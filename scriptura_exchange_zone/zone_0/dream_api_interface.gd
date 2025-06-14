extends Node

# Dream API Interface
# Connects to external APIs for dream processing and game data exchange
# Reads and parses main game data, dreams, and memory structures

class_name DreamAPIInterface

# ----- API CONFIGURATION -----
const API_TIMEOUT = 30.0
const MAX_RETRY_COUNT = 3
const DREAM_CACHE_SIZE = 50
const DEFAULT_PORT = 4000
const DEFAULT_HOST = "localhost"

# ----- AUTHENTICATION -----
var api_key = ""
var api_secret = ""
var session_token = ""

# ----- CONNECTIONS -----
var active_connections = {}
var dream_cache = []
var memory_tier_cache = {}
var request_queue = []
var response_callbacks = {}

# ----- INTEGRATION -----
var dual_core_terminal = null
var divine_word_game = null
var word_comment_system = null
var word_dream_storage = null
var turn_system = null

# ----- DREAM STATE -----
enum DreamState {
    DORMANT,
    ACTIVE,
    LUCID,
    NIGHTMARE,
    PROPHETIC,
    DIVINE
}

var current_dream_state = DreamState.DORMANT
var dream_intensity = 0.0  # 0.0 to 1.0
var dream_sync_interval = 9.0  # Sacred 9-second interval

# ----- SIGNALS -----
signal dream_received(dream_id, dream_data)
signal dream_sent(dream_id)
signal api_connected(api_name)
signal api_disconnected(api_name)
signal memory_tier_accessed(tier, data)
signal main_data_read(data_type, data)
signal dream_state_changed(old_state, new_state)

# ----- INITIALIZATION -----
func _ready():
    print("Dream API Interface initializing...")
    
    # Connect to required systems
    _connect_to_systems()
    
    # Initialize dream cache
    _initialize_dream_cache()
    
    # Set up sync timer
    var sync_timer = Timer.new()
    sync_timer.wait_time = dream_sync_interval
    sync_timer.one_shot = false
    sync_timer.autostart = true
    sync_timer.connect("timeout", self, "_on_dream_sync_timer")
    add_child(sync_timer)
    
    print("Dream API Interface initialized")
    print("Current dream state: " + DreamState.keys()[current_dream_state])

func _connect_to_systems():
    # Connect to dual core terminal
    dual_core_terminal = get_node_or_null("/root/DualCoreTerminal")
    if dual_core_terminal:
        dual_core_terminal.connect("miracle_triggered", self, "_on_miracle_triggered")
        dual_core_terminal.connect("time_state_changed", self, "_on_time_state_changed")
        dual_core_terminal.connect("snake_case_detected", self, "_on_snake_case_detected")
    
    # Connect to divine word game
    divine_word_game = get_node_or_null("/root/DivineWordGame")
    if divine_word_game:
        # Check if this is a connection to the actual game
        if divine_word_game.has_method("get_game_stats"):
            var stats = divine_word_game.get_game_stats()
            print("Connected to Divine Word Game (Level: " + str(stats.level) + ")")
    
    # Connect to word comment system
    word_comment_system = get_node_or_null("/root/WordCommentSystem")
    if word_comment_system:
        word_comment_system.connect("dream_recorded", self, "_on_dream_recorded")
    
    # Connect to word dream storage
    word_dream_storage = get_node_or_null("/root/WordDreamStorage")
    
    # Connect to turn system
    turn_system = get_node_or_null("/root/TurnSystem")
    if turn_system:
        turn_system.connect("dimension_changed", self, "_on_dimension_changed")

func _initialize_dream_cache():
    dream_cache = []
    
    # Initialize memory tier cache
    for tier in range(1, 4):
        memory_tier_cache[tier] = []
    
    # If word dream storage exists, try to load some initial dreams
    if word_dream_storage and word_dream_storage.has_method("get_all_dreams"):
        var dreams = word_dream_storage.get_all_dreams()
        for dream in dreams:
            if dream_cache.size() < DREAM_CACHE_SIZE:
                dream_cache.append(dream)
            else:
                break
    
    print("Dream cache initialized with " + str(dream_cache.size()) + " dreams")

