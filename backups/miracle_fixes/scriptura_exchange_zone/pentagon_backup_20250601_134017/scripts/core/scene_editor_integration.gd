# ==================================================
# SCRIPT NAME: scene_editor_integration.gd
# DESCRIPTION: Integrates advanced object inspector with scene management
# PURPOSE: Bridge between inspector, floodgate, and scene systems
# CREATED: 2025-05-28 - Scene editing integration
# ==================================================

extends UniversalBeingBase
signal scene_modified(changes: Array)
signal object_selected(object: Node)
signal edit_mode_changed(mode: String)

# Edit modes
enum EditMode {
	SELECT,
	TRANSLATE,
	ROTATE,
	SCALE,
	CREATE,
	DELETE
}

# References
var floodgate_controller: Node
var scene_manager: Node
var object_inspector: Control
var console_manager: Node

# State
var current_edit_mode: EditMode = EditMode.SELECT
var selected_objects: Array = []
var scene_changes: Array = []  # Track all changes for save
var is_editing: bool = false
var grid_snap_enabled: bool = false
var grid_size: float = 1.0

# Gizmo settings
var show_gizmos: bool = true
var gizmo_size: float = 1.0
var gizmo_alpha: float = 0.8

# Scene data
var original_scene_state: Dictionary = {}
var current_scene_path: String = ""

func _ready() -> void:
	_setup_references()
	_register_console_commands()
	print("[SceneEditorIntegration] Scene editor integration ready")

func _setup_references() -> void:
	# Get autoload references
	floodgate_controller = get_node_or_null("/root/FloodgateController")
	console_manager = get_node_or_null("/root/ConsoleManager")
	
	# Get scene manager
	scene_manager = get_node_or_null("/root/UnifiedSceneManager")
	if not scene_manager:
		scene_manager = get_node_or_null("/root/SceneManager")

func _register_console_commands() -> void:
	if not console_manager:
		return
	
	# Scene editing commands
	console_manager.register_command("scene_edit", _cmd_scene_edit, "Enable/disable scene editing mode")
	console_manager.register_command("scene_save", _cmd_scene_save, "Save current scene with all changes")
	console_manager.register_command("scene_load", _cmd_scene_load, "Load a scene file for editing")
	console_manager.register_command("scene_new", _cmd_scene_new, "Create a new empty scene")
	console_manager.register_command("scene_export", _cmd_scene_export, "Export scene as various formats")
	
	# Object manipulation
	console_manager.register_command("select", _cmd_select, "Select object by name or path")
	console_manager.register_command("select_all", _cmd_select_all, "Select all objects in scene")
	console_manager.register_command("deselect", _cmd_deselect, "Deselect all objects")
	console_manager.register_command("delete_selected", _cmd_delete_selected, "Delete selected objects")
	console_manager.register_command("duplicate_selected", _cmd_duplicate_selected, "Duplicate selected objects")
	
	# Transform commands
	console_manager.register_command("move", _cmd_move, "Move selected objects by vector")
	console_manager.register_command("rotate", _cmd_rotate, "Rotate selected objects by degrees")
	console_manager.register_command("scale", _cmd_scale, "Scale selected objects by factor")
	console_manager.register_command("reset_transform", _cmd_reset_transform, "Reset transform of selected objects")
	
	# Creation commands
	console_manager.register_command("create_node", _cmd_create_node, "Create a new node of type")
	console_manager.register_command("create_mesh", _cmd_create_mesh, "Create a mesh instance")
	console_manager.register_command("create_light", _cmd_create_light, "Create a light source")
	console_manager.register_command("create_camera", _cmd_create_camera, "Create a camera")
	
	# Inspector commands
	console_manager.register_command("inspect", _cmd_inspect, "Open inspector for object")
	console_manager.register_command("set_property", _cmd_set_property, "Set property on selected objects")
	console_manager.register_command("get_property", _cmd_get_property, "Get property from selected object")
	
	# Grid and snapping
	console_manager.register_command("grid", _cmd_grid, "Toggle grid snapping")
	console_manager.register_command("grid_size", _cmd_grid_size, "Set grid size")
	console_manager.register_command("snap_to_grid", _cmd_snap_to_grid, "Snap selected to grid")

# ================================
# SCENE EDITING COMMANDS
# ================================

