extends RefCounted
class_name JSHFileStorageAdapter

# Default paths
const DEFAULT_STORAGE_ROOT = "user://storage/"
const DEFAULT_ENTITY_DATA_DIR = "entity_data/"
const DEFAULT_MEDIA_DIR = "media/"
const DEFAULT_TEMP_DIR = "temp/"

# Storage paths
var storage_root: String = DEFAULT_STORAGE_ROOT
var entity_data_path: String = storage_root + DEFAULT_ENTITY_DATA_DIR
var media_path: String = storage_root + DEFAULT_MEDIA_DIR
var temp_path: String = storage_root + DEFAULT_TEMP_DIR

# Storage options
var auto_create_dirs: bool = true
var use_compression: bool = false
var compression_level: int = 6  # 0-9 for GZIP
var file_mode: int = FileAccess.READ_WRITE

# File tracking
var open_files: Dictionary = {}
var file_locks: Dictionary = {}

# Initialization flag
var _initialized: bool = false

# Statistics
var stats: Dictionary = {
    "reads": 0,
    "writes": 0,
    "appends": 0,
    "deletes": 0,
    "total_bytes_read": 0,
    "total_bytes_written": 0
}

func _init(root_path: String = "") -> void:
    if not root_path.is_empty():
        storage_root = root_path
        entity_data_path = storage_root + DEFAULT_ENTITY_DATA_DIR
        media_path = storage_root + DEFAULT_MEDIA_DIR
        temp_path = storage_root + DEFAULT_TEMP_DIR

func initialize() -> bool:
    print("JSHFileStorageAdapter: Initializing at " + storage_root)
    
    # Ensure directories exist
    if auto_create_dirs:
        ensure_directories()
    
    _initialized = true
    print("JSHFileStorageAdapter: Initialized")
    return true

func is_initialized() -> bool:
    return _initialized

# Directory management
func ensure_directories() -> void:
    var dir = DirAccess.open("user://")
    
    # Create main directories
    dir.make_dir_recursive(entity_data_path)
    dir.make_dir_recursive(media_path)
    dir.make_dir_recursive(temp_path)
    
    print("JSHFileStorageAdapter: Directories created")

func ensure_path_exists(path: String) -> bool:
    if not path.ends_with("/"):
        # Extract directory part
        var last_slash = path.rfind("/")
        if last_slash >= 0:
            path = path.substr(0, last_slash + 1)
        else:
            return true  # No directory part
    
    var dir = DirAccess.open("user://")
    dir.make_dir_recursive(path)
    
    return true

# Path helpers
func get_entity_data_file_path(entity_id: String, data_type: String = "main") -> String:
    var file_extension = get_file_extension(data_type)
    return entity_data_path + entity_id + "_" + data_type + file_extension

func get_media_file_path(media_id: String, media_type: String = "image") -> String:
    var file_extension = get_media_extension(media_type)
    return media_path + media_id + file_extension

func get_temp_file_path(file_name: String) -> String:
    return temp_path + file_name

func get_file_extension(data_type: String) -> String:
    match data_type:
        "binary":
            return ".dat"
        "compressed":
            return ".dat.gz"
        "json":
            return ".json"
        "text":
            return ".txt"
        "csv":
            return ".csv"
        _:
            return ".json"

func get_media_extension(media_type: String) -> String:
    match media_type:
        "image":
            return ".png"
        "audio":
            return ".wav"
        "video":
            return ".webm"
        "model":
            return ".glb"
        "texture":
            return ".ktx"
        _:
            return ".bin"

# File operations
func file_exists(file_path: String) -> bool:
    var file = FileAccess.open(file_path, FileAccess.READ)
    
    if file:
        file.close()
        return true
    
    return false

func save_data(file_path: String, data, data_type: String = "json") -> bool:
    if not _initialized:
        push_error("JSHFileStorageAdapter: Not initialized")
        return false
    
    # Ensure parent directory exists
    ensure_path_exists(file_path)
    
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    
    if file:
        match data_type:
            "binary":
                file.store_var(data)
            "compressed":
                var buffer = data
                if typeof(data) == TYPE_STRING:
                    buffer = data.to_utf8_buffer()
                elif typeof(data) == TYPE_DICTIONARY or typeof(data) == TYPE_ARRAY:
                    buffer = JSON.stringify(data).to_utf8_buffer()
                
                file.store_buffer(buffer.compress(FileAccess.COMPRESSION_GZIP))
            "json":
                var json_string = ""
                if typeof(data) == TYPE_DICTIONARY or typeof(data) == TYPE_ARRAY:
                    json_string = JSON.stringify(data, "  ")
                else:
                    json_string = str(data)
                
                file.store_string(json_string)
            "text", "csv", _:
                file.store_string(str(data))
        
        # Update stats
        stats.writes += 1
        stats.total_bytes_written += file.get_length()
        
        file.close()
        return true
    
    push_error("JSHFileStorageAdapter: Failed to save file - " + file_path)
    return false

