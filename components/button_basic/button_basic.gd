# ==================================================
# UNIVERSAL BEING: ButtonBasic
# TYPE: UI Component
# PURPOSE: Basic button with standard UI interactions
# COMPONENTS: None (base component)
# SCENES: button_basic.tscn
# ==================================================

extends UniversalBeing
class_name ButtonBasicUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var button_text: String = "Click Me"
@export var normal_color: Color = Color(0.2, 0.2, 0.2, 1.0)
@export var hover_color: Color = Color(0.3, 0.3, 0.3, 1.0)
@export var pressed_color: Color = Color(0.4, 0.4, 0.4, 1.0)
@export var disabled_color: Color = Color(0.1, 0.1, 0.1, 0.5)

# ===== INTERNAL STATE =====
var _button_node: Button = null
var _is_hovered: bool = false
var _is_pressed: bool = false
var _is_disabled: bool = false

# ===== SIGNALS =====
signal button_pressed()
signal button_released()
signal button_hover_started()
signal button_hover_ended()

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
    super.pentagon_init()
    
    # Set Universal Being identity
    being_type = "ui_component"
    being_name = "ButtonBasic"
    consciousness_level = 2  # AI accessible but not highly conscious
    
    print("🔘 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
    super.pentagon_ready()
    
    # Load button scene
    load_scene("res://components/button_basic/button_basic.tscn")
    
    # Get button node
    _button_node = get_scene_node("Button")
    if _button_node:
        _setup_button()
    else:
        push_error("Button node not found in scene")
    
    print("🔘 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    
    # Update button state
    if _button_node:
        _update_button_state()

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    
    if not _button_node or _is_disabled:
        return
    
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT:
            if event.pressed:
                _handle_button_press()
            else:
                _handle_button_release()
    
    elif event is InputEventMouseMotion:
        var is_hovering = _button_node.get_global_rect().has_point(event.position)
        if is_hovering != _is_hovered:
            _is_hovered = is_hovering
            if _is_hovered:
                _handle_hover_start()
            else:
                _handle_hover_end()

func pentagon_sewers() -> void:
    # Cleanup button resources
    if _button_node:
        _button_node.queue_free()
        _button_node = null
    
    super.pentagon_sewers()
    print("🔘 %s: Pentagon Sewers Complete" % being_name)

# ===== BUTTON SETUP =====

func _setup_button() -> void:
    """Initialize button properties and connections"""
    _button_node.text = button_text
    
    # Set initial colors
    _update_button_colors()
    
    # Connect button signals
    _button_node.pressed.connect(_on_button_pressed)
    _button_node.button_up.connect(_on_button_released)
    _button_node.mouse_entered.connect(_on_mouse_entered)
    _button_node.mouse_exited.connect(_on_mouse_exited)

func _update_button_state() -> void:
    """Update button visual state"""
    if not _button_node:
        return
    
    _button_node.disabled = _is_disabled
    _update_button_colors()

func _update_button_colors() -> void:
    """Update button colors based on state"""
    if not _button_node:
        return
    
    var target_color = normal_color
    if _is_disabled:
        target_color = disabled_color
    elif _is_pressed:
        target_color = pressed_color
    elif _is_hovered:
        target_color = hover_color
    
    # Apply color to button
    _button_node.modulate = target_color

# ===== EVENT HANDLERS =====

func _handle_button_press() -> void:
    """Handle button press event"""
    if not _is_disabled:
        _is_pressed = true
        _update_button_state()
        button_pressed.emit()

func _handle_button_release() -> void:
    """Handle button release event"""
    if _is_pressed:
        _is_pressed = false
        _update_button_state()
        button_released.emit()

func _handle_hover_start() -> void:
    """Handle hover start event"""
    if not _is_disabled:
        _update_button_state()
        button_hover_started.emit()

func _handle_hover_end() -> void:
    """Handle hover end event"""
    if not _is_disabled:
        _update_button_state()
        button_hover_ended.emit()

# ===== SIGNAL HANDLERS =====

func _on_button_pressed() -> void:
    """Button pressed signal handler"""
    _handle_button_press()

func _on_button_released() -> void:
    """Button released signal handler"""
    _handle_button_release()

func _on_mouse_entered() -> void:
    """Mouse entered signal handler"""
    _is_hovered = true
    _handle_hover_start()

func _on_mouse_exited() -> void:
    """Mouse exited signal handler"""
    _is_hovered = false
    _handle_hover_end()

# ===== PUBLIC INTERFACE =====

func set_text(new_text: String) -> void:
    """Set button text"""
    button_text = new_text
    if _button_node:
        _button_node.text = new_text

func set_disabled(disabled: bool) -> void:
    """Set button disabled state"""
    _is_disabled = disabled
    _update_button_state()

func set_colors(normal: Color, hover: Color, pressed: Color, disabled: Color = Color(0.1, 0.1, 0.1, 0.5)) -> void:
    """Set button colors"""
    normal_color = normal
    hover_color = hover
    pressed_color = pressed
    disabled_color = disabled
    _update_button_colors()

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
    """Enhanced AI interface for button being"""
    var base_interface = super.ai_interface()
    base_interface.custom_commands = [
        "set_text",
        "set_disabled",
        "set_colors",
        "simulate_click"
    ]
    base_interface.custom_properties = {
        "button_text": button_text,
        "is_disabled": _is_disabled,
        "is_hovered": _is_hovered,
        "is_pressed": _is_pressed,
        "colors": {
            "normal": normal_color,
            "hover": hover_color,
            "pressed": pressed_color,
            "disabled": disabled_color
        }
    }
    return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
    """Handle AI method calls"""
    match method_name:
        "set_text":
            if args.size() > 0:
                set_text(str(args[0]))
                return true
        "set_disabled":
            if args.size() > 0:
                set_disabled(bool(args[0]))
                return true
        "set_colors":
            if args.size() >= 3:
                var disabled = args[3] if args.size() > 3 else Color(0.1, 0.1, 0.1, 0.5)
                set_colors(args[0], args[1], args[2], disabled)
                return true
        "simulate_click":
            _handle_button_press()
            await get_tree().create_timer(0.1).timeout
            _handle_button_release()
            return true
        _:
            return super.ai_invoke_method(method_name, args)
    
    return false 