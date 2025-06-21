# ==================================================
# UNIVERSAL BEING: INPUT STREAM VISUALIZER
# TYPE: Real-time Input Data Flow Visualization
# PURPOSE: Show every keystroke and input as floating data
# INSPIRED BY: Matrix data streams + Your vision
# ==================================================

extends Node3D
class_name InputStreamVisualizer

## 🌊 INPUT STREAMS - Every keystroke becomes visible floating data
## See the flow of human input as consciousness interacts with the system

# ===== STREAM CONFIGURATION =====
@export var stream_visualization_enabled: bool = true
@export var show_keyboard_streams: bool = true
@export var show_mouse_streams: bool = true
@export var show_data_flow_lines: bool = true
@export var stream_lifetime: float = 5.0

# Stream Types
enum StreamType {
	KEYBOARD_INPUT,     # Keyboard key presses
	MOUSE_MOVEMENT,     # Mouse motion data
	MOUSE_CLICK,        # Mouse button events
	GAMEPAD_INPUT,      # Controller input
	SYSTEM_COMMAND,     # System-level commands
	AI_RESPONSE         # AI-generated responses
}

# ===== INPUT STREAM DATA =====
class InputStreamData:
	var stream_type: StreamType
	var input_data: InputEvent
	var world_position: Vector3
	var flow_direction: Vector3
	var life_remaining: float
	var creation_time: float
	var visual_node: Node3D
	var stream_velocity: float = 2.0
	var consciousness_connection: bool = false
	
	func _init(type: StreamType, event: InputEvent, pos: Vector3):
		stream_type = type
		input_data = event
		world_position = pos
		creation_time = Time.get_time_from_start()
		life_remaining = 5.0
		_set_flow_properties()
	
	func _set_flow_properties():
		match stream_type:
			StreamType.KEYBOARD_INPUT:
				flow_direction = Vector3(randf_range(-0.5, 0.5), 1.5, randf_range(-0.5, 0.5))
				stream_velocity = 3.0
			StreamType.MOUSE_MOVEMENT:
				flow_direction = Vector3(randf_range(-1, 1), 0.5, randf_range(-1, 1))
				stream_velocity = 4.0
			StreamType.MOUSE_CLICK:
				flow_direction = Vector3(0, 2.0, 0)
				stream_velocity = 5.0
			StreamType.AI_RESPONSE:
				flow_direction = Vector3(0, -1.0, 0)
				stream_velocity = 2.5
				consciousness_connection = true

# ===== STREAM STATE =====
var active_streams: Array[InputStreamData] = []
var stream_materials: Dictionary = {}
var input_history: Array[Dictionary] = []
var stream_containers: Dictionary = {}

# Flow line system
var flow_lines: Array[Line3D] = []
var connection_points: Array[Vector3] = []

# Performance settings
var max_concurrent_streams: int = 100
var stream_update_interval: float = 0.016  # 60 FPS

# Visual settings
var base_stream_size: float = 0.1
var stream_glow_intensity: float = 2.0
var flow_line_opacity: float = 0.6

# ===== PENTAGON INTEGRATION =====

func _ready() -> void:
	setup_stream_visualization()
	initialize_stream_materials()
	create_stream_containers()
	connect_to_input_systems()
	
	print("🌊 Input Stream Visualizer: Every input becomes visible data!")

func _process(delta: float) -> void:
	if stream_visualization_enabled:
		update_active_streams(delta)
		update_flow_lines(delta)
		manage_stream_performance()

func _input(event: InputEvent) -> void:
	if stream_visualization_enabled:
		create_input_stream(event)

# ===== STREAM SETUP =====

func setup_stream_visualization() -> void:
	"""Initialize the input stream visualization system"""
	# Create main containers
	stream_containers["keyboard"] = Node3D.new()
	stream_containers["keyboard"].name = "KeyboardStreams"
	add_child(stream_containers["keyboard"])
	
	stream_containers["mouse"] = Node3D.new()
	stream_containers["mouse"].name = "MouseStreams"
	add_child(stream_containers["mouse"])
	
	stream_containers["system"] = Node3D.new()
	stream_containers["system"].name = "SystemStreams"
	add_child(stream_containers["system"])
	
	print("🌊 Stream containers initialized")

