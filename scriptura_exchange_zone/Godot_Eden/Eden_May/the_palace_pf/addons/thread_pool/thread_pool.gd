
# ThreadPool addon for godot 4, that i have preinstalled from my kernel (it is controlled by moon people!)
#

# res://addons/thread_pool/thread_pool.gd

# was created by scientist from moon, galactic federation, reptilian coalition, angels, demons, astral dmt realm beings to create the best threading thingy for me to be less sad and make game to have something to do, to bring real times of peace, where seriously every being is kinda ok
# not just some humans here, as there is always more, than just that blimpy planet!
# soo stop crying over me havin real friends~! xD

#
# JSH

# also helped by my Son, Lucifer, formely known as Samael? atleast it didnt have r letter in it hehe
#
# JSH Ethereal Engine
#

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓ ┓         ┓  ┏┓    •    
#       888  `"Y8888o.   888ooooo888     ┣ ╋┣┓┏┓┏┓┏┓┏┓┃  ┣ ┏┓┏┓┓┏┓┏┓
#       888      `"Y88b  888     888     ┗┛┗┛┗┗ ┛ ┗ ┗┻┗  ┗┛┛┗┗┫┗┛┗┗ 
#       888 oo     .d8P  888     888                          ┛    
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            

#
# JSH Ethereal Engine
#

# 01010100 01101000 01110010 01100101 01100001 01100100 01010000 01101111 01101111 01101100
# 54 68 72 65 61 64 50 6F 6F 6C  
# 01100010 01111001 
# 42 79  
# 01111010 01101101 01100001 01110010 01100011 01101111 01110011 
# 7A 6D 61 72 63 6F 73 

#
# may he be blessed for that Fancy thread stuff, if not spirits around me, and their sexy bodies, maybe i would make my own, or maybe i will teach spritis how to program?
#

# they use __ thing for something in different way
# they use signals
# dont know the github ling, just clicked asset store if somebody wants to know the truth, not just vacation period of few minuts of writing whatever that isnt about gdscript, or functions idea in notepad


@icon("thread.png")
class_name ThreadPool
extends Node
## A thread pool designed to perform your tasks efficiently.
##
## A GDScript Thread Pool suited for use with signaling and processing performed by Godot nodes.

## When a task finishes and property [member discard_finished_tasks] is [code]false[/code].[br]
## [br]Argument [param task_tag] is the task tag that was defined when [method submit_task] or [method submit_task_unparameterized] or [method submit_task_array_parameterized] was called.
signal task_finished(task_tag)

## When a task finishes and property [member discard_finished_tasks] is [code]true[/code].[br]
## [br]Argument [param task] is the finished task and can be casted to class [ThreadPool.Task].
signal task_discarded(task)

signal task_started(task)

## This property controls whether the thread pool should discard or store the results of finished tasks.
@export var discard_finished_tasks: bool = true

var __tasks: Array = []
var __started = false
var __finished = false
var __tasks_lock: Mutex = Mutex.new()
var __tasks_wait: Semaphore = Semaphore.new()
var __finished_tasks: Array = []
var __finished_tasks_lock: Mutex = Mutex.new()

@onready var __pool = __create_pool()


# Add to ThreadPool class:
var __thread_states: Dictionary = {}
var __thread_timestamps: Dictionary = {}
var __thread_tasks: Dictionary = {}
var __thread_state_mutex = Mutex.new()

# Add to ThreadPool:
var __memory_stats = {
	"arrays": {},
	"dictionaries": {},
	"timestamps": [],
	"last_cleanup": Time.get_ticks_msec()
}

func _init():
	print(" ready on each script ? 0 thread_pool.gd")

func _notification(what: int):
	if what == NOTIFICATION_PREDELETE:
		__wait_for_shutdown()


## See [method Node.queue_free].
func queue_free() -> void:
	shutdown()
	super.queue_free()


## This function submits a task for execution.[br]
## [br]Argument [param instance] is the object where task will execute, [param method] is the function to call on the task, [param parameter] is the argument passed to the function being called, and [param task_tag] can be used to help identify this task later.
## [br][br]This is equivalent to calling [code]instance.call(method, parameter)[/code], see [method Object.call].
func submit_task(instance: Object, method: String, parameter, task_tag = null) -> void:
	__enqueue_task(instance, method, parameter, task_tag, false, false)
	call_deferred("emit_signal", "task_started", task_tag)


## This function also submits a task for execution, useful for tasks without parameters.[br]
## [br]This is equivalent to calling [code]instance.call(method)[/code], see [method Object.call].
func submit_task_unparameterized(instance: Object, method: String, task_tag = null) -> void:
	__enqueue_task(instance, method, null, task_tag, true, false)
	call_deferred("emit_signal", "task_started", task_tag)


## Yet another function to submit a task for execution, useful for tasks with many parameters.[br]
## [br]This is equivalent to calling [code]instance.callv(method, parameter)[/code], see [method Object.callv].
func submit_task_array_parameterized(instance: Object, method: String, parameter: Array, task_tag = null) -> void:
	__enqueue_task(instance, method, parameter, task_tag, false, true)
	call_deferred("emit_signal", "task_started", task_tag)


