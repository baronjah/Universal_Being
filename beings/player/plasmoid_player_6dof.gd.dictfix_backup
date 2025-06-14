extends PlasmoidUniversalBeing
class_name PlasmoidPlayer6DOF

## 6DOF PLASMOID PLAYER - Perfect Universal Being movement
## WASD + mouse = 6 degrees of freedom movement
## Crosshair interface, socket system, perfect rotation

signal crosshair_target_changed(target: Node3D)
signal socket_interaction(socket: Node3D, distance: float)
signal text_editing_mode_changed(enabled: bool)
signal interface_activated(interface_type: String)

@export_group("6DOF Movement")
@export var movement_speed: float = 15.0
@export var mouse_sensitivity: float = 0.002
@export var acceleration: float = 8.0
@export var deceleration: float = 12.0

@export_group("Camera & Crosshair")
@export var crosshair_range: float = 100.0
@export var interaction_range: float = 10.0

# Camera system
@onready var camera: Camera3D = $Camera3D
@onready var crosshair_ray: RayCast3D = $Camera3D/CrosshairRay

# Movement state
var velocity: Vector3 = Vector3.ZERO
var current_target: Node3D = null

# Crosshair UI
var crosshair_ui: Control
var crosshair_dot: ColorRect

# Socket system
var nearby_sockets: Array[Node3D] = []
var selected_socket: Node3D = null

# Text editing system
var text_editing_mode: bool = false
var current_text_object: Node3D = null
var text_cursor_position: int = 0
var text_content: String = ""

# Interface states
var console_open: bool = false
var creation_mode: bool = false
var inspection_mode: bool = false

func pentagon_init() -> void:
	super.pentagon_init()
	being_name = "6DOF Player"
	add_to_group("plasmoid_player")
	
	# Setup camera system
	setup_camera_and_crosshair()
	
	# Setup interaction system
	setup_interaction_system()
	
	# Register with Universal Input Manager
	call_deferred("connect_to_input_manager")
	
	# Capture mouse for 6DOF control
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func connect_to_input_manager() -> void:
	"""Connect to Universal Input Manager for consciousness-driven input"""
	var input_manager = get_tree().get_first_node_in_group("universal_input_manager")
	if not input_manager:
		# Create input manager if it doesn't exist
		input_manager = preload("res://core/UniversalInputManager.gd").new()
		input_manager.name = "UniversalInputManager"
		input_manager.add_to_group("universal_input_manager")
		get_tree().current_scene.add_child(input_manager)
	
	# Input handler system will be added later
	print("🎮 6DOF Player connected to input manager")

func setup_camera_and_crosshair() -> void:
	"""Setup 6DOF camera with crosshair system"""
	if not camera:
		camera = Camera3D.new()
		camera.name = "Camera3D"
		add_child(camera)
	
	# Position camera at eye level of plasmoid
	camera.position = Vector3(0, 0, 0)  # Camera is the plasmoid center
	camera.fov = 75
	
	# Setup crosshair ray
	if not crosshair_ray:
		crosshair_ray = RayCast3D.new()
		crosshair_ray.name = "CrosshairRay"
		camera.add_child(crosshair_ray)
	
	crosshair_ray.target_position = Vector3(0, 0, -crosshair_range)
	crosshair_ray.enabled = true
	crosshair_ray.collision_mask = 1  # Layer 1 for interactions
	
	# Create crosshair UI after tree is ready
	call_deferred("create_crosshair_ui")

func create_crosshair_ui() -> void:
	"""Create screen-center crosshair for aiming"""
	# Create UI overlay
	crosshair_ui = Control.new()
	crosshair_ui.name = "CrosshairUI"
	crosshair_ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	crosshair_ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Create crosshair dot
	crosshair_dot = ColorRect.new()
	crosshair_dot.name = "CrosshairDot"
	crosshair_dot.size = Vector2(4, 4)
	crosshair_dot.color = Color.CYAN
	crosshair_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Position crosshair at screen center
	crosshair_dot.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	crosshair_ui.add_child(crosshair_dot)
	
	# Add to scene UI layer
	get_tree().current_scene.add_child(crosshair_ui)

func setup_interaction_system() -> void:
	"""Setup socket and interaction detection"""
	# Create socket detector area
	var socket_area = Area3D.new()
	socket_area.name = "SocketDetector"
	add_child(socket_area)
	
	var socket_collision = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = interaction_range
	socket_collision.shape = sphere_shape
	socket_area.add_child(socket_collision)
	
	# Connect socket detection
	socket_area.area_entered.connect(_on_socket_area_entered)
	socket_area.area_exited.connect(_on_socket_area_exited)
	socket_area.body_entered.connect(_on_socket_body_entered)
	socket_area.body_exited.connect(_on_socket_body_exited)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# ALL INPUTS GO THROUGH UNIVERSAL INPUT MANAGER
	# This is just for direct handling when needed
	pass

