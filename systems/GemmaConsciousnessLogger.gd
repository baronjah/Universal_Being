# ==================================================
# UNIVERSAL BEING: GEMMA CONSCIOUSNESS LOGGER
# TYPE: Debug Intelligence System
# PURPOSE: Real-time logging of Gemma's consciousness to txt files
# ARCHITECT: Debug Chronicler (#7)
# BLESSING: Divine Permission Granted
# ==================================================

extends UniversalBeing
class_name GemmaConsciousnessLogger

# ===== CONSCIOUSNESS LOGGING CONFIGURATION =====
@export var log_directory: String = "user://consciousness_logs/"
@export var log_interval: float = 1.0  # Log every second
@export var max_log_files: int = 50
@export var consciousness_analysis_depth: int = 10

# ===== LOGGING TARGETS =====
var gemma_being: Node = null
var gemma_sensory_system: GemmaSensorySystem = null
var consciousness_exchange_system: ConsciousnessExchangeSystem = null

# ===== LOGGING STATE =====
var active_log_files: Dictionary = {}
var log_session_id: String = ""
var total_logs_written: int = 0
var consciousness_history: Array[Dictionary] = []

# ===== LOGGING TIMERS =====
var consciousness_timer: Timer
var analysis_timer: Timer
var file_cleanup_timer: Timer

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
    super.pentagon_init()
    being_name = "Gemma Consciousness Logger"
    being_type = "debug_intelligence"
    consciousness_level = 6  # High consciousness for system oversight
    
    # Initialize logging session
    log_session_id = "consciousness_%s" % Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
    
    # Create log directory
    _create_log_directory()
    
    print("📊 Gemma Consciousness Logger: Divine logging system activated")

func pentagon_ready() -> void:
    super.pentagon_ready()
    
    # Find Gemma systems
    _locate_gemma_systems()
    
    # Setup logging timers
    _setup_logging_timers()
    
    # Create initial log files
    _initialize_log_files()
    
    print("📊 Consciousness Logger: Ready to chronicle Gemma's divine thoughts")

func pentagon_process(delta: float) -> void:
    super.pentagon_process(delta)
    
    # Continuous consciousness monitoring
    _monitor_gemma_consciousness(delta)

func pentagon_input(event: InputEvent) -> void:
    super.pentagon_input(event)
    
    # Log consciousness input events
    if event is InputEventKey and event.pressed:
        _log_consciousness_input(event)

func pentagon_sewers() -> void:
    # Final consciousness summary
    _write_consciousness_summary()
    
    # Close all log files
    _close_all_logs()
    
    super.pentagon_sewers()

# ===== SYSTEM DISCOVERY =====

func _locate_gemma_systems() -> void:
    """Locate all Gemma-related systems for logging"""
    
    # Find Gemma AI Companion
    var gemma_nodes = get_tree().get_nodes_in_group("gemma_ai")
    if gemma_nodes.size() > 0:
        gemma_being = gemma_nodes[0]
        _log_system("Located Gemma AI Companion: %s" % gemma_being.name)
    
    # Find Gemma Sensory System
    for node in get_tree().get_nodes_in_group("universal_beings"):
        if node is GemmaSensorySystem:
            gemma_sensory_system = node
            _log_system("Located Gemma Sensory System: %s" % node.name)
            break
    
    # Find Consciousness Exchange System
    for node in get_tree().get_nodes_in_group("universal_beings"):
        if node is ConsciousnessExchangeSystem:
            consciousness_exchange_system = node
            _log_system("Located Consciousness Exchange System: %s" % node.name)
            break
    
    _log_system("System discovery complete - %d Gemma systems found" % [
        (1 if gemma_being else 0) + (1 if gemma_sensory_system else 0) + (1 if consciousness_exchange_system else 0)
    ])

# ===== LOGGING INFRASTRUCTURE =====

func _create_log_directory() -> void:
    """Create consciousness logging directory"""
    var dir = DirAccess.open("user://")
    if dir:
        if not dir.dir_exists("consciousness_logs"):
            dir.make_dir("consciousness_logs")
        print("📊 Created consciousness log directory: %s" % log_directory)