# ----- API CONNECTION -----
func connect_to_api(api_name, host=DEFAULT_HOST, port=DEFAULT_PORT):
    # Create HTTP client
    var http = HTTPClient.new()
    var err = http.connect_to_host(host, port)
    
    if err != OK:
        print("Error connecting to API: " + str(err))
        return false
    
    # Add to active connections
    active_connections[api_name] = {
        "client": http,
        "host": host,
        "port": port,
        "status": HTTPClient.STATUS_CONNECTING,
        "last_request": 0,
        "last_response": 0,
        "retry_count": 0
    }
    
    print("Connecting to API: " + api_name + " at " + host + ":" + str(port))
    return true

func disconnect_from_api(api_name):
    if not active_connections.has(api_name):
        return false
    
    var connection = active_connections[api_name]
    
    if connection.has("client"):
        connection.client.close()
    
    active_connections.erase(api_name)
    
    emit_signal("api_disconnected", api_name)
    print("Disconnected from API: " + api_name)
    
    return true

func set_api_credentials(key, secret):
    api_key = key
    api_secret = secret
    return true

func authenticate_api(api_name):
    if not active_connections.has(api_name):
        return false
    
    var connection = active_connections[api_name]
    
    if connection.status != HTTPClient.STATUS_CONNECTED:
        return false
    
    # Create authentication request
    var headers = [
        "Content-Type: application/json",
        "Authorization: Bearer " + api_key
    ]
    
    var data = {
        "key": api_key,
        "secret": api_secret
    }
    
    var json_data = JSON.print(data)
    
    # Send request
    var err = connection.client.request("POST", "/auth", headers, json_data)
    
    if err != OK:
        print("Error sending authentication request: " + str(err))
        return false
    
    connection.last_request = OS.get_unix_time()
    
    # Add callback for response
    response_callbacks[api_name] = {
        "type": "auth",
        "timestamp": OS.get_unix_time()
    }
    
    return true

# ----- DREAM PROCESSING -----
func send_dream(dream_data, api_name):
    if not active_connections.has(api_name):
        return false
    
    var connection = active_connections[api_name]
    
    if connection.status != HTTPClient.STATUS_CONNECTED:
        return false
    
    # Create dream sending request
    var headers = [
        "Content-Type: application/json",
        "Authorization: Bearer " + api_key
    ]
    
    var json_data = JSON.print(dream_data)
    
    # Send request
    var err = connection.client.request("POST", "/dreams", headers, json_data)
    
    if err != OK:
        print("Error sending dream: " + str(err))
        return false
    
    connection.last_request = OS.get_unix_time()
    
    # Add to request queue
    request_queue.append({
        "api_name": api_name,
        "endpoint": "/dreams",
        "method": "POST",
        "data": dream_data,
        "timestamp": OS.get_unix_time(),
        "retry_count": 0
    })
    
    # Generate dream ID
    var dream_id = "dream_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)
    
    emit_signal("dream_sent", dream_id)
    return dream_id

func fetch_dreams(api_name, count=10):
    if not active_connections.has(api_name):
        return false
    
    var connection = active_connections[api_name]
    
    if connection.status != HTTPClient.STATUS_CONNECTED:
        return false
    
    # Create dream fetching request
    var headers = [
        "Content-Type: application/json",
        "Authorization: Bearer " + api_key
    ]
    
    # Send request
    var err = connection.client.request("GET", "/dreams?count=" + str(count), headers, "")
    
    if err != OK:
        print("Error fetching dreams: " + str(err))
        return false
    
    connection.last_request = OS.get_unix_time()
    
    # Add callback for response
    response_callbacks[api_name] = {
        "type": "fetch_dreams",
        "timestamp": OS.get_unix_time()
    }
    
    return true

