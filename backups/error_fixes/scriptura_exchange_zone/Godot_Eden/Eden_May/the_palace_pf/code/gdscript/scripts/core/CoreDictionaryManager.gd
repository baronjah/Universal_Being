extends Node
class_name JSHDictionaryManager

# Singleton pattern
static var _instance = null

# Dictionary storage
var word_definitions = {}
var word_categories = {}
var word_relationships = {}
var element_properties = {}

# Dynamic learning
var learned_words = {}
var definition_counts = {}

# Configuration
var auto_learn_new_words = true
var min_confidence_threshold = 0.6

# Signals
signal word_defined(word, definition)
signal word_learned(word, properties)
signal relationship_established(word1, word2, relationship_type)

# Static accessor for singleton
static func get_instance():
    if not _instance:
        _instance = JSHDictionaryManager.new()
    return _instance

func _init() -> void:
    # Initialize dictionaries
    _initialize_basic_dictionary()
    _initialize_element_properties()

func _ready() -> void:
    # Connect to word manifestor if available
    if ClassDB.class_exists("JSHWordManifestor"):
        var word_manifestor = JSHWordManifestor.get_instance()
        word_manifestor.connect("word_analyzed", self, "_on_word_analyzed")
        word_manifestor.connect("word_manifested", self, "_on_word_manifested")
        word_manifestor.connect("word_relationship_created", self, "_on_word_relationship_created")

# Initialize with some basic words and definitions
func _initialize_basic_dictionary() -> void:
    # Element definitions
    add_word_definition("fire", "A primordial element associated with heat, light, energy, passion, and transformation.")
    add_word_definition("water", "A primordial element associated with fluidity, adaptability, emotions, healing, and purification.")
    add_word_definition("earth", "A primordial element associated with stability, solidity, growth, abundance, and foundation.")
    add_word_definition("air", "A primordial element associated with movement, intelligence, communication, freedom, and breath.")
    add_word_definition("lightning", "A powerful element associated with speed, sudden change, revelation, and destructive force.")
    add_word_definition("ice", "A specialized element derived from water, associated with preservation, stasis, clarity, and isolation.")
    add_word_definition("metal", "A refined element derived from earth, associated with strength, resilience, conductivity, and precision.")
    add_word_definition("wood", "A living element derived from earth, associated with growth, flexibility, life energy, and renewal.")
    
    # Categories
    add_word_to_category("fire", "element")
    add_word_to_category("water", "element")
    add_word_to_category("earth", "element")
    add_word_to_category("air", "element")
    add_word_to_category("lightning", "element")
    add_word_to_category("ice", "element")
    add_word_to_category("metal", "element")
    add_word_to_category("wood", "element")
    
    # Concept definitions
    add_word_definition("creation", "The act or process of bringing something into existence, forming something from nothing.")
    add_word_definition("destruction", "The act of destroying or state of being destroyed, breaking down into components.")
    add_word_definition("transformation", "A thorough or dramatic change in form, appearance, or character.")
    add_word_definition("protection", "The act of protecting or state of being protected, keeping safe from harm.")
    
    add_word_to_category("creation", "concept")
    add_word_to_category("destruction", "concept")
    add_word_to_category("transformation", "concept")
    add_word_to_category("protection", "concept")
    
    # Element relationships
    add_word_relationship("fire", "water", "opposes")
    add_word_relationship("fire", "earth", "strengthens")
    add_word_relationship("water", "fire", "weakens")
    add_word_relationship("water", "earth", "nourishes")
    add_word_relationship("earth", "air", "opposes")
    add_word_relationship("earth", "fire", "contains")
    add_word_relationship("air", "earth", "erodes")
    add_word_relationship("air", "fire", "feeds")
    add_word_relationship("lightning", "earth", "seeks")
    add_word_relationship("ice", "fire", "opposes")

