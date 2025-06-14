# ==================================================
# SCRIPT NAME: physics_state_manager.gd
# DESCRIPTION: State-based physics control for light beings and objects
# CREATED: 2025-05-23 - Dynamic state transitions
# ==================================================

extends UniversalBeingBase
# Physics states for light beings and objects
enum PhysicsState {
	STATIC,          # No physics, no movement - scene anchor state
	AWAKENING,       # Transition from static to moving
	KINEMATIC,       # Controlled movement, no physics
	DYNAMIC,         # Full physics simulation
	ETHEREAL,        # Light being state - can pass through objects
	CONNECTED,       # Connected to another object
	TRANSFORMING,    # Changing between states
	LIGHT_BEING,     # Special state for light entities
	SCENE_ANCHORED   # Locked to scene zero point
}

# Scene reference point (0,0,0)
var scene_zero_point: Vector3 = Vector3.ZERO
var gravity_center: Vector3 = Vector3.ZERO
var gravity_strength: float = 9.8

# State tracking
var object_states: Dictionary = {}
var state_change_queue: Array = []
var transition_duration: float = 1.0

# Player reference
var player_object: Node3D = null
var player_state: PhysicsState = PhysicsState.DYNAMIC

# Signals
signal state_changed(object: Node3D, old_state: PhysicsState, new_state: PhysicsState)
signal gravity_modified(new_center: Vector3, new_strength: float)

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	set_physics_process(true)


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	# Process state transitions
	_process_state_transitions(delta)
	
	# Apply custom gravity rules
	_apply_custom_physics(delta)


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

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
func set_object_state(object: Node3D, new_state: PhysicsState, force: bool = false) -> bool:
	if not object:
		return false
	
	var current_state = get_object_state(object)
	if current_state == new_state and not force:
		return true
	
	# Check if transition is allowed
	if not _can_transition(current_state, new_state):
		print("Cannot transition from " + _state_to_string(current_state) + " to " + _state_to_string(new_state))
		return false
	
	# Queue transition
	state_change_queue.append({
		"object": object,
		"from_state": current_state,
		"to_state": new_state,
		"progress": 0.0,
		"start_time": Time.get_ticks_msec() / 1000.0
	})
	
	# Update tracking
	object_states[object] = new_state
	
	print("Queued state change for " + object.name + ": " + _state_to_string(current_state) + " → " + _state_to_string(new_state))
	return true

func get_object_state(object: Node3D) -> PhysicsState:
	return object_states.get(object, PhysicsState.STATIC)

func _can_transition(from_state: PhysicsState, to_state: PhysicsState) -> bool:
	# Light beings must awaken before moving
	match from_state:
		PhysicsState.STATIC:
			return to_state in [PhysicsState.AWAKENING, PhysicsState.SCENE_ANCHORED]
		PhysicsState.AWAKENING:
			return to_state in [PhysicsState.KINEMATIC, PhysicsState.LIGHT_BEING, PhysicsState.ETHEREAL, PhysicsState.STATIC]
		PhysicsState.KINEMATIC:
			return to_state in [PhysicsState.STATIC, PhysicsState.DYNAMIC, PhysicsState.ETHEREAL, PhysicsState.CONNECTED, PhysicsState.LIGHT_BEING]
		PhysicsState.DYNAMIC:
			return to_state in [PhysicsState.STATIC, PhysicsState.KINEMATIC, PhysicsState.ETHEREAL, PhysicsState.CONNECTED]
		PhysicsState.ETHEREAL:
			return to_state in [PhysicsState.LIGHT_BEING, PhysicsState.KINEMATIC, PhysicsState.DYNAMIC, PhysicsState.STATIC]
		PhysicsState.LIGHT_BEING:
			return to_state in [PhysicsState.ETHEREAL, PhysicsState.TRANSFORMING, PhysicsState.STATIC]
		PhysicsState.CONNECTED:
			return to_state in [PhysicsState.KINEMATIC, PhysicsState.DYNAMIC, PhysicsState.STATIC]
		PhysicsState.TRANSFORMING:
			return false  # Must complete transformation first
		PhysicsState.SCENE_ANCHORED:
			return to_state in [PhysicsState.STATIC, PhysicsState.AWAKENING]
	
	return false

