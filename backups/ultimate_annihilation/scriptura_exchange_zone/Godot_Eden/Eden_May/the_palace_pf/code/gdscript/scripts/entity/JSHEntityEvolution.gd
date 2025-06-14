extends Node
class_name JSHEntityEvolution

# The JSHEntityEvolution system manages the evolution of entities over time
# It handles evolution stages, triggers, conditions, and transformations

# Singleton instance
static var _instance = null
static func get_instance() -> JSHEntityEvolution:
	if not _instance:
		_instance = JSHEntityEvolution.new()
	return _instance

# Evolution stages define how entities progress
# Format: {entity_type: {stage_name: EvolutionStage}}
var _evolution_stages = {}

# Evolution stage inner class
class EvolutionStage:
	var stage_name: String
	var entity_type: String
	var required_complexity: float
	var stage_index: int
	var requirements: Dictionary
	var transforms_to: String
	var effect_script: String
	var next_stages: Array[String]
	
	func _init(p_stage_name: String, p_entity_type: String, p_stage_index: int,
			   p_required_complexity: float, p_requirements: Dictionary,
			   p_transforms_to: String = "", p_effect_script: String = "", p_next_stages: Array = []):
		stage_name = p_stage_name
		entity_type = p_entity_type
		stage_index = p_stage_index
		required_complexity = p_required_complexity
		requirements = p_requirements
		transforms_to = p_transforms_to
		effect_script = p_effect_script
		next_stages = p_next_stages

func _init():
	# Initialize default evolution stages if this is the first instance
	if not _instance:
		_setup_default_stages()

func _setup_default_stages():
	# Example basic evolution paths - should be expanded with real game-specific stages
	
	# Plant evolution path: seed -> seedling -> young -> mature -> flowering -> fruit bearing
	define_evolution_stage("seed", "seed", 0, 0.0, {})
	
	define_evolution_stage("seedling", "plant", 1, 1.0, {
		"water_level": {"min": 2.0},
		"sunlight": {"min": 1.0}
	}, "plant_seedling")
	
	define_evolution_stage("young", "plant", 2, 2.0, {
		"water_level": {"min": 5.0},
		"sunlight": {"min": 3.0},
		"soil_quality": {"min": 2.0}
	}, "plant_young")
	
	define_evolution_stage("mature", "plant", 3, 4.0, {
		"water_level": {"min": 8.0},
		"sunlight": {"min": 5.0},
		"soil_quality": {"min": 4.0},
		"age": {"min": 10.0}
	}, "plant_mature")
	
	define_evolution_stage("flowering", "plant", 4, 6.0, {
		"water_level": {"min": 10.0},
		"sunlight": {"min": 8.0},
		"soil_quality": {"min": 6.0},
		"age": {"min": 20.0}
	}, "plant_flowering")
	
	define_evolution_stage("fruit_bearing", "plant", 5, 8.0, {
		"water_level": {"min": 12.0},
		"sunlight": {"min": 10.0},
		"soil_quality": {"min": 8.0},
		"age": {"min": 30.0},
		"pollinated": {"equals": true}
	}, "plant_fruit")
	
	# Set up stage connections
	add_next_stage("seed", "seedling")
	add_next_stage("seedling", "young")
	add_next_stage("young", "mature")
	add_next_stage("mature", "flowering")
	add_next_stage("flowering", "fruit_bearing")

# Define a new evolution stage
func define_evolution_stage(stage_name: String, entity_type: String, stage_index: int,
							required_complexity: float, requirements: Dictionary,
							transforms_to: String = "", effect_script: String = "") -> void:
	# Create the stage object
	var stage = EvolutionStage.new(
		stage_name, entity_type, stage_index, required_complexity, 
		requirements, transforms_to, effect_script
	)
	
	# Initialize the entity type dictionary if it doesn't exist
	if not _evolution_stages.has(entity_type):
		_evolution_stages[entity_type] = {}
	
	# Add the stage to the entity type
	_evolution_stages[entity_type][stage_name] = stage

# Define a connection between stages (what comes next)
func add_next_stage(from_stage: String, to_stage: String) -> void:
	# Find the source stage
	for entity_type in _evolution_stages:
		if _evolution_stages[entity_type].has(from_stage):
			# Add the target stage to the next_stages array
			if not to_stage in _evolution_stages[entity_type][from_stage].next_stages:
				_evolution_stages[entity_type][from_stage].next_stages.append(to_stage)
			return

# Get the evolution stage for an entity
func get_entity_stage(entity: JSHUniversalEntity) -> String:
	var entity_type = entity.entity_type
	var current_stage = entity.get_property("evolution_stage", "")
	
	# If entity has a defined stage, return it
	if not current_stage.is_empty():
		return current_stage
	
	# Otherwise, try to determine the stage based on entity type
	if _evolution_stages.has(entity_type):
		# Find the lowest stage for this type
		var lowest_stage = null
		var lowest_index = 9999
		
		for stage_name in _evolution_stages[entity_type]:
			var stage = _evolution_stages[entity_type][stage_name]
			if stage.stage_index < lowest_index:
				lowest_index = stage.stage_index
				lowest_stage = stage_name
		
		if lowest_stage:
			return lowest_stage
	
	# If no stage is found, return empty string
	return ""