# Initialize element properties
func _initialize_element_properties() -> void:
    element_properties = {
        "fire": {
            "primary_properties": ["heat", "light", "energy"],
            "secondary_properties": ["passion", "transformation", "purification"],
            "opposing_elements": ["water", "ice"],
            "complementary_elements": ["air", "lightning"],
            "visual_traits": ["red", "orange", "yellow", "flicker", "glow"]
        },
        "water": {
            "primary_properties": ["fluidity", "adaptability", "cleansing"],
            "secondary_properties": ["emotion", "intuition", "healing"],
            "opposing_elements": ["fire", "lightning"],
            "complementary_elements": ["earth", "ice"],
            "visual_traits": ["blue", "clear", "reflective", "flowing", "rippling"]
        },
        "earth": {
            "primary_properties": ["stability", "solidity", "fertility"],
            "secondary_properties": ["patience", "endurance", "abundance"],
            "opposing_elements": ["air", "lightning"],
            "complementary_elements": ["water", "wood"],
            "visual_traits": ["brown", "green", "textured", "dense", "layered"]
        },
        "air": {
            "primary_properties": ["movement", "lightness", "invisibility"],
            "secondary_properties": ["intellect", "communication", "freedom"],
            "opposing_elements": ["earth"],
            "complementary_elements": ["fire", "lightning"],
            "visual_traits": ["transparent", "swirling", "white", "wispy", "clear"]
        },
        "lightning": {
            "primary_properties": ["electricity", "speed", "power"],
            "secondary_properties": ["revelation", "inspiration", "destruction"],
            "opposing_elements": ["earth", "wood"],
            "complementary_elements": ["air", "fire"],
            "visual_traits": ["blue-white", "jagged", "flashing", "branching", "bright"]
        },
        "ice": {
            "primary_properties": ["cold", "solidity", "preservation"],
            "secondary_properties": ["clarity", "stasis", "reflection"],
            "opposing_elements": ["fire"],
            "complementary_elements": ["water"],
            "visual_traits": ["white", "blue", "transparent", "crystalline", "faceted"]
        }
    }

# Public API methods

func add_word_definition(word: String, definition: String) -> void:
    word_definitions[word.to_lower()] = definition
    emit_signal("word_defined", word, definition)

func get_word_definition(word: String) -> String:
    var lower_word = word.to_lower()
    if word_definitions.has(lower_word):
        return word_definitions[lower_word]
    elif learned_words.has(lower_word):
        return learned_words[lower_word].get("generated_definition", "No definition available.")
    return "No definition available."

func add_word_to_category(word: String, category: String) -> void:
    var lower_word = word.to_lower()
    if not word_categories.has(lower_word):
        word_categories[lower_word] = []
    
    if not category in word_categories[lower_word]:
        word_categories[lower_word].append(category)

func get_word_categories(word: String) -> Array:
    var lower_word = word.to_lower()
    if word_categories.has(lower_word):
        return word_categories[lower_word]
    return []

func add_word_relationship(word1: String, word2: String, relationship_type: String) -> void:
    var lower_word1 = word1.to_lower()
    var lower_word2 = word2.to_lower()
    
    # Create relationship entries if needed
    if not word_relationships.has(lower_word1):
        word_relationships[lower_word1] = {}
    
    # Add relationship
    word_relationships[lower_word1][lower_word2] = relationship_type
    
    emit_signal("relationship_established", lower_word1, lower_word2, relationship_type)

func get_related_words(word: String, relationship_type: String = "") -> Dictionary:
    var lower_word = word.to_lower()
    var result = {}
    
    if word_relationships.has(lower_word):
        if relationship_type.empty():
            # Return all relationships
            return word_relationships[lower_word]
        else:
            # Filter by relationship type
            for related_word in word_relationships[lower_word]:
                if word_relationships[lower_word][related_word] == relationship_type:
                    result[related_word] = relationship_type
    
    return result

func get_element_properties(element: String) -> Dictionary:
    var lower_element = element.to_lower()
    if element_properties.has(lower_element):
        return element_properties[lower_element]
    return {}

func get_all_words_in_category(category: String) -> Array:
    var result = []
    
    for word in word_categories:
        if category in word_categories[word]:
            result.append(word)
    
    return result

# Dynamic learning methods

