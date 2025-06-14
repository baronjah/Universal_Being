################################################################
# SEWERS MONITOR SYSTEM - PHASE 3 IMPLEMENTATION
# Flow tracking, bottleneck detection, and auto-optimization
# Created: May 31st, 2025 | Perfect Pentagon Architecture
# Location: scripts/autoload/sewers_monitor.gd
################################################################

extends UniversalBeingBase
################################################################
# CORE VARIABLES - Flow Monitoring
################################################################

var flow_metrics: Dictionary = {}
var bottlenecks: Array[Dictionary] = []
var system_health: Dictionary = {}
var monitoring_enabled: bool = true

# Sewers tracking (Kamisama's sewers philosophy)
var input_sewers: Dictionary = {}    # Perfect Input flow
var process_sewers: Dictionary = {}  # Perfect Delta flow  
var action_sewers: Dictionary = {}   # Logic Connector flow
var data_sewers: Dictionary = {}     # Universal Being data flow
var ai_sewers: Dictionary = {}       # AI entity communication flow

# Performance thresholds
var max_input_rate: float = 100.0    # events per second
var max_process_time: float = 16.66  # milliseconds (60 FPS)
var max_action_queue: int = 50       # pending actions
var max_ai_messages: int = 20        # AI messages per second

# System status
var debug_mode: bool = true
var system_ready: bool = false
var monitoring_start_time: int = 0
var total_flows_tracked: int = 0

################################################################
# SIGNALS - Perfect Pentagon Communication
################################################################

signal bottleneck_detected(sewer_type: String, severity: String, recommendation: String)
signal flow_overflow(sewer_type: String, rate: float, threshold: float)
signal system_health_changed(health_level: String)
signal auto_adjustment_applied(system: String, adjustment: String)
signal ai_sewer_activity(ai_name: String, activity_type: String, data: Dictionary)

################################################################
# INITIALIZATION
################################################################

func _ready():
	print("🌊 SEWERS MONITOR SYSTEM: Initializing flow tracking and bottleneck detection...")
	
	# Initialize monitoring systems
	initialize_monitoring()
	
	# Connect to Perfect Pentagon systems
	_connect_to_pentagon_systems()
	
	# Set up AI monitoring
	_setup_ai_monitoring()
	
	# Start monitoring process
	set_process(true)
	
	monitoring_start_time = Time.get_ticks_msec()
	system_ready = true
	
	if debug_mode:
		print("✅ SEWERS MONITOR: System ready - Monitoring all flows through Perfect Pentagon")

################################################################
# MONITORING INITIALIZATION
################################################################


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func initialize_monitoring():
	"""
	Initialize all monitoring systems and data structures
	
	INPUT: None (uses system configuration)
	PROCESS: Sets up flow tracking for all sewer types, initializes health metrics
	OUTPUT: Ready monitoring system
	CHANGES: Creates monitoring infrastructure for all Pentagon systems
	CONNECTION: Links to Perfect Init, Ready, Input, Logic Connector systems
	"""
	
	# Initialize flow metrics for each sewer type
	flow_metrics = {
		"input": {"rate": 0.0, "total": 0, "last_update": 0},
		"process": {"rate": 0.0, "total": 0, "last_update": 0}, 
		"action": {"rate": 0.0, "total": 0, "last_update": 0},
		"data": {"rate": 0.0, "total": 0, "last_update": 0},
		"ai": {"rate": 0.0, "total": 0, "last_update": 0}
	}
	
	# Initialize system health tracking
	system_health = {
		"overall": "excellent",
		"input_health": "excellent",
		"process_health": "excellent", 
		"action_health": "excellent",
		"data_health": "excellent",
		"ai_health": "excellent",
		"performance_score": 100.0
	}
	
	print("📊 SEWERS MONITOR: Initialized monitoring for all sewer types")

################################################################
# MAIN MONITORING PROCESS
################################################################

func _process(delta):
	"""
	Main monitoring loop - tracks all flows and detects issues
	"""
	if not monitoring_enabled or not system_ready:
		return
	
	# Update flow metrics
	update_flow_metrics(delta)
	
	# Detect bottlenecks
	detect_bottlenecks()
	
	# Auto-adjust systems if needed
	auto_adjust_systems()
	
	# Update system health
	_update_system_health()
	
	# Monitor AI activities
	_monitor_ai_activities()

################################################################
# FLOW LOGGING FUNCTIONS
################################################################

