extends Node

class_name WordManifestationGame

# ----- GAME CONFIGURATION -----
const MAX_TURNS = 12
const MAX_TERMINAL_WINDOWS = 6
const WORD_POWER_THRESHOLD = 50
const REALITY_THRESHOLD = 200

# ----- TURN SYSTEM -----
var current_turn = 3  # Default to 3D space
var turn_symbols = ["α", "β", "γ", "δ", "ε", "ζ", "η", "θ", "ι", "κ", "λ", "μ"]
var turn_dimensions = ["1D", "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "11D", "12D"]
var turn_concepts = ["Point", "Line", "Space", "Time", "Consciousness", "Connection", "Creation", "Network", "Harmony", "Unity", "Transcendence", "Infinity"]
var turn_phases = ["Genesis", "Formation", "Complexity", "Consciousness", "Awakening", "Enlightenment", "Manifestation", "Connection", "Harmony", "Transcendence", "Unity", "Beyond"]

# ----- TERMINAL WINDOWS -----
var terminal_windows = []
var active_terminal = 0

# ----- WORD PROCESSING -----
var word_processor = null
var manifested_words = {}
var word_connections = []
var dice_results = {}

# ----- 3D VISUALIZATION -----
var visualizer = null
var current_positions = {}

# ----- GAME STATE -----
var game_state = {
    "score": 0,
    "level": 1,
    "words_processed": 0,
    "realities_created": 0,
    "divine_level": 1
}

# ----- SIGNALS -----
signal turn_advanced(new_turn, symbol, dimension)
signal word_manifested(word_data)
signal reality_created(reality_data)
signal dice_rolled(terminal_id, results, total)
signal terminal_switched(terminal_id)
signal game_state_updated(state)

# ----- INITIALIZATION -----
func _ready():
    print("Word Manifestation Game initializing...")
    initialize_word_processor()
    initialize_terminals()
    
    # Connect to turn system
    var turn_file_path = "user://current_turn.txt"
    var dir = Directory.new()
    if dir.file_exists(turn_file_path):
        var file = File.new()
        file.open(turn_file_path, File.READ)
        var turn_str = file.get_line()
        file.close()
        
        if turn_str.is_valid_integer():
            current_turn = int(turn_str)
            if current_turn < 1 or current_turn > MAX_TURNS:
                current_turn = 3  # Default to 3D space
    
    print("Word Manifestation Game initialized at Turn %d (%s - %s)" % 
        [current_turn, turn_symbols[current_turn-1], turn_dimensions[current_turn-1]])
    
    # Initial game state update
    update_game_state()

# Initialize word processor
func initialize_word_processor():
    word_processor = DivineWordProcessor.new()
    add_child(word_processor)
    
    # Connect signals
    word_processor.connect("word_processed", self, "_on_word_processed")
    word_processor.connect("reality_created", self, "_on_reality_created")
    word_processor.connect("divine_level_changed", self, "_on_divine_level_changed")
    
    print("Word processor initialized with %d divine words" % word_processor.word_power_dictionary.size())

# Initialize terminal windows
func initialize_terminals():
    for i in range(MAX_TERMINAL_WINDOWS):
        var terminal = {
            "id": i,
            "name": "Terminal %d" % (i + 1),
            "content": "",
            "word_history": [],
            "dice_results": [],
            "color": Color(0.1, 0.3 + (i * 0.1), 0.6),
            "active": i == active_terminal
        }
        
        terminal_windows.append(terminal)
    
    print("Initialized %d terminal windows" % terminal_windows.size())

# ----- TURN MANAGEMENT -----
func advance_turn():
    current_turn = (current_turn % MAX_TURNS) + 1
    
    # Save current turn
    var turn_file_path = "user://current_turn.txt"
    var file = File.new()
    file.open(turn_file_path, File.WRITE)
    file.store_line(str(current_turn))
    file.close()
    
    # Update all terminals with turn change message
    for i in range(terminal_windows.size()):
        add_terminal_message(i, "=======================")
        add_terminal_message(i, "TURN ADVANCED TO %d: %s" % [current_turn, turn_phases[current_turn-1]])
        add_terminal_message(i, "Symbol: %s - Dimension: %s" % [turn_symbols[current_turn-1], turn_dimensions[current_turn-1]])
        add_terminal_message(i, "=======================")
    
    # Special dimension-specific effects
    match current_turn:
        1:  # 1D - Point
            add_terminal_message(active_terminal, "In the 1D Point dimension, all creation stems from a single point.")
        2:  # 2D - Line
            add_terminal_message(active_terminal, "The 2D Line dimension allows connections between points.")
        3:  # 3D - Space
            add_terminal_message(active_terminal, "Welcome to 3D Space, where objects can be positioned and manipulated.")
        4:  # 4D - Time
            add_terminal_message(active_terminal, "The 4D Time dimension introduces causality and change.")
        5:  # 5D - Consciousness
            add_terminal_message(active_terminal, "In 5D Consciousness, awareness and perception emerge.")
        6:  # 6D - Connection
            add_terminal_message(active_terminal, "The 6D Connection dimension reveals relationships between all things.")
        7:  # 7D - Creation
            add_terminal_message(active_terminal, "In 7D Creation, thoughts manifest into reality.")
        8:  # 8D - Network
            add_terminal_message(active_terminal, "The 8D Network connects all created elements into systems.")
        9:  # 9D - Harmony
            add_terminal_message(active_terminal, "In 9D Harmony, all elements find perfect balance.")
        10: # 10D - Unity
            add_terminal_message(active_terminal, "The 10D Unity dimension reveals the oneness of all creation.")
        11: # 11D - Transcendence
            add_terminal_message(active_terminal, "In 11D Transcendence, limitations dissolve and evolution accelerates.")
        12: # 12D - Beyond
            add_terminal_message(active_terminal, "The 12D Beyond prepares for the next cycle of creation.")
    
    # Reset dice results for new turn
    dice_results = {}
    
    # Emit signal
    emit_signal("turn_advanced", current_turn, turn_symbols[current_turn-1], turn_dimensions[current_turn-1])
    
    # Roll dice for new turn automatically
    roll_dice_all_terminals()
    
    return {
        "turn": current_turn,
        "symbol": turn_symbols[current_turn-1],
        "dimension": turn_dimensions[current_turn-1],
        "phase": turn_phases[current_turn-1],
        "concept": turn_concepts[current_turn-1]
    }

# Switch active terminal
func switch_terminal(terminal_id):
    if terminal_id >= 0 and terminal_id < terminal_windows.size():
        # Update active status
        terminal_windows[active_terminal].active = false
        active_terminal = terminal_id
        terminal_windows[active_terminal].active = true
        
        # Add message
        add_terminal_message(active_terminal, "--- Terminal %d activated ---" % (active_terminal + 1))
        
        # Emit signal
        emit_signal("terminal_switched", active_terminal)
        
        return terminal_windows[active_terminal]
    
    return null

# ----- WORD PROCESSING -----
func process_text(text, terminal_id=null):
    if terminal_id == null:
        terminal_id = active_terminal
    
    # Process the text
    var result = word_processor.process_text(text)
    
    # Add to terminal history
    if terminal_id >= 0 and terminal_id < terminal_windows.size():
        add_terminal_message(terminal_id, "> " + text)
        
        # Add messages for powerful words
        if result.powerful_words.size() > 0:
            add_terminal_message(terminal_id, "Powerful words detected:")
            for word_data in result.powerful_words:
                add_terminal_message(terminal_id, "- '%s' (Power: %d)" % [word_data.word, word_data.power])
            
            add_terminal_message(terminal_id, "Total power: %d" % result.total_power)
        
        # Add to word history
        terminal_windows[terminal_id].word_history.append({
            "text": result.corrected,
            "timestamp": OS.get_unix_time(),
            "power": result.total_power,
            "powerful_words": result.powerful_words
        })
    
    # Handle reality creation if powerful enough
    if result.total_power > WORD_POWER_THRESHOLD:
        # Manifest words in 3D space
        for word_data in result.powerful_words:
            manifest_word(word_data.word, word_data.power, terminal_id)
    
    # Update game state
    game_state.words_processed += result.word_count
    game_state.score += int(result.total_power / 10)
    update_game_state()
    
    return result

# Manifest a powerful word in the game world
func manifest_word(word, power, terminal_id):
    # Create unique ID for this word
    var word_id = "word_" + str(OS.get_unix_time()) + "_" + str(randi() % 10000)
    
    # Determine color based on terminal
    var color = terminal_windows[terminal_id].color
    
    # Determine position based on turn/dimension
    var position = generate_position_for_dimension(current_turn)
    
    # Word size based on power
    var size = Vector3(0.5, 0.5, 0.5) * (1.0 + (power / 100.0))
    
    # Create word data
    var word_data = {
        "id": word_id,
        "text": word,
        "power": power,
        "position": position,
        "rotation": Vector3(randf() * PI, randf() * PI, randf() * PI),
        "color": color,
        "size": size,
        "terminal_id": terminal_id,
        "turn": current_turn,
        "dimension": turn_dimensions[current_turn-1],
        "symbol": turn_symbols[current_turn-1],
        "timestamp": OS.get_unix_time(),
        "evolution_stage": 1
    }
    
    # Store in manifested words
    manifested_words[word_id] = word_data
    
    # Add to terminal
    add_terminal_message(terminal_id, "Word '%s' manifested in %s with power %d" % 
        [word, turn_dimensions[current_turn-1], power])
    
    # Check for connections with other manifested words
    create_word_connections(word_data)
    
    # Check if enough power to create reality
    check_reality_formation()
    
    # Emit signal
    emit_signal("word_manifested", word_data)
    
    return word_data

# Generate appropriate position based on dimension
func generate_position_for_dimension(turn_number):
    var position = Vector3()
    
    match turn_number:
        1:  # 1D - Point
            # All at origin
            position = Vector3(0, 0, 0)
        2:  # 2D - Line
            # Only x-axis has meaning
            position = Vector3(rand_range(-10, 10), 0, 0)
        3:  # 3D - Space
            # Full 3D positioning
            position = Vector3(
                rand_range(-10, 10),
                rand_range(-5, 5),
                rand_range(-10, 10)
            )
        4:  # 4D - Time
            # 3D + time (simulate with animation paths)
            position = Vector3(
                rand_range(-10, 10),
                rand_range(-5, 5),
                rand_range(-10, 10)
            )
            # Store time path
            current_positions[position] = {
                "path": "time_oscillation",
                "amplitude": Vector3(rand_range(1, 3), rand_range(1, 3), rand_range(1, 3)),
                "frequency": rand_range(0.5, 2.0)
            }
        5:  # 5D - Consciousness
            # Position reflects awareness (height = consciousness level)
            position = Vector3(
                rand_range(-10, 10),
                rand_range(3, 10),  # Higher consciousness
                rand_range(-10, 10)
            )
        _:  # Other dimensions
            # For higher dimensions, use 3D representation with special effects
            position = Vector3(
                rand_range(-10, 10),
                rand_range(-5, 5),
                rand_range(-10, 10)
            )
    
    return position

# Create connections between manifested words
func create_word_connections(new_word_data):
    # Skip if no visualizer
    if visualizer == null:
        return
    
    for word_id in manifested_words:
        # Skip self-connection
        if word_id == new_word_data.id:
            continue
        
        var existing_word = manifested_words[word_id]
        
        # Calculate connection probability based on:
        # 1. Word power (higher = more connections)
        # 2. Terminal source (same terminal = more likely to connect)
        # 3. Turn/dimension compatibility
        
        var power_factor = (new_word_data.power + existing_word.power) / (2 * WORD_POWER_THRESHOLD)
        var terminal_factor = 1.0 if new_word_data.terminal_id == existing_word.terminal_id else 0.5
        var turn_factor = 1.0 - (abs(new_word_data.turn - existing_word.turn) / float(MAX_TURNS))
        
        var connection_probability = power_factor * terminal_factor * turn_factor
        
        # Roll for connection
        if randf() < connection_probability:
            # Create connection
            var connection_id = "conn_" + new_word_data.id + "_" + existing_word.id
            
            # Calculate strength and color
            var strength = (new_word_data.power + existing_word.power) / 200.0
            strength = clamp(strength, 0.1, 1.0)
            
            # Mix colors
            var connection_color = new_word_data.color.linear_interpolate(existing_word.color, 0.5)
            
            # Create connection data
            var connection_data = {
                "id": connection_id,
                "word1_id": new_word_data.id,
                "word2_id": existing_word.id,
                "strength": strength,
                "color": connection_color,
                "timestamp": OS.get_unix_time(),
                "turn": current_turn
            }
            
            # Add to connections list
            word_connections.append(connection_data)
            
            # Add message to both terminals
            add_terminal_message(new_word_data.terminal_id, 
                "Connection formed: '%s' ↔ '%s' (Strength: %.2f)" % 
                [new_word_data.text, existing_word.text, strength])
            
            if new_word_data.terminal_id != existing_word.terminal_id:
                add_terminal_message(existing_word.terminal_id, 
                    "Connection formed: '%s' ↔ '%s' (Strength: %.2f)" % 
                    [existing_word.text, new_word_data.text, strength])
        }
    }
}

