class_name KeyboardCommandSystem
extends Node

# ----- KEY COMMAND CONFIGURATION -----
const KEY_COMMAND_PATTERNS = {
    # Shift key combinations
    "SHIFT+SPACE": {
        "name": "Word Separator",
        "symbol": "⎵",
        "dimensional_depth": 1,
        "function": "separate_words",
        "description": "Adds special type of space with dimensional properties"
    },
    "SHIFT+ENTER": {
        "name": "New Turn Cycle",
        "symbol": "↵",
        "dimensional_depth": 2,
        "function": "start_new_turn",
        "description": "Begins a new turn cycle in the 12-turns system"
    },
    "SHIFT+#": {
        "name": "Hash Symbol",
        "symbol": "#",
        "dimensional_depth": 1,
        "function": "insert_symbol",
        "description": "Inserts dimensional hash symbol"
    },
    "SHIFT+_": {
        "name": "Snake Case",
        "symbol": "_",
        "dimensional_depth": 1,
        "function": "convert_snake_case",
        "description": "Converts text to snake_case format"
    },
    
    # Ctrl key combinations
    "CTRL+SPACE": {
        "name": "Symbol Insertion",
        "symbol": "§",
        "dimensional_depth": 2,
        "function": "insert_special_symbol",
        "description": "Inserts a special dimensional symbol"
    },
    "CTRL+B": {
        "name": "Bridge Connection",
        "symbol": "≈",
        "dimensional_depth": 3,
        "function": "create_bridge_connection",
        "description": "Creates a bridge between dimensional spaces"
    },
    "CTRL+#": {
        "name": "Dimensional Shift Up",
        "symbol": "##",
        "dimensional_depth": 2,
        "function": "dimension_shift_up",
        "description": "Shifts up in dimensional hierarchy"
    },
    "CTRL+S": {
        "name": "Save State",
        "symbol": "💾",
        "dimensional_depth": 1,
        "function": "save_current_state",
        "description": "Saves current dimensional state"
    },
    "CTRL+Z": {
        "name": "Undo Change",
        "symbol": "↩",
        "dimensional_depth": 2,
        "function": "undo_last_change",
        "description": "Undoes last dimensional change"
    },
    "CTRL+Y": {
        "name": "Redo Change", 
        "symbol": "↪",
        "dimensional_depth": 2,
        "function": "redo_last_change",
        "description": "Redoes previously undone change"
    },
    
    # Alt key combinations
    "ALT+SPACE": {
        "name": "Alternative Correction",
        "symbol": "✓",
        "dimensional_depth": 2,
        "function": "alternative_correction",
        "description": "Shows alternative correction options"
    },
    "ALT+C": {
        "name": "Connection Check",
        "symbol": "⟷",
        "dimensional_depth": 2,
        "function": "check_connections",
        "description": "Checks all system connections"
    },
    "ALT+T": {
        "name": "Turn System",
        "symbol": "⟳",
        "dimensional_depth": 3,
        "function": "trigger_turn_system",
        "description": "Triggers turn system functions"
    },
    "ALT+#": {
        "name": "Triple Hash",
        "symbol": "###",
        "dimensional_depth": 3,
        "function": "insert_triple_hash",
        "description": "Inserts a triple hash symbol"
    },
    
    # Symbol transformations
    "#": {
        "name": "Direct Connection",
        "symbol": "#",
        "dimensional_depth": 1,
        "function": "direct_connection",
        "description": "Creates a direct dimensional connection"
    },
    "##": {
        "name": "Secondary Connection",
        "symbol": "##",
        "dimensional_depth": 2,
        "function": "secondary_connection",
        "description": "Creates a secondary dimensional connection"
    },
    "###": {
        "name": "Tertiary Connection",
        "symbol": "###",
        "dimensional_depth": 3,
        "function": "tertiary_connection",
        "description": "Creates a tertiary dimensional connection"
    },
    "#_": {
        "name": "Snake Connection",
        "symbol": "#_",
        "dimensional_depth": 2,
        "function": "snake_connection",
        "description": "Creates snake_case dimensional connection"
    },
    "_#": {
        "name": "Reverse Connection",
        "symbol": "_#",
        "dimensional_depth": 2,
        "function": "reverse_connection",
        "description": "Creates reverse dimensional connection"
    }
}

