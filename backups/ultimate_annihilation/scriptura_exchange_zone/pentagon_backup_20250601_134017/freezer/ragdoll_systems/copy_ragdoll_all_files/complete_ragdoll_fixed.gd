# ==================================================
# SCRIPT NAME: complete_ragdoll_fixed.gd
# DESCRIPTION: Complete ragdoll with proper legs and talking ability - FIXED
# CREATED: 2025-05-26 - Fixed all GDScript errors
# ==================================================

extends Node3D

# Body parts - properly declared
var body_parts: Dictionary = {}
var joints: Dictionary = {}
var main_body: RigidBody3D  # This was the missing 'body' variable

# Walking state
var is_walking: bool = false
var walk_cycle: float = 0.0
var walk_speed: float = 1.5
var stumble_chance: float = 0.05
var balance_force: float = 20.0

# Physics tuning
const LEG_FORCE: float = 10.0
const FORWARD_FORCE: float = 1.0
const MAX_ANGULAR_VELOCITY: float = 5.0

# Talking system
var speech_texts: Dictionary = {
	"COLLISION": ["Ouch!", "Whoa!", "That hurt!", "Careful!"],
	"DRAGGED": ["Here we go!", "Let's walk!", "Moving along!", "Step by step!"],
	"IDLE": ["Stopping now.", "Rest time.", "All done!", "Phew!"]
}

func _ready() -> void:
	_create_complete_ragdoll()
	_apply_materials()
	add_to_group("ragdoll")
	print("[CompleteRagdoll] Ragdoll created successfully!")

func _create_complete_ragdoll() -> void:
	# Main body (torso) - properly create and assign
	main_body = RigidBody3D.new()
	main_body.name = "Body"
	add_child(main_body)
	
	main_body.mass = 10.0
	main_body.linear_damp = 1.0
	main_body.angular_damp = 2.0
	
	# Body mesh
	var body_mesh = MeshInstance3D.new()
	var body_shape = BoxMesh.new()
	body_shape.size = Vector3(1.0, 2.0, 0.5)
	body_mesh.mesh = body_shape
	main_body.add_child(body_mesh)
	
	var body_collision = CollisionShape3D.new()
	var body_col_shape = BoxShape3D.new()
	body_col_shape.size = Vector3(1.0, 2.0, 0.5)
	body_collision.shape = body_col_shape
	main_body.add_child(body_collision)
	
	body_parts["body"] = main_body
	
	# Create legs with proper constraints
	_create_leg("left", Vector3(-0.3, -1.0, 0))
	_create_leg("right", Vector3(0.3, -1.0, 0))

func _create_leg(side: String, offset: Vector3) -> void:
	# Upper leg (thigh)
	var upper_leg = RigidBody3D.new()
	upper_leg.name = side.capitalize() + "UpperLeg"
	upper_leg.mass = 2.0
	upper_leg.linear_damp = 1.0
	upper_leg.angular_damp = 2.0
	upper_leg.position = offset
	add_child(upper_leg)
	
	var upper_mesh = MeshInstance3D.new()
	var upper_shape = BoxMesh.new()
	upper_shape.size = Vector3(0.25, 0.8, 0.25)
	upper_mesh.mesh = upper_shape
	upper_mesh.position.y = -0.4
	upper_leg.add_child(upper_mesh)
	
	var upper_collision = CollisionShape3D.new()
	var upper_col_shape = BoxShape3D.new()
	upper_col_shape.size = Vector3(0.25, 0.8, 0.25)
	upper_collision.shape = upper_col_shape
	upper_collision.position.y = -0.4
	upper_leg.add_child(upper_collision)
	
	# Lower leg (shin + foot)
	var lower_leg = RigidBody3D.new()
	lower_leg.name = side.capitalize() + "LowerLeg"
	lower_leg.mass = 1.5
	lower_leg.linear_damp = 1.0
	lower_leg.angular_damp = 2.0
	lower_leg.position = offset + Vector3(0, -0.8, 0)
	add_child(lower_leg)
	
	var lower_mesh = MeshInstance3D.new()
	var lower_shape = BoxMesh.new()
	lower_shape.size = Vector3(0.25, 0.8, 0.35)  # Includes foot
	lower_mesh.mesh = lower_shape
	lower_mesh.position.y = -0.4
	lower_leg.add_child(lower_mesh)
	
	var lower_collision = CollisionShape3D.new()
	var lower_col_shape = BoxShape3D.new()
	lower_col_shape.size = Vector3(0.25, 0.8, 0.35)
	lower_collision.shape = lower_col_shape
	lower_collision.position.y = -0.4
	lower_leg.add_child(lower_collision)
	
	body_parts[side + "_upper_leg"] = upper_leg
	body_parts[side + "_lower_leg"] = lower_leg
	
	# Hip joint (connects body to upper leg)
	var hip_joint = Generic6DOFJoint3D.new()
	hip_joint.name = side.capitalize() + "HipJoint"
	add_child(hip_joint)
	hip_joint.node_a = main_body.get_path()
	hip_joint.node_b = upper_leg.get_path()
	hip_joint.position = offset
	
	# Constrain hip movement
	hip_joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -0.3)
	hip_joint.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, 0.3)
	hip_joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -0.1)
	hip_joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, 0.1)
	hip_joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -0.8)
	hip_joint.set_param_z(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, 0.8)
	
	# Knee joint (connects upper to lower leg)
	var knee_joint = HingeJoint3D.new()
	knee_joint.name = side.capitalize() + "KneeJoint"
	add_child(knee_joint)
	knee_joint.node_a = upper_leg.get_path()
	knee_joint.node_b = lower_leg.get_path()
	knee_joint.position = offset + Vector3(0, -0.8, 0)
	
	# Knee only bends backward
	knee_joint.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, -2.0)
	knee_joint.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, 0.0)
	knee_joint.set_param(HingeJoint3D.PARAM_LIMIT_BIAS, 0.3)
	knee_joint.set_param(HingeJoint3D.PARAM_LIMIT_SOFTNESS, 0.9)
	
	joints[side + "_hip"] = hip_joint
	joints[side + "_knee"] = knee_joint