func initialize_stream_materials() -> void:
	"""Create materials for different stream types"""
	# Keyboard streams - bright green flowing
	var keyboard_material = StandardMaterial3D.new()
	keyboard_material.albedo_color = Color(0.2, 1.0, 0.3, 0.9)
	keyboard_material.emission_enabled = true
	keyboard_material.emission = Color(0.1, 0.8, 0.1)
	keyboard_material.emission_energy = stream_glow_intensity
	stream_materials[StreamType.KEYBOARD_INPUT] = keyboard_material
	
	# Mouse movement - cyan flowing
	var mouse_material = StandardMaterial3D.new()
	mouse_material.albedo_color = Color(0.2, 0.8, 1.0, 0.8)
	mouse_material.emission_enabled = true
	mouse_material.emission = Color(0.0, 0.6, 1.0)
	mouse_material.emission_energy = stream_glow_intensity
	stream_materials[StreamType.MOUSE_MOVEMENT] = mouse_material
	
	# Mouse clicks - bright white bursts
	var click_material = StandardMaterial3D.new()
	click_material.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	click_material.emission_enabled = true
	click_material.emission = Color(1.0, 1.0, 1.0)
	click_material.emission_energy = stream_glow_intensity * 1.5
	stream_materials[StreamType.MOUSE_CLICK] = click_material
	
	# AI responses - purple consciousness
	var ai_material = StandardMaterial3D.new()
	ai_material.albedo_color = Color(0.8, 0.3, 1.0, 0.9)
	ai_material.emission_enabled = true
	ai_material.emission = Color(0.5, 0.1, 0.8)
	ai_material.emission_energy = stream_glow_intensity
	stream_materials[StreamType.AI_RESPONSE] = ai_material
	
	print("💎 Stream materials created")

# ===== STREAM CREATION =====

func create_input_stream(event: InputEvent) -> InputStreamData:
	"""Create a visual stream for any input event"""
	var stream_type = determine_stream_type(event)
	var start_position = calculate_spawn_position(event)
	
	var stream = InputStreamData.new(stream_type, event, start_position)
	
	# Create visual representation
	create_stream_visual(stream)
	
	active_streams.append(stream)
	
	# Record in history
	record_input_history(event, stream_type)
	
	print("🌊 Input stream created: %s at %s" % [StreamType.keys()[stream_type], start_position])
	return stream

func determine_stream_type(event: InputEvent) -> StreamType:
	"""Determine what type of stream this input should create"""
	if event is InputEventKey:
		return StreamType.KEYBOARD_INPUT
	elif event is InputEventMouseMotion:
		return StreamType.MOUSE_MOVEMENT
	elif event is InputEventMouseButton:
		return StreamType.MOUSE_CLICK
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		return StreamType.GAMEPAD_INPUT
	else:
		return StreamType.SYSTEM_COMMAND