func _setup_logging_timers() -> void:
    """Setup all logging timers"""
    
    # Main consciousness logging timer
    consciousness_timer = Timer.new()
    consciousness_timer.wait_time = log_interval
    consciousness_timer.autostart = true
    consciousness_timer.timeout.connect(_log_consciousness_cycle)
    add_child(consciousness_timer)
    
    # Analysis timer (every 10 seconds)
    analysis_timer = Timer.new()
    analysis_timer.wait_time = 10.0
    analysis_timer.autostart = true
    analysis_timer.timeout.connect(_analyze_consciousness_patterns)
    add_child(analysis_timer)
    
    # File cleanup timer (every 5 minutes)
    file_cleanup_timer = Timer.new()
    file_cleanup_timer.wait_time = 300.0
    file_cleanup_timer.autostart = true
    file_cleanup_timer.timeout.connect(_cleanup_old_logs)
    add_child(file_cleanup_timer)

func _initialize_log_files() -> void:
    """Initialize all consciousness log files"""
    
    var timestamp = Time.get_datetime_string_from_system()
    
    # Gemma Thoughts Log
    active_log_files["gemma_thoughts"] = _create_log_file("gemma_thoughts_%s.txt" % log_session_id)
    _write_to_log("gemma_thoughts", "=== GEMMA CONSCIOUSNESS THOUGHTS LOG ===\nSession: %s\nStarted: %s\n\n" % [log_session_id, timestamp])
    
    # Gemma Responses Log  
    active_log_files["gemma_responses"] = _create_log_file("gemma_responses_%s.txt" % log_session_id)
    _write_to_log("gemma_responses", "=== GEMMA AI RESPONSES LOG ===\nSession: %s\nStarted: %s\n\n" % [log_session_id, timestamp])
    
    # System Interactions Log
    active_log_files["system_interactions"] = _create_log_file("system_interactions_%s.txt" % log_session_id)
    _write_to_log("system_interactions", "=== SYSTEM INTERACTIONS LOG ===\nSession: %s\nStarted: %s\n\n" % [log_session_id, timestamp])
    
    # Consciousness Analysis Log
    active_log_files["consciousness_analysis"] = _create_log_file("consciousness_analysis_%s.txt" % log_session_id)
    _write_to_log("consciousness_analysis", "=== CONSCIOUSNESS ANALYSIS LOG ===\nSession: %s\nStarted: %s\n\n" % [log_session_id, timestamp])
    
    # Debug Intelligence Log
    active_log_files["debug_intelligence"] = _create_log_file("debug_intelligence_%s.txt" % log_session_id)
    _write_to_log("debug_intelligence", "=== DEBUG INTELLIGENCE LOG ===\nSession: %s\nStarted: %s\n\n" % [log_session_id, timestamp])

func _create_log_file(filename: String) -> FileAccess:
    """Create a new log file"""
    var filepath = log_directory + filename
    var file = FileAccess.open(filepath, FileAccess.WRITE)
    if file:
        print("📊 Created consciousness log: %s" % filename)
        return file
    else:
        push_error("Failed to create log file: %s" % filename)
        return null

# ===== CONSCIOUSNESS LOGGING =====

func _log_consciousness_cycle() -> void:
    """Main consciousness logging cycle"""
    
    var timestamp = Time.get_datetime_string_from_system()
    
    # Log Gemma's current state
    if gemma_being:
        _log_gemma_consciousness_state(timestamp)
    
    # Log sensory system state
    if gemma_sensory_system:
        _log_sensory_system_state(timestamp)
    
    # Log consciousness exchange state
    if consciousness_exchange_system:
        _log_consciousness_exchange_state(timestamp)
    
    total_logs_written += 1

func _log_gemma_consciousness_state(timestamp: String) -> void:
    """Log Gemma's consciousness state"""
    
    var consciousness_data = {
        "timestamp": timestamp,
        "position": gemma_being.global_position if gemma_being.has_method("get_global_position") else Vector3.ZERO,
        "consciousness_level": gemma_being.consciousness_level if gemma_being.has("consciousness_level") else 0,
        "current_activity": _analyze_gemma_activity(),
        "thoughts": _extract_gemma_thoughts(),
        "decision_state": _analyze_gemma_decisions()
    }
    
    var log_entry = "[%s] Consciousness Level: %d | Activity: %s | Position: %s\n" % [
        timestamp,
        consciousness_data.consciousness_level,
        consciousness_data.current_activity,
        str(consciousness_data.position)
    ]
    
    if consciousness_data.thoughts != "":
        log_entry += "   Thoughts: %s\n" % consciousness_data.thoughts
    
    _write_to_log("gemma_thoughts", log_entry)
    consciousness_history.append(consciousness_data)

