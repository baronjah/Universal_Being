extends Node

class_name CyberGateController

# ----- CYBER GATE CONTROLLER -----
# Manages transitions between realities, dimensions, and data sewers
# Controls the "Moon Man" game flow and data processing

# ----- GATE CONSTANTS -----
const REALITIES = ["physical", "digital", "astral", "quantum", "memory", "dream"]
const GATE_TYPES = ["standard", "quantum", "forced", "bypass", "hidden"]
const DATA_PACKET_SIZES = [1024, 2048, 4096, 8192, 16384, 32768]
const MAX_GATES_PER_REALITY = 7
const CYCLE_TIME = 12.0 # Full cycle time in seconds (12 turns)

# ----- GATE STRUCTURE -----
var active_gates = {}
var gate_connections = {}
var active_reality = "digital" # Default starting reality
var target_reality = ""
var reality_transition_progress = 0.0
var current_cycle_time = 0.0
var in_transition = false
var transition_type = "standard"
var moon_phase = 0 # 0-7, affects gate stability

# ----- DATA MANAGEMENT -----
var data_sewers = {}
var pending_data_packets = []
var processed_data = {}
var data_corruption_level = 0.0 # 0.0 to 1.0
var sewer_cleanup_timer = 0.0
var cleanup_interval = 60.0 # Clean sewers every minute

# ----- SUBSYSTEM REFERENCES -----
var word_processor = null
var word_manifestation = null
var visualizer = null
var main_system = null

# ----- SIGNALS -----
signal gate_created(gate_id, gate_data)
signal gate_activated(gate_id)
signal gate_destroyed(gate_id)
signal reality_transition_started(from_reality, to_reality)
signal reality_transition_completed(to_reality)
signal data_packet_processed(packet_id, result)
signal sewer_cleaned(sewer_id, bytes_cleaned)
signal moon_phase_changed(old_phase, new_phase)

# ----- INITIALIZATION -----
func _ready():
    print("Cyber Gate Controller initializing...")
    initialize_sewers()
    initialize_moon_phases()
    print("Cyber Gate Controller ready")

# ----- PROCESS -----
func _process(delta):
    # Handle reality transitions
    if in_transition:
        process_reality_transition(delta)
    
    # Update cycle time - controls synchronized turns
    current_cycle_time += delta
    if current_cycle_time >= CYCLE_TIME:
        current_cycle_time = 0.0
        on_full_cycle_completed()
    
    # Process pending data packets
    process_data_packets(delta)
    
    # Periodically clean sewers
    sewer_cleanup_timer += delta
    if sewer_cleanup_timer >= cleanup_interval:
        sewer_cleanup_timer = 0.0
        clean_all_sewers()
    
    # Update moon phases every cycle
    if current_cycle_time < delta:
        advance_moon_phase()

# ----- GATE MANAGEMENT -----
func create_gate(position, gate_type="standard", source_reality=null, target_reality=null):
    if source_reality == null:
        source_reality = active_reality
    
    if target_reality == null:
        # Choose random target different from source
        var available_realities = REALITIES.duplicate()
        available_realities.erase(source_reality)
        target_reality = available_realities[randi() % available_realities.size()]
    
    # Check if max gates reached for this reality
    var existing_gates = 0
    for gate_id in active_gates:
        if active_gates[gate_id].source_reality == source_reality:
            existing_gates += 1
    
    if existing_gates >= MAX_GATES_PER_REALITY:
        print("Maximum gates reached for reality: %s" % source_reality)
        return null
    
    # Generate unique gate ID
    var gate_id = "gate_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)
    
    # Calculate stability based on moon phase and gate type
    var base_stability = 0.7
    var moon_factor = (7 - abs(moon_phase - 3.5)) / 7.0  # More stable at phase 3-4
    var type_stability = {
        "standard": 1.0,
        "quantum": 0.8,
        "forced": 0.6,
        "bypass": 0.5,
        "hidden": 0.9
    }
    
    var stability = base_stability * moon_factor * type_stability[gate_type]
    
    # Create gate data
    var gate_data = {
        "id": gate_id,
        "position": position,
        "source_reality": source_reality,
        "target_reality": target_reality,
        "type": gate_type,
        "creation_time": OS.get_unix_time(),
        "stability": stability,
        "active": true,
        "uses": 0,
        "data_throughput": 0,
        "cycle_signature": current_cycle_time,
        "moon_phase": moon_phase
    }
    
    # Store gate
    active_gates[gate_id] = gate_data
    
    # Create gate connection record
    if not gate_connections.has(source_reality):
        gate_connections[source_reality] = {}
    
    if not gate_connections[source_reality].has(target_reality):
        gate_connections[source_reality][target_reality] = []
    
    gate_connections[source_reality][target_reality].append(gate_id)
    
    # Emit signal
    emit_signal("gate_created", gate_id, gate_data)
    
    print("Cyber Gate created: %s → %s (Stability: %.2f)" % [source_reality, target_reality, stability])
    
    return gate_data

