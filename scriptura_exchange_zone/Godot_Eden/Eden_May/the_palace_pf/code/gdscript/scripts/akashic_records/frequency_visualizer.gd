extends Node3D
class_name FrequencyVisualizer

# Signal when a word is selected
signal word_selected(word)

# References
var akashic_records = null
var evolution_manager = null

# Visualization settings
@export var auto_update: bool = true
@export var update_interval: float = 2.0
@export var max_words: int = 100
@export var layout_type: String = "radial"  # radial, spiral, cluster
@export var show_connections: bool = true
@export var connection_threshold: float = 0.7  # Similarity threshold for connections

# Node for organizing word visualizations
var words_container: Node3D
var word_nodes = {}  # Dictionary of word_id to visualization node
var update_timer: Timer
var selected_node = null

# Layout parameters
var radial_distance: float = 5.0
var spiral_distance: float = 0.5
var spiral_rotation: float = 0.5
var cluster_separation: float = 6.0

# Visualization node class
class VisualizationNode extends Node3D:
	# Signal when this node is selected/clicked
	signal clicked(node)

	# References
	var word = null  # Reference to the WordEntry this node represents
	var visualizer = null  # Reference to the parent FrequencyVisualizer

	# Visual components
	var mesh_instance: MeshInstance3D
	var pulse_animation: AnimationPlayer
	var label_3d: Label3D
	var connection_lines = []

	# Visual properties
	var base_size: float = 0.2
	var max_size: float = 1.0
	var base_color = Color(0.2, 0.5, 1.0)
	var highlight_color = Color(1.0, 0.5, 0.2)
	var selected_color = Color(1.0, 0.8, 0.0)
	var is_selected = false
	var is_highlighted = false

	# Frequency and pulse properties
	var frequency: float = 1.0
	var pulse_speed: float = 1.0
	var pulse_strength: float = 0.2

	func _init(p_word, p_visualizer):
		word = p_word
		visualizer = p_visualizer
		
		# Create the visual elements
		_create_mesh()
		_create_pulse_animation()
		_create_label()
		
		# Set up interaction
		var area = Area3D.new()
		add_child(area)
		
		var collision_shape = CollisionShape3D.new()
		var sphere_shape = SphereShape3D.new()
		sphere_shape.radius = max_size * 1.2  # Slightly larger than the node for easier selection
		collision_shape.shape = sphere_shape
		area.add_child(collision_shape)
		
		# Connect signals
		area.input_event.connect(_on_input_event)
		area.mouse_entered.connect(_on_mouse_entered)
		area.mouse_exited.connect(_on_mouse_exited)

	func _create_mesh():
		# Create a sphere mesh for the node
		mesh_instance = MeshInstance3D.new()
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = base_size
		sphere_mesh.height = base_size * 2
		
		# Create material
		var material = StandardMaterial3D.new()
		material.albedo_color = base_color
		material.emission_enabled = true
		material.emission = base_color
		material.emission_energy_multiplier = 0.5
		
		sphere_mesh.material = material
		mesh_instance.mesh = sphere_mesh
		
		add_child(mesh_instance)

	func _create_pulse_animation():
		# Create animation player for pulsing effect
		pulse_animation = AnimationPlayer.new()
		add_child(pulse_animation)
		
		# Create pulse animation
		var animation = Animation.new()
		
		# Create track for mesh radius
		var track_idx = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_idx, "mesh_instance:mesh:radius")
		
		# Add keyframes for pulsing
		animation.track_insert_key(track_idx, 0.0, base_size)
		animation.track_insert_key(track_idx, 0.5, base_size * (1.0 + pulse_strength))
		animation.track_insert_key(track_idx, 1.0, base_size)
		
		# Same for height (2x radius)
		track_idx = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_idx, "mesh_instance:mesh:height")
		animation.track_insert_key(track_idx, 0.0, base_size * 2)
		animation.track_insert_key(track_idx, 0.5, base_size * 2 * (1.0 + pulse_strength))
		animation.track_insert_key(track_idx, 1.0, base_size * 2)
		
		# Add track for emission energy
		track_idx = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_idx, "mesh_instance:mesh:material:emission_energy_multiplier")
		animation.track_insert_key(track_idx, 0.0, 0.5)
		animation.track_insert_key(track_idx, 0.5, 1.0)
		animation.track_insert_key(track_idx, 1.0, 0.5)
		
		# Set animation length
		animation.length = 1.0
		
		# Add the animation to the player
		var anim_library = AnimationLibrary.new()
		anim_library.add_animation("pulse", animation)
		pulse_animation.add_animation_library("", anim_library)
		
		# Play the animation on loop
		pulse_animation.play("pulse")
		pulse_animation.speed_scale = pulse_speed

	func _create_label():
		# Create 3D label for the word text
		label_3d = Label3D.new()
		label_3d.text = word.id
		label_3d.font_size = 18
		label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label_3d.no_depth_test = true
		label_3d.position.y = base_size * 1.5  # Position above the sphere
		
		add_child(label_3d)

	func create_connection_to(target_node, line_width=0.05, color=Color(0.5, 0.5, 0.5, 0.3)):
		# Create a line connecting this node to another node
		var line_mesh = MeshInstance3D.new()
		var immediate_mesh = ImmediateMesh.new()
		line_mesh.mesh = immediate_mesh
		
		# Create material for the line
		var material = StandardMaterial3D.new()
		material.albedo_color = color
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		line_mesh.material_override = material
		
		# Add line to the scene
		visualizer.add_child(line_mesh)
		connection_lines.append({"line": line_mesh, "target": target_node, "width": line_width})
		
		# Draw initial line
		_update_connection_line({"line": line_mesh, "target": target_node, "width": line_width})
		
		return line_mesh

	func update_connections():
		# Update all connection lines positions
		for connection in connection_lines:
			_update_connection_line(connection)

	func _update_connection_line(connection):
		var line = connection.line
		var target = connection.target
		var width = connection.width
		
		# Skip if target no longer exists
		if not is_instance_valid(target):
			if is_instance_valid(line):
				line.queue_free()
			connection_lines.erase(connection)
			return
		
		# Get start and end positions
		var start_pos = global_position
		var end_pos = target.global_position
		
		# Calculate direction and length
		var direction = (end_pos - start_pos).normalized()
		var length = start_pos.distance_to(end_pos)
		
		# Adjust start and end to be on the surface of the spheres
		start_pos += direction * base_size
		end_pos -= direction * target.base_size
		
		# Recalculate length
		length = start_pos.distance_to(end_pos)
		
		# Draw the line
		var immediate_mesh = line.mesh as ImmediateMesh
		immediate_mesh.clear_surfaces()
		
		# Begin surface
		immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
		
		# Create a simple line mesh with width
		var right = direction.cross(Vector3.UP).normalized()
		if right.length() < 0.1:  # Handle case when direction is parallel to UP
			right = direction.cross(Vector3.RIGHT).normalized()
		
		var up = direction.cross(right).normalized()
		
		# Create quad vertices for the line
		var half_width = width / 2.0
		var v1 = start_pos + right * half_width
		var v2 = start_pos - right * half_width
		var v3 = end_pos + right * half_width
		var v4 = end_pos - right * half_width
		
		# Add triangles (two to form a quad)
		immediate_mesh.surface_add_vertex(v1)
		immediate_mesh.surface_add_vertex(v2)
		immediate_mesh.surface_add_vertex(v3)
		
		immediate_mesh.surface_add_vertex(v2)
		immediate_mesh.surface_add_vertex(v4)
		immediate_mesh.surface_add_vertex(v3)
		
		immediate_mesh.surface_end()

	func update_visual(based_on_usage=true):
		# Update the visual representation based on word properties
		if word == null:
			return
		
		# Calculate size based on usage count
		var size_factor = 0.0
		if based_on_usage and word.usage_count > 0:
			size_factor = min(1.0, log(word.usage_count + 1) / log(20))  # Logarithmic scaling
		else:
			# Calculate from properties if any exist
			if "energy_level" in word.properties:
				size_factor = word.properties.energy_level
			elif "importance" in word.properties:
				size_factor = word.properties.importance
			else:
				size_factor = 0.5  # Default
		
		# Calculate frequency based on properties
		if "resonance_frequency" in word.properties:
			frequency = word.properties.resonance_frequency
		elif "vibrational_state" in word.properties:
			frequency = word.properties.vibrational_state / 5.0
		else:
			frequency = 1.0
		
		# Update the size
		base_size = lerp(0.2, max_size, size_factor)
		
		# Update the mesh
		if mesh_instance and mesh_instance.mesh:
			mesh_instance.mesh.radius = base_size
			mesh_instance.mesh.height = base_size * 2
		
		# Update pulse speed based on frequency
		pulse_speed = frequency
		if pulse_animation:
			pulse_animation.speed_scale = pulse_speed
		
		# Update label size based on node size
		if label_3d:
			label_3d.font_size = int(18 + (10 * size_factor))
			label_3d.position.y = base_size * 1.5
			
		# Update collision shape if it exists
		var area = get_node_or_null("Area3D")
		if area:
			var collision = area.get_node_or_null("CollisionShape3D")
			if collision and collision.shape:
				collision.shape.radius = base_size * 1.2

	func set_selected(selected):
		is_selected = selected
		_update_material_color()

	func set_highlighted(highlighted):
		is_highlighted = highlighted
		_update_material_color()

	func _update_material_color():
		if not mesh_instance or not mesh_instance.mesh or not mesh_instance.mesh.material:
			return
			
		var material = mesh_instance.mesh.material
		
		if is_selected:
			material.albedo_color = selected_color
			material.emission = selected_color
			material.emission_energy_multiplier = 1.0
		elif is_highlighted:
			material.albedo_color = highlight_color
			material.emission = highlight_color
			material.emission_energy_multiplier = 0.8
		else:
			material.albedo_color = base_color
			material.emission = base_color
			material.emission_energy_multiplier = 0.5

	func _on_input_event(_camera, event, _position, _normal, _shape_idx):
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				# Left click - emit signal for selection
				clicked.emit(self)

	func _on_mouse_entered():
		set_highlighted(true)

	func _on_mouse_exited():
		set_highlighted(false)

