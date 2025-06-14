# ==================================================
# SCRIPT NAME: enhanced_ragdoll_walker.gd
# DESCRIPTION: Advanced movement system with smooth transitions
# PURPOSE: Full movement capabilities - walk, run, crouch, strafe, rotate, jump
# CREATED: 2025-05-26 - Complete movement overhaul
# ==================================================

extends UniversalBeingBase
# Movement states with smooth transitions
enum MovementState {
	IDLE,
	STANDING_UP,
	WALKING,
	RUNNING,
	CROUCHING,
	CROUCH_WALKING,
	STRAFING,
	ROTATING,
	JUMPING,
	FALLING,
	LANDING
}

# Movement speeds
enum SpeedMode {
	SLOW,
	NORMAL,
	FAST
}

# State machine
var current_state: MovementState = MovementState.IDLE
var previous_state: MovementState = MovementState.IDLE
var state_transition_time: float = 0.0
var state_transition_duration: float = 0.3  # Default transition time

# Movement parameters
var current_speed_mode: SpeedMode = SpeedMode.NORMAL
var movement_speeds = {
	SpeedMode.SLOW: {"walk": 1.0, "run": 2.0, "crouch": 0.5, "strafe": 0.8},
	SpeedMode.NORMAL: {"walk": 2.0, "run": 4.0, "crouch": 1.0, "strafe": 1.5},
	SpeedMode.FAST: {"walk": 3.0, "run": 6.0, "crouch": 1.5, "strafe": 2.5}
}

# Movement input and direction
var input_vector: Vector2 = Vector2.ZERO  # Raw input
var movement_direction: Vector3 = Vector3.ZERO  # World space direction
var desired_rotation: float = 0.0
var rotation_speed: float = 3.0
var is_rotating_in_place: bool = false

# Movement command management
var active_movement_command: String = ""  # Track current command
var command_timer: float = 0.0  # For timed commands
var command_duration: float = 0.0  # How long to execute command

# Jump parameters
var jump_force: float = 8.0
var jump_forward_multiplier: float = 1.5
var can_jump: bool = true
var jump_cooldown: float = 0.5
var jump_timer: float = 0.0

# Crouch parameters
var standing_height: float = 1.0
var crouching_height: float = 0.5
var current_height: float = 1.0
var crouch_transition_speed: float = 3.0

# Body parts references
var pelvis: RigidBody3D
var spine: RigidBody3D
var head: RigidBody3D
var left_thigh: RigidBody3D
var right_thigh: RigidBody3D
var left_shin: RigidBody3D
var right_shin: RigidBody3D
var left_foot: RigidBody3D
var right_foot: RigidBody3D

# Physics parameters
var balance_force: float = 200.0
var upright_torque: float = 100.0
var movement_force: float = 50.0
var strafe_force: float = 40.0
var rotation_torque: float = 50.0

# Step cycle for walking
var step_timer: float = 0.0
var step_duration: float = 0.4
var is_left_step: bool = true

# Ground detection
var is_grounded: bool = false
var ground_check_distance: float = 0.2
var ground_normal: Vector3 = Vector3.UP

# Smooth transitions
var velocity_smoothing: float = 0.1
var rotation_smoothing: float = 0.15
var height_smoothing: float = 0.1

# Animation blend weights
var state_blend_weights: Dictionary = {}

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("[EnhancedWalker] Initializing advanced movement system...")
	
	# Initialize blend weights
	for state in MovementState.values():
		state_blend_weights[state] = 0.0
	state_blend_weights[current_state] = 1.0
	
	# Wait for body parts
	await get_tree().process_frame
	_find_body_parts()
	_configure_physics()
	
	print("[EnhancedWalker] Movement system ready!")

func _find_body_parts() -> void:
	var parent = get_parent()
	if parent.has_meta("body_parts"):
		var parts = parent.get_meta("body_parts")
		pelvis = parts.get("pelvis")
		spine = parts.get("spine")
		head = parts.get("head")
		left_thigh = parts.get("left_thigh")
		right_thigh = parts.get("right_thigh")
		left_shin = parts.get("left_shin")
		right_shin = parts.get("right_shin")
		left_foot = parts.get("left_foot")
		right_foot = parts.get("right_foot")
		print("[EnhancedWalker] Found body parts")

