# ==================================================
# SCRIPT NAME: unified_biomechanical_walker.gd
# DESCRIPTION: Single, consolidated biomechanical walker system
# PURPOSE: Replace all ragdoll systems with one working implementation
# CREATED: 2025-05-26 - Project cleanup and consolidation
# ==================================================

extends UniversalBeingBase
class_name UnifiedBiomechanicalWalker

# signal step_completed(foot: String)  # Currently unused but kept for future expansion
signal phase_changed(leg: String, phase: String)

# Simplified gait phases
enum GaitPhase {
	STANCE,       # Foot on ground
	LIFT,         # Foot lifting
	SWING,        # Foot swinging forward
	PLANT         # Foot planting down
}

# Three-element foot structure
class Foot:
	var heel: RigidBody3D
	var midfoot: RigidBody3D  
	var toes: RigidBody3D
	var heel_joint: HingeJoint3D
	var toe_joint: HingeJoint3D
	
	
# Simplified leg structure
class Leg:
	var thigh: RigidBody3D
	var shin: RigidBody3D
	var foot: Foot
	
	var hip_joint: Generic6DOFJoint3D
	var knee_joint: HingeJoint3D
	var ankle_joint: Generic6DOFJoint3D
	
	var phase: GaitPhase = GaitPhase.STANCE
	var phase_timer: float = 0.0
	var side: String = "left"
	
	
# Walker components
@export var walk_speed: float = 1.0
@export var step_length: float = 0.5
@export var step_height: float = 0.1

var pelvis: RigidBody3D
var spine: RigidBody3D
var head: RigidBody3D

var left_leg: Leg
var right_leg: Leg

var cycle_time: float = 0.0
var step_duration: float = 1.0


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	super.pentagon_init()
	"""
	Unified _init function - Perfect Pentagon Architecture
	"""
	# Initialize walker components
	left_leg = Leg.new()
	left_leg.side = "left"
	right_leg = Leg.new()
	right_leg.side = "right"

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("[UnifiedWalker] Creating biomechanical walker...")
	_create_body()
	_create_joints()
	_setup_physics()
	print("[UnifiedWalker] Walker ready!")

func _create_body() -> void:
	# Core body
	pelvis = _create_rigid_body("Pelvis", Vector3(0.3, 0.2, 0.2), 8.0)
	pelvis.position = Vector3(0, 1.2, 0)
	add_child(pelvis)
	
	spine = _create_rigid_body("Spine", Vector3(0.25, 0.4, 0.15), 5.0)
	spine.position = pelvis.position + Vector3(0, 0.35, 0)
	add_child(spine)
	
	head = _create_rigid_body("Head", Vector3(0.2, 0.2, 0.2), 3.0)
	head.position = spine.position + Vector3(0, 0.3, 0)
	add_child(head)
	
	# Create legs
	left_leg = _create_leg("left", Vector3(-0.15, -0.1, 0))
	right_leg = _create_leg("right", Vector3(0.15, -0.1, 0))

func _create_leg(side: String, offset: Vector3) -> Leg:
	var leg = Leg.new()
	leg.side = side
	
	# Thigh
	leg.thigh = _create_rigid_body(side + "_thigh", Vector3(0.12, 0.4, 0.12), 4.0)
	leg.thigh.position = pelvis.position + offset + Vector3(0, -0.25, 0)
	add_child(leg.thigh)
	
	# Shin
	leg.shin = _create_rigid_body(side + "_shin", Vector3(0.1, 0.4, 0.1), 3.0)
	leg.shin.position = leg.thigh.position + Vector3(0, -0.45, 0)
	add_child(leg.shin)
	
	# Three-element foot
	leg.foot.heel = _create_rigid_body(side + "_heel", Vector3(0.08, 0.06, 0.1), 0.8)
	leg.foot.heel.position = leg.shin.position + Vector3(0, -0.45, -0.08)
	add_child(leg.foot.heel)
	
	leg.foot.midfoot = _create_rigid_body(side + "_midfoot", Vector3(0.1, 0.05, 0.15), 1.0)
	leg.foot.midfoot.position = leg.foot.heel.position + Vector3(0, 0, 0.1)
	add_child(leg.foot.midfoot)
	
	leg.foot.toes = _create_rigid_body(side + "_toes", Vector3(0.08, 0.04, 0.08), 0.5)
	leg.foot.toes.position = leg.foot.midfoot.position + Vector3(0, 0, 0.1)
	add_child(leg.foot.toes)
	
	return leg

