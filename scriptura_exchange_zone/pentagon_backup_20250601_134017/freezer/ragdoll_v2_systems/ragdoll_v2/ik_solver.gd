# ==================================================
# SCRIPT NAME: ik_solver.gd
# DESCRIPTION: Inverse Kinematics solver for ragdoll limbs
# PURPOSE: Move limbs towards keypoint goals while respecting physics
# CREATED: 2025-05-26 - Complete ragdoll system overhaul
# ==================================================

extends UniversalBeingBase
class_name IKSolver

# IK chain definition
class IKChain:
	var name: String = ""
	var root: RigidBody3D = null      # e.g., thigh
	var middle: RigidBody3D = null    # e.g., shin
	var end: RigidBody3D = null       # e.g., foot
	var pole_target: Vector3 = Vector3.ZERO  # For knee/elbow direction
	var constraints: Dictionary = {
		"min_angle": 0.0,      # Minimum bend angle (degrees)
		"max_angle": 150.0,    # Maximum bend angle (degrees)
		"twist_limit": 45.0    # Max twist around bone axis
	}

# Solver parameters
const MAX_ITERATIONS: int = 10
const POSITION_THRESHOLD: float = 0.01
const FORCE_MULTIPLIER: float = 100.0
const TORQUE_MULTIPLIER: float = 50.0
const DAMPING_FACTOR: float = 0.8

# IK chains
var ik_chains: Dictionary = {}

# Body parts reference
var body_parts: Dictionary = {}

# Debug visualization
var debug_enabled: bool = true
var debug_lines: Array = []

func _ready() -> void:
	print("[IKSolver] Initializing IK solver...")


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
func set_body_parts(parts: Dictionary) -> void:
	"""Setup IK chains from body parts"""
	body_parts = parts
	_setup_ik_chains()

func _setup_ik_chains() -> void:
	"""Create IK chains for limbs"""
	# Left leg chain
	if _has_parts(["left_thigh", "left_shin", "left_foot"]):
		var left_leg = IKChain.new()
		left_leg.name = "left_leg"
		left_leg.root = body_parts["left_thigh"]
		left_leg.middle = body_parts["left_shin"]
		left_leg.end = body_parts["left_foot"]
		left_leg.pole_target = Vector3(-0.2, 0, 0.2)  # Knee points slightly outward
		ik_chains["left_leg"] = left_leg
	
	# Right leg chain
	if _has_parts(["right_thigh", "right_shin", "right_foot"]):
		var right_leg = IKChain.new()
		right_leg.name = "right_leg"
		right_leg.root = body_parts["right_thigh"]
		right_leg.middle = body_parts["right_shin"]
		right_leg.end = body_parts["right_foot"]
		right_leg.pole_target = Vector3(0.2, 0, 0.2)  # Knee points slightly outward
		ik_chains["right_leg"] = right_leg
	
	# Left arm chain
	if _has_parts(["left_upper_arm", "left_forearm", "left_hand"]):
		var left_arm = IKChain.new()
		left_arm.name = "left_arm"
		left_arm.root = body_parts["left_upper_arm"]
		left_arm.middle = body_parts["left_forearm"]
		left_arm.end = body_parts["left_hand"]
		left_arm.pole_target = Vector3(-0.3, -0.2, 0)  # Elbow points outward
		ik_chains["left_arm"] = left_arm
	
	# Right arm chain
	if _has_parts(["right_upper_arm", "right_forearm", "right_hand"]):
		var right_arm = IKChain.new()
		right_arm.name = "right_arm"
		right_arm.root = body_parts["right_upper_arm"]
		right_arm.middle = body_parts["right_forearm"]
		right_arm.end = body_parts["right_hand"]
		right_arm.pole_target = Vector3(0.3, -0.2, 0)  # Elbow points outward
		ik_chains["right_arm"] = right_arm
	
	print("[IKSolver] Created ", ik_chains.size(), " IK chains")

func _has_parts(part_names: Array) -> bool:
	"""Check if all required parts exist"""
	for part_name in part_names:
		if not part_name in body_parts or not body_parts[part_name]:
			return false
	return true

