extends Node
class_name JSHPhoneticAnalyzer

# Static instance for singleton pattern
static var _instance = null

# Constants for phonetic analysis
const VOWELS = "aeiouäëïöüáéíóúàèìòùâêîôûãẽĩõũāēīōū"
const SOFT_CONSONANTS = "lrwyjhszvf"
const HARD_CONSONANTS = "tkpdgbqxcm"
const NEUTRAL_CONSONANTS = "n"

# Phonetic patterns dictionary
var phonetic_patterns = {
    "plosive": ["p", "b", "t", "d", "k", "g"],
    "fricative": ["f", "v", "s", "z", "h", "th", "sh"],
    "nasal": ["m", "n", "ng"],
    "liquid": ["l", "r"],
    "glide": ["w", "y"]
}

# Element affinities for phonetic patterns
var element_affinities = {
    "a": {"primary": "fire", "secondary": "earth"},
    "e": {"primary": "air", "secondary": "water"},
    "i": {"primary": "lightning", "secondary": "air"},
    "o": {"primary": "earth", "secondary": "fire"},
    "u": {"primary": "water", "secondary": "ice"},
    "plosive": {"primary": "earth", "secondary": "fire"},
    "fricative": {"primary": "air", "secondary": "lightning"},
    "nasal": {"primary": "water", "secondary": "earth"},
    "liquid": {"primary": "water", "secondary": "air"},
    "glide": {"primary": "air", "secondary": "fire"}
}

# Power characteristics for patterns
var pattern_power = {
    "CVC": 0.6,    # Consonant-Vowel-Consonant (strong structure)
    "CV": 0.4,     # Consonant-Vowel (medium structure)
    "VC": 0.5,     # Vowel-Consonant (medium structure)
    "VV": 0.3,     # Vowel-Vowel (flowing but weak)
    "CC": 0.7      # Consonant-Consonant (powerful but harsh)
}

# Static accessor for singleton
static func get_instance():
    if not _instance:
        _instance = JSHPhoneticAnalyzer.new()
    return _instance

# Core analysis function
func analyze(word: String) -> Dictionary:
    # Convert to lowercase for consistent analysis
    var text = word.to_lower()
    
    # Initialize result structure
    var result = {
        "vowels": [],              # List of vowels in the word
        "consonants": [],          # List of consonants in the word
        "pattern": "",             # CV pattern (C=consonant, V=vowel)
        "syllables": 0,            # Estimated syllable count
        "power": 0.5,              # Overall phonetic power (0.0-1.0)
        "resonance": 0.5,          # Phonetic resonance/harmony (0.0-1.0)
        "element_affinity": {},    # Primary and secondary element affinities
        "sound_qualities": {},     # Various sound qualities
        "dominant_patterns": []    # Dominant phonetic patterns
    }
    
    # Extract vowels and consonants
    for i in range(text.length()):
        var c = text[i]
        if VOWELS.find(c) >= 0:
            result.vowels.append(c)
            result.pattern += "V"
        elif c.is_valid_identifier():  # Ensure it's a valid character
            result.consonants.append(c)
            result.pattern += "C"
    
    # Extract pattern sequences
    var pattern_sequences = _extract_pattern_sequences(result.pattern)
    
    # Estimate syllable count (crude approximation based on vowel groups)
    result.syllables = _estimate_syllables(text, result.vowels)
    
    # Calculate power based on consonant types and pattern
    result.power = _calculate_power(text, result.consonants, pattern_sequences)
    
    # Calculate resonance based on pattern harmony
    result.resonance = _calculate_resonance(text, result.pattern)
    
    # Determine element affinities
    result.element_affinity = _determine_element_affinity(result.vowels, result.consonants)
    
    # Calculate sound qualities
    result.sound_qualities = _determine_sound_qualities(text, result.vowels, result.consonants, result.pattern)
    
    # Identify dominant patterns
    result.dominant_patterns = _identify_dominant_patterns(result.consonants)
    
    return result

# Function to extract pattern sequences (like CVC, CV, etc.) from a CV pattern
func _extract_pattern_sequences(pattern: String) -> Dictionary:
    var sequences = {}
    
    # Common pattern types to look for
    var pattern_types = ["CVC", "CV", "VC", "VV", "CC"]
    
    # Count occurrences of each pattern type
    for type in pattern_types:
        var count = 0
        var start_pos = 0
        
        while true:
            start_pos = pattern.find(type, start_pos)
            if start_pos == -1:
                break
            count += 1
            start_pos += 1
        
        if count > 0:
            sequences[type] = count
    
    return sequences

