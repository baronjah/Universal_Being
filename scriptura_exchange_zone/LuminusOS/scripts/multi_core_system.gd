extends Node

class_name MultiCoreSystem

# Multi-core simulation for LuminusOS
# Simulates parallel processing environments 

signal task_completed(task_id, result)
signal core_state_changed(core_id, state)
signal memory_updated(address, value)

# Core States
enum CoreState {IDLE, RUNNING, WAITING, ERROR}

# Available cores
var cores = []
var core_count = 4
var max_cores = 16

# Task queue and memory
var task_queue = []
var shared_memory = {}
var memory_locks = {}

# Tick system for automation
var auto_tick_enabled = false
var tick_speed = 0.1
var tick_timer = 0.0

# Performance metrics
var performance_metrics = {
	"tasks_completed": 0,
	"average_completion_time": 0.0,
	"total_execution_time": 0.0
}

func _ready():
	initialize_cores(core_count)

func _process(delta):
	if auto_tick_enabled:
		tick_timer += delta
		if tick_timer >= tick_speed:
			tick_timer = 0.0
			process_tick()

func initialize_cores(count):
	cores.clear()
	core_count = min(count, max_cores)
	
	for i in range(core_count):
		var core = {
			"id": i,
			"state": CoreState.IDLE,
			"current_task": null,
			"progress": 0.0,
			"execution_time": 0.0
		}
		cores.append(core)
		emit_signal("core_state_changed", i, CoreState.IDLE)

# Schedule a task on available cores
func schedule_task(task):
	task_queue.append(task)
	assign_tasks()

# Process one tick of the system
func process_tick():
	# Update running tasks
	for i in range(cores.size()):
		var core = cores[i]
		if core["state"] == CoreState.RUNNING:
			process_core_task(i)
	
	# Assign new tasks if cores are available
	assign_tasks()

# Process a single core's current task
func process_core_task(core_id):
	var core = cores[core_id]
	if core["current_task"] == null:
		return
		
	var task = core["current_task"]
	
	# Simulate task execution
	core["progress"] += randf_range(0.05, 0.2)  # Random progress per tick
	core["execution_time"] += tick_speed
	
	if core["progress"] >= 1.0:
		# Task completed
		var result = execute_task(task)
		
		emit_signal("task_completed", task["id"], result)
		
		# Update performance metrics
		performance_metrics["tasks_completed"] += 1
		performance_metrics["total_execution_time"] += core["execution_time"]
		performance_metrics["average_completion_time"] = performance_metrics["total_execution_time"] / performance_metrics["tasks_completed"]
		
		# Reset core
		core["state"] = CoreState.IDLE
		core["current_task"] = null
		core["progress"] = 0.0
		core["execution_time"] = 0.0
		
		emit_signal("core_state_changed", core_id, CoreState.IDLE)
		
		# Assign new tasks
		assign_tasks()

# Assign tasks to available cores
func assign_tasks():
	if task_queue.size() == 0:
		return
		
	for i in range(cores.size()):
		var core = cores[i]
		if core["state"] == CoreState.IDLE and task_queue.size() > 0:
			var task = task_queue.pop_front()
			
			core["state"] = CoreState.RUNNING
			core["current_task"] = task
			core["progress"] = 0.0
			core["execution_time"] = 0.0
			
			emit_signal("core_state_changed", core_id, CoreState.RUNNING)

# Execute a task and return its result
func execute_task(task):
	var result = null
	
	match task["type"]:
		"compute":
			result = compute_task(task)
		"io":
			result = io_task(task)
		"memory":
			result = memory_task(task)
		_:
			result = {"status": "error", "message": "Unknown task type"}
	
	return result

func compute_task(task):
	# Simulated computation task
	var result = 0
	
	match task["operation"]:
		"add":
			result = task["operands"][0] + task["operands"][1]
		"subtract":
			result = task["operands"][0] - task["operands"][1]
		"multiply":
			result = task["operands"][0] * task["operands"][1]
		"divide":
			if task["operands"][1] != 0:
				result = task["operands"][0] / task["operands"][1]
			else:
				return {"status": "error", "message": "Division by zero"}
		_:
			return {"status": "error", "message": "Unknown operation"}
	
	return {"status": "success", "result": result}

