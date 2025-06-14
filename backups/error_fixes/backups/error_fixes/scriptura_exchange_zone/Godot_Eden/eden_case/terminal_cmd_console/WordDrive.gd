extends Node
class_name WordDrive

# ------------------------------------
# WordDrive - Central message bus for the World of Words system
# Functions as a singular data flow control point between all word-related systems
# ------------------------------------

# Signal Declaration - All word system messages pass through these signals
signal word_message_sent(msg_type: String, payload: Variant, source: String)
signal word_dimension_changed(dimension: String, properties: Dictionary)
signal word_evolution_triggered(word_id: String, evolution_stage: int)
signal word_connection_established(from_id: String, to_id: String, properties: Dictionary)
signal word_physical_interaction(word_id: String, interaction_type: String, properties: Dictionary)
signal word_visualization_updated(word_id: String, visual_properties: Dictionary)

# Tracking and Monitoring
var active_words = {}
var word_connections = {}
var dimension_states = {}
var message_history = []
var system_status = {
    "active": true,
    "current_dimension": "3D",
    "current_turn": 1,
    "memory_allocated": 0,
    "last_activity_timestamp": 0,
    "total_message_count": 0,
    "visualizer_connected": false
}

# Integrated Systems References
var word_processor = null
var word_visualizer = null
var physics_engine = null
var connection_manager = null
var memory_system = null

# Constants
const MAX_HISTORY_LENGTH = 1000
const DEFAULT_WORD_POWER = 25
const SYSTEM_VERSION = "1.0.0"

# Initialize the system
func _ready():
    print("WordDrive initialized (v%s)" % SYSTEM_VERSION)
    _setup_dimension_states()
    system_status.last_activity_timestamp = OS.get_unix_time()

# Primary API: Send a message through the central word bus
func send_message(msg_type: String, payload: Variant, source: String = "system") -> bool:
    # Validate message
    if not _validate_message(msg_type, payload):
        push_warning("WordDrive: Invalid message rejected (%s)" % msg_type)
        return false
    
    # Process message based on type
    match msg_type:
        "word_create":
            _process_word_creation(payload, source)
        "word_update":
            _process_word_update(payload, source)
        "word_delete":
            _process_word_deletion(payload, source)
        "dimension_change":
            _process_dimension_change(payload, source)
        "connection_create":
            _process_connection_creation(payload, source)
        "connection_update":
            _process_connection_update(payload, source)
        "connection_delete":
            _process_connection_deletion(payload, source)
        "physics_update":
            _process_physics_update(payload, source)
        "visualization_update":
            _process_visualization_update(payload, source)
        "system_command":
            _process_system_command(payload, source)
    
    # Record in history
    _record_message(msg_type, payload, source)
    
    # Update status
    system_status.total_message_count += 1
    system_status.last_activity_timestamp = OS.get_unix_time()
    
    # Broadcast message
    emit_signal("word_message_sent", msg_type, payload, source)
    return true

# Process a new word creation
func _process_word_creation(payload: Dictionary, source: String) -> void:
    # Generate word ID if not provided
    if not payload.has("id") or payload.id.empty():
        payload.id = _generate_word_id(payload.text)
    
    # Process the word if we have a processor
    if word_processor != null and payload.has("text"):
        var processed = word_processor.process_word(payload.text)
        if processed != null:
            payload.power = processed.power
            payload.attributes = processed.attributes
    
    # Set default power if not specified
    if not payload.has("power"):
        payload.power = DEFAULT_WORD_POWER
    
    # Set dimension if not specified
    if not payload.has("dimension"):
        payload.dimension = system_status.current_dimension
    
    # Set creation metadata
    payload.creation_time = OS.get_unix_time()
    payload.creator = source
    payload.turn = system_status.current_turn
    
    # Store the word
    active_words[payload.id] = payload
    
    # Update the memory allocation tracking
    system_status.memory_allocated += _calculate_word_memory_size(payload)
    
    # If visualizer is connected, send update
    if system_status.visualizer_connected and word_visualizer != null:
        word_visualizer.visualize_word(payload)

