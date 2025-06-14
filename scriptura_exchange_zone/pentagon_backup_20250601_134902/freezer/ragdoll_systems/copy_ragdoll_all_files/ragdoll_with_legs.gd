# ==================================================
# SCRIPT NAME: ragdoll_with_legs.gd
# DESCRIPTION: Enhanced ragdoll with legs that can walk/stumble
# CREATED: 2025-05-23 - Adding legs to our talking friend
# ==================================================

extends Node3D

# Components
var body: RigidBody3D
var left_leg: RigidBody3D
var right_leg: RigidBody3D
var left_foot: RigidBody3D
var right_foot: RigidBody3D

# Joints
var left_hip_joint: Generic6DOFJoint3D
var right_hip_joint: Generic6DOFJoint3D
var left_knee_joint: HingeJoint3D
var right_knee_joint: HingeJoint3D

# Walking state
var is_walking: bool = false
var walk_cycle: float = 0.0
var walk_speed: float = 2.0
var stumble_chance: float = 0.1
var balance_force: float = 50.0

# Material
var body_material: StandardMaterial3D
var leg_material: StandardMaterial3D

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_create_ragdoll_parts()
	_setup_joints()
	_apply_materials()
	
	# Add to ragdoll group
	add_to_group("ragdoll")
	
	# Start the walking cycle
	set_physics_process(true)

func _create_ragdoll_parts() -> void:
	# Main body (torso)
	body = RigidBody3D.new()
	body.name = "Body"
	body.mass = 10.0
	add_child(body)
	
	var body_mesh = MeshInstance3D.new()
	var body_shape = BoxMesh.new()
	body_shape.size = Vector3(1.0, 2.0, 0.5)
	body_mesh.mesh = body_shape
	body.add_child(body_mesh)
	
	var body_collision = CollisionShape3D.new()
	var body_col_shape = BoxShape3D.new()
	body_col_shape.size = Vector3(1.0, 2.0, 0.5)
	body_collision.shape = body_col_shape
	body.add_child(body_collision)
	
	# Left upper leg
	left_leg = RigidBody3D.new()
	left_leg.name = "LeftLeg"
	left_leg.mass = 3.0
	left_leg.position = Vector3(-0.3, -1.0, 0)
	add_child(left_leg)
	
	var left_leg_mesh = MeshInstance3D.new()
	var leg_shape = BoxMesh.new()
	leg_shape.size = Vector3(0.3, 1.0, 0.3)
	left_leg_mesh.mesh = leg_shape
	left_leg_mesh.position.y = -0.5
	left_leg.add_child(left_leg_mesh)
	
	var left_leg_collision = CollisionShape3D.new()
	var leg_col_shape = BoxShape3D.new()
	leg_col_shape.size = Vector3(0.3, 1.0, 0.3)
	left_leg_collision.shape = leg_col_shape
	left_leg_collision.position.y = -0.5
	left_leg.add_child(left_leg_collision)
	
	# Right upper leg (mirror of left)
	right_leg = RigidBody3D.new()
	right_leg.name = "RightLeg"
	right_leg.mass = 3.0
	right_leg.position = Vector3(0.3, -1.0, 0)
	add_child(right_leg)
	
	var right_leg_mesh = MeshInstance3D.new()
	right_leg_mesh.mesh = leg_shape
	right_leg_mesh.position.y = -0.5
	right_leg.add_child(right_leg_mesh)
	
	var right_leg_collision = CollisionShape3D.new()
	right_leg_collision.shape = leg_col_shape
	right_leg_collision.position.y = -0.5
	right_leg.add_child(right_leg_collision)
	
	# Left foot
	left_foot = RigidBody3D.new()
	left_foot.name = "LeftFoot"
	left_foot.mass = 1.0
	left_foot.position = Vector3(-0.3, -2.5, 0.2)
	add_child(left_foot)
	
	var foot_mesh = MeshInstance3D.new()
	var foot_shape = BoxMesh.new()
	foot_shape.size = Vector3(0.3, 0.2, 0.5)
	foot_mesh.mesh = foot_shape
	left_foot.add_child(foot_mesh)
	
	var foot_collision = CollisionShape3D.new()
	var foot_col_shape = BoxShape3D.new()
	foot_col_shape.size = Vector3(0.3, 0.2, 0.5)
	foot_collision.shape = foot_col_shape
	left_foot.add_child(foot_collision)
	
	# Right foot
	right_foot = RigidBody3D.new()
	right_foot.name = "RightFoot"
	right_foot.mass = 1.0
	right_foot.position = Vector3(0.3, -2.5, 0.2)
	add_child(right_foot)
	
	var right_foot_mesh = MeshInstance3D.new()
	right_foot_mesh.mesh = foot_shape
	right_foot.add_child(right_foot_mesh)
	
	var right_foot_collision = CollisionShape3D.new()
	right_foot_collision.shape = foot_col_shape
	right_foot.add_child(right_foot_collision)

