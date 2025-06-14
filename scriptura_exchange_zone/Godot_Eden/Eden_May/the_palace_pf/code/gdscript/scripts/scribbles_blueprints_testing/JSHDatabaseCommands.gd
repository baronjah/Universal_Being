extends Node
class_name JSHDatabaseCommands

# Database system console commands
var console_manager: JSHConsoleManager = null
var database_manager: JSHDatabaseManager = null
var commands: Dictionary = {}

func _init() -> void:
    console_manager = JSHConsoleManager.get_instance()
    database_manager = JSHDatabaseManager.get_instance()
    
    # Register commands
    register_commands()

func register_commands() -> void:
    commands = {
        "db": {
            "description": "Database management commands",
            "usage": "db <subcommand> [arguments]",
            "callback": Callable(self, "cmd_db"),
            "min_args": 1,
            "max_args": -1,
            "arg_types": [TYPE_STRING],
            "arg_descriptions": ["Subcommand: list, info, save, load, delete, stats, compact, backup"]
        },
        "dictionary": {
            "description": "Dictionary management commands",
            "usage": "dictionary <subcommand> [arguments]",
            "callback": Callable(self, "cmd_dictionary"),
            "min_args": 1,
            "max_args": -1,
            "arg_types": [TYPE_STRING],
            "arg_descriptions": ["Subcommand: list, get, save, delete"]
        }
    }
    
    # Register with console manager
    for cmd_name in commands:
        console_manager.register_command(cmd_name, commands[cmd_name])

# Database command handler (main command)
func cmd_db(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Missing subcommand for db")
        return {"success": false, "message": "Missing subcommand"}
    
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1)
    
    match subcommand:
        "list":
            return cmd_db_list(self, subargs)
        "info":
            return cmd_db_info(self, subargs)
        "save":
            return cmd_db_save(self, subargs)
        "load":
            return cmd_db_load(self, subargs)
        "delete":
            return cmd_db_delete(self, subargs)
        "stats":
            return cmd_db_stats(self, subargs)
        "compact":
            return cmd_db_compact(self, subargs)
        "backup":
            return cmd_db_backup(self, subargs)
        _:
            console_manager.print_error("Unknown db subcommand: " + subcommand)
            console_manager.print_line("Available subcommands: list, info, save, load, delete, stats, compact, backup")
            return {"success": false, "message": "Unknown subcommand: " + subcommand}

# Database subcommands
func cmd_db_list(self, args: Array) -> Dictionary:
    var entity_manager = JSHEntityManager.get_instance()
    
    if not entity_manager:
        console_manager.print_error("Entity manager not found")
        return {"success": false, "message": "Entity manager not found"}
    
    var list_type = ""
    if args.size() >= 1:
        list_type = args[0].to_lower()
    
    if list_type.is_empty() or list_type == "entities":
        # List entities in database
        console_manager.print_line("Database entities:")
        
        var stored_entities = []
        var entity_ids = entity_manager.entities.keys()
        
        for id in entity_ids:
            if database_manager.entity_exists(id):
                stored_entities.append(id)
        
        if stored_entities.size() > 0:
            for id in stored_entities:
                var entity = entity_manager.get_entity(id)
                if entity:
                    console_manager.print_line("  " + id.substr(0, 8) + ": " + entity.get_type())
                else:
                    console_manager.print_line("  " + id.substr(0, 8) + ": [not loaded]")
        else:
            console_manager.print_line("  No entities in database")
        
        return {
            "success": true,
            "message": str(stored_entities.size()) + " entities in database",
            "count": stored_entities.size(),
            "entities": stored_entities
        }
    
    elif list_type == "dictionaries":
        # List dictionaries
        console_manager.print_line("Dictionaries:")
        
        var stats = database_manager.get_dictionary("dictionary_stats")
        var dictionaries = []
        
        if stats and stats.has("dictionaries"):
            dictionaries = stats.dictionaries
            
            if dictionaries.size() > 0:
                for dict_name in dictionaries:
                    console_manager.print_line("  " + dict_name)
            else:
                console_manager.print_line("  No dictionaries in database")
        else:
            console_manager.print_line("  No dictionaries in database")
        
        return {
            "success": true,
            "message": str(dictionaries.size()) + " dictionaries in database",
            "count": dictionaries.size(),
            "dictionaries": dictionaries
        }
    
    elif list_type == "zones":
        # List zones
        console_manager.print_line("Zones:")
        
        var spatial_manager = JSHSpatialManager.get_instance()
        var zones = []
        
        if spatial_manager:
            zones = spatial_manager.get_all_zones()
            
            if zones.size() > 0:
                for zone_id in zones:
                    var zone = spatial_manager.get_zone(zone_id)
                    console_manager.print_line("  " + zone_id + ": " + str(zone.name if zone.has("name") else zone_id))
            else:
                console_manager.print_line("  No zones in database")
        else:
            console_manager.print_line("  Spatial manager not found")
        
        return {
            "success": true,
            "message": str(zones.size()) + " zones in database",
            "count": zones.size(),
            "zones": zones
        }
    
    else:
        console_manager.print_error("Unknown list type: " + list_type)
        console_manager.print_line("Valid list types: entities, dictionaries, zones")
        return {"success": false, "message": "Unknown list type"}

