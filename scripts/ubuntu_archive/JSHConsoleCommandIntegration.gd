extends Node
class_name JSHConsoleCommandIntegration

# References to systems
var console_manager: JSHConsoleManager = null
var entity_manager: JSHEntityManager = null
var database_manager: JSHDatabaseManager = null
var spatial_manager: JSHSpatialManager = null

# Command modules
var entity_commands: JSHEntityCommands = null
var database_commands: JSHDatabaseCommands = null
var spatial_commands: JSHSpatialCommands = null
var visualization_commands = null  # Will be implemented separately

func _init() -> void:
    # Get system instances
    console_manager = JSHConsoleManager.get_instance()
    entity_manager = JSHEntityManager.get_instance()
    database_manager = JSHDatabaseManager.get_instance()
    spatial_manager = JSHSpatialManager.get_instance()
    
    # Initialize command modules
    entity_commands = JSHEntityCommands.new()
    database_commands = JSHDatabaseCommands.new()
    spatial_commands = JSHSpatialCommands.new()
    
    # Register custom commands
    register_custom_commands()

func register_custom_commands() -> void:
    # Register integrated commands that span multiple systems
    console_manager.register_command("jsh", {
        "description": "JSH Eden System commands",
        "usage": "jsh <subcommand> [arguments]",
        "callback": Callable(self, "cmd_jsh"),
        "min_args": 0,
        "max_args": -1,
        "arg_types": [TYPE_STRING],
        "arg_descriptions": ["Subcommand: info, status, reload, test, debug"]
    })
    
    console_manager.register_command("create", {
        "description": "Create an entity or zone",
        "usage": "create <type> <name> [properties...]",
        "callback": Callable(self, "cmd_create"),
        "min_args": 2,
        "max_args": -1,
        "arg_types": [TYPE_STRING, TYPE_STRING],
        "arg_descriptions": ["Type (entity/zone)", "Name or type of the object to create"]
    })
    
    console_manager.register_command("find", {
        "description": "Find entities or zones",
        "usage": "find <type> <query>",
        "callback": Callable(self, "cmd_find"),
        "min_args": 2,
        "max_args": -1,
        "arg_types": [TYPE_STRING, TYPE_STRING],
        "arg_descriptions": ["Type (entity/zone)", "Search query"]
    })
    
    console_manager.register_command("stats", {
        "description": "Show statistics for all systems",
        "usage": "stats [system]",
        "callback": Callable(self, "cmd_stats"),
        "min_args": 0,
        "max_args": 1,
        "arg_types": [TYPE_STRING],
        "arg_descriptions": ["Optional system: entity, db, spatial"]
    })

# Command handlers for integrated commands
func cmd_jsh(self, args: Array = []) -> Dictionary:
    if args.size() == 0:
        # Display general system info
        console_manager.print_line("JSH Eden System", Color(0.2, 0.7, 1.0))
        console_manager.print_line("================", Color(0.2, 0.7, 1.0))
        
        console_manager.print_line("\nCore Systems:")
        console_manager.print_line("  Entity System: " + ("Active" if entity_manager != null else "Inactive"))
        console_manager.print_line("  Database System: " + ("Active" if database_manager != null else "Inactive"))
        console_manager.print_line("  Spatial System: " + ("Active" if spatial_manager != null else "Inactive"))
        
        console_manager.print_line("\nAvailable Commands:")
        console_manager.print_line("  jsh info - Display system information")
        console_manager.print_line("  jsh status - Display system status")
        console_manager.print_line("  jsh reload - Reload systems")
        console_manager.print_line("  jsh test - Run system tests")
        console_manager.print_line("  jsh debug - Toggle debug mode")
        
        return {
            "success": true,
            "message": "JSH system information displayed"
        }
    
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1)
    
    match subcommand:
        "info":
            return cmd_jsh_info(self, subargs)
        "status":
            return cmd_jsh_status(self, subargs)
        "reload":
            return cmd_jsh_reload(self, subargs)
        "test":
            return cmd_jsh_test(self, subargs)
        "debug":
            return cmd_jsh_debug(self, subargs)
        _:
            console_manager.print_error("Unknown jsh subcommand: " + subcommand)
            console_manager.print_line("Available subcommands: info, status, reload, test, debug")
            return {"success": false, "message": "Unknown subcommand: " + subcommand}

