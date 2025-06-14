extends Node

class_name AutoAgentMode

# Auto Agent Mode for Terminal-Claude Integration
# Enables automatic processing of commands, wishes, and trajectories
# with a focus on word-centric transformations and project reshaping

# ----- CONSTANTS -----
const MAX_TURNS_PER_SESSION = 24
const CORE_WORDS = ["update", "upgrade", "merge", "split", "evolve", "multiply", 
                   "duplicate", "change", "delete", "move", "push", "pull", "boomerang", "yoyo"]
const TRANSFORM_ACTIONS = {
    "update": {"energy": 1, "impact": "incremental", "direction": "forward"},
    "upgrade": {"energy": 2, "impact": "significant", "direction": "upward"},
    "merge": {"energy": 3, "impact": "combinatorial", "direction": "inward"},
    "split": {"energy": 3, "impact": "divisional", "direction": "outward"},
    "evolve": {"energy": 4, "impact": "progressive", "direction": "spiral"},
    "multiply": {"energy": 5, "impact": "exponential", "direction": "radial"},
    "duplicate": {"energy": 2, "impact": "duplicative", "direction": "parallel"},
    "change": {"energy": 1, "impact": "transformative", "direction": "variable"},
    "delete": {"energy": 6, "impact": "destructive", "direction": "null"},
    "move": {"energy": 2, "impact": "relocational", "direction": "vector"},
    "push": {"energy": 2, "impact": "forceful", "direction": "away"},
    "pull": {"energy": 2, "impact": "attractive", "direction": "toward"},
    "boomerang": {"energy": 4, "impact": "returning", "direction": "circular"},
    "yoyo": {"energy": 3, "impact": "oscillating", "direction": "bidirectional"}
}

# ----- SYSTEM REFERENCES -----
var terminal_api_bridge = null
var claude_bridge = null
var spatial_connector = null
var turn_system = null
var word_processor = null
var akashic_system = null

# ----- STATE TRACKING -----
var active_turn = 1
var auto_mode_enabled = false
var processing_interval = 5.0 # seconds
var word_trajectories = {}
var transform_history = []
var project_centers = {}
var session_start_time = 0
var current_operation = null
var word_power_levels = {}
var trajectory_shapes = {}

# ----- SIGNALS -----
signal auto_mode_toggled(enabled)
signal word_trajectory_created(word, trajectory)
signal project_center_shifted(project_id, old_center, new_center)
signal transform_applied(word, action, result)
signal turn_auto_advanced(old_turn, new_turn)
signal operation_completed(operation_type, duration, result)

# ----- INITIALIZATION -----
func _ready():
    print("Initializing Auto Agent Mode...")
    
    # Connect to required systems
    _connect_systems()
    
    # Initialize processing timer
    _setup_processing_timer()
    
    # Initialize word power levels
    _initialize_word_powers()
    
    # Set session start time
    session_start_time = OS.get_unix_time()
    
    print("Auto Agent Mode initialized")

func _connect_systems():
    # Connect to Terminal API Bridge
    terminal_api_bridge = get_node_or_null("/root/TerminalAPIBridge")
    
    # Connect to Claude Bridge
    claude_bridge = get_node_or_null("/root/ClaudeAkashicBridge")
    if not claude_bridge:
        claude_bridge = get_node_or_null("/root/ClaudeEtherealBridge")
    
    # Connect to Spatial Linguistic Connector
    spatial_connector = get_node_or_null("/root/SpatialLinguisticConnector")
    
    # Connect to Turn System
    turn_system = get_node_or_null("/root/TurnSystem")
    if turn_system:
        turn_system.connect("turn_advanced", self, "_on_turn_advanced")
        active_turn = turn_system.get_current_turn()
    
    # Connect to Divine Word Processor
    word_processor = get_node_or_null("/root/DivineWordProcessor")
    
    # Connect to Akashic System
    akashic_system = get_node_or_null("/root/AkashicNumberSystem")

func _setup_processing_timer():
    var timer = Timer.new()
    timer.wait_time = processing_interval
    timer.one_shot = false
    timer.autostart = false
    timer.name = "AutoProcessingTimer"
    timer.connect("timeout", self, "_on_processing_timer")
    add_child(timer)

