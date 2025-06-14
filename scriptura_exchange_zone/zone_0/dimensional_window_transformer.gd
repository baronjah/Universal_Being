class_name DimensionalWindowTransformer
extends Node

# ----- WINDOW SETTINGS -----
@export_category("Window Configuration")
@export var ethereal_bridge_path: String = "res://12_turns_system/ethereal_akashic_bridge.gd"
@export var akashic_system_path: String = "res://12_turns_system/akashic_number_system.gd"
@export var base_window_size: Vector2 = Vector2(1280, 720)
@export var window_transform_speed: float = 0.5
@export var window_transition_duration: float = 0.5
@export var enable_experimental_features: bool = true
@export var max_window_instances: int = 5
@export var dimension_color_mode: String = "frequential" # frequential, stability, hybrid

# ----- WINDOW STATES -----
enum WindowState {
    NORMAL,
    TRANSITIONING,
    MAXIMIZED,
    MINIMIZED,
    ETHEREAL,
    FRACTALIZED,
    DIMENSIONAL_SHIFT
}

# ----- WINDOW TRANSFORMS -----
var window_references: Array = []
var window_states: Dictionary = {}
var window_transforms: Dictionary = {}
var window_positions: Dictionary = {}
var window_dimensions: Dictionary = {}
var active_transitions: Dictionary = {}
var window_colors: Dictionary = {}

# ----- DIMENSIONAL DATA -----
var current_dimension: String = "0-0-0"
var dimension_stack: Array = []
var fractal_points: Array = []
var dimension_properties: Dictionary = {}

# ----- COMPONENT REFERENCES -----
var ethereal_bridge: Node = null
var akashic_system: Node = null
var symbol_system: Node = null

# ----- TRANSFORMATION MATRICES -----
var transform_matrices: Dictionary = {
    "identity": Transform2D.IDENTITY,
    "rotate_90": Transform2D(Vector2(0, -1), Vector2(1, 0), Vector2.ZERO),
    "rotate_180": Transform2D(Vector2(-1, 0), Vector2(0, -1), Vector2.ZERO),
    "rotate_270": Transform2D(Vector2(0, 1), Vector2(-1, 0), Vector2.ZERO),
    "mirror_x": Transform2D(Vector2(-1, 0), Vector2(0, 1), Vector2.ZERO),
    "mirror_y": Transform2D(Vector2(1, 0), Vector2(0, -1), Vector2.ZERO),
    "scale_up": Transform2D(Vector2(1.2, 0), Vector2(0, 1.2), Vector2.ZERO),
    "scale_down": Transform2D(Vector2(0.8, 0), Vector2(0, 0.8), Vector2.ZERO),
    "shear_x": Transform2D(Vector2(1, 0.2), Vector2(0, 1), Vector2.ZERO),
    "shear_y": Transform2D(Vector2(1, 0), Vector2(0.2, 1), Vector2.ZERO)
}

# ----- WINDOW PATTERNS -----
var window_patterns: Dictionary = {
    "triangle": { 
        "points": [Vector2(0, 0), Vector2(1, 0), Vector2(0.5, 0.866)],
        "transform_sequence": ["identity", "rotate_120", "rotate_240"]
    },
    "square": {
        "points": [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)],
        "transform_sequence": ["identity", "rotate_90", "rotate_180", "rotate_270"]
    },
    "pentagon": {
        "points": [
            Vector2(0.5, 0), 
            Vector2(1, 0.363), 
            Vector2(0.809, 0.951), 
            Vector2(0.191, 0.951),
            Vector2(0, 0.363)
        ],
        "transform_sequence": ["identity", "rotate_72", "rotate_144", "rotate_216", "rotate_288"]
    },
    "hexagon": {
        "points": [
            Vector2(0.5, 0),
            Vector2(1, 0.25),
            Vector2(1, 0.75),
            Vector2(0.5, 1),
            Vector2(0, 0.75),
            Vector2(0, 0.25)
        ],
        "transform_sequence": ["identity", "rotate_60", "rotate_120", "rotate_180", "rotate_240", "rotate_300"]
    },
    "cube": {
        "points": [
            Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1),  # Front face
            Vector2(0.2, 0.2), Vector2(1.2, 0.2), Vector2(1.2, 1.2), Vector2(0.2, 1.2)  # Back face
        ],
        "transform_sequence": ["identity", "rotate_90", "rotate_180", "rotate_270", "mirror_x", "mirror_y", "shear_x", "shear_y"]
    }
}

