extends Node

# center_projection_system.gd
# Advanced projection system that uses center-based coordinates
# with fractal loading zones and data easing for optimal performance

# Configuration
export var use_center_projection = true
export var use_fractal_loading = true
export var ease_data_checks = true
export var viewport_scale = 1.0
export var max_loading_zones = 9
export var gradient_smoothing = 0.5
export var ocr_enabled = true

# Constants
const FRACTAL_DEPTH = 4
const CENTER_BIAS = 0.66  # 66% center focus
const DATA_CHECK_INTERVAL = 0.1  # seconds
const BRACKET_SIZE_LIMIT = 99

# State variables
var viewport_size = Vector2.ZERO
var center_point = Vector2.ZERO
var loading_zones = []
var fractal_boundaries = []
var bracket_sizes = {}
var check_time_accumulator = 0.0
var ocr_data_cache = {}
var gradient_footprints = {}

# Signals
signal zone_loaded(zone_id)
signal data_bracket_changed(bracket_id, size)
signal ocr_text_detected(text, position, confidence)

# Reference to dependencies
var data_pack_system = null
var quantum_terminal = null

# ===== CORE FUNCTIONALITY =====

func _ready():
    # Initialize center point
    _update_viewport_size()
    
    # Setup loading zones
    if use_fractal_loading:
        _generate_fractal_loading_zones()
    
    # Connect to existing systems if possible
    _connect_to_systems()

func _process(delta):
    # Update time accumulator for data checks
    if ease_data_checks:
        check_time_accumulator += delta
        if check_time_accumulator >= DATA_CHECK_INTERVAL:
            check_time_accumulator = 0.0
            _perform_data_checks()
    
    # Update fractal zones if viewport changed
    if viewport_size != get_viewport().size:
        _update_viewport_size()
        if use_fractal_loading:
            _generate_fractal_loading_zones()

# ===== CENTER PROJECTION SYSTEM =====

# Convert absolute coordinates to center-relative
func to_center_coordinates(position):
    if not use_center_projection:
        return position
    
    var relative_pos = position - center_point
    return relative_pos

# Convert center-relative coordinates to absolute
func from_center_coordinates(center_relative_position):
    if not use_center_projection:
        return center_relative_position
    
    return center_point + center_relative_position

# Transform input position using center projection rules
func transform_position(position):
    if not use_center_projection:
        return position
    
    # Convert to center coordinates
    var center_relative = to_center_coordinates(position)
    
    # Apply center bias (objects closer to center appear more prominent)
    var distance_from_center = center_relative.length()
    var max_distance = min(viewport_size.x, viewport_size.y) * 0.5
    var factor = 1.0 - (distance_from_center / max_distance) * (1.0 - CENTER_BIAS)
    
    # Scale based on bias factor
    center_relative *= factor
    
    # Convert back to absolute coordinates
    return from_center_coordinates(center_relative)

# Transform input trajectory (direction + speed)
func transform_trajectory(position, direction, speed):
    if not use_center_projection:
        return {"position": position, "direction": direction, "speed": speed}
    
    # Get center distance factor (faster near edges, slower in center)
    var center_relative = to_center_coordinates(position)
    var distance_from_center = center_relative.length()
    var max_distance = min(viewport_size.x, viewport_size.y) * 0.5
    var distance_factor = distance_from_center / max_distance
    
    # Adjust speed based on distance from center (paradox effect)
    var adjusted_speed = speed * (0.5 + distance_factor)
    
    # Adjust direction to curve slightly around center
    var perpendicular = Vector2(-center_relative.y, center_relative.x).normalized()
    var curve_strength = 0.2 * (1.0 - distance_factor)
    var curved_direction = direction.normalized().linear_interpolate(perpendicular, curve_strength)
    
    return {
        "position": transform_position(position),
        "direction": curved_direction,
        "speed": adjusted_speed
    }

