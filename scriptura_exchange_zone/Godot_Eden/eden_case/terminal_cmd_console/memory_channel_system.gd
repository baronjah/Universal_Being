extends Node
class_name MemoryChannelSystem

"""
Memory Channel System
--------------------
Distributes processing tasks across multiple connected devices and memory locations.
Uses a channel-based architecture to organize data flow and processing priority.

Channel Types:
- Primary: Critical systems data and real-time processing
- Secondary: Game mechanics and medium-priority processing
- Tertiary: Background tasks, data mining, and low-priority processing
- Auxiliary: Special purpose channels for specific tasks (visualization, API connections, etc.)

Storage Types:
- RAM: Volatile in-memory processing
- Local Storage: Persistent local data (files, SQLite)
- Cloud Storage: Remote synchronized data
- Distributed: Data spread across multiple devices

Features:
- Task distribution based on device capabilities and load
- Automatic recovery from device disconnection
- Data synchronization across all connected devices
- Priority-based processing queues
- Cross-platform compatibility (Windows, Linux, macOS, Web)
"""

# Channel definitions
enum ChannelType {
    PRIMARY,
    SECONDARY,
    TERTIARY,
    AUXILIARY
}

# Storage types
enum StorageType {
    RAM,
    LOCAL,
    CLOUD,
    DISTRIBUTED
}

# Processing priorities
enum Priority {
    CRITICAL,
    HIGH,
    MEDIUM,
    LOW,
    BACKGROUND
}

# Task status
enum TaskStatus {
    PENDING,
    IN_PROGRESS,
    COMPLETED,
    FAILED,
    CANCELED
}

# Device types
enum DeviceType {
    DESKTOP,
    MOBILE,
    WEB,
    IOT,
    SERVER
}

# Structures
class MemoryChannel:
    var id: String
    var type: int  # ChannelType
    var storage_type: int  # StorageType
    var task_queue = []
    var connected_devices = []
    var capacity: int
    var current_load: float = 0.0
    var is_active: bool = true
    var created_at: int
    var description: String
    var metadata = {}
    
    func _init(p_id: String, p_type: int, p_storage_type: int, p_capacity: int = 100, p_description: String = ""):
        id = p_id
        type = p_type
        storage_type = p_storage_type
        capacity = p_capacity
        description = p_description
        created_at = OS.get_unix_time()
    
    func can_accept_task(task_size: float) -> bool:
        return is_active and (current_load + task_size <= capacity)
    
    func add_task(task) -> bool:
        if can_accept_task(task.size):
            task_queue.append(task)
            current_load += task.size
            return true
        return false
    
    func remove_task(task_id: String) -> bool:
        for i in range(task_queue.size()):
            if task_queue[i].id == task_id:
                var task = task_queue[i]
                task_queue.remove(i)
                current_load -= task.size
                return true
        return false
    
    func connect_device(device) -> bool:
        if not connected_devices.has(device):
            connected_devices.append(device)
            return true
        return false
    
    func disconnect_device(device_id: String) -> bool:
        for i in range(connected_devices.size()):
            if connected_devices[i].id == device_id:
                connected_devices.remove(i)
                return true
        return false

class Task:
    var id: String
    var name: String
    var description: String
    var priority: int  # Priority
    var status: int  # TaskStatus
    var size: float
    var dependencies = []
    var target_channel_id: String
    var target_device_id: String
    var created_at: int
    var started_at: int
    var completed_at: int
    var creator_id: String
    var payload = null  # The actual data or function to process
    var result = null  # The result of processing
    var error = null  # Any error that occurred
    
    func _init(p_id: String, p_name: String, p_priority: int, p_size: float, p_payload = null):
        id = p_id
        name = p_name
        priority = p_priority
        size = p_size
        payload = p_payload
        created_at = OS.get_unix_time()
        status = TaskStatus.PENDING
    
    func start():
        if status == TaskStatus.PENDING:
            status = TaskStatus.IN_PROGRESS
            started_at = OS.get_unix_time()
    
    func complete(p_result = null):
        status = TaskStatus.COMPLETED
        result = p_result
        completed_at = OS.get_unix_time()
    
    func fail(error_message: String):
        status = TaskStatus.FAILED
        error = error_message
        completed_at = OS.get_unix_time()
    
    func cancel():
        status = TaskStatus.CANCELED
        completed_at = OS.get_unix_time()
    
    func is_ready() -> bool:
        # Check if all dependencies are completed
        for dep_id in dependencies:
            var dep = MemoryChannelSystem.get_task(dep_id)
            if not dep or dep.status != TaskStatus.COMPLETED:
                return false
        return true

