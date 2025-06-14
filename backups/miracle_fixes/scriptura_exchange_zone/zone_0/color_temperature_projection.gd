class_name ColorTemperatureProjection
extends Node

# ----- COLOR CONSTANTS -----
const COLOR_TEMPERATURES = {
    "VERY_COLD": {
        "temperature": -273,
        "color": Color(0.0, 0.4, 1.0, 1.0),  # Deep blue
        "frequency": 999,
        "energy_state": "frozen"
    },
    "COLD": {
        "temperature": -100,
        "color": Color(0.4, 0.7, 1.0, 1.0),  # Light blue
        "frequency": 777,
        "energy_state": "low"
    },
    "COOL": {
        "temperature": 0,
        "color": Color(0.5, 0.5, 0.5, 1.0),  # Gray
        "frequency": 555,
        "energy_state": "neutral"
    },
    "NEUTRAL": {
        "temperature": 25,
        "color": Color(0.8, 0.8, 0.8, 1.0),  # Light gray to white
        "frequency": 389,
        "energy_state": "balanced"
    },
    "WARM": {
        "temperature": 37,
        "color": Color(1.0, 0.8, 0.4, 1.0),  # Light orange
        "frequency": 333,
        "energy_state": "active"
    },
    "HOT": {
        "temperature": 100,
        "color": Color(1.0, 0.6, 0.0, 1.0),  # Orange
        "frequency": 99,
        "energy_state": "excited"
    },
    "VERY_HOT": {
        "temperature": 1000,
        "color": Color(1.0, 0.2, 0.0, 1.0),  # Dark red-orange
        "frequency": 33,
        "energy_state": "intense"
    }
}

const LIGHT_SPECTRUM = {
    "ULTRAVIOLET": {
        "wavelength": [100, 400],  # nanometers
        "visible": false,
        "color": Color(0.5, 0.0, 1.0, 0.5),  # Purple with transparency (not visible)
        "energy": "high"
    },
    "VIOLET": {
        "wavelength": [380, 450],
        "visible": true,
        "color": Color(0.5, 0.0, 1.0, 1.0),  # Purple
        "energy": "high-visible"
    },
    "BLUE": {
        "wavelength": [450, 495],
        "visible": true,
        "color": Color(0.0, 0.0, 1.0, 1.0),  # Blue
        "energy": "medium-high"
    },
    "GREEN": {
        "wavelength": [495, 570],
        "visible": true,
        "color": Color(0.0, 1.0, 0.0, 1.0),  # Green
        "energy": "medium"
    },
    "YELLOW": {
        "wavelength": [570, 590],
        "visible": true,
        "color": Color(1.0, 1.0, 0.0, 1.0),  # Yellow
        "energy": "medium-low"
    },
    "ORANGE": {
        "wavelength": [590, 620],
        "visible": true,
        "color": Color(1.0, 0.5, 0.0, 1.0),  # Orange
        "energy": "low"
    },
    "RED": {
        "wavelength": [620, 750],
        "visible": true,
        "color": Color(1.0, 0.0, 0.0, 1.0),  # Red
        "energy": "very-low"
    },
    "INFRARED": {
        "wavelength": [750, 1000000],
        "visible": false,
        "color": Color(0.5, 0.0, 0.0, 0.5),  # Dark red with transparency (not visible)
        "energy": "thermal"
    }
}

const LUCKY_NUMBERS = [9, 33, 89, 99, 333, 389, 555, 777, 999]

# ----- COMPONENT REFERENCES -----
var terminal_bridge = null
var akashic_system = null
var color_system = null
var migration_system = null
var ethereal_bridge = null

# ----- PROJECTION STATE -----
var current_temperature = 25  # Default to NEUTRAL
var current_color_state = "NEUTRAL"
var current_light_spectrum = "GREEN"
var current_energy_level = "balanced"
var projection_mode = "standard"
var projection_intensity = 1.0
var projection_visible = true
var temperature_gradient = []

# ----- AKASHIC RECORDING -----
var projection_numbers = []
var color_pattern_numbers = []
var temperature_numbers = []
var light_spectrum_numbers = []

# ----- SIGNALS -----
signal temperature_changed(old_temp, new_temp, color)
signal color_state_changed(old_state, new_state, temperature)
signal light_spectrum_shifted(from_spectrum, to_spectrum)
signal energy_level_changed(old_level, new_level)
signal projection_mode_changed(old_mode, new_mode)
signal projection_numbers_recorded(numbers)

