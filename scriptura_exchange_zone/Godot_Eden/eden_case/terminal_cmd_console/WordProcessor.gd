extends Node
class_name WordProcessor

# ------------------------------------
# WordProcessor - Text processing engine for the World of Words system
# Analyzes, processes, and enriches word entities with power and attributes
# ------------------------------------

# Word database resource
var word_database = {}
var word_clusters = {}
var word_affinities = {}

# Constants
const DEFAULT_POWER = 25
const MIN_POWER = 5
const MAX_POWER = 100
const DIMENSIONAL_MODIFIERS = {
    "1D": 0.7,
    "2D": 0.9,
    "3D": 1.0,
    "4D": 1.2,
    "5D": 1.4,
    "6D": 1.8,
    "7D": 2.5
}
const SEMANTIC_CATEGORIES = [
    "divine", "cosmic", "reality", "creative", "elemental",
    "temporal", "spatial", "conscious", "technological", "natural",
    "emotional", "physical", "abstract", "scientific", "mystical"
]

# Runtime state
var current_turn = 1
var current_dimension = "3D"
var processing_mode = "standard"
var custom_rules = []

# Initialized flag
var is_initialized = false

# Reference to the WordDrive message bus
var word_drive = null

# Signal for when word database is updated
signal database_updated
signal word_processed(word_text, result)

# Initialize the processor
func _ready():
    print("WordProcessor initialized")
    _load_word_database()
    is_initialized = true

# Load the word database
func _load_word_database() -> void:
    var file = File.new()
    if file.open("/mnt/c/Users/Percision 15/12_turns_system/word_database.txt", File.READ) == OK:
        while not file.eof_reached():
            var line = file.get_line().strip_edges()
            if line.empty():
                continue
                
            var parts = line.split(" ", false, 1)
            if parts.size() >= 2:
                var word = parts[0].to_lower()
                var power = int(parts[1])
                word_database[word] = power
        file.close()
        
        # After loading, generate clusters and affinities
        _generate_word_clusters()
        _calculate_word_affinities()
        print("WordProcessor loaded %d words from database" % word_database.size())
    else:
        push_warning("WordProcessor: Failed to load word database")

# Process a word to determine its properties
func process_word(word_text: String, context: Dictionary = {}) -> Dictionary:
    if not is_initialized:
        push_warning("WordProcessor: Attempted to process word before initialization")
        return {"text": word_text, "power": DEFAULT_POWER}
    
    # Normalize text
    var normalized_text = word_text.strip_edges().to_lower()
    
    # If empty, return default
    if normalized_text.empty():
        return {"text": word_text, "power": MIN_POWER}
    
    # Calculate base power
    var power = _calculate_word_power(normalized_text)
    
    # Apply dimension modifier
    var dimension = context.get("dimension", current_dimension)
    power = _apply_dimension_modifier(power, dimension)
    
    # Apply turn context
    var turn = context.get("turn", current_turn)
    power = _apply_turn_modifier(power, turn)
    
    # Apply custom rules
    power = _apply_custom_rules(power, normalized_text, context)
    
    # Clamp power
    power = clamp(power, MIN_POWER, MAX_POWER)
    
    # Determine word attributes
    var attributes = _analyze_word_attributes(normalized_text)
    
    # Create result
    var result = {
        "text": word_text,
        "power": power,
        "attributes": attributes,
        "categories": _categorize_word(normalized_text),
        "processed_by": "WordProcessor v1.0",
        "timestamp": OS.get_unix_time()
    }
    
    # Emit signal
    emit_signal("word_processed", word_text, result)
    
    return result

