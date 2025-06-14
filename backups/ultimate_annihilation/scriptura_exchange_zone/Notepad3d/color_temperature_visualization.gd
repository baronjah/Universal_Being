extends Node

class_name ColorTemperatureVisualization

# Constants for color temperature
const TEMPERATURE_RANGES = {
    "ULTRAVIOLET": {
        "min_temp": -273,
        "max_temp": -100,
        "min_color": Color(0.3, 0.0, 0.5, 1.0),  # Deep purple
        "max_color": Color(0.5, 0.0, 0.8, 1.0)   # Bright purple
    },
    "DEEP_BLUE": {
        "min_temp": -100,
        "max_temp": 0,
        "min_color": Color(0.0, 0.0, 0.8, 1.0),  # Deep blue
        "max_color": Color(0.0, 0.4, 1.0, 1.0)   # Bright blue
    },
    "BLUE": {
        "min_temp": 0,
        "max_temp": 15,
        "min_color": Color(0.0, 0.4, 1.0, 1.0),  # Bright blue
        "max_color": Color(0.4, 0.6, 1.0, 1.0)   # Light blue
    },
    "COOL": {
        "min_temp": 15,
        "max_temp": 25,
        "min_color": Color(0.4, 0.6, 1.0, 1.0),  # Light blue
        "max_color": Color(0.7, 0.7, 0.9, 1.0)   # Pale blue
    },
    "NEUTRAL": {
        "min_temp": 25,
        "max_temp": 35,
        "min_color": Color(0.7, 0.7, 0.9, 1.0),  # Pale blue
        "max_color": Color(0.9, 0.9, 0.9, 1.0)   # White/gray
    },
    "WARM": {
        "min_temp": 35,
        "max_temp": 70,
        "min_color": Color(0.9, 0.9, 0.7, 1.0),  # Pale yellow
        "max_color": Color(1.0, 0.8, 0.4, 1.0)   # Yellow-orange
    },
    "HOT": {
        "min_temp": 70,
        "max_temp": 200,
        "min_color": Color(1.0, 0.7, 0.2, 1.0),  # Orange
        "max_color": Color(1.0, 0.4, 0.0, 1.0)   # Deep orange
    },
    "VERY_HOT": {
        "min_temp": 200,
        "max_temp": 1000,
        "min_color": Color(1.0, 0.4, 0.0, 1.0),  # Deep orange
        "max_color": Color(1.0, 0.0, 0.0, 1.0)   # Red
    },
    "EXTREME": {
        "min_temp": 1000,
        "max_temp": 10000,
        "min_color": Color(1.0, 0.0, 0.0, 1.0),  # Red
        "max_color": Color(1.0, 1.0, 1.0, 1.0)   # White (plasma)
    },
    "INFRARED": {
        "min_temp": -50,  # Special case for infrared visualization
        "max_temp": 100,  # Special case for infrared visualization
        "min_color": Color(0.5, 0.0, 0.0, 1.0),  # Dark red
        "max_color": Color(1.0, 0.3, 0.3, 1.0)   # Bright red
    }
}

# Lucky frequencies that resonate with the universe
const LUCKY_FREQUENCIES = [9, 33, 89, 99, 333, 389, 555, 777, 999]

# Temperature to frequency mappings
const TEMP_TO_FREQ = {
    "ULTRAVIOLET": 999,
    "DEEP_BLUE": 777,
    "BLUE": 555,
    "COOL": 389,
    "NEUTRAL": 333,
    "WARM": 99,
    "HOT": 89,
    "VERY_HOT": 33,
    "EXTREME": 9,
    "INFRARED": 33
}

# Visualization properties
var current_temperature = 25  # Celsius
var current_temperature_name = "NEUTRAL"
var current_temperature_color = Color(0.9, 0.9, 0.9, 1.0)
var current_frequency = 333
var visualization_mode = "NORMAL"  # NORMAL, INFRARED, ULTRAVIOLET
var energy_level = 0.5  # 0.0 to 1.0

# Connection to terminal visual bridge
var terminal_bridge = null