func _setup_joints() -> void:
	# Left hip joint (connects body to left leg)
	left_hip_joint = Generic6DOFJoint3D.new()
	left_hip_joint.name = "LeftHipJoint"
	add_child(left_hip_joint)
	left_hip_joint.node_a = body.get_path()
	left_hip_joint.node_b = left_leg.get_path()
	left_hip_joint.position = Vector3(-0.3, -1.0, 0)
	
	# Configure hip joint limits
	left_hip_joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -0.5)
	left_hip_joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, 0.5)
	left_hip_joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -1.0)
	left_hip_joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, 1.0)
	
	# Right hip joint
	right_hip_joint = Generic6DOFJoint3D.new()
	right_hip_joint.name = "RightHipJoint"
	add_child(right_hip_joint)
	right_hip_joint.node_a = body.get_path()
	right_hip_joint.node_b = right_leg.get_path()
	right_hip_joint.position = Vector3(0.3, -1.0, 0)
	
	right_hip_joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -0.5)
	right_hip_joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, 0.5)
	right_hip_joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -1.0)
	right_hip_joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, 1.0)
	
	# Left knee joint
	left_knee_joint = HingeJoint3D.new()
	left_knee_joint.name = "LeftKneeJoint"
	add_child(left_knee_joint)
	left_knee_joint.node_a = left_leg.get_path()
	left_knee_joint.node_b = left_foot.get_path()
	left_knee_joint.position = Vector3(-0.3, -2.0, 0)
	left_knee_joint.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, 0.0)
	left_knee_joint.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, 2.0)
	
	# Right knee joint
	right_knee_joint = HingeJoint3D.new()
	right_knee_joint.name = "RightKneeJoint"
	add_child(right_knee_joint)
	right_knee_joint.node_a = right_leg.get_path()
	right_knee_joint.node_b = right_foot.get_path()
	right_knee_joint.position = Vector3(0.3, -2.0, 0)
	right_knee_joint.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, 0.0)
	right_knee_joint.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, 2.0)

func _apply_materials() -> void:
	# Body material (reddish)
	body_material = StandardMaterial3D.new()
	body_material.albedo_color = Color(0.8, 0.3, 0.3)
	body_material.roughness = 0.7
	
	# Leg material (darker red)
	leg_material = StandardMaterial3D.new()
	leg_material.albedo_color = Color(0.6, 0.2, 0.2)
	leg_material.roughness = 0.8
	
	# Apply materials
	if body.get_child(0) is MeshInstance3D:
		body.get_child(0).material_override = body_material
	
	for leg in [left_leg, right_leg, left_foot, right_foot]:
		if leg.get_child(0) is MeshInstance3D:
			leg.get_child(0).material_override = leg_material


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	if is_walking:
		_update_walk_cycle(delta)
		_apply_walking_forces()
		_check_balance()

func _update_walk_cycle(delta: float) -> void:
	walk_cycle += delta * walk_speed
	if walk_cycle > TAU:
		walk_cycle -= TAU
		
		# Random stumble
		if randf() < stumble_chance:
			_stumble()

func _apply_walking_forces() -> void:
	# Simple walking forces - alternating leg movements
	var left_phase = sin(walk_cycle)
	var right_phase = sin(walk_cycle + PI)
	
	# Apply forces to feet to create walking motion
	left_foot.apply_central_force(Vector3(0, left_phase * 20, left_phase * 10))
	right_foot.apply_central_force(Vector3(0, right_phase * 20, right_phase * 10))
	
	# Forward movement
	body.apply_central_force(Vector3(0, 0, -2))

func _check_balance() -> void:
	# Try to keep body upright
	var current_rotation = body.rotation
	var balance_torque = Vector3(-current_rotation.x * balance_force, 0, -current_rotation.z * balance_force)
	body.apply_torque(balance_torque)

func _stumble() -> void:
	# Random stumble force
	var stumble_force = Vector3(
		randf_range(-50, 50),
		randf_range(20, 50),
		randf_range(-50, 50)
	)
	body.apply_central_impulse(stumble_force)
	
	# Dialogue hook for stumbling
	if has_method("_say_something"):
		call("_say_something", "COLLISION")

func start_walking() -> void:
	is_walking = true

func stop_walking() -> void:
	is_walking = false

func set_walk_speed(speed: float) -> void:
	walk_speed = clamp(speed, 0.5, 5.0)

func get_body() -> RigidBody3D:
	return body