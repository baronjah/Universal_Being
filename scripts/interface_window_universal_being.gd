# ==================================================
# UNIVERSAL BEING: Interface Window Universal Being
# TYPE: interface_window
# PURPOSE: Draggable, resizable window with socket connections
# ==================================================

extends UniversalBeing
class_name InterfaceWindowUniversalBeing

# ===== WINDOW PROPERTIES =====
@export var window_title: String = "Interface Window"
@export var min_size: Vector2 = Vector2(3, 2)
@export var max_size: Vector2 = Vector2(20, 15)
@export var enable_sockets: bool = true

# Window state
var is_dragging: bool = false
var is_resizing: bool = false
var drag_offset: Vector3
var resize_corner: String = ""
var initial_size: Vector2

# Node references
var sprite_3d: Sprite3D
var close_button: Node3D
var header: Node3D
var corners: Dictionary = {}
var sides: Dictionary = {}

# Socket nodes
var input_sockets: Array[Marker3D] = []
var output_sockets: Array[Marker3D] = []

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	being_type = "interface_window"
	being_name = window_title
	consciousness_level = 2

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Find all components
	sprite_3d = find_child("Sprite3D") as Sprite3D
	close_button = find_child("Close") as Node3D
	header = find_child("header") as Node3D
	
	# Find corners
	corners["left_top"] = find_child("left_top_corner") as Node3D
	corners["right_top"] = find_child("right_top_corner") as Node3D
	corners["left_bottom"] = find_child("left_bottom_corner") as Node3D
	corners["right_bottom"] = find_child("right_bottom_corner") as Node3D
	
	# Find sides
	sides["top"] = find_child("top") as Node3D
	sides["bottom"] = find_child("bottom") as Node3D
	sides["left"] = find_child("left") as Node3D
	sides["right"] = find_child("right") as Node3D
	
	# Store initial size
	if corners["left_top"] and corners["right_bottom"]:
		var width = abs(corners["right_bottom"].position.x - corners["left_top"].position.x)
		var height = abs(corners["left_top"].position.y - corners["right_bottom"].position.y)
		initial_size = Vector2(width, height)
	
	# Connect interactions
	_setup_interactions()
	
	# Add sockets if enabled
	if enable_sockets:
		_add_socket_points()
	
	# Add visual enhancements
	_setup_visual_style()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Handle dragging
	if is_dragging:
		var camera = get_viewport().get_camera_3d()
		if camera:
			var mouse_pos = get_viewport().get_mouse_position()
			var from = camera.project_ray_origin(mouse_pos)
			var to = from + camera.project_ray_normal(mouse_pos) * 10
			
			# Keep on same Z plane
			var t = -from.z / (to - from).z
			var world_pos = from + (to - from) * t
			global_position = world_pos + drag_offset
	
	# Handle resizing
	if is_resizing:
		_handle_resize()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not event.pressed:
				is_dragging = false
				is_resizing = false
				resize_corner = ""

func pentagon_sewers() -> void:
	# Clean up any connections
	for socket in input_sockets + output_sockets:
		socket.queue_free()
	
	super.pentagon_sewers()

# ===== INTERACTION SETUP =====

func _setup_interactions() -> void:
	# Close button
	if close_button:
		var close_area = close_button.find_child("Area3D", true) as Area3D
		if close_area:
			close_area.input_event.connect(_on_close_clicked)
			close_area.mouse_entered.connect(func(): _highlight_element(close_button, Color.RED))
			close_area.mouse_exited.connect(func(): _unhighlight_element(close_button))
	
	# Header for dragging
	if header:
		var header_area = header.find_child("Area3D", true) as Area3D
		if header_area:
			header_area.input_event.connect(_on_header_clicked)
			header_area.mouse_entered.connect(func(): _highlight_element(header, Color.BLUE))
			header_area.mouse_exited.connect(func(): _unhighlight_element(header))
	
	# Corners for resizing
	for corner_name in corners:
		var corner = corners[corner_name]
		if corner:
			var area = corner.find_child("Area3D", true) as Area3D
			if area:
				area.input_event.connect(func(cam, ev, pos, norm, idx): _on_corner_clicked(corner_name, cam, ev, pos, norm, idx))
				area.mouse_entered.connect(func(): _highlight_element(corner, Color.YELLOW))
				area.mouse_exited.connect(func(): _unhighlight_element(corner))

# ===== WINDOW ACTIONS =====

func _on_close_clicked(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("🗙 Closing window: ", being_name)
		# Animate close
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector3.ZERO, 0.3)
		tween.finished.connect(func(): visible = false)

