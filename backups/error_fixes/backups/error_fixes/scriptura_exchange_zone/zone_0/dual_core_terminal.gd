extends Node

# Dual Core Terminal System for 12 Turns Game
# Manages multiple terminal cores and their interactions with the Divine Word Game
# Implements hash-based bracket coloring and special pattern detection

class_name DualCoreTerminal

# ----- CORE CONFIGURATION -----
const MAX_CORES = 9
const CORE_0_PRIORITY = 100
const HASH_SYMBOL = "#"
const MAX_ACCOUNT_VALUE = 19

# ----- TERMINAL WINDOW STATES -----
enum WindowState {
    ACTIVE,
    PROCESSING,
    WAITING,
    BACKGROUND,
    API_CONNECTED,
    MAX_ACCOUNT,
    CALIBRATION,
    GAME_MODE,
    TETRIS_MODE,
    MINECRAFT_MODE
}

# ----- MIRACLE PATTERN DETECTION -----
const MIRACLE_PATTERN = "#$%$#@@"
const SPECIAL_PATTERNS = {
    "####": "solid_wall",
    "~~~~": "water_area",
    "^^^^": "lava_pit",
    "...+...": "door_corridor",
    "@@@": "entity_spawn",
    "$$$": "treasure_room",
    "###\n#+#\n###": "enclosed_room",
    "[@]": "player_start",
    "<->": "teleporter",
    "/*\\": "time_rune",
    "|/\\|": "dimension_gate"
}

# ----- TIME STATES -----
enum TimeState {
    PAST,
    PRESENT,
    FUTURE,
    TIMELESS
}

# ----- BRACKET STYLES -----
var bracket_styles = {
    "default": {
        "color": Color(1, 1, 1),
        "bold": false,
        "symbol_pairs": [["(", ")"], ["[", "]"], ["{", "}"], ["<", ">"]]
    },
    "red": {
        "color": Color(1, 0, 0),
        "bold": true,
        "symbol_pairs": [["(", ")"], ["[", "]"], ["{", "}"], ["<", ">"]]
    },
    "green": {
        "color": Color(0, 1, 0),
        "bold": true,
        "symbol_pairs": [["(", ")"], ["[", "]"], ["{", "}"], ["<", ">"]]
    },
    "blue": {
        "color": Color(0, 0, 1),
        "bold": true,
        "symbol_pairs": [["(", ")"], ["[", "]"], ["{", "}"], ["<", ">"]]
    },
    "purple": {
        "color": Color(0.5, 0, 0.5),
        "bold": true,
        "symbol_pairs": [["(", ")"], ["[", "]"], ["{", "}"], ["<", ">"]]
    },
    "gold": {
        "color": Color(1, 0.84, 0),
        "bold": true,
        "symbol_pairs": [["(", ")"], ["[", "]"], ["{", "}"], ["<", ">"]]
    },
    "rainbow": {
        "color": Color(1, 1, 1),  # Base color, actual colors cycle
        "bold": true,
        "symbol_pairs": [["(", ")"], ["[", "]"], ["{", "}"], ["<", ">"]],
        "rainbow": true
    }
}

# ----- TERMINAL CORE STORAGE -----
var cores = {}
var active_core_id = 0
var current_time_state = TimeState.PRESENT
var rainbow_colors = [
    Color(1, 0, 0),      # Red
    Color(1, 0.5, 0),    # Orange
    Color(1, 1, 0),      # Yellow
    Color(0, 1, 0),      # Green
    Color(0, 0.5, 1),    # Blue
    Color(0.3, 0, 0.8)   # Purple
]
var rainbow_index = 0
var rainbow_timer = 0

# ----- GAME INTEGRATION -----
var divine_word_game = null
var divine_word_processor = null
var turn_system = null
var word_comment_system = null

# ----- SIGNALS -----
signal core_switched(from_core, to_core)
signal input_processed(core_id, text, result)
signal special_pattern_detected(pattern, effect)
signal miracle_triggered(core_id)
signal time_state_changed(old_state, new_state)
signal snake_case_detected(text, cleaned_text)