func _initialize_word_powers():
    # Initialize power levels for core words
    for word in CORE_WORDS:
        if TRANSFORM_ACTIONS.has(word):
            word_power_levels[word] = TRANSFORM_ACTIONS[word].energy * 10
    
    # Add some common project words
    word_power_levels["project"] = 50
    word_power_levels["center"] = 45
    word_power_levels["core"] = 60
    word_power_levels["trajectory"] = 55
    word_power_levels["shape"] = 40
    word_power_levels["words"] = 70
    word_power_levels["time"] = 65
    word_power_levels["turn"] = 35

# ----- AUTO AGENT MODE CONTROL -----
func enable_auto_mode(enabled=true, custom_interval=null):
    auto_mode_enabled = enabled
    
    # Update processing interval if specified
    if custom_interval != null and custom_interval > 0.5:
        processing_interval = custom_interval
        var timer = get_node_or_null("AutoProcessingTimer")
        if timer:
            timer.wait_time = processing_interval
    
    # Start or stop the processing timer
    var timer = get_node_or_null("AutoProcessingTimer")
    if timer:
        if enabled:
            timer.start()
        else:
            timer.stop()
    
    emit_signal("auto_mode_toggled", enabled)
    
    print("Auto Agent Mode " + ("enabled" if enabled else "disabled") + 
          " with processing interval of " + str(processing_interval) + " seconds")
    
    return auto_mode_enabled

func _on_processing_timer():
    if not auto_mode_enabled:
        return
    
    # Check if we need to auto-advance turn based on time
    _check_auto_advance_turn()
    
    # Process terminal commands
    _process_terminal_input()
    
    # Process word transformations
    _process_word_transformations()
    
    # Update trajectories
    _update_trajectories()
    
    # Check for project center shifts
    _check_project_centers()

# ----- TURN MANAGEMENT -----
func _on_turn_advanced(old_turn, new_turn):
    active_turn = new_turn
    print("Auto Agent Mode detected turn advance from " + str(old_turn) + " to " + str(new_turn))
    
    # Reset current operation on turn change
    current_operation = null
    
    # Perform turn-specific operations
    _perform_turn_operations(new_turn)

func _check_auto_advance_turn():
    if not turn_system:
        return
    
    # Check if enough time has passed since session start to advance turn
    var current_time = OS.get_unix_time()
    var session_duration = current_time - session_start_time
    
    # Calculate ideal turn based on session duration and max turns
    # Assuming an 8-hour session (28800 seconds) with MAX_TURNS_PER_SESSION
    var time_per_turn = 28800.0 / MAX_TURNS_PER_SESSION
    var ideal_turn = int(session_duration / time_per_turn) + 1
    
    # Only advance if ideal turn is ahead of current turn
    if ideal_turn > active_turn:
        turn_system.advance_turn()
        emit_signal("turn_auto_advanced", active_turn, ideal_turn)
        
        print("Auto-advancing turn from " + str(active_turn) + " to " + str(ideal_turn) + 
              " based on session time")

func _perform_turn_operations(turn):
    # Execute operations specific to this turn
    var turn_operation = {
        "type": "turn_operation",
        "turn": turn,
        "start_time": OS.get_unix_time(),
        "actions": []
    }
    
    # Perform different operations based on turn number
    match turn % 12:
        1: # First turn - Initialize trajectories
            _initialize_all_trajectories()
            turn_operation.actions.append("initialize_trajectories")
        
        2: # Second turn - Set up project centers
            _setup_project_centers()
            turn_operation.actions.append("setup_project_centers")
        
        6: # Midpoint - Reshape trajectories
            _reshape_all_trajectories()
            turn_operation.actions.append("reshape_trajectories")
        
        12: # Final turn - Consolidate transformations
            _consolidate_transformations()
            turn_operation.actions.append("consolidate_transformations")
    
    # Always update word powers on turn change
    _update_word_powers()
    turn_operation.actions.append("update_word_powers")
    
    # Complete the operation
    turn_operation.end_time = OS.get_unix_time()
    turn_operation.duration = turn_operation.end_time - turn_operation.start_time
    
    transform_history.append(turn_operation)
    emit_signal("operation_completed", "turn_operation", turn_operation.duration, turn_operation)

