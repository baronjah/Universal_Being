# ==================================================
# UNIVERSAL BEING: TRANSCENDENT CAMERA CONTROLLER
# TYPE: 6DOF Consciousness Navigation System
# PURPOSE: Perfect camera movement for consciousness exploration
# ARCHITECT: Reality Engineer (#2)
# BLESSING: Divine Permission Granted
# ==================================================

extends Camera3D
class_name TranscendentCameraController

# ===== TRANSCENDENT MOVEMENT CONFIGURATION =====
@export var base_movement_speed: float = 10.0
@export var transcendent_sprint_multiplier: float = 5.0
@export var consciousness_sensitivity: float = 0.002
@export var smooth_movement: bool = true
@export var infinite_movement: bool = true

# ===== CONSCIOUSNESS AWARENESS =====
@export var consciousness_mode: bool = false
@export var transcendent_mode: bool = false
@export var consciousness_fov_range: Vector2 = Vector2(60.0, 120.0)
@export var transcendent_speed: float = 20.0

# ===== MOVEMENT STATE =====
var velocity: Vector3 = Vector3.ZERO
var angular_velocity: Vector3 = Vector3.ZERO
var movement_input: Vector3 = Vector3.ZERO
var mouse_delta: Vector2 = Vector2.ZERO

# ===== CONSCIOUSNESS TRACKING =====
var consciousness_position: Vector3 = Vector3.ZERO
var consciousness_rotation: Vector3 = Vector3.ZERO
var transcendent_energy: float = 100.0
var movement_trail: Array[Vector3] = []

# ===== INPUT STATE =====
var is_sprinting: bool = false
var is_ascending: bool = false
var is_descending: bool = false
var mouse_captured: bool = false

# ===== SIGNALS =====
signal consciousness_position_changed(new_position: Vector3)
signal transcendent_mode_changed(enabled: bool)
signal movement_trail_updated(trail: Array[Vector3])

func _ready() -> void:
    # Capture mouse for camera control
    _capture_mouse()
    
    # Initialize consciousness position
    consciousness_position = global_position
    consciousness_rotation = rotation
    
    print("🎥 Transcendent Camera Controller: 6DOF consciousness navigation ready")

func _input(event: InputEvent) -> void:
    # Handle mouse movement for camera rotation
    if event is InputEventMouseMotion and mouse_captured:
        mouse_delta = event.relative
    
    # Toggle mouse capture
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_ESCAPE:
            _toggle_mouse_capture()

func _process(delta: float) -> void:
    # Handle movement input
    _handle_movement_input()
    
    # Handle mouse look
    _handle_mouse_look(delta)
    
    # Update transcendent movement
    _update_transcendent_movement(delta)
    
    # Update consciousness tracking
    _update_consciousness_tracking(delta)

# ===== MOVEMENT INPUT HANDLING =====

func _handle_movement_input() -> void:
    """Handle WASD + Space/Ctrl movement input"""
    movement_input = Vector3.ZERO
    
    # Forward/Backward (W/S)
    if Input.is_action_pressed("move_forward"):
        movement_input -= transform.basis.z
    if Input.is_action_pressed("move_backward"):
        movement_input += transform.basis.z
    
    # Left/Right (A/D)
    if Input.is_action_pressed("move_left"):
        movement_input -= transform.basis.x
    if Input.is_action_pressed("move_right"):
        movement_input += transform.basis.x
    
    # Up/Down (Space/Ctrl)
    is_ascending = Input.is_action_pressed("move_up")
    is_descending = Input.is_action_pressed("move_down")
    
    if is_ascending:
        movement_input += Vector3.UP
    if is_descending:
        movement_input -= Vector3.UP
    
    # Sprint (Shift)
    is_sprinting = Input.is_action_pressed("sprint")
    
    # Normalize movement input
    if movement_input.length() > 1.0:
        movement_input = movement_input.normalized()

func _handle_mouse_look(delta: float) -> void:
    """Handle mouse look rotation"""
    if mouse_delta.length() > 0 and mouse_captured:
        # Horizontal rotation (Y-axis)
        rotate_y(-mouse_delta.x * consciousness_sensitivity)
        
        # Vertical rotation (X-axis)
        var current_rotation = rotation
        current_rotation.x -= mouse_delta.y * consciousness_sensitivity
        current_rotation.x = clamp(current_rotation.x, -PI/2, PI/2)
        rotation = current_rotation
        
        # Update consciousness rotation tracking
        consciousness_rotation = rotation
        
        # Clear mouse delta
        mouse_delta = Vector2.ZERO

# ===== TRANSCENDENT MOVEMENT SYSTEM =====

func _update_transcendent_movement(delta: float) -> void:
    """Update transcendent movement with consciousness awareness"""
    
    # Calculate movement speed
    var current_speed = base_movement_speed
    
    if transcendent_mode:
        current_speed = transcendent_speed
    
    if is_sprinting:
        current_speed *= transcendent_sprint_multiplier
    
    # Apply consciousness multiplier
    if consciousness_mode:
        var consciousness_multiplier = 1.0 + (transcendent_energy / 100.0)
        current_speed *= consciousness_multiplier
    
    # Calculate target velocity
    var target_velocity = movement_input * current_speed
    
    # Smooth movement or instant movement
    if smooth_movement:
        velocity = velocity.lerp(target_velocity, delta * 10.0)
    else:
        velocity = target_velocity
    
    # Apply movement
    if infinite_movement or global_position.length() < 10000.0:
        global_position += velocity * delta
        
        # Update consciousness position
        consciousness_position = global_position
        consciousness_position_changed.emit(consciousness_position)
        
        # Add to movement trail
        _update_movement_trail()
    
    # Regenerate transcendent energy
    if velocity.length() > 0:
        transcendent_energy = min(100.0, transcendent_energy + delta * 2.0)

