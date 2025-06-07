extends Node
class_name JSHWordCommands

# Console command module for word manifestation
# This integrates with the JSHConsoleManager system

# Reference to necessary components
var console_manager = null
var word_manifestor = null

func _init() -> void:
    print("JSHWordCommands: Initializing...")
    
    # Try to get console manager
    if ClassDB.class_exists("JSHConsoleManager"):
        console_manager = JSHConsoleManager.get_instance()
    
    # Try to get word manifestor
    if ClassDB.class_exists("JSHWordManifestor"):
        word_manifestor = JSHWordManifestor.get_instance()
    
    # Register commands if both systems are available
    if console_manager and word_manifestor:
        _register_commands()
        print("JSHWordCommands: Commands registered")
    else:
        print("JSHWordCommands: Missing required components, commands not registered")

func _register_commands() -> void:
    # Register word manifestation commands
    
    # Main word command with subcommands
    console_manager.register_command(
        "word",
        "_cmd_word",
        self,
        "Word manifestation commands",
        "word <subcommand> [args...]"
    )
    
    # Manifest subcommand
    console_manager.register_command(
        "word manifest",
        "_cmd_word_manifest",
        self,
        "Manifest a word into an entity",
        "word manifest <word> [options]"
    )
    
    # Analyze subcommand
    console_manager.register_command(
        "word analyze",
        "_cmd_word_analyze",
        self,
        "Analyze a word without creating an entity",
        "word analyze <word>"
    )
    
    # Sequence subcommand
    console_manager.register_command(
        "word sequence",
        "_cmd_word_sequence",
        self,
        "Manifest a sequence of related words",
        "word sequence <word1> <word2> [word3] [...]"
    )
    
    # History subcommand
    console_manager.register_command(
        "word history",
        "_cmd_word_history",
        self,
        "Show recent word manifestations",
        "word history [count]"
    )
    
    # Find subcommand
    console_manager.register_command(
        "word find",
        "_cmd_word_find",
        self,
        "Find entities manifested from a specific word",
        "word find <word>"
    )

# Command handlers

func _cmd_word(args: Array) -> String:
    if args.size() == 0:
        return "Available word subcommands: manifest, analyze, sequence, history, find"
    
    return "Unknown word subcommand: " + args[0] + ". Try: manifest, analyze, sequence, history, find"

func _cmd_word_manifest(args: Array) -> String:
    if args.size() == 0:
        return "Error: No word specified. Usage: word manifest <word> [options]"
    
    var word = args[0]
    var options = {}
    
    # Parse options if provided
    if args.size() > 1:
        for i in range(1, args.size()):
            var option_arg = args[i]
            
            if option_arg.begins_with("reality="):
                options["reality_context"] = option_arg.split("=")[1]
            elif option_arg.begins_with("emotion="):
                options["emotion"] = option_arg.split("=")[1]
            elif option_arg.begins_with("intent="):
                options["intent"] = option_arg.split("=")[1]
            elif option_arg.begins_with("influence="):
                var influence_str = option_arg.split("=")[1]
                options["influence"] = float(influence_str)
    
    # Manifest the word
    var result = word_manifestor.manifest_word(word, options)
    
    # Format response
    if result.entity:
        var entity = result.entity
        var response = "Manifested word '%s' as %s entity (ID: %s)\n" % [word, entity.get_type(), entity.get_id()]
        response += "Properties:\n"
        
        # Add key properties
        var key_props = ["energy", "complexity"]
        for prop in key_props:
            var value = entity.get_property(prop, null)
            if value != null:
                response += "  %s: %s\n" % [prop, str(value)]
        
        # Add type-specific property
        var type_prop = _get_type_specific_property(entity.get_type())
        if type_prop != "":
            var value = entity.get_property(type_prop, null)
            if value != null:
                response += "  %s: %s\n" % [type_prop, str(value)]
        
        # Add analysis info
        response += "\nWord Analysis:\n"
        response += "  Element Affinity: %s\n" % [result.analysis.element_affinity]
        response += "  Power Level: %s\n" % [str(result.analysis.power_level)]
        
        if result.analysis.has("concept_triggers") and result.analysis.concept_triggers.size() > 0:
            response += "  Concepts: %s\n" % [", ".join(result.analysis.concept_triggers)]
        
        return response
    else:
        return "Failed to manifest word '%s'" % [word]

