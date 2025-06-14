# 🏛️ Biomechanical Walker - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
class_name BiomechanicalWalker
# Advanced bipedal walker with anatomically correct feet and gait cycle

signal step_completed(foot: String)
signal phase_changed(leg: String, phase: String)

# Gait phases
enum GaitPhase {
	# Stance phases (60% of cycle)
	HEEL_STRIKE,      # Initial contact
	FOOT_FLAT,        # Loading response
	MIDSTANCE,        # Single support
	HEEL_OFF,         # Terminal stance
	TOE_OFF,          # Pre-swing
	# Swing phases (40% of cycle)
	INITIAL_SWING,    # Foot leaves ground
	MID_SWING,        # Foot clears ground
	TERMINAL_SWING    # Prepare for contact
}

# Leg structure with detailed foot
class Leg:
	var hip: RigidBody3D
	var thigh: RigidBody3D
	var shin: RigidBody3D
	var foot: RigidBody3D      # Main foot body
	var heel: RigidBody3D      # Heel segment
	var toes: RigidBody3D      # Toe segment
	
	var hip_joint: Generic6DOFJoint3D
	var knee_joint: HingeJoint3D
	var ankle_joint: Generic6DOFJoint3D
	var midfoot_joint: HingeJoint3D    # Between heel and foot
	var toe_joint: HingeJoint3D        # Between foot and toes
	
	var phase: GaitPhase = GaitPhase.MIDSTANCE
	var phase_timer: float = 0.0
	var is_stance: bool = true
	var side: String = "left"  # or "right"

# Walker components
@export var walk_speed: float = 2.0
@export var step_length: float = 0.6
@export var step_height: float = 0.15
@export var stance_duration: float = 0.6  # 60% of cycle
@export var swing_duration: float = 0.4   # 40% of cycle

var pelvis: RigidBody3D
var spine: RigidBody3D
var left_leg: Leg
var right_leg: Leg

# Gait timing
var cycle_time: float = 0.0
var left_phase_offset: float = 0.0
var right_phase_offset: float = 0.5  # Half cycle offset

# Ground detection
var ground_contacts: Dictionary = {}  # Track which parts touch ground

# Balance control
var center_of_mass: Vector3
var stability_threshold: float = 0.3

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_create_skeleton()
	_setup_physics()
	_initialize_gait()

func _create_skeleton() -> void:
	# Create pelvis (base)
	pelvis = _create_body("Pelvis", 8.0, Vector3(0.3, 0.15, 0.2))
	pelvis.position = Vector3(0, 1.0, 0)
	add_child(pelvis)
	
	# Create spine for upper body stability
	spine = _create_body("Spine", 5.0, Vector3(0.2, 0.4, 0.15))
	spine.position = pelvis.position + Vector3(0, 0.3, 0)
	add_child(spine)
	
	# Connect spine to pelvis
	var spine_joint = Generic6DOFJoint3D.new()
	spine_joint.node_a = pelvis.get_path()
	spine_joint.node_b = spine.get_path()
	add_child(spine_joint)
	
	# Create legs
	left_leg = _create_leg("left", Vector3(-0.15, -0.1, 0))
	right_leg = _create_leg("right", Vector3(0.15, -0.1, 0))

func _create_leg(side: String, offset: Vector3) -> Leg:
	var leg = Leg.new()
	leg.side = side
	
	# Hip (upper thigh connection point)
	leg.hip = _create_body(side + "_hip", 2.0, Vector3(0.1, 0.1, 0.1))
	leg.hip.position = pelvis.position + offset
	add_child(leg.hip)
	
	# Thigh
	leg.thigh = _create_body(side + "_thigh", 4.0, Vector3(0.12, 0.4, 0.12))
	leg.thigh.position = leg.hip.position + Vector3(0, -0.25, 0)
	add_child(leg.thigh)
	
	# Shin
	leg.shin = _create_body(side + "_shin", 3.0, Vector3(0.1, 0.4, 0.1))
	leg.shin.position = leg.thigh.position + Vector3(0, -0.45, 0)
	add_child(leg.shin)
	
	# Foot components with anatomical proportions
	# Heel (calcaneus)
	leg.heel = _create_body(side + "_heel", 0.8, Vector3(0.06, 0.05, 0.08))
	leg.heel.position = leg.shin.position + Vector3(0, -0.45, -0.05)
	add_child(leg.heel)
	
	# Main foot (metatarsals)
	leg.foot = _create_body(side + "_foot", 1.0, Vector3(0.08, 0.03, 0.15))
	leg.foot.position = leg.heel.position + Vector3(0, -0.02, 0.08)
	add_child(leg.foot)
	
	# Toes (phalanges)
	leg.toes = _create_body(side + "_toes", 0.5, Vector3(0.08, 0.02, 0.06))
	leg.toes.position = leg.foot.position + Vector3(0, -0.01, 0.08)
	add_child(leg.toes)
	
	# Create joints
	leg.hip_joint = _create_hip_joint(pelvis, leg.hip, leg.thigh)
	leg.knee_joint = _create_knee_joint(leg.thigh, leg.shin)
	leg.ankle_joint = _create_ankle_joint(leg.shin, leg.heel)
	leg.midfoot_joint = _create_midfoot_joint(leg.heel, leg.foot)
	leg.toe_joint = _create_toe_joint(leg.foot, leg.toes)
	
	return leg

