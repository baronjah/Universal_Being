# ==================================================
# SCRIPT NAME: advanced_inspector_integration.gd
# DESCRIPTION: Integrates advanced object inspector with console
# PURPOSE: Add advanced editing commands to console
# CREATED: 2025-05-28 - Console integration patch
# ==================================================

extends UniversalBeingBase
var console_manager: Node
var advanced_inspector: Control
var scene_editor: Node

func _ready() -> void:
	_setup_integration()

func _setup_integration() -> void:
	# Wait for console manager
	await get_tree().process_frame
	
	console_manager = get_node_or_null("/root/ConsoleManager")
	if not console_manager:
		print("[AdvancedInspectorIntegration] Console manager not found")
		return
	
	# Create advanced inspector
	_create_advanced_inspector()
	
	# Create scene editor integration
	_create_scene_editor()
	
	# Register enhanced commands
	_register_advanced_commands()
	
	print("[AdvancedInspectorIntegration] Advanced inspector integrated with console")

func _create_advanced_inspector() -> void:
	# Load and create advanced inspector
	if ResourceLoader.exists("res://scripts/ui/advanced_object_inspector.gd"):
		var AdvancedInspector = preload("res://scripts/ui/advanced_object_inspector.gd")
		advanced_inspector = AdvancedInspector.new()
		advanced_inspector.name = "AdvancedObjectInspector"
		
		# Add to root for proper display
		get_tree().FloodgateController.universal_add_child(advanced_inspector, get_tree().current_scene)
		advanced_inspector.z_index = 101  # Above regular inspector
		
		# Connect signals
		advanced_inspector.property_changed.connect(_on_property_changed)
		advanced_inspector.scene_save_requested.connect(_on_scene_save_requested)
		advanced_inspector.object_deleted.connect(_on_object_deleted)
		
		print("[AdvancedInspectorIntegration] Advanced inspector created")

func _create_scene_editor() -> void:
	# Load scene editor integration
	if ResourceLoader.exists("res://scripts/core/scene_editor_integration.gd"):
		var SceneEditor = preload("res://scripts/core/scene_editor_integration.gd")
		scene_editor = SceneEditor.new()
		scene_editor.name = "SceneEditorIntegration"
		add_child(scene_editor)
		
		print("[AdvancedInspectorIntegration] Scene editor integration created")

func _register_advanced_commands() -> void:
	if not console_manager or not console_manager.has_method("register_command"):
		return
	
	# Inspector commands
	console_manager.register_command("inspect", _cmd_inspect, "Open advanced inspector for object")
	console_manager.register_command("inspector", _cmd_inspector_control, "Control inspector (show/hide/pin)")
	console_manager.register_command("edit", _cmd_edit_property, "Edit object property directly")
	
	# Object selection commands
	console_manager.register_command("select", _cmd_select, "Select object(s) by name or type")
	console_manager.register_command("select_all", _cmd_select_all, "Select all objects in scene")
	console_manager.register_command("deselect", _cmd_deselect, "Deselect all objects")
	console_manager.register_command("selection", _cmd_show_selection, "Show current selection")
	
	# Transform shortcuts
	console_manager.register_command("pos", _cmd_set_position, "Set position of selected objects")
	console_manager.register_command("rot", _cmd_set_rotation, "Set rotation of selected objects")
	console_manager.register_command("scale", _cmd_set_scale, "Set scale of selected objects")
	
	# Scene shortcuts
	console_manager.register_command("save_scene", _cmd_save_scene, "Save current scene")
	console_manager.register_command("load_scene", _cmd_load_scene, "Load a scene file")
	
	print("[AdvancedInspectorIntegration] Registered advanced commands")

# ================================
# COMMAND IMPLEMENTATIONS
# ================================

func _cmd_inspect(args: Array) -> void:
	if args.size() == 0:
		console_manager._print_to_console("Usage: inspect <object_name>")
		console_manager._print_to_console("       inspect selected  (inspect first selected)")
		console_manager._print_to_console("       inspect mouse    (inspect under mouse)")
		return
	
	var target_name = args[0]
	var target_object: Node = null
	
	# Special cases
	if target_name == "selected":
		if scene_editor and scene_editor.selected_objects.size() > 0:
			target_object = scene_editor.selected_objects[0]
		else:
			console_manager._print_to_console("[color=yellow]No objects selected[/color]")
			return
	elif target_name == "mouse":
		target_object = _get_object_under_mouse()
		if not target_object:
			console_manager._print_to_console("[color=yellow]No object under mouse[/color]")
			return
	else:
		# Find by name
		target_object = _find_object_by_name(target_name)
		if not target_object:
			console_manager._print_to_console("[color=red]Object not found: " + target_name + "[/color]")
			return
	
	# Open advanced inspector
	if advanced_inspector:
		advanced_inspector.inspect_object(target_object)
		console_manager._print_to_console("[color=green]Inspecting: " + target_object.name + " [" + target_object.get_class() + "][/color]")
	else:
		console_manager._print_to_console("[color=red]Advanced inspector not available[/color]")

