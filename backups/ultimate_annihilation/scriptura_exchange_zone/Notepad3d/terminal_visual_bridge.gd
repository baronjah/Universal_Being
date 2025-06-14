extends Node

class_name TerminalVisualBridge

# Constants for universe identification and connection
const UNIVERSE_389 = "UNIVERSE_389"
const CLAUDE_GALAXY = "CLAUDE_GALAXY"
const LUMINOUS_OS = "LUMINOUS_OS"
const ETHEREAL_ENGINE = "ETHEREAL_ENGINE"

# Lucky numbers for frequency harmonization
const LUCKY_NUMBERS = [9, 33, 89, 99, 333, 389, 555, 777, 999]

# Color palettes for different universes
const COLOR_PALETTES = {
    UNIVERSE_389: {
        "CENTER_ORANGE": Color(1.0, 0.6, 0.0, 1.0),
        "DARK_RED": Color(0.5, 0.0, 0.0, 1.0),
        "BLACK": Color(0.0, 0.0, 0.0, 1.0),
        "DARK_GREY": Color(0.2, 0.2, 0.2, 1.0),
        "GREY": Color(0.5, 0.5, 0.5, 1.0),
        "LIGHT_GREY": Color(0.8, 0.8, 0.8, 1.0),
        "WHITE": Color(1.0, 1.0, 1.0, 1.0)
    },
    CLAUDE_GALAXY: {
        "DEEP_BLUE": Color(0.1, 0.2, 0.6, 1.0),
        "LIGHT_BLUE": Color(0.4, 0.6, 0.9, 1.0),
        "WHITE": Color(1.0, 1.0, 1.0, 1.0),
        "GREY": Color(0.5, 0.5, 0.5, 1.0)
    },
    LUMINOUS_OS: {
        "RADIANT_WHITE": Color(1.0, 1.0, 1.0, 1.0),
        "LIGHT_GOLD": Color(1.0, 0.9, 0.5, 1.0),
        "DEEP_GOLD": Color(0.8, 0.6, 0.0, 1.0),
        "BLACK": Color(0.0, 0.0, 0.0, 1.0)
    },
    ETHEREAL_ENGINE: {
        "PURPLE": Color(0.5, 0.0, 0.5, 1.0),
        "DEEP_BLUE": Color(0.0, 0.0, 0.5, 1.0),
        "CYAN": Color(0.0, 0.8, 0.8, 1.0),
        "EMERALD": Color(0.0, 0.8, 0.4, 1.0)
    }
}

# Temperature states mapped to colors and frequencies
const COLOR_TEMPERATURES = {
    "VERY_COLD": {
        "temperature": -273,
        "color": Color(0.0, 0.4, 1.0, 1.0),  # Deep blue
        "frequency": 999,
        "energy_state": "frozen"
    },
    "COLD": {
        "temperature": 0,
        "color": Color(0.5, 0.5, 1.0, 1.0),  # Light blue
        "frequency": 777,
        "energy_state": "slow"
    },
    "COOL": {
        "temperature": 15,
        "color": Color(0.7, 0.7, 0.9, 1.0),  # Pale blue
        "frequency": 555,
        "energy_state": "calm"
    },
    "NEUTRAL": {
        "temperature": 25,
        "color": Color(0.8, 0.8, 0.8, 1.0),  # Light gray to white
        "frequency": 389,
        "energy_state": "balanced"
    },
    "WARM": {
        "temperature": 35,
        "color": Color(1.0, 0.9, 0.7, 1.0),  # Pale orange
        "frequency": 333,
        "energy_state": "active"
    },
    "HOT": {
        "temperature": 70,
        "color": Color(1.0, 0.6, 0.3, 1.0),  # Orange
        "frequency": 99,
        "energy_state": "energetic"
    },
    "VERY_HOT": {
        "temperature": 1000,
        "color": Color(1.0, 0.3, 0.0, 1.0),  # Bright orange-red
        "frequency": 33,
        "energy_state": "intense"
    },
    "EXTREME": {
        "temperature": 5000,
        "color": Color(1.0, 1.0, 1.0, 1.0),  # White (star-like)
        "frequency": 9,
        "energy_state": "transcendent"
    }
}