func _create_body(body_name: String, mass: float, size: Vector3) -> RigidBody3D:
	var body = RigidBody3D.new()
	body.name = body_name
	body.mass = mass
	body.continuous_cd = true
	
	# Add collision shape
	var shape = CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	shape.shape.size = size
	FloodgateController.universal_add_child(shape, body)
	
	# Add visual mesh
	var mesh = MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	mesh.mesh.size = size
	FloodgateController.universal_add_child(mesh, body)
	
	# Contact monitoring for ground detection
	body.contact_monitor = true
	body.max_contacts_reported = 10
	body.body_entered.connect(_on_body_contact.bind(body))
	body.body_exited.connect(_on_body_exit_contact.bind(body))
	
	return body

func _create_hip_joint(pelvis_body: RigidBody3D, hip: RigidBody3D, thigh: RigidBody3D) -> Generic6DOFJoint3D:
	var joint = Generic6DOFJoint3D.new()
	joint.node_a = pelvis_body.get_path()
	joint.node_b = hip.get_path()
	add_child(joint)
	
	# Ball joint with limited range
	joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -PI/4)  # Flexion limit
	joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, PI/6)   # Extension limit
	joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -PI/6)  # Adduction
	joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, PI/6)   # Abduction
	joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -PI/8)  # Internal rotation
	joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, PI/8)   # External rotation
	
	# Connect hip to thigh
	var hip_thigh = HingeJoint3D.new()
	hip_thigh.node_a = hip.get_path()
	hip_thigh.node_b = thigh.get_path()
	add_child(hip_thigh)
	
	return joint

func _create_knee_joint(thigh: RigidBody3D, shin: RigidBody3D) -> HingeJoint3D:
	var joint = HingeJoint3D.new()
	joint.node_a = thigh.get_path()
	joint.node_b = shin.get_path()
	add_child(joint)
	
	# Knee only bends backward
	joint.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, 0)
	joint.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, PI * 0.75)  # ~135 degrees
	joint.set_flag(HingeJoint3D.FLAG_USE_LIMIT, true)
	
	return joint

func _create_ankle_joint(shin: RigidBody3D, heel: RigidBody3D) -> Generic6DOFJoint3D:
	var joint = Generic6DOFJoint3D.new()
	joint.node_a = shin.get_path()
	joint.node_b = heel.get_path()
	add_child(joint)
	
	# Ankle dorsiflexion/plantarflexion
	joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -PI/6)   # 30° plantarflexion
	joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, PI/9)    # 20° dorsiflexion
	# Minimal inversion/eversion
	joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -PI/18)  # 10° each way
	joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, PI/18)
	
	return joint

func _create_midfoot_joint(heel: RigidBody3D, foot: RigidBody3D) -> HingeJoint3D:
	var joint = HingeJoint3D.new()
	joint.node_a = heel.get_path()
	joint.node_b = foot.get_path()
	add_child(joint)
	
	# Slight flexibility in midfoot
	joint.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, -PI/12)  # 15° down
	joint.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, PI/18)   # 10° up
	joint.set_flag(HingeJoint3D.FLAG_USE_LIMIT, true)
	
	return joint

func _create_toe_joint(foot: RigidBody3D, toes: RigidBody3D) -> HingeJoint3D:
	var joint = HingeJoint3D.new()
	joint.node_a = foot.get_path()
	joint.node_b = toes.get_path()
	add_child(joint)
	
	# Toe flexion for push-off
	joint.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, -PI/4)   # 45° flexion
	joint.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, PI/6)    # 30° extension
	joint.set_flag(HingeJoint3D.FLAG_USE_LIMIT, true)
	
	return joint

