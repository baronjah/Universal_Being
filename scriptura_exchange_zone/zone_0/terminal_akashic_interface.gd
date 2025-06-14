class_name TerminalAkashicInterface
extends Node

# ----- TERMINAL INTERFACE CONSTANTS -----
const TERMINAL_COLORS = {
    "DEFAULT": Color(1.0, 1.0, 1.0),  # White
    "INFO": Color(0.4, 0.8, 1.0),      # Light blue
    "SUCCESS": Color(0.4, 1.0, 0.4),   # Light green
    "WARNING": Color(1.0, 0.8, 0.2),   # Yellow
    "ERROR": Color(1.0, 0.4, 0.4),     # Light red
    "SYSTEM": Color(0.8, 0.5, 1.0),    # Purple
    "AKASHIC": Color(1.0, 0.6, 0.0),   # Orange
    "ETHEREAL": Color(0.0, 0.9, 0.7),  # Teal
    "MIGRATION": Color(0.7, 0.7, 0.7), # Gray
    "USER": Color(0.9, 0.9, 0.9)       # Light gray
}

const TERMINAL_COMMANDS = {
    "help": {
        "description": "Lists available commands",
        "usage": "help [command]",
        "category": "system"
    },
    "status": {
        "description": "Shows current system status",
        "usage": "status [component]",
        "category": "system"
    },
    "connect": {
        "description": "Connects to a component or system",
        "usage": "connect <component>",
        "category": "system"
    },
    "migrate": {
        "description": "Starts migration process",
        "usage": "migrate <from_path> <to_path>",
        "category": "migration"
    },
    "check": {
        "description": "Checks project compatibility",
        "usage": "check <project_path>",
        "category": "migration"
    },
    "test": {
        "description": "Runs migration tests",
        "usage": "test [test_name]",
        "category": "migration"
    },
    "temp": {
        "description": "Sets or gets temperature",
        "usage": "temp [value | up | down]",
        "category": "color"
    },
    "color": {
        "description": "Sets or gets color state",
        "usage": "color [state_name]",
        "category": "color"
    },
    "spectrum": {
        "description": "Sets or gets light spectrum",
        "usage": "spectrum [spectrum_name]",
        "category": "color"
    },
    "project": {
        "description": "Manages projection settings",
        "usage": "project [mode] [intensity]",
        "category": "color"
    },
    "number": {
        "description": "Manages akashic numbers",
        "usage": "number <value> [name]",
        "category": "akashic"
    },
    "universe": {
        "description": "Connects to a universe",
        "usage": "universe <name> [connect|disconnect]",
        "category": "akashic"
    },
    "energy": {
        "description": "Transports energy between points",
        "usage": "energy <shape> <from_x,y,z> <to_x,y,z>",
        "category": "ethereal"
    },
    "audio": {
        "description": "Activates audio input processing",
        "usage": "audio <frequency_range> [intensity]",
        "category": "ethereal"
    },
    "sync": {
        "description": "Synchronizes systems",
        "usage": "sync [component]",
        "category": "system"
    },
    "record": {
        "description": "Creates a record entry",
        "usage": "record <type> <data>",
        "category": "akashic"
    },
    "exit": {
        "description": "Exits the terminal",
        "usage": "exit",
        "category": "system"
    }
}

const HISTORY_MAX_SIZE = 50
const SYSTEM_LUCKY_NUMBERS = [9, 33, 89, 99, 333, 389, 555, 777, 999]

# ----- COMPONENT REFERENCES -----
var terminal_bridge = null
var color_temperature = null
var akashic_system = null
var migration_system = null
var ethereal_bridge = null

# ----- TERMINAL STATE -----
var command_history = []
var history_index = -1
var command_buffer = ""
var connected_components = {}
var current_directory = "/"
var logged_in = false
var username = ""
var last_result = null
var terminal_open = true
var prompt_style = "> "

# ----- MIGRATION PATHS -----
var godot3_project_path = ""
var godot4_project_path = ""

# ----- SIGNALS -----
signal command_executed(command, result)
signal terminal_ready
signal system_connected(component)
signal migration_started(from_path, to_path)
signal record_created(type, data)

# ----- INITIALIZATION -----
func _ready():
    _find_components()
    _initialize_interface()
    
    print("Terminal Akashic Interface initialized")
    emit_signal("terminal_ready")

func _find_components():
    # Find TerminalBridgeConnector
    terminal_bridge = get_node_or_null("/root/TerminalBridgeConnector")
    if not terminal_bridge:
        terminal_bridge = _find_node_by_class(get_tree().root, "TerminalBridgeConnector")
    
    # Find ColorTemperatureProjection
    color_temperature = get_node_or_null("/root/ColorTemperatureProjection")
    if not color_temperature:
        color_temperature = _find_node_by_class(get_tree().root, "ColorTemperatureProjection")
    
    # Find AkashicNumberSystem
    akashic_system = get_node_or_null("/root/AkashicNumberSystem")
    if not akashic_system:
        akashic_system = _find_node_by_class(get_tree().root, "AkashicNumberSystem")
    
    # Find migration components
    migration_system = get_node_or_null("/root/UnifiedMigrationSystem")
    if not migration_system:
        migration_system = _find_node_by_class(get_tree().root, "UnifiedMigrationSystem")
    
    ethereal_bridge = get_node_or_null("/root/EtherealMigrationBridge")
    if not ethereal_bridge:
        ethereal_bridge = _find_node_by_class(get_tree().root, "EtherealMigrationBridge")
    
    print("Components found: Terminal=%s, ColorTemp=%s, Akashic=%s, Migration=%s, Ethereal=%s" % [
        "Yes" if terminal_bridge else "No",
        "Yes" if color_temperature else "No",
        "Yes" if akashic_system else "No",
        "Yes" if migration_system else "No",
        "Yes" if ethereal_bridge else "No"
    ])

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