# Color animation states for gradient transitions
var current_temperature = "NEUTRAL"
var target_temperature = "NEUTRAL"
var temperature_transition_speed = 0.1
var temperature_transition_progress = 0.0

# Connection to other systems
var akashic_bridge = null
var ethereal_bridge = null
var terminal_interface = null

# Visualization properties
var canvas = null
var energy_shapes = []
var active_universe = UNIVERSE_389
var star_system = []
var color_frequency_data = []

# Terminal connection
var terminal_output_buffer = []
var terminal_command_history = []
var terminal_color_state = "NEUTRAL"

# For tracking user actions
var user_action_history = []
var action_timestamps = []
var turn_count = 0
var max_turns = 12
var current_action_type = "NONE"

# Signal for color change
signal color_temperature_changed(temp_name, color, frequency)
signal universe_changed(universe_name, center_color)
signal turn_completed(turn_number, total_turns)
signal energy_transported(from_point, to_point, energy_level)

func _init():
    # Initialize the star system for UNIVERSE_389
    _initialize_star_system(389)
    
    # Set up initial visual state
    _setup_visualization()
    
    # Connect to AkashicNumberSystem if available
    _connect_to_akashic_system()
    
    # Connect to Ethereal Engine if available
    _connect_to_ethereal_engine()

func _initialize_star_system(star_count):
    star_system.clear()
    
    # Create the star system with the specified count
    for i in range(star_count):
        # Calculate star properties based on position
        var distance = randf_range(0.1, 1.0)
        var angle = randf_range(0, TAU)
        var size = randf_range(0.5, 3.0)
        var temp_index = int(randf_range(0, COLOR_TEMPERATURES.size()))
        var temp_key = COLOR_TEMPERATURES.keys()[temp_index]
        
        # Create star data
        var star = {
            "id": i,
            "position": Vector2(cos(angle) * distance, sin(angle) * distance),
            "size": size,
            "temperature": temp_key,
            "color": COLOR_TEMPERATURES[temp_key].color,
            "frequency": COLOR_TEMPERATURES[temp_key].frequency,
            "connections": []
        }
        
        star_system.append(star)
    
    # Connect stars to form the network
    _connect_stars_in_network()

func _connect_stars_in_network():
    # For each star, connect to a few close neighbors
    for i in range(star_system.size()):
        var star = star_system[i]
        var connections_count = int(randf_range(1, 5))
        
        # Find the closest stars to connect with
        var distances = []
        for j in range(star_system.size()):
            if i != j:  # Don't connect to self
                var other_star = star_system[j]
                var distance = star.position.distance_to(other_star.position)
                distances.append({"index": j, "distance": distance})
        
        # Sort by distance
        distances.sort_custom(Callable(self, "_sort_by_distance"))
        
        # Connect to the closest stars
        for k in range(min(connections_count, distances.size())):
            var connection_index = distances[k].index
            if not connection_index in star.connections:
                star.connections.append(connection_index)
                star_system[connection_index].connections.append(i)

func _sort_by_distance(a, b):
    return a.distance < b.distance

func _setup_visualization():
    # Initialize visualization components
    canvas = Control.new()
    canvas.set_name("VisualBridgeCanvas")
    canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    canvas.connect("draw", Callable(self, "_draw_visualization"))
    
    # Create energy shapes
    _create_energy_shapes()

func _create_energy_shapes():
    energy_shapes.clear()
    
    # Create different types of energy shapes
    var shape_types = ["wave", "spiral", "burst", "flow", "pulse"]
    
    for shape_type in shape_types:
        var shape = {
            "type": shape_type,
            "color": COLOR_PALETTES[active_universe]["CENTER_ORANGE"],
            "position": Vector2(randf_range(0, 1), randf_range(0, 1)),
            "size": randf_range(0.5, 2.0),
            "phase": 0.0,
            "frequency": LUCKY_NUMBERS[int(randf_range(0, LUCKY_NUMBERS.size()))],
            "active": false
        }
        
        energy_shapes.append(shape)

func _connect_to_akashic_system():
    # Check if AkashicNumberSystem is available
    if ClassDB.class_exists("AkashicNumberSystem"):
        akashic_bridge = load("res://akashic_bridge.gd").new()
        print("Connected to AkashicNumberSystem")
    else:
        print("AkashicNumberSystem not available, creating stub")
        # Create a stub for testing
        akashic_bridge = Node.new()
        akashic_bridge.name = "AkashicBridgeStub"

