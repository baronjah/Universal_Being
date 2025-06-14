extends Node

class_name WordSmoothingSystem

# ----- SMOOTHING SETTINGS -----
@export_category("Smoothing Settings")
@export var smoothing_enabled: bool = true
@export var path_smoothing_strength: float = 0.5
@export var position_smoothing_weight: float = 0.2
@export var rotation_smoothing_weight: float = 0.1
@export var scale_smoothing_weight: float = 0.3
@export var use_bezier_curves: bool = true

# ----- VISUAL SETTINGS -----
@export_category("Visual Settings")
@export var draw_debug_paths: bool = false
@export var debug_path_segments: int = 20
@export var debug_path_width: float = 2.0
@export var debug_path_color: Color = Color(1.0, 0.5, 0.0, 0.5)

# ----- INTEGRATION SETTINGS -----
@export_category("Integration Settings")
@export var auto_update_on_physics: bool = true
@export var update_frequency: float = 60.0  # Updates per second when not using physics
@export var max_words_per_update: int = 10  # To avoid performance issues

# ----- STATE TRACKING -----
var word_entities: Dictionary = {}  # word_id -> {node, target, data}
var word_paths: Dictionary = {}     # word_id -> {points, current_t, speed}
var word_smoothing_data: Dictionary = {}  # word_id -> {original_transform, target_transform, weight}

# ----- SIGNALS -----
signal word_path_completed(word_id)
signal smoothing_started(word_id)
signal smoothing_updated(word_id, progress)

# ----- INITIALIZATION -----
func _ready():
    if auto_update_on_physics:
        set_physics_process(true)
    else:
        var timer = Timer.new()
        timer.name = "UpdateTimer"
        timer.wait_time = 1.0 / update_frequency
        timer.autostart = true
        timer.timeout.connect(_on_update_timer_timeout)
        add_child(timer)

# ----- UPDATE FUNCTIONS -----
func _physics_process(delta):
    if auto_update_on_physics and smoothing_enabled:
        update_all_word_smoothing(delta)

func _on_update_timer_timeout():
    if smoothing_enabled and not auto_update_on_physics:
        update_all_word_smoothing(1.0 / update_frequency)

func update_all_word_smoothing(delta):
    # Get list of word IDs to process this frame
    var words_to_process = word_entities.keys()
    
    # Limit number of words processed per frame if needed
    if words_to_process.size() > max_words_per_update:
        words_to_process = words_to_process.slice(0, max_words_per_update)
    
    # Process each word
    for word_id in words_to_process:
        update_word_smoothing(word_id, delta)

# ----- WORD PATH MANAGEMENT -----
func create_word_path(word_id: String, start_pos: Vector3, end_pos: Vector3, control_points: Array = []):
    if not word_entities.has(word_id):
        return
    
    var path = {
        "type": "bezier" if use_bezier_curves else "linear",
        "start": start_pos,
        "end": end_pos,
        "control_points": control_points,
        "current_t": 0.0,
        "speed": randf_range(0.5, 1.5),  # Random speed for variety
        "length": (end_pos - start_pos).length()
    }
    
    # Generate points for linear path or use bezier for curved path
    if path.type == "linear":
        path.points = [start_pos, end_pos]
    else:
        # Generate bezier curve points
        path.points = generate_bezier_points(start_pos, end_pos, control_points, debug_path_segments)
    
    word_paths[word_id] = path
    
    # Signal that smoothing has started
    emit_signal("smoothing_started", word_id)

func update_word_path(word_id: String, delta: float):
    if not word_paths.has(word_id) or not word_entities.has(word_id):
        return
    
    var path = word_paths[word_id]
    var entity = word_entities[word_id]
    
    # Update progress along path
    path.current_t += delta * path.speed / path.length
    
    # Clamp and check for completion
    if path.current_t >= 1.0:
        path.current_t = 1.0
        
        # Set final position
        if entity.node and is_instance_valid(entity.node):
            entity.node.global_position = path.end
        
        # Signal path completion and remove path
        emit_signal("word_path_completed", word_id)
        word_paths.erase(word_id)
        return
    
    # Calculate current position on path
    var current_pos
    
    if path.type == "linear":
        current_pos = path.start.lerp(path.end, path.current_t)
    else:
        # Find position on bezier curve
        var t = path.current_t
        current_pos = evaluate_bezier_at(path.points, t)
    
    # Update entity position
    if entity.node and is_instance_valid(entity.node):
        entity.node.global_position = current_pos
    
    # Signal progress update
    emit_signal("smoothing_updated", word_id, path.current_t)

