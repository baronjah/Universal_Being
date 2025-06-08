extends Node

class_name ExtendedColorThemeSystem

# ----- COLOR DEPTH SETTINGS -----
@export_category("Color Depth Settings")
@export var color_depth: int = 24  # 16, 24, or 32 bits
@export var use_hdr_colors: bool = false  # Enable HDR colors (32-bit)
@export var enable_color_correction: bool = true  # Apply sRGB correction
@export var dithering_enabled: bool = false  # Enable dithering for lower bit depths

# ----- THEME CONFIGURATION -----
@export_category("Theme Settings")
@export var current_theme: String = "default"
@export var auto_theme_switching: bool = false
@export var time_based_themes: bool = false
@export var theme_transition_duration: float = 0.5  # seconds
@export var enable_contrast_adjustment: bool = true
@export var contrast_ratio_target: float = 4.5  # WCAG AA standard

# ----- COLOR HARMONICS -----
@export_category("Color Harmonics")
@export var primary_color: Color = Color(0.1, 0.4, 0.9, 1.0)  # Base blue
@export var secondary_color: Color = Color(0.9, 0.3, 0.1, 1.0)  # Accent orange
@export var tertiary_color: Color = Color(0.1, 0.7, 0.3, 1.0)  # Highlight green
@export var neutral_color: Color = Color(0.2, 0.2, 0.25, 1.0)  # Base neutral
@export var background_color: Color = Color(0.05, 0.05, 0.1, 1.0)  # Dark background

# ----- STATE VARIABLES -----
var themes = {}
var current_colors = {}
var transition_timer: Timer
var is_transitioning = false
var transition_progress = 0.0
var transition_start_colors = {}
var transition_target_colors = {}
var color_correction_lut = []
var color_temperature = 6500  # Kelvin
var color_brightness = 1.0  # 0-1 scale

# ----- SIGNALS -----
signal theme_changed(theme_name)
signal color_component_changed(component_name, color)
signal transition_started(from_theme, to_theme)
signal transition_completed(theme_name)
signal color_temperature_changed(temperature)
signal color_format_changed(format)

# ----- INITIALIZATION -----
func _ready():
    # Initialize timers
    _initialize_timers()
    
    # Initialize default themes
    _initialize_default_themes()
    
    # Initialize color correction lookup table
    _initialize_color_correction()
    
    # Apply default theme
    apply_theme(current_theme, false)
    
    print("Extended Color Theme System initialized")
    print("Current theme: " + current_theme)
    print("Color depth: " + str(color_depth) + "-bit")

func _initialize_timers():
    # Create transition timer
    transition_timer = Timer.new()
    transition_timer.wait_time = 0.016  # ~60fps
    transition_timer.one_shot = false
    transition_timer.autostart = false
    transition_timer.connect("timeout", Callable(self, "_on_transition_timer"))
    add_child(transition_timer)

