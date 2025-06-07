class_name CoreWordManifestor
extends Node

# ----- CONSTANTS -----
const MAX_WORD_HISTORY = 100
const WORD_DB_FILE = "user://word_database.json"
const CONCEPT_MAP_FILE = "user://concept_map.json"

# ----- SINGLETON PATTERN -----
static var _instance = null

static func get_instance() -> CoreWordManifestor:
    if not _instance:
        _instance = CoreWordManifestor.new()
    return _instance

# ----- DICTIONARIES AND MAPS -----
var word_properties = {}      # Known properties of words
var concept_relationships = {} # How concepts connect to each other
var word_history = []         # Recently used words
var word_relationships = {}   # How words relate to each other
var recent_manifestations = [] # Recently manifested words (duplicates word_history)

# ----- WORD ANALYSIS COMPONENTS -----
var phonetic_analyzer = null
var semantic_analyzer = null
var pattern_analyzer = null

# ----- CONFIGURATION -----
var default_manifestation_influence: float = 1.0
var phonetic_weight: float = 0.3
var semantic_weight: float = 0.5
var pattern_weight: float = 0.2

# ----- REFERENCES TO OTHER SYSTEMS -----
var entity_manager = null
var dictionary_manager = null
var map_system = null
var player_node = null

# ----- SIGNALS -----
signal word_manifested(word, entity)
signal concept_discovered(concept, properties)
signal word_combination_created(words, result)
signal word_analyzed(word, analysis)
signal word_relationship_created(word1, word2, relationship_type)

# ----- INITIALIZATION -----
func _init() -> void:
    # Initialize analyzers
    _initialize_analyzers()
    
    # Setup configuration
    _setup_default_configuration()
    
    # Load databases
    load_word_database()
    load_concept_map()

func _ready() -> void:
    # Try to get entity manager if available
    if ClassDB.class_exists("JSHEntityManager"):
        entity_manager = JSHEntityManager.get_instance()
    elif ClassDB.class_exists("CoreEntityManager"):
        entity_manager = CoreEntityManager.get_instance()
    else:
        entity_manager = ThingCreatorA.get_instance()
        print("CoreWordManifestor: Using ThingCreatorA as entity manager")
    
    # Try to get dictionary manager
    if ClassDB.class_exists("JSHDictionaryManager"):
        dictionary_manager = JSHDictionaryManager.get_instance()
        print("CoreWordManifestor: Connected to JSHDictionaryManager")
    elif ClassDB.class_exists("CoreDictionaryManager"):
        dictionary_manager = CoreDictionaryManager.get_instance()
        print("CoreWordManifestor: Connected to CoreDictionaryManager")
    else:
        print("CoreWordManifestor: Dictionary manager not found, dictionary features limited")

func initialize(p_map_system, p_player = null) -> void:
    map_system = p_map_system
    player_node = p_player

func _initialize_analyzers() -> void:
    # Try to get specialized analyzers first
    if ClassDB.class_exists("JSHPhoneticAnalyzer"):
        phonetic_analyzer = JSHPhoneticAnalyzer.get_instance()
        print("CoreWordManifestor: Using JSHPhoneticAnalyzer")
    else:
        phonetic_analyzer = PhoneticAnalyzer.new()
        
    if ClassDB.class_exists("JSHSemanticAnalyzer"):
        semantic_analyzer = JSHSemanticAnalyzer.get_instance()
        print("CoreWordManifestor: Using JSHSemanticAnalyzer")
    else:
        semantic_analyzer = SemanticAnalyzer.new()
        
    if ClassDB.class_exists("JSHPatternAnalyzer"):
        pattern_analyzer = JSHPatternAnalyzer.get_instance()
        print("CoreWordManifestor: Using JSHPatternAnalyzer")
    else:
        pattern_analyzer = PatternAnalyzer.new()

func _setup_default_configuration() -> void:
    # Default settings for word manifestation
    default_manifestation_influence = 1.0
    phonetic_weight = 0.3
    semantic_weight = 0.5
    pattern_weight = 0.2

