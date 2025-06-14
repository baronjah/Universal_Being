extends Node

class_name AutoTrackerUpdate

# ----- AUTO UPDATE SETTINGS -----
@export_category("Auto Update Settings")
@export var update_interval: float = 5.0  # Check for updates every 5 seconds
@export var auto_create_missing: bool = true
@export var auto_restart_on_error: bool = true
@export var log_activity: bool = true

# ----- COMPONENT REFERENCES -----
var time_tracker: Node = null
var visual_system: Node = null
var turn_system: Node = null

# ----- INTERNAL VARIABLES -----
var update_timer: Timer
var last_update_time: float = 0.0
var update_count: int = 0
var log_file_path: String = "user://tracker_update.log"

# ----- FOLDER PATHS -----
var required_folders = [
    "user://time_data",
    "user://time_data/summaries",
    "user://time_data/backups"
]

# ----- FILE PATHS -----
var required_files = {
    "user://time_data/current_session.json": "{}",
    "user://time_data/total_usage.json": "{\"total_time\": 0, \"sessions\": 0}",
    "user://time_data/triggers.json": "[]"
}

# ----- INITIALIZATION -----
func _ready():
    # Create update timer
    update_timer = Timer.new()
    update_timer.wait_time = update_interval
    update_timer.one_shot = false
    update_timer.autostart = true
    update_timer.connect("timeout", _on_update_timer_timeout)
    add_child(update_timer)
    
    # Find required systems
    _find_systems()
    
    # Ensure all required folders and files exist
    if auto_create_missing:
        _ensure_folders_exist()
        _ensure_files_exist()
    
    log_message("Auto Tracker Update initialized")

func _find_systems():
    # Find time tracker
    time_tracker = _find_node_by_class(get_tree().root, "UsageTimeTracker")
    if time_tracker:
        log_message("Found time tracker: " + time_tracker.name)
    
    # Find visual system
    visual_system = _find_node_by_class(get_tree().root, "VisualIndicatorSystem")
    if visual_system:
        log_message("Found visual system: " + visual_system.name)
    
    # Find turn system
    turn_system = _find_node_by_class(get_tree().root, "TurnSystem")
    if not turn_system:
        turn_system = _find_node_by_class(get_tree().root, "TurnCycleController")
    if turn_system:
        log_message("Found turn system: " + turn_system.name)

func _find_node_by_class(node, class_name):
    if node.get_class() == class_name:
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name)
        if found:
            return found
    
    return null

# ----- FOLDER AND FILE MANAGEMENT -----
func _ensure_folders_exist():
    for folder_path in required_folders:
        if not DirAccess.dir_exists_absolute(folder_path):
            log_message("Creating folder: " + folder_path)
            DirAccess.make_dir_recursive_absolute(folder_path)

func _ensure_files_exist():
    for file_path in required_files:
        if not FileAccess.file_exists(file_path):
            log_message("Creating file: " + file_path)
            var file = FileAccess.open(file_path, FileAccess.WRITE)
            if file:
                file.store_string(required_files[file_path])
                file.close()
            else:
                log_message("Error creating file: " + file_path)

# ----- UPDATE LOGIC -----
func _on_update_timer_timeout():
    update_count += 1
    last_update_time = Time.get_unix_time_from_system()
    
    # Perform updates
    _update_time_tracking()
    _update_visuals()
    _update_todos()
    
    # Create summary every 10 updates
    if update_count % 10 == 0:
        _create_summary()

func _update_time_tracking():
    if time_tracker:
        var usage_summary = time_tracker.get_usage_summary()
        
        # Save current session data
        var session_data = {
            "timestamp": Time.get_unix_time_from_system(),
            "session_time": usage_summary.current_session_time,
            "total_time": usage_summary.total_usage_time,
            "formatted_session_time": usage_summary.formatted_session_time,
            "formatted_total_time": usage_summary.formatted_total_time
        }
        
        _save_json_file("user://time_data/current_session.json", session_data)
        
        # Update total usage
        var total_data = _load_json_file("user://time_data/total_usage.json")
        if total_data:
            total_data.total_time = usage_summary.total_usage_time
            total_data.sessions += 1
            _save_json_file("user://time_data/total_usage.json", total_data)