# ----- SIGNALS -----
signal window_transformed(window_id, transform_type)
signal window_state_changed(window_id, old_state, new_state)
signal window_dimension_changed(window_id, old_dimension, new_dimension)
signal windows_synchronized()
signal fractal_data_updated(points)

# ----- INITIALIZATION -----
func _ready():
    _find_components()
    _initialize_window_references()
    
    # Connect to ethereal bridge if available
    if ethereal_bridge:
        if ethereal_bridge.has_signal("fractal_data_updated"):
            ethereal_bridge.connect("fractal_data_updated", _on_fractal_data_updated)
        
        if ethereal_bridge.has_signal("dimension_changed"):
            ethereal_bridge.connect("dimension_changed", _on_dimension_changed)
        
        # Get initial dimension data
        _update_dimension_data()

func _find_components():
    # Find Ethereal Bridge
    var bridge_script = load(ethereal_bridge_path) if ResourceLoader.exists(ethereal_bridge_path) else null
    if bridge_script:
        ethereal_bridge = get_node_or_null("/root/EtherealAkashicBridge")
        if not ethereal_bridge:
            ethereal_bridge = _find_node_by_class(get_tree().root, "EtherealAkashicBridge")
    
    # Find Akashic System
    var akashic_script = load(akashic_system_path) if ResourceLoader.exists(akashic_system_path) else null
    if akashic_script:
        akashic_system = get_node_or_null("/root/AkashicNumberSystem")
        if not akashic_system:
            akashic_system = _find_node_by_class(get_tree().root, "AkashicNumberSystem")
    
    print("Components found - Ethereal Bridge: %s, Akashic System: %s" % [
        "Yes" if ethereal_bridge else "No",
        "Yes" if akashic_system else "No"
    ])

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

func _initialize_window_references():
    # Add main window
    var main_window = {
        "id": "main",
        "viewport": get_viewport(),
        "size": base_window_size,
        "position": Vector2.ZERO,
        "state": WindowState.NORMAL,
        "dimension": current_dimension,
        "transform": Transform2D.IDENTITY
    }
    
    window_references.append(main_window)
    window_states["main"] = WindowState.NORMAL
    window_transforms["main"] = Transform2D.IDENTITY
    window_positions["main"] = Vector2.ZERO
    window_dimensions["main"] = current_dimension
    
    # Set initial window properties
    if OS.has_feature("windows") or OS.has_feature("X11") or OS.has_feature("OSX"):
        OS.window_size = base_window_size
        OS.window_position = Vector2i(100, 100)
        window_positions["main"] = Vector2(100, 100)

# ----- UPDATE LOOP -----
func _process(delta):
    # Update active transitions
    _update_transitions(delta)
    
    # Handle periodic window synchronization
    _sync_window_transforms()

# ----- WINDOW MANAGEMENT -----
func create_window(window_id: String, size: Vector2 = Vector2.ZERO, position: Vector2 = Vector2.ZERO):
    if window_references.size() >= max_window_instances:
        print("Cannot create more windows: maximum instances reached")
        return null
    
    if OS.has_feature("windows") or OS.has_feature("X11") or OS.has_feature("OSX"):
        if size == Vector2.ZERO:
            size = base_window_size
        
        if position == Vector2.ZERO:
            position = Vector2(200, 200)
        
        var window = Window.new()
        window.size = Vector2i(size)
        window.position = Vector2i(position)
        window.title = "Dimensional Window: " + window_id
        
        var new_window = {
            "id": window_id,
            "window": window,
            "size": size,
            "position": position,
            "state": WindowState.NORMAL,
            "dimension": current_dimension,
            "transform": Transform2D.IDENTITY
        }
        
        window_references.append(new_window)
        window_states[window_id] = WindowState.NORMAL
        window_transforms[window_id] = Transform2D.IDENTITY
        window_positions[window_id] = position
        window_dimensions[window_id] = current_dimension
        
        add_child(window)
        return window
    
    print("Window creation not supported on this platform")
    return null

func close_window(window_id: String):
    for i in range(window_references.size()):
        if window_references[i].id == window_id and window_id != "main":
            var window_ref = window_references[i]
            
            if window_ref.has("window") and is_instance_valid(window_ref.window):
                window_ref.window.queue_free()
            
            window_references.remove_at(i)
            window_states.erase(window_id)
            window_transforms.erase(window_id)
            window_positions.erase(window_id)
            window_dimensions.erase(window_id)
            active_transitions.erase(window_id)
            
            return true
    
    return false

