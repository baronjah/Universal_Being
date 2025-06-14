# ==================================================
# SCRIPT NAME: ragdoll_v2_spawner.gd
# DESCRIPTION: Spawner for the new advanced ragdoll system
# PURPOSE: Create and configure ragdoll v2 with all subsystems
# CREATED: 2025-05-26 - Integration with existing game
# ==================================================

extends UniversalBeingBase
class_name RagdollV2Spawner

# Ragdoll body configuration
const BODY_CONFIG = {
	"pelvis": {
		"size": Vector3(0.3, 0.15, 0.2),
		"mass": 15.0,
		"color": Color(0.8, 0.6, 0.5)
	},
	"spine": {
		"size": Vector3(0.25, 0.3, 0.15),
		"mass": 10.0,
		"color": Color(0.8, 0.6, 0.5)
	},
	"head": {
		"size": Vector3(0.2, 0.25, 0.2),
		"mass": 5.0,
		"color": Color(0.9, 0.7, 0.6)
	},
	"left_thigh": {
		"size": Vector3(0.12, 0.35, 0.12),
		"mass": 8.0,
		"color": Color(0.7, 0.5, 0.4)
	},
	"right_thigh": {
		"size": Vector3(0.12, 0.35, 0.12),
		"mass": 8.0,
		"color": Color(0.7, 0.5, 0.4)
	},
	"left_shin": {
		"size": Vector3(0.1, 0.35, 0.1),
		"mass": 5.0,
		"color": Color(0.7, 0.5, 0.4)
	},
	"right_shin": {
		"size": Vector3(0.1, 0.35, 0.1),
		"mass": 5.0,
		"color": Color(0.7, 0.5, 0.4)
	},
	"left_foot": {
		"size": Vector3(0.08, 0.05, 0.2),
		"mass": 2.0,
		"color": Color(0.6, 0.4, 0.3)
	},
	"right_foot": {
		"size": Vector3(0.08, 0.05, 0.2),
		"mass": 2.0,
		"color": Color(0.6, 0.4, 0.3)
	}
}

# Joint configuration
const JOINT_CONFIG = {
	"pelvis_spine": {
		"type": "hinge",
		"limits": {"lower": -30, "upper": 30},
		"damping": 5.0
	},
	"spine_head": {
		"type": "cone",
		"limits": {"swing": 30, "twist": 45},
		"damping": 3.0
	},
	"pelvis_left_thigh": {
		"type": "cone",
		"limits": {"swing": 90, "twist": 45},
		"damping": 8.0
	},
	"pelvis_right_thigh": {
		"type": "cone", 
		"limits": {"swing": 90, "twist": 45},
		"damping": 8.0
	},
	"left_thigh_shin": {
		"type": "hinge",
		"limits": {"lower": -150, "upper": 0},
		"damping": 5.0
	},
	"right_thigh_shin": {
		"type": "hinge",
		"limits": {"lower": -150, "upper": 0},
		"damping": 5.0
	},
	"left_shin_foot": {
		"type": "cone",
		"limits": {"swing": 30, "twist": 10},
		"damping": 3.0
	},
	"right_shin_foot": {
		"type": "cone",
		"limits": {"swing": 30, "twist": 10},
		"damping": 3.0
	}
}


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	# Pentagon setup - override in child classes
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
func spawn_ragdoll_v2(spawn_position: Vector3 = Vector3.ZERO) -> Node3D:
	"""Spawn a new advanced ragdoll at the given position"""
	print("[RagdollV2Spawner] Creating advanced ragdoll...")
	
	# Create root node
	var ragdoll_root = Node3D.new()
	ragdoll_root.name = "RagdollV2"
	ragdoll_root.position = spawn_position
	
	# Create body parts
	var body_parts = _create_body_parts(ragdoll_root)
	
	# Create joints
	_create_joints(body_parts, ragdoll_root)
	
	# Add to scene first (so controller can properly initialize)
	get_tree().FloodgateController.universal_add_child(ragdoll_root, current_scene)
	
	# Add controller
	var controller = AdvancedRagdollController.new()
	controller.name = "AdvancedController"
	FloodgateController.universal_add_child(controller, ragdoll_root)
	
	# Wait for controller to be ready before initializing
	await controller.ready
	
	# Initialize controller with body parts
	controller.initialize_ragdoll(body_parts)
	
	# Add to ragdolls group
	ragdoll_root.add_to_group("ragdolls")
	ragdoll_root.add_to_group("ragdolls_v2")
	
	# Store body parts reference
	ragdoll_root.set_meta("body_parts", body_parts)
	ragdoll_root.set_meta("controller", controller)
	ragdoll_root.set_meta("ragdoll_version", 2)
	
	print("[RagdollV2Spawner] Ragdoll created successfully!")
	return ragdoll_root