# Function to estimate syllables in a word
func _estimate_syllables(word: String, vowels: Array) -> int:
    # Basic syllable counting - count vowel groups
    var syllable_count = 0
    var in_vowel_group = false
    
    for c in word:
        var is_vowel = VOWELS.find(c) >= 0
        
        if is_vowel and not in_vowel_group:
            syllable_count += 1
            in_vowel_group = true
        elif not is_vowel:
            in_vowel_group = false
    
    # Handle special cases
    if syllable_count == 0 and word.length() > 0:
        syllable_count = 1  # Ensure at least one syllable for non-empty words
    
    # Special ending cases in English
    if word.ends_with("le") and word.length() > 2 and CONSONANTS.find(word[word.length() - 3]) >= 0:
        syllable_count += 1
    
    # Special combining cases in English
    if word.find("io") >= 0:
        syllable_count -= 1
    
    return max(1, syllable_count)  # Ensure at least one syllable

# Function to calculate phonetic power
func _calculate_power(word: String, consonants: Array, pattern_sequences: Dictionary) -> float:
    var base_power = 0.3  # Start with a base power
    
    # Power from consonant types
    var hard_count = 0
    var soft_count = 0
    
    for c in consonants:
        if HARD_CONSONANTS.find(c) >= 0:
            hard_count += 1
        elif SOFT_CONSONANTS.find(c) >= 0:
            soft_count += 1
    
    # Hard consonants increase power
    if consonants.size() > 0:
        var hard_ratio = float(hard_count) / consonants.size()
        base_power += hard_ratio * 0.3
    
    # Power from patterns
    var pattern_power = 0.0
    var total_patterns = 0
    
    for pattern in pattern_sequences:
        if pattern_power.has(pattern):
            pattern_power += pattern_power[pattern] * pattern_sequences[pattern]
            total_patterns += pattern_sequences[pattern]
    
    if total_patterns > 0:
        pattern_power = pattern_power / total_patterns
        base_power = (base_power + pattern_power) / 2
    
    # Word length factor (longer words have slightly more power)
    var length_factor = min(0.2, word.length() * 0.01)
    base_power += length_factor
    
    # Ensure power is within range
    return clamp(base_power, 0.1, 1.0)

# Function to calculate phonetic resonance (harmonious sound)
func _calculate_resonance(word: String, pattern: String) -> float:
    var base_resonance = 0.3
    
    # Pattern alternation increases resonance
    var alternations = 0
    for i in range(1, pattern.length()):
        if pattern[i] != pattern[i-1]:
            alternations += 1
    
    if pattern.length() > 1:
        var alternation_ratio = float(alternations) / (pattern.length() - 1)
        base_resonance += alternation_ratio * 0.4
    
    # Repeated sounds can increase resonance in moderation
    var char_counts = {}
    for c in word:
        if not char_counts.has(c):
            char_counts[c] = 0
        char_counts[c] += 1
    
    var repetition_score = 0.0
    for c in char_counts:
        if char_counts[c] > 1:
            repetition_score += min(0.1, (char_counts[c] - 1) * 0.05)
    
    base_resonance += repetition_score
    
    # Certain endings are more resonant
    if word.ends_with("a") or word.ends_with("o") or word.ends_with("n") or word.ends_with("m"):
        base_resonance += 0.1
    
    # Certain harsh combinations reduce resonance
    var harsh_combos = ["kt", "pt", "gd", "bd", "kp", "ts"]
    for combo in harsh_combos:
        if word.find(combo) >= 0:
            base_resonance -= 0.05
    
    return clamp(base_resonance, 0.1, 1.0)