func _cmd_inspector_control(args: Array) -> void:
	if not advanced_inspector:
		console_manager._print_to_console("[color=red]Advanced inspector not available[/color]")
		return
	
	if args.size() == 0:
		var status = "visible" if advanced_inspector.visible else "hidden"
		var pinned = " (pinned)" if advanced_inspector.is_pinned else ""
		console_manager._print_to_console("Inspector is " + status + pinned)
		return
	
	match args[0]:
		"show":
			advanced_inspector.show()
			console_manager._print_to_console("Inspector shown")
		"hide":
			advanced_inspector.hide()
			console_manager._print_to_console("Inspector hidden")
		"toggle":
			advanced_inspector.visible = !advanced_inspector.visible
			var status = "shown" if advanced_inspector.visible else "hidden"
			console_manager._print_to_console("Inspector " + status)
		"pin":
			advanced_inspector.is_pinned = true
			advanced_inspector.pin_button.button_pressed = true
			console_manager._print_to_console("Inspector pinned")
		"unpin":
			advanced_inspector.is_pinned = false
			advanced_inspector.pin_button.button_pressed = false
			console_manager._print_to_console("Inspector unpinned")
		_:
			console_manager._print_to_console("Usage: inspector [show|hide|toggle|pin|unpin]")

func _cmd_edit_property(args: Array) -> void:
	if args.size() < 2:
		console_manager._print_to_console("Usage: edit <property> <value>")
		console_manager._print_to_console("Example: edit position 0,5,0")
		console_manager._print_to_console("         edit visible false")
		console_manager._print_to_console("         edit modulate 1,0,0,1")
		return
	
	if not scene_editor or scene_editor.selected_objects.is_empty():
		console_manager._print_to_console("[color=yellow]No objects selected[/color]")
		return
	
	var property_name = args[0]
	var value_str = args[1]
	
	# Parse the value
	var value = _parse_value(value_str)
	
	# Apply to all selected objects
	var success_count = 0
	for obj in scene_editor.selected_objects:
		if obj.has_method("set"):
			obj.set(property_name, value)
			success_count += 1
	
	console_manager._print_to_console("[color=green]Set " + property_name + " = " + str(value) + " on " + str(success_count) + " objects[/color]")
	
	# Update inspector if showing
	if advanced_inspector and advanced_inspector.visible and advanced_inspector.target_object in scene_editor.selected_objects:
		advanced_inspector._update_properties_tab()

func _cmd_select(args: Array) -> void:
	if args.size() == 0:
		console_manager._print_to_console("Usage: select <name_pattern>")
		console_manager._print_to_console("       select type:<class_name>")
		console_manager._print_to_console("       select group:<group_name>")
		return
	
	var pattern = args[0]
	var objects_found = []
	
	if pattern.begins_with("type:"):
		var type_name = pattern.substr(5)
		objects_found = _find_objects_by_type(type_name)
	elif pattern.begins_with("group:"):
		var group_name = pattern.substr(6)
		objects_found = get_tree().get_nodes_in_group(group_name)
	else:
		# Find by name pattern
		objects_found = _find_objects_by_pattern(pattern)
	
	if objects_found.is_empty():
		console_manager._print_to_console("[color=yellow]No objects found matching: " + pattern + "[/color]")
		return
	
	# Select found objects
	if scene_editor:
		scene_editor._deselect_all()
		for obj in objects_found:
			scene_editor._select_object(obj)
	
	console_manager._print_to_console("[color=green]Selected " + str(objects_found.size()) + " objects[/color]")

func _cmd_select_all(args: Array) -> void:
	if scene_editor:
		scene_editor._cmd_select_all(args)

func _cmd_deselect(args: Array) -> void:
	if scene_editor:
		scene_editor._cmd_deselect(args)

