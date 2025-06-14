extends Node

class_name ScaleConsoleCommands

# ----- CONSOLE REFERENCE -----
var console: Node  # JSHConsoleAdvanced reference
var zone_scale_system: Node  # ZoneScaleSystem reference
var word_seed_evolution: Node  # WordSeedEvolution reference
var player_controller: Node  # Player controller

# ----- COMMAND SETTINGS -----
var output_color_zone: Color = Color(0.4, 0.7, 0.9)
var output_color_scale: Color = Color(0.9, 0.6, 0.9)
var output_color_error: Color = Color(1.0, 0.4, 0.4)
var output_color_system: Color = Color(0.8, 0.8, 0.2)

# ----- INITIALIZATION -----
func _ready():
    # Register zone and scale commands to the console
    register_commands()

# ----- COMMAND REGISTRATION -----
func register_commands():
    if not console:
        push_error("ScaleConsoleCommands: console reference not set")
        return
    
    # Register each command
    console.register_command(
        "zone", 
        "Create or manipulate reality zones", 
        "zone <create|info|delete|list> [args]",
        Callable(self, "_cmd_zone")
    )
    
    console.register_command(
        "scale", 
        "Control or view scale levels", 
        "scale <info|jump|effect> [args]",
        Callable(self, "_cmd_scale")
    )
    
    console.register_command(
        "whimsy", 
        "Create zones based on your whims", 
        "whimsy <emotion|concept|intensity> [size]",
        Callable(self, "_cmd_whimsy")
    )
    
    console.register_command(
        "matter", 
        "Control matter creation and destruction rates", 
        "matter <balance|creation|destruction> <value>",
        Callable(self, "_cmd_matter")
    )
    
    console.register_command(
        "frequency", 
        "Adjust event frequency in current zone", 
        "frequency <evolution|destruction|manifestation> <value>",
        Callable(self, "_cmd_frequency")
    )
    
    console.register_command(
        "timescale", 
        "Adjust time flow in a zone", 
        "timescale <zone_id|current> <value>",
        Callable(self, "_cmd_timescale")
    )
    
    console.register_command(
        "chunk", 
        "Create or modify a specific chunk of reality", 
        "chunk <create|destroy|modify> [args]",
        Callable(self, "_cmd_chunk")
    )

# ----- COMMAND IMPLEMENTATIONS -----
func _cmd_zone(args: Array) -> Dictionary:
    if not zone_scale_system:
        return {"message": "Zone scale system not connected", "color": output_color_error}
    
    if args.size() < 1:
        return {"message": "Usage: /zone <create|info|delete|list> [args]", "color": output_color_error}
    
    var subcommand = args[0].to_lower()
    
    match subcommand:
        "create":
            return _cmd_zone_create(args.slice(1))
        "info":
            return _cmd_zone_info(args.slice(1))
        "delete":
            return _cmd_zone_delete(args.slice(1))
        "list":
            return _cmd_zone_list(args.slice(1))
        _:
            return {"message": "Unknown zone subcommand: " + subcommand, "color": output_color_error}