# ----- INITIALIZATION -----
func _ready():
    _find_components()
    _initialize_projection()
    _create_temperature_gradient()
    _record_initial_numbers()
    
    print("Color Temperature Projection initialized")

func _find_components():
    # Find TerminalBridgeConnector
    terminal_bridge = get_node_or_null("/root/TerminalBridgeConnector")
    if not terminal_bridge:
        terminal_bridge = _find_node_by_class(get_tree().root, "TerminalBridgeConnector")
    
    # Find AkashicNumberSystem
    akashic_system = get_node_or_null("/root/AkashicNumberSystem")
    if not akashic_system:
        akashic_system = _find_node_by_class(get_tree().root, "AkashicNumberSystem")
    
    # Find DimensionalColorSystem
    color_system = get_node_or_null("/root/DimensionalColorSystem")
    if not color_system:
        color_system = _find_node_by_class(get_tree().root, "DimensionalColorSystem")
    
    # Find migration components
    migration_system = get_node_or_null("/root/UnifiedMigrationSystem")
    if not migration_system:
        migration_system = _find_node_by_class(get_tree().root, "UnifiedMigrationSystem")
    
    ethereal_bridge = get_node_or_null("/root/EtherealMigrationBridge")
    if not ethereal_bridge:
        ethereal_bridge = _find_node_by_class(get_tree().root, "EtherealMigrationBridge")
    
    print("Components found: Terminal=%s, Akashic=%s, Color=%s, Migration=%s, Ethereal=%s" % [
        "Yes" if terminal_bridge else "No",
        "Yes" if akashic_system else "No",
        "Yes" if color_system else "No",
        "Yes" if migration_system else "No",
        "Yes" if ethereal_bridge else "No"
    ])

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

func _initialize_projection():
    # Set initial values
    current_temperature = COLOR_TEMPERATURES.NEUTRAL.temperature
    current_color_state = "NEUTRAL"
    current_light_spectrum = "GREEN"
    current_energy_level = COLOR_TEMPERATURES.NEUTRAL.energy_state
    
    # Register colors with color system if available
    if color_system and color_system.has_method("register_color_palette"):
        # Register temperature colors
        var temp_colors = {}
        for temp_key in COLOR_TEMPERATURES:
            temp_colors[temp_key] = COLOR_TEMPERATURES[temp_key].color
        
        color_system.register_color_palette("temperature", temp_colors)
        
        # Register light spectrum
        var spectrum_colors = {}
        for spectrum_key in LIGHT_SPECTRUM:
            if LIGHT_SPECTRUM[spectrum_key].visible:
                spectrum_colors[spectrum_key] = LIGHT_SPECTRUM[spectrum_key].color
        
        color_system.register_color_palette("spectrum", spectrum_colors)
    
    # Connect to terminal bridge if available
    if terminal_bridge:
        _synchronize_with_terminal()

func _create_temperature_gradient():
    # Create temperature gradient from coldest to hottest
    temperature_gradient = []
    
    # Sort temperature points
    var temp_points = []
    for temp_key in COLOR_TEMPERATURES:
        temp_points.append({
            "key": temp_key,
            "temperature": COLOR_TEMPERATURES[temp_key].temperature
        })
    
    # Sort by temperature
    temp_points.sort_custom(func(a, b): return a.temperature < b.temperature)
    
    # Create gradient
    for point in temp_points:
        temperature_gradient.append({
            "key": point.key,
            "temperature": COLOR_TEMPERATURES[point.key].temperature,
            "color": COLOR_TEMPERATURES[point.key].color,
            "energy_state": COLOR_TEMPERATURES[point.key].energy_state,
            "frequency": COLOR_TEMPERATURES[point.key].frequency
        })
    
    # Register with color system
    if color_system and color_system.has_method("create_gradient"):
        var from_color = temperature_gradient[0].color
        var to_color = temperature_gradient[temperature_gradient.size() - 1].color
        color_system.create_gradient("temperature", from_color, to_color, temperature_gradient.size())

