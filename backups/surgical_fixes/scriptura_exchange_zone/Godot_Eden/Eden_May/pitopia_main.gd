extends Node3D

class_name PitopiaMain

# ----- NODE PATHS -----
# These paths help with easily connecting nodes in the editor
@export_node_path var word_manifestor_path: NodePath
@export_node_path var turn_system_path: NodePath
@export_node_path var ethereal_engine_path: NodePath
@export_node_path var color_system_path: NodePath
@export_node_path var console_path: NodePath
@export_node_path var player_camera_path: NodePath
@export_node_path var entity_container_path: NodePath

# ----- NODE REFERENCES -----
var word_manifestor = null
var turn_system = null
var ethereal_engine = null
var color_system = null
var console = null
var player_camera = null
var entity_container = null

# ----- CONFIGURATION -----
@export var auto_initialize: bool = true
@export var auto_connect_signals: bool = true
@export var default_dimension: int = 3
@export var default_turn_duration: float = 9.0
@export var enable_creation_on_words: bool = true
@export var enable_automatic_dimension_effects: bool = true
@export var enable_debug_messages: bool = true

# ----- PRELOAD RESOURCES -----
@export var default_entity_scene: PackedScene
@export var word_display_effect_scene: PackedScene
@export var dimension_particle_effect_scene: PackedScene
@export var pitopia_environment: Environment

# ----- STATE VARIABLES -----
var initialized: bool = false
var current_dimension: int = 3
var current_turn: int = 1
var manifested_words = []
var manifested_entities = {}
var dimension_history = []
var is_console_visible: bool = false

# ----- SIGNALS -----
signal initialization_completed
signal word_manifested(word, entity)
signal dimension_changed(new_dimension, old_dimension)
signal turn_advanced(turn_number)
signal pitopia_state_changed(state_name, value)
signal entity_connected(source_entity, target_entity, connection_type)

# ----- INITIALIZATION -----
func _ready():
	print("PitopiaMain: Initializing...")
	
	# Setup environment if provided
	if pitopia_environment != null:
		var world_env = get_node_or_null("WorldEnvironment")
		if world_env:
			world_env.environment = pitopia_environment
		else:
			var new_world_env = WorldEnvironment.new()
			new_world_env.name = "WorldEnvironment"
			new_world_env.environment = pitopia_environment
			add_child(new_world_env)
	
	if auto_initialize:
		initialize()

func initialize():
	# Resolve node paths and get references
	_resolve_node_paths()
	
	# Create missing components if necessary
	_create_missing_components()
	
	# Initialize systems in correct order
	_initialize_turn_system()
	_initialize_color_system()
	_initialize_word_system()
	_initialize_ethereal_system()
	_initialize_console()
	
	# Connect signals between components
	if auto_connect_signals:
		_connect_signals()
	
	# Set default dimension
	set_dimension(default_dimension)
	
	# Mark as initialized
	initialized = true
	emit_signal("initialization_completed")
	
	# Log initialization complete
	if enable_debug_messages:
		print("PitopiaMain: Initialization complete")
		_log_message("Initialization complete. Pitopia system ready.")

func _resolve_node_paths():
	# Resolve all node paths to actual node references
	if word_manifestor_path:
		word_manifestor = get_node_or_null(word_manifestor_path)
	
	if turn_system_path:
		turn_system = get_node_or_null(turn_system_path)
	
	if ethereal_engine_path:
		ethereal_engine = get_node_or_null(ethereal_engine_path)
	
	if color_system_path:
		color_system = get_node_or_null(color_system_path)
	
	if console_path:
		console = get_node_or_null(console_path)
	
	if player_camera_path:
		player_camera = get_node_or_null(player_camera_path)
	
	if entity_container_path:
		entity_container = get_node_or_null(entity_container_path)
	
	# Log what was found
	if enable_debug_messages:
		print("PitopiaMain: Node resolution results:")
		print("- Word Manifestor: ", "Found" if word_manifestor else "Not found")
		print("- Turn System: ", "Found" if turn_system else "Not found")
		print("- Ethereal Engine: ", "Found" if ethereal_engine else "Not found")
		print("- Color System: ", "Found" if color_system else "Not found")
		print("- Console: ", "Found" if console else "Not found")
		print("- Player Camera: ", "Found" if player_camera else "Not found")
		print("- Entity Container: ", "Found" if entity_container else "Not found")