func transform_window(window_id: String, transform_type: String):
    if not window_transforms.has(window_id):
        print("Window not found: " + window_id)
        return false
    
    if not transform_matrices.has(transform_type):
        print("Transform type not found: " + transform_type)
        return false
    
    # Start transition to new transform
    var current_transform = window_transforms[window_id]
    var target_transform = transform_matrices[transform_type]
    
    active_transitions[window_id] = {
        "start_transform": current_transform,
        "target_transform": target_transform,
        "progress": 0.0,
        "duration": window_transition_duration,
        "transform_type": transform_type
    }
    
    return true

func transform_window_to_pattern(window_id: String, pattern_name: String, point_index: int = 0):
    if not window_patterns.has(pattern_name):
        print("Pattern not found: " + pattern_name)
        return false
    
    var pattern = window_patterns[pattern_name]
    
    if point_index < 0 or point_index >= pattern.transform_sequence.size():
        print("Invalid point index for pattern: " + str(point_index))
        return false
    
    var transform_type = pattern.transform_sequence[point_index]
    return transform_window(window_id, transform_type)

func set_window_position(window_id: String, position: Vector2):
    if not window_positions.has(window_id):
        print("Window not found: " + window_id)
        return false
    
    window_positions[window_id] = position
    
    for window_ref in window_references:
        if window_ref.id == window_id:
            if window_id == "main":
                OS.window_position = Vector2i(position)
            elif window_ref.has("window") and is_instance_valid(window_ref.window):
                window_ref.window.position = Vector2i(position)
            
            return true
    
    return false

func set_window_size(window_id: String, size: Vector2):
    for window_ref in window_references:
        if window_ref.id == window_id:
            window_ref.size = size
            
            if window_id == "main":
                OS.window_size = Vector2i(size)
            elif window_ref.has("window") and is_instance_valid(window_ref.window):
                window_ref.window.size = Vector2i(size)
            
            return true
    
    return false

func set_window_state(window_id: String, state: int):
    if not window_states.has(window_id):
        print("Window not found: " + window_id)
        return false
    
    var old_state = window_states[window_id]
    window_states[window_id] = state
    
    # Apply state-specific transformations
    match state:
        WindowState.MAXIMIZED:
            if window_id == "main":
                OS.window_maximized = true
            # For other windows, use custom maximization
        
        WindowState.MINIMIZED:
            if window_id == "main":
                OS.window_minimized = true
            # For other windows, use custom minimization
        
        WindowState.NORMAL:
            if window_id == "main":
                OS.window_maximized = false
                OS.window_minimized = false
            # For other windows, restore normal state
        
        WindowState.ETHEREAL:
            # Apply ethereal effect - pulsing transparency
            _apply_ethereal_effect(window_id)
        
        WindowState.FRACTALIZED:
            # Apply fractal transformation
            _apply_fractal_transformation(window_id)
        
        WindowState.DIMENSIONAL_SHIFT:
            # Prepare for dimension shift
            _prepare_dimensional_shift(window_id)
    
    emit_signal("window_state_changed", window_id, old_state, state)
    return true

func change_window_dimension(window_id: String, dimension_key: String):
    if not window_dimensions.has(window_id):
        print("Window not found: " + window_id)
        return false
    
    # Check if dimension exists in ethereal bridge
    if ethereal_bridge and ethereal_bridge.has_method("get_dimension_fractal"):
        var dim_fractal = ethereal_bridge.get_dimension_fractal(dimension_key)
        if dim_fractal == null:
            print("Dimension not found: " + dimension_key)
            return false
    
    var old_dimension = window_dimensions[window_id]
    window_dimensions[window_id] = dimension_key
    
    # Update window color based on dimension
    _update_window_color(window_id, dimension_key)
    
    emit_signal("window_dimension_changed", window_id, old_dimension, dimension_key)
    return true

# ----- TRANSITION HANDLING -----
func _update_transitions(delta):
    var completed_transitions = []
    
    for window_id in active_transitions:
        var transition = active_transitions[window_id]
        transition.progress += delta / transition.duration
        
        if transition.progress >= 1.0:
            # Transition complete
            window_transforms[window_id] = transition.target_transform
            completed_transitions.append(window_id)
            
            emit_signal("window_transformed", window_id, transition.transform_type)
        else:
            # Update in-progress transition
            window_transforms[window_id] = transition.start_transform.interpolate_with(
                transition.target_transform,
                transition.progress
            )
    
    # Remove completed transitions
    for window_id in completed_transitions:
        active_transitions.erase(window_id)

