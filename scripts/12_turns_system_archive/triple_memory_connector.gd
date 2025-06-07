extends Node

class_name TripleMemoryConnector

# ----- CONNECTOR SETTINGS -----
@export_category("Memory Connector Settings")
@export var enabled: bool = true
@export var auto_connect: bool = true
@export var synchronize_frequency: float = 0.5  # How often to sync memories (in seconds)
@export var max_sync_entries: int = 888
@export var memory_compression_level: int = 6  # 0-9 scale, higher = more compression

# ----- MEMORY SYSTEMS -----
enum MemorySystem {
    LOCAL,      # Device storage
    ETHEREAL,   # Ethereal Engine storage
    AKASHIC     # Akashic Records storage
}

# ----- MEMORY PATHS -----
var local_memory_path: String = "user://memory_system/"
var ethereal_memory_path: String = "user://ethereal_memories/"
var akashic_memory_path: String = "user://akashic_records/"

# ----- MEMORY CONTAINERS -----
var local_memories: Dictionary = {}
var ethereal_memories: Dictionary = {}
var akashic_memories: Dictionary = {}

# ----- SYSTEM REFERENCES -----
var memory_system: Node = null
var ethereal_bridge: Node = null
var performance_optimizer: Node = null

# ----- SYNCHRONIZATION STATE -----
var last_sync_time: int = 0
var sync_in_progress: bool = false
var sync_queues: Dictionary = {
    MemorySystem.LOCAL: [],
    MemorySystem.ETHEREAL: [],
    MemorySystem.AKASHIC: []
}
var memory_conflicts: Array = []

# ----- MEMORY STATISTICS -----
var sync_stats: Dictionary = {
    "last_sync": 0,
    "total_syncs": 0,
    "transferred_entries": 0,
    "conflicts_resolved": 0,
    "compression_savings": 0.0
}

# ----- WISH CONNECTIONS -----
var connected_wishes: Dictionary = {}
var wish_completions: Dictionary = {}

# ----- TIMERS -----
var sync_timer: Timer
var cleanup_timer: Timer

# ----- SIGNALS -----
signal memory_systems_connected()
signal memories_synchronized(stats)
signal memory_conflict_detected(memory_id, systems)
signal wish_connected(wish_id, memory_ids)
signal wish_fulfilled(wish_id, memory_id)

# ----- INITIALIZATION -----
func _ready():
    # Set up directories
    _ensure_directories_exist()
    
    # Set up timers
    _setup_timers()
    
    # Find system references
    _find_system_references()
    
    # Load memories
    _load_all_memories()
    
    # Auto-connect if enabled
    if auto_connect:
        connect_memory_systems()
    
    print("Triple Memory Connector initialized")

func _ensure_directories_exist():
    var directories = [
        local_memory_path,
        ethereal_memory_path,
        akashic_memory_path
    ]
    
    for dir in directories:
        if not DirAccess.dir_exists_absolute(dir):
            DirAccess.make_dir_recursive_absolute(dir)

func _setup_timers():
    # Sync timer
    sync_timer = Timer.new()
    sync_timer.wait_time = synchronize_frequency
    sync_timer.one_shot = false
    sync_timer.autostart = true
    sync_timer.connect("timeout", _on_sync_timer_timeout)
    add_child(sync_timer)
    
    # Cleanup timer - runs every 5 minutes
    cleanup_timer = Timer.new()
    cleanup_timer.wait_time = 300
    cleanup_timer.one_shot = false
    cleanup_timer.autostart = true
    cleanup_timer.connect("timeout", _on_cleanup_timer_timeout)
    add_child(cleanup_timer)

func _find_system_references():
    # Find Memory System
    memory_system = _find_node_by_class(get_tree().root, "IntegratedMemorySystem")
    
    # Find Ethereal Bridge
    ethereal_bridge = _find_node_by_class(get_tree().root, "EtherealAkashicBridge")
    
    # Find Performance Optimizer
    performance_optimizer = _find_node_by_class(get_tree().root, "PerformanceOptimizer")