# Visual components
var canvas = null
var temperature_gradient = null
var frequency_wave = null
var energy_particles = []

# Signal for temperature change
signal temperature_changed(temp_value, temp_name, color, frequency)
signal frequency_resonance(frequency, amplitude, resonance_type)
signal energy_state_changed(energy_level, state_name)

func _init():
    # Set up visual components
    _setup_visualization()
    
    # Connect to TerminalVisualBridge if available
    _connect_to_terminal_bridge()

func _setup_visualization():
    # Create canvas
    canvas = Control.new()
    canvas.set_name("ColorTemperatureCanvas")
    canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    canvas.connect("draw", Callable(self, "_draw_visualization"))
    
    # Create temperature gradient
    temperature_gradient = Gradient.new()
    _update_temperature_gradient()
    
    # Set up frequency wave data
    frequency_wave = {
        "frequency": current_frequency,
        "amplitude": 0.5,
        "phase": 0.0,
        "color": current_temperature_color
    }
    
    # Create energy particles
    _create_energy_particles()

func _create_energy_particles():
    energy_particles.clear()
    
    var particle_count = 50
    for i in range(particle_count):
        var particle = {
            "position": Vector2(randf(), randf()),
            "velocity": Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(0.01, 0.05),
            "size": randf_range(1.0, 5.0),
            "color": current_temperature_color,
            "energy": randf(),
            "lifetime": randf_range(0.5, 2.0)
        }
        
        energy_particles.append(particle)

func _connect_to_terminal_bridge():
    # Check if TerminalVisualBridge is available
    if ClassDB.class_exists("TerminalVisualBridge"):
        terminal_bridge = load("res://terminal_visual_bridge.gd").new()
        terminal_bridge.connect("color_temperature_changed", 
                                Callable(self, "_on_bridge_temperature_changed"))
        print("Connected to TerminalVisualBridge")
    else:
        print("TerminalVisualBridge not available, creating stub")
        # We'll continue without the bridge

func _process(delta):
    # Update frequency wave
    frequency_wave.phase += delta * frequency_wave.frequency * 0.01
    if frequency_wave.phase > TAU:
        frequency_wave.phase -= TAU
    
    # Update energy particles
    _update_energy_particles(delta)
    
    # Check for resonance
    _check_frequency_resonance()
    
    # Update canvas
    if canvas:
        canvas.queue_redraw()

func _update_energy_particles(delta):
    for particle in energy_particles:
        # Update position
        particle.position += particle.velocity * delta * energy_level * 60.0
        
        # Wrap around edges
        particle.position.x = fmod(particle.position.x + 1.0, 1.0)
        particle.position.y = fmod(particle.position.y + 1.0, 1.0)
        
        # Update lifetime
        particle.lifetime -= delta
        if particle.lifetime <= 0:
            # Reset particle
            particle.position = Vector2(randf(), randf())
            particle.velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(0.01, 0.05)
            particle.size = randf_range(1.0, 5.0)
            particle.color = current_temperature_color
            particle.lifetime = randf_range(0.5, 2.0)

func _check_frequency_resonance():
    # Check if current frequency is close to a lucky frequency
    for lucky_freq in LUCKY_FREQUENCIES:
        var freq_diff = abs(current_frequency - lucky_freq)
        
        if freq_diff < 5:
            # Strong resonance
            var resonance_strength = 1.0 - (freq_diff / 5.0)
            emit_signal("frequency_resonance", lucky_freq, resonance_strength, "STRONG")
            return
        elif freq_diff < 10:
            # Medium resonance
            var resonance_strength = 1.0 - (freq_diff / 10.0)
            emit_signal("frequency_resonance", lucky_freq, resonance_strength, "MEDIUM")
            return
        elif freq_diff < 20:
            # Weak resonance
            var resonance_strength = 1.0 - (freq_diff / 20.0)
            emit_signal("frequency_resonance", lucky_freq, resonance_strength, "WEAK")
            return

