extends Node

class_name KeyboardShapeManager

# Keyboard tracking and shape generation system with eyeball tracking integration

# Keyboard state tracking
var key_states = {}
var active_keys = []
var key_press_history = []
var key_combinations = []
var last_key_time = 0
var typing_speed = 0
var typing_rhythm = []
var typing_pattern = ""
var current_shape = "none"
var current_color = Color(1, 1, 1)
var eye_tracking_active = false
var eye_position = Vector2(0.5, 0.5) # Normalized 0-1 position
var keyboard_dimensions = Vector2(1920, 200) # Default size

# Color progression for shapes
var color_gradient = {
    "cool": [
        Color(0.2, 0.4, 0.8),
        Color(0.3, 0.6, 0.9),
        Color(0.4, 0.7, 0.8),
        Color(0.5, 0.8, 0.7)
    ],
    "warm": [
        Color(0.9, 0.3, 0.2),
        Color(0.8, 0.4, 0.3),
        Color(0.9, 0.5, 0.1),
        Color(0.8, 0.6, 0.2)
    ],
    "neutral": [
        Color(0.7, 0.7, 0.7),
        Color(0.6, 0.6, 0.6),
        Color(0.8, 0.8, 0.8),
        Color(0.5, 0.5, 0.5)
    ],
    "vibrant": [
        Color(0.9, 0.2, 0.8),
        Color(0.2, 0.8, 0.4),
        Color(0.8, 0.8, 0.2),
        Color(0.2, 0.4, 0.9)
    ]
}

# Shape patterns based on key combinations
var shape_patterns = {
    "WASD": "cube",
    "HJKL": "sphere",
    "UIOP": "pyramid",
    "ZXCV": "cylinder",
    "1234": "torus",
    "QWER": "plane",
    "ASDF": "cone",
    "JKLI": "star",
    "YGHJ": "octahedron",
    "BNM": "icosahedron"
}

# Special key combinations for effects
var effect_combos = {
    "CTRL+ALT+S": "save_shape",
    "CTRL+ALT+L": "load_shape",
    "CTRL+ALT+C": "cycle_color",
    "CTRL+SHIFT+E": "toggle_eye_tracking",
    "ALT+SHIFT+R": "randomize_properties"
}

# External tool connections
var github_connected = false
var github_repos = []
var shape_library_path = "user://shape_library/"
var external_tools = []

# Signals
signal key_sequence_recognized(sequence, shape)
signal shape_changed(shape_name, properties)
signal eye_gaze_tracked(position)
signal shape_saved(shape_name, file_path)
signal tool_connected(tool_name, status)

func _ready():
    # Initialize key states for entire keyboard
    _initialize_key_states()
    
    # Create shape library directory if it doesn't exist
    var dir = Directory.new()
    if not dir.dir_exists(shape_library_path):
        dir.make_dir_recursive(shape_library_path)
    
    # Start input monitoring
    set_process_input(true)
    
    # Try to connect to GitHub
    connect_to_github()
    
    # Load external tools
    load_external_tools()

func _initialize_key_states():
    # Initialize tracking for standard keys
    var keys = [
        # Letters
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        # Numbers
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        # Special keys
        "SPACE", "ENTER", "BACKSPACE", "TAB", "ESCAPE",
        "LEFT", "RIGHT", "UP", "DOWN",
        "CTRL", "SHIFT", "ALT", "META"
    ]
    
    for key in keys:
        key_states[key] = {
            "pressed": false,
            "last_pressed_time": 0,
            "press_count": 0,
            "hold_duration": 0,
            "combined_with": []
        }

func _input(event):
    # Track keyboard input
    if event is InputEventKey:
        var key_name = OS.get_scancode_string(event.scancode)
        
        if event.pressed:
            _on_key_pressed(key_name)
        else:
            _on_key_released(key_name)
        
        # Check for shape patterns
        check_shape_patterns()
        
        # Check for effect combinations
        check_effect_combinations()

