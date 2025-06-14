extends Node

class_name WordSystem

# Word System for Eden_OS
# Manages the World of Words game with 5D chess concepts

signal word_added(word, meaning)
signal word_connected(word1, word2, connection_type)
signal word_moved(word, position)
signal word_transformed(word, transformation)
signal word_system_ready

# Word database
var word_database = {}
var word_connections = {}
var word_positions = {}
var word_dimensions = {}

# Dimensional settings
var available_dimensions = ["alpha", "beta", "gamma", "delta", "epsilon"]
var current_dimension = "alpha"

# Chess-related properties
var chess_board_size = 8
var chess_dimensions = 5
var chess_positions = {}
var chess_move_history = []

# Word properties
var word_properties = {
    "noun": {"moveset": "orthogonal", "power": 2, "color": Color(0.2, 0.6, 0.8)},
    "verb": {"moveset": "diagonal", "power": 3, "color": Color(0.8, 0.2, 0.2)},
    "adjective": {"moveset": "knight", "power": 2, "color": Color(0.2, 0.8, 0.2)},
    "adverb": {"moveset": "queen", "power": 4, "color": Color(0.8, 0.8, 0.2)},
    "pronoun": {"moveset": "king", "power": 1, "color": Color(0.8, 0.2, 0.8)},
    "conjunction": {"moveset": "bishop", "power": 2, "color": Color(0.2, 0.8, 0.8)},
    "preposition": {"moveset": "rook", "power": 3, "color": Color(0.6, 0.4, 0.8)},
    "interjection": {"moveset": "teleport", "power": 1, "color": Color(0.8, 0.6, 0.2)}
}

# Word transformation rules
var transformation_rules = {
    "noun_to_verb": {"source": "noun", "target": "verb", "condition": "adjacent_to_verb"},
    "verb_to_noun": {"source": "verb", "target": "noun", "condition": "in_past_tense"},
    "adjective_to_adverb": {"source": "adjective", "target": "adverb", "condition": "add_ly_suffix"},
    "singular_to_plural": {"source": "noun", "target": "noun", "condition": "add_s_suffix", "property_change": "count"},
    "dimensionalization": {"condition": "cross_dimension", "property_gain": "dimensional"}
}

func _ready():
    initialize_word_system()
    print("Word System initialized")
    emit_signal("word_system_ready")

func initialize_word_system():
    # Initialize dimensions
    for dimension in available_dimensions:
        word_dimensions[dimension] = {
            "words": [],
            "connections": [],
            "properties": {
                "stability": randf(),
                "density": randf(),
                "connectivity": randf()
            }
        }
    
    # Initialize chess positions
    for x in range(chess_board_size):
        for y in range(chess_board_size):
            for z in range(chess_dimensions):
                for w in range(chess_dimensions):
                    for t in range(chess_dimensions):
                        var position = Vector3i(x, y, z)
                        var hyper_position = {"w": w, "t": t}
                        chess_positions[str(position) + ":" + str(hyper_position)] = null
    
    # Add some initial words
    var initial_words = [
        {"word": "eden", "meaning": "A paradise or place of pristine beauty", "type": "noun"},
        {"word": "create", "meaning": "To bring something into existence", "type": "verb"},
        {"word": "dimension", "meaning": "A measurable extent of a particular kind", "type": "noun"},
        {"word": "turn", "meaning": "A change of direction or position", "type": "verb"},
        {"word": "word", "meaning": "A single unit of language", "type": "noun"},
        {"word": "game", "meaning": "A structured playing activity", "type": "noun"},
        {"word": "chess", "meaning": "A strategy board game", "type": "noun"},
        {"word": "divine", "meaning": "Of, from, or like God or a god", "type": "adjective"},
        {"word": "luminous", "meaning": "Bright, shining, or glowing", "type": "adjective"},
        {"word": "temple", "meaning": "A building devoted to worship", "type": "noun"}
    ]
    
    for word_info in initial_words:
        add_word(word_info.word, word_info.meaning, word_info.type)
    
    # Create some initial connections
    connect_words("eden", "paradise")
    connect_words("create", "game")
    connect_words("word", "game")
    connect_words("chess", "game")
    connect_words("dimension", "chess")
    connect_words("turn", "game")
    connect_words("divine", "temple")
    connect_words("luminous", "divine")

