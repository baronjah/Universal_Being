# ==================================================
# SCRIPT NAME: triangular_bird_walker.gd
# DESCRIPTION: True triangular bird that walks on leg tips
# PURPOSE: Physics-based bird using two triangles as described
# CREATED: 2025-05-24 - Walking on leg tips
# ==================================================

extends RigidBody3D

signal found_food(food_item: Node3D)
signal drinking_water(water_source: Node3D)

# ================================
# BIRD STRUCTURE
# ================================

# The 5 points forming our bird
var head_joint: PinJoint3D
var left_wing_joint: PinJoint3D
var right_wing_joint: PinJoint3D
var left_leg_joint: PinJoint3D  
var right_leg_joint: PinJoint3D

# Physical bodies for each point
var head_body: RigidBody3D
var left_wing_body: RigidBody3D
var right_wing_body: RigidBody3D
var left_leg_body: RigidBody3D
var right_leg_body: RigidBody3D
var tail_body: RigidBody3D  # Balance weight

# Visual meshes
var triangle1_mesh: MeshInstance3D  # Head-LeftWing-LeftLeg
var triangle2_mesh: MeshInstance3D  # Head-RightWing-RightLeg

# ================================
# MOVEMENT PROPERTIES
# ================================

enum BirdState {
	IDLE,
	WALKING,
	FLYING,
	EATING,
	DRINKING
}

var current_state: BirdState = BirdState.IDLE
var walk_phase: float = 0.0
var target_position: Vector3 = Vector3.ZERO
var has_target: bool = false

# Movement parameters
const WALK_FORCE = 10.0
const LEG_LIFT_HEIGHT = 0.3
const WING_FLAP_FORCE = 20.0
const BALANCE_FORCE = 5.0

# Food detection
var food_in_range: Array = []
var water_in_range: Array = []

# ================================
# INITIALIZATION
# ================================

func _ready() -> void:
	# Set up rigid body properties
	mass = 2.0
	linear_damp = 1.0
	angular_damp = 2.0
	
	# Create the bird structure
	_create_bird_physics()
	_create_visual_meshes()
	_create_sensors()
	
	# Start in idle state
	_set_idle_position()

func _create_bird_physics() -> void:
	# Head (front, elevated)
	head_body = _create_body_part("Head", Vector3(0, 0.5, 0.3), 0.3)
	
	# Wings (sides, mid-height)
	left_wing_body = _create_body_part("LeftWing", Vector3(-0.5, 0.3, 0), 0.2)
	right_wing_body = _create_body_part("RightWing", Vector3(0.5, 0.3, 0), 0.2)
	
	# Legs (walking points - these touch the ground)
	left_leg_body = _create_body_part("LeftLeg", Vector3(-0.2, 0, 0), 0.5)
	right_leg_body = _create_body_part("RightLeg", Vector3(0.2, 0, 0), 0.5)
	
	# Tail (back balance weight)
	tail_body = _create_body_part("Tail", Vector3(0, 0.2, -0.3), 0.3)
	
	# Connect with joints
	_create_joints()

func _create_body_part(part_name: String, offset: Vector3, part_mass: float) -> RigidBody3D:
	var body = RigidBody3D.new()
	body.name = part_name
	body.mass = part_mass
	body.position = offset
	
	# Add collision
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.05
	collision.shape = shape
	FloodgateController.universal_add_child(collision, body)
	
	# Small visual indicator
	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.05
	sphere.height = 0.1
	mesh.mesh = sphere
	FloodgateController.universal_add_child(mesh, body)
	
	add_child(body)
	return body

func _create_joints() -> void:
	# Head connects to both wings and legs
	_connect_bodies(head_body, left_wing_body)
	_connect_bodies(head_body, right_wing_body)
	_connect_bodies(head_body, left_leg_body)
	_connect_bodies(head_body, right_leg_body)
	
	# Wings connect to their respective legs
	_connect_bodies(left_wing_body, left_leg_body)
	_connect_bodies(right_wing_body, right_leg_body)
	
	# Tail connects to head for balance
	_connect_bodies(head_body, tail_body)

func _connect_bodies(body_a: RigidBody3D, body_b: RigidBody3D) -> void:
	var joint = PinJoint3D.new()
	joint.node_a = body_a.get_path()
	joint.node_b = body_b.get_path()
	joint.position = (body_a.position + body_b.position) / 2.0
	add_child(joint)

