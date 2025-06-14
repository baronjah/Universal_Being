extends Node

class_name UsageTimeTracker

# ----- TIME TRACKING SETTINGS -----
@export_category("Usage Time Settings")
@export var tracking_enabled: bool = true
@export var hourly_limit: float = 1.0  # Limit in hours
@export var show_notifications: bool = true
@export var auto_save_interval: float = 60.0  # Save every minute
@export var max_log_lines: int = 888  # Maximum log lines for lucky purposes
@export var lucky_number: int = 1333  # Lucky number for special features

# ----- TIME TRACKING VARIABLES -----
var current_session_time: float = 0.0
var total_usage_time: float = 0.0  # Total time across all sessions
var session_start_time: float = 0.0
var last_saved_time: float = 0.0

# ----- TURN SYSTEM INTEGRATION -----
var turn_system: Node = null
var current_turn: int = 1

# ----- TIMER REFERENCES -----
var save_timer: Timer
var blink_timer: Timer
var notification_timer: Timer

# ----- VISUAL INDICATORS -----
var current_blink_state: bool = false
var blink_speed: float = 0.5  # How fast the indicators blink (in seconds)
var color_layers: Array[Color] = [
    Color(1.0, 0.3, 0.3),  # Layer 1 - First hour
    Color(0.3, 1.0, 0.3),  # Layer 2 - Second hour
    Color(0.3, 0.3, 1.0)   # Layer 3 - Third hour and beyond
]
var current_color_layer: int = 0

# ----- DATA PATHS -----
var usage_data_path: String = "user://usage_time_data.json"
var usage_log_path: String = "user://usage_time_log.txt"

# ----- SIGNALS -----
signal time_updated(current_session_time, total_usage_time)
signal hour_limit_reached(hours_used)
signal color_layer_changed(layer_index, color)
signal blink_state_changed(is_on)
signal usage_data_saved()

# ----- INITIALIZATION -----
func _ready():
    _initialize_timers()
    _load_usage_data()
    
    # Record session start time
    session_start_time = Time.get_unix_time_from_system()
    
    # Try to find turn system
    _find_turn_system()
    
    print("Usage Time Tracker initialized")
    print("Total usage time: " + format_time(total_usage_time))

# ----- TIMER SETUP -----
func _initialize_timers():
    # Save timer
    save_timer = Timer.new()
    save_timer.wait_time = auto_save_interval
    save_timer.one_shot = false
    save_timer.autostart = true
    save_timer.connect("timeout", _on_save_timer_timeout)
    add_child(save_timer)
    
    # Blink timer
    blink_timer = Timer.new()
    blink_timer.wait_time = blink_speed
    blink_timer.one_shot = false
    blink_timer.autostart = true
    blink_timer.connect("timeout", _on_blink_timer_timeout)
    add_child(blink_timer)
    
    # Notification timer - for hourly notifications
    notification_timer = Timer.new()
    notification_timer.wait_time = 3600.0  # 1 hour
    notification_timer.one_shot = false
    notification_timer.autostart = true
    notification_timer.connect("timeout", _on_notification_timer_timeout)
    add_child(notification_timer)

# ----- PROCESS -----
func _process(delta):
    if not tracking_enabled:
        return
    
    # Update session time
    current_session_time += delta
    total_usage_time += delta
    
    # Check for color layer changes based on hours played
    var hours_used = total_usage_time / 3600.0
    var new_layer = min(floor(hours_used), color_layers.size() - 1)
    
    if new_layer != current_color_layer:
        current_color_layer = new_layer
        emit_signal("color_layer_changed", current_color_layer, color_layers[current_color_layer])
    
    # Check if we've reached the hourly limit
    if hours_used >= hourly_limit and show_notifications:
        # Only emit once per hour
        if floor(hours_used) > floor((total_usage_time - delta) / 3600.0):
            emit_signal("hour_limit_reached", floor(hours_used))
    
    # Emit regular updates
    emit_signal("time_updated", current_session_time, total_usage_time)
    
    # Update turn information if turn system is available
    if turn_system and turn_system.has_method("get_current_turn"):
        var new_turn = turn_system.get_current_turn()
        if new_turn != current_turn:
            current_turn = new_turn
            _log_turn_change(current_turn)

# ----- TURN SYSTEM INTEGRATION -----
func _find_turn_system():
    # Try to find an existing turn system in the scene
    var potential_systems = get_tree().get_nodes_in_group("turn_systems")
    if potential_systems.size() > 0:
        turn_system = potential_systems[0]
        print("Found turn system: " + turn_system.name)
        current_turn = turn_system.current_turn if turn_system.has_method("get_current_turn") else 1
    else:
        # Find using class name
        var root = get_tree().root
        turn_system = _find_node_by_class(root, "TurnSystem")
        if not turn_system:
            turn_system = _find_node_by_class(root, "TurnCycleController")
            
        if turn_system:
            print("Found turn system by class: " + turn_system.name)
            current_turn = turn_system.current_turn if turn_system.has_method("get_current_turn") else 1

func _find_node_by_class(node, class_name):
    if node.get_class() == class_name:
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name)
        if found:
            return found
    
    return null

