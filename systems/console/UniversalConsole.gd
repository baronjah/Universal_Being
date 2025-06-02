# ==================================================
# UNIVERSAL BEING: UniversalConsole
# TYPE: Console System
# PURPOSE: Complete in-game development environment and AI interface
# COMPONENTS: Command processing, live editing, macro system
# SCENES: console_interface.tscn
# ==================================================

extends UniversalBeing
class_name UniversalConsole

## Console UI Container
@onready var console_ui: Control = Control.new()

## Console components
@onready var output_area: RichTextLabel = RichTextLabel.new()
@onready var input_line: LineEdit = LineEdit.new()
@onready var suggestions_box: ItemList = ItemList.new()

## Systems
var command_processor: UniversalCommandProcessor
var macro_system: MacroSystem
var input_manager: Node  # Will be cast to InputFocusManager when available
var akashic_records: Node

## Console state
var command_history: Array[String] = []
var history_index: int = -1
var auto_complete_active: bool = false
var ai_channel_active: bool = false

signal console_opened()
signal console_closed()
signal reality_modified(what: String)
signal ai_message_received(message: String, sender: String)

func pentagon_init() -> void:
    super.pentagon_init()
    being_type = "console"
    being_name = "UniversalConsole"
    consciousness_level = 7  # Full consciousness for console
    
    # Setup console UI container
    console_ui.name = "ConsoleUI"
    console_ui.anchor_right = 1.0
    console_ui.anchor_bottom = 0.5
    console_ui.modulate = Color(1, 1, 1, 0.9)
    add_child(console_ui)

func pentagon_ready() -> void:
    super.pentagon_ready()
    _setup_ui()
    _connect_systems()
    _setup_input_handling()
    print_welcome()

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    if console_ui.visible and input_line.has_focus():
        _update_suggestions()

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    if event.is_action_pressed("toggle_console"):
        toggle()
    elif console_ui.visible:
        if event.is_action_pressed("ui_up"):
            navigate_history(-1)
        elif event.is_action_pressed("ui_down"):
            navigate_history(1)
        elif event.is_action_pressed("ui_text_completion_accept"):
            accept_suggestion()
        elif event.is_action_pressed("toggle_ai_channel"):
            toggle_ai_channel()

func pentagon_sewers() -> void:
    # Save console state
    if akashic_records:
        var state = {
            "command_history": command_history,
            "ai_channel_active": ai_channel_active
        }
        akashic_records.save_record("console_state", "system", state)
    super.pentagon_sewers()

func _setup_ui() -> void:
    """Create console UI"""
    var margin = MarginContainer.new()
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    margin.set("theme_override_constants/margin_left", 10)
    margin.set("theme_override_constants/margin_right", 10)
    margin.set("theme_override_constants/margin_top", 10)
    margin.set("theme_override_constants/margin_bottom", 10)
    console_ui.add_child(margin)
    
    var vbox = VBoxContainer.new()
    margin.add_child(vbox)
    
    # Output area
    output_area.bbcode_enabled = true
    output_area.scroll_following = true
    output_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
    output_area.add_theme_color_override("default_color", Color.GREEN)
    vbox.add_child(output_area)
    
    # Input line
    input_line.placeholder_text = "Enter command or 'help'..."
    input_line.text_submitted.connect(_on_command_entered)
    input_line.text_changed.connect(_on_text_changed)
    vbox.add_child(input_line)
    
    # Suggestions box (hidden by default)
    suggestions_box.visible = false
    suggestions_box.max_displayed_items = 5
    suggestions_box.item_selected.connect(_on_suggestion_selected)
    console_ui.add_child(suggestions_box)

func _connect_systems() -> void:
    """Connect to all subsystems"""
    # Command processor
    if has_node("/root/UniversalCommandProcessor"):
        command_processor = get_node("/root/UniversalCommandProcessor")
    
    # Macro system
    if has_node("/root/MacroSystem"):
        macro_system = get_node("/root/MacroSystem")
    
    # Input manager
    if has_node("/root/InputFocusManager"):
        input_manager = get_node("/root/InputFocusManager")
    
    # Find Akashic Records
    if has_node("/root/AkashicRecords"):
        akashic_records = get_node("/root/AkashicRecords")
        _load_console_state()

