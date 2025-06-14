extends Node
class_name JSHEntityCommands

# Entity system console commands
var console_manager: JSHConsoleManager = null
var entity_manager: JSHEntityManager = null
var commands: Dictionary = {}

func _init() -> void:
    console_manager = JSHConsoleManager.get_instance()
    entity_manager = JSHEntityManager.get_instance()
    
    # Register commands
    register_commands()

func register_commands() -> void:
    commands = {
        "entity": {
            "description": "Entity management commands",
            "usage": "entity <subcommand> [arguments]",
            "callback": Callable(self, "cmd_entity"),
            "min_args": 1,
            "max_args": -1,
            "arg_types": [TYPE_STRING],
            "arg_descriptions": ["Subcommand: list, create, delete, info, find, tag, stats"]
        },
        "entities": {
            "description": "List all entities or filter by type/tag",
            "usage": "entities [type/tag] [value]",
            "callback": Callable(self, "cmd_entities"),
            "min_args": 0,
            "max_args": 2,
            "arg_types": [TYPE_STRING, TYPE_STRING],
            "arg_descriptions": ["Filter type (type/tag)", "Filter value"]
        }
    }
    
    # Register with console manager
    for cmd_name in commands:
        console_manager.register_command(cmd_name, commands[cmd_name])

# Entity command handler (main command)
func cmd_entity(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Missing subcommand for entity")
        return {"success": false, "message": "Missing subcommand"}
    
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1)
    
    match subcommand:
        "list":
            return cmd_entity_list(self, subargs)
        "create":
            return cmd_entity_create(self, subargs)
        "delete":
            return cmd_entity_delete(self, subargs)
        "info":
            return cmd_entity_info(self, subargs)
        "find":
            return cmd_entity_find(self, subargs)
        "tag":
            return cmd_entity_tag(self, subargs)
        "stats":
            return cmd_entity_stats(self, subargs)
        _:
            console_manager.print_error("Unknown entity subcommand: " + subcommand)
            console_manager.print_line("Available subcommands: list, create, delete, info, find, tag, stats")
            return {"success": false, "message": "Unknown subcommand: " + subcommand}

# Entity subcommands
func cmd_entity_list(self, args: Array) -> Dictionary:
    var filter_type = ""
    var filter_value = ""
    
    if args.size() >= 1:
        filter_type = args[0].to_lower()
    
    if args.size() >= 2:
        filter_value = args[1]
    
    var entities = []
    
    if filter_type == "type" and not filter_value.is_empty():
        entities = entity_manager.get_entities_by_type(filter_value)
    elif filter_type == "tag" and not filter_value.is_empty():
        entities = entity_manager.get_entities_by_tag(filter_value)
    else:
        # Get all entities
        for id in entity_manager.entities:
            entities.append(entity_manager.entities[id])
    
    console_manager.print_line("Entities" + (": " + str(entities.size()) if entities.size() > 0 else " (none)"))
    
    for entity in entities:
        var tags = ""
        if entity.get_tags().size() > 0:
            tags = " [" + ", ".join(entity.get_tags()) + "]"
        
        console_manager.print_line("  " + entity.get_id().substr(0, 8) + ": " + entity.get_type() + tags)
    
    return {
        "success": true,
        "message": str(entities.size()) + " entities found",
        "count": entities.size(),
        "entities": entities
    }