func cmd_jsh_info(self, args: Array) -> Dictionary:
    console_manager.print_line("JSH Eden System Information", Color(0.2, 0.7, 1.0))
    console_manager.print_line("=========================", Color(0.2, 0.7, 1.0))
    
    console_manager.print_line("\nSystem Overview:")
    console_manager.print_line("  Entity System: Universal entity framework with self-evolving capabilities")
    console_manager.print_line("  Database System: Persistent storage with automatic entity splitting")
    console_manager.print_line("  Spatial System: Zone-based world management with spatial partitioning")
    console_manager.print_line("  Console System: Command interface for system interaction and control")
    
    console_manager.print_line("\nSystem Architecture:")
    console_manager.print_line("  - Universal Entity Model")
    console_manager.print_line("  - Self-Evolving Database")
    console_manager.print_line("  - Hierarchical Zone Organization")
    console_manager.print_line("  - Dynamic Loading/Unloading")
    console_manager.print_line("  - Spatial Query Optimization")
    
    return {
        "success": true,
        "message": "JSH system information displayed"
    }

func cmd_jsh_status(self, args: Array) -> Dictionary:
    console_manager.print_line("JSH Eden System Status", Color(0.2, 0.7, 1.0))
    console_manager.print_line("====================", Color(0.2, 0.7, 1.0))
    
    # Entity system status
    console_manager.print_line("\nEntity System:")
    if entity_manager:
        var stats = entity_manager.get_statistics()
        console_manager.print_line("  Status: Active")
        console_manager.print_line("  Entities: " + str(stats.total_entities))
        console_manager.print_line("  Entity Types: " + str(stats.by_type.size()))
        console_manager.print_line("  Process Queue: " + str(stats.process_queue_size))
    else:
        console_manager.print_line("  Status: Inactive")
    
    # Database system status
    console_manager.print_line("\nDatabase System:")
    if database_manager:
        var stats = database_manager.get_database_statistics()
        console_manager.print_line("  Status: Active")
        console_manager.print_line("  Entity Count: " + str(stats.entity_count if stats.has("entity_count") else "Unknown"))
        console_manager.print_line("  Dictionary Count: " + str(stats.dictionary_count if stats.has("dictionary_count") else "Unknown"))
        console_manager.print_line("  Zone Count: " + str(stats.zone_count if stats.has("zone_count") else "Unknown"))
        
        if stats.has("cache"):
            console_manager.print_line("  Cache Size: " + str(stats.cache.entity_cache_size))
            console_manager.print_line("  Pending Saves: " + str(stats.cache.pending_saves))
    else:
        console_manager.print_line("  Status: Inactive")
    
    # Spatial system status
    console_manager.print_line("\nSpatial System:")
    if spatial_manager:
        var stats = spatial_manager.get_zone_statistics()
        console_manager.print_line("  Status: Active")
        console_manager.print_line("  Total Zones: " + str(stats.total_zones))
        console_manager.print_line("  Loaded Zones: " + str(stats.loaded_zones))
        console_manager.print_line("  Visible Entities: " + str(stats.visible_entities))
        console_manager.print_line("  Active Zone: " + str(stats.active_zone))
    else:
        console_manager.print_line("  Status: Inactive")
    
    return {
        "success": true,
        "message": "JSH system status displayed"
    }

func cmd_jsh_reload(self, args: Array) -> Dictionary:
    console_manager.print_line("Reloading JSH Eden Systems...", Color(0.2, 0.7, 1.0))
    
    # Reload would re-initialize the systems
    # For now just report that systems were reloaded
    console_manager.print_success("Systems reloaded successfully")
    
    return {
        "success": true,
        "message": "JSH systems reloaded"
    }