# ----- INITIALIZATION -----
func _ready():
    print("Dual Core Terminal System initializing...")
    
    # Initialize core 0 (always exists)
    cores[0] = {
        "id": 0,
        "state": WindowState.ACTIVE,
        "name": "Core 0",
        "priority": CORE_0_PRIORITY,
        "buffer": "",
        "history": [],
        "bracket_style": "default",
        "account_value": 0,
        "special_patterns": {},
        "last_input": "",
        "creation_time": OS.get_unix_time(),
        "miracle_count": 0
    }
    
    # Connect to game systems
    _connect_to_game_systems()
    
    # Initialize additional cores based on current dimension
    _initialize_dimension_cores()
    
    print("Dual Core Terminal System initialized")
    print("Active cores: " + str(cores.size()))
    print("Current time state: " + TimeState.keys()[current_time_state])

func _connect_to_game_systems():
    # Connect to divine word game
    divine_word_game = get_node_or_null("/root/DivineWordGame")
    
    # Connect to divine word processor
    divine_word_processor = get_node_or_null("/root/DivineWordProcessor")
    
    # Connect to turn system
    turn_system = get_node_or_null("/root/TurnSystem")
    if turn_system:
        turn_system.connect("dimension_changed", self, "_on_dimension_changed")
    
    # Connect to word comment system
    word_comment_system = get_node_or_null("/root/WordCommentSystem")

func _initialize_dimension_cores():
    # Create additional cores based on current dimension
    var dimension = 3 # Default dimension if turn system not found
    
    if turn_system:
        dimension = turn_system.current_dimension
    
    # Create cores based on dimension
    for i in range(1, min(dimension + 1, MAX_CORES)):
        # Each dimension unlocks a new core
        if not cores.has(i):
            cores[i] = {
                "id": i,
                "state": WindowState.WAITING,
                "name": "Core " + str(i),
                "priority": i * 10,
                "buffer": "",
                "history": [],
                "bracket_style": "default",
                "account_value": 0,
                "special_patterns": {},
                "last_input": "",
                "creation_time": OS.get_unix_time(),
                "miracle_count": 0
            }

# ----- PROCESSING -----
func _process(delta):
    # Update rainbow colors if any cores use rainbow style
    rainbow_timer += delta
    if rainbow_timer >= 0.2: # Update every 0.2 seconds
        rainbow_timer = 0
        rainbow_index = (rainbow_index + 1) % rainbow_colors.size()
        
        # Check if any cores use rainbow brackets
        for core_id in cores:
            if cores[core_id].bracket_style == "rainbow":
                # This will trigger a redraw on any UI components displaying this core
                pass

# ----- CORE MANAGEMENT -----
func switch_core(core_id):
    if not cores.has(core_id):
        print("ERROR: Cannot switch to non-existent core: " + str(core_id))
        return false
    
    var old_core = active_core_id
    active_core_id = core_id
    
    # Mark old core as background, new core as active
    if cores.has(old_core):
        cores[old_core].state = WindowState.BACKGROUND
    
    cores[active_core_id].state = WindowState.ACTIVE
    
    emit_signal("core_switched", old_core, active_core_id)
    print("Switched from Core " + str(old_core) + " to Core " + str(core_id))
    
    return true

func create_core(core_id, name=""):
    if cores.has(core_id):
        print("WARNING: Core " + str(core_id) + " already exists!")
        return false
    
    if core_id < 0 or core_id >= MAX_CORES:
        print("ERROR: Core ID must be between 0 and " + str(MAX_CORES-1))
        return false
    
    var core_name = name if name else "Core " + str(core_id)
    
    cores[core_id] = {
        "id": core_id,
        "state": WindowState.WAITING,
        "name": core_name,
        "priority": core_id * 10,
        "buffer": "",
        "history": [],
        "bracket_style": "default",
        "account_value": 0,
        "special_patterns": {},
        "last_input": "",
        "creation_time": OS.get_unix_time(),
        "miracle_count": 0
    }
    
    print("Created new core: " + core_name + " (ID: " + str(core_id) + ")")
    return true

