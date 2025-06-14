extends Node
class_name MultiDeviceController

# Singleton instance
static var _instance = null

# Signals
signal device_connected(device_name, connection_info)
signal device_disconnected(device_name)
signal data_synchronized(sync_type, data_size)
signal reality_synchronized(reality_type)
signal scan_data_received(scan_id, scan_data)

# Device tracking
var connected_devices: Dictionary = {}
var primary_device: String = "laptop"
var device_capabilities: Dictionary = {}
var connection_status: Dictionary = {}

# Synchronization
var sync_mutex = Mutex.new()
var last_sync_timestamp: int = 0
var entity_sync_queue: Array = []
var word_sync_queue: Array = []
var scene_sync_queue: Array = []
var scan_data_queue: Array = []

# Reality state
var shared_reality: String = "physical"
var reality_mutex = Mutex.new()

# Thread management
var sync_thread: Thread
var scan_processing_thread: Thread
var entity_processing_thread: Thread

# References
var thread_pool = null
var vr_manager = null
var entity_manager = null
var word_manifestor = null
var records_system = null

# Network configuration
var server_mode: bool = true
var server_port: int = 45678
var connection_timeout: float = 5.0
var packet_size_limit: int = 10 * 1024 * 1024  # 10MB limit for scan data

# Scan processing settings
var scan_resolution: float = 0.05  # 5cm voxel resolution
var scan_distance_limit: float = 10.0  # 10 meter scan limit
var use_gpu_acceleration: bool = true

# Internal state
var is_running: bool = false
var pending_tasks: Dictionary = {}
var task_mutex = Mutex.new()

# Get singleton instance
static func get_instance():
    if not _instance:
        _instance = MultiDeviceController.new()
    return _instance

func _init():
    # Register this node as singleton
    if not Engine.has_singleton("MultiDeviceController"):
        Engine.register_singleton("MultiDeviceController", self)
    
    # Initialize capability detection
    _detect_capabilities()

func _ready():
    # Find required components
    _find_components()
    
    # Set up initial device (this device)
    _register_current_device()
    
    # Start synchronization system
    _start_sync_system()

# Initialize with thread pool and other core systems
func initialize():
    print("MultiDeviceController: Initializing...")
    
    if not thread_pool:
        thread_pool = get_node("/root/thread_pool_autoload")
    
    if not thread_pool:
        push_error("ThreadPool not found - MultiDeviceController requires ThreadPool")
        return false
    
    # Initialize VR if available
    if Engine.has_singleton("XRServer"):
        _initialize_vr()
    
    # Start background threads
    _start_background_threads()
    
    is_running = true
    return true

# Main processing function
func _process(delta):
    if not is_running:
        return
    
    # Process pending device connections
    _process_connections()
    
    # Process synchronization queues
    _process_sync_queues()
    
    # Check for scan data
    _check_scan_data()

# Handle device registration for current device
func _register_current_device():
    var device_info = {
        "name": "laptop",  # Default, will be updated if VR or mobile
        "capabilities": device_capabilities,
        "connection_type": "local",
        "is_primary": true,
        "last_active": Time.get_ticks_msec()
    }
    
    # Update name based on capabilities
    if device_capabilities.has("vr") and device_capabilities.vr:
        device_info.name = "vr_headset"
    
    connected_devices[device_info.name] = device_info
    primary_device = device_info.name

# Start all background threads
func _start_background_threads():
    # Start synchronization thread
    sync_thread = Thread.new()
    sync_thread.start(_sync_thread_function)
    
    # Start scan processing thread if we have GPU acceleration
    if use_gpu_acceleration and device_capabilities.has("gpu"):
        scan_processing_thread = Thread.new()
        scan_processing_thread.start(_scan_processing_thread_function)
    
    # Start entity processing thread
    entity_processing_thread = Thread.new()
    entity_processing_thread.start(_entity_processing_thread_function)

# Detect device capabilities
func _detect_capabilities():
    device_capabilities = {
        "gpu": OS.has_feature("gpu"),
        "vr": Engine.has_singleton("XRServer"),
        "mobile": OS.has_feature("mobile"),
        "threads": OS.get_processor_count(),
        "memory_mb": OS.get_static_memory_usage() / (1024 * 1024)
    }
    
    print("Device capabilities detected: ", device_capabilities)

# Find required components
func _find_components():
    # Look for thread pool
    if has_node("/root/thread_pool_autoload"):
        thread_pool = get_node("/root/thread_pool_autoload")
    
    # Look for VR manager
    vr_manager = VRManager.get_instance() if ClassDB.class_exists("VRManager") else null
    
    # Look for entity manager, word manifestor, etc
    if has_node("/root/main"):
        var main = get_node("/root/main")
        if main.has_method("get_entity_manager"):
            entity_manager = main.get_entity_manager()
        if main.has_method("get_word_manifestor"):
            word_manifestor = main.get_word_manifestor()
        if main.has_method("get_records_system"):
            records_system = main.get_records_system()