func io_task(task):
	# Simulated I/O task
	match task["operation"]:
		"read":
			# Simulate reading from a file
			return {"status": "success", "data": "Simulated file content for " + task["path"]}
		"write":
			# Simulate writing to a file
			return {"status": "success", "message": "Data written to " + task["path"]}
		_:
			return {"status": "error", "message": "Unknown I/O operation"}

func memory_task(task):
	match task["operation"]:
		"read":
			if shared_memory.has(task["address"]):
				return {"status": "success", "value": shared_memory[task["address"]]}
			else:
				return {"status": "error", "message": "Memory address not found"}
		"write":
			shared_memory[task["address"]] = task["value"]
			emit_signal("memory_updated", task["address"], task["value"])
			return {"status": "success"}
		"lock":
			if memory_locks.has(task["address"]) and memory_locks[task["address"]]:
				return {"status": "error", "message": "Memory address already locked"}
			memory_locks[task["address"]] = true
			return {"status": "success"}
		"unlock":
			if memory_locks.has(task["address"]):
				memory_locks[task["address"]] = false
				return {"status": "success"}
			return {"status": "error", "message": "Memory address not locked"}
		_:
			return {"status": "error", "message": "Unknown memory operation"}

# API for LuminusOS terminal commands

func cmd_cores(args):
	# Command to manage cores
	if args.size() == 0:
		return get_cores_status()
	
	match args[0]:
		"count":
			if args.size() >= 2 and args[1].is_valid_int():
				var new_count = int(args[1])
				if new_count > 0 and new_count <= max_cores:
					initialize_cores(new_count)
					return "Core count set to " + str(core_count)
				else:
					return "Core count must be between 1 and " + str(max_cores)
			return "Current core count: " + str(core_count)
		"status":
			return get_cores_status()
		"reset":
			initialize_cores(core_count)
			return "All cores reset to idle state"
		_:
			return "Unknown cores command. Try 'count', 'status', or 'reset'"

func cmd_task(args):
	# Command to manage tasks
	if args.size() == 0:
		return "Current tasks in queue: " + str(task_queue.size())
	
	match args[0]:
		"add":
			if args.size() < 3:
				return "Usage: task add <type> <operation> [params...]"
			
			var task_type = args[1]
			var operation = args[2]
			var task_id = performance_metrics["tasks_completed"] + task_queue.size() + 1
			
			var task = {
				"id": task_id,
				"type": task_type,
				"operation": operation
			}
			
			match task_type:
				"compute":
					if args.size() < 5:
						return "Usage: task add compute <operation> <operand1> <operand2>"
					if args[3].is_valid_float() and args[4].is_valid_float():
						task["operands"] = [float(args[3]), float(args[4])]
					else:
						return "Operands must be numbers"
				"io":
					if args.size() < 4:
						return "Usage: task add io <operation> <path>"
					task["path"] = args[3]
				"memory":
					if args.size() < 4:
						return "Usage: task add memory <operation> <address> [value]"
					task["address"] = args[3]
					if args.size() >= 5 and args[2] == "write":
						task["value"] = args[4]
			
			schedule_task(task)
			return "Task " + str(task_id) + " added to queue"
			
		"list":
			var task_list = "Tasks in queue: " + str(task_queue.size()) + "\n"
			for i in range(task_queue.size()):
				var task = task_queue[i]
				task_list += str(i+1) + ". ID: " + str(task["id"]) + ", Type: " + task["type"] + ", Op: " + task["operation"] + "\n"
			return task_list
			
		"clear":
			var count = task_queue.size()
			task_queue.clear()
			return "Cleared " + str(count) + " tasks from queue"
			
		_:
			return "Unknown task command. Try 'add', 'list', or 'clear'"

