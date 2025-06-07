extends Node

class_name WordDirectionTracker

# Word Direction Tracker - Analyzes patterns and directions in words and program actions
# Integrates with the 12-turn system and memory investment

# Constants
const DIRECTION_VECTORS = {
    "forward": Vector3(0, 0, 1),
    "backward": Vector3(0, 0, -1),
    "up": Vector3(0, 1, 0),
    "down": Vector3(0, -1, 0),
    "left": Vector3(-1, 0, 0),
    "right": Vector3(1, 0, 0),
    "inward": Vector3(-0.5, -0.5, -0.5),
    "outward": Vector3(0.5, 0.5, 0.5),
    "clockwise": Vector3(0.7, 0.7, 0),
    "counterclockwise": Vector3(-0.7, 0.7, 0)
}

const ACTION_TYPES = {
    "create": 0,
    "modify": 1,
    "delete": 2,
    "read": 3,
    "execute": 4,
    "connect": 5,
    "disconnect": 6,
    "analyze": 7,
    "synthesize": 8,
    "transform": 9,
    "shift": 10,
    "pause": 11
}

const WORD_CATEGORIES = {
    "noun": 0,
    "verb": 1,
    "adjective": 2,
    "adverb": 3,
    "pronoun": 4,
    "conjunction": 5,
    "preposition": 6,
    "interjection": 7,
    "modifier": 8,
    "symbol": 9,
    "command": 10,
    "query": 11
}

const ACTIVATION_THRESHOLDS = {
    "word": 5.0,
    "direction": 3.0,
    "action": 4.0,
    "pattern": 7.0,
    "composite": 10.0
}

# Direction tracking and analysis
var word_directions = {}
var action_history = []
var pattern_detections = {}
var direction_strengths = {}
var active_directions = []
var current_direction = "forward"
var direction_momentum = 0.0
var pattern_memory = []
var global_direction_vector = Vector3(0, 0, 1) # Default forward
var infrastructure_map = {}
var word_clusters = {}
var program_flow_paths = []
var activation_levels = {}

# System connection
var investment_system = null
var memory_system = null
var turn_system = null

# Temporal tracking
var last_analysis_time = 0
var analysis_frequency = 5.0 # seconds
var pattern_decay_rate = 0.05
var direction_shift_count = 0
var last_direction_shift = 0

# Visualization
var visualization_enabled = true
var visualization_scale = 1.0
var visualization_color = Color(0.4, 0.6, 0.9, 0.8) # EVE blue
var visualization_points = []
var direction_trails = []
var active_trail = []

# Signals
signal direction_changed(from_dir, to_dir, strength)
signal pattern_detected(pattern_type, words, strength)
signal word_analyzed(word, direction, category)
signal action_tracked(action_type, source, target)
signal infrastructure_mapped(node_count, connection_count)
signal critical_mass_reached(direction, intensity)

func _ready():
    # Initialize system
    _initialize_direction_strengths()
    _initialize_activation_levels()
    
    # Connect to related systems
    connect_to_memory_system()
    connect_to_investment_system()
    
    # Set up analysis timer
    var timer = Timer.new()
    timer.wait_time = analysis_frequency
    timer.autostart = true
    timer.connect("timeout", self, "_on_analysis_timer")
    add_child(timer)
    
    print("Word Direction Tracker initialized")
    print("Current direction: " + current_direction)
    print("Analysis frequency: " + str(analysis_frequency) + " seconds")

func _process(delta):
    # Update visualization if enabled
    if visualization_enabled:
        _update_visualization(delta)
    
    # Update direction momentum
    _update_direction_momentum(delta)

func connect_to_memory_system():
    # Connect to ProjectMemorySystem if available
    if has_node("/root/ProjectMemorySystem") or get_node_or_null("/root/ProjectMemorySystem"):
        memory_system = get_node("/root/ProjectMemorySystem")
        print("Connected to ProjectMemorySystem")
        return true
    
    # Try SmartAccountSystem path
    if has_node("/root/SmartAccountSystem/ProjectMemorySystem") or get_node_or_null("/root/SmartAccountSystem/ProjectMemorySystem"):
        memory_system = get_node("/root/SmartAccountSystem/ProjectMemorySystem")
        print("Connected to ProjectMemorySystem under SmartAccountSystem")
        return true
    
    return false

