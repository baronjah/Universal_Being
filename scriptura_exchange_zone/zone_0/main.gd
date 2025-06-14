extends Node

# Main controller for JSH 12-turn system with divine word processing
# Integrates with 3D notepad visualization, multiverse evolution, and divine memory

# ----- SYSTEM CONSTANTS -----
const TURNS_PER_SECOND = 12 # 12 turns per second for quantum speed
const TURN_DURATION = 1.0 / TURNS_PER_SECOND
const MAX_TURNS = 12
const AUTO_SAVE_INTERVAL = 60.0 # Save every minute

# ----- COSMIC AGES -----
var cosmic_ages = [
    "Genesis", "Formation", "Complexity", "Consciousness", 
    "Awakening", "Enlightenment", "Manifestation", "Connection", 
    "Harmony", "Transcendence", "Unity", "Beyond"
]

var turn_symbols = ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "κ", "λ", "μ"]
var turn_dimensions = ["1D", "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "11D", "12D"]

# ----- STATE VARIABLES -----
var current_turn = 3 # Starting at gamma (3D - Space)
var current_age_index = 0
var turn_timer = 0.0
var auto_advance_turns = false
var time_since_last_save = 0.0
var quantum_loop_active = false
var big_bang_timestamp = 0
var universe_age = 0

# ----- COMPONENT REFERENCES -----
var word_processor: DivineWordProcessor
var turn_history = []
var current_notes = {}
var active_objects = []

# ----- SIGNALS -----
signal turn_advanced(turn_number, symbol, dimension)
signal note_created(note_data)
signal word_manifested(word, position, power)
signal reality_changed(reality_data)

# ----- INITIALIZATION -----
func _ready():
    print("JSH 12-Turn System initializing...")
    
    # Initialize word processor
    word_processor = DivineWordProcessor.new()
    add_child(word_processor)
    
    # Connect signals
    word_processor.connect("word_processed", self, "_on_word_processed")
    word_processor.connect("reality_created", self, "_on_reality_created")
    word_processor.connect("memory_stored", self, "_on_memory_stored")
    
    # Record big bang timestamp
    big_bang_timestamp = OS.get_unix_time()
    
    # Setup folders
    _ensure_directories_exist()
    
    # Initial turn setup
    _set_current_turn(current_turn)
    
    # Initial status message
    print("System initialized at Turn %d: %s - %s - %s" % 
          [current_turn, turn_symbols[current_turn-1], turn_dimensions[current_turn-1], cosmic_ages[current_turn-1]])
    
    # Initial memory creation
    word_processor.process_text("JSH 12-Turn System has been initialized in the " + cosmic_ages[current_turn-1] + " age", "system", 3)

# ----- PROCESS FUNCTION -----
func _process(delta):
    # Update universe age
    universe_age = OS.get_unix_time() - big_bang_timestamp
    
    # Handle automatic turn advancement
    if quantum_loop_active or auto_advance_turns:
        turn_timer += delta
        
        if turn_timer >= TURN_DURATION:
            turn_timer -= TURN_DURATION
            advance_turn()
    
    # Auto-save timer
    time_since_last_save += delta
    if time_since_last_save >= AUTO_SAVE_INTERVAL:
        time_since_last_save = 0
        auto_save()

# ----- TURN MANAGEMENT -----
func advance_turn():
    var prev_turn = current_turn
    
    # Advance to next turn
    current_turn = (current_turn % MAX_TURNS) + 1
    
    # Record in turn history
    _record_turn_transition(prev_turn, current_turn)
    
    # Update current turn state
    _set_current_turn(current_turn)
    
    # Emit signal
    emit_signal("turn_advanced", current_turn, turn_symbols[current_turn-1], turn_dimensions[current_turn-1])
    
    # Log turn advancement
    print("Advanced to Turn %d: %s - %s - %s" % 
          [current_turn, turn_symbols[current_turn-1], turn_dimensions[current_turn-1], cosmic_ages[current_turn-1]])
    
    # Check for age advancement
    if current_turn == 1:
        advance_age()
    
    return current_turn

func advance_age():
    current_age_index = (current_age_index + 1) % cosmic_ages.size()
    
    # Log age advancement
    print("Advanced to new cosmic age: %s" % cosmic_ages[current_age_index])
    
    # Create memory of age advancement
    word_processor.process_text("Entering new cosmic age: " + cosmic_ages[current_age_index], "system", 2)
    
    return cosmic_ages[current_age_index]

func _set_current_turn(turn_number):
    current_turn = turn_number
    
    # Save current turn to file for external systems
    var file = File.new()
    file.open("user://current_turn.txt", File.WRITE)
    file.store_string(str(current_turn))
    file.close()
    
    # Save to system directory for bash integration
    _save_to_system_dir("current_turn.txt", str(current_turn))

func _record_turn_transition(from_turn, to_turn):
    var transition = {
        "from_turn": from_turn,
        "to_turn": to_turn,
        "from_symbol": turn_symbols[from_turn-1],
        "to_symbol": turn_symbols[to_turn-1],
        "from_dimension": turn_dimensions[from_turn-1],
        "to_dimension": turn_dimensions[to_turn-1],
        "timestamp": OS.get_unix_time(),
        "universe_age": universe_age
    }
    
    turn_history.append(transition)
    
    # Keep history at reasonable size
    if turn_history.size() > 1000:
        turn_history.pop_front()

# ----- NOTE MANAGEMENT -----
func create_note(text, position=Vector3(0,0,0)):
    # Process the text through divine word processor
    var result = word_processor.process_text(text, "note", 1)
    
    # Create note data with positioning
    var note_id = "note_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)
    var note_data = {
        "id": note_id,
        "text": result.corrected,
        "position": position,
        "turn": current_turn,
        "turn_symbol": turn_symbols[current_turn-1],
        "dimension": turn_dimensions[current_turn-1],
        "timestamp": OS.get_unix_time(),
        "power": result.total_power,
        "powerful_words": result.powerful_words
    }
    
    # Store the note
    current_notes[note_id] = note_data
    
    # Save note to file
    _save_note_to_file(note_data)
    
    # Emit signal
    emit_signal("note_created", note_data)
    
    print("Note created in Turn %d (%s - %s)" % 
          [current_turn, turn_symbols[current_turn-1], turn_dimensions[current_turn-1]])
    
    # Special processing for high-power notes
    if result.total_power > 50:
        _manifest_powerful_note(note_data)
    
    return note_data

func get_notes_for_current_turn():
    var turn_notes = []
    
    for note_id in current_notes:
        if current_notes[note_id].turn == current_turn:
            turn_notes.append(current_notes[note_id])
    
    return turn_notes

func _manifest_powerful_note(note_data):
    print("Powerful note manifesting in reality!")
    
    # Extract powerful words from the note
    for word_data in note_data.powerful_words:
        var word = word_data.word
        var power = word_data.power
        
        # Calculate position based on note position with slight randomization
        var pos = note_data.position + Vector3(
            rand_range(-1, 1),
            rand_range(-1, 1),
            rand_range(-1, 1)
        )
        
        # Emit signal for 3D visualization
        emit_signal("word_manifested", word, pos, power)
        
        # Add to active objects
        active_objects.append({
            "word": word,
            "position": pos,
            "power": power,
            "creation_turn": current_turn,
            "age": universe_age
        })

# ----- QUANTUM LOOP FUNCTIONS -----
func start_quantum_loop():
    quantum_loop_active = true
    turn_timer = 0
    print("Quantum loop started - 12 turns per second")
    
    # Create memory
    word_processor.process_text("Quantum loop activated at 12 turns per second in the " + cosmic_ages[current_age_index] + " age", "system", 2)
    
    return true

func stop_quantum_loop():
    quantum_loop_active = false
    print("Quantum loop stopped")
    
    # Create memory
    word_processor.process_text("Quantum loop deactivated in the " + cosmic_ages[current_age_index] + " age", "system", 2)
    
    return false

# ----- FILE OPERATIONS -----
func _ensure_directories_exist():
    var dir = Directory.new()
    
    # Ensure save directories exist
    if !dir.dir_exists("user://notes"):
        dir.make_dir_recursive("user://notes")
    
    if !dir.dir_exists("user://realities"):
        dir.make_dir_recursive("user://realities")
    
    if !dir.dir_exists("user://turns"):
        dir.make_dir_recursive("user://turns")

func _save_note_to_file(note_data):
    var file = File.new()
    var note_path = "user://notes/note_" + note_data.id + ".json"
    
    file.open(note_path, File.WRITE)
    file.store_string(JSON.print(note_data, "  "))
    file.close()

func _save_to_system_dir(filename, content):
    # This attempts to write to the system directory for bash script integration
    # NOTE: This might require proper permissions and won't work in all environments
    var file = File.new()
    var system_path = "/mnt/c/Users/Percision 15/12_turns_system/" + filename
    
    var err = file.open(system_path, File.WRITE)
    if err == OK:
        file.store_string(content)
        file.close()

# ----- SAVE & LOAD -----
func auto_save():
    var save_name = "autosave_turn_" + str(current_turn)
    save_reality(save_name)
    
    # Log autosave
    print("Auto-saved reality state at Turn %d" % current_turn)
    
    return save_name

func save_reality(save_name):
    # Use word processor to save reality state
    var save_data = word_processor.save_reality_state(save_name)
    
    # Add turn-specific data
    save_data.turn = current_turn
    save_data.turn_symbol = turn_symbols[current_turn-1]
    save_data.dimension = turn_dimensions[current_turn-1]
    save_data.age = cosmic_ages[current_age_index]
    save_data.universe_age = universe_age
    save_data.notes = current_notes.duplicate()
    save_data.quantum_loop_active = quantum_loop_active
    
    # Create memory of reality save
    word_processor.process_text("Reality state saved as: " + save_name, "system", 2)
    
    return save_data

# ----- EVENT HANDLERS -----
func _on_word_processed(word, power):
    # Handle word processing event
    if power > 75:
        print("Divine word detected: %s (Power: %d)" % [word, power])

func _on_reality_created(reality_data):
    # Handle reality creation event
    emit_signal("reality_changed", reality_data)
    
    # Add special effect if this is a very powerful reality
    if reality_data.is_persistent:
        print("A persistent reality has formed...")
        
        # This would trigger special visualization in the actual game

func _on_memory_stored(memory_data):
    # Handle memory stored event
    if memory_data.tier == 3:
        print("Eternal memory has been preserved in Tier 3")

# ----- COMMAND FUNCTIONS -----
func execute_command(command_text):
    # Parse command
    var parts = command_text.split(" ", true, 1)
    var command = parts[0].strip_edges().to_lower()
    var args = parts[1] if parts.size() > 1 else ""
    
    # Process command
    match command:
        "/turn":
            return advance_turn()
            
        "/loop":
            if quantum_loop_active:
                return stop_quantum_loop()
            else:
                return start_quantum_loop()
        
        "/note":
            if args.strip_edges().empty():
                return "Error: Note text required"
            return create_note(args)
        
        "/save":
            var name = args.strip_edges()
            if name.empty():
                name = "manual_save_" + str(OS.get_unix_time())
            return save_reality(name)
        
        "/status":
            return show_status()
        
        "/word-power":
            if args.strip_edges().empty():
                return "Error: Word required"
            var word = args.strip_edges()
            var power = word_processor.check_word_power(word)
            print("The word '%s' has power: %d" % [word, power])
            return power
        
        "/memory":
            if args.strip_edges().empty():
                return "Error: Memory text required"
            var tier = 1
            if args.ends_with(" 2"):
                tier = 2
                args = args.substr(0, args.length() - 2).strip_edges()
            elif args.ends_with(" 3"):
                tier = 3
                args = args.substr(0, args.length() - 2).strip_edges()
            
            var result = word_processor.process_text(args, "command", tier)
            return "Memory created with power: " + str(result.total_power)
        
        "/memories":
            return show_memories()
            
        _:
            print("Unknown command: " + command)
            return "Unknown command: " + command

func show_status():
    var status = word_processor.get_divine_status()
    
    var status_text = """
=== DIVINE STATUS ===
Turn: %d (%s - %s)
Age: %s
Universe Age: %d seconds
Divine Level: %d (%s)
Words Processed: %d
Realities Created: %d
Memories: %d
Notes: %d
Quantum Loop: %s
""" % [
        current_turn, turn_symbols[current_turn-1], turn_dimensions[current_turn-1],
        cosmic_ages[current_age_index],
        universe_age,
        status.level, status.status,
        status.words_processed,
        status.realities_created,
        status.memory_count,
        current_notes.size(),
        "Active" if quantum_loop_active else "Inactive"
    ]
    
    print(status_text)
    return status

func show_memories():
    var all_memories = []
    
    # Get memories from each tier
    for tier in range(1, 4):
        var tier_memories = word_processor.get_memories_by_tier(tier)
        print("=== TIER %d MEMORIES (%d) ===" % [tier, tier_memories.size()])
        
        for memory in tier_memories:
            print("- \"%s\" (Power: %d)" % [memory.text, memory.power])
            all_memories.append(memory)
    
    return all_memories