# ----- CORE MANIFESTATION SYSTEM -----
func manifest_word(word: String, position = null, extra_properties: Dictionary = {}) -> Object:
    """
    Create a universal entity from a word
    """
    # Clean the word
    word = word.strip_edges().to_lower()
    
    if word.is_empty():
        return null
    
    # Add to history
    _add_to_word_history(word)
    
    # Get properties for this word
    var properties = analyze_word(word)
    
    # Merge with extra properties
    for key in extra_properties:
        properties[key] = extra_properties[key]
    
    # Determine position
    var spawn_position = Vector3.ZERO
    if position is Vector3:
        spawn_position = position
    elif player_node:
        # Default to in front of player
        var forward = -player_node.global_transform.basis.z
        spawn_position = player_node.global_position + forward * 2.0
    
    # Create the universal entity
    var entity = null
    
    # Try to create entity using entity manager
    if entity_manager:
        if entity_manager.has_method("create_entity"):
            # Determine entity type based on word analysis
            var entity_type = _determine_entity_type(properties)
            entity = entity_manager.create_entity(entity_type, properties)
        elif entity_manager.has_method("manifest_from_word"):
            # Direct word manifestation
            entity = entity_manager.manifest_from_word(word)
    
    # If entity was created
    if entity:
        # Set source word
        if entity.has_method("set_property"):
            entity.set_property("source_word", word)
        elif entity.has_property("source_word"):
            entity.source_word = word
        
        # Position the entity
        if entity is Node3D:
            entity.global_position = spawn_position
        
        # Add to map system if available
        if map_system and map_system.has_method("add_entity_to_world"):
            map_system.add_entity_to_world(entity, spawn_position)
        
        # Save this word's properties for future use
        _learn_word_properties(word, properties)
        
        emit_signal("word_manifested", word, entity)
    
    return entity

func manifest_word_sequence(sequence: String, start_position: Vector3, spacing: float = 1.5) -> Array:
    """
    Create multiple entities from a sequence of words
    """
    var words = sequence.split(" ", false)
    var entities = []
    var position = start_position
    
    for word in words:
        if word.strip_edges().is_empty():
            continue
            
        var entity = manifest_word(word, position)
        if entity:
            entities.append(entity)
            
            # Move position forward
            if player_node:
                var right = player_node.global_transform.basis.x
                position += right * spacing
            else:
                position += Vector3(spacing, 0, 0)
    
    return entities

func manifest_words(words: Array, relationship_type: String = "sequence", options: Dictionary = {}) -> Array:
    """
    Manifest multiple words at once with relationships
    """
    var entities = []
    var previous_entity = null
    var previous_word = ""
    
    # Determine position if not provided
    var position = options.get("position", null)
    if position == null and player_node:
        var forward = -player_node.global_transform.basis.z
        position = player_node.global_position + forward * 2.0
    
    for word in words:
        var result = manifest_word(word, position, options)
        
        if result:
            entities.append(result)
            
            # Create relationship with previous entity if available
            if previous_entity:
                if result.has_method("connect_to"):
                    result.connect_to(previous_entity, relationship_type)
                
                _create_word_relationship(previous_word, word, relationship_type)
            
            previous_entity = result
            previous_word = word
            
            # Adjust position for next entity if position is provided
            if position is Vector3:
                position += Vector3(1.5, 0, 0)  # Move right
    
    return entities

