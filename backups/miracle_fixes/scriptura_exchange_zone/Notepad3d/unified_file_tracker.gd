extends Node

class_name UnifiedFileTracker

# ----- CONFIGURATION -----
@export var auto_initialize: bool = true
@export var scan_interval: float = 300.0  # 5 minutes
@export var log_changes: bool = true
@export var memory_file_path: String = "user://unified_tracker_memory.dat"
@export var max_memory_size_mb: float = 10.0  # MB

# ----- DRIVE PATHS -----
@export var drive_paths: Array[String] = [
    "C:/",                               # Windows C drive
    "D:/",                               # Windows D drive
    "/mnt/c/Users/Percision 15",         # WSL path to Windows user directory
    "/home/",                            # Linux home directory
    "res://",                            # Project directory
    "user://",                           # User data directory
]

# ----- PATH MONITORING -----
@export var monitored_extensions: Array[String] = [
    "gd",           # GDScript
    "py",           # Python
    "js",           # JavaScript
    "html",         # HTML
    "css",          # CSS
    "json",         # JSON
    "txt",          # Text
    "md",           # Markdown
    "csv",          # CSV
    "tscn",         # Godot scene
    "tres",         # Godot resource
    "shader",       # Shader
    "gdshader"      # Godot shader
]

# ----- IGNORE PATTERNS -----
@export var ignore_patterns: Array[String] = [
    ".git",
    "node_modules",
    "__pycache__",
    ".import",
    ".mono",
    "Temp",
    "build",
    "dist",
    "*.tmp",
    "*.bak"
]

# ----- TRACKING CATEGORIES -----
enum TrackingCategory {
    CODE,           # Code files
    DATA,           # Data files
    RESOURCE,       # Resource files
    SYSTEM,         # System files
    DOCUMENT        # Documentation files
}

# ----- COMPONENT CONNECTIONS -----
@export_node_path var akashic_system_path: NodePath
@export_node_path var memory_system_path: NodePath
@export_node_path var terminal_system_path: NodePath

# ----- STATE VARIABLES -----
var akashic_system = null
var memory_system = null
var terminal_system = null

var tracked_files = {}
var file_changes = []
var last_scan_time = 0
var scan_in_progress = false
var current_scan_drive_index = 0
var current_scan_subpath = ""
var scan_queue = []

# ----- PLATFORM DETECTION -----
var os_name = OS.get_name()
var is_windows = os_name == "Windows"
var is_linux = os_name == "Linux"
var is_wsl = false # Will detect in _ready

# ----- SIGNALS -----
signal scan_completed(stats)
signal file_changed(file_path, change_type, details)
signal memory_stored(count, size_kb)
signal category_scan_completed(category, file_count)
signal drive_scan_completed(drive_path, file_count)

# ----- INITIALIZATION -----
func _ready():
    if auto_initialize:
        initialize()

func initialize():
    print("UnifiedFileTracker: Initializing...")
    
    # Detect if running in WSL
    if is_linux:
        var file = FileAccess.open("/proc/version", FileAccess.READ)
        if file:
            var content = file.get_as_text()
            is_wsl = content.to_lower().contains("microsoft")
    
    # Find references to connected systems
    _connect_systems()
    
    # Load previous tracking data
    _load_memory()
    
    # Start scan queue
    _build_scan_queue()
    
    print("UnifiedFileTracker: Initialized")
    print("- Detected OS: ", os_name)
    print("- WSL Detected: ", is_wsl)
    print("- Drive Paths: ", drive_paths.size())
    print("- Monitored Extensions: ", monitored_extensions.size())
    print("- Tracked Files: ", tracked_files.size())

# ----- SYSTEM CONNECTIONS -----
func _connect_systems():
    # Connect to Akashic system if path provided
    if akashic_system_path:
        akashic_system = get_node_or_null(akashic_system_path)
    
    if not akashic_system:
        # Try to find by class name or in specific paths
        akashic_system = get_node_or_null("/root/AkashicSystem")
        if not akashic_system:
            var potential_nodes = get_tree().get_nodes_in_group("akashic_system")
            if potential_nodes.size() > 0:
                akashic_system = potential_nodes[0]
    
    # Connect to Memory system if path provided
    if memory_system_path:
        memory_system = get_node_or_null(memory_system_path)
    
    if not memory_system:
        # Try to find by class name or in specific paths
        memory_system = get_node_or_null("/root/MemorySystem")
        if not memory_system:
            var potential_nodes = get_tree().get_nodes_in_group("memory_system")
            if potential_nodes.size() > 0:
                memory_system = potential_nodes[0]
    
    # Connect to Terminal system if path provided
    if terminal_system_path:
        terminal_system = get_node_or_null(terminal_system_path)
    
    if not terminal_system:
        # Try to find by class name or in specific paths
        terminal_system = get_node_or_null("/root/TerminalSystem")
        if not terminal_system:
            var potential_nodes = get_tree().get_nodes_in_group("terminal_system")
            if potential_nodes.size() > 0:
                terminal_system = potential_nodes[0]
    
    print("UnifiedFileTracker: System connections:")
    print("- Akashic System: ", "Connected" if akashic_system else "Not found")
    print("- Memory System: ", "Connected" if memory_system else "Not found")
    print("- Terminal System: ", "Connected" if terminal_system else "Not found")

