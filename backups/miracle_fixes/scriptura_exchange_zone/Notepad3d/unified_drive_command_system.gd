extends Node

class_name UnifiedDriveCommandSystem

# Constants for drive connection
const DRIVE_MAPPINGS = {
    "C_DRIVE": {
        "path": "/mnt/c",
        "color": Color(0.2, 0.7, 0.3, 1.0),  # Green
        "frequency": 333,
        "symbol": "©",
        "type": "LOCAL"
    },
    "D_DRIVE": {
        "path": "/mnt/d",
        "color": Color(0.3, 0.5, 0.9, 1.0),  # Blue
        "frequency": 555,
        "symbol": "Đ",
        "type": "NETWORK"
    },
    "VIRTUAL_DRIVE": {
        "path": "res://virtual_drive",
        "color": Color(0.8, 0.3, 0.8, 1.0),  # Purple
        "frequency": 777,
        "symbol": "∞",
        "type": "VIRTUAL"
    }
}

# Solar cycle constants
const SOLAR_CYCLES = {
    "DAWN": {
        "color": Color(1.0, 0.8, 0.4, 1.0),  # Golden yellow
        "frequency": 89,
        "commands": ["wake", "illuminate", "initialize", "connect", "activate"],
        "time_range": [5, 8]  # 5:00 AM - 8:00 AM
    },
    "NOON": {
        "color": Color(1.0, 0.9, 0.0, 1.0),  # Bright yellow
        "frequency": 389,
        "commands": ["maximize", "sync", "process", "transport", "accelerate"],
        "time_range": [11, 14]  # 11:00 AM - 2:00 PM
    },
    "DUSK": {
        "color": Color(1.0, 0.5, 0.2, 1.0),  # Orange
        "frequency": 99,
        "commands": ["transition", "merge", "transform", "evolve", "adapt"],
        "time_range": [17, 20]  # 5:00 PM - 8:00 PM
    },
    "NIGHT": {
        "color": Color(0.2, 0.3, 0.7, 1.0),  # Deep blue
        "frequency": 999,
        "commands": ["dream", "store", "analyze", "reflect", "integrate"],
        "time_range": [22, 4]  # 10:00 PM - 4:00 AM
    }
}

# Command system constants
const COMMAND_PREFIXES = {
    "STANDARD": "#",
    "URGENT": "##",
    "SYSTEM": "@",
    "LINK": "$$$",
    "SHAPE": "∆",
    "WORD": "§",
    "CHAOS": "###"
}

const COMMAND_TERMINATORS = [".", ";", "!", "?", ":", ""]
const LUCKY_NUMBERS = [9, 33, 89, 99, 333, 389, 555, 777, 999]

# Connected systems
var drive_connector = null
var terminal_bridge = null
var message_timeline = null
var word_system = null

# System state
var active_drives = {}
var command_history = []
var connected_words = {}
var current_solar_cycle = "NOON"
var current_command_chain = []
var online_status = false
var vertical_shapes = []

# Signals
signal command_executed(command, result)
signal drive_connected(drive_id)
signal solar_cycle_changed(cycle)
signal word_connected(word, drives)
signal shape_changed(shape_id, properties)
signal chaos_event(type, intensity)

func _init():
    print("Initializing Unified Drive Command System...")
    
    # Connect to required systems
    _connect_systems()
    
    # Initialize drives
    _initialize_drives()
    
    # Determine current solar cycle based on time
    _update_solar_cycle()
    
    # Initialize vertical shapes
    _initialize_vertical_shapes()
    
    print("Unified Drive Command System initialized")

func _connect_systems():
    # Connect to DriveConnector
    if ClassDB.class_exists("DriveConnector"):
        drive_connector = load("res://drive_connector.gd").new()
        print("Connected to DriveConnector")
    else:
        print("DriveConnector not available, trying to load directly")
        var script = load("/mnt/c/Users/Percision 15/drive_connector.gd")
        if script:
            drive_connector = script.new()
            print("Loaded DriveConnector directly")
        else:
            print("DriveConnector not found, creating stub")
            drive_connector = Node.new()
            drive_connector.name = "DriveConnectorStub"
    
    # Connect to TerminalVisualBridge
    if ClassDB.class_exists("TerminalVisualBridge"):
        terminal_bridge = load("res://terminal_visual_bridge.gd").new()
        print("Connected to TerminalVisualBridge")
    else:
        print("TerminalVisualBridge not available, trying to load directly")
        var script = load("/mnt/c/Users/Percision 15/terminal_visual_bridge.gd")
        if script:
            terminal_bridge = script.new()
            print("Loaded TerminalVisualBridge directly")
        else:
            print("TerminalVisualBridge not found, creating stub")
            terminal_bridge = Node.new()
            terminal_bridge.name = "TerminalBridgeStub"
    
    # Connect to MessageTimelineConnector
    if ClassDB.class_exists("MessageTimelineConnector"):
        message_timeline = load("res://message_timeline_connector.gd").new()
        print("Connected to MessageTimelineConnector")
    else:
        print("MessageTimelineConnector not available, trying to load directly")
        var script = load("/mnt/c/Users/Percision 15/message_timeline_connector.gd")
        if script:
            message_timeline = script.new()
            print("Loaded MessageTimelineConnector directly")
        else:
            print("MessageTimelineConnector not found, creating stub")
            message_timeline = Node.new()
            message_timeline.name = "MessageTimelineStub"
    
    # Create or connect to WordSystem
    word_system = Node.new()
    word_system.name = "WordSystem"
    add_child(word_system)

func _initialize_drives():
    # Connect all three drives
    for drive_id in DRIVE_MAPPINGS.keys():
        var drive_data = DRIVE_MAPPINGS[drive_id]
        
        if drive_connector and drive_connector.has_method("connect_drive"):
            var result = drive_connector.connect_drive(
                drive_id, 
                drive_id, 
                drive_data.type, 
                drive_data.path
            )
            
            if result:
                active_drives[drive_id] = {
                    "id": drive_id,
                    "status": "ONLINE",
                    "connection_time": OS.get_unix_time(),
                    "commands": [],
                    "words": []
                }
                
                emit_signal("drive_connected", drive_id)
            }
        }
    
    if active_drives.size() > 0:
        online_status = true
        print("Drives connected: " + str(active_drives.size()) + " / " + str(DRIVE_MAPPINGS.size()))
    }

func _update_solar_cycle():
    # Get current hour
    var datetime = Time.get_datetime_dict_from_system()
    var current_hour = datetime.hour
    
    # Determine solar cycle
    var new_cycle = "NOON"  # Default
    
    for cycle in SOLAR_CYCLES.keys():
        var time_range = SOLAR_CYCLES[cycle].time_range
        var start_hour = time_range[0]
        var end_hour = time_range[1]
        
        if end_hour < start_hour:  # Handles ranges that cross midnight
            if current_hour >= start_hour or current_hour < end_hour:
                new_cycle = cycle
                break
        else:
            if current_hour >= start_hour and current_hour < end_hour:
                new_cycle = cycle
                break
        }
    
    if new_cycle != current_solar_cycle:
        current_solar_cycle = new_cycle
        emit_signal("solar_cycle_changed", current_solar_cycle)
        
        # Update terminal colors based on solar cycle
        if terminal_bridge and terminal_bridge.has_method("set_temperature"):
            var cycle_data = SOLAR_CYCLES[current_solar_cycle]
            terminal_bridge.set_temperature(_get_temperature_for_cycle(current_solar_cycle))
        }
    
    return current_solar_cycle

