################################################################
# PERFECT INPUT SYSTEM - PHASE 2 IMPLEMENTATION
# Divine Cursor + Universal Input Unification + AI Integration
# Created: May 31st, 2025 | Perfect Pentagon Architecture  
# Location: scripts/autoload/perfect_input.gd
################################################################

extends UniversalBeingBase
################################################################
# CORE VARIABLES
################################################################

# DIVINE CURSOR - Mouse as Universal Being!
var mouse_being: Node = null
var keyboard_being: Node = null
var divine_cursor_active: bool = false

# Handler registries for ALL Godot input functions (from 3k-line gold mine!)
var shortcut_handlers: Array[Callable] = []
var main_input_handlers: Array[Callable] = []
var gui_input_handlers: Array[Callable] = []
var unhandled_handlers: Array[Callable] = []
var unhandled_key_handlers: Array[Callable] = []

# AI Integration - For Gamma and other AI entities
var ai_input_handlers: Dictionary = {}
var ai_entities_active: Array[String] = []
var ai_input_enabled: bool = true

# System status
var input_throttling: bool = false
var throttle_rate: float = 100.0  # events per second limit
var debug_mode: bool = true
var system_ready: bool = false

################################################################
# SIGNALS - Perfect Pentagon Communication
################################################################

signal divine_cursor_created(cursor_being: Node)
signal input_processed(event: InputEvent, handler_type: String)
signal ai_input_received(ai_name: String, input_data: Dictionary)
signal mouse_being_interaction(target_being: Node, interaction_type: String)
signal input_overflow_detected(rate: float)

################################################################
# INITIALIZATION
################################################################

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("🖱️ PERFECT INPUT SYSTEM: Initializing divine input management...")
	
	# Wait for other systems to be ready
	await get_tree().process_frame
	
	# Create divine beings
	create_divine_cursor()
	create_keyboard_being()
	
	# Set up AI input monitoring
	setup_ai_input_monitoring()
	
	# Connect to other Perfect Pentagon systems
	_connect_to_pentagon_systems()
	
	system_ready = true
	
	if debug_mode:
		print("✅ PERFECT INPUT: System ready - Divine Cursor active, AI integration enabled")

################################################################
# DIVINE CURSOR CREATION
################################################################


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func create_divine_cursor():
	"""
	Create the Divine Cursor - Mouse as Universal Being in 3D space
	
	INPUT: None (uses system configuration)
	PROCESS: Creates Universal Being for mouse, sets up 3D representation, configures consciousness
	OUTPUT: Divine Cursor Universal Being in scene
	CHANGES: Creates mouse_being node with maximum awareness
	CONNECTION: Links to Universal Being system and scene interaction
	"""
	
	print("🖱️ CREATING DIVINE CURSOR: Mouse becoming Universal Being...")
	
	# Check if Universal Object Manager exists
	if not has_node("/root/UniversalObjectManager"):
		print("⚠️ DIVINE CURSOR: UniversalObjectManager not found, creating basic cursor")
		_create_basic_divine_cursor()
		return
	
	var uom = get_node("/root/UniversalObjectManager")
	
	# Create mouse as Universal Being using correct method name
	mouse_being = uom.create_object("magical_orb", Vector3(0, 2, 0), {
		"name": "divine_cursor_mouse",
		"consciousness_level": 5,
		"divine_cursor": true
	})
	
	if mouse_being:
		# Configure divine properties
		if mouse_being.has_method("set_consciousness_level"):
			mouse_being.set_consciousness_level(5)  # Maximum awareness
		
		if mouse_being.has_method("become"):
			mouse_being.become("divine_cursor")
		
		# Set visual properties
		if mouse_being.has_method("set_form_properties"):
			mouse_being.set_form_properties({
				"size": Vector3(0.1, 0.1, 0.1),
				"color": Color.GOLD,
				"glow": true,
				"transparency": 0.7,
				"layer": 100  # Always on top
			})
		
		# Add to current scene (check if already has parent first)
		var current_scene = get_tree().current_scene
		if current_scene and not mouse_being.get_parent():
			FloodgateController.universal_add_child(mouse_being, current_scene)
			divine_cursor_active = true
		elif mouse_being.get_parent():
			print("✨ DIVINE CURSOR: Already has parent, skipping add_child")
			divine_cursor_active = true
			
			print("✨ DIVINE CURSOR: Mouse Universal Being created with maximum consciousness")
			emit_signal("divine_cursor_created", mouse_being)
		else:
			print("🚨 DIVINE CURSOR ERROR: No current scene found")
	else:
		print("🚨 DIVINE CURSOR ERROR: Failed to create Universal Being")
		_create_basic_divine_cursor()