func _ready():
	# Create container for word nodes
	words_container = Node3D.new()
	words_container.name = "WordsContainer"
	add_child(words_container)
	
	# Create camera
	var camera = Camera3D.new()
	camera.position = Vector3(0, 0, 15)
	add_child(camera)
	
	# Add lighting
	var light = DirectionalLight3D.new()
	light.position = Vector3(10, 10, 10)
	light.look_at_from_position(light.position, Vector3.ZERO, Vector3.UP)
	add_child(light)
	
	# Create timer for auto updates
	if auto_update:
		update_timer = Timer.new()
		update_timer.wait_time = update_interval
		update_timer.timeout.connect(_on_update_timer)
		update_timer.autostart = true
		add_child(update_timer)
	
	# First update
	update_visualization()

func _on_update_timer():
	update_visualization()

func update_visualization():
	if not akashic_records:
		return
	
	# Get all words from dictionary
	var all_words = []
	var words_dict = akashic_records.dynamic_dictionary.words
	
	for word_id in words_dict:
		all_words.append(words_dict[word_id])
	
	# Sort words by usage count (descending)
	all_words.sort_custom(func(a, b): return a.usage_count > b.usage_count)
	
	# Limit to max_words
	var words_to_show = all_words.slice(0, min(all_words.size(), max_words))
	
	# Track existing nodes to identify which ones to remove
	var existing_ids = word_nodes.keys()
	var current_ids = []
	
	# Create or update nodes for each word
	for word in words_to_show:
		current_ids.append(word.id)
		
		if word_nodes.has(word.id):
			# Update existing node
			word_nodes[word.id].update_visual()
		else:
			# Create new node
			var word_node = VisualizationNode.new(word, self)
			words_container.add_child(word_node)
			word_nodes[word.id] = word_node
			
			# Connect signals
			word_node.clicked.connect(_on_word_node_clicked)
	
	# Remove nodes for words that are no longer in view
	for id in existing_ids:
		if not current_ids.has(id):
			if word_nodes[id] == selected_node:
				selected_node = null
				word_selected.emit(null)
			
			word_nodes[id].queue_free()
			word_nodes.erase(id)
	
	# Update layout
	match layout_type:
		"radial":
			_layout_radial()
		"spiral":
			_layout_spiral()
		"cluster":
			_layout_cluster()
	
	# Create connections
	if show_connections:
		_create_connections()
	
	# Update all connections (in case nodes moved)
	for node in word_nodes.values():
		node.update_connections()

