extends Node
class_name MemoryYoyoCatcher

"""
Memory Yo-Yo Catcher System
--------------------------
Captures and processes memory fragments across devices
Implements yo-yo catching pattern for memory synchronization
Connects data across multiple storage devices and browsers
"""

# Constants
const YOYO_TYPES = {
    "STANDARD": 0,    # Regular memory yo-yo
    "RETURNING": 1,   # Auto-returns to source
    "CONTINUOUS": 2,  # Stays in motion continuously
    "LOOPING": 3,     # Creates memory loops
    "SPLITTING": 4,   # Splits as it returns
    "MERGING": 5,     # Merges with other yo-yos
    "DIMENSIONAL": 6  # Crosses dimensional boundaries
}

const DEVICE_TYPES = {
    "DESKTOP": 0,     # Desktop computer
    "LAPTOP": 1,      # Laptop computer
    "PHONE": 2,       # Mobile phone
    "TABLET": 3,      # Tablet device
    "BROWSER": 4,     # Web browser
    "TERMINAL": 5,    # Terminal application
    "SERVER": 6,      # Remote server
    "CUSTOM": 7       # Custom device type
}

const STORAGE_LOCATIONS = {
    "PRIMARY": 0,     # Main storage
    "SECONDARY": 1,   # Backup storage
    "TERTIARY": 2,    # Archive storage
    "CLOUD": 3,       # Cloud storage
    "DISTRIBUTED": 4, # Distributed across multiple locations
    "BROWSER": 5,     # Browser storage (localStorage/IndexedDB)
    "MEMORY": 6       # In-memory only (volatile)
}

const MAX_CATCH_ATTEMPTS = 5
const DEFAULT_THROW_VELOCITY = 3.0
const YO_YO_PATH_MARKERS = [
    "_s",             # Standard path marker
    "---->",          # Forward path
    "<----",          # Return path
    "<-->",           # Bidirectional path
    "~~~~",           # Wave path
    "/\\",            # Angular path
    "[]",             # Contained path
    "()",             # Grouped path
    "{}"              # Block path
]

# System components
var _main_system = null
var _memory_system = null
var _connection_system = null
var _communication_bridge = null
var _secure_channel = null
var _yoyos = {}        # id -> MemoryYoYo
var _catch_history = []
var _device_registry = {}
var _active_yoyo_count = 0
var _current_yoyo_type = YOYO_TYPES.STANDARD
var _active_devices = []
var _catches_per_minute = 0
var _catch_timer = null
var _auto_catch_enabled = true
var _throw_velocity = DEFAULT_THROW_VELOCITY
var _current_device_type = DEVICE_TYPES.DESKTOP
var _current_storage_location = STORAGE_LOCATIONS.PRIMARY
var _sync_frequency = 60 # seconds

# Data structures
class MemoryYoYo:
    var id: String
    var type: int
    var memory_ids = []
    var source_device: String
    var target_devices = []
    var path_marker: String
    var creation_time: int
    var last_catch_time: int = -1
    var catch_count: int = 0
    var is_active: bool = true
    var velocity: float
    var metadata = {}
    
    func _init(p_id: String, p_type: int, p_marker: String = "_s"):
        id = p_id
        type = p_type
        path_marker = p_marker
        creation_time = OS.get_unix_time()
        velocity = DEFAULT_THROW_VELOCITY
    
    func add_memory(memory_id: String):
        if not memory_ids.has(memory_id):
            memory_ids.append(memory_id)
    
    func add_target_device(device_id: String):
        if not target_devices.has(device_id):
            target_devices.append(device_id)
    
    func catch():
        last_catch_time = OS.get_unix_time()
        catch_count += 1
    
    func time_since_last_catch() -> int:
        if last_catch_time < 0:
            return -1
        return OS.get_unix_time() - last_catch_time
    
    func time_in_flight() -> int:
        if last_catch_time < 0:
            return OS.get_unix_time() - creation_time
        return last_catch_time - creation_time
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "type": type,
            "memory_ids": memory_ids,
            "source_device": source_device,
            "target_devices": target_devices,
            "path_marker": path_marker,
            "creation_time": creation_time,
            "last_catch_time": last_catch_time,
            "catch_count": catch_count,
            "is_active": is_active,
            "velocity": velocity,
            "metadata": metadata
        }
    
    static func from_dict(data: Dictionary) -> MemoryYoYo:
        var yoyo = MemoryYoYo.new(
            data.id,
            data.type,
            data.path_marker
        )
        
        yoyo.memory_ids = data.memory_ids.duplicate()
        yoyo.source_device = data.source_device
        yoyo.target_devices = data.target_devices.duplicate()
        yoyo.creation_time = data.creation_time
        yoyo.last_catch_time = data.last_catch_time
        yoyo.catch_count = data.catch_count
        yoyo.is_active = data.is_active
        yoyo.velocity = data.velocity
        yoyo.metadata = data.metadata.duplicate()
        
        return yoyo

