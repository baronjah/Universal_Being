extends Node
class_name JSHPatternAnalyzer

# Static instance for singleton pattern
static var _instance = null

# Pattern significance weights
var pattern_weights = {
    "repetition": 0.3,      # Weight of repetition patterns
    "symmetry": 0.25,       # Weight of symmetrical patterns
    "progression": 0.2,     # Weight of progressive patterns
    "alternation": 0.15,    # Weight of alternating patterns
    "clustering": 0.1       # Weight of character clusters
}

# Pattern types and their baseline power
var pattern_power = {
    "palindrome": 0.9,      # Words that read the same backward as forward
    "alliteration": 0.7,    # Repeated consonant sounds
    "rhyme": 0.6,           # Similar ending sounds
    "assonance": 0.5,       # Repeated vowel sounds
    "consonance": 0.5,      # Consonant repetition with different vowels
    "reduplication": 0.8,   # Repeating syllables (e.g., "murmur")
    "anagram": 0.6,         # Rearrangements of same letters
    "chiasmus": 0.7         # Crosswise arrangement (e.g., AB-BA pattern)
}

# Static accessor for singleton
static func get_instance():
    if not _instance:
        _instance = JSHPatternAnalyzer.new()
    return _instance

# Core analysis function
func analyze(word: String) -> Dictionary:
    # Convert to lowercase for consistent analysis
    var text = word.to_lower()
    
    # Initialize result structure
    var result = {
        "repetitions": 0,           # Count of repeated characters
        "unique_chars_ratio": 0.0,  # Ratio of unique characters to total
        "symmetry": 0.0,            # Symmetry score (0.0-1.0)
        "patterns": [],             # Identified patterns
        "power": 0.5,               # Pattern-based power (0.0-1.0)
        "character_stats": {},      # Statistics about character usage
        "sequence_patterns": [],    # Identified sequence patterns
        "visual_balance": 0.0       # Visual balance/harmony (0.0-1.0)
    }
    
    # Calculate character statistics
    var char_stats = _calculate_char_stats(text)
    result.character_stats = char_stats
    result.repetitions = char_stats.repetitions
    result.unique_chars_ratio = char_stats.unique_ratio
    
    # Calculate symmetry
    result.symmetry = _calculate_symmetry(text)
    
    # Identify patterns
    result.patterns = _identify_patterns(text, char_stats)
    
    # Identify sequence patterns
    result.sequence_patterns = _identify_sequence_patterns(text)
    
    # Calculate pattern-based power
    result.power = _calculate_pattern_power(text, result.patterns, result.symmetry, char_stats)
    
    # Calculate visual balance
    result.visual_balance = _calculate_visual_balance(text, char_stats)
    
    return result

# Function to calculate character statistics
func _calculate_char_stats(word: String) -> Dictionary:
    var char_counts = {}
    var result = {
        "total_chars": word.length(),
        "unique_chars": 0,
        "most_frequent": {
            "char": "",
            "count": 0
        },
        "repetitions": 0,
        "unique_ratio": 0.0,
        "char_counts": {}
    }
    
    # Count character occurrences
    for c in word:
        if not char_counts.has(c):
            char_counts[c] = 0
        char_counts[c] += 1
        
        # Track most frequent character
        if char_counts[c] > result.most_frequent.count:
            result.most_frequent.char = c
            result.most_frequent.count = char_counts[c]
    
    # Calculate unique characters
    result.unique_chars = char_counts.size()
    
    # Calculate repetitions (sum of counts beyond 1)
    for c in char_counts:
        if char_counts[c] > 1:
            result.repetitions += char_counts[c] - 1
    
    # Calculate unique ratio
    if word.length() > 0:
        result.unique_ratio = float(result.unique_chars) / word.length()
    
    # Save char counts to result
    result.char_counts = char_counts
    
    return result

# Function to calculate symmetry
func _calculate_symmetry(word: String) -> float:
    var symmetry_score = 0.0
    
    if word.length() <= 1:
        return 1.0  # Single character is perfectly symmetric
    
    # Check for palindrome (perfect symmetry)
    var is_palindrome = true
    for i in range(word.length() / 2):
        if word[i] != word[word.length() - 1 - i]:
            is_palindrome = false
            break
    
    if is_palindrome:
        return 1.0
    
    # Calculate partial symmetry
    var matches = 0
    var total = word.length() / 2
    
    for i in range(total):
        if word[i] == word[word.length() - 1 - i]:
            matches += 1
    
    if total > 0:
        symmetry_score = float(matches) / total
    
    # Boost symmetry for near-palindromes (small edit distance)
    if symmetry_score > 0.7:
        symmetry_score = 0.7 + (symmetry_score * 0.3)
    
    return symmetry_score