func solve_chain(chain_name: String, target_position: Vector3, weight: float = 1.0) -> void:
	"""Solve IK for a specific chain"""
	if not chain_name in ik_chains:
		return
	
	var chain = ik_chains[chain_name]
	
	# Use physics-based IK instead of direct positioning
	_solve_two_bone_ik_physics(chain, target_position, weight)

func _solve_two_bone_ik_physics(chain: IKChain, target: Vector3, weight: float) -> void:
	"""Solve two-bone IK using physics forces"""
	if not chain.root or not chain.middle or not chain.end:
		return
	
	# Get current positions
	var root_pos = chain.root.global_position
	var middle_pos = chain.middle.global_position
	var end_pos = chain.end.global_position
	
	# Calculate bone lengths
	var upper_length = root_pos.distance_to(middle_pos)
	var lower_length = middle_pos.distance_to(end_pos)
	var total_length = upper_length + lower_length
	
	# Check if target is reachable
	var target_distance = root_pos.distance_to(target)
	if target_distance > total_length * 0.98:  # Allow slight stretch
		# Target too far - extend towards it
		var direction = (target - root_pos).normalized()
		target = root_pos + direction * total_length * 0.98
		target_distance = total_length * 0.98
	
	# Calculate joint angles using law of cosines
	var cos_angle_upper = (upper_length * upper_length + target_distance * target_distance - lower_length * lower_length) / (2.0 * upper_length * target_distance)
	var cos_angle_lower = (upper_length * upper_length + lower_length * lower_length - target_distance * target_distance) / (2.0 * upper_length * lower_length)
	
	# Clamp to valid range
	cos_angle_upper = clamp(cos_angle_upper, -1.0, 1.0)
	cos_angle_lower = clamp(cos_angle_lower, -1.0, 1.0)
	
	var angle_upper = acos(cos_angle_upper)
	var angle_lower = acos(cos_angle_lower)
	
	# Apply constraints
	angle_lower = clamp(
		rad_to_deg(angle_lower),
		chain.constraints.min_angle,
		chain.constraints.max_angle
	)
	angle_lower = deg_to_rad(angle_lower)
	
	# Calculate ideal middle joint position
	var root_to_target = (target - root_pos).normalized()
	var pole_direction = _calculate_pole_direction(chain, root_pos, target)
	
	# Rotate around axis perpendicular to root_to_target
	var rotation_axis = root_to_target.cross(pole_direction).normalized()
	if rotation_axis.length() < 0.001:
		rotation_axis = Vector3.UP
	
	var ideal_middle = root_pos + root_to_target.rotated(rotation_axis, angle_upper) * upper_length
	
	# Apply forces to achieve desired positions
	_apply_ik_forces(chain, ideal_middle, target, weight)

func _calculate_pole_direction(chain: IKChain, root_pos: Vector3, target: Vector3) -> Vector3:
	"""Calculate pole vector direction for joint bending"""
	var forward = (target - root_pos).normalized()
	var pole_world = chain.root.global_transform * chain.pole_target
	var pole_dir = (pole_world - root_pos).normalized()
	
	# Make sure pole is perpendicular to forward
	pole_dir = pole_dir - forward * forward.dot(pole_dir)
	pole_dir = pole_dir.normalized()
	
	if pole_dir.length() < 0.001:
		# Fallback if pole is aligned with forward
		pole_dir = Vector3.UP.cross(forward).normalized()
		if pole_dir.length() < 0.001:
			pole_dir = Vector3.RIGHT
	
	return pole_dir

func _apply_ik_forces(chain: IKChain, middle_target: Vector3, end_target: Vector3, weight: float) -> void:
	"""Apply physics forces to move joints towards IK targets"""
	# Calculate errors
	var middle_error = middle_target - chain.middle.global_position
	var end_error = end_target - chain.end.global_position
	
	# Skip if already close enough
	if middle_error.length() < POSITION_THRESHOLD and end_error.length() < POSITION_THRESHOLD:
		return
	
	# Apply forces with damping
	var middle_force = middle_error * FORCE_MULTIPLIER * weight
	var end_force = end_error * FORCE_MULTIPLIER * weight
	
	# Dampen based on current velocity
	middle_force -= chain.middle.linear_velocity * DAMPING_FACTOR
	end_force -= chain.end.linear_velocity * DAMPING_FACTOR
	
	# Apply forces
	chain.middle.apply_central_force(middle_force)
	chain.end.apply_central_force(end_force)
	
	# Apply corrective torques for proper alignment
	_apply_alignment_torques(chain, weight)