func _cmd_show_selection(_args: Array) -> void:
	if not scene_editor or scene_editor.selected_objects.is_empty():
		console_manager._print_to_console("No objects selected")
		return
	
	console_manager._print_to_console("[color=cyan]=== Current Selection (" + str(scene_editor.selected_objects.size()) + " objects) ===[/color]")
	for obj in scene_editor.selected_objects:
		var info = obj.name + " [" + obj.get_class() + "]"
		if obj is Node3D:
			info += " @ " + str(obj.position)
		console_manager._print_to_console("  • " + info)

func _cmd_set_position(args: Array) -> void:
	if args.size() < 3:
		console_manager._print_to_console("Usage: pos <x> <y> <z>")
		return
	
	if scene_editor:
		scene_editor._cmd_move(args)

func _cmd_set_rotation(args: Array) -> void:
	if args.size() < 3:
		console_manager._print_to_console("Usage: rot <x> <y> <z> (in degrees)")
		return
	
	if scene_editor:
		scene_editor._cmd_rotate(args)

func _cmd_set_scale(args: Array) -> void:
	if args.size() == 0:
		console_manager._print_to_console("Usage: scale <uniform> or scale <x> <y> <z>")
		return
	
	if scene_editor:
		scene_editor._cmd_scale(args)

func _cmd_save_scene(args: Array) -> void:
	if scene_editor:
		scene_editor._cmd_scene_save(args)

func _cmd_load_scene(args: Array) -> void:
	if scene_editor:
		scene_editor._cmd_scene_load(args)

# ================================
# HELPER FUNCTIONS
# ================================

func _find_object_by_name(object_name: String) -> Node:
	var root = get_tree().current_scene
	if not root:
		return null
	
	# Try exact match first
	var result = _find_node_recursive(root, object_name, true)
	if result:
		return result
	
	# Try partial match
	return _find_node_recursive(root, object_name, false)

func _find_node_recursive(node: Node, target_name: String, exact_match: bool) -> Node:
	if exact_match and node.name == target_name:
		return node
	elif not exact_match and node.name.to_lower().contains(target_name.to_lower()):
		return node
	
	for child in node.get_children():
		var found = _find_node_recursive(child, target_name, exact_match)
		if found:
			return found
	
	return null

func _find_objects_by_pattern(pattern: String) -> Array:
	var results = []
	var root = get_tree().current_scene
	if root:
		_collect_matching_nodes(root, pattern.to_lower(), results)
	return results

func _find_objects_by_type(type_name: String) -> Array:
	var results = []
	var root = get_tree().current_scene
	if root:
		_collect_nodes_by_type(root, type_name, results)
	return results

func _collect_matching_nodes(node: Node, pattern: String, results: Array) -> void:
	if node.name.to_lower().contains(pattern):
		results.append(node)
	
	for child in node.get_children():
		_collect_matching_nodes(child, pattern, results)

func _collect_nodes_by_type(node: Node, type_name: String, results: Array) -> void:
	if node.get_class() == type_name or node.is_class(type_name):
		results.append(node)
	
	for child in node.get_children():
		_collect_nodes_by_type(child, type_name, results)

func _get_object_under_mouse() -> Node:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return null
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		return result.collider
	
	return null

func _parse_value(value_str: String) -> Variant:
	# Boolean
	if value_str.to_lower() == "true":
		return true
	elif value_str.to_lower() == "false":
		return false
	
	# Numbers
	if value_str.is_valid_int():
		return int(value_str)
	elif value_str.is_valid_float():
		return float(value_str)
	
	# Vectors - handle comma-separated values
	var parts = value_str.split(",")
	if parts.size() == 2:
		# Vector2
		return Vector2(float(parts[0]), float(parts[1]))
	elif parts.size() == 3:
		# Vector3
		return Vector3(float(parts[0]), float(parts[1]), float(parts[2]))
	elif parts.size() == 4:
		# Color
		return Color(float(parts[0]), float(parts[1]), float(parts[2]), float(parts[3]))
	
	# String
	return value_str

# ================================
# SIGNAL HANDLERS
# ================================

func _on_property_changed(object: Node, property: String, value: Variant) -> void:
	console_manager._print_to_console("[color=green]Property changed: " + object.name + "." + property + " = " + str(value) + "[/color]")

func _on_scene_save_requested(_scene_data: Dictionary) -> void:
	console_manager._print_to_console("[color=cyan]Scene save requested[/color]")

func _on_object_deleted(object: Node) -> void:
	console_manager._print_to_console("[color=yellow]Object deleted: " + object.name + "[/color]")

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

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