func _get_temperature_for_cycle(cycle):
    match cycle:
        "DAWN":
            return "COOL"
        "NOON":
            return "HOT"
        "DUSK":
            return "WARM"
        "NIGHT":
            return "VERY_COLD"
        _:
            return "NEUTRAL"

func _initialize_vertical_shapes():
    # Create initial set of vertical shapes
    vertical_shapes = [
        {
            "id": "pyramid",
            "height": 5,
            "width": 9,
            "color": SOLAR_CYCLES[current_solar_cycle].color,
            "frequency": SOLAR_CYCLES[current_solar_cycle].frequency,
            "rotation": 0.0,
            "active": true
        },
        {
            "id": "column",
            "height": 8,
            "width": 3,
            "color": Color(0.5, 0.5, 0.9, 1.0),
            "frequency": 333,
            "rotation": 0.0,
            "active": true
        },
        {
            "id": "wave",
            "height": 3,
            "width": 12,
            "color": Color(0.3, 0.8, 0.4, 1.0),
            "frequency": 89,
            "rotation": 0.0,
            "active": true
        }
    ]

func _process(delta):
    # Update solar cycle periodically
    if OS.get_unix_time() % 300 == 0:  # Every 5 minutes
        _update_solar_cycle()
    
    # Update vertical shapes
    _update_vertical_shapes(delta)
    
    # Process any pending command chains
    if current_command_chain.size() > 0:
        _process_command_chain()

func _update_vertical_shapes(delta):
    for shape in vertical_shapes:
        if shape.active:
            # Animate shape properties based on frequency
            shape.rotation += delta * (shape.frequency * 0.001)
            
            # Cycle through color hues based on frequency
            var color = shape.color
            var h = color.h + delta * (shape.frequency * 0.0002)
            if h > 1.0:
                h -= 1.0
            color.h = h
            shape.color = color
            
            # Emit shape changed signal periodically
            if randf() < 0.02:  # 2% chance per frame
                emit_signal("shape_changed", shape.id, shape)
        }

func _process_command_chain():
    if current_command_chain.size() == 0:
        return
    
    # Process the next command in the chain
    var command = current_command_chain[0]
    current_command_chain.remove_at(0)
    
    var result = process_command(command)
    
    # Special case for chaos commands which might generate additional commands
    if command.begins_with(COMMAND_PREFIXES.CHAOS):
        var chaos_intensity = randf()
        emit_signal("chaos_event", "command_chaos", chaos_intensity)
        
        if chaos_intensity > 0.7:  # High chaos
            # Add random commands to the chain
            var cycle_commands = SOLAR_CYCLES[current_solar_cycle].commands
            var random_command = cycle_commands[randi() % cycle_commands.size()]
            current_command_chain.append(random_command)
        }
    
    # If chain is complete, emit signal
    if current_command_chain.size() == 0:
        print("Command chain completed")

func process_command(command_text):
    print("Processing command: " + command_text)
    
    # Normalize command text
    command_text = command_text.strip_edges()
    
    # Add to history
    command_history.append({
        "command": command_text,
        "timestamp": OS.get_unix_time(),
        "cycle": current_solar_cycle
    })
    
    # Parse command prefix
    var prefix = ""
    var base_command = command_text
    
    for prefix_key in COMMAND_PREFIXES.keys():
        var current_prefix = COMMAND_PREFIXES[prefix_key]
        if command_text.begins_with(current_prefix):
            prefix = prefix_key
            base_command = command_text.substr(current_prefix.length())
            break
        }
    
    # Remove terminator if present
    for terminator in COMMAND_TERMINATORS:
        if terminator != "" and base_command.ends_with(terminator):
            base_command = base_command.substr(0, base_command.length() - terminator.length())
            break
        }
    
    # Process based on prefix
    var result = null
    
    match prefix:
        "STANDARD":
            result = _process_standard_command(base_command)
        "URGENT":
            result = _process_urgent_command(base_command)
        "SYSTEM":
            result = _process_system_command(base_command)
        "LINK":
            result = _process_link_command(base_command)
        "SHAPE":
            result = _process_shape_command(base_command)
        "WORD":
            result = _process_word_command(base_command)
        "CHAOS":
            result = _process_chaos_command(base_command)
        _:
            # No prefix, treat as standard command
            result = _process_standard_command(base_command)
    
    # Emit command executed signal
    emit_signal("command_executed", command_text, result)
    
    return result

func _process_standard_command(command):
    # Split command into parts
    var parts = command.split(" ", false)
    if parts.size() == 0:
        return null
    
    var cmd = parts[0].to_lower()
    var args = parts.slice(1)
    
    # Check if command is in current solar cycle commands
    var cycle_commands = SOLAR_CYCLES[current_solar_cycle].commands
    if not cmd in cycle_commands:
        print("Command not available in current solar cycle: " + cmd)
        
        # Suggest available commands
        var suggestion = "Available commands in " + current_solar_cycle + ": " + str(cycle_commands)
        return {"error": "Command not available", "suggestion": suggestion}
    }
    
    # Process command
    match cmd:
        "connect":
            if args.size() > 0:
                return connect_drive(args[0])
            else:
                return connect_all_drives()
        
        "sync":
            if args.size() >= 2:
                return sync_drives(args[0], args[1])
            else:
                return sync_all_drives()
        
        "process":
            if args.size() > 0:
                return process_data(args[0])
            else:
                return {"error": "Data ID required"}
        
        "transport":
            if args.size() >= 3:
                return transport_data(args[0], args[1], args[2])
            else:
                return {"error": "Source drive, target drive, and data ID required"}
        
        "initialize":
            return initialize_system()
        
        "activate":
            if args.size() > 0:
                return activate_component(args[0])
            else:
                return {"error": "Component name required"}
        
        "store":
            if args.size() >= 3:
                return store_data(args[0], args[1], args[2])
            else:
                return {"error": "Drive ID, data ID, and content required"}
        
        "analyze":
            if args.size() >= 2:
                return analyze_data(args[0], args[1])
            else:
                return {"error": "Drive ID and data ID required"}
        
        "transform":
            if args.size() >= 2:
                return transform_data(args[0], args.slice(1).join(" "))
            else:
                return {"error": "Data ID and transformation type required"}
        
        "accelerate":
            if args.size() > 0:
                return accelerate_process(args[0])
            else:
                return accelerate_all_processes()
        
        "illuminate":
            if args.size() > 0:
                return illuminate_drive(args[0])
            else:
                return illuminate_all_drives()
        
        "wake":
            return wake_system()
        
        "dream":
            if args.size() > 0:
                return dream_data(args[0])
            else:
                return dream_random()
        
        "reflect":
            if args.size() > 0:
                return reflect_on_data(args[0])
            else:
                return reflect_on_system()
        
        "integrate":
            if args.size() >= 2:
                return integrate_data(args[0], args[1])
            else:
                return {"error": "Source and target data IDs required"}
        
        "adapt":
            if args.size() > 0:
                return adapt_to_condition(args[0])
            else:
                return adapt_to_current_conditions()
        
        "evolve":
            if args.size() > 0:
                return evolve_component(args[0])
            else:
                return evolve_system()
        
        "maximize":
            if args.size() > 0:
                return maximize_component(args[0])
            else:
                return maximize_system()
        
        "merge":
            if args.size() >= 2:
                return merge_data(args[0], args[1])
            else:
                return {"error": "Source and target data IDs required"}
        
        "transition":
            if args.size() > 0:
                return transition_to_state(args[0])
            else:
                return {"error": "Target state required"}
        
        _:
            return {"error": "Unknown command: " + cmd}

