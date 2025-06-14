# ==================================================
# SCRIPT NAME: perfect_delta_process.gd
# DESCRIPTION: The ONE script that controls ALL frame processing
# PURPOSE: Perfect delta distribution - physics remain accurate
# CREATED: 2025-05-28 - The guardian of time itself
# ==================================================

extends UniversalBeingBase
class_name PerfectDeltaProcess

signal frame_distributed(total_scripts: int, frame_time: float)
signal script_registered(script_path: String)
signal performance_report(fps: float, load: float)

# The ONE process to rule them all
var registered_processors: Array[ProcessorInfo] = []
var frame_budget_ms: float = 16.67  # 60 FPS target
var accumulated_time: Dictionary = {}  # Script -> accumulated delta
var process_order: Array = []  # Optimized processing order

# Performance tracking
var frame_count: int = 0
var total_frame_time: float = 0.0
var worst_frame: float = 0.0

class ProcessorInfo:
	var node: Node
	var callable: Callable
	var priority: int = 50
	var group: String = "default"  # physics, render, logic, ui
	var accumulated_delta: float = 0.0
	var last_process_time: float = 0.0
	var skip_frames: int = 0  # How many frames to skip
	var frames_skipped: int = 0

func _ready() -> void:
	name = "PerfectDeltaProcess"
	process_priority = -1000  # First to process
	
	print("⏰ [PerfectDeltaProcess] The ONE process begins...")
	
	# We are the only one with _process
	set_process(true)
	
	# Register console commands
	_register_commands()

func _process(delta: float) -> void:
	#var main_node = get_node("MainGame")
	#print("main_node : ", main_node)
	#print_tree_pretty()
	"""The ONLY _process function in the entire game"""
	var frame_start = Time.get_ticks_usec()
	
	# Sort processors by priority if needed
	if frame_count % 60 == 0:  # Re-sort every second
		_optimize_process_order()
	
	# Process all registered scripts
	for info in process_order:
		if not is_instance_valid(info.node):
			registered_processors.erase(info)
			continue
		
		# Check if we should skip this frame
		if info.frames_skipped < info.skip_frames:
			info.frames_skipped += 1
			continue
		
		info.frames_skipped = 0
		
		# Accumulate delta
		info.accumulated_delta += delta
		
		# Call the processor with accumulated delta
		var process_start = Time.get_ticks_usec()
		info.callable.call(info.accumulated_delta)
		var process_time = (Time.get_ticks_usec() - process_start) / 1000.0
		
		info.last_process_time = process_time
		info.accumulated_delta = 0.0  # Reset after use
		
		# Check frame budget
		var elapsed = (Time.get_ticks_usec() - frame_start) / 1000.0
		if elapsed > frame_budget_ms * 0.8:  # 80% budget used
			# Start skipping lower priority scripts
			_apply_adaptive_skipping(info)
	
	# Track performance
	var frame_time = (Time.get_ticks_usec() - frame_start) / 1000.0
	total_frame_time += frame_time
	frame_count += 1
	
	if frame_time > worst_frame:
		worst_frame = frame_time
	
	# Emit frame distributed signal for this frame
	var scripts_processed = 0
	for info in process_order:
		if is_instance_valid(info.node) and info.frames_skipped == 0:
			scripts_processed += 1
	frame_distributed.emit(scripts_processed, frame_time)
	
	# Emit performance report every second
	if frame_count % 60 == 0:
		var avg_frame = total_frame_time / frame_count
		var fps = 1000.0 / avg_frame if avg_frame > 0 else 60.0
		performance_report.emit(fps, avg_frame / frame_budget_ms)


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
func register_process(node: Node, callback: Callable, priority: int = 50, group: String = "default") -> void:
	"""Register a script to receive managed delta updates"""
	# Ensure the node doesn't have _process or _physics_process
	if node.has_method("_process"):
		node.set_process(false)
		push_warning("[PerfectDelta] Disabled _process on %s" % node.name)
	
	if node.has_method("_physics_process"):
		node.set_physics_process(false)
		push_warning("[PerfectDelta] Disabled _physics_process on %s" % node.name)
	
	var info = ProcessorInfo.new()
	info.node = node
	info.callable = callback
	info.priority = priority
	info.group = group
	
	registered_processors.append(info)
	script_registered.emit(node.get_script().resource_path if node.get_script() else node.name)
	
	# Force re-optimization
	_optimize_process_order()
	
	print("📝 [PerfectDelta] Registered: %s (priority: %d, group: %s)" % [
		node.name, priority, group
	])

