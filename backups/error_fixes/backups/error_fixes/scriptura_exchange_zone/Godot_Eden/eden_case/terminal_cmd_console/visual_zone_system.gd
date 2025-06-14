extends Node2D

# visual_zone_system.gd
# Sophisticated visual interface system with multi-color gradient zones,
# rounded edges, and Apple-inspired design aesthetics

# Configuration
export var zone_count = 5
export var use_rounded_corners = true
export var corner_radius = 15.0
export var transition_duration = 0.3
export var default_zone_opacity = 0.6
export var highlight_zone_opacity = 0.85
export var border_thickness = 2.0
export var pattern_complexity = 99  # 99+ for advanced patterns

# Zone appearance
export var zone_colors = [
    Color(0.0, 0.5, 1.0, 1.0),   # Blue
    Color(0.8, 0.3, 1.0, 1.0),   # Purple
    Color(1.0, 0.4, 0.4, 1.0),   # Salmon/Red
    Color(1.0, 0.8, 0.0, 1.0),   # Gold
    Color(0.0, 0.8, 0.5, 1.0)    # Teal
]

export var secondary_colors = [
    Color(0.0, 0.7, 1.0, 1.0),   # Lighter blue
    Color(0.6, 0.4, 0.9, 1.0),   # Lighter purple
    Color(1.0, 0.6, 0.6, 1.0),   # Lighter salmon
    Color(1.0, 0.9, 0.4, 1.0),   # Lighter gold
    Color(0.4, 0.9, 0.7, 1.0)    # Lighter teal
]

export var tertiary_colors = [
    Color(0.2, 0.3, 0.9, 1.0),   # Darker blue
    Color(0.5, 0.2, 0.8, 1.0),   # Darker purple
    Color(0.8, 0.2, 0.2, 1.0),   # Darker red
    Color(0.9, 0.7, 0.0, 1.0),   # Darker gold
    Color(0.0, 0.6, 0.4, 1.0)    # Darker teal
]

# Internal state
var zones = []
var active_zone_index = -1
var gaze_position = Vector2.ZERO
var hover_position = Vector2.ZERO
var is_transition_active = false
var viewport_size = Vector2.ZERO

# Components
var center_projection_system = null
var tween_manager = null

# Signals
signal zone_activated(zone_index)
signal zone_deactivated(zone_index)
signal pattern_recognized(pattern_id, positions)

# ===== INITIALIZATION =====

func _ready():
    # Get viewport size
    viewport_size = get_viewport_rect().size
    
    # Initialize zones
    _create_zones()
    
    # Setup tween manager for smooth transitions
    tween_manager = Tween.new()
    add_child(tween_manager)
    
    # Connect to center projection system if available
    _connect_to_center_projection()
    
    # Misc setup
    set_process(true)
    set_process_input(true)

# Create interface zones
func _create_zones():
    zones.clear()
    
    # Calculate zone layout based on zone count
    var layouts = {
        3: _create_three_zone_layout(),
        4: _create_four_zone_layout(),
        5: _create_five_zone_layout()
    }
    
    var layout = layouts.get(zone_count, _create_five_zone_layout())
    
    # Create zone objects
    for i in range(layout.size()):
        var zone_info = layout[i]
        
        # Select colors
        var primary = zone_colors[i % zone_colors.size()]
        var secondary = secondary_colors[i % secondary_colors.size()]
        var tertiary = tertiary_colors[i % tertiary_colors.size()]
        
        var zone = {
            "index": i,
            "rect": zone_info.rect,
            "color": primary,
            "secondary_color": secondary,
            "tertiary_color": tertiary,
            "highlight": false,
            "active": false,
            "opacity": default_zone_opacity,
            "name": zone_info.name,
            "gradient_points": _generate_gradient_points(zone_info.rect),
            "pattern_points": _generate_pattern_points(zone_info.rect, pattern_complexity),
            "gaze_active": false,
            "interaction_weight": 0.0
        }
        
        zones.append(zone)

# Layout generators
func _create_three_zone_layout():
    var layout = []
    
    # Three zones - top, middle, bottom
    var top_height = viewport_size.y * 0.3
    var middle_height = viewport_size.y * 0.4
    var bottom_height = viewport_size.y * 0.3
    
    layout.append({
        "rect": Rect2(0, 0, viewport_size.x, top_height),
        "name": "Top Zone"
    })
    
    layout.append({
        "rect": Rect2(0, top_height, viewport_size.x, middle_height),
        "name": "Middle Zone"
    })
    
    layout.append({
        "rect": Rect2(0, top_height + middle_height, viewport_size.x, bottom_height),
        "name": "Bottom Zone"
    })
    
    return layout