func _apply_materials() -> void:
	# Body material (reddish)
	var body_material = StandardMaterial3D.new()
	body_material.albedo_color = Color(0.8, 0.3, 0.3)
	body_material.roughness = 0.7
	
	# Leg material (darker red)
	var leg_material = StandardMaterial3D.new()
	leg_material.albedo_color = Color(0.6, 0.2, 0.2)
	leg_material.roughness = 0.8
	
	# Apply materials
	for part_name in body_parts:
		var part = body_parts[part_name]
		if part.get_child_count() > 0 and part.get_child(0) is MeshInstance3D:
			if "body" in part_name:
				part.get_child(0).material_override = body_material
			else:
				part.get_child(0).material_override = leg_material

func _physics_process(delta: float) -> void:
	# Limit angular velocities to prevent wild spinning
	for part_name in body_parts:
		var part = body_parts[part_name]
		if part.angular_velocity.length() > MAX_ANGULAR_VELOCITY:
			part.angular_velocity = part.angular_velocity.normalized() * MAX_ANGULAR_VELOCITY
	
	if is_walking:
		_update_walk_cycle(delta)
		_apply_walking_forces()
		_maintain_balance()

func _update_walk_cycle(delta: float) -> void:
	walk_cycle += delta * walk_speed
	if walk_cycle > TAU:
		walk_cycle -= TAU
		
		# Random stumble (less frequent)
		if randf() < stumble_chance:
			_stumble()

func _apply_walking_forces() -> void:
	# Simple alternating leg movement
	var left_phase = sin(walk_cycle)
	var right_phase = sin(walk_cycle + PI)
	
	# Apply gentle forces to legs
	if body_parts.has("left_lower_leg"):
		var left_foot = body_parts["left_lower_leg"]
		left_foot.apply_central_force(Vector3(0, max(0, left_phase) * LEG_FORCE, left_phase * LEG_FORCE * 0.5))
	
	if body_parts.has("right_lower_leg"):
		var right_foot = body_parts["right_lower_leg"]
		right_foot.apply_central_force(Vector3(0, max(0, right_phase) * LEG_FORCE, right_phase * LEG_FORCE * 0.5))
	
	# Gentle forward movement
	main_body.apply_central_force(Vector3(0, 0, -FORWARD_FORCE))

func _maintain_balance() -> void:
	# Try to keep body upright
	var current_rotation = main_body.rotation
	var balance_torque = Vector3(
		-current_rotation.x * balance_force,
		0,
		-current_rotation.z * balance_force
	)
	main_body.apply_torque(balance_torque)
	
	# Prevent body from tilting too much
	if abs(current_rotation.x) > 0.5 or abs(current_rotation.z) > 0.5:
		main_body.angular_velocity *= 0.9  # Dampen rotation

func _stumble() -> void:
	# Smaller stumble force
	var stumble_force = Vector3(
		randf_range(-20, 20),
		randf_range(10, 20),
		randf_range(-20, 20)
	)
	main_body.apply_central_impulse(stumble_force)
	
	# Say something about stumbling
	_say_something("COLLISION")

func start_walking() -> void:
	is_walking = true
	_say_something("DRAGGED")  # Use dragged dialogue for walking

func stop_walking() -> void:
	is_walking = false
	_say_something("IDLE")

func set_walk_speed(speed: float) -> void:
	walk_speed = clamp(speed, 0.5, 3.0)

func set_floppiness(factor: float) -> void:
	"""Adjust joint stiffness based on floppiness factor"""
	# Adjust joint stiffness
	for joint_name in joints:
		var joint = joints[joint_name]
		if joint is HingeJoint3D:
			joint.set_param(HingeJoint3D.PARAM_LIMIT_SOFTNESS, 0.5 + factor * 0.4)

# Talking functionality
func _say_something(category: String) -> void:
	"""Make the ragdoll say something from the given category"""
	if not category in speech_texts:
		print("[CompleteRagdoll] Unknown speech category: ", category)
		return
	
	var possible_texts = speech_texts[category]
	if possible_texts.is_empty():
		return
	
	var text = possible_texts[randi() % possible_texts.size()]
	print("[CompleteRagdoll] Says: ", text)
	
	# TODO: Add visual speech bubble or audio here
	_create_speech_bubble(text)

func _create_speech_bubble(text: String) -> void:
	"""Create a temporary speech bubble above the ragdoll"""
	# Create a simple label for now
	var bubble = Label3D.new()
	bubble.text = text
	bubble.position = Vector3(0, 3, 0)  # Above the ragdoll
	bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(bubble)
	
	# Remove after 2 seconds
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(bubble.queue_free)

# Public API
func get_body_parts() -> Dictionary:
	"""Get reference to all body parts"""
	return body_parts

func get_main_body() -> RigidBody3D:
	"""Get the main body for external manipulation"""
	return main_body

func is_currently_walking() -> bool:
	"""Check if ragdoll is currently walking"""
	return is_walking