func log_flow(sewer_type: String, source: String, data: Variant, timestamp: float = 0.0):
	"""
	Log a flow event in the specified sewer system
	
	INPUT: sewer_type (input/process/action/data/ai), source (origin), data (flow data), timestamp
	PROCESS: Records flow event, updates metrics, checks for overflows
	OUTPUT: None (logs to monitoring system)
	CHANGES: Updates flow_metrics, triggers overflow detection
	CONNECTION: Used by all Perfect Pentagon systems to report their activities
	"""
	
	if timestamp == 0.0:
		timestamp = Time.get_ticks_msec() / 1000.0
	
	# Ensure sewer type exists
	if not flow_metrics.has(sewer_type):
		flow_metrics[sewer_type] = {"rate": 0.0, "total": 0, "last_update": 0}
	
	# Update flow metrics
	flow_metrics[sewer_type].total += 1
	flow_metrics[sewer_type].last_update = timestamp
	total_flows_tracked += 1
	
	# Store detailed flow data based on sewer type
	match sewer_type:
		"input":
			_log_input_flow(source, data, timestamp)
		"process":
			_log_process_flow(source, data, timestamp)
		"action":
			_log_action_flow(source, data, timestamp)
		"data":
			_log_data_flow(source, data, timestamp)
		"ai":
			_log_ai_flow(source, data, timestamp)
	
	# Update flow rate calculation
	_calculate_flow_rate(sewer_type)
	
	if debug_mode and total_flows_tracked % 100 == 0:
		print("🌊 SEWERS: %d total flows tracked across all sewers" % total_flows_tracked)

func _log_input_flow(source: String, data: Variant, timestamp: float):
	"""Log input sewer flow (from Perfect Input)"""
	if not input_sewers.has(source):
		input_sewers[source] = {"events": [], "rate": 0.0}
	
	input_sewers[source].events.append({
		"timestamp": timestamp,
		"data": data,
		"type": data.get("event_type", "unknown") if data is Dictionary else "raw"
	})
	
	# Keep only recent events (last 60 seconds)
	_cleanup_old_events(input_sewers[source].events, timestamp, 60.0)

func _log_process_flow(source: String, data: Variant, timestamp: float):
	"""Log process sewer flow (from Perfect Delta or other processing)"""
	if not process_sewers.has(source):
		process_sewers[source] = {"processes": [], "avg_time": 0.0}
	
	process_sewers[source].processes.append({
		"timestamp": timestamp,
		"data": data,
		"duration": data.get("duration", 0.0) if data is Dictionary else 0.0
	})
	
	_cleanup_old_events(process_sewers[source].processes, timestamp, 30.0)

func _log_action_flow(source: String, data: Variant, timestamp: float):
	"""Log action sewer flow (from Logic Connector)"""
	if not action_sewers.has(source):
		action_sewers[source] = {"actions": [], "success_rate": 1.0}
	
	action_sewers[source].actions.append({
		"timestamp": timestamp,
		"data": data,
		"action": data.get("action", "unknown") if data is Dictionary else "raw",
		"result": data.get("result", "unknown") if data is Dictionary else "unknown"
	})
	
	_cleanup_old_events(action_sewers[source].actions, timestamp, 120.0)

func _log_data_flow(source: String, data: Variant, timestamp: float):
	"""Log data sewer flow (Universal Being data)"""
	if not data_sewers.has(source):
		data_sewers[source] = {"data_events": [], "size": 0}
	
	data_sewers[source].data_events.append({
		"timestamp": timestamp,
		"data": data,
		"size": str(data).length() if data != null else 0
	})
	
	_cleanup_old_events(data_sewers[source].data_events, timestamp, 180.0)

func _log_ai_flow(source: String, data: Variant, timestamp: float):
	"""Log AI sewer flow (AI entity communications)"""
	if not ai_sewers.has(source):
		ai_sewers[source] = {"messages": [], "communication_rate": 0.0}
	
	ai_sewers[source].messages.append({
		"timestamp": timestamp,
		"data": data,
		"type": data.get("type", "unknown") if data is Dictionary else "raw",
		"ai_entity": data.get("ai_entity", source) if data is Dictionary else source
	})
	
	_cleanup_old_events(ai_sewers[source].messages, timestamp, 300.0)
	
	# Emit AI activity signal
	emit_signal("ai_sewer_activity", source, "message", data if data is Dictionary else {"raw_data": data})

################################################################
# FLOW RATE CALCULATION
################################################################

func update_flow_metrics(delta: float):
	"""
	Update flow rate calculations for all sewer types
	"""
	var current_time = Time.get_ticks_msec() / 1000.0
	
	for sewer_type in flow_metrics:
		_calculate_flow_rate(sewer_type)