func unregister_process(node: Node) -> void:
	"""Remove a script from processing"""
	for info in registered_processors:
		if info.node == node:
			registered_processors.erase(info)
			process_order.erase(info)
			print("🚮 [PerfectDelta] Unregistered: %s" % node.name)
			break

func _optimize_process_order() -> void:
	"""Optimize processing order for cache efficiency"""
	process_order.clear()
	
	# Group by type, then sort by priority within groups
	var groups = {}
	for info in registered_processors:
		if not info.group in groups:
			groups[info.group] = []
		groups[info.group].append(info)
	
	# Process in optimal order: physics -> logic -> render -> ui
	var group_order = ["physics", "logic", "default", "render", "ui"]
	
	for group_name in group_order:
		if group_name in groups:
			var group_processors = groups[group_name]
			group_processors.sort_custom(func(a, b): return a.priority > b.priority)
			process_order.append_array(group_processors)

func _apply_adaptive_skipping(info: ProcessorInfo) -> void:
	"""Apply frame skipping to maintain performance"""
	# Skip more frames for lower priority scripts
	if info.priority < 30:
		info.skip_frames = 2  # Process every 3rd frame
	elif info.priority < 50:
		info.skip_frames = 1  # Process every 2nd frame
	else:
		info.skip_frames = 0  # Process every frame

func get_processor_stats() -> Dictionary:
	"""Get statistics about all processors"""
	var stats = {
		"total_processors": registered_processors.size(),
		"by_group": {},
		"by_priority": {
			"high": 0,    # 70-100
			"medium": 0,  # 40-69
			"low": 0      # 0-39
		},
		"average_frame_time": total_frame_time / max(frame_count, 1),
		"worst_frame": worst_frame
	}
	
	for info in registered_processors:
		# Count by group
		if not info.group in stats.by_group:
			stats.by_group[info.group] = 0
		stats.by_group[info.group] += 1
		
		# Count by priority
		if info.priority >= 70:
			stats.by_priority.high += 1
		elif info.priority >= 40:
			stats.by_priority.medium += 1
		else:
			stats.by_priority.low += 1
	
	return stats

func force_process_all() -> void:
	"""Force process all scripts immediately (for testing)"""
	print("⚡ [PerfectDelta] Force processing all scripts...")
	var delta = get_process_delta_time()
	
	for info in registered_processors:
		if is_instance_valid(info.node):
			info.callable.call(delta)

# Console commands
func _register_commands() -> void:
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		console.register_command("delta_stats", _cmd_show_stats,
			"Show perfect delta processor statistics")
		console.register_command("delta_list", _cmd_list_processors,
			"List all registered processors")
		console.register_command("delta_force", _cmd_force_process,
			"Force process all scripts once")

func _cmd_show_stats(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	var stats = get_processor_stats()
	
	console._print_to_console("[color=cyan]⏰ Perfect Delta Stats[/color]")
	console._print_to_console("Total processors: %d" % stats.total_processors)
	console._print_to_console("Average frame: %.2fms" % stats.average_frame_time)
	console._print_to_console("Worst frame: %.2fms" % stats.worst_frame)
	console._print_to_console("By priority: High=%d, Med=%d, Low=%d" % [
		stats.by_priority.high, stats.by_priority.medium, stats.by_priority.low
	])

func _cmd_list_processors(_args: Array) -> void:
	var console = get_node("/root/ConsoleManager")
	console._print_to_console("[color=yellow]📋 Registered Processors:[/color]")
	
	for info in process_order:
		var skip_text = " (skip %d)" % info.skip_frames if info.skip_frames > 0 else ""
		console._print_to_console("• %s [%s] P:%d%s - %.2fms" % [
			info.node.name, info.group, info.priority, skip_text, info.last_process_time
		])

func _cmd_force_process(_args: Array) -> void:
	force_process_all()
	var console = get_node("/root/ConsoleManager")
	console._print_to_console("Forced process on all %d scripts" % registered_processors.size())