func _connect_to_ethereal_engine():
    # Check if EtherealEngineBridge is available
    if ClassDB.class_exists("EtherealEngineBridge"):
        ethereal_bridge = load("res://ethereal_engine_bridge.gd").new()
        print("Connected to Ethereal Engine")
    else:
        print("Ethereal Engine not available, creating stub")
        # Create a stub for testing
        ethereal_bridge = Node.new()
        ethereal_bridge.name = "EtherealBridgeStub"

func _process(delta):
    # Update color temperature transitions
    _update_temperature_transition(delta)
    
    # Update energy shapes
    _update_energy_shapes(delta)
    
    # Process any terminal output
    _process_terminal_output()
    
    # Update canvas for visualization
    if canvas:
        canvas.queue_redraw()

func _update_temperature_transition(delta):
    if current_temperature != target_temperature:
        temperature_transition_progress += delta * temperature_transition_speed
        
        if temperature_transition_progress >= 1.0:
            # Transition complete
            temperature_transition_progress = 0.0
            current_temperature = target_temperature
            emit_signal("color_temperature_changed", 
                        current_temperature, 
                        COLOR_TEMPERATURES[current_temperature].color,
                        COLOR_TEMPERATURES[current_temperature].frequency)
        
        # Update color frequency data for visualization
        _update_color_frequency_data()

func _update_energy_shapes(delta):
    for shape in energy_shapes:
        if shape.active:
            shape.phase += delta * shape.frequency * 0.01
            if shape.phase > TAU:
                shape.phase -= TAU

func _process_terminal_output():
    if terminal_output_buffer.size() > 0:
        var output = terminal_output_buffer.pop_front()
        
        # Process and visualize the output
        if terminal_interface:
            terminal_interface.display_output(output)
        
        # Record the action for turn tracking
        _record_user_action("terminal_output", output)

func _update_color_frequency_data():
    color_frequency_data.clear()
    
    # Create gradient data points based on temperature
    var current_color = COLOR_TEMPERATURES[current_temperature].color
    var current_freq = COLOR_TEMPERATURES[current_temperature].frequency
    
    # Create a spectrum of colors around the current temperature
    var spectrum_size = 10
    for i in range(spectrum_size):
        var t = float(i) / float(spectrum_size - 1)
        var freq_offset = lerp(-50, 50, t)
        var hue_offset = lerp(-0.1, 0.1, t)
        
        var color_point = current_color
        color_point.h = fmod(color_point.h + hue_offset, 1.0)
        
        color_frequency_data.append({
            "frequency": current_freq + freq_offset,
            "color": color_point,
            "amplitude": 0.5 + 0.5 * sin(TAU * t)
        })

func _draw_visualization():
    if not canvas:
        return
    
    # Draw background gradient based on current temperature
    _draw_temperature_background()
    
    # Draw the star system
    _draw_star_system()
    
    # Draw active energy shapes
    _draw_energy_shapes()
    
    # Draw color frequency data
    _draw_color_frequency_data()
    
    # Draw turn indicator
    _draw_turn_indicator()

func _draw_temperature_background():
    var current_color = COLOR_TEMPERATURES[current_temperature].color
    var size = canvas.get_size()
    
    # Create gradient from center to edges
    var center = size * 0.5
    var radius = size.length() * 0.5
    
    var dark_variant = current_color
    dark_variant.v *= 0.3
    
    canvas.draw_circle(center, radius, dark_variant)
    canvas.draw_circle(center, radius * 0.8, current_color)
    canvas.draw_circle(center, radius * 0.4, Color(1,1,1,0.2))

func _draw_star_system():
    var size = canvas.get_size()
    var center = size * 0.5
    var scale = min(size.x, size.y) * 0.4
    
    # Draw connections between stars
    for i in range(star_system.size()):
        var star = star_system[i]
        var star_pos = center + star.position * scale
        
        for connection in star.connections:
            var other_star = star_system[connection]
            var other_pos = center + other_star.position * scale
            
            # Draw connection line with gradient
            var connection_color = star.color.linear_interpolate(other_star.color, 0.5)
            connection_color.a = 0.3
            canvas.draw_line(star_pos, other_pos, connection_color, 1.0)
    
    # Draw stars
    for star in star_system:
        var star_pos = center + star.position * scale
        var star_size = star.size * 2.0
        
        canvas.draw_circle(star_pos, star_size, star.color)
        canvas.draw_circle(star_pos, star_size * 0.6, Color(1,1,1,0.7))