func _create_four_zone_layout():
    var layout = []
    
    # Four zones - 2x2 grid
    var half_width = viewport_size.x * 0.5
    var half_height = viewport_size.y * 0.5
    
    layout.append({
        "rect": Rect2(0, 0, half_width, half_height),
        "name": "Top Left"
    })
    
    layout.append({
        "rect": Rect2(half_width, 0, half_width, half_height),
        "name": "Top Right"
    })
    
    layout.append({
        "rect": Rect2(0, half_height, half_width, half_height),
        "name": "Bottom Left"
    })
    
    layout.append({
        "rect": Rect2(half_width, half_height, half_width, half_height),
        "name": "Bottom Right"
    })
    
    return layout

func _create_five_zone_layout():
    var layout = []
    
    # Five zones - center with four corners
    var center_size = min(viewport_size.x, viewport_size.y) * 0.4
    var center_x = (viewport_size.x - center_size) * 0.5
    var center_y = (viewport_size.y - center_size) * 0.5
    
    # Center zone
    layout.append({
        "rect": Rect2(center_x, center_y, center_size, center_size),
        "name": "Center"
    })
    
    # Top left
    layout.append({
        "rect": Rect2(0, 0, center_x, center_y),
        "name": "Top Left"
    })
    
    # Top right
    layout.append({
        "rect": Rect2(center_x + center_size, 0, viewport_size.x - (center_x + center_size), center_y),
        "name": "Top Right"
    })
    
    # Bottom left
    layout.append({
        "rect": Rect2(0, center_y + center_size, center_x, viewport_size.y - (center_y + center_size)),
        "name": "Bottom Left"
    })
    
    # Bottom right
    layout.append({
        "rect": Rect2(center_x + center_size, center_y + center_size, 
                     viewport_size.x - (center_x + center_size), viewport_size.y - (center_y + center_size)),
        "name": "Bottom Right"
    })
    
    return layout

# Generate internal gradient points for a zone
func _generate_gradient_points(rect):
    var points = []
    
    # Create 3-5 gradient points
    var point_count = 3 + randi() % 3  # 3 to 5 points
    
    for i in range(point_count):
        var point = {
            "position": Vector2(
                rect.position.x + randf() * rect.size.x,
                rect.position.y + randf() * rect.size.y
            ),
            "radius": 20.0 + randf() * 100.0,
            "intensity": 0.6 + randf() * 0.4
        }
        points.append(point)
    
    return points

# Generate pattern points for advanced interactions
func _generate_pattern_points(rect, complexity):
    var points = []
    
    if complexity < 50:
        # Simple pattern - just corners and center
        points.append(rect.position)  # Top-left
        points.append(Vector2(rect.position.x + rect.size.x, rect.position.y))  # Top-right
        points.append(Vector2(rect.position.x, rect.position.y + rect.size.y))  # Bottom-left
        points.append(rect.position + rect.size)  # Bottom-right
        points.append(rect.position + rect.size * 0.5)  # Center
    else:
        # Complex pattern - Fibonacci spiral points
        var center = rect.position + rect.size * 0.5
        var min_dim = min(rect.size.x, rect.size.y) * 0.4
        
        # Golden ratio
        var phi = 1.618033988749895
        
        for i in range(9):
            var angle = i * TAU / phi
            var distance = min_dim * sqrt(float(i) / 8.0)  # Increasing distance
            var point = center + Vector2(cos(angle), sin(angle)) * distance
            
            # Ensure point is inside rect
            point.x = clamp(point.x, rect.position.x, rect.position.x + rect.size.x)
            point.y = clamp(point.y, rect.position.y, rect.position.y + rect.size.y)
            
            points.append(point)
    
    return points

# Connect to center projection system if available
func _connect_to_center_projection():
    # Try to find center_projection_system
    center_projection_system = get_node_or_null("/root/CenterProjectionSystem")
    
    if not center_projection_system:
        # Check parent
        if get_parent() and get_parent().has_node("CenterProjectionSystem"):
            center_projection_system = get_parent().get_node("CenterProjectionSystem")
    
    # If still not found, try global search
    if not center_projection_system:
        var cps = load("res://center_projection_system.gd")
        if cps:
            center_projection_system = cps.new()
            add_child(center_projection_system)