# ----- AUTO-CORRECTION DICTIONARY -----
const AUTO_CORRECTIONS = {
    "teh": "the",
    "adn": "and",
    "taht": "that",
    "wat": "what",
    "ot": "to",
    "nad": "and",
    "fo": "of",
    "ti": "it",
    "si": "is",
    "hte": "the",
    "wiht": "with",
    "waht": "what",
    "tiem": "time",
    "thign": "thing",
    "liek": "like",
    "ot": "to",
    "wehn": "when",
    "thre": "there",
    "becuase": "because",
    "trun": "turn",
    "systme": "system",
    "keyboartd": "keyboard",
    "sumbol": "symbol",
    "trigge": "trigger",
    "wrtie": "write",
    "wrtien": "written",
    "splti": "split",
    "recrod": "record",
    "recrodning": "recording",
    "maek": "make",
    "corect": "correct",
    "corectino": "correction",
    "uise": "use",
    "whoel": "whole",
    "dimensino": "dimension",
    "dimensino": "dimension",
    "etherial": "ethereal",
    "etherial engine": "ethereal engine",
    "brigde": "bridge",
    "transfoorm": "transform",
    "transformatino": "transformation",
    "conection": "connection",
    "conenct": "connect",
    "symbool": "symbol",
    "modificatino": "modification",
    "modificatinos": "modifications",
    "integratino": "integration",
    "integrte": "integrate",
    "wondow": "window",
    "wondows": "windows",
    "godto": "godot",
    "godto engine": "godot engine",
    "scheduel": "schedule",
    "automate": "automate",
    "automatino": "automation",
    "engnie": "engine"
}

# ----- SYSTEM STATE -----
var command_history = []
var correction_history = []
var auto_corrections_applied = 0
var last_key_sequence = []
var current_key_combination = ""
var input_buffer = ""
var last_correction_time = 0
var command_mode_active = false
var active_dimensional_depth = 1
var current_symbol = ""

# ----- SYSTEM REFERENCES -----
var auto_correction_system = null
var ethereal_bridge = null
var akashic_system = null
var turn_system = null

# ----- SYSTEM SETTINGS -----
var auto_correction_enabled = true
var command_mode_enabled = true
var dimensional_typing_enabled = true
var max_history_size = 100
var max_sequence_timeout = 1.0 # seconds
var last_key_time = 0

# ----- SIGNALS -----
signal command_executed(command_name, result)
signal auto_correction_applied(original, corrected)
signal symbol_inserted(symbol, dimension)
signal key_sequence_recognized(sequence)
signal dimensional_shift(old_depth, new_depth)

# ----- INITIALIZATION -----
func _ready():
    _find_systems()
    _initialize_input_handling()
    
    print("Keyboard Command System initialized with dimensional depth: " + str(active_dimensional_depth))

func _find_systems():
    # Find Auto-Correction System
    auto_correction_system = get_node_or_null("/root/AutoCorrectionSystem")
    if not auto_correction_system:
        auto_correction_system = _find_node_by_class(get_tree().root, "AutoCorrectionSystem")
    
    # Find Ethereal Bridge
    ethereal_bridge = get_node_or_null("/root/EtherealAkashicBridge")
    if not ethereal_bridge:
        ethereal_bridge = _find_node_by_class(get_tree().root, "EtherealAkashicBridge")
    
    # Find Akashic System
    akashic_system = get_node_or_null("/root/AkashicNumberSystem")
    if not akashic_system:
        akashic_system = _find_node_by_class(get_tree().root, "AkashicNumberSystem")
    
    # Find Turn System
    turn_system = get_node_or_null("/root/TurnSystem") 
    if not turn_system:
        turn_system = _find_node_by_class(get_tree().root, "TurnCycleController")
    
    print("Systems found - Auto-Correction: %s, Ethereal Bridge: %s, Akashic System: %s, Turn System: %s" % [
        "Yes" if auto_correction_system else "No",
        "Yes" if ethereal_bridge else "No",
        "Yes" if akashic_system else "No",
        "Yes" if turn_system else "No"
    ])

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

func _initialize_input_handling():
    # Connect to input events
    set_process_input(true)

# ----- INPUT HANDLING -----
func _input(event):
    if event is InputEventKey:
        if event.pressed:
            _handle_key_press(event)
        else:
            _handle_key_release(event)