# ----- TRANSFORM SMOOTHING -----
func start_transform_smoothing(word_id: String, target_transform: Transform3D, weight: float = 1.0, duration: float = 1.0):
    if not word_entities.has(word_id):
        return
    
    var entity = word_entities[word_id]
    
    if not entity.node or not is_instance_valid(entity.node):
        return
    
    # Store smoothing data
    word_smoothing_data[word_id] = {
        "original_transform": entity.node.global_transform,
        "target_transform": target_transform,
        "weight": weight,
        "duration": duration,
        "elapsed": 0.0
    }
    
    # Signal smoothing started
    emit_signal("smoothing_started", word_id)

func update_transform_smoothing(word_id: String, delta: float):
    if not word_smoothing_data.has(word_id) or not word_entities.has(word_id):
        return
    
    var smooth_data = word_smoothing_data[word_id]
    var entity = word_entities[word_id]
    
    if not entity.node or not is_instance_valid(entity.node):
        word_smoothing_data.erase(word_id)
        return
    
    # Update elapsed time
    smooth_data.elapsed += delta
    
    # Calculate interpolation factor
    var t = smooth_data.elapsed / smooth_data.duration
    
    # Apply easing function for smoother transitions
    t = ease(t, 2.0)  # Ease-out quadratic
    
    if t >= 1.0:
        # Smoothing completed
        entity.node.global_transform = smooth_data.target_transform
        word_smoothing_data.erase(word_id)
        emit_signal("word_path_completed", word_id)
        return
    
    # Interpolate transform components with weighted influence
    var current_transform = entity.node.global_transform
    var target_transform = smooth_data.target_transform
    var weight = smooth_data.weight
    
    # Position smoothing
    var smoothed_position = current_transform.origin.lerp(
        target_transform.origin,
        position_smoothing_weight * weight * t
    )
    
    # Rotation smoothing (using Quaternion for smoother rotation)
    var current_quat = Quaternion(current_transform.basis)
    var target_quat = Quaternion(target_transform.basis)
    var smoothed_quat = current_quat.slerp(target_quat, rotation_smoothing_weight * weight * t)
    
    # Scale smoothing
    var current_scale = current_transform.basis.get_scale()
    var target_scale = target_transform.basis.get_scale()
    var smoothed_scale = current_scale.lerp(target_scale, scale_smoothing_weight * weight * t)
    
    # Construct new transform
    var new_transform = Transform3D(Basis(smoothed_quat), smoothed_position)
    new_transform.basis = new_transform.basis.scaled(smoothed_scale)
    
    # Apply smoothed transform
    entity.node.global_transform = new_transform
    
    # Signal progress update
    emit_signal("smoothing_updated", word_id, t)

# ----- GENERAL SMOOTHING UPDATE -----
func update_word_smoothing(word_id: String, delta: float):
    # Check if word has an active path
    if word_paths.has(word_id):
        update_word_path(word_id, delta)
    
    # Check if word has active transform smoothing
    if word_smoothing_data.has(word_id):
        update_transform_smoothing(word_id, delta)

# ----- REGISTRATION FUNCTIONS -----
func register_word_entity(word_id: String, node: Node3D, target: Node3D = null, data: Dictionary = {}):
    word_entities[word_id] = {
        "node": node,
        "target": target,
        "data": data
    }

func unregister_word_entity(word_id: String):
    word_entities.erase(word_id)
    word_paths.erase(word_id)
    word_smoothing_data.erase(word_id)

# ----- BEZIER CURVE UTILITIES -----
func generate_bezier_points(start: Vector3, end: Vector3, control_points: Array, segment_count: int) -> Array:
    var points = []
    
    # For cubic bezier, we need exactly two control points
    var p0 = start
    var p3 = end
    
    var p1: Vector3
    var p2: Vector3
    
    if control_points.size() >= 2:
        p1 = control_points[0]
        p2 = control_points[1]
    elif control_points.size() == 1:
        p1 = control_points[0]
        p2 = (end - start) * 0.75 + start
    else:
        # Generate sensible control points if none provided
        var mid = (end - start) * 0.5 + start
        var perp = Vector3(-start.z + end.z, 0, start.x - end.x).normalized() * (start - end).length() * 0.25
        p1 = mid + perp
        p2 = mid - perp
    
    # Sample points along the bezier curve
    for i in range(segment_count + 1):
        var t = float(i) / segment_count
        points.append(bezier_point(p0, p1, p2, p3, t))
    
    return points

