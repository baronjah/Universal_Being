# 🏛️ Visual Indicator System - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
class_name VisualIndicatorSystem

# ----- VISUAL INDICATOR SETTINGS -----
@export_category("Visual Settings")
@export var enabled: bool = true
@export var current_mode: int = 0
@export var blink_speed: float = 0.5
@export var color_cycle_speed: float = 1.0
@export var icon_scale: float = 1.0
@export var layer_count: int = 3

# ----- MODE DEFINITIONS -----
enum Modes {
    MINIMAL,        # Mode 1: Simple minimal display
    STANDARD,       # Mode 2: Standard with more info
    DETAILED,       # Mode 3: Full details with all indicators
    SYMBOLIC        # Mode 4: Symbol-based visualization
}

# ----- SYMBOLS -----
const SYMBOLS = [
    "#",       # Hash/pound - basic symbol
    "##",      # Double hash - medium intensity
    "###",     # Triple hash - high intensity
    "####",    # Quad hash - maximum intensity
    "$",       # Dollar - currency/value
    "$$",      # Double dollar - medium value
    "$$$$",    # Quad dollar - high value
    "@",       # At sign - connection/network
    "*",       # Asterisk - special event
    "^",       # Caret - attention/focus
    "!",       # Exclamation - alert/warning
    "+"        # Plus - positive/addition
]

# ----- VISUAL COMPONENTS -----
var center_icon: String = "#"
var current_blink_state: bool = false
var current_layer: int = 0
var current_symbol_index: int = 0

# ----- COLOR DEFINITIONS -----
var base_colors = [
    Color(0.8, 0.2, 0.2),  # Red
    Color(0.2, 0.8, 0.2),  # Green
    Color(0.2, 0.2, 0.8),  # Blue
    Color(0.8, 0.8, 0.2),  # Yellow
    Color(0.8, 0.2, 0.8),  # Magenta
    Color(0.2, 0.8, 0.8),  # Cyan
    Color(0.8, 0.8, 0.8),  # White
    Color(0.4, 0.4, 0.4),  # Gray
    Color(0.6, 0.4, 0.2)   # Brown
]

var mode_colors = {
    Modes.MINIMAL: [Color(0.5, 0.5, 0.5)],
    Modes.STANDARD: [Color(0.2, 0.6, 0.8), Color(0.8, 0.6, 0.2)],
    Modes.DETAILED: [Color(0.9, 0.2, 0.2), Color(0.2, 0.9, 0.2), Color(0.2, 0.2, 0.9)],
    Modes.SYMBOLIC: [Color(0.8, 0.3, 0.9), Color(0.3, 0.8, 0.9), Color(0.9, 0.8, 0.3)]
}

# ----- TIMERS -----
var blink_timer: Timer
var color_cycle_timer: Timer
var animation_timer: Timer

# ----- INTEGRATION -----
var time_tracker: Node = null

# ----- SIGNALS -----
signal mode_changed(new_mode)
signal blink_occurred(is_on)
signal layer_changed(new_layer)
signal symbol_changed(new_symbol)
signal color_updated(new_color)

# ----- INITIALIZATION -----
func _ready():
    _setup_timers()
    _find_time_tracker()
    _apply_mode_settings(current_mode)
    
    print("Visual Indicator System initialized - Mode: " + str(current_mode))

func _setup_timers():
    # Blink timer
    blink_timer = TimerManager.get_timer()
    blink_timer.wait_time = blink_speed
    blink_timer.one_shot = false
    blink_timer.autostart = true
    blink_timer.connect("timeout", _on_blink_timer_timeout)
    add_child(blink_timer)
    
    # Color cycle timer
    color_cycle_timer = TimerManager.get_timer()
    color_cycle_timer.wait_time = color_cycle_speed
    color_cycle_timer.one_shot = false
    color_cycle_timer.autostart = true
    color_cycle_timer.connect("timeout", _on_color_cycle_timer_timeout)
    add_child(color_cycle_timer)
    
    # Animation timer for more complex animations
    animation_timer = TimerManager.get_timer()
    animation_timer.wait_time = 0.05  # 20 fps for animations
    animation_timer.one_shot = false
    animation_timer.autostart = true
    animation_timer.connect("timeout", _on_animation_timer_timeout)
    add_child(animation_timer)

func _find_time_tracker():
    var potential_trackers = get_tree().get_nodes_in_group("time_trackers")
    if potential_trackers.size() > 0:
        time_tracker = potential_trackers[0]
        print("Found time tracker: " + time_tracker.name)
        
        # Connect to time tracker signals if available
        if time_tracker.has_signal("time_updated"):
            time_tracker.connect("time_updated", _on_time_updated)
        
        if time_tracker.has_signal("hour_limit_reached"):
            time_tracker.connect("hour_limit_reached", _on_hour_limit_reached)
    else:
        # Find using class name
        var root = get_tree().root
        time_tracker = _find_node_by_class(root, "UsageTimeTracker")
            
        if time_tracker:
            print("Found time tracker by class: " + time_tracker.name)
            
            # Connect to signals
            if time_tracker.has_signal("time_updated"):
                time_tracker.connect("time_updated", _on_time_updated)
            
            if time_tracker.has_signal("hour_limit_reached"):
                time_tracker.connect("hour_limit_reached", _on_hour_limit_reached)