func _update_temperature_gradient():
    temperature_gradient.clear_points()
    
    var range_name = _get_temperature_range_name(current_temperature)
    var range_data = TEMPERATURE_RANGES[range_name]
    
    var t = inverse_lerp(range_data.min_temp, range_data.max_temp, current_temperature)
    t = clamp(t, 0.0, 1.0)
    
    current_temperature_color = range_data.min_color.linear_interpolate(range_data.max_color, t)
    current_temperature_name = range_name
    current_frequency = TEMP_TO_FREQ[range_name]
    
    # Add gradient points
    temperature_gradient.add_point(0.0, current_temperature_color.darkened(0.5))
    temperature_gradient.add_point(0.5, current_temperature_color)
    temperature_gradient.add_point(1.0, current_temperature_color.lightened(0.3))
    
    # Update frequency wave color
    frequency_wave.color = current_temperature_color

func _get_temperature_range_name(temp):
    if visualization_mode == "INFRARED":
        return "INFRARED"
    elif visualization_mode == "ULTRAVIOLET":
        return "ULTRAVIOLET"
    
    # Normal temperature range lookup
    for range_name in TEMPERATURE_RANGES.keys():
        if range_name == "INFRARED" or range_name == "ULTRAVIOLET":
            continue  # Skip special visualization modes
        
        var range_data = TEMPERATURE_RANGES[range_name]
        if temp >= range_data.min_temp and temp < range_data.max_temp:
            return range_name
    
    # Default to NEUTRAL if no range found
    return "NEUTRAL"

func _draw_visualization():
    if not canvas:
        return
    
    var size = canvas.get_size()
    
    # Draw background based on temperature
    _draw_temperature_background(size)
    
    # Draw frequency wave
    _draw_frequency_wave(size)
    
    # Draw energy particles
    _draw_energy_particles(size)
    
    # Draw temperature scale
    _draw_temperature_scale(size)
    
    # Draw frequency indicator
    _draw_frequency_indicator(size)

func _draw_temperature_background(size):
    # Draw gradient background
    var gradient_rect = Rect2(0, 0, size.x, size.y)
    
    # Use temperature gradient
    var colors = [
        current_temperature_color.darkened(0.7),
        current_temperature_color,
        current_temperature_color.lightened(0.3)
    ]
    
    var points = [
        Vector2(0, 0),
        Vector2(size.x * 0.5, size.y * 0.5),
        Vector2(size.x, size.y)
    ]
    
    # Create a radial gradient effect
    var center = size * 0.5
    var radius = size.length() * 0.5
    
    canvas.draw_circle(center, radius, colors[0])
    canvas.draw_circle(center, radius * 0.7, colors[1])
    canvas.draw_circle(center, radius * 0.3, colors[2])

func _draw_frequency_wave(size):
    var points = []
    var segments = 100
    var amplitude = size.y * 0.1 * frequency_wave.amplitude
    var wave_y = size.y * 0.5
    
    for i in range(segments + 1):
        var x = size.x * (float(i) / float(segments))
        var phase_offset = frequency_wave.phase + (float(i) / float(segments)) * TAU
        var y = wave_y + sin(phase_offset) * amplitude
        
        points.append(Vector2(x, y))
    
    # Draw the wave
    for i in range(segments):
        var line_color = frequency_wave.color
        line_color.a = 0.7
        canvas.draw_line(points[i], points[i+1], line_color, 2.0)

func _draw_energy_particles(size):
    for particle in energy_particles:
        var pos = Vector2(particle.position.x * size.x, particle.position.y * size.y)
        var particle_color = particle.color
        particle_color.a = clamp(particle.lifetime, 0.0, 1.0)
        
        var particle_size = particle.size * energy_level
        canvas.draw_circle(pos, particle_size, particle_color)