func _initialize_default_themes():
    # Create preset themes
    
    # Default theme (blue-based)
    themes["default"] = {
        "primary": Color(0.1, 0.4, 0.9, 1.0),        # Blue
        "secondary": Color(0.9, 0.3, 0.1, 1.0),      # Orange
        "tertiary": Color(0.1, 0.7, 0.3, 1.0),       # Green
        "neutral": Color(0.2, 0.2, 0.25, 1.0),       # Slate
        "background": Color(0.05, 0.05, 0.1, 1.0),   # Dark blue
        "success": Color(0.2, 0.8, 0.2, 1.0),        # Green
        "warning": Color(0.9, 0.7, 0.1, 1.0),        # Yellow
        "error": Color(0.9, 0.1, 0.1, 1.0),          # Red
        "info": Color(0.1, 0.6, 0.9, 1.0),           # Light blue
        "text_primary": Color(0.9, 0.9, 0.95, 1.0),  # Near white
        "text_secondary": Color(0.7, 0.7, 0.75, 1.0),# Light gray
        "border": Color(0.3, 0.3, 0.4, 1.0),         # Medium gray
        "highlight": Color(0.4, 0.6, 1.0, 1.0)       # Highlight blue
    }
    
    # Dark theme
    themes["dark"] = {
        "primary": Color(0.2, 0.2, 0.25, 1.0),       # Dark slate
        "secondary": Color(0.5, 0.1, 0.7, 1.0),      # Purple
        "tertiary": Color(0.1, 0.5, 0.5, 1.0),       # Teal
        "neutral": Color(0.15, 0.15, 0.18, 1.0),     # Dark gray
        "background": Color(0.05, 0.05, 0.06, 1.0),  # Nearly black
        "success": Color(0.2, 0.6, 0.2, 1.0),        # Muted green
        "warning": Color(0.7, 0.5, 0.1, 1.0),        # Muted yellow
        "error": Color(0.7, 0.1, 0.1, 1.0),          # Muted red
        "info": Color(0.1, 0.4, 0.7, 1.0),           # Muted blue
        "text_primary": Color(0.9, 0.9, 0.9, 1.0),   # White
        "text_secondary": Color(0.6, 0.6, 0.65, 1.0),# Gray
        "border": Color(0.25, 0.25, 0.3, 1.0),       # Dark gray
        "highlight": Color(0.3, 0.3, 0.5, 1.0)       # Muted highlight
    }
    
    # Light theme
    themes["light"] = {
        "primary": Color(0.2, 0.5, 0.9, 1.0),        # Blue
        "secondary": Color(0.9, 0.4, 0.1, 1.0),      # Orange
        "tertiary": Color(0.1, 0.7, 0.4, 1.0),       # Green
        "neutral": Color(0.9, 0.9, 0.93, 1.0),       # Light gray
        "background": Color(0.98, 0.98, 1.0, 1.0),   # Nearly white
        "success": Color(0.2, 0.8, 0.2, 1.0),        # Green
        "warning": Color(0.9, 0.7, 0.1, 1.0),        # Yellow
        "error": Color(0.9, 0.1, 0.1, 1.0),          # Red
        "info": Color(0.1, 0.6, 0.9, 1.0),           # Light blue
        "text_primary": Color(0.1, 0.1, 0.15, 1.0),  # Nearly black
        "text_secondary": Color(0.4, 0.4, 0.5, 1.0), # Gray
        "border": Color(0.8, 0.8, 0.85, 1.0),        # Light gray
        "highlight": Color(0.7, 0.8, 1.0, 1.0)       # Light highlight
    }
    
    # High contrast theme
    themes["high_contrast"] = {
        "primary": Color(1.0, 1.0, 1.0, 1.0),        # White
        "secondary": Color(1.0, 0.8, 0.0, 1.0),      # Yellow
        "tertiary": Color(0.0, 1.0, 1.0, 1.0),       # Cyan
        "neutral": Color(0.8, 0.8, 0.8, 1.0),        # Light gray
        "background": Color(0.0, 0.0, 0.0, 1.0),     # Black
        "success": Color(0.0, 1.0, 0.0, 1.0),        # Bright green
        "warning": Color(1.0, 1.0, 0.0, 1.0),        # Bright yellow
        "error": Color(1.0, 0.0, 0.0, 1.0),          # Bright red
        "info": Color(0.0, 0.8, 1.0, 1.0),           # Bright blue
        "text_primary": Color(1.0, 1.0, 1.0, 1.0),   # White
        "text_secondary": Color(0.9, 0.9, 0.9, 1.0), # Light gray
        "border": Color(1.0, 1.0, 1.0, 1.0),         # White
        "highlight": Color(1.0, 0.8, 0.0, 1.0)       # Yellow
    }
    
    # Ethereal theme (blue/cyan)
    themes["ethereal"] = {
        "primary": Color(0.05, 0.3, 0.7, 1.0),       # Deep blue
        "secondary": Color(0.1, 0.6, 0.8, 1.0),      # Cyan
        "tertiary": Color(0.3, 0.7, 0.9, 1.0),       # Light blue
        "neutral": Color(0.15, 0.2, 0.3, 1.0),       # Blue-gray
        "background": Color(0.03, 0.05, 0.15, 1.0),  # Dark blue
        "success": Color(0.2, 0.9, 0.7, 1.0),        # Teal
        "warning": Color(0.7, 0.5, 0.9, 1.0),        # Purple
        "error": Color(0.9, 0.3, 0.5, 1.0),          # Pink
        "info": Color(0.3, 0.7, 1.0, 1.0),           # Sky blue
        "text_primary": Color(0.8, 0.9, 1.0, 1.0),   # Light blue-white
        "text_secondary": Color(0.5, 0.7, 0.9, 1.0), # Medium blue
        "border": Color(0.2, 0.4, 0.6, 1.0),         # Blue-gray
        "highlight": Color(0.1, 0.8, 1.0, 1.0)       # Bright cyan
    }
    
    # Akashic theme (purple/gold)
    themes["akashic"] = {
        "primary": Color(0.4, 0.1, 0.6, 1.0),        # Purple
        "secondary": Color(0.8, 0.6, 0.1, 1.0),      # Gold
        "tertiary": Color(0.6, 0.2, 0.8, 1.0),       # Violet
        "neutral": Color(0.25, 0.15, 0.3, 1.0),      # Dark purple
        "background": Color(0.1, 0.05, 0.15, 1.0),   # Deep purple
        "success": Color(0.5, 0.8, 0.2, 1.0),        # Green-gold
        "warning": Color(0.9, 0.6, 0.1, 1.0),        # Orange-gold
        "error": Color(0.8, 0.2, 0.3, 1.0),          # Red-purple
        "info": Color(0.3, 0.2, 0.8, 1.0),           # Blue-purple
        "text_primary": Color(0.9, 0.8, 1.0, 1.0),   # Light purple-white
        "text_secondary": Color(0.7, 0.5, 0.8, 1.0), # Medium purple
        "border": Color(0.4, 0.3, 0.5, 1.0),         # Purple-gray
        "highlight": Color(1.0, 0.8, 0.2, 1.0)       # Bright gold
    }
    
    # Current colors start with default theme
    current_colors = themes["default"].duplicate()