func activate_gate(gate_id):
    # Verify gate exists
    if not active_gates.has(gate_id):
        print("Error: Gate %s does not exist" % gate_id)
        return false
    
    var gate = active_gates[gate_id]
    
    # Check if already in transition
    if in_transition:
        print("Error: Already in reality transition")
        return false
    
    # Check if gate is in current reality
    if gate.source_reality != active_reality:
        print("Error: Gate %s is not in current reality" % gate_id)
        return false
    
    # Begin transition to target reality
    begin_reality_transition(gate.target_reality, gate.type)
    
    # Update gate usage stats
    gate.uses += 1
    gate.last_used = OS.get_unix_time()
    
    # Emit signal
    emit_signal("gate_activated", gate_id)
    
    print("Gate activated: %s → %s" % [gate.source_reality, gate.target_reality])
    
    return true

func destroy_gate(gate_id):
    # Verify gate exists
    if not active_gates.has(gate_id):
        print("Error: Gate %s does not exist" % gate_id)
        return false
    
    var gate = active_gates[gate_id]
    
    # Remove from connections
    if gate_connections.has(gate.source_reality) and gate_connections[gate.source_reality].has(gate.target_reality):
        gate_connections[gate.source_reality][gate.target_reality].erase(gate_id)
    
    # Remove gate
    active_gates.erase(gate_id)
    
    # Emit signal
    emit_signal("gate_destroyed", gate_id)
    
    print("Gate destroyed: %s" % gate_id)
    
    return true

func get_gates_in_reality(reality):
    var gates = []
    
    for gate_id in active_gates:
        if active_gates[gate_id].source_reality == reality:
            gates.append(active_gates[gate_id])
    
    return gates

# ----- REALITY TRANSITIONS -----
func begin_reality_transition(to_reality, transition_type="standard"):
    # Skip if already in transition
    if in_transition:
        return false
    
    # Skip if same reality
    if to_reality == active_reality:
        return false
    
    in_transition = true
    target_reality = to_reality
    self.transition_type = transition_type
    reality_transition_progress = 0.0
    
    # Emit signal
    emit_signal("reality_transition_started", active_reality, to_reality)
    
    print("Reality transition started: %s → %s (Type: %s)" % [active_reality, to_reality, transition_type])
    
    return true

func process_reality_transition(delta):
    if not in_transition:
        return
    
    # Calculate speed modifier based on transition type
    var speed_modifier = {
        "standard": 1.0,
        "quantum": 2.0,
        "forced": 1.5,
        "bypass": 3.0,
        "hidden": 0.7
    }
    
    # Update progress
    reality_transition_progress += delta * speed_modifier[transition_type]
    
    # Process transition effects - could be expanded with visual effects
    process_transition_effects(reality_transition_progress)
    
    # Check if transition complete
    if reality_transition_progress >= 1.0:
        complete_reality_transition()

func process_transition_effects(progress):
    # This would be expanded with actual transition effects
    # For now just handle data corruption during transition
    
    # Data becomes more corrupted during transitions
    var corruption_spike = sin(progress * PI) * 0.5
    data_corruption_level = min(1.0, data_corruption_level + corruption_spike * 0.1)
    
    # Modify word manifestation properties during transition
    if word_manifestation != null:
        # Adding jitter to manifestation
        if progress > 0.3 and progress < 0.7:
            # Highest disruption in middle of transition
            var disruption = sin(progress * PI) * 0.3
            
            # This would affect word manifestation behavior
            # Placeholder for implementation
            pass

func complete_reality_transition():
    # Transition is complete
    var old_reality = active_reality
    active_reality = target_reality
    in_transition = false
    reality_transition_progress = 0.0
    
    # Emit signal
    emit_signal("reality_transition_completed", target_reality)
    
    print("Reality transition completed: %s → %s" % [old_reality, active_reality])
    
    # Apply reality-specific effects
    apply_reality_effects(active_reality)
    
    # Generate new data from transition
    generate_transition_data(old_reality, active_reality)
    
    return true

