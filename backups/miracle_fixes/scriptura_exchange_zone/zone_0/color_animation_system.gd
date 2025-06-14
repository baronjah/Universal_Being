class_name ColorAnimationSystem
extends Node

# ----- COLOR ANIMATION SETTINGS -----
@export_category("Animation Settings")
@export var enabled: bool = true
@export var update_interval: float = 0.05  # 20 FPS update rate
@export var default_duration: float = 1.0  # Default animation duration in seconds
@export var base_frequency: int = 99  # Starting frequency (maps to special frequencies)
@export var color_intensity: float = 0.8  # Color intensity (0-1)
@export var max_active_animations: int = 30  # Maximum concurrent animations

# ----- COLOR FREQUENCY CONSTANTS -----
const HARMONIC_FREQUENCIES = {
    "PRIMARY": [99, 333, 555, 777, 999],
    "SECONDARY": [120, 240, 360, 480, 600, 720, 840, 960],
    "SPECIAL": [33, 66, 166, 233, 266, 299, 399, 466, 499, 533, 599, 633, 666, 699, 833, 866, 899, 933, 966]
}

const MESH_POINTS = {
    "CENTERS": [333, 666, 999],
    "EDGES": [120, 240, 480, 720, 960],
    "CORNERS": [99, 555, 777]
}

const SYMBOL_FREQUENCIES = {
    "#": 33,    // Simple hash
    "##": 66,   // Double hash
    "###": 99,  // Triple hash
    "_": 12,    // Underscore
    "@": 55,    // At symbol
    "$": 77,    // Dollar
    "%": 44,    // Percent
    "&": 88,    // Ampersand
    "*": 22     // Asterisk
}

# ----- ANIMATION TYPES -----
enum AnimationType {
    FADE,        # Smooth fade between colors
    PULSE,       # Pulsing animation (fade in/out)
    RAINBOW,     # Cycling through rainbow colors
    FLASH,       # Quick flash effect
    GRADIENT,    # Gradient between two colors
    SPARKLE,     # Sparkling effect (random bright spots)
    WAVE,        # Wave effect across multiple elements
    MESH_POINT   # Special animation for mesh points
}

# ----- STATE VARIABLES -----
var active_animations = {}
var color_map = {}
var update_timer: Timer
var current_turn = 1
var total_turns = 12
var base_color_palette = []
var turn_color_palette = []
var last_animation_id = 0

# ----- COMPONENT REFERENCES -----
var color_system = null
var visual_indicator = null

# ----- SIGNALS -----
signal animation_started(animation_id, type)
signal animation_completed(animation_id, type)
signal color_updated(target_id, color)
signal frequency_activated(frequency, source)

# ----- INITIALIZATION -----
func _ready():
    _setup_timer()
    _initialize_color_map()
    _find_components()
    _initialize_palettes()
    
    print("Color Animation System initialized with base frequency: " + str(base_frequency))

func _setup_timer():
    update_timer = Timer.new()
    update_timer.wait_time = update_interval
    update_timer.one_shot = false
    update_timer.autostart = true
    update_timer.connect("timeout", Callable(self, "_on_update_timer"))
    add_child(update_timer)

func _initialize_color_map():
    # Initialize base colors for primary frequencies
    for freq in HARMONIC_FREQUENCIES.PRIMARY:
        color_map[freq] = _create_color_for_frequency(freq, "primary")
    
    # Initialize colors for secondary frequencies
    for freq in HARMONIC_FREQUENCIES.SECONDARY:
        color_map[freq] = _create_color_for_frequency(freq, "secondary")
    
    # Initialize colors for special frequencies
    for freq in HARMONIC_FREQUENCIES.SPECIAL:
        color_map[freq] = _create_color_for_frequency(freq, "special")

