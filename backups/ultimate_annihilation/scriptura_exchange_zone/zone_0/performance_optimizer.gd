extends Node

class_name PerformanceOptimizer

# ----- PERFORMANCE SETTINGS -----
@export_category("Performance Configuration")
@export var enabled: bool = true
@export var max_performance_mode: bool = false
@export var freemium_optimization: bool = true
@export var hourly_magic_cycles: bool = true
@export var turn_duration_minutes: int = 5  # 5 minutes per turn = 1 hour for 12 turns
@export var memory_limit_mb: int = 512  # Memory limit in MB
@export var max_threads: int = 4  # Max thread count for parallel processing
@export var ethereal_engine_priority: int = 10  # Higher priority for Ethereal Engine

# ----- RESOURCE MANAGEMENT -----
var resource_allocation: Dictionary = {
    "cpu": 0.0,         # 0.0-1.0 scale
    "memory": 0.0,      # 0.0-1.0 scale
    "gpu": 0.0,         # 0.0-1.0 scale
    "storage": 0.0,     # 0.0-1.0 scale
    "network": 0.0      # 0.0-1.0 scale
}

var resource_limits: Dictionary = {
    "cpu": 0.8,         # Max CPU usage (0.0-1.0)
    "memory": 0.7,      # Max Memory usage (0.0-1.0)
    "gpu": 0.6,         # Max GPU usage (0.0-1.0)
    "storage": 0.9,     # Max Storage usage (0.0-1.0)
    "network": 0.5      # Max Network usage (0.0-1.0)
}

var freemium_day_usage: Dictionary = {
    "cpu_minutes": 0.0,
    "api_calls": 0,
    "memory_mb_minutes": 0.0,
    "data_transfers_mb": 0.0,
    "resource_score": 0.0
}

# ----- SYSTEM REFERENCES -----
var ethereal_bridge: Node = null
var turn_system: Node = null
var memory_system: Node = null
var time_tracker: Node = null

# ----- OPTIMIZATION STATE -----
var current_performance_level: int = 2  # 1-3 (Low, Medium, High)
var optimization_active: bool = false
var last_optimization_time: int = 0
var active_threads: Array = []
var thread_pool: Array = []
var performance_stats: Dictionary = {}
var scheduled_optimizations: Array = []

# ----- MAGIC CYCLE TRACKING -----
var current_magic_cycle: int = 0  # 0-11 corresponding to the 12 turns
var magic_cycle_start_time: int = 0
var magic_cycle_resources: Dictionary = {}
var magic_cycle_performance: Array = []

# ----- TIMERS -----
var resource_monitor_timer: Timer
var optimization_timer: Timer
var freemium_usage_timer: Timer
var magic_cycle_timer: Timer

# ----- SIGNALS -----
signal performance_optimized(level, stats)
signal resource_limits_reached(resource_type, current_value)
signal magic_cycle_completed(cycle_number, performance)
signal freemium_usage_updated(usage_stats)
signal thread_pool_status_changed(active_count, total_count)

# ----- INITIALIZATION -----
func _ready():
    # Set up timers
    _setup_timers()
    
    # Find system references
    _find_system_references()
    
    # Initialize resources
    _initialize_resources()
    
    # Initialize thread pool
    _initialize_thread_pool()
    
    # Set initial magic cycle
    _initialize_magic_cycle()
    
    print("Performance Optimizer initialized - Magic cycle duration: " + str(turn_duration_minutes * 12) + " minutes")

