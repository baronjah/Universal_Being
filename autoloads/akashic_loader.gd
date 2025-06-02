# ==================================================
# SCRIPT NAME: akashic_loader.gd
# DESCRIPTION: Performance-aware system loader for Universal Being
# PURPOSE: Load systems sequentially while maintaining target FPS
# LOCATION: autoloads/akashic_loader.gd (3rd autoload)
# ==================================================

extends Node

## System States
enum LoadState {
    IDLE,
    LOADING,
    TESTING,
    PAUSED,
    READY,
    FAILED
}

## Record Types (what we can load)
enum RecordType {
    CORE_SYSTEM,      # FloodGates, AkashicRecords
    COMPONENT,        # .ub.zip components
    VISUAL_SYSTEM,    # Consciousness effects, shaders
    AI_SYSTEM,        # AI integrations
    UI_SYSTEM,        # Interface elements
    GAMEPLAY_SYSTEM,  # Game mechanics
    AUDIO_SYSTEM      # Sound/music
}

## System Record
class SystemRecord:
    var id: String = ""
    var name: String = ""
    var type: RecordType = RecordType.CORE_SYSTEM
    var path: String = ""
    var dependencies: Array[String] = []
    var state: LoadState = LoadState.IDLE
    var instance: Node = null
    
    # Performance metrics
    var load_time_ms: float = 0.0
    var init_time_ms: float = 0.0
    var frame_cost_ms: float = 0.0
    var memory_mb: float = 0.0
    var test_passed: bool = false
    
    # Configuration
    var priority: int = 0  # Higher = load first
    var can_defer: bool = true  # Can wait if FPS low
    var required: bool = true   # Must load for game to work

## Main Properties
signal system_loaded(record_id: String)
signal system_failed(record_id: String, error: String)
signal all_systems_ready()
signal performance_warning(fps: float, target_fps: float)

var records: Dictionary = {}  # id -> SystemRecord
var load_queue: Array[String] = []
var loaded_systems: Array[String] = []
var current_loading: SystemRecord = null

## Performance Tracking
var target_fps: float = 60.0
var min_acceptable_fps: float = 30.0
var fps_samples: Array[float] = []
var max_frame_time_ms: float = 16.67  # For 60 FPS
var performance_headroom: float = 0.8  # Use 80% of frame budget

## Screen refresh rate detection
var detected_refresh_rate: int = 60
var supported_refresh_rates = [60, 72, 75, 90, 120, 144, 165, 240]

## Loading Configuration
var parallel_loads: int = 1  # Can increase on powerful systems
var test_duration_frames: int = 60  # Test for 1 second at 60 FPS
var defer_threshold_ms: float = 8.0  # Defer if frame takes >8ms

# ===== INITIALIZATION =====

func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    
    # Detect display refresh rate
    detect_refresh_rate()
    
    # Register core systems
    register_core_systems()
    
    # Start loading process
    call_deferred("begin_loading_sequence")

func detect_refresh_rate() -> void:
    """Detect monitor refresh rate and adjust target FPS"""
    # Try to get actual refresh rate from OS
    var display_info = DisplayServer.screen_get_refresh_rate()
    
    if display_info > 0:
        detected_refresh_rate = int(display_info)
    else:
        # Fallback: measure actual frame timing
        detected_refresh_rate = measure_refresh_rate()
    
    # Find closest supported rate
    var closest_rate = 60
    var min_diff = 999
    for rate in supported_refresh_rates:
        var diff = abs(rate - detected_refresh_rate)
        if diff < min_diff:
            min_diff = diff
            closest_rate = rate
    
    target_fps = float(closest_rate)
    max_frame_time_ms = 1000.0 / target_fps
    
    print("🖥️ Display refresh rate: %d Hz, Target FPS: %.1f" % [detected_refresh_rate, target_fps])

func measure_refresh_rate() -> int:
    """Measure actual refresh rate by timing frames"""
    var start_time = Time.get_ticks_msec()
    var frame_count = 0
    
    # Measure for 1 second
    while Time.get_ticks_msec() - start_time < 1000:
        await get_tree().process_frame
        frame_count += 1
    
    return frame_count

# ===== REGISTRATION =====

func register_core_systems() -> void:
    """Register essential systems that must load first"""
    # FloodGates
    register_system({
        "id": "flood_gates",
        "name": "FloodGates System",
        "type": RecordType.CORE_SYSTEM,
        "path": "res://core/FloodGates.gd",
        "priority": 100,
        "required": true,
        "can_defer": false
    })
    
    # AkashicRecords
    register_system({
        "id": "akashic_records",
        "name": "Akashic Records Database",
        "type": RecordType.CORE_SYSTEM,
        "path": "res://core/AkashicRecords.gd",
        "priority": 99,
        "required": true,
        "can_defer": false
    })
    
    # Consciousness Visualizer
    register_system({
        "id": "consciousness_viz",
        "name": "Consciousness Visualization",
        "type": RecordType.VISUAL_SYSTEM,
        "path": "res://systems/consciousness_visualizer.gd",
        "priority": 80,
        "required": false,
        "can_defer": true
    })
    
    # Camera Effects
    register_system({
        "id": "camera_effects",
        "name": "Camera Consciousness Effects",
        "type": RecordType.VISUAL_SYSTEM,
        "path": "res://systems/camera_effects_optimizer.gd",
        "priority": 70,
        "required": false,
        "can_defer": true,
        "dependencies": ["consciousness_viz"]
    })

