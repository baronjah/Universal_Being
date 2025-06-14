# ==================================================
# SCRIPT NAME: advanced_being_system.gd
# DESCRIPTION: Advanced skeletal being with physics/animation hybrid
# PURPOSE: Create realistic beings with proper bone hierarchy
# CREATED: 2025-05-26 - Evolution from simple ragdoll
# ==================================================

extends UniversalBeingBase
# Being state
enum BeingState {
	ANIMATED,      # Full animation control
	PHYSICS,       # Full physics ragdoll
	HYBRID,        # Mix of animation and physics
	RECOVERING     # Transitioning from physics to animated
}

# Body configuration
@export var use_standard_humanoid: bool = true
@export var bone_mass_multiplier: float = 1.0
@export var enable_soft_dynamics: bool = true
@export var enable_ik_systems: bool = true

# Core components
var skeleton: Skeleton3D
var physical_simulator: PhysicalBoneSimulator3D
var spring_simulator: SpringBoneSimulator3D
var animation_tree: AnimationTree
var foot_ik_left: SkeletonIK3D
var foot_ik_right: SkeletonIK3D

# State management
var current_state: BeingState = BeingState.ANIMATED
var physics_blend: float = 0.0  # 0 = full animation, 1 = full physics
var recovery_timer: float = 0.0

# Bone tracking
var bone_map: Dictionary = {}  # bone_name -> bone_id
var physical_bones: Array[PhysicalBone3D] = []
var critical_bones: Array = ["Hips", "Spine", "Head"]  # Must stay stable

# Physics parameters
var ragdoll_trigger_force: float = 500.0  # Force needed to trigger ragdoll
var recovery_time: float = 2.0  # Time to recover from ragdoll
var blend_speed: float = 3.0  # How fast to blend between states

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("🦴 [AdvancedBeing] Initializing advanced skeletal system...")
	
	# Create core skeleton
	_create_skeleton()
	
	# Add physics system
	_setup_physics_bones()
	
	# Add soft dynamics
	if enable_soft_dynamics:
		_setup_spring_bones()
	
	# Add IK systems
	if enable_ik_systems:
		_setup_ik_systems()
	
	# Initialize animation
	_setup_animation_system()
	
	print("✨ [AdvancedBeing] Advanced being ready!")

func _create_skeleton() -> void:
	skeleton = Skeleton3D.new()
	skeleton.name = "Skeleton"
	add_child(skeleton)
	
	if use_standard_humanoid:
		_create_humanoid_skeleton()
	else:
		_create_custom_skeleton()
	
	# Enable physics animation
	skeleton.animate_physical_bones = true