class DeviceConnection:
    var id: String
    var name: String
    var type: int
    var ip_address: String = ""
    var is_connected: bool = false
    var last_connection: int = -1
    var storage_location: int
    var connection_count: int = 0
    var capabilities = []
    var metadata = {}
    
    func _init(p_id: String, p_name: String, p_type: int, p_storage: int):
        id = p_id
        name = p_name
        type = p_type
        storage_location = p_storage
    
    func connect():
        is_connected = true
        last_connection = OS.get_unix_time()
        connection_count += 1
    
    func disconnect():
        is_connected = false
    
    func add_capability(capability: String):
        if not capabilities.has(capability):
            capabilities.append(capability)
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "name": name,
            "type": type,
            "ip_address": ip_address,
            "is_connected": is_connected,
            "last_connection": last_connection,
            "storage_location": storage_location,
            "connection_count": connection_count,
            "capabilities": capabilities,
            "metadata": metadata
        }
    
    static func from_dict(data: Dictionary) -> DeviceConnection:
        var device = DeviceConnection.new(
            data.id,
            data.name,
            data.type,
            data.storage_location
        )
        
        device.ip_address = data.ip_address
        device.is_connected = data.is_connected
        device.last_connection = data.last_connection
        device.connection_count = data.connection_count
        device.capabilities = data.capabilities.duplicate()
        device.metadata = data.metadata.duplicate()
        
        return device

class CatchEvent:
    var id: String
    var yoyo_id: String
    var device_id: String
    var memory_ids = []
    var catch_time: int
    var catch_success: bool
    var error_message: String = ""
    var metadata = {}
    
    func _init(p_id: String, p_yoyo_id: String, p_device_id: String):
        id = p_id
        yoyo_id = p_yoyo_id
        device_id = p_device_id
        catch_time = OS.get_unix_time()
    
    func add_memory(memory_id: String):
        if not memory_ids.has(memory_id):
            memory_ids.append(memory_id)
    
    func succeed():
        catch_success = true
    
    func fail(message: String):
        catch_success = false
        error_message = message
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "yoyo_id": yoyo_id,
            "device_id": device_id,
            "memory_ids": memory_ids,
            "catch_time": catch_time,
            "catch_success": catch_success,
            "error_message": error_message,
            "metadata": metadata
        }
    
    static func from_dict(data: Dictionary) -> CatchEvent:
        var event = CatchEvent.new(
            data.id,
            data.yoyo_id,
            data.device_id
        )
        
        event.memory_ids = data.memory_ids.duplicate()
        event.catch_time = data.catch_time
        event.catch_success = data.catch_success
        event.error_message = data.error_message
        event.metadata = data.metadata.duplicate()
        
        return event

# Signals
signal yoyo_created(yoyo_id)
signal yoyo_caught(yoyo_id, event_id)
signal device_connected(device_id)
signal storage_synchronized(device_id, storage_id)
signal auto_catch_toggled(enabled)

# System Initialization
func _ready():
    # Setup timer for catch statistics
    _catch_timer = Timer.new()
    _catch_timer.wait_time = 60.0  # 1 minute
    _catch_timer.connect("timeout", self, "_on_catch_timer_timeout")
    _catch_timer.autostart = true
    add_child(_catch_timer)
    
    # Load data
    load_yoyos()
    load_device_registry()

func initialize(
    main_system = null,
    memory_system = null,
    connection_system = null,
    communication_bridge = null,
    secure_channel = null
):
    _main_system = main_system
    _memory_system = memory_system
    _connection_system = connection_system
    _communication_bridge = communication_bridge
    _secure_channel = secure_channel
    
    # Register this device
    register_current_device()
    
    # Start auto-catch if enabled
    if _auto_catch_enabled:
        start_auto_catch()
    
    return true

# YoYo Management
func create_yoyo(type: int = -1, path_marker: String = "") -> String:
    if type < 0:
        type = _current_yoyo_type
    
    if path_marker.empty():
        # Pick a default path marker
        path_marker = YO_YO_PATH_MARKERS[0]  # Default: "_s"
    
    var yoyo_id = "yoyo_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    var yoyo = MemoryYoYo.new(yoyo_id, type, path_marker)
    
    # Set source device
    var device_id = get_current_device_id()
    yoyo.source_device = device_id
    
    # Set velocity
    yoyo.velocity = _throw_velocity
    
    # Add to active yoyos
    _yoyos[yoyo_id] = yoyo
    _active_yoyo_count += 1
    
    # Save yoyos
    save_yoyos()
    
    emit_signal("yoyo_created", yoyo_id)
    
    return yoyo_id