func _layout_radial():
	# Arrange words in a circular pattern
	var node_count = word_nodes.size()
	if node_count == 0:
		return
	
	var angle_step = 2 * PI / node_count
	var current_angle = 0
	
	# Sort nodes by usage count for consistent order
	var sorted_nodes = word_nodes.values()
	sorted_nodes.sort_custom(func(a, b): return a.word.usage_count > b.word.usage_count)
	
	for node in sorted_nodes:
		var x = cos(current_angle) * radial_distance
		var z = sin(current_angle) * radial_distance
		
		# Add some height variation based on properties
		var y = 0.0
		if "stability_factor" in node.word.properties:
			y = node.word.properties.stability_factor * 2.0 - 1.0
		
		# Set position with a bit of smoothing
		var target_pos = Vector3(x, y, z)
		node.global_position = node.global_position.lerp(target_pos, 0.1)
		
		current_angle += angle_step

func _layout_spiral():
	# Arrange words in a spiral pattern
	var sorted_nodes = word_nodes.values()
	sorted_nodes.sort_custom(func(a, b): return a.word.usage_count > b.word.usage_count)
	
	var current_angle = 0
	var current_radius = 0
	
	for i in range(sorted_nodes.size()):
		var node = sorted_nodes[i]
		
		# Spiral parameters
		current_radius = spiral_distance * sqrt(i + 1)
		current_angle = i * spiral_rotation
		
		var x = cos(current_angle) * current_radius
		var z = sin(current_angle) * current_radius
		
		# Add height based on frequency
		var y = 0.0
		if node.frequency > 0:
			y = (node.frequency - 1.0) * 0.5
		
		# Set position with smoothing
		var target_pos = Vector3(x, y, z)
		node.global_position = node.global_position.lerp(target_pos, 0.1)

