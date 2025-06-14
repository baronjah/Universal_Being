extends Node
class_name TurnSystem

# Signals
signal turn_started(turn_number, session_data)
signal turn_completed(turn_number, results)
signal cycle_started(cycle_number)
signal cycle_completed(cycle_number, cycle_summary)
signal break_time_started(duration)
signal break_time_ended

# Turn configuration
export var max_turns = 12
export var current_turn = 0
export var current_cycle = 0
export var auto_start_next_turn = false
export var auto_start_next_cycle = false
export var break_duration = 300  # 5 minutes in seconds
export var turn_timeout = 600    # 10 minutes in seconds

# State tracking
var is_turn_active = false
var is_in_break = false
var turn_start_time = 0
var session_start_time = 0
var turn_history = []
var session_data = {}
var break_timer = null
var turn_timer = null

# Constants
const IDLE_STATE = 0
const TURN_ACTIVE_STATE = 1
const BREAK_STATE = 2
const CYCLE_COMPLETE_STATE = 3

var current_state = IDLE_STATE

func _ready():
    # Initialize timers
    break_timer = Timer.new()
    break_timer.one_shot = true
    break_timer.connect("timeout", self, "_on_break_timer_timeout")
    add_child(break_timer)
    
    turn_timer = Timer.new()
    turn_timer.one_shot = true
    turn_timer.connect("timeout", self, "_on_turn_timer_timeout")
    add_child(turn_timer)
    
    # Initialize session data
    _initialize_session_data()

func _initialize_session_data():
    session_data = {
        "start_time": OS.get_unix_time(),
        "cycles_completed": 0,
        "turns_completed": 0,
        "break_time_total": 0,
        "active_time_total": 0,
        "last_activity": "initialization"
    }
    
    session_start_time = OS.get_unix_time()
    current_turn = 0
    current_cycle = 0
    turn_history.clear()
    
    # Save initial state
    save_session_state()

func set_max_turns(turns):
    max_turns = max(1, turns)
    print("Max turns set to: ", max_turns)

func start_session():
    if current_state != IDLE_STATE:
        printerr("Cannot start session: already in progress")
        return false
    
    _initialize_session_data()
    print("New session started")
    
    return start_next_turn()

func start_next_turn():
    if current_state == TURN_ACTIVE_STATE:
        printerr("Cannot start next turn: current turn still active")
        return false
    
    if current_state == BREAK_STATE:
        printerr("Cannot start next turn: in break time")
        return false
    
    if current_turn >= max_turns:
        # Start new cycle
        if auto_start_next_cycle:
            return start_next_cycle()
        else:
            current_state = CYCLE_COMPLETE_STATE
            print("Cycle complete, waiting for manual start of next cycle")
            return false
    
    # Increment turn counter
    current_turn += 1
    is_turn_active = true
    current_state = TURN_ACTIVE_STATE
    turn_start_time = OS.get_unix_time()
    
    # Start turn timeout timer
    turn_timer.wait_time = turn_timeout
    turn_timer.start()
    
    # Prepare turn data
    var turn_data = {
        "turn_number": current_turn,
        "cycle_number": current_cycle,
        "start_time": turn_start_time,
        "max_duration": turn_timeout,
        "is_final_turn": current_turn == max_turns
    }
    
    # Update session data
    session_data.last_activity = "turn_started"
    
    # Emit signal
    emit_signal("turn_started", current_turn, turn_data)
    print("Turn ", current_turn, " started")
    
    # Save updated state
    save_turn_state(turn_data)
    
    return true

func end_current_turn(results={}):
    if !is_turn_active:
        printerr("Cannot end turn: no active turn")
        return false
    
    # Stop timer
    turn_timer.stop()
    
    # Update state
    is_turn_active = false
    var turn_end_time = OS.get_unix_time()
    var turn_duration = turn_end_time - turn_start_time
    
    # Prepare turn results
    var turn_results = {
        "turn_number": current_turn,
        "cycle_number": current_cycle,
        "start_time": turn_start_time,
        "end_time": turn_end_time,
        "duration": turn_duration,
        "results": results
    }
    
    # Add to history
    turn_history.append(turn_results)
    
    # Update session data
    session_data.turns_completed += 1
    session_data.active_time_total += turn_duration
    session_data.last_activity = "turn_completed"
    
    # Emit signal
    emit_signal("turn_completed", current_turn, turn_results)
    print("Turn ", current_turn, " completed in ", turn_duration, " seconds")
    
    # Check if cycle is complete
    if current_turn >= max_turns:
        _complete_cycle()
    elif auto_start_next_turn:
        # Check if we should take a break
        if _should_take_break():
            start_break()
        else:
            start_next_turn()
    else:
        current_state = IDLE_STATE
    
    # Save updated state
    save_turn_state(turn_results)
    
    return true