func _process_urgent_command(command):
    # Urgent commands get priority and execute immediately
    var result = _process_standard_command(command)
    
    # Log urgent command
    print("URGENT command executed: " + command)
    
    # Notify terminal of urgent command
    if terminal_bridge and terminal_bridge.has_method("process_terminal_command"):
        terminal_bridge.process_terminal_command("energy", ["0", "1"])  # Activate energy flow
    }
    
    return result

func _process_system_command(command):
    # System commands for managing the unified command system itself
    var parts = command.split(" ", false)
    if parts.size() == 0:
        return null
    
    var cmd = parts[0].to_lower()
    var args = parts.slice(1)
    
    match cmd:
        "status":
            return get_system_status()
        
        "reset":
            return reset_system()
        
        "cycle":
            if args.size() > 0:
                return force_solar_cycle(args[0])
            else:
                return {"current_cycle": current_solar_cycle}
        
        "online":
            online_status = true
            return {"status": "ONLINE"}
        
        "offline":
            online_status = false
            return {"status": "OFFLINE"}
        
        "history":
            return get_command_history()
        
        "clear":
            command_history.clear()
            return {"cleared": true}
        
        "version":
            return {"version": "1.0", "system": "UnifiedDriveCommandSystem"}
        
        _:
            return {"error": "Unknown system command: " + cmd}

func _process_link_command(command):
    # Link commands for connecting drives, words, and systems
    var parts = command.split(" ", false)
    if parts.size() < 2:
        return {"error": "Link commands require at least two arguments"}
    
    var source = parts[0]
    var target = parts[1]
    var link_type = "standard"
    
    if parts.size() >= 3:
        link_type = parts[2]
    }
    
    # Create link
    print("Creating link: " + source + " → " + target + " (" + link_type + ")")
    
    if drive_connector and drive_connector.has_method("sync_drives"):
        if source in active_drives and target in active_drives:
            var sync_id = drive_connector.sync_drives(source, target)
            return {"link_created": true, "sync_id": sync_id}
        }
    }
    
    # Special case for linking words
    if link_type == "word" and word_system:
        connect_word(source, target)
        return {"word_linked": true, "source": source, "target": target}
    }
    
    return {"link_attempted": true, "status": "unknown"}

func _process_shape_command(command):
    // Shape commands for manipulating vertical shapes
    var parts = command.split(" ", false)
    if parts.size() == 0:
        return {"shapes": vertical_shapes}
    
    var cmd = parts[0].to_lower()
    var args = parts.slice(1)
    
    match cmd:
        "create":
            if args.size() >= 2:
                var shape_id = args[0]
                var shape_type = args[1]
                return create_shape(shape_id, shape_type)
            else:
                return {"error": "Shape ID and type required"}
        
        "modify":
            if args.size() >= 3:
                var shape_id = args[0]
                var property = args[1]
                var value = args[2]
                return modify_shape(shape_id, property, value)
            else:
                return {"error": "Shape ID, property, and value required"}
        
        "activate":
            if args.size() > 0:
                var shape_id = args[0]
                return activate_shape(shape_id)
            else:
                return {"error": "Shape ID required"}
        
        "deactivate":
            if args.size() > 0:
                var shape_id = args[0]
                return deactivate_shape(shape_id)
            else:
                return {"error": "Shape ID required"}
        
        "rotate":
            if args.size() >= 2:
                var shape_id = args[0]
                var angle = float(args[1])
                return rotate_shape(shape_id, angle)
            else:
                return {"error": "Shape ID and angle required"}
        
        "color":
            if args.size() >= 2:
                var shape_id = args[0]
                var color_name = args[1]
                return color_shape(shape_id, color_name)
            else:
                return {"error": "Shape ID and color required"}
        
        "list":
            return {"shapes": vertical_shapes}
        
        _:
            return {"error": "Unknown shape command: " + cmd}

func _process_word_command(command):
    // Word commands for manipulating connected words
    var parts = command.split(" ", false)
    if parts.size() == 0:
        return {"words": connected_words}
    
    var cmd = parts[0].to_lower()
    var args = parts.slice(1)
    
    match cmd:
        "connect":
            if args.size() >= 2:
                var word = args[0]
                var drives = args.slice(1)
                return connect_word(word, drives)
            else:
                return {"error": "Word and at least one drive required"}
        
        "disconnect":
            if args.size() > 0:
                var word = args[0]
                return disconnect_word(word)
            else:
                return {"error": "Word required"}
        
        "list":
            return {"words": connected_words}
        
        "search":
            if args.size() > 0:
                var pattern = args[0]
                return search_words(pattern)
            else:
                return {"error": "Search pattern required"}
        
        "process":
            if args.size() > 0:
                var word = args[0]
                return process_word(word)
            else:
                return {"error": "Word required"}
        
        "reverse":
            if args.size() > 0:
                var word = args[0]
                return reverse_word(word)
            else:
                return {"error": "Word required"}
        
        _:
            return {"error": "Unknown word command: " + cmd}

func _process_chaos_command(command):
    // Chaos commands introduce randomness and unpredictability
    var chaos_level = randf()
    var chaos_result = {"chaos_level": chaos_level}
    
    // Random effects based on chaos level
    if chaos_level < 0.3:
        // Low chaos - minor effects
        var random_shape = vertical_shapes[randi() % vertical_shapes.size()]
        random_shape.color = Color(randf(), randf(), randf())
        chaos_result["effect"] = "color_shift"
    elif chaos_level < 0.7:
        // Medium chaos - command substitution
        var cycle_commands = SOLAR_CYCLES[current_solar_cycle].commands
        var random_command = cycle_commands[randi() % cycle_commands.size()]
        process_command(random_command)
        chaos_result["effect"] = "command_substitution"
    else:
        // High chaos - system change
        var cycles = SOLAR_CYCLES.keys()
        var random_cycle = cycles[randi() % cycles.size()]
        force_solar_cycle(random_cycle)
        chaos_result["effect"] = "cycle_shift"
    }
    
    emit_signal("chaos_event", "chaos_command", chaos_level)
    return chaos_result

