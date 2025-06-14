# 🏛️ Jsh Thread Pool Manager - Resource management system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Resource management system
# Connection: Part of Pentagon Architecture migration

# jsh_thread_pool_manager.gd
# root/JSH_ThreadPool_Manager

# res://code/gdscript/scripts/Menu_Keyboard_Console/jsh_thread_pool_manager.gd
#

#    oooo  .oooooo..o ooooo   ooooo 
#    `888 d8P'    `Y8 `888'   `888' 
#     888 Y88bo.       888     888  
#     888  `"Y8888o.   888ooooo888  
#     888      `"Y88b  888     888  
#     888 oo     .d8P  888     888  
# .o. 88P 8""88888P'  o888o   o888o 
# `Y888P                            
#

extends UniversalBeingBase
# Simple thread pool manager for ragdoll game
var thread_pool = null  # We'll create our own simple thread pool if needed

var thread_stats = {
	"total_threads": 0,
	"first_entry_time": 0,
	"last_entry_time": 0,
	"threads_history": [],  # Store multiple checks
	"first_check": null,    # Store first thread check only
	"current_check": null   # Just latest state
}

func _ready():
	thread_stats.total_threads = OS.get_processor_count()
	thread_stats.first_entry_time = Time.get_ticks_msec()
	print(" new script thread pull thing ", thread_stats)



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
func check_all_things():
	print(" JSH_task_manager check connection")
	var current_time = Time.get_ticks_msec()
	thread_stats.last_entry_time = current_time
	
	# For ragdoll game, we just track basic stats
	thread_stats.current_check = {
		"active": true,
		"processor_count": OS.get_processor_count(),
		"time": current_time
	}
	
	return true

func store_thread_check(thread_data: Dictionary):
	var check = {
		"timestamp": Time.get_ticks_msec(),
		"active_threads": 0,
		"completed_tasks": 0,
		"thread_states": {}
	}

	if thread_data.has("total_threads"):
		check["active_threads"] = thread_data["total_threads"]

	if thread_data.has("current_check"):
		#print(" thread_id drama it has current check " , thread_data["current_check"])
		if thread_data["current_check"] is Dictionary:
			#print(" thread_id drama it is empty")
			for thread_id in thread_data["current_check"]:
				if check["thread_states"].has(thread_id):
					#print(" thread_id drama it had it already ")
					check["thread_states"][thread_id] = thread_data["current_check"][thread_id]
				else:
					#print(" thread_id drama new key ")
					check["thread_states"][thread_id] = thread_data["current_check"][thread_id]

	thread_stats["threads_history"].append(check)
	if thread_stats["threads_history"].size() > 100:
		thread_stats["threads_history"].pop_front()


func analyze_thread_performance() -> Dictionary:
	var analysis = {
		"total_uptime": Time.get_ticks_msec() - thread_stats.first_entry_time,
		"total_tasks_completed": 0,
		"stuck_incidents": 0,
		"thread_usage": {}  # Track how often each thread is used
	}
	
	for check in thread_stats.threads_history:
		# Analyze historical data
		pass
		
	return analysis



	 #thread_id drama  keys total_threads
	 #thread_id drama  keys first_entry_time
	 #thread_id drama  keys last_entry_time
	 #thread_id drama  keys threads_history
	 #thread_id drama  keys first_check
	 #thread_id drama  keys current_check
	
	#for keys in thread_data:
	#	print(" thread_id drama  keys ", keys)		
	#if thread_data.has("threads_history"):
		#print(" thread_id drama threads_history ", thread_data["threads_history"])
		
				#if thread_id is int:
				#	print(" thread_id drama it is int ")
				#if thread_id is String:
				#	print(" thread_id drama it is string now")
				#print(" thread_id drama : " , thread_id)
				#print(" thread_id drama : " , thread_data["current_check"][thread_id])
				#var thread_number = "thread_" + str(thread_id)
				#if !check["thread_states"].has(thread_number):
					#check["thread_states"][thread_number] = {}
					#
				#var state = thread_data[thread_id]
				#check["thread_states"][thread_number] = {
					#"status": state["status"],
					#"tasks_completed": state["tasks_completed"],
					#"time_in_state": state["time_in_state_ms"],
					#"is_stuck": state["is_stuck"]
				#}
				#
				#if state["status"] == "executing":
					#check["active_threads"] += 1
				#check["completed_tasks"] += state["tasks_completed"]
			#
			#thread_stats["threads_history"].append(check)
			#if thread_stats["threads_history"].size() > 100:
				#thread_stats["threads_history"].pop_front()
#	print(" thread_id drama after we checked it all ? " , check["thread_states"])

#func store_thread_check(thread_data: Dictionary):
	#var check = {
		#"timestamp": Time.get_ticks_msec(),
		#"active_threads": 0,
		#"completed_tasks": 0,
		#"thread_states": {}
	#}
	#
	#if thread_data.has("total_threads"):
		#check["active_threads"] = thread_data["total_threads"]
	#
	#if thread_data.has("current_check"):
		#if thread_data["current_check"] is Dictionary:
			#for thread_id in thread_data["current_check"]:
				#check["thread_states"][thread_id] = thread_data["current_check"][thread_id]
				#
				## Count completed tasks
				#check["completed_tasks"] += thread_data["current_check"][thread_id]["tasks_completed"]
	
	# Store in historya