func _apply_alignment_torques(chain: IKChain, weight: float) -> void:
	"""Apply torques to maintain proper joint alignment"""
	# Calculate desired bone directions
	var upper_current = (chain.middle.global_position - chain.root.global_position).normalized()
	var lower_current = (chain.end.global_position - chain.middle.global_position).normalized()
	
	# Apply torque to root to point towards middle
	var root_forward = chain.root.global_transform.basis.z
	var root_error = root_forward.cross(upper_current)
	chain.root.apply_torque(root_error * TORQUE_MULTIPLIER * weight)
	
	# Apply torque to middle to point towards end
	var middle_forward = chain.middle.global_transform.basis.z
	var middle_error = middle_forward.cross(lower_current)
	chain.middle.apply_torque(middle_error * TORQUE_MULTIPLIER * weight)

func solve_all_chains(targets: Dictionary, weights: Dictionary = {}) -> void:
	"""Solve all IK chains with given targets"""
	for chain_name in targets:
		var weight = weights.get(chain_name, 1.0)
		solve_chain(chain_name, targets[chain_name], weight)

func get_chain_info(chain_name: String) -> Dictionary:
	"""Get information about an IK chain"""
	if not chain_name in ik_chains:
		return {}
	
	var chain = ik_chains[chain_name]
	return {
		"root_pos": chain.root.global_position if chain.root else Vector3.ZERO,
		"middle_pos": chain.middle.global_position if chain.middle else Vector3.ZERO,
		"end_pos": chain.end.global_position if chain.end else Vector3.ZERO,
		"total_length": _get_chain_length(chain),
		"current_bend": _get_chain_bend_angle(chain)
	}

func _get_chain_length(chain: IKChain) -> float:
	"""Get total length of IK chain"""
	if not chain.root or not chain.middle or not chain.end:
		return 0.0
	
	var upper = chain.root.global_position.distance_to(chain.middle.global_position)
	var lower = chain.middle.global_position.distance_to(chain.end.global_position)
	return upper + lower

func _get_chain_bend_angle(chain: IKChain) -> float:
	"""Get current bend angle of middle joint"""
	if not chain.root or not chain.middle or not chain.end:
		return 0.0
	
	var upper_dir = (chain.middle.global_position - chain.root.global_position).normalized()
	var lower_dir = (chain.end.global_position - chain.middle.global_position).normalized()
	return rad_to_deg(acos(clamp(upper_dir.dot(lower_dir), -1.0, 1.0)))

func enable_debug(enabled: bool) -> void:
	"""Toggle debug visualization"""
	debug_enabled = enabled
	if not enabled:
		_clear_debug_lines()

func _create_debug_line(_from: Vector3, _to: Vector3, _color: Color) -> void:
	"""Create a debug line (placeholder for actual implementation)"""
	# TODO: Implement debug line drawing
	pass

func _clear_debug_lines() -> void:
	"""Clear all debug lines"""
	for line in debug_lines:
		if line:
			line.queue_free()
	debug_lines.clear()

func _physics_process(_delta: float) -> void:
	if debug_enabled:
		_update_debug_visualization()

func _update_debug_visualization() -> void:
	"""Update debug visualization"""
	_clear_debug_lines()
	
	# Draw IK chains
	for chain_name in ik_chains:
		var chain = ik_chains[chain_name]
		if chain.root and chain.middle and chain.end:
			# Draw bones
			_create_debug_line(
				chain.root.global_position,
				chain.middle.global_position,
				Color.CYAN
			)
			_create_debug_line(
				chain.middle.global_position,
				chain.end.global_position,
				Color.CYAN
			)
			
			# Draw pole target
			var pole_world = chain.root.global_transform * chain.pole_target
			_create_debug_line(
				chain.middle.global_position,
				pole_world,
				Color.YELLOW.darkened(0.3)
			)