# Command implementation functions
func connect_drive(drive_id):
    if not drive_id in DRIVE_MAPPINGS:
        return {"error": "Unknown drive: " + drive_id}
    
    if drive_id in active_drives:
        return {"already_connected": true, "drive": drive_id}
    
    var drive_data = DRIVE_MAPPINGS[drive_id]
    
    if drive_connector and drive_connector.has_method("connect_drive"):
        var result = drive_connector.connect_drive(
            drive_id,
            drive_id,
            drive_data.type,
            drive_data.path
        )
        
        if result:
            active_drives[drive_id] = {
                "id": drive_id,
                "status": "ONLINE",
                "connection_time": OS.get_unix_time(),
                "commands": [],
                "words": []
            }
            
            emit_signal("drive_connected", drive_id)
            return {"connected": true, "drive": drive_id}
        }
    }
    
    return {"error": "Failed to connect drive: " + drive_id}

func connect_all_drives():
    var results = {}
    
    for drive_id in DRIVE_MAPPINGS.keys():
        if not drive_id in active_drives:
            results[drive_id] = connect_drive(drive_id)
        }
    }
    
    return results

func sync_drives(source_drive, target_drive):
    if not source_drive in active_drives:
        return {"error": "Source drive not connected: " + source_drive}
    
    if not target_drive in active_drives:
        return {"error": "Target drive not connected: " + target_drive}
    
    if drive_connector and drive_connector.has_method("sync_drives"):
        var sync_id = drive_connector.sync_drives(source_drive, target_drive)
        
        if sync_id:
            return {"sync_started": true, "sync_id": sync_id}
        }
    }
    
    return {"error": "Failed to sync drives"}

func sync_all_drives():
    var results = {}
    var drive_ids = active_drives.keys()
    
    for i in range(drive_ids.size()):
        var source_drive = drive_ids[i]
        
        for j in range(drive_ids.size()):
            if i != j:
                var target_drive = drive_ids[j]
                var sync_key = source_drive + "_to_" + target_drive
                results[sync_key] = sync_drives(source_drive, target_drive)
            }
        }
    }
    
    return results

func process_data(data_id):
    // Find data in any connected drive
    var drive_with_data = null
    var data_content = null
    
    for drive_id in active_drives.keys():
        if drive_connector and drive_connector.has_method("get_data"):
            var data = drive_connector.get_data(drive_id, data_id)
            
            if data:
                drive_with_data = drive_id
                data_content = data
                break
            }
        }
    }
    
    if not drive_with_data:
        return {"error": "Data not found: " + data_id}
    }
    
    // Process the data (in this case, we'll just analyze it)
    var processing_result = {
        "data_id": data_id,
        "source_drive": drive_with_data,
        "size": data_content.length(),
        "timestamp": OS.get_unix_time()
    }
    
    // Send to terminal for visualization
    if terminal_bridge and terminal_bridge.has_method("process_terminal_command"):
        terminal_bridge.process_terminal_command("energy", ["2", "active"])
    }
    
    return processing_result

func transport_data(source_drive, target_drive, data_id):
    if not source_drive in active_drives:
        return {"error": "Source drive not connected: " + source_drive}
    
    if not target_drive in active_drives:
        return {"error": "Target drive not connected: " + target_drive}
    
    // Get data from source drive
    var data_content = null
    
    if drive_connector and drive_connector.has_method("get_data"):
        data_content = drive_connector.get_data(source_drive, data_id)
    }
    
    if not data_content:
        return {"error": "Data not found on source drive: " + data_id}
    }
    
    // Store data to target drive
    if drive_connector and drive_connector.has_method("store_data"):
        var result = drive_connector.store_data(target_drive, data_id, data_content)
        
        if result:
            return {
                "transported": true,
                "data_id": data_id,
                "source_drive": source_drive,
                "target_drive": target_drive
            }
        }
    }
    
    return {"error": "Failed to transport data"}

func initialize_system():
    // Reset and reinitialize all system components
    
    // Reconnect drives
    _initialize_drives()
    
    // Reset vertical shapes
    _initialize_vertical_shapes()
    
    // Update solar cycle
    _update_solar_cycle()
    
    // Clear command history
    command_history.clear()
    
    return {
        "initialized": true,
        "drives": active_drives.size(),
        "cycle": current_solar_cycle
    }

func activate_component(component_name):
    match component_name:
        "drives":
            return connect_all_drives()
        
        "terminal":
            if terminal_bridge:
                return {"activated": true, "component": "terminal"}
            else:
                return {"error": "Terminal bridge not available"}
        
        "timeline":
            if message_timeline:
                return {"activated": true, "component": "timeline"}
            else:
                return {"error": "Message timeline not available"}
        
        "words":
            return {"activated": true, "component": "words", "words": connected_words.size()}
        
        "shapes":
            for shape in vertical_shapes:
                shape.active = true
            }
            return {"activated": true, "component": "shapes", "shapes": vertical_shapes.size()}
        
        _:
            return {"error": "Unknown component: " + component_name}

func store_data(drive_id, data_id, content):
    if not drive_id in active_drives:
        return {"error": "Drive not connected: " + drive_id}
    
    if drive_connector and drive_connector.has_method("store_data"):
        var result = drive_connector.store_data(drive_id, data_id, content)
        
        if result:
            return {"stored": true, "drive": drive_id, "data_id": data_id}
        }
    }
    
    return {"error": "Failed to store data"}

func analyze_data(drive_id, data_id):
    if not drive_id in active_drives:
        return {"error": "Drive not connected: " + drive_id}
    
    var data_content = null
    
    if drive_connector and drive_connector.has_method("get_data"):
        data_content = drive_connector.get_data(drive_id, data_id)
    }
    
    if not data_content:
        return {"error": "Data not found: " + data_id}
    }
    
    // Analyze the data
    var analysis = {
        "data_id": data_id,
        "drive": drive_id,
        "size": data_content.length(),
        "timestamp": OS.get_unix_time(),
        "contains_numbers": data_content.is_valid_float() or data_content.is_valid_integer(),
        "contains_words": data_content.split(" ").size() > 1,
        "lucky_numbers": []
    }
    
    // Check for lucky numbers
    for lucky_number in LUCKY_NUMBERS:
        if data_content.find(str(lucky_number)) >= 0:
            analysis.lucky_numbers.append(lucky_number)
        }
    }
    
    return analysis

