extends Node3D

class_name EdenHarmonyMain

# ----- REFERENCES TO COMPONENTS -----
var harmony_connector = null
var console = null
var camera = null
var ui = null
var word_display = null

# ----- PRELOADS -----
var connector_scene = preload("res://eden_harmony_connector.tscn")
var console_scene = preload("res://creation_console.tscn")
var word_display_scene = preload("res://word_display.tscn")

# ----- STATE VARIABLES -----
var is_initialized = false
var current_dimension = 3
var system_ready = false
var recent_words = []
var word_positions = {}
var word_entities = {}

# ----- SIGNALS -----
signal system_ready
signal dimension_changed(dimension)
signal word_manifested(word, entity)

# ----- INITIALIZATION -----
func _ready():
	print("Eden Harmony Main initializing...")
	
	# Create harmony connector
	_initialize_connector()
	
	# Create console for word input
	_initialize_console()
	
	# Create word display system
	_initialize_word_display()
	
	# Setup camera
	_initialize_camera()
	
	# Setup UI
	_initialize_ui()
	
	# Register input handling
	_setup_input_handling()
	
	# Perform initialization after a short delay to ensure all systems are ready
	await get_tree().create_timer(0.5).timeout
	
	# Mark system as ready
	system_ready = true
	emit_signal("system_ready")
	
	print("Eden Harmony Main initialized")
	
	# Display welcome message
	_show_welcome_message()

func _initialize_connector():
	# First check if connector already exists in the scene
	harmony_connector = get_node_or_null("EdenHarmonyConnector")
	
	if not harmony_connector:
		# Try to find connector elsewhere in the scene
		harmony_connector = get_node_or_null("/root/EdenHarmonyConnector")
	
	if not harmony_connector:
		# Instantiate connector
		harmony_connector = EdenHarmonyConnector.new()
		harmony_connector.name = "EdenHarmonyConnector"
		add_child(harmony_connector)
	
	# Connect signals
	harmony_connector.connect("initialization_complete", Callable(self, "_on_connector_initialized"))
	harmony_connector.connect("dimension_changed", Callable(self, "_on_dimension_changed"))
	harmony_connector.connect("word_manifested", Callable(self, "_on_word_manifested"))
	
	print("Harmony connector initialized")

func _initialize_console():
	# First check if console already exists in the scene
	console = get_node_or_null("CreationConsole")
	
	if not console:
		# Try to find console elsewhere in the scene
		console = get_node_or_null("/root/CreationConsole")
	
	if not console:
		# Check if scene is available
		if console_scene:
			console = console_scene.instantiate()
			console.name = "CreationConsole"
			add_child(console)
			
			# Connect console signals
			if console.has_signal("command_entered"):
				console.connect("command_entered", Callable(self, "_on_command_entered"))
			
			print("Console created from scene")
		else:
			# Create a basic console
			console = Control.new()
			console.name = "CreationConsole"
			add_child(console)
			print("Basic console created")
	
	print("Console initialized")

func _initialize_word_display():
	# Check if word display already exists in the scene
	word_display = get_node_or_null("WordDisplay")
	
	if not word_display:
		# Try to find word display elsewhere in the scene
		word_display = get_node_or_null("/root/WordDisplay")
	
	if not word_display:
		# Check if scene is available
		if word_display_scene:
			word_display = word_display_scene.instantiate()
			word_display.name = "WordDisplay"
			add_child(word_display)
			print("Word display created from scene")
		else:
			# Create a basic word display
			word_display = Node3D.new()
			word_display.name = "WordDisplay"
			add_child(word_display)
			print("Basic word display created")
	
	print("Word display initialized")

func _initialize_camera():
	# Find or create camera
	camera = get_node_or_null("Camera3D")
	
	if not camera:
		# Create a camera
		camera = Camera3D.new()
		camera.name = "Camera3D"
		camera.current = true
		camera.global_position = Vector3(0, 2, 5)  # Position the camera
		camera.look_at(Vector3.ZERO)
		add_child(camera)
	
	print("Camera initialized")