func _configure_physics() -> void:
	var all_parts = [pelvis, spine, head, left_thigh, right_thigh, 
					 left_shin, right_shin, left_foot, right_foot]
	
	for part in all_parts:
		if part:
			part.gravity_scale = 1.0
			part.linear_damp = 2.0
			part.angular_damp = 5.0
			part.continuous_cd = true
			part.can_sleep = false


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	if not pelvis:
		return
	
	# Update ground detection
	_update_ground_detection()
	
	# Update jump cooldown
	if jump_timer > 0:
		jump_timer -= delta
		can_jump = jump_timer <= 0
	
	# Update command timer
	if active_movement_command != "" and command_duration > 0:
		command_timer += delta
		if command_timer >= command_duration:
			print("[EnhancedWalker] Command expired: ", active_movement_command)
			_clear_movement_command()
	
	# Process input
	_process_movement_input()
	
	# Update state machine
	_update_state_machine(delta)
	
	# Blend between states
	_update_state_blending(delta)
	
	# Apply physics based on blended states
	_apply_blended_physics(delta)
	
	# Update step cycle
	_update_step_cycle(delta)

func _process_movement_input() -> void:
	# This will be called by the ragdoll controller with actual input
	# For now, process any existing input
	
	# Convert input to world space movement
	var camera = get_viewport().get_camera_3d()
	if camera and input_vector.length() > 0:
		var cam_transform = camera.global_transform
		var forward = -cam_transform.basis.z
		var right = cam_transform.basis.x
		
		forward.y = 0
		forward = forward.normalized()
		right.y = 0
		right = right.normalized()
		
		movement_direction = (forward * -input_vector.y + right * input_vector.x).normalized()

func _update_state_machine(delta: float) -> void:
	var new_state = current_state
	
	# Check for state transitions
	match current_state:
		MovementState.IDLE:
			if not is_grounded:
				new_state = MovementState.FALLING
			elif input_vector.length() > 0:
				if _is_action_safe("crouch"):
					new_state = MovementState.CROUCH_WALKING
				elif _is_action_safe("run"):
					new_state = MovementState.RUNNING
				else:
					new_state = MovementState.WALKING
			elif _is_action_safe("crouch"):
				new_state = MovementState.CROUCHING
			elif _is_action_just_pressed_safe("jump") and can_jump:
				new_state = MovementState.JUMPING
		
		MovementState.WALKING:
			if not is_grounded:
				new_state = MovementState.FALLING
			elif input_vector.length() < 0.1:
				new_state = MovementState.IDLE
			elif _is_action_safe("run"):
				new_state = MovementState.RUNNING
			elif _is_action_safe("crouch"):
				new_state = MovementState.CROUCH_WALKING
			elif _is_action_just_pressed_safe("jump") and can_jump:
				new_state = MovementState.JUMPING
			elif is_rotating_in_place:
				new_state = MovementState.ROTATING
		
		MovementState.RUNNING:
			if not is_grounded:
				new_state = MovementState.FALLING
			elif input_vector.length() < 0.1:
				new_state = MovementState.IDLE
			elif not _is_action_safe("run"):
				new_state = MovementState.WALKING
			elif _is_action_just_pressed_safe("jump") and can_jump:
				new_state = MovementState.JUMPING
		
		MovementState.CROUCHING:
			if not is_grounded:
				new_state = MovementState.FALLING
			elif not _is_action_safe("crouch"):
				new_state = MovementState.STANDING_UP
			elif input_vector.length() > 0:
				new_state = MovementState.CROUCH_WALKING
			elif _is_action_just_pressed_safe("jump") and can_jump:
				new_state = MovementState.JUMPING
		
		MovementState.CROUCH_WALKING:
			if not is_grounded:
				new_state = MovementState.FALLING
			elif not _is_action_safe("crouch"):
				new_state = MovementState.WALKING
			elif input_vector.length() < 0.1:
				new_state = MovementState.CROUCHING
		
		MovementState.JUMPING:
			if pelvis.linear_velocity.y < 0:
				new_state = MovementState.FALLING
		
		MovementState.FALLING:
			if is_grounded:
				new_state = MovementState.LANDING
		
		MovementState.LANDING:
			if state_transition_time > 0.3:
				if input_vector.length() > 0:
					new_state = MovementState.WALKING
				else:
					new_state = MovementState.IDLE
		
		MovementState.STANDING_UP:
			if state_transition_time > 0.5:
				new_state = MovementState.IDLE
		
		MovementState.ROTATING:
			if not is_rotating_in_place:
				if input_vector.length() > 0:
					new_state = MovementState.WALKING
				else:
					new_state = MovementState.IDLE
	
	# Handle state transition
	if new_state != current_state:
		_enter_state(new_state)