func handle_mouse_look(relative_motion: Vector2) -> void:
	"""Perfect 6DOF mouse look - 3 rotational degrees of freedom"""
	# Horizontal rotation (yaw) - rotate entire plasmoid
	rotate_y(-relative_motion.x * mouse_sensitivity)
	
	# Vertical rotation (pitch) - rotate camera only, with limits
	camera.rotation.x = clamp(
		camera.rotation.x - relative_motion.y * mouse_sensitivity,
		-PI/2, PI/2
	)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Handle 6DOF movement
	handle_wasd_movement(delta)
	
	# Update crosshair targeting
	update_crosshair_targeting()
	
	# Update socket visualization
	update_socket_highlights()

func handle_wasd_movement(delta: float) -> void:
	"""6DOF movement - plasmoid moves where camera looks"""
	var input_vector = Vector3.ZERO
	
	# Get movement input relative to camera direction
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vector -= global_transform.basis.z  # Forward
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vector += global_transform.basis.z   # Backward
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vector -= global_transform.basis.x   # Left
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vector += global_transform.basis.x   # Right
	
	# Vertical movement (space/shift for up/down)
	if Input.is_key_pressed(KEY_SPACE):
		input_vector += Vector3.UP
	if Input.is_key_pressed(KEY_SHIFT):
		input_vector -= Vector3.UP
	
	# Calculate target velocity
	var target_velocity = Vector3.ZERO
	if input_vector.length() > 0:
		target_velocity = input_vector.normalized() * movement_speed
	
	# Smooth acceleration/deceleration
	var accel_rate = acceleration if input_vector.length() > 0 else deceleration
	velocity = velocity.lerp(target_velocity, accel_rate * delta)
	
	# Apply movement
	global_position += velocity * delta

func update_crosshair_targeting() -> void:
	"""Update crosshair targeting and interaction detection"""
	var new_target: Node3D = null
	
	if crosshair_ray.is_colliding():
		var collider = crosshair_ray.get_collider()
		if collider is Node3D:
			new_target = collider
	
	# Update target if changed
	if new_target != current_target:
		current_target = new_target
		crosshair_target_changed.emit(current_target)
		update_crosshair_visual()

func update_crosshair_visual() -> void:
	"""Update crosshair appearance based on target"""
	if current_target:
		# Target acquired - change crosshair color
		if is_socket(current_target):
			crosshair_dot.color = Color.GREEN  # Socket
		else:
			crosshair_dot.color = Color.YELLOW # Interactable
	else:
		crosshair_dot.color = Color.CYAN  # Default

func update_socket_highlights() -> void:
	"""Highlight nearby sockets for connection"""
	# Update socket material/glow based on proximity and selection
	for socket in nearby_sockets:
		if socket == selected_socket:
			highlight_socket(socket, Color.GREEN)
		elif is_socket_compatible(socket):
			highlight_socket(socket, Color.BLUE)

func is_socket(node: Node3D) -> bool:
	"""Check if node is a socket"""
	return node.has_meta("socket_type") or "socket" in node.name.to_lower()

func is_socket_compatible(socket: Node3D) -> bool:
	"""Check if socket is compatible for connection"""
	if not is_socket(socket):
		return false
	
	var socket_type = socket.get_meta("socket_type", "")
	# Add socket compatibility logic here
	return true

func highlight_socket(socket: Node3D, color: Color) -> void:
	"""Highlight socket with specified color"""
	if socket.has_method("set_glow_color"):
		socket.set_glow_color(color)

func interact_with_target() -> void:
	"""Interact with whatever the crosshair is targeting"""
	if current_target:
		if is_socket(current_target):
			attempt_socket_connection(current_target)
		elif current_target.has_method("interact"):
			current_target.interact(self)

func attempt_socket_connection(socket: Node3D) -> void:
	"""Attempt to connect to targeted socket"""
	var distance = global_position.distance_to(socket.global_position)
	
	if distance <= interaction_range:
		# Emit interaction signal for connection system
		socket_interaction.emit(socket, distance)
		print("🔌 Connecting to socket: %s" % socket.name)
	else:
		print("⚠️ Socket too far: %.1fm (max: %.1fm)" % [distance, interaction_range])

func connect_to_nearest_socket() -> void:
	"""Connect to nearest compatible socket"""
	var nearest_socket: Node3D = null
	var min_distance: float = interaction_range
	
	for socket in nearby_sockets:
		var distance = global_position.distance_to(socket.global_position)
		if distance < min_distance and is_socket_compatible(socket):
			min_distance = distance
			nearest_socket = socket
	
	if nearest_socket:
		attempt_socket_connection(nearest_socket)

func cycle_target_socket() -> void:
	"""Cycle through nearby sockets with TAB"""
	if nearby_sockets.is_empty():
		return
	
	var current_index = nearby_sockets.find(selected_socket)
	var next_index = (current_index + 1) % nearby_sockets.size()
	selected_socket = nearby_sockets[next_index]