# ===== MAIN LOOPS =====

func _process(delta):
    # Update zone states
    _update_zone_states(delta)
    
    # Check for pattern recognition
    _check_patterns()
    
    # Update display
    update()  # Trigger redraw

func _input(event):
    # Track mouse position for hover effects
    if event is InputEventMouseMotion:
        hover_position = event.position
        _update_hover()
    
    # Handle clicks for zone activation
    elif event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
        _handle_click(event.position)

# ===== ZONE MANAGEMENT =====

# Update all zone states
func _update_zone_states(delta):
    for i in range(zones.size()):
        var zone = zones[i]
        
        # Update interaction weight based on gaze and hover
        var hover_weight = 1.0 if zone.rect.has_point(hover_position) else 0.0
        var gaze_weight = 1.0 if zone.rect.has_point(gaze_position) else 0.0
        
        var target_weight = max(hover_weight, gaze_weight * 0.7)  # Gaze is slightly less influential
        zone.interaction_weight = lerp(zone.interaction_weight, target_weight, delta * 3.0)
        
        # Update opacity based on interaction weight
        var target_opacity = lerp(default_zone_opacity, highlight_zone_opacity, zone.interaction_weight)
        
        if zone.active:
            target_opacity = highlight_zone_opacity
        
        zone.opacity = lerp(zone.opacity, target_opacity, delta * 5.0)
        
        # Update gradient points
        for point in zone.gradient_points:
            point.intensity = lerp(point.intensity, 0.6 + 0.4 * zone.interaction_weight, delta * 2.0)

# Update hover state
func _update_hover():
    for i in range(zones.size()):
        var zone = zones[i]
        var was_highlight = zone.highlight
        
        zone.highlight = zone.rect.has_point(hover_position)
        
        if zone.highlight != was_highlight and not is_transition_active:
            # Start transition animation
            _animate_zone_transition(i, zone.highlight)

# Handle mouse/touch clicks
func _handle_click(position):
    for i in range(zones.size()):
        var zone = zones[i]
        
        if zone.rect.has_point(position):
            # Toggle active state
            zone.active = !zone.active
            
            if zone.active:
                active_zone_index = i
                emit_signal("zone_activated", i)
            else:
                active_zone_index = -1
                emit_signal("zone_deactivated", i)
            
            # Animate transition
            _animate_zone_transition(i, zone.active)
            
            # Record interaction for pattern recognition
            _record_interaction(position)

# Animate zone transition
func _animate_zone_transition(zone_index, highlight):
    is_transition_active = true
    var zone = zones[zone_index]
    
    # Target opacity
    var target_opacity = highlight_zone_opacity if highlight else default_zone_opacity
    
    # Create animation
    tween_manager.interpolate_property(zone, "opacity", 
                                     zone.opacity, target_opacity, 
                                     transition_duration, 
                                     Tween.TRANS_QUAD, Tween.EASE_OUT)
    tween_manager.start()
    
    # Set up completion callback
    yield(tween_manager, "tween_completed")
    is_transition_active = false

# ===== PATTERN RECOGNITION =====

var interaction_history = []
var pattern_timeout = 2.0  # seconds
var pattern_timer = 0.0

# Record user interactions for pattern recognition
func _record_interaction(position):
    interaction_history.append({
        "position": position,
        "time": OS.get_ticks_msec() / 1000.0
    })
    
    # Reset timer
    pattern_timer = 0.0
    
    # Clean up old interactions
    _clean_interaction_history()

# Clean up old interaction history
func _clean_interaction_history():
    var current_time = OS.get_ticks_msec() / 1000.0
    
    var i = 0
    while i < interaction_history.size():
        if current_time - interaction_history[i].time > pattern_timeout:
            interaction_history.remove(i)
        else:
            i += 1

# Check for recognized patterns
func _check_patterns():
    # Update timer
    pattern_timer += get_process_delta_time()
    
    # If timer exceeds threshold, check for patterns
    if pattern_timer >= pattern_timeout and interaction_history.size() >= 3:
        var pattern_id = _identify_pattern()
        
        if pattern_id != -1:
            var positions = []
            for interaction in interaction_history:
                positions.append(interaction.position)
            
            emit_signal("pattern_recognized", pattern_id, positions)
        
        # Clear history after check
        interaction_history.clear()
        pattern_timer = 0.0