func _cmd_zone_create(args: Array) -> Dictionary:
    if args.size() < 3:
        return {"message": "Usage: /zone create <scale_level> <zone_type> [radius] [x y z]", "color": output_color_error}
    
    var scale_level = args[0].to_lower()
    var zone_type = args[1].to_upper()
    var radius = 10.0  # Default radius
    var position = Vector3.ZERO
    
    # Check scale level validity
    if not scale_level in zone_scale_system.scale_levels:
        var valid_scales = ", ".join(zone_scale_system.scale_levels)
        return {"message": "Invalid scale level. Valid options: " + valid_scales, "color": output_color_error}
    
    # Check zone type validity
    var valid_type = false
    for type in zone_scale_system.ZoneType.keys():
        if type.to_upper() == zone_type:
            valid_type = true
            break
    
    if not valid_type:
        var valid_types = ", ".join(zone_scale_system.ZoneType.keys())
        return {"message": "Invalid zone type. Valid options: " + valid_types, "color": output_color_error}
    
    # Parse radius if provided
    if args.size() >= 3:
        radius = float(args[2])
        radius = max(1.0, min(radius, 50.0))  # Limit between 1-50
    
    # Parse position if provided
    if args.size() >= 6:
        position = Vector3(float(args[3]), float(args[4]), float(args[5]))
    elif player_controller:
        # Use position in front of player
        position = player_controller.global_position + player_controller.camera_mount.global_transform.basis.z * -10.0
    
    # Create the zone
    var zone_id = zone_scale_system.create_custom_zone(position, radius, scale_level, zone_type)
    
    if zone_id != "":
        return {
            "message": "Created " + scale_level + " " + zone_type.capitalize() + " zone with radius " + str(radius) + " at " + str(position) + "\nZone ID: " + zone_id, 
            "color": output_color_zone
        }
    else:
        return {"message": "Failed to create zone", "color": output_color_error}

func _cmd_zone_info(args: Array) -> Dictionary:
    if args.size() < 1:
        # Default to current zone
        var current_zone_id = zone_scale_system.get_current_zone_id()
        if current_zone_id == "":
            return {"message": "Not currently in any zone. Specify a zone ID or enter a zone.", "color": output_color_error}
        args = [current_zone_id]
    
    var zone_id = args[0]
    
    if not zone_scale_system.active_zones.has(zone_id):
        return {"message": "Zone ID not found: " + zone_id, "color": output_color_error}
    
    var zone_data = zone_scale_system.active_zones[zone_id]
    var zone_type_name = zone_scale_system.ZoneType.keys()[zone_data.zone_type].capitalize()
    
    var output = "Zone Information for " + zone_id + ":\n"
    output += "Scale Level: " + zone_data.scale_level.capitalize() + "\n"
    output += "Zone Type: " + zone_type_name + "\n"
    output += "Position: " + str(zone_data.position) + "\n"
    output += "Radius: " + str(zone_data.radius) + "\n"
    output += "Evolution Factor: " + str(snapped(zone_data.evolution_factor, 0.01)) + "x\n"
    output += "Destruction Factor: " + str(snapped(zone_data.destruction_factor, 0.01)) + "x\n"
    output += "Manifestation Factor: " + str(snapped(zone_data.manifestation_factor, 0.01)) + "x\n"
    output += "Time Dilation: " + str(snapped(zone_data.time_dilation, 0.01)) + "x\n"
    
    # Word information
    var words_in_zone = zone_scale_system.get_words_in_zone(zone_id)
    output += "Words in Zone: " + str(words_in_zone.size()) + "\n"
    
    # Connected zones
    if zone_data.connected_zones.size() > 0:
        output += "Connected Zones: " + str(zone_data.connected_zones.size()) + " zones"
    else:
        output += "Connected Zones: None"
    
    return {"message": output, "color": output_color_zone}

func _cmd_zone_delete(args: Array) -> Dictionary:
    if args.size() < 1:
        return {"message": "Usage: /zone delete <zone_id>", "color": output_color_error}
    
    var zone_id = args[0]
    
    if not zone_scale_system.active_zones.has(zone_id):
        return {"message": "Zone ID not found: " + zone_id, "color": output_color_error}
    
    if zone_scale_system.delete_zone(zone_id):
        return {"message": "Zone deleted: " + zone_id, "color": output_color_zone}
    else:
        return {"message": "Failed to delete zone", "color": output_color_error}

func _cmd_zone_list(args: Array) -> Dictionary:
    var active_zones = zone_scale_system.active_zones
    
    if active_zones.size() == 0:
        return {"message": "No active zones found.", "color": output_color_zone}
    
    var output = "Active Zones:\n"
    var current_zone_id = zone_scale_system.get_current_zone_id()
    
    for zone_id in active_zones:
        var zone_data = active_zones[zone_id]
        var zone_type_name = zone_scale_system.ZoneType.keys()[zone_data.zone_type].capitalize()
        
        output += zone_id + ": " + zone_data.scale_level.capitalize() + " " + zone_type_name + " Zone"
        
        if zone_id == current_zone_id:
            output += " (Current)"
        
        output += "\n"
    
    return {"message": output, "color": output_color_zone}

