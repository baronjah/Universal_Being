# ==================================================
# SCRIPT NAME: ragdoll_controller.gd
# DESCRIPTION: Enhanced ragdoll controller for walking and object manipulation
# PURPOSE: Control the ragdoll to walk around, pick up objects, and manipulate the scene
# CREATED: 2025-05-24 - Enhanced for Garden of Eden creation
# ==================================================

extends UniversalBeingBase
# Core Components
@onready var ragdoll_body: Node3D = null
var floodgate: Node = null
var world_builder: Node = null

# Object Manipulation
var held_object: RigidBody3D = null
var pickup_range: float = 2.0
var manipulation_strength: float = 100.0
var carrying_position_offset: Vector3 = Vector3(0, 1.5, -1)

# Movement Control
var movement_target: Vector3 = Vector3.ZERO
var is_moving_to_target: bool = false
var movement_speed: float = 3.0
var rotation_speed: float = 2.0

# AI Behavior
var behavior_state: BehaviorState = BehaviorState.IDLE
var patrol_points: Array[Vector3] = []
var current_patrol_index: int = 0

enum BehaviorState {
	IDLE,
	WALKING,
	INVESTIGATING,
	CARRYING_OBJECT,
	HELPING_PLAYER,
	ORGANIZING_SCENE
}

# Interaction System
signal object_picked_up(object: RigidBody3D)
signal object_dropped(object: RigidBody3D)
signal movement_started(target: Vector3)
signal movement_completed()
signal player_needs_help()

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("[RagdollController] Initializing ragdoll controller...")
	
	# Get references
	floodgate = get_node("/root/FloodgateController") if has_node("/root/FloodgateController") else null
	world_builder = get_node("/root/WorldBuilder") if has_node("/root/WorldBuilder") else null
	
	# Find ragdoll in scene
	_find_ragdoll_body()
	
	# Setup default patrol points
	_setup_default_patrol()
	
	# Start with idle behavior
	set_behavior_state(BehaviorState.IDLE)
	
	print("[RagdollController] Ready - Ragdoll can now help build the garden!")

# Spawn 7-part ragdoll if none found
func _spawn_seven_part_ragdoll() -> void:
	print("[RagdollController] Spawning 7-part ragdoll...")
	
	var SevenPartRagdoll = load("res://scripts/core/seven_part_ragdoll_integration.gd")
	if SevenPartRagdoll:
		ragdoll_body = Node3D.new()  # Now using Node3D as base
		ragdoll_body.name = "SevenPartRagdoll"
		ragdoll_body.set_script(SevenPartRagdoll)
		ragdoll_body.position = Vector3(0, 0, 0)  # Position at ground level
		
		# Add to scene
		FloodgateController.universal_add_child(ragdoll_body, get_tree().current_scene)
		
		print("[RagdollController] 7-part ragdoll spawned and connected")
	else:
		print("[RagdollController] Failed to load 7-part ragdoll script")

func _find_ragdoll_body() -> void:
	# Look for existing ragdoll in scene
	var ragdoll_nodes = get_tree().get_nodes_in_group("ragdoll")
	if ragdoll_nodes.size() > 0:
		ragdoll_body = ragdoll_nodes[0]
		print("[RagdollController] Found existing ragdoll: " + ragdoll_body.name)
		# Connect to 7-part ragdoll if available
		if ragdoll_body.has_method("handle_console_command"):
			print("[RagdollController] Connected to 7-part ragdoll system")
	else:
		print("[RagdollController] No ragdoll found in scene")
		# Try to spawn a 7-part ragdoll
		_spawn_seven_part_ragdoll()

func _setup_default_patrol() -> void:
	# Create a patrol pattern around the scene
	patrol_points = [
		Vector3(5, 0, 5),
		Vector3(-5, 0, 5),
		Vector3(-5, 0, -5),
		Vector3(5, 0, -5),
		Vector3(0, 0, 0)
	]

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	if not ragdoll_body:
		return
		
	match behavior_state:
		BehaviorState.IDLE:
			_process_idle(delta)
		BehaviorState.WALKING:
			_process_walking(delta)
		BehaviorState.INVESTIGATING:
			_process_investigating(delta)
		BehaviorState.CARRYING_OBJECT:
			_process_carrying(delta)
		BehaviorState.HELPING_PLAYER:
			_process_helping(delta)
		BehaviorState.ORGANIZING_SCENE:
			_process_organizing(delta)

func _process_idle(_delta: float) -> void:
	# Look for objects to organize or investigate
	var nearby_objects = _find_nearby_objects()
	
	if nearby_objects.size() > 0:
		var object_to_investigate = nearby_objects[0]
		move_to_object(object_to_investigate)
		set_behavior_state(BehaviorState.INVESTIGATING)
	else:
		# Start patrol if nothing to do
		if patrol_points.size() > 0:
			move_to_position(patrol_points[current_patrol_index])
			set_behavior_state(BehaviorState.WALKING)