func connect_to_investment_system():
    # Connect to MemoryInvestmentSystem if available
    if has_node("/root/MemoryInvestmentSystem") or get_node_or_null("/root/MemoryInvestmentSystem"):
        investment_system = get_node("/root/MemoryInvestmentSystem")
        print("Connected to MemoryInvestmentSystem")
        return true
    
    # Try SmartAccountSystem path
    if has_node("/root/SmartAccountSystem/MemoryInvestmentSystem") or get_node_or_null("/root/SmartAccountSystem/MemoryInvestmentSystem"):
        investment_system = get_node("/root/SmartAccountSystem/MemoryInvestmentSystem")
        print("Connected to MemoryInvestmentSystem under SmartAccountSystem")
        return true
    
    return false

func _initialize_direction_strengths():
    # Initialize direction strengths
    for direction in DIRECTION_VECTORS:
        direction_strengths[direction] = 0.0

func _initialize_activation_levels():
    # Initialize activation levels
    for threshold_type in ACTIVATION_THRESHOLDS:
        activation_levels[threshold_type] = 0.0

func analyze_word(word, category = "noun"):
    # Skip empty words
    if word.empty():
        return null
    
    # Validate category
    if not category in WORD_CATEGORIES:
        category = "noun"
    
    # Check if word is already analyzed
    if word in word_directions:
        # Update existing analysis
        word_directions[word]["count"] += 1
        word_directions[word]["last_seen"] = OS.get_unix_time()
        
        # Strengthen existing direction
        var direction = word_directions[word]["direction"]
        direction_strengths[direction] += 0.5
        
        emit_signal("word_analyzed", word, direction, category)
        return word_directions[word]
    
    # Determine direction based on word characteristics
    var direction = _determine_word_direction(word)
    
    # Create word direction record
    word_directions[word] = {
        "word": word,
        "direction": direction,
        "category": category,
        "count": 1,
        "first_seen": OS.get_unix_time(),
        "last_seen": OS.get_unix_time(),
        "vector": DIRECTION_VECTORS[direction],
        "associations": [],
        "patterns": []
    }
    
    # Strengthen this direction
    direction_strengths[direction] += 1.0
    
    # Update global direction
    _update_global_direction()
    
    # Check for patterns
    _check_for_word_patterns(word)
    
    # Add to visualization
    if visualization_enabled:
        _add_visualization_point(word, direction)
    
    # Invest in the word if investment system is available
    if investment_system and investment_system.has_method("invest_word"):
        var rarity = _determine_word_rarity(word)
        var value = _calculate_word_value(word, category, rarity)
        investment_system.invest_word(word, "directional", value, rarity)
    
    # Store in memory system if available
    if memory_system and memory_system.has_method("add_memory"):
        memory_system.add_memory(
            "Word direction: " + word + " -> " + direction,
            "word_directions",
            [word, direction, category]
        )
    
    # Emit signal
    emit_signal("word_analyzed", word, direction, category)
    
    print("Analyzed word: " + word + " -> " + direction + " (" + category + ")")
    return word_directions[word]

func track_action(action, source = "", target = ""):
    # Validate action
    if not action in ACTION_TYPES:
        print("Invalid action type: " + action)
        return null
    
    # Record action
    var action_data = {
        "action": action,
        "source": source,
        "target": target,
        "timestamp": OS.get_unix_time(),
        "direction": current_direction,
        "global_vector": global_direction_vector
    }
    
    # Add to action history
    action_history.append(action_data)
    
    # Limit history size
    if action_history.size() > 100:
        action_history.pop_front()
    
    # Update activation levels based on action
    _update_activation_levels(action)
    
    # Emit signal
    emit_signal("action_tracked", action, source, target)
    
    print("Tracked action: " + action + " from " + source + " to " + target)
    return action_data

