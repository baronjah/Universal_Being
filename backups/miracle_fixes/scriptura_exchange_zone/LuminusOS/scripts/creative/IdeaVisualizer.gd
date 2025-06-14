extends Node3D
class_name IdeaVisualizer

# References to important nodes
var idea_container: Node3D
var word_cloud: Node3D
var connection_beams: Node3D
var animation_player: AnimationPlayer
var word_scene = preload("res://scenes/word_object.tscn") # Assumes you have this scene

# Configuration options
var max_words: int = 20
var arrangement_radius: float = 5.0
var color_palette: Array = [
	Color(0.8, 0.2, 0.2),  # Red
	Color(0.2, 0.8, 0.2),  # Green
	Color(0.2, 0.2, 0.8),  # Blue
	Color(0.8, 0.8, 0.2),  # Yellow
	Color(0.8, 0.2, 0.8),  # Magenta
	Color(0.2, 0.8, 0.8),  # Cyan
	Color(0.8, 0.5, 0.2),  # Orange
	Color(0.5, 0.2, 0.8)   # Purple
]

# Current visualization state
var current_words: Array = []
var current_theme: String = ""
var active_words: Dictionary = {}  # Maps word text to Node3D instances
var connection_strength: Dictionary = {}  # Maps pairs of words to connection strength
var visualization_mode: String = "cloud"  # cloud, network, orbit, flow

# Signals
signal visualization_complete(word_count)
signal word_selected(word_text, word_position, word_properties)
signal theme_changed(new_theme)

func _ready():
	# Create necessary child nodes if they don't exist
	_setup_scene()
	
	# Look for OpenAI Gateway and connect to it if possible
	var openai_gateway = get_node_or_null("/root/OpenAIGateway")
	if openai_gateway:
		openai_gateway.word_transformed.connect(_on_word_transformed)
		openai_gateway.world_description_created.connect(_on_world_description_created)
	
	# Connect to memory system if available
	var memory_manager = get_node_or_null("/root/MemoryEvolutionManager")
	if memory_manager:
		memory_manager.word_caught.connect(_on_word_caught)

func _setup_scene():
	# Create container node for all visualized ideas
	idea_container = Node3D.new()
	idea_container.name = "IdeaContainer"
	add_child(idea_container)
	
	# Create word cloud container
	word_cloud = Node3D.new()
	word_cloud.name = "WordCloud"
	idea_container.add_child(word_cloud)
	
	# Create connections container
	connection_beams = Node3D.new()
	connection_beams.name = "ConnectionBeams"
	idea_container.add_child(connection_beams)
	
	# Create animation player
	animation_player = AnimationPlayer.new()
	animation_player.name = "AnimationPlayer"
	add_child(animation_player)
	
	# Create animations
	_create_animations()

func _create_animations():
	# Pulsating animation
	var pulsate_animation = Animation.new()
	var track_index = pulsate_animation.add_track(Animation.TYPE_VALUE)
	pulsate_animation.track_set_path(track_index, "IdeaContainer:scale")
	pulsate_animation.track_insert_key(track_index, 0.0, Vector3(1, 1, 1))
	pulsate_animation.track_insert_key(track_index, 1.0, Vector3(1.05, 1.05, 1.05))
	pulsate_animation.track_insert_key(track_index, 2.0, Vector3(1, 1, 1))
	pulsate_animation.length = 2.0
	pulsate_animation.loop_mode = Animation.LOOP_LINEAR
	
	animation_player.add_animation("pulsate", pulsate_animation)
	
	# Slow rotation animation
	var rotate_animation = Animation.new()
	track_index = rotate_animation.add_track(Animation.TYPE_VALUE)
	rotate_animation.track_set_path(track_index, "IdeaContainer:rotation")
	rotate_animation.track_insert_key(track_index, 0.0, Vector3(0, 0, 0))
	rotate_animation.track_insert_key(track_index, 10.0, Vector3(0, 2 * PI, 0))
	rotate_animation.length = 10.0
	rotate_animation.loop_mode = Animation.LOOP_LINEAR
	
	animation_player.add_animation("rotate", rotate_animation)

func visualize_keywords(keywords: Array, theme: String = ""):
	# Clear existing visualization
	clear_visualization()
	
	# Update current state
	current_words = keywords
	if theme != "":
		current_theme = theme
		emit_signal("theme_changed", current_theme)
	
	# Choose visualization based on mode
	match visualization_mode:
		"cloud":
			_visualize_as_cloud(keywords)
		"network":
			_visualize_as_network(keywords)
		"orbit":
			_visualize_as_orbit(keywords)
		"flow":
			_visualize_as_flow(keywords)
		_:
			_visualize_as_cloud(keywords)  # Default to cloud

	# Create connections between related words
	_create_connections()
	
	# Start animations
	animation_player.play("pulsate")
	
	emit_signal("visualization_complete", keywords.size())

