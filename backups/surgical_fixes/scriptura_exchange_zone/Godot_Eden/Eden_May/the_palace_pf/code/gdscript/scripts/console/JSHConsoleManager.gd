extends Node
class_name JSHConsoleManager

# Singleton pattern
static var _instance: JSHConsoleManager = null

static func get_instance() -> JSHConsoleManager:
    if not _instance:
        _instance = JSHConsoleManager.new()
    return _instance

# Command registration
var commands: Dictionary = {}
var default_commands: Dictionary = {
    "help": {
        "description": "Show help for available commands",
        "usage": "help [command]",
        "callback": Callable(self, "_cmd_help"),
        "min_args": 0,
        "max_args": 1,
        "arg_types": [TYPE_STRING],
        "arg_descriptions": ["Command name to get help for"],
        "system": true
    },
    "clear": {
        "description": "Clear the console output",
        "usage": "clear",
        "callback": Callable(self, "_cmd_clear"),
        "min_args": 0,
        "max_args": 0,
        "system": true
    },
    "list": {
        "description": "List all available commands",
        "usage": "list [filter]",
        "callback": Callable(self, "_cmd_list"),
        "min_args": 0,
        "max_args": 1,
        "arg_types": [TYPE_STRING],
        "arg_descriptions": ["Optional filter for command names"],
        "system": true
    },
    "history": {
        "description": "Show command history",
        "usage": "history [clear]",
        "callback": Callable(self, "_cmd_history"),
        "min_args": 0,
        "max_args": 1,
        "arg_types": [TYPE_STRING],
        "arg_descriptions": ["Use 'clear' to clear history"],
        "system": true
    },
    "echo": {
        "description": "Display text in the console",
        "usage": "echo <text>",
        "callback": Callable(self, "_cmd_echo"),
        "min_args": 1,
        "max_args": -1,  # Unlimited args
        "arg_types": [TYPE_STRING],
        "arg_descriptions": ["Text to display"],
        "system": true
    },
    "info": {
        "description": "Display system information",
        "usage": "info [jsh|entity|db|spatial]",
        "callback": Callable(self, "_cmd_info"),
        "min_args": 0,
        "max_args": 1,
        "arg_types": [TYPE_STRING],
        "arg_descriptions": ["Optional subsystem to show info for"],
        "system": true
    }
}

# Command execution
var command_history: Array = []
var command_history_limit: int = 100
var output_buffer: Array = []
var variables: Dictionary = {}

# Console UI
var console_ui: Control = null
var console_visible: bool = false
var autocomplete_active: bool = false

# Signals
signal command_executed(command_text, result)
signal command_registered(command_name)
signal command_unregistered(command_name)
signal console_visibility_changed(visible)
signal console_output_updated()

func _init() -> void:
    if _instance == null:
        _instance = self
        name = "JSHConsoleManager"
        print("JSHConsoleManager: Instance created")
        
        # Register default commands
        for cmd_name in default_commands:
            register_command(cmd_name, default_commands[cmd_name])

func _ready() -> void:
    # Initialize variables with system info
    variables = {
        "system": "JSH Eden Console",
        "version": "1.0.0",
        "start_time": Time.get_datetime_string_from_system()
    }

# Command registration
func register_command(command_name: String, command_data: Dictionary) -> bool:
    if commands.has(command_name):
        print("JSHConsoleManager: Command already exists: " + command_name)
        return false
    
    # Validate command data
    if not command_data.has("description"):
        command_data["description"] = "No description provided"
    
    if not command_data.has("usage"):
        command_data["usage"] = command_name
    
    if not command_data.has("callback") or not command_data["callback"] is Callable:
        print("JSHConsoleManager: Command must have a valid callback: " + command_name)
        return false
    
    if not command_data.has("min_args"):
        command_data["min_args"] = 0
    
    if not command_data.has("max_args"):
        command_data["max_args"] = 0
    
    # Register command
    commands[command_name] = command_data
    emit_signal("command_registered", command_name)
    
    print("JSHConsoleManager: Registered command: " + command_name)
    return true

func unregister_command(command_name: String) -> bool:
    if not commands.has(command_name):
        return false
    
    # Protect system commands
    if commands[command_name].get("system", false) == true:
        print("JSHConsoleManager: Cannot unregister system command: " + command_name)
        return false
    
    commands.erase(command_name)
    emit_signal("command_unregistered", command_name)
    
    print("JSHConsoleManager: Unregistered command: " + command_name)
    return true

