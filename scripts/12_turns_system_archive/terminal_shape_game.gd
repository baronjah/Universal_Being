extends Node

# Terminal Shape Game
# Integrates the terminal systems into a complete game
# Handles shape generation, special effects, and game state

class_name TerminalShapeGame

# ----- GAME STATES -----
enum GameState {
    MENU,
    CREATE_MODE,
    PLAY_MODE,
    EDIT_MODE,
    MIRACULOUS_MODE,
    TIME_SHIFT_MODE
}

# ----- SPECIAL FUNCTION KEYS -----
enum FunctionKey {
    CREATE = 0,
    EDIT = 1,
    SAVE = 2,
    LOAD = 3,
    SHIFT = 4,
    MIRACLE = 5,
    TIME = 6,
    CORE = 7,
    HELP = 8
}

# ----- GAME PROPERTIES -----
var current_state = GameState.MENU
var current_level = 1
var current_shape_id = -1
var player_position = Vector2(0, 0)
var score = 0
var move_count = 0
var miracle_count = 0
var time_shifts = 0
var saved_shapes = {}
var shape_history = []
var function_keys_active = {}

# ----- TIME MANAGEMENT -----
enum TimeState {
    PAST,
    PRESENT,
    FUTURE,
    TIMELESS
}
var current_time_state = TimeState.PRESENT
var time_remaining = 300.0  # 5 minutes
var turn_duration = 9.0  # Sacred 9-second interval
var turn_timer = 0.0

# ----- SYSTEM INTEGRATION -----
var dual_core_terminal = null
var terminal_api_bridge = null
var terminal_grid_creator = null
var divine_word_game = null
var turn_system = null
var word_comment_system = null

# ----- SIGNALS -----
signal game_state_changed(old_state, new_state)
signal shape_created(shape_id, category, pattern)
signal shape_edited(shape_id, new_pattern)
signal shape_saved(shape_id, name)
signal shape_loaded(shape_id, name)
signal player_moved(old_position, new_position)
signal miracle_triggered(count)
signal time_shifted(old_state, new_state)
signal level_completed(level, score)
signal core_switched(old_core, new_core)
signal turn_advanced(turn_number)

# ----- INITIALIZATION -----
func _ready():
    print("Terminal Shape Game initializing...")
    
    # Connect to all required systems
    _connect_to_systems()
    
    # Initialize function keys
    for key in FunctionKey:
        function_keys_active[FunctionKey[key]] = true
    
    # Reset game state
    reset_game()
    
    print("Terminal Shape Game initialized")
    print("Current state: " + GameState.keys()[current_state])

func _connect_to_systems():
    # Connect to DualCoreTerminal
    dual_core_terminal = get_node_or_null("/root/DualCoreTerminal")
    if dual_core_terminal:
        dual_core_terminal.connect("input_processed", self, "_on_terminal_input_processed")
        dual_core_terminal.connect("core_switched", self, "_on_core_switched")
        dual_core_terminal.connect("special_pattern_detected", self, "_on_special_pattern_detected")
        dual_core_terminal.connect("miracle_triggered", self, "_on_miracle_triggered")
        dual_core_terminal.connect("time_state_changed", self, "_on_time_state_changed")
        dual_core_terminal.connect("snake_case_detected", self, "_on_snake_case_detected")
    
    # Connect to TerminalAPIBridge
    terminal_api_bridge = get_node_or_null("/root/TerminalAPIBridge")
    
    # Connect to TerminalGridCreator
    terminal_grid_creator = get_node_or_null("/root/TerminalGridCreator")
    if terminal_grid_creator:
        terminal_grid_creator.connect("grid_created", self, "_on_grid_created")
        terminal_grid_creator.connect("grid_element_added", self, "_on_grid_element_added")
        terminal_grid_creator.connect("special_pattern_detected", self, "_on_special_pattern_detected")
        terminal_grid_creator.connect("miracle_portal_created", self, "_on_miracle_portal_created")
    
    # Connect to divine word game
    divine_word_game = get_node_or_null("/root/DivineWordGame")
    if divine_word_game:
        divine_word_game.connect("word_target_completed", self, "_on_word_target_completed")
    
    # Connect to turn system
    turn_system = get_node_or_null("/root/TurnSystem")
    if turn_system:
        turn_system.connect("turn_advanced", self, "_on_turn_advanced")
        turn_system.connect("dimension_changed", self, "_on_dimension_changed")
    
    # Connect to word comment system
    word_comment_system = get_node_or_null("/root/WordCommentSystem")