func _find_node_by_class(node: Node, class_name: String) -> Node:
    if node.get_class() == class_name:
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name)
        if found:
            return found
    
    return null

# ----- MODE MANAGEMENT -----
func _apply_mode_settings(mode_index):
    var mode = mode_index
    current_mode = mode
    
    match mode:
        Modes.MINIMAL:
            blink_speed = 1.0
            color_cycle_speed = 2.0
            layer_count = 1
            _set_symbol(0)  # Simple #
            
        Modes.STANDARD:
            blink_speed = 0.75
            color_cycle_speed = 1.5
            layer_count = 2
            _set_symbol(1)  # ##
            
        Modes.DETAILED:
            blink_speed = 0.5
            color_cycle_speed = 1.0
            layer_count = 3
            _set_symbol(2)  # ###
            
        Modes.SYMBOLIC:
            blink_speed = 0.3
            color_cycle_speed = 0.8
            layer_count = 3
            _set_symbol(4)  # $
    
    # Update timers with new settings
    blink_timer.wait_time = blink_speed
    color_cycle_timer.wait_time = color_cycle_speed
    
    emit_signal("mode_changed", current_mode)

func _set_symbol(symbol_index):
    current_symbol_index = symbol_index
    center_icon = SYMBOLS[symbol_index]
    emit_signal("symbol_changed", center_icon)

# ----- TIMER CALLBACKS -----
func _on_blink_timer_timeout():
    if not enabled:
        return
        
    current_blink_state = !current_blink_state
    emit_signal("blink_occurred", current_blink_state)

func _on_color_cycle_timer_timeout():
    if not enabled:
        return
        
    # Cycle to next layer color based on mode
    current_layer = (current_layer + 1) % layer_count
    
    var color
    if current_mode < mode_colors.size() and current_layer < mode_colors[current_mode].size():
        color = mode_colors[current_mode][current_layer]
    else:
        # Fallback to base colors
        color = base_colors[current_layer % base_colors.size()]
    
    emit_signal("layer_changed", current_layer)
    emit_signal("color_updated", color)

func _on_animation_timer_timeout():
    if not enabled:
        return
        
    # This would handle more complex animations like symbol rotations,
    # scaling effects, or other periodic visual changes

# ----- TIME TRACKER CALLBACKS -----
func _on_time_updated(session_time, total_time):
    # Update visuals based on time progression
    var hours_used = total_time / 3600.0
    
    # Change symbol based on hours used (more complex as time increases)
    var new_symbol_index = min(floor(hours_used), SYMBOLS.size() - 1)
    if new_symbol_index != current_symbol_index:
        _set_symbol(new_symbol_index)

func _on_hour_limit_reached(hours):
    # Change to warning mode when hour limit is reached
    _set_symbol(10)  # Exclamation mark
    
    # Temporarily speed up blinking
    var original_speed = blink_timer.wait_time
    blink_timer.wait_time = 0.2
    
    # Reset after 5 seconds
    await get_tree().create_timer(5.0).timeout
    blink_timer.wait_time = original_speed

# ----- PUBLIC API -----

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func set_mode(mode_index: int) -> bool:
    if mode_index < 0 or mode_index >= Modes.size():
        return false
        
    _apply_mode_settings(mode_index)
    return true

func cycle_mode() -> int:
    var next_mode = (current_mode + 1) % Modes.size()
    _apply_mode_settings(next_mode)
    return current_mode

func toggle_enabled() -> bool:
    enabled = !enabled
    return enabled

func get_current_symbol() -> String:
    return center_icon

func get_current_mode_name() -> String:
    match current_mode:
        Modes.MINIMAL: return "Minimal"
        Modes.STANDARD: return "Standard"
        Modes.DETAILED: return "Detailed"
        Modes.SYMBOLIC: return "Symbolic"
        _: return "Unknown"

func get_visual_state() -> Dictionary:
    var color
    if current_mode < mode_colors.size() and current_layer < mode_colors[current_mode].size():
        color = mode_colors[current_mode][current_layer]
    else:
        color = base_colors[current_layer % base_colors.size()]
        
    return {
        "enabled": enabled,
        "mode": current_mode,
        "mode_name": get_current_mode_name(),
        "symbol": center_icon,
        "blink_state": current_blink_state,
        "current_layer": current_layer,
        "color": color,
        "scale": icon_scale
    }