func _initialize_ui():
	# Setup UI elements
	ui = get_node_or_null("UI")
	
	if not ui:
		# Create UI container
		ui = Control.new()
		ui.name = "UI"
		ui.set_anchors_preset(Control.PRESET_FULL_RECT)
		add_child(ui)
		
		# Create dimension indicator
		var dimension_label = Label.new()
		dimension_label.name = "DimensionLabel"
		dimension_label.text = "Dimension: 3D - Spatial Manifestation"
		dimension_label.position = Vector2(20, 20)
		ui.add_child(dimension_label)
		
		# Create word count indicator
		var word_count_label = Label.new()
		word_count_label.name = "WordCountLabel"
		word_count_label.text = "Words Manifested: 0"
		word_count_label.position = Vector2(20, 50)
		ui.add_child(word_count_label)
		
		# Create help indicator
		var help_label = Label.new()
		help_label.name = "HelpLabel"
		help_label.text = "Press Tab for console | 1-9 to change dimension"
		help_label.position = Vector2(20, 80)
		ui.add_child(help_label)
	
	print("UI initialized")

func _setup_input_handling():
	# Check for existing input map action for console toggle
	if not InputMap.has_action("toggle_console"):
		# Create action for console toggle
		InputMap.add_action("toggle_console")
		
		# Add Tab key to the action
		var event = InputEventKey.new()
		event.keycode = KEY_TAB
		InputMap.action_add_event("toggle_console", event)
	
	print("Input handling set up")

func _show_welcome_message():
	# Show welcome message in console
	if console and console.has_method("add_message"):
		console.add_message("Welcome to Eden Harmony - A world of word manifestation!")
		console.add_message("Current dimension: " + str(current_dimension) + "D - " + harmony_connector.get_dimension_name())
		console.add_message("Use the console to manifest words into reality")
		console.add_message("Type 'help' for available commands")

# ----- WORD MANIFESTATION -----
func manifest_word(word: String):
	if not harmony_connector:
		return null
	
	# Generate position in front of camera
	var spawn_position = _get_spawn_position()
	
	# Use harmony connector to manifest the word
	var entity = harmony_connector.manifest_word(word, spawn_position)
	
	# Track the word
	if entity:
		recent_words.append(word)
		word_positions[word] = spawn_position
		word_entities[word] = entity
		
		# Update UI
		_update_word_count_display()
	
	return entity

func _get_spawn_position() -> Vector3:
	# Generate a position in front of the camera
	var spawn_position = Vector3.ZERO
	
	if camera:
		var forward = -camera.global_transform.basis.z
		spawn_position = camera.global_position + forward * 3.0
		
		# Add some randomness based on dimension
		var dimension_factor = current_dimension * 0.1
		spawn_position += Vector3(
			randf_range(-1.0, 1.0) * dimension_factor,
			randf_range(-0.5, 1.5) * dimension_factor,
			randf_range(-0.5, 0.5) * dimension_factor
		)
	
	return spawn_position

func process_command(command: String):
	if not harmony_connector:
		return
	
	var result = harmony_connector.process_command(command)
	
	if console and console.has_method("add_message"):
		console.add_message(result.message)
	
	if result.success and result.entity:
		# Update UI
		_update_word_count_display()

# ----- UI UPDATES -----
func _update_dimension_display():
	# Update dimension indicator
	var dimension_label = ui.get_node_or_null("DimensionLabel")
	if dimension_label:
		dimension_label.text = "Dimension: " + str(current_dimension) + "D - " + harmony_connector.get_dimension_name()

func _update_word_count_display():
	# Update word count indicator
	var word_count_label = ui.get_node_or_null("WordCountLabel")
	if word_count_label:
		var count = harmony_connector.get_manifested_word_count()
		word_count_label.text = "Words Manifested: " + str(count)

# ----- SIGNAL HANDLERS -----
func _on_connector_initialized():
	print("Harmony connector initialization complete")
	current_dimension = harmony_connector.get_current_dimension()
	_update_dimension_display()

func _on_dimension_changed(new_dimension):
	current_dimension = new_dimension
	_update_dimension_display()
	
	# Notify any connected systems
	emit_signal("dimension_changed", new_dimension)
	
	# Update visuals of all manifested entities
	_update_manifested_entities_dimension(new_dimension)
	
	if console and console.has_method("add_message"):
		console.add_message("Dimension changed to: " + str(new_dimension) + "D - " + harmony_connector.get_dimension_name())

func _on_word_manifested(word, entity, dimension):
	# Notify any connected systems
	emit_signal("word_manifested", word, entity)
	
	# Update UI
	_update_word_count_display()
	
	if console and console.has_method("add_message"):
		console.add_message("Manifested: " + word + " in dimension " + str(dimension) + "D")