# ----- PROCESSING -----
func _process(delta):
    # Process turn timer for the sacred 9-second interval
    turn_timer += delta
    
    if turn_timer >= turn_duration:
        turn_timer = 0
        _on_turn_interval_complete()
    
    # Process game time
    if current_state == GameState.PLAY_MODE:
        time_remaining -= delta
        
        if time_remaining <= 0:
            _on_time_expired()

# ----- GAME STATE MANAGEMENT -----
func reset_game():
    current_state = GameState.MENU
    current_level = 1
    current_shape_id = -1
    player_position = Vector2(0, 0)
    score = 0
    move_count = 0
    miracle_count = 0
    time_shifts = 0
    time_remaining = 300.0
    current_time_state = TimeState.PRESENT
    
    # Reset history
    shape_history = []
    
    # Create initial shapes if grid creator is available
    if terminal_grid_creator:
        terminal_grid_creator.create_grid(80, 24, ".")
    
    print("Game reset to initial state")

func change_game_state(new_state):
    var old_state = current_state
    current_state = new_state
    
    # Handle state transitions
    match new_state:
        GameState.CREATE_MODE:
            # Enter creation mode
            if terminal_grid_creator:
                terminal_grid_creator.clear_grid()
        
        GameState.PLAY_MODE:
            # Start gameplay timer
            time_remaining = 300.0 # 5 minutes
            
            # Create initial game elements if needed
            if terminal_grid_creator and terminal_grid_creator.get_elements_by_category(terminal_grid_creator.ShapeCategory.ROOM).size() == 0:
                terminal_grid_creator.generate_dungeon(5, 0.7)
            
            # Position player
            _place_player_at_start()
        
        GameState.EDIT_MODE:
            # Enter edit mode for current shape
            pass
        
        GameState.MIRACULOUS_MODE:
            # Enter miraculous mode
            miracle_count += 1
        
        GameState.TIME_SHIFT_MODE:
            # Enter time shift mode
            time_shifts += 1
    
    emit_signal("game_state_changed", old_state, new_state)
    print("Game state changed from " + GameState.keys()[old_state] + " to " + GameState.keys()[new_state])
    
    # Notify word comment system if available
    if word_comment_system:
        word_comment_system.add_comment("game_state",
            "Game state changed to " + GameState.keys()[new_state],
            word_comment_system.CommentType.OBSERVATION, "Shape_Game")
    
    return true

func save_shape(name=""):
    if current_shape_id < 0:
        return false
    
    # Generate a name if none provided
    if name.empty():
        name = "shape_" + str(OS.get_unix_time())
    
    # Get shape from grid creator
    if terminal_grid_creator:
        var element = terminal_grid_creator.get_element(current_shape_id)
        
        if element:
            # Save shape
            saved_shapes[name] = element.duplicate(true)
            
            emit_signal("shape_saved", current_shape_id, name)
            print("Shape saved as: " + name)
            
            return true
    
    return false

func load_shape(name):
    if not saved_shapes.has(name):
        return false
    
    # Load shape
    var shape = saved_shapes[name]
    
    # Place on grid
    if terminal_grid_creator:
        var element_id = terminal_grid_creator.place_pattern(
            shape.x, shape.y, shape.pattern, shape.category, shape.properties
        )
        
        if element_id >= 0:
            current_shape_id = element_id
            
            emit_signal("shape_loaded", element_id, name)
            print("Shape loaded: " + name)
            
            return true
    
    return false

