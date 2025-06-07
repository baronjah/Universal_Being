extends Node

class_name UsageTimeTrackerWithExtensions

# This class extends the base UsageTimeTracker to add support for extensions:
# 1. Neural net shape visualization
# 2. Auto-updating capabilities
# 3. Lucky number integration

# ----- TIME TRACKING SETTINGS -----
@export_category("Extended Time Tracking")
@export var use_neural_visualization: bool = true
@export var auto_update_enabled: bool = true
@export var lucky_numbers_enabled: bool = true
@export var line_limit: int = 888
@export var lucky_sequence: Array = [8, 88, 888, 1333]

# ----- COMPONENT REFERENCES -----
var base_tracker: Node = null
var visualizer: Node = null
var auto_updater: Node = null

# ----- LOGGING -----
var log_buffer = []
var log_file_path = "user://time_tracking_log.txt"

# ----- SIGNALS -----
signal neural_updated(memory_stats)
signal lucky_event_occurred(number, proximity)

# ----- INITIALIZATION -----
func _ready():
    # Create the base time tracker
    base_tracker = UsageTimeTracker.new()
    base_tracker.name = "BaseTracker"
    base_tracker.max_log_lines = line_limit
    
    # Update lucky number
    if lucky_numbers_enabled:
        base_tracker.lucky_number = lucky_sequence[-1]
    
    add_child(base_tracker)
    
    # Create neural visualizer if enabled
    if use_neural_visualization:
        visualizer = ShapeMemoryVisualizer.new()
        visualizer.name = "MemoryVisualizer"
        visualizer.max_nodes = min(line_limit / 10, 100)
        visualizer.number_sequence = lucky_sequence
        visualizer.lucky_number = lucky_sequence[-1]
        add_child(visualizer)
    
    # Create auto updater if enabled
    if auto_update_enabled:
        auto_updater = AutoTrackerUpdate.new()
        auto_updater.name = "AutoUpdater"
        add_child(auto_updater)
    
    # Ensure log file exists with max line count limit
    _init_log_file()
    
    # Log initialization
    _log_message("Extended time tracker initialized - Lucky numbers: " + str(lucky_sequence))

# ----- PROCESS -----
func _process(delta):
    # Check for lucky events from base tracker
    if lucky_numbers_enabled and base_tracker:
        var usage_summary = base_tracker.get_usage_summary()
        if usage_summary.has("lucky") and usage_summary.lucky.is_lucky:
            emit_signal("lucky_event_occurred", usage_summary.lucky.number, usage_summary.lucky.proximity)
    
    # Update neural visualization with current memory stats
    if use_neural_visualization and visualizer:
        # Calculate memory stats based on total time
        var memory_stats = _calculate_memory_stats()
        emit_signal("neural_updated", memory_stats)

# ----- LOGGING -----
func _init_log_file():
    # Create log file if it doesn't exist
    if not FileAccess.file_exists(log_file_path):
        var file = FileAccess.open(log_file_path, FileAccess.WRITE)
        if file:
            file.store_string("=== Time Tracking Log (max " + str(line_limit) + " lines) ===\n")
            file.close()
    else:
        # Ensure the file isn't too long
        _enforce_line_limit()

func _log_message(message):
    var timestamp = Time.get_datetime_string_from_system()
    var log_entry = "[" + timestamp + "] " + message
    
    # Add to buffer
    log_buffer.append(log_entry)
    
    # Keep buffer at reasonable size
    if log_buffer.size() > 20:
        log_buffer.remove_at(0)
    
    # Log to file
    var file = FileAccess.open(log_file_path, FileAccess.READ_WRITE)
    if file:
        file.seek_end()
        file.store_line(log_entry)
        file.close()
        
        # Check if we need to enforce line limit
        if file.get_length() > line_limit * 100:  # Rough estimate
            _enforce_line_limit()

func _enforce_line_limit():
    var file = FileAccess.open(log_file_path, FileAccess.READ)
    if file:
        var lines = []
        while not file.eof_reached():
            lines.append(file.get_line())
        file.close()
        
        # If too many lines, keep only the newest ones
        if lines.size() > line_limit:
            lines = lines.slice(lines.size() - line_limit, lines.size())
            
            # Write back to file
            file = FileAccess.open(log_file_path, FileAccess.WRITE)
            if file:
                for line in lines:
                    file.store_line(line)
                file.close()

# ----- MEMORY STATS -----
func _calculate_memory_stats():
    if not base_tracker:
        return {}
    
    var usage_summary = base_tracker.get_usage_summary()
    
    # Calculate memory usage stats for visualization
    var memory_usage = min(1.0, usage_summary.total_usage_time / (3600.0 * 4))  # Max out at 4 hours
    var session_percentage = min(1.0, usage_summary.current_session_time / 3600.0)
    var lucky_percentage = 0.0
    
    if usage_summary.has("lucky"):
        lucky_percentage = usage_summary.lucky.proximity_percent / 100.0
    
    return {
        "total_memory_usage": memory_usage,
        "session_percentage": session_percentage,
        "lucky_percentage": lucky_percentage,
        "current_turn": usage_summary.current_turn,
        "hours_used": usage_summary.hours_used,
        "is_lucky": usage_summary.has("lucky") and usage_summary.lucky.is_lucky
    }

# ----- PUBLIC API -----
func get_usage_summary():
    if base_tracker:
        return base_tracker.get_usage_summary()
    return {}

func set_hourly_limit(hours: float):
    if base_tracker:
        return base_tracker.set_hourly_limit(hours)
    return false

func toggle_neural_visualization():
    use_neural_visualization = !use_neural_visualization
    
    if use_neural_visualization and not visualizer:
        visualizer = ShapeMemoryVisualizer.new()
        visualizer.name = "MemoryVisualizer"
        visualizer.max_nodes = min(line_limit / 10, 100)
        visualizer.number_sequence = lucky_sequence
        visualizer.lucky_number = lucky_sequence[-1]
        add_child(visualizer)
    elif visualizer:
        visualizer.enabled = use_neural_visualization
    
    return use_neural_visualization

func cycle_lucky_number():
    # Cycle to next lucky number in sequence
    var current_index = lucky_sequence.find(base_tracker.lucky_number)
    var next_index = (current_index + 1) % lucky_sequence.size()
    var new_lucky = lucky_sequence[next_index]
    
    # Update tracker
    if base_tracker:
        base_tracker.lucky_number = new_lucky
    
    # Update visualizer
    if visualizer:
        visualizer.set_lucky_number(new_lucky)
        visualizer.force_next_number()
    
    _log_message("Lucky number changed to: " + str(new_lucky))
    
    return new_lucky

func get_log_buffer():
    return log_buffer.duplicate()

func add_lucky_number(number: int):
    if number > 0 and not lucky_sequence.has(number):
        lucky_sequence.append(number)
        _log_message("Added lucky number: " + str(number))
        
        if visualizer:
            visualizer.set_number_sequence(lucky_sequence)
        
        return true
    
    return false