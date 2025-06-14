extends Node
class_name WorldOfWords

# ------------------------------------
# WorldOfWords - Main controller and integration point for the World of Words system
# Initializes and manages all components of the system
# ------------------------------------

# Child components
var word_drive = null
var word_processor = null
var word_visualizer = null
var physics_engine = null
var memory_system = null
var connection_manager = null

# System state
var is_initialized = false
var current_turn = 1
var current_dimension = "3D"
var auto_physics_enabled = true
var system_ready = false

# Constants
const VERSION = "1.0.0"
const SUPPORTED_DIMENSIONS = ["1D", "2D", "3D", "4D", "5D", "6D", "7D"]
const MAX_TURN = 12
const AUTO_SAVE_INTERVAL = 300 # 5 minutes

# Timer for auto-save
var auto_save_timer = null
var last_activity_time = 0

# Configuration
var config = {
    "visualization_enabled": true,
    "physics_enabled": true,
    "memory_enabled": true,
    "connection_auto_discovery": true,
    "max_words_per_dimension": 100,
    "auto_save_enabled": true,
    "debug_mode": false
}

# Signal declarations
signal system_initialized
signal turn_changed(turn_number)
signal dimension_changed(dimension)
signal config_updated(config)
signal system_status_updated(status)
signal word_created(word_id, word_data)
signal word_deleted(word_id)
signal log_message(level, message)

# Initialize the system
func _ready():
    print("WorldOfWords initializing (v%s)" % VERSION)
    
    # Create and setup components
    _create_components()
    _connect_signals()
    
    # Setup auto-save timer
    auto_save_timer = Timer.new()
    auto_save_timer.wait_time = AUTO_SAVE_INTERVAL
    auto_save_timer.one_shot = false
    auto_save_timer.connect("timeout", self, "_on_auto_save_timer_timeout")
    add_child(auto_save_timer)
    
    # Initialize data structures
    _load_or_initialize_data()
    
    is_initialized = true
    system_ready = true
    
    emit_signal("system_initialized")
    emit_signal("log_message", "info", "World of Words system initialized (v%s)" % VERSION)

# Physics process function
func _physics_process(delta):
    if not system_ready or not auto_physics_enabled:
        return
    
    # Update physics if enabled
    if config.physics_enabled and physics_engine:
        physics_engine.process_physics(delta)

# Create system components
func _create_components():
    # Create WordDrive (central message bus)
    word_drive = WordDrive.new()
    word_drive.name = "WordDrive"
    add_child(word_drive)
    
    # Create WordProcessor
    word_processor = WordProcessor.new()
    word_processor.name = "WordProcessor"
    add_child(word_processor)
    
    # Create physics engine
    physics_engine = WordPhysics.new()
    physics_engine.name = "WordPhysics"
    add_child(physics_engine)
    
    # Create connection manager
    connection_manager = WordConnectionManager.new()
    connection_manager.name = "ConnectionManager"
    add_child(connection_manager)
    
    # Create memory system
    memory_system = WordMemorySystem.new()
    memory_system.name = "MemorySystem"
    add_child(memory_system)
    
    # Create word visualizer
    word_visualizer = WordVisualizer.new()
    word_visualizer.name = "WordVisualizer"
    add_child(word_visualizer)

# Connect component signals
func _connect_signals():
    # Connect WordDrive signals
    word_drive.connect("word_message_sent", self, "_on_word_message_sent")
    word_drive.connect("word_dimension_changed", self, "_on_dimension_changed")
    
    # Connect WordProcessor signals
    word_processor.connect("word_processed", self, "_on_word_processed")
    word_processor.connect("database_updated", self, "_on_database_updated")
    
    # Connect WordVisualizer signals
    word_visualizer.connect("word_clicked", self, "_on_word_clicked")
    word_visualizer.connect("dimension_changed", self, "_on_visualizer_dimension_changed")
    
    # Connect component references
    word_processor.connect_to_word_drive(word_drive)
    word_visualizer.connect_to_word_drive(word_drive)
    physics_engine.connect_to_word_drive(word_drive)
    connection_manager.connect_to_word_drive(word_drive)
    memory_system.connect_to_word_drive(word_drive)
    
    # Register components with WordDrive
    word_drive.send_message("system_command", {
        "command": "set_word_processor", 
        "processor": word_processor
    })
    
    word_drive.send_message("system_command", {
        "command": "set_physics_engine", 
        "engine": physics_engine
    })
    
    word_drive.send_message("system_command", {
        "command": "set_connection_manager", 
        "manager": connection_manager
    })
    
    word_drive.send_message("system_command", {
        "command": "set_memory_system", 
        "system": memory_system
    })

