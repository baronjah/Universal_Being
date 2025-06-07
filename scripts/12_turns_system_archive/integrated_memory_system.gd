extends Node

class_name IntegratedMemorySystem

# ----- MEMORY SYSTEM SETTINGS -----
@export_category("Memory System Settings")
@export var enabled: bool = true
@export var local_storage_enabled: bool = true
@export var online_storage_enabled: bool = false
@export var multi_device_sync: bool = false
@export var auto_backup: bool = true
@export var backup_interval: int = 300  # seconds
@export var memory_compression: bool = true
@export var memories_per_turn: int = 8
@export var max_stored_wishes: int = 88

# ----- STORAGE PATHS -----
var local_memory_path: String = "user://memory_system/"
var local_backup_path: String = "user://memory_system/backups/"
var offline_cache_path: String = "user://memory_system/offline_cache/"
var wish_storage_path: String = "user://memory_system/wishes/"
var connection_map_path: String = "user://memory_system/connections/"
var user_device_file: String = "user://memory_system/device_identity.json"

# ----- DEVICE IDENTITY -----
var device_id: String = ""
var device_name: String = ""
var last_sync_timestamp: int = 0
var memory_signature: String = ""

# ----- CLOUD STORAGE -----
var google_drive_connected: bool = false
var onedrive_connected: bool = false
var dropbox_connected: bool = false

# ----- MEMORY CONTAINERS -----
var local_memories: Dictionary = {}
var device_memories: Dictionary = {}
var cloud_memories: Dictionary = {}
var wish_collection: Array = []
var memory_connections: Dictionary = {}

# ----- CONNECTION SYSTEM -----
var connection_strength: Dictionary = {}
var connection_associations: Dictionary = {}
var memory_heat_map: Dictionary = {}

# ----- COMPONENT REFERENCES -----
var turn_system: Node = null
var time_tracker: Node = null

# ----- OFFLINE QUEUE -----
var offline_changes: Array = []
var pending_syncs: Dictionary = {}

# ----- TIMERS -----
var backup_timer: Timer
var sync_timer: Timer

# ----- SIGNALS -----
signal memory_stored(memory_id, content)
signal memory_retrieved(memory_id, content)
signal wish_added(wish_id, content)
signal wish_fulfilled(wish_id, content)
signal memories_synced(device_id, count)
signal connection_established(from_id, to_id, strength)
signal memory_system_ready()
signal cloud_connection_changed(service, connected)

# ----- INITIALIZATION -----
func _ready():
    # Create required directories
    _ensure_directories_exist()
    
    # Set up timers
    _setup_timers()
    
    # Generate or load device identity
    _initialize_device_identity()
    
    # Find reference components
    _find_reference_components()
    
    # Load local memories
    _load_local_memories()
    
    # Load wishes
    _load_wishes()
    
    # Load connection map
    _load_connection_map()
    
    # Check for cloud connections
    _check_cloud_connections()
    
    # Process any offline changes
    _process_offline_queue()
    
    # Log initialization
    print("Integrated Memory System initialized - Device ID: " + device_id)
    emit_signal("memory_system_ready")

func _ensure_directories_exist():
    var directories = [
        local_memory_path,
        local_backup_path,
        offline_cache_path,
        wish_storage_path,
        connection_map_path
    ]
    
    for dir in directories:
        if not DirAccess.dir_exists_absolute(dir):
            DirAccess.make_dir_recursive_absolute(dir)

func _setup_timers():
    # Backup timer
    backup_timer = Timer.new()
    backup_timer.wait_time = backup_interval
    backup_timer.one_shot = false
    backup_timer.autostart = true
    backup_timer.connect("timeout", _on_backup_timer_timeout)
    add_child(backup_timer)
    
    # Sync timer
    sync_timer = Timer.new()
    sync_timer.wait_time = 600  # 10 minutes
    sync_timer.one_shot = false
    sync_timer.autostart = true
    sync_timer.connect("timeout", _on_sync_timer_timeout)
    add_child(sync_timer)