func execute_command(command_text: String) -> Dictionary:
    if command_text.strip_edges().is_empty():
        return { "success": false, "message": "Empty command" }
    
    # Add command to history
    if command_history.size() >= command_history_limit:
        command_history.pop_front()
    
    command_history.append(command_text)
    
    # Parse command and arguments
    var command_parts = _parse_command(command_text)
    var command_name = command_parts[0]
    var args = command_parts.slice(1)
    
    # Validate command
    if not commands.has(command_name):
        var result = {
            "success": false,
            "message": "Unknown command: " + command_name,
            "command": command_name
        }
        emit_signal("command_executed", command_text, result)
        return result
    
    var command = commands[command_name]
    
    # Validate argument count
    if args.size() < command.min_args:
        var result = {
            "success": false,
            "message": "Not enough arguments. Usage: " + command.usage,
            "command": command_name
        }
        emit_signal("command_executed", command_text, result)
        return result
    
    if command.max_args >= 0 and args.size() > command.max_args:
        var result = {
            "success": false,
            "message": "Too many arguments. Usage: " + command.usage,
            "command": command_name
        }
        emit_signal("command_executed", command_text, result)
        return result
    
    # Type conversion and validation
    var converted_args = args
    if command.has("arg_types") and command.arg_types.size() > 0:
        converted_args = []
        for i in range(min(args.size(), command.arg_types.size())):
            var arg_type = command.arg_types[i]
            
            match arg_type:
                TYPE_INT:
                    if args[i].is_valid_int():
                        converted_args.append(int(args[i]))
                    else:
                        var result = {
                            "success": false,
                            "message": "Argument " + str(i+1) + " must be an integer",
                            "command": command_name
                        }
                        emit_signal("command_executed", command_text, result)
                        return result
                
                TYPE_FLOAT:
                    if args[i].is_valid_float():
                        converted_args.append(float(args[i]))
                    else:
                        var result = {
                            "success": false,
                            "message": "Argument " + str(i+1) + " must be a number",
                            "command": command_name
                        }
                        emit_signal("command_executed", command_text, result)
                        return result
                
                TYPE_BOOL:
                    var lower_arg = args[i].to_lower()
                    if lower_arg in ["true", "yes", "1", "on"]:
                        converted_args.append(true)
                    elif lower_arg in ["false", "no", "0", "off"]:
                        converted_args.append(false)
                    else:
                        var result = {
                            "success": false,
                            "message": "Argument " + str(i+1) + " must be a boolean value",
                            "command": command_name
                        }
                        emit_signal("command_executed", command_text, result)
                        return result
                
                _:  # String or other types
                    converted_args.append(args[i])
        
        # Add remaining arguments
        for i in range(command.arg_types.size(), args.size()):
            converted_args.append(args[i])
    
    # Execute command
    var callback = command.callback
    var result
    
    if converted_args.size() > 0:
        result = callback.call(self, converted_args)
    else:
        result = callback.call(self)
    
    # Ensure result is a dictionary
    if result == null:
        result = {
            "success": true,
            "message": "Command executed",
            "command": command_name
        }
    elif typeof(result) != TYPE_DICTIONARY:
        result = {
            "success": true,
            "message": str(result),
            "command": command_name
        }
    
    # Add command info
    if not result.has("command"):
        result["command"] = command_name
    
    # Emit signal
    emit_signal("command_executed", command_text, result)
    return result

func get_command_list() -> Array:
    return commands.keys()

func get_command_help(command_name: String) -> String:
    if not commands.has(command_name):
        return "Unknown command: " + command_name
    
    var command = commands[command_name]
    var help_text = command_name + ": " + command.description + "\n"
    help_text += "Usage: " + command.usage + "\n"
    
    if command.has("arg_descriptions") and command.arg_descriptions.size() > 0:
        help_text += "Arguments:\n"
        
        for i in range(command.arg_descriptions.size()):
            var type_str = "any"
            if command.has("arg_types") and i < command.arg_types.size():
                match command.arg_types[i]:
                    TYPE_INT: type_str = "integer"
                    TYPE_FLOAT: type_str = "number"
                    TYPE_BOOL: type_str = "boolean"
                    TYPE_STRING: type_str = "string"
            
            help_text += "  - " + command.arg_descriptions[i] + " (" + type_str + ")\n"
    
    return help_text

# Console output
func print_line(text: String, color: Color = Color.WHITE) -> void:
    output_buffer.append({"text": text, "color": color})
    emit_signal("console_output_updated")

func print_error(text: String) -> void:
    print_line("ERROR: " + text, Color(1, 0.3, 0.3))

func print_warning(text: String) -> void:
    print_line("WARNING: " + text, Color(1, 0.9, 0.2))

func print_success(text: String) -> void:
    print_line("SUCCESS: " + text, Color(0.3, 1, 0.3))

func clear() -> void:
    output_buffer.clear()
    emit_signal("console_output_updated")