# Initialize VR system
func _initialize_vr():
    if not vr_manager:
        vr_manager = VRManager.get_instance()
    
    if vr_manager:
        var vr_initialized = vr_manager.initialize()
        if vr_initialized:
            print("VR system initialized successfully")
            vr_manager.connect("scale_transition_requested", Callable(self, "_on_vr_scale_transition"))
            device_capabilities.vr_active = true
        else:
            print("VR system failed to initialize")

# Synchronization thread function
func _sync_thread_function():
    print("Sync thread started")
    
    while is_running:
        # Process entity sync queue
        _sync_entities()
        
        # Process word sync queue
        _sync_words()
        
        # Process scene sync queue
        _sync_scenes()
        
        # Throttle thread execution to reduce CPU usage
        OS.delay_msec(50)  # 20Hz sync rate

# Scan processing thread function
func _scan_processing_thread_function():
    print("Scan processing thread started")
    
    while is_running:
        # Process any pending scan data
        _process_scan_data()
        
        # Throttle thread execution
        OS.delay_msec(100)  # 10Hz processing rate

# Entity processing thread function
func _entity_processing_thread_function():
    print("Entity processing thread started")
    
    while is_running:
        # Process entity transitions and interactions
        _process_entities()
        
        # Throttle thread execution
        OS.delay_msec(20)  # 50Hz processing rate

# Process pending connections from other devices
func _process_connections():
    # This would handle any TCP or UDP connections from other devices
    pass

# Process synchronization queues
func _process_sync_queues():
    # Check if enough time has passed since last sync
    var current_time = Time.get_ticks_msec()
    if current_time - last_sync_timestamp < 100:  # 10Hz max sync rate
        return
    
    # Update timestamp
    last_sync_timestamp = current_time
    
    # Queue sync jobs to thread pool if available
    if thread_pool:
        if not entity_sync_queue.is_empty():
            thread_pool.submit_task(self, "_sync_entities", entity_sync_queue.duplicate(), "entity_sync")
            entity_sync_queue.clear()
        
        if not word_sync_queue.is_empty():
            thread_pool.submit_task(self, "_sync_words", word_sync_queue.duplicate(), "word_sync")
            word_sync_queue.clear()
        
        if not scene_sync_queue.is_empty():
            thread_pool.submit_task(self, "_sync_scenes", scene_sync_queue.duplicate(), "scene_sync")
            scene_sync_queue.clear()

# Check for any scan data received from iPhone LiDAR
func _check_scan_data():
    if scan_data_queue.is_empty():
        return
    
    # Process the next scan in the queue
    var scan_data = scan_data_queue.pop_front()
    
    # Submit to thread pool for processing
    if thread_pool:
        thread_pool.submit_task(self, "_process_scan", scan_data, "scan_processing")
    else:
        # Fallback to direct processing if no thread pool
        _process_scan(scan_data)

# Process a 3D scan from iPhone LiDAR
func _process_scan(scan_data):
    print("Processing scan data: ", scan_data.scan_id)
    
    # Convert point cloud to mesh or 3D structure
    var processed_data = _convert_scan_to_mesh(scan_data)
    
    # Generate entities from recognized objects if needed
    if scan_data.has("recognized_objects"):
        _generate_entities_from_scan(scan_data.recognized_objects)
    
    # Add to world
    _add_scan_to_world(processed_data)
    
    # Notify completion
    emit_signal("scan_data_processed", scan_data.scan_id, processed_data)

# Connect to iPhone LiDAR
func connect_to_iphone(ip_address: String, port: int = 45679) -> bool:
    print("Attempting to connect to iPhone at ", ip_address, ":", port)
    
    # This would establish a WebSocket or TCP connection to an app running on iPhone
    # For demonstration, we'll simulate success
    var connection_info = {
        "ip": ip_address,
        "port": port,
        "connected": true,
        "last_active": Time.get_ticks_msec()
    }
    
    connected_devices["iphone"] = {
        "name": "iphone",
        "capabilities": {"lidar": true, "arkit": true},
        "connection_type": "network",
        "connection_info": connection_info,
        "is_primary": false,
        "last_active": Time.get_ticks_msec()
    }
    
    emit_signal("device_connected", "iphone", connection_info)
    return true

# Connect VR headset (if not already connected as primary device)
func connect_to_vr() -> bool:
    if device_capabilities.has("vr") and device_capabilities.vr:
        # VR is available on this device, initialize it
        return _initialize_vr()
    else:
        # Would need to connect to external VR device
        print("External VR connection not implemented yet")
        return false

# Receive scan data from iPhone
func receive_scan_data(scan_data: Dictionary) -> bool:
    print("Received scan data: ", scan_data.scan_id)
    
    # Add to processing queue
    scan_data_queue.append(scan_data)
    
    # Notify receipt
    emit_signal("scan_data_received", scan_data.scan_id, scan_data.size)
    
    return true

# Synchronize entities across devices
func _sync_entities(entities = null):
    if not entities:
        return
    
    sync_mutex.lock()
    # This would send entity data to connected devices
    # For now, we'll just log it
    print("Syncing entities: ", entities.size())
    sync_mutex.unlock()