# Check if enough powerful words to form a reality
func check_reality_formation():
    # Calculate total power of all manifested words
    var total_power = 0
    for word_id in manifested_words:
        total_power += manifested_words[word_id].power
    
    # Check if we've reached reality threshold
    if total_power > REALITY_THRESHOLD:
        # Create reality
        var reality_id = "reality_" + str(OS.get_unix_time())
        
        var reality_data = {
            "id": reality_id,
            "power": total_power,
            "word_count": manifested_words.size(),
            "connection_count": word_connections.size(),
            "turn": current_turn,
            "dimension": turn_dimensions[current_turn-1],
            "symbol": turn_symbols[current_turn-1],
            "timestamp": OS.get_unix_time(),
            "terminal_contributions": get_terminal_contributions()
        }
        
        # Announce to all terminals
        for i in range(terminal_windows.size()):
            add_terminal_message(i, "=======================")
            add_terminal_message(i, "REALITY FORMED IN %s!" % turn_dimensions[current_turn-1])
            add_terminal_message(i, "Power: %d | Words: %d | Connections: %d" % 
                [total_power, manifested_words.size(), word_connections.size()])
            add_terminal_message(i, "=======================")
        
        # Update game state
        game_state.realities_created += 1
        game_state.score += total_power
        game_state.level += 1
        update_game_state()
        
        # Apply special effects based on turn
        apply_reality_effects(reality_data)
        
        # Emit signal
        emit_signal("reality_created", reality_data)
        
        return reality_data
    }
    
    return null
}

