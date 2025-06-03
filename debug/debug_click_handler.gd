# Debug Click Handler - Makes any Universal Being clickable for inspection
# Attach this to main scene to enable click-to-inspect functionality

extends Node
class_name DebugClickHandler

# ===== DEBUG PROPERTIES =====
@export var debug_mode: bool = true
@export var click_to_inspect: bool = true
@export var show_click_hints: bool = true
@export var highlight_inspectable: bool = true

# Inspector Integration
var script_inspector: UniversalScriptInspector = null
var highlighted_object: Node = null
var highlight_material: StandardMaterial3D = null

# Click Detection
var camera: Camera3D = null
var raycast_length: float = 1000.0

# Visual Feedback
var click_hint_label: Label = null
var inspection_cursor: TextureRect = null

# Signals
signal object_clicked(object: Node, click_position: Vector3)
signal inspection_requested(object: Node)

# ===== SETUP =====

func _ready() -> void:
	if not debug_mode:
		return
	
	# Create script inspector
	create_script_inspector()
	
	# Setup visual feedback
	setup_visual_feedback()
	
	# Find camera
	find_active_camera()
	
	print("🖱️ Debug Click Handler ready - click any Universal Being to inspect!")

func create_script_inspector() -> void:
	"""Create the universal script inspector"""
	script_inspector = UniversalScriptInspector.new()
	add_child(script_inspector)
	
	# Connect to inspector signals
	script_inspector.variable_changed.connect(_on_variable_changed)
	script_inspector.inspection_started.connect(_on_inspection_started)
	script_inspector.inspection_ended.connect(_on_inspection_ended)

func setup_visual_feedback() -> void:
	"""Setup visual feedback for debugging"""
	if show_click_hints:
		create_click_hint_ui()
	
	if highlight_inspectable:
		create_highlight_material()

func create_click_hint_ui() -> void:
	"""Create UI hint for click instructions"""
	# Create overlay canvas
	var canvas = CanvasLayer.new()
	add_child(canvas)
	
	# Click hint label
	click_hint_label = Label.new()
	click_hint_label.text = "🖱️ Right-click any Universal Being to inspect"
	click_hint_label.position = Vector2(10, 10)
	click_hint_label.modulate = Color(1, 1, 1, 0.7)
	canvas.add_child(click_hint_label)
	
	# Inspection cursor (shows when hovering inspectable objects)
	inspection_cursor = TextureRect.new()
	inspection_cursor.size = Vector2(32, 32)
	inspection_cursor.modulate = Color.CYAN
	inspection_cursor.visible = false
	canvas.add_child(inspection_cursor)

func create_highlight_material() -> void:
	"""Create material for highlighting inspectable objects"""
	highlight_material = StandardMaterial3D.new()
	highlight_material.flags_unshaded = true
	highlight_material.albedo_color = Color.CYAN
	highlight_material.flags_transparent = true
	highlight_material.albedo_color.a = 0.3
	highlight_material.grow_amount = 0.1

func find_active_camera() -> void:
	"""Find the active camera in the scene"""
	var cameras = get_tree().get_nodes_in_group("cameras")
	if cameras.size() > 0:
		camera = cameras[0]
	else:
		camera = get_viewport().get_camera_3d()
	
	if camera:
		print("📷 Debug click handler connected to camera: %s" % camera.name)

# ===== INPUT HANDLING =====

func _input(event: InputEvent) -> void:
	if not debug_mode or not click_to_inspect:
		return
	
	# Handle mouse clicks
	if event is InputEventMouseButton:
		handle_mouse_click(event)
	
	# Handle mouse movement for highlighting
	elif event is InputEventMouseMotion:
		handle_mouse_hover(event)
	
	# Handle keyboard shortcuts
	elif event is InputEventKey and event.pressed:
		handle_debug_shortcuts(event)

func handle_mouse_click(event: InputEventMouseButton) -> void:
	"""Handle mouse click for inspection"""
	if not event.pressed:
		return
	
	# Right click or Ctrl+Left click for inspection
	if event.button_index == MOUSE_BUTTON_RIGHT or (event.button_index == MOUSE_BUTTON_LEFT and event.ctrl_pressed):
		var clicked_object = get_object_under_mouse(event.position)
		if clicked_object:
			inspect_clicked_object(clicked_object, event.position)

func handle_mouse_hover(event: InputEventMouseMotion) -> void:
	"""Handle mouse hover for highlighting"""
	if not highlight_inspectable:
		return
	
	var hovered_object = get_object_under_mouse(event.position)
	
	if hovered_object != highlighted_object:
		# Remove old highlight
		remove_highlight()
		
		# Add new highlight
		if hovered_object and is_inspectable_object(hovered_object):
			highlight_object(hovered_object)
			show_inspection_cursor(event.position)
		else:
			hide_inspection_cursor()

func handle_debug_shortcuts(event: InputEventKey) -> void:
	"""Handle debug keyboard shortcuts"""
	match event.keycode:
		KEY_F12:  # Toggle debug mode
			if event.ctrl_pressed:
				toggle_debug_mode()
		KEY_ESCAPE:  # Close inspector
			if script_inspector and script_inspector.inspector_window and script_inspector.inspector_window.visible:
				script_inspector.hide_inspector()

# ===== OBJECT DETECTION =====

func get_object_under_mouse(mouse_pos: Vector2) -> Node:
	"""Get the object under mouse cursor using raycast"""
	if not camera:
		find_active_camera()
		if not camera:
			return null
	
	# Create raycast from camera through mouse position
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * raycast_length
	
	# Perform raycast
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 0xFFFFFFFF  # All layers
	
	var result = space_state.intersect_ray(query)
	
	if result:
		var collider = result.get("collider")
		if collider:
			# Find the root Universal Being or interesting object
			return find_inspectable_parent(collider)
	
	return null