func transform_data(data_id, transformation_type):
    // Find data in any connected drive
    var drive_with_data = null
    var data_content = null
    
    for drive_id in active_drives.keys():
        if drive_connector and drive_connector.has_method("get_data"):
            var data = drive_connector.get_data(drive_id, data_id)
            
            if data:
                drive_with_data = drive_id
                data_content = data
                break
            }
        }
    }
    
    if not drive_with_data:
        return {"error": "Data not found: " + data_id}
    }
    
    // Transform the data based on type
    var transformed_data = data_content
    
    match transformation_type:
        "reverse":
            transformed_data = data_content.reverse()
        
        "uppercase":
            transformed_data = data_content.to_upper()
        
        "lowercase":
            transformed_data = data_content.to_lower()
        
        "rotate":
            // Rotate characters
            var chars = []
            for i in range(data_content.length()):
                chars.append(data_content[data_content.length() - 1 - i])
            }
            transformed_data = "".join(chars)
        
        "evolve":
            // Add some random variations
            var words = data_content.split(" ")
            var evolved_words = []
            
            for word in words:
                if randf() < 0.3:  // 30% chance to modify a word
                    if word.length() > 2:
                        var middle = word.substr(1, word.length() - 2)
                        var first = word[0]
                        var last = word[word.length() - 1]
                        evolved_words.append(first + middle.shuffle() + last)
                    } else {
                        evolved_words.append(word)
                    }
                } else {
                    evolved_words.append(word)
                }
            }
            
            transformed_data = " ".join(evolved_words)
        
        _:
            return {"error": "Unknown transformation type: " + transformation_type}
    
    // Store transformed data
    if drive_connector and drive_connector.has_method("update_data"):
        var result = drive_connector.update_data(drive_with_data, data_id, transformed_data)
        
        if result:
            return {
                "transformed": true,
                "data_id": data_id,
                "drive": drive_with_data,
                "transformation": transformation_type
            }
        }
    }
    
    return {"error": "Failed to transform data"}

func accelerate_process(process_id):
    // Acceleration depends on the type of process
    if process_id.begins_with("sync_"):
        // Accelerate sync operation
        if drive_connector and drive_connector.has_method("active_sync_operations"):
            var sync_ops = drive_connector.active_sync_operations
            
            if process_id in sync_ops:
                sync_ops[process_id].speed *= 2.0
                return {
                    "accelerated": true,
                    "process": process_id,
                    "new_speed": sync_ops[process_id].speed
                }
            }
        }
    } else if process_id.begins_with("msg_"):
        // Accelerate message timeline hatching
        if message_timeline and message_timeline.has_method("accelerate_hatching"):
            var result = message_timeline.accelerate_hatching(process_id, 2.0)
            
            if result:
                return {
                    "accelerated": true,
                    "process": process_id,
                    "type": "message_hatching"
                }
            }
        }
    }
    
    return {"error": "Process not found or cannot be accelerated: " + process_id}

func accelerate_all_processes():
    var results = {}
    
    // Accelerate all sync operations
    if drive_connector and drive_connector.has_method("active_sync_operations"):
        var sync_ops = drive_connector.active_sync_operations
        
        for sync_id in sync_ops.keys():
            sync_ops[sync_id].speed *= 2.0
            results[sync_id] = {
                "accelerated": true,
                "new_speed": sync_ops[sync_id].speed
            }
        }
    }
    
    return results

func illuminate_drive(drive_id):
    if not drive_id in active_drives:
        return {"error": "Drive not connected: " + drive_id}
    
    // Change visual representation of drive
    if drive_id in DRIVE_MAPPINGS:
        var drive_data = DRIVE_MAPPINGS[drive_id]
        var drive_color = drive_data.color
        
        // Send to terminal for visualization
        if terminal_bridge and terminal_bridge.has_method("process_terminal_command"):
            var color_name = _get_color_name(drive_color)
            terminal_bridge.process_terminal_command("colors", [color_name])
        }
        
        return {
            "illuminated": true,
            "drive": drive_id,
            "color": drive_data.color
        }
    }
    
    return {"error": "Failed to illuminate drive: " + drive_id}

func illuminate_all_drives():
    var results = {}
    
    for drive_id in active_drives.keys():
        results[drive_id] = illuminate_drive(drive_id)
    }
    
    return results

func _get_color_name(color):
    // Convert color to closest named color
    if color.r > 0.7 and color.g < 0.3 and color.b < 0.3:
        return "RED"
    elif color.r > 0.7 and color.g > 0.7 and color.b < 0.3:
        return "YELLOW"
    elif color.r < 0.3 and color.g > 0.7 and color.b < 0.3:
        return "GREEN"
    elif color.r < 0.3 and color.g < 0.3 and color.b > 0.7:
        return "BLUE"
    elif color.r > 0.7 and color.g > 0.3 and color.b < 0.3:
        return "ORANGE"
    elif color.r > 0.7 and color.g < 0.3 and color.b > 0.7:
        return "PURPLE"
    elif color.r > 0.7 and color.g > 0.7 and color.b > 0.7:
        return "WHITE"
    else:
        return "NEUTRAL"

func wake_system():
    // Set all components to active state
    online_status = true
    
    // Activate all shapes
    for shape in vertical_shapes:
        shape.active = true
    }
    
    // Connect all drives
    connect_all_drives()
    
    // Set solar cycle to DAWN
    force_solar_cycle("DAWN")
    
    return {
        "awake": true,
        "drives": active_drives.size(),
        "cycle": current_solar_cycle
    }

func dream_data(data_id):
    // Dream process creates variations of existing data
    // Find data in any connected drive
    var drive_with_data = null
    var data_content = null
    
    for drive_id in active_drives.keys():
        if drive_connector and drive_connector.has_method("get_data"):
            var data = drive_connector.get_data(drive_id, data_id)
            
            if data:
                drive_with_data = drive_id
                data_content = data
                break
            }
        }
    }
    
    if not drive_with_data:
        return {"error": "Data not found: " + data_id}
    }
    
    // Create a dream variation
    var dream_id = "dream_" + data_id
    var words = data_content.split(" ")
    var dream_words = []
    
    for word in words:
        if randf() < 0.7:  // 70% chance to keep original word
            dream_words.append(word)
        } else {
            // Replace with a connected word if possible
            var found_replacement = false
            
            for connected_word in connected_words.keys():
                if connected_word.length() == word.length() or randf() < 0.3:
                    dream_words.append(connected_word)
                    found_replacement = true
                    break
                }
            }
            
            if not found_replacement:
                dream_words.append(word)
            }
        }
    }
    
    var dream_content = " ".join(dream_words)
    
    // Store dream data
    if drive_connector and drive_connector.has_method("store_data"):
        var result = drive_connector.store_data(drive_with_data, dream_id, dream_content)
        
        if result:
            return {
                "dreamed": true,
                "original": data_id,
                "dream": dream_id,
                "drive": drive_with_data
            }
        }
    }
    
    return {"error": "Failed to create dream data"}

func dream_random():
    // Create a completely new dream from connected words
    if connected_words.size() == 0:
        return {"error": "No connected words to dream with"}
    }
    
    var dream_id = "dream_" + str(OS.get_unix_time())
    var dream_words = []
    var word_count = 5 + randi() % 10  // 5-15 words
    
    var word_keys = connected_words.keys()
    
    for i in range(word_count):
        var random_word = word_keys[randi() % word_keys.size()]
        dream_words.append(random_word)
    }
    
    var dream_content = " ".join(dream_words)
    
    // Store in a random drive
    var drive_ids = active_drives.keys()
    if drive_ids.size() > 0:
        var random_drive = drive_ids[randi() % drive_ids.size()]
        
        if drive_connector and drive_connector.has_method("store_data"):
            var result = drive_connector.store_data(random_drive, dream_id, dream_content)
            
            if result:
                return {
                    "dreamed": true,
                    "dream": dream_id,
                    "drive": random_drive,
                    "content": dream_content
                }
            }
        }
    }
    
    return {"error": "Failed to create random dream"}