func add_word(word, meaning, word_type="noun", properties={}):
    # Check if word already exists
    if word_database.has(word):
        return "Word '" + word + "' already exists in the database"
    
    # Create word entry
    word_database[word] = {
        "meaning": meaning,
        "type": word_type,
        "connections": [],
        "properties": properties,
        "dimensions": [current_dimension],
        "creation_time": Time.get_unix_time_from_system(),
        "used_count": 0,
        "power": word_properties[word_type]["power"] if word_properties.has(word_type) else 1,
        "color": word_properties[word_type]["color"] if word_properties.has(word_type) else Color(0.5, 0.5, 0.5)
    }
    
    # Add to current dimension
    if word_dimensions.has(current_dimension):
        word_dimensions[current_dimension]["words"].append(word)
    
    # Place on chess board if not already placed
    if not word_positions.has(word):
        place_word_on_board(word)
    
    # Emit signal
    emit_signal("word_added", word, meaning)
    
    return "Word '" + word + "' added to the database"

func connect_words(word1, word2, connection_type="semantic"):
    # Check if words exist
    if not word_database.has(word1):
        return "Word '" + word1 + "' not found in database"
    
    if not word_database.has(word2):
        return "Word '" + word2 + "' not found in database"
    
    # Check if connection already exists
    if word2 in word_database[word1]["connections"]:
        return "Words '" + word1 + "' and '" + word2 + "' are already connected"
    
    # Create connection
    word_database[word1]["connections"].append(word2)
    word_database[word2]["connections"].append(word1)
    
    # Store connection details
    var connection_id = word1 + "_" + word2
    word_connections[connection_id] = {
        "type": connection_type,
        "strength": 1.0,
        "created_time": Time.get_unix_time_from_system(),
        "dimensions": [current_dimension]
    }
    
    # Add to current dimension
    if word_dimensions.has(current_dimension):
        word_dimensions[current_dimension]["connections"].append(connection_id)
    
    # Emit signal
    emit_signal("word_connected", word1, word2, connection_type)
    
    return "Connected '" + word1 + "' to '" + word2 + "'"

func place_word_on_board(word):
    # Find an empty position
    var positioned = false
    
    # Try to place in current dimension
    for x in range(chess_board_size):
        for y in range(chess_board_size):
            if positioned:
                break
                
            var position = Vector3i(x, y, 0)
            var hyper_position = {"w": 0, "t": 0}
            var pos_key = str(position) + ":" + str(hyper_position)
            
            if chess_positions[pos_key] == null:
                chess_positions[pos_key] = word
                
                # Store word position
                word_positions[word] = {
                    "position": position,
                    "hyper_position": hyper_position,
                    "dimension": current_dimension
                }
                
                positioned = true
                break
    
    if positioned:
        return "Word '" + word + "' placed on the board"
    else:
        return "Could not place word '" + word + "' - board is full"

func move_word(word, new_position, new_hyper_position=null):
    # Check if word exists
    if not word_database.has(word):
        return "Word '" + word + "' not found in database"
    
    # Check if word is on the board
    if not word_positions.has(word):
        return "Word '" + word + "' is not on the board"
    
    # If hyper_position not provided, keep the same
    if new_hyper_position == null:
        new_hyper_position = word_positions[word]["hyper_position"]
    
    # Calculate position key
    var pos_key = str(new_position) + ":" + str(new_hyper_position)
    
    # Check if position is valid and empty
    if not chess_positions.has(pos_key):
        return "Invalid position"
    
    if chess_positions[pos_key] != null and chess_positions[pos_key] != word:
        return "Position already occupied by '" + chess_positions[pos_key] + "'"
    
    # Remove from old position
    var old_position = word_positions[word]["position"]
    var old_hyper_position = word_positions[word]["hyper_position"]
    var old_pos_key = str(old_position) + ":" + str(old_hyper_position)
    
    chess_positions[old_pos_key] = null
    
    # Place at new position
    chess_positions[pos_key] = word
    
    # Update word position
    word_positions[word] = {
        "position": new_position,
        "hyper_position": new_hyper_position,
        "dimension": current_dimension
    }
    
    # Record move in history
    chess_move_history.append({
        "word": word,
        "from": {"position": old_position, "hyper_position": old_hyper_position},
        "to": {"position": new_position, "hyper_position": new_hyper_position},
        "time": Time.get_unix_time_from_system()
    })
    
    # Check for transformations
    check_word_transformations(word)
    
    # Emit signal
    emit_signal("word_moved", word, new_position)
    
    return "Moved '" + word + "' to new position"