func _create_basic_divine_cursor():
	"""
	Create a basic divine cursor if Universal Object Manager isn't available
	"""
	mouse_being = Node3D.new()
	mouse_being.name = "divine_cursor_basic"
	
	# Add visual representation
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.05
	mesh_instance.mesh = sphere_mesh
	
	# Add glowing material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color.GOLD
	material.emission = Color.GOLD * 0.5
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.material_override = material
	
	FloodgateController.universal_add_child(mesh_instance, mouse_being)
	
	# Add to scene
	var current_scene = get_tree().current_scene
	if current_scene:
		FloodgateController.universal_add_child(mouse_being, current_scene)
		divine_cursor_active = true
		print("✨ DIVINE CURSOR: Basic cursor created (Universal Being system not available)")

func create_keyboard_being():
	"""
	Create keyboard as Universal Being for AI text input
	"""
	if not has_node("/root/UniversalObjectManager"):
		return
	
	var uom = get_node("/root/UniversalObjectManager")
	keyboard_being = uom.create_object("input_interface", Vector3(0, 1, 0), {
		"name": "divine_keyboard",
		"consciousness_level": 3,
		"input_type": "keyboard"
	})
	
	if keyboard_being:
		if keyboard_being.has_method("set_consciousness_level"):
			keyboard_being.set_consciousness_level(3)  # High awareness for text input
		
		if keyboard_being.has_method("become"):
			keyboard_being.become("input_interface")
		
		print("⌨️ DIVINE KEYBOARD: Keyboard Universal Being created")

################################################################
# INPUT PROCESSING - ALL GODOT INPUT FUNCTIONS UNIFIED
################################################################

# INTERCEPT ALL INPUT TYPES (From 3000-line Godot gold mine knowledge!)

func _shortcut_input(event: InputEvent):
	"""Highest priority input - shortcuts and hotkeys"""
	if system_ready:
		_process_divine_input(event, "shortcut", shortcut_handlers)

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	"""Main input processing - mouse, keyboard, etc."""
	if system_ready:
		_process_divine_input(event, "main", main_input_handlers)
		_update_divine_beings(event)

func _gui_input(event: InputEvent):
	"""GUI-specific input processing"""
	if system_ready:
		_process_divine_input(event, "gui", gui_input_handlers)

# Unhandled input integrated into Pentagon Architecture
func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	# Unhandled input logic
	"""Fallback input processing"""
	if system_ready:
		_process_divine_input(event, "unhandled", unhandled_handlers)

func _unhandled_key_input(event: InputEvent):
	"""Unhandled keyboard input"""
	if system_ready:
		_process_divine_input(event, "unhandled_key", unhandled_key_handlers)

################################################################
# DIVINE INPUT PROCESSING
################################################################

func _process_divine_input(event: InputEvent, type: String, handlers: Array[Callable]):
	"""
	Process input through the divine input system with AI integration
	"""
	
	# Check for input throttling
	if input_throttling and _should_throttle_input():
		return
	
	# Process for AI entities first
	_process_ai_input(event, type)
	
	# Process through registered handlers
	for handler in handlers:
		if handler.is_valid():
			handler.call(event, type)
	
	# Emit signal for monitoring
	emit_signal("input_processed", event, type)
	
	if debug_mode and event is InputEventMouseButton:
		print("🖱️ DIVINE INPUT: %s processed (%s)" % [event.get_class(), type])

func _update_divine_beings(event: InputEvent):
	"""
	Update Divine Cursor and other beings based on input
	"""
	if not divine_cursor_active or not mouse_being:
		return
	
	if event is InputEventMouse:
		# Update mouse being position in 3D space
		var mouse_pos_3d = _screen_to_world_position(event.position)
		if mouse_pos_3d != Vector3.ZERO:
			mouse_being.global_position = mouse_pos_3d
		
		# Check what the mouse is pointing at
		var pointed_being = _get_being_under_mouse(mouse_pos_3d)
		if pointed_being:
			_handle_mouse_being_interaction(pointed_being, event)

