# ==================================================
# SCRIPT NAME: simple_ragdoll_walker.gd
# DESCRIPTION: Walking system for 7-part ragdoll using physics forces
# PURPOSE: Make ragdoll walk upright using coordinated forces
# CREATED: 2025-05-25 - Walking ragdoll implementation
# ==================================================

extends UniversalBeingBase
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

# Balance parameters (reduced to prevent explosion)
var target_height: float = 1.0  # Reasonable standing height
var balance_force: float = 150.0  # Gentle balance force
var upright_torque: float = 50.0  # Gentle uprighting
var lean_angle: float = 0.02  # Minimal lean
var ground_anchor_force: float = 100.0  # Moderate ground anchoring
var hip_adjustment_rate: float = 2.0  # Slower adjustment

# Walking parameters (gentler forces)
var step_force: float = 20.0  # Gentle step force
var step_height: float = 0.3  # Lower step height
var step_distance: float = 0.3  # Trigger distance
var step_duration: float = 0.5  # Step timing
var current_step_time: float = 0.0
var is_left_step: bool = true
var max_leg_spread: float = 1.0  # Reasonable spread

# Ground detection
var ground_check_distance: float = 0.1
var foot_ground_threshold: float = 0.15

# Stability helpers
var com_offset: Vector3 = Vector3.ZERO  # Center of mass offset
var support_polygon: Array[Vector3] = []

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
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
			part.linear_damp = 1.0  # Reduced for easier movement
			part.angular_damp = 5.0  # Reduced to allow rotation
			part.continuous_cd = true
			part.can_sleep = false  # Keep active
			
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


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
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
	# Phase 1: Reset to stable position
	if pelvis.global_position.y < 0.3:
		# If very low, apply gentle upward force
		pelvis.apply_central_impulse(Vector3.UP * 2.0)
		return
	
	# Phase 2: Straighten body parts
	var pelvis_pos = pelvis.global_position
	var target_pos = Vector3(pelvis_pos.x, target_height, pelvis_pos.z)
	
	# Gentle upward force based on height difference
	var height_diff = target_pos.y - pelvis_pos.y
	var lift_force = Vector3.UP * height_diff * balance_force
	pelvis.apply_central_force(lift_force)
	
	# Small additional upward force
	pelvis.apply_central_force(Vector3.UP * 50.0)
	
	# Straighten legs gently
	_apply_leg_straightening_forces()
	
	# Gentle uprighting
	_apply_upright_torque()
	
	# Position feet properly under body
	_position_feet_for_standing()
	
	# Moderate damping
	pelvis.linear_velocity *= 0.9
	pelvis.angular_velocity *= 0.8

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
	# Use global transform basis for more accurate uprighting
	var up_vector = pelvis.global_transform.basis.y
	
	# Safety check for valid vector
	if not up_vector.is_finite() or up_vector.is_zero_approx():
		return
	
	# Calculate torque to align with world up
	var torque = Vector3.ZERO
	
	# Correct tilt using cross product for proper uprighting
	var cross_product = up_vector.cross(Vector3.UP)
	if cross_product.length_squared() > 0.001:  # Avoid near-zero cross products
		var tilt_correction = cross_product * upright_torque
		torque += tilt_correction
		
		# Additional stabilization for any tilt
		if up_vector.dot(Vector3.UP) < 0.9:  # More sensitive to tilting
			torque += cross_product * upright_torque * 3.0
	
	if torque.is_finite() and not torque.is_zero_approx():
		pelvis.apply_torque(torque)
	
	# Strong angular damping to prevent oscillation
	pelvis.angular_velocity *= 0.3
	
	# Also stabilize legs
	if left_thigh and right_thigh:
		left_thigh.angular_velocity *= 0.5
		right_thigh.angular_velocity *= 0.5

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
	# Apply forces to straighten legs and position feet properly
	var pelvis_pos = pelvis.global_position
	
	# Position feet for stable stance
	var foot_separation = 0.3  # Normal stance
	var left_foot_target = Vector3(pelvis_pos.x - foot_separation/2, 0.05, pelvis_pos.z)
	var right_foot_target = Vector3(pelvis_pos.x + foot_separation/2, 0.05, pelvis_pos.z)
	
	# Gentle downward force to keep feet on ground
	left_foot.apply_central_force(Vector3.DOWN * 30.0)
	right_foot.apply_central_force(Vector3.DOWN * 30.0)
	
	# Gentle horizontal positioning forces
	var foot_force = 20.0
	var left_force = (left_foot_target - left_foot.global_position) * foot_force
	var right_force = (right_foot_target - right_foot.global_position) * foot_force
	
	# Clamp to prevent explosion
	left_force = left_force.limit_length(50.0)
	right_force = right_force.limit_length(50.0)
	
	left_foot.apply_central_force(left_force)
	right_foot.apply_central_force(right_force)
	
	# Gentle damping
	left_foot.linear_velocity *= 0.9
	right_foot.linear_velocity *= 0.9
	
	# Straighten leg segments
	var leg_straightening_force = 30.0
	
	# Push thighs toward proper position
	var left_thigh_target = Vector3(pelvis_pos.x - foot_separation/2, pelvis_pos.y - 0.3, pelvis_pos.z)
	var right_thigh_target = Vector3(pelvis_pos.x + foot_separation/2, pelvis_pos.y - 0.3, pelvis_pos.z)
	
	left_thigh.apply_central_force((left_thigh_target - left_thigh.global_position) * leg_straightening_force)
	right_thigh.apply_central_force((right_thigh_target - right_thigh.global_position) * leg_straightening_force)

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
		
		# Safety check for valid vector
		if not current_up.is_finite() or current_up.is_zero_approx():
			continue
			
		var cross_product = current_up.cross(Vector3.UP)
		if cross_product.length_squared() > 0.001:  # Avoid near-zero cross products
			var torque = cross_product * 20.0
			if torque.is_finite():
				foot.apply_torque(torque)