func _create_body_parts(parent: Node3D) -> Dictionary:
	"""Create all body parts as RigidBody3D nodes"""
	var parts = {}
	
	# Starting positions (relative to pelvis at origin)
	var positions = {
		"pelvis": Vector3(0, 0, 0),
		"spine": Vector3(0, 0.25, 0),
		"head": Vector3(0, 0.5, 0),
		"left_thigh": Vector3(-0.1, -0.15, 0),
		"right_thigh": Vector3(0.1, -0.15, 0),
		"left_shin": Vector3(-0.1, -0.5, 0),
		"right_shin": Vector3(0.1, -0.5, 0),
		"left_foot": Vector3(-0.1, -0.85, 0.05),
		"right_foot": Vector3(0.1, -0.85, 0.05)
	}
	
	for part_name in BODY_CONFIG:
		var config = BODY_CONFIG[part_name]
		
		# Create RigidBody3D
		var body = RigidBody3D.new()
		body.name = part_name
		body.mass = config.mass
		body.continuous_cd = true
		body.can_sleep = false
		
		# Set physics properties
		body.linear_damp = 1.0
		body.angular_damp = 3.0
		body.gravity_scale = 1.0
		
		# Position
		if part_name in positions:
			body.position = positions[part_name]
		
		# Create collision shape
		var collision = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = config.size
		collision.shape = shape
		FloodgateController.universal_add_child(collision, body)
		
		# Create visual mesh
		var mesh_instance = MeshInstance3D.new()
		var box_mesh = BoxMesh.new()
		box_mesh.size = config.size
		mesh_instance.mesh = box_mesh
		
		# Create material
		var material = MaterialLibrary.get_material("default")
		material.albedo_color = config.color
		material.roughness = 0.8
		mesh_instance.material_override = material
		
		FloodgateController.universal_add_child(mesh_instance, body)
		
		# Add to parent
		FloodgateController.universal_add_child(body, parent)
		parts[part_name] = body
		
		# Add metadata
		body.set_meta("part_name", part_name)
		body.set_meta("is_ragdoll_part", true)
	
	return parts

func _create_joints(parts: Dictionary, parent: Node3D) -> void:
	"""Create physics joints between body parts"""
	
	# Pelvis to spine
	_create_joint(parts["pelvis"], parts["spine"], "pelvis_spine", parent)
	
	# Spine to head
	_create_joint(parts["spine"], parts["head"], "spine_head", parent)
	
	# Pelvis to thighs
	_create_joint(parts["pelvis"], parts["left_thigh"], "pelvis_left_thigh", parent)
	_create_joint(parts["pelvis"], parts["right_thigh"], "pelvis_right_thigh", parent)
	
	# Thighs to shins
	_create_joint(parts["left_thigh"], parts["left_shin"], "left_thigh_shin", parent)
	_create_joint(parts["right_thigh"], parts["right_shin"], "right_thigh_shin", parent)
	
	# Shins to feet
	_create_joint(parts["left_shin"], parts["left_foot"], "left_shin_foot", parent)
	_create_joint(parts["right_shin"], parts["right_foot"], "right_shin_foot", parent)

func _create_joint(body_a: RigidBody3D, body_b: RigidBody3D, joint_name: String, parent: Node3D) -> void:
	"""Create a physics joint between two bodies"""
	if not joint_name in JOINT_CONFIG:
		push_error("Joint config not found: " + joint_name)
		return
	
	var config = JOINT_CONFIG[joint_name]
	var joint: Joint3D
	
	match config.type:
		"hinge":
			var hinge = HingeJoint3D.new()
			hinge.set_flag(HingeJoint3D.FLAG_USE_LIMIT, true)
			hinge.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, deg_to_rad(config.limits.lower))
			hinge.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, deg_to_rad(config.limits.upper))
			hinge.params[HingeJoint3D.PARAM_LIMIT_SOFTNESS] = 0.5
			hinge.params[HingeJoint3D.PARAM_LIMIT_RELAXATION] = 0.3
			joint = hinge
			
		"cone":
			var cone = ConeTwistJoint3D.new()
			cone.swing_span = deg_to_rad(config.limits.swing)
			cone.twist_span = deg_to_rad(config.limits.twist)
			cone.softness = 0.5
			cone.relaxation = 0.3
			joint = cone
			
		_:
			# Default to generic
			joint = Generic6DOFJoint3D.new()
	
	# Configure joint
	joint.name = joint_name + "_joint"
	joint.node_a = body_a.get_path()
	joint.node_b = body_b.get_path()
	
	# Position joint at connection point
	joint.global_position = (body_a.global_position + body_b.global_position) * 0.5
	
	# Add to scene
	FloodgateController.universal_add_child(joint, parent)