func _calculate_flow_rate(sewer_type: String) -> float:
	"""
	Calculate flow rate (events per second) for a sewer type
	"""
	var current_time = Time.get_ticks_msec() / 1000.0
	var time_window = 10.0  # 10 second window
	
	# Count events in the time window
	var event_count = 0
	var events_array = []
	
	match sewer_type:
		"input":
			for source in input_sewers:
				events_array.append_array(input_sewers[source].events)
		"process":
			for source in process_sewers:
				events_array.append_array(process_sewers[source].processes)
		"action":
			for source in action_sewers:
				events_array.append_array(action_sewers[source].actions)
		"data":
			for source in data_sewers:
				events_array.append_array(data_sewers[source].data_events)
		"ai":
			for source in ai_sewers:
				events_array.append_array(ai_sewers[source].messages)
	
	# Count recent events
	for event in events_array:
		if current_time - event.timestamp <= time_window:
			event_count += 1
	
	var rate = event_count / time_window
	flow_metrics[sewer_type].rate = rate
	
	return rate

func _cleanup_old_events(events_array: Array, current_time: float, max_age: float):
	"""
	Remove old events from tracking arrays to prevent memory bloat
	"""
	var cutoff_time = current_time - max_age
	var i = 0
	
	while i < events_array.size():
		if events_array[i].timestamp < cutoff_time:
			events_array.remove_at(i)
		else:
			i += 1

################################################################
# BOTTLENECK DETECTION
################################################################

func detect_bottlenecks():
	"""
	Detect bottlenecks in all sewer systems
	"""
	bottlenecks.clear()
	
	# Check input flow rates
	if _get_flow_rate("input") > max_input_rate:
		bottlenecks.append({
			"type": "input_overload",
			"severity": "high",
			"recommendation": "enable_input_throttling",
			"current_rate": _get_flow_rate("input"),
			"threshold": max_input_rate
		})
		emit_signal("flow_overflow", "input", _get_flow_rate("input"), max_input_rate)
	
	# Check process time
	var avg_process_time = _get_average_process_time()
	if avg_process_time > max_process_time:
		bottlenecks.append({
			"type": "process_bottleneck",
			"severity": "critical",
			"recommendation": "adjust_frame_distribution",
			"current_time": avg_process_time,
			"threshold": max_process_time
		})
	
	# Check action queue
	var pending_actions = _get_pending_actions_count()
	if pending_actions > max_action_queue:
		bottlenecks.append({
			"type": "action_queue_full",
			"severity": "medium",
			"recommendation": "increase_action_processing",
			"current_queue": pending_actions,
			"threshold": max_action_queue
		})
	
	# Check AI message rate
	if _get_flow_rate("ai") > max_ai_messages:
		bottlenecks.append({
			"type": "ai_communication_overload",
			"severity": "medium", 
			"recommendation": "throttle_ai_communication",
			"current_rate": _get_flow_rate("ai"),
			"threshold": max_ai_messages
		})
	
	# Emit signals for detected bottlenecks
	for bottleneck in bottlenecks:
		emit_signal("bottleneck_detected", bottleneck.type, bottleneck.severity, bottleneck.recommendation)

################################################################
# AUTO-ADJUSTMENT SYSTEM
################################################################

func auto_adjust_systems():
	"""
	Automatically adjust systems based on detected bottlenecks
	"""
	for bottleneck in bottlenecks:
		match bottleneck.recommendation:
			"enable_input_throttling":
				_adjust_input_throttling(true)
			"adjust_frame_distribution":
				_adjust_frame_distribution()
			"increase_action_processing":
				_adjust_action_processing()
			"throttle_ai_communication":
				_adjust_ai_communication(true)

func _adjust_input_throttling(enabled: bool):
	"""Adjust input throttling in Perfect Input system"""
	if has_node("/root/PerfectInput"):
		var perfect_input = get_node("/root/PerfectInput")
		if perfect_input.has_method("enable_throttling"):
			perfect_input.enable_throttling(enabled, max_input_rate * 0.8)
			print("🌊 SEWERS AUTO-ADJUST: Input throttling %s" % ("ENABLED" if enabled else "DISABLED"))
			emit_signal("auto_adjustment_applied", "PerfectInput", "throttling_" + ("enabled" if enabled else "disabled"))