func _layout_cluster():
	# Group words into clusters based on properties
	var clusters = {}
	
	# Sort nodes by certain properties
	for id in word_nodes:
		var node = word_nodes[id]
		var cluster_key = "default"
		
		# Determine cluster based on properties
		if "energy_level" in node.word.properties:
			var energy = node.word.properties.energy_level
			if energy < 0.3:
				cluster_key = "low_energy"
			elif energy < 0.7:
				cluster_key = "mid_energy"
			else:
				cluster_key = "high_energy"
		elif node.word.variants.size() > 0:
			cluster_key = "has_variants"
		elif not node.word.parent_id.is_empty():
			cluster_key = "variant"
		
		# Add to cluster
		if not clusters.has(cluster_key):
			clusters[cluster_key] = []
		clusters[cluster_key].append(node)
	
	# Position each cluster
	var cluster_positions = {
		"default": Vector3(0, 0, 0),
		"low_energy": Vector3(-cluster_separation, 0, -cluster_separation),
		"mid_energy": Vector3(0, 0, cluster_separation),
		"high_energy": Vector3(cluster_separation, 0, 0),
		"has_variants": Vector3(-cluster_separation, 0, cluster_separation),
		"variant": Vector3(cluster_separation, 0, -cluster_separation)
	}
	
	# Layout each cluster in a mini radial pattern
	for cluster_key in clusters:
		var nodes = clusters[cluster_key]
		var center = cluster_positions[cluster_key]
		var radius = 0.8
		
		# Mini radial layout
		var angle_step = 2 * PI / max(1, nodes.size())
		var current_angle = 0
		
		for node in nodes:
			var offset_x = cos(current_angle) * radius
			var offset_z = sin(current_angle) * radius
			
			# Add some height variation
			var offset_y = 0.0
			if "stability_factor" in node.word.properties:
				offset_y = node.word.properties.stability_factor - 0.5
			
			var target_pos = center + Vector3(offset_x, offset_y, offset_z)
			node.global_position = node.global_position.lerp(target_pos, 0.1)
			
			current_angle += angle_step