# Load or initialize data
func _load_or_initialize_data():
    # Try to load saved state
    var save_loaded = memory_system.load_system_state()
    
    if not save_loaded:
        # Initialize with default state
        current_turn = 1
        current_dimension = "3D"
        
        # Apply initial dimension
        change_dimension(current_dimension)
        
        # Load word database
        word_processor.set_turn(current_turn)
        word_processor.set_dimension(current_dimension)
    else:
        # Apply loaded state
        current_turn = memory_system.get_current_turn()
        current_dimension = memory_system.get_current_dimension()
        
        # Apply loaded dimension
        change_dimension(current_dimension)
        
        # Update processor
        word_processor.set_turn(current_turn)
        word_processor.set_dimension(current_dimension)
    
    # Start auto-save timer if enabled
    if config.auto_save_enabled:
        auto_save_timer.start()

# Public API: Create a new word
func create_word(text, properties = {}):
    if not is_initialized:
        return null
    
    # Record last activity time
    last_activity_time = OS.get_unix_time()
    
    # Process through the word processor
    var processed = word_processor.process_word(text, {
        "dimension": current_dimension,
        "turn": current_turn
    })
    
    # Merge processed results with properties
    for key in processed:
        if not properties.has(key):
            properties[key] = processed[key]
    
    # Add through WordDrive
    var word_id = word_drive.create_word(text, properties)
    
    # Get the created word data
    var word_data = word_drive.get_word(word_id)
    
    # Emit signal
    emit_signal("word_created", word_id, word_data)
    emit_signal("log_message", "info", "Created word: '%s' with power %d" % [text, word_data.power])
    
    return word_id

# Public API: Delete a word
func delete_word(word_id):
    if not is_initialized:
        return false
    
    # Record last activity time
    last_activity_time = OS.get_unix_time()
    
    var word_data = word_drive.get_word(word_id)
    var success = word_drive.delete_word(word_id)
    
    if success:
        emit_signal("word_deleted", word_id)
        emit_signal("log_message", "info", "Deleted word: '%s'" % (word_data.text if word_data else word_id))
    
    return success

# Public API: Connect two words
func connect_words(from_id, to_id, properties = {}):
    if not is_initialized:
        return null
    
    # Record last activity time
    last_activity_time = OS.get_unix_time()
    
    # Get word data
    var from_word = word_drive.get_word(from_id)
    var to_word = word_drive.get_word(to_id)
    
    if not from_word or not to_word:
        emit_signal("log_message", "error", "Cannot connect: One or both words don't exist")
        return null
    
    # Calculate connection strength if not provided
    if not properties.has("strength"):
        properties.strength = word_processor.calculate_affinity(from_word.text, to_word.text)
    
    # Create connection through WordDrive
    var connection_id = word_drive.connect_words(from_id, to_id, properties)
    
    emit_signal("log_message", "info", "Connected words: '%s' and '%s'" % [from_word.text, to_word.text])
    
    return connection_id

# Public API: Change the current dimension
func change_dimension(dimension):
    if not is_initialized or not SUPPORTED_DIMENSIONS.has(dimension):
        return false
    
    # Record last activity time
    last_activity_time = OS.get_unix_time()
    
    # Set current dimension
    current_dimension = dimension
    
    # Update processor
    word_processor.set_dimension(dimension)
    
    # Update through WordDrive
    word_drive.change_dimension(dimension)
    
    emit_signal("dimension_changed", dimension)
    emit_signal("log_message", "info", "Changed to dimension: %s" % dimension)
    
    return true

# Public API: Advance to the next turn
func advance_turn():
    if not is_initialized:
        return false
    
    if current_turn >= MAX_TURN:
        emit_signal("log_message", "warning", "Already at maximum turn (%d)" % MAX_TURN)
        return false
    
    # Record last activity time
    last_activity_time = OS.get_unix_time()
    
    // Save current state
    save_system_state()
    
    // Increment turn
    current_turn += 1
    
    // Update processor
    word_processor.set_turn(current_turn)
    
    // Update through WordDrive
    word_drive.send_message("system_command", {
        "command": "change_turn",
        "turn": current_turn
    })
    
    emit_signal("turn_changed", current_turn)
    emit_signal("log_message", "info", "Advanced to turn %d" % current_turn)
    
    return true

