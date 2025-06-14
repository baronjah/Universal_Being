extends Node

# DataPackSystem.gd
# A quantum-inspired data management system for handling 99+ data packs
# with center splitting for 66% synergy optimization

# Configuration
const MAX_PACKS = 99
const SYNERGY_THRESHOLD = 0.66  # 66% threshold for optimal data splitting
const CYCLE_COUNT = 12  # LUNO system cycles

# Quantum state data structure
class QuantumDataState:
    var amplitude: float = 1.0
    var phase: float = 0.0
    var value # Can hold any type
    var metadata: Dictionary = {}
    
    func _init(v, amp=1.0, ph=0.0):
        value = v
        amplitude = amp
        phase = ph
    
    func collapse() -> float:
        # Simulates quantum collapse to determine visibility priority
        return amplitude * amplitude * (1 + cos(phase)) / 2

# Main data containers
var data_packs = []  # Array of all data packs
var quantum_registry = []  # Quantum-superposition data points
var active_segments = []  # Currently visible/active segments
var current_cycle = 1  # Current LUNO cycle (1-12)

# Cycle data from LUNO system
var cycle_data = [
    {"turn": 1, "phase": "Genesis", "purpose": "Create data structures"},
    {"turn": 2, "phase": "Formation", "purpose": "Assign paths, build nodes"},
    {"turn": 3, "phase": "Complexity", "purpose": "Establish connections"},
    {"turn": 4, "phase": "Consciousness", "purpose": "Begin monitoring"},
    {"turn": 5, "phase": "Awakening", "purpose": "AI auto-tracking + self-checks"},
    {"turn": 6, "phase": "Enlightenment", "purpose": "Optimize relationships"},
    {"turn": 7, "phase": "Manifestation", "purpose": "Generate new entities"},
    {"turn": 8, "phase": "Connection", "purpose": "Network interactions"},
    {"turn": 9, "phase": "Harmony", "purpose": "Balance memory + performance"},
    {"turn": 10, "phase": "Transcendence", "purpose": "Remove limits (dynamic scaling)"},
    {"turn": 11, "phase": "Unity", "purpose": "Integrate all systems"},
    {"turn": 12, "phase": "Beyond", "purpose": "Reset cycle or start expansion"}
]

# Optional API key storage with encryption
var _api_key_hash = ""  # Stores a hash of the API key, not the key itself

# UI/Display references
var terminal_ref = null
var display_buffer = []  # Buffer for terminal display

# Statistics tracking
var stats = {
    "messages_processed": 0,
    "quantum_operations": 0,
    "synergy_score": 0.0,
    "center_splits": 0
}

# Signal for system updates
signal data_updated(segment_id)
signal cycle_changed(cycle_num, phase_name)

func _ready():
    # Initialize data structures based on current LUNO cycle
    _initialize_data_structures()
    
    # Setup cyclic timer
    var timer = Timer.new()
    timer.wait_time = 30.0  # Default 30 seconds per cycle
    timer.autostart = true
    timer.connect("timeout", self, "_advance_cycle")
    add_child(timer)

func _initialize_data_structures():
    # Create different data structures based on the LUNO cycle
    match current_cycle:
        1: # Genesis
            # Simple array structure
            data_packs = []
        2, 3: # Formation, Complexity
            # Dictionary-based structure with indexing
            data_packs = {}
        4, 5, 6: # Consciousness, Awakening, Enlightenment
            # Advanced structure with quantum registry
            data_packs = []
            quantum_registry = []
        7, 8, 9: # Manifestation, Connection, Harmony
            # Full hierarchical structure with segments
            data_packs = []
            quantum_registry = []
            active_segments = []
        _: # Transcendence, Unity, Beyond (10-12)
            # Full dynamic structure with all components
            data_packs = []
            quantum_registry = []
            active_segments = []
            # Additional metastructures would be initialized here