func change_direction(direction):
    # Validate direction
    if not direction in DIRECTION_VECTORS:
        print("Invalid direction: " + direction)
        return false
    
    var old_direction = current_direction
    current_direction = direction
    
    # Reset momentum when changing direction
    direction_momentum = 1.0
    
    # Update global direction vector
    global_direction_vector = DIRECTION_VECTORS[direction]
    
    # Record direction shift
    direction_shift_count += 1
    last_direction_shift = OS.get_unix_time()
    
    # Add to active directions if not already there
    if not direction in active_directions:
        active_directions.append(direction)
    
    # Start a new trail for visualization
    if visualization_enabled:
        _start_new_trail()
    
    # Emit signal
    emit_signal("direction_changed", old_direction, direction, direction_strengths[direction])
    
    print("Direction changed: " + old_direction + " -> " + direction)
    return true

func detect_pattern(words):
    # Need at least 3 words for a pattern
    if words.size() < 3:
        return null
    
    # Calculate pattern characteristics
    var pattern_type = _determine_pattern_type(words)
    var pattern_strength = _calculate_pattern_strength(words, pattern_type)
    var pattern_vector = _calculate_pattern_vector(words)
    
    # Generate unique pattern ID
    var pattern_id = _generate_pattern_id(words, pattern_type)
    
    # Record pattern detection
    pattern_detections[pattern_id] = {
        "id": pattern_id,
        "type": pattern_type,
        "words": words,
        "strength": pattern_strength,
        "detected_at": OS.get_unix_time(),
        "vector": pattern_vector
    }
    
    # Add to memory
    pattern_memory.append(pattern_id)
    
    # Limit pattern memory size
    if pattern_memory.size() > 50:
        pattern_memory.pop_front()
    
    # Add pattern to the word records
    for word in words:
        if word in word_directions:
            word_directions[word]["patterns"].append(pattern_id)
    
    # Update infrastructure map
    _update_infrastructure_with_pattern(pattern_id, words, pattern_type)
    
    # Emit signal
    emit_signal("pattern_detected", pattern_type, words, pattern_strength)
    
    print("Detected pattern: " + pattern_type + " with strength " + str(pattern_strength))
    return pattern_detections[pattern_id]

func map_infrastructure(depth = 2):
    # Build an infrastructure map of words, directions, and patterns
    infrastructure_map = {
        "nodes": {},
        "connections": {},
        "clusters": {},
        "flows": []
    }
    
    # Add words as nodes
    for word in word_directions:
        infrastructure_map["nodes"][word] = {
            "type": "word",
            "direction": word_directions[word]["direction"],
            "vector": word_directions[word]["vector"],
            "strength": word_directions[word]["count"],
            "connections": []
        }
    
    # Add patterns as nodes
    for pattern_id in pattern_detections:
        var pattern = pattern_detections[pattern_id]
        infrastructure_map["nodes"][pattern_id] = {
            "type": "pattern",
            "pattern_type": pattern["type"],
            "strength": pattern["strength"],
            "vector": pattern["vector"],
            "connections": []
        }
    
    # Build connections
    for word in word_directions:
        # Connect words to their patterns
        for pattern_id in word_directions[word]["patterns"]:
            _add_infrastructure_connection(word, pattern_id, "part_of")
        
        # Connect words to associated words
        for associated_word in word_directions[word]["associations"]:
            _add_infrastructure_connection(word, associated_word, "associated_with")
    
    # Build word clusters
    _build_word_clusters()
    
    # Generate program flow paths
    _generate_flow_paths(depth)
    
    # Calculate infrastructure metrics
    var node_count = infrastructure_map["nodes"].size()
    var connection_count = infrastructure_map["connections"].size()
    
    # Emit signal
    emit_signal("infrastructure_mapped", node_count, connection_count)
    
    print("Mapped program infrastructure: " + str(node_count) + " nodes, " + str(connection_count) + " connections")
    return infrastructure_map

func associate_words(word1, word2):
    # Ensure both words exist
    if not word1 in word_directions or not word2 in word_directions:
        print("One or both words not found")
        return false
    
    # Add association
    if not word2 in word_directions[word1]["associations"]:
        word_directions[word1]["associations"].append(word2)
    
    if not word1 in word_directions[word2]["associations"]:
        word_directions[word2]["associations"].append(word1)
    
    print("Associated words: " + word1 + " <-> " + word2)
    
    # See if this creates any new patterns
    var potential_pattern = []
    
    # Look for other common associations
    for assoc in word_directions[word1]["associations"]:
        if assoc in word_directions[word2]["associations"] and assoc != word1 and assoc != word2:
            potential_pattern = [word1, word2, assoc]
            break
    
    if potential_pattern.size() >= 3:
        detect_pattern(potential_pattern)
    
    return true

