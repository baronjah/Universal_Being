extends Node
class_name JSHSemanticAnalyzer

# Static instance for singleton pattern
static var _instance = null

# Concept dictionaries
var concept_roots = {
    "life": ["life", "live", "alive", "vital", "animate", "birth", "grow", "living", "exist"],
    "death": ["death", "dead", "decay", "expire", "end", "finite", "mortal", "lethal", "fatal"],
    "power": ["power", "strong", "might", "force", "vigor", "energy", "potent", "strength", "powerful"],
    "wisdom": ["wisdom", "know", "sage", "mind", "intellect", "smart", "wise", "knowledge", "learn"],
    "creation": ["create", "make", "form", "build", "craft", "construct", "design", "forge", "establish"],
    "destruction": ["destroy", "break", "ruin", "smash", "wreck", "crush", "demolish", "shatter", "collapse"],
    "protection": ["protect", "shield", "guard", "defend", "ward", "secure", "safety", "shelter", "preserve"],
    "transformation": ["transform", "change", "shift", "morph", "alter", "modify", "transmute", "convert", "evolve"],
    "movement": ["move", "flow", "walk", "run", "travel", "journey", "motion", "dynamic", "mobile"],
    "stillness": ["still", "quiet", "calm", "peace", "serene", "tranquil", "static", "immobile", "rest"],
    "light": ["light", "bright", "shine", "glow", "illuminate", "radiant", "gleam", "luminous", "beam"],
    "darkness": ["dark", "shadow", "night", "black", "dim", "obscure", "shroud", "gloom", "shade"],
    "time": ["time", "moment", "instant", "epoch", "era", "age", "period", "duration", "temporal"],
    "space": ["space", "void", "vacuum", "dimension", "area", "region", "volume", "expanse", "cosmos"],
    "mind": ["mind", "thought", "idea", "concept", "mental", "brain", "psyche", "intellect", "consciousness"],
    "body": ["body", "flesh", "physical", "corporal", "material", "tangible", "somatic", "anatomical", "corporeal"],
    "spirit": ["spirit", "soul", "essence", "ethereal", "ghost", "wraith", "phantom", "spectre", "apparition"],
    "element": ["element", "fundamental", "basic", "essential", "primal", "core", "primary", "quintessential", "elemental"],
    "emotion": ["emotion", "feel", "heart", "passion", "sense", "perceive", "sentiment", "affect", "mood"]
}

# Antonym pairs (concepts with opposite meanings)
var antonym_pairs = [
    ["life", "death"],
    ["creation", "destruction"],
    ["light", "darkness"],
    ["movement", "stillness"],
    ["body", "spirit"],
    ["wisdom", "folly"]  # Folly not included in concept_roots, just for reference
]

# Emotional valence (positive/negative association)
var emotional_valence = {
    "positive": ["joy", "happy", "good", "great", "love", "peace", "hope", "kind", "gentle", "beauty", 
                 "truth", "light", "heal", "pure", "noble", "grace", "honor", "loyal", "brave", "just"],
    "negative": ["sad", "bad", "evil", "hate", "fear", "anger", "pain", "cruel", "harsh", "ugly", 
                 "lie", "dark", "harm", "taint", "vile", "shame", "betray", "coward", "foul", "unjust"]
}

# Intensity modifiers (words that amplify or diminish meaning)
var intensity_modifiers = {
    "amplifiers": ["very", "extremely", "incredibly", "immensely", "utterly", "absolutely", "completely", "totally"],
    "diminishers": ["slightly", "somewhat", "rather", "fairly", "a bit", "a little", "hardly", "barely"]
}

# Static accessor for singleton
static func get_instance():
    if not _instance:
        _instance = JSHSemanticAnalyzer.new()
    return _instance