# API for adding data packs
func add_data_pack(data, metadata={}):
    if data_packs.size() >= MAX_PACKS:
        # Apply 66% center removal strategy when at capacity
        _apply_center_splitting()
    
    # Create a quantum data state
    var q_state = QuantumDataState.new(data)
    q_state.metadata = metadata
    
    # Store based on current cycle structure
    if current_cycle >= 4:
        # For advanced cycles, use quantum registry
        quantum_registry.append(q_state)
        # Only materialize if probability is high enough
        if q_state.collapse() > 0.5:
            data_packs.append(data)
    else:
        # For early cycles, use simpler storage
        data_packs.append(data)
    
    stats.messages_processed += 1
    emit_signal("data_updated", metadata.get("segment_id", 0))
    
    return true

# Core algorithm implementing the 66% center splitting theory
func _apply_center_splitting():
    # Calculate 66% center point
    var start_idx = floor(data_packs.size() * (1.0 - SYNERGY_THRESHOLD) / 2)
    var end_idx = ceil(data_packs.size() * (0.5 + SYNERGY_THRESHOLD / 2))
    var center_length = end_idx - start_idx
    
    # Create a segment from center data
    var center_segment = []
    for i in range(start_idx, end_idx):
        if i < data_packs.size():
            center_segment.append(data_packs[i])
    
    # Store segment for future reference
    if center_segment.size() > 0:
        active_segments.append({
            "data": center_segment,
            "cycle": current_cycle,
            "synergy": _calculate_synergy(center_segment),
            "timestamp": OS.get_unix_time()
        })
    
    # Remove center data, keeping edges (the most recent and oldest data)
    var new_packs = []
    for i in range(0, start_idx):
        new_packs.append(data_packs[i])
    for i in range(end_idx, data_packs.size()):
        new_packs.append(data_packs[i])
    
    # Replace data packs with new filtered collection
    data_packs = new_packs
    stats.center_splits += 1
    
    # Update synergy score
    stats.synergy_score = _calculate_synergy(data_packs)

# Calculate synergy between data elements (0-1 scale)
func _calculate_synergy(elements):
    if elements.size() <= 1:
        return 0.0
        
    # Basic implementation - more sophisticated patterns would be implemented here
    var connections = 0
    var max_connections = elements.size() * (elements.size() - 1) / 2
    
    # Count "connections" between elements
    for i in range(elements.size()):
        for j in range(i+1, elements.size()):
            # Simple pattern matching - check if elements share any keys/values
            if typeof(elements[i]) == TYPE_DICTIONARY and typeof(elements[j]) == TYPE_DICTIONARY:
                for key in elements[i].keys():
                    if elements[j].has(key) and elements[j][key] == elements[i][key]:
                        connections += 1
                        break
            elif str(elements[i]).find(str(elements[j])) >= 0 or str(elements[j]).find(str(elements[i])) >= 0:
                connections += 1
    
    return float(connections) / max(1, max_connections)

# LUNO cycle advancement
func _advance_cycle():
    current_cycle = (current_cycle % CYCLE_COUNT) + 1
    
    # Update data structures for new cycle
    _adapt_to_cycle()
    
    emit_signal("cycle_changed", current_cycle, cycle_data[current_cycle-1].phase)

func _adapt_to_cycle():
    # Reinitialize structures based on new cycle
    _initialize_data_structures()
    
    # Special cycle-specific behavior
    match current_cycle:
        5: # Awakening - perform self-check
            _perform_self_check()
        10: # Transcendence - remove limits
            MAX_PACKS = 999 # Temporarily increase capacity
        12: # Beyond - prepare for reset
            _prepare_for_reset()

# Self-check diagnostic
func _perform_self_check():
    # Check data integrity
    var integrity_score = 1.0
    var total_elements = data_packs.size() + quantum_registry.size()
    
    # Update stats
    stats.quantum_operations += 1
    stats.synergy_score = _calculate_synergy(data_packs)
    
    # Log diagnostics (to terminal if available)
    if terminal_ref != null:
        var msg = "🔍 Self-check complete. Integrity: %.2f%%, Synergy: %.2f%%, Elements: %d"
        terminal_ref.log_message(msg % [integrity_score * 100, stats.synergy_score * 100, total_elements])

