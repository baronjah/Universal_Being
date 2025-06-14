extends Control

class_name JSHConsoleAdvanced

# ----- CONSOLE SETTINGS -----
@export_category("Console Settings")
@export var console_font: Font
@export var console_font_size: int = 14
@export var console_max_lines: int = 100
@export var console_padding: Vector2 = Vector2(10, 10)
@export var auto_complete_enabled: bool = true
@export var save_command_history: bool = true
@export var command_history_size: int = 50

# ----- VISUAL SETTINGS -----
@export_category("Visual Settings")
@export var console_background_color: Color = Color(0.0, 0.0, 0.0, 0.8)
@export var console_text_color: Color = Color(0.8, 0.8, 0.8, 1.0)
@export var console_input_color: Color = Color(1.0, 1.0, 1.0, 1.0)
@export var console_error_color: Color = Color(1.0, 0.3, 0.3, 1.0)
@export var console_warning_color: Color = Color(1.0, 0.8, 0.0, 1.0)
@export var console_success_color: Color = Color(0.3, 1.0, 0.3, 1.0)
@export var console_border_color: Color = Color(0.5, 0.5, 0.5, 0.5)
@export var console_border_width: int = 1

# ----- GAME INTEGRATION SETTINGS -----
@export_category("Game Integration Settings")
@export var overlay_mode_enabled: bool = false
@export var game_overlay_path: NodePath
@export var word_manifestor_path: NodePath
@export var word_dna_system_path: NodePath
@export var player_controller_path: NodePath
@export var cheat_codes_enabled: bool = true

# ----- COMPONENT REFERENCES -----
@onready var console_input: LineEdit = $ConsoleInput
@onready var console_output: RichTextLabel = $ConsoleOutput
@onready var auto_complete_popup: PopupMenu = $AutoCompletePopup
@onready var game_overlay = get_node_or_null(game_overlay_path)
@onready var word_manifestor = get_node_or_null(word_manifestor_path)
@onready var word_dna_system = get_node_or_null(word_dna_system_path)
@onready var player_controller = get_node_or_null(player_controller_path)

# ----- CONSOLE STATE -----
var console_visible: bool = false
var command_history: Array = []
var command_history_index: int = -1
var current_input_text: String = ""
var registered_commands: Dictionary = {}
var cheat_codes: Dictionary = {}

# ----- SIGNALS -----
signal command_executed(command, result)
signal word_entered(word)
signal cheat_code_activated(code, effect)
signal console_toggled(visible)

# ----- INITIALIZATION -----
func _ready():
    # Setup console components
    setup_console_components()
    
    # Register built-in commands
    register_built_in_commands()
    
    # Register cheat codes if enabled
    if cheat_codes_enabled:
        register_cheat_codes()
    
    # Hide console initially
    visible = false
    
    # Connect signals
    console_input.text_submitted.connect(_on_console_input_submitted)
    
    # Load command history if enabled
    if save_command_history:
        load_command_history()

# ----- CONSOLE SETUP -----
func setup_console_components():
    # Setup console input
    if console_input:
        console_input.placeholder_text = "Enter command or word..."
        console_input.clear_button_enabled = true
        if console_font:
            console_input.add_theme_font_override("font", console_font)
            console_input.add_theme_font_size_override("font_size", console_font_size)
    
    # Setup console output
    if console_output:
        console_output.bbcode_enabled = true
        console_output.scroll_following = true
        if console_font:
            console_output.add_theme_font_override("normal_font", console_font)
            console_output.add_theme_font_size_override("normal_font_size", console_font_size)
    
    # Setup autocomplete popup
    if auto_complete_popup:
        auto_complete_popup.id_pressed.connect(_on_auto_complete_selected)

# ----- COMMAND REGISTRATION -----
func register_command(name: String, description: String, usage: String, callback: Callable):
    registered_commands[name] = {
        "description": description,
        "usage": usage,
        "callback": callback
    }