func add_memory_to_yoyo(yoyo_id: String, memory_id: String) -> bool:
    if not _yoyos.has(yoyo_id):
        return false
    
    _yoyos[yoyo_id].add_memory(memory_id)
    
    # Save yoyos
    save_yoyos()
    
    return true

func set_yoyo_target(yoyo_id: String, target_device_id: String) -> bool:
    if not _yoyos.has(yoyo_id):
        return false
    
    _yoyos[yoyo_id].add_target_device(target_device_id)
    
    # Save yoyos
    save_yoyos()
    
    return true

func throw_yoyo(yoyo_id: String) -> bool:
    if not _yoyos.has(yoyo_id):
        return false
    
    var yoyo = _yoyos[yoyo_id]
    
    # Check if there's anything to throw
    if yoyo.memory_ids.empty():
        return false
    
    # Check if there are target devices
    if yoyo.target_devices.empty():
        // Add all connected devices as targets
        for device_id in _active_devices:
            yoyo.add_target_device(device_id)
        
        // If still empty, nothing to do
        if yoyo.target_devices.empty():
            return false
    
    // Simulate throwing the yoyo
    // In a real implementation, this would involve network communication
    
    return true

func catch_yoyo(yoyo_id: String) -> Dictionary:
    if not _yoyos.has(yoyo_id):
        return {"success": false, "error": "YoYo not found"}
    
    var yoyo = _yoyos[yoyo_id]
    
    // Create catch event
    var event_id = "catch_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    var event = CatchEvent.new(event_id, yoyo_id, get_current_device_id())
    
    // Process memory retrieval
    var memories_caught = []
    var catch_success = true
    
    for memory_id in yoyo.memory_ids:
        event.add_memory(memory_id)
        
        // In a real system, this would retrieve memory data from storage
        memories_caught.append(memory_id)
    
    // Update yoyo status
    yoyo.catch()
    
    // Check if this is a returning yoyo
    var is_returning = false
    if yoyo.type == YOYO_TYPES.RETURNING:
        is_returning = true
    
    // Handle specific yoyo types
    match yoyo.type:
        YOYO_TYPES.SPLITTING:
            // Create a split yoyo with half the memories
            var split_yoyo_id = _split_yoyo(yoyo)
            if not split_yoyo_id.empty():
                event.metadata["split_yoyo"] = split_yoyo_id
        
        YOYO_TYPES.MERGING:
            // Look for other yoyos to merge with
            var merge_result = _find_and_merge_yoyos(yoyo)
            if merge_result.merged:
                event.metadata["merged_with"] = merge_result.merged_with
        
        YOYO_TYPES.LOOPING:
            // Automatically throw again
            throw_yoyo(yoyo_id)
            event.metadata["auto_thrown"] = true
    
    // Mark event as successful
    event.succeed()
    
    // Add to catch history
    _catch_history.append(event)
    
    // Save data
    save_yoyos()
    
    emit_signal("yoyo_caught", yoyo_id, event_id)
    
    return {
        "success": true,
        "memories_caught": memories_caught,
        "is_returning": is_returning,
        "event_id": event_id
    }

func _split_yoyo(yoyo: MemoryYoYo) -> String:
    // Create a new yoyo with half the memories
    var split_yoyo_id = create_yoyo(yoyo.type, yoyo.path_marker)
    var split_yoyo = _yoyos[split_yoyo_id]
    
    // Split memories
    var memory_count = yoyo.memory_ids.size()
    var split_point = memory_count / 2
    
    for i in range(split_point, memory_count):
        split_yoyo.add_memory(yoyo.memory_ids[i])
    
    // Remove split memories from original
    for i in range(memory_count - 1, split_point - 1, -1):
        yoyo.memory_ids.remove(i)
    
    // Copy target devices
    for device_id in yoyo.target_devices:
        split_yoyo.add_target_device(device_id)
    
    return split_yoyo_id