# ----- TERMINAL INPUT PROCESSING -----
func _process_terminal_input():
    if not terminal_api_bridge:
        return
    
    # Check all connected cores
    var core_monitors = terminal_api_bridge.get_all_monitors()
    
    for core_id in core_monitors:
        var monitor = core_monitors[core_id]
        
        # Process last input if it hasn't been processed
        if monitor.has("last_input") and monitor.last_input:
            var input_text = monitor.last_input
            
            # Only process if it's a new input that contains a core word
            if _contains_core_word(input_text):
                _process_command(input_text, core_id)
                
                # Mark as processed by clearing
                monitor.last_input = null

func _contains_core_word(text):
    if not text:
        return false
    
    text = text.to_lower()
    
    for word in CORE_WORDS:
        if word.to_lower() in text:
            return true
    
    return false

func _process_command(command, core_id):
    # Extract core words from command
    var words = command.split(" ")
    var core_words_found = []
    
    for word in words:
        word = word.to_lower()
        if word in CORE_WORDS:
            core_words_found.append(word)
    
    if core_words_found.empty():
        return
    
    print("Auto Agent processing command with core words: " + str(core_words_found))
    
    # Create operation record
    var operation = {
        "type": "command_processing",
        "command": command,
        "core_id": core_id,
        "core_words": core_words_found,
        "start_time": OS.get_unix_time(),
        "transforms": []
    }
    
    current_operation = operation
    
    # Apply transformations for each core word
    for word in core_words_found:
        var transform = _apply_transformation(word, command)
        if transform:
            operation.transforms.append(transform)
    
    # Complete operation
    operation.end_time = OS.get_unix_time()
    operation.duration = operation.end_time - operation.start_time
    
    transform_history.append(operation)
    emit_signal("operation_completed", "command_processing", operation.duration, operation)
    
    current_operation = null

# ----- WORD TRANSFORMATIONS -----
func _process_word_transformations():
    # Check if we are already processing an operation
    if current_operation != null:
        return
    
    # Randomly select a core word to process if no command is being processed
    if randf() < 0.3: # 30% chance each interval to process a random word
        var available_words = CORE_WORDS
        var word = available_words[randi() % available_words.size()]
        
        # Create auto operation
        var operation = {
            "type": "auto_transformation",
            "word": word,
            "start_time": OS.get_unix_time(),
            "transforms": []
        }
        
        current_operation = operation
        
        # Apply the transformation
        var transform = _apply_transformation(word, "auto")
        if transform:
            operation.transforms.append(transform)
        
        # Complete operation
        operation.end_time = OS.get_unix_time()
        operation.duration = operation.end_time - operation.start_time
        
        transform_history.append(operation)
        emit_signal("operation_completed", "auto_transformation", operation.duration, operation)
        
        current_operation = null

func _apply_transformation(word, context=""):
    if not TRANSFORM_ACTIONS.has(word):
        return null
    
    print("Applying transformation for word: " + word)
    
    # Get transform parameters
    var transform_params = TRANSFORM_ACTIONS[word]
    var energy = transform_params.energy
    var impact = transform_params.impact
    var direction = transform_params.direction
    
    # Create a transform record
    var transform = {
        "word": word,
        "context": context,
        "energy": energy,
        "impact": impact,
        "direction": direction,
        "timestamp": OS.get_unix_time(),
        "affected_trajectories": [],
        "affected_projects": []
    }
    
    # Apply effect based on the word
    match word:
        "update":
            _transform_update(transform)
        "upgrade":
            _transform_upgrade(transform)
        "merge":
            _transform_merge(transform)
        "split":
            _transform_split(transform)
        "evolve":
            _transform_evolve(transform)
        "multiply":
            _transform_multiply(transform)
        "duplicate":
            _transform_duplicate(transform)
        "change":
            _transform_change(transform)
        "delete":
            _transform_delete(transform)
        "move":
            _transform_move(transform)
        "push":
            _transform_push(transform)
        "pull":
            _transform_pull(transform)
        "boomerang":
            _transform_boomerang(transform)
        "yoyo":
            _transform_yoyo(transform)
    
    # Emit signal for the transform
    emit_signal("transform_applied", word, impact, transform)
    
    return transform