func bezier_point(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, t: float) -> Vector3:
    var q0 = p0.lerp(p1, t)
    var q1 = p1.lerp(p2, t)
    var q2 = p2.lerp(p3, t)
    
    var r0 = q0.lerp(q1, t)
    var r1 = q1.lerp(q2, t)
    
    return r0.lerp(r1, t)

func evaluate_bezier_at(points: Array, t: float) -> Vector3:
    # If t is exactly at a sample point, return it directly
    var point_count = points.size()
    var segment = t * (point_count - 1)
    var i = int(segment)
    
    # Handle edge cases
    if i >= point_count - 1:
        return points[point_count - 1]
    
    // Interpolate between sample points
    var fraction = segment - i
    return points[i].lerp(points[i + 1], fraction)

# ----- DEBUGGING FUNCTIONS -----
func _draw_debug_paths():
    if not draw_debug_paths:
        return
    
    for word_id in word_paths:
        var path = word_paths[word_id]
        var points = path.points
        
        if points.size() < 2:
            continue
        
        # Draw path lines
        for i in range(points.size() - 1):
            DebugDraw3D.draw_line(points[i], points[i+1], debug_path_color, debug_path_width)
        
        # Draw current position marker
        var current_position
        if path.type == "linear":
            current_position = path.start.lerp(path.end, path.current_t)
        else:
            current_position = evaluate_bezier_at(points, path.current_t)
        
        DebugDraw3D.draw_sphere(current_position, 0.1, Color(1, 0, 0, 0.8))

# Called when visibility changes
func _notification(what):
    if what == NOTIFICATION_VISIBILITY_CHANGED and visible:
        if draw_debug_paths:
            _draw_debug_paths()

# ----- PUBLIC API -----
func create_smooth_path_to_target(word_id: String, target_position: Vector3, duration: float = 1.0, add_curve: bool = true):
    if not word_entities.has(word_id):
        return
    
    var entity = word_entities[word_id]
    
    if not entity.node or not is_instance_valid(entity.node):
        return
    
    var start_pos = entity.node.global_position
    var end_pos = target_position
    
    # Create control points for curved path if requested
    var control_points = []
    
    if add_curve and use_bezier_curves:
        var mid = (end_pos - start_pos) * 0.5 + start_pos
        var up_offset = Vector3(0, (end_pos - start_pos).length() * 0.2, 0)
        
        # Create a curve that arcs upward
        control_points = [
            start_pos + (mid - start_pos) * 0.5 + up_offset,
            end_pos - (end_pos - mid) * 0.5 + up_offset
        ]
    
    # Calculate path length for speed adjustment
    var path_length = (end_pos - start_pos).length()
    
    # Create the path
    create_word_path(word_id, start_pos, end_pos, control_points)
    
    # Adjust speed based on desired duration
    if word_paths.has(word_id):
        word_paths[word_id].speed = path_length / duration

func smooth_to_transform(word_id: String, target_transform: Transform3D, duration: float = 1.0):
    start_transform_smoothing(word_id, target_transform, 1.0, duration)

func apply_dna_smoothing(word_id: String, dna: String, duration: float = 0.5):
    if not word_entities.has(word_id):
        return
    
    var entity = word_entities[word_id]
    
    if not entity.node or not is_instance_valid(entity.node):
        return
    
    # Get transformation data from DNA
    var transform_data = WordDNASystem.get_shape_transform_from_dna(dna)
    
    # Create target transform based on current transform and DNA
    var current_transform = entity.node.global_transform
    
    # Apply DNA scale and rotation
    var new_basis = Basis()
    new_basis = new_basis.rotated(Vector3(1, 0, 0), deg_to_rad(transform_data.rotation.x))
    new_basis = new_basis.rotated(Vector3(0, 1, 0), deg_to_rad(transform_data.rotation.y))
    new_basis = new_basis.rotated(Vector3(0, 0, 1), deg_to_rad(transform_data.rotation.z))
    new_basis = new_basis.scaled(transform_data.scale)
    
    var target_transform = Transform3D(new_basis, current_transform.origin)
    
    # Start smoothing to the new transform
    start_transform_smoothing(word_id, target_transform, 1.0, duration)