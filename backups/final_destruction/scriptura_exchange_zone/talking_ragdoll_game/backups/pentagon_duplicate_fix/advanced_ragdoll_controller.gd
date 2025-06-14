# ==================================================
# SCRIPT NAME: advanced_ragdoll_controller.gd
# DESCRIPTION: Main controller integrating all ragdoll v2 systems
# PURPOSE: Coordinate ground detection, animation, and IK for realistic movement
# CREATED: 2025-05-26 - Complete ragdoll system overhaul
# ==================================================

extends UniversalBeingBase
class_name AdvancedRagdollController

# Movement states
enum MovementState {
	IDLE,
	PREPARING,      # Getting ready to move
	WALKING,
	RUNNING, 
	TURNING,
	CROUCHING,
	JUMPING,
	FALLING,
	RECOVERING,     # Getting back up
	INTERACTING     # Picking up objects, etc.
}

# State machine
var current_state: MovementState = MovementState.IDLE
var previous_state: MovementState = MovementState.IDLE
var state_timer: float = 0.0

# Movement input
var movement_input: Vector2 = Vector2.ZERO
var turn_input: float = 0.0
var desired_speed: float = 2.0  # m/s
var actual_velocity: Vector3 = Vector3.ZERO

# Systems
var ground_detection: GroundDetectionSystem
var animation_system: KeypointAnimationSystem
var ik_solver: IKSolver

# Body parts
var body_parts: Dictionary = {}
var pelvis: RigidBody3D
var spine: RigidBody3D
var head: RigidBody3D

# Foot tracking
var left_foot_grounded: bool = false
var right_foot_grounded: bool = false
var last_left_foot_pos: Vector3 = Vector3.ZERO
var last_right_foot_pos: Vector3 = Vector3.ZERO
var next_step_foot: String = "left_foot"  # Which foot steps next

# Balance control
var center_of_mass: Vector3 = Vector3.ZERO
var support_polygon: Array = []  # Points defining stable base
var balance_margin: float = 0.0  # How close to falling
var is_balanced: bool = true

# Physics parameters
var upright_force: float = 200.0
var movement_force: float = 50.0
var turn_torque: float = 30.0
var max_force: float = 300.0

# Step planning
var planned_foot_position: Vector3 = Vector3.ZERO
var step_height: float = 0.15
var step_length: float = 0.4
var step_progress: float = 0.0

# Debug
var debug_enabled: bool = true

signal state_changed(old_state: MovementState, new_state: MovementState)
# signal step_taken(foot_name: String, position: Vector3)  # Currently unused but kept for future expansion
signal balance_lost()
signal balance_recovered()

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("[AdvancedRagdoll] Initializing advanced ragdoll controller...")
	
	# Create subsystems
	_create_subsystems()
	
	# Wait for body parts setup
	await get_tree().process_frame


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

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
func initialize_ragdoll(parts: Dictionary) -> void:
	"""Initialize with body parts dictionary"""
	body_parts = parts
	
	# Get key parts
	pelvis = parts.get("pelvis")
	spine = parts.get("spine") 
	head = parts.get("head")
	
	if not pelvis:
		push_error("No pelvis found in ragdoll!")
		return
	
	# Pass to subsystems (with safety check)
	if ground_detection:
		ground_detection.set_body_parts(parts)
	else:
		push_error("[AdvancedRagdoll] Ground detection system not initialized!")
		
	if animation_system:
		animation_system.set_body_parts(parts)
	else:
		push_error("[AdvancedRagdoll] Animation system not initialized!")
		
	if ik_solver:
		ik_solver.set_body_parts(parts)
	else:
		push_error("[AdvancedRagdoll] IK solver not initialized!")
	
	# Connect systems
	if animation_system and ground_detection:
		animation_system.set_ground_detection(ground_detection)
	
	# Start in idle
	_change_state(MovementState.IDLE)
	
	print("[AdvancedRagdoll] Initialization complete!")