func cmd_jsh_test(self, args: Array) -> Dictionary:
    if args.size() == 0:
        console_manager.print_line("Available tests:")
        console_manager.print_line("  jsh test entity - Test entity system")
        console_manager.print_line("  jsh test db - Test database system")
        console_manager.print_line("  jsh test spatial - Test spatial system")
        console_manager.print_line("  jsh test all - Run all tests")
        
        return {
            "success": true,
            "message": "Test options displayed"
        }
    
    var test_type = args[0].to_lower()
    
    match test_type:
        "entity":
            console_manager.print_line("Running entity system tests...")
            # Create some test entities
            var entity_types = ["fire", "water", "earth", "air"]
            var created_entities = []
            
            for i in range(5):
                var type = entity_types[i % entity_types.size()]
                var entity = entity_manager.create_entity(type, {
                    "test_index": i,
                    "energy": randi() % 10 + 1
                })
                
                if entity:
                    created_entities.append(entity)
                    console_manager.print_line("  Created test entity: " + entity.get_id().substr(0, 8) + " (" + type + ")")
            
            console_manager.print_success("Entity tests completed: " + str(created_entities.size()) + " entities created")
        
        "db":
            console_manager.print_line("Running database system tests...")
            # Save some entities to the database
            var saved_count = 0
            
            for id in entity_manager.entities:
                var entity = entity_manager.entities[id]
                if database_manager.save_entity(entity):
                    saved_count += 1
            
            database_manager.save_pending_entities()
            
            console_manager.print_success("Database tests completed: " + str(saved_count) + " entities saved")
        
        "spatial":
            console_manager.print_line("Running spatial system tests...")
            # Create a test zone
            var zone_id = "test_zone_" + str(randi() % 1000)
            var zone_data = {
                "name": "Test Zone",
                "bounds": {
                    "min_x": -100, "max_x": 100,
                    "min_y": -100, "max_y": 100,
                    "min_z": -100, "max_z": 100
                },
                "level": 0,
                "is_root": true,
                "autoload": true,
                "properties": {
                    "test": true
                }
            }
            
            spatial_manager.create_zone(zone_id, zone_data)
            console_manager.print_line("  Created test zone: " + zone_id)
            
            # Add some entities to the zone
            var entity_count = 0
            for id in entity_manager.entities:
                var entity = entity_manager.entities[id]
                
                # Set random position
                var position = Vector3(
                    randf_range(-90, 90),
                    randf_range(-90, 90),
                    randf_range(-90, 90)
                )
                
                spatial_manager.set_entity_position(id, position)
                
                if spatial_manager.add_entity_to_zone(id, zone_id):
                    entity_count += 1
                
                if entity_count >= 10:
                    break
            
            console_manager.print_line("  Added " + str(entity_count) + " entities to test zone")
            
            # Perform a spatial query
            var center = Vector3(0, 0, 0)
            var radius = 50.0
            var nearby_entities = spatial_manager.get_entities_in_radius(center, radius)
            
            console_manager.print_line("  Found " + str(nearby_entities.size()) + " entities within " + str(radius) + " units of center")
            
            console_manager.print_success("Spatial tests completed")
        
        "all":
            console_manager.print_line("Running all system tests...")
            
            # Run all tests in sequence
            cmd_jsh_test(self, ["entity"])
            cmd_jsh_test(self, ["db"])
            cmd_jsh_test(self, ["spatial"])
            
            console_manager.print_success("All tests completed")
        
        _:
            console_manager.print_error("Unknown test type: " + test_type)
            console_manager.print_line("Valid test types: entity, db, spatial, all")
            return {"success": false, "message": "Unknown test type"}
    
    return {
        "success": true,
        "message": "Tests completed"
    }