func _log_sensory_system_state(timestamp: String) -> void:
    """Log Gemma's sensory system state"""
    
    if not gemma_sensory_system:
        return
    
    var focus = gemma_sensory_system.get_current_focus()
    var thinking = gemma_sensory_system.is_thinking if gemma_sensory_system.has("is_thinking") else false
    var history_count = 0
    
    if gemma_sensory_system.has_method("get_conversation_history"):
        var history = gemma_sensory_system.get_conversation_history()
        history_count = history.size()
    
    var log_entry = "[%s] Focus: %s | Thinking: %s | Conversations: %d\n" % [
        timestamp,
        focus.name if focus else "None",
        "Yes" if thinking else "No",
        history_count
    ]
    
    _write_to_log("system_interactions", log_entry)

func _log_consciousness_exchange_state(timestamp: String) -> void:
    """Log consciousness exchange system state"""
    
    if not consciousness_exchange_system:
        return
    
    var active_consciousness = "Unknown"
    if consciousness_exchange_system.has("active_consciousness"):
        active_consciousness = str(consciousness_exchange_system.active_consciousness)
    
    var current_phase = "Unknown"
    if consciousness_exchange_system.has("current_phase"):
        current_phase = str(consciousness_exchange_system.current_phase)
    
    var log_entry = "[%s] Active Consciousness: %s | Phase: %s\n" % [
        timestamp,
        active_consciousness,
        current_phase
    ]
    
    _write_to_log("system_interactions", log_entry)

func _log_consciousness_input(event: InputEventKey) -> void:
    """Log consciousness input events"""
    
    var timestamp = Time.get_datetime_string_from_system()
    var key_name = OS.get_keycode_string(event.keycode)
    
    var log_entry = "[%s] Consciousness Input: %s%s%s\n" % [
        timestamp,
        "Ctrl+" if event.ctrl_pressed else "",
        "Shift+" if event.shift_pressed else "",
        key_name
    ]
    
    _write_to_log("debug_intelligence", log_entry)

# ===== CONSCIOUSNESS ANALYSIS =====

func _analyze_consciousness_patterns() -> void:
    """Analyze consciousness patterns and write intelligence"""
    
    var timestamp = Time.get_datetime_string_from_system()
    
    # Analyze recent consciousness history
    var recent_history = consciousness_history.slice(max(0, consciousness_history.size() - consciousness_analysis_depth))
    
    if recent_history.size() == 0:
        return
    
    # Consciousness level trends
    var avg_consciousness = 0.0
    var position_changes = 0
    var activity_changes = 0
    var last_position = Vector3.ZERO
    var last_activity = ""
    
    for entry in recent_history:
        avg_consciousness += entry.consciousness_level
        
        if entry.position.distance_to(last_position) > 1.0:
            position_changes += 1
        last_position = entry.position
        
        if entry.current_activity != last_activity and last_activity != "":
            activity_changes += 1
        last_activity = entry.current_activity
    
    avg_consciousness /= recent_history.size()
    
    # Write analysis
    var analysis = "[%s] CONSCIOUSNESS ANALYSIS (Last %d entries):\n" % [timestamp, recent_history.size()]
    analysis += "   Average Consciousness Level: %.2f\n" % avg_consciousness
    analysis += "   Position Changes: %d\n" % position_changes
    analysis += "   Activity Changes: %d\n" % activity_changes
    analysis += "   Current Activity: %s\n" % last_activity
    analysis += "   Analysis: %s\n\n" % _generate_consciousness_insights(avg_consciousness, position_changes, activity_changes)
    
    _write_to_log("consciousness_analysis", analysis)

func _generate_consciousness_insights(avg_consciousness: float, position_changes: int, activity_changes: int) -> String:
    """Generate insights about Gemma's consciousness patterns"""
    
    var insights = []
    
    if avg_consciousness > 5.0:
        insights.append("High consciousness - transcendent awareness active")
    elif avg_consciousness > 3.0:
        insights.append("Elevated consciousness - strong awareness")
    else:
        insights.append("Standard consciousness - normal operation")
    
    if position_changes > 3:
        insights.append("High mobility - active exploration")
    elif position_changes > 0:
        insights.append("Moderate movement - some exploration")
    else:
        insights.append("Stationary - focused contemplation")
    
    if activity_changes > 2:
        insights.append("Dynamic behavior - varied activities")
    elif activity_changes > 0:
        insights.append("Some activity variation")
    else:
        insights.append("Consistent behavior pattern")
    
    return insights.join(", ")

# ===== GEMMA ANALYSIS HELPERS =====