func analyze_sentence(sentence):
    # Break sentence into words and analyze each
    var words = sentence.split(" ")
    var analyzed_words = []
    var sentence_direction = null
    
    for word in words:
        # Clean word
        word = word.strip_edges().to_lower()
        if word.empty():
            continue
        
        # Guess word category
        var category = _guess_word_category(word)
        
        # Analyze word
        var word_data = analyze_word(word, category)
        if word_data:
            analyzed_words.append(word_data)
    
    # Determine overall sentence direction
    if analyzed_words.size() > 0:
        sentence_direction = _determine_sentence_direction(analyzed_words)
        
        # If sentence has strong directional intent, change direction
        var strength = 0.0
        for word_data in analyzed_words:
            if word_data["direction"] == sentence_direction:
                strength += 1.0
        
        if strength >= analyzed_words.size() * 0.5:
            change_direction(sentence_direction)
    
    return {
        "words": analyzed_words,
        "direction": sentence_direction,
        "strength": analyzed_words.size()
    }

func get_recommended_direction():
    # Calculate which direction would be most beneficial to explore next
    var directions = []
    
    # Find underutilized directions with potential
    for direction in direction_strengths:
        var current_strength = direction_strengths[direction]
        var exploration_value = 5.0 - current_strength
        
        if exploration_value > 0:
            directions.append({
                "direction": direction,
                "value": exploration_value,
                "vector": DIRECTION_VECTORS[direction]
            })
    
    # Sort by value
    directions.sort_custom(self, "_sort_by_direction_value")
    
    if directions.size() > 0:
        return directions[0]["direction"]
    else:
        return current_direction

func get_word_cloud(max_words = 20):
    # Generate a word cloud of important words
    var words = []
    
    # Collect words with count and direction
    for word in word_directions:
        words.append({
            "word": word,
            "count": word_directions[word]["count"],
            "direction": word_directions[word]["direction"],
            "last_seen": word_directions[word]["last_seen"]
        })
    
    # Sort by count
    words.sort_custom(self, "_sort_by_word_count")
    
    # Return top words
    return words.slice(0, min(max_words - 1, words.size() - 1))

func get_direction_summary():
    # Generate a summary of active directions
    var summary = {}
    
    # Summarize direction strengths
    for direction in direction_strengths:
        summary[direction] = {
            "strength": direction_strengths[direction],
            "is_active": direction in active_directions,
            "is_current": direction == current_direction,
            "vector": DIRECTION_VECTORS[direction]
        }
    
    summary["global_vector"] = global_direction_vector
    summary["momentum"] = direction_momentum
    summary["shifts"] = direction_shift_count
    
    return summary

func toggle_visualization(enabled = null):
    if enabled != null:
        visualization_enabled = enabled
    else:
        visualization_enabled = !visualization_enabled
    
    print("Visualization " + ("enabled" if visualization_enabled else "disabled"))
    return visualization_enabled

func set_visualization_color(color):
    visualization_color = color
    return visualization_color

func _on_analysis_timer():
    # Periodic analysis of directions and patterns
    var current_time = OS.get_unix_time()
    var time_since_last = current_time - last_analysis_time
    last_analysis_time = current_time
    
    # Apply pattern decay
    _apply_pattern_decay(time_since_last)
    
    # Check for activation thresholds
    _check_activation_thresholds()
    
    # Find emergent patterns
    _find_emergent_patterns()
    
    # Update infrastructure if needed
    if time_since_last > 30: # Every 30 seconds
        map_infrastructure()
    
    return {
        "time": current_time,
        "patterns": pattern_detections.size(),
        "directions": active_directions.size()
    }

func _update_direction_momentum(delta):
    # Gradually reduce momentum over time
    if direction_momentum > 0:
        direction_momentum = max(0, direction_momentum - (delta * 0.1))

func _update_global_direction():
    # Calculate global direction vector based on direction strengths
    var result_vector = Vector3(0, 0, 0)
    var total_strength = 0.0
    
    for direction in direction_strengths:
        var strength = direction_strengths[direction]
        if strength > 0:
            result_vector += DIRECTION_VECTORS[direction] * strength
            total_strength += strength
    
    if total_strength > 0:
        result_vector = result_vector / total_strength
    else:
        result_vector = DIRECTION_VECTORS[current_direction]
    
    global_direction_vector = result_vector.normalized()