func _setup_physics() -> void:
	# Set up damping for stability
	var bodies = [pelvis, spine, left_leg.hip, left_leg.thigh, left_leg.shin, 
				  left_leg.heel, left_leg.foot, left_leg.toes,
				  right_leg.hip, right_leg.thigh, right_leg.shin,
				  right_leg.heel, right_leg.foot, right_leg.toes]
	
	for body in bodies:
		body.linear_damp = 0.5
		body.angular_damp = 2.0

func _initialize_gait() -> void:
	# Start with left leg in stance, right leg mid-swing
	left_leg.phase = GaitPhase.MIDSTANCE
	left_leg.is_stance = true
	right_leg.phase = GaitPhase.MID_SWING
	right_leg.is_stance = false


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	cycle_time += delta
	
	# Update each leg's gait phase
	_update_leg_phase(left_leg, delta)
	_update_leg_phase(right_leg, delta)
	
	# Apply forces based on current phases
	_apply_gait_forces(left_leg)
	_apply_gait_forces(right_leg)
	
	# Maintain balance
	_maintain_balance()
	
	# Update center of mass
	_update_center_of_mass()

func _update_leg_phase(leg: Leg, delta: float) -> void:
	leg.phase_timer += delta
	
	# Check if phase should transition
	var phase_duration = stance_duration / 5.0 if leg.is_stance else swing_duration / 3.0
	
	if leg.phase_timer >= phase_duration:
		leg.phase_timer = 0.0
		_transition_to_next_phase(leg)

func _transition_to_next_phase(leg: Leg) -> void:
	var _old_phase = leg.phase
	
	match leg.phase:
		GaitPhase.HEEL_STRIKE:
			leg.phase = GaitPhase.FOOT_FLAT
		GaitPhase.FOOT_FLAT:
			leg.phase = GaitPhase.MIDSTANCE
		GaitPhase.MIDSTANCE:
			leg.phase = GaitPhase.HEEL_OFF
		GaitPhase.HEEL_OFF:
			leg.phase = GaitPhase.TOE_OFF
		GaitPhase.TOE_OFF:
			leg.phase = GaitPhase.INITIAL_SWING
			leg.is_stance = false
		GaitPhase.INITIAL_SWING:
			leg.phase = GaitPhase.MID_SWING
		GaitPhase.MID_SWING:
			leg.phase = GaitPhase.TERMINAL_SWING
		GaitPhase.TERMINAL_SWING:
			leg.phase = GaitPhase.HEEL_STRIKE
			leg.is_stance = true
			step_completed.emit(leg.side)
	
	phase_changed.emit(leg.side, GaitPhase.keys()[leg.phase])

func _apply_gait_forces(leg: Leg) -> void:
	match leg.phase:
		GaitPhase.HEEL_STRIKE:
			_apply_heel_strike_forces(leg)
		GaitPhase.FOOT_FLAT:
			_apply_foot_flat_forces(leg)
		GaitPhase.MIDSTANCE:
			_apply_midstance_forces(leg)
		GaitPhase.HEEL_OFF:
			_apply_heel_off_forces(leg)
		GaitPhase.TOE_OFF:
			_apply_toe_off_forces(leg)
		GaitPhase.INITIAL_SWING:
			_apply_initial_swing_forces(leg)
		GaitPhase.MID_SWING:
			_apply_mid_swing_forces(leg)
		GaitPhase.TERMINAL_SWING:
			_apply_terminal_swing_forces(leg)

func _apply_heel_strike_forces(leg: Leg) -> void:
	# Heel contacts ground first
	# Ankle slightly dorsiflexed
	var ankle_torque = Vector3(-0.2, 0, 0)  # Slight upward toe angle
	leg.heel.apply_torque(ankle_torque)
	
	# Knee slightly flexed for shock absorption
	var knee_torque = Vector3(0.1, 0, 0)
	leg.shin.apply_torque(knee_torque)
	
	# Hip flexed forward
	var hip_torque = Vector3(-0.3, 0, 0)
	leg.thigh.apply_torque(hip_torque)

func _apply_foot_flat_forces(leg: Leg) -> void:
	# Transition to full foot contact
	# Control ankle to lower foot
	var ankle_torque = Vector3(0.1, 0, 0)  # Controlled lowering
	leg.heel.apply_torque(ankle_torque)
	leg.foot.apply_torque(ankle_torque * 0.5)
	
	# Knee continues to flex slightly
	var knee_torque = Vector3(0.2, 0, 0)
	leg.shin.apply_torque(knee_torque)

func _apply_midstance_forces(leg: Leg) -> void:
	# Support full body weight
	# Maintain upright posture
	var support_force = Vector3(0, walk_speed * 50, 0)
	leg.foot.apply_central_force(support_force)
	
	# Ankle neutral to slight dorsiflexion
	var ankle_torque = Vector3(-0.1, 0, 0)
	leg.heel.apply_torque(ankle_torque)
	
	# Knee extends
	var knee_torque = Vector3(-0.2, 0, 0)
	leg.shin.apply_torque(knee_torque)