# Console commands integration
func register_console_commands() -> void:
	"""Register commands with console manager"""
	var console = get_node_or_null("/root/ConsoleManager")
	if console and console.has_method("register_command"):
		# Register spawn command
		console.register_command("spawn_ragdoll_v2", _cmd_spawn_ragdoll_v2)
		console.register_command("ragdoll2", _cmd_spawn_ragdoll_v2)
		
		# Register control commands
		console.register_command("ragdoll2_move", _cmd_ragdoll2_move)
		console.register_command("ragdoll2_state", _cmd_ragdoll2_state)
		console.register_command("ragdoll2_debug", _cmd_ragdoll2_debug)

func _cmd_spawn_ragdoll_v2(args: Array) -> void:
	"""Console command to spawn ragdoll v2"""
	var spawn_pos = Vector3(0, 1, 0)
	
	# Check for position arguments
	if args.size() >= 3:
		spawn_pos = Vector3(
			float(args[0]),
			float(args[1]),
			float(args[2])
		)
	
	var _ragdoll = await spawn_ragdoll_v2(spawn_pos)
	print("[Console] Spawned advanced ragdoll v2 at ", spawn_pos)

func _cmd_ragdoll2_move(args: Array) -> void:
	"""Control ragdoll v2 movement"""
	var ragdoll = get_tree().get_first_node_in_group("ragdolls_v2")
	if not ragdoll:
		print("[Console] No ragdoll v2 found!")
		return
	
	var controller = ragdoll.get_meta("controller")
	if not controller:
		print("[Console] No controller found!")
		return
	
	if args.size() == 0:
		print("[Console] Usage: ragdoll2_move <forward/back/left/right/stop>")
		return
	
	var command = args[0].to_lower()
	match command:
		"forward":
			controller.set_movement_input(Vector2(0, -1))
		"back", "backward":
			controller.set_movement_input(Vector2(0, 1))
		"left":
			controller.set_movement_input(Vector2(-1, 0))
		"right":
			controller.set_movement_input(Vector2(1, 0))
		"stop":
			controller.set_movement_input(Vector2.ZERO)
		_:
			print("[Console] Unknown movement: ", command)

func _cmd_ragdoll2_state(_args: Array) -> void:
	"""Show ragdoll v2 state"""
	var ragdoll = get_tree().get_first_node_in_group("ragdolls_v2")
	if not ragdoll:
		print("[Console] No ragdoll v2 found!")
		return
	
	var controller = ragdoll.get_meta("controller")
	if controller:
		var state = controller.get_state_info()
		print("\n[Ragdoll V2 State]")
		print("State: ", state.state)
		print("Time in state: ", "%.2f" % state.state_time, "s")
		print("Balanced: ", state.balanced)
		print("Balance margin: ", "%.2f" % state.balance_margin)
		print("Feet grounded: L=", state.left_foot_grounded, " R=", state.right_foot_grounded)
		print("Velocity: ", "%.1f" % state.velocity, " m/s")
		print("Animation: ", state.animation.current_cycle)

func _cmd_ragdoll2_debug(_args: Array) -> void:
	"""Toggle debug visualization"""
	var ragdoll = get_tree().get_first_node_in_group("ragdolls_v2")
	if not ragdoll:
		print("[Console] No ragdoll v2 found!")
		return
	
	var controller = ragdoll.get_meta("controller")
	if controller:
		controller.debug_enabled = not controller.debug_enabled
		if controller.ground_detection:
			controller.ground_detection.debug_enabled = controller.debug_enabled
		if controller.ik_solver:
			controller.ik_solver.enable_debug(controller.debug_enabled)
		print("[Console] Debug visualization: ", controller.debug_enabled)
