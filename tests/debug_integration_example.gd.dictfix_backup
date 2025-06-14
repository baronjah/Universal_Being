# Debug Integration Example - Shows how to integrate debug system with main.gd
# Add this to your main.gd to enable complete Universal Being debugging

extends Node

# ===== DEBUG SYSTEM INTEGRATION =====

var debug_click_handler: DebugClickHandler = null
var universal_inspector: UniversalScriptInspector = null

# Add this to your main.gd _ready() function:
func setup_universal_debugging() -> void:
	"""Setup the complete Universal Being debug system"""
	print("🔧 Setting up Universal Being debug system...")
	
	# Create debug click handler
	debug_click_handler = DebugClickHandler.new()
	debug_click_handler.name = "DebugClickHandler"
	add_child(debug_click_handler)
	
	# Connect debug events
	debug_click_handler.inspection_requested.connect(_on_debug_inspection_requested)
	debug_click_handler.object_clicked.connect(_on_debug_object_clicked)
	
	print("🔧 Universal Being debug system ready!")
	print("🖱️ Right-click any Universal Being to inspect its variables!")
	print("🔧 Press Ctrl+F12 to toggle debug mode")
	print("🔧 Press F12 to open/close inspector")

# Add this to your main.gd _input() function:
func handle_debug_input(event: InputEvent) -> void:
	"""Handle debug-related input"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F12:
				if event.ctrl_pressed:
					# Toggle debug mode
					if debug_click_handler:
						debug_click_handler.toggle_debug_mode()
				else:
					# Toggle inspector visibility
					if universal_inspector:
						if universal_inspector.inspector_window.visible:
							universal_inspector.hide_inspector()
						else:
							universal_inspector.show_inspector()

# Debug event handlers
func _on_debug_inspection_requested(object: Node) -> void:
	"""Handle inspection request"""
	print("🔍 Inspection requested for: %s" % object.name)
	
	# Get debug interface using LogicConnector
	var debug_interface = LogicConnector.get_debug_interface(object)
	
	# Print debug summary
	print_debug_summary(object, debug_interface)

func _on_debug_object_clicked(object: Node, click_position: Vector3) -> void:
	"""Handle object click"""
	print("🖱️ Clicked on: %s at position %s" % [object.name, click_position])

func print_debug_summary(object: Node, debug_interface: Dictionary) -> void:
	"""Print a debug summary of the object"""
	print("=" * 50)
	print("🔍 DEBUG SUMMARY: %s" % object.name)
	print("=" * 50)
	
	# Object info
	var obj_info = debug_interface.object_info
	print("📋 Object Info:")
	print("  Name: %s" % obj_info.name)
	print("  Type: %s" % obj_info.type)
	print("  Class: %s" % obj_info.class)
	print("  Position: %s" % obj_info.position)
	print("  Children: %d" % obj_info.children_count)
	
	# Pentagon status
	var pentagon = debug_interface.pentagon_status
	print("🔺 Pentagon Status:")
	print("  Is Universal Being: %s" % pentagon.is_universal_being)
	print("  Pentagon Active: %s" % pentagon.pentagon_active)
	print("  Lifecycle Stage: %s" % pentagon.lifecycle_stage)
	print("  Methods: %s" % pentagon.pentagon_methods)
	
	# Consciousness data
	var consciousness = debug_interface.consciousness_data
	print("🧠 Consciousness:")
	print("  Level: %d" % consciousness.level)
	print("  Color: %s" % consciousness.color)
	print("  Evolution Paths: %s" % consciousness.evolution_paths)
	
	# Available actions
	var actions = debug_interface.available_actions
	print("⚡ Available Actions (%d):" % actions.size())
	for action in actions.slice(0, 5):  # Show first 5
		print("  - %s: %s" % [action.name, action.description])
	if actions.size() > 5:
		print("  ... and %d more" % (actions.size() - 5))
	
	# Connection points
	var connections = debug_interface.connection_points
	print("🔗 Connections (%d):" % connections.size())
	for connection in connections.slice(0, 3):  # Show first 3
		print("  - %s: %s" % [connection.type, connection.description])
	if connections.size() > 3:
		print("  ... and %d more" % (connections.size() - 3))
	
	print("=" * 50)

# ===== EXAMPLE USAGE IN YOUR EXISTING FUNCTIONS =====

# Add this to your create_test_being() function:
func add_debug_to_test_being(test_being: Node) -> void:
	"""Add debug capabilities to a test being"""
	if test_being and test_being.has_method("pentagon_init"):
		# The being automatically gets LogicConnector capabilities
		# You can test the debug interface:
		var debug_interface = LogicConnector.get_debug_interface(test_being)
		print("🧪 Test being debug interface ready: %d actions available" % debug_interface.available_actions.size())

# Add this to your create_chunk_at_coordinate() function in ChunkGridManager:
func add_debug_to_chunk(chunk: Node) -> void:
	"""Add debug capabilities to a chunk"""
	if chunk and chunk.has_method("pentagon_init"):
		# Chunks automatically get full debug interface
		var debug_interface = LogicConnector.get_debug_interface(chunk)
		print("🧊 Chunk debug interface ready: %s" % chunk.name)

# ===== COMPLETE INTEGRATION EXAMPLE =====

# Here's how to modify your existing main.gd _ready() function:
func _ready() -> void:
	# Your existing initialization code...
	name = "Main"
	print("🌟 Universal Being Engine: Starting...")
	
	# ADD THIS LINE to enable debugging:
	setup_universal_debugging()
	
	# Your existing code continues...
	if SystemBootstrap:
		if SystemBootstrap.is_system_ready():
			on_systems_ready()
		else:
			SystemBootstrap.system_ready.connect(on_systems_ready)

# And modify your _input() function:
func _input(event: InputEvent) -> void:
	# ADD THIS LINE to handle debug input:
	handle_debug_input(event)
	
	# Your existing input handling continues...
	if event.is_action_pressed("ui_console_toggle"):
		toggle_console()
	# ... rest of your input handling

# ===== TESTING THE DEBUG SYSTEM =====

func test_debug_system() -> void:
	"""Test the debug system with existing beings"""
	print("🧪 Testing Universal Being debug system...")
	
	# Test with demo beings
	for being in demo_beings:
		if being and is_instance_valid(being):
			var debug_interface = LogicConnector.get_debug_interface(being)
			print("🔍 %s: %d actions, %d connections" % [
				being.name,
				debug_interface.available_actions.size(),
				debug_interface.connection_points.size()
			])
	
	print("🧪 Debug system test complete!")

# ===== ADVANCED DEBUG FEATURES =====

func debug_all_universal_beings() -> void:
	"""Debug all Universal Beings in the scene"""
	var universal_beings = get_tree().get_nodes_in_group("universal_beings")
	
	print("🔍 Debugging %d Universal Beings:" % universal_beings.size())
	
	for being in universal_beings:
		var debug_interface = LogicConnector.get_debug_interface(being)
		var obj_info = debug_interface.object_info
		var pentagon = debug_interface.pentagon_status
		
		print("  %s (%s): Pentagon=%s, Consciousness=%d" % [
			obj_info.name,
			obj_info.type,
			pentagon.pentagon_active,
			debug_interface.consciousness_data.level
		])

func find_debug_problems() -> Array:
	"""Find potential problems in Universal Being scripts"""
	var problems = []
	var all_beings = get_tree().get_nodes_in_group("universal_beings")
	
	for being in all_beings:
		var debug_interface = LogicConnector.get_debug_interface(being)
		var pentagon = debug_interface.pentagon_status
		
		# Check for Pentagon compliance
		if pentagon.is_universal_being:
			if pentagon.pentagon_methods.size() < 5:
				problems.append("Missing Pentagon methods in %s" % being.name)
			
			if not pentagon.pentagon_active and being.is_inside_tree():
				problems.append("Pentagon not active for %s" % being.name)
		
		# Check consciousness levels
		var consciousness = debug_interface.consciousness_data
		if consciousness.level < 0 or consciousness.level > 5:
			problems.append("Invalid consciousness level in %s: %d" % [being.name, consciousness.level])
	
	return problems