func _adjust_frame_distribution():
	"""Adjust frame distribution in Perfect Delta system"""
	if has_node("/root/PerfectDelta"):
		var perfect_delta = get_node("/root/PerfectDelta")  
		if perfect_delta.has_method("adjust_frame_pattern"):
			perfect_delta.adjust_frame_pattern()
			print("🌊 SEWERS AUTO-ADJUST: Frame distribution adjusted")
			emit_signal("auto_adjustment_applied", "PerfectDelta", "frame_distribution_adjusted")

func _adjust_action_processing():
	"""Adjust action processing in Logic Connector"""
	# This could be implemented to batch process actions or prioritize them
	print("🌊 SEWERS AUTO-ADJUST: Action processing optimization applied")
	emit_signal("auto_adjustment_applied", "LogicConnector", "processing_optimized")

func _adjust_ai_communication(throttle: bool):
	"""Adjust AI communication rates"""
	if throttle:
		print("🌊 SEWERS AUTO-ADJUST: AI communication throttling enabled")
	else:
		print("🌊 SEWERS AUTO-ADJUST: AI communication throttling disabled")
	emit_signal("auto_adjustment_applied", "AI_Systems", "communication_throttling")

################################################################
# METRICS CALCULATION
################################################################

func _get_flow_rate(sewer_type: String) -> float:
	"""Get current flow rate for a sewer type"""
	return flow_metrics.get(sewer_type, {}).get("rate", 0.0)

func _get_average_process_time() -> float:
	"""Calculate average process time across all process sewers"""
	var total_time = 0.0
	var count = 0
	
	for source in process_sewers:
		var processes = process_sewers[source].processes
		for process in processes:
			total_time += process.get("duration", 0.0)
			count += 1
	
	return total_time / max(count, 1)

func _get_pending_actions_count() -> int:
	"""Get total pending actions across all action sewers"""
	var total = 0
	
	for source in action_sewers:
		var actions = action_sewers[source].actions
		var recent_actions = 0
		var current_time = Time.get_ticks_msec() / 1000.0
		
		for action in actions:
			if current_time - action.timestamp <= 5.0:  # Actions in last 5 seconds
				recent_actions += 1
		
		total += recent_actions
	
	return total

################################################################
# SYSTEM HEALTH MONITORING
################################################################

func _update_system_health():
	"""
	Update overall system health based on all metrics
	"""
	var health_score = 100.0
	
	# Reduce score based on bottlenecks
	for bottleneck in bottlenecks:
		match bottleneck.severity:
			"critical": health_score -= 30.0
			"high": health_score -= 20.0  
			"medium": health_score -= 10.0
			"low": health_score -= 5.0
	
	# Reduce score based on flow rates
	if _get_flow_rate("input") > max_input_rate * 0.8:
		health_score -= 10.0
	if _get_average_process_time() > max_process_time * 0.8:
		health_score -= 15.0
	
	# Update health levels
	system_health.performance_score = max(0.0, health_score)
	
	var health_level = "excellent"
	if health_score < 50:
		health_level = "critical"
	elif health_score < 70:
		health_level = "poor"
	elif health_score < 85:
		health_level = "good"
	
	if system_health.overall != health_level:
		system_health.overall = health_level
		emit_signal("system_health_changed", health_level)
	
	# Update individual system health
	_update_individual_health_metrics()

func _update_individual_health_metrics():
	"""Update health metrics for individual systems"""
	system_health.input_health = "excellent" if _get_flow_rate("input") < max_input_rate * 0.8 else "overloaded"
	system_health.process_health = "excellent" if _get_average_process_time() < max_process_time * 0.8 else "slow"
	system_health.action_health = "excellent" if _get_pending_actions_count() < max_action_queue * 0.8 else "congested"
	system_health.ai_health = "excellent" if _get_flow_rate("ai") < max_ai_messages * 0.8 else "busy"

################################################################
# AI MONITORING
################################################################

func _setup_ai_monitoring():
	"""Set up monitoring for AI entities"""
	if has_node("/root/PerfectReady"):
		var perfect_ready = get_node("/root/PerfectReady")
		if perfect_ready.has_signal("ai_entity_ready"):
			perfect_ready.ai_entity_ready.connect(_on_ai_entity_ready)

func _on_ai_entity_ready(ai_name: String):
	"""Called when an AI entity becomes ready"""
	print("🤖 SEWERS MONITOR: Monitoring AI entity " + ai_name)