func get_core_info(core_id):
    if not cores.has(core_id):
        return null
    
    # Return a copy of core info without history (can be large)
    var info = cores[core_id].duplicate()
    info.erase("history")
    return info

func get_all_cores():
    var core_ids = []
    for core_id in cores:
        core_ids.append(core_id)
    return core_ids

# ----- INPUT PROCESSING -----
func process_input(core_id, input_text):
    if not cores.has(core_id):
        print("ERROR: Cannot process input for non-existent core: " + str(core_id))
        return null
    
    # Store raw input in core history
    cores[core_id].history.append({
        "type": "input",
        "text": input_text,
        "timestamp": OS.get_unix_time()
    })
    
    cores[core_id].last_input = input_text
    
    var result = {
        "original": input_text,
        "processed": input_text,
        "special_patterns": [],
        "hash_commands": [],
        "miracle_triggered": false,
        "time_shift": false,
        "snake_case_detected": false
    }
    
    # Process special hash commands
    if input_text.find(HASH_SYMBOL) >= 0:
        result.hash_commands = _process_hash_commands(core_id, input_text)
    
    # Check for special patterns
    var patterns = _detect_special_patterns(input_text)
    result.special_patterns = patterns
    
    # Check for miracle pattern
    if input_text.find(MIRACLE_PATTERN) >= 0:
        result.miracle_triggered = true
        _trigger_miracle(core_id)
    
    # Check for time state commands
    var time_shift = _check_time_shift_commands(input_text)
    if time_shift:
        result.time_shift = true
    
    # Check for snake_case formatting
    if "_" in input_text:
        var snake_case = _process_snake_case(input_text)
        if snake_case.detected:
            result.snake_case_detected = true
            result.snake_case = snake_case.cleaned
            
            emit_signal("snake_case_detected", input_text, snake_case.cleaned)
            
            # Special case for "I_Might_See"
            if snake_case.cleaned == "i_might_see":
                result.i_might_see_secret = true
                _handle_i_might_see_secret(core_id)
    
    # Process words with divine word processor
    if divine_word_processor:
        var word_result = divine_word_processor.process_text(input_text, "Terminal_Core_" + str(core_id))
        result.word_power = word_result.total_power
        result.powerful_words = word_result.powerful_words
    
    # Send result to game if available
    if divine_word_game:
        divine_word_game.process_word(input_text)
    
    # Add output to core history
    cores[core_id].history.append({
        "type": "output",
        "text": str(result),
        "timestamp": OS.get_unix_time()
    })
    
    emit_signal("input_processed", core_id, input_text, result)
    return result

func _process_hash_commands(core_id, text):
    var commands = []
    var parts = text.split(HASH_SYMBOL)
    
    # Skip the first part (before any hash)
    for i in range(1, parts.size()):
        var command_text = parts[i].strip_edges()
        
        # Extract first word as command
        var command = ""
        var param = ""
        
        var space_pos = command_text.find(" ")
        if space_pos >= 0:
            command = command_text.substr(0, space_pos).to_lower()
            param = command_text.substr(space_pos + 1).strip_edges()
        else:
            command = command_text.to_lower()
        
        if command:
            commands.append({
                "command": command,
                "param": param
            })
            
            # Process command
            _process_command(core_id, command, param)
    
    return commands