# Identify patterns in interaction history
func _identify_pattern():
    # Simple pattern identification based on number of points and shape
    var count = interaction_history.size()
    
    if count < 3:
        return -1
    
    # Check if points form a rough circle
    if count >= 5 and _is_circular_pattern():
        return 1  # Circle pattern
    
    # Check if points form a line
    if _is_linear_pattern():
        return 2  # Line pattern
    
    # Check if points form a zigzag
    if count >= 4 and _is_zigzag_pattern():
        return 3  # Zigzag pattern
    
    # Check for 'Z' pattern
    if count >= 3 and _is_z_pattern():
        return 4  # Z pattern
    
    # Default - unrecognized
    return -1

# Pattern detection helpers
func _is_circular_pattern():
    # Extract positions
    var positions = []
    for interaction in interaction_history:
        positions.append(interaction.position)
    
    # Find center and average radius
    var center = Vector2.ZERO
    for pos in positions:
        center += pos
    center /= positions.size()
    
    var avg_radius = 0.0
    for pos in positions:
        avg_radius += pos.distance_to(center)
    avg_radius /= positions.size()
    
    # Check if points are roughly equidistant from center
    var radius_variance = 0.0
    for pos in positions:
        var distance = pos.distance_to(center)
        radius_variance += abs(distance - avg_radius)
    radius_variance /= positions.size()
    
    # If variance is small relative to radius, it's circular
    return radius_variance / avg_radius < 0.3

func _is_linear_pattern():
    # Need at least 3 points
    if interaction_history.size() < 3:
        return false
    
    var positions = []
    for interaction in interaction_history:
        positions.append(interaction.position)
    
    # Calculate average angle
    var total_angle = 0.0
    var angle_count = 0
    
    for i in range(1, positions.size() - 1):
        var v1 = positions[i] - positions[i-1]
        var v2 = positions[i+1] - positions[i]
        
        if v1.length() > 0 and v2.length() > 0:
            var angle = abs(v1.angle_to(v2))
            total_angle += angle
            angle_count += 1
    
    if angle_count == 0:
        return false
    
    var avg_angle = total_angle / angle_count
    
    # If average angle is close to 0, points are roughly linear
    return avg_angle < 0.3

func _is_zigzag_pattern():
    # Need at least 4 points
    if interaction_history.size() < 4:
        return false
    
    var positions = []
    for interaction in interaction_history:
        positions.append(interaction.position)
    
    # Check for alternating angles
    var angles = []
    
    for i in range(1, positions.size() - 1):
        var v1 = positions[i] - positions[i-1]
        var v2 = positions[i+1] - positions[i]
        
        if v1.length() > 0 and v2.length() > 0:
            angles.append(v1.angle_to(v2))
    
    # Check if angles alternate sign
    var sign_changes = 0
    for i in range(1, angles.size()):
        if sign(angles[i]) != sign(angles[i-1]):
            sign_changes += 1
    
    # Zigzag has several sign changes
    return sign_changes >= angles.size() - 2

func _is_z_pattern():
    # Need exactly 3 points for Z
    if interaction_history.size() != 3:
        return false
    
    var p1 = interaction_history[0].position
    var p2 = interaction_history[1].position
    var p3 = interaction_history[2].position
    
    # Z pattern: p1 top-left, p2 top-right, p3 bottom-right
    var is_horizontal = abs(p1.y - p2.y) < abs(p1.x - p2.x)
    var is_diagonal = abs((p2.y - p3.y) / (p2.x - p3.x)) > 0.5
    
    return is_horizontal and is_diagonal

# ===== RENDERING =====

func _draw():
    # Draw zones
    for zone in zones:
        _draw_zone(zone)