func _create_color_for_frequency(frequency: int, type: String = "primary") -> Color:
    # Create a color based on frequency value and type
    var hue = (frequency % 360) / 360.0
    var saturation = 0.8
    var value = 0.9
    
    match type:
        "primary":
            # Primary frequencies get pure, vibrant colors
            saturation = 0.9
            value = 1.0
        "secondary":
            # Secondary frequencies are slightly less saturated
            saturation = 0.8
            value = 0.9
        "special":
            # Special frequencies have unique treatment
            saturation = 0.7
            value = 0.85
    
    # Special cases for mesh points
    if MESH_POINTS.CENTERS.has(frequency):
        # Centers are bright and pure
        return Color(1.0, 1.0, 1.0).lerp(Color.from_hsv(hue, 0.5, 1.0), 0.7)
    elif MESH_POINTS.CORNERS.has(frequency):
        # Corners are gold/bronze toned
        return Color.from_hsv(0.15, 0.8, 0.9)
    elif MESH_POINTS.EDGES.has(frequency):
        # Edges are blue/cyan toned
        return Color.from_hsv(0.5, 0.7, 1.0)
    
    # Standard HSV-based color
    return Color.from_hsv(hue, saturation, value)

func _find_components():
    # Find Color System
    color_system = get_node_or_null("/root/DimensionalColorSystem")
    if not color_system:
        color_system = _find_node_by_class(get_tree().root, "DimensionalColorSystem")
    
    # Find Visual Indicator
    visual_indicator = get_node_or_null("/root/VisualIndicatorSystem")
    if not visual_indicator:
        visual_indicator = _find_node_by_class(get_tree().root, "VisualIndicatorSystem")
    
    print("Components found - Color System: %s, Visual Indicator: %s" % [
        "Yes" if color_system else "No",
        "Yes" if visual_indicator else "No"
    ])

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

func _initialize_palettes():
    # Initialize base color palette
    base_color_palette = [
        Color(0.1, 0.4, 0.9),  # Blue
        Color(0.0, 0.9, 0.6),  # Teal
        Color(0.9, 0.4, 0.7),  # Pink
        Color(0.9, 0.8, 0.1),  # Gold
        Color(0.5, 0.0, 0.9),  # Purple
        Color(0.0, 0.7, 0.9),  # Cyan 
        Color(0.0, 0.9, 0.0),  # Green
        Color(0.9, 0.9, 0.0)   # Yellow
    ]
    
    # Initialize turn-based color palette
    turn_color_palette = []
    for i in range(total_turns):
        var turn_number = i + 1
        var hue = (turn_number - 1) / float(total_turns)
        var turn_color = Color.from_hsv(hue, 0.8, 0.9)
        turn_color_palette.append(turn_color)

# ----- UPDATE LOOP -----
func _on_update_timer():
    if not enabled:
        return
    
    # Process active animations
    _update_animations(update_interval)
    
    # Forward colors to any connected systems
    _sync_colors()

func _update_animations(delta: float):
    var completed_animations = []
    
    # Update each active animation
    for animation_id in active_animations.keys():
        var animation = active_animations[animation_id]
        animation.elapsed_time += delta
        
        # Check if animation is complete
        if animation.elapsed_time >= animation.duration:
            completed_animations.append(animation_id)
            continue
        
        # Calculate progress (0 to 1)
        var progress = animation.elapsed_time / animation.duration
        
        # Update animation based on type
        match animation.type:
            AnimationType.FADE:
                _update_fade_animation(animation, progress)
            AnimationType.PULSE:
                _update_pulse_animation(animation, progress)
            AnimationType.RAINBOW:
                _update_rainbow_animation(animation, progress)
            AnimationType.FLASH:
                _update_flash_animation(animation, progress)
            AnimationType.GRADIENT:
                _update_gradient_animation(animation, progress)
            AnimationType.SPARKLE:
                _update_sparkle_animation(animation, progress)
            AnimationType.WAVE:
                _update_wave_animation(animation, progress)
            AnimationType.MESH_POINT:
                _update_mesh_point_animation(animation, progress)
    
    # Remove completed animations
    for animation_id in completed_animations:
        var animation = active_animations[animation_id]
        
        # Apply final state
        if animation.has("target_id") and animation.has("current_color"):
            emit_signal("color_updated", animation.target_id, animation.current_color)
        
        # Remove animation
        active_animations.erase(animation_id)
        
        # Signal completion
        emit_signal("animation_completed", animation_id, animation.type)