func _find_and_merge_yoyos(yoyo: MemoryYoYo) -> Dictionary {
    var result = {
        "merged": false,
        "merged_with": []
    }
    
    // Find other merging yoyos
    for other_id in _yoyos:
        if other_id == yoyo.id:
            continue
        
        var other = _yoyos[other_id]
        if other.type == YOYO_TYPES.MERGING and other.is_active:
            // Merge memories
            for memory_id in other.memory_ids:
                if not yoyo.memory_ids.has(memory_id):
                    yoyo.add_memory(memory_id)
            
            // Deactivate the other yoyo
            other.is_active = false
            
            result.merged = true
            result.merged_with.append(other_id)
    
    return result

# Device Management
func register_current_device():
    var device_name = OS.get_name() + " (" + OS.get_model_name() + ")"
    var device_id = "device_" + device_name.sha256_text().substr(0, 8)
    
    // Check if already registered
    if _device_registry.has(device_id):
        _device_registry[device_id].connect()
        return device_id
    
    // Create new device registration
    var device = DeviceConnection.new(
        device_id,
        device_name,
        _current_device_type,
        _current_storage_location
    )
    
    // Set device capabilities
    device.add_capability("memory_storage")
    device.add_capability("yoyo_catching")
    
    if _memory_system:
        device.add_capability("memory_system")
    
    if _connection_system:
        device.add_capability("connection_system")
    
    if _communication_bridge:
        device.add_capability("communication_bridge")
    
    if _secure_channel:
        device.add_capability("secure_channel")
    
    // Connect device
    device.connect()
    
    // Add to registry
    _device_registry[device_id] = device
    
    // Add to active devices
    if not _active_devices.has(device_id):
        _active_devices.append(device_id)
    
    // Save registry
    save_device_registry()
    
    emit_signal("device_connected", device_id)
    
    return device_id

func register_device(name: String, type: int, storage_location: int) -> String {
    var device_id = "device_" + name.sha256_text().substr(0, 8)
    
    // Create new device registration
    var device = DeviceConnection.new(
        device_id,
        name,
        type,
        storage_location
    )
    
    // Set device capabilities based on type
    match type:
        DEVICE_TYPES.DESKTOP, DEVICE_TYPES.LAPTOP:
            device.add_capability("memory_storage")
            device.add_capability("yoyo_catching")
            device.add_capability("memory_system")
        
        DEVICE_TYPES.PHONE, DEVICE_TYPES.TABLET:
            device.add_capability("memory_storage")
            device.add_capability("yoyo_catching")
        
        DEVICE_TYPES.BROWSER:
            device.add_capability("memory_storage")
            device.add_capability("yoyo_catching")
        
        DEVICE_TYPES.TERMINAL:
            device.add_capability("memory_storage")
            device.add_capability("yoyo_catching")
            device.add_capability("command_processing")
    
    // Add to registry
    _device_registry[device_id] = device
    
    // Save registry
    save_device_registry()
    
    return device_id

func connect_device(device_id: String) -> bool:
    if not _device_registry.has(device_id):
        return false
    
    _device_registry[device_id].connect()
    
    // Add to active devices
    if not _active_devices.has(device_id):
        _active_devices.append(device_id)
    
    // Save registry
    save_device_registry()
    
    emit_signal("device_connected", device_id)
    
    return true

func disconnect_device(device_id: String) -> bool:
    if not _device_registry.has(device_id):
        return false
    
    _device_registry[device_id].disconnect()
    
    // Remove from active devices
    if _active_devices.has(device_id):
        _active_devices.erase(device_id)
    
    // Save registry
    save_device_registry()
    
    return true

func get_device(device_id: String) -> DeviceConnection:
    if _device_registry.has(device_id):
        return _device_registry[device_id]
    
    return null

func get_current_device_id() -> String:
    var device_name = OS.get_name() + " (" + OS.get_model_name() + ")"
    return "device_" + device_name.sha256_text().substr(0, 8)

# Storage Management
func sync_with_all_devices() -> Dictionary:
    var result = {
        "success": true,
        "devices_synced": []
    }
    
    for device_id in _active_devices:
        if device_id == get_current_device_id():
            continue
        
        var sync_result = sync_with_device(device_id)
        
        if sync_result.success:
            result.devices_synced.append(device_id)
    
    return result

func sync_with_device(device_id: String) -> Dictionary:
    if not _device_registry.has(device_id):
        return {"success": false, "error": "Device not registered"}
    
    var device = _device_registry[device_id]
    
    if not device.is_connected:
        return {"success": false, "error": "Device not connected"}
    
    // Simulate synchronization
    var storage_id = "storage_" + device_id + "_" + str(OS.get_unix_time())
    
    var result = {
        "success": true,
        "storage_id": storage_id,
        "device_id": device_id,
        "timestamp": OS.get_unix_time(),
        "yoyos_synced": 0,
        "memories_synced": 0
    }
    
    // Get active yoyos
    var active_yoyos = []
    for yoyo_id in _yoyos:
        var yoyo = _yoyos[yoyo_id]
        if yoyo.is_active:
            active_yoyos.append(yoyo)
    
    result.yoyos_synced = active_yoyos.size()
    
    // Count memories
    var all_memories = []
    for yoyo in active_yoyos:
        for memory_id in yoyo.memory_ids:
            if not all_memories.has(memory_id):
                all_memories.append(memory_id)
    
    result.memories_synced = all_memories.size()
    
    // Track last connection
    device.connect()
    
    // Save registry
    save_device_registry()
    
    emit_signal("storage_synchronized", device_id, storage_id)
    
    return result

# Auto-catch functionality
func start_auto_catch():
    if not _auto_catch_enabled:
        _auto_catch_enabled = true
        emit_signal("auto_catch_toggled", true)
    
    // Start a timer to periodically catch yoyos
    var auto_catch_timer = Timer.new()
    auto_catch_timer.autostart = true
    auto_catch_timer.wait_time = 10.0 // Check every 10 seconds
    auto_catch_timer.one_shot = false
    auto_catch_timer.connect("timeout", self, "_on_auto_catch_timer_timeout")
    add_child(auto_catch_timer)

func stop_auto_catch():
    _auto_catch_enabled = false
    emit_signal("auto_catch_toggled", false)
    
    // Stop any auto-catch timers
    for child in get_children():
        if child is Timer and child != _catch_timer:
            child.queue_free()

func _on_auto_catch_timer_timeout():
    if not _auto_catch_enabled:
        return
    
    // Find catchable yoyos
    var catchable_yoyos = []
    
    for yoyo_id in _yoyos:
        var yoyo = _yoyos[yoyo_id]
        
        if not yoyo.is_active:
            continue
        
        // Check if this device is a target
        var device_id = get_current_device_id()
        if yoyo.target_devices.has(device_id) or yoyo.target_devices.empty():
            catchable_yoyos.append(yoyo_id)
    
    // Catch one random yoyo
    if catchable_yoyos.size() > 0:
        var random_index = randi() % catchable_yoyos.size()
        var yoyo_to_catch = catchable_yoyos[random_index]
        
        catch_yoyo(yoyo_to_catch)

func _on_catch_timer_timeout():
    // Reset catch counter for statistics
    _catches_per_minute = 0

# Integration with main.gd and memory system
func connect_to_main_system(main_system) -> bool:
    if not main_system:
        return false
    
    _main_system = main_system
    return true

func create_memory_yoyo_from_word(word_text: String, path_marker: String = "_s") -> Dictionary {
    if not _main_system or not _memory_system:
        return {"success": false, "error": "Main system or memory system not available"}
    
    // Create memory
    var memory_id = ""
    if _main_system.has_method("add_word"):
        memory_id = _main_system.add_word(word_text)
    elif _memory_system.has_method("create_memory"):
        memory_id = _memory_system.create_memory(word_text)
    
    if memory_id.empty():
        return {"success": false, "error": "Failed to create memory"}
    
    // Create yoyo
    var yoyo_id = create_yoyo(_current_yoyo_type, path_marker)
    
    // Add memory to yoyo
    add_memory_to_yoyo(yoyo_id, memory_id)
    
    return {
        "success": true,
        "yoyo_id": yoyo_id,
        "memory_id": memory_id
    }

func send_yoyo_to_main_system(yoyo_id: String) -> Dictionary {
    if not _main_system:
        return {"success": false, "error": "Main system not available"}
    
    if not _yoyos.has(yoyo_id):
        return {"success": false, "error": "YoYo not found"}
    
    var yoyo = _yoyos[yoyo_id]
    
    // Process each memory
    var processed_memories = []
    
    for memory_id in yoyo.memory_ids:
        // Check if memory exists
        var memory = _memory_system.get_memory(memory_id) if _memory_system else null
        
        if memory:
            // Add to main system
            if _main_system.has_method("add_word"):
                var result = _main_system.add_word(memory.content)
                if result:
                    processed_memories.append(memory_id)
            elif _main_system.has_method("process_memory"):
                var result = _main_system.process_memory(memory)
                if result:
                    processed_memories.append(memory_id)
        
    return {
        "success": processed_memories.size() > 0,
        "processed_memories": processed_memories
    }

# File operations
func save_yoyos() -> bool:
    var dir = Directory.new()
    var save_dir = "user://yoyo_catcher"
    
    // Create directory if it doesn't exist
    if not dir.dir_exists(save_dir):
        dir.make_dir_recursive(save_dir)
    
    // Save as JSON
    var file = File.new()
    var file_path = save_dir.plus_file("yoyos.json")
    var err = file.open(file_path, File.WRITE)
    
    if err != OK:
        push_error("Failed to open yoyos file for writing: " + str(err))
        return false
    
    var yoyos_data = {}
    for yoyo_id in _yoyos:
        yoyos_data[yoyo_id] = _yoyos[yoyo_id].to_dict()
    
    file.store_string(JSON.print(yoyos_data, "  "))
    file.close()
    
    return true

func load_yoyos() -> bool:
    var file = File.new()
    var file_path = "user://yoyo_catcher/yoyos.json"
    
    if not file.file_exists(file_path):
        return false
    
    var err = file.open(file_path, File.READ)
    if err != OK:
        push_error("Failed to open yoyos file for reading: " + str(err))
        return false
    
    var content = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(content)
    if parse_result.error != OK:
        push_error("Failed to parse yoyos JSON: " + str(parse_result.error))
        return false
    
    var yoyos_data = parse_result.result
    _yoyos = {}
    
    for yoyo_id in yoyos_data:
        var yoyo = MemoryYoYo.from_dict(yoyos_data[yoyo_id])
        _yoyos[yoyo_id] = yoyo
        
        if yoyo.is_active:
            _active_yoyo_count += 1
    
    return true

func save_device_registry() -> bool:
    var dir = Directory.new()
    var save_dir = "user://yoyo_catcher"
    
    // Create directory if it doesn't exist
    if not dir.dir_exists(save_dir):
        dir.make_dir_recursive(save_dir)
    
    // Save as JSON
    var file = File.new()
    var file_path = save_dir.plus_file("devices.json")
    var err = file.open(file_path, File.WRITE)
    
    if err != OK:
        push_error("Failed to open devices file for writing: " + str(err))
        return false
    
    var devices_data = {}
    for device_id in _device_registry:
        devices_data[device_id] = _device_registry[device_id].to_dict()
    
    file.store_string(JSON.print(devices_data, "  "))
    file.close()
    
    return true

func load_device_registry() -> bool:
    var file = File.new()
    var file_path = "user://yoyo_catcher/devices.json"
    
    if not file.file_exists(file_path):
        return false
    
    var err = file.open(file_path, File.READ)
    if err != OK:
        push_error("Failed to open devices file for reading: " + str(err))
        return false
    
    var content = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(content)
    if parse_result.error != OK:
        push_error("Failed to parse devices JSON: " + str(parse_result.error))
        return false
    
    var devices_data = parse_result.result
    _device_registry = {}
    
    for device_id in devices_data:
        var device = DeviceConnection.from_dict(devices_data[device_id])
        _device_registry[device_id] = device
        
        if device.is_connected:
            _active_devices.append(device_id)
    
    return true

# Multi-device setup
func setup_multi_device_system() -> Dictionary {
    // Register common devices
    var desktop_id = register_device("Desktop", DEVICE_TYPES.DESKTOP, STORAGE_LOCATIONS.PRIMARY)
    var laptop_id = register_device("Laptop", DEVICE_TYPES.LAPTOP, STORAGE_LOCATIONS.SECONDARY)
    var phone_id = register_device("Phone", DEVICE_TYPES.PHONE, STORAGE_LOCATIONS.TERTIARY)
    var browser_id = register_device("Chrome Browser", DEVICE_TYPES.BROWSER, STORAGE_LOCATIONS.BROWSER)
    var terminal_id = register_device("Terminal", DEVICE_TYPES.TERMINAL, STORAGE_LOCATIONS.PRIMARY)
    
    // Connect devices
    connect_device(desktop_id)
    connect_device(laptop_id)
    connect_device(phone_id)
    connect_device(browser_id)
    connect_device(terminal_id)
    
    // Set up automatic sync
    var sync_timer = Timer.new()
    sync_timer.autostart = true
    sync_timer.wait_time = _sync_frequency
    sync_timer.one_shot = false
    sync_timer.connect("timeout", self, "_on_sync_timer_timeout")
    add_child(sync_timer)
    
    return {
        "devices": [desktop_id, laptop_id, phone_id, browser_id, terminal_id],
        "current_device": get_current_device_id(),
        "sync_frequency": _sync_frequency
    }

func _on_sync_timer_timeout():
    sync_with_all_devices()

# Backup to Eden OS
func backup_to_eden(backup_name: String = "") -> Dictionary {
    if backup_name.empty():
        var datetime = OS.get_datetime()
        backup_name = "eden_backup_%04d%02d%02d_%02d%02d%02d" % [
            datetime.year, datetime.month, datetime.day,
            datetime.hour, datetime.minute, datetime.second
        ]
    
    var result = {
        "success": true,
        "backup_name": backup_name,
        "timestamp": OS.get_unix_time(),
        "yoyos_backed_up": _yoyos.size(),
        "devices_backed_up": _device_registry.size()
    }
    
    // Create backup directory
    var dir = Directory.new()
    var backup_dir = "user://eden_backups/" + backup_name
    
    if not dir.dir_exists(backup_dir):
        dir.make_dir_recursive(backup_dir)
    
    // Backup yoyos
    save_file_to_backup(backup_dir, "yoyos.json", _yoyos_to_json())
    
    // Backup devices
    save_file_to_backup(backup_dir, "devices.json", _devices_to_json())
    
    // Backup catch history
    save_file_to_backup(backup_dir, "catch_history.json", _catch_history_to_json())
    
    // Add backup metadata
    var metadata = {
        "backup_name": backup_name,
        "timestamp": OS.get_unix_time(),
        "device_id": get_current_device_id(),
        "stats": {
            "yoyos": _yoyos.size(),
            "active_yoyos": _active_yoyo_count,
            "devices": _device_registry.size(),
            "active_devices": _active_devices.size(),
            "catch_history": _catch_history.size()
        }
    }
    
    save_file_to_backup(backup_dir, "metadata.json", JSON.print(metadata, "  "))
    
    return result

func save_file_to_backup(backup_dir: String, file_name: String, content: String) -> bool:
    var file = File.new()
    var file_path = backup_dir.plus_file(file_name)
    var err = file.open(file_path, File.WRITE)
    
    if err != OK:
        push_error("Failed to open backup file for writing: " + str(err))
        return false
    
    file.store_string(content)
    file.close()
    
    return true

func _yoyos_to_json() -> String:
    var yoyos_data = {}
    for yoyo_id in _yoyos:
        yoyos_data[yoyo_id] = _yoyos[yoyo_id].to_dict()
    
    return JSON.print(yoyos_data, "  ")

func _devices_to_json() -> String:
    var devices_data = {}
    for device_id in _device_registry:
        devices_data[device_id] = _device_registry[device_id].to_dict()
    
    return JSON.print(devices_data, "  ")

func _catch_history_to_json() -> String:
    var history_data = []
    for event in _catch_history:
        history_data.append(event.to_dict())
    
    return JSON.print(history_data, "  ")

func restore_from_eden(backup_name: String) -> Dictionary:
    var result = {
        "success": false,
        "backup_name": backup_name
    }
    
    var backup_dir = "user://eden_backups/" + backup_name
    
    var dir = Directory.new()
    if not dir.dir_exists(backup_dir):
        result["error"] = "Backup not found"
        return result
    
    // Load metadata first
    var metadata = load_file_from_backup(backup_dir, "metadata.json")
    if metadata.empty():
        result["error"] = "Invalid backup: metadata missing"
        return result
    
    // Parse metadata
    var parse_result = JSON.parse(metadata)
    if parse_result.error != OK:
        result["error"] = "Invalid metadata format"
        return result
    
    var metadata_data = parse_result.result
    result["metadata"] = metadata_data
    
    // Load yoyos
    var yoyos_json = load_file_from_backup(backup_dir, "yoyos.json")
    if not yoyos_json.empty():
        restore_yoyos_from_json(yoyos_json)
        result["yoyos_restored"] = true
    
    // Load devices
    var devices_json = load_file_from_backup(backup_dir, "devices.json")
    if not devices_json.empty():
        restore_devices_from_json(devices_json)
        result["devices_restored"] = true
    
    // Load catch history
    var history_json = load_file_from_backup(backup_dir, "catch_history.json")
    if not history_json.empty():
        restore_catch_history_from_json(history_json)
        result["history_restored"] = true
    
    result["success"] = true
    return result

func load_file_from_backup(backup_dir: String, file_name: String) -> String:
    var file = File.new()
    var file_path = backup_dir.plus_file(file_name)
    
    if not file.file_exists(file_path):
        return ""
    
    var err = file.open(file_path, File.READ)
    if err != OK:
        push_error("Failed to open backup file for reading: " + str(err))
        return ""
    
    var content = file.get_as_text()
    file.close()
    
    return content

func restore_yoyos_from_json(json_str: String) -> bool:
    var parse_result = JSON.parse(json_str)
    if parse_result.error != OK:
        push_error("Failed to parse yoyos JSON: " + str(parse_result.error))
        return false
    
    var yoyos_data = parse_result.result
    _yoyos = {}
    _active_yoyo_count = 0
    
    for yoyo_id in yoyos_data:
        var yoyo = MemoryYoYo.from_dict(yoyos_data[yoyo_id])
        _yoyos[yoyo_id] = yoyo
        
        if yoyo.is_active:
            _active_yoyo_count += 1
    
    save_yoyos()
    
    return true

func restore_devices_from_json(json_str: String) -> bool:
    var parse_result = JSON.parse(json_str)
    if parse_result.error != OK:
        push_error("Failed to parse devices JSON: " + str(parse_result.error))
        return false
    
    var devices_data = parse_result.result
    _device_registry = {}
    _active_devices = []
    
    for device_id in devices_data:
        var device = DeviceConnection.from_dict(devices_data[device_id])
        _device_registry[device_id] = device
        
        if device.is_connected:
            _active_devices.append(device_id)
    
    // Make sure current device is connected
    var current_device_id = get_current_device_id()
    if _device_registry.has(current_device_id):
        _device_registry[current_device_id].connect()
        
        if not _active_devices.has(current_device_id):
            _active_devices.append(current_device_id)
    else:
        register_current_device()
    
    save_device_registry()
    
    return true

func restore_catch_history_from_json(json_str: String) -> bool:
    var parse_result = JSON.parse(json_str)
    if parse_result.error != OK:
        push_error("Failed to parse catch history JSON: " + str(parse_result.error))
        return false
    
    var history_data = parse_result.result
    _catch_history = []
    
    for event_data in history_data:
        var event = CatchEvent.from_dict(event_data)
        _catch_history.append(event)
    
    return true

# Utility functions
func get_yoyo_stats() -> Dictionary:
    var stats = {
        "total_yoyos": _yoyos.size(),
        "active_yoyos": _active_yoyo_count,
        "connected_devices": _active_devices.size(),
        "registered_devices": _device_registry.size(),
        "catch_history": _catch_history.size(),
        "catches_per_minute": _catches_per_minute
    }
    
    // Count by type
    var by_type = {}
    for type_name in YOYO_TYPES:
        by_type[type_name] = 0
    
    for yoyo in _yoyos.values():
        var type_num = yoyo.type
        var type_name = "UNKNOWN"
        
        for name in YOYO_TYPES:
            if YOYO_TYPES[name] == type_num:
                type_name = name
                break
        
        if by_type.has(type_name):
            by_type[type_name] += 1
    
    stats["by_type"] = by_type
    
    return stats

func generate_report() -> String:
    var report = "# MEMORY YO-YO CATCHER REPORT #\n\n"
    
    // Current stats
    var stats = get_yoyo_stats()
    report += "## System Status\n"
    report += "Total YoYos: " + str(stats.total_yoyos) + "\n"
    report += "Active YoYos: " + str(stats.active_yoyos) + "\n"
    report += "Connected Devices: " + str(stats.connected_devices) + " / " + str(stats.registered_devices) + "\n"
    report += "Auto-Catch: " + ("Enabled" if _auto_catch_enabled else "Disabled") + "\n\n"
    
    // Device information
    report += "## Connected Devices\n"
    for device_id in _active_devices:
        var device = _device_registry[device_id]
        report += "- " + device.name + " (" + get_device_type_name(device.type) + ")\n"
        report += "  Storage: " + get_storage_location_name(device.storage_location) + "\n"
        
        if device_id == get_current_device_id():
            report += "  [CURRENT DEVICE]\n"
    
    report += "\n"
    
    // YoYo distribution
    report += "## YoYo Distribution\n"
    for type_name in stats.by_type:
        if stats.by_type[type_name] > 0:
            report += type_name + ": " + str(stats.by_type[type_name]) + "\n"
    
    report += "\n"
    
    // Recent catches
    report += "## Recent Catches\n"
    var recent_catches = min(5, _catch_history.size())
    
    if recent_catches > 0:
        for i in range(_catch_history.size() - recent_catches, _catch_history.size()):
            var event = _catch_history[i]
            var status = event.catch_success ? "SUCCESS" : "FAILED"
            
            report += "- " + status + ": YoYo " + event.yoyo_id.split("_")[1] + "\n"
            report += "  Memories: " + str(event.memory_ids.size()) + "\n"
    else:
        report += "No recent catches\n"
    
    return report

func get_device_type_name(type: int) -> String:
    for name in DEVICE_TYPES:
        if DEVICE_TYPES[name] == type:
            return name
    return "UNKNOWN"

func get_storage_location_name(location: int) -> String:
    for name in STORAGE_LOCATIONS:
        if STORAGE_LOCATIONS[name] == location:
            return name
    return "UNKNOWN"

# Example usage:
# var yoyo_catcher = MemoryYoyoCatcher.new()
# add_child(yoyo_catcher)
# yoyo_catcher.initialize(main_system, memory_system, connection_system, communication_bridge, secure_channel)
#
# # Set up multi-device system
# var devices = yoyo_catcher.setup_multi_device_system()
#
# # Create and throw a yoyo
# var yoyo_id = yoyo_catcher.create_yoyo()
# yoyo_catcher.add_memory_to_yoyo(yoyo_id, "memory_123")
# yoyo_catcher.throw_yoyo(yoyo_id)
#
# # Catch yoyos
# yoyo_catcher.start_auto_catch()
#
# # Create from main.gd
# var result = yoyo_catcher.create_memory_yoyo_from_word("Hello world", "_s")
#
# # Backup to Eden
# var backup_result = yoyo_catcher.backup_to_eden()