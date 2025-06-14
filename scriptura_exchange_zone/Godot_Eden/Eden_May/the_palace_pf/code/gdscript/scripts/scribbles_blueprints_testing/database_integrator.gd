extends Node
class_name AkashicDatabaseIntegrator

# System references
var akashic_records_manager: Node = null
var jsh_data_splitter: Node = null
var jsh_records_system: Node = null
var jsh_database_system: Node = null

# Configuration
var max_file_size_bytes: int = 5 * 1024 * 1024  # 5MB
var max_entries_per_file: int = 10000
var check_interval_seconds: float = 60.0
var registry_path: String = "user://akashic_registry.json"

# State
var file_registry: Dictionary = {}
var check_timer: Timer = null

# Signals
signal database_split(file_path, new_files)
signal registry_updated

func _ready() -> void:
    # Set up timer for periodic checks
    check_timer = Timer.new()
    check_timer.wait_time = check_interval_seconds
    check_timer.autostart = true
    check_timer.one_shot = false
    add_child(check_timer)
    check_timer.connect("timeout", Callable(self, "_on_check_timer_timeout"))
    
    # Load registry on startup
    load_registry()

func initialize(records_manager: Node, data_splitter: Node, records_system: Node, database_system: Node) -> void:
    akashic_records_manager = records_manager
    jsh_data_splitter = data_splitter
    jsh_records_system = records_system
    jsh_database_system = database_system
    
    print("DatabaseIntegrator: Initialized with system references")

# Registry management
func load_registry() -> void:
    var file = FileAccess.open(registry_path, FileAccess.READ)
    if file:
        var json_string = file.get_as_text()
        file.close()
        
        var json = JSON.new()
        var error = json.parse(json_string)
        if error == OK:
            file_registry = json.get_data()
            print("DatabaseIntegrator: Registry loaded with ", file_registry.size(), " entries")
        else:
            print("DatabaseIntegrator: Error parsing registry JSON: ", error)
            # Initialize an empty registry
            file_registry = {
                "files": {},
                "references": {},
                "split_history": []
            }
    else:
        print("DatabaseIntegrator: Registry file not found, creating new registry")
        # Initialize an empty registry
        file_registry = {
            "files": {},
            "references": {},
            "split_history": []
        }
        save_registry()

func save_registry() -> void:
    var file = FileAccess.open(registry_path, FileAccess.WRITE)
    if file:
        var json_string = JSON.stringify(file_registry)
        file.store_string(json_string)
        file.close()
        print("DatabaseIntegrator: Registry saved")
    else:
        print("DatabaseIntegrator: Error opening registry file for writing")

func register_database_file(file_path: String, metadata: Dictionary = {}) -> void:
    # Extract or create initial metadata
    if !metadata.has("creation_date"):
        metadata["creation_date"] = Time.get_datetime_string_from_system()
    if !metadata.has("entry_count"):
        metadata["entry_count"] = count_entries(file_path)
    if !metadata.has("byte_size"):
        metadata["byte_size"] = get_file_size(file_path)
    if !metadata.has("parent_file"):
        metadata["parent_file"] = ""
    if !metadata.has("child_files"):
        metadata["child_files"] = []
    
    # Add to registry
    file_registry["files"][file_path] = metadata
    save_registry()
    emit_signal("registry_updated")
    
    print("DatabaseIntegrator: Registered file: ", file_path)

func unregister_database_file(file_path: String) -> void:
    if file_registry["files"].has(file_path):
        file_registry["files"].erase(file_path)
        save_registry()
        emit_signal("registry_updated")
        print("DatabaseIntegrator: Unregistered file: ", file_path)
    else:
        print("DatabaseIntegrator: Cannot unregister non-existent file: ", file_path)

func update_file_metadata(file_path: String, metadata: Dictionary) -> void:
    if file_registry["files"].has(file_path):
        # Update only provided fields
        for key in metadata:
            file_registry["files"][file_path][key] = metadata[key]
        save_registry()
        emit_signal("registry_updated")
        print("DatabaseIntegrator: Updated metadata for file: ", file_path)
    else:
        print("DatabaseIntegrator: Cannot update metadata for non-existent file: ", file_path)

# File management
func count_entries(file_path: String) -> int:
    # This is a placeholder - in your real implementation, 
    # this would use your JSH systems to count entries
    
    # Placeholder implementation: check if the file exists
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file:
        var entry_count = 0
        # Simple line counting as placeholder
        while file.get_position() < file.get_length():
            file.get_line()
            entry_count += 1
        file.close()
        return entry_count
    return 0