# Console state
func is_visible() -> bool:
    return console_visible

func set_visible(visible: bool) -> void:
    if console_visible != visible:
        console_visible = visible
        emit_signal("console_visibility_changed", visible)

func toggle_visibility() -> void:
    set_visible(not console_visible)

# History management
func get_command_history() -> Array:
    return command_history.duplicate()

func clear_command_history() -> void:
    command_history.clear()

# Autocomplete
func get_autocomplete_suggestions(partial_command: String) -> Array:
    var suggestions = []
    
    # Empty input - suggest nothing
    if partial_command.strip_edges().is_empty():
        return []
    
    var parts = _parse_command(partial_command)
    
    if parts.size() <= 1:
        # Command name autocomplete
        var cmd_prefix = parts[0].to_lower()
        
        for cmd in commands:
            if cmd.to_lower().begins_with(cmd_prefix):
                suggestions.append(cmd)
    else:
        # Argument autocomplete - depends on the command
        var cmd_name = parts[0]
        if commands.has(cmd_name):
            # Custom argument completions can be added here for specific commands
            var command = commands[cmd_name]
            
            if command.has("arg_autocomplete"):
                var arg_index = parts.size() - 2  # -2 because parts[0] is command, and we want index of current arg
                if arg_index < command.arg_autocomplete.size():
                    var autocomplete_func = command.arg_autocomplete[arg_index]
                    if autocomplete_func is Callable:
                        var arg_suggestions = autocomplete_func.call(parts[parts.size() - 1])
                        if arg_suggestions is Array:
                            suggestions = arg_suggestions
    
    return suggestions

# Variables and context
func set_variable(variable_name: String, value) -> void:
    variables[variable_name] = value

func get_variable(variable_name: String):
    if variables.has(variable_name):
        return variables[variable_name]
    return null

func get_all_variables() -> Dictionary:
    return variables.duplicate()

# Command parsing
func _parse_command(command_text: String) -> Array:
    var result = []
    var current_token = ""
    var in_quotes = false
    var escape_next = false
    
    for i in range(command_text.length()):
        var c = command_text[i]
        
        if escape_next:
            current_token += c
            escape_next = false
        elif c == "\\":
            escape_next = true
        elif c == "\"":
            in_quotes = not in_quotes
        elif c == " " and not in_quotes:
            if current_token.length() > 0:
                result.append(current_token)
                current_token = ""
        else:
            current_token += c
    
    if current_token.length() > 0:
        result.append(current_token)
    
    return result

# Default command implementations
func _cmd_help(self, args = []) -> Dictionary:
    if args.size() == 0:
        # General help
        print_line("Available commands:")
        var sorted_commands = commands.keys()
        sorted_commands.sort()
        
        for cmd in sorted_commands:
            print_line("  " + cmd + ": " + commands[cmd].description)
        
        print_line("\nType 'help <command>' for detailed help on a specific command.")
        return { "success": true, "message": "Help displayed" }
    else:
        # Specific command help
        var command_name = args[0]
        
        if commands.has(command_name):
            print_line(get_command_help(command_name))
            return { "success": true, "message": "Help for " + command_name + " displayed" }
        else:
            print_error("Unknown command: " + command_name)
            print_line("Type 'list' to see all available commands.")
            return { "success": false, "message": "Unknown command: " + command_name }
    }

func _cmd_clear(self) -> Dictionary:
    clear()
    return { "success": true, "message": "Console cleared" }

func _cmd_list(self, args = []) -> Dictionary:
    var filter = ""
    if args.size() > 0:
        filter = args[0].to_lower()
    
    var sorted_commands = commands.keys()
    sorted_commands.sort()
    
    var filtered_commands = sorted_commands
    if not filter.is_empty():
        filtered_commands = []
        for cmd in sorted_commands:
            if cmd.to_lower().contains(filter) or commands[cmd].description.to_lower().contains(filter):
                filtered_commands.append(cmd)
    
    print_line("Commands" + (" matching '" + filter + "'" if not filter.is_empty() else "") + ":")
    
    for cmd in filtered_commands:
        var system_tag = "[system] " if commands[cmd].get("system", false) else ""
        print_line("  " + cmd + ": " + system_tag + commands[cmd].description)
    
    return {
        "success": true,
        "message": str(filtered_commands.size()) + " commands listed",
        "commands": filtered_commands
    }

func _cmd_history(self, args = []) -> Dictionary:
    if args.size() > 0 and args[0].to_lower() == "clear":
        clear_command_history()
        print_line("Command history cleared")
        return { "success": true, "message": "Command history cleared" }
    
    if command_history.size() == 0:
        print_line("Command history is empty")
    else:
        print_line("Command history:")
        for i in range(command_history.size()):
            print_line(str(i+1) + ": " + command_history[i])
    
    return {
        "success": true,
        "message": str(command_history.size()) + " commands in history",
        "history": command_history
    }

