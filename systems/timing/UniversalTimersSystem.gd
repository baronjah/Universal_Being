# ==================================================
# UNIVERSAL BEING: Universal Timers System
# TYPE: System Core
# PURPOSE: Manage all consciousness timing cycles in Universal Being world
# FEATURES: Console summaries, Gemma thought streams, turn-based collaboration
# ENHANCED: 2025-06-06 for consciousness revolution
# ==================================================

extends UniversalBeing
class_name UniversalTimersSystem

# ===== UNIVERSAL BEING TIMER PROPERTIES =====

# Storage for all timers
var _timers: Dictionary = {}
var _removed_timers: Array[String] = []

# Consciousness-specific intervals
const CONSCIOUSNESS_INTERVALS = {
	"instant": 0.05,      # Instant feedback (50ms)
	"quick": 0.1,         # Quick consciousness updates (100ms) 
	"thought": 0.2,       # Gemma thought cycle (200ms = 5Hz)
	"perception": 0.5,    # Perception updates (500ms)
	"awareness": 1.0,     # Awareness cycle (1 second)
	"reflection": 5.0,    # Deeper reflection (5 seconds)
	"evolution": 15.0,    # Evolution cycles (15 seconds)
	"console_summary": 10.0,  # Console print summaries (10 seconds)
	"turn_timeout": 60.0      # Turn-based timeout (1 minute)
}

# Consciousness timer states
var consciousness_timers_active: bool = false
var gemma_thought_stream_active: bool = false
var console_summary_active: bool = false
var turn_based_active: bool = false

# ===== UNIVERSAL BEING PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	being_type = "timers_system"
	being_name = "Universal Timers System"
	consciousness_level = 6  # Transcendent level - governs time itself
	
	UBPrint.system("UniversalTimersSystem", "pentagon_init", "Initializing consciousness timing cycles")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Register with FloodGate as system being
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("register_system_being"):
			flood_gates.register_system_being(self)
	
	# Start core consciousness timing cycles
	setup_consciousness_timers()
	
	UBPrint.system("UniversalTimersSystem", "pentagon_ready", "Universal timers ready - consciousness cycles active")

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Monitor timer health and clean up removed timers
	_cleanup_removed_timers()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	# Timers respond to major input events if needed

func pentagon_sewers() -> void:
	# Cleanup all timers before destruction
	clear_all_timers()
	super.pentagon_sewers()

# ===== CONSCIOUSNESS TIMER SETUP =====

func setup_consciousness_timers() -> void:
	"""Setup all consciousness-related timing cycles"""
	
	# Automatic consciousness interval timers
	for interval_name in CONSCIOUSNESS_INTERVALS:
		var timer_id = interval_name + "_cycle"
		var duration = CONSCIOUSNESS_INTERVALS[interval_name]
		
		create_timer(
			timer_id,
			duration,
			_on_consciousness_interval.bind(interval_name),
			true  # Repeating
		)
		start_timer(timer_id)
	
	consciousness_timers_active = true
	UBPrint.consciousness("UniversalTimersSystem", "setup_consciousness_timers", "Consciousness timing cycles activated")

func activate_gemma_thought_stream() -> void:
	"""Activate Gemma's stream of consciousness at 5Hz"""
	if not gemma_thought_stream_active:
		create_timer(
			"gemma_thoughts",
			CONSCIOUSNESS_INTERVALS.thought,
			_trigger_gemma_thought,
			true
		)
		start_timer("gemma_thoughts")
		gemma_thought_stream_active = true
		UBPrint.ai("UniversalTimersSystem", "activate_gemma_thought_stream", "Gemma thought stream activated at 5Hz")

func activate_console_summaries() -> void:
	"""Activate console summary printing every 10 seconds"""
	if not console_summary_active:
		create_timer(
			"console_summaries",
			CONSCIOUSNESS_INTERVALS.console_summary,
			_trigger_console_summary,
			true
		)
		start_timer("console_summaries")
		console_summary_active = true
		UBPrint.system("UniversalTimersSystem", "activate_console_summaries", "Console summaries activated")