func _process_command(core_id, command, param):
    match command:
        "red", "green", "blue", "purple", "gold", "rainbow", "default":
            # Change bracket style
            cores[core_id].bracket_style = command
            print("Core " + str(core_id) + " bracket style set to: " + command)
        
        "switch":
            # Switch core if param is a valid core ID
            if param.is_valid_integer():
                var target_core = int(param)
                if cores.has(target_core):
                    switch_core(target_core)
        
        "account":
            # Set account value if param is a valid integer
            if param.is_valid_integer():
                var value = int(param)
                if value >= 0 and value <= MAX_ACCOUNT_VALUE:
                    cores[core_id].account_value = value
                    print("Core " + str(core_id) + " account value set to: " + str(value))
                    
                    # If account value reached max, set special state
                    if value == MAX_ACCOUNT_VALUE:
                        cores[core_id].state = WindowState.MAX_ACCOUNT
                        print("Core " + str(core_id) + " reached MAX_ACCOUNT state!")
        
        "calibrate":
            # Enter calibration mode
            cores[core_id].state = WindowState.CALIBRATION
            print("Core " + str(core_id) + " entered CALIBRATION state")
        
        "game":
            # Enter game mode
            cores[core_id].state = WindowState.GAME_MODE
            print("Core " + str(core_id) + " entered GAME_MODE state")
        
        "name":
            # Set core name
            if param:
                cores[core_id].name = param
                print("Core " + str(core_id) + " renamed to: " + param)
        
        "comment":
            # Add comment to word comment system
            if word_comment_system and param:
                var parts = param.split(" ", true, 1)
                if parts.size() >= 2:
                    var word = parts[0]
                    var comment = parts[1]
                    word_comment_system.add_comment(word, comment, word_comment_system.CommentType.OBSERVATION, 
                        "Core_" + str(core_id))
                    print("Comment added for word: " + word)

func _detect_special_patterns(text):
    var found_patterns = []
    
    # Check for each special pattern
    for pattern in SPECIAL_PATTERNS:
        if text.find(pattern) >= 0:
            found_patterns.append({
                "pattern": pattern,
                "effect": SPECIAL_PATTERNS[pattern]
            })
            
            emit_signal("special_pattern_detected", pattern, SPECIAL_PATTERNS[pattern])
    
    return found_patterns

func _trigger_miracle(core_id):
    # Increment miracle count for this core
    cores[core_id].miracle_count += 1
    
    # Add special output to core history
    cores[core_id].history.append({
        "type": "miracle",
        "text": "MIRACLE PATTERN DETECTED: Reality manifests!",
        "timestamp": OS.get_unix_time()
    })
    
    # Change bracket style to rainbow for this core
    cores[core_id].bracket_style = "rainbow"
    
    emit_signal("miracle_triggered", core_id)
    print("MIRACLE triggered on Core " + str(core_id) + "!")
    
    # Notify divine word game if available
    if divine_word_game:
        divine_word_game.process_word("miracle")
    
    # Add comment to word comment system if available
    if word_comment_system:
        word_comment_system.add_comment("miracle", 
            "MIRACLE PATTERN DETECTED on Core " + str(core_id) + "!",
            word_comment_system.CommentType.DIVINE, "Miracle_System")

func _check_time_shift_commands(text):
    var lower_text = text.to_lower()
    var old_state = current_time_state
    var changed = false
    
    if "past" in lower_text and (text.begins_with("past") or " past" in lower_text):
        current_time_state = TimeState.PAST
        changed = true
    elif "future" in lower_text and (text.begins_with("future") or " future" in lower_text):
        current_time_state = TimeState.FUTURE
        changed = true
    elif "present" in lower_text and (text.begins_with("present") or " present" in lower_text):
        current_time_state = TimeState.PRESENT
        changed = true
    elif "timeless" in lower_text and (text.begins_with("timeless") or " timeless" in lower_text):
        current_time_state = TimeState.TIMELESS
        changed = true
    
    if changed and old_state != current_time_state:
        emit_signal("time_state_changed", old_state, current_time_state)
        print("Time state changed from " + TimeState.keys()[old_state] + " to " + TimeState.keys()[current_time_state])
        
        # Add comment to word comment system if available
        if word_comment_system:
            word_comment_system.add_comment("time_shift",
                "Time state shifted to " + TimeState.keys()[current_time_state],
                word_comment_system.CommentType.OBSERVATION, "Time_System")
        
        return true
    
    return false

func _process_snake_case(text):
    var result = {
        "detected": false,
        "cleaned": ""
    }
    
    # Check if text has underscores and follows snake_case pattern
    if "_" in text:
        var words = text.split("_")
        var valid_snake_case = true
        
        # Verify that all parts are valid words
        for word in words:
            if word.strip_edges().empty():
                valid_snake_case = false
                break
        
        if valid_snake_case:
            result.detected = true
            result.cleaned = text.to_lower().strip_edges()
            
            # Add comment to word comment system if available
            if word_comment_system:
                word_comment_system.add_comment("snake_case",
                    "Snake case detected: " + result.cleaned,
                    word_comment_system.CommentType.OBSERVATION, "Snake_Case_System")
    
    return result