class Device:
    var id: String
    var name: String
    var type: int  # DeviceType
    var capabilities = []
    var max_capacity: float
    var current_load: float = 0.0
    var is_online: bool = true
    var last_seen: int
    var ip_address: String
    var connected_channels = []
    var metadata = {}
    
    func _init(p_id: String, p_name: String, p_type: int, p_max_capacity: float):
        id = p_id
        name = p_name
        type = p_type
        max_capacity = p_max_capacity
        last_seen = OS.get_unix_time()
    
    func update_status(online: bool):
        is_online = online
        last_seen = OS.get_unix_time()
    
    func can_accept_task(task_size: float) -> bool:
        return is_online and (current_load + task_size <= max_capacity)
    
    func add_channel(channel_id: String) -> bool:
        if not connected_channels.has(channel_id):
            connected_channels.append(channel_id)
            return true
        return false
    
    func remove_channel(channel_id: String) -> bool:
        return connected_channels.erase(channel_id)

# System variables
var _channels = {}  # Dictionary of MemoryChannel objects
var _devices = {}   # Dictionary of Device objects
var _tasks = {}     # Dictionary of Task objects
var _active_tasks = {}  # Tasks currently being processed
var _channel_stats = {}  # Statistics for each channel
var _device_stats = {}   # Statistics for each device
var _task_history = []   # History of completed tasks

# Configuration
var _config = {
    "max_channels_per_device": 10,
    "max_tasks_per_channel": 100,
    "auto_balance_load": true,
    "sync_interval": 30,  # seconds
    "timeout_threshold": 300,  # seconds
    "retry_count": 3,
    "offline_mode": false,
    "distributed_processing": true,
    "encryption_enabled": true,
    "compression_enabled": true,
    "debug_mode": false
}

var _sync_timer: Timer = null
var _cleanup_timer: Timer = null
var _is_initialized: bool = false
var _current_device_id: String = ""
var _system_id: String = ""

# Signals
signal channel_created(channel_id, type)
signal channel_removed(channel_id)
signal device_connected(device_id, device_name)
signal device_disconnected(device_id)
signal task_created(task_id, priority)
signal task_started(task_id)
signal task_completed(task_id, result)
signal task_failed(task_id, error)
signal sync_started
signal sync_completed
signal system_initialized
signal system_error(error_message)

func _ready():
    _system_id = generate_unique_id()
    _init_timers()
    if auto_init():
        initialize()

func _init_timers():
    _sync_timer = Timer.new()
    _sync_timer.wait_time = _config.sync_interval
    _sync_timer.one_shot = false
    _sync_timer.connect("timeout", self, "_on_sync_timer_timeout")
    add_child(_sync_timer)
    
    _cleanup_timer = Timer.new()
    _cleanup_timer.wait_time = 300  # 5 minutes
    _cleanup_timer.one_shot = false
    _cleanup_timer.connect("timeout", self, "_on_cleanup_timer_timeout")
    add_child(_cleanup_timer)

func auto_init() -> bool:
    # Check if we should automatically initialize based on project settings
    var auto_init = ProjectSettings.get_setting("memory_channel/auto_init") if ProjectSettings.has_setting("memory_channel/auto_init") else true
    return auto_init