func _sync_window_transforms():
    for window_ref in window_references:
        var window_id = window_ref.id
        
        if window_transforms.has(window_id):
            var transform = window_transforms[window_id]
            
            # Apply transform to window shader or canvas item
            if window_id == "main":
                # Apply to main window via shader or canvas
                if get_viewport().has_method("set_canvas_transform"):
                    get_viewport().set_canvas_transform(transform)
            elif window_ref.has("window") and is_instance_valid(window_ref.window):
                # Apply to sub-window
                if window_ref.window.has_method("set_canvas_transform"):
                    window_ref.window.set_canvas_transform(transform)
    
    emit_signal("windows_synchronized")

# ----- SPECIAL WINDOW EFFECTS -----
func _apply_ethereal_effect(window_id: String):
    # This would typically use shaders for the ethereal effect
    # Simplified version just applies a scale transform
    transform_window(window_id, "scale_up")
    
    # In a real implementation, you would apply a shader with pulsing transparency

func _apply_fractal_transformation(window_id: String):
    # Apply a fractal-based transformation
    # This effect would be based on the current dimension's fractal points
    
    # For now, just apply a random transform from the available matrices
    var transform_keys = transform_matrices.keys()
    var random_transform = transform_keys[randi() % transform_keys.size()]
    
    transform_window(window_id, random_transform)

func _prepare_dimensional_shift(window_id: String):
    # Set up the window for dimension shifting
    # This effect would prepare a smooth transition between dimensions
    
    # For now, just apply a sequence of transforms
    transform_window(window_id, "rotate_90")
    # In a real implementation, this would be a more elaborate sequence

func _update_window_color(window_id: String, dimension_key: String):
    # Generate color based on dimension properties
    var color = Color.WHITE
    
    if ethereal_bridge and dimension_properties.has(dimension_key):
        var properties = dimension_properties[dimension_key]
        
        match dimension_color_mode:
            "frequential":
                # Higher frequency = more blue
                var freq = properties.frequency
                color = Color(1.0 - freq, 1.0 - freq/2.0, freq)
            
            "stability":
                # Higher stability = more green
                var stability = properties.stability
                color = Color(1.0 - stability, stability, 1.0 - stability/2.0)
            
            "hybrid":
                # Combine frequency and stability
                var freq = properties.frequency
                var stability = properties.stability
                color = Color(
                    1.0 - (freq + stability)/2.0,
                    stability,
                    freq
                )
    
    window_colors[window_id] = color
    
    # Apply color to window
    # This would typically be done via a shader or other visual effect
    # For now, just store the color for reference

# ----- DIMENSION DATA HANDLERS -----
func _update_dimension_data():
    if not ethereal_bridge:
        return
    
    # Get current dimension
    if ethereal_bridge.has_method("get_dimension_fractal"):
        current_dimension = ethereal_bridge.get_property("current_dimension") if ethereal_bridge.has_method("get_property") else "0-0-0"
        
        # Update dimension stack
        if ethereal_bridge.has_property("dimension_stack"):
            dimension_stack = ethereal_bridge.dimension_stack.duplicate()
    
    # Get fractal data
    if ethereal_bridge.has_method("get_fractal_visualization_data"):
        var fractal_data = ethereal_bridge.get_fractal_visualization_data()
        
        if fractal_data.has("points"):
            fractal_points = fractal_data.points.duplicate()
            
            # Update dimension properties dictionary
            for point in fractal_points:
                if point.has("key"):
                    dimension_properties[point.key] = {
                        "frequency": point.frequency,
                        "stability": point.stability,
                        "position": point.position
                    }

func _on_fractal_data_updated(points):
    fractal_points = points.duplicate()
    
    # Update dimension properties
    for point in fractal_points:
        if point.has("key"):
            dimension_properties[point.key] = {
                "frequency": point.frequency,
                "stability": point.stability,
                "position": point.position
            }
    
    emit_signal("fractal_data_updated", fractal_points)

func _on_dimension_changed(previous, current):
    # Update current dimension
    current_dimension = current
    
    # Add to dimension stack
    dimension_stack.append(previous)
    if dimension_stack.size() > 12:
        dimension_stack.remove_at(0)
    
    # Update main window dimension
    window_dimensions["main"] = current
    _update_window_color("main", current)

# ----- PUBLIC API -----
func get_window_list():
    var result = []
    for window_ref in window_references:
        result.append({
            "id": window_ref.id,
            "state": window_states.get(window_ref.id, WindowState.NORMAL),
            "dimension": window_dimensions.get(window_ref.id, current_dimension),
            "position": window_positions.get(window_ref.id, Vector2.ZERO),
            "size": window_ref.size if window_ref.has("size") else base_window_size
        })
    return result

