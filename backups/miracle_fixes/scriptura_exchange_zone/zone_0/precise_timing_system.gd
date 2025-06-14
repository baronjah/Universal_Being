extends Node

class_name PreciseTimingSystem

# ----- PRECISION SETTINGS -----
@export_category("Precision Settings")
@export var enabled: bool = true
@export var use_precise_timing: bool = true
@export var timing_resolution: float = 0.001  # 1ms precision
@export var synchronize_with_system_clock: bool = true
@export var max_timing_drift: float = 0.01  # Maximum allowed drift before correction

# ----- TIME MARKERS -----
@export_category("Time Markers")
@export var hour_markers: Array[int] = [0, 3, 6, 9, 12, 15, 18, 21]  # Key hours
@export var minute_markers: Array[int] = [0, 15, 30, 45]  # Key minutes
@export var second_markers: Array[int] = [0, 15, 30, 45]  # Key seconds

# ----- TURN INTEGRATION -----
@export_category("Turn Integration")
@export var turn_time_mapping: Dictionary = {
    "1": {"hour": 0, "minute": 0},
    "2": {"hour": 2, "minute": 0},
    "3": {"hour": 4, "minute": 0},
    "4": {"hour": 6, "minute": 0},
    "5": {"hour": 8, "minute": 0},
    "6": {"hour": 10, "minute": 0},
    "7": {"hour": 12, "minute": 0},
    "8": {"hour": 14, "minute": 0},
    "9": {"hour": 16, "minute": 0},
    "10": {"hour": 18, "minute": 0},
    "11": {"hour": 20, "minute": 0},
    "12": {"hour": 22, "minute": 0},
    "15": {"hour": 15, "minute": 0}  # Special turn 15
}

# ----- STATE VARIABLES -----
var precise_timer: Timer
var time_offset: float = 0.0
var last_sync_time: int = 0
var current_turn: int = 1
var registered_callbacks = {}
var active_timers = {}
var turn_controller = null
var blink_controller = null

# ----- SIGNALS -----
signal time_marker_reached(hour, minute, second, marker_type)
signal sync_performed(drift_corrected)
signal precision_timer_tick(time_ms)
signal turn_time_reached(turn_number)

# ----- INITIALIZATION -----
func _ready():
    # Initialize timer for precision timing
    _initialize_timer()
    
    # Find turn controller
    turn_controller = get_node_or_null("/root/TurnController")
    if not turn_controller:
        turn_controller = _find_node_by_class(get_tree().root, "TurnController")
    
    # Find blink controller
    blink_controller = get_node_or_null("/root/BlinkAnimationController")
    if not blink_controller:
        blink_controller = _find_node_by_class(get_tree().root, "BlinkAnimationController")
    
    # Connect to turn controller if available
    if turn_controller:
        turn_controller.connect("turn_started", Callable(self, "_on_turn_started"))
        turn_controller.register_system(self)
        current_turn = turn_controller.get_current_turn()
    
    # Synchronize with system time
    if synchronize_with_system_clock:
        _sync_with_system_time()
    
    # Start timing system if enabled
    if enabled:
        precise_timer.start()
    
    print("Precise Timing System initialized")
    print("Timing resolution: " + str(timing_resolution * 1000) + "ms")
    print("Current turn: " + str(current_turn))

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

func _initialize_timer():
    # Create high precision timer
    precise_timer = Timer.new()
    precise_timer.wait_time = timing_resolution
    precise_timer.one_shot = false
    precise_timer.connect("timeout", Callable(self, "_on_precise_timer_timeout"))
    add_child(precise_timer)

# ----- TIMING FUNCTIONS -----
func _on_precise_timer_timeout():
    if not enabled:
        return
    
    # Get current time
    var current_time = Time.get_time_dict_from_system()
    var current_ms = OS.get_ticks_msec()
    
    # Check if we need to sync with system time
    if synchronize_with_system_clock and current_ms - last_sync_time > 60000:  # Sync every minute
        _sync_with_system_time()
    
    # Emit precision timer tick signal
    emit_signal("precision_timer_tick", current_ms)
    
    # Check time markers
    _check_time_markers(current_time)
    
    # Check active timers
    _update_active_timers(current_ms)
    
    # Check for turn-specific time triggers
    _check_turn_time_triggers(current_time)