# Process word update
func _process_word_update(payload: Dictionary, source: String) -> void:
    var word_id = payload.id
    
    # Ensure word exists
    if not active_words.has(word_id):
        push_warning("WordDrive: Attempted to update non-existent word: %s" % word_id)
        return
    
    # Update word properties
    for key in payload.keys():
        if key != "id": # Don't change the ID
            active_words[word_id][key] = payload[key]
    
    # Mark as modified
    active_words[word_id].last_modified = OS.get_unix_time()
    active_words[word_id].last_modifier = source
    
    # Update visualization if needed
    if system_status.visualizer_connected and word_visualizer != null:
        word_visualizer.update_word_visual(word_id, payload)

# Process word deletion
func _process_word_deletion(payload: Dictionary, source: String) -> void:
    var word_id = payload.id
    
    # Ensure word exists
    if not active_words.has(word_id):
        push_warning("WordDrive: Attempted to delete non-existent word: %s" % word_id)
        return
    
    # Remove all connections to this word
    var connections_to_remove = []
    for conn_id in word_connections.keys():
        var conn = word_connections[conn_id]
        if conn.from_id == word_id or conn.to_id == word_id:
            connections_to_remove.append(conn_id)
    
    for conn_id in connections_to_remove:
        _process_connection_deletion({"id": conn_id}, "system")
    
    # Update memory allocation
    system_status.memory_allocated -= _calculate_word_memory_size(active_words[word_id])
    
    # Remove the word
    active_words.erase(word_id)
    
    # Update visualization
    if system_status.visualizer_connected and word_visualizer != null:
        word_visualizer.remove_word_visual(word_id)

# Process dimension change
func _process_dimension_change(payload: Dictionary, source: String) -> void:
    # Update current dimension
    system_status.current_dimension = payload.dimension
    
    # Apply dimension-specific rules to all words in the dimension
    var dimension_properties = dimension_states[payload.dimension]
    
    # Emit signal with dimension properties
    emit_signal("word_dimension_changed", payload.dimension, dimension_properties)
    
    # Update visualization
    if system_status.visualizer_connected and word_visualizer != null:
        word_visualizer.update_dimension(payload.dimension, dimension_properties)

# Process connection creation
func _process_connection_creation(payload: Dictionary, source: String) -> void:
    # Generate connection ID if not provided
    if not payload.has("id") or payload.id.empty():
        payload.id = _generate_connection_id(payload.from_id, payload.to_id)
    
    # Ensure both words exist
    if not active_words.has(payload.from_id) or not active_words.has(payload.to_id):
        push_warning("WordDrive: Attempted to connect non-existent words")
        return
    
    # Set defaults
    if not payload.has("strength"):
        payload.strength = 1.0
    
    # Set creation metadata
    payload.creation_time = OS.get_unix_time()
    payload.creator = source
    
    # Store connection
    word_connections[payload.id] = payload
    
    # Add connection reference to words
    if not active_words[payload.from_id].has("connections"):
        active_words[payload.from_id].connections = []
    if not active_words[payload.to_id].has("connections"):
        active_words[payload.to_id].connections = []
    
    active_words[payload.from_id].connections.append(payload.id)
    active_words[payload.to_id].connections.append(payload.id)
    
    # Emit signal
    emit_signal("word_connection_established", payload.from_id, payload.to_id, payload)
    
    # Update visualization
    if system_status.visualizer_connected and word_visualizer != null:
        word_visualizer.visualize_connection(payload)

# Process connection update
func _process_connection_update(payload: Dictionary, source: String) -> void:
    var connection_id = payload.id
    
    # Ensure connection exists
    if not word_connections.has(connection_id):
        push_warning("WordDrive: Attempted to update non-existent connection: %s" % connection_id)
        return
    
    # Update connection properties
    for key in payload.keys():
        if key != "id": # Don't change the ID
            word_connections[connection_id][key] = payload[key]
    
    # Mark as modified
    word_connections[connection_id].last_modified = OS.get_unix_time()
    word_connections[connection_id].last_modifier = source
    
    # Update visualization
    if system_status.visualizer_connected and word_visualizer != null:
        word_visualizer.update_connection_visual(connection_id, payload)