func _handle_i_might_see_secret(core_id):
    # Special functionality for the I_Might_See secret
    print("I_Might_See secret detected on Core " + str(core_id) + "!")
    
    # Add special output to core history
    cores[core_id].history.append({
        "type": "secret",
        "text": "I_MIGHT_SEE: The hidden truth reveals itself!",
        "timestamp": OS.get_unix_time()
    })
    
    # Change bracket style to gold for this core
    cores[core_id].bracket_style = "gold"
    
    # Add comment to word comment system if available
    if word_comment_system:
        word_comment_system.add_comment("i_might_see",
            "SECRET DISCOVERED: I_Might_See reveals the hidden reality!",
            word_comment_system.CommentType.DIVINE, "Secret_System")
    
    # If turn system is available, advance to the next dimension
    if turn_system and turn_system.current_dimension < turn_system.max_turns:
        turn_system.set_dimension(turn_system.current_dimension + 1)

# ----- TEXT FORMATTING -----
func format_text_with_brackets(core_id, text):
    if not cores.has(core_id):
        return text
    
    var style_name = cores[core_id].bracket_style
    
    if not bracket_styles.has(style_name):
        style_name = "default"
    
    var style = bracket_styles[style_name]
    var formatted_text = text
    
    # Handle rainbow style specially
    if style_name == "rainbow":
        # Choose color based on current rainbow index
        var color = rainbow_colors[rainbow_index]
        
        # Format each bracket pair with the current rainbow color
        for pair in style.symbol_pairs:
            var open_bracket = pair[0]
            var close_bracket = pair[1]
            
            # Replace with colored versions
            formatted_text = formatted_text.replace(open_bracket, "[color=#" + color.to_html(false) + "]" + open_bracket + "[/color]")
            formatted_text = formatted_text.replace(close_bracket, "[color=#" + color.to_html(false) + "]" + close_bracket + "[/color]")
    else:
        # Standard styling
        var color = style.color
        var is_bold = style.bold
        
        for pair in style.symbol_pairs:
            var open_bracket = pair[0]
            var close_bracket = pair[1]
            
            # Replace with colored/bold versions
            var open_tag = "[color=#" + color.to_html(false) + "]"
            var close_tag = "[/color]"
            
            if is_bold:
                open_tag += "[b]"
                close_tag = "[/b]" + close_tag
            
            formatted_text = formatted_text.replace(open_bracket, open_tag + open_bracket + close_tag)
            formatted_text = formatted_text.replace(close_bracket, open_tag + close_bracket + close_tag)
    
    return formatted_text

func format_output_for_time_state(text):
    # Modify text based on current time state
    match current_time_state:
        TimeState.PAST:
            return "[i][color=#aaaaaa]" + text + "[/color][/i]"
        
        TimeState.FUTURE:
            return "[color=#7777ff]" + text + "[/color]"
        
        TimeState.TIMELESS:
            return "[color=#aa77dd][wave amp=20 freq=2 connected=true]" + text + "[/wave][/color]"
        
        _: # PRESENT or default
            return text

# ----- EVENT HANDLERS -----
func _on_dimension_changed(new_dimension, old_dimension):
    print("Dimension changed from " + str(old_dimension) + "D to " + str(new_dimension) + "D")
    
    # Create new cores for the new dimension
    for i in range(old_dimension + 1, new_dimension + 1):
        if i < MAX_CORES and not cores.has(i):
            create_core(i)
    
    # Update all cores with dimension-specific behavior
    _update_cores_for_dimension(new_dimension)

