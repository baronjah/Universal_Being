extends Node
class_name WordMemorySystem

# ------------------------------------
# WordMemorySystem - Memory and persistence system for World of Words
# Records, stores, and recalls word data across sessions
# ------------------------------------

# Storage constants
const SAVE_FILE_PATH = "user://word_memory_system.json"
const BACKUP_PATH = "user://word_memory_system.backup.json" 
const MAX_HISTORY_ENTRIES = 1000
const MAX_CONNECTIONS_PER_WORD = 20
const AUTO_SAVE_INTERVAL = 300 # 5 minutes

# Compression options
const COMPRESSED_SAVE = true
const COMPRESSION_MODE = File.COMPRESSION_ZSTD

# Memory state
var message_history = []
var word_memories = {}  # Dictionary of word_id -> memory data
var dimension_memories = {}  # Dictionary of dimension -> state data
var last_save_time = 0
var auto_save_timer = null
var memory_enabled = true
var memory_allocated = 0

# Word Drive reference
var word_drive = null

# Signal declarations
signal memory_updated(word_id, memory_data)
signal memory_saved
signal memory_loaded
signal word_remembered(word_id, memory_quality)

# Initialize the memory system
func _ready():
    print("WordMemorySystem initialized")
    
    # Setup auto-save timer
    auto_save_timer = Timer.new()
    auto_save_timer.wait_time = AUTO_SAVE_INTERVAL
    auto_save_timer.one_shot = false
    auto_save_timer.connect("timeout", self, "_on_auto_save_timer")
    add_child(auto_save_timer)
    
    if memory_enabled:
        auto_save_timer.start()

# Record a word message to memory
func record_word_message(message):
    if not memory_enabled:
        return
    
    # Add message to history
    message_history.append(message)
    
    # Trim history if needed
    if message_history.size() > MAX_HISTORY_ENTRIES:
        message_history.pop_front()
    
    # Process message based on type
    var msg_type = message.type
    var payload = message.payload
    
    match msg_type:
        "word_create":
            _record_word_creation(payload, message.timestamp)
        "word_update":
            _record_word_update(payload, message.timestamp)
        "word_delete":
            _record_word_deletion(payload, message.timestamp)
        "connection_create":
            _record_connection_creation(payload, message.timestamp)
        "dimension_change":
            _record_dimension_change(payload, message.timestamp)

# Record word creation
func _record_word_creation(payload, timestamp):
    if not payload.has("id"):
        return
    
    var word_id = payload.id
    
    # Initialize memory entry if it doesn't exist
    if not word_memories.has(word_id):
        word_memories[word_id] = {
            "id": word_id,
            "text": payload.get("text", ""),
            "creation_time": timestamp,
            "last_update_time": timestamp,
            "times_updated": 0,
            "times_connected": 0,
            "connections": [],
            "evolution_history": [],
            "dimension_history": [],
            "power_history": [],
            "creation_context": {
                "dimension": payload.get("dimension", "3D"),
                "turn": payload.get("turn", 1),
                "creator": payload.get("creator", "system")
            }
        }
    
    # Record initial power
    if payload.has("power"):
        word_memories[word_id].power_history.append({
            "timestamp": timestamp,
            "power": payload.power,
            "source": "creation"
        })
    
    # Record initial dimension
    if payload.has("dimension"):
        word_memories[word_id].dimension_history.append({
            "timestamp": timestamp,
            "dimension": payload.dimension
        })
    
    # Update memory allocation estimate
    _update_memory_allocation()
    
    # Emit signal
    emit_signal("memory_updated", word_id, word_memories[word_id])

# Record word update
func _record_word_update(payload, timestamp):
    if not payload.has("id") or not word_memories.has(payload.id):
        return
    
    var word_id = payload.id
    var memory = word_memories[word_id]
    
    # Update last update time
    memory.last_update_time = timestamp
    memory.times_updated += 1
    
    # Record power change
    if payload.has("power"):
        memory.power_history.append({
            "timestamp": timestamp,
            "power": payload.power,
            "source": "update"
        })
    
    # Record evolution
    if payload.has("evolution_stage") and (
        memory.evolution_history.empty() or 
        memory.evolution_history[memory.evolution_history.size() - 1].stage != payload.evolution_stage
    ):
        memory.evolution_history.append({
            "timestamp": timestamp,
            "stage": payload.evolution_stage,
            "context": payload.get("evolution_context", {})
        })
    
    # Record dimension change
    if payload.has("dimension") and (
        memory.dimension_history.empty() or 
        memory.dimension_history[memory.dimension_history.size() - 1].dimension != payload.dimension
    ):
        memory.dimension_history.append({
            "timestamp": timestamp,
            "dimension": payload.dimension
        })
    
    # Emit signal
    emit_signal("memory_updated", word_id, memory)

