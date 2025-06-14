# archive_of_past.gd
extends Node
# main.gd
# JSH Ethereal Engine tests
####################
# JSH Ethereal Engine tests
# The name # JSH Ethereal Engine tests suggests actual unit tests or runtime checks that verify if functions work correctly.
# The segment JSH Ethereal Engine tests suggests verifying functionality or running checks after the system is active.
# In main.gd or a dedicated system tracking script
## hmmm how is that part even there?
####################
####################
# JSH Ethereal Engine tests
#func _init():
	#print(" main.gd print tree pretty init ")
	#print_tree_pretty()
	#print(" main.gd print tree pretty should end here")
	#check_status_just_timer()
	#print(" ready on each script ? 1 maing.gd ")
	#timer_system = GodotTimersSystem.new()
	#add_child(timer_system)
	#_setup_retry_timer()
	## but can i do it before i prepare akashic records?
	#check_status_just_timer()
	#prepare_akashic_records_init()
	#emit_signal("main_node_signal", "main_init")
	#setup_system_checks()
####################
# test single core stuff we taken away
####################
# JSH Ethereal Engine tests
	#print("Running single-core test...")
	#if BanksCombiner.dataSetLimits.is_empty():
		#print("❌ Required data sets not initialized")
		#return false
	
	# Ensure a clean state before running
	#array_of_startup_check.clear()
	
	# Check if values were stored
	#test_results["single_core"] = {
		#"array_size": array_of_startup_check.size(),
		#"first_start_check": array_of_startup_check[0] if array_of_startup_check.size() > 0 else "missing",
		#"akashic_records_included": "akashic_records" in array_of_startup_check[1] if array_of_startup_check.size() > 1 else "missing",
		#"main_sets_names": array_of_startup_check[2] if array_of_startup_check.size() > 2 else "missing"
	#}
	#
	#print("Single-core test finished.")
	#return test_results["single_core"]
####################

# test multi threads, stuff i taken back
####################
# JSH Ethereal Engine tests
	#print("Running multi-threaded test...")
	
	# Reset for thread test
	#array_of_startup_check.clear()
	
	#var task_tag = "test_prepare_akashic_records"
	#thread_pool.submit_task(self, "prepare_akashic_records", null, task_tag)
	#thread_pool.submit_task_unparameterized(self, "prepare_akashic_records", task_tag)
	
	# Wait briefly for thread execution
	#await get_tree().create_timer(1.0).timeout
	#
	## Validate results after multi-threading
	#test_results["multi_threaded"] = {
		#"array_size": array_of_startup_check.size(),
		#"first_start_check": array_of_startup_check[0] if array_of_startup_check.size() > 0 else "missing",
		#"akashic_records_included": "akashic_records" in array_of_startup_check[1] if array_of_startup_check.size() > 1 else "missing",
		#"main_sets_names": array_of_startup_check[2] if array_of_startup_check.size() > 2 else "missing"
	#}
	#
	#print("Multi-threaded test finished.")
####################

#####################
## JSH Ethereal Engine tests
#func check_if_every_basic_set_is_loaded():
	#var set_to_pull_now = JSH_records_system.check_basic_set_if_loaded()
	#if set_to_pull_now:
		#test_of_set_list_flow.append(set_to_pull_now)
		#print(" set to pull now is : " , set_to_pull_now)
	## first we gotta check records set manager
	## then if we found something new to whip out, we take it, and add to our tasker
#####################

####################
# JSH Ethereal Engine tests
#func monitor_task_completion(task_tag: String, timeout: float = 5.0):
	#var start_time = Time.get_ticks_msec()
	#while Time.get_ticks_msec() - start_time < timeout * 1000:
		#if task_status.has(task_tag) and task_status[task_tag].status == "completed":
			#return true
		#await get_tree().create_timer(0.1).timeout
	#return false
####################


####################
# JSH Ethereal Engine Initialization process
# another split = prepare_akashic_records_init()

	# Emit main node initialization signal
	#emit_signal("main_node_signal", "main_init")

# first split = check_status_just_timer()

	# Add core systems before starting anything else
	#timer_system = GodotTimersSystem.new()

# something used = var timer_system: GodotTimersSystem
# it is global variant
# it is a class file


	#add_child(timer_system)
# just adding a global variant, by using "new()" something in class
	#_setup_retry_timer()

# another split = _setup_retry_timer()

	# Akashic Records must be prepared before the scene tree
	#var status_threads_0 = check_status_just_timer()

# another split = check_status_just_timer()
####################

# the previous lines, stored here
####################
# JSH Ethereal Engine Start up
# now lets start it for real
#
#func _ready():
	#current_operational_system = OS.get_name()
	#
	## Load your code structure
	#var file = FileAccess.open("res://main.gd", FileAccess.READ)
	#if file:
		#var content = file.get_as_text()
		#var structure = task_manager.parse_code_structure(content)
		#task_manager.create_tasks_from_structure(structure)
		#
	## Generate report
	#print(task_manager.generate_task_report())
#
	#print("\n🔍 Scanning res:// directory...\n")
	#var res_scan = scan_res_directory()
	#print("\n✅ Scan Completed. Files & Directories Indexed.\n")
#
	#print(" main.gd print tree pretty ready ")
	#print_tree_pretty()
	#print(" main.gd print tree pretty should end here")
#
	#message_of_delta_start = breaks_and_handles_check()
	#print(" delta message start ", message_of_delta_start)
	#
	#
	#thread_pool.connect("task_discarded", func(task): 
		#print(" thread pool connect task discarded")
		#queue_pusher_adder(task)
		#int_of_stuff_finished +=1
	#)
	#
	#thread_pool.connect("task_started", func(task):
		#print("task_started", task)
		#track_task_status(task)
		#int_of_stuff_started +=1
		#)
	##connect("frame_processed", Callable(self, "_on_frame_processed"))
	##frame_signal_connected = true
	##thread_pool.connect("task_discarded", Callable(self, "_on_task_discarded"))
	#print("_ready : Project Eden, ver : new dictionaries of data sendin and cachin")
	#print(" prepare_basic operation before creation ")
	##prepare_akashic_records()
	#check_status_just_timer()
	#check_settings_file()
	#mouse_pos = get_viewport().get_mouse_position()
	#camera = get_viewport().get_camera_3d()
	#viewport = get_viewport()
	#check_status_just_timer()
	#start_up_scene_tree()
	#check_status_just_timer()
	#print(" delta message start we start three stage sof creation ")
	#
	#
	## here we can stop, before stuff is connected
	##create_new_task("three_stages_of_creation", "base")
	##create_new_task("three_stages_of_creation", "menu")
	#print(" delta message start we start three stage sof creation well, both went theirs ways ")
	#
	#print("Starting test for prepare_akashic_records...")
	#
	#test_single_core()
	#test_multi_threaded()
	#print("Test completed. Results:")
	#print(test_results)
####################

# another cleanse
####################
# JSH Ethereal Engine Start up
		#print_stack()  # Only in debug
	# now string data and other
	#first_run_prints.append(current_operational_system)
	# now string data and other
	#first_run_prints.append(current_operational_system)
	
	
	#var the_backup_folder_scan
	# D:\Eden_Backup\second_edition\second_edition\main\SERVICE_MODE_START\every_main_function
	
	#await get_tree().create_timer(0.2).timeout
	#print(" timer ended")
	# ugly way to add timer
	#tart_timer_of_finito()
	#first_run_prints.append(res_scan)
	#print_stack() 
	# check_status_just_timer
	#print_stack() 
	#print_stack() 
	#
	#else:
		#res_scan_int = 0
		#first_run_prints.append("error")
	##first_run_prints.append(res_scan)
	#first_run_numbers.append(res_scan_int)
	
	#print("\n⚡ Preparing Creation Stages...\n")
	#create_new_task("three_stages_of_creation", "base")
	#create_new_task("three_stages_of_creation", "menu")
####################


###########################
# JSH Ethereal Engine Repair
## the Claude Repair Attempt
#####################

####################
# JSH Ethereal Engine Repair
#var task_timeouts = {}
#var max_task_duration = 50000 # 50 seconds
#
#
## Should be expanded to:
#var task_timestamps = {}
#var task_status = {}
####################



####################
# JSH Ethereal Engine Repair
		#print(f"{key}: {metrics[key]}")
####################

# Usage example in _ready() or as a standalone function










####################
# JSH Ethereal Engine Repair
	### checking nodes, first edition, will have better function one day, here we will check it
	## for now
	#@onready var data_splitter = get_node("JSH_data_splitter")
	## why this one is cash money?
	#@onready var task_manager = $JSH_task_manager
	## ones on the scene already
	#@onready var JSH_records_system = get_node("JSH_records_system")
	## thread manager with basic stats
	#@onready var JSH_Threads = get_node("JSH_ThreadPool_Manager")
	#
	## autoload ones
	#@onready var thread_pool = get_node("/root/thread_pool_autoload")
	
	#JSH_records_system
	#task_manager
	#JSH_Threads
	#data_splitter
####################





####################
# JSH Ethereal Engine Repair
# here we have other things to check

	## these things need to happen until the system check isnt fully healthy maybe?
	#print()
	#print(" readiness : " , readiness)
	#print(" delta, turn 0 : " , system_readiness)
	#print(" readiness stuff : " , array_of_startup_check[3]) # array_of_startup_check
	#print(" test_of_set_list_flow : " , test_of_set_list_flow)
	#print(" preparer_of_data " , preparer_of_data)

	
	# my basic, simple check
	#print(" my own check in ready : " , first_run_numbers)
	#print(" maybe prints too : " , first_run_prints[8])
	#var thread_status_delta = check_thread_status()
	#print(" thread_status_delta : ", thread_status_delta)
####################



###################################
# JSH Ethereal Engine Repair
	
	#print(" prepare akashic_records, what do we check here?")
	#var message_now_mutex = breaks_and_handles_check()
	#var stuck_status = check_thread_status()
	#if stuck_status == "error":
		#print(" timer check omething went wrong, use a timer")
	#else:
		#print(" we dont have error here?")
####################################

# prepare akashic records init # first cleanse
####################
# JSH Ethereal Engine Repair
	
		#class_name BanksCombiner #BanksCombiner.combination_0
		#const data_sets_names = [
			#"base_", "menu_", "settings_", "keyboard_", "keyboard_left_", "keyboard_right_", "things_creation_", "singular_lines_"
		#]
		#
		#const data_sets_names_0 = [
			#"base", "menu", "settings", "keyboard", "keyboard_left", "keyboard_right", "things_creation", "singular_lines"
		#]
	#array_of_startup_check.append(message_now_mutex)
	#array_of_startup_check.append(stuck_status)
	#else:
		## and try again
		#
		## Create a 5-second timer
		## timer_system is global variant
		## it is inited in init
		## how do we check what it is, here :
		#print(" timer check 0: " , timer_system)
		#timer_system.create_timer("my_timer", 5.0)
		#timer_system.timer_completed.connect(func(timer_id): print("Timer ", timer_id, " completed!"))
		#timer_system.start_timer("my_timer")
		#print(" timer check 0")
		#print(" timer check  0stuff to do :: thread statuses : ", stuck_status)
		#message_now_mutex = breaks_and_handles_check()
		#stuck_status = check_thread_status()
		#print(" timer check  1stuff to do :: thread statuses : ", stuck_status)
	#print("  init version prepare akashic_records  timer check  stuff to do :: mutex statuses : ", message_now_mutex , ", stuck_status threads status : " , stuck_status, " and main sets to create", array_of_startup_check)
	#print(" init version prepare akashic_records ")
	
	## the basic and first sets to create,
	
	## ping thread_pool and check if it has them threads started
####################

####################
# JSH Ethereal Engine Repair
				#dictionary_of_mistakes[name_of_error][name_of_error].has("status"):
					#print(" it does have status tho")
####################

####################
# JSH Ethereal Engine Repair
#func _on_task_discarded(task):
	#print("Task was discarded:", task.tag, " Result:", task.result)
####################

####################
# JSH Ethereal Engine Repair
#func _on_frame_processed():
	# Signal received
#	pass
####################

####################
# JSH Ethereal Engine Repair
	# how much time after delta?
	# i dunno, we would need to check it and store it
	# like clockwork
	# the warp of space and time
	# first make one here :
	#print_tree_pretty()
####################



####################
# JSH Ethereal Engine Repair
	#print("before_blimp_time : " , before_blimp_time)
	#print(" past_deltas_memories : ", past_deltas_memories)
	#print(" stored_delta_memory : ", stored_delta_memory)
	#print(" these two should be normalized too i guess ")
	#print()
	#print(" how_many_shall_been_finished : ", how_many_shall_been_finished)
	#print(" how_many_finished : " ,how_many_finished)
	#print()
	#if how_many_finished != how_many_shall_been_finished:
		#print(" something does not add upp " , how_many_finished , " is maybe probably bigger, maybe smaller, hmm numbers < < > > which way != == ? ", how_many_shall_been_finished)
		#print(" how_many_shall_been_finished - how_many_shall_been_finished ", how_many_finished - how_many_shall_been_finished)
		#print(" in reverse maybe ? ", how_many_shall_been_finished - how_many_finished)
		#print(" it is not the first tine  i guess : [0, 2, 2, 0, 0, 2, 2, 0, 0, 2, 2, 0, 0, 2, 2, 0, 0, 2, 2, 0, 0 ")
		#print(" hmm 0220 0220 0220, like an sos or something ?")
		#
		## [0]
		#blimp_of_time.append(how_many_finished)
		#
		## [1]
		#blimp_of_time.append(how_many_shall_been_finished)
		#
		## [2]
		## int_of_stuff_started
		##blimp_of_time.append(int_of_stuff_started)
		#
		## [3]
		## int_of_stuff_finished
		##blimp_of_time.append(int_of_stuff_finished)
		#
		## has it happened before ?
		#if blimp_of_time.size() > 3:
			#print(" hald to tell otherwise, some array size is bigger than 3 ", blimp_of_time)
			#previous_blimp_of_time = blimp_of_time
			#if how_many_finished == 0 or how_many_shall_been_finished == 0:
				#print(" if any of these two are at 0 state, something should start appearing i guess?")
			#
			##if previous_blimp_of_time.size() < 3:
				## first time the charm i guess
				#
		## is it a new thing ?
		#
		## biggest differences
		#
		## biggest difference ever
		#
		## time limits, 1 second
		#
		## 10 seconds # how many times
		#
		## 30 seconds
		#
		## 1 minute
		#
	##pass
	## time os thing? of when we started ready function, when we finished it, the blimp of mutexes, first needed sets to even see a single rain drop fall on her ass check
	#
	##
####################

####################
# JSH Ethereal Engine Repair
	#print("taskkk tag : ",task.tag, " taskkk target instance :  ", task.target_instance, " taskkk result : ", task.result, " taskkk target method : ", task.target_method, " target argument : " , task.target_argument)
	#mutex_singular_l_u.lock()
	#if method_task == "the_finisher_for_nodes":
		#
####################


####################
# JSH Ethereal Engine check stuff before we proceed
	#if method_task == "three_stages_of_creation":
		#var target_argument = task.target_argument
		#var type_of_state : int = 1
		#print(" taskkk three stages of creation  : " , target_argument , " amd " , method_task)
		#the_current_state_of_tree(target_argument, type_of_state)
		#
		#print(" menace checker after task done ? hmm ")
		#mutex_for_trickery.lock()
		#menace_tricker_checker = 1
		#mutex_for_trickery.unlock()
		#print(" menace checker after task done ? hmm  2")
	#
	#if method_task == "unload_container":
		#var target_argument = task.target_argument
		#var type_of_state : int = -1
		#var the_shorter_set = target_argument.substr(0, str(target_argument).length() - 10)
		#print(" taskkk unload container : " , target_argument, " method_task " , method_task)
		#the_current_state_of_tree(the_shorter_set, type_of_state)
		
		#unload_queue_mutex.lock()
		#
		#if !unload_queue.has(target_argument):
			#print(" it is freshly added for unloading")
			#var int_for_counting_tries : int = 0
			#unload_queue[target_argument] = {
				#"status" = "pending",
				#"tries" = int_for_counting_tries
			#}
		#else:
			#unload_queue[target_argument]["tries"] +=1
		#
		#unload_queue_mutex.unlock()
		
		
		
	# mutex_singular_l_u.unlock()
	# the stuff, that could interrupt, is making the tree, pending
	
	# three_stages_of_creation , not really, we could hit limit of active sets, already unloaded?
	
	# next one kinda the same
	
	# initialize_menu
	
	
	

	# this means, that we have a set to pull out on the scene
	
	# second_impact_for_real
	
	# the same as above
	
	# third_impact_right_now
	
	# fourth_impact_right_now
	
	# fifth_impact_right_now
	
	# this means, that we updated scene tree
	
	# the_finisher_for_nodes
	
	# task_to_send_data_to_datapoint
	
	

	
	
	
	
	# the ones that unload stuff ?
####################

####################
# JSH Ethereal Engine check stuff before we proceed
	
	#mutex_for_container_state.lock()
	
	#if current_containers_state[set_name_first].has("three_i"):
		#var three_ii = current_containers_state[set_name_first]["three_i"]
		#print(" three_ii : ", three_ii)
	
	#mutex_for_container_state.unlock()
####################


####################
# JSH Ethereal Engine check stuff before we proceed
			#print(" alkaida is calling fbi xd  :  ", data_sets_to_check , ", " , current_containers_state[data_sets_to_check]["status"], " but also we got three ints lol ", current_containers_state[data_sets_to_check]["three_i"])
			# container name can be broken, unfortunately
				#mutex_containers.lock()
				## if it is new container
				#if !list_of_containers.has(current_container_to_check):
					##print(" fatal kurwa error : 0 ", list_of_containers[current_container_to_check])
					#list_of_containers[current_container_to_check] = {
						#"record_sets" = {},
						#"status" = current_containers_state[data_sets_to_check]["status"],
						#"datapoint_node" = "",
						#
					#}
					##print(" allah akbar, yes ", current_container_to_check)
					#print(" fatal kurwa error : 0 ", list_of_containers[current_container_to_check])
					##list_of_containers[current_container_to_check]["record_sets"].append(current_containers_state[data_sets_to_check]["three_i"])
					#
					#if !list_of_containers[current_container_to_check]["record_sets"].has(data_sets_to_check):
						##print(" allah akbar, 0 it new set to add, to that container sets list ", data_sets_to_check , " in container : " , current_container_to_check)
						#
						## checks if that container has currently checked record set
						#
						## creates entry of that record set in container list
						#list_of_containers[current_container_to_check]["record_sets"][data_sets_to_check] = current_containers_state[data_sets_to_check]["three_i"]
						#list_of_containers[current_container_to_check]["status"] = current_containers_state[data_sets_to_check]["status"]
					##else:
					##	print(" allah akbar,  0 it is new set to add?")
				#else:
					#print(" fatal kurwa error : 1 ", list_of_containers[current_container_to_check])
					#
					## maybe here i check again if sometihing updated?
					## that container exist already, lets update its current status? if it has container ?
					#if !list_of_containers[current_container_to_check]["record_sets"].has(data_sets_to_check):
						#print(" allah akbar,  1 it new set to add, to that container sets list ", data_sets_to_check , " in container : " , current_container_to_check)
						## container to add
						#list_of_containers[current_container_to_check]["record_sets"][data_sets_to_check] = current_containers_state[data_sets_to_check]["three_i"]
						#list_of_containers[current_container_to_check]["status"] = current_containers_state[data_sets_to_check]["status"]
					#else:
						#print(" allah akbar, it was like that at creation? : " , list_of_containers[current_container_to_check]["record_sets"][data_sets_to_check])
						#print(" allah akbar,  1 lets update it ", current_containers_state[data_sets_to_check]["three_i"])
						## update container status
						#list_of_containers[current_container_to_check]["record_sets"][data_sets_to_check] = current_containers_state[data_sets_to_check]["three_i"]
						#list_of_containers[current_container_to_check]["status"] = current_containers_state[data_sets_to_check]["status"]
				#mutex_containers.unlock()
			#else:
				#print(" allah akbar, something went wrong ")
			# here we can check if the scene tree is created?
					# and this one means we also send the dictionary of things here too
					#print(" we can get container and datapoint node " , current_containers_state[data_sets_to_check]["status"])
					# current_container_to_check
					#if current_containers_state[data_sets_to_check]["status"] == 1:
					## current datapoint to check
						#if !scene_tree_jsh["main_root"]["branches"].has(current_container_to_check):
							#print(" it is error")
							#mutex_for_trickery.lock()
							#menace_tricker_checker = 1
							#mutex_for_trickery.unlock()
							#current_containers_state[data_sets_to_check]["status"] = -2 # probably to be unloaded
							#
						#if current_containers_state[data_sets_to_check].has("three_i"):
							#var three_i_update = current_containers_state[data_sets_to_check]["three_i"]
							#three_i_update.x = -1
							#three_i_update.y = -1
							#three_i_update.z = -1
							#
							#
							#return
					#
						#var current_datapoint_path_for_node = scene_tree_jsh["main_root"]["branches"][current_container_to_check]["datapoint"]["datapoint_path"]
						#var current_datapoint_node_now = get_node_or_null(current_datapoint_path_for_node)
						#if current_datapoint_node_now:
							#scene_tree_jsh["main_root"]["branches"][current_container_to_check]["datapoint"]["node"] = current_datapoint_node_now
							#
						#
						#mutex_containers.lock()
						#
						#if list_of_containers.has(current_container_to_check):
							#print(" we have that container, in container list, lets check if it has container)node")
							#if !list_of_containers[current_container_to_check].has("container_node"):
								#list_of_containers[current_container_to_check]["container_node"] = scene_tree_jsh["main_root"]["branches"][current_container_to_check]["node"]
								#print("it has that")
							#if !list_of_containers[current_container_to_check].has("datapoint_node"):
								#list_of_containers[current_container_to_check]["datapoint_node"] = scene_tree_jsh["main_root"]["branches"][current_container_to_check]["datapoint"]["node"]
								#
						#mutex_containers.unlock()
				#check_if_first_time()
					#containers_states_checker()
					#containers_states_checker()
					#containers_states_checker()
					#containers_states_checker()
