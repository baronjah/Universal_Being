extends Node
class_name InteractionMatrix

# Interaction matrix defines how different entity types interact with each other
var interaction_rules: Dictionary = {
    # Basic elements
    "fire": {
        "fire": "intensify",
        "water": "diminish",
        "wood": "consume",
        "ash": "consume",
        "air": "intensify",
        "earth": "transform",
        "metal": "transform",
        "primordial": "transform"
    },
    "water": {
        "fire": "diminish",
        "water": "fuse",
        "wood": "intensify",
        "ash": "transform",
        "air": "create",
        "earth": "create",
        "metal": "transform",
        "primordial": "transform"
    },
    "wood": {
        "fire": "consumed",
        "water": "intensify",
        "wood": "fuse",
        "ash": "transform",
        "air": "intensify",
        "earth": "intensify",
        "metal": "diminish",
        "primordial": "transform"
    },
    "ash": {
        "fire": "diminish",
        "water": "transform",
        "wood": "transform",
        "ash": "fuse",
        "air": "split",
        "earth": "fuse",
        "metal": "transform",
        "primordial": "transform"
    },
    "air": {
        "fire": "intensify",
        "water": "create",
        "wood": "intensify",
        "ash": "split",
        "air": "fuse",
        "earth": "transform",
        "metal": "transform",
        "primordial": "transform"
    },
    "earth": {
        "fire": "transform",
        "water": "create",
        "wood": "intensify",
        "ash": "fuse",
        "air": "transform",
        "earth": "fuse",
        "metal": "create",
        "primordial": "transform"
    },
    "metal": {
        "fire": "transform",
        "water": "transform",
        "wood": "diminish",
        "ash": "transform",
        "air": "transform",
        "earth": "create",
        "metal": "fuse",
        "primordial": "transform"
    },
    
    # Special types
    "primordial": {
        "fire": "transform",
        "water": "transform",
        "wood": "transform",
        "ash": "transform",
        "air": "transform",
        "earth": "transform",
        "metal": "transform",
        "primordial": "split"
    },
    "consumed": {
        "fire": "none",
        "water": "transform",
        "wood": "none",
        "ash": "none",
        "air": "split",
        "earth": "transform",
        "metal": "none",
        "primordial": "transform"
    },
    "fused": {
        "fire": "split",
        "water": "split",
        "wood": "split",
        "ash": "split",
        "air": "split",
        "earth": "split",
        "metal": "split",
        "primordial": "transform",
        "fused": "intensify"
    },
    "transformed": {
        "fire": "transform",
        "water": "transform",
        "wood": "transform",
        "ash": "transform",
        "air": "transform",
        "earth": "transform",
        "metal": "transform",
        "primordial": "transform",
        "transformed": "fuse"
    }
}

# Extended entity types will be dynamically added based on interactions
var dynamic_types: Dictionary = {}

func _ready() -> void:
    # Initialize any additional setup needed
    print("InteractionMatrix: Ready")

# Get the interaction effect between two entity types
func get_interaction_effect(type1: String, type2: String) -> String:
    # Check if this is a known interaction
    if interaction_rules.has(type1) and interaction_rules[type1].has(type2):
        return interaction_rules[type1][type2]
    
    # Check for dynamic types
    if dynamic_types.has(type1) and dynamic_types[type1].has(type2):
        return dynamic_types[type1][type2]
    
    # Default base type fallbacks - extract base types from derived types
    var base_type1 = extract_base_type(type1)
    var base_type2 = extract_base_type(type2)
    
    # Try with base types
    if base_type1 != type1 or base_type2 != type2:
        if interaction_rules.has(base_type1) and interaction_rules[base_type1].has(base_type2):
            return interaction_rules[base_type1][base_type2]
    
    # If no rule is found, return default "none" effect
    return "none"

# Extract the base type from a derived type (e.g., "transmuted_fire" -> "fire")
func extract_base_type(type: String) -> String:
    var prefixes = ["transmuted_", "transformed_", "fused_", "split_"]
    
    for prefix in prefixes:
        if type.begins_with(prefix):
            return type.substr(prefix.length())
    
    # Check for compound types (e.g., "fire_water")
    if type.find("_") >= 0:
        var parts = type.split("_")
        if parts.size() >= 2:
            if interaction_rules.has(parts[0]):
                return parts[0]
            elif interaction_rules.has(parts[1]):
                return parts[1]
    
    return type

# Add a new interaction rule
func add_interaction_rule(type1: String, type2: String, effect: String) -> void:
    # Check if we need to create the type entry
    if not interaction_rules.has(type1):
        interaction_rules[type1] = {}
    
    # Add the rule
    interaction_rules[type1][type2] = effect
    print("InteractionMatrix: Added rule ", type1, " + ", type2, " -> ", effect)

# Add a dynamic type with its interaction rules
func add_dynamic_type(type: String, rules: Dictionary) -> void:
    if not dynamic_types.has(type):
        dynamic_types[type] = {}
    
    # Merge the rules
    for other_type in rules:
        dynamic_types[type][other_type] = rules[other_type]
    
    print("InteractionMatrix: Added dynamic type ", type, " with ", rules.size(), " rules")

# Get all known types
func get_all_types() -> Array:
    var types = []
    
    # Add base types
    for type in interaction_rules.keys():
        if not type in types:
            types.append(type)
    
    # Add dynamic types
    for type in dynamic_types.keys():
        if not type in types:
            types.append(type)
    
    return types

# Get all possible effects
func get_all_effects() -> Array:
    var effects = []
    
    # Scan all rules for effects
    for type1 in interaction_rules:
        for type2 in interaction_rules[type1]:
            var effect = interaction_rules[type1][type2]
            if not effect in effects:
                effects.append(effect)
    
    # Add from dynamic types
    for type1 in dynamic_types:
        for type2 in dynamic_types[type1]:
            var effect = dynamic_types[type1][type2]
            if not effect in effects:
                effects.append(effect)
    
    return effects