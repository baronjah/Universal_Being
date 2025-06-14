# ==================================================
# SCRIPT NAME: simple_ragdoll_walker.gd
# DESCRIPTION: Walking system for 7-part ragdoll using physics forces
# PURPOSE: Make ragdoll walk upright using coordinated forces
# CREATED: 2025-05-25 - Walking ragdoll implementation
# ==================================================

extends Node3D

# Movement states
enum WalkState {
	IDLE,
	STANDING_UP,
	BALANCING,
	STEPPING,
	FALLING
}

# Current state
var current_state: WalkState = WalkState.IDLE
var walk_direction: Vector3 = Vector3.ZERO
var is_walking: bool = false

# Body parts references
var pelvis: RigidBody3D
var left_thigh: RigidBody3D
var right_thigh: RigidBody3D
var left_shin: RigidBody3D
var right_shin: RigidBody3D
var left_foot: RigidBody3D
var right_foot: RigidBody3D

# Balance parameters
var target_height: float = 1.5  # Target pelvis height
var balance_force: float = 150.0
var upright_torque: float = 50.0
var lean_angle: float = 0.1  # Slight forward lean when walking

# Walking parameters
var step_force: float = 30.0
var step_height: float = 0.3
var step_distance: float = 0.5
var step_duration: float = 0.5
var current_step_time: float = 0.0
var is_left_step: bool = true

# Ground detection
var ground_check_distance: float = 0.1
var foot_ground_threshold: float = 0.15

# Stability helpers
var com_offset: Vector3 = Vector3.ZERO  # Center of mass offset
var support_polygon: Array[Vector3] = []

func _ready() -> void:
	print("[SimpleWalker] Initializing walking system...")
	# Wait for parent to create body parts
	await get_tree().process_frame
	_find_body_parts()
	_configure_physics()
	set_physics_process(true)
	print("[SimpleWalker] Walker ready")

func _find_body_parts() -> void:
	# Get body parts from parent metadata
	var parent = get_parent()
	if parent.has_meta("body_parts"):
		var parts = parent.get_meta("body_parts")
		pelvis = parts.get("pelvis")
		left_thigh = parts.get("left_thigh")
		right_thigh = parts.get("right_thigh") 
		left_shin = parts.get("left_shin")
		right_shin = parts.get("right_shin")
		left_foot = parts.get("left_foot")
		right_foot = parts.get("right_foot")
		print("[SimpleWalker] Found all body parts")
	else:
		print("[SimpleWalker] ERROR: No body parts metadata found!")

func _configure_physics() -> void:
	# Configure each body part for walking
	var all_parts = [pelvis, left_thigh, right_thigh, left_shin, right_shin, left_foot, right_foot]
	
	for part in all_parts:
		if part:
			# Set physics properties for stability
			part.gravity_scale = 1.0
			part.linear_damp = 2.0
			part.angular_damp = 10.0
			part.continuous_cd = true
			
			# Adjust mass distribution
			if part == pelvis:
				part.mass = 15.0  # Heavy center for stability
			elif part in [left_thigh, right_thigh]:
				part.mass = 5.0
			elif part in [left_shin, right_shin]:
				part.mass = 3.0
			else:  # Feet
				part.mass = 2.0
				part.linear_damp = 5.0  # Extra damping for feet

func _physics_process(delta: float) -> void:
	if not pelvis:
		return
	
	# Update state machine
	_update_state(delta)
	
	# Apply state-specific physics
	match current_state:
		WalkState.IDLE:
			_process_idle()
		WalkState.STANDING_UP:
			_process_standing_up()
		WalkState.BALANCING:
			_process_balancing()
		WalkState.STEPPING:
			_process_stepping(delta)
		WalkState.FALLING:
			_process_falling()

func _update_state(_delta: float) -> void:
	# Check if we're falling
	if _is_falling():
		current_state = WalkState.FALLING
		return
	
	# State transitions
	match current_state:
		WalkState.IDLE:
			if is_walking:
				current_state = WalkState.STANDING_UP
		WalkState.STANDING_UP:
			if _is_upright():
				current_state = WalkState.BALANCING
		WalkState.BALANCING:
			if walk_direction.length() > 0.1:
				current_state = WalkState.STEPPING
		WalkState.STEPPING:
			if walk_direction.length() < 0.1:
				current_state = WalkState.BALANCING
		WalkState.FALLING:
			if _is_on_ground() and not _is_falling():
				current_state = WalkState.STANDING_UP

func _process_idle() -> void:
	# Apply minimal damping
	pelvis.angular_velocity *= 0.95

func _process_standing_up() -> void:
	# Get up from any position
	var pelvis_pos = pelvis.global_position
	var target_pos = Vector3(pelvis_pos.x, target_height, pelvis_pos.z)
	
	# Lift pelvis
	var lift_force = (target_pos - pelvis_pos) * balance_force
	pelvis.apply_central_force(lift_force)
	
	# Straighten legs
	_apply_leg_straightening_forces()
	
	# Prevent rotation
	_apply_upright_torque()

func _process_balancing() -> void:
	# Maintain upright position
	_maintain_height()
	_apply_upright_torque()
	_balance_over_feet()

func _process_stepping(delta: float) -> void:
	# Continue balancing while stepping
	_maintain_height()
	_apply_upright_torque()
	
	# Step cycle
	current_step_time += delta
	if current_step_time >= step_duration:
		current_step_time = 0.0
		is_left_step = !is_left_step
	
	# Apply stepping forces
	_apply_step_forces()

