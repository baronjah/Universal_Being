extends Node
class_name JSHSpatialCommands

# Spatial system console commands
var console_manager: JSHConsoleManager = null
var spatial_manager: JSHSpatialManager = null
var commands: Dictionary = {}

func _init() -> void:
    console_manager = JSHConsoleManager.get_instance()
    spatial_manager = JSHSpatialManager.get_instance()
    
    # Register commands
    register_commands()

func register_commands() -> void:
    commands = {
        "zone": {
            "description": "Zone management commands",
            "usage": "zone <subcommand> [arguments]",
            "callback": Callable(self, "cmd_zone"),
            "min_args": 1,
            "max_args": -1,
            "arg_types": [TYPE_STRING],
            "arg_descriptions": ["Subcommand: list, create, delete, info, entities, transition, activate, subdivide"]
        },
        "spatial": {
            "description": "Spatial query commands",
            "usage": "spatial <subcommand> [arguments]",
            "callback": Callable(self, "cmd_spatial"),
            "min_args": 1,
            "max_args": -1,
            "arg_types": [TYPE_STRING],
            "arg_descriptions": ["Subcommand: radius, box, nearest, ray, stats"]
        },
        "position": {
            "description": "Entity position commands",
            "usage": "position <subcommand> [arguments]",
            "callback": Callable(self, "cmd_position"),
            "min_args": 1,
            "max_args": -1,
            "arg_types": [TYPE_STRING],
            "arg_descriptions": ["Subcommand: get, set, move"]
        }
    }
    
    # Register with console manager
    for cmd_name in commands:
        console_manager.register_command(cmd_name, commands[cmd_name])

# Zone command handler
func cmd_zone(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Missing subcommand for zone")
        return {"success": false, "message": "Missing subcommand"}
    
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1)
    
    match subcommand:
        "list":
            return cmd_zone_list(self, subargs)
        "create":
            return cmd_zone_create(self, subargs)
        "delete":
            return cmd_zone_delete(self, subargs)
        "info":
            return cmd_zone_info(self, subargs)
        "entities":
            return cmd_zone_entities(self, subargs)
        "transition":
            return cmd_zone_transition(self, subargs)
        "activate":
            return cmd_zone_activate(self, subargs)
        "subdivide":
            return cmd_zone_subdivide(self, subargs)
        _:
            console_manager.print_error("Unknown zone subcommand: " + subcommand)
            console_manager.print_line("Available subcommands: list, create, delete, info, entities, transition, activate, subdivide")
            return {"success": false, "message": "Unknown subcommand: " + subcommand}

# Zone subcommands
func cmd_zone_list(self, args: Array) -> Dictionary:
    var zones = spatial_manager.get_all_zones()
    var active_zone = spatial_manager.get_active_zone()
    var visible_zones = spatial_manager.get_visible_zones()
    
    console_manager.print_line("Zones:")
    
    for zone_id in zones:
        var zone = spatial_manager.get_zone(zone_id)
        var status = ""
        
        if zone_id == active_zone:
            status = " [ACTIVE]"
        elif zone_id in visible_zones:
            status = " [visible]"
        
        var entity_count = spatial_manager.get_entities_in_zone(zone_id).size()
        
        console_manager.print_line("  " + zone_id + ": " + str(zone.name if zone.has("name") else zone_id) + status + " (" + str(entity_count) + " entities)")
    
    return {
        "success": true,
        "message": str(zones.size()) + " zones listed",
        "zones": zones,
        "active_zone": active_zone,
        "visible_zones": visible_zones
    }

func cmd_zone_create(self, args: Array) -> Dictionary:
    if args.size() < 3:
        console_manager.print_error("Usage: zone create <zone_id> <name> <min_x,min_y,min_z,max_x,max_y,max_z>")
        return {"success": false, "message": "Invalid arguments"}
    
    var zone_id = args[0]
    var zone_name = args[1]
    var bounds_str = args[2].split(",")
    
    if bounds_str.size() < 6:
        console_manager.print_error("Invalid bounds format. Expected: min_x,min_y,min_z,max_x,max_y,max_z")
        return {"success": false, "message": "Invalid bounds format"}
    
    var min_x = float(bounds_str[0])
    var min_y = float(bounds_str[1])
    var min_z = float(bounds_str[2])
    var max_x = float(bounds_str[3])
    var max_y = float(bounds_str[4])
    var max_z = float(bounds_str[5])
    
    # Create zone data
    var zone_data = {
        "name": zone_name,
        "bounds": {
            "min_x": min_x,
            "min_y": min_y,
            "min_z": min_z,
            "max_x": max_x,
            "max_y": max_y,
            "max_z": max_z
        },
        "level": 0,
        "is_root": args.size() >= 4 and args[3].to_lower() == "root",
        "autoload": false,
        "properties": {}
    }
    
    # Parse additional properties
    for i in range(4, args.size()):
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