func reflect_on_data(data_id):
    // Reflection creates metadata about existing data
    // Find data in any connected drive
    var drive_with_data = null
    var data_content = null
    
    for drive_id in active_drives.keys():
        if drive_connector and drive_connector.has_method("get_data"):
            var data = drive_connector.get_data(drive_id, data_id)
            
            if data:
                drive_with_data = drive_id
                data_content = data
                break
            }
        }
    }
    
    if not drive_with_data:
        return {"error": "Data not found: " + data_id}
    }
    
    // Create a reflection
    var reflection_id = "reflection_" + data_id
    var words = data_content.split(" ")
    
    var reflection = {
        "original_id": data_id,
        "word_count": words.size(),
        "character_count": data_content.length(),
        "drive": drive_with_data,
        "timestamp": OS.get_unix_time(),
        "solar_cycle": current_solar_cycle,
        "connected_words": []
    }
    
    // Find connected words in the data
    for word in words:
        if word in connected_words:
            reflection.connected_words.append(word)
        }
    }
    
    // Store reflection as JSON
    var reflection_content = JSON.stringify(reflection)
    
    if drive_connector and drive_connector.has_method("store_data"):
        var result = drive_connector.store_data(drive_with_data, reflection_id, reflection_content)
        
        if result:
            return {
                "reflected": true,
                "original": data_id,
                "reflection": reflection_id,
                "drive": drive_with_data
            }
        }
    }
    
    return {"error": "Failed to create reflection"}

func reflect_on_system():
    // Create a system-wide reflection
    var reflection = {
        "timestamp": OS.get_unix_time(),
        "solar_cycle": current_solar_cycle,
        "drives": active_drives.size(),
        "commands": command_history.size(),
        "words": connected_words.size(),
        "shapes": vertical_shapes.size(),
        "online": online_status
    }
    
    var reflection_id = "system_reflection_" + str(OS.get_unix_time())
    var reflection_content = JSON.stringify(reflection)
    
    // Store in all connected drives
    var results = {}
    
    for drive_id in active_drives.keys():
        if drive_connector and drive_connector.has_method("store_data"):
            var result = drive_connector.store_data(drive_id, reflection_id, reflection_content)
            results[drive_id] = result
        }
    }
    
    return {
        "reflected": true,
        "reflection": reflection_id,
        "drives": results
    }

func integrate_data(source_id, target_id):
    // Integration combines two pieces of data
    // Find source data
    var source_drive = null
    var source_content = null
    
    for drive_id in active_drives.keys():
        if drive_connector and drive_connector.has_method("get_data"):
            var data = drive_connector.get_data(drive_id, source_id)
            
            if data:
                source_drive = drive_id
                source_content = data
                break
            }
        }
    }
    
    if not source_drive:
        return {"error": "Source data not found: " + source_id}
    }
    
    // Find target data
    var target_drive = null
    var target_content = null
    
    for drive_id in active_drives.keys():
        if drive_connector and drive_connector.has_method("get_data"):
            var data = drive_connector.get_data(drive_id, target_id)
            
            if data:
                target_drive = drive_id
                target_content = data
                break
            }
        }
    }
    
    if not target_drive:
        return {"error": "Target data not found: " + target_id}
    }
    
    // Integrate the data
    var integrated_id = "integrated_" + source_id + "_" + target_id
    var integrated_content = source_content + " " + target_content
    
    // Store in both drives
    var results = {}
    
    if drive_connector and drive_connector.has_method("store_data"):
        results[source_drive] = drive_connector.store_data(source_drive, integrated_id, integrated_content)
        results[target_drive] = drive_connector.store_data(target_drive, integrated_id, integrated_content)
    }
    
    return {
        "integrated": true,
        "source": source_id,
        "target": target_id,
        "integrated": integrated_id,
        "drives": results
    }

func adapt_to_condition(condition):
    // Adaptation changes system behavior based on conditions
    match condition:
        "low_energy":
            // Reduce activity
            for shape in vertical_shapes:
                shape.frequency *= 0.5
            }
            return {"adapted": true, "condition": "low_energy"}
        
        "high_traffic":
            // Prioritize certain operations
            return {"adapted": true, "condition": "high_traffic"}
        
        "offline":
            // Prepare for offline operation
            online_status = false
            return {"adapted": true, "condition": "offline"}
        
        "secure":
            // Increase security measures
            return {"adapted": true, "condition": "secure"}
        
        _:
            return {"error": "Unknown condition: " + condition}

func adapt_to_current_conditions():
    // Automatically detect and adapt to current conditions
    var conditions = []
    
    // Check drive status
    if active_drives.size() < DRIVE_MAPPINGS.size():
        conditions.append("limited_drives")
    }
    
    // Check time of day (solar cycle)
    if current_solar_cycle == "NIGHT":
        conditions.append("night_mode")
    }
    
    // Check command frequency
    if command_history.size() > 0:
        var last_command_time = command_history[command_history.size() - 1].timestamp
        var time_since_last = OS.get_unix_time() - last_command_time
        
        if time_since_last > 3600:  // More than an hour
            conditions.append("low_activity")
        } else if time_since_last < 60:  // Less than a minute
            conditions.append("high_activity")
        }
    }
    
    // Adapt to all detected conditions
    var results = {}
    
    for condition in conditions:
        results[condition] = adapt_to_condition(condition)
    }
    
    return {
        "adapted": conditions.size() > 0,
        "conditions": conditions,
        "results": results
    }

func evolve_component(component):
    // Evolution improves or changes components over time
    match component:
        "shapes":
            // Add a new shape based on existing ones
            var new_shape_id = "evolved_shape_" + str(vertical_shapes.size())
            var base_shape = vertical_shapes[randi() % vertical_shapes.size()]
            
            var new_shape = {
                "id": new_shape_id,
                "height": base_shape.height * (0.8 + randf() * 0.4),
                "width": base_shape.width * (0.8 + randf() * 0.4),
                "color": base_shape.color,
                "frequency": LUCKY_NUMBERS[randi() % LUCKY_NUMBERS.size()],
                "rotation": randf() * TAU,
                "active": true
            }
            
            vertical_shapes.append(new_shape)
            
            return {
                "evolved": true,
                "component": "shapes",
                "new_shape": new_shape_id
            }
        
        "words":
            // Evolve word connections
            if connected_words.size() == 0:
                return {"error": "No connected words to evolve"}
            }
            
            var word_keys = connected_words.keys()
            var word_pairs = []
            
            for i in range(min(5, word_keys.size())):
                var word1 = word_keys[randi() % word_keys.size()]
                var word2 = word_keys[randi() % word_keys.size()]
                
                if word1 != word2:
                    word_pairs.append([word1, word2])
                }
            }
            
            // Connect each pair
            var results = {}
            
            for pair in word_pairs:
                var w1 = pair[0]
                var w2 = pair[1]
                
                if not w2 in connected_words[w1].connections:
                    connected_words[w1].connections.append(w2)
                    results[w1 + "_" + w2] = true
                }
            }
            
            return {
                "evolved": true,
                "component": "words",
                "connections": results
            }
        
        "drives":
            // Evolve drive capabilities
            return {
                "evolved": true,
                "component": "drives"
            }
        
        _:
            return {"error": "Unknown component: " + component}

