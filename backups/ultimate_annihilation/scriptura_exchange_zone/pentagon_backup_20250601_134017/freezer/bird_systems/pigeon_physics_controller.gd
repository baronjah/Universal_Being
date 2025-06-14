# ==================================================
# SCRIPT NAME: pigeon_physics_controller.gd
# DESCRIPTION: Two-triangle bird physics system with walking and flying
# PURPOSE: Simple physics-based character that can walk and fly
# CREATED: 2025-05-24 - Triangular bird physics
# ==================================================

extends CharacterBody3D

signal mode_changed(new_mode: MovementMode)
signal balance_shifted(balance: float)

# ================================
# ENUMS AND CONSTANTS
# ================================

enum MovementMode {
	WALKING,
	FLYING,
	LANDING,
	IDLE
}

# Physics constants
const GRAVITY = -9.8
const WALK_SPEED = 3.0
const FLY_SPEED = 8.0
const JUMP_VELOCITY = 5.0
const BALANCE_RESTORE_SPEED = 2.0

# ================================
# TRIANGLE POINTS
# ================================

# 5 key points forming two triangles
var head_point: Node3D
var left_wing_tip: Node3D
var right_wing_tip: Node3D
var left_leg: Node3D
var right_leg: Node3D
var tail_weight: Node3D  # Back weight for balance

# Visual meshes
var body_mesh: MeshInstance3D
var debug_lines: ImmediateMesh

# ================================
# MOVEMENT PROPERTIES
# ================================

var movement_mode: MovementMode = MovementMode.IDLE
var balance: float = 0.0  # -1 = falling left, 1 = falling right
var leg_phase: float = 0.0  # Walking animation phase
var wing_phase: float = 0.0  # Flying animation phase
var is_grounded: bool = true

# Wing positions
var wings_walking_spread: float = 0.5  # Close to body
var wings_flying_spread: float = 2.0   # Wide spread
var current_wing_spread: float = 0.5

# Leg positions
var legs_walking_spread: float = 0.3
var legs_flying_spread: float = 0.1  # Tucked under
var current_leg_spread: float = 0.3

# ================================
# INITIALIZATION
# ================================

func _ready() -> void:
	# Create the 5 points
	_create_physics_points()
	
	# Create visual representation
	_create_visual_mesh()
	
	# Set up collision
	_setup_collision()
	
	# Initialize positions
	_set_idle_position()
	
	set_physics_process(true)

func _create_physics_points() -> void:
	# Head (front top)
	head_point = Node3D.new()
	head_point.name = "HeadPoint"
	head_point.position = Vector3(0, 0.5, 0.5)
	add_child(head_point)
	
	# Wing tips
	left_wing_tip = Node3D.new()
	left_wing_tip.name = "LeftWingTip"
	add_child(left_wing_tip)
	
	right_wing_tip = Node3D.new()
	right_wing_tip.name = "RightWingTip"
	add_child(right_wing_tip)
	
	# Legs
	left_leg = Node3D.new()
	left_leg.name = "LeftLeg"
	add_child(left_leg)
	
	right_leg = Node3D.new()
	right_leg.name = "RightLeg"
	add_child(right_leg)
	
	# Tail weight (back balance)
	tail_weight = Node3D.new()
	tail_weight.name = "TailWeight"
	tail_weight.position = Vector3(0, 0.3, -0.5)
	add_child(tail_weight)

func _create_visual_mesh() -> void:
	body_mesh = MeshInstance3D.new()
	body_mesh.name = "BirdBody"
	
	# Create initial mesh
	_update_triangles()
	add_child(body_mesh)
	
	# Create material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color(0.8, 0.6, 0.3)  # Bird-like color
	material.vertex_color_use_as_albedo = true
	body_mesh.material_override = material

func _setup_collision() -> void:
	# Simple capsule collision
	var collision = CollisionShape3D.new()
	var shape = CapsuleShape3D.new()
	shape.radius = 0.3
	shape.height = 1.0
	collision.shape = shape
	add_child(collision)