func cmd_entity_create(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Entity type required")
        return {"success": false, "message": "Entity type required"}
    
    var entity_type = args[0]
    var properties = {}
    
    # Parse properties
    for i in range(1, args.size()):
        var prop = args[i].split("=")
        if prop.size() == 2:
            var key = prop[0].strip_edges()
            var value = prop[1].strip_edges()
            
            # Try to convert value to number if possible
            if value.is_valid_int():
                properties[key] = int(value)
            elif value.is_valid_float():
                properties[key] = float(value)
            else:
                properties[key] = value
    
    # Create entity
    var entity = entity_manager.create_entity(entity_type, properties)
    
    if entity:
        console_manager.print_success("Created entity: " + entity.get_id())
        console_manager.print_line("Type: " + entity.get_type())
        console_manager.print_line("Properties: " + str(properties))
        
        return {
            "success": true,
            "message": "Entity created",
            "entity_id": entity.get_id(),
            "entity": entity
        }
    else:
        console_manager.print_error("Failed to create entity")
        return {"success": false, "message": "Failed to create entity"}

func cmd_entity_delete(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Entity ID required")
        return {"success": false, "message": "Entity ID required"}
    
    var entity_id = args[0]
    
    # Find entity with ID or partial ID
    var full_id = entity_id
    if entity_id.length() < 32:  # Not a full ID, try to find matching entity
        for id in entity_manager.entities:
            if id.begins_with(entity_id):
                full_id = id
                break
    
    # Delete entity
    if entity_manager.unregister_entity(full_id):
        console_manager.print_success("Deleted entity: " + full_id)
        return {"success": true, "message": "Entity deleted", "entity_id": full_id}
    else:
        console_manager.print_error("Entity not found: " + entity_id)
        return {"success": false, "message": "Entity not found"}

func cmd_entity_info(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Entity ID required")
        return {"success": false, "message": "Entity ID required"}
    
    var entity_id = args[0]
    
    # Find entity with ID or partial ID
    var full_id = entity_id
    if entity_id.length() < 32:  # Not a full ID, try to find matching entity
        for id in entity_manager.entities:
            if id.begins_with(entity_id):
                full_id = id
                break
    
    # Get entity info
    var entity = entity_manager.get_entity(full_id)
    
    if entity:
        console_manager.print_line("Entity: " + entity.get_id())
        console_manager.print_line("Type: " + entity.get_type())
        console_manager.print_line("Creation Time: " + entity.get_creation_timestamp())
        console_manager.print_line("Complexity: " + str(entity.complexity))
        console_manager.print_line("Evolution Stage: " + str(entity.evolution_stage))
        
        # Properties
        var properties = entity.get_properties()
        console_manager.print_line("\nProperties:")
        for key in properties:
            console_manager.print_line("  " + key + ": " + str(properties[key]))
        
        # Tags
        var tags = entity.get_tags()
        console_manager.print_line("\nTags:")
        if tags.size() > 0:
            for tag in tags:
                console_manager.print_line("  " + tag)
        else:
            console_manager.print_line("  None")
        
        # Zones
        var zones = entity.get_zones()
        console_manager.print_line("\nZones:")
        if zones.size() > 0:
            for zone in zones:
                console_manager.print_line("  " + zone)
        else:
            console_manager.print_line("  None")
        
        # References
        var references = entity.get_references()
        console_manager.print_line("\nReferences:")
        if references.size() > 0:
            for ref_type in references:
                console_manager.print_line("  " + ref_type + ": " + str(references[ref_type].size()) + " references")
        else:
            console_manager.print_line("  None")
        
        return {
            "success": true,
            "message": "Entity info displayed",
            "entity": entity
        }
    else:
        console_manager.print_error("Entity not found: " + entity_id)
        return {"success": false, "message": "Entity not found"}

func cmd_entity_find(self, args: Array) -> Dictionary:
    if args.size() < 2:
        console_manager.print_error("Search criteria required (type/property/tag/zone value)")
        return {"success": false, "message": "Search criteria required"}
    
    var search_type = args[0].to_lower()
    var search_value = args[1]
    
    var entities = []
    
    match search_type:
        "type":
            entities = entity_manager.get_entities_by_type(search_value)
        "tag":
            entities = entity_manager.get_entities_by_tag(search_value)
        "property":
            if args.size() < 3:
                console_manager.print_error("Property value required")
                return {"success": false, "message": "Property value required"}
            
            var property_name = search_value
            var property_value = args[2]
            
            # Convert value to number if possible
            if property_value.is_valid_int():
                property_value = int(property_value)
            elif property_value.is_valid_float():
                property_value = float(property_value)
            
            # Search all entities with matching property
            for id in entity_manager.entities:
                var entity = entity_manager.entities[id]
                if entity.get_property(property_name) == property_value:
                    entities.append(entity)
        _:
            console_manager.print_error("Unknown search type: " + search_type)
            console_manager.print_line("Valid search types: type, tag, property")
            return {"success": false, "message": "Unknown search type"}
    
    console_manager.print_line("Found " + str(entities.size()) + " entities matching " + search_type + "=" + search_value)
    
    for entity in entities:
        console_manager.print_line("  " + entity.get_id().substr(0, 8) + ": " + entity.get_type())
    
    return {
        "success": true,
        "message": str(entities.size()) + " entities found",
        "count": entities.size(),
        "entities": entities
    }

func cmd_entity_tag(self, args: Array) -> Dictionary:
    if args.size() < 3:
        console_manager.print_error("Usage: entity tag add/remove <entity_id> <tag>")
        return {"success": false, "message": "Invalid arguments"}
    
    var action = args[0].to_lower()
    var entity_id = args[1]
    var tag = args[2]
    
    # Find entity with ID or partial ID
    var full_id = entity_id
    if entity_id.length() < 32:  # Not a full ID, try to find matching entity
        for id in entity_manager.entities:
            if id.begins_with(entity_id):
                full_id = id
                break
    
    # Get entity
    var entity = entity_manager.get_entity(full_id)
    
    if not entity:
        console_manager.print_error("Entity not found: " + entity_id)
        return {"success": false, "message": "Entity not found"}
    
    match action:
        "add":
            if entity.add_tag(tag):
                console_manager.print_success("Added tag '" + tag + "' to entity " + entity.get_id().substr(0, 8))
                return {
                    "success": true,
                    "message": "Tag added",
                    "entity": entity,
                    "tag": tag
                }
            else:
                console_manager.print_warning("Entity already has tag '" + tag + "'")
                return {
                    "success": false,
                    "message": "Tag already exists",
                    "entity": entity,
                    "tag": tag
                }
        
        "remove":
            if entity.remove_tag(tag):
                console_manager.print_success("Removed tag '" + tag + "' from entity " + entity.get_id().substr(0, 8))
                return {
                    "success": true,
                    "message": "Tag removed",
                    "entity": entity,
                    "tag": tag
                }
            else:
                console_manager.print_warning("Entity does not have tag '" + tag + "'")
                return {
                    "success": false,
                    "message": "Tag does not exist",
                    "entity": entity,
                    "tag": tag
                }
        
        _:
            console_manager.print_error("Unknown tag action: " + action)
            console_manager.print_line("Valid actions: add, remove")
            return {"success": false, "message": "Unknown tag action"}

func cmd_entity_stats(self, args: Array) -> Dictionary:
    var stats = entity_manager.get_statistics()
    
    console_manager.print_line("Entity System Statistics:")
    console_manager.print_line("  Total Entities: " + str(stats.total_entities))
    console_manager.print_line("  Process Queue: " + str(stats.process_queue_size))
    console_manager.print_line("  Average Complexity: " + str(snappedf(stats.average_complexity, 0.01)))
    
    console_manager.print_line("\nEntities by Type:")
    for type in stats.by_type:
        console_manager.print_line("  " + type + ": " + str(stats.by_type[type]))
    
    console_manager.print_line("\nEntities by Evolution Stage:")
    for stage in stats.by_evolution_stage:
        console_manager.print_line("  Stage " + stage + ": " + str(stats.by_evolution_stage[stage]))
    
    return {
        "success": true,
        "message": "Entity statistics displayed",
        "stats": stats
    }

# Entities command handler
func cmd_entities(self, args: Array) -> Dictionary:
    # This is a shorthand for entity list
    return cmd_entity_list(self, args)