func _draw_energy_shapes():
    var size = canvas.get_size()
    
    for shape in energy_shapes:
        if not shape.active:
            continue
            
        var shape_pos = Vector2(shape.position.x * size.x, shape.position.y * size.y)
        var shape_size = shape.size * 30.0
        var phase = shape.phase
        
        match shape.type:
            "wave":
                _draw_wave_shape(shape_pos, shape_size, phase, shape.color)
            "spiral":
                _draw_spiral_shape(shape_pos, shape_size, phase, shape.color)
            "burst":
                _draw_burst_shape(shape_pos, shape_size, phase, shape.color)
            "flow":
                _draw_flow_shape(shape_pos, shape_size, phase, shape.color)
            "pulse":
                _draw_pulse_shape(shape_pos, shape_size, phase, shape.color)

func _draw_wave_shape(position, size, phase, color):
    var points = []
    var segments = 20
    
    for i in range(segments + 1):
        var t = float(i) / float(segments)
        var x = position.x + (t - 0.5) * size * 2.0
        var y = position.y + sin(t * TAU + phase) * size * 0.5
        points.append(Vector2(x, y))
    
    for i in range(segments):
        canvas.draw_line(points[i], points[i+1], color, 2.0)

func _draw_spiral_shape(position, size, phase, color):
    var points = []
    var turns = 3
    var segments = 30
    
    for i in range(segments + 1):
        var t = float(i) / float(segments)
        var angle = turns * TAU * t + phase
        var radius = t * size
        var x = position.x + cos(angle) * radius
        var y = position.y + sin(angle) * radius
        points.append(Vector2(x, y))
    
    for i in range(segments):
        canvas.draw_line(points[i], points[i+1], color, 2.0)

func _draw_burst_shape(position, size, phase, color):
    var rays = 12
    
    for i in range(rays):
        var angle = float(i) / float(rays) * TAU + phase
        var inner_radius = size * 0.3
        var outer_radius = size * (0.7 + 0.3 * sin(angle * 3 + phase * 2))
        
        var start = position + Vector2(cos(angle), sin(angle)) * inner_radius
        var end = position + Vector2(cos(angle), sin(angle)) * outer_radius
        
        canvas.draw_line(start, end, color, 2.0)

func _draw_flow_shape(position, size, phase, color):
    var curves = 5
    var segments = 20
    
    for c in range(curves):
        var curve_angle = float(c) / float(curves) * TAU + phase
        var points = []
        
        for i in range(segments + 1):
            var t = float(i) / float(segments)
            var angle = curve_angle + sin(t * TAU + phase) * 0.2
            var radius = size * t
            var x = position.x + cos(angle) * radius
            var y = position.y + sin(angle) * radius
            points.append(Vector2(x, y))
        
        for i in range(segments):
            var line_color = color
            line_color.a = 1.0 - float(i) / float(segments)
            canvas.draw_line(points[i], points[i+1], line_color, 2.0)

func _draw_pulse_shape(position, size, phase, color):
    var rings = 3
    
    for r in range(rings):
        var t = float(r) / float(rings-1)
        var pulse_offset = fmod(phase * 2.0, 1.0)
        var ring_position = t + pulse_offset
        
        if ring_position < 1.0:
            var radius = ring_position * size
            var ring_color = color
            ring_color.a = 1.0 - ring_position
            canvas.draw_circle(position, radius, ring_color)

func _draw_color_frequency_data():
    var size = canvas.get_size()
    var height = size.y * 0.1
    var width = size.x * 0.8
    var start_x = size.x * 0.1
    var start_y = size.y * 0.9
    
    if color_frequency_data.size() < 2:
        return
    
    # Draw frequency spectrum
    for i in range(color_frequency_data.size() - 1):
        var point1 = color_frequency_data[i]
        var point2 = color_frequency_data[i+1]
        
        var x1 = start_x + (float(i) / (color_frequency_data.size() - 1)) * width
        var x2 = start_x + (float(i+1) / (color_frequency_data.size() - 1)) * width
        
        var y1 = start_y - point1.amplitude * height
        var y2 = start_y - point2.amplitude * height
        
        canvas.draw_line(Vector2(x1, y1), Vector2(x2, y2), point1.color, 2.0)