func apply_reality_effects(reality):
    # Apply effects specific to each reality
    match reality:
        "physical":
            data_corruption_level = max(0.0, data_corruption_level - 0.2)
            
            # Affect word manifestation
            if word_manifestation != null:
                # Physical reality makes words more stable
                # Placeholder for implementation
                pass
        
        "digital":
            # Higher data processing in digital reality
            process_pending_data(5)
            
            # Affect word manifestation
            if word_manifestation != null:
                # Digital reality makes words more structured
                # Placeholder for implementation
                pass
        
        "astral":
            # Higher corruption but more creative manifestation
            data_corruption_level = min(1.0, data_corruption_level + 0.1)
            
            # Affect word manifestation
            if word_manifestation != null:
                # Astral reality makes words more fluid
                # Placeholder for implementation
                pass
        
        "quantum":
            # Unpredictable effects
            if randf() < 0.5:
                data_corruption_level = randf()
            
            # Affect word manifestation
            if word_manifestation != null:
                # Quantum reality makes words probabilistic
                # Placeholder for implementation
                pass
        
        "memory":
            # Process stored data
            process_memory_data()
            
            # Affect word manifestation
            if word_manifestation != null:
                # Memory reality makes words more persistent
                # Placeholder for implementation
                pass
        
        "dream":
            # High creativity, high corruption
            data_corruption_level = min(1.0, data_corruption_level + 0.3)
            
            # Affect word manifestation
            if word_manifestation != null:
                # Dream reality makes words more abstract
                # Placeholder for implementation
                pass

# ----- DATA MANAGEMENT -----
func initialize_sewers():
    # Create sewer structures for each reality
    for reality in REALITIES:
        data_sewers[reality] = {
            "capacity": 1024 * 1024 * 10, # 10MB initial capacity
            "used": 0,
            "packets": [],
            "last_cleaned": OS.get_unix_time(),
            "corruption_level": 0.0
        }
    
    print("Data sewers initialized for %d realities" % REALITIES.size())

func process_data_packets(delta):
    # Process a limited number of packets per frame
    var packets_to_process = min(5, pending_data_packets.size())
    
    for i in range(packets_to_process):
        if pending_data_packets.size() > 0:
            var packet = pending_data_packets.pop_front()
            process_data_packet(packet)

func process_data_packet(packet):
    # Apply data corruption
    if randf() < data_corruption_level:
        corrupt_data_packet(packet)
    
    # Process data based on type
    var result = null
    
    match packet.type:
        "word":
            # Manifest word from data
            if word_manifestation != null:
                var word = extract_word_from_data(packet.data)
                var position = Vector3(
                    rand_range(-5, 5),
                    rand_range(0, 5),
                    rand_range(-5, 5)
                )
                
                result = word_manifestation.manifest_word(word, position)
        
        "command":
            # Execute command from data
            if main_system != null:
                var command = extract_command_from_data(packet.data)
                result = main_system.execute_command(command)
        
        "gate":
            # Create gate from data
            var gate_type = extract_gate_type_from_data(packet.data)
            var position = Vector3(
                rand_range(-10, 10),
                rand_range(0, 10),
                rand_range(-10, 10)
            )
            
            result = create_gate(position, gate_type)
        
        "memory":
            # Create memory from data
            if word_processor != null:
                var memory_text = extract_text_from_data(packet.data)
                var tier = int(min(3, 1 + packet.size / 4096))
                
                result = word_processor.process_text(memory_text, "data", tier)
    
    # Store processed result
    processed_data[packet.id] = {
        "original": packet,
        "result": result,
        "timestamp": OS.get_unix_time()
    }
    
    # Direct to sewer if needed
    if packet.size > 4096:
        send_to_sewer(packet)
    
    # Emit signal
    emit_signal("data_packet_processed", packet.id, result)
    
    return result

func corrupt_data_packet(packet):
    # Apply data corruption
    var corruption_amount = data_corruption_level * 0.5
    
    # Corrupt size
    packet.size = int(packet.size * (1.0 + (randf() * 2 - 1) * corruption_amount))
    
    # Corrupt data (simplified)
    if typeof(packet.data) == TYPE_STRING:
        var chars = packet.data.length()
        var corrupt_chars = int(chars * corruption_amount * 0.2)
        
        for i in range(corrupt_chars):
            var pos = randi() % chars
            var char_code = packet.data.ord_at(pos)
            char_code = (char_code + randi() % 10 - 5) % 256
            
            var before = packet.data.substr(0, pos)
            var after = packet.data.substr(pos + 1)
            packet.data = before + char(char_code) + after
    
    return packet