# ----- MEMORY MANAGEMENT -----
func _load_memory():
    if FileAccess.file_exists(memory_file_path):
        var file = FileAccess.open(memory_file_path, FileAccess.READ)
        if file:
            var content = file.get_as_text()
            var data = JSON.parse_string(content)
            
            if data and data.has("tracked_files"):
                tracked_files = data.tracked_files
                print("UnifiedFileTracker: Loaded memory with ", tracked_files.size(), " tracked files")
                
                # Convert string keys back to proper types if needed
                var converted_tracked_files = {}
                for key in tracked_files:
                    converted_tracked_files[key] = tracked_files[key]
                
                tracked_files = converted_tracked_files
            
            if data and data.has("last_scan_time"):
                last_scan_time = data.last_scan_time
            
            return true
    
    # No previous data or error loading
    tracked_files = {}
    last_scan_time = 0
    return false

func _save_memory():
    var file = FileAccess.open(memory_file_path, FileAccess.WRITE)
    if file:
        var data = {
            "tracked_files": tracked_files,
            "last_scan_time": last_scan_time,
            "version": "1.0",
            "timestamp": Time.get_unix_time_from_system()
        }
        
        file.store_string(JSON.stringify(data))
        
        # Get file size
        var size_kb = file.get_length() / 1024.0
        emit_signal("memory_stored", tracked_files.size(), size_kb)
        
        print("UnifiedFileTracker: Saved memory with ", tracked_files.size(), " tracked files (", size_kb, " KB)")
        return true
    
    print("UnifiedFileTracker: Failed to save memory")
    return false

# ----- SCANNING LOGIC -----
func _build_scan_queue():
    scan_queue = []
    
    # Add each drive path to the queue
    for drive_path in drive_paths:
        # Skip drive paths that don't exist
        if not _check_path_exists(drive_path):
            print("UnifiedFileTracker: Path does not exist, skipping: ", drive_path)
            continue
        
        scan_queue.append(drive_path)
    
    print("UnifiedFileTracker: Built scan queue with ", scan_queue.size(), " paths")

func _check_path_exists(path: String) -> bool:
    # Handle special paths
    if path == "res://" or path == "user://":
        return true
    
    # Check if directory exists
    var dir = DirAccess.open(path)
    return dir != null

func start_scan():
    if scan_in_progress:
        print("UnifiedFileTracker: Scan already in progress")
        return false
    
    # Initialize scan variables
    scan_in_progress = true
    current_scan_drive_index = 0
    current_scan_subpath = ""
    file_changes = []
    
    # Reset the scan queue
    _build_scan_queue()
    
    print("UnifiedFileTracker: Starting file scan")
    return true

func _process(delta):
    # Check if it's time for a periodic scan
    if not scan_in_progress and last_scan_time + scan_interval < Time.get_unix_time_from_system():
        start_scan()
    
    # Process current scan if in progress
    if scan_in_progress:
        _process_scan_step()

func _process_scan_step():
    # Check if we need to move to the next drive
    if current_scan_subpath.is_empty() and current_scan_drive_index < scan_queue.size():
        # Start scanning a new drive
        var drive_path = scan_queue[current_scan_drive_index]
        print("UnifiedFileTracker: Scanning drive ", drive_path)
        
        # Set up for scanning this drive
        current_scan_subpath = drive_path
    
    # Process the current path
    if not current_scan_subpath.is_empty():
        var completed = _scan_directory(current_scan_subpath)
        
        if completed:
            # Move to the next drive
            emit_signal("drive_scan_completed", scan_queue[current_scan_drive_index], 0) # TODO: Count files
            current_scan_drive_index += 1
            current_scan_subpath = ""
    else:
        # All drives scanned
        _finish_scan()

