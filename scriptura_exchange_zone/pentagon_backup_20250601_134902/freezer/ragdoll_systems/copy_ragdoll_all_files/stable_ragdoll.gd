# ==================================================
# SCRIPT NAME: stable_ragdoll.gd
# DESCRIPTION: Stable ragdoll character with realistic physics
# CREATED: 2025-05-23 - Stable physics implementation
# ==================================================

extends Node3D

# Core components
var body: RigidBody3D
var head: RigidBody3D
var left_leg: RigidBody3D
var right_leg: RigidBody3D

# Physics parameters - much gentler
const BODY_MASS: float = 10.0
const HEAD_MASS: float = 2.0
const LEG_MASS: float = 3.0

# Movement parameters - very gentle
const LEG_FORCE: float = 5.0  # Gentle stepping force
const FORWARD_FORCE: float = 0.5  # Very gentle forward movement
const MAX_VELOCITY: float = 3.0
const MAX_ANGULAR_VELOCITY: float = 2.0

# Walking state
var is_walking: bool = false
var walk_speed: float = 1.0
var step_timer: float = 0.0
var current_leg: int = 0  # 0 = left, 1 = right
const STEP_DURATION: float = 0.5

# Dialogue system
signal dialogue_spoken(text: String)
var dialogue_timer: float = 0.0
var dialogue_cooldown: float = 3.0

const IDLE_DIALOGUE = [
	"Oh hey there! Nice day for being a ragdoll, isn't it?",
	"You know, I used to have bones... I miss bones.",
	"Is it just me or is gravity extra strong today?",
	"I'm not falling, I'm just testing physics!",
	"These legs are new! Still getting used to them.",
	"Walking is harder than it looks, you know?"
]

const WALKING_DIALOGUE = [
	"Left foot, right foot, left foot, right foot...",
	"Look at me go! I'm practically running!",
	"Who needs balance when you have determination?",
	"I think I'm getting the hang of this walking thing!",
	"Onward! To adventure! Or at least to not falling over!",
	"Walking level: Expert. Falling level: Also expert."
]

const COLLISION_DIALOGUE = [
	"Ow! That wasn't supposed to be there!",
	"I meant to do that!",
	"Physics! My old nemesis!",
	"That's gonna leave a mark... if I had skin.",
	"Bonk! Right on the noggin!",
	"I'm okay! Everything's fine! Nothing to see here!"
]

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_create_stable_ragdoll()
	set_physics_process(true)

func _create_stable_ragdoll() -> void:
	# Create main body (torso)
	body = RigidBody3D.new()
	body.name = "Body"
	body.mass = BODY_MASS
	body.linear_damp = 2.0  # High damping for stability
	body.angular_damp = 4.0
	body.add_to_group("ragdoll_body")
	add_child(body)
	
	# Body mesh
	var body_mesh = MeshInstance3D.new()
	var body_box = BoxMesh.new()
	body_box.size = Vector3(0.8, 1.2, 0.4)
	body_mesh.mesh = body_box
	
	var body_mat = StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.3, 0.5, 0.8)
	body_mesh.material_override = body_mat
	body.add_child(body_mesh)
	
	# Body collision
	var body_collision = CollisionShape3D.new()
	var body_shape = BoxShape3D.new()
	body_shape.size = body_box.size
	body_collision.shape = body_shape
	body.add_child(body_collision)
	
	# Create head
	head = RigidBody3D.new()
	head.name = "Head"
	head.mass = HEAD_MASS
	head.position = Vector3(0, 0.9, 0)
	head.linear_damp = 2.0
	head.angular_damp = 4.0
	add_child(head)
	
	# Head mesh
	var head_mesh = MeshInstance3D.new()
	var head_sphere = SphereMesh.new()
	head_sphere.radius = 0.3
	head_mesh.mesh = head_sphere
	
	var head_mat = StandardMaterial3D.new()
	head_mat.albedo_color = Color(0.9, 0.7, 0.6)
	head_mesh.material_override = head_mat
	head.add_child(head_mesh)
	
	# Head collision
	var head_collision = CollisionShape3D.new()
	var head_shape = SphereShape3D.new()
	head_shape.radius = 0.3
	head_collision.shape = head_shape
	head.add_child(head_collision)
	
	# Create legs
	_create_leg(true)  # Left leg
	_create_leg(false)  # Right leg
	
	# Connect head to body with a joint
	var neck_joint = Generic6DOFJoint3D.new()
	neck_joint.node_a = body.get_path()
	neck_joint.node_b = head.get_path()
	neck_joint.position = Vector3(0, 0.6, 0)
	add_child(neck_joint)
	
	# Limited neck rotation
	neck_joint.set("angular_limit_x/enabled", true)
	neck_joint.set("angular_limit_x/upper_angle", deg_to_rad(30))
	neck_joint.set("angular_limit_x/lower_angle", deg_to_rad(-30))
	neck_joint.set("angular_limit_y/enabled", true)
	neck_joint.set("angular_limit_y/upper_angle", deg_to_rad(45))
	neck_joint.set("angular_limit_y/lower_angle", deg_to_rad(-45))
	neck_joint.set("angular_limit_z/enabled", true)
	neck_joint.set("angular_limit_z/upper_angle", deg_to_rad(20))
	neck_joint.set("angular_limit_z/lower_angle", deg_to_rad(-20))
	
	# Connect collision signals
	body.body_entered.connect(_on_body_collision)
	head.body_entered.connect(_on_head_collision)