func _create_connections():
	# Clear existing connections
	for node in word_nodes.values():
		for connection in node.connection_lines:
			if is_instance_valid(connection.line):
				connection.line.queue_free()
		node.connection_lines.clear()
	
	# Create connections between related words
	var nodes = word_nodes.values()
	
	# Connect variants to their parents
	for node in nodes:
		var word = node.word
		
		# Connect variants to parent
		if not word.parent_id.is_empty() and word_nodes.has(word.parent_id):
			var parent_node = word_nodes[word.parent_id]
			node.create_connection_to(parent_node, 0.05, Color(0.8, 0.6, 0.1, 0.5))
		
		# Connect parents to their variants
		if word.variants.size() > 0:
			for variant in word.variants:
				if variant is WordEntry and word_nodes.has(variant.id):
					node.create_connection_to(word_nodes[variant.id], 0.05, Color(0.8, 0.6, 0.1, 0.5))
	
	# Connect words with similar properties
	for i in range(nodes.size()):
		var node_a = nodes[i]
		
		for j in range(i + 1, nodes.size()):
			var node_b = nodes[j]
			
			# Skip variants as they are already connected
			if not node_a.word.parent_id.is_empty() and node_a.word.parent_id == node_b.word.id:
				continue
			if not node_b.word.parent_id.is_empty() and node_b.word.parent_id == node_a.word.id:
				continue
				
			var similarity = _calculate_similarity(node_a.word, node_b.word)
			
			if similarity > connection_threshold:
				# Create connection with alpha based on similarity
				var alpha = (similarity - connection_threshold) / (1.0 - connection_threshold)
				var connection_color = Color(0.5, 0.5, 0.8, alpha * 0.3)
				var width = 0.02 + (similarity - connection_threshold) * 0.05
				
				node_a.create_connection_to(node_b, width, connection_color)

func _calculate_similarity(word_a, word_b):
	# Calculate similarity score between two words based on their properties
	var similarity = 0.0
	var property_count = 0
	
	# Check common properties
	for prop in word_a.properties:
		if prop in word_b.properties:
			var a_val = word_a.properties[prop]
			var b_val = word_b.properties[prop]
			
			if a_val is float and b_val is float:
				# Calculate normalized difference
				var diff = abs(a_val - b_val)
				var max_range = 1.0  # Assume properties are normalized
				
				similarity += 1.0 - min(1.0, diff / max_range)
				property_count += 1
	
	# Return average similarity, or 0 if no common properties
	return similarity / property_count if property_count > 0 else 0.0

func _on_word_node_clicked(node):
	# Deselect previously selected node
	if selected_node and is_instance_valid(selected_node):
		selected_node.set_selected(false)
	
	# Select new node if not the same
	if node != selected_node:
		selected_node = node
		selected_node.set_selected(true)
		word_selected.emit(node.word)
	else:
		# Deselect if clicking the same node
		selected_node = null
		word_selected.emit(null)

func get_selected_word():
	return selected_node.word if selected_node else null

func select_word(word_id: String):
	# Deselect current selection
	if selected_node and is_instance_valid(selected_node):
		selected_node.set_selected(false)
		selected_node = null
	
	# Find and select the new word
	if word_nodes.has(word_id):
		selected_node = word_nodes[word_id]
		selected_node.set_selected(true)
		
		# Center the camera on this node (if we had camera controls)
		# For now, we'll just emit the signal
		word_selected.emit(selected_node.word)
	else:
		word_selected.emit(null)

func set_layout(new_layout: String):
	layout_type = new_layout
	update_visualization()

func set_show_connections(show: bool):
	show_connections = show
	update_visualization()

func set_max_words(count: int):
	max_words = count
	update_visualization()