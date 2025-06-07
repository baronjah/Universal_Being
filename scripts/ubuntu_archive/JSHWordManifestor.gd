extends Node
class_name JSHWordManifestor

# Singleton pattern
static var _instance: JSHWordManifestor = null

# Static function to get the singleton instance
static func get_instance() -> JSHWordManifestor:
    if not _instance:
        _instance = JSHWordManifestor.new()
    return _instance

# Word analysis components
var phonetic_analyzer = null
var semantic_analyzer = null
var pattern_analyzer = null

# Word history and relationships
var recent_manifestations: Array = []
var word_relationships: Dictionary = {}

# Configuration
var default_manifestation_influence: float = 1.0
var phonetic_weight: float = 0.3
var semantic_weight: float = 0.5
var pattern_weight: float = 0.2
var max_history_size: int = 100

# References to other systems
var entity_manager = null
var dictionary_manager = null

# Signals
signal word_manifested(word, entity)
signal word_analyzed(word, analysis)
signal word_relationship_created(word1, word2, relationship_type)

func _init() -> void:
    # Try to get specialized analyzers
    _initialize_analyzers()

    # Setup configuration
    _setup_default_configuration()

func _initialize_analyzers() -> void:
    # Try to get specialized analyzers first
    if ClassDB.class_exists("JSHPhoneticAnalyzer"):
        phonetic_analyzer = JSHPhoneticAnalyzer.get_instance()
        print("JSHWordManifestor: Using JSHPhoneticAnalyzer")
    else:
        phonetic_analyzer = PhoneticAnalyzer.new()

    if ClassDB.class_exists("JSHSemanticAnalyzer"):
        semantic_analyzer = JSHSemanticAnalyzer.get_instance()
        print("JSHWordManifestor: Using JSHSemanticAnalyzer")
    else:
        semantic_analyzer = SemanticAnalyzer.new()

    if ClassDB.class_exists("JSHPatternAnalyzer"):
        pattern_analyzer = JSHPatternAnalyzer.get_instance()
        print("JSHWordManifestor: Using JSHPatternAnalyzer")
    else:
        pattern_analyzer = PatternAnalyzer.new()

func _ready() -> void:
    # Try to get entity manager if available
    if ClassDB.class_exists("JSHEntityManager"):
        entity_manager = JSHEntityManager.get_instance()
    else:
        print("JSHWordManifestor: JSHEntityManager not found, using ThingCreatorA")
        entity_manager = ThingCreatorA.get_instance()

    # Try to get dictionary manager
    if ClassDB.class_exists("JSHDictionaryManager"):
        dictionary_manager = JSHDictionaryManager.get_instance()
        print("JSHWordManifestor: Connected to JSHDictionaryManager")
    else:
        print("JSHWordManifestor: JSHDictionaryManager not found, dictionary features unavailable")

# Core manifestation function
func manifest_word(word: String, options: Dictionary = {}) -> Dictionary:
    # Track history
    _add_to_history(word)
    
    # Analyze word
    var analysis = analyze_word(word)
    
    # Apply modifiers
    _apply_context_modifiers(analysis, options)
    
    # Create entity properties
    var entity_properties = _generate_entity_properties(analysis)
    
    # Get entity type from analysis
    var entity_type = _determine_entity_type(analysis)
    
    # Add source word to properties
    entity_properties["source_word"] = word
    
    # Create the entity
    var entity = null
    if entity_manager:
        # Check if we're using JSHEntityManager (preferred)
        if entity_manager.has_method("create_entity"):
            entity = entity_manager.create_entity(entity_type, entity_properties)
        # Otherwise fallback to ThingCreatorA
        else:
            entity = entity_manager.create_entity(entity_type, entity_properties)
    else:
        print("JSHWordManifestor: No entity manager available, cannot create entity")
    
    # Process relationships with recent words
    if entity:
        _process_word_relationships(word, analysis, entity)
        emit_signal("word_manifested", word, entity)
    
    # Return result
    return {
        "word": word,
        "entity": entity,
        "analysis": analysis,
        "properties": entity_properties,
        "type": entity_type
    }

# Analyze a word and return its characteristics
func analyze_word(word: String) -> Dictionary:
    # Ensure lowercase for consistent analysis
    var normalized_word = word.to_lower()
    
    # Get analysis from each analyzer
    var phonetic_result = phonetic_analyzer.analyze(normalized_word)
    var semantic_result = semantic_analyzer.analyze(normalized_word)
    var pattern_result = pattern_analyzer.analyze(normalized_word)
    
    # Combine results
    var combined_analysis = {
        "word": normalized_word,
        "phonetic": phonetic_result,
        "semantic": semantic_result,
        "pattern": pattern_result,
        "power_level": _calculate_power_level(normalized_word, phonetic_result, semantic_result, pattern_result),
        "element_affinity": _determine_element_affinity(normalized_word, phonetic_result),
        "concept_triggers": _extract_concept_triggers(normalized_word, semantic_result),
        "timestamp": Time.get_datetime_string_from_system()
    }
    
    emit_signal("word_analyzed", word, combined_analysis)
    return combined_analysis

# Manifest multiple words at once with relationships
func manifest_words(words: Array, relationship_type: String = "sequence", options: Dictionary = {}) -> Array:
    var entities = []
    var previous_entity = null
    var previous_word = ""
    
    for word in words:
        var result = manifest_word(word, options)
        
        if result.entity:
            entities.append(result.entity)
            
            # Create relationship with previous entity if available
            if previous_entity:
                _create_entity_relationship(previous_entity, result.entity, relationship_type)
                _create_word_relationship(previous_word, word, relationship_type)
            
            previous_entity = result.entity
            previous_word = word
    
    return entities