# Record word deletion
func _record_word_deletion(payload, timestamp):
    if not payload.has("id") or not word_memories.has(payload.id):
        return
    
    var word_id = payload.id
    var memory = word_memories[word_id]
    
    # Record deletion time
    memory.deletion_time = timestamp
    memory.deleted = true
    
    # Keep memory entry for historical purposes
    
    # Update memory allocation estimate
    _update_memory_allocation()
    
    # Emit signal
    emit_signal("memory_updated", word_id, memory)

# Record connection creation
func _record_connection_creation(payload, timestamp):
    if not payload.has("from_id") or not payload.has("to_id"):
        return
    
    var from_id = payload.from_id
    var to_id = payload.to_id
    
    # Skip if either word doesn't have a memory entry
    if not word_memories.has(from_id) or not word_memories.has(to_id):
        return
    
    # Record connection in both words
    _add_connection_to_word(from_id, to_id, payload, timestamp)
    _add_connection_to_word(to_id, from_id, payload, timestamp)
    
    # Update connection counts
    word_memories[from_id].times_connected += 1
    word_memories[to_id].times_connected += 1
    
    # Emit signals
    emit_signal("memory_updated", from_id, word_memories[from_id])
    emit_signal("memory_updated", to_id, word_memories[to_id])

# Record dimension change
func _record_dimension_change(payload, timestamp):
    if not payload.has("dimension"):
        return
    
    var dimension = payload.dimension
    
    # Record dimension state
    dimension_memories[dimension] = {
        "last_active": timestamp,
        "times_visited": dimension_memories.get(dimension, {}).get("times_visited", 0) + 1,
        "properties": payload.get("properties", {})
    }
    
    # Update current dimension for all active words
    if word_drive:
        var active_words = word_drive.get_all_words()
        for word_id in active_words:
            if word_memories.has(word_id):
                var memory = word_memories[word_id]
                
                # Record dimension change if different from last
                if memory.dimension_history.empty() or 
                   memory.dimension_history[memory.dimension_history.size() - 1].dimension != dimension:
                    memory.dimension_history.append({
                        "timestamp": timestamp,
                        "dimension": dimension
                    })
                
                # Emit signal
                emit_signal("memory_updated", word_id, memory)

# Add connection to word memory
func _add_connection_to_word(word_id, connected_id, connection_data, timestamp):
    var memory = word_memories[word_id]
    
    # Check if this connection already exists
    for conn in memory.connections:
        if conn.target_id == connected_id:
            # Update existing connection
            conn.last_update_time = timestamp
            conn.times_updated += 1
            if connection_data.has("strength"):
                conn.strength = connection_data.strength
            return
    
    # Add new connection
    var connection_entry = {
        "target_id": connected_id,
        "creation_time": timestamp,
        "last_update_time": timestamp,
        "times_updated": 0,
        "strength": connection_data.get("strength", 1.0),
        "connection_id": connection_data.get("id", "")
    }
    
    memory.connections.append(connection_entry)
    
    # Limit connections to prevent excessive memory usage
    if memory.connections.size() > MAX_CONNECTIONS_PER_WORD:
        # Sort by strength and recency
        memory.connections.sort_custom(self, "_sort_connections_by_importance")
        
        # Remove least important connections
        while memory.connections.size() > MAX_CONNECTIONS_PER_WORD:
            memory.connections.pop_back()

# Sorting function for connections
func _sort_connections_by_importance(a, b):
    # Calculate importance score (blend of strength and recency)
    var now = OS.get_unix_time()
    var recency_a = 1.0 / (1.0 + (now - a.last_update_time) / 86400.0) # Decay over days
    var recency_b = 1.0 / (1.0 + (now - b.last_update_time) / 86400.0)
    
    var score_a = a.strength * 0.7 + recency_a * 0.3
    var score_b = b.strength * 0.7 + recency_b * 0.3
    
    return score_a > score_b

