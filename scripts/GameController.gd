extends Node3D

@export var being_scene: PackedScene

@onready var player := $Player
@onready var camera := $Player/CameraRig/Camera3D
@onready var ray := $Player/CameraRig/Camera3D/RayCast3D
@onready var beings_container := $World/Beings

var selected_being: Node3D = null
var connection_start: Node3D = null
var beings_created := 0

# 6DOF Camera Variables
var mouse_sensitivity := 0.003
var camera_pitch := 0.0
var camera_yaw := 0.0
var movement_speed := 10.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print("🌌 Universal Being Game Started - FULL 6DOF CAMERA")
	print("🎮 Left Click: Create/Interact | Right Click: Connect | Middle: Drag")
	print("🚀 WASD: Move | QE: Up/Down | Mouse: Perfect 6DOF rotation")
	print("🔥 Every click creates life. Every connection creates consciousness.")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Perfect 6DOF Camera Control - NO GIMBAL LOCK
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_yaw -= event.relative.x * mouse_sensitivity
		camera_pitch -= event.relative.y * mouse_sensitivity
		camera_pitch = clamp(camera_pitch, -1.57, 1.57)  # ±90 degrees but no gimbal lock
		
		# Apply rotation using quaternions (no gimbal lock)
		var rotation_y = Quaternion(Vector3.UP, camera_yaw)
		var rotation_x = Quaternion(Vector3.RIGHT, camera_pitch)
		player.quaternion = rotation_y
		camera.get_parent().quaternion = rotation_x
	
	# Creation
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_handle_create()
	
	# Connection
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_handle_connect()
	
	# Drag
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		_handle_drag(event.pressed)

func _process(delta):
	ray.force_raycast_update()
	
	# 6DOF Movement Controls
	var input_vector := Vector3.ZERO
	
	# Forward/Backward (relative to camera)
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vector -= camera.global_transform.basis.z
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vector += camera.global_transform.basis.z
	
	# Left/Right (relative to camera)
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vector -= camera.global_transform.basis.x
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vector += camera.global_transform.basis.x
	
	# Up/Down (world space)
	if Input.is_key_pressed(KEY_Q):
		input_vector += Vector3.UP
	if Input.is_key_pressed(KEY_E):
		input_vector -= Vector3.UP
	
	# Apply movement
	if input_vector.length() > 0:
		player.global_position += input_vector.normalized() * movement_speed * delta
	
	# Update drag position
	if selected_being and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 20.0
		selected_being.global_position = from + (to - from) * 0.5

func _handle_create():
	var creation_pos: Vector3
	
	if ray.is_colliding():
		var collider = ray.get_collider()
		if collider and collider.get_parent().has_method("interact"):
			# Interact with existing being
			collider.get_parent().interact()
			return
		else:
			creation_pos = ray.get_collision_point()
	else:
		# Create in space
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 10.0
		creation_pos = to
	
	# Create new being
	var being = being_scene.instantiate()
	being.position = creation_pos
	beings_container.add_child(being)
	beings_created += 1
	
	print("✨ Being #", beings_created, " created at ", creation_pos)

func _handle_connect():
	if not ray.is_colliding():
		return
		
	var collider = ray.get_collider()
	if not collider or not collider.get_parent().has_method("connect_to"):
		return
	
	var being = collider.get_parent()
	
	if connection_start == null:
		connection_start = being
		print("🔗 Connection started from Being")
	else:
		if being != connection_start:
			connection_start.connect_to(being)
			print("⚡ Connected! Network grows stronger")
		connection_start = null

func _handle_drag(pressed: bool):
	if pressed and ray.is_colliding():
		var collider = ray.get_collider()
		if collider:
			selected_being = collider.get_parent()
	else:
		selected_being = null