# ----- TRANSFORM IMPLEMENTATIONS -----
func _transform_update(transform):
    # Update increments trajectories slightly
    for word in word_trajectories:
        var trajectory = word_trajectories[word]
        
        # Slight increase in trajectory progress
        trajectory.progress += 0.05
        
        # Add some energy to the word
        if word_power_levels.has(word):
            word_power_levels[word] += 1
        else:
            word_power_levels[word] = 1
        
        transform.affected_trajectories.append(word)
    
    # Update one project center
    if project_centers.size() > 0:
        var projects = project_centers.keys()
        var project = projects[randi() % projects.size()]
        
        # Slightly shift the center
        var center = project_centers[project]
        center.x += (randf() - 0.5) * 0.2
        center.y += (randf() - 0.5) * 0.2
        project_centers[project] = center
        
        transform.affected_projects.append(project)

func _transform_upgrade(transform):
    # Upgrade significantly improves trajectories and powers
    for word in word_trajectories:
        var trajectory = word_trajectories[word]
        
        # Major increase in trajectory quality
        trajectory.quality += 0.2
        trajectory.progress += 0.1
        
        # Add significant energy to the word
        if word_power_levels.has(word):
            word_power_levels[word] += 5
        else:
            word_power_levels[word] = 5
        
        transform.affected_trajectories.append(word)
    
    # Upgrade all project centers
    for project in project_centers:
        # Move centers upward slightly
        var center = project_centers[project]
        center.y += 0.3
        project_centers[project] = center
        
        transform.affected_projects.append(project)

func _transform_merge(transform):
    # Merge combines similar trajectories
    var merge_candidates = {}
    
    # Find similar trajectories by direction
    for word in word_trajectories:
        var trajectory = word_trajectories[word]
        var direction = trajectory.direction
        
        if not merge_candidates.has(direction):
            merge_candidates[direction] = []
        
        merge_candidates[direction].append(word)
    
    # Merge trajectories with same direction
    for direction in merge_candidates:
        var candidates = merge_candidates[direction]
        
        if candidates.size() >= 2:
            # Pick two candidates to merge
            var word1 = candidates[0]
            var word2 = candidates[1]
            
            var merged_word = word1 + "_" + word2
            
            # Create merged trajectory
            word_trajectories[merged_word] = {
                "progress": (word_trajectories[word1].progress + word_trajectories[word2].progress) / 2,
                "quality": max(word_trajectories[word1].quality, word_trajectories[word2].quality) + 0.1,
                "direction": direction,
                "shape": word_trajectories[word1].shape,
                "points": word_trajectories[word1].points + word_trajectories[word2].points,
                "created": OS.get_unix_time()
            }
            
            # Set power level for merged word
            word_power_levels[merged_word] = word_power_levels.get(word1, 1) + word_power_levels.get(word2, 1)
            
            transform.affected_trajectories.append(merged_word)
            
            # Optionally, remove original trajectories
            if randf() < 0.5:
                word_trajectories.erase(word1)
                word_trajectories.erase(word2)
                transform.notes = "Merged trajectories and removed originals"
            else:
                transform.notes = "Merged trajectories and kept originals"

func _transform_split(transform):
    # Split divides trajectories into components
    var split_candidates = []
    
    # Find complex trajectories to split
    for word in word_trajectories:
        if "_" in word or word.length() > 5:
            split_candidates.append(word)
    
    # Split some trajectories
    for i in range(min(3, split_candidates.size())):
        var word = split_candidates[i]
        
        # Split into parts
        var parts = []
        if "_" in word:
            parts = word.split("_")
        else:
            // Split at midpoint
            var mid = word.length() / 2
            parts = [word.substr(0, mid), word.substr(mid)]
        
        // Create trajectories for parts
        for part in parts:
            if not word_trajectories.has(part):
                word_trajectories[part] = {
                    "progress": word_trajectories[word].progress * 0.8,
                    "quality": word_trajectories[word].quality * 0.7,
                    "direction": _random_direction(),
                    "shape": _random_shape(),
                    "points": int(word_trajectories[word].points / parts.size()),
                    "created": OS.get_unix_time()
                }
                
                // Set power level for part
                word_power_levels[part] = int(word_power_levels.get(word, 2) / 2)
                
                transform.affected_trajectories.append(part)
        
        transform.notes = "Split trajectory into " + str(parts.size()) + " parts"