# Update the viewport size and center point
func _update_viewport_size():
    var viewport = get_viewport()
    if viewport:
        viewport_size = viewport.size * viewport_scale
        center_point = viewport_size * 0.5

# ===== FRACTAL LOADING ZONES =====

# Generate fractal loading zones
func _generate_fractal_loading_zones():
    loading_zones.clear()
    fractal_boundaries.clear()
    
    # Create initial zone (full screen)
    var root_zone = {
        "id": 0,
        "rect": Rect2(Vector2.ZERO, viewport_size),
        "level": 0,
        "loaded": true,
        "active": true,
        "parent": -1,
        "children": []
    }
    
    loading_zones.append(root_zone)
    
    # Generate fractal subdivisions
    _subdivide_zone(0, FRACTAL_DEPTH)
    
    # Generate boundaries between zones
    _generate_boundaries()

# Recursively subdivide a zone into subzones
func _subdivide_zone(zone_index, depth):
    if depth <= 0 or zone_index >= loading_zones.size():
        return
    
    var zone = loading_zones[zone_index]
    var rect = zone.rect
    
    # Calculate subdivision points with golden ratio bias toward center
    # Instead of even splits, we bias toward the center
    var golden_ratio = 1.618033988749895
    var h_ratio = 1.0 / (1.0 + golden_ratio)
    var v_ratio = 1.0 / (1.0 + golden_ratio)
    
    # Adjust ratio based on distance from center
    var zone_center = rect.position + rect.size * 0.5
    var dist_from_center = (zone_center - center_point).length()
    var max_dist = center_point.length()
    var center_factor = 1.0 - min(1.0, dist_from_center / max_dist)
    
    # Adjust splits to bias more toward center when closer to center
    h_ratio = lerp(0.5, h_ratio, center_factor)
    v_ratio = lerp(0.5, v_ratio, center_factor)
    
    # Create 4 child zones
    var split_h = rect.position.x + rect.size.x * h_ratio
    var split_v = rect.position.y + rect.size.y * v_ratio
    
    var rects = [
        Rect2(rect.position, Vector2(split_h - rect.position.x, split_v - rect.position.y)),
        Rect2(Vector2(split_h, rect.position.y), Vector2(rect.position.x + rect.size.x - split_h, split_v - rect.position.y)),
        Rect2(Vector2(rect.position.x, split_v), Vector2(split_h - rect.position.x, rect.position.y + rect.size.y - split_v)),
        Rect2(Vector2(split_h, split_v), Vector2(rect.position.x + rect.size.x - split_h, rect.position.y + rect.size.y - split_v))
    ]
    
    # Add child zones
    for i in range(4):
        var child_index = loading_zones.size()
        var child_zone = {
            "id": child_index,
            "rect": rects[i],
            "level": zone.level + 1,
            "loaded": false,
            "active": false,
            "parent": zone_index,
            "children": []
        }
        
        loading_zones.append(child_zone)
        zone.children.append(child_index)
        
        # Recursively subdivide if not at max depth
        if zone.level + 1 < depth:
            _subdivide_zone(child_index, depth)

# Generate boundaries between fractal zones
func _generate_boundaries():
    if loading_zones.size() <= 1:
        return
    
    fractal_boundaries.clear()
    
    # For simplicity, just use zone edges as boundaries
    for zone in loading_zones:
        var rect = zone.rect
        
        # Add rectangle outline as boundaries
        var top = {"start": rect.position, "end": Vector2(rect.position.x + rect.size.x, rect.position.y)}
        var right = {"start": Vector2(rect.position.x + rect.size.x, rect.position.y), "end": rect.position + rect.size}
        var bottom = {"start": Vector2(rect.position.x, rect.position.y + rect.size.y), "end": rect.position + rect.size}
        var left = {"start": rect.position, "end": Vector2(rect.position.x, rect.position.y + rect.size.y)}
        
        fractal_boundaries.append(top)
        fractal_boundaries.append(right)
        fractal_boundaries.append(bottom)
        fractal_boundaries.append(left)