func _cmd_scale(args: Array) -> Dictionary:
    if not zone_scale_system:
        return {"message": "Zone scale system not connected", "color": output_color_error}
    
    if args.size() < 1:
        return {"message": "Usage: /scale <info|jump|effect> [args]", "color": output_color_error}
    
    var subcommand = args[0].to_lower()
    
    match subcommand:
        "info":
            return _cmd_scale_info(args.slice(1))
        "jump":
            return _cmd_scale_jump(args.slice(1))
        "effect":
            return _cmd_scale_effect(args.slice(1))
        _:
            return {"message": "Unknown scale subcommand: " + subcommand, "color": output_color_error}

func _cmd_scale_info(args: Array) -> Dictionary:
    var current_scale = zone_scale_system.get_current_scale_level()
    var scale_levels = zone_scale_system.scale_levels
    
    var output = "Scale Information:\n"
    output += "Current Scale: " + current_scale.capitalize() + "\n\n"
    output += "Available Scales (from smallest to largest):\n"
    
    for i in range(scale_levels.size()):
        var scale_level = scale_levels[i]
        output += (i+1) + ". " + scale_level.capitalize()
        
        if scale_level == current_scale:
            output += " (Current)"
        
        output += "\n"
    
    return {"message": output, "color": output_color_scale}

func _cmd_scale_jump(args: Array) -> Dictionary:
    if args.size() < 1:
        return {"message": "Usage: /scale jump <scale_level>", "color": output_color_error}
    
    var target_scale = args[0].to_lower()
    
    # Check scale level validity
    if not target_scale in zone_scale_system.scale_levels:
        var valid_scales = ", ".join(zone_scale_system.scale_levels)
        return {"message": "Invalid scale level. Valid options: " + valid_scales, "color": output_color_error}
    
    var current_scale = zone_scale_system.get_current_scale_level()
    
    if target_scale == current_scale:
        return {"message": "Already at " + target_scale.capitalize() + " scale.", "color": output_color_scale}
    
    # Find closest zone of target scale
    var closest_zone_id = ""
    var closest_distance = INF
    
    for zone_id in zone_scale_system.active_zones:
        var zone_data = zone_scale_system.active_zones[zone_id]
        
        if zone_data.scale_level == target_scale:
            var player_pos = player_controller.global_position
            var distance = player_pos.distance_to(zone_data.position)
            
            if distance < closest_distance:
                closest_zone_id = zone_id
                closest_distance = distance
    
    if closest_zone_id == "":
        # Create a new zone of the target scale
        var position = player_controller.global_position
        position += player_controller.camera_mount.global_transform.basis.z * -10.0
        
        closest_zone_id = zone_scale_system.create_custom_zone(position, 10.0, target_scale, "STABLE")
        
        if closest_zone_id == "":
            return {"message": "Failed to create " + target_scale + " scale zone", "color": output_color_error}
    
    # Teleport player to zone
    var target_position = zone_scale_system.active_zones[closest_zone_id].position
    
    if player_controller and player_controller.has_method("teleport_to"):
        player_controller.teleport_to(target_position)
        return {"message": "Jumped to " + target_scale.capitalize() + " scale", "color": output_color_scale}
    else:
        return {"message": "Cannot teleport player - missing teleport_to method", "color": output_color_error}

func _cmd_scale_effect(args: Array) -> Dictionary:
    if args.size() < 2:
        return {"message": "Usage: /scale effect <type> <intensity>", "color": output_color_error}
    
    var effect_type = args[0].to_lower()
    var intensity = float(args[1])
    intensity = clamp(intensity, 0.0, 1.0)
    
    # TODO: Implement scale effects system
    # This would apply visual or gameplay effects based on scale transitions
    
    return {"message": "Applied " + effect_type + " effect with intensity " + str(intensity), "color": output_color_scale}