func _create_subsystems() -> void:
	"""Create and add subsystem nodes"""
	# Ground detection
	ground_detection = GroundDetectionSystem.new()
	ground_detection.name = "GroundDetection"
	add_child(ground_detection)
	
	# Animation system
	animation_system = KeypointAnimationSystem.new()
	animation_system.name = "AnimationSystem"
	add_child(animation_system)
	
	# IK solver
	ik_solver = IKSolver.new()
	ik_solver.name = "IKSolver"
	add_child(ik_solver)


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	if not pelvis:
		return
	
	# Update state timer
	state_timer += delta
	
	# Update systems
	_update_ground_state()
	_update_balance()
	_update_velocity()
	
	# State machine update
	_update_state_machine(delta)
	
	# Apply physics
	_apply_movement_physics(delta)
	_apply_balance_physics(delta)
	
	# Update animation
	animation_system.update_animation(delta)
	
	# Apply IK to reach animation goals
	_apply_ik_to_animation_goals()

func _update_ground_state() -> void:
	"""Check which feet are on the ground"""
	var left_info = ground_detection.get_foot_ground_info("left_foot")
	var right_info = ground_detection.get_foot_ground_info("right_foot")
	
	left_foot_grounded = left_info.hit and left_info.distance < 0.1
	right_foot_grounded = right_info.hit and right_info.distance < 0.1
	
	# Update last grounded positions
	if left_foot_grounded:
		last_left_foot_pos = left_info.position
	if right_foot_grounded:
		last_right_foot_pos = right_info.position

func _update_balance() -> void:
	"""Calculate balance state"""
	if not pelvis:
		return
	
	# Calculate center of mass
	center_of_mass = _calculate_center_of_mass()
	
	# Define support polygon from grounded feet
	support_polygon.clear()
	if left_foot_grounded:
		support_polygon.append(last_left_foot_pos)
	if right_foot_grounded:
		support_polygon.append(last_right_foot_pos)
	
	# Check if COM is over support
	if support_polygon.size() >= 1:
		is_balanced = _is_point_in_polygon(center_of_mass, support_polygon)
		
		# Calculate margin (distance to edge)
		if is_balanced and support_polygon.size() == 2:
			var line_dist = _point_to_line_distance(
				center_of_mass,
				support_polygon[0],
				support_polygon[1]
			)
			balance_margin = line_dist
	else:
		is_balanced = false
		balance_margin = 0.0

func _update_velocity() -> void:
	"""Track actual movement velocity"""
	if pelvis:
		actual_velocity = pelvis.linear_velocity
		# Remove vertical component for movement calculations
		actual_velocity.y = 0

func _update_state_machine(delta: float) -> void:
	"""Main state machine logic"""
	match current_state:
		MovementState.IDLE:
			_update_idle_state(delta)
		MovementState.PREPARING:
			_update_preparing_state(delta)
		MovementState.WALKING:
			_update_walking_state(delta)
		MovementState.RUNNING:
			_update_running_state(delta)
		MovementState.TURNING:
			_update_turning_state(delta)
		MovementState.FALLING:
			_update_falling_state(delta)
		MovementState.RECOVERING:
			_update_recovering_state(delta)

func _update_idle_state(_delta: float) -> void:
	"""Update idle state"""
	# Play idle animation
	if animation_system.current_cycle == null or animation_system.current_cycle.name != "idle":
		animation_system.play_cycle("idle")
	
	# Check for movement input
	if movement_input.length() > 0.1:
		_change_state(MovementState.PREPARING)
	
	# Check for falling
	if not is_balanced and not (left_foot_grounded or right_foot_grounded):
		_change_state(MovementState.FALLING)

func _update_preparing_state(_delta: float) -> void:
	"""Prepare to start moving"""
	# Brief state to ensure balance before walking
	if state_timer > 0.2:
		if actual_velocity.length() > 3.0:
			_change_state(MovementState.RUNNING)
		else:
			_change_state(MovementState.WALKING)

