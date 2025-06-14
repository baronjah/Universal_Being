# ==================================================
# SCRIPT NAME: pentagon_initialization_queue.gd
# DESCRIPTION: Pentagon dependency resolution and retry system
# PURPOSE: Handle Pentagon scripts that need other nodes to exist first
# CREATED: 2025-06-01 - Solving Pentagon initialization dependencies
# ==================================================

extends UniversalBeingBase
class_name PentagonInitializationQueue

signal all_systems_green()
signal system_initialization_complete(system_name: String)
signal system_initialization_failed(system_name: String, reason: String)
signal dependency_resolved(dependent_system: String, required_node: String)

# Queue system for delayed initialization
var pending_initializations: Array[Dictionary] = []
var failed_initializations: Array[Dictionary] = []
var completed_initializations: Dictionary = {}
var retry_attempts: Dictionary = {}

# Configuration
const MAX_RETRY_ATTEMPTS: int = 10
const RETRY_INTERVAL: float = 0.5
const DEPENDENCY_TIMEOUT: float = 30.0

# System status tracking
var systems_status: Dictionary = {}
var dependency_map: Dictionary = {}
var initialization_timer: Timer

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "PentagonInitializationQueue"
	print("🏛️ [PentagonQueue] Pentagon Initialization Queue starting...")
	
	# Setup retry timer
	initialization_timer = TimerManager.get_timer()
	initialization_timer.wait_time = RETRY_INTERVAL
	initialization_timer.timeout.connect(_process_pending_queue)
	add_child(initialization_timer)
	initialization_timer.start()
	
	print("✅ [PentagonQueue] Queue system ready - monitoring Pentagon dependencies")

# ===== PENTAGON DEPENDENCY REGISTRATION =====


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
func register_pentagon_dependency(system_name: String, required_nodes: Array[String], callback: Callable, context_node: Node = null) -> void:
	"""Register a Pentagon system that needs specific nodes to exist"""
	var dependency_info = {
		"system_name": system_name,
		"required_nodes": required_nodes,
		"callback": callback,
		"context_node": context_node,
		"registered_at": Time.get_ticks_msec(),
		"attempts": 0,
		"status": "pending"
	}
	
	pending_initializations.append(dependency_info)
	systems_status[system_name] = "pending"
	dependency_map[system_name] = required_nodes
	
	print("📋 [PentagonQueue] Registered dependency: %s → %s" % [system_name, str(required_nodes)])
	
	# Try immediate initialization if nodes might already exist
	_try_initialize_system(dependency_info)

func register_simple_pentagon_retry(system_name: String, callback: Callable, context_node: Node = null) -> void:
	"""Register a Pentagon system that just needs to retry later"""
	register_pentagon_dependency(system_name, [], callback, context_node)

# ===== DEPENDENCY CHECKING =====

func check_nodes_exist(required_nodes: Array[String]) -> Dictionary:
	"""Check if required nodes exist and return status"""
	var result = {
		"all_exist": true,
		"existing_nodes": [],
		"missing_nodes": []
	}
	
	for node_path in required_nodes:
		if has_node(node_path) or get_node_or_null(node_path) != null:
			result.existing_nodes.append(node_path)
		else:
			result.missing_nodes.append(node_path)
			result.all_exist = false
	
	return result

