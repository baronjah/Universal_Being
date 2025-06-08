extends Control

class_name TimeTrackingUI

# ----- UI REFERENCES -----
@onready var time_label: Label = $TimeLabel
@onready var symbol_label: Label = $SymbolContainer/SymbolLabel
@onready var mode_label: Label = $ModeLabel
@onready var turn_label: Label = $TurnLabel
@onready var background_panel: Panel = $BackgroundPanel
@onready var symbol_container: Control = $SymbolContainer
@onready var symbol_layers: Control = $SymbolContainer/SymbolLayers
@onready var layer1: Panel = $SymbolContainer/SymbolLayers/Layer1
@onready var layer2: Panel = $SymbolContainer/SymbolLayers/Layer2
@onready var layer3: Panel = $SymbolContainer/SymbolLayers/Layer3

# ----- SYSTEM REFERENCES -----
var time_tracker: Node = null
var visual_system: Node = null
var turn_system: Node = null

# ----- UI SETTINGS -----
@export_category("UI Settings")
@export var update_interval: float = 0.1  # How often to update UI in seconds
@export var compact_mode: bool = false
@export var show_turn_info: bool = true
@export var show_mode_info: bool = true
@export var auto_hide: bool = false
@export var auto_hide_delay: float = 5.0  # Seconds before UI hides

# ----- ANIMATION SETTINGS -----
@export_category("Animation Settings")
@export var use_animations: bool = true
@export var symbol_rotation_speed: float = 10.0  # Degrees per second
@export var scale_pulse_speed: float = 2.0
@export var pulse_min_scale: float = 0.9
@export var pulse_max_scale: float = 1.1

# ----- INTERNAL VARIABLES -----
var update_timer: Timer
var auto_hide_timer: Timer
var pulse_dir: int = 1  # 1 for increasing, -1 for decreasing
var current_pulse_scale: float = 1.0
var is_hidden: bool = false

# ----- INITIALIZATION -----
func _ready():
    # Set up timers
    _setup_timers()
    
    # Find required systems
    _find_systems()
    
    # Connect signals from visual system if found
    if visual_system:
        visual_system.connect("mode_changed", _on_mode_changed)
        visual_system.connect("blink_occurred", _on_blink_occurred)
        visual_system.connect("layer_changed", _on_layer_changed)
        visual_system.connect("symbol_changed", _on_symbol_changed)
        visual_system.connect("color_updated", _on_color_updated)
    
    # Apply initial UI state
    _update_ui_all()
    
    # Set initial symbol
    if visual_system:
        symbol_label.text = visual_system.get_current_symbol()
    else:
        symbol_label.text = "#"
    
    print("Time Tracking UI initialized")

func _setup_timers():
    # Update timer for regular UI updates
    update_timer = Timer.new()
    update_timer.wait_time = update_interval
    update_timer.one_shot = false
    update_timer.autostart = true
    update_timer.connect("timeout", _on_update_timer_timeout)
    add_child(update_timer)
    
    # Auto-hide timer
    auto_hide_timer = Timer.new()
    auto_hide_timer.wait_time = auto_hide_delay
    auto_hide_timer.one_shot = true
    auto_hide_timer.autostart = false
    auto_hide_timer.connect("timeout", _on_auto_hide_timer_timeout)
    add_child(auto_hide_timer)

func _find_systems():
    # Find visual indicator system
    var potential_visuals = get_tree().get_nodes_in_group("visual_indicators")
    if potential_visuals.size() > 0:
        visual_system = potential_visuals[0]
        print("Found visual system: " + visual_system.name)
    else:
        visual_system = _find_node_by_class(get_tree().root, "VisualIndicatorSystem")
        if visual_system:
            print("Found visual system by class: " + visual_system.name)
    
    # Find time tracker
    var potential_trackers = get_tree().get_nodes_in_group("time_trackers")
    if potential_trackers.size() > 0:
        time_tracker = potential_trackers[0]
        print("Found time tracker: " + time_tracker.name)
    else:
        time_tracker = _find_node_by_class(get_tree().root, "UsageTimeTracker")
        if time_tracker:
            print("Found time tracker by class: " + time_tracker.name)
    
    # Find turn system
    var potential_turns = get_tree().get_nodes_in_group("turn_systems")
    if potential_turns.size() > 0:
        turn_system = potential_turns[0]
        print("Found turn system: " + turn_system.name)
    else:
        # Try to find by class name - try multiple possible classes
        turn_system = _find_node_by_class(get_tree().root, "TurnSystem")
        if not turn_system:
            turn_system = _find_node_by_class(get_tree().root, "TurnCycleController")
        
        if turn_system:
            print("Found turn system by class: " + turn_system.name)

func _find_node_by_class(node, class_name):
    if node.get_class() == class_name:
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name)
        if found:
            return found
    
    return null

# ----- PROCESS -----
func _process(delta):
    if not visible or is_hidden:
        return
    
    if use_animations:
        _update_animations(delta)

func _update_animations(delta):
    # Rotate symbol
    if symbol_container:
        symbol_container.rotation_degrees += symbol_rotation_speed * delta
        
    # Pulse scaling
    current_pulse_scale += scale_pulse_speed * delta * pulse_dir
    if current_pulse_scale > pulse_max_scale:
        current_pulse_scale = pulse_max_scale
        pulse_dir = -1
    elif current_pulse_scale < pulse_min_scale:
        current_pulse_scale = pulse_min_scale
        pulse_dir = 1
    
    symbol_label.scale = Vector2(current_pulse_scale, current_pulse_scale)