func _initialize_interface():
    # Set initial connected components state
    connected_components = {
        "terminal": terminal_bridge != null,
        "color": color_temperature != null,
        "akashic": akashic_system != null,
        "migration": migration_system != null,
        "ethereal": ethereal_bridge != null
    }
    
    # Connect to terminal bridge if available
    if terminal_bridge and terminal_bridge.has_method("connect_terminal_to_user"):
        var result = terminal_bridge.connect_terminal_to_user()
        if result:
            logged_in = true
            username = "user"

# ----- COMMAND PROCESSING -----
func execute_command(command_line):
    # Add to history
    _add_to_history(command_line)
    
    # Parse command
    var parts = command_line.strip_edges().split(" ", false)
    var command = parts[0].to_lower() if parts.size() > 0 else ""
    var args = parts.slice(1) if parts.size() > 1 else []
    
    # Process command
    var result = _process_command(command, args)
    
    # Store result
    last_result = result
    
    # Emit signal
    emit_signal("command_executed", command_line, result)
    
    return result

func _process_command(command, args):
    # Check if command exists
    if not TERMINAL_COMMANDS.has(command):
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Unknown command: " + command + "\nType 'help' for a list of commands."
        }
    
    # Process based on command category
    var category = TERMINAL_COMMANDS[command].category
    
    match category:
        "system":
            return _process_system_command(command, args)
        "migration":
            return _process_migration_command(command, args)
        "color":
            return _process_color_command(command, args)
        "akashic":
            return _process_akashic_command(command, args)
        "ethereal":
            return _process_ethereal_command(command, args)
        _:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Unknown command category: " + category
            }

func _process_system_command(command, args):
    match command:
        "help":
            return _cmd_help(args)
        "status":
            return _cmd_status(args)
        "connect":
            return _cmd_connect(args)
        "sync":
            return _cmd_sync(args)
        "exit":
            return _cmd_exit(args)
        _:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Unknown system command: " + command
            }

func _process_migration_command(command, args):
    # Check if migration system is connected
    if not connected_components.migration:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Migration system is not connected. Use 'connect migration' first."
        }
    
    match command:
        "migrate":
            return _cmd_migrate(args)
        "check":
            return _cmd_check(args)
        "test":
            return _cmd_test(args)
        _:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Unknown migration command: " + command
            }

func _process_color_command(command, args):
    # Check if color system is connected
    if not connected_components.color:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Color system is not connected. Use 'connect color' first."
        }
    
    match command:
        "temp":
            return _cmd_temp(args)
        "color":
            return _cmd_color(args)
        "spectrum":
            return _cmd_spectrum(args)
        "project":
            return _cmd_project(args)
        _:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Unknown color command: " + command
            }

func _process_akashic_command(command, args):
    # Check if akashic system is connected
    if not connected_components.akashic:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Akashic system is not connected. Use 'connect akashic' first."
        }
    
    match command:
        "number":
            return _cmd_number(args)
        "universe":
            return _cmd_universe(args)
        "record":
            return _cmd_record(args)
        _:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Unknown akashic command: " + command
            }

func _process_ethereal_command(command, args):
    # Check if ethereal system is connected
    if not connected_components.ethereal:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Ethereal system is not connected. Use 'connect ethereal' first."
        }
    
    match command:
        "energy":
            return _cmd_energy(args)
        "audio":
            return _cmd_audio(args)
        _:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Unknown ethereal command: " + command
            }

# ----- SYSTEM COMMANDS -----
func _cmd_help(args):
    if args.size() > 0:
        # Show help for specific command
        var command = args[0].to_lower()
        
        if not TERMINAL_COMMANDS.has(command):
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Unknown command: " + command
            }
        
        var cmd_info = TERMINAL_COMMANDS[command]
        var help_text = command + " - " + cmd_info.description + "\n"
        help_text += "Usage: " + cmd_info.usage + "\n"
        help_text += "Category: " + cmd_info.category
        
        return {
            "success": true,
            "color": TERMINAL_COLORS.INFO,
            "message": help_text
        }
    else:
        # Show all commands grouped by category
        var categories = {}
        
        for cmd in TERMINAL_COMMANDS:
            var category = TERMINAL_COMMANDS[cmd].category
            
            if not categories.has(category):
                categories[category] = []
            
            categories[category].append(cmd)
        
        var help_text = "Available commands:\n\n"
        
        for category in categories:
            help_text += category.to_upper() + ":\n"
            
            for cmd in categories[category]:
                help_text += "  " + cmd + " - " + TERMINAL_COMMANDS[cmd].description + "\n"
            
            help_text += "\n"
        
        help_text += "Type 'help <command>' for more information about a specific command."
        
        return {
            "success": true,
            "color": TERMINAL_COLORS.INFO,
            "message": help_text
        }