func _try_initialize_system(dependency_info: Dictionary) -> bool:
	"""Try to initialize a system if dependencies are met"""
	var system_name = dependency_info.system_name
	var required_nodes = dependency_info.required_nodes
	var callback = dependency_info.callback
	var context_node = dependency_info.context_node
	
	# Check if context node is still valid
	if context_node and not is_instance_valid(context_node):
		print("⚠️ [PentagonQueue] Context node invalid for %s - removing from queue" % system_name)
		_remove_from_pending(system_name)
		return false
	
	# Check dependencies
	var dependency_check = check_nodes_exist(required_nodes)
	
	if dependency_check.all_exist:
		# All dependencies met - try initialization
		dependency_info.attempts += 1
		retry_attempts[system_name] = dependency_info.attempts
		
		print("🚀 [PentagonQueue] Initializing %s (attempt %d)" % [system_name, dependency_info.attempts])
		
		var success = false
		if callback.is_valid():
			try:
				if context_node and is_instance_valid(context_node):
					success = callback.callv([]) if callback.get_argument_count() == 0 else callback.callv([context_node])
				else:
					success = callback.callv([])
				
				if success == null:
					success = true  # Assume success if no return value
			except:
				print("❌ [PentagonQueue] Callback failed for %s" % system_name)
				success = false
		
		if success:
			# Success - remove from pending and mark complete
			_mark_system_complete(system_name)
			_remove_from_pending(system_name)
			print("✅ [PentagonQueue] %s initialized successfully!" % system_name)
			system_initialization_complete.emit(system_name)
			return true
		else:
			# Failed - check if we should retry
			if dependency_info.attempts >= MAX_RETRY_ATTEMPTS:
				_mark_system_failed(system_name, "Max retry attempts reached")
				return false
			else:
				print("🔄 [PentagonQueue] %s initialization failed, will retry" % system_name)
				return false
	else:
		# Dependencies not met
		if dependency_info.attempts == 0:
			print("⏳ [PentagonQueue] %s waiting for: %s" % [system_name, str(dependency_check.missing_nodes)])
		
		# Check timeout
		var elapsed = (Time.get_ticks_msec() - dependency_info.registered_at) / 1000.0
		if elapsed > DEPENDENCY_TIMEOUT:
			_mark_system_failed(system_name, "Dependency timeout: " + str(dependency_check.missing_nodes))
			return false
	
	return false

# ===== QUEUE PROCESSING =====

func _process_pending_queue() -> void:
	"""Process all pending initializations"""
	if pending_initializations.is_empty():
		_check_all_systems_status()
		return
	
	var to_remove = []
	
	for i in range(pending_initializations.size()):
		var dependency_info = pending_initializations[i]
		var initialized = _try_initialize_system(dependency_info)
		
		if initialized or dependency_info.status == "failed":
			to_remove.append(i)
	
	# Remove completed/failed systems (reverse order to maintain indices)
	for i in range(to_remove.size() - 1, -1, -1):
		pending_initializations.remove_at(to_remove[i])
	
	_check_all_systems_status()

func _check_all_systems_status() -> void:
	"""Check if all systems are green and operational"""
	var all_complete = true
	var pending_count = 0
	var failed_count = 0
	
	for system_name in systems_status:
		match systems_status[system_name]:
			"pending":
				all_complete = false
				pending_count += 1
			"failed":
				all_complete = false
				failed_count += 1
			"complete":
				pass  # This is good
	
	# Emit status updates
	if all_complete and systems_status.size() > 0:
		print("🌟 [PentagonQueue] ALL SYSTEMS GREEN! Pentagon Architecture fully operational")
		all_systems_green.emit()
	elif pending_count > 0 or failed_count > 0:
		if Engine.get_process_frames() % 300 == 0:  # Every 5 seconds at 60fps
			print("📊 [PentagonQueue] Status: %d complete, %d pending, %d failed" % [
				systems_status.size() - pending_count - failed_count,
				pending_count,
				failed_count
			])

# ===== SYSTEM STATUS MANAGEMENT =====

func _mark_system_complete(system_name: String) -> void:
	"""Mark a system as successfully initialized"""
	systems_status[system_name] = "complete"
	completed_initializations[system_name] = Time.get_ticks_msec()

func _mark_system_failed(system_name: String, reason: String) -> void:
	"""Mark a system as failed to initialize"""
	systems_status[system_name] = "failed"
	failed_initializations.append({
		"system_name": system_name,
		"reason": reason,
		"failed_at": Time.get_ticks_msec()
	})
	
	print("❌ [PentagonQueue] %s initialization FAILED: %s" % [system_name, reason])
	system_initialization_failed.emit(system_name, reason)
	_remove_from_pending(system_name)

func _remove_from_pending(system_name: String) -> void:
	"""Remove a system from pending queue"""
	for i in range(pending_initializations.size() - 1, -1, -1):
		if pending_initializations[i].system_name == system_name:
			pending_initializations.remove_at(i)
			break

# ===== MANUAL OPERATIONS =====

func force_retry_system(system_name: String) -> void:
	"""Force retry a specific system"""
	if systems_status.has(system_name):
		systems_status[system_name] = "pending"
		retry_attempts.erase(system_name)
		
		# Re-add to pending if it was failed
		var found_in_failed = false
		for i in range(failed_initializations.size() - 1, -1, -1):
			if failed_initializations[i].system_name == system_name:
				failed_initializations.remove_at(i)
				found_in_failed = true
				break
		
		if found_in_failed and dependency_map.has(system_name):
			# Re-register the dependency
			print("🔄 [PentagonQueue] Force retrying %s" % system_name)