func _handle_key_press(event: InputEventKey):
    # Get current key combination
    var key_combination = _get_key_combination(event)
    
    # Update key sequence for pattern recognition
    _update_key_sequence(key_combination)
    
    # Check if this is a recognized command
    if KEY_COMMAND_PATTERNS.has(key_combination):
        execute_command(key_combination)
    
    # For normal typing, check for auto-correction
    if _is_normal_typing_key(event) and not command_mode_active:
        input_buffer += char(event.unicode)
        _check_for_auto_correction()

func _handle_key_release(event: InputEventKey):
    # Reset command mode when modifier keys are released
    if event.keycode == KEY_SHIFT or event.keycode == KEY_CTRL or event.keycode == KEY_ALT:
        command_mode_active = false

func _get_key_combination(event: InputEventKey) -> String:
    var combination = ""
    
    # Add modifiers
    if event.shift:
        combination += "SHIFT+"
    if event.control:
        combination += "CTRL+"
    if event.alt:
        combination += "ALT+"
    
    # Add key
    var key_name = OS.get_keycode_string(event.keycode)
    combination += key_name
    
    current_key_combination = combination
    return combination

func _is_normal_typing_key(event: InputEventKey) -> bool:
    # Check if this is a normal typing key (not a command or control key)
    return event.unicode > 0 and not event.control and not event.alt

func _update_key_sequence(key: String):
    var current_time = Time.get_unix_time_from_system()
    
    # Clear sequence if timeout occurred
    if current_time - last_key_time > max_sequence_timeout:
        last_key_sequence.clear()
    
    # Add key to sequence
    last_key_sequence.append(key)
    
    # Limit sequence size
    if last_key_sequence.size() > 10:
        last_key_sequence.pop_front()
    
    # Check for known patterns
    _check_for_key_patterns()
    
    # Update timestamp
    last_key_time = current_time

func _check_for_key_patterns():
    # Join last few keys
    var sequence = ""
    for key in last_key_sequence.slice(-3, last_key_sequence.size()):
        sequence += key
    
    # Example sequences to check
    var sequences = {
        "SHIFT+#SHIFT+#SHIFT+#": "triple_hash_insertion",
        "CTRL+SCTRL+HCTRL+I": "dimensional_shift_initiation",
        "ALT+CALT+OALT+N": "connection_verification",
        "SHIFT+#CTRL+#ALT+#": "multi_dimensional_traversal"
    }
    
    if sequences.has(sequence):
        emit_signal("key_sequence_recognized", sequences[sequence])
        
        # Execute special sequence command
        var sequence_name = sequences[sequence]
        
        match sequence_name:
            "triple_hash_insertion":
                _insert_symbol("###")
            "dimensional_shift_initiation":
                _shift_dimensional_depth(active_dimensional_depth + 1)
            "connection_verification":
                _verify_all_connections()
            "multi_dimensional_traversal":
                if ethereal_bridge and ethereal_bridge.has_method("change_dimension"):
                    var connected_dimensions = ethereal_bridge.get_connected_dimensions()
                    if connected_dimensions.size() > 0:
                        ethereal_bridge.change_dimension(connected_dimensions[0])

func _check_for_auto_correction():
    if not auto_correction_enabled:
        return
    
    # Split input buffer into words
    var words = input_buffer.split(" ")
    
    # Check last word for auto-correction
    if words.size() > 0:
        var last_word = words[words.size() - 1]
        
        # Check if this word needs correction
        if AUTO_CORRECTIONS.has(last_word.to_lower()):
            var corrected = AUTO_CORRECTIONS[last_word.to_lower()]
            
            # Apply case preservation
            if last_word == last_word.to_upper():
                corrected = corrected.to_upper()
            elif last_word[0] == last_word[0].to_upper():
                corrected = corrected[0].to_upper() + corrected.substr(1)
            
            # Replace word in buffer
            words[words.size() - 1] = corrected
            input_buffer = " ".join(words)
            
            # Record correction
            _record_correction(last_word, corrected)
            
            # Emit signal
            emit_signal("auto_correction_applied", last_word, corrected)
            
            print("Auto-corrected: " + last_word + " → " + corrected)