func create_data_packet(type, data, size=null):
    # Generate appropriate size if not specified
    if size == null:
        if typeof(data) == TYPE_STRING:
            size = data.length()
        else:
            size = DATA_PACKET_SIZES[randi() % DATA_PACKET_SIZES.size()]
    
    # Generate unique packet ID
    var packet_id = "packet_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)
    
    # Create packet data
    var packet = {
        "id": packet_id,
        "type": type,
        "data": data,
        "size": size,
        "creation_time": OS.get_unix_time(),
        "reality": active_reality,
        "moon_phase": moon_phase,
        "cycle_time": current_cycle_time
    }
    
    # Add to pending packets
    pending_data_packets.append(packet)
    
    return packet

func send_to_sewer(packet):
    # Direct large or corrupted data to sewers
    var sewer = data_sewers[active_reality]
    
    # Add to sewer
    sewer.packets.append(packet)
    sewer.used += packet.size
    
    # Update corruption level
    sewer.corruption_level = max(sewer.corruption_level, data_corruption_level)
    
    return true

func clean_sewer(reality):
    # Clean a specific reality's sewer
    if not data_sewers.has(reality):
        return 0
    
    var sewer = data_sewers[reality]
    var packets_before = sewer.packets.size()
    var bytes_before = sewer.used
    
    # Remove oldest packets first
    var packets_to_keep = []
    var keep_threshold = OS.get_unix_time() - (86400 * 3) # Keep last 3 days
    
    for packet in sewer.packets:
        if packet.creation_time > keep_threshold:
            packets_to_keep.append(packet)
    
    # Update sewer
    sewer.packets = packets_to_keep
    sewer.used = 0
    
    # Recalculate used size
    for packet in sewer.packets:
        sewer.used += packet.size
    
    # Update last cleaned time
    sewer.last_cleaned = OS.get_unix_time()
    
    # Calculate cleaned amount
    var packets_removed = packets_before - sewer.packets.size()
    var bytes_cleaned = bytes_before - sewer.used
    
    # Emit signal
    emit_signal("sewer_cleaned", reality, bytes_cleaned)
    
    print("Cleaned %s sewer: removed %d packets, freed %d bytes" % [reality, packets_removed, bytes_cleaned])
    
    return bytes_cleaned

func clean_all_sewers():
    var total_bytes_cleaned = 0
    
    for reality in data_sewers:
        total_bytes_cleaned += clean_sewer(reality)
    
    print("Cleaned all sewers: freed %d bytes total" % total_bytes_cleaned)
    
    return total_bytes_cleaned

# ----- MOON PHASES -----
func initialize_moon_phases():
    # Initialize with random moon phase
    moon_phase = randi() % 8
    print("Moon phase initialized to: %d/7" % moon_phase)

func advance_moon_phase():
    var old_phase = moon_phase
    moon_phase = (moon_phase + 1) % 8
    
    # Emit signal
    emit_signal("moon_phase_changed", old_phase, moon_phase)
    
    print("Moon phase changed: %d → %d" % [old_phase, moon_phase])
    
    # Moon phase affects gate stability
    update_gate_stability()
    
    return moon_phase

func update_gate_stability():
    # Update gate stability based on current moon phase
    for gate_id in active_gates:
        var gate = active_gates[gate_id]
        
        # Calculate moon influence factor
        var moon_influence = (7 - abs(moon_phase - gate.moon_phase)) / 7.0
        
        # Update stability
        gate.stability = clamp(gate.stability * (0.8 + moon_influence * 0.4), 0.1, 1.0)
        
        # Extremely unstable gates may collapse
        if gate.stability < 0.2 and randf() < 0.3:
            print("Gate %s collapsed due to low stability (%.2f)" % [gate_id, gate.stability])
            destroy_gate(gate_id)

# ----- CYCLE MANAGEMENT -----
func on_full_cycle_completed():
    print("Full cycle completed")
    
    # Apply cycle effects
    
    # Clean sewers automatically every few cycles
    if current_cycle_time < 0.1 and randf() < 0.3:
        clean_all_sewers()
    
    # Generate new gates occasionally
    if randf() < 0.2:
        var position = Vector3(
            rand_range(-10, 10),
            rand_range(0, 10),
            rand_range(-10, 10)
        )
        
        create_gate(position)
    
    # Process memory data
    process_memory_data()
    
    # Generate game events
    generate_game_event()

func generate_transition_data(from_reality, to_reality):
    # Generate data based on reality transition
    var data_types = ["word", "command", "gate", "memory"]
    var data_type = data_types[randi() % data_types.size()]
    
    var data = "Transition from %s to %s reality" % [from_reality, to_reality]
    var size = 1024 + randi() % 4096
    
    create_data_packet(data_type, data, size)
    
    return true