# Function to identify patterns
func _identify_patterns(word: String, char_stats: Dictionary) -> Array:
    var identified_patterns = []
    
    # Check for palindrome
    if _calculate_symmetry(word) >= 0.99:
        identified_patterns.append({
            "type": "palindrome",
            "strength": 1.0
        })
    
    # Check for alliteration (repeated initial consonants)
    var syllables = _split_into_syllables(word)
    var initial_consonants = []
    
    for syllable in syllables:
        if syllable.length() > 0:
            var initial = syllable[0]
            if not "aeiou".find(initial) >= 0:  # If it's a consonant
                initial_consonants.append(initial)
    
    if initial_consonants.size() > 1:
        var alliteration_count = 0
        
        for i in range(1, initial_consonants.size()):
            if initial_consonants[i] == initial_consonants[i-1]:
                alliteration_count += 1
        
        if alliteration_count > 0:
            var strength = min(1.0, float(alliteration_count) / (initial_consonants.size() - 1))
            identified_patterns.append({
                "type": "alliteration",
                "strength": strength
            })
    
    # Check for assonance (repeated vowel sounds)
    var vowel_sequence = ""
    for c in word:
        if "aeiou".find(c) >= 0:
            vowel_sequence += c
    
    if vowel_sequence.length() > 1:
        var vowel_counts = {}
        for v in vowel_sequence:
            if not vowel_counts.has(v):
                vowel_counts[v] = 0
            vowel_counts[v] += 1
        
        var repeated_vowels = 0
        for v in vowel_counts:
            if vowel_counts[v] > 1:
                repeated_vowels += vowel_counts[v] - 1
        
        if repeated_vowels > 0:
            var strength = min(1.0, float(repeated_vowels) / vowel_sequence.length())
            identified_patterns.append({
                "type": "assonance",
                "strength": strength
            })
    
    # Check for consonance (repeated consonant sounds)
    var consonant_sequence = ""
    for c in word:
        if not "aeiou".find(c) >= 0:
            consonant_sequence += c
    
    if consonant_sequence.length() > 1:
        var consonant_counts = {}
        for c in consonant_sequence:
            if not consonant_counts.has(c):
                consonant_counts[c] = 0
            consonant_counts[c] += 1
        
        var repeated_consonants = 0
        for c in consonant_counts:
            if consonant_counts[c] > 1:
                repeated_consonants += consonant_counts[c] - 1
        
        if repeated_consonants > 0:
            var strength = min(1.0, float(repeated_consonants) / consonant_sequence.length())
            identified_patterns.append({
                "type": "consonance",
                "strength": strength
            })
    
    # Check for reduplication (repeating syllables)
    if syllables.size() > 1:
        var reduplication_count = 0
        
        for i in range(1, syllables.size()):
            if syllables[i] == syllables[i-1]:
                reduplication_count += 1
        
        if reduplication_count > 0:
            var strength = min(1.0, float(reduplication_count) / (syllables.size() - 1))
            identified_patterns.append({
                "type": "reduplication",
                "strength": strength
            })
    
    # Check for rhyming pattern in multi-syllable words
    if syllables.size() > 1:
        var last_syllables = []
        for syl in syllables:
            if syl.length() > 0:
                last_syllables.append(syl.substr(syl.length() - 1))
        
        var rhyme_count = 0
        for i in range(1, last_syllables.size()):
            if last_syllables[i] == last_syllables[i-1]:
                rhyme_count += 1
        
        if rhyme_count > 0:
            var strength = min(1.0, float(rhyme_count) / (last_syllables.size() - 1))
            identified_patterns.append({
                "type": "rhyme",
                "strength": strength
            })
    
    # Check for chiasmus pattern (ABBA)
    if word.length() >= 4:
        if word[0] == word[3] and word[1] == word[2]:
            identified_patterns.append({
                "type": "chiasmus",
                "strength": 1.0
            })
    
    return identified_patterns