func _record_correction(original: String, corrected: String):
    correction_history.append({
        "original": original,
        "corrected": corrected,
        "timestamp": Time.get_unix_time_from_system(),
        "dimensional_depth": active_dimensional_depth
    })
    
    # Limit history size
    if correction_history.size() > max_history_size:
        correction_history.pop_front()
    
    auto_corrections_applied += 1
    last_correction_time = Time.get_unix_time_from_system()

# ----- COMMAND EXECUTION -----
func execute_command(command_name: String):
    if not command_mode_enabled:
        return false
    
    if not KEY_COMMAND_PATTERNS.has(command_name):
        print("Unknown command: " + command_name)
        return false
    
    var command = KEY_COMMAND_PATTERNS[command_name]
    var function = command.function
    var result = null
    
    # Set command mode active
    command_mode_active = true
    
    # Execute function based on name
    match function:
        "separate_words":
            result = _separate_words()
        "start_new_turn":
            result = _start_new_turn()
        "insert_symbol":
            result = _insert_symbol(command.symbol)
        "convert_snake_case":
            result = _convert_to_snake_case()
        "insert_special_symbol":
            result = _insert_special_symbol()
        "create_bridge_connection":
            result = _create_bridge_connection()
        "dimension_shift_up":
            result = _shift_dimensional_depth(active_dimensional_depth + 1)
        "save_current_state":
            result = _save_current_state()
        "undo_last_change":
            result = _undo_last_change()
        "redo_last_change":
            result = _redo_last_change()
        "alternative_correction":
            result = _show_alternative_corrections()
        "check_connections":
            result = _verify_all_connections()
        "trigger_turn_system":
            result = _trigger_turn_system()
        "insert_triple_hash":
            result = _insert_symbol("###")
        "direct_connection":
            result = _create_connection("direct", 1)
        "secondary_connection":
            result = _create_connection("secondary", 2)
        "tertiary_connection":
            result = _create_connection("tertiary", 3)
        "snake_connection":
            result = _create_connection("snake", 2)
        "reverse_connection":
            result = _create_connection("reverse", 2)
    
    # Record command in history
    _record_command(command_name, result)
    
    # Emit signal
    emit_signal("command_executed", command_name, result)
    
    return result != null

func _record_command(command_name: String, result):
    command_history.append({
        "command": command_name,
        "result": result, 
        "timestamp": Time.get_unix_time_from_system(),
        "dimensional_depth": active_dimensional_depth
    })
    
    # Limit history size
    if command_history.size() > max_history_size:
        command_history.pop_front()

# ----- COMMAND IMPLEMENTATIONS -----
func _separate_words() -> bool:
    # Insert special word separator
    input_buffer += " "
    return true

func _start_new_turn() -> bool:
    if turn_system and turn_system.has_method("advance_turn"):
        var current_turn = 1
        if turn_system.has_method("get_current_turn"):
            current_turn = turn_system.get_current_turn()
        
        var success = turn_system.advance_turn()
        if success:
            print("Advanced to turn " + str(current_turn + 1))
            return true
    
    return false

func _insert_symbol(symbol_str: String) -> bool:
    input_buffer += symbol_str
    current_symbol = symbol_str
    
    emit_signal("symbol_inserted", symbol_str, active_dimensional_depth)
    
    return true

func _convert_to_snake_case() -> bool:
    # Split input buffer into words
    var words = input_buffer.split(" ")
    
    # Convert last word or all buffer to snake_case
    if words.size() > 0:
        var text_to_convert = words[words.size() - 1]
        
        # If no clear last word, convert all buffer
        if text_to_convert.strip_edges() == "":
            text_to_convert = input_buffer
            input_buffer = ""
        else:
            words.remove_at(words.size() - 1)
            input_buffer = " ".join(words)
            if input_buffer != "":
                input_buffer += " "
        
        # Convert to snake_case
        var snake_case = _to_snake_case(text_to_convert)
        input_buffer += snake_case
        
        return true
    
    return false

func _to_snake_case(text: String) -> String:
    # Convert to lowercase
    var result = text.to_lower()
    
    # Replace spaces and special characters with underscores
    var regex = RegEx.new()
    regex.compile("\\s+|[^a-z0-9]")
    result = regex.sub(result, "_", true)
    
    # Remove consecutive underscores
    regex.compile("_+")
    result = regex.sub(result, "_", true)
    
    # Remove leading/trailing underscores
    result = result.strip_edges()
    if result.begins_with("_"):
        result = result.substr(1)
    if result.ends_with("_"):
        result = result.substr(0, result.length() - 1)
    
    return result