func _on_key_pressed(key_name):
    if not key_name in key_states:
        key_states[key_name] = {
            "pressed": false,
            "last_pressed_time": 0,
            "press_count": 0,
            "hold_duration": 0,
            "combined_with": []
        }
    
    var now = OS.get_ticks_msec()
    var key_state = key_states[key_name]
    
    # Update key state
    key_state["pressed"] = true
    key_state["last_pressed_time"] = now
    key_state["press_count"] += 1
    key_state["hold_duration"] = 0
    
    # Update active keys list
    if not key_name in active_keys:
        active_keys.append(key_name)
    
    # Update key combinations
    key_state["combined_with"] = active_keys.duplicate()
    key_state["combined_with"].erase(key_name)
    
    # Add to history
    key_press_history.append({
        "key": key_name,
        "time": now,
        "combined_with": key_state["combined_with"].duplicate()
    })
    
    # Limit history size
    if key_press_history.size() > 100:
        key_press_history.pop_front()
    
    # Calculate typing speed
    if key_press_history.size() >= 2:
        var prev_time = key_press_history[key_press_history.size() - 2]["time"]
        var time_diff = now - prev_time
        
        # Only count if keys are pressed within reasonable typing timeframe (2 seconds)
        if time_diff < 2000:
            typing_rhythm.append(time_diff)
            # Keep only the last 20 rhythm measurements
            if typing_rhythm.size() > 20:
                typing_rhythm.pop_front()
            
            # Calculate average typing speed in characters per minute
            var avg_time_between_keys = 0
            for time in typing_rhythm:
                avg_time_between_keys += time
            
            if typing_rhythm.size() > 0:
                avg_time_between_keys /= typing_rhythm.size()
                if avg_time_between_keys > 0:
                    typing_speed = 60000 / avg_time_between_keys
                else:
                    typing_speed = 0
    
    # Update typing pattern
    if key_press_history.size() >= 4:
        var recent_keys = []
        for i in range(key_press_history.size() - 4, key_press_history.size()):
            recent_keys.append(key_press_history[i]["key"])
        
        typing_pattern = ""
        for k in recent_keys:
            typing_pattern += k

func _on_key_released(key_name):
    if not key_name in key_states:
        return
    
    var now = OS.get_ticks_msec()
    var key_state = key_states[key_name]
    
    # Update key state
    key_state["pressed"] = false
    key_state["hold_duration"] = now - key_state["last_pressed_time"]
    
    # Remove from active keys
    active_keys.erase(key_name)

func check_shape_patterns():
    # Convert active keys to a sorted string for pattern matching
    var active_keys_str = ""
    var sorted_keys = active_keys.duplicate()
    sorted_keys.sort()
    
    for key in sorted_keys:
        active_keys_str += key
    
    # Check against shape patterns
    for pattern in shape_patterns:
        if active_keys_str.find(pattern) >= 0:
            var shape_name = shape_patterns[pattern]
            if shape_name != current_shape:
                current_shape = shape_name
                create_shape(shape_name)
                emit_signal("key_sequence_recognized", pattern, shape_name)
                return

func check_effect_combinations():
    # Check for effect combinations
    for combo in effect_combos:
        var combo_keys = combo.split("+")
        var all_pressed = true
        
        for key in combo_keys:
            if not key in active_keys:
                all_pressed = false
                break
        
        if all_pressed:
            execute_effect(effect_combos[combo])
            return

func execute_effect(effect_name):
    match effect_name:
        "save_shape":
            save_current_shape()
        "load_shape":
            load_shape()
        "cycle_color":
            cycle_color_palette()
        "toggle_eye_tracking":
            toggle_eye_tracking()
        "randomize_properties":
            randomize_shape_properties()

func create_shape(shape_name):
    # Generate shape properties
    var properties = {
        "name": shape_name,
        "color": get_current_color(),
        "scale": Vector3(1.0, 1.0, 1.0),
        "rotation": Vector3(0, 0, 0),
        "typing_speed": typing_speed,
        "typing_pattern": typing_pattern,
        "created_at": OS.get_unix_time()
    }
    
    # Adjust properties based on typing rhythm
    if typing_rhythm.size() > 0:
        var rhythm_variance = 0
        var rhythm_avg = 0
        
        for r in typing_rhythm:
            rhythm_avg += r
        
        rhythm_avg /= typing_rhythm.size()
        
        for r in typing_rhythm:
            rhythm_variance += abs(r - rhythm_avg)
        
        rhythm_variance /= typing_rhythm.size()
        
        # Use rhythm variance to adjust shape properties
        var variance_normalized = clamp(rhythm_variance / 500.0, 0, 1)
        properties["complexity"] = variance_normalized
        properties["size"] = 1.0 + variance_normalized
        
        # Adjust rotation based on typing speed
        properties["rotation"] = Vector3(
            rand_range(0, typing_speed / 100.0),
            rand_range(0, typing_speed / 100.0),
            rand_range(0, typing_speed / 100.0)
        )
    
    # Incorporate eye tracking if active
    if eye_tracking_active:
        properties["eye_position"] = eye_position
        
        # Adjust position based on eye gaze
        properties["position"] = Vector3(
            (eye_position.x - 0.5) * 2.0,
            (eye_position.y - 0.5) * 2.0,
            0
        )
    else:
        properties["position"] = Vector3(0, 0, 0)
    
    # Emit signal with shape data
    emit_signal("shape_changed", shape_name, properties)
    
    return properties