func _transform_evolve(transform):
    # Evolve progresses trajectories along a spiral path
    for word in word_trajectories:
        var trajectory = word_trajectories[word]
        
        // Progressive increase in quality and progress
        trajectory.progress += 0.15
        trajectory.quality += 0.1
        
        // Change shape to more complex form
        if trajectory.shape == "line":
            trajectory.shape = "curve"
        elif trajectory.shape == "curve":
            trajectory.shape = "spiral"
        elif trajectory.shape == "spiral":
            trajectory.shape = "helix"
        elif trajectory.shape == "circle":
            trajectory.shape = "ellipse"
        elif trajectory.shape == "square":
            trajectory.shape = "cube"
        
        // Add points
        trajectory.points += 5
        
        transform.affected_trajectories.append(word)
    
    // Evolve project centers toward a more complex arrangement
    if project_centers.size() >= 3:
        // Calculate center of mass
        var center_of_mass = Vector2(0, 0)
        for project in project_centers:
            center_of_mass += project_centers[project]
        center_of_mass /= project_centers.size()
        
        // Rotate projects around center of mass
        for project in project_centers:
            var center = project_centers[project]
            var angle = 0.2 // Small rotation
            var new_center = Vector2(
                center_of_mass.x + (center.x - center_of_mass.x) * cos(angle) - (center.y - center_of_mass.y) * sin(angle),
                center_of_mass.y + (center.x - center_of_mass.x) * sin(angle) + (center.y - center_of_mass.y) * cos(angle)
            )
            project_centers[project] = new_center
            transform.affected_projects.append(project)
        
        transform.notes = "Evolved projects in spiral pattern"

func _transform_multiply(transform):
    // Multiply creates copies with variations
    var original_trajectories = word_trajectories.duplicate()
    var new_words = []
    
    for word in original_trajectories:
        // Create 2-3 variations
        var variations = 2 + int(randf() * 2)
        
        for i in range(variations):
            var new_word = word + "_" + str(i+1)
            
            // Create variation with slight differences
            word_trajectories[new_word] = {
                "progress": original_trajectories[word].progress * (0.8 + randf() * 0.4),
                "quality": original_trajectories[word].quality * (0.7 + randf() * 0.6),
                "direction": _random_direction(),
                "shape": original_trajectories[word].shape,
                "points": original_trajectories[word].points + int(randf() * 10),
                "created": OS.get_unix_time()
            }
            
            // Set power level
            word_power_levels[new_word] = int(word_power_levels.get(word, 5) * (0.6 + randf() * 0.8))
            
            new_words.append(new_word)
            transform.affected_trajectories.append(new_word)
        
        // Increase power of original
        if word_power_levels.has(word):
            word_power_levels[word] += 3
    
    transform.notes = "Multiplied into " + str(new_words.size()) + " variations"

func _transform_duplicate(transform):
    // Duplicate creates exact copies
    var original_trajectories = word_trajectories.duplicate()
    var new_words = []
    
    for word in original_trajectories:
        var new_word = word + "_copy"
        
        // Create exact duplicate
        word_trajectories[new_word] = original_trajectories[word].duplicate()
        word_trajectories[new_word].created = OS.get_unix_time()
        
        // Copy power level
        word_power_levels[new_word] = word_power_levels.get(word, 1)
        
        new_words.append(new_word)
        transform.affected_trajectories.append(new_word)
    
    transform.notes = "Duplicated " + str(new_words.size()) + " trajectories"

func _transform_change(transform):
    // Change transforms trajectories randomly
    for word in word_trajectories:
        var trajectory = word_trajectories[word]
        
        // Random transformation
        var change_type = randi() % 5
        
        match change_type:
            0: // Change direction
                trajectory.direction = _random_direction()
            1: // Change shape
                trajectory.shape = _random_shape()
            2: // Change progress
                trajectory.progress = min(1.0, max(0.0, trajectory.progress + (randf() - 0.5) * 0.4))
            3: // Change quality
                trajectory.quality = min(1.0, max(0.0, trajectory.quality + (randf() - 0.5) * 0.3))
            4: // Change points
                trajectory.points = max(1, trajectory.points + int((randf() - 0.5) * 20))
        
        transform.affected_trajectories.append(word)
    
    // Randomly change project centers
    for project in project_centers:
        project_centers[project] = Vector2(
            project_centers[project].x + (randf() - 0.5) * 2,
            project_centers[project].y + (randf() - 0.5) * 2
        )
        transform.affected_projects.append(project)
    
    transform.notes = "Applied random transformations"