func _insert_special_symbol() -> bool:
    # Get special symbol based on dimensional depth
    var symbol = "§"
    
    if active_dimensional_depth == 2:
        symbol = "¶"
    elif active_dimensional_depth == 3:
        symbol = "‡"
    elif active_dimensional_depth > 3:
        symbol = "≅"
    
    input_buffer += symbol
    current_symbol = symbol
    
    emit_signal("symbol_inserted", symbol, active_dimensional_depth)
    
    return true

func _create_bridge_connection() -> bool:
    if ethereal_bridge and ethereal_bridge.has_method("record_memory"):
        var content = "Bridge connection at depth " + str(active_dimensional_depth)
        if input_buffer.length() > 0:
            content = input_buffer
        
        var tags = ["bridge", "depth:" + str(active_dimensional_depth)]
        ethereal_bridge.record_memory(content, tags)
        
        print("Created bridge connection: " + content)
        return true
    
    return false

func _shift_dimensional_depth(new_depth: int) -> bool:
    var old_depth = active_dimensional_depth
    active_dimensional_depth = max(1, min(new_depth, 5))
    
    emit_signal("dimensional_shift", old_depth, active_dimensional_depth)
    print("Dimensional depth shifted from " + str(old_depth) + " to " + str(active_dimensional_depth))
    
    return true

func _save_current_state() -> bool:
    # Save state in akashic system or ethereal bridge
    var saved = false
    
    if akashic_system and akashic_system.has_method("store_record"):
        var data = {
            "input_buffer": input_buffer,
            "dimensional_depth": active_dimensional_depth,
            "corrections": auto_corrections_applied,
            "commands": command_history.size(),
            "timestamp": Time.get_unix_time_from_system()
        }
        
        saved = akashic_system.store_record(0, 0, data)
    
    if not saved and ethereal_bridge and ethereal_bridge.has_method("record_memory"):
        var content = "Saved state: Depth=" + str(active_dimensional_depth) + ", Buffer=" + input_buffer
        var tags = ["saved_state", "depth:" + str(active_dimensional_depth)]
        
        saved = ethereal_bridge.record_memory(content, tags)
    
    if saved:
        print("State saved successfully")
    else:
        print("Failed to save state")
    
    return saved

func _undo_last_change() -> bool:
    # For now, just clear the last word in buffer
    var words = input_buffer.split(" ")
    
    if words.size() > 0:
        words.remove_at(words.size() - 1)
        input_buffer = " ".join(words)
        
        if correction_history.size() > 0:
            correction_history.pop_back()
        
        print("Undid last change")
        return true
    
    return false

func _redo_last_change() -> bool:
    # Not implemented yet
    return false

func _show_alternative_corrections() -> bool:
    # Get last word
    var words = input_buffer.split(" ")
    
    if words.size() > 0:
        var last_word = words[words.size() - 1]
        var alternatives = _find_alternative_corrections(last_word)
        
        print("Alternative corrections for '" + last_word + "':")
        for alt in alternatives:
            print("- " + alt)
        
        return alternatives.size() > 0
    
    return false

func _find_alternative_corrections(word: String) -> Array:
    var alternatives = []
    
    # Direct match
    if AUTO_CORRECTIONS.has(word.to_lower()):
        alternatives.append(AUTO_CORRECTIONS[word.to_lower()])
    
    # Find similar words (simplified)
    for original in AUTO_CORRECTIONS.keys():
        # Check if original is similar to word
        if original.length() == word.length() and _similarity_score(original, word) > 0.7:
            alternatives.append(AUTO_CORRECTIONS[original])
        
        # Check if correction is similar to word
        var correction = AUTO_CORRECTIONS[original]
        if correction.length() == word.length() and _similarity_score(correction, word) > 0.7:
            if not alternatives.has(correction):
                alternatives.append(correction)
    
    return alternatives

