# 🏛️ Universal Being Scene Container - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: universal_being_scene_container.gd
# DESCRIPTION: Universal Being that acts as 3D spatial container for scenes
# PURPOSE: Create rooms, spaces with connection points for organized scene building
# ==================================================

extends UniversalBeingBase
class_name UniversalBeingSceneContainer

# Scene container properties
@export var container_size: Vector3 = Vector3(10, 5, 10)
@export var container_type: String = "room"
@export var show_boundaries: bool = true
@export var show_connection_points: bool = true

# Spatial organization
var center_point: Vector3
var corner_points: Array[Vector3] = []
var edge_points: Array[Vector3] = []
var side_points: Array[Vector3] = []
var connection_points: Array[Dictionary] = []

# Container contents
var contained_beings: Array[UniversalBeing] = []
var connections: Array[Dictionary] = []

# Visual elements
var boundary_lines: Node3D
var connection_visualizers: Node3D
var grid_overlay: Node3D

signal being_added_to_container(being: UniversalBeing, position: Vector3)
signal being_removed_from_container(being: UniversalBeing)
signal connection_point_created(point_data: Dictionary)
signal containers_connected(container_a: UniversalBeingSceneContainer, container_b: UniversalBeingSceneContainer)

func _ready() -> void:
	name = "SceneContainer_" + container_type
	_initialize_spatial_points()
	_create_visual_elements()
	_setup_interaction_area()

func _initialize_spatial_points() -> void:
	"""Calculate all spatial reference points for the container"""
	
	# Center point
	center_point = Vector3.ZERO
	
	# Corner points (8 corners of the container box)
	corner_points = [
		Vector3(-container_size.x/2, -container_size.y/2, -container_size.z/2),  # Bottom-back-left
		Vector3(container_size.x/2, -container_size.y/2, -container_size.z/2),   # Bottom-back-right
		Vector3(-container_size.x/2, container_size.y/2, -container_size.z/2),   # Top-back-left
		Vector3(container_size.x/2, container_size.y/2, -container_size.z/2),    # Top-back-right
		Vector3(-container_size.x/2, -container_size.y/2, container_size.z/2),   # Bottom-front-left
		Vector3(container_size.x/2, -container_size.y/2, container_size.z/2),    # Bottom-front-right
		Vector3(-container_size.x/2, container_size.y/2, container_size.z/2),    # Top-front-left
		Vector3(container_size.x/2, container_size.y/2, container_size.z/2)      # Top-front-right
	]
	
	# Side center points (6 faces)
	side_points = [
		Vector3(0, 0, -container_size.z/2),           # Back face center
		Vector3(0, 0, container_size.z/2),            # Front face center
		Vector3(-container_size.x/2, 0, 0),           # Left face center
		Vector3(container_size.x/2, 0, 0),            # Right face center
		Vector3(0, -container_size.y/2, 0),           # Bottom face center
		Vector3(0, container_size.y/2, 0)             # Top face center
	]
	
	# Edge midpoints (12 edges)
	edge_points = [
		# Bottom edges
		Vector3(0, -container_size.y/2, -container_size.z/2),
		Vector3(0, -container_size.y/2, container_size.z/2),
		Vector3(-container_size.x/2, -container_size.y/2, 0),
		Vector3(container_size.x/2, -container_size.y/2, 0),
		# Top edges
		Vector3(0, container_size.y/2, -container_size.z/2),
		Vector3(0, container_size.y/2, container_size.z/2),
		Vector3(-container_size.x/2, container_size.y/2, 0),
		Vector3(container_size.x/2, container_size.y/2, 0),
		# Vertical edges
		Vector3(-container_size.x/2, 0, -container_size.z/2),
		Vector3(container_size.x/2, 0, -container_size.z/2),
		Vector3(-container_size.x/2, 0, container_size.z/2),
		Vector3(container_size.x/2, 0, container_size.z/2)
	]
	
	print("[SceneContainer] Initialized ", container_type, " with ", corner_points.size(), " corners, ", side_points.size(), " sides, ", edge_points.size(), " edges")

func _create_visual_elements() -> void:
	"""Create visual representation of container boundaries and points"""
	
	# Boundary lines container
	boundary_lines = Node3D.new()
	boundary_lines.name = "BoundaryLines"
	add_child(boundary_lines)
	
	# Connection points container
	connection_visualizers = Node3D.new()
	connection_visualizers.name = "ConnectionVisualizers"
	add_child(connection_visualizers)
	
	# Grid overlay container
	grid_overlay = Node3D.new()
	grid_overlay.name = "GridOverlay"
	add_child(grid_overlay)
	
	if show_boundaries:
		_create_boundary_visualization()
	
	if show_connection_points:
		_create_connection_point_visualization()

