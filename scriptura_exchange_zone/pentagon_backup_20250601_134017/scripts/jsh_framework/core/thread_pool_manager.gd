# 🏛️ Thread Pool Manager - Resource management system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Resource management system
# Connection: Part of Pentagon Architecture migration

# thread_pool_manager.gd



extends UniversalBeingBase
# Thread pool configuration
const MAX_THREADS = 8
const TASK_TIMEOUT = 5000 # 5 seconds timeout

# Thread status tracking
var active_threads = {}
var task_queue = []
var task_mutex = Mutex.new()

# Task completion tracking
# TODO: Implement task_completed signal emission in _task_wrapper method
signal task_completed(task_id, result)
signal task_failed(task_id, error)




func _init():
	setup_thread_pool()





func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	# Pentagon setup - override in child classes
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
func setup_thread_pool():
	for i in range(MAX_THREADS):
		active_threads[i] = {
			"thread": null,
			"task": null,
			"start_time": 0,
			"status": "idle"
		}

func add_task(task_data):
	task_mutex.lock()
	task_queue.push_back(task_data)
	task_mutex.unlock()
	process_queue()

func process_queue():
	task_mutex.lock()
	var available_thread = find_available_thread()
	
	if available_thread != -1 and !task_queue.is_empty():
		var task = task_queue.pop_front()
		start_task(available_thread, task)
	task_mutex.unlock()

func find_available_thread():
	for thread_id in active_threads:
		if active_threads[thread_id]["status"] == "idle":
			return thread_id
	return -1

func start_task(thread_id, task):
	var thread = Thread.new()
	active_threads[thread_id]["thread"] = thread
	active_threads[thread_id]["task"] = task
	active_threads[thread_id]["start_time"] = Time.get_ticks_msec()
	active_threads[thread_id]["status"] = "running"
	
	thread.start(Callable(self, "_task_wrapper").bind(thread_id, task))




func cleanup_thread(thread_id):
	if thread_id in active_threads:
		active_threads[thread_id]["thread"] = null
		active_threads[thread_id]["task"] = null
		active_threads[thread_id]["status"] = "idle"
		process_queue()



func check_timeouts():
	var current_time = Time.get_ticks_msec()
	
	for thread_id in active_threads:
		var thread_data = active_threads[thread_id]
		if thread_data["status"] == "running":
			var duration = current_time - thread_data["start_time"]
			if duration > TASK_TIMEOUT:
				handle_timeout(thread_id)

func handle_timeout(thread_id):
	var thread_data = active_threads[thread_id]
	if thread_data["thread"] and thread_data["thread"].is_alive():
		# Attempt graceful shutdown first
		thread_data["thread"].wait_to_finish()
	cleanup_thread(thread_id)
	task_failed.emit(thread_data["task"].id, "Task timeout")