func _cmd_scene_edit(args: Array) -> void:
	if args.size() == 0:
		is_editing = !is_editing
	else:
		is_editing = args[0] == "on" or args[0] == "true" or args[0] == "1"
	
	if is_editing:
		_enter_edit_mode()
		print("Scene editing mode: ENABLED")
	else:
		_exit_edit_mode()
		print("Scene editing mode: DISABLED")

func _cmd_scene_save(args: Array) -> void:
	if args.size() == 0:
		if current_scene_path == "":
			print("Error: No scene path. Use 'scene_save <path>' or load a scene first")
			return
		_save_scene(current_scene_path)
	else:
		var path = args[0]
		if not path.ends_with(".tscn") and not path.ends_with(".scn"):
			path += ".tscn"
		_save_scene(path)

func _cmd_scene_load(args: Array) -> void:
	if args.size() == 0:
		print("Usage: scene_load <path>")
		return
	
	var path = args[0]
	_load_scene_for_editing(path)

func _cmd_scene_new(_args: Array) -> void:
	_create_new_scene()
	print("Created new empty scene")

func _cmd_scene_export(args: Array) -> void:
	if args.size() == 0:
		print("Usage: scene_export <format> [path]")
		print("Formats: gltf, obj, dae")
		return
	
	var format = args[0]
	var path = args[1] if args.size() > 1 else "exported_scene." + format
	_export_scene(format, path)

# ================================
# OBJECT MANIPULATION COMMANDS
# ================================

func _cmd_select(args: Array) -> void:
	if args.size() == 0:
		print("Usage: select <object_name_or_path>")
		return
	
	var target_name = args[0]
	var node = _find_node_by_name(target_name)
	
	if node:
		_select_object(node)
		print("Selected: " + node.name)
	else:
		print("Object not found: " + target_name)

func _cmd_select_all(_args: Array) -> void:
	var root = get_tree().current_scene
	if root:
		_select_all_children(root)
		print("Selected " + str(selected_objects.size()) + " objects")

func _cmd_deselect(_args: Array) -> void:
	_deselect_all()
	print("Deselected all objects")

func _cmd_delete_selected(_args: Array) -> void:
	if selected_objects.is_empty():
		print("No objects selected")
		return
	
	var count = selected_objects.size()
	for obj in selected_objects:
		_queue_delete_operation(obj)
	
	selected_objects.clear()
	print("Deleted " + str(count) + " objects")

func _cmd_duplicate_selected(_args: Array) -> void:
	if selected_objects.is_empty():
		print("No objects selected")
		return
	
	var duplicates = []
	for obj in selected_objects:
		var dup = _queue_duplicate_operation(obj)
		if dup:
			duplicates.append(dup)
	
	# Select the duplicates
	_deselect_all()
	for dup in duplicates:
		_select_object(dup)
	
	print("Duplicated " + str(duplicates.size()) + " objects")

# ================================
# TRANSFORM COMMANDS
# ================================

func _cmd_move(args: Array) -> void:
	if selected_objects.is_empty():
		print("No objects selected")
		return
	
	if args.size() < 3:
		print("Usage: move <x> <y> <z>")
		return
	
	var offset = Vector3(float(args[0]), float(args[1]), float(args[2]))
	
	for obj in selected_objects:
		if obj is Node3D:
			_queue_move_operation(obj, obj.position + offset)
	
	print("Moved " + str(selected_objects.size()) + " objects by " + str(offset))

func _cmd_rotate(args: Array) -> void:
	if selected_objects.is_empty():
		print("No objects selected")
		return
	
	if args.size() < 3:
		print("Usage: rotate <x_deg> <y_deg> <z_deg>")
		return
	
	var rotation_deg = Vector3(float(args[0]), float(args[1]), float(args[2]))
	var rotation_rad = rotation_deg * (PI / 180.0)
	
	for obj in selected_objects:
		if obj is Node3D:
			_queue_rotate_operation(obj, obj.rotation + rotation_rad)
	
	print("Rotated " + str(selected_objects.size()) + " objects by " + str(rotation_deg) + " degrees")

