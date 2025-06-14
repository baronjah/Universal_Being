extends Node
class_name JSHDataTransformation

# The JSHDataTransformation system handles dynamic transformations of entity data
# It provides a flexible way to modify, combine, and process entity properties and behavior

# Singleton instance
static var _instance = null
static func get_instance() -> JSHDataTransformation:
	if not _instance:
		_instance = JSHDataTransformation.new()
	return _instance

# Transformation templates - reusable transformations that can be applied
# Format: {template_name: TransformationTemplate}
var _transformation_templates = {}

# Registered operation handlers
# Format: {operation_name: callable}
var _operation_handlers = {}

# Transformation template inner class
class TransformationTemplate:
	var template_name: String
	var description: String
	var transformation_steps: Array
	var applies_to_types: Array
	
	func _init(p_name: String, p_description: String, p_steps: Array, p_types: Array = []):
		template_name = p_name
		description = p_description
		transformation_steps = p_steps
		applies_to_types = p_types

func _init():
	# Initialize default transformation templates and operations
	if not _instance:
		_setup_default_operations()
		_setup_default_templates()

func _setup_default_operations() -> void:
	# Register basic operations
	register_operation("add", _operation_add)
	register_operation("subtract", _operation_subtract)
	register_operation("multiply", _operation_multiply)
	register_operation("divide", _operation_divide)
	register_operation("concat", _operation_concat)
	register_operation("replace", _operation_replace)
	register_operation("increment", _operation_increment)
	register_operation("decrement", _operation_decrement)
	register_operation("set", _operation_set)
	register_operation("copy", _operation_copy)
	register_operation("remove", _operation_remove)
	register_operation("min", _operation_min)
	register_operation("max", _operation_max)
	register_operation("round", _operation_round)
	register_operation("floor", _operation_floor)
	register_operation("ceil", _operation_ceil)
	register_operation("clamp", _operation_clamp)
	register_operation("lerp", _operation_lerp)
	register_operation("condition", _operation_condition)
	register_operation("random", _operation_random)
	register_operation("transform", _operation_transform)
	register_operation("merge", _operation_merge)
	register_operation("split", _operation_split)
	register_operation("evaluate", _operation_evaluate)

func _setup_default_templates() -> void:
	# Register basic transformation templates
	
	# Example: Growth template
	register_transformation_template(
		"growth",
		"Increases size, mass, and complexity of an entity over time",
		[
			{
				"operation": "multiply",
				"property": "size",
				"value": 1.1
			},
			{
				"operation": "multiply",
				"property": "mass",
				"value": 1.1
			},
			{
				"operation": "add",
				"property": "complexity",
				"value": 0.2
			}
		],
		["plant", "animal", "tree"]
	)
	
	# Example: Decay template
	register_transformation_template(
		"decay",
		"Reduces health, energy, and increases age of an entity over time",
		[
			{
				"operation": "multiply",
				"property": "health",
				"value": 0.95
			},
			{
				"operation": "multiply",
				"property": "energy",
				"value": 0.98
			},
			{
				"operation": "add",
				"property": "age",
				"value": 1.0
			}
		]
	)
	
	# Example: Temperature adjustment template
	register_transformation_template(
		"temperature_adjustment",
		"Adjusts entity temperature based on environment",
		[
			{
				"operation": "lerp",
				"property": "temperature",
				"target": "environment.temperature",
				"factor": 0.05
			}
		]
	)
	
	# Example: Data merging template
	register_transformation_template(
		"data_merge",
		"Merges properties from source into target entity",
		[
			{
				"operation": "merge",
				"source": "source_entity",
				"strategy": {
					"size": "max",
					"mass": "add",
					"energy": "add",
					"complexity": "max"
				}
			}
		]
	)

# Register a new operation handler
func register_operation(name: String, handler: Callable) -> void:
	_operation_handlers[name] = handler

# Register a new transformation template
func register_transformation_template(name: String, description: String, 
									  steps: Array, applies_to_types: Array = []) -> void:
	var template = TransformationTemplate.new(name, description, steps, applies_to_types)
	_transformation_templates[name] = template

