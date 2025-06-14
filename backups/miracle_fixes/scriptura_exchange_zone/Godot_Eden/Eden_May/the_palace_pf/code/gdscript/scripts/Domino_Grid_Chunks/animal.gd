# animal.gd
extends Entity

# Animal-specific properties
var species: String
var speed: float
var perception_range: int
var diet_type: String  # "herbivore", "carnivore", "omnivore"
var preferred_food: Array
var reproduction_energy_threshold: float
var memory: Dictionary = {}  # For storing locations of interest, etc.

func _ready():
	entity_type = "animal"
	initialize_genetics()
	initialize_state_machine()

func initialize_genetics():
	if genetics.is_empty():
		genetics = {
			"speed": randf_range(0.8, 1.2),
			"perception": randf_range(0.9, 1.1),
			"metabolic_rate": randf_range(0.8, 1.2),
			"size": randf_range(0.7, 1.3),
			"aggression": randf_range(0.5, 1.5)
		}
	
	# Apply genetics
	speed = 2.0 * genetics.speed
	perception_range = int(5.0 * genetics.perception)
	energy = 100.0 * genetics.size
	
	# Visual representation
	scale = Vector2(genetics.size, genetics.size)

var AnimalStateMachine

func initialize_state_machine():
	# Complex state machine for animal behavior
	state_machine = AnimalStateMachine.new(self)
	add_child(state_machine)

func get_base_energy_consumption() -> float:
	# Animals consume energy based on size and metabolism
	return 0.5 * genetics.size * genetics.metabolic_rate

func perceive_environment():
	# Scan surroundings within perception range
	var world = get_node("/root/World")
	var perceived_entities = []
	
	for dx in range(-perception_range, perception_range + 1):
		for dy in range(-perception_range, perception_range + 1):
			var nx = position.x + dx
			var ny = position.y + dy
			
			if world.is_valid_cell(nx, ny):
				var entities = world.get_entities_at(nx, ny)
				for entity in entities:
					# Calculate actual perception chance based on distance
					var distance = sqrt(dx*dx + dy*dy)
					var perception_chance = 1.0 - (distance / perception_range)
					
					if randf() < perception_chance:
						perceived_entities.append({
							"entity": entity,
							"position": Vector2i(nx, ny),
							"distance": distance
						})
	
	return perceived_entities

func find_closest_food():
	var perceived = perceive_environment()
	var potential_food = []
	
	# Filter for edible entities based on diet
	for item in perceived:
		if is_entity_edible(item.entity):
			potential_food.append(item)
	
	# Find closest
	if potential_food.size() > 0:
		potential_food.sort_custom(func(a, b): return a.distance < b.distance)
		return potential_food[0]
	
	return null

func is_entity_edible(entity) -> bool:
	match diet_type:
		"herbivore":
			return entity.entity_type == "plant" and entity.growth_stage > 0
		"carnivore":
			return entity.entity_type == "animal" and entity != self
		"omnivore":
			return (entity.entity_type == "plant" and entity.growth_stage > 0) or \
				   (entity.entity_type == "animal" and entity != self)
	
	return false

func move_toward(target_pos: Vector2i):
	var world = get_node("/root/World")
	
	# Simple A* pathfinding to target
	var path = world.find_path(position, target_pos)
	
	if path.size() > 1:
		# Move along path (respecting speed)
		var next_pos = path[1]  # First point is current position
		move_to(next_pos)
		return true
	
	return false

func eat(target_entity):
	if not is_entity_edible(target_entity):
		return false
	
	# Different energy gain based on what's eaten
	var energy_gain = 0.0
	
	if target_entity.entity_type == "plant":
		energy_gain = 10.0 * target_entity.growth_stage
		# Plants lose growth stage when partially eaten
		target_entity.growth_stage = max(0, target_entity.growth_stage - 1)
	elif target_entity.entity_type == "animal":
		energy_gain = 25.0 * target_entity.genetics.size
		# Animals take damage when attacked
		target_entity.health -= 30.0
	
	energy += energy_gain
	return true

func reproduce():
	# Check if enough energy
	if energy < reproduction_energy_threshold:
		return false
	
	var world = get_node("/root/World")
	
	# Find open adjacent cell
	var adjacent_cells = []
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			
			var nx = position.x + dx
			var ny = position.y + dy
			
			if world.is_valid_cell(nx, ny) and world.get_entities_at(nx, ny).size() == 0:
				adjacent_cells.append(Vector2i(nx, ny))
	
	if adjacent_cells.size() == 0:
		return false  # No space for offspring
	
	# Select random adjacent cell
	var offspring_pos = adjacent_cells[randi() % adjacent_cells.size()]
	
	# Create offspring with mutations
	var offspring = self.duplicate()
	offspring.position = offspring_pos
	offspring.age = 0
	offspring.energy = energy * 0.3  # Transfer some energy
	
	# Reduce parent's energy
	energy *= 0.6  # Parent loses more than given to offspring (cost of reproduction)
	
	# Apply mutations
	for key in offspring.genetics.keys():
		offspring.genetics[key] *= randf_range(0.95, 1.05)  # 5% mutation
	
	# Add to world
	world.add_entity(offspring, offspring_pos.x, offspring_pos.y)
	return true