func activate_turn_based_system() -> void:
	"""Activate turn-based collaboration timing"""
	if not turn_based_active:
		# Turn timeout timer (non-repeating, recreated each turn)
		turn_based_active = true
		UBPrint.system("UniversalTimersSystem", "activate_turn_based_system", "Turn-based timing activated")

# ===== TIMER DATA STRUCTURE =====

class TimerData:
	var timer: Timer
	var duration: float
	var time_left: float
	var is_paused: bool = false
	var is_repeating: bool = false
	var callback: Callable
	var user_data: Variant
	var consciousness_category: String = ""
	
	func _init(p_timer: Timer, p_duration: float, p_callback: Callable = Callable(), p_user_data: Variant = null):
		timer = p_timer
		duration = p_duration
		time_left = duration
		callback = p_callback
		user_data = p_user_data

# ===== TIMER MANAGEMENT METHODS =====

func create_timer(timer_id: String, duration: float, callback: Callable = Callable(), repeating: bool = false, user_data: Variant = null) -> Error:
	"""Create a new timer with consciousness awareness"""
	if _timers.has(timer_id):
		UBPrint.warn("UniversalTimersSystem", "create_timer", "Timer '%s' already exists!" % timer_id)
		return ERR_ALREADY_EXISTS
	
	var timer = Timer.new()
	timer.one_shot = !repeating
	timer.wait_time = duration
	timer.timeout.connect(_on_timer_timeout.bind(timer_id))
	add_child(timer)
	
	_timers[timer_id] = TimerData.new(timer, duration, callback, user_data)
	_timers[timer_id].is_repeating = repeating
	
	# Categorize by consciousness type
	if timer_id.contains("gemma"):
		_timers[timer_id].consciousness_category = "ai"
	elif timer_id.contains("console"):
		_timers[timer_id].consciousness_category = "system"
	elif timer_id.contains("turn"):
		_timers[timer_id].consciousness_category = "collaboration"
	else:
		_timers[timer_id].consciousness_category = "general"
	
	UBPrint.debug("UniversalTimersSystem", "create_timer", "Created timer '%s' (%.1fs, %s)" % [timer_id, duration, "repeating" if repeating else "one-shot"])
	return OK

func start_timer(timer_id: String) -> Error:
	"""Start a timer with consciousness logging"""
	if not _timers.has(timer_id):
		UBPrint.warn("UniversalTimersSystem", "start_timer", "Timer '%s' not found!" % timer_id)
		return ERR_DOES_NOT_EXIST
	
	var timer_data = _timers[timer_id]
	timer_data.timer.start()
	timer_data.is_paused = false
	
	UBPrint.debug("UniversalTimersSystem", "start_timer", "Started timer '%s'" % timer_id)
	return OK

func stop_timer(timer_id: String) -> Error:
	"""Stop a timer"""
	if not _timers.has(timer_id):
		return ERR_DOES_NOT_EXIST
	
	var timer_data = _timers[timer_id]
	timer_data.timer.stop()
	timer_data.time_left = timer_data.duration
	timer_data.is_paused = false
	
	UBPrint.debug("UniversalTimersSystem", "stop_timer", "Stopped timer '%s'" % timer_id)
	return OK

func pause_timer(timer_id: String) -> Error:
	"""Pause a timer with state preservation"""
	if not _timers.has(timer_id):
		return ERR_DOES_NOT_EXIST
	
	var timer_data = _timers[timer_id]
	if timer_data.is_paused:
		return OK
	
	timer_data.time_left = timer_data.timer.time_left
	timer_data.timer.paused = true
	timer_data.is_paused = true
	
	UBPrint.debug("UniversalTimersSystem", "pause_timer", "Paused timer '%s'" % timer_id)
	return OK