func complete_level():
    # Save current level
    save_shape("level_" + str(current_level) + "_completion")
    
    # Calculate level score
    var level_score = score + (time_remaining > 0 ? int(time_remaining / 10) : 0)
    
    # Apply miracle bonus
    level_score += miracle_count * 100
    
    emit_signal("level_completed", current_level, level_score)
    print("Level " + str(current_level) + " completed with score: " + str(level_score))
    
    # Increment level
    current_level += 1
    
    # Reset timer for next level
    time_remaining = 300.0 + (current_level * 60.0) # More time for higher levels
    
    # Notify word comment system if available
    if word_comment_system:
        word_comment_system.add_comment("level_completed",
            "Level " + str(current_level - 1) + " completed! Score: " + str(level_score),
            word_comment_system.CommentType.DIVINE, "Shape_Game")
    
    # Return to menu state
    change_game_state(GameState.MENU)
    
    return level_score

# ----- SHAPE CREATION -----
func create_shape(pattern, category, properties={}):
    if terminal_grid_creator:
        # Find a suitable location for the shape
        var grid_size = terminal_grid_creator.get_grid_size()
        var x = randi() % int(grid_size.x / 2) + int(grid_size.x / 4)
        var y = randi() % int(grid_size.y / 2) + int(grid_size.y / 4)
        
        // Place the pattern
        var element_id = terminal_grid_creator.place_pattern(x, y, pattern, category, properties)
        
        if element_id >= 0:
            current_shape_id = element_id
            
            // Add to history
            shape_history.append({
                "id": element_id,
                "pattern": pattern,
                "category": category,
                "timestamp": OS.get_unix_time()
            })
            
            emit_signal("shape_created", element_id, category, pattern)
            print("Shape created with ID: " + str(element_id))
            
            // Try to process the pattern for special effects
            _check_pattern_for_special_effects(pattern)
            
            return element_id
    
    return -1

func _check_pattern_for_special_effects(pattern):
    // Check for miracle pattern
    if pattern.find("#$%$#@@") >= 0:
        _trigger_miracle()
    
    // Check if pattern has snake_case format
    if "_" in pattern:
        var snake_case = pattern.strip_edges()
        var is_snake_case = true
        
        for i in range(snake_case.length()):
            var c = snake_case[i]
            if c != "_" and not (c >= "a" and c <= "z") and not (c >= "A" and c <= "Z") and not (c >= "0" and c <= "9"):
                is_snake_case = false
                break
        
        if is_snake_case:
            // Handle snake case pattern
            if dual_core_terminal:
                dual_core_terminal.emit_signal("snake_case_detected", pattern, pattern.to_lower())
    
    // Check for time-related patterns
    if pattern.find("/*\\") >= 0:
        _shift_time_state(TimeState.FUTURE)
    elif pattern.find("<->") >= 0:
        _shift_time_state(TimeState.TIMELESS)

func edit_shape(shape_id, new_pattern):
    if not terminal_grid_creator:
        return false
    
    var element = terminal_grid_creator.get_element(shape_id)
    
    if not element:
        return false
    
    // First remove the old element
    terminal_grid_creator.remove_element(shape_id)
    
    // Then place the new pattern at the same location
    var element_id = terminal_grid_creator.place_pattern(
        element.x, element.y, new_pattern, element.category, element.properties
    )
    
    if element_id >= 0:
        current_shape_id = element_id
        
        emit_signal("shape_edited", element_id, new_pattern)
        print("Shape edited: " + str(shape_id) + " -> " + str(element_id))
        
        return true
    
    return false

# ----- PLAYER MOVEMENT -----
func move_player(direction):
    if current_state != GameState.PLAY_MODE:
        return false
    
    var old_position = player_position
    var new_position = player_position
    
    // Calculate new position
    match direction:
        "up":
            new_position.y -= 1
        "down":
            new_position.y += 1
        "left":
            new_position.x -= 1
        "right":
            new_position.x += 1
    
    // Check if the move is valid
    if _is_valid_move(new_position):
        // Update player position
        player_position = new_position
        move_count += 1
        
        // Update player on grid
        if terminal_grid_creator:
            // Remove player from old position
            terminal_grid_creator.place_symbol(old_position.x, old_position.y, ".", -1)
            
            // Place player at new position
            terminal_grid_creator.place_symbol(new_position.x, new_position.y, "@", -1, {"type": "player"})
        
        emit_signal("player_moved", old_position, new_position)
        
        // Check for special tiles at new position
        _check_player_position()
        
        return true
    
    return false

