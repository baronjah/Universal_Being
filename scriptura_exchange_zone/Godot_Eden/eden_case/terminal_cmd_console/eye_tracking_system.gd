extends Node2D

# eye_tracking_system.gd
# Simulated eye tracking system that creates realistic gaze patterns
# and provides visual feedback for attention-aware interfaces

# Configuration
export var enable_eye_tracking = true
export var gaze_smoothing = 0.15  # Lower = smoother
export var gaze_inertia = 0.8  # Higher = more inertia
export var attention_threshold = 1.2  # Seconds before considering "focused"
export var saccade_frequency = 0.8  # How often to make small eye movements
export var natural_movement = true  # Enable more realistic eye movement patterns
export var show_debug_cursor = true  # Show visual indicator of gaze position

# Visual settings
export var cursor_size = 12.0
export var cursor_color = Color(1.0, 1.0, 1.0, 0.3)
export var focus_color = Color(1.0, 0.8, 0.2, 0.5)
export var attention_radius = 80.0  # Radius of attention visualization
export var heatmap_enabled = true  # Show gaze heatmap

# Tracking state
var current_gaze_position = Vector2.ZERO
var target_gaze_position = Vector2.ZERO
var mouse_position = Vector2.ZERO
var gaze_velocity = Vector2.ZERO
var is_tracking = false
var viewport_size = Vector2.ZERO

# Attention tracking
var attention_points = {}  # Dictionary of points with accumulated attention
var current_attention_point = null
var current_attention_time = 0.0
var heatmap_points = []  # For visualization

# Random movement
var saccade_timer = 0.0
var next_saccade_time = 0.0
var saccade_target = Vector2.ZERO
var is_in_saccade = false

# Referenced systems
var visual_zone_system = null
var center_projection_system = null

# Signals
signal gaze_moved(position, velocity)
signal attention_focused(position, duration)
signal attention_lost(position, duration)

# ===== INITIALIZATION =====

func _ready():
    # Initialize with center position
    viewport_size = get_viewport_rect().size
    current_gaze_position = viewport_size / 2
    target_gaze_position = current_gaze_position
    
    # Connect to other systems
    _connect_to_systems()
    
    # Set up processing
    set_process(true)
    set_process_input(true)
    
    # Initialize heatmap
    if heatmap_enabled:
        _initialize_heatmap()

# Connect to required systems
func _connect_to_systems():
    # Try to find visual_zone_system
    visual_zone_system = get_node_or_null("/root/VisualZoneSystem")
    if not visual_zone_system and get_parent():
        visual_zone_system = get_parent().get_node_or_null("VisualZoneSystem")
    
    # Try to find center_projection_system
    center_projection_system = get_node_or_null("/root/CenterProjectionSystem")
    if not center_projection_system and get_parent():
        center_projection_system = get_parent().get_node_or_null("CenterProjectionSystem")

# Initialize heatmap for visualization
func _initialize_heatmap():
    heatmap_points.clear()
    
    # Create initial sparse grid of heatmap points
    var grid_size = 20
    var x_count = int(viewport_size.x / grid_size)
    var y_count = int(viewport_size.y / grid_size)
    
    for x in range(x_count):
        for y in range(y_count):
            var point = {
                "position": Vector2(x * grid_size + grid_size/2, y * grid_size + grid_size/2),
                "heat": 0.0,
                "radius": grid_size * 0.8
            }
            heatmap_points.append(point)

# ===== MAIN LOOPS =====

func _process(delta):
    if not enable_eye_tracking:
        return
    
    # Update gaze position with physics
    _update_gaze_position(delta)
    
    # Update attention tracking
    _update_attention(delta)
    
    # Update heatmap if enabled
    if heatmap_enabled:
        _update_heatmap(delta)
    
    # Integrate with other systems
    _integrate_with_systems()
    
    # Trigger redraw
    update()

func _input(event):
    # Track mouse position as primary target
    if event is InputEventMouseMotion:
        mouse_position = event.position
        
        # Only use mouse position as target if we're not in natural movement mode
        # or if the mouse is moving significantly
        if not natural_movement or event.speed.length() > 50:
            target_gaze_position = mouse_position
            is_in_saccade = false

# ===== GAZE PHYSICS =====

