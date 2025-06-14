extends Node3D

# This is the main script that ties everything together
# Attach this to your main scene Node3D

# References to our core systems
var snake_core: Node3D
var snake_animator: Node3D  
var grid_system: GridSystem

# Bank references
var records_bank: RecordsBank
var scenes_bank: ScenesBank
var actions_bank: ActionsBank
var instructions_bank: InstructionsBank
var settings_bank: SettingsBank
var banks_combiner: BanksCombiner

# UI elements
var debug_label: Label
var fps_counter: Label

# Game state
var game_running = false
var loading_complete = false
var debug_mode = true

func _ready():
	# Initialize globals first
	#Globals.initialize()
	
	# Setup UI
	setup_ui()
	
	# Wait for models to be ready before continuing
	#if not Globals.segment_model or not Globals.head_model:
	#	debug_print("Waiting for models to load...")
	#	await Globals.model_loader.models_ready
	
	# Initialize the game systems
	initialize_game_systems()
	
	# Connect signals
	connect_signals()
	
	# Start game loop
	game_running = true
	debug_print("Game initialized and ready to run")

func setup_ui():
	# Create debug UI
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	
	# Debug label for displaying messages
	debug_label = Label.new()
	debug_label.position = Vector2(10, 10)
	debug_label.text = "Initializing..."
	canvas_layer.add_child(debug_label)
	
	# FPS counter
	fps_counter = Label.new()
	fps_counter.position = Vector2(10, 40)
	canvas_layer.add_child(fps_counter)
	
	if not debug_mode:
		debug_label.visible = false
		fps_counter.visible = false

func initialize_game_systems():
	debug_print("Initializing game systems...")
	
	# Initialize settings
	initialize_settings()
	
	# Initialize the Grid System
	grid_system# = GridSystem.new(Globals.get_setting("grid_resolution"), Globals.get_setting("cell_size"))
	add_child(grid_system)
	
	# Initialize the Snake Core
	snake_core# = preload("res://space-snake-core.gd").new()
	add_child(snake_core)
	
	# Initialize the Snake Animator
	var animator_script = load("res://space-snake-animation.gd")
	snake_animator = animator_script.new()
	add_child(snake_animator)
	
	# Initialize Banks
	initialize_banks()
	
	# Setup camera
	setup_camera()
	
	loading_complete = true
	debug_print("Game systems initialized")

func initialize_settings():
	debug_print("Loading settings...")
	
	# Try to load settings file
	var settings_file_path = "user://settings.txt"
	var loaded = SettingsBank.load_settings_file(settings_file_path)
	
	if not loaded:
		debug_print("Settings file not found, creating default settings")
		SettingsBank.path_to_main_directory = "user://"
		SettingsBank.path_to_settings_file = "user://"
		SettingsBank.settings_file_name = "settings.txt"
		SettingsBank.last_created_thing_number = 0
		SettingsBank.available_directory = "user://data"
		SettingsBank.save_settings_file(settings_file_path)
	
	# Apply settings to globals
	#Globals.set_setting("grid_resolution", 32)
	#Globals.set_setting("cell_size", 1.0)
	#Globals.set_setting("game_speed", 0.2)
	
	debug_print("Settings loaded")

func initialize_banks():
	debug_print("Initializing data banks...")
	
	# Create the bank instances
	records_bank = RecordsBank.new()
	scenes_bank = ScenesBank.new()
	actions_bank = ActionsBank.new()
	instructions_bank = InstructionsBank.new()
	settings_bank = SettingsBank.new()
	banks_combiner = BanksCombiner.new()
	
	# Additional setup for banks if needed
	
	debug_print("Data banks initialized")

func setup_camera():
	# Create a camera
	var camera = Camera3D.new()
	var camera_pivot = Node3D.new()
	
	camera_pivot.name = "CameraPivot"
	camera.name = "Camera"
	
	# Position the camera
	camera.position = Vector3(0, 10, 15)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	
	# Add camera to scene
	camera_pivot.add_child(camera)
	add_child(camera_pivot)

func connect_signals():
	# Connect any necessary signals between systems
	pass

func _process(delta):
	if not game_running or not loading_complete:
		return
	
	# Update FPS counter
	if debug_mode:
		fps_counter.text = "FPS: " + str(Engine.get_frames_per_second())
	
	# Handle game state and updates
	process_game_state(delta)

func process_game_state(delta):
	# Any global game state processing here
	pass

func debug_print(message):
	if debug_mode:
		print(message)
		if debug_label:
			debug_label.text = message

# Handle player requests to "god" (the command system)
func request_to_god(command):
	debug_print("Command received: " + command)
	
	var parts = command.split(" ")
	
	if parts.size() > 0:
		match parts[0]:
			"debug":
				toggle_debug()
				return "Debug mode toggled"
			"speed":
				if parts.size() > 1:
					var new_speed = float(parts[1])
					#Globals.set_setting("game_speed", new_speed)
					return "Game speed set to " + parts[1]
			"reset":
				reset_game()
				return "Game reset"
			# Add more commands as needed
	
	# If command wasn't handled here, try passing it to snake_core
	if snake_core and snake_core.has_method("request_to_god"):
		return snake_core.request_to_god(command)
	
	return "Unknown command: " + command

func toggle_debug():
	debug_mode = !debug_mode
	
	if debug_label:
		debug_label.visible = debug_mode
	
	if fps_counter:
		fps_counter.visible = debug_mode

func reset_game():
	# Reset the game state
	if snake_core:
		remove_child(snake_core)
		snake_core.queue_free()
		
		# Create a new snake core
		snake_core# 
		#= preload("res://space-snake-core.gd").new()
		add_child(snake_core)
	
	debug_print("Game reset")