func get_file_size(file_path: String) -> int:
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file:
        var size = file.get_length()
        file.close()
        return size
    return 0

func create_reference_file(original_file: String, split_files: Array) -> String:
    # Create a reference file that points to the split files
    var reference_file_path = original_file + ".ref"
    
    var reference_data = {
        "original_file": original_file,
        "split_files": split_files,
        "creation_date": Time.get_datetime_string_from_system()
    }
    
    var file = FileAccess.open(reference_file_path, FileAccess.WRITE)
    if file:
        var json_string = JSON.stringify(reference_data)
        file.store_string(json_string)
        file.close()
        
        # Register the reference file
        file_registry["references"][reference_file_path] = reference_data
        save_registry()
        
        print("DatabaseIntegrator: Created reference file: ", reference_file_path)
        return reference_file_path
    else:
        print("DatabaseIntegrator: Failed to create reference file")
        return ""

# Database checking and splitting
func check_database_sizes() -> void:
    print("DatabaseIntegrator: Checking database sizes...")
    
    var files_to_check = file_registry["files"].keys()
    for file_path in files_to_check:
        # Skip files that are already split
        if file_registry["files"][file_path].has("is_split") and file_registry["files"][file_path]["is_split"]:
            continue
            
        var size = get_file_size(file_path)
        var entry_count = count_entries(file_path)
        
        # Update metadata
        update_file_metadata(file_path, {
            "byte_size": size,
            "entry_count": entry_count,
            "last_checked": Time.get_datetime_string_from_system()
        })
        
        # Check if file exceeds thresholds
        if size > max_file_size_bytes or entry_count > max_entries_per_file:
            print("DatabaseIntegrator: File exceeds threshold, splitting: ", file_path)
            split_database_file(file_path)

func _on_check_timer_timeout() -> void:
    check_database_sizes()

func split_database_file(file_path: String) -> Array:
    print("DatabaseIntegrator: Splitting database file: ", file_path)
    
    # This would use your JSH_data_splitter to do the actual splitting
    # For now, we'll create a simulated split
    
    var new_files = []
    var base_path = file_path.get_basename()
    var extension = file_path.get_extension()
    
    # Simulate splitting into 3 chunks
    for i in range(3):
        var chunk_path = base_path + "_chunk" + str(i) + "." + extension
        new_files.append(chunk_path)
        
        # Register the new chunk file
        register_database_file(chunk_path, {
            "parent_file": file_path,
            "chunk_index": i,
            "creation_date": Time.get_datetime_string_from_system(),
            "entry_count": count_entries(file_path) / 3,  # Simplified simulation
            "byte_size": get_file_size(file_path) / 3     # Simplified simulation
        })
    
    # Create reference file
    var reference_file = create_reference_file(file_path, new_files)
    
    # Update original file metadata
    update_file_metadata(file_path, {
        "is_split": true,
        "reference_file": reference_file,
        "child_files": new_files,
        "split_date": Time.get_datetime_string_from_system()
    })
    
    # Log split in history
    file_registry["split_history"].append({
        "original_file": file_path,
        "new_files": new_files,
        "reference_file": reference_file,
        "date": Time.get_datetime_string_from_system()
    })
    save_registry()
    
    # Emit signal
    emit_signal("database_split", file_path, new_files)
    
    print("DatabaseIntegrator: Split complete, created ", new_files.size(), " new files")
    return new_files

# Public API
func get_database_files() -> Array:
    return file_registry["files"].keys()

func get_reference_files() -> Array:
    return file_registry["references"].keys()

func get_file_metadata(file_path: String) -> Dictionary:
    if file_registry["files"].has(file_path):
        return file_registry["files"][file_path]
    return {}

func get_reference_data(reference_file: String) -> Dictionary:
    if file_registry["references"].has(reference_file):
        return file_registry["references"][reference_file]
    return {}

func get_split_history() -> Array:
    return file_registry["split_history"]

func resolve_file_reference(file_path: String) -> Array:
    # Check if this file has been split
    if file_registry["files"].has(file_path) and file_registry["files"][file_path].has("is_split") and file_registry["files"][file_path]["is_split"]:
        return file_registry["files"][file_path]["child_files"]
    return [file_path]  # Return the original file if not split