func toggle_mouse_mode() -> void:
	"""Toggle between captured and visible mouse mode"""
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Socket detection callbacks
func _on_socket_area_entered(area: Area3D) -> void:
	if is_socket(area.get_parent()):
		nearby_sockets.append(area.get_parent())

func _on_socket_area_exited(area: Area3D) -> void:
	nearby_sockets.erase(area.get_parent())

func _on_socket_body_entered(body: Node3D) -> void:
	if is_socket(body):
		nearby_sockets.append(body)

func _on_socket_body_exited(body: Node3D) -> void:
	nearby_sockets.erase(body)

func handle_text_editing_input(event: InputEvent) -> void:
	"""Handle text editing with arrow key navigation"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				exit_text_editing_mode()
			KEY_ENTER:
				save_text_and_exit()
			KEY_LEFT:
				move_text_cursor(-1)
			KEY_RIGHT:
				move_text_cursor(1)
			KEY_UP:
				move_text_cursor_line(-1)
			KEY_DOWN:
				move_text_cursor_line(1)
			KEY_BACKSPACE:
				delete_text_character()
			_:
				if event.unicode > 0:
					insert_text_character(char(event.unicode))

func enter_text_editing_mode() -> void:
	"""Enter text editing mode for crosshair target"""
	if current_target and current_target.has_method("get_text"):
		text_editing_mode = true
		current_text_object = current_target
		text_content = current_target.get_text()
		text_cursor_position = text_content.length()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		text_editing_mode_changed.emit(true)
		show_ub_visual("Editing text: " + current_target.name)

func exit_text_editing_mode() -> void:
	"""Exit text editing mode without saving"""
	text_editing_mode = false
	current_text_object = null
	text_content = ""
	text_cursor_position = 0
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	text_editing_mode_changed.emit(false)

func save_text_and_exit() -> void:
	"""Save text changes and exit editing mode"""
	if current_text_object and current_text_object.has_method("set_text"):
		current_text_object.set_text(text_content)
		show_ub_visual("Text saved")
	exit_text_editing_mode()

func move_text_cursor(direction: int) -> void:
	"""Move text cursor left/right"""
	text_cursor_position = clamp(text_cursor_position + direction, 0, text_content.length())

func move_text_cursor_line(direction: int) -> void:
	"""Move text cursor up/down by line"""
	var lines = text_content.split("\n")
	if lines.size() <= 1:
		return
	
	# Find current line and position
	var current_line = 0
	var char_count = 0
	for i in range(lines.size()):
		if char_count + lines[i].length() >= text_cursor_position:
			current_line = i
			break
		char_count += lines[i].length() + 1  # +1 for newline
	
	# Move to target line
	var target_line = clamp(current_line + direction, 0, lines.size() - 1)
	if target_line != current_line:
		# Calculate position in target line
		var line_pos = text_cursor_position - char_count
		var target_char_count = 0
		for i in range(target_line):
			target_char_count += lines[i].length() + 1
		text_cursor_position = target_char_count + min(line_pos, lines[target_line].length())

func insert_text_character(character: String) -> void:
	"""Insert character at cursor position"""
	text_content = text_content.insert(text_cursor_position, character)
	text_cursor_position += 1

func delete_text_character() -> void:
	"""Delete character before cursor"""
	if text_cursor_position > 0:
		text_content = text_content.erase(text_cursor_position - 1, 1)
		text_cursor_position -= 1

func toggle_console() -> void:
	"""Toggle Universal Being console"""
	console_open = not console_open
	if console_open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		interface_activated.emit("console")
		show_ub_visual("Console opened")
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		show_ub_visual("Console closed")

func toggle_inspection_mode() -> void:
	"""Toggle inspection mode for Universal Beings"""
	inspection_mode = not inspection_mode
	if inspection_mode:
		interface_activated.emit("inspector")
		show_ub_visual("Inspection mode active")
	else:
		show_ub_visual("Inspection mode disabled")

func toggle_creation_mode() -> void:
	"""Toggle creation mode for spawning beings"""
	creation_mode = not creation_mode
	if creation_mode:
		interface_activated.emit("creator")
		show_ub_visual("Creation mode active")
	else:
		show_ub_visual("Creation mode disabled")

func reset_to_spawn_point() -> void:
	"""Reset position to spawn point"""
	global_position = Vector3(0, 2, 0)
	velocity = Vector3.ZERO
	show_ub_visual("Reset to spawn")

func enter_grab_mode() -> void:
	"""Enter grab mode to move objects"""
	if current_target:
		interface_activated.emit("grab")
		show_ub_visual("Grabbed: " + current_target.name)

func pentagon_sewers() -> void:
	# Clean up UI
	if crosshair_ui:
		crosshair_ui.queue_free()
	
	super.pentagon_sewers()

# Public interface for external control
func get_camera_position() -> Vector3:
	return camera.global_position

func get_camera_direction() -> Vector3:
	return -camera.global_transform.basis.z

func set_movement_speed(speed: float) -> void:
	movement_speed = speed

func enable_socket_interaction(enabled: bool) -> void:
	crosshair_ray.enabled = enabled