func _is_valid_move(position):
    if not terminal_grid_creator:
        return false
    
    // Check bounds
    var grid_size = terminal_grid_creator.get_grid_size()
    if position.x < 0 or position.x >= grid_size.x or position.y < 0 or position.y >= grid_size.y:
        return false
    
    // Check if cell is walkable
    var cell = terminal_grid_creator.get_cell(position.x, position.y)
    if not cell:
        return false
    
    // Check if symbol is walkable
    var symbol = cell.symbol
    var non_walkable_symbols = ["#", "+", "-", "|", "\\", "/"]
    
    return not (symbol in non_walkable_symbols)

func _place_player_at_start():
    if not terminal_grid_creator:
        return
    
    // Look for player start position
    var grid_size = terminal_grid_creator.get_grid_size()
    var found = false
    
    // First try to find [@] start marker
    for y in range(grid_size.y):
        for x in range(grid_size.x):
            var cell = terminal_grid_creator.get_cell(x, y)
            if cell and cell.symbol == "@":
                player_position = Vector2(x, y)
                found = true
                break
        
        if found:
            break
    
    // If not found, use a default position
    if not found:
        player_position = Vector2(grid_size.x / 2, grid_size.y / 2)
        
        // Try to find a valid position near the center
        for dy in range(-5, 6):
            for dx in range(-5, 6):
                var pos = Vector2(grid_size.x / 2 + dx, grid_size.y / 2 + dy)
                if _is_valid_move(pos):
                    player_position = pos
                    found = true
                    break
            
            if found:
                break
    
    // Place player at position
    if terminal_grid_creator:
        terminal_grid_creator.place_symbol(player_position.x, player_position.y, "@", -1, {"type": "player"})
    
    print("Player placed at: " + str(player_position))

func _check_player_position():
    if not terminal_grid_creator:
        return
    
    var cell = terminal_grid_creator.get_cell(player_position.x, player_position.y)
    
    if cell:
        // Check for special effects
        if cell.properties.has("type"):
            match cell.properties.type:
                "miracle_portal":
                    _trigger_miracle()
                
                "teleporter":
                    // Teleport to destination
                    if cell.properties.has("destination_x") and cell.properties.has("destination_y"):
                        var dest = Vector2(cell.properties.destination_x, cell.properties.destination_y)
                        var old_pos = player_position
                        player_position = dest
                        
                        // Move player on grid
                        terminal_grid_creator.place_symbol(old_pos.x, old_pos.y, ".", -1)
                        terminal_grid_creator.place_symbol(dest.x, dest.y, "@", -1, {"type": "player"})
                        
                        emit_signal("player_moved", old_pos, dest)
                
                "time_rune":
                    // Activate time shift
                    if cell.properties.has("time_state"):
                        _shift_time_state(cell.properties.time_state)
                
                "dimension_gate":
                    // Switch to another dimension
                    if cell.properties.has("target_dimension") and turn_system:
                        turn_system.set_dimension(cell.properties.target_dimension)
                
                "treasure":
                    // Collect treasure
                    score += 50
                    
                    // Remove treasure
                    cell.properties.erase("type")