func _initialize_device_identity():
    if FileAccess.file_exists(user_device_file):
        # Load existing identity
        var file = FileAccess.open(user_device_file, FileAccess.READ)
        if file:
            var json = JSON.new()
            var error = json.parse(file.get_as_text())
            if error == OK:
                var data = json.data
                device_id = data.get("device_id", "")
                device_name = data.get("device_name", "")
                last_sync_timestamp = data.get("last_sync", 0)
                memory_signature = data.get("memory_signature", "")
                
            file.close()
    
    # Generate new identity if needed
    if device_id.is_empty():
        device_id = _generate_unique_id()
        device_name = "Device_" + device_id.substr(0, 8)
        memory_signature = _generate_memory_signature()
        last_sync_timestamp = Time.get_unix_time_from_system()
        
        # Save identity
        _save_device_identity()

func _find_reference_components():
    # Find turn system
    var potential_turns = get_tree().get_nodes_in_group("turn_systems")
    if potential_turns.size() > 0:
        turn_system = potential_turns[0]
        print("Found turn system: " + turn_system.name)
    else:
        # Find using class name
        turn_system = _find_node_by_class(get_tree().root, "TurnSystem")
        if not turn_system:
            turn_system = _find_node_by_class(get_tree().root, "TurnCycleController")
    
    # Find time tracker
    var potential_trackers = get_tree().get_nodes_in_group("time_trackers")
    if potential_trackers.size() > 0:
        time_tracker = potential_trackers[0]
        print("Found time tracker: " + time_tracker.name)
    else:
        time_tracker = _find_node_by_class(get_tree().root, "UsageTimeTracker")

func _find_node_by_class(node, class_name):
    if node.get_class() == class_name:
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name)
        if found:
            return found
    
    return null