func _initialize_color_correction():
    # Initialize color correction lookup table
    # This would be used for sRGB correction and color temperature adjustment
    
    color_correction_lut.clear()
    
    # Create lookup tables for sRGB correction
    if enable_color_correction:
        # In a real implementation, would create a proper sRGB conversion table
        # For this mock-up, we'll just initialize with identity values
        for i in range(256):
            var normalized = i / 255.0
            
            # Simple gamma correction (gamma = 2.2)
            var corrected = pow(normalized, 1.0 / 2.2)
            
            color_correction_lut.append(corrected)
    else:
        # No correction - identity mapping
        for i in range(256):
            color_correction_lut.append(i / 255.0)

# ----- PROCESS -----
func _process(delta):
    # Process theme transitions
    if is_transitioning:
        # Update transition in _on_transition_timer
        pass
    
    # Process time-based theme switching if enabled
    if time_based_themes and not is_transitioning:
        _update_time_based_theme()

func _on_transition_timer():
    # Update theme transition
    if not is_transitioning:
        transition_timer.stop()
        return
    
    # Update progress
    transition_progress += transition_timer.wait_time / theme_transition_duration
    transition_progress = min(transition_progress, 1.0)
    
    # Interpolate colors
    for key in transition_start_colors.keys():
        var start_color = transition_start_colors[key]
        var target_color = transition_target_colors[key]
        
        # Use smoothstep for nicer easing
        var t = smoothstep(0.0, 1.0, transition_progress)
        var new_color = start_color.lerp(target_color, t)
        
        # Apply the interpolated color
        current_colors[key] = new_color
        
        # Emit signal for each changed color
        emit_signal("color_component_changed", key, new_color)
    
    # Check if transition is complete
    if transition_progress >= 1.0:
        is_transitioning = false
        transition_timer.stop()
        
        emit_signal("transition_completed", current_theme)
        
        print("Theme transition complete: " + current_theme)

