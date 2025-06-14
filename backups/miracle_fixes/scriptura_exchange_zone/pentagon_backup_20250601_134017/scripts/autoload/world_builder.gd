# ==================================================
# SCRIPT NAME: world_builder.gd
# DESCRIPTION: Spawns objects in the world based on console commands
# CREATED: 2025-05-23 - Dynamic world creation system
# ==================================================

extends UniversalBeingBase
# Object storage
var spawned_objects: Array[Node3D] = []
var object_counter: Dictionary = {}

# Prefab scenes (we'll create them procedurally for now)
var spawn_height: float = 0.0  # Fixed: was 10.0, now objects spawn on ground
var spawn_distance: float = 5.0

# Position override for scene loading
var use_override_position: bool = false
var override_spawn_position: Vector3 = Vector3.ZERO

# References to new systems
var floodgate: Node = null
var asset_library: Node = null

# Debug control
var debug_level: int = 1  # 0=none, 1=errors only, 2=info, 3=verbose


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
func debug_print(message: String, level: int = 2) -> void:
	if debug_level >= level:
		print(message)

func _get_std_objects() -> Node:
	"""Get StandardizedObjects autoload"""
	return get_node_or_null("/root/StandardizedObjects")

func _ready() -> void:
	# Initialize counters
	object_counter = {
		"tree": 0,
		"rock": 0,
		"box": 0,
		"ball": 0,
		"ramp": 0,
		"ragdoll": 0,
		"sun": 0,
		"astral_being": 0,
		"pathway": 0,
		"bush": 0,
		"fruit": 0,
		"wall": 0,
		"stick": 0,
		"leaf": 0
	}
	
	# Get references to new systems
	floodgate = get_node("/root/FloodgateController")
	asset_library = get_node("/root/AssetLibrary")
	
	if floodgate:
		debug_print("[WorldBuilder] Connected to FloodgateController", 2)
	else:
		push_error("[WorldBuilder] FloodgateController not found!")
	
	if asset_library:
		debug_print("[WorldBuilder] Connected to AssetLibrary", 2)
	else:
		push_error("[WorldBuilder] AssetLibrary not found!")

## Get mouse world position for spawning
# INPUT: None
# PROCESS: Raycasts from camera through mouse position
# OUTPUT: Vector3 world position
# CHANGES: None
# CONNECTION: Used by all create functions
func get_mouse_spawn_position() -> Vector3:
	# Check if we should use override position
	if use_override_position:
		return override_spawn_position
	
	var camera = get_viewport().get_camera_3d()
	if not camera:
		# Fallback to random position
		return Vector3(
			randf_range(-10, 10),
			spawn_height,
			randf_range(-10, 10)
		)
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 100
	
	var space_state = get_tree().current_scene.get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collision_mask = 1  # Ground layer
	
	var result = space_state.intersect_ray(ray_query)
	if result:
		return result.position + Vector3(0, spawn_height, 0)
	
	# If no ground hit, spawn at camera forward position
	return camera.global_position + camera.global_transform.basis.z * -spawn_distance + Vector3(0, spawn_height, 0)

func create_tree() -> void:
	if not floodgate:
		_fallback_create_tree()
		return
	
	# Use floodgate system to create tree
	var spawn_pos = get_mouse_spawn_position()
	var tree_node = StandardizedObjects.create_object("tree", spawn_pos)
	if tree_node:
		object_counter["tree"] += 1
		var tree_name = "tree_" + str(object_counter["tree"])
		tree_node.name = tree_name
		
		# Queue through floodgate using second_dimensional_magic (node creation)
		floodgate.second_dimensional_magic(0, tree_name, tree_node)
		spawned_objects.append(tree_node)
		
		debug_print("[WorldBuilder] Queued tree creation through floodgate: " + tree_name, 3)

func _fallback_create_tree() -> void:
	# Fallback method if floodgate not available
	var std_objects = _get_std_objects()
	if not std_objects:
		return
	var obj = std_objects.create_object("tree", get_mouse_spawn_position())
	if obj:
		object_counter["tree"] += 1
		get_tree().get_node("/root/FloodgateController").universal_add_child(obj, get_tree().current_scene)
		spawned_objects.append(obj)

