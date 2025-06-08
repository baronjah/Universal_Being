extends Node
class_name JSHInteractionMatrix

# The interaction matrix defines how entities interact with each other based on their types
# It handles entity-to-entity interactions, transformations, and emergent behaviors

# Singleton instance
static var _instance = null
static func get_instance() -> JSHInteractionMatrix:
	if not _instance:
		_instance = JSHInteractionMatrix.new()
	return _instance

# Matrix storage - maps entity type pairs to interaction rules
# Format: {source_type: {target_type: [InteractionRule]}}
var _interaction_rules = {}

# Interaction rule inner class
class InteractionRule:
	var source_type: String
	var target_type: String
	var probability: float # 0.0 to 1.0
	var condition_script: String # GDScript snippet for custom condition
	var effect_type: String # "transform", "spawn", "evolve", "merge", "split", etc.
	var effect_params: Dictionary # Parameters for the effect
	var cooldown: float # Cooldown time in seconds
	var last_triggered: Dictionary = {} # Map of entity IDs to last trigger time
	
	func _init(p_source_type: String, p_target_type: String, p_probability: float, 
			   p_effect_type: String, p_effect_params: Dictionary, 
			   p_cooldown: float = 0.0, p_condition_script: String = ""):
		source_type = p_source_type
		target_type = p_target_type
		probability = p_probability
		effect_type = p_effect_type
		effect_params = p_effect_params
		cooldown = p_cooldown
		condition_script = p_condition_script

func _init():
	# Initialize default interaction rules if this is the first instance
	if not _instance:
		_setup_default_rules()

func _setup_default_rules():
	# Example basic rules - should be expanded with real game-specific rules
	
	# Water + Seed = Plant interaction
	add_interaction_rule("water", "seed", 0.8, "transform", {
		"target_becomes": "plant_seedling",
		"source_consumed": true
	})
	
	# Fire + Wood = Fire (fire spreads to wood)
	add_interaction_rule("fire", "wood", 0.9, "transform", {
		"target_becomes": "fire",
		"source_remains": true,
		"duration": 10.0
	})
	
	# Plant + Sunlight = Plant Growth
	add_interaction_rule("plant", "sunlight", 1.0, "evolve", {
		"growth_stage": "+1",
		"source_remains": true
	}, 60.0) # 60 second cooldown on growth

# Add a new interaction rule between entity types
func add_interaction_rule(source_type: String, target_type: String, probability: float, 
						  effect_type: String, effect_params: Dictionary, 
						  cooldown: float = 0.0, condition_script: String = "") -> void:
	# Create the rule object
	var rule = InteractionRule.new(source_type, target_type, probability, 
								   effect_type, effect_params, cooldown, condition_script)
	
	# Initialize the source type dictionary if it doesn't exist
	if not _interaction_rules.has(source_type):
		_interaction_rules[source_type] = {}
	
	# Initialize the target type array if it doesn't exist
	if not _interaction_rules[source_type].has(target_type):
		_interaction_rules[source_type][target_type] = []
	
	# Add the rule to the matrix
	_interaction_rules[source_type][target_type].append(rule)

# Remove all interaction rules between entity types
func remove_interaction_rules(source_type: String, target_type: String) -> void:
	if _interaction_rules.has(source_type) and _interaction_rules[source_type].has(target_type):
		_interaction_rules[source_type].erase(target_type)
		
		# Clean up empty dictionaries
		if _interaction_rules[source_type].is_empty():
			_interaction_rules.erase(source_type)

# Get all interaction rules between two entity types
func get_interaction_rules(source_type: String, target_type: String) -> Array:
	if _interaction_rules.has(source_type) and _interaction_rules[source_type].has(target_type):
		return _interaction_rules[source_type][target_type]
	return []

# Check if there are any interaction rules between two entity types
func has_interaction_rules(source_type: String, target_type: String) -> bool:
	return (_interaction_rules.has(source_type) and 
			_interaction_rules[source_type].has(target_type) and 
			not _interaction_rules[source_type][target_type].is_empty())