func _update_walking_state(_delta: float) -> void:
	"""Update walking state"""
	# Play walk animation
	if animation_system.current_cycle == null or animation_system.current_cycle.name != "walk":
		animation_system.play_cycle("walk")
	
	# Check for state changes
	if movement_input.length() < 0.1:
		_change_state(MovementState.IDLE)
	elif actual_velocity.length() > 4.0:
		_change_state(MovementState.RUNNING)
	elif not is_balanced:
		_change_state(MovementState.FALLING)
	
	# Plan next step
	_plan_next_step()

func _update_running_state(_delta: float) -> void:
	"""Update running state"""
	# Play run animation
	if animation_system.current_cycle == null or animation_system.current_cycle.name != "run":
		animation_system.play_cycle("run")
	
	# Check for state changes
	if movement_input.length() < 0.1:
		_change_state(MovementState.IDLE)
	elif actual_velocity.length() < 3.0:
		_change_state(MovementState.WALKING)
	elif not is_balanced:
		_change_state(MovementState.FALLING)

func _update_turning_state(_delta: float) -> void:
	"""Update turning state"""
	if state_timer > 0.5:  # Turn duration
		_change_state(MovementState.IDLE)

func _update_falling_state(_delta: float) -> void:
	"""Update falling state"""
	# Check if landed
	if left_foot_grounded or right_foot_grounded:
		_change_state(MovementState.RECOVERING)

func _update_recovering_state(_delta: float) -> void:
	"""Update recovery state"""
	# Try to regain balance
	if state_timer > 1.0 and is_balanced:
		_change_state(MovementState.IDLE)

func _plan_next_step() -> void:
	"""Plan where to place the next foot"""
	if not movement_input:
		return
	
	# Get movement direction in world space
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var forward = -camera.global_transform.basis.z
	var right = camera.global_transform.basis.x
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()
	
	var move_direction = (forward * -movement_input.y + right * movement_input.x).normalized()
	
	# Calculate next foot position
	var current_foot = body_parts.get(next_step_foot)
	if current_foot:
		var safe_position = ground_detection.get_safe_foot_placement(
			current_foot.global_position,
			move_direction,
			step_length
		)
		planned_foot_position = safe_position

func _apply_movement_physics(_delta: float) -> void:
	"""Apply forces for movement"""
	if not pelvis or movement_input.length() < 0.1:
		return
	
	# Get movement direction
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	var forward = -camera.global_transform.basis.z
	var right = camera.global_transform.basis.x
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()
	
	var move_direction = (forward * -movement_input.y + right * movement_input.x).normalized()
	
	# Apply movement force
	var force = move_direction * movement_force * movement_input.length()
	
	# Scale by state
	match current_state:
		MovementState.WALKING:
			force *= 1.0
		MovementState.RUNNING:
			force *= 2.0
		MovementState.CROUCHING:
			force *= 0.5
	
	# Limit maximum force
	force = force.limit_length(max_force)
	
	# Apply to pelvis
	pelvis.apply_central_force(force)
	
	# Apply turn torque if needed
	if abs(turn_input) > 0.1:
		pelvis.apply_torque(Vector3.UP * turn_input * turn_torque)

func _apply_balance_physics(_delta: float) -> void:
	"""Apply forces to maintain balance"""
	if not pelvis:
		return
	
	# Upright torque
	var up_vector = pelvis.global_transform.basis.y
	var tilt_error = up_vector.cross(Vector3.UP)
	var correction_torque = tilt_error * upright_force
	
	pelvis.apply_torque(correction_torque)
	
	# Extra stability for spine and head
	if spine:
		spine.apply_torque(correction_torque * 0.7)
	if head:
		head.apply_torque(correction_torque * 0.5)
	
	# Height maintenance
	var target_height = 1.0  # Default standing height
	match current_state:
		MovementState.CROUCHING:
			target_height = 0.6
	
	var height_error = target_height - pelvis.global_position.y
	var lift_force = Vector3.UP * height_error * 100.0
	lift_force -= Vector3.UP * pelvis.linear_velocity.y * 10.0  # Damping
	
	pelvis.apply_central_force(lift_force)