# Get the next possible evolution stages for an entity
func get_next_stages(entity: JSHUniversalEntity) -> Array:
	var entity_type = entity.entity_type
	var current_stage = get_entity_stage(entity)
	
	# If no current stage or unknown entity type, return empty array
	if current_stage.is_empty() or not _evolution_stages.has(entity_type):
		return []
	
	# If current stage not found in entity type, return empty array
	if not _evolution_stages[entity_type].has(current_stage):
		return []
	
	# Return the next stages array
	return _evolution_stages[entity_type][current_stage].next_stages

# Check if an entity can evolve to a specific stage
func can_evolve_to_stage(entity: JSHUniversalEntity, target_stage: String) -> bool:
	var entity_type = entity.entity_type
	
	# Check if entity type has stages defined
	if not _evolution_stages.has(entity_type):
		return false
	
	# Check if target stage exists for this entity type
	if not _evolution_stages[entity_type].has(target_stage):
		return false
	
	# Get the stage data
	var stage = _evolution_stages[entity_type][target_stage]
	
	# Check if entity has enough complexity
	if entity.complexity < stage.required_complexity:
		return false
	
	# Check if the stage is in the next stages list for the current stage
	var current_stage = get_entity_stage(entity)
	if not current_stage.is_empty() and _evolution_stages[entity_type].has(current_stage):
		if not target_stage in _evolution_stages[entity_type][current_stage].next_stages:
			return false
	
	# Check all requirements
	for req_name in stage.requirements:
		var req = stage.requirements[req_name]
		var entity_value = entity.get_property(req_name, null)
		
		# If property doesn't exist, requirement fails
		if entity_value == null:
			return false
		
		# Check based on requirement type
		if req.has("min") and entity_value < req["min"]:
			return false
		if req.has("max") and entity_value > req["max"]:
			return false
		if req.has("equals") and entity_value != req["equals"]:
			return false
		if req.has("not_equals") and entity_value == req["not_equals"]:
			return false
	
	# All checks passed
	return true

# Get all stages an entity can currently evolve to
func get_available_evolution_options(entity: JSHUniversalEntity) -> Array:
	var next_stages = get_next_stages(entity)
	var available_stages = []
	
	# Check each potential next stage
	for stage_name in next_stages:
		if can_evolve_to_stage(entity, stage_name):
			available_stages.append(stage_name)
	
	return available_stages

# Evolve an entity to a specific stage
func evolve_entity_to_stage(entity: JSHUniversalEntity, target_stage: String) -> bool:
	# Check if evolution is possible
	if not can_evolve_to_stage(entity, target_stage):
		return false
	
	var entity_type = entity.entity_type
	var stage = _evolution_stages[entity_type][target_stage]
	
	# Store current stage for reference
	var previous_stage = get_entity_stage(entity)
	
	# Update entity properties
	entity.set_property("evolution_stage", target_stage)
	
	# If stage defines a transformation
	if not stage.transforms_to.is_empty():
		# Save entity data
		var entity_data = entity.get_entity_data()
		
		# Update entity type
		entity_data["entity_type"] = stage.transforms_to
		entity.set_entity_data(entity_data)
		entity.entity_type = stage.transforms_to
	
	# Run effect script if defined
	if not stage.effect_script.is_empty():
		_run_effect_script(stage.effect_script, entity, previous_stage, target_stage)
	
	# Emit signal for UI updates
	entity.emit_signal("entity_evolved", entity)
	
	return true

# Evaluate a custom effect script
func _run_effect_script(effect_script: String, entity: JSHUniversalEntity, from_stage: String, to_stage: String) -> void:
	# Security note: Running arbitrary scripts can be dangerous in production
	# Consider using a more structured approach for effects in a real game
	
	var script = GDScript.new()
	script.source_code = """
	func apply_effect(entity, from_stage, to_stage):
		%s
	""" % effect_script
	
	script.reload()
	var obj = RefCounted.new()
	obj.set_script(script)
	
	# Apply the effect
	obj.apply_effect(entity, from_stage, to_stage)

