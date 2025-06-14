extends Node

class_name EdenPitopiaIntegration

# ----- EDEN PITOPIA INTEGRATION SYSTEM -----
# This system connects the Eden Harmony system, Pitopia, and Akashic Notepad3D game
# allowing cross-system entity creation, dimension transitions, and word manifestation

# ----- CONSTANTS -----
const MAX_ENTITIES_PER_SYSTEM = 1000
const DIMENSION_NAMES = ["1D", "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "11D", "12D"]
const DIMENSION_SYMBOLS = ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "κ", "λ", "μ"]

# ----- COMPONENT REFERENCES -----
var akashic_notepad = null
var eden_harmony = null
var pitopia = null
var word_manifestation_system = null
var turn_manager = null
var notepad3d_visualizer = null
var akashic_records_manager = null

# ----- ENTITY MAPPING -----
# Maps entities between different systems
var entity_mapping = {
    # Structure:
    # akashic_id: {
    #   eden_id: "id_in_eden",
    #   pitopia_id: "id_in_pitopia",
    #   notepad_id: "id_in_notepad3d",
    #   type: "entity_type",
    #   created_timestamp: 0
    # }
}

# ----- DIMENSION STATE -----
var current_dimension = 2  # Default to 3D (index 2)
var current_dimension_name = "3D"
var current_dimension_symbol = "γ"

# ----- SYSTEM STATE -----
var systems_connected = false
var connection_status = {
    "akashic_notepad": false,
    "eden_harmony": false,
    "pitopia": false
}

# ----- SIGNALS -----
signal system_connected(system_name, success)
signal entity_mapped(akashic_id, system_mappings)
signal dimension_synchronized(dimension_index, dimension_name)
signal word_manifested(word_text, system_name, entity_id)

# ----- INITIALIZATION -----
func _ready():
    print("Eden Pitopia Integration initializing...")
    
    # Connect to core systems
    call_deferred("_discover_and_connect_components")
    
    # Initialize entity mapping storage
    _initialize_entity_storage()

# ----- COMPONENT DISCOVERY -----
func _discover_and_connect_components():
    print("Discovering system components...")
    
    # Try to find core systems in scene tree
    if has_node("/root/AkashicNotepad"):
        akashic_notepad = get_node("/root/AkashicNotepad")
        connection_status.akashic_notepad = true
    
    # Connect to Eden Harmony
    if _connect_to_eden_harmony():
        connection_status.eden_harmony = true
    
    # Connect to Pitopia
    if _connect_to_pitopia():
        connection_status.pitopia = true
    
    # Find Word Manifestation System
    if has_node("/root/WordManifestationSystem"):
        word_manifestation_system = get_node("/root/WordManifestationSystem")
    elif has_node("/root/Main/WordManifestationSystem"):
        word_manifestation_system = get_node("/root/Main/WordManifestationSystem")
    
    # Find Turn Manager
    if has_node("/root/TurnManager"):
        turn_manager = get_node("/root/TurnManager")
        
        # Connect turn signal
        if turn_manager.has_signal("turn_changed"):
            turn_manager.connect("turn_changed", Callable(self, "_on_turn_changed"))
    
    # Find Notepad3D Visualizer
    if has_node("/root/Notepad3DVisualizer"):
        notepad3d_visualizer = get_node("/root/Notepad3DVisualizer")
    elif has_node("/root/Main/Notepad3DVisualizer"):
        notepad3d_visualizer = get_node("/root/Main/Notepad3DVisualizer")
    
    # Find Akashic Records Manager
    var akashic_manager = AkashicRecordsManagerA.get_instance()
    if akashic_manager:
        akashic_records_manager = akashic_manager
    
    # Check if we have the minimal required components
    if akashic_notepad != null or word_manifestation_system != null:
        systems_connected = true
        print("Eden Pitopia Integration: System connected successfully")
    else:
        print("Eden Pitopia Integration: Failed to connect core systems")

