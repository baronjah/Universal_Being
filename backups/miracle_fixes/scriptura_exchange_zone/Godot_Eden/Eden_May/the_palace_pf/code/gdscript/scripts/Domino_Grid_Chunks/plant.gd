# Plant.gd
extends Entity

var growth_stage: int = 0
var max_growth_stage: int = 3
var growth_speed: float
var seed_production_rate: float
var seed_dispersal_range: float
var water_requirement: float
var sunlight_requirement: float

func _ready():
	entity_type = "plant"
	initialize_genetics()
	initialize_state_machine()

func initialize_genetics():
	# Either load from parent or generate new random genetics
	if genetics.is_empty():
		genetics = {
			"growth_speed": randf_range(0.8, 1.2),
			"seed_production": randf_range(0.7, 1.3),
			"seed_range": randf_range(0.9, 1.1),
			"water_need": randf_range(0.8, 1.2),
			"sun_need": randf_range(0.8, 1.2)
		}
	
	# Apply genetics to actual properties
	growth_speed = 0.1 * genetics.growth_speed
	seed_production_rate = 0.05 * genetics.seed_production
	seed_dispersal_range = 3.0 * genetics.seed_range
	water_requirement = 0.2 * genetics.water_need
	sunlight_requirement = 0.3 * genetics.sun_need

#class PlantStateMachine():
#	func new():

var PlantStateMachine

func initialize_state_machine():
	state_machine = PlantStateMachine.new(self)
	add_child(state_machine)

func _process(delta):
	super._process(delta)
	
	# Plant-specific processes
	var world = get_node("/root/World")
	var cell_moisture = world.moisture_layer[position.x][position.y]
	var cell_sunlight = world.sunlight_layer[position.x][position.y]
	
	# Growth based on environmental conditions
	var growth_factor = min(cell_moisture / water_requirement, cell_sunlight / sunlight_requirement)
	
	if growth_factor >= 0.8:
		grow(delta * growth_speed * growth_factor)
	elif growth_factor < 0.4:
		# Plant is struggling
		health -= delta * (0.4 - growth_factor) * 10.0

func grow(amount: float):
	growth_stage = min(growth_stage + amount, max_growth_stage)
	
	# Visual updates based on growth stage
	update_appearance()
	
	# Once mature, can reproduce
	if growth_stage >= max_growth_stage:
		if randf() < seed_production_rate:
			disperse_seeds()

func disperse_seeds():
	var world = get_node("/root/World")
	
	# Try to spawn 1-3 seeds
	var seed_count = 1 + randi() % 3
	
	for i in range(seed_count):
		# Random direction
		var angle = randf() * 2.0 * PI
		var distance = randf() * seed_dispersal_range
		
		var seed_pos = Vector2i(
			position.x + int(cos(angle) * distance),
			position.y + int(sin(angle) * distance)
		)
		
		# Check if position is valid and can support plant
		if world.is_valid_cell(seed_pos.x, seed_pos.y) and world.can_support_plant(seed_pos.x, seed_pos.y):
			# Create a slightly mutated offspring
			var offspring = self.duplicate()
			offspring.position = seed_pos
			offspring.growth_stage = 0
			offspring.age = 0
			
			# Apply slight mutations
			for key in offspring.genetics.keys():
				offspring.genetics[key] *= randf_range(0.95, 1.05)  # 5% mutation range
			
			# Add to world
			world.add_entity(offspring, seed_pos.x, seed_pos.y)

func update_appearance():
	# Update sprite or visual representation based on growth stage
	var sprite_frame = int(growth_stage)
	$Sprite.frame = sprite_frame