# Process evolution for a batch of entities
func process_batch_evolution(entities: Array, delta: float) -> int:
	var evolution_count = 0
	
	for entity in entities:
		# Skip entities without evolution data
		if not entity.has_property("evolution_time_accumulator"):
			# Initialize evolution timer
			entity.set_property("evolution_time_accumulator", 0.0)
			continue
		
		# Accumulate time
		var time_acc = entity.get_property("evolution_time_accumulator", 0.0)
		time_acc += delta
		entity.set_property("evolution_time_accumulator", time_acc)
		
		# Check if enough time has passed for evolution check
		var check_interval = entity.get_property("evolution_check_interval", 5.0)
		if time_acc < check_interval:
			continue
		
		# Reset accumulator
		entity.set_property("evolution_time_accumulator", 0.0)
		
		# Check for possible evolutions
		var options = get_available_evolution_options(entity)
		if options.is_empty():
			continue
		
		# Decide which evolution to perform (for now, just take the first available)
		var target_stage = options[0]
		
		# Evolve the entity
		if evolve_entity_to_stage(entity, target_stage):
			evolution_count += 1
	
	return evolution_count

# Save evolution stages to a file
func save_to_file(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open file for writing: " + file_path)
		return false
	
	# Convert evolution stages to serializable format
	var serialized_data = {}
	for entity_type in _evolution_stages:
		serialized_data[entity_type] = {}
		for stage_name in _evolution_stages[entity_type]:
			var stage = _evolution_stages[entity_type][stage_name]
			serialized_data[entity_type][stage_name] = {
				"stage_index": stage.stage_index,
				"required_complexity": stage.required_complexity,
				"requirements": stage.requirements,
				"transforms_to": stage.transforms_to,
				"effect_script": stage.effect_script,
				"next_stages": stage.next_stages
			}
	
	# Save as JSON
	file.store_string(JSON.stringify(serialized_data, "\t"))
	return true

# Load evolution stages from a file
func load_from_file(file_path: String) -> bool:
	if not FileAccess.file_exists(file_path):
		push_error("File doesn't exist: " + file_path)
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open file for reading: " + file_path)
		return false
	
	var json_text = file.get_as_text()
	var json_result = JSON.parse_string(json_text)
	if json_result == null:
		push_error("Failed to parse JSON from file: " + file_path)
		return false
	
	# Clear existing stages
	_evolution_stages.clear()
	
	# Load stages from JSON
	var loaded_data = json_result
	for entity_type in loaded_data:
		for stage_name in loaded_data[entity_type]:
			var stage_data = loaded_data[entity_type][stage_name]
			
			# Create the stage
			define_evolution_stage(
				stage_name,
				entity_type,
				stage_data["stage_index"],
				stage_data["required_complexity"],
				stage_data["requirements"],
				stage_data["transforms_to"],
				stage_data["effect_script"]
			)
	
	# Set up stage connections
	for entity_type in loaded_data:
		for stage_name in loaded_data[entity_type]:
			var stage_data = loaded_data[entity_type][stage_name]
			
			# Add next stages
			for next_stage in stage_data["next_stages"]:
				add_next_stage(stage_name, next_stage)
	
	return true

# Reset all evolution stages
func reset_stages() -> void:
	_evolution_stages.clear()
	_setup_default_stages()

# Get a list of all entity types with evolution stages
func get_evolvable_entity_types() -> Array:
	return _evolution_stages.keys()

# Get a list of all stages for an entity type
func get_stages_for_entity_type(entity_type: String) -> Array:
	if not _evolution_stages.has(entity_type):
		return []
	
	return _evolution_stages[entity_type].keys()

# Get the initial stage for an entity type
func get_initial_stage(entity_type: String) -> String:
	if not _evolution_stages.has(entity_type):
		return ""
	
	var lowest_stage = ""
	var lowest_index = 9999
	
	for stage_name in _evolution_stages[entity_type]:
		var stage = _evolution_stages[entity_type][stage_name]
		if stage.stage_index < lowest_index:
			lowest_index = stage.stage_index
			lowest_stage = stage_name
	
	return lowest_stage

# Get the stage information
func get_stage_info(entity_type: String, stage_name: String) -> Dictionary:
	if not _evolution_stages.has(entity_type) or not _evolution_stages[entity_type].has(stage_name):
		return {}
	
	var stage = _evolution_stages[entity_type][stage_name]
	return {
		"stage_name": stage.stage_name,
		"entity_type": stage.entity_type,
		"stage_index": stage.stage_index,
		"required_complexity": stage.required_complexity,
		"requirements": stage.requirements,
		"transforms_to": stage.transforms_to,
		"next_stages": stage.next_stages
	}

# Set up an entity with initial evolution data
func initialize_entity_evolution(entity: JSHUniversalEntity) -> void:
	var entity_type = entity.entity_type
	
	# Skip if entity type doesn't have evolution stages
	if not _evolution_stages.has(entity_type):
		return
	
	# Get initial stage
	var initial_stage = get_initial_stage(entity_type)
	if initial_stage.is_empty():
		return
	
	# Set initial properties
	entity.set_property("evolution_stage", initial_stage)
	entity.set_property("evolution_time_accumulator", 0.0)
	entity.set_property("evolution_check_interval", 5.0) # Check every 5 seconds by default