func combine_words(words: Array, position = null) -> Object:
    """
    Combine multiple words to create a more complex entity
    """
    if words.size() < 2:
        return null
    
    # Combine the properties of all words
    var combined_properties = {}
    var combined_word = ""
    
    for word in words:
        word = word.strip_edges().to_lower()
        if word.is_empty():
            continue
            
        combined_word += word + "_"
        
        var word_props = analyze_word(word)
        for key in word_props:
            if key in combined_properties:
                # For numeric properties, take the average
                if word_props[key] is float or word_props[key] is int:
                    combined_properties[key] = (combined_properties[key] + word_props[key]) / 2.0
                # For string properties, combine them
                elif word_props[key] is String:
                    combined_properties[key] = combined_properties[key] + "_" + word_props[key]
                # For dictionaries, merge them
                elif word_props[key] is Dictionary:
                    for subkey in word_props[key]:
                        if subkey in combined_properties[key]:
                            combined_properties[key][subkey] = (combined_properties[key][subkey] + word_props[key][subkey]) / 2.0
                        else:
                            combined_properties[key][subkey] = word_props[key][subkey]
            else:
                combined_properties[key] = word_props[key]
    
    # Remove trailing underscore
    combined_word = combined_word.rstrip("_")
    
    # Add combination bonus
    combined_properties["complexity"] = combined_properties.get("complexity", 0.5) * 1.5
    combined_properties["manifestation_bonus"] = 0.2 * words.size()
    
    # Create the entity with combined properties
    var entity = manifest_word(combined_word, position, combined_properties)
    
    # Record this combination
    _add_word_combination(words, combined_word)
    
    emit_signal("word_combination_created", words, combined_word)
    return entity

# ----- WORD ANALYSIS -----
func analyze_word(word: String) -> Dictionary:
    """
    Convert a word into entity properties
    """
    word = word.strip_edges().to_lower()
    
    # Check if we already know this word
    if word_properties.has(word):
        return word_properties[word].duplicate()
    
    # Use existing dictionary definition if available
    if dictionary_manager and dictionary_manager.has_method("get_word_definition"):
        var definition = dictionary_manager.get_word_definition(word)
        if definition != "No definition available.":
            # Extract properties from definition
            var dict_props = {}
            if dictionary_manager.has_method("get_element_properties"):
                var element_props = dictionary_manager.get_element_properties(word)
                if not element_props.is_empty():
                    dict_props = element_props
            
            if not dict_props.is_empty():
                return dict_props
    
    # Get analysis from each analyzer component
    var phonetic_result = phonetic_analyzer.analyze(word)
    var semantic_result = semantic_analyzer.analyze(word)
    var pattern_result = pattern_analyzer.analyze(word)
    
    # Combine results into a consolidated analysis
    var analysis = {
        "word": word,
        "phonetic": phonetic_result,
        "semantic": semantic_result,
        "pattern": pattern_result,
        "element_affinity": _determine_element_affinity(word, phonetic_result),
        "power_level": _calculate_power_level(word, phonetic_result, semantic_result, pattern_result),
        "concept_triggers": _extract_concept_triggers(word, semantic_result),
        "timestamp": Time.get_datetime_string_from_system()
    }
    
    # Emit signal with the analysis results
    emit_signal("word_analyzed", word, analysis)
    
    # Generate entity properties from the analysis
    var props = _generate_entity_properties(analysis)
    
    # Store the properties for future reference
    _learn_word_properties(word, props)
    
    return props

func _calculate_power_level(word: String, phonetic_result: Dictionary, semantic_result: Dictionary, pattern_result: Dictionary) -> float:
    var length_factor = min(1.0, float(word.length()) / 10.0)
    
    var phonetic_power = phonetic_result.get("power", 0.5) * phonetic_weight
    var semantic_power = semantic_result.get("power", 0.5) * semantic_weight
    var pattern_power = pattern_result.get("power", 0.5) * pattern_weight
    
    var base_power = phonetic_power + semantic_power + pattern_power
    
    # Adjust based on unique characters ratio
    var unique_chars = {}
    for c in word:
        unique_chars[c] = true
    var uniqueness_ratio = float(unique_chars.size()) / max(1, word.length())
    
    return base_power * (1.0 + length_factor) * (0.8 + uniqueness_ratio * 0.4)