func register_built_in_commands():
    # Help command
    register_command("help", "Display available commands", "help [command]", Callable(self, "_cmd_help"))
    
    # Clear console
    register_command("clear", "Clear the console output", "clear", Callable(self, "_cmd_clear"))
    
    # Echo command
    register_command("echo", "Display text in the console", "echo <text>", Callable(self, "_cmd_echo"))
    
    # History command
    register_command("history", "Show command history", "history [clear]", Callable(self, "_cmd_history"))
    
    # Word commands
    register_command("word", "Create or manipulate words", "word <create|delete|connect|list|info> [args]", Callable(self, "_cmd_word"))
    
    # Overlay commands
    register_command("overlay", "Control game overlay", "overlay <on|off|mode> [args]", Callable(self, "_cmd_overlay"))
    
    # DNA commands
    register_command("dna", "Work with word DNA", "dna <generate|info|evolve> [word_id]", Callable(self, "_cmd_dna"))
    
    # Player commands
    register_command("player", "Control player", "player <tp|mode|energy> [args]", Callable(self, "_cmd_player"))
    
    # System commands
    register_command("system", "System operations", "system <info|fps|memory>", Callable(self, "_cmd_system"))

func register_cheat_codes():
    # Energy cheat codes
    cheat_codes["idkfa"] = {
        "description": "Unlimited energy",
        "effect": "energy_unlimited",
        "callback": Callable(self, "_cheat_unlimited_energy")
    }
    
    # God mode
    cheat_codes["iddqd"] = {
        "description": "God mode",
        "effect": "god_mode",
        "callback": Callable(self, "_cheat_god_mode")
    }
    
    # Spawn all words
    cheat_codes["idfa"] = {
        "description": "Spawn many words",
        "effect": "spawn_words",
        "callback": Callable(self, "_cheat_spawn_words")
    }
    
    # Reality shift
    cheat_codes["idclip"] = {
        "description": "No-clip mode",
        "effect": "noclip",
        "callback": Callable(self, "_cheat_noclip")
    }
    
    # Word connection
    cheat_codes["iddt"] = {
        "description": "Reveal all connections",
        "effect": "reveal_connections",
        "callback": Callable(self, "_cheat_reveal_connections")
    }

# ----- INPUT HANDLING -----
func _input(event):
    # Toggle console visibility with tilde/backtick key
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_QUOTELEFT or event.keycode == KEY_ASCIITILDE:
            toggle_console()
        
        # Handle up/down arrow for command history
        if console_visible and console_input.has_focus():
            if event.keycode == KEY_UP:
                cycle_command_history(true)
                get_viewport().set_input_as_handled()
            elif event.keycode == KEY_DOWN:
                cycle_command_history(false)
                get_viewport().set_input_as_handled()
            elif event.keycode == KEY_TAB and auto_complete_enabled:
                show_auto_complete()
                get_viewport().set_input_as_handled()

func _on_console_input_submitted(text: String):
    # Skip empty input
    if text.strip_edges() == "":
        return
    
    # Echo the input
    add_console_line("> " + text, console_input_color)
    
    # Add to command history
    add_to_command_history(text)
    
    # Process the input
    process_console_input(text)
    
    # Clear the input
    console_input.clear()
    
    # Save command history
    if save_command_history:
        save_command_history()

func process_console_input(text: String):
    # Check if it's a command (starts with /)
    if text.begins_with("/"):
        execute_command(text.substr(1))
    # Check if it's a cheat code
    elif cheat_codes_enabled and cheat_codes.has(text.to_lower()):
        execute_cheat_code(text.to_lower())
    # Otherwise treat as a word to manifest
    else:
        if word_manifestor:
            # Emit signal for word manifestation
            emit_signal("word_entered", text)
            add_console_line("Manifesting word: " + text, console_success_color)
        else:
            add_console_line("Cannot manifest word - word system not connected", console_error_color)

func execute_command(command_text: String):
    var parts = command_text.split(" ", false)
    if parts.size() == 0:
        return
    
    var command_name = parts[0].to_lower()
    var args = parts.slice(1)
    
    if registered_commands.has(command_name):
        var command = registered_commands[command_name]
        var result = command.callback.call(args)
        
        # Emit signal
        emit_signal("command_executed", command_name, result)
        
        # Format result
        if result is Dictionary and result.has("message"):
            var color = console_text_color
            if result.has("color"):
                color = result.color
            add_console_line(result.message, color)
        elif result is String:
            add_console_line(result, console_text_color)
    else:
        add_console_line("Unknown command: " + command_name, console_error_color)
        add_console_line("Type /help for a list of commands", console_text_color)

