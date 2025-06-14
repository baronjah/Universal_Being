extends Node

class_name TurnSystem

# Turn System for Eden_OS
# Implements the 12-turns-per-turn concept for multi-dimensional game progression

signal turn_advanced(turn_id)
signal subturn_advanced(subturn_id)
signal turn_completed(turn_id)
signal turn_action_recorded(action_data)

# Turn constants
const TURNS_PER_CYCLE = 12
const MAX_TURNS = 1000
const TURN_STATES = ["pending", "active", "completed", "archived"]

# Turn state
var current_main_turn = 1
var current_subturn = 1
var current_turn_state = "active"
var turn_history = {}
var subturn_history = {}
var turn_timestamps = {}

# Time tracking
var turn_start_time = 0
var auto_advance = false
var auto_advance_time = 300  # 5 minutes per subturn

# Advanced turn tracking across dimensions
var dimension_turn_states = {}
var parallel_turns = {}
var branched_turns = {}

func _ready():
    initialize_turn_system()
    print("Turn System initialized with " + str(TURNS_PER_CYCLE) + " subturns per turn")
    
    # Start the first turn
    start_turn(1, 1)

func _process(delta):
    # Auto-advance turns if enabled
    if auto_advance and Time.get_unix_time_from_system() - turn_start_time > auto_advance_time:
        advance_subturn()

func initialize_turn_system():
    # Initialize the first main turn and its subturns
    for i in range(1, TURNS_PER_CYCLE + 1):
        create_subturn(1, i)
    
    # Initialize turn timestamp tracking
    turn_timestamps[1] = {
        "start": Time.get_unix_time_from_system(),
        "subturns": {}
    }
    
    for i in range(1, TURNS_PER_CYCLE + 1):
        turn_timestamps[1]["subturns"][i] = {
            "start": 0,
            "end": 0
        }

func create_subturn(main_turn, subturn):
    # Create a data structure for a subturn
    var subturn_id = str(main_turn) + "." + str(subturn)
    
    subturn_history[subturn_id] = {
        "main_turn": main_turn,
        "subturn": subturn,
        "state": "pending",
        "actions": [],
        "words_created": [],
        "words_connected": [],
        "dimensions_visited": [],
        "events": []
    }
    
    # If this is the first subturn of a main turn, initialize the main turn
    if subturn == 1:
        turn_history[main_turn] = {
            "state": "pending",
            "subturns_completed": 0,
            "words_created": [],
            "dimensions_visited": [],
            "summary": ""
        }

func start_turn(main_turn, subturn):
    var subturn_id = str(main_turn) + "." + str(subturn)
    
    if not subturn_history.has(subturn_id):
        create_subturn(main_turn, subturn)
    
    # Set current turn parameters
    current_main_turn = main_turn
    current_subturn = subturn
    current_turn_state = "active"
    
    # Update state
    subturn_history[subturn_id]["state"] = "active"
    if subturn == 1:
        turn_history[main_turn]["state"] = "active"
    
    # Record start time
    turn_start_time = Time.get_unix_time_from_system()
    turn_timestamps[main_turn]["subturns"][subturn]["start"] = turn_start_time
    
    # Emit signal
    emit_signal("subturn_advanced", subturn_id)
    
    return "Turn " + subturn_id + " started"

func advance_subturn():
    # Complete current subturn
    complete_current_subturn()
    
    # Calculate next subturn
    var next_subturn = current_subturn + 1
    var next_main_turn = current_main_turn
    
    if next_subturn > TURNS_PER_CYCLE:
        next_subturn = 1
        next_main_turn = current_main_turn + 1
        complete_main_turn(current_main_turn)
    
    # Start next subturn
    return start_turn(next_main_turn, next_subturn)

func complete_current_subturn():
    var subturn_id = str(current_main_turn) + "." + str(current_subturn)
    
    # Mark as completed
    subturn_history[subturn_id]["state"] = "completed"
    
    # Update main turn
    turn_history[current_main_turn]["subturns_completed"] += 1
    
    # Record end time
    turn_timestamps[current_main_turn]["subturns"][current_subturn]["end"] = Time.get_unix_time_from_system()
    
    # Emit signal
    emit_signal("subturn_advanced", subturn_id)
    
    return "Subturn " + subturn_id + " completed"