func find_inspectable_parent(node: Node) -> Node:
	"""Find the inspectable parent of a node"""
	var current = node
	
	while current:
		if is_inspectable_object(current):
			return current
		current = current.get_parent()
	
	return null

func is_inspectable_object(object: Node) -> bool:
	"""Check if an object is worth inspecting"""
	if not object:
		return false
	
	# Universal Beings are always inspectable
	if object.has_method("pentagon_init"):
		return true
	
	# Chunks are inspectable
	if object.name.contains("Chunk"):
		return true
	
	# Objects with interesting scripts
	if object.get_script():
		return true
	
	# 3D objects with significant properties
	if object is Node3D and object.get_child_count() > 0:
		return true
	
	return false

# ===== VISUAL FEEDBACK =====

func highlight_object(object: Node) -> void:
	"""Highlight an object for inspection"""
	highlighted_object = object
	
	# Add visual highlight if it's a 3D object
	if object is MeshInstance3D and highlight_material:
		# Store original material
		var original_material = object.material_override
		
		# Apply highlight material
		object.material_override = highlight_material
		
		# Restore original material after a delay
		get_tree().create_timer(0.1).timeout.connect(func():
			if object and is_instance_valid(object):
				object.material_override = original_material
		)

func remove_highlight() -> void:
	"""Remove highlight from previously highlighted object"""
	highlighted_object = null

func show_inspection_cursor(mouse_pos: Vector2) -> void:
	"""Show inspection cursor at mouse position"""
	if inspection_cursor:
		inspection_cursor.position = mouse_pos - inspection_cursor.size / 2
		inspection_cursor.visible = true

func hide_inspection_cursor() -> void:
	"""Hide inspection cursor"""
	if inspection_cursor:
		inspection_cursor.visible = false

# ===== INSPECTION INTERFACE =====

func inspect_clicked_object(object: Node, click_pos: Vector2) -> void:
	"""Inspect a clicked object"""
	print("🔍 Right-clicked on: %s" % object.name)
	
	# Emit signals
	var world_pos = Vector3.ZERO
	if object is Node3D:
		world_pos = object.global_position
	
	object_clicked.emit(object, world_pos)
	inspection_requested.emit(object)
	
	# Start inspection
	if script_inspector:
		script_inspector.inspect_object(object)
	
	# Update click hint
	if click_hint_label:
		click_hint_label.text = "🔍 Inspecting: %s" % object.name

func toggle_debug_mode() -> void:
	"""Toggle debug mode on/off"""
	debug_mode = !debug_mode
	
	if debug_mode:
		print("🔧 Debug mode enabled")
		if click_hint_label:
			click_hint_label.visible = true
	else:
		print("🔧 Debug mode disabled")
		if script_inspector:
			script_inspector.hide_inspector()
		if click_hint_label:
			click_hint_label.visible = false
		hide_inspection_cursor()

# ===== EVENT HANDLERS =====

func _on_variable_changed(object: Node, property: String, old_value, new_value) -> void:
	"""Handle variable change from inspector"""
	print("🔧 Variable changed: %s.%s = %s (was %s)" % [object.name, property, new_value, old_value])
	
	# Add visual feedback for the change
	show_change_feedback(object, property, new_value)

func _on_inspection_started(object: Node) -> void:
	"""Handle inspection start"""
	print("🔍 Started inspecting: %s" % object.name)
	
	if click_hint_label:
		click_hint_label.text = "🔍 Inspecting: %s (Right-click others to switch)" % object.name

func _on_inspection_ended(object: Node) -> void:
	"""Handle inspection end"""
	print("🔍 Stopped inspecting: %s" % object.name)
	
	if click_hint_label:
		click_hint_label.text = "🖱️ Right-click any Universal Being to inspect"

func show_change_feedback(object: Node, property: String, new_value) -> void:
	"""Show visual feedback when a variable changes"""
	# Create floating text showing the change
	if object is Node3D:
		create_floating_change_text(object, "%s = %s" % [property, str(new_value)])

func create_floating_change_text(object: Node3D, text: String) -> void:
	"""Create floating text above object showing change"""
	var label_3d = Label3D.new()
	label_3d.text = text
	label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_3d.modulate = Color.YELLOW
	label_3d.position = Vector3(0, 2, 0)
	
	object.add_child(label_3d)
	
	# Animate and remove
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(label_3d, "position:y", 4.0, 2.0)
	tween.parallel().tween_property(label_3d, "modulate:a", 0.0, 2.0)
	tween.tween_callback(label_3d.queue_free)

# ===== UTILITY FUNCTIONS =====

func get_inspectable_objects() -> Array[Node]:
	"""Get all currently inspectable objects in scene"""
	var objects = []
	
	var all_nodes = get_tree().get_nodes_in_group("universal_beings")
	for node in all_nodes:
		if is_inspectable_object(node):
			objects.append(node)
	
	return objects

func print_debug_status() -> void:
	"""Print current debug status"""
	print("🔧 Debug Status:")
	print("  Debug Mode: %s" % debug_mode)
	print("  Click to Inspect: %s" % click_to_inspect)
	print("  Show Hints: %s" % show_click_hints)
	print("  Highlight Objects: %s" % highlight_inspectable)
	print("  Inspector Active: %s" % (script_inspector and script_inspector.inspector_window and script_inspector.inspector_window.visible))
	print("  Inspectable Objects: %d" % get_inspectable_objects().size())