func _cmd_status(args):
    var component = args[0].to_lower() if args.size() > 0 else "all"
    var status_text = ""
    
    if component == "all":
        # Show status of all components
        status_text += "SYSTEM STATUS\n\n"
        
        status_text += "Connected components:\n"
        for comp in connected_components:
            var status = "Connected" if connected_components[comp] else "Disconnected"
            status_text += "  " + comp + ": " + status + "\n"
        
        status_text += "\nCurrent directory: " + current_directory + "\n"
        status_text += "Logged in as: " + (username if logged_in else "Not logged in") + "\n"
        
        # Add migration paths if set
        if godot3_project_path != "" or godot4_project_path != "":
            status_text += "\nMigration paths:\n"
            status_text += "  Godot 3: " + (godot3_project_path if godot3_project_path != "" else "Not set") + "\n"
            status_text += "  Godot 4: " + (godot4_project_path if godot4_project_path != "" else "Not set") + "\n"
        
        # Add color temperature if available
        if connected_components.color and color_temperature:
            var color_state = color_temperature.get_current_state()
            status_text += "\nColor temperature: " + str(color_state.temperature) + "°C (" + color_state.color_state + ")\n"
            status_text += "Light spectrum: " + color_state.light_spectrum + "\n"
            status_text += "Energy level: " + color_state.energy_level + "\n"
        
        # Add terminal bridge stats if available
        if connected_components.terminal and terminal_bridge:
            var terminal_stats = terminal_bridge.get_terminal_connection_stats()
            status_text += "\nTerminal stats:\n"
            status_text += "  Connected universes: " + str(terminal_stats.connected_universes) + "\n"
            status_text += "  Active color mode: " + terminal_stats.active_color_mode + "\n"
            status_text += "  Temperature: " + str(terminal_stats.temperature) + "\n"
            status_text += "  Total stars: " + str(terminal_stats.total_stars) + "\n"
    else:
        # Show status of specific component
        match component:
            "terminal":
                if connected_components.terminal and terminal_bridge:
                    var terminal_stats = terminal_bridge.get_terminal_connection_stats()
                    status_text += "TERMINAL STATUS\n\n"
                    status_text += "Connected universes: " + str(terminal_stats.connected_universes) + "\n"
                    status_text += "Active color mode: " + terminal_stats.active_color_mode + "\n"
                    status_text += "Temperature: " + str(terminal_stats.temperature) + "\n"
                    status_text += "Projection active: " + ("Yes" if terminal_stats.projection_active else "No") + "\n"
                    status_text += "Audio active: " + ("Yes" if terminal_stats.audio_active else "No") + "\n"
                    status_text += "Total stars: " + str(terminal_stats.total_stars) + "\n"
                else:
                    status_text += "Terminal system is not connected."
            
            "color":
                if connected_components.color and color_temperature:
                    var color_state = color_temperature.get_current_state()
                    status_text += "COLOR TEMPERATURE STATUS\n\n"
                    status_text += "Temperature: " + str(color_state.temperature) + "°C\n"
                    status_text += "Color state: " + color_state.color_state + "\n"
                    status_text += "Light spectrum: " + color_state.light_spectrum + "\n"
                    status_text += "Energy level: " + color_state.energy_level + "\n"
                    status_text += "Projection mode: " + color_state.projection_mode + "\n"
                    status_text += "Projection intensity: " + str(color_state.projection_intensity) + "\n"
                    status_text += "Projection visible: " + ("Yes" if color_state.projection_visible else "No") + "\n"
                else:
                    status_text += "Color system is not connected."
            
            "akashic":
                if connected_components.akashic and akashic_system:
                    status_text += "AKASHIC SYSTEM STATUS\n\n"
                    status_text += "System active: Yes\n"
                    status_text += "Lucky numbers: " + str(SYSTEM_LUCKY_NUMBERS) + "\n"
                    
                    # Add registered numbers count if available
                    if akashic_system.has_method("get_registered_numbers_count"):
                        status_text += "Registered numbers: " + str(akashic_system.get_registered_numbers_count()) + "\n"
                else:
                    status_text += "Akashic system is not connected."
            
            "migration":
                if connected_components.migration and migration_system:
                    status_text += "MIGRATION SYSTEM STATUS\n\n"
                    status_text += "System active: Yes\n"
                    status_text += "Godot 3 path: " + (godot3_project_path if godot3_project_path != "" else "Not set") + "\n"
                    status_text += "Godot 4 path: " + (godot4_project_path if godot4_project_path != "" else "Not set") + "\n"
                    
                    # Add migration stats if available
                    if migration_system.has_method("get_statistics"):
                        var stats = migration_system.get_statistics()
                        status_text += "Migration count: " + str(stats.migration_count) + "\n"
                        status_text += "Ethereal migration count: " + str(stats.ethereal_migration_count) + "\n"
                        status_text += "Test run count: " + str(stats.test_run_count) + "\n"
                        status_text += "Runtime: " + str(stats.runtime_seconds) + " seconds\n"
                else:
                    status_text += "Migration system is not connected."
            
            "ethereal":
                if connected_components.ethereal and ethereal_bridge:
                    status_text += "ETHEREAL SYSTEM STATUS\n\n"
                    status_text += "System active: Yes\n"
                    status_text += "Connected to migration: " + ("Yes" if migration_system else "No") + "\n"
                    status_text += "Connected to akashic: " + ("Yes" if akashic_system else "No") + "\n"
                else:
                    status_text += "Ethereal system is not connected."
            
            _:
                return {
                    "success": false,
                    "color": TERMINAL_COLORS.ERROR,
                    "message": "Unknown component: " + component
                }
    
    return {
        "success": true,
        "color": TERMINAL_COLORS.INFO,
        "message": status_text
    }