func _visualize_as_cloud(keywords: Array):
	# Position words in a cloud-like 3D arrangement
	for i in range(min(keywords.size(), max_words)):
		var word_text = keywords[i]
		var word_node = _create_word_node(word_text)
		
		# Position words in a sphere
		var phi = acos(1 - 2 * (i + 1) / float(min(keywords.size(), max_words) + 1))
		var theta = PI * (1 + sqrt(5)) * (i + 1)
		
		var x = arrangement_radius * sin(phi) * cos(theta)
		var y = arrangement_radius * sin(phi) * sin(theta)
		var z = arrangement_radius * cos(phi)
		
		word_node.position = Vector3(x, y, z)
		
		# Look at center
		word_node.look_at(Vector3.ZERO)
		
		# Store in active words dictionary
		active_words[word_text] = word_node
		
		# Add to word cloud
		word_cloud.add_child(word_node)

func _visualize_as_network(keywords: Array):
	# Position words in a network-like arrangement with nodes and connections
	for i in range(min(keywords.size(), max_words)):
		var word_text = keywords[i]
		var word_node = _create_word_node(word_text)
		
		# Create network layout
		var angle = 2 * PI * i / float(min(keywords.size(), max_words))
		var distance = arrangement_radius * (0.5 + randf() * 0.5)
		
		var x = distance * cos(angle)
		var z = distance * sin(angle)
		var y = (randf() - 0.5) * arrangement_radius * 0.5
		
		word_node.position = Vector3(x, y, z)
		
		# Look at center with slight randomization
		word_node.look_at(Vector3(randf() * 0.2, randf() * 0.2, randf() * 0.2))
		
		# Store in active words dictionary
		active_words[word_text] = word_node
		
		# Add to word cloud
		word_cloud.add_child(word_node)

func _visualize_as_orbit(keywords: Array):
	# Position words in orbital rings around a center
	var rings = 3
	var words_per_ring = ceil(float(min(keywords.size(), max_words)) / rings)
	
	var word_index = 0
	for ring in range(rings):
		var ring_radius = arrangement_radius * (0.5 + ring * 0.5)
		var word_count_in_ring = min(words_per_ring, min(keywords.size(), max_words) - word_index)
		
		for i in range(word_count_in_ring):
			if word_index >= min(keywords.size(), max_words):
				break
			
			var word_text = keywords[word_index]
			var word_node = _create_word_node(word_text)
			
			var angle = 2 * PI * i / float(word_count_in_ring)
			var x = ring_radius * cos(angle)
			var z = ring_radius * sin(angle)
			var y = (ring - 1) * arrangement_radius * 0.3
			
			word_node.position = Vector3(x, y, z)
			word_node.look_at(Vector3(0, y, 0))
			
			active_words[word_text] = word_node
			word_cloud.add_child(word_node)
			
			word_index += 1

func _visualize_as_flow(keywords: Array):
	# Position words in a flowing stream-like pattern
	var curve_points = 5
	var words_per_segment = ceil(float(min(keywords.size(), max_words)) / (curve_points - 1))
	
	# Generate a random 3D curve
	var curve_positions = []
	for i in range(curve_points):
		var x = (i - curve_points/2) * arrangement_radius * 0.5
		var y = sin(i * PI / (curve_points - 1)) * arrangement_radius * 0.3
		var z = cos(i * PI / 2 + PI/4) * arrangement_radius * 0.3
		curve_positions.append(Vector3(x, y, z))
	
	var word_index = 0
	for segment in range(curve_points - 1):
		var start_pos = curve_positions[segment]
		var end_pos = curve_positions[segment + 1]
		var word_count_in_segment = min(words_per_segment, min(keywords.size(), max_words) - word_index)
		
		for i in range(word_count_in_segment):
			if word_index >= min(keywords.size(), max_words):
				break
			
			var word_text = keywords[word_index]
			var word_node = _create_word_node(word_text)
			
			var t = float(i) / float(word_count_in_segment)
			var pos = start_pos.lerp(end_pos, t)
			
			# Add some randomness
			pos += Vector3(
				(randf() - 0.5) * arrangement_radius * 0.2,
				(randf() - 0.5) * arrangement_radius * 0.2,
				(randf() - 0.5) * arrangement_radius * 0.2
			)
			
			word_node.position = pos
			
			# Look in the direction of flow
			var look_direction = (end_pos - start_pos).normalized()
			if look_direction != Vector3.ZERO:
				word_node.look_at(pos + look_direction)
			
			active_words[word_text] = word_node
			word_cloud.add_child(word_node)
			
			word_index += 1

