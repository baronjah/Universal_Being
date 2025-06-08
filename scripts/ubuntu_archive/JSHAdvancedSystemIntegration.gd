extends Node
class_name JSHAdvancedSystemIntegration

# The JSHAdvancedSystemIntegration ties together all the advanced systems
# It provides a unified interface for working with the advanced features

# Singleton instance
static var _instance = null
static func get_instance() -> JSHAdvancedSystemIntegration:
	if not _instance:
		_instance = JSHAdvancedSystemIntegration.new()
	return _instance

# References to all systems
var entity_manager: JSHEntityManager
var database_manager: JSHDatabaseManager
var spatial_manager: JSHSpatialManager
var console_manager: JSHConsoleManager

# Advanced systems
var interaction_matrix: JSHInteractionMatrix
var entity_evolution: JSHEntityEvolution
var data_transformation: JSHDataTransformation
var event_system: JSHEventSystem
var query_language: JSHQueryLanguage

# System state
var is_initialized: bool = false
var update_interval: float = 0.5
var time_accumulator: float = 0.0

# Signals
signal advanced_systems_initialized()
signal advanced_systems_updated()
signal advanced_systems_shutdown()

func _init() -> void:
	# Automatically add to scene tree when instanced
	# This ensures _process will be called
	if not is_instance_valid(_instance):
		_instance = self
		if not is_inside_tree():
			var root = Engine.get_main_loop().root
			if root:
				root.call_deferred("add_child", self)

# Initialize all advanced systems
func initialize() -> void:
	if is_initialized:
		return
	
	print("Initializing JSH Advanced Systems...")
	
	# Get references to base systems
	entity_manager = JSHEntityManager.get_instance()
	database_manager = JSHDatabaseManager.get_instance()
	spatial_manager = JSHSpatialManager.get_instance()
	console_manager = JSHConsoleManager.get_instance()
	
	# Initialize advanced systems
	interaction_matrix = JSHInteractionMatrix.get_instance()
	entity_evolution = JSHEntityEvolution.get_instance()
	data_transformation = JSHDataTransformation.get_instance()
	event_system = JSHEventSystem.get_instance()
	query_language = JSHQueryLanguage.get_instance()
	
	# Register event handlers
	_register_event_handlers()
	
	# Register console commands
	_register_console_commands()
	
	is_initialized = true
	advanced_systems_initialized.emit()
	
	print("JSH Advanced Systems initialized!")

# Shutdown all advanced systems
func shutdown() -> void:
	if not is_initialized:
		return
	
	print("Shutting down JSH Advanced Systems...")
	
	# Unregister event handlers
	_unregister_event_handlers()
	
	# Unregister console commands
	_unregister_console_commands()
	
	is_initialized = false
	advanced_systems_shutdown.emit()
	
	print("JSH Advanced Systems shut down!")

# Process method called every frame
func _process(delta: float) -> void:
	if not is_initialized:
		return
	
	# Accumulate time
	time_accumulator += delta
	
	# Process systems on interval
	if time_accumulator >= update_interval:
		_update_systems(time_accumulator)
		time_accumulator = 0.0

# Update all systems
func _update_systems(delta: float) -> void:
	# Get all entities
	var entities = entity_manager.get_all_entities()
	
	# Process entity interactions
	var interactions_processed = interaction_matrix.process_entity_interactions(entities)
	
	# Process entity evolution
	var evolutions_processed = entity_evolution.process_batch_evolution(entities, delta)
	
	# Emit update event
	advanced_systems_updated.emit()
	
	# Log activity if there were changes
	if interactions_processed > 0 or evolutions_processed > 0:
		print("Updated systems - Interactions: " + str(interactions_processed) + ", Evolutions: " + str(evolutions_processed))