# ----- EDEN HARMONY CONNECTION -----
func _connect_to_eden_harmony():
    print("Connecting to Eden Harmony system...")
    
    # Try to find Eden Harmony system
    if has_node("/root/EdenHarmony"):
        eden_harmony = get_node("/root/EdenHarmony")
        emit_signal("system_connected", "eden_harmony", true)
        return true
    
    # Try to load Eden Harmony script and create instance
    var eden_script = load("res://Eden_OS/wish_engine.gd")
    if eden_script:
        eden_harmony = eden_script.new()
        eden_harmony.name = "EdenHarmony"
        add_child(eden_harmony)
        emit_signal("system_connected", "eden_harmony", true)
        return true
    
    print("Eden Harmony system not found")
    emit_signal("system_connected", "eden_harmony", false)
    return false

# ----- PITOPIA CONNECTION -----
func _connect_to_pitopia():
    print("Connecting to Pitopia system...")
    
    # Try to find Pitopia system
    if has_node("/root/Pitopia"):
        pitopia = get_node("/root/Pitopia")
        emit_signal("system_connected", "pitopia", true)
        return true
    
    # Try alternative names
    if has_node("/root/PitopiaSystem"):
        pitopia = get_node("/root/PitopiaSystem")
        emit_signal("system_connected", "pitopia", true)
        return true
    
    print("Pitopia system not found")
    emit_signal("system_connected", "pitopia", false)
    return false

# ----- ENTITY STORAGE -----
func _initialize_entity_storage():
    # Create necessary directories
    var dir = DirAccess.open("user://")
    if dir:
        if not dir.dir_exists("user://entity_mappings/"):
            dir.make_dir_recursive("user://entity_mappings/")
    
    # Try to load existing mappings
    _load_entity_mappings()

# ----- ENTITY MAPPING -----
func _load_entity_mappings():
    if FileAccess.file_exists("user://entity_mappings/mappings.json"):
        var file = FileAccess.open("user://entity_mappings/mappings.json", FileAccess.READ)
        var json_string = file.get_as_text()
        var json = JSON.new()
        var error = json.parse(json_string)
        
        if error == OK:
            var data = json.data
            if typeof(data) == TYPE_DICTIONARY:
                entity_mapping = data
                print("Loaded %d entity mappings" % entity_mapping.size())
    else:
        print("No existing entity mappings found")

func _save_entity_mappings():
    var file = FileAccess.open("user://entity_mappings/mappings.json", FileAccess.WRITE)
    var json_string = JSON.stringify(entity_mapping)
    file.store_string(json_string)
    print("Saved %d entity mappings" % entity_mapping.size())

# ----- TURN SYSTEM INTEGRATION -----
func _on_turn_changed(turn_number, dimension_symbol, dimension_properties):
    # Update internal dimension state
    var dimension_index = turn_number % 12
    
    current_dimension = dimension_index
    current_dimension_name = DIMENSION_NAMES[dimension_index]
    current_dimension_symbol = dimension_symbol
    
    # Synchronize dimensions across systems
    synchronize_dimensions(dimension_index)

# ----- DIMENSION SYNCHRONIZATION -----
func synchronize_dimensions(dimension_index):
    var dimension_name = DIMENSION_NAMES[dimension_index]
    var dimension_symbol = DIMENSION_SYMBOLS[dimension_index]
    
    print("Synchronizing dimension %d (%s: %s) across all systems..." % [
        dimension_index, dimension_name, dimension_symbol
    ])
    
    # Update Word Manifestation System
    if word_manifestation_system and word_manifestation_system.has_method("update_dimension"):
        word_manifestation_system.update_dimension(dimension_index, dimension_name, dimension_symbol)
    
    # Update Eden Harmony
    if eden_harmony and eden_harmony.has_method("set_dimension"):
        eden_harmony.set_dimension(dimension_index, dimension_name)
    
    # Update Pitopia
    if pitopia and pitopia.has_method("change_dimension"):
        pitopia.change_dimension(dimension_index)
    
    # Update Notepad3D Visualizer
    if notepad3d_visualizer and notepad3d_visualizer.has_method("transition_to_dimension"):
        notepad3d_visualizer.transition_to_dimension(dimension_index)
    
    # Emit signal
    emit_signal("dimension_synchronized", dimension_index, dimension_name)
    
    # Return success
    return true