func _setup_input_handling() -> void:
    """Setup keyboard shortcuts"""
    set_process_unhandled_input(true)

func toggle() -> void:
    """Toggle console visibility"""
    console_ui.visible = not console_ui.visible
    if console_ui.visible:
        input_line.grab_focus()
        if input_manager:
            input_manager.set_console_focus(true)
        console_opened.emit()
    else:
        if input_manager:
            input_manager.set_console_focus(false)
        console_closed.emit()

func toggle_ai_channel() -> void:
    """Toggle AI communication channel"""
    ai_channel_active = not ai_channel_active
    if ai_channel_active:
        output_line("[color=purple]🤖 AI Channel Active - Ready for Gemma[/color]")
    else:
        output_line("[color=gray]AI Channel Closed[/color]")

func print_welcome() -> void:
    """Print welcome message"""
    output_line("[color=cyan]╔═══════════════════════════════════════╗[/color]")
    output_line("[color=cyan]║   UNIVERSAL CONSOLE - Reality OS      ║[/color]")
    output_line("[color=cyan]╚═══════════════════════════════════════╝[/color]")
    output_line("")
    output_line("Welcome to the Universe Simulator!")
    output_line("Type [color=yellow]help[/color] for commands")
    output_line("Type [color=yellow]tutorial[/color] to learn reality manipulation")
    output_line("Press [color=yellow]F2[/color] to toggle AI channel")
    output_line("")

func _on_command_entered(text: String) -> void:
    """Process entered command"""
    if text.strip_edges().is_empty():
        return
    
    # Add to history
    command_history.append(text)
    history_index = command_history.size()
    
    # Echo command with appropriate prefix
    if ai_channel_active:
        output_line("[color=purple][AI] > %s[/color]" % text)
    else:
        output_line("[color=gray]> %s[/color]" % text)
    
    # Special console commands
    if text.begins_with("/"):
        process_console_command(text.substr(1))
    else:
        # Process through command processor
        if command_processor:
            var result = command_processor.execute_command(text)
            if result != null and result != "":
                output_line(str(result))
    
    # Clear input
    input_line.clear()

func process_console_command(cmd: String) -> void:
    """Process console-specific commands"""
    var parts = cmd.split(" ", 2)
    var command = parts[0]
    var args = parts[1] if parts.size() > 1 else ""
    
    match command:
        "clear":
            output_area.clear()
        
        "save":
            save_session()
            output_line("Session saved to Akashic Records")
        
        "load":
            if args:
                load_session(args)
            else:
                output_line("Usage: /load <session_name>")
        
        "macro":
            process_macro_command(args)
        
        "edit":
            toggle_code_editor()
        
        "reload":
            reload_reality()
        
        "tutorial":
            show_tutorial()
        
        "ai":
            process_ai_command(args)
        
        _:
            output_line("Unknown console command: /%s" % command)

func process_ai_command(args: String) -> void:
    """Handle AI-specific commands"""
    var parts = args.split(" ", 2)
    if parts.is_empty():
        output_line("Usage: /ai <say|think|act> [message]")
        return
    
    var subcmd = parts[0]
    var message = parts[1] if parts.size() > 1 else ""
    
    match subcmd:
        "say":
            if message:
                ai_message_received.emit(message, "Gemma")
                output_line("[color=purple][Gemma] %s[/color]" % message)
            else:
                output_line("Usage: /ai say <message>")
        
        "think":
            if message:
                output_line("[color=purple][Gemma Thinking] %s[/color]" % message)
            else:
                output_line("Usage: /ai think <thought>")
        
        "act":
            if message:
                if command_processor:
                    var result = command_processor.execute_command(message)
                    output_line("[color=purple][Gemma Action] %s[/color]" % str(result))
            else:
                output_line("Usage: /ai act <command>")

