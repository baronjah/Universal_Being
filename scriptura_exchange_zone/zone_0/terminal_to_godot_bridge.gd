extends Node

class_name TerminalToGodotBridge

# ----- BRIDGE CONFIGURATION -----
const TERMINAL_COUNT = 6
const TURN_COUNT = 12
const DATA_SEWER_PATH = "user://data_sewers"
const WORD_DB_PATH = "user://word_database.json"
const TERMINAL_DATA_PATH = "user://terminal_data"

# ----- CONNECTION SETTINGS -----
var terminal_poll_interval = 0.5 # seconds
var sewer_clean_interval = 60.0 # seconds
var terminal_file_extension = ".terminal"
var bridge_active = false

# ----- COMMUNICATION STATE -----
var last_poll_time = 0
var last_clean_time = 0
var terminal_last_modified = {}
var word_database = {}
var pending_manifests = []
var pending_dice_results = []
var active_terminal_windows = []
var active_turns = {}
var current_turn = 3 # Default to 3D space

# ----- SIGNALS -----
signal word_received(word_data)
signal dice_result_received(dice_data)
signal terminal_message_received(terminal_id, message)
signal turn_advanced(new_turn)
signal database_updated(word_count)
signal sewer_cleaned(file_count)

# ----- INITIALIZATION -----
func _ready():
    print("Terminal to Godot Bridge initializing...")
    
    # Create required directories
    _create_directories()
    
    # Initialize terminal data
    _init_terminal_data()
    
    # Load word database
    _load_word_database()
    
    # Read current turn
    _read_current_turn()
    
    print("Terminal to Godot Bridge initialized")
    
    # Start bridge
    bridge_active = true

# Create necessary directories
func _create_directories():
    var dir = Directory.new()
    
    # Create data sewer directory
    if not dir.dir_exists(DATA_SEWER_PATH):
        dir.make_dir_recursive(DATA_SEWER_PATH)
    
    # Create terminal data directory
    if not dir.dir_exists(TERMINAL_DATA_PATH):
        dir.make_dir_recursive(TERMINAL_DATA_PATH)
        
    print("Directories created: data sewers and terminal data")

# Initialize terminal data files
func _init_terminal_data():
    var file = File.new()
    
    # Create terminal data files if they don't exist
    for i in range(TERMINAL_COUNT):
        var terminal_file = TERMINAL_DATA_PATH + "/terminal_" + str(i) + terminal_file_extension
        
        if not file.file_exists(terminal_file):
            file.open(terminal_file, File.WRITE)
            var init_data = {
                "terminal_id": i,
                "last_update": OS.get_unix_time(),
                "messages": ["Terminal " + str(i) + " initialized"],
                "manifested_words": [],
                "dice_results": []
            }
            file.store_string(JSON.print(init_data))
            file.close()
        
        # Store last modified time
        terminal_last_modified[i] = OS.get_unix_time()
    
    print("Terminal data files initialized")

# Load word database
func _load_word_database():
    var file = File.new()
    
    if file.file_exists(WORD_DB_PATH):
        file.open(WORD_DB_PATH, File.READ)
        var json_text = file.get_as_text()
        file.close()
        
        var parse_result = JSON.parse(json_text)
        if parse_result.error == OK:
            word_database = parse_result.result
            print("Word database loaded with " + str(word_database.size()) + " entries")
        else:
            print("Error parsing word database JSON: " + str(parse_result.error_string))
            # Initialize with default words
            _init_default_word_database()
    else:
        print("Word database not found, creating default")
        _init_default_word_database()

# Initialize default word database
func _init_default_word_database():
    # Basic word power values
    word_database = {
        "god": 100,
        "divine": 75,
        "eternal": 50,
        "infinite": 50, 
        "creation": 40,
        "reality": 35,
        "universe": 30,
        "perfect": 25,
        "absolute": 20,
        "supreme": 15,
        "transcendent": 18,
        "omniscient": 45,
        "omnipotent": 48,
        "celestial": 28,
        "sovereign": 22,
        "immortal": 33,
        "timeless": 30,
        "limitless": 29,
        "almighty": 43,
        "sacred": 19,
        "miracle": 80,
        "transform": 38,
        "manifestation": 45,
        "quantum": 40,
        "dimension": 35,
        "consciousness": 55,
        "ascension": 65,
        "enlighten": 60,
        "harmony": 42,
        "unity": 47,
        "synchronize": 39,
        "ethereal": 37,
        "cosmic": 44,
        "seraphic": 52,
        "celestial": 48,
        "illuminate": 36,
        "transcend": 58,
        "multidimensional": 53,
        "genesis": 70,
        "creation": 65
    }
    
    _save_word_database()
    print("Default word database created with " + str(word_database.size()) + " entries")

