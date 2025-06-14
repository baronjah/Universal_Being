# ==================================================
# SCRIPT NAME: delta_frame_guardian.gd
# DESCRIPTION: Controls and optimizes frame access for all scripts
# PURPOSE: Maintain good FPS by managing who gets process time
# CREATED: 2025-05-28 - Guardian of the sacred frames
# ==================================================

extends UniversalBeingBase
class_name DeltaFrameGuardian

signal performance_warning  # Emitted when performance issues detected(script: String, usage: float)
signal script_throttled(script: String, reason: String)
signal fps_improved  # Emitted when FPS performance improves(old_fps: float, new_fps: float)

# Frame budget management
var target_fps: float = 60.0
var min_acceptable_fps: float = 30.0
var current_fps: float = 60.0
var frame_time_budget: float = 16.67  # ms for 60 FPS

# Script tracking
var registered_scripts: Dictionary = {}  # path -> ScriptInfo
var frame_consumers: Array = []  # Sorted by priority
var accumulated_deltas: Dictionary = {}  # Store accumulated time

# Performance tracking
var frame_times: Array = []
var max_frame_history: int = 60

# Throttling settings
var throttle_enabled: bool = true
var adaptive_throttling: bool = true
var emergency_mode: bool = false

class ScriptInfo:
	var path: String
	var node: Node
	var priority: int = 50  # 0-100, higher = more important
	var update_rate: float = 60.0  # Target updates per second
	var last_update: int = 0
	var accumulated_delta: float = 0.0
	var average_time: float = 0.0
	var is_throttled: bool = false
	var process_type: String = "idle"  # idle, physics, both

func _ready() -> void:
	name = "DeltaFrameGuardian"
	process_priority = -100  # Run before everything else
	
	print("🛡️ [DeltaGuardian] Frame protection activated")
	print("   Target FPS: %.1f, Frame budget: %.2fms" % [target_fps, frame_time_budget])
	
	# Start monitoring
	set_process(true)
	
	# Register console commands
	_register_guardian_commands()

func _process(delta: float) -> void:
	# Track frame time
	var frame_start = Time.get_ticks_msec()
	
	# Update FPS tracking
	current_fps = Engine.get_frames_per_second()
	
	# Check performance
	if current_fps < min_acceptable_fps and current_fps > 0:
		if not emergency_mode:
			_enter_emergency_mode()
	elif emergency_mode and current_fps > target_fps * 0.8:
		_exit_emergency_mode()
	
	# Distribute frame time to registered scripts
	if throttle_enabled:
		_distribute_frame_time(delta)
	
	# Track this frame's time
	var frame_time = Time.get_ticks_msec() - frame_start
	_track_frame_time(frame_time)


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
func register_script(node: Node, priority: int = 50, update_rate: float = 60.0) -> void:
	"""Register a script for managed frame access"""
	var info = ScriptInfo.new()
	info.node = node
	info.path = node.get_script().resource_path if node.get_script() else node.name
	info.priority = clamp(priority, 0, 100)
	info.update_rate = update_rate
	info.last_update = Time.get_ticks_msec()
	
	registered_scripts[info.path] = info
	frame_consumers.append(info)
	
	# Sort by priority
	frame_consumers.sort_custom(func(a, b): return a.priority > b.priority)
	
	print("📝 [DeltaGuardian] Registered: %s (priority: %d, rate: %.1f)" % [
		info.path.get_file(), priority, update_rate
	])

func unregister_script(node: Node) -> void:
	"""Unregister a script from frame management"""
	var path = node.get_script().resource_path if node.get_script() else node.name
	
	if path in registered_scripts:
		var info = registered_scripts[path]
		frame_consumers.erase(info)
		registered_scripts.erase(path)
		accumulated_deltas.erase(path)
		
		print("🚮 [DeltaGuardian] Unregistered: %s" % path.get_file())

func get_managed_delta(node: Node) -> float:
	"""Get the accumulated delta for a managed script"""
	var path = node.get_script().resource_path if node.get_script() else node.name
	
	if not path in registered_scripts:
		return get_process_delta_time()  # Fallback to normal delta
	
	var info = registered_scripts[path]
	
	# Check if throttled
	if info.is_throttled and not _should_update(info):
		return 0.0
	
	# Return accumulated delta
	var delta = accumulated_deltas.get(path, 0.0)
	accumulated_deltas[path] = 0.0  # Reset after use
	
	info.last_update = Time.get_ticks_msec()
	return delta

func _distribute_frame_time(delta: float) -> void:
	"""Distribute frame time based on priority and need"""
	var total_priority = 0
	var active_scripts = []
	
	# Calculate total priority of scripts that need updates
	for info in frame_consumers:
		if _should_update(info):
			total_priority += info.priority
			active_scripts.append(info)
	
	if total_priority == 0:
		return
	
	# Distribute delta based on priority
	for info in active_scripts:
		var weight = float(info.priority) / float(total_priority)
		var allocated_delta = delta * weight
		
		# Accumulate delta for the script
		var path = info.path
		accumulated_deltas[path] = accumulated_deltas.get(path, 0.0) + allocated_delta