func complete_main_turn(turn_id):
    # Check if all subturns are completed
    if turn_history[turn_id]["subturns_completed"] >= TURNS_PER_CYCLE:
        # Mark as completed
        turn_history[turn_id]["state"] = "completed"
        
        # Generate turn summary
        generate_turn_summary(turn_id)
        
        # Record end time
        turn_timestamps[turn_id]["end"] = Time.get_unix_time_from_system()
        
        # Emit signal
        emit_signal("turn_completed", turn_id)
        
        # Initialize next turn
        if not turn_history.has(turn_id + 1):
            for i in range(1, TURNS_PER_CYCLE + 1):
                create_subturn(turn_id + 1, i)
            
            turn_timestamps[turn_id + 1] = {
                "start": Time.get_unix_time_from_system(),
                "subturns": {}
            }
            
            for i in range(1, TURNS_PER_CYCLE + 1):
                turn_timestamps[turn_id + 1]["subturns"][i] = {
                    "start": 0,
                    "end": 0
                }
        
        return "Turn " + str(turn_id) + " completed"
    else:
        return "Turn " + str(turn_id) + " not completed - " + str(turn_history[turn_id]["subturns_completed"]) + "/" + str(TURNS_PER_CYCLE) + " subturns done"

func generate_turn_summary(turn_id):
    # Generate a summary of the entire turn
    var summary = "Turn " + str(turn_id) + " Summary:\n"
    
    # Count actions across all subturns
    var total_actions = 0
    var words_created = []
    var dimensions_visited = []
    
    for i in range(1, TURNS_PER_CYCLE + 1):
        var subturn_id = str(turn_id) + "." + str(i)
        if subturn_history.has(subturn_id):
            total_actions += subturn_history[subturn_id]["actions"].size()
            words_created.append_array(subturn_history[subturn_id]["words_created"])
            dimensions_visited.append_array(subturn_history[subturn_id]["dimensions_visited"])
    
    # Remove duplicates
    var unique_words = []
    var unique_dimensions = []
    
    for word in words_created:
        if not word in unique_words:
            unique_words.append(word)
            
    for dimension in dimensions_visited:
        if not dimension in unique_dimensions:
            unique_dimensions.append(dimension)
    
    # Generate summary
    summary += "Total actions: " + str(total_actions) + "\n"
    summary += "Words created: " + str(unique_words.size()) + "\n"
    summary += "Dimensions visited: " + str(unique_dimensions.size()) + "\n"
    
    # Calculate time spent
    var turn_start = turn_timestamps[turn_id]["start"]
    var turn_end = turn_timestamps[turn_id]["end"]
    var duration = turn_end - turn_start
    
    summary += "Duration: " + format_duration(duration) + "\n"
    
    # Store the summary
    turn_history[turn_id]["summary"] = summary
    
    return summary

func format_duration(seconds):
    var hours = int(seconds / 3600)
    var minutes = int((seconds % 3600) / 60)
    var secs = int(seconds % 60)
    
    return str(hours) + "h " + str(minutes) + "m " + str(secs) + "s"

func record_action(action_data):
    # Record an action in the current subturn
    var subturn_id = str(current_main_turn) + "." + str(current_subturn)
    
    if subturn_history.has(subturn_id):
        subturn_history[subturn_id]["actions"].append(action_data)
        
        # Check if action created words
        if action_data.has("words_created") and action_data["words_created"].size() > 0:
            subturn_history[subturn_id]["words_created"].append_array(action_data["words_created"])
        
        # Check if action visited dimensions
        if action_data.has("dimensions_visited") and action_data["dimensions_visited"].size() > 0:
            subturn_history[subturn_id]["dimensions_visited"].append_array(action_data["dimensions_visited"])
        
        # Emit signal
        emit_signal("turn_action_recorded", action_data)
        
        return true
    else:
        return false

func get_turn_info(main_turn=null, subturn=null):
    # Get information about a specific turn or subturn
    if main_turn == null:
        main_turn = current_main_turn
    
    if subturn == null:
        # Return info about main turn
        if turn_history.has(main_turn):
            return turn_history[main_turn]
        else:
            return null
    else:
        # Return info about specific subturn
        var subturn_id = str(main_turn) + "." + str(subturn)
        if subturn_history.has(subturn_id):
            return subturn_history[subturn_id]
        else:
            return null

func get_current_turn_id():
    return str(current_main_turn) + "." + str(current_subturn)

func set_auto_advance(enabled, time_per_subturn=300):
    auto_advance = enabled
    auto_advance_time = time_per_subturn
    return "Auto-advance " + ("enabled" if enabled else "disabled") + " with " + str(time_per_subturn) + "s per subturn"

# Advanced turn manipulation for multi-dimensional games

func create_turn_branch(source_turn_id, branch_name):
    # Create a branch from an existing turn
    var parts = source_turn_id.split(".")
    var main_turn = int(parts[0])
    var subturn = int(parts[1])
    
    branched_turns[branch_name] = {
        "source_turn": source_turn_id,
        "current_turn": 1,
        "current_subturn": 1,
        "turns": {}
    }
    
    # Copy turn data
    var source_data = get_turn_info(main_turn, subturn)
    if source_data:
        branched_turns[branch_name]["turns"]["1.1"] = source_data.duplicate(true)
        branched_turns[branch_name]["turns"]["1.1"]["branch"] = branch_name
        
        return "Branch created: " + branch_name + " from turn " + source_turn_id
    else:
        return "Failed to create branch - source turn not found"

