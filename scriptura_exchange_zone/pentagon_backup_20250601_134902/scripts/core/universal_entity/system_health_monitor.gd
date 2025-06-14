# ==================================================
# SCRIPT NAME: system_health_monitor.gd
# DESCRIPTION: Monitor and maintain system health - the guardian
# PURPOSE: Keep the universal entity stable and performant
# CREATED: 2025-05-27 - The Universal Entity Core
# ==================================================

extends UniversalBeingBase
class_name SystemHealthMonitor

signal health_check_complete(report: Dictionary)
signal system_warning(severity: String, message: String)
signal auto_fix_applied(issue: String, fix: String)

# Health thresholds
const CRITICAL_FPS = 20
const WARNING_FPS = 40
const MAX_NODES = 22000
const MAX_MEMORY_MB = 4096
const MAX_QUEUE_SIZE = 100

# Health status
enum HealthStatus {
	HEALTHY,
	WARNING,
	CRITICAL,
	EMERGENCY
}

var current_status: HealthStatus = HealthStatus.HEALTHY
var health_history: Array = []
var auto_fix_enabled: bool = true

# System references
var loader: UniversalLoaderUnloader
var floodgate: FloodgateController
var console: Node

# Monitoring data
var monitoring_data = {
	"fps_samples": [],
	"memory_samples": [],
	"node_count_samples": [],
	"queue_sizes": {},
	"error_count": 0,
	"warning_count": 0,
	"last_check": 0
}

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "SystemHealthMonitor"
	
	# Get system references
	console = get_node_or_null("/root/ConsoleManager")
	floodgate = get_node_or_null("/root/FloodgateController")
	
	# Start health monitoring
	var timer = TimerManager.get_timer()
	timer.wait_time = 1.0
	timer.timeout.connect(_perform_health_check)
	add_child(timer)
	timer.start()
	
	_print("[SystemHealthMonitor] Guardian system online - keeping you safe!")

func _perform_health_check() -> void:
	"""Main health check routine"""
	var report = {
		"timestamp": Time.get_ticks_msec(),
		"status": HealthStatus.HEALTHY,
		"fps": Engine.get_frames_per_second(),
		"node_count": get_tree().get_node_count(),
		"memory_mb": _estimate_memory_usage(),
		"issues": [],
		"auto_fixes": []
	}
	
	# Check FPS
	if report.fps < CRITICAL_FPS:
		report.status = HealthStatus.CRITICAL
		report.issues.append("Critical FPS: " + str(report.fps))
		if auto_fix_enabled:
			_apply_fps_fix()
			report.auto_fixes.append("Emergency FPS optimization")
	elif report.fps < WARNING_FPS:
		if report.status == HealthStatus.HEALTHY:
			report.status = HealthStatus.WARNING
		report.issues.append("Low FPS: " + str(report.fps))
	
	# Check node count
	if report.node_count > MAX_NODES:
		report.status = HealthStatus.CRITICAL
		report.issues.append("Too many nodes: " + str(report.node_count))
		if auto_fix_enabled:
			_apply_node_limit_fix()
			report.auto_fixes.append("Node cleanup performed")
	
	# Check memory
	if report.memory_mb > MAX_MEMORY_MB:
		report.status = HealthStatus.EMERGENCY
		report.issues.append("Memory limit exceeded: " + str(report.memory_mb) + "MB")
		if auto_fix_enabled:
			_apply_memory_fix()
			report.auto_fixes.append("Memory cleanup performed")
	
	# Check floodgate queues
	if floodgate:
		var queue_report = _check_floodgate_queues()
		if queue_report.has_issues:
			report.issues.append_array(queue_report.issues)
			report.status = max(report.status, HealthStatus.WARNING)
	
	# Update status
	current_status = report.status
	health_history.append(report)
	if health_history.size() > 60:
		health_history.pop_front()
	
	# Emit signals
	health_check_complete.emit(report)
	
	if report.status >= HealthStatus.WARNING:
		var severity = _status_to_string(report.status)
		system_warning.emit(severity, report.issues[0] if report.issues.size() > 0 else "Unknown issue")