# Calculate the power of a word
func _calculate_word_power(word_text: String) -> float:
    # Check if word exists in database
    if word_database.has(word_text):
        return float(word_database[word_text])
    
    # Word not in database, calculate based on substrings and algorithmic factors
    var power = DEFAULT_POWER
    
    # Factor 1: Word length
    power += min(word_text.length() * 2, 30)
    
    # Factor 2: Character diversity
    var unique_chars = {}
    for c in word_text:
        unique_chars[c] = true
    power += min(unique_chars.size() * 1.5, 15)
    
    # Factor 3: Substring matching with known words
    var substring_power = 0
    var match_count = 0
    
    for db_word in word_database:
        if word_text.find(db_word) >= 0:
            substring_power += word_database[db_word] * 0.4
            match_count += 1
        elif db_word.find(word_text) >= 0:
            substring_power += word_database[db_word] * 0.2
            match_count += 1
    
    if match_count > 0:
        power += min(substring_power / match_count, 40)
    
    # Factor 4: Symbolic characters
    var symbolic_chars = "!@#$%^&*()_+-={}[]|\\:;\"'<>,.?/~`"
    var symbol_count = 0
    for c in word_text:
        if symbolic_chars.find(c) >= 0:
            symbol_count += 1
    
    power += symbol_count * 3
    
    # Factor 5: Repeating characters (reduces power)
    var repeats = 0
    for i in range(1, word_text.length()):
        if word_text[i] == word_text[i-1]:
            repeats += 1
    
    power -= min(repeats * 2, 10)
    
    return power

# Apply dimension modifier to word power
func _apply_dimension_modifier(power: float, dimension: String) -> float:
    if DIMENSIONAL_MODIFIERS.has(dimension):
        return power * DIMENSIONAL_MODIFIERS[dimension]
    return power

# Apply turn-based modifier
func _apply_turn_modifier(power: float, turn: int) -> float:
    # Words get more powerful in later turns
    var turn_factor = 1.0 + (min(turn, 12) - 1) * 0.05
    return power * turn_factor

# Apply custom processing rules
func _apply_custom_rules(power: float, word_text: String, context: Dictionary) -> float:
    var modified_power = power
    
    for rule in custom_rules:
        if rule.has("condition") and rule.has("effect"):
            # Check if condition applies
            var condition_met = false
            
            match rule.condition.type:
                "contains":
                    condition_met = word_text.find(rule.condition.value) >= 0
                "length_greater_than":
                    condition_met = word_text.length() > rule.condition.value
                "length_less_than":
                    condition_met = word_text.length() < rule.condition.value
                "matches_regex":
                    # Would need proper regex implementation
                    pass
                "in_context":
                    condition_met = context.has(rule.condition.key) and context[rule.condition.key] == rule.condition.value
            
            # Apply effect if condition is met
            if condition_met:
                match rule.effect.type:
                    "multiply_power":
                        modified_power *= rule.effect.value
                    "add_power":
                        modified_power += rule.effect.value
                    "set_power":
                        modified_power = rule.effect.value
                    "min_power":
                        modified_power = max(modified_power, rule.effect.value)
                    "max_power":
                        modified_power = min(modified_power, rule.effect.value)
    
    return modified_power

# Analyze word for attributes
func _analyze_word_attributes(word_text: String) -> Dictionary:
    var attributes = {
        "length": word_text.length(),
        "has_vowels": false,
        "has_consonants": false,
        "first_letter": "",
        "last_letter": "",
        "syllable_count": _estimate_syllables(word_text),
        "character_types": {}
    }
    
    if word_text.length() > 0:
        attributes.first_letter = word_text[0]
        attributes.last_letter = word_text[word_text.length() - 1]
        
        # Check for vowels and consonants
        var vowels = "aeiou"
        var consonants = "bcdfghjklmnpqrstvwxyz"
        
        attributes.has_vowels = false
        attributes.has_consonants = false
        
        var char_counts = {}
        
        for c in word_text:
            if not char_counts.has(c):
                char_counts[c] = 0
            char_counts[c] += 1
            
            if vowels.find(c) >= 0:
                attributes.has_vowels = true
            elif consonants.find(c) >= 0:
                attributes.has_consonants = true
        
        attributes.character_counts = char_counts
        attributes.unique_character_count = char_counts.size()
    
    return attributes