func _cmd_scale(args: Array) -> void:
	if selected_objects.is_empty():
		print("No objects selected")
		return
	
	var scale_factor: Vector3
	if args.size() == 1:
		var uniform = float(args[0])
		scale_factor = Vector3(uniform, uniform, uniform)
	elif args.size() >= 3:
		scale_factor = Vector3(float(args[0]), float(args[1]), float(args[2]))
	else:
		print("Usage: scale <factor> or scale <x> <y> <z>")
		return
	
	for obj in selected_objects:
		if obj is Node3D:
			_queue_scale_operation(obj, obj.scale * scale_factor)
	
	print("Scaled " + str(selected_objects.size()) + " objects by " + str(scale_factor))

func _cmd_reset_transform(_args: Array) -> void:
	if selected_objects.is_empty():
		print("No objects selected")
		return
	
	for obj in selected_objects:
		if obj is Node3D:
			_queue_move_operation(obj, Vector3.ZERO)
			_queue_rotate_operation(obj, Vector3.ZERO)
			_queue_scale_operation(obj, Vector3.ONE)
	
	print("Reset transform for " + str(selected_objects.size()) + " objects")

# ================================
# CREATION COMMANDS
# ================================

func _cmd_create_node(args: Array) -> void:
	if args.size() == 0:
		print("Usage: create_node <type> [name]")
		print("Types: Node3D, MeshInstance3D, CollisionShape3D, Area3D, RigidBody3D, etc.")
		return
	
	var node_type = args[0]
	var node_name = args[1] if args.size() > 1 else node_type
	
	var new_node = _create_node_of_type(node_type)
	if new_node:
		new_node.name = node_name
		_queue_add_node_operation(new_node)
		_select_object(new_node)
		print("Created " + node_type + ": " + node_name)
	else:
		print("Unknown node type: " + node_type)

func _cmd_create_mesh(args: Array) -> void:
	var mesh_type = args[0] if args.size() > 0 else "box"
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "Mesh_" + mesh_type
	
	match mesh_type.to_lower():
		"box", "cube":
			mesh_instance.mesh = BoxMesh.new()
		"sphere":
			mesh_instance.mesh = SphereMesh.new()
		"cylinder":
			mesh_instance.mesh = CylinderMesh.new()
		"plane":
			mesh_instance.mesh = PlaneMesh.new()
		"torus":
			mesh_instance.mesh = TorusMesh.new()
		"prism":
			mesh_instance.mesh = PrismMesh.new()
		_:
			print("Unknown mesh type: " + mesh_type)
			print("Available: box, sphere, cylinder, plane, torus, prism")
			return
	
	_queue_add_node_operation(mesh_instance)
	_select_object(mesh_instance)
	print("Created " + mesh_type + " mesh")

func _cmd_create_light(args: Array) -> void:
	var light_type = args[0] if args.size() > 0 else "omni"
	var light_node: Light3D
	
	match light_type.to_lower():
		"directional", "sun":
			light_node = DirectionalLight3D.new()
		"spot":
			light_node = SpotLight3D.new()
		"omni", "point":
			light_node = OmniLight3D.new()
		_:
			print("Unknown light type: " + light_type)
			print("Available: directional, spot, omni")
			return
	
	light_node.name = "Light_" + light_type
	_queue_add_node_operation(light_node)
	_select_object(light_node)
	print("Created " + light_type + " light")

func _cmd_create_camera(_args: Array) -> void:
	var camera = Camera3D.new()
	camera.name = "Camera" + str(get_tree().get_nodes_in_group("cameras").size() + 1)
	camera.position = Vector3(0, 2, 5)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	
	_queue_add_node_operation(camera)
	_select_object(camera)
	print("Created camera: " + camera.name)

# ================================
# PROPERTY COMMANDS
# ================================

func _cmd_inspect(args: Array) -> void:
	var target: Node
	
	if args.size() > 0:
		target = _find_node_by_name(args[0])
	elif selected_objects.size() > 0:
		target = selected_objects[0]
	else:
		print("Usage: inspect [object_name] or select an object first")
		return
	
	if target:
		_open_inspector_for_object(target)
		print("Inspecting: " + target.name)
	else:
		print("Object not found")

func _cmd_set_property(args: Array) -> void:
	if args.size() < 2:
		print("Usage: set_property <property_name> <value>")
		return
	
	if selected_objects.is_empty():
		print("No objects selected")
		return
	
	var prop_name = args[0]
	var value_str = args[1]
	
	# Parse value based on content
	var value = _parse_property_value(value_str)
	
	var success_count = 0
	for obj in selected_objects:
		if obj.has_method("set"):
			obj.set(prop_name, value)
			success_count += 1
			_track_property_change(obj, prop_name, value)
	
	print("Set " + prop_name + " = " + str(value) + " on " + str(success_count) + " objects")