func _process_walking(delta: float) -> void:
	if not is_moving_to_target:
		return
		
	var ragdoll_pos = ragdoll_body.global_position
	var distance_to_target = ragdoll_pos.distance_to(movement_target)
	
	if distance_to_target < 1.0:
		# Reached target
		is_moving_to_target = false
		emit_signal("movement_completed")
		
		# Next patrol point
		current_patrol_index = (current_patrol_index + 1) % patrol_points.size()
		set_behavior_state(BehaviorState.IDLE)
	else:
		# Continue walking
		_apply_movement_to_ragdoll(delta)

func _process_investigating(_delta: float) -> void:
	var nearby_objects = _find_nearby_objects()
	
	if nearby_objects.size() > 0 and not held_object:
		var object_to_pickup = nearby_objects[0]
		attempt_pickup(object_to_pickup)
	else:
		set_behavior_state(BehaviorState.IDLE)

func _process_carrying(_delta: float) -> void:
	if not held_object:
		set_behavior_state(BehaviorState.IDLE)
		return
		
	# Keep object at carrying position
	_update_carried_object_position()
	
	# Look for good place to put object
	_look_for_organization_spot()

func _process_helping(_delta: float) -> void:
	# Help player with tasks (future implementation)
	pass

func _process_organizing(_delta: float) -> void:
	# Organize objects in the scene
	if held_object:
		var drop_position = _find_good_drop_position()
		if drop_position != Vector3.ZERO:
			drop_object_at_position(drop_position)

func _apply_movement_to_ragdoll(_delta: float) -> void:
	if not ragdoll_body or not ragdoll_body.has_method("start_walking"):
		return
		
	# Get ragdoll's main body
	var body = null
	if ragdoll_body.has_method("get_body"):
		body = ragdoll_body.get_body()
	
	if not body:
		return
		
	# Calculate direction to target
	var direction = (movement_target - ragdoll_body.global_position).normalized()
	direction.y = 0  # Keep movement horizontal
	
	# Apply movement force
	var movement_force = direction * movement_speed * 10
	body.apply_central_force(movement_force)
	
	# Rotate toward movement direction
	if direction.length() > 0.1:
		var target_rotation = atan2(direction.x, direction.z)
		var current_rotation = ragdoll_body.rotation.y
		var rotation_diff = angle_difference(target_rotation, current_rotation)
		
		body.apply_torque(Vector3(0, rotation_diff * rotation_speed, 0))
	
	# Start walking animation
	ragdoll_body.start_walking()

func _find_nearby_objects(radius: float = 5.0) -> Array:
	var nearby_objects = []
	
	if not ragdoll_body:
		return nearby_objects
		
	var ragdoll_pos = ragdoll_body.global_position
	
	# Find all RigidBody3D objects in scene
	var all_bodies = get_tree().get_nodes_in_group("objects")
	
	for body in all_bodies:
		if body is RigidBody3D and body != held_object:
			var distance = ragdoll_pos.distance_to(body.global_position)
			if distance <= radius:
				nearby_objects.append(body)
	
	# Sort by distance
	nearby_objects.sort_custom(func(a, b): return ragdoll_body.global_position.distance_to(a.global_position) < ragdoll_body.global_position.distance_to(b.global_position))
	
	return nearby_objects

func _update_carried_object_position() -> void:
	if not held_object or not ragdoll_body:
		return
		
	var carry_position = ragdoll_body.global_position + carrying_position_offset
	
	# Smoothly move object to carrying position
	var direction = (carry_position - held_object.global_position)
	held_object.linear_velocity = direction * 5.0
	
	# Reduce rotation while carrying
	held_object.angular_velocity *= 0.8

func _look_for_organization_spot() -> void:
	# Look for a good spot to organize objects
	var random_chance = randf()
	
	if random_chance < 0.02:  # 2% chance per frame to decide to drop
		set_behavior_state(BehaviorState.ORGANIZING_SCENE)

func _find_good_drop_position() -> Vector3:
	if not ragdoll_body:
		return Vector3.ZERO
		
	# Find a spot near ragdoll but not too close to other objects
	var base_pos = ragdoll_body.global_position
	var attempts = 0
	
	while attempts < 10:
		var random_offset = Vector3(
			randf_range(-3, 3),
			0,
			randf_range(-3, 3)
		)
		
		var test_position = base_pos + random_offset
		
		# Check if position is clear
		if _is_position_clear(test_position, 1.5):
			return test_position
		
		attempts += 1
	
	return base_pos + Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))

func _is_position_clear(target_position: Vector3, radius: float) -> bool:
	var nearby = _find_nearby_objects(radius)
	
	for obj in nearby:
		if obj.global_position.distance_to(target_position) < radius:
			return false
	
	return true