func _record_initial_numbers():
    # Record initial numbers in akashic system
    if akashic_system and akashic_system.has_method("register_number"):
        # Record temperature numbers
        for temp_key in COLOR_TEMPERATURES:
            temperature_numbers.append(COLOR_TEMPERATURES[temp_key].temperature)
            temperature_numbers.append(COLOR_TEMPERATURES[temp_key].frequency)
            
            akashic_system.register_number(
                COLOR_TEMPERATURES[temp_key].temperature,
                "temp_" + temp_key
            )
            
            akashic_system.register_number(
                COLOR_TEMPERATURES[temp_key].frequency,
                "freq_" + temp_key
            )
        
        # Record light spectrum numbers
        for spectrum_key in LIGHT_SPECTRUM:
            light_spectrum_numbers.append(LIGHT_SPECTRUM[spectrum_key].wavelength[0])
            light_spectrum_numbers.append(LIGHT_SPECTRUM[spectrum_key].wavelength[1])
            
            akashic_system.register_number(
                LIGHT_SPECTRUM[spectrum_key].wavelength[0],
                "wave_min_" + spectrum_key
            )
            
            akashic_system.register_number(
                LIGHT_SPECTRUM[spectrum_key].wavelength[1],
                "wave_max_" + spectrum_key
            )
        
        # Record lucky numbers
        for lucky_num in LUCKY_NUMBERS:
            projection_numbers.append(lucky_num)
            akashic_system.register_number(lucky_num, "lucky_" + str(lucky_num))
        
        emit_signal("projection_numbers_recorded", projection_numbers)

func _synchronize_with_terminal():
    if not terminal_bridge:
        return
    
    # Get terminal state
    var terminal_temp = terminal_bridge.get_temperature_state()
    var terminal_projection = terminal_bridge.get_current_projection_state()
    
    # Synchronize temperature
    if terminal_temp != current_temperature:
        set_temperature(terminal_temp)
    
    # Synchronize projection
    projection_visible = terminal_projection.active
    
    # Connect signals
    terminal_bridge.connect("temperature_changed", _on_terminal_temperature_changed)
    terminal_bridge.connect("color_shift_detected", _on_terminal_color_shift)
    terminal_bridge.connect("projection_changed", _on_terminal_projection_changed)

# ----- TEMPERATURE AND COLOR MANAGEMENT -----
func set_temperature(temperature):
    var old_temp = current_temperature
    var old_state = current_color_state
    
    # Update temperature
    current_temperature = temperature
    
    # Find closest temperature state
    var closest_key = "NEUTRAL"
    var smallest_diff = 1000000
    
    for temp_key in COLOR_TEMPERATURES:
        var temp_diff = abs(temperature - COLOR_TEMPERATURES[temp_key].temperature)
        if temp_diff < smallest_diff:
            smallest_diff = temp_diff
            closest_key = temp_key
    
    # Set new state
    current_color_state = closest_key
    current_energy_level = COLOR_TEMPERATURES[closest_key].energy_state
    
    # Record in akashic system
    if akashic_system and akashic_system.has_method("register_number"):
        akashic_system.register_number(temperature, "current_temperature")
        akashic_system.register_number(COLOR_TEMPERATURES[closest_key].frequency, "current_frequency")
    
    # Update color system
    if color_system and color_system.has_method("set_current_color"):
        color_system.set_current_color(COLOR_TEMPERATURES[closest_key].color)
    
    # Emit signals
    emit_signal("temperature_changed", old_temp, temperature, COLOR_TEMPERATURES[closest_key].color)
    
    if old_state != closest_key:
        emit_signal("color_state_changed", old_state, closest_key, temperature)
        emit_signal("energy_level_changed", COLOR_TEMPERATURES[old_state].energy_state, current_energy_level)

func set_color_state(state_key):
    if not COLOR_TEMPERATURES.has(state_key):
        push_warning("Invalid color state: " + state_key)
        return
    
    var old_state = current_color_state
    var old_temp = current_temperature
    
    # Set new state
    current_color_state = state_key
    current_temperature = COLOR_TEMPERATURES[state_key].temperature
    current_energy_level = COLOR_TEMPERATURES[state_key].energy_state
    
    # Record in akashic system
    if akashic_system and akashic_system.has_method("register_number"):
        akashic_system.register_number(current_temperature, "current_temperature")
        akashic_system.register_number(COLOR_TEMPERATURES[state_key].frequency, "current_frequency")
    
    # Update color system
    if color_system and color_system.has_method("set_current_color"):
        color_system.set_current_color(COLOR_TEMPERATURES[state_key].color)
    
    # Update terminal bridge
    if terminal_bridge:
        terminal_bridge.adjust_temperature(current_temperature - old_temp)
    
    # Emit signals
    emit_signal("color_state_changed", old_state, state_key, current_temperature)
    emit_signal("temperature_changed", old_temp, current_temperature, COLOR_TEMPERATURES[state_key].color)
    emit_signal("energy_level_changed", COLOR_TEMPERATURES[old_state].energy_state, current_energy_level)