# Process connection deletion
func _process_connection_deletion(payload: Dictionary, source: String) -> void:
    var connection_id = payload.id
    
    # Ensure connection exists
    if not word_connections.has(connection_id):
        push_warning("WordDrive: Attempted to delete non-existent connection: %s" % connection_id)
        return
    
    var connection = word_connections[connection_id]
    
    # Remove connection from words
    if active_words.has(connection.from_id):
        active_words[connection.from_id].connections.erase(connection_id)
    
    if active_words.has(connection.to_id):
        active_words[connection.to_id].connections.erase(connection_id)
    
    # Remove connection
    word_connections.erase(connection_id)
    
    # Update visualization
    if system_status.visualizer_connected and word_visualizer != null:
        word_visualizer.remove_connection_visual(connection_id)

# Process physics update
func _process_physics_update(payload: Dictionary, source: String) -> void:
    # Update physical properties of words
    if payload.has("word_id") and active_words.has(payload.word_id):
        var word_id = payload.word_id
        
        # Update position, velocity, etc.
        if payload.has("position"):
            active_words[word_id].position = payload.position
        
        if payload.has("velocity"):
            active_words[word_id].velocity = payload.velocity
        
        if payload.has("rotation"):
            active_words[word_id].rotation = payload.rotation
        
        # Emit signal for physical interaction
        emit_signal("word_physical_interaction", word_id, 
                   payload.interaction_type if payload.has("interaction_type") else "update", 
                   payload)
        
        # Update visualization
        if system_status.visualizer_connected and word_visualizer != null:
            word_visualizer.update_word_physics(word_id, payload)

# Process visualization update
func _process_visualization_update(payload: Dictionary, source: String) -> void:
    # Update visual properties
    if payload.has("word_id") and active_words.has(payload.word_id):
        var word_id = payload.word_id
        
        # Store visual properties in word
        if payload.has("visual_properties"):
            if not active_words[word_id].has("visual"):
                active_words[word_id].visual = {}
            
            for key in payload.visual_properties:
                active_words[word_id].visual[key] = payload.visual_properties[key]
        
        # Emit signal for visualization update
        emit_signal("word_visualization_updated", word_id, 
                   payload.visual_properties if payload.has("visual_properties") else {})
        
        # Update visualization
        if system_status.visualizer_connected and word_visualizer != null:
            word_visualizer.update_word_visual(word_id, payload.visual_properties)

# Process system commands
func _process_system_command(payload: Dictionary, source: String) -> void:
    match payload.command:
        "connect_visualizer":
            system_status.visualizer_connected = true
            word_visualizer = payload.visualizer if payload.has("visualizer") else null
        
        "disconnect_visualizer":
            system_status.visualizer_connected = false
            word_visualizer = null
        
        "set_word_processor":
            word_processor = payload.processor if payload.has("processor") else null
        
        "set_physics_engine":
            physics_engine = payload.engine if payload.has("engine") else null
        
        "set_connection_manager":
            connection_manager = payload.manager if payload.has("manager") else null
        
        "set_memory_system":
            memory_system = payload.system if payload.has("memory_system") else null
        
        "change_turn":
            system_status.current_turn = payload.turn if payload.has("turn") else system_status.current_turn + 1
        
        "system_status_request":
            # If a callback is provided, use it
            if payload.has("callback") and payload.callback is Callable:
                payload.callback.call(system_status)

# Record message in history
func _record_message(msg_type: String, payload: Variant, source: String) -> void:
    var message = {
        "type": msg_type,
        "payload": payload,
        "source": source,
        "timestamp": OS.get_unix_time()
    }
    
    message_history.append(message)
    
    # Trim history if needed
    if message_history.size() > MAX_HISTORY_LENGTH:
        message_history.pop_front()
    
    # If memory system is connected, record there too
    if memory_system != null:
        memory_system.record_word_message(message)

# Validate message
func _validate_message(msg_type: String, payload: Variant) -> bool:
    # Check system is active
    if not system_status.active:
        return false
    
    # Check payload is a dictionary
    if not payload is Dictionary:
        return false
    
    # Type-specific validation
    match msg_type:
        "word_create":
            return payload.has("text")
        
        "word_update", "word_delete":
            return payload.has("id")
        
        "dimension_change":
            return payload.has("dimension") and dimension_states.has(payload.dimension)
        
        "connection_create":
            return payload.has("from_id") and payload.has("to_id")
        
        "connection_update", "connection_delete":
            return payload.has("id")
        
        "physics_update", "visualization_update":
            return payload.has("word_id")
        
        "system_command":
            return payload.has("command")
    
    # Unknown message type
    return false

