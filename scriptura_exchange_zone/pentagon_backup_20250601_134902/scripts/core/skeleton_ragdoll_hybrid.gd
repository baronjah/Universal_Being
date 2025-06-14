# ==================================================
# SCRIPT NAME: skeleton_ragdoll_hybrid.gd
# DESCRIPTION: Hybrid skeleton/physics ragdoll - best of both worlds
# PURPOSE: Upgrade our ragdoll with proper skeletal structure
# CREATED: 2025-05-26 - Practical implementation
# ==================================================

extends UniversalBeingBase
# This is a practical upgrade path from our 7-part ragdoll
# Uses Skeleton3D for proper bone hierarchy but keeps physics simple

signal ragdoll_state_changed(new_state: String)
signal bone_impacted(bone_name: String, force: Vector3)

# Ragdoll state
enum RagdollMode {
	ANIMATED,     # Skeleton controls pose
	PHYSICS,      # Physics bodies control
	BLENDED       # Mix of both
}

# Configuration
@export var start_mode: RagdollMode = RagdollMode.PHYSICS
@export var bone_radius: float = 0.08
@export var bone_mass: float = 1.0
@export var use_simple_shapes: bool = true  # Capsules vs complex

# Components
var skeleton: Skeleton3D
var physics_bones: Dictionary = {}  # bone_name -> RigidBody3D
var joints: Dictionary = {}  # connection_name -> Joint3D
var current_mode: RagdollMode

# Simple humanoid structure (similar to our 7-part but with skeleton)
var bone_structure = {
	"Root": {"parent": -1, "pos": Vector3.ZERO, "create_physics": false},
	"Hips": {"parent": "Root", "pos": Vector3(0, 1.0, 0), "create_physics": true},
	"Spine": {"parent": "Hips", "pos": Vector3(0, 0.3, 0), "create_physics": true},
	"Head": {"parent": "Spine", "pos": Vector3(0, 0.3, 0), "create_physics": true},
	"UpperLeg_L": {"parent": "Hips", "pos": Vector3(0.15, -0.1, 0), "create_physics": true},
	"LowerLeg_L": {"parent": "UpperLeg_L", "pos": Vector3(0, -0.4, 0), "create_physics": true},
	"Foot_L": {"parent": "LowerLeg_L", "pos": Vector3(0, -0.35, 0), "create_physics": true},
	"UpperLeg_R": {"parent": "Hips", "pos": Vector3(-0.15, -0.1, 0), "create_physics": true},
	"LowerLeg_R": {"parent": "UpperLeg_R", "pos": Vector3(0, -0.4, 0), "create_physics": true},
	"Foot_R": {"parent": "LowerLeg_R", "pos": Vector3(0, -0.35, 0), "create_physics": true}
}

# Bone ID mapping
var bone_ids: Dictionary = {}

# Visual meshes attached to bones
var bone_meshes: Dictionary = {}

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("🦴 [SkeletonRagdoll] Creating hybrid skeleton-physics ragdoll...")
	
	# Create skeleton first
	_create_skeleton()
	
	# Add physics bodies
	_create_physics_bodies()
	
	# Connect with joints
	_create_joints()
	
	# Add visual representation
	_create_visuals()
	
	# Set initial mode
	set_ragdoll_mode(start_mode)
	
	print("✅ [SkeletonRagdoll] Hybrid ragdoll ready!")

func _create_skeleton() -> void:
	skeleton = Skeleton3D.new()
	skeleton.name = "Skeleton"
	add_child(skeleton)
	
	# Create bones
	for bone_name in bone_structure:
		var bone_data = bone_structure[bone_name]
		var bone_id = skeleton.add_bone(bone_name)
		bone_ids[bone_name] = bone_id
		
		# Set parent
		if bone_data.parent is String and bone_ids.has(bone_data.parent):
			skeleton.set_bone_parent(bone_id, bone_ids[bone_data.parent])
		elif bone_data.parent == -1:
			skeleton.set_bone_parent(bone_id, -1)
		
		# Set rest position
		var rest_transform = Transform3D()
		rest_transform.origin = bone_data.pos
		skeleton.set_bone_rest(bone_id, rest_transform)
		skeleton.set_bone_pose_position(bone_id, bone_data.pos)