func arrange_windows_in_pattern(pattern_name: String):
    if not window_patterns.has(pattern_name):
        print("Pattern not found: " + pattern_name)
        return false
    
    var pattern = window_patterns[pattern_name]
    var points = pattern.points
    var transforms = pattern.transform_sequence
    
    # Ensure we have enough windows
    var window_count = min(window_references.size(), points.size())
    
    # Position windows according to pattern
    for i in range(window_count):
        var window_ref = window_references[i]
        var point = points[i]
        var transform_type = transforms[i % transforms.size()]
        
        # Set window position based on pattern point
        var screen_size = DisplayServer.screen_get_size()
        var position = Vector2(
            point.x * (screen_size.x - window_ref.size.x),
            point.y * (screen_size.y - window_ref.size.y)
        )
        
        set_window_position(window_ref.id, position)
        transform_window(window_ref.id, transform_type)
    
    return true

func create_dimensional_window_set(dimension_keys: Array):
    # Create a window for each dimension
    var created_windows = []
    
    for i in range(min(dimension_keys.size(), max_window_instances - window_references.size())):
        var dimension = dimension_keys[i]
        var window_id = "dim_" + dimension
        
        var window = create_window(window_id)
        if window:
            change_window_dimension(window_id, dimension)
            created_windows.append(window_id)
    
    return created_windows

func set_window_transform_speed(speed: float):
    window_transform_speed = max(0.1, speed)
    window_transition_duration = 1.0 / window_transform_speed
    return window_transform_speed

func generate_window_from_coordinates(x: int, y: int, z: int):
    if not ethereal_bridge or not ethereal_bridge.has_method("get_dimension_at_coordinates"):
        return null
    
    var dimension_key = ethereal_bridge.get_dimension_at_coordinates(x, y, z)
    if not dimension_key:
        return null
    
    var window_id = "dim_" + dimension_key
    var window = create_window(window_id)
    
    if window:
        change_window_dimension(window_id, dimension_key)
        
        # Position based on coordinates
        var position = Vector2(
            (x + dimensional_depth) * 100,
            (y + dimensional_depth) * 100
        )
        set_window_position(window_id, position)
        
        # Scale based on z coordinate
        var scale_factor = 1.0 + (z / float(dimensional_depth) * 0.5)
        set_window_size(window_id, base_window_size * scale_factor)
    
    return window

func combine_windows(window_ids: Array, pattern_name: String = ""):
    if window_ids.size() < 2:
        return false
    
    # If pattern provided, arrange windows in that pattern first
    if pattern_name != "" and window_patterns.has(pattern_name):
        var pattern = window_patterns[pattern_name]
        var points = pattern.points
        var transforms = pattern.transform_sequence
        
        for i in range(min(window_ids.size(), points.size())):
            var window_id = window_ids[i]
            if window_transforms.has(window_id):
                # Set position based on pattern
                var screen_size = DisplayServer.screen_get_size()
                var position = Vector2(
                    points[i].x * screen_size.x / 2,
                    points[i].y * screen_size.y / 2
                )
                
                set_window_position(window_id, position)
                
                # Apply transform
                var transform_type = transforms[i % transforms.size()]
                transform_window(window_id, transform_type)
    
    # In a real implementation, this would do more to visually combine the windows
    return true

func split_window(window_id: String, split_count: int = 2):
    if not window_dimensions.has(window_id):
        return []
    
    # Get original window's dimension and size
    var original_dimension = window_dimensions[window_id]
    var original_size = null
    var original_position = null
    
    for window_ref in window_references:
        if window_ref.id == window_id:
            original_size = window_ref.size if window_ref.has("size") else base_window_size
            original_position = window_positions.get(window_id, Vector2.ZERO)
            break
    
    if not original_size or not original_position:
        return []
    
    # Create new windows
    var new_windows = []
    for i in range(split_count):
        var new_id = window_id + "_split_" + str(i)
        
        # Calculate new position with offset
        var offset = Vector2(
            (i % 2) * original_size.x * 0.6,
            (i / 2) * original_size.y * 0.6
        )
        var new_position = original_position + offset
        
        # Calculate new size (smaller than original)
        var new_size = original_size * (0.7 / sqrt(split_count))
        
        # Create new window
        var window = create_window(new_id, new_size, new_position)
        if window:
            # Inherit dimension
            change_window_dimension(new_id, original_dimension)
            
            # Apply a transform
            var transform_keys = transform_matrices.keys()
            var random_transform = transform_keys[i % transform_keys.size()]
            transform_window(new_id, random_transform)
            
            new_windows.append(new_id)
    
    return new_windows