func check_word_transformations(word):
    # Check if any transformations apply to this word
    if not word_database.has(word):
        return
    
    var word_data = word_database[word]
    var transformed = false
    
    # Check each transformation rule
    for rule_name in transformation_rules:
        var rule = transformation_rules[rule_name]
        
        # Check if rule applies to this word type
        if rule.has("source") and rule["source"] != word_data["type"]:
            continue
        
        # Check specific conditions
        if rule.has("condition"):
            var condition_met = false
            
            match rule["condition"]:
                "adjacent_to_verb":
                    condition_met = is_adjacent_to_word_type(word, "verb")
                "in_past_tense":
                    condition_met = word.ends_with("ed")
                "add_ly_suffix":
                    condition_met = word.ends_with("ly")
                "add_s_suffix":
                    condition_met = word.ends_with("s")
                "cross_dimension":
                    condition_met = word_data["dimensions"].size() > 1
            
            if not condition_met:
                continue
        
        # Apply transformation
        transformed = true
        
        # Type transformation
        if rule.has("target"):
            word_data["type"] = rule["target"]
            
            # Update power based on new type
            if word_properties.has(rule["target"]):
                word_data["power"] = word_properties[rule["target"]]["power"]
                word_data["color"] = word_properties[rule["target"]]["color"]
        
        # Property changes
        if rule.has("property_change"):
            word_data["properties"][rule["property_change"]] = true
        
        if rule.has("property_gain"):
            word_data["properties"][rule["property_gain"]] = true
        
        # Emit signal
        emit_signal("word_transformed", word, rule_name)
    
    return transformed

func is_adjacent_to_word_type(word, type):
    # Check if word is adjacent to a word of the given type
    if not word_positions.has(word):
        return false
    
    var pos = word_positions[word]["position"]
    var hyper_pos = word_positions[word]["hyper_position"]
    
    # Check all adjacent positions
    for dx in range(-1, 2):
        for dy in range(-1, 2):
            if dx == 0 and dy == 0:
                continue
                
            var adj_pos = Vector3i(pos.x + dx, pos.y + dy, pos.z)
            var adj_pos_key = str(adj_pos) + ":" + str(hyper_pos)
            
            if chess_positions.has(adj_pos_key) and chess_positions[adj_pos_key] != null:
                var adj_word = chess_positions[adj_pos_key]
                
                if word_database.has(adj_word) and word_database[adj_word]["type"] == type:
                    return true
    
    return false

func change_dimension(dimension):
    # Change current dimension
    if not word_dimensions.has(dimension):
        return "Dimension '" + dimension + "' does not exist"
    
    current_dimension = dimension
    
    return "Changed to dimension '" + dimension + "'"

func get_word_info(word):
    # Get information about a word
    if not word_database.has(word):
        return "Word '" + word + "' not found in database"
    
    var info = "Word: " + word + "\n"
    info += "Meaning: " + word_database[word]["meaning"] + "\n"
    info += "Type: " + word_database[word]["type"] + "\n"
    info += "Power: " + str(word_database[word]["power"]) + "\n"
    info += "Connections: " + str(word_database[word]["connections"].size()) + "\n"
    
    if word_database[word]["connections"].size() > 0:
        info += "Connected to: " + ", ".join(word_database[word]["connections"]) + "\n"
    
    if word_positions.has(word):
        var pos = word_positions[word]["position"]
        var hyper_pos = word_positions[word]["hyper_position"]
        
        info += "Position: (" + str(pos.x) + "," + str(pos.y) + "," + str(pos.z) + ")"
        info += " Hyper: (w:" + str(hyper_pos["w"]) + ", t:" + str(hyper_pos["t"]) + ")\n"
    
    info += "Dimensions: " + ", ".join(word_database[word]["dimensions"]) + "\n"
    
    return info

