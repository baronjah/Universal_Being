extends Node
class_name ThreadManager

# Thread Manager for the 12 Turns System
# Handles multi-threaded processing across cores
# Follows snake_case naming convention

# Signal emitted when a task completes
signal task_completed(task_id, result)
# Signal emitted when all tasks in a group complete
signal task_group_completed(group_id)
# Signal emitted when a task fails
signal task_failed(task_id, error)

# Thread pool and management
var worker_threads = []
var thread_count = 0
var available_thread_count = 0
var thread_mutex = Mutex.new()

# Task management
var task_queue = []
var task_results = {}
var task_groups = {}
var queue_mutex = Mutex.new()
var task_semaphore = Semaphore.new()

# Thread status tracking
var thread_status = []
var exit_threads = false

# Statistics and monitoring
var stats = {
	"tasks_processed": 0,
	"tasks_failed": 0,
	"avg_processing_time": 0.0,
	"max_processing_time": 0.0,
	"current_queue_size": 0
}

func _init(thread_count_override = -1):
	# Determine thread count (auto or manual)
	if thread_count_override > 0:
		thread_count = thread_count_override
	else:
		# Use one less than the number of cores (leave one for main thread)
		thread_count = max(1, OS.get_processor_count() - 1)
	
	available_thread_count = thread_count
	
	# Initialize thread status tracking
	thread_status.resize(thread_count)
	for i in range(thread_count):
		thread_status[i] = {
			"status": "initializing",
			"current_task": null,
			"tasks_processed": 0,
			"processing_time": 0.0
		}
	
	print("Thread manager initialized with %d worker threads" % thread_count)

func _ready():
	# Start worker threads
	_start_threads()

func _exit_tree():
	# Clean shutdown of threads
	_stop_threads()

func _start_threads():
	# Create and start worker threads
	exit_threads = false
	worker_threads.resize(thread_count)
	
	for i in range(thread_count):
		worker_threads[i] = Thread.new()
		var result = worker_threads[i].start(Callable(self, "_thread_function").bind(i))
		
		if result != OK:
			push_error("Failed to start worker thread %d" % i)
			thread_status[i].status = "failed"
		else:
			thread_status[i].status = "idle"
			print("Worker thread %d started" % i)

func _stop_threads():
	# Signal all threads to exit
	exit_threads = true
	
	# Wake up all threads to check exit condition
	for i in range(thread_count):
		task_semaphore.post()
	
	# Wait for all threads to finish
	for i in range(worker_threads.size()):
		if worker_threads[i].is_started():
			worker_threads[i].wait_to_finish()
	
	print("All worker threads stopped")