func force_retry_all_failed() -> void:
	"""Force retry all failed systems"""
	var failed_system_names = []
	for failed_info in failed_initializations:
		failed_system_names.append(failed_info.system_name)
	
	for system_name in failed_system_names:
		force_retry_system(system_name)

func get_system_status(system_name: String) -> String:
	"""Get the current status of a system"""
	return systems_status.get(system_name, "unknown")

func get_all_systems_status() -> Dictionary:
	"""Get status of all registered systems"""
	return systems_status.duplicate()

func get_pending_systems() -> Array[String]:
	"""Get list of systems still pending initialization"""
	var pending = []
	for system_name in systems_status:
		if systems_status[system_name] == "pending":
			pending.append(system_name)
	return pending

func get_failed_systems() -> Array[Dictionary]:
	"""Get list of systems that failed initialization"""
	return failed_initializations.duplicate()

# ===== CONSOLE COMMANDS =====

func register_console_commands() -> void:
	"""Register console commands for debugging"""
	var console = get_node_or_null("/root/ConsoleManager")
	if console and "commands" in console:
		console.commands["pentagon_queue_status"] = _cmd_queue_status
		console.commands["pentagon_retry_failed"] = _cmd_retry_failed
		console.commands["pentagon_force_retry"] = _cmd_force_retry
		console.commands["pentagon_dependencies"] = _cmd_show_dependencies
		console.commands["pentagon_green_check"] = _cmd_green_check
		print("🎮 [PentagonQueue] Console commands registered")

func _cmd_queue_status(_args: Array) -> String:
	"""Show Pentagon queue status"""
	var result = "🏛️ PENTAGON INITIALIZATION QUEUE STATUS\n"
	result += "════════════════════════════════════════\n"
	
	var complete_count = 0
	var pending_count = 0
	var failed_count = 0
	
	for system_name in systems_status:
		match systems_status[system_name]:
			"complete":
				complete_count += 1
			"pending":
				pending_count += 1
			"failed":
				failed_count += 1
	
	result += "✅ Complete: %d systems\n" % complete_count
	result += "⏳ Pending: %d systems\n" % pending_count
	result += "❌ Failed: %d systems\n" % failed_count
	
	if pending_count > 0:
		result += "\n📋 PENDING SYSTEMS:\n"
		for dependency_info in pending_initializations:
			var system_name = dependency_info.system_name
			var required_nodes = dependency_info.required_nodes
			var attempts = dependency_info.attempts
			result += "• %s (attempt %d) → %s\n" % [system_name, attempts, str(required_nodes)]
	
	if failed_count > 0:
		result += "\n❌ FAILED SYSTEMS:\n"
		for failed_info in failed_initializations:
			result += "• %s: %s\n" % [failed_info.system_name, failed_info.reason]
	
	return result

func _cmd_retry_failed(_args: Array) -> String:
	"""Retry all failed systems"""
	var failed_count = failed_initializations.size()
	if failed_count == 0:
		return "No failed systems to retry"
	
	force_retry_all_failed()
	return "🔄 Retrying %d failed systems" % failed_count

func _cmd_force_retry(args: Array) -> String:
	"""Force retry specific system"""
	if args.is_empty():
		return "Usage: pentagon_force_retry <system_name>"
	
	var system_name = args[0]
	if not systems_status.has(system_name):
		return "❌ System not found: " + system_name
	
	force_retry_system(system_name)
	return "🔄 Force retrying: " + system_name

func _cmd_show_dependencies(_args: Array) -> String:
	"""Show dependency map"""
	var result = "🔗 PENTAGON DEPENDENCY MAP\n"
	result += "═══════════════════════════\n"
	
	for system_name in dependency_map:
		var deps = dependency_map[system_name]
		var status = systems_status.get(system_name, "unknown")
		result += "%s [%s] → %s\n" % [system_name, status, str(deps)]
	
	return result

func _cmd_green_check(_args: Array) -> String:
	"""Check if all systems are green"""
	var complete_count = 0
	var total_count = systems_status.size()
	
	for status in systems_status.values():
		if status == "complete":
			complete_count += 1
	
	if complete_count == total_count and total_count > 0:
		return "🌟 ALL SYSTEMS GREEN! Pentagon Architecture fully operational (%d/%d)" % [complete_count, total_count]
	else:
		return "⏳ Systems status: %d/%d complete" % [complete_count, total_count]