func execute_cheat_code(code: String):
    if cheat_codes.has(code):
        var cheat = cheat_codes[code]
        
        # Execute cheat code
        var result = cheat.callback.call()
        
        # Show activation message
        add_console_line("Activated: " + cheat.description, console_success_color)
        
        # Emit signal
        emit_signal("cheat_code_activated", code, cheat.effect)
    else:
        add_console_line("Invalid cheat code", console_error_color)

# ----- CONSOLE OUTPUT -----
func add_console_line(text: String, color: Color = console_text_color):
    if console_output:
        # Format the text with color
        var formatted_text = "[color=#" + color.to_html(false) + "]" + text + "[/color]"
        
        # Add the line to console output
        console_output.append_text(formatted_text + "\n")
        
        # Trim console if needed
        if console_output.get_line_count() > console_max_lines:
            var excess_lines = console_output.get_line_count() - console_max_lines
            console_output.remove_line(0)

func clear_console():
    if console_output:
        console_output.clear()

# ----- COMMAND HISTORY MANAGEMENT -----
func add_to_command_history(command: String):
    # Don't add duplicates consecutively
    if command_history.size() > 0 and command_history.back() == command:
        return
    
    command_history.append(command)
    
    # Trim history if needed
    while command_history.size() > command_history_size:
        command_history.pop_front()
    
    # Reset index to point to the end
    command_history_index = command_history.size()

func cycle_command_history(up: bool):
    if command_history.size() == 0:
        return
    
    # Save current input if at the end
    if command_history_index == command_history.size():
        current_input_text = console_input.text
    
    if up:
        # Go up in history
        command_history_index = max(0, command_history_index - 1)
        console_input.text = command_history[command_history_index]
    else:
        # Go down in history
        command_history_index = min(command_history.size(), command_history_index + 1)
        
        if command_history_index == command_history.size():
            console_input.text = current_input_text
        else:
            console_input.text = command_history[command_history_index]
    
    # Move cursor to end
    console_input.caret_column = console_input.text.length()

func save_command_history():
    # Create Save File
    var save_file = FileAccess.open("user://console_history.json", FileAccess.WRITE)
    if save_file:
        save_file.store_string(JSON.stringify(command_history))
        save_file.close()

func load_command_history():
    if FileAccess.file_exists("user://console_history.json"):
        var save_file = FileAccess.open("user://console_history.json", FileAccess.READ)
        if save_file:
            var json_string = save_file.get_as_text()
            save_file.close()
            
            var json = JSON.new()
            var parse_result = json.parse(json_string)
            if parse_result == OK:
                var data = json.get_data()
                if data is Array:
                    command_history = data
                    command_history_index = command_history.size()

# ----- AUTO COMPLETE -----
func show_auto_complete():
    if not auto_complete_enabled or not auto_complete_popup:
        return
    
    var input_text = console_input.text
    var suggestions = []
    
    # If input starts with /, show command suggestions
    if input_text.begins_with("/"):
        var command_prefix = input_text.substr(1).to_lower()
        
        # Find matching commands
        for command in registered_commands.keys():
            if command.begins_with(command_prefix):
                suggestions.append("/" + command)
    else:
        # Check for cheat codes
        for code in cheat_codes.keys():
            if code.begins_with(input_text.to_lower()):
                suggestions.append(code)
        
        # For word suggestions, we could integrate with a dictionary
        # This would need to be customized for your specific needs
    
    # If we have suggestions, show the popup
    if suggestions.size() > 0:
        auto_complete_popup.clear()
        
        for i in range(suggestions.size()):
            auto_complete_popup.add_item(suggestions[i], i)
        
        # Position popup below the input field
        var input_rect = console_input.get_global_rect()
        auto_complete_popup.position = Vector2(input_rect.position.x, input_rect.position.y + input_rect.size.y)
        auto_complete_popup.size = Vector2(input_rect.size.x, min(suggestions.size() * 20, 200))
        
        auto_complete_popup.popup()

func _on_auto_complete_selected(id: int):
    var text = auto_complete_popup.get_item_text(id)
    console_input.text = text
    console_input.caret_column = text.length()
    auto_complete_popup.hide()