func _create_boundary_visualization() -> void:
	"""Create wireframe visualization of container boundaries"""
	
	# Create boundary box using MeshInstance3D with wireframe
	var boundary_mesh = MeshInstance3D.new()
	boundary_mesh.name = "BoundaryBox"
	
	var box_mesh = BoxMesh.new()
	box_mesh.size = container_size
	boundary_mesh.mesh = box_mesh
	
	# Wireframe material
	var boundary_material = MaterialLibrary.get_material("default")
	boundary_material.flags_unshaded = true
	boundary_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	boundary_material.flags_transparent = true
	boundary_material.albedo_color = Color(0.5, 0.8, 1.0, 0.3)  # Light blue with transparency
	boundary_material.flags_do_not_receive_shadows = true
	boundary_material.flags_disable_ambient_light = true
	boundary_material.wireframe = true
	
	boundary_mesh.material_override = boundary_material
	FloodgateController.universal_add_child(boundary_mesh, boundary_lines)
	
	# Add corner markers
	for i in corner_points.size():
		var corner_marker = _create_point_marker(corner_points[i], Color.RED, 0.1, "Corner_" + str(i))
		FloodgateController.universal_add_child(corner_marker, boundary_lines)
	
	# Add side markers
	for i in side_points.size():
		var side_marker = _create_point_marker(side_points[i], Color.GREEN, 0.15, "Side_" + str(i))
		FloodgateController.universal_add_child(side_marker, boundary_lines)

func _create_connection_point_visualization() -> void:
	"""Create visual markers for potential connection points"""
	
	# Default connection points at side centers (doors, windows, etc.)
	var connection_types = ["door", "window", "portal", "vent", "passage", "stairs"]
	
	for i in side_points.size():
		var connection_data = {
			"position": side_points[i],
			"type": "potential",
			"connection_type": connection_types[i % connection_types.size()],
			"direction": _get_face_normal(i),
			"size": Vector2(1.0, 2.0),
			"available": true
		}
		
		connection_points.append(connection_data)
		var visualizer = _create_connection_point_visualizer(connection_data, i)
		FloodgateController.universal_add_child(visualizer, connection_visualizers)

func _create_point_marker(marker_position: Vector3, color: Color, size: float, marker_name: String) -> Node3D:
	"""Create a small sphere marker at a specific point"""
	
	var marker = Node3D.new()
	marker.name = marker_name
	marker.position = marker_position
	
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = size
	sphere_mesh.height = size * 2
	mesh_instance.mesh = sphere_mesh
	
	var material = MaterialLibrary.get_material("default")
	material.flags_unshaded = true
	material.emission_enabled = true
	material.emission = color
	material.albedo_color = color
	
	mesh_instance.material_override = material
	FloodgateController.universal_add_child(mesh_instance, marker)
	
	return marker

func _create_connection_point_visualizer(connection_data: Dictionary, index: int) -> Node3D:
	"""Create visualization for a connection point"""
	
	var visualizer = Node3D.new()
	visualizer.name = "ConnectionPoint_" + str(index)
	visualizer.position = connection_data.position
	
	# Connection point mesh
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.3, 0.3, 0.1)
	mesh_instance.mesh = box_mesh
	
	# Material based on connection type
	var material = MaterialLibrary.get_material("default")
	material.flags_unshaded = true
	material.emission_enabled = true
	
	match connection_data.connection_type:
		"door":
			material.emission = Color.BLUE
			material.albedo_color = Color.BLUE
		"window":
			material.emission = Color.YELLOW
			material.albedo_color = Color.YELLOW
		"portal":
			material.emission = Color.PURPLE
			material.albedo_color = Color.PURPLE
		"stairs":
			material.emission = Color.GREEN
			material.albedo_color = Color.GREEN
		_:
			material.emission = Color.CYAN
			material.albedo_color = Color.CYAN
	
	mesh_instance.material_override = material
	FloodgateController.universal_add_child(mesh_instance, visualizer)
	
	# Add text label
	var label = Label3D.new()
	label.text = connection_data.connection_type.capitalize()
	label.position = Vector3(0, 0, 0.2)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = material.emission
	FloodgateController.universal_add_child(label, visualizer)
	
	# Add interaction area
	var area = Area3D.new()
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(0.5, 0.5, 0.3)
	collision.shape = shape
	FloodgateController.universal_add_child(collision, area)
	FloodgateController.universal_add_child(area, visualizer)
	
	# Connect interaction
	area.input_event.connect(_on_connection_point_clicked.bind(connection_data, index))
	
	return visualizer