func set_light_spectrum(spectrum_key):
    if not LIGHT_SPECTRUM.has(spectrum_key):
        push_warning("Invalid light spectrum: " + spectrum_key)
        return
    
    var old_spectrum = current_light_spectrum
    
    # Set new spectrum
    current_light_spectrum = spectrum_key
    
    # Update color system if visible spectrum
    if LIGHT_SPECTRUM[spectrum_key].visible and color_system and color_system.has_method("set_accent_color"):
        color_system.set_accent_color(LIGHT_SPECTRUM[spectrum_key].color)
    
    # Record in akashic system
    if akashic_system and akashic_system.has_method("register_number"):
        akashic_system.register_number(LIGHT_SPECTRUM[spectrum_key].wavelength[0], "current_wavelength_min")
        akashic_system.register_number(LIGHT_SPECTRUM[spectrum_key].wavelength[1], "current_wavelength_max")
    
    # Emit signal
    emit_signal("light_spectrum_shifted", old_spectrum, spectrum_key)

func get_temperature_color(temperature):
    # Find closest temperature gradient point
    var closest_idx = 0
    var smallest_diff = 1000000
    
    for i in range(temperature_gradient.size()):
        var temp_diff = abs(temperature - temperature_gradient[i].temperature)
        if temp_diff < smallest_diff:
            smallest_diff = temp_diff
            closest_idx = i
    
    return temperature_gradient[closest_idx].color

func get_spectrum_color(spectrum_key):
    if LIGHT_SPECTRUM.has(spectrum_key):
        return LIGHT_SPECTRUM[spectrum_key].color
    return Color(1.0, 1.0, 1.0, 1.0)  # Default white

# ----- PROJECTION MANAGEMENT -----
func set_projection_mode(mode):
    var old_mode = projection_mode
    projection_mode = mode
    
    # Update terminal bridge
    if terminal_bridge:
        terminal_bridge.toggle_projection(projection_visible, mode)
    
    # Emit signal
    emit_signal("projection_mode_changed", old_mode, mode)

func set_projection_intensity(intensity):
    projection_intensity = clamp(intensity, 0.0, 2.0)
    
    # Update terminal bridge
    if terminal_bridge:
        terminal_bridge.detect_user_action("projection_toggle", {
            "active": projection_visible,
            "type": projection_mode,
            "intensity": projection_intensity
        })

func toggle_projection_visibility(visible = null):
    if visible != null:
        projection_visible = visible
    else:
        projection_visible = !projection_visible
    
    # Update terminal bridge
    if terminal_bridge:
        terminal_bridge.toggle_projection(projection_visible, projection_mode)

func get_projection_state():
    return {
        "mode": projection_mode,
        "intensity": projection_intensity,
        "visible": projection_visible,
        "temperature": current_temperature,
        "color_state": current_color_state,
        "light_spectrum": current_light_spectrum,
        "energy_level": current_energy_level
    }

# ----- AKASHIC NUMBER MANIPULATION -----
func record_color_pattern(color_names):
    # Record color pattern in akashic system
    if akashic_system and akashic_system.has_method("register_number"):
        var color_values = []
        
        for color_name in color_names:
            if COLOR_TEMPERATURES.has(color_name):
                color_values.append(COLOR_TEMPERATURES[color_name].frequency)
            elif LIGHT_SPECTRUM.has(color_name):
                var wavelength_avg = (LIGHT_SPECTRUM[color_name].wavelength[0] + LIGHT_SPECTRUM[color_name].wavelength[1]) / 2
                color_values.append(wavelength_avg)
            else:
                color_values.append(0)
        
        # Convert pattern to a single hash number
        var pattern_hash = 0
        for value in color_values:
            pattern_hash = pattern_hash * 31 + value
        
        # Find closest lucky number
        var lucky_number = _find_closest_lucky_number(pattern_hash)
        
        # Register pattern
        akashic_system.register_number(pattern_hash, "color_pattern_hash")
        akashic_system.register_number(lucky_number, "color_pattern_lucky")
        
        color_pattern_numbers.append(pattern_hash)
        projection_numbers.append(lucky_number)
        
        return {
            "pattern_hash": pattern_hash,
            "lucky_number": lucky_number,
            "color_values": color_values
        }
    
    return null