# Function to determine element affinity based on phonetic profile
func _determine_element_affinity(vowels: Array, consonants: Array) -> Dictionary:
    var affinities = {
        "fire": 0,
        "water": 0,
        "earth": 0,
        "air": 0,
        "lightning": 0,
        "ice": 0
    }
    
    # Process vowels
    for vowel in vowels:
        var base_vowel = vowel.substr(0, 1)  # Handle accented vowels by taking first char
        
        if element_affinities.has(base_vowel):
            var primary = element_affinities[base_vowel].primary
            var secondary = element_affinities[base_vowel].secondary
            
            affinities[primary] += 2
            affinities[secondary] += 1
    
    # Process consonants by type
    var consonant_types = {}
    for pattern_type in phonetic_patterns:
        consonant_types[pattern_type] = 0
    
    for c in consonants:
        for pattern_type in phonetic_patterns:
            if c in phonetic_patterns[pattern_type]:
                consonant_types[pattern_type] += 1
    
    # Add affinities from consonant types
    for pattern_type in consonant_types:
        if consonant_types[pattern_type] > 0 and element_affinities.has(pattern_type):
            var primary = element_affinities[pattern_type].primary
            var secondary = element_affinities[pattern_type].secondary
            
            affinities[primary] += consonant_types[pattern_type] * 1.5
            affinities[secondary] += consonant_types[pattern_type] * 0.75
    
    # Find primary and secondary affinities
    var primary_element = "neutral"
    var secondary_element = "neutral"
    var primary_value = 0
    var secondary_value = 0
    
    for element in affinities:
        if affinities[element] > primary_value:
            secondary_element = primary_element
            secondary_value = primary_value
            primary_element = element
            primary_value = affinities[element]
        elif affinities[element] > secondary_value:
            secondary_element = element
            secondary_value = affinities[element]
    
    return {
        "primary": primary_element,
        "secondary": secondary_element,
        "affinities": affinities
    }

# Function to determine various sound qualities
func _determine_sound_qualities(word: String, vowels: Array, consonants: Array, pattern: String) -> Dictionary:
    var qualities = {
        "flowing": 0.0,  # Smooth, flowing sound
        "sharp": 0.0,    # Sharp, cutting sound
        "resonant": 0.0, # Resonating, echoing sound
        "heavy": 0.0,    # Heavy, substantial sound
        "light": 0.0,    # Light, airy sound
        "mystical": 0.0  # Unusual, magical-sounding
    }
    
    # Flowing quality (more vowels, liquid consonants)
    var vowel_ratio = float(vowels.size()) / max(1, word.length())
    qualities.flowing = vowel_ratio * 0.7
    
    for c in consonants:
        if c in phonetic_patterns.liquid:
            qualities.flowing += 0.05
    
    # Sharp quality (plosives, certain patterns)
    for c in consonants:
        if c in phonetic_patterns.plosive:
            qualities.sharp += 0.1
    
    if pattern.find("CC") >= 0:
        qualities.sharp += 0.2
    
    # Resonant quality
    for c in consonants:
        if c in phonetic_patterns.nasal:
            qualities.resonant += 0.1
    
    if pattern.ends_with("V"):
        qualities.resonant += 0.1
    
    # Heavy quality
    for c in consonants:
        if c in "gdbm":
            qualities.heavy += 0.1
    
    if vowel_ratio < 0.3:
        qualities.heavy += 0.2
    
    # Light quality
    for c in consonants:
        if c in "fshlty":
            qualities.light += 0.1
    
    if vowel_ratio > 0.6:
        qualities.light += 0.2
    
    # Mystical quality (unusual combinations)
    var unusual_combos = ["ae", "th", "qu", "ph", "zh", "sh", "ch"]
    for combo in unusual_combos:
        if word.find(combo) >= 0:
            qualities.mystical += 0.15
    
    # Clamp all values
    for quality in qualities:
        qualities[quality] = clamp(qualities[quality], 0.0, 1.0)
    
    return qualities

# Function to identify dominant phonetic patterns
func _identify_dominant_patterns(consonants: Array) -> Array:
    var pattern_counts = {}
    
    # Count occurrences of each pattern type
    for pattern_type in phonetic_patterns:
        pattern_counts[pattern_type] = 0
        
        for c in consonants:
            if c in phonetic_patterns[pattern_type]:
                pattern_counts[pattern_type] += 1
    
    # Find dominant patterns (above threshold)
    var dominant = []
    var threshold = max(1, consonants.size() * 0.3)
    
    for pattern_type in pattern_counts:
        if pattern_counts[pattern_type] >= threshold:
            dominant.append({
                "type": pattern_type,
                "count": pattern_counts[pattern_type]
            })
    
    # Sort by count
    dominant.sort_custom(self, "_sort_by_count")
    
    # Return just the pattern types
    var result = []
    for item in dominant:
        result.append(item.type)
    
    return result

# Helper function for sorting
func _sort_by_count(a, b):
    return a.count > b.count