func _determine_element_affinity(word: String, phonetic_result: Dictionary) -> String:
    # If we have the dictionary manager, try to use it first
    if dictionary_manager:
        # Check if this word is in the "element" category
        if dictionary_manager.has_method("get_word_categories"):
            var categories = dictionary_manager.get_word_categories(word)
            if "element" in categories:
                return word  # The word itself is an element
    
    # Try to use the enhanced phonetic analyzer if available
    if phonetic_analyzer is JSHPhoneticAnalyzer:
        # The enhanced analyzer provides more detailed element affinity
        var analysis = phonetic_analyzer.analyze(word)
        if analysis.has("element_affinity") and analysis.element_affinity.has("primary"):
            return analysis.element_affinity.primary
    
    # Fallback to basic mapping
    var vowels = phonetic_result.get("vowels", [])
    var element = "neutral"
    
    # Simple mapping based on dominant vowels
    if vowels.size() > 0:
        var vowel_counts = {}
        for v in vowels:
            if not vowel_counts.has(v):
                vowel_counts[v] = 0
            vowel_counts[v] += 1
        
        # Find dominant vowel
        var max_count = 0
        var dominant_vowel = ""
        for v in vowel_counts:
            if vowel_counts[v] > max_count:
                max_count = vowel_counts[v]
                dominant_vowel = v
        
        # Map vowels to elements
        match dominant_vowel:
            "a": element = "fire"
            "e": element = "air"
            "i": element = "lightning"
            "o": element = "earth"
            "u": element = "water"
            _: element = "neutral"
    
    # Adjust based on consonant patterns
    var consonants = phonetic_result.get("consonants", [])
    
    # Hard consonants push toward more solid elements
    var hard_consonants = ["k", "t", "p", "g", "d", "b"]
    var hard_count = 0
    
    # Flowing consonants push toward more fluid elements
    var flowing_consonants = ["f", "v", "s", "z", "h", "l", "r", "w"]
    var flowing_count = 0
    
    for c in consonants:
        if c in hard_consonants:
            hard_count += 1
        elif c in flowing_consonants:
            flowing_count += 1
    
    # Adjust element if there's a strong consonant bias
    if hard_count > flowing_count * 2 and hard_count > 2:
        if element == "air":
            element = "earth"
        elif element == "water":
            element = "ice"
    elif flowing_count > hard_count * 2 and flowing_count > 2:
        if element == "earth":
            element = "sand"
        elif element == "fire":
            element = "plasma"
    
    return element

func _extract_concept_triggers(word: String, semantic_result: Dictionary) -> Array:
    var concepts = []
    
    # Get concepts from semantic analysis if available
    if semantic_result.has("concepts"):
        concepts = semantic_result.get("concepts", [])
    
    # Add common triggers based on substrings
    var common_triggers = {
        "life": ["life", "live", "alive", "grow"],
        "death": ["death", "dead", "decay", "end"],
        "creation": ["create", "make", "build", "form"],
        "destruction": ["destroy", "break", "shatter", "ruin"],
        "movement": ["move", "flow", "walk", "run"],
        "stillness": ["still", "quiet", "calm", "peace"],
        "knowledge": ["know", "learn", "wise", "mind"],
        "mystery": ["mystery", "secret", "hidden", "obscure"]
    }
    
    # Check for matches
    for concept in common_triggers:
        for trigger in common_triggers[concept]:
            if word.find(trigger) >= 0:
                if not concept in concepts:
                    concepts.append(concept)
                break
    
    return concepts

func _determine_entity_type(properties: Dictionary) -> String:
    # Check if element_affinity is provided
    if properties.has("element_affinity"):
        return properties.element_affinity
    
    # Default to primordial
    return "primordial"