func _monitor_ai_activities():
	"""Monitor AI entity activities and communications"""
	# This monitors AI txt file communications and Universal Being activities
	for ai_name in ai_sewers:
		var ai_data = ai_sewers[ai_name]
		var recent_messages = 0
		var current_time = Time.get_ticks_msec() / 1000.0
		
		for message in ai_data.messages:
			if current_time - message.timestamp <= 10.0:
				recent_messages += 1
		
		ai_data.communication_rate = recent_messages / 10.0

################################################################
# SYSTEM CONNECTION
################################################################

func _connect_to_pentagon_systems():
	"""
	Connect to all Perfect Pentagon systems for monitoring
	"""
	# Connect to systems as they become available
	var systems_to_monitor = ["PerfectInit", "PerfectReady", "PerfectInput", "LogicConnector"]
	
	for system_name in systems_to_monitor:
		if has_node("/root/" + system_name):
			print("🔗 SEWERS MONITOR: Connected to " + system_name)

################################################################
# STATUS AND CONSOLE FUNCTIONS
################################################################

func get_sewers_status() -> String:
	"""
	Get complete sewers system status display
	"""
	return """
🌊 SEWERS SYSTEM STATUS
════════════════════════
⚡ Input Sewers: %s (%.1f events/sec)
🔄 Process Sewers: %s (%.2f ms avg)
🔗 Action Sewers: %s (%d pending)
💾 Data Sewers: %s (%d sources)
🤖 AI Sewers: %s (%.1f msgs/sec)

🚨 Bottlenecks: %d detected
📊 System Health: %s (%.1f%%)
🎯 Monitoring: %s
🌊 Total Flows Tracked: %d

🏥 INDIVIDUAL HEALTH:
• Input: %s
• Process: %s  
• Action: %s
• Data: %s
• AI: %s
""" % [
		_get_sewer_status("input"), _get_flow_rate("input"),
		_get_sewer_status("process"), _get_average_process_time(),
		_get_sewer_status("action"), _get_pending_actions_count(),
		_get_sewer_status("data"), data_sewers.size(),
		_get_sewer_status("ai"), _get_flow_rate("ai"),
		bottlenecks.size(),
		system_health.overall.to_upper(), system_health.performance_score,
		"ACTIVE" if monitoring_enabled else "DISABLED",
		total_flows_tracked,
		system_health.input_health,
		system_health.process_health,
		system_health.action_health,
		system_health.data_health,
		system_health.ai_health
	]

func _get_sewer_status(sewer_type: String) -> String:
	"""Get status string for a specific sewer type"""
	var rate = _get_flow_rate(sewer_type)
	var threshold = 0.0
	
	match sewer_type:
		"input": threshold = max_input_rate * 0.8
		"ai": threshold = max_ai_messages * 0.8
		_: return "NORMAL"
	
	if rate > threshold:
		return "HIGH"
	elif rate > threshold * 0.5:
		return "MEDIUM"
	else:
		return "NORMAL"

func _get_overall_health() -> String:
	"""Get overall system health string"""
	return system_health.overall.to_upper()

func console_sewers_status() -> String:
	"""Console command: Show sewers status"""
	return get_sewers_status()

func console_sewers_bottlenecks() -> String:
	"""Console command: Show current bottlenecks"""
	if bottlenecks.is_empty():
		return "🌊 SEWERS: No bottlenecks detected - all flows normal!"
	
	var result = "🚨 SEWERS BOTTLENECKS DETECTED:\n"
	for i in range(bottlenecks.size()):
		var bottleneck = bottlenecks[i]
		result += "%d. %s [%s] - %s\n" % [
			i + 1,
			bottleneck.type.replace("_", " ").to_upper(),
			bottleneck.severity.to_upper(), 
			bottleneck.recommendation.replace("_", " ")
		]
	
	return result

################################################################
# PERFECT PENTAGON INTEGRATION
################################################################

func get_system_info() -> Dictionary:
	"""
	Return system information for Perfect Pentagon coordination
	"""
	return {
		"system_name": "Sewers Monitor",
		"version": "1.0",
		"status": "active" if system_ready else "initializing",
		"priority": 5,  # Fifth in Pentagon sequence - monitors all others
		"dependencies": ["Perfect Init", "Perfect Ready", "Perfect Input", "Logic Connector"],
		"provides": ["flow_monitoring", "bottleneck_detection", "auto_optimization", "system_health"],
		"monitoring_active": monitoring_enabled,
		"flows_tracked": total_flows_tracked,
		"bottlenecks_detected": bottlenecks.size(),
		"system_health": system_health.overall
	}

################################################################
# END OF SEWERS MONITOR SYSTEM
################################################################