func _update_time_based_theme():
    # Switch theme based on time of day
    var time = OS.get_time()
    var hour = time.hour
    
    # Early morning (5-8): Light theme
    if hour >= 5 and hour < 8:
        if current_theme != "light":
            apply_theme("light")
    
    # Day (8-18): Default theme
    elif hour >= 8 and hour < 18:
        if current_theme != "default":
            apply_theme("default")
    
    # Evening (18-22): Ethereal theme
    elif hour >= 18 and hour < 22:
        if current_theme != "ethereal":
            apply_theme("ethereal")
    
    # Night (22-5): Dark theme
    else:
        if current_theme != "dark":
            apply_theme("dark")

# ----- THEME MANAGEMENT -----
func apply_theme(theme_name: String, with_transition: bool = true) -> bool:
    # Apply a theme by name
    if not themes.has(theme_name):
        print("Theme not found: " + theme_name)
        return false
    
    # If already using this theme, do nothing
    if current_theme == theme_name and not is_transitioning:
        return true
    
    print("Applying theme: " + theme_name + (", with transition" if with_transition else ", without transition"))
    
    if with_transition:
        # Start transition to new theme
        _start_theme_transition(current_theme, theme_name)
    else:
        # Apply immediately
        current_colors = themes[theme_name].duplicate()
        current_theme = theme_name
        
        emit_signal("theme_changed", theme_name)
        
        # Emit signals for each color component
        for key in current_colors:
            emit_signal("color_component_changed", key, current_colors[key])
    
    return true

func _start_theme_transition(from_theme: String, to_theme: String):
    # Start a smooth transition between themes
    if not themes.has(from_theme) or not themes.has(to_theme):
        print("Invalid theme for transition")
        return
    
    # Stop any existing transition
    if is_transitioning:
        transition_timer.stop()
    
    # Set up transition
    transition_start_colors = current_colors.duplicate()
    transition_target_colors = themes[to_theme].duplicate()
    transition_progress = 0.0
    is_transitioning = true
    current_theme = to_theme
    
    # Start transition timer
    transition_timer.start()
    
    emit_signal("transition_started", from_theme, to_theme)
    
    print("Starting theme transition from " + from_theme + " to " + to_theme)

func create_theme(theme_name: String, base_color: Color) -> bool:
    # Create a new theme based on a color
    if themes.has(theme_name):
        print("Theme already exists: " + theme_name)
        return false
    
    print("Creating new theme: " + theme_name)
    
    # Generate colors based on the base color
    var h = base_color.h
    var s = base_color.s
    var v = base_color.v
    
    var new_theme = {
        "primary": base_color,
        "secondary": Color.from_hsv(fmod(h + 0.5, 1.0), s, v),  # Complementary
        "tertiary": Color.from_hsv(fmod(h + 0.33, 1.0), s, v),  # Triadic
        "neutral": Color.from_hsv(h, 0.15, 0.8),                # Desaturated
        "background": Color.from_hsv(h, 0.7, 0.1),              # Dark
        "success": Color(0.2, 0.8, 0.2, 1.0),                   # Green
        "warning": Color(0.9, 0.7, 0.1, 1.0),                   # Yellow
        "error": Color(0.9, 0.1, 0.1, 1.0),                     # Red
        "info": Color(0.1, 0.6, 0.9, 1.0),                      # Blue
        "text_primary": Color(0.9, 0.9, 0.95, 1.0),             # Near white
        "text_secondary": Color(0.7, 0.7, 0.75, 1.0),           # Light gray
        "border": Color(0.3, 0.3, 0.4, 1.0),                    # Medium gray
        "highlight": Color.from_hsv(h, 0.7, 1.0)                # Bright variant
    }
    
    # Fix text colors for light themes
    if v > 0.7:
        new_theme.text_primary = Color(0.1, 0.1, 0.15, 1.0)
        new_theme.text_secondary = Color(0.4, 0.4, 0.45, 1.0)
    
    # Apply contrast correction if enabled
    if enable_contrast_adjustment:
        _adjust_theme_contrast(new_theme)
    
    # Store the new theme
    themes[theme_name] = new_theme
    
    return true