# Process an interaction between two entities
func process_interaction(source_entity: JSHUniversalEntity, target_entity: JSHUniversalEntity) -> bool:
	# Get the entity types
	var source_type = source_entity.entity_type
	var target_type = target_entity.entity_type
	
	# Check if there are rules for these types
	if not has_interaction_rules(source_type, target_type):
		return false
	
	# Get applicable rules
	var rules = get_interaction_rules(source_type, target_type)
	var interaction_occurred = false
	
	# Try each rule
	for rule in rules:
		# Skip if on cooldown
		var entity_key = str(source_entity.entity_id) + "_" + str(target_entity.entity_id)
		if rule.last_triggered.has(entity_key):
			var time_since_last = Time.get_ticks_msec() / 1000.0 - rule.last_triggered[entity_key]
			if time_since_last < rule.cooldown:
				continue
		
		# Check probability
		if randf() > rule.probability:
			continue
			
		# Check custom condition if specified
		if not rule.condition_script.is_empty():
			var result = _evaluate_condition(rule.condition_script, source_entity, target_entity)
			if not result:
				continue
		
		# Apply effect based on type
		_apply_effect(rule, source_entity, target_entity)
		
		# Update last triggered time
		rule.last_triggered[entity_key] = Time.get_ticks_msec() / 1000.0
		
		interaction_occurred = true
	
	return interaction_occurred

# Evaluate a custom condition script
func _evaluate_condition(condition_script: String, source_entity: JSHUniversalEntity, target_entity: JSHUniversalEntity) -> bool:
	# Security note: Running arbitrary scripts can be dangerous in production
	# Consider using a more structured approach for conditions in a real game
	
	var script = GDScript.new()
	script.source_code = """
	func evaluate(source, target):
		var result = false
		%s
		return result
	""" % condition_script
	
	script.reload()
	var obj = RefCounted.new()
	obj.set_script(script)
	
	# Evaluate the condition
	return obj.evaluate(source_entity, target_entity)

# Apply the effect of an interaction rule
func _apply_effect(rule: InteractionRule, source_entity: JSHUniversalEntity, target_entity: JSHUniversalEntity) -> void:
	var effect_type = rule.effect_type
	var params = rule.effect_params
	
	match effect_type:
		"transform":
			_apply_transform_effect(rule, source_entity, target_entity)
		"spawn":
			_apply_spawn_effect(rule, source_entity, target_entity)
		"evolve":
			_apply_evolve_effect(rule, source_entity, target_entity)
		"merge":
			_apply_merge_effect(rule, source_entity, target_entity)
		"split":
			_apply_split_effect(rule, source_entity, target_entity)
		_:
			push_error("Unknown effect type: " + effect_type)

# Apply a transform effect (change entity type)
func _apply_transform_effect(rule: InteractionRule, source_entity: JSHUniversalEntity, target_entity: JSHUniversalEntity) -> void:
	var params = rule.effect_params
	
	# Transform target if specified
	if params.has("target_becomes"):
		# Save the target's data
		var target_data = target_entity.get_entity_data()
		target_data["entity_type"] = params["target_becomes"]
		
		# Update entity with new type
		target_entity.set_entity_data(target_data)
		target_entity.entity_type = params["target_becomes"]
		
		# Emit signal for UI updates
		target_entity.emit_signal("entity_transformed", target_entity)
	
	# Handle source entity
	if params.has("source_consumed") and params["source_consumed"]:
		# Mark source for deletion
		JSHEntityManager.get_instance().mark_entity_for_deletion(source_entity.entity_id)
	elif params.has("source_becomes"):
		# Transform source
		var source_data = source_entity.get_entity_data()
		source_data["entity_type"] = params["source_becomes"]
		source_entity.set_entity_data(source_data)
		source_entity.entity_type = params["source_becomes"]
		source_entity.emit_signal("entity_transformed", source_entity)

# Apply a spawn effect (create new entities)
func _apply_spawn_effect(rule: InteractionRule, source_entity: JSHUniversalEntity, target_entity: JSHUniversalEntity) -> void:
	var params = rule.effect_params
	
	if not params.has("spawn_type"):
		push_error("Spawn effect missing spawn_type parameter")
		return
	
	var spawn_type = params["spawn_type"]
	var count = params.get("count", 1)
	var position = target_entity.position
	
	# Adjust position if offset is specified
	if params.has("offset"):
		var offset = params["offset"]
		position += Vector3(offset.x, offset.y, offset.z)
	
	# Create the new entities
	var entity_manager = JSHEntityManager.get_instance()
	for i in range(count):
		var spawn_data = {
			"entity_type": spawn_type,
			"position": position,
			"parent_id": target_entity.entity_id if params.get("set_parent", false) else null
		}
		
		# Add additional data if specified
		if params.has("additional_data"):
			for key in params["additional_data"]:
				spawn_data[key] = params["additional_data"][key]
		
		# Create the new entity
		var new_entity = entity_manager.create_entity(spawn_data)
		
		# Emit signal for UI updates
		if new_entity:
			new_entity.emit_signal("entity_spawned", new_entity, source_entity, target_entity)