# ================================
# PHYSICS PROCESS
# ================================

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor() and movement_mode != MovementMode.FLYING:
		velocity.y += GRAVITY * delta
	else:
		is_grounded = true
	
	# Update based on mode
	match movement_mode:
		MovementMode.WALKING:
			_process_walking(delta)
		MovementMode.FLYING:
			_process_flying(delta)
		MovementMode.LANDING:
			_process_landing(delta)
		MovementMode.IDLE:
			_process_idle(delta)
	
	# Update balance
	_update_balance(delta)
	
	# Update visual mesh
	_update_triangles()
	
	# Move and check collisions
	move_and_slide()

# ================================
# MOVEMENT MODES
# ================================

func _process_walking(delta: float) -> void:
	# Animate legs
	leg_phase += delta * 4.0  # Walking speed
	
	# Move legs in walking pattern
	var leg_offset = sin(leg_phase) * 0.2
	left_leg.position = Vector3(-current_leg_spread, -0.5 + abs(leg_offset), leg_offset)
	right_leg.position = Vector3(current_leg_spread, -0.5 + abs(-leg_offset), -leg_offset)
	
	# Keep wings close
	current_wing_spread = lerp(current_wing_spread, wings_walking_spread, delta * 3.0)
	left_wing_tip.position = Vector3(-current_wing_spread, 0.2, 0)
	right_wing_tip.position = Vector3(current_wing_spread, 0.2, 0)
	
	# Move tail for balance
	var balance_offset = balance * 0.3
	tail_weight.position.x = -balance_offset  # Opposite of tilt
	
	# Apply movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * WALK_SPEED
		velocity.z = direction.z * WALK_SPEED
		
		# Affect balance when moving
		balance += input_dir.x * delta * 2.0
		balance = clamp(balance, -1.0, 1.0)

func _process_flying(delta: float) -> void:
	# Animate wings
	wing_phase += delta * 3.0  # Flapping speed
	
	# Flap wings
	var wing_flap = sin(wing_phase) * 0.3
	current_wing_spread = lerp(current_wing_spread, wings_flying_spread, delta * 5.0)
	left_wing_tip.position = Vector3(-current_wing_spread, 0.3 + wing_flap, 0)
	right_wing_tip.position = Vector3(current_wing_spread, 0.3 - wing_flap, 0)
	
	# Tuck legs
	current_leg_spread = lerp(current_leg_spread, legs_flying_spread, delta * 5.0)
	left_leg.position = Vector3(-current_leg_spread, -0.2, -0.3)
	right_leg.position = Vector3(current_leg_spread, -0.2, -0.3)
	
	# Flying controls
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * FLY_SPEED
		velocity.z = direction.z * FLY_SPEED
	
	# Vertical control
	if Input.is_action_pressed("fly_up"):
		velocity.y = min(velocity.y + delta * 10.0, 5.0)
	elif Input.is_action_pressed("fly_down"):
		velocity.y = max(velocity.y - delta * 10.0, -5.0)
	else:
		velocity.y *= 0.95  # Air resistance

func _process_landing(delta: float) -> void:
	# Transition from flying to walking
	current_wing_spread = lerp(current_wing_spread, wings_walking_spread, delta * 2.0)
	current_leg_spread = lerp(current_leg_spread, legs_walking_spread, delta * 2.0)
	
	# Extend legs for landing
	left_leg.position.y = lerp(left_leg.position.y, -0.5, delta * 5.0)
	right_leg.position.y = lerp(right_leg.position.y, -0.5, delta * 5.0)
	
	if is_grounded:
		set_movement_mode(MovementMode.IDLE)