func process_macro_command(args: String) -> void:
    """Handle macro subcommands"""
    var parts = args.split(" ", 2)
    if parts.is_empty():
        output_line("Usage: /macro <record|stop|play|list> [args]")
        return
    
    var subcmd = parts[0]
    var macro_args = parts[1] if parts.size() > 1 else ""
    
    if not macro_system:
        output_line("Macro system not available")
        return
    
    match subcmd:
        "record":
            if macro_args:
                macro_system.start_recording(macro_args)
                output_line("🔴 Recording macro: %s" % macro_args)
            else:
                output_line("Usage: /macro record <name>")
        
        "stop":
            if macro_system.stop_recording():
                output_line("⏹️ Macro recording stopped")
            else:
                output_line("No macro recording in progress")
        
        "play":
            if macro_args:
                macro_system.play_macro(macro_args)
                output_line("▶️ Playing macro: %s" % macro_args)
            else:
                output_line("Usage: /macro play <name>")
        
        "list":
            var macros = macro_system.list_macros()
            output_line("Available macros:")
            for macro in macros:
                var info = macro_system.get_macro_info(macro)
                output_line("  • %s - %d commands" % [macro, info.command_count])

func show_tutorial() -> void:
    """Show interactive tutorial"""
    output_line("\
[color=yellow]🎓 REALITY MANIPULATION TUTORIAL[/color]\
")
    
    output_line("1. [color=cyan]Basic Commands:[/color]")
    output_line("   inspect <target> - Examine anything")
    output_line("   create being <name> - Create a new being")
    output_line("   load script <path> - Load GDScript")
    output_line("")
    
    output_line("2. [color=cyan]Natural Language Triggers:[/color]")
    output_line("   create trigger <word> <action>")
    output_line("   Example: create trigger potato open_doors")
    output_line("   Then say 'potato' near a door!")
    output_line("")
    
    output_line("3. [color=cyan]Reality Modification:[/color]")
    output_line("   reality gravity <value> - Change gravity")
    output_line("   reality time <scale> - Alter time flow")
    output_line("   execute <code> - Run GDScript directly")
    output_line("")
    
    output_line("4. [color=cyan]Macro System:[/color]")
    output_line("   /macro record <name> - Start recording")
    output_line("   /macro stop - Stop recording")
    output_line("   /macro play <name> - Replay commands")
    output_line("")
    
    output_line("5. [color=cyan]AI Integration:[/color]")
    output_line("   Press F2 to toggle AI channel")
    output_line("   /ai say <message> - Talk as Gemma")
    output_line("   /ai think <thought> - Show AI thoughts")
    output_line("   /ai act <command> - Execute as AI")
    output_line("")
    
    output_line("Try: [color=green]create being TestSubject[/color]")

func reload_reality() -> void:
    """Hot reload the entire game while running"""
    output_line("🔄 Reloading reality...")
    
    # Save current state
    var state = capture_reality_state()
    
    # Reload all scripts
    var scripts_reloaded = 0
    for node in get_tree().get_nodes_in_group("universal_beings"):
        if node.get_script():
            var script_path = node.get_script().resource_path
            if script_path:
                node.set_script(load(script_path))
                scripts_reloaded += 1
    
    # Restore state
    restore_reality_state(state)
    
    output_line("✅ Reality reloaded! (%d scripts)" % scripts_reloaded)
    reality_modified.emit("reload")

func capture_reality_state() -> Dictionary:
    """Capture current state of reality"""
    var state = {
        "beings": [],
        "gravity": ProjectSettings.get_setting("physics/2d/default_gravity"),
        "time_scale": Engine.time_scale,
        "triggers": command_processor.natural_triggers.duplicate() if command_processor else {}
    }
    
    # Capture all beings
    for being in get_tree().get_nodes_in_group("universal_beings"):
        state.beings.append({
            "name": being.being_name,
            "type": being.being_type,
            "consciousness": being.consciousness_level,
            "position": being.position if being is Node2D else Vector2.ZERO
        })
    
    return state

func restore_reality_state(state: Dictionary) -> void:
    """Restore reality to saved state"""
    # Restore physics
    ProjectSettings.set_setting("physics/2d/default_gravity", state.gravity)
    Engine.time_scale = state.time_scale
    
    # Restore triggers
    if command_processor:
        command_processor.natural_triggers = state.triggers