func _enter_state(new_state: MovementState) -> void:
	previous_state = current_state
	current_state = new_state
	state_transition_time = 0.0
	
	# State-specific initialization
	match new_state:
		MovementState.JUMPING:
			_perform_jump()
		MovementState.LANDING:
			_perform_landing()
		MovementState.STANDING_UP:
			current_height = crouching_height  # Start from crouch

func _update_state_blending(delta: float) -> void:
	state_transition_time += delta
	
	# Update blend weights with smooth transitions
	for state in MovementState.values():
		var target_weight = 1.0 if state == current_state else 0.0
		state_blend_weights[state] = lerp(
			state_blend_weights[state],
			target_weight,
			delta * 5.0  # Blend speed
		)

func _apply_blended_physics(delta: float) -> void:
	# Apply physics based on weighted blend of states
	
	# Height adjustment
	var target_height_value = standing_height
	if state_blend_weights[MovementState.CROUCHING] > 0 or \
	   state_blend_weights[MovementState.CROUCH_WALKING] > 0:
		target_height_value = lerp(standing_height, crouching_height, 
			state_blend_weights[MovementState.CROUCHING] + 
			state_blend_weights[MovementState.CROUCH_WALKING])
	
	current_height = lerp(current_height, target_height_value, delta * crouch_transition_speed)
	
	# Apply movement forces
	if state_blend_weights[MovementState.WALKING] > 0:
		_apply_walking_forces(state_blend_weights[MovementState.WALKING])
	
	if state_blend_weights[MovementState.RUNNING] > 0:
		_apply_running_forces(state_blend_weights[MovementState.RUNNING])
	
	if state_blend_weights[MovementState.CROUCH_WALKING] > 0:
		_apply_crouch_walking_forces(state_blend_weights[MovementState.CROUCH_WALKING])
	
	if state_blend_weights[MovementState.STRAFING] > 0:
		_apply_strafing_forces(state_blend_weights[MovementState.STRAFING])
	
	if state_blend_weights[MovementState.ROTATING] > 0:
		_apply_rotation_forces(state_blend_weights[MovementState.ROTATING])
	
	# Always apply balance
	_apply_balance_forces()
	_maintain_upright_posture()
	_adjust_height_to_target()

func _apply_walking_forces(weight: float) -> void:
	var speed = movement_speeds[current_speed_mode]["walk"]
	var force = movement_direction * movement_force * speed * weight
	pelvis.apply_central_force(force)
	
	# Apply stepping motion
	_apply_step_animation(weight, speed)

func _apply_running_forces(weight: float) -> void:
	var speed = movement_speeds[current_speed_mode]["run"]
	var force = movement_direction * movement_force * speed * weight * 1.5
	pelvis.apply_central_force(force)
	
	# Faster stepping
	_apply_step_animation(weight * 1.5, speed)

func _apply_crouch_walking_forces(weight: float) -> void:
	var speed = movement_speeds[current_speed_mode]["crouch"]
	var force = movement_direction * movement_force * speed * weight * 0.7
	pelvis.apply_central_force(force)
	
	# Slower, careful steps
	_apply_step_animation(weight * 0.5, speed)

func _apply_strafing_forces(weight: float) -> void:
	var speed = movement_speeds[current_speed_mode]["strafe"]
	var strafe_dir = movement_direction.cross(Vector3.UP)
	var force = strafe_dir * strafe_force * speed * weight
	pelvis.apply_central_force(force)