func evolve_system():
    // Evolve the entire system
    var results = {}
    
    results.shapes = evolve_component("shapes")
    results.words = evolve_component("words")
    results.drives = evolve_component("drives")
    
    // Also evolve the solar cycle
    var cycles = SOLAR_CYCLES.keys()
    var current_index = cycles.find(current_solar_cycle)
    var next_index = (current_index + 1) % cycles.size()
    var next_cycle = cycles[next_index]
    
    results.cycle = force_solar_cycle(next_cycle)
    
    return {
        "evolved": true,
        "components": results
    }

func maximize_component(component):
    // Maximize a component's capabilities
    match component:
        "shapes":
            // Make all shapes active and larger
            for shape in vertical_shapes:
                shape.active = true
                shape.height *= 1.5
                shape.width *= 1.5
            }
            
            return {
                "maximized": true,
                "component": "shapes",
                "shapes": vertical_shapes.size()
            }
        
        "drives":
            // Connect all drives and sync them
            connect_all_drives()
            sync_all_drives()
            
            return {
                "maximized": true,
                "component": "drives",
                "drives": active_drives.size()
            }
        
        "words":
            // Make all words connect to all drives
            var results = {}
            
            for word in connected_words.keys():
                connected_words[word].drives = active_drives.keys()
                results[word] = true
            }
            
            return {
                "maximized": true,
                "component": "words",
                "words": results
            }
        
        _:
            return {"error": "Unknown component: " + component}

func maximize_system():
    // Maximize the entire system
    var results = {}
    
    results.shapes = maximize_component("shapes")
    results.words = maximize_component("words")
    results.drives = maximize_component("drives")
    
    // Set to NOON cycle (maximum energy)
    results.cycle = force_solar_cycle("NOON")
    
    // Maximize terminal as well
    if terminal_bridge and terminal_bridge.has_method("process_terminal_command"):
        terminal_bridge.process_terminal_command("temp", ["HOT"])
        terminal_bridge.process_terminal_command("energy", ["1", "2", "3", "4"])
    }
    
    return {
        "maximized": true,
        "components": results
    }

func merge_data(source_id, target_id):
    // Similar to integrate but overwrites the target
    // Find source data
    var source_drive = null
    var source_content = null
    
    for drive_id in active_drives.keys():
        if drive_connector and drive_connector.has_method("get_data"):
            var data = drive_connector.get_data(drive_id, source_id)
            
            if data:
                source_drive = drive_id
                source_content = data
                break
            }
        }
    }
    
    if not source_drive:
        return {"error": "Source data not found: " + source_id}
    }
    
    // Find target data
    var target_drive = null
    var target_content = null
    
    for drive_id in active_drives.keys():
        if drive_connector and drive_connector.has_method("get_data"):
            var data = drive_connector.get_data(drive_id, target_id)
            
            if data:
                target_drive = drive_id
                target_content = data
                break
            }
        }
    }
    
    if not target_drive:
        return {"error": "Target data not found: " + target_id}
    }
    
    // Merge the data (source takes precedence)
    var merged_content = source_content
    
    // Update target with merged content
    if drive_connector and drive_connector.has_method("update_data"):
        var result = drive_connector.update_data(target_drive, target_id, merged_content)
        
        if result:
            return {
                "merged": true,
                "source": source_id,
                "target": target_id,
                "drive": target_drive
            }
        }
    }
    
    return {"error": "Failed to merge data"}

func transition_to_state(state):
    // Transition the system to a new state
    match state:
        "online":
            online_status = true
            return {"transitioned": true, "state": "online"}
        
        "offline":
            online_status = false
            return {"transitioned": true, "state": "offline"}
        
        "ready":
            // Set system to ready state
            online_status = true
            
            // Activate all components
            for shape in vertical_shapes:
                shape.active = true
            }
            
            return {"transitioned": true, "state": "ready"}
        
        "standby":
            // Set system to standby state
            for shape in vertical_shapes:
                shape.active = false
            }
            
            return {"transitioned": true, "state": "standby"}
        
        _:
            return {"error": "Unknown state: " + state}

func get_system_status():
    return {
        "online": online_status,
        "drives": active_drives.size(),
        "words": connected_words.size(),
        "shapes": vertical_shapes.size(),
        "commands": command_history.size(),
        "solar_cycle": current_solar_cycle,
        "timestamp": OS.get_unix_time()
    }

func reset_system():
    // Reset all system components
    active_drives.clear()
    command_history.clear()
    connected_words.clear()
    current_command_chain.clear()
    
    // Reinitialize
    _initialize_drives()
    _initialize_vertical_shapes()
    _update_solar_cycle()
    
    online_status = true
    
    return {
        "reset": true,
        "drives": active_drives.size(),
        "cycle": current_solar_cycle
    }

func force_solar_cycle(cycle):
    if not cycle in SOLAR_CYCLES:
        return {"error": "Unknown solar cycle: " + cycle}
    }
    
    current_solar_cycle = cycle
    emit_signal("solar_cycle_changed", current_solar_cycle)
    
    // Update terminal colors based on solar cycle
    if terminal_bridge and terminal_bridge.has_method("set_temperature"):
        var cycle_data = SOLAR_CYCLES[current_solar_cycle]
        terminal_bridge.set_temperature(_get_temperature_for_cycle(current_solar_cycle))
    }
    
    return {
        "cycle_changed": true,
        "cycle": current_solar_cycle
    }

func get_command_history():
    return command_history

func connect_word(word, drives):
    // Connect a word to one or more drives
    if not word in connected_words:
        connected_words[word] = {
            "word": word,
            "connection_time": OS.get_unix_time(),
            "drives": [],
            "connections": []
        }
    }
    
    var word_entry = connected_words[word]
    var connected_drive_ids = []
    
    // Handle drives as string or array
    var drive_ids = []
    if drives is String:
        drive_ids = [drives]
    } else if drives is Array:
        drive_ids = drives
    }
    
    // Connect to each drive
    for drive_id in drive_ids:
        if drive_id in active_drives and not drive_id in word_entry.drives:
            word_entry.drives.append(drive_id)
            connected_drive_ids.append(drive_id)
            
            // Add word to drive's word list
            active_drives[drive_id].words.append(word)
        }
    }
    
    emit_signal("word_connected", word, connected_drive_ids)
    
    return {
        "connected": true,
        "word": word,
        "drives": connected_drive_ids
    }

func disconnect_word(word):
    if not word in connected_words:
        return {"error": "Word not connected: " + word}
    }
    
    var word_entry = connected_words[word]
    var drive_ids = word_entry.drives.duplicate()
    
    // Remove word from drives
    for drive_id in drive_ids:
        if drive_id in active_drives:
            word_entry.drives.erase(drive_id)
            active_drives[drive_id].words.erase(word)
        }
    }
    
    // Remove word if no more drive connections
    if word_entry.drives.size() == 0 and word_entry.connections.size() == 0:
        connected_words.erase(word)
    }
    
    return {
        "disconnected": true,
        "word": word,
        "drives": drive_ids
    }