# ----- MEMORY LOADING -----
func _load_local_memories():
    # Clear existing memories
    local_memories.clear()
    
    # Scan memory directory
    var dir = DirAccess.open(local_memory_path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if not dir.current_is_dir() and file_name.ends_with(".json") and not file_name.begins_with("."): 
                var memory_path = local_memory_path + file_name
                _load_memory_file(memory_path)
            
            file_name = dir.get_next()
        
        dir.list_dir_end()
    
    print("Loaded " + str(local_memories.size()) + " local memories")

func _load_memory_file(file_path):
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file:
        var json = JSON.new()
        var error = json.parse(file.get_as_text())
        if error == OK:
            var memory_data = json.data
            var memory_id = memory_data.get("id", "")
            
            if not memory_id.is_empty():
                local_memories[memory_id] = memory_data
        
        file.close()

func _load_wishes():
    # Clear existing wishes
    wish_collection.clear()
    
    # Load wish file
    var wish_file = wish_storage_path + "wishes.json"
    
    if FileAccess.file_exists(wish_file):
        var file = FileAccess.open(wish_file, FileAccess.READ)
        if file:
            var json = JSON.new()
            var error = json.parse(file.get_as_text())
            if error == OK:
                wish_collection = json.data
            
            file.close()
    
    # Ensure we don't exceed max wishes
    if wish_collection.size() > max_stored_wishes:
        wish_collection = wish_collection.slice(wish_collection.size() - max_stored_wishes, wish_collection.size())
    
    print("Loaded " + str(wish_collection.size()) + " wishes")

func _load_connection_map():
    # Clear existing connections
    memory_connections.clear()
    
    # Load connection file
    var connection_file = connection_map_path + "memory_connections.json"
    
    if FileAccess.file_exists(connection_file):
        var file = FileAccess.open(connection_file, FileAccess.READ)
        if file:
            var json = JSON.new()
            var error = json.parse(file.get_as_text())
            if error == OK:
                memory_connections = json.data
            
            file.close()
    
    print("Loaded " + str(memory_connections.size()) + " memory connections")

func _check_cloud_connections():
    # Try to connect to cloud services if enabled
    if online_storage_enabled:
        _check_google_drive_connection()
        _check_onedrive_connection()
        _check_dropbox_connection()

func _check_google_drive_connection():
    # Placeholder for Google Drive connection
    # Would use actual API calls in a real implementation
    google_drive_connected = false
    emit_signal("cloud_connection_changed", "google_drive", google_drive_connected)

func _check_onedrive_connection():
    # Placeholder for OneDrive connection
    onedrive_connected = false
    emit_signal("cloud_connection_changed", "onedrive", onedrive_connected)

func _check_dropbox_connection():
    # Placeholder for Dropbox connection
    dropbox_connected = false
    emit_signal("cloud_connection_changed", "dropbox", dropbox_connected)

func _process_offline_queue():
    # Process any pending changes from offline mode
    var offline_queue_file = offline_cache_path + "offline_queue.json"
    
    if FileAccess.file_exists(offline_queue_file):
        var file = FileAccess.open(offline_queue_file, FileAccess.READ)
        if file:
            var json = JSON.new()
            var error = json.parse(file.get_as_text())
            
            if error == OK:
                offline_changes = json.data
                
                # Process each change
                var processed_changes = []
                
                for change in offline_changes:
                    var success = _process_offline_change(change)
                    if success:
                        processed_changes.append(change)
                
                # Remove processed changes
                for change in processed_changes:
                    offline_changes.erase(change)
                
                # Save remaining changes
                _save_offline_queue()
            
            file.close()
    
    print("Processed offline memory queue")

# ----- MEMORY OPERATIONS -----
func store_memory(content: String, tags: Array = [], type: String = "general", turn: int = -1):
    if not enabled:
        return ""
    
    # Get current turn if not specified
    if turn < 0 and turn_system and "current_turn" in turn_system:
        turn = turn_system.current_turn
    else:
        turn = 1  # Default
    
    # Generate memory ID
    var memory_id = _generate_unique_id()
    
    # Create memory structure
    var memory = {
        "id": memory_id,
        "content": content,
        "tags": tags,
        "type": type,
        "turn": turn,
        "device_id": device_id,
        "timestamp": Time.get_unix_time_from_system(),
        "connections": []
    }
    
    # Store locally
    local_memories[memory_id] = memory
    
    # Save to file
    _save_memory_to_file(memory)
    
    # Generate connections
    _generate_memory_connections(memory_id, content, tags)
    
    # Queue for syncing if online storage enabled
    if online_storage_enabled:
        _queue_for_syncing(memory_id)
    
    # Emit signal
    emit_signal("memory_stored", memory_id, content)
    
    return memory_id

func retrieve_memory(memory_id: String):
    # Check local memories first
    if local_memories.has(memory_id):
        emit_signal("memory_retrieved", memory_id, local_memories[memory_id])
        return local_memories[memory_id]
    
    # Check device memories
    if device_memories.has(memory_id):
        emit_signal("memory_retrieved", memory_id, device_memories[memory_id])
        return device_memories[memory_id]
    
    # Check cloud memories if enabled
    if online_storage_enabled and cloud_memories.has(memory_id):
        emit_signal("memory_retrieved", memory_id, cloud_memories[memory_id])
        return cloud_memories[memory_id]
    
    # Not found
    return null

func search_memories(query: String, tags: Array = [], type: String = "", max_results: int = 10):
    var results = []
    
    # Search in all memory containers
    var search_containers = [local_memories, device_memories, cloud_memories]
    
    for container in search_containers:
        for memory_id in container:
            var memory = container[memory_id]
            
            # Check type filter
            if not type.is_empty() and memory.type != type:
                continue
            
            # Check tags filter
            if not tags.is_empty():
                var has_all_tags = true
                for tag in tags:
                    if not memory.tags.has(tag):
                        has_all_tags = false
                        break
                
                if not has_all_tags:
                    continue
            
            # Check content for query
            if query.is_empty() or memory.content.to_lower().contains(query.to_lower()):
                results.append(memory)
                
                # Check if we've reached max results
                if results.size() >= max_results:
                    return results
    
    return results

func add_wish(wish_content: String, priority: int = 5, tags: Array = []):
    if not enabled:
        return ""
    
    # Generate wish ID
    var wish_id = _generate_unique_id()
    
    # Create wish structure
    var wish = {
        "id": wish_id,
        "content": wish_content,
        "priority": priority,
        "tags": tags,
        "created": Time.get_unix_time_from_system(),
        "fulfilled": false,
        "fulfilled_time": 0,
        "connections": []
    }
    
    # Add to collection
    wish_collection.append(wish)
    
    # Ensure we don't exceed max wishes
    if wish_collection.size() > max_stored_wishes:
        wish_collection.remove_at(0)
    
    # Save wishes
    _save_wishes()
    
    # Emit signal
    emit_signal("wish_added", wish_id, wish_content)
    
    return wish_id

func fulfill_wish(wish_id: String, fulfillment_details: String = ""):
    if not enabled:
        return false
    
    # Find wish
    for i in range(wish_collection.size()):
        if wish_collection[i].id == wish_id:
            wish_collection[i].fulfilled = true
            wish_collection[i].fulfilled_time = Time.get_unix_time_from_system()
            
            if not fulfillment_details.is_empty():
                wish_collection[i].fulfillment_details = fulfillment_details
            
            # Save wishes
            _save_wishes()
            
            # Create memory of fulfillment
            var memory_content = "Wish fulfilled: " + wish_collection[i].content
            if not fulfillment_details.is_empty():
                memory_content += " - " + fulfillment_details
            
            store_memory(memory_content, wish_collection[i].tags, "wish_fulfillment")
            
            # Emit signal
            emit_signal("wish_fulfilled", wish_id, wish_collection[i])
            
            return true
    
    return false

func connect_memories(from_id: String, to_id: String, connection_type: String = "association", strength: float = 1.0):
    if not enabled:
        return false
    
    # Ensure both memories exist
    if not local_memories.has(from_id) and not device_memories.has(from_id) and not cloud_memories.has(from_id):
        return false
    
    if not local_memories.has(to_id) and not device_memories.has(to_id) and not cloud_memories.has(to_id):
        return false
    
    # Create connection key
    var connection_key = from_id + "->" + to_id
    
    # Create connection
    var connection = {
        "from": from_id,
        "to": to_id,
        "type": connection_type,
        "strength": strength,
        "created": Time.get_unix_time_from_system()
    }
    
    # Add to connections
    memory_connections[connection_key] = connection
    
    # Add to memory's connections list
    if local_memories.has(from_id):
        if not "connections" in local_memories[from_id]:
            local_memories[from_id].connections = []
        
        local_memories[from_id].connections.append({
            "to": to_id,
            "type": connection_type,
            "strength": strength
        })
        
        # Save memory
        _save_memory_to_file(local_memories[from_id])
    
    # Save connections
    _save_connection_map()
    
    # Emit signal
    emit_signal("connection_established", from_id, to_id, strength)
    
    return true

func find_related_memories(memory_id: String, max_results: int = 10):
    var related = []
    
    # Find direct connections
    for connection_key in memory_connections:
        var connection = memory_connections[connection_key]
        
        if connection.from == memory_id:
            var to_memory = retrieve_memory(connection.to)
            if to_memory:
                related.append({
                    "memory": to_memory,
                    "connection": connection,
                    "direction": "outgoing"
                })
        
        if connection.to == memory_id:
            var from_memory = retrieve_memory(connection.from)
            if from_memory:
                related.append({
                    "memory": from_memory,
                    "connection": connection,
                    "direction": "incoming"
                })
        
        # Check if we've reached max results
        if related.size() >= max_results:
            break
    
    return related

# ----- SYNC OPERATIONS -----
func sync_with_device(target_device_id: String):
    if not multi_device_sync:
        return false
    
    # In a real implementation, this would involve network communication
    # Here we'll just simulate with a placeholder
    
    # Mark as pending sync
    pending_syncs[target_device_id] = Time.get_unix_time_from_system()
    
    print("Queued sync with device: " + target_device_id)
    
    return true

func _queue_for_syncing(memory_id: String):
    # Add to offline queue if we're not connected
    if not google_drive_connected and not onedrive_connected and not dropbox_connected:
        var change = {
            "type": "add",
            "memory_id": memory_id,
            "timestamp": Time.get_unix_time_from_system()
        }
        
        offline_changes.append(change)
        _save_offline_queue()
    else:
        # Otherwise, we would push directly to cloud storage
        # This is a placeholder for actual API calls
        print("Memory " + memory_id + " queued for sync to cloud")

func _process_offline_change(change):
    # Process a single offline change
    if change.type == "add":
        # We would upload to cloud storage here
        return true
    elif change.type == "update":
        # We would update cloud storage here
        return true
    elif change.type == "delete":
        # We would delete from cloud storage here
        return true
    
    return false

# ----- FILE OPERATIONS -----
func _save_memory_to_file(memory):
    var file_path = local_memory_path + memory.id + ".json"
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    
    if file:
        var json_string = JSON.stringify(memory, "  ")
        file.store_string(json_string)
        file.close()
        return true
    
    return false

func _save_wishes():
    var file_path = wish_storage_path + "wishes.json"
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    
    if file:
        var json_string = JSON.stringify(wish_collection, "  ")
        file.store_string(json_string)
        file.close()
        return true
    
    return false

func _save_connection_map():
    var file_path = connection_map_path + "memory_connections.json"
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    
    if file:
        var json_string = JSON.stringify(memory_connections, "  ")
        file.store_string(json_string)
        file.close()
        return true
    
    return false

func _save_device_identity():
    var identity = {
        "device_id": device_id,
        "device_name": device_name,
        "last_sync": last_sync_timestamp,
        "memory_signature": memory_signature
    }
    
    var file = FileAccess.open(user_device_file, FileAccess.WRITE)
    if file:
        var json_string = JSON.stringify(identity, "  ")
        file.store_string(json_string)
        file.close()
        return true
    
    return false

func _save_offline_queue():
    var file_path = offline_cache_path + "offline_queue.json"
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    
    if file:
        var json_string = JSON.stringify(offline_changes, "  ")
        file.store_string(json_string)
        file.close()
        return true
    
    return false

func _backup_memories():
    if not auto_backup:
        return
    
    # Create timestamp for backup
    var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
    var backup_folder = local_backup_path + "backup_" + timestamp + "/"
    
    # Create backup directory
    if not DirAccess.dir_exists_absolute(backup_folder):
        DirAccess.make_dir_recursive_absolute(backup_folder)
    
    # Copy all memory files
    var dir = DirAccess.open(local_memory_path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if not dir.current_is_dir() and file_name.ends_with(".json"):
                var source_path = local_memory_path + file_name
                var target_path = backup_folder + file_name
                
                var source_file = FileAccess.open(source_path, FileAccess.READ)
                var target_file = FileAccess.open(target_path, FileAccess.WRITE)
                
                if source_file and target_file:
                    target_file.store_string(source_file.get_as_text())
                    
                    source_file.close()
                    target_file.close()
            
            file_name = dir.get_next()
        
        dir.list_dir_end()
    
    # Backup wishes
    var wishes_source = wish_storage_path + "wishes.json"
    var wishes_target = backup_folder + "wishes.json"
    
    if FileAccess.file_exists(wishes_source):
        var source_file = FileAccess.open(wishes_source, FileAccess.READ)
        var target_file = FileAccess.open(wishes_target, FileAccess.WRITE)
        
        if source_file and target_file:
            target_file.store_string(source_file.get_as_text())
            
            source_file.close()
            target_file.close()
    
    # Backup connections
    var connections_source = connection_map_path + "memory_connections.json"
    var connections_target = backup_folder + "memory_connections.json"
    
    if FileAccess.file_exists(connections_source):
        var source_file = FileAccess.open(connections_source, FileAccess.READ)
        var target_file = FileAccess.open(connections_target, FileAccess.WRITE)
        
        if source_file and target_file:
            target_file.store_string(source_file.get_as_text())
            
            source_file.close()
            target_file.close()
    
    print("Created memory backup: " + timestamp)
    
    # Clean up old backups - keep only the latest 5
    _cleanup_old_backups(5)

func _cleanup_old_backups(keep_count: int):
    var backups = []
    
    # Scan backup directory
    var dir = DirAccess.open(local_backup_path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if dir.current_is_dir() and file_name.begins_with("backup_"):
                backups.append(file_name)
            
            file_name = dir.get_next()
        
        dir.list_dir_end()
    
    # Sort backups by name (which includes timestamp)
    backups.sort()
    
    # Remove oldest backups
    if backups.size() > keep_count:
        for i in range(0, backups.size() - keep_count):
            var old_backup = backups[i]
            _remove_directory_recursive(local_backup_path + old_backup)

func _remove_directory_recursive(path: String):
    var dir = DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if dir.current_is_dir() and file_name != "." and file_name != "..":
                _remove_directory_recursive(path + "/" + file_name)
            elif not dir.current_is_dir():
                dir.remove(file_name)
            
            file_name = dir.get_next()
        
        dir.list_dir_end()
        
        # Remove the empty directory
        DirAccess.remove_absolute(path)

# ----- MEMORY CONNECTIONS -----
func _generate_memory_connections(memory_id: String, content: String, tags: Array):
    # Find potentially related memories
    var related_by_content = _find_related_by_content(content, 3)
    var related_by_tags = _find_related_by_tags(tags, 3)
    
    # Combine unique related memories
    var related = {}
    
    for item in related_by_content:
        related[item.id] = item.similarity
    
    for item in related_by_tags:
        if related.has(item.id):
            related[item.id] = max(related[item.id], item.similarity)
        else:
            related[item.id] = item.similarity
    
    # Create connections
    for related_id in related:
        var strength = related[related_id]
        connect_memories(memory_id, related_id, "auto_association", strength)

func _find_related_by_content(content: String, max_results: int):
    var related = []
    
    # Simple word matching algorithm - in a real implementation
    # this would use more sophisticated NLP techniques
    var content_words = content.to_lower().split(" ", false)
    
    # Search through local memories
    for memory_id in local_memories:
        if memory_id == content:  # Skip self
            continue
        
        var memory = local_memories[memory_id]
        var memory_content = memory.content.to_lower()
        var memory_words = memory_content.split(" ", false)
        
        # Count matching words
        var matching_words = 0
        for word in content_words:
            if memory_words.has(word) and word.length() > 3:  # Only count significant words
                matching_words += 1
        
        # Calculate similarity (0-1)
        var max_possible_matches = min(content_words.size(), memory_words.size())
        var similarity = 0.0
        
        if max_possible_matches > 0:
            similarity = float(matching_words) / float(max_possible_matches)
        
        # Add if significant similarity
        if similarity > 0.2:
            related.append({
                "id": memory_id,
                "similarity": similarity
            })
            
            # Sort by similarity and keep only top results
            related.sort_custom(func(a, b): return a.similarity > b.similarity)
            
            if related.size() > max_results:
                related.resize(max_results)
    
    return related

func _find_related_by_tags(tags: Array, max_results: int):
    var related = []
    
    if tags.is_empty():
        return related
    
    # Search through local memories
    for memory_id in local_memories:
        var memory = local_memories[memory_id]
        
        if not "tags" in memory or memory.tags.is_empty():
            continue
        
        # Count matching tags
        var matching_tags = 0
        for tag in tags:
            if memory.tags.has(tag):
                matching_tags += 1
        
        # Calculate similarity (0-1)
        var max_possible_matches = min(tags.size(), memory.tags.size())
        var similarity = 0.0
        
        if max_possible_matches > 0:
            similarity = float(matching_tags) / float(max_possible_matches)
        
        # Add if has any matching tags
        if similarity > 0:
            related.append({
                "id": memory_id,
                "similarity": similarity
            })
            
            # Sort by similarity and keep only top results
            related.sort_custom(func(a, b): return a.similarity > b.similarity)
            
            if related.size() > max_results:
                related.resize(max_results)
    
    return related

# ----- UTILITY FUNCTIONS -----
func _generate_unique_id() -> String:
    var uuid = ""
    var chars = "abcdefghijklmnopqrstuvwxyz0123456789"
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    
    # Format: 8-4-4-4-12
    for i in range(32):
        if i == 8 or i == 12 or i == 16 or i == 20:
            uuid += "-"
        uuid += chars[rng.randi() % chars.length()]
    
    return uuid

func _generate_memory_signature() -> String:
    var signature = ""
    var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var rng = RandomNumberGenerator.new()
    rng.randomize()
    
    for i in range(16):
        signature += chars[rng.randi() % chars.length()]
    
    return signature

# ----- EVENT HANDLERS -----
func _on_backup_timer_timeout():
    if auto_backup:
        _backup_memories()

func _on_sync_timer_timeout():
    if online_storage_enabled:
        # Check cloud connections
        _check_cloud_connections()
        
        # Process offline queue if we're now connected
        if google_drive_connected or onedrive_connected or dropbox_connected:
            _process_offline_queue()

# ----- PUBLIC API -----
func get_memory_stats() -> Dictionary:
    return {
        "local_memories": local_memories.size(),
        "device_memories": device_memories.size(),
        "cloud_memories": cloud_memories.size(),
        "total_memories": local_memories.size() + device_memories.size() + cloud_memories.size(),
        "wishes": wish_collection.size(),
        "fulfilled_wishes": wish_collection.filter(func(wish): return wish.fulfilled).size(),
        "connections": memory_connections.size(),
        "device_id": device_id,
        "device_name": device_name,
        "online_storage": online_storage_enabled,
        "multi_device": multi_device_sync,
        "cloud_connections": {
            "google_drive": google_drive_connected,
            "onedrive": onedrive_connected,
            "dropbox": dropbox_connected
        }
    }

func set_device_name(name: String) -> bool:
    if name.is_empty():
        return false
    
    device_name = name
    _save_device_identity()
    return true

func toggle_online_storage() -> bool:
    online_storage_enabled = !online_storage_enabled
    
    if online_storage_enabled:
        _check_cloud_connections()
    
    return online_storage_enabled

func toggle_multi_device_sync() -> bool:
    multi_device_sync = !multi_device_sync
    return multi_device_sync

func export_memories(target_path: String, format: String = "json") -> bool:
    if not DirAccess.dir_exists_absolute(target_path):
        return false
    
    match format:
        "json":
            # Export as single JSON file
            var export_data = {
                "memories": local_memories,
                "wishes": wish_collection,
                "connections": memory_connections,
                "device_info": {
                    "device_id": device_id,
                    "device_name": device_name,
                    "exported_at": Time.get_datetime_string_from_system()
                }
            }
            
            var file_path = target_path + "/memories_export_" + Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_") + ".json"
            var file = FileAccess.open(file_path, FileAccess.WRITE)
            
            if file:
                var json_string = JSON.stringify(export_data, "  ")
                file.store_string(json_string)
                file.close()
                return true
        
        # Could add other formats like CSV, XML, etc.
    
    return false

func import_memories(source_path: String) -> Dictionary:
    if not FileAccess.file_exists(source_path):
        return {"success": false, "error": "File not found"}
    
    var file = FileAccess.open(source_path, FileAccess.READ)
    if not file:
        return {"success": false, "error": "Could not open file"}
    
    var json = JSON.new()
    var error = json.parse(file.get_as_text())
    
    if error != OK:
        file.close()
        return {"success": false, "error": "Invalid JSON format"}
    
    var data = json.data
    file.close()
    
    # Validate import data
    if not data.has("memories") or not data.has("wishes") or not data.has("connections"):
        return {"success": false, "error": "Invalid memory export format"}
    
    # Import memories
    var imported_count = 0
    
    for memory_id in data.memories:
        var memory = data.memories[memory_id]
        
        # Skip if we already have this memory
        if local_memories.has(memory_id):
            continue
        
        # Add to local memories
        local_memories[memory_id] = memory
        
        # Save to file
        _save_memory_to_file(memory)
        
        imported_count += 1
    
    # Import wishes
    var imported_wishes = 0
    
    for wish in data.wishes:
        # Check if we already have this wish
        var exists = false
        for existing_wish in wish_collection:
            if existing_wish.id == wish.id:
                exists = true
                break
        
        if not exists:
            wish_collection.append(wish)
            imported_wishes += 1
    
    # Ensure we don't exceed max wishes
    if wish_collection.size() > max_stored_wishes:
        wish_collection = wish_collection.slice(wish_collection.size() - max_stored_wishes, wish_collection.size())
    
    # Save wishes
    _save_wishes()
    
    # Import connections
    var imported_connections = 0
    
    for connection_key in data.connections:
        if not memory_connections.has(connection_key):
            memory_connections[connection_key] = data.connections[connection_key]
            imported_connections += 1
    
    # Save connections
    _save_connection_map()
    
    return {
        "success": true,
        "imported_memories": imported_count,
        "imported_wishes": imported_wishes,
        "imported_connections": imported_connections
    }