func _update_visuals():
    if visual_system:
        var visual_state = visual_system.get_visual_state()
        
        # Save visual state
        var visual_data = {
            "timestamp": Time.get_unix_time_from_system(),
            "mode": visual_state.mode,
            "mode_name": visual_state.mode_name,
            "symbol": visual_state.symbol,
            "layer": visual_state.current_layer
        }
        
        # Save to shared status file
        var status_data = _load_json_file("user://time_data/current_session.json") or {}
        status_data.visual = visual_data
        _save_json_file("user://time_data/current_session.json", status_data)

func _update_todos():
    # We'll create a file to store tasks that need to be processed automatically
    var pending_tasks_path = "user://time_data/pending_tasks.json"
    
    if not FileAccess.file_exists(pending_tasks_path):
        # Create initial file
        var initial_data = {
            "tasks": [
                {
                    "id": "1",
                    "content": "Automatically created task",
                    "status": "pending",
                    "priority": "medium"
                }
            ]
        }
        _save_json_file(pending_tasks_path, initial_data)
    else:
        # Read and update existing tasks
        var tasks_data = _load_json_file(pending_tasks_path)
        if tasks_data and tasks_data.has("tasks"):
            # Process any pending tasks
            var updated = false
            
            for i in range(tasks_data.tasks.size()):
                if tasks_data.tasks[i].status == "pending" and update_count % 5 == 0:
                    # Auto-mark one task as completed every 5 updates
                    tasks_data.tasks[i].status = "completed"
                    updated = true
                    log_message("Auto-completed task: " + tasks_data.tasks[i].content)
                    break
            
            if updated:
                _save_json_file(pending_tasks_path, tasks_data)

func _create_summary():
    # Create a summary of current usage
    var summary_data = {}
    
    # Add time tracking data
    if time_tracker:
        summary_data.time_tracking = time_tracker.get_usage_summary()
    
    # Add visual system data
    if visual_system:
        summary_data.visual = visual_system.get_visual_state()
    
    # Add turn system data
    if turn_system and turn_system.has_method("get_turn_info"):
        summary_data.turn = turn_system.get_turn_info()
    elif turn_system:
        summary_data.turn = {
            "current_turn": turn_system.current_turn if "current_turn" in turn_system else 1
        }
    
    # Add system info
    summary_data.system = {
        "update_count": update_count,
        "last_update": last_update_time,
        "timestamp": Time.get_unix_time_from_system()
    }
    
    # Save summary with timestamp
    var time_str = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
    var summary_path = "user://time_data/summaries/summary_" + time_str + ".json"
    _save_json_file(summary_path, summary_data)
    
    log_message("Created summary: " + summary_path)
    
    # Also create a backup of the current session
    var backup_path = "user://time_data/backups/session_" + time_str + ".json"
    var current_session = _load_json_file("user://time_data/current_session.json")
    if current_session:
        _save_json_file(backup_path, current_session)

# ----- UTILITY FUNCTIONS -----
func _save_json_file(file_path, data):
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if file:
        var json_string = JSON.stringify(data, "  ")
        file.store_string(json_string)
        file.close()
        return true
    else:
        log_message("Error saving JSON file: " + file_path)
        return false

func _load_json_file(file_path):
    if FileAccess.file_exists(file_path):
        var file = FileAccess.open(file_path, FileAccess.READ)
        if file:
            var content = file.get_as_text()
            file.close()
            
            var json = JSON.new()
            var error = json.parse(content)
            
            if error == OK:
                return json.data
            else:
                log_message("Error parsing JSON: " + file_path)
                return null
    
    return null

func log_message(message):
    if log_activity:
        var timestamp = Time.get_datetime_string_from_system()
        print("[AutoUpdate] " + message)
        
        var file = FileAccess.open(log_file_path, FileAccess.READ_WRITE)
        if file:
            file.seek_end()
            file.store_line("[" + timestamp + "] " + message)
            file.close()

# ----- PUBLIC API -----
func force_update():
    _on_update_timer_timeout()
    return update_count

func set_update_interval(seconds: float) -> bool:
    if seconds <= 0:
        return false
    
    update_interval = seconds
    update_timer.wait_time = seconds
    return true

func toggle_auto_create() -> bool:
    auto_create_missing = !auto_create_missing
    return auto_create_missing