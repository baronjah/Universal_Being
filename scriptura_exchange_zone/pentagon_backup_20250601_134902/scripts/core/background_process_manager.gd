# 🏛️ Background Process Manager - Resource management system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Resource management system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
## Background Process Manager
## Controls and limits per-frame calculations
## Created: 2025-05-26

signal performance_warning(system: String, frame_time: float)

# Process limits
const MAX_PHYSICS_PROCESSES_PER_FRAME = 5
const MAX_VISUAL_PROCESSES_PER_FRAME = 10
const TARGET_FRAME_TIME = 16.67  # 60 FPS target
const PERFORMANCE_WARNING_THRESHOLD = 20.0  # Warn if frame takes > 20ms

# Registered processes
var physics_processes: Array[Dictionary] = []
var visual_processes: Array[Dictionary] = []
var debug_processes: Array[Dictionary] = []

# Process scheduling
var physics_index: int = 0
var visual_index: int = 0
var frame_count: int = 0

# Performance tracking
var frame_times: Array[float] = []
var max_frame_history: int = 60

# Process states
var processes_enabled: bool = true
var debug_enabled: bool = false

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("[ProcessManager] Background process manager initialized")
	set_process(true)
	set_physics_process(true)

## Register a physics process

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
func register_physics_process(node: Node, callback: Callable, priority: int = 5) -> void:
	physics_processes.append({
		"node": node,
		"callback": callback,
		"priority": priority,
		"active": true,
		"last_run": 0
	})
	physics_processes.sort_custom(_sort_by_priority)
	print("[ProcessManager] Registered physics process: %s" % node.name)

## Register a visual process
func register_visual_process(node: Node, callback: Callable, priority: int = 5) -> void:
	visual_processes.append({
		"node": node,
		"callback": callback,
		"priority": priority,
		"active": true,
		"last_run": 0
	})
	visual_processes.sort_custom(_sort_by_priority)
	print("[ProcessManager] Registered visual process: %s" % node.name)

## Register a debug process (only runs when debug is enabled)
func register_debug_process(node: Node, callback: Callable) -> void:
	debug_processes.append({
		"node": node,
		"callback": callback,
		"active": true
	})
	print("[ProcessManager] Registered debug process: %s" % node.name)

## Unregister a process
func unregister_process(node: Node) -> void:
	physics_processes = physics_processes.filter(func(p): return p.node != node)
	visual_processes = visual_processes.filter(func(p): return p.node != node)
	debug_processes = debug_processes.filter(func(p): return p.node != node)

## Main physics processing (60 Hz)

# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	if not processes_enabled:
		return
	
	var start_time = Time.get_ticks_usec()
	var processes_run = 0
	
	# Run limited physics processes
	for i in range(MAX_PHYSICS_PROCESSES_PER_FRAME):
		if physics_index >= physics_processes.size():
			physics_index = 0
			break
			
		var process = physics_processes[physics_index]
		if process.active and is_instance_valid(process.node):
			process.callback.call(delta)
			process.last_run = frame_count
			processes_run += 1
		
		physics_index += 1
	
	# Track performance
	var physics_time = (Time.get_ticks_usec() - start_time) / 1000.0
	if physics_time > 8.0:  # Half of target frame time
		performance_warning.emit("physics", physics_time)
	
	# Debug: track processes run
	if debug_enabled and processes_run > 0:
		print("[BGProcess] Physics: ", processes_run, " processes in ", physics_time, "ms")

## Main visual processing (variable rate)
func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	if not processes_enabled:
		return
		
	var start_time = Time.get_ticks_usec()
	var processes_run = 0
	
	# Run limited visual processes
	for i in range(MAX_VISUAL_PROCESSES_PER_FRAME):
		if visual_index >= visual_processes.size():
			visual_index = 0
			break
			
		var process = visual_processes[visual_index]
		if process.active and is_instance_valid(process.node):
			process.callback.call(delta)
			process.last_run = frame_count
			processes_run += 1
		
		visual_index += 1
	
	# Run debug processes if enabled
	if debug_enabled:
		for process in debug_processes:
			if process.active and is_instance_valid(process.node):
				process.callback.call(delta)
	
	# Track frame time
	var frame_time = (Time.get_ticks_usec() - start_time) / 1000.0
	frame_times.append(frame_time)
	if frame_times.size() > max_frame_history:
		frame_times.pop_front()
	
	if frame_time > PERFORMANCE_WARNING_THRESHOLD:
		performance_warning.emit("frame", frame_time)
	
	# Debug: track visual processes run
	if debug_enabled and processes_run > 0:
		print("[BGProcess] Visual: ", processes_run, " processes in ", frame_time, "ms")
	
	frame_count += 1

## Enable/disable debug processes
func set_debug_enabled(enabled: bool) -> void:
	debug_enabled = enabled
	print("[ProcessManager] Debug processes: %s" % ("enabled" if enabled else "disabled"))

## Get performance statistics
func get_performance_stats() -> Dictionary:
	var avg_frame_time = 0.0
	if frame_times.size() > 0:
		for time in frame_times:
			avg_frame_time += time
		avg_frame_time /= frame_times.size()
	
	return {
		"avg_frame_time": avg_frame_time,
		"physics_processes": physics_processes.size(),
		"visual_processes": visual_processes.size(),
		"debug_processes": debug_processes.size(),
		"debug_enabled": debug_enabled
	}

## Temporarily disable a process
func set_process_active(node: Node, active: bool) -> void:
	for process in physics_processes + visual_processes + debug_processes:
		if process.node == node:
			process.active = active
			break

func _sort_by_priority(a: Dictionary, b: Dictionary) -> bool:
	return a.priority > b.priority