# Word history management
func _add_to_history(word: String) -> void:
    # Add to recent manifestations
    recent_manifestations.append(word)
    
    # Trim history if too large
    if recent_manifestations.size() > max_history_size:
        recent_manifestations.pop_front()

func get_recent_manifestations(count: int = 10) -> Array:
    var history_size = recent_manifestations.size()
    var start_index = max(0, history_size - count)
    return recent_manifestations.slice(start_index, history_size - 1)

# Word relationship management
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

# Entity relationship management
func _create_entity_relationship(entity1, entity2, relationship_type: String) -> void:
    if entity1 and entity2:
        # Add reference in both directions
        if entity1.has_method("add_reference"):
            entity1.add_reference(relationship_type, entity2.get_id())
        
        if entity2.has_method("add_reference"):
            entity2.add_reference("reverse_" + relationship_type, entity1.get_id())

# Helper functions for word analysis

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

func _determine_entity_type(analysis: Dictionary) -> String:
    # First try to use element affinity
    var entity_type = analysis.get("element_affinity", "primordial")
    
    # If too many concept triggers, use "abstract" type
    var concepts = analysis.get("concept_triggers", [])
    if concepts.size() >= 3:
        entity_type = "abstract"
    
    # If power level is very high, use "primal" type
    var power_level = analysis.get("power_level", 0.5)
    if power_level > 0.8:
        entity_type = "primal"
    
    return entity_type

func _generate_entity_properties(analysis: Dictionary) -> Dictionary:
    var properties = {}
    
    # Base properties
    properties["energy"] = analysis.get("power_level", 0.5) * 100
    properties["complexity"] = 10 + analysis.get("word", "").length()
    
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

func _apply_context_modifiers(analysis: Dictionary, options: Dictionary) -> void:
    # Apply influence modifier
    var influence = options.get("influence", default_manifestation_influence)
    if influence != 1.0:
        analysis["power_level"] *= influence
    
    # Apply reality context modifier
    var reality_context = options.get("reality_context", "physical")
    match reality_context:
        "digital":
            # Digital reality boosts abstract and lightning elements
            if analysis["element_affinity"] == "lightning":
                analysis["power_level"] *= 1.3
            elif analysis["element_affinity"] == "abstract":
                analysis["power_level"] *= 1.2
        "astral":
            # Astral reality boosts abstract and primal elements
            if analysis.get("concept_triggers", []).size() >= 2:
                analysis["power_level"] *= 1.25
            if analysis["element_affinity"] == "abstract":
                analysis["power_level"] *= 1.4
        "ethereal":
            # Ethereal reality boosts all elements but especially abstract
            analysis["power_level"] *= 1.1
            if analysis["element_affinity"] == "abstract":
                analysis["power_level"] *= 1.3
    
    # Apply source modifier
    var source = options.get("source", "spoken")
    match source:
        "written":
            # Written words have more stability
            analysis["stability_factor"] = options.get("stability_factor", 1.0) * 1.3
        "thought":
            # Thought words have less stability but more flexibility
            analysis["stability_factor"] = options.get("stability_factor", 1.0) * 0.7
            analysis["flexibility_factor"] = options.get("flexibility_factor", 1.0) * 1.4
        "encoded":
            # Encoded words (like in a database) are more stable but less powerful
            analysis["stability_factor"] = options.get("stability_factor", 1.0) * 1.5
            analysis["power_level"] *= 0.8
    
    # Apply emotion modifier
    var emotion = options.get("emotion", "neutral")
    match emotion:
        "joy":
            analysis["power_level"] *= 1.2
            if analysis["element_affinity"] == "fire":
                analysis["power_level"] *= 1.1
        "anger":
            analysis["power_level"] *= 1.3
            if analysis["element_affinity"] == "fire":
                analysis["power_level"] *= 1.2
            else:
                analysis["stability_factor"] = options.get("stability_factor", 1.0) * 0.7
        "fear":
            analysis["power_level"] *= 0.9
            analysis["stability_factor"] = options.get("stability_factor", 1.0) * 0.6
        "sadness":
            analysis["power_level"] *= 0.8
            if analysis["element_affinity"] == "water":
                analysis["power_level"] *= 1.3
    
    # Apply intent modifier
    var intent = options.get("intent", "passive")
    match intent:
        "creative":
            analysis["power_level"] *= 1.2
            analysis["concept_triggers"].append("creation")
        "destructive":
            analysis["power_level"] *= 1.3
            analysis["concept_triggers"].append("destruction")
            analysis["stability_factor"] = options.get("stability_factor", 1.0) * 0.7
        "protective":
            analysis["power_level"] *= 1.1
            analysis["stability_factor"] = options.get("stability_factor", 1.0) * 1.3
            analysis["concept_triggers"].append("protection")
        "transformative":
            analysis["power_level"] *= 1.15
            analysis["concept_triggers"].append("transformation")

func _process_word_relationships(word: String, analysis: Dictionary, entity) -> void:
    # Process relationships with recent words
    var recent_words = get_recent_manifestations(5)
    
    # Skip current word
    recent_words.erase(word)
    
    for other_word in recent_words:
        # Determine relationship type based on some logic
        var relationship_type = "temporal_sequence"
        
        # Create word relationship
        _create_word_relationship(word, other_word, relationship_type)
        
        # Find entity for the other word
        # This would normally use a query to the entity system
        # For simplicity, we'll just create a placeholder reference
        # In real implementation, you'd want to properly find and reference actual entities
        entity.add_reference("word_relation", other_word)

func _setup_default_configuration() -> void:
    # Default settings for word manifestation
    default_manifestation_influence = 1.0
    phonetic_weight = 0.3
    semantic_weight = 0.5
    pattern_weight = 0.2
    max_history_size = 100

# Analyzer classes

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