# Draw an individual zone
func _draw_zone(zone):
    var rect = zone.rect
    var color = zone.color
    color.a = zone.opacity
    
    # Draw background
    if use_rounded_corners:
        _draw_rounded_rect(rect, color, corner_radius)
    else:
        draw_rect(rect, color)
    
    # Draw gradient points
    for point in zone.gradient_points:
        var gradient_color = zone.secondary_color
        gradient_color.a = point.intensity * zone.opacity
        
        # Draw gradient circle
        draw_circle(point.position, point.radius, gradient_color)
    
    # Draw border
    if zone.highlight or zone.active:
        var border_color = zone.tertiary_color
        border_color.a = zone.opacity
        
        if use_rounded_corners:
            _draw_rounded_rect_outline(rect, border_color, corner_radius, border_thickness)
        else:
            var inner_rect = Rect2(
                rect.position + Vector2(border_thickness, border_thickness),
                rect.size - Vector2(border_thickness * 2, border_thickness * 2)
            )
            draw_rect(rect, border_color)
            draw_rect(inner_rect, Color(0, 0, 0, 0), false)
    
    # Draw pattern points when debugging or for active zones
    if zone.active and pattern_complexity >= 99:
        for point in zone.pattern_points:
            draw_circle(point, 4.0, Color(1, 1, 1, 0.7 * zone.opacity))

# Draw a rounded rectangle
func _draw_rounded_rect(rect, color, radius):
    # Corners
    var top_left = rect.position
    var top_right = Vector2(rect.position.x + rect.size.x, rect.position.y)
    var bottom_left = Vector2(rect.position.x, rect.position.y + rect.size.y)
    var bottom_right = rect.position + rect.size
    
    # Draw corner arcs
    draw_circle(top_left + Vector2(radius, radius), radius, color)
    draw_circle(top_right + Vector2(-radius, radius), radius, color)
    draw_circle(bottom_left + Vector2(radius, -radius), radius, color)
    draw_circle(bottom_right + Vector2(-radius, -radius), radius, color)
    
    # Draw rect sections
    # Center
    draw_rect(Rect2(top_left.x + radius, top_left.y, rect.size.x - radius * 2, rect.size.y), color)
    # Left
    draw_rect(Rect2(top_left.x, top_left.y + radius, radius, rect.size.y - radius * 2), color)
    # Right
    draw_rect(Rect2(top_right.x - radius, top_right.y + radius, radius, rect.size.y - radius * 2), color)

# Draw a rounded rectangle outline
func _draw_rounded_rect_outline(rect, color, radius, thickness):
    # Draw outer rounded rect
    _draw_rounded_rect(rect, color, radius)
    
    # Draw inner rounded rect (hole)
    var inner_rect = Rect2(
        rect.position + Vector2(thickness, thickness),
        rect.size - Vector2(thickness * 2, thickness * 2)
    )
    
    # Use BLEND_SUB mode to cut out the inner rect
    _draw_rounded_rect(inner_rect, Color(1, 1, 1, 1), radius - thickness)

# ===== PUBLIC API =====

# Set gaze position (for eye tracking)
func set_gaze_position(position):
    gaze_position = position
    return position

# Activate a specific zone by index
func activate_zone(index):
    if index >= 0 and index < zones.size():
        zones[index].active = true
        active_zone_index = index
        
        # Animate transition
        _animate_zone_transition(index, true)
        
        emit_signal("zone_activated", index)
        return true
    
    return false

# Deactivate a specific zone by index
func deactivate_zone(index):
    if index >= 0 and index < zones.size() and zones[index].active:
        zones[index].active = false
        
        if active_zone_index == index:
            active_zone_index = -1
        
        # Animate transition
        _animate_zone_transition(index, false)
        
        emit_signal("zone_deactivated", index)
        return true
    
    return false

# Get active zone index
func get_active_zone():
    return active_zone_index

# Get zone at position
func get_zone_at_position(position):
    for i in range(zones.size()):
        if zones[i].rect.has_point(position):
            return i
    
    return -1

# Integrate with center projection system
func integrate_with_center_projection():
    if center_projection_system:
        # Update focal point based on active zone
        if active_zone_index >= 0:
            var zone = zones[active_zone_index]
            var focal_point = zone.rect.position + zone.rect.size * 0.5
            center_projection_system.update_loading_zones(focal_point)
        
        # Add gradient footprints for active zones
        for zone in zones:
            if zone.active or zone.interaction_weight > 0.5:
                var position = zone.rect.position + zone.rect.size * 0.5
                var radius = min(zone.rect.size.x, zone.rect.size.y) * 0.4
                center_projection_system.add_gradient_footprint(
                    position, radius, zone.color, zone.opacity, 2.0)
        
        return true
    
    return false