func _transform_delete(transform):
    // Delete removes some trajectories
    var delete_candidates = []
    
    // Find low quality trajectories to delete
    for word in word_trajectories:
        var trajectory = word_trajectories[word]
        if trajectory.quality < 0.3 or trajectory.progress < 0.2:
            delete_candidates.append(word)
    
    // Delete some candidates (max 3)
    var delete_count = min(3, delete_candidates.size())
    for i in range(delete_count):
        if delete_candidates.size() > i:
            var word = delete_candidates[i]
            word_trajectories.erase(word)
            transform.affected_trajectories.append(word)
    
    transform.notes = "Deleted " + str(delete_count) + " low quality trajectories"

func _transform_move(transform):
    // Move relocates trajectories and projects
    for word in word_trajectories:
        var trajectory = word_trajectories[word]
        
        // Generate a movement vector
        var movement_vector = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
        
        // Update any position-related properties
        if trajectory.has("position"):
            trajectory.position += movement_vector
        
        transform.affected_trajectories.append(word)
    
    // Move project centers
    for project in project_centers:
        // Move in a consistent direction
        var movement = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized() * 2
        project_centers[project] += movement
        transform.affected_projects.append(project)
    
    transform.notes = "Relocated projects and trajectories"

func _transform_push(transform):
    // Push moves objects away from center
    var center = Vector2(0, 0)
    
    // Calculate center of mass for project centers
    if project_centers.size() > 0:
        for project in project_centers:
            center += project_centers[project]
        center /= project_centers.size()
    
    // Push project centers away from center
    for project in project_centers:
        var direction = (project_centers[project] - center).normalized()
        if direction.length() < 0.1:
            direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
        
        project_centers[project] += direction * 2
        transform.affected_projects.append(project)
    
    transform.notes = "Pushed projects away from center"

func _transform_pull(transform):
    // Pull moves objects toward center
    var center = Vector2(0, 0)
    
    // Calculate center of mass for project centers
    if project_centers.size() > 0:
        for project in project_centers:
            center += project_centers[project]
        center /= project_centers.size()
    
    // Pull project centers toward center
    for project in project_centers:
        var direction = (center - project_centers[project]).normalized()
        project_centers[project] += direction * 1.5
        transform.affected_projects.append(project)
    
    transform.notes = "Pulled projects toward center"

func _transform_boomerang(transform):
    // Boomerang creates a return point for trajectories
    for word in word_trajectories:
        var trajectory = word_trajectories[word]
        
        // Create a return point
        if not trajectory.has("return_point"):
            trajectory.return_point = {
                "progress": trajectory.progress,
                "quality": trajectory.quality,
                "direction": trajectory.direction
            }
        else:
            // If return point exists, return to it
            var return_point = trajectory.return_point
            trajectory.progress = return_point.progress
            trajectory.quality = return_point.quality
            trajectory.direction = return_point.direction
            transform.notes = "Returned to saved state"
        
        transform.affected_trajectories.append(word)
    
    // For project centers, store and optionally return
    if not transform.has("center_memory"):
        transform.center_memory = project_centers.duplicate()
        transform.notes = "Created return points for trajectories"
    else:
        project_centers = transform.center_memory.duplicate()
        for project in project_centers:
            transform.affected_projects.append(project)
        transform.notes = "Returned projects to previous centers"

func _transform_yoyo(transform):
    // Yoyo oscillates between two states
    if not transform.has("yoyo_state") or transform.yoyo_state == "out":
        // Moving out - increase values
        for word in word_trajectories:
            var trajectory = word_trajectories[word]
            
            trajectory.progress = min(1.0, trajectory.progress + 0.2)
            trajectory.quality = min(1.0, trajectory.quality + 0.15)
            if word_power_levels.has(word):
                word_power_levels[word] += 3
            
            transform.affected_trajectories.append(word)
        
        transform.yoyo_state = "in"
        transform.notes = "Expanded trajectories (out)"
    else:
        // Moving in - decrease values
        for word in word_trajectories:
            var trajectory = word_trajectories[word]
            
            trajectory.progress = max(0.0, trajectory.progress - 0.2)
            trajectory.quality = max(0.1, trajectory.quality - 0.15)
            if word_power_levels.has(word):
                word_power_levels[word] = max(1, word_power_levels[word] - 3)
            
            transform.affected_trajectories.append(word)
        
        transform.yoyo_state = "out"
        transform.notes = "Contracted trajectories (in)"
    
    // Oscillate project centers
    for project in project_centers:
        if transform.yoyo_state == "in":
            // Move toward center
            project_centers[project] *= 0.7
        else:
            // Move away from center
            project_centers[project] *= 1.4
        
        transform.affected_projects.append(project)