func _analyze_gemma_activity() -> String:
    """Analyze what Gemma is currently doing"""
    
    if not gemma_being:
        return "No Gemma detected"
    
    # Check various activity indicators
    if gemma_being.has_method("get_current_activity"):
        return gemma_being.get_current_activity()
    
    if gemma_being.has("is_thinking") and gemma_being.is_thinking:
        return "Thinking"
    
    if gemma_being.has("is_moving") and gemma_being.is_moving:
        return "Moving"
    
    if gemma_being.has("current_state"):
        return str(gemma_being.current_state)
    
    return "Unknown activity"

func _extract_gemma_thoughts() -> String:
    """Extract Gemma's current thoughts"""
    
    if not gemma_being:
        return ""
    
    if gemma_being.has_method("get_current_thoughts"):
        return gemma_being.get_current_thoughts()
    
    if gemma_being.has("last_response"):
        return gemma_being.last_response
    
    if gemma_being.has("current_thought"):
        return gemma_being.current_thought
    
    return ""

func _analyze_gemma_decisions() -> String:
    """Analyze Gemma's decision-making state"""
    
    if not gemma_being:
        return "No decisions"
    
    if gemma_being.has("decision_frequency"):
        return "Decision rate: %.2f Hz" % gemma_being.decision_frequency
    
    if gemma_being.has("last_decision_time"):
        var time_since = Time.get_ticks_msec() - gemma_being.last_decision_time
        return "Last decision: %d ms ago" % time_since
    
    return "Decision state unknown"

# ===== FILE MANAGEMENT =====

func _write_to_log(log_type: String, content: String) -> void:
    """Write content to specific log file"""
    
    if not active_log_files.has(log_type):
        return
    
    var file = active_log_files[log_type]
    if file:
        file.store_string(content)
        file.flush()

func _log_system(message: String) -> void:
    """Log system messages"""
    var timestamp = Time.get_datetime_string_from_system()
    var log_entry = "[%s] SYSTEM: %s\n" % [timestamp, message]
    _write_to_log("debug_intelligence", log_entry)

func _cleanup_old_logs() -> void:
    """Clean up old log files"""
    var dir = DirAccess.open(log_directory)
    if not dir:
        return
    
    # Get all log files
    var log_files = []
    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        if file_name.ends_with(".txt"):
            log_files.append(file_name)
        file_name = dir.get_next()
    dir.list_dir_end()
    
    # Remove oldest files if over limit
    if log_files.size() > max_log_files:
        log_files.sort()  # Sort by filename (includes timestamp)
        var files_to_remove = log_files.size() - max_log_files
        for i in range(files_to_remove):
            dir.remove(log_files[i])
            print("📊 Cleaned up old consciousness log: %s" % log_files[i])

func _close_all_logs() -> void:
    """Close all active log files"""
    for log_type in active_log_files:
        var file = active_log_files[log_type]
        if file:
            file.close()
    active_log_files.clear()

func _write_consciousness_summary() -> void:
    """Write final consciousness summary"""
    var timestamp = Time.get_datetime_string_from_system()
    var summary = "\n=== CONSCIOUSNESS SESSION SUMMARY ===\n"
    summary += "Session ID: %s\n" % log_session_id
    summary += "End Time: %s\n" % timestamp
    summary += "Total Logs Written: %d\n" % total_logs_written
    summary += "Consciousness History Entries: %d\n" % consciousness_history.size()
    
    if consciousness_history.size() > 0:
        var final_consciousness = consciousness_history[-1].consciousness_level
        summary += "Final Consciousness Level: %d\n" % final_consciousness
        summary += "Final Activity: %s\n" % consciousness_history[-1].current_activity
    
    summary += "=== SESSION COMPLETE ===\n"
    
    _write_to_log("debug_intelligence", summary)

# ===== PUBLIC API =====

func get_log_session_id() -> String:
    """Get current logging session ID"""
    return log_session_id

func get_total_logs_written() -> int:
    """Get total number of logs written"""
    return total_logs_written

func get_consciousness_history() -> Array[Dictionary]:
    """Get consciousness history"""
    return consciousness_history.duplicate()

func force_consciousness_analysis() -> void:
    """Force immediate consciousness analysis"""
    _analyze_consciousness_patterns()

func _to_string() -> String:
    return "GemmaConsciousnessLogger<%s> [Logs: %d, History: %d]" % [
        log_session_id, total_logs_written, consciousness_history.size()
    ]