func _cmd_get_property(args: Array) -> void:
	if args.size() == 0:
		print("Usage: get_property <property_name>")
		return
	
	if selected_objects.is_empty():
		print("No objects selected")
		return
	
	var prop_name = args[0]
	var obj = selected_objects[0]
	
	if obj.has_method("get"):
		var value = obj.get(prop_name)
		print(obj.name + "." + prop_name + " = " + str(value))
	else:
		print("Property not found: " + prop_name)

# ================================
# GRID COMMANDS
# ================================

func _cmd_grid(args: Array) -> void:
	if args.size() == 0:
		grid_snap_enabled = !grid_snap_enabled
	else:
		grid_snap_enabled = args[0] == "on" or args[0] == "true" or args[0] == "1"
	
	print("Grid snapping: " + ("ENABLED" if grid_snap_enabled else "DISABLED"))

func _cmd_grid_size(args: Array) -> void:
	if args.size() == 0:
		print("Current grid size: " + str(grid_size))
		return
	
	grid_size = float(args[0])
	print("Grid size set to: " + str(grid_size))

func _cmd_snap_to_grid(_args: Array) -> void:
	if selected_objects.is_empty():
		print("No objects selected")
		return
	
	var snapped_count = 0
	for obj in selected_objects:
		if obj is Node3D:
			var snapped_pos = _snap_to_grid_position(obj.position)
			if snapped_pos != obj.position:
				_queue_move_operation(obj, snapped_pos)
				snapped_count += 1
	
	print("Snapped " + str(snapped_count) + " objects to grid")

# ================================
# SCENE MANAGEMENT
# ================================

func _enter_edit_mode() -> void:
	is_editing = true
	
	# Store original scene state
	_capture_scene_state()
	
	# Enable visual helpers
	_enable_edit_visuals()
	
	# Start tracking changes
	scene_changes.clear()
	
	edit_mode_changed.emit("edit")

func _exit_edit_mode() -> void:
	is_editing = false
	
	# Disable visual helpers
	_disable_edit_visuals()
	
	# Optionally prompt to save changes
	if scene_changes.size() > 0:
		print("You have " + str(scene_changes.size()) + " unsaved changes")
	
	edit_mode_changed.emit("normal")

func _save_scene(path: String) -> void:
	var root = get_tree().current_scene
	if not root:
		print("Error: No scene to save")
		return
	
	# Create packed scene
	var packed_scene = PackedScene.new()
	var result = packed_scene.pack(root)
	
	if result == OK:
		var error = ResourceSaver.save(packed_scene, path)
		if error == OK:
			current_scene_path = path
			scene_changes.clear()
			print("Scene saved to: " + path)
		else:
			print("Error saving scene: " + str(error))
	else:
		print("Error packing scene: " + str(result))

func _load_scene_for_editing(path: String) -> void:
	if not ResourceLoader.exists(path):
		print("Error: Scene file not found: " + path)
		return
	
	# Load the scene
	var packed_scene = load(path) as PackedScene
	if not packed_scene:
		print("Error: Failed to load scene: " + path)
		return
	
	# Clear current scene
	var current = get_tree().current_scene
	if current:
		current.queue_free()
	
	# Instance new scene
	var new_scene = packed_scene.instantiate()
	get_tree().FloodgateController.universal_add_child(new_scene, get_tree().current_scene)
	get_tree().current_scene = new_scene
	
	current_scene_path = path
	scene_changes.clear()
	
	print("Loaded scene: " + path)
	
	# Enter edit mode automatically
	_enter_edit_mode()

func _create_new_scene() -> void:
	# Clear current scene
	var current = get_tree().current_scene
	if current:
		current.queue_free()
	
	# Create new root
	var new_root = Node3D.new()
	new_root.name = "Scene"
	get_tree().FloodgateController.universal_add_child(new_root, get_tree().current_scene)
	get_tree().current_scene = new_root
	
	# Add default ground
	var ground = MeshInstance3D.new()
	ground.name = "Ground"
	ground.mesh = PlaneMesh.new()
	ground.mesh.size = Vector2(20, 20)
	FloodgateController.universal_add_child(ground, new_root)
	
	# Add default light
	var light = DirectionalLight3D.new()
	light.name = "Sun"
	light.rotation_degrees = Vector3(-45, -45, 0)
	FloodgateController.universal_add_child(light, new_root)
	
	current_scene_path = ""
	scene_changes.clear()
	
	# Enter edit mode
	_enter_edit_mode()