func cmd_memory(args):
	# Command to manage shared memory
	if args.size() == 0:
		return "Usage: memory <operation> [parameters]"
	
	match args[0]:
		"list":
			var mem_list = "Shared memory contents:\n"
			for address in shared_memory:
				var lock_status = ""
				if memory_locks.has(address) and memory_locks[address]:
					lock_status = " [LOCKED]"
				mem_list += address + ": " + str(shared_memory[address]) + lock_status + "\n"
			return mem_list
			
		"get":
			if args.size() < 2:
				return "Usage: memory get <address>"
			var address = args[1]
			if shared_memory.has(address):
				return "Memory at " + address + ": " + str(shared_memory[address])
			else:
				return "Address not found: " + address
				
		"set":
			if args.size() < 3:
				return "Usage: memory set <address> <value>"
			var address = args[1]
			var value = args[2]
			
			# Check if memory is locked
			if memory_locks.has(address) and memory_locks[address]:
				return "Cannot write to locked memory: " + address
				
			shared_memory[address] = value
			emit_signal("memory_updated", address, value)
			return "Memory set: " + address + " = " + value
			
		"lock":
			if args.size() < 2:
				return "Usage: memory lock <address>"
			var address = args[1]
			if memory_locks.has(address) and memory_locks[address]:
				return "Memory already locked: " + address
			memory_locks[address] = true
			return "Memory locked: " + address
			
		"unlock":
			if args.size() < 2:
				return "Usage: memory unlock <address>"
			var address = args[1]
			if not memory_locks.has(address) or not memory_locks[address]:
				return "Memory not locked: " + address
			memory_locks[address] = false
			return "Memory unlocked: " + address
			
		"clear":
			shared_memory.clear()
			memory_locks.clear()
			return "All shared memory cleared"
			
		_:
			return "Unknown memory command. Try 'list', 'get', 'set', 'lock', 'unlock', or 'clear'"

func cmd_tick(args):
	# Command to manage auto-ticking
	if args.size() == 0:
		return "Auto-tick: " + ("Enabled" if auto_tick_enabled else "Disabled") + ", Speed: " + str(tick_speed) + "s"
	
	match args[0]:
		"on":
			auto_tick_enabled = true
			return "Auto-tick enabled"
			
		"off":
			auto_tick_enabled = false
			return "Auto-tick disabled"
			
		"speed":
			if args.size() < 2:
				return "Current tick speed: " + str(tick_speed) + "s"
			if args[1].is_valid_float():
				var new_speed = float(args[1])
				if new_speed > 0.01:
					tick_speed = new_speed
					return "Tick speed set to " + str(tick_speed) + "s"
				else:
					return "Tick speed must be at least 0.01s"
			return "Invalid tick speed"
			
		"once":
			process_tick()
			return "Manual tick processed"
			
		_:
			return "Unknown tick command. Try 'on', 'off', 'speed', or 'once'"

func cmd_stats():
	# Command to show performance stats
	var stats = "Multi-Core System Statistics:\n"
	stats += "Total tasks completed: " + str(performance_metrics["tasks_completed"]) + "\n"
	stats += "Average completion time: " + str(performance_metrics["average_completion_time"]) + "s\n"
	stats += "Total execution time: " + str(performance_metrics["total_execution_time"]) + "s\n"
	stats += "Current utilization: " + str(get_utilization() * 100) + "%\n"
	return stats

func get_cores_status():
	var status = "Core Status (" + str(core_count) + " cores):\n"
	
	for i in range(cores.size()):
		var core = cores[i]
		var state_str = ""
		
		match core["state"]:
			CoreState.IDLE:
				state_str = "IDLE"
			CoreState.RUNNING:
				state_str = "RUNNING"
			CoreState.WAITING:
				state_str = "WAITING"
			CoreState.ERROR:
				state_str = "ERROR"
		
		status += "Core " + str(core["id"]) + ": " + state_str
		
		if core["state"] == CoreState.RUNNING and core["current_task"] != null:
			status += " (Task " + str(core["current_task"]["id"]) + ", " 
			status += str(int(core["progress"] * 100)) + "%, "
			status += str(core["execution_time"]) + "s)"
		
		status += "\n"
	
	return status

func get_utilization():
	var active_cores = 0
	for core in cores:
		if core["state"] == CoreState.RUNNING:
			active_cores += 1
	
	return float(active_cores) / float(core_count)