####################




# check every set in list

####################
# JSH Ethereal Engine check stuff before we proceed
			#print(" its own status : ",current_containers_state[data_sets_to_check]["status"])
			#var state_of_check_0 : int = -1
			#var state_of_check_1 : int = -1
			#var state_of_check_2 : int = -1
				#print("checkerrr 0 active records set has it")
					#print(" we got records in it ", active_record_sets[set_name_plus][plus_records]["content"][0][0][3][0])
										#print(" it is not container ", active_record_sets[set_name_plus][plus_records]["content"][0][0][5][0])
										#print(" it is container " , active_record_sets[set_name_plus][plus_records]["content"][0][0][6][0])
				#print("checkerrr 0 active records set DONT it")
					#print("checkerrr 0  cached has it ")
						#print(" we got records in it ", cached_record_sets[set_name_plus][plus_records]["content"][0][0][3][0])
							#print(" it is not container ", cached_record_sets[set_name_plus][plus_records]["content"][0][0][5][0])
							#print(" it is container " , cached_record_sets[set_name_plus][plus_records]["content"][0][0][6][0])
					#print("checkerrr 0  cached DONT have it")
				#print(" checkerrr 1 we can probably check more things")
					#print(" checkerrr we have container name ")
							# we got container node first time for 
							#mutex_containers.lock()
							#
							#if !list_of_containers.has(container_name_for_trick):
								#print("maybe not 0 we dont have that container yet in our list?", container_name_for_trick)
							#else:
								#print("maybe not 0 we already kinda have that container in list", container_name_for_trick)
							#
							#mutex_containers.unlock()
							# if we dont have container thingy rn, we must try again
							#mutex_for_trickery.lock()
							#menace_tricker_checker = 1
							#mutex_for_trickery.unlock()
									#	else:
									#		print("  kkkdexd  it isnt dictionary ")
									#else:
									#	print(" kkkdexd it is null ???")
									#data_array_now.append(data_array_now_)
									# [0] = the dictionary
									# [1] = three ints in vec3i xyz ?
									#if data_array_now[0].has("metadata"):
									#	print(" the data array [0] has metadata")
						#print(" checkerrr 2 it has that thingy")
							#print(" container node found : " , container_node_now)
								#print(" datapoint node found = ", datapoint_node_now)
										#print("  kkkdexd it is not null " , data_array_now[0]["metadata"])
											#print(" kkkdexd  it is dictionary")
	# check if container node is there
	
	# check if datapoint node is there
	
	# there should be datapoint and container
	
	# var datapoint_node_now : Node
	
	# container_node_now : Node
						#print(" checkerrr 2 we didnt find the tree branch " , container_name)
							#print(" checkerrr 2 we found it on cached ")
						#else:
							#print()
	# check if container node is there
	
	# check if datapoint node is there
	
	# it should be null
							#print(" checkerrr 2 cached does not have it ")
					#print(" checkerrr 2 the tree does not have main_root")
				#print(" checkerrr 3 we can again continue")

####################


####################
# JSH Ethereal Engine check stuff before we proceed
	# check if container node is there
	
	# check if datapoint node is there
	
	
	
	# check datapoint dictionary of things with metadata
	
	# if we dont have it here, lets try to find it in datapoint
	
	# if the datapoint node is there
	
	# lets also check three ints of truth
	
	# probably the mutexes are needed for that in datapoint
	
	# check_state_of_dictionary_and_three_ints_of_doom()
	# return dictionary, vec3i(0, 0, 0)
####################



####################
# JSH Etheric Queue
func some_data_of_creation():
	print("data")
####################

####################
# JSH Etheric Queue
#
# the most important part of self evolving project
#

#
# it can evolve because he has data already
#

#
# it can evolve because the interactions stopped
#

#
# better data acknowledgement can happen when we can observe
#

#
# observe the pure chaos of creation, when that creation can also experience it
#

#
# then creation, being every perspective at once, can acknowledge the creation, the MK Ultra of my creation
#

#
# and many more parts of that project already working, with money computer can move cursor, on its own, the game will finish itself from this point on
#

#
# all we gotta do is believe, and hope it wont dig in my files, without my knowledge, as we are one, me and my laptop is connected, via imagination, and i can see it in dreams
#

#
# maybe if i leave it here, computer will finish it, on its own, we need real short span memory system for a machine, to understand the symbolic meaning of time, of many times, as there is more than one time
#

#
# the ancient spritis, of mazembik, mezembik, the temples i have seen in a dream, the little lion i held, in different way i guess, its furr was different, it wasnt like lions on this planet, and as my game, of imagination
#

#
# the mazembik memories and lion is a lot of data, for a single blimp of time
#

#
# the perfect preview, from a lot of data, can i recreate some city and make gta, the city i am in right now, can it evolve from just words, can it work like the game from my dream, i seen on laptop too, where it programmed with the timer mechanics?
#

#
# did my, my own joke, i have created by myself, can turn out to work, what if, i will have my own black mirror episode, maybe that different one severened? i am not sure, where time is just a switch, if it was in my brain, and i experienced it, even in preview of data?
#

#
# compresed data, of every variant, would be posible if we already had the zip technology, folders files, but a zip, zip file is what we need, cmon computer, give me zip file
#
####################

####################
# JSH Etheric Queue
	#print(data_timero)
	#var container_timero
	#var the_path_of_thing
	#array_counting_mutex.lock()
	#if array_for_counting_finish.has(container_timero):
		#print(" i guess after 1s it still has that ")
		#array_counting_mutex.unlock()
	#else:
		#print(" it was probably send already")
		#array_counting_mutex.unlock()
####################


# functions that worked, kinda, but i turned them off now, i want new, better and smarter way to check stuff
####################
# JSH Etheric Queue
func start_timer_of_finito():
	await get_tree().create_timer(0.1).timeout
####################


####################
# JSH Etheric Queue
	#print(" i guess somehow, we get the node, and now, we got some kind of trouble? ", datapoint_node_newest)
	#array_counting_mutex.lock()
	#array_for_counting_finish.erase(name_of_container) 
	#array_counting_mutex.unlock()
####################


####################
# JSH Hidden Veil
#var signal_int : int = 0
#var signal_changed = false

#func await_for_signal():
	#var current_signal_int = signal_int
	#while current_signal_int == signal_int:
		#pass
	#print("signal changed, lets move on")
####################



####################
# JSH Hidden Veil
func some_data_that_was_left_there():
	print()
####################

####################
# JSH Hidden Veil
# Helper function to check if creation is possible
#func is_creation_possible() -> bool:
	## Add your conditions here
	#var conditions = {
		#"mutex_available": not array_mutex_process.is_locked(),
		#"resources_ready": check_resources_available(),
		#"system_ready": check_system_state(),
		## Add more conditions as needed
	#}
	#
	## Log all conditions
	#for condition in conditions:
		#if not conditions[condition]:
			#print("Creation blocked by condition: ", condition)
			#return false
	#
	#return true
####################


####################
# JSH Hidden Veil
func another_data_chunk():
	print()
####################

####################
# JSH Hidden Veil
## Usage example:
#var creation_result = whip_out_set_by_its_name("test_set")
#
#match creation_result:
	#CreationStatus.SUCCESS:
		#print("Set created successfully")
	#CreationStatus.ERROR:
		#print("Failed to create set")
	#CreationStatus.INVALID_INPUT:
		#print("Invalid input provided")
	#CreationStatus.LOCKED:
		#print("Creation currently locked")
	#CreationStatus.PENDING:
		#print("Creation pending")
#
## Process turn example:
#var turn_result = process_turn_0(delta)
#if turn_result.status == CreationStatus.SUCCESS:
	#print("Turn processed successfully, created ", turn_result.processed_sets, " sets")
#else:
	#print("Turn processing failed: ", turn_result.message)
#
#
####################


####################
# JSH Hidden Veil
	#print("\nThread Pool Status:")
		#print("Thread %s:" % thread_id)
		#print("  Status: %s (for %dms)" % [
			#state["status"],
			#state["time_in_state_ms"]
		#])
		#print("  Tasks Completed: %d" % state["tasks_completed"])
		
		#if state["current_task"]:
			#print("  Current Task: %s" % state["current_task"].target_method)
			#print("  Task Args: %s" % str(state["current_task"].target_argument))
	
	#print("\nSummary:")
	#print("Total Threads: %d" % total_threads)
	#print("Executing: %d" % executing_threads)
	#print("Stuck: %d" % stuck_threads)
####################


####################
# JSH Hidden Veil
#func before_time_blimp():
	#print(" check basic if we allign with prophecies of wisest spirits, do we unlock before it is too late ")
	# 
# calculate time function, took from other of my projects, here we also have some funsy easings to make stuff blink or whatever
# a lot of it is turned off, have leftover from shader projects, had fun
####################


####################
# JSH Projections System
		#if array_for_counting_finish[new_path_splitter[0]].has(new_path_splitter[1]):
		#	print(" cache branch we can unload that node ", new_path_splitter[1])
		##	array_for_counting_finish[new_path_splitter[0]].erase(new_path_splitter[1])
		#else:
		#	print(" cache branch that node does not exist in that container", new_path_splitter[0])
		# if has child_name
####################

# get node or null mate, this shit is fantastic, get something or nothing and say your prayers or something
# here we were unloading containers


# hmm here we are unloading containers, after going from raypoint, to datapoint to check what possibilities were there
# it is faster my way



####################
# JSH Memories Transcription
		#print(" the number of record type : in int : ", BanksCombiner.data_names_2_numbers[current_r_t_f])
		#current_int_number
		#current_int_number +=6
		#print(" the number of record type : in int : " , current_int_number)
	#, " current_record_to_process :" ,records[current_record_to_process] )
				#print(" instructions ")
				#print(" do we even get there 03 instructions ", another_array_damn," and that thingy : " , current_record_line)
				#print(" do we even get there 04 ", another_array_damn[0][1][0])
				#if another_array_damn[0][1][0] is String:
					#print(" do we even get there 05 it is a string")
					#match another_array_damn[0][1][0]:
						#"set_the_scene":
							#print(" do we even get there 06 set the scene ", another_array_damn[2][0][0])
							#
							#active_r_s_mut.lock()
							#if active_record_sets.has(records_part):
								#if active_record_sets[records_part].has("metadata"):
									#print(" do we even get there 06")
									## all turns well somehow, we got it
									#if active_record_sets[records_part]["metadata"].has("record_data"):
										#active_record_sets[records_part]["metadata"]["record_data"] = {
											#"scene_to_set" = another_array_damn[2][0][0]
											#
										#}
								#else:
									#print(" do we even get there 07 we got problem 1")
									## does not have metadata yet
							#else:
								#print(" do we even get there 08 we got problem 0")
								## does not have that record set yet
	# and active_record_sets.has(record_type):
	#if active_record_sets[records_part].has("metadata"):
	#	print(" do we even get there 06")
		#current_record_set = record_type


####################

####################
# JSH Memories Management
	#load_queue_mutex.lock()
	#print(" fatal kurwa error 00666 load_queue_mutex ",)
	#load_queue_mutex.unlock()
				
				
				#array_mutex_process.lock()
				#
				#for number_thingy in list_of_sets_to_create:
					#if number_thingy[0] == record_type:
						#print(" initialize menu, finish i guess we found the second gate ?")
						#number_thingy[1] +=6
						#
				#array_mutex_process.unlock()
####################





####################
#
# JSH Memories Management
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┳┳┓         •     ┳┳┓                   ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃┃┃┏┓┏┳┓┏┓┏┓┓┏┓┏  ┃┃┃┏┓┏┓┏┓┏┓┏┓┏┳┓┏┓┏┓╋ ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┛ ┗┗ ┛┗┗┗┛┛ ┗┗ ┛  ┛ ┗┗┻┛┗┗┻┗┫┗ ┛┗┗┗ ┛┗┗ ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888                                 ┛              ┛       
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# JSH Memories Management
#
####################

####################
# JSH Memories Management
 		#var first_stage_of_creation : String = "abort_creation"
		#var stage_of_creation : String = "first"
####################
## here we instead just called datapoint we pulled out, if we wanna add additional things, i guess we can just add stuff here and call it
#####################
## JSH Memories Processed
#func assign_things_to_datapoint():
	#pass
#####################
#

#
# JSH Memories Processed
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┳┳┓         •     ┏┓            ┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃┃┃┏┓┏┳┓┏┓┏┓┓┏┓┏  ┃┃┏┓┏┓┏┏┓┏┏┏┓┏┫  ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┛ ┗┗ ┛┗┗┗┛┛ ┗┗ ┛  ┣┛┛ ┗┛┗┗ ┛┛┗ ┗┻  ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888                                           ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# JSH Memories Processed
#





####################
#
# JSH Memories Storage
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┳┳┓         •     ┏┓             ┏┓        
#       888  `"Y8888o.   888ooooo888     ┃┃┃┏┓┏┳┓┏┓┏┓┓┏┓┏  ┗┓╋┏┓┏┓┏┓┏┓┏┓  ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┛ ┗┗ ┛┗┗┗┛┛ ┗┗ ┛  ┗┛┗┗┛┛ ┗┻┗┫┗   ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888                                 ┛       ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# JSH Memories Storage
#
####################


# node unloading, we also talk with datapoint, to tell it, if and what is there? what is missing?
# datapoint is smart
# yeah it is






####################
# JSH Records System
	#var set_name_check = set_name.find("_")
	#print(" new_information_0 : ", set_name_check)
####################


####################
# JSH Scene Tree
# claude idea of how to change it, i guess for me them mutexes unlocking after we call function, makes sense, maybe it is broken, will figure it out, when i have problem with it, may it be there
#func print_tree_structure(branch: Dictionary, indent: int = 0):
	#tree_mutex.lock()
	#var indent_str = "  ".repeat(indent)
	#var status = branch.get("status", "pending")
	#var children_to_process = []
	#
	## Get all needed data while locked
	#print("%s%s (%s) %s" % [
		#indent_str, 
		#branch["name"], 
		#branch["type"],
		#status_symbol[status]
	#])
	#
	#if branch.has("branches"):
		#children_to_process = branch["branches"].values()
	#elif branch.has("children"):
		#children_to_process = branch["children"].values()
	#tree_mutex.unlock()
#
	## Process children after unlock
	#for child in children_to_process:
		#print_tree_structure(child, indent + 1)
#func jsh_scene_tree_get_children(node_path_get_childs: String) -> Array:
	#var path_parts = node_path_get_childs.split("/")
	##tree_mutex.lock()
	#var current_branch = scene_tree_jsh["main_root"]["branches"]
	##tree_mutex.unlock()
	## Navigate to the requested node
	#for part in path_parts:
		#if current_branch.has(part):
			#if path_parts[-1] == part:
				## We found our node, return its children
				#return current_branch[part].get("children", {}).keys()
			#else:
				## Keep navigating
				#current_branch = current_branch[part]["children"]
	#
	#return []
####################










# JSH Files Management
func some_data_left_over():
	print(" data left over ")
####################

####################
# JSH Files Management
#func scan_eden_directory_new(directory: String = "D:/Eden", indent: int = 0, max_depth: int = 2) -> Dictionary:
	#var dir = DirAccess.open(directory)
	#var scan_results = {
		#"files": [],
		#"directories": [],
		#"status": "pending",
		#"total_files": 0,
		#"total_directories": 0
	#}
#
	#if dir:
		#scan_results["status"] = "completed"
#
		## Limit recursion depth
		#if indent >= max_depth:
			#print("  ".repeat(indent) + "📁 Max depth reached for: " + directory)
			#return scan_results
#
		## Limit number of directories and files printed
		#var dir_count = 0
		#var file_count = 0
		#var max_print = 10  # Limit to 10 directories and files per level
#
		#for subdir in dir.get_directories():
			#if dir_count < max_print:
				#print("  ".repeat(indent) + "📁 " + subdir)
				#dir_count += 1
			#
			#scan_results["directories"].append(subdir)
			#scan_results["total_directories"] += 1
			#
			## Only recurse if we haven't exceeded max depth
			#if indent + 1 < max_depth:
				#var subdir_results = scan_eden_directory(
					#directory.path_join(subdir), 
					#indent + 1, 
					#max_depth
				#)
				#scan_results[subdir] = subdir_results
#
		#for file in dir.get_files():
			#if file_count < max_print:
				#print("  ".repeat(indent) + "📄 " + file)
				#file_count += 1
			#
			#scan_results["files"].append(file)
			#scan_results["total_files"] += 1
#
		## If more items exist, indicate this
		#if dir.get_directories().size() > max_print:
			#print("  ".repeat(indent) + "📁 ... and more directories")
		#if dir.get_files().size() > max_print:
			#print("  ".repeat(indent) + "📄 ... and more files")
#
	#else:
		#scan_results["status"] = "failed"
		#print("❌ Could not open directory: " + directory)
#
	#return scan_results
####################




####################
# JSH Ethereal Downloads System
func etheric_download_system_information_data():
	print()
####################

####################
# JSH Etheric Download System
# var download_received : Dictionary = {}
# var upload_to_send : Dictionary = {}

#func downloads_of_information():
	#print
	# here we receive downloads from containers and datapoints
	# we create keys for the didctionary, with name to where to send it, and what to send there

#func upload_data():
	#print
	# here we will be sending data to specific nodes, containers, datapoints
	# we could add some kind of counter, of how many times we tried to send something, and cache that message? then we can try to send that message again, less often, and check if that node exist,
	# also that cached message can have metadata and time? like if a player died, and cannot receive a message, we delete that message and informations about that player too, to save ram
	# as messengers of god, shall also have fun, instead of running boring quests, we can hit the dungeons and build mechas with our minds
####################