func _on_header_clicked(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = true
		drag_offset = global_position - position

func _on_corner_clicked(corner_name: String, camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_resizing = true
		resize_corner = corner_name

func _handle_resize() -> void:
	pass
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 10
	
	# Get position on same Z plane
	var t = -from.z / (to - from).z
	var world_pos = from + (to - from) * t
	var local_pos = to_local(world_pos)
	
	# Update window size based on which corner is being dragged
	match resize_corner:
		"right_bottom":
			_resize_window(Vector2(local_pos.x, -local_pos.y))
		"left_top":
			_resize_window(Vector2(-local_pos.x, local_pos.y))
		"right_top":
			_resize_window(Vector2(local_pos.x, local_pos.y))
		"left_bottom":
			_resize_window(Vector2(-local_pos.x, -local_pos.y))

func _resize_window(new_size: Vector2) -> void:
	new_size = new_size.clamp(min_size, max_size)
	
	# Update corner positions
	var half_width = new_size.x / 2
	var half_height = new_size.y / 2
	
	if corners["left_top"]:
		corners["left_top"].position = Vector3(-half_width, half_height, 0)
	if corners["right_top"]:
		corners["right_top"].position = Vector3(half_width, half_height, 0)
	if corners["left_bottom"]:
		corners["left_bottom"].position = Vector3(-half_width, -half_height, 0)
	if corners["right_bottom"]:
		corners["right_bottom"].position = Vector3(half_width, -half_height, 0)
	
	# Update sides
	if sides["top"]:
		sides["top"].position.y = half_height
		sides["top"].scale.x = new_size.x / initial_size.x
	if sides["bottom"]:
		sides["bottom"].position.y = -half_height
		sides["bottom"].scale.x = new_size.x / initial_size.x
	if sides["left"]:
		sides["left"].position.x = -half_width
		sides["left"].scale.y = new_size.y / initial_size.y
	if sides["right"]:
		sides["right"].position.x = half_width
		sides["right"].scale.y = new_size.y / initial_size.y
	
	# Update sprite size if needed
	if sprite_3d and sprite_3d.texture:
		sprite_3d.scale = Vector3(new_size.x / initial_size.x, new_size.y / initial_size.y, 1)

# ===== SOCKET SYSTEM =====

func _add_socket_points() -> void:
	# Add input sockets on left side
	for i in range(3):
		var socket = Marker3D.new()
		socket.name = "InputSocket" + str(i)
		socket.position = Vector3(-initial_size.x/2 - 0.5, initial_size.y/2 - (i + 1) * 1.5, 0)
		socket.set_meta("socket_type", "input")
		socket.set_meta("socket_name", "in_" + str(i))
		add_child(socket)
		input_sockets.append(socket)
		
		# Add visual
		var vis = _create_socket_visual(Color.BLUE)
		socket.add_child(vis)
	
	# Add output sockets on right side
	for i in range(3):
		var socket = Marker3D.new()
		socket.name = "OutputSocket" + str(i)
		socket.position = Vector3(initial_size.x/2 + 0.5, initial_size.y/2 - (i + 1) * 1.5, 0)
		socket.set_meta("socket_type", "output")
		socket.set_meta("socket_name", "out_" + str(i))
		add_child(socket)
		output_sockets.append(socket)
		
		# Add visual
		var vis = _create_socket_visual(Color.RED)
		socket.add_child(vis)

func _create_socket_visual(color: Color) -> MeshInstance3D:
	pass
	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius_height = 0.15
	sphere_mesh.radius_width = 0.15
	mesh_instance.mesh = sphere_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy = 0.3
	mesh_instance.material_override = material
	
	return mesh_instance

# ===== VISUAL ENHANCEMENTS =====

func _setup_visual_style() -> void:
	# Add glow to window based on consciousness
	if sprite_3d:
		var material = StandardMaterial3D.new()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = Color(1, 1, 1, 0.9)
		material.emission_enabled = true
		material.emission = consciousness_aura_color
		material.emission_energy = consciousness_level * 0.1
		sprite_3d.material_override = material

func _highlight_element(element: Node3D, color: Color) -> void:
	pass
	var mesh = element.find_child("MeshInstance3D") as MeshInstance3D
	if mesh:
		var mat = mesh.material_override
		if not mat:
			mat = StandardMaterial3D.new()
			mesh.material_override = mat
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy = 0.5

func _unhighlight_element(element: Node3D) -> void:
	pass
	var mesh = element.find_child("MeshInstance3D") as MeshInstance3D
	if mesh and mesh.material_override:
		mesh.material_override.emission_enabled = false

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	pass
	var base = super.ai_interface()
	base.window_state = {
		"title": window_title,
		"visible": visible,
		"position": global_position,
		"size": initial_size,
		"sockets_enabled": enable_sockets
	}
	base.text_representation = get_text_representation()
	return base

# ===== 1D TEXT REPRESENTATION =====

func get_text_representation() -> String:
	pass
	var text = "=== INTERFACE WINDOW ===\n"
	text += "Title: %s\n" % window_title
	text += "Position: %.2f, %.2f, %.2f\n" % [global_position.x, global_position.y, global_position.z]
	text += "Size: %.2f x %.2f\n" % [initial_size.x, initial_size.y]
	text += "State: %s\n" % ("DRAGGING" if is_dragging else "RESIZING" if is_resizing else "IDLE")
	
	# Socket information
	if enable_sockets:
		text += "\nSOCKETS:\n"
		text += "  Inputs: %d\n" % input_sockets.size()
		for i in range(input_sockets.size()):
			text += "    - in_%d: %s\n" % [i, "connected" if _is_socket_connected(input_sockets[i]) else "open"]
		text += "  Outputs: %d\n" % output_sockets.size()
		for i in range(output_sockets.size()):
			text += "    - out_%d: %s\n" % [i, "connected" if _is_socket_connected(output_sockets[i]) else "open"]
	
	text += "Consciousness: Level %d\n" % consciousness_level
	text += "========================\n"
	return text

func _is_socket_connected(socket: Marker3D) -> bool:
	# Check if this socket has any connections
	# This would be implemented based on your connection system
	return false  # Placeholder

# Override to provide text updates
func _notification(what: int) -> void:
	if what == NOTIFICATION_PROCESS:
		# Update AI companions with text representation
		if Engine.get_process_frames() % 60 == 0:  # Every second
			var text_rep = get_text_representation()
			# This could be sent to AI systems
			if has_signal("text_updated"):
				emit_signal("text_updated", text_rep)