# ----- WORD MANIFESTATION -----
func manifest_word(word_text, system_name="all", dimension=null):
    print("Manifesting word '%s' in system '%s'" % [word_text, system_name])
    
    # Override dimension if provided
    var target_dimension = dimension if dimension != null else current_dimension
    var target_dimension_name = DIMENSION_NAMES[target_dimension]
    
    # Track IDs in different systems
    var entity_ids = {}
    
    # Manifest in specified system or all systems
    if system_name == "all" or system_name == "word_manifestation":
        if word_manifestation_system and word_manifestation_system.has_method("manifest_word"):
            # Synchronize dimension first if needed
            if word_manifestation_system.current_dimension != target_dimension_name:
                word_manifestation_system.update_dimension(
                    target_dimension, target_dimension_name, DIMENSION_SYMBOLS[target_dimension]
                )
            
            # Manifest the word
            var word_data = word_manifestation_system.manifest_word(word_text)
            if word_data:
                entity_ids.word_manifestation = word_data.id
    
    if system_name == "all" or system_name == "eden_harmony":
        if eden_harmony and eden_harmony.has_method("create_word_entity"):
            var eden_id = eden_harmony.create_word_entity(word_text, target_dimension)
            if eden_id:
                entity_ids.eden_harmony = eden_id
    
    if system_name == "all" or system_name == "pitopia":
        if pitopia and pitopia.has_method("create_node"):
            var pitopia_id = pitopia.create_node(word_text, "word", {
                "dimension": target_dimension,
                "text": word_text
            })
            if pitopia_id:
                entity_ids.pitopia = pitopia_id
    
    if system_name == "all" or system_name == "akashic_records":
        if akashic_records_manager and akashic_records_manager.has_method("create_word"):
            var properties = {
                "text": word_text,
                "dimension": target_dimension,
                "power": 10 + word_text.length() * 2,
                "creation_time": Time.get_unix_time_from_system()
            }
            
            var success = akashic_records_manager.create_word(word_text, "word", properties)
            if success:
                entity_ids.akashic_records = word_text
    
    # Create entity mapping if we have multiple IDs
    if entity_ids.size() > 1:
        _create_entity_mapping(word_text, entity_ids)
    
    # Emit signal
    emit_signal("word_manifested", word_text, system_name, entity_ids)
    
    return entity_ids

# ----- ENTITY MAPPING -----
func _create_entity_mapping(entity_id, system_ids):
    # Create mapping entry
    var mapping = {
        "type": "word",
        "created_timestamp": Time.get_unix_time_from_system()
    }
    
    # Add system-specific IDs
    for system in system_ids:
        mapping[system] = system_ids[system]
    
    # Store in mapping dictionary
    entity_mapping[entity_id] = mapping
    
    # Save mappings
    _save_entity_mappings()
    
    # Emit signal
    emit_signal("entity_mapped", entity_id, mapping)
    
    return mapping

