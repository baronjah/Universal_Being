extends Node

class_name GazeTrackingIntegration

# Apple-style eyeball tracking integration for Godot

# Constants
const CALIBRATION_POINTS = 9
const MIN_TRACKING_CONFIDENCE = 0.65
const SMOOTHING_FACTOR = 0.25
const UPDATE_FREQUENCY = 0.033 # ~30Hz

# Tracking state
var is_tracking_active = false
var is_calibrated = false
var tracking_confidence = 0.0
var raw_gaze_point = Vector2(0.5, 0.5)
var smoothed_gaze_point = Vector2(0.5, 0.5)
var gaze_history = []
var calibration_points = []
var calibration_matrices = []
var device_capabilities = {}
var screen_dimensions = Vector2(1920, 1080)
var last_update_time = 0
var fixation_threshold = 0.05
var fixation_time_threshold = 0.3
var current_fixation_point = Vector2(0, 0)
var current_fixation_duration = 0
var heatmap_data = {}
var tracking_quality = "unknown"
var device_with_lidar = false

# Connections
var keyboard_manager = null
var shape_manager = null
var external_device = null

# Signals
signal gaze_updated(point, confidence)
signal calibration_completed(success)
signal fixation_detected(point, duration)
signal tracking_quality_changed(quality)
signal device_connected(device_info)

func _ready():
    # Detect device capabilities
    detect_device_capabilities()
    
    # Set up update timer
    var timer = Timer.new()
    timer.wait_time = UPDATE_FREQUENCY
    timer.autostart = true
    timer.connect("timeout", self, "_on_tracking_update")
    add_child(timer)
    
    # Initialize calibration points
    _generate_calibration_points()
    
    # Connect to keyboard manager if available
    connect_to_keyboard_manager()

func _process(delta):
    # Process fixations
    if is_tracking_active and is_calibrated:
        # Check if gaze point is stable enough to be a fixation
        var distance = smoothed_gaze_point.distance_to(current_fixation_point)
        
        if distance < fixation_threshold:
            # Continue existing fixation
            current_fixation_duration += delta
            
            # Emit signal when fixation exceeds threshold
            if current_fixation_duration >= fixation_time_threshold:
                emit_signal("fixation_detected", current_fixation_point, current_fixation_duration)
                
                # Update heatmap data
                _update_heatmap(current_fixation_point, current_fixation_duration)
        else:
            # Start new fixation
            current_fixation_point = smoothed_gaze_point
            current_fixation_duration = 0

func detect_device_capabilities():
    # Detect current device capabilities
    var device_info = {
        "platform": OS.get_name(),
        "model": OS.get_model_name(),
        "screen_dpi": OS.get_screen_dpi(),
        "screen_size": OS.get_screen_size(),
        "front_camera": false,
        "lidar_sensor": false,
        "processing_cores": OS.get_processor_count()
    }
    
    # Simulate detection of camera and LiDAR based on platform/model
    if device_info["platform"] == "iOS" or device_info["platform"] == "Android":
        device_info["front_camera"] = true
        
        # Check for LiDAR-capable devices (iPhone 12 Pro and newer, iPad Pro 2020 and newer)
        var model = device_info["model"]
        if model.find("iPhone 12 Pro") != -1 or model.find("iPhone 13 Pro") != -1 or \
           model.find("iPhone 14 Pro") != -1 or model.find("iPhone 15 Pro") != -1 or \
           model.find("iPad Pro") != -1:
            device_info["lidar_sensor"] = true
    
    device_capabilities = device_info
    device_with_lidar = device_info["lidar_sensor"]
    
    # Update tracking quality based on device capabilities
    if device_with_lidar:
        tracking_quality = "high"
    elif device_info["front_camera"]:
        tracking_quality = "medium"
    else:
        tracking_quality = "low"
    
    emit_signal("tracking_quality_changed", tracking_quality)
    emit_signal("device_connected", device_info)
    
    print("Detected device: " + device_info["platform"] + " " + device_info["model"])
    print("Eye tracking quality: " + tracking_quality)
    
    return device_capabilities

func connect_to_keyboard_manager():
    # Find keyboard manager node
    if has_node("/root/KeyboardShapeManager") or get_node_or_null("/root/KeyboardShapeManager"):
        keyboard_manager = get_node("/root/KeyboardShapeManager")
        print("Connected to keyboard shape manager")
        return true
    
    # Try to find shape manager
    if has_node("/root/SmartAccountSystem/KeyboardShapeManager") or get_node_or_null("/root/SmartAccountSystem/KeyboardShapeManager"):
        keyboard_manager = get_node("/root/SmartAccountSystem/KeyboardShapeManager")
        print("Connected to keyboard shape manager")
        return true
    
    return false

func start_tracking():
    if tracking_quality == "low":
        print("Device has insufficient capabilities for eye tracking")
        return false
    
    is_tracking_active = true
    last_update_time = OS.get_ticks_msec()
    print("Eye tracking started")
    return true

func stop_tracking():
    is_tracking_active = false
    print("Eye tracking stopped")
    return true