func generate_lucky_number_from_temperature():
    var temp_frequency = 0
    
    # Get frequency for current temperature
    if COLOR_TEMPERATURES.has(current_color_state):
        temp_frequency = COLOR_TEMPERATURES[current_color_state].frequency
    else:
        for temp_key in COLOR_TEMPERATURES:
            var temp_diff = abs(current_temperature - COLOR_TEMPERATURES[temp_key].temperature)
            if temp_diff < 10:
                temp_frequency = COLOR_TEMPERATURES[temp_key].frequency
                break
    
    if temp_frequency == 0:
        temp_frequency = 389  # Default to neutral
    
    # Record in akashic system
    if akashic_system and akashic_system.has_method("register_number"):
        akashic_system.register_number(temp_frequency, "temperature_frequency")
        projection_numbers.append(temp_frequency)
        
        return temp_frequency
    
    return 0

func _find_closest_lucky_number(value):
    var closest = LUCKY_NUMBERS[0]
    var smallest_diff = abs(value - closest)
    
    for lucky in LUCKY_NUMBERS:
        var diff = abs(value - lucky)
        if diff < smallest_diff:
            smallest_diff = diff
            closest = lucky
    
    return closest

# ----- MIGRATION INTEGRATION -----
func integrate_with_migration_system():
    if not migration_system or not ethereal_bridge:
        return {
            "success": false,
            "error": "Migration components not available",
            "migration_system": migration_system != null,
            "ethereal_bridge": ethereal_bridge != null
        }
    
    # Create color temperature reference in migration system
    var temperature_data = {
        "temperatures": {},
        "lucky_numbers": LUCKY_NUMBERS,
        "light_spectrum": {},
        "current_state": {
            "temperature": current_temperature,
            "color_state": current_color_state,
            "light_spectrum": current_light_spectrum,
            "energy_level": current_energy_level
        }
    }
    
    # Add temperature data
    for temp_key in COLOR_TEMPERATURES:
        temperature_data.temperatures[temp_key] = {
            "temperature": COLOR_TEMPERATURES[temp_key].temperature,
            "frequency": COLOR_TEMPERATURES[temp_key].frequency,
            "energy_state": COLOR_TEMPERATURES[temp_key].energy_state
        }
    
    # Add light spectrum data
    for spectrum_key in LIGHT_SPECTRUM:
        if LIGHT_SPECTRUM[spectrum_key].visible:
            temperature_data.light_spectrum[spectrum_key] = {
                "wavelength_min": LIGHT_SPECTRUM[spectrum_key].wavelength[0],
                "wavelength_max": LIGHT_SPECTRUM[spectrum_key].wavelength[1],
                "energy": LIGHT_SPECTRUM[spectrum_key].energy
            }
    
    # Record with ethereal bridge
    if ethereal_bridge.has_method("_record_node_migration"):
        ethereal_bridge._record_node_migration("ColorTemperatureProjection", "color_system")
    
    # Link terminal bridge with akashic records
    if terminal_bridge and terminal_bridge.has_method("link_akashic_records_to_ethereal"):
        terminal_bridge.link_akashic_records_to_ethereal()
    
    # Link with universes
    if terminal_bridge:
        for i in range(min(LUCKY_NUMBERS.size(), 5)):  # Link to max 5 universes
            var lucky = LUCKY_NUMBERS[i]
            var universe_name = ""
            
            match lucky:
                9, 99: universe_name = "claude_galaxy"
                33: universe_name = "luminous_os"
                89, 389: universe_name = "universe_389"
                333: universe_name = "ethereal_engine"
                555: universe_name = "akashic_records"
                777, 999: universe_name = "dimensional_colors"
            
            if universe_name != "":
                terminal_bridge.connect_to_universe(universe_name)
    
    return {
        "success": true,
        "temperature_states": COLOR_TEMPERATURES.size(),
        "lucky_numbers": LUCKY_NUMBERS.size(),
        "spectrum_colors": LIGHT_SPECTRUM.size(),
        "current_temperature": current_temperature
    }