# Categorize word into semantic categories
func _categorize_word(word_text: String) -> Array:
    var categories = []
    
    # Simple categorization based on substrings
    var category_keywords = {
        "divine": ["god", "divine", "sacred", "holy", "spirit", "soul", "eternal"],
        "cosmic": ["universe", "cosmos", "star", "galaxy", "space", "astral", "celestial"],
        "reality": ["real", "exist", "reality", "dimension", "truth", "actual"],
        "creative": ["create", "make", "build", "design", "craft", "art", "form"],
        "elemental": ["fire", "water", "earth", "air", "element", "nature"],
        "temporal": ["time", "age", "era", "moment", "duration", "eternal", "instant"],
        "spatial": ["space", "area", "region", "zone", "field", "place"],
        "conscious": ["mind", "think", "conscious", "aware", "thought", "sentient"],
        "technological": ["tech", "digital", "computer", "system", "machine", "code"],
        "natural": ["nature", "life", "organic", "growth", "evolve", "living"],
        "emotional": ["feel", "emotion", "heart", "love", "hate", "joy", "sad"],
        "physical": ["body", "material", "object", "mass", "weight", "solid"],
        "abstract": ["concept", "idea", "theory", "abstract", "thought", "notion"],
        "scientific": ["science", "study", "research", "data", "experiment", "analyze"],
        "mystical": ["magic", "mystic", "occult", "arcane", "esoteric", "hidden"]
    }
    
    for category in category_keywords:
        for keyword in category_keywords[category]:
            if word_text.find(keyword) >= 0:
                categories.append(category)
                break
    
    # If no categories found, add "undefined"
    if categories.empty():
        categories.append("undefined")
    
    return categories

# Estimate syllable count for English text
func _estimate_syllables(word: String) -> int:
    # Simple syllable counting algorithm
    var count = 0
    var prev_is_vowel = false
    var vowels = "aeiouy"
    
    for i in range(word.length()):
        var is_vowel = vowels.find(word[i]) >= 0
        if is_vowel and not prev_is_vowel:
            count += 1
        prev_is_vowel = is_vowel
    
    # Handle special cases
    if count == 0:
        count = 1  # Every word has at least one syllable
    
    # Handle silent e at end
    if word.length() > 2 and word[word.length() - 1] == "e" and vowels.find(word[word.length() - 2]) < 0:
        count = max(1, count - 1)
    
    return count

# Generate word clusters based on semantic relationships
func _generate_word_clusters() -> void:
    # Simple implementation: cluster by prefix and suffix
    word_clusters = {
        "prefixes": {},
        "suffixes": {},
        "length": {}
    }
    
    for word in word_database:
        # Cluster by first 2-3 letters (prefix)
        if word.length() >= 3:
            var prefix = word.substr(0, 3)
            if not word_clusters.prefixes.has(prefix):
                word_clusters.prefixes[prefix] = []
            word_clusters.prefixes[prefix].append(word)
        
        # Cluster by last 2-3 letters (suffix)
        if word.length() >= 3:
            var suffix = word.substr(word.length() - 3, 3)
            if not word_clusters.suffixes.has(suffix):
                word_clusters.suffixes[suffix] = []
            word_clusters.suffixes[suffix].append(word)
        
        # Cluster by length
        var length_key = str(word.length())
        if not word_clusters.length.has(length_key):
            word_clusters.length[length_key] = []
        word_clusters.length[length_key].append(word)

# Calculate affinity between words (how well they connect)
func _calculate_word_affinities() -> void:
    # For now, just initialize the structure
    word_affinities = {}
    
    # Full calculation would be expensive at startup
    # Will calculate on-demand when needed