# ----- ENTITY CONNECTION -----
func connect_entities(entity1_id, entity2_id, connection_type="default"):
    print("Connecting entities '%s' and '%s'" % [entity1_id, entity2_id])
    
    # Check if entities exist in mappings
    var entity1_exists = entity_mapping.has(entity1_id)
    var entity2_exists = entity_mapping.has(entity2_id)
    
    # If not in mappings, check individual systems
    if not entity1_exists:
        if word_manifestation_system and word_manifestation_system.manifested_words.has(entity1_id):
            entity1_exists = true
    
    if not entity2_exists:
        if word_manifestation_system and word_manifestation_system.manifested_words.has(entity2_id):
            entity2_exists = true
    
    # Fail if either entity doesn't exist
    if not entity1_exists or not entity2_exists:
        print("Cannot connect: One or both entities don't exist")
        return false
    
    # Connect in Word Manifestation System
    var connection_created = false
    
    if word_manifestation_system and word_manifestation_system.has_method("connect_words"):
        var word1_id = entity1_id
        var word2_id = entity2_id
        
        # If we have mappings, use the word manifestation IDs
        if entity_mapping.has(entity1_id) and entity_mapping[entity1_id].has("word_manifestation"):
            word1_id = entity_mapping[entity1_id].word_manifestation
        
        if entity_mapping.has(entity2_id) and entity_mapping[entity2_id].has("word_manifestation"):
            word2_id = entity_mapping[entity2_id].word_manifestation
        
        var connection = word_manifestation_system.connect_words(word1_id, word2_id)
        if connection:
            connection_created = true
    
    # Connect in Eden Harmony
    if eden_harmony and eden_harmony.has_method("connect_entities"):
        var eden1_id = entity1_id
        var eden2_id = entity2_id
        
        # If we have mappings, use the eden harmony IDs
        if entity_mapping.has(entity1_id) and entity_mapping[entity1_id].has("eden_harmony"):
            eden1_id = entity_mapping[entity1_id].eden_harmony
        
        if entity_mapping.has(entity2_id) and entity_mapping[entity2_id].has("eden_harmony"):
            eden2_id = entity_mapping[entity2_id].eden_harmony
        
        var success = eden_harmony.connect_entities(eden1_id, eden2_id, connection_type)
        if success:
            connection_created = true
    
    # Connect in Pitopia
    if pitopia and pitopia.has_method("create_connection"):
        var pitopia1_id = entity1_id
        var pitopia2_id = entity2_id
        
        # If we have mappings, use the pitopia IDs
        if entity_mapping.has(entity1_id) and entity_mapping[entity1_id].has("pitopia"):
            pitopia1_id = entity_mapping[entity1_id].pitopia
        
        if entity_mapping.has(entity2_id) and entity_mapping[entity2_id].has("pitopia"):
            pitopia2_id = entity_mapping[entity2_id].pitopia
        
        var connection_id = pitopia.create_connection(pitopia1_id, pitopia2_id, connection_type)
        if connection_id:
            connection_created = true
    
    return connection_created

# ----- ENTITY EVOLUTION -----
func evolve_entity(entity_id, force_stage=null):
    print("Evolving entity '%s'" % entity_id)
    
    # Track evolution success across systems
    var evolution_success = false
    
    # Evolve in Word Manifestation System
    if word_manifestation_system and word_manifestation_system.has_method("evolve_word"):
        var word_id = entity_id
        
        # If we have mapping, use the word manifestation ID
        if entity_mapping.has(entity_id) and entity_mapping[entity_id].has("word_manifestation"):
            word_id = entity_mapping[entity_id].word_manifestation
        
        // If force_stage is provided and word manifestation system supports it
        if force_stage != null and word_manifestation_system.manifested_words.has(word_id):
            var current_stage = word_manifestation_system.manifested_words[word_id].evolution_stage
            
            // Evolve multiple times if needed
            while current_stage < force_stage:
                var success = word_manifestation_system.evolve_word(word_id)
                if not success:
                    break
                    
                current_stage += 1
                evolution_success = true
        else:
            // Standard evolution
            evolution_success = word_manifestation_system.evolve_word(word_id)
    
    // Evolve in Eden Harmony if it supports evolution
    if eden_harmony and eden_harmony.has_method("evolve_entity"):
        var eden_id = entity_id
        
        // If we have mapping, use the eden harmony ID
        if entity_mapping.has(entity_id) and entity_mapping[entity_id].has("eden_harmony"):
            eden_id = entity_mapping[entity_id].eden_harmony
        
        var success = eden_harmony.evolve_entity(eden_id, force_stage)
        if success:
            evolution_success = true
    
    // Evolve in Pitopia if it supports evolution
    if pitopia and pitopia.has_method("evolve_node"):
        var pitopia_id = entity_id
        
        // If we have mapping, use the pitopia ID
        if entity_mapping.has(entity_id) and entity_mapping[entity_id].has("pitopia"):
            pitopia_id = entity_mapping[entity_id].pitopia
        
        var success = pitopia.evolve_node(pitopia_id, force_stage)
        if success:
            evolution_success = true
    
    // Create Akashic record for the evolution if successful
    if evolution_success and akashic_records_manager:
        // Create or update evolution record
        var properties = {
            "entity_id": entity_id,
            "evolution_time": Time.get_unix_time_from_system(),
            "dimension": current_dimension,
            "dimension_name": current_dimension_name,
            "target_stage": force_stage
        }
        
        if entity_mapping.has(entity_id):
            properties.mappings = entity_mapping[entity_id]
        
        // If akashic records supports creating records
        if akashic_records_manager.has_method("create_word"):
            var record_id = "evolution_" + entity_id + "_" + str(Time.get_unix_time_from_system())
            akashic_records_manager.create_word(record_id, "evolution_record", properties)
    
    return evolution_success