# Generate unique word ID
func _generate_word_id(text: String) -> String:
    var timestamp = OS.get_unix_time()
    var random = randi() % 10000
    return "word_" + text.substr(0, 3).to_lower() + "_" + str(timestamp) + "_" + str(random)

# Generate unique connection ID
func _generate_connection_id(from_id: String, to_id: String) -> String:
    var timestamp = OS.get_unix_time()
    var random = randi() % 10000
    return "conn_" + str(timestamp) + "_" + str(random)

# Calculate approximate memory footprint of a word
func _calculate_word_memory_size(word: Dictionary) -> int:
    var size = 0
    
    # Base size for word entry
    size += 100
    
    # Text length
    if word.has("text"):
        size += word.text.length() * 2
    
    # Additional properties
    if word.has("attributes") and word.attributes is Dictionary:
        size += word.attributes.size() * 20
    
    return size

# Setup default dimension states
func _setup_dimension_states() -> void:
    # Define properties for each dimension
    dimension_states = {
        "1D": {
            "physics_enabled": false,
            "gravity_factor": 0.0,
            "connection_limit": 2,
            "color_scheme": "monochrome",
            "description": "Linear dimension - words can only connect in sequence"
        },
        "2D": {
            "physics_enabled": true,
            "gravity_factor": 0.5,
            "connection_limit": 4,
            "color_scheme": "pastel",
            "description": "Flat dimension - words exist on a plane"
        },
        "3D": {
            "physics_enabled": true,
            "gravity_factor": 1.0,
            "connection_limit": 12,
            "color_scheme": "vibrant",
            "description": "Spatial dimension - words exist in 3D space with full physics"
        },
        "4D": {
            "physics_enabled": true,
            "gravity_factor": 1.2,
            "connection_limit": 24,
            "color_scheme": "hypercolor",
            "description": "Temporal dimension - words exist with time as a fourth dimension"
        },
        "5D": {
            "physics_enabled": true,
            "gravity_factor": 0.8,
            "connection_limit": 60,
            "color_scheme": "penta",
            "description": "Probability dimension - words exist in multiple states simultaneously"
        },
        "6D": {
            "physics_enabled": false,
            "gravity_factor": 0.0,
            "connection_limit": 720,
            "color_scheme": "quantum",
            "description": "Conceptual dimension - words connect based on meaning rather than space"
        },
        "7D": {
            "physics_enabled": false,
            "gravity_factor": 0.0,
            "connection_limit": 0, # No limit
            "color_scheme": "metaphysical",
            "description": "Metaphysical dimension - words transcend physical space entirely"
        }
    }

# Public API Methods
func create_word(text: String, properties: Dictionary = {}) -> String:
    properties.text = text
    send_message("word_create", properties)
    return properties.id if properties.has("id") else _generate_word_id(text)

func update_word(word_id: String, properties: Dictionary) -> bool:
    properties.id = word_id
    return send_message("word_update", properties)

func delete_word(word_id: String) -> bool:
    return send_message("word_delete", {"id": word_id})

func connect_words(from_id: String, to_id: String, properties: Dictionary = {}) -> String:
    properties.from_id = from_id
    properties.to_id = to_id
    send_message("connection_create", properties)
    return properties.id if properties.has("id") else _generate_connection_id(from_id, to_id)

func get_word(word_id: String) -> Dictionary:
    return active_words[word_id] if active_words.has(word_id) else {}

func get_all_words() -> Dictionary:
    return active_words

func get_connection(connection_id: String) -> Dictionary:
    return word_connections[connection_id] if word_connections.has(connection_id) else {}

func get_all_connections() -> Dictionary:
    return word_connections

func change_dimension(dimension: String) -> bool:
    if dimension_states.has(dimension):
        return send_message("dimension_change", {"dimension": dimension})
    return false

func get_system_status() -> Dictionary:
    return system_status

func register_visualizer(visualizer_node) -> void:
    send_message("system_command", {
        "command": "connect_visualizer", 
        "visualizer": visualizer_node
    })

func search_words(query: String) -> Array:
    var results = []
    for word_id in active_words:
        var word = active_words[word_id]
        if word.text.to_lower().contains(query.to_lower()):
            results.append(word)
    return results

func disable() -> void:
    system_status.active = false

func enable() -> void:
    system_status.active = true