# Get contribution percentages by terminal
func get_terminal_contributions():
    var contributions = {}
    var total_power = 0
    
    # Calculate total power first
    for word_id in manifested_words:
        total_power += manifested_words[word_id].power
    
    if total_power <= 0:
        return contributions
    
    # Initialize all terminals with zero
    for i in range(terminal_windows.size()):
        contributions[i] = 0
    
    # Calculate each terminal's contribution
    for word_id in manifested_words:
        var terminal_id = manifested_words[word_id].terminal_id
        var word_power = manifested_words[word_id].power
        
        if not contributions.has(terminal_id):
            contributions[terminal_id] = 0
        
        contributions[terminal_id] += word_power / float(total_power)
    
    return contributions
}

# Apply special effects based on the turn the reality was formed in
func apply_reality_effects(reality_data):
    # Different effects based on dimension
    match reality_data.turn:
        1:  # 1D - Point
            # Converge all words to a single point temporarily
            # Implementation would depend on visualizer
            pass
        2:  # 2D - Line
            # Align all words to a line
            pass
        3:  # 3D - Space
            # Create a spatial arrangement showcasing all words
            pass
        4:  # 4D - Time
            # Create time effects - words pulsating or moving in patterns
            pass
        5:  # 5D - Consciousness
            # Words become more intelligent - start to self-organize
            evolve_all_words()
        6:  # 6D - Connection
            # Enhance all connections, create new ones
            enhance_connections()
        7:  # 7D - Creation
            # Words gain ability to spawn new words
            spawn_echo_words()
        _:  # Other dimensions
            # Generic enhancement
            evolve_all_words()
}