func cmd_zone_delete(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Zone ID required")
        return {"success": false, "message": "Zone ID required"}
    
    var zone_id = args[0]
    
    if spatial_manager.delete_zone(zone_id):
        console_manager.print_success("Zone deleted: " + zone_id)
        return {
            "success": true,
            "message": "Zone deleted",
            "zone_id": zone_id
        }
    else:
        console_manager.print_error("Failed to delete zone: " + zone_id)
        return {"success": false, "message": "Failed to delete zone"}

func cmd_zone_info(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Zone ID required")
        return {"success": false, "message": "Zone ID required"}
    
    var zone_id = args[0]
    var zone = spatial_manager.get_zone(zone_id)
    
    if zone.is_empty():
        console_manager.print_error("Zone not found: " + zone_id)
        return {"success": false, "message": "Zone not found"}
    
    var zone_stats = spatial_manager.get_zone_statistics(zone_id)
    var hierarchy = {
        "parent": spatial_manager.get_parent_zone(zone_id),
        "children": spatial_manager.get_child_zones(zone_id)
    }
    
    console_manager.print_line("Zone: " + zone_id)
    console_manager.print_line("  Name: " + str(zone.name if zone.has("name") else zone_id))
    
    if zone.has("bounds"):
        var bounds = zone.bounds
        console_manager.print_line("  Bounds:")
        console_manager.print_line("    X: " + str(bounds.min_x) + " to " + str(bounds.max_x))
        console_manager.print_line("    Y: " + str(bounds.min_y) + " to " + str(bounds.max_y))
        console_manager.print_line("    Z: " + str(bounds.min_z) + " to " + str(bounds.max_z))
    
    console_manager.print_line("  Entity Count: " + str(zone_stats.entity_count))
    console_manager.print_line("  Entity Density: " + str(snappedf(zone_stats.entity_density, 0.001)))
    
    console_manager.print_line("  Hierarchy:")
    console_manager.print_line("    Level: " + str(zone.level if zone.has("level") else 0))
    console_manager.print_line("    Root: " + str(zone.is_root if zone.has("is_root") else false))
    console_manager.print_line("    Parent: " + (hierarchy.parent if not hierarchy.parent.is_empty() else "None"))
    console_manager.print_line("    Children: " + str(hierarchy.children.size()))
    
    for child in hierarchy.children:
        console_manager.print_line("      - " + child)
    
    console_manager.print_line("  Properties:")
    if zone.has("properties") and not zone.properties.is_empty():
        for key in zone.properties:
            console_manager.print_line("    " + key + ": " + str(zone.properties[key]))
    else:
        console_manager.print_line("    None")
    
    # Transitions
    var transitions = spatial_manager.get_zone_transitions(zone_id)
    console_manager.print_line("  Transitions:")
    if transitions.size() > 0:
        for transition in transitions:
            console_manager.print_line("    To " + transition.target_zone + ": " + transition.type)
    else:
        console_manager.print_line("    None")
    
    return {
        "success": true,
        "message": "Zone info displayed",
        "zone": zone,
        "zone_stats": zone_stats,
        "hierarchy": hierarchy,
        "transitions": transitions
    }

func cmd_zone_entities(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Zone ID required")
        return {"success": false, "message": "Zone ID required"}
    
    var zone_id = args[0]
    var entities = spatial_manager.get_entities_in_zone(zone_id)
    
    console_manager.print_line("Entities in zone " + zone_id + ":")
    
    if entities.size() > 0:
        for entity in entities:
            console_manager.print_line("  " + entity.get_id().substr(0, 8) + ": " + entity.get_type())
    else:
        console_manager.print_line("  No entities in zone")
    
    return {
        "success": true,
        "message": str(entities.size()) + " entities in zone",
        "count": entities.size(),
        "entities": entities
    }

func cmd_zone_transition(self, args: Array) -> Dictionary:
    if args.size() < 2:
        console_manager.print_error("Usage: zone transition <source_zone> <target_zone> [type] [bidirectional]")
        return {"success": false, "message": "Invalid arguments"}
    
    var source_zone = args[0]
    var target_zone = args[1]
    
    var transition_data = {
        "type": "portal",
        "bidirectional": true
    }
    
    if args.size() >= 3:
        transition_data.type = args[2]
    
    if args.size() >= 4:
        transition_data.bidirectional = args[3].to_lower() == "true"
    
    if spatial_manager.register_zone_transition(source_zone, target_zone, transition_data):
        console_manager.print_success("Transition registered: " + source_zone + " -> " + target_zone)
        return {
            "success": true,
            "message": "Transition registered",
            "source_zone": source_zone,
            "target_zone": target_zone,
            "transition_data": transition_data
        }
    else:
        console_manager.print_error("Failed to register transition: " + source_zone + " -> " + target_zone)
        return {"success": false, "message": "Failed to register transition"}

func cmd_zone_activate(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Zone ID required")
        return {"success": false, "message": "Zone ID required"}
    
    var zone_id = args[0]
    
    if spatial_manager.set_active_zone(zone_id):
        console_manager.print_success("Active zone set to: " + zone_id)
        return {
            "success": true,
            "message": "Active zone set",
            "zone_id": zone_id
        }
    else:
        console_manager.print_error("Failed to set active zone: " + zone_id)
        return {"success": false, "message": "Failed to set active zone"}

func cmd_zone_subdivide(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Zone ID required")
        return {"success": false, "message": "Zone ID required"}
    
    var zone_id = args[0]
    
    var divisions = Vector3i(2, 2, 2)  # Default divisions
    
    if args.size() >= 2:
        var div_parts = args[1].split(",")
        if div_parts.size() >= 3:
            divisions = Vector3i(int(div_parts[0]), int(div_parts[1]), int(div_parts[2]))
    
    var child_zones = spatial_manager.subdivide_zone(zone_id, divisions)
    
    if child_zones.size() > 0:
        console_manager.print_success("Zone subdivided: " + zone_id)
        console_manager.print_line("Created " + str(child_zones.size()) + " child zones:")
        
        for child_id in child_zones:
            console_manager.print_line("  " + child_id)
        
        return {
            "success": true,
            "message": "Zone subdivided",
            "zone_id": zone_id,
            "child_zones": child_zones
        }
    else:
        console_manager.print_error("Failed to subdivide zone: " + zone_id)
        return {"success": false, "message": "Failed to subdivide zone"}

# Spatial command handler
func cmd_spatial(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Missing subcommand for spatial")
        return {"success": false, "message": "Missing subcommand"}
    
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1)
    
    match subcommand:
        "radius":
            return cmd_spatial_radius(self, subargs)
        "box":
            return cmd_spatial_box(self, subargs)
        "nearest":
            return cmd_spatial_nearest(self, subargs)
        "ray":
            return cmd_spatial_ray(self, subargs)
        "stats":
            return cmd_spatial_stats(self, subargs)
        _:
            console_manager.print_error("Unknown spatial subcommand: " + subcommand)
            console_manager.print_line("Available subcommands: radius, box, nearest, ray, stats")
            return {"success": false, "message": "Unknown subcommand: " + subcommand}

# Spatial subcommands
func cmd_spatial_radius(self, args: Array) -> Dictionary:
    if args.size() < 4:
        console_manager.print_error("Usage: spatial radius <x> <y> <z> <radius> [type/tag] [value]")
        return {"success": false, "message": "Invalid arguments"}
    
    var position = Vector3(float(args[0]), float(args[1]), float(args[2]))
    var radius = float(args[3])
    
    var filter = {}
    
    if args.size() >= 6:
        var filter_type = args[4]
        var filter_value = args[5]
        
        filter[filter_type] = filter_value
    
    var entities = spatial_manager.get_entities_in_radius(position, radius, filter)
    
    console_manager.print_line("Entities within " + str(radius) + " units of " + str(position) + ":")
    
    if entities.size() > 0:
        for entity in entities:
            var entity_pos = spatial_manager.get_entity_position(entity.get_id())
            var distance = position.distance_to(entity_pos)
            console_manager.print_line("  " + entity.get_id().substr(0, 8) + ": " + entity.get_type() + " (d=" + str(snappedf(distance, 0.1)) + ")")
    else:
        console_manager.print_line("  No entities found")
    
    return {
        "success": true,
        "message": str(entities.size()) + " entities found",
        "count": entities.size(),
        "entities": entities
    }

func cmd_spatial_box(self, args: Array) -> Dictionary:
    if args.size() < 6:
        console_manager.print_error("Usage: spatial box <min_x> <min_y> <min_z> <max_x> <max_y> <max_z> [type/tag] [value]")
        return {"success": false, "message": "Invalid arguments"}
    
    var min_bounds = Vector3(float(args[0]), float(args[1]), float(args[2]))
    var max_bounds = Vector3(float(args[3]), float(args[4]), float(args[5]))
    
    var filter = {}
    
    if args.size() >= 8:
        var filter_type = args[6]
        var filter_value = args[7]
        
        filter[filter_type] = filter_value
    
    var entities = spatial_manager.get_entities_in_box(min_bounds, max_bounds, filter)
    
    console_manager.print_line("Entities in box from " + str(min_bounds) + " to " + str(max_bounds) + ":")
    
    if entities.size() > 0:
        for entity in entities:
            var entity_pos = spatial_manager.get_entity_position(entity.get_id())
            console_manager.print_line("  " + entity.get_id().substr(0, 8) + ": " + entity.get_type() + " at " + str(entity_pos))
    else:
        console_manager.print_line("  No entities found")
    
    return {
        "success": true,
        "message": str(entities.size()) + " entities found",
        "count": entities.size(),
        "entities": entities
    }

func cmd_spatial_nearest(self, args: Array) -> Dictionary:
    if args.size() < 5:
        console_manager.print_error("Usage: spatial nearest <x> <y> <z> <count> <max_distance> [type/tag] [value]")
        return {"success": false, "message": "Invalid arguments"}
    
    var position = Vector3(float(args[0]), float(args[1]), float(args[2]))
    var count = int(args[3])
    var max_distance = float(args[4])
    
    var filter = {}
    
    if args.size() >= 7:
        var filter_type = args[5]
        var filter_value = args[6]
        
        filter[filter_type] = filter_value
    
    var entities = spatial_manager.get_nearest_entities(position, count, max_distance, filter)
    
    console_manager.print_line("Nearest " + str(count) + " entities to " + str(position) + ":")
    
    if entities.size() > 0:
        for entity in entities:
            var entity_pos = spatial_manager.get_entity_position(entity.get_id())
            var distance = position.distance_to(entity_pos)
            console_manager.print_line("  " + entity.get_id().substr(0, 8) + ": " + entity.get_type() + " (d=" + str(snappedf(distance, 0.1)) + ")")
    else:
        console_manager.print_line("  No entities found")
    
    return {
        "success": true,
        "message": str(entities.size()) + " entities found",
        "count": entities.size(),
        "entities": entities
    }

func cmd_spatial_ray(self, args: Array) -> Dictionary:
    if args.size() < 6:
        console_manager.print_error("Usage: spatial ray <start_x> <start_y> <start_z> <end_x> <end_y> <end_z> [type/tag] [value]")
        return {"success": false, "message": "Invalid arguments"}
    
    var start = Vector3(float(args[0]), float(args[1]), float(args[2]))
    var end = Vector3(float(args[3]), float(args[4]), float(args[5]))
    
    var filter = {}
    
    if args.size() >= 8:
        var filter_type = args[6]
        var filter_value = args[7]
        
        filter[filter_type] = filter_value
    
    var result = spatial_manager.cast_ray(start, end, filter)
    
    console_manager.print_line("Ray cast from " + str(start) + " to " + str(end) + ":")
    
    if result.hit:
        console_manager.print_line("  Hit entity: " + result.entity.get_id().substr(0, 8) + " (" + result.entity.get_type() + ")")
        console_manager.print_line("  Hit position: " + str(result.position))
        console_manager.print_line("  Hit distance: " + str(snappedf(result.distance, 0.1)))
        console_manager.print_line("  Hit normal: " + str(result.normal))
    else:
        console_manager.print_line("  No hit")
    
    return {
        "success": true,
        "message": "Ray cast completed",
        "hit": result.hit,
        "result": result
    }

func cmd_spatial_stats(self, args: Array) -> Dictionary:
    var stats = spatial_manager.get_zone_statistics()
    
    console_manager.print_line("Spatial System Statistics:")
    console_manager.print_line("  Total Zones: " + str(stats.total_zones))
    console_manager.print_line("  Loaded Zones: " + str(stats.loaded_zones))
    console_manager.print_line("  Visible Entities: " + str(stats.visible_entities))
    console_manager.print_line("  Active Zone: " + str(stats.active_zone))
    console_manager.print_line("  Entity Positions: " + str(stats.entity_positions))
    console_manager.print_line("  Spatial Queries: " + str(stats.spatial_queries))
    console_manager.print_line("  Zone Transitions: " + str(stats.zone_transitions))
    
    return {
        "success": true,
        "message": "Spatial statistics displayed",
        "stats": stats
    }

# Position command handler
func cmd_position(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Missing subcommand for position")
        return {"success": false, "message": "Missing subcommand"}
    
    var subcommand = args[0].to_lower()
    var subargs = args.slice(1)
    
    match subcommand:
        "get":
            return cmd_position_get(self, subargs)
        "set":
            return cmd_position_set(self, subargs)
        "move":
            return cmd_position_move(self, subargs)
        _:
            console_manager.print_error("Unknown position subcommand: " + subcommand)
            console_manager.print_line("Available subcommands: get, set, move")
            return {"success": false, "message": "Unknown subcommand: " + subcommand}

# Position subcommands
func cmd_position_get(self, args: Array) -> Dictionary:
    if args.size() < 1:
        console_manager.print_error("Entity ID required")
        return {"success": false, "message": "Entity ID required"}
    
    var entity_id = args[0]
    
    # Find entity with ID or partial ID
    var full_id = entity_id
    var entity_manager = JSHEntityManager.get_instance()
    
    if entity_id.length() < 32 and entity_manager:  # Not a full ID, try to find matching entity
        for id in entity_manager.entities:
            if id.begins_with(entity_id):
                full_id = id
                break
    
    var position = spatial_manager.get_entity_position(full_id)
    
    console_manager.print_line("Entity position:")
    console_manager.print_line("  X: " + str(position.x))
    console_manager.print_line("  Y: " + str(position.y))
    console_manager.print_line("  Z: " + str(position.z))
    
    return {
        "success": true,
        "message": "Entity position retrieved",
        "entity_id": full_id,
        "position": position
    }

func cmd_position_set(self, args: Array) -> Dictionary:
    if args.size() < 4:
        console_manager.print_error("Usage: position set <entity_id> <x> <y> <z>")
        return {"success": false, "message": "Invalid arguments"}
    
    var entity_id = args[0]
    var position = Vector3(float(args[1]), float(args[2]), float(args[3]))
    
    # Find entity with ID or partial ID
    var full_id = entity_id
    var entity_manager = JSHEntityManager.get_instance()
    
    if entity_id.length() < 32 and entity_manager:  # Not a full ID, try to find matching entity
        for id in entity_manager.entities:
            if id.begins_with(entity_id):
                full_id = id
                break
    
    if spatial_manager.set_entity_position(full_id, position):
        console_manager.print_success("Entity position set: " + str(position))
        return {
            "success": true,
            "message": "Entity position set",
            "entity_id": full_id,
            "position": position
        }
    else:
        console_manager.print_error("Failed to set entity position")
        return {"success": false, "message": "Failed to set entity position"}

func cmd_position_move(self, args: Array) -> Dictionary:
    if args.size() < 4:
        console_manager.print_error("Usage: position move <entity_id> <x> <y> <z>")
        return {"success": false, "message": "Invalid arguments"}
    
    var entity_id = args[0]
    var position = Vector3(float(args[1]), float(args[2]), float(args[3]))
    
    # Find entity with ID or partial ID
    var full_id = entity_id
    var entity_manager = JSHEntityManager.get_instance()
    
    if entity_id.length() < 32 and entity_manager:  # Not a full ID, try to find matching entity
        for id in entity_manager.entities:
            if id.begins_with(entity_id):
                full_id = id
                break
    
    var old_position = spatial_manager.get_entity_position(full_id)
    
    if spatial_manager.move_entity(full_id, position):
        console_manager.print_success("Entity moved: " + str(old_position) + " -> " + str(position))
        
        # Get zones after move
        var entity = entity_manager.get_entity(full_id)
        if entity:
            var zones = entity.get_zones()
            console_manager.print_line("Current zones: " + str(zones))
        
        return {
            "success": true,
            "message": "Entity moved",
            "entity_id": full_id,
            "old_position": old_position,
            "new_position": position
        }
    else:
        console_manager.print_error("Failed to move entity")
        return {"success": false, "message": "Failed to move entity"}