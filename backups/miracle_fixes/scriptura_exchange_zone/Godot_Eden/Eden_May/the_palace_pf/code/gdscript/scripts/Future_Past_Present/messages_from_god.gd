# message_from_god.gd
extends Node
class_name MessagesSystem
## consts of some random words and lines of text

const first_message = {
	"message_0" :
		"
		what we had touched and worked, atleast before i started editing it too much, as i predict things happening
		## cube cam
		cubecam is working, generates pictures,generates shader picture, can be applied to skybox, shader can be used, to make it bigger, smaller, make it bigger, vertically, horizontally
		so basics were there, for me to pick on, we pushed project, but we need our own file for our cubecam usage
		## trackball camera
		works already, kinda get process from main _process, and so inputs, have also q and e barell roll
		it have quanternion, and i will probably need it too



		### functions i remember working at first, mostly in different project
		## look_at basis, with the same horizontal direction? no weird rotation for 180 degrees, one of nicer functions
		last seen in planets 2d sprites, mimicking 3d planets
		as we care how we se thing, not how that thing sees itself
		## whip out cube cam, make texture file for skybox
		the same project have that function, we must scavange it from my sea of data
		## shader functions, for skybox, apply it, use it, load a shader into it
		it worked nice, the shader have a bug, as it is calculating how far we need to travel to traverse back
		it was not enlarging in perfect way, probably easy fix, but i know i can edit skybox as i wish
		## the mover for camera, and placement for nodes, i made it once, and didnt really store it in nice way
		it is somewhere, in planets project



		### stuff that need to happen soon, so i can touch my keyboard again
		## real system checks, first some easy
		check folders and files
		if we have them, we read some settings file and config file
		from that we compare data with precodded data from banks of data, we have many already
		we create basic and empty dictionaries, get them metadatas, of root state
		we load data into
		make the storage based on my hallucination, based on akashic records, as spirit are whispering
		based on kinda if we repeat, it is fast, if it is new, we kinda check it for you
		damn, hope it can change, and we can creat some brakes and handles, not for ai, not for machine
		but for ai and for machine, so it wont break, from unknow reasons
		we need file parser
		we need functions reader
		cathegorize all functions in project, in specific txt files, in specific folder, with metadatas, we will be able to make nice lists
		with that and my tag system, that works, and i can see, each tag special effects
		nice 3d stuff


		### well my next personality just switched
		## now lets continue from different perspective, my perspective
		i write and write, and i think we can start that, by just what i said
		",
	"message_1":
		"
		📁 scripts
		  📄 UJAH_Texts.gd
		  📄 banks_combiner.gd
		  📄 banks_combiner.gd.uid
		  📄 button.gd
		  📄 button.gd.uid
		  📄 camera_move.gd
		  📄 camera_move.gd.uid
		  📄 camera_mover.gd
		  📄 camera_mover.gd.uid
		  📄 containter.gd
		  📄 containter.gd.uid
		  📄 cursor_pc.gd
		  📄 cursor_pc.gd.uid
		  📄 data_point.gd
		  📄 data_point.gd.uid
		  📄 function_metadata.gd
		  📄 functions_database.gd
		  📄 godot_model.gd
		  📄 godot_timers_system.gd
		  📄 init_function.gd
		  📄 instructions_bank.gd
		  📄 instructions_bank.gd.uid
		  📄 interactions_bank.gd
		  📄 interactions_bank.gd.uid
		  📄 jsh_data_splitter.gd
		  📄 jsh_task_manager.gd
		  📄 line.gd
		  📄 line.gd.uid
		  📄 main.gd
		  📄 main.gd.uid
		  📄 pi_number.gd
		  📄 pi_number_creator.gd
		  📄 project_architecture.gd
		  📄 record_set_manager.gd
		  📄 records_bank.gd
		  📄 records_bank.gd.uid
		  📄 scene_tree_check.gd
		  📄 scene_tree_check.gd.uid
		  📄 scenes_bank.gd
		  📄 scenes_bank.gd.uid
		  📄 settings_bank.gd
		  📄 settings_bank.gd.uid
		  📄 system_check.gd
		  📄 system_interfaces.gd
		  📄 text_label.gd
		  📄 text_label.gd.uid
		  📄 thing (2).gd
		  📄 thing.gd
		  📄 thing.gd.uid
		  📄 thread_pool_manager.gd
		  📄 tree_blueprints_bank.gd",
		
	"message_2": 
		"
		### cleaning_0

		📁 scripts
		  📄 UJAH_Texts.gd
		  📄 banks_combiner.gd
		  📄 button.gd
		  📄 camera_move.gd
		  📄 camera_mover.gd
		  📄 containter.gd
		  📄 cursor_pc.gd
		  📄 data_point.gd
		  📄 function_metadata.gd
		  📄 functions_database.gd
		  📄 godot_model.gd
		  📄 godot_timers_system.gd
		  📄 init_function.gd
		  📄 instructions_bank.gd
		  📄 interactions_bank.gd
		  📄 jsh_data_splitter.gd
		  📄 jsh_task_manager.gd
		  📄 line.gd
		  📄 main.gd
		  📄 pi_number.gd
		  📄 pi_number_creator.gd
		  📄 project_architecture.gd
		  📄 record_set_manager.gd
		  📄 records_bank.gd
		  📄 scene_tree_check.gd
		  📄 scenes_bank.gd
		  📄 scenes_bank.gd.uid
		  📄 settings_bank.gd
		  📄 system_check.gd
		  📄 system_interfaces.gd
		  📄 text_label.gd
		  📄 thing (2).gd
		  📄 thing.gd
		  📄 thread_pool_manager.gd
		  📄 tree_blueprints_bank.gd
		",
		
	"message_3": 
		"
		### cleaning_2
		UJAH_Texts, banks_combiner, button, camera_move, camera_mover, containter, cursor_pc, data_point, function_metadata, functions_database, godot_model, godot_timers_system, init_function, instructions_bank, interactions_bank, jsh_data_splitter, jsh_task_manager, line, main, pi_number, pi_number_creator, project_architecture, record_set_manager, records_bank, scene_tree_check, scenes_bank, settings_bank, system_check, system_interfaces, text_label, thing (2), thing, thread_pool_manager, tree_blueprints_bank
		",
			
	"message_4": 
		"### cleaning_3

		# additionally camera addon file
		camera_move, camera_mover

		# additionally threadpool addon file
		thread_pool_manager, jsh_task_manager


		# the main file, and new project_architecture file
		main, project_architecture

		# records system files so far, so connected to active_record_sets and cached_record_sets
		banks_combiner, instructions_bank, interactions_bank, record_set_manager, records_bank, scenes_bank, thing

		# this needs different sorting, data splitting can happen in raycast, aura stuff, in writing, in two things interacting
		settings_bank, system_interfaces, godot_timers_system, jsh_data_splitter, jsh_task_manager


		# stuff that is happening on a scene tree
		tree_blueprints_bank, containter, data_point, scene_tree_check


		# we didnt touch too much of that too
		button , cursor_pc, line


		# the files we need to make our own kernel like system check, just normal all system clear
		function_metadata, functions_database


		# dunno, we didnt use it yet
		init_function



		# some random files, maybe we will work on them too
		UJAH_Texts, godot_model, pi_number, pi_number_creator


		### now i need some tree of godot scene tree to compare, and connect stuff here too 
		
		# that function didnt work
		# Usage example in _ready() or as a standalone function
		func print_system_metrics():
			var metrics = get_system_metrics()
			print(System Metrics:)
			for key in metrics:
				print(key)
			#print(f{key}: {metrics[key]})
		",
	"message_5":
		"
		###had to change a thing, it given me error
		#
		 shall_execute : 0
		🕒 Quick tick: 2236
		Timer quick_interval completed!
		 ┖╴main
			┠╴@Node@2
			┃  ┠╴@Timer@3
			┃  ┠╴@Timer@4
			┃  ┠╴@Timer@5
			┃  ┠╴@Timer@6
			┃  ┠╴@Timer@7
			┃  ┖╴@Timer@8
			┠╴sphere
			┃  ┠╴pointers
			┃  ┃  ┠╴cursor_mouse
			┃  ┃  ┠╴cursor_left
			┃  ┃  ┠╴cursor_right
			┃  ┃  ┠╴cursor_head
			┃  ┃  ┖╴cursor_body
			┃  ┠╴cameramove
			┃  ┃  ┖╴TrackballCamera
			┃  ┃     ┠╴CameraMover
			┃  ┃     ┖╴light
			┃  ┖╴godot_model
			┠╴WorldEnvironment
			┠╴system_check
			┠╴godot_timers_system
			┃  ┠╴@Timer@9
			┃  ┠╴@Timer@10
			┃  ┠╴@Timer@11
			┃  ┖╴@Timer@12
			┠╴godot_tree_system
			┠╴JSH_records_system
			┠╴JSH_scene_tree_system
			┠╴JSH_database_system
			┠╴JSH_queue_system
			┠╴JSH_turns_system
			┠╴JSH_cache_memory_system
			┠╴JSH_akashic_records
			┠╴JSH_multiplayer_files
			┠╴JSH_mainframe_database
			┠╴JSH_data_splitter
			┖╴JSH_task_manager

		",
	"message_6": 
		"
		
		###first cleaning of data
		 ┖╴main

			┠╴sphere

			┃  ┠╴cameramove
			┃  ┃  ┖╴TrackballCamera

			┠╴WorldEnvironment
			┠╴system_check
			┠╴godot_timers_system
			┠╴godot_tree_system
			┠╴JSH_records_system
			┠╴JSH_scene_tree_system
			┠╴JSH_database_system
			┠╴JSH_queue_system
			┠╴JSH_turns_system
			┠╴JSH_cache_memory_system
			┠╴JSH_akashic_records
			┠╴JSH_multiplayer_files
			┠╴JSH_mainframe_database
			┠╴JSH_data_splitter
			┖╴JSH_task_manager

		",
	"message_7": 
		"
		###second cleaning of data
		main, sphere, cameramove, TrackballCamera, WorldEnvironment, system_check, godot_timers_system, godot_tree_system, JSH_records_system, JSH_scene_tree_system, JSH_database_system, JSH_queue_system, JSH_turns_system, JSH_cache_memory_system, JSH_akashic_records, JSH_multiplayer_files, JSH_mainframe_database, JSH_data_splitter, JSH_task_manager
		",
	"message_8": 
		"
		### third cleaning of data


		## camera and its nodes, have some more
		# additionally camera addon file
		camera_move, camera_mover
		# for node i dunno, sphere so maybe planet generator too?
		Node: sphere, cameramove, TrackballCamera
		## code segments for that from main

		## code segments of scripts


		## threads, threadpool, threading, tasks, queue, turns, information streams
		# additionally threadpool addon file
		thread_pool_manager, jsh_task_manager
		# threadpool stuff, task stuff, queue stuff
		Node: JSH_queue_system, JSH_turns_system, JSH_task_manager
		## code segments for that from main

		## code segments of scripts


		## main node, project architecture, might become faucets of data, in some settings
		# the main file, and new project_architecture file
		main, project_architecture
		# nodes for main, and project architecture
		Node: main, WorldEnvironment, JSH_mainframe_database
		## code segments for that from main

		## code segments of scripts

		## database of files, creation from, created from, will create from, will compare, will evolve, will duplicate and maybe check something
		# records system files so far, so connected to active_record_sets and cached_record_sets
		banks_combiner, instructions_bank, interactions_bank, record_set_manager, records_bank, scenes_bank, thing
		# nodes connected to records system ram, rom, load, cache, archive, forget
		Node: JSH_records_system, JSH_database_system, JSH_cache_memory_system, JSH_akashic_records, JSH_multiplayer_files, JSH_data_splitter
		## code segments for that from main

		## code segments of scripts

		## timers, system check, well i need my own process delta made on timers too so there is less prints about game state
		# this needs different sorting, data splitting can happen in raycast, aura stuff, in writing, in two things interacting
		settings_bank, system_interfaces, godot_timers_system, jsh_data_splitter, jsh_task_manager
		# for nodes i am not sure yet, settings, informations, first run, first run of the day, stuff like that
		Node: system_check, godot_timers_system
		## code segments for that from main

		## code segments of scripts


		## tree, godot tree, my dictionary about that tree, its connections o scripts, functions, database parts
		# stuff that is happening on a scene tree
		tree_blueprints_bank, containter, data_point, scene_tree_check
		# nodes connected to tree stuff
		Node: godot_tree_system, JSH_scene_tree_system
		## code segments for that from main

		## code segments of scripts


		## stuff to do, just in case i would need a button and cursor and some debug line, it happened, but didnt venture further
		# we didnt touch too much of that too
		button , cursor_pc, line
		## code segments for that from main

		## code segments of scripts


		## functions of each file, in gd script, with descriptions, checks, etc
		# the files we need to make our own kernel like system check, just normal all system clear
		function_metadata, functions_database
		## code segments for that from main

		## code segments of scripts

		# dunno, we didnt use it yet
		init_function
		## code segments for that from main

		## code segments of scripts


		## files not really used right now
		# some random files, maybe we will work on them too
		UJAH_Texts, godot_model, pi_number, pi_number_creator
		## code segments for that from main

		## code segments of scripts

		### stuff to do ? connect main segments here, and we will work more on it now
		",
	"message_9":
		"
		### we only have main.gd segmented into data type, can this be enought data?

		# JSH Ethereal Engine
		# JSH Ethereal Engine Initialization process
		# JSH Ethereal Engine Start up
		# JSH Ethereal Engine Repair
		# JSH Ethereal Engine check stuff before we proceed
		# JSH Etheric Download System
		# JSH Etheric Queue
		# JSH Records System
		# JSH Scene Tree
		# JSH Multi Threads
		# JSH Files Management
		# JSH Memories Management
		# JSH Memories Transcription
		# JSH Hidden Veil
		# JSH Projections System
		# JSH Memories Storage
		# JSH Memories Processed
		# JSH Things Creation
		# JSH Scene Tree Add Nodes, Physical and Astral Bodies
		",
	"message_10":
		"
		func _init():
		func _setup_retry_timer():
		func _on_retry_timer_completed(timer_id: String):
		func check_status():
		func check_status_just_timer():
		func _ready():
		func track_task_status(task_id):
		func track_task_completion(task_id):
		func handle_task_timeout(task_id):
		func clear_task_queues():
		func validate_container_state(container_name):
		func attempt_container_repair(container_name, missing_nodes):
		func log_error_state(error_type, details):
		func start_health_checks():
		func check_system_health():
		func prepare_akashic_records():
		func zippy_unzipper_data_center():
		func handle_random_errors():
		func recreate_node_from_records(container_name: String, node_type: String, records: Dictionary):
		func trigger_deep_repair(error_type: String):
		func reanimate_all_handles_and_breaks():
		func unlock_stuck_mutexes():
		func breaks_and_handles_check():
		func before_time_blimp(how_many_finished, how_many_shall_been_finished):
		func queue_pusher_adder(task):
		func handle_creation_task(target_argument):
		func handle_unload_task(target_argument):
		func the_current_state_of_tree(set_name_now, the_state):
		func check_if_first_time(set_name_first, the_current_of_energy):
		func connect_containers(container_name_0, container_name_1):
		func containers_list_creator():
		func containers_states_checker():
		func three_stages_of_creation(data_set_name):
		func check_currently_being_created_sets():
		func process_stages():
		func the_finisher_for_nodes(data_to_be_parsed):
		func jsh_tree_get_node_status_changer(node_path_jsh_tree_status: String, node_name: String, node_to_check: Node):
		func start_timer_of_finito(data_timero):
		func recreate_missing_nodes(array_of_recreation):
		func recreator_of_singular_thing(data_set):
		func unload_node_branch(path_for_node_to_unload, recreation_of_node_data):
		func disable_all_branches_reset_counters(branch_to_disable, container_name_for_array):
		func first_stage_of_creation_(data_set_name_0, sets_to_create_0):
		func second_stage_of_creation_(data_set_name_1, sets_to_create_1):
		func second_impact_for_real(set_to_do_thingy):
		func third_stage_of_creation_(data_set_name_2, sets_to_create_2):
		func third_impact_right_now(data_set_thingiess):
		func fourth_impact_of_creation_(data_set_name_3, sets_to_create_3):
		func fifth_impact_of_creation_(data_set_name_4, sets_to_create_4):
		func fifth_impact_right_now(data_set_nameeeeee):
		func newer_even_function_for_dictionary(name_of_container):
		func container_finder(set_name):
		func tasked_children(node_to_be_added, node_to_be_added_path):
		func task_to_send_data_to_datapoint(data_for_sending):
		func disable_all_branches(branch_to_disable):
		func find_branch_to_unload(thing_path):
		func cache_tree_branch_fully(container_to_unload):
		func cache_branch(branch_name, child_name, branch_part):
		func start_up_scene_tree():
		func print_tree_structure(branch: Dictionary, indent: int = 0):
		func jsh_tree_get_node(node_path_get_node: String) -> Node:
		func create_new_task(function_name: String, data):
		func create_file(array_with_data: Array, lines_amount: int, name_for_file: String):
		func file_finder(file_name, path_to_file, list_of_files, type_of_data):
		func check_folder(folder_path):
		func check_folder_content(directory):  # Take DirAccess as parameter
		func check_settings_file():
		func file_creation(file_content,  path_for_file, name_for_file):
		func setup_settings():
		func find_or_create_eden_directory():
		func create_default_settings(file_path_c_d_s):
		func scan_available_storage():
		func new_function_for_creation_recovery(record_type_now, first_stage_of_creation_now, stage_of_creation_now):
		func initialize_menu(record_type: String):
		func find_record_set(record_type: String) -> Dictionary:
		func find_instructions_set(record_type: String) -> Dictionary:
		func find_scene_frames(record_type: String) -> Dictionary:
		func find_interactions_list(record_type: String) -> Dictionary:
		func recreator(number_to_add, data_to_process, data_set_name, new_name_for_set):
		func find_highest_in_array(numbers: Array) -> int:
		func load_record_set(records_part: String, record_type: String, type_of_data : int, records : Dictionary) -> void:
		func read_records_data(record_set : Dictionary, records_set_name):
		func process_active_records_for_tree(active_records: Dictionary, set_name_to_process : String, container_name_here : String):
		func match_node_type(type: String) -> String:
		func deep_copy_dictionary(original: Dictionary) -> Dictionary:
		func unload_record_set(records_sets_name : String, record_type: String) -> void:
		func cache_data(records_sets_name: String, record_type: String, data, meta_data) -> void:
		func clean_oldest_dataset() -> void:
		func get_dictionary_memory_size(dict: Dictionary) -> int:
		func get_cache_total_size() -> int:
		func get_record_type_id(record_type: String) -> int:
		func the_fourth_dimensional_magic(type_of_operation : String, node : Node, data_of_movement):
		func fifth_dimensional_magic(type_of_unloading : String, node_path_for_unload : String):
		func sixth_dimensional_magic(type_of_function, node_to_call, function_name : String, additional_data = null):
		func call_some_thingy():
		func each_blimp_of_delta():
		func attempt_creation(set_name: String) -> CreationState:
		func _process(delta):
		func whip_out_set_by_its_name(set_name_to_test) -> CreationStatus:
		func process_turn_0(delta: float) -> Dictionary:
		func check_system_state(state_name: String) -> SystemState:
		func set_system_state(state_name: String, new_state: SystemState) -> bool:
		func is_creation_possible() -> bool:
		func record_mistake(mistake_data: Dictionary):
		func update_delta_history(delta: float):
		func check_first_time_status(status_name: String) -> bool:
		func process_creation_request(set_name: String) -> Dictionary:
		func get_data_structure_size(data) -> int:
		func get_jsh(property_name: String):
		func check_memory_state():
		func clean_array(array_name: String):
		func clean_dictionary(dict_name: String):
		func check_thread_status():
		func calculate_time(delta_current, time, hour, minute, second):
		func _input(event: InputEvent):
		func get_ray_points(mouse_position: Vector2):
		func ray_cast_data_preparer(data_ray_cast):
		func multi_threaded_ray_cast(result, to, from):
		func secondary_interaction_after_rc(array_of_data):
		func unload_container(container_to_unload):
		func process_to_unload_records(container_name_to_unload):
		func unload_nodes(array_of_thingiess_that_shall_remain):
		func load_cached_data(data_set: String):
		func load_cached_data_second_impact(data_set: String):
		func interactions_upload_to_datapoint(header_line, information_lines, datapoint):
		func scene_frames_upload_to_datapoint(header_line, information_lines, datapointi, containeri):
		func instructions_analiser(metadata_parts, second_line, third_line, datapoint, container):
		func assign_things_to_datapoint():
		func analise_data(thing_name_, type, data_to_analyze, second_part, group_number, verion_of_thing, information_lines_parsed):
		func create_circle_shape(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
		func generate_circle_points(radius: float, num_points: int) -> Array:
		func create_flat_shape(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
		func create_text_label(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
		func create_array_mesh(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
		func create_textmesh(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
		func create_button(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
		func create_cursor(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
		func create_connection(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
		func create_screen(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
		func create_datapoint(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
		func create_container(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
		func get_spectrum_color(value: float) -> Color:
		func node_creation(node_name, crafted_data, coords, to_rotate, group_number, node_type, path_of_thing):
		func add_collision_to_thing(thing_node, node_type, path_of_thingy, name_of_thingy):
		func the_pretender_printer(node_name: String, node_path_jsh_tree: String, godot_node_type, node_type: String = Node3D):
		",
	"message_11": 
		"
		func test_single_core():
		func test_multi_threaded():
		",
	"message_12":
		"
		metadata
		extends Node3D
		all variants
		var first_start_check : String = pending
		var int_of_stuff_started : int = 0
		var int_of_stuff_finished : int = 0
		var path = D:/Eden
		var file_path
		var files_content
		var folders_content
		var directory_existence = false
		var folders_existence = false
		var files_existence = false
		const DataPointScript = preload(res://scripts/data_point.gd)
		const ContainterScript = preload(res://scripts/container.gd)
		const LineScript = preload(res://scripts/line.gd)
		var ray_distance_set = 20.0
		var viewport
		var mouse_pos
		var camera
		var turn_number_process : int = 0
		var delta_turn_0 : int = 0
		var active_record_sets: Dictionary = {}
		var active_r_s_mut = Mutex.new()
		var cached_record_sets: Dictionary = {}
		var cached_r_s_mutex = Mutex.new()
		var list_of_sets_to_create : Array = []
		var array_mutex_process = Mutex.new()
		var max_nodes_added_per_cycle : int = 369
		var nodes_to_be_added_int : int = 0
		var nodes_to_be_added : Array = []
		var mutex_nodes_to_be_added = Mutex.new()
		var max_data_send_per_cycle : int = 369
		var data_to_be_send : Array = []
		var mutex_data_to_send = Mutex.new()
		var max_movements_per_cycle : int = 369
		var things_to_be_moved : Array = []
		var movmentes_mutex = Mutex.new()
		var max_nodes_to_unload_per_cycle : int = 369
		var nodes_to_be_unloaded : Array = []
		var mutex_for_unloading_nodes = Mutex.new()
		var max_functions_called_per_cycle : int = 369
		var functions_to_be_called : Array = []
		var mutex_function_call = Mutex.new()
		var scene_tree_jsh : Dictionary = {}
		var tree_mutex = Mutex.new()
		var cached_jsh_tree_branches : Dictionary = {}
		var cached_tree_mutex = Mutex.new()
		var status_symbol = {active:●, pending: ○, disabled: ×}
		var cache_timestamps: Dictionary = {}
		var max_cache_size_mb: int = 8
		var available_directiories : Array = []
		@onready var thread_pool = get_node(/root/thread_pool_autoload)
		var curent_queue : Array = [[0], [0], [0], [0], [0], [0], [0], [0], [0], [0]] 
		var the_menace_checker : int = 0
		var menace_mutex = Mutex.new()
		var array_for_counting_finish : Dictionary = {}
		var array_counting_mutex = Mutex.new()
		var download_received : Dictionary = {}
		var upload_to_send : Dictionary = {}
		var current_containers_state : Dictionary = {}
		var mutex_for_container_state = Mutex.new()
		var menace_tricker_checker : int = -2
		var mutex_for_trickery = Mutex.new()
		var unload_queue : Dictionary = {}
		var unload_queue_mutex = Mutex.new()
		var load_queue : Dictionary = {}
		var load_queue_mutex = Mutex.new()
		var mutex_containers = Mutex.new()
		var list_of_containers : Dictionary = {}
		var mutex_singular_l_u = Mutex.new()
		var array_with_no_mutex : Array = []
		var dictionary_of_mistakes : Dictionary = {}
		var dictionary_of_mistakes_mutex = Mutex.new()
		var task_timeouts = {}
		var max_task_duration = 50000
		var task_timestamps = {}
		var task_status = {}
		var creation_can_happen
		var mistakes_of_past
		var deletion_process_can_happen
		var movement_possible
		var edit_possible
		var fsc_status = null
		var fdc_status = null
		var ftc_status = null
		enum SystemState {UNKNOWN = -1,INACTIVE = 0,ACTIVE = 1,BUSY = 2,ERROR = 3}
		var message_of_delta_start
		var array_of_startup_check : Array = []
		signal main_node_signal(place)
		var timer_system: GodotTimersSystem
		",
	"message_13":
		"
		# Core system states that need mutex protection
		var core_states := {
			mutex: Mutex.new(),  # Single mutex for all core states
			states: {
				creation: SystemState.INACTIVE,
				deletion: SystemState.INACTIVE,
				movement: SystemState.INACTIVE,
				edit: SystemState.INACTIVE
			}
		}

		# First-time checks (need mutex as they're initialization flags)
		var initialization_states := {
			mutex: Mutex.new(),
			states: {
				first_start: null,      # fsc_status
				first_delta: null,      # fdc_status
				first_task: null        # ftc_status
			}
		}

		# History tracking (needs mutex for concurrent access)
		var history_tracking := {
			mutex: Mutex.new(),
			mistakes: [],  # mistakes_of_past
			creation_history: [],
			deletion_history: []
		}

		# Time tracking (needs mutex for concurrent updates)
		var time_tracking := {
			mutex: Mutex.new(),
			delta_history: [],
			godot_timers: {},
			last_update: Time.get_ticks_msec()
		}


		# Add properties to track main script memory
		var memory_metadata = {
			arrays: {
				blimp_of_time: [],
				stored_delta_memory: [],
				past_deltas_memories: [],
				array_with_no_mutex: [],
				list_of_sets_to_create: []
			},
			dictionaries: {
				active_record_sets: {},
				cached_record_sets: {},
				scene_tree_jsh: {},
				current_containers_state: {},
				dictionary_of_mistakes: {}
			},
			last_cleanup: Time.get_ticks_msec(),
			cleanup_thresholds: {
				array_max: 1000,  # Max array entries
				dict_max_mb: 50,  # Max dictionary size in MB
				time_between_cleanups: 30000  # 30 seconds
			}
		}
		"
		
}

const tags_from_god = {

	"tags_0" = 
		{
		 
			"JSH Memories Processed" = {},
			"JSH Things Creation" = {},
			"JSH Scene Tree Add Nodes, Physical and Astral Bodies" = {},
			"JSH Ethereal Engine" = {},
			"JSH Ethereal Engine Initialization process" = {},
			"JSH Ethereal Engine Start up" = {},
			"JSH Ethereal Engine Repair" = {},
			"JSH Ethereal Engine check stuff before we proceed" = {},
			"JSH Etheric Download System" = {},
			"JSH Etheric Queue" = {},
			"JSH Records System" = {},
			"JSH Scene Tree" = {},
			"JSH Multi Threads" = {},
			"JSH Files Management" = {},
			"JSH Memories Management" = {},
			"JSH Memories Transcription" = {},
			"JSH Hidden Veil" = {},
			"JSH Projections System" = {},
			"JSH Memories Storage" = {},
			"multi_threads" = {},
			"time_clock" = {},
			"file_storing" = {},
			"file_read" = {},
			"file_create" = {},
			"tree_structure" = {},
			"messages_of_creation" = {},
			"file_structure" = {},
			"functions_structure" = {},
			"singular_function" = {}
		
	}
}

const things = {
	"things" = {},
	"Thing" = {},
	"record" = {},
	"cache" = {},
	"loaded" = {},
	"archived" = {},
	"forbidden" = {},
	"statistic" = {},
	"settings" = {},
	"time" = {},
	"paths" = {},
	"data_channel" = {},
	"data_channels" = {},
	"creations" = {},
	"directories" = {},
	"memories" = {},
	"action" = {},
	"actions" = {},
	"combos" = {}
}

const tasks = {
	"done" = {},
	"pending" = {},
	"failed" = {},
	"archived" = {},
	"working" = {},
	"loadable" = {}
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