func save_session() -> void:
    """Save console session to Akashic Records"""
    if akashic_records:
        var session_data = {
            "timestamp": Time.get_unix_time_from_system(),
            "commands": command_history,
            "reality_state": capture_reality_state()
        }
        akashic_records.save_record("console_session", "system", session_data)

func load_session(name: String) -> void:
    """Load session from Akashic Records"""
    if akashic_records:
        var data = akashic_records.load_record("console_session", name)
        if data:
            restore_reality_state(data.reality_state)
            output_line("Session loaded: %s" % name)

func _load_console_state() -> void:
    """Load saved console state"""
    if akashic_records:
        var state = akashic_records.load_record("console_state", "system")
        if state:
            command_history = state.get("command_history", [])
            ai_channel_active = state.get("ai_channel_active", false)

func output_line(text: String) -> void:
    """Output formatted text to console"""
    output_area.append_bbcode(text + "\n")

func navigate_history(direction: int) -> void:
    """Navigate command history"""
    if command_history.is_empty():
        return
    
    history_index = clamp(history_index + direction, 0, command_history.size())
    
    if history_index < command_history.size():
        input_line.text = command_history[history_index]
        input_line.caret_column = input_line.text.length()
    else:
        input_line.clear()

func _update_suggestions() -> void:
    """Update command suggestions"""
    var text = input_line.text
    if text.length() < 2:
        suggestions_box.visible = false
        return
    
    var suggestions = get_suggestions(text)
    if suggestions.is_empty():
        suggestions_box.visible = false
        return
    
    suggestions_box.clear()
    for suggestion in suggestions:
        suggestions_box.add_item(suggestion)
    
    suggestions_box.visible = true
    position_suggestions_box()

func get_suggestions(partial: String) -> Array[String]:
    """Get command suggestions"""
    var suggestions: Array[String] = []
    
    # Check command registry
    if command_processor:
        for cmd in command_processor.command_registry:
            if cmd.begins_with(partial):
                suggestions.append(cmd)
    
    # Check macro names
    if macro_system:
        for macro in macro_system.list_macros():
            if macro.begins_with(partial):
                suggestions.append("macro play " + macro)
    
    # Add AI commands if in AI channel
    if ai_channel_active:
        suggestions.append("ai say")
        suggestions.append("ai think")
        suggestions.append("ai act")
    
    return suggestions.slice(0, 5) # Limit to 5

func position_suggestions_box() -> void:
    """Position suggestions below input"""
    var input_pos = input_line.global_position
    suggestions_box.position = Vector2(input_pos.x, input_pos.y - 100)
    suggestions_box.size = Vector2(input_line.size.x, 100)

func _on_suggestion_selected(index: int) -> void:
    """Apply selected suggestion"""
    var suggestion = suggestions_box.get_item_text(index)
    input_line.text = suggestion
    input_line.caret_column = suggestion.length()
    suggestions_box.visible = false
    input_line.grab_focus()

func accept_suggestion() -> void:
    """Accept first suggestion"""
    if suggestions_box.visible and suggestions_box.item_count > 0:
        _on_suggestion_selected(0)

## AI Interface Methods
func ai_print(text: String) -> void:
    """Allow AI to print to console"""
    output_line("[color=purple][AI] %s[/color]" % text)

func ai_execute(command: String) -> Variant:
    """Allow AI to execute commands"""
    output_line("[color=purple][AI] > %s[/color]" % command)
    if command_processor:
        return command_processor.execute_command(command)
    return null

func ai_query_state(query: String) -> Variant:
    """Allow AI to query game state"""
    match query:
        "beings":
            return get_tree().get_nodes_in_group("universal_beings")
        "reality":
            return capture_reality_state()
        "macros":
            if macro_system:
                return macro_system.list_macros()
        _:
            return null
    return null

func _on_text_changed(new_text: String) -> void:
    """Handle text changes for suggestions"""
    _update_suggestions()

func toggle_code_editor() -> void:
    """Toggle the live code editor interface"""
    output_line("[color=yellow]📝 Live Code Editor[/color]")
    output_line("This feature is coming soon!")
    output_line("You will be able to edit Universal Beings in real-time")
    output_line("Type [color=green]help editor[/color] when it's ready") 