# Save word database
func _save_word_database():
    var file = File.new()
    file.open(WORD_DB_PATH, File.WRITE)
    file.store_string(JSON.print(word_database, "  "))
    file.close()

# Read current turn
func _read_current_turn():
    var file = File.new()
    var current_turn_path = "user://current_turn.txt"
    
    if file.file_exists(current_turn_path):
        file.open(current_turn_path, File.READ)
        var turn_str = file.get_line()
        file.close()
        
        if turn_str.is_valid_integer():
            current_turn = int(turn_str)
            if current_turn < 1 or current_turn > TURN_COUNT:
                current_turn = 3  # Default to 3D
    else:
        # Create file with default turn
        file.open(current_turn_path, File.WRITE)
        file.store_line(str(current_turn))
        file.close()
    
    print("Current turn set to: " + str(current_turn))

# ----- PROCESSING -----
func _process(delta):
    if not bridge_active:
        return
    
    # Poll terminal files at interval
    last_poll_time += delta
    if last_poll_time >= terminal_poll_interval:
        last_poll_time = 0
        _poll_terminal_files()
    
    # Clean data sewers at interval
    last_clean_time += delta
    if last_clean_time >= sewer_clean_interval:
        last_clean_time = 0
        _clean_data_sewers()
    
    # Process pending manifests
    _process_pending_manifests()
    
    # Process pending dice results
    _process_pending_dice_results()

# Poll terminal files for changes
func _poll_terminal_files():
    var file = File.new()
    
    for i in range(TERMINAL_COUNT):
        var terminal_file = TERMINAL_DATA_PATH + "/terminal_" + str(i) + terminal_file_extension
        
        if file.file_exists(terminal_file):
            # Check if file has been modified
            var modified_time = OS.get_unix_time()
            
            if modified_time > terminal_last_modified[i]:
                terminal_last_modified[i] = modified_time
                
                # Read and process terminal data
                file.open(terminal_file, File.READ)
                var json_text = file.get_as_text()
                file.close()
                
                var parse_result = JSON.parse(json_text)
                if parse_result.error == OK:
                    _process_terminal_data(parse_result.result)
                else:
                    print("Error parsing terminal JSON: " + str(parse_result.error_string))

# Process terminal data
func _process_terminal_data(data):
    var terminal_id = data.terminal_id
    
    # Process new messages
    if data.has("messages") and data.messages.size() > 0:
        for message in data.messages:
            emit_signal("terminal_message_received", terminal_id, message)
            
            # Check for turn advance messages
            if message.begins_with("TURN ADVANCED TO"):
                var turn_str = message.substr(16, 2).strip_edges()
                if turn_str.is_valid_integer():
                    var new_turn = int(turn_str)
                    if new_turn >= 1 and new_turn <= TURN_COUNT:
                        current_turn = new_turn
                        emit_signal("turn_advanced", current_turn)
    
    # Process manifested words
    if data.has("manifested_words") and data.manifested_words.size() > 0:
        for word_data in data.manifested_words:
            # Check if word is new (not yet processed)
            var is_new = true
            
            for pending in pending_manifests:
                if pending.id == word_data.id:
                    is_new = false
                    break
            
            if is_new:
                pending_manifests.append(word_data)
                
                # Update word database if needed
                if not word_database.has(word_data.text.to_lower()):
                    word_database[word_data.text.to_lower()] = word_data.power
                    _save_word_database()
                    emit_signal("database_updated", word_database.size())
    
    # Process dice results
    if data.has("dice_results") and data.dice_results.size() > 0:
        for dice_data in data.dice_results:
            # Check if dice result is new
            var is_new = true
            
            for pending in pending_dice_results:
                if pending.timestamp == dice_data.timestamp:
                    is_new = false
                    break
            
            if is_new:
                pending_dice_results.append(dice_data)