func _determine_word_direction(word):
    # Analyze word to determine its inherent direction
    var word_lower = word.to_lower()
    
    # Check for explicit direction words
    for direction in DIRECTION_VECTORS:
        if word_lower.find(direction) >= 0:
            return direction
    
    # Check semantic meaning of common words
    var forward_words = ["go", "move", "advance", "progress", "continue", "next", "future"]
    var backward_words = ["back", "return", "previous", "past", "undo", "revert"]
    var up_words = ["rise", "ascend", "climb", "above", "over", "upper"]
    var down_words = ["descend", "fall", "below", "under", "lower", "beneath"]
    var left_words = ["west", "port", "sinister"]
    var right_words = ["east", "starboard", "dexter"]
    var inward_words = ["in", "inside", "internal", "deep", "core", "center"]
    var outward_words = ["out", "outside", "external", "surface", "edge", "border"]
    
    if word_lower in forward_words:
        return "forward"
    elif word_lower in backward_words:
        return "backward"
    elif word_lower in up_words:
        return "up"
    elif word_lower in down_words:
        return "down"
    elif word_lower in left_words:
        return "left"
    elif word_lower in right_words:
        return "right"
    elif word_lower in inward_words:
        return "inward"
    elif word_lower in outward_words:
        return "outward"
    
    # Use character pattern analysis for remaining words
    var first_char = word_lower[0]
    var last_char = word_lower[word_lower.length() - 1]
    
    # Words starting with b, c, d tend backwards
    if first_char in ["b", "c", "d"]:
        return "backward"
    # Words starting with a, e, f, g tend forward
    elif first_char in ["a", "e", "f", "g"]:
        return "forward"
    # Words ending with up-like letters tend upward
    elif last_char in ["b", "d", "h", "k", "l", "t"]:
        return "up"
    # Words ending with down-like letters tend downward
    elif last_char in ["g", "j", "p", "q", "y"]:
        return "down"
    # Words with circular letters tend clockwise
    elif word_lower.find("o") >= 0 or word_lower.find("e") >= 0:
        return "clockwise"
    # Words with many angular letters tend counterclockwise
    elif word_lower.find("z") >= 0 or word_lower.find("x") >= 0:
        return "counterclockwise"
    
    # Default to current direction
    return current_direction

func _determine_sentence_direction(analyzed_words):
    # Count directions
    var direction_counts = {}
    
    for direction in DIRECTION_VECTORS:
        direction_counts[direction] = 0
    
    for word_data in analyzed_words:
        var dir = word_data["direction"]
        direction_counts[dir] += 1
    
    # Find dominant direction
    var max_count = 0
    var dominant_direction = current_direction
    
    for direction in direction_counts:
        if direction_counts[direction] > max_count:
            max_count = direction_counts[direction]
            dominant_direction = direction
    
    return dominant_direction

func _guess_word_category(word):
    # Simple heuristic to guess word category
    # In a real implementation, would use a more sophisticated approach
    
    word = word.strip_edges().to_lower()
    
    # Check for symbol
    if "!@#$%^&*()_+-=[]{}|;:'\",.<>/?\\".find(word) >= 0:
        return "symbol"
    
    # Check for verbs (common endings)
    if word.ends_with("ing") or word.ends_with("ed") or word.ends_with("ate"):
        return "verb"
    
    # Check for adjectives (common endings)
    if word.ends_with("ful") or word.ends_with("ous") or word.ends_with("ive") or word.ends_with("al"):
        return "adjective"
    
    # Check for adverbs (common ending)
    if word.ends_with("ly"):
        return "adverb"
    
    # Check for pronouns
    var pronouns = ["i", "you", "he", "she", "it", "we", "they", "me", "him", "her", "us", "them"]
    if word in pronouns:
        return "pronoun"
    
    # Check for prepositions
    var prepositions = ["in", "on", "at", "by", "for", "with", "about", "against", "between"]
    if word in prepositions:
        return "preposition"
    
    # Check for conjunctions
    var conjunctions = ["and", "but", "or", "nor", "so", "yet", "for"]
    if word in conjunctions:
        return "conjunction"
    
    # Check for interjections
    var interjections = ["oh", "wow", "ouch", "hey", "hi", "hello"]
    if word in interjections:
        return "interjection"
    
    # Check for commands
    if word == "stop" or word == "start" or word == "go" or word == "help":
        return "command"
    
    # Default to noun
    return "noun"