func process_dream(dream_text, source="api", state=DreamState.ACTIVE):
    # Process a dream text and add it to storage
    var dream_id = "dream_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)
    
    var dream_data = {
        "id": dream_id,
        "text": dream_text,
        "source": source,
        "state": state,
        "timestamp": OS.get_unix_time(),
        "processed": false
    }
    
    # Add to cache
    if dream_cache.size() >= DREAM_CACHE_SIZE:
        dream_cache.pop_front()  # Remove oldest dream
    
    dream_cache.append(dream_data)
    
    # If word dream storage exists, store the dream
    if word_dream_storage and word_dream_storage.has_method("save_dream"):
        var tier = 1
        
        # Higher tier for more important dreams
        if state == DreamState.PROPHETIC or state == DreamState.DIVINE:
            tier = 3
        elif state == DreamState.LUCID:
            tier = 2
        
        word_dream_storage.save_dream(dream_data, tier)
        
        # Keep tier cache updated
        if memory_tier_cache.has(tier):
            memory_tier_cache[tier].append(dream_data)
    
    # If word comment system exists, add comment about the dream
    if word_comment_system:
        var comment_type = word_comment_system.CommentType.DREAM
        if state == DreamState.DIVINE:
            comment_type = word_comment_system.CommentType.DIVINE
        
        word_comment_system.add_comment("dream_" + dream_id, 
            "DREAM: " + dream_text, 
            comment_type, "Dream_API")
    
    emit_signal("dream_received", dream_id, dream_data)
    return dream_id

func change_dream_state(new_state):
    var old_state = current_dream_state
    current_dream_state = new_state
    
    # Update dream intensity based on state
    match new_state:
        DreamState.DORMANT:
            dream_intensity = 0.0
        DreamState.ACTIVE:
            dream_intensity = 0.3
        DreamState.LUCID:
            dream_intensity = 0.6
        DreamState.NIGHTMARE:
            dream_intensity = 0.8
        DreamState.PROPHETIC:
            dream_intensity = 0.9
        DreamState.DIVINE:
            dream_intensity = 1.0
    
    # Update dream sync interval based on intensity
    dream_sync_interval = 9.0 / (1.0 + dream_intensity)  # Faster sync for higher intensity
    
    emit_signal("dream_state_changed", old_state, new_state)
    print("Dream state changed from " + DreamState.keys()[old_state] + " to " + DreamState.keys()[new_state])
    
    # If word comment system exists, add comment about state change
    if word_comment_system:
        var comment_type = word_comment_system.CommentType.DREAM
        if new_state == DreamState.DIVINE:
            comment_type = word_comment_system.CommentType.DIVINE
        
        word_comment_system.add_comment("dream_state", 
            "Dream state changed to " + DreamState.keys()[new_state], 
            comment_type, "Dream_API")
    
    return true

# ----- MEMORY TIER ACCESS -----
func access_memory_tier(tier, read_only=true):
    if tier < 1 or tier > 3:
        return null
    
    # Check if cached data exists
    if memory_tier_cache.has(tier) and memory_tier_cache[tier].size() > 0:
        emit_signal("memory_tier_accessed", tier, memory_tier_cache[tier])
        return memory_tier_cache[tier]
    
    # Try to fetch from word dream storage
    if word_dream_storage and word_dream_storage.has_method("get_memories_by_tier"):
        var memories = word_dream_storage.get_memories_by_tier(tier)
        
        # Cache the results
        memory_tier_cache[tier] = memories
        
        emit_signal("memory_tier_accessed", tier, memories)
        return memories
    
    # If divine word game exists, try its memory access method
    if divine_word_game and divine_word_game.has_method("get_memory_by_tier"):
        var memories = divine_word_game.get_memory_by_tier(tier)
        
        # Cache the results
        memory_tier_cache[tier] = memories
        
        emit_signal("memory_tier_accessed", tier, memories)
        return memories
    
    return []