func _create_physics_bodies() -> void:
	for bone_name in bone_structure:
		var bone_data = bone_structure[bone_name]
		if not bone_data.create_physics:
			continue
		
		# Create rigid body
		var body = RigidBody3D.new()
		body.name = bone_name + "_Body"
		body.mass = bone_mass
		body.linear_damp = 0.5
		body.angular_damp = 2.0
		
		# Create collision shape
		var collision = CollisionShape3D.new()
		
		if use_simple_shapes:
			# Use capsules for limbs, box for torso
			if bone_name in ["Hips", "Spine"]:
				var box = BoxShape3D.new()
				box.size = Vector3(0.3, 0.2, 0.2)
				collision.shape = box
			else:
				var capsule = CapsuleShape3D.new()
				capsule.radius = bone_radius
				capsule.height = _get_bone_length(bone_name)
				collision.shape = capsule
		
		FloodgateController.universal_add_child(collision, body)
		
		# Position at bone location
		if bone_ids.has(bone_name):
			var bone_id = bone_ids[bone_name]
			var bone_pose = skeleton.get_bone_global_pose(bone_id)
			body.global_transform = skeleton.global_transform * bone_pose
			
			# Connect to skeleton bone
			body.set_meta("bone_id", bone_id)
			body.set_meta("bone_name", bone_name)
		else:
			print("[SkeletonRagdoll] Warning: bone_id not found for " + bone_name)
			body.set_meta("bone_name", bone_name)
		
		# Add to scene
		add_child(body)
		physics_bones[bone_name] = body

func _get_bone_length(bone_name: String) -> float:
	match bone_name:
		"Head": return 0.2
		"UpperLeg_L", "UpperLeg_R": return 0.4
		"LowerLeg_L", "LowerLeg_R": return 0.35
		"Foot_L", "Foot_R": return 0.15
		_: return 0.3

func _create_joints() -> void:
	# Hip to legs
	_create_joint("Hips", "UpperLeg_L", "Hip_L", Generic6DOFJoint3D)
	_create_joint("Hips", "UpperLeg_R", "Hip_R", Generic6DOFJoint3D)
	
	# Knees (hinge joints)
	_create_joint("UpperLeg_L", "LowerLeg_L", "Knee_L", HingeJoint3D)
	_create_joint("UpperLeg_R", "LowerLeg_R", "Knee_R", HingeJoint3D)
	
	# Ankles
	_create_joint("LowerLeg_L", "Foot_L", "Ankle_L", HingeJoint3D)
	_create_joint("LowerLeg_R", "Foot_R", "Ankle_R", HingeJoint3D)
	
	# Spine
	_create_joint("Hips", "Spine", "Lower_Spine", Generic6DOFJoint3D)
	_create_joint("Spine", "Head", "Neck", ConeTwistJoint3D)

func _create_joint(parent_bone: String, child_bone: String, joint_name: String, joint_type) -> void:
	if not physics_bones.has(parent_bone) or not physics_bones.has(child_bone):
		return
	
	var joint = joint_type.new()
	joint.name = joint_name
	add_child(joint)
	
	var parent_body = physics_bones[parent_bone]
	var child_body = physics_bones[child_bone]
	
	# Position at connection point
	joint.global_position = child_body.global_position
	
	# Set bodies
	joint.node_a = parent_body.get_path()
	joint.node_b = child_body.get_path()
	
	# Configure based on type
	if joint is HingeJoint3D:
		# Knees and ankles bend one way
		joint.set_param(HingeJoint3D.PARAM_LIMIT_LOWER, 0)
		joint.set_param(HingeJoint3D.PARAM_LIMIT_UPPER, PI * 0.75)
		joint.set_flag(HingeJoint3D.FLAG_USE_LIMIT, true)
	elif joint is Generic6DOFJoint3D:
		# Limited rotation for hips and spine
		for axis in ["x", "y", "z"]:
			joint.set_flag(axis, Generic6DOFJoint3D.FLAG_ENABLE_ANGULAR_LIMIT, true)
			joint.set_param(axis, Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -PI/4)
			joint.set_param(axis, Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, PI/4)
	
	joints[joint_name] = joint