# Function to identify sequence patterns
func _identify_sequence_patterns(word: String) -> Array:
    var identified_patterns = []
    
    # Check for alphabetical progression
    var is_increasing = true
    var is_decreasing = true
    
    for i in range(1, word.length()):
        if word[i].ord() <= word[i-1].ord():
            is_increasing = false
        if word[i].ord() >= word[i-1].ord():
            is_decreasing = false
    
    if is_increasing and word.length() > 2:
        identified_patterns.append({
            "type": "increasing_sequence",
            "strength": min(1.0, word.length() * 0.2)
        })
    
    if is_decreasing and word.length() > 2:
        identified_patterns.append({
            "type": "decreasing_sequence",
            "strength": min(1.0, word.length() * 0.2)
        })
    
    # Check for alternating patterns
    var has_alternating_vowels = true
    var has_alternating_consonants = true
    var last_was_vowel = null
    
    for c in word:
        var is_vowel = "aeiou".find(c) >= 0
        
        if last_was_vowel != null:
            if is_vowel == last_was_vowel:
                has_alternating_vowels = false
        
        last_was_vowel = is_vowel
    
    if has_alternating_vowels and word.length() > 2:
        identified_patterns.append({
            "type": "alternating_vowels_consonants",
            "strength": min(1.0, word.length() * 0.2)
        })
    
    return identified_patterns

# Function to calculate pattern-based power
func _calculate_pattern_power(word: String, patterns: Array, symmetry: float, char_stats: Dictionary) -> float:
    var base_power = 0.3  # Start with a base power
    
    # Add power from identified patterns
    for pattern in patterns:
        if pattern_power.has(pattern.type):
            base_power += pattern_power[pattern.type] * pattern.strength * pattern_weights.repetition
    
    # Add power from symmetry
    base_power += symmetry * pattern_weights.symmetry
    
    # Add power from unique character ratio
    var uniqueness_factor = 0.0
    if char_stats.unique_ratio > 0.5:
        uniqueness_factor = (char_stats.unique_ratio - 0.5) * 2.0
    else:
        uniqueness_factor = -((0.5 - char_stats.unique_ratio) * 2.0)
    
    base_power += uniqueness_factor * 0.1
    
    return clamp(base_power, 0.1, 1.0)

# Function to calculate visual balance
func _calculate_visual_balance(word: String, char_stats: Dictionary) -> float:
    var balance_score = 0.5  # Start with moderate balance
    
    # Perfect symmetry is perfectly balanced
    if _calculate_symmetry(word) >= 0.95:
        return 1.0
    
    # Calculate visual weight distribution
    var left_weight = 0.0
    var right_weight = 0.0
    var midpoint = word.length() / 2.0
    
    for i in range(word.length()):
        var char_weight = 1.0
        
        # Some characters have visually more "weight"
        var heavy_chars = "mbwgpqdy"
        var light_chars = "ilt.,"
        
        if heavy_chars.find(word[i]) >= 0:
            char_weight = 1.5
        elif light_chars.find(word[i]) >= 0:
            char_weight = 0.7
        
        # Calculate position relative to midpoint
        var position = float(i) / word.length()
        
        if position < 0.5:
            left_weight += char_weight
        else:
            right_weight += char_weight
    
    # Calculate balance ratio
    var total_weight = left_weight + right_weight
    var balance_ratio = 0.0
    
    if total_weight > 0:
        balance_ratio = 1.0 - (abs(left_weight - right_weight) / total_weight)
    
    // Adjust balance score
    balance_score = 0.3 + (balance_ratio * 0.7)
    
    // Length affects balance - very short words are less balanced
    if word.length() < 3:
        balance_score *= 0.8
    
    return clamp(balance_score, 0.0, 1.0)

# Helper function to split a word into syllables (simplified)
func _split_into_syllables(word: String) -> Array:
    # This is a very simplified syllable splitter
    var syllables = []
    var current_syllable = ""
    var in_vowel_group = false
    
    for c in word:
        var is_vowel = "aeiou".find(c) >= 0
        
        if is_vowel and not in_vowel_group:
            # Starting a new vowel group
            if current_syllable.length() > 0:
                syllables.append(current_syllable)
                current_syllable = ""
            current_syllable += c
            in_vowel_group = true
        elif is_vowel and in_vowel_group:
            # Continuing a vowel group
            current_syllable += c
        elif not is_vowel and in_vowel_group:
            # End of vowel group, start consonant
            current_syllable += c
            in_vowel_group = false
        else:  # not is_vowel and not in_vowel_group
            # Continuing consonants
            current_syllable += c
    
    // Add the last syllable if there is one
    if current_syllable.length() > 0:
        syllables.append(current_syllable)
    
    return syllables