func _create_rigid_body(body_name: String, size: Vector3, mass: float) -> RigidBody3D:
	var body = RigidBody3D.new()
	body.name = body_name
	body.mass = mass
	body.continuous_cd = true
	body.contact_monitor = true
	body.max_contacts_reported = 5
	
	# Physics properties for stability
	body.linear_damp = 0.8
	body.angular_damp = 3.0
	
	# Collision shape (smaller than visual to prevent interference)
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = size * 0.8  # 20% smaller to prevent joint interference
	collision.shape = shape
	FloodgateController.universal_add_child(collision, body)
	
	# Visual mesh with color coding
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = size
	mesh_instance.mesh = box_mesh
	
	# Color code parts
	var material = MaterialLibrary.get_material("default")
	if "head" in body_name:
		material.albedo_color = Color.YELLOW
	elif "spine" in body_name or "pelvis" in body_name:
		material.albedo_color = Color.BLUE
	elif "thigh" in body_name or "shin" in body_name:
		material.albedo_color = Color.GREEN
	else:  # Feet
		material.albedo_color = Color.RED
	
	material.roughness = 0.8
	mesh_instance.material_override = material
	FloodgateController.universal_add_child(mesh_instance, body)
	
	return body

func _create_joints() -> void:
	print("[UnifiedWalker] Creating joints...")
	
	# Spine to pelvis
	var spine_joint = _create_6dof_joint(pelvis, spine, "spine_pelvis")
	_limit_6dof_joint(spine_joint, 15.0, 15.0, 15.0)
	
	# Head to spine
	var head_joint = _create_6dof_joint(spine, head, "head_spine")
	_limit_6dof_joint(head_joint, 30.0, 30.0, 45.0)
	
	# Left leg joints
	_create_leg_joints(left_leg, pelvis)
	
	# Right leg joints
	_create_leg_joints(right_leg, pelvis)

func _create_leg_joints(leg: Leg, pelvis_body: RigidBody3D) -> void:
	# Hip joint (6DOF with limits)
	leg.hip_joint = _create_6dof_joint(pelvis_body, leg.thigh, leg.side + "_hip")
	_limit_6dof_joint(leg.hip_joint, 90.0, 30.0, 30.0)
	
	# Knee joint (hinge)
	leg.knee_joint = _create_hinge_joint(leg.thigh, leg.shin, leg.side + "_knee")
	leg.knee_joint.set_flag(HingeJoint3D.FLAG_USE_LIMIT, true)
	leg.knee_joint.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, -150.0)
	leg.knee_joint.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, 0.0)
	
	# Ankle joint (6DOF)
	leg.ankle_joint = _create_6dof_joint(leg.shin, leg.foot.heel, leg.side + "_ankle")
	_limit_6dof_joint(leg.ankle_joint, 30.0, 15.0, 30.0)
	
	# Foot joints
	leg.foot.heel_joint = _create_hinge_joint(leg.foot.heel, leg.foot.midfoot, leg.side + "_heel_mid")
	leg.foot.heel_joint.set_flag(HingeJoint3D.FLAG_USE_LIMIT, true)
	leg.foot.heel_joint.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, -30.0)
	leg.foot.heel_joint.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, 30.0)
	
	leg.foot.toe_joint = _create_hinge_joint(leg.foot.midfoot, leg.foot.toes, leg.side + "_mid_toe")
	leg.foot.toe_joint.set_flag(HingeJoint3D.FLAG_USE_LIMIT, true)
	leg.foot.toe_joint.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, -45.0)
	leg.foot.toe_joint.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, 15.0)

func _create_6dof_joint(body_a: RigidBody3D, body_b: RigidBody3D, joint_name: String) -> Generic6DOFJoint3D:
	var joint = Generic6DOFJoint3D.new()
	joint.name = joint_name
	joint.node_a = body_a.get_path()
	joint.node_b = body_b.get_path()
	
	# Set anchor points for proper connection
	var midpoint = (body_a.position + body_b.position) * 0.5
	joint.position = midpoint
	
	add_child(joint)
	return joint