func _should_take_break():
    # Custom logic to determine if a break should be taken
    # For example, after every 3 turns or if the last turn took too long
    
    # Take a break after every 3 turns
    return current_turn % 3 == 0 && current_turn < max_turns
    
    # Additional conditions could include:
    # - Last turn took more than X minutes
    # - User has been active for Y minutes without a break
    # - etc.

func start_break(duration=0):
    if current_state == BREAK_STATE:
        printerr("Already in break time")
        return false
    
    if duration > 0:
        break_duration = duration
    
    current_state = BREAK_STATE
    is_in_break = true
    
    # Start break timer
    break_timer.wait_time = break_duration
    break_timer.start()
    
    # Update session data
    session_data.last_activity = "break_started"
    
    # Emit signal
    emit_signal("break_time_started", break_duration)
    print("Break time started (", break_duration, " seconds)")
    
    # Save state
    save_session_state()
    
    return true

func skip_break():
    if !is_in_break:
        return false
    
    break_timer.stop()
    _end_break()
    
    return true

func _on_break_timer_timeout():
    _end_break()

func _end_break():
    if !is_in_break:
        return
    
    is_in_break = false
    
    # Update session data
    session_data.break_time_total += break_duration
    session_data.last_activity = "break_ended"
    
    # Emit signal
    emit_signal("break_time_ended")
    print("Break time ended")
    
    # Auto-start next turn if configured
    if auto_start_next_turn:
        start_next_turn()
    else:
        current_state = IDLE_STATE
    
    # Save state
    save_session_state()

func _on_turn_timer_timeout():
    print("Turn timeout reached")
    
    # Auto-end the turn with timeout result
    end_current_turn({"timeout": true})

func _complete_cycle():
    # Calculate cycle summary
    var cycle_summary = {
        "cycle_number": current_cycle,
        "turns_completed": current_turn,
        "start_time": session_data.start_time,
        "end_time": OS.get_unix_time(),
        "duration": OS.get_unix_time() - session_data.start_time,
        "break_time": session_data.break_time_total,
        "active_time": session_data.active_time_total,
        "turn_details": turn_history.duplicate()
    }
    
    # Update session data
    session_data.cycles_completed += 1
    session_data.last_activity = "cycle_completed"
    
    # Emit signal
    emit_signal("cycle_completed", current_cycle, cycle_summary)
    print("Cycle ", current_cycle, " completed")
    
    current_state = CYCLE_COMPLETE_STATE
    
    # Auto-start next cycle if configured
    if auto_start_next_cycle:
        start_next_cycle()
    
    # Save completed cycle
    save_cycle_summary(cycle_summary)
    
    return cycle_summary

func start_next_cycle():
    if current_state == TURN_ACTIVE_STATE:
        printerr("Cannot start next cycle: turn still active")
        return false
    
    if current_state == BREAK_STATE:
        printerr("Cannot start next cycle: in break time")
        return false
    
    # Increment cycle counter
    current_cycle += 1
    current_turn = 0
    
    # Reset history for the new cycle
    turn_history.clear()
    
    # Update session data
    session_data.last_activity = "cycle_started"
    
    # Emit signal
    emit_signal("cycle_started", current_cycle)
    print("Cycle ", current_cycle, " started")
    
    # Start first turn of the new cycle
    return start_next_turn()

func get_current_state():
    var state_name = ""
    match current_state:
        IDLE_STATE:
            state_name = "idle"
        TURN_ACTIVE_STATE:
            state_name = "turn_active"
        BREAK_STATE:
            state_name = "break"
        CYCLE_COMPLETE_STATE:
            state_name = "cycle_complete"
    
    return {
        "state": current_state,
        "state_name": state_name,
        "current_turn": current_turn,
        "max_turns": max_turns,
        "current_cycle": current_cycle,
        "is_turn_active": is_turn_active,
        "is_in_break": is_in_break,
        "break_time_remaining": break_timer.time_left if is_in_break else 0,
        "turn_time_remaining": turn_timer.time_left if is_turn_active else 0,
        "turn_time_elapsed": OS.get_unix_time() - turn_start_time if is_turn_active else 0
    }