func _create_humanoid_skeleton() -> void:
	# Create standard humanoid bone hierarchy
	var bones = {
		# Core
		"Root": {"parent": -1, "rest": Transform3D()},
		"Hips": {"parent": "Root", "rest": Transform3D(Basis(), Vector3(0, 1.0, 0))},
		
		# Spine
		"Spine": {"parent": "Hips", "rest": Transform3D(Basis(), Vector3(0, 0.15, 0))},
		"Spine1": {"parent": "Spine", "rest": Transform3D(Basis(), Vector3(0, 0.15, 0))},
		"Spine2": {"parent": "Spine1", "rest": Transform3D(Basis(), Vector3(0, 0.15, 0))},
		"Neck": {"parent": "Spine2", "rest": Transform3D(Basis(), Vector3(0, 0.1, 0))},
		"Head": {"parent": "Neck", "rest": Transform3D(Basis(), Vector3(0, 0.15, 0))},
		
		# Left arm
		"Shoulder_L": {"parent": "Spine2", "rest": Transform3D(Basis(), Vector3(0.15, 0.1, 0))},
		"UpperArm_L": {"parent": "Shoulder_L", "rest": Transform3D(Basis(), Vector3(0.2, 0, 0))},
		"LowerArm_L": {"parent": "UpperArm_L", "rest": Transform3D(Basis(), Vector3(0.25, 0, 0))},
		"Hand_L": {"parent": "LowerArm_L", "rest": Transform3D(Basis(), Vector3(0.15, 0, 0))},
		
		# Right arm (mirror)
		"Shoulder_R": {"parent": "Spine2", "rest": Transform3D(Basis(), Vector3(-0.15, 0.1, 0))},
		"UpperArm_R": {"parent": "Shoulder_R", "rest": Transform3D(Basis(), Vector3(-0.2, 0, 0))},
		"LowerArm_R": {"parent": "UpperArm_R", "rest": Transform3D(Basis(), Vector3(-0.25, 0, 0))},
		"Hand_R": {"parent": "LowerArm_R", "rest": Transform3D(Basis(), Vector3(-0.15, 0, 0))},
		
		# Left leg
		"UpperLeg_L": {"parent": "Hips", "rest": Transform3D(Basis(), Vector3(0.1, -0.1, 0))},
		"LowerLeg_L": {"parent": "UpperLeg_L", "rest": Transform3D(Basis(), Vector3(0, -0.4, 0))},
		"Foot_L": {"parent": "LowerLeg_L", "rest": Transform3D(Basis(), Vector3(0, -0.4, 0))},
		"Toes_L": {"parent": "Foot_L", "rest": Transform3D(Basis(), Vector3(0, 0, 0.1))},
		
		# Right leg (mirror)
		"UpperLeg_R": {"parent": "Hips", "rest": Transform3D(Basis(), Vector3(-0.1, -0.1, 0))},
		"LowerLeg_R": {"parent": "UpperLeg_R", "rest": Transform3D(Basis(), Vector3(0, -0.4, 0))},
		"Foot_R": {"parent": "LowerLeg_R", "rest": Transform3D(Basis(), Vector3(0, -0.4, 0))},
		"Toes_R": {"parent": "Foot_R", "rest": Transform3D(Basis(), Vector3(0, 0, 0.1))},
	}
	
	# Create bones
	for bone_name in bones:
		var bone_data = bones[bone_name]
		var _bone_id = skeleton.add_bone(bone_name)
		bone_map[bone_name] = bone_id
		
		# Set parent
		if bone_data.parent is String:
			var parent_id = bone_map[bone_data.parent]
			skeleton.set_bone_parent(bone_id, parent_id)
		else:
			skeleton.set_bone_parent(bone_id, bone_data.parent)
		
		# Set rest pose
		skeleton.set_bone_rest(bone_id, bone_data.rest)

func _create_custom_skeleton() -> void:
	# Override this for custom creatures
	pass

func _setup_physics_bones() -> void:
	# Create physical bone simulator
	physical_simulator = PhysicalBoneSimulator3D.new()
	physical_simulator.name = "PhysicalBoneSimulator"
	FloodgateController.universal_add_child(physical_simulator, skeleton)
	
	# Create PhysicalBone3D for each bone that needs physics
	var physics_bones = ["Hips", "Spine", "Spine1", "Spine2", "Head",
						"UpperArm_L", "LowerArm_L", "Hand_L",
						"UpperArm_R", "LowerArm_R", "Hand_R",
						"UpperLeg_L", "LowerLeg_L", "Foot_L",
						"UpperLeg_R", "LowerLeg_R", "Foot_R"]
	
	for bone_name in physics_bones:
		if bone_map.has(bone_name):
			var _bone_id = bone_map[bone_name]
			var phys_bone = PhysicalBone3D.new()
			phys_bone.name = bone_name + "_PhysicalBone"
			
			# Configure physics properties
			phys_bone.bone_name = bone_name
			phys_bone.mass = _get_bone_mass(bone_name) * bone_mass_multiplier
			phys_bone.friction = 0.5
			phys_bone.bounce = 0.1
			phys_bone.linear_damp = 0.5
			phys_bone.angular_damp = 2.0
			phys_bone.can_sleep = true
			
			# Set joint type based on bone
			phys_bone.joint_type = _get_joint_type(bone_name)
			
			# Add to simulator
			FloodgateController.universal_add_child(phys_bone, physical_simulator)
			physical_bones.append(phys_bone)
	
	# Start inactive (animation mode)
	physical_simulator.active = false

func _get_bone_mass(bone_name: String) -> float:
	# Realistic mass distribution
	match bone_name:
		"Hips": return 10.0
		"Spine", "Spine1", "Spine2": return 5.0
		"Head": return 4.0
		"UpperArm_L", "UpperArm_R": return 2.0
		"LowerArm_L", "LowerArm_R": return 1.5
		"Hand_L", "Hand_R": return 0.5
		"UpperLeg_L", "UpperLeg_R": return 4.0
		"LowerLeg_L", "LowerLeg_R": return 3.0
		"Foot_L", "Foot_R": return 1.0
		_: return 1.0