func _setup_timers():
    # Resource monitor timer - check resource usage every 5 seconds
    resource_monitor_timer = Timer.new()
    resource_monitor_timer.wait_time = 5.0
    resource_monitor_timer.one_shot = false
    resource_monitor_timer.autostart = true
    resource_monitor_timer.connect("timeout", _on_resource_monitor_timeout)
    add_child(resource_monitor_timer)
    
    # Optimization timer - run optimizations every 30 seconds
    optimization_timer = Timer.new()
    optimization_timer.wait_time = 30.0
    optimization_timer.one_shot = false
    optimization_timer.autostart = true
    optimization_timer.connect("timeout", _on_optimization_timeout)
    add_child(optimization_timer)
    
    # Freemium usage timer - update usage stats every minute
    freemium_usage_timer = Timer.new()
    freemium_usage_timer.wait_time = 60.0
    freemium_usage_timer.one_shot = false
    freemium_usage_timer.autostart = true
    freemium_usage_timer.connect("timeout", _on_freemium_usage_timeout)
    add_child(freemium_usage_timer)
    
    # Magic cycle timer - update magic cycle every minute
    magic_cycle_timer = Timer.new()
    magic_cycle_timer.wait_time = 60.0
    magic_cycle_timer.one_shot = false
    magic_cycle_timer.autostart = true
    magic_cycle_timer.connect("timeout", _on_magic_cycle_timeout)
    add_child(magic_cycle_timer)

func _find_system_references():
    # Find Ethereal Bridge
    ethereal_bridge = _find_node_by_class(get_tree().root, "EtherealAkashicBridge")
    
    # Find Turn System
    turn_system = _find_node_by_class(get_tree().root, "TurnSystem")
    if not turn_system:
        turn_system = _find_node_by_class(get_tree().root, "TurnCycleController")
    
    # Find Memory System
    memory_system = _find_node_by_class(get_tree().root, "IntegratedMemorySystem")
    
    # Find Time Tracker
    time_tracker = _find_node_by_class(get_tree().root, "UsageTimeTracker")