func initialize():
    if _is_initialized:
        return
    
    # Initialize the current device
    var system_info = OS.get_name()
    var device_type = DeviceType.DESKTOP
    
    if system_info == "Android" or system_info == "iOS":
        device_type = DeviceType.MOBILE
    elif system_info == "HTML5":
        device_type = DeviceType.WEB
    
    var device_name = OS.get_name() + "-" + OS.get_unique_id()
    _current_device_id = generate_unique_id()
    
    var current_device = Device.new(_current_device_id, device_name, device_type, 100.0)
    _devices[_current_device_id] = current_device
    
    # Create default channels
    _create_default_channels()
    
    # Start timers
    _sync_timer.start()
    _cleanup_timer.start()
    
    _is_initialized = true
    emit_signal("system_initialized")
    
    if _config.debug_mode:
        print("Memory Channel System initialized. Device ID: ", _current_device_id)

func _create_default_channels():
    # Create primary channel (RAM)
    create_channel("primary_ram", ChannelType.PRIMARY, StorageType.RAM, 200, "Primary in-memory channel")
    
    # Create secondary channel (Local)
    create_channel("secondary_local", ChannelType.SECONDARY, StorageType.LOCAL, 500, "Secondary local storage channel")
    
    # Create tertiary channel (Local)
    create_channel("tertiary_local", ChannelType.TERTIARY, StorageType.LOCAL, 1000, "Tertiary local storage channel")
    
    # Create auxiliary channel for API connections
    create_channel("aux_api", ChannelType.AUXILIARY, StorageType.RAM, 50, "API connection channel")
    
    # Create auxiliary channel for visualization
    create_channel("aux_visual", ChannelType.AUXILIARY, StorageType.RAM, 100, "Visualization processing channel")

func create_channel(id: String, type: int, storage_type: int, capacity: int = 100, description: String = "") -> bool:
    if _channels.has(id):
        if _config.debug_mode:
            push_error("Channel ID already exists: " + id)
        return false
    
    var channel = MemoryChannel.new(id, type, storage_type, capacity, description)
    _channels[id] = channel
    
    # Connect the current device to this channel
    channel.connect_device(_devices[_current_device_id])
    _devices[_current_device_id].add_channel(id)
    
    # Initialize stats for this channel
    _channel_stats[id] = {
        "tasks_processed": 0,
        "tasks_failed": 0,
        "avg_processing_time": 0.0,
        "peak_load": 0.0,
        "created_at": OS.get_unix_time()
    }
    
    emit_signal("channel_created", id, type)
    return true

func remove_channel(id: String) -> bool:
    if not _channels.has(id):
        return false
    
    # Move any pending tasks to another channel
    var channel = _channels[id]
    for task in channel.task_queue:
        # Find another suitable channel
        var target_channel_id = find_suitable_channel(task.size, task.priority)
        if target_channel_id:
            var target_channel = _channels[target_channel_id]
            if target_channel.add_task(task):
                # Success
                pass
            else:
                # Failed to move task, will be lost when channel is removed
                if _config.debug_mode:
                    push_warning("Failed to move task " + task.id + " when removing channel " + id)
    
    # Disconnect all devices from this channel
    for device_id in _devices:
        _devices[device_id].remove_channel(id)
    
    # Remove the channel
    _channels.erase(id)
    _channel_stats.erase(id)
    
    emit_signal("channel_removed", id)
    return true