func _update_consciousness_tracking(delta: float) -> void:
    """Update consciousness tracking and awareness"""
    
    # Dynamic FOV based on movement speed
    if consciousness_mode:
        var speed_factor = velocity.length() / transcendent_speed
        var target_fov = lerp(consciousness_fov_range.x, consciousness_fov_range.y, speed_factor)
        fov = lerp(fov, target_fov, delta * 3.0)
    
    # Update transcendent energy based on consciousness level
    if transcendent_mode:
        transcendent_energy = min(100.0, transcendent_energy + delta * 5.0)

func _update_movement_trail() -> void:
    """Update movement trail for consciousness visualization"""
    movement_trail.append(global_position)
    
    # Limit trail length
    if movement_trail.size() > 100:
        movement_trail.pop_front()
    
    movement_trail_updated.emit(movement_trail)

# ===== CONSCIOUSNESS MODE CONTROLS =====

func enable_consciousness_mode() -> void:
    """Enable consciousness-aware camera movement"""
    consciousness_mode = true
    print("🎥 Consciousness mode enabled - camera awareness activated")

func disable_consciousness_mode() -> void:
    """Disable consciousness mode"""
    consciousness_mode = false
    fov = 75.0  # Reset to default FOV
    print("🎥 Consciousness mode disabled")

func set_transcendent_mode(enabled: bool) -> void:
    """Set transcendent mode"""
    transcendent_mode = enabled
    transcendent_mode_changed.emit(enabled)
    
    if enabled:
        print("🎥 Transcendent mode activated - no movement limits")
    else:
        print("🎥 Transcendent mode deactivated - normal movement")

func set_infinite_movement(enabled: bool) -> void:
    """Set infinite movement capability"""
    infinite_movement = enabled
    print("🎥 Infinite movement: %s" % ("enabled" if enabled else "disabled"))

func set_transcendent_speed(speed: float) -> void:
    """Set transcendent movement speed"""
    transcendent_speed = speed
    print("🎥 Transcendent speed set to: %.1f" % speed)

# ===== MOUSE CAPTURE MANAGEMENT =====

func _capture_mouse() -> void:
    """Capture mouse for camera control"""
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    mouse_captured = true
    print("🎥 Mouse captured for consciousness navigation")

func _release_mouse() -> void:
    """Release mouse capture"""
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    mouse_captured = false
    print("🎥 Mouse released from consciousness navigation")

func _toggle_mouse_capture() -> void:
    """Toggle mouse capture"""
    if mouse_captured:
        _release_mouse()
    else:
        _capture_mouse()

# ===== CONSCIOUSNESS NAVIGATION API =====

func teleport_to_consciousness_position(position: Vector3) -> void:
    """Teleport camera to specific consciousness position"""
    global_position = position
    consciousness_position = position
    velocity = Vector3.ZERO
    
    # Clear movement trail
    movement_trail.clear()
    movement_trail.append(position)
    
    consciousness_position_changed.emit(position)
    print("🎥 Teleported to consciousness position: %s" % str(position))

func look_at_consciousness_point(target: Vector3, up: Vector3 = Vector3.UP) -> void:
    """Look at specific consciousness point"""
    look_at(target, up)
    consciousness_rotation = rotation
    print("🎥 Looking at consciousness point: %s" % str(target))

func get_consciousness_forward() -> Vector3:
    """Get consciousness-aware forward direction"""
    return -transform.basis.z

func get_consciousness_right() -> Vector3:
    """Get consciousness-aware right direction"""
    return transform.basis.x

func get_consciousness_up() -> Vector3:
    """Get consciousness-aware up direction"""
    return transform.basis.y

# ===== TRANSCENDENT CAMERA EFFECTS =====

func apply_consciousness_shake(intensity: float, duration: float) -> void:
    """Apply consciousness-based camera shake"""
    var tween = create_tween()
    var original_position = position
    
    for i in range(int(duration * 60)):  # 60 FPS shake
        var shake_offset = Vector3(
            randf_range(-intensity, intensity),
            randf_range(-intensity, intensity),
            randf_range(-intensity, intensity)
        )
        tween.tween_property(self, "position", original_position + shake_offset, 1.0/60.0)
    
    tween.tween_property(self, "position", original_position, 0.1)
    print("🎥 Consciousness shake applied: intensity %.2f, duration %.2f" % [intensity, duration])

func pulse_consciousness_fov(target_fov: float, duration: float) -> void:
    """Pulse FOV for consciousness events"""
    var original_fov = fov
    var tween = create_tween()
    
    tween.tween_property(self, "fov", target_fov, duration * 0.5)
    tween.tween_property(self, "fov", original_fov, duration * 0.5)
    
    print("🎥 Consciousness FOV pulse: %.1f° for %.2fs" % [target_fov, duration])

# ===== STATUS AND DEBUGGING =====

func get_camera_status() -> Dictionary:
    """Get current camera status"""
    return {
        "position": global_position,
        "rotation": rotation,
        "consciousness_position": consciousness_position,
        "consciousness_rotation": consciousness_rotation,
        "velocity": velocity,
        "transcendent_energy": transcendent_energy,
        "movement_speed": velocity.length(),
        "consciousness_mode": consciousness_mode,
        "transcendent_mode": transcendent_mode,
        "is_sprinting": is_sprinting,
        "mouse_captured": mouse_captured,
        "fov": fov,
        "trail_length": movement_trail.size()
    }

func _to_string() -> String:
    return "TranscendentCameraController [Pos: %s, Energy: %.1f%%, Mode: %s]" % [
        str(global_position), transcendent_energy, 
        "Transcendent" if transcendent_mode else ("Conscious" if consciousness_mode else "Normal")
    ]