func _create_visual_meshes() -> void:
	# Triangle 1: Head - Left Wing - Left Leg
	triangle1_mesh = MeshInstance3D.new()
	triangle1_mesh.name = "Triangle1"
	add_child(triangle1_mesh)
	
	# Triangle 2: Head - Right Wing - Right Leg
	triangle2_mesh = MeshInstance3D.new()
	triangle2_mesh.name = "Triangle2"
	add_child(triangle2_mesh)
	
	# Create materials
	var mat1 = MaterialLibrary.get_material("default")
	mat1.albedo_color = Color(0.8, 0.4, 0.2)
	mat1.cull_mode = BaseMaterial3D.CULL_DISABLED
	triangle1_mesh.material_override = mat1
	
	var mat2 = MaterialLibrary.get_material("default")
	mat2.albedo_color = Color(0.6, 0.3, 0.1)
	mat2.cull_mode = BaseMaterial3D.CULL_DISABLED
	triangle2_mesh.material_override = mat2

func _create_sensors() -> void:
	# Food detection area
	var food_detector = Area3D.new()
	food_detector.name = "FoodDetector"
	var detection_shape = SphereShape3D.new()
	detection_shape.radius = 3.0
	var collision = CollisionShape3D.new()
	collision.shape = detection_shape
	FloodgateController.universal_add_child(collision, food_detector)
	add_child(food_detector)
	
	# Connect signals
	food_detector.body_entered.connect(_on_food_detected)
	food_detector.body_exited.connect(_on_food_lost)

# ================================
# PHYSICS PROCESS
# ================================

func _physics_process(delta: float) -> void:
	# Update visual triangles
	_update_triangle_meshes()
	
	# Process current state
	match current_state:
		BirdState.IDLE:
			_process_idle(delta)
		BirdState.WALKING:
			_process_walking(delta)
		BirdState.FLYING:
			_process_flying(delta)
		BirdState.EATING:
			_process_eating(delta)
		BirdState.DRINKING:
			_process_drinking(delta)
	
	# Always maintain balance
	_maintain_balance(delta)

func _process_idle(delta: float) -> void:
	# Look for food
	if food_in_range.size() > 0:
		target_position = food_in_range[0].global_position
		has_target = true
		current_state = BirdState.WALKING
	elif randf() < 0.01:  # Random walk
		target_position = global_position + Vector3(
			randf_range(-5, 5), 0, randf_range(-5, 5)
		)
		has_target = true
		current_state = BirdState.WALKING

func _process_walking(delta: float) -> void:
	if not has_target:
		current_state = BirdState.IDLE
		return
	
	# Check if reached target
	var distance = global_position.distance_to(target_position)
	if distance < 0.5:
		has_target = false
		current_state = BirdState.IDLE
		return
	
	# Walking animation phase
	walk_phase += delta * 3.0
	
	# Alternate leg lifting - ONLY LEGS TOUCH GROUND
	var left_lift = max(0, sin(walk_phase)) * LEG_LIFT_HEIGHT
	var right_lift = max(0, -sin(walk_phase)) * LEG_LIFT_HEIGHT
	
	# Apply forces to legs for walking
	var direction = (target_position - global_position).normalized()
	direction.y = 0  # Keep horizontal
	
	# Lift and move legs
	if left_lift > 0.01:  # Left leg is up
		left_leg_body.apply_central_force(Vector3(0, 10, 0))  # Lift
		left_leg_body.apply_central_force(direction * WALK_FORCE)  # Move forward
	else:  # Left leg is down - push against ground
		left_leg_body.apply_central_force(Vector3(0, -5, 0))  # Press down
		right_leg_body.apply_central_force(direction * WALK_FORCE * 0.5)  # Push off
	
	if right_lift > 0.01:  # Right leg is up
		right_leg_body.apply_central_force(Vector3(0, 10, 0))  # Lift
		right_leg_body.apply_central_force(direction * WALK_FORCE)  # Move forward
	else:  # Right leg is down - push against ground
		right_leg_body.apply_central_force(Vector3(0, -5, 0))  # Press down
		left_leg_body.apply_central_force(direction * WALK_FORCE * 0.5)  # Push off
	
	# Keep body upright by pulling head up
	head_body.apply_central_force(Vector3(0, 5, 0))
	
	# Wings help with balance during walking
	left_wing_body.apply_central_force(Vector3(-1, 2, 0) * sin(walk_phase) * 0.5)
	right_wing_body.apply_central_force(Vector3(1, 2, 0) * sin(walk_phase) * 0.5)