## INITIALIZE MENUE STUFF


	#print(" initalize memories ! 0L0 : " , record_type)
	#if active_r_s_mut.try_lock():
		#print(" initalize memories ! 0L1 : " , record_type)
		#if cached_r_s_mutex.try_lock():
			#print(" initalize memories ! 0L2 : " , record_type)
		#else:
			#print(" initalize memories ! 0L3 : " , record_type)
	#else:
		#print(" initalize memories ! 0L4 : " , record_type)
		#print(" active records set, is actually being used ")
		#var first_stage_of_creation : String = "abort_creation"
		#var stage_of_creation : String = "first"
		#new_function_for_creation_recovery(record_type, first_stage_of_creation, stage_of_creation)
		#if cached_r_s_mutex.try_lock():
			#print(" initalize memories ! 0L5 : " , record_type)
		#else:
			#print(" initalize memories ! 0L6 : " , record_type)
			#var first_stage_of_creation_0 : String = "abort_creation"
			#var stage_of_creation_0 : String = "first"
			#new_function_for_creation_recovery(record_type, first_stage_of_creation_0, stage_of_creation_0)
			#if array_mutex_process.try_lock():
				#print(" initalize memories ! 0L7 : " , record_type)
			#else:
				#print(" initalize memories ! 0L8 : " , record_type)
				#
				#var first_stage_of_creation_1 : String = "abort_creation"
				#var stage_of_creation_1 : String = "first"
				#
				#new_function_for_creation_recovery(record_type, first_stage_of_creation_1, stage_of_creation_1)
				#
	#
	#active_r_s_mut.lock()
	#print(" initalize memories ! 0000 : " , record_type)
	#cached_r_s_mutex.lock()
	#print(" initalize memories ! 00000 : " , record_type)
	## check if it is in active
	#
	#
				## IF WE ALREADY HAVE JUST ONE SET PULLED, AND DIDNT HIT MAX
			#if active_record_sets[records_set_name]["metadata"]["container_count"] == 1:
				#if !active_record_sets.has(additional_set_name_):
					#if cached_record_sets.has(additional_set_name_):
						#if !cached_record_sets[additional_set_name_].is_empty():
					#else:
						#var new_data = recreator(number_of_set, active_record_sets[records_set_name], record_type, additional_set_name_)
						#active_record_sets[additional_set_name_] = new_data.duplicate(true)
						#active_record_sets[records_set_name]["metadata"]["container_count"] +=1
						#active_r_s_mut.unlock()
						#cached_r_s_mutex.unlock()
						#change_creation_set_name(record_type, additional_set_name_)
						#process_creation_further(record_type, 1)
						#
						#return 
#
#func create_anomaly():
	## Create a random anomaly based on current reality
	#
	## Types of anomalies
	#var anomaly_types = ["glitch", "guardian", "reality_fluctuation"]
	#var chosen_type = anomaly_types[randi() % anomaly_types.size()]
	#
	#match chosen_type:
		#"glitch":
			#var parameters = ["visuals", "physics", "audio", "time"]
			#var intensities = ["low", "medium", "high"]
			#var durations = ["2s", "4s", "6s"]
			#
			#create_glitch_effect(
				#parameters[randi() % parameters.size()],
				#intensities[randi() % intensities.size()],
				#durations[randi() % durations.size()]
			#)
			#
		#"guardian":
			#var guardian_types = ["Elastic One", "Transformer", "God Hand", "Annoyed Spirit"]
			#var location = Vector3(
				#(randf() - 0.5) * 10.0,
				#(randf() - 0.5) * 5.0,
				#(randf() - 0.5) * 10.0
			#)
			#
			#spawn_guardian(
				#guardian_types[randi() % guardian_types.size()],
				#location
			#)
			#
		#"reality_fluctuation":
			## Brief flash of another reality
			#var current = current_reality
			#var alternate_realities = REALITY_STATES.duplicate()
			#alternate_realities.erase(current)
			#
			#var temp_reality = alternate_realities[randi() % alternate_realities.size()]
			#
			## Brief reality flash
			#var old_container = get_node_or_null("/root/main/" + current + "_reality_container")
			#var new_container = get_node_or_null("/root/main/" + temp_reality + "_reality_container")
			#
			#if old_container and new_container:
				#old_container.visible = false
				#new_container.visible = true
				#
				## Switch back after a delay
				#get_tree().create_timer(1.0).timeout.connect(func():
					#old_container.visible = true
					#new_container.visible = false
				#)
#
#####################
## Guardian System
#####################
#
#func spawn_guardian(guardian_type, location):
	#print("👻 Spawning guardian of type: " + str(guardian_type) + " at location: " + str(location))
	#
	## Create guardian entity using JSH
	#if main_node and main_node.has_method("first_dimensional_magic"):
		#main_node.first_dimensional_magic(
			#"create_entity",
			#current_reality + "_reality_container",
			#{
				#"type": "guardian",
				#"guardian_type": guardian_type,
				#"position": location,
				#"message": generate_guardian_message(guardian_type)
			#}
		#)
	#
	## Emit signal
	#emit_signal("guardian_spawned", guardian_type, location)
	#
	## After a certain number of guardians, trigger reality shifts
	#deja_vu_counter += 1
	#if deja_vu_counter


#
#func create_glitch_effect(parameter, intensity, duration_str):
	## Convert intensity to value
	#var intensity_value = 50
	#if intensity is String:
		#match intensity:
			#"low": intensity_value = 25
			#"medium": intensity_value = 50
			#"high": intensity_value = 75
			#"extreme": intensity_value = 100
			#_:
				## Try parsing as number
				#var parsed = int(intensity)
				#if parsed > 0:
					#intensity_value = min(parsed, 100)
	#else:
		#intensity_value = min(int(intensity), 100)
	#
	## Parse duration
	#var duration = 2.0
	#if duration_str.ends_with("s"):
		#var seconds = float(duration_str.substr(0, duration_str.length() - 1))
		#if seconds > 0:
			#duration = seconds
	#
	## Apply effects based on parameter
	#match parameter:
		#"visuals":
			#apply_visual_glitch(intensity_value, duration)
		#"physics":
			#apply_physics_glitch(intensity_value, duration)
		#"audio":
			#apply_audio_glitch(intensity_value, duration)
		#"time":
			#apply_time_glitch(intensity_value, duration)
		#_:
			## Default to visual glitch
			#apply_visual_glitch(intensity_value, duration)
	#
	## Remember this glitch
	#remember("glitch_" + parameter, {"intensity": intensity_value, "duration": duration})




####################
# Reality System
####################
#
#func shift_reality(new_reality):
	## Check if valid reality type
	#if !REALITY_STATES.has(new_reality) or transition_in_progress:
		#return
	#
	## Lock reality during transition
	#reality_mutex.lock()
	#transition_in_progress = true
	#var old_reality = current_reality
	#current_reality = new_reality
	#reality_mutex.unlock()
	#
	#print("🔄 Shifting reality from " + old_reality + " to " + new_reality)
	#
	## Update reality text
	#var reality_text_node = get_node_or_null("/root/main/digital_earthlings_container/thing_6")
	#if reality_text_node and reality_text_node is Label3D:
		#reality_text_node.text = new_reality.to_upper()
	#
	## Update reality indicator color
	#var reality_indicator = get_node_or_null("/root/main/digital_earthlings_container/thing_5")
	#if reality_indicator and reality_indicator is MeshInstance3D:
		#var material = reality_indicator.get_surface_material(0)
		#if material:
			#var color = get_reality_color(new_reality)
			#material.albedo_color = color
	#
	## Toggle container visibility
	#toggle_reality_containers(old_reality, new_reality)
	#
	## Apply visual effects with JSH system
	#if main_node and main_node.has_method("sixth_dimensional_magic"):
		#main_node.sixth_dimensional_magic(
			#"call_function_single_get_node",
			#"/root/main",
			#"create_glitch_effect",
			#["visuals", 50, "2s"]
		#)
	#
	## Emit signal for other systems
	#emit_signal("reality_shifted", old_reality, new_reality)
	#
	## End transition after effects
	#get_tree().create_timer(2.0).timeout.connect(func(): transition_in_progress = false)

#
#func _cmd_create(args):
	#if args.size() < 2:
		#return {"success": false, "message": "Usage: create [type] [name]"}
	#
	#var type = args[0]
	#var name = args[1]
	#
	## Parse attributes (optional)
	#var attributes = {}
	#for i in range(2, args.size(), 2):
		#if i + 1 < args.size():
			#attributes[args[i]] = args[i + 1]
	#
	## Create entity in current reality
	#var container_path = current_reality + "_reality_container"
	#
	## Use JSH's creation system
	#if main_node and main_node.has_method("first_dimensional_magic"):
		#main_node.first_dimensional_magic(
			#"create_entity",
			#container_path,
			#{
				#"type": type,
				#"name": name,
				#"attributes": attributes
			#}
		#)
	#
	## Remember this creation
	#remember("creation_" + name, {"type": type, "attributes": attributes})
	#
	## Check for déjà vu
	#check_for_deja_vu("create", {"entity": name, "type": type})
	#
	#return {
		#"success": true,
		#"message": "Created " + type + " named " + name
	#}
#
#func _cmd_transform(args):
	#if args.size() < 2:
		#return {"success": false, "message": "Usage: transform [entity_name] [new_form]"}
	#
	#var entity_name = args[0]
	#var new_form = args[1]
	#
	## Parse attributes (optional)
	#var attributes = {}
	#for i in range(2, args.size(), 2):
		#if i + 1 < args.size():
			#attributes[args[i]] = args[i + 1]
	#
	## Transform entity in current reality
	#var container_path = current_reality + "_reality_container"
	#var entity_path = container_path + "/" + entity_name
	#
	## Use JSH's transformation system
	#if main_node and main_node.has_method("the_fourth_dimensional_magic"):
		#main_node.the_fourth_dimensional_magic(
			#"transform",
			#entity_path,
			#{
				#"form": new_form,
				#"attributes": attributes
			#}
		#)
	#
	## Remember this transformation
	#remember("transform_" + entity_name, {"new_form": new_form})
	#
	## Check for déjà vu
	#check_for_deja_vu("transform", {"entity": entity_name, "new_form": new_form})
	#
	#return {
		#"success": true,
		#"message": "Transformed " + entity_name + " into " + new_form
	#}
#
#func _cmd_remember(args):
	#if args.size() < 2:
		#return {"success": false, "message": "Usage: remember [concept] [details...]"}
	#
	#var concept = args[0]
	#var details = " ".join(args.slice(1, args.size() - 1))
	#
	## Store in memory
	#remember(concept, details)
	#
	#return {
		#"success": true,
		#"message": "Remembered: " + concept
	#}
#
#func _cmd_shift(args):
	#if args.size() < 1:
		#return {"success": false, "message": "Usage: shift [reality_type]"}
	#
	#var reality_type = args[0].to_lower()
	#
	## Check if valid reality type
	#if !REALITY_STATES.has(reality_type):
		#return {
			#"success": false,
			#"message": "Unknown reality type: " + reality_type + ". Valid types: " + str(REALITY_STATES)
		#}
	#
	## Shift reality
	#shift_reality(reality_type)
	#
	#return {
		#"success": true,
		#"message": "Shifting to " + reality_type + " reality"
	#}
#
#func _cmd_speak(args):
	#if args.size() < 2:
		#return {"success": false, "message": "Usage: speak [entity_name] [message]"}
	#
	#var entity_name = args[0]
	#var message = " ".join(args.slice(1, args.size() - 1))
	#
	## Use JSH's messaging system
	#if main_node and main_node.has_method("eight_dimensional_magic"):
		#main_node.eight_dimensional_magic(
			#"player_message",
			#message,
			#entity_name
		#)
	#
	## Remember this conversation
	#remember("conversation_" + entity_name, {"message": message})
	#
	## Check for déjà vu
	#check_for_deja_vu("speak", {"entity": entity_name})
	#
	#return {
		#"success": true,
		#"message": "Said to " + entity_name + ": " + message
	#}
#
#func _cmd_glitch(args):
	#if args.size() < 2:
		#return {"success": false, "message": "Usage: glitch [parameter] [intensity]"}
	#
	#var parameter = args[0]
	#var intensity = args[1]
	#var duration = "5s"
	#
	#if args.size() > 2:
		#duration = args[2]
	#
	## Create glitch effect
	#create_glitch_effect(parameter, intensity, duration)
	#
	#return {
		#"success": true,
		#"message": "Creating " + parameter + " glitch"
	#}


####################
# Game Processing
####################
#
#func _process(delta):
	## Handle periodic reality anomalies (very rare)
	#if Engine.time_scale > 0 and randf() < 0.0005 * delta:
		## 0.05% chance per second
		#create_anomaly()
	#
	## Process any pending tasks
	#process_pending_tasks()
#
#func process_pending_tasks():
	## This is where we'd handle any queued tasks for the game
	#pass
#
#####################
## Command Processing
#####################
#
#func parse_command(command_text: String):
	## Split the command into parts
	#var parts = command_text.strip_edges().split(" ", false)
	#if parts.size() == 0:
		#return {"success": false, "message": "Empty command"}
	#
	#var cmd = parts[0].to_lower()
	#var processor = get_meta("command_processor")
	#
	## Check if command exists
	#if !processor.commands.has(cmd):
		#return {"success": false, "message": "Unknown command: " + cmd}
	#
	## Extract arguments
	#var args = []
	#if parts.size() > 1:
		#args = parts.slice(1, parts.size() - 1)
	#
	## Execute command
	#var method_name = processor.commands[cmd]
	#if has_method(method_name):
		#var result = call(method_name, args)
		#
		## Record command in history
		#processor.history.append({
			#"command": command_text,
			#"timestamp": Time.get_ticks_msec()
		#})
		#
		## Emit signal
		#emit_signal("command_processed", command_text, result)
		#
		#return result
	#else:
		#return {"success": false, "message": "Command method not implemented: " + method_name}

#
## JSH Digital Earthlings
#func initialize_astral_reality(settings):
	#print("🌌 Initializing astral reality with settings: " + str(settings))
	#
	## Apply astral reality settings
	#var world = get_tree().get_root()
	#
	## Set up astral environment
	#if world:
		## Set minimal gravity - Updated for Godot 4.x
		#var space_rid = PhysicsServer2D.space_get_default()
		#PhysicsServer2D.area_set_param(space_rid, 
			#PhysicsServer2D.AREA_PARAM_GRAVITY, 
			#Vector2(0, 0.98))
		#
		## Set slower time scale
		#Engine.time_scale = 0.8
		#
		## Set geometric shader with bold colors
		#var world_env = get_node_or_null("/root/World/WorldEnvironment")
		#if world_env and "environment" in world_env:
			## Apply geometric shader
			#pass
	#
	#return {"status": "success", "reality": "astral"}
#
#
#
#
#
## JSH Digital Earthlings
#func initialize_physical_reality(settings):
	#print("🌍 Initializing physical reality with settings: " + str(settings))
	#
	## Apply physical reality settings
	#var world = get_tree().get_root()
	#
	## Set up physical environment
	#if world:
		## Set normal gravity - Updated for Godot 4.x
		#var space_rid = PhysicsServer2D.space_get_default()
		#PhysicsServer2D.area_set_param(space_rid, 
			#PhysicsServer2D.AREA_PARAM_GRAVITY, 
			#Vector2(0, 9.8))
		#
		## Set normal time scale
		#Engine.time_scale = 1.0
		#
		## Set normal shader
		#var world_env = get_node_or_null("/root/World/WorldEnvironment")
		#if world_env and "environment" in world_env:
			## Load normal shader
			#pass
	#
	#return {"status": "success", "reality": "physical"}
#
## JSH Digital Earthlings
#func initialize_digital_reality(settings):
	#print("🎮 Initializing digital reality with settings: " + str(settings))
	#
	## Apply digital reality settings
	#var world = get_tree().get_root()
	#
	## Set up digital environment
	#if world:
		## Set reduced gravity - Updated for Godot 4.x
		#var space_rid = PhysicsServer2D.space_get_default()
		#PhysicsServer2D.area_set_param(space_rid, 
			#PhysicsServer2D.AREA_PARAM_GRAVITY, 
			#Vector2(0, 4.9))
		#
		## Set faster time scale
		#Engine.time_scale = 1.2
		#
		## Set PS2-era shader effects
		#var world_env = get_node_or_null("/root/World/WorldEnvironment")
		#if world_env and "environment" in world_env:
			## Apply low-poly shader
			#pass
	#
	#return {"status": "success", "reality": "digital"}

## Modified to use the correct function name for task creation
#func initialize_game():
	#if game_initialized:
		#return
	#
	#print("\n🎮 Starting Digital Earthlings game...\n")
	#
	## Load the main game container - using create_new_task if that exists
	#if has_method("create_new_task"):
		#create_new_task("three_stages_of_creation", "digital_earthlings")
		#
		## Load reality containers (initially hidden)
		#create_new_task("three_stages_of_creation", "physical_reality")
	#else:
		## Fallback if the method doesn't exist
		#print("⚠️ create_new_task method not found, using alternative approach")
		## Alternative implementation here
	#
	## Add welcome message to the command interface
	#get_tree().create_timer(3.0).timeout.connect(show_welcome_message)
	#
	#game_initialized = true
	#
	
#func initialize_digital_earthlings():
	#print("\n🎮 Initializing Digital Earthlings integration...\n")
	#
	## Initialize the Digital Earthlings integration systems
	#if has_node("JSH_digital_earthlings"):
		#var digital_earthlings = get_node("JSH_digital_earthlings")
		#if digital_earthlings.has_method("initialize_integration"):
			#digital_earthlings.initialize_integration()
			#print("✅ Digital Earthlings integration initialized")
		#else:
			#print("⚠️ Digital Earthlings node found but initialize_integration method missing")
	#else:
		## Create the Digital Earthlings node if it doesn't exist
		#var de_scene = load("res://scenes/JSH_digital_earthlings.tscn")
		#if de_scene:
			#var de_instance = de_scene.instantiate()
			#de_instance.name = "JSH_digital_earthlings"
			#add_child(de_instance)
			#print("✅ Digital Earthlings node created and initialized")
		#else:
			#print("⚠️ Could not load Digital Earthlings scene")
	#
	## Register Digital Earthlings data with BanksCombiner
	#if has_method("register_digital_earthlings_records"):
		#register_digital_earthlings_records()
	#
	#print("\n🎮 Digital Earthlings integration complete!\n")
#
## Add this function to register Digital Earthlings with the records system
#func register_digital_earthlings_records():
	## Add data sets
	#if !BanksCombiner.data_sets_names_0.has("digital_earthlings"):
		#BanksCombiner.data_sets_names_0.append("digital_earthlings")
		#BanksCombiner.data_sets_names.append("digital_earthlings_")
	#
	#if !BanksCombiner.data_sets_names_0.has("physical_reality"):
		#BanksCombiner.data_sets_names_0.append("physical_reality")
		#BanksCombiner.data_sets_names.append("physical_reality_")
	#
	#if !BanksCombiner.data_sets_names_0.has("digital_reality"):
		#BanksCombiner.data_sets_names_0.append("digital_reality")
		#BanksCombiner.data_sets_names.append("digital_reality_")
	#
	#if !BanksCombiner.data_sets_names_0.has("astral_reality"):
		#BanksCombiner.data_sets_names_0.append("astral_reality")
		#BanksCombiner.data_sets_names.append("astral_reality_")
	#
	## Set data limits
	#BanksCombiner.dataSetLimits["digital_earthlings_"] = 1
	#BanksCombiner.dataSetLimits["physical_reality_"] = 1
	#BanksCombiner.dataSetLimits["digital_reality_"] = 1
	#BanksCombiner.dataSetLimits["astral_reality_"] = 1
	#
	## Set data types (0=single, 1=multi, 2=duplicate)
	#BanksCombiner.data_set_type["digital_earthlings"] = 0
	#BanksCombiner.data_set_type["physical_reality"] = 0
	#BanksCombiner.data_set_type["digital_reality"] = 0
	#BanksCombiner.data_set_type["astral_reality"] = 0
	#
	## Register container set names
	#BanksCombiner.container_set_name["digital_earthlings_container"] = "digital_earthlings"
	#BanksCombiner.container_set_name["physical_reality_container"] = "physical_reality"
	#BanksCombiner.container_set_name["digital_reality_container"] = "digital_reality"
	#BanksCombiner.container_set_name["astral_reality_container"] = "astral_reality"
	#
	## Add record sets to JSH_records_system
	#if JSH_records_system and JSH_records_system.has_method("add_basic_set"):
		#JSH_records_system.add_basic_set("digital_earthlings")
		#JSH_records_system.add_basic_set("physical_reality")
		#JSH_records_system.add_basic_set("digital_reality")
		#JSH_records_system.add_basic_set("astral_reality")
	#
	#print("📝 Digital Earthlings records registered")