func calibrate():
    # Reset calibration data
    calibration_points = []
    calibration_matrices = []
    is_calibrated = false
    
    # Generate calibration points
    _generate_calibration_points()
    
    # In a real implementation, would guide user through calibration process
    # For this demo, simulate successful calibration
    yield(get_tree().create_timer(2.0), "timeout")
    
    # Simulate calibration result
    var success = true
    is_calibrated = success
    
    if success:
        tracking_confidence = 0.85
    else:
        tracking_confidence = 0.4
    
    emit_signal("calibration_completed", success)
    print("Calibration " + ("successful" if success else "failed"))
    return success

func _generate_calibration_points():
    # Generate a grid of calibration points
    calibration_points = []
    
    var rows = 3
    var cols = 3
    
    for r in range(rows):
        for c in range(cols):
            var point = Vector2(
                (c + 0.5) / cols,
                (r + 0.5) / rows
            )
            calibration_points.append(point)
    
    return calibration_points

func _on_tracking_update():
    if not is_tracking_active:
        return
    
    # Update gaze tracking
    _update_gaze_point()
    
    # Update keyboard manager if connected
    if keyboard_manager and keyboard_manager.has_method("update_eye_position"):
        keyboard_manager.update_eye_position(smoothed_gaze_point)

func _update_gaze_point():
    # In a real implementation, would get data from eye tracking hardware
    # For this demo, simulate eye movement
    
    var now = OS.get_ticks_msec()
    var time_delta = (now - last_update_time) / 1000.0
    last_update_time = now
    
    # Simulate natural eye movement
    if is_calibrated:
        # More precise movement when using LiDAR
        var movement_scale = 0.02 if device_with_lidar else 0.05
        
        # Simulate natural eye movement with noise
        raw_gaze_point.x += (randf() - 0.5) * movement_scale
        raw_gaze_point.y += (randf() - 0.5) * movement_scale
        
        # Apply simulated tracking confidence
        if randf() > 0.95:
            # Occasional tracking loss
            tracking_confidence = randf() * 0.3
        else:
            # Normal tracking
            tracking_confidence = 0.7 + randf() * 0.3
        
        # Clamp to valid range
        raw_gaze_point.x = clamp(raw_gaze_point.x, 0.0, 1.0)
        raw_gaze_point.y = clamp(raw_gaze_point.y, 0.0, 1.0)
        
        # Apply smoothing
        smoothed_gaze_point = smoothed_gaze_point.linear_interpolate(
            raw_gaze_point,
            SMOOTHING_FACTOR
        )
        
        # Add to history
        gaze_history.append({
            "point": smoothed_gaze_point,
            "time": now,
            "confidence": tracking_confidence
        })
        
        # Limit history size
        if gaze_history.size() > 100:
            gaze_history.pop_front()
        
        # Emit signal if confidence is sufficient
        if tracking_confidence >= MIN_TRACKING_CONFIDENCE:
            emit_signal("gaze_updated", smoothed_gaze_point, tracking_confidence)

func _update_heatmap(position, duration):
    # Convert normalized position to grid cell
    var grid_size = 20 # 20x20 grid for heatmap
    var grid_x = int(position.x * grid_size)
    var grid_y = int(position.y * grid_size)
    var grid_key = str(grid_x) + "_" + str(grid_y)
    
    # Update heatmap data
    if not grid_key in heatmap_data:
        heatmap_data[grid_key] = {
            "duration": 0,
            "visits": 0,
            "position": Vector2(grid_x / float(grid_size), grid_y / float(grid_size))
        }
    
    heatmap_data[grid_key]["duration"] += duration
    heatmap_data[grid_key]["visits"] += 1

func get_heatmap_data():
    # Return processed heatmap data
    var result = []
    
    for grid_key in heatmap_data:
        result.append(heatmap_data[grid_key])
    
    return result

func get_device_info():
    # Return detailed device capabilities
    return {
        "capabilities": device_capabilities,
        "tracking_quality": tracking_quality,
        "is_calibrated": is_calibrated,
        "tracking_confidence": tracking_confidence,
        "has_lidar": device_with_lidar
    }

func get_screen_to_world_point(screen_position):
    # Convert screen position to world coordinates (normalized 0-1)
    return Vector2(
        screen_position.x / screen_dimensions.x,
        screen_position.y / screen_dimensions.y
    )

func world_to_screen_point(world_position):
    # Convert normalized world position to screen coordinates
    return Vector2(
        world_position.x * screen_dimensions.x,
        world_position.y * screen_dimensions.y
    )

func connect_external_device(device_data):
    # Connect to external eye tracking device
    external_device = device_data
    
    # Update capabilities based on external device
    if external_device != null:
        if external_device.has("has_lidar") and external_device["has_lidar"]:
            device_with_lidar = true
            tracking_quality = "high"
        elif external_device.has("has_camera") and external_device["has_camera"]:
            tracking_quality = "medium"
        
        emit_signal("tracking_quality_changed", tracking_quality)
        emit_signal("device_connected", external_device)
    
    print("Connected to external device")
    return external_device