func _adjust_theme_contrast(theme_dict: Dictionary):
    # Adjust contrast to meet accessibility standards
    
    # Check and fix text contrast against background
    var bg = theme_dict.background
    var text_primary = theme_dict.text_primary
    var text_secondary = theme_dict.text_secondary
    
    # Calculate contrast ratios
    var primary_contrast = _calculate_contrast_ratio(bg, text_primary)
    var secondary_contrast = _calculate_contrast_ratio(bg, text_secondary)
    
    # Adjust if needed
    if primary_contrast < contrast_ratio_target:
        theme_dict.text_primary = _increase_contrast(bg, text_primary, contrast_ratio_target)
    
    if secondary_contrast < contrast_ratio_target * 0.8:  # Lower target for secondary text
        theme_dict.text_secondary = _increase_contrast(bg, text_secondary, contrast_ratio_target * 0.8)

func _calculate_contrast_ratio(color1: Color, color2: Color) -> float:
    # Calculate WCAG contrast ratio between two colors
    var l1 = _get_relative_luminance(color1)
    var l2 = _get_relative_luminance(color2)
    
    # Ensure lighter color is l1
    if l1 < l2:
        var temp = l1
        l1 = l2
        l2 = temp
    
    return (l1 + 0.05) / (l2 + 0.05)

func _get_relative_luminance(color: Color) -> float:
    # Calculate relative luminance for WCAG contrast
    
    # Convert sRGB to linear RGB
    var r = color.r
    var g = color.g
    var b = color.b
    
    if r <= 0.03928:
        r = r / 12.92
    else:
        r = pow((r + 0.055) / 1.055, 2.4)
    
    if g <= 0.03928:
        g = g / 12.92
    else:
        g = pow((g + 0.055) / 1.055, 2.4)
    
    if b <= 0.03928:
        b = b / 12.92
    else:
        b = pow((b + 0.055) / 1.055, 2.4)
    
    # Calculate luminance
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

func _increase_contrast(background: Color, foreground: Color, target_ratio: float) -> Color:
    # Increase contrast between background and foreground to meet target ratio
    
    # Determine if we need to lighten or darken the foreground
    var bg_lum = _get_relative_luminance(background)
    var fg_lum = _get_relative_luminance(foreground)
    
    var new_color = foreground
    var step = 0.05
    var max_iterations = 10
    
    # If background is dark, lighten the foreground
    if bg_lum < 0.5:
        for i in range(max_iterations):
            new_color = new_color.lightened(step)
            if _calculate_contrast_ratio(background, new_color) >= target_ratio:
                break
    # If background is light, darken the foreground
    else:
        for i in range(max_iterations):
            new_color = new_color.darkened(step)
            if _calculate_contrast_ratio(background, new_color) >= target_ratio:
                break
    
    return new_color

# ----- COLOR MANAGEMENT -----
func get_color(component: String) -> Color:
    # Get a specific color from the current theme
    if current_colors.has(component):
        var color = current_colors[component]
        
        # Apply bit depth limitation if needed
        if color_depth < 24:
            color = _apply_bit_depth(color)
        
        return color
    
    # Return default if not found
    print("Color component not found: " + component)
    return Color(1, 1, 1, 1)