func _create_missing_components():
	# Create any critical components that are missing
	
	# Create entity container if missing
	if not entity_container:
		entity_container = Node3D.new()
		entity_container.name = "EntityContainer"
		add_child(entity_container)
		print("PitopiaMain: Created missing EntityContainer")
	
	# Create camera if missing
	if not player_camera:
		player_camera = Camera3D.new()
		player_camera.name = "PlayerCamera"
		player_camera.current = true
		player_camera.position = Vector3(0, 2, 5)
		add_child(player_camera)
		print("PitopiaMain: Created missing PlayerCamera")
	
	# Create console if missing (just basic functionality)
	if not console:
		console = Control.new()
		console.name = "BasicConsole"
		console.visible = false
		
		var panel = Panel.new()
		panel.anchor_bottom = 0.3
		panel.anchor_right = 1.0
		console.add_child(panel)
		
		var input = LineEdit.new()
		input.name = "CommandInput"
		input.anchor_bottom = 1.0
		input.anchor_right = 1.0
		input.anchor_top = 0.7
		input.placeholder_text = "Enter a word or command..."
		input.connect("text_submitted", Callable(self, "_on_console_command_entered"))
		panel.add_child(input)
		
		var output = RichTextLabel.new()
		output.name = "OutputLabel"
		output.anchor_bottom = 0.7
		output.anchor_right = 1.0
		output.bbcode_enabled = true
		panel.add_child(output)
		
		add_child(console)
		print("PitopiaMain: Created basic console")

# ----- SYSTEM INITIALIZATION -----
func _initialize_turn_system():
	if not turn_system:
		# Try to find turn system in the scene
		turn_system = get_node_or_null("/root/TurnSystem")
		
		if not turn_system and ClassDB.class_exists("TurnSystem"):
			# Create a new turn system
			turn_system = TurnSystem.new()
			turn_system.name = "TurnSystem"
			add_child(turn_system)
			print("PitopiaMain: Created TurnSystem")
		elif not turn_system and ClassDB.class_exists("TurnController"):
			# Try turn controller as fallback
			turn_system = TurnController.new()
			turn_system.name = "TurnController"
			add_child(turn_system)
			print("PitopiaMain: Created TurnController as fallback")
	
	if turn_system:
		# Configure turn system
		if turn_system.has_method("set_turn_duration"):
			turn_system.set_turn_duration(default_turn_duration)
		elif turn_system.has_property("turn_duration"):
			turn_system.turn_duration = default_turn_duration
		
		# Start turn system if applicable
		if turn_system.has_method("start_turns"):
			turn_system.start_turns()
		elif turn_system.has_method("start_turn"):
			turn_system.start_turn()
	else:
		print("PitopiaMain: WARNING - No turn system available")

func _initialize_color_system():
	if not color_system:
		# Try to find color system in the scene
		color_system = get_node_or_null("/root/DimensionalColorSystem")
		
		if not color_system and ClassDB.class_exists("DimensionalColorSystem"):
			# Create a new color system
			color_system = DimensionalColorSystem.new()
			color_system.name = "DimensionalColorSystem"
			add_child(color_system)
			print("PitopiaMain: Created DimensionalColorSystem")
	
	if color_system:
		# Configure color system if needed
		if color_system.has_method("set_dimension"):
			color_system.set_dimension(default_dimension)
	else:
		print("PitopiaMain: WARNING - No color system available")