func _apply_rotation_forces(weight: float) -> void:
	var torque = Vector3.UP * rotation_torque * desired_rotation * weight
	pelvis.apply_torque(torque)

func _apply_step_animation(weight: float, _speed: float) -> void:
	var step_phase = fmod(step_timer / step_duration, 1.0)
	
	# Determine which leg to move
	var swing_thigh = left_thigh if is_left_step else right_thigh
	var _swing_shin = left_shin if is_left_step else right_shin
	var swing_foot = left_foot if is_left_step else right_foot
	
	# Smooth sine wave for natural stepping
	var lift_amount = sin(step_phase * PI) * 0.3 * weight
	var forward_amount = cos(step_phase * PI) * 0.2 * weight
	
	# Apply forces
	swing_thigh.apply_central_force(Vector3.UP * lift_amount * 100)
	swing_foot.apply_central_force(movement_direction * forward_amount * 50)

func _apply_balance_forces() -> void:
	# Keep pelvis at target height
	var height_error = current_height - pelvis.global_position.y
	var lift_force = height_error * balance_force
	lift_force -= pelvis.linear_velocity.y * 20.0  # Damping
	pelvis.apply_central_force(Vector3.UP * lift_force)
	
	# Balance over feet
	var com = _calculate_center_of_mass()
	var support_center = (left_foot.global_position + right_foot.global_position) * 0.5
	var balance_error = Vector3(support_center.x - com.x, 0, support_center.z - com.z)
	pelvis.apply_central_force(balance_error * 50.0)

func _maintain_upright_posture() -> void:
	# Calculate current tilt
	var up_vector = pelvis.global_transform.basis.y
	var tilt_error = up_vector.cross(Vector3.UP)
	
	# Apply corrective torque
	var correction_torque = tilt_error * upright_torque
	pelvis.apply_torque(correction_torque)
	
	# Extra stability for spine and head
	if spine:
		spine.apply_torque(correction_torque * 0.5)
	if head:
		head.apply_torque(correction_torque * 0.3)
	
	# Damping to prevent oscillation
	pelvis.angular_velocity *= 0.8

func _adjust_height_to_target() -> void:
	# Adjust leg positions for crouch/stand
	if current_height < standing_height:
		# Bend knees for crouch
		var crouch_factor = 1.0 - (current_height / standing_height)
		left_thigh.apply_torque(Vector3.RIGHT * crouch_factor * 20)
		right_thigh.apply_torque(Vector3.RIGHT * crouch_factor * 20)

func _update_step_cycle(delta: float) -> void:
	if current_state in [MovementState.WALKING, MovementState.RUNNING, MovementState.CROUCH_WALKING]:
		step_timer += delta
		if step_timer >= step_duration:
			step_timer = 0.0
			is_left_step = !is_left_step

func _perform_jump() -> void:
	can_jump = false
	jump_timer = jump_cooldown
	
	# Apply jump impulse
	var jump_impulse = Vector3.UP * jump_force
	
	# Add forward momentum if moving
	if movement_direction.length() > 0:
		jump_impulse += movement_direction * jump_force * jump_forward_multiplier * 0.3
	
	pelvis.apply_central_impulse(jump_impulse)
	
	# Slight leg extension
	left_foot.apply_central_impulse(Vector3.DOWN * 2)
	right_foot.apply_central_impulse(Vector3.DOWN * 2)

func _perform_landing() -> void:
	# Absorb impact
	var impact_force = pelvis.linear_velocity.y * -0.5
	left_thigh.apply_central_impulse(Vector3.UP * impact_force)
	right_thigh.apply_central_impulse(Vector3.UP * impact_force)