func _create_word_node(word_text: String) -> Node3D:
	# This function creates a 3D visualization for a single word
	# It will use the word_scene if available, otherwise create a simple mesh
	
	var word_node
	
	if ResourceLoader.exists("res://scenes/word_object.tscn"):
		# Use the preloaded scene
		word_node = word_scene.instantiate()
		word_node.set_word(word_text)
	else:
		# Create a simple text mesh
		word_node = Node3D.new()
		
		var text_mesh = MeshInstance3D.new()
		var font_size = 0.2
		
		# Create text mesh (simplified - in real implementation you'd use a TextMesh)
		var text_shape = TextMesh.new()
		text_shape.text = word_text
		text_shape.font_size = font_size * 100  # Font size in TextMesh is in pixels
		
		var text_mesh_instance = MeshInstance3D.new()
		text_mesh_instance.mesh = text_shape
		text_mesh_instance.name = "TextMesh"
		
		# Apply material
		var material = StandardMaterial3D.new()
		material.albedo_color = color_palette[randi() % color_palette.size()]
		material.metallic = 0.2
		material.roughness = 0.7
		text_mesh_instance.material_override = material
		
		word_node.add_child(text_mesh_instance)
	
	# Set node name and metadata
	word_node.name = "Word_" + word_text.replace(" ", "_")
	
	# Store word properties as metadata
	word_node.set_meta("word_text", word_text)
	word_node.set_meta("creation_time", Time.get_unix_time_from_system())
	word_node.set_meta("importance", 1.0)  # Default importance
	
	# Make words interactive
	_make_word_interactive(word_node)
	
	return word_node

func _make_word_interactive(word_node: Node3D):
	# Add area for interaction
	var area = Area3D.new()
	area.name = "InteractionArea"
	
	var collision_shape = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.3  # Adjust based on your word size
	collision_shape.shape = shape
	
	area.add_child(collision_shape)
	word_node.add_child(area)
	
	# Connect signals
	area.input_event.connect(_on_word_input_event.bind(word_node))
	area.mouse_entered.connect(_on_word_mouse_entered.bind(word_node))
	area.mouse_exited.connect(_on_word_mouse_exited.bind(word_node))

func _on_word_input_event(camera, event, click_position, click_normal, shape_idx, word_node):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Handle word selection
		var word_text = word_node.get_meta("word_text")
		var word_properties = {
			"creation_time": word_node.get_meta("creation_time"),
			"importance": word_node.get_meta("importance")
		}
		
		# Highlight selected word
		_highlight_word(word_node)
		
		# Emit signal for external systems
		emit_signal("word_selected", word_text, word_node.global_position, word_properties)

func _on_word_mouse_entered(word_node):
	# Scale up the word slightly on hover
	var tween = create_tween()
	tween.tween_property(word_node, "scale", Vector3(1.2, 1.2, 1.2), 0.2)

func _on_word_mouse_exited(word_node):
	# Scale back to normal
	var tween = create_tween()
	tween.tween_property(word_node, "scale", Vector3(1.0, 1.0, 1.0), 0.2)

func _highlight_word(word_node: Node3D):
	# Reset previous highlights
	for word in word_cloud.get_children():
		if word.has_meta("highlighted") and word.get_meta("highlighted"):
			var material = word.get_node("TextMesh").material_override
			material.emission_enabled = false
			material.emission_energy = 0.0
			word.set_meta("highlighted", false)
	
	# Apply highlight to selected word
	var text_mesh = word_node.get_node("TextMesh")
	if text_mesh and text_mesh.material_override:
		var material = text_mesh.material_override
		material.emission_enabled = true
		material.emission = material.albedo_color
		material.emission_energy = 2.0
		word_node.set_meta("highlighted", true)
		
		# Create highlight effect
		var particles = GPUParticles3D.new()
		particles.name = "HighlightParticles"
		
		# Set up particle material and properties
		# (In a real implementation you would set up the particle system properly)
		
		word_node.add_child(particles)
		
		# Remove after a while
		await get_tree().create_timer(5.0).timeout
		if particles and is_instance_valid(particles):
			particles.queue_free()