# ----- VISIBILITY MANAGEMENT -----
func toggle_console():
    console_visible = !console_visible
    visible = console_visible
    
    if console_visible:
        # Pause game when console is open (optional)
        # get_tree().paused = true
        
        # Focus the input field
        console_input.grab_focus()
    else:
        # Resume game when console is closed
        # get_tree().paused = false
        
        # Clear focus
        console_input.release_focus()
    
    # Emit signal
    emit_signal("console_toggled", console_visible)

# ----- BUILT-IN COMMANDS -----
func _cmd_help(args: Array) -> Dictionary:
    if args.size() == 0:
        # Show general help
        var help_text = "Available commands:\n"
        
        for command in registered_commands.keys():
            help_text += "  /" + command + " - " + registered_commands[command].description + "\n"
        
        if cheat_codes_enabled:
            help_text += "\nCheat codes are also available. Try some classic FPS cheats!"
        
        return {"message": help_text}
    else:
        # Show help for specific command
        var command = args[0].to_lower()
        
        if registered_commands.has(command):
            var cmd = registered_commands[command]
            var help_text = "Command: /" + command + "\n"
            help_text += "Description: " + cmd.description + "\n"
            help_text += "Usage: /" + cmd.usage
            
            return {"message": help_text}
        else:
            return {"message": "No help available for '" + command + "'", "color": console_error_color}

func _cmd_clear(args: Array) -> Dictionary:
    clear_console()
    return {"message": "Console cleared"}

func _cmd_echo(args: Array) -> Dictionary:
    if args.size() == 0:
        return {"message": "Usage: /echo <text>", "color": console_warning_color}
    
    var text = " ".join(args)
    return {"message": text}

func _cmd_history(args: Array) -> Dictionary:
    if args.size() > 0 and args[0].to_lower() == "clear":
        command_history.clear()
        command_history_index = 0
        save_command_history()
        return {"message": "Command history cleared", "color": console_success_color}
    
    if command_history.size() == 0:
        return {"message": "Command history is empty"}
    
    var history_text = "Command history:\n"
    for i in range(command_history.size()):
        history_text += str(i + 1) + ". " + command_history[i] + "\n"
    
    return {"message": history_text}

func _cmd_word(args: Array) -> Dictionary:
    if args.size() == 0:
        return {"message": "Usage: /word <create|delete|connect|list|info> [args]", "color": console_warning_color}
    
    var subcommand = args[0].to_lower()
    var word_args = args.slice(1)
    
    match subcommand:
        "create":
            return _cmd_word_create(word_args)
        "delete":
            return _cmd_word_delete(word_args)
        "connect":
            return _cmd_word_connect(word_args)
        "list":
            return _cmd_word_list(word_args)
        "info":
            return _cmd_word_info(word_args)
        _:
            return {"message": "Unknown word subcommand: " + subcommand, "color": console_error_color}

func _cmd_word_create(args: Array) -> Dictionary:
    if args.size() < 1:
        return {"message": "Usage: /word create <word_text> [category] [position]", "color": console_warning_color}
    
    if not word_manifestor:
        return {"message": "Word manifestor not connected", "color": console_error_color}
    
    var word_text = args[0]
    var category = "concept"
    var position = Vector3.ZERO
    
    if args.size() >= 2:
        category = args[1]
    
    if args.size() >= 5:
        # Expecting x y z coordinates
        position = Vector3(float(args[2]), float(args[3]), float(args[4]))
    elif player_controller:
        # Use position in front of player
        position = player_controller.global_position + (-player_controller.camera_mount.global_transform.basis.z * 2.0) + Vector3(0, 1, 0)
    
    # Generate a unique ID
    var word_id = "word_" + word_text + "_" + str(randi())
    
    # Call into the word manifestor
    if word_manifestor.has_method("add_word"):
        word_manifestor.add_word(word_id, word_text, position, category)
        emit_signal("word_entered", word_text)
        return {"message": "Created word '" + word_text + "' (" + category + ") at " + str(position), "color": console_success_color}
    
    return {"message": "Failed to create word", "color": console_error_color}

func _cmd_word_delete(args: Array) -> Dictionary:
    # Implementation for deleting words
    return {"message": "Word deletion not implemented yet", "color": console_warning_color}