func _sync_colors():
    # Sync colors with other systems if available
    if color_system:
        # Get any color updates from color system
        # Note: In a full implementation, this would be more sophisticated
        pass

# ----- ANIMATION UPDATE METHODS -----
func _update_fade_animation(animation, progress: float):
    var start_color = animation.start_color
    var end_color = animation.end_color
    
    # Linear interpolation
    var current_color = start_color.lerp(end_color, progress)
    animation.current_color = current_color
    
    # Apply to target
    if animation.has("target_id"):
        emit_signal("color_updated", animation.target_id, current_color)

func _update_pulse_animation(animation, progress: float):
    var base_color = animation.base_color
    var pulse_color = animation.pulse_color
    var frequency = animation.pulse_frequency
    
    # Calculate pulse factor (0 to 1 to 0)
    var pulse_progress = sin(progress * TAU * frequency) * 0.5 + 0.5
    pulse_progress = pulse_progress * animation.intensity
    
    # Interpolate between base and pulse color
    var current_color = base_color.lerp(pulse_color, pulse_progress)
    animation.current_color = current_color
    
    # Apply to target
    if animation.has("target_id"):
        emit_signal("color_updated", animation.target_id, current_color)

func _update_rainbow_animation(animation, progress: float):
    var speed = animation.rainbow_speed
    var saturation = animation.saturation
    var value = animation.value
    
    # Calculate hue based on progress and speed
    var hue = fmod(progress * speed, 1.0)
    
    # Create color from HSV
    var current_color = Color.from_hsv(hue, saturation, value)
    animation.current_color = current_color
    
    # Apply to target
    if animation.has("target_id"):
        emit_signal("color_updated", animation.target_id, current_color)

func _update_flash_animation(animation, progress: float):
    var base_color = animation.base_color
    var flash_color = animation.flash_color
    var flash_count = animation.flash_count
    
    # Calculate flash factor (0 or 1 based on time)
    var phase = fmod(progress * flash_count, 1.0)
    var flash_active = phase < 0.5
    
    # Choose appropriate color
    var current_color = flash_active ? flash_color : base_color
    animation.current_color = current_color
    
    # Apply to target
    if animation.has("target_id"):
        emit_signal("color_updated", animation.target_id, current_color)

func _update_gradient_animation(animation, progress: float):
    var colors = animation.gradient_colors
    var positions = animation.gradient_positions
    
    # Find the two colors to interpolate between
    var index = 0
    while index < positions.size() - 1 and progress > positions[index + 1]:
        index += 1
    
    # Calculate local progress between these two points
    var local_progress = 0.0
    if index < positions.size() - 1:
        local_progress = (progress - positions[index]) / (positions[index + 1] - positions[index])
    
    # Interpolate between colors
    var start_color = colors[index]
    var end_color = colors[min(index + 1, colors.size() - 1)]
    var current_color = start_color.lerp(end_color, local_progress)
    
    animation.current_color = current_color
    
    # Apply to target
    if animation.has("target_id"):
        emit_signal("color_updated", animation.target_id, current_color)

func _update_sparkle_animation(animation, progress: float):
    var base_color = animation.base_color
    var sparkle_color = animation.sparkle_color
    var sparkle_count = animation.sparkle_count
    
    # Generate random sparkles
    var current_color = base_color
    var random_value = randf()
    
    # Apply sparkle if random value falls within threshold
    var sparkle_threshold = 0.1 * animation.intensity
    
    if random_value < sparkle_threshold:
        # Apply sparkle color
        current_color = sparkle_color
    
    animation.current_color = current_color
    
    # Apply to target
    if animation.has("target_id"):
        emit_signal("color_updated", animation.target_id, current_color)

func _update_wave_animation(animation, progress: float):
    var base_color = animation.base_color
    var wave_color = animation.wave_color
    var wave_frequency = animation.wave_frequency
    var wave_phase = animation.wave_phase
    
    # Calculate wave factor
    var wave_progress = sin((progress * wave_frequency + wave_phase) * TAU) * 0.5 + 0.5
    
    # Interpolate color
    var current_color = base_color.lerp(wave_color, wave_progress * animation.intensity)
    animation.current_color = current_color
    
    # Apply to target
    if animation.has("target_id"):
        emit_signal("color_updated", animation.target_id, current_color)

