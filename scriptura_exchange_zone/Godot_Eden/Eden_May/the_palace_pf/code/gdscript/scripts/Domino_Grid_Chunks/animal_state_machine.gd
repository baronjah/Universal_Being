# AnimalStateMachine.gd
extends StateMachine

class_name AnimalStateMachine

# was _init, but its godot function
func initialize(parent_entity):
	# Add states
	add_state("idle", IdleState.new())
	add_state("wander", WanderState.new())
	add_state("seek_food", SeekFoodState.new())
	# had to delete self from input of the functions
	# here i commented out functions that were not yet in scriptures, we will continue the work and change these lines, so they are un commented :)
	#add_state("eat", EatState.new())
	#add_state("seek_mate", SeekMateState.new(self))
	#add_state("flee", FleeState.new(self))
	#add_state("reproduce", ReproduceState.new(self))
	
	# Start in idle state
	change_state("idle")

# Base State Class
class BaseState:
	var state_machine
	
	func initialize(sm):
		state_machine = sm
	
	func enter():
		pass
	
	func exit():
		pass
	
	func update(delta: float):
		pass

# Idle State
class IdleState extends BaseState:
	var idle_timer = 0.0
	var idle_duration = 0.0
	
	func enter():
		idle_timer = 0.0
		idle_duration = randf_range(1.0, 3.0)
	
	func update(delta: float):
		idle_timer += delta
		
		var animal = state_machine.parent
		
		# Check for threats first (highest priority)
		var perceived = animal.perceive_environment()
		
		for item in perceived:
			if item.entity.entity_type == "animal" and item.entity.is_predator(animal):
				state_machine.change_state("flee")
				return
		
		# Check hunger
		if animal.energy < 70.0:
			state_machine.change_state("seek_food")
			return
		
		# Check reproduction
		if animal.energy > animal.reproduction_energy_threshold:
			state_machine.change_state("seek_mate")
			return
		
		# Transition to wander after idle period
		if idle_timer >= idle_duration:
			state_machine.change_state("wander")

# Wander State
class WanderState extends BaseState:
	var move_timer = 0.0
	var move_interval = 0.5
	var wander_duration = 0.0
	var wander_timer = 0.0
	
	func enter():
		wander_timer = 0.0
		wander_duration = randf_range(5.0, 10.0)
	
	func update(delta: float):
		var animal = state_machine.parent
		
		# Check for threats first (highest priority)
		var perceived = animal.perceive_environment()
		
		for item in perceived:
			if item.entity.entity_type == "animal" and item.entity.is_predator(animal):
				state_machine.change_state("flee")
				return
		
		# Check hunger
		if animal.energy < 50.0:
			state_machine.change_state("seek_food")
			return
		
		# Random movement
		move_timer += delta
		if move_timer >= move_interval:
			move_timer = 0.0
			
			# Choose random direction
			var directions = [
				Vector2i(1, 0), Vector2i(-1, 0),
				Vector2i(0, 1), Vector2i(0, -1),
				Vector2i(1, 1), Vector2i(-1, -1),
				Vector2i(1, -1), Vector2i(-1, 1)
			]
			
			var dir = directions[randi() % directions.size()]
			var new_pos = Vector2i(animal.position.x + dir.x, animal.position.y + dir.y)
			
			var world = animal.get_node("/root/World")
			if world.is_valid_move(animal, new_pos.x, new_pos.y):
				animal.move_to(new_pos)
		
		# Update timer
		wander_timer += delta
		if wander_timer >= wander_duration:
			state_machine.change_state("idle")

# Seek Food State
class SeekFoodState extends BaseState:
	var target_food = null
	var path_refresh_timer = 0.0
	var path_refresh_interval = 1.0
	
	func enter():
		path_refresh_timer = 0.0
		find_food()
	
	func update(delta: float):
		var animal = state_machine.parent
		
		# Check for threats first (highest priority)
		var perceived = animal.perceive_environment()
		
		for item in perceived:
			if item.entity.entity_type == "animal" and item.entity.is_predator(animal):
				state_machine.change_state("flee")
				return
		
		path_refresh_timer += delta
		
		# If no food target or regular refresh
		if target_food == null or path_refresh_timer >= path_refresh_interval:
			path_refresh_timer = 0.0
			find_food()
			
			if target_food == null:
				# No food found, go back to wandering
				state_machine.change_state("wander")
				return
		
		# Check if we're adjacent to food
		if target_food != null:
			var dx = abs(animal.position.x - target_food.position.x)
			var dy = abs(animal.position.y - target_food.position.y)
			
			if dx <= 1 and dy <= 1:
				# Adjacent to food, switch to eat state
				state_machine.change_state("eat")
				return
			
			# Move toward food
			animal.move_toward(target_food.position)
	
	func find_food():
		var animal = state_machine.parent
		var food_data = animal.find_closest_food()
		
		if food_data != null:
			target_food = food_data.entity
		else:
			target_food = null

# Additional states would be implemented similarly...