func _cmd_whimsy(args: Array) -> Dictionary:
    if not zone_scale_system:
        return {"message": "Zone scale system not connected", "color": output_color_error}
    
    if args.size() < 1:
        return {"message": "Usage: /whimsy <emotion|concept|intensity> [size]", "color": output_color_error}
    
    var whimsy_type = args[0].to_lower()
    var size = 15.0  # Default size
    
    if args.size() >= 2:
        size = float(args[1])
        size = max(5.0, min(size, 50.0))  # Limit between 5-50
    
    // Determine zone properties based on whimsy type
    var scale_level = "human"  // Default
    var zone_type = zone_scale_system.ZoneType.STABLE
    var position = Vector3.ZERO
    
    if player_controller:
        position = player_controller.global_position + player_controller.camera_mount.global_transform.basis.z * -size
    
    // Map whimsy to zone properties
    match whimsy_type:
        // Emotional whimsies
        "joy", "happy", "excitement":
            scale_level = "human"
            zone_type = zone_scale_system.ZoneType.CREATIVE
        "sadness", "melancholy", "sorrow":
            scale_level = "human"
            zone_type = zone_scale_system.ZoneType.SLOWED
        "anger", "rage", "fury":
            scale_level = "human"
            zone_type = zone_scale_system.ZoneType.CHAOTIC
        "fear", "anxiety", "dread":
            scale_level = "micro"
            zone_type = zone_scale_system.ZoneType.DESTRUCTIVE
        "peace", "calm", "serenity":
            scale_level = "planetary"
            zone_type = zone_scale_system.ZoneType.STABLE
        
        // Conceptual whimsies
        "infinity", "endless", "eternal":
            scale_level = "cosmic"
            zone_type = zone_scale_system.ZoneType.ACCELERATED
        "microscopic", "tiny", "small":
            scale_level = "quantum"
            zone_type = zone_scale_system.ZoneType.CHAOTIC
        "chaos", "disorder", "entropy":
            scale_level = rand_array(zone_scale_system.scale_levels)
            zone_type = zone_scale_system.ZoneType.CHAOTIC
        "creation", "genesis", "birth":
            scale_level = rand_array(zone_scale_system.scale_levels)
            zone_type = zone_scale_system.ZoneType.CREATIVE
        "destruction", "end", "death":
            scale_level = rand_array(zone_scale_system.scale_levels)
            zone_type = zone_scale_system.ZoneType.DESTRUCTIVE
        
        // Intensity whimsies
        "intense", "powerful", "strong":
            scale_level = rand_array(zone_scale_system.scale_levels)
            zone_type = zone_scale_system.ZoneType.ACCELERATED
        "subtle", "gentle", "soft":
            scale_level = rand_array(zone_scale_system.scale_levels)
            zone_type = zone_scale_system.ZoneType.SLOWED
        "random", "chance", "luck":
            scale_level = rand_array(zone_scale_system.scale_levels)
            zone_type = randi() % zone_scale_system.ZoneType.size()
        
        _:
            // For unknown whimsies, use a shifting zone with random scale
            scale_level = rand_array(zone_scale_system.scale_levels)
            zone_type = zone_scale_system.ZoneType.SHIFTING
    
    // Create the zone based on whimsy
    var zone_id = zone_scale_system.create_custom_zone(position, size, scale_level, zone_scale_system.ZoneType.keys()[zone_type])
    
    if zone_id != "":
        return {
            "message": "Created whimsical " + scale_level + " " + zone_scale_system.ZoneType.keys()[zone_type].capitalize() + " zone from your '" + whimsy_type + "' whim", 
            "color": output_color_zone
        }
    else:
        return {"message": "Failed to create whimsical zone", "color": output_color_error}