# CONSOLE COMMAND INTERFACE METHODS
# These methods are called by the console system


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
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
func cmd_ragdoll_come() -> void:
	print("[RagdollController] Come command received")
	if ragdoll_body and ragdoll_body.has_method("come_to_position"):
		# Get player camera position as target
		var camera = get_viewport().get_camera_3d()
		if camera:
			var target_pos = camera.global_position + camera.global_transform.basis.z * -3
			target_pos.y = 0  # Keep on ground level
			ragdoll_body.come_to_position(target_pos)
		else:
			ragdoll_body.come_to_position(Vector3.ZERO)
	else:
		print("[RagdollController] No 7-part ragdoll connected")

func cmd_ragdoll_pickup() -> void:
	print("[RagdollController] Pickup command received")
	if ragdoll_body and ragdoll_body.has_method("pick_up_nearest_object"):
		ragdoll_body.pick_up_nearest_object()
	else:
		print("[RagdollController] No 7-part ragdoll connected")

func cmd_ragdoll_drop() -> void:
	print("[RagdollController] Drop command received")
	if ragdoll_body and ragdoll_body.has_method("handle_console_command"):
		ragdoll_body.handle_console_command("drop", [])
	else:
		print("[RagdollController] No 7-part ragdoll connected")

func cmd_ragdoll_organize() -> void:
	print("[RagdollController] Organize command received")
	if ragdoll_body and ragdoll_body.has_method("organize_nearby_objects"):
		ragdoll_body.organize_nearby_objects()
	else:
		print("[RagdollController] No 7-part ragdoll connected")

func cmd_ragdoll_patrol() -> void:
	print("[RagdollController] Patrol command received")
	if ragdoll_body:
		set_behavior_state(BehaviorState.WALKING)
		move_to_position(patrol_points[current_patrol_index])
	else:
		print("[RagdollController] No ragdoll connected")

# PUBLIC INTERFACE METHODS

func move_to_position(target: Vector3) -> void:
	movement_target = target
	movement_target.y = 0  # Keep on ground level
	is_moving_to_target = true
	emit_signal("movement_started", target)
	print("[RagdollController] Moving to position: " + str(target))

func move_to_object(object: Node3D) -> void:
	if object:
		var target = object.global_position
		target.y = 0
		move_to_position(target)

func attempt_pickup(object: RigidBody3D) -> bool:
	if not object or held_object or not ragdoll_body:
		return false
		
	var distance = ragdoll_body.global_position.distance_to(object.global_position)
	
	if distance <= pickup_range:
		held_object = object
		set_behavior_state(BehaviorState.CARRYING_OBJECT)
		emit_signal("object_picked_up", object)
		
		# Add object to "carried" group
		object.add_to_group("carried")
		
		print("[RagdollController] Picked up: " + object.name)
		return true
	
	return false

func drop_object() -> void:
	if held_object:
		drop_object_at_position(ragdoll_body.global_position + Vector3(0, 0, 1))

func drop_object_at_position(target_position: Vector3) -> void:
	if not held_object:
		return
		
	# Set object position
	held_object.global_position = target_position
	held_object.linear_velocity = Vector3.ZERO
	held_object.angular_velocity = Vector3.ZERO
	
	# Remove from carried group
	held_object.remove_from_group("carried")
	
	emit_signal("object_dropped", held_object)
	print("[RagdollController] Dropped: " + held_object.name)
	
	held_object = null
	set_behavior_state(BehaviorState.IDLE)

func set_behavior_state(new_state: BehaviorState) -> void:
	var old_state = behavior_state
	behavior_state = new_state
	
	print("[RagdollController] Behavior changed: " + str(old_state) + " -> " + str(new_state))
	
	# State transition logic
	match new_state:
		BehaviorState.WALKING:
			if ragdoll_body and ragdoll_body.has_method("start_walking"):
				ragdoll_body.start_walking()
		BehaviorState.IDLE:
			if ragdoll_body and ragdoll_body.has_method("stop_walking"):
				ragdoll_body.stop_walking()

func help_player_with_task(task_description: String) -> void:
	print("[RagdollController] Helping with: " + task_description)
	set_behavior_state(BehaviorState.HELPING_PLAYER)
	emit_signal("player_needs_help")

func organize_nearby_objects() -> void:
	print("[RagdollController] Starting to organize nearby objects")
	set_behavior_state(BehaviorState.ORGANIZING_SCENE)

# CONSOLE COMMANDS
func cmd_ragdoll_come_here() -> void:
	var camera = get_viewport().get_camera_3d()
	if camera:
		var target = camera.global_position + camera.global_transform.basis.z * -3
		target.y = 0
		move_to_position(target)

func cmd_ragdoll_pickup_nearest() -> void:
	var nearby = _find_nearby_objects(5.0)
	if nearby.size() > 0:
		move_to_object(nearby[0])
		await get_tree().create_timer(2.0).timeout
		attempt_pickup(nearby[0])

# Removed duplicate functions - these are already defined above

## Get ragdoll body for dimensional system
func get_ragdoll_body() -> RigidBody3D:
	return ragdoll_body