# Evolve all manifested words
func evolve_all_words():
    for word_id in manifested_words:
        var word_data = manifested_words[word_id]
        
        # Increment evolution stage
        word_data.evolution_stage += 1
        
        # Cap at stage 5
        if word_data.evolution_stage > 5:
            word_data.evolution_stage = 5
        
        # Announce in relevant terminal
        add_terminal_message(word_data.terminal_id, 
            "Word '%s' evolved to stage %d!" % [word_data.text, word_data.evolution_stage])
        
        # Update in dictionary
        manifested_words[word_id] = word_data
    }
}

# Enhance all connections
func enhance_connections():
    for connection in word_connections:
        # Increase strength
        connection.strength = min(connection.strength * 1.5, 1.0)
    }
}

# Spawn echo words from existing words
func spawn_echo_words():
    var original_word_count = manifested_words.size()
    var words_to_echo = []
    
    # Collect words to echo
    for word_id in manifested_words:
        if randf() < 0.3:  # 30% chance to echo
            words_to_echo.append(manifested_words[word_id])
    
    # Create echo words
    for word_data in words_to_echo:
        var echo_text = "echo_" + word_data.text
        var echo_power = word_data.power * 0.7
        manifest_word(echo_text, echo_power, word_data.terminal_id)
    }
    
    # Announce
    var new_words = manifested_words.size() - original_word_count
    if new_words > 0:
        add_terminal_message(active_terminal, "%d echo words spawned from existing words" % new_words)
    }
}