func _apply_ik_to_animation_goals() -> void:
	"""Use IK to move limbs towards animation goals"""
	# Get current animation goals
	var goals = {}
	
	# Feet
	goals["left_leg"] = animation_system.get_limb_goal("left_foot")
	goals["right_leg"] = animation_system.get_limb_goal("right_foot")
	
	# Hands (if needed)
	goals["left_arm"] = animation_system.get_limb_goal("left_hand")
	goals["right_arm"] = animation_system.get_limb_goal("right_hand")
	
	# Apply IK
	ik_solver.solve_all_chains(goals)

func _calculate_center_of_mass() -> Vector3:
	"""Calculate the center of mass of all body parts"""
	var total_mass = 0.0
	var weighted_position = Vector3.ZERO
	
	for part_name in body_parts:
		var part = body_parts[part_name]
		if part and part is RigidBody3D:
			total_mass += part.mass
			weighted_position += part.global_position * part.mass
	
	if total_mass > 0:
		return weighted_position / total_mass
	else:
		return pelvis.global_position if pelvis else Vector3.ZERO

func _is_point_in_polygon(point: Vector3, polygon: Array) -> bool:
	"""Check if point is inside support polygon (2D check on XZ plane)"""
	if polygon.size() < 1:
		return false
	
	if polygon.size() == 1:
		# Single point support
		var dist = Vector2(point.x - polygon[0].x, point.z - polygon[0].z).length()
		return dist < 0.1  # Within 10cm
	
	if polygon.size() == 2:
		# Line support
		var dist = _point_to_line_distance(point, polygon[0], polygon[1])
		return dist < 0.1  # Within 10cm of line
	
	# Full polygon (not implemented for now)
	return true

func _point_to_line_distance(point: Vector3, line_start: Vector3, line_end: Vector3) -> float:
	"""Calculate distance from point to line segment"""
	var line = line_end - line_start
	var t = clamp((point - line_start).dot(line) / line.dot(line), 0.0, 1.0)
	var closest = line_start + line * t
	return Vector2(point.x - closest.x, point.z - closest.z).length()

func _change_state(new_state: MovementState) -> void:
	"""Change to a new movement state"""
	if new_state == current_state:
		return
	
	previous_state = current_state
	current_state = new_state
	state_timer = 0.0
	
	print("[AdvancedRagdoll] State changed: ", MovementState.keys()[previous_state], " -> ", MovementState.keys()[new_state])
	state_changed.emit(previous_state, new_state)
	
	# Handle state entry
	match new_state:
		MovementState.FALLING:
			if previous_state != MovementState.RECOVERING:
				balance_lost.emit()
		MovementState.IDLE:
			if previous_state == MovementState.RECOVERING:
				balance_recovered.emit()

# Public interface
func set_movement_input(input: Vector2) -> void:
	"""Set movement input from player"""
	movement_input = input.limit_length(1.0)

func set_turn_input(input: float) -> void:
	"""Set turning input"""
	turn_input = clamp(input, -1.0, 1.0)

func set_desired_speed(speed: float) -> void:
	"""Set target movement speed"""
	desired_speed = clamp(speed, 0.0, 10.0)

func execute_action(action: String) -> void:
	"""Execute a specific action"""
	match action:
		"jump":
			if current_state in [MovementState.IDLE, MovementState.WALKING]:
				# TODO: Implement jump
				pass
		"crouch":
			if current_state == MovementState.IDLE:
				_change_state(MovementState.CROUCHING)
		"interact":
			if current_state == MovementState.IDLE:
				_change_state(MovementState.INTERACTING)

func get_state_info() -> Dictionary:
	"""Get current state information"""
	return {
		"state": MovementState.keys()[current_state],
		"state_time": state_timer,
		"balanced": is_balanced,
		"balance_margin": balance_margin,
		"left_foot_grounded": left_foot_grounded,
		"right_foot_grounded": right_foot_grounded,
		"velocity": actual_velocity.length(),
		"animation": animation_system.get_animation_state()
	}