func _process_falling() -> void:
	# Try to land on feet
	_orient_feet_down()

# Balance and movement helpers
func _maintain_height() -> void:
	var current_height = pelvis.global_position.y
	var height_error = target_height - current_height
	
	# PD controller for height
	var lift_force = height_error * balance_force
	lift_force -= pelvis.linear_velocity.y * 20.0  # Damping
	
	pelvis.apply_central_force(Vector3.UP * lift_force)

func _apply_upright_torque() -> void:
	# Get current rotation
	var current_rotation = pelvis.rotation
	
	# Calculate torque to return to upright
	var torque = Vector3.ZERO
	torque.x = -current_rotation.x * upright_torque
	torque.z = -current_rotation.z * upright_torque
	
	# Add lean when walking
	if walk_direction.length() > 0.1:
		var lean_direction = walk_direction.normalized()
		torque.x += lean_direction.z * lean_angle * upright_torque
		torque.z -= lean_direction.x * lean_angle * upright_torque
	
	pelvis.apply_torque(torque)

func _balance_over_feet() -> void:
	# Calculate center of mass
	var com = _calculate_center_of_mass()
	
	# Get support polygon from feet positions
	var left_foot_pos = left_foot.global_position
	var right_foot_pos = right_foot.global_position
	var support_center = (left_foot_pos + right_foot_pos) * 0.5
	
	# Apply force to move COM over support
	var balance_error = Vector3(support_center.x - com.x, 0, support_center.z - com.z)
	var balance_correction = balance_error * 30.0
	
	pelvis.apply_central_force(balance_correction)

func _apply_step_forces() -> void:
	var step_phase = current_step_time / step_duration
	
	# Determine swing and stance legs
	var swing_thigh = left_thigh if is_left_step else right_thigh
	var _swing_shin = left_shin if is_left_step else right_shin
	var swing_foot = left_foot if is_left_step else right_foot
	var stance_foot = right_foot if is_left_step else left_foot
	
	# Swing phase (0.0 to 0.5)
	if step_phase < 0.5:
		# Lift knee
		var lift_force = Vector3.UP * step_force * 2.0
		swing_thigh.apply_central_force(lift_force)
		
		# Move foot forward
		var forward_force = walk_direction * step_force
		swing_foot.apply_central_force(forward_force)
		
		# Keep stance foot planted
		_stabilize_foot(stance_foot)
	else:
		# Stance phase (0.5 to 1.0)
		# Push off with foot
		var push_force = -walk_direction * step_force * 0.5
		swing_foot.apply_central_force(push_force)
		
		# Prepare for next step
		_stabilize_foot(swing_foot)

func _apply_leg_straightening_forces() -> void:
	# Apply forces to straighten legs
	var _pelvis_pos = pelvis.global_position
	
	# Pull feet under pelvis
	for foot in [left_foot, right_foot]:
		var foot_target = Vector3(foot.global_position.x, 0.1, foot.global_position.z)
		var foot_force = (foot_target - foot.global_position) * 50.0
		foot.apply_central_force(foot_force)
	
	# Push thighs down
	for thigh in [left_thigh, right_thigh]:
		thigh.apply_central_force(Vector3.DOWN * 20.0)

func _stabilize_foot(foot: RigidBody3D) -> void:
	# Reduce foot movement when it should be planted
	foot.linear_velocity *= 0.7
	foot.angular_velocity *= 0.5
	
	# Apply downward force to keep contact
	foot.apply_central_force(Vector3.DOWN * 30.0)

func _orient_feet_down() -> void:
	# Try to point feet downward when falling
	for foot in [left_foot, right_foot]:
		var current_up = foot.global_transform.basis.y
		var torque = current_up.cross(Vector3.UP) * 20.0
		foot.apply_torque(torque)

# State checks
func _is_upright() -> bool:
	var up_vector = pelvis.global_transform.basis.y
	return up_vector.dot(Vector3.UP) > 0.8

func _is_falling() -> bool:
	# Check if center of mass is outside support or rotating too fast
	return pelvis.angular_velocity.length() > 5.0 or pelvis.global_position.y < 0.5

func _is_on_ground() -> bool:
	# Check if at least one foot is near ground
	for foot in [left_foot, right_foot]:
		if foot.global_position.y < foot_ground_threshold:
			return true
	return false

func _calculate_center_of_mass() -> Vector3:
	# Weighted average of all body parts
	var total_mass = 0.0
	var weighted_pos = Vector3.ZERO
	
	var parts = [pelvis, left_thigh, right_thigh, left_shin, right_shin, left_foot, right_foot]
	for part in parts:
		if part:
			weighted_pos += part.global_position * part.mass
			total_mass += part.mass
	
	return weighted_pos / total_mass if total_mass > 0 else pelvis.global_position

# Public API
func start_walking(direction: Vector3) -> void:
	walk_direction = direction.normalized()
	is_walking = true
	print("[SimpleWalker] Starting walk in direction: " + str(walk_direction))

func stop_walking() -> void:
	walk_direction = Vector3.ZERO
	is_walking = false
	current_state = WalkState.BALANCING
	print("[SimpleWalker] Stopping walk")

func stand_up() -> void:
	current_state = WalkState.STANDING_UP
	is_walking = true
	print("[SimpleWalker] Standing up")

func get_status() -> String:
	var state_names = ["IDLE", "STANDING_UP", "BALANCING", "STEPPING", "FALLING"]
	return "State: %s, Walking: %s, Height: %.2f" % [
		state_names[current_state],
		is_walking,
		pelvis.global_position.y if pelvis else 0.0
	]