# ----- SPECIAL EFFECTS -----
func _trigger_miracle():
    miracle_count += 1
    
    // Enter miraculous mode
    change_game_state(GameState.MIRACULOUS_MODE)
    
    // Create a miracle effect in the game
    // This could be a special visual effect, or a gameplay benefit
    if terminal_grid_creator:
        // Create a miracle portal
        var grid_size = terminal_grid_creator.get_grid_size()
        var x = randi() % int(grid_size.x / 2) + int(grid_size.x / 4)
        var y = randi() % int(grid_size.y / 2) + int(grid_size.y / 4)
        
        terminal_grid_creator._create_miracle_portal(x, y)
    
    emit_signal("miracle_triggered", miracle_count)
    print("Miracle triggered! Count: " + str(miracle_count))
    
    // Notify word comment system if available
    if word_comment_system:
        word_comment_system.add_comment("miracle",
            "MIRACLE TRIGGERED in Shape Game! The fabric of reality shifts...",
            word_comment_system.CommentType.DIVINE, "Shape_Game")
    
    return true

func _shift_time_state(new_state):
    if new_state == current_time_state:
        return false
    
    var old_state = current_time_state
    current_time_state = new_state
    time_shifts += 1
    
    // Apply time effects to the grid
    if terminal_grid_creator:
        terminal_grid_creator.apply_time_effect(new_state)
    
    // Apply global time effects
    match new_state:
        TimeState.PAST:
            // In past mode, slow down turn timer
            turn_duration = 12.0 // Slower turns
        
        TimeState.FUTURE:
            // In future mode, speed up turn timer
            turn_duration = 6.0 // Faster turns
        
        TimeState.TIMELESS:
            // In timeless mode, random turn duration
            turn_duration = rand_range(3.0, 15.0)
        
        TimeState.PRESENT:
            // Reset to normal
            turn_duration = 9.0 // Sacred 9-second interval
    
    emit_signal("time_shifted", old_state, new_state)
    print("Time shifted from " + TimeState.keys()[old_state] + " to " + TimeState.keys()[new_state])
    
    // Also update dual core terminal if available
    if dual_core_terminal:
        dual_core_terminal.set_time_state(new_state)
    
    // Notify word comment system if available
    if word_comment_system:
        word_comment_system.add_comment("time_shift",
            "Time shifted to " + TimeState.keys()[new_state] + " state",
            word_comment_system.CommentType.OBSERVATION, "Shape_Game")
    
    return true

# ----- EVENT HANDLERS -----
func _on_terminal_input_processed(core_id, input_text, result):
    // Handle input from the terminal
    
    // Check for game commands
    var lower_text = input_text.to_lower()
    
    if current_state == GameState.CREATE_MODE:
        // In create mode, input becomes shapes
        var category = terminal_grid_creator.ShapeCategory.SPECIAL
        
        if "room" in lower_text:
            category = terminal_grid_creator.ShapeCategory.ROOM
        elif "corridor" in lower_text:
            category = terminal_grid_creator.ShapeCategory.CORRIDOR
        elif "ship" in lower_text:
            category = terminal_grid_creator.ShapeCategory.SHIP
        elif "base" in lower_text:
            category = terminal_grid_creator.ShapeCategory.BASE
        elif "entity" in lower_text:
            category = terminal_grid_creator.ShapeCategory.ENTITY
        
        create_shape(input_text, category, {"source": "terminal_input", "core_id": core_id})
    elif current_state == GameState.PLAY_MODE:
        // In play mode, check for movement commands
        if "up" in lower_text or "north" in lower_text:
            move_player("up")
        elif "down" in lower_text or "south" in lower_text:
            move_player("down")
        elif "left" in lower_text or "west" in lower_text:
            move_player("left")
        elif "right" in lower_text or "east" in lower_text:
            move_player("right")
        
        // Check for function commands
        if "save" in lower_text:
            var name = "shape_" + str(OS.get_unix_time())
            if "save as" in lower_text:
                var parts = lower_text.split("save as ", true, 1)
                if parts.size() > 1:
                    name = parts[1].strip_edges()
            
            save_shape(name)
        elif "load" in lower_text:
            var parts = lower_text.split("load ", true, 1)
            if parts.size() > 1:
                var name = parts[1].strip_edges()
                load_shape(name)
        elif "complete" in lower_text or "finish" in lower_text:
            complete_level()
    elif current_state == GameState.EDIT_MODE:
        // In edit mode, update current shape
        if current_shape_id >= 0:
            edit_shape(current_shape_id, input_text)
    
    // Check for state change commands
    if "create mode" in lower_text:
        change_game_state(GameState.CREATE_MODE)
    elif "play mode" in lower_text:
        change_game_state(GameState.PLAY_MODE)
    elif "edit mode" in lower_text:
        change_game_state(GameState.EDIT_MODE)
    elif "menu" in lower_text:
        change_game_state(GameState.MENU)
    
    // Check for key controls
    var shift_pressed = result.has("shift_pressed") and result.shift_pressed
    var ctrl_pressed = result.has("ctrl_pressed") and result.ctrl_pressed
    var enter_pressed = result.has("enter_pressed") and result.enter_pressed
    
    if shift_pressed and enter_pressed:
        // Shift+Enter triggers miracle
        _trigger_miracle()
    elif ctrl_pressed and enter_pressed:
        // Ctrl+Enter triggers time shift
        var next_state = (current_time_state + 1) % TimeState.size()
        _shift_time_state(next_state)