func _create_hinge_joint(body_a: RigidBody3D, body_b: RigidBody3D, joint_name: String) -> HingeJoint3D:
	var joint = HingeJoint3D.new()
	joint.name = joint_name
	joint.node_a = body_a.get_path()
	joint.node_b = body_b.get_path()
	
	# Set anchor points for proper connection
	var midpoint = (body_a.position + body_b.position) * 0.5
	joint.position = midpoint
	
	add_child(joint)
	return joint

func _limit_6dof_joint(joint: Generic6DOFJoint3D, x_degrees: float, y_degrees: float, z_degrees: float) -> void:
	# Set angular limits for all axes
	joint.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)
	joint.set_flag_y(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)
	joint.set_flag_z(Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)
	
	var x_rad = deg_to_rad(x_degrees)
	var y_rad = deg_to_rad(y_degrees)
	var z_rad = deg_to_rad(z_degrees)
	
	joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -x_rad)
	joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, x_rad)
	joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -y_rad)
	joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, y_rad)
	joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -z_rad)
	joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, z_rad)

func _setup_physics() -> void:
	print("[UnifiedWalker] Setting up physics...")
	
	# Initialize gait - start with left leg stance, right leg swing
	left_leg.phase = GaitPhase.STANCE
	right_leg.phase = GaitPhase.SWING


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	cycle_time += delta
	
	# Simple walking animation
	_update_gait(delta)
	
	# Apply basic balance forces
	_maintain_balance()

func _update_gait(delta: float) -> void:
	# Update leg phases
	_update_leg_phase(left_leg, delta)
	_update_leg_phase(right_leg, delta)
	
	# Apply forces for current phases
	_apply_gait_forces(left_leg)
	_apply_gait_forces(right_leg)

func _update_leg_phase(leg: Leg, delta: float) -> void:
	leg.phase_timer += delta
	
	if leg.phase_timer >= step_duration / 4.0:  # 4 phases per step
		leg.phase_timer = 0.0
		
		match leg.phase:
			GaitPhase.STANCE:
				leg.phase = GaitPhase.LIFT
			GaitPhase.LIFT:
				leg.phase = GaitPhase.SWING
			GaitPhase.SWING:
				leg.phase = GaitPhase.PLANT
			GaitPhase.PLANT:
				leg.phase = GaitPhase.STANCE
		
		phase_changed.emit(leg.side, GaitPhase.keys()[leg.phase])

func _apply_gait_forces(leg: Leg) -> void:
	var force_strength = 100.0
	
	match leg.phase:
		GaitPhase.STANCE:
			# Push up and stabilize
			leg.foot.heel.apply_central_force(Vector3(0, force_strength * 0.5, 0))
		GaitPhase.LIFT:
			# Lift foot
			leg.foot.toes.apply_central_force(Vector3(0, force_strength, 0))
		GaitPhase.SWING:
			# Move forward
			leg.shin.apply_central_force(Vector3(0, 0, walk_speed * force_strength))
		GaitPhase.PLANT:
			# Plant down
			leg.foot.heel.apply_central_force(Vector3(0, -force_strength * 0.3, 0))

func _maintain_balance() -> void:
	# Simple balance - keep pelvis upright
	var upright_force = -pelvis.angular_velocity * 50.0
	pelvis.apply_torque(upright_force)
	
	# Keep moving forward
	if pelvis.linear_velocity.z < walk_speed:
		pelvis.apply_central_force(Vector3(0, 0, walk_speed * 20.0))

# Public interface for console commands

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
func set_walk_speed(speed: float) -> void:
	walk_speed = clamp(speed, 0.1, 5.0)
	print("[UnifiedWalker] Walk speed set to: ", walk_speed)

func teleport_to(new_position: Vector3) -> void:
	pelvis.position = new_position
	print("[UnifiedWalker] Teleported to: ", new_position)

func get_debug_info() -> Dictionary:
	return {
		"position": pelvis.position,
		"velocity": pelvis.linear_velocity,
		"walk_speed": walk_speed,
		"left_phase": GaitPhase.keys()[left_leg.phase],
		"right_phase": GaitPhase.keys()[right_leg.phase],
		"cycle_time": cycle_time
	}