func _update_mesh_point_animation(animation, progress: float):
    var mesh_type = animation.mesh_type
    var base_color = animation.base_color
    var highlight_color = animation.highlight_color
    
    # Calculate highlight intensity based on mesh type
    var intensity = animation.intensity
    match mesh_type:
        "center":
            # Centers pulse with high intensity
            intensity = sin(progress * TAU * 3.0) * 0.5 + 0.5
        "edge":
            # Edges pulse with medium intensity
            intensity = sin(progress * TAU * 2.0) * 0.4 + 0.4
        "corner":
            # Corners pulse with lower intensity but higher base
            intensity = sin(progress * TAU * 1.5) * 0.3 + 0.6
    
    # Apply intensity scaling from animation
    intensity *= animation.intensity
    
    # Interpolate color
    var current_color = base_color.lerp(highlight_color, intensity)
    animation.current_color = current_color
    
    # Apply to target
    if animation.has("target_id"):
        emit_signal("color_updated", animation.target_id, current_color)
    
    # Emit frequency activation at certain intervals
    if progress > animation.last_activation_time + 0.2:
        animation.last_activation_time = progress
        emit_signal("frequency_activated", animation.frequency, mesh_type)

# ----- ANIMATION CREATION METHODS -----
func start_fade_animation(target_id, start_color: Color, end_color: Color, duration: float = default_duration) -> int:
    # Create a fade animation
    var animation_id = _get_next_animation_id()
    
    active_animations[animation_id] = {
        "type": AnimationType.FADE,
        "target_id": target_id,
        "start_color": start_color,
        "end_color": end_color,
        "current_color": start_color,
        "duration": duration,
        "elapsed_time": 0.0
    }
    
    emit_signal("animation_started", animation_id, AnimationType.FADE)
    
    return animation_id

func start_pulse_animation(target_id, base_color: Color, pulse_color: Color, duration: float = default_duration, frequency: float = 2.0, intensity: float = 0.7) -> int:
    # Create a pulse animation
    var animation_id = _get_next_animation_id()
    
    active_animations[animation_id] = {
        "type": AnimationType.PULSE,
        "target_id": target_id,
        "base_color": base_color,
        "pulse_color": pulse_color,
        "current_color": base_color,
        "pulse_frequency": frequency,
        "intensity": intensity,
        "duration": duration,
        "elapsed_time": 0.0
    }
    
    emit_signal("animation_started", animation_id, AnimationType.PULSE)
    
    return animation_id

func start_rainbow_animation(target_id, duration: float = default_duration, speed: float = 1.0, saturation: float = 0.8, value: float = 0.9) -> int:
    # Create a rainbow animation
    var animation_id = _get_next_animation_id()
    
    active_animations[animation_id] = {
        "type": AnimationType.RAINBOW,
        "target_id": target_id,
        "rainbow_speed": speed,
        "saturation": saturation,
        "value": value,
        "current_color": Color.from_hsv(0, saturation, value),
        "duration": duration,
        "elapsed_time": 0.0
    }
    
    emit_signal("animation_started", animation_id, AnimationType.RAINBOW)
    
    return animation_id

func start_flash_animation(target_id, base_color: Color, flash_color: Color, duration: float = default_duration, flash_count: int = 3) -> int:
    # Create a flash animation
    var animation_id = _get_next_animation_id()
    
    active_animations[animation_id] = {
        "type": AnimationType.FLASH,
        "target_id": target_id,
        "base_color": base_color,
        "flash_color": flash_color,
        "current_color": base_color,
        "flash_count": flash_count,
        "duration": duration,
        "elapsed_time": 0.0
    }
    
    emit_signal("animation_started", animation_id, AnimationType.FLASH)
    
    return animation_id