func _get_face_normal(side_index: int) -> Vector3:
	"""Get the normal vector for a face based on side index"""
	
	match side_index:
		0: return Vector3(0, 0, -1)  # Back
		1: return Vector3(0, 0, 1)   # Front
		2: return Vector3(-1, 0, 0)  # Left
		3: return Vector3(1, 0, 0)   # Right
		4: return Vector3(0, -1, 0)  # Bottom
		5: return Vector3(0, 1, 0)   # Top
		_: return Vector3(0, 0, 1)

func _setup_interaction_area() -> void:
	"""Setup area for detecting when beings enter/exit container"""
	
	var container_area = Area3D.new()
	container_area.name = "ContainerArea"
	
	var collision = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = container_size
	collision.shape = box_shape
	FloodgateController.universal_add_child(collision, container_area)
	
	add_child(container_area)
	
	# Connect area signals
	container_area.body_entered.connect(_on_being_entered_container)
	container_area.body_exited.connect(_on_being_exited_container)

# ===== UNIVERSAL BEING MANAGEMENT =====


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
func add_being_to_container(being: UniversalBeing, target_position: Vector3 = Vector3.ZERO) -> bool:
	"""Add a Universal Being to this container at specified position"""
	
	if not being:
		return false
	
	# Check if position is within bounds
	if not _is_position_within_bounds(target_position):
		print("[SceneContainer] Position ", target_position, " is outside container bounds")
		return false
	
	# Add to container
	being.reparent(self)
	being.position = target_position
	contained_beings.append(being)
	
	# Store container reference in being
	being.set_meta("container", self)
	being.set_meta("container_position", target_position)
	
	emit_signal("being_added_to_container", being, target_position)
	print("[SceneContainer] Added ", being.name, " to container at ", target_position)
	
	return true

func remove_being_from_container(being: UniversalBeing) -> bool:
	"""Remove a Universal Being from this container"""
	
	var index = contained_beings.find(being)
	if index == -1:
		return false
	
	contained_beings.remove_at(index)
	being.remove_meta("container")
	being.remove_meta("container_position")
	
	emit_signal("being_removed_from_container", being)
	print("[SceneContainer] Removed ", being.name, " from container")
	
	return true

func get_snap_position(world_position: Vector3) -> Vector3:
	"""Get closest snap position (center, corner, edge, side) for placement"""
	
	var local_position = to_local(world_position)
	var closest_position = center_point
	var min_distance = local_position.distance_to(center_point)
	
	# Check all snap points
	var all_snap_points = [center_point] + corner_points + side_points + edge_points
	
	for point in all_snap_points:
		var distance = local_position.distance_to(point)
		if distance < min_distance:
			min_distance = distance
			closest_position = point
	
	return closest_position

func _is_position_within_bounds(check_position: Vector3) -> bool:
	"""Check if position is within container bounds"""
	
	return (abs(check_position.x) <= container_size.x/2 and 
			abs(check_position.y) <= container_size.y/2 and 
			abs(check_position.z) <= container_size.z/2)

# ===== CONNECTION SYSTEM =====

func create_connection_point(point_position: Vector3, connection_type: String, properties: Dictionary = {}) -> Dictionary:
	"""Create a new connection point for linking to other containers"""
	
	var connection_data = {
		"id": connection_points.size(),
		"position": point_position,
		"type": "active",
		"connection_type": connection_type,
		"direction": properties.get("direction", Vector3.ZERO),
		"size": properties.get("size", Vector2(1.0, 2.0)),
		"available": true,
		"connected_to": null,
		"properties": properties
	}
	
	connection_points.append(connection_data)
	
	# Create visual representation
	var visualizer = _create_connection_point_visualizer(connection_data, connection_data.id)
	FloodgateController.universal_add_child(visualizer, connection_visualizers)
	
	emit_signal("connection_point_created", connection_data)
	print("[SceneContainer] Created connection point: ", connection_type, " at ", point_position)
	
	return connection_data