func load_data(file_path: String, data_type: String = "json"):
    if not _initialized:
        push_error("JSHFileStorageAdapter: Not initialized")
        return null
    
    var file = FileAccess.open(file_path, FileAccess.READ)
    
    if file:
        var data = null
        
        match data_type:
            "binary":
                data = file.get_var()
            "compressed":
                var compressed_data = file.get_buffer(file.get_length())
                var decompressed = compressed_data.decompress_dynamic(-1, FileAccess.COMPRESSION_GZIP)
                
                # Try to parse as JSON
                var json_string = decompressed.get_string_from_utf8()
                var json_result = JSON.parse_string(json_string)
                
                if json_result != null:
                    data = json_result
                else:
                    # Return raw decompressed data
                    data = decompressed
            "json":
                var json_string = file.get_as_text()
                var json_result = JSON.parse_string(json_string)
                
                if json_result != null:
                    data = json_result
                else:
                    data = json_string
            "text", "csv", _:
                data = file.get_as_text()
        
        # Update stats
        stats.reads += 1
        stats.total_bytes_read += file.get_length()
        
        file.close()
        return data
    
    return null

func append_data(file_path: String, data, data_type: String = "text") -> bool:
    if not _initialized:
        push_error("JSHFileStorageAdapter: Not initialized")
        return false
    
    # Check if file exists, if not create it
    if not file_exists(file_path):
        return save_data(file_path, data, data_type)
    
    # For append, we need to handle different data types
    match data_type:
        "binary":
            # For binary, we need to read the file, append, and save
            var existing_data = load_data(file_path, "binary")
            
            if typeof(existing_data) == TYPE_ARRAY and typeof(data) == TYPE_ARRAY:
                existing_data.append_array(data)
            elif typeof(existing_data) == TYPE_DICTIONARY and typeof(data) == TYPE_DICTIONARY:
                for key in data:
                    existing_data[key] = data[key]
            else:
                push_error("JSHFileStorageAdapter: Incompatible data types for append")
                return false
            
            return save_data(file_path, existing_data, "binary")
        "json":
            # For JSON, we need to read the file, append, and save
            var existing_data = load_data(file_path, "json")
            
            if typeof(existing_data) == TYPE_ARRAY and typeof(data) == TYPE_ARRAY:
                existing_data.append_array(data)
            elif typeof(existing_data) == TYPE_DICTIONARY and typeof(data) == TYPE_DICTIONARY:
                for key in data:
                    existing_data[key] = data[key]
            else:
                push_error("JSHFileStorageAdapter: Incompatible data types for append")
                return false
            
            return save_data(file_path, existing_data, "json")
        "text", "csv", _:
            # For text, we can actually append to the file
            var file = FileAccess.open(file_path, FileAccess.READ_WRITE)
            
            if file:
                # Seek to end
                file.seek_end()
                
                # Append data
                var text_data = str(data)
                file.store_string(text_data)
                
                # Update stats
                stats.appends += 1
                stats.total_bytes_written += text_data.length()
                
                file.close()
                return true
    
    push_error("JSHFileStorageAdapter: Failed to append to file - " + file_path)
    return false

func delete_file(file_path: String) -> bool:
    if not _initialized:
        push_error("JSHFileStorageAdapter: Not initialized")
        return false
    
    var dir = DirAccess.open("user://")
    
    if dir.file_exists(file_path):
        var result = dir.remove(file_path)
        
        if result == OK:
            stats.deletes += 1
            return true
    
    return false

func copy_file(source_path: String, dest_path: String) -> bool:
    if not _initialized:
        push_error("JSHFileStorageAdapter: Not initialized")
        return false
    
    # Ensure source exists
    var source_file = FileAccess.open(source_path, FileAccess.READ)
    
    if not source_file:
        push_error("JSHFileStorageAdapter: Source file does not exist - " + source_path)
        return false
    
    # Ensure destination directory exists
    ensure_path_exists(dest_path)
    
    # Open destination
    var dest_file = FileAccess.open(dest_path, FileAccess.WRITE)
    
    if not dest_file:
        push_error("JSHFileStorageAdapter: Cannot open destination file - " + dest_path)
        source_file.close()
        return false
    
    # Copy data
    var buffer_size = 4096  # 4KB chunks
    var buffer = source_file.get_buffer(buffer_size)
    
    while buffer.size() > 0:
        dest_file.store_buffer(buffer)
        buffer = source_file.get_buffer(buffer_size)
    
    source_file.close()
    dest_file.close()
    
    return true

func move_file(source_path: String, dest_path: String) -> bool:
    if not _initialized:
        push_error("JSHFileStorageAdapter: Not initialized")
        return false
    
    # Copy file
    var copy_result = copy_file(source_path, dest_path)
    
    if not copy_result:
        return false
    
    # Delete source
    return delete_file(source_path)

func list_files(directory: String, pattern: String = "*") -> Array:
    if not _initialized:
        push_error("JSHFileStorageAdapter: Not initialized")
        return []
    
    var result = []
    var dir = DirAccess.open(directory)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while not file_name.is_empty():
            if not dir.current_is_dir():
                if pattern == "*" or file_name.match(pattern):
                    result.append(file_name)
            
            file_name = dir.get_next()
    
    return result