func _draw_temperature_scale(size):
    var scale_width = size.x * 0.8
    var scale_height = size.y * 0.03
    var scale_x = size.x * 0.1
    var scale_y = size.y * 0.9
    
    # Draw temperature scale background
    var scale_rect = Rect2(scale_x, scale_y, scale_width, scale_height)
    canvas.draw_rect(scale_rect, Color(0.2, 0.2, 0.2, 0.7))
    
    # Draw temperature indicator
    var temp_range = 300  # -100 to 200 C range
    var norm_temp = (current_temperature + 100) / temp_range  # Normalize to 0-1
    var indicator_x = scale_x + scale_width * clamp(norm_temp, 0.0, 1.0)
    
    canvas.draw_rect(Rect2(indicator_x - 2, scale_y - 5, 4, scale_height + 10), 
                    current_temperature_color)
    
    # Draw temperature value text
    var font_color = Color(1, 1, 1, 0.9)
    var temp_text = str(current_temperature) + "°C - " + current_temperature_name
    
    # Drawing text directly not supported in GDScript 4, would need a Label node
    # Instead, draw a text indicator rectangle
    var text_rect = Rect2(indicator_x - 40, scale_y - 25, 80, 15)
    canvas.draw_rect(text_rect, Color(0.1, 0.1, 0.1, 0.7))
    canvas.draw_rect(text_rect, current_temperature_color, false, 1)

func _draw_frequency_indicator(size):
    var indicator_width = size.x * 0.15
    var indicator_height = size.y * 0.04
    var indicator_x = size.x * 0.05
    var indicator_y = size.y * 0.05
    
    # Draw frequency indicator background
    var indicator_rect = Rect2(indicator_x, indicator_y, indicator_width, indicator_height)
    canvas.draw_rect(indicator_rect, Color(0.1, 0.1, 0.1, 0.7))
    
    # Draw frequency value
    var freq_width = indicator_width * (current_frequency / 1000.0)  # Normalize to 0-1000 Hz
    var freq_rect = Rect2(indicator_x, indicator_y, freq_width, indicator_height)
    canvas.draw_rect(freq_rect, current_temperature_color)
    
    # Draw frequency text indicator
    var text_rect = Rect2(indicator_x + indicator_width + 10, indicator_y, 80, indicator_height)
    canvas.draw_rect(text_rect, Color(0.1, 0.1, 0.1, 0.7))
    canvas.draw_rect(text_rect, current_temperature_color, false, 1)

func set_temperature(temp_value):
    current_temperature = temp_value
    
    # Update visualization
    _update_temperature_gradient()
    
    # Update energy state based on temperature
    var temp_range = TEMPERATURE_RANGES[current_temperature_name]
    var normalized_temp = inverse_lerp(temp_range.min_temp, temp_range.max_temp, current_temperature)
    energy_level = normalized_temp
    
    # Update energy state name
    var energy_state = "BALANCED"
    if current_temperature < 0:
        energy_state = "FROZEN"
    elif current_temperature < 15:
        energy_state = "SLOW"
    elif current_temperature < 25:
        energy_state = "CALM"
    elif current_temperature < 35:
        energy_state = "BALANCED"
    elif current_temperature < 70:
        energy_state = "ACTIVE"
    elif current_temperature < 200:
        energy_state = "ENERGETIC"
    elif current_temperature < 1000:
        energy_state = "INTENSE"
    else:
        energy_state = "TRANSCENDENT"
    
    # Emit signal
    emit_signal("temperature_changed", 
                current_temperature, 
                current_temperature_name, 
                current_temperature_color, 
                current_frequency)
    
    emit_signal("energy_state_changed", energy_level, energy_state)
    
    # Update terminal bridge if available
    if terminal_bridge and terminal_bridge.has_method("set_temperature"):
        terminal_bridge.set_temperature(current_temperature_name)
    
    return true

func set_temperature_by_name(temp_name):
    if TEMPERATURE_RANGES.has(temp_name):
        var temp_range = TEMPERATURE_RANGES[temp_name]
        var mid_temp = (temp_range.min_temp + temp_range.max_temp) * 0.5
        return set_temperature(mid_temp)
    
    return false

func set_frequency(freq_value):
    # Set the frequency directly
    current_frequency = freq_value
    frequency_wave.frequency = freq_value
    
    # Check for lucky frequencies and adjust if very close
    for lucky_freq in LUCKY_FREQUENCIES:
        if abs(current_frequency - lucky_freq) < 3:
            current_frequency = lucky_freq
            frequency_wave.frequency = lucky_freq
            break
    
    # Update visualization
    _check_frequency_resonance()
    
    return true

