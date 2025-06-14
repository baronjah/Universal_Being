# ==================================================
# SCRIPT NAME: simple_walking_ragdoll.gd
# DESCRIPTION: Simple ragdoll with legs that can walk
# CREATED: 2025-05-23 - Simplified stable version
# ==================================================

extends UniversalBeingBase
# Body parts
var body: RigidBody3D
var left_leg: RigidBody3D
var right_leg: RigidBody3D

# Movement
var is_walking: bool = false
var walk_timer: float = 0.0
var current_leg: int = 0

# Dialogue
const IDLE_DIALOGUE = [
	"Oh hey there! Nice day for being a ragdoll, isn't it?",
	"You know, I used to have bones... I miss bones.",
	"These legs are new! Still getting used to them.",
	"Walking is harder than it looks, you know?"
]

const WALKING_DIALOGUE = [
	"Left foot, right foot, left foot, right foot...",
	"Look at me go! I'm practically running!",
	"Who needs balance when you have determination?",
	"I think I'm getting the hang of this walking thing!"
]

var dialogue_timer: float = 0.0
var dialogue_cooldown: float = 5.0

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_create_simple_ragdoll()

func _create_simple_ragdoll() -> void:
	# Create body
	body = RigidBody3D.new()
	body.name = "Body"
	body.mass = 10.0
	body.linear_damp = 3.0
	body.angular_damp = 5.0
	body.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	body.freeze = false
	add_child(body)
	
	# Body visual
	var body_mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(0.8, 1.5, 0.4)
	body_mesh.mesh = box
	var body_mat = MaterialLibrary.get_material("default")
	body_mat.albedo_color = Color(0.3, 0.5, 0.8)
	body_mesh.material_override = body_mat
	FloodgateController.universal_add_child(body_mesh, body)
	
	# Body collision
	var body_col = CollisionShape3D.new()
	var body_shape = BoxShape3D.new()
	body_shape.size = Vector3(0.8, 1.5, 0.4)
	body_col.shape = body_shape
	FloodgateController.universal_add_child(body_col, body)
	
	# Create simple legs
	_create_simple_leg(true)  # Left
	_create_simple_leg(false)  # Right
	
	# Keep upright force
	body.gravity_scale = 1.0
	body.center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	body.center_of_mass = Vector3(0, -0.5, 0)

func _create_simple_leg(is_left: bool) -> void:
	var leg = RigidBody3D.new()
	leg.name = "LeftLeg" if is_left else "RightLeg"
	leg.mass = 3.0
	leg.linear_damp = 4.0
	leg.angular_damp = 6.0
	
	# Position relative to body
	leg.position = Vector3(-0.25 if is_left else 0.25, -0.75, 0)
	add_child(leg)
	
	# Leg visual - simple box
	var leg_mesh = MeshInstance3D.new()
	var leg_box = BoxMesh.new()
	leg_box.size = Vector3(0.25, 0.8, 0.25)
	leg_mesh.mesh = leg_box
	leg_mesh.position.y = -0.4
	
	var leg_mat = MaterialLibrary.get_material("default")
	leg_mat.albedo_color = Color(0.8, 0.3, 0.3)
	leg_mesh.material_override = leg_mat
	FloodgateController.universal_add_child(leg_mesh, leg)
	
	# Leg collision
	var leg_col = CollisionShape3D.new()
	var leg_shape = BoxShape3D.new()
	leg_shape.size = Vector3(0.25, 0.8, 0.25)
	leg_col.shape = leg_shape
	leg_col.position.y = -0.4
	FloodgateController.universal_add_child(leg_col, leg)
	
	# Simple pin joint to body
	var joint = PinJoint3D.new()
	joint.node_a = body.get_path()
	joint.node_b = leg.get_path()
	joint.position = Vector3(-0.25 if is_left else 0.25, -0.75, 0)
	add_child(joint)
	
	# Store reference
	if is_left:
		left_leg = leg
	else:
		right_leg = leg


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	# Keep body upright
	if body and not is_walking:
		var up_force = Vector3.UP * 50.0
		var current_up = body.global_transform.basis.y
		var correction = up_force * (1.0 - current_up.dot(Vector3.UP))
		body.apply_central_force(correction)
	
	# Walking logic
	if is_walking and body:
		walk_timer += delta
		if walk_timer >= 0.4:  # Step every 0.4 seconds
			walk_timer = 0.0
			_take_step()
	
	# Dialogue
	dialogue_timer += delta
	if dialogue_timer >= dialogue_cooldown:
		dialogue_timer = 0.0
		dialogue_cooldown = randf_range(3.0, 8.0)
		_speak_random_dialogue()

func _take_step() -> void:
	# Alternate legs
	var leg = left_leg if current_leg == 0 else right_leg
	current_leg = 1 - current_leg
	
	if leg and body:
		# Simple hop
		leg.apply_central_impulse(Vector3.UP * 3.0)
		# Move forward
		var forward = -global_transform.basis.z
		body.apply_central_impulse(forward * 0.5)

func _speak_random_dialogue() -> void:
	var dialogue_pool = WALKING_DIALOGUE if is_walking else IDLE_DIALOGUE
	var text = dialogue_pool[randi() % dialogue_pool.size()]
	
	if DialogueSystem:
		DialogueSystem.show_dialogue(text, global_position + Vector3(0, 2, 0))
	
	print("Ragdoll says: " + text)


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
func start_walking() -> void:
	is_walking = true
	walk_timer = 0.0
	if DialogueSystem:
		DialogueSystem.show_dialogue("Time to walk! Here we go!", global_position + Vector3(0, 2, 0))

func stop_walking() -> void:
	is_walking = false
	if DialogueSystem:
		DialogueSystem.show_dialogue("Whew! Walking is hard work!", global_position + Vector3(0, 2, 0))

func toggle_walking() -> void:
	if is_walking:
		stop_walking()
	else:
		start_walking()

func get_body() -> RigidBody3D:
	return body