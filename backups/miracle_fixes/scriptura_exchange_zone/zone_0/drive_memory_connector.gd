extends Node

# Drive Memory Connector
# Connects the memory investment system to local and external drives
# Enables cross-system memory persistence and synchronization

signal drive_connected(drive_name)
signal memory_fragment_found(fragment_data)
signal sync_complete(stats)

# Drive connection types
enum DriveType {
    LOCAL,
    NETWORK,
    CLOUD,
    VIRTUAL,
    ETHEREAL
}

# Connection state
var connected_drives = {}
var active_memory_paths = []
var memory_fragments = []
var sync_in_progress = false

# Constants
const FRAGMENT_EXTENSION = ".mem.json"
const DRIVE_CONFIG_PATH = "res://12_turns_system/drive_config.json"
const DEFAULT_PATHS = [
    "/mnt/c/Users/Percision 15/12_turns_system/",
    "/mnt/c/Users/Percision 15/world_of_words/",
    "/mnt/c/Users/Percision 15/notepad3d/",
    "/mnt/c/Users/Percision 15/Eden_OS/",
    "/mnt/c/Users/Percision 15/LuminusOS/"
]

# File system access
var file = FileAccess
var dir = DirAccess

# Configuration
var config = {
    "auto_sync": true,
    "sync_interval": 300,  # seconds
    "fragment_threshold": 5,
    "ethereal_enabled": true,
    "directional_scanning": true
}

func _ready():
    # Load configuration
    _load_config()
    
    # Setup timer for auto-sync
    var timer = Timer.new()
    timer.wait_time = config.sync_interval
    timer.autostart = true
    timer.timeout.connect(_auto_sync)
    add_child(timer)
    
    # Connect to default drives
    for path in DEFAULT_PATHS:
        connect_drive(path, DriveType.LOCAL)
    
    # Initial scan
    scan_for_memory_fragments()

func _load_config():
    if file.file_exists(DRIVE_CONFIG_PATH):
        var config_file = file.open(DRIVE_CONFIG_PATH, file.READ)
        var json = JSON.parse_string(config_file.get_as_text())
        if json:
            # Update config with loaded values
            for key in json:
                if config.has(key):
                    config[key] = json[key]

func _save_config():
    var config_file = file.open(DRIVE_CONFIG_PATH, file.WRITE)
    config_file.store_string(JSON.stringify(config, "  "))

func connect_drive(path, type = DriveType.LOCAL):
    # Skip if already connected
    if connected_drives.has(path):
        return false
    
    # Validate path exists
    if not dir.dir_exists(path):
        if type == DriveType.ETHEREAL:
            # Ethereal drives don't need to physically exist
            pass
        else:
            print("Drive path does not exist: ", path)
            return false
    
    # Register drive
    connected_drives[path] = {
        "type": type,
        "connected_at": Time.get_unix_time_from_system(),
        "fragments_found": 0,
        "last_sync": 0
    }
    
    # Add to active paths
    active_memory_paths.append(path)
    
    # Emit signal
    emit_signal("drive_connected", path)
    
    return true

func disconnect_drive(path):
    if connected_drives.has(path):
        active_memory_paths.erase(path)
        connected_drives.erase(path)
        return true
    return false

func scan_for_memory_fragments():
    memory_fragments.clear()
    var fragments_found = 0
    
    for path in active_memory_paths:
        var drive_type = connected_drives[path].type
        
        if drive_type == DriveType.ETHEREAL:
            # Ethereal drives use a different scanning method
            var ethereal_fragments = _scan_ethereal_drive(path)
            memory_fragments.append_array(ethereal_fragments)
            fragments_found += ethereal_fragments.size()
        else:
            # Physical drive scanning
            fragments_found += _scan_physical_drive(path)
    
    print("Memory scan complete. Found ", fragments_found, " fragments.")
    return fragments_found

func _scan_physical_drive(path):
    var fragments_found = 0
    var d = dir.open(path)
    
    if d:
        d.list_dir_begin()
        var file_name = d.get_next()
        
        while file_name != "":
            if not d.current_is_dir():
                # Check if it's a memory fragment
                if file_name.ends_with(FRAGMENT_EXTENSION):
                    var full_path = path.path_join(file_name)
                    var fragment = _load_fragment(full_path)
                    
                    if fragment:
                        memory_fragments.append(fragment)
                        fragments_found += 1
                        emit_signal("memory_fragment_found", fragment)
            else:
                # Recursively scan subdirectories if not . or ..
                if file_name != "." and file_name != ".." and config.directional_scanning:
                    var subdir_path = path.path_join(file_name)
                    fragments_found += _scan_physical_drive(subdir_path)
            
            file_name = d.get_next()
    
    # Update drive stats
    if connected_drives.has(path):
        connected_drives[path].fragments_found = fragments_found
        connected_drives[path].last_sync = Time.get_unix_time_from_system()
    
    return fragments_found

func _scan_ethereal_drive(path):
    # Ethereal drives don't physically exist
    # They're procedurally generated based on memory investment patterns
    var ethereal_fragments = []
    
    # Generate ethereal fragments based on existing memory patterns
    for i in range(memory_fragments.size()):
        var source_fragment = memory_fragments[i]
        
        # Only create ethereal variations if we have enough physical fragments
        if i % config.fragment_threshold == 0 and i > 0:
            var ethereal_fragment = _generate_ethereal_fragment(source_fragment)
            ethereal_fragments.append(ethereal_fragment)
    
    return ethereal_fragments