func set_visualization_mode(mode):
    if mode in ["NORMAL", "INFRARED", "ULTRAVIOLET"]:
        visualization_mode = mode
        
        # Update visualization
        _update_temperature_gradient()
        
        return true
    
    return false

func set_energy_level(level):
    energy_level = clamp(level, 0.0, 1.0)
    
    # Update energy particles
    for particle in energy_particles:
        particle.energy = energy_level
    
    # Emit signal
    var energy_state = "BALANCED"
    if energy_level < 0.2:
        energy_state = "MINIMAL"
    elif energy_level < 0.4:
        energy_state = "LOW"
    elif energy_level < 0.6:
        energy_state = "BALANCED"
    elif energy_level < 0.8:
        energy_state = "HIGH"
    else:
        energy_state = "MAXIMUM"
    
    emit_signal("energy_state_changed", energy_level, energy_state)
    
    return true

func get_temperature_color():
    return current_temperature_color

func get_temperature_name():
    return current_temperature_name

func get_frequency():
    return current_frequency

func get_energy_level():
    return energy_level

func get_energy_state():
    if energy_level < 0.2:
        return "MINIMAL"
    elif energy_level < 0.4:
        return "LOW"
    elif energy_level < 0.6:
        return "BALANCED"
    elif energy_level < 0.8:
        return "HIGH"
    else:
        return "MAXIMUM"

func _on_bridge_temperature_changed(temp_name, color, frequency):
    set_temperature_by_name(temp_name)

# Return visualization canvas for external use
func get_visualization_canvas():
    return canvas

# Compute temperature and frequency for a color
func compute_temperature_for_color(color):
    # Find closest matching temperature range
    var closest_range = "NEUTRAL"
    var closest_distance = 1.0e10
    
    for range_name in TEMPERATURE_RANGES.keys():
        if range_name == "INFRARED" or range_name == "ULTRAVIOLET":
            continue  # Skip special visualization modes
        
        var range_data = TEMPERATURE_RANGES[range_name]
        var mid_color = range_data.min_color.linear_interpolate(range_data.max_color, 0.5)
        
        var distance = _color_distance(color, mid_color)
        if distance < closest_distance:
            closest_distance = distance
            closest_range = range_name
    
    # Return temperature and frequency
    var temp_range = TEMPERATURE_RANGES[closest_range]
    var mid_temp = (temp_range.min_temp + temp_range.max_temp) * 0.5
    var freq = TEMP_TO_FREQ[closest_range]
    
    return {
        "temperature": mid_temp,
        "temperature_name": closest_range,
        "frequency": freq
    }

func _color_distance(color1, color2):
    # Simple RGB distance
    var dr = color1.r - color2.r
    var dg = color1.g - color2.g
    var db = color1.b - color2.b
    
    return sqrt(dr*dr + dg*dg + db*db)

# Generate a cosmic color map based on temperature and frequency
func generate_cosmic_color_map(base_temp, temp_range, frequency):
    var color_map = []
    var center_color = current_temperature_color
    var steps = 10
    
    for i in range(steps):
        var t = float(i) / float(steps - 1)
        var temp = base_temp + (t - 0.5) * temp_range
        var temp_name = _get_temperature_range_name(temp)
        var temp_data = TEMPERATURE_RANGES[temp_name]
        
        var temp_t = inverse_lerp(temp_data.min_temp, temp_data.max_temp, temp)
        var color = temp_data.min_color.linear_interpolate(temp_data.max_color, temp_t)
        
        # Add harmonic oscillation based on frequency
        var phase = t * TAU
        var freq_factor = sin(phase * (frequency / 100.0))
        
        # Adjust color based on frequency
        color.r += freq_factor * 0.1
        color.g += freq_factor * 0.1
        color.b += freq_factor * 0.1
        
        # Ensure color is valid
        color.r = clamp(color.r, 0.0, 1.0)
        color.g = clamp(color.g, 0.0, 1.0)
        color.b = clamp(color.b, 0.0, 1.0)
        
        color_map.append(color)
    }
    
    return color_map