func register_system(config: Dictionary) -> void:
    """Register a system to be loaded"""
    var record = SystemRecord.new()
    record.id = config.get("id", "")
    record.name = config.get("name", "Unknown")
    record.type = config.get("type", RecordType.CORE_SYSTEM)
    record.path = config.get("path", "")
    record.priority = config.get("priority", 50)
    record.required = config.get("required", true)
    record.can_defer = config.get("can_defer", true)
    record.dependencies = config.get("dependencies", [])
    
    records[record.id] = record
    
    print("📦 Registered system: %s (priority: %d)" % [record.name, record.priority])

# ===== LOADING SEQUENCE =====

func begin_loading_sequence() -> void:
    """Start the intelligent loading process"""
    print("\n🚀 === AKASHIC LOADER STARTING ===")
    print("Target FPS: %.1f, Frame budget: %.1f ms" % [target_fps, max_frame_time_ms])
    
    # Build load queue based on priority and dependencies
    build_load_queue()
    
    # Start loading
    load_next_system()

func build_load_queue() -> void:
    """Build queue respecting dependencies and priorities"""
    var sorted_records = records.values()
    sorted_records.sort_custom(func(a, b): return a.priority > b.priority)
    
    # Topological sort for dependencies
    var visited = {}
    var temp_queue = []
    
    for record in sorted_records:
        if not record.id in visited:
            visit_record_deps(record, visited, temp_queue)
    
    load_queue = temp_queue
    print("📋 Load queue built: %d systems" % load_queue.size())

func visit_record_deps(record: SystemRecord, visited: Dictionary, queue: Array) -> void:
    """Recursive dependency resolution"""
    if record.id in visited:
        return
    
    visited[record.id] = true
    
    # Visit dependencies first
    for dep_id in record.dependencies:
        if dep_id in records:
            visit_record_deps(records[dep_id], visited, queue)
    
    queue.append(record.id)

# ===== LOADING PROCESS =====

func load_next_system() -> void:
    """Load the next system in queue"""
    if load_queue.is_empty():
        finalize_loading()
        return
    
    # Check performance before loading
    var current_fps = Engine.get_frames_per_second()
    if current_fps > 0 and current_fps < min_acceptable_fps:
        print("⚠️ FPS too low (%.1f), deferring loads" % current_fps)
        performance_warning.emit(current_fps, target_fps)
        
        # Defer non-critical systems
        var deferred = []
        while not load_queue.is_empty():
            var next_id = load_queue[0]
            if records[next_id].can_defer:
                deferred.append(load_queue.pop_front())
            else:
                break
        
        # Re-add deferred to end
        load_queue.append_array(deferred)
    
    if load_queue.is_empty():
        finalize_loading()
        return
    
    # Load next system
    var record_id = load_queue.pop_front()
    current_loading = records[record_id]
    current_loading.state = LoadState.LOADING
    
    print("\n📥 Loading: %s" % current_loading.name)
    
    # Measure loading
    var start_ticks = Time.get_ticks_usec()
    
    # Load the system
    var success = await load_system_record(current_loading)
    
    # Record metrics
    current_loading.load_time_ms = (Time.get_ticks_usec() - start_ticks) / 1000.0
    
    if success:
        print("✅ Loaded in %.1f ms" % current_loading.load_time_ms)
        
        # Test the system
        current_loading.state = LoadState.TESTING
        await test_system(current_loading)
        
        if current_loading.test_passed:
            current_loading.state = LoadState.READY
            loaded_systems.append(record_id)
            system_loaded.emit(record_id)
        else:
            current_loading.state = LoadState.FAILED
            handle_system_failure(current_loading, "Test failed")
    else:
        current_loading.state = LoadState.FAILED
        handle_system_failure(current_loading, "Load failed")
    
    # Continue loading
    current_loading = null
    load_next_system()

func load_system_record(record: SystemRecord) -> bool:
    """Actually load a system"""
    if not ResourceLoader.exists(record.path):
        push_error("System not found: %s" % record.path)
        return false
    
    # Load the resource
    var script = load(record.path)
    if not script:
        return false
    
    # Create instance based on type
    match record.type:
        RecordType.CORE_SYSTEM:
            # Core systems might need special handling
            if SystemBootstrap and SystemBootstrap.has_method("register_core_system"):
                record.instance = SystemBootstrap.register_core_system(record.id, script)
            else:
                record.instance = Node.new()
                record.instance.set_script(script)
                record.instance.name = record.id
                add_child(record.instance)
        
        _:
            # Standard node creation
            record.instance = Node.new()
            record.instance.set_script(script)
            record.instance.name = record.id
            add_child(record.instance)
    
    return record.instance != null