func search_words(pattern):
    var matching_words = []
    
    for word in connected_words.keys():
        if word.find(pattern) >= 0:
            matching_words.append(word)
        }
    }
    
    return {
        "pattern": pattern,
        "matches": matching_words
    }

func process_word(word):
    if not word in connected_words:
        return {"error": "Word not connected: " + word}
    }
    
    var word_entry = connected_words[word]
    
    // Process the word (in this case, find connections)
    var connected_drive_data = []
    
    for drive_id in word_entry.drives:
        if drive_id in active_drives:
            connected_drive_data.append({
                "drive": drive_id,
                "words": active_drives[drive_id].words
            })
        }
    }
    
    // Find similar words
    var similar_words = []
    
    for other_word in connected_words.keys():
        if word != other_word:
            // Check for partial match
            if word.length() >= 3 and other_word.length() >= 3:
                if word.find(other_word.substr(0, 3)) >= 0 or other_word.find(word.substr(0, 3)) >= 0:
                    similar_words.append(other_word)
                }
            }
        }
    }
    
    return {
        "word": word,
        "drives": word_entry.drives,
        "connections": word_entry.connections,
        "similar": similar_words,
        "drive_data": connected_drive_data
    }

func reverse_word(word):
    if not word in connected_words:
        return {"error": "Word not connected: " + word}
    }
    
    // Create reversed version of the word
    var reversed_word = ""
    for i in range(word.length() - 1, -1, -1):
        reversed_word += word[i]
    }
    
    // Connect the reversed word to the same drives
    var word_entry = connected_words[word]
    var result = connect_word(reversed_word, word_entry.drives)
    
    // Connect the words to each other
    if not reversed_word in word_entry.connections:
        word_entry.connections.append(reversed_word)
    }
    
    if reversed_word in connected_words and not word in connected_words[reversed_word].connections:
        connected_words[reversed_word].connections.append(word)
    }
    
    return {
        "reversed": true,
        "original": word,
        "reversed": reversed_word,
        "connection": result
    }

func create_shape(shape_id, shape_type):
    // Create a new vertical shape
    var shape = {
        "id": shape_id,
        "height": 5,
        "width": 5,
        "color": SOLAR_CYCLES[current_solar_cycle].color,
        "frequency": SOLAR_CYCLES[current_solar_cycle].frequency,
        "rotation": 0.0,
        "active": true,
        "type": shape_type
    }
    
    // Adjust properties based on type
    match shape_type:
        "pyramid":
            shape.height = 7
            shape.width = 13
        
        "column":
            shape.height = 10
            shape.width = 4
        
        "wave":
            shape.height = 3
            shape.width = 15
        
        "cube":
            shape.height = 8
            shape.width = 8
        
        "star":
            shape.height = 9
            shape.width = 9
            shape.frequency = 555
    }
    
    vertical_shapes.append(shape)
    
    emit_signal("shape_changed", shape_id, shape)
    
    return {
        "created": true,
        "shape": shape_id,
        "type": shape_type
    }

func modify_shape(shape_id, property, value):
    // Find the shape
    var target_shape = null
    var shape_index = -1
    
    for i in range(vertical_shapes.size()):
        if vertical_shapes[i].id == shape_id:
            target_shape = vertical_shapes[i]
            shape_index = i
            break
        }
    }
    
    if not target_shape:
        return {"error": "Shape not found: " + shape_id}
    }
    
    // Convert value to appropriate type
    var converted_value = value
    
    if property in ["height", "width", "rotation", "frequency"]:
        converted_value = float(value)
    } elif property == "active":
        converted_value = value.to_lower() == "true"
    } elif property == "color":
        // Handle color names
        match value.to_upper():
            "RED":
                converted_value = Color(1.0, 0.0, 0.0)
            "GREEN":
                converted_value = Color(0.0, 1.0, 0.0)
            "BLUE":
                converted_value = Color(0.0, 0.0, 1.0)
            "YELLOW":
                converted_value = Color(1.0, 1.0, 0.0)
            "CYAN":
                converted_value = Color(0.0, 1.0, 1.0)
            "MAGENTA":
                converted_value = Color(1.0, 0.0, 1.0)
            "WHITE":
                converted_value = Color(1.0, 1.0, 1.0)
            "BLACK":
                converted_value = Color(0.0, 0.0, 0.0)
            "ORANGE":
                converted_value = Color(1.0, 0.5, 0.0)
            "PURPLE":
                converted_value = Color(0.5, 0.0, 0.5)
            _:
                // Try to parse as RGB
                var rgb = value.split(",")
                if rgb.size() >= 3:
                    converted_value = Color(float(rgb[0]), float(rgb[1]), float(rgb[2]))
                }
        }
    }
    
    // Modify the property
    target_shape[property] = converted_value
    
    emit_signal("shape_changed", shape_id, target_shape)
    
    return {
        "modified": true,
        "shape": shape_id,
        "property": property,
        "value": converted_value
    }

func activate_shape(shape_id):
    return modify_shape(shape_id, "active", "true")

func deactivate_shape(shape_id):
    return modify_shape(shape_id, "active", "false")

func rotate_shape(shape_id, angle):
    return modify_shape(shape_id, "rotation", str(angle))

func color_shape(shape_id, color_name):
    return modify_shape(shape_id, "color", color_name)

# Utility functions

# Run a command or command chain
func run_command(command_text):
    if ";" in command_text:
        // Split into chain
        var commands = command_text.split(";")
        
        for cmd in commands:
            current_command_chain.append(cmd.strip_edges())
        }
        
        return {
            "command_chain": current_command_chain.duplicate()
        }
    } else {
        return process_command(command_text)
    }

# Listen for word activation
func listen_for_word(word):
    if word in connected_words:
        var word_entry = connected_words[word]
        
        // Check drives for word activation
        for drive_id in word_entry.drives:
            if drive_id in active_drives:
                active_drives[drive_id].status = "ACTIVE"
            }
        }
        
        // Check word connections
        var connections = []
        
        for connected_word in word_entry.connections:
            connections.append(connected_word)
            // Also activate the connected words
            if connected_word in connected_words:
                for drive_id in connected_words[connected_word].drives:
                    if drive_id in active_drives:
                        active_drives[drive_id].status = "ACTIVE"
                    }
                }
            }
        }
        
        return {
            "word_activated": true,
            "word": word,
            "drives": word_entry.drives,
            "connections": connections
        }
    }
    
    return {"error": "Word not found: " + word}

# Process terminal input
func process_terminal_input(input_text):
    // Process as command if it starts with a recognized prefix
    for prefix in COMMAND_PREFIXES.values():
        if input_text.begins_with(prefix):
            return run_command(input_text)
        }
    }
    
    // Otherwise, treat as word activation
    return listen_for_word(input_text)