func _create_leg(is_left: bool) -> void:
	var leg = RigidBody3D.new()
	leg.name = "LeftLeg" if is_left else "RightLeg"
	leg.mass = LEG_MASS
	leg.position = Vector3(-0.3 if is_left else 0.3, -0.6, 0)
	leg.linear_damp = 3.0  # High damping for stable legs
	leg.angular_damp = 5.0
	add_child(leg)
	
	# Leg mesh - rectangular prism
	var leg_mesh = MeshInstance3D.new()
	var leg_box = BoxMesh.new()
	leg_box.size = Vector3(0.25, 0.8, 0.25)
	leg_mesh.mesh = leg_box
	leg_mesh.position.y = -0.4  # Offset down
	
	var leg_mat = StandardMaterial3D.new()
	leg_mat.albedo_color = Color(0.8, 0.3, 0.3)  # Reddish color
	leg_mesh.material_override = leg_mat
	leg.add_child(leg_mesh)
	
	# Leg collision
	var leg_collision = CollisionShape3D.new()
	var leg_shape = BoxShape3D.new()
	leg_shape.size = leg_box.size
	leg_collision.shape = leg_shape
	leg_collision.position.y = -0.4
	leg.add_child(leg_collision)
	
	# Connect leg to body with hip joint
	var hip_joint = HingeJoint3D.new()
	hip_joint.node_a = body.get_path()
	hip_joint.node_b = leg.get_path()
	hip_joint.position = Vector3(-0.3 if is_left else 0.3, -0.6, 0)
	add_child(hip_joint)
	
	# Set hip joint limits - only swing forward/backward
	hip_joint.set("angular_limit/enable", true)
	hip_joint.set("angular_limit/upper", deg_to_rad(45))  # Forward
	hip_joint.set("angular_limit/lower", deg_to_rad(-45))  # Backward
	hip_joint.set("motor/enable", true)
	hip_joint.set("motor/target_velocity", 0.0)
	hip_joint.set("motor/max_impulse", 10.0)
	
	# Store reference
	if is_left:
		left_leg = leg
	else:
		right_leg = leg
	
	# Add collision callback
	leg.body_entered.connect(_on_leg_collision.bind(is_left))


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	# Limit velocities for stability
	if body:
		if body.linear_velocity.length() > MAX_VELOCITY:
			body.linear_velocity = body.linear_velocity.normalized() * MAX_VELOCITY
		if body.angular_velocity.length() > MAX_ANGULAR_VELOCITY:
			body.angular_velocity = body.angular_velocity.normalized() * MAX_ANGULAR_VELOCITY
	
	# Walking logic
	if is_walking:
		_process_walking(delta)
	
	# Dialogue system
	_process_dialogue(delta)

func _process_walking(delta: float) -> void:
	step_timer += delta
	
	if step_timer >= STEP_DURATION:
		step_timer = 0.0
		current_leg = 1 - current_leg  # Switch legs
		
		# Apply gentle stepping force
		var target_leg = left_leg if current_leg == 0 else right_leg
		if target_leg:
			# Lift leg slightly
			target_leg.apply_central_impulse(Vector3.UP * LEG_FORCE * walk_speed)
			
			# Move forward gently
			var forward = -global_transform.basis.z
			body.apply_central_impulse(forward * FORWARD_FORCE * walk_speed)

func _process_dialogue(delta: float) -> void:
	dialogue_timer += delta
	
	if dialogue_timer >= dialogue_cooldown:
		dialogue_timer = 0.0
		dialogue_cooldown = randf_range(3.0, 8.0)
		
		# Choose dialogue based on state
		var dialogue_pool = WALKING_DIALOGUE if is_walking else IDLE_DIALOGUE
		var message = dialogue_pool[randi() % dialogue_pool.size()]
		
		emit_signal("dialogue_spoken", message)
		DialogueSystem.show_dialogue(message, global_position + Vector3(0, 2, 0))

func _on_body_collision(other_body: Node) -> void:
	if other_body.is_in_group("spawned_objects"):
		var message = COLLISION_DIALOGUE[randi() % COLLISION_DIALOGUE.size()]
		DialogueSystem.show_dialogue(message, global_position + Vector3(0, 2, 0))

func _on_head_collision(other_body: Node) -> void:
	if other_body.is_in_group("spawned_objects"):
		DialogueSystem.show_dialogue("Bonk! Right on the head!", head.global_position + Vector3(0, 0.5, 0))

func _on_leg_collision(other_body: Node, is_left: bool) -> void:
	if other_body.is_in_group("spawned_objects") and is_walking:
		var leg_name = "left" if is_left else "right"
		DialogueSystem.show_dialogue("My " + leg_name + " leg! That smarts!", global_position)

func start_walking() -> void:
	is_walking = true
	dialogue_timer = 0.0  # Trigger dialogue soon
	DialogueSystem.show_dialogue("Time to walk! This should be interesting...", global_position + Vector3(0, 2, 0))

func stop_walking() -> void:
	is_walking = false
	DialogueSystem.show_dialogue("Phew! Walking is exhausting!", global_position + Vector3(0, 2, 0))

func toggle_walking() -> void:
	if is_walking:
		stop_walking()
	else:
		start_walking()

func set_walk_speed(speed: float) -> void:
	walk_speed = clamp(speed, 0.5, 3.0)
	DialogueSystem.show_dialogue("Walk speed set to " + str(walk_speed) + "!", global_position + Vector3(0, 2, 0))

func get_body() -> RigidBody3D:
	return body