func start_gradient_animation(target_id, colors: Array, positions: Array = [], duration: float = default_duration) -> int:
    # Create a gradient animation
    var animation_id = _get_next_animation_id()
    
    # If positions not provided, distribute evenly
    var pos = positions
    if pos.size() != colors.size():
        pos = []
        for i in range(colors.size()):
            pos.append(float(i) / max(1, colors.size() - 1))
    
    active_animations[animation_id] = {
        "type": AnimationType.GRADIENT,
        "target_id": target_id,
        "gradient_colors": colors,
        "gradient_positions": pos,
        "current_color": colors[0],
        "duration": duration,
        "elapsed_time": 0.0
    }
    
    emit_signal("animation_started", animation_id, AnimationType.GRADIENT)
    
    return animation_id

func start_sparkle_animation(target_id, base_color: Color, sparkle_color: Color, duration: float = default_duration, sparkle_count: int = 10, intensity: float = 0.7) -> int:
    # Create a sparkle animation
    var animation_id = _get_next_animation_id()
    
    active_animations[animation_id] = {
        "type": AnimationType.SPARKLE,
        "target_id": target_id,
        "base_color": base_color,
        "sparkle_color": sparkle_color,
        "current_color": base_color,
        "sparkle_count": sparkle_count,
        "intensity": intensity,
        "duration": duration,
        "elapsed_time": 0.0
    }
    
    emit_signal("animation_started", animation_id, AnimationType.SPARKLE)
    
    return animation_id

func start_wave_animation(target_id, base_color: Color, wave_color: Color, duration: float = default_duration, frequency: float = 1.0, phase: float = 0.0, intensity: float = 0.7) -> int:
    # Create a wave animation
    var animation_id = _get_next_animation_id()
    
    active_animations[animation_id] = {
        "type": AnimationType.WAVE,
        "target_id": target_id,
        "base_color": base_color,
        "wave_color": wave_color,
        "current_color": base_color,
        "wave_frequency": frequency,
        "wave_phase": phase,
        "intensity": intensity,
        "duration": duration,
        "elapsed_time": 0.0
    }
    
    emit_signal("animation_started", animation_id, AnimationType.WAVE)
    
    return animation_id

func start_mesh_point_animation(target_id, frequency: int, mesh_type: String, duration: float = default_duration, intensity: float = 0.8) -> int:
    # Create a mesh point animation
    var animation_id = _get_next_animation_id()
    
    # Determine colors based on mesh type
    var base_color = Color(0.2, 0.2, 0.2)
    var highlight_color = Color(1.0, 1.0, 1.0)
    
    match mesh_type:
        "center":
            base_color = Color(0.1, 0.1, 0.6)
            highlight_color = Color(0.5, 0.5, 1.0)
        "edge":
            base_color = Color(0.1, 0.4, 0.4)
            highlight_color = Color(0.3, 0.9, 0.9)
        "corner":
            base_color = Color(0.5, 0.4, 0.1)
            highlight_color = Color(0.9, 0.8, 0.2)
    
    # If we have color_system, get proper colors
    if color_system:
        if color_system.has_method("get_color_for_frequency"):
            base_color = color_system.get_color_for_frequency(frequency)
        
        # Brighten for highlight
        highlight_color = base_color.lightened(0.5)
    
    active_animations[animation_id] = {
        "type": AnimationType.MESH_POINT,
        "target_id": target_id,
        "mesh_type": mesh_type,
        "frequency": frequency,
        "base_color": base_color,
        "highlight_color": highlight_color,
        "current_color": base_color,
        "intensity": intensity,
        "duration": duration,
        "elapsed_time": 0.0,
        "last_activation_time": 0.0
    }
    
    emit_signal("animation_started", animation_id, AnimationType.MESH_POINT)
    
    return animation_id

func stop_animation(animation_id: int) -> bool:
    if active_animations.has(animation_id):
        active_animations.erase(animation_id)
        return true
    
    return false

func stop_all_animations():
    active_animations.clear()

func _get_next_animation_id() -> int:
    last_animation_id += 1
    
    # Cap to prevent overflow
    if last_animation_id > 1000000:
        last_animation_id = 1
    
    return last_animation_id

