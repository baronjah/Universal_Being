# ==================================================
# UNIVERSAL BEING: Socket Button Universal Being
# TYPE: socket_button
# PURPOSE: 3D button with input/output sockets for logic connections
# ==================================================

extends UniversalBeing
class_name SocketButtonUniversalBeing

# ===== SOCKET PROPERTIES =====
@export var button_pressed_signal: bool = false
@export var input_active: bool = false
@export var output_value: bool = false

# Socket references
var input_socket: Marker3D
var output_socket: Marker3D
var connected_inputs: Array[Node] = []
var connected_outputs: Array[Node] = []

# Visual references
var mesh_instance: MeshInstance3D
var area_3d: Area3D
var material: StandardMaterial3D

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	being_type = "socket_button"
	being_name = "Socket Button"
	consciousness_level = 1

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Find components
	mesh_instance = find_child("MeshInstance3D") as MeshInstance3D
	area_3d = find_child("Area3D", true) as Area3D
	input_socket = find_child("InputSocket") as Marker3D
	output_socket = find_child("OutputSocket") as Marker3D
	
	# Set up material
	if mesh_instance and mesh_instance.mesh:
		material = StandardMaterial3D.new()
		material.albedo_color = Color.GRAY
		mesh_instance.material_override = material
	
	# Connect area signals
	if area_3d:
		area_3d.input_event.connect(_on_area_input_event)
		area_3d.mouse_entered.connect(_on_mouse_entered)
		area_3d.mouse_exited.connect(_on_mouse_exited)
	
	# Set up socket visuals
	_setup_socket_visuals()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update visual state based on input/output
	if material:
		if button_pressed_signal or output_value:
			material.albedo_color = Color.GREEN
			material.emission_enabled = true
			material.emission = Color.GREEN
			material.emission_energy = 0.5
		elif input_active:
			material.albedo_color = Color.YELLOW
			material.emission_enabled = true
			material.emission = Color.YELLOW
			material.emission_energy = 0.3
		else:
			material.albedo_color = Color.GRAY
			material.emission_enabled = false
	
	# Process input signal
	if input_active:
		_process_input_signal()
	
	# Send output signal
	if output_value:
		_send_output_signal()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)

func pentagon_sewers() -> void:
	# Disconnect all connections
	for node in connected_inputs:
		disconnect_from_input(node)
	for node in connected_outputs:
		disconnect_from_output(node)
	
	super.pentagon_sewers()

# ===== SOCKET METHODS =====

func _setup_socket_visuals() -> void:
	# Add visual indicators for sockets
	if input_socket:
		var input_vis = MeshInstance3D.new()
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius_height = 0.1
		sphere_mesh.radius_width = 0.1
		input_vis.mesh = sphere_mesh
		var input_mat = StandardMaterial3D.new()
		input_mat.albedo_color = Color.BLUE
		input_vis.material_override = input_mat
		input_socket.add_child(input_vis)
	
	if output_socket:
		var output_vis = MeshInstance3D.new()
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius_height = 0.1
		sphere_mesh.radius_width = 0.1
		output_vis.mesh = sphere_mesh
		var output_mat = StandardMaterial3D.new()
		output_mat.albedo_color = Color.RED
		output_vis.material_override = output_mat
		output_socket.add_child(output_vis)

func connect_to_input(source_node: Node) -> void:
	if source_node and source_node not in connected_inputs:
		connected_inputs.append(source_node)
		print("🔌 Connected input from: ", source_node.name)

func connect_to_output(target_node: Node) -> void:
	if target_node and target_node not in connected_outputs:
		connected_outputs.append(target_node)
		print("🔌 Connected output to: ", target_node.name)

func disconnect_from_input(source_node: Node) -> void:
	connected_inputs.erase(source_node)

func disconnect_from_output(target_node: Node) -> void:
	connected_outputs.erase(target_node)

func receive_input_signal(value: bool) -> void:
	input_active = value
	if value and not button_pressed_signal:
		# Trigger button press when receiving input signal
		_on_button_clicked()

func _process_input_signal() -> void:
	# Check all connected inputs for signals
	for node in connected_inputs:
		if node.has_method("get_output_value"):
			var value = node.get_output_value()
			if value:
				receive_input_signal(true)
				return
	input_active = false

func _send_output_signal() -> void:
	# Send signal to all connected outputs
	for node in connected_outputs:
		if node.has_method("receive_input_signal"):
			node.receive_input_signal(output_value)

func get_output_value() -> bool:
	return output_value

# ===== BUTTON METHODS =====

func _on_area_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_button_clicked()

func _on_button_clicked() -> void:
	button_pressed_signal = true
	output_value = true
	
	# Visual feedback
	if mesh_instance:
		var tween = get_tree().create_tween()
		tween.tween_property(mesh_instance, "scale", Vector3.ONE * 1.2, 0.1)
		tween.tween_property(mesh_instance, "scale", Vector3.ONE, 0.1)
	
	# Reset after delay
	await get_tree().create_timer(0.5).timeout
	button_pressed_signal = false
	output_value = false
	
	print("🔘 Socket Button clicked! Sending output signal")

func _on_mouse_entered() -> void:
	if mesh_instance:
		mesh_instance.scale = Vector3.ONE * 1.05

func _on_mouse_exited() -> void:
	if mesh_instance:
		mesh_instance.scale = Vector3.ONE

# ===== SOCKET INFORMATION =====

func get_socket_info() -> Dictionary:
	return {
		"input_socket": input_socket.global_position if input_socket else Vector3.ZERO,
		"output_socket": output_socket.global_position if output_socket else Vector3.ZERO,
		"input_connections": connected_inputs.size(),
		"output_connections": connected_outputs.size(),
		"current_state": output_value
	}

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	pass
	var base = super.ai_interface()
	base.socket_info = get_socket_info()
	base.text_representation = get_text_representation()
	return base

# ===== 1D TEXT REPRESENTATION =====

func get_text_representation() -> String:
	pass
	var text = "[BUTTON:%s]" % being_name
	text += " STATE:%s" % ("PRESSED" if button_pressed_signal else "IDLE")
	text += " IN:%s" % ("ACTIVE" if input_active else "NONE")
	text += " OUT:%s" % ("HIGH" if output_value else "LOW")
	text += " CONNECTIONS:[%d->%d]" % [connected_inputs.size(), connected_outputs.size()]
	text += " CONSCIOUSNESS:%d" % consciousness_level
	return text