func _cmd_word_connect(args: Array) -> Dictionary:
    if args.size() < 2:
        return {"message": "Usage: /word connect <word_id1> <word_id2>", "color": console_warning_color}
    
    if not word_manifestor or not word_manifestor.has_method("connect_words"):
        return {"message": "Word manifestor not connected or doesn't support connections", "color": console_error_color}
    
    var word_id1 = args[0]
    var word_id2 = args[1]
    
    # Call into the word manifestor
    if word_manifestor.connect_words(word_id1, word_id2):
        return {"message": "Connected words '" + word_id1 + "' and '" + word_id2 + "'", "color": console_success_color}
    
    return {"message": "Failed to connect words", "color": console_error_color}

func _cmd_word_list(args: Array) -> Dictionary:
    # Implementation for listing words
    return {"message": "Word listing not implemented yet", "color": console_warning_color}

func _cmd_word_info(args: Array) -> Dictionary:
    # Implementation for getting word info
    return {"message": "Word info not implemented yet", "color": console_warning_color}

func _cmd_overlay(args: Array) -> Dictionary:
    if not game_overlay:
        return {"message": "Game overlay system not connected", "color": console_error_color}
    
    if args.size() == 0:
        return {"message": "Usage: /overlay <on|off|mode> [args]", "color": console_warning_color}
    
    var subcommand = args[0].to_lower()
    
    match subcommand:
        "on":
            game_overlay.set_overlay_enabled(true)
            return {"message": "Game overlay enabled", "color": console_success_color}
        "off":
            game_overlay.set_overlay_enabled(false)
            return {"message": "Game overlay disabled", "color": console_success_color}
        "mode":
            if args.size() < 2:
                return {"message": "Usage: /overlay mode <blend|replace|alternate>", "color": console_warning_color}
            
            var mode = args[1].to_upper()
            game_overlay.set_overlay_mode(mode)
            return {"message": "Game overlay mode set to " + mode, "color": console_success_color}
        "capture":
            if args.size() < 2:
                return {"message": "Usage: /overlay capture <window_title>", "color": console_warning_color}
            
            var window_title = " ".join(args.slice(1))
            game_overlay.target_window_title = window_title
            
            if game_overlay.is_capturing:
                game_overlay.disconnect_from_external_game()
            
            game_overlay.connect_to_external_game()
            return {"message": "Attempting to capture window: " + window_title, "color": console_success_color}
        _:
            return {"message": "Unknown overlay subcommand: " + subcommand, "color": console_error_color}

func _cmd_dna(args: Array) -> Dictionary:
    if not word_dna_system:
        return {"message": "DNA system not connected", "color": console_error_color}
    
    if args.size() == 0:
        return {"message": "Usage: /dna <generate|info|evolve> [args]", "color": console_warning_color}
    
    var subcommand = args[0].to_lower()
    
    match subcommand:
        "generate":
            if args.size() < 2:
                return {"message": "Usage: /dna generate <word>", "color": console_warning_color}
            
            var word = args[1]
            var dna = WordDNASystem.generate_dna_for_word(word)
            return {"message": "DNA for '" + word + "':\n" + WordDNASystem.dna_to_string_representation(dna), "color": console_success_color}
        "info":
            if args.size() < 2:
                return {"message": "Usage: /dna info <dna_string>", "color": console_warning_color}
            
            var dna = args[1]
            return {"message": "DNA Analysis:\n" + WordDNASystem.dna_to_string_representation(dna), "color": console_success_color}
        "evolve":
            # Implementation for evolving DNA
            return {"message": "DNA evolution not implemented yet", "color": console_warning_color}
        _:
            return {"message": "Unknown DNA subcommand: " + subcommand, "color": console_error_color}

func _cmd_player(args: Array) -> Dictionary:
    if not player_controller:
        return {"message": "Player controller not connected", "color": console_error_color}
    
    if args.size() == 0:
        return {"message": "Usage: /player <tp|mode|energy> [args]", "color": console_warning_color}
    
    var subcommand = args[0].to_lower()
    
    match subcommand:
        "tp":
            if args.size() < 4:
                return {"message": "Usage: /player tp <x> <y> <z>", "color": console_warning_color}
            
            var x = float(args[1])
            var y = float(args[2])
            var z = float(args[3])
            
            player_controller.teleport_to(Vector3(x, y, z))
            return {"message": "Teleported to " + str(Vector3(x, y, z)), "color": console_success_color}
        "mode":
            if args.size() < 2:
                return {"message": "Usage: /player mode <walking|running|flying|spectator>", "color": console_warning_color}
            
            var mode = args[1].to_upper()
            
            # This would need to match your player controller's mode constants
            player_controller.change_state(mode)
            return {"message": "Player mode set to " + mode, "color": console_success_color}
        "energy":
            # This would need to match your player controller's energy system
            return {"message": "Energy management not implemented yet", "color": console_warning_color}
        _:
            return {"message": "Unknown player subcommand: " + subcommand, "color": console_error_color}