# ----- COLOR MANAGEMENT -----
func get_color_for_frequency(frequency: int) -> Color:
    # Use color system if available
    if color_system and color_system.has_method("get_color_for_frequency"):
        return color_system.get_color_for_frequency(frequency)
    
    # Use internal color map
    if color_map.has(frequency):
        return color_map[frequency]
    
    # Calculate a color based on frequency
    var hue = (frequency % 360) / 360.0
    return Color.from_hsv(hue, 0.8, 0.9)

func get_turn_color(turn_number: int) -> Color:
    var index = (turn_number - 1) % turn_color_palette.size()
    return turn_color_palette[index]

func get_symbol_color(symbol: String) -> Color:
    # Get a color for a specific symbol
    if SYMBOL_FREQUENCIES.has(symbol):
        var frequency = SYMBOL_FREQUENCIES[symbol]
        return get_color_for_frequency(frequency)
    
    # Default color
    return Color(0.7, 0.7, 0.7)

# ----- TEXT COLORIZATION -----
func colorize_text(text: String, frequency: int = -1) -> String:
    # Use base frequency if none provided
    var freq = frequency if frequency > 0 else base_frequency
    
    # Use color system if available
    if color_system and color_system.has_method("colorize_line"):
        return color_system.colorize_line(text, freq)
    
    # Simple fallback: just colorize the whole text with frequency color
    var color = get_color_for_frequency(freq)
    var hex_color = color.to_html(false)
    
    return "[color=#" + hex_color + "]" + text + "[/color]"

func colorize_symbols(text: String) -> String:
    # Apply colors to specific symbols in text
    var result = text
    
    # Handle multi-character symbols first
    if text.find("###") != -1:
        var color = get_symbol_color("###")
        var hex_color = color.to_html(false)
        result = result.replace("###", "[color=#" + hex_color + "]###[/color]")
    
    if text.find("##") != -1:
        var color = get_symbol_color("##")
        var hex_color = color.to_html(false)
        result = result.replace("##", "[color=#" + hex_color + "]##[/color]")
    
    # Handle single character symbols
    for symbol in SYMBOL_FREQUENCIES.keys():
        if symbol.length() == 1 and text.find(symbol) != -1:
            var color = get_symbol_color(symbol)
            var hex_color = color.to_html(false)
            result = result.replace(symbol, "[color=#" + hex_color + "]" + symbol + "[/color]")
    
    return result

func create_gradient_text(text: String, start_freq: int, end_freq: int) -> String:
    # Use color system if available
    if color_system and color_system.has_method("get_gradient_text"):
        return color_system.get_gradient_text(text, start_freq, end_freq)
    
    # Fallback gradient using RichTextLabel BBCode
    var start_color = get_color_for_frequency(start_freq)
    var end_color = get_color_for_frequency(end_freq)
    
    var start_hex = start_color.to_html(false)
    var end_hex = end_color.to_html(false)
    
    return "[gradient start=#" + start_hex + " end=#" + end_hex + "]" + text + "[/gradient]"

# ----- FREQUENCY MANAGEMENT -----
func find_closest_harmonic(frequency: int) -> int:
    # Find the closest harmonic frequency
    var closest = HARMONIC_FREQUENCIES.PRIMARY[0]
    var min_distance = abs(frequency - closest)
    
    # Check primary harmonics
    for freq in HARMONIC_FREQUENCIES.PRIMARY:
        var distance = abs(frequency - freq)
        if distance < min_distance:
            min_distance = distance
            closest = freq
    
    # Check secondary harmonics
    for freq in HARMONIC_FREQUENCIES.SECONDARY:
        var distance = abs(frequency - freq)
        if distance < min_distance:
            min_distance = distance
            closest = freq
    
    return closest

func create_mesh_point_colors() -> Dictionary:
    # Create colors for mesh points
    var result = {
        "centers": [],
        "edges": [],
        "corners": []
    }
    
    for center in MESH_POINTS.CENTERS:
        result.centers.append(get_color_for_frequency(center))
    
    for edge in MESH_POINTS.EDGES:
        result.edges.append(get_color_for_frequency(edge))
    
    for corner in MESH_POINTS.CORNERS:
        result.corners.append(get_color_for_frequency(corner))
    
    return result