func _cmd_matter(args: Array) -> Dictionary:
    if not zone_scale_system:
        return {"message": "Zone scale system not connected", "color": output_color_error}
    
    if args.size() < 2:
        return {"message": "Usage: /matter <balance|creation|destruction> <value>", "color": output_color_error}
    
    var matter_aspect = args[0].to_lower()
    var value = float(args[1])
    value = clamp(value, 0.1, 5.0)  // Limit between 0.1x and 5.0x
    
    var current_zone_id = zone_scale_system.get_current_zone_id()
    
    if current_zone_id == "":
        return {"message": "Not currently in any zone. Enter a zone first.", "color": output_color_error}
    
    var zone_data = zone_scale_system.active_zones[current_zone_id]
    
    match matter_aspect:
        "balance":
            // Set creation and destruction to the same value
            zone_data.manifestation_factor = value
            zone_data.destruction_factor = value
            return {
                "message": "Matter balance in current zone set to " + str(value) + "x", 
                "color": output_color_system
            }
        
        "creation":
            // Set creation/manifestation rate
            zone_data.manifestation_factor = value
            return {
                "message": "Matter creation rate in current zone set to " + str(value) + "x", 
                "color": output_color_system
            }
        
        "destruction":
            // Set destruction rate
            zone_data.destruction_factor = value
            return {
                "message": "Matter destruction rate in current zone set to " + str(value) + "x", 
                "color": output_color_system
            }
        
        _:
            return {"message": "Unknown matter aspect: " + matter_aspect, "color": output_color_error}

func _cmd_frequency(args: Array) -> Dictionary:
    if not zone_scale_system:
        return {"message": "Zone scale system not connected", "color": output_color_error}
    
    if args.size() < 2:
        return {"message": "Usage: /frequency <evolution|destruction|manifestation> <value>", "color": output_color_error}
    
    var frequency_type = args[0].to_lower()
    var value = float(args[1])
    value = clamp(value, 0.1, 5.0)  // Limit between 0.1x and 5.0x
    
    var current_zone_id = zone_scale_system.get_current_zone_id()
    
    if current_zone_id == "":
        return {"message": "Not currently in any zone. Enter a zone first.", "color": output_color_error}
    
    var zone_data = zone_scale_system.active_zones[current_zone_id]
    
    match frequency_type:
        "evolution":
            zone_data.evolution_factor = value
            return {
                "message": "Evolution frequency in current zone set to " + str(value) + "x", 
                "color": output_color_system
            }
        
        "destruction":
            zone_data.destruction_factor = value
            return {
                "message": "Destruction frequency in current zone set to " + str(value) + "x", 
                "color": output_color_system
            }
        
        "manifestation":
            zone_data.manifestation_factor = value
            return {
                "message": "Manifestation frequency in current zone set to " + str(value) + "x", 
                "color": output_color_system
            }
        
        "all":
            zone_data.evolution_factor = value
            zone_data.destruction_factor = value
            zone_data.manifestation_factor = value
            return {
                "message": "All frequencies in current zone set to " + str(value) + "x", 
                "color": output_color_system
            }
        
        _:
            return {"message": "Unknown frequency type: " + frequency_type, "color": output_color_error}

func _cmd_timescale(args: Array) -> Dictionary:
    if not zone_scale_system:
        return {"message": "Zone scale system not connected", "color": output_color_error}
    
    if args.size() < 2:
        return {"message": "Usage: /timescale <zone_id|current> <value>", "color": output_color_error}
    
    var zone_id = args[0]
    var value = float(args[1])
    value = clamp(value, 0.1, 5.0)  // Limit between 0.1x and 5.0x
    
    if zone_id.to_lower() == "current":
        zone_id = zone_scale_system.get_current_zone_id()
        
        if zone_id == "":
            return {"message": "Not currently in any zone. Specify a zone ID or enter a zone.", "color": output_color_error}
    
    if not zone_scale_system.active_zones.has(zone_id):
        return {"message": "Zone ID not found: " + zone_id, "color": output_color_error}
    
    zone_scale_system.active_zones[zone_id].time_dilation = value
    
    return {
        "message": "Time scale in zone " + zone_id + " set to " + str(value) + "x", 
        "color": output_color_system
    }