func create_rock() -> void:
	if not floodgate:
		_fallback_create_rock()
		return
	
	var spawn_pos = get_mouse_spawn_position()
	var rock_node = StandardizedObjects.create_object("rock", spawn_pos)
	if rock_node:
		object_counter["rock"] += 1
		var rock_name = "rock_" + str(object_counter["rock"])
		rock_node.name = rock_name
		
		floodgate.second_dimensional_magic(0, rock_name, rock_node)
		spawned_objects.append(rock_node)
		debug_print("[WorldBuilder] Queued rock creation through floodgate: " + rock_name, 3)

func create_box() -> void:
	if not floodgate:
		_fallback_create_box()
		return
	
	var spawn_pos = get_mouse_spawn_position()
	var box_node = StandardizedObjects.create_object("box", spawn_pos)
	if box_node:
		object_counter["box"] += 1
		var box_name = "box_" + str(object_counter["box"])
		box_node.name = box_name
		
		floodgate.second_dimensional_magic(0, box_name, box_node)
		spawned_objects.append(box_node)
		debug_print("[WorldBuilder] Queued box creation through floodgate: " + box_name, 3)

func create_ball() -> void:
	if not floodgate:
		_fallback_create_ball()
		return
	
	var spawn_pos = get_mouse_spawn_position()
	var ball_node = StandardizedObjects.create_object("ball", spawn_pos)
	if ball_node:
		object_counter["ball"] += 1
		var ball_name = "ball_" + str(object_counter["ball"])
		ball_node.name = ball_name
		
		floodgate.second_dimensional_magic(0, ball_name, ball_node)
		spawned_objects.append(ball_node)
		debug_print("[WorldBuilder] Queued ball creation through floodgate: " + ball_name, 3)

func create_ramp() -> void:
	if not floodgate:
		_fallback_create_ramp()
		return
	
	var spawn_pos = get_mouse_spawn_position()
	var ramp_node = StandardizedObjects.create_object("ramp", spawn_pos)
	if ramp_node:
		object_counter["ramp"] += 1
		var ramp_name = "ramp_" + str(object_counter["ramp"])
		ramp_node.name = ramp_name
		
		floodgate.second_dimensional_magic(0, ramp_name, ramp_node)
		spawned_objects.append(ramp_node)
		debug_print("[WorldBuilder] Queued ramp creation through floodgate: " + ramp_name, 3)

func create_ragdoll() -> void:
	# Check if a ragdoll already exists
	var existing_ragdolls = get_tree().get_nodes_in_group("ragdolls")
	if not existing_ragdolls.is_empty():
		debug_print("Ragdoll already exists, removing old one", 2)
		for ragdoll in existing_ragdolls:
			ragdoll.queue_free()
	
	var obj = StandardizedObjects.create_object("ragdoll", get_mouse_spawn_position())
	if obj:
		object_counter["ragdoll"] += 1
		get_tree().get_node("/root/FloodgateController").universal_add_child(obj, get_tree().current_scene)
		# Don't add to spawned_objects since we only want one ragdoll

func create_sun() -> void:
	var spawn_pos = get_mouse_spawn_position()
	spawn_pos.y += 15.0  # Sun should be high above the spawn point
	var obj = StandardizedObjects.create_object("sun", spawn_pos)
	if obj:
		object_counter["sun"] += 1
		get_tree().get_node("/root/FloodgateController").universal_add_child(obj, get_tree().current_scene)
		spawned_objects.append(obj)
		# Ensure sun stays in place (no gravity)
		if obj.has_method("set_freeze_enabled"):
			obj.set_freeze_enabled(true)

func create_astral_being() -> void:
	# Use new talking astral being system
	var spawn_pos = get_mouse_spawn_position()
	spawn_pos.y += 2.0  # Spawn floating above ground
	
	var astral_script = load("res://scripts/core/talking_astral_being.gd")
	if astral_script:
		var astral_being = Node3D.new()
		astral_being.set_script(astral_script)
		astral_being.position = spawn_pos
		astral_being.add_to_group("astral_beings")
		astral_being.add_to_group("spawned_objects")
		
		# Assign personality randomly (using enum values)
		var personality_values = [0, 1, 2, 3, 4]  # HELPFUL, CURIOUS, WISE, PLAYFUL, GUARDIAN
		astral_being.personality = personality_values[randi() % personality_values.size()]
		astral_being.being_id = object_counter.get("astral_being", 0) + 1
		
		# Queue through floodgate system
		if floodgate:
			var being_name = "astral_being_" + str(astral_being.being_id)
			floodgate.second_dimensional_magic(0, being_name, astral_being)
			object_counter["astral_being"] = astral_being.being_id
			spawned_objects.append(astral_being)
			debug_print("[WorldBuilder] Queued talking astral being creation: " + being_name, 3)
		else:
			get_tree().get_node("/root/FloodgateController").universal_add_child(astral_being, get_tree().current_scene)
			spawned_objects.append(astral_being)
			debug_print("[WorldBuilder] Created talking astral being directly", 3)
	else:
		print("[WorldBuilder] Failed to load talking astral being script")