func _sync_with_system_time():
    # Calculate timing drift and correct if needed
    var godot_time = OS.get_ticks_msec() / 1000.0
    var system_time = Time.get_unix_time_from_system()
    var drift = system_time - godot_time - time_offset
    
    if abs(drift) > max_timing_drift:
        time_offset += drift
        emit_signal("sync_performed", drift)
        
        if OS.is_debug_build():
            print("Time sync performed, corrected drift of " + str(drift) + "s")
    
    last_sync_time = OS.get_ticks_msec()

func _check_time_markers(time_dict):
    # Check if current time hits any of our markers
    var hour = time_dict.hour
    var minute = time_dict.minute
    var second = time_dict.second
    
    # Check hour markers
    if minute == 0 and second == 0 and hour_markers.has(hour):
        emit_signal("time_marker_reached", hour, minute, second, "hour")
        _trigger_hour_marker_callbacks(hour)
    
    # Check minute markers
    if second == 0 and minute_markers.has(minute):
        emit_signal("time_marker_reached", hour, minute, second, "minute")
        _trigger_minute_marker_callbacks(hour, minute)
    
    # Check second markers
    if second_markers.has(second):
        emit_signal("time_marker_reached", hour, minute, second, "second")
        _trigger_second_marker_callbacks(hour, minute, second)

func _update_active_timers(current_ms):
    # Check and update active timers
    var completed_timers = []
    
    for timer_id in active_timers:
        var timer_data = active_timers[timer_id]
        
        if current_ms >= timer_data.end_time:
            # Timer completed
            completed_timers.append(timer_id)
            
            # Call callback if present
            if timer_data.has("callback") and timer_data.callback is Callable:
                timer_data.callback.call()
    
    # Remove completed timers
    for timer_id in completed_timers:
        active_timers.erase(timer_id)

func _check_turn_time_triggers(time_dict):
    # Check if current time matches any turn time mapping
    var hour = time_dict.hour
    var minute = time_dict.minute
    
    for turn_str in turn_time_mapping:
        var turn_data = turn_time_mapping[turn_str]
        var turn_number = int(turn_str)
        
        if turn_data.hour == hour and turn_data.minute == minute and time_dict.second == 0:
            # This turn's time has been reached
            emit_signal("turn_time_reached", turn_number)
            
            # Auto-transition to this turn if applicable
            if turn_controller and turn_number != current_turn:
                # Only do this once per minute
                _handle_turn_time_trigger(turn_number)
                
                # Special effect for turn 15
                if turn_number == 15:
                    _trigger_turn15_sequence()

func _handle_turn_time_trigger(turn_number):
    # Handle a turn time trigger event
    print("Turn " + str(turn_number) + " time trigger activated at " + _format_current_time())
    
    # If turn controller exists, notify it
    if turn_controller:
        if turn_controller.has_method("set_turn"):
            # Wait a moment for dramatic effect
            await get_tree().create_timer(1.0).timeout
            turn_controller.set_turn(turn_number)

func _trigger_turn15_sequence():
    # Special sequence for turn 15
    print("Initiating Turn 15 sequence - Precisely 15")
    
    # Triple flicker effect if blink controller exists
    if blink_controller:
        blink_controller.trigger_flicker("", 15)  # 15 flickers for turn 15
    
    # Visual effect sequence
    for i in range(5):
        # Create a tempo of exactly 15 beats per minute (4 seconds per beat)
        await get_tree().create_timer(4.0).timeout
        
        if blink_controller:
            if i % 3 == 0:
                blink_controller.trigger_blink("", 1)
            elif i % 3 == 1:
                blink_controller.trigger_wink("", i % 2 == 0)
            else:
                blink_controller.trigger_flicker("", 3)

# ----- CALLBACK REGISTRATION -----
func _trigger_hour_marker_callbacks(hour):
    var key = "hour_" + str(hour)
    if registered_callbacks.has(key):
        for callback in registered_callbacks[key]:
            if callback is Callable:
                callback.call(hour)

func _trigger_minute_marker_callbacks(hour, minute):
    var key = "hour_" + str(hour) + "_minute_" + str(minute)
    if registered_callbacks.has(key):
        for callback in registered_callbacks[key]:
            if callback is Callable:
                callback.call(hour, minute)

