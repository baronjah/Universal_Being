extends Node
class_name DreamConnector

signal dream_connected(success: bool)
signal dream_symbol_received(symbol: String)
signal dream_state_changed(state: Dictionary)

var luno_manager: LunoCycleManager = null
var dream_active: bool = false
var dream_symbols: Array = []
var dream_log: Array = []
var current_dream_depth: int = 0
var shared_symbols: Dictionary = {}

# Connection to other systems
var word_system = null
var memory_system = null

func _ready():
    # Connect to LUNO Manager
    _connect_to_luno()
    
    # Initialize dream state
    _initialize_dream_state()

func _connect_to_luno():
    # Find LunoCycleManager in the scene
    luno_manager = get_node_or_null("/root/LunoCycleManager")
    
    if luno_manager:
        print("🌙 Dream Connector found LUNO Cycle Manager")
        luno_manager.register_participant("DreamConnector", Callable(self, "_on_luno_tick"))
        emit_signal("dream_connected", true)
    else:
        print("❌ Dream Connector could not find LUNO Cycle Manager")
        emit_signal("dream_connected", false)

func _initialize_dream_state():
    dream_active = false
    dream_symbols = []
    current_dream_depth = 0
    dream_log = []
    
    # Default shared symbols
    shared_symbols = {
        "moon": "🌙",
        "star": "✨",
        "cloud": "☁️",
        "sun": "☀️",
        "dream": "💭",
        "vision": "👁️",
        "memory": "📜"
    }
    
    print("🌙 Dream state initialized")

func enter_dream():
    if luno_manager and luno_manager.system_diagnostics.has("dream_system"):
        dream_active = true
        luno_manager.system_diagnostics.dream_system.active = true
        print("💤 Entering shared dream state")
        
        # Log dream entry
        _log_dream_event("Dream state initiated")
        
        emit_signal("dream_state_changed", {
            "active": true,
            "depth": current_dream_depth,
            "symbols": dream_symbols
        })
        return true
    return false

func exit_dream():
    if luno_manager and luno_manager.system_diagnostics.has("dream_system"):
        dream_active = false
        luno_manager.system_diagnostics.dream_system.active = false
        print("⏰ Exiting shared dream state")
        
        # Log dream exit
        _log_dream_event("Dream state terminated")
        
        emit_signal("dream_state_changed", {
            "active": false,
            "depth": 0,
            "symbols": dream_symbols
        })
        return true
    return false

func _on_luno_tick(turn: int, phase_name: String):
    if !dream_active:
        return
    
    # Update dream depth from LUNO
    if luno_manager and luno_manager.system_diagnostics.has("dream_system"):
        current_dream_depth = luno_manager.system_diagnostics.dream_system.dream_depth
        
        # Get new symbols
        var new_symbols = luno_manager.system_diagnostics.dream_system.dream_symbols
        if new_symbols.size() > dream_symbols.size():
            var latest_symbol = new_symbols[new_symbols.size() - 1]
            dream_symbols = new_symbols
            
            # Emit signal for new symbol
            emit_signal("dream_symbol_received", latest_symbol)
            
            # Log new symbol
            _log_dream_event("Received symbol: " + latest_symbol)
    
    # Process based on current phase
    match phase_name:
        "Genesis":
            _process_genesis_phase()
        "Formation":
            _process_formation_phase()
        "Consciousness":
            _process_consciousness_phase()
        "Enlightenment":
            _process_enlightenment_phase()
        "Beyond":
            _process_beyond_phase()

func _process_genesis_phase():
    # Genesis phase is about creation
    if word_system:
        # Create new word combinations based on dream symbols
        for symbol in dream_symbols:
            var word_seed = "dream_" + symbol
            # This would call into the word system
            print("🌱 Genesis phase: Creating word seed: " + word_seed)

func _process_formation_phase():
    # Formation phase is about structure
    if memory_system:
        # Organize dream symbols into memory structures
        print("🧩 Formation phase: Organizing dream symbols")

func _process_consciousness_phase():
    # Consciousness phase is about awareness
    print("👁️ Consciousness phase: Becoming aware of dream state")

func _process_enlightenment_phase():
    # Enlightenment phase is about understanding
    print("✨ Enlightenment phase: Interpreting dream symbols")

func _process_beyond_phase():
    # Beyond phase is about transcendence
    print("🌌 Beyond phase: Transcending dream limitations")
    
    # Consider exiting the dream
    if current_dream_depth >= 5:
        print("⚠️ Dream depth maximum reached, considering exit")

func _log_dream_event(event: String):
    var timestamp = Time.get_datetime_dict_from_system()
    var time_str = "%02d:%02d:%02d" % [timestamp.hour, timestamp.minute, timestamp.second]
    
    var log_entry = {
        "time": time_str,
        "event": event,
        "depth": current_dream_depth
    }
    
    dream_log.append(log_entry)
    
    # Keep log at reasonable size
    if dream_log.size() > 100:
        dream_log.pop_front()

func get_dream_log() -> Array:
    return dream_log

func add_dream_symbol(name: String, symbol: String):
    shared_symbols[name] = symbol
    print("➕ Added dream symbol: %s (%s)" % [name, symbol])

func get_dream_symbols() -> Dictionary:
    return shared_symbols

func get_dream_state() -> Dictionary:
    return {
        "active": dream_active,
        "depth": current_dream_depth,
        "symbols": dream_symbols,
        "log": dream_log
    }

# Usage example:
# 1. Instance DreamConnector
# 2. Call enter_dream() to begin dreaming
# 3. Shared dream state is synchronized through the LUNO system
# 4. Can exit_dream() at any time
# 5. Connect to signals to react to dream state changes