# State checks
func _is_upright() -> bool:
	var up_vector = pelvis.global_transform.basis.y
	var is_upright_oriented = up_vector.dot(Vector3.UP) > 0.95  # Much stricter
	var is_at_target_height = abs(pelvis.global_position.y - target_height) < 0.2
	var is_stable = pelvis.angular_velocity.length() < 1.0
	return is_upright_oriented and is_at_target_height and is_stable

func _is_falling() -> bool:
	# Check if center of mass is outside support or rotating too fast
	# Only consider falling if pelvis is very low AND rotating fast
	var is_rotating_fast = pelvis.angular_velocity.length() > 3.0
	var is_very_low = pelvis.global_position.y < 0.2
	var feet_off_ground = not _is_on_ground()
	
	# Only falling if rotating fast and very low, or if no feet touch ground and rotating
	return (is_rotating_fast and is_very_low) or (feet_off_ground and is_rotating_fast)

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

func _position_feet_for_standing() -> void:
	# Position feet directly under pelvis for stable standing
	if not pelvis or not left_foot or not right_foot:
		return
	
	var pelvis_pos = pelvis.global_position
	var foot_spread = 0.3  # Comfortable stance width
	
	# Target positions for feet
	var left_target = Vector3(pelvis_pos.x - foot_spread/2, 0.05, pelvis_pos.z)
	var right_target = Vector3(pelvis_pos.x + foot_spread/2, 0.05, pelvis_pos.z)
	
	# Apply GENTLE forces to move feet to target positions
	var positioning_force = 50.0  # Much gentler!
	var force_left = (left_target - left_foot.global_position) * positioning_force
	var force_right = (right_target - right_foot.global_position) * positioning_force
	
	# Clamp forces to prevent explosion
	force_left = force_left.limit_length(100.0)
	force_right = force_right.limit_length(100.0)
	
	left_foot.apply_central_force(force_left)
	right_foot.apply_central_force(force_right)
	
	# Gentle torque to keep feet flat
	left_foot.apply_torque(-left_foot.angular_velocity * 5.0)
	right_foot.apply_torque(-right_foot.angular_velocity * 5.0)

# Public API

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
	# Force ragdoll to stand up
	current_state = WalkState.STANDING_UP
	is_walking = false
	print("[SimpleWalker] Standing up")

func get_status() -> String:
	var state_names = ["IDLE", "STANDING_UP", "BALANCING", "STEPPING", "FALLING"]
	return "State: %s, Walking: %s, Height: %.2f" % [
		state_names[current_state],
		is_walking,
		pelvis.global_position.y if pelvis else 0.0
	]

func set_movement_input(input: Vector2) -> void:
	"""Handle movement input from console commands"""
	# Convert 2D input to 3D world direction
	var camera = get_viewport().get_camera_3d()
	if camera:
		var cam_transform = camera.global_transform
		var forward = -cam_transform.basis.z
		var right = cam_transform.basis.x
		
		forward.y = 0
		forward = forward.normalized()
		right.y = 0
		right = right.normalized()
		
		var direction = (forward * -input.y + right * input.x).normalized()
		if input.length() > 0.1:
			start_walking(direction)
		else:
			stop_walking()
	else:
		# Fallback to simple direction
		var direction = Vector3(input.x, 0, -input.y)
		if input.length() > 0.1:
			start_walking(direction)
		else:
			stop_walking()