# Main thread function executed by each worker thread
func _thread_function(thread_id):
	print("Worker thread %d running" % thread_id)
	
	while true:
		# Wait for a task or exit signal
		task_semaphore.wait()
		
		# Check if we should exit
		if exit_threads:
			thread_status[thread_id].status = "exiting"
			print("Worker thread %d exiting" % thread_id)
			break
		
		# Try to get a task from the queue
		var task = null
		
		queue_mutex.lock()
		if task_queue.size() > 0:
			task = task_queue.pop_front()
			stats.current_queue_size = task_queue.size()
		queue_mutex.unlock()
		
		# If no task was available, go back to waiting
		if task == null:
			thread_status[thread_id].status = "idle"
			continue
		
		# We have a task, update status
		thread_status[thread_id].status = "processing"
		thread_status[thread_id].current_task = task.id
		
		# Process the task
		var start_time = Time.get_ticks_msec()
		var result = null
		var error = null
		
		thread_mutex.lock()
		available_thread_count -= 1
		thread_mutex.unlock()
		
		# Try to execute the task
		try:
			# Different handling based on parameters
			if task.params != null:
				result = task.callable.call(task.params)
			else:
				result = task.callable.call()
		catch(e):
			error = e
			print("Error in thread %d processing task %s: %s" % [thread_id, task.id, e])
		
		thread_mutex.lock()
		available_thread_count += 1
		thread_mutex.unlock()
		
		# Calculate processing time
		var end_time = Time.get_ticks_msec()
		var processing_time = end_time - start_time
		
		# Update thread statistics
		thread_status[thread_id].tasks_processed += 1
		thread_status[thread_id].processing_time += processing_time
		thread_status[thread_id].current_task = null
		thread_status[thread_id].status = "idle"
		
		# Store the result and notify the main thread
		queue_mutex.lock()
		
		# Update global statistics
		stats.tasks_processed += 1
		stats.avg_processing_time = ((stats.avg_processing_time * (stats.tasks_processed - 1)) + processing_time) / stats.tasks_processed
		stats.max_processing_time = max(stats.max_processing_time, processing_time)
		
		if error != null:
			stats.tasks_failed += 1
			task_results[task.id] = {
				"status": "failed",
				"error": error,
				"processing_time": processing_time
			}
			
			# Schedule signal emission on main thread
			call_deferred("_emit_task_failed", task.id, error)
		else:
			task_results[task.id] = {
				"status": "completed",
				"result": result,
				"processing_time": processing_time
			}
			
			# Schedule signal emission on main thread
			call_deferred("_emit_task_completed", task.id, result)
		
		# Handle task groups
		if task.group_id != null:
			if not task_groups.has(task.group_id):
				task_groups[task.group_id] = {
					"total": 0,
					"completed": 0,
					"failed": 0
				}
			
			task_groups[task.group_id].completed += 1
			
			# Check if group is complete
			if task_groups[task.group_id].completed >= task_groups[task.group_id].total:
				call_deferred("_emit_task_group_completed", task.group_id)
		
		queue_mutex.unlock()

# Add a task to the queue
func add_task(callable, params = null, group_id = null) -> String:
	if not callable is Callable:
		push_error("Invalid callable provided to add_task")
		return ""
	
	var task_id = _generate_task_id()
	
	queue_mutex.lock()
	
	# Add task to queue
	task_queue.append({
		"id": task_id,
		"callable": callable,
		"params": params,
		"group_id": group_id,
		"creation_time": Time.get_ticks_msec()
	})
	
	stats.current_queue_size = task_queue.size()
	
	# Track in group if applicable
	if group_id != null:
		if not task_groups.has(group_id):
			task_groups[group_id] = {
				"total": 0,
				"completed": 0,
				"failed": 0
			}
		task_groups[group_id].total += 1
	
	queue_mutex.unlock()
	
	# Signal a thread that work is available
	task_semaphore.post()
	
	return task_id

# Add multiple tasks from an array of parameters
func add_batch_tasks(callable, param_array, group_id = null) -> Array:
	if not callable is Callable:
		push_error("Invalid callable provided to add_batch_tasks")
		return []
	
	if param_array == null or param_array.size() == 0:
		push_error("Empty parameter array provided to add_batch_tasks")
		return []
	
	var task_ids = []
	var batch_group_id = group_id if group_id != null else _generate_task_id()
	
	queue_mutex.lock()
	
	# Initialize group tracking
	if not task_groups.has(batch_group_id):
		task_groups[batch_group_id] = {
			"total": 0,
			"completed": 0,
			"failed": 0
		}
	
	# Add all tasks to queue
	for params in param_array:
		var task_id = _generate_task_id()
		
		task_queue.append({
			"id": task_id,
			"callable": callable,
			"params": params,
			"group_id": batch_group_id,
			"creation_time": Time.get_ticks_msec()
		})
		
		task_ids.append(task_id)
		task_groups[batch_group_id].total += 1
	
	stats.current_queue_size = task_queue.size()
	
	queue_mutex.unlock()
	
	# Signal threads that work is available (once per task)
	for i in range(param_array.size()):
		task_semaphore.post()
	
	return task_ids

# Check if a task has completed
func is_task_completed(task_id) -> bool:
	queue_mutex.lock()
	var completed = task_results.has(task_id) and task_results[task_id].status == "completed"
	queue_mutex.unlock()
	
	return completed