func save_current_shape():
    if current_shape == "none":
        print("No shape to save")
        return false
    
    # Generate shape data
    var properties = create_shape(current_shape)
    
    # Create a unique filename
    var timestamp = OS.get_unix_time()
    var filename = shape_library_path + current_shape + "_" + str(timestamp) + ".json"
    
    # Save to file
    var file = File.new()
    file.open(filename, File.WRITE)
    file.store_string(JSON.print(properties, "  "))
    file.close()
    
    emit_signal("shape_saved", current_shape, filename)
    print("Saved shape: " + current_shape + " to " + filename)
    return true

func load_shape(shape_name = ""):
    var dir = Directory.new()
    if not dir.dir_exists(shape_library_path):
        print("Shape library doesn't exist")
        return false
    
    dir.open(shape_library_path)
    dir.list_dir_begin(true, true)
    
    var shape_files = []
    var file_name = dir.get_next()
    
    while file_name != "":
        if not dir.current_is_dir() and file_name.ends_with(".json"):
            if shape_name.empty() or file_name.begins_with(shape_name):
                shape_files.append(file_name)
        file_name = dir.get_next()
    
    dir.list_dir_end()
    
    if shape_files.size() == 0:
        print("No shape files found")
        return false
    
    # Load the most recent shape file
    shape_files.sort()
    var most_recent = shape_files[shape_files.size() - 1]
    
    var file = File.new()
    if file.open(shape_library_path + most_recent, File.READ) != OK:
        print("Failed to open shape file")
        return false
    
    var json_text = file.get_as_text()
    file.close()
    
    var json = JSON.parse(json_text)
    if json.error != OK:
        print("Failed to parse shape file")
        return false
    
    var shape_data = json.result
    
    # Apply loaded shape
    current_shape = shape_data["name"]
    if shape_data.has("color"):
        current_color = Color(
            shape_data["color"]["r"],
            shape_data["color"]["g"],
            shape_data["color"]["b"]
        )
    
    emit_signal("shape_changed", current_shape, shape_data)
    print("Loaded shape: " + current_shape)
    return true

func get_current_color():
    # Return current color for shape creation
    return current_color

func cycle_color_palette():
    # Cycle through color palettes
    var palettes = ["cool", "warm", "neutral", "vibrant"]
    var current_palette = "cool"
    
    # Try to determine current palette
    for palette in palettes:
        for color in color_gradient[palette]:
            if color.is_equal_approx(current_color):
                current_palette = palette
                break
    
    # Find next palette
    var palette_index = palettes.find(current_palette)
    palette_index = (palette_index + 1) % palettes.size()
    var next_palette = palettes[palette_index]
    
    # Pick a random color from the next palette
    var colors = color_gradient[next_palette]
    current_color = colors[randi() % colors.size()]
    
    # If shape exists, update its color
    if current_shape != "none":
        var properties = create_shape(current_shape)
        emit_signal("shape_changed", current_shape, properties)
    
    print("Cycled to " + next_palette + " color palette: " + str(current_color))
    return next_palette

func toggle_eye_tracking():
    eye_tracking_active = !eye_tracking_active
    print("Eye tracking: " + ("Enabled" if eye_tracking_active else "Disabled"))
    return eye_tracking_active

func update_eye_position(position):
    # Update eye gaze position (normalized 0-1 coordinates)
    eye_position = position
    emit_signal("eye_gaze_tracked", position)
    
    # If shape exists, update its position
    if current_shape != "none" and eye_tracking_active:
        var properties = create_shape(current_shape)
        emit_signal("shape_changed", current_shape, properties)
    
    return eye_position