func learn_word(word: String, properties: Dictionary) -> void:
    var lower_word = word.to_lower()
    
    # Check if we already have a definition
    if word_definitions.has(lower_word):
        # Update confidence if we're seeing this word again
        if learned_words.has(lower_word):
            learned_words[lower_word].confidence += 0.1
            learned_words[lower_word].confidence = min(learned_words[lower_word].confidence, 1.0)
        return
    
    # Create or update learned word
    if not learned_words.has(lower_word):
        learned_words[lower_word] = {
            "properties": properties.duplicate(),
            "confidence": 0.5,
            "generated_definition": _generate_definition(word, properties)
        }
    else:
        # Update existing learned word
        for key in properties:
            if not learned_words[lower_word].properties.has(key):
                learned_words[lower_word].properties[key] = properties[key]
        
        # Increase confidence
        learned_words[lower_word].confidence += 0.1
        learned_words[lower_word].confidence = min(learned_words[lower_word].confidence, 1.0)
        
        # Regenerate definition with new properties
        learned_words[lower_word].generated_definition = _generate_definition(word, learned_words[lower_word].properties)
    
    emit_signal("word_learned", word, learned_words[lower_word])

func _generate_definition(word: String, properties: Dictionary) -> String:
    var definition = "A"
    
    # Start with element type if available
    if properties.has("element_affinity"):
        var element = properties.element_affinity
        if element in ["a", "e", "i", "o", "u"]:
            definition = "An"
        
        definition += " " + element + "-aligned"
    
    # Add basic categorization
    if properties.has("entity_type"):
        var entity_type = properties.entity_type
        
        if entity_type == "abstract":
            definition += " abstract concept"
        elif entity_type == "primal":
            definition += " primal force"
        else:
            definition += " entity"
    else:
        definition += " word"
    
    # Add property descriptions
    var property_descriptions = []
    
    # Energy level
    if properties.has("energy"):
        var energy = properties.energy as float
        if energy > 80:
            property_descriptions.append("high energy")
        elif energy > 50:
            property_descriptions.append("moderate energy")
        else:
            property_descriptions.append("low energy")
    
    # Specific element properties
    if properties.has("entity_type"):
        var type = properties.entity_type
        
        match type:
            "fire":
                if properties.has("intensity"):
                    var intensity = properties.intensity as float
                    if intensity > 80:
                        property_descriptions.append("intense heat")
                    else:
                        property_descriptions.append("moderate warmth")
            "water":
                if properties.has("fluidity"):
                    var fluidity = properties.fluidity as float
                    if fluidity > 80:
                        property_descriptions.append("exceptional fluidity")
                    else:
                        property_descriptions.append("flowing nature")
            "earth":
                if properties.has("mass"):
                    var mass = properties.mass as float
                    if mass > 80:
                        property_descriptions.append("substantial mass")
                    else:
                        property_descriptions.append("grounding presence")
    
    # Concept properties
    if properties.has("concept_triggers") and properties.concept_triggers is Array:
        for concept in properties.concept_triggers:
            property_descriptions.append("association with " + concept)
    
    # Compile property descriptions
    if property_descriptions.size() > 0:
        definition += " with " + property_descriptions.join(", ")
    
    # Add origin
    definition += ". Manifested from the word '" + word + "'."
    
    return definition

# Signal handlers

func _on_word_analyzed(word: String, analysis: Dictionary) -> void:
    if auto_learn_new_words:
        # Extract properties from analysis
        var properties = {
            "element_affinity": analysis.element_affinity,
            "power_level": analysis.power_level,
            "concept_triggers": analysis.concept_triggers
        }
        
        # Track word occurrence
        if not definition_counts.has(word):
            definition_counts[word] = 0
        definition_counts[word] += 1
        
        # Learn if we've seen it enough times
        if definition_counts[word] >= 2:
            learn_word(word, properties)

func _on_word_manifested(word: String, entity) -> void:
    if auto_learn_new_words:
        # Extract properties from entity
        var properties = {}
        
        if entity.has_method("get_type"):
            properties["entity_type"] = entity.get_type()
        
        if entity.has_method("get_properties"):
            var entity_properties = entity.get_properties()
            for prop in entity_properties:
                properties[prop] = entity_properties[prop]
        
        # Learn word
        learn_word(word, properties)

func _on_word_relationship_created(word1: String, word2: String, relationship_type: String) -> void:
    # Add to our relationship dictionary
    add_word_relationship(word1, word2, relationship_type)