func _cmd_connect(args):
    if args.size() == 0:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Missing component name. Usage: connect <component>"
        }
    
    var component = args[0].to_lower()
    
    # Check if component is valid
    if not connected_components.has(component):
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Unknown component: " + component
        }
    
    # Check if already connected
    if connected_components[component]:
        return {
            "success": true,
            "color": TERMINAL_COLORS.INFO,
            "message": "Already connected to " + component + " system."
        }
    
    # Try to connect
    match component:
        "terminal":
            terminal_bridge = get_node_or_null("/root/TerminalBridgeConnector")
            if not terminal_bridge:
                terminal_bridge = _find_node_by_class(get_tree().root, "TerminalBridgeConnector")
            
            if terminal_bridge:
                var result = terminal_bridge.connect_terminal_to_user()
                if result:
                    connected_components.terminal = true
                    emit_signal("system_connected", "terminal")
                    return {
                        "success": true,
                        "color": TERMINAL_COLORS.SUCCESS,
                        "message": "Successfully connected to terminal system."
                    }
            
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Failed to connect to terminal system."
            }
        
        "color":
            color_temperature = get_node_or_null("/root/ColorTemperatureProjection")
            if not color_temperature:
                color_temperature = _find_node_by_class(get_tree().root, "ColorTemperatureProjection")
            
            if color_temperature:
                connected_components.color = true
                emit_signal("system_connected", "color")
                return {
                    "success": true,
                    "color": TERMINAL_COLORS.SUCCESS,
                    "message": "Successfully connected to color system."
                }
            
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Failed to connect to color system."
            }
        
        "akashic":
            akashic_system = get_node_or_null("/root/AkashicNumberSystem")
            if not akashic_system:
                akashic_system = _find_node_by_class(get_tree().root, "AkashicNumberSystem")
            
            if akashic_system:
                connected_components.akashic = true
                emit_signal("system_connected", "akashic")
                return {
                    "success": true,
                    "color": TERMINAL_COLORS.SUCCESS,
                    "message": "Successfully connected to akashic system."
                }
            
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Failed to connect to akashic system."
            }
        
        "migration":
            migration_system = get_node_or_null("/root/UnifiedMigrationSystem")
            if not migration_system:
                migration_system = _find_node_by_class(get_tree().root, "UnifiedMigrationSystem")
            
            if migration_system:
                connected_components.migration = true
                emit_signal("system_connected", "migration")
                return {
                    "success": true,
                    "color": TERMINAL_COLORS.SUCCESS,
                    "message": "Successfully connected to migration system."
                }
            
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Failed to connect to migration system."
            }
        
        "ethereal":
            ethereal_bridge = get_node_or_null("/root/EtherealMigrationBridge")
            if not ethereal_bridge:
                ethereal_bridge = _find_node_by_class(get_tree().root, "EtherealMigrationBridge")
            
            if ethereal_bridge:
                connected_components.ethereal = true
                emit_signal("system_connected", "ethereal")
                return {
                    "success": true,
                    "color": TERMINAL_COLORS.SUCCESS,
                    "message": "Successfully connected to ethereal system."
                }
            
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Failed to connect to ethereal system."
            }
        
        "all":
            var results = []
            var all_success = true
            
            for comp in connected_components.keys():
                if comp != "all" and not connected_components[comp]:
                    var result = _cmd_connect([comp])
                    results.append(result.message)
                    all_success = all_success and result.success
            
            if all_success:
                return {
                    "success": true,
                    "color": TERMINAL_COLORS.SUCCESS,
                    "message": "Successfully connected to all systems:\n" + "\n".join(results)
                }
            else:
                return {
                    "success": false,
                    "color": TERMINAL_COLORS.WARNING,
                    "message": "Some systems could not be connected:\n" + "\n".join(results)
                }
        
        _:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Unknown component: " + component
            }

func _cmd_sync(args):
    var component = args[0].to_lower() if args.size() > 0 else "all"
    
    match component:
        "all":
            # Sync all components
            var success = true
            var messages = []
            
            # Sync color system
            if connected_components.color and color_temperature:
                var color_result = color_temperature.create_color_temperature_bridge()
                success = success and color_result.success
                if color_result.success:
                    messages.append("Color system synchronized with lucky number " + str(color_result.lucky_number))
                else:
                    messages.append("Failed to synchronize color system")
            
            # Sync terminal bridge
            if connected_components.terminal and terminal_bridge:
                var terminal_result = terminal_bridge.sync_terminal_view_with_akashic()
                success = success and terminal_result.success
                if terminal_result.success:
                    messages.append("Terminal view synchronized at " + str(terminal_result.sync_timestamp))
                else:
                    messages.append("Failed to synchronize terminal view")
            
            # Sync ethereal bridge with akashic records
            if connected_components.ethereal and ethereal_bridge and connected_components.akashic:
                if terminal_bridge and terminal_bridge.has_method("link_akashic_records_to_ethereal"):
                    var bridge_result = terminal_bridge.link_akashic_records_to_ethereal()
                    success = success and bridge_result.success
                    if bridge_result.success:
                        messages.append("Akashic records linked to ethereal bridge at " + str(bridge_result.bridge_timestamp))
                    else:
                        messages.append("Failed to link akashic records to ethereal bridge")
            
            return {
                "success": success,
                "color": TERMINAL_COLORS.SUCCESS if success else TERMINAL_COLORS.WARNING,
                "message": "Synchronization " + ("completed" if success else "partially completed") + ":\n" + "\n".join(messages)
            }
        
        "color":
            # Sync color system
            if connected_components.color and color_temperature:
                var color_result = color_temperature.create_color_temperature_bridge()
                if color_result.success:
                    return {
                        "success": true,
                        "color": TERMINAL_COLORS.SUCCESS,
                        "message": "Color system synchronized with lucky number " + str(color_result.lucky_number)
                    }
                else:
                    return {
                        "success": false,
                        "color": TERMINAL_COLORS.ERROR,
                        "message": "Failed to synchronize color system: " + (color_result.error if color_result.has("error") else "Unknown error")
                    }
            else:
                return {
                    "success": false,
                    "color": TERMINAL_COLORS.ERROR,
                    "message": "Color system is not connected. Use 'connect color' first."
                }
        
        "terminal":
            # Sync terminal view
            if connected_components.terminal and terminal_bridge:
                var terminal_result = terminal_bridge.sync_terminal_view_with_akashic()
                if terminal_result.success:
                    return {
                        "success": true,
                        "color": TERMINAL_COLORS.SUCCESS,
                        "message": "Terminal view synchronized at " + str(terminal_result.sync_timestamp) + 
                                  "\nConnected universes: " + str(terminal_result.connected_universes) +
                                  "\nColor mode: " + terminal_result.color_mode
                    }
                else:
                    return {
                        "success": false,
                        "color": TERMINAL_COLORS.ERROR,
                        "message": "Failed to synchronize terminal view: " + (terminal_result.error if terminal_result.has("error") else "Unknown error")
                    }
            else:
                return {
                    "success": false,
                    "color": TERMINAL_COLORS.ERROR,
                    "message": "Terminal system is not connected. Use 'connect terminal' first."
                }
        
        "akashic":
            # Sync akashic records
            if connected_components.akashic and connected_components.ethereal:
                if terminal_bridge and terminal_bridge.has_method("link_akashic_records_to_ethereal"):
                    var bridge_result = terminal_bridge.link_akashic_records_to_ethereal()
                    if bridge_result.success:
                        return {
                            "success": true,
                            "color": TERMINAL_COLORS.SUCCESS,
                            "message": "Akashic records linked to ethereal bridge at " + str(bridge_result.bridge_timestamp) +
                                      "\nBridge records: " + str(bridge_result.bridge_records) +
                                      "\nCosmic address: " + bridge_result.cosmic_address
                        }
                    else:
                        return {
                            "success": false,
                            "color": TERMINAL_COLORS.ERROR,
                            "message": "Failed to link akashic records to ethereal bridge: " + (bridge_result.error if bridge_result.has("error") else "Unknown error")
                        }
                else:
                    return {
                        "success": false,
                        "color": TERMINAL_COLORS.ERROR,
                        "message": "Terminal bridge is not connected. Use 'connect terminal' first."
                    }
            else:
                return {
                    "success": false,
                    "color": TERMINAL_COLORS.ERROR,
                    "message": "Both akashic and ethereal systems must be connected. Use 'connect akashic' and 'connect ethereal' first."
                }
        
        _:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Unknown component: " + component + "\nValid options: all, color, terminal, akashic"
            }