func list_directories(directory: String) -> Array:
    if not _initialized:
        push_error("JSHFileStorageAdapter: Not initialized")
        return []
    
    var result = []
    var dir = DirAccess.open(directory)
    
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while not file_name.is_empty():
            if dir.current_is_dir() and file_name != "." and file_name != "..":
                result.append(file_name)
            
            file_name = dir.get_next()
    
    return result

# Lock operations
func lock_file(file_path: String) -> bool:
    if file_locks.has(file_path):
        return false
    
    # Create lock file
    var lock_path = file_path + ".lock"
    var lock_file = FileAccess.open(lock_path, FileAccess.WRITE)
    
    if lock_file:
        lock_file.store_string(str(Time.get_unix_time_from_system()))
        lock_file.close()
        
        file_locks[file_path] = lock_path
        return true
    
    return false

func unlock_file(file_path: String) -> bool:
    if not file_locks.has(file_path):
        return false
    
    var lock_path = file_locks[file_path]
    var dir = DirAccess.open("user://")
    
    if dir.file_exists(lock_path):
        var result = dir.remove(lock_path)
        
        if result == OK:
            file_locks.erase(file_path)
            return true
    
    return false

func is_file_locked(file_path: String) -> bool:
    # Check for global lock
    if file_locks.has(file_path):
        return true
    
    # Check for lock file
    var lock_path = file_path + ".lock"
    var file = FileAccess.open(lock_path, FileAccess.READ)
    
    if file:
        file.close()
        return true
    
    return false

# Entity data operations
func save_entity_data(entity_id: String, entity_data, data_type: String = "main") -> bool:
    if not _initialized:
        push_error("JSHFileStorageAdapter: Not initialized")
        return false
    
    var file_path = get_entity_data_file_path(entity_id, data_type)
    return save_data(file_path, entity_data, "json")

func load_entity_data(entity_id: String, data_type: String = "main"):
    if not _initialized:
        push_error("JSHFileStorageAdapter: Not initialized")
        return null
    
    var file_path = get_entity_data_file_path(entity_id, data_type)
    return load_data(file_path, "json")

func entity_data_exists(entity_id: String, data_type: String = "main") -> bool:
    var file_path = get_entity_data_file_path(entity_id, data_type)
    return file_exists(file_path)

func delete_entity_data(entity_id: String, data_type: String = "main") -> bool:
    var file_path = get_entity_data_file_path(entity_id, data_type)
    return delete_file(file_path)

# Media operations
func save_media_file(media_id: String, media_data, media_type: String = "image") -> bool:
    if not _initialized:
        push_error("JSHFileStorageAdapter: Not initialized")
        return false
    
    var file_path = get_media_file_path(media_id, media_type)
    
    # For images, handle Image objects
    if media_type == "image" and media_data is Image:
        var image = media_data as Image
        return image.save_png(file_path) == OK
    
    # For other types, save raw data
    return save_data(file_path, media_data, "binary")

func load_media_file(media_id: String, media_type: String = "image"):
    if not _initialized:
        push_error("JSHFileStorageAdapter: Not initialized")
        return null
    
    var file_path = get_media_file_path(media_id, media_type)
    
    # For images, load as Image object
    if media_type == "image":
        var image = Image.new()
        var err = image.load(file_path)
        if err == OK:
            return image
        return null
    
    # For other types, load raw data
    return load_data(file_path, "binary")

func media_file_exists(media_id: String, media_type: String = "image") -> bool:
    var file_path = get_media_file_path(media_id, media_type)
    return file_exists(file_path)

func delete_media_file(media_id: String, media_type: String = "image") -> bool:
    var file_path = get_media_file_path(media_id, media_type)
    return delete_file(file_path)

# Temporary file operations
func create_temp_file(prefix: String = "temp_", extension: String = ".tmp") -> String:
    if not _initialized:
        push_error("JSHFileStorageAdapter: Not initialized")
        return ""
    
    # Generate unique name
    var temp_name = prefix + str(Time.get_unix_time_from_system()) + "_" + str(randi() % 10000).pad_zeros(4) + extension
    var file_path = get_temp_file_path(temp_name)
    
    # Create empty file
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    
    if file:
        file.close()
        return file_path
    
    return ""

func cleanup_temp_files(max_age_seconds: int = 3600) -> int:
    if not _initialized:
        push_error("JSHFileStorageAdapter: Not initialized")
        return 0
    
    var count = 0
    var current_time = Time.get_unix_time_from_system()
    var files = list_files(temp_path)
    
    for file_name in files:
        var file_path = temp_path + file_name
        
        # Check file age
        var file = FileAccess.open(file_path, FileAccess.READ)
        
        if file:
            var modified_time = file.get_modified_time(file_path)
            file.close()
            
            if current_time - modified_time > max_age_seconds:
                if delete_file(file_path):
                    count += 1
    
    return count

# Statistics
func get_statistics() -> Dictionary:
    return stats

func reset_statistics() -> void:
    stats = {
        "reads": 0,
        "writes": 0,
        "appends": 0,
        "deletes": 0,
        "total_bytes_read": 0,
        "total_bytes_written": 0
    }