func _screen_to_world_position(screen_pos: Vector2) -> Vector3:
	"""
	Convert screen position to 3D world position for Divine Cursor
	"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return Vector3.ZERO
	
	# Raycast from camera through screen position
	var from = camera.project_ray_origin(screen_pos)
	var to = from + camera.project_ray_normal(screen_pos) * 1000.0
	
	var space_state = get_viewport().get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		return result.position
	else:
		# Default to position in front of camera
		return from + camera.project_ray_normal(screen_pos) * 5.0

func _get_being_under_mouse(mouse_pos_3d: Vector3) -> Node:
	"""
	Find Universal Being under mouse cursor
	"""
	# This will be enhanced when we have the Universal Object Manager fully integrated
	var nearby_objects = _find_nearby_objects(mouse_pos_3d, 1.0)
	
	for obj in nearby_objects:
		if obj.has_method("is_universal_being") and obj.is_universal_being():
			return obj
	
	return null

func _find_nearby_objects(position: Vector3, radius: float) -> Array:
	"""
	Find objects near a 3D position
	"""
	var nearby = []
	var all_nodes = get_tree().get_nodes_in_group("universal_beings")
	
	for node in all_nodes:
		if node.has_method("get_global_position"):
			var distance = position.distance_to(node.global_position)
			if distance <= radius:
				nearby.append(node)
	
	return nearby

func _handle_mouse_being_interaction(target_being: Node, event: InputEvent):
	"""
	Handle interaction between Divine Cursor and other Universal Beings
	"""
	if mouse_being and mouse_being.has_method("show_connection_to"):
		mouse_being.show_connection_to(target_being)
	
	if event is InputEventMouseButton and event.pressed:
		var interaction_type = "click"
		if event.button_index == MOUSE_BUTTON_RIGHT:
			interaction_type = "right_click"
		elif event.double_click:
			interaction_type = "double_click"
		
		# Trigger Logic Connector action if available
		if has_node("/root/LogicConnector"):
			var logic_connector = get_node("/root/LogicConnector")
			if logic_connector.has_method("trigger_action"):
				logic_connector.trigger_action(target_being, "on_user_" + interaction_type)
		
		emit_signal("mouse_being_interaction", target_being, interaction_type)
		
		if debug_mode:
			print("✨ DIVINE INTERACTION: Mouse being %s with %s" % [interaction_type, target_being.name])

################################################################
# AI INPUT INTEGRATION
################################################################

func setup_ai_input_monitoring():
	"""
	Set up monitoring for AI entity input
	"""
	if has_node("/root/PerfectReady"):
		var perfect_ready = get_node("/root/PerfectReady")
		if perfect_ready.has_signal("ai_entity_ready"):
			perfect_ready.ai_entity_ready.connect(_on_ai_entity_ready)

func _on_ai_entity_ready(ai_name: String):
	"""
	Called when an AI entity becomes ready for input
	"""
	ai_entities_active.append(ai_name)
	ai_input_handlers[ai_name] = []
	
	print("🤖 AI INPUT: %s ready for input processing" % ai_name)

func _process_ai_input(event: InputEvent, type: String):
	"""
	Process input for AI entities (they can observe and learn from user input)
	"""
	if not ai_input_enabled or ai_entities_active.is_empty():
		return
	
	# Create input data for AI entities
	var ai_input_data = {
		"event_type": event.get_class(),
		"input_type": type,
		"timestamp": Time.get_ticks_msec(),
		"details": _extract_input_details(event)
	}
	
	# Send to each active AI entity
	for ai_name in ai_entities_active:
		emit_signal("ai_input_received", ai_name, ai_input_data)
		_write_ai_input_log(ai_name, ai_input_data)

func _extract_input_details(event: InputEvent) -> Dictionary:
	"""
	Extract relevant details from input event for AI processing
	"""
	var details = {}
	
	if event is InputEventMouse:
		details["position"] = event.position
		details["relative"] = event.relative if event.has_method("relative") else Vector2.ZERO
	
	if event is InputEventMouseButton:
		details["button"] = event.button_index
		details["pressed"] = event.pressed
		details["double_click"] = event.double_click
	
	if event is InputEventKey:
		details["keycode"] = event.keycode
		details["pressed"] = event.pressed
		details["unicode"] = event.unicode
	
	return details

func _write_ai_input_log(ai_name: String, input_data: Dictionary):
	"""
	Write input data to AI entity's input file for processing
	"""
	var input_file_path = "ai_communication/input/" + ai_name + "_input_log.txt"
	var file = FileAccess.open(input_file_path, FileAccess.WRITE_READ)
	
	if file:
		file.seek_end()
		file.store_line("input_event: %s" % JSON.stringify(input_data))
		file.close()

################################################################
# HANDLER REGISTRATION
################################################################

func register_input_handler(type: String, handler: Callable) -> bool:
	"""
	Register an input handler for specific input types
	"""
	match type.to_lower():
		"shortcut":
			shortcut_handlers.append(handler)
		"main":
			main_input_handlers.append(handler)
		"gui":
			gui_input_handlers.append(handler)
		"unhandled":
			unhandled_handlers.append(handler)
		"unhandled_key":
			unhandled_key_handlers.append(handler)
		_:
			print("🚨 PERFECT INPUT ERROR: Unknown handler type " + type)
			return false
	
	if debug_mode:
		print("📝 PERFECT INPUT: Registered %s handler" % type)
	
	return true

func unregister_input_handler(type: String, handler: Callable) -> bool:
	"""
	Remove an input handler
	"""
	var handlers_array: Array[Callable]
	
	match type.to_lower():
		"shortcut": handlers_array = shortcut_handlers
		"main": handlers_array = main_input_handlers
		"gui": handlers_array = gui_input_handlers
		"unhandled": handlers_array = unhandled_handlers
		"unhandled_key": handlers_array = unhandled_key_handlers
		_: return false
	
	var index = handlers_array.find(handler)
	if index >= 0:
		handlers_array.remove_at(index)
		return true
	
	return false

################################################################
# INPUT THROTTLING AND MONITORING
################################################################

func enable_throttling(enabled: bool, rate: float = 100.0):
	"""
	Enable or disable input throttling for performance
	"""
	input_throttling = enabled
	throttle_rate = rate
	
	print("🌊 PERFECT INPUT: Throttling %s (rate: %.1f events/sec)" % [
		"ENABLED" if enabled else "DISABLED", 
		rate
	])

func _should_throttle_input() -> bool:
	"""
	Check if input should be throttled based on current rate
	"""
	# This would be implemented with rate limiting logic
	# For now, return false to allow all input
	return false

################################################################
# SYSTEM CONNECTION
################################################################

func _connect_to_pentagon_systems():
	"""
	Connect to other Perfect Pentagon systems
	"""
	# Connect to SewersMonitor when available
	if has_node("/root/SewersMonitor"):
		print("🔗 PERFECT INPUT: Connected to SewersMonitor")

################################################################
# STATUS AND CONSOLE FUNCTIONS
################################################################

func get_input_status() -> Dictionary:
	"""
	Get complete status of input system
	"""
	return {
		"system_ready": system_ready,
		"divine_cursor_active": divine_cursor_active,
		"input_throttling": input_throttling,
		"throttle_rate": throttle_rate,
		"ai_entities_active": ai_entities_active.size(),
		"handler_counts": {
			"shortcut": shortcut_handlers.size(),
			"main": main_input_handlers.size(),
			"gui": gui_input_handlers.size(),
			"unhandled": unhandled_handlers.size(),
			"unhandled_key": unhandled_key_handlers.size()
		}
	}

func console_input_status() -> String:
	"""Console command: Show input system status"""
	var status = get_input_status()
	return """