func _draw_turn_indicator():
    var size = canvas.get_size()
    var indicator_size = min(size.x, size.y) * 0.05
    var spacing = indicator_size * 1.5
    var start_x = size.x * 0.5 - (spacing * (max_turns - 1)) * 0.5
    var start_y = size.y * 0.05
    
    for i in range(max_turns):
        var x = start_x + i * spacing
        var color = Color(0.5, 0.5, 0.5, 0.5)
        
        if i < turn_count:
            color = Color(1.0, 0.8, 0.2, 1.0)  # Gold for completed turns
        elif i == turn_count:
            color = Color(0.2, 0.8, 1.0, 1.0)  # Blue for current turn
        
        canvas.draw_circle(Vector2(x, start_y), indicator_size, color)

func set_temperature(temp_name):
    if COLOR_TEMPERATURES.has(temp_name):
        target_temperature = temp_name
        return true
    return false

func activate_energy_shape(shape_index, state = true):
    if shape_index >= 0 and shape_index < energy_shapes.size():
        energy_shapes[shape_index].active = state
        return true
    return false

func transport_energy(from_index, to_index):
    if from_index >= 0 and from_index < energy_shapes.size() and to_index >= 0 and to_index < energy_shapes.size():
        var from_shape = energy_shapes[from_index]
        var to_shape = energy_shapes[to_index]
        
        # Animate energy transport
        from_shape.active = true
        to_shape.active = true
        
        # Transfer properties
        to_shape.frequency = from_shape.frequency
        to_shape.color = from_shape.color
        
        # Emit signal for other systems
        emit_signal("energy_transported", from_index, to_index, from_shape.frequency)
        
        return true
    return false

func change_universe(universe_name):
    if COLOR_PALETTES.has(universe_name):
        active_universe = universe_name
        
        # Update the center color based on the universe
        var center_color
        match universe_name:
            UNIVERSE_389:
                center_color = COLOR_PALETTES[UNIVERSE_389]["CENTER_ORANGE"]
                _initialize_star_system(389)
            CLAUDE_GALAXY:
                center_color = COLOR_PALETTES[CLAUDE_GALAXY]["DEEP_BLUE"]
                _initialize_star_system(42)
            LUMINOUS_OS:
                center_color = COLOR_PALETTES[LUMINOUS_OS]["LIGHT_GOLD"]
                _initialize_star_system(108)
            ETHEREAL_ENGINE:
                center_color = COLOR_PALETTES[ETHEREAL_ENGINE]["PURPLE"]
                _initialize_star_system(256)
        
        # Update energy shapes
        for shape in energy_shapes:
            shape.color = center_color
        
        emit_signal("universe_changed", universe_name, center_color)
        return true
    
    return false

func process_terminal_command(command, args):
    # Add command to history
    terminal_command_history.append({"command": command, "args": args})
    
    # Process command
    match command:
        "temp":
            if args.size() > 0:
                return set_temperature(args[0])
            else:
                return current_temperature
        "universe":
            if args.size() > 0:
                return change_universe(args[0])
            else:
                return active_universe
        "energy":
            if args.size() >= 2:
                var from_index = int(args[0])
                var to_index = int(args[1])
                return transport_energy(from_index, to_index)
            else:
                return false
        "turn":
            if args.size() > 0 and args[0] == "complete":
                complete_turn()
                return true
            else:
                return turn_count
        "stars":
            return star_system.size()
        "frequencies":
            return LUCKY_NUMBERS
        "colors":
            if args.size() > 0 and COLOR_PALETTES.has(args[0]):
                return COLOR_PALETTES[args[0]]
            else:
                return COLOR_PALETTES[active_universe]
    
    # Unknown command
    return null