func _initialize_word_system():
	if not word_manifestor:
		# Try to get the CoreWordManifestor singleton
		if ClassDB.class_exists("CoreWordManifestor"):
			word_manifestor = CoreWordManifestor.get_instance()
			print("PitopiaMain: Connected to CoreWordManifestor singleton")
		elif ClassDB.class_exists("JSHWordManifestor"):
			word_manifestor = JSHWordManifestor.get_instance()
			print("PitopiaMain: Connected to JSHWordManifestor singleton")
	
	if word_manifestor:
		# Initialize the word manifestor with map system (entity container) and player
		if word_manifestor.has_method("initialize"):
			word_manifestor.initialize(entity_container, player_camera)
	else:
		print("PitopiaMain: WARNING - No word manifestation system available")

func _initialize_ethereal_system():
	if not ethereal_engine:
		# Try to find ethereal engine in the scene
		ethereal_engine = get_node_or_null("/root/JshEtherealIntegration")
		
		if not ethereal_engine and ClassDB.class_exists("JshEtherealIntegration"):
			# Create a new ethereal engine
			ethereal_engine = JshEtherealIntegration.new()
			ethereal_engine.name = "JshEtherealIntegration"
			add_child(ethereal_engine)
			print("PitopiaMain: Created JshEtherealIntegration")
	
	if ethereal_engine:
		# Nothing specific to configure
		pass
	else:
		print("PitopiaMain: WARNING - No ethereal engine available")

func _initialize_console():
	if console:
		# Configure console
		is_console_visible = console.visible
		
		# Pre-populate with help info
		if console.get_node_or_null("OutputLabel"):
			var rtl = console.get_node("OutputLabel")
			rtl.text = "[color=#9988ff]Welcome to Pitopia[/color]\n"
			rtl.text += "Press [TAB] to toggle console\n"
			rtl.text += "Type [color=#88ff99]help[/color] for commands\n"
			rtl.text += "Use number keys [color=#ff8888]1-9[/color] to change dimension\n"
			rtl.text += "Current dimension: [color=#ffdd88]" + str(current_dimension) + "D[/color]\n"

func _connect_signals():
	# Connect turn system signals
	if turn_system:
		if turn_system.has_signal("turn_started") and not turn_system.is_connected("turn_started", Callable(self, "_on_turn_started")):
			turn_system.connect("turn_started", Callable(self, "_on_turn_started"))
		
		if turn_system.has_signal("turn_completed") and not turn_system.is_connected("turn_completed", Callable(self, "_on_turn_completed")):
			turn_system.connect("turn_completed", Callable(self, "_on_turn_completed"))
		
		if turn_system.has_signal("dimension_changed") and not turn_system.is_connected("dimension_changed", Callable(self, "_on_dimension_changed")):
			turn_system.connect("dimension_changed", Callable(self, "_on_dimension_changed"))
	
	# Connect word manifestor signals
	if word_manifestor:
		if word_manifestor.has_signal("word_manifested") and not word_manifestor.is_connected("word_manifested", Callable(self, "_on_word_manifested")):
			word_manifestor.connect("word_manifested", Callable(self, "_on_word_manifested"))
		
		if word_manifestor.has_signal("word_combination_created") and not word_manifestor.is_connected("word_combination_created", Callable(self, "_on_word_combination_created")):
			word_manifestor.connect("word_combination_created", Callable(self, "_on_word_combination_created"))
		
		if word_manifestor.has_signal("word_relationship_created") and not word_manifestor.is_connected("word_relationship_created", Callable(self, "_on_word_relationship_created")):
			word_manifestor.connect("word_relationship_created", Callable(self, "_on_word_relationship_created"))