func _update_ground_detection() -> void:
	# Simple ground check from feet
	var space_state = get_tree().root.get_world_3d().direct_space_state
	
	var left_check = PhysicsRayQueryParameters3D.new()
	left_check.from = left_foot.global_position
	left_check.to = left_foot.global_position + Vector3.DOWN * ground_check_distance
	
	var right_check = PhysicsRayQueryParameters3D.new()
	right_check.from = right_foot.global_position
	right_check.to = right_foot.global_position + Vector3.DOWN * ground_check_distance
	
	var left_result = space_state.intersect_ray(left_check)
	var right_result = space_state.intersect_ray(right_check)
	
	is_grounded = left_result or right_result
	
	if left_result and right_result:
		ground_normal = ((left_result.normal + right_result.normal) * 0.5).normalized()
	elif left_result:
		ground_normal = left_result.normal
	elif right_result:
		ground_normal = right_result.normal

func _calculate_center_of_mass() -> Vector3:
	var total_mass = 0.0
	var weighted_position = Vector3.ZERO
	
	var parts = [pelvis, spine, head, left_thigh, right_thigh, 
				 left_shin, right_shin, left_foot, right_foot]
	
	for part in parts:
		if part:
			total_mass += part.mass
			weighted_position += part.global_position * part.mass
	
	return weighted_position / total_mass if total_mass > 0 else pelvis.global_position

# Public interface for controlling movement

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func set_movement_input(input: Vector2) -> void:
	input_vector = input

func set_speed_mode(mode: SpeedMode) -> void:
	current_speed_mode = mode

func set_rotation_input(rotation: float) -> void:
	desired_rotation = rotation
	is_rotating_in_place = abs(rotation) > 0.1 and input_vector.length() < 0.1

func trigger_jump() -> void:
	if can_jump and is_grounded:
		_enter_state(MovementState.JUMPING)

func trigger_crouch(pressed: bool) -> void:
	# This will be handled by input system
	pass

# New command system to prevent stacking
func execute_movement_command(command: String, duration: float = -1.0) -> void:
	"""Execute a movement command, clearing any previous command"""
	print("[EnhancedWalker] Executing command: ", command)
	
	# Clear previous command
	_clear_movement_command()
	
	# Set new command
	active_movement_command = command
	command_timer = 0.0
	command_duration = duration
	
	# Parse and apply command
	match command.to_lower():
		"forward", "move_forward":
			set_movement_input(Vector2(0, -1))
		"backward", "move_backward":
			set_movement_input(Vector2(0, 1))
		"left", "strafe_left":
			set_movement_input(Vector2(-1, 0))
		"right", "strafe_right":
			set_movement_input(Vector2(1, 0))
		"stop", "idle":
			set_movement_input(Vector2.ZERO)
			set_rotation_input(0.0)
		"rotate_left":
			set_rotation_input(-1.0)
		"rotate_right":
			set_rotation_input(1.0)
		"jump":
			trigger_jump()
		"crouch":
			# TODO: Implement crouch toggle
			pass
		"run":
			set_speed_mode(SpeedMode.FAST)
		"walk":
			set_speed_mode(SpeedMode.NORMAL)
		"slow":
			set_speed_mode(SpeedMode.SLOW)
		_:
			print("[EnhancedWalker] Unknown command: ", command)

func _clear_movement_command() -> void:
	"""Clear current movement command and reset to idle"""
	active_movement_command = ""
	command_timer = 0.0
	command_duration = 0.0
	set_movement_input(Vector2.ZERO)
	set_rotation_input(0.0)

func get_current_state() -> MovementState:
	return current_state

func get_state_name() -> String:
	match current_state:
		MovementState.IDLE: return "Idle"
		MovementState.STANDING_UP: return "Standing Up"
		MovementState.WALKING: return "Walking"
		MovementState.RUNNING: return "Running"
		MovementState.CROUCHING: return "Crouching"
		MovementState.CROUCH_WALKING: return "Crouch Walking"
		MovementState.STRAFING: return "Strafing"
		MovementState.ROTATING: return "Rotating"
		MovementState.JUMPING: return "Jumping"
		MovementState.FALLING: return "Falling"
		MovementState.LANDING: return "Landing"
		_: return "Unknown"

# Helper functions to safely check input actions
func _is_action_safe(action: String) -> bool:
	if InputMap.has_action(action):
		return Input.is_action_pressed(action)
	return false

func _is_action_just_pressed_safe(action: String) -> bool:
	if InputMap.has_action(action):
		return Input.is_action_just_pressed(action)
	return false