func _log_turn_change(new_turn):
    # Add turn change to usage log
    var turn_data = {
        "timestamp": Time.get_unix_time_from_system(),
        "turn": new_turn,
        "session_time": current_session_time,
        "total_time": total_usage_time
    }
    
    # We would save this to a turn log file
    print("Turn changed to: " + str(new_turn) + " at session time: " + format_time(current_session_time))

# ----- DATA MANAGEMENT -----
func _save_usage_data():
    var lucky_timestamp = Time.get_unix_time_from_system()
    # Add lucky number if total time approaches it
    var lucky_check = int(total_usage_time) % lucky_number
    var is_lucky = lucky_check > (lucky_number - 10) and lucky_check < lucky_number
    
    var usage_data = {
        "last_saved": lucky_timestamp,
        "total_usage_time": total_usage_time,
        "session_history": [
            {
                "start_time": session_start_time,
                "duration": current_session_time,
                "end_time": lucky_timestamp,
                "is_lucky_session": is_lucky
            }
        ],
        "lucky_stats": {
            "lucky_number": lucky_number,
            "proximity": lucky_check,
            "is_lucky": is_lucky
        }
    }
    
    var file = FileAccess.open(usage_data_path, FileAccess.WRITE)
    if file:
        var json_string = JSON.stringify(usage_data, "  ")
        file.store_string(json_string)
        file.close()
        last_saved_time = total_usage_time
        emit_signal("usage_data_saved")
        
        # Also log to the log file with max line limit
        _log_usage_event("Session saved", is_lucky)
    else:
        push_error("Failed to save usage data")

func _load_usage_data():
    if FileAccess.file_exists(usage_data_path):
        var file = FileAccess.open(usage_data_path, FileAccess.READ)
        if file:
            var content = file.get_as_text()
            var json = JSON.new()
            var error = json.parse(content)
            
            if error == OK:
                var data = json.get_data()
                total_usage_time = data.get("total_usage_time", 0.0)
                # We don't reset session_time as this is a new session
                
                print("Loaded usage data: " + str(data))
            else:
                push_error("Failed to parse usage data JSON")
            
            file.close()
    else:
        # First time using the system, initialize with zeros
        total_usage_time = 0.0
        _save_usage_data()

# ----- TIMER CALLBACKS -----
func _on_save_timer_timeout():
    if tracking_enabled:
        _save_usage_data()

func _on_blink_timer_timeout():
    current_blink_state = !current_blink_state
    emit_signal("blink_state_changed", current_blink_state)

func _on_notification_timer_timeout():
    if tracking_enabled and show_notifications:
        var hours_used = floor(total_usage_time / 3600.0)
        print("You've been using the system for " + str(hours_used) + " hours")
        
        if hours_used >= hourly_limit:
            print("You've reached your hourly limit of " + str(hourly_limit) + " hours")

# ----- UTILITY FUNCTIONS -----
func format_time(seconds: float) -> String:
    var hours = floor(seconds / 3600.0)
    var minutes = floor((seconds - hours * 3600.0) / 60.0)
    var secs = floor(seconds - hours * 3600.0 - minutes * 60.0)
    
    if hours > 0:
        return "%02d:%02d:%02d" % [hours, minutes, secs]
    else:
        return "%02d:%02d" % [minutes, secs]

func get_color_for_current_time() -> Color:
    return color_layers[current_color_layer]

func get_usage_summary() -> Dictionary:
    # Calculate lucky status
    var lucky_check = int(total_usage_time) % lucky_number
    var is_lucky = lucky_check > (lucky_number - 10) and lucky_check < lucky_number
    var lucky_proximity = abs(lucky_check - lucky_number)
    
    return {
        "current_session_time": current_session_time,
        "total_usage_time": total_usage_time,
        "formatted_session_time": format_time(current_session_time),
        "formatted_total_time": format_time(total_usage_time),
        "hours_used": floor(total_usage_time / 3600.0),
        "minutes_used": floor((total_usage_time % 3600.0) / 60.0),
        "current_turn": current_turn,
        "hourly_limit": hourly_limit,
        "over_limit": (total_usage_time / 3600.0) > hourly_limit,
        "current_color": color_layers[current_color_layer],
        "blink_state": current_blink_state,
        "lucky": {
            "number": lucky_number,
            "is_lucky": is_lucky,
            "proximity": lucky_proximity,
            "proximity_percent": (1.0 - (float(lucky_proximity) / float(lucky_number))) * 100.0
        }
    }

# ----- PUBLIC API -----
func reset_session():
    current_session_time = 0.0
    session_start_time = Time.get_unix_time_from_system()
    
func add_usage_time(additional_seconds: float):
    current_session_time += additional_seconds
    total_usage_time += additional_seconds
    
func set_hourly_limit(hours: float) -> bool:
    if hours <= 0:
        return false
        
    hourly_limit = hours
    return true
    
func toggle_tracking() -> bool:
    tracking_enabled = !tracking_enabled
    return tracking_enabled

func toggle_notifications() -> bool:
    show_notifications = !show_notifications
    return show_notifications