# ----- TURN & DIMENSION MANAGEMENT -----
func set_dimension(dimension: int):
	var old_dimension = current_dimension
	current_dimension = dimension
	
	# Update turn system if available
	if turn_system:
		if turn_system.has_method("set_dimension"):
			turn_system.set_dimension(dimension)
	
	# Update color system if available
	if color_system:
		if color_system.has_method("set_dimension"):
			color_system.set_dimension(dimension)
		elif color_system.has_method("update_dimension"):
			color_system.update_dimension(dimension)
	
	# Apply dimension effects to entities
	_apply_dimension_to_entities(dimension)
	
	# Create dimension transition effect
	_create_dimension_transition_effect(old_dimension, dimension)
	
	# Record in history
	dimension_history.append({
		"timestamp": Time.get_unix_time_from_system(),
		"old_dimension": old_dimension,
		"new_dimension": dimension
	})
	
	# Emit signal
	emit_signal("dimension_changed", dimension, old_dimension)
	
	# Update console display
	_update_console_dimension_display()
	
	if enable_debug_messages:
		print("PitopiaMain: Dimension changed from " + str(old_dimension) + "D to " + str(dimension) + "D")

func advance_turn():
	if turn_system:
		if turn_system.has_method("advance_turn"):
			turn_system.advance_turn()
		elif turn_system.has_method("end_turn"):
			turn_system.end_turn()
	else:
		# Simple turn advancement
		current_turn += 1
		emit_signal("turn_advanced", current_turn)
		
		if enable_debug_messages:
			print("PitopiaMain: Advanced to turn " + str(current_turn))

func get_dimension_name(dimension: int = -1) -> String:
	if dimension < 0:
		dimension = current_dimension
	
	if turn_system and turn_system.has_method("get_dimension_name"):
		return turn_system.get_dimension_name()
	
	# Default dimension names
	var dimension_names = [
		"Linear Expression",      # 1D
		"Planar Reflection",      # 2D
		"Spatial Manifestation",  # 3D
		"Temporal Flow",          # 4D
		"Probability Waves",      # 5D
		"Phase Resonance",        # 6D
		"Dream Weaving",          # 7D
		"Interconnection",        # 8D
		"Divine Judgment",        # 9D
		"Harmonic Convergence",   # 10D
		"Conscious Reflection",   # 11D
		"Divine Manifestation"    # 12D
	]
	
	if dimension >= 1 and dimension <= dimension_names.size():
		return dimension_names[dimension - 1]
	
	return "Unknown Dimension"

# ----- WORD MANIFESTATION -----
func manifest_word(word: String) -> Object:
	if not word_manifestor:
		print("PitopiaMain: Cannot manifest word - no word manifestor available")
		return null
	
	# Generate position based on camera or defaults
	var position = _get_spawn_position()
	
	# Use word manifestor to create entity
	var entity = word_manifestor.manifest_word(word, position)
	
	if entity:
		# Add to tracking
		manifested_words.append(word)
		manifested_entities[word] = entity
		
		# Apply current dimension properties
		_apply_dimension_to_entity(entity, current_dimension)
		
		if enable_debug_messages:
			print("PitopiaMain: Manifested word '" + word + "'")
	
	return entity

func combine_words(words: Array) -> Object:
	if not word_manifestor:
		print("PitopiaMain: Cannot combine words - no word manifestor available")
		return null
	
	# Generate position based on camera or defaults
	var position = _get_spawn_position()
	
	# Use word manifestor to combine words
	var entity = word_manifestor.combine_words(words, position)
	
	if entity:
		# Get combined word if possible
		var combined_word = ""
		if entity.has_property("source_word"):
			combined_word = entity.source_word
		else:
			combined_word = "_".join(words)
		
		# Add to tracking
		manifested_words.append(combined_word)
		manifested_entities[combined_word] = entity
		
		# Apply current dimension properties
		_apply_dimension_to_entity(entity, current_dimension)
		
		if enable_debug_messages:
			print("PitopiaMain: Combined words into '" + combined_word + "'")
	
	return entity

func process_command(command: String) -> Dictionary:
	if not word_manifestor:
		_log_message("Cannot process command - no word manifestor available")
		return {"success": false, "message": "No word manifestor available"}
	
	# Process command through word manifestor
	var result = word_manifestor.process_command(command)
	
	# Apply dimension properties to any created entity
	if result.success and result.entity:
		_apply_dimension_to_entity(result.entity, current_dimension)
	
	# Log result to console
	_log_message(result.message)
	
	return result

