# ==================================================
# UNIVERSAL BEING: Cursor Controller
# TYPE: cursor
# PURPOSE: 3D cursor that follows mouse and can interact with sockets
# ==================================================

extends UniversalBeing
class_name CursorController

# ===== CURSOR PROPERTIES =====
@export var hover_distance: float = 10.0
@export var connection_distance: float = 1.0
@export var cursor_speed: float = 15.0

# References
var camera: Camera3D
var mesh_instance: MeshInstance3D
var area_3d: Area3D
var material: StandardMaterial3D

# Connection state
var hovering_socket: Marker3D = null
var selected_socket: Marker3D = null
var connection_line: MeshInstance3D = null

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	being_type = "cursor"
	being_name = "Cursor"
	consciousness_level = 2

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Find components
	mesh_instance = find_child("MeshInstance3D") as MeshInstance3D
	area_3d = find_child("Area3D", true) as Area3D
	
	# Set up material
	if mesh_instance and mesh_instance.mesh:
		material = StandardMaterial3D.new()
		material.albedo_color = Color.CYAN
		material.emission_enabled = true
		material.emission = Color.CYAN
		material.emission_energy = 0.3
		mesh_instance.material_override = material
	
	# Find camera in scene
	camera = get_viewport().get_camera_3d()
	
	# Create connection line renderer
	_create_connection_line()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	if not camera:
		camera = get_viewport().get_camera_3d()
		return
	
	# Cast ray from camera through mouse position
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * hover_distance
	
	# Perform raycast
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1
	var result = space_state.intersect_ray(query)
	
	# Position cursor
	if result:
		var target_pos = result.position
		global_position = global_position.lerp(target_pos, cursor_speed * delta)
	else:
		# Position at max distance
		global_position = global_position.lerp(to, cursor_speed * delta)
	
	# Check for nearby sockets
	_check_socket_proximity()
	
	# Update connection line
	_update_connection_line()
	
	# Update visual state
	_update_cursor_visual()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Handle socket connections
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_handle_socket_click()
		elif event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_connection()

func pentagon_sewers() -> void:
	if connection_line:
		connection_line.queue_free()
	super.pentagon_sewers()

# ===== SOCKET INTERACTION =====

func _check_socket_proximity() -> void:
	hovering_socket = null
	
	# Find all sockets in range
	var bodies = []
	for body in get_tree().get_nodes_in_group("sockets"):
		if body is Marker3D and body.has_meta("socket_type"):
			var distance = global_position.distance_to(body.global_position)
			if distance < connection_distance:
				hovering_socket = body
				break

func _handle_socket_click() -> void:
	if not hovering_socket:
		return
	
	if not selected_socket:
		# First click - select socket
		selected_socket = hovering_socket
		print("🔌 Selected socket: ", selected_socket.get_meta("socket_name"))
	else:
		# Second click - try to connect
		if _can_connect_sockets(selected_socket, hovering_socket):
			_connect_sockets(selected_socket, hovering_socket)
		selected_socket = null

func _can_connect_sockets(socket_a: Marker3D, socket_b: Marker3D) -> bool:
	if not socket_a or not socket_b:
		return false
	
	# Can't connect socket to itself
	if socket_a == socket_b:
		return false
	
	# Must be different types (input to output)
	var type_a = socket_a.get_meta("socket_type", "")
	var type_b = socket_b.get_meta("socket_type", "")
	
	return (type_a == "output" and type_b == "input") or (type_a == "input" and type_b == "output")

func _connect_sockets(socket_a: Marker3D, socket_b: Marker3D) -> void:
	var output_socket = socket_a if socket_a.get_meta("socket_type") == "output" else socket_b
	var input_socket = socket_a if socket_a.get_meta("socket_type") == "input" else socket_b
	
	var output_being = _find_parent_being(output_socket)
	var input_being = _find_parent_being(input_socket)
	
	if output_being and input_being:
		if output_being.has_method("connect_to_output"):
			output_being.connect_to_output(input_being)
		if input_being.has_method("connect_to_input"):
			input_being.connect_to_input(output_being)
		
		print("🔗 Connected: ", output_being.being_name, " -> ", input_being.being_name)

func _find_parent_being(node: Node) -> UniversalBeing:
	var current = node
	while current:
		if current is UniversalBeing:
			return current
		current = current.get_parent()
	return null

func _cancel_connection() -> void:
	selected_socket = null

# ===== VISUAL FEEDBACK =====

func _create_connection_line() -> void:
	connection_line = MeshInstance3D.new()
	add_child(connection_line)
	connection_line.visible = false

func _update_connection_line() -> void:
	if not connection_line:
		return
	
	if selected_socket:
		connection_line.visible = true
		# Create line from selected socket to cursor
		# This is simplified - you'd want a proper line mesh
		connection_line.global_position = (selected_socket.global_position + global_position) / 2
	else:
		connection_line.visible = false

func _update_cursor_visual() -> void:
	if not material:
		return
	
	if hovering_socket:
		material.albedo_color = Color.GREEN
		material.emission = Color.GREEN
		if mesh_instance:
			mesh_instance.scale = Vector3.ONE * 1.2
	elif selected_socket:
		material.albedo_color = Color.YELLOW
		material.emission = Color.YELLOW
		if mesh_instance:
			mesh_instance.scale = Vector3.ONE * 1.1
	else:
		material.albedo_color = Color.CYAN
		material.emission = Color.CYAN
		if mesh_instance:
			mesh_instance.scale = Vector3.ONE

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	var base = super.ai_interface()
	base.cursor_state = {
		"position": global_position,
		"hovering": hovering_socket != null,
		"selected": selected_socket != null
	}
	return base