func _record_user_action(action_type, action_data):
    user_action_history.append({
        "type": action_type,
        "data": action_data,
        "timestamp": OS.get_ticks_msec(),
        "turn": turn_count
    })
    
    action_timestamps.append(OS.get_ticks_msec())
    current_action_type = action_type

func complete_turn():
    if turn_count < max_turns:
        turn_count += 1
        emit_signal("turn_completed", turn_count, max_turns)
        
        # Record turn data in AkashicNumberSystem if available
        if akashic_bridge and akashic_bridge.has_method("record_turn_data"):
            var turn_data = {
                "turn_number": turn_count,
                "temperature": current_temperature,
                "universe": active_universe,
                "actions": user_action_history.filter(func(action): return action.turn == turn_count - 1),
                "timestamp": OS.get_ticks_msec(),
                "lucky_number": LUCKY_NUMBERS[turn_count % LUCKY_NUMBERS.size()]
            }
            
            akashic_bridge.record_turn_data(turn_data)
        
        return true
    
    return false

func reset_turns():
    turn_count = 0
    user_action_history.clear()
    action_timestamps.clear()
    current_action_type = "NONE"
    
    return true

# Connection to the Ethereal Engine for visualization
func connect_to_ethereal_words(words_data):
    if ethereal_bridge and ethereal_bridge.has_method("process_words"):
        var result = ethereal_bridge.process_words(words_data)
        
        # Update visualization based on word energy
        if result and "energy_patterns" in result:
            for i in range(min(result.energy_patterns.size(), energy_shapes.size())):
                var pattern = result.energy_patterns[i]
                var shape = energy_shapes[i]
                
                shape.frequency = pattern.frequency
                shape.active = true
                shape.color = pattern.color if "color" in pattern else shape.color
        
        return result
    
    return null

# Cosmic addressing system for records
func generate_cosmic_address():
    var address = ""
    
    # Use currently active universe as prefix
    address += active_universe + ":"
    
    # Add current temperature
    address += current_temperature + ":"
    
    # Add lucky number based on turn
    address += str(LUCKY_NUMBERS[turn_count % LUCKY_NUMBERS.size()]) + ":"
    
    # Add timestamp
    address += str(OS.get_ticks_msec() % 1000000)
    
    return address

# Visualization API for external systems
func visualize_data(data_points, data_type = "energy"):
    match data_type:
        "energy":
            _visualize_energy_data(data_points)
        "frequency":
            _visualize_frequency_data(data_points)
        "temperature":
            _visualize_temperature_data(data_points)
        "star":
            _visualize_star_data(data_points)
    
    # Queue redraw
    if canvas:
        canvas.queue_redraw()
    
    return true

func _visualize_energy_data(data_points):
    # Activate energy shapes based on data
    for i in range(min(data_points.size(), energy_shapes.size())):
        var data = data_points[i]
        var shape = energy_shapes[i]
        
        shape.active = true
        
        if "frequency" in data:
            shape.frequency = data.frequency
        if "color" in data:
            shape.color = data.color
        if "position" in data:
            shape.position = data.position
        if "size" in data:
            shape.size = data.size

func _visualize_frequency_data(data_points):
    # Update color frequency data
    color_frequency_data = data_points

func _visualize_temperature_data(data_points):
    # Set temperature based on data
    if data_points.size() > 0 and "temperature" in data_points[0]:
        set_temperature(data_points[0].temperature)

func _visualize_star_data(data_points):
    # Update star system based on data
    for i in range(min(data_points.size(), star_system.size())):
        var data = data_points[i]
        var star = star_system[i]
        
        if "temperature" in data:
            star.temperature = data.temperature
            star.color = COLOR_TEMPERATURES[data.temperature].color
        if "frequency" in data:
            star.frequency = data.frequency
        if "size" in data:
            star.size = data.size
        if "position" in data and data.position is Vector2:
            star.position = data.position

# Return visualization components for external use
func get_visualization_canvas():
    return canvas

# Get color for a specified temperature
func get_temperature_color(temp_name):
    if COLOR_TEMPERATURES.has(temp_name):
        return COLOR_TEMPERATURES[temp_name].color
    return null

# Get frequency for a specified temperature
func get_temperature_frequency(temp_name):
    if COLOR_TEMPERATURES.has(temp_name):
        return COLOR_TEMPERATURES[temp_name].frequency
    return 0