func _get_spawn_position() -> Vector3:
	var position = Vector3.ZERO
	
	if player_camera:
		var forward = -player_camera.global_transform.basis.z
		position = player_camera.global_position + forward * 3.0
		
		# Add dimension-based randomness
		var dimension_factor = current_dimension * 0.1
		position += Vector3(
			randf_range(-1.0, 1.0) * dimension_factor,
			randf_range(-0.5, 1.5) * dimension_factor,
			randf_range(-0.5, 0.5) * dimension_factor
		)
	
	return position

func toggle_console():
	if console:
		is_console_visible = !is_console_visible
		console.visible = is_console_visible
		
		# Focus the input field if visible
		if is_console_visible:
			var input = console.get_node_or_null("CommandInput")
			if input:
				input.grab_focus()

# ----- DIMENSION EFFECTS -----
func _apply_dimension_to_entities(dimension: int):
	# Apply dimension properties to all manifested entities
	for word in manifested_entities:
		var entity = manifested_entities[word]
		if entity and is_instance_valid(entity):
			_apply_dimension_to_entity(entity, dimension)

func _apply_dimension_to_entity(entity, dimension: int):
	# Apply dimension-specific properties to an entity
	if entity.has_method("set_property"):
		entity.set_property("dimension", dimension)
		
		# Set dimensionality property
		match dimension:
			1: entity.set_property("dimensionality", "linear")
			2: entity.set_property("dimensionality", "planar")
			3: entity.set_property("dimensionality", "spatial")
			4: entity.set_property("dimensionality", "temporal")
			5: entity.set_property("dimensionality", "probabilistic")
			6: entity.set_property("dimensionality", "resonant")
			7: entity.set_property("dimensionality", "dreamlike")
			8: entity.set_property("dimensionality", "connected")
			9: entity.set_property("dimensionality", "judged")
			10: entity.set_property("dimensionality", "harmonic")
			11: entity.set_property("dimensionality", "conscious")
			12: entity.set_property("dimensionality", "divine")
	
	# Apply visual effects based on dimension
	if entity is Node3D:
		# Scale adjustment based on dimension
		var scale_factor = 1.0 + ((dimension - 3) * 0.1) if dimension >= 3 else max(0.2, dimension * 0.3)
		entity.scale = Vector3(scale_factor, scale_factor, scale_factor)
		
		# For 4D+ add temporal effects
		if dimension >= 4:
			# Add animation player if needed
			var anim_player = entity.get_node_or_null("AnimationPlayer")
			if not anim_player:
				anim_player = AnimationPlayer.new()
				anim_player.name = "AnimationPlayer"
				entity.add_child(anim_player)
				
				# Create simple animation
				var animation = Animation.new()
				var track_idx = animation.add_track(Animation.TYPE_VALUE)
				animation.track_set_path(track_idx, ":position")
				animation.track_insert_key(track_idx, 0.0, Vector3.ZERO)
				animation.track_insert_key(track_idx, 1.0, Vector3(0, 0.5, 0) * (dimension - 3) * 0.2)
				animation.track_insert_key(track_idx, 2.0, Vector3.ZERO)
				animation.loop_mode = Animation.LOOP_LINEAR
				
				# Add to animation player
				anim_player.add_animation("temporal_flow", animation)
				anim_player.play("temporal_flow")
		
		# Add glow effect for higher dimensions
		if dimension >= 7:
			# Find mesh instance
			var mesh_instance = entity
			if not mesh_instance is MeshInstance3D:
				mesh_instance = entity.get_node_or_null("MeshInstance3D")
			
			if mesh_instance and mesh_instance is MeshInstance3D:
				# Create or get material
				var material = mesh_instance.get_surface_override_material(0)
				if material is StandardMaterial3D:
					material.emission_enabled = true
					material.emission = Color(0.5, 0.5, 1.0)
					material.emission_energy = 0.5 + (dimension - 7) * 0.2
				elif not material:
					# Create new material
					material = StandardMaterial3D.new()
					material.emission_enabled = true
					material.emission = Color(0.5, 0.5, 1.0)
					material.emission_energy = 0.5 + (dimension - 7) * 0.2
					mesh_instance.set_surface_override_material(0, material)