func _cmd_system(args: Array) -> Dictionary:
    if args.size() == 0:
        return {"message": "Usage: /system <info|fps|memory>", "color": console_warning_color}
    
    var subcommand = args[0].to_lower()
    
    match subcommand:
        "info":
            var info = "System Information:\n"
            info += "Engine: Godot " + Engine.get_version_info().string + "\n"
            info += "FPS: " + str(Engine.get_frames_per_second()) + "\n"
            info += "OS: " + OS.get_name() + "\n"
            info += "Device: " + OS.get_model_name() + "\n"
            return {"message": info, "color": console_success_color}
        "fps":
            return {"message": "Current FPS: " + str(Engine.get_frames_per_second()), "color": console_success_color}
        "memory":
            var mem = OS.get_static_memory_usage() / 1024.0 / 1024.0
            return {"message": "Memory usage: " + str(mem) + " MB", "color": console_success_color}
        _:
            return {"message": "Unknown system subcommand: " + subcommand, "color": console_error_color}

# ----- CHEAT CODE IMPLEMENTATIONS -----
func _cheat_unlimited_energy():
    if player_controller:
        # Set unlimited energy
        # This would need to match your player controller's energy system
        return true
    return false

func _cheat_god_mode():
    if player_controller:
        # Enable god mode
        # This would need to match your player controller's implementation
        return true
    return false

func _cheat_spawn_words():
    if word_manifestor:
        # Spawn multiple words around the player
        var words = ["power", "creation", "infinite", "reality", "energy", "wisdom", 
                      "universe", "eternal", "divine", "cosmic", "being", "essence"]
        
        var spawn_pos = Vector3.ZERO
        if player_controller:
            spawn_pos = player_controller.global_position
        
        # Spawn words in a circle around the player
        for i in range(words.size()):
            var angle = (2 * PI / words.size()) * i
            var offset = Vector3(cos(angle) * 3, 1, sin(angle) * 3)
            var word_pos = spawn_pos + offset
            
            # Generate word ID
            var word_id = "cheat_" + words[i] + "_" + str(randi())
            
            # Add the word
            if word_manifestor.has_method("add_word"):
                word_manifestor.add_word(word_id, words[i], word_pos, "concept")
                
                # Connect to the previous word to create a circle
                if i > 0:
                    var prev_id = "cheat_" + words[i-1] + "_" + str(randi())
                    if word_manifestor.has_method("connect_words"):
                        word_manifestor.connect_words(word_id, prev_id)
                
                # Connect the last word to the first to complete the circle
                if i == words.size() - 1:
                    var first_id = "cheat_" + words[0] + "_" + str(randi())
                    if word_manifestor.has_method("connect_words"):
                        word_manifestor.connect_words(word_id, first_id)
        
        return true
    
    return false

func _cheat_noclip():
    if player_controller:
        # Enable noclip mode
        player_controller.enable_noclip(true)
        return true
    return false

func _cheat_reveal_connections():
    if word_manifestor:
        # Reveal all word connections
        # This would need to match your word system's implementation
        return true
    return false

# ----- PUBLIC API -----
func log(text: String, color: Color = console_text_color):
    add_console_line(text, color)

func log_error(text: String):
    add_console_line("ERROR: " + text, console_error_color)

func log_warning(text: String):
    add_console_line("WARNING: " + text, console_warning_color)

func log_success(text: String):
    add_console_line("SUCCESS: " + text, console_success_color)

func focus_input():
    if console_input:
        console_input.grab_focus()

func is_console_visible() -> bool:
    return console_visible

func get_command_history() -> Array:
    return command_history

func get_registered_commands() -> Dictionary:
    return registered_commands