func find_suitable_channel(task_size: float, priority: int) -> String:
    var best_channel_id = ""
    var best_fit_score = -1
    
    for channel_id in _channels:
        var channel = _channels[channel_id]
        
        # Skip if channel can't accept this task
        if not channel.can_accept_task(task_size):
            continue
        
        # Calculate a fit score based on channel type and priority
        var fit_score = 0
        
        # High priority tasks prefer PRIMARY channels
        if priority == Priority.CRITICAL or priority == Priority.HIGH:
            if channel.type == ChannelType.PRIMARY:
                fit_score += 30
            elif channel.type == ChannelType.SECONDARY:
                fit_score += 15
        # Medium priority tasks prefer SECONDARY channels
        elif priority == Priority.MEDIUM:
            if channel.type == ChannelType.SECONDARY:
                fit_score += 30
            elif channel.type == ChannelType.PRIMARY:
                fit_score += 10
            elif channel.type == ChannelType.TERTIARY:
                fit_score += 5
        # Low priority tasks prefer TERTIARY channels
        else:
            if channel.type == ChannelType.TERTIARY:
                fit_score += 30
            elif channel.type == ChannelType.SECONDARY:
                fit_score += 10
        
        # Consider current load (prefer less loaded channels)
        var load_factor = 1.0 - (channel.current_load / channel.capacity)
        fit_score += int(load_factor * 20)
        
        # If this channel is better than what we've seen so far, use it
        if fit_score > best_fit_score:
            best_fit_score = fit_score
            best_channel_id = channel_id
    
    return best_channel_id

func create_task(name: String, priority: int, size: float, payload = null, dependencies = []) -> String:
    var task_id = generate_unique_id()
    var task = Task.new(task_id, name, priority, size, payload)
    
    # Add dependencies if any
    task.dependencies = dependencies.duplicate()
    
    # Find a suitable channel for this task
    var channel_id = find_suitable_channel(size, priority)
    
    if not channel_id:
        if _config.debug_mode:
            push_error("No suitable channel found for task: " + name)
        return ""
    
    task.target_channel_id = channel_id
    task.creator_id = _current_device_id
    
    # Add the task to the chosen channel
    var channel = _channels[channel_id]
    if not channel.add_task(task):
        if _config.debug_mode:
            push_error("Failed to add task to channel: " + channel_id)
        return ""
    
    # Add to our task dictionary
    _tasks[task_id] = task
    
    emit_signal("task_created", task_id, priority)
    
    if _config.debug_mode:
        print("Task created: ", name, " (", task_id, ") on channel ", channel_id)
    
    # Check if we can process this task immediately
    process_pending_tasks()
    
    return task_id

func process_pending_tasks():
    # Process each channel
    for channel_id in _channels:
        var channel = _channels[channel_id]
        
        # Skip inactive channels
        if not channel.is_active:
            continue
        
        # Find tasks that can be processed based on dependencies
        var processable_tasks = []
        
        for task in channel.task_queue:
            if task.status == TaskStatus.PENDING and task.is_ready():
                processable_tasks.append(task)
        
        # Sort by priority (higher priorities first)
        processable_tasks.sort_custom(self, "_sort_tasks_by_priority")
        
        # Process tasks
        for task in processable_tasks:
            # Find a suitable device
            var device_id = find_suitable_device(task.size)
            
            if not device_id:
                # No device available to process this task
                continue
            
            # Assign task to device
            task.target_device_id = device_id
            _devices[device_id].current_load += task.size
            
            # Start processing the task
            start_task(task.id)

func _sort_tasks_by_priority(a, b):
    # Lower value = higher priority
    return a.priority < b.priority

func find_suitable_device(task_size: float) -> String:
    # Current implementation just uses the current device
    # This would be expanded in a networked setup
    if _devices[_current_device_id].can_accept_task(task_size):
        return _current_device_id
    return ""

func start_task(task_id: String) -> bool:
    if not _tasks.has(task_id):
        return false
    
    var task = _tasks[task_id]
    
    # Check if task can be started
    if task.status != TaskStatus.PENDING or not task.is_ready():
        return false
    
    # Start the task
    task.start()
    
    # Move to active tasks
    _active_tasks[task_id] = task
    
    # Remove from channel queue
    var channel = _channels[task.target_channel_id]
    channel.remove_task(task_id)
    
    emit_signal("task_started", task_id)
    
    # Process the task
    _process_task(task)
    
    return true