func process_memory_data():
    # Process stored memories to generate new insights
    if word_processor == null:
        return
    
    var memories = []
    
    # This would extract memories from word processor
    # Placeholder implementation
    
    for memory in memories:
        # Create data packet from memory
        create_data_packet("memory", memory.text, memory.power * 100)
    
    return memories.size()

func process_pending_data(count=1):
    # Force process a number of pending data packets
    var processed = 0
    
    for i in range(min(count, pending_data_packets.size())):
        if pending_data_packets.size() > 0:
            var packet = pending_data_packets.pop_front()
            process_data_packet(packet)
            processed += 1
    
    return processed

func generate_game_event():
    # Generate random game events
    var event_types = ["gate_malfunction", "data_surge", "reality_echo", "moon_anomaly"]
    var event = event_types[randi() % event_types.size()]
    
    match event:
        "gate_malfunction":
            # Random gate malfunctions
            if active_gates.size() > 0:
                var gate_ids = active_gates.keys()
                var gate_id = gate_ids[randi() % gate_ids.size()]
                
                var gate = active_gates[gate_id]
                gate.stability *= 0.7
                
                print("Gate malfunction event: Gate %s stability reduced to %.2f" % [gate_id, gate.stability])
        
        "data_surge":
            # Create a surge of data
            var data_size = 1024 * (1 + randi() % 16)
            var data = "Data surge event"
            create_data_packet("word", data, data_size)
            
            print("Data surge event: Created %d byte data packet" % data_size)
        
        "reality_echo":
            # Echo between realities
            var source_reality = REALITIES[randi() % REALITIES.size()]
            var target_reality = active_reality
            
            if source_reality != target_reality:
                print("Reality echo event: Echo from %s to %s" % [source_reality, target_reality])
                
                # Transfer data between sewers
                if data_sewers.has(source_reality) and data_sewers.has(target_reality):
                    var source_sewer = data_sewers[source_reality]
                    var target_sewer = data_sewers[target_reality]
                    
                    if source_sewer.packets.size() > 0:
                        var packet = source_sewer.packets[randi() % source_sewer.packets.size()]
                        target_sewer.packets.append(packet)
                        target_sewer.used += packet.size
                        
                        print("Transferred %d byte packet from %s to %s sewer" % [packet.size, source_reality, target_reality])
        
        "moon_anomaly":
            # Moon phase anomaly
            var old_phase = moon_phase
            moon_phase = randi() % 8
            
            print("Moon anomaly event: Phase jumped from %d to %d" % [old_phase, moon_phase])
            emit_signal("moon_phase_changed", old_phase, moon_phase)
            
            # Update gate stability
            update_gate_stability()
    
    return event

# ----- HELPER FUNCTIONS -----
func extract_word_from_data(data):
    # Extract meaningful word from data
    # Simple implementation - extract words if string data
    if typeof(data) == TYPE_STRING:
        var words = data.split(" ")
        if words.size() > 0:
            var word_idx = randi() % words.size()
            return words[word_idx]
    
    return "data"

func extract_command_from_data(data):
    # Extract command from data
    # Simple implementation - extract command if string data
    if typeof(data) == TYPE_STRING:
        if data.begins_with("/"):
            return data
        else:
            return "/note " + data
    
    return "/status"

func extract_gate_type_from_data(data):
    # Extract gate type from data
    # Simple implementation - try to match with known types
    if typeof(data) == TYPE_STRING:
        for type in GATE_TYPES:
            if data.to_lower().find(type) >= 0:
                return type
    
    return "standard"

func extract_text_from_data(data):
    # Extract text from data
    if typeof(data) == TYPE_STRING:
        return data
    
    return "Data conversion"

# ----- PUBLIC API -----
func set_word_processor(processor):
    word_processor = processor
    print("Word processor connected to Cyber Gate Controller")

func set_word_manifestation(system):
    word_manifestation = system
    print("Word manifestation system connected to Cyber Gate Controller")

func set_visualizer(vis):
    visualizer = vis
    print("Visualizer connected to Cyber Gate Controller")

func set_main_system(system):
    main_system = system
    print("Main system connected to Cyber Gate Controller")

func get_current_reality():
    return active_reality

func get_current_moon_phase():
    return moon_phase

func get_sewer_status():
    var status = {}
    
    for reality in data_sewers:
        status[reality] = {
            "capacity": data_sewers[reality].capacity,
            "used": data_sewers[reality].used,
            "packet_count": data_sewers[reality].packets.size(),
            "corruption": data_sewers[reality].corruption_level,
            "last_cleaned": data_sewers[reality].last_cleaned
        }
    
    return status

func get_data_corruption_level():
    return data_corruption_level