func _get_joint_type(bone_name: String) -> PhysicalBone3D.JointType:
	# Appropriate joint types for each bone
	match bone_name:
		"Head", "Hand_L", "Hand_R": 
			return PhysicalBone3D.JOINT_TYPE_CONE
		"UpperLeg_L", "UpperLeg_R", "UpperArm_L", "UpperArm_R":
			return PhysicalBone3D.JOINT_TYPE_6DOF  # Full range
		"LowerLeg_L", "LowerLeg_R", "LowerArm_L", "LowerArm_R":
			return PhysicalBone3D.JOINT_TYPE_HINGE  # Single axis
		_:
			return PhysicalBone3D.JOINT_TYPE_6DOF

func _setup_spring_bones() -> void:
	# Add spring bone simulator for soft dynamics
	spring_simulator = SpringBoneSimulator3D.new()
	spring_simulator.name = "SpringBoneSimulator"
	FloodgateController.universal_add_child(spring_simulator, skeleton)
	
	# Example: Add hair chain
	if bone_map.has("Head"):
		# Would add hair bones here
		pass

func _setup_ik_systems() -> void:
	# Left foot IK
	foot_ik_left = SkeletonIK3D.new()
	foot_ik_left.name = "FootIK_L"
	foot_ik_left.root_bone = "UpperLeg_L"
	foot_ik_left.tip_bone = "Foot_L"
	foot_ik_left.use_magnet = true
	foot_ik_left.magnet = Vector3(-0.5, 0, 6)  # Guide knee direction
	FloodgateController.universal_add_child(foot_ik_left, skeleton)
	
	# Right foot IK
	foot_ik_right = SkeletonIK3D.new()
	foot_ik_right.name = "FootIK_R"
	foot_ik_right.root_bone = "UpperLeg_R"
	foot_ik_right.tip_bone = "Foot_R"
	foot_ik_right.use_magnet = true
	foot_ik_right.magnet = Vector3(0.5, 0, 6)
	FloodgateController.universal_add_child(foot_ik_right, skeleton)

func _setup_animation_system() -> void:
	# Create animation tree for blending
	animation_tree = AnimationTree.new()
	animation_tree.name = "AnimationTree"
	add_child(animation_tree)
	
	# Set skeleton path
	animation_tree.tree_root = AnimationNodeStateMachine.new()
	animation_tree.anim_player = NodePath("../AnimationPlayer")
	
	# Would setup animation states here


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	# Update based on current state
	match current_state:
		BeingState.ANIMATED:
			_process_animated(delta)
		BeingState.PHYSICS:
			_process_physics(delta)
		BeingState.HYBRID:
			_process_hybrid(delta)
		BeingState.RECOVERING:
			_process_recovery(delta)
	
	# Update IK if enabled
	if enable_ik_systems:
		_update_ik_targets()

func _process_animated(_delta: float) -> void:
	# Full animation control
	pass

func _process_physics(_delta: float) -> void:
	# Full physics simulation
	pass

func _process_hybrid(_delta: float) -> void:
	# Blend between animation and physics
	pass

func _process_recovery(_delta: float) -> void:
	# Recover from ragdoll to animation
	recovery_timer += delta
	if recovery_timer >= recovery_time:
		current_state = BeingState.ANIMATED
		physical_simulator.active = false
		recovery_timer = 0.0

func _update_ik_targets() -> void:
	# Update foot IK targets based on ground
	# Would raycast down from feet to find ground
	pass

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
func trigger_ragdoll(impact_force: Vector3, _impact_point: Vector3) -> void:
	"""Switch to full physics ragdoll mode"""
	if impact_force.length() > ragdoll_trigger_force:
		current_state = BeingState.PHYSICS
		physical_simulator.active = true
		
		# Apply impact to nearest bone
		# Would find closest physical bone and apply impulse

func set_animation_state(state_name: String) -> void:
	"""Change animation state"""
	if animation_tree:
		# Would transition animation state
		pass

func blend_to_physics(amount: float) -> void:
	"""Gradually blend to physics (0-1)"""
	physics_blend = clamp(amount, 0.0, 1.0)
	if physics_blend > 0.01:
		current_state = BeingState.HYBRID
	else:
		current_state = BeingState.ANIMATED

func get_bone_global_transform(bone_name: String) -> Transform3D:
	"""Get world transform of a bone"""
	if bone_map.has(bone_name):
		var _bone_id = bone_map[bone_name]
		return skeleton.global_transform * skeleton.get_bone_global_pose(bone_id)
	return Transform3D()