func _cmd_echo(self, args: Array) -> Dictionary:
    var message = " ".join(args)
    print_line(message)
    return { "success": true, "message": message }

func _cmd_info(self, args = []) -> Dictionary:
    var subsystem = ""
    if args.size() > 0:
        subsystem = args[0].to_lower()
    
    if subsystem.is_empty() or subsystem == "jsh":
        print_line("JSH Eden Console System")
        print_line("=====================")
        print_line("System: " + str(variables.get("system", "Unknown")))
        print_line("Version: " + str(variables.get("version", "Unknown")))
        print_line("Started: " + str(variables.get("start_time", "Unknown")))
        print_line("Commands: " + str(commands.size()))
        print_line("History: " + str(command_history.size()))
        print_line("Variables: " + str(variables.size()))
        
        # System details
        var system_info = Engine.get_engine_info()
        print_line("\nEngine:")
        print_line("  Version: " + system_info.version)
        print_line("  Platform: " + OS.get_name())
        
        var datetime = Time.get_datetime_dict_from_system()
        print_line("Time: " + "%02d:%02d:%02d" % [datetime.hour, datetime.minute, datetime.second])
        print_line("Date: " + "%04d-%02d-%02d" % [datetime.year, datetime.month, datetime.day])
    
    if subsystem == "entity" or subsystem == "entities":
        var entity_manager = get_node_or_null("/root/JSHEntityManager") or JSHEntityManager.get_instance()
        
        if entity_manager:
            var stats = entity_manager.get_statistics()
            print_line("\nEntity System")
            print_line("=============")
            print_line("Total Entities: " + str(stats.total_entities))
            print_line("Process Queue: " + str(stats.process_queue_size))
            print_line("Average Complexity: " + str(snappedf(stats.average_complexity, 0.01)))
            
            print_line("\nEntities by Type:")
            for type in stats.by_type:
                print_line("  " + type + ": " + str(stats.by_type[type]))
            
            print_line("\nEntities by Evolution Stage:")
            for stage in stats.by_evolution_stage:
                print_line("  Stage " + stage + ": " + str(stats.by_evolution_stage[stage]))
        else:
            print_error("Entity Manager not found")
    
    if subsystem == "db" or subsystem == "database":
        var db_manager = get_node_or_null("/root/JSHDatabaseManager") or JSHDatabaseManager.get_instance()
        
        if db_manager:
            var stats = db_manager.get_database_statistics()
            print_line("\nDatabase System")
            print_line("===============")
            print_line("Entity Count: " + str(stats.entity_count if stats.has("entity_count") else "Unknown"))
            print_line("Dictionary Count: " + str(stats.dictionary_count if stats.has("dictionary_count") else "Unknown"))
            print_line("Zone Count: " + str(stats.zone_count if stats.has("zone_count") else "Unknown"))
            
            if stats.has("cache"):
                print_line("\nCache:")
                print_line("  Entity Cache Size: " + str(stats.cache.entity_cache_size))
                print_line("  Entity Cache Limit: " + str(stats.cache.entity_cache_limit))
                print_line("  Pending Saves: " + str(stats.cache.pending_saves))
        else:
            print_error("Database Manager not found")
    
    if subsystem == "spatial" or subsystem == "space":
        var spatial_manager = get_node_or_null("/root/JSHSpatialManager") or JSHSpatialManager.get_instance()
        
        if spatial_manager:
            var stats = spatial_manager.get_zone_statistics()
            print_line("\nSpatial System")
            print_line("==============")
            print_line("Total Zones: " + str(stats.total_zones))
            print_line("Loaded Zones: " + str(stats.loaded_zones))
            print_line("Visible Entities: " + str(stats.visible_entities))
            print_line("Active Zone: " + str(stats.active_zone))
            
            print_line("\nActive Zone Details:")
            var active_zone = spatial_manager.get_active_zone()
            if not active_zone.is_empty():
                var zone_stats = spatial_manager.get_zone_statistics(active_zone)
                print_line("  Name: " + str(zone_stats.name))
                print_line("  Entity Count: " + str(zone_stats.entity_count))
                print_line("  Size: " + str(zone_stats.size))
                print_line("  Volume: " + str(zone_stats.volume))
                print_line("  Entity Density: " + str(snappedf(zone_stats.entity_density, 0.001)))
                print_line("  Transition Count: " + str(zone_stats.transition_count))
                print_line("  Child Zones: " + str(zone_stats.child_count))
        else:
            print_error("Spatial Manager not found")
    
    return { "success": true, "message": "System information displayed" }