func _determine_pattern_type(words):
    # Analyze words to determine pattern type
    var word_count = words.size()
    
    # Check for repetition pattern
    var repetitions = 0
    for i in range(1, word_count):
        if words[i] == words[i-1]:
            repetitions += 1
    
    if repetitions >= word_count / 2:
        return "repetition"
    
    # Check for alternation pattern
    var alternations = 0
    for i in range(2, word_count):
        if words[i] == words[i-2]:
            alternations += 1
    
    if alternations >= (word_count - 2) / 2:
        return "alternation"
    
    # Check for progression pattern
    var progressions = 0
    var last_direction = null
    
    for word in words:
        if word in word_directions:
            var direction = word_directions[word]["direction"]
            if last_direction != null and direction != last_direction:
                progressions += 1
            last_direction = direction
    
    if progressions >= word_count / 2:
        return "progression"
    
    # Check for cluster pattern
    var categories = {}
    for word in words:
        if word in word_directions:
            var category = word_directions[word]["category"]
            if not category in categories:
                categories[category] = 0
            categories[category] += 1
    
    var dominant_category = null
    var dominant_count = 0
    
    for category in categories:
        if categories[category] > dominant_count:
            dominant_count = categories[category]
            dominant_category = category
    
    if dominant_count >= word_count * 0.7:
        return "cluster"
    
    # Default to mixed pattern
    return "mixed"

func _calculate_pattern_strength(words, pattern_type):
    # Calculate pattern strength based on type and words
    var base_strength = 1.0
    
    # Factor in word strengths
    for word in words:
        if word in word_directions:
            base_strength += word_directions[word]["count"] * 0.5
    
    # Factor in pattern type
    match pattern_type:
        "repetition":
            base_strength *= 1.5
        "alternation":
            base_strength *= 1.3
        "progression":
            base_strength *= 1.7
        "cluster":
            base_strength *= 1.2
        "mixed":
            base_strength *= 0.8
    
    # Factor in word count
    base_strength *= (1.0 + (words.size() - 3) * 0.1)
    
    return base_strength

func _calculate_pattern_vector(words):
    # Calculate directional vector for a pattern
    var result_vector = Vector3(0, 0, 0)
    var vectors_found = 0
    
    for word in words:
        if word in word_directions:
            result_vector += word_directions[word]["vector"]
            vectors_found += 1
    
    if vectors_found > 0:
        result_vector = result_vector / vectors_found
    else:
        result_vector = global_direction_vector
    
    return result_vector

func _generate_pattern_id(words, pattern_type):
    # Generate unique pattern ID
    var word_string = PoolStringArray(words).join("_")
    return "pattern_" + pattern_type + "_" + word_string.md5_text().substr(0, 8)

func _apply_pattern_decay(elapsed_time):
    # Apply decay to pattern strengths over time
    var decay_amount = elapsed_time * pattern_decay_rate
    
    for pattern_id in pattern_detections:
        pattern_detections[pattern_id]["strength"] *= (1.0 - decay_amount)

func _check_activation_thresholds():
    # Check if any thresholds have been reached
    for threshold_type in activation_levels:
        var threshold = ACTIVATION_THRESHOLDS[threshold_type]
        
        if activation_levels[threshold_type] >= threshold:
            # Threshold reached
            _trigger_activation(threshold_type)
            
            # Reset activation
            activation_levels[threshold_type] = 0.0

func _update_activation_levels(action_type):
    # Update activation levels based on action
    activation_levels["action"] += 0.5
    
    # Different actions affect different activation types
    match action_type:
        "create", "modify", "delete":
            activation_levels["word"] += 0.3
        "read", "execute":
            activation_levels["direction"] += 0.3
        "connect", "disconnect":
            activation_levels["pattern"] += 0.3
        "analyze", "synthesize":
            activation_levels["composite"] += 0.4
        "transform", "shift":
            activation_levels["direction"] += 0.5
            activation_levels["pattern"] += 0.2