# Activate/deactivate loading zones based on a focal point
func update_loading_zones(focal_point):
    if not use_fractal_loading or loading_zones.size() <= 1:
        return
    
    # Find the deepest zone that contains the focal point
    var active_zones = []
    var current_zone_index = 0  # Start with root
    
    while true:
        var zone = loading_zones[current_zone_index]
        active_zones.append(current_zone_index)
        
        # Check if point is in this zone
        if not zone.rect.has_point(focal_point):
            break
        
        # Find child that contains the point
        var found_child = false
        for child_index in zone.children:
            var child = loading_zones[child_index]
            if child.rect.has_point(focal_point):
                current_zone_index = child_index
                found_child = true
                break
        
        if not found_child:
            break
    
    # Activate zones containing focal point and immediate neighbors
    for i in range(loading_zones.size()):
        var should_activate = false
        
        # Check if in active path
        if active_zones.has(i):
            should_activate = true
        
        # Check if neighbor of active zone
        else:
            for active_idx in active_zones:
                var active_zone = loading_zones[active_idx]
                
                # Check if parent or child
                if active_zone.parent == i or (active_zone.children.has(i)):
                    should_activate = true
                    break
        
        # Update zone status
        var zone = loading_zones[i]
        var was_active = zone.active
        zone.active = should_activate
        
        # Load if needed
        if should_activate and not zone.loaded:
            zone.loaded = true
            emit_signal("zone_loaded", zone.id)

# ===== DATA HANDLING =====

# Perform periodic data checks with easing
func _perform_data_checks():
    if not ease_data_checks:
        return
    
    # Update bracket sizes
    _update_bracket_sizes()
    
    # Process OCR data if enabled
    if ocr_enabled:
        _process_ocr_queue()
    
    # Update gradient footprints
    _update_gradient_footprints()

# Update data bracket sizes
func _update_bracket_sizes():
    var changed = false
    
    # Update brackets from data_pack_system if available
    if data_pack_system != null:
        for i in range(min(12, data_pack_system.cycle_data.size())):
            var cycle = data_pack_system.cycle_data[i]
            var turn = cycle.turn
            
            # Calculate bracket size based on data and cycle
            var base_size = data_pack_system.data_packs.size() * (1.0 - (turn - 1) / 12.0)
            var size = min(int(base_size), BRACKET_SIZE_LIMIT)
            
            # Update if changed
            if not bracket_sizes.has(turn) or bracket_sizes[turn] != size:
                bracket_sizes[turn] = size
                emit_signal("data_bracket_changed", turn, size)
                changed = true
    
    return changed

# Process OCR text detection queue
func _process_ocr_queue():
    # This would interface with your OCR system
    # For now, just simulate processing
    if ocr_data_cache.size() > 0:
        var keys = ocr_data_cache.keys()
        var key = keys[randi() % keys.size()]
        var data = ocr_data_cache[key]
        
        # Simulate processing
        if randf() > 0.7:  # 30% chance to process an item
            emit_signal("ocr_text_detected", data.text, data.position, data.confidence)
            ocr_data_cache.erase(key)

# Update gradient footprints for OS/app shapes
func _update_gradient_footprints():
    # Update existing gradients
    for key in gradient_footprints.keys():
        var footprint = gradient_footprints[key]
        footprint.age += DATA_CHECK_INTERVAL
        
        # Fade out old footprints
        if footprint.age > footprint.lifespan:
            gradient_footprints.erase(key)
            continue
        
        # Update intensity
        var life_factor = 1.0 - (footprint.age / footprint.lifespan)
        footprint.intensity = footprint.initial_intensity * life_factor
    
    # Randomly generate new footprints for testing
    if randf() > 0.8 and gradient_footprints.size() < 10:  # 20% chance, max 10
        var new_key = "gradient_" + str(OS.get_ticks_msec())
        var pos = Vector2(randf() * viewport_size.x, randf() * viewport_size.y)
        
        gradient_footprints[new_key] = {
            "position": pos,
            "radius": 20.0 + randf() * 100.0,
            "color": Color(randf(), randf(), randf(), 0.3 + randf() * 0.5),
            "intensity": 0.5 + randf() * 0.5,
            "initial_intensity": 0.5 + randf() * 0.5,
            "age": 0.0,
            "lifespan": 3.0 + randf() * 7.0
        }

