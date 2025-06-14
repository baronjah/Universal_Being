extends Node

# Concurrent Function Processor for Terminal Memory System
# Allows running 2-3 functions concurrently with priority and dependency management

class_name ConcurrentProcessor

# Task priority levels
enum Priority { LOW, MEDIUM, HIGH, CRITICAL }

# Task status tracking
enum TaskStatus { PENDING, RUNNING, COMPLETED, FAILED, CANCELED }

# Task structure for function processing
class Task:
	var id: String
	var function_ref: FuncRef
	var args: Array
	var priority: int
	var dependencies: Array
	var status: int
	var result = null
	var error_message: String = ""
	var start_time: int = 0
	var end_time: int = 0
	
	func _init(p_id: String, p_function: FuncRef, p_args: Array = [], p_priority: int = Priority.MEDIUM):
		id = p_id
		function_ref = p_function
		args = p_args
		priority = p_priority
		status = TaskStatus.PENDING
		dependencies = []
	
	func add_dependency(task_id: String) -> void:
		dependencies.append(task_id)
	
	func can_run(completed_tasks: Array) -> bool:
		if status != TaskStatus.PENDING:
			return false
			
		# Check if all dependencies are completed
		for dep in dependencies:
			if not completed_tasks.has(dep):
				return false
				
		return true
	
	func execute() -> void:
		status = TaskStatus.RUNNING
		start_time = OS.get_ticks_msec()
		
		if function_ref.is_valid():
			# Execute with variable number of arguments
			match args.size():
				0: result = function_ref.call_func()
				1: result = function_ref.call_func(args[0])
				2: result = function_ref.call_func(args[0], args[1])
				3: result = function_ref.call_func(args[0], args[1], args[2])
				4: result = function_ref.call_func(args[0], args[1], args[2], args[3])
				_: 
					# For more args, use call_funcv
					result = function_ref.call_funcv(args)
			
			status = TaskStatus.COMPLETED
		else:
			error_message = "Invalid function reference"
			status = TaskStatus.FAILED
			
		end_time = OS.get_ticks_msec()

# Main processor properties
var max_concurrent_tasks: int = 3
var task_queue: Array = []
var running_tasks: Array = []
var completed_tasks: Array = []
var failed_tasks: Array = []
var completed_task_ids: Array = []

# Signals
signal task_started(task_id)
signal task_completed(task_id, result)
signal task_failed(task_id, error)
signal all_tasks_completed()

func _ready() -> void:
	# Set up processing thread or timer for continuous execution
	var process_timer = Timer.new()
	process_timer.wait_time = 0.05  # 50ms intervals for processing
	process_timer.autostart = true
	process_timer.connect("timeout", self, "_process_tasks")
	add_child(process_timer)

# Create a new task and add it to the queue
func schedule_task(id: String, function_object: Object, function_name: String, 
				  args: Array = [], priority: int = Priority.MEDIUM) -> Task:
	var func_ref = funcref(function_object, function_name)
	var task = Task.new(id, func_ref, args, priority)
	
	task_queue.append(task)
	# Sort by priority (higher priority first)
	task_queue.sort_custom(self, "_compare_task_priority")
	
	return task

# Execute 2-3 functions at once based on priority and dependencies
func _process_tasks() -> void:
	# First, update status of running tasks
	var i = running_tasks.size() - 1
	while i >= 0:
		var task = running_tasks[i]
		
		if task.status == TaskStatus.COMPLETED:
			running_tasks.remove(i)
			completed_tasks.append(task)
			completed_task_ids.append(task.id)
			emit_signal("task_completed", task.id, task.result)
			
		elif task.status == TaskStatus.FAILED:
			running_tasks.remove(i)
			failed_tasks.append(task)
			emit_signal("task_failed", task.id, task.error_message)
			
		i -= 1
	
	# Start new tasks if we have capacity
	while running_tasks.size() < max_concurrent_tasks and not task_queue.empty():
		var next_task_index = _find_next_executable_task()
		
		if next_task_index >= 0:
			var task = task_queue[next_task_index]
			task_queue.remove(next_task_index)
			running_tasks.append(task)
			
			# Execute in thread or directly
			_execute_task(task)
			emit_signal("task_started", task.id)
		else:
			# No tasks can run right now
			break
	
	# Check if all tasks are complete
	if task_queue.empty() and running_tasks.empty():
		emit_signal("all_tasks_completed")

# Find index of next task that can be executed based on dependencies
func _find_next_executable_task() -> int:
	for i in range(task_queue.size()):
		if task_queue[i].can_run(completed_task_ids):
			return i
	return -1

# Execute a task (in thread if supported)
func _execute_task(task: Task) -> void:
	# In Godot 3.x, we don't have easy threading for GDScript functions
	# So we'll execute directly in this example
	task.execute()
	
	# For thread support in real implementation, use:
	# var thread = Thread.new()
	# thread.start(self, "_thread_execute_task", task)

# Thread execution function (for thread support)
func _thread_execute_task(task: Task) -> void:
	task.execute()
	# Note: In a real implementation, you'd need a mutex
	# to protect shared data and signals

# Compare function for sorting by priority
func _compare_task_priority(a: Task, b: Task) -> bool:
	return a.priority > b.priority

# Create a chain of dependent tasks
func create_task_chain(base_id: String, object: Object, function_names: Array, 
					  args_list: Array = [], priority: int = Priority.MEDIUM) -> Array:
	var tasks = []
	var prev_task_id = ""
	
	for i in range(function_names.size()):
		var task_id = base_id + "_" + str(i)
		var args = args_list[i] if i < args_list.size() else []
		
		var task = schedule_task(task_id, object, function_names[i], args, priority)
		if prev_task_id != "":
			task.add_dependency(prev_task_id)
			
		tasks.append(task)
		prev_task_id = task_id
		
	return tasks

# Create parallel tasks to be executed concurrently
func create_parallel_tasks(base_id: String, object: Object, function_names: Array,
						  args_list: Array = [], priority: int = Priority.MEDIUM) -> Array:
	var tasks = []
	
	for i in range(function_names.size()):
		var task_id = base_id + "_parallel_" + str(i)
		var args = args_list[i] if i < args_list.size() else []
		
		var task = schedule_task(task_id, object, function_names[i], args, priority)
		tasks.append(task)
		
	return tasks

# Cancel a specific task if it hasn't started yet
func cancel_task(task_id: String) -> bool:
	for i in range(task_queue.size()):
		if task_queue[i].id == task_id:
			task_queue[i].status = TaskStatus.CANCELED
			task_queue.remove(i)
			return true
	return false

# Set the maximum number of concurrent tasks
func set_max_concurrent_tasks(value: int) -> void:
	max_concurrent_tasks = clamp(value, 1, 10)  # Limit to reasonable range