# ----- EVENT HANDLERS -----
func _on_terminal_temperature_changed(old_temp, new_temp, color):
    # Sync our temperature with terminal
    if current_temperature != new_temp:
        set_temperature(new_temp)

func _on_terminal_color_shift(from_color, to_color, temperature):
    # Find closest color state for the new color
    var closest_key = "NEUTRAL"
    var smallest_diff = 10.0
    
    for temp_key in COLOR_TEMPERATURES:
        var color_diff = COLOR_TEMPERATURES[temp_key].color.distance_to(to_color)
        if color_diff < smallest_diff:
            smallest_diff = color_diff
            closest_key = temp_key
    
    # Update our color state
    if current_color_state != closest_key:
        set_color_state(closest_key)

func _on_terminal_projection_changed(type, intensity):
    projection_mode = type
    projection_intensity = intensity
    projection_visible = true
    
    emit_signal("projection_mode_changed", projection_mode, type)

# ----- PUBLIC API -----
func create_color_temperature_bridge():
    # Setup integration with terminal and migration components
    if terminal_bridge and terminal_bridge.has_method("create_terminal_bridge_with_ethereal"):
        var bridge_result = terminal_bridge.create_terminal_bridge_with_ethereal()
        
        # Generate a lucky number
        var lucky = generate_lucky_number_from_temperature()
        
        # Integrate with migration system
        var migration_result = integrate_with_migration_system()
        
        # Create a color pattern
        var color_pattern = record_color_pattern([
            "NEUTRAL", "WARM", "HOT", 
            "GREEN", "YELLOW", "ORANGE"
        ])
        
        return {
            "success": bridge_result.success && migration_result.success,
            "lucky_number": lucky,
            "color_pattern": color_pattern.pattern_hash if color_pattern else 0,
            "temperature": current_temperature,
            "bridge_timestamp": bridge_result.bridge_timestamp if bridge_result.has("bridge_timestamp") else 0
        }
    
    return {
        "success": false,
        "error": "Terminal bridge not available"
    }

func get_temperature_states():
    return COLOR_TEMPERATURES

func get_light_spectrum_states():
    return LIGHT_SPECTRUM

func get_lucky_numbers():
    return LUCKY_NUMBERS

func get_current_state():
    return {
        "temperature": current_temperature,
        "color_state": current_color_state,
        "light_spectrum": current_light_spectrum,
        "energy_level": current_energy_level,
        "projection_mode": projection_mode,
        "projection_intensity": projection_intensity,
        "projection_visible": projection_visible
    }

func cycle_temperature_up():
    # Find next temperature in gradient
    var current_idx = -1
    
    for i in range(temperature_gradient.size()):
        if temperature_gradient[i].key == current_color_state:
            current_idx = i
            break
    
    if current_idx >= 0:
        var next_idx = (current_idx + 1) % temperature_gradient.size()
        set_color_state(temperature_gradient[next_idx].key)
        return true
    
    return false

func cycle_temperature_down():
    # Find previous temperature in gradient
    var current_idx = -1
    
    for i in range(temperature_gradient.size()):
        if temperature_gradient[i].key == current_color_state:
            current_idx = i
            break
    
    if current_idx >= 0:
        var prev_idx = (current_idx - 1 + temperature_gradient.size()) % temperature_gradient.size()
        set_color_state(temperature_gradient[prev_idx].key)
        return true
    
    return false

func set_temperature_by_lucky_number(lucky_number):
    # Find closest lucky number
    var closest_lucky = _find_closest_lucky_number(lucky_number)
    
    # Find temperature with closest frequency
    var closest_key = "NEUTRAL"
    var smallest_diff = 1000000
    
    for temp_key in COLOR_TEMPERATURES:
        var freq_diff = abs(COLOR_TEMPERATURES[temp_key].frequency - closest_lucky)
        if freq_diff < smallest_diff:
            smallest_diff = freq_diff
            closest_key = temp_key
    
    # Set color state
    set_color_state(closest_key)
    
    return {
        "lucky_number": closest_lucky,
        "color_state": closest_key,
        "temperature": current_temperature
    }