# Public API: Save system state
func save_system_state():
    if not is_initialized or not memory_system:
        return false
    
    var saved = memory_system.save_system_state(current_turn, current_dimension)
    
    if saved:
        emit_signal("log_message", "info", "System state saved")
    else:
        emit_signal("log_message", "error", "Failed to save system state")
    
    return saved

# Public API: Load system state
func load_system_state():
    if not is_initialized or not memory_system:
        return false
    
    var loaded = memory_system.load_system_state()
    
    if loaded:
        current_turn = memory_system.get_current_turn()
        current_dimension = memory_system.get_current_dimension()
        
        // Update processor
        word_processor.set_turn(current_turn)
        word_processor.set_dimension(current_dimension)
        
        // Update dimension
        change_dimension(current_dimension)
        
        emit_signal("turn_changed", current_turn)
        emit_signal("log_message", "info", "System state loaded")
    else:
        emit_signal("log_message", "warning", "No saved state to load")
    
    return loaded

# Public API: Get all words
func get_all_words():
    if not is_initialized:
        return {}
    
    return word_drive.get_all_words()

# Public API: Get all connections
func get_all_connections():
    if not is_initialized:
        return {}
    
    return word_drive.get_all_connections()

# Public API: Search for words
func search_words(query):
    if not is_initialized:
        return []
    
    return word_drive.search_words(query)

# Public API: Get similar words
func get_similar_words(word_text, limit = 5):
    if not is_initialized:
        return []
    
    return word_processor.find_similar_words(word_text, limit)

# Public API: Update configuration
func update_config(new_config):
    if not is_initialized:
        return false
    
    // Apply changes
    for key in new_config:
        if config.has(key):
            config[key] = new_config[key]
    
    // Apply configuration changes to components
    word_visualizer.set_visualization_enabled(config.visualization_enabled)
    physics_engine.set_physics_enabled(config.physics_enabled)
    memory_system.set_memory_enabled(config.memory_enabled)
    connection_manager.set_auto_discovery(config.connection_auto_discovery)
    
    // Update auto-save
    if config.auto_save_enabled:
        auto_save_timer.start()
    else:
        auto_save_timer.stop()
    
    emit_signal("config_updated", config)
    emit_signal("log_message", "info", "Configuration updated")
    
    return true

# Public API: Get system status
func get_system_status():
    if not is_initialized:
        return {
            "initialized": false,
            "version": VERSION
        }
    
    var word_drive_status = word_drive.get_system_status()
    
    var status = {
        "initialized": is_initialized,
        "version": VERSION,
        "current_turn": current_turn,
        "current_dimension": current_dimension,
        "word_count": word_drive.get_all_words().size(),
        "connection_count": word_drive.get_all_connections().size(),
        "memory_allocated": word_drive_status.memory_allocated,
        "last_activity_time": last_activity_time,
        "uptime": OS.get_unix_time() - word_drive_status.last_activity_timestamp,
        "config": config
    }
    
    emit_signal("system_status_updated", status)
    
    return status

# Signal handlers
func _on_word_message_sent(msg_type, payload, source):
    // Update last activity time
    last_activity_time = OS.get_unix_time()

func _on_dimension_changed(dimension, properties):
    current_dimension = dimension

func _on_word_processed(word_text, result):
    if config.debug_mode:
        print("Word processed: %s (Power: %d)" % [word_text, result.power])

func _on_database_updated():
    if config.debug_mode:
        print("Word database updated")

func _on_word_clicked(word_id, word_data):
    if config.debug_mode:
        print("Word clicked: %s" % word_data.text if word_data else word_id)

func _on_visualizer_dimension_changed(dimension, properties):
    // This is for when the visualizer triggers a dimension change
    if dimension != current_dimension:
        change_dimension(dimension)

func _on_auto_save_timer_timeout():
    if config.auto_save_enabled:
        // Check if there was activity since last save
        if last_activity_time > memory_system.get_last_save_time():
            save_system_state()

# Synthetic component classes (would normally be in separate files)