func _process_idle(_delta: float) -> void:
	# Gentle idle animation
	var idle_time = Time.get_ticks_msec() / 1000.0
	
	# Slight wing movement
	var wing_idle = sin(idle_time * 2.0) * 0.05
	left_wing_tip.position.y = 0.2 + wing_idle
	right_wing_tip.position.y = 0.2 - wing_idle
	
	# Shift weight occasionally
	if randf() < 0.01:
		balance += randf_range(-0.3, 0.3)
	
	# Dampen velocity
	velocity.x *= 0.9
	velocity.z *= 0.9

# ================================
# BALANCE SYSTEM
# ================================

func _update_balance(delta: float) -> void:
	# Natural balance restoration
	var old_balance = balance
	balance = lerp(balance, 0.0, delta * BALANCE_RESTORE_SPEED)
	
	# Emit signal if balance changed significantly
	if abs(old_balance - balance) > 0.01:
		balance_shifted.emit(balance)
	
	# Apply tilt based on balance
	rotation.z = balance * 0.2  # Slight tilt
	
	# Shift center of gravity
	var cog_shift = balance * 0.1
	head_point.position.x = cog_shift
	tail_weight.position.x = -cog_shift * 1.5  # Tail compensates more

# ================================
# TRIANGLE VISUALIZATION
# ================================

func _update_triangles() -> void:
	# Create mesh if it doesn't exist
	if not body_mesh.mesh:
		body_mesh.mesh = ArrayMesh.new()
		
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var colors = PackedColorArray()
	
	# Get world positions
	var head = head_point.position
	var l_wing = left_wing_tip.position
	var r_wing = right_wing_tip.position
	var l_leg = left_leg.position
	var r_leg = right_leg.position
	
	# Triangle 1: Head - Left Wing - Left Leg
	vertices.append(head)
	vertices.append(l_wing)
	vertices.append(l_leg)
	
	# Triangle 2: Head - Right Wing - Right Leg
	vertices.append(head)
	vertices.append(r_wing)
	vertices.append(r_leg)
	
	# Calculate normals
	for i in range(6):
		normals.append(Vector3.UP)
		
	# Colors based on mode
	var mode_color = Color.WHITE
	match movement_mode:
		MovementMode.WALKING:
			mode_color = Color(0.8, 0.6, 0.3)
		MovementMode.FLYING:
			mode_color = Color(0.3, 0.6, 0.9)
		MovementMode.LANDING:
			mode_color = Color(0.6, 0.6, 0.4)
		MovementMode.IDLE:
			mode_color = Color(0.7, 0.5, 0.3)
	
	for i in range(6):
		colors.append(mode_color)
	
	# Update mesh
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	
	body_mesh.mesh.clear_surfaces()
	body_mesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

# ================================
# PUBLIC METHODS
# ================================


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

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func set_movement_mode(mode: MovementMode) -> void:
	movement_mode = mode
	mode_changed.emit(mode)
	
	match mode:
		MovementMode.FLYING:
			is_grounded = false
		MovementMode.LANDING:
			pass  # Handled in process

func jump() -> void:
	if is_grounded and movement_mode == MovementMode.IDLE:
		velocity.y = JUMP_VELOCITY
		set_movement_mode(MovementMode.FLYING)

func _set_idle_position() -> void:
	left_wing_tip.position = Vector3(-wings_walking_spread, 0.2, 0)
	right_wing_tip.position = Vector3(wings_walking_spread, 0.2, 0)
	left_leg.position = Vector3(-legs_walking_spread, -0.5, 0)
	right_leg.position = Vector3(legs_walking_spread, -0.5, 0)

# ================================
# INPUT HANDLING
# ================================

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if movement_mode == MovementMode.IDLE or movement_mode == MovementMode.WALKING:
			jump()
	elif event.is_action_pressed("fly_toggle"):
		if movement_mode == MovementMode.FLYING:
			set_movement_mode(MovementMode.LANDING)
		elif is_grounded:
			jump()
	elif event.is_action_pressed("walk"):
		if is_grounded and movement_mode == MovementMode.IDLE:
			set_movement_mode(MovementMode.WALKING)