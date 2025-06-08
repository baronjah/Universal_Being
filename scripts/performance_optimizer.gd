# PerformanceOptimizer.gd - Dramatically reduce lag and errors
# Add this as an autoload or to your main scene

extends Node
class_name PerformanceOptimizer

# Performance settings
@export var max_chunks_per_frame: int = 3
@export var max_beings_per_frame: int = 5
@export var error_throttle_ms: int = 1000  # Only log same error once per second
@export var auto_optimize: bool = true

# Error tracking
var error_timestamps: Dictionary = {}  # error_hash -> last_timestamp
var error_counts: Dictionary = {}      # error_hash -> count

# Performance metrics
var fps_history: Array[float] = []
var target_fps: float = 60.0

func _ready():
    # Connect to error logging
    get_tree().set_meta("error_handler", self)
    
    # Start optimization
    if auto_optimize:
        call_deferred("optimize_game_performance")
    
    print("⚡ Performance Optimizer Active - Target: %d FPS" % target_fps)

func optimize_game_performance():
    """Apply immediate performance optimizations"""
    
    # 1. Reduce chunk render distance if needed
    var chunk_systems = get_tree().get_nodes_in_group("chunk_system")
    for system in chunk_systems:
        if system.has_method("set_render_distance"):
            system.render_distance = min(system.render_distance, 50.0)  # Cap at 50
            print("🔧 Optimized %s render distance to %d" % [system.name, system.render_distance])
    
    # 2. Disable verbose logging
    var matrix_systems = get_tree().get_nodes_in_group("matrix_system") 
    for system in matrix_systems:
        if system.has_method("set_verbose"):
            system.set_verbose(false)
    
    # 3. Set up LOD distances
    optimize_lod_settings()
    
    # 4. Enable frustum culling
    RenderingServer.camera_set_cull_mask(RenderingServer.CAMERA_CULL_MASK_DEFAULT, 0xFFFFFFFF)
    
    print("✅ Performance optimizations applied!")

func optimize_lod_settings():
    """Optimize LOD (Level of Detail) settings"""
    # Find all mesh instances and set up LOD
    var meshes = get_tree().get_nodes_in_group("mesh_instance")
    for mesh in meshes:
        if mesh is MeshInstance3D:
            mesh.lod_bias = 1.0  # More aggressive LOD
            
            # Set visibility range for distant objects
            if mesh.has_meta("chunk_coord"):
                mesh.visibility_range_begin = 0.0
                mesh.visibility_range_end = 100.0
                mesh.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_SELF

func should_log_error(error_message: String) -> bool:
    """Check if we should log this error (throttling)"""
    var error_hash = error_message.hash()
    var current_time = Time.get_ticks_msec()
    
    # Check if we've seen this error recently
    if error_hash in error_timestamps:
        var last_time = error_timestamps[error_hash]
        if current_time - last_time < error_throttle_ms:
            # Increment count but don't log
            error_counts[error_hash] = error_counts.get(error_hash, 0) + 1
            return false
    
    # Log the error and update timestamp
    error_timestamps[error_hash] = current_time
    
    # If we've been suppressing, show count
    if error_hash in error_counts and error_counts[error_hash] > 0:
        print("⚠️ Error occurred %d more times: %s" % [error_counts[error_hash], error_message])
        error_counts[error_hash] = 0
    
    return true

func _process(delta):
	pass
    # Track FPS
    var current_fps = Engine.get_frames_per_second()
    fps_history.append(current_fps)
    
    # Keep only last 60 frames
    if fps_history.size() > 60:
        fps_history.pop_front()
    
    # Auto-adjust quality if FPS is low
    if auto_optimize and fps_history.size() >= 60:
        var avg_fps = 0.0
        for fps in fps_history:
            avg_fps += fps
        avg_fps /= fps_history.size()
        
        if avg_fps < 30:
            reduce_quality()
        elif avg_fps > 55:
            increase_quality()

func reduce_quality():
    """Reduce quality settings for better performance"""
    print("📉 Reducing quality for better performance...")
    
    # Reduce chunk systems load
    var chunk_systems = get_tree().get_nodes_in_group("chunk_system")
    for system in chunk_systems:
        if system.has_property("render_distance"):
            system.render_distance *= 0.8  # Reduce by 20%
        if system.has_property("chunk_resolution"):
            system.chunk_resolution = max(2, system.chunk_resolution - 1)
    
    # Reduce particle counts
    var particles = get_tree().get_nodes_in_group("particles")
    for particle_system in particles:
        if particle_system is GPUParticles3D:
            particle_system.amount = int(particle_system.amount * 0.7)

func increase_quality():
    """Increase quality if performance allows"""
    # Only increase if we've been stable for a while
    var all_above_55 = true
    for fps in fps_history:
        if fps < 55:
            all_above_55 = false
            break
    
    if not all_above_55:
        return
    
    print("📈 Increasing quality - performance is good!")
    
    # Carefully increase settings
    var chunk_systems = get_tree().get_nodes_in_group("chunk_system")
    for system in chunk_systems:
        if system.has_property("render_distance"):
            system.render_distance = min(system.render_distance * 1.1, 100.0)

func get_performance_report() -> Dictionary:
    """Get current performance metrics"""
    var avg_fps = 0.0
    if fps_history.size() > 0:
        for fps in fps_history:
            avg_fps += fps
        avg_fps /= fps_history.size()
    
    return {
        "current_fps": Engine.get_frames_per_second(),
        "average_fps": avg_fps,
        "error_types": error_timestamps.size(),
        "total_errors_suppressed": error_counts.values().reduce(func(a, b): return a + b, 0),
        "active_chunks": get_tree().get_nodes_in_group("chunk").size(),
        "active_beings": get_tree().get_nodes_in_group("universal_beings").size()
    }