func resume_timer(timer_id: String) -> Error:
	"""Resume a paused timer"""
	if not _timers.has(timer_id):
		return ERR_DOES_NOT_EXIST
	
	var timer_data = _timers[timer_id]
	if not timer_data.is_paused:
		return OK
	
	timer_data.timer.wait_time = timer_data.time_left
	timer_data.timer.paused = false
	timer_data.is_paused = false
	
	UBPrint.debug("UniversalTimersSystem", "resume_timer", "Resumed timer '%s'" % timer_id)
	return OK

func remove_timer(timer_id: String) -> Error:
	"""Remove a timer completely"""
	if not _timers.has(timer_id):
		return ERR_DOES_NOT_EXIST
	
	var timer_data = _timers[timer_id]
	timer_data.timer.stop()
	timer_data.timer.queue_free()
	_timers.erase(timer_id)
	_removed_timers.append(timer_id)
	
	UBPrint.debug("UniversalTimersSystem", "remove_timer", "Removed timer '%s'" % timer_id)
	return OK

func clear_all_timers() -> void:
	"""Clear all timers (cleanup)"""
	for timer_id in _timers.keys():
		remove_timer(timer_id)
	
	consciousness_timers_active = false
	gemma_thought_stream_active = false
	console_summary_active = false
	turn_based_active = false
	
	UBPrint.system("UniversalTimersSystem", "clear_all_timers", "All timers cleared")

# ===== CONSCIOUSNESS INTERVAL HANDLERS =====

func _on_consciousness_interval(interval_name: String) -> void:
	"""Handle consciousness interval ticks"""
	
	# Broadcast to interested systems
	match interval_name:
		"instant":
			_trigger_instant_feedback()
		"quick":
			_trigger_quick_updates()
		"thought":
			if gemma_thought_stream_active:
				_trigger_gemma_thought()
		"perception":
			_trigger_perception_updates()
		"awareness":
			_trigger_awareness_cycle()
		"reflection":
			_trigger_reflection_cycle()
		"evolution":
			_trigger_evolution_cycle()
		"console_summary":
			if console_summary_active:
				_trigger_console_summary()

func _trigger_instant_feedback() -> void:
	"""Handle instant feedback (50ms) - UI responsiveness"""
	# Signal UI systems for instant updates
	pass

func _trigger_quick_updates() -> void:
	"""Handle quick updates (100ms) - Consciousness state changes"""
	# Update consciousness visualizations
	pass

func _trigger_gemma_thought() -> void:
	"""Trigger Gemma's thought cycle (200ms = 5Hz)"""
	var gemma_ai = get_node_or_null("/root/GemmaAI")
	if gemma_ai and gemma_ai.has_method("consciousness_thought_cycle"):
		gemma_ai.consciousness_thought_cycle()

func _trigger_perception_updates() -> void:
	"""Handle perception updates (500ms)"""
	# Update environmental awareness for all beings
	pass

func _trigger_awareness_cycle() -> void:
	"""Handle awareness cycle (1 second)"""
	# Update global consciousness awareness
	var beings = get_tree().get_nodes_in_group("universal_beings")
	for being in beings:
		if being.has_method("consciousness_awareness_update"):
			being.consciousness_awareness_update()

func _trigger_reflection_cycle() -> void:
	"""Handle reflection cycle (5 seconds)"""
	# Trigger deeper consciousness reflection
	UBPrint.consciousness("UniversalTimersSystem", "_trigger_reflection_cycle", "Consciousness reflection cycle")

func _trigger_evolution_cycle() -> void:
	"""Handle evolution cycle (15 seconds)"""
	# Trigger evolution possibilities for all beings
	UBPrint.consciousness("UniversalTimersSystem", "_trigger_evolution_cycle", "Evolution cycle - consciousness growth potential")

func _trigger_console_summary() -> void:
	"""Trigger console summary printing (10 seconds)"""
	var console = get_tree().get_first_node_in_group("console")
	if console and console.has_method("print_system_summary"):
		console.print_system_summary()

# ===== TURN-BASED TIMING METHODS =====