func _trigger_second_marker_callbacks(hour, minute, second):
    var key = "hour_" + str(hour) + "_minute_" + str(minute) + "_second_" + str(second)
    if registered_callbacks.has(key):
        for callback in registered_callbacks[key]:
            if callback is Callable:
                callback.call(hour, minute, second)

# ----- TURN SYSTEM INTEGRATION -----
func _on_turn_started(turn_number):
    # Update current turn
    current_turn = turn_number
    
    print("Turn " + str(turn_number) + " started at " + _format_current_time())
    
    # Special handling for turn 15
    if turn_number == 15:
        _on_turn15_started()

func _on_turn15_started():
    # Special handling for turn 15
    print("Turn 15 started - Initializing precise timing mode")
    
    # Set maximum precision
    timing_resolution = 0.001  # 1ms
    precise_timer.wait_time = timing_resolution
    
    # Ensure synchronization is active
    synchronize_with_system_clock = true
    _sync_with_system_time()
    
    # Set up special marker for exactly 15:00:00
    register_time_callback(15, 0, 0, func(h, m, s):
        print("⌚ EXACTLY 15:00:00 REACHED ⌚")
        _trigger_turn15_sequence()
    )

# ----- PUBLIC API -----
func register_time_callback(hour: int, minute: int, second: int, callback: Callable) -> bool:
    # Register a callback for a specific time
    var key = "hour_" + str(hour) + "_minute_" + str(minute) + "_second_" + str(second)
    
    if not registered_callbacks.has(key):
        registered_callbacks[key] = []
    
    registered_callbacks[key].append(callback)
    
    print("Registered callback for time " + str(hour) + ":" + str(minute) + ":" + str(second))
    
    return true

func register_hour_callback(hour: int, callback: Callable) -> bool:
    # Register a callback for a specific hour
    var key = "hour_" + str(hour)
    
    if not registered_callbacks.has(key):
        registered_callbacks[key] = []
    
    registered_callbacks[key].append(callback)
    
    print("Registered callback for hour " + str(hour))
    
    return true

func register_minute_callback(hour: int, minute: int, callback: Callable) -> bool:
    # Register a callback for a specific hour and minute
    var key = "hour_" + str(hour) + "_minute_" + str(minute)
    
    if not registered_callbacks.has(key):
        registered_callbacks[key] = []
    
    registered_callbacks[key].append(callback)
    
    print("Registered callback for time " + str(hour) + ":" + str(minute))
    
    return true

func create_timer(duration_ms: int, callback: Callable = Callable()) -> int:
    # Create a precise timer with optional callback
    var timer_id = randi() % 1000000
    
    active_timers[timer_id] = {
        "start_time": OS.get_ticks_msec(),
        "end_time": OS.get_ticks_msec() + duration_ms,
        "duration": duration_ms,
        "callback": callback
    }
    
    return timer_id

func cancel_timer(timer_id: int) -> bool:
    # Cancel an active timer
    if active_timers.has(timer_id):
        active_timers.erase(timer_id)
        return true
    
    return false

func get_timer_remaining(timer_id: int) -> int:
    # Get remaining time for a timer in milliseconds
    if not active_timers.has(timer_id):
        return -1
    
    var timer_data = active_timers[timer_id]
    var current_ms = OS.get_ticks_msec()
    var remaining = timer_data.end_time - current_ms
    
    return max(0, remaining)

func set_enabled(is_enabled: bool) -> void:
    # Enable or disable the timing system
    enabled = is_enabled
    
    if enabled:
        precise_timer.start()
    else:
        precise_timer.stop()
    
    print("Precise timing system " + ("enabled" if enabled else "disabled"))

func get_current_formatted_time() -> String:
    # Get current time as formatted string
    return _format_current_time()

func on_turn_changed(turn_number: int, turn_data: Dictionary) -> void:
    # Required method for turn system integration
    current_turn = turn_number
    
    # Special case for turn 15
    if turn_number == 15:
        _on_turn15_started()

# ----- UTILITY FUNCTIONS -----
func _format_current_time() -> String:
    var time = Time.get_time_dict_from_system()
    return "%02d:%02d:%02d" % [time.hour, time.minute, time.second]