# ----- UI UPDATES -----
func _update_ui_all():
    _update_time_display()
    _update_turn_display()
    _update_mode_display()
    _update_layers_display()
    
    # Reset auto-hide timer if auto-hide is enabled
    if auto_hide:
        auto_hide_timer.start(auto_hide_delay)

func _update_time_display():
    if not time_tracker:
        time_label.text = "00:00:00"
        return
    
    var usage_info = time_tracker.get_usage_summary()
    time_label.text = usage_info.formatted_total_time
    
    # Check if over limit and update style
    if usage_info.over_limit:
        time_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
    else:
        time_label.remove_theme_color_override("font_color")

func _update_turn_display():
    if not turn_system or not show_turn_info:
        turn_label.visible = false
        return
    
    turn_label.visible = true
    var current_turn = 0
    
    # Try to get current turn
    if turn_system.has_method("get_current_turn"):
        current_turn = turn_system.get_current_turn()
    elif "current_turn" in turn_system:
        current_turn = turn_system.current_turn
    
    # Try to get phase name if available
    var phase_name = ""
    if turn_system.has_method("get_current_phase_name"):
        phase_name = turn_system.get_current_phase_name()
    
    if phase_name:
        turn_label.text = "Turn: " + str(current_turn) + " - " + phase_name
    else:
        turn_label.text = "Turn: " + str(current_turn)

func _update_mode_display():
    if not visual_system or not show_mode_info:
        mode_label.visible = false
        return
    
    mode_label.visible = true
    mode_label.text = "Mode: " + visual_system.get_current_mode_name()

func _update_layers_display():
    if not visual_system:
        return
    
    var visual_state = visual_system.get_visual_state()
    
    # Update symbol
    symbol_label.text = visual_state.symbol
    
    # Update colors based on mode
    background_panel.modulate = visual_state.color.darkened(0.7)
    
    # Update layers based on mode
    var mode = visual_state.mode
    var layer_count = 1
    
    match mode:
        0: # Minimal
            layer_count = 1
        1: # Standard
            layer_count = 2
        2, 3: # Detailed or Symbolic
            layer_count = 3
    
    # Show only the needed layers
    layer1.visible = layer_count >= 1
    layer2.visible = layer_count >= 2
    layer3.visible = layer_count >= 3
    
    # Update layer colors
    if layer1.visible:
        layer1.modulate = visual_state.color.lightened(0.2)
    if layer2.visible:
        layer2.modulate = visual_state.color.darkened(0.2)
    if layer3.visible:
        layer3.modulate = visual_state.color.darkened(0.4)
    
    # Handle blink state
    if visual_state.blink_state:
        symbol_label.modulate.a = 1.0
    else:
        symbol_label.modulate.a = 0.5

# ----- EVENT HANDLERS -----
func _on_update_timer_timeout():
    _update_ui_all()

func _on_auto_hide_timer_timeout():
    if auto_hide:
        is_hidden = true
        # Tween to fade out
        var tween = create_tween()
        tween.tween_property(self, "modulate:a", 0.0, 0.5)
        await tween.finished
        visible = false

func _on_mode_changed(new_mode):
    _update_mode_display()
    _update_layers_display()

func _on_blink_occurred(is_on):
    if symbol_label:
        symbol_label.modulate.a = 1.0 if is_on else 0.5

func _on_layer_changed(new_layer):
    _update_layers_display()

func _on_symbol_changed(new_symbol):
    if symbol_label:
        symbol_label.text = new_symbol

func _on_color_updated(new_color):
    _update_layers_display()

func _on_mouse_entered():
    # Show UI when mouse enters
    show_ui()

func _input(event):
    # Show UI on any input
    if event is InputEventMouseButton or event is InputEventKey:
        if event.pressed:
            show_ui()

# ----- PUBLIC API -----
func show_ui():
    if is_hidden:
        is_hidden = false
        visible = true
        modulate.a = 0.0
        var tween = create_tween()
        tween.tween_property(self, "modulate:a", 1.0, 0.3)
    
    if auto_hide:
        auto_hide_timer.start(auto_hide_delay)

func toggle_compact_mode():
    compact_mode = !compact_mode
    
    # Update UI elements based on compact mode
    if compact_mode:
        turn_label.visible = false
        mode_label.visible = false
    else:
        turn_label.visible = show_turn_info
        mode_label.visible = show_mode_info
    
    return compact_mode

func toggle_auto_hide():
    auto_hide = !auto_hide
    
    if auto_hide:
        auto_hide_timer.start(auto_hide_delay)
    else:
        auto_hide_timer.stop()
        show_ui()
    
    return auto_hide

func toggle_animations():
    use_animations = !use_animations
    
    if !use_animations:
        # Reset animation state
        symbol_container.rotation_degrees = 0
        symbol_label.scale = Vector2(1, 1)
    
    return use_animations

func cycle_visual_mode():
    if visual_system and visual_system.has_method("cycle_mode"):
        return visual_system.cycle_mode()
    return -1