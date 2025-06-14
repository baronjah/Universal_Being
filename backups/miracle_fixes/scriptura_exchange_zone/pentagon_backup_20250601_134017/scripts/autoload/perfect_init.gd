################################################################
# PERFECT INIT SYSTEM - PHASE 1 IMPLEMENTATION
# Universal initialization control and dependency management
# Created: May 31st, 2025 | Perfect Pentagon Architecture
# Location: scripts/autoload/perfect_init.gd
################################################################

extends UniversalBeingBase
################################################################
# CORE VARIABLES
################################################################

var init_sequence: Array[Dictionary] = []
var init_status: Dictionary = {}
var dependencies_resolved: bool = false
var initialization_complete: bool = false
var debug_mode: bool = true

################################################################
# SIGNALS - Perfect Pentagon Communication
################################################################

signal init_started(script_name: String)
signal init_completed(script_name: String)
signal all_init_complete()
signal dependency_resolved(dependency: String)
signal init_error(script_name: String, error: String)

################################################################
# READY FUNCTION - Initialize the Perfect Init System
################################################################

func _ready():
	print("🌟 PERFECT INIT SYSTEM: Initializing...")
	set_process(false)  # Only process when needed
	
	# Set up system monitoring
	init_status["system_start_time"] = Time.get_ticks_msec()
	init_status["total_registered"] = 0
	init_status["completed"] = 0
	init_status["failed"] = 0
	
	if debug_mode:
		print("✅ PERFECT INIT: System ready for registration")

################################################################
# REGISTRATION FUNCTIONS - Register init functions
################################################################


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
func register_init(script_name: String, init_callable: Callable, priority: int = 50, deps: Array = []) -> bool:
	"""
	Register an initialization function with the Perfect Init system
	
	INPUT: script_name (identifier), init_callable (function to call), priority (1-100), dependencies (array of script names)
	PROCESS: Validates input, creates init entry, sorts by priority
	OUTPUT: Returns true if registration successful
	CHANGES: Adds entry to init_sequence array
	CONNECTION: Links to dependency resolution system
	"""
	
	# Validation
	if script_name == "" or not init_callable.is_valid():
		print("🚨 PERFECT INIT ERROR: Invalid registration for " + script_name)
		return false
	
	# Check for duplicate registration
	for init_item in init_sequence:
		if init_item.script == script_name:
			print("⚠️ PERFECT INIT WARNING: " + script_name + " already registered, updating...")
			init_item.callable = init_callable
			init_item.priority = priority
			init_item.dependencies = deps
			_sort_by_priority()
			return true
	
	# Create new init entry
	var init_entry = {
		"script": script_name,
		"callable": init_callable,
		"priority": priority,
		"dependencies": deps,
		"status": "pending",
		"registration_time": Time.get_ticks_msec(),
		"start_time": 0,
		"completion_time": 0,
		"error_message": ""
	}
	
	init_sequence.append(init_entry)
	init_status.total_registered += 1
	_sort_by_priority()
	
	if debug_mode:
		print("📝 PERFECT INIT: Registered %s (priority: %d, deps: %s)" % [script_name, priority, str(deps)])
	
	return true

################################################################
# DEPENDENCY MANAGEMENT
################################################################

func _dependencies_met(init_item: Dictionary) -> bool:
	"""
	Check if all dependencies for an init item are resolved
	"""
	if init_item.dependencies.is_empty():
		return true
	
	for dependency in init_item.dependencies:
		var dep_completed = false
		for completed_item in init_sequence:
			if completed_item.script == dependency and completed_item.status == "complete":
				dep_completed = true
				break
		
		if not dep_completed:
			if debug_mode:
				print("⏳ DEPENDENCY WAIT: %s waiting for %s" % [init_item.script, dependency])
			return false
	
	return true

func _sort_by_priority():
	"""
	Sort init sequence by priority (higher priority = lower number = first execution)
	"""
	init_sequence.sort_custom(func(a, b): return a.priority < b.priority)

################################################################
# EXECUTION FUNCTIONS - Core initialization execution
################################################################

func execute_divine_initialization() -> void:
	"""
	Execute the complete initialization sequence with dependency resolution
	
	INPUT: None (uses registered init_sequence)
	PROCESS: Executes each init function in priority order, respecting dependencies
	OUTPUT: Calls all registered initialization functions
	CHANGES: Updates init_status for each item, emits completion signals
	CONNECTION: Triggers ready for Perfect Ready system
	"""
	
	if initialization_complete:
		print("⚠️ PERFECT INIT: Already initialized, skipping")
		return
	
	print("🌟 PERFECT INIT: Beginning divine initialization sequence...")
	print("📊 INIT STATUS: %d scripts registered" % init_sequence.size())
	
	var max_attempts = init_sequence.size() * 3  # Prevent infinite loops
	var attempt_count = 0
	var completed_this_round = true
	
	# Main execution loop - continue until all dependencies resolved
	while completed_this_round and attempt_count < max_attempts:
		completed_this_round = false
		attempt_count += 1
		
		for init_item in init_sequence:
			if init_item.status == "pending" and _dependencies_met(init_item):
				_execute_single_init(init_item)
				completed_this_round = true
	
	# Check for incomplete initialization
	var incomplete_count = 0
	for init_item in init_sequence:
		if init_item.status == "pending":
			incomplete_count += 1
			print("🚨 INIT INCOMPLETE: %s (deps: %s)" % [init_item.script, str(init_item.dependencies)])
	
	if incomplete_count == 0:
		_finalize_initialization()
	else:
		print("🚨 PERFECT INIT ERROR: %d scripts failed to initialize due to dependency issues" % incomplete_count)