func randomize_shape_properties():
    if current_shape == "none":
        # Create a random shape if none exists
        var shapes = shape_patterns.values()
        current_shape = shapes[randi() % shapes.size()]
    
    # Randomize color
    var palettes = color_gradient.keys()
    var palette = palettes[randi() % palettes.size()]
    var colors = color_gradient[palette]
    current_color = colors[randi() % colors.size()]
    
    # Create shape with randomized properties
    var properties = create_shape(current_shape)
    
    # Add additional randomization
    properties["scale"] = Vector3(
        rand_range(0.5, 2.0),
        rand_range(0.5, 2.0),
        rand_range(0.5, 2.0)
    )
    
    properties["rotation"] = Vector3(
        rand_range(0, 360),
        rand_range(0, 360),
        rand_range(0, 360)
    )
    
    emit_signal("shape_changed", current_shape, properties)
    print("Randomized shape properties for: " + current_shape)
    return properties

func connect_to_github():
    # In a real implementation, would use GitHub API
    # For this demo, simulate GitHub connection
    github_connected = true
    
    # Simulate some repositories
    github_repos = [
        {
            "name": "godot-keyboard-tools",
            "url": "https://github.com/example/godot-keyboard-tools",
            "stars": 128,
            "forks": 32,
            "description": "Keyboard input tools for Godot"
        },
        {
            "name": "godot-shape-generator",
            "url": "https://github.com/example/godot-shape-generator",
            "stars": 85,
            "forks": 23,
            "description": "Procedural shape generation for Godot"
        },
        {
            "name": "eyetracking-godot",
            "url": "https://github.com/example/eyetracking-godot",
            "stars": 263,
            "forks": 87,
            "description": "Eye tracking integration for Godot"
        }
    ]
    
    emit_signal("tool_connected", "GitHub", github_connected)
    print("Connected to GitHub")
    return github_repos

func load_external_tools():
    # In a real implementation, would load tools from GitHub or other sources
    # For this demo, define some simulated tools
    external_tools = [
        {
            "name": "Shape Generator",
            "source": "github",
            "repo": "godot-shape-generator",
            "version": "1.2.3",
            "functions": ["generate_primitive", "export_shape", "animate_shape"]
        },
        {
            "name": "Color Palette Manager",
            "source": "local",
            "version": "0.9.1",
            "functions": ["create_palette", "blend_colors", "export_palette"]
        },
        {
            "name": "EyeTracker Pro",
            "source": "github",
            "repo": "eyetracking-godot",
            "version": "2.1.0",
            "functions": ["track_gaze", "generate_heatmap", "calibrate_tracking"]
        },
        {
            "name": "KeyboardMapper",
            "source": "github",
            "repo": "godot-keyboard-tools",
            "version": "1.0.5",
            "functions": ["map_keyboard", "create_custom_mapping", "export_layout"]
        }
    ]
    
    # For each tool, emit connected signal
    for tool in external_tools:
        emit_signal("tool_connected", tool["name"], true)
    
    print("Loaded " + str(external_tools.size()) + " external tools")
    return external_tools

func get_available_tools():
    # Return list of available tools
    return external_tools

func get_keyboard_stats():
    # Return statistics about keyboard usage
    var stats = {
        "active_keys": active_keys.size(),
        "total_keys_tracked": key_states.size(),
        "typing_speed": typing_speed,
        "typing_pattern": typing_pattern,
        "current_shape": current_shape,
        "current_color": current_color,
        "eye_tracking": eye_tracking_active
    }
    
    # Calculate most pressed keys
    var most_pressed = []
    var key_press_counts = {}
    
    for key in key_states:
        key_press_counts[key] = key_states[key]["press_count"]
    
    # Sort keys by press count
    var sorted_keys = key_press_counts.keys()
    sorted_keys.sort_custom(self, "_sort_by_press_count")
    
    # Get top 5 most pressed keys
    for i in range(min(5, sorted_keys.size())):
        most_pressed.append({
            "key": sorted_keys[i],
            "count": key_states[sorted_keys[i]]["press_count"]
        })
    
    stats["most_pressed_keys"] = most_pressed
    
    return stats

func _sort_by_press_count(a, b):
    return key_states[a]["press_count"] > key_states[b]["press_count"]

func set_keyboard_dimensions(dimensions):
    keyboard_dimensions = dimensions
    return keyboard_dimensions