# ==================================================
# UNIVERSAL BEING: InputFocusManager
# TYPE: Input System
# PURPOSE: Manage input focus between console and game to prevent conflicts
# COMPONENTS: Focus management, input routing, context switching
# SCENES: None (core system)
# ==================================================

extends UniversalBeing
class_name InputFocusManager

# ===== INPUT STATES =====
enum FocusState {
    GAME_FOCUSED,     # Game receives all input
    CONSOLE_FOCUSED,  # Console receives all input
    AI_CHANNEL,       # AI collaboration mode
    MIXED_MODE        # Special commands pass through
}

# ===== FOCUS MANAGEMENT =====
var current_focus: FocusState = FocusState.GAME_FOCUSED
var console_node: Node = null
var game_input_handlers: Array[Node] = []
var input_buffer: Array[InputEvent] = []
var focus_locked: bool = false

# ===== HOTKEYS =====
var console_toggle_key: int = KEY_QUOTELEFT  # ~ key
var ai_channel_key: int = KEY_F1
var escape_key: int = KEY_ESCAPE

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
    super.pentagon_init()
    
    being_type = "input_manager"
    being_name = "Input Focus Manager"
    consciousness_level = 3
    
    print("⌨️ InputFocusManager: Focus control initialized")

func pentagon_ready() -> void:
    super.pentagon_ready()
    
    # Find console node
    _find_console_node()
    
    # Register with scene tree to intercept input
    get_tree().set_input_as_handled()
    
    print("⌨️ InputFocusManager: Ready for input management")

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    
    # Process any buffered input events
    _process_input_buffer()

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    
    # This is our main input interception point
    _handle_input_routing(event)

func pentagon_sewers() -> void:
    print("⌨️ InputFocusManager: Cleaning up input management")
    input_buffer.clear()
    super.pentagon_sewers()

# ===== INPUT ROUTING =====

func _handle_input_routing(event: InputEvent) -> void:
    """Main input routing logic"""
    
    # Check for focus change hotkeys first
    if event is InputEventKey and event.pressed:
        if _handle_focus_hotkeys(event):
            return  # Hotkey consumed, don't process further
    
    # Route input based on current focus
    match current_focus:
        FocusState.GAME_FOCUSED:
            _route_to_game(event)
        
        FocusState.CONSOLE_FOCUSED:
            _route_to_console(event)
        
        FocusState.AI_CHANNEL:
            _route_to_ai_channel(event)
        
        FocusState.MIXED_MODE:
            _route_mixed_mode(event)

func _handle_focus_hotkeys(event: InputEventKey) -> bool:
    """Handle focus switching hotkeys"""
    match event.keycode:
        console_toggle_key:  # ~ key
            _toggle_console_focus()
            return true
        
        ai_channel_key:  # F1 key
            _toggle_ai_channel()
            return true
        
        escape_key:  # ESC key
            _handle_escape_key()
            return true
    
    return false

func _toggle_console_focus() -> void:
    """Toggle between game and console focus"""
    match current_focus:
        FocusState.GAME_FOCUSED:
            _set_focus(FocusState.CONSOLE_FOCUSED)
            print("⌨️ Focus: CONSOLE (~ to return to game)")
        
        FocusState.CONSOLE_FOCUSED:
            _set_focus(FocusState.GAME_FOCUSED)
            print("⌨️ Focus: GAME (~ to open console)")
        
        _:  # From other modes, return to game
            _set_focus(FocusState.GAME_FOCUSED)
            print("⌨️ Focus: GAME")

func _toggle_ai_channel() -> void:
    """Toggle AI collaboration channel"""
    if current_focus == FocusState.AI_CHANNEL:
        _set_focus(FocusState.GAME_FOCUSED)
        print("🤖 AI Channel: CLOSED")
    else:
        _set_focus(FocusState.AI_CHANNEL)
        print("🤖 AI Channel: OPEN - Gemma collaboration active!")

func _handle_escape_key() -> void:
    """ESC key always returns to game focus"""
    if current_focus != FocusState.GAME_FOCUSED:
        _set_focus(FocusState.GAME_FOCUSED)
        print("⌨️ Focus: GAME (ESC pressed)")

func _set_focus(new_focus: FocusState) -> void:
    """Change input focus state"""
    var old_focus = current_focus
    current_focus = new_focus
    
    # Notify console about focus changes
    if console_node and console_node.has_method("set_focus_state"):
        console_node.set_focus_state(current_focus == FocusState.CONSOLE_FOCUSED)
    
    # Emit signal for other systems
    if has_signal("focus_changed"):
        emit_signal("focus_changed", old_focus, new_focus)
    
    _update_visual_indicators()

# ===== INPUT ROUTING METHODS =====

func _route_to_game(event: InputEvent) -> void:
    """Route input to game systems"""
    # Let all game input handlers process the event
    for handler in game_input_handlers:
        if handler and handler.has_method("_input"):
            handler._input(event)
    
    # Don't consume the event - let it propagate normally