# Register event handlers
func _register_event_handlers() -> void:
	# Entity events
	event_system.subscribe("entity_created", _on_entity_created)
	event_system.subscribe("entity_updated", _on_entity_updated)
	event_system.subscribe("entity_transformed", _on_entity_transformed)
	event_system.subscribe("entity_evolved", _on_entity_evolved)
	
	# System events
	event_system.subscribe("system_initialized", _on_system_initialized)
	event_system.subscribe("system_shutdown", _on_system_shutdown)

# Unregister event handlers
func _unregister_event_handlers() -> void:
	event_system.unsubscribe_all("advanced_integration")

# Register console commands
func _register_console_commands() -> void:
	# Skip if console manager is not available
	if not console_manager:
		return
	
	# Interaction Matrix commands
	console_manager.register_command("interaction.list", _cmd_list_interactions, 
		"Lists all interaction rules", [])
	
	console_manager.register_command("interaction.trigger", _cmd_trigger_interaction, 
		"Triggers an interaction between two entities", [
			{"name": "source_id", "type": "string", "description": "Source entity ID"},
			{"name": "target_id", "type": "string", "description": "Target entity ID"}
		])
	
	# Evolution commands
	console_manager.register_command("evolution.stages", _cmd_list_evolution_stages, 
		"Lists all evolution stages for an entity type", [
			{"name": "entity_type", "type": "string", "description": "Entity type to check"}
		])
	
	console_manager.register_command("evolution.evolve", _cmd_evolve_entity, 
		"Evolves an entity to a specific stage", [
			{"name": "entity_id", "type": "string", "description": "Entity ID to evolve"},
			{"name": "target_stage", "type": "string", "description": "Target evolution stage"}
		])
	
	# Transformation commands
	console_manager.register_command("transform.list", _cmd_list_transformations, 
		"Lists all transformation templates", [])
	
	console_manager.register_command("transform.apply", _cmd_apply_transformation, 
		"Applies a transformation to an entity", [
			{"name": "entity_id", "type": "string", "description": "Entity ID to transform"},
			{"name": "template", "type": "string", "description": "Transformation template name"}
		])
	
	# Query commands
	console_manager.register_command("query.run", _cmd_run_query, 
		"Runs a query using query language", [
			{"name": "query_string", "type": "string", "description": "Query string to execute"}
		])

# Unregister console commands
func _unregister_console_commands() -> void:
	# Skip if console manager is not available
	if not console_manager:
		return
	
	console_manager.unregister_command("interaction.list")
	console_manager.unregister_command("interaction.trigger")
	console_manager.unregister_command("evolution.stages")
	console_manager.unregister_command("evolution.evolve")
	console_manager.unregister_command("transform.list")
	console_manager.unregister_command("transform.apply")
	console_manager.unregister_command("query.run")

# Event handlers
func _on_entity_created(event_name: String, event_data: Dictionary) -> void:
	if not event_data.has("entity_id"):
		return
	
	var entity_id = event_data["entity_id"]
	var entity = entity_manager.get_entity(entity_id)
	
	if entity:
		# Set up entity for evolution
		entity_evolution.initialize_entity_evolution(entity)

func _on_entity_updated(event_name: String, event_data: Dictionary) -> void:
	if not event_data.has("entity_id"):
		return
	
	var entity_id = event_data["entity_id"]
	var entity = entity_manager.get_entity(entity_id)
	
	if entity and entity.complexity > entity.split_threshold:
		# Entity might need to split if complexity is high
		entity.attempt_split()

func _on_entity_transformed(event_name: String, event_data: Dictionary) -> void:
	if not event_data.has("entity_id") or not event_data.has("from_type") or not event_data.has("to_type"):
		return
	
	var entity_id = event_data["entity_id"]
	var from_type = event_data["from_type"]
	var to_type = event_data["to_type"]
	
	print("Entity " + entity_id + " transformed from " + from_type + " to " + to_type)

