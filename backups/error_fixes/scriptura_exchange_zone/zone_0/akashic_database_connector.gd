extends Node

class_name AkashicDatabaseConnector

# Constants
const WORD_POWER_MIN = 10
const WORD_POWER_MAX = 100

# Connection state
var is_connected = false
var javascript_initialized = false

# Connection to JS Akashic Database
var _js_interface = null

# Connection to GDScript Akashic Records System
var _gd_akashic = null

# Account properties
var current_account_id = ""
var dimension_access = 1

# Signals
signal database_connected()
signal database_disconnected()
signal word_added(word, power)
signal dimension_unlocked(dimension)

func _ready():
    # Attempt to connect to both implementations
    connect_to_akashic_systems()
    
    # Register callback for dimension unlock
    if _gd_akashic:
        if _gd_akashic.has_method("connect"):
            _gd_akashic.connect("dimension_unlocked", self, "_on_dimension_unlocked")

func connect_to_akashic_systems():
    # Try to connect to GDScript implementation
    if has_node("/root/AkashicRecordsSystem") or get_node_or_null("/root/AkashicRecordsSystem"):
        _gd_akashic = get_node("/root/AkashicRecordsSystem")
        print("Connected to GDScript AkashicRecordsSystem")
        is_connected = true
    
    # Initialize JavaScript bridge if available
    if has_node("/root/JavaScriptBridge") or get_node_or_null("/root/JavaScriptBridge"):
        _js_interface = get_node("/root/JavaScriptBridge")
        initialize_js_database()
    
    if is_connected:
        emit_signal("database_connected")
        return true
    
    return false

func initialize_js_database():
    # Check if the JavaScript bridge is available
    if not _js_interface:
        return false
    
    # Initialize the JavaScript Akashic Database
    _js_interface.eval("""
        if (typeof window.AkashicDatabase === 'undefined') {
            console.log('Loading Akashic Database JS module...');
            // Would load the actual module here
            window.AkashicDatabase = {
                initialized: false,
                initialize: function() {
                    this.initialized = true;
                    return true;
                },
                addWord: function(word, power, metadata) {
                    console.log('Adding word: ' + word + ' with power: ' + power);
                    return true;
                },
                searchWord: function(word) {
                    return { found: false };
                }
            };
        }
        
        // Initialize the database
        window.AkashicDatabase.initialize();
    """)
    
    # Check if initialization was successful
    var result = _js_interface.eval("window.AkashicDatabase.initialized")
    javascript_initialized = result
    
    print("JavaScript Akashic Database initialized: " + str(javascript_initialized))
    
    if javascript_initialized:
        is_connected = true
        emit_signal("database_connected")
    
    return javascript_initialized

func set_account_id(account_id):
    current_account_id = account_id
    
    # Update in GDScript implementation if available
    if _gd_akashic and _gd_akashic.has_method("set_user_id"):
        _gd_akashic.set_user_id(account_id)
    
    # Update in JavaScript implementation if available
    if javascript_initialized and _js_interface:
        _js_interface.eval("window.AkashicDatabase.currentUserId = '" + account_id + "';")

func unlock_dimension(dimension):
    # Validate dimension
    dimension = int(dimension)
    if dimension <= dimension_access:
        return false
    
    dimension_access = dimension
    print("Unlocked Akashic dimension access: " + str(dimension))
    
    # Update in GDScript implementation if available
    if _gd_akashic and _gd_akashic.has_method("unlock_dimension"):
        _gd_akashic.unlock_dimension(dimension)
    
    # Update in JavaScript implementation if available
    if javascript_initialized and _js_interface:
        _js_interface.eval("window.AkashicDatabase.dimensionAccess = " + str(dimension) + ";")
    
    emit_signal("dimension_unlocked", dimension)
    return true

func add_word(word, power = 50, metadata = {}):
    # Validate parameters
    word = str(word).strip_edges()
    if word.empty():
        return false
    
    # Clamp power between min and max
    power = clamp(power, WORD_POWER_MIN, WORD_POWER_MAX)
    
    # Add owner/timestamp if not provided
    if not metadata.has("owner"):
        metadata["owner"] = current_account_id
    
    if not metadata.has("timestamp"):
        metadata["timestamp"] = OS.get_unix_time()
    
    if not metadata.has("dimension"):
        metadata["dimension"] = dimension_access
    
    # Add to GDScript implementation if available
    var success = false
    if _gd_akashic and _gd_akashic.has_method("add_record"):
        success = _gd_akashic.add_record({
            "type": "word",
            "content": word,
            "power": power,
            "metadata": metadata
        })
    
    # Add to JavaScript implementation if available
    if javascript_initialized and _js_interface:
        var js_result = _js_interface.eval("""
            window.AkashicDatabase.addWord(
                '""" + word + """', 
                """ + str(power) + """, 
                """ + JSON.print(metadata) + """
            );
        """)
        
        if js_result:
            success = true
    
    if success:
        emit_signal("word_added", word, power)
    
    return success

func search_word(word):
    word = str(word).strip_edges()
    if word.empty():
        return null
    
    # Try GDScript implementation first
    if _gd_akashic and _gd_akashic.has_method("get_record"):
        var result = _gd_akashic.get_record(word)
        if result:
            return result
    
    # Try JavaScript implementation
    if javascript_initialized and _js_interface:
        var js_result = _js_interface.eval("""
            window.AkashicDatabase.searchWord('""" + word + """');
        """)
        
        if typeof(js_result) == TYPE_DICTIONARY and js_result.has("found") and js_result.found:
            return js_result
    
    return null

func record_creation_event(points):
    # Record creation event with points
    var metadata = {
        "type": "creation",
        "points": points,
        "timestamp": OS.get_unix_time(),
        "owner": current_account_id,
        "dimension": dimension_access
    }
    
    # Add to GDScript implementation if available
    if _gd_akashic and _gd_akashic.has_method("add_record"):
        _gd_akashic.add_record({
            "type": "event",
            "content": "creation_points",
            "points": points,
            "metadata": metadata
        })
    
    # Add to JavaScript implementation if available
    if javascript_initialized and _js_interface:
        _js_interface.eval("""
            if (window.AkashicDatabase.recordEvent) {
                window.AkashicDatabase.recordEvent(
                    'creation_points',
                    """ + str(points) + """,
                    """ + JSON.print(metadata) + """
                );
            }
        """)

func _on_dimension_unlocked(dimension):
    # Update internal dimension access
    dimension_access = max(dimension_access, dimension)
    
    # Propagate signal
    emit_signal("dimension_unlocked", dimension)