func set_color(component: String, color: Color) -> bool:
    # Set a specific color in the current theme
    if not current_colors.has(component):
        print("Color component not found: " + component)
        return false
    
    current_colors[component] = color
    
    emit_signal("color_component_changed", component, color)
    
    return true

func _apply_bit_depth(color: Color) -> Color:
    # Apply bit depth limitation to a color
    var result = color
    
    match color_depth:
        16:
            # 16-bit color (5:6:5)
            var r = floor(color.r * 31) / 31
            var g = floor(color.g * 63) / 63
            var b = floor(color.b * 31) / 31
            result = Color(r, g, b, 1.0)
            
            # Apply dithering if enabled
            if dithering_enabled:
                # Simple ordered dithering
                var dither_amount = 0.5 / 32.0
                var px = int(OS.get_ticks_msec()) % 4
                var py = int(OS.get_ticks_msec() / 4) % 4
                var dither_matrix = [
                    [0, 8, 2, 10],
                    [12, 4, 14, 6],
                    [3, 11, 1, 9],
                    [15, 7, 13, 5]
                ]
                var dither_value = dither_matrix[py][px] / 16.0 * dither_amount
                
                result.r = clamp(result.r + dither_value, 0, 1)
                result.g = clamp(result.g + dither_value, 0, 1)
                result.b = clamp(result.b + dither_value, 0, 1)
        
        32:
            # 32-bit color with HDR support
            if use_hdr_colors:
                # Allow values > 1.0 for HDR
                result = color
            else:
                # Standard 32-bit color (8:8:8:8)
                result = color
        
        _:  # 24-bit (default)
            # 24-bit color (8:8:8)
            var r = floor(color.r * 255) / 255
            var g = floor(color.g * 255) / 255
            var b = floor(color.b * 255) / 255
            result = Color(r, g, b, color.a)
    
    return result

func set_color_depth(bits: int) -> void:
    # Set the color depth
    if bits in [16, 24, 32]:
        color_depth = bits
        
        print("Color depth set to " + str(color_depth) + "-bit")
        
        # When depth changes, colors may change
        emit_signal("color_format_changed", color_depth)
    else:
        print("Unsupported color depth: " + str(bits))

func set_color_temperature(temperature: int) -> void:
    # Set the color temperature (in Kelvin)
    color_temperature = clamp(temperature, 1000, 12000)
    
    print("Color temperature set to " + str(color_temperature) + "K")
    
    # Update color correction
    _update_color_temperature()
    
    emit_signal("color_temperature_changed", color_temperature)

func _update_color_temperature():
    # Apply color temperature adjustment to all colors
    var strength = 0.3  # Adjustment strength (0-1)
    
    # Calculate temperature factor (0 = cold/blue, 1 = warm/red)
    var temp_factor = clamp((color_temperature - 1000) / 11000.0, 0, 1)
    var inverse_factor = 1.0 - temp_factor
    
    # Adjust current colors
    for key in current_colors.keys():
        var color = current_colors[key]
        
        # Adjust red and blue channels based on temperature
        var r = color.r + (temp_factor * strength)
        var b = color.b + (inverse_factor * strength)
        
        # Clamp values
        r = clamp(r, 0, 1)
        b = clamp(b, 0, 1)
        
        # Create adjusted color
        var adjusted_color = Color(r, color.g, b, color.a)
        
        # Apply to current colors
        current_colors[key] = adjusted_color
        
        # Emit signal for changed color
        emit_signal("color_component_changed", key, adjusted_color)

# ----- COLOR UTILITIES -----
func create_gradient(start_color: Color, end_color: Color, steps: int) -> Array:
    # Create a gradient between two colors
    var colors = []
    
    for i in range(steps):
        var t = float(i) / (steps - 1)
        var color = start_color.lerp(end_color, t)
        
        # Apply bit depth limitation if needed
        if color_depth < 24:
            color = _apply_bit_depth(color)
            
        colors.append(color)
    
    return colors