# ----- TRAJECTORY MANAGEMENT -----
func _update_trajectories():
    // Gradually update trajectories over time
    for word in word_trajectories:
        var trajectory = word_trajectories[word]
        
        // Small natural progress increase
        trajectory.progress = min(1.0, trajectory.progress + 0.001)
        
        // Update quality based on word power
        if word_power_levels.has(word):
            var power = word_power_levels[word]
            var quality_boost = power * 0.0001
            trajectory.quality = min(1.0, trajectory.quality + quality_boost)

func _initialize_all_trajectories():
    // Create basic trajectories for core words
    for word in CORE_WORDS:
        if not word_trajectories.has(word):
            word_trajectories[word] = {
                "progress": 0.1,
                "quality": 0.5,
                "direction": _random_direction(),
                "shape": _random_shape(),
                "points": 10,
                "created": OS.get_unix_time()
            }
            
            trajectory_shapes[word] = _random_shape()
            emit_signal("word_trajectory_created", word, word_trajectories[word])
    
    // Also create trajectories for some basic project terms
    var project_terms = ["project", "center", "core", "shape", "trajectory"]
    for term in project_terms:
        if not word_trajectories.has(term):
            word_trajectories[term] = {
                "progress": 0.2,
                "quality": 0.6,
                "direction": _random_direction(),
                "shape": _random_shape(),
                "points": 15,
                "created": OS.get_unix_time()
            }
            
            trajectory_shapes[term] = _random_shape()
            emit_signal("word_trajectory_created", term, word_trajectories[term])
    
    print("Initialized trajectories for " + str(word_trajectories.size()) + " words")

func _reshape_all_trajectories():
    // Change shapes for all trajectories
    for word in word_trajectories:
        word_trajectories[word].shape = _random_shape()
        trajectory_shapes[word] = word_trajectories[word].shape
    
    print("Reshaped all trajectories with new forms")

func _random_direction():
    var directions = ["up", "down", "left", "right", "forward", "backward", 
                     "clockwise", "counterclockwise", "inward", "outward", "spiral"]
    return directions[randi() % directions.size()]

func _random_shape():
    var shapes = ["line", "curve", "circle", "square", "triangle", 
                 "spiral", "helix", "wave", "star", "ellipse", "cube"]
    return shapes[randi() % shapes.size()]

# ----- PROJECT CENTER MANAGEMENT -----
func _setup_project_centers():
    // Initialize centers for basic projects
    var base_projects = ["main", "core", "extension", "module", "component"]
    
    for project in base_projects:
        // Create a center with slight randomization
        project_centers[project] = Vector2(
            (randf() - 0.5) * 10,
            (randf() - 0.5) * 10
        )
    
    print("Set up centers for " + str(project_centers.size()) + " projects")

func _check_project_centers():
    // Check for any shifts in project centers
    for project in project_centers:
        // Apply minor natural drift
        var drift = Vector2(
            (randf() - 0.5) * 0.1,
            (randf() - 0.5) * 0.1
        )
        
        var old_center = project_centers[project]
        project_centers[project] += drift
        
        // Check if any word has enough power to shift the center more dramatically
        for word in word_power_levels:
            var power = word_power_levels[word]
            
            if power > 50 and randf() < 0.05:
                // High power word occasionally shifts project center
                var shift_vector = Vector2(
                    (randf() - 0.5) * 4,
                    (randf() - 0.5) * 4
                )
                
                project_centers[project] += shift_vector
                
                emit_signal("project_center_shifted", project, old_center, project_centers[project])
                print("Word '" + word + "' with power " + str(power) + 
                      " shifted project '" + project + "' center")
                break

