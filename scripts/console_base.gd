# ==================================================
# UNIVERSAL BEING: ConsoleBase
# TYPE: Console
# PURPOSE: Base class for console functionality
# COMPONENTS: None (base console component)
# SCENES: None (base class only)
# ==================================================

extends UniversalBeing
class_name ConsoleBaseUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var console_name: String = "Universal Console"
@export var console_color: Color = Color(0.2, 0.8, 1.0)
@export var max_history: int = 100

# Console state
var command_history: Array[String] = []
var output_buffer: Array[String] = []
var is_processing: bool = false

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
    super.pentagon_init()
    
    # Set Universal Being identity
    being_type = "console_base"
    being_name = console_name
    consciousness_level = 2  # Medium consciousness for console management
    
    print("🌟 %s: Console Base Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()
    
    # Initialize console UI
    setup_console_ui()
    
    print("🌟 %s: Console Base Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    
    # Process any pending commands
    if not is_processing and command_history.size() > 0:
        var command = command_history.pop_front()
        process_console_command(command)

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    
    # Handle console input
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ENTER:
            submit_current_command()
        elif event.keycode == KEY_UP:
            cycle_command_history(-1)
        elif event.keycode == KEY_DOWN:
            cycle_command_history(1)

func pentagon_sewers() -> void:
    # Cleanup console state
    command_history.clear()
    output_buffer.clear()
    
    super.pentagon_sewers()

# ===== CONSOLE BASE METHODS =====

func terminal_output(text: String) -> void:
    """Output text to the console"""
    output_buffer.append(text)
    if output_buffer.size() > max_history:
        output_buffer.pop_front()
    
    # Update UI if it exists
    update_console_output()

func process_console_command(command: String) -> void:
    """Process a console command"""
    if command.is_empty():
        return
    
    # Add to history
    command_history.append(command)
    if command_history.size() > max_history:
        command_history.pop_front()
    
    # Process the command
    is_processing = true
    var result = execute_command(command)
    is_processing = false
    
    # Log result
    if result:
        terminal_output("> " + command)
        terminal_output(result)

func execute_command(command: String) -> String:
    """Execute a console command and return result"""
    # Base implementation - override in subclasses
    return "Command not implemented: " + command

func submit_current_command() -> void:
    """Submit the current command for processing"""
    var input_node = get_node_or_null("ConsoleUI/CommandInput")
    if input_node and input_node is LineEdit:
        var command = input_node.text.strip_edges()
        if not command.is_empty():
            process_console_command(command)
            input_node.text = ""

func cycle_command_history(direction: int) -> void:
    """Cycle through command history"""
    var input_node = get_node_or_null("ConsoleUI/CommandInput")
    if input_node and input_node is LineEdit:
        # TODO: Implement command history cycling
        pass

# ===== CONSOLE UI METHODS =====

func setup_console_ui() -> void:
    """Setup the console UI"""
    # Create UI container
    var ui = Control.new()
    ui.name = "ConsoleUI"
    ui.anchor_right = 1.0
    ui.anchor_bottom = 1.0
    ui.grow_horizontal = Control.GROW_DIRECTION_BOTH
    ui.grow_vertical = Control.GROW_DIRECTION_BOTH
    add_child(ui)
    
    # Create output display
    var output = RichTextLabel.new()
    output.name = "OutputDisplay"
    output.anchor_right = 1.0
    output.anchor_bottom = 1.0
    output.offset_bottom = -40  # Leave space for input
    output.grow_horizontal = Control.GROW_DIRECTION_BOTH
    output.grow_vertical = Control.GROW_DIRECTION_BOTH
    output.bbcode_enabled = true
    output.scroll_following = true
    output.fit_content = true
    ui.add_child(output)
    
    # Create command input
    var input = LineEdit.new()
    input.name = "CommandInput"
    input.anchor_top = 1.0
    input.anchor_bottom = 1.0
    input.offset_top = -40
    input.offset_bottom = 0
    input.anchor_right = 1.0
    input.grow_horizontal = Control.GROW_DIRECTION_BOTH
    input.placeholder_text = "Enter command..."
    ui.add_child(input)

func update_console_output() -> void:
    """Update the console output display"""
    var output_node = get_node_or_null("ConsoleUI/OutputDisplay")
    if output_node and output_node is RichTextLabel:
        var text = ""
        for line in output_buffer:
            text += line + "\n"
        output_node.text = text

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	pass
    var base_interface = super.ai_interface()
    base_interface.console_commands = ["execute", "clear", "history"]
    base_interface.console_properties = {
        "name": console_name,
        "history_size": command_history.size(),
        "output_size": output_buffer.size()
    }
    return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    match method_name:
        "execute":
            if args.size() > 0:
                return execute_command(args[0])
            return "No command provided"
        "clear":
            output_buffer.clear()
            update_console_output()
            return true
        "history":
            return command_history
        _:
            return super.ai_invoke_method(method_name, args) 