func _generate_entity_properties(analysis: Dictionary) -> Dictionary:
    var properties = {}
    
    # Base properties
    properties["energy"] = analysis.get("power_level", 0.5) * 100
    properties["complexity"] = 10 + analysis.get("word", "").length()
    
    # Source word
    properties["source_word"] = analysis.get("word", "")
    
    # Element affinity
    properties["element_affinity"] = analysis.get("element_affinity", "neutral")
    
    # Element-specific properties
    var element_affinity = analysis.get("element_affinity", "neutral")
    
    match element_affinity:
        "fire":
            properties["temperature"] = 80 + randi() % 20
            properties["intensity"] = 70 + randi() % 30
            properties["spread_rate"] = 0.5 + randf() * 0.5
        "water":
            properties["fluidity"] = 80 + randi() % 20  
            properties["volume"] = 50 + randi() % 50
            properties["clarity"] = 0.3 + randf() * 0.7
        "earth":
            properties["solidity"] = 80 + randi() % 20
            properties["mass"] = 70 + randi() % 30
            properties["fertility"] = 0.2 + randf() * 0.8
        "air":
            properties["movement"] = 70 + randi() % 30
            properties["visibility"] = 0.1 + randf() * 0.3
            properties["pressure"] = 0.4 + randf() * 0.6
        "lightning":
            properties["voltage"] = 80 + randi() % 20
            properties["speed"] = 90 + randi() % 10
            properties["unpredictability"] = 0.7 + randf() * 0.3
        "ice":
            properties["temperature"] = -10 - randi() % 20
            properties["hardness"] = 70 + randi() % 30
            properties["clarity"] = 0.5 + randf() * 0.5
        "plasma":
            properties["temperature"] = 200 + randi() % 100
            properties["energy_density"] = 80 + randi() % 20
            properties["volatility"] = 0.6 + randf() * 0.4
        "sand":
            properties["grain_size"] = 0.1 + randf() * 0.3
            properties["flow_rate"] = 0.5 + randf() * 0.5
            properties["abrasiveness"] = 0.4 + randf() * 0.6
        "abstract":
            properties["conceptual_strength"] = 60 + randi() % 40
            properties["manifestation_clarity"] = 0.3 + randf() * 0.7
            properties["reality_influence"] = 0.4 + randf() * 0.6
        "primal":
            properties["raw_power"] = 80 + randi() % 20
            properties["stability"] = 0.2 + randf() * 0.4
            properties["reality_disruption"] = 0.6 + randf() * 0.4
    
    # Add concept-based properties
    var concepts = analysis.get("concept_triggers", [])
    for concept in concepts:
        properties["concept_" + concept] = 0.7 + randf() * 0.3
    
    # Add the original word as phonetic pattern
    var phonetic = analysis.get("phonetic", {})
    if phonetic.has("pattern"):
        properties["phonetic_pattern"] = phonetic.get("pattern", "")
    
    return properties

# ----- WORD HISTORY MANAGEMENT -----
func _add_to_word_history(word: String) -> void:
    """
    Add a word to both history trackers, maintaining max size
    """
    word_history.push_front(word)
    recent_manifestations.push_front(word)
    
    # Trim history if too large
    if word_history.size() > MAX_WORD_HISTORY:
        word_history.pop_back()
    
    if recent_manifestations.size() > MAX_WORD_HISTORY:
        recent_manifestations.pop_back()

func get_recent_manifestations(count: int = 10) -> Array:
    var history_size = recent_manifestations.size()
    var start_index = max(0, history_size - count)
    return recent_manifestations.slice(start_index, history_size - 1)

# ----- WORD RELATIONSHIP MANAGEMENT -----
func _create_word_relationship(word1: String, word2: String, relationship_type: String) -> void:
    # Initialize if needed
    if not word_relationships.has(word1):
        word_relationships[word1] = {}
    
    # Create relationship
    word_relationships[word1][word2] = relationship_type
    
    emit_signal("word_relationship_created", word1, word2, relationship_type)

func get_related_words(word: String) -> Dictionary:
    if word_relationships.has(word):
        return word_relationships[word].duplicate()
    return {}

func _add_word_combination(words: Array, result: String) -> void:
    """
    Record a successful word combination
    """
    if not concept_relationships.has("combinations"):
        concept_relationships["combinations"] = {}
    
    var combo_key = " + ".join(words)
    concept_relationships["combinations"][combo_key] = result
    
    save_concept_map()

# ----- LEARNING SYSTEM -----
func _learn_word_properties(word: String, properties: Dictionary) -> void:
    """
    Store the properties of a word for future use
    """
    word_properties[word] = properties.duplicate()
    save_word_database()

# ----- SAVING AND LOADING -----
func save_word_database() -> void:
    """
    Save the word properties database to file
    """
    var file = FileAccess.open(WORD_DB_FILE, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(word_properties))
    else:
        print("Error saving word database: ", FileAccess.get_open_error())