func cmd_db_info(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Missing info type (entity/dictionary/zone)")
        return {"success": false, "message": "Missing info type"}
    
    var info_type = args[0].to_lower()
    
    if args.size() < 2:
        console_manager.print_error("Missing identifier")
        return {"success": false, "message": "Missing identifier"}
    
    var identifier = args[1]
    
    match info_type:
        "entity":
            var entity = database_manager.load_entity(identifier)
            
            if entity:
                console_manager.print_line("Database entity info:")
                console_manager.print_line("  ID: " + entity.get_id())
                console_manager.print_line("  Type: " + entity.get_type())
                console_manager.print_line("  Created: " + entity.get_creation_timestamp())
                console_manager.print_line("  Complexity: " + str(entity.complexity))
                console_manager.print_line("  Evolution Stage: " + str(entity.evolution_stage))
                
                return {
                    "success": true,
                    "message": "Entity info displayed",
                    "entity": entity
                }
            else:
                console_manager.print_error("Entity not found in database: " + identifier)
                return {"success": false, "message": "Entity not found"}
        
        "dictionary":
            var dict_name = identifier
            var dict_entry = database_manager.load_dictionary_entry(dict_name, "metadata")
            
            if not dict_entry.is_empty():
                console_manager.print_line("Dictionary info:")
                console_manager.print_line("  Name: " + dict_name)
                
                if dict_entry.has("entries"):
                    console_manager.print_line("  Entries: " + str(dict_entry.entries.size()))
                    
                    for key in dict_entry.entries:
                        var value = dict_entry.entries[key]
                        if typeof(value) == TYPE_DICTIONARY:
                            console_manager.print_line("    " + key + ": " + (value.value if value.has("value") else str(value)))
                        else:
                            console_manager.print_line("    " + key + ": " + str(value))
                
                return {
                    "success": true,
                    "message": "Dictionary info displayed",
                    "dictionary": dict_entry
                }
            else:
                console_manager.print_error("Dictionary not found: " + dict_name)
                return {"success": false, "message": "Dictionary not found"}
        
        "zone":
            var spatial_manager = JSHSpatialManager.get_instance()
            
            if spatial_manager:
                var zone = spatial_manager.get_zone(identifier)
                
                if not zone.is_empty():
                    console_manager.print_line("Zone info:")
                    console_manager.print_line("  ID: " + identifier)
                    console_manager.print_line("  Name: " + str(zone.name if zone.has("name") else identifier))
                    
                    if zone.has("bounds"):
                        var bounds = zone.bounds
                        console_manager.print_line("  Bounds:")
                        console_manager.print_line("    X: " + str(bounds.min_x) + " to " + str(bounds.max_x))
                        console_manager.print_line("    Y: " + str(bounds.min_y) + " to " + str(bounds.max_y))
                        console_manager.print_line("    Z: " + str(bounds.min_z) + " to " + str(bounds.max_z))
                    
                    var entities = spatial_manager.get_entities_in_zone(identifier)
                    console_manager.print_line("  Entities: " + str(entities.size()))
                    
                    return {
                        "success": true,
                        "message": "Zone info displayed",
                        "zone": zone
                    }
                else:
                    console_manager.print_error("Zone not found: " + identifier)
                    return {"success": false, "message": "Zone not found"}
            else:
                console_manager.print_error("Spatial manager not found")
                return {"success": false, "message": "Spatial manager not found"}
        
        _:
            console_manager.print_error("Unknown info type: " + info_type)
            console_manager.print_line("Valid info types: entity, dictionary, zone")
            return {"success": false, "message": "Unknown info type"}

func cmd_db_save(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Missing save type (entity/dictionary/zone/all)")
        return {"success": false, "message": "Missing save type"}
    
    var save_type = args[0].to_lower()
    
    match save_type:
        "entity":
            if args.size() < 2:
                console_manager.print_error("Missing entity ID")
                return {"success": false, "message": "Missing entity ID"}
            
            var entity_id = args[1]
            var entity_manager = JSHEntityManager.get_instance()
            
            if entity_manager:
                var entity = entity_manager.get_entity(entity_id)
                
                if entity:
                    if database_manager.save_entity(entity, true):
                        console_manager.print_success("Entity saved: " + entity_id)
                        return {
                            "success": true,
                            "message": "Entity saved",
                            "entity_id": entity_id
                        }
                    else:
                        console_manager.print_error("Failed to save entity: " + entity_id)
                        return {"success": false, "message": "Failed to save entity"}
                else:
                    console_manager.print_error("Entity not found: " + entity_id)
                    return {"success": false, "message": "Entity not found"}
            else:
                console_manager.print_error("Entity manager not found")
                return {"success": false, "message": "Entity manager not found"}
        
        "all":
            # Save all entities
            var entity_manager = JSHEntityManager.get_instance()
            
            if entity_manager:
                var entities = entity_manager.entities
                var saved_count = 0
                
                for id in entities:
                    var entity = entities[id]
                    if database_manager.save_entity(entity):
                        saved_count += 1
                
                # Force save of pending entities
                database_manager.save_pending_entities()
                
                console_manager.print_success("Saved " + str(saved_count) + " entities")
                return {
                    "success": true,
                    "message": str(saved_count) + " entities saved",
                    "count": saved_count
                }
            else:
                console_manager.print_error("Entity manager not found")
                return {"success": false, "message": "Entity manager not found"}
        
        "dictionary":
            console_manager.print_warning("Dictionary saving not implemented in CLI")
            return {"success": false, "message": "Not implemented"}
        
        "zone":
            console_manager.print_warning("Zone saving not implemented in CLI")
            return {"success": false, "message": "Not implemented"}
        
        _:
            console_manager.print_error("Unknown save type: " + save_type)
            console_manager.print_line("Valid save types: entity, dictionary, zone, all")
            return {"success": false, "message": "Unknown save type"}

func cmd_db_load(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Missing load type (entity)")
        return {"success": false, "message": "Missing load type"}
    
    var load_type = args[0].to_lower()
    
    match load_type:
        "entity":
            if args.size() < 2:
                console_manager.print_error("Missing entity ID")
                return {"success": false, "message": "Missing entity ID"}
            
            var entity_id = args[1]
            
            var entity = database_manager.load_entity(entity_id)
            
            if entity:
                console_manager.print_success("Entity loaded: " + entity_id)
                return {
                    "success": true,
                    "message": "Entity loaded",
                    "entity_id": entity_id,
                    "entity": entity
                }
            else:
                console_manager.print_error("Entity not found in database: " + entity_id)
                return {"success": false, "message": "Entity not found"}
        
        _:
            console_manager.print_error("Unknown load type: " + load_type)
            console_manager.print_line("Valid load types: entity")
            return {"success": false, "message": "Unknown load type"}

func cmd_db_delete(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Missing delete type (entity/dictionary/zone)")
        return {"success": false, "message": "Missing delete type"}
    
    var delete_type = args[0].to_lower()
    
    match delete_type:
        "entity":
            if args.size() < 2:
                console_manager.print_error("Missing entity ID")
                return {"success": false, "message": "Missing entity ID"}
            
            var entity_id = args[1]
            
            if database_manager.delete_entity(entity_id):
                console_manager.print_success("Entity deleted from database: " + entity_id)
                return {
                    "success": true,
                    "message": "Entity deleted",
                    "entity_id": entity_id
                }
            else:
                console_manager.print_error("Failed to delete entity: " + entity_id)
                return {"success": false, "message": "Failed to delete entity"}
        
        _:
            console_manager.print_error("Unknown delete type: " + delete_type)
            console_manager.print_line("Valid delete types: entity")
            return {"success": false, "message": "Unknown delete type"}

func cmd_db_stats(self, args: Array) -> Dictionary:
    var stats = database_manager.get_database_statistics()
    
    console_manager.print_line("Database Statistics:")
    console_manager.print_line("  Entity Count: " + str(stats.entity_count if stats.has("entity_count") else "Unknown"))
    console_manager.print_line("  Dictionary Count: " + str(stats.dictionary_count if stats.has("dictionary_count") else "Unknown"))
    console_manager.print_line("  Zone Count: " + str(stats.zone_count if stats.has("zone_count") else "Unknown"))
    console_manager.print_line("  Total Size: " + str(stats.total_size_bytes / 1024 if stats.has("total_size_bytes") else "Unknown") + " KB")
    
    if stats.has("cache"):
        console_manager.print_line("\nCache:")
        console_manager.print_line("  Entity Cache Size: " + str(stats.cache.entity_cache_size))
        console_manager.print_line("  Entity Cache Limit: " + str(stats.cache.entity_cache_limit))
        console_manager.print_line("  Pending Saves: " + str(stats.cache.pending_saves))
    
    if stats.has("operations"):
        console_manager.print_line("\nOperations:")
        console_manager.print_line("  Reads: " + str(stats.operations.reads))
        console_manager.print_line("  Writes: " + str(stats.operations.writes))
        console_manager.print_line("  Deletes: " + str(stats.operations.deletes))
    
    return {
        "success": true,
        "message": "Database statistics displayed",
        "stats": stats
    }

func cmd_db_compact(self, args: Array) -> Dictionary:
    if database_manager.compact_database():
        console_manager.print_success("Database compacted")
        return {"success": true, "message": "Database compacted"}
    else:
        console_manager.print_error("Failed to compact database")
        return {"success": false, "message": "Failed to compact database"}

func cmd_db_backup(self, args: Array) -> Dictionary:
    var backup_path = "user://database_backup_" + str(Time.get_unix_time_from_system())
    
    if args.size() >= 1:
        backup_path = args[0]
    
    if database_manager.backup_database(backup_path):
        console_manager.print_success("Database backed up to: " + backup_path)
        return {
            "success": true,
            "message": "Database backed up",
            "backup_path": backup_path
        }
    else:
        console_manager.print_error("Failed to backup database")
        return {"success": false, "message": "Failed to backup database"}

# Dictionary command handler
func cmd_dictionary(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Missing subcommand for dictionary")
        return {"success": false, "message": "Missing subcommand"}
    
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1)
    
    match subcommand:
        "list":
            return cmd_dictionary_list(self, subargs)
        "get":
            return cmd_dictionary_get(self, subargs)
        "save":
            return cmd_dictionary_save(self, subargs)
        "delete":
            return cmd_dictionary_delete(self, subargs)
        _:
            console_manager.print_error("Unknown dictionary subcommand: " + subcommand)
            console_manager.print_line("Available subcommands: list, get, save, delete")
            return {"success": false, "message": "Unknown subcommand: " + subcommand}

# Dictionary subcommands
func cmd_dictionary_list(self, args: Array) -> Dictionary:
    # Reuse the db list dictionaries command
    return cmd_db_list(self, ["dictionaries"])

func cmd_dictionary_get(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Missing dictionary name")
        return {"success": false, "message": "Missing dictionary name"}
    
    var dict_name = args[0]
    var dict_data = database_manager.get_dictionary(dict_name)
    
    if not dict_data.is_empty():
        console_manager.print_line("Dictionary: " + dict_name)
        
        for key in dict_data:
            var value = dict_data[key]
            
            if typeof(value) == TYPE_DICTIONARY:
                console_manager.print_line("  " + key + ": [Dictionary]")
            elif typeof(value) == TYPE_ARRAY:
                console_manager.print_line("  " + key + ": [Array: " + str(value.size()) + " items]")
            else:
                console_manager.print_line("  " + key + ": " + str(value))
        
        return {
            "success": true,
            "message": "Dictionary displayed",
            "dictionary": dict_data
        }
    else:
        console_manager.print_error("Dictionary not found: " + dict_name)
        return {"success": false, "message": "Dictionary not found"}

func cmd_dictionary_save(self, args: Array) -> Dictionary:
    console_manager.print_warning("Dictionary saving not implemented in CLI")
    return {"success": false, "message": "Not implemented"}

func cmd_dictionary_delete(self, args: Array) -> Dictionary:
    console_manager.print_warning("Dictionary deletion not implemented in CLI")
    return {"success": false, "message": "Not implemented"}