func _create_dimension_transition_effect(old_dimension: int, new_dimension: int):
	# Create visual effect for dimension transition
	if dimension_particle_effect_scene:
		var effect = dimension_particle_effect_scene.instantiate()
		add_child(effect)
		
		# Position at camera or center
		if player_camera:
			effect.global_position = player_camera.global_position
		
		# Set properties based on dimensions
		if effect.has_method("set_transition_dimensions"):
			effect.set_transition_dimensions(old_dimension, new_dimension)
		
		# Auto-remove after effect completes
		var timer = Timer.new()
		timer.wait_time = 2.0
		timer.one_shot = true
		timer.connect("timeout", Callable(effect, "queue_free"))
		effect.add_child(timer)
		timer.start()

# ----- UI UPDATES -----
func _log_message(message: String):
	# Log message to console output if available
	if console:
		var output = console.get_node_or_null("OutputLabel")
		if output and output is RichTextLabel:
			output.text += message + "\n"
			
			# Scroll to bottom
			output.scroll_to_line(output.get_line_count() - 1)

func _update_console_dimension_display():
	# Update dimension info in console
	if console:
		var output = console.get_node_or_null("OutputLabel")
		if output and output is RichTextLabel:
			output.text += "[color=#ffdd88]Dimension changed to: " + str(current_dimension) + "D - " + get_dimension_name() + "[/color]\n"
			
			# Scroll to bottom
			output.scroll_to_line(output.get_line_count() - 1)

# ----- SIGNAL HANDLERS -----
func _on_console_command_entered(text: String):
	if text.strip_edges().is_empty():
		return
	
	# Echo command to console
	_log_message("[color=#aaaaaa]> " + text + "[/color]")
	
	# Check for built-in commands
	if text.begins_with("dim ") or text.begins_with("dimension "):
		var parts = text.split(" ")
		if parts.size() >= 2:
			var dim = int(parts[1])
			if dim >= 1 and dim <= 12:
				set_dimension(dim)
				return
	
	if text == "help":
		_log_message("[color=#88ff99]Available commands:[/color]")
		_log_message("- create [word] - Create an entity")
		_log_message("- combine [word1] [word2] ... - Combine words")
		_log_message("- transform [word] to [form] - Transform entity")
		_log_message("- connect [word1] to [word2] - Connect entities")
		_log_message("- dimension [1-12] - Change dimension")
		_log_message("- turn - Advance to next turn")
		return
	
	if text == "turn":
		advance_turn()
		return
	
	# Process command through word manifestor
	if enable_creation_on_words:
		process_command(text)

func _on_turn_started(turn_number):
	current_turn = turn_number
	emit_signal("turn_advanced", turn_number)
	
	if enable_debug_messages:
		print("PitopiaMain: Turn " + str(turn_number) + " started")
	
	_log_message("Turn " + str(turn_number) + " started")

func _on_turn_completed(turn_number):
	if enable_debug_messages:
		print("PitopiaMain: Turn " + str(turn_number) + " completed")
	
	_log_message("Turn " + str(turn_number) + " completed")

func _on_dimension_changed(new_dimension, old_dimension = 0):
	current_dimension = new_dimension
	
	if enable_debug_messages:
		print("PitopiaMain: Dimension changed to " + str(new_dimension) + "D")
	
	_update_console_dimension_display()

func _on_word_manifested(word, entity):
	emit_signal("word_manifested", word, entity)
	
	# Track entity
	if not manifested_entities.has(word):
		manifested_entities[word] = entity
		manifested_words.append(word)
	
	if enable_debug_messages:
		print("PitopiaMain: Word '" + word + "' manifested")

func _on_word_combination_created(words, result):
	_log_message("Combined words " + str(words) + " into " + result)