# Calculate affinity between two specific words
func calculate_affinity(word1: String, word2: String) -> float:
    var w1 = word1.to_lower()
    var w2 = word2.to_lower()
    
    # Check cache
    var cache_key = w1 + "|" + w2
    if word_affinities.has(cache_key):
        return word_affinities[cache_key]
    
    var reversed_key = w2 + "|" + w1
    if word_affinities.has(reversed_key):
        return word_affinities[reversed_key]
    
    # Calculate affinity
    var affinity = 1.0
    
    # Factor 1: Shared letters
    var common_letters = 0
    for c in w1:
        if w2.find(c) >= 0:
            common_letters += 1
    
    var letter_similarity = float(common_letters) / max(w1.length(), w2.length())
    affinity *= (0.5 + letter_similarity)
    
    # Factor 2: Length similarity
    var length_diff = abs(w1.length() - w2.length())
    var length_factor = 1.0 - (min(length_diff, 10) / 10.0) * 0.5
    affinity *= length_factor
    
    # Factor 3: Database power relationship
    if word_database.has(w1) and word_database.has(w2):
        var power1 = word_database[w1]
        var power2 = word_database[w2]
        var power_diff = abs(power1 - power2)
        var power_factor = 1.0 - (min(power_diff, 50) / 50.0) * 0.3
        affinity *= power_factor
    
    # Factor 4: Special opposites (high affinity)
    var opposites = [
        ["light", "dark"], ["up", "down"], ["hot", "cold"],
        ["good", "evil"], ["life", "death"], ["create", "destroy"],
        ["begin", "end"], ["love", "hate"], ["truth", "lie"]
    ]
    
    for pair in opposites:
        if (w1.find(pair[0]) >= 0 and w2.find(pair[1]) >= 0) or \
           (w1.find(pair[1]) >= 0 and w2.find(pair[0]) >= 0):
            affinity *= 2.0
            break
    
    # Cache result
    word_affinities[cache_key] = affinity
    
    return affinity

# Find words similar to the given word
func find_similar_words(word_text: String, limit: int = 5) -> Array:
    var normalized = word_text.to_lower()
    var similar_words = []
    
    # First try to find by prefix if word is long enough
    if normalized.length() >= 3:
        var prefix = normalized.substr(0, 3)
        if word_clusters.prefixes.has(prefix):
            for similar in word_clusters.prefixes[prefix]:
                if similar != normalized:
                    similar_words.append({"word": similar, "power": word_database[similar]})
    
    # If we don't have enough, try suffix
    if similar_words.size() < limit and normalized.length() >= 3:
        var suffix = normalized.substr(normalized.length() - 3, 3)
        if word_clusters.suffixes.has(suffix):
            for similar in word_clusters.suffixes[suffix]:
                if similar != normalized and not similar_words.has({"word": similar, "power": word_database[similar]}):
                    similar_words.append({"word": similar, "power": word_database[similar]})
    
    # Still need more? Try by length
    if similar_words.size() < limit:
        var length_key = str(normalized.length())
        if word_clusters.length.has(length_key):
            for similar in word_clusters.length[length_key]:
                if similar != normalized and not similar_words.has({"word": similar, "power": word_database[similar]}):
                    similar_words.append({"word": similar, "power": word_database[similar]})
    
    # Limit results
    if similar_words.size() > limit:
        similar_words = similar_words.slice(0, limit)
    
    return similar_words

# Add a custom processing rule
func add_custom_rule(condition: Dictionary, effect: Dictionary) -> void:
    custom_rules.append({
        "condition": condition,
        "effect": effect,
        "id": "rule_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    })

# Remove a custom rule by ID
func remove_custom_rule(rule_id: String) -> bool:
    for i in range(custom_rules.size()):
        if custom_rules[i].id == rule_id:
            custom_rules.remove(i)
            return true
    return false

# Clear all custom rules
func clear_custom_rules() -> void:
    custom_rules.clear()

# Add a word to the database
func add_word_to_database(word: String, power: int) -> void:
    word_database[word.to_lower()] = clamp(power, MIN_POWER, MAX_POWER)
    # Update clusters and emit signal
    _generate_word_clusters()
    emit_signal("database_updated")

# Set the current turn
func set_turn(turn: int) -> void:
    current_turn = turn

# Set the current dimension
func set_dimension(dimension: String) -> void:
    current_dimension = dimension

# Connect to WordDrive
func connect_to_word_drive(drive) -> void:
    word_drive = drive