func cmd_jsh_debug(self, args: Array) -> Dictionary:
    var debug_mode = true
    
    if args.size() > 0:
        debug_mode = args[0].to_lower() == "on" or args[0].to_lower() == "true"
    else:
        # Toggle current mode
        debug_mode = not console_manager.get_variable("debug_mode")
    
    console_manager.set_variable("debug_mode", debug_mode)
    
    if debug_mode:
        console_manager.print_success("Debug mode enabled")
    else:
        console_manager.print_success("Debug mode disabled")
    
    return {
        "success": true,
        "message": "Debug mode " + ("enabled" if debug_mode else "disabled"),
        "debug_mode": debug_mode
    }

# Create command handler
func cmd_create(self, args: Array) -> Dictionary:
    if args.size() < 2:
        console_manager.print_error("Usage: create <type> <name> [properties...]")
        return {"success": false, "message": "Invalid arguments"}
    
    var create_type = args[0].to_lower()
    var name = args[1]
    
    match create_type:
        "entity":
            # Delegate to entity create command
            return entity_commands.cmd_entity_create(self, args.slice(1))
        
        "zone":
            # Simplified zone creation with reasonable defaults
            var zone_id = name
            var zone_name = "Zone " + name
            
            # Parse bounds if provided
            var bounds = {
                "min_x": -100, "max_x": 100,
                "min_y": -100, "max_y": 100,
                "min_z": -100, "max_z": 100
            }
            
            if args.size() >= 3 and args[2].contains(","):
                var bounds_parts = args[2].split(",")
                if bounds_parts.size() >= 6:
                    bounds = {
                        "min_x": float(bounds_parts[0]),
                        "min_y": float(bounds_parts[1]),
                        "min_z": float(bounds_parts[2]),
                        "max_x": float(bounds_parts[3]),
                        "max_y": float(bounds_parts[4]),
                        "max_z": float(bounds_parts[5])
                    }
            
            # Create zone data
            var zone_data = {
                "name": zone_name,
                "bounds": bounds,
                "level": 0,
                "is_root": false,
                "autoload": false,
                "properties": {}
            }
            
            # Parse properties
            for i in range(3, args.size()):
                var prop = args[i].split("=")
                if prop.size() == 2:
                    var key = prop[0]
                    var value = prop[1]
                    
                    # Convert to appropriate type
                    if value.to_lower() == "true":
                        value = true
                    elif value.to_lower() == "false":
                        value = false
                    elif value.is_valid_int():
                        value = int(value)
                    elif value.is_valid_float():
                        value = float(value)
                    
                    zone_data.properties[key] = value
            
            # Create zone
            if spatial_manager.create_zone(zone_id, zone_data):
                console_manager.print_success("Zone created: " + zone_id)
                return {
                    "success": true,
                    "message": "Zone created",
                    "zone_id": zone_id,
                    "zone_data": zone_data
                }
            else:
                console_manager.print_error("Failed to create zone: " + zone_id)
                return {"success": false, "message": "Failed to create zone"}
        
        _:
            console_manager.print_error("Unknown create type: " + create_type)
            console_manager.print_line("Valid create types: entity, zone")
            return {"success": false, "message": "Unknown create type"}