func _scan_directory(path: String) -> bool:
    var dir = DirAccess.open(path)
    if not dir:
        print("UnifiedFileTracker: Failed to open directory: ", path)
        return true # Skip this directory
    
    # Check all files in the directory
    dir.list_dir_begin()
    var file_name = dir.get_next()
    
    while file_name != "":
        if file_name == "." or file_name == "..":
            file_name = dir.get_next()
            continue
        
        var full_path = path.path_join(file_name)
        
        # Check if this is in the ignore patterns
        var should_ignore = false
        for pattern in ignore_patterns:
            if pattern.begins_with("*"):
                # Wildcard at the start
                var suffix = pattern.substr(1)
                if file_name.ends_with(suffix):
                    should_ignore = true
                    break
            elif pattern.ends_with("*"):
                # Wildcard at the end
                var prefix = pattern.substr(0, pattern.length() - 1)
                if file_name.begins_with(prefix):
                    should_ignore = true
                    break
            else:
                # Exact match
                if file_name == pattern:
                    should_ignore = true
                    break
        
        if should_ignore:
            file_name = dir.get_next()
            continue
        
        if dir.current_is_dir():
            # Add subdirectory to the scan queue
            scan_queue.append(full_path)
        else:
            # Check if this is a file we want to track
            var extension = file_name.get_extension().to_lower()
            if monitored_extensions.has(extension):
                _track_file(full_path)
        
        file_name = dir.get_next()
    
    dir.list_dir_end()
    return true

func _track_file(file_path: String):
    var file = FileAccess.open(file_path, FileAccess.READ)
    if not file:
        return
    
    # Get file metadata
    var size = file.get_length()
    var modified_time = FileAccess.get_modified_time(file_path)
    
    # Determine category based on extension
    var extension = file_path.get_extension().to_lower()
    var category = _get_file_category(extension)
    
    # Check if file is already tracked
    if tracked_files.has(file_path):
        var existing = tracked_files[file_path]
        
        # Check for changes
        if existing.modified_time != modified_time or existing.size != size:
            # File has changed
            var change_data = {
                "path": file_path,
                "previous_size": existing.size,
                "new_size": size,
                "previous_time": existing.modified_time,
                "new_time": modified_time,
                "change_type": "modified"
            }
            
            file_changes.append(change_data)
            emit_signal("file_changed", file_path, "modified", change_data)
            
            if log_changes:
                print("UnifiedFileTracker: File modified: ", file_path)
            
            # Update tracking info
            tracked_files[file_path] = {
                "size": size,
                "modified_time": modified_time,
                "category": category,
                "extension": extension,
                "last_checked": Time.get_unix_time_from_system()
            }
        else:
            # File unchanged, just update last checked time
            tracked_files[file_path].last_checked = Time.get_unix_time_from_system()
    else:
        # New file
        tracked_files[file_path] = {
            "size": size,
            "modified_time": modified_time,
            "category": category,
            "extension": extension,
            "last_checked": Time.get_unix_time_from_system(),
            "first_seen": Time.get_unix_time_from_system()
        }
        
        var change_data = {
            "path": file_path,
            "size": size,
            "modified_time": modified_time,
            "change_type": "new"
        }
        
        file_changes.append(change_data)
        emit_signal("file_changed", file_path, "new", change_data)
        
        if log_changes:
            print("UnifiedFileTracker: New file found: ", file_path)

func _finish_scan():
    # Scan is complete
    scan_in_progress = false
    last_scan_time = Time.get_unix_time_from_system()
    
    # Check for deleted files
    var deleted_files = []
    for file_path in tracked_files:
        if tracked_files[file_path].last_checked < last_scan_time:
            # This file was not found during the scan
            deleted_files.append(file_path)
    
    # Remove deleted files from tracking
    for file_path in deleted_files:
        var change_data = {
            "path": file_path,
            "previous_size": tracked_files[file_path].size,
            "previous_time": tracked_files[file_path].modified_time,
            "change_type": "deleted"
        }
        
        file_changes.append(change_data)
        emit_signal("file_changed", file_path, "deleted", change_data)
        
        if log_changes:
            print("UnifiedFileTracker: File deleted: ", file_path)
        
        tracked_files.erase(file_path)
    
    # Save updated tracking data
    _save_memory()
    
    # Create scan stats
    var stats = {
        "total_files": tracked_files.size(),
        "new_files": file_changes.filter(func(c): return c.change_type == "new").size(),
        "modified_files": file_changes.filter(func(c): return c.change_type == "modified").size(),
        "deleted_files": deleted_files.size(),
        "categories": _count_files_by_category(),
        "extensions": _count_files_by_extension(),
        "timestamp": last_scan_time
    }
    
    # Emit completed signal
    emit_signal("scan_completed", stats)
    
    # Register with Akashic system if available
    if akashic_system and akashic_system.has_method("register_file_scan"):
        akashic_system.register_file_scan(stats)
    
    # Log summary
    print("UnifiedFileTracker: Scan completed")
    print("- Total tracked files: ", stats.total_files)
    print("- New files: ", stats.new_files)
    print("- Modified files: ", stats.modified_files)
    print("- Deleted files: ", stats.deleted_files)