func _should_update(info: ScriptInfo) -> bool:
	"""Check if a script should update this frame"""
	if emergency_mode and info.priority < 70:
		return false  # Only high priority in emergency
	
	var time_since_update = Time.get_ticks_msec() - info.last_update
	var target_interval = 1000.0 / info.update_rate
	
	return time_since_update >= target_interval

func _track_frame_time(frame_time: float) -> void:
	"""Track frame timing for analysis"""
	frame_times.append(frame_time)
	
	if frame_times.size() > max_frame_history:
		frame_times.pop_front()
	
	# Check if we're over budget
	if frame_time > frame_time_budget * 1.5:
		_analyze_performance_issue()

func _analyze_performance_issue() -> void:
	"""Analyze what's causing performance issues"""
	var worst_offenders = []
	
	for info in frame_consumers:
		if info.average_time > frame_time_budget * 0.1:  # Using >10% of budget
			worst_offenders.append(info)
	
	# Sort by time usage
	worst_offenders.sort_custom(func(a, b): return a.average_time > b.average_time)
	
	# Throttle worst offenders
	if adaptive_throttling and worst_offenders.size() > 0:
		var worst = worst_offenders[0]
		_throttle_script(worst, "High frame time usage")

func _throttle_script(info: ScriptInfo, reason: String) -> void:
	"""Throttle a script's update rate"""
	info.is_throttled = true
	info.update_rate = min(info.update_rate * 0.5, 15.0)  # Halve rate, min 15 FPS
	
	script_throttled.emit(info.path, reason)
	print("🚦 [DeltaGuardian] Throttled: %s - %s" % [info.path.get_file(), reason])

func _enter_emergency_mode() -> void:
	"""Enter emergency performance mode"""
	emergency_mode = true
	print("🚨 [DeltaGuardian] EMERGENCY MODE - FPS critically low!")
	
	# Throttle all non-critical scripts
	for info in frame_consumers:
		if info.priority < 70:
			_throttle_script(info, "Emergency mode")

func _exit_emergency_mode() -> void:
	"""Exit emergency performance mode"""
	emergency_mode = false
	print("✅ [DeltaGuardian] Emergency mode ended - FPS recovered")
	
	# Restore update rates gradually
	for info in frame_consumers:
		if info.is_throttled:
			info.update_rate = min(info.update_rate * 1.5, 60.0)
			if info.update_rate >= 55.0:
				info.is_throttled = false

func get_performance_report() -> Dictionary:
	"""Get current performance statistics"""
	var avg_frame_time = 0.0
	if frame_times.size() > 0:
		for time in frame_times:
			avg_frame_time += time
		avg_frame_time /= frame_times.size()
	
	return {
		"current_fps": current_fps,
		"average_frame_time": avg_frame_time,
		"registered_scripts": registered_scripts.size(),
		"throttled_count": frame_consumers.filter(func(i): return i.is_throttled).size(),
		"emergency_mode": emergency_mode
	}

func _register_guardian_commands() -> void:
	"""Register console commands"""
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		console.register_command("fps_status", _cmd_fps_status,
			"Show FPS and performance status")
		console.register_command("fps_scripts", _cmd_list_scripts,
			"List all frame-managed scripts")
		console.register_command("fps_throttle", _cmd_toggle_throttle,
			"Toggle frame throttling on/off")
		console.register_command("fps_emergency", _cmd_force_emergency,
			"Force emergency mode for testing")

func _cmd_fps_status(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	var report = get_performance_report()
	
	console._print_to_console("[color=cyan]🛡️ Delta Frame Guardian Status[/color]")
	console._print_to_console("Current FPS: %.1f" % report.current_fps)
	console._print_to_console("Avg frame time: %.2fms" % report.average_frame_time)
	console._print_to_console("Scripts managed: %d" % report.registered_scripts)
	console._print_to_console("Scripts throttled: %d" % report.throttled_count)
	console._print_to_console("Emergency mode: %s" % ("ON" if report.emergency_mode else "OFF"))
	console._print_to_console("Throttling: %s" % ("ENABLED" if throttle_enabled else "DISABLED"))

func _cmd_list_scripts(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	console._print_to_console("[color=yellow]📜 Managed Scripts:[/color]")
	
	for info in frame_consumers:
		var status = "🟢" if not info.is_throttled else "🔴"
		console._print_to_console("%s %s - Priority: %d, Rate: %.1f FPS" % [
			status, info.path.get_file(), info.priority, info.update_rate
		])

func _cmd_toggle_throttle(args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	
	if args.size() > 0:
		throttle_enabled = args[0].to_lower() == "on"
	else:
		throttle_enabled = !throttle_enabled
	
	console._print_to_console("Frame throttling: %s" % ("ENABLED" if throttle_enabled else "DISABLED"))

func _cmd_force_emergency(args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	
	if args.size() > 0 and args[0].to_lower() == "off":
		_exit_emergency_mode()
	else:
		_enter_emergency_mode()
	
	console._print_to_console("Emergency mode: %s" % ("ON" if emergency_mode else "OFF"))