# Update gaze position with physics model
func _update_gaze_position(delta):
    if natural_movement:
        _update_natural_eye_movement(delta)
    
    # Physics-based smoothing
    var desired_velocity = (target_gaze_position - current_gaze_position) / gaze_smoothing
    gaze_velocity = gaze_velocity.linear_interpolate(desired_velocity, (1.0 - gaze_inertia) * delta * 60.0)
    
    # Apply velocity with delta
    var movement = gaze_velocity * delta
    
    # Limit maximum movement per frame for stability
    var max_movement = 100.0 * delta
    if movement.length() > max_movement:
        movement = movement.normalized() * max_movement
    
    # Update position
    current_gaze_position += movement
    
    # Ensure position stays within viewport
    current_gaze_position.x = clamp(current_gaze_position.x, 0, viewport_size.x)
    current_gaze_position.y = clamp(current_gaze_position.y, 0, viewport_size.y)
    
    # Emit signal if moved significantly
    if movement.length() > 1.0:
        emit_signal("gaze_moved", current_gaze_position, gaze_velocity)

# Update more realistic eye movement patterns
func _update_natural_eye_movement(delta):
    # Update saccade timer
    saccade_timer += delta
    
    # Check if time for a new saccade
    if not is_in_saccade and saccade_timer > next_saccade_time:
        # Start a new saccade
        is_in_saccade = true
        
        # 80% of saccades are small, 20% are larger
        var saccade_type = "small" if randf() < 0.8 else "large"
        
        if saccade_type == "small":
            # Small movement near current position
            var angle = randf() * TAU
            var distance = 20.0 + randf() * 40.0
            saccade_target = current_gaze_position + Vector2(cos(angle), sin(angle)) * distance
        else:
            # Larger movement or to mouse position
            if randf() < 0.7:
                # Use mouse position
                saccade_target = mouse_position
            else:
                # Random position in viewport
                saccade_target = Vector2(
                    randf() * viewport_size.x,
                    randf() * viewport_size.y
                )
        
        # Clamp target to viewport
        saccade_target.x = clamp(saccade_target.x, 0, viewport_size.x)
        saccade_target.y = clamp(saccade_target.y, 0, viewport_size.y)
        
        # Set as target
        target_gaze_position = saccade_target
        
        # Reset timer and set next saccade time
        saccade_timer = 0.0
        next_saccade_time = 0.5 + randf() * (1.0 / saccade_frequency)
    
    # Check if saccade is complete
    if is_in_saccade and current_gaze_position.distance_to(saccade_target) < 5.0:
        is_in_saccade = false

# ===== ATTENTION TRACKING =====

# Update attention based on gaze position
func _update_attention(delta):
    # Check if gaze is relatively still
    var is_gaze_still = gaze_velocity.length() < 50.0
    
    if is_gaze_still:
        # Get current region under gaze
        var key = _get_attention_key(current_gaze_position)
        
        # If we have a current attention point and still looking at it
        if current_attention_point and current_attention_point == key:
            current_attention_time += delta
            
            # If passed threshold and not yet reported
            if current_attention_time >= attention_threshold and not attention_points.has(key):
                # Add to attention points
                attention_points[key] = {
                    "position": current_gaze_position,
                    "time": current_attention_time,
                    "intensity": 0.0
                }
                
                # Signal that attention is focused
                emit_signal("attention_focused", current_gaze_position, current_attention_time)
            
            # Update existing point intensity
            if attention_points.has(key):
                var point = attention_points[key]
                point.time += delta
                point.intensity = min(1.0, point.time / 5.0)  # Max intensity after 5 seconds
                
                # Update heatmap
                if heatmap_enabled:
                    _add_heat_to_position(current_gaze_position, delta * 0.2)
        else:
            # Looking at a new point
            if current_attention_point:
                # Signal lost attention on previous point
                emit_signal("attention_lost", current_gaze_position, current_attention_time)
            
            # Reset
            current_attention_point = key
            current_attention_time = 0.0
    else:
        # Gaze is moving fast
        if current_attention_point:
            # Signal lost attention
            emit_signal("attention_lost", current_gaze_position, current_attention_time)
            
            # Reset
            current_attention_point = null
            current_attention_time = 0.0

# Generate a unique key for an attention point
func _get_attention_key(position):
    # Quantize position to avoid tiny movements creating new points
    var grid_size = 30
    var x = int(position.x / grid_size)
    var y = int(position.y / grid_size)
    return str(x) + "_" + str(y)

# ===== HEATMAP MANAGEMENT =====

# Update heatmap visualization
func _update_heatmap(delta):
    # Gradually cool down all points
    for point in heatmap_points:
        point.heat = max(0.0, point.heat - delta * 0.05)

