# ==================================================
# UNIVERSAL BEING: ZipPackageManager
# TYPE: System
# PURPOSE: Advanced ZIP package management with async loading and caching
# COMPONENTS: None (core system)
# SCENES: None (core system)
# ==================================================

extends UniversalBeing
class_name ZipPackageManager

# ===== CONSTANTS =====
const MAX_CACHE_SIZE: int = 100 * 1024 * 1024  # 100MB cache limit
const MAX_ACTIVE_PACKAGES: int = 50  # Maximum active packages
const FRAME_LOADING_BUDGET_MS: float = 2.0  # 2ms per frame budget

# ===== PACKAGE STATE =====
var active_packages: Dictionary = {}  # package_id -> {data, ref_count, last_access}
var asset_cache: Dictionary = {}  # "package_id/asset.png" -> WeakRef
var loading_queue: Array[Dictionary] = []  # Queue of pending loads
var total_cache_size: int = 0  # Current cache size in bytes

# ===== THREADING =====
var loading_thread: Thread
var thread_mutex: Mutex
var thread_semaphore: Semaphore
var thread_exit: bool = false

# ===== SIGNALS =====
signal package_loaded(package_id: String, success: bool)
signal asset_loaded(package_id: String, asset_path: String, asset: Resource)
signal cache_updated(cache_size: int, max_size: int)
signal loading_progress(package_id: String, progress: float)

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
    super.pentagon_init()
    
    # Set Universal Being identity
    being_type = "system"
    being_name = "ZipPackageManager"
    consciousness_level = 3  # High consciousness for AI accessibility
    
    # Initialize threading system
    thread_mutex = Mutex.new()
    thread_semaphore = Semaphore.new()
    loading_thread = Thread.new()
    loading_thread.start(_loading_thread_function)
    
    print("📦 ZipPackageManager: Pentagon Init Complete")

func pentagon_ready() -> void:
    super.pentagon_ready()
    print("📦 ZipPackageManager: Pentagon Ready Complete")

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    
    # Process loading queue within frame budget
    var start_time = Time.get_ticks_msec()
    while loading_queue.size() > 0 and (Time.get_ticks_msec() - start_time) < FRAME_LOADING_BUDGET_MS:
        var request = loading_queue.pop_front()
        _process_loading_request(request)

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    # No input handling needed

func pentagon_sewers() -> void:
    # Signal thread to exit
    thread_exit = true
    thread_semaphore.post()
    
    # Wait for thread to finish
    if loading_thread.is_started():
        loading_thread.wait_to_finish()
    
    # Clear caches
    active_packages.clear()
    asset_cache.clear()
    loading_queue.clear()
    
    super.pentagon_sewers()
    print("📦 ZipPackageManager: Pentagon Sewers Complete")

# ===== PUBLIC INTERFACE =====

func load_full_package(zip_path: String) -> bool:
    """Load a complete package using ProjectSettings.load_resource_pack()"""
    if not FileAccess.file_exists(zip_path):
        push_error("📦 ZipPackageManager: Package not found: " + zip_path)
        return false
    
    var package_id = zip_path.get_file().get_basename()
    if package_id in active_packages:
        active_packages[package_id].ref_count += 1
        active_packages[package_id].last_access = Time.get_ticks_msec()
        return true
    
    # Load package using Godot's resource pack system
    var success = ProjectSettings.load_resource_pack(zip_path)
    if success:
        active_packages[package_id] = {
            "path": zip_path,
            "ref_count": 1,
            "last_access": Time.get_ticks_msec(),
            "loaded_at": Time.get_ticks_msec()
        }
        package_loaded.emit(package_id, true)
        print("📦 ZipPackageManager: Package loaded successfully: " + package_id)
    else:
        push_error("📦 ZipPackageManager: Failed to load package: " + zip_path)
        package_loaded.emit(package_id, false)
    
    return success

func read_selective_files(zip_path: String, file_list: Array) -> Dictionary:
    """Read specific files from a ZIP package using ZIPReader"""
    var result = {}
    
    if not FileAccess.file_exists(zip_path):
        push_error("📦 ZipPackageManager: Package not found: " + zip_path)
        return result
    
    var reader = ZIPReader.new()
    var err = reader.open(zip_path)
    if err != OK:
        push_error("📦 ZipPackageManager: Failed to open ZIP: " + str(err))
        return result
    
    for file_path in file_list:
        if reader.file_exists(file_path):
            var data = reader.read_file(file_path)
            if data:
                result[file_path] = data
    
    reader.close()
    return result