# ===== INTEGRATION METHODS =====

# Connect to existing systems
func _connect_to_systems():
    # Try to find data_pack_system
    var dps = get_node_or_null("/root/DataPackSystem")
    if dps:
        data_pack_system = dps
    
    # Check parent for data_pack_system
    if not data_pack_system and get_parent() and get_parent().has_node("DataPackSystem"):
        data_pack_system = get_parent().get_node("DataPackSystem")
    
    # Find quantum terminal
    var qt = get_node_or_null("/root/QuantumTerminal")
    if qt:
        quantum_terminal = qt

# ===== PUBLIC API =====

# Get loading zone at specified position
func get_zone_at_position(position):
    if not use_fractal_loading or loading_zones.size() == 0:
        return null
    
    for zone in loading_zones:
        if zone.active and zone.rect.has_point(position):
            return zone
    
    return null

# Add OCR text data to processing queue
func add_ocr_text(text, position, confidence=1.0):
    if not ocr_enabled:
        return false
    
    var key = "ocr_" + str(OS.get_ticks_msec())
    ocr_data_cache[key] = {
        "text": text,
        "position": position,
        "confidence": confidence,
        "timestamp": OS.get_unix_time()
    }
    
    return true

# Add a gradient footprint (e.g., for app shapes)
func add_gradient_footprint(position, radius, color, intensity=1.0, lifespan=5.0):
    var key = "gradient_" + str(OS.get_ticks_msec())
    gradient_footprints[key] = {
        "position": position,
        "radius": radius,
        "color": color,
        "intensity": intensity,
        "initial_intensity": intensity,
        "age": 0.0,
        "lifespan": lifespan
    }
    
    return key

# Get rendered gradient data for visualization
func get_gradient_data():
    return gradient_footprints

# Debug: visualize loading zones
func debug_draw_loading_zones(canvas_item):
    if not use_fractal_loading:
        return
    
    for zone in loading_zones:
        var color = Color.white
        if zone.active:
            color = Color.green
        color.a = 0.2
        
        # Draw zone rectangle
        canvas_item.draw_rect(zone.rect, color, false)
        
        # Draw zone ID
        var font = Control.new().get_font("font")
        var zone_center = zone.rect.position + zone.rect.size * 0.5
        canvas_item.draw_string(font, zone_center, str(zone.id), color)

# Debug: visualize boundaries
func debug_draw_boundaries(canvas_item):
    if not use_fractal_loading:
        return
    
    for boundary in fractal_boundaries:
        canvas_item.draw_line(boundary.start, boundary.end, Color(0.7, 0.7, 0.7, 0.3), 1.0)

# Apply weather effects based on system state
func apply_weather_effects(volume=1.0):
    # This would interface with your sound system
    # Example weather types based on system state
    var weather_types = ["calm", "storm", "rain", "wind", "thunder"]
    var current_weather = weather_types[current_cycle % weather_types.size()]
    
    # Signal to audio system (implement your sound interface here)
    # For now, just print debug info
    print("Weather changed to: %s (volume: %.2f)" % [current_weather, volume])
    
    return current_weather

# Get current LUNO cycle
var current_cycle = 1
func set_current_cycle(cycle):
    current_cycle = cycle
    # Update systems based on cycle
    _update_bracket_sizes()
    
    return current_cycle