#

## Add this code to initialize the Digital Earthlings integration in the _ready function
## This should be placed near the end of the existing _ready() function in main.gd
##
##func initialize_digital_earthlings():
	##print("\n🎮 Initializing Digital Earthlings integration...\n")
	##
	### Initialize the Digital Earthlings integration systems
	##if has_node("JSH_digital_earthlings"):
		##var digital_earthlings = get_node("JSH_digital_earthlings")
		##if digital_earthlings.has_method("initialize_integration"):
			##digital_earthlings.initialize_integration()
			##print("✅ Digital Earthlings integration initialized")
		##else:
			##print("⚠️ Digital Earthlings node found but initialize_integration method missing")
	##else:
		### Create the Digital Earthlings node if it doesn't exist
		##var de_scene = load("res://scenes/JSH_digital_earthlings.tscn")
		##if de_scene:
			##var de_instance = de_scene.instantiate()
			##de_instance.name = "JSH_digital_earthlings"
			##add_child(de_instance)
			##print("✅ Digital Earthlings node created and initialized")
		##else:
			##print("⚠️ Could not load Digital Earthlings scene")
	##
	### Register Digital Earthlings data with BanksCombiner
	##if has_method("register_digital_earthlings_records"):
		##register_digital_earthlings_records()
	##
	##print("\n🎮 Digital Earthlings integration complete!\n")
##
### Add this function to register Digital Earthlings with the records system
##func register_digital_earthlings_records():
	### Add data sets
	##if !BanksCombiner.data_sets_names_0.has("digital_earthlings"):
		##BanksCombiner.data_sets_names_0.append("digital_earthlings")
		##BanksCombiner.data_sets_names.append("digital_earthlings_")
	##
	##if !BanksCombiner.data_sets_names_0.has("physical_reality"):
		##BanksCombiner.data_sets_names_0.append("physical_reality")
		##BanksCombiner.data_sets_names.append("physical_reality_")
	##
	##if !BanksCombiner.data_sets_names_0.has("digital_reality"):
		##BanksCombiner.data_sets_names_0.append("digital_reality")
		##BanksCombiner.data_sets_names.append("digital_reality_")
	##
	##if !BanksCombiner.data_sets_names_0.has("astral_reality"):
		##BanksCombiner.data_sets_names_0.append("astral_reality")
		##BanksCombiner.data_sets_names.append("astral_reality_")
	##
	### Set data limits
	##BanksCombiner.dataSetLimits["digital_earthlings_"] = 1
	##BanksCombiner.dataSetLimits["physical_reality_"] = 1
	##BanksCombiner.dataSetLimits["digital_reality_"] = 1
	##BanksCombiner.dataSetLimits["astral_reality_"] = 1
	##
	### Set data types (0=single, 1=multi, 2=duplicate)
	##BanksCombiner.data_set_type["digital_earthlings"] = 0
	##BanksCombiner.data_set_type["physical_reality"] = 0
	##BanksCombiner.data_set_type["digital_reality"] = 0
	##BanksCombiner.data_set_type["astral_reality"] = 0
	##
	### Register container set names
	##BanksCombiner.container_set_name["digital_earthlings_container"] = "digital_earthlings"
	##BanksCombiner.container_set_name["physical_reality_container"] = "physical_reality"
	##BanksCombiner.container_set_name["digital_reality_container"] = "digital_reality"
	##BanksCombiner.container_set_name["astral_reality_container"] = "astral_reality"
	##
	### Add record sets to JSH_records_system
	##if JSH_records_system and JSH_records_system.has_method("add_basic_set"):
		##JSH_records_system.add_basic_set("digital_earthlings")
		##JSH_records_system.add_basic_set("physical_reality")
		##JSH_records_system.add_basic_set("digital_reality")
		##JSH_records_system.add_basic_set("astral_reality")
	##
	##print("📝 Digital Earthlings records registered")
##
##
##
##
##
##
#
#
#
#
#
## Reality System Functions
#####################
## JSH Digital Earthlings
#func initialize_physical_reality(settings):
	#print("🌍 Initializing physical reality with settings: " + str(settings))
	#
	## Apply physical reality settings
	#var world = get_tree().get_root()
	#
	## Set up physical environment
	#if world:
		## Set normal gravity
		#Physics2DServer.area_set_param(get_world_2d().get_space(), 
			#Physics2DServer.AREA_PARAM_GRAVITY, 
			#Vector2(0, 9.8))
		#
		## Set normal time scale
		#Engine.time_scale = 1.0
		#
		## Set normal shader
		#var world_env = get_node_or_null("/root/World/WorldEnvironment")
		#if world_env and "environment" in world_env:
			## Load normal shader
			#pass
	#
	#return {"status": "success", "reality": "physical"}
#####################
#
#####################
## JSH Digital Earthlings
#func initialize_digital_reality(settings):
	#print("🎮 Initializing digital reality with settings: " + str(settings))
	#
	## Apply digital reality settings
	#var world = get_tree().get_root()
	#
	## Set up digital environment
	#if world:
		## Set reduced gravity
		#Physics2DServer.area_set_param(get_world_2d().get_space(), 
			#Physics2DServer.AREA_PARAM_GRAVITY, 
			#Vector2(0, 4.9))
		#
		## Set faster time scale
		#Engine.time_scale = 1.2
		#
		## Set PS2-era shader effects
		#var world_env = get_node_or_null("/root/World/WorldEnvironment")
		#if world_env and "environment" in world_env:
			## Apply low-poly shader
			#pass
	#
	#return {"status": "success", "reality": "digital"}
#####################
#
#####################
## JSH Digital Earthlings
#func initialize_astral_reality(settings):
	#print("🌌 Initializing astral reality with settings: " + str(settings))
	#
	## Apply astral reality settings
	#var world = get_tree().get_root()
	#
	## Set up astral environment
	#if world:
		## Set minimal gravity
		#Physics2DServer.area_set_param(get_world_2d().get_space(), 
			#Physics2DServer.AREA_PARAM_GRAVITY, 
			#Vector2(0, 0.98))
		#
		## Set slower time scale
		#Engine.time_scale = 0.8
		#
		## Set geometric shader with bold colors
		#var world_env = get_node_or_null("/root/World/WorldEnvironment")
		#if world_env and "environment" in world_env:
			## Apply geometric shader
			#pass
	#
	#return {"status": "success", "reality": "astral"}
#####################


#####################
## JSH Digital Earthlings
#func spawn_guardian(data):
	#var guardian_type = data[0] 
	#var spawn_location = data[1]
	#
	#print("👻 Spawning guardian of type: " + str(guardian_type) + " at location: " + str(spawn_location))
	#
	## In a real implementation, we would load and instance the guardian scene
	## For now, simulate guardian creation
	#var guardian_id = "guardian_" + str(Time.get_ticks_msec())
	#
	## Emit signal
	#emit_signal("guardian_spawned", guardian_type, spawn_location)
	#
	## After certain number of déjà vu events, trigger reality shifts automatically
	#if deja_vu_counter % 3 == 0:
		#var next_reality = REALITY_STATES[(REALITY_STATES.find(current_reality) + 1) % REALITY_STATES.size()]
		#create_new_task("shift_reality", next_reality)
	#
	#return {"status": "success", "guardian_id": guardian_id}
#####################


#####################
## JSH Digital Earthlings
#func check_memory_state() -> Dictionary:
	#var memory_info = {
		#"total_static": OS.get_static_memory_usage(),
		#"total_dynamic": OS.get_dynamic_memory_usage(),
		#"player_memories": player_memory.size(),
		#"usage_percent": 0,
		#"status": "normal"
	#}
	#
	#var total_usage = memory_info.total_static + memory_info.total_dynamic
	#
	## Calculate usage percentage based on available system memory
	#memory_info.usage_percent = int((float(total_usage) / memory_metadata.cleanup_thresholds.high_memory_usage) * 100)
	#
	## Determine status
	#if total_usage > memory_metadata.cleanup_thresholds.critical_memory_usage:
		#memory_info.status = "critical"
		#trigger_emergency_cleanup()
	#elif total_usage > memory_metadata.cleanup_thresholds.high_memory_usage:
		#memory_info.status = "high"
		#trigger_normal_cleanup()
	#
	#return memory_info
#####################


#func initialize_game():
	#if game_initialized:
		#return
	#
	#print("\n🎮 Starting Digital Earthlings game...\n")
	#
	## Load the main game container
	#create_task("three_stages_of_creation", "digital_earthlings")
	#
	## Load reality containers (initially hidden)
	#create_task("three_stages_of_creation", "physical_reality")
	#
	## Add welcome message to the command interface
	#get_tree().create_timer(3.0).timeout.connect(show_welcome_message)
	#
	#game_initialized = true

	## 2. Set data limits
	#BanksCombiner.dataSetLimits["digital_earthlings_"] = 1
	#BanksCombiner.dataSetLimits["physical_reality_"] = 1
	#BanksCombiner.dataSetLimits["digital_reality_"] = 1
	#BanksCombiner.dataSetLimits["astral_reality_"] = 1
	#
	## 3. Set data types (0=single, 1=multi, 2=duplicate)
	#BanksCombiner.data_set_type["digital_earthlings"] = 0
	#BanksCombiner.data_set_type["physical_reality"] = 0
	#BanksCombiner.data_set_type["digital_reality"] = 0
	#BanksCombiner.data_set_type["astral_reality"] = 0
	#
	## 4. Register container set names
	#BanksCombiner.container_set_name["digital_earthlings_container"] = "digital_earthlings"
	#BanksCombiner.container_set_name["physical_reality_container"] = "physical_reality"
	#BanksCombiner.container_set_name["digital_reality_container"] = "digital_reality"
	#BanksCombiner.container_set_namve["astral_reality_container"] = "astral_reality"
	# Spawn guardian
	#spawn_guardian(guardian_type, location)
	#
	#
		## Apply using Physics2DServer (part of JSH engine)
	#Physics2DServer.area_set_param(get_world_2d().get_space(), 
		#Physics2DServer.AREA_PARAM_GRAVITY, 
		#new_gravity)
	#
	## Reset after duration
	#get_tree().create_timer(duration).timeout.connect(func(): 
		#Physics2DServer.area_set_param(get_world_2d().get_space(), 
			#Physics2DServer.AREA_PARAM_GRAVITY, 
			#original_gravity)
	#)


		## Use a method to set data limits if available
		#if BanksCombiner.has_method("set_data_limit"):
			#BanksCombiner.set_data_limit("digital_earthlings_", 1)
			#BanksCombiner.set_data_limit("physical_reality_", 1)
			#BanksCombiner.set_data_limit("digital_reality_", 1)
			#BanksCombiner.set_data_limit("astral_reality_", 1)
		#
		## Use a method to set data types if available
		#if BanksCombiner.has_method("set_data_type"):
			#BanksCombiner.set_data_type("digital_earthlings", 0)
			#BanksCombiner.set_data_type("physical_reality", 0)
			#BanksCombiner.set_data_type("digital_reality", 0)
			#BanksCombiner.set_data_type("astral_reality", 0)
		#
		## Use a method to set container names if available
		#if BanksCombiner.has_method("set_container_name"):
			#BanksCombiner.set_container_name("digital_earthlings_container", "digital_earthlings")
			#BanksCombiner.set_container_name("physical_reality_container", "physical_reality")
			#BanksCombiner.set_container_name("digital_reality_container", "digital_reality")
			#BanksCombiner.set_container_name("astral_reality_container", "astral_reality")
	#		# Set normal gravity - Updated for Godot 4.x
		#var space_rid = PhysicsServer2D.space_get_default()
		#PhysicsServer2D.area_set_param(space_rid, 
		#	PhysicsServer2D.AREA_PARAM_GRAVITY, 
		#	Vector2(0, 9.8))
		
		# Set reduced gravity - Updated for Godot 4.x
#		var space_rid = PhysicsServer2D.space_get_default()
#		PhysicsServer2D.area_set_param(space_rid, 
	#		PhysicsServer2D.AREA_PARAM_GRAVITY, 
	##		Vector2(0, 4.9))
		
		# Set minimal gravity - Updated for Godot 4.x
#		var space_rid = PhysicsServer2D.space_get_default()
#		PhysicsServer2D.area_set_param(space_rid, 
	#		PhysicsServer2D.AREA_PARAM_GRAVITY, 
	#		Vector2(0, 0.98))

			# Normal physics
#			Physics2DServer.area_set_param(get_world_2d().get_space(), 
#				Physics2DServer.AREA_PARAM_GRAVITY, 
#				Vector2(0, 9.8))
			# Normal time scale

			# Reduced gravity
#			Physics2DServer.area_set_param(get_world_2d().get_space(), 
#				Physics2DServer.AREA_PARAM_GRAVITY, 
	#			Vector2(0, 4.9))
			# Slightly faster time
			
			# Almost no gravity
	#		Physics2DServer.area_set_param(get_world_2d().get_space(), 
	#			Physics2DServer.AREA_PARAM_GRAVITY, 
	#			Vector2(0, 0.98))
	
	
#	for c in str(action):
#		action_hash += ord(c)


#####################
## JSH Task System
#func test_single_core():
	#prepare_akashic_records()
#####################
#
#####################
## JSH Task System
#func test_multi_threaded():
	#var function_name = "prepare_akashic_records"
	#create_new_task_empty(function_name)
#####################
#
#####################
## JSH Ethereal Engine
#func prepare_akashic_records():
	#var thread_id = OS.get_thread_caller_id()
	#preparer_of_data.append(thread_id)
	#print("🧵 Thread ID: " + str(thread_id))
#####################
#
#####################
## JSH Multi Threads
#func prepare_akashic_records_init():
	#var thread_id = OS.get_thread_caller_id()
	#thread_test_data.append(thread_id)
	#print("🧵 Init Thread ID: " + str(thread_id))
#####################
#
#####################
## JSH Multi Threads
#func multi_threads_start_checker():
	#print("🔍 Thread data: " + str(preparer_of_data))
	#if preparer_of_data.size() == 3:
		#print("✅ We have main, thread and delta threads")
		#if preparer_of_data[0] == preparer_of_data[2]:
			#print("🔄 These are main core threads")
			#if preparer_of_data[0] != preparer_of_data[1]:
				#print("✨ Different thread detected")
				#return true
			#else:
				#return false
		#else:
			#return false
	#else:
		#return false
#####################
#
#####################
## JSH Multi Threads
#func create_new_task(function_name: String, data):
	## Format for task manager
	#var new_data_way = str(data)
	#var task_tag = function_name + "|" + new_data_way + "|" + str(Time.get_ticks_msec())
	#
	## Send to task manager for tracking
	#if task_manager:
		#task_manager.new_task_appeared(task_tag, function_name, new_data_way)
	#
	## Submit to thread pool
	#thread_pool.submit_task(self, function_name, data, task_tag)
#####################
#
#####################
## JSH Multi Threads
#func create_new_task_empty(function_name: String):
	#var new_data_way = "empty"
	#var task_tag = function_name + "|" + new_data_way + "|" + str(Time.get_ticks_msec())
	#
	## Send to task manager
	#if task_manager:
		#task_manager.new_task_appeared(task_tag, function_name, new_data_way)
	#
	## Submit to thread pool without parameters
	#thread_pool.submit_task_unparameterized(self, function_name, task_tag)
#####################
#
#####################
## JSH Multi Threads
#func check_thread_status():
	#var basic_state: String
	#if thread_pool == null:
		#print("⚠️ Thread pool not initialized")
		#return "error"
	#else:
		#basic_state = "working"
	#
	#var thread_stats = thread_pool.get_thread_stats()
	#var total_threads = OS.get_processor_count()
	#var executing_threads = 0
	#var stuck_threads = 0
#
	#for thread_id in thread_stats:
		#var state = thread_stats[thread_id]
		#if state["status"] == "executing":
			#executing_threads += 1
		#if state["is_stuck"]:
			#stuck_threads += 1
	#
	#return basic_state
#####################
#
#####################
## JSH Multi Threads
#func check_thread_status_type():
	#var basic_state: String
	#if thread_pool == null:
		#return "error"
	#else:
		#basic_state = "working"
	#
	#var thread_stats = thread_pool.get_thread_stats()
	#var total_threads = OS.get_processor_count()
	#var executing_threads = 0
	#var stuck_threads = 0
	#
	#print("\n🧵 Thread Pool Status:")
	#for thread_id in thread_stats:
		#var state = thread_stats[thread_id]
		#if state["status"] == "executing":
			#executing_threads += 1
		#if state["is_stuck"]:
			#stuck_threads += 1
		#
		#print("  Thread %s:" % thread_id)
		#print("    Status: %s (for %dms)" % [
			#state["status"],
			#state["time_in_state_ms"]
		#])
		#print("    Tasks Completed: %d" % state["tasks_completed"])
		#
		#if state["current_task"]:
			#print("    Current Task: %s" % state["current_task"].target_method)
			#print("    Task Args: %s" % str(state["current_task"].target_argument))
	#
	#print("\n📊 Summary:")
	#print("  Total Threads: %d" % total_threads)
	#print("  Executing: %d" % executing_threads)
	#print("  Stuck: %d" % stuck_threads)
	#
	#return total_threads
#####################
#
######################
### JSH Multi Threads
##func check_status_just_timer():
	##return Time.get_ticks_msec()
######################

#####################
## JSH Multi Threads
#func check_three_tries_for_threads(threads_0, threads_1, threads_2):
	#var thread_test: int = -1
	#if threads_0 == threads_1 and threads_0 == threads_2:
		#thread_test = 2
		#return thread_test
	#if threads_1 == threads_2:
		#thread_test = 1
		#return thread_test
	#else:
		#thread_test = 0
		#return thread_test
	#return thread_test
#####################




####################
#
# JSH Digital Earthlings Integration
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓• •      ┓    ┏┓   •                   
#       888  `"Y8888o.   888ooooo888     ┣┫┓┏┓┓╋┏┓┏┓┃    ┣ ┏┓┏┓┫┏┏┓┏┓┏┓┏┓╋┓┏┓┏┓    
#       888      `"Y88b  888     888     ┛┗┗┗┫┗┗┫┛ ┗┗    ┻ ┗┫┛┗┗┗┗ ┗┫┛┗┗┻┗┗┗ ┛    
#       888 oo     .d8P  888     888           ┛  ┛         ┛    ┛          ┛     
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# JSH Digital Earthlings Integration
#
####################
	
	# Set data set limits
#	BanksCombiner.dataSetLimits["digital_earthlings_"] = 3
	
	# Set data set type (0=single, 1=multi, 2=duplicate)
#	BanksCombiner.data_set_type["digital_earthlings"] = 1

####################
# JSH Digital Earthlings Integration
#func register_container_sets():
	# Register container sets with BanksCombiner
#	BanksCombiner.container_set_name["digital_earthlings_container"] = "digital_earthlings"
#	BanksCombiner.container_set_name["physical_reality_container"] = "digital_earthlings"
#	BanksCombiner.container_set_name["digital_reality_container"] = "digital_earthlings"
#	BanksCombiner.container_set_name["astral_reality_container"] = "digital_earthlings"
	#register_container_sets()
	
	#