func request_asset_async(package_path: String, asset_path: String, callback: Callable) -> void:
    """Request an asset to be loaded asynchronously"""
    var request = {
        "package_path": package_path,
        "asset_path": asset_path,
        "callback": callback,
        "timestamp": Time.get_ticks_msec()
    }
    
    # Check cache first
    var cache_key = package_path.get_file().get_basename() + "/" + asset_path
    if asset_cache.has(cache_key):
        var weak_ref = asset_cache[cache_key]
        var asset = weak_ref.get_ref()
        if asset:
            callback.call(asset)
            return
    
    # Add to loading queue
    thread_mutex.lock()
    loading_queue.append(request)
    thread_mutex.unlock()
    thread_semaphore.post()

# ===== PRIVATE IMPLEMENTATION =====

func _loading_thread_function() -> void:
    """Background thread for loading assets"""
    while not thread_exit:
        thread_semaphore.wait()
        
        if thread_exit:
            break
        
        thread_mutex.lock()
        var request = loading_queue.pop_front() if loading_queue.size() > 0 else null
        thread_mutex.unlock()
        
        if request:
            _process_loading_request(request)

func _process_loading_request(request: Dictionary) -> void:
    """Process a single loading request"""
    var package_path = request.package_path
    var asset_path = request.asset_path
    var callback = request.callback
    
    # Load the asset
    var asset = load(asset_path)
    if asset:
        # Cache the asset
        var cache_key = package_path.get_file().get_basename() + "/" + asset_path
        var weak_ref = WeakRef.new()
        weak_ref.set_ref(asset)
        asset_cache[cache_key] = weak_ref
        
        # Update cache size
        _update_cache_size()
        
        # Call callback
        callback.call(asset)
        asset_loaded.emit(package_path, asset_path, asset)
    else:
        push_error("📦 ZipPackageManager: Failed to load asset: " + asset_path)

func _update_cache_size() -> void:
    """Update and manage cache size"""
    var new_size = 0
    var to_remove = []
    
    # Calculate new size and find items to remove
    for key in asset_cache.keys():
        var weak_ref = asset_cache[key]
        var asset = weak_ref.get_ref()
        if asset:
            if asset is Resource:
                new_size += asset.get_rid().get_id()  # Approximate size
        else:
            to_remove.append(key)
    
    # Remove invalid references
    for key in to_remove:
        asset_cache.erase(key)
    
    # Remove oldest items if over limit
    while new_size > MAX_CACHE_SIZE and asset_cache.size() > 0:
        var oldest_key = _find_oldest_cache_item()
        if oldest_key:
            asset_cache.erase(oldest_key)
            new_size = _calculate_cache_size()
    
    total_cache_size = new_size
    cache_updated.emit(total_cache_size, MAX_CACHE_SIZE)

func _find_oldest_cache_item() -> String:
    """Find the oldest item in the cache"""
    var oldest_time = INF
    var oldest_key = ""
    
    for key in asset_cache.keys():
        var weak_ref = asset_cache[key]
        var asset = weak_ref.get_ref()
        if asset and asset is Resource:
            var time = asset.get_meta("last_access", 0)
            if time < oldest_time:
                oldest_time = time
                oldest_key = key
    
    return oldest_key

func _calculate_cache_size() -> int:
    """Calculate current cache size"""
    var size = 0
    for key in asset_cache.keys():
        var weak_ref = asset_cache[key]
        var asset = weak_ref.get_ref()
        if asset and asset is Resource:
            size += asset.get_rid().get_id()  # Approximate size
    return size

# ===== UTILITY FUNCTIONS =====

func get_package_info(package_id: String) -> Dictionary:
    """Get information about a loaded package"""
    if package_id in active_packages:
        return active_packages[package_id].duplicate(true)
    return {}

func get_cache_info() -> Dictionary:
    """Get information about the asset cache"""
    return {
        "total_size": total_cache_size,
        "max_size": MAX_CACHE_SIZE,
        "item_count": asset_cache.size(),
        "active_packages": active_packages.size()
    }

func clear_cache() -> void:
    """Clear the entire asset cache"""
    asset_cache.clear()
    total_cache_size = 0
    cache_updated.emit(0, MAX_CACHE_SIZE)