# ----- TURN MANAGEMENT -----
func update_turn(turn_number: int, total: int = 12):
    current_turn = turn_number
    total_turns = total
    
    # Update turn color palette if total changed
    if turn_color_palette.size() != total:
        turn_color_palette = []
        for i in range(total):
            var t = i + 1
            var hue = (t - 1) / float(total)
            var turn_color = Color.from_hsv(hue, 0.8, 0.9)
            turn_color_palette.append(turn_color)
    
    # Update frequency system based on turn
    _adjust_frequencies_for_turn(turn_number)

func _adjust_frequencies_for_turn(turn_number: int):
    # Adjust base frequency based on turn
    var turn_frequency = base_frequency + ((turn_number - 1) * 33)
    
    # Update all active animations
    for animation_id in active_animations:
        var animation = active_animations[animation_id]
        
        # Adjust frequency-based animations
        if animation.has("frequency"):
            # Scale frequency based on turn
            animation.frequency = max(animation.frequency, turn_frequency)
        
        # Update colors if needed
        if animation.has("base_color"):
            # Add turn color influence
            var turn_color = get_turn_color(turn_number)
            animation.base_color = animation.base_color.lerp(turn_color, 0.3)

# ----- PUBLIC API -----
func animate_line(line_text: String, target_id, animation_type: int = AnimationType.PULSE, duration: float = default_duration) -> int:
    # Calculate a frequency for the line
    var frequency = base_frequency
    
    # Count special symbols
    for symbol in SYMBOL_FREQUENCIES:
        if line_text.find(symbol) != -1:
            frequency += SYMBOL_FREQUENCIES[symbol]
    
    # Create appropriate animation
    match animation_type:
        AnimationType.FADE:
            var start_color = get_color_for_frequency(frequency)
            var end_color = get_color_for_frequency(find_closest_harmonic(frequency))
            return start_fade_animation(target_id, start_color, end_color, duration)
            
        AnimationType.PULSE:
            var base_color = get_color_for_frequency(frequency)
            var pulse_color = base_color.lightened(0.3)
            return start_pulse_animation(target_id, base_color, pulse_color, duration)
            
        AnimationType.RAINBOW:
            return start_rainbow_animation(target_id, duration)
            
        AnimationType.FLASH:
            var base_color = get_color_for_frequency(frequency)
            var flash_color = Color(1, 1, 1)
            return start_flash_animation(target_id, base_color, flash_color, duration)
            
        AnimationType.GRADIENT:
            var colors = []
            colors.append(get_color_for_frequency(frequency))
            colors.append(get_color_for_frequency(find_closest_harmonic(frequency)))
            colors.append(get_turn_color(current_turn))
            return start_gradient_animation(target_id, colors, [], duration)
            
        AnimationType.SPARKLE:
            var base_color = get_color_for_frequency(frequency)
            var sparkle_color = Color(1, 1, 1)
            return start_sparkle_animation(target_id, base_color, sparkle_color, duration)
            
        AnimationType.WAVE:
            var base_color = get_color_for_frequency(frequency)
            var wave_color = get_turn_color(current_turn)
            return start_wave_animation(target_id, base_color, wave_color, duration)
            
        AnimationType.MESH_POINT:
            # Determine mesh type
            var mesh_type = "edge"
            if MESH_POINTS.CENTERS.has(frequency):
                mesh_type = "center"
            elif MESH_POINTS.CORNERS.has(frequency):
                mesh_type = "corner"
            return start_mesh_point_animation(target_id, frequency, mesh_type, duration)
    
    return -1

func get_animation_info(animation_id: int) -> Dictionary:
    if active_animations.has(animation_id):
        var animation = active_animations[animation_id]
        
        return {
            "id": animation_id,
            "type": animation.type,
            "progress": animation.elapsed_time / animation.duration,
            "target_id": animation.get("target_id", ""),
            "current_color": animation.get("current_color", Color.WHITE)
        }
    
    return {}