# ----- TURN SYSTEM FUNCTIONS -----
func advance_turn():
    if turn_manager and turn_manager.has_method("advance_turn"):
        return turn_manager.advance_turn()
    
    // Fallback implementation if turn manager isn't available
    current_dimension = (current_dimension + 1) % 12
    current_dimension_name = DIMENSION_NAMES[current_dimension]
    current_dimension_symbol = DIMENSION_SYMBOLS[current_dimension]
    
    // Synchronize dimensions
    synchronize_dimensions(current_dimension)
    
    return current_dimension

# ----- UTILITY FUNCTIONS -----
func get_current_dimension_info():
    return {
        "index": current_dimension,
        "name": current_dimension_name,
        "symbol": current_dimension_symbol
    }

func get_entity_mapping(entity_id):
    if entity_mapping.has(entity_id):
        return entity_mapping[entity_id]
    return null

func get_all_entities_in_dimension(dimension_index=null):
    var target_dimension = dimension_index if dimension_index != null else current_dimension
    var entities = []
    
    // Collect entities from Word Manifestation System
    if word_manifestation_system:
        for word_id in word_manifestation_system.manifested_words:
            var word = word_manifestation_system.manifested_words[word_id]
            if word.dimension == DIMENSION_NAMES[target_dimension]:
                entities.append({
                    "id": word_id,
                    "system": "word_manifestation",
                    "type": "word",
                    "text": word.text,
                    "power": word.power
                })
    
    return entities

# ----- PUBLIC API -----
# These functions are exposed for external systems to access

# Get connection status of all integrated systems
func get_connection_status():
    return connection_status

# Get total number of connected systems
func get_connected_system_count():
    var count = 0
    for system in connection_status:
        if connection_status[system]:
            count += 1
    return count

# Get list of all mapped entities
func get_all_entity_mappings():
    return entity_mapping

# Clean up and disconnect
func disconnect_all_systems():
    print("Disconnecting all systems...")
    
    # Save entity mappings
    _save_entity_mappings()
    
    # Disconnect signals
    if turn_manager and turn_manager.has_signal("turn_changed"):
        if turn_manager.is_connected("turn_changed", Callable(self, "_on_turn_changed")):
            turn_manager.disconnect("turn_changed", Callable(self, "_on_turn_changed"))
    
    # Set connection status to false
    for system in connection_status:
        connection_status[system] = false
    
    systems_connected = false
    
    return true

# Test integration by creating test entities
func run_integration_test():
    print("Running integration test...")
    
    # Test entity creation
    var test_words = ["harmony", "integration", "dimension", "akashic", "notepad", "reality"]
    var created_entities = []
    
    for word in test_words:
        var entity_ids = manifest_word(word)
        created_entities.append({
            "word": word,
            "ids": entity_ids
        })
    
    # Test entity connection
    if created_entities.size() >= 2:
        for i in range(created_entities.size() - 1):
            var entity1 = created_entities[i].word
            var entity2 = created_entities[i + 1].word
            connect_entities(entity1, entity2)
    
    # Test dimension synchronization
    for i in range(3):
        var dim = (current_dimension + i + 1) % 12
        synchronize_dimensions(dim)
        await get_tree().create_timer(1.0).timeout
    
    # Return to original dimension
    synchronize_dimensions(current_dimension)
    
    return created_entities