# Add heat to a specific position
func _add_heat_to_position(position, amount):
    # Find nearby heatmap points and add heat
    for point in heatmap_points:
        var distance = position.distance_to(point.position)
        
        # Heat dissipates with distance (inverse square)
        if distance < point.radius * 2:
            var factor = 1.0 - (distance / (point.radius * 2))
            point.heat = min(1.0, point.heat + amount * factor * factor)

# ===== SYSTEM INTEGRATION =====

# Integrate with other systems
func _integrate_with_systems():
    # Update visual zone system
    if visual_zone_system:
        visual_zone_system.set_gaze_position(current_gaze_position)
    
    # Update center projection
    if center_projection_system:
        # Pass focus points for loading zones
        if current_attention_point and current_attention_time > attention_threshold:
            center_projection_system.update_loading_zones(current_gaze_position)

# ===== RENDERING =====

func _draw():
    if not enable_eye_tracking or not show_debug_cursor:
        return
    
    # Draw heatmap if enabled
    if heatmap_enabled:
        _draw_heatmap()
    
    # Draw attention points
    for key in attention_points:
        var point = attention_points[key]
        var color = focus_color
        color.a = min(0.7, point.intensity)
        
        draw_circle(point.position, attention_radius * point.intensity, color)
    
    # Draw gaze cursor
    var cursor_alpha = 0.2 + 0.3 * sin(OS.get_ticks_msec() / 500.0)
    var current_cursor_color = cursor_color
    current_cursor_color.a = cursor_alpha
    
    draw_circle(current_gaze_position, cursor_size, current_cursor_color)
    
    # Draw gaze target if in debug
    if OS.is_debug_build():
        draw_circle(target_gaze_position, cursor_size * 0.5, Color(1, 0, 0, 0.3))

# Draw heatmap visualization
func _draw_heatmap():
    for point in heatmap_points:
        if point.heat > 0.01:  # Only draw visible points
            var color = Color(1.0, 0.3, 0.0, point.heat * 0.3)  # Orange heat color
            draw_circle(point.position, point.radius * (0.5 + point.heat * 0.5), color)

# ===== PUBLIC API =====

# Enable/disable eye tracking
func set_tracking_enabled(enabled):
    enable_eye_tracking = enabled
    return enabled

# Force gaze to a specific position
func set_gaze_position(position):
    if position is Vector2:
        current_gaze_position = position
        target_gaze_position = position
        return true
    return false

# Set natural movement parameters
func set_natural_movement(enabled, saccade_freq=0.8):
    natural_movement = enabled
    saccade_frequency = saccade_freq
    return natural_movement

# Clear all attention data
func clear_attention_data():
    attention_points.clear()
    current_attention_point = null
    current_attention_time = 0.0
    
    # Reset heatmap
    if heatmap_enabled:
        for point in heatmap_points:
            point.heat = 0.0
    
    return true

# Get all attention areas
func get_attention_areas():
    var result = []
    
    for key in attention_points:
        result.append(attention_points[key])
    
    return result

# Get the most focused area
func get_most_focused_area():
    var max_intensity = 0.0
    var max_point = null
    
    for key in attention_points:
        var point = attention_points[key]
        if point.intensity > max_intensity:
            max_intensity = point.intensity
            max_point = point
    
    return max_point

# Add an artificial attention point
func add_attention_point(position, intensity=0.5, time=2.0):
    var key = _get_attention_key(position)
    
    attention_points[key] = {
        "position": position,
        "time": time,
        "intensity": intensity
    }
    
    # Add to heatmap
    if heatmap_enabled:
        _add_heat_to_position(position, intensity)
    
    return key

# Calibrate the eye tracking (simulate calibration process)
func calibrate():
    # In a real implementation, this would perform actual calibration
    # For simulation, we'll just reset and return success
    
    # Reset state
    clear_attention_data()
    
    # Simulate calibration process
    var calibration_points = [
        Vector2(100, 100),
        Vector2(viewport_size.x - 100, 100),
        Vector2(viewport_size.x - 100, viewport_size.y - 100),
        Vector2(100, viewport_size.y - 100),
        Vector2(viewport_size.x / 2, viewport_size.y / 2)
    ]
    
    # Animate to each point
    for point in calibration_points:
        set_gaze_position(point)
        # In a real implementation, we'd wait for user confirmation
        # yield(get_tree().create_timer(1.0), "timeout")
    
    # Return to center
    set_gaze_position(Vector2(viewport_size.x / 2, viewport_size.y / 2))
    
    return true