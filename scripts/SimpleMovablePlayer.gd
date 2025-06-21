extends CharacterBody3D
class_name SimpleMovablePlayer

## 🎮 Simple Movable Player for Universal Being
## Features WASD movement with perfect trackball camera integration

@export var speed: float = 8.0
@export var jump_velocity: float = 12.0
@export var mouse_sensitivity: float = 0.003

# Camera reference
var camera: PerfectTrackballCamera3D
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	print("🎮 Simple Movable Player ready - WASD to move, Space to jump, Mouse to look")
	
	# Find camera in children
	camera = find_child("PerfectTrackballCamera3D") as PerfectTrackballCamera3D
	if not camera:
		print("⚠️ No PerfectTrackballCamera3D found in children")

func _physics_process(delta):
	# Handle gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get input direction and movement
	var input_dir = Vector2.ZERO
	
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_dir.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_dir.y += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_dir.x += 1

	# Calculate movement direction based on camera orientation
	var direction = Vector3.ZERO
	if camera:
		var camera_basis = camera.get_global_transform().basis
		direction = (camera_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		direction.y = 0  # Keep movement horizontal
	else:
		direction = Vector3(input_dir.x, 0, input_dir.y)

	if direction != Vector3.ZERO:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		print("🚀 Moving direction: %s" % direction)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()