func _cmd_chunk(args: Array) -> Dictionary:
    if not zone_scale_system:
        return {"message": "Zone scale system not connected", "color": output_color_error}
    
    if args.size() < 1:
        return {"message": "Usage: /chunk <create|destroy|modify> [args]", "color": output_color_error}
    
    var subcommand = args[0].to_lower()
    
    match subcommand:
        "create":
            return _cmd_chunk_create(args.slice(1))
        "destroy":
            return _cmd_chunk_destroy(args.slice(1))
        "modify":
            return _cmd_chunk_modify(args.slice(1))
        _:
            return {"message": "Unknown chunk subcommand: " + subcommand, "color": output_color_error}

func _cmd_chunk_create(args: Array) -> Dictionary:
    if args.size() < 1:
        return {"message": "Usage: /chunk create <chunk_name> [scale_level] [x y z]", "color": output_color_error}
    
    var chunk_name = args[0]
    var scale_level = "human"  // Default
    var position = Vector3.ZERO
    
    if args.size() >= 2:
        scale_level = args[1].to_lower()
        
        // Check scale level validity
        if not scale_level in zone_scale_system.scale_levels:
            var valid_scales = ", ".join(zone_scale_system.scale_levels)
            return {"message": "Invalid scale level. Valid options: " + valid_scales, "color": output_color_error}
    
    if args.size() >= 5:
        position = Vector3(float(args[2]), float(args[3]), float(args[4]))
    elif player_controller:
        // Use position in front of player
        position = player_controller.global_position + player_controller.camera_mount.global_transform.basis.z * -10.0
    
    // Create a custom chunk with properties based on name
    var properties = {
        "name": chunk_name,
        "custom_chunk": true,
        "creation_time": Time.get_ticks_msec() / 1000.0
    }
    
    // Random zone type based on chunk name hash
    var hash_value = 0
    for i in range(chunk_name.length()):
        hash_value += chunk_name.unicode_at(i)
    
    var zone_type_index = hash_value % zone_scale_system.ZoneType.size()
    var zone_type = zone_scale_system.ZoneType.keys()[zone_type_index]
    
    // Create the zone representing this chunk
    var zone_id = zone_scale_system.create_custom_zone(position, 8.0, scale_level, zone_type, properties)
    
    if zone_id != "":
        return {
            "message": "Created '" + chunk_name + "' chunk at " + str(position) + " with " + scale_level + " scale", 
            "color": output_color_zone
        }
    else:
        return {"message": "Failed to create chunk", "color": output_color_error}

func _cmd_chunk_destroy(args: Array) -> Dictionary:
    if args.size() < 1:
        return {"message": "Usage: /chunk destroy <chunk_name|zone_id>", "color": output_color_error}
    
    var chunk_identifier = args[0]
    var found_zone_id = ""
    
    // Check if it's a direct zone ID
    if zone_scale_system.active_zones.has(chunk_identifier):
        found_zone_id = chunk_identifier
    else:
        // Search for chunk by name
        for zone_id in zone_scale_system.active_zones:
            var zone_data = zone_scale_system.active_zones[zone_id]
            
            if zone_data.has("properties") and zone_data.properties.has("name") and zone_data.properties.name == chunk_identifier:
                found_zone_id = zone_id
                break
    
    if found_zone_id == "":
        return {"message": "Chunk not found: " + chunk_identifier, "color": output_color_error}
    
    // Delete the zone
    if zone_scale_system.delete_zone(found_zone_id):
        return {"message": "Destroyed chunk: " + chunk_identifier, "color": output_color_zone}
    else:
        return {"message": "Failed to destroy chunk", "color": output_color_error}