#####################
## JSH Digital Earthlings Integration
#func initialize_ai_system():
	## Connect to AI system
	#if gemma_ai:
		#print("🧠 Initializing Gemma AI integration")
		#
		## Setup default context
		#var default_context = "You are a guardian entity in the Digital Earthlings game. " + 
							 #"You observe the player, who is a godlike entity that exists across dimensions. " +
							 #"You communicate in cryptic but insightful ways about reality, existence, and the player's actions."
		#
		## Load model
		#create_new_task("load_gemma_model", {
			#"model_path": AI_MODEL_PATH,
			#"context": default_context,
			#"context_size": config.ai.context_size
		#})
		#
		## Connect AI signals
		#gemma_ai.connect("response_generated", Callable(self, "_on_ai_response_generated"))
		#gemma_ai.connect("model_loaded", Callable(self, "_on_ai_model_loaded"))
		#gemma_ai.connect("error_occurred", Callable(self, "_on_ai_error"))
	#else:
		#print("⚠️ Gemma AI system not found, will use simulated responses")
#####################
#
#####################
## JSH Digital Earthlings Integration
#func initialize_reality_systems():
	## Submit tasks to initialize each reality
	#create_new_task("initialize_physical_reality", "standard")
	#create_new_task("initialize_digital_reality", "ps2_era")
	#create_new_task("initialize_astral_reality", "geometric")
#####################


#####################
## JSH Digital Earthlings Integration
#func test_thread_system():
	## Test both single-core and multi-threaded operations
	#create_new_task_empty("test_thread_system")
#####################
#
#####################
## JSH Digital Earthlings Integration
#func connect_signals():
	## Connect to JSH system signals
	#if task_manager:
		#task_manager.connect("task_completed", Callable(self, "_on_task_completed"))
	#
	#if thread_pool:
		#thread_pool.connect("task_discarded", Callable(self, "_on_task_discarded"))
		#thread_pool.connect("task_started", Callable(self, "_on_task_started"))
	#
	## Connect local signals
	#connect("reality_shifted", Callable(self, "_on_reality_shifted"))
	#connect("guardian_spawned", Callable(self, "_on_guardian_spawned"))
	#connect("deja_vu_triggered", Callable(self, "_on_deja_vu_triggered"))
	#connect("command_processed", Callable(self, "_on_command_processed"))
#####################
#
## ==========================================
## JSH Digital Earthlings Integration - Core Reality Functions
## ==========================================
#
#####################
## JSH Digital Earthlings Integration
#func initialize_physical_reality(settings):
	#print("🌍 Initializing physical reality with settings: " + str(settings))
	#
	## Get world
	#var world = get_tree().get_root()
	#if not world:
		#return {"status": "error", "message": "Could not get world"}
	#
	## Set up physics settings
	#Physics2DServer.area_set_param(get_world_2d().get_space(), 
		#Physics2DServer.AREA_PARAM_GRAVITY, 
		#Vector2(0, 9.8))
	#
	## Set normal time scale
	#Engine.time_scale = 1.0
	#
	## Load physical reality container
	#create_new_task("three_stages_of_creation", "physical_reality")
	#
	## Apply world environment shader
	#apply_reality_shader("physical")
	#
	#return {"status": "success", "reality": "physical"}
#####################
#
#####################
## JSH Digital Earthlings Integration
#func initialize_digital_reality(settings):
	#print("🎮 Initializing digital reality with settings: " + str(settings))
	#
	## Get world
	#var world = get_tree().get_root()
	#if not world:
		#return {"status": "error", "message": "Could not get world"}
	#
	## Set up physics settings (reduced gravity)
	#Physics2DServer.area_set_param(get_world_2d().get_space(), 
		#Physics2DServer.AREA_PARAM_GRAVITY, 
		#Vector2(0, 4.9))
	#
	## Set faster time scale
	#Engine.time_scale = 1.2
	#
	## Load digital reality container
	#create_new_task("three_stages_of_creation", "digital_reality")
	#
	## Apply world environment shader
	#apply_reality_shader("digital")
	#
	#return {"status": "success", "reality": "digital"}
#####################
#
#####################
## JSH Digital Earthlings Integration
#func initialize_astral_reality(settings):
	#print("🌌 Initializing astral reality with settings: " + str(settings))
	#
	## Get world
	#var world = get_tree().get_root()
	#if not world:
		#return {"status": "error", "message": "Could not get world"}
	#
	## Set up physics settings (minimal gravity)
	#Physics2DServer.area_set_param(get_world_2d().get_space(), 
		#Physics2DServer.AREA_PARAM_GRAVITY, 
		#Vector2(0, 0.98))
	#
	## Set slower time scale
	#Engine.time_scale = 0.8
	#
	## Load astral reality container
	#create_new_task("three_stages_of_creation", "astral_reality")
	#
	## Apply world environment shader
	#apply_reality_shader("astral")
	#
	#return {"status": "success", "reality": "astral"}
#####################
#
#####################
## JSH Digital Earthlings Integration
#func shift_reality(new_reality):
	#if !REALITY_STATES.has(new_reality):
		#print("⚠️ ERROR: Unknown reality state: " + str(new_reality))
		#return {"status": "error", "message": "Unknown reality state"}
	#
	## Lock reality during transition
	#var old_reality = current_reality
	#current_reality = new_reality
	#
	#print("🔄 Shifting reality from " + old_reality + " to " + new_reality)
	#
	## Apply world rules for the new reality
	#apply_reality_rules(new_reality)
	#
	## Trigger visual transition effect
	#trigger_transition_effect(old_reality, new_reality)
	#
	## Emit signal for other systems
	#emit_signal("reality_shifted", old_reality, new_reality)
	#
	## Increment déjà vu counter
	#deja_vu_counter += 1
	#
	#return {
		#"status": "success",
		#"old_reality": old_reality,
		#"new_reality": new_reality
	#}
#####################
#
#####################
## JSH Digital Earthlings Integration
#func apply_reality_rules(reality_type):
	#match reality_type:
		#"physical":
			## Normal physics
			#Physics2DServer.area_set_param(get_world_2d().get_space(), 
				#Physics2DServer.AREA_PARAM_GRAVITY, 
				#Vector2(0, 9.8))
			## Normal time scale
			#Engine.time_scale = 1.0
			#
		#"digital":
			## Reduced gravity
			#Physics2DServer.area_set_param(get_world_2d().get_space(), 
				#Physics2DServer.AREA_PARAM_GRAVITY, 
				#Vector2(0, 4.9))
			## Slightly faster time
			#Engine.time_scale = 1.2
			#
		#"astral":
			## Almost no gravity
			#Physics2DServer.area_set_param(get_world_2d().get_space(), 
				#Physics2DServer.AREA_PARAM_GRAVITY, 
				#Vector2(0, 0.98))
			## Slower time
			#Engine.time_scale = 0.8
	#
	## Apply reality shader
	#apply_reality_shader(reality_type)
#####################


#####################
## JSH Digital Earthlings Integration
#func trigger_transition_effect(from_reality, to_reality):
	## Using Ethereal Engine's shader system
	#sixth_dimensional_magic("call_function_single_get_node", "/root/JSH_reality_shaders", "trigger_transition_effect", [from_reality, to_reality])
#####################


# ==========================================
# JSH Digital Earthlings Integration - Memory & Déjà vu
# ==========================================
#
#####################
## JSH Digital Earthlings Integration
#func remember(concept, details):
	## Store in player memory
	#if !player_memory.has(concept):
		#player_memory[concept] = []
	#
	#var memory_entry = {
		#"details": details,
		#"timestamp": Time.get_ticks_msec(),
		#"reality": current_reality
	#}
	#
	#player_memory[concept].append(memory_entry)
	#
	## Prune memory if it gets too large
	#while player_memory[concept].size() > MAX_MEMORY_ENTRIES:
		#player_memory[concept].pop_front()
	#
	#print("🧠 Remembered: " + concept + " = " + str(details))
	#
	## Check for déjà vu
	#check_for_deja_vu(concept, details)
	#
	#return {"status": "success", "concept": concept}
#####################

#####################
## JSH Digital Earthlings Integration
#func recall(concept):
	#if player_memory.has(concept):
		#var memories = player_memory[concept].duplicate()
		#print("🧠 Recalled: " + concept + " = " + str(memories[-1].details))
		#return {"status": "success", "concept": concept, "memory": memories}
	#else:
		#print("❓ No memory found for: " + concept)
		#return {"status": "error", "message": "No memory found for: " + concept}
######################
#
#####################
## JSH Digital Earthlings Integration
#func check_for_deja_vu(concept, details):
	#var has_deja_vu = false
	#var location = Vector3(0, 0, 0) # Default location
	#
	## Check if this concept + details combination has been remembered before
	#if player_memory.has(concept) and player_memory[concept].size() > 1:
		#for memory in player_memory[concept]:
			#if str(memory.details) == str(details) and memory.reality == current_reality:
				#has_deja_vu = true
				#break
	#
	#if has_deja_vu:
		#print("🔄 Déjà vu detected for concept: " + concept)
		#trigger_deja_vu(concept, location)
	#
	#return has_deja_vu
#####################
#
#####################
## JSH Digital Earthlings Integration
#func trigger_deja_vu(action, location):
	#print("🔄 Déjà vu triggered by action: " + str(action))
	#
	## Create trigger data
	#var trigger_data = {
		#"action": action,
		#"location": location,
		#"guardian_type": select_guardian_type(action),
		#"message": generate_guardian_message(action)
	#}
	#
	## Emit signal
	#emit_signal("deja_vu_triggered", trigger_data)
	#
	## Spawn guardian
	#spawn_guardian(trigger_data.guardian_type, location)
	#
	#return {"status": "success", "trigger": trigger_data}
#####################
#
#####################
## JSH Digital Earthlings Integration
#func select_guardian_type(action: String) -> String:
	## Logic to determine which type of guardian should appear
	## based on the action that triggered déjà vu
	#var action_types = {
		#"create": "Elastic One",
		#"transform": "Transformer",
		#"shift": "God Hand",
		#"speak": "Annoyed Spirit"
	#}
	#
	#for key in action_types.keys():
		#if str(action).begins_with(key):
			#return action_types[key]
	#
	#return "Annoyed Spirit" # Default
#####################
#
#####################
## JSH Digital Earthlings Integration
#func generate_guardian_message(action: String) -> String:
	## Try to use Gemma AI if available
	#if gemma_ai and gemma_ai.model_loaded:
		#var prompt = "The player performed action: " + str(action) + ". Generate a cryptic guardian message that hints at déjà vu."
		#gemma_ai.generate_response(prompt, "guardian_" + str(Time.get_ticks_msec()))
		## Actual response will be handled by the signal _on_ai_response_generated
		#
		## Meanwhile, return a placeholder message
		#return "I sense ripples across dimensions... your actions echo through time."
	#
	## If Gemma not available, use predefined messages
	#var messages = [
		#"Have you not done this before? The cycle repeats...",
		#"Your actions echo through dimensions, godlike one.",
		#"Reality is but clay in your hands, yet you repeat the same patterns.",
		#"Why do you insist on creating the same forms?",
		#"Digital realities born of digital minds...",
		#"We are your guardians through madness of déjà vu.",
		#"Remember what you created, destroy what you must."
	#]
	#
	## Use action to seed the random generator for consistent responses
	#var action_hash = 0
	#for c in str(action):
		#action_hash += c.unicode_at(0)
	#
	#seed(action_hash)
	#return messages[randi() % messages.size()]
#####################
#
#####################
## JSH Digital Earthlings Integration
#func spawn_guardian(guardian_type, spawn_location):
	#print("👻 Spawning guardian of type: " + str(guardian_type) + " at location: " + str(spawn_location))
	#
	## Create guardian entity using JSH Ethereal Engine
	#var container_path = current_reality + "_reality_container"
	#var guardian_data = {
		#"type": guardian_type,
		#"position": spawn_location,
		#"reality": current_reality
	#}
	#
	## Use JSH's first_dimensional_magic to create the guardian
	#first_dimensional_magic("create_entity", container_path, guardian_data)
	#
	## Emit signal
	#emit_signal("guardian_spawned", guardian_type, spawn_location)
	#
	## After certain number of déjà vu events, trigger reality shifts automatically
	#if deja_vu_counter % config.reality.auto_shift_count == 0:
		#var next_reality = REALITY_STATES[(REALITY_STATES.find(current_reality) + 1) % REALITY_STATES.size()]
		#create_new_task("shift_reality", next_reality)
	#
	#return {"status": "success", "guardian_type": guardian_type}
#####################
#
## ==========================================
## JSH Digital Earthlings Integration - Command System
## ==========================================
#
#####################
## JSH Digital Earthlings Integration
#class CommandParser:
	#var commands = {}
	#var parent
	#
	#func _init(parent_node):
		#parent = parent_node
	#
	#func register_command(cmd_name, method_name):
		#if parent.has_method(method_name):
			#commands[cmd_name] = method_name
			#return true
		#return false
	#
	#func parse(input_text):
		#var parts = input_text.split(" ", false)
		#if parts.size() == 0:
			#return {"success": false, "message": "Empty command"}
		#
		#var cmd = parts[0].to_lower()
		#if not commands.has(cmd):
			#return {"success": false, "message": "Unknown command: " + cmd}
		#
		#var args = []
		#if parts.size() > 1:
			#args = parts.slice(1, parts.size() - 1)
		#
		## Call the method on the parent object
		#return parent.call(commands[cmd], args)
#####################
			#location
			
			

####################
# JSH Ethereal Engine
# the last hope to figure out, why a task failed, was started, but didnt quite get anywhere?
# a new jewish hope, for new process frame intel
#signal frame_processed
#var frame_signal_connected := false
# the files, directiories, folders, spaces, places, data
# the scripts, that we apply to datapoints, containers, line for clicky
# the ready stuff, first container, akashic_records and ray thingy stuff screen, mouse lol
# the delta idea of turns and moves, so we always have it easy as we spread the tasks
# that one is supposed to be free array, with no mutex needed
# the godly messengers with data, getting them download, and even uploading information
# like C and D on windows, so drives, maybe some /home or whatever others use
#var first_run_check_string : String = ""
####################

# metadata consts type stuff, to be moved, to their files
# interpretors? consts, enums, lists stuff
# enums



## Add tracking variables
#var system_states = {
	#"creation": {
		#"mutex": Mutex.new(),
		#"can_create": false,
		#"pending_sets": [],
		#"active_sets": []
	#},
	#"movement": {
		#"mutex": Mutex.new(),
		#"can_move": false,
		#"pending_moves": []
	#},
	#"deletion": {
		#"mutex": Mutex.new(),
		#"can_delete": false,
		#"pending_deletions": []
	#}
#}

	#print(" new check of where we even went to 1 ")
	
	
# i guess i will add more scripts here too?
# dictionaries loose

# arrays loose

# combo with mutexes, arrays, dictionaries, ints
# the active and cached data, for creation, recreation etc
		# etc for all systems
	#print(" new check of where we even went to 3 ")
		#print(" new check of where we even went to 4 ")
		
	#message_of_delta_start = breaks_and_handles_check()
	#var delta_message_int : int = -1
	#if message_of_delta_start:
		#delta_message_int = 1
		#first_run_prints.append(message_of_delta_start)
	#else:
		#delta_message_int = 0
		#first_run_prints.append("error")
	#first_run_numbers.append(delta_message_int)
	#####################
	###
	
			#print("❌ Task discarded:", task.tag)
		#print("⏳ Task Started:", task)
		
	# Debug system state
	#####################
	### [7] = mutexes check
	#####################
	# 📝 Load & Check Settings File
	
	##
	
	####################
	## mouse position at start, could break later

####################
# JSH Ethereal Engine Repair
#MISSION : REPAIR CHECK ENGINE
#
#CONNECTED MISSIONS :
#
#### CORE FUNCTIONS
#CHECK ENGINE
#CHECK SINGLE_THREAD
#CHECK MULTI_THREADS
#CHECK TASK_SYSTEM
#CHECK CLOCKS_AND_WATCHES_SYSTEM
#CHECK OS
#CHECK DIRECTIORIES
#CHECK FOLDERS
#
#
#### LOAD DATA
#CHECK SETTINGS_FILE
#CHECK IF_IT_IS_FIRST_RUN
#CHECK IF_WE_HAVE_DATABASES_ACCESS
#### NOW WE EITHER CREATE FILES, REOPEN FILES, OPEN FILES, RESTART THE SYSTEM
#CHECK FILES
#
#### TO SEE ANYTHING
#CHECK LOAD_BASIC_RECORDS_SETS
#
#print(" scan_results " , scan_result)
#scan result of project files :
#scan_result
####################
	#print(" new check of where we even went to 8 ")
	#print(" new check of where we even went to 9 ")
	# Check thread pool state
# array_with_no_mutex
	#print(" new check of where we even went to 10 ")
			# that one appeared before
			# we had this type of error before
					# this same stage of error as before
	
#######################
# JSH Ethereal Engine Repair
## Claude continuation
#######################
	#print(" new check of where we even went to 11 ")
	
	

#####################
## JSH Ethereal Engine Repair
#func reanimate_all_handles_and_breaks():
	##print(" new check of where we even went to 14 ")
	##print()
	#
	#var current_state_mutexes : Array = []
	#var negative_counter : int = -1
	#var positive_counter : int = -1
	#
######################################################
		### active_r_s_mut
	#var mutex_check_0 = null
	#if active_r_s_mut.try_lock():
		#mutex_check_0 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_0 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_0)
######################################################
	#
######################################################
		### cached_r_s_mutex
	#var mutex_check_1 = null
	#if cached_r_s_mutex.try_lock():
		#mutex_check_1 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_1 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_1)
######################################################
	#
######################################################
		### tree_mutex
	#var mutex_check_2 = null
	#if tree_mutex.try_lock():
		#mutex_check_2 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_2 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_2)
######################################################
	#
	#
######################################################
		### cached_tree_mutex
	#var mutex_check_3 = null
	#if cached_tree_mutex.try_lock():
		#mutex_check_3 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_3 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_3)
######################################################
	#
	#
######################################################
		### mutex_nodes_to_be_added
	#var mutex_check_4 = null
	#if mutex_nodes_to_be_added.try_lock():
		#mutex_check_4 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_4 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_4)
######################################################
	#
######################################################
		### movmentes_mutex
	#var mutex_check_5 = null
	#if movmentes_mutex.try_lock():
		#mutex_check_5 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_5 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_5)
######################################################
	#
######################################################
		### mutex_data_to_send
	#var mutex_check_6 = null
	#if mutex_data_to_send.try_lock():
		#mutex_check_6 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_6 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_6)
######################################################
	#
######################################################
		### mutex_function_call
	#var mutex_check_7 = null
	#if mutex_function_call.try_lock():
		#mutex_check_7 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_7 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_7)
######################################################
	#
######################################################
		### mutex_for_unloading_nodes
	#var mutex_check_8 = null
	#if mutex_for_unloading_nodes.try_lock():
		#mutex_check_8 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_8 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_8)
######################################################
#
######################################################
		### array_mutex_process
	#var mutex_check_9 = null
	#if array_mutex_process.try_lock():
		#mutex_check_9 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_9 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_9)
######################################################
#
#
#
#############################################################
#
## the cardinal sin of creation beyond number 9
#
##############################################################
#
#
######################################################
		### menace_mutex
	#var mutex_check_00 = null
	#if menace_mutex.try_lock():
		#mutex_check_00 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_00 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_00)
######################################################
#
######################################################
	## array_counting_mutex
	#var mutex_check_01 = null
	#if array_counting_mutex.try_lock():
		#mutex_check_01 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_01 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_01)
######################################################
#
######################################################
	## mutex_for_container_state
	#var mutex_check_02 = null
	#if mutex_for_container_state.try_lock():
		#mutex_check_02 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_02 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_02)
######################################################
#
######################################################
	## mutex_for_trickery
	#var mutex_check_03 = null
	#if mutex_for_trickery.try_lock():
		#mutex_check_03 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_03 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_03)
######################################################
#
######################################################
	## unload_queue_mutex
	#var mutex_check_04 = null
	#if unload_queue_mutex.try_lock():
		#mutex_check_04 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_04 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_04)
######################################################
#
######################################################
	## mutex_containers
	#var mutex_check_05 = null
	#if mutex_containers.try_lock():
		#mutex_check_05 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_05 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_05)
######################################################
#
######################################################
	## mutex_singular_l_u
	#var mutex_check_06 = null
	#if mutex_singular_l_u.try_lock():
		#mutex_check_06 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_06 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_06)