func _on_entity_evolved(event_name: String, event_data: Dictionary) -> void:
	if not event_data.has("entity_id") or not event_data.has("from_stage") or not event_data.has("to_stage"):
		return
	
	var entity_id = event_data["entity_id"]
	var from_stage = event_data["from_stage"]
	var to_stage = event_data["to_stage"]
	
	print("Entity " + entity_id + " evolved from " + from_stage + " to " + to_stage)

func _on_system_initialized(event_name: String, event_data: Dictionary) -> void:
	if not event_data.has("system_name"):
		return
	
	var system_name = event_data["system_name"]
	print("System initialized: " + system_name)

func _on_system_shutdown(event_name: String, event_data: Dictionary) -> void:
	if not event_data.has("system_name"):
		return
	
	var system_name = event_data["system_name"]
	print("System shut down: " + system_name)

# Console command handlers
func _cmd_list_interactions(args: Array) -> String:
	var response = "Interaction rules:\n"
	
	var entity_types = []
	var all_entities = entity_manager.get_all_entities()
	
	for entity in all_entities:
		if not entity.entity_type in entity_types:
			entity_types.append(entity.entity_type)
	
	for source_type in entity_types:
		var target_types = interaction_matrix.get_interaction_targets_for_type(source_type)
		
		if not target_types.is_empty():
			response += "\n" + source_type + " interacts with:\n"
			
			for target_type in target_types:
				var rules = interaction_matrix.get_interaction_rules(source_type, target_type)
				response += "  - " + target_type + " (" + str(rules.size()) + " rules)\n"
	
	return response

func _cmd_trigger_interaction(args: Array) -> String:
	if args.size() < 2:
		return "Error: Missing entity IDs"
	
	var source_id = args[0]
	var target_id = args[1]
	
	var source_entity = entity_manager.get_entity(source_id)
	var target_entity = entity_manager.get_entity(target_id)
	
	if not source_entity:
		return "Error: Source entity not found: " + source_id
	
	if not target_entity:
		return "Error: Target entity not found: " + target_id
	
	var interaction_happened = interaction_matrix.process_interaction(source_entity, target_entity)
	
	if interaction_happened:
		return "Interaction successfully triggered between " + source_entity.entity_type + " and " + target_entity.entity_type
	else:
		return "No interaction occurred between " + source_entity.entity_type + " and " + target_entity.entity_type

func _cmd_list_evolution_stages(args: Array) -> String:
	if args.is_empty():
		var response = "Evolution stages for all entity types:\n"
		var evolvable_types = entity_evolution.get_evolvable_entity_types()
		
		for entity_type in evolvable_types:
			response += "\n" + entity_type + " stages:\n"
			var stages = entity_evolution.get_stages_for_entity_type(entity_type)
			
			for stage_name in stages:
				var stage_info = entity_evolution.get_stage_info(entity_type, stage_name)
				response += "  - " + stage_name + " (index: " + str(stage_info["stage_index"]) + ")\n"
		
		return response
	else:
		var entity_type = args[0]
		var response = "Evolution stages for " + entity_type + ":\n"
		var stages = entity_evolution.get_stages_for_entity_type(entity_type)
		
		if stages.is_empty():
			return "No evolution stages defined for " + entity_type
		
		for stage_name in stages:
			var stage_info = entity_evolution.get_stage_info(entity_type, stage_name)
			response += "  - " + stage_name + " (index: " + str(stage_info["stage_index"]) + ")\n"
			
			if not stage_info["transforms_to"].is_empty():
				response += "    Transforms to: " + stage_info["transforms_to"] + "\n"
			
			response += "    Required complexity: " + str(stage_info["required_complexity"]) + "\n"
			
			if not stage_info["requirements"].is_empty():
				response += "    Requirements:\n"
				for req_name in stage_info["requirements"]:
					response += "      - " + req_name + ": " + str(stage_info["requirements"][req_name]) + "\n"
			
			if not stage_info["next_stages"].is_empty():
				response += "    Next stages: " + ", ".join(stage_info["next_stages"]) + "\n"
		
		return response