func _process_flying(delta: float) -> void:
	# Flap wings for flight
	var flap_phase = Time.get_ticks_msec() / 200.0
	var flap_force = sin(flap_phase) * WING_FLAP_FORCE
	
	left_wing_body.apply_central_force(Vector3(0, flap_force, 0))
	right_wing_body.apply_central_force(Vector3(0, flap_force, 0))
	
	# Tuck legs while flying
	left_leg_body.apply_central_force((tail_body.global_position - left_leg_body.global_position) * 2)
	right_leg_body.apply_central_force((tail_body.global_position - right_leg_body.global_position) * 2)

func _process_eating(delta: float) -> void:
	# Peck at food
	var peck_motion = sin(Time.get_ticks_msec() / 300.0)
	head_body.apply_central_force(Vector3(0, -2 * peck_motion, 2 * peck_motion))

func _process_drinking(delta: float) -> void:
	# Similar to eating but slower
	var drink_motion = sin(Time.get_ticks_msec() / 500.0)
	head_body.apply_central_force(Vector3(0, -1 * drink_motion, 1 * drink_motion))

func _maintain_balance(delta: float) -> void:
	# Use tail as counterweight
	var center_mass = (left_leg_body.global_position + right_leg_body.global_position) / 2.0
	var tilt = head_body.global_position.x - center_mass.x
	
	# Move tail opposite to tilt
	tail_body.apply_central_force(Vector3(-tilt * BALANCE_FORCE, 0, 0))
	
	# Keep head elevated
	if head_body.global_position.y < global_position.y + 0.3:
		head_body.apply_central_force(Vector3(0, 10, 0))

# ================================
# VISUAL UPDATE
# ================================

func _update_triangle_meshes() -> void:
	# Triangle 1: Head - Left Wing - Left Leg
	var verts1 = PackedVector3Array([
		head_body.position,
		left_wing_body.position,
		left_leg_body.position
	])
	
	# Triangle 2: Head - Right Wing - Right Leg  
	var verts2 = PackedVector3Array([
		head_body.position,
		right_wing_body.position,
		right_leg_body.position
	])
	
	_update_mesh(triangle1_mesh, verts1)
	_update_mesh(triangle2_mesh, verts2)

func _update_mesh(mesh_instance: MeshInstance3D, vertices: PackedVector3Array) -> void:
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	# Calculate normal
	var normal = (vertices[1] - vertices[0]).cross(vertices[2] - vertices[0]).normalized()
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array([normal, normal, normal])
	
	if not mesh_instance.mesh:
		mesh_instance.mesh = ArrayMesh.new()
	else:
		mesh_instance.mesh.clear_surfaces()
	
	mesh_instance.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

# ================================
# FOOD DETECTION
# ================================

func _on_food_detected(body: Node3D) -> void:
	if body.is_in_group("fruit") or body.is_in_group("food"):
		food_in_range.append(body)
	elif body.is_in_group("water"):
		water_in_range.append(body)

func _on_food_lost(body: Node3D) -> void:
	food_in_range.erase(body)
	water_in_range.erase(body)

# ================================
# PUBLIC METHODS
# ================================

func _set_idle_position() -> void:
	# Reset to standing position
	head_body.position = Vector3(0, 0.5, 0.3)
	left_wing_body.position = Vector3(-0.5, 0.3, 0)
	right_wing_body.position = Vector3(0.5, 0.3, 0)
	left_leg_body.position = Vector3(-0.2, 0, 0)
	right_leg_body.position = Vector3(0.2, 0, 0)
	tail_body.position = Vector3(0, 0.2, -0.3)


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
func start_flying() -> void:
	current_state = BirdState.FLYING
	# Give initial upward impulse
	apply_central_impulse(Vector3(0, 10, 0))

func land() -> void:
	current_state = BirdState.IDLE