func store_in_memory_tier(data, tier):
    if tier < 1 or tier > 3:
        return false
    
    # If word dream storage exists, store the data
    if word_dream_storage and word_dream_storage.has_method("save_memory"):
        word_dream_storage.save_memory(data, tier)
        
        # Update cache
        if not memory_tier_cache.has(tier):
            memory_tier_cache[tier] = []
        
        memory_tier_cache[tier].append(data)
        
        emit_signal("memory_tier_accessed", tier, memory_tier_cache[tier])
        return true
    
    # If divine word game exists, try its memory storage method
    if divine_word_game and divine_word_game.has_method("save_to_tier"):
        divine_word_game.save_to_tier(data, tier)
        
        # Update cache
        if not memory_tier_cache.has(tier):
            memory_tier_cache[tier] = []
        
        memory_tier_cache[tier].append(data)
        
        emit_signal("memory_tier_accessed", tier, memory_tier_cache[tier])
        return true
    
    return false

# ----- MAIN DATA READING -----
func read_main_data(data_type):
    var data = null
    
    match data_type:
        "game_stats":
            if divine_word_game and divine_word_game.has_method("get_game_stats"):
                data = divine_word_game.get_game_stats()
        
        "terminal_cores":
            if dual_core_terminal and dual_core_terminal.has_method("get_all_cores"):
                data = dual_core_terminal.get_all_cores()
        
        "dream_cache":
            data = dream_cache
        
        "turn_info":
            if turn_system and turn_system.has_method("get_turn_info"):
                data = turn_system.get_turn_info()
        
        "current_dimension":
            if turn_system:
                data = turn_system.current_dimension
        
        "memory_tiers":
            var tiers = {}
            for tier in range(1, 4):
                tiers[tier] = access_memory_tier(tier)
            data = tiers
        
        "dream_state":
            data = {
                "state": current_dream_state,
                "intensity": dream_intensity,
                "sync_interval": dream_sync_interval,
                "cache_size": dream_cache.size()
            }
    
    if data != null:
        emit_signal("main_data_read", data_type, data)
    
    return data

func read_all_main_data():
    var all_data = {}
    
    var data_types = [
        "game_stats",
        "terminal_cores",
        "dream_cache",
        "turn_info",
        "current_dimension",
        "memory_tiers",
        "dream_state"
    ]
    
    for data_type in data_types:
        all_data[data_type] = read_main_data(data_type)
    
    return all_data

# ----- SNAKE CASE DATA FORMATTING -----
func format_snake_case(text):
    # Convert text to snake_case format
    var result = ""
    var prev_char_was_uppercase = false
    
    for i in range(text.length()):
        var c = text[i]
        
        if c == " ":
            # Replace spaces with underscores
            result += "_"
            prev_char_was_uppercase = false
        elif c >= "A" and c <= "Z":
            # Convert uppercase to lowercase, possibly add underscore
            if i > 0 and not prev_char_was_uppercase and result[result.length() - 1] != "_":
                result += "_"
            
            result += c.to_lower()
            prev_char_was_uppercase = true
        else:
            result += c
            prev_char_was_uppercase = false
    
    return result

func clean_data_with_snake_case(data):
    # Convert all keys in a dictionary to snake_case
    if typeof(data) != TYPE_DICTIONARY:
        return data
    
    var result = {}
    
    for key in data:
        var snake_key = format_snake_case(key)
        
        if typeof(data[key]) == TYPE_DICTIONARY:
            result[snake_key] = clean_data_with_snake_case(data[key])
        elif typeof(data[key]) == TYPE_ARRAY:
            var cleaned_array = []
            for item in data[key]:
                if typeof(item) == TYPE_DICTIONARY:
                    cleaned_array.append(clean_data_with_snake_case(item))
                else:
                    cleaned_array.append(item)
            result[snake_key] = cleaned_array
        else:
            result[snake_key] = data[key]
    
    return result

# ----- EVENT HANDLERS -----
func _on_dream_sync_timer():
    # Called at the sacred interval for dream synchronization
    
    # Check dream state
    if current_dream_state == DreamState.DORMANT:
        return
    
    # Generate a dream based on current state
    if randf() < dream_intensity:
        _generate_dream()
    
    # Check if any API connections need refreshing
    for api_name in active_connections:
        var connection = active_connections[api_name]
        
        if OS.get_unix_time() - connection.last_request > 60:
            # Refresh connection by fetching dreams
            fetch_dreams(api_name, 1)