# Apply an evolve effect (change entity properties or stage)
func _apply_evolve_effect(rule: InteractionRule, source_entity: JSHUniversalEntity, target_entity: JSHUniversalEntity) -> void:
	var params = rule.effect_params
	var entity_to_evolve = target_entity
	
	# Determine which entity to evolve
	if params.has("evolve_source") and params["evolve_source"]:
		entity_to_evolve = source_entity
	
	# Handle growth stage
	if params.has("growth_stage"):
		var growth_value = params["growth_stage"]
		var current_stage = entity_to_evolve.get_property("growth_stage", 0)
		
		if growth_value.begins_with("+"):
			# Increment growth stage
			current_stage += int(growth_value.substr(1))
		elif growth_value.begins_with("-"):
			# Decrement growth stage
			current_stage -= int(growth_value.substr(1))
		else:
			# Set absolute growth stage
			current_stage = int(growth_value)
		
		entity_to_evolve.set_property("growth_stage", current_stage)
	
	# Apply property changes
	if params.has("property_changes"):
		for property_name in params["property_changes"]:
			var property_value = params["property_changes"][property_name]
			entity_to_evolve.set_property(property_name, property_value)
	
	# Check if we need to transform based on growth stage
	if params.has("stage_transforms"):
		var stage_transforms = params["stage_transforms"]
		var current_stage = entity_to_evolve.get_property("growth_stage", 0)
		
		if stage_transforms.has(str(current_stage)):
			var new_type = stage_transforms[str(current_stage)]
			
			# Transform entity to new type
			var entity_data = entity_to_evolve.get_entity_data()
			entity_data["entity_type"] = new_type
			entity_to_evolve.set_entity_data(entity_data)
			entity_to_evolve.entity_type = new_type
			
			# Emit signal for UI updates
			entity_to_evolve.emit_signal("entity_transformed", entity_to_evolve)
	
	# Increment complexity if specified
	if params.has("complexity_change"):
		var complexity_change = params["complexity_change"]
		var current_complexity = entity_to_evolve.complexity
		
		if complexity_change.begins_with("+"):
			current_complexity += float(complexity_change.substr(1))
		elif complexity_change.begins_with("-"):
			current_complexity -= float(complexity_change.substr(1))
		else:
			current_complexity = float(complexity_change)
		
		entity_to_evolve.complexity = current_complexity
		
		# Check for splitting if complexity is too high
		if entity_to_evolve.complexity > entity_to_evolve.split_threshold:
			entity_to_evolve.attempt_split()
	
	# Emit signal for UI updates
	entity_to_evolve.emit_signal("entity_evolved", entity_to_evolve)

# Apply a merge effect (combine entities)
func _apply_merge_effect(rule: InteractionRule, source_entity: JSHUniversalEntity, target_entity: JSHUniversalEntity) -> void:
	var params = rule.effect_params
	
	# Determine the result type
	var result_type = params.get("result_type", source_entity.entity_type)
	
	# Create result data combining both entities
	var result_data = {
		"entity_type": result_type,
		"position": target_entity.position,
	}
	
	# Combine properties from both entities
	var source_data = source_entity.get_entity_data()
	var target_data = target_entity.get_entity_data()
	
	# Handle specific property merging logic
	if params.has("merge_properties"):
		for property_name in params["merge_properties"]:
			var merge_type = params["merge_properties"][property_name]
			
			match merge_type:
				"add":
					# Add numeric properties
					var source_value = source_data.get(property_name, 0)
					var target_value = target_data.get(property_name, 0)
					result_data[property_name] = source_value + target_value
				"max":
					# Take maximum value
					var source_value = source_data.get(property_name, 0)
					var target_value = target_data.get(property_name, 0)
					result_data[property_name] = max(source_value, target_value)
				"min":
					# Take minimum value
					var source_value = source_data.get(property_name, 0)
					var target_value = target_data.get(property_name, 0)
					result_data[property_name] = min(source_value, target_value)
				"concat":
					# Concatenate string or array properties
					var source_value = source_data.get(property_name, "")
					var target_value = target_data.get(property_name, "")
					result_data[property_name] = str(source_value) + str(target_value)
				"source":
					# Use source entity value
					result_data[property_name] = source_data.get(property_name)
				"target":
					# Use target entity value
					result_data[property_name] = target_data.get(property_name)
	
	# Create the new merged entity
	var entity_manager = JSHEntityManager.get_instance()
	var merged_entity = entity_manager.create_entity(result_data)
	
	# Calculate combined complexity
	merged_entity.complexity = source_entity.complexity + target_entity.complexity
	
	# Delete the original entities
	entity_manager.mark_entity_for_deletion(source_entity.entity_id)
	entity_manager.mark_entity_for_deletion(target_entity.entity_id)
	
	# Emit signal for UI updates
	merged_entity.emit_signal("entities_merged", merged_entity, [source_entity, target_entity])