func _process_state_transitions(delta: float) -> void:
	var completed_transitions = []
	
	for i in range(state_change_queue.size()):
		var transition = state_change_queue[i]
		transition["progress"] += delta / transition_duration
		
		if transition["progress"] >= 1.0:
			# Complete transition
			_complete_state_transition(transition)
			completed_transitions.append(i)
		else:
			# Update transition
			_update_state_transition(transition, delta)
	
	# Remove completed transitions (reverse order to maintain indices)
	for i in range(completed_transitions.size() - 1, -1, -1):
		state_change_queue.remove_at(completed_transitions[i])

func _complete_state_transition(transition: Dictionary) -> void:
	var object = transition["object"]
	var to_state = transition["to_state"]
	var from_state = transition["from_state"]
	
	if not is_instance_valid(object):
		return
	
	# Apply final state
	_apply_physics_state(object, to_state)
	
	emit_signal("state_changed", object, from_state, to_state)
	print("Completed state transition for " + object.name + " to " + _state_to_string(to_state))

func _update_state_transition(transition: Dictionary, _delta: float) -> void:
	var object = transition["object"]
	var progress = transition["progress"]
	
	if not is_instance_valid(object):
		return
	
	# Visual feedback during transition
	if object.has_method("set_modulate"):
		var alpha = 0.5 + 0.5 * sin(progress * PI * 4)  # Blinking effect
		object.modulate.a = alpha
	
	# Partial physics application
	_apply_transition_physics(object, transition, progress)

func _apply_physics_state(object: Node3D, state: PhysicsState) -> void:
	match state:
		PhysicsState.STATIC:
			_make_static(object)
		PhysicsState.KINEMATIC:
			_make_kinematic(object)
		PhysicsState.DYNAMIC:
			_make_dynamic(object)
		PhysicsState.ETHEREAL:
			_make_ethereal(object)
		PhysicsState.CONNECTED:
			_make_connected(object)

func _make_static(object: Node3D) -> void:
	if object is RigidBody3D:
		object.freeze = true
		object.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	elif object is CharacterBody3D:
		object.set_physics_process(false)
	
	# Disable collision for non-physical objects
	_set_collision_enabled(object, false)

func _make_kinematic(object: Node3D) -> void:
	if object is RigidBody3D:
		object.freeze = false
		object.freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
	elif object is CharacterBody3D:
		object.set_physics_process(true)
	
	_set_collision_enabled(object, true)

func _make_dynamic(object: Node3D) -> void:
	if object is RigidBody3D:
		object.freeze = false
		object.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC  # Default physics
	elif object is CharacterBody3D:
		object.set_physics_process(true)
	
	_set_collision_enabled(object, true)

func _make_ethereal(object: Node3D) -> void:
	# Can pass through other objects
	_set_collision_enabled(object, false)
	
	if object is RigidBody3D:
		object.freeze = false
		object.gravity_scale = 0.0  # No gravity
	
	# Visual effect
	if object.has_method("set_modulate"):
		object.modulate.a = 0.7

func _make_connected(object: Node3D) -> void:
	# Object follows another object
	_make_kinematic(object)

func _set_collision_enabled(object: Node3D, enabled: bool) -> void:
	# Find all collision shapes
	var collision_shapes = _find_collision_shapes(object)
	for shape in collision_shapes:
		shape.disabled = not enabled

func _find_collision_shapes(node: Node) -> Array:
	var shapes = []
	
	if node is CollisionShape3D:
		shapes.append(node)
	
	for child in node.get_children():
		shapes.append_array(_find_collision_shapes(child))
	
	return shapes