func _cmd_exit(args):
    terminal_open = false
    
    return {
        "success": true,
        "color": TERMINAL_COLORS.INFO,
        "message": "Exiting terminal..."
    }

# ----- MIGRATION COMMANDS -----
func _cmd_migrate(args):
    if args.size() < 2:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Missing project paths. Usage: migrate <from_path> <to_path>"
        }
    
    var from_path = args[0]
    var to_path = args[1]
    
    # Save paths for later
    godot3_project_path = from_path
    godot4_project_path = to_path
    
    # Set paths in migration system
    if migration_system and migration_system.has_method("set_project_paths"):
        migration_system.set_project_paths(from_path, to_path)
    
    # Start migration
    if migration_system and migration_system.has_method("start_migration"):
        emit_signal("migration_started", from_path, to_path)
        
        var result = migration_system.start_migration()
        
        if result.success:
            return {
                "success": true,
                "color": TERMINAL_COLORS.SUCCESS,
                "message": "Migration completed successfully!\n\n" +
                          "Files processed: " + str(result.files_processed) + "\n" +
                          "Files modified: " + str(result.files_modified) + "\n" +
                          "Errors: " + str(result.errors_encountered if result.has("errors_encountered") else 0) + "\n" +
                          "Warnings: " + str(result.warnings_generated if result.has("warnings_generated") else 0) + "\n" +
                          (("Ethereal nodes: " + str(result.ethereal_nodes_migrated) + "\n") if result.has("ethereal_nodes_migrated") else "") +
                          (("Reality contexts: " + str(result.reality_contexts_migrated) + "\n") if result.has("reality_contexts_migrated") else "") +
                          (("Word manifestations: " + str(result.word_manifestations_migrated) + "\n") if result.has("word_manifestations_migrated") else "")
            }
        else:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Migration failed: " + (result.error if result.has("error") else "Unknown error")
            }
    else:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Migration system is not properly connected."
        }

func _cmd_check(args):
    if args.size() < 1:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Missing project path. Usage: check <project_path>"
        }
    
    var project_path = args[0]
    
    # Generate compatibility report
    if migration_system and migration_system.has_method("generate_compatibility_report"):
        var report = migration_system.generate_compatibility_report(project_path)
        
        if report.success:
            var message = "Compatibility Report for " + project_path + "\n\n"
            
            # Standard compatibility report
            if report.has("total_files"):
                message += "Total files: " + str(report.total_files) + "\n"
                message += "Compatible files: " + str(report.compatible_files) + "\n"
                message += "Incompatible files: " + str(report.incompatible_files) + "\n\n"
            
            # Ethereal engine report
            if report.has("ethereal_files"):
                message += "Ethereal Engine Detection:\n"
                message += "Ethereal files: " + str(report.ethereal_files) + "\n"
                message += "Ethereal patterns: " + str(report.ethereal_patterns_detected) + "\n\n"
                
                if report.has("pattern_distribution"):
                    message += "Pattern distribution:\n"
                    for pattern in report.pattern_distribution:
                        message += "  " + pattern + ": " + str(report.pattern_distribution[pattern]) + "\n"
            
            return {
                "success": true,
                "color": TERMINAL_COLORS.INFO,
                "message": message
            }
        else:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Failed to generate compatibility report: " + (report.error if report.has("error") else "Unknown error")
            }
    else:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Migration system is not properly connected."
        }