func _find_node_by_class(node, class_name):
    if node.get_class() == class_name or (node.get_script() and node.get_script().get_path().find(class_name.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name)
        if found:
            return found
    
    return null

func _initialize_resources():
    # Initialize resource usage metrics
    resource_allocation.cpu = 0.2  # Start at 20% CPU
    resource_allocation.memory = 0.1  # Start at 10% Memory
    resource_allocation.gpu = 0.05  # Start at 5% GPU
    resource_allocation.storage = 0.1  # Start at 10% Storage
    resource_allocation.network = 0.05  # Start at 5% Network
    
    # Initialize freemium usage tracking
    freemium_day_usage.cpu_minutes = 0.0
    freemium_day_usage.api_calls = 0
    freemium_day_usage.memory_mb_minutes = 0.0
    freemium_day_usage.data_transfers_mb = 0.0
    freemium_day_usage.resource_score = 0.0
    
    # Configure resource limits based on freemium mode
    if freemium_optimization:
        _configure_freemium_limits()
    
    # Configure for max performance if enabled
    if max_performance_mode:
        _configure_max_performance()

func _initialize_thread_pool():
    thread_pool.clear()
    
    # Create thread objects for the pool
    for i in range(max_threads):
        thread_pool.append({
            "id": i,
            "active": false,
            "task": "",
            "priority": 0,
            "start_time": 0
        })

func _initialize_magic_cycle():
    # Get current turn as magic cycle if available
    if turn_system and turn_system.has_method("get_current_turn"):
        current_magic_cycle = (turn_system.get_current_turn() - 1) % 12
    
    # Initialize magic cycle start time
    magic_cycle_start_time = Time.get_unix_time_from_system()
    
    # Initialize resources for each cycle stage
    for i in range(12):
        magic_cycle_resources[i] = _get_resources_for_cycle(i)
    
    # Initialize performance stats array
    magic_cycle_performance.resize(12)
    for i in range(12):
        magic_cycle_performance[i] = 0.0

# ----- RESOURCE MANAGEMENT -----
func _configure_freemium_limits():
    # Set conservative resource limits for freemium mode
    resource_limits.cpu = 0.6  # 60% max CPU
    resource_limits.memory = 0.5  # 50% max Memory
    resource_limits.gpu = 0.4  # 40% max GPU
    resource_limits.storage = 0.7  # 70% max Storage
    resource_limits.network = 0.3  # 30% max Network
    
    # Lower thread count
    max_threads = min(max_threads, 2)
    _initialize_thread_pool()
    
    print("Configured for freemium optimization mode")

func _configure_max_performance():
    # Set aggressive resource limits for max performance mode
    resource_limits.cpu = 0.9  # 90% max CPU
    resource_limits.memory = 0.8  # 80% max Memory
    resource_limits.gpu = 0.7  # 70% max GPU
    resource_limits.storage = 0.95  # 95% max Storage
    resource_limits.network = 0.6  # 60% max Network
    
    # Increase thread count
    max_threads = OS.get_processor_count() - 1  # Leave one core for the OS
    max_threads = min(max_threads, 8)  # Cap at 8 threads
    _initialize_thread_pool()
    
    print("Configured for maximum performance mode")

func _calculate_current_resource_usage():
    # In a real implementation, this would measure actual system resources
    # Here we simulate resource usage
    
    # Update CPU usage - fluctuate based on active threads and tasks
    var active_thread_count = 0
    for thread in thread_pool:
        if thread.active:
            active_thread_count += 1
    
    var cpu_factor = float(active_thread_count) / max(1.0, float(max_threads))
    resource_allocation.cpu = min(0.2 + cpu_factor * 0.6, resource_limits.cpu)
    
    # Update memory usage - gradually increase until garbage collection
    resource_allocation.memory += randf_range(0.001, 0.005)
    if resource_allocation.memory > resource_limits.memory * 0.9:
        # Simulate garbage collection
        resource_allocation.memory *= 0.7
    
    # Update GPU usage based on rendering needs
    if optimization_active:
        resource_allocation.gpu = min(resource_allocation.gpu + 0.05, resource_limits.gpu)
    else:
        resource_allocation.gpu = max(resource_allocation.gpu - 0.03, 0.05)
    
    # Update storage based on data operations
    if freemium_day_usage.data_transfers_mb > 100:
        resource_allocation.storage = min(resource_allocation.storage + 0.01, resource_limits.storage)
    
    # Update network based on API calls
    if freemium_day_usage.api_calls > 0:
        var network_factor = min(freemium_day_usage.api_calls / 100.0, 1.0)
        resource_allocation.network = min(0.05 + network_factor * 0.3, resource_limits.network)
    
    # Check if any resource is nearing its limit
    for resource in resource_allocation:
        if resource_allocation[resource] > resource_limits[resource] * 0.9:
            emit_signal("resource_limits_reached", resource, resource_allocation[resource])
            
            # Automatically optimize if close to limits
            _optimize_resource_usage(resource)

func _get_resources_for_cycle(cycle_number):
    # Define resource distribution for each of the 12 magical cycles
    var cycle_resources = {}
    
    match cycle_number:
        0:  # Genesis - Initialization phase
            cycle_resources = {
                "cpu": 0.3,
                "memory": 0.2,
                "gpu": 0.1,
                "storage": 0.3,
                "network": 0.1
            }
        1:  # Formation - Structure creation
            cycle_resources = {
                "cpu": 0.4,
                "memory": 0.3,
                "gpu": 0.2,
                "storage": 0.4,
                "network": 0.1
            }
        2:  # Complexity - Systems interact
            cycle_resources = {
                "cpu": 0.5,
                "memory": 0.4,
                "gpu": 0.2,
                "storage": 0.3,
                "network": 0.2
            }
        3:  # Consciousness - Awareness develops
            cycle_resources = {
                "cpu": 0.6,
                "memory": 0.5,
                "gpu": 0.3,
                "storage": 0.2,
                "network": 0.3
            }
        4:  # Awakening - Full activation
            cycle_resources = {
                "cpu": 0.7,
                "memory": 0.6,
                "gpu": 0.4,
                "storage": 0.2,
                "network": 0.4
            }
        5:  # Enlightenment - Knowledge processing
            cycle_resources = {
                "cpu": 0.8,
                "memory": 0.7,
                "gpu": 0.3,
                "storage": 0.4,
                "network": 0.5
            }
        6:  # Manifestation - Creation peak
            cycle_resources = {
                "cpu": 0.9,
                "memory": 0.8,
                "gpu": 0.7,
                "storage": 0.5,
                "network": 0.4
            }
        7:  # Connection - Network focus
            cycle_resources = {
                "cpu": 0.7,
                "memory": 0.6,
                "gpu": 0.5,
                "storage": 0.6,
                "network": 0.8
            }
        8:  # Harmony - Balanced resources
            cycle_resources = {
                "cpu": 0.6,
                "memory": 0.6,
                "gpu": 0.6,
                "storage": 0.6,
                "network": 0.6
            }
        9:  # Transcendence - All systems peak
            cycle_resources = {
                "cpu": 0.9,
                "memory": 0.9,
                "gpu": 0.8,
                "storage": 0.7,
                "network": 0.7
            }
        10: # Unity - Full integration
            cycle_resources = {
                "cpu": 0.8,
                "memory": 0.8,
                "gpu": 0.7,
                "storage": 0.8,
                "network": 0.6
            }
        11: # Beyond - Cycle completion
            cycle_resources = {
                "cpu": 0.5,
                "memory": 0.7,
                "gpu": 0.4,
                "storage": 0.9,
                "network": 0.3
            }
    
    # Apply freemium limits if enabled
    if freemium_optimization:
        for resource in cycle_resources:
            cycle_resources[resource] = min(cycle_resources[resource], resource_limits[resource])
    
    return cycle_resources

func _optimize_resource_usage(resource_type):
    if not enabled or not optimization_active:
        return
    
    match resource_type:
        "cpu":
            # Reduce active threads
            var high_priority_count = 0
            for thread in thread_pool:
                if thread.active and thread.priority > 5:
                    high_priority_count += 1
            
            # Keep only high priority threads if too many are active
            if high_priority_count < thread_pool.size() * 0.7:
                for i in range(thread_pool.size()):
                    if thread_pool[i].active and thread_pool[i].priority <= 5:
                        # Pause low priority thread
                        thread_pool[i].active = false
                        print("Optimizing CPU: Paused low priority thread #" + str(i))
                        break
        
        "memory":
            # Simulate memory cleanup
            resource_allocation.memory *= 0.6
            print("Optimizing Memory: Forced garbage collection")
        
        "gpu":
            # Reduce GPU usage
            resource_allocation.gpu *= 0.7
            print("Optimizing GPU: Reduced rendering quality")
        
        "storage":
            # Clean up temporary files
            print("Optimizing Storage: Cleaned temporary files")
        
        "network":
            # Throttle network operations
            resource_allocation.network *= 0.5
            print("Optimizing Network: Throttled data transfers")

func _apply_magic_cycle_resources():
    if not hourly_magic_cycles:
        return
    
    # Get resources for current magic cycle
    var cycle_resources = magic_cycle_resources[current_magic_cycle]
    
    # Gradually adjust resource allocation towards cycle targets
    for resource in resource_allocation:
        if cycle_resources.has(resource):
            # Move 10% of the way towards the target each time
            var target = cycle_resources[resource]
            var current = resource_allocation[resource]
            var new_value = current + (target - current) * 0.1
            
            # Ensure we don't exceed limits
            new_value = min(new_value, resource_limits[resource])
            
            resource_allocation[resource] = new_value

# ----- THREAD MANAGEMENT -----
func allocate_thread(task_name, priority = 5):
    if not enabled:
        return -1
    
    # Find an available thread
    for i in range(thread_pool.size()):
        if not thread_pool[i].active:
            thread_pool[i].active = true
            thread_pool[i].task = task_name
            thread_pool[i].priority = priority
            thread_pool[i].start_time = Time.get_unix_time_from_system()
            
            emit_signal("thread_pool_status_changed", _count_active_threads(), thread_pool.size())
            return i
    
    # If ethereal engine has high priority, try to preempt a lower priority thread
    if priority >= ethereal_engine_priority:
        var lowest_priority = 999
        var lowest_idx = -1
        
        for i in range(thread_pool.size()):
            if thread_pool[i].active and thread_pool[i].priority < lowest_priority:
                lowest_priority = thread_pool[i].priority
                lowest_idx = i
        
        if lowest_idx >= 0 and lowest_priority < priority:
            # Preempt the lower priority thread
            thread_pool[lowest_idx].active = true
            thread_pool[lowest_idx].task = task_name
            thread_pool[lowest_idx].priority = priority
            thread_pool[lowest_idx].start_time = Time.get_unix_time_from_system()
            
            emit_signal("thread_pool_status_changed", _count_active_threads(), thread_pool.size())
            return lowest_idx
    
    # No threads available
    return -1

func release_thread(thread_id):
    if thread_id < 0 or thread_id >= thread_pool.size():
        return false
    
    if thread_pool[thread_id].active:
        thread_pool[thread_id].active = false
        thread_pool[thread_id].task = ""
        
        emit_signal("thread_pool_status_changed", _count_active_threads(), thread_pool.size())
        return true
    
    return false

func _count_active_threads():
    var count = 0
    for thread in thread_pool:
        if thread.active:
            count += 1
    return count

# ----- FREEMIUM USAGE TRACKING -----
func _update_freemium_usage():
    if not freemium_optimization:
        return
    
    # Update CPU minutes
    var active_thread_count = _count_active_threads()
    freemium_day_usage.cpu_minutes += active_thread_count * (1.0 / 60.0)  # 1 minute of 1 CPU core
    
    # Update memory usage
    var estimated_memory_mb = resource_allocation.memory * memory_limit_mb
    freemium_day_usage.memory_mb_minutes += estimated_memory_mb * (1.0 / 60.0)  # MB-minutes
    
    # Calculate resource score (0-100)
    var resource_score = 0.0
    for resource in resource_allocation:
        resource_score += resource_allocation[resource] * 20.0  # Scale to 0-20 per resource
    
    freemium_day_usage.resource_score = resource_score
    
    emit_signal("freemium_usage_updated", freemium_day_usage)
    
    # If approaching daily limits, reduce resource usage
    if freemium_day_usage.cpu_minutes > 30.0 or freemium_day_usage.memory_mb_minutes > 15000.0:
        _reduce_resource_usage_for_freemium()

func _reduce_resource_usage_for_freemium():
    # Reduce all resource limits by 10%
    for resource in resource_limits:
        resource_limits[resource] *= 0.9
    
    # Force optimization
    optimization_active = true
    last_optimization_time = Time.get_unix_time_from_system()
    
    print("Reducing resource usage for freemium mode")

func _record_api_call():
    if freemium_optimization:
        freemium_day_usage.api_calls += 1

func _record_data_transfer(mb: float):
    if freemium_optimization:
        freemium_day_usage.data_transfers_mb += mb

# ----- OPTIMIZATION PROCESS -----
func _run_performance_optimization():
    if not enabled or optimization_active:
        return
    
    optimization_active = true
    last_optimization_time = Time.get_unix_time_from_system()
    
    print("Starting performance optimization...")
    
    # Register optimization task
    var thread_id = allocate_thread("performance_optimization", 8)
    
    if thread_id >= 0:
        # Simulate optimization process
        var start_performance = _calculate_performance_metric()
        
        # Optimize resource usage
        for resource in resource_allocation:
            if resource_allocation[resource] > resource_limits[resource] * 0.7:
                _optimize_resource_usage(resource)
        
        # Clean up unused resources
        _clean_unused_resources()
        
        # Optimize for current magic cycle
        _apply_magic_cycle_resources()
        
        # Calculate new performance
        var end_performance = _calculate_performance_metric()
        
        # Update performance stats
        performance_stats = {
            "time": Time.get_datetime_string_from_system(),
            "improvement": end_performance - start_performance,
            "level": current_performance_level
        }
        
        # Store performance for current magic cycle
        magic_cycle_performance[current_magic_cycle] = end_performance
        
        # Release thread
        release_thread(thread_id)
        
        emit_signal("performance_optimized", current_performance_level, performance_stats)
    
    optimization_active = false

func _clean_unused_resources():
    # Simulate resource cleanup
    resource_allocation.memory *= 0.9
    
    # In a real implementation, this would:
    # - Clear caches
    # - Close unused file handles
    # - Release unused GPU resources
    # - etc.
    
    print("Cleaned up unused resources")

func _calculate_performance_metric():
    # Calculate a composite performance score (0-100)
    var performance = 0.0
    
    # Resource efficiency (higher is better)
    var resource_efficiency = 0.0
    for resource in resource_allocation:
        var usage_ratio = resource_allocation[resource] / resource_limits[resource]
        resource_efficiency += (1.0 - abs(0.7 - usage_ratio)) * 20.0  # Optimal at 70% usage
    
    # Thread efficiency
    var active_threads = _count_active_threads()
    var thread_efficiency = float(active_threads) / float(max_threads) * 25.0
    
    # Magic cycle alignment (higher when resources match cycle needs)
    var cycle_alignment = 0.0
    if hourly_magic_cycles and current_magic_cycle >= 0:
        var cycle_resources = magic_cycle_resources[current_magic_cycle]
        var alignment_sum = 0.0
        var count = 0
        
        for resource in cycle_resources:
            if resource_allocation.has(resource):
                var target = cycle_resources[resource]
                var current = resource_allocation[resource]
                alignment_sum += 1.0 - abs(target - current)
                count += 1
        
        if count > 0:
            cycle_alignment = alignment_sum / count * 25.0
    
    # Freemium efficiency (higher when under limits)
    var freemium_efficiency = 0.0
    if freemium_optimization:
        var cpu_ratio = min(30.0, freemium_day_usage.cpu_minutes) / 30.0
        var memory_ratio = min(15000.0, freemium_day_usage.memory_mb_minutes) / 15000.0
        freemium_efficiency = (2.0 - cpu_ratio - memory_ratio) * 15.0
    else:
        freemium_efficiency = 15.0
    
    # Calculate total performance
    performance = resource_efficiency + thread_efficiency + cycle_alignment + freemium_efficiency
    
    # Determine performance level
    if performance < 40:
        current_performance_level = 1  # Low
    elif performance < 70:
        current_performance_level = 2  # Medium
    else:
        current_performance_level = 3  # High
    
    return performance

# ----- MAGIC CYCLE MANAGEMENT -----
func _update_magic_cycle():
    if not hourly_magic_cycles:
        return
    
    # Calculate elapsed time
    var current_time = Time.get_unix_time_from_system()
    var elapsed_seconds = current_time - magic_cycle_start_time
    
    # Calculate expected turn based on elapsed time
    var seconds_per_turn = turn_duration_minutes * 60
    var expected_turn = int(elapsed_seconds / seconds_per_turn) % 12
    
    # Check if turn system is available and synchronized
    if turn_system and turn_system.has_method("get_current_turn"):
        var system_turn = (turn_system.get_current_turn() - 1) % 12
        
        # If system turn is different, use it
        if system_turn != current_magic_cycle:
            current_magic_cycle = system_turn
            _on_magic_cycle_changed()
            return
    
    # If no turn system or not synchronized, use time-based approach
    if expected_turn != current_magic_cycle:
        current_magic_cycle = expected_turn
        _on_magic_cycle_changed()

func _on_magic_cycle_changed():
    print("Magic cycle changed to: " + str(current_magic_cycle + 1))
    
    # Apply resources for new cycle
    _apply_magic_cycle_resources()
    
    # Check if we completed a full 12-turn cycle
    if current_magic_cycle == 0:
        _on_full_magic_cycle_completed()

func _on_full_magic_cycle_completed():
    print("Completed full 12-turn magic cycle")
    
    # Calculate overall cycle performance
    var total_performance = 0.0
    for perf in magic_cycle_performance:
        total_performance += perf
    
    var avg_performance = total_performance / 12.0
    
    # Reset magic cycle start time
    magic_cycle_start_time = Time.get_unix_time_from_system()
    
    # Reset performance array
    for i in range(12):
        magic_cycle_performance[i] = 0.0
    
    emit_signal("magic_cycle_completed", current_magic_cycle, avg_performance)

# ----- EVENT HANDLERS -----
func _on_resource_monitor_timeout():
    if not enabled:
        return
    
    # Update resource usage
    _calculate_current_resource_usage()
    
    # Update magic cycle if hourly cycles enabled
    if hourly_magic_cycles:
        _update_magic_cycle()

func _on_optimization_timeout():
    if not enabled:
        return
    
    # Run optimization if it's been a while
    var current_time = Time.get_unix_time_from_system()
    if current_time - last_optimization_time > 60:  # At least 1 minute since last optimization
        _run_performance_optimization()

func _on_freemium_usage_timeout():
    if not enabled:
        return
    
    if freemium_optimization:
        _update_freemium_usage()

func _on_magic_cycle_timeout():
    if not enabled:
        return
    
    if hourly_magic_cycles:
        # Gradually apply magic cycle resources
        _apply_magic_cycle_resources()

# ----- PUBLIC API -----
func toggle_optimizer(enabled_state: bool):
    enabled = enabled_state
    return enabled

func toggle_max_performance(enabled_state: bool):
    max_performance_mode = enabled_state
    
    if max_performance_mode:
        _configure_max_performance()
    else:
        # Reset to default or freemium mode
        if freemium_optimization:
            _configure_freemium_limits()
        else:
            _initialize_resources()
    
    return max_performance_mode

func toggle_freemium_mode(enabled_state: bool):
    freemium_optimization = enabled_state
    
    if freemium_optimization:
        _configure_freemium_limits()
    else:
        # Reset to default or max performance mode
        if max_performance_mode:
            _configure_max_performance()
        else:
            _initialize_resources()
    
    return freemium_optimization

func set_hourly_magic_duration(hours: float):
    # Set duration for a full 12-turn cycle
    var minutes_per_cycle = int(hours * 60.0)
    turn_duration_minutes = max(1, minutes_per_cycle / 12)
    
    return turn_duration_minutes * 12  # Return total minutes for the cycle

func force_optimization():
    if not optimization_active:
        _run_performance_optimization()
        return true
    return false

func get_current_performance():
    return {
        "level": current_performance_level,
        "score": _calculate_performance_metric(),
        "magic_cycle": current_magic_cycle + 1,
        "resource_usage": resource_allocation.duplicate(),
        "thread_usage": _count_active_threads() / float(max_threads),
        "freemium_usage": freemium_day_usage.duplicate()
    }

func get_magic_cycle_info():
    # Calculate time remaining in current cycle
    var current_time = Time.get_unix_time_from_system()
    var elapsed_in_cycle = (current_time - magic_cycle_start_time) % (turn_duration_minutes * 60)
    var remaining_in_cycle = (turn_duration_minutes * 60) - elapsed_in_cycle
    
    return {
        "current_cycle": current_magic_cycle + 1,
        "time_elapsed": elapsed_in_cycle,
        "time_remaining": remaining_in_cycle,
        "total_duration": turn_duration_minutes * 60,
        "resources": magic_cycle_resources[current_magic_cycle].duplicate(),
        "performance": magic_cycle_performance[current_magic_cycle]
    }

func allocate_ethereal_thread(task_name):
    # Special allocation for Ethereal Engine with high priority
    return allocate_thread(task_name, ethereal_engine_priority)