# Word Physics Engine
class WordPhysics extends Node:
    var word_drive = null
    var physics_enabled = true
    
    func connect_to_word_drive(drive):
        word_drive = drive
    
    func set_physics_enabled(enabled):
        physics_enabled = enabled
    
    func process_physics(delta):
        if not physics_enabled or not word_drive:
            return
        
        var words = word_drive.get_all_words()
        var connections = word_drive.get_all_connections()
        
        # Process word physics
        for word_id in words:
            var word = words[word_id]
            if not word.has("position") or not word.has("velocity"):
                continue
            
            # Apply gravity and other forces
            var gravity = Vector3(0, -9.8, 0)
            word.velocity += gravity * delta
            
            # Update position
            word.position += word.velocity * delta
            
            # Floor collision
            if word.position.y < 0:
                word.position.y = 0
                word.velocity.y *= -0.5
                
                # Apply friction
                word.velocity.x *= 0.9
                word.velocity.z *= 0.9
            
            # Apply damping
            word.velocity *= 0.99
            
            # Send physics update through WordDrive
            word_drive.send_message("physics_update", {
                "word_id": word_id,
                "position": word.position,
                "velocity": word.velocity,
                "interaction_type": "physics"
            })
        
        # Process connection physics
        for connection_id in connections:
            var connection = connections[connection_id]
            var from_id = connection.from_id
            var to_id = connection.to_id
            
            if not words.has(from_id) or not words.has(to_id):
                continue
            
            var from_word = words[from_id]
            var to_word = words[to_id]
            
            if not from_word.has("position") or not to_word.has("position"):
                continue
            
            # Calculate spring force
            var direction = (from_word.position - to_word.position).normalized()
            var distance = from_word.position.distance_to(to_word.position)
            var ideal_distance = 2.0
            var stretch = distance - ideal_distance
            
            # Spring force proportional to connection strength
            var spring_constant = 0.5 * connection.get("strength", 1.0)
            var force = direction * stretch * spring_constant
            
            # Apply forces to words
            if from_word.has("velocity") and to_word.has("velocity"):
                from_word.velocity -= force * delta
                to_word.velocity += force * delta
                
                # Send physics updates through WordDrive
                word_drive.send_message("physics_update", {
                    "word_id": from_id,
                    "velocity": from_word.velocity,
                    "interaction_type": "connection"
                })
                
                word_drive.send_message("physics_update", {
                    "word_id": to_id,
                    "velocity": to_word.velocity,
                    "interaction_type": "connection"
                })

# Word Connection Manager
class WordConnectionManager extends Node:
    var word_drive = null
    var auto_discovery_enabled = true
    
    func connect_to_word_drive(drive):
        word_drive = drive
        if word_drive:
            word_drive.connect("word_message_sent", self, "_on_word_message")
    
    func set_auto_discovery(enabled):
        auto_discovery_enabled = enabled
    
    func _on_word_message(msg_type, payload, source):
        # Auto-discover connections when new words are created
        if auto_discovery_enabled and msg_type == "word_create":
            var new_word_id = payload.id
            _discover_connections(new_word_id)
    
    func _discover_connections(word_id):
        if not word_drive:
            return
        
        var words = word_drive.get_all_words()
        if not words.has(word_id):
            return
        
        var new_word = words[word_id]
        var new_word_text = new_word.text
        
        # Check for potential connections with existing words
        for other_id in words:
            if other_id == word_id:
                continue
            
            var other_word = words[other_id]
            var other_text = other_word.text
            
            # Simple connection criteria:
            # 1. Words that share a common prefix/suffix
            # 2. Words that are antonyms/synonyms (if we had such a database)
            # 3. Words with similar categories
            
            var should_connect = false
            var connection_strength = 1.0
            var connection_properties = {}
            
            # Check for common prefix (3+ characters)
            if new_word_text.length() >= 3 and other_text.length() >= 3:
                var new_prefix = new_word_text.substr(0, 3).to_lower()
                var other_prefix = other_text.substr(0, 3).to_lower()
                
                if new_prefix == other_prefix:
                    should_connect = true
                    connection_strength = 1.2
                    connection_properties["type"] = "prefix_match"
            
            # Check for common suffix (3+ characters)
            if not should_connect and new_word_text.length() >= 3 and other_text.length() >= 3:
                var new_suffix = new_word_text.substr(new_word_text.length() - 3).to_lower()
                var other_suffix = other_text.substr(other_text.length() - 3).to_lower()
                
                if new_suffix == other_suffix:
                    should_connect = true
                    connection_strength = 1.2
                    connection_properties["type"] = "suffix_match"
            
            # Check for exact substring
            if not should_connect:
                if new_word_text.to_lower().find(other_text.to_lower()) >= 0 or other_text.to_lower().find(new_word_text.to_lower()) >= 0:
                    should_connect = true
                    connection_strength = 1.5
                    connection_properties["type"] = "substring_match"
            
            # Check for category match
            if not should_connect and new_word.has("categories") and other_word.has("categories"):
                for category in new_word.categories:
                    if other_word.categories.has(category):
                        should_connect = true
                        connection_strength = 1.3
                        connection_properties["type"] = "category_match"
                        connection_properties["category"] = category
                        break
            
            # Create connection if criteria met
            if should_connect:
                connection_properties["strength"] = connection_strength
                connection_properties["auto_discovered"] = true
                
                word_drive.connect_words(word_id, other_id, connection_properties)