func create_color_scheme(base_color: Color, scheme_type: String = "complementary") -> Dictionary:
    # Create a color scheme based on a base color
    var h = base_color.h
    var s = base_color.s
    var v = base_color.v
    
    var colors = {}
    
    match scheme_type:
        "complementary":
            colors = {
                "base": base_color,
                "complement": Color.from_hsv(fmod(h + 0.5, 1.0), s, v)
            }
        
        "analogous":
            colors = {
                "base": base_color,
                "analogous1": Color.from_hsv(fmod(h - 0.08, 1.0), s, v),
                "analogous2": Color.from_hsv(fmod(h + 0.08, 1.0), s, v)
            }
        
        "triadic":
            colors = {
                "base": base_color,
                "triadic1": Color.from_hsv(fmod(h + 0.33, 1.0), s, v),
                "triadic2": Color.from_hsv(fmod(h + 0.66, 1.0), s, v)
            }
        
        "tetradic":
            colors = {
                "base": base_color,
                "tetradic1": Color.from_hsv(fmod(h + 0.25, 1.0), s, v),
                "tetradic2": Color.from_hsv(fmod(h + 0.5, 1.0), s, v),
                "tetradic3": Color.from_hsv(fmod(h + 0.75, 1.0), s, v)
            }
        
        "monochromatic":
            colors = {
                "base": base_color,
                "lighter1": Color.from_hsv(h, s * 0.7, min(v * 1.3, 1.0)),
                "lighter2": Color.from_hsv(h, s * 0.5, min(v * 1.6, 1.0)),
                "darker1": Color.from_hsv(h, min(s * 1.2, 1.0), v * 0.7),
                "darker2": Color.from_hsv(h, min(s * 1.4, 1.0), v * 0.4)
            }
            
        _:
            print("Unknown color scheme type: " + scheme_type)
            return {"base": base_color}
    
    # Apply bit depth limitation if needed
    if color_depth < 24:
        for key in colors.keys():
            colors[key] = _apply_bit_depth(colors[key])
    
    return colors

func smoothstep(edge0: float, edge1: float, x: float) -> float:
    # Smoothstep function for smooth transitions
    var t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)

# ----- THEME UTILITIES -----
func get_available_themes() -> Array:
    # Get a list of available themes
    return themes.keys()

func get_current_theme() -> String:
    return current_theme

func toggle_theme(theme1: String, theme2: String) -> void:
    # Toggle between two themes
    if current_theme == theme1:
        apply_theme(theme2)
    else:
        apply_theme(theme1)

func set_auto_theme_switching(enabled: bool) -> void:
    # Enable or disable automatic theme switching
    auto_theme_switching = enabled
    
    print("Auto theme switching " + ("enabled" if enabled else "disabled"))
    
    # If enabling time-based themes, update immediately
    if enabled and time_based_themes:
        _update_time_based_theme()

func export_theme(theme_name: String) -> Dictionary:
    # Export a theme as a JSON-compatible dictionary
    if not themes.has(theme_name):
        print("Theme not found: " + theme_name)
        return {}
    
    var export_data = {
        "name": theme_name,
        "colors": {}
    }
    
    # Convert colors to hex strings for easy serialization
    for key in themes[theme_name]:
        var color = themes[theme_name][key]
        export_data.colors[key] = color.to_html(true)
    
    return export_data

func import_theme(theme_data: Dictionary) -> bool:
    # Import a theme from a JSON-compatible dictionary
    if not theme_data.has("name") or not theme_data.has("colors"):
        print("Invalid theme data format")
        return false
    
    var theme_name = theme_data.name
    var theme_colors = {}
    
    # Convert hex strings back to colors
    for key in theme_data.colors:
        var hex_color = theme_data.colors[key]
        theme_colors[key] = Color(hex_color)
    
    # Store the theme
    themes[theme_name] = theme_colors
    
    print("Imported theme: " + theme_name)
    
    return true