func _route_to_console(event: InputEvent) -> void:
    """Route input exclusively to console"""
    if console_node and console_node.has_method("handle_input"):
        console_node.handle_input(event)
    
    # Consume the event to prevent game from receiving it
    get_viewport().set_input_as_handled()

func _route_to_ai_channel(event: InputEvent) -> void:
    """Route input to AI collaboration system"""
    # Both console and AI system receive input
    if console_node and console_node.has_method("handle_ai_input"):
        console_node.handle_ai_input(event)
    
    # Also notify command processor
    var cmd_processor = _find_command_processor()
    if cmd_processor and cmd_processor.has_method("handle_ai_input"):
        cmd_processor.handle_ai_input(event)
    
    get_viewport().set_input_as_handled()

func _route_mixed_mode(event: InputEvent) -> void:
    """Route input to both systems with smart filtering"""
    # Special mode where some commands pass through
    var consumed = false
    
    # Console gets first chance
    if console_node and console_node.has_method("try_handle_input"):
        consumed = console_node.try_handle_input(event)
    
    # If console didn't consume it, pass to game
    if not consumed:
        _route_to_game(event)
    else:
        get_viewport().set_input_as_handled()

# ===== VISUAL FEEDBACK =====

func _update_visual_indicators() -> void:
    """Update visual indicators for current focus state"""
    match current_focus:
        FocusState.GAME_FOCUSED:
            _set_cursor_style("game")
        
        FocusState.CONSOLE_FOCUSED:
            _set_cursor_style("console")
        
        FocusState.AI_CHANNEL:
            _set_cursor_style("ai")
        
        FocusState.MIXED_MODE:
            _set_cursor_style("mixed")

func _set_cursor_style(style: String) -> void:
    """Set cursor visual style based on focus"""
    # Could change cursor, add overlay, etc.
    match style:
        "console":
            # Make cursor more prominent for console mode
            pass
        "ai":
            # Special AI collaboration cursor
            pass

# ===== NODE DISCOVERY =====

func _find_console_node() -> void:
    """Find the console node in the scene"""
    # Try to find console by various methods
    var potential_consoles = [
        get_node_or_null("/root/Console"),
        get_node_or_null("/root/ConsoleTextLayer"),
        _find_node_by_class("ConsoleTextLayerUniversalBeing")
    ]
    
    for potential in potential_consoles:
        if potential:
            console_node = potential
            print("⌨️ Found console node: %s" % console_node.name)
            break
    
    if not console_node:
        print("⚠️ Console node not found - some features may not work")

func _find_command_processor() -> Node:
    """Find the universal command processor"""
    return _find_node_by_class("UniversalCommandProcessor")

func _find_node_by_class(class_name: String) -> Node:
    """Find first node with specific class name"""
    return _search_tree_for_class(get_tree().root, class_name)

func _search_tree_for_class(node: Node, class_name: String) -> Node:
    """Recursively search tree for node with class name"""
    if node.get_script() and node.get_script().get_global_name() == class_name:
        return node
    
    for child in node.get_children():
        var result = _search_tree_for_class(child, class_name)
        if result:
            return result
    
    return null

# ===== INPUT BUFFER =====

func _process_input_buffer() -> void:
    """Process any buffered input events"""
    if input_buffer.is_empty():
        return
    
    var events_to_process = input_buffer.duplicate()
    input_buffer.clear()
    
    for event in events_to_process:
        _handle_input_routing(event)

func buffer_input(event: InputEvent) -> void:
    """Buffer input event for later processing"""
    input_buffer.append(event)

# ===== AI INTERFACE =====

signal focus_changed(old_focus: FocusState, new_focus: FocusState)

func ai_interface() -> Dictionary:
    """AI interface for input management"""
    var base = super.ai_interface()
    base.input_commands = [
        "set_focus",
        "toggle_console",
        "enable_ai_channel",
        "get_focus_state",
        "lock_input_to_console"
    ]
    base.current_focus = FocusState.keys()[current_focus]
    return base

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    """AI method invocation for input control"""
    match method_name:
        "set_focus":
            if args.size() > 0:
                var focus_name = args[0]
                for i in FocusState.size():
                    if FocusState.keys()[i] == focus_name:
                        _set_focus(i)
                        return "Focus set to: %s" % focus_name
                return "Invalid focus state: %s" % focus_name
        
        "toggle_console":
            _toggle_console_focus()
            return "Console focus toggled"
        
        "enable_ai_channel":
            _set_focus(FocusState.AI_CHANNEL)
            return "AI collaboration channel enabled"
        
        "get_focus_state":
            return FocusState.keys()[current_focus]
        
        "lock_input_to_console":
            focus_locked = true
            _set_focus(FocusState.CONSOLE_FOCUSED)
            return "Input locked to console"
        
        _:
            return await super.ai_invoke_method(method_name, args)

func _to_string() -> String:
    return "InputFocusManager<Focus:%s>" % FocusState.keys()[current_focus]