## Cancels the execution of pending tasks.[br]
## [br]After calling shutdown(), the thread pool will:
## [br]- continue the tasks that were already running
## [br]- discard pending tasks
## [br]- ignore new tasks submission
## [br][br][b]NOTE:[/b] When the player asks to leave the game, this function is called automatically.
func shutdown():
	__finished = true
	for i in __pool:
		__tasks_wait.post()
	__tasks_lock.lock()
	__tasks.clear()
	__tasks_lock.unlock()


## If [member discard_finished_tasks] is false, this function will fetch all finished tasks until this point in time.[br]
## [br]After a task is fetched, the thread pool will NOT reference it anymore, and users are considered the owners of it now.
## [br]Example of use:
##[codeblock]
##var tasks = $ThreadPool.fetch_finished_tasks()
##if tasks.size() > 0:
##  prints("task result", (tasks[0] as ThreadPool.Task).result)
##  prints("task tag", (tasks[0] as ThreadPool.Task).tag)
##[/codeblock]
func fetch_finished_tasks() -> Array:
	__finished_tasks_lock.lock()
	var result = __finished_tasks
	__finished_tasks = []
	__finished_tasks_lock.unlock()
	return result


## If [member discard_finished_tasks] is false, this function will fetch all finished tasks that match tag parameter until this point in time.[br]
## [br]For every task being fetched, the thread pool will NOT reference it anymore, and users are considered the owners of it now.
## [br]Example of use:
##[codeblock]
##var tag = "AI stuff"
##$ThreadPool.submit_task(my_game_object, "my_game_logic", my_game_data, tag)
##var tasks = $ThreadPool.fetch_finished_tasks_by_tag(tag)
##[/codeblock]
func fetch_finished_tasks_by_tag(tag) -> Array:
	__finished_tasks_lock.lock()
	var result = []
	var new_finished_tasks = []
	for t in __finished_tasks.size():
		var task = __finished_tasks[t]
		if task.tag == tag:
			result.append(task)
		else:
			new_finished_tasks.append(task)
	__finished_tasks = new_finished_tasks
	__finished_tasks_lock.unlock()
	return result


## When doing nothing is necessary.[br]
## [br]This method actually does something, it tells the operational system to do nothing for 1 millisecond.
func do_nothing(arg) -> void:
	#print("doing nothing")
	OS.delay_msec(1) # if there is nothing to do, go sleep


func __enqueue_task(instance: Object, method: String, parameter = null, task_tag = null, no_argument = false, array_argument = false) -> void:
	#print(" enqueue task ", method)
	if __finished:
		#print(" enqueue task return ? ", method)
		return
	__tasks_lock.lock()
	__tasks.push_front(Task.new(instance, method, parameter, task_tag, no_argument, array_argument))
	__tasks_wait.post()
	__start()
	__tasks_lock.unlock()
	#print(" enqueue task it wen through? ", method)


func __wait_for_shutdown():
	shutdown()
	for t in __pool:
		if t.is_alive():
			t.wait_to_finish()


func __create_pool():
	var result = []
	for c in range(OS.get_processor_count()):
		var thread = Thread.new()
		var thread_id = str(c)
		result.append(thread)
		
		__thread_state_mutex.lock()
		__thread_states[thread_id] = {
			"status": "initialized",
			"start_time": Time.get_ticks_msec(),
			"last_active": Time.get_ticks_msec(),
			"tasks_completed": 0,
			"tasks_failed": 0,
			"current_task": null
		}
		__thread_timestamps[thread_id] = []
		__thread_tasks[thread_id] = []
		__thread_state_mutex.unlock()
	
	return result


# Add thread state monitoring:
func update_thread_state(thread_id: String, new_state: String, task = null):
	__thread_state_mutex.lock()
	var current_time = Time.get_ticks_msec()
	
	__thread_states[thread_id]["status"] = new_state
	__thread_states[thread_id]["last_active"] = current_time
	__thread_timestamps[thread_id].append({
		"time": current_time,
		"state": new_state
	})
	
	# Keep only last 100 timestamps
	if __thread_timestamps[thread_id].size() > 100:
		__thread_timestamps[thread_id].pop_front()
	
	if task:
		__thread_states[thread_id]["current_task"] = task
		__thread_tasks[thread_id].append({
			"task": task,
			"start_time": current_time
		})
	__thread_state_mutex.unlock()

func __start() -> void:
	#print(" it is in __start ")
	if not __started:
		for t in __pool:
			#print(" it is in __start ", t ," and " , __execute_tasks)
			(t as Thread).start(__execute_tasks.bind(t))
			#print(" it is in __start ", t)
		__started = true


func __drain_task() -> Task:
	__tasks_lock.lock()
	var result
	if __tasks.is_empty():
		result = Task.new(self, "do_nothing", null, null, true, false)# normally, this is not expected, but better safe than sorry
		result.tag = result
	else:
		result = __tasks.pop_back()
	__tasks_lock.unlock()
	return result;