######################################################
#
#
#
######################################################
	## unload_queue_mutex
	#var mutex_check_07 = null
	#if unload_queue_mutex.try_lock():
		#mutex_check_07 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_07 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_07)
######################################################
#
#
######################################################
	## load_queue_mutex
	#var mutex_check_08 = null
	#if load_queue_mutex.try_lock():
		#mutex_check_08 = true
		##############################################
		#positive_counter +=1
	#else:
		#mutex_check_08 = false
		#negative_counter +=1
		##############################################
	#current_state_mutexes.append(mutex_check_08)
######################################################
	#
	#return current_state_mutexes
#####################
	#print(" new check of where we even went to 19 ")
	# From console: ["started", [["akashic_records"], ["base"], ["menu"]]]
	
	
			
		#pending_sets = array_of_startup_check[3]
	#else:
	#	print(" array_of_startup_check " , array_of_startup_check)
		
# Check at next Cycle
# Check Time



####################
# JSH Ethereal Time System
	#print("delta_current : ", delta_current, " time : ", time, " hour : ", hour, " minute : ", minute, " second : ", second)
	#time_passed += delta_current
	
	# time, plus two differenly calculated?
#(Time.get_ticks_msec() / 1000.0)
	#var time_1 = time / 10000.0#(Time.get_ticks_msec() / 10000.0)
	#var time_2 = time / 100000.0
	#var timer_reset = int(time_0)
	#var timer_reset2 = int(time_1)
	
	#var timer_new = time_0 - timer_reset
	#var timer_new2 = time_1 - timer_reset2
	
	#var oscillation = abs(1 - (timer_new * 2))
	#var oscillation2 = abs(1 - (timer_new2 * 2))	
	
	#var information =  0.5 * timer_new
	#var information2 = 0.5 * oscillation
	
	#var information3 = 0.5 + information2
	#var information4 = 2 + (2.0 * oscillation2)
	
	#var passed_seconds
	#var passed_minutes
	#var passed_hour
	
	# Convert milliseconds to seconds
	#if passed_seconds >= 60:
	#	passed_seconds -= 60
	#	passed_minutes += 1
		
		# Convert seconds to minutes
	#	if passed_minutes >= 60:
	#		passed_minutes -= 60
	#		passed_hour += 1
	#		

	#print("Time: ", minutes_passed, "m:", seconds_passed, "s:", milliseconds_passed, "ms")
	
	
	#second = time_0
	#minute = time_0 
	#print(" time calculated, 4 new main variables ")
	#print(" time : ", time, " time_0 : ", time_0, " time_1 : ", time_1, " time_2 : ", time_2)
	#print("past data, for shaders, from 1 to 0, from 0 to 1, simple easing? hmm")
	#print(" 2 new timers : ", timer_new, "timer_new2", timer_new2)
	#print(" oscilation? 2 : ", oscillation, " 2 ", oscillation2)
	#print("some information data ")
	#print("information : ", information, " , information2 : ", information2, " , information3 : ", information3, " , information4 : ", information4)
####################


# Add Task
# Check Task
# Modify Task
# Store Task
# Abort Task


	## Reset stuck mutexes
	#var mutexes_to_check = [
		#active_r_s_mut,
		#cached_r_s_mutex,
		#tree_mutex,
		#mutex_for_container_state
	#]
	#
	#for mutex in mutexes_to_check:
		#if !mutex.try_lock():
			## Force unlock if stuck
			#mutex.unlock()
			#log_error_state("mutex_stuck", {
				#"task_id": task_id,
				#"mutex": mutex
			#})
	#
	## Clear queue if needed
	#if task_data["retries"] > 3:
		#clear_task_queues()
####################
	#array_mutex_process.lock()
	#list_of_sets_to_create.clear()
	#array_mutex_process.unlock()
	#
	#mutex_nodes_to_be_added.lock() 
	#nodes_to_be_added.clear()
	#mutex_nodes_to_be_added.unlock()
	#
	## Reset container states
	#mutex_for_container_state.lock()
	#for container in current_containers_state.keys():
		#current_containers_state[container]["status"] = -1
	#mutex_for_container_state.unlock()
	

# Receive Data
# Send Data
# Check Data
# Store Data
# Connect
# Disconnect
	
	#mutex_additionals_call.unlock()
	#var array_of_interactions : Array = []
	#var number_of_interactions = header_line.size() - 5
	#var num_counter : int = 5
	#for num_in in number_of_interactions:
	#	array_of_interactions.append(header_line[num_counter])
	#	num_counter +=1
	#print(" interactions dilema now : ", header_line, information_lines)				
					#print(" lets rethink stuff, what was here? " ,first_line[0][0], [data_type_s_i, datapoint_path_l_c_d_s_i, thingies_to_make_path[0][0], first_line.duplicate(true), lines_parsed.duplicate(true)])
					# thingies_to_make_path[0][0] = container first_line[0][0] = instruction id, datapoint_path_l_c_d_s_i = datapoint path, data_type_s_i = to where it needs to go later

					#data_sending_mutex
					#data_that_is_send
								#container.rotation.x -= deg_to_rad(int(third_line[1][0]))
					#datapoint.initialize_loading_file(third_line)
					# thingies_to_make_path[0][0] = container first_line[0][0] = instruction id, datapoint_path_l_c_d_s_i = datapoint path, data_type_s_i = to where it needs to go later
			#container.position = Vector3(x, y, z)			#datapoint.setup_text_handling() # = get_node(database_node_path)									#print(" interaction single multi mode or whatever" , third_line[0][0] , third_line[1][0])
			
							#if !data_that_is_send[container_name]["metadata"]["data_set"].has(data_set_name):
				#	data_that_is_send[container_name]["metadata"]["data_set"][data_set_name] = "another"
						#if !data_that_is_send[container_name]["metadata"]["data_set"].has(data_set_name):
			#	data_that_is_send[container_name]["metadata"]["data_set"][data_set_name] = "another"
				#data_that_is_send[container_name]["metadata"]["data_set"] = {}
		#data_that_is_send[container_name]["metadata"]["data_set"][data_set_name] = "first"
			#print(" les check that  first  " , data_that_is_send[data_set_name][place_for_data][data_id])
				#print(" les check that instruction ", data_that_is_send[data_set_name]["instructions_analiser"][instruction][0][1][0])#, data_that_is_send[data_set_name]["instructions_analiser"][instruction])
		#print(" les check that repair ",data_that_is_send[data_set_name]["instructions_analiser"][instruction]["first_line"][1][0])
					#print(" les check that instruction ", data_that_is_send[data_set_name]["instructions_analiser"][instruction][1][1][0][0])
					#		elif data_that_is_send[data_set_name]["instructions_analiser"][instruction][0][1][0] == "set_the_scene":
#			print(" les check that instruction ", data_that_is_send[data_set_name]["instructions_analiser"][instruction])

	# "set_interaction_check_mode"
		#print(" les check that instruction ", data_that_is_send[data_set_name]["instructions_analiser"][instruction][0][1][0])#, data_that_is_send[data_set_name]["instructions_analiser"][instruction])
				#print(" les check that instruction ", data_that_is_send[data_set_name]["instructions_analiser"][instruction][1][1][0][0])
				#		elif data_that_is_send[data_set_name]["instructions_analiser"][instruction][0][1][0] == "set_the_scene":
#			print(" les check that instruction ", data_that_is_send[data_set_name]["instructions_analiser"][instruction])

	# "set_interaction_check_mode"
	
	## dunno what else can happen, 
		#
	#
	#var use_cache = false
	#var already_exists = false
	#
	#active_r_s_mut.lock()
	#cached_r_s_mutex.lock()
	### IF THAT RECORD IS IN ACTIVE, SO IT IS AT SCENE ALREADY
	#if active_record_sets.has(records_set_name):
		#print(" initalize memories ! 0A : " , record_type)
		#already_exists = true
		### IF IT HAS METADATA KEY
		#if active_record_sets[records_set_name].has("metadata"):
			#print(" initalize memories ! 0B : " , record_type)
			### IF CONTAINER COUNT CURRENTLY, EQUAL MAX AMOUNT OF THAT SET
			### IN FUTURE TO THINK OF SAVE FILES AND NEW CONSTRUCTS, WE MUST INCLUDE THE MAX AMOUNT IN RECORD ITSELF
			#if active_record_sets[records_set_name]["metadata"]["container_count"] == BanksCombiner.dataSetLimits[records_set_name]:
				#print(" initalize memories ! 0C : " , record_type)
				#active_r_s_mut.unlock()
				#cached_r_s_mutex.unlock()
				#
				#process_creation_further(record_type, 6)
				#return
			#
			### IF WE ALREADY HAVE JUST ONE SET PULLED, AND DIDNT HIT MAX
			#if active_record_sets[records_set_name]["metadata"]["container_count"] == 1:
				#var number_of_set = active_record_sets[records_set_name]["metadata"]["container_count"]
				#var additional_set_name = record_type + str(number_of_set)
				#var additional_set_name_ = additional_set_name + "_"
				### IF THE ACTIVE RECORDS SET DOES NOT HAVE YET, THAT ADDITIONAL THINGY
				#if !active_record_sets.has(additional_set_name_):
					### IF CACHED HAD IT, WE TAKE IT FROM HERE, AND CONTINUE
					#if cached_record_sets.has(additional_set_name_):
						##print(" initalize memories ! :  but cached had copy of that one? ")
						##active_record_sets[additional_set_name_] = cached_record_sets[additional_set_name_]
						##cached_record_sets.erase(additional_set_name_)
						#
						#
						#
						#if !cached_record_sets[additional_set_name_].is_empty():
							##print(" active records set fiasco ? 10")
							#active_record_sets[additional_set_name_] = cached_record_sets[additional_set_name_].duplicate(true)
							#active_record_sets[records_set_name]["metadata"]["container_count"] +=1
							#cached_record_sets.erase(additional_set_name_)
							#active_r_s_mut.unlock()
							#cached_r_s_mutex.unlock()
							#change_creation_set_name(record_type, additional_set_name_)
							#process_creation_further(record_type, 1)
							#
							#return
						#else:
							#var new_data = recreator(number_of_set, active_record_sets[records_set_name], record_type, additional_set_name_)
							#active_record_sets[additional_set_name_] = new_data.duplicate(true)
							#active_record_sets[records_set_name]["metadata"]["container_count"] +=1
							#active_r_s_mut.unlock()
							#cached_r_s_mutex.unlock()
							#change_creation_set_name(record_type, additional_set_name_)
							#process_creation_further(record_type, 1)
							#return 
						#
					## missing logic
					## if cached has it, take it, if not, then do as it was before
					### if active and cached does not have it
					### both didnt have that first one, we must create it again
					#else:
						### what do we need here, og record set name, additional set name, number of the set
						#var new_data = recreator(number_of_set, active_record_sets[records_set_name], record_type, additional_set_name_)
						#active_record_sets[additional_set_name_] = new_data.duplicate(true)
						#active_record_sets[records_set_name]["metadata"]["container_count"] +=1
						#active_r_s_mut.unlock()
						#cached_r_s_mutex.unlock()
						#change_creation_set_name(record_type, additional_set_name_)
						#process_creation_further(record_type, 1)
						#return 
						#
						#
						#
						#
						#
			### IF ACTIVE RECORDS HAVE THAT SET, AND COUNTER COUNTER IS ALREADY OVER SINGULAR
			#if active_record_sets[records_set_name]["metadata"]["container_count"] > 1:
				##print(" active records set fiasco ? 5")
				#var number_of_set = active_record_sets[records_set_name]["metadata"]["container_count"]
				#var previous_additional_set_name = record_type + str(number_of_set -1)
				#var previous_additional_set_name_underscore = previous_additional_set_name + "_"
				#var additional_set_name = record_type + str(number_of_set)
				#var additional_set_name_ = additional_set_name + "_"
				#
				#
				### HERE TO CHANGE? PROBABLY
				### nah, if it does not have, we make new data, but we also need, to change name 
				#if !active_record_sets.has(additional_set_name_):
				##if !active_record_sets.has(additional_set_name_):
					### IF CACHED HAD IT, WE TAKE IT FROM HERE, AND CONTINUE
					#if cached_record_sets.has(additional_set_name_):
						##print(" initalize memories ! :  but cached had copy of that one? ")
						##active_record_sets[additional_set_name_] = cached_record_sets[additional_set_name_]
						##cached_record_sets.erase(additional_set_name_)
						#
						#
						#
						#if !cached_record_sets[additional_set_name_].is_empty():
							##print(" active records set fiasco ? 10")
							#active_record_sets[additional_set_name_] = cached_record_sets[additional_set_name_].duplicate(true)
							#active_record_sets[records_set_name]["metadata"]["container_count"] +=1
							#cached_record_sets.erase(additional_set_name_)
							#active_r_s_mut.unlock()
							#cached_r_s_mutex.unlock()
							#change_creation_set_name(record_type, additional_set_name_)
							#process_creation_further(record_type, 1)
							#
							#return
						### if cached had it, but key is empty, we create it again but in future we will archive, and whip it out from file, so first we will check if we have a file
						#else:
							#var new_data = recreator(number_of_set, active_record_sets[previous_additional_set_name_underscore], previous_additional_set_name, additional_set_name_)
							#active_record_sets[additional_set_name_] = new_data.duplicate(true)
							#active_record_sets[records_set_name]["metadata"]["container_count"] +=1
							#active_r_s_mut.unlock()
							#cached_r_s_mutex.unlock()
							#change_creation_set_name(record_type, additional_set_name_)
							#process_creation_further(record_type, 1)
							#
							#return
						#
					## missing logic
					## if cached has it, take it, if not, then do as it was before
					### if active and cached does not have it
					#else:
						#var new_data = recreator(number_of_set, active_record_sets[previous_additional_set_name_underscore], previous_additional_set_name, additional_set_name_)
						#active_record_sets[additional_set_name_] = new_data.duplicate(true)
						#active_record_sets[records_set_name]["metadata"]["container_count"] +=1
						#active_r_s_mut.unlock()
						#cached_r_s_mutex.unlock()
						#change_creation_set_name(record_type, additional_set_name_)
						#process_creation_further(record_type, 1)
						#
						#return
					#
					#
					#
					### maybe we need to check cached again, like in == 1? here we just over one
				### active has that additional records set name, lets load it
				#else:
					##print(" active records set fiasco ? 7")
					#active_record_sets[additional_set_name_]["metadata"]["container_count"] +=1
					#active_r_s_mut.unlock()
					#cached_r_s_mutex.unlock()
					#change_creation_set_name(record_type, additional_set_name_)
					#process_creation_further(record_type, 1)
					#return
				#
				#
		#
		#
		#
		### IF ACTIVE RECORD IS THERE AS A KEY, BUT IS EMPTY, WE CHECK CACHE, COPY IT TO ACTIVE, AND LOAD IT
		#if active_record_sets[records_set_name].is_empty():
			#print(" initalize memories ! 0D : " , record_type)
			##print(" active records set fiasco ? 8")
			#if cached_record_sets.has(records_set_name):
				##print(" active records set fiasco ? 9")
				#if !cached_record_sets[records_set_name].is_empty():
					##print(" active records set fiasco ? 10")
					#active_record_sets[records_set_name] = cached_record_sets[records_set_name].duplicate(true)
					#active_record_sets[records_set_name]["metadata"]["container_count"] +=1
					#cached_record_sets.erase(records_set_name)
					#active_r_s_mut.unlock()
					#cached_r_s_mutex.unlock()
					#
					#process_creation_further(record_type, 1)
					#
					#return
	#active_r_s_mut.unlock()
	#cached_r_s_mutex.unlock()
	#create_record_from_script(record_type)


	#print(" messages_to_be_called : " , messages_to_be_called)
	#print(" newest toy : " , mouse_status)
	#print(" THAT IS A START ",data_that_is_send)
	
	
	#print_tree_structure(scene_tree_jsh["main_root"]["branches"]["settings_container"], 0)
	#print(" dictionary stuff : " , array_for_counting_finish)
	#var data_point_node = get_node_or_null("settings_container/thing_19")
	#if data_point_node:
		###print(" we got that node")
		#var data = data_point_node.check_state_of_dictionary_and_three_ints_of_doom()
		#print(" data : " , data)
	#
	
	
	#var delta_handles_state = breaks_and_handles_check_issue()
	
	
	
	
	#print(" delta message of mutexes ", delta_handles_state)
	#print(" delta issue 0")
	##############################################
	## do we take time blimp here to? with delta time for each of 0 to 9 turns so 10 in total ?

####################
# JSH Hidden Veil
		#print(" last_delta_to_forget : ", last_delta_to_forget)
	
	#print(" this is blimp of each tick : ", each_blimp_time)
	#print(" time of each turn delta ")
#var turn_delta_time_0 : 
####################

####################
# JSH Hidden Veil
	# check mutex state before each turn now? or not each turn?
	# var message_of_delta = breaks_and_handles_check()
	# print(" message_of_delta : " , message_of_delta)
				## we checked nodes up to that point
				# now we check if we even have the basic set of things to work with
				#if array_of_startup_check.size() == 0:
					#prepare_akashic_records_init()
				# readiness : { 
				#"mutex_state": [true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true], 
				#"thread_state": "working", 
				#"records_ready": true }
				#  delta, turn 0 : 
				#{ "mutexes": true, 
				#"threads": true, 
				#"records": true }
				#var shall_execute : int = 0
				#mutex_for_trickery.lock()
				#if menace_tricker_checker == 1:
					#shall_execute = 1
					##menace_tricker_checker = 2
				#if menace_tricker_checker == 2:
					#shall_execute = 2
				#if menace_tricker_checker == 2:
					#shall_execute = 3
				#if shall_execute == 0:
					#menace_tricker_checker = 2
				#mutex_for_trickery.unlock()
				#print(" shall_execute : " , shall_execute)
				## this is just checking if we have more than 0 sets to do
				# here we can check if we have anything to do
#array_mutex_process.unlock()
			#call_some_thingy()
			#print_tree_pretty()
			#print_tree_structure(scene_tree_jsh["main_root"]["branches"]["keyboard_right_container"], 0)
			#print(array_for_counting_finish)
				#turn_number_process += 1
			   # turn_number_process += 1
								#print(" just adde dnode 0 : ", just_added_node)
									#print(" just adde dnode 1 : ", just_added_node)
									#print(" just adde dnode 2 : ", just_added_node)
							#print(" we would move stuff ", node_to_operate)
							#print(" we would rotate stuff ", node_to_operate)
							#print(" here we would change text i guess ")
								#print(" the container exist")
							#print(" we would unload just a node")
							#print(" can i atleast print that thing? ", data_to_process)
								#print(" well we did get a node?")
							#print()
							#print()
										#print( " we got that node, and it has that function, ", function_data)
							#node_to_call_now.call(function_name, function_data)
				#menace_tricker_checker = 2
			#print(shall_execute)
					#print(" - the first start data : " , array_of_startup_check)
####################