func _apply_heel_off_forces(leg: Leg) -> void:
	# Heel lifts, weight shifts to forefoot
	# Strong plantarflexion begins
	var heel_lift_force = Vector3(0, 20, 0)
	leg.heel.apply_central_force(heel_lift_force)
	
	# Ankle plantarflexion
	var ankle_torque = Vector3(0.4, 0, 0)
	leg.foot.apply_torque(ankle_torque)
	
	# Prepare toes for push-off
	var toe_torque = Vector3(0.2, 0, 0)
	leg.toes.apply_torque(toe_torque)

func _apply_toe_off_forces(leg: Leg) -> void:
	# Final push-off
	# Maximum plantarflexion
	var push_force = Vector3(0, 30, -walk_speed * 20)
	leg.toes.apply_central_force(push_force)
	
	# Toe flexion for push
	var toe_torque = Vector3(0.5, 0, 0)
	leg.toes.apply_torque(toe_torque)
	
	# Begin knee flexion for swing
	var knee_torque = Vector3(0.3, 0, 0)
	leg.shin.apply_torque(knee_torque)

func _apply_initial_swing_forces(leg: Leg) -> void:
	# Rapid knee flexion to clear ground
	var knee_torque = Vector3(0.6, 0, 0)
	leg.shin.apply_torque(knee_torque)
	
	# Hip flexion to swing forward
	var hip_torque = Vector3(-0.4, 0, 0)
	leg.thigh.apply_torque(hip_torque)
	
	# Ankle returns to neutral
	var ankle_torque = Vector3(-0.3, 0, 0)
	leg.foot.apply_torque(ankle_torque)

func _apply_mid_swing_forces(leg: Leg) -> void:
	# Leg swings forward
	# Hip continues flexion
	var hip_force = Vector3(0, 0, -walk_speed * 15)
	leg.thigh.apply_central_force(hip_force)
	
	# Knee begins to extend
	var knee_torque = Vector3(-0.3, 0, 0)
	leg.shin.apply_torque(knee_torque)
	
	# Ankle dorsiflexed for clearance
	var ankle_torque = Vector3(-0.2, 0, 0)
	leg.foot.apply_torque(ankle_torque)

func _apply_terminal_swing_forces(leg: Leg) -> void:
	# Prepare for heel strike
	# Knee extends nearly straight
	var knee_torque = Vector3(-0.4, 0, 0)
	leg.shin.apply_torque(knee_torque)
	
	# Ankle dorsiflexed for heel strike
	var ankle_torque = Vector3(-0.25, 0, 0)
	leg.heel.apply_torque(ankle_torque)
	
	# Position leg for landing
	var position_force = Vector3(0, -10, -walk_speed * 10)
	leg.foot.apply_central_force(position_force)

func _maintain_balance() -> void:
	# Apply corrective torques to pelvis based on COM
	var com_offset = center_of_mass - pelvis.global_position
	com_offset.y = 0  # Only care about horizontal balance
	
	if com_offset.length() > stability_threshold:
		var correction_torque = -com_offset.normalized() * 5.0
		pelvis.apply_torque(Vector3(correction_torque.z, 0, -correction_torque.x))

func _update_center_of_mass() -> void:
	var total_mass = 0.0
	var weighted_position = Vector3.ZERO
	
	var bodies = [pelvis, spine, left_leg.thigh, left_leg.shin, left_leg.foot,
				  right_leg.thigh, right_leg.shin, right_leg.foot]
	
	for body in bodies:
		total_mass += body.mass
		weighted_position += body.global_position * body.mass
	
	center_of_mass = weighted_position / total_mass

func _on_body_contact(body: Node3D, contacting_body: Node3D) -> void:
	if contacting_body.name == "Ground":
		ground_contacts[body.name] = true

func _on_body_exit_contact(body: Node3D, contacting_body: Node3D) -> void:
	if contacting_body.name == "Ground":
		ground_contacts.erase(body.name)

# Public API

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
func set_walk_speed(speed: float) -> void:
	walk_speed = speed

func get_current_phase(leg_side: String) -> String:
	var leg = left_leg if leg_side == "left" else right_leg
	return GaitPhase.keys()[leg.phase]

func is_foot_on_ground(leg_side: String) -> bool:
	var leg = left_leg if leg_side == "left" else right_leg
	return leg.heel.name in ground_contacts or leg.foot.name in ground_contacts or leg.toes.name in ground_contacts