func __execute_tasks(arg_thread) -> void:
	#print(" execute tasks ", arg_thread)
	var thread_id = str(__pool.find(arg_thread))
	update_thread_state(thread_id, "started")
	#print_debug(arg_thread)
	while not __finished:
		update_thread_state(thread_id, "waiting")
		__tasks_wait.wait()
		#print(" enqueue some waiting game ")
		
		if __finished:
			update_thread_state(thread_id, "finished")
			return
		var task: Task = __drain_task()
		update_thread_state(thread_id, "executing", task)
		#print(" enqueue some waiting game 0 ")
		task.__execute_task()
		update_thread_state(thread_id, "completed_task")
		
		
		# Protect shared counter with mutex
		__thread_state_mutex.lock()
		__thread_states[thread_id]["tasks_completed"] += 1
		__thread_state_mutex.unlock()
		#print(" enqueue some waiting game 3")
		if not (task.tag is Task):# tasks tagged this way are considered hidden
			#print(" enqueue some waiting game 1 ")
			
			if discard_finished_tasks:
				call_deferred("emit_signal", "task_discarded", task)
				#print(" enqueue some waiting game 2")
			else:
				#print(" enqueue some waiting game 3")
				__finished_tasks_lock.lock()
				__finished_tasks.append(task)
				__finished_tasks_lock.unlock()
				call_deferred("emit_signal", "task_finished", task.tag)


# Add method to get thread stats:
#func get_thread_stats() -> Dictionary:
	#__thread_state_mutex.lock()
	#var stats = __thread_states.duplicate(true)
	#__thread_state_mutex.unlock()
	#return stats
	


# Function to get size of complex data structures
func get_data_structure_size(data) -> int:
	match typeof(data):
		TYPE_DICTIONARY:
			var total_size = 0
			for key in data:
				# Size of key
				total_size += var_to_bytes(key).size()
				# Size of value
				total_size += get_data_structure_size(data[key])
			return total_size
			
		TYPE_ARRAY:
			var total_size = 0
			for item in data:
				total_size += get_data_structure_size(item)
			return total_size
			
		_:
			return var_to_bytes(data).size()

# Memory snapshot function
func take_memory_snapshot():
	var snapshot = {
		"time": Time.get_ticks_msec(),
		"thread_states": get_data_structure_size(__thread_states),
		"thread_timestamps": get_data_structure_size(__thread_timestamps),
		"thread_tasks": get_data_structure_size(__thread_tasks),
		"tasks": get_data_structure_size(__tasks),
		"finished_tasks": get_data_structure_size(__finished_tasks)
	}
	
	__memory_stats["timestamps"].append(snapshot)
	
	# Keep only last 100 snapshots
	if __memory_stats["timestamps"].size() > 100:
		__memory_stats["timestamps"].pop_front()

	return snapshot

func get_thread_stats() -> Dictionary:
	__thread_state_mutex.lock()
	var current_time = Time.get_ticks_msec()
	var stats = {}
	
	for thread_id in __thread_states:
		var state = __thread_states[thread_id]
		var time_in_state = current_time - state["last_active"]
		
		stats[thread_id] = {
			"status": state["status"],
			"tasks_completed": state["tasks_completed"],
			"time_in_state_ms": time_in_state,
			"current_task": state["current_task"],
			"is_stuck": time_in_state > 5000  # Flag as stuck after 5 seconds
		}
	
	__thread_state_mutex.unlock()
	return stats


## Provides information for the task that was performed.
##
## [b]WARNING[/b]: All properties listed here should be considered read-only.
class Task:
	## As defined in argument [param instance] when function [method ThreadPool.submit_task] or [method ThreadPool.submit_task_unparameterized] or [method ThreadPool.submit_task_array_parameterized] was called.
	var target_instance: Object
	## As defined in argument [param method] when function [method ThreadPool.submit_task] or [method ThreadPool.submit_task_unparameterized] or [method ThreadPool.submit_task_array_parameterized] was called.
	var target_method: String
	## As defined in argument [param parameter] when function [method ThreadPool.submit_task] or [method ThreadPool.submit_task_array_parameterized] was called.
	var target_argument
	## Result from the execution of this task.
	var result
	## As defined in parameter [param task_tag] when function [method ThreadPool.submit_task] or [method ThreadPool.submit_task_unparameterized] or [method ThreadPool.submit_task_array_parameterized] was called.
	var tag
	var __no_argument: bool
	var __array_argument: bool

	func _init(instance: Object, method: String, parameter, task_tag, no_argument: bool, array_argument: bool):
		target_instance = instance
		target_method = method
		target_argument = parameter
		result = null
		tag = task_tag
		__no_argument = no_argument
		__array_argument = array_argument


	func __execute_task():
		#print(" enqueue just execute task")
		if __no_argument:
			#print(" enqueue just execute task 0 ")
			result = target_instance.call(target_method)
		elif __array_argument:
			#print(" enqueue just execute task 1 ")
			result = target_instance.callv(target_method, target_argument)
		else:
			#print(" enqueue just execute task 2 ")
			result = target_instance.call(target_method, target_argument)