# Check if a task has failed
func is_task_failed(task_id) -> bool:
	queue_mutex.lock()
	var failed = task_results.has(task_id) and task_results[task_id].status == "failed"
	queue_mutex.unlock()
	
	return failed

# Get task result (blocking)
func get_task_result(task_id):
	# Wait until the task is completed
	while not is_task_completed(task_id) and not is_task_failed(task_id):
		OS.delay_msec(5)
	
	queue_mutex.lock()
	var result = null
	
	if task_results.has(task_id):
		if task_results[task_id].status == "completed":
			result = task_results[task_id].result
		else:
			result = {"error": task_results[task_id].error}
	
	queue_mutex.unlock()
	
	return result

# Get task result (non-blocking)
func try_get_task_result(task_id):
	queue_mutex.lock()
	var result = null
	
	if task_results.has(task_id):
		if task_results[task_id].status == "completed":
			result = task_results[task_id].result
		else:
			result = {"error": task_results[task_id].error}
	
	queue_mutex.unlock()
	
	return result

# Check if all tasks in a group have completed
func is_group_completed(group_id) -> bool:
	queue_mutex.lock()
	
	var completed = false
	if task_groups.has(group_id):
		completed = task_groups[group_id].completed >= task_groups[group_id].total
	
	queue_mutex.unlock()
	
	return completed

# Wait for all tasks in a group to complete
func wait_for_group(group_id) -> void:
	while not is_group_completed(group_id):
		OS.delay_msec(5)

# Clear completed task results to free memory
func clear_completed_tasks() -> void:
	queue_mutex.lock()
	
	var keys_to_remove = []
	for task_id in task_results:
		keys_to_remove.append(task_id)
	
	for key in keys_to_remove:
		task_results.erase(key)
	
	queue_mutex.unlock()

# Clear completed groups to free memory
func clear_completed_groups() -> void:
	queue_mutex.lock()
	
	var keys_to_remove = []
	for group_id in task_groups:
		if task_groups[group_id].completed >= task_groups[group_id].total:
			keys_to_remove.append(group_id)
	
	for key in keys_to_remove:
		task_groups.erase(key)
	
	queue_mutex.unlock()

# Get current statistics
func get_statistics() -> Dictionary:
	queue_mutex.lock()
	var current_stats = stats.duplicate()
	queue_mutex.unlock()
	
	thread_mutex.lock()
	current_stats.thread_count = thread_count
	current_stats.available_threads = available_thread_count
	thread_mutex.unlock()
	
	return current_stats

# Get thread status information
func get_thread_status() -> Array:
	var status_copy = []
	
	for i in range(thread_status.size()):
		status_copy.append(thread_status[i].duplicate())
	
	return status_copy

# Generate a unique task ID
func _generate_task_id() -> String:
	return "%d_%d" % [Time.get_ticks_msec(), randi() % 1000000]

# These functions are called on the main thread via call_deferred
func _emit_task_completed(task_id, result):
	emit_signal("task_completed", task_id, result)

func _emit_task_failed(task_id, error):
	emit_signal("task_failed", task_id, error)

func _emit_task_group_completed(group_id):
	emit_signal("task_group_completed", group_id)

# Example usage functions

# Sample CPU-intensive task: calculate prime numbers up to n
func calculate_primes(n):
	var primes = []
	for i in range(2, n + 1):
		var is_prime = true
		for j in range(2, int(sqrt(i)) + 1):
			if i % j == 0:
				is_prime = false
				break
		if is_prime:
			primes.append(i)
	return primes

# Helper function to print task results
func debug_task_result(task_id, result):
	print("Task %s completed with result: %s" % [task_id, result])

# Helper function to print task errors
func debug_task_error(task_id, error):
	print("Task %s failed with error: %s" % [task_id, error])

# Usage example in _ready():
# var task_id = add_task(Callable(self, "calculate_primes").bind(10000))
# connect("task_completed", Callable(self, "debug_task_result"))
# connect("task_failed", Callable(self, "debug_task_error"))