func _get_file_category(extension: String) -> String:
    match extension:
        "gd", "py", "js", "cs", "java", "cpp", "c", "h", "shader", "gdshader":
            return "CODE"
        "json", "txt", "csv", "xml", "ini", "cfg", "dat", "bin":
            return "DATA"
        "tscn", "tres", "png", "jpg", "jpeg", "svg", "obj", "mtl", "wav", "mp3", "ogg":
            return "RESOURCE"
        "md", "pdf", "doc", "docx", "html", "htm", "css":
            return "DOCUMENT"
        _:
            return "SYSTEM"

func _count_files_by_category() -> Dictionary:
    var result = {
        "CODE": 0,
        "DATA": 0,
        "RESOURCE": 0,
        "SYSTEM": 0,
        "DOCUMENT": 0
    }
    
    for file_path in tracked_files:
        var category = tracked_files[file_path].category
        result[category] += 1
    
    return result

func _count_files_by_extension() -> Dictionary:
    var result = {}
    
    for file_path in tracked_files:
        var extension = tracked_files[file_path].extension
        if not result.has(extension):
            result[extension] = 0
        result[extension] += 1
    
    return result

# ----- PUBLIC API -----
func get_tracked_files() -> Dictionary:
    return tracked_files

func get_files_by_category(category: String) -> Array:
    var result = []
    
    for file_path in tracked_files:
        if tracked_files[file_path].category == category:
            result.append(file_path)
    
    return result

func get_files_by_extension(extension: String) -> Array:
    var result = []
    
    for file_path in tracked_files:
        if tracked_files[file_path].extension == extension:
            result.append(file_path)
    
    return result

func get_recent_changes(limit: int = 10) -> Array:
    # Return the most recent file changes, up to limit
    return file_changes.slice(0, min(limit, file_changes.size()))

func force_scan():
    return start_scan()

func get_scan_status() -> Dictionary:
    return {
        "in_progress": scan_in_progress,
        "last_scan_time": last_scan_time,
        "current_drive_index": current_scan_drive_index,
        "current_path": current_scan_subpath,
        "queue_size": scan_queue.size()
    }

func add_drive_path(path: String) -> bool:
    if not drive_paths.has(path):
        drive_paths.append(path)
        return true
    return false

func add_extension(extension: String) -> bool:
    if not monitored_extensions.has(extension):
        monitored_extensions.append(extension)
        return true
    return false

func get_file_info(file_path: String) -> Dictionary:
    if tracked_files.has(file_path):
        return tracked_files[file_path]
    return {}

func check_file_exists(file_path: String) -> bool:
    return FileAccess.file_exists(file_path)

func clean_memory():
    # Remove old entries to keep memory size manageable
    var file = FileAccess.open(memory_file_path, FileAccess.READ)
    if not file:
        return false
    
    var size_mb = file.get_length() / (1024.0 * 1024.0)
    file.close()
    
    if size_mb < max_memory_size_mb:
        return true # Memory size is under limit
    
    # Memory is too large, remove older entries
    print("UnifiedFileTracker: Memory size ", size_mb, " MB exceeds limit, cleaning up")
    
    # Sort files by last checked time
    var files_array = []
    for file_path in tracked_files:
        files_array.append({
            "path": file_path,
            "data": tracked_files[file_path]
        })
    
    files_array.sort_custom(func(a, b): return a.data.last_checked < b.data.last_checked)
    
    # Remove oldest entries until under 80% of limit
    var target_size = max_memory_size_mb * 0.8
    var remove_count = ceil(files_array.size() * (1.0 - target_size / size_mb))
    
    for i in range(min(remove_count, files_array.size())):
        tracked_files.erase(files_array[i].path)
    
    _save_memory()
    
    print("UnifiedFileTracker: Removed ", remove_count, " old entries from memory")
    return true