func _generate_dream():
    # Generate a dream based on current state
    var templates = []
    
    match current_dream_state:
        DreamState.ACTIVE:
            templates = [
                "Walking through a misty forest, the trees whisper secrets.",
                "Flying over an endless ocean, feeling weightless and free.",
                "Exploring an ancient library filled with glowing books.",
                "Climbing a staircase that seems to reach into the clouds."
            ]
        
        DreamState.LUCID:
            templates = [
                "I realize I'm dreaming as the sky turns purple with geometric patterns.",
                "As I become aware this is a dream, I begin to shape the environment around me.",
                "The dream landscape responds to my thoughts, shifting and changing at will.",
                "I can feel the boundaries between reality and dream becoming thin and permeable."
            ]
        
        DreamState.NIGHTMARE:
            templates = [
                "Shadows with glowing eyes chase me through endless corridors.",
                "I'm falling endlessly into a dark abyss with no bottom.",
                "The walls are closing in slowly, and I can't find an exit.",
                "Everyone I meet has no face, just smooth skin where features should be."
            ]
        
        DreamState.PROPHETIC:
            templates = [
                "I see fragments of future events, like pieces of a shattered mirror.",
                "Numbers and symbols float in the air, forming patterns that reveal coming changes.",
                "A voice speaks from everywhere and nowhere, telling me what is to come.",
                "Time splits into multiple streams, showing different possible futures."
            ]
        
        DreamState.DIVINE:
            templates = [
                "Surrounded by light beyond description, I receive knowledge beyond words.",
                "The universe unfolds before me, revealing its sacred patterns and purpose.",
                "Divine beings of pure energy communicate with me through music and color.",
                "The boundaries between all things dissolve, and I experience complete unity."
            ]
    
    if templates.size() > 0:
        var template = templates[randi() % templates.size()]
        process_dream(template, "generated", current_dream_state)

func _on_miracle_triggered(core_id):
    # Miracles elevate dream state
    var new_state = min(current_dream_state + 2, DreamState.DIVINE)
    change_dream_state(new_state)
    
    # Generate a divine dream
    process_dream(
        "A miracle ripples through reality, revealing glimpses of divine patterns.",
        "miracle",
        DreamState.DIVINE
    )

func _on_time_state_changed(old_state, new_state):
    # Time shifts affect dreams
    if new_state == dual_core_terminal.TimeState.PAST:
        change_dream_state(DreamState.ACTIVE)
    elif new_state == dual_core_terminal.TimeState.FUTURE:
        change_dream_state(DreamState.PROPHETIC)
    elif new_state == dual_core_terminal.TimeState.TIMELESS:
        change_dream_state(DreamState.DIVINE)
    else: # PRESENT
        change_dream_state(DreamState.LUCID)

func _on_snake_case_detected(text, cleaned_text):
    # Snake case triggers affect dreams
    if cleaned_text == "i_might_see":
        change_dream_state(DreamState.DIVINE)
        
        # Generate a special dream
        process_dream(
            "I_Might_See reveals a glimpse beyond the veil, where all knowledge is accessible.",
            "snake_case",
            DreamState.DIVINE
        )
    elif cleaned_text == "dream_state":
        # Cycle dream state
        var next_state = (current_dream_state + 1) % DreamState.size()
        change_dream_state(next_state)
    elif cleaned_text == "access_tier_3":
        # Access highest memory tier
        access_memory_tier(3, false)

func _on_dream_recorded(dream_text, power_level):
    # When a dream is recorded in the comment system, process it
    var state = DreamState.ACTIVE
    
    if power_level > 80:
        state = DreamState.DIVINE
    elif power_level > 60:
        state = DreamState.PROPHETIC
    elif power_level > 40:
        state = DreamState.LUCID
    elif power_level > 20:
        state = DreamState.ACTIVE
    else:
        state = DreamState.DORMANT
    
    process_dream(dream_text, "comment_system", state)