func create_pathway() -> void:
	var obj = StandardizedObjects.create_object("pathway", get_mouse_spawn_position())
	if obj:
		object_counter["pathway"] += 1
		get_tree().get_node("/root/FloodgateController").universal_add_child(obj, get_tree().current_scene)
		spawned_objects.append(obj)

func create_bush() -> void:
	var obj = StandardizedObjects.create_object("bush", get_mouse_spawn_position())
	if obj:
		object_counter["bush"] += 1
		get_tree().get_node("/root/FloodgateController").universal_add_child(obj, get_tree().current_scene)
		spawned_objects.append(obj)

func create_fruit() -> void:
	var obj = StandardizedObjects.create_object("fruit", get_mouse_spawn_position())
	if obj:
		object_counter["fruit"] += 1
		get_tree().get_node("/root/FloodgateController").universal_add_child(obj, get_tree().current_scene)
		spawned_objects.append(obj)

func create_pigeon() -> void:
	print("[WorldBuilder] Creating triangular bird character...")
	
	var spawn_pos = get_mouse_spawn_position()
	spawn_pos.y += 1.0  # Spawn above ground
	
	# Try the new triangular walker first
	var bird_script = load("res://scripts/core/triangular_bird_walker.gd")
	if not bird_script:
		# Fallback to original pigeon
		bird_script = load("res://scripts/core/pigeon_physics_controller.gd")
		
	if bird_script:
		var bird = RigidBody3D.new()
		bird.set_script(bird_script)
		bird.position = spawn_pos
		bird.add_to_group("birds")
		bird.add_to_group("spawned_objects")
		
		# Give it a unique name
		object_counter["pigeon"] = object_counter.get("pigeon", 0) + 1
		bird.name = "bird_" + str(object_counter["pigeon"])
		
		# Add AI behavior
		var ai_script = load("res://scripts/core/bird_ai_behavior.gd")
		if ai_script:
			var ai = Node.new()
			ai.name = "AI"
			ai.set_script(ai_script)
			FloodgateController.universal_add_child(ai, bird)
			ai.setup(bird)
			
		# Add through floodgate
		if floodgate:
			floodgate.second_dimensional_magic(0, bird.name, bird)
			spawned_objects.append(bird)
			print("[WorldBuilder] Queued triangular bird creation with AI: " + bird.name)
		else:
			get_tree().get_node("/root/FloodgateController").universal_add_child(bird, get_tree().current_scene)
			spawned_objects.append(bird)
			print("[WorldBuilder] Created triangular bird with AI directly")
	else:
		print("[WorldBuilder] Failed to load bird scripts")

func clear_all_objects() -> int:
	var count = spawned_objects.size()
	
	if floodgate:
		# Use floodgate system for safe deletion
		for obj in spawned_objects:
			if is_instance_valid(obj):
				floodgate.fifth_dimensional_magic("just_node", obj.get_path())
	else:
		# Fallback to direct deletion
		for obj in spawned_objects:
			if is_instance_valid(obj):
				obj.queue_free()
	
	spawned_objects.clear()
	
	# Reset counters
	for key in object_counter:
		object_counter[key] = 0
	
	print("[WorldBuilder] Queued " + str(count) + " objects for deletion through floodgate")
	return count

func get_spawned_objects() -> Array[Node3D]:
	# Clean up invalid references
	spawned_objects = spawned_objects.filter(func(obj): return is_instance_valid(obj))
	return spawned_objects

# Register objects created by other systems (like world generation)
func register_world_object(obj: Node3D) -> void:
	if obj and is_instance_valid(obj):
		spawned_objects.append(obj)
		debug_print("[WorldBuilder] Registered world object: " + obj.name, 3)