# Core analysis function
func analyze(word: String) -> Dictionary:
    # Convert to lowercase for consistent analysis
    var text = word.to_lower()
    
    # Initialize result structure
    var result = {
        "concepts": [],           # Identified concept roots
        "power": 0.5,             # Semantic power (0.0-1.0)
        "positivity": 0.5,        # Positive/negative valence (0.0-1.0)
        "complexity": 0.5,        # Conceptual complexity (0.0-1.0)
        "opposing_concepts": [],  # Concepts that oppose identified concepts
        "primary_concept": "",    # Most strongly matched concept
        "intensity": 0.5,         # Intensity of meaning (0.0-1.0)
        "abstraction": 0.5        # Level of abstractness (0.0-1.0)
    }
    
    # Find matching concepts
    var concept_matches = _find_concept_matches(text)
    result.concepts = concept_matches.concepts
    
    # Set primary concept if any were found
    if result.concepts.size() > 0:
        result.primary_concept = result.concepts[0]
    
    # Find opposing concepts
    result.opposing_concepts = _find_opposing_concepts(result.concepts)
    
    # Calculate semantic power
    result.power = _calculate_semantic_power(text, concept_matches)
    
    # Calculate positivity
    result.positivity = _calculate_positivity(text)
    
    # Calculate complexity
    result.complexity = _calculate_complexity(text, result.concepts)
    
    # Calculate intensity
    result.intensity = _calculate_intensity(text, concept_matches)
    
    # Calculate abstraction level
    result.abstraction = _calculate_abstraction(text, result.concepts)
    
    return result

# Function to find concepts that match the word
func _find_concept_matches(word: String) -> Dictionary:
    var matches = []
    var match_strengths = {}
    var substring_matches = {}
    
    # Check for exact matches in concept roots
    for concept in concept_roots:
        for root in concept_roots[concept]:
            if root == word:
                # Exact match is strongest
                matches.append(concept)
                match_strengths[concept] = 1.0
                break
            elif word.find(root) >= 0:
                # Substring match
                if not concept in matches:
                    matches.append(concept)
                
                # Calculate match strength based on substring length ratio
                var match_strength = float(root.length()) / word.length()
                
                # Update if this is a stronger match
                if not match_strengths.has(concept) or match_strength > match_strengths[concept]:
                    match_strengths[concept] = match_strength
                
                # Save the matching root
                if not substring_matches.has(concept):
                    substring_matches[concept] = []
                substring_matches[concept].append(root)
    
    # Sort matches by strength
    var sorted_matches = []
    for concept in matches:
        sorted_matches.append({
            "concept": concept,
            "strength": match_strengths[concept]
        })
    
    sorted_matches.sort_custom(self, "_sort_by_strength")
    
    # Extract just the concepts in sorted order
    var result_concepts = []
    for match_data in sorted_matches:
        result_concepts.append(match_data.concept)
    
    return {
        "concepts": result_concepts,
        "strengths": match_strengths,
        "substring_matches": substring_matches
    }

# Function to find concepts that oppose the identified concepts
func _find_opposing_concepts(concepts: Array) -> Array:
    var opposing = []
    
    for concept in concepts:
        for pair in antonym_pairs:
            if concept == pair[0] and not pair[1] in opposing:
                opposing.append(pair[1])
            elif concept == pair[1] and not pair[0] in opposing:
                opposing.append(pair[0])
    
    return opposing

# Function to calculate semantic power
func _calculate_semantic_power(word: String, concept_matches: Dictionary) -> float:
    var base_power = 0.3  # Start with a base power
    
    # Concepts increase power
    var concept_count = concept_matches.concepts.size()
    base_power += min(0.4, concept_count * 0.1)
    
    # Strong concept matches increase power more
    var total_strength = 0.0
    for concept in concept_matches.strengths:
        total_strength += concept_matches.strengths[concept]
    
    if concept_count > 0:
        base_power += (total_strength / concept_count) * 0.2
    
    # Word length can indicate complexity/power
    var length_factor = min(0.2, word.length() * 0.01)
    base_power += length_factor
    
    # Check for intensity modifiers
    for amplifier in intensity_modifiers.amplifiers:
        if word.find(amplifier) >= 0:
            base_power += 0.1
            break
    
    for diminisher in intensity_modifiers.diminishers:
        if word.find(diminisher) >= 0:
            base_power -= 0.1
            break
    
    return clamp(base_power, 0.1, 1.0)

