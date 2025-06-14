extends Node

# VR Integration for Eden Space Game
# This script handles the integration of VR functionality into the main game

# References
var main_node = null
var vr_manager = null
var akashic_records = null
var universe_controller = null

# Settings
var vr_enabled = false
var vr_auto_initialize = false
var vr_passthrough_enabled = false

# Paths
const VR_MANAGER_PATH = "res://code/gdscript/scripts/vr_system/vr_manager.gd"
const VR_SCENE_SETUP_PATH = "res://code/gdscript/scripts/vr_system/vr_scene_setup.gd"
const SETTINGS_FILE = "user://settings.cfg"

# Ready function
func _ready():
	# Store reference to main node
	main_node = get_parent()
	
	# Load settings
	load_settings()
	
	# Initialize VR if auto-initialize is enabled
	if vr_auto_initialize and vr_enabled:
		initialize_vr()
	
	# Add input map for VR toggle if it doesn't exist
	if not InputMap.has_action("toggle_vr"):
		var event = InputEventKey.new()
		event.keycode = KEY_F8
		InputMap.add_action("toggle_vr")
		InputMap.action_add_event("toggle_vr", event)
		print("Added toggle_vr input mapping")

# Process function
func _process(delta):
	# Check for VR toggle
	if Input.is_action_just_pressed("toggle_vr"):
		toggle_vr()
	
	# Update VR if active
	if vr_manager and vr_enabled:
		update_vr_state()

# Initialize VR system
func initialize_vr():
	print("Initializing VR system...")
	
	# Check if VR files exist
	var vr_manager_script = load(VR_MANAGER_PATH)
	if vr_manager_script:
		# Create VR Manager
		vr_manager = VRManager.get_instance()
		if not vr_manager:
			vr_manager = vr_manager_script.new()
			vr_manager.name = "VRManager"
			get_tree().root.add_child(vr_manager)
		
		# Initialize VR Manager
		vr_manager.initialize()
		
		# Find universe controller
		find_universe_controller()
		
		# Initialize Akashic Records
		initialize_akashic_records()
		
		# Create VR scene setup
		create_vr_scene_setup()
		
		print("VR system initialized successfully")
		return true
	else:
		push_error("VR Manager script not found at " + VR_MANAGER_PATH)
		return false

# Find or create universe controller
func find_universe_controller():
	# Try to find existing controller
	universe_controller = get_node_or_null("/root/UniverseController")
	
	if not universe_controller:
		# Look through the scene tree
		var nodes = get_tree().get_nodes_in_group("universe_controller")
		if nodes.size() > 0:
			universe_controller = nodes[0]
			print("Found universe controller: " + universe_controller.name)
	
	if universe_controller and vr_manager:
		print("Connecting VR Manager to Universe Controller")
		# Connection would happen through the VR Scene Setup

# Initialize Akashic Records
func initialize_akashic_records():
	# Try to get existing Akashic Records manager
	akashic_records = get_node_or_null("/root/AkashicRecordsManager")
	
	if not akashic_records:
		# Try to find through script access
		akashic_records = AkashicRecordsManager.get_instance()
	
	if akashic_records:
		if not akashic_records.is_initialized:
			akashic_records.initialize()
		print("Akashic Records system initialized")
	else:
		push_error("Could not find or initialize Akashic Records manager")

# Create VR Scene Setup
func create_vr_scene_setup():
	var vr_scene_setup_script = load(VR_SCENE_SETUP_PATH)
	if vr_scene_setup_script:
		var vr_scene_setup = vr_scene_setup_script.new()
		vr_scene_setup.name = "VRSceneSetup"
		get_tree().root.add_child(vr_scene_setup)
		print("VR Scene Setup created")
	else:
		push_error("VR Scene Setup script not found at " + VR_SCENE_SETUP_PATH)

# Toggle VR mode
func toggle_vr():
	vr_enabled = !vr_enabled
	
	if vr_enabled:
		if not vr_manager:
			initialize_vr()
		else:
			print("VR system already initialized")
	else:
		if vr_manager:
			# We don't destroy the VR manager, just disable it
			# Otherwise we'd need to re-create it later
			vr_manager.set_process(false)
			print("VR system disabled")
	
	save_settings()
	print("VR mode " + ("enabled" if vr_enabled else "disabled"))

# Update VR state with game data
func update_vr_state():
	# Update with current game state
	if vr_manager and main_node:
		# Here we would update VR with any relevant game state
		pass

# Load settings
func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_FILE)
	
	if err == OK:
		vr_enabled = config.get_value("vr", "enabled", false)
		vr_auto_initialize = config.get_value("vr", "auto_initialize", false)
		vr_passthrough_enabled = config.get_value("vr", "passthrough", false)
		print("VR settings loaded")
	else:
		print("No settings file found, using defaults")
		vr_enabled = false
		vr_auto_initialize = false
		vr_passthrough_enabled = false
		save_settings()

# Save settings
func save_settings():
	var config = ConfigFile.new()
	
	# Save VR settings
	config.set_value("vr", "enabled", vr_enabled)
	config.set_value("vr", "auto_initialize", vr_auto_initialize)
	config.set_value("vr", "passthrough", vr_passthrough_enabled)
	
	config.save(SETTINGS_FILE)
	print("VR settings saved")

# Add VR options to settings menu
func add_vr_settings_to_menu(settings_menu):
	# Check if we have access to the settings menu
	if settings_menu:
		# Add VR toggle option
		var vr_toggle_option = {
			"name": "VR Mode",
			"action": "toggle_vr",
			"description": "Enable or disable VR mode for Oculus Quest 2"
		}
		
		# Add auto-initialize option
		var vr_auto_option = {
			"name": "Auto-initialize VR",
			"action": "toggle_vr_auto",
			"description": "Automatically initialize VR at startup"
		}
		
		# Add passthrough option
		var vr_passthrough_option = {
			"name": "VR Passthrough",
			"action": "toggle_vr_passthrough",
			"description": "Enable camera passthrough in VR (only works on Quest 2)"
		}
		
		# Add options to menu
		settings_menu.append(vr_toggle_option)
		settings_menu.append(vr_auto_option)
		settings_menu.append(vr_passthrough_option)
		
		print("VR options added to settings menu")
	else:
		print("Settings menu not available")

# Actions for settings menu
func toggle_vr_auto():
	vr_auto_initialize = !vr_auto_initialize
	save_settings()
	print("Auto-initialize VR " + ("enabled" if vr_auto_initialize else "disabled"))

func toggle_vr_passthrough():
	vr_passthrough_enabled = !vr_passthrough_enabled
	save_settings()
	
	# Apply passthrough setting if VR is active
	if vr_manager and vr_enabled:
		vr_manager.set_passthrough(vr_passthrough_enabled)
	
	print("VR Passthrough " + ("enabled" if vr_passthrough_enabled else "disabled"))