func _create_visuals() -> void:
	# Create mesh instances attached to bones
	for bone_name in bone_structure:
		if not bone_structure[bone_name].create_physics:
			continue
		
		if not bone_ids.has(bone_name):
			print("[SkeletonRagdoll] Warning: bone_id not found for visual " + bone_name)
			continue
			
		var _bone_id = bone_ids[bone_name]
		
		# Create bone attachment
		var attachment = BoneAttachment3D.new()
		attachment.name = bone_name + "_Visual"
		attachment.bone_name = bone_name
		# Don't set both bone_name and bone_idx
		FloodgateController.universal_add_child(attachment, skeleton)
		
		# Create mesh
		var mesh_inst = MeshInstance3D.new()
		
		if bone_name == "Head":
			mesh_inst.mesh = SphereMesh.new()
			mesh_inst.mesh.radial_segments = 16
			mesh_inst.mesh.height = 0.2
		else:
			mesh_inst.mesh = CapsuleMesh.new()
			mesh_inst.mesh.radius = bone_radius
			mesh_inst.mesh.height = _get_bone_length(bone_name)
		
		# Add material
		var material = MaterialLibrary.get_material("default")
		material.albedo_color = Color.LIGHT_CORAL
		mesh_inst.material_override = material
		
		FloodgateController.universal_add_child(mesh_inst, attachment)
		bone_meshes[bone_name] = mesh_inst


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	match current_mode:
		RagdollMode.PHYSICS:
			# Update skeleton from physics bodies
			_sync_skeleton_to_physics()
		RagdollMode.ANIMATED:
			# Update physics bodies from skeleton
			_sync_physics_to_skeleton()
		RagdollMode.BLENDED:
			# Mix both
			pass

func _sync_skeleton_to_physics() -> void:
	# Update skeleton bones to match physics body positions
	for bone_name in physics_bones:
		var body = physics_bones[bone_name]
		if not bone_ids.has(bone_name):
			continue
		var bone_id = bone_ids[bone_name]
		
		# Convert physics transform to bone space
		var body_transform = body.global_transform
		var skeleton_inv = skeleton.global_transform.inverse()
		var local_transform = skeleton_inv * body_transform
		
		# Update bone pose
		skeleton.set_bone_pose_position(bone_id, local_transform.origin)
		skeleton.set_bone_pose_rotation(bone_id, local_transform.basis.get_rotation_quaternion())

func _sync_physics_to_skeleton() -> void:
	# Update physics bodies to match skeleton pose
	for bone_name in physics_bones:
		var body = physics_bones[bone_name]
		if not bone_ids.has(bone_name):
			continue
		var bone_id = bone_ids[bone_name]
		
		# Get bone global pose
		var bone_pose = skeleton.get_bone_global_pose(bone_id)
		var global_pose = skeleton.global_transform * bone_pose
		
		# Teleport physics body
		body.global_transform = global_pose
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO

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
func set_ragdoll_mode(mode: RagdollMode) -> void:
	current_mode = mode
	
	match mode:
		RagdollMode.PHYSICS:
			# Enable physics
			for body in physics_bones.values():
				body.freeze = false
			ragdoll_state_changed.emit("physics")
			
		RagdollMode.ANIMATED:
			# Disable physics
			for body in physics_bones.values():
				body.freeze = true
			ragdoll_state_changed.emit("animated")
			
		RagdollMode.BLENDED:
			ragdoll_state_changed.emit("blended")

func apply_impulse_to_bone(bone_name: String, impulse: Vector3) -> void:
	if physics_bones.has(bone_name):
		physics_bones[bone_name].apply_central_impulse(impulse)
		bone_impacted.emit(bone_name, impulse)

func get_bone_position(bone_name: String) -> Vector3:
	if bone_ids.has(bone_name):
		var bone_id = bone_ids[bone_name]
		var pose = skeleton.get_bone_global_pose(bone_id)
		return (skeleton.global_transform * pose).origin
	return Vector3.ZERO

func stand_up() -> void:
	# Similar to our simple walker
	print("[SkeletonRagdoll] Standing up using skeleton system")
	# Would implement standing logic here
