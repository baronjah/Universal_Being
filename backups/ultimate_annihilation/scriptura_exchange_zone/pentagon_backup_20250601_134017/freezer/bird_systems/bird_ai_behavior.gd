# ==================================================
# SCRIPT NAME: bird_ai_behavior.gd
# DESCRIPTION: Simple AI for birds to walk and find food
# PURPOSE: Make birds autonomously explore and eat
# CREATED: 2025-05-24 - Bird AI behaviors
# ==================================================

extends UniversalBeingBase
# ================================
# AI STATES
# ================================

enum AIState {
	WANDERING,
	SEEKING_FOOD,
	EATING,
	SEEKING_WATER,
	DRINKING,
	RESTING
}

# ================================
# PROPERTIES
# ================================

var bird_body: RigidBody3D
var current_state: AIState = AIState.WANDERING
var target_object: Node3D = null
var hunger: float = 50.0
var thirst: float = 50.0
var energy: float = 100.0

# Behavior parameters
var wander_radius: float = 10.0
var food_detection_range: float = 5.0
var eating_distance: float = 1.0
var walk_speed: float = 3.0

# Timers
var state_timer: float = 0.0
var action_timer: float = 0.0

# ================================
# INITIALIZATION
# ================================


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
func setup(bird: RigidBody3D) -> void:
	bird_body = bird
	set_physics_process(true)

# ================================
# PHYSICS PROCESS
# ================================

func _physics_process(delta: float) -> void:
	if not bird_body:
		return
	
	# Update needs
	hunger = max(0, hunger - delta * 2.0)  # Get hungry over time
	thirst = max(0, thirst - delta * 1.5)  # Get thirsty over time
	energy = min(100, energy + delta * 5.0)  # Restore energy when resting
	
	# Update timers
	state_timer += delta
	action_timer += delta
	
	# Process current state
	match current_state:
		AIState.WANDERING:
			_process_wandering(delta)
		AIState.SEEKING_FOOD:
			_process_seeking_food(delta)
		AIState.EATING:
			_process_eating(delta)
		AIState.SEEKING_WATER:
			_process_seeking_water(delta)
		AIState.DRINKING:
			_process_drinking(delta)
		AIState.RESTING:
			_process_resting(delta)
	
	# Check for state transitions
	_check_state_transitions()

# ================================
# STATE BEHAVIORS
# ================================

func _process_wandering(_delta: float) -> void:
	# Random walk pattern
	if action_timer > 3.0:
		action_timer = 0.0
		
		# Pick random direction
		var angle = randf() * TAU
		var distance = randf_range(2.0, wander_radius)
		var target = bird_body.global_position + Vector3(
			cos(angle) * distance,
			0,
			sin(angle) * distance
		)
		
		# Start walking toward target
		if bird_body.has_method("target_position"):
			bird_body.target_position = target
			bird_body.has_target = true
			bird_body.current_state = 1  # WALKING
	
	# Look for food while wandering
	var nearby_food = _find_nearby_food()
	if nearby_food:
		target_object = nearby_food
		_change_state(AIState.SEEKING_FOOD)

func _process_seeking_food(_delta: float) -> void:
	if not target_object or not is_instance_valid(target_object):
		_change_state(AIState.WANDERING)
		return
	
	# Move toward food
	if bird_body.has_method("target_position"):
		bird_body.target_position = target_object.global_position
		bird_body.has_target = true
		bird_body.current_state = 1  # WALKING
	
	# Check if close enough to eat
	var distance = bird_body.global_position.distance_to(target_object.global_position)
	if distance < eating_distance:
		_change_state(AIState.EATING)

func _process_eating(_delta: float) -> void:
	if not target_object or not is_instance_valid(target_object):
		_change_state(AIState.WANDERING)
		return
	
	# Eating animation (pecking)
	if action_timer > 0.5:
		action_timer = 0.0
		
		# Restore hunger
		hunger = min(100, hunger + 20)
		
		# Remove fruit if fully eaten
		if randf() < 0.3:  # 30% chance per peck
			if target_object.has_method("queue_free"):
				target_object.queue_free()
			target_object = null
			_change_state(AIState.WANDERING)

func _process_seeking_water(_delta: float) -> void:
	if not target_object or not is_instance_valid(target_object):
		# Look for water
		var water = _find_nearby_water()
		if water:
			target_object = water
		else:
			_change_state(AIState.WANDERING)
			return
	
	# Move toward water
	if bird_body.has_method("target_position"):
		bird_body.target_position = target_object.global_position
		bird_body.has_target = true
		bird_body.current_state = 1  # WALKING
	
	# Check if close enough to drink
	var distance = bird_body.global_position.distance_to(target_object.global_position)
	if distance < eating_distance * 2:  # Water pools are bigger
		_change_state(AIState.DRINKING)

func _process_drinking(_delta: float) -> void:
	# Drinking animation
	if action_timer > 0.7:
		action_timer = 0.0
		
		# Restore thirst
		thirst = min(100, thirst + 15)
		
		# Stop drinking when satisfied
		if thirst > 80:
			_change_state(AIState.WANDERING)

func _process_resting(_delta: float) -> void:
	# Just rest and restore energy
	if energy > 90 or state_timer > 5.0:
		_change_state(AIState.WANDERING)

# ================================
# STATE MANAGEMENT
# ================================

func _check_state_transitions() -> void:
	# Priority-based state transitions
	
	# Critical needs
	if hunger < 20 and current_state != AIState.EATING:
		var food = _find_nearby_food()
		if food:
			target_object = food
			_change_state(AIState.SEEKING_FOOD)
	
	if thirst < 20 and current_state != AIState.DRINKING:
		var water = _find_nearby_water()
		if water:
			target_object = water
			_change_state(AIState.SEEKING_WATER)
	
	# Low energy
	if energy < 20 and current_state == AIState.WANDERING:
		_change_state(AIState.RESTING)

func _change_state(new_state: AIState) -> void:
	current_state = new_state
	state_timer = 0.0
	action_timer = 0.0
	
	# Update bird visual state if possible
	if bird_body.has_method("set_ai_state"):
		bird_body.set_ai_state(current_state)

# ================================
# DETECTION FUNCTIONS
# ================================

func _find_nearby_food() -> Node3D:
	var foods = get_tree().get_nodes_in_group("food")
	var closest_food: Node3D = null
	var closest_distance: float = food_detection_range
	
	for food in foods:
		if not is_instance_valid(food):
			continue
			
		var distance = bird_body.global_position.distance_to(food.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_food = food
	
	return closest_food

func _find_nearby_water() -> Node3D:
	var waters = get_tree().get_nodes_in_group("water")
	var closest_water: Node3D = null
	var closest_distance: float = food_detection_range * 2  # Detect water from farther
	
	for water in waters:
		if not is_instance_valid(water):
			continue
			
		var distance = bird_body.global_position.distance_to(water.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_water = water
	
	return closest_water

# ================================
# PUBLIC METHODS
# ================================

func get_status() -> Dictionary:
	return {
		"state": AIState.keys()[current_state],
		"hunger": hunger,
		"thirst": thirst,
		"energy": energy,
		"has_target": target_object != null
	}

func feed() -> void:
	hunger = 100.0

func give_water() -> void:
	thirst = 100.0