func load_word_database() -> void:
    """
    Load the word properties database from file
    """
    if FileAccess.file_exists(WORD_DB_FILE):
        var file = FileAccess.open(WORD_DB_FILE, FileAccess.READ)
        if file:
            var text = file.get_as_text()
            var parsed = JSON.parse_string(text)
            
            if parsed != null:
                word_properties = parsed
            else:
                print("Error parsing word database JSON")
        else:
            print("Error opening word database file")
    else:
        print("Word database not found, creating new one")
        # Initialize with some basic words
        _initialize_starter_words()

func save_concept_map() -> void:
    """
    Save the concept relationship map to file
    """
    var file = FileAccess.open(CONCEPT_MAP_FILE, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(concept_relationships))
    else:
        print("Error saving concept map: ", FileAccess.get_open_error())

func load_concept_map() -> void:
    """
    Load the concept relationship map from file
    """
    if FileAccess.file_exists(CONCEPT_MAP_FILE):
        var file = FileAccess.open(CONCEPT_MAP_FILE, FileAccess.READ)
        if file:
            var text = file.get_as_text()
            var parsed = JSON.parse_string(text)
            
            if parsed != null:
                concept_relationships = parsed
            else:
                print("Error parsing concept map JSON")
        else:
            print("Error opening concept map file")
    else:
        print("Concept map not found, creating new one")
        concept_relationships = {
            "opposites": {
                "fire": "water",
                "earth": "air",
                "light": "dark",
                "life": "death",
                "creation": "destruction",
                "movement": "stillness"
            },
            "combinations": {}
        }

func _initialize_starter_words() -> void:
    """
    Initialize the database with some basic words
    """
    # Define starter elemental words
    var starters = ["fire", "water", "earth", "air", "light", "dark", "wood", "metal"]
    
    for word in starters:
        var props = analyze_word(word)
        _learn_word_properties(word, props)
    
    # Add some pre-defined combinations
    var combinations = {
        "fire+water": "steam",
        "earth+water": "mud",
        "fire+earth": "lava",
        "air+water": "mist",
        "light+water": "rainbow",
        "fire+air": "smoke"
    }
    
    for combo in combinations:
        var result = combinations[combo]
        var words = combo.split("+")
        var props = {}
        
        for word in words:
            var word_props = analyze_word(word)
            for key in word_props:
                if not props.has(key):
                    props[key] = word_props[key]
                elif props[key] is float:
                    props[key] = (props[key] + word_props[key]) / 2.0
        
        props["complexity"] = props.get("complexity", 0.5) * 1.5
        _learn_word_properties(result, props)
    
    # Save the initialized database
    save_word_database()

# ----- UTILITY FUNCTIONS -----
func get_opposite_concept(concept: String) -> String:
    """
    Get the opposite of a concept if known
    """
    if concept_relationships.has("opposites") and concept_relationships["opposites"].has(concept):
        return concept_relationships["opposites"][concept]
    
    return ""