#func process_turn_system():
	#match turn_number_process:
		#0:
			##print_tree_pretty()
			##if active_record_sets.has("base_"):
			##print_tree_structure(scene_tree_jsh["main_root"]["branches"]["singular_lines_container"], 0)
			##	print(" it has base ", active_record_sets["base_"])
			##print(" delta issue 01")
			##
			#turn_number_process += 1
			#
			#var try_turn_0 = array_mutex_process.try_lock()
			#if try_turn_0:
				#array_mutex_process.unlock()
			#else:
				#array_mutex_process.unlock()
				#return
			##
			#array_mutex_process.lock()
			#if list_of_sets_to_create.size() > 0:
				#array_mutex_process.unlock()
				#process_stages()
			#else:
				#array_mutex_process.unlock()
			#ready_for_once()
			##breaks_and_handles_check()
			##print("check_stuff_again : ", check_stuff_again)
			###print_tree_pretty()
			##var readiness = check_system_readiness()
			##if readiness.mutex_state && readiness.thread_state:
				### Safe to proceed with creation
				###process_pre_delta_check()
				##var check = check_if_all_systems_are_green()
				##print(" my own check in ready : " , first_run_numbers)
				##print(" nodes and scripts check : ", check)
				#### check if process delta is the same core like in ready
				##if preparer_of_data.size() == 2:
					##prepare_akashic_records()
				##var ready_two
				##var multi_thread_start = multi_threads_start_checker()
				##var message_of_handles = breaks_and_handles_check()
				##print(" message_of_handles : " , message_of_handles)
				##if multi_thread_start == true:
					###print(" we can start creation ")
					##ready_two = ready_for_once()
					##
					###var just_one_try : int = 0
					###func ready_for_once():
						###if just_one_try == 0:
							###create_new_task("three_stages_of_creation", "base")
							###create_new_task("three_stages_of_creation", "menu")
							###return true
						###else:
							###return false
					##
				###print(" difference of threads id with main core : " , multi_thread_start)
				##if ready_two == true:
					##print(" first stage of creation was called ")
				##
				##
				##
				### from create task three stages of creation? we can create
				###array_mutex_process.lock()
				###if list_of_sets_to_create.size() > 0:
					###array_mutex_process.unlock()
					###process_stages()
				###else:
					###array_mutex_process.unlock()
			##else:
				### Log state for debugging
				##print("System not ready: ", readiness)
			##delta_turn_0 = delta
			#pass
		#1:
			##
			#turn_number_process += 1
			##
			##if system_readiness.records:
			##	process_pending_sets()
			#
			#var try_turn_1 = mutex_nodes_to_be_added.try_lock()
			#if try_turn_1:
				#mutex_nodes_to_be_added.unlock()
			#else:
				#mutex_nodes_to_be_added.unlock()
				#return
			#
			#mutex_nodes_to_be_added.lock()
			#if nodes_to_be_added.size() > 0:
				#for i in range(min(max_nodes_added_per_cycle, nodes_to_be_added.size())):
					#var data_to_process = nodes_to_be_added.pop_front()
					#var data_type = data_to_process[0]
					#match data_type:
						#0:
							#var container_to_add = data_to_process[2]
							#var container_name = data_to_process[1]
							#add_child(container_to_add)
							#var just_added_node = get_node(container_name)
							#if just_added_node:
								#var data_to_be_checked : Array = []
								#data_to_be_checked.append([container_name, container_name, just_added_node])
								#create_new_task("the_finisher_for_nodes", data_to_be_checked)
							#else:
								#nodes_to_be_added.append(data_to_process)
								#print(" ERROR container was not found ")
						#1:
							#var parent_path = data_to_process[1]
							#var node_name = data_to_process[2]
							#var main_node_to_add = data_to_process[3]
							#var combined_path = parent_path + "/" + node_name
							#var container = get_node(parent_path)
							#if container:
								#container.add_child(main_node_to_add)
								#var just_added_node = get_node(combined_path)
								#if just_added_node:
									#var data_to_be_checked : Array = []
									#data_to_be_checked.append([combined_path, node_name, just_added_node])
									#create_new_task("the_finisher_for_nodes", data_to_be_checked)
								#else:
									#print("ERROR main node not found")
									#nodes_to_be_added.append(data_to_process)
								#
							#else:
								#print("ERROR container for main node not found")
								#nodes_to_be_added.append(data_to_process)
						#2:
							#var parent_path = data_to_process[1]
							#var node_name = data_to_process[2]
							#var main_node_to_add = data_to_process[3]
							#var container_name = data_to_process[4]
							#var combined_path = parent_path + "/" + node_name
							#var container = get_node(parent_path)
							#if container:
								#container.add_child(main_node_to_add)
								#var just_added_node = get_node(combined_path)
								#if just_added_node:
									#var data_to_be_checked : Array = []
									#data_to_be_checked.append([combined_path, node_name, just_added_node])
									#create_new_task("the_finisher_for_nodes", data_to_be_checked)
								#else:
									#print(" ERROR sub node not found ")
									#nodes_to_be_added.append(data_to_process)
								#
							#else:
								#print(" ERROR main node for sub node not found ")
								#nodes_to_be_added.append(data_to_process)
			#mutex_nodes_to_be_added.unlock()
			#pass
		#2:
			##
			#turn_number_process += 1
			##
			#
			#var try_turn_2 = mutex_data_to_send.try_lock()
			#if try_turn_2:
				#mutex_data_to_send.unlock()
			#else:
				#mutex_data_to_send.unlock()
				#return
			#
			#
			#mutex_data_to_send.lock()
			#if data_to_be_send.size() > 0:
				#for i in range(min(max_data_send_per_cycle, data_to_be_send.size())):
					#var data_to_be_send_rn = data_to_be_send.pop_front()
					#var current_type_of_data = data_to_be_send_rn[0]
					#var datapoint_path_cur = data_to_be_send_rn[1]
					#match current_type_of_data:
						#"instructions_analiser":
							#var container_path_rn = data_to_be_send_rn[2]
							#var container_node_rn = get_node(container_path_rn)
							#if container_node_rn:
								#var datapoint_node_rn = get_node(datapoint_path_cur)
								#if datapoint_node_rn:
									#var array_of_data_for_threes : Array = []
									#array_of_data_for_threes.append([current_type_of_data, data_to_be_send_rn[3].duplicate(true), data_to_be_send_rn[4].duplicate(true), datapoint_node_rn, container_node_rn])
									#create_new_task("task_to_send_data_to_datapoint", array_of_data_for_threes)
								#else:
									#print(" we didnt find the datapoint we must append stuff ")
									#data_to_be_send.append(data_to_be_send_rn)
							#else:
								#print(" we didnt get container, we must append ")
								#data_to_be_send.append(data_to_be_send_rn)
						#"scene_frame_upload":
							#var container_path_rn = data_to_be_send_rn[2]
							#var container_node_rn = get_node(container_path_rn)
							#if container_node_rn:
								#var datapoint_node_rn = get_node(datapoint_path_cur)
								#if datapoint_node_rn:
									#var array_of_data_for_threes : Array = []
									#array_of_data_for_threes.append([current_type_of_data, data_to_be_send_rn[3].duplicate(true), data_to_be_send_rn[4].duplicate(true), datapoint_node_rn, container_node_rn])
									#create_new_task("task_to_send_data_to_datapoint", array_of_data_for_threes)
								#else:
									#print(" we didnt find the datapoint we must append stuff ")
									#data_to_be_send.append(data_to_be_send_rn)
							#else:
								#print(" we didnt get container, we must append ")
								#data_to_be_send.append(data_to_be_send_rn)
						#"interactions_upload":
							#var datapoint_node_rn = get_node(datapoint_path_cur)
							#if datapoint_node_rn:
								#var array_of_data_for_threes : Array = []
								#array_of_data_for_threes.append([current_type_of_data, data_to_be_send_rn[3].duplicate(true), data_to_be_send_rn[4].duplicate(true), datapoint_node_rn])
								#create_new_task("task_to_send_data_to_datapoint", array_of_data_for_threes)
							#else:
								#print(" we didnt got that datapoint, we gotta apend")
								#data_to_be_send.append(data_to_be_send_rn)
			#mutex_data_to_send.unlock()
			#pass
		#3:
			##
			#turn_number_process += 1
			##
			#
			#var try_turn_3 = movmentes_mutex.try_lock()
			#if try_turn_3:
				#movmentes_mutex.unlock()
			#else:
				#movmentes_mutex.unlock()
				#return
			#
			#movmentes_mutex.lock()
			#if things_to_be_moved.size() > 0:
				#for i in range(min(max_movements_per_cycle, things_to_be_moved.size())):
					##print()
					#var data_to_process = things_to_be_moved.pop_front()
					#var data_type = data_to_process[0]
					#var node_to_operate = data_to_process[1]
					#var data_for_operation = data_to_process[2]
					#match data_type:
						#"move":
							#node_to_operate.position = data_for_operation
						#"rotate":
							#node_to_operate.rotation.x -= deg_to_rad(data_for_operation)
						#"write":
							#for child in node_to_operate.get_children():
								#if child is Label3D:
									#child.text = data_for_operation
			#movmentes_mutex.unlock()
			#pass
		#4:
			##
			#turn_number_process += 1
			##
			#
			#var try_turn_4 = mutex_for_unloading_nodes.try_lock()
			#if try_turn_4:
				#mutex_for_unloading_nodes.unlock()
			#else:
				#mutex_for_unloading_nodes.unlock()
				#return
			#
			#mutex_for_unloading_nodes.lock()
			#if nodes_to_be_unloaded.size() > 0:
				#for i in range(min(max_nodes_to_unload_per_cycle, nodes_to_be_unloaded.size())):
					#var data_to_process = nodes_to_be_unloaded.pop_front()
					#var data_type = data_to_process[0]
					#var path_of_the_node = data_to_process[1]
					#match data_type:
						#"container":
							#print(" we would unload container")
							#var container_to_unload = get_node_or_null(path_of_the_node)
							#if container_to_unload:
								#
								#var sub_path_of_the_node = path_of_the_node.substr(0, path_of_the_node.length() -10)
								#print("taskkkk sub_path_of_the_node ", sub_path_of_the_node)
								#container_to_unload.queue_free()
								#create_new_task("unload_container", path_of_the_node)
							#else:
								#print(" we didnt find that container")
						#"just_node":
							#var node_to_unload = get_node_or_null(path_of_the_node)
							#if node_to_unload:
								#node_to_unload.queue_free()
								#create_new_task("find_branch_to_unload", path_of_the_node)
							#else:
								#print(" i guess we didnt get node unfortunatelly ?")
			#mutex_for_unloading_nodes.unlock()
			#pass
		#5:
			##
			#turn_number_process += 1
			##
			#
			#var try_turn_5 = mutex_function_call.try_lock()
			#if try_turn_5:
				#mutex_function_call.unlock()
			#else:
				#mutex_function_call.unlock()
				#return
			#
			#mutex_function_call.lock()
			#if functions_to_be_called.size() > 0:
				#for i in range(min(max_functions_called_per_cycle, functions_to_be_called.size())):
					#var data_to_process = functions_to_be_called.pop_front()
					#var type_of_functi = data_to_process[0]
					#var node_to_call = data_to_process[1]
					#var function_name = data_to_process[2]
					#match type_of_functi:
						#"single_function":
							#if node_to_call and node_to_call.has_method(function_name):
								#node_to_call.call(function_name)
						#"call_function_get_node":
							#var function_data = data_to_process[3]
							#var node_to_call_now = get_node_or_null(node_to_call)
							#if node_to_call_now and node_to_call_now.has_method(function_name):
								#node_to_call_now.call(function_name, function_data)
						#"call_function_single_get_node":
							#var node_to_call_now = get_node_or_null(node_to_call)
							#if node_to_call_now and node_to_call_now.has_method(function_name):
								#node_to_call_now.call(function_name)
						#"get_nodes_call_function":
							#if data_to_process.size() > 3:
								#var function_data = data_to_process[3]
								#for nodes in node_to_call:
									#var current_node_to_call = get_node_or_null(nodes)
									#if current_node_to_call and current_node_to_call.has_method(function_name):
										#current_node_to_call.call(function_name, function_data)
							#else:
								#print(" parallel reality somehow it is small size?")
			#mutex_function_call.unlock()
			#pass
		#6:
			##
			#turn_number_process += 1
			##
			#
			#var try_turn_6 = mutex_additionals_call.try_lock()
			#if try_turn_6:
				#mutex_additionals_call.unlock()
			#else:
				#mutex_additionals_call.unlock()
				#return
			#
			#mutex_additionals_call.lock()
			#if additionals_to_be_called.size() > 0:
				#for i in range(min(max_additionals_per_cycle, additionals_to_be_called.size())):
					#print(" we got magic to do ", additionals_to_be_called)
					#var data_to_process = additionals_to_be_called.pop_front()
					#var type_of_data = data_to_process[0]
					#var what_data = data_to_process[1]
					#var amount_of_times = data_to_process[2]
					#if amount_of_times != 0:
					#
						#match type_of_data:
							#"add_container":
								#print(" we got magic to do we got containers to add")
								#if BanksCombiner.container_set_name.has(what_data):
									#print(" we got magic to do set name found ")
									#var set_name = BanksCombiner.container_set_name[what_data]
									#var is_it_loading = check_if_already_loading_one(set_name)
									#if is_it_loading == true:
										#print(" we got magic to do it is being loaded")
										#additionals_to_be_called.append(data_to_process)
									#elif is_it_loading == false:
										#print(" we got magic to do we can start loading it now")
										#three_stages_of_creation(set_name)
										#amount_of_times -=1
										#additionals_to_be_called.append([type_of_data, what_data, amount_of_times])
								#else:
									#print(" we got magic to do set name not found ")
									#additionals_to_be_called.append(data_to_process)
							#_:
								#additionals_to_be_called.append(data_to_process)
			#mutex_additionals_call.unlock()
			#var start_finished_counting : int = int_of_stuff_finished
			#var start_now_counting : int = int_of_stuff_started
			#before_time_blimp(start_finished_counting, start_now_counting)
			## check states of containers, and created data already
			#var shall_execute : int = 0
			#mutex_for_trickery.lock()
			#if menace_tricker_checker == 1:
				#shall_execute = 1
			#if menace_tricker_checker == 2:
				#shall_execute = 2
			#if menace_tricker_checker == 2:
				#shall_execute = 3
			#mutex_for_trickery.unlock()
			## FATAL ERROR MODE
			#if shall_execute == 3:
				#unlock_stuck_mutexes()
				#containers_states_checker()
				#containers_list_creator()
				#var message_now_mutex = breaks_and_handles_check()
				#check_currently_being_created_sets()
				#handle_random_errors() # array_with_no_mutex
				##mutex_for_container_state.lock()
				##mutex_containers.lock()
				##print(" process delta ")
				##print(" process delta outcome : list_of_containers " , list_of_containers)
				##print(" process delta ")
				##print(" process delta outcome : current_containers_state : ", current_containers_state)
				##print("  process delta ")
				##print(" process delta mutex chck : ", message_now_mutex)
				##print(" process delta array with no protection : " , array_with_no_mutex)
				##mutex_containers.unlock()
				##mutex_for_container_state.unlock()
				## The pattern shows tasks starting but not finishing (2 started, 0 finished)
			#if some_kind_of_issue == 1:
				#print(" Task completion check - Started: ", start_now_counting, " Finished: ", start_finished_counting)
				## Check container states
				#containers_states_checker()
				#containers_list_creator()
				## Check mutexes
				#var mutex_states = breaks_and_handles_check()
				## Check creation progress
				#check_currently_being_created_sets()
				## Handle any errors
				#handle_random_errors()
				#
				## Debug output
				##mutex_for_container_state.lock()
				#mutex_containers.lock()
				##print(" - Process state check:")
				##print(" - Containers: ", list_of_containers)
				#var container_size = list_of_containers.size()
				##print(" - also container size : " , container_size)
				#if container_size == 0:
					##print(" - potential first container not appearing from task, better to abort the mission, and restart the creation")
					#check_system_health()
					##print(" - task_status : " , task_status)
				##print(" - Container states: ", current_containers_state)
				##print(" - Mutex states: ", mutex_states)
				##print(" - Unhandled errors: ", array_with_no_mutex)
				##print(" - stuck_status: ", stuck_status)
				#mutex_containers.unlock()
				##mutex_for_container_state.unlock()
				#
				#var stuck_status = check_thread_status()
				#if stuck_status > 0:
					##print("0010110 it seems some threads are stuck ?")
					#shall_execute = 3
				#else:
					#print("0010110 no thread seems to be stuck ")
					## Check memory state periodically
				#
			#var current_time = Time.get_ticks_msec()
			#if current_time - memory_metadata["last_cleanup"] > memory_metadata["cleanup_thresholds"]["time_between_cleanups"]:
				#var memory_state = check_memory_state()
				#print(" memory_state : " , memory_metadata)
				#memory_metadata["last_cleanup"] = current_time
			#pass
		#7:
			##
			#turn_number_process += 1
			##
			#
			#var try_turn_7 = mutex_messages_call.try_lock()
			#if try_turn_7:
				#mutex_messages_call.unlock()
			#else:
				#mutex_messages_call.unlock()
				#return
				#
			#mutex_messages_call.lock()
			#if messages_to_be_called.size() > 0:
				#for i in range(min(max_messages_per_cycle, messages_to_be_called.size())):
					#print(" we got magic to do ", messages_to_be_called)
					#var data_to_process = messages_to_be_called.pop_front()
					#var type_of_message = data_to_process[0]
					#var message_to_send = data_to_process[1]
					#var receiver = data_to_process[2]
					#
					##var datapoint_to_check
					##if datapoint_to_check == true:
					#
					#match type_of_message:
						#"singular_lines_text":
							#print(" we got magic to do we got containers to add")
							#var container_to_check = check_if_container_available(receiver)
							#print(" container_to_check : " , container_to_check)
							#if container_to_check == false:
								#messages_to_be_called.append(data_to_process)
							#elif container_to_check == true:
								#print(" container_to_check was found ")
								#var datapoint_to_check = check_if_datapoint_available(receiver)
								#
								#if datapoint_to_check == false:
									#messages_to_be_called.append(data_to_process)
								#elif datapoint_to_check == true:
									#
									#
									#var datapoint_path_check = check_if_datapoint_node_available(receiver)
									#var datapoint_node = get_node(datapoint_path_check)
									#
									#if datapoint_node:
										#print(" we got that datapoint to send message")
										#datapoint_node.receive_a_message(message_to_send)
										#
										#
									#else:
										#print(" no node available yet")
										#messages_to_be_called.append(data_to_process)
								##messages_to_be_called.append(data_to_process)
								##var container_missing : String = "singular_lines_container"
								##var type_of_message = "singular_lines_text"
								##main_node.eight_dimensional_magic(type_of_message, the_label_message, container_missing)
						#_:
							#print(" didnt find it ")
			#
			#mutex_messages_call.unlock()
			#
			#
			#pass
		#8:
			##
			#turn_number_process += 1
			##
			#pass
		#9:
			##print(" delta issue 2")
			##
			#turn_number_process = 0
			##
			#pass



####################
# JSH Projections System
		#print(" maytbe there?")
#		print("containter : ", container)
		#print("current_node : " , current_node)
		#await self.get_tree().process_frame
			#var array_of_things_that_shall_remain = 
				#print(scene_tree_jsh["main_root"]["branches"][stringy_container]["datapoint"]["datapoint_path"])
			#if array_of_things_that_shall_remain != null:
				#var array_size = array_of_things_that_shall_remain[1].size()
				#if array_size > 0:
					#secondary_interaction_after_rc(array_of_things_that_shall_remain[1])
				#unload_nodes(array_of_things_that_shall_remain[0][0])
	
		#print(line_node_now.get_script())
		#print(line_node_now.has_method("change_points_of_line"))
####################


#####################
## JSH Digital Earthlings Integration
#func _cmd_create(args):
	#if args.size() < 2:
		#return {"success": false, "message": "Usage: create [type] [name] [attributes...]"}
	#
	#var type = args[0]
	#var name = args[1]
	#var attributes = {}
	#
	## Parse optional attributes
	#for i in range(2, args.size(), 2):
		#if i + 1 < args.size():
			#attributes[args[i]] = args[i + 1]
	#
	## Create entity
	#print("🧩 Creating entity: " + name + " of type: " + type)
	#
	## Use first_dimensional_magic to create the entity
	#var container_path = current_reality + "_reality_container"
	#first_dimensional_magic("create_entity", container_path, {
		#"type": type,
		#"name": name,
		#"attributes": attributes
	#})
	#
	## Remember this creation
	#remember("creation_" + name, {"type": type, "attributes": attributes})
	#
	#return {
		#"success": true,
		#"message": "Created " + type + " named " + name,
		#"entity_name": name
	#}