func _on_word_relationship_created(word1, word2, relationship_type):
	_log_message("Created " + relationship_type + " relationship: " + word1 + " → " + word2)
	
	# If entities exist, try to visualize the connection
	if manifested_entities.has(word1) and manifested_entities.has(word2):
		var entity1 = manifested_entities[word1]
		var entity2 = manifested_entities[word2]
		
		if entity1 and entity2 and entity1 is Node3D and entity2 is Node3D:
			# Create visual connection between entities
			var connection = _create_entity_connection(entity1, entity2, relationship_type)
			emit_signal("entity_connected", entity1, entity2, relationship_type)

func _create_entity_connection(entity1, entity2, connection_type):
	# Create visual connection between entities
	var connection = Line2D.new()
	connection.name = "Connection_" + connection_type
	connection.width = 2.0
	
	# Set color based on connection type
	match connection_type:
		"sequence": connection.default_color = Color(0.2, 0.6, 1.0)
		"evolution": connection.default_color = Color(0.8, 0.4, 1.0)
		"transformation": connection.default_color = Color(1.0, 0.6, 0.2)
		"opposition": connection.default_color = Color(1.0, 0.2, 0.2)
		"harmony": connection.default_color = Color(0.2, 1.0, 0.4)
		_: connection.default_color = Color(0.7, 0.7, 0.7)
	
	# Add points
	connection.add_point(entity1.global_position)
	connection.add_point(entity2.global_position)
	
	# Make it update continuously
	var script = GDScript.new()
	script.source_code = """
	extends Line2D
	
	@export var entity1_path: NodePath
	@export var entity2_path: NodePath
	
	func _process(delta):
		var entity1 = get_node_or_null(entity1_path)
		var entity2 = get_node_or_null(entity2_path)
		
		if entity1 and entity2:
			set_point_position(0, entity1.global_position)
			set_point_position(1, entity2.global_position)
		else:
			queue_free() # Remove if either entity is gone
	"""
	script.reload()
	connection.set_script(script)
	
	# Set entity paths
	connection.entity1_path = entity1.get_path()
	connection.entity2_path = entity2.get_path()
	
	# Add to scene
	entity_container.add_child(connection)
	return connection

# ----- INPUT HANDLING -----
func _input(event):
	# Handle keyboard input
	if event is InputEventKey and event.pressed:
		# Number keys 1-9 (and 0, -, =) for dimensions 1-12
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var dimension = event.keycode - KEY_0
			set_dimension(dimension)
		elif event.keycode == KEY_0:
			set_dimension(10)
		elif event.keycode == KEY_MINUS:
			set_dimension(11)
		elif event.keycode == KEY_EQUAL:
			set_dimension(12)
		
		# Tab for console
		elif event.keycode == KEY_TAB:
			toggle_console()
		
		# Space for advancing turn
		elif event.keycode == KEY_SPACE and not is_console_visible:
			advance_turn()
		
		# Camera movement using WASD
		var camera_speed = 0.3
		if not is_console_visible:
			if event.keycode == KEY_W:
				player_camera.global_position += -player_camera.global_transform.basis.z * camera_speed
			elif event.keycode == KEY_S:
				player_camera.global_position += player_camera.global_transform.basis.z * camera_speed
			elif event.keycode == KEY_A:
				player_camera.global_position += -player_camera.global_transform.basis.x * camera_speed
			elif event.keycode == KEY_D:
				player_camera.global_position += player_camera.global_transform.basis.x * camera_speed
			elif event.keycode == KEY_Q:
				player_camera.global_position += player_camera.global_transform.basis.y * camera_speed
			elif event.keycode == KEY_E:
				player_camera.global_position += -player_camera.global_transform.basis.y * camera_speed
			elif event.keycode == KEY_R:
				player_camera.look_at(Vector3.ZERO)

# ----- PHYSICS PROCESS -----
func _physics_process(delta):
	if not initialized or not enable_automatic_dimension_effects:
		return
	
	# Apply dimension-specific continuous effects
	if current_dimension >= 4:
		_process_temporal_effects(delta)
	
	if current_dimension >= 7:
		_process_dream_weaving_effects(delta)
	
	if current_dimension >= 10:
		_process_harmonic_effects(delta)