func _on_dimension_changed(new_dimension, old_dimension):
    # Dimension 7 is the dream dimension
    if new_dimension == 7:
        change_dream_state(DreamState.DIVINE)
        
        # Generate a dimension 7 dream
        process_dream(
            "Entering Dimension 7, the realm of dreams and collective consciousness.",
            "dimension_7",
            DreamState.DIVINE
        )
    elif old_dimension == 7:
        # Leaving dream dimension
        change_dream_state(DreamState.LUCID)

# ----- PUBLIC API -----
func get_dream_cache():
    return dream_cache

func get_dream_by_id(dream_id):
    for dream in dream_cache:
        if dream.id == dream_id:
            return dream
    
    return null

func get_dreams_by_state(state):
    var result = []
    
    for dream in dream_cache:
        if dream.state == state:
            result.append(dream)
    
    return result

func get_current_dream_state():
    return {
        "state": current_dream_state,
        "intensity": dream_intensity,
        "name": DreamState.keys()[current_dream_state]
    }

func get_memory_tier_info():
    var result = {}
    
    for tier in range(1, 4):
        var count = 0
        if memory_tier_cache.has(tier):
            count = memory_tier_cache[tier].size()
        
        result[tier] = {
            "count": count,
            "name": "Tier " + str(tier)
        }
    
    return result

func create_dream_from_text(text, state=null):
    # Determine dream state based on text content if not provided
    if state == null:
        if "divine" in text.to_lower() or "god" in text.to_lower():
            state = DreamState.DIVINE
        elif "future" in text.to_lower() or "prophec" in text.to_lower():
            state = DreamState.PROPHETIC
        elif "nightmare" in text.to_lower() or "terror" in text.to_lower():
            state = DreamState.NIGHTMARE
        elif "lucid" in text.to_lower() or "aware" in text.to_lower():
            state = DreamState.LUCID
        else:
            state = DreamState.ACTIVE
    
    return process_dream(text, "api_create", state)

func search_dreams(query):
    var results = []
    
    for dream in dream_cache:
        if dream.text.to_lower().find(query.to_lower()) >= 0:
            results.append(dream)
    
    return results

func find_patterns_in_dreams(pattern_regex):
    var results = []
    var regex = RegEx.new()
    var err = regex.compile(pattern_regex)
    
    if err != OK:
        print("Error compiling regex: " + str(err))
        return results
    
    for dream in dream_cache:
        var matches = regex.search_all(dream.text)
        if matches.size() > 0:
            results.append({
                "dream": dream,
                "matches": matches
            })
    
    return results

func connect_to_chat_api(api_key=""):
    # Configure connection to external chat API (e.g., OpenAI)
    if api_key != "":
        set_api_credentials(api_key, "")
    
    # Try to connect
    return connect_to_api("chat_api", "api.openai.com", 443)

func process_chat_response(response_text):
    # Process a response from a chat API and extract dream content
    if response_text.find("DREAM:") >= 0:
        var parts = response_text.split("DREAM:", true, 1)
        if parts.size() > 1:
            var dream_text = parts[1].strip_edges()
            return create_dream_from_text(dream_text)
    elif response_text.find("MEMORY:") >= 0:
        var parts = response_text.split("MEMORY:", true, 1)
        if parts.size() > 1:
            var memory_text = parts[1].strip_edges()
            var data = {
                "text": memory_text,
                "source": "chat_api",
                "timestamp": OS.get_unix_time()
            }
            
            // Determine which tier to store in
            var tier = 1
            if memory_text.to_lower().find("important") >= 0 or memory_text.to_lower().find("crucial") >= 0:
                tier = 2
            elif memory_text.to_lower().find("divine") >= 0 or memory_text.to_lower().find("fundamental") >= 0:
                tier = 3
            
            store_in_memory_tier(data, tier)
            return "memory_" + str(OS.get_unix_time())
    
    return null

func set_openai_key(key):
    api_key = key
    return true