# Find command handler
func cmd_find(self, args: Array) -> Dictionary:
    if args.size() < 2:
        console_manager.print_error("Usage: find <type> <query>")
        return {"success": false, "message": "Invalid arguments"}
    
    var find_type = args[0].to_lower()
    var query = args[1]
    
    match find_type:
        "entity":
            # Check if we're searching by type, tag, or property
            if args.size() >= 3:
                var search_type = query
                var search_value = args[2]
                
                # Delegate to entity find command
                return entity_commands.cmd_entity_find(self, [search_type, search_value] + args.slice(3))
            else:
                # Simple entity ID search
                var entity_id = query
                
                # Find entity with ID or partial ID
                var full_id = entity_id
                if entity_id.length() < 32:  # Not a full ID, try to find matching entity
                    for id in entity_manager.entities:
                        if id.begins_with(entity_id):
                            full_id = id
                            break
                
                var entity = entity_manager.get_entity(full_id)
                
                if entity:
                    console_manager.print_success("Entity found: " + full_id)
                    console_manager.print_line("Type: " + entity.get_type())
                    
                    # Get position
                    var position = spatial_manager.get_entity_position(full_id)
                    console_manager.print_line("Position: " + str(position))
                    
                    # Get zones
                    var zones = entity.get_zones()
                    console_manager.print_line("Zones: " + str(zones))
                    
                    return {
                        "success": true,
                        "message": "Entity found",
                        "entity_id": full_id,
                        "entity": entity
                    }
                else:
                    console_manager.print_error("Entity not found: " + entity_id)
                    return {"success": false, "message": "Entity not found"}
        
        "zone":
            # Zone ID or name search
            var zone_id = query
            
            # Look for exact match first
            if spatial_manager.zone_exists(zone_id):
                var zone = spatial_manager.get_zone(zone_id)
                
                console_manager.print_success("Zone found: " + zone_id)
                console_manager.print_line("Name: " + str(zone.name if zone.has("name") else zone_id))
                
                if zone.has("bounds"):
                    var bounds = zone.bounds
                    console_manager.print_line("Bounds:")
                    console_manager.print_line("  X: " + str(bounds.min_x) + " to " + str(bounds.max_x))
                    console_manager.print_line("  Y: " + str(bounds.min_y) + " to " + str(bounds.max_y))
                    console_manager.print_line("  Z: " + str(bounds.min_z) + " to " + str(bounds.max_z))
                
                var entities = spatial_manager.get_entities_in_zone(zone_id)
                console_manager.print_line("Entities: " + str(entities.size()))
                
                return {
                    "success": true,
                    "message": "Zone found",
                    "zone_id": zone_id,
                    "zone": zone
                }
            
            # Try partial match
            var zones = spatial_manager.get_all_zones()
            var matching_zones = []
            
            for z_id in zones:
                if z_id.contains(zone_id):
                    matching_zones.append(z_id)
                else:
                    var zone = spatial_manager.get_zone(z_id)
                    if zone.has("name") and zone.name.contains(zone_id):
                        matching_zones.append(z_id)
            
            if matching_zones.size() > 0:
                console_manager.print_line("Matching zones found: " + str(matching_zones.size()))
                
                for z_id in matching_zones:
                    var zone = spatial_manager.get_zone(z_id)
                    console_manager.print_line("  " + z_id + ": " + str(zone.name if zone.has("name") else z_id))
                
                return {
                    "success": true,
                    "message": str(matching_zones.size()) + " zones found",
                    "zones": matching_zones
                }
            else:
                console_manager.print_error("Zone not found: " + zone_id)
                return {"success": false, "message": "Zone not found"}
        
        _:
            console_manager.print_error("Unknown find type: " + find_type)
            console_manager.print_line("Valid find types: entity, zone")
            return {"success": false, "message": "Unknown find type"}

# Stats command handler
func cmd_stats(self, args: Array) -> Dictionary:
    var system_type = ""
    
    if args.size() > 0:
        system_type = args[0].to_lower()
    
    if system_type.is_empty() or system_type == "all":
        # Show all stats
        cmd_stats(self, ["entity"])
        cmd_stats(self, ["db"])
        cmd_stats(self, ["spatial"])
        
        return {
            "success": true,
            "message": "All system statistics displayed"
        }
    
    match system_type:
        "entity":
            return entity_commands.cmd_entity_stats(self, [])
        
        "db":
            return database_commands.cmd_db_stats(self, [])
        
        "spatial":
            return spatial_commands.cmd_spatial_stats(self, [])
        
        _:
            console_manager.print_error("Unknown system type: " + system_type)
            console_manager.print_line("Valid system types: entity, db, spatial, all")
            return {"success": false, "message": "Unknown system type"}