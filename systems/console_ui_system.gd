extends Node

# Console settings
@export var command_history_size: int = 100
@export var auto_complete_enabled: bool = true
@export var gemma_response_delay: float = 0.5

# Console state
var command_history: Array[String] = []
var current_command_index: int = -1
var is_console_visible: bool = false
var gemma_thinking: bool = false

# Available commands
var commands: Dictionary = {
    "help": "Show available commands",
    "create": "Create a new Universal Being",
    "modify": "Modify the selected being",
    "list": "List all Universal Beings",
    "inspect": "Inspect a being's properties",
    "evolve": "Evolve a being to a new form",
    "clear": "Clear the console",
    "exit": "Close the console"
}

# Signals
signal output_received(text: String)
signal console_toggled(visible: bool)

func _ready() -> void:
    # Connect to parent UniversalBeing
    var parent = get_parent()
    if parent and parent.has_method("pentagon_ready"):
        parent.pentagon_ready.connect(_on_parent_ready)
    
    # Connect to input field
    var input_field = get_node_or_null("../ConsoleContainer/InputContainer/InputField")
    if input_field:
        input_field.text_submitted.connect(_on_input_submitted)

func _input(event: InputEvent) -> void:
    # Toggle console with backtick
    if event.is_action_pressed("ui_cancel"):  # Escape key
        _toggle_console()
    
    # Handle command history
    if is_console_visible:
        if event.is_action_pressed("ui_up"):
            _navigate_history(-1)
        elif event.is_action_pressed("ui_down"):
            _navigate_history(1)

func _on_parent_ready() -> void:
    # Initialize console with parent's consciousness
    var parent = get_parent()
    if parent and parent.has_method("get_consciousness_level"):
        var consciousness = parent.get_consciousness_level()
        if consciousness >= 3:
            auto_complete_enabled = true
            gemma_response_delay = max(0.1, 0.5 - (consciousness - 3) * 0.1)

func _on_input_submitted(text: String) -> void:
    if text.strip_edges().is_empty():
        return
    
    # Add to history
    command_history.append(text)
    if command_history.size() > command_history_size:
        command_history.pop_front()
    current_command_index = -1
    
    # Process command asynchronously
    _process_command_async(text)
    
    # Clear input
    var input_field = get_node_or_null("../ConsoleContainer/InputContainer/InputField")
    if input_field:
        input_field.text = ""

func _process_command_async(command: String) -> void:
    var response = await _process_command(command)
    emit_signal("output_received", "\n> " + command + "\n" + response)

func _process_command(command: String) -> String:
    var parts = command.split(" ", false)
    var cmd = parts[0].to_lower()
    var args = parts.slice(1)
    
    # Handle special commands
    match cmd:
        "help":
            return _show_help()
        "create":
            return _handle_create(args)
        "modify":
            return _handle_modify(args)
        "list":
            return _handle_list()
        "inspect":
            return _handle_inspect(args)
        "evolve":
            return _handle_evolve(args)
        "clear":
            return _handle_clear()
        "exit":
            _toggle_console()
            return "Console closed"
        _:
            # Let Gemma handle unknown commands
            return await _ask_gemma(command)

func _show_help() -> String:
    var help_text = "Available commands:\n"
    for cmd in commands:
        help_text += "  " + cmd + " - " + commands[cmd] + "\n"
    return help_text

func _handle_create(args: Array) -> String:
    if args.is_empty():
        return "Usage: create [type] [name]"
    
    var type = args[0]
    var name = args[1] if args.size() > 1 else "New Being"
    
    # Create being through wand system
    var wand = get_node_or_null("/root/UniversalBeing/CreationWand")
    if wand and wand.has_method("_create_universal_being"):
        var being = wand._create_universal_being()
        being.being_type = type
        being.being_name = name
        return "Created " + name + " of type " + type
    return "Creation failed"

func _handle_modify(args: Array) -> String:
    if args.is_empty():
        return "Usage: modify [property] [value]"
    
    var wand = get_node_or_null("/root/UniversalBeing/CreationWand")
    if wand and wand.has_method("_modify_current_being"):
        wand._modify_current_being()
        return "Modified current being"
    return "Modification failed"

func _handle_list() -> String:
    var beings = get_tree().get_nodes_in_group("universal_beings")
    var list = "Universal Beings:\n"
    for being in beings:
        if being.has_method("get_being_name"):
            list += "  " + being.get_being_name() + " (" + being.being_type + ")\n"
    return list

func _handle_inspect(args: Array) -> String:
    if args.is_empty():
        return "Usage: inspect [name]"
    
    var name = args[0]
    var beings = get_tree().get_nodes_in_group("universal_beings")
    for being in beings:
        if being.has_method("get_being_name") and being.get_being_name() == name:
            return _get_being_info(being)
    return "Being not found"

func _handle_evolve(args: Array) -> String:
    if args.is_empty():
        return "Usage: evolve [name] [target_type]"
    
    var name = args[0]
    var target_type = args[1] if args.size() > 1 else "evolved"
    
    var beings = get_tree().get_nodes_in_group("universal_beings")
    for being in beings:
        if being.has_method("get_being_name") and being.get_being_name() == name:
            if being.has_method("evolve_to"):
                being.evolve_to(target_type)
                return name + " evolved to " + target_type
    return "Evolution failed"

func _handle_clear() -> String:
    var output = get_node_or_null("../ConsoleContainer/OutputPanel/OutputScroll/OutputText")
    if output:
        output.text = ""
    return "Console cleared"

func _ask_gemma(command: String) -> String:
    if gemma_thinking:
        return "Gemma is still thinking..."
    
    gemma_thinking = true
    await get_tree().create_timer(gemma_response_delay).timeout
    gemma_thinking = false
    
    # Get Gemma's response
    var gemma = get_node_or_null("/root/UniversalBeing/GemmaSensory")
    if gemma and gemma.has_method("process_command"):
        return await gemma.process_command(command)
    return "Gemma is not available"

func _get_being_info(being: Node) -> String:
    var info = being.get_being_name() + " (" + being.being_type + ")\n"
    info += "  Consciousness: " + str(being.consciousness_level) + "\n"
    info += "  Position: " + str(being.global_position) + "\n"
    info += "  Scale: " + str(being.scale) + "\n"
    return info

func _toggle_console() -> void:
    is_console_visible = !is_console_visible
    emit_signal("console_toggled", is_console_visible)
    
    # Update input field focus
    var input_field = get_node_or_null("../ConsoleContainer/InputContainer/InputField")
    if input_field:
        if is_console_visible:
            input_field.grab_focus()
        else:
            input_field.release_focus()

func _navigate_history(direction: int) -> void:
    if command_history.is_empty():
        return
    
    current_command_index = clamp(current_command_index + direction, -1, command_history.size() - 1)
    
    var input_field = get_node_or_null("../ConsoleContainer/InputContainer/InputField")
    if input_field:
        if current_command_index == -1:
            input_field.text = ""
        else:
            input_field.text = command_history[command_history.size() - 1 - current_command_index]
            input_field.caret_column = input_field.text.length() 