# Process pending manifested words
func _process_pending_manifests():
    if pending_manifests.size() > 0:
        var word_data = pending_manifests[0]
        emit_signal("word_received", word_data)
        pending_manifests.pop_front()

# Process pending dice results
func _process_pending_dice_results():
    if pending_dice_results.size() > 0:
        var dice_data = pending_dice_results[0]
        emit_signal("dice_result_received", dice_data)
        pending_dice_results.pop_front()

# Clean data sewers
func _clean_data_sewers():
    var dir = Directory.new()
    var file_count = 0
    
    if dir.open(DATA_SEWER_PATH) == OK:
        dir.list_dir_begin(true, true)
        var file_name = dir.get_next()
        
        while file_name != "":
            if not dir.current_is_dir():
                # Get file age in seconds
                var file_path = DATA_SEWER_PATH + "/" + file_name
                var modified_time = OS.get_unix_time()
                
                # Delete files older than 1 hour
                if modified_time - OS.get_unix_time() > 3600:
                    dir.remove(file_path)
                    file_count += 1
            
            file_name = dir.get_next()
        
        dir.list_dir_end()
    
    if file_count > 0:
        print("Cleaned " + str(file_count) + " old files from data sewers")
        emit_signal("sewer_cleaned", file_count)

# ----- PUBLIC API -----
# Add a word to the database
func add_word_to_database(word, power):
    word = word.to_lower()
    
    if not word_database.has(word):
        word_database[word] = power
        _save_word_database()
        emit_signal("database_updated", word_database.size())
        print("Added word to database: " + word + " (Power: " + str(power) + ")")
        return true
    
    return false

# Send message to terminal
func send_message_to_terminal(terminal_id, message):
    if terminal_id < 0 or terminal_id >= TERMINAL_COUNT:
        return false
    
    var file = File.new()
    var terminal_file = TERMINAL_DATA_PATH + "/terminal_" + str(terminal_id) + terminal_file_extension
    
    if file.file_exists(terminal_file):
        # Read current data
        file.open(terminal_file, File.READ)
        var json_text = file.get_as_text()
        file.close()
        
        var parse_result = JSON.parse(json_text)
        if parse_result.error == OK:
            var data = parse_result.result
            
            # Add message
            if not data.has("messages"):
                data.messages = []
            
            data.messages.append(message)
            
            # Save updated data
            file.open(terminal_file, File.WRITE)
            file.store_string(JSON.print(data))
            file.close()
            
            return true
        else:
            print("Error parsing terminal JSON: " + str(parse_result.error_string))
    
    return false

# Update current turn
func update_current_turn(new_turn):
    if new_turn < 1 or new_turn > TURN_COUNT:
        return false
    
    current_turn = new_turn
    
    # Save to file
    var file = File.new()
    var current_turn_path = "user://current_turn.txt"
    
    file.open(current_turn_path, File.WRITE)
    file.store_line(str(current_turn))
    file.close()
    
    emit_signal("turn_advanced", current_turn)
    print("Current turn updated to: " + str(current_turn))
    
    return true

# Get word power from database
func get_word_power(word):
    word = word.to_lower()
    
    if word_database.has(word):
        return word_database[word]
    
    return 1 # Default minimal power

# Get entire word database
func get_word_database():
    return word_database

# Move data to sewers
func move_to_sewers(data, name=""):
    var timestamp = OS.get_unix_time()
    var file_name = "sewer_" + str(timestamp)
    
    if name:
        file_name += "_" + name
    
    file_name += ".json"
    
    var file = File.new()
    file.open(DATA_SEWER_PATH + "/" + file_name, File.WRITE)
    file.store_string(JSON.print(data))
    file.close()
    
    print("Data moved to sewers: " + file_name)
    return file_name

# Start bridge if it was stopped
func start_bridge():
    bridge_active = true
    print("Terminal to Godot Bridge started")

# Stop bridge
func stop_bridge():
    bridge_active = false
    print("Terminal to Godot Bridge stopped")