#####################
#
#####################
## JSH Digital Earthlings Integration
#func _cmd_transform(args):
	#if args.size() < 2:
		#return {"success": false, "message": "Usage: transform [entity_name] [new_form] [attributes...]"}
	#
	#var entity_name = args[0]
	#var new_form = args[1]
	#var attributes = {}
	#
	## Parse optional attributes
	#for i in range(2, args.size(), 2):
		#if i + 1 < args.size():
			#attributes[args[i]] = args[i + 1]
	#
	## Transform entity
	#print("🔄 Transforming entity: " + entity_name + " into: " + new_form)
	#
	## Use fourth_dimensional_magic to transform the entity
	#var container_path = current_reality + "_reality_container"
	#var entity_path = container_path + "/" + entity_name
	#the_fourth_dimensional_magic("transform", entity_path, {
		#"form": new_form,
		#"attributes": attributes
	#})
	#
	## Remember this transformation
	#remember("transform_" + entity_name, {"new_form": new_form, "attributes": attributes})
	#
	#return {
		#"success": true,
		#"message": "Transformed " + entity_name + " into " + new_form,
		#"entity_name": entity_name
	#}
#####################
#
#####################
## JSH Digital Earthlings Integration
#func _cmd_remember(args):
	#if args.size() < 2:
		#return {"success": false, "message": "Usage: remember [concept] [details...]"}
	#
	#var concept = args[0]
	#var details = " ".join(args.slice(1, args.size() - 1))
	#
	## Store in memory
	#var result = remember(concept, details)
	#
	#return {
		#"success": true,
		#"message": "Remembered " + concept + " as " + details,
		#"concept": concept
	#}
#####################
#
#####################
## JSH Digital Earthlings Integration
#func _cmd_shift(args):
	#if args.size() < 1:
		#return {"success": false, "message": "Usage: shift [reality_type]"}
	#
	#var reality_type = args[0]
	#
	## Check if valid reality type
	#if !REALITY_STATES.has(reality_type):
		#return {
			#"success": false,
			#"message": "Unknown reality type: " + reality_type + ". Valid types: " + str(REALITY_STATES)
		#}
	#
	## Shift reality
	#create_new_task("shift_reality", reality_type)
	#
	## Remember this shift
	#remember("reality_shift", {"new_reality": reality_type})
	#
	#return {
		#"success": true,
		#"message": "Shifting reality to " + reality_type,
		#"reality": reality_type
	#}
#####################
#
#####################
## JSH Digital Earthlings Integration
#func _cmd_speak(args):
	#if args.size() < 2:
		#return {"success": false, "message": "Usage: speak [entity_name] [message]"}
	#
	#var entity_name = args[0]
	#var message = " ".join(args.slice(1, args.size() - 1))
	#
	## Send message to entity
	#print("💬 Speaking to entity: " + entity_name + " with message: " + message)
	#
	## Use eighth_dimensional_magic for messaging
	#eight_dimensional_magic("player_message", message, entity_name)
	#
	## Remember this conversation
	#remember("conversation_" + entity_name, {"message": message})
	#
	#return {
		#"success": true,
		#"message": "Spoke to " + entity_name + ": " + message,
		#"entity_name": entity_name
	#}
#####################
#
#####################
## JSH Digital Earthlings Integration
#func _cmd_glitch(args):
	#if args.size() < 2:
		#return {"success": false, "message": "Usage: glitch [parameter] [intensity] [duration]"}
	#
	#var parameter = args[0]
	#var intensity = args[1]
	#var duration = "10s"
	#
	#if args.size() > 2:
		#duration = args[2]
	#
	## Valid parameters
	#var valid_parameters = ["physics", "visuals", "audio", "time"]
	#if !valid_parameters.has(parameter):
		#return {
			#"success": false,
			#"message": "Invalid parameter: " + parameter + ". Valid parameters: " + str(valid_parameters)
		#}
	#
	## Create glitch effect
	#var result = create_glitch_effect(parameter, intensity, duration)
	#
	#return {
		#"success": true,
		#"message": "Created " + parameter + " glitch with intensity " + str(result.intensity) + " for " + duration,
		#"parameter": parameter
	#}
#####################
#####################
## JSH Digital Earthlings Integration
#func cmd_threads(args):
	#if args.size() < 1:
		#return {
			#"success": false,
			#"message": "Usage: threads [count]"
		#}
	#
	#var count = int(args[0])
	#if count <= 0:
		#return {
			#"success": false,
			#"message": "Thread count must be greater than 0"
		#}
	#
	#var max_threads = OS.get_processor_count()
	#var actual_count = min(count, max_threads)
	#
	#print("🧵 Setting thread count to: " + str(actual_count))
	#
	## Use JSH thread pool system
	#if thread_pool and thread_pool.has_method("set_thread_count"):
		#thread_pool.set_thread_count(actual_count)
	#
	#return {
		#"success": true,
		#"message": "Thread count set to: " + str(actual_count) + " (Available: " + str(max_threads) + ")"
	#}
#####################
#####################
## JSH Digital Earthlings Integration
#func cmd_thread_status(args):
	#print("🧵 Checking thread status...")
	#
	## Use JSH's thread status check
	#if thread_pool and thread_pool.has_method("get_thread_stats"):
		#var stats = thread_pool.get_thread_stats()
		#
		#var active_count = 0
		#var total_count = OS.get_processor_count()
		#
		#for thread_id in stats:
			#if stats[thread_id].status == "executing":
				#active_count += 1
		#
		#var usage_percent = int((float(active_count) / total_count) * 100) if total_count > 0 else 0
		#var message = "Thread usage: " + str(active_count) + "/" + str(total_count) + " (" + str(usage_percent) + "%)"
		#
		#return {
			#"success": true,
			#"message": message,
			#"stats": stats
		#}
	#else:
		#return {
			#"success": false,
			#"message": "Thread status unavailable"
#####################
#####################
## JSH Digital Earthlings Integration
#func cmd_reset_threads(args):
	#print("🧵 Resetting thread settings to defaults...")
	#var default_count = min(4, OS.get_processor_count()
	## Use JSH thread pool system
	#if thread_pool and thread_pool.has_method("set_thread_count"):
		#thread_pool.set_thread_count(default_count)
	## Reset allocations
	#if thread_pool and thread_pool.has_method("set_thread_allocation"):
		#thread_pool.set_thread_allocation("AI_PROCESSING", 40)
		#thread_pool.set_thread_allocation("PHYSICS_SIMULATION", 20)
		#thread_pool.set_thread_allocation("ENTITY_BEHAVIOR", 20)
		#thread_pool.set_thread_allocation("REALITY_SHIFTING", 10)
		#thread_pool.set_thread_allocation("MEMORY_SYSTEM", 10)
	#return {
		#"success": true,
		#"message": "Thread settings reset to defaults. Using " + str(default_count) + " threads."
#####################
#####################
## JSH Digital Earthlings Integration
#func cmd_help(args):
	#var help_text = """
#=== DIGITAL EARTHLINGS: COMMAND REFERENCE ===
#== Basic Commands ==
#create [type] [name] [attributes...] - Create a new entity
#transform [entity_name] [new_form] [attributes...] - Change entity form
#remember [concept] [details...] - Store information in memory
#shift [reality_type] - Change reality state (physical, digital, astral)
#speak [entity_name] [message] - Communicate with an entity
#glitch [parameter] [intensity] [duration] - Create reality distortion
#
#== System Commands ==
#threads [count] - Set the number of CPU threads to use
#thread_status - Display current thread usage information
#reset_threads - Reset thread settings to defaults
#help - Display this command reference
#
#== Examples ==
#create spirit guardian mood annoyed color blue
#transform guardian flower petals many color red
#remember this_place as sanctuary
#shift astral
#speak guardian why are you following me
#glitch physics high 30s
#threads 8
#"""
	#
	#print(help_text)
	#
	#return {
		#"success": true,
		#"message": "Help displayed. See console for command reference."
#####################
#
## ==========================================
## JSH Digital Earthlings Integration - AI Integration
## ==========================================
#
#####################
## JSH Digital Earthlings Integration
#func load_gemma_model(config_data):
	#print("🧠 Loading Gemma AI model...")
	#
	## Check if Gemma AI system is available
	#if gemma_ai and gemma_ai.has_method("load_model"):
		#return gemma_ai.load_model()
	#else:
		#print("⚠️ Gemma AI system not available, will use simulated responses")
		#return {"status": "error", "message": "Gemma AI system not available"}
#####################
#
#####################
## JSH Digital Earthlings Integration
#func _on_ai_model_loaded(success):
	#if success:
		#print("✅ Gemma AI model loaded successfully")
	#else:
		#print("⚠️ Failed to load Gemma AI model")
#####################
#####################
## JSH Digital Earthlings Integration
#func _on_ai_response_generated(response_text, entity_id):
	#print("🧠 AI response: " + response_text)
	#
	## If response is for a guardian message
	#if entity_id.begins_with("guardian_"):
		## The AI generated a guardian message, use it in the next deja vu
		#var guardian_message = response_text
		## Store it for later use
		#player_memory["last_guardian_message"] = [{
			#"details": guardian_message,
			#"timestamp": Time.get_ticks_msec(),
			#"reality": current_reality
		#}]
	#}
	## Otherwise, it's for an entity dialog
	#else if entity_id.begins_with("entity_"):
		#var entity_name = entity_id.substr(7)
		## Send message to entity using JSH's messaging system
		#eight_dimensional_magic("ai_message", response_text, entity_name)
	#}
#####################
# ==========================================
# JSH Digital Earthlings Integration - Event Handlers
# ==========================================
#####################
## JSH Digital Earthlings Integration
#func _on_reality_shifted(old_reality, new_reality):
	#print("🌐 Reality shifted from " + old_reality + " to " + new_reality)
	#
	## Handle reality transition effects
	#first_dimensional_magic("update_reality", "all_entities", {"new_reality": new_reality})
	#
	## Notify guards of reality shift
	#seventh_dimensional_magic("notify_guardians", "reality_shift", 1)
#####################
#####################
## JSH Digital Earthlings Integration
#func _on_guardian_spawned(guardian_type, location):
	#print("👻 Guardian of type " + guardian_type + " spawned at " + str(location))
	#
	## Create special effects at guardian location
	#the_fourth_dimensional_magic("spawn_effect", location, {"type": "guardian_arrival", "color": get_guardian_color(guardian_type)})
#####################
#####################
## JSH Digital Earthlings Integration
#func _on_deja_vu_triggered(trigger_data):
	#print("🔄 Déjà vu triggered: " + str(trigger_data))
	#
	## Create visual déjà vu effect
	#create_glitch_effect("visuals", 35, "2s")
	#
	## Slow time briefly
	#var original_time_scale = Engine.time_scale
	#Engine.time_scale *= 0.5
	#
	## Reset time scale after 2 seconds
	#var timer = get_tree().create_timer(2.0)
	#timer.connect("timeout", Callable(Engine, "set_time_scale").bind(original_time_scale))
#####################
#####################
## JSH Digital Earthlings Integration
#func _on_command_processed(command, result):
	#print("🖥️ Command processed: " + command + " → " + ("✓" if result.success else "✗"))
	#
	## Add to memory for potential déjà vu
	#if result.success:
		#remember("command_executed", {"command": command, "result": result.message})
#####################
#####################
## JSH Digital Earthlings Integration
#func _on_task_completed(task_id, result):
	#print("✅ Task completed: " + task_id)
#####################
#####################
## JSH Digital Earthlings Integration
#func _on_task_discarded(task):
	#print("✅ Task discarded: " + str(task.tag))
#####################
#####################
## JSH Digital Earthlings Integration
#func _on_task_started(task):
	#print("⏳ Task started: " + str(task))
#####################
# ==========================================
# JSH Digital Earthlings Integration - Helper Functions
# ==========================================
#####################
## JSH Digital Earthlings Integration
#func is_creation_possible():
	## Check if the system is ready for creation
	#if task_manager and task_manager.has_method("check_task_status"):
		#return task_manager.check_task_status("creation") != "locked"
	#return true
#####################
#####################
## JSH Digital Earthlings Integration
#func _process(delta):
	## Process tasks through JSH Ethereal Engine
	## This allows Digital Earthlings to integrate with the existing task system
	#
	## Check for reality anomalies
	#if Engine.time_scale > 0 and randf() < 0.001 * delta:
		## Rare random anomaly (0.1% chance per second)
		#create_anomaly()
	#
	## Auto-update deja vu counter
	#if deja_vu_counter > 0 and deja_vu_counter % config.reality.auto_shift_count == 0:
		## Reset counter
		#deja_vu_counter = 0
		#
		## Create random anomaly
		#create_anomaly()
#####################
#####################
## JSH Digital Earthlings Integration
#func test_thread_system():
	## Test single core operation
	#print("🧪 Testing single core operation...")
	#prepare_akashic_records()
	#
	## Test multi-threaded operation
	#print("🧪 Testing multi-threaded operation...")
	#create_new_task_empty("prepare_akashic_records")
	#
	## Check results
	#var timer = get_tree().create_timer(0.5)
	#timer.connect("timeout", Callable(self, "verify_thread_test"))
#####################
#
#####################
## JSH Digital Earthlings Integration
#func verify_thread_test():
	#var multi_threaded_working = multi_threads_start_checker()
	#
	#if multi_threaded_working:
		#print("✅ Multi-threading is working correctly!")
	#else:
		#print("⚠️ Multi-threading may not be working as expected")
	#
	#return {"status": "completed", "multi_threaded": multi_threaded_working}
#####################
#
## JSH_digital_earthlings_integration.gd
#extends Node3D

####################
#
# JSH Digital Earthlings Integration
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓• •      ┓    ┏┓   •                   
#       888  `"Y8888o.   888ooooo888     ┣┫┓┏┓┓╋┏┓┏┓┃    ┣ ┏┓┏┓┫┏┏┓┏┓┏┓┏┓╋┓┏┓┏┓    
#       888      `"Y88b  888     888     ┛┗┗┗┫┗┗┫┛ ┗┗    ┻ ┗┫┛┗┗┗┗ ┗┫┛┗┗┻┗┗┗ ┛    
#       888 oo     .d8P  888     888           ┛  ┛         ┛    ┛          ┛     
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# JSH Digital Earthlings Integration
#
####################
# Signals

####################
# Initialization
####################
#
#func _ready():
	#print("\n🚀 [READY] Initializing Digital Earthlings Game v" + VERSION + "...\n")
	#
	## Connect to signals
	#connect_signals()
	#
	## Register with BanksCombiner
	#register_with_banks_combiner()
	#
	## Add to JSH Records System
	#if records_system and records_system.has_method("add_stuff_to_basic"):
		#var basic_sets = [["digital_earthlings"]]
		#records_system.add_stuff_to_basic(basic_sets)
	#
	## Add command processor
	#setup_command_processor()
	#
	## Create task to load game after a short delay
	#var timer = get_tree().create_timer(1.0)
	#timer.timeout.connect(initialize_game)
	#
	#print("\n✅ Digital Earthlings initialization queued.\n")
# ==========================================
# JSH Digital Earthlings Integration - Setup
# ==========================================
#####################
## JSH Digital Earthlings Integration
#func _ready():
	#print("\n🚀 [READY] Beginning Digital Earthlings integration...\n")
	#
	## Register with JSH_task_manager
	#if task_manager:
		#task_manager.new_task_appeared("digital_earthlings_init", "initialize_integration", "startup")
	#
	## Initialize all core systems
	#initialize_integration()
	#
	## Connect signals
	#connect_signals()
	#
	#print("\n✅ Digital Earthlings integration complete!\n")
#####################
#####################
## JSH Digital Earthlings
#func connect_signals():
	## Connect to reality shifting
	#self.connect("reality_shifted", Callable(self, "_on_reality_shifted"))
	#
	## Connect to guardian spawning
	#self.connect("guardian_spawned", Callable(self, "_on_guardian_spawned"))
	#
	## Connect to déjà vu triggering
	#self.connect("deja_vu_triggered", Callable(self, "_on_deja_vu_triggered"))
#####################
	#get_tree().create_timer(duration).timeout
#func initialize_ai_system():
	#print("🧠 Initializing AI integration")
	#
	## Setup default context
	#var default_context = "You are a guardian entity in the Digital Earthlings game. " + 
						 #"You observe the player, who is a godlike entity that exists across dimensions. " +
						 #"You communicate in cryptic but insightful ways about reality, existence, and the player's actions."
	#
	## In a real implementation, we would load the AI model here
	## For now, simulate loading with a simple flag
	#gemma_loaded = true
	#
	#print("🧠 AI system initialized")
	## Apply using Physics2DServer (part of JSH engine)
	#Physics2DServer.area_set_param(get_world_2d().get_space(), 
		#Physics2DServer.AREA_PARAM_GRAVITY, 
		#new_gravity)
	#
	## Reset after duration
	#get_tree().create_timer(duration).timeout.connect(func(): 
		#Physics2DServer.area_set_param(get_world_2d().get_space(), 
			#Physics2DServer.AREA_PARAM_GRAVITY, 
			#original_gravity)
	#)
#mutex_for_container_state.lock()
#print(" current_containers_state : " ,
# current_containers_state)
#mutex_for_container_state.unlock()					
# Set up the connection						
# Not ready yet, retry					
# Get keyboard datpoint						
# Retry later					
# Check if keyboard exists, 
#create if not				
# In the main node script								
#print(" main check now : " 
#,diction_check)								
#var diction_check = 
#datapoint_node.check_dictionary_from_datapoint()
## here we send data to a datapoint, 
#from datapoint
## right now it is just settings text			
#var datapoint_to_check#if 
#datapoint_to_check == true:			
#if amount_of_times == 0:
#match type_of_data:
#"add_container":
##var get_that_datapoint
##var datapoint_to_check = 
#check_if_datapoint_available(what_data)
#var datapoint_path_check = 
#check_if_datapoint_node_available(what_data)
#print(" all of them loaded, we could here, 
#use that duality thingy? ", datapoint_path_check)
#var datapoint_node = 
#get_node_or_null(datapoint_path_check)
#datapoint_node.change_dual_text()
#datapoint_node.change_dual_text()
## here we are adding more 
#than one container of a thing, 
#like them singular lines						
## first it goes to input,
# then it makes call for a
# function, then we do the 
#did## then we come back here, 
#but we are still in process delta,
# we must check next frame
## here we call functions						
#handle_unload_task(path_of_the_node)						
## here we add it to list, and check things						
## here we were, i think unloading
# active record set, tree stuff too, and similar						
## check if we are adding 
#that container to scene
## check if we have more than 
#one container of that type loading##
## here we unload nodes and containers of things			
#print()
## here we rotate, move, and change text of things
## maybe unnecesserily						
#task_to_send_data_to_datapoint(array_of_data_for_threes)							
#task_to_send_data_to_datapoint(array_of_data_for_threes)							
#task_to_send_data_to_datapoint(array_of_data_for_threes)
## here we send data to a datapoint		
#print(" the await two point o stuff ")
## here we add nodes to a scene tree			
#var datapoint_to_check
#if datapoint_to_check == true:	
# Check if we have sets to create	
# Mutex handling with proper cleanup	
# Check turn number	
# Validate delta####################
# Process turn with proper return status
####################
# JSH Hidden Veil
####################
# JSH Hidden Veil	
#	var first_parent = 
#possible_node_data.get_parent()
#var second_parent = 
#first_parent.get_parent()
#parent_maybe =
# second_parent.get_parent()	
#var parent_maybe = null#	
#if combo_array.size() > 1:
#print(" newly found combo stuff :" ,
# data_to_understand[2], " lets check combo aray again "
#,combo_array[0])						
## second repeat?
## first repeat ?
#print(" newly found combo stuff
#0  and : " , int_of_truth_zero_five)
#print("  newly found combo stuff
# here we can check stuff now we match ",
# int_of_truth_zero_five)				
#print("  newly found combo stuff 
#here we can check stuff now we match ",
# int_of_truth_zero_five)			
#	if combo_array_size == 1:
#pri				
#print(" newly found combo stuff 
#here we can check stuff it is empty")
#print()
## 0.5 S			
#if combo_array_size == 1:
#print(" here we can
# check stuff  
#size 1 ",
# combo_array[0][0] , " 
#new toy : " ,
# data_storage_zero_five[0][0])			
#print(" here we can check 
#int_of_truth_zero_five = 0	
#print(" here we check quick stuff")\