func _find_node_by_class(node, class_name):
    if node.get_class() == class_name or (node.get_script() and node.get_script().get_path().find(class_name.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name)
        if found:
            return found
    
    return null

# ----- MEMORY LOADING -----
func _load_all_memories():
    # Load memories from all three systems
    _load_local_memories()
    _load_ethereal_memories()
    _load_akashic_memories()
    
    print("Loaded memories - Local: " + str(local_memories.size()) + 
          ", Ethereal: " + str(ethereal_memories.size()) + 
          ", Akashic: " + str(akashic_memories.size()))

func _load_local_memories():
    local_memories.clear()
    
    # Load from local memory path
    _load_memories_from_directory(local_memory_path, local_memories)

func _load_ethereal_memories():
    ethereal_memories.clear()
    
    # Load from ethereal memory path
    _load_memories_from_directory(ethereal_memory_path, ethereal_memories)

func _load_akashic_memories():
    akashic_memories.clear()
    
    # Load from akashic memory path
    _load_memories_from_directory(akashic_memory_path, akashic_memories)

func _load_memories_from_directory(directory_path, memory_container):
    var dir = DirAccess.open(directory_path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        
        while file_name != "":
            if not dir.current_is_dir() and file_name.ends_with(".json"):
                var memory_path = directory_path + file_name
                _load_memory_file(memory_path, memory_container)
            
            file_name = dir.get_next()
        
        dir.list_dir_end()

func _load_memory_file(file_path, memory_container):
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file:
        var content = file.get_as_text()
        
        # Decompress if it starts with the compression marker
        if content.begins_with("COMPRESSED:"):
            content = _decompress_memory_data(content.substr(11))  # Remove "COMPRESSED:" prefix
        
        var json = JSON.new()
        var error = json.parse(content)
        
        if error == OK:
            var memory_data = json.data
            var memory_id = memory_data.get("id", "")
            
            if not memory_id.is_empty():
                memory_container[memory_id] = memory_data
        
        file.close()

# ----- MEMORY SYSTEM CONNECTION -----
func connect_memory_systems():
    if not enabled:
        return false
    
    var connected = true
    
    # Connect to Memory System if available
    if memory_system:
        # Connect signals
        if memory_system.has_signal("memory_stored"):
            if not memory_system.is_connected("memory_stored", _on_memory_stored):
                memory_system.connect("memory_stored", _on_memory_stored)
        
        if memory_system.has_signal("wish_added"):
            if not memory_system.is_connected("wish_added", _on_wish_added):
                memory_system.connect("wish_added", _on_wish_added)
        
        if memory_system.has_signal("wish_fulfilled"):
            if not memory_system.is_connected("wish_fulfilled", _on_wish_fulfilled):
                memory_system.connect("wish_fulfilled", _on_wish_fulfilled)
    else:
        connected = false
    
    # Connect to Ethereal Bridge if available
    if ethereal_bridge:
        # Connect signals
        if ethereal_bridge.has_signal("memory_recorded"):
            if not ethereal_bridge.is_connected("memory_recorded", _on_ethereal_memory_recorded):
                ethereal_bridge.connect("memory_recorded", _on_ethereal_memory_recorded)
    else:
        connected = false
    
    # Optimize performance if available
    if performance_optimizer and performance_optimizer.has_method("allocate_thread"):
        # Allocate thread for memory operations
        performance_optimizer.allocate_thread("memory_connector", 7)
    
    emit_signal("memory_systems_connected")
    
    return connected

# ----- MEMORY SYNCHRONIZATION -----
func synchronize_memories():
    if not enabled or sync_in_progress:
        return false
    
    sync_in_progress = true
    
    # Allocate performance thread if available
    var thread_id = -1
    if performance_optimizer and performance_optimizer.has_method("allocate_thread"):
        thread_id = performance_optimizer.allocate_thread("memory_sync", 6)
    
    # Clear sync queues
    for system in sync_queues:
        sync_queues[system].clear()
    
    # Build sync queues
    _build_sync_queues()
    
    # Process sync queues
    var total_synced = _process_sync_queues()
    
    # Update sync stats
    var current_time = Time.get_unix_time_from_system()
    sync_stats.last_sync = current_time
    sync_stats.total_syncs += 1
    sync_stats.transferred_entries += total_synced
    
    # Release thread if allocated
    if thread_id >= 0 and performance_optimizer and performance_optimizer.has_method("release_thread"):
        performance_optimizer.release_thread(thread_id)
    
    sync_in_progress = false
    last_sync_time = current_time
    
    emit_signal("memories_synchronized", sync_stats)
    
    return true

func _build_sync_queues():
    # Build queue of memories to sync from each system to the others
    
    # 1. Local -> Ethereal/Akashic
    for memory_id in local_memories:
        var memory = local_memories[memory_id]
        
        # Check if this memory needs to be synced to other systems
        if not ethereal_memories.has(memory_id) or _is_memory_newer(memory, ethereal_memories.get(memory_id)):
            # Queue for sync to Ethereal
            sync_queues[MemorySystem.ETHEREAL].append(memory_id)
        
        if not akashic_memories.has(memory_id) or _is_memory_newer(memory, akashic_memories.get(memory_id)):
            # Queue for sync to Akashic
            sync_queues[MemorySystem.AKASHIC].append(memory_id)
    
    # 2. Ethereal -> Local/Akashic
    for memory_id in ethereal_memories:
        var memory = ethereal_memories[memory_id]
        
        # Check if this memory needs to be synced to other systems
        if not local_memories.has(memory_id) or _is_memory_newer(memory, local_memories.get(memory_id)):
            # Queue for sync to Local
            sync_queues[MemorySystem.LOCAL].append(memory_id)
        
        if not akashic_memories.has(memory_id) or _is_memory_newer(memory, akashic_memories.get(memory_id)):
            # Queue for sync to Akashic
            sync_queues[MemorySystem.AKASHIC].append(memory_id)
    
    # 3. Akashic -> Local/Ethereal
    for memory_id in akashic_memories:
        var memory = akashic_memories[memory_id]
        
        # Check if this memory needs to be synced to other systems
        if not local_memories.has(memory_id) or _is_memory_newer(memory, local_memories.get(memory_id)):
            # Queue for sync to Local
            if not sync_queues[MemorySystem.LOCAL].has(memory_id):
                sync_queues[MemorySystem.LOCAL].append(memory_id)
        
        if not ethereal_memories.has(memory_id) or _is_memory_newer(memory, ethereal_memories.get(memory_id)):
            # Queue for sync to Ethereal
            if not sync_queues[MemorySystem.ETHEREAL].has(memory_id):
                sync_queues[MemorySystem.ETHEREAL].append(memory_id)
    
    # Limit queue sizes
    for system in sync_queues:
        if sync_queues[system].size() > max_sync_entries:
            sync_queues[system] = sync_queues[system].slice(0, max_sync_entries)

func _process_sync_queues():
    var total_synced = 0
    
    # Process each system's queue
    for target_system in sync_queues:
        var queue = sync_queues[target_system]
        
        for memory_id in queue:
            # Find the most recent version of this memory
            var memory = _get_most_recent_memory(memory_id)
            
            if memory:
                # Sync this memory to the target system
                _sync_memory_to_system(memory, target_system)
                total_synced += 1
    
    return total_synced

func _get_most_recent_memory(memory_id):
    var most_recent = null
    
    # Check all three systems for this memory
    if local_memories.has(memory_id):
        most_recent = local_memories[memory_id]
    
    if ethereal_memories.has(memory_id):
        if most_recent == null or _is_memory_newer(ethereal_memories[memory_id], most_recent):
            most_recent = ethereal_memories[memory_id]
    
    if akashic_memories.has(memory_id):
        if most_recent == null or _is_memory_newer(akashic_memories[memory_id], most_recent):
            most_recent = akashic_memories[memory_id]
    
    return most_recent

func _sync_memory_to_system(memory, target_system):
    match target_system:
        MemorySystem.LOCAL:
            local_memories[memory.id] = memory
            _save_memory_to_file(memory, local_memory_path + memory.id + ".json")
        
        MemorySystem.ETHEREAL:
            ethereal_memories[memory.id] = memory
            _save_memory_to_file(memory, ethereal_memory_path + memory.id + ".json")
            
            # Also update Ethereal Bridge if available
            if ethereal_bridge and ethereal_bridge.has_method("record_memory"):
                ethereal_bridge.record_memory(
                    memory.content,
                    memory.has("tags") ? memory.tags : [],
                    memory.has("dimension") ? memory.dimension : ""
                )
        
        MemorySystem.AKASHIC:
            akashic_memories[memory.id] = memory
            _save_memory_to_file(memory, akashic_memory_path + memory.id + ".json")

func _save_memory_to_file(memory, file_path):
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if file:
        var json_string = JSON.stringify(memory, "  ")
        
        # Compress if above threshold size
        if json_string.length() > 1024 and memory_compression_level > 0:
            var compressed = _compress_memory_data(json_string)
            file.store_string("COMPRESSED:" + compressed)
            
            # Track compression savings
            var savings = 1.0 - (float(compressed.length()) / float(json_string.length()))
            sync_stats.compression_savings = (sync_stats.compression_savings + savings) / 2.0
        else:
            file.store_string(json_string)
        
        file.close()

# ----- CONFLICT HANDLING -----
func _detect_conflicts():
    memory_conflicts.clear()
    
    # Check for memories that exist in multiple systems with different content
    for memory_id in local_memories:
        var systems_with_memory = [MemorySystem.LOCAL]
        
        if ethereal_memories.has(memory_id):
            systems_with_memory.append(MemorySystem.ETHEREAL)
        
        if akashic_memories.has(memory_id):
            systems_with_memory.append(MemorySystem.AKASHIC)
        
        # If this memory exists in multiple systems, check for conflicts
        if systems_with_memory.size() > 1:
            var has_conflict = false
            var local_memory = local_memories[memory_id]
            
            if ethereal_memories.has(memory_id):
                var ethereal_memory = ethereal_memories[memory_id]
                
                if _has_content_conflict(local_memory, ethereal_memory):
                    has_conflict = true
            
            if akashic_memories.has(memory_id):
                var akashic_memory = akashic_memories[memory_id]
                
                if _has_content_conflict(local_memory, akashic_memory):
                    has_conflict = true
            
            if has_conflict:
                memory_conflicts.append({
                    "memory_id": memory_id,
                    "systems": systems_with_memory
                })
                
                emit_signal("memory_conflict_detected", memory_id, systems_with_memory)
    
    return memory_conflicts

func _has_content_conflict(memory1, memory2):
    # Check if two memories have conflicting content
    # This is a basic check that could be made more sophisticated
    
    if memory1.content != memory2.content:
        # Different content
        return true
    
    if memory1.has("tags") and memory2.has("tags") and memory1.tags != memory2.tags:
        # Different tags
        return true
    
    return false

func _resolve_conflicts():
    var resolved_count = 0
    
    for conflict in memory_conflicts:
        var memory_id = conflict.memory_id
        
        # Strategy: Use the most recent version
        var most_recent = _get_most_recent_memory(memory_id)
        
        if most_recent:
            # Sync to all systems
            _sync_memory_to_system(most_recent, MemorySystem.LOCAL)
            _sync_memory_to_system(most_recent, MemorySystem.ETHEREAL)
            _sync_memory_to_system(most_recent, MemorySystem.AKASHIC)
            
            resolved_count += 1
    
    sync_stats.conflicts_resolved += resolved_count
    memory_conflicts.clear()
    
    return resolved_count

# ----- WISH CONNECTION -----
func connect_wish_to_memories(wish_id, memory_ids):
    if not enabled:
        return false
    
    # Create wish connection
    connected_wishes[wish_id] = {
        "memory_ids": memory_ids,
        "connected_at": Time.get_unix_time_from_system(),
        "fulfilled": false,
        "fulfilled_by": ""
    }
    
    # Add connections to memories
    for memory_id in memory_ids:
        # Update Local
        if local_memories.has(memory_id):
            if not local_memories[memory_id].has("connected_wishes"):
                local_memories[memory_id].connected_wishes = []
            
            if not local_memories[memory_id].connected_wishes.has(wish_id):
                local_memories[memory_id].connected_wishes.append(wish_id)
            
            # Save updated memory
            _sync_memory_to_system(local_memories[memory_id], MemorySystem.LOCAL)
        
        # Update Ethereal
        if ethereal_memories.has(memory_id):
            if not ethereal_memories[memory_id].has("connected_wishes"):
                ethereal_memories[memory_id].connected_wishes = []
            
            if not ethereal_memories[memory_id].connected_wishes.has(wish_id):
                ethereal_memories[memory_id].connected_wishes.append(wish_id)
            
            # Save updated memory
            _sync_memory_to_system(ethereal_memories[memory_id], MemorySystem.ETHEREAL)
        
        # Update Akashic
        if akashic_memories.has(memory_id):
            if not akashic_memories[memory_id].has("connected_wishes"):
                akashic_memories[memory_id].connected_wishes = []
            
            if not akashic_memories[memory_id].connected_wishes.has(wish_id):
                akashic_memories[memory_id].connected_wishes.append(wish_id)
            
            # Save updated memory
            _sync_memory_to_system(akashic_memories[memory_id], MemorySystem.AKASHIC)
    
    emit_signal("wish_connected", wish_id, memory_ids)
    
    return true

func fulfill_wish_with_memory(wish_id, memory_id):
    if not enabled or not connected_wishes.has(wish_id):
        return false
    
    # Mark wish as fulfilled
    connected_wishes[wish_id].fulfilled = true
    connected_wishes[wish_id].fulfilled_by = memory_id
    
    # Add to wish completions
    wish_completions[wish_id] = {
        "memory_id": memory_id,
        "fulfilled_at": Time.get_unix_time_from_system()
    }
    
    # Update Memory System if available
    if memory_system and memory_system.has_method("fulfill_wish"):
        var memory = _get_memory_by_id(memory_id)
        if memory:
            memory_system.fulfill_wish(wish_id, memory.content)
    
    emit_signal("wish_fulfilled", wish_id, memory_id)
    
    return true

func _get_memory_by_id(memory_id):
    # Try all three memory systems
    if local_memories.has(memory_id):
        return local_memories[memory_id]
    
    if ethereal_memories.has(memory_id):
        return ethereal_memories[memory_id]
    
    if akashic_memories.has(memory_id):
        return akashic_memories[memory_id]
    
    return null

# ----- UTILITY FUNCTIONS -----
func _is_memory_newer(memory1, memory2):
    if not memory2:
        return true
    
    # Compare timestamps
    var timestamp1 = memory1.get("timestamp", 0)
    var timestamp2 = memory2.get("timestamp", 0)
    
    return timestamp1 > timestamp2

func _compress_memory_data(data):
    # A very simple compression scheme - not for actual use
    # In a real implementation, this would use proper compression
    
    # For the sake of this exercise, we'll just simulate compression
    # by creating a mock compressed string that's shorter
    
    # In a real implementation, you would use the compression level like:
    # return data.compress(memory_compression_level)
    
    return "COMPRESSED_DATA:" + str(data.length()) + ":" + data.substr(0, 100) + "..."

func _decompress_memory_data(compressed_data):
    # Since our compression is just a mock, this is also a mock decompression
    # that just extracts the original data length and returns a mock string
    
    var parts = compressed_data.split(":", true, 2)
    if parts.size() >= 3 and parts[0] == "COMPRESSED_DATA":
        var original_length = int(parts[1])
        
        # In a real implementation, you would decompress the data
        # return compressed_data.decompress()
        
        # For this mock, we'll just return what's left after the prefix
        return parts[2].replace("...", "[...additional " + str(original_length - 100) + " characters...]")
    
    return compressed_data

func _cleanup_unused_memories():
    # In a real implementation, this would remove old memories
    # based on age, relevance, etc.
    
    # For this exercise, we'll just log that it happened
    print("Memory cleanup performed")

# ----- EVENT HANDLERS -----
func _on_sync_timer_timeout():
    if not enabled:
        return
    
    # Don't sync too frequently
    var current_time = Time.get_unix_time_from_system()
    if current_time - last_sync_time < synchronize_frequency:
        return
    
    # Detect and resolve conflicts
    if _detect_conflicts().size() > 0:
        _resolve_conflicts()
    
    # Synchronize memories
    synchronize_memories()

func _on_cleanup_timer_timeout():
    if not enabled:
        return
    
    _cleanup_unused_memories()

func _on_memory_stored(memory_id, content):
    # Memory was stored in the Memory System
    if not local_memories.has(memory_id) and memory_system and memory_system.has_method("retrieve_memory"):
        var memory = memory_system.retrieve_memory(memory_id)
        if memory:
            local_memories[memory_id] = memory
            _sync_memory_to_system(memory, MemorySystem.LOCAL)
    
    # Check for wish fulfillment
    _check_wish_fulfillment_by_content(content)

func _on_wish_added(wish_id, content):
    # Find related memories for this wish
    var related_memories = _find_memories_related_to_content(content)
    
    if related_memories.size() > 0:
        connect_wish_to_memories(wish_id, related_memories)

func _on_wish_fulfilled(wish_id, content):
    if connected_wishes.has(wish_id):
        connected_wishes[wish_id].fulfilled = true
    
    # Create a new memory for this fulfillment
    if memory_system and memory_system.has_method("store_memory"):
        var tags = ["wish_fulfillment", "wish:" + wish_id]
        var memory_id = memory_system.store_memory("Wish fulfilled: " + content, tags, "fulfillment")
        
        wish_completions[wish_id] = {
            "memory_id": memory_id,
            "fulfilled_at": Time.get_unix_time_from_system()
        }

func _on_ethereal_memory_recorded(content, dimension):
    # Memory was recorded in Ethereal Bridge
    if ethereal_bridge and ethereal_bridge.has_method("search_akashic_records"):
        var results = ethereal_bridge.search_akashic_records(content, dimension)
        
        for result in results:
            if result.has("memory_id") and not ethereal_memories.has(result.memory_id):
                var memory = {
                    "id": result.memory_id,
                    "content": result.content,
                    "tags": result.has("tags") ? result.tags : [],
                    "dimension": result.has("dimension") ? result.dimension : "",
                    "timestamp": result.has("timestamp") ? result.timestamp : Time.get_unix_time_from_system()
                }
                
                ethereal_memories[result.memory_id] = memory
                _sync_memory_to_system(memory, MemorySystem.ETHEREAL)
    
    # Check for wish fulfillment
    _check_wish_fulfillment_by_content(content)

func _check_wish_fulfillment_by_content(content):
    # Check if this content fulfills any wishes
    for wish_id in connected_wishes:
        var wish = connected_wishes[wish_id]
        
        if not wish.fulfilled:
            # Create a memory for this content
            var memory_id = ""
            
            if memory_system and memory_system.has_method("store_memory"):
                var tags = ["potential_fulfillment", "wish:" + wish_id]
                memory_id = memory_system.store_memory(content, tags, "fulfillment_check")
            
            # Add connection
            if not memory_id.is_empty():
                fulfill_wish_with_memory(wish_id, memory_id)

func _find_memories_related_to_content(content):
    var related_ids = []
    
    # Simple word matching - in a real implementation, this would be more sophisticated
    var content_words = content.to_lower().split(" ", false)
    
    # Search Local memories
    for memory_id in local_memories:
        var memory = local_memories[memory_id]
        var memory_content = memory.content.to_lower()
        
        var matches = 0
        for word in content_words:
            if word.length() > 3 and memory_content.find(word) >= 0:
                matches += 1
        
        if matches >= 2 or memory_content.find(content.to_lower()) >= 0:
            related_ids.append(memory_id)
    
    // Limit number of related memories
    if related_ids.size() > 5:
        related_ids = related_ids.slice(0, 5)
    
    return related_ids

# ----- PUBLIC API -----
func toggle_connector(enabled_state: bool):
    enabled = enabled_state
    return enabled

func set_sync_frequency(frequency: float):
    if frequency <= 0:
        return false
    
    synchronize_frequency = frequency
    sync_timer.wait_time = frequency
    return true

func set_compression_level(level: int):
    memory_compression_level = clamp(level, 0, 9)
    return memory_compression_level

func get_memory_counts():
    return {
        "local": local_memories.size(),
        "ethereal": ethereal_memories.size(),
        "akashic": akashic_memories.size(),
        "total_unique": _count_unique_memories()
    }

func _count_unique_memories():
    var unique_ids = {}
    
    for memory_id in local_memories:
        unique_ids[memory_id] = true
    
    for memory_id in ethereal_memories:
        unique_ids[memory_id] = true
    
    for memory_id in akashic_memories:
        unique_ids[memory_id] = true
    
    return unique_ids.size()

func get_sync_statistics():
    return sync_stats.duplicate()

func force_synchronization():
    return synchronize_memories()

func get_connected_wish_count():
    return connected_wishes.size()

func get_fulfilled_wish_count():
    var count = 0
    
    for wish_id in connected_wishes:
        if connected_wishes[wish_id].fulfilled:
            count += 1
    
    return count