func _on_command_entered(command):
	process_command(command)

func _update_manifested_entities_dimension(dimension):
	# Update all manifested entities with new dimension properties
	for word in word_entities:
		var entity = word_entities[word]
		if entity and is_instance_valid(entity):
			if entity.has_method("set_property"):
				entity.set_property("dimension", dimension)
				
				# Adjust visual appearance based on dimension
				if entity is Node3D:
					var scale_factor = 1.0 + (dimension * 0.05)
					entity.scale = Vector3(scale_factor, scale_factor, scale_factor)
					
					# Apply special effects for higher dimensions
					if dimension > 3:
						var material_override = entity.get_node_or_null("MeshInstance3D/MaterialOverride")
						if material_override:
							material_override.set_shader_parameter("dimension", dimension)

# ----- INPUT HANDLING -----
func _input(event):
	# Handle camera movement
	if event is InputEventKey:
		if event.pressed:
			var camera_speed = 0.3
			
			if event.keycode == KEY_W:
				camera.global_position += -camera.global_transform.basis.z * camera_speed
			elif event.keycode == KEY_S:
				camera.global_position += camera.global_transform.basis.z * camera_speed
			elif event.keycode == KEY_A:
				camera.global_position += -camera.global_transform.basis.x * camera_speed
			elif event.keycode == KEY_D:
				camera.global_position += camera.global_transform.basis.x * camera_speed
			elif event.keycode == KEY_Q:
				camera.global_position += camera.global_transform.basis.y * camera_speed
			elif event.keycode == KEY_E:
				camera.global_position += -camera.global_transform.basis.y * camera_speed
			
			# Look at center if R pressed
			elif event.keycode == KEY_R:
				camera.look_at(Vector3.ZERO)

# ----- PHYSICS PROCESS -----
func _physics_process(delta):
	# Process any continuous effects
	if system_ready:
		_process_dimensional_effects(delta)

func _process_dimensional_effects(delta):
	# Apply dimension-specific effects to the scene
	
	# 4D and above: Temporal effects (subtle movement)
	if current_dimension >= 4:
		var time_factor = Time.get_ticks_msec() / 1000.0
		var dimension_intensity = (current_dimension - 3) * 0.05
		
		# Apply to all manifested entities
		for word in word_entities:
			var entity = word_entities[word]
			if entity and is_instance_valid(entity) and entity is Node3D:
				var base_position = word_positions.get(word, Vector3.ZERO)
				var offset = Vector3(
					sin(time_factor + entity.get_instance_id() * 0.1) * dimension_intensity,
					cos(time_factor * 0.7 + entity.get_instance_id() * 0.05) * dimension_intensity,
					sin(time_factor * 0.5 + entity.get_instance_id() * 0.15) * dimension_intensity
				)
				
				# Smooth interpolation to new position
				entity.global_position = entity.global_position.lerp(base_position + offset, delta * 2.0)
	
	# 7D and above: Color/visual pulsing effects
	if current_dimension >= 7:
		var time_factor = Time.get_ticks_msec() / 1000.0
		var pulse_factor = (sin(time_factor) * 0.5 + 0.5) * ((current_dimension - 6) * 0.1)
		
		# Apply to all manifested entities
		for word in word_entities:
			var entity = word_entities[word]
			if entity and is_instance_valid(entity):
				var mesh = entity.get_node_or_null("MeshInstance3D")
				if mesh and mesh.get_surface_override_material(0):
					var material = mesh.get_surface_override_material(0)
					if material is StandardMaterial3D:
						material.emission_energy = pulse_factor
					elif material.has_method("set_shader_parameter"):
						material.set_shader_parameter("pulse_factor", pulse_factor)
	
	# 10D and above: Reality-bending effects
	if current_dimension >= 10:
		var time_factor = Time.get_ticks_msec() / 1000.0
		var reality_factor = (current_dimension - 9) * 0.05
		
		# Apply global post-processing effects
		var environment = get_node_or_null("WorldEnvironment")
		if environment and environment.environment:
			var env = environment.environment
			env.adjustment_brightness = 1.0 + sin(time_factor * 0.3) * reality_factor * 0.1
			env.adjustment_saturation = 1.0 + sin(time_factor * 0.5) * reality_factor * 0.2