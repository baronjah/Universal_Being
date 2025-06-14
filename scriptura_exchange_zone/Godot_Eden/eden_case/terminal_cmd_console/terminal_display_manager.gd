extends Node
class_name TerminalDisplayManager

signal mode_changed(mode_name: String)
signal battery_state_changed(state: Dictionary)
signal fractal_updated(settings: Dictionary)

enum DisplayMode {
    STANDARD,
    NIGHT,
    BATTERY_SAVER,
    AIRMAX,
    FRACTAL
}

var current_mode: int = DisplayMode.STANDARD
var luno_manager: LunoCycleManager = null
var battery_monitor_active: bool = true

# Color themes for different modes
var color_themes: Dictionary = {
    "standard": {
        "background": Color(0.1, 0.1, 0.1, 1.0),
        "foreground": Color(0.9, 0.9, 0.9, 1.0),
        "accent": Color(0.0, 0.6, 1.0, 1.0),
        "secondary": Color(0.7, 0.7, 0.7, 1.0),
        "highlight": Color(1.0, 0.8, 0.0, 1.0)
    },
    "night": {
        "background": Color(0.05, 0.05, 0.1, 1.0),
        "foreground": Color(0.7, 0.7, 0.8, 1.0),
        "accent": Color(0.3, 0.4, 0.7, 1.0),
        "secondary": Color(0.4, 0.4, 0.5, 1.0),
        "highlight": Color(0.5, 0.5, 0.8, 1.0)
    },
    "battery_saver": {
        "background": Color(0.0, 0.0, 0.0, 1.0),
        "foreground": Color(0.6, 0.6, 0.6, 1.0),
        "accent": Color(0.2, 0.5, 0.2, 1.0),
        "secondary": Color(0.3, 0.3, 0.3, 1.0),
        "highlight": Color(0.4, 0.7, 0.4, 1.0)
    },
    "airmax": {
        "background": Color(0.95, 0.95, 0.97, 1.0),
        "foreground": Color(0.1, 0.1, 0.15, 1.0),
        "accent": Color(0.0, 0.4, 0.9, 1.0),
        "secondary": Color(0.5, 0.5, 0.6, 1.0),
        "highlight": Color(0.0, 0.6, 1.0, 1.0)
    },
    "fractal": {
        "background": Color(0.05, 0.05, 0.1, 1.0),
        "foreground": Color(0.8, 0.8, 0.9, 1.0),
        "accent": Color(0.5, 0.0, 0.8, 1.0),
        "secondary": Color(0.4, 0.3, 0.6, 1.0),
        "highlight": Color(0.8, 0.3, 0.9, 1.0)
    }
}

# Terminal settings
var terminal_settings: Dictionary = {
    "font_size": 14,
    "line_spacing": 1.2,
    "cursor_blink_rate": 0.5,
    "show_line_numbers": true,
    "scroll_speed": 1.0,
    "animation_speed": 1.0
}

# Battery state
var battery_state: Dictionary = {
    "level": 100,
    "charging": true,
    "save_mode": false,
    "last_updated": 0
}

# Fractal settings
var fractal_settings: Dictionary = {
    "active": false,
    "depth": 3,
    "offset": Vector2(0, 0),
    "scale": 1.0,
    "rotation": 0.0,
    "color_shift": 0.0,
    "animation_speed": 0.5
}

func _ready():
    # Connect to LUNO system if available
    _connect_to_luno()
    
    # Initialize with standard mode
    set_display_mode(DisplayMode.STANDARD)
    
    # Start battery monitoring
    _start_battery_monitor()

func _connect_to_luno():
    luno_manager = get_node_or_null("/root/LunoCycleManager")
    
    if luno_manager:
        print("🖥️ Terminal Display Manager connected to LUNO")
        luno_manager.register_participant("TerminalDisplay", Callable(self, "_on_luno_tick"))
    else:
        print("⚠️ LUNO manager not found, terminal display will operate independently")