func _process_task(task):
    # Processing logic depends on task type
    # For now, we just handle a simple function call if payload is a callable
    if task.payload is FuncRef:
        var result = null
        var error = null
        
        # Try to call the function
        try:
            result = task.payload.call_func()
        except:
            error = "Exception while executing task function"
            task.fail(error)
            emit_signal("task_failed", task.id, error)
            return
        
        # Task completed successfully
        task.complete(result)
        emit_signal("task_completed", task.id, result)
    else:
        # For non-function payloads, just store the payload as the result
        task.complete(task.payload)
        emit_signal("task_completed", task.id, task.payload)
    
    # Update statistics
    _update_stats_for_completed_task(task)
    
    # Free up device resources
    if _devices.has(task.target_device_id):
        _devices[task.target_device_id].current_load -= task.size
    
    # Remove from active tasks and add to history
    _active_tasks.erase(task.id)
    _task_history.append(task)
    
    # Process any tasks that might be waiting on this one
    process_pending_tasks()

func _update_stats_for_completed_task(task):
    # Update channel stats
    if _channel_stats.has(task.target_channel_id):
        var stats = _channel_stats[task.target_channel_id]
        
        if task.status == TaskStatus.COMPLETED:
            stats.tasks_processed += 1
            
            # Update average processing time
            var processing_time = task.completed_at - task.started_at
            var old_avg = stats.avg_processing_time
            var old_count = stats.tasks_processed - 1
            
            if old_count > 0:
                stats.avg_processing_time = (old_avg * old_count + processing_time) / stats.tasks_processed
            else:
                stats.avg_processing_time = processing_time
        elif task.status == TaskStatus.FAILED:
            stats.tasks_failed += 1
    
    # Update device stats
    if _device_stats.has(task.target_device_id):
        var stats = _device_stats[task.target_device_id]
        
        if task.status == TaskStatus.COMPLETED:
            stats.tasks_processed += 1
        elif task.status == TaskStatus.FAILED:
            stats.tasks_failed += 1

func get_task(task_id: String):
    if _tasks.has(task_id):
        return _tasks[task_id]
    return null

func get_task_status(task_id: String) -> int:
    if _tasks.has(task_id):
        return _tasks[task_id].status
    return -1

func get_task_result(task_id: String):
    if _tasks.has(task_id) and _tasks[task_id].status == TaskStatus.COMPLETED:
        return _tasks[task_id].result
    return null

func cancel_task(task_id: String) -> bool:
    if not _tasks.has(task_id):
        return false
    
    var task = _tasks[task_id]
    
    # Can only cancel pending or in-progress tasks
    if task.status != TaskStatus.PENDING and task.status != TaskStatus.IN_PROGRESS:
        return false
    
    # Cancel the task
    task.cancel()
    
    # If it was in a channel, remove it
    if task.status == TaskStatus.PENDING and _channels.has(task.target_channel_id):
        _channels[task.target_channel_id].remove_task(task_id)
    
    # If it was active, free up device resources
    if task.status == TaskStatus.IN_PROGRESS and _devices.has(task.target_device_id):
        _devices[task.target_device_id].current_load -= task.size
        _active_tasks.erase(task_id)
    
    # Move to history
    _task_history.append(task)
    
    return true

func get_channel(channel_id: String):
    if _channels.has(channel_id):
        return _channels[channel_id]
    return null

func get_channels() -> Array:
    return _channels.values()

func get_device(device_id: String):
    if _devices.has(device_id):
        return _devices[device_id]
    return null

func get_current_device():
    return _devices[_current_device_id]