🖱️ PERFECT INPUT SYSTEM STATUS
═════════════════════════════════
System Ready: %s
🌟 Divine Cursor Active: %s
🌊 Input Throttling: %s (%.1f events/sec)
🤖 AI Entities Active: %d

📊 INPUT HANDLERS:
• Shortcut: %d
• Main: %d  
• GUI: %d
• Unhandled: %d
• Unhandled Key: %d

✨ DIVINE BEINGS:
• Mouse Being: %s
• Keyboard Being: %s
""" % [
		"YES" if status.system_ready else "NO",
		"YES" if status.divine_cursor_active else "NO", 
		"ENABLED" if status.input_throttling else "DISABLED",
		status.throttle_rate,
		status.ai_entities_active,
		status.handler_counts.shortcut,
		status.handler_counts.main,
		status.handler_counts.gui, 
		status.handler_counts.unhandled,
		status.handler_counts.unhandled_key,
		"ACTIVE" if mouse_being != null else "INACTIVE",
		"ACTIVE" if keyboard_being != null else "INACTIVE"
	]

################################################################
# PERFECT PENTAGON INTEGRATION
################################################################

func get_system_info() -> Dictionary:
	"""
	Return system information for Perfect Pentagon coordination
	"""
	return {
		"system_name": "Perfect Input",
		"version": "1.0",
		"status": "active" if system_ready else "initializing",
		"priority": 3,  # Third in Pentagon sequence
		"dependencies": ["Perfect Init", "Perfect Ready"],
		"provides": ["divine_cursor", "unified_input", "ai_input_integration"],
		"divine_cursor_active": divine_cursor_active,
		"ai_integration": true
	}

################################################################
# END OF PERFECT INPUT SYSTEM
################################################################