func _cmd_test(args):
    var test_name = args[0] if args.size() > 0 else ""
    
    # Run tests
    if migration_system and migration_system.has_method("run_all_tests"):
        var results = migration_system.run_all_tests()
        
        if results.success:
            var message = "Test Results\n\n"
            message += "Total tests: " + str(results.total) + "\n"
            message += "Passed: " + str(results.passed) + "\n"
            message += "Failed: " + str(results.failed) + "\n"
            
            # Add details for specific test if requested
            if test_name != "" and results.details.has(test_name):
                var test_result = results.details[test_name]
                message += "\nDetails for test '" + test_name + "':\n"
                message += "Status: " + ("Passed" if test_result.passed else "Failed") + "\n"
                
                if test_result.has("warnings") and test_result.warnings.size() > 0:
                    message += "Warnings:\n"
                    for warning in test_result.warnings:
                        message += "  - " + warning + "\n"
                
                if test_result.has("errors") and test_result.errors.size() > 0:
                    message += "Errors:\n"
                    for error in test_result.errors:
                        message += "  - " + error + "\n"
            
            return {
                "success": true,
                "color": TERMINAL_COLORS.SUCCESS,
                "message": message
            }
        else:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Failed to run tests: " + (results.error if results.has("error") else "Unknown error")
            }
    else:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Migration system is not properly connected."
        }

# ----- COLOR COMMANDS -----
func _cmd_temp(args):
    if args.size() == 0:
        # Get current temperature
        if color_temperature:
            var state = color_temperature.get_current_state()
            return {
                "success": true,
                "color": TERMINAL_COLORS.INFO,
                "message": "Current temperature: " + str(state.temperature) + "°C (" + state.color_state + ")\n" +
                          "Energy level: " + state.energy_level
            }
        else:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Color system is not properly connected."
            }
    else:
        var param = args[0].to_lower()
        
        if param == "up":
            # Increase temperature by cycling up
            if color_temperature and color_temperature.has_method("cycle_temperature_up"):
                var result = color_temperature.cycle_temperature_up()
                
                if result:
                    var state = color_temperature.get_current_state()
                    return {
                        "success": true,
                        "color": TERMINAL_COLORS.SUCCESS,
                        "message": "Temperature increased to " + str(state.temperature) + "°C (" + state.color_state + ")"
                    }
                else:
                    return {
                        "success": false,
                        "color": TERMINAL_COLORS.ERROR,
                        "message": "Failed to increase temperature"
                    }
            }
        elif param == "down":
            # Decrease temperature by cycling down
            if color_temperature and color_temperature.has_method("cycle_temperature_down"):
                var result = color_temperature.cycle_temperature_down()
                
                if result:
                    var state = color_temperature.get_current_state()
                    return {
                        "success": true,
                        "color": TERMINAL_COLORS.SUCCESS,
                        "message": "Temperature decreased to " + str(state.temperature) + "°C (" + state.color_state + ")"
                    }
                else:
                    return {
                        "success": false,
                        "color": TERMINAL_COLORS.ERROR,
                        "message": "Failed to decrease temperature"
                    }
            }
        elif param.is_valid_int():
            # Set specific temperature
            var temp = param.to_int()
            
            if color_temperature and color_temperature.has_method("set_temperature"):
                color_temperature.set_temperature(temp)
                
                var state = color_temperature.get_current_state()
                return {
                    "success": true,
                    "color": TERMINAL_COLORS.SUCCESS,
                    "message": "Temperature set to " + str(state.temperature) + "°C (" + state.color_state + ")"
                }
            }
        else:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Invalid temperature value: " + param + "\nUse a number, 'up', or 'down'"
            }
    
    return {
        "success": false,
        "color": TERMINAL_COLORS.ERROR,
        "message": "Failed to process temperature command"
    }

func _cmd_color(args):
    if args.size() == 0:
        # Get available color states
        if color_temperature:
            var states = color_temperature.get_temperature_states()
            var message = "Available color states:\n\n"
            
            for state in states:
                message += state + ": " + str(states[state].temperature) + "°C, " + 
                          states[state].energy_state + " energy, " +
                          "frequency " + str(states[state].frequency) + "\n"
            
            var current = color_temperature.get_current_state()
            message += "\nCurrent color state: " + current.color_state
            
            return {
                "success": true,
                "color": TERMINAL_COLORS.INFO,
                "message": message
            }
        else:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Color system is not properly connected."
            }
    else:
        var state_name = args[0].to_upper()
        
        # Set color state
        if color_temperature and color_temperature.has_method("set_color_state"):
            var states = color_temperature.get_temperature_states()
            
            if states.has(state_name):
                color_temperature.set_color_state(state_name)
                
                var current = color_temperature.get_current_state()
                return {
                    "success": true,
                    "color": TERMINAL_COLORS.SUCCESS,
                    "message": "Color state set to " + current.color_state + " (" + 
                              str(current.temperature) + "°C, " + current.energy_level + " energy)"
                }
            else:
                return {
                    "success": false,
                    "color": TERMINAL_COLORS.ERROR,
                    "message": "Invalid color state: " + state_name + "\nUse 'color' to see available states"
                }
        }
    
    return {
        "success": false,
        "color": TERMINAL_COLORS.ERROR,
        "message": "Failed to process color command"
    }

