extends UniversalBeing
class_name PlayerUniversalBeing

# Player consciousness and movement
@export var movement_speed: float = 8.0
@export var rotation_speed: float = 3.0
@export var jump_force: float = 12.0

var velocity: Vector3 = Vector3.ZERO
var camera: Camera3D

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_name = "Player"
	being_type = "player"
	consciousness_level = 3  # Players start aware
	telepathic_enabled = true

func pentagon_ready() -> void:
	super.pentagon_ready()
	camera = get_viewport().get_camera_3d()
	add_to_group("player")
	print("🎮 Player Being Ready - Consciousness Level: %d" % consciousness_level)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	_handle_movement(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_PAGEUP:
				elevate_consciousness()
			KEY_PAGEDOWN:
				diminish_consciousness()

func pentagon_sewers() -> void:
	print("🎮 Player Being shutting down...")
	super.pentagon_sewers()

# ===== PLAYER MOVEMENT =====

func _handle_movement(delta: float) -> void:
	var input_vector = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		input_vector.z -= 1
	if Input.is_action_pressed("move_backward"):
		input_vector.z += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		velocity.x = input_vector.x * movement_speed
		velocity.z = input_vector.z * movement_speed
	else:
		velocity.x = lerp(velocity.x, 0.0, 10.0 * delta)
		velocity.z = lerp(velocity.z, 0.0, 10.0 * delta)
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_force
		create_consciousness_ripple(global_position)
	
	global_position += velocity * delta