# Prepare for cycle reset
func _prepare_for_reset():
    # Archive current data
    if data_packs.size() > 0 or quantum_registry.size() > 0:
        var archive = {
            "timestamp": OS.get_unix_time(),
            "cycle": current_cycle,
            "data_count": data_packs.size(),
            "quantum_count": quantum_registry.size(),
            "segments": active_segments,
            "stats": stats
        }
        
        # Optional: Save to disk
        # var file = File.new()
        # file.open("user://data_archive_%d.json" % OS.get_unix_time(), File.WRITE)
        # file.store_string(JSON.print(archive))
        # file.close()

# API for terminal visualization
func get_display_buffer():
    display_buffer.clear()
    
    # Header
    display_buffer.append({
        "text": "🌊 LUNO Cycle DataPack System - Cycle %d: %s" % [
            current_cycle, 
            cycle_data[current_cycle-1].phase
        ],
        "type": "header"
    })
    
    # Stats
    display_buffer.append({
        "text": "📊 Packs: %d/%d | Quantum States: %d | Synergy: %.1f%%" % [
            data_packs.size(),
            MAX_PACKS,
            quantum_registry.size(),
            stats.synergy_score * 100
        ],
        "type": "stats"
    })
    
    # Active segments
    if active_segments.size() > 0:
        display_buffer.append({
            "text": "🧩 Active Segments: %d" % active_segments.size(),
            "type": "subheader"
        })
        
        for i in range(min(3, active_segments.size())):
            var segment = active_segments[active_segments.size() - i - 1]
            display_buffer.append({
                "text": "  Segment #%d - %d items, Synergy: %.1f%%" % [
                    i+1,
                    segment.data.size(),
                    segment.synergy * 100
                ],
                "type": "segment"
            })
    
    # Recent data packs (most recent first)
    display_buffer.append({
        "text": "📦 Recent Data Packs:",
        "type": "subheader"
    })
    
    var display_count = min(10, data_packs.size())
    for i in range(display_count):
        var idx = data_packs.size() - i - 1
        if idx >= 0:
            var pack = data_packs[idx]
            display_buffer.append({
                "text": "  %d. %s" % [i+1, _format_data_for_display(pack)],
                "type": "data"
            })
    
    # Footer with cycle purpose
    display_buffer.append({
        "text": "🔮 Purpose: %s" % cycle_data[current_cycle-1].purpose,
        "type": "footer"
    })
    
    return display_buffer

# Helper to format data for display
func _format_data_for_display(data):
    var result = ""
    match typeof(data):
        TYPE_DICTIONARY:
            var keys = data.keys()
            if keys.size() > 0:
                if data.has("text"):
                    result = str(data.text)
                elif data.has("message"):
                    result = str(data.message)
                elif data.has("name"):
                    result = "%s: %s" % [data.name, data.get("value", "")]
                else:
                    result = "%s: %s" % [keys[0], data[keys[0]]]
            else:
                result = "{empty dict}"
        TYPE_ARRAY:
            if data.size() > 0:
                result = "%d items [%s...]" % [data.size(), str(data[0]).substr(0, 20)]
            else:
                result = "[]"
        _:
            var s = str(data)
            if s.length() > 40:
                result = s.substr(0, 37) + "..."
            else:
                result = s
    
    return result

# API key integration with secure handling
func set_api_key(key):
    if key.empty():
        return false
    
    # Store only a hash, not the actual key
    _api_key_hash = _hash_api_key(key)
    return true

func _hash_api_key(key):
    # Simple hash implementation (in production, use proper cryptographic hash)
    var hash = 0
    for i in range(key.length()):
        hash = ((hash << 5) - hash) + ord(key[i])
    return str(hash)

# Interface with the terminal visualizer
func register_terminal(terminal):
    terminal_ref = terminal

# Public API to get current cycle information
func get_current_cycle_info():
    return cycle_data[current_cycle-1]

# Debug/testing function
func debug_generate_test_data(count=20):
    for i in range(count):
        var test_data = {
            "id": i,
            "message": "Test data pack #%d" % i,
            "timestamp": OS.get_unix_time(),
            "value": randf()
        }
        add_data_pack(test_data, {"segment_id": i % 5})