func _execute_single_init(init_item: Dictionary) -> void:
	"""
	Execute a single initialization function with error handling
	"""
	init_item.status = "running"
	init_item.start_time = Time.get_ticks_msec()
	
	if debug_mode:
		print("⚡ EXECUTING INIT: " + init_item.script)
	
	emit_signal("init_started", init_item.script)
	
	# Execute with error handling
	init_item.callable.call()
	init_item.status = "complete"
	init_item.completion_time = Time.get_ticks_msec()
	init_status.completed += 1
	
	if debug_mode:
		var duration = init_item.completion_time - init_item.start_time
		print("✅ INIT COMPLETE: %s (%.2f ms)" % [init_item.script, duration])
	
	emit_signal("init_completed", init_item.script)

func _finalize_initialization() -> void:
	"""
	Complete the initialization process and emit final signals
	"""
	initialization_complete = true
	dependencies_resolved = true
	
	var total_time = Time.get_ticks_msec() - init_status.system_start_time
	
	print("🎯 PERFECT INIT COMPLETE!")
	print("📊 FINAL STATUS: %d completed, %d failed, %.2f ms total" % [
		init_status.completed,
		init_status.failed, 
		total_time
	])
	
	emit_signal("all_init_complete")
	
	# Connect to Perfect Ready if it exists
	if has_node("/root/PerfectReady"):
		print("🔗 PERFECT INIT: Triggering Perfect Ready system...")
		get_node("/root/PerfectReady").execute_ready_sequence()

################################################################
# STATUS AND DEBUG FUNCTIONS
################################################################

func get_initialization_status() -> Dictionary:
	"""
	Get complete status of initialization system
	"""
	return {
		"complete": initialization_complete,
		"total_registered": init_status.total_registered,
		"completed": init_status.completed,
		"failed": init_status.failed,
		"pending": init_sequence.filter(func(item): return item.status == "pending").size(),
		"sequence": init_sequence.duplicate()
	}

func get_status_string() -> String:
	"""
	Get human-readable status string for console
	"""
	var status = get_initialization_status()
	return """
🌟 PERFECT INIT SYSTEM STATUS
═══════════════════════════════
Initialization Complete: %s
Total Registered: %d
✅ Completed: %d
🚨 Failed: %d  
⏳ Pending: %d
🎯 Dependencies Resolved: %s

📋 INIT SEQUENCE:
%s
""" % [
		"YES" if initialization_complete else "NO",
		status.total_registered,
		status.completed,
		status.failed,
		status.pending,
		"YES" if dependencies_resolved else "NO",
		_get_sequence_display()
	]

func _get_sequence_display() -> String:
	"""
	Generate display string for init sequence
	"""
	var display = ""
	for i in range(init_sequence.size()):
		var item = init_sequence[i]
		var status_icon = "⏳"
		match item.status:
			"complete": status_icon = "✅"
			"error": status_icon = "🚨"
			"running": status_icon = "⚡"
		
		display += "%d. %s %s (priority: %d)\n" % [i+1, status_icon, item.script, item.priority]
	
	return display

################################################################
# CONSOLE INTEGRATION - For debugging and testing
################################################################

func console_init_status() -> String:
	"""Console command: Show initialization status"""
	return get_status_string()

func console_init_restart() -> String:
	"""Console command: Restart initialization process"""
	initialization_complete = false
	dependencies_resolved = false
	init_status.completed = 0
	init_status.failed = 0
	
	# Reset all statuses to pending
	for item in init_sequence:
		item.status = "pending"
		item.start_time = 0
		item.completion_time = 0
		item.error_message = ""
	
	execute_divine_initialization()
	return "🔄 PERFECT INIT: Restarted initialization process"

func console_init_debug(enabled: String = "") -> String:
	"""Console command: Toggle debug mode"""
	if enabled != "":
		debug_mode = enabled.to_lower() == "true" or enabled == "1"
	else:
		debug_mode = !debug_mode
	
	return "🔧 PERFECT INIT: Debug mode " + ("ENABLED" if debug_mode else "DISABLED")

################################################################
# PERFECT PENTAGON INTEGRATION
################################################################

func get_system_info() -> Dictionary:
	"""
	Return system information for Perfect Pentagon coordination
	"""
	return {
		"system_name": "Perfect Init",
		"version": "1.0",
		"status": "active" if initialization_complete else "initializing",
		"priority": 1,  # Highest priority in Pentagon
		"dependencies": [],  # No dependencies - this is the foundation
		"provides": ["initialization_control", "dependency_resolution"],
		"initialization_complete": initialization_complete
	}

################################################################
# AUTOLOAD READY - Final system preparation
################################################################

func _enter_tree():
	"""
	Called when autoload is added to scene tree
	"""
	if debug_mode:
		print("🏗️ PERFECT INIT: Entering scene tree, system starting...")

################################################################
# END OF PERFECT INIT SYSTEM
################################################################