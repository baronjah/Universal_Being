# Enhanced Debug Click Handler - Uses Luminus's LogicConnector singleton
# Simplified click handling using the elegant registry approach

extends Node
class_name EnhancedDebugClickHandler

# ===== DEBUG PROPERTIES =====
@export var debug_mode: bool = true
@export var click_to_inspect: bool = true
@export var show_click_hints: bool = true

# Inspector Integration
var unified_inspector: UnifiedDebugInterface = null
var camera: Camera3D = null

# Visual Feedback
var click_hint_label: Label = null

# Signals
signal debuggable_clicked(debuggable: Debuggable)
signal inspection_requested(debuggable: Debuggable)

# ===== SETUP =====

func _ready() -> void:
	if not debug_mode:
		return
	
	# Create unified inspector
	create_unified_inspector()
	
	# Setup visual feedback
	setup_visual_feedback()
	
	# Find camera
	find_active_camera()
	
	print("🖱️ Enhanced Debug Click Handler ready - using LogicConnector registry!")

func create_unified_inspector() -> void:
	"""Create the unified debug inspector"""
	unified_inspector = UnifiedDebugInterface.new()
	add_child(unified_inspector)
	
	# Connect to inspector signals
	unified_inspector.variable_changed.connect(_on_variable_changed)
	unified_inspector.inspection_started.connect(_on_inspection_started)
	unified_inspector.inspection_ended.connect(_on_inspection_ended)

func setup_visual_feedback() -> void:
	"""Setup visual feedback for debugging"""
	if show_click_hints:
		create_click_hint_ui()

func create_click_hint_ui() -> void:
	"""Create UI hint for click instructions"""
	var canvas = CanvasLayer.new()
	add_child(canvas)
	
	click_hint_label = Label.new()
	click_hint_label.text = "🖱️ Right-click any Debuggable object to inspect (%d registered)" % LogicConnector.get_debuggable_count()
	click_hint_label.position = Vector2(10, 10)
	click_hint_label.modulate = Color(1, 1, 1, 0.7)
	canvas.add_child(click_hint_label)
	
	# Update hint periodically
	var update_hint = func():
		if click_hint_label:
			click_hint_label.text = "🖱️ Right-click any Debuggable object to inspect (%d registered)" % LogicConnector.get_debuggable_count()
	
	var timer = Timer.new()
	timer.wait_time = 2.0
	timer.timeout.connect(update_hint)
	timer.autostart = true
	add_child(timer)

func find_active_camera() -> void:
	"""Find the active camera in the scene"""
	var cameras = get_tree().get_nodes_in_group("cameras")
	if cameras.size() > 0:
		camera = cameras[0]
	else:
		camera = get_viewport().get_camera_3d()
	
	if camera:
		print("📷 Enhanced debug click handler connected to camera: %s" % camera.name)

# ===== INPUT HANDLING =====

func _input(event: InputEvent) -> void:
	if not debug_mode or not click_to_inspect:
		return
	
	# Handle mouse clicks
	if event is InputEventMouseButton:
		handle_mouse_click(event)
	
	# Handle keyboard shortcuts
	elif event is InputEventKey and event.pressed:
		handle_debug_shortcuts(event)

func handle_mouse_click(event: InputEventMouseButton) -> void:
	"""Handle mouse click for inspection using LogicConnector"""
	if not event.pressed:
		return
	
	# Right click or Ctrl+Left click for inspection
	if event.button_index == MOUSE_BUTTON_RIGHT or (event.button_index == MOUSE_BUTTON_LEFT and event.ctrl_pressed):
		inspect_debuggable_under_cursor()

func handle_debug_shortcuts(event: InputEventKey) -> void:
	"""Handle debug keyboard shortcuts"""
	match event.keycode:
		KEY_F12:  # Toggle debug mode
			if event.ctrl_pressed:
				toggle_debug_mode()
		KEY_F11:  # Show all debuggables
			if event.ctrl_pressed:
				show_all_debuggables()
		KEY_F10:  # Print registry status
			if event.ctrl_pressed:
				LogicConnector.print_registry_status()
		KEY_ESCAPE:  # Close inspector
			if unified_inspector and unified_inspector.inspector_window and unified_inspector.inspector_window.visible:
				unified_inspector.hide_inspector()

# ===== LUMINUS INTEGRATION =====