func _export_scene(format: String, _path: String) -> void:
	# TODO: Implement scene export to various formats
	print("Scene export not yet implemented for format: " + format)

# ================================
# FLOODGATE OPERATIONS
# ================================

func _queue_add_node_operation(node: Node) -> void:
	if not floodgate_controller:
		# Direct add if no floodgate
		var parent = selected_objects[0].get_parent() if selected_objects.size() > 0 else get_tree().current_scene
		FloodgateController.universal_add_child(node, parent)
		return
	
	var operation = {
		"type": FloodgateController.OperationType.CREATE_NODE,
		"node": node,
		"parent": selected_objects[0].get_parent() if selected_objects.size() > 0 else get_tree().current_scene
	}
	
	floodgate_controller.queue_operation(operation)
	_track_scene_change("add_node", node)

func _queue_delete_operation(node: Node) -> void:
	if not floodgate_controller:
		node.queue_free()
		return
	
	var operation = {
		"type": FloodgateController.OperationType.DELETE_NODE,
		"node": node
	}
	
	floodgate_controller.queue_operation(operation)
	_track_scene_change("delete_node", node)

func _queue_move_operation(node: Node3D, new_position: Vector3) -> void:
	if grid_snap_enabled:
		new_position = _snap_to_grid_position(new_position)
	
	if not floodgate_controller:
		node.position = new_position
		return
	
	var operation = {
		"type": FloodgateController.OperationType.MOVE_NODE,
		"node": node,
		"position": new_position
	}
	
	floodgate_controller.queue_operation(operation)
	_track_scene_change("move", node, {"position": new_position})

func _queue_rotate_operation(node: Node3D, new_rotation: Vector3) -> void:
	if not floodgate_controller:
		node.rotation = new_rotation
		return
	
	var operation = {
		"type": FloodgateController.OperationType.ROTATE_NODE,
		"node": node,
		"rotation": new_rotation
	}
	
	floodgate_controller.queue_operation(operation)
	_track_scene_change("rotate", node, {"rotation": new_rotation})

func _queue_scale_operation(node: Node3D, new_scale: Vector3) -> void:
	if not floodgate_controller:
		node.scale = new_scale
		return
	
	var operation = {
		"type": FloodgateController.OperationType.SCALE_NODE,
		"node": node,
		"scale": new_scale
	}
	
	floodgate_controller.queue_operation(operation)
	_track_scene_change("scale", node, {"scale": new_scale})

func _queue_duplicate_operation(node: Node) -> Node:
	var duplicated_node = node.duplicate()
	
	if duplicated_node is Node3D:
		# Offset position slightly
		duplicated_node.position += Vector3(1, 0, 1)
	
	_queue_add_node_operation(duplicated_node)
	return duplicated_node

# ================================
# HELPER FUNCTIONS
# ================================

func _find_node_by_name(target_name: String) -> Node:
	var root = get_tree().current_scene
	if not root:
		return null
	
	# Try direct path first
	var node = root.get_node_or_null(NodePath(target_name))
	if node:
		return node
	
	# Search by name
	return _find_node_recursive(root, target_name)

func _find_node_recursive(node: Node, search_name: String) -> Node:
	if node.name == search_name:
		return node
	
	for child in node.get_children():
		var found = _find_node_recursive(child, search_name)
		if found:
			return found
	
	return null

func _select_object(obj: Node) -> void:
	if not obj in selected_objects:
		selected_objects.append(obj)
		_highlight_object(obj, true)
		object_selected.emit(obj)

func _deselect_all() -> void:
	for obj in selected_objects:
		_highlight_object(obj, false)
	selected_objects.clear()

func _select_all_children(node: Node) -> void:
	if node != get_tree().current_scene:  # Don't select root
		_select_object(node)
	
	for child in node.get_children():
		_select_all_children(child)

func _highlight_object(obj: Node, highlight: bool) -> void:
	# Visual feedback for selection
	if obj.has_method("set_modulate"):
		obj.modulate = Color.YELLOW if highlight else Color.WHITE