func _process_temporal_effects(delta):
	# 4D+ temporal effects
	var time = Time.get_ticks_msec() / 1000.0
	var temporal_factor = (current_dimension - 3) * 0.02
	
	for word in manifested_entities:
		var entity = manifested_entities[word]
		if entity and is_instance_valid(entity) and entity is Node3D:
			# Apply subtle position offset based on time
			var original_pos = word_positions.get(word, entity.global_position)
			var offset = Vector3(
				sin(time + entity.get_instance_id() * 0.1) * temporal_factor,
				cos(time * 0.7 + entity.get_instance_id() * 0.05) * temporal_factor,
				sin(time * 0.5 + entity.get_instance_id() * 0.15) * temporal_factor
			)
			
			entity.global_position = entity.global_position.lerp(original_pos + offset, delta * 2.0)

func _process_dream_weaving_effects(delta):
	# 7D+ dream weaving effects - color/emission changes
	var time = Time.get_ticks_msec() / 1000.0
	var dream_factor = (current_dimension - 6) * 0.05
	
	for word in manifested_entities:
		var entity = manifested_entities[word]
		if entity and is_instance_valid(entity):
			var mesh_instance = entity
			if not mesh_instance is MeshInstance3D:
				mesh_instance = entity.get_node_or_null("MeshInstance3D")
			
			if mesh_instance and mesh_instance is MeshInstance3D:
				var material = mesh_instance.get_surface_override_material(0)
				if material is StandardMaterial3D and material.emission_enabled:
					# Pulse emission based on time
					var pulse = (sin(time + entity.get_instance_id() * 0.1) * 0.5 + 0.5) * dream_factor
					material.emission_energy = 0.5 + pulse
					
					# Shift emission color slightly
					var hue_shift = fmod(time * 0.05 + entity.get_instance_id() * 0.01, 1.0)
					material.emission = Color.from_hsv(hue_shift, 0.7, 1.0)

func _process_harmonic_effects(delta):
	# 10D+ harmonic effects - entities affecting each other
	var harmonic_factor = (current_dimension - 9) * 0.02
	
	# Group entities by proximity
	var proximity_groups = {}
	var group_id = 0
	
	for word1 in manifested_entities:
		var entity1 = manifested_entities[word1]
		if not entity1 or not is_instance_valid(entity1) or not entity1 is Node3D:
			continue
			
		var found_group = false
		
		for group in proximity_groups:
			for word2 in proximity_groups[group]:
				var entity2 = manifested_entities[word2]
				if entity1.global_position.distance_to(entity2.global_position) < 2.0:
					proximity_groups[group].append(word1)
					found_group = true
					break
			
			if found_group:
				break
		
		if not found_group:
			group_id += 1
			proximity_groups[group_id] = [word1]
	
	# Apply harmonic effects to each group
	for group in proximity_groups:
		var words = proximity_groups[group]
		if words.size() < 2:
			continue
		
		# Create harmonic center
		var center = Vector3.ZERO
		for word in words:
			var entity = manifested_entities[word]
			center += entity.global_position
		center /= words.size()
		
		# Apply orbital effect
		var time = Time.get_ticks_msec() / 1000.0
		for i in range(words.size()):
			var word = words[i]
			var entity = manifested_entities[word]
			var orbit_radius = 1.0 + (i * 0.2)
			var orbit_speed = 0.5 + (i * 0.1)
			var phase = (2 * PI / words.size()) * i
			
			var orbit_pos = center + Vector3(
				cos(time * orbit_speed + phase) * orbit_radius * harmonic_factor,
				sin(time * orbit_speed * 0.7 + phase) * orbit_radius * harmonic_factor * 0.5,
				sin(time * orbit_speed * 0.3 + phase) * orbit_radius * harmonic_factor
			)
			
			entity.global_position = entity.global_position.lerp(orbit_pos, delta)
			
			# Entities in harmonics look at center
			entity.look_at(center)