func _create_connections():
	# Clear previous connections
	for connection in connection_beams.get_children():
		connection.queue_free()
	
	# Reset connection strengths
	connection_strength.clear()
	
	# Create connections between words based on semantic relationships
	for i in range(current_words.size()):
		var word1 = current_words[i]
		if not word1 in active_words:
			continue
			
		for j in range(i + 1, current_words.size()):
			var word2 = current_words[j]
			if not word2 in active_words:
				continue
				
			# Skip if too many connections (prevents visual clutter)
			if connection_beams.get_child_count() > current_words.size() * 2:
				break
				
			# Calculate semantic relationship (simplified method)
			var relationship = _calculate_word_relationship(word1, word2)
			
			# Only create visible connections for stronger relationships
			if relationship > 0.3:
				_create_connection_beam(active_words[word1], active_words[word2], relationship)
				
				# Store connection strength
				connection_strength[word1 + ":" + word2] = relationship

func _calculate_word_relationship(word1: String, word2: String) -> float:
	# This is a simplified semantic relationship calculation
	# In a real implementation, you might use word embeddings or other NLP techniques
	
	# For now, implement a simple approach
	var relationship = 0.0
	
	# Similar length gives some relationship
	var length_diff = abs(word1.length() - word2.length())
	if length_diff <= 2:
		relationship += 0.2
	
	# Common prefixes or suffixes
	var prefix_length = min(3, min(word1.length(), word2.length()))
	if word1.substr(0, prefix_length) == word2.substr(0, prefix_length):
		relationship += 0.3
	
	# Common letters
	var common_letters = 0
	for c in word1:
		if word2.contains(c):
			common_letters += 1
	
	relationship += float(common_letters) / max(word1.length(), word2.length()) * 0.5
	
	# Add some randomness for demo purposes
	relationship += randf() * 0.2
	
	return min(relationship, 1.0)

func _create_connection_beam(word_node1: Node3D, word_node2: Node3D, strength: float = 0.5):
	# Create a beam/line between two words
	var beam = MeshInstance3D.new()
	beam.name = "Beam_" + word_node1.name + "_to_" + word_node2.name
	
	# Calculate beam properties
	var start_pos = word_node1.position
	var end_pos = word_node2.position
	var direction = (end_pos - start_pos).normalized()
	var distance = start_pos.distance_to(end_pos)
	
	# Create beam mesh
	var beam_mesh = CylinderMesh.new()
	beam_mesh.top_radius = 0.02 * strength
	beam_mesh.bottom_radius = 0.02 * strength
	beam_mesh.height = distance
	
	beam.mesh = beam_mesh
	
	# Position and orient the beam
	beam.position = start_pos + direction * (distance / 2)
	
	# Orient the beam to point from start to end
	beam.look_at(end_pos)
	beam.rotate_object_local(Vector3(1, 0, 0), PI/2)
	
	# Create material based on strength
	var beam_material = StandardMaterial3D.new()
	var color_factor = min(1.0, strength * 2)
	beam_material.albedo_color = Color(0.2, 0.5 + color_factor * 0.5, 0.8, strength * 0.7)
	beam_material.metallic = 0.8
	beam_material.roughness = 0.1
	beam_material.emission_enabled = true
	beam_material.emission = Color(0.3, 0.6, 1.0)
	beam_material.emission_energy = strength * 2
	
	beam.material_override = beam_material
	
	# Add beam to connection container
	connection_beams.add_child(beam)
	
	return beam

func clear_visualization():
	# Clear all words
	for word in word_cloud.get_children():
		word.queue_free()
	
	# Clear all connections
	for connection in connection_beams.get_children():
		connection.queue_free()
	
	# Reset state
	active_words.clear()
	connection_strength.clear()
	
	# Stop animations
	animation_player.stop()

func set_visualization_mode(mode: String):
	visualization_mode = mode
	
	# If we have words to display, update the visualization
	if current_words.size() > 0:
		visualize_keywords(current_words, current_theme)
	
	return visualization_mode

func _on_word_transformed(original: String, transformed: String):
	# When a word is transformed by the OpenAI API, visualize it
	visualize_keywords([original, transformed], "Word Transformation")

func _on_world_description_created(description: String):
	# When a world description is created, extract keywords and visualize
	var simple_keywords = _extract_simple_keywords(description)
	visualize_keywords(simple_keywords, "World Description")

func _on_word_caught(source: String, word: String):
	# When memory manager catches a word, add it to visualization if relevant
	if current_words.size() < max_words and not current_words.has(word):
		current_words.append(word)
		visualize_keywords(current_words, current_theme)

func _extract_simple_keywords(text: String) -> Array:
	# Simple keyword extraction for testing
	# In production, this should use the OpenAIGateway.extract_keywords_from_text
	
	var words = text.split(" ")
	var results = []
	
	for word in words:
		word = word.strip_edges().to_lower()
		
		# Remove punctuation
		word = word.replace(",", "").replace(".", "").replace("!", "").replace("?", "")
		
		# Skip short words and duplicates
		if word.length() > 3 and not results.has(word) and results.size() < max_words:
			results.append(word)
	
	return results