func get_session_stats():
    var current_time = OS.get_unix_time()
    var session_duration = current_time - session_start_time
    
    return {
        "session_start": session_start_time,
        "session_duration": session_duration,
        "current_cycle": current_cycle,
        "cycles_completed": session_data.cycles_completed,
        "current_turn": current_turn,
        "turns_completed": session_data.turns_completed,
        "active_time": session_data.active_time_total,
        "break_time": session_data.break_time_total,
        "idle_time": session_duration - session_data.active_time_total - session_data.break_time_total,
        "last_activity": session_data.last_activity
    }

func save_session_state(file_path="user://turn_system/session_state.json"):
    _ensure_directory_exists(file_path.get_base_dir())
    
    var file = File.new()
    var err = file.open(file_path, File.WRITE)
    if err != OK:
        printerr("Failed to save session state: ", err)
        return false
    
    var session_state = {
        "session_data": session_data,
        "current_turn": current_turn,
        "current_cycle": current_cycle,
        "is_turn_active": is_turn_active,
        "is_in_break": is_in_break,
        "state": current_state,
        "max_turns": max_turns,
        "break_duration": break_duration,
        "turn_timeout": turn_timeout,
        "auto_start_next_turn": auto_start_next_turn,
        "auto_start_next_cycle": auto_start_next_cycle,
        "timestamp": OS.get_unix_time()
    }
    
    file.store_string(JSON.print(session_state, "  "))
    file.close()
    
    return true

func save_turn_state(turn_data, file_path=""):
    if file_path.empty():
        file_path = "user://turn_system/turns/turn_" + str(current_cycle) + "_" + str(current_turn) + ".json"
    
    _ensure_directory_exists(file_path.get_base_dir())
    
    var file = File.new()
    var err = file.open(file_path, File.WRITE)
    if err != OK:
        printerr("Failed to save turn state: ", err)
        return false
    
    file.store_string(JSON.print(turn_data, "  "))
    file.close()
    
    return true

func save_cycle_summary(cycle_summary, file_path=""):
    if file_path.empty():
        file_path = "user://turn_system/cycles/cycle_" + str(current_cycle) + ".json"
    
    _ensure_directory_exists(file_path.get_base_dir())
    
    var file = File.new()
    var err = file.open(file_path, File.WRITE)
    if err != OK:
        printerr("Failed to save cycle summary: ", err)
        return false
    
    file.store_string(JSON.print(cycle_summary, "  "))
    file.close()
    
    return true

func load_session_state(file_path="user://turn_system/session_state.json"):
    var file = File.new()
    if !file.file_exists(file_path):
        print("No saved session state found")
        return false
    
    var err = file.open(file_path, File.READ)
    if err != OK:
        printerr("Failed to load session state: ", err)
        return false
    
    var json = JSON.parse(file.get_as_text())
    file.close()
    
    if json.error != OK:
        printerr("Failed to parse session state JSON: ", json.error_string)
        return false
    
    var state = json.result
    
    # Restore session state
    session_data = state.session_data
    current_turn = state.current_turn
    current_cycle = state.current_cycle
    is_turn_active = state.is_turn_active
    is_in_break = state.is_in_break
    current_state = state.state
    max_turns = state.max_turns
    break_duration = state.break_duration
    turn_timeout = state.turn_timeout
    auto_start_next_turn = state.auto_start_next_turn
    auto_start_next_cycle = state.auto_start_next_cycle
    
    session_start_time = session_data.start_time
    
    # Restore active timers if needed
    if is_in_break:
        var elapsed = OS.get_unix_time() - state.timestamp
        var remaining = max(0, break_duration - elapsed)
        
        if remaining > 0:
            break_timer.wait_time = remaining
            break_timer.start()
        else:
            _end_break()
    
    if is_turn_active:
        var elapsed = OS.get_unix_time() - state.timestamp
        var remaining = max(0, turn_timeout - elapsed)
        
        if remaining > 0:
            turn_timer.wait_time = remaining
            turn_timer.start()
        else:
            _on_turn_timer_timeout()
    
    print("Session state loaded from: ", file_path)
    return true

func _ensure_directory_exists(dir_path):
    var dir = Directory.new()
    if !dir.dir_exists(dir_path):
        dir.make_dir_recursive(dir_path)
        return true
    return false

func reset():
    # Stop all timers
    turn_timer.stop()
    break_timer.stop()
    
    # Reset state
    _initialize_session_data()
    
    current_state = IDLE_STATE
    is_turn_active = false
    is_in_break = false
    
    print("Turn system reset")
    save_session_state()
    
    return true