func _cmd_chunk_modify(args: Array) -> Dictionary:
    if args.size() < 2:
        return {"message": "Usage: /chunk modify <chunk_name|zone_id> <property> <value>", "color": output_color_error}
    
    var chunk_identifier = args[0]
    var property = args[1].to_lower()
    var value = args[2] if args.size() >= 3 else "1.0"
    
    var found_zone_id = ""
    
    // Check if it's a direct zone ID
    if zone_scale_system.active_zones.has(chunk_identifier):
        found_zone_id = chunk_identifier
    else:
        // Search for chunk by name
        for zone_id in zone_scale_system.active_zones:
            var zone_data = zone_scale_system.active_zones[zone_id]
            
            if zone_data.has("properties") and zone_data.properties.has("name") and zone_data.properties.name == chunk_identifier:
                found_zone_id = zone_id
                break
    
    if found_zone_id == "":
        return {"message": "Chunk not found: " + chunk_identifier, "color": output_color_error}
    
    var zone_data = zone_scale_system.active_zones[found_zone_id]
    
    // Modify the specified property
    match property:
        "size", "radius":
            zone_data.radius = float(value)
            
            // Update visualization if available
            if zone_scale_system.visualization_enabled and zone_scale_system.zone_visualization_nodes.has(found_zone_id):
                var mesh = zone_scale_system.zone_visualization_nodes[found_zone_id].get_node("BoundaryMesh")
                if mesh and mesh.mesh:
                    mesh.mesh.radius = float(value)
                    mesh.mesh.height = float(value) * 2
        
        "scale":
            if value in zone_scale_system.scale_levels:
                zone_data.scale_level = value
            else:
                return {"message": "Invalid scale level. Valid options: " + ", ".join(zone_scale_system.scale_levels), "color": output_color_error}
        
        "type":
            var zone_type_index = -1
            for i in range(zone_scale_system.ZoneType.size()):
                if zone_scale_system.ZoneType.keys()[i].to_lower() == value.to_lower():
                    zone_type_index = i
                    break
            
            if zone_type_index >= 0:
                zone_data.zone_type = zone_type_index
                
                // Update visualization if available
                if zone_scale_system.visualization_enabled and zone_scale_system.zone_visualization_nodes.has(found_zone_id):
                    var mesh = zone_scale_system.zone_visualization_nodes[found_zone_id].get_node("BoundaryMesh")
                    if mesh and mesh.material_override:
                        mesh.material_override.albedo_color = zone_scale_system.get_zone_color(zone_type_index, zone_data.scale_level)
                        mesh.material_override.emission = mesh.material_override.albedo_color
            else:
                return {"message": "Invalid zone type. Valid options: " + ", ".join(zone_scale_system.ZoneType.keys()), "color": output_color_error}
        
        "evolution":
            zone_data.evolution_factor = float(value)
        
        "destruction":
            zone_data.destruction_factor = float(value)
        
        "manifestation":
            zone_data.manifestation_factor = float(value)
        
        "time", "timescale":
            zone_data.time_dilation = float(value)
        
        _:
            return {"message": "Unknown property: " + property, "color": output_color_error}
    
    // Update the zone label
    if zone_scale_system.visualization_enabled and zone_scale_system.zone_visualization_nodes.has(found_zone_id):
        var label = zone_scale_system.zone_visualization_nodes[found_zone_id].get_node("ZoneLabel")
        if label:
            label.text = zone_scale_system.get_zone_description(found_zone_id)
    
    return {
        "message": "Modified " + property + " of chunk " + chunk_identifier + " to " + value, 
        "color": output_color_zone
    }

# ----- HELPER FUNCTIONS -----
func rand_array(arr: Array):
    if arr.size() == 0:
        return null
    return arr[randi() % arr.size()]

# ----- PUBLIC API -----
func set_references(console_ref, zone_scale_ref, word_seed_ref, player_ref):
    console = console_ref
    zone_scale_system = zone_scale_ref
    word_seed_evolution = word_seed_ref
    player_controller = player_ref
    
    // Register commands
    register_commands()