# ----- DICE SYSTEM -----
func roll_dice(terminal_id=null, dice_type=null, dice_count=null):
    if terminal_id == null:
        terminal_id = active_terminal
    
    # Determine dice type based on current turn if not specified
    if dice_type == null:
        # Different dice types for different dimensions
        var dice_by_turn = [4, 6, 8, 10, 12, 20, 100, 12, 10, 8, 6, 4]
        dice_type = dice_by_turn[current_turn - 1]
    
    # Default dice count
    if dice_count == null:
        dice_count = 2
    
    # Generate dice rolls
    var rolls = []
    var total = 0
    
    for i in range(dice_count):
        var roll = 1 + (randi() % dice_type)
        rolls.append(roll)
        total += roll
    }
    
    # Apply turn bonus
    var turn_bonus = current_turn - 1
    var final_total = total + turn_bonus
    
    # Create result data
    var result = {
        "terminal_id": terminal_id,
        "dice_type": dice_type,
        "dice_count": dice_count,
        "rolls": rolls,
        "total": total,
        "turn_bonus": turn_bonus,
        "final_total": final_total,
        "timestamp": OS.get_unix_time()
    }
    
    # Store result
    dice_results[terminal_id] = result
    
    # Add to terminal history
    terminal_windows[terminal_id].dice_results.append(result)
    
    # Add message to terminal
    add_terminal_message(terminal_id, "----- DICE ROLL -----")
    add_terminal_message(terminal_id, "Rolling %dd%d: %s" % [dice_count, dice_type, str(rolls)])
    add_terminal_message(terminal_id, "Total: %d + Turn Bonus (%d) = %d" % [total, turn_bonus, final_total])
    
    # Emit signal
    emit_signal("dice_rolled", terminal_id, rolls, final_total)
    
    return result
}

# Roll dice on all terminals
func roll_dice_all_terminals(dice_type=null, dice_count=null):
    var all_results = []
    var grand_total = 0
    
    for i in range(terminal_windows.size()):
        var result = roll_dice(i, dice_type, dice_count)
        all_results.append(result)
        grand_total += result.final_total
    }
    
    # Check for "blimp" - when all terminals roll the same number
    check_for_blimp(all_results)
    
    # Add grand total message to active terminal
    add_terminal_message(active_terminal, "----- MULTI-TERMINAL ROLL -----")
    add_terminal_message(active_terminal, "Grand Total across all terminals: %d" % grand_total)
    
    # Update game state
    game_state.score += int(grand_total / 10)
    update_game_state()
    
    return {
        "results": all_results,
        "grand_total": grand_total
    }
}

# Check for "blimp" - when all terminals roll the same total
func check_for_blimp(results):
    if results.size() <= 1:
        return false
    
    var first_total = results[0].total
    var is_blimp = true
    
    for i in range(1, results.size()):
        if results[i].total != first_total:
            is_blimp = false
            break
    }
    
    if is_blimp:
        # Time blimp detected!
        for i in range(terminal_windows.size()):
            add_terminal_message(i, "!!! TIME BLIMP DETECTED !!!")
            add_terminal_message(i, "All terminals synchronized at value: " + str(first_total))
            add_terminal_message(i, "Reality may be experiencing temporal anomalies")
        }
        
        # Special effect - advance turn and apply bonus
        advance_turn()
        
        # Apply power bonus to all manifested words
        for word_id in manifested_words:
            manifested_words[word_id].power += first_total
            add_terminal_message(manifested_words[word_id].terminal_id, 
                "Word '%s' power increased by %d due to time blimp!" % 
                [manifested_words[word_id].text, first_total])
        }
        
        return true
    }
    
    return false
}

# ----- TERMINAL MANAGEMENT -----
func add_terminal_message(terminal_id, message):
    if terminal_id >= 0 and terminal_id < terminal_windows.size():
        # Add timestamp
        var timestamp = OS.get_time()
        var time_str = "%02d:%02d:%02d" % [timestamp.hour, timestamp.minute, timestamp.second]
        
        # Format message
        var formatted = "[%s] %s" % [time_str, message]
        
        # Add to terminal content
        terminal_windows[terminal_id].content += formatted + "\n"
        
        # Trim if too long
        var lines = terminal_windows[terminal_id].content.split("\n")
        if lines.size() > 100:  # Keep last 100 lines
            terminal_windows[terminal_id].content = ""
            for i in range(lines.size() - 100, lines.size()):
                if i >= 0 and i < lines.size():
                    terminal_windows[terminal_id].content += lines[i] + "\n"
        }
        
        return formatted
    }
    
    return null
}