func _cmd_spectrum(args):
    if args.size() == 0:
        # Get available light spectrum states
        if color_temperature:
            var spectrums = color_temperature.get_light_spectrum_states()
            var message = "Available light spectrum states:\n\n"
            
            for spectrum in spectrums:
                var visible = spectrums[spectrum].visible
                message += spectrum + ": " + 
                          str(spectrums[spectrum].wavelength[0]) + "-" + str(spectrums[spectrum].wavelength[1]) + " nm, " +
                          (visible ? "visible" : "invisible") + ", " +
                          spectrums[spectrum].energy + " energy\n"
            
            var current = color_temperature.get_current_state()
            message += "\nCurrent light spectrum: " + current.light_spectrum
            
            return {
                "success": true,
                "color": TERMINAL_COLORS.INFO,
                "message": message
            }
        else:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Color system is not properly connected."
            }
    else:
        var spectrum_name = args[0].to_upper()
        
        # Set light spectrum
        if color_temperature and color_temperature.has_method("set_light_spectrum"):
            var spectrums = color_temperature.get_light_spectrum_states()
            
            if spectrums.has(spectrum_name):
                color_temperature.set_light_spectrum(spectrum_name)
                
                var current = color_temperature.get_current_state()
                return {
                    "success": true,
                    "color": TERMINAL_COLORS.SUCCESS,
                    "message": "Light spectrum set to " + current.light_spectrum
                }
            else:
                return {
                    "success": false,
                    "color": TERMINAL_COLORS.ERROR,
                    "message": "Invalid light spectrum: " + spectrum_name + "\nUse 'spectrum' to see available spectrums"
                }
        }
    
    return {
        "success": false,
        "color": TERMINAL_COLORS.ERROR,
        "message": "Failed to process spectrum command"
    }

func _cmd_project(args):
    if args.size() == 0:
        # Get current projection state
        if color_temperature:
            var state = color_temperature.get_projection_state()
            return {
                "success": true,
                "color": TERMINAL_COLORS.INFO,
                "message": "Current projection state:\n\n" +
                          "Mode: " + state.mode + "\n" +
                          "Intensity: " + str(state.intensity) + "\n" +
                          "Visible: " + ("Yes" if state.visible else "No") + "\n" +
                          "Temperature: " + str(state.temperature) + "°C\n" +
                          "Color state: " + state.color_state + "\n" +
                          "Light spectrum: " + state.light_spectrum
            }
        else:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Color system is not properly connected."
            }
    else:
        var mode = args[0].to_lower()
        var intensity = args[1].to_float() if args.size() > 1 and args[1].is_valid_float() else 1.0
        
        # Set projection mode
        if color_temperature and color_temperature.has_method("set_projection_mode"):
            color_temperature.set_projection_mode(mode)
            color_temperature.set_projection_intensity(intensity)
            color_temperature.toggle_projection_visibility(true)
            
            return {
                "success": true,
                "color": TERMINAL_COLORS.SUCCESS,
                "message": "Projection set to mode '" + mode + "' with intensity " + str(intensity)
            }
        else:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Color system is not properly connected."
            }
    }

# ----- AKASHIC COMMANDS -----
func _cmd_number(args):
    if args.size() == 0:
        # Show lucky numbers
        return {
            "success": true,
            "color": TERMINAL_COLORS.INFO,
            "message": "System lucky numbers: " + str(SYSTEM_LUCKY_NUMBERS)
        }
    
    var value_str = args[0]
    var name = args[1] if args.size() > 1 else "custom_number"
    
    if not value_str.is_valid_float():
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Invalid number: " + value_str
        }
    
    var value = value_str.to_float()
    
    # Register number in akashic system
    if akashic_system and akashic_system.has_method("register_number"):
        akashic_system.register_number(value, name)
        
        # Find closest lucky number
        var closest_lucky = value
        var smallest_diff = abs(value - SYSTEM_LUCKY_NUMBERS[0])
        
        for lucky in SYSTEM_LUCKY_NUMBERS:
            var diff = abs(value - lucky)
            if diff < smallest_diff:
                smallest_diff = diff
                closest_lucky = lucky
        
        return {
            "success": true,
            "color": TERMINAL_COLORS.SUCCESS,
            "message": "Number " + str(value) + " registered as '" + name + "'\n" +
                      "Closest lucky number: " + str(closest_lucky)
        }
    else:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Akashic system is not properly connected."
        }

func _cmd_universe(args):
    if args.size() == 0:
        # Show connected universes
        if terminal_bridge:
            var universes = terminal_bridge.get_connected_universes()
            return {
                "success": true,
                "color": TERMINAL_COLORS.INFO,
                "message": "Connected universes:\n\n" + "\n".join(universes)
            }
        else:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Terminal bridge is not properly connected."
            }
    
    var universe_name = args[0].to_lower()
    var connect_mode = args[1].to_lower() if args.size() > 1 else "connect"
    var should_connect = connect_mode != "disconnect"
    
    # Connect to universe
    if terminal_bridge and terminal_bridge.has_method("connect_to_universe"):
        var result = terminal_bridge.connect_to_universe(universe_name, should_connect)
        
        if result.success:
            return {
                "success": true,
                "color": TERMINAL_COLORS.SUCCESS,
                "message": (should_connect ? "Connected to" : "Disconnected from") + " universe: " + universe_name + "\n" +
                          "Cosmic address: " + result.cosmic_address
            }
        else:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Failed to " + (should_connect ? "connect to" : "disconnect from") + " universe: " + 
                          (result.error if result.has("error") else "Unknown error")
            }
    else:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Terminal bridge is not properly connected."
        }

