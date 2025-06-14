extends Node
## Camera Controller class for smooth 3D movement
class_name CameraController

var camera: Camera3D
var rotation_speed: float = 2.0
var movement_speed: float = 5.0
var zoom_speed: float = 10.0
var mouse_sensitivity: float = 0.005

var is_rotating: bool = false
var rotation_start_pos: Vector2

func initialize(camera_node: Camera3D) -> void:
	camera = camera_node
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_rotating = event.pressed
			rotation_start_pos = event.position
		# Mouse wheel disabled - handled by main controller for layer navigation
		# elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
		#	_zoom_camera(-1)
		# elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		#	_zoom_camera(1)
	
	elif event is InputEventMouseMotion and is_rotating:
		_rotate_camera(event.relative)

func update(delta: float) -> void:
	_handle_movement_input(delta)

func _handle_movement_input(delta: float) -> void:
	var input_vector = Vector3.ZERO
	
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.z -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.z += 1
	
	if input_vector != Vector3.ZERO:
		input_vector = input_vector.normalized()
		var movement = input_vector * movement_speed * delta
		camera.translate(movement)

func _rotate_camera(relative: Vector2) -> void:
	var rotation_delta = relative * mouse_sensitivity
	camera.rotate_y(-rotation_delta.x)
	camera.rotate_object_local(Vector3.RIGHT, -rotation_delta.y)
	
	# Clamp vertical rotation
	var current_rotation = camera.rotation_degrees
	current_rotation.x = clamp(current_rotation.x, -80, 80)
	camera.rotation_degrees = current_rotation

func _zoom_camera(direction: int) -> void:
	var zoom_delta = direction * zoom_speed * 0.1
	camera.translate(Vector3(0, 0, zoom_delta))