func _trigger_activation(activation_type):
    # React to activation threshold being reached
    print("ACTIVATION: " + activation_type + " threshold reached")
    
    match activation_type:
        "word":
            # Generate a new word direction recommendation
            var recommended = get_recommended_direction()
            print("Word activation suggests direction: " + recommended)
        "direction":
            # Potential direction shift
            var intensity = direction_strengths[current_direction]
            emit_signal("critical_mass_reached", current_direction, intensity)
        "action":
            # Recommend an action
            print("Action activation suggests analyzing recent patterns")
        "pattern":
            # Find emergent patterns
            _find_emergent_patterns()
        "composite":
            # Update infrastructure map
            map_infrastructure()

func _find_emergent_patterns():
    # Look for emergent patterns in recently analyzed words
    var recent_words = []
    var current_time = OS.get_unix_time()
    
    # Collect recent words (last 60 seconds)
    for word in word_directions:
        if current_time - word_directions[word]["last_seen"] < 60:
            recent_words.append(word)
    
    # Need at least 3 words for a pattern
    if recent_words.size() < 3:
        return
    
    # Try different combinations
    var detected = false
    
    for i in range(recent_words.size()):
        for j in range(i+1, recent_words.size()):
            for k in range(j+1, recent_words.size()):
                var combo = [recent_words[i], recent_words[j], recent_words[k]]
                var result = detect_pattern(combo)
                if result:
                    detected = true
    
    return detected

func _update_infrastructure_with_pattern(pattern_id, words, pattern_type):
    # Update infrastructure map with new pattern
    if not "patterns" in infrastructure_map:
        infrastructure_map["patterns"] = {}
    
    infrastructure_map["patterns"][pattern_id] = {
        "words": words,
        "type": pattern_type,
        "connections": []
    }
    
    # Connect pattern to words
    for word in words:
        if word in infrastructure_map["nodes"]:
            _add_infrastructure_connection(pattern_id, word, "contains")

func _add_infrastructure_connection(source, target, connection_type):
    # Add connection to infrastructure map
    var connection_id = source + "_to_" + target
    
    infrastructure_map["connections"][connection_id] = {
        "source": source,
        "target": target,
        "type": connection_type
    }
    
    # Add to node connection lists
    if source in infrastructure_map["nodes"]:
        infrastructure_map["nodes"][source]["connections"].append(connection_id)
    
    if target in infrastructure_map["nodes"]:
        infrastructure_map["nodes"][target]["connections"].append(connection_id)

func _build_word_clusters():
    # Build clusters of related words
    var clusters = {}
    var unclustered_words = []
    
    # Start with all words unclustered
    for word in word_directions:
        unclustered_words.append(word)
    
    # Create clusters based on associations
    while unclustered_words.size() > 0:
        var seed_word = unclustered_words.pop_front()
        var cluster = [seed_word]
        var to_process = [seed_word]
        
        # Process all connected words
        while to_process.size() > 0:
            var current = to_process.pop_front()
            
            if current in word_directions:
                for associated in word_directions[current]["associations"]:
                    if associated in unclustered_words:
                        unclustered_words.erase(associated)
                        cluster.append(associated)
                        to_process.append(associated)
        
        # Create cluster if it has at least 2 words
        if cluster.size() >= 2:
            var cluster_id = "cluster_" + str(clusters.size())
            clusters[cluster_id] = {
                "words": cluster,
                "size": cluster.size(),
                "direction": _determine_cluster_direction(cluster)
            }
    
    # Store clusters
    word_clusters = clusters
    infrastructure_map["clusters"] = clusters
    
    return clusters.size()

func _determine_cluster_direction(words):
    # Determine dominant direction for a cluster
    var direction_counts = {}
    
    for direction in DIRECTION_VECTORS:
        direction_counts[direction] = 0
    
    for word in words:
        if word in word_directions:
            var direction = word_directions[word]["direction"]
            direction_counts[direction] += 1
    
    # Find dominant direction
    var max_count = 0
    var dominant_direction = current_direction
    
    for direction in direction_counts:
        if direction_counts[direction] > max_count:
            max_count = direction_counts[direction]
            dominant_direction = direction
    
    return dominant_direction