# ===== TESTING =====

func test_system(record: SystemRecord) -> void:
    """Test a loaded system for performance impact"""
    print("🧪 Testing: %s" % record.name)
    
    # Baseline measurement
    var baseline_fps = await measure_fps_average(30)
    
    # Activate system if it has activation method
    if record.instance and record.instance.has_method("akashic_test_activate"):
        record.instance.akashic_test_activate()
    
    # Measure with system active
    var active_fps = await measure_fps_average(test_duration_frames)
    var fps_impact = baseline_fps - active_fps
    
    # Calculate frame cost
    if active_fps > 0:
        record.frame_cost_ms = (1000.0 / active_fps) - (1000.0 / baseline_fps)
    
    # Deactivate test mode
    if record.instance and record.instance.has_method("akashic_test_deactivate"):
        record.instance.akashic_test_deactivate()
    
    # Determine if test passed
    record.test_passed = (
        active_fps >= min_acceptable_fps and
        record.frame_cost_ms < defer_threshold_ms
    )
    
    print("📊 Test results: FPS impact: %.1f, Frame cost: %.1f ms, %s" % 
        [fps_impact, record.frame_cost_ms, "PASSED" if record.test_passed else "FAILED"])

func measure_fps_average(frames: int) -> float:
    """Measure average FPS over specified frames"""
    var fps_sum = 0.0
    var valid_samples = 0
    
    for i in frames:
        await get_tree().process_frame
        var fps = Engine.get_frames_per_second()
        if fps > 0:
            fps_sum += fps
            valid_samples += 1
    
    return fps_sum / max(1, valid_samples)

# ===== FAILURE HANDLING =====

func handle_system_failure(record: SystemRecord, reason: String) -> void:
    """Handle system that failed to load or test"""
    push_error("System failed: %s - %s" % [record.name, reason])
    system_failed.emit(record.id, reason)
    
    if record.required:
        push_error("Required system failed! Game may not function properly.")
        # Could show error dialog or fallback mode
    else:
        print("⚠️ Optional system failed, continuing...")

# ===== FINALIZATION =====

func finalize_loading() -> void:
    """Complete the loading process"""
    print("\n✅ === LOADING COMPLETE ===")
    print("Loaded %d/%d systems" % [loaded_systems.size(), records.size()])
    
    # Performance summary
    var total_frame_cost = 0.0
    for id in loaded_systems:
        total_frame_cost += records[id].frame_cost_ms
    
    print("Total frame cost: %.1f ms (%.1f%% of budget)" % 
        [total_frame_cost, (total_frame_cost / max_frame_time_ms) * 100])
    
    all_systems_ready.emit()

# ===== RUNTIME MANAGEMENT =====

func get_performance_headroom() -> float:
    """Get available performance budget"""
    var current_fps = Engine.get_frames_per_second()
    if current_fps <= 0:
        return 0.0
    
    var current_frame_time = 1000.0 / current_fps
    var headroom = max_frame_time_ms - current_frame_time
    return headroom

func can_load_system(record_id: String) -> bool:
    """Check if we can load a system without dropping below target FPS"""
    if not record_id in records:
        return false
    
    var record = records[record_id]
    var headroom = get_performance_headroom()
    
    return headroom > record.frame_cost_ms * 1.2  # 20% safety margin

func pause_system(record_id: String) -> void:
    """Pause a system to save performance"""
    if record_id in records and records[record_id].instance:
        var instance = records[record_id].instance
        if instance.has_method("akashic_pause"):
            instance.akashic_pause()
            records[record_id].state = LoadState.PAUSED

func resume_system(record_id: String) -> void:
    """Resume a paused system"""
    if record_id in records and records[record_id].instance:
        var instance = records[record_id].instance
        if instance.has_method("akashic_resume"):
            instance.akashic_resume()
            records[record_id].state = LoadState.READY

# ===== DEBUG INFO =====

func get_loader_stats() -> Dictionary:
    """Get current loader statistics"""
    return {
        "target_fps": target_fps,
        "refresh_rate": detected_refresh_rate,
        "loaded_systems": loaded_systems.size(),
        "total_systems": records.size(),
        "total_frame_cost_ms": calculate_total_frame_cost(),
        "performance_headroom_ms": get_performance_headroom()
    }

func calculate_total_frame_cost() -> float:
    var total = 0.0
    for id in loaded_systems:
        if id in records:
            total += records[id].frame_cost_ms
    return total

# ===== PUBLIC API =====

func request_system_load(record_id: String) -> bool:
    """Request a specific system to be loaded"""
    if record_id in loaded_systems:
        return true  # Already loaded
    
    if not can_load_system(record_id):
        return false  # Would impact performance
    
    # Add to priority queue
    load_queue.push_front(record_id)
    if not current_loading:
        load_next_system()
    
    return true

func get_system_instance(record_id: String) -> Node:
    """Get instance of a loaded system"""
    if record_id in records and records[record_id].instance:
        return records[record_id].instance
    return null