func _start_battery_monitor():
    # Create timer for periodic battery checks
    var battery_timer = Timer.new()
    battery_timer.wait_time = 60.0  # Check every minute
    battery_timer.one_shot = false
    battery_timer.connect("timeout", Callable(self, "_check_battery_state"))
    add_child(battery_timer)
    battery_timer.start()
    
    # Initial check
    _check_battery_state()

func _check_battery_state():
    if not battery_monitor_active:
        return
    
    # In a real implementation, this would check actual battery status
    # For simulation, we'll just update values
    
    # Simulate battery level
    var previous_level = battery_state.level
    
    if battery_state.charging:
        battery_state.level = min(battery_state.level + 2, 100)
    else:
        battery_state.level = max(battery_state.level - 1, 5)
    
    # Toggle charging state occasionally for simulation
    if randf() > 0.95:
        battery_state.charging = !battery_state.charging
    
    # Update timestamp
    battery_state.last_updated = OS.get_unix_time()
    
    # Auto-enable battery save mode when low
    if battery_state.level < 20 and !battery_state.save_mode:
        battery_state.save_mode = true
        print("🔋 Battery level low, enabling save mode")
        set_display_mode(DisplayMode.BATTERY_SAVER)
    
    # Disable save mode when charging and above threshold
    if battery_state.charging and battery_state.level > 30 and battery_state.save_mode:
        battery_state.save_mode = false
        print("🔋 Battery charging, disabling save mode")
        set_display_mode(DisplayMode.STANDARD)
    
    # Emit signal if level changed significantly
    if abs(previous_level - battery_state.level) >= 5:
        emit_signal("battery_state_changed", battery_state)

func set_display_mode(mode: int):
    if mode == current_mode:
        return
    
    current_mode = mode
    var mode_name = ""
    
    match mode:
        DisplayMode.STANDARD:
            mode_name = "standard"
            _apply_theme("standard")
            fractal_settings.active = false
        DisplayMode.NIGHT:
            mode_name = "night"
            _apply_theme("night")
            fractal_settings.active = false
        DisplayMode.BATTERY_SAVER:
            mode_name = "battery_saver"
            _apply_theme("battery_saver")
            fractal_settings.active = false
        DisplayMode.AIRMAX:
            mode_name = "airmax"
            _apply_theme("airmax")
            fractal_settings.active = false
        DisplayMode.FRACTAL:
            mode_name = "fractal"
            _apply_theme("fractal")
            fractal_settings.active = true
            _update_fractal_visualization()
    
    print("🎨 Display mode changed to: " + mode_name)
    emit_signal("mode_changed", mode_name)

func _apply_theme(theme_name: String):
    if not color_themes.has(theme_name):
        print("⚠️ Theme not found: " + theme_name)
        return
    
    var theme = color_themes[theme_name]
    
    # In a real implementation, this would apply the theme to UI elements
    print("🎨 Applied theme: " + theme_name)
    
    # Adjust terminal settings based on theme
    match theme_name:
        "standard":
            terminal_settings.font_size = 14
            terminal_settings.animation_speed = 1.0
        "night":
            terminal_settings.font_size = 16
            terminal_settings.animation_speed = 0.8
        "battery_saver":
            terminal_settings.font_size = 14
            terminal_settings.animation_speed = 0.5
        "airmax":
            terminal_settings.font_size = 13
            terminal_settings.animation_speed = 1.2
        "fractal":
            terminal_settings.font_size = 15
            terminal_settings.animation_speed = 1.0

func _update_fractal_visualization():
    if not fractal_settings.active:
        return
    
    # Simulate fractal parameter updates
    # In a real implementation, this would update a shader or visualization
    print("🌀 Updating fractal visualization")
    emit_signal("fractal_updated", fractal_settings)