# Apply a transformation template to an entity
func apply_transformation(template_name: String, entity: JSHUniversalEntity, 
						  parameters: Dictionary = {}) -> bool:
	# Check if template exists
	if not _transformation_templates.has(template_name):
		push_error("Transformation template not found: " + template_name)
		return false
	
	var template = _transformation_templates[template_name]
	
	# Check if entity type is compatible
	if not template.applies_to_types.is_empty():
		if not entity.entity_type in template.applies_to_types:
			return false
	
	# Apply each transformation step
	for step in template.transformation_steps:
		if not _apply_transformation_step(step, entity, parameters):
			push_warning("Transformation step failed during template: " + template_name)
	
	return true

# Apply a transformation to multiple entities
func apply_transformation_to_batch(template_name: String, entities: Array, 
								   parameters: Dictionary = {}) -> int:
	var success_count = 0
	
	for entity in entities:
		if apply_transformation(template_name, entity, parameters):
			success_count += 1
	
	return success_count

# Apply a custom transformation to an entity
func apply_custom_transformation(steps: Array, entity: JSHUniversalEntity, 
								 parameters: Dictionary = {}) -> bool:
	# Apply each transformation step
	for step in steps:
		if not _apply_transformation_step(step, entity, parameters):
			push_warning("Custom transformation step failed")
			return false
	
	return true

# Apply a single transformation step
func _apply_transformation_step(step: Dictionary, entity: JSHUniversalEntity, 
								parameters: Dictionary) -> bool:
	# Check if the operation exists
	if not step.has("operation") or not _operation_handlers.has(step["operation"]):
		push_error("Invalid operation in transformation step: " + str(step.get("operation", "N/A")))
		return false
	
	# Get operation handler
	var handler = _operation_handlers[step["operation"]]
	
	# Prepare context with parameters and entity
	var context = parameters.duplicate()
	context["entity"] = entity
	context["step"] = step
	
	# Apply the operation
	return handler.call(context)

# Create a custom transformation from a JSON string
func create_transformation_from_json(json_string: String) -> Array:
	var json_result = JSON.parse_string(json_string)
	if json_result == null:
		push_error("Failed to parse transformation JSON")
		return []
	
	if not json_result is Array:
		push_error("Transformation JSON must be an array of steps")
		return []
	
	return json_result

# Save transformations to a file
func save_to_file(file_path: String) -> bool:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open file for writing: " + file_path)
		return false
	
	# Convert templates to serializable format
	var serialized_data = {}
	for template_name in _transformation_templates:
		var template = _transformation_templates[template_name]
		serialized_data[template_name] = {
			"description": template.description,
			"steps": template.transformation_steps,
			"applies_to_types": template.applies_to_types
		}
	
	# Save as JSON
	file.store_string(JSON.stringify(serialized_data, "\t"))
	return true

# Load transformations from a file
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
	
	# Clear existing templates
	_transformation_templates.clear()
	
	# Load templates from JSON
	var loaded_data = json_result
	for template_name in loaded_data:
		var template_data = loaded_data[template_name]
		register_transformation_template(
			template_name,
			template_data["description"],
			template_data["steps"],
			template_data["applies_to_types"]
		)
	
	return true

# Reset all transformation templates
func reset_templates() -> void:
	_transformation_templates.clear()
	_setup_default_templates()

# Get all available transformation templates
func get_available_templates() -> Array:
	return _transformation_templates.keys()

# Get template information
func get_template_info(template_name: String) -> Dictionary:
	if not _transformation_templates.has(template_name):
		return {}
	
	var template = _transformation_templates[template_name]
	return {
		"name": template.template_name,
		"description": template.description,
		"steps_count": template.transformation_steps.size(),
		"applies_to_types": template.applies_to_types
	}

# Get all templates that apply to a specific entity type
func get_templates_for_entity_type(entity_type: String) -> Array:
	var matching_templates = []
	
	for template_name in _transformation_templates:
		var template = _transformation_templates[template_name]
		
		if template.applies_to_types.is_empty() or entity_type in template.applies_to_types:
			matching_templates.append(template_name)
	
	return matching_templates