func connect_to_container(other_container: UniversalBeingSceneContainer, my_connection_id: int, other_connection_id: int) -> bool:
	"""Connect this container to another container via connection points"""
	
	if my_connection_id >= connection_points.size() or other_connection_id >= other_container.connection_points.size():
		print("[SceneContainer] Invalid connection point IDs")
		return false
	
	var my_connection = connection_points[my_connection_id]
	var other_connection = other_container.connection_points[other_connection_id]
	
	if not my_connection.available or not other_connection.available:
		print("[SceneContainer] Connection points not available")
		return false
	
	# Create connection data
	var connection = {
		"container_a": self,
		"container_b": other_container,
		"connection_a_id": my_connection_id,
		"connection_b_id": other_connection_id,
		"type": my_connection.connection_type,
		"established_at": Time.get_unix_time_from_system()
	}
	
	# Mark connection points as used
	my_connection.available = false
	my_connection.connected_to = other_container
	other_connection.available = false
	other_connection.connected_to = self
	
	# Store connection
	connections.append(connection)
	other_container.connections.append(connection)
	
	emit_signal("containers_connected", self, other_container)
	print("[SceneContainer] Connected ", name, " to ", other_container.name)
	
	return true

# ===== EVENT HANDLERS =====

func _on_being_entered_container(body: Node3D) -> void:
	"""Handle when a Universal Being enters the container area"""
	
	if body is UniversalBeing and body not in contained_beings:
		print("[SceneContainer] Being ", body.name, " entered container area")

func _on_being_exited_container(body: Node3D) -> void:
	"""Handle when a Universal Being exits the container area"""
	
	if body is UniversalBeing and body in contained_beings:
		print("[SceneContainer] Being ", body.name, " exited container area")

func _on_connection_point_clicked(connection_data: Dictionary, index: int, _camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	"""Handle clicks on connection points"""
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("[SceneContainer] Connection point clicked: ", connection_data.connection_type, " at index ", index)
		
		# TODO: Open connection interface or auto-connect to nearby containers

# ===== UTILITY FUNCTIONS =====

func get_available_connection_points() -> Array:
	"""Get all available connection points"""
	
	var available = []
	for connection in connection_points:
		if connection.available:
			available.append(connection)
	
	return available

func get_beings_near_position(target_position: Vector3, radius: float = 2.0) -> Array[UniversalBeing]:
	"""Get all beings within radius of target position"""
	
	var nearby_beings = []
	for being in contained_beings:
		if being.position.distance_to(target_position) <= radius:
			nearby_beings.append(being)
	
	return nearby_beings

func set_container_size(new_size: Vector3) -> void:
	"""Update container size and recalculate spatial points"""
	
	container_size = new_size
	_initialize_spatial_points()
	
	# Update visuals
	if boundary_lines:
		boundary_lines.queue_free()
	if connection_visualizers:
		connection_visualizers.queue_free()
	
	_create_visual_elements()

func get_container_info() -> Dictionary:
	"""Get complete information about this container"""
	
	return {
		"name": name,
		"type": container_type,
		"size": container_size,
		"position": global_position,
		"beings_count": contained_beings.size(),
		"connection_points_count": connection_points.size(),
		"available_connections": get_available_connection_points().size(),
		"connections_count": connections.size()
	}

# ===== CONSOLE INTEGRATION =====

func handle_console_command(command: String, args: Array) -> String:
	"""Handle console commands for container management"""
	
	match command:
		"container_info":
			var info = get_container_info()
			return "Container: " + str(info)
		
		"add_connection":
			if args.size() >= 3:
				var pos = Vector3(args[0].to_float(), args[1].to_float(), args[2].to_float())
				var type = args[3] if args.size() > 3 else "door"
				create_connection_point(pos, type)
				return "Created " + type + " connection point at " + str(pos)
			return "Usage: add_connection x y z [type]"
		
		"list_beings":
			var being_names = []
			for being in contained_beings:
				being_names.append(being.name)
			return "Beings in container: " + str(being_names)
		
		"snap_to":
			if args.size() >= 1:
				var being_name = args[0]
				for being in contained_beings:
					if being.name.contains(being_name):
						var snap_pos = get_snap_position(being.global_position)
						being.position = snap_pos
						return "Snapped " + being.name + " to " + str(snap_pos)
				return "Being not found: " + being_name
			return "Usage: snap_to <being_name>"
		
		"resize":
			if args.size() >= 3:
				var new_size = Vector3(args[0].to_float(), args[1].to_float(), args[2].to_float())
				set_container_size(new_size)
				return "Resized container to " + str(new_size)
			return "Usage: resize x y z"
		
		_:
			return "Unknown container command: " + command