func _cmd_word_analyze(args: Array) -> String:
    if args.size() == 0:
        return "Error: No word specified. Usage: word analyze <word>"
    
    var word = args[0]
    
    # Analyze the word
    var analysis = word_manifestor.analyze_word(word)
    
    # Format response
    var response = "Analysis of word '%s':\n" % [word]
    
    # General properties
    response += "General:\n"
    response += "  Element Affinity: %s\n" % [analysis.element_affinity]
    response += "  Power Level: %s\n" % [str(analysis.power_level)]
    
    # Phonetic analysis
    response += "\nPhonetic Analysis:\n"
    var phonetic = analysis.phonetic
    response += "  Pattern: %s\n" % [phonetic.pattern]
    response += "  Vowels: %s\n" % [", ".join(phonetic.vowels)]
    response += "  Consonants: %s\n" % [", ".join(phonetic.consonants)]
    response += "  Power: %s\n" % [str(phonetic.power)]
    response += "  Resonance: %s\n" % [str(phonetic.resonance)]
    
    # Semantic analysis
    response += "\nSemantic Analysis:\n"
    var semantic = analysis.semantic
    if semantic.concepts.size() > 0:
        response += "  Concepts: %s\n" % [", ".join(semantic.concepts)]
    else:
        response += "  Concepts: None detected\n"
    response += "  Power: %s\n" % [str(semantic.power)]
    response += "  Positivity: %s\n" % [str(semantic.positivity)]
    response += "  Complexity: %s\n" % [str(semantic.complexity)]
    
    # Pattern analysis
    response += "\nPattern Analysis:\n"
    var pattern = analysis.pattern
    response += "  Repetitions: %s\n" % [str(pattern.repetitions)]
    response += "  Symmetry: %s\n" % [str(pattern.symmetry)]
    response += "  Power: %s\n" % [str(pattern.power)]
    
    # Concept triggers
    if analysis.concept_triggers.size() > 0:
        response += "\nConcept Triggers: %s\n" % [", ".join(analysis.concept_triggers)]
    else:
        response += "\nConcept Triggers: None detected\n"
    
    return response

func _cmd_word_sequence(args: Array) -> String:
    if args.size() < 2:
        return "Error: At least two words required. Usage: word sequence <word1> <word2> [word3] [...]"
    
    # Get words from arguments
    var words = args
    
    # Manifest word sequence
    var entities = word_manifestor.manifest_words(words)
    
    # Format response
    var response = "Manifested word sequence:\n"
    
    for i in range(entities.size()):
        var entity = entities[i]
        response += "%d. %s (%s) - ID: %s\n" % [i+1, words[i], entity.get_type(), entity.get_id()]
    
    response += "\nCreated %d entities with evolutionary relationships" % [entities.size()]
    
    return response

func _cmd_word_history(args: Array) -> String:
    var count = 10
    
    # Parse count if provided
    if args.size() > 0:
        count = int(args[0])
    
    # Get recent manifestations
    var recent = word_manifestor.get_recent_manifestations(count)
    
    # Format response
    var response = "Recent Word Manifestations:\n"
    
    if recent.size() == 0:
        response += "No words have been manifested yet."
    else:
        for i in range(recent.size()):
            response += "%d. %s\n" % [i+1, recent[i]]
    
    return response

func _cmd_word_find(args: Array) -> String:
    if args.size() == 0:
        return "Error: No word specified. Usage: word find <word>"
    
    var word = args[0]
    
    # We need the entity manager to search
    var entity_manager = null
    if ClassDB.class_exists("JSHEntityManager"):
        entity_manager = JSHEntityManager.get_instance()
    
    if not entity_manager:
        return "Error: Entity manager not available, cannot search for entities."
    
    # Find entities with the source_word property
    var found_entities = []
    
    # This implementation depends on the entity manager's API
    # Using a generic approach here
    if entity_manager.has_method("find_entities"):
        var criteria = {
            "property_key": "source_word",
            "property_value": word
        }
        found_entities = entity_manager.find_entities(criteria)
    elif entity_manager.has_method("get_all_entities"):
        # Fallback: manual search
        var all_entities = entity_manager.get_all_entities()
        for entity in all_entities:
            if entity.get_property("source_word", "") == word:
                found_entities.append(entity)
    
    # Format response
    var response = "Entities manifested from word '%s':\n" % [word]
    
    if found_entities.size() == 0:
        response += "No entities found."
    else:
        for i in range(found_entities.size()):
            var entity = found_entities[i]
            response += "%d. %s (ID: %s)\n" % [i+1, entity.get_type(), entity.get_id()]
        
        response += "\nFound %d entities." % [found_entities.size()]
    
    return response

# Helper functions

func _get_type_specific_property(type: String) -> String:
    match type:
        "fire": return "intensity"
        "water": return "fluidity"
        "earth": return "mass"
        "air": return "movement"
        "lightning": return "voltage"
        "ice": return "hardness"
        "plasma": return "energy_density"
        "sand": return "grain_size"
        "abstract": return "conceptual_strength"
        "primal": return "raw_power"
        _: return ""