# Operation implementations
func _operation_add(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property"):
		return false
	
	var property_name = step["property"]
	var current_value = entity.get_property(property_name, 0)
	var add_value = step.get("value", 0)
	
	# Handle value from context
	if add_value is String and add_value.begins_with("$"):
		var param_name = add_value.substr(1)
		if context.has(param_name):
			add_value = context[param_name]
		else:
			add_value = 0
	
	entity.set_property(property_name, current_value + add_value)
	return true

func _operation_subtract(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property"):
		return false
	
	var property_name = step["property"]
	var current_value = entity.get_property(property_name, 0)
	var subtract_value = step.get("value", 0)
	
	# Handle value from context
	if subtract_value is String and subtract_value.begins_with("$"):
		var param_name = subtract_value.substr(1)
		if context.has(param_name):
			subtract_value = context[param_name]
		else:
			subtract_value = 0
	
	entity.set_property(property_name, current_value - subtract_value)
	return true

func _operation_multiply(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property"):
		return false
	
	var property_name = step["property"]
	var current_value = entity.get_property(property_name, 0)
	var multiply_value = step.get("value", 1)
	
	# Handle value from context
	if multiply_value is String and multiply_value.begins_with("$"):
		var param_name = multiply_value.substr(1)
		if context.has(param_name):
			multiply_value = context[param_name]
		else:
			multiply_value = 1
	
	entity.set_property(property_name, current_value * multiply_value)
	return true

func _operation_divide(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property"):
		return false
	
	var property_name = step["property"]
	var current_value = entity.get_property(property_name, 0)
	var divide_value = step.get("value", 1)
	
	# Handle value from context
	if divide_value is String and divide_value.begins_with("$"):
		var param_name = divide_value.substr(1)
		if context.has(param_name):
			divide_value = context[param_name]
		else:
			divide_value = 1
	
	# Avoid division by zero
	if divide_value == 0:
		push_warning("Attempted division by zero in transformation")
		return false
	
	entity.set_property(property_name, current_value / divide_value)
	return true

func _operation_concat(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property"):
		return false
	
	var property_name = step["property"]
	var current_value = str(entity.get_property(property_name, ""))
	var concat_value = str(step.get("value", ""))
	
	# Handle value from context
	if concat_value.begins_with("$"):
		var param_name = concat_value.substr(1)
		if context.has(param_name):
			concat_value = str(context[param_name])
		else:
			concat_value = ""
	
	entity.set_property(property_name, current_value + concat_value)
	return true

func _operation_replace(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property") or not step.has("find") or not step.has("replace"):
		return false
	
	var property_name = step["property"]
	var current_value = str(entity.get_property(property_name, ""))
	var find_value = str(step["find"])
	var replace_value = str(step["replace"])
	
	# Handle values from context
	if find_value.begins_with("$"):
		var param_name = find_value.substr(1)
		if context.has(param_name):
			find_value = str(context[param_name])
	
	if replace_value.begins_with("$"):
		var param_name = replace_value.substr(1)
		if context.has(param_name):
			replace_value = str(context[param_name])
	
	var new_value = current_value.replace(find_value, replace_value)
	entity.set_property(property_name, new_value)
	return true

func _operation_increment(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property"):
		return false
	
	var property_name = step["property"]
	var current_value = entity.get_property(property_name, 0)
	entity.set_property(property_name, current_value + 1)
	return true

func _operation_decrement(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property"):
		return false
	
	var property_name = step["property"]
	var current_value = entity.get_property(property_name, 0)
	entity.set_property(property_name, current_value - 1)
	return true

func _operation_set(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property") or not step.has("value"):
		return false
	
	var property_name = step["property"]
	var set_value = step["value"]
	
	# Handle value from context
	if set_value is String and set_value.begins_with("$"):
		var param_name = set_value.substr(1)
		if context.has(param_name):
			set_value = context[param_name]
	
	entity.set_property(property_name, set_value)
	return true

func _operation_copy(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("from_property") or not step.has("to_property"):
		return false
	
	var from_property = step["from_property"]
	var to_property = step["to_property"]
	
	# Handle property from another entity
	if from_property.begins_with("$"):
		var parts = from_property.substr(1).split(".")
		if parts.size() >= 2 and context.has(parts[0]):
			var source_entity = context[parts[0]]
			if source_entity is JSHUniversalEntity:
				var source_property = parts[1]
				var value = source_entity.get_property(source_property)
				entity.set_property(to_property, value)
				return true
		return false
	
	var value = entity.get_property(from_property)
	entity.set_property(to_property, value)
	return true

func _operation_remove(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property"):
		return false
	
	var property_name = step["property"]
	return entity.remove_property(property_name)

func _operation_min(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property") or not step.has("value"):
		return false
	
	var property_name = step["property"]
	var current_value = entity.get_property(property_name, 0)
	var min_value = step["value"]
	
	# Handle value from context
	if min_value is String and min_value.begins_with("$"):
		var param_name = min_value.substr(1)
		if context.has(param_name):
			min_value = context[param_name]
		else:
			min_value = 0
	
	entity.set_property(property_name, min(current_value, min_value))
	return true

func _operation_max(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property") or not step.has("value"):
		return false
	
	var property_name = step["property"]
	var current_value = entity.get_property(property_name, 0)
	var max_value = step["value"]
	
	# Handle value from context
	if max_value is String and max_value.begins_with("$"):
		var param_name = max_value.substr(1)
		if context.has(param_name):
			max_value = context[param_name]
		else:
			max_value = 0
	
	entity.set_property(property_name, max(current_value, max_value))
	return true

func _operation_round(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property"):
		return false
	
	var property_name = step["property"]
	var current_value = entity.get_property(property_name, 0)
	entity.set_property(property_name, round(current_value))
	return true

func _operation_floor(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property"):
		return false
	
	var property_name = step["property"]
	var current_value = entity.get_property(property_name, 0)
	entity.set_property(property_name, floor(current_value))
	return true

func _operation_ceil(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property"):
		return false
	
	var property_name = step["property"]
	var current_value = entity.get_property(property_name, 0)
	entity.set_property(property_name, ceil(current_value))
	return true

func _operation_clamp(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property") or not step.has("min") or not step.has("max"):
		return false
	
	var property_name = step["property"]
	var current_value = entity.get_property(property_name, 0)
	var min_value = step["min"]
	var max_value = step["max"]
	
	# Handle values from context
	if min_value is String and min_value.begins_with("$"):
		var param_name = min_value.substr(1)
		if context.has(param_name):
			min_value = context[param_name]
		else:
			min_value = 0
	
	if max_value is String and max_value.begins_with("$"):
		var param_name = max_value.substr(1)
		if context.has(param_name):
			max_value = context[param_name]
		else:
			max_value = 1
	
	entity.set_property(property_name, clamp(current_value, min_value, max_value))
	return true

func _operation_lerp(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property") or not step.has("target") or not step.has("factor"):
		return false
	
	var property_name = step["property"]
	var current_value = entity.get_property(property_name, 0)
	var target_value = step["target"]
	var factor = step["factor"]
	
	# Handle values from context
	if target_value is String:
		if target_value.begins_with("$"):
			var param_name = target_value.substr(1)
			if context.has(param_name):
				target_value = context[param_name]
			else:
				target_value = 0
		elif target_value.find(".") != -1:
			# Handle dot notation for accessing other properties
			var parts = target_value.split(".")
			if parts.size() >= 2:
				if parts[0] == "environment" and context.has("environment"):
					var env = context["environment"]
					if env is Dictionary and env.has(parts[1]):
						target_value = env[parts[1]]
					else:
						target_value = 0
				else:
					target_value = 0
	
	if factor is String and factor.begins_with("$"):
		var param_name = factor.substr(1)
		if context.has(param_name):
			factor = context[param_name]
		else:
			factor = 0.5
	
	entity.set_property(property_name, lerp(current_value, target_value, factor))
	return true

func _operation_condition(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("if") or not step.has("then"):
		return false
	
	var condition = step["if"]
	var then_steps = step["then"]
	var else_steps = step.get("else", [])
	
	var condition_met = _evaluate_condition(condition, entity, context)
	
	if condition_met:
		for then_step in then_steps:
			_apply_transformation_step(then_step, entity, context)
	else:
		for else_step in else_steps:
			_apply_transformation_step(else_step, entity, context)
	
	return true

func _operation_random(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property"):
		return false
	
	var property_name = step["property"]
	var min_value = step.get("min", 0)
	var max_value = step.get("max", 1)
	
	# Handle values from context
	if min_value is String and min_value.begins_with("$"):
		var param_name = min_value.substr(1)
		if context.has(param_name):
			min_value = context[param_name]
		else:
			min_value = 0
	
	if max_value is String and max_value.begins_with("$"):
		var param_name = max_value.substr(1)
		if context.has(param_name):
			max_value = context[param_name]
		else:
			max_value = 1
	
	# Generate random value
	var random_value = 0
	if step.get("integer", false):
		random_value = randi_range(min_value, max_value)
	else:
		random_value = randf_range(min_value, max_value)
	
	entity.set_property(property_name, random_value)
	return true

func _operation_transform(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("template"):
		return false
	
	var template_name = step["template"]
	
	# Handle template name from context
	if template_name is String and template_name.begins_with("$"):
		var param_name = template_name.substr(1)
		if context.has(param_name):
			template_name = context[param_name]
		else:
			return false
	
	# Create parameters for the sub-transformation
	var sub_params = context.duplicate()
	if step.has("parameters"):
		for param_name in step["parameters"]:
			sub_params[param_name] = step["parameters"][param_name]
	
	return apply_transformation(template_name, entity, sub_params)

func _operation_merge(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("source") or not step.has("strategy"):
		return false
	
	var source_entity = null
	var source_ref = step["source"]
	
	# Handle source from context
	if source_ref is String and source_ref.begins_with("$"):
		var param_name = source_ref.substr(1)
		if context.has(param_name):
			source_entity = context[param_name]
		else:
			return false
	
	if not source_entity or not source_entity is JSHUniversalEntity:
		return false
	
	var merge_strategy = step["strategy"]
	
	# Apply merge strategy to each property
	for property_name in merge_strategy:
		var strategy = merge_strategy[property_name]
		var target_value = entity.get_property(property_name, null)
		var source_value = source_entity.get_property(property_name, null)
		
		if source_value == null:
			continue
		
		var new_value = null
		match strategy:
			"add":
				new_value = (target_value if target_value != null else 0) + source_value
			"max":
				if target_value == null:
					new_value = source_value
				else:
					new_value = max(target_value, source_value)
			"min":
				if target_value == null:
					new_value = source_value
				else:
					new_value = min(target_value, source_value)
			"replace":
				new_value = source_value
			"concat":
				if target_value == null:
					new_value = str(source_value)
				else:
					new_value = str(target_value) + str(source_value)
		
		if new_value != null:
			entity.set_property(property_name, new_value)
	
	return true

func _operation_split(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("count") or not step.has("property_distribution"):
		return false
	
	var split_count = step["count"]
	var property_distribution = step["property_distribution"]
	
	# Get entity manager
	var entity_manager = JSHEntityManager.get_instance()
	if not entity_manager:
		return false
	
	# Calculate property values for each split entity
	var split_entities = []
	for i in range(split_count):
		var entity_data = {
			"entity_type": entity.entity_type,
			"position": entity.position,
			"properties": {}
		}
		
		# Distribution properties according to strategy
		for property_name in property_distribution:
			var strategy = property_distribution[property_name]
			var original_value = entity.get_property(property_name, null)
			
			if original_value == null:
				continue
			
			var new_value = null
			match strategy:
				"divide":
					new_value = original_value / split_count
				"copy":
					new_value = original_value
				"distribute_random":
					if i == split_count - 1:
						# Last entity gets the remainder
						var total = 0
						for j in range(split_entities.size()):
							total += split_entities[j]["properties"].get(property_name, 0)
						new_value = original_value - total
					else:
						new_value = original_value * randf_range(0.1, 0.5) / (split_count - 1)
			
			if new_value != null:
				entity_data["properties"][property_name] = new_value
		
		# Create the split entity
		var split_entity = entity_manager.create_entity(entity_data)
		if split_entity:
			split_entities.append(split_entity)
	
	# Mark the original entity for deletion if all splits were created
	if split_entities.size() == split_count:
		entity_manager.mark_entity_for_deletion(entity.entity_id)
		return true
	
	return false

func _operation_evaluate(context: Dictionary) -> bool:
	var entity = context["entity"]
	var step = context["step"]
	
	if not step.has("property") or not step.has("expression"):
		return false
	
	var property_name = step["property"]
	var expression_text = step["expression"]
	
	# Create expression context with entity properties
	var expr_context = {}
	for prop_name in entity.get_all_property_names():
		expr_context[prop_name] = entity.get_property(prop_name)
	
	# Add context parameters
	for param_name in context:
		if param_name != "entity" and param_name != "step":
			expr_context[param_name] = context[param_name]
	
	# Create and evaluate expression
	var expression = Expression.new()
	var error = expression.parse(expression_text, expr_context.keys())
	if error != OK:
		push_error("Expression parse error: " + expression.get_error_text())
		return false
	
	var result = expression.execute(expr_context.values())
	if expression.has_execute_failed():
		push_error("Expression execute error")
		return false
	
	entity.set_property(property_name, result)
	return true

# Evaluate a condition expression
func _evaluate_condition(condition: Dictionary, entity: JSHUniversalEntity, context: Dictionary) -> bool:
	# Handle different condition types
	
	# Property comparison
	if condition.has("property") and (condition.has("equals") or condition.has("not_equals") or 
									 condition.has("greater_than") or condition.has("less_than")):
		var property_name = condition["property"]
		var property_value = entity.get_property(property_name, null)
		
		if property_value == null:
			return false
		
		if condition.has("equals"):
			var compare_value = _resolve_value(condition["equals"], context)
			return property_value == compare_value
		
		if condition.has("not_equals"):
			var compare_value = _resolve_value(condition["not_equals"], context)
			return property_value != compare_value
		
		if condition.has("greater_than"):
			var compare_value = _resolve_value(condition["greater_than"], context)
			return property_value > compare_value
		
		if condition.has("less_than"):
			var compare_value = _resolve_value(condition["less_than"], context)
			return property_value < compare_value
	
	# Entity type check
	if condition.has("entity_type"):
		var type_value = _resolve_value(condition["entity_type"], context)
		return entity.entity_type == type_value
	
	# Property exists
	if condition.has("has_property"):
		var property_name = _resolve_value(condition["has_property"], context)
		return entity.has_property(property_name)
	
	# Combined conditions
	if condition.has("and"):
		var and_conditions = condition["and"]
		if not and_conditions is Array:
			return false
		
		for subcond in and_conditions:
			if not _evaluate_condition(subcond, entity, context):
				return false
		return true
	
	if condition.has("or"):
		var or_conditions = condition["or"]
		if not or_conditions is Array:
			return false
		
		for subcond in or_conditions:
			if _evaluate_condition(subcond, entity, context):
				return true
		return false
	
	if condition.has("not"):
		return not _evaluate_condition(condition["not"], entity, context)
	
	# Expression condition
	if condition.has("expression"):
		var expression_text = condition["expression"]
		
		# Create expression context with entity properties
		var expr_context = {}
		for prop_name in entity.get_all_property_names():
			expr_context[prop_name] = entity.get_property(prop_name)
		
		# Add context parameters
		for param_name in context:
			if param_name != "entity" and param_name != "step":
				expr_context[param_name] = context[param_name]
		
		# Create and evaluate expression
		var expression = Expression.new()
		var error = expression.parse(expression_text, expr_context.keys())
		if error != OK:
			push_error("Expression parse error: " + expression.get_error_text())
			return false
		
		var result = expression.execute(expr_context.values())
		if expression.has_execute_failed():
			push_error("Expression execute error")
			return false
		
		return bool(result)
	
	return false

# Resolve a value from context if needed
func _resolve_value(value, context: Dictionary):
	if value is String and value.begins_with("$"):
		var param_name = value.substr(1)
		if context.has(param_name):
			return context[param_name]
		return null
	return value