# Update memory allocation estimate
func _update_memory_allocation():
    var allocation = 0
    
    # Estimate message history size
    allocation += message_history.size() * 200 # Rough estimate per message
    
    # Estimate word memories size
    for word_id in word_memories:
        var memory = word_memories[word_id]
        
        # Base memory size
        var word_size = 100
        
        # Add size for text
        word_size += memory.text.length() * 2
        
        # Add size for history arrays
        word_size += memory.evolution_history.size() * 50
        word_size += memory.dimension_history.size() * 30
        word_size += memory.power_history.size() * 30
        word_size += memory.connections.size() * 80
        
        allocation += word_size
    }
    
    # Estimate dimension memories size
    allocation += dimension_memories.size() * 100
    
    memory_allocated = allocation
    
    # Report to word drive if available
    if word_drive:
        word_drive.send_message("system_status_update", {
            "memory_allocation": memory_allocated
        })

# Save system state
func save_system_state(current_turn = 1, current_dimension = "3D"):
    if not memory_enabled:
        return false
    
    # Create backup of existing save
    _create_backup()
    
    # Prepare save data
    var save_data = {
        "version": "1.0.0",
        "timestamp": OS.get_unix_time(),
        "current_turn": current_turn,
        "current_dimension": current_dimension,
        "word_memories": word_memories,
        "dimension_memories": dimension_memories,
        "memory_allocated": memory_allocated
    }
    
    # Try to save file
    var file = File.new()
    var err
    
    if COMPRESSED_SAVE:
        err = file.open_compressed(SAVE_FILE_PATH, File.WRITE, COMPRESSION_MODE)
    else:
        err = file.open(SAVE_FILE_PATH, File.WRITE)
    
    if err != OK:
        push_warning("WordMemorySystem: Failed to open save file")
        return false
    
    # Write data
    file.store_string(JSON.print(save_data, "  "))
    file.close()
    
    # Update last save time
    last_save_time = OS.get_unix_time()
    
    # Emit signal
    emit_signal("memory_saved")
    
    return true

# Load system state
func load_system_state():
    if not memory_enabled:
        return false
    
    var file = File.new()
    if not file.file_exists(SAVE_FILE_PATH):
        return false
    
    var err
    
    if COMPRESSED_SAVE:
        err = file.open_compressed(SAVE_FILE_PATH, File.READ, COMPRESSION_MODE)
    else:
        err = file.open(SAVE_FILE_PATH, File.READ)
    
    if err != OK:
        push_warning("WordMemorySystem: Failed to open save file")
        return false
    
    var text = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(text)
    if parse_result.error != OK:
        push_warning("WordMemorySystem: Failed to parse save file")
        return false
    
    var save_data = parse_result.result
    
    # Check version compatibility
    if not save_data.has("version") or not save_data.has("word_memories"):
        push_warning("WordMemorySystem: Invalid save file format")
        return false
    
    # Load memories
    word_memories = save_data.word_memories
    dimension_memories = save_data.dimension_memories
    memory_allocated = save_data.get("memory_allocated", 0)
    
    # Emit signal
    emit_signal("memory_loaded")
    
    return true

# Create backup of save file
func _create_backup():
    var src_file = File.new()
    var dst_file = File.new()
    
    if not src_file.file_exists(SAVE_FILE_PATH):
        return
    
    var src_err
    var dst_err
    
    if COMPRESSED_SAVE:
        src_err = src_file.open_compressed(SAVE_FILE_PATH, File.READ, COMPRESSION_MODE)
        dst_err = dst_file.open_compressed(BACKUP_PATH, File.WRITE, COMPRESSION_MODE)
    else:
        src_err = src_file.open(SAVE_FILE_PATH, File.READ)
        dst_err = dst_file.open(BACKUP_PATH, File.WRITE)
    
    if src_err != OK or dst_err != OK:
        if src_file.is_open():
            src_file.close()
        if dst_file.is_open():
            dst_file.close()
        return
    
    # Copy contents
    dst_file.store_string(src_file.get_as_text())
    
    src_file.close()
    dst_file.close()

# Clear memory
func clear_memory():
    message_history.clear()
    word_memories.clear()
    dimension_memories.clear()
    memory_allocated = 0
    
    # Emit signals
    emit_signal("memory_updated", "", {})