func _cmd_record(args):
    if args.size() < 2:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Missing record parameters. Usage: record <type> <data>"
        }
    
    var record_type = args[0]
    var record_data = " ".join(args.slice(1))
    
    # Create record
    if terminal_bridge and terminal_bridge.has_method("sync_akashic_record"):
        var result = terminal_bridge.sync_akashic_record(record_type)
        
        if result.success:
            emit_signal("record_created", record_type, record_data)
            
            return {
                "success": true,
                "color": TERMINAL_COLORS.SUCCESS,
                "message": "Record created:\n" +
                          "Type: " + record_type + "\n" +
                          "Data: " + record_data + "\n" +
                          "Cosmic address: " + result.cosmic_address
            }
        else:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Failed to create record: " + (result.error if result.has("error") else "Unknown error")
            }
    else:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Terminal bridge is not properly connected."
        }

# ----- ETHEREAL COMMANDS -----
func _cmd_energy(args):
    if args.size() < 3:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Missing energy parameters. Usage: energy <shape> <from_x,y,z> <to_x,y,z>"
        }
    
    var shape_type = args[0]
    var from_coords = args[1].split(",")
    var to_coords = args[2].split(",")
    
    if from_coords.size() < 3 or to_coords.size() < 3:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Invalid coordinate format. Use x,y,z format."
        }
    
    var from_point = Vector3(
        from_coords[0].to_float(),
        from_coords[1].to_float(),
        from_coords[2].to_float()
    )
    
    var to_point = Vector3(
        to_coords[0].to_float(),
        to_coords[1].to_float(),
        to_coords[2].to_float()
    )
    
    # Transport energy
    if terminal_bridge and terminal_bridge.has_method("transport_energy_shape"):
        var result = terminal_bridge.transport_energy_shape(shape_type, from_point, to_point)
        
        if result.success:
            return {
                "success": true,
                "color": TERMINAL_COLORS.SUCCESS,
                "message": "Energy transported:\n" +
                          "Shape: " + shape_type + "\n" +
                          "From: " + str(from_point) + "\n" +
                          "To: " + str(to_point) + "\n" +
                          "Flow direction: " + str(result.flow_direction)
            }
        else:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Failed to transport energy: " + (result.error if result.has("error") else "Unknown error")
            }
    else:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Terminal bridge is not properly connected."
        }

func _cmd_audio(args):
    if args.size() == 0:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Missing audio parameters. Usage: audio <frequency_range> [intensity]"
        }
    
    var frequency_range = args[0].to_lower()
    var intensity = args[1].to_float() if args.size() > 1 and args[1].is_valid_float() else 1.0
    
    # Valid frequency ranges
    var valid_ranges = ["low", "mid", "high"]
    
    if not valid_ranges.has(frequency_range):
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Invalid frequency range: " + frequency_range + "\nValid ranges: " + str(valid_ranges)
        }
    
    # Activate audio input
    if terminal_bridge and terminal_bridge.has_method("activate_audio_input"):
        var result = terminal_bridge.activate_audio_input(frequency_range, intensity)
        
        if result.success:
            return {
                "success": true,
                "color": TERMINAL_COLORS.SUCCESS,
                "message": "Audio input activated:\n" +
                          "Frequency range: " + frequency_range + " (" + 
                          str(result.frequency_values[0]) + "-" + str(result.frequency_values[1]) + " Hz)\n" +
                          "Intensity: " + str(intensity)
            }
        else:
            return {
                "success": false,
                "color": TERMINAL_COLORS.ERROR,
                "message": "Failed to activate audio input: " + (result.error if result.has("error") else "Unknown error")
            }
    else:
        return {
            "success": false,
            "color": TERMINAL_COLORS.ERROR,
            "message": "Terminal bridge is not properly connected."
        }

# ----- HISTORY MANAGEMENT -----
func _add_to_history(command):
    command_history.append(command)
    
    # Trim history if necessary
    if command_history.size() > HISTORY_MAX_SIZE:
        command_history.pop_front()
    
    # Reset history index
    history_index = command_history.size()

func get_previous_command():
    if command_history.size() == 0:
        return ""
    
    # Decrease history index
    history_index = max(0, history_index - 1)
    
    return command_history[history_index]

func get_next_command():
    if command_history.size() == 0:
        return ""
    
    # Increase history index
    history_index = min(command_history.size(), history_index + 1)
    
    if history_index == command_history.size():
        return command_buffer
    else:
        return command_history[history_index]

func set_command_buffer(buffer):
    command_buffer = buffer

func is_terminal_open():
    return terminal_open

# ----- PUBLIC API -----
func connect_all_systems():
    var result = _cmd_connect(["all"])
    
    if result.success:
        # Sync all systems
        _cmd_sync(["all"])
    
    return result

func set_migration_paths(godot3_path, godot4_path):
    godot3_project_path = godot3_path
    godot4_project_path = godot4_path
    
    if migration_system and migration_system.has_method("set_project_paths"):
        migration_system.set_project_paths(godot3_path, godot4_path)
    
    return {
        "success": true,
        "godot3_path": godot3_path,
        "godot4_path": godot4_path
    }

func start_migration(from_path = null, to_path = null):
    var args = []
    
    if from_path:
        args.append(from_path)
    else:
        args.append(godot3_project_path)
    
    if to_path:
        args.append(to_path)
    else:
        args.append(godot4_project_path)
    
    return _cmd_migrate(args)

func get_terminal_prompt():
    var temp_indicator = ""
    
    if connected_components.color and color_temperature:
        var state = color_temperature.get_current_state()
        
        match state.color_state:
            "VERY_COLD", "COLD":
                temp_indicator = "❄️ "
            "COOL":
                temp_indicator = "🌧️ "
            "NEUTRAL":
                temp_indicator = "☀️ "
            "WARM":
                temp_indicator = "🔆 "
            "HOT", "VERY_HOT":
                temp_indicator = "🔥 "
    
    return temp_indicator + (username + "@" if logged_in else "") + current_directory + prompt_style