# Synchronize words across devices
func _sync_words(words = null):
    if not words:
        return
    
    sync_mutex.lock()
    # This would send word manifestation data to connected devices
    print("Syncing words: ", words.size())
    sync_mutex.unlock()

# Synchronize scene state across devices
func _sync_scenes(scenes = null):
    if not scenes:
        return
    
    sync_mutex.lock()
    # This would send scene state to connected devices
    print("Syncing scenes: ", scenes.size())
    sync_mutex.unlock()

# Process entities for interactions and transitions
func _process_entities():
    # This would handle entity lifecycle and interactions
    # across multiple devices
    pass

# Create entities from recognized objects in scan
func _generate_entities_from_scan(recognized_objects: Array):
    if not word_manifestor:
        return
    
    for obj in recognized_objects:
        if obj.has("name") and obj.has("position") and obj.has("confidence"):
            # Only create if confidence is high enough
            if obj.confidence >= 0.7:
                var pos = Vector3(obj.position.x, obj.position.y, obj.position.z)
                
                # Use word manifestor to create entity
                var entity_id = word_manifestor.manifest_word(obj.name, {"position": pos})
                
                print("Created entity from scan: ", obj.name, " at ", pos)

# Start the sync system
func _start_sync_system():
    print("Starting sync system")
    # Initialize sync queues
    entity_sync_queue = []
    word_sync_queue = []
    scene_sync_queue = []
    scan_data_queue = []

# Handle VR scale transitions
func _on_vr_scale_transition(from_scale, to_scale):
    print("VR scale transition: ", from_scale, " to ", to_scale)
    
    # Synchronize scale change to other devices
    var scale_data = {
        "from_scale": from_scale,
        "to_scale": to_scale,
        "timestamp": Time.get_ticks_msec()
    }
    
    # Add to scene sync queue
    scene_sync_queue.append({"type": "scale_change", "data": scale_data})

# Convert scan point cloud to mesh
func _convert_scan_to_mesh(scan_data: Dictionary):
    # This would convert the point cloud or depth data to a mesh
    # For now, we'll just return placeholder data
    return {
        "scan_id": scan_data.scan_id,
        "mesh": null,  # Would be a mesh resource
        "position": Vector3(0, 0, 0),
        "scale": Vector3(1, 1, 1)
    }

# Add processed scan to world
func _add_scan_to_world(processed_data: Dictionary):
    # This would add the processed scan mesh to the world
    # at the correct position/orientation
    print("Adding scan to world: ", processed_data.scan_id)
    
    # In the real implementation, this would create actual mesh instances

# Queue an entity for sync to other devices
func queue_entity_sync(entity_id: String) -> bool:
    if entity_manager and entity_manager.has_method("get_entity"):
        var entity = entity_manager.get_entity(entity_id)
        if entity:
            entity_sync_queue.append({
                "id": entity_id,
                "data": entity,
                "timestamp": Time.get_ticks_msec()
            })
            return true
    return false

# Queue a word for sync to other devices
func queue_word_sync(word: String, properties: Dictionary) -> bool:
    word_sync_queue.append({
        "word": word,
        "properties": properties,
        "timestamp": Time.get_ticks_msec()
    })
    return true

# Queue a scene change for sync to other devices
func queue_scene_sync(change_type: String, change_data: Dictionary) -> bool:
    scene_sync_queue.append({
        "type": change_type,
        "data": change_data,
        "timestamp": Time.get_ticks_msec()
    })
    return true

# Manifest a word across all devices
func manifest_word_everywhere(word: String, position: Vector3, options: Dictionary = {}) -> String:
    # First manifest locally
    var entity_id = ""
    if word_manifestor and word_manifestor.has_method("manifest_word"):
        var local_options = options.duplicate()
        local_options["position"] = position
        entity_id = word_manifestor.manifest_word(word, local_options)
    
    # Then queue for sync to other devices
    if not entity_id.is_empty():
        queue_entity_sync(entity_id)
    
    return entity_id

# Change reality type across all devices
func change_reality(reality_type: String) -> bool:
    if not reality_type in ["physical", "digital", "astral"]:
        return false
    
    reality_mutex.lock()
    shared_reality = reality_type
    reality_mutex.unlock()
    
    # Queue reality change for sync
    queue_scene_sync("reality_change", {
        "reality": reality_type,
        "timestamp": Time.get_ticks_msec()
    })
    
    emit_signal("reality_synchronized", reality_type)
    return true

# Get current connection status
func get_connection_status() -> Dictionary:
    var status = {
        "devices": connected_devices.size(),
        "primary": primary_device,
        "vr_active": false,
        "iphone_connected": false,
        "last_sync": last_sync_timestamp
    }
    
    # Check VR status
    if vr_manager:
        status.vr_active = vr_manager.is_vr_active
    
    # Check iPhone connection
    if connected_devices.has("iphone"):
        status.iphone_connected = true
    
    return status