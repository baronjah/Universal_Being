# VR Helper Functions for Eden Space Game
# These functions can be added to any script to quickly enable VR functionality

# Initialize VR system
static func initialize_vr():
	print("Initializing VR system...")
	
	# Check if VR Manager exists or can be loaded
	var vr_manager = null
	
	# Try to get existing singleton first
	if Engine.has_singleton("VRManager"):
		vr_manager = Engine.get_singleton("VRManager")
	
	# If not a singleton, try to find in scene tree
	if not vr_manager:
		var root = Engine.get_main_loop().root
		for child in root.get_children():
			if child.name == "VRManager":
				vr_manager = child
				break
	
	# If not found, try to load and create
	if not vr_manager:
		var vr_manager_script = load("res://code/gdscript/scripts/vr_system/vr_manager.gd")
		if vr_manager_script:
			vr_manager = vr_manager_script.new()
			vr_manager.name = "VRManager"
			Engine.get_main_loop().root.add_child(vr_manager)
			print("VR Manager created")
		else:
			push_error("VR Manager script not found")
			return null
	
	# Initialize VR manager if it has initialize method
	if "initialize" in vr_manager:
		vr_manager.initialize()
	
	# Create VR scene setup
	var scene_setup = create_vr_scene_setup()
	
	return vr_manager

# Create VR scene setup
static func create_vr_scene_setup():
	var vr_scene_setup = null
	var root = Engine.get_main_loop().root
	
	# Check if it already exists
	for child in root.get_children():
		if child.name == "VRSceneSetup":
			vr_scene_setup = child
			break
	
	if not vr_scene_setup:
		var vr_scene_setup_script = load("res://code/gdscript/scripts/vr_system/vr_scene_setup.gd")
		if vr_scene_setup_script:
			vr_scene_setup = vr_scene_setup_script.new()
			vr_scene_setup.name = "VRSceneSetup"
			root.add_child(vr_scene_setup)
			print("VR Scene Setup created")
		else:
			push_error("VR Scene Setup script not found")
	
	return vr_scene_setup

# Load VR integration file into a node
static func add_vr_integration_to(node):
	if not node:
		push_error("Cannot add VR integration - node is null")
		return null
	
	# Check if the node already has VR integration
	for child in node.get_children():
		if child.name == "VRIntegration":
			return child
	
	# Load and add VR integration
	var vr_integration_script = load("res://code/gdscript/scripts/Menu_Keyboard_Console/vr_integration.gd")
	if vr_integration_script:
		var vr_integration = vr_integration_script.new()
		vr_integration.name = "VRIntegration"
		node.add_child(vr_integration)
		print("VR Integration added to " + node.name)
		return vr_integration
	else:
		push_error("VR Integration script not found")
		return null

# Toggle VR mode
static func toggle_vr():
	var vr_manager = null
	
	# Try to get existing VR manager
	if Engine.has_singleton("VRManager"):
		vr_manager = Engine.get_singleton("VRManager")
	else:
		var root = Engine.get_main_loop().root
		for child in root.get_children():
			if child.name == "VRManager":
				vr_manager = child
				break
	
	# Toggle VR if found
	if vr_manager:
		if "toggle_vr" in vr_manager:
			vr_manager.toggle_vr()
			return true
		else:
			push_error("VR Manager does not have toggle_vr method")
	else:
		# Create VR system if it doesn't exist
		vr_manager = initialize_vr()
		if vr_manager:
			return true
	
	return false

# Check if VR is active
static func is_vr_active():
	var vr_manager = null
	
	# Try to get existing VR manager
	if Engine.has_singleton("VRManager"):
		vr_manager = Engine.get_singleton("VRManager")
	else:
		var root = Engine.get_main_loop().root
		for child in root.get_children():
			if child.name == "VRManager":
				vr_manager = child
				break
	
	# Check VR status
	if vr_manager:
		if "is_vr_active" in vr_manager:
			return vr_manager.is_vr_active
		else:
			return false
	
	return false

# Add VR toggle action to InputMap
static func add_vr_toggle_input():
	if not InputMap.has_action("toggle_vr"):
		var event = InputEventKey.new()
		event.keycode = KEY_F8
		InputMap.add_action("toggle_vr")
		InputMap.action_add_event("toggle_vr", event)
		print("Added toggle_vr input mapping")
		return true
	
	return false

# Add VR options to settings menu
static func add_vr_options_to_settings(settings_menu):
	if not settings_menu:
		return false
	
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
	return true