# Apply a split effect (divide entity into multiple entities)
func _apply_split_effect(rule: InteractionRule, source_entity: JSHUniversalEntity, target_entity: JSHUniversalEntity) -> void:
	var params = rule.effect_params
	var entity_to_split = target_entity
	
	# Determine which entity to split
	if params.has("split_source") and params["split_source"]:
		entity_to_split = source_entity
	
	# Get split configuration
	var split_count = params.get("split_count", 2)
	var split_types = params.get("split_types", [entity_to_split.entity_type])
	
	# Start the split process
	entity_to_split.split_into_multiple(split_count, split_types)

# Save the interaction matrix to a file
func save_to_file(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open file for writing: " + file_path)
		return false
	
	# Convert interaction rules to serializable format
	var serialized_data = {}
	for source_type in _interaction_rules:
		serialized_data[source_type] = {}
		for target_type in _interaction_rules[source_type]:
			serialized_data[source_type][target_type] = []
			for rule in _interaction_rules[source_type][target_type]:
				serialized_data[source_type][target_type].append({
					"probability": rule.probability,
					"effect_type": rule.effect_type,
					"effect_params": rule.effect_params,
					"cooldown": rule.cooldown,
					"condition_script": rule.condition_script
				})
	
	# Save as JSON
	file.store_string(JSON.stringify(serialized_data, "\t"))
	return true

# Load the interaction matrix from a file
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
	
	# Clear existing rules
	_interaction_rules.clear()
	
	# Load rules from JSON
	var loaded_data = json_result
	for source_type in loaded_data:
		for target_type in loaded_data[source_type]:
			for rule_data in loaded_data[source_type][target_type]:
				add_interaction_rule(
					source_type,
					target_type,
					rule_data["probability"],
					rule_data["effect_type"],
					rule_data["effect_params"],
					rule_data.get("cooldown", 0.0),
					rule_data.get("condition_script", "")
				)
	
	return true

# Reset all interaction rules
func reset_rules() -> void:
	_interaction_rules.clear()
	_setup_default_rules()

# Get all entity types that can interact with a specific type
func get_interaction_sources_for_type(target_type: String) -> Array:
	var sources = []
	for source_type in _interaction_rules:
		if _interaction_rules[source_type].has(target_type):
			sources.append(source_type)
	return sources

# Get all entity types that a specific type can interact with
func get_interaction_targets_for_type(source_type: String) -> Array:
	var targets = []
	if _interaction_rules.has(source_type):
		targets = _interaction_rules[source_type].keys()
	return targets

# Process all possible interactions in a list of entities
func process_entity_interactions(entities: Array) -> int:
	var interaction_count = 0
	
	# Check all pairs of entities for possible interactions
	for i in range(entities.size()):
		var source_entity = entities[i]
		
		for j in range(entities.size()):
			if i == j:
				continue
				
			var target_entity = entities[j]
			
			# Process interaction between this pair
			if process_interaction(source_entity, target_entity):
				interaction_count += 1
	
	return interaction_count

# Process interactions between two lists of entities
func process_group_interactions(group1: Array, group2: Array) -> int:
	var interaction_count = 0
	
	# Check all pairs of entities between the two groups
	for source_entity in group1:
		for target_entity in group2:
			# Process interaction between this pair
			if process_interaction(source_entity, target_entity):
				interaction_count += 1
	
	return interaction_count