func switch_to_branch(branch_name):
    if not branched_turns.has(branch_name):
        return "Branch not found: " + branch_name
    
    # Store state of current branch
    var current_branch = "main"
    for branch in branched_turns:
        if branched_turns[branch].has("active") and branched_turns[branch]["active"]:
            current_branch = branch
            branched_turns[branch]["active"] = false
            break
    
    # Activate new branch
    branched_turns[branch_name]["active"] = true
    
    # Set current turn to branch's current turn
    current_main_turn = branched_turns[branch_name]["current_turn"]
    current_subturn = branched_turns[branch_name]["current_subturn"]
    
    return "Switched from branch '" + current_branch + "' to '" + branch_name + "' at turn " + str(current_main_turn) + "." + str(current_subturn)

# Public command-based interface

func process_command(args):
    if args.size() == 0:
        return get_turn_status()
    
    match args[0]:
        "next":
            return advance_subturn()
        "status":
            return get_turn_status()
        "info":
            if args.size() >= 2:
                var turn_parts = args[1].split(".")
                if turn_parts.size() >= 2:
                    return get_turn_detail(int(turn_parts[0]), int(turn_parts[1]))
                else:
                    return get_turn_detail(int(args[1]))
            else:
                return get_turn_detail()
        "complete":
            return complete_current_subturn()
        "auto":
            if args.size() >= 2:
                if args[1] == "on":
                    var time = 300
                    if args.size() >= 3 and args[2].is_valid_integer():
                        time = int(args[2])
                    return set_auto_advance(true, time)
                elif args[1] == "off":
                    return set_auto_advance(false)
            return "Auto-advance is " + ("enabled" if auto_advance else "disabled") + " (" + str(auto_advance_time) + "s per subturn)"
        "branch":
            if args.size() >= 3:
                if args[1] == "create":
                    return create_turn_branch(get_current_turn_id(), args[2])
                elif args[1] == "switch":
                    return switch_to_branch(args[2])
            return "Usage: turn branch [create|switch] <branch_name>"
        _:
            return "Unknown turn command: " + args[0]

func get_turn_status():
    var status = "Current turn: " + str(current_main_turn) + "." + str(current_subturn) + " (" + str(current_subturn) + "/" + str(TURNS_PER_CYCLE) + ")\n"
    status += "State: " + current_turn_state + "\n"
    
    # Add time tracking
    var elapsed = Time.get_unix_time_from_system() - turn_start_time
    status += "Time in current subturn: " + format_duration(elapsed) + "\n"
    
    # Show auto-advance status
    status += "Auto-advance: " + ("Enabled" if auto_advance else "Disabled")
    if auto_advance:
        var remaining = auto_advance_time - elapsed
        status += " (" + format_duration(remaining) + " until next advance)"
    
    return status

func get_turn_detail(main_turn=null, subturn=null):
    var turn_data
    
    if main_turn == null:
        main_turn = current_main_turn
    
    if subturn == null:
        turn_data = get_turn_info(main_turn)
        
        if turn_data:
            var detail = "Turn " + str(main_turn) + " Details:\n"
            detail += "State: " + turn_data["state"] + "\n"
            detail += "Subturns completed: " + str(turn_data["subturns_completed"]) + "/" + str(TURNS_PER_CYCLE) + "\n"
            
            if turn_data["state"] == "completed":
                detail += "\n" + turn_data["summary"]
            
            return detail
        else:
            return "Turn " + str(main_turn) + " not found"
    else:
        turn_data = get_turn_info(main_turn, subturn)
        
        if turn_data:
            var detail = "Subturn " + str(main_turn) + "." + str(subturn) + " Details:\n"
            detail += "State: " + turn_data["state"] + "\n"
            detail += "Actions: " + str(turn_data["actions"].size()) + "\n"
            detail += "Words created: " + str(turn_data["words_created"].size()) + "\n"
            detail += "Dimensions visited: " + str(turn_data["dimensions_visited"].size()) + "\n"
            
            # Add timing info if available
            if turn_timestamps.has(main_turn) and turn_timestamps[main_turn]["subturns"].has(subturn):
                var start_time = turn_timestamps[main_turn]["subturns"][subturn]["start"]
                var end_time = turn_timestamps[main_turn]["subturns"][subturn]["end"]
                
                if start_time > 0:
                    detail += "Start time: " + str(Time.get_datetime_string_from_unix_time(start_time)) + "\n"
                
                if end_time > 0:
                    detail += "End time: " + str(Time.get_datetime_string_from_unix_time(end_time)) + "\n"
                    detail += "Duration: " + format_duration(end_time - start_time) + "\n"
            
            return detail
        else:
            return "Subturn " + str(main_turn) + "." + str(subturn) + " not found"