func _generate_ethereal_fragment(source):
    # Create an ethereal variation of a physical fragment
    var ethereal = source.duplicate(true)
    
    # Modify with ethereal properties
    ethereal.is_ethereal = true
    ethereal.origin_path = source.path
    ethereal.path = "ethereal://" + str(randi() % 1000000) + "/" + source.name
    
    # Add dimensional shift
    if ethereal.has("dimensions"):
        for d in ethereal.dimensions:
            # Shift dimension value slightly
            ethereal.dimensions[d] += randf_range(-0.1, 0.2)
    
    # Add blue tint to color if present
    if ethereal.has("color"):
        var color = Color(ethereal.color)
        color = color.lerp(Color(0.5, 0.7, 0.9), 0.3)
        ethereal.color = color.to_html()
    
    return ethereal

func _load_fragment(path):
    if not file.file_exists(path):
        return null
    
    var fragment_file = file.open(path, file.READ)
    var json = JSON.parse_string(fragment_file.get_as_text())
    
    if json:
        # Add metadata
        json.path = path
        json.name = path.get_file().trim_suffix(FRAGMENT_EXTENSION)
        json.is_ethereal = false
        
        return json
    
    return null

func save_memory_fragment(fragment_data, target_path = ""):
    if target_path.is_empty():
        # Use the first connected drive by default
        if active_memory_paths.size() > 0:
            target_path = active_memory_paths[0]
        else:
            print("No connected drives to save fragment")
            return false
    
    # Ensure path ends with separator
    if not target_path.ends_with("/"):
        target_path += "/"
    
    # Generate a name if none provided
    if not fragment_data.has("name") or fragment_data.name.is_empty():
        fragment_data.name = "memory_" + str(randi() % 1000000)
    
    # Create the file path
    var file_path = target_path + fragment_data.name + FRAGMENT_EXTENSION
    
    # Save to file
    var fragment_file = file.open(file_path, file.WRITE)
    if fragment_file:
        # Remove path info before saving (to avoid circular references)
        var save_data = fragment_data.duplicate(true)
        if save_data.has("path"):
            save_data.erase("path")
        
        fragment_file.store_string(JSON.stringify(save_data, "  "))
        return true
    
    return false

func get_memory_fragment(name_or_path):
    # Try to find by path
    for fragment in memory_fragments:
        if fragment.path == name_or_path:
            return fragment
    
    # Try to find by name
    for fragment in memory_fragments:
        if fragment.name == name_or_path:
            return fragment
    
    return null

func _auto_sync():
    if config.auto_sync and not sync_in_progress:
        sync_memory_fragments()

func sync_memory_fragments():
    if sync_in_progress:
        return false
    
    sync_in_progress = true
    
    # Scan all drives
    var found = scan_for_memory_fragments()
    
    # Cross-reference fragments and sync unique ones to all drives
    var unique_fragments = _identify_unique_fragments()
    var sync_stats = {
        "found": found,
        "unique": unique_fragments.size(),
        "synced": 0
    }
    
    # Sync to all drives
    for fragment in unique_fragments:
        # Skip ethereal fragments, they don't get saved to disk
        if fragment.has("is_ethereal") and fragment.is_ethereal:
            continue
        
        for path in active_memory_paths:
            var drive_type = connected_drives[path].type
            
            # Only sync to physical drives
            if drive_type != DriveType.ETHEREAL:
                if save_memory_fragment(fragment, path):
                    sync_stats.synced += 1
    
    sync_in_progress = false
    emit_signal("sync_complete", sync_stats)
    return true

func _identify_unique_fragments():
    var unique = []
    var fragment_hashes = {}
    
    for fragment in memory_fragments:
        # Create a simplified version for hashing
        var simplified = fragment.duplicate(true)
        if simplified.has("path"):
            simplified.erase("path")
        if simplified.has("name"):
            simplified.erase("name")
        if simplified.has("is_ethereal"):
            simplified.erase("is_ethereal")
        
        # Generate a hash
        var hash_text = JSON.stringify(simplified)
        var fragment_hash = hash_text.hash()
        
        # Add if unique
        if not fragment_hashes.has(fragment_hash):
            fragment_hashes[fragment_hash] = true
            unique.append(fragment)
    
    return unique

func get_drive_stats():
    var stats = {
        "drives": connected_drives.size(),
        "fragments": memory_fragments.size(),
        "paths": active_memory_paths
    }
    return stats

func create_fragment_from_investment(word, category, value, directional_data):
    var fragment = {
        "name": "investment_" + word,
        "type": "investment",
        "word": word,
        "category": category,
        "value": value,
        "timestamp": Time.get_unix_time_from_system(),
        "directions": directional_data,
        "dimensions": {
            "x": directional_data.get("right", 0) - directional_data.get("left", 0),
            "y": directional_data.get("up", 0) - directional_data.get("down", 0),
            "z": directional_data.get("forward", 0) - directional_data.get("backward", 0),
            "w": directional_data.get("inward", 0) - directional_data.get("outward", 0)
        },
        "color": _get_category_color(category)
    }
    
    return fragment

func _get_category_color(category):
    match category:
        "Knowledge": return "#3388ff"
        "Insight": return "#cc66ff"
        "Creation": return "#33cc66"
        "Connection": return "#ff9933"
        "Memory": return "#99ccff"
        "Dream": return "#7755cc"
        "Ethereal": return "#eeeeff"
        _: return "#aaaaaa"