func _on_luno_tick(turn: int, phase_name: String):
    # Respond to LUNO cycle ticks
    if turn == 0 and phase_name == "Evolution":
        # Special case for evolution events
        print("✨ Terminal display evolving with system")
        _evolve_display()
        return
    
    # Only process in fractal mode
    if current_mode != DisplayMode.FRACTAL:
        return
    
    # Update fractal parameters based on phase
    match phase_name:
        "Genesis":
            fractal_settings.depth = 2
        "Formation":
            fractal_settings.depth = 3
        "Complexity": 
            fractal_settings.depth = 4
        "Transcendence", "Unity", "Beyond":
            fractal_settings.depth = 5
    
    # Adjust color shift based on turn
    fractal_settings.color_shift = (turn - 1) / 11.0
    
    # Update rotation
    fractal_settings.rotation += 0.1
    
    # Update fractal
    _update_fractal_visualization()

func _evolve_display():
    # Enhance display capabilities after system evolution
    
    # Add a new color theme variation
    var current_theme = color_themes[get_current_theme_name()]
    var evolved_theme = current_theme.duplicate()
    
    # Slightly modify colors
    evolved_theme.accent = Color(
        clamp(evolved_theme.accent.r + randf_range(-0.1, 0.1), 0, 1),
        clamp(evolved_theme.accent.g + randf_range(-0.1, 0.1), 0, 1),
        clamp(evolved_theme.accent.b + randf_range(-0.1, 0.1), 0, 1),
        1.0
    )
    
    evolved_theme.highlight = Color(
        clamp(evolved_theme.highlight.r + randf_range(-0.1, 0.1), 0, 1),
        clamp(evolved_theme.highlight.g + randf_range(-0.1, 0.1), 0, 1),
        clamp(evolved_theme.highlight.b + randf_range(-0.1, 0.1), 0, 1),
        1.0
    )
    
    # Add evolved theme
    color_themes["evolved"] = evolved_theme
    
    # Enhance fractal capabilities
    fractal_settings.depth += 1
    
    print("✨ Display capabilities enhanced")

func toggle_night_mode(enable: bool):
    if enable:
        set_display_mode(DisplayMode.NIGHT)
    else:
        set_display_mode(DisplayMode.STANDARD)

func toggle_battery_saver(enable: bool):
    battery_state.save_mode = enable
    
    if enable:
        set_display_mode(DisplayMode.BATTERY_SAVER)
    else:
        set_display_mode(DisplayMode.STANDARD)

func toggle_airmax_mode(enable: bool):
    if enable:
        set_display_mode(DisplayMode.AIRMAX)
    else:
        set_display_mode(DisplayMode.STANDARD)

func toggle_fractal_mode(enable: bool):
    if enable:
        set_display_mode(DisplayMode.FRACTAL)
    else:
        set_display_mode(DisplayMode.STANDARD)

func set_fractal_offset(offset: Vector2):
    fractal_settings.offset = offset
    _update_fractal_visualization()

func set_text_offset(offset: float):
    # Adjust text rendering offset
    # In a real implementation, this would update text rendering
    print("📝 Text offset updated: " + str(offset))

func get_current_theme_name() -> String:
    match current_mode:
        DisplayMode.STANDARD: return "standard"
        DisplayMode.NIGHT: return "night"
        DisplayMode.BATTERY_SAVER: return "battery_saver"
        DisplayMode.AIRMAX: return "airmax"
        DisplayMode.FRACTAL: return "fractal"
        _: return "standard"

func get_current_theme() -> Dictionary:
    return color_themes[get_current_theme_name()]

func get_battery_state() -> Dictionary:
    return battery_state
    
func get_terminal_settings() -> Dictionary:
    return terminal_settings
    
# Example usage:
# var display_manager = TerminalDisplayManager.new()
# add_child(display_manager)
# display_manager.toggle_night_mode(true)
# display_manager.connect("mode_changed", self, "_on_display_mode_changed")