func _on_core_switched(old_core_id, new_core_id):
    // Handle core switching
    emit_signal("core_switched", old_core_id, new_core_id)
    print("Core switched from " + str(old_core_id) + " to " + str(new_core_id))
    
    // Update UI based on current core
    if current_state == GameState.CREATE_MODE:
        // Different cores might have different shape creation abilities
        // Update available shapes based on current core
        pass

func _on_turn_interval_complete():
    // Called every 9 seconds (sacred interval)
    emit_signal("turn_advanced", move_count)
    
    // Handle different effects based on current state
    match current_state:
        GameState.PLAY_MODE:
            // In play mode, update game elements
            // For example, move NPCs, update environment, etc.
            pass
        
        GameState.MIRACULOUS_MODE:
            // In miraculous mode, create additional miracle effects
            if randf() < 0.3: // 30% chance
                _trigger_miracle()
            else:
                // Return to previous state
                change_game_state(GameState.PLAY_MODE)
        
        GameState.TIME_SHIFT_MODE:
            // In time shift mode, gradually return to present
            if current_time_state != TimeState.PRESENT:
                _shift_time_state(TimeState.PRESENT)
            else:
                // Return to previous state
                change_game_state(GameState.PLAY_MODE)

func _on_time_expired():
    // Game over due to time
    print("Time expired!")
    
    // Calculate final score
    var final_score = score + (miracle_count * 100) - (move_count / 10)
    
    // Handle game over
    if word_comment_system:
        word_comment_system.add_comment("time_expired",
            "Time expired! Final score: " + str(final_score),
            word_comment_system.CommentType.WARNING, "Shape_Game")
    
    // Return to menu
    change_game_state(GameState.MENU)

func _on_special_pattern_detected(pattern, effect):
    // Handle special patterns
    print("Special pattern detected: " + pattern + " -> " + effect)
    
    // Check for specific pattern effects
    if pattern == "#$%$#@@":
        _trigger_miracle()
    elif pattern == "/*\\":
        _shift_time_state(TimeState.FUTURE)
    elif pattern == "<->":
        _shift_time_state(TimeState.TIMELESS)
    elif pattern == "|/\\|":
        if turn_system:
            var current_dim = turn_system.current_dimension
            var next_dim = (current_dim % turn_system.max_turns) + 1
            turn_system.set_dimension(next_dim)

func _on_miracle_triggered(core_id):
    // Handle miracle from terminal
    _trigger_miracle()

func _on_time_state_changed(old_state, new_state):
    // Handle time state change from terminal
    current_time_state = new_state
    
    // Update game based on time state
    if terminal_grid_creator:
        terminal_grid_creator.apply_time_effect(new_state)
    
    emit_signal("time_shifted", old_state, new_state)