func search_words(query):
    # Search for words matching the query
    var results = []
    
    for word in word_database:
        if word.contains(query):
            results.append(word)
        elif word_database[word]["meaning"].contains(query):
            results.append(word)
    
    return results

func get_words_by_type(word_type):
    # Get all words of a specific type
    var results = []
    
    for word in word_database:
        if word_database[word]["type"] == word_type:
            results.append(word)
    
    return results

func get_dimension_words(dimension):
    # Get all words in a specific dimension
    if not word_dimensions.has(dimension):
        return []
    
    return word_dimensions[dimension]["words"]

func process_command(args):
    if args.size() == 0:
        return "Word System. Use 'word add', 'word connect', 'word info', 'word search', 'word move'"
    
    match args[0]:
        "add":
            if args.size() < 3:
                return "Usage: word add <word> <meaning> [type]"
            
            var word_type = "noun"
            if args.size() >= 4:
                word_type = args[3]
                
            return add_word(args[1], args[2], word_type)
        "connect":
            if args.size() < 3:
                return "Usage: word connect <word1> <word2> [type]"
            
            var connection_type = "semantic"
            if args.size() >= 4:
                connection_type = args[3]
                
            return connect_words(args[1], args[2], connection_type)
        "info":
            if args.size() < 2:
                return "Usage: word info <word>"
                
            return get_word_info(args[1])
        "search":
            if args.size() < 2:
                return "Usage: word search <query>"
                
            var results = search_words(args[1])
            
            if results.size() == 0:
                return "No words found matching '" + args[1] + "'"
                
            var response = "Found " + str(results.size()) + " words matching '" + args[1] + "':\n"
            response += ", ".join(results)
            
            return response
        "move":
            if args.size() < 4:
                return "Usage: word move <word> <x> <y> [z] [w] [t]"
                
            var word = args[1]
            var x = int(args[2])
            var y = int(args[3])
            
            var z = 0
            if args.size() >= 5:
                z = int(args[4])
                
            var w = 0
            if args.size() >= 6:
                w = int(args[5])
                
            var t = 0
            if args.size() >= 7:
                t = int(args[6])
                
            var position = Vector3i(x, y, z)
            var hyper_position = {"w": w, "t": t}
            
            return move_word(word, position, hyper_position)
        "type":
            if args.size() < 2:
                return "Usage: word type <word_type>"
                
            var results = get_words_by_type(args[1])
            
            if results.size() == 0:
                return "No words found of type '" + args[1] + "'"
                
            var response = "Found " + str(results.size()) + " words of type '" + args[1] + "':\n"
            response += ", ".join(results)
            
            return response
        "dimension":
            if args.size() < 2:
                return "Current dimension: " + current_dimension
                
            if args[1] == "list":
                var response = "Available dimensions:\n"
                
                for dimension in word_dimensions:
                    var word_count = word_dimensions[dimension]["words"].size()
                    response += dimension + " (" + str(word_count) + " words)\n"
                    
                return response
            else:
                return change_dimension(args[1])
        "list":
            var max_words = 20
            var total = word_database.size()
            
            var response = "Words in database (" + str(total) + " total, showing first " + str(min(max_words, total)) + "):\n"
            
            var count = 0
            for word in word_database:
                response += word + " (" + word_database[word]["type"] + ")\n"
                count += 1
                
                if count >= max_words:
                    break
                    
            return response
        "connections":
            if args.size() < 2:
                return "Usage: word connections <word>"
                
            var word = args[1]
            
            if not word_database.has(word):
                return "Word '" + word + "' not found in database"
                
            var connections = word_database[word]["connections"]
            
            if connections.size() == 0:
                return "Word '" + word + "' has no connections"
                
            var response = "Connections for '" + word + "' (" + str(connections.size()) + "):\n"
            
            for connected_word in connections:
                var connection_id = word + "_" + connected_word
                if not word_connections.has(connection_id):
                    connection_id = connected_word + "_" + word
                    
                var type = "semantic"
                if word_connections.has(connection_id):
                    type = word_connections[connection_id]["type"]
                    
                response += "- " + connected_word + " (" + type + ")\n"
                
            return response
        "chess":
            return "5D Chess Word System active - use 'word move' to position words"
        _:
            return "Unknown word command: " + args[0]