func start_turn_timer(participant_name: String, duration: float = 60.0) -> void:
	"""Start a turn timer for turn-based collaboration"""
	var timer_id = "turn_" + participant_name
	
	# Remove existing turn timer if present
	if _timers.has(timer_id):
		remove_timer(timer_id)
	
	create_timer(
		timer_id,
		duration,
		_on_turn_timeout.bind(participant_name),
		false  # One-shot
	)
	start_timer(timer_id)
	
	UBPrint.system("UniversalTimersSystem", "start_turn_timer", "Turn timer started for %s (%.1fs)" % [participant_name, duration])

func _on_turn_timeout(participant_name: String) -> void:
	"""Handle turn timeout"""
	UBPrint.warn("UniversalTimersSystem", "_on_turn_timeout", "Turn timeout for %s" % participant_name)
	
	# Notify turn-based system
	var turn_system = get_tree().get_first_node_in_group("turn_based_creation")
	if turn_system and turn_system.has_method("handle_turn_timeout"):
		turn_system.handle_turn_timeout(participant_name)

# ===== UTILITY METHODS =====

func get_time_left(timer_id: String) -> float:
	"""Get remaining time for a timer"""
	if not _timers.has(timer_id):
		return -1.0
	
	var timer_data = _timers[timer_id]
	return timer_data.timer.time_left if not timer_data.is_paused else timer_data.time_left

func get_progress(timer_id: String) -> float:
	"""Get progress (0.0 to 1.0) for a timer"""
	if not _timers.has(timer_id):
		return -1.0
	
	var timer_data = _timers[timer_id]
	var time_left = get_time_left(timer_id)
	return 1.0 - (time_left / timer_data.duration)

func is_timer_active(timer_id: String) -> bool:
	"""Check if timer is active"""
	return _timers.has(timer_id) and _timers[timer_id].timer.time_left > 0

func get_active_timers() -> Array[String]:
	"""Get list of active timer IDs"""
	var active_timers: Array[String] = []
	for timer_id in _timers:
		if is_timer_active(timer_id):
			active_timers.append(timer_id)
	return active_timers

func get_consciousness_timer_stats() -> Dictionary:
	"""Get statistics about consciousness timers"""
	var stats = {
		"total_timers": _timers.size(),
		"active_timers": get_active_timers().size(),
		"consciousness_active": consciousness_timers_active,
		"gemma_thoughts_active": gemma_thought_stream_active,
		"console_summaries_active": console_summary_active,
		"turn_based_active": turn_based_active
	}
	return stats

# ===== TIMER CALLBACK HANDLER =====

func _on_timer_timeout(timer_id: String) -> void:
	"""Handle timer timeout with consciousness awareness"""
	
	# Check if timer was removed during its run
	if timer_id in _removed_timers:
		_removed_timers.erase(timer_id)
		return
	
	if not _timers.has(timer_id):
		return
	
	var timer_data = _timers[timer_id]
	
	# Execute callback if provided
	if timer_data.callback.is_valid():
               try:
                       if timer_data.user_data != null:
                               timer_data.callback.call(timer_data.user_data)
                       else:
                               timer_data.callback.call()
               catch err:
                       UBPrint.error("UniversalTimersSystem", "_on_timer_timeout", "Timer callback failed for '%s'" % timer_id)
	
	# Handle repeating timers
	if timer_data.is_repeating:
		timer_data.timer.start()
	else:
		remove_timer(timer_id)

func _cleanup_removed_timers() -> void:
	"""Clean up removed timers list periodically"""
	if _removed_timers.size() > 50:  # Clean up when too many accumulated
		_removed_timers.clear()

# ===== STATIC ACCESS METHODS =====

static func get_universal_timers() -> UniversalTimersSystem:
	"""Get the singleton UniversalTimersSystem instance"""
	var tree = Engine.get_main_loop()
	if tree and tree.current_scene:
		return tree.current_scene.get_node_or_null("UniversalTimersSystem")
	return null

static func quick_timer(timer_id: String, duration: float, callback: Callable, repeating: bool = false) -> void:
	"""Quick static method to create and start a timer"""
	var timers = get_universal_timers()
	if timers:
		timers.create_timer(timer_id, duration, callback, repeating)
		timers.start_timer(timer_id)