func _create_node_of_type(type_name: String) -> Node:
	# Map common type names to Godot classes
	var type_map = {
		"node3d": "Node3D",
		"mesh": "MeshInstance3D",
		"collision": "CollisionShape3D",
		"area": "Area3D",
		"rigid": "RigidBody3D",
		"static": "StaticBody3D",
		"character": "CharacterBody3D",
		"path": "Path3D",
		"marker": "Marker3D"
	}
	
	var actual_type = type_map.get(type_name.to_lower(), type_name)
	
	# Try to create the node
	if ClassDB.class_exists(actual_type):
		return ClassDB.instantiate(actual_type)
	
	return null

func _parse_property_value(value_str: String) -> Variant:
	# Try to parse as different types
	if value_str.to_lower() == "true":
		return true
	elif value_str.to_lower() == "false":
		return false
	elif value_str.is_valid_int():
		return int(value_str)
	elif value_str.is_valid_float():
		return float(value_str)
	elif value_str.begins_with("Vector2(") or value_str.begins_with("(") and value_str.contains(","):
		# Parse Vector2
		var parts = value_str.strip_edges().trim_prefix("Vector2(").trim_suffix(")").split(",")
		if parts.size() >= 2:
			return Vector2(float(parts[0]), float(parts[1]))
	elif value_str.begins_with("Vector3(") or value_str.count(",") == 2:
		# Parse Vector3
		var parts = value_str.strip_edges().trim_prefix("Vector3(").trim_suffix(")").split(",")
		if parts.size() >= 3:
			return Vector3(float(parts[0]), float(parts[1]), float(parts[2]))
	elif value_str.begins_with("Color("):
		# Parse Color
		var parts = value_str.strip_edges().trim_prefix("Color(").trim_suffix(")").split(",")
		if parts.size() >= 3:
			return Color(float(parts[0]), float(parts[1]), float(parts[2]), float(parts[3]) if parts.size() > 3 else 1.0)
	
	# Default to string
	return value_str

func _snap_to_grid_position(pos: Vector3) -> Vector3:
	return Vector3(
		round(pos.x / grid_size) * grid_size,
		round(pos.y / grid_size) * grid_size,
		round(pos.z / grid_size) * grid_size
	)

func _capture_scene_state() -> void:
	original_scene_state.clear()
	var root = get_tree().current_scene
	if root:
		_capture_node_state(root, original_scene_state)

func _capture_node_state(node: Node, state_dict: Dictionary) -> void:
	var node_state = {}
	
	# Capture transform for Node3D
	if node is Node3D:
		node_state["position"] = node.position
		node_state["rotation"] = node.rotation
		node_state["scale"] = node.scale
	
	# Capture other important properties
	node_state["visible"] = node.visible if node.has_method("is_visible") else true
	node_state["name"] = node.name
	
	state_dict[node.get_path()] = node_state
	
	# Recurse to children
	for child in node.get_children():
		_capture_node_state(child, state_dict)

func _track_scene_change(change_type: String, node: Node, data: Dictionary = {}) -> void:
	var change = {
		"type": change_type,
		"node_path": node.get_path(),
		"node_name": node.name,
		"timestamp": Time.get_ticks_msec(),
		"data": data
	}
	
	scene_changes.append(change)
	scene_modified.emit(scene_changes)

func _track_property_change(node: Node, property: String, value: Variant) -> void:
	_track_scene_change("property", node, {"property": property, "value": value})

func _enable_edit_visuals() -> void:
	# TODO: Add visual grid, selection outlines, gizmos
	pass

func _disable_edit_visuals() -> void:
	# TODO: Remove edit visuals
	pass

func _open_inspector_for_object(obj: Node) -> void:
	# Try to find existing inspector
	var inspector = get_tree().get_nodes_in_group("object_inspectors")
	if inspector.size() > 0:
		object_inspector = inspector[0]
	
	# Create new inspector if needed
	if not object_inspector:
		var inspector_scene = load("res://scripts/ui/advanced_object_inspector.gd")
		if inspector_scene:
			object_inspector = inspector_scene.new()
			get_tree().FloodgateController.universal_add_child(object_inspector, get_tree().current_scene)
			object_inspector.add_to_group("object_inspectors")
	
	# Open inspector for object
	if object_inspector and object_inspector.has_method("inspect_object"):
		object_inspector.inspect_object(obj)

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