# Function to calculate positivity (negative to positive scale)
func _calculate_positivity(word: String) -> float:
    var positivity_score = 0.5  # Start neutral
    
    # Check positive indicators
    for positive_word in emotional_valence.positive:
        if word.find(positive_word) >= 0:
            positivity_score += 0.1
    
    # Check negative indicators
    for negative_word in emotional_valence.negative:
        if word.find(negative_word) >= 0:
            positivity_score -= 0.1
    
    # Clamp the result
    return clamp(positivity_score, 0.0, 1.0)

# Function to calculate conceptual complexity
func _calculate_complexity(word: String, concepts: Array) -> float:
    var base_complexity = 0.3  # Start with moderate complexity
    
    # More concepts = more complex
    base_complexity += min(0.4, concepts.size() * 0.1)
    
    # Word length can indicate complexity
    var length_factor = min(0.3, word.length() * 0.02)
    base_complexity += length_factor
    
    # Having opposing concepts increases complexity
    if concepts.size() > 1:
        for i in range(concepts.size()):
            for j in range(i+1, concepts.size()):
                # Check if this pair is in antonym_pairs
                var is_opposing = false
                for pair in antonym_pairs:
                    if (concepts[i] == pair[0] and concepts[j] == pair[1]) or (concepts[i] == pair[1] and concepts[j] == pair[0]):
                        is_opposing = true
                        break
                
                if is_opposing:
                    base_complexity += 0.2
    
    # Complexity markers in English
    var complexity_markers = ["meta", "trans", "inter", "multi", "poly", "hyper", "ultra"]
    for marker in complexity_markers:
        if word.begins_with(marker) or (" " + marker) in word:
            base_complexity += 0.1
            break
    
    return clamp(base_complexity, 0.1, 1.0)

# Function to calculate semantic intensity
func _calculate_intensity(word: String, concept_matches: Dictionary) -> float:
    var base_intensity = 0.5  # Start with moderate intensity
    
    # Strong concept matches increase intensity
    var total_strength = 0.0
    for concept in concept_matches.strengths:
        total_strength += concept_matches.strengths[concept]
    
    if concept_matches.concepts.size() > 0:
        base_intensity += (total_strength / concept_matches.concepts.size()) * 0.3
    
    # Check for intensity modifiers
    for amplifier in intensity_modifiers.amplifiers:
        if word.find(amplifier) >= 0:
            base_intensity += 0.2
            break
    
    for diminisher in intensity_modifiers.diminishers:
        if word.find(diminisher) >= 0:
            base_intensity -= 0.2
            break
    
    # Certain concepts are inherently more intense
    var high_intensity_concepts = ["power", "death", "destruction", "transformation"]
    for concept in concept_matches.concepts:
        if concept in high_intensity_concepts:
            base_intensity += 0.1
            break
    
    return clamp(base_intensity, 0.0, 1.0)

# Function to calculate abstraction level
func _calculate_abstraction(word: String, concepts: Array) -> float:
    var base_abstraction = 0.3  # Start with moderate abstraction
    
    # Certain concepts are more abstract
    var abstract_concepts = ["wisdom", "time", "space", "mind", "spirit", "emotion"]
    var concrete_concepts = ["body", "movement", "element", "life", "death"]
    
    for concept in concepts:
        if concept in abstract_concepts:
            base_abstraction += 0.15
        elif concept in concrete_concepts:
            base_abstraction -= 0.1
    
    # Abstract suffix indicators
    var abstract_suffixes = ["ness", "ity", "tion", "ance", "ence"]
    for suffix in abstract_suffixes:
        if word.ends_with(suffix):
            base_abstraction += 0.2
            break
    
    # Concrete indicators
    var concrete_indicators = ["able", "ible", "ful", "ive", "al"]
    for indicator in concrete_indicators:
        if word.ends_with(indicator):
            base_abstraction -= 0.1
            break
    
    return clamp(base_abstraction, 0.0, 1.0)

# Helper function for sorting
func _sort_by_strength(a, b):
    return a.strength > b.strength