func _cmd_evolve_entity(args: Array) -> String:
	if args.size() < 2:
		return "Error: Missing entity ID or target stage"
	
	var entity_id = args[0]
	var target_stage = args[1]
	
	var entity = entity_manager.get_entity(entity_id)
	
	if not entity:
		return "Error: Entity not found: " + entity_id
	
	var can_evolve = entity_evolution.can_evolve_to_stage(entity, target_stage)
	
	if not can_evolve:
		return "Error: Entity cannot evolve to stage " + target_stage + " (requirements not met)"
	
	var evolution_successful = entity_evolution.evolve_entity_to_stage(entity, target_stage)
	
	if evolution_successful:
		return "Entity " + entity_id + " successfully evolved to " + target_stage
	else:
		return "Failed to evolve entity " + entity_id + " to " + target_stage

func _cmd_list_transformations(args: Array) -> String:
	var response = "Transformation templates:\n"
	var templates = data_transformation.get_available_templates()
	
	for template_name in templates:
		var template_info = data_transformation.get_template_info(template_name)
		response += "\n" + template_name + ":\n"
		response += "  Description: " + template_info["description"] + "\n"
		response += "  Steps: " + str(template_info["steps_count"]) + "\n"
		
		if not template_info["applies_to_types"].is_empty():
			response += "  Applies to: " + ", ".join(template_info["applies_to_types"]) + "\n"
	
	return response

func _cmd_apply_transformation(args: Array) -> String:
	if args.size() < 2:
		return "Error: Missing entity ID or template name"
	
	var entity_id = args[0]
	var template_name = args[1]
	
	var entity = entity_manager.get_entity(entity_id)
	
	if not entity:
		return "Error: Entity not found: " + entity_id
	
	var templates = data_transformation.get_available_templates()
	
	if not template_name in templates:
		return "Error: Template not found: " + template_name
	
	var parameters = {}
	
	if args.size() > 2:
		# Parse additional parameters
		for i in range(2, args.size(), 2):
			if i + 1 < args.size():
				parameters[args[i]] = _parse_parameter_value(args[i + 1])
	
	var transformation_successful = data_transformation.apply_transformation(template_name, entity, parameters)
	
	if transformation_successful:
		return "Transformation " + template_name + " successfully applied to entity " + entity_id
	else:
		return "Failed to apply transformation " + template_name + " to entity " + entity_id

func _cmd_run_query(args: Array) -> String:
	if args.is_empty():
		return "Error: Missing query string"
	
	var query_string = " ".join(args)
	var query = query_language.parse_query_string(query_string)
	var results = query_language.execute_query(query)
	
	var response = "Query executed: " + query_string + "\n"
	response += "Results: " + str(results.size()) + "\n\n"
	
	if results.is_empty():
		response += "No results found."
		return response
	
	# Check if results are entities or dictionaries (from projection)
	if results[0] is Dictionary:
		// Handle projection results
		for i in range(min(results.size(), 10)):
			response += "Result " + str(i + 1) + ":\n"
			for key in results[i]:
				response += "  " + key + ": " + str(results[i][key]) + "\n"
	else:
		// Handle entity results
		for i in range(min(results.size(), 10)):
			var entity = results[i]
			response += "Result " + str(i + 1) + ": " + entity.entity_type + " (ID: " + entity.entity_id + ")\n"
	
	if results.size() > 10:
		response += "\n(Showing 10 of " + str(results.size()) + " results)"
	
	return response

# Helper function to parse parameter values
func _parse_parameter_value(value_str: String):
	# Try to parse as number
	if value_str.is_valid_int():
		return int(value_str)
	
	if value_str.is_valid_float():
		return float(value_str)
	
	# Handle booleans
	if value_str.to_lower() == "true":
		return true
	
	if value_str.to_lower() == "false":
		return false
	
	# Handle null
	if value_str.to_lower() == "null":
		return null
	
	# Default to string
	return value_str