extends CharacterBody3D

"""
🌟 SIMPLE MOVABLE PLASMOID - Clean, working WASD movement
Perfect for testing the 10 commandments without scriptura dependencies
"""

@export var movement_speed: float = 5.0
@export var acceleration: float = 10.0
@export var friction: float = 10.0

var input_vector: Vector3 = Vector3.ZERO

func _ready():
	print("🌟 Simple Movable Plasmoid: Ready for WASD movement!")
	print("✅ Use WASD to move, Space/Shift for up/down")

func _physics_process(delta):
	handle_input()
	apply_movement(delta)
	move_and_slide()

func handle_input():
	"""Handle WASD + Space/Shift input - Universal Being commandment #5"""
	input_vector = Vector3.ZERO
	
	# WASD movement
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("move_forward"):    # W
		input_vector.z -= 1
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("move_backward"):  # S
		input_vector.z += 1
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("move_left"):   # A
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("move_right"): # D
		input_vector.x += 1
	
	# Vertical movement (Q/E or Space/Shift)
	if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("jump"):  # Space
		input_vector.y += 1
	if Input.is_action_pressed("ui_cancel"):  # Shift/Escape
		input_vector.y -= 1
	
	# Normalize to prevent faster diagonal movement
	if input_vector.length() > 0:
		input_vector = input_vector.normalized()

func apply_movement(delta):
	"""Apply smooth movement with acceleration and friction"""
	if input_vector.length() > 0:
		# Accelerate towards input direction
		velocity = velocity.move_toward(input_vector * movement_speed, acceleration * delta)
	else:
		# Apply friction when no input
		velocity = velocity.move_toward(Vector3.ZERO, friction * delta)

func _input(event):
	"""Handle discrete input events"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				print("🎯 Plasmoid position: " + str(global_position))
			KEY_2:
				print("⚡ Plasmoid velocity: " + str(velocity))
			KEY_3:
				print("🌟 Simple Plasmoid: All systems working!")