func inspect_debuggable_under_cursor() -> void:
	"""Inspect debuggable object under cursor using LogicConnector raypick"""
	if not camera:
		find_active_camera()
		if not camera:
			print("❌ No camera found for raypicking")
			return
	
	# Use LogicConnector's elegant raypick
	var debuggable = LogicConnector.raypick(camera)
	
	if debuggable:
		inspect_debuggable(debuggable)
	else:
		print("🖱️ No Debuggable object found under cursor")

func inspect_debuggable(debuggable: Debuggable) -> void:
	"""Inspect a debuggable object"""
	print("🔍 Inspecting Debuggable: %s" % debuggable.name if debuggable.has_method("get") else "Unknown")
	
	# Emit signals
	debuggable_clicked.emit(debuggable)
	inspection_requested.emit(debuggable)
	
	# Start inspection with unified inspector
	if unified_inspector:
		unified_inspector.inspect_object(debuggable)
	
	# Update click hint
	if click_hint_label:
		var name = debuggable.name if debuggable.has_method("get") else "Unknown"
		click_hint_label.text = "🔍 Inspecting Debuggable: %s" % name

func show_all_debuggables() -> void:
	"""Show list of all registered debuggables"""
	var debuggables = LogicConnector.all()
	
	print("🔍 All Registered Debuggables (%d):" % debuggables.size())
	
	for i in range(debuggables.size()):
		var debuggable = debuggables[i]
		var name = debuggable.name if debuggable.has_method("get") else "Unknown"
		var type = debuggable.get_class() if debuggable.has_method("get_class") else "Unknown"
		var pos = debuggable.global_position if debuggable is Node3D else Vector3.ZERO
		
		print("  %d. %s (%s) at %s" % [i + 1, name, type, pos])

func toggle_debug_mode() -> void:
	"""Toggle debug mode on/off"""
	debug_mode = !debug_mode
	
	if debug_mode:
		print("🔧 Enhanced debug mode enabled")
		if click_hint_label:
			click_hint_label.visible = true
	else:
		print("🔧 Enhanced debug mode disabled")
		if unified_inspector:
			unified_inspector.hide_inspector()
		if click_hint_label:
			click_hint_label.visible = false

# ===== EVENT HANDLERS =====

func _on_variable_changed(object: Node, property: String, old_value, new_value) -> void:
	"""Handle variable change from inspector"""
	print("🔧 Debuggable variable changed: %s.%s = %s (was %s)" % [object.name, property, new_value, old_value])

func _on_inspection_started(object: Node) -> void:
	"""Handle inspection start"""
	var name = object.name if object.has_method("get") else "Unknown"
	print("🔍 Started inspecting Debuggable: %s" % name)
	
	if click_hint_label:
		click_hint_label.text = "🔍 Inspecting: %s (Right-click others to switch)" % name

func _on_inspection_ended(object: Node) -> void:
	"""Handle inspection end"""
	var name = object.name if object.has_method("get") else "Unknown"
	print("🔍 Stopped inspecting: %s" % name)
	
	if click_hint_label:
		click_hint_label.text = "🖱️ Right-click any Debuggable object to inspect (%d registered)" % LogicConnector.get_debuggable_count()

# ===== UTILITY FUNCTIONS =====

func get_closest_debuggable(position: Vector3) -> Debuggable:
	"""Get closest debuggable to a position"""
	var debuggables = LogicConnector.all()
	var closest: Debuggable = null
	var closest_distance = INF
	
	for debuggable in debuggables:
		if debuggable is Node3D:
			var distance = position.distance_to(debuggable.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest = debuggable
	
	return closest

func find_debuggable_by_name(name: String) -> Debuggable:
	"""Find debuggable by name using LogicConnector"""
	return LogicConnector.find_debuggable_by_name(name)

func inspect_debuggable_by_name(name: String) -> void:
	"""Inspect a debuggable by name"""
	var debuggable = find_debuggable_by_name(name)
	if debuggable:
		inspect_debuggable(debuggable)
	else:
		print("❌ No debuggable found with name: %s" % name)

func get_debug_status() -> Dictionary:
	"""Get current debug status"""
	return {
		"debug_mode": debug_mode,
		"click_to_inspect": click_to_inspect,
		"registered_debuggables": LogicConnector.get_debuggable_count(),
		"debuggable_types": LogicConnector.get_debuggable_types(),
		"inspector_active": unified_inspector and unified_inspector.inspector_window and unified_inspector.inspector_window.visible,
		"camera_connected": camera != null
	}

func print_debug_status() -> void:
	"""Print current debug status"""
	var status = get_debug_status()
	print("🔧 Enhanced Debug Status:")
	for key in status.keys():
		print("  %s: %s" % [key, status[key]])