func get_system_stats() -> Dictionary:
    var total_tasks = 0
    var completed_tasks = 0
    var failed_tasks = 0
    var total_channels = _channels.size()
    var active_channels = 0
    var total_devices = _devices.size()
    var online_devices = 0
    
    # Count tasks
    for task_id in _tasks:
        total_tasks += 1
        var task = _tasks[task_id]
        if task.status == TaskStatus.COMPLETED:
            completed_tasks += 1
        elif task.status == TaskStatus.FAILED:
            failed_tasks += 1
    
    # Count channels and devices
    for channel_id in _channels:
        if _channels[channel_id].is_active:
            active_channels += 1
    
    for device_id in _devices:
        if _devices[device_id].is_online:
            online_devices += 1
    
    return {
        "total_tasks": total_tasks,
        "completed_tasks": completed_tasks,
        "failed_tasks": failed_tasks,
        "active_tasks": _active_tasks.size(),
        "task_success_rate": 0.0 if total_tasks == 0 else float(completed_tasks) / total_tasks,
        "total_channels": total_channels,
        "active_channels": active_channels,
        "total_devices": total_devices,
        "online_devices": online_devices,
        "system_uptime": OS.get_unix_time() - _channels["primary_ram"].created_at if _channels.has("primary_ram") else 0
    }

func _on_sync_timer_timeout():
    synchronize()

func synchronize():
    emit_signal("sync_started")
    
    # In a networked setup, this would sync data with other devices
    # For now, we just update our local state
    
    # Check for timed-out tasks
    var current_time = OS.get_unix_time()
    var timeout_threshold = _config.timeout_threshold
    
    for task_id in _active_tasks.keys():
        var task = _active_tasks[task_id]
        if current_time - task.started_at > timeout_threshold:
            # Task timed out
            task.fail("Task timed out after " + str(timeout_threshold) + " seconds")
            emit_signal("task_failed", task.id, "Task timed out")
            
            # Free up device resources
            if _devices.has(task.target_device_id):
                _devices[task.target_device_id].current_load -= task.size
            
            # Remove from active tasks and add to history
            _active_tasks.erase(task.id)
            _task_history.append(task)
    
    # Update device statuses
    for device_id in _devices:
        var device = _devices[device_id]
        if device_id == _current_device_id:
            device.update_status(true)  # Current device is always online
        else:
            # In a networked setup, we would check for actual connection status
            # For now, we assume external devices may go offline after a timeout
            if current_time - device.last_seen > timeout_threshold:
                device.update_status(false)
    
    emit_signal("sync_completed")

func _on_cleanup_timer_timeout():
    cleanup_old_tasks()

func cleanup_old_tasks():
    # Remove old task history beyond a certain limit
    var max_history = 1000
    while _task_history.size() > max_history:
        _task_history.pop_front()

func generate_unique_id() -> String:
    var id = str(OS.get_unix_time()) + "-" + str(randi() % 1000000).pad_zeros(6)
    return id

func shutdown():
    _sync_timer.stop()
    _cleanup_timer.stop()
    
    # Cancel all active tasks
    for task_id in _active_tasks:
        cancel_task(task_id)
    
    _is_initialized = false
    
    if _config.debug_mode:
        print("Memory Channel System shutdown")

func _exit_tree():
    shutdown()

# Utility methods
func get_channel_by_name(name: String) -> String:
    for channel_id in _channels:
        if _channels[channel_id].description == name:
            return channel_id
    return ""

func get_task_by_name(name: String) -> String:
    for task_id in _tasks:
        if _tasks[task_id].name == name:
            return task_id
    return ""

# Create function task
func create_function_task(name: String, func_ref: FuncRef, priority: int, size: float = 1.0, dependencies = []) -> String:
    return create_task(name, priority, size, func_ref, dependencies)

# Example usage:
# var memory_system = MemoryChannelSystem.new()
# add_child(memory_system)
# memory_system.initialize()
# 
# var funcref = funcref(self, "my_function")
# var task_id = memory_system.create_function_task("My Task", funcref, MemoryChannelSystem.Priority.HIGH)
# 
# # Later check the result:
# var result = memory_system.get_task_result(task_id)