func _on_snake_case_detected(text, cleaned_text):
    // Handle snake case detection
    print("Snake case detected: " + cleaned_text)
    
    // Check for special snake cases
    if cleaned_text == "i_might_see":
        // Trigger special effect for I_Might_See
        if current_state != GameState.MIRACULOUS_MODE:
            change_game_state(GameState.MIRACULOUS_MODE)
        
        // Trigger multiple miracles
        for i in range(3):
            _trigger_miracle()
    elif cleaned_text == "time_shift":
        // Trigger time shift
        var next_state = (current_time_state + 1) % TimeState.size()
        _shift_time_state(next_state)
    elif cleaned_text == "complete_level":
        // Complete current level
        complete_level()

func _on_grid_created(grid_id, width, height):
    // Handle grid creation
    print("Grid created: " + grid_id + " (" + str(width) + "x" + str(height) + ")")
    
    // If in play mode, place player
    if current_state == GameState.PLAY_MODE:
        _place_player_at_start()

func _on_grid_element_added(element_id, category, pattern):
    // Handle new grid element
    current_shape_id = element_id
    
    // If in play mode and this is a player start, place player there
    if current_state == GameState.PLAY_MODE and category == terminal_grid_creator.ShapeCategory.ENTITY:
        var element = terminal_grid_creator.get_element(element_id)
        if element and element.pattern == "@":
            player_position = Vector2(element.x, element.y)

func _on_miracle_portal_created(x, y):
    // Handle miracle portal creation
    miracle_count += 1
    emit_signal("miracle_triggered", miracle_count)
    
    // If in play mode, create a special gameplay effect
    if current_state == GameState.PLAY_MODE:
        // For example, reveal hidden areas, or spawn bonus items
        score += 100
    
    // Notify word comment system if available
    if word_comment_system:
        word_comment_system.add_comment("miracle_portal",
            "Miracle Portal created at (" + str(x) + "," + str(y) + ")!",
            word_comment_system.CommentType.DIVINE, "Shape_Game")

func _on_word_target_completed(word, power):
    // Handle word target completion from divine word game
    print("Word target completed: " + word + " (Power: " + str(power) + ")")
    
    // Add bonus score
    score += power
    
    // If power is high enough, trigger special effects
    if power >= 50:
        _trigger_miracle()
    elif power >= 30:
        var next_state = (current_time_state + 1) % TimeState.size()
        _shift_time_state(next_state)

func _on_turn_advanced(old_turn, new_turn):
    // Handle turn advancement
    emit_signal("turn_advanced", new_turn)
    
    // Check for level completion on specific turns
    if new_turn % 12 == 0:
        // Every 12 turns, increase score
        score += 120
        
        // Notify word comment system if available
        if word_comment_system:
            word_comment_system.add_comment("turn_cycle",
                "Turn cycle completed! +120 points",
                word_comment_system.CommentType.OBSERVATION, "Shape_Game")

func _on_dimension_changed(new_dimension, old_dimension):
    // Handle dimension change
    print("Dimension changed from " + str(old_dimension) + "D to " + str(new_dimension) + "D")
    
    // Update game elements based on dimension
    if current_state == GameState.PLAY_MODE and terminal_grid_creator:
        // Create dimension-specific elements
        terminal_grid_creator._add_dimension_elements(new_dimension)
        
        // Reposition player
        _place_player_at_start()
    
    // Every dimension change gives bonus score
    score += new_dimension * 10
    
    // Higher dimensions have more miraculous events
    if new_dimension >= 7 and randf() < 0.3:
        _trigger_miracle()

# ----- PUBLIC API -----
func get_game_state():
    return current_state

func get_current_level():
    return current_level

func get_score():
    return score

func get_time_remaining():
    return time_remaining

func get_miracle_count():
    return miracle_count

func get_current_shape():
    if current_shape_id >= 0 and terminal_grid_creator:
        return terminal_grid_creator.get_element(current_shape_id)
    return null

func get_saved_shapes():
    return saved_shapes.keys()

func get_player_position():
    return player_position

func get_current_time_state():
    return current_time_state