func _similarity_score(a: String, b: String) -> float:
    # Simple character-based similarity (0.0 to 1.0)
    if a.length() == 0 or b.length() == 0:
        return 0.0
    
    var matches = 0
    var a_lower = a.to_lower()
    var b_lower = b.to_lower()
    
    for i in range(min(a.length(), b.length())):
        if a_lower[i] == b_lower[i]:
            matches += 1
    
    return float(matches) / max(a.length(), b.length())

func _verify_all_connections() -> bool:
    var all_connected = true
    
    print("Checking system connections:")
    
    if not auto_correction_system:
        print("- Auto-Correction System: DISCONNECTED")
        all_connected = false
    else:
        print("- Auto-Correction System: CONNECTED")
    
    if not ethereal_bridge:
        print("- Ethereal Bridge: DISCONNECTED")
        all_connected = false
    else:
        print("- Ethereal Bridge: CONNECTED")
    
    if not akashic_system:
        print("- Akashic System: DISCONNECTED")
        all_connected = false
    else:
        print("- Akashic System: CONNECTED")
    
    if not turn_system:
        print("- Turn System: DISCONNECTED")
        all_connected = false
    else:
        print("- Turn System: CONNECTED")
    
    return all_connected

func _trigger_turn_system() -> bool:
    if turn_system:
        if turn_system.has_method("trigger_special_event"):
            return turn_system.trigger_special_event("command_triggered", {
                "dimensional_depth": active_dimensional_depth,
                "symbol": current_symbol,
                "buffer": input_buffer
            })
    
    return false

func _create_connection(connection_type: String, depth: int) -> bool:
    if not ethereal_bridge:
        return false
    
    var dimension_key = ethereal_bridge.get_property("current_dimension") if ethereal_bridge.has_method("get_property") else "0-0-0"
    
    # Get connected dimensions
    var connected_dimensions = []
    if ethereal_bridge.has_method("get_connected_dimensions"):
        connected_dimensions = ethereal_bridge.get_connected_dimensions()
    
    # Create connection data
    var connection_data = {
        "type": connection_type,
        "depth": depth,
        "dimension": dimension_key,
        "symbol": _get_symbol_for_connection(connection_type),
        "timestamp": Time.get_unix_time_from_system()
    }
    
    # Create memory record
    if ethereal_bridge.has_method("record_memory"):
        var content = "Created " + connection_type + " connection at depth " + str(depth)
        var tags = ["connection", connection_type, "depth:" + str(depth)]
        
        ethereal_bridge.record_memory(content, tags)
        print("Connection created: " + content)
        
        return true
    
    return false

func _get_symbol_for_connection(connection_type: String) -> String:
    match connection_type:
        "direct":
            return "#"
        "secondary":
            return "##"
        "tertiary":
            return "###"
        "snake":
            return "#_"
        "reverse":
            return "_#"
        _:
            return "#"

# ----- PUBLIC API -----
func get_command_list() -> Array:
    var commands = []
    
    for command_name in KEY_COMMAND_PATTERNS:
        var command = KEY_COMMAND_PATTERNS[command_name]
        commands.append({
            "name": command_name,
            "description": command.description,
            "symbol": command.symbol,
            "depth": command.dimensional_depth
        })
    
    return commands

func get_correction_stats() -> Dictionary:
    return {
        "total_corrections": auto_corrections_applied,
        "last_correction_time": last_correction_time,
        "history_size": correction_history.size(),
        "current_dimensional_depth": active_dimensional_depth
    }

func set_auto_correction(enabled: bool) -> void:
    auto_correction_enabled = enabled
    print("Auto-correction " + ("enabled" if enabled else "disabled"))

func set_command_mode(enabled: bool) -> void:
    command_mode_enabled = enabled
    print("Command mode " + ("enabled" if enabled else "disabled"))

func set_dimensional_depth(depth: int) -> bool:
    return _shift_dimensional_depth(depth)

func add_custom_correction(original: String, corrected: String) -> bool:
    if original.strip_edges() == "":
        return false
    
    AUTO_CORRECTIONS[original.to_lower()] = corrected
    print("Added custom correction: " + original + " → " + corrected)
    
    return true

func get_current_input_buffer() -> String:
    return input_buffer

func clear_input_buffer() -> void:
    input_buffer = ""

func simulate_key_combination(combination: String) -> bool:
    if KEY_COMMAND_PATTERNS.has(combination):
        return execute_command(combination)
    
    return false