func _update_cores_for_dimension(dimension):
    # Apply dimension-specific effects to all cores
    match dimension:
        1: # Genesis - core 0 only
            # Reset all cores except core 0
            for core_id in cores:
                if core_id != 0:
                    cores[core_id].buffer = ""
                    cores[core_id].state = WindowState.WAITING
            
            # Focus on core 0
            switch_core(0)
        
        4: # 4D - Time dimension
            # Enable time shifting commands
            print("Time dimension activated - Time shifting enabled")
        
        7: # 7D - Dream dimension
            # Change bracket style of core 7 to purple (dream color)
            if cores.has(7):
                cores[7].bracket_style = "purple"
                
                # Add comment about special state
                if word_comment_system:
                    word_comment_system.add_comment("core_7", 
                        "Core 7 activated in Dream Dimension - Unlock your subconscious!",
                        word_comment_system.CommentType.DREAM, "Core_System")
        
        9: # 9D - Judgment dimension
            # Change bracket style of core 0 to gold (judgment color)
            cores[0].bracket_style = "gold"
            
            # Add comment about this special dimension
            if word_comment_system:
                word_comment_system.add_comment("dimension_9", 
                    "Judgment dimension activated - Words will be judged!",
                    word_comment_system.CommentType.DIVINE, "Core_System")
        
        12: # 12D - Divine dimension
            # All cores get rainbow brackets
            for core_id in cores:
                cores[core_id].bracket_style = "rainbow"
            
            # Add comment about ultimate dimension
            if word_comment_system:
                word_comment_system.add_comment("dimension_12", 
                    "Divine dimension activated - All cores at maximum power!",
                    word_comment_system.CommentType.DIVINE, "Core_System")

# ----- PUBLIC API -----
func get_current_core_id():
    return active_core_id

func get_core_history(core_id, limit=10):
    if not cores.has(core_id):
        return []
    
    # Return most recent entries
    var history = cores[core_id].history
    
    if history.size() <= limit:
        return history
    
    return history.slice(history.size() - limit, history.size() - 1)

func get_formatted_core_output(core_id, text):
    # Apply bracket formatting and time state formatting
    var bracketed = format_text_with_brackets(core_id, text)
    return format_output_for_time_state(bracketed)

func clear_core_history(core_id):
    if cores.has(core_id):
        cores[core_id].history = []
        return true
    return false

func get_time_state():
    return current_time_state

func set_time_state(state):
    if state >= 0 and state < TimeState.size():
        var old_state = current_time_state
        current_time_state = state
        
        if old_state != current_time_state:
            emit_signal("time_state_changed", old_state, current_time_state)
            return true
    
    return false

func get_miracle_count(core_id):
    if cores.has(core_id):
        return cores[core_id].miracle_count
    return 0

func get_total_miracle_count():
    var total = 0
    for core_id in cores:
        total += cores[core_id].miracle_count
    return total

# Creates a multicolor bracket pattern based on the current core
func get_multicolor_pattern(core_id, text, pattern_type="standard"):
    var result = text
    
    # Different pattern types
    match pattern_type:
        "rainbow":
            # Rainbow pattern with gradient across text
            var colors = rainbow_colors
            var sections = min(6, text.length())
            var section_length = text.length() / sections
            
            for i in range(sections):
                var start_pos = i * section_length
                var end_pos = (i + 1) * section_length
                if i == sections - 1:
                    end_pos = text.length()
                
                var color = colors[i % colors.size()]
                var section = text.substr(start_pos, end_pos - start_pos)
                
                result = result.replace(section, "[color=#" + color.to_html(false) + "]" + section + "[/color]")
        
        "miracle":
            # Special miracle pattern with flashing effect
            result = "[rainbow freq=0.2 sat=10 val=20]" + result + "[/rainbow]"
        
        "snake_case":
            # Pattern for snake_case words
            var words = text.split("_")
            result = ""
            
            for i in range(words.size()):
                var word = words[i]
                var color = rainbow_colors[i % rainbow_colors.size()]
                
                result += "[color=#" + color.to_html(false) + "]" + word + "[/color]"
                if i < words.size() - 1:
                    result += "[color=#ffffff]_[/color]"
        
        _: # standard or default
            # Just apply the core's bracket style
            result = format_text_with_brackets(core_id, text)
    
    return result