func _generate_flow_paths(depth):
    # Generate potential program flow paths
    var paths = []
    
    # Start from each word with no incoming connections
    var starting_words = []
    
    for word in word_directions:
        if word in infrastructure_map["nodes"]:
            var has_incoming = false
            
            for connection_id in infrastructure_map["nodes"][word]["connections"]:
                var connection = infrastructure_map["connections"][connection_id]
                if connection["target"] == word:
                    has_incoming = true
                    break
            
            if not has_incoming:
                starting_words.append(word)
    
    # Generate paths from each starting word
    for start in starting_words:
        var path = _generate_path_from_word(start, depth)
        if path.size() > 1:
            paths.append({
                "start": start,
                "path": path,
                "length": path.size(),
                "direction": word_directions[start]["direction"]
            })
    
    # Store paths
    program_flow_paths = paths
    infrastructure_map["flows"] = paths
    
    return paths.size()

func _generate_path_from_word(word, max_depth, current_path = []):
    # Recursively generate path from word
    if max_depth <= 0:
        return current_path
    
    if not word in infrastructure_map["nodes"]:
        return current_path
    
    # Add word to path
    var path = current_path.duplicate()
    path.append(word)
    
    # Find outgoing connections
    var outgoing = []
    
    for connection_id in infrastructure_map["nodes"][word]["connections"]:
        var connection = infrastructure_map["connections"][connection_id]
        if connection["source"] == word:
            outgoing.append(connection["target"])
    
    # If no outgoing connections, return current path
    if outgoing.size() == 0:
        return path
    
    # Pick next word based on direction
    var next_word = null
    var word_direction = word_directions[word]["direction"] if word in word_directions else current_direction
    
    for target in outgoing:
        if target in word_directions and word_directions[target]["direction"] == word_direction:
            next_word = target
            break
    
    # If no word with same direction, pick first
    if next_word == null and outgoing.size() > 0:
        next_word = outgoing[0]
    
    # Continue path
    if next_word != null and not next_word in path:
        return _generate_path_from_word(next_word, max_depth - 1, path)
    
    return path

func _update_visualization(delta):
    # Update visualization trails
    if active_trail.size() > 0:
        var last_point = active_trail[active_trail.size() - 1]
        var new_point = last_point + (global_direction_vector * delta * 5.0)
        active_trail.append(new_point)
        
        # Limit trail length
        if active_trail.size() > 100:
            active_trail.pop_front()

func _add_visualization_point(word, direction):
    # Add point to visualization
    var point = {
        "word": word,
        "direction": direction,
        "position": Vector3(
            randf() * 10.0 - 5.0,
            randf() * 10.0 - 5.0,
            randf() * 10.0 - 5.0
        ),
        "color": visualization_color,
        "size": 1.0
    }
    
    visualization_points.append(point)

func _start_new_trail():
    # Start a new direction trail
    if active_trail.size() > 0:
        direction_trails.append(active_trail)
        
        # Limit number of trails
        if direction_trails.size() > 10:
            direction_trails.pop_front()
    
    # Create new trail
    active_trail = [Vector3(0, 0, 0)]

func _determine_word_rarity(word):
    # Determine rarity of a word
    var length = word.length()
    var unique_chars = {}
    
    for c in word:
        unique_chars[c] = true
    
    var unique_count = unique_chars.size()
    
    if length >= 10 or unique_count >= 8:
        return "unique"
    elif length >= 7 or unique_count >= 6:
        return "rare"
    elif length >= 5 or unique_count >= 4:
        return "uncommon"
    else:
        return "common"

func _calculate_word_value(word, category, rarity):
    # Calculate investment value of a word
    var base_value = 10.0
    
    # Adjust based on rarity
    var rarity_multiplier = WORD_VALUE_MULTIPLIERS[rarity]
    base_value *= rarity_multiplier
    
    # Adjust based on category
    if category == "verb":
        base_value *= 1.2
    elif category == "adjective":
        base_value *= 1.1
    elif category == "symbol":
        base_value *= 1.5
    
    # Adjust based on word length
    base_value *= (1.0 + word.length() * 0.05)
    
    return base_value

func _sort_by_word_count(a, b):
    return a["count"] > b["count"]

func _sort_by_direction_value(a, b):
    return a["value"] > b["value"]