func _estimate_memory_usage() -> float:
	"""Estimate current memory usage in MB"""
	# This is a simplified estimation
	var node_count = get_tree().get_node_count()
	var base_memory = 100.0  # Base 100MB
	var per_node = 0.5  # 0.5MB per node (rough estimate)
	
	return base_memory + (node_count * per_node)

func _check_floodgate_queues() -> Dictionary:
	"""Check floodgate queue health"""
	var report = {
		"has_issues": false,
		"issues": []
	}
	
	var queues = [
		{"name": "actions", "size": floodgate.actions_to_be_called.size()},
		{"name": "nodes", "size": floodgate.nodes_to_be_added.size()},
		{"name": "movements", "size": floodgate.things_to_be_moved.size()},
		{"name": "unloads", "size": floodgate.nodes_to_be_unloaded.size()}
	]
	
	for queue in queues:
		if queue.size > MAX_QUEUE_SIZE:
			report.has_issues = true
			report.issues.append("Floodgate " + queue.name + " queue overflow: " + str(queue.size))
	
	return report

# ========== AUTO-FIX FUNCTIONS ==========

func _apply_fps_fix() -> void:
	"""Emergency FPS optimization"""
	_print("[HEALTH] Applying emergency FPS fix!")
	
	# Reduce visual quality
	get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_DISABLED
	
	# Freeze distant objects
	if loader:
		loader._emergency_optimization()
	
	# Clear particle effects
	for node in get_tree().get_nodes_in_group("particles"):
		node.queue_free()
	
	auto_fix_applied.emit("Low FPS", "Reduced quality and cleared effects")

func _apply_node_limit_fix() -> void:
	"""Fix too many nodes"""
	_print("[HEALTH] Too many nodes - cleaning up!")
	
	# Use loader to clean up
	if loader:
		loader.force_cleanup(true)
	else:
		# Manual cleanup
		var removed = 0
		for node in get_tree().get_nodes_in_group("spawned_objects"):
			if removed >= 100:
				break
			node.queue_free()
			removed += 1
	
	auto_fix_applied.emit("Node limit", "Removed excess nodes")

func _apply_memory_fix() -> void:
	"""Fix memory issues"""
	_print("[HEALTH] Memory critical - forcing cleanup!")
	
	# Clear all caches
	if loader:
		loader.force_cleanup(true)
	
	# Force garbage collection hint
	OS.low_processor_usage_mode = true
	await get_tree().create_timer(0.1).timeout
	OS.low_processor_usage_mode = false
	
	auto_fix_applied.emit("Memory limit", "Forced memory cleanup")

# ========== PUBLIC API ==========


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
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
func get_health_status() -> HealthStatus:
	"""Get current health status"""
	return current_status

func get_health_report() -> Dictionary:
	"""Get detailed health report"""
	if health_history.is_empty():
		return {}
	
	var latest = health_history[-1]
	var report = latest.duplicate()
	
	# Add averages
	var fps_sum = 0.0
	var node_sum = 0
	var count = min(10, health_history.size())
	
	for i in range(health_history.size() - count, health_history.size()):
		fps_sum += health_history[i].fps
		node_sum += health_history[i].node_count
	
	report.avg_fps = fps_sum / count
	report.avg_nodes = node_sum / count
	
	return report

func set_auto_fix(enabled: bool) -> void:
	"""Enable/disable automatic fixes"""
	auto_fix_enabled = enabled
	_print("[HEALTH] Auto-fix " + ("enabled" if enabled else "disabled"))

func force_health_check() -> void:
	"""Force an immediate health check"""
	_perform_health_check()

func _status_to_string(status: HealthStatus) -> String:
	match status:
		HealthStatus.HEALTHY: return "HEALTHY"
		HealthStatus.WARNING: return "WARNING"
		HealthStatus.CRITICAL: return "CRITICAL"
		HealthStatus.EMERGENCY: return "EMERGENCY"
		_: return "UNKNOWN"

func _print(message: String) -> void:
	if console and console.has_method("_print_to_console"):
		console._print_to_console(message)
	else:
		print(message)