func get_terminal_content(terminal_id):
    if terminal_id >= 0 and terminal_id < terminal_windows.size():
        return terminal_windows[terminal_id].content
    }
    
    return ""
}

func clear_terminal(terminal_id):
    if terminal_id >= 0 and terminal_id < terminal_windows.size():
        terminal_windows[terminal_id].content = ""
        
        # Add initial message
        add_terminal_message(terminal_id, "Terminal cleared")
        add_terminal_message(terminal_id, "Turn %d: %s - %s" % 
            [current_turn, turn_symbols[current_turn-1], turn_dimensions[current_turn-1]])
        
        return true
    }
    
    return false
}

# ----- VISUALIZATION INTEGRATION -----
func set_visualizer(vis_node):
    visualizer = vis_node
    
    if visualizer:
        # Connect signals
        visualizer.connect("visualization_ready", self, "_on_visualization_ready")
        visualizer.connect("word_selected", self, "_on_visualizer_word_selected")
        
        print("Connected to 3D visualizer")
    }
}

# ----- GAME STATE MANAGEMENT -----
func update_game_state():
    # Update divine level from word processor
    var divine_status = word_processor.get_divine_status()
    game_state.divine_level = divine_status.level
    
    # Emit signal
    emit_signal("game_state_updated", game_state)
    
    return game_state
}

func save_game_state(name="auto_save"):
    var save_data = {
        "game_state": game_state,
        "current_turn": current_turn,
        "manifested_words": manifested_words,
        "word_connections": word_connections,
        "terminal_windows": terminal_windows,
        "timestamp": OS.get_unix_time(),
        "date": OS.get_datetime()
    }
    
    # Save to file
    var file = File.new()
    var save_path = "user://word_game_saves/" + name + "_" + str(OS.get_unix_time()) + ".json"
    
    # Ensure directory exists
    var dir = Directory.new()
    if !dir.dir_exists("user://word_game_saves"):
        dir.make_dir_recursive("user://word_game_saves")
    }
    
    # Save file
    file.open(save_path, File.WRITE)
    file.store_string(JSON.print(save_data, "  "))
    file.close()
    
    print("Game state saved as '%s'" % name)
    print("Save location: %s" % save_path)
    
    return save_data
}

# ----- DATA ACCESS METHODS -----
func get_word_list():
    return manifested_words
}

func get_connection_list():
    return word_connections
}

func get_terminal_list():
    return terminal_windows
}

func get_current_turn_info():
    return {
        "turn": current_turn,
        "symbol": turn_symbols[current_turn-1],
        "dimension": turn_dimensions[current_turn-1],
        "phase": turn_phases[current_turn-1],
        "concept": turn_concepts[current_turn-1]
    }
}

# ----- SIGNAL HANDLERS -----
func _on_word_processed(word, power):
    # Word was processed by the divine word processor
    pass
}

func _on_reality_created(reality_data):
    # Reality was created
    game_state.realities_created += 1
    update_game_state()
}

func _on_divine_level_changed(new_level):
    # Divine level changed
    game_state.divine_level = new_level
    update_game_state()
    
    add_terminal_message(active_terminal, "Divine Level increased to %d!" % new_level)
}

func _on_visualization_ready():
    # Visualizer is ready
    print("3D Visualizer is ready")
    
    # Populate with existing words
    for word_id in manifested_words:
        emit_signal("word_manifested", manifested_words[word_id])
    }
}

func _on_visualizer_word_selected(word_data):
    # Word was selected in visualizer
    add_terminal_message(active_terminal, "Selected word: '%s' (Power: %d)" % [word_data.text, word_data.power])
}

# ----- PUBLIC API -----
# Process text from a terminal
func process_terminal_input(text, terminal_id=null):
    return process_text(text, terminal_id)
}

# Roll dice from a terminal
func roll_terminal_dice(terminal_id=null, dice_type=null, dice_count=null):
    return roll_dice(terminal_id, dice_type, dice_count)
}

# Get game status info
func get_game_status():
    return {
        "game_state": game_state,
        "current_turn": current_turn,
        "turn_info": get_current_turn_info(),
        "active_terminal": active_terminal,
        "word_count": manifested_words.size(),
        "connection_count": word_connections.size(),
        "divine_level": game_state.divine_level
    }
}