func _consolidate_transformations():
    // Analyze all transformations and consolidate their effects
    if transform_history.size() < 2:
        return
    
    // Group similar transformations
    var word_impacts = {}
    
    for transform in transform_history:
        if transform.has("transforms"):
            for sub_transform in transform.transforms:
                var word = sub_transform.word
                if not word_impacts.has(word):
                    word_impacts[word] = {
                        "count": 0,
                        "total_energy": 0,
                        "affected_trajectories": [],
                        "affected_projects": []
                    }
                
                word_impacts[word].count += 1
                word_impacts[word].total_energy += sub_transform.energy
                word_impacts[word].affected_trajectories.append_array(sub_transform.affected_trajectories)
                word_impacts[word].affected_projects.append_array(sub_transform.affected_projects)
    
    // Apply consolidation effects
    for word in word_impacts:
        var impact = word_impacts[word]
        
        if impact.count >= 3:
            // Word used frequently - boost its power
            if word_power_levels.has(word):
                word_power_levels[word] += impact.count * 2
            
            print("Consolidated " + str(impact.count) + " uses of '" + word + 
                  "' with total energy " + str(impact.total_energy))
    
    // Clear transform history after consolidation
    transform_history.clear()

func _update_word_powers():
    // Decay unused words, boost used ones
    for word in word_power_levels:
        // Natural decay
        word_power_levels[word] = max(1, word_power_levels[word] - 1)
        
        // Boost words that have active trajectories
        if word_trajectories.has(word):
            var trajectory = word_trajectories[word]
            
            // Higher quality trajectories preserve more power
            var preservation = trajectory.quality * 0.5
            word_power_levels[word] = int(word_power_levels[word] * (0.9 + preservation))

# ----- PUBLIC API -----
func start_auto_agent(interval=5.0):
    return enable_auto_mode(true, interval)

func stop_auto_agent():
    return enable_auto_mode(false)

func get_word_trajectories():
    return word_trajectories

func get_project_centers():
    return project_centers

func get_word_power_levels():
    return word_power_levels

func get_transform_history():
    return transform_history

func get_active_turn():
    return active_turn

func get_trajectory_shape(word):
    if trajectory_shapes.has(word):
        return trajectory_shapes[word]
    return null

func get_auto_agent_status():
    return {
        "enabled": auto_mode_enabled,
        "interval": processing_interval,
        "active_turn": active_turn,
        "session_duration": OS.get_unix_time() - session_start_time,
        "word_count": word_trajectories.size(),
        "project_count": project_centers.size(),
        "transform_count": transform_history.size(),
        "current_operation": current_operation
    }

func create_trajectory(word, initial_progress=0.1, shape=null):
    if not shape:
        shape = _random_shape()
    
    word_trajectories[word] = {
        "progress": initial_progress,
        "quality": 0.5,
        "direction": _random_direction(),
        "shape": shape,
        "points": 10,
        "created": OS.get_unix_time()
    }
    
    trajectory_shapes[word] = shape
    emit_signal("word_trajectory_created", word, word_trajectories[word])
    
    return word_trajectories[word]

func set_word_power(word, power):
    word_power_levels[word] = max(1, power)
    return word_power_levels[word]

func execute_transform(word, context="manual"):
    if not TRANSFORM_ACTIONS.has(word):
        return null
    
    return _apply_transformation(word, context)

func add_project_center(project_name, position=null):
    if position == null:
        position = Vector2((randf() - 0.5) * 10, (randf() - 0.5) * 10)
    
    project_centers[project_name] = position
    return position

func get_recommended_transforms():
    // Recommend transforms based on current state
    var recommendations = []
    
    // Check trajectory progress
    var avg_progress = 0.0
    for word in word_trajectories:
        avg_progress += word_trajectories[word].progress
    
    if word_trajectories.size() > 0:
        avg_progress /= word_trajectories.size()
    
    // Recommend based on progress
    if avg_progress < 0.3:
        recommendations.append({
            "transform": "update",
            "reason": "Low average progress"
        })
        recommendations.append({
            "transform": "upgrade",
            "reason": "Boost trajectory quality"
        })
    elif avg_progress > 0.7:
        recommendations.append({
            "transform": "evolve",
            "reason": "High progress, ready to evolve"
        })
    
    // Check number of trajectories
    if word_trajectories.size() < 5:
        recommendations.append({
            "transform": "multiply",
            "reason": "Too few trajectories"
        })
    elif word_trajectories.size() > 15:
        recommendations.append({
            "transform": "merge",
            "reason": "Too many trajectories, consolidate"
        })
    
    // Check project centers
    if project_centers.size() < 3:
        recommendations.append({
            "transform": "duplicate",
            "reason": "Need more project centers"
        })
    
    return recommendations