func _apply_transition_physics(object: Node3D, transition: Dictionary, progress: float) -> void:
	var from_state = transition["from_state"]
	var to_state = transition["to_state"]
	
	# Interpolate between states
	if from_state == PhysicsState.STATIC and to_state == PhysicsState.DYNAMIC:
		# Gradually enable physics
		if object is RigidBody3D and progress > 0.5:
			object.freeze = false

func _apply_custom_physics(delta: float) -> void:
	# Apply custom gravity rules based on scene zero point
	for obj in object_states:
		if not is_instance_valid(obj):
			continue
		
		var state = object_states[obj]
		if state == PhysicsState.DYNAMIC and obj is RigidBody3D:
			_apply_custom_gravity(obj, delta)

func _apply_custom_gravity(object: RigidBody3D, _delta: float) -> void:
	# Calculate gravity relative to scene zero point or gravity center
	var gravity_direction = (gravity_center - object.global_position).normalized()
	var distance = gravity_center.distance_to(object.global_position)
	
	# Distance-based gravity (closer = stronger)
	var gravity_force = gravity_direction * gravity_strength
	if distance > 0:
		gravity_force *= max(0.1, 1.0 / (distance * 0.1 + 1.0))
	
	object.apply_central_force(gravity_force * object.mass)

# Astral being specific functions
func prepare_object_for_manipulation(object: Node3D, _astral_being: Node3D) -> bool:
	var current_state = get_object_state(object)
	
	if current_state == PhysicsState.STATIC:
		# Astral being must first change object to kinematic
		print("Astral being preparing object for manipulation...")
		return set_object_state(object, PhysicsState.KINEMATIC)
	
	return true

func astral_being_manipulate(astral_being: Node3D, target_object: Node3D, force: Vector3) -> bool:
	if not prepare_object_for_manipulation(target_object, astral_being):
		return false
	
	var state = get_object_state(target_object)
	
	match state:
		PhysicsState.KINEMATIC:
			# Move object kinematically
			if target_object is RigidBody3D:
				target_object.global_position += force * get_physics_process_delta_time()
			return true
		PhysicsState.DYNAMIC:
			# Apply force to object
			if target_object is RigidBody3D:
				target_object.apply_central_force(force)
			return true
		_:
			return false

# Public API
func set_scene_zero_point(point: Vector3) -> void:
	scene_zero_point = point
	gravity_center = point

func set_gravity_center(center: Vector3, strength: float = 9.8) -> void:
	gravity_center = center
	gravity_strength = strength
	emit_signal("gravity_modified", center, strength)

func set_player_reference(player: Node3D) -> void:
	player_object = player
	if player:
		set_object_state(player, PhysicsState.DYNAMIC)

func get_objects_in_state(state: PhysicsState) -> Array:
	var result = []
	for obj in object_states:
		if is_instance_valid(obj) and object_states[obj] == state:
			result.append(obj)
	return result

func _state_to_string(state: PhysicsState) -> String:
	match state:
		PhysicsState.STATIC: return "STATIC"
		PhysicsState.KINEMATIC: return "KINEMATIC"
		PhysicsState.DYNAMIC: return "DYNAMIC"
		PhysicsState.ETHEREAL: return "ETHEREAL"
		PhysicsState.CONNECTED: return "CONNECTED"
		PhysicsState.TRANSFORMING: return "TRANSFORMING"
		_: return "UNKNOWN"

func get_state_info() -> Dictionary:
	var info = {
		"scene_zero_point": scene_zero_point,
		"gravity_center": gravity_center,
		"gravity_strength": gravity_strength,
		"total_objects": object_states.size(),
		"state_counts": {}
	}
	
	# Count objects in each state
	for state in PhysicsState.values():
		info["state_counts"][_state_to_string(state)] = get_objects_in_state(state).size()
	
	return info