func process_key_command(key):
    // Handle function key presses
    if not function_keys_active.has(key) or not function_keys_active[key]:
        return false
    
    match key:
        FunctionKey.CREATE:
            change_game_state(GameState.CREATE_MODE)
        
        FunctionKey.EDIT:
            change_game_state(GameState.EDIT_MODE)
        
        FunctionKey.SAVE:
            save_shape("quick_save_" + str(OS.get_unix_time()))
        
        FunctionKey.LOAD:
            // Load most recent save if available
            var saves = saved_shapes.keys()
            if saves.size() > 0:
                load_shape(saves[saves.size() - 1])
        
        FunctionKey.SHIFT:
            var next_state = (current_time_state + 1) % TimeState.size()
            _shift_time_state(next_state)
        
        FunctionKey.MIRACLE:
            _trigger_miracle()
        
        FunctionKey.TIME:
            change_game_state(GameState.TIME_SHIFT_MODE)
        
        FunctionKey.CORE:
            // Switch to next core if available
            if dual_core_terminal:
                var current_core = dual_core_terminal.get_current_core_id()
                var cores = dual_core_terminal.get_all_cores()
                
                if cores.size() > 1:
                    var next_index = (cores.find(current_core) + 1) % cores.size()
                    dual_core_terminal.switch_core(cores[next_index])
        
        FunctionKey.HELP:
            // Display help
            if word_comment_system:
                word_comment_system.add_comment("help",
                    "Shape Game Help: CREATE, EDIT, PLAY modes. Use directional commands to move. Create shapes in CREATE mode. Trigger miracles with special patterns like #$%$#@@.",
                    word_comment_system.CommentType.OBSERVATION, "Shape_Game")
    
    return true

func disable_function_key(key):
    if function_keys_active.has(key):
        function_keys_active[key] = false
        return true
    return false

func enable_function_key(key):
    if function_keys_active.has(key):
        function_keys_active[key] = true
        return true
    return false

func generate_random_shape(complexity=1):
    // Generate a random ASCII art shape
    var patterns = []
    
    // Simple patterns
    patterns.append("+-+\n| |\n+-+")  // Box
    patterns.append("/\\\n\\/")       // Diamond
    patterns.append("#####\n#   #\n#####") // Filled box
    patterns.append("  *  \n * * \n*****") // Tree
    
    // Medium patterns
    if complexity >= 2:
        patterns.append("+---+\n|[o]|\n+---+")  // Monitor
        patterns.append(" /\\ \n/  \\\n|  |\n\\__/") // House
        patterns.append(" ____ \n/    \\\n\\____/") // Pill
        patterns.append(" /|\\  \n/ | \\ \n  |  \n / \\ ") // Person
    
    // Complex patterns
    if complexity >= 3:
        patterns.append("  /\\  \n /  \\ \n/====\\\n|    |\n|====|") // Spaceport
        patterns.append(" /\\\n<==>\n \\/") // Ship
        patterns.append("   /\\\n  /  \\\n /    \\\n<======>\n \\    /\n  \\  /\n   \\/") // Large ship
    
    // Choose a random pattern based on complexity
    var pattern = patterns[randi() % patterns.size()]
    
    // Create the shape
    var category = terminal_grid_creator.ShapeCategory.SPECIAL
    return create_shape(pattern, category, {"generated": true, "complexity": complexity})

func get_shape_history(limit=5):
    if shape_history.size() <= limit:
        return shape_history
    
    return shape_history.slice(shape_history.size() - limit, shape_history.size() - 1)

func generate_game_world(world_type="dungeon"):
    if not terminal_grid_creator:
        return ""
    
    var world_id = ""
    
    match world_type:
        "dungeon":
            world_id = terminal_grid_creator.generate_dungeon(5 + current_level, 0.7)
        "space":
            world_id = terminal_grid_creator.generate_space_map(3 + current_level, 2)
        "random":
            if randf() < 0.5:
                world_id = terminal_grid_creator.generate_dungeon(5 + current_level, 0.7)
            else:
                world_id = terminal_grid_creator.generate_space_map(3 + current_level, 2)
    
    // Place player at start
    _place_player_at_start()
    
    return world_id