# Word Memory System
class WordMemorySystem extends Node:
    var word_drive = null
    var memory_enabled = true
    var message_history = []
    var last_save_time = 0
    
    const MAX_HISTORY = 1000
    
    func connect_to_word_drive(drive):
        word_drive = drive
    
    func set_memory_enabled(enabled):
        memory_enabled = enabled
    
    func record_word_message(message):
        if not memory_enabled:
            return
        
        message_history.append(message)
        
        if message_history.size() > MAX_HISTORY:
            message_history.pop_front()
    
    func save_system_state(turn = 1, dimension = "3D"):
        if not memory_enabled or not word_drive:
            return false
        
        var words = word_drive.get_all_words()
        var connections = word_drive.get_all_connections()
        
        var save_data = {
            "version": "1.0.0",
            "timestamp": OS.get_unix_time(),
            "turn": turn,
            "dimension": dimension,
            "words": words,
            "connections": connections
        }
        
        var file = File.new()
        var save_path = "user://world_of_words_save.json"
        
        if file.open(save_path, File.WRITE) == OK:
            file.store_string(JSON.print(save_data, "  "))
            file.close()
            last_save_time = OS.get_unix_time()
            return true
        
        return false
    
    func load_system_state():
        if not memory_enabled:
            return false
        
        var file = File.new()
        var save_path = "user://world_of_words_save.json"
        
        if not file.file_exists(save_path):
            return false
        
        if file.open(save_path, File.READ) == OK:
            var saved_data_text = file.get_as_text()
            file.close()
            
            var json = JSON.parse(saved_data_text)
            if json.error != OK:
                return false
            
            var saved_data = json.result
            
            # Check version compatibility and required fields
            if not saved_data.has("version") or not saved_data.has("words") or not saved_data.has("connections"):
                return false
            
            # Restore words
            for word_id in saved_data.words:
                var word_data = saved_data.words[word_id]
                if not word_drive.get_word(word_id).empty():
                    word_drive.update_word(word_id, word_data)
                else:
                    word_drive.create_word(word_data.text, word_data)
            
            # Restore connections
            for conn_id in saved_data.connections:
                var conn_data = saved_data.connections[conn_id]
                var from_id = conn_data.from_id
                var to_id = conn_data.to_id
                
                if word_drive.get_word(from_id).empty() or word_drive.get_word(to_id).empty():
                    continue
                
                if word_drive.get_connection(conn_id).empty():
                    var conn_props = conn_data.duplicate()
                    word_drive.connect_words(from_id, to_id, conn_props)
            
            return true
        
        return false
    
    func get_current_turn():
        var file = File.new()
        var save_path = "user://world_of_words_save.json"
        
        if not file.file_exists(save_path):
            return 1
        
        if file.open(save_path, File.READ) == OK:
            var saved_data_text = file.get_as_text()
            file.close()
            
            var json = JSON.parse(saved_data_text)
            if json.error != OK:
                return 1
            
            var saved_data = json.result
            
            if saved_data.has("turn"):
                return saved_data.turn
        
        return 1
    
    func get_current_dimension():
        var file = File.new()
        var save_path = "user://world_of_words_save.json"
        
        if not file.file_exists(save_path):
            return "3D"
        
        if file.open(save_path, File.READ) == OK:
            var saved_data_text = file.get_as_text()
            file.close()
            
            var json = JSON.parse(saved_data_text)
            if json.error != OK:
                return "3D"
            
            var saved_data = json.result
            
            if saved_data.has("dimension"):
                return saved_data.dimension
        
        return "3D"
    
    func get_last_save_time():
        return last_save_time