# ----- CONSOLE COMMAND PROCESSING -----
func process_command(command: String) -> Dictionary:
    """
    Process a text command for creating, combining, or evolving entities
    """
    command = command.strip_edges()
    
    # Split into command parts
    var parts = command.split(" ", false, 1)
    var action = parts[0].to_lower()
    var params = parts[1] if parts.size() > 1 else ""
    
    var result = {
        "success": false,
        "message": "",
        "entity": null
    }
    
    match action:
        "create", "manifest":
            var entity = manifest_word(params)
            if entity:
                result.success = true
                result.message = "Created entity from word: " + params
                result.entity = entity
            else:
                result.message = "Failed to create entity from: " + params
        
        "combine":
            var words = params.split(" ", false)
            if words.size() >= 2:
                var entity = combine_words(words)
                if entity:
                    result.success = true
                    result.message = "Combined words into: " + entity.source_word
                    result.entity = entity
                else:
                    result.message = "Failed to combine words"
            else:
                result.message = "Need at least 2 words to combine"
        
        "evolve":
            # Find entities by word
            var entity = _find_entity_by_word(params)
            if entity:
                if entity.has_method("evolve"):
                    entity.evolve()
                    result.success = true
                    result.message = "Evolved entity: " + params
                    result.entity = entity
                else:
                    result.message = "Entity cannot be evolved: " + params
            else:
                result.message = "No entity found with word: " + params
        
        "transform":
            var word_parts = params.split(" to ", false)
            if word_parts.size() == 2:
                var source_word = word_parts[0].strip_edges()
                var target_form = word_parts[1].strip_edges()
                
                var entity = _find_entity_by_word(source_word)
                if entity:
                    if entity.has_method("transform_to"):
                        entity.transform_to(target_form)
                        result.success = true
                        result.message = "Transformed " + source_word + " to " + target_form
                        result.entity = entity
                    else:
                        result.message = "Entity cannot be transformed: " + source_word
                else:
                    result.message = "No entity found with word: " + source_word
            else:
                result.message = "Invalid transform command. Use 'transform X to Y'"
        
        "connect":
            var word_parts = params.split(" to ", false)
            if word_parts.size() == 2:
                var source_word = word_parts[0].strip_edges()
                var target_word = word_parts[1].strip_edges()
                
                var source_entity = _find_entity_by_word(source_word)
                var target_entity = _find_entity_by_word(target_word)
                
                if source_entity and target_entity:
                    if source_entity.has_method("connect_to"):
                        source_entity.connect_to(target_entity)
                        result.success = true
                        result.message = "Connected " + source_word + " to " + target_word
                        result.entity = source_entity
                    else:
                        result.message = "Entity cannot establish connections: " + source_word
                else:
                    result.message = "Could not find one or both entities"
            else:
                result.message = "Invalid connect command. Use 'connect X to Y'"
        
        "help":
            result.success = true
            result.message = "Available commands:\n" + \
                            "create/manifest [word] - Create an entity\n" + \
                            "combine [word1] [word2] ... - Combine words\n" + \
                            "evolve [word] - Evolve an entity\n" + \
                            "transform [word] to [form] - Transform entity\n" + \
                            "connect [word1] to [word2] - Connect entities"
        
        _:
            # Default to creating an entity from the entire command
            var entity = manifest_word(command)
            if entity:
                result.success = true
                result.message = "Created entity from: " + command
                result.entity = entity
            else:
                result.message = "Unknown command or failed to create entity"
    
    return result

func _find_entity_by_word(word: String) -> Object:
    """
    Find an entity with the given source word
    """
    # Check if map system is available
    if map_system and map_system.has_method("get_entities"):
        var all_entities = map_system.get_entities()
        for entity in all_entities:
            if entity.source_word == word:
                return entity
    
    # Alternative search through entity manager
    if entity_manager and entity_manager.has_method("find_entity_by_word"):
        return entity_manager.find_entity_by_word(word)
    
    # Look through cells in map system
    if map_system and map_system.has_property("cells"):
        for cell_coords in map_system.cells:
            var cell = map_system.cells[cell_coords]
            if cell.has_method("get_entities"):
                for entity in cell.get_entities():
                    if entity.has_property("source_word") and entity.source_word == word:
                        return entity
    
    return null

# ----- INNER CLASSES FOR FALLBACK ANALYZERS -----

# Simple implementation of phonetic analyzer used if the JSHPhoneticAnalyzer is not available
class PhoneticAnalyzer:
    func analyze(word: String) -> Dictionary:
        var result = {
            "vowels": [],
            "consonants": [],
            "pattern": "",
            "power": 0.5,
            "resonance": 0.5
        }
        
        # Extract vowels and consonants
        var vowels = "aeiou"
        for i in range(word.length()):
            var c = word[i].to_lower()
            if vowels.find(c) >= 0:
                result.vowels.append(c)
                result.pattern += "V"
            else:
                result.consonants.append(c)
                result.pattern += "C"
        
        # Calculate power based on pattern
        var pattern = result.pattern
        
        # Consecutive consonants increase power
        var max_consonant_streak = 0
        var current_streak = 0
        
        for c in pattern:
            if c == "C":
                current_streak += 1
                max_consonant_streak = max(max_consonant_streak, current_streak)
            else:
                current_streak = 0
        
        # Vowel-consonant alternation increases resonance
        var alternations = 0
        for i in range(1, pattern.length()):
            if pattern[i] != pattern[i-1]:
                alternations += 1
        
        var alternation_ratio = float(alternations) / max(1, pattern.length() - 1)
        
        # Calculate final values
        result.power = 0.3 + (0.1 * max_consonant_streak) + (0.1 * result.consonants.size() / max(1, word.length()))
        result.resonance = 0.3 + (0.4 * alternation_ratio)
        
        return result