func delete_object(object_name: String) -> bool:
	for obj in spawned_objects:
		if is_instance_valid(obj) and obj.name == object_name:
			if floodgate:
				# Use floodgate system for safe deletion
				floodgate.fifth_dimensional_magic("just_node", obj.get_path())
				print("[WorldBuilder] Queued object deletion through floodgate: " + object_name)
			else:
				# Fallback to direct deletion
				obj.queue_free()
				print("[WorldBuilder] Direct deletion: " + object_name)
			
			spawned_objects.erase(obj)
			return true
	
	print("[WorldBuilder] Object not found for deletion: " + object_name)
	return false

# ----- FALLBACK METHODS -----
func _fallback_create_rock() -> void:
	var obj = StandardizedObjects.create_object("rock", get_mouse_spawn_position())
	if obj:
		object_counter["rock"] += 1
		get_tree().get_node("/root/FloodgateController").universal_add_child(obj, get_tree().current_scene)
		spawned_objects.append(obj)

func _fallback_create_box() -> void:
	var obj = StandardizedObjects.create_object("box", get_mouse_spawn_position())
	if obj:
		object_counter["box"] += 1
		get_tree().get_node("/root/FloodgateController").universal_add_child(obj, get_tree().current_scene)
		spawned_objects.append(obj)

func _fallback_create_ball() -> void:
	var obj = StandardizedObjects.create_object("ball", get_mouse_spawn_position())
	if obj:
		object_counter["ball"] += 1
		get_tree().get_node("/root/FloodgateController").universal_add_child(obj, get_tree().current_scene)
		spawned_objects.append(obj)

func _fallback_create_ramp() -> void:
	var obj = StandardizedObjects.create_object("ramp", get_mouse_spawn_position())
	if obj:
		object_counter["ramp"] += 1
		get_tree().get_node("/root/FloodgateController").universal_add_child(obj, get_tree().current_scene)
		spawned_objects.append(obj)

## Generic object creation for any type
# INPUT: object_type - String name of object to create
# PROCESS: Routes through floodgate or creates directly
# OUTPUT: None (object added to world)
# CHANGES: Increments object counter, adds to spawned list
# CONNECTION: Used by console commands for new asset types
func create_object(object_type: String) -> void:
	# Try to use UniversalObjectManager first (the perfect way)
	var uom = get_node_or_null("/root/UniversalObjectManager")
	if uom and uom.has_method("create_object"):
		var uom_spawn_pos = get_mouse_spawn_position()
		var uom_obj_node = uom.create_object(object_type, uom_spawn_pos)
		if uom_obj_node:
			if object_type in object_counter:
				object_counter[object_type] += 1
			else:
				object_counter[object_type] = 1
			spawned_objects.append(uom_obj_node)
			debug_print("[WorldBuilder] Created %s through UniversalObjectManager" % [object_type], 3)
		return
	
	# Fallback to floodgate system
	if not floodgate:
		_fallback_create_object(object_type)
		return
	
	# Use floodgate system to create object
	var spawn_pos = get_mouse_spawn_position()
	var std_objects = get_node_or_null("/root/StandardizedObjects")
	if not std_objects:
		_fallback_create_object(object_type)
		return
	var obj_node = std_objects.create_object(object_type, spawn_pos)
	if obj_node:
		if object_type in object_counter:
			object_counter[object_type] += 1
		else:
			object_counter[object_type] = 1
		var obj_name = "%s_%d" % [object_type, object_counter[object_type]]
		obj_node.name = obj_name
		
		# Queue through floodgate using second_dimensional_magic (node creation)
		floodgate.second_dimensional_magic(0, obj_name, obj_node)
		spawned_objects.append(obj_node)
		
		# Object is already tracked by floodgate and StandardizedObjects
		# Add to groups for easy listing
		obj_node.add_to_group("spawned_objects")
		obj_node.add_to_group(object_type + "s")
		
		debug_print("[WorldBuilder] Queued %s creation through floodgate: %s" % [object_type, obj_name], 3)
	
func _fallback_create_object(object_type: String) -> void:
	var std_objects = get_node_or_null("/root/StandardizedObjects")
	if not std_objects:
		debug_print("[WorldBuilder] StandardizedObjects autoload not found!", 1)
		return
	var obj = std_objects.create_object(object_type, get_mouse_spawn_position())
	if obj:
		if object_type in object_counter:
			object_counter[object_type] += 1
		else:
			object_counter[object_type] = 1
		get_tree().get_node("/root/FloodgateController").universal_add_child(obj, get_tree().current_scene)
		spawned_objects.append(obj)