func calculate_spawn_position(event: InputEvent) -> Vector3:
	"""Calculate where to spawn the input stream"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return Vector3.ZERO
	
	var base_pos = camera.global_position
	
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		# Spawn at mouse cursor position in 3D space
		var mouse_pos = get_viewport().get_mouse_position()
		var ray_origin = camera.project_ray_origin(mouse_pos)
		var ray_direction = camera.project_ray_normal(mouse_pos)
		return ray_origin + ray_direction * 3.0
	else:
		# Spawn near camera for keyboard events
		return base_pos + camera.basis.z * -2.0 + Vector3(randf_range(-1, 1), randf_range(-0.5, 0.5), 0)

func create_stream_visual(stream: InputStreamData) -> void:
	"""Create the visual representation of an input stream"""
	var visual_container = Node3D.new()
	visual_container.name = "Stream_" + str(Time.get_ticks_msec())
	visual_container.position = stream.world_position
	
	# Main stream particle/mesh
	var stream_mesh = create_stream_mesh(stream)
	visual_container.add_child(stream_mesh)
	
	# Text label for keyboard input
	if stream.stream_type == StreamType.KEYBOARD_INPUT:
		var label = create_input_label(stream)
		visual_container.add_child(label)
	
	# Particle trail
	var particles = create_stream_particles(stream)
	visual_container.add_child(particles)
	
	stream.visual_node = visual_container
	
	# Add to appropriate container
	match stream.stream_type:
		StreamType.KEYBOARD_INPUT:
			stream_containers["keyboard"].add_child(visual_container)
		StreamType.MOUSE_MOVEMENT, StreamType.MOUSE_CLICK:
			stream_containers["mouse"].add_child(visual_container)
		_:
			stream_containers["system"].add_child(visual_container)

func create_stream_mesh(stream: InputStreamData) -> MeshInstance3D:
	"""Create the main mesh for a stream"""
	var mesh_instance = MeshInstance3D.new()
	
	match stream.stream_type:
		StreamType.KEYBOARD_INPUT:
			# Small cube for keyboard
			var cube = BoxMesh.new()
			cube.size = Vector3.ONE * base_stream_size
			mesh_instance.mesh = cube
		StreamType.MOUSE_MOVEMENT:
			# Elongated shape for mouse movement
			var capsule = CapsuleMesh.new()
			capsule.radius = base_stream_size * 0.5
			capsule.height = base_stream_size * 2.0
			mesh_instance.mesh = capsule
		StreamType.MOUSE_CLICK:
			# Burst sphere for clicks
			var sphere = SphereMesh.new()
			sphere.radius = base_stream_size * 1.5
			mesh_instance.mesh = sphere
		_:
			# Default shape
			var sphere = SphereMesh.new()
			sphere.radius = base_stream_size
			mesh_instance.mesh = sphere
	
	mesh_instance.material_override = stream_materials[stream.stream_type]
	return mesh_instance

func create_input_label(stream: InputStreamData) -> Label3D:
	"""Create text label for keyboard input"""
	var label = Label3D.new()
	
	if stream.input_data is InputEventKey:
		var key_event = stream.input_data as InputEventKey
		label.text = OS.get_keycode_string(key_event.keycode)
		
		# Special handling for modifier keys
		if key_event.ctrl_pressed:
			label.text = "Ctrl+" + label.text
		if key_event.shift_pressed:
			label.text = "Shift+" + label.text
		if key_event.alt_pressed:
			label.text = "Alt+" + label.text
	else:
		label.text = "KEY"
	
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = Color.GREEN
	label.outline_modulate = Color.BLACK
	label.outline_size = 2
	label.position.y = base_stream_size * 2
	
	return label

func create_stream_particles(stream: InputStreamData) -> GPUParticles3D:
	"""Create particle trail for stream"""
	var particles = GPUParticles3D.new()
	particles.emitting = true
	particles.amount = 50
	particles.lifetime = stream_lifetime * 0.5
	particles.visibility_aabb = AABB(Vector3.ONE * -5, Vector3.ONE * 10)
	
	# Create particle material
	var particle_material = ParticleProcessMaterial.new()
	particle_material.direction = Vector3(0, 1, 0)
	particle_material.initial_velocity_min = 0.5
	particle_material.initial_velocity_max = 2.0
	particle_material.gravity = Vector3(0, -1, 0)
	particle_material.scale_min = 0.1
	particle_material.scale_max = 0.3
	
	particles.process_material = particle_material
	
	return particles

# ===== STREAM UPDATES =====

func update_active_streams(delta: float) -> void:
	"""Update all active input streams"""
	var streams_to_remove = []
	
	for stream in active_streams:
		# Age the stream
		stream.life_remaining -= delta
		
		# Move the stream
		if stream.visual_node and is_instance_valid(stream.visual_node):
			stream.world_position += stream.flow_direction * stream.stream_velocity * delta
			stream.visual_node.position = stream.world_position
			
			# Fade out over time
			var life_ratio = 1.0 - (stream.life_remaining / stream_lifetime)
			var alpha = 1.0 - life_ratio
			
			# Apply fading to all child meshes
			for child in stream.visual_node.get_children():
				if child is MeshInstance3D and child.material_override:
					var material = child.material_override as StandardMaterial3D
					if material:
						material.albedo_color.a = alpha
						material.emission_energy = stream_glow_intensity * alpha
		
		# Mark for removal if expired
		if stream.life_remaining <= 0.0:
			streams_to_remove.append(stream)
	
	# Remove expired streams
	for stream in streams_to_remove:
		remove_stream(stream)

func remove_stream(stream: InputStreamData) -> void:
	"""Remove a stream from the system"""
	if stream.visual_node and is_instance_valid(stream.visual_node):
		stream.visual_node.queue_free()
	
	active_streams.erase(stream)

func update_flow_lines(delta: float) -> void:
	"""Update connection lines between streams (if enabled)"""
	if not show_data_flow_lines:
		return
	
	# Clear old lines
	for line in flow_lines:
		if is_instance_valid(line):
			line.queue_free()
	flow_lines.clear()
	
	# Create new connection lines between nearby streams
	for i in range(active_streams.size()):
		for j in range(i + 1, active_streams.size()):
			var stream1 = active_streams[i]
			var stream2 = active_streams[j]
			
			var distance = stream1.world_position.distance_to(stream2.world_position)
			if distance < 5.0:  # Only connect nearby streams
				create_flow_line(stream1.world_position, stream2.world_position)

func create_flow_line(from: Vector3, to: Vector3) -> void:
	"""Create a flow line between two points"""
	# For now, use a simple MeshInstance3D with a tube
	# In a full implementation, you might use Line3D or custom mesh
	var line_container = Node3D.new()
	line_container.position = from
	line_container.look_at(to, Vector3.UP)
	
	var line_mesh = MeshInstance3D.new()
	var capsule = CapsuleMesh.new()
	capsule.radius = 0.02
	capsule.height = from.distance_to(to)
	line_mesh.mesh = capsule
	
	var line_material = StandardMaterial3D.new()
	line_material.albedo_color = Color(0.5, 0.8, 1.0, flow_line_opacity)
	line_material.emission_enabled = true
	line_material.emission = Color(0.3, 0.6, 1.0)
	line_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	line_mesh.material_override = line_material
	
	line_container.add_child(line_mesh)
	add_child(line_container)
	
	# Store reference (would be Line3D in a real implementation)
	flow_lines.append(line_container)

# ===== SYSTEM INTEGRATION =====

func connect_to_input_systems() -> void:
	"""Connect to other input and consciousness systems"""
	# Connect to AI systems to show AI responses
	var ai_systems = get_tree().get_nodes_in_group("ai_systems")
	for ai in ai_systems:
		if ai.has_signal("ai_response_generated"):
			ai.ai_response_generated.connect(_on_ai_response)

func _on_ai_response(response_text: String, position: Vector3) -> void:
	"""Handle AI response visualization"""
	# Create a mock InputEvent for AI response
	var mock_event = InputEventKey.new()
	mock_event.keycode = KEY_ENTER
	
	var stream = InputStreamData.new(StreamType.AI_RESPONSE, mock_event, position)
	stream.consciousness_connection = true
	
	create_stream_visual(stream)
	active_streams.append(stream)
	
	print("🤖 AI response stream created at %s" % position)

func record_input_history(event: InputEvent, stream_type: StreamType) -> void:
	"""Record input in history for analysis"""
	var history_entry = {
		"timestamp": Time.get_time_from_start(),
		"type": StreamType.keys()[stream_type],
		"event_class": event.get_class(),
		"consciousness_active": true
	}
	
	if event is InputEventKey:
		history_entry["keycode"] = (event as InputEventKey).keycode
		history_entry["pressed"] = (event as InputEventKey).pressed
	
	input_history.append(history_entry)
	
	# Limit history size
	if input_history.size() > 1000:
		input_history = input_history.slice(-500)  # Keep last 500

# ===== PERFORMANCE MANAGEMENT =====

func manage_stream_performance() -> void:
	"""Manage performance by limiting concurrent streams"""
	if active_streams.size() > max_concurrent_streams:
		# Remove oldest streams
		var streams_to_remove = active_streams.slice(0, active_streams.size() - max_concurrent_streams)
		for stream in streams_to_remove:
			remove_stream(stream)

# ===== PUBLIC API =====

func create_custom_stream(type: StreamType, position: Vector3, data: Variant) -> InputStreamData:
	"""Create a custom input stream (for system events)"""
	var mock_event = InputEventKey.new()
	var stream = InputStreamData.new(type, mock_event, position)
	stream.input_data = data
	
	create_stream_visual(stream)
	active_streams.append(stream)
	
	return stream

func get_stream_statistics() -> Dictionary:
	"""Get current stream statistics"""
	var type_counts = {}
	for type in StreamType.values():
		type_counts[StreamType.keys()[type]] = 0
	
	for stream in active_streams:
		var type_name = StreamType.keys()[stream.stream_type]
		type_counts[type_name] += 1
	
	return {
		"total_active_streams": active_streams.size(),
		"type_breakdown": type_counts,
		"history_entries": input_history.size(),
		"flow_lines": flow_lines.size(),
		"performance_limited": active_streams.size() >= max_concurrent_streams
	}

func toggle_stream_type(type: StreamType, enabled: bool) -> void:
	"""Enable/disable specific stream types"""
	match type:
		StreamType.KEYBOARD_INPUT:
			show_keyboard_streams = enabled
		StreamType.MOUSE_MOVEMENT, StreamType.MOUSE_CLICK:
			show_mouse_streams = enabled

func _to_string() -> String:
	return "InputStreamVisualizer [Active: %d, History: %d]" % [active_streams.size(), input_history.size()]