# Simple implementation of semantic analyzer used if the JSHSemanticAnalyzer is not available
class SemanticAnalyzer:
    # Known concept root words - in a real implementation this would be more advanced
    var concept_roots = {
        "life": ["life", "live", "alive", "animate", "birth", "grow"],
        "death": ["death", "dead", "decay", "expire", "end"],
        "power": ["power", "strong", "might", "force", "vigor"],
        "wisdom": ["wisdom", "know", "sage", "mind", "intellect"],
        "creation": ["create", "make", "form", "build", "craft"],
        "destruction": ["destroy", "break", "ruin", "smash", "wreck"],
        "protection": ["protect", "shield", "guard", "defend", "ward"],
        "transformation": ["transform", "change", "shift", "morph"]
    }
    
    func analyze(word: String) -> Dictionary:
        var result = {
            "concepts": [],
            "power": 0.5,
            "positivity": 0.5,
            "complexity": 0.5
        }
        
        # Check for concept roots
        for concept in concept_roots:
            for root in concept_roots[concept]:
                if word.find(root) >= 0:
                    result.concepts.append(concept)
                    break
        
        # Calculate power based on word length and concepts
        result.power = 0.3 + min(0.6, 0.05 * word.length()) + (0.1 * result.concepts.size())
        
        # Calculate positivity (in a real implementation, this would use a lexicon)
        # Here we just use a simple heuristic
        var positive_indicators = ["good", "great", "nice", "kind", "joy", "happy", "create"]
        var negative_indicators = ["bad", "evil", "hate", "dark", "fear", "sad", "destroy"]
        
        var positive_score = 0
        var negative_score = 0
        
        for indicator in positive_indicators:
            if word.find(indicator) >= 0:
                positive_score += 1
        
        for indicator in negative_indicators:
            if word.find(indicator) >= 0:
                negative_score += 1
        
        if positive_score > 0 or negative_score > 0:
            result.positivity = float(positive_score) / max(1, positive_score + negative_score)
        
        # Calculate complexity
        result.complexity = 0.3 + min(0.5, 0.04 * word.length()) + (0.1 * result.concepts.size())
        
        return result

# Simple implementation of pattern analyzer used if the JSHPatternAnalyzer is not available
class PatternAnalyzer:
    func analyze(word: String) -> Dictionary:
        var result = {
            "repetitions": 0,
            "symmetry": 0.0,
            "power": 0.5
        }
        
        # Check for repetitions
        var char_counts = {}
        for c in word:
            if not char_counts.has(c):
                char_counts[c] = 0
            char_counts[c] += 1
        
        for c in char_counts:
            if char_counts[c] > 1:
                result.repetitions += char_counts[c] - 1
        
        # Check for symmetry
        if word.length() > 2:
            var is_palindrome = true
            for i in range(word.length() / 2):
                if word[i] != word[word.length() - 1 - i]:
                    is_palindrome = false
                    break
            
            if is_palindrome:
                result.symmetry = 1.0
            else:
                # Partial symmetry
                var matches = 0
                for i in range(word.length() / 2):
                    if word[i] == word[word.length() - 1 - i]:
                        matches += 1
                
                result.symmetry = float(matches) / (word.length() / 2)
        
        # Calculate power
        var repetition_factor = min(0.5, 0.1 * result.repetitions)
        result.power = 0.3 + repetition_factor + (0.4 * result.symmetry)
        
        return result