# Get current turn from saved data
func get_current_turn():
    var file = File.new()
    if not file.file_exists(SAVE_FILE_PATH):
        return 1
    
    var err
    
    if COMPRESSED_SAVE:
        err = file.open_compressed(SAVE_FILE_PATH, File.READ, COMPRESSION_MODE)
    else:
        err = file.open(SAVE_FILE_PATH, File.READ)
    
    if err != OK:
        return 1
    
    var text = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(text)
    if parse_result.error != OK:
        return 1
    
    var save_data = parse_result.result
    
    return save_data.get("current_turn", 1)

# Get current dimension from saved data
func get_current_dimension():
    var file = File.new()
    if not file.file_exists(SAVE_FILE_PATH):
        return "3D"
    
    var err
    
    if COMPRESSED_SAVE:
        err = file.open_compressed(SAVE_FILE_PATH, File.READ, COMPRESSION_MODE)
    else:
        err = file.open(SAVE_FILE_PATH, File.READ)
    
    if err != OK:
        return "3D"
    
    var text = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(text)
    if parse_result.error != OK:
        return "3D"
    
    var save_data = parse_result.result
    
    return save_data.get("current_dimension", "3D")

# Get last save time
func get_last_save_time():
    return last_save_time

# Set memory enabled state
func set_memory_enabled(enabled):
    memory_enabled = enabled
    
    if enabled:
        auto_save_timer.start()
    else:
        auto_save_timer.stop()

# Get word memory
func get_word_memory(word_id):
    if word_memories.has(word_id):
        return word_memories[word_id]
    return null

# Get recent word memories (for a context window)
func get_recent_memories(count = 10):
    var memories = []
    var word_ids = word_memories.keys()
    
    # Sort by last update time
    word_ids.sort_custom(self, "_sort_words_by_recency")
    
    # Take most recent
    for i in range(min(count, word_ids.size())):
        memories.append(word_memories[word_ids[i]])
    
    return memories

# Sorting function for words by recency
func _sort_words_by_recency(a, b):
    if not word_memories.has(a) or not word_memories.has(b):
        return false
    
    return word_memories[a].last_update_time > word_memories[b].last_update_time

# Handle auto-save timeout
func _on_auto_save_timer():
    if memory_enabled and word_drive:
        # Get current turn and dimension from WordDrive
        var system_status = null
        word_drive.send_message("system_command", {
            "command": "system_status_request",
            "callback": funcref(self, "_receive_system_status")
        })

# Callback for system status
func _receive_system_status(status):
    if status:
        save_system_state(status.current_turn, status.current_dimension)

# Remember a word (attempt to recall from memory)
func remember_word(word_text):
    var matches = []
    
    # Look for exact and partial matches
    for word_id in word_memories:
        var memory = word_memories[word_id]
        
        if memory.text.to_lower() == word_text.to_lower():
            # Exact match
            emit_signal("word_remembered", word_id, 1.0)
            return memory
        elif memory.text.to_lower().find(word_text.to_lower()) >= 0 or word_text.to_lower().find(memory.text.to_lower()) >= 0:
            # Partial match
            matches.append({
                "memory": memory,
                "quality": _calculate_match_quality(word_text, memory.text)
            })
        }
    }
    
    # If we found partial matches, return the best one
    if matches.size() > 0:
        # Sort by match quality
        matches.sort_custom(self, "_sort_matches_by_quality")
        
        var best_match = matches[0]
        emit_signal("word_remembered", best_match.memory.id, best_match.quality)
        return best_match.memory
    }
    
    # No matches found
    return null

# Calculate match quality between two strings
func _calculate_match_quality(str1, str2):
    var s1 = str1.to_lower()
    var s2 = str2.to_lower()
    
    # Simple containment check
    if s1 == s2:
        return 1.0
    elif s1.find(s2) >= 0:
        return 0.8 * (float(s2.length()) / s1.length())
    elif s2.find(s1) >= 0:
        return 0.8 * (float(s1.length()) / s2.length())
    
    # Check for partial match
    var common_length = 0
    var min_length = min(s1.length(), s2.length())
    
    for i in range(min_length):
        if s1[i] == s2[i]:
            common_length += 1
        else:
            break
    
    return float(common_length) / min_length * 0.6

# Sorting function for matches by quality
func _sort_matches_by_quality(a, b):
    return a.quality > b.quality

# Connect to WordDrive
func connect_to_word_drive(drive):
    word_drive = drive
    
    if word_drive:
        word_drive.connect("word_message_sent", self, "_on_word_message")
        
        # Register with WordDrive
        word_drive.send_message("system_command", {
            "command": "set_memory_system",
            "system": self
        })