# 🏛️ Main - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# main.gd
# root/main


# signal, onready, const, enum, var
# _init():, _ready():, _input(InputEvent):, _process(delta):

 # ## func
# # var
# const
# class
# call
# class
# task
# thread
# combo command function type
# signal finish from time to time
# ram rom memory archive
# lenght limit in data and splits

#    # int value float string
#    # Array Dictionary
#Tab :|#/\_+{}()()_[{}][]oO0

# split
# space
# distance
# limit frequency

# main node
# main_root

# main.gd

# scripts/main.gd
# res://code/gdscript/scripts/Menu_Keyboard_Console/main.gd

# we need node from list
# we need records from lists
# we need scripts from listsm
# we need shader from list

# we need group viewer and list view too
# selecting more than one node in change
# distance from thing to everything


# what we need is lists
# code/gdscript/scripts/Menu_Keyboard_Console
# code/gdscript/scripts

# code
# scenes
# shader

####################

#
# JSH Ethereal Engine
#

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓ ┓         ┓  ┏┓    •      ┏┓        
#       888  `"Y8888o.   888ooooo888     ┣ ╋┣┓┏┓┏┓┏┓┏┓┃  ┣ ┏┓┏┓┓┏┓┏┓  ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗┛┗┗ ┛ ┗ ┗┻┗  ┗┛┛┗┗┫┗┛┗┗   ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888                          ┛          ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            



extends UniversalBeingBase
var jsh_console
var cmd_terminal
var console
var terminal
var tree
var snake
var apple
var direction_movement
var rotation_move
var command
var current_operational_system
var file_path
var files_content
var folders_content
var viewport
var mouse_pos
var camera
var message_of_delta_start
var scan_result
var creation_can_happen
var mistakes_of_past
var deletion_process_can_happen
var movement_possible
var edit_possible
var edge_table
var tri_table
var acceleration
var target_direction
var max_speed
var lerp_speed
var LRUCache
var chunk_cache
var local_ai
var api_key
var list_of_groups
#
var density_texture := Texture3D.new()
var volume_data := []
var move_quat = Quaternion()
var velocity = Vector3.ZERO

#

var mouse_status : Vector2i = Vector2i(0,0)

#
var current_command = ""
var last_guardian_message = ""
var gemma_context = ""
var gemma_model_path = "gemma-2-2b-it-Q4_K_M.gguf"
var current_reality = "physical"
var path = "D:/Eden"
var database_folder = "akashic_records"
var container_name = "container_"
var line_word = "line"
var datapoint_name = "datapoint"



var deja_vu_counter = 0
#
var max_task_duration = 50000
var ray_distance_set = 20.0
#

var directory_existence = false
var folders_existence = false
var files_existence = false
var gemma_loaded = false
var game_initialized = false
var transition_in_progress = false
#
var command_parser = null
var fsc_status = null
var fdc_status = null
var ftc_status = null
#

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
var data_that_is_send : Dictionary = {}
var data_sending_mutex = Mutex.new()
var data_that_was_send : Dictionary = {}
var data_send_mutex = Mutex.new()
var max_movements_per_cycle : int = 369
var things_to_be_moved : Array = []
var movmentes_mutex = Mutex.new()
var max_nodes_to_unload_per_cycle : int = 369
var nodes_to_be_unloaded : Array = []
var mutex_for_unloading_nodes = Mutex.new()
var max_functions_called_per_cycle : int = 369
var functions_to_be_called : Array = []
var mutex_function_call = Mutex.new()
var max_additionals_per_cycle : int = 369
var additionals_to_be_called : Array = []
var mutex_additionals_call = Mutex.new()
var max_actions_per_cycle : int = 369
var actions_to_be_called : Array = []
var mutex_actions = Mutex.new()
var max_messages_per_cycle : int = 369
var messages_to_be_called : Array = []
var mutex_messages_call = Mutex.new()
var scene_tree_jsh : Dictionary = {}
var tree_mutex = Mutex.new()
var cached_jsh_tree_branches : Dictionary = {}
var cached_tree_mutex = Mutex.new()
var dictionary_of_mistakes : Dictionary = {}
var dictionary_of_mistakes_mutex = Mutex.new()
var the_menace_checker : int = 0
var menace_mutex = Mutex.new()
var array_for_counting_finish : Dictionary = {}
var array_counting_mutex = Mutex.new()
var current_containers_state : Dictionary = {}
var mutex_for_container_state = Mutex.new()
var unload_queue : Dictionary = {}
var unload_queue_mutex = Mutex.new()
var load_queue : Dictionary = {}
var load_queue_mutex = Mutex.new()
var menace_tricker_checker : int = -2
var mutex_for_trickery = Mutex.new()
var list_of_containers : Dictionary = {}
var mutex_containers = Mutex.new()
var mutex_singular_l_u = Mutex.new()
#
var player_memory = {}
var entity_states = {}


var test_results: Dictionary = {}
var download_received : Dictionary = {}
var upload_to_send : Dictionary = {}
var cache_timestamps: Dictionary = {}
var task_timeouts: Dictionary = {}
var task_timestamps: Dictionary = {}
var task_status: Dictionary = {}
#
var thread_test_data = []
var command_history = []

var first_run_prints : Array = []
var first_run_numbers : Array = []
var init_array : Array = []
var init_array_int : Array = []
var blimp_of_time : Array = []
var previous_blimp_of_time : Array = []
var past_deltas_memories : Array = []
var stored_delta_memory : Array = []
var array_of_startup_check : Array = []
var check_settings_data : Array = []
var array_with_no_mutex : Array = []
var available_directiories : Array = []
var combo_array : Array = []
var _highlighted_colliders : Array = []
var data_storage_comparer : Array = []
var preparer_of_data : Array = []
var test_of_set_list_flow : Array = []
var data_storage_zero_five : Array = []

var curent_queue : Array = [[0], [0], [0], [0], [0], [0], [0], [0], [0], [0]] 
#

var int_of_stuff_started : int = 0
var int_of_stuff_finished : int = 0
var turn_number_process : int = 0
var delta_turn_0 : int = 0
var max_cache_size_mb: int = 8
var some_kind_of_issue : int = 0
var just_one_try : int = 0
var int_of_truth_zero_five : int = 0
var reality_mutex = Mutex.new()
var memory_mutex = Mutex.new()
var first_start_check : String = "pending"
var timer_system: GodotTimersSystem
@onready var gemma_ai = get_node("JSH_gemma_integration")


@onready var main_node = get_node("/root/main")
@onready var records_system = get_node_or_null("/root/main/JSH_records_system")
var JSH_records_system = records_system

@onready var data_splitter = get_node("/root/main/JSH_data_splitter")
@onready var task_manager = get_node("/root/main/JSH_task_manager")
#@onready var JSH_records_system = get_node("JSH_records_system")
@onready var JSH_Threads = get_node("/root/main/JSH_ThreadPool_Manager")
@onready var JSH_system_check = get_node("/root/main/system_check")



@onready var thread_pool = get_node("/root/thread_pool_autoload")




# singular not var

const MAX_RAM_CHUNKS = 500
const CHUNK_SIZE := 32
const ISO_LEVEL := 0.5

const DataPointScript = preload("res://scripts/jsh_framework/core/data_point.gd") 
const ContainterScript = preload("res://scripts/jsh_framework/core/container.gd")
const LineScript = preload("res://scripts/jsh_framework/core/line.gd")

## nodes in main
## scripts in main
## missing many core components
# shaders
# scripts : console, functions metadata, branches metadata
# new scripts, keyboard, key, planet, galaxy, star, point
# classes as lists maybe?
# 

const REALITY_STATES = ["physical", "digital", "astral"]
const DIMENSIONAL_MAGICS = ["first", "fourth", "fifth", "sixth", "seventh", "eighth"]

const AI_MODEL_PATH = "res://models/gemma-2-2b-it-Q4_K_M.gguf"

const AI_MODEL_SIZE_MB = 1500  
const MAX_MEMORY_ENTRIES = 100  

const VERSION = "1.0.0"
#

#
signal command_processed(command, result)
# TODO: Signal not currently used - may be needed for future node communication
# signal main_node_signal(place)
signal reality_shifted(old_reality, new_reality)
signal guardian_spawned(guardian_type, location)
signal entity_created(entity_type, entity_id)
signal entity_transformed(entity_id, new_form)
signal deja_vu_triggered(trigger_data)
#

# var lists, more than one thing in one
# here we had circles for on and off
# triangle was for shift of key size and another data
# do we have square

#

var status_symbol = {
	"active": "●",
	"pending": "○", 
	"disabled": "×"
}

var word_params := {
	"letter_scale": 0.1,
	"word_radius": 2.0,
	"time_phase": 0.0
}



var tree_data = {
	"snapshot": "", 
	"structure": {},
	"timestamp": 0,
	"node_count": 0
}



var system_readiness = {
	"mutexes": false,
	"threads": false,
	"records": false
}

var system_checks = {
	"creation": "is_creation_possible",
	"movement": "movement_possible",
	"deletion": "deletion_process_can_happen"
}




enum SystemState {
	UNKNOWN = -1,
	INACTIVE = 0,
	ACTIVE = 1,
	BUSY = 2,
	ERROR = 3
}
enum CreationStatus {
	ERROR = -1,
	SUCCESS = 0,
	PENDING = 1,
	INVALID_INPUT = 2,
	LOCKED = 3
}
enum CreationState {
	INACTIVE = -1,
	POSSIBLE = 0,
	IN_PROGRESS = 1,
	LOCKED = 2,
	ERROR = 3
}
#

var config = {
	"thread_allocation": {
		"ai_thread_percent": 40,
		"physics_thread_percent": 20,
		"entity_thread_percent": 20,
		"reality_thread_percent": 10,
		"memory_thread_percent": 10
	},
	"reality": {
		"transition_duration": 1.0,
		"glitch_intensity": 0.25,
		"auto_shift_count": 3
	},
	"ai": {
		"context_size": 1024,
		"max_tokens": 256,
		"temperature": 0.7
	}
}




var memory_metadata = {
	"arrays": {
		"blimp_of_time": [],
		"stored_delta_memory": [],
		"past_deltas_memories": [],
		"array_with_no_mutex": [],
		"list_of_sets_to_create": []
	},
	"dictionaries": {
		"active_record_sets": {},
		"cached_record_sets": {},
		"scene_tree_jsh": {},
		"current_containers_state": {},
		"dictionary_of_mistakes": {}
	},
	"last_cleanup": Time.get_ticks_msec(),
	"cleanup_thresholds": {
		"array_max": 1000, 
		"dict_max_mb": 50,  
		"time_between_cleanups": 30000  
	}
}



var core_states := {
	"mutex": Mutex.new(), 
	"states": {
		"creation": SystemState.INACTIVE,
		"deletion": SystemState.INACTIVE,
		"movement": SystemState.INACTIVE,
		"edit": SystemState.INACTIVE
	}
}

var initialization_states := {
	"mutex": Mutex.new(),
	"states": {
		"first_start": null,
		"first_delta": null, 
		"first_task": null  
	}
}

var history_tracking := {
	"mutex": Mutex.new(),
	"mistakes": [],
	"creation_history": [],
	"deletion_history": []
}

var time_tracking := {
	"mutex": Mutex.new(),
	"delta_history": [],
	"godot_timers": {},
	"last_update": Time.get_ticks_msec()
}

var system_states = {
	"creation": {
		"mutex": Mutex.new(),
		"state": SystemState.INACTIVE,
		"pending_sets": [],
		"active_sets": []
	}
}


var system_states_0 := {
	"mutex": Mutex.new(),
	"core_systems": {
		"system_check": {
			"node": null,
			"ready": false,
			"last_verified": 0
		},
		"timers": {
			"node": null,
			"ready": false,
			"last_verified": 0
		},
		"tree": {
			"node": null,
			"ready": false,
			"last_verified": 0
		},
		"records": {
			"node": null,
			"ready": false,
			"last_verified": 0
		},
	}
}

var verification_data := {
	"mutex": Mutex.new(),
	"current_phase": 0,
	"phases": {
		0: "system_initialization",
		1: "node_verification", 
		2: "script_connections",
		3: "mutex_verification",
		4: "memory_check",
		5: "final_verification"
	},
	"logs": [],
	"errors": []
}
#

class CommandParser:
	var commands = {}
	var parent
	func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	super.pentagon_init()
		parent = parent_node

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
	func register_command(cmd_name, target, method_name):
		commands[cmd_name] = {"target": target, "method": method_name}
	func parse(raw_input: String) -> Dictionary:
		var parts = raw_input.split(" ", false)
		if parts.size() == 0:
			return {"success": false, "message": "Empty command"}
		var cmd = parts[0].to_lower()
		if not commands.has(cmd):
			return {"success": false, "message": "Unknown command: " + cmd}
		var args = []
		if parts.size() > 1:
			args = parts.slice(1, parts.size() - 1)
		return call_command(cmd, args)
	func call_command(cmd: String, args: Array) -> Dictionary:
		var command_data = commands[cmd]
		return command_data.target.call(command_data.method, args)
#


#
# JSH Initialize Ethereal Engine
#

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┳  • •  ┓•     ┏┓ ┓         ┓  ┏┓    •    
#       888  `"Y8888o.   888ooooo888     ┃┏┓┓╋┓┏┓┃┓┓┏┓  ┣ ╋┣┓┏┓┏┓┏┓┏┓┃  ┣ ┏┓┏┓┓┏┓┏┓
#       888      `"Y88b  888     888     ┻┛┗┗┗┗┗┻┗┗┗┗   ┗┛┗┛┗┗ ┛ ┗ ┗┻┗  ┗┛┛┗┗┫┗┛┗┗ 
#       888 oo     .d8P  888     888                                         ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            

#
# JSH Initialize Ethereal Engine
# spaces words commands terminal
# command vindow text


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	super.pentagon_init()
	print("\n🌱 [INIT] Starting initialization...\n")
	print(" main.gd print tree pretty init ")
	print_tree_pretty()
	print(" main.gd print tree pretty should end here")
	var status_threads_int = -1
	var status_threads = check_status_just_timer()
	if status_threads:
		status_threads_int = 1
	else:
		status_threads_int = 0
	init_array_int.append(status_threads_int)
	prepare_akashic_records_init()
	setup_system_checks()
	print("\n✅ [INIT] Initialization complete. Waiting for _ready()...\n")

#
# JSH Start Ethereal Engine
#

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓        ┏┓ ┓         ┓  ┏┓    •    
#       888  `"Y8888o.   888ooooo888     ┗┓╋┏┓┏┓╋  ┣ ╋┣┓┏┓┏┓┏┓┏┓┃  ┣ ┏┓┏┓┓┏┓┏┓
#       888      `"Y88b  888     888     ┗┛┗┗┻┛ ┗  ┗┛┗┛┗┗ ┛ ┗ ┗┻┗  ┗┛┛┗┗┫┗┛┗┗ 
#       888 oo     .d8P  888     888                                    ┛     
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            

#
# JSH Start Ethereal Engine


func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	print("\n🚀 [READY] Beginning full system setup...\n")
	
	var debug_build_info : int = -1
	var debug_build_name : String = "no build detected"
	if OS.is_debug_build():
		print("Scanning in debug mode, OS.is_debug_build()")
		debug_build_info = 1
		debug_build_name = "debug_build"
	else: 
		print(" os is not in debug build ")
		debug_build_info = 0
		debug_build_name = "normal_build"
	first_run_numbers.append(debug_build_info)
	first_run_prints.append(debug_build_name)
	var os_int_fr : int = -1
	current_operational_system = OS.get_name()
	if current_operational_system:
		os_int_fr = 1
		first_run_prints.append(current_operational_system)
	else:
		os_int_fr = 0
		first_run_prints.append("error")
	first_run_numbers.append(os_int_fr)
	
	print("🖥️ Running on:", current_operational_system)
	
	var main_file_state : int = -1
	var file = FileAccess.open("res://main.gd", FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var structure = task_manager.parse_code_structure(content)
		task_manager.create_tasks_from_structure(structure)
		print(task_manager.generate_task_report())
		main_file_state = 1
		first_run_prints.append([content, structure])
	else:
		main_file_state = 0
		first_run_prints.append("error")
	first_run_numbers.append(main_file_state)
	var res_scan_int : int = -1
	
	print("\n🔍 Scanning res:// directory...\n")
	
	var res_scan = scan_res_directory()
	
	print("\n✅ Scan Completed. Files & Directories Indexed.\n")
	
	if res_scan:
		res_scan_int = 1
		first_run_prints.append(res_scan)
	else:
		res_scan_int = 0
		first_run_prints.append("error")
	first_run_numbers.append(res_scan_int)
	
	print("\n🌳 Scene Tree Before Adjustments:")
	
	print_tree_pretty()
	
	print(" maybe again")
	
	var tree_state_int : int = -1
	var tree_state = capture_tree_state()
	if tree_state:
		tree_state_int = 1
		first_run_prints.append(tree_state)
	else:
		tree_state_int = 0
		first_run_prints.append("error")
	first_run_numbers.append(tree_state_int)
	var eden_D = scan_eden_directory()
	var eden_d_i : int = -1
	if eden_D:
		eden_d_i = 1
		first_run_prints.append(eden_D)
	else:
		eden_d_i = 0
		first_run_prints.append("error")
	first_run_numbers.append(eden_d_i)
	var eden_b_i : int = -1
	var eden_B = scan_eden_directory("D:/Eden_Backup") 
	if eden_B:
		eden_b_i = 1
		first_run_prints.append(eden_B)
	else:
		eden_b_i = 0
		first_run_prints.append("error")
	first_run_numbers.append(eden_b_i)
	print("\n🔄 Delta System State:", message_of_delta_start)
	thread_pool.connect("task_discarded", func(task):
		queue_pusher_adder(task)
		int_of_stuff_finished += 1
	)
	thread_pool.connect("task_started", func(task):
		track_task_status(task)
		int_of_stuff_started += 1
	)
	
	print("\n🎬 Starting Scene Setup...\n")
	
	var threads_0 = check_status_just_timer()
	
	var settings_check_int : int = -1
	var type_of_file = "settings"
	var settings_check = check_settings_file(type_of_file)
	if settings_check:
		settings_check_int = 1
		first_run_prints.append(settings_check)
	else:
		settings_check_int = 0
		first_run_prints.append("error")
	first_run_numbers.append(settings_check_int)
	
	var _modules_check_int : int = -1
	var _type_of_file_m = "modules"
	var module_check = check_settings_file(_type_of_file_m)
	#var modules_check = check_modules_file()
	
	
	mouse_pos = get_viewport().get_mouse_position()
	var camera_check_int : int = -1
	camera = get_viewport().get_camera_3d()
	if camera:
		camera_check_int = 1
		first_run_prints.append(camera)
	else:
		camera_check_int = 0
		first_run_prints.append("error")
	first_run_numbers.append(camera_check_int)
	var viewport_check_int : int = -1
	viewport = get_viewport()
	if viewport:
		viewport_check_int = 1
		first_run_prints.append(viewport)
	else:
		viewport_check_int = 0
		first_run_prints.append("error")
	first_run_numbers.append(viewport_check_int)
	var threads_1 = check_status_just_timer()
	start_up_scene_tree()
	var int_for_jsh_tree : int = -1
	var tree_jsh_status_start = check_tree_branches()
	if tree_jsh_status_start == true:
		int_for_jsh_tree = 1
		first_run_prints.append(tree_jsh_status_start)
	elif tree_jsh_status_start == false:
		int_for_jsh_tree = 0
		first_run_prints.append("just main root")
	elif tree_jsh_status_start == null:
		int_for_jsh_tree = -2
		first_run_prints.append("main root missing")
	else:
		int_for_jsh_tree = -3
		first_run_prints.append("fatal kurwa error")
	first_run_numbers.append(int_for_jsh_tree)
	var threads_2 = check_status_just_timer()
	##
	
	print(" we gotta figure out the time stuff, clocks, watches, ticks and tacks")
	
	var timer_system_int : int = -1
	timer_system = GodotTimersSystem.new()
	if timer_system:
		add_child(timer_system)
		_setup_retry_timer()  
		timer_system_int = 1
		first_run_prints.append(timer_system)
	else:
		timer_system_int = 0
		first_run_prints.append("error")
	first_run_numbers.append(timer_system_int)
	var thread_status_int : int = -1
	var threads_state = check_three_tries_for_threads(threads_0, threads_1, threads_2)
	if threads_state:
		thread_status_int = 1
		first_run_prints.append(threads_state)
	else:
		thread_status_int = 0
		first_run_prints.append("error")
	first_run_numbers.append(thread_status_int)
	test_single_core()
	test_multi_threaded()
	timer_system.connect("interval_tick", Callable(self, "_on_interval_tick"))
	
	var target_directory = "D:/Eden_Backup/all scripts files 13.02.25" 
	
	print("\n📂 Scanning directory: " + target_directory)
	#var target_directory = "D:/Eden_Backup/all scripts files 13.02.25" 
	var results = scan_directory_with_sizes(target_directory)
	save_file_list_text(results, "D:/Eden/files/file_list.txt", target_directory)

	initialize_base_textures()


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
# JSH Ethereal Engine tests
# need asci for _input
#

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	_input_event(event)
#




#
func _input_event(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				mouse_status.x = 1
				var _current_ray_points = get_ray_points(event.position)
			else:
				mouse_status.x = 0
				process_ray_cast(event.position)
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				mouse_status.y = 1
			else:
				mouse_status.y = 0
	if event is InputEventMouseMotion:
		pass
		process_ray_cast(event.position)
	
	camera.input(event)
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
# JSH Ethereal Engine process

#
# need asci for _process



func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	camera.process(delta)
	camera.process_roll(delta)
	
	each_blimp_of_delta()
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pass
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		pass
	
	process_system()
#


# Physics processing integrated into Pentagon Architecture
func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Physics processing logic
	var _camera_forward = -camera.global_transform.basis.z
	var _target_quat = Quaternion(camera.global_transform.basis)
	# TODO: Complete move_quat statement or remove if not needed
	# move_quat
	if velocity:
		velocity = velocity.lerp(target_direction * max_speed, delta * lerp_speed)
		position += velocity * delta

#
func process_system():
	process_system_0()
	process_system_1()
	process_system_2()
	process_system_3()
	process_system_4()
	process_system_5()
	process_system_6()
	process_system_7()
	process_system_8()
	process_system_9()
#

#
func each_blimp_of_delta():
	
	var each_blimp_time = Time.get_ticks_msec()
	stored_delta_memory.append(each_blimp_time)
	if stored_delta_memory.size() > 9:
		var _last_delta_to_forget = stored_delta_memory.pop_front()
#

# from here we change and add later in list of functions that check or number of frequency in what size from 1 to 0 99 max, we have now 
# two ## in one packed # data to split and it is kinda the same and empty data, number now two of them





#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓ ┓         ┓  ┏┳┓•       ┏┓         
#       888  `"Y8888o.   888ooooo888     ┣ ╋┣┓┏┓┏┓┏┓┏┓┃   ┃ ┓┏┳┓┏┓  ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗┛┗┗ ┛ ┗ ┗┻┗   ┻ ┗┛┗┗┗   ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888                                   ┛       
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            

#

func update_delta_history(delta: float):
	time_tracking.mutex.lock()
	time_tracking.delta_history.append({
		"time": Time.get_ticks_msec(),
		"delta": delta
	})
	time_tracking.last_update = Time.get_ticks_msec()
	time_tracking.mutex.unlock()

func calculate_time(_delta_current, time, _hour, _minute, _second):
	time = Time.get_ticks_msec()
	var time_0 = time / 1000.0
	var all_seconds : int = time / 1000
	var minutes : int = all_seconds / 60.0
	var remaining_seconds : int = all_seconds % 60
	print("Time: ", minutes, " minutes and ", remaining_seconds, " seconds")

func before_time_blimp(_how_many_finished, _how_many_shall_been_finished):
	var before_blimp_time = Time.get_ticks_msec()
	return before_blimp_time

func blimp_time_for_some_reason():
	print(" check basic if we allign with prophecies of wisest spirits, do we unlock before it is too late ")



# combos

# commands lines scripts strings combo
# cmd termninal computer

func _on_interval_tick(interval_name: String):
	match interval_name:
		"quick":
			print("🕒 Quick tick: ", Time.get_ticks_msec())
			check_quick_functions()
		"short":
			print("⏱️ Short tick: ", Time.get_ticks_msec())
			check_short_functions()
		"medium":
			print("⏰ Medium tick: ", Time.get_ticks_msec())
		"long":
			print("🕓 Long tick: ", Time.get_ticks_msec())


# this is time stuff that worked

func track_delta_timing(_validation):
	print("blink")

func _setup_retry_timer():
	timer_system.timer_completed.connect(_on_retry_timer_completed)


func _on_retry_timer_completed(timer_id: String):
	if timer_id == "retry_timer":
		print("Retrying operation after timer completion")
		prepare_akashic_records()

#
# JSH Ethereal Task System
#

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓ ┓         ┓  ┏┳┓   ┓   ┏┓         
#       888  `"Y8888o.   888ooooo888     ┣ ╋┣┓┏┓┏┓┏┓┏┓┃   ┃ ┏┓┏┃┏  ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗┛┗┗ ┛ ┗ ┗┻┗   ┻ ┗┻┛┛┗  ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888                                  ┛       
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            

#

# Add Task

#                     ,,        ,,                                         
#       db          `7MM      `7MM      MMP""MM""YMM             `7MM      
#      ;MM:           MM        MM      P'   MM   `7               MM      
#     ,V^MM.     ,M""bMM   ,M""bMM           MM   ,6"Yb.  ,pP"Ybd  MM  ,MP'
#    ,M  `MM   ,AP    MM ,AP    MM           MM  8)   MM  8I   `"  MM ;Y   
#    AbmmmqMA  8MI    MM 8MI    MM           MM   ,pm9MM  `YMMMa.  MM;Mm   
#   A'     VML `Mb    MM `Mb    MM           MM  8M   MM  L.   I8  MM `Mb. 
# .AMA.   .AMMA.`Wbmd"MML.`Wbmd"MML.       .JMML.`Moo9^Yo.M9mmmP'.JMML. YA.

#
# Add Task

func ready_for_once():
	if just_one_try == 0:
		just_one_try = 1
		create_new_task("three_stages_of_creation", "base")
		create_new_task("three_stages_of_creation", "menu")
		return true
	else:
		return false

func process_pending_sets():
	var creation_state = get_system_state("creation")
	if creation_state.is_empty():
		return false
	creation_state["mutex"].lock()
	var can_process_sets = true
	if creation_state["pending_sets"].size() > 0:
		for set_data in creation_state["pending_sets"]:
			if check_system_function("creation"):
				create_new_task("three_stages_of_creation", set_data)
				creation_state["active_sets"].append(set_data)
			else:
				can_process_sets = false
				break
	creation_state["mutex"].unlock()
	return can_process_sets

func handle_creation_task(target_argument):
	var type_of_state : int = 1
	print(" handle_creation_task : ", target_argument)
	load_queue_mutex.lock()
	var can_proceed = true
	if load_queue.has(target_argument):
		if load_queue[target_argument].has("metadata"):
			if load_queue[target_argument]["metadata"].has("status"):
				if load_queue[target_argument]["metadata"]["status"] != 0:
					can_proceed = false
	load_queue_mutex.unlock()
	if can_proceed:
		the_current_state_of_tree(target_argument, type_of_state)
		mutex_for_trickery.lock()
		menace_tricker_checker = 1
		mutex_for_trickery.unlock()
	else:
		dictionary_of_mistakes_mutex.lock()
		if !dictionary_of_mistakes.has(target_argument):
			dictionary_of_mistakes[target_argument] = {
				"status": "pending",
				"counter": int(1),
				"last_attempt": Time.get_ticks_msec()
			}
		dictionary_of_mistakes_mutex.unlock()

func handle_unload_task(target_argument):
	var type_of_state : int = -1
	var the_shorter_set = target_argument.substr(0, str(target_argument).length() - 10)
	print(" handle_unload_task : ", target_argument, " shortened to: ", the_shorter_set)
	unload_queue_mutex.lock()
	if !unload_queue.has(target_argument):
		unload_queue[target_argument] = {
			"metadata": {
				"status": "pending",
				"tries": 0,
				"last_attempt": Time.get_ticks_msec()
			}
		}
	else:
		unload_queue[target_argument]["metadata"]["tries"] += 1
		unload_queue[target_argument]["metadata"]["last_attempt"] = Time.get_ticks_msec()
	unload_queue_mutex.unlock()
	the_current_state_of_tree(the_shorter_set, type_of_state)
	mutex_for_trickery.lock()
	menace_tricker_checker = 1
	mutex_for_trickery.unlock()
	if unload_queue[target_argument]["metadata"]["tries"] > 3:
		dictionary_of_mistakes_mutex.lock()
		if !dictionary_of_mistakes.has(target_argument):
			dictionary_of_mistakes[target_argument] = {
				"status": "stuck_unload",
				"counter": int(1),
				"last_attempt": Time.get_ticks_msec()
			}
		dictionary_of_mistakes_mutex.unlock()

# Check Task

#               ,,                                                                        
#   .g8"""bgd `7MM                       `7MM          MMP""MM""YMM             `7MM      
# .dP'     `M   MM                         MM          P'   MM   `7               MM      
# dM'       `   MMpMMMb.  .gP"Ya   ,p6"bo  MM  ,MP'         MM   ,6"Yb.  ,pP"Ybd  MM  ,MP'
# MM            MM    MM ,M'   Yb 6M'  OO  MM ;Y            MM  8)   MM  8I   `"  MM ;Y   
# MM.           MM    MM 8M"""""" 8M       MM;Mm            MM   ,pm9MM  `YMMMa.  MM;Mm   
# `Mb.     ,'   MM    MM YM.    , YM.    , MM `Mb.          MM  8M   MM  L.   I8  MM `Mb. 
#   `"bmmmd'  .JMML  JMML.`Mbmmd'  YMbmd'.JMML. YA.       .JMML.`Moo9^Yo.M9mmmP'.JMML. YA.
#

func check_status():
	var stuck_status = check_thread_status()
	
	if stuck_status == "error":
		print(" something went wrong, starting retry timer")
		if timer_system:
			if timer_system.is_timer_active("retry_timer"):
				print("Retry timer already running...")
				return
			timer_system.create_timer("retry_timer", 5.0)
			timer_system.start_timer("retry_timer")
			var current_attempt = 1
			timer_system.timer_completed.connect(
				func(timer_id): 
					if timer_id == "retry_timer":
						var local_attempt = current_attempt
						local_attempt += 1
						print("Retry attempt: ", local_attempt)
			)
		else:
			push_error("Timer system not initialized!")
	elif stuck_status == "working":
		var updated_message = check_thread_status_type()
		print(" stuck status after working : ", updated_message)
	print(" stuff to do :: mutex statuses : ", breaks_and_handles_check(), 
		  ", stuck_status threads status : ", stuck_status, 
		  " and main sets to create", array_of_startup_check)

func check_status_just_timer():
	var stuck_status = check_thread_status()
	if stuck_status is String:
		print(" stuck status it is string ")
		if stuck_status == "error":
			print(" stuck status something went wrong, starting verified timer " , stuck_status)
			if timer_system:
				var start_time = Time.get_ticks_msec()
				timer_system.create_timer("retry_timer", 5.0)
				timer_system.start_timer("retry_timer")
				print(" stuck status Timer started at OS time: ", start_time)
		else:
			print(" stuck status it is not error, it is :::" , stuck_status)
			var updated_message = check_thread_status_type()
			print(" stuck status ::: " , updated_message, " :::: " , stuck_status)
			return stuck_status
	if stuck_status is int:
		print(" stuck status is int " , stuck_status)
		return str(stuck_status)

func track_task_status(task_id):
	task_status[task_id] = {
		"start_time": Time.get_ticks_msec(),
		"status": "pending",
		"retries": 0,
		"error_count": 0
	}

func track_task_completion(task_id):
	task_timeouts[task_id] = {
		"start_time": Time.get_ticks_msec(),
		"status": "pending"
	}
	await get_tree().create_timer(max_task_duration / 1000.0).timeout
	if task_timeouts.has(task_id) and task_timeouts[task_id]["status"] == "pending":
		handle_task_timeout(task_id)

func handle_task_timeout(task_id):
	var _task_data = task_status[task_id]
	

# Modify Task

#                                 ,,    ,,      ,...                                                
# `7MMM.     ,MMF'              `7MM    db    .d' ""             MMP""MM""YMM             `7MM      
#   MMMb    dPMM                  MM          dM`                P'   MM   `7               MM      
#   M YM   ,M MM  ,pW"Wq.    ,M""bMM  `7MM   mMMmm`7M'   `MF'         MM   ,6"Yb.  ,pP"Ybd  MM  ,MP'
#   M  Mb  M' MM 6W'   `Wb ,AP    MM    MM    MM    VA   ,V           MM  8)   MM  8I   `"  MM ;Y   
#   M  YM.P'  MM 8M     M8 8MI    MM    MM    MM     VA ,V            MM   ,pm9MM  `YMMMa.  MM;Mm   
#   M  `YM'   MM YA.   ,A9 `Mb    MM    MM    MM      VVV             MM  8M   MM  L.   I8  MM `Mb. 
# .JML. `'  .JMML.`Ybmd9'   `Wbmd"MML..JMML..JMML.    ,V            .JMML.`Moo9^Yo.M9mmmP'.JMML. YA.
#                                                    ,V                                             
#                                                 OOb"


# Store Task
#
#  .M"""bgd mm                               MMP""MM""YMM             `7MM      
# ,MI    "Y MM                               P'   MM   `7               MM      
# `MMb.   mmMMmm ,pW"Wq.`7Mb,od8 .gP"Ya           MM   ,6"Yb.  ,pP"Ybd  MM  ,MP'
#   `YMMNq. MM  6W'   `Wb MM' "',M'   Yb          MM  8)   MM  8I   `"  MM ;Y   
# .     `MM MM  8M     M8 MM    8M""""""          MM   ,pm9MM  `YMMMa.  MM;Mm   
# Mb     dM MM  YA.   ,A9 MM    YM.    ,          MM  8M   MM  L.   I8  MM `Mb. 
# P"Ybmmd"  `Mbmo`Ybmd9'.JMML.   `Mbmmd'        .JMML.`Moo9^Yo.M9mmmP'.JMML. YA.

#

#               ,,                                                                       
#       db     *MM                           mm       MMP""MM""YMM             `7MM      
#      ;MM:     MM                           MM       P'   MM   `7               MM      
#     ,V^MM.    MM,dMMb.   ,pW"Wq.`7Mb,od8 mmMMmm          MM   ,6"Yb.  ,pP"Ybd  MM  ,MP'
#    ,M  `MM    MM    `Mb 6W'   `Wb MM' "'   MM            MM  8)   MM  8I   `"  MM ;Y   
#    AbmmmqMA   MM     M8 8M     M8 MM       MM            MM   ,pm9MM  `YMMMa.  MM;Mm   
#   A'     VML  MM.   ,M9 YA.   ,A9 MM       MM            MM  8M   MM  L.   I8  MM `Mb. 
# .AMA.   .AMMA.P^YbmdP'   `Ybmd9'.JMML.     `Mbmo       .JMML.`Moo9^Yo.M9mmmP'.JMML. YA.

#

func clear_task_queues():
	print(" hm ")


# JSH Ethereal Downloads System
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓ ┓         ┓  ┳┓       ┓     ┓   ┏┓         
#       888  `"Y8888o.   888ooooo888     ┣ ╋┣┓┏┓┏┓┏┓┏┓┃  ┃┃┏┓┓┏┏┏┓┃┏┓┏┓┏┫┏  ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗┛┗┗ ┛ ┗ ┗┻┗  ┻┛┗┛┗┻┛┛┗┗┗┛┗┻┗┻┛  ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888                                           ┛       
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

																								

#                                        ,,                                                            
# `7MM"""Mq.                             db                        `7MM"""Yb.            mm            
#   MM   `MM.                                                        MM    `Yb.          MM            
#   MM   ,M9  .gP"Ya   ,p6"bo   .gP"Ya `7MM `7M'   `MF'.gP"Ya        MM     `Mb  ,6"Yb.mmMMmm  ,6"Yb.  
#   MMmmdM9  ,M'   Yb 6M'  OO  ,M'   Yb  MM   VA   ,V ,M'   Yb       MM      MM 8)   MM  MM   8)   MM  
#   MM  YM.  8M"""""" 8M       8M""""""  MM    VA ,V  8M""""""       MM     ,MP  ,pm9MM  MM    ,pm9MM  
#   MM   `Mb.YM.    , YM.    , YM.    ,  MM     VVV   YM.    ,       MM    ,dP' 8M   MM  MM   8M   MM  
# .JMML. .JMM.`Mbmmd'  YMbmd'   `Mbmmd'.JMML.    W     `Mbmmd'     .JMMmmmdP'   `Moo9^Yo.`Mbmo`Moo9^Yo.

#

func first_dimensional_magic(type_of_action_to_do : String, datapoint_node : Node, additional_node : Node = null):
	var first_dimensional_data_array : Array = []
	first_dimensional_data_array.append(type_of_action_to_do)
	first_dimensional_data_array.append(datapoint_node)
	first_dimensional_data_array.append(additional_node)
	mutex_actions.lock()
	actions_to_be_called.append(first_dimensional_data_array)
	mutex_actions.unlock()

func the_fourth_dimensional_magic(type_of_operation : String, node : Node, data_of_movement):
	var data_for_movement : Array = []
	data_for_movement.append(type_of_operation)
	data_for_movement.append(node)
	data_for_movement.append(data_of_movement)
	movmentes_mutex.lock()
	things_to_be_moved.append(data_for_movement)
	movmentes_mutex.unlock()

func fifth_dimensional_magic(type_of_unloading : String, node_path_for_unload : String):
	var data_for_unloading : Array = []
	data_for_unloading.append(type_of_unloading)
	data_for_unloading.append(node_path_for_unload)
	mutex_for_unloading_nodes.lock()
	nodes_to_be_unloaded.append(data_for_unloading)
	mutex_for_unloading_nodes.unlock()

func sixth_dimensional_magic(type_of_function, node_to_call, function_name : String, additional_data = null):
	var data_for_function_call : Array = []
	data_for_function_call.append(type_of_function)
	data_for_function_call.append(node_to_call)
	data_for_function_call.append(function_name)
	if additional_data != null:
		data_for_function_call.append(additional_data)
	mutex_function_call.lock()
	functions_to_be_called.append(data_for_function_call)
	mutex_function_call.unlock()

func seventh_dimensional_magic(type_of_action : String, kind_of_action : String, amount_of_actions : int):
	var data_for_additionals : Array = []
	data_for_additionals.append(type_of_action)
	data_for_additionals.append(kind_of_action)
	data_for_additionals.append(amount_of_actions)
	mutex_additionals_call.lock()
	additionals_to_be_called.append(data_for_additionals)
	mutex_additionals_call.unlock()
	print(" seventh dimensional magic : " , data_for_additionals)

func check_magical_array(path_of_the_node):
	var name_parts = path_of_the_node.split("_")  
	var modifiable_parts = Array(name_parts) 
	modifiable_parts.pop_back()  
	var new_name = "_".join(modifiable_parts)
	print(" magical we must learn abortion hehe ", new_name) 
	mutex_additionals_call.lock()
	for current_sets_to_create in additionals_to_be_called:
		print("we must learn abortion hehe current_sets_to_create ", current_sets_to_create)
		if current_sets_to_create[1] == path_of_the_node:
			current_sets_to_create[2] = 0
			mutex_additionals_call.unlock()
			return false
		elif current_sets_to_create[0].begins_with(new_name):
			current_sets_to_create[2] = 0
			mutex_additionals_call.unlock()
			return false
	mutex_additionals_call.unlock()
	return true

func eight_dimensional_magic(type_of_message : String, message_now, receiver_name : String):
	print(" we got magic to do ", type_of_message)
	var divine_messenger_of_space_and_time : Array = []
	divine_messenger_of_space_and_time.append(type_of_message)
	divine_messenger_of_space_and_time.append(message_now)
	divine_messenger_of_space_and_time.append(receiver_name)
	print(" we got magic to do ", type_of_message)
	mutex_messages_call.lock()
	messages_to_be_called.append(divine_messenger_of_space_and_time)
	mutex_messages_call.unlock()
	print(" we got magic to do ", type_of_message)

var texture_storage = {} # Add this as a global variable

func ninth_dimensional_magic(operation, path, texture = null):
	match operation:
		"store_texture":
			texture_storage[path] = texture
			print("Texture stored for " + path)
			
		#"apply_texture":
			#var node = jsh_tree_get_node(path)
			#if node and node is MeshInstance3D and texture_storage.has(path):
				#var material = node.material_override
				#if material:
					#var textured_material = material.duplicate()
					#textured_material.albedo_texture = texture_storage[path]
					#
					#node.set_meta("material_plain", material)
					#node.set_meta("material_textured", textured_material)
					#
					#if is_textures_enabled():
						#node.material_override = textured_material
					#
					#node.add_to_group("texturable")
					#print("Texture applied to " + path)
					#
		#"toggle_textures":
			#textures_enabled = !textures_enabled
			#var objects = get_tree().get_nodes_in_group("texturable")
			#for obj in objects:
				#if obj is MeshInstance3D and obj.has_meta("material_plain") and obj.has_meta("material_textured"):
					#obj.material_override = obj.get_meta("material_textured") if textures_enabled else obj.get_meta("material_plain")
			#print("Textures " + ("enabled" if textures_enabled else "disabled"))
#

#                                     ,,                                          
#  .M"""bgd                         `7MM      `7MM"""Yb.            mm            
# ,MI    "Y                           MM        MM    `Yb.          MM            
# `MMb.      .gP"Ya `7MMpMMMb.   ,M""bMM        MM     `Mb  ,6"Yb.mmMMmm  ,6"Yb.  
#   `YMMNq. ,M'   Yb  MM    MM ,AP    MM        MM      MM 8)   MM  MM   8)   MM  
# .     `MM 8M""""""  MM    MM 8MI    MM        MM     ,MP  ,pm9MM  MM    ,pm9MM  
# Mb     dM YM.    ,  MM    MM `Mb    MM        MM    ,dP' 8M   MM  MM   8M   MM  
# P"Ybmmd"   `Mbmmd'.JMML  JMML.`Wbmd"MML.    .JMMmmmdP'   `Moo9^Yo.`Mbmo`Moo9^Yo.

#

func newer_even_function_for_dictionary(name_of_container):
	array_counting_mutex.lock()
	var datapoint_node_newest = array_for_counting_finish[name_of_container]["metadata"]["datapoint_node"]#.duplicate(true)
	var deep_state_copy_of_apples = array_for_counting_finish[name_of_container].duplicate(true)
	array_counting_mutex.unlock()
	datapoint_node_newest.new_datapoint_layer_system(deep_state_copy_of_apples)

func task_to_send_data_to_datapoint(data_for_sending):
	print(" les check stuff sending data to datapoint")
	var current_datatype = data_for_sending[0][0]
	var first_line_t = data_for_sending[0][1]
	var parsed_lines_t = data_for_sending[0][2]
	var data_point_node_t = data_for_sending[0][3]
	match current_datatype:
		"instructions_analiser":
			var container_node_t = data_for_sending[0][4]
			instructions_analiser(first_line_t, parsed_lines_t[0], parsed_lines_t[1], data_point_node_t, container_node_t)
		"scene_frame_upload":
			var container_node_t = data_for_sending[0][4]
			scene_frames_upload_to_datapoint(first_line_t, parsed_lines_t, data_point_node_t, container_node_t)
		"interactions_upload":
			interactions_upload_to_datapoint(first_line_t, parsed_lines_t, data_point_node_t)

func interactions_upload_to_datapoint(header_line, information_lines, datapoint):
	print(" the await two point o stuff ")
	datapoint.upload_interactions(header_line, information_lines)

func scene_frames_upload_to_datapoint(header_line, information_lines, datapointi, containeri):
	var datapoint_path = header_line[1][0] + "/" + header_line[2][0]
	var datapoint_selector = datapointi
	var new_way1 = header_line
	var new_way2 = information_lines
	datapoint_selector.upload_scenes_frames(header_line, information_lines)

####################
# Check Data
#

#               ,,                                                                         
#   .g8"""bgd `7MM                       `7MM          `7MM"""Yb.            mm            
# .dP'     `M   MM                         MM            MM    `Yb.          MM            
# dM'       `   MMpMMMb.  .gP"Ya   ,p6"bo  MM  ,MP'      MM     `Mb  ,6"Yb.mmMMmm  ,6"Yb.  
# MM            MM    MM ,M'   Yb 6M'  OO  MM ;Y         MM      MM 8)   MM  MM   8)   MM  
# MM.           MM    MM 8M"""""" 8M       MM;Mm         MM     ,MP  ,pm9MM  MM    ,pm9MM  
# `Mb.     ,'   MM    MM YM.    , YM.    , MM `Mb.       MM    ,dP' 8M   MM  MM   8M   MM  
#   `"bmmmd'  .JMML  JMML.`Mbmmd'  YMbmd'.JMML. YA.    .JMMmmmdP'   `Moo9^Yo.`Mbmo`Moo9^Yo.

#

# Check Data

func load_cached_data_second_impact(data_set: String):
	print(" load cached data start : " , data_set)
	var type_of_data : int
	var records_set_name = data_set
	active_r_s_mut.lock()
	var cached_data_new = active_record_sets[records_set_name].duplicate(true)
	active_r_s_mut.unlock()
	var thing_name
	var coords_to_place
	var direction_to_place
	var thing_type_file
	var shape_name
	var root_name
	var pathway_dna
	var group_number
	var first_line : Array = []
	var lines_parsed : Array = []
	for data_type in BanksCombiner.combination_new_gen_1:
		type_of_data = int(data_type[0])
		var type_num = data_type[0]
		var data_name = records_set_name + BanksCombiner.data_names_0[type_num]
		var file_data = cached_data_new[data_name]["content"]
		var size_of_data = file_data.size()
		for record in file_data:
			for lines in record:
				if lines == record[0]:
					first_line = record[0]
				else:
					lines_parsed.append(lines)
					
			print(" we have an issue, probably " , first_line)
			match type_of_data:
				0:
					print("newly_made_dictio here we act re se ")
				1:
					var thingies_to_make_path = lines_parsed[0]
					var datapoint_path_l_c_d_s_i =  thingies_to_make_path[0][0] + "/" + thingies_to_make_path[1][0]
					var data_type_s_i : String = "instructions_analiser"
					print(" we have an issue, probably  1")
					data_to_be_send_processing(thingies_to_make_path[0][0], first_line[0][0], datapoint_path_l_c_d_s_i, data_type_s_i, first_line.duplicate(true), lines_parsed.duplicate(true), data_set)
					mutex_data_to_send.lock()
					data_to_be_send.append([data_type_s_i, datapoint_path_l_c_d_s_i, thingies_to_make_path[0][0], first_line.duplicate(true), lines_parsed.duplicate(true)])
					mutex_data_to_send.unlock()
				2: 
					var thingies_to_make_path = lines_parsed[0]
					var datapoint_path_l_c_d_s_i0 =  first_line[1][0] + "/" + first_line[2][0]
					var data_type_s_i0 : String = "scene_frame_upload"
					print(" we have an issue, probably  2")
					data_to_be_send_processing(first_line[1][0], first_line[0][0], datapoint_path_l_c_d_s_i0, data_type_s_i0, first_line.duplicate(true), lines_parsed.duplicate(true), data_set)
					
					mutex_data_to_send.lock()
					data_to_be_send.append([data_type_s_i0, datapoint_path_l_c_d_s_i0, first_line[1][0], first_line.duplicate(true), lines_parsed.duplicate(true)])
					mutex_data_to_send.unlock()
				3:
					var datapoint_path_l_c_d_s_i1 =  first_line[1][0] + "/" + first_line[2][0]
					var data_type_s_i1 : String = "interactions_upload"
					print(" we have an issue, probably  3")
					data_to_be_send_processing(first_line[1][0], first_line[0][0], datapoint_path_l_c_d_s_i1, data_type_s_i1, first_line.duplicate(true), lines_parsed.duplicate(true), data_set)
					mutex_data_to_send.lock()
					data_to_be_send.append([data_type_s_i1, datapoint_path_l_c_d_s_i1, first_line[1][0], first_line.duplicate(true), lines_parsed.duplicate(true)])
					mutex_data_to_send.unlock()
			first_line.clear()
			lines_parsed.clear()

func load_cached_data_second_impact_old(data_set: String):
	print(" load cached data start : " , data_set)
	var type_of_data : int
	var records_set_name = data_set
	active_r_s_mut.lock()
	var cached_data_new = active_record_sets[records_set_name].duplicate(true)
	active_r_s_mut.unlock()
	var thing_name
	var coords_to_place
	var direction_to_place
	var thing_type_file
	var shape_name
	var root_name
	var pathway_dna
	var group_number
	var first_line : Array = []
	var lines_parsed : Array = []
	for data_type in BanksCombiner.combination_new_gen_1:
		type_of_data = int(data_type[0])
		var type_num = data_type[0]
		var data_name = records_set_name + BanksCombiner.data_names_0[type_num]
		var file_data = cached_data_new[data_name]["content"]
		var size_of_data = file_data.size()
		for record in file_data:
			for lines in record:
				if lines == record[0]:
					first_line = record[0]
				else:
					lines_parsed.append(lines)
			match type_of_data:
				0:
					print("newly_made_dictio here we act re se ")
				1:
					var thingies_to_make_path = lines_parsed[0]
					var datapoint_path_l_c_d_s_i =  thingies_to_make_path[0][0] + "/" + thingies_to_make_path[1][0]
					var data_type_s_i : String = "instructions_analiser"
					data_to_be_send_processing(thingies_to_make_path[0][0], first_line[0][0], datapoint_path_l_c_d_s_i, data_type_s_i, first_line.duplicate(true), lines_parsed.duplicate(true), data_set)
					mutex_data_to_send.lock()
					data_to_be_send.append([data_type_s_i, datapoint_path_l_c_d_s_i, thingies_to_make_path[0][0], first_line.duplicate(true), lines_parsed.duplicate(true)])
					mutex_data_to_send.unlock()
				2: 
					var thingies_to_make_path = lines_parsed[0]
					var datapoint_path_l_c_d_s_i0 =  first_line[1][0] + "/" + first_line[2][0]
					var data_type_s_i0 : String = "scene_frame_upload"
					data_to_be_send_processing(first_line[1][0], first_line[0][0], datapoint_path_l_c_d_s_i0, data_type_s_i0, first_line.duplicate(true), lines_parsed.duplicate(true), data_set)
					mutex_data_to_send.lock()
					data_to_be_send.append([data_type_s_i0, datapoint_path_l_c_d_s_i0, first_line[1][0], first_line.duplicate(true), lines_parsed.duplicate(true)])
					mutex_data_to_send.unlock()
				3: 
					var datapoint_path_l_c_d_s_i1 =  first_line[1][0] + "/" + first_line[2][0]
					var data_type_s_i1 : String = "interactions_upload"
					data_to_be_send_processing(first_line[1][0], first_line[0][0], datapoint_path_l_c_d_s_i1, data_type_s_i1, first_line.duplicate(true), lines_parsed.duplicate(true), data_set)
					mutex_data_to_send.lock()
					data_to_be_send.append([data_type_s_i1, datapoint_path_l_c_d_s_i1, first_line[1][0], first_line.duplicate(true), lines_parsed.duplicate(true)])
					mutex_data_to_send.unlock()
			first_line.clear()
			lines_parsed.clear()

func instructions_analiser(metadata_parts, second_line, third_line, datapoint, container):
	var type = metadata_parts[1][0]
	var counter = -1
	for i in InstructionsBank.type_of_instruction_0:
		counter +=1
		if type == i:
			break
	match counter:
		0:
			datapoint.datapoint_assign_priority(third_line[0][0])
		1: 
			datapoint.add_thing_to_datapoint(third_line)
		2: 
			datapoint.datapoint_max_things_number_setter(third_line[0][0])
		3:
			container.containter_start_up(0, datapoint)
		4: 
			print("analise instruction 4, we didnt use it yet, probably putting containers inside containers, so we have like, easy way to use scenes system :)")
		5: 
			var scene_setter_number = int(third_line[0][0])
			datapoint.scene_to_set_number_later(scene_setter_number)
		6: 
			var type_of_stuff : String = "rotate"
			the_fourth_dimensional_magic(type_of_stuff, container, int(third_line[1][0]))
		7: 
			var action_function_type : String = "single_function"
			var name_of_function : String = "setup_text_handling"
			sixth_dimensional_magic(action_function_type, datapoint, name_of_function)
		8: 
			datapoint.set_maximum_interaction_number(third_line[0][0], int(third_line[1][0]))
		9: 
			print(" move container " , third_line)
			var x = float(third_line[1][0]) 
			var y = float(third_line[1][1])  
			var z = float(third_line[1][2]) 
			var new_position = Vector3(x, y, z)
			var type_of_stuff : String = "move"
			the_fourth_dimensional_magic(type_of_stuff, container, new_position)
		10:
			print(" load_file ")

func data_to_be_send_processing(container_name, data_id, path_for_datapoint, place_for_data, first_line, lines_parsed, data_set_name):
	data_sending_mutex.lock()
	if data_that_is_send.has(data_set_name): 
		if data_that_is_send[data_set_name].has(place_for_data):
			if data_that_is_send[data_set_name][place_for_data].has(data_id):
				print(" it had it already")
			else:
				data_that_is_send[data_set_name][place_for_data][data_id] = {}
				data_that_is_send[data_set_name][place_for_data][data_id]["first_line"] = first_line
				data_that_is_send[data_set_name][place_for_data][data_id]["lines_parsed"] = lines_parsed
		else:
			data_that_is_send[data_set_name][place_for_data] = {}
			data_that_is_send[data_set_name][place_for_data][data_id] = {}
			data_that_is_send[data_set_name][place_for_data][data_id]["first_line"] = first_line
			data_that_is_send[data_set_name][place_for_data][data_id]["lines_parsed"] = lines_parsed
	else:
		data_that_is_send[data_set_name] = {}
		data_that_is_send[data_set_name]["metadata"] = {}
		data_that_is_send[data_set_name]["metadata"]["datapoint_path"] = path_for_datapoint
		data_that_is_send[data_set_name]["metadata"]["container_path"] = container_name
		data_that_is_send[data_set_name][place_for_data] = {}
		data_that_is_send[data_set_name][place_for_data][data_id] = {}
		data_that_is_send[data_set_name][place_for_data][data_id]["first_line"] = first_line
		data_that_is_send[data_set_name][place_for_data][data_id]["lines_parsed"] = lines_parsed
	data_sending_mutex.unlock()

func check_type_of_container(data_set_name):
	var type_of_container : String
	data_sending_mutex.lock()
	for instruction in data_that_is_send[data_set_name]["instructions_analiser"]:
		if data_that_is_send[data_set_name]["instructions_analiser"][instruction]["first_line"][1][0] == "set_interaction_check_mode":
			print(" les check repair ", data_that_is_send[data_set_name]["instructions_analiser"][instruction]["lines_parsed"][1][0])
			type_of_container = data_that_is_send[data_set_name]["instructions_analiser"][instruction]["lines_parsed"][1][0][0]
			data_sending_mutex.unlock()
			return type_of_container
	data_sending_mutex.unlock()

func check_scene_container(data_set_name):
	var type_of_container : String
	data_sending_mutex.lock()
	for instruction in data_that_is_send[data_set_name]["instructions_analiser"]:
		if data_that_is_send[data_set_name]["instructions_analiser"][instruction]["first_line"][1][0] == "set_the_scene":	
			print(" les check repair ", data_that_is_send[data_set_name]["instructions_analiser"][instruction]["lines_parsed"][1][0])
			type_of_container = data_that_is_send[data_set_name]["instructions_analiser"][instruction]["lines_parsed"][1][0][0]
			data_sending_mutex.unlock()
			return type_of_container
	data_sending_mutex.unlock()

# Store Data
#

#  .M"""bgd mm                               `7MM"""Yb.            mm            
# ,MI    "Y MM                                 MM    `Yb.          MM            
# `MMb.   mmMMmm ,pW"Wq.`7Mb,od8 .gP"Ya        MM     `Mb  ,6"Yb.mmMMmm  ,6"Yb.  
#   `YMMNq. MM  6W'   `Wb MM' "',M'   Yb       MM      MM 8)   MM  MM   8)   MM  
# .     `MM MM  8M     M8 MM    8M""""""       MM     ,MP  ,pm9MM  MM    ,pm9MM  
# Mb     dM MM  YA.   ,A9 MM    YM.    ,       MM    ,dP' 8M   MM  MM   8M   MM  
# P"Ybmmd"  `Mbmo`Ybmd9'.JMML.   `Mbmmd'     .JMMmmmdP'   `Moo9^Yo.`Mbmo`Moo9^Yo.

#

#

#   .g8"""bgd                                                  mm    
# .dP'     `M                                                  MM    
# dM'       ` ,pW"Wq.`7MMpMMMb.  `7MMpMMMb.  .gP"Ya   ,p6"bo mmMMmm  
# MM         6W'   `Wb MM    MM    MM    MM ,M'   Yb 6M'  OO   MM    
# MM.        8M     M8 MM    MM    MM    MM 8M"""""" 8M        MM    
# `Mb.     ,'YA.   ,A9 MM    MM    MM    MM YM.    , YM.    ,  MM    
#   `"bmmmd'  `Ybmd9'.JMML  JMML..JMML  JMML.`Mbmmd'  YMbmd'   `Mbmo 

#
# Connect

# Disconnect

#                ,,                                                                           
# `7MM"""Yb.     db                                                                     mm    
#   MM    `Yb.                                                                          MM    
#   MM     `Mb `7MM  ,pP"Ybd  ,p6"bo   ,pW"Wq.`7MMpMMMb.  `7MMpMMMb.  .gP"Ya   ,p6"bo mmMMmm  
#   MM      MM   MM  8I   `" 6M'  OO  6W'   `Wb MM    MM    MM    MM ,M'   Yb 6M'  OO   MM    
#   MM     ,MP   MM  `YMMMa. 8M       8M     M8 MM    MM    MM    MM 8M"""""" 8M        MM    
#   MM    ,dP'   MM  L.   I8 YM.    , YA.   ,A9 MM    MM    MM    MM YM.    , YM.    ,  MM    
# .JMMmmmdP'   .JMML.M9mmmP'  YMbmd'   `Ybmd9'.JMML  JMML..JMML  JMML.`Mbmmd'  YMbmd'   `Mbmo 

# 

# JSH Ethereal Multi Threads System
#

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓ ┓         ┓  ┳┳┓  ┓ •  ┏┳┓┓        ┓   ┏┓         
#       888  `"Y8888o.   888ooooo888     ┣ ╋┣┓┏┓┏┓┏┓┏┓┃  ┃┃┃┓┏┃╋┓   ┃ ┣┓┏┓┏┓┏┓┏┫┏  ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗┛┗┗ ┛ ┗ ┗┻┗  ┛ ┗┗┻┗┗┗   ┻ ┛┗┛ ┗ ┗┻┗┻┛  ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888                                                  ┛       
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            

#

func test_single_core():
	prepare_akashic_records()

func test_multi_threaded():
	var function_name = "prepare_akashic_records"
	create_new_task_empty(function_name)

func check_thread_status():
	var basic_state : String
	if thread_pool == null:
		print(" thread_stats error first")
		return "error"
	else:
		basic_state = "working"
	var thread_stats = thread_pool.get_thread_stats()
	var total_threads = OS.get_processor_count()
	var executing_threads = 0
	var stuck_threads = 0
	for thread_id in thread_stats:
		var state = thread_stats[thread_id]
		if state["status"] == "executing":
			executing_threads += 1
		if state["is_stuck"]:
			stuck_threads += 1
	return basic_state

func check_thread_status_type():
	var basic_state : String
	if thread_pool == null:
		return "error"
	else:
		basic_state = "working"
	var thread_stats = thread_pool.get_thread_stats()
	var total_threads = OS.get_processor_count()
	var executing_threads = 0
	var stuck_threads = 0
	print("\nThread Pool Status:")
	for thread_id in thread_stats:
		var state = thread_stats[thread_id]
		if state["status"] == "executing":
			executing_threads += 1
		if state["is_stuck"]:
			stuck_threads += 1
		print("Thread %s:" % thread_id)
		print("  Status: %s (for %dms)" % [
			state["status"],
			state["time_in_state_ms"]
		])
		print("  Tasks Completed: %d" % state["tasks_completed"])
		
		if state["current_task"]:
			print("  Current Task: %s" % state["current_task"].target_method)
			print("  Task Args: %s" % str(state["current_task"].target_argument))
	print("\nSummary:")
	print("Total Threads: %d" % total_threads)
	print("Executing: %d" % executing_threads)
	print("Stuck: %d" % stuck_threads)
	return total_threads

func multi_threads_start_checker():
	print(" preparer_of_data : " , preparer_of_data)
	if preparer_of_data.size() == 3:
		print(" we have main, thread and delta ")
		if preparer_of_data[0] == preparer_of_data[2]:
			print(" these are main core ")
			if preparer_of_data[0] != preparer_of_data[1]:
				print(" it is different thread")
				return true
			else:
				return false
		else:
			return false
	else:
		return false

func prepare_akashic_records():
	var thread_id = OS.get_thread_caller_id()
	preparer_of_data.append(thread_id)
	print(" threads dilema : " , thread_id)

func create_new_task(function_name: String, data):
	var new_data_way = str(data)
	var task_tag = function_name + "|" + new_data_way + "|" + str(Time.get_ticks_msec())
	thread_pool.submit_task(self, function_name, data, task_tag)

func create_new_task_empty(function_name: String):
	var new_data_way = "empty"
	var task_tag = function_name + "|" + new_data_way + "|" + str(Time.get_ticks_msec())
#	task_manager.new_task_appeared(task_tag, function_name, new_data_way)
	thread_pool.submit_task_unparameterized(self, function_name, task_tag)

func check_three_tries_for_threads(threads_0, threads_1, threads_2):
	var thread_test : int = -1
	if threads_0 == threads_1 and threads_0 == threads_2:
		thread_test = 2
		return thread_test
	if threads_1 == threads_2:
		thread_test = 1
		return thread_test
	else:
		thread_test = 0
		return thread_test
	return thread_test

func validate_thread_system() -> Dictionary:
	var thread_check = check_thread_status()
	return {
		"status": "operational" if thread_check == "working" else "error",
		"total_threads": OS.get_processor_count(),
		"active_threads": thread_pool.get_active_threads() if thread_pool else 0,
		"initialization_time": Time.get_ticks_msec()
	}

#
# JSH Ethereal Queue
#

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓ ┓         ┓  ┏┓        
#       888  `"Y8888o.   888ooooo888     ┣ ╋┣┓┏┓┏┓┏┓┏┓┃  ┃┃┓┏┏┓┓┏┏┓
#       888      `"Y88b  888     888     ┗┛┗┛┗┗ ┛ ┗ ┗┻┗  ┗┻┗┻┗ ┗┻┗ 
#       888 oo     .d8P  888     888         
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            

#                     ,,        ,,                                                                              
#       db          `7MM      `7MM        mm                  .g8""8q.                                          
#      ;MM:           MM        MM        MM                .dP'    `YM.                                        
#     ,V^MM.     ,M""bMM   ,M""bMM      mmMMmm ,pW"Wq.      dM'      `MM `7MM  `7MM  .gP"Ya `7MM  `7MM  .gP"Ya  
#    ,M  `MM   ,AP    MM ,AP    MM        MM  6W'   `Wb     MM        MM   MM    MM ,M'   Yb  MM    MM ,M'   Yb 
#    AbmmmqMA  8MI    MM 8MI    MM        MM  8M     M8     MM.      ,MP   MM    MM 8M""""""  MM    MM 8M"""""" 
#   A'     VML `Mb    MM `Mb    MM        MM  YA.   ,A9     `Mb.    ,dP'   MM    MM YM.    ,  MM    MM YM.    , 
# .AMA.   .AMMA.`Wbmd"MML.`Wbmd"MML.      `Mbmo`Ybmd9'        `"bmmd"'     `Mbod"YML.`Mbmmd'  `Mbod"YML.`Mbmmd' 
#                                                                 MMb                                           
#                                                                  `bood'                                       

func three_stages_of_creation(data_set_name):
	print(" delta message start 00")
	array_mutex_process.lock()
	for current_sets_to_create in list_of_sets_to_create:
		if current_sets_to_create[0] == data_set_name:
			array_mutex_process.unlock()
			return
		elif current_sets_to_create[0].begins_with(data_set_name):
			array_mutex_process.unlock()
			return
	array_mutex_process.unlock()
	print(" delta message start 01")
	var current_stage_of_creation : int = 0
	var first_stage_bool : int = 0
	var second_stage_bool : int = 0
	var third_stage_bool : int = 0
	var fourth_stage_bool : int = 0
	var fifth_stage_bool : int = 0
	var sixth_stage_bool : int = 0
	var seventh_stage_bool : int = 0
	var eight_stage_bool : int = 0
	var nineth_stage_bool : int = 0
	array_mutex_process.lock()
	print(" delta message start 02")
	list_of_sets_to_create.append([data_set_name, current_stage_of_creation, first_stage_bool, second_stage_bool, third_stage_bool, fourth_stage_bool, fifth_stage_bool, sixth_stage_bool, seventh_stage_bool, eight_stage_bool, nineth_stage_bool])
	array_mutex_process.unlock()
	print(" delta message start 03")
	handle_creation_task(data_set_name)

# Check Queue                                                                                                    

#               ,,                                                                                         
#   .g8"""bgd `7MM                       `7MM            .g8""8q.                                          
# .dP'     `M   MM                         MM          .dP'    `YM.                                        
# dM'       `   MMpMMMb.  .gP"Ya   ,p6"bo  MM  ,MP'    dM'      `MM `7MM  `7MM  .gP"Ya `7MM  `7MM  .gP"Ya  
# MM            MM    MM ,M'   Yb 6M'  OO  MM ;Y       MM        MM   MM    MM ,M'   Yb  MM    MM ,M'   Yb 
# MM.           MM    MM 8M"""""" 8M       MM;Mm       MM.      ,MP   MM    MM 8M""""""  MM    MM 8M"""""" 
# `Mb.     ,'   MM    MM YM.    , YM.    , MM `Mb.     `Mb.    ,dP'   MM    MM YM.    ,  MM    MM YM.    , 
#   `"bmmmd'  .JMML  JMML.`Mbmmd'  YMbmd'.JMML. YA.      `"bmmd"'     `Mbod"YML.`Mbmmd'  `Mbod"YML.`Mbmmd' 
#                                                            MMb                                           
#                                                             `bood'                                       

# Check Queue
####################

func check_if_we_are_adding_container(path_of_the_node):
	print(" we must learn abortion hehe ", path_of_the_node)
	var name_parts = path_of_the_node.split("_") 
	var modifiable_parts = Array(name_parts) 
	modifiable_parts.pop_back()  
	var new_name = "_".join(modifiable_parts)
	print(" we must learn abortion hehe ",new_name) 
	array_mutex_process.lock()
	for current_sets_to_create in list_of_sets_to_create:
		if current_sets_to_create[0] == new_name:
			array_mutex_process.unlock()
			return false
		elif current_sets_to_create[0].begins_with(new_name):
			array_mutex_process.unlock()
			return false
	array_mutex_process.unlock()
	return true

func check_if_already_loading_one(set_name):
	array_mutex_process.lock()
	for current_sets_to_create in list_of_sets_to_create:
		if current_sets_to_create[0] == set_name:
			array_mutex_process.unlock()
			return true
		elif current_sets_to_create[0].begins_with(set_name):
			array_mutex_process.unlock()
			return true
	array_mutex_process.unlock()
	return false

func the_current_state_of_tree(set_name_now, the_state):
	mutex_for_container_state.lock()
	if current_containers_state.has(set_name_now):
		current_containers_state[set_name_now]["status"] = the_state
		print("taskkkkl it has it already ", set_name_now, " its status : " , the_state)
	else:
		print("taskkkkl does not have ", set_name_now, " its status : " , the_state)
		current_containers_state[set_name_now] = {
			"status" = the_state
		}
	mutex_for_container_state.unlock()
	if the_state == 1:
		print(" to be loaded ")
		load_queue_mutex.lock()
		if load_queue.has(set_name_now):
			print(" we had it before, to be loaded : ", set_name_now)
		else:
			load_queue[set_name_now] = {}
			print(" we have not loaded it before : ", set_name_now)
		load_queue_mutex.unlock()
	if the_state == -1:
		print(" to be unloaded ")
		unload_queue_mutex.lock()
		if unload_queue.has(set_name_now):
			print(" we had it before, to be unloaded : ", set_name_now)
		else:
			unload_queue[set_name_now] = {}
			print(" we have not unloaded it before")
		unload_queue_mutex.unlock()


																											 

#                                 ,,    ,,      ,...                                                                 
# `7MMM.     ,MMF'              `7MM    db    .d' ""               .g8""8q.                                          
#   MMMb    dPMM                  MM          dM`                .dP'    `YM.                                        
#   M YM   ,M MM  ,pW"Wq.    ,M""bMM  `7MM   mMMmm`7M'   `MF'    dM'      `MM `7MM  `7MM  .gP"Ya `7MM  `7MM  .gP"Ya  
#   M  Mb  M' MM 6W'   `Wb ,AP    MM    MM    MM    VA   ,V      MM        MM   MM    MM ,M'   Yb  MM    MM ,M'   Yb 
#   M  YM.P'  MM 8M     M8 8MI    MM    MM    MM     VA ,V       MM.      ,MP   MM    MM 8M""""""  MM    MM 8M"""""" 
#   M  `YM'   MM YA.   ,A9 `Mb    MM    MM    MM      VVV        `Mb.    ,dP'   MM    MM YM.    ,  MM    MM YM.    , 
# .JML. `'  .JMML.`Ybmd9'   `Wbmd"MML..JMML..JMML.    ,V           `"bmmd"'     `Mbod"YML.`Mbmmd'  `Mbod"YML.`Mbmmd' 
#                                                    ,V                MMb                                           
#                                                 OOb"                  `bood'                                       

func change_creation_set_name(record_type, additional_set_name_):
	print()
	array_mutex_process.lock()
	for number_thingy in list_of_sets_to_create:
		if number_thingy[0] == record_type:
			number_thingy[0] = additional_set_name_
			break
	array_mutex_process.unlock()

# Process Queue                                                                                                                   

# `7MM"""Mq.                                                           .g8""8q.                                          
#   MM   `MM.                                                        .dP'    `YM.                                        
#   MM   ,M9 `7Mb,od8 ,pW"Wq.   ,p6"bo   .gP"Ya  ,pP"Ybd ,pP"Ybd     dM'      `MM `7MM  `7MM  .gP"Ya `7MM  `7MM  .gP"Ya  
#   MMmmdM9    MM' "'6W'   `Wb 6M'  OO  ,M'   Yb 8I   `" 8I   `"     MM        MM   MM    MM ,M'   Yb  MM    MM ,M'   Yb 
#   MM         MM    8M     M8 8M       8M"""""" `YMMMa. `YMMMa.     MM.      ,MP   MM    MM 8M""""""  MM    MM 8M"""""" 
#   MM         MM    YA.   ,A9 YM.    , YM.    , L.   I8 L.   I8     `Mb.    ,dP'   MM    MM YM.    ,  MM    MM YM.    , 
# .JMML.     .JMML.   `Ybmd9'   YMbmd'   `Mbmmd' M9mmmP' M9mmmP'       `"bmmd"'     `Mbod"YML.`Mbmmd'  `Mbod"YML.`Mbmmd' 
#                                                                          MMb                                           

func process_creation_further(record_type : String, amount : int):
	array_mutex_process.lock()
	for number_thingy in list_of_sets_to_create:
		if number_thingy[0] == record_type:
			number_thingy[1] +=amount
			break
	array_mutex_process.unlock()

func whip_out_set_by_its_name(set_name_to_test) -> CreationStatus:
	if not set_name_to_test is String:
		print("Invalid input type for set_name_to_test: ", typeof(set_name_to_test))
		return CreationStatus.INVALID_INPUT
	if set_name_to_test.is_empty():
		print("Set name cannot be empty")
		return CreationStatus.INVALID_INPUT
	if not is_creation_possible():
		print("Creation not possible at this time")
		return CreationStatus.LOCKED
	var task_result = create_new_task("three_stages_of_creation", set_name_to_test)
	if task_result:
		return CreationStatus.SUCCESS
	else:
		return CreationStatus.ERROR

func attempt_creation(set_name: String) -> CreationState:
	if not is_creation_possible():
		return CreationState.LOCKED
	print(" attempt creation list_of_sets_to_create ")
	return CreationState.POSSIBLE

func queue_pusher_adder(task):
	print("queue pusher ", task)
	var method_task = task.target_method
	var completion_time = Time.get_ticks_msec()
	var task_id = str(task.tag)
	var target_argument = task.target_argument
	if task_status.has(task_id):
		var duration = completion_time - task_status[task_id]["start_time"]
		if duration > 1000: # 1 second timeout
			handle_task_timeout(task_id)

func check_currently_being_created_sets():
	print(" delta message start hmm we check if we can push further  ")
	print(" we check em again, are they stuck?")
	array_mutex_process.lock()
	mutex_for_container_state.lock()
	for set_to_create in list_of_sets_to_create:
		print(" we have that for example : ", set_to_create)
		print(" it can even be seen as [0] ", set_to_create[0])
		var name_of_set = set_to_create[0]
		var counter_now : int = -1
		var dumb_counter_0 : int = 0
		var dumb_counter_1 : int = 0
		if current_containers_state.has(name_of_set):
			print(" it has something 0 ", counter_now)
			counter_now = 0
		if current_containers_state.has(name_of_set + "_"):
			print(" it has something 1")
			if counter_now == -1:
				name_of_set = name_of_set + "_"
				counter_now = -2
		if current_containers_state.has(name_of_set + "container"):
			print(" it has something 2")
			if counter_now == -2:
				name_of_set = name_of_set + "container"
		for singular_info in set_to_create:
			if singular_info is int:
				print(" singular_info ", singular_info)
				if dumb_counter_0 == 0:
					dumb_counter_0 +=1
				else:
					dumb_counter_0 +=1
					if singular_info != 0:
						dumb_counter_1 +=1
		print(" checky chicky : " , name_of_set , " and that counter : " , counter_now , " , " , dumb_counter_0 , " , " , dumb_counter_1)
		load_queue_mutex.lock()
		if load_queue.has(name_of_set):
			print(" we have it already in load queue")
			if load_queue[name_of_set].has("metadata"):
				print(" it already had it ")
			else:
				load_queue[name_of_set]["metadata"] = {}
		if dumb_counter_1 >= 1:
			print(" we are somewhere, here something started the creation ")
			if load_queue.has(name_of_set):
				if load_queue[name_of_set].has("metadata"):
					if load_queue[name_of_set]["metadata"].has("status"):
						load_queue[name_of_set]["metadata"]["status"] = int(1)
		else:
			if load_queue.has(name_of_set):
				if load_queue[name_of_set].has("metadata"):
					if load_queue[name_of_set]["metadata"].has("status"):
						print(" that thing have not started its creation ")
						load_queue[name_of_set]["metadata"]["status"] = int(0)
		print(" cheecku chicku : load_queue : " , load_queue)
		load_queue_mutex.unlock()
	array_mutex_process.unlock()
	mutex_for_container_state.unlock()

func process_stages():
	array_mutex_process.lock()
	for sets_to_create in list_of_sets_to_create:
		var dataset = sets_to_create[0]
		var dataset_name = sets_to_create[0]
		var current_stage = sets_to_create[1]
		match current_stage:
			0:
				if sets_to_create[1] == 0 and curent_queue[0][0] == 0 and sets_to_create[2] == 0:
					curent_queue[0][0] = 1
					sets_to_create[2] = 1
					#print(" creation 00 ", dataset_name)
					first_stage_of_creation_(dataset_name, sets_to_create)
			1:
				if sets_to_create[1] == 1 and curent_queue[1][0] == 0 and sets_to_create[3] == 0:
					sets_to_create[3] = 1
					curent_queue[0][0] = 0
					curent_queue[1][0] = 1
					#print(" creation 01 ", dataset_name)
					second_stage_of_creation_(dataset_name, sets_to_create)
			2:
				if sets_to_create[1] == 2 and curent_queue[2][0] == 0 and sets_to_create[4] == 0:
					curent_queue[1][0] = 0 
					curent_queue[2][0] = 1
					sets_to_create[4] = 1
					#print(" creation 02 ", dataset_name)
					third_stage_of_creation_(dataset_name, sets_to_create)
			3:
				if sets_to_create[1] == 3 and curent_queue[3][0] == 0 and sets_to_create[5] == 0:
					sets_to_create[5] = 1
					curent_queue[2][0] = 0
					curent_queue[3][0] = 1
					fourth_impact_of_creation_(dataset_name, sets_to_create)
			4:
				if sets_to_create[1] == 4 and curent_queue[4][0] == 0 and sets_to_create[6] == 0:
					sets_to_create[6] = 1
					curent_queue[3][0] = 0
					curent_queue[4][0] = 1
					fifth_impact_of_creation_(dataset_name, sets_to_create)
			5:
				if sets_to_create[1] == 5 and curent_queue[5][0] == 0 and sets_to_create[7] == 0:
					sets_to_create[7] = 1
					curent_queue[4][0] = 0
					curent_queue[5][0] = 1
					sixth_impact_of_creation(dataset_name, sets_to_create)
			6:
				if curent_queue[5][0] == 1:
					curent_queue[5][0] = 0
				if curent_queue[0][0] == 1:
					curent_queue[0][0] = 0
				list_of_sets_to_create.erase(sets_to_create)
				if list_of_sets_to_create.size() == 0:
					curent_queue = [[0], [0], [0], [0], [0], [0], [0], [0], [0], [0]] 
			7:
				if curent_queue[4][0] == 1:
					curent_queue[4][0] = 0
				if curent_queue[0][0] == 1:
					curent_queue[0][0] = 0
				list_of_sets_to_create.erase(sets_to_create)
				if list_of_sets_to_create.size() == 0:
					curent_queue = [[0], [0], [0], [0], [0], [0], [0], [0], [0], [0]] 
					the_menace_checker = 0
	array_mutex_process.unlock()

func first_stage_of_creation_(data_set_name_0, sets_to_create_0):
	create_new_task("initialize_menu", sets_to_create_0[0])

func second_stage_of_creation_(data_set_name_1, sets_to_create_1):
	create_new_task("second_impact_for_real", sets_to_create_1[0])

func second_impact_for_real(set_to_do_thingy):
	var records_set_name_0 = set_to_do_thingy + "_"
	var container_name_for_array = container_finder(records_set_name_0)
	array_counting_mutex.lock()
	if !array_for_counting_finish.has(container_name_for_array):
		array_for_counting_finish[container_name_for_array] = {}
	array_counting_mutex.unlock()
	active_r_s_mut.lock()
	var safe_activ_record_set = active_record_sets
	active_r_s_mut.unlock()
	process_active_records_for_tree(safe_activ_record_set, records_set_name_0, container_name_for_array)
	array_mutex_process.lock()
	for number_thingy in list_of_sets_to_create:
		if number_thingy[0] == set_to_do_thingy:
			number_thingy[1] +=1
	array_mutex_process.unlock()
func third_stage_of_creation_(data_set_name_2, sets_to_create_2):
	create_new_task("third_impact_right_now", sets_to_create_2[0])

func third_impact_right_now(data_set_thingiess):
	var records_set_name_1 = data_set_thingiess + "_"
	load_cached_data(records_set_name_1)
	array_mutex_process.lock()
	for number_thingy in list_of_sets_to_create:
		if number_thingy[0] == data_set_thingiess:
			number_thingy[1] +=1
	array_mutex_process.unlock()
####################
func fourth_impact_of_creation_(data_set_name_3, sets_to_create_3):
	create_new_task("fourth_impact_right_now", data_set_name_3)

func fourth_impact_right_now(data_set_nameeee):
	var records_set_name_1 = data_set_nameeee + "_"
	load_cached_data_second_impact(records_set_name_1)
	array_mutex_process.lock()
	for number_thingy in list_of_sets_to_create:
		if number_thingy[0] == data_set_nameeee:
			number_thingy[1] +=1
	array_mutex_process.unlock()

func fifth_impact_of_creation_(data_set_name_4, sets_to_create_4):
	create_new_task("fifth_impact_right_now", data_set_name_4)

func fifth_impact_right_now(data_set_nameeeeee):
	array_mutex_process.lock()
	for number_thingy in list_of_sets_to_create:
		if number_thingy[0] == data_set_nameeeeee:
			print(" fifth imnpact list of sets to create we plus one " , data_set_nameeeeee)
			number_thingy[1] +=1
	array_mutex_process.unlock()

func sixth_impact_of_creation(data_set_name_6, sets_to_create_6):
	create_new_task("sixth_impact_right_now", data_set_name_6)

func sixth_impact_right_now(data_set_name_here):
	var data_set_name_here_ = data_set_name_here + "_"
	var container_name : String
	var data_point_path : String
	data_sending_mutex.lock()
	container_name = data_that_is_send[data_set_name_here_]["metadata"]["datapoint_path"]
	data_point_path = data_that_is_send[data_set_name_here_]["metadata"]["container_path"]
	data_sending_mutex.unlock()
	var type_of_container = check_type_of_container(data_set_name_here_)
	var main_scene_to_set = check_scene_container(data_set_name_here_)
	mutex_for_container_state.lock()
	if current_containers_state.has(data_set_name_here):
		current_containers_state[data_set_name_here]["container"] = container_name
		current_containers_state[data_set_name_here]["datapoint_path"] = data_point_path
		if type_of_container != null:
			print(" les check stuff, what is it? ", type_of_container)
			current_containers_state[data_set_name_here]["container_type"] = type_of_container
		if main_scene_to_set != null:
			print(" les check stuff, what is it? ", main_scene_to_set)
			current_containers_state[data_set_name_here]["main_scene"] = main_scene_to_set
	else:
		var set_name_minus_one = data_set_name_here.substr(0, data_set_name_here.length() -1)
		if current_containers_state.has(set_name_minus_one):
			print(" it is multi type stuff ")
	mutex_for_container_state.unlock()
	if type_of_container == null:
		print(" type_of_container null ")
	elif type_of_container == "single":
		print(" type_of_container single ")
	elif type_of_container == "multi":
		print(" type_of_container multi ")
	array_mutex_process.lock()
	for number_thingy in list_of_sets_to_create:
		if number_thingy[0] == data_set_name_here:
			number_thingy[1] +=1
	array_mutex_process.unlock()

#
# JSH Ethereal Files Management System

#

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓ ┓         ┓  ┏┓•┓     ┳┳┓                    ┏┓         
#       888  `"Y8888o.   888ooooo888     ┣ ╋┣┓┏┓┏┓┏┓┏┓┃  ┣ ┓┃┏┓┏  ┃┃┃┏┓┏┓┏┓┏┓┏┓┏┳┓┏┓┏┓╋  ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗┛┗┗ ┛ ┗ ┗┻┗  ┻ ┗┗┗ ┛  ┛ ┗┗┻┛┗┗┻┗┫┗ ┛┗┗┗ ┛┗┗  ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888                                        ┛               ┛       
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            


# JSH Ethereal Files Management System
#

																			 
#                                                                  ,,    ,,                  
#   .g8"""bgd                          mm               `7MM"""YMM db  `7MM                  
# .dP'     `M                          MM                 MM    `7       MM                  
# dM'       ``7Mb,od8 .gP"Ya   ,6"Yb.mmMMmm .gP"Ya        MM   d `7MM    MM  .gP"Ya  ,pP"Ybd 
# MM           MM' "',M'   Yb 8)   MM  MM  ,M'   Yb       MM""MM   MM    MM ,M'   Yb 8I   `" 
# MM.          MM    8M""""""  ,pm9MM  MM  8M""""""       MM   Y   MM    MM 8M"""""" `YMMMa. 
# `Mb.     ,'  MM    YM.    , 8M   MM  MM  YM.    ,       MM       MM    MM YM.    , L.   I8 
#   `"bmmmd' .JMML.   `Mbmmd' `Moo9^Yo.`Mbmo`Mbmmd'     .JMML.   .JMML..JMML.`Mbmmd' M9mmmP' 
# Create Files

func file_creation(file_content,  path_for_file, name_for_file):
	var file = FileAccess.open( path_for_file + "/" + name_for_file + ".txt", FileAccess.WRITE)
	if file:
		for line in file_content:
			file.store_line(line) 

func create_file(array_with_data: Array, lines_amount: int, name_for_file: String):
	var file = FileAccess.open(path + "/" + name_for_file + ".txt", FileAccess.WRITE)
	if file:
		for line in range(lines_amount):
			file.store_line(array_with_data[line][0]) 
		file_path = path + "/" + name_for_file + ".txt"

func save_file_list_text(scan_results: Dictionary, output_file: String, target_directory: String):
	var file = FileAccess.open(output_file, FileAccess.WRITE)
	if not file:
		print("❌ Error: Could not create file_list.txt")
		return
	file.store_line("📂 File List for " + target_directory + "\n") # Fixed scope issue
	for subdir in scan_results["directories"]:
		file.store_line("📁 " + subdir)
	for file_data in scan_results["files"]:
		file.store_line("📄 " + file_data["name"] + " - " + str(file_data["size"]) + " bytes")
	file.close()
	print("✅ File list saved to: " + output_file)

func create_default_settings(file_path_c_d_s):
	var settings_data = []
	for entry in SettingsBank.settings_file_blue_print_0[0]:
		settings_data.append(entry)
	create_file(settings_data, settings_data.size(), "settings")

func save_file_list_json(scan_results: Dictionary, output_file: String = "user://file_list.json"):
	var file = FileAccess.open(output_file, FileAccess.WRITE)
	if file:
		var json_data = JSON.stringify(scan_results, "\t")  
		file.store_string(json_data)
		file.close()
		print("✅ File list saved to: " + output_file)

# Check Files

#               ,,                                                ,,    ,,                  
#   .g8"""bgd `7MM                       `7MM          `7MM"""YMM db  `7MM                  
# .dP'     `M   MM                         MM            MM    `7       MM                  
# dM'       `   MMpMMMb.  .gP"Ya   ,p6"bo  MM  ,MP'      MM   d `7MM    MM  .gP"Ya  ,pP"Ybd 
# MM            MM    MM ,M'   Yb 6M'  OO  MM ;Y         MM""MM   MM    MM ,M'   Yb 8I   `" 
# MM.           MM    MM 8M"""""" 8M       MM;Mm         MM   Y   MM    MM 8M"""""" `YMMMa. 
# `Mb.     ,'   MM    MM YM.    , YM.    , MM `Mb.       MM       MM    MM YM.    , L.   I8 
#   `"bmmmd'  .JMML  JMML.`Mbmmd'  YMbmd'.JMML. YA.    .JMML.   .JMML..JMML.`Mbmmd' M9mmmP' 

# Check Files
####################


func find_or_create_eden_directory():
	var available_dirs = scan_available_storage()
	for dir in available_dirs:
		if DirAccess.dir_exists_absolute(dir + "/Eden"):
			return dir + "/Eden"
	var target_dir = available_dirs[0] + "/Eden"
	DirAccess.make_dir_recursive_absolute(target_dir)
	return target_dir
####################
	
func file_finder(file_name, path_to_file, list_of_files, type_of_data):
	var counter_liste = list_of_files.size()
	var counter_times : int = 0
	for file in list_of_files:
		if file == file_name:
			file_path = path_to_file + "/" + file
####################

func check_folder(folder_path):
	var space_existence = DirAccess.open(folder_path)
	if space_existence:
		check_folder_content(space_existence)
		directory_existence = true
	else:
		pass

func check_folder_content(directory):  
	files_content = directory.get_files()     
	folders_content = directory.get_directories() 
	if files_content.size() > 0:
		files_existence = true
	else:
		files_existence = false
	if folders_content.size() > 0:
		folders_existence = true
	else:
		folders_existence = false


# packed points of data, either 2 or three, for spaces, beside 1 poiint based as previously
# vec3, vec3i
# vec4, vec4i
# quad, 4 xyzw
# basis xxx, yyy, zzz, xyz, yxz, zxy
# so one layer, more layer
# a string object, adnoted as string, never touched
# two datas, for mouse where, screen max size, window size, to calculate its center point on 2d screen user looks at
# function of anything inside, like entire object in javascript
var just_test_var
var we_just_need_new_word : String
# this one is empty, not even spacebar, but start and end
var another_string_of_nothing : String = ""
# another var, that is an array, even told what it is, empty [] array, beginning and end
var another_snake_case_var : Array = []
# another var that is something
var snake_case_dictionary : Dictionary = {}
# "1" int(string_as_number)
# numbers zone, starting point is 0, in any directions
var snake_case_int : int = 0
# one that is divided, between full points
var snake_case_float : float = 0.0
var snake_vector_two : Vector2
# the same no divide, faster
var snake_vector_two_int : Vector2i
# three things in one, one layer
var snake_vector_three : Vector3
# the same just int no divide
var snake_vector_three_int : Vector3i
# four in one layer
var snake_vector_four : Vector4
# four numbers just ints
var snake_vector_four_int : Vector4i
# basic identity
var basis_snake = Basis.IDENTITY 
# same basic
var my_basis = Basis(Vector3(0, 2, 0), Vector3(2, 0, 0), Vector3(0, 0, 2))
# quaternion for rotations, and basis like stuff, transform3d like stuff,
var quanternion_snake : Quaternion
# the same, named in not mistake way
var quaternion_snake_case : Quaternion
#
# this is jsut a commen line it can have mistakes

# function start
func check_settings_file(type_of_file):# function start
	# function start
	
	var path_for_user_data = "user://" 
	var settings_file_name = type_of_file + ".txt"
	
	var settings_exists = FileAccess.file_exists("user://"+ type_of_file + ".txt")
	scan_available_storage()
	
	var file_data_of_settings
	if type_of_file == "settings":
		file_data_of_settings = SettingsBank.settings_file_blue_print_0
	elif type_of_file == "modules":
		file_data_of_settings = ModulesBank.module_blue_print
		
	var data_of_settings_cleaned : Array = []
	for entry in file_data_of_settings[0]:
		var cleansed = entry[0].split("|")
		data_of_settings_cleaned.append(cleansed)
	
	
	if !FileAccess.file_exists(path_for_user_data + settings_file_name):
		var file = FileAccess.open(path_for_user_data + settings_file_name, FileAccess.WRITE)
		if file:
			for line in data_of_settings_cleaned:
				file.store_line(line[0] + " : " + line[1])
		file.close()
		var settings_message 
		if type_of_file == "settings":
			settings_message = SettingsBank.load_settings_file(path_for_user_data + settings_file_name)
		if type_of_file == "modules":
			settings_message = ModulesBank.load_settings_file(path_for_user_data + settings_file_name)
			print("main gd modules file load : " , data_of_settings_cleaned)
		print(" settings message = ", settings_message)
	
	
	
	if type_of_file == "settings":
		var path_for_directory = data_of_settings_cleaned[0][1] # D:/Eden
		update_main_path(path_for_directory)
		
		var path_for_database = data_of_settings_cleaned[1][1] # akashic_records
		update_database_path(path_for_database)
		
		var default_directory = DirAccess.dir_exists_absolute(path_for_directory)
		if default_directory == true:
			print("the directory exist, we can send there file, hmm, damn, i wanted to do it different way, like use res? but lets just do it my way, it even finds")
		else:
			scan_available_storage()
		if available_directiories is Array:
			print(" available directories is an Array, but is it empty?")
			if available_directiories.is_empty():
				print(" it is empty " , available_directiories)
			else:
				print(" it is not empty ", available_directiories)
		if available_directiories[0]:
			data_of_settings_cleaned.append(["available_directiory" , available_directiories[0]])
		if !DirAccess.dir_exists_absolute(path_for_user_data + path_for_database):
			DirAccess.make_dir_recursive_absolute(path_for_user_data + path_for_database)
			
			
		
	print(" settings file history|file_exist|user://settings.txt ", settings_exists)
	check_settings_data.append(check_settings_data)
	if settings_exists:
		var file = FileAccess.open(("user://"+ type_of_file + ".txt"), FileAccess.READ)
		print(" settings file history|if user folder had |settings.txt:", settings_exists)
		check_settings_data.append(settings_exists)
		check_settings_data.append(file)
		if file:
			print("Successfully opened settings file")
			file.close()
			
			if type_of_file == "settings":
				var settings_message = SettingsBank.load_settings_file("user://settings.txt")
				print(" settings message = 2 ", settings_message)
			elif type_of_file == "modules":
				var modules_message = ModulesBank.load_settings_file("user://"+ type_of_file + ".txt")
			
			return true
		else:
			print("File exists but couldn't open it")
			return false
	else:
		print("No settings file found in user://")
	return check_settings_data




#################



func update_main_path(updated_path):
	path = updated_path
#var path = "D:/Eden"
#var database_folder = "akashic_records"

func update_database_path(updated_db_path):
	database_folder = updated_db_path


################

func scan_eden_directory(directory: String = "D:/Eden", indent: int = 0) -> Dictionary:
	var dir = DirAccess.open(directory)
	var scan_results = {
		"files": [],  
		"directories": [],  
		"subdirectories": {}, 
		"status": "pending"
	}
	if dir:
		scan_results["status"] = "completed"
		for subdir in dir.get_directories():
			scan_results["directories"].append(subdir)
			scan_results["subdirectories"][subdir] = scan_eden_directory(directory.path_join(subdir), indent + 1)  
		for file in dir.get_files():
			scan_results["files"].append(file)  
	else:
		scan_results["status"] = "failed"
		print("❌ Could not open directory: " + directory)
	return scan_results

func scan_available_storage():
	if OS.get_name() == "Windows":
		for ascii in range(65, 91):
			var drive = char(ascii) + ":/"
			var dir = DirAccess.open(drive)
			if dir != null:
				available_directiories.append(drive)
	elif OS.get_name() == "Android":
		var common_paths = [
			"/storage/emulated/0/", 
			"/sdcard/",              
			"/storage/"              
		]
		for path_s_a_s in common_paths:
			var dir = DirAccess.open(path)
			if dir != null:
				if path_s_a_s == "/storage/":
					var contents = dir.get_directories()
					for storage in contents:
						print("Storage device found: /storage/" + storage)
	return available_directiories

func scan_res_directory(directory: String = "res://", indent: int = 0) -> Dictionary:
	var dir = DirAccess.open(directory)
	var scan_results = {
		"files": [],
		"directories": [],
		"status": "pending"
	}
	if dir:
		scan_results["status"] = "completed"
		for subdir in dir.get_directories():
			print("  ".repeat(indent) + "📁 " + subdir)
			scan_results["directories"].append(subdir)
			scan_results[subdir] = scan_res_directory(directory.path_join(subdir), indent + 1)  
		for file in dir.get_files():
			print("  ".repeat(indent) + "📄 " + file)
			scan_results["files"].append(file)
	else:
		scan_results["status"] = "failed"
	scan_result = scan_results
	return scan_results

func scan_directory_with_sizes(directory: String, indent: int = 0) -> Dictionary:
	var dir = DirAccess.open(directory)
	var scan_results = {
		"files": [],        
		"directories": [],  
		"status": "pending"
	}
	if dir:
		scan_results["status"] = "completed"
		for subdir in dir.get_directories():
			scan_results["directories"].append(subdir)
			scan_results[subdir] = scan_directory_with_sizes(directory.path_join(subdir), indent + 1)
		for file in dir.get_files():
			var full_path = directory.path_join(file)
			var file_size = 0  
			var file_access = FileAccess.open(full_path, FileAccess.READ)
			if file_access:
				file_size = file_access.get_length()
				file_access.close()  
			var file_entry = {
				"name": file,
				"size": file_size
			}
			scan_results["files"].append(file_entry)  
	else:
		scan_results["status"] = "failed"
	return scan_results

func get_data_structure_size(data) -> int:
	if data == null:
		return 0
	match typeof(data):
		TYPE_DICTIONARY:
			var total_size = 0
			for key in data:
				total_size += var_to_bytes(key).size()
				if data[key] != null:
					total_size += get_data_structure_size(data[key])
			return total_size
		TYPE_ARRAY:
			var total_size = 0
			for item in data:
				if item != null:
					total_size += get_data_structure_size(item)
			return total_size
		TYPE_OBJECT:
			if data is Node:
				return 8  
			return var_to_bytes(data).size()
		TYPE_STRING:
			return data.length() * 2  
		TYPE_INT:
			return 4
		TYPE_FLOAT:
			return 8
		TYPE_VECTOR2, TYPE_VECTOR2I:
			return 8
		TYPE_VECTOR3, TYPE_VECTOR3I:
			return 12
		_:
			return var_to_bytes(data).size()

func get_jsh(property_name: String):
	if property_name in self:
		return self[property_name]
	return null

func check_memory_state():
	var current_time = Time.get_ticks_msec()
	var sizes = {}
	for array_name in memory_metadata["arrays"].keys():
		if get_jsh(array_name) != null:
			var array_size = get_data_structure_size(get_jsh(array_name))
			sizes[array_name] = array_size
			if array_size > memory_metadata["cleanup_thresholds"]["array_max"]:
				clean_array(array_name)
	for dict_name in memory_metadata["dictionaries"].keys():
		if get_jsh(dict_name) != null:
			var dict_size = get_data_structure_size(get_jsh(dict_name))
			sizes[dict_name] = dict_size
			var size_mb = dict_size / (1024 * 1024)
			if size_mb > memory_metadata["cleanup_thresholds"]["dict_max_mb"]:
				clean_dictionary(dict_name)
	print("\nMemory State:")
	for name in sizes:
		print("%s: %s bytes" % [name, sizes[name]])
	return sizes

####################
# Load Files

#                                      ,,                 ,,    ,,                  
# `7MMF'                             `7MM      `7MM"""YMM db  `7MM                  
#   MM                                 MM        MM    `7       MM                  
#   MM         ,pW"Wq.   ,6"Yb.   ,M""bMM        MM   d `7MM    MM  .gP"Ya  ,pP"Ybd 
#   MM        6W'   `Wb 8)   MM ,AP    MM        MM""MM   MM    MM ,M'   Yb 8I   `" 
#   MM      , 8M     M8  ,pm9MM 8MI    MM        MM   Y   MM    MM 8M"""""" `YMMMa. 
#   MM     ,M YA.   ,A9 8M   MM `Mb    MM        MM       MM    MM YM.    , L.   I8 
# .JMMmmmmMMM  `Ybmd9'  `Moo9^Yo.`Wbmd"MML.    .JMML.   .JMML..JMML.`Mbmmd' M9mmmP' 

# Load Files

func setup_settings():
	var eden_path = find_or_create_eden_directory()
	var akashic_path = eden_path + "/akashic_records"
	if !DirAccess.dir_exists_absolute(akashic_path):
		DirAccess.make_dir_recursive_absolute(akashic_path)
	var settings_file_path = akashic_path + "/settings.txt"
	if !FileAccess.file_exists(settings_file_path):
		create_default_settings(settings_file_path)
	SettingsBank.load_settings_file(settings_file_path)

####################
# Modify Files

#                                 ,,    ,,      ,...                        ,,    ,,                  
# `7MMM.     ,MMF'              `7MM    db    .d' ""             `7MM"""YMM db  `7MM                  
#   MMMb    dPMM                  MM          dM`                  MM    `7       MM                  
#   M YM   ,M MM  ,pW"Wq.    ,M""bMM  `7MM   mMMmm`7M'   `MF'      MM   d `7MM    MM  .gP"Ya  ,pP"Ybd 
#   M  Mb  M' MM 6W'   `Wb ,AP    MM    MM    MM    VA   ,V        MM""MM   MM    MM ,M'   Yb 8I   `" 
#   M  YM.P'  MM 8M     M8 8MI    MM    MM    MM     VA ,V         MM   Y   MM    MM 8M"""""" `YMMMa. 
#   M  `YM'   MM YA.   ,A9 `Mb    MM    MM    MM      VVV          MM       MM    MM YM.    , L.   I8 
# .JML. `'  .JMML.`Ybmd9'   `Wbmd"MML..JMML..JMML.    ,V         .JMML.   .JMML..JMML.`Mbmmd' M9mmmP' 
#                                                    ,V                                               
#                                                 OOb"                                                

																					

#               ,,                                              ,,    ,,                  
#   .g8"""bgd `7MM                                   `7MM"""YMM db  `7MM                  
# .dP'     `M   MM                                     MM    `7       MM                  
# dM'       `   MM  .gP"Ya   ,6"Yb.  `7MMpMMMb.        MM   d `7MM    MM  .gP"Ya  ,pP"Ybd 
# MM            MM ,M'   Yb 8)   MM    MM    MM        MM""MM   MM    MM ,M'   Yb 8I   `" 
# MM.           MM 8M""""""  ,pm9MM    MM    MM        MM   Y   MM    MM 8M"""""" `YMMMa. 
# `Mb.     ,'   MM YM.    , 8M   MM    MM    MM        MM       MM    MM YM.    , L.   I8 
#   `"bmmmd'  .JMML.`Mbmmd' `Moo9^Yo..JMML  JMML.    .JMML.   .JMML..JMML.`Mbmmd' M9mmmP' 
#                                                                                                                                                                                

func clean_array(array_name: String):
	match array_name:
		"stored_delta_memory":
			if stored_delta_memory.size() > 100:
				stored_delta_memory = stored_delta_memory.slice(-100)
		"blimp_of_time":
			if blimp_of_time.size() > 50:
				blimp_of_time = blimp_of_time.slice(-50)
		"array_with_no_mutex":
			var current_time = Time.get_ticks_msec()
			array_with_no_mutex = array_with_no_mutex.filter(
				func(error): return current_time - error.time < 300000 # 5 minutes
			)

func clean_dictionary(dict_name: String):
	match dict_name:
		"cached_record_sets":
			var current_time = Time.get_ticks_msec()
			for key in cached_record_sets.keys():
				if current_time - cached_record_sets[key].get("timestamp", 0) > 3600000: # 1 hour
					cached_record_sets.erase(key)
		"dictionary_of_mistakes":
			for key in dictionary_of_mistakes.keys():
				if dictionary_of_mistakes[key].get("status") == "resolved":
					dictionary_of_mistakes.erase(key)


####################
#
# JSH Data Splitter
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┳┓       ┏┓  ┓•      
#       888  `"Y8888o.   888ooooo888     ┃┃┏┓╋┏┓  ┗┓┏┓┃┓╋╋┏┓┏┓
#       888      `"Y88b  888     888     ┻┛┗┻┗┗┻  ┗┛┣┛┗┗┗┗┗ ┛ 
#       888 oo     .d8P  888     888                ┛       
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# JSH Data Splitter
#

func data_splitter_some_function():
	var content = "your content"
	var analysis = data_splitter.analyze_file_content(content)

func zippy_unzipper_data_center():
	print(" the load and unload of zip file is needed ")
	print(" lets do it three letters system of words ")
	print(" the gateway of repeats ")
	print(" one big zip file ")

#
# JSH Ethereal Records System

#

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓ ┓         ┓  ┳┓        ┓   ┏┓         
#       888  `"Y8888o.   888ooooo888     ┣ ╋┣┓┏┓┏┓┏┓┏┓┃  ┣┫┏┓┏┏┓┏┓┏┫┏  ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗┛┗┗ ┛ ┗ ┗┻┗  ┛┗┗ ┗┗┛┛ ┗┻┛  ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888                                      ┛       
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            

#

####################
# Check Records

#               ,,                                                                                         ,,          
#   .g8"""bgd `7MM                       `7MM          `7MM"""Mq.                                        `7MM          
# .dP'     `M   MM                         MM            MM   `MM.                                         MM          
# dM'       `   MMpMMMb.  .gP"Ya   ,p6"bo  MM  ,MP'      MM   ,M9  .gP"Ya   ,p6"bo   ,pW"Wq.`7Mb,od8  ,M""bMM  ,pP"Ybd 
# MM            MM    MM ,M'   Yb 6M'  OO  MM ;Y         MMmmdM9  ,M'   Yb 6M'  OO  6W'   `Wb MM' "',AP    MM  8I   `" 
# MM.           MM    MM 8M"""""" 8M       MM;Mm         MM  YM.  8M"""""" 8M       8M     M8 MM    8MI    MM  `YMMMa. 
# `Mb.     ,'   MM    MM YM.    , YM.    , MM `Mb.       MM   `Mb.YM.    , YM.    , YA.   ,A9 MM    `Mb    MM  L.   I8 
#   `"bmmmd'  .JMML  JMML.`Mbmmd'  YMbmd'.JMML. YA.    .JMML. .JMM.`Mbmmd'  YMbmd'   `Ybmd9'.JMML.   `Wbmd"MML.M9mmmP' 

## check if active has that set
## check if active set is empty
# -1 = missing, 0 = empty, 1 = it is here

func check_record_in_active(records_set_name):
	active_r_s_mut.lock()
	# -1 = dont have that key, it is empty
	var active_int : int = -1
	if active_record_sets.has(records_set_name):
		# 0 = has that key
		active_int = 0
		if !active_record_sets[records_set_name].is_empty():
			# 1 = has that key, not empty
			active_int = 1
	active_r_s_mut.unlock()
	return active_int

func check_record_in_cached(records_set_name):
	cached_r_s_mutex.lock()
	# -1 = dont have that key, it is empty
	var cached_int : int = -1
	if cached_record_sets.has(records_set_name):
		# 0 = has that key
		cached_int = 0
		if !cached_record_sets[records_set_name].is_empty():
			# 1 = has that key, not empty
			cached_int = 1
	cached_r_s_mutex.unlock()
	return cached_int

func check_set_limit(records_set_name):
	var currently_checked_set : int = -1
	var set_limit = BanksCombiner.dataSetLimits
	if set_limit.has(records_set_name):
		currently_checked_set = set_limit[records_set_name]
	return currently_checked_set

func check_current_set_container_count(record_set_name):
	active_r_s_mut.lock()
	var current_container_count : int = -1
	if active_record_sets.has(record_set_name):
		if active_record_sets[record_set_name].has("metadata"):
			if active_record_sets[record_set_name]["metadata"].has("container_count"):
				current_container_count = active_record_sets[record_set_name]["metadata"]["container_count"]
	active_r_s_mut.unlock()
	return current_container_count

func check_record_set_type(record_set_name):
	var currently_checked_set : int = -1
	var set_type = BanksCombiner.data_set_type
	if set_type.has(record_set_name):
		currently_checked_set = set_type[record_set_name]
	var set_type_string : String = ""
	if currently_checked_set == -1:
		print( " we didnt find it, lets put a 0 here ")
		currently_checked_set = 0
		set_type_string = "single"
	elif currently_checked_set == 0:
		print(" single ")
		set_type_string = "single"
	elif currently_checked_set == 1:
		print(" multi ")
		set_type_string = "multi"
	elif currently_checked_set == 2:
		print(" duplicate")
		set_type_string = "duplicate"
	return set_type_string

func check_if_first_time(set_name_first, the_current_of_energy):
	mutex_containers.lock()
	print(" set_name_first  : " , set_name_first , " the_current_of_energy ", the_current_of_energy , " list_of_containers " , list_of_containers)
	if list_of_containers.has(set_name_first):
		print(" it have it already")
	else:
		list_of_containers[set_name_first] = {}
		list_of_containers[set_name_first]["status"] = the_current_of_energy
	list_of_containers
	mutex_containers.unlock()

func containers_states_checker():
	mutex_for_container_state.lock()
	if current_containers_state.size() > 0:
		print("checkerrr bigger list than 0 ")
		for data_sets_to_check in current_containers_state:
			print(" alkaida is calling fbi xd :  ", data_sets_to_check , ", " , current_containers_state[data_sets_to_check]["status"])
			var state_of_check_0 : int = -1
			var state_of_check_1 : int = -1
			var state_of_check_2 : int = -1
			var vector_now : Vector3i
			vector_now.x = state_of_check_0
			vector_now.y = state_of_check_1
			vector_now.z = state_of_check_2
			if !current_containers_state[data_sets_to_check].has("status_tree"):
				current_containers_state[data_sets_to_check]["status_tree"] = "pending"
				current_containers_state[data_sets_to_check]["three_i"] = vector_now
			if current_containers_state[data_sets_to_check]["status"] == -1:
				print(" we must reset the xyz thingy")
				current_containers_state[data_sets_to_check]["three_i"] = vector_now
			var set_name_plus = data_sets_to_check + "_"
			var container_name_from_data_set : String = ""
			var datapoint_node_now : Node
			var container_node_now : Node
			var data_array_now : Array = []
			var dictionary_size_now : int
			active_r_s_mut.lock()
			if active_record_sets.has(set_name_plus):
				var plus_records = set_name_plus + "records"
				current_containers_state[data_sets_to_check]["status_tree"] = "started_0"
				if active_record_sets[set_name_plus].has(plus_records):
					current_containers_state[data_sets_to_check]["status_tree"] = "started_1"
					if active_record_sets[set_name_plus][plus_records].has("content"):
						if active_record_sets[set_name_plus][plus_records]["content"] is Array:
							print(" hmm " , active_record_sets[set_name_plus][plus_records]["content"])
							if active_record_sets[set_name_plus][plus_records]["content"] != []:
								if active_record_sets[set_name_plus][plus_records]["content"][0][0][3][0] is String:
									if active_record_sets[set_name_plus][plus_records]["content"][0][0][3][0] != "container":
										container_name_from_data_set = active_record_sets[set_name_plus][plus_records]["content"][0][0][5][0]
										current_containers_state[data_sets_to_check]["status_tree"] = "started_2"
									else:
										container_name_from_data_set = active_record_sets[set_name_plus][plus_records]["content"][0][0][6][0]
										current_containers_state[data_sets_to_check]["status_tree"] = "started_3"
								else:
									print(" FATAL KURWA ERROR, 1")
							else:
								print(" FATAL KURWA ERROR, 2",  active_record_sets[set_name_plus][plus_records]["content"])
						else:
							print(" FATAL KURWA ERROR, 3")
					else:
						print(" FATAL KURWA ERROR, VERY IMPORTANT, DUNNO WHY IT HAPPENED, OH MY ")
				else:
					print(" FATAL KURWA ERROR, 0")
				state_of_check_0 = 1
				current_containers_state[data_sets_to_check]["three_i"].x = state_of_check_0
				active_r_s_mut.unlock()
			else:
				active_r_s_mut.unlock()
				cached_r_s_mutex.lock()
				if cached_record_sets.has(set_name_plus):
					var plus_records = set_name_plus + "records"
					current_containers_state[data_sets_to_check]["status_tree"] = "cached_0"
					if cached_record_sets[set_name_plus].has(plus_records):
						current_containers_state[data_sets_to_check]["status_tree"] = "cached_1"
						if cached_record_sets[set_name_plus][plus_records]["content"][0][0][3][0] != "container":
							container_name_from_data_set = cached_record_sets[set_name_plus][plus_records]["content"][0][0][5][0]
							current_containers_state[data_sets_to_check]["status_tree"] = "cached_2"
						else:
							container_name_from_data_set = cached_record_sets[set_name_plus][plus_records]["content"][0][0][6][0]
							current_containers_state[data_sets_to_check]["status_tree"] = "cached_3"
					state_of_check_0 = 0
					current_containers_state[data_sets_to_check]["three_i"].x = state_of_check_0
					cached_r_s_mutex.unlock()
				else:
					cached_r_s_mutex.unlock()
			if state_of_check_0 != -1:
				var container_name
				if container_name_from_data_set != "":
					container_name = container_name_from_data_set
				else:
					container_name = data_sets_to_check + "_container"
				current_containers_state[data_sets_to_check]["container_name"] = container_name
				tree_mutex.lock()
				if scene_tree_jsh.has("main_root"):
					if scene_tree_jsh["main_root"]["branches"].has(container_name):
						current_containers_state[data_sets_to_check]["status_tree"] = "started_4"
						if scene_tree_jsh["main_root"]["branches"][container_name].has("node"):
							print(" it has node, do we unload there ? nah it can go both ways")
							if is_instance_valid(scene_tree_jsh["main_root"]["branches"][container_name]["node"]):
								container_node_now = scene_tree_jsh["main_root"]["branches"][container_name]["node"]
							else:
								container_node_now = null
						else:
							container_node_now = null
							state_of_check_2 = -1
						if container_node_now:
							state_of_check_2 = 0
							current_containers_state[data_sets_to_check]["three_i"].z = state_of_check_2
							var container_name_for_trick = scene_tree_jsh["main_root"]["branches"][container_name]["name"]
							current_containers_state[data_sets_to_check]["status_tree"] = "started_5"
							var datapoint_path_now = scene_tree_jsh["main_root"]["branches"][container_name]["datapoint"]["datapoint_path"]
							datapoint_node_now = get_node(datapoint_path_now)
							if datapoint_node_now:
								current_containers_state[data_sets_to_check]["status_tree"] = "started_6"
								state_of_check_2 = 1
								current_containers_state[data_sets_to_check]["three_i"].z = state_of_check_2
								if datapoint_node_now.has_method("check_state_of_dictionary_and_three_ints_of_doom"):
									var data_array_now_ = datapoint_node_now.check_state_of_dictionary_and_three_ints_of_doom()
									current_containers_state[data_sets_to_check]["status_tree"] = "started_7"
									if data_array_now_ != null:
										data_array_now = data_array_now_
										if data_array_now[0] is Dictionary:
											current_containers_state[data_sets_to_check]["status_tree"] = "started_8"
											state_of_check_2 = 2
											current_containers_state[data_sets_to_check]["three_i"].z = state_of_check_2
						state_of_check_1 = 1
						current_containers_state[data_sets_to_check]["three_i"].y = state_of_check_1
						tree_mutex.unlock()
					else:
						tree_mutex.unlock()
						cached_tree_mutex.lock()
						if cached_jsh_tree_branches.has(container_name):
							current_containers_state[data_sets_to_check]["status_tree"] = "cached_4"
							state_of_check_1 = 0
							current_containers_state[data_sets_to_check]["three_i"].y = state_of_check_1
							cached_tree_mutex.unlock()
						else:
							mutex_for_trickery.lock()
							menace_tricker_checker = 1
							mutex_for_trickery.unlock()
							cached_tree_mutex.unlock()
				else:
					current_containers_state[data_sets_to_check]["status_tree"] = "fatal_kurwa_error"
					tree_mutex.unlock()
			if state_of_check_1 != -1:
				if state_of_check_2 != -1:
					print(" we even got nodes to tinker with")
			print(" alkaida is calling fbi xd :  ", data_sets_to_check , ", " , current_containers_state[data_sets_to_check]["three_i"])
	mutex_for_container_state.unlock()
	mutex_for_trickery.lock()
	if menace_tricker_checker == 2:
		print(" check is finished and we didnt get interupted while doing so kurwa ")
		menace_tricker_checker = 3
	mutex_for_trickery.unlock()

func the_basic_sets_creation():
	check_if_every_basic_set_is_loaded()
	if test_of_set_list_flow.size() > 0:
		print(" it is bigger than 0, we have sets to create ")

func get_every_basic_set():
	return BanksCombiner.data_sets_names_0

func get_every_basic_set_():
	return BanksCombiner.data_sets_names

func check_if_every_basic_set_is_loaded():
	var set_to_pull_now = JSH_records_system.check_basic_set_if_loaded()
	if set_to_pull_now:
		test_of_set_list_flow.append(set_to_pull_now)
		print(" set to pull now is : " , set_to_pull_now)

func container_finder(set_name):
	var wordly_word = set_name + BanksCombiner.data_names_0[0]
	active_r_s_mut.lock()
	var container_name_now = "akashic_records"
	if active_record_sets.has(set_name):
		if active_record_sets[set_name][wordly_word].has("content") and active_record_sets[set_name][wordly_word]["content"] != []:
			active_record_sets[set_name][wordly_word]
			container_name_now = active_record_sets[set_name][wordly_word]["content"][0][0][6][0]
	active_r_s_mut.unlock()
	var container_splitter = container_name_now.split("/")
	if container_splitter.size() > 1:
		container_name_now = container_splitter[0]
	return container_name_now

func initialize_menu(record_type: String):
	var records_set_name = record_type + "_"
	var use_active : bool = false
	var use_cached : bool = false
	var can_be_created : bool = false
	var state_of_active_check = check_record_in_active(records_set_name)
	var state_of_cached_check = check_record_in_cached(records_set_name)
	var set_limit_check = check_set_limit(records_set_name)
	var current_container_count_check = check_current_set_container_count(records_set_name)
	var record_set_type_check = check_record_set_type(records_set_name)
	print("catch current_container_count_check " , current_container_count_check, " in set " , record_type)
	print("catch initalize memories ! 0 : " , record_type)
	if state_of_active_check == 1:
		print("catch active is there ")
		use_active = true
	if state_of_cached_check == 1:
		print("catch cached have it ")
		use_cached = true
	if set_limit_check > current_container_count_check:
		print("catch we can still create ")
		can_be_created = true
	if can_be_created == true and use_active == false and use_cached == false:
		print("catch new checkers in initia menu new set must be created")
		create_record_from_script(record_type)
	elif can_be_created == true and use_active == true and use_cached == false:
		print("catch new checkers in initia menu it is in active, probably additional set can be created ", record_set_type_check)
		var additional_records_set_name = record_type + str(current_container_count_check)
		var aditional_cached = check_record_in_cached(additional_records_set_name)
		if aditional_cached == 1:
			print(" we had it in cache ")
			load_cached_record_to_active(additional_records_set_name)
			change_creation_set_name(record_type, additional_records_set_name)
			process_creation_further(additional_records_set_name, 1)
		else:
			print("catch some else ")
			create_additional_record_set(record_type, current_container_count_check)
			active_record_sets[records_set_name]["metadata"]["container_count"] +=1
			change_creation_set_name(record_type, additional_records_set_name)
			process_creation_further(additional_records_set_name, 1)
	elif can_be_created == true and use_active == false and use_cached == true:
		print("catch new checkers in initia menu it is in cached, we must move it around")
		load_cached_record_to_active(records_set_name)
		process_creation_further(record_type, 1)
	elif can_be_created == false:
		print("catch new checkers in initia menu we hit limit, cannot create more")
		process_creation_further(record_type, 7)


func find_record_set(record_type: String) -> Dictionary:
	match record_type:
		"base":
			return RecordsBank.records_map_0
		"menu":
			return RecordsBank.records_map_2
		"settings":
			return RecordsBank.records_map_3
		"keyboard":
			return RecordsBank.records_map_4
		"keyboard_left":
			return RecordsBank.records_map_5
		"keyboard_right":
			return RecordsBank.records_map_6
		"things_creation":
			return RecordsBank.records_map_7
		"singular_lines":
			return RecordsBank.records_map_8
		_:
			return {}

func find_instructions_set(record_type: String) -> Dictionary:
	match record_type:
		"base":
			return InstructionsBank.instructions_set_0
		"menu":
			return InstructionsBank.instructions_set_1
		"settings":
			return InstructionsBank.instructions_set_2
		"keyboard":
			return InstructionsBank.instructions_set_3
		"keyboard_left":
			return InstructionsBank.instructions_set_4
		"keyboard_right":
			return InstructionsBank.instructions_set_5
		"things_creation":
			return InstructionsBank.instructions_set_6
		"singular_lines":
			return InstructionsBank.instructions_set_7
		_:
			return {}

func find_scene_frames(record_type: String) -> Dictionary:
	match record_type:
		"base":
			return ScenesBank.scenes_frames_0
		"menu":
			return ScenesBank.scenes_frames_1
		"settings":
			return ScenesBank.scenes_frames_2
		"keyboard":
			return ScenesBank.scenes_frames_3
		"keyboard_left":
			return ScenesBank.scenes_frames_4
		"keyboard_right":
			return ScenesBank.scenes_frames_5
		"things_creation":
			return ScenesBank.scenes_frames_6
		"singular_lines":
			return ScenesBank.scenes_frames_7
		_:
			return {}

func find_interactions_list(record_type: String) -> Dictionary:
	match record_type:
		"base":
			return ActionsBank.interactions_list_0
		"menu":
			return ActionsBank.interactions_list_1
		"settings":
			return ActionsBank.interactions_list_2
		"keyboard":
			return ActionsBank.interactions_list_3
		"keyboard_left":
			return ActionsBank.interactions_list_4
		"keyboard_right":
			return ActionsBank.interactions_list_5
		"things_creation":
			return ActionsBank.interactions_list_6
		"singular_lines":
			return ActionsBank.interactions_list_7
		_:
			return {}

func record_mistake(mistake_data: Dictionary):
	history_tracking.mutex.lock()
	mistake_data["timestamp"] = Time.get_ticks_msec()
	history_tracking.mistakes.append(mistake_data)
	history_tracking.mutex.unlock()

func get_record_type_id(record_type: String) -> int:
	match record_type:
		"base":
			return 0
		"menu":
			return 1
		_:
			return -1

func get_cache_total_size() -> int:
	var total_size: int = 0
	cached_r_s_mutex.lock()
	for records_set in cached_record_sets:
		for record_type in cached_record_sets[records_set]:
			var data = cached_record_sets[records_set][record_type]
			total_size += get_dictionary_memory_size(data)
	cached_r_s_mutex.unlock()
	return total_size

func get_dictionary_memory_size(dict: Dictionary) -> int:
	var serialized = var_to_bytes(dict)
	return serialized.size()

func find_highest_in_array(numbers: Array) -> int:
	return numbers.max()

func new_function_for_creation_recovery(record_type_now, first_stage_of_creation_now, stage_of_creation_now):
	print(" fatal kurwa error 000 ", record_type_now , " , " , first_stage_of_creation_now, " , " , stage_of_creation_now)
	if load_queue_mutex.try_lock():
		print(" fatal kurwa error 00 load_queue_mutex ",)
	else:
		print(" fatal kurwa error 001 load_queue_mutex ",)
	array_with_no_mutex.append([record_type_now, first_stage_of_creation_now, stage_of_creation_now])

# Create Records

#                                                                                                           ,,          
#   .g8"""bgd                          mm               `7MM"""Mq.                                        `7MM          
# .dP'     `M                          MM                 MM   `MM.                                         MM          
# dM'       ``7Mb,od8 .gP"Ya   ,6"Yb.mmMMmm .gP"Ya        MM   ,M9  .gP"Ya   ,p6"bo   ,pW"Wq.`7Mb,od8  ,M""bMM  ,pP"Ybd 
# MM           MM' "',M'   Yb 8)   MM  MM  ,M'   Yb       MMmmdM9  ,M'   Yb 6M'  OO  6W'   `Wb MM' "',AP    MM  8I   `" 
# MM.          MM    8M""""""  ,pm9MM  MM  8M""""""       MM  YM.  8M"""""" 8M       8M     M8 MM    8MI    MM  `YMMMa. 
# `Mb.     ,'  MM    YM.    , 8M   MM  MM  YM.    ,       MM   `Mb.YM.    , YM.    , YA.   ,A9 MM    `Mb    MM  L.   I8 
#   `"bmmmd' .JMML.   `Mbmmd' `Moo9^Yo.`Mbmo`Mbmmd'     .JMML. .JMM.`Mbmmd'  YMbmd'   `Ybmd9'.JMML.   `Wbmd"MML.M9mmmP' 
#

func create_additional_record_set(record_type, current_container_count_check):
	var set_name_to_work_on = record_type + "_"
	active_r_s_mut.lock()
	var data_to_work_on_additional_set = active_record_sets[set_name_to_work_on].duplicate(true)
	active_r_s_mut.unlock()
	var datapoint_name_thing : String = ""
	var container_name_thing : String = ""
	var entire_array_of_scene_to_set : Array = []
	var amounts_of_instructions = data_to_work_on_additional_set[set_name_to_work_on + "instructions"]["content"].size() - 1
	amounts_of_instructions = amounts_of_instructions + current_container_count_check
	for stuffff in data_to_work_on_additional_set[set_name_to_work_on + "instructions"]["content"]:
		var type_of_instruction = stuffff[0][1][0]
		if type_of_instruction == "set_the_scene":
			entire_array_of_scene_to_set = stuffff
	var interaction_name = entire_array_of_scene_to_set[0][0][0]
	var new_interaction_split = interaction_name.split("_")
	var new_interaction_name = new_interaction_split[0] + "_" + str(amounts_of_instructions)
	entire_array_of_scene_to_set[0][0][0] = new_interaction_name
	entire_array_of_scene_to_set[1][2][0] = str(current_container_count_check)
	entire_array_of_scene_to_set[2][0][0] = str(current_container_count_check)
	data_to_work_on_additional_set[set_name_to_work_on + "instructions"] = {
		"header" = [new_interaction_name],
		"content" = [entire_array_of_scene_to_set]
	}
	data_to_work_on_additional_set[set_name_to_work_on + "scenes"]
	var scene_name_to_take = data_to_work_on_additional_set[set_name_to_work_on + "scenes"]["header"][current_container_count_check]
	var scene_array_to_take = data_to_work_on_additional_set[set_name_to_work_on + "scenes"]["content"][current_container_count_check]
	data_to_work_on_additional_set[set_name_to_work_on + "scenes"] = {
		"header" = [scene_name_to_take],
		"content" = [scene_array_to_take]
	}
	var amount_of_things = data_to_work_on_additional_set[set_name_to_work_on + "records"]["header"].size()
	var container_informations
	var first_counter : int = -1
	for stufff in data_to_work_on_additional_set[set_name_to_work_on + "records"]["content"]:
		first_counter +=1
		var thing_name_find = stufff[0][3][0]
		var thing_number_name_find = stufff[0][0][0]
		if thing_name_find == "container":
			container_name_thing = thing_number_name_find
			container_informations = data_to_work_on_additional_set[set_name_to_work_on + "records"]["content"][first_counter]
			data_to_work_on_additional_set[set_name_to_work_on + "records"]["content"][first_counter] = []
		elif thing_name_find == "datapoint":
			datapoint_name_thing = thing_number_name_find
			data_to_work_on_additional_set[set_name_to_work_on + "records"]["content"][first_counter] = []
		if container_name_thing != "" and datapoint_name_thing != "":
			break
	var container_name = container_informations[1][0][0]
	if datapoint_name_thing != "":
		data_to_work_on_additional_set[set_name_to_work_on + "records"]["content"].erase([])
		amount_of_things -=1
	if container_name_thing != "":
		data_to_work_on_additional_set[set_name_to_work_on + "records"]["content"].erase([])
		amount_of_things -=1
	amount_of_things = amount_of_things * current_container_count_check
	var second_counter : int = -1
	var counter_of_finish : int = 0
	for stufff_0 in data_to_work_on_additional_set[set_name_to_work_on + "records"]["header"]:
		second_counter +=1
		if stufff_0 == container_name_thing:
			data_to_work_on_additional_set[set_name_to_work_on + "records"]["header"][second_counter] = ""
			counter_of_finish +=1
		elif stufff_0 == datapoint_name_thing:
			data_to_work_on_additional_set[set_name_to_work_on + "records"]["header"][second_counter] = ""
			counter_of_finish +=1
		if counter_of_finish == 2:
			break
	if datapoint_name_thing != "":
		data_to_work_on_additional_set[set_name_to_work_on + "records"]["header"].erase("")
	if container_name_thing != "":
		data_to_work_on_additional_set[set_name_to_work_on + "records"]["header"].erase("")
	continue_recreation(data_to_work_on_additional_set, datapoint_name_thing, container_name_thing, set_name_to_work_on, current_container_count_check, record_type, amount_of_things, container_name)

func continue_recreation(data_to_work_on_additional_set, datapoint_name_thing, container_name_thing, set_name_to_work_on, current_container_count_check, record_type, amount_of_things, container_name):
	var just_thing : String = "thing_"
	var just_interaction : String = "interaction_"
	var just_path_now : String = container_name + "/" + just_thing
	var parts_to_change = BanksCombiner.data_names_3
	for part_now in parts_to_change:
		var part_name = set_name_to_work_on + part_now
		if data_to_work_on_additional_set.has(part_name):
			for stuff in data_to_work_on_additional_set[part_name]:
				if data_to_work_on_additional_set[part_name].has(stuff):
					var counting_int_0 : int = -1
					for recreation_0 in data_to_work_on_additional_set[part_name][stuff]:
						counting_int_0 +=1
						if stuff == "header":
							if recreation_0 is String:
								if recreation_0.begins_with(just_thing):
									var split_recreation_0 = recreation_0.split("_")
									var thing_name_split = split_recreation_0[0]
									var number_of_that_thing : int = int(split_recreation_0[1]) + amount_of_things
									var new_recreation_0 = thing_name_split + "_" + str(number_of_that_thing)
									data_to_work_on_additional_set[part_name][stuff][counting_int_0] = new_recreation_0
								elif recreation_0.begins_with(just_interaction):
									var split_recreation_0 = recreation_0.split("_")
									var interaction_name_split = split_recreation_0[0]
									var number_of_that_interaction : int = int(split_recreation_0[1]) + amount_of_things
									var new_recreation_0  = interaction_name_split + "_" + str(number_of_that_interaction)
									data_to_work_on_additional_set[part_name][stuff][counting_int_0] = new_recreation_0
						elif stuff == "content":
							var counting_int_1 : int = -1
							for stuff_to_find in recreation_0:
								counting_int_1 +=1
								if stuff_to_find is String:
									print(" recreator 2.0a we found string 0")
								else:
									var counting_int_2 : int = -1
									for stuff_to_find_0 in stuff_to_find:
										counting_int_2 +=1
										if stuff_to_find_0 is String:
											print(" recreator 2.0a we found string 1")
										else:
											var counting_int_3 : int = -1
											for stuff_to_find_1 in stuff_to_find_0:
												counting_int_3 +=1
												if stuff_to_find_1 is String:
													if stuff_to_find_1.begins_with(just_thing):
														if stuff_to_find_1 != datapoint_name_thing and stuff_to_find_1 != container_name_thing:
															var split_recreation_0 = stuff_to_find_1.split("_")
															var thing_name_split = split_recreation_0[0]
															var number_of_that_thing : int = int(split_recreation_0[1]) + amount_of_things
															var new_stuff_to_find_1 = thing_name_split + "_" + str(number_of_that_thing)
															data_to_work_on_additional_set[part_name][stuff][counting_int_0][counting_int_1][counting_int_2][counting_int_3] = new_stuff_to_find_1
													elif stuff_to_find_1.begins_with(just_interaction):
														var split_recreation_0 = stuff_to_find_1.split("_")
														var interaction_name_split = split_recreation_0[0]
														var number_of_that_interaction : int = int(split_recreation_0[1]) + amount_of_things
														var new_stuff_to_find_1 = interaction_name_split + "_" + str(number_of_that_interaction)
														data_to_work_on_additional_set[part_name][stuff][counting_int_0][counting_int_1][counting_int_2][counting_int_3] = new_stuff_to_find_1
													elif stuff_to_find_1.begins_with(just_path_now):
														var first_path_split = stuff_to_find_1.split("/")
														var second_split_of_thing = first_path_split[1].split("_")
														var first_merge = first_path_split[0] + "/" + second_split_of_thing[0] + "_"
														var number_of_that_thing : int = int(second_split_of_thing[1]) + amount_of_things
														var new_path_now = first_merge + str(number_of_that_thing)
														data_to_work_on_additional_set[part_name][stuff][counting_int_0][counting_int_1][counting_int_2][counting_int_3] = new_path_now
												else:
													print(" recreator 2.0a we could go deeper? ")
	var additional_set_name = record_type + str(current_container_count_check) + "_"
	active_r_s_mut.lock()
	active_record_sets[additional_set_name] = {}
	active_record_sets[additional_set_name][additional_set_name + "records"] = data_to_work_on_additional_set[set_name_to_work_on + "records"]
	active_record_sets[additional_set_name][additional_set_name + "scenes"] = data_to_work_on_additional_set[set_name_to_work_on + "scenes"]
	active_record_sets[additional_set_name][additional_set_name + "interactions"] = data_to_work_on_additional_set[set_name_to_work_on + "interactions"]
	active_record_sets[additional_set_name][additional_set_name + "instructions"] = data_to_work_on_additional_set[set_name_to_work_on + "instructions"]
	active_r_s_mut.unlock()

func create_record_from_script(record_type):
	var type_of_data : int
	var datapoint_node
	var records : Dictionary
	var current_data_pack_loaded
	var records_part : String
	var records_name : String
	records_part = ""
	match record_type:
		"base":
			current_data_pack_loaded = BanksCombiner.combination_0
			records_part = "base_"
		"menu":
			current_data_pack_loaded = BanksCombiner.combination_1
			records_part = "menu_"
		"settings":
			current_data_pack_loaded = BanksCombiner.combination_2
			records_part = "settings_"
		"keyboard":
			current_data_pack_loaded = BanksCombiner.combination_3
			records_part = "keyboard_"
		"keyboard_left":
			current_data_pack_loaded = BanksCombiner.combination_4
			records_part = "keyboard_left_"
		"keyboard_right":
			current_data_pack_loaded = BanksCombiner.combination_5
			records_part = "keyboard_right_"
		"things_creation":
			current_data_pack_loaded = BanksCombiner.combination_6
			records_part = "things_creation_"
		"singular_lines":
			current_data_pack_loaded = BanksCombiner.combination_7
			records_part = "singular_lines_"
		_:
			return {}
	for data_types in current_data_pack_loaded:
		type_of_data = data_types[0]
		match type_of_data:
			0:
				records = find_record_set(record_type)
				records_name = records_part + "records"
			1:
				records = find_instructions_set(record_type)
				records_name = records_part + "instructions"
			2: 
				records = find_scene_frames(record_type)
				records_name = records_part + "scenes"
			3:
				records = find_interactions_list(record_type)
				records_name = records_part + "interactions"
		load_record_set(records_part, records_name, type_of_data, records)
	process_creation_further(record_type, 1)

func find_record_set_new_file_finder(data):
	print("find it", data)

func process_creation_request(set_name: String) -> Dictionary:
	var result = {
		"status": CreationStatus.ERROR,
		"message": "",
		"timestamp": Time.get_ticks_msec()
	}
	if not is_creation_possible():
		result.status = CreationStatus.LOCKED
		result.message = "Creation system is not active"
		return result
	var creation_result = whip_out_set_by_its_name(set_name)
	match creation_result:
		CreationStatus.SUCCESS:
			result.status = CreationStatus.SUCCESS
			result.message = "Set created successfully"
		CreationStatus.ERROR:
			record_mistake({
				"type": "creation_error",
				"set_name": set_name,
				"error": "Creation failed"
			})
			result.message = "Failed to create set"
		_:
			result.message = "Unexpected creation status"
	return result

func prepare_akashic_records_init():
	first_start_check = "started"
	var main_sets_names = BanksCombiner.dataSetLimits
	var main_sets_names_just_names = BanksCombiner.data_sets_names_0
	var main_sets_names_with_underscore = BanksCombiner.data_sets_names
	array_of_startup_check.append(first_start_check)
	array_of_startup_check.append([["akashic_records"],["base"],["menu"]])
	var stuck_status = check_thread_status()
	before_time_blimp(0, 0)
	array_of_startup_check.append(main_sets_names)
	array_of_startup_check.append(main_sets_names_just_names)
	array_of_startup_check.append(main_sets_names_with_underscore)
	if stuck_status == "error":
		print(" timer check omething went wrong, use a timer")

func load_record_set(records_part: String, record_type: String, type_of_data : int, records : Dictionary) -> void:
	var max_nunmber_of_thingy = BanksCombiner.dataSetLimits[records_part]
	var current_number_of_that_set : int = 0
	if !active_record_sets.has(records_part):
		current_number_of_that_set = 1
	var list_of_reliquaries : Array = [] 
	var codices : Array = [] 
	var current_record_line : Array = []
	for current_record_to_process in records:
		var another_array_damn : Array = []
		var string_splitter
		for current_part in records[current_record_to_process]:
			string_splitter = current_part[0].split("|")
			var string_to_be_splitted
			var tomes_of_knowledge : Array = []
			for stringy_string in string_splitter:
				string_to_be_splitted = stringy_string.split(",")
				tomes_of_knowledge.append(string_to_be_splitted)
			current_record_line.append(string_splitter[0])
			another_array_damn.append(tomes_of_knowledge)
		codices.append(another_array_damn)
		list_of_reliquaries.append(current_record_line[0])
		current_record_line.clear()
	var string_header : String = "header"
	var string_content : String = "content"
	var records_processed : Dictionary = {}
	records_processed[string_header] =  list_of_reliquaries
	records_processed[string_content] = codices
	if active_record_sets.has(records_part):
		if active_record_sets[records_part].has(record_type):
			return
	if not active_record_sets.has(records_part):
		active_record_sets[records_part] = {
			"metadata": {
				"timestamp": Time.get_ticks_msec(),
				"container_count": current_number_of_that_set,
				"max_containers": max_nunmber_of_thingy
			}
		}
	if records.size() > 0:
		active_record_sets[records_part][record_type] = records_processed

#                                      ,,                                                          ,,          
# `7MMF'                             `7MM      `7MM"""Mq.                                        `7MM          
#   MM                                 MM        MM   `MM.                                         MM          
#   MM         ,pW"Wq.   ,6"Yb.   ,M""bMM        MM   ,M9  .gP"Ya   ,p6"bo   ,pW"Wq.`7Mb,od8  ,M""bMM  ,pP"Ybd 
#   MM        6W'   `Wb 8)   MM ,AP    MM        MMmmdM9  ,M'   Yb 6M'  OO  6W'   `Wb MM' "',AP    MM  8I   `" 
#   MM      , 8M     M8  ,pm9MM 8MI    MM        MM  YM.  8M"""""" 8M       8M     M8 MM    8MI    MM  `YMMMa. 
#   MM     ,M YA.   ,A9 8M   MM `Mb    MM        MM   `Mb.YM.    , YM.    , YA.   ,A9 MM    `Mb    MM  L.   I8 
# .JMMmmmmMMM  `Ybmd9'  `Moo9^Yo.`Wbmd"MML.    .JMML. .JMM.`Mbmmd'  YMbmd'   `Ybmd9'.JMML.   `Wbmd"MML.M9mmmP' 

# Load Records

func load_cached_data(data_set: String):
	var type_of_data : int
	var records_set_name = data_set
	active_r_s_mut.lock()
	var cached_data_new = active_record_sets[records_set_name].duplicate(true)
	active_r_s_mut.unlock()
	var thing_name
	var coords_to_place
	var direction_to_place
	var thing_type_file
	var shape_name
	var root_name
	var pathway_dna
	var group_number
	var counter_to_know : int = 0
	var first_line : Array = []
	var lines_parsed : Array = []
	for data_type in BanksCombiner.combination_new_gen_0:
		counter_to_know = 0
		type_of_data = int(data_type[0])
		var type_num = data_type[0]
		var data_name = records_set_name + BanksCombiner.data_names_0[type_num]
		var file_data = cached_data_new[data_name]["content"]
		var size_of_data = file_data.size()
		for record in file_data:
			counter_to_know +=1
			for lines in record:
				if lines == record[0]:
					first_line = record[0]
				else:
					lines_parsed.append(lines)
			match type_of_data:
				0:
					thing_name = first_line[0][0]
					coords_to_place = first_line[1][0]
					direction_to_place = first_line[2][0]
					thing_type_file = first_line[3][0]
					shape_name = first_line[4][0]
					root_name = first_line[5][0]
					pathway_dna = first_line[6][0]
					group_number = first_line[7][0]
				1:
					pass
				2:
					pass
				3:
					pass
			match type_of_data:
				0:
					analise_data(thing_name, thing_type_file, first_line, lines_parsed[0], group_number, shape_name, lines_parsed)
				1:
					print("instruction stuff:")
				2: 
					print(" scenes and frames analise : ")
				3: 
					print("so we will need to add them to datapoint")
					if counter_to_know - 666 == size_of_data:
						var container_node_path = first_line[1][0]
						var container_node = get_node(container_node_path)
						var datapoint_node = container_node.get_datapoint()
						var scene_number: int = 0
						datapoint_node.move_things_around(scene_number)
			first_line.clear()
			lines_parsed.clear()

#                                                                                                   ,,          
# `7MMM.     ,MMF'                              `7MM"""Mq.                                        `7MM          
#   MMMb    dPMM                                  MM   `MM.                                         MM          
#   M YM   ,M MM  ,pW"Wq.`7M'   `MF'.gP"Ya        MM   ,M9  .gP"Ya   ,p6"bo   ,pW"Wq.`7Mb,od8  ,M""bMM  ,pP"Ybd 
#   M  Mb  M' MM 6W'   `Wb VA   ,V ,M'   Yb       MMmmdM9  ,M'   Yb 6M'  OO  6W'   `Wb MM' "',AP    MM  8I   `" 
#   M  YM.P'  MM 8M     M8  VA ,V  8M""""""       MM  YM.  8M"""""" 8M       8M     M8 MM    8MI    MM  `YMMMa. 
#   M  `YM'   MM YA.   ,A9   VVV   YM.    ,       MM   `Mb.YM.    , YM.    , YA.   ,A9 MM    `Mb    MM  L.   I8 
# .JML. `'  .JMML.`Ybmd9'     W     `Mbmmd'     .JMML. .JMM.`Mbmmd'  YMbmd'   `Ybmd9'.JMML.   `Wbmd"MML.M9mmmP' 

# Move Records

func load_cached_record_to_active(records_set_name):

	active_r_s_mut.lock()
	cached_r_s_mutex.lock()
	active_record_sets[records_set_name] = cached_record_sets[records_set_name].duplicate(true)
	active_record_sets[records_set_name]["metadata"]["container_count"] +=1
	cached_record_sets.erase(records_set_name)
	active_r_s_mut.unlock()
	cached_r_s_mutex.unlock()

func deep_copy_dictionary(original: Dictionary) -> Dictionary:
	var json_string = JSON.stringify(original)
	var parsed = JSON.parse_string(json_string)
	return parsed

func clean_oldest_dataset() -> void:
	var oldest_time = Time.get_ticks_msec()
	var oldest_set = ""
	for timestamp_key in cache_timestamps:
		if cache_timestamps[timestamp_key] < oldest_time:
			oldest_time = cache_timestamps[timestamp_key]
			oldest_set = timestamp_key.split("_")[0]
	if oldest_set != "":
		cached_r_s_mutex.lock()
		cached_record_sets.erase(oldest_set + "_")
		cached_r_s_mutex.unlock()
		var to_remove = []
		for timestamp_key in cache_timestamps:
			if timestamp_key.begins_with(oldest_set):
				to_remove.append(timestamp_key)
		for key in to_remove:
			cache_timestamps.erase(key)

func process_to_unload_records(container_name_to_unload):
	var parts = container_name_to_unload.split("_")
	if parts.size() < 2:
		return
	var records_sets_name
	if parts.size() > 2:
		records_sets_name = parts[0] + "_" + parts[1]
	else:
		records_sets_name = parts[0]
	var counter_for_rec_ty : int = 0
	active_r_s_mut.lock()
	if active_record_sets[records_sets_name + "_" ].has("metadata"):
		active_record_sets[records_sets_name + "_" ]["metadata"]["container_count"] = 0
		active_r_s_mut.unlock()
		for records_types in BanksCombiner.combination_0:
			var record_to_unloadin = records_sets_name + "_" + BanksCombiner.data_names_0[counter_for_rec_ty]
			counter_for_rec_ty +=1
			unload_record_set(records_sets_name , record_to_unloadin)
		active_r_s_mut.lock()
		active_record_sets[records_sets_name + "_" ].erase("metadata")
		active_r_s_mut.unlock()
	else:
		active_r_s_mut.unlock()

func unload_record_set(records_sets_name : String, record_type: String) -> void:
	records_sets_name = records_sets_name + "_"
	active_r_s_mut.lock()
	if active_record_sets.has(records_sets_name):
		if active_record_sets[records_sets_name].has(record_type):
			var data = active_record_sets[records_sets_name][record_type]
			var meta_data = active_record_sets[records_sets_name]["metadata"]
			active_r_s_mut.unlock()
			cache_data(records_sets_name, record_type, data, meta_data)
			active_r_s_mut.lock()
			active_record_sets[records_sets_name].erase(record_type)
			active_r_s_mut.unlock()
		else:
			active_r_s_mut.unlock()
	else:
		active_r_s_mut.unlock()

func cache_data(records_sets_name: String, record_type: String, data, meta_data) -> void:
	var current_cache_size = get_cache_total_size()
	var new_data_size = get_dictionary_memory_size(data)
	var max_size_bytes = max_cache_size_mb * 1024 * 1024
	if current_cache_size + new_data_size > max_size_bytes:
		clean_oldest_dataset()
	current_cache_size = get_cache_total_size()
	cached_r_s_mutex.lock()
	if current_cache_size + new_data_size <= max_size_bytes:
		if !cached_record_sets.has(records_sets_name):
			active_r_s_mut.lock()
			cached_record_sets[records_sets_name] = { 
				"metadata": active_record_sets[records_sets_name]["metadata"].duplicate(true)
			}
			active_r_s_mut.unlock()
		cached_record_sets[records_sets_name][record_type] = data.duplicate(true)
		cached_record_sets[records_sets_name]["metadata"][str(record_type)] = {
			"size": new_data_size,
			"time_of_cache" : Time.get_ticks_msec()
		}
		cache_timestamps[records_sets_name + record_type] = Time.get_ticks_msec()
	else:
		print("Cache limit reached, cannot store new data")
	cached_r_s_mutex.unlock()

#               ,,                                                                                                      ,,          
#   .g8"""bgd `7MM                                                  `7MM"""Mq.                                        `7MM          
# .dP'     `M   MM                                                    MM   `MM.                                         MM          
# dM'       `   MMpMMMb.   ,6"Yb.  `7MMpMMMb.  .P"Ybmmm .gP"Ya        MM   ,M9  .gP"Ya   ,p6"bo   ,pW"Wq.`7Mb,od8  ,M""bMM  ,pP"Ybd 
# MM            MM    MM  8)   MM    MM    MM :MI  I8  ,M'   Yb       MMmmdM9  ,M'   Yb 6M'  OO  6W'   `Wb MM' "',AP    MM  8I   `" 
# MM.           MM    MM   ,pm9MM    MM    MM  WmmmP"  8M""""""       MM  YM.  8M"""""" 8M       8M     M8 MM    8MI    MM  `YMMMa. 
# `Mb.     ,'   MM    MM  8M   MM    MM    MM 8M       YM.    ,       MM   `Mb.YM.    , YM.    , YA.   ,A9 MM    `Mb    MM  L.   I8 
#   `"bmmmd'  .JMML  JMML.`Moo9^Yo..JMML  JMML.YMMMMMb  `Mbmmd'     .JMML. .JMM.`Mbmmd'  YMbmd'   `Ybmd9'.JMML.   `Wbmd"MML.M9mmmP' 
#                                             6'     dP                                                                             
#                                             Ybmmmd'                                                                               

# Change Records

func add_container_count(records_set_name):
	active_r_s_mut.lock()
	if active_record_sets.has(records_set_name):
		if active_record_sets[records_set_name].has("metadata"):
			if active_record_sets[records_set_name]["metadata"].has("container_count"):
				active_record_sets[records_set_name]["metadata"]["container_count"] +=1
			else:
				print(" metadata has no container count ")
		else:
			print(" set has no metadata ")
	else:
		print(" we dont have that set ")
	active_r_s_mut.unlock()

func recreator(number_to_add, data_to_process, data_set_name, new_name_for_set):
	var initial_number_to_add : int = int(number_to_add)
	print(" recreator whats wrong")
	print(" new_name_for_set : " , new_name_for_set)
	var processed_data : Dictionary
	var data_to_work_on = data_to_process.duplicate(true)
	var container_path = data_set_name + "_container/thing_"
	var patterns = ["thing_" , container_path ]
	var number_we_wanna_add : int
	var container_name_to_free
	var data_type_name_combined_first = data_set_name + "_" + BanksCombiner.data_names_0[0]
	var tasks_to_be_done : int = 0
	var datapoint_name
	var datapoint_container_name
	for container_to_find in data_to_work_on[data_type_name_combined_first]["content"]:
		#for
		if container_to_find[0][3][0] == "container":
			container_name_to_free = container_to_find[0][0][0]
			container_to_find.clear()
			#break
			break
	data_to_work_on[data_type_name_combined_first]["content"].erase([])
	#for
	for data_types in BanksCombiner.data_names_0:
		var data_type_name_combined = data_set_name + "_" + data_types
		print(data_set_name + "_" + data_types)
		for data_to_be_parsed_1 in data_to_work_on[data_type_name_combined]: 
			if data_to_be_parsed_1 == "header":
				if BanksCombiner.data_names_0[0] == data_types:
					number_we_wanna_add = data_to_work_on[data_type_name_combined][data_to_be_parsed_1].size()
					var counter_for_header_strings : int = 0
					for container_name_to_find in data_to_work_on[data_type_name_combined][data_to_be_parsed_1]:
						if container_name_to_find == container_name_to_free:
							container_name_to_find = ""
							data_to_work_on[data_type_name_combined][data_to_be_parsed_1][counter_for_header_strings] = ""
							data_to_work_on[data_type_name_combined][data_to_be_parsed_1].erase("")
							counter_for_header_strings +=1
							break
			var counter_new_0 : int = 0
			for data_to_be_parsed_2 in data_to_work_on[data_type_name_combined][data_to_be_parsed_1]:
				if data_to_be_parsed_2 is String:
					for pattern in patterns:
						if data_to_be_parsed_2.begins_with(pattern):
							var string_to_change = data_to_be_parsed_2.split("_")
							var size_of_array = string_to_change.size() -1
							string_to_change[size_of_array] = str(int(string_to_change[size_of_array]) + number_we_wanna_add)
							string_to_change = "_".join(string_to_change)
							data_to_work_on[data_type_name_combined][data_to_be_parsed_1][counter_new_0] = string_to_change
				if data_to_be_parsed_2 is Array:
					print(" recreator data_types : " , data_types)
					if data_types == "instructions":
						print(" recreator_check : 0 : ", data_to_be_parsed_2[0][1][0])
						print(" recreator_check : 0 : ", data_to_be_parsed_2[2][0][0])
						if data_to_be_parsed_2[0][1][0] == "set_the_scene":
							print(" recreator_check : 0 :  we found that set the scene " , number_to_add , " for   " , new_name_for_set)
							data_to_be_parsed_2[2][0][0][0] = str(number_to_add)
							#break
					if initial_number_to_add == 1:
						if data_types == "scenes":
							print(" recreator_check : 10 : ", data_to_be_parsed_2[0][0], " and number_to_add : " , number_to_add)
							print(" recreator_check : 11 : ", data_to_be_parsed_2)
							var scene_number = data_to_be_parsed_2[0][0][0].substr(6, data_to_be_parsed_2[0][0][0].length()) #scene)
							print(" recreator_check : 12 : ", scene_number)
							number_to_add = scene_number
							print(" recreator_check : 14 number_to_add " , number_to_add)
						if data_types == "interactions":
							number_to_add = initial_number_to_add
							print(" recreator_check : 15 number_to_add " , number_to_add)
					else:
						break
					print(" recreator data_types : continuation : " , data_types)
					if data_to_be_parsed_2.size() > 1:
						var counter_new_1 : int = 0
						var counter_helper : int = 0
						for data_to_be_parsed_3 in data_to_be_parsed_2:
							if data_to_be_parsed_3 is String:
								for pattern in patterns:
									if data_to_be_parsed_3.begins_with(pattern):
										var string_to_change = data_to_be_parsed_3.split("_")
										var size_of_array = string_to_change.size() -1
										string_to_change[size_of_array] = str(int(string_to_change[size_of_array]) + number_we_wanna_add)
										string_to_change = "_".join(string_to_change)
										data_to_be_parsed_3 = string_to_change
										counter_helper +=1
							if data_to_be_parsed_3 is Array:
								if data_to_be_parsed_3.size() > 1:
									var counter_new_2 : int = 0
									for data_to_be_parsed_4 in data_to_be_parsed_3:
										if data_to_be_parsed_4[0] is String:
											for pattern in patterns:
												if data_to_be_parsed_4[0].begins_with(pattern):
													var string_to_change = data_to_be_parsed_4[0].split("_")
													var size_of_array = string_to_change.size() -1
													string_to_change[size_of_array] = str(int(string_to_change[size_of_array]) + number_we_wanna_add)
													string_to_change = "_".join(string_to_change)
													data_to_be_parsed_4[0] = string_to_change
										counter_new_2 +=1
							counter_new_1 +=1
				counter_new_0 +=1
				
	#for
	for container_to_find in data_to_work_on[data_type_name_combined_first]["content"]:
		if container_to_find[0][3][0] == "datapoint":
			datapoint_name = container_to_find[0][0][0]
			datapoint_container_name = container_to_find[0][5][0]
			#break
			break
	#for
	for data_types in BanksCombiner.data_names_0:
		var data_type_name_combined = data_set_name + "_" + data_types
		var data_type_name_combined_new = new_name_for_set + data_types
		print(data_set_name + "_" + data_types)
		#for
		for data_to_be_parsed_1 in data_to_work_on[data_type_name_combined]: 
			processed_data[data_type_name_combined_new] = data_to_work_on[data_type_name_combined].duplicate(true)
	processed_data["metadata"] = {
				"timestamp": Time.get_ticks_msec(),
				"datapoint_name": datapoint_name,
				"datapoint_container_name": datapoint_container_name
			} 
	print(" recreator : ", processed_data)
	##return
	return processed_data

####################
#
# JSH Scene Tree System

#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓         ┏┳┓        ┏┓        
#       888  `"Y8888o.   888ooooo888     ┗┓┏┏┓┏┓┏┓   ┃ ┏┓┏┓┏┓  ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗┗ ┛┗┗    ┻ ┛ ┗ ┗   ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888                              ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            

#
# JSH Scene Tree System
# Check Branch/ Leaf

#              ,,                                                                                     ,,             AW                                       ,...
#  .g8"""bgd `7MM                       `7MM          `7MM"""Yp,                                    `7MM            ,M'     `7MMF'                          .d' ""
#.dP'     `M   MM                         MM            MM    Yb                                      MM            MV        MM                            dM`   
#dM'       `   MMpMMMb.  .gP"Ya   ,p6"bo  MM  ,MP'      MM    dP `7Mb,od8 ,6"Yb.  `7MMpMMMb.  ,p6"bo  MMpMMMb.     AW         MM         .gP"Ya   ,6"Yb.   mMMmm  
#MM            MM    MM ,M'   Yb 6M'  OO  MM ;Y         MM"""bg.   MM' "'8)   MM    MM    MM 6M'  OO  MM    MM    ,M'         MM        ,M'   Yb 8)   MM    MM    
#MM.           MM    MM 8M"""""" 8M       MM;Mm         MM    `Y   MM     ,pm9MM    MM    MM 8M       MM    MM    MV          MM      , 8M""""""  ,pm9MM    MM    
#`Mb.     ,'   MM    MM YM.    , YM.    , MM `Mb.       MM    ,9   MM    8M   MM    MM    MM YM.    , MM    MM   AW           MM     ,M YM.    , 8M   MM    MM    
#  `"bmmmd'  .JMML  JMML.`Mbmmd'  YMbmd'.JMML. YA.    .JMMmmmd9  .JMML.  `Moo9^Yo..JMML  JMML.YMbmd'.JMML  JMML.,M'         .JMMmmmmMMM  `Mbmmd' `Moo9^Yo..JMML.  
#                                                                                                               MV                                                
#                                                                                                              AW                                                 

# Check Branch/ Leaf

func check_if_container_available(container):
	tree_mutex.lock()
	if scene_tree_jsh["main_root"]["branches"].has(container):
		tree_mutex.unlock()
		print(" lets check the structure ")
		return true
	else:
		tree_mutex.unlock()
		return false
	tree_mutex.unlock()

func check_if_datapoint_available(container):
	tree_mutex.lock()
	if scene_tree_jsh["main_root"]["branches"][container].has("datapoint"):
		tree_mutex.unlock()
		return true
	else:
		tree_mutex.unlock()
		return false
	tree_mutex.unlock()

func check_if_datapoint_node_available(container):
	tree_mutex.lock()
	var datapoint_path = scene_tree_jsh["main_root"]["branches"][container]["datapoint"]["datapoint_path"]
	tree_mutex.unlock()
	return datapoint_path

func build_pretty_print(node: Node, prefix: String = "", is_last: bool = true) -> String:
	var output = ""
	output += prefix
	output += "┖╴" if is_last else "┠╴"
	output += node.name + "\n"
	var children = node.get_children()
	for i in range(children.size()):
		var child = children[i]
		var child_prefix = prefix + ("   " if is_last else "┃  ")
		var child_is_last = i == children.size() - 1
		output += build_pretty_print(child, child_prefix, child_is_last)
	return output

func find_branch_to_unload(thing_path):
	var new_path_splitter = str(thing_path).split("/")
	tree_mutex.lock()
	if scene_tree_jsh["main_root"]["branches"][new_path_splitter[0]]["children"].has(new_path_splitter[1]):
		var branch_part_to_cache = scene_tree_jsh["main_root"]["branches"][new_path_splitter[0]]["children"][new_path_splitter[1]].duplicate(true)
		var branch_name_to_cache = new_path_splitter[0]
		var child_name_to_cache = new_path_splitter[1]
		tree_mutex.unlock()
		cache_branch(branch_name_to_cache, child_name_to_cache, branch_part_to_cache)
		tree_mutex.lock()
		scene_tree_jsh["main_root"]["branches"][new_path_splitter[0]]["children"].erase(new_path_splitter[1])
		tree_mutex.unlock()
	else:
		tree_mutex.unlock()
	array_counting_mutex.lock()
	if array_for_counting_finish.has(new_path_splitter[0]):
		if array_for_counting_finish[new_path_splitter[0]].has(new_path_splitter[1]):
			print(" cache branch we can unload that node ", new_path_splitter[1])
			array_for_counting_finish[new_path_splitter[0]].erase(new_path_splitter[1])
		else:
			print(" cache branch that node does not exist in that container", new_path_splitter[0])
	else:
		print(" cache branch that container does not exist")
	array_counting_mutex.unlock()

func check_tree_branches():
	tree_mutex.lock()
	if scene_tree_jsh.has("main_root"):
		if scene_tree_jsh.has("branches"):
			tree_mutex.unlock()
			return true
		else:
			tree_mutex.unlock()
			return false
	else:
		tree_mutex.unlock()
		return null
	tree_mutex.unlock()

func print_tree_structure(branch: Dictionary, indent: int = 0):
	tree_mutex.lock()
	var indent_str = "  ".repeat(indent)
	var status = branch.get("status", "pending") 
	print("%s%s (%s) %s" % [
		indent_str, 
		branch["name"], 
		branch["type"],
		status_symbol[status]
	])
	if branch.has("metadata"):
		var metadata = branch["metadata"]
		if metadata.get("has_collision", false):
			print("%s  └─ Has Collision" % indent_str)
		if metadata.get("has_area", false):
			print("%s  └─ Has Area" % indent_str)
	if branch.has("branches"):
		for child in branch["branches"].values():
			tree_mutex.unlock()
			print_tree_structure(child, indent + 1)
	elif branch.has("children"):
		for child in branch["children"].values():
			tree_mutex.unlock()
			print_tree_structure(child, indent + 1)
	tree_mutex.unlock()

func jsh_tree_get_node(node_path_get_node: String) -> Node:
	var path_parts = node_path_get_node.split("/")
	tree_mutex.lock()
	var current = scene_tree_jsh["main_root"]["branches"]
	for part in path_parts:
		if current.has(part):
			current = current[part]
			if path_parts[-1] == part:
				
				tree_mutex.unlock()
				return current["node"]
			else:
				current = current["children"]
	tree_mutex.unlock()
	return null

func containers_list_creator():
	mutex_for_container_state.lock()
	if current_containers_state.size() > 0:
		print(" fatal kurwa error : ", current_containers_state)
		print("checkerrr bigger list than 0 ")
		for data_sets_to_check in current_containers_state: 
			var three_iii : Vector3i
			var current_state_0 : int = -1
			var current_state_1 : int = -1
			var current_state_2 : int = -1
			three_iii.x = current_state_0
			three_iii.y = current_state_1
			three_iii.z = current_state_2
			var new_information_0 = null
			print(" first we check basics")
			var three_ii
			if current_containers_state[data_sets_to_check].has("three_i"):
				three_ii = current_containers_state[data_sets_to_check]["three_i"]
				three_iii.x = 0
			else:
				three_ii = null
				three_iii.x = -2
			var current_status
			if current_containers_state[data_sets_to_check].has("status"):
				print(" allah akbar, three_ii ", three_ii, current_containers_state[data_sets_to_check]["status"])
				current_status = current_containers_state[data_sets_to_check]["status"]
				three_iii.x = 1
			else:
				current_status = null
				three_iii.x = -2
			var current_container_to_check
			if current_containers_state[data_sets_to_check].has("container_name"):
				current_container_to_check = current_containers_state[data_sets_to_check]["container_name"]
				three_iii.x = 2
			else:
				current_container_to_check = null
				three_iii.x = -2
			
			if current_container_to_check != null:
				if current_status != null:
					check_if_first_time(current_container_to_check, current_status)
					three_iii.x = -3
			print(" fatal kurwa error 0 : ", current_container_to_check , ", 1 : " , current_status , ", 2 : " , three_ii)
			if current_container_to_check == null:
				if current_status == null:
					if three_ii == null:
						print(" FATAL KURWA ERROR WE MUST DO SOMETHING")
						three_iii.x -4
			mutex_containers.lock()
			if list_of_containers.has(current_container_to_check):
				print("three_ii tree check 011 normal human first check, if it is, not if it isnt ")
				three_iii.y = 0
				
				if list_of_containers[current_container_to_check].has("status"):
					print(" three_ii tree check 013 status? : ", list_of_containers[current_container_to_check]["status"])
					three_iii.y = 1
				
				if list_of_containers[current_container_to_check].has("three_i"):
					print(" three_ii tree check 014 ")
					list_of_containers[current_container_to_check]["three_i"] = three_iii
					three_iii.y = 2
				else:
					print(" three_ii tree check 015 we dont have it there, yet, lets add something to it")
					list_of_containers[current_container_to_check]["three_i"] = three_iii
			else:
				print("three_ii tree check 0112 three_ii what i maybe trully need more?")
				three_iii.y = -2
			mutex_containers.unlock()
			tree_mutex.lock()
			if scene_tree_jsh.has("main_root"):
				print(" three_ii tree check 00 ")
				three_iii.z = 0
				if scene_tree_jsh["main_root"].has("branches"):
					print(" three_ii tree check 01")
					if scene_tree_jsh["main_root"]["branches"].has(current_container_to_check):
						three_iii.z = 1
						print(" three_ii tree check 02")
					else:
						print(" three_ii tree check 00, we didnt find that container in tree, maybe it will appear, lets add new list of add to queue")
						new_information_0 = container_finder(data_sets_to_check)
						three_iii.z = -2
						print(" new_information_0  : " , new_information_0, " and previous info : " , current_container_to_check)
						if current_container_to_check != new_information_0:
							print(" new_information_0 they are not the same how lol ")
							
							check_if_first_time(new_information_0, current_status)
							three_iii.z = -3
			tree_mutex.unlock()
			mutex_containers.lock()
			for container_to_check in list_of_containers:
				print(" three_ii :" , container_to_check)
				print()
				print(list_of_containers[container_to_check])
				print()
				if new_information_0 != null:
					if list_of_containers[container_to_check].has("connected_containers"):
						
						if !list_of_containers[container_to_check]["connected_containers"].has(new_information_0):
							connect_containers(container_to_check, new_information_0)
					
					else:
						connect_containers(current_container_to_check, new_information_0)
			mutex_containers.unlock()
			print(" three_ii ",scene_tree_jsh)
			print(" what we even wanted with these three ? three_ii : " , three_ii , " , ", current_status , " , " , current_container_to_check)
			if current_containers_state[data_sets_to_check]["status"] == 1:
				print(" taskkkkl should load = 1 ")
				if three_ii.x == -1:
					print(" allah akbar, run again? 0 ")
					mutex_for_trickery.lock()
					menace_tricker_checker = 1
					mutex_for_trickery.unlock()
				else:
					print(" it has container? ")
				if three_ii.y == -1:
					print(" allah akbar, run again? 1 ")
					mutex_for_trickery.lock()
					menace_tricker_checker = 1
					mutex_for_trickery.unlock()
				if three_ii.z == -1:
					print(" allah akbar, run again 2")
					mutex_for_trickery.lock()
					menace_tricker_checker = 1
					mutex_for_trickery.unlock()
				if three_ii.z == 0:
					
					print(" allah akbar, run again 3")
					mutex_for_trickery.lock()
					menace_tricker_checker = 1
					mutex_for_trickery.unlock()
					
				if three_ii.z == 1:
					
					print(" allah akbar, run again 4")
					mutex_for_trickery.lock()
					menace_tricker_checker = 1
					mutex_for_trickery.unlock()
				if three_ii.z == 2:
					continue
			else:
				print(" taskkkkl means unload ?")
				var three_i_update = current_containers_state[data_sets_to_check]["three_i"]
				three_i_update.x = -1
				three_i_update.y = -1
				three_i_update.z = -1
	print(" allah akbar, end : list_of_containers ", list_of_containers)
	mutex_for_container_state.unlock()

func validate_container_state(container_name):
	var required_nodes = ["datapoint", "container"]
	var missing_nodes = []
	tree_mutex.lock()
	if scene_tree_jsh["main_root"]["branches"].has(container_name):
		var container = scene_tree_jsh["main_root"]["branches"][container_name]
		for node_type in required_nodes:
			if !container.has(node_type) or !is_instance_valid(container[node_type]["node"]):
				missing_nodes.append(node_type)
	tree_mutex.unlock()
	if missing_nodes.size() > 0:
		attempt_container_repair(container_name, missing_nodes)

func capture_tree_state() -> Dictionary:
	var root = get_tree().get_root()
	tree_data.structure = capture_node_structure(root)
	tree_data.snapshot = build_pretty_print(root)
	tree_data.timestamp = Time.get_unix_time_from_system()
	return tree_data

func capture_node_structure(node: Node) -> Dictionary:
	var data = {
		"name": node.name,
		"class": node.get_class(),
		"path": str(node.get_path()),
		"children": []
	}
	for child in node.get_children():
		data.children.append(capture_node_structure(child))
		tree_data.node_count += 1
	return data


####################
# Add Branch/ Leaf

#                    ,,        ,,                                                      ,,             AW                                       ,...
#      db          `7MM      `7MM      `7MM"""Yp,                                    `7MM            ,M'     `7MMF'                          .d' ""
#     ;MM:           MM        MM        MM    Yb                                      MM            MV        MM                            dM`   
#    ,V^MM.     ,M""bMM   ,M""bMM        MM    dP `7Mb,od8 ,6"Yb.  `7MMpMMMb.  ,p6"bo  MMpMMMb.     AW         MM         .gP"Ya   ,6"Yb.   mMMmm  
#   ,M  `MM   ,AP    MM ,AP    MM        MM"""bg.   MM' "'8)   MM    MM    MM 6M'  OO  MM    MM    ,M'         MM        ,M'   Yb 8)   MM    MM    
#   AbmmmqMA  8MI    MM 8MI    MM        MM    `Y   MM     ,pm9MM    MM    MM 8M       MM    MM    MV          MM      , 8M""""""  ,pm9MM    MM    
#  A'     VML `Mb    MM `Mb    MM        MM    ,9   MM    8M   MM    MM    MM YM.    , MM    MM   AW           MM     ,M YM.    , 8M   MM    MM    
#.AMA.   .AMMA.`Wbmd"MML.`Wbmd"MML.    .JMMmmmd9  .JMML.  `Moo9^Yo..JMML  JMML.YMbmd'.JMML  JMML.,M'         .JMMmmmmMMM  `Mbmmd' `Moo9^Yo..JMML.  
#                                                                                                MV                                                
#                                                                                               AW                                                 


func start_up_scene_tree():
	tree_mutex.lock()
	scene_tree_jsh = TreeBlueprints.SCENE_TREE_BLUEPRINT.duplicate(true)
	var name_to_add = self.name
	scene_tree_jsh["main_root"]["name"] = name_to_add
	scene_tree_jsh["main_root"]["type"] = self.get_class()
	scene_tree_jsh["main_root"]["metadata"]["creation_time"] = Time.get_ticks_msec()
	scene_tree_jsh["main_root"]["node"] = self
	scene_tree_jsh["main_root"]["status"] = "active"
	tree_mutex.unlock()

func recreator_of_singular_thing(data_set):
	var cached_data_new = data_set.duplicate(true) 
	var thing_name
	var coords_to_place
	var direction_to_place
	var thing_type_file
	var shape_name
	var root_name
	var pathway_dna
	var group_number
	var first_line : Array = []
	var lines_parsed : Array = []
	for lines in cached_data_new:
		if lines == cached_data_new[0]:
			first_line = cached_data_new[0]
		else:
			lines_parsed.append(lines)
	thing_name = first_line[0][0]
	coords_to_place = first_line[1][0]
	direction_to_place = first_line[2][0]
	thing_type_file = first_line[3][0]
	shape_name = first_line[4][0]
	root_name = first_line[5][0]
	pathway_dna = first_line[6][0]
	group_number = first_line[7][0]
	analise_data(thing_name, thing_type_file, first_line, lines_parsed[0], group_number, shape_name, lines_parsed)
	first_line.clear()
	lines_parsed.clear()

func recreate_missing_nodes(array_of_recreation):
	var container_name = array_of_recreation[0]
	var path_of_missing_node = array_of_recreation[1]
	var splitted_path_for_main_thingy = path_of_missing_node.split("/")
	var node_we_look_for_now : String
	var set_name_we_look_for : String
	if splitted_path_for_main_thingy.size() > 1:
		node_we_look_for_now = splitted_path_for_main_thingy[1]
		print(" that thingy is bigger than 1, so it is not container ? " , node_we_look_for_now)
	active_r_s_mut.lock()
	for current_activ_rec in active_record_sets:
		for current_avail_rec in active_record_sets[current_activ_rec][current_activ_rec + "records"]["header"]:
			print("current_avail_rec " , current_avail_rec)
			if node_we_look_for_now == current_avail_rec:
				print(" we found that thing " )
				if scene_tree_jsh["main_root"]["branches"].has(container_name):
					if scene_tree_jsh["main_root"]["branches"][container_name]["children"].has(node_we_look_for_now):
						print_tree_pretty()
						print(" the tree has that branch?")
						print_tree_structure(scene_tree_jsh["main_root"]["branches"][container_name]["children"][node_we_look_for_now], 0)
						disable_all_branches_reset_counters(scene_tree_jsh["main_root"]["branches"][container_name]["children"][node_we_look_for_now], container_name)
						print_tree_structure(scene_tree_jsh["main_root"]["branches"][container_name]["children"][node_we_look_for_now], 0)
						var path_for_node_to_unload = container_name + "/" + node_we_look_for_now
						array_counting_mutex.lock()
						if array_for_counting_finish[container_name].has(node_we_look_for_now):
							array_for_counting_finish[container_name][node_we_look_for_now]["node"] = []
						array_counting_mutex.unlock()
						for singular_thingies in active_record_sets[current_activ_rec][current_activ_rec + "records"]["content"]:
							print(" singular_thingies : " , singular_thingies[0][0][0])
							if singular_thingies[0][0][0] == node_we_look_for_now:
								print(" we found active records part : " , singular_thingies)
								unload_node_branch(path_for_node_to_unload, singular_thingies)
								return
				return
	active_r_s_mut.unlock()

func unload_node_branch(path_for_node_to_unload, recreation_of_node_data):
	var node_to_unload_now = jsh_tree_get_node(path_for_node_to_unload)
	if node_to_unload_now:
		print(" node_to_unload_now : " , node_to_unload_now)
		node_to_unload_now.queue_free()
	print_tree_pretty()
	recreator_of_singular_thing(recreation_of_node_data)

func attempt_container_repair(container_name, missing_nodes):
	active_r_s_mut.lock()
	var records_set_name = container_name.split("_")[0] + "_"
	if active_record_sets.has(records_set_name):
		var records = active_record_sets[records_set_name]
		for node_type in missing_nodes:
			recreate_node_from_records(container_name, node_type, records) 
	active_r_s_mut.unlock()

func recreate_node_from_records(container_name: String, node_type: String, records: Dictionary):
	print("Attempting to recreate %s for container %s" % [node_type, container_name])
	var records_set_name = container_name + "records"
	var node_data = null
	if records.has(records_set_name):
		for record in records[records_set_name]["content"]:
			if record[0][3][0] == node_type:  
				node_data = record[0]
				break
	if node_data:
		match node_type:
			"datapoint":
				var data_point = Node3D.new()
				data_point.set_script(DataPointScript)
				data_point.setup_main_reference(self)
				var version = node_data[4][0]  
				var setup_data = node_data[5]  
				data_point.power_up_data_point(node_data[0][0], int(version), setup_data)
				var node_path = node_data[6][0]
				tasked_children(data_point, node_path)
				tree_mutex.lock()
				scene_tree_jsh["main_root"]["branches"][container_name]["datapoint"] = {
					"datapoint_name": node_data[0][0],
					"datapoint_path": node_path,
					"node": data_point
				}
				tree_mutex.unlock()
			"container":
				var container = Node3D.new()
				container.set_script(ContainterScript)
				container.name = node_data[0][0]
				if container.has_method("container_initialize"):
					container.container_initialize(node_data[5])
				var node_path = node_data[6][0]
				tasked_children(container, node_path)
				tree_mutex.lock()
				scene_tree_jsh["main_root"]["branches"][container_name]["node"] = container
				scene_tree_jsh["main_root"]["branches"][container_name]["status"] = "active"
				tree_mutex.unlock()
			_:
				print("Unknown node type for recreation: ", node_type)
		log_error_state("node_recreation", {
			"container": container_name,
			"node_type": node_type,
			"success": true
		})
	else:
		print("Failed to find data for node recreation")
		log_error_state("node_recreation_failed", {
			"container": container_name,
			"node_type": node_type,
			"reason": "no_data_found"
		})

func tasked_children(node_to_be_added, node_to_be_added_path):
	var splitted_path = node_to_be_added_path.split("/")
	var container_name = splitted_path[0]
	var node_to_be_added_name = splitted_path[-1]
	var parent_path = "/".join(splitted_path.slice(0, -1)) 
	if splitted_path.size() == 1:
		var node_type : int = 0
		mutex_nodes_to_be_added.lock()
		nodes_to_be_added.append([node_type, node_to_be_added_name, node_to_be_added])
		mutex_nodes_to_be_added.unlock()
	elif splitted_path.size() == 2:
		var node_type : int = 1
		mutex_nodes_to_be_added.lock()
		nodes_to_be_added.append([node_type, parent_path, node_to_be_added_name, node_to_be_added])
		mutex_nodes_to_be_added.unlock()
	else:
		var parent_name = splitted_path[1]
		var node_type : int = 2
		mutex_nodes_to_be_added.lock()
		nodes_to_be_added.append([node_type, parent_path, node_to_be_added_name, node_to_be_added, container_name])
		mutex_nodes_to_be_added.unlock()

func process_active_records_for_tree(active_records: Dictionary, set_name_to_process : String, container_name_here : String):
	var records_set_name = set_name_to_process + "records"
	active_r_s_mut.lock()
	for record in active_records[set_name_to_process][records_set_name]["content"]:
		var node_data = record[0]
		var node_name = node_data[0][0]
		var node_path_p_a_r_f_t = node_data[6][0]
		var node_type = node_data[3][0]
		var godot_type = match_node_type(node_type)
		if node_type != "container" and node_type != "datapoint":
			array_counting_mutex.lock()
			if !array_for_counting_finish[container_name_here].has("metadata"):
				var counter_before : int = 0
				var counter_after : int = 0
				var inty_bolean : int = 0
				array_for_counting_finish[container_name_here]["metadata"] = {
					"counter_before" = counter_before,
					"counter_after" = counter_after,
					"process_to_send" = inty_bolean
				}
			array_counting_mutex.unlock()
			array_counting_mutex.lock()
			if !array_for_counting_finish[container_name_here].has(node_name):
				array_for_counting_finish[container_name_here][node_name] = {
					"node" = [],
					"type" = node_type,
					"g_type" = godot_type
				}
			array_counting_mutex.unlock()
		array_counting_mutex.lock()
		if !array_for_counting_finish[container_name_here].has("metadata"):
			var counter_before : int = 0
			var counter_after : int = 0
			var inty_bolean : int = 0
			array_for_counting_finish[container_name_here]["metadata"] = {
				"counter_before" = counter_before,
				"counter_after" = counter_after,
				"process_to_send" = inty_bolean
			}
		array_counting_mutex.unlock()
		if node_type == "datapoint":
			array_counting_mutex.lock()
			array_for_counting_finish[container_name_here]["metadata"]["datapoint_path"] = node_path_p_a_r_f_t
			array_for_counting_finish[container_name_here]["metadata"]["datapoint_name"] = node_name
			array_counting_mutex.unlock()
		if node_type == "container":
			array_counting_mutex.lock()
			array_for_counting_finish[container_name_here]["metadata"]["container_path"] = node_path_p_a_r_f_t
			array_for_counting_finish[container_name_here]["metadata"]["container_name"] = node_name
			array_counting_mutex.unlock()
		var new_type_thingy = godot_type + "|" + node_type
		the_pretender_printer(node_name, node_path_p_a_r_f_t, new_type_thingy, node_type)
		array_counting_mutex.lock()
		array_for_counting_finish[container_name_here]["metadata"]["counter_before"] +=1
		array_counting_mutex.unlock()
		if node_type in ["flat_shape", "model", "cursor", "screen", "circle"]:
			array_counting_mutex.lock()
			array_for_counting_finish[container_name_here]["metadata"]["counter_before"] +=4
			array_counting_mutex.unlock()
			var static_body_name = "collision_" + node_name
			var static_body_path = node_path_p_a_r_f_t + "/" + static_body_name
			the_pretender_printer(static_body_name, static_body_path, "StaticBody3D", "collision")
			var shape_name = "shape_" + node_name
			var shape_path = static_body_path + "/" + shape_name
			the_pretender_printer(shape_name, shape_path, "CollisionShape3D", "collision")
			var area_name = "aura_" + node_name
			var area_path = node_path_p_a_r_f_t + "/" + area_name
			the_pretender_printer(area_name, area_path, "Area3D", "area")
			var area_shape_name = "collision_aura_" + node_name
			var area_shape_path = area_path + "/" + area_shape_name
			the_pretender_printer(area_shape_name, area_shape_path, "CollisionShape3D", "collision")
		elif node_type == "button":
			array_counting_mutex.lock()
			array_for_counting_finish[container_name_here]["metadata"]["counter_before"] +=6
			array_counting_mutex.unlock()
			var text_name = "text_" + node_name
			var text_path = node_path_p_a_r_f_t + "/" + text_name
			the_pretender_printer(text_name, text_path, "Label3D", "text")
			var shape_name = "shape_" + node_name
			var shape_path = node_path_p_a_r_f_t + "/" + shape_name
			the_pretender_printer(shape_name, shape_path, "MeshInstance3D", "button")
			var collision_shape_name = "collision_" + shape_name
			var collision_shape_path = shape_path + "/" + collision_shape_name
			the_pretender_printer(collision_shape_name, collision_shape_path, "StaticBody3D", "collision")
			var shape_collision_name = "shape_" + shape_name
			var shape_collision_path = collision_shape_path + "/" + shape_collision_name
			the_pretender_printer(shape_collision_name, shape_collision_path, "CollisionShape3D", "collision")
			var area_name = "aura_" + shape_name
			var area_path = shape_path + "/" + area_name
			the_pretender_printer(area_name, area_path, "Area3D", "area")
			var area_collision_name = "collision_aura_" + shape_name
			var area_collision_path = area_path + "/" + area_collision_name
			the_pretender_printer(area_collision_name, area_collision_path, "CollisionShape3D", "collision")
	active_r_s_mut.unlock()

func match_node_type(type: String) -> String:
	match type:
		"flat_shape", "model", "cursor", "screen", "circle":
			return "MeshInstance3D"
		"text":
			return "Label3D"
		"button":
			return "Node3D" 
		"connection":
			return "MeshInstance3D"
		"text_mesh":
			return "MeshInstance3D"
		"datapoint":
			return "Node3D"
		"container":
			return "Node3D"
		_:
			return "Node3D"

func the_pretender_printer(node_name: String, node_path_jsh_tree: String, godot_node_type, node_type: String = "Node3D"):
	tree_mutex.lock()
	if !scene_tree_jsh.has("main_root"):
		scene_tree_jsh = TreeBlueprints.SCENE_TREE_BLUEPRINT.duplicate(true)
		scene_tree_jsh["main_root"]["name"] = "main"
		scene_tree_jsh["main_root"]["type"] = "Node3D"
		scene_tree_jsh["main_root"]["status"] = "active"
		scene_tree_jsh["main_root"]["node"] = self
	var path_parts = node_path_jsh_tree.split("/")
	var current_branch = scene_tree_jsh["main_root"]["branches"]
	cached_tree_mutex.lock()
	var cached_current_branch = cached_jsh_tree_branches
	cached_tree_mutex.unlock()
	var current_full_path = ""
	for i in range(path_parts.size()):
		var part = path_parts[i]
		current_full_path = current_full_path + "/" + part if current_full_path else part
		if !current_branch.has(part):
			if cached_current_branch.has(part):
				print(" the cached branch has that one ")
				current_branch[part] = cached_current_branch[part]
				cached_current_branch.erase(part)
			else:
				var new_branch = TreeBlueprints.BRANCH_BLUEPRINT.duplicate(true)
				new_branch["name"] = part
				new_branch["type"] = godot_node_type
				new_branch["jsh_type"] = node_type
				new_branch["status"] = "pending"
				new_branch["node"] = null
				new_branch["metadata"] = {
					"creation_time": Time.get_ticks_msec(),
					"full_path": current_full_path,
					"parent_path": current_full_path.get_base_dir(),
					"has_collision": false,
					"has_area": false
				}
				if node_type == "datapoint":
					scene_tree_jsh["main_root"]["branches"][path_parts[0]]["datapoint"] = {
						"datapoint_name" = new_branch["name"],
						"datapoint_path" = new_branch["metadata"]["full_path"]
					}
				current_branch[part] = new_branch
		if i < path_parts.size() - 1:
			if !current_branch[part].has("children"):
				current_branch[part]["children"] = {}
			current_branch = current_branch[part]["children"]
			if cached_current_branch.has(part):
				if cached_current_branch[part].has("children"):
					print(" the cached branch had them children")
					cached_current_branch = cached_current_branch[part]["children"]
	tree_mutex.unlock()

# Remove Branch/ Leaf

#                                                                                                                   ,,             AW                                       ,...
#`7MM"""Mq.                                                         `7MM"""Yp,                                    `7MM            ,M'     `7MMF'                          .d' ""
#  MM   `MM.                                                          MM    Yb                                      MM            MV        MM                            dM`   
#  MM   ,M9  .gP"Ya `7MMpMMMb.pMMMb.  ,pW"Wq.`7M'   `MF'.gP"Ya        MM    dP `7Mb,od8 ,6"Yb.  `7MMpMMMb.  ,p6"bo  MMpMMMb.     AW         MM         .gP"Ya   ,6"Yb.   mMMmm  
#  MMmmdM9  ,M'   Yb  MM    MM    MM 6W'   `Wb VA   ,V ,M'   Yb       MM"""bg.   MM' "'8)   MM    MM    MM 6M'  OO  MM    MM    ,M'         MM        ,M'   Yb 8)   MM    MM    
#  MM  YM.  8M""""""  MM    MM    MM 8M     M8  VA ,V  8M""""""       MM    `Y   MM     ,pm9MM    MM    MM 8M       MM    MM    MV          MM      , 8M""""""  ,pm9MM    MM    
#  MM   `Mb.YM.    ,  MM    MM    MM YA.   ,A9   VVV   YM.    ,       MM    ,9   MM    8M   MM    MM    MM YM.    , MM    MM   AW           MM     ,M YM.    , 8M   MM    MM    
#.JMML. .JMM.`Mbmmd'.JMML  JMML  JMML.`Ybmd9'     W     `Mbmmd'     .JMMmmmd9  .JMML.  `Moo9^Yo..JMML  JMML.YMbmd'.JMML  JMML.,M'         .JMMmmmmMMM  `Mbmmd' `Moo9^Yo..JMML.  
#                                                                                                                             MV                                                
#                                                                                                                            AW                                                 

# Remove Branch/ Leaf

func unload_container(container_to_unload):
	var data_sets_names = null
	if BanksCombiner.container_set_name.has(container_to_unload):
		data_sets_names = BanksCombiner.container_set_name[container_to_unload]
	cache_tree_branch_fully(container_to_unload)
	process_to_unload_records(container_to_unload)
	array_counting_mutex.lock()
	if array_for_counting_finish.has(container_to_unload):
		array_for_counting_finish.erase(container_to_unload)
	else:
		print(" cache branch that container does not exist")
	array_counting_mutex.unlock()
	if data_sets_names != null:
		if data_sets_names is String:
			print(" just singular action , ", data_sets_names )
		elif data_sets_names is Array:
			print("unloading philantrophy more than one set in that container ", data_sets_names)

func unload_nodes(array_of_thingiess_that_shall_remain):
	var counter_1 : int = 0
	var counter_2 : int = 0
	var data_point_node = array_of_thingiess_that_shall_remain[1][0]
	var data_point
	var children_finder = array_of_thingiess_that_shall_remain[0][0].get_children()
	for children in children_finder:
		var thing_to_something : int = 0
		thing_to_something = 0
		for nodes_to_remain in array_of_thingiess_that_shall_remain:
			if str(children.name) == str(nodes_to_remain[0]):
				thing_to_something = 1
				break
		match thing_to_something:
			0:
				counter_1 +=1
				print("this thing shall be unloaded :)")
				print(" children  ", children)
				find_branch_to_unload(children.get_path())
				children.queue_free()
			1:
				counter_2 +=1
				if data_point_node == str(children.name):
					data_point = children
	if counter_1 <=1:
		pass

func cache_tree_branch_fully(container_to_unload):
	cached_tree_mutex.lock()
	print(" new function to cache tree branch fully ", container_to_unload)
	if !cached_jsh_tree_branches.has(container_to_unload):
		print(" new function, it doesnt have that branch ", container_to_unload)
		tree_mutex.lock()
		if scene_tree_jsh["main_root"]["branches"].has(container_to_unload):
			print(" the main scene tree thingy got that container in it rn ")
			tree_mutex.unlock()
			disable_all_branches(scene_tree_jsh["main_root"]["branches"][container_to_unload])
			tree_mutex.lock()
			cached_jsh_tree_branches[container_to_unload] = scene_tree_jsh["main_root"]["branches"][container_to_unload]
			scene_tree_jsh["main_root"]["branches"].erase(container_to_unload)
			tree_mutex.unlock()
		else:
			tree_mutex.unlock()
	cached_tree_mutex.unlock()

func cache_branch(branch_name, child_name, branch_part):
	print(" cache branch : ", branch_name, child_name)
	cached_tree_mutex.lock()
	if !cached_jsh_tree_branches.has(branch_name):
		tree_mutex.lock()
		cached_jsh_tree_branches[branch_name] = {
			"name" = scene_tree_jsh["main_root"]["branches"][branch_name]["name"],
			"type" = scene_tree_jsh["main_root"]["branches"][branch_name]["type"],
			"jsh_type" = scene_tree_jsh["main_root"]["branches"][branch_name]["jsh_type"],
			"parent" = scene_tree_jsh["main_root"]["branches"][branch_name]["parent"],
			"status" = "disabled",
			"node" = null,
			"metadata" = scene_tree_jsh["main_root"]["branches"][branch_name]["metadata"],
			"children" = {}
		}
		tree_mutex.unlock()
	if cached_jsh_tree_branches.has(branch_name):
		if !cached_jsh_tree_branches[branch_name]["children"].has(child_name):
			disable_all_branches(branch_part)
			tree_mutex.lock()
			cached_jsh_tree_branches[branch_name]["children"][child_name] = branch_part
			tree_mutex.unlock()
	cached_tree_mutex.unlock()

#                ,,        ,,                                                              ,,             AW                                       ,...
#`7MMF'  `7MMF'  db      `7MM              `7MM"""Yp,                                    `7MM            ,M'     `7MMF'                          .d' ""
#  MM      MM              MM                MM    Yb                                      MM            MV        MM                            dM`   
#  MM      MM  `7MM   ,M""bMM  .gP"Ya        MM    dP `7Mb,od8 ,6"Yb.  `7MMpMMMb.  ,p6"bo  MMpMMMb.     AW         MM         .gP"Ya   ,6"Yb.   mMMmm  
#  MMmmmmmmMM    MM ,AP    MM ,M'   Yb       MM"""bg.   MM' "'8)   MM    MM    MM 6M'  OO  MM    MM    ,M'         MM        ,M'   Yb 8)   MM    MM    
#  MM      MM    MM 8MI    MM 8M""""""       MM    `Y   MM     ,pm9MM    MM    MM 8M       MM    MM    MV          MM      , 8M""""""  ,pm9MM    MM    
#  MM      MM    MM `Mb    MM YM.    ,       MM    ,9   MM    8M   MM    MM    MM YM.    , MM    MM   AW           MM     ,M YM.    , 8M   MM    MM    
#.JMML.  .JMML..JMML.`Wbmd"MML.`Mbmmd'     .JMMmmmd9  .JMML.  `Moo9^Yo..JMML  JMML.YMbmd'.JMML  JMML.,M'         .JMMmmmmMMM  `Mbmmd' `Moo9^Yo..JMML.  
#                                                                                                    MV                                                
#                                                                                                   AW                                                 

# Hide Branch/ Leaf

#                                                                                              ,,             AW                                       ,...
#`7MMM.     ,MMF'                              `7MM"""Yp,                                    `7MM            ,M'     `7MMF'                          .d' ""
#  MMMb    dPMM                                  MM    Yb                                      MM            MV        MM                            dM`   
#  M YM   ,M MM  ,pW"Wq.`7M'   `MF'.gP"Ya        MM    dP `7Mb,od8 ,6"Yb.  `7MMpMMMb.  ,p6"bo  MMpMMMb.     AW         MM         .gP"Ya   ,6"Yb.   mMMmm  
#  M  Mb  M' MM 6W'   `Wb VA   ,V ,M'   Yb       MM"""bg.   MM' "'8)   MM    MM    MM 6M'  OO  MM    MM    ,M'         MM        ,M'   Yb 8)   MM    MM    
#  M  YM.P'  MM 8M     M8  VA ,V  8M""""""       MM    `Y   MM     ,pm9MM    MM    MM 8M       MM    MM    MV          MM      , 8M""""""  ,pm9MM    MM    
#  M  `YM'   MM YA.   ,A9   VVV   YM.    ,       MM    ,9   MM    8M   MM    MM    MM YM.    , MM    MM   AW           MM     ,M YM.    , 8M   MM    MM    
#.JML. `'  .JMML.`Ybmd9'     W     `Mbmmd'     .JMMmmmd9  .JMML.  `Moo9^Yo..JMML  JMML.YMbmd'.JMML  JMML.,M'         .JMMmmmmMMM  `Mbmmd' `Moo9^Yo..JMML.  
#                                                                                                        MV                                                
#                                                                                                       AW                                                 

# Move Branch/ Leaf

#               ,,                                                                                                  ,,             AW                                       ,...
#   .g8"""bgd `7MM                                                  `7MM"""Yp,                                    `7MM            ,M'     `7MMF'                          .d' ""
# .dP'     `M   MM                                                    MM    Yb                                      MM            MV        MM                            dM`   
# dM'       `   MMpMMMb.   ,6"Yb.  `7MMpMMMb.  .P"Ybmmm .gP"Ya        MM    dP `7Mb,od8 ,6"Yb.  `7MMpMMMb.  ,p6"bo  MMpMMMb.     AW         MM         .gP"Ya   ,6"Yb.   mMMmm  
# MM            MM    MM  8)   MM    MM    MM :MI  I8  ,M'   Yb       MM"""bg.   MM' "'8)   MM    MM    MM 6M'  OO  MM    MM    ,M'         MM        ,M'   Yb 8)   MM    MM    
# MM.           MM    MM   ,pm9MM    MM    MM  WmmmP"  8M""""""       MM    `Y   MM     ,pm9MM    MM    MM 8M       MM    MM    MV          MM      , 8M""""""  ,pm9MM    MM    
# `Mb.     ,'   MM    MM  8M   MM    MM    MM 8M       YM.    ,       MM    ,9   MM    8M   MM    MM    MM YM.    , MM    MM   AW           MM     ,M YM.    , 8M   MM    MM    
#   `"bmmmd'  .JMML  JMML.`Moo9^Yo..JMML  JMML.YMMMMMb  `Mbmmd'     .JMMmmmd9  .JMML.  `Moo9^Yo..JMML  JMML.YMbmd'.JMML  JMML.,M'         .JMMmmmmMMM  `Mbmmd' `Moo9^Yo..JMML.  
#                                             6'     dP                                                                       MV                                                
#                                             Ybmmmd'                                                                        AW                                                 

# Change Branch/ Leaf

func the_finisher_for_nodes(data_to_be_parsed):
	var path_of_node_jsh = data_to_be_parsed[0][0]
	var node_name_jsh_checker = data_to_be_parsed[0][1]
	var node_to_be_checker = data_to_be_parsed[0][2]
	jsh_tree_get_node_status_changer(path_of_node_jsh, node_name_jsh_checker, node_to_be_checker)

func disable_all_branches_reset_counters(branch_to_disable, container_name_for_array):
	var all_containers : Array = []
	var all_nodes : Array = []
	var branches_to_process : Array = []
	var just_container : Array = []
	var process_branch = func traverse_branch(branch: Dictionary):
		if branch["metadata"].has("full_path") and branch["metadata"]["full_path"] != null:
			all_containers.append(branch["name"])
			if branch["status"] == "active":
				array_counting_mutex.lock()
				array_for_counting_finish[container_name_for_array]["metadata"]["counter_after"] -=1
				array_counting_mutex.unlock()
			branch["status"] = "disabled"
		if branch.has("children"):
			for child_name in branch["children"]:
				branches_to_process.append(branch["children"][child_name])
				if branch["children"][child_name]["status"] == "active":
					array_counting_mutex.lock()
					array_for_counting_finish[container_name_for_array]["metadata"]["counter_after"] -=1
					array_counting_mutex.unlock()
				branch["children"][child_name]["status"] = "disabled"
	var process_children = func traverse_branch(branch: Dictionary):
		if branch.has("metadata"):
			all_nodes.append(branch["metadata"]["full_path"])
		if branch.has("children"):
			for child_name in branch["children"]:
				branches_to_process.append(branch["children"][child_name])
				if branch["children"][child_name]["status"] == "active":
					array_counting_mutex.lock()
					array_for_counting_finish[container_name_for_array]["metadata"]["counter_after"] -=1
					array_counting_mutex.unlock()
				branch["children"][child_name]["status"] = "disabled"
	process_branch.call(branch_to_disable)
	var current_branches = branches_to_process.duplicate(false)
	while branches_to_process.size() > 0:
		var current_branch = branches_to_process[0]  
		process_branch.call(current_branch)
		branches_to_process.remove_at(0)

func jsh_tree_get_node_status_changer(node_path_jsh_tree_status: String, node_name: String, node_to_check: Node):
	var path_parts_jsh_status_node = node_path_jsh_tree_status.split("/")
	tree_mutex.lock()
	var current = scene_tree_jsh["main_root"]["branches"]
	tree_mutex.unlock()
	var name_of_container = path_parts_jsh_status_node[0]
	var name_of_current_thing = path_parts_jsh_status_node[path_parts_jsh_status_node.size() - 1]
	tree_mutex.lock()
	array_counting_mutex.lock()
	for part in path_parts_jsh_status_node:
		if current.has(part):
			current = current[part]
			if path_parts_jsh_status_node[-1] == part:
				if node_to_check:
					current["status"] = "active"
					current["node"] = node_to_check
					if array_for_counting_finish.has(name_of_container):
						if array_for_counting_finish[name_of_container].has(name_of_current_thing):
							array_for_counting_finish[name_of_container][name_of_current_thing]["node"] = node_to_check
						array_for_counting_finish[path_parts_jsh_status_node[0]]["metadata"]["counter_after"] +=1
						if array_for_counting_finish[name_of_container]["metadata"]["datapoint_name"] == name_of_current_thing:
							array_for_counting_finish[name_of_container]["metadata"]["datapoint_node"] = node_to_check
						if array_for_counting_finish[name_of_container]["metadata"]["container_path"] == name_of_current_thing:
							array_for_counting_finish[name_of_container]["metadata"]["container_node"] = node_to_check
						if array_for_counting_finish[name_of_container]["metadata"]["counter_before"] == array_for_counting_finish[name_of_container]["metadata"]["counter_after"]:
							create_new_task("newer_even_function_for_dictionary", name_of_container)
					else:
						print(" dilemafiasco i guess it could like, not find somehow that container? how ?")
				else: 
					print(" dilemafiasco new way to check node from proces we are but we didnt get node? on if:")
			else: 
				current = current["children"]
		else:
			print(" dilemafiasco the new one? ")
	tree_mutex.unlock()
	array_counting_mutex.unlock()

func connect_containers(container_name_0, container_name_1):
	print(" two containers to connect " , container_name_0 , " and : " , container_name_0)
	var container_data_0
	var container_data_1
	mutex_containers.lock()
	if list_of_containers.has(container_name_0):
		if list_of_containers[container_name_0].has("connected_containers"):
			container_data_0 = list_of_containers[container_name_0]
		else:
			list_of_containers[container_name_0]["connected_containers"] = {}
			list_of_containers[container_name_0]["connected_containers"][container_name_1] = {}
	if list_of_containers.has(container_name_1):
		if list_of_containers[container_name_1].has("connected_containers"):
			container_data_1 = list_of_containers[container_name_1]
		else:
			list_of_containers[container_name_1]["connected_containers"] = {}
			list_of_containers[container_name_1]["connected_containers"][container_name_0] = {}
	mutex_containers.unlock()

func disable_all_branches(branch_to_disable):
	var all_containers : Array = []
	var all_nodes : Array = []
	var branches_to_process : Array = []
	var just_container : Array = []
	var process_branch = func traverse_branch(branch: Dictionary):
		tree_mutex.lock()
		if branch["metadata"].has("full_path") and branch["metadata"]["full_path"] != null:
			all_containers.append(branch["name"])
			branch["status"] = "disabled"
			branch["node"] = null
		if branch.has("children"):
			for child_name in branch["children"]:
				branches_to_process.append(branch["children"][child_name])
				branch["children"][child_name]["status"] = "disabled"
				branch["children"][child_name]["node"] = null 
		tree_mutex.unlock()
	process_branch.call(branch_to_disable)
	var current_branches = branches_to_process.duplicate(false)
	while branches_to_process.size() > 0:
		tree_mutex.lock()
		var current_branch = branches_to_process[0] 
		tree_mutex.unlock()
		process_branch.call(current_branch)        
		tree_mutex.lock()
		branches_to_process.remove_at(0)            
		tree_mutex.unlock()

#

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┓┏• ┓ ┓      ┓┏  •┓  ┏┓         
#       888  `"Y8888o.   888ooooo888     ┣┫┓┏┫┏┫┏┓┏┓  ┃┃┏┓┓┃  ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┛┗┗┗┻┗┻┗ ┛┗  ┗┛┗ ┗┗  ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888                             ┛       
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            

#
# JSH Hidden Veil

func check_quick_functions():
	if mouse_status.x == 0:
		data_storage_comparer.clear()
	elif mouse_status.x == 1:
		if !data_storage_comparer.is_empty():
			var combo_array_size = combo_array.size()
			var just_name_from_combo = combo_array[combo_array_size - 1][0].name
			var just_name_from_func = data_storage_comparer[0][0]
			if just_name_from_combo == just_name_from_func:
				var size_of_stuff = data_storage_comparer[0][3].size()
				if size_of_stuff == 3:
					sixth_dimensional_magic(data_storage_comparer[0][3][0], data_storage_comparer[0][3][1], data_storage_comparer[0][3][2])
				elif size_of_stuff == 4:
					sixth_dimensional_magic(data_storage_comparer[0][3][0], data_storage_comparer[0][3][1], data_storage_comparer[0][3][2], data_storage_comparer[0][3][3])

func check_short_functions():
	if mouse_status.x == 0:
		data_storage_zero_five.clear()
		data_storage_comparer.clear()
		int_of_truth_zero_five = 0
	elif mouse_status.x == 1:
		if int_of_truth_zero_five <= 2:
			if !data_storage_zero_five.is_empty():
				var combo_array_size = combo_array.size()
				var just_name_from_combo = combo_array[combo_array_size - 1][0].name
				var just_name_from_func = data_storage_zero_five[0][0]
				if just_name_from_combo == just_name_from_func:
					if int_of_truth_zero_five == 0:
						print(" newly found combo stuff under 2 ", data_storage_zero_five[0][3])
						int_of_truth_zero_five +=1
					elif int_of_truth_zero_five == 1:
						print(" newly found combo stuff over 2 ", data_storage_zero_five[0][3])
						data_storage_comparer = data_storage_zero_five
						int_of_truth_zero_five +=1

func preparer_for_combos(data_to_understand):
	data_storage_comparer = []
	data_storage_zero_five = []
	var array_to_send_its_way : Array = []
	var data_splitin = data_to_understand[2].split("|")
	data_to_understand[2] = data_splitin[0]
	var just_thing = data_splitin[1]
	var possible_node_data = combo_array[0][0]
	var node_name_now = null
	var just_thing_name = null
	var combo_array_size = combo_array.size()
	if possible_node_data is Node:
		node_name_now = possible_node_data.name
		var first_split_name = node_name_now.split("_")
		var splitted_name_size = first_split_name.size() - 1
		just_thing_name = first_split_name[splitted_name_size - 1] + "_" + first_split_name[splitted_name_size]
		if just_thing == just_thing_name:
			print(" newly found combo stuff : " , combo_array_size)
			data_storage_zero_five.clear()
			data_storage_comparer.clear()
			int_of_truth_zero_five = 0
			array_to_send_its_way.append(node_name_now)
			array_to_send_its_way.append(just_thing)
			array_to_send_its_way.append(combo_array_size)
			array_to_send_its_way.append(data_to_understand)
			data_storage_zero_five.append(array_to_send_its_way)
	
func call_some_thingy():
	print()
	var data_pooint_node_now = get_node("keyboard_right_container/thing_53")
	data_pooint_node_now.process_delta_fake()

func process_turn_0(delta: float) -> Dictionary:
	var result = {
		"status": CreationStatus.ERROR,
		"message": "",
		"delta_time": delta,
		"processed_sets": 0
	}
	if delta <= 0:
		result.message = "Invalid delta time"
		return result
	if turn_number_process != 0:
		result.message = "Wrong turn number"
		return result
	turn_number_process += 1
	array_mutex_process.lock()
	if list_of_sets_to_create.size() > 0:
		var process_result = process_stages()
		if process_result:
			result.status = CreationStatus.SUCCESS
			result.processed_sets = list_of_sets_to_create.size()
		else:
			result.message = "Process stages failed"
	else:
		result.message = "No sets to create"
		result.status = CreationStatus.PENDING
	array_mutex_process.unlock()
	result.delta_time = delta
	return result

func process_system_0():
	var try_turn_0 = array_mutex_process.try_lock()
	if try_turn_0:
		array_mutex_process.unlock()
	else:
		array_mutex_process.unlock()
		return
	array_mutex_process.lock()
	if list_of_sets_to_create.size() > 0:
		array_mutex_process.unlock()
		process_stages()
	else:
		array_mutex_process.unlock()
	ready_for_once()
	var try_turn_00 = mutex_actions.try_lock()
	if try_turn_00:
		mutex_actions.unlock()
	else:
		mutex_actions.unlock()
		return
	mutex_actions.lock()
	if actions_to_be_called.size() > 0:
		for i in range(min(max_actions_per_cycle, actions_to_be_called.size())):
			print(" we got magic to do ", actions_to_be_called)
			var data_to_process = actions_to_be_called.pop_front()
			var type_of_action = data_to_process[0]
			var datapoint_node = data_to_process[1]
			var additional_node = data_to_process[2]
			match type_of_action:
				"update_text_cursor_after":
					if datapoint_node is Node:
						datapoint_node.update_text_cursor_after(additional_node)
					else:
						print(" conductor, we got a problem ")
						actions_to_be_called.append(data_to_process)
	mutex_actions.unlock()

func process_system_1():
	var try_turn_1 = mutex_nodes_to_be_added.try_lock()
	if try_turn_1:
		mutex_nodes_to_be_added.unlock()
	else:
		mutex_nodes_to_be_added.unlock()
		return
	mutex_nodes_to_be_added.lock()
	if nodes_to_be_added.size() > 0:
		for i in range(min(max_nodes_added_per_cycle, nodes_to_be_added.size())):
			var data_to_process = nodes_to_be_added.pop_front()
			var data_type = data_to_process[0]
			match data_type:
				0:
					var container_to_add = data_to_process[2]
					var container_name = data_to_process[1]
					add_child(container_to_add)
					var just_added_node = get_node_or_null(container_name)
					if just_added_node:
						var data_to_be_checked : Array = []
						data_to_be_checked.append([container_name, container_name, just_added_node])
						create_new_task("the_finisher_for_nodes", data_to_be_checked)
					else:
						nodes_to_be_added.append(data_to_process)
						print(" ERROR container was not found ")
				1:
					var parent_path = data_to_process[1]
					var node_name = data_to_process[2]
					var main_node_to_add = data_to_process[3]
					var combined_path = parent_path + "/" + node_name
					var container = get_node_or_null(parent_path)
					if container:
						FloodgateController.universal_add_child(main_node_to_add, container)
						var just_added_node = get_node(combined_path)
						if just_added_node:
							
							if texture_storage.has(combined_path):
								print(" texture dilema ")
							
							
							var data_to_be_checked : Array = []
							data_to_be_checked.append([combined_path, node_name, just_added_node])
							create_new_task("the_finisher_for_nodes", data_to_be_checked)
						else:
							print("ERROR main node not found")
							nodes_to_be_added.append(data_to_process)
						
					else:
						print("ERROR container for main node not found")
						nodes_to_be_added.append(data_to_process)
				2:
					var parent_path = data_to_process[1]
					var node_name = data_to_process[2]
					var main_node_to_add = data_to_process[3]
					var container_name = data_to_process[4]
					var combined_path = parent_path + "/" + node_name
					var container = get_node_or_null(parent_path)
					if container:
						FloodgateController.universal_add_child(main_node_to_add, container)
						var just_added_node = get_node_or_null(combined_path)
						if just_added_node:
							var data_to_be_checked : Array = []
							data_to_be_checked.append([combined_path, node_name, just_added_node])
							create_new_task("the_finisher_for_nodes", data_to_be_checked)
						else:
							print(" ERROR sub node not found ")
							nodes_to_be_added.append(data_to_process)
					else:
						print(" ERROR main node for sub node not found ")
						nodes_to_be_added.append(data_to_process)
	mutex_nodes_to_be_added.unlock()

func process_system_2():
	var try_turn_2 = mutex_data_to_send.try_lock()
	if try_turn_2:
		mutex_data_to_send.unlock()
	else:
		mutex_data_to_send.unlock()
		return
	mutex_data_to_send.lock()
	if data_to_be_send.size() > 0:
		for i in range(min(max_data_send_per_cycle, data_to_be_send.size())):
			var data_to_be_send_rn = data_to_be_send.pop_front()
			var current_type_of_data = data_to_be_send_rn[0]
			var datapoint_path_cur = data_to_be_send_rn[1]
			match current_type_of_data:
				"instructions_analiser":
					var container_path_rn = data_to_be_send_rn[2]
					var container_node_rn = get_node_or_null(container_path_rn)
					if container_node_rn:
						var datapoint_node_rn = get_node_or_null(datapoint_path_cur)
						if datapoint_node_rn:
							var array_of_data_for_threes : Array = []
							array_of_data_for_threes.append([current_type_of_data, data_to_be_send_rn[3].duplicate(true), data_to_be_send_rn[4].duplicate(true), datapoint_node_rn, container_node_rn])
							create_new_task("task_to_send_data_to_datapoint", array_of_data_for_threes)
						else:
							print(" we didnt find the datapoint we must append stuff ")
							data_to_be_send.append(data_to_be_send_rn)
					else:
						print(" we didnt get container, we must append ")
						data_to_be_send.append(data_to_be_send_rn)
				"scene_frame_upload":
					var container_path_rn = data_to_be_send_rn[2]
					var container_node_rn = get_node_or_null(container_path_rn)
					if container_node_rn:
						var datapoint_node_rn = get_node_or_null(datapoint_path_cur)
						if datapoint_node_rn:
							var array_of_data_for_threes : Array = []
							array_of_data_for_threes.append([current_type_of_data, data_to_be_send_rn[3].duplicate(true), data_to_be_send_rn[4].duplicate(true), datapoint_node_rn, container_node_rn])
							create_new_task("task_to_send_data_to_datapoint", array_of_data_for_threes)
						else:
							print(" we didnt find the datapoint we must append stuff ")
							data_to_be_send.append(data_to_be_send_rn)
					else:
						print(" we didnt get container, we must append ")
						data_to_be_send.append(data_to_be_send_rn)
				"interactions_upload":
					var datapoint_node_rn = get_node_or_null(datapoint_path_cur)
					if datapoint_node_rn:
						var array_of_data_for_threes : Array = []
						array_of_data_for_threes.append([current_type_of_data, data_to_be_send_rn[3].duplicate(true), data_to_be_send_rn[4].duplicate(true), datapoint_node_rn])
						create_new_task("task_to_send_data_to_datapoint", array_of_data_for_threes)
					else:
						print(" we didnt got that datapoint, we gotta apend")
						data_to_be_send.append(data_to_be_send_rn)
	mutex_data_to_send.unlock()

func process_system_3():
	var try_turn_3 = movmentes_mutex.try_lock()
	if try_turn_3:
		movmentes_mutex.unlock()
	else:
		movmentes_mutex.unlock()
		return
	movmentes_mutex.lock()
	if things_to_be_moved.size() > 0:
		for i in range(min(max_movements_per_cycle, things_to_be_moved.size())):
			var data_to_process = things_to_be_moved.pop_front()
			var data_type = data_to_process[0]
			var node_to_operate = data_to_process[1]
			var data_for_operation = data_to_process[2]
			match data_type:
				"move":
					node_to_operate.position = data_for_operation
				"rotate":
					node_to_operate.rotation.x -= deg_to_rad(data_for_operation)
				"write":
					for child in node_to_operate.get_children():
						if child is Label3D:
							child.text = data_for_operation
	movmentes_mutex.unlock()

func process_system_4():
	var try_turn_4 = mutex_for_unloading_nodes.try_lock()
	if try_turn_4:
		mutex_for_unloading_nodes.unlock()
	else:
		mutex_for_unloading_nodes.unlock()
		return
	mutex_for_unloading_nodes.lock()
	if nodes_to_be_unloaded.size() > 0:
		for i in range(min(max_nodes_to_unload_per_cycle, nodes_to_be_unloaded.size())):
			var data_to_process = nodes_to_be_unloaded.pop_front()
			var data_type = data_to_process[0]
			var path_of_the_node = data_to_process[1]
			match data_type:
				"container":
					print(" we would unload container")
					var container_to_unload = get_node_or_null(path_of_the_node)
					if container_to_unload:
						var possibility_to_unload_now = check_if_we_are_adding_container(path_of_the_node)
						var possiblity_to_unload_container = check_magical_array(path_of_the_node)
						print(" unloading stuff we must learn abortion hehe ", possibility_to_unload_now , " and " , possiblity_to_unload_container)
						if possibility_to_unload_now == false or possiblity_to_unload_container == false:
							nodes_to_be_unloaded.append(data_to_process)
							mutex_for_unloading_nodes.unlock()
							return
						var sub_path_of_the_node = path_of_the_node.substr(0, path_of_the_node.length() -10)
						print("taskkkk sub_path_of_the_node ", sub_path_of_the_node)
						container_to_unload.queue_free()
						create_new_task("unload_container", path_of_the_node)
						create_new_task("handle_unload_task", path_of_the_node)
					else:
						print(" abortion we didnt find that container")
				"just_node":
					var node_to_unload = get_node_or_null(path_of_the_node)
					if node_to_unload:
						node_to_unload.queue_free()
						create_new_task("find_branch_to_unload", path_of_the_node)
					else:
						print(" i guess we didnt get node unfortunatelly ?")
	mutex_for_unloading_nodes.unlock()

func process_system_5():
	var try_turn_5 = mutex_function_call.try_lock()
	if try_turn_5:
		mutex_function_call.unlock()
	else:
		mutex_function_call.unlock()
		return
	mutex_function_call.lock()
	if functions_to_be_called.size() > 0:
		for i in range(min(max_functions_called_per_cycle, functions_to_be_called.size())):
			var data_to_process = functions_to_be_called.pop_front()
			var type_of_functi = data_to_process[0]
			var node_to_call = data_to_process[1]
			var function_name = data_to_process[2]
			var function_name_split = function_name.split("|")
			function_name = function_name_split[0]
			match type_of_functi:
				"single_function":
					if node_to_call and node_to_call.has_method(function_name):
						node_to_call.call(function_name)
				"call_function_get_node":
					var function_data = data_to_process[3]
					var node_to_call_now = get_node_or_null(node_to_call)
					if node_to_call_now and node_to_call_now.has_method(function_name):
						node_to_call_now.call(function_name, function_data)
						if function_name == "handle_key_press":
							if function_name_split.size() > 1:
								print(" newest toy : " , mouse_status , function_name_split[1])
								preparer_for_combos(data_to_process)
				"call_function_single_get_node":
					var node_to_call_now = get_node_or_null(node_to_call)
					if node_to_call_now and node_to_call_now.has_method(function_name):
						node_to_call_now.call(function_name)
						
						if function_name == "handle_backspace":
							if function_name_split.size() > 1:
								print(" newest toy : " , mouse_status, function_name_split[1])
								preparer_for_combos(data_to_process)
				"get_nodes_call_function":
					if data_to_process.size() > 3:
						var function_data = data_to_process[3]
						for nodes in node_to_call:
							var current_node_to_call = get_node_or_null(nodes)
							if current_node_to_call and current_node_to_call.has_method(function_name):
								current_node_to_call.call(function_name, function_data)
					else:
						print(" parallel reality somehow it is small size?")
	mutex_function_call.unlock()

func process_system_6():
	var try_turn_6 = mutex_additionals_call.try_lock()
	if try_turn_6:
		mutex_additionals_call.unlock()
	else:
		mutex_additionals_call.unlock()
		return
	mutex_additionals_call.lock()
	if additionals_to_be_called.size() > 0:
		for i in range(min(max_additionals_per_cycle, additionals_to_be_called.size())):
			print(" we got magic to do ", additionals_to_be_called)
			var data_to_process = additionals_to_be_called.pop_front()
			var type_of_data = data_to_process[0]
			var what_data = data_to_process[1]
			var amount_of_times = data_to_process[2]
			if amount_of_times != 0:
				match type_of_data:
					"add_container":
						print(" we got magic to do we got containers to add")
						if BanksCombiner.container_set_name.has(what_data):
							print(" we got magic to do set name found ")
							var set_name = BanksCombiner.container_set_name[what_data]
							var is_it_loading = check_if_already_loading_one(set_name)
							if is_it_loading == true:
								print(" we got magic to do it is being loaded")
								additionals_to_be_called.append(data_to_process)
							elif is_it_loading == false:
								print(" we got magic to do we can start loading it now")
								three_stages_of_creation(set_name)
								amount_of_times -=1
								additionals_to_be_called.append([type_of_data, what_data, amount_of_times])
						else:
							print(" we got magic to do set name not found ")
							additionals_to_be_called.append(data_to_process)
					"change_visibilty":
						print(" here we can change its visibility ", data_to_process)
						var container_to_make_visible = get_node(what_data)
						if container_to_make_visible:
							check_if_scene_was_set(container_to_make_visible)
							container_to_make_visible.visible = true
						else:
							additionals_to_be_called.append(data_to_process)
					_:
						additionals_to_be_called.append(data_to_process)
	mutex_additionals_call.unlock()
	var current_time = Time.get_ticks_msec()
	if current_time - memory_metadata["last_cleanup"] > memory_metadata["cleanup_thresholds"]["time_between_cleanups"]:
		var memory_state = check_memory_state()
		print(" memory_state : " , memory_metadata)
		memory_metadata["last_cleanup"] = current_time

func process_system_7():
	var try_turn_7 = mutex_messages_call.try_lock()
	if try_turn_7:
		mutex_messages_call.unlock()
	else:
		mutex_messages_call.unlock()
		return
	mutex_messages_call.lock()
	if messages_to_be_called.size() > 0:
		for i in range(min(max_messages_per_cycle, messages_to_be_called.size())):
			print(" we got magic to do ", messages_to_be_called)
			var data_to_process = messages_to_be_called.pop_front()
			var type_of_message = data_to_process[0]
			var message_to_send = data_to_process[1]
			var receiver = data_to_process[2]
			match type_of_message:
				"singular_lines_text":
					print(" we got magic to do we got containers to add " , data_to_process)
					var container_to_check = check_if_container_available(receiver)
					print(" container_to_check : " , container_to_check)
					if container_to_check == false:
						messages_to_be_called.append(data_to_process)
					elif container_to_check == true:
						print(" container_to_check was found ")
						var datapoint_to_check = check_if_datapoint_available(receiver)
						if datapoint_to_check == false:
							messages_to_be_called.append(data_to_process)
						elif datapoint_to_check == true:
							var datapoint_path_check = check_if_datapoint_node_available(receiver)
							var datapoint_node = get_node_or_null(datapoint_path_check)
							if datapoint_node:
								print(" we got that datapoint to send message")
								var check_movement = datapoint_node.check_if_datapoint_moved_once()
								if check_movement == 1:
									datapoint_node.receive_a_message(message_to_send)
								else:
									messages_to_be_called.append(data_to_process)
							else:
								print(" no node available yet")
								messages_to_be_called.append(data_to_process)
				"load_a_file":
					print("load_a_file we got magic to do we got containers to add " , data_to_process)
					var container_to_check = check_if_container_available(receiver)
					print("load_a_file container_to_check : " , container_to_check)
					if container_to_check == false:
						messages_to_be_called.append(data_to_process)
					elif container_to_check == true:
						print(" container_to_check was found ")
						var datapoint_to_check = check_if_datapoint_available(receiver)
						if datapoint_to_check == false:
							messages_to_be_called.append(data_to_process)
						elif datapoint_to_check == true:
							var datapoint_path_check = check_if_datapoint_node_available(receiver)
							var datapoint_node = get_node_or_null(datapoint_path_check)
							if datapoint_node:
								print("load_a_file we got that datapoint to send message")
								var check_movement = datapoint_node.check_if_datapoint_moved_once()
								print("load_a_file now we gotta check that movement ", check_movement)
								if check_movement == 1:
									print("load_a_file main check not is empty")
									datapoint_node.initialize_loading_file(message_to_send)
								else:
									print("load_a_file main check is empty")
									messages_to_be_called.append(data_to_process)
							else:
								print("load_a_file no node available yet")
								messages_to_be_called.append(data_to_process)
				"keyboard_connection":
					print("Processing keyboard connection")
					var target_container = message_to_send[0]
					var target_thing = message_to_send[1]
					var target_datapoint = message_to_send[2]
					var keyboard_container = get_node_or_null("keyboard_container")
					if !keyboard_container:
						create_new_task("three_stages_of_creation", "keyboard")
						messages_to_be_called.append(data_to_process)
						continue
					var keyboard_dp = get_node_or_null("keyboard_container/thing_24")
					if keyboard_dp:
						var check_movement = keyboard_dp.check_if_datapoint_moved_once()
						if check_movement == 1:
							keyboard_dp.set_connection_target(target_container, target_thing, target_datapoint)
						else:
							messages_to_be_called.append(data_to_process)
					else:
						messages_to_be_called.append(data_to_process)
						continue
				_:
					print(" didnt find it ")
	mutex_messages_call.unlock()

func process_system_8():
	var try_turn_8 = mutex_for_container_state.try_lock()
	if try_turn_8:
		mutex_for_container_state.unlock()
	else:
		mutex_for_container_state.unlock()
		return

var max_textures_applied_per_turn : int = 369

func process_system_9():
	var try_turn_9 = texture_storage_mutex.try_lock()
	if try_turn_9:
		
		if texture_storage.size() > 0:
			for i in range(min(max_textures_applied_per_turn, texture_storage.size())):
				for key in texture_storage:
					print(" texture dilema ", texture_storage[key])
					var node_to_apply_texture = get_node_or_null(key)
					if node_to_apply_texture:
						var potential_material = node_to_apply_texture.material_override
						var material_for_texture
						if !potential_material:
							material_for_texture = MaterialLibrary.get_material("default")
						else:
							material_for_texture = potential_material
						material_for_texture.albedo_texture = texture_storage[key]["texture"]
						print(" what is that node even, texture dilema " , node_to_apply_texture)
						
						if node_to_apply_texture is MeshInstance3D:
							generate_uvs_for_mesh(node_to_apply_texture)
						
						#material_for_texture.uv1_scale = Vector3(1, 1, 1)  # Adjust UV scaling
						#material_for_texture.uv1_offset = Vector3(0, 0, 0)  # Adjust UV offset
						#material_for_texture.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST  # For pixel art textures
						change_material_settings(material_for_texture)
						#material_for_texture.shading_mode = BaseMaterial3D.SHADING_MODE_MAX
						#material_for_texture.transparency = BaseMaterial3D.TRANSPARENCY_MAX
						#material_for_texture.cull_mode = BaseMaterial3D.CULL_DISABLED
						node_to_apply_texture.material_override = material_for_texture
						#node_to_apply_texture.mesh.surface_set_material(0, material_for_texture)#set_surface_override_material(0, material_for_texture)
						
						# Check if it's a MeshInstance3D
						#if node_to_apply_texture is MeshInstance3D:
							## This applies to the instance
							#node_to_apply_texture.set_surface_override_material(0, material_for_texture)
						#else:
							## If it's a mesh resource itself (ArrayMesh, etc.)
							#node_to_apply_texture.surface_set_material(0, material_for_texture)
						
						
						texture_storage.erase(key)
						
						
		
		texture_storage_mutex.unlock()
	else:
		texture_storage_mutex.unlock()
		return


func change_material_settings(material):
	material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_VERTEX
	material.transparency = BaseMaterial3D.TRANSPARENCY_MAX
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material


func apply_texture_with_proper_settings(node_to_apply_texture, texture, node_type="default"):
	# First generate proper UVs if it's a mesh
	if node_to_apply_texture is MeshInstance3D:
		generate_uvs_for_mesh(node_to_apply_texture)
	
	var material_for_texture = MaterialLibrary.get_material("default")
	material_for_texture.albedo_texture = texture
	material_for_texture.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	# Configure material based on node type
	match node_type:
		"flat_shape", "button", "screen", "circle":
			# For flat objects, visible from both sides
			material_for_texture.cull_mode = BaseMaterial3D.CULL_DISABLED  # No face culling
			material_for_texture.uv1_scale = Vector3(1, 1, 1)
			
		"model", "cursor":
			# For 3D models, usually visible from outside only
			material_for_texture.cull_mode = BaseMaterial3D.CULL_BACK  # Cull back faces (default)
			material_for_texture.uv1_scale = Vector3(1, 1, 1)
			
		"heightmap":
			# For terrain-like surfaces, visible from top
			material_for_texture.cull_mode = BaseMaterial3D.CULL_BACK
			# Often for heightmaps, we want a repeating texture
			material_for_texture.uv1_scale = Vector3(5, 5, 5)  # Repeat texture 5 times
			
		"text", "ui_element":
			# For UI elements, visible from front only but needs transparency
			material_for_texture.cull_mode = BaseMaterial3D.CULL_BACK
			material_for_texture.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			
		"glass", "transparent":
			# For transparent objects
			material_for_texture.cull_mode = BaseMaterial3D.CULL_DISABLED
			material_for_texture.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			
		"vegetation", "billboard":
			# For vegetation like grass or trees
			material_for_texture.cull_mode = BaseMaterial3D.CULL_DISABLED
			material_for_texture.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			material_for_texture.alpha_scissor_threshold = 0.5
			
		_:  # default case
			# Default settings for most objects
			material_for_texture.cull_mode = BaseMaterial3D.CULL_BACK
	
	# Apply the material
	node_to_apply_texture.material_override = material_for_texture
	return true






####################
#

# JSH Projections System
#

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓    •    •       ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃┃┏┓┏┓┓┏┓┏╋┓┏┓┏┓┏  ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┣┛┛ ┗┛┃┗ ┗┗┗┗┛┛┗┛  ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888           ┛               ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            

#

# ray points window direction of showing finger of mine
# to understand the computer
# touch of the touch in 3d space too

func get_ray_points(mouse_position: Vector2):
	var from = camera.project_ray_origin(mouse_position)
	var ray_normal = camera.project_ray_normal(mouse_position)
	var to = from + ray_normal * ray_distance_set
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	var data : Array = []
	data.append(result)
	data.append(to)
	data.append(from)
	another_ray_cast(result)
	create_new_task("ray_cast_data_preparer", data) 
	print("ray_cast_stuff are we even at begining? ", data)

func another_ray_cast(result):
	reset_debug_colors()
	if result and result.collider:
		highlight_collision_shape(result.collider)

func process_ray_cast(stuff):
	var from = camera.project_ray_origin(stuff)
	var ray_normal = camera.project_ray_normal(stuff)
	var to = from + ray_normal * ray_distance_set
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	reset_debug_colors()
	if result and result.collider:
		highlight_collision_shape(result.collider)

func reset_debug_colors():
	if _highlighted_colliders:
		for collider in _highlighted_colliders:
			if is_instance_valid(collider):
				reset_collider_debug_color(collider)
		_highlighted_colliders.clear()

func reset_collider_debug_color(collider):
	for child in collider.get_children():
		if child is CollisionShape3D:
			child.debug_color = Color(0, 0, 1, 0.4) 
			child.debug_fill = true

func highlight_collision_shape(collider):
	var found_shape = false
	for child in collider.get_children():
		if child is CollisionShape3D:
			if mouse_status.x == 0:
				print(" testing_ray 0 ")
				child.debug_color = Color(1, 0, 0, 1)  
				child.debug_fill = true
				found_shape = true
				combo_checker(child, mouse_status.x)
			elif mouse_status.x == 1:
				print(" testing_ray 1 ")
				child.debug_color = Color(0, 1, 0, 1)  
				child.debug_fill = true
				found_shape = true
				combo_checker(child, mouse_status.x)
	if found_shape:
		_highlighted_colliders.append(collider)
	if collider is CollisionShape3D:
		if mouse_status.x == 0:
			print(" testing_ray 2 ")
			collider.debug_color = Color(1, 0, 0, 1) 
			collider.debug_fill = true
			_highlighted_colliders.append(collider)
		elif mouse_status.x == 1:
			print(" testing_ray 3 ")
			collider.debug_color = Color(0, 1, 0, 1)  
			collider.debug_fill = true
			_highlighted_colliders.append(collider)

func combo_checker(node_to_check, state_of_button):
	var current_time = Time.get_ticks_msec()
	if combo_array.is_empty() or (current_time - combo_array[-1][2]) > 1000: 
		combo_array = [[node_to_check, state_of_button, current_time]]
		return
	if combo_array[-1][0] == node_to_check:
		if combo_array[-1][1] != state_of_button:
			combo_array.append([node_to_check, state_of_button, current_time])
			check_combo_patterns()
	else:
		combo_array = [[node_to_check, state_of_button, current_time]]
	if combo_array.size() > 10:
		combo_array.pop_front()
	print("COMBO Current combo: ", format_combo_for_display())

func format_combo_for_display():
	var display = []
	for entry in combo_array:
		var node_name = entry[0].get_parent().name if entry[0].get_parent() else "unknown"
		var action = "release" if entry[1] == 0 else "press"
		display.append(node_name + ":" + action)
	return display

func check_combo_patterns():
	if combo_array.size() >= 2:
		var last_two = [combo_array[-2][1], combo_array[-1][1]]
		if last_two == [1, 0] and combo_array[-2][0] == combo_array[-1][0]:
			print("COMBO: Click completed on ", combo_array[-1][0].get_parent().name)
	if combo_array.size() >= 3:
		var last_three_states = [combo_array[-3][1], combo_array[-2][1], combo_array[-1][1]]
		var same_object = (combo_array[-3][0] == combo_array[-2][0] and combo_array[-2][0] == combo_array[-1][0])
		if last_three_states == [1, 1, 0] and same_object:
			var hold_duration = combo_array[-1][2] - combo_array[-3][2]
			if hold_duration > 500:  # Held for 500ms
				print("COMBO: Long press detected on ", combo_array[-1][0].get_parent().name)

func ray_cast_data_preparer(data_ray_cast):
	var results = data_ray_cast[0]
	var tos = data_ray_cast[1]
	var froms = data_ray_cast[2]
	multi_threaded_ray_cast(results, tos, froms)
	print("ray_cast_stuff are we even at begining?")

func multi_threaded_ray_cast(result, to, from):
	if result:
		to = result.position
		var collider = result.collider
		var container_path = result.collider.get_path()
		var container_name_split = str(container_path).split("/")
		var container_name = container_name_split[3]
		var thing_name = container_name_split[4]
		print(" ray_cast_stufff container_name : " , container_name, " andu za thingu : " , thing_name)
		var datapoint
		var datapoint_path_ray_cast
		tree_mutex.lock()
		if scene_tree_jsh["main_root"]["branches"].has(container_name):
			datapoint_path_ray_cast = scene_tree_jsh["main_root"]["branches"][container_name]["datapoint"]["datapoint_path"]
		tree_mutex.unlock()
		if datapoint_path_ray_cast:
			datapoint = jsh_tree_get_node(datapoint_path_ray_cast)
		if datapoint is Node:
			var returned_data = datapoint.thing_interaction(thing_name)
	var line_node_now = jsh_tree_get_node("akashic_records/thing_3")
	if line_node_now:
		var start_end_points : Array = [from, to]
		if line_node_now.has_method("change_points_of_line"):
			line_node_now.change_points_of_line(start_end_points)
			return [from, to]

func old_multi_thread_thingy(result, to, from):
	if result:
		var collider
		var parent = collider.get_parent()
		var containter = parent.get_parent()
		var get_container = func(node: Node, method_name: String):
			while node:
				print("ray_cast_stuff maybe that one? huh? ", node)
				if node.has_method(method_name):
					return node
				node = node.get_parent()
			return null
		var container = get_container.call(containter, "get_datapoint")
		var datapoint = container.get_datapoint()
		print("test000 ", datapoint)
		var current_node = collider
		while current_node != null and not current_node.name.begins_with("thing_"):
			current_node = current_node.get_parent()
		if current_node:
			if datapoint:
				var returned_data = datapoint.thing_interaction(current_node)
				print(" returned data stuff " , returned_data, " new toy : " , mouse_status)
			else:
				print(" somehow we didnt get that datapoint, but we got different kinds of data :) " , container.name)
				var stringy_container = str(container.name)
				tree_mutex.lock()
				var datapoint_path_ray_cast = scene_tree_jsh["main_root"]["branches"][stringy_container]["datapoint"]["datapoint_path"]
				tree_mutex.unlock()
				datapoint = jsh_tree_get_node(datapoint_path_ray_cast)
				if datapoint:
					var returned_data = datapoint.thing_interaction(current_node)
					print(" returned data stuff " , returned_data)
				else:
					print(" i guess it didn work out ?")
	var line_node_now = jsh_tree_get_node("akashic_records/thing_3")
	if line_node_now:
		var start_end_points : Array = [from, to]
		if line_node_now.has_method("change_points_of_line"):
			line_node_now.change_points_of_line(start_end_points)
			return [from, to]

func secondary_interaction_after_rc(array_of_data):
	var size_of_array : int = array_of_data.size()
	var counter_to_know_which : int = 0
	for interactions_to_do in array_of_data :
		var array_to_have_fun_with =  array_of_data[counter_to_know_which]
		counter_to_know_which +=1
		var counter_inter : int = 0
		for inter in ActionsBank.type_of_interactions_0:
			if array_of_data[0][0] == inter:
				match counter_inter:
					0: 
						counter_inter = -1
					1:
						counter_inter = -1
					2: 
						counter_inter = -1
					3:
						counter_inter = -1
					4:
						unload_container(array_to_have_fun_with[1])
						counter_inter = -1
					5: 
						counter_inter = -1
			counter_inter +=1

# JSH Things Creation
#

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┳┓┓ •       ┏┓       •      ┏┓        
#       888  `"Y8888o.   888ooooo888      ┃ ┣┓┓┏┓┏┓┏  ┃ ┏┓┏┓┏┓╋┓┏┓┏┓  ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888      ┻ ┛┗┗┛┗┗┫┛  ┗┛┛ ┗ ┗┻┗┗┗┛┛┗  ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888              ┛                      ┛       
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            

#
# JSH Things Creation

#
func analise_data(thing_name_, type, data_to_analyze, second_part, group_number, verion_of_thing, information_lines_parsed):
	var counter = -1
	for i in RecordsBank.type_of_thing_0:
		counter +=1
		if type == i:
			break
		else:
			continue
	match counter:
		0:
			create_flat_shape(thing_name_, data_to_analyze, second_part, group_number, verion_of_thing, information_lines_parsed)
		1:
			create_text_label(thing_name_, data_to_analyze, second_part, group_number, verion_of_thing, information_lines_parsed)
		2:
			create_array_mesh(thing_name_, data_to_analyze, second_part, group_number, verion_of_thing, information_lines_parsed) 
		3:
			create_button_with_rounded_corners(thing_name_, data_to_analyze, second_part, group_number, verion_of_thing, information_lines_parsed)
			#create_button(thing_name_, data_to_analyze, second_part, group_number, verion_of_thing, information_lines_parsed)
		4:
			create_cursor(thing_name_, data_to_analyze, second_part, group_number, verion_of_thing, information_lines_parsed)
		5:
			create_connection(thing_name_, data_to_analyze, second_part, group_number, verion_of_thing, information_lines_parsed)
		6:
			create_screen(thing_name_, data_to_analyze, second_part, group_number, verion_of_thing, information_lines_parsed)
		7:
			create_datapoint(thing_name_, data_to_analyze, second_part, group_number, verion_of_thing, information_lines_parsed)
		8:
			create_circle_shape(thing_name_, data_to_analyze, second_part, group_number, verion_of_thing, information_lines_parsed)
		9:
			create_container(thing_name_, data_to_analyze, second_part, group_number, verion_of_thing, information_lines_parsed)
		10:
			create_textmesh(thing_name_, data_to_analyze, second_part, group_number, verion_of_thing, information_lines_parsed)
		_:  
			print("hmmm didnt find the type of thing?")

func create_circle_shape(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
	var coords = first_line[1]
	var to_rotate = first_line[2]
	var radius = data_to_write[0]
	var num_points = data_to_write[1]
	var points = generate_circle_points(int(radius[0]), int(num_points[0]))
	# Create the shape using your existing create_flat_shape function
	create_flat_shape(node_name, first_line, points, group_name, version_of_thing, information_lines_parsed)

func generate_circle_points(radius: float, num_points: int) -> Array:
	# Ensure minimum 3 points and maximum 33 points
	num_points = clamp(num_points, 3, 33)
	var points_to_clean
	var points = []
	var points_array = []
	var angle_step = TAU / num_points  # TAU is 2*PI, for a full circle
	for i in range(num_points):
		var angle = i * angle_step
		var x : float = radius * cos(angle)
		var y : float = radius * sin(angle)
		var z : float
		points_to_clean = "%0.1f,%0.1f,0.0" % [x, y]
		points_to_clean = points_to_clean.split(",")
		points.append(points_to_clean)
	return points

func create_flat_shape(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
	var node_path_c_f_s = first_line[6][0]
	var coords = first_line[1]
	var to_rotate = first_line[2]
	var color_to_change = float(information_lines_parsed[1][0][0])
	var opacity_to_change = float(information_lines_parsed[1][1][0])
	var material = MaterialLibrary.get_material("default")
	var color_to_add_op = get_spectrum_color(color_to_change)
	color_to_add_op.a = opacity_to_change
	material.albedo_color = color_to_add_op
	#material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	vertices.push_back(Vector3.ZERO)
	var vector_points = []
	for point in data_to_write:
		var point_vector = Vector3(float(point[0]), float(point[1]), float(point[2]))
		vector_points.append(point_vector)
		vertices.push_back(point_vector)
	for i in range(vector_points.size()):
		var next_i = (i + 1) % vector_points.size()
		indices.append(0)     
		indices.append(i + 1)
		indices.append(next_i + 1)
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = arr_mesh
	#material.cull_mode = BaseMaterial3D.CULL_DISABLED 
	var node_type = "flat_shape"
	mesh_instance.material_override = material
	node_creation(node_name, mesh_instance, coords, to_rotate, group_name, node_type, node_path_c_f_s)

func create_text_label(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
	var node_path_c_t_l = first_line[6][0]
	var coords = first_line[1]
	var to_rotate = first_line[2]
	var text_label = Label3D.new()
	text_label.render_priority = 1
	text_label.text = data_to_write[0][0]
	text_label.font_size = int(data_to_write[1][0])  
	text_label.no_depth_test = true  
	text_label.modulate = Color(1, 1, 1)  
	var node_type = "text"
	node_creation(node_name, text_label, coords, to_rotate, group_name, node_type, node_path_c_t_l)

func create_array_mesh(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
	var node_path_c_a_m = first_line[6][0]
	var coords = first_line[1]
	var to_rotate = first_line[2]
	var color_to_change = float(information_lines_parsed[1][0][0])
	var opacity_to_change = float(information_lines_parsed[1][1][0])
	var vertices = PackedVector3Array()
	var vector_points = []
	for point in data_to_write:
		vector_points.append(Vector3(float(point[0]), float(point[1]), float(point[2])))
	vertices.append(vector_points[0])
	vertices.append(vector_points[2])
	vertices.append(vector_points[1])
	vertices.append(vector_points[0])
	vertices.append(vector_points[3])
	vertices.append(vector_points[2])
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = arr_mesh
	var material = MaterialLibrary.get_material("default")
	var color_to_add_op = get_spectrum_color(color_to_change)
	color_to_add_op.a = opacity_to_change
	material.albedo_color = color_to_add_op
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	mesh_instance.material_override = material
	var node_type = "model"
	node_creation(node_name, mesh_instance, coords, to_rotate, group_name, node_type, node_path_c_a_m)

func create_textmesh(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
	var node_path_c_tm = first_line[6][0]
	var coords = first_line[1]
	var to_rotate = first_line[2]
	var text_for_label = information_lines_parsed[1][0][0]
	var size_for_label = int(information_lines_parsed[1][1][0])
	var depth = float(information_lines_parsed[1][2][0])
	var pixel_size = float(information_lines_parsed[1][3][0])
	var color_to_change = float(information_lines_parsed[1][4][0])
	var opacity_to_change = float(information_lines_parsed[1][5][0])
	var material = MaterialLibrary.get_material("default")
	var color_to_add_op = get_spectrum_color(color_to_change)
	color_to_add_op.a = opacity_to_change
	material.albedo_color = color_to_add_op
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_HASH
	var mesh_instance = MeshInstance3D.new()
	var text_mesh = TextMesh.new()
	text_mesh.text = text_for_label
	text_mesh.font_size = size_for_label
	text_mesh.depth = depth
	text_mesh.pixel_size = pixel_size
	text_mesh.horizontal_alignment = 1
	text_mesh.vertical_alignment = 1
	mesh_instance.mesh = text_mesh
	mesh_instance.name = node_name
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	#change_material_settings(material)
	
	if text_for_label == "JSH":
		material.metallic = 1.0
		material.metallic_specular = 0.52
		material.roughness = 0.33
	mesh_instance.material_override = material
	var node_type = "textmesh"
	node_creation(node_name, mesh_instance, coords, to_rotate, group_name, node_type, node_path_c_tm)

########## button test


func generate_rounded_rect(width: float, height: float, corner_radius: float, depth: float = 0.0) -> Array:
	var points = []
	var num_points_per_corner = 8  # More points = smoother corners
	
	# Ensure corner radius isn't larger than half the smallest dimension
	corner_radius = min(corner_radius, min(width/2, height/2))
	
	# Calculate the inner rectangle coordinates
	var inner_left = -width/2 + corner_radius
	var inner_right = width/2 - corner_radius
	var inner_top = height/2 - corner_radius
	var inner_bottom = -height/2 + corner_radius
	
	# Generate points for each corner
	# Top-right corner
	for i in range(num_points_per_corner + 1):
		var angle = 0 + (i * (PI/2) / num_points_per_corner)
		var x = inner_right + corner_radius * cos(angle)
		var y = inner_top + corner_radius * sin(angle)
		points.append([str(x), str(y), str(depth)])
	
	# Top-left corner
	for i in range(num_points_per_corner + 1):
		var angle = PI/2 + (i * (PI/2) / num_points_per_corner)
		var x = inner_left + corner_radius * cos(angle)
		var y = inner_top + corner_radius * sin(angle)
		points.append([str(x), str(y), str(depth)])
	
	# Bottom-left corner
	for i in range(num_points_per_corner + 1):
		var angle = PI + (i * (PI/2) / num_points_per_corner)
		var x = inner_left + corner_radius * cos(angle)
		var y = inner_bottom + corner_radius * sin(angle)
		points.append([str(x), str(y), str(depth)])
	
	# Bottom-right corner
	for i in range(num_points_per_corner + 1):
		var angle = 3*PI/2 + (i * (PI/2) / num_points_per_corner)
		var x = inner_right + corner_radius * cos(angle)
		var y = inner_bottom + corner_radius * sin(angle)
		points.append([str(x), str(y), str(depth)])
	
	return points


func create_rounded_button(node_name: String, first_line: Array, data_to_write: Array, group_name: String, version_of_thing: String, information_lines_parsed: Array, corner_radius: float = 0.1):
	# First, analyze the existing rectangle data to get width and height
	var min_x = float(data_to_write[0][0])
	var min_y = float(data_to_write[0][1])
	var max_x = float(data_to_write[0][0])
	var max_y = float(data_to_write[0][1])
	
	# Find the bounds of the rectangle
	for point in data_to_write:
		var x = float(point[0])
		var y = float(point[1])
		min_x = min(min_x, x)
		min_y = min(min_y, y)
		max_x = max(max_x, x)
		max_y = max(max_y, y)
	
	# Calculate width and height
	var width = max_x - min_x
	var height = max_y - min_y
	var z_value = data_to_write[0][2]  # Assuming z is constant for all points
	
	# Ensure the corner radius isn't too large
	corner_radius = min(corner_radius, min(width/2, height/2))
	
	# Generate the rounded rectangle points
	var rounded_points = []
	var num_points_per_corner = 5  # You can adjust this for smoother corners
	
	# Define the inner rectangle coordinates
	var inner_left = min_x + corner_radius
	var inner_right = max_x - corner_radius
	var inner_top = max_y - corner_radius
	var inner_bottom = min_y + corner_radius
	
	# Top-right corner
	for i in range(num_points_per_corner):
		var angle = 0 + (i * (PI/2) / (num_points_per_corner-1))
		var x = inner_right + corner_radius * cos(angle)
		var y = inner_top + corner_radius * sin(angle)
		rounded_points.append([str(x), str(y), z_value])
	
	# Top-left corner
	for i in range(num_points_per_corner):
		var angle = PI/2 + (i * (PI/2) / (num_points_per_corner-1))
		var x = inner_left + corner_radius * cos(angle)
		var y = inner_top + corner_radius * sin(angle)
		rounded_points.append([str(x), str(y), z_value])
	
	# Bottom-left corner
	for i in range(num_points_per_corner):
		var angle = PI + (i * (PI/2) / (num_points_per_corner-1))
		var x = inner_left + corner_radius * cos(angle)
		var y = inner_bottom + corner_radius * sin(angle)
		rounded_points.append([str(x), str(y), z_value])
	
	# Bottom-right corner
	for i in range(num_points_per_corner):
		var angle = 3*PI/2 + (i * (PI/2) / (num_points_per_corner-1))
		var x = inner_right + corner_radius * cos(angle)
		var y = inner_bottom + corner_radius * sin(angle)
		rounded_points.append([str(x), str(y), z_value])
	
	# Now call your existing create_button function with the rounded points
	create_button(node_name, first_line, rounded_points, group_name, version_of_thing, information_lines_parsed)



func create_button_with_rounded_corners(node_name: String, first_line: Array, data_to_write: Array, 
										group_name: String, version_of_thing: String, 
										information_lines_parsed: Array, corner_radius: float = 0.1):
	var node_path_c_b = first_line[6][0]
	var coords = first_line[1]
	var to_rotate = first_line[2]
	var mesh_name = "shape_" + node_name 
	var text_label_name = "text_" + node_name
	var color_to_change = float(information_lines_parsed[1][2][0])
	var opacity_to_change = float(information_lines_parsed[1][3][0])
	var material = MaterialLibrary.get_material("default")
	var color_to_add_op = get_spectrum_color(color_to_change)
	color_to_add_op.a = opacity_to_change
	material.albedo_color = color_to_add_op
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	var text_for_label = information_lines_parsed[1][0][0]
	var size_for_label = int(information_lines_parsed[1][1][0])
	var button_node = Node3D.new()
	button_node.name = node_name
	tasked_children(button_node, node_path_c_b)
	
	# Extract rectangle dimensions
	var min_x = float(data_to_write[0][0])
	var min_y = float(data_to_write[0][1])
	var max_x = min_x
	var max_y = min_y
	var z_value = data_to_write[0][2]
	
	for point in data_to_write:
		var x = float(point[0])
		var y = float(point[1])
		min_x = min(min_x, x)
		min_y = min(min_y, y)
		max_x = max(max_x, x)
		max_y = max(max_y, y)
	
	var width = max_x - min_x
	var height = max_y - min_y
	
	# Adjust corner radius if needed
	corner_radius = min(corner_radius, min(width/2, height/2))
	
	# Generate vertices for the rounded rectangle
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	
	# Center point (for triangulation)
	var center_x = (min_x + max_x) / 2
	var center_y = (min_y + max_y) / 2
	vertices.push_back(Vector3(center_x, center_y, float(z_value)))
	
	# Define the inner rectangle coordinates
	var inner_left = min_x + corner_radius
	var inner_right = max_x - corner_radius
	var inner_top = max_y - corner_radius
	var inner_bottom = min_y + corner_radius
	
	var num_points_per_corner = 5  # Adjust for smoothness
	var perimeter_points = []
	
	# Generate perimeter points
	# Top-right corner (0 to PI/2)
	for i in range(num_points_per_corner):
		var angle = 0 + (i * (PI/2) / (num_points_per_corner-1))
		var x = inner_right + corner_radius * cos(angle)
		var y = inner_top + corner_radius * sin(angle)
		perimeter_points.append(Vector3(x, y, float(z_value)))
	
	# Top-left corner (PI/2 to PI)
	for i in range(num_points_per_corner):
		var angle = PI/2 + (i * (PI/2) / (num_points_per_corner-1))
		var x = inner_left + corner_radius * cos(angle)
		var y = inner_top + corner_radius * sin(angle)
		perimeter_points.append(Vector3(x, y, float(z_value)))
	
	# Bottom-left corner (PI to 3PI/2)
	for i in range(num_points_per_corner):
		var angle = PI + (i * (PI/2) / (num_points_per_corner-1))
		var x = inner_left + corner_radius * cos(angle)
		var y = inner_bottom + corner_radius * sin(angle)
		perimeter_points.append(Vector3(x, y, float(z_value)))
	
	# Bottom-right corner (3PI/2 to 2PI)
	for i in range(num_points_per_corner):
		var angle = 3*PI/2 + (i * (PI/2) / (num_points_per_corner-1))
		var x = inner_right + corner_radius * cos(angle)
		var y = inner_bottom + corner_radius * sin(angle)
		perimeter_points.append(Vector3(x, y, float(z_value)))
	
	# Add all perimeter points to vertices
	for point in perimeter_points:
		vertices.push_back(point)
	
	# Create fan triangulation from center
	for i in range(perimeter_points.size()):
		indices.append(0)  # Center vertex
		indices.append(i + 1)
		indices.append(((i + 1) % perimeter_points.size()) + 1)
	
	# Create the mesh
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = arr_mesh
	mesh_instance.name = mesh_name
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = material
	
	# Set up the text label
	var text_label = Label3D.new()
	text_label.name = text_label_name
	text_label.text = text_for_label
	text_label.font_size = size_for_label
	text_label.no_depth_test = true
	text_label.modulate = Color(1, 1, 1) 
	text_label.position.z += 0.01 
	
	var mesh_path = node_path_c_b + "/" + mesh_name
	var label_path = node_path_c_b + "/" + text_label_name
	tasked_children(text_label, label_path)
	
	var node_type = "button"
	node_creation(mesh_name, mesh_instance, coords, to_rotate, group_name, node_type, mesh_path)



#################


func create_button(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):

	print("create button data : ", node_name, " , " , first_line, " , ", data_to_write, " , " , group_name, " , " , version_of_thing , " , " , information_lines_parsed)
	var node_path_c_b = first_line[6][0]
	var coords = first_line[1]
	var to_rotate = first_line[2]
	var mesh_name = "shape_" + node_name 
	var text_label_name = "text_" + node_name
	var color_to_change = float(information_lines_parsed[1][2][0])
	var opacity_to_change = float(information_lines_parsed[1][3][0])
	var material = MaterialLibrary.get_material("default")
	var color_to_add_op = get_spectrum_color(color_to_change)
	color_to_add_op.a = opacity_to_change
	material.albedo_color = color_to_add_op
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	var text_for_label = information_lines_parsed[1][0][0]
	var size_for_label = int(information_lines_parsed[1][1][0])
	var button_node = Node3D.new()
	button_node.name = node_name
	tasked_children(button_node, node_path_c_b)
	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()
	var vector_points = []
	for point in data_to_write:
		var point_vector = Vector3(float(point[0]), float(point[1]), float(point[2]))
		vector_points.append(point_vector)
		vertices.push_back(point_vector)
	indices.append(0)  
	indices.append(1)
	indices.append(2)
	indices.append(0)  
	indices.append(2)
	indices.append(3)
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = arr_mesh
	mesh_instance.name = mesh_name
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = material
	var text_label = Label3D.new()
	text_label.name = text_label_name
	text_label.text = text_for_label
	text_label.font_size = size_for_label
	text_label.no_depth_test = true
	text_label.modulate = Color(1, 1, 1) 
	text_label.position.z += 0.01 
	var mesh_path = node_path_c_b + "/" + mesh_name
	var label_path = node_path_c_b + "/" + text_label_name
	tasked_children(text_label, label_path)
	var node_type = "button"
	node_creation(mesh_name, mesh_instance, coords, to_rotate, group_name, node_type, mesh_path)

func create_cursor(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
	var node_path_c_c_0 = first_line[6][0]
	var coords = first_line[1]
	var to_rotate = first_line[2]
	var color_to_change = float(information_lines_parsed[1][0][0])
	var opacity_to_change = float(information_lines_parsed[1][1][0])
	var material = MaterialLibrary.get_material("default")
	var color_to_add_op = get_spectrum_color(color_to_change)
	color_to_add_op.a = opacity_to_change
	material.albedo_color = color_to_add_op
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	var vertices = PackedVector3Array()
	var triangle_data = [data_to_write[0], data_to_write[1], data_to_write[2]]
	var triangle_scale = data_to_write[3] 
	var triangle_scale_vec3 : Vector3 = Vector3(float(triangle_scale[0]), float(triangle_scale[1]), float(triangle_scale[2]))
	var vector_points = []
	for point in triangle_data:
		vector_points.append(Vector3(float(point[0]), float(point[1]), float(point[2])))
	vertices.append(vector_points[0])
	vertices.append(vector_points[1])
	vertices.append(vector_points[2])
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = arr_mesh
	mesh_instance.scale = triangle_scale_vec3
	material.cull_mode = StandardMaterial3D.CULL_DISABLED 
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED  
	mesh_instance.material_override = material
	var node_type = "cursor"
	node_creation(node_name, mesh_instance, coords, to_rotate, group_name, node_type, node_path_c_c_0)

func create_connection(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
	var node_path_cc_c = first_line[6][0]
	var coords = first_line[1]
	var to_rotate = first_line[2]
	var cords_for_line = [data_to_write[0], data_to_write[1]]
	var color_for_line = data_to_write[2][0]
	var point1 = Vector3(
		float(cords_for_line[0][0]),
		float(cords_for_line[0][1]),
		float(cords_for_line[0][2])
	)
	var point2 = Vector3(
		float(cords_for_line[1][0]),
		float(cords_for_line[1][1]),
		float(cords_for_line[1][2])
	)
	var center = point1 + point2 / 2
	var mesh_instance = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	mesh_instance.mesh = immediate_mesh
	mesh_instance.name = node_name
	var material = MaterialLibrary.get_material("default")
	material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	var color_line = float(data_to_write[2][0])
	material.albedo_color = get_spectrum_color(color_line)
	mesh_instance.material_override = material
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
	immediate_mesh.surface_add_vertex(point1 + center)
	immediate_mesh.surface_add_vertex(center)
	immediate_mesh.surface_add_vertex(center)
	immediate_mesh.surface_add_vertex(point2 + center)
	immediate_mesh.surface_end()
	mesh_instance.set_script(LineScript)
	var node_type = "connection"
	node_creation(node_name, mesh_instance, coords, to_rotate, group_name, node_type, node_path_cc_c)

func create_screen(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
	var node_path_c_s = first_line[6][0]
	var coords = first_line[1]
	var to_rotate = first_line[2]
	var color_to_change = float(information_lines_parsed[1][0][0])
	var opacity_to_change = float(information_lines_parsed[1][1][0])
	var material = MaterialLibrary.get_material("default")
	var color_to_add_op = get_spectrum_color(color_to_change)
	color_to_add_op.a = opacity_to_change
	material.albedo_color = color_to_add_op
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
	var vertices = PackedVector3Array()
	var vector_points = []
	for point in data_to_write:
		vector_points.append(Vector3(float(point[0]), float(point[1]), float(point[2])))
	vertices.append(vector_points[0])
	vertices.append(vector_points[2])
	vertices.append(vector_points[1])
	vertices.append(vector_points[0])
	vertices.append(vector_points[3])
	vertices.append(vector_points[2])
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = arr_mesh
	mesh_instance.material_override = material
	var node_type =  "screen"
	node_creation(node_name, mesh_instance, coords, to_rotate, group_name, node_type, node_path_c_s)

func create_datapoint(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
	var node_path_c_dp = first_line[6][0]
	var coords = first_line[1]
	var to_rotate = first_line[2]
	var data_point = Node3D.new()
	data_point.set_script(DataPointScript)
	data_point.setup_main_reference(self)
	var message_tester 
	message_tester = data_point.power_up_data_point(node_name, int(version_of_thing), data_to_write)
	var node_type = "datapoint"
	node_creation(node_name, data_point, coords, to_rotate, group_name, node_type, node_path_c_dp)

func create_container(node_name: String, first_line : Array, data_to_write : Array, group_name : String, version_of_thing : String, information_lines_parsed : Array):
	print(" container test ? ", data_to_write[1][0])
	var visibility_of_container = int(data_to_write[1][0])
	var node_path_c_con = first_line[6][0]
	var coords = first_line[1]
	var to_rotate = first_line[2]
	var container 
	container = Node3D.new()
	container.name = data_to_write[0][0]
	if visibility_of_container == 0:
		container.visible = false
	container.set_script(ContainterScript)
	if container.has_method("container_initialize"):
		container.container_initialize(data_to_write)
	var node_type = "container"
	node_creation(data_to_write[0][0], container, coords, to_rotate, group_name, node_type, node_path_c_con)

func get_spectrum_color(value: float) -> Color:
	# Ensure value is between 0 and 1
	value = clamp(value, 0.0, 1.0)
	# Map 0-1 to our 9 color points
	var color_index = value * 10  # 10 segments for 11 colors
	var colors = [
		Color(0.0, 0.0, 0.0),      # 1. Black
		Color(1.0, 1.0, 1.0),      # 2. White
		Color(0.0, 0.0, 0.0),      # 3. Black
		Color(0.45, 0.25, 0.0),    # 4. Brown
		Color(1.0, 0.0, 0.0),      # 5. Red
		Color(1.0, 0.5, 0.0),      # 6. Orange
		Color(1.0, 1.0, 0.0),      # 7. Yellow
		Color(1.0, 1.0, 1.0),      # 8. White
		Color(0.0, 1.0, 0.0),      # 9. Green
		Color(0.0, 0.0, 1.0),      # 10. Blue
		Color(0.5, 0.0, 0.5)       # 11. Purple
	]
	var lower_index = floor(color_index)
	var upper_index = ceil(color_index)
	var t = color_index - lower_index
	return colors[lower_index].lerp(colors[min(upper_index, 8)], t)

#
# JSH Scene Tree Add Nodes, Physical and Astral Bodies
#

#      oooo  .oooooo..o ooooo   ooooo      ┏┓         ┏┳┓        ┏┓ ┓ ┓  ┳┓   ┓     
#      `888 d8P'    `Y8 `888'   `888'      ┗┓┏┏┓┏┓┏┓   ┃ ┏┓┏┓┏┓  ┣┫┏┫┏┫  ┃┃┏┓┏┫┏┓┏   
#       888 Y88bo.       888     888       ┗┛┗┗ ┛┗┗    ┻ ┛ ┗ ┗   ┛┗┗┻┗┻  ┛┗┗┛┗┻┗ ┛   
#       888  `"Y8888o.   888ooooo888      ┏┓┓    •   ┓       ┓  ┏┓      ┓  ┳┓   ┓•  
#       888      `"Y88b  888     888      ┃┃┣┓┓┏┏┓┏┏┓┃  ┏┓┏┓┏┫  ┣┫┏╋┏┓┏┓┃  ┣┫┏┓┏┫┓┏┓┏
#       888 oo     .d8P  888     888      ┣┛┛┗┗┫┛┗┗┗┻┗  ┗┻┛┗┗┻  ┛┗┛┗┛ ┗┻┗  ┻┛┗┛┗┻┗┗ ┛
#   .o. 88P 8""88888P'  o888o   o888o          ┛                        
#   `Y888P                            

#
# JSH Scene Tree Add Nodes, Physical and Astral Bodies, also Sprit bodies ;)

func node_creation(node_name, crafted_data, coords, to_rotate, group_number, node_type, path_of_thing):
	crafted_data.add_to_group(group_number)
	var pos_parts = coords
	var position_ = Vector3(float(pos_parts[0]), float(pos_parts[1]), float(pos_parts[2]))
	crafted_data.position = position_
	var rot_parts = to_rotate
	var rotation_euler = Vector3(float(rot_parts[0]), float(rot_parts[1]), float(rot_parts[2]))
	crafted_data.rotation_degrees = rotation_euler
	
	
	
	## suspect found, i repeat suspect found
	## the wanted piece of lines that can break things
	## if there is no name, we wont move this baby on tree, stuff can beecome broken
	if node_name != "":
		crafted_data.name = node_name
		
	# Add textures if appropriate (before collisions so they don't affect texture)
	if node_type in ["flat_shape", "model", "cursor", "screen", "circle", "button"]:
		# Get color parameters from the shape creation data
		var color_params = null
		if crafted_data is MeshInstance3D and crafted_data.material_override:
			color_params = {
				"color": crafted_data.material_override.albedo_color
			}
		add_texture_to_thing_task_creator(crafted_data, node_type, color_params, path_of_thing)
	
	
	tasked_children(crafted_data, path_of_thing)
	match node_type:
		"flat_shape", "model", "cursor", "screen", "circle", "button" :
			add_collision_to_thing(crafted_data, node_type, path_of_thing, node_name)
		_:
			pass
	return crafted_data

#############################






# add_texture_to_thing_task_creator(crafted_data, node_type, get_mesh_data(crafted_data), color_params)

func add_texture_to_thing_task_creator(thing_node, node_type, color_params, path_for_thing):
	var data_to_send_for_texture : Array = []
	data_to_send_for_texture.append(thing_node)
	data_to_send_for_texture.append(node_type)
	data_to_send_for_texture.append(color_params)
	data_to_send_for_texture.append(path_for_thing)
	
	var task_name : String = "add_texture_to_thing_preparer"
	create_new_task(task_name, data_to_send_for_texture)


var texture_storage_mutex = Mutex.new()

func add_texture_to_thing_preparer(data_to_create):
	var crafted_data = data_to_create[0]
	var node_type = data_to_create[1]
	var color_params = data_to_create[2]
	var path_of_the_thing = data_to_create[3]
	
	
	base_textures_mutex.lock()
	# Initialize base textures if not done yet
	if base_textures["square"] == null:
		base_textures_mutex.unlock()
		initialize_base_textures()
		base_textures_mutex.lock()
	
	# Determine color value
	var color_value = 0.5  # Default
	if color_params and color_params.has("color"):
		color_value = color_params.color
	
	# Pick texture based on shape type
	var texture_to_apply = null
	match node_type:
		"circle":
			texture_to_apply = base_textures["circle"]
		"flat_shape", "button", "screen", "model":
			texture_to_apply = base_textures["square"]
		_:
			print("hmm")
			#texture_to_apply = base_textures["square"]
			
	base_textures_mutex.unlock()
	
	# Store texture and color for later application
	var texture_data = {
		"texture": texture_to_apply,
		"color": get_spectrum_color(0.5)
	}
	
	# Store for later application
	
	texture_storage_mutex.lock()
	texture_storage[path_of_the_thing] = texture_data
	texture_storage_mutex.unlock()
	
	#return {"status": "success", "path": path_of_the_thing}
	#var mesh_data = get_mesh_data(crafted_data)
	
	# Generate the texture
	#var texture_to_apply = generate_texture_for_shape(mesh_data, node_type)
	
	# Now we can use texture_to_apply later with the path
	#ninth_dimensional_magic("store_texture", path_of_the_thing, texture_to_apply)
	#add_texture_to_thing(crafted_data, node_type, get_mesh_data(crafted_data), color_params)
	#var texture_to_apply
	## use path here as we have it, so we can send it further, to apply it to a thing


var base_textures_mutex = Mutex.new()

var base_textures = {
	"square": null,
	"circle": null
}


@onready var texture_two_di_node = $Node2D/TextureRect

func initialize_base_textures():
	# Square texture (gradient from center)
	var square_img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	var center = Vector2(128, 128)
	
	for y in range(256):
		for x in range(256):
			var dist = center.distance_to(Vector2(x, y)) / 180.0
			dist = clamp(dist, 0.0, 1.0)
			var alpha = 1.0 - dist / 1.5
			square_img.set_pixel(x, y, Color(1, 1, 1, alpha))
	
	# Circle texture (radial gradient)
	var circle_img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	
	for y in range(256):
		for x in range(256):
			var dist = center.distance_to(Vector2(x, y)) / 128.0
			if dist <= 1.0:
				var alpha = 1.0 - dist
				circle_img.set_pixel(x, y, Color(1, 1, 1, alpha))
			else:
				circle_img.set_pixel(x, y, Color(0, 0, 0, 0))
	
	# Convert to ImageTexture
	
	#var rounded_square_texture = generate_rounded_rect_texture(2.0, 1.5, 0.3)
	
	base_textures_mutex.lock()
	base_textures["square"] = ImageTexture.create_from_image(square_img)
	#base_textures["rounded_square"] = rounded_square_texture#ImageTexture.create_from_image(rounded_square_texture)
	texture_two_di_node.set_texture(base_textures["square"])
	base_textures["circle"] = ImageTexture.create_from_image(circle_img)
	base_textures_mutex.unlock()



func generate_rounded_rect_texture(width, height, corner_radius, color_value=0.5, alpha_value=1.0):
	# Create a new image
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))  # Start with transparent
	
	# Calculate inner rectangle coordinates (scaled to image size)
	var img_width = 256
	var img_height = 256
	
	# Ensure corner radius isn't larger than half the smallest dimension
	corner_radius = min(corner_radius, min(width/2, height/2))
	
	# Scale the dimensions to fit the image
	var scale = min(img_width / width, img_height / height) * 0.8  # 80% to add margin
	
	var scaled_width = width * scale
	var scaled_height = height * scale
	var scaled_radius = corner_radius * scale
	
	var inner_left = (img_width - scaled_width) / 2 + scaled_radius
	var inner_right = (img_width + scaled_width) / 2 - scaled_radius
	var inner_top = (img_height - scaled_height) / 2 + scaled_radius
	var inner_bottom = (img_height + scaled_height) / 2 - scaled_radius
	
	# Get base color
	var base_color = get_spectrum_color(color_value)
	base_color.a = alpha_value
	
	# Generate gradient
	for y in range(img_height):
		for x in range(img_width):
			# Check if point is inside the rounded rectangle
			var inside = false
			
			# Check if inside the center rectangle
			if x >= inner_left and x <= inner_right and y >= inner_top and y <= inner_bottom:
				inside = true
			
			# Check if inside any corner
			else:
				# Top-right corner
				if x > inner_right and y > inner_top and y < inner_bottom:
					var corner_center = Vector2(inner_right, inner_top + inner_bottom - inner_top)
					if Vector2(x, y).distance_to(corner_center) <= scaled_radius:
						inside = true
				
				# Top-left corner
				elif x < inner_left and y > inner_top and y < inner_bottom:
					var corner_center = Vector2(inner_left, inner_top + inner_bottom - inner_top)
					if Vector2(x, y).distance_to(corner_center) <= scaled_radius:
						inside = true
				
				# Bottom-left corner
				elif x < inner_left and y < inner_top and y > inner_bottom:
					var corner_center = Vector2(inner_left, inner_bottom)
					if Vector2(x, y).distance_to(corner_center) <= scaled_radius:
						inside = true
				
				# Bottom-right corner
				elif x > inner_right and y < inner_top and y > inner_bottom:
					var corner_center = Vector2(inner_right, inner_bottom)
					if Vector2(x, y).distance_to(corner_center) <= scaled_radius:
						inside = true
			
			if inside:
				# Create gradient effect from center to edge
				var center = Vector2(img_width/2, img_height/2)
				var dist = Vector2(x, y).distance_to(center) / (min(img_width, img_height) / 2)
				var gradient_factor = 1.0 - dist * 0.5
				
				var pixel_color = base_color
				pixel_color.r *= gradient_factor
				pixel_color.g *= gradient_factor
				pixel_color.b *= gradient_factor
				
				img.set_pixel(x, y, pixel_color)
	
	# Add subtle pattern or texture
	add_noise_pattern(img, base_color, 0.05)
	
	# Create ImageTexture from Image
	var texture = ImageTexture.create_from_image(img)
	return texture



###############




func add_texture_to_thing(thing_node, node_type, mesh_data, color_params):
	# Skip if not a MeshInstance3D
	var mesh_instance = thing_node as MeshInstance3D
	if not mesh_instance or not mesh_instance.mesh:
		return
		
	# Get the existing material if available
	var material = mesh_instance.material_override
	if not material:
		material = MaterialLibrary.get_material("default")
	
	# Generate texture based on node type and mesh data
	var texture = generate_texture_for_shape(mesh_data, node_type)
	if texture:
		# Create a copy of the material for textured version
		var textured_material = material.duplicate()
		textured_material.albedo_texture = texture
		
		# Store both materials for toggling
		mesh_instance.set_meta("material_plain", material)
		mesh_instance.set_meta("material_textured", textured_material)
		
		# Apply the textured version if textures are enabled
		if is_textures_enabled():
			mesh_instance.material_override = textured_material
		else:
			mesh_instance.material_override = material

# Helper function to extract mesh data
func get_mesh_data(node):
	var mesh_data = []
	var mesh_instance = node as MeshInstance3D
	if mesh_instance and mesh_instance.mesh:
		# Get vertices from the mesh
		var vertices = mesh_instance.mesh.get_faces()
		mesh_data.append(vertices)
	return mesh_data

var textures_enabled = true

func toggle_textures():
	textures_enabled = !textures_enabled
	
	# Find all objects with materials in the scene
	var objects = get_tree().get_nodes_in_group("texturable")
	for obj in objects:
		if obj is MeshInstance3D:
			if obj.has_meta("material_plain") and obj.has_meta("material_textured"):
				obj.material_override = obj.get_meta("material_textured") if textures_enabled else obj.get_meta("material_plain")
	
	print("Textures " + ("enabled" if textures_enabled else "disabled"))

func is_textures_enabled():
	return textures_enabled

func generate_texture_for_shape(shape_data, node_type, default_params=null):
	# Extract shape data
	var vertices = []
	var color_info = []
	
	# Parse shape data from your records format
	if shape_data.size() > 0:
		# Get vertex information from first parameter array
		var vertex_data = shape_data[0]
		if vertex_data is Array:
			for vertex_str in vertex_data:
				var coords = vertex_str.split(",")
				if coords.size() >= 2:
					vertices.append(Vector2(float(coords[0]), float(coords[1])))
		
		# Get color information from second parameter array if it exists
		if shape_data.size() > 1:
			var color_data = shape_data[1]
			if color_data is Array and color_data.size() > 0:
				var color_parts = color_data[0].split("|")
				if color_parts.size() >= 1:
					color_info = color_parts
	
	# Set defaults if data is missing
	if vertices.is_empty() and default_params and default_params.has("vertices"):
		vertices = default_params.vertices
	
	if color_info.is_empty() and default_params and default_params.has("color_info"):
		color_info = default_params.color_info
	
	# Generate texture based on shape type
	var img = Image.create(256, 256, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))  # Start with transparent
	
	var color_value = 0.5  # Default
	var alpha_value = 1.0  # Default
	
	if color_info.size() >= 1:
		color_value = float(color_info[0])
	if color_info.size() >= 2:
		alpha_value = float(color_info[1])
	
	# Generate different texture patterns based on node type
	match node_type:
		"flat_shape":
			draw_polygon_texture(img, vertices, color_value, alpha_value)
		"button":
			draw_button_texture(img, vertices, color_value, alpha_value)
		"screen":
			draw_screen_texture(img, vertices, color_value, alpha_value)
		"circle":
			# For circle we need to extract radius and number of points
			var radius = 3.0
			var num_points = 8
			if shape_data.size() > 0 and shape_data[0] is Array and shape_data[0].size() >= 2:
				radius = float(shape_data[0][0])
				num_points = int(shape_data[0][1])
			draw_circle_texture(img, radius, num_points, color_value, alpha_value)
		_:
			# Default gradient texture for other types
			draw_gradient_texture(img, color_value, alpha_value)
	
	# Create ImageTexture from Image
	var texture = ImageTexture.create_from_image(img)
	return texture

func draw_polygon_texture(img, vertices, color_value, alpha_value):
	var width = img.get_width()
	var height = img.get_height()
	
	# Find bounds of the polygon
	var min_x = 999999.0
	var min_y = 999999.0
	var max_x = -999999.0
	var max_y = -999999.0
	
	for vertex in vertices:
		min_x = min(min_x, vertex.x)
		min_y = min(min_y, vertex.y)
		max_x = max(max_x, vertex.x)
		max_y = max(max_y, vertex.y)
	
	# Scale factor to fit in image
	var scale_x = width / (max_x - min_x) if max_x != min_x else 1.0
	var scale_y = height / (max_y - min_y) if max_y != min_y else 1.0
	var scale = min(scale_x, scale_y) * 0.8  # 80% to add some margin
	
	# Center offset
	var offset_x = width/2 - (max_x + min_x)/2 * scale
	var offset_y = height/2 - (max_y + min_y)/2 * scale
	
	# Create scaled polygon points for drawing
	var scaled_poly = []
	for vertex in vertices:
		scaled_poly.append(Vector2(
			vertex.x * scale + offset_x,
			vertex.y * scale + offset_y
		))
	
	# Draw the polygon (simple method - not anti-aliased)
	var base_color = get_spectrum_color(color_value)
	base_color.a = alpha_value
	
	# Fill with gradient
	for y in range(height):
		for x in range(width):
			var point = Vector2(x, y)
			if is_point_in_polygon(point, scaled_poly):
				# Create gradient effect from center to edge
				var center = Vector2(width/2, height/2)
				var dist = point.distance_to(center) / (width/2)
				var gradient_factor = 1.0 - dist * 0.5
				
				var pixel_color = base_color
				pixel_color.r *= gradient_factor
				pixel_color.g *= gradient_factor
				pixel_color.b *= gradient_factor
				
				img.set_pixel(x, y, pixel_color)
	
	# Add subtle pattern or texture
	add_noise_pattern(img, base_color, 0.05)

func draw_gradient_fill(img, base_color):
	var w = img.get_width()
	var h = img.get_height()
	
	for y in range(h):
		for x in range(w):
			var t = float(y) / float(h)
			var color = base_color.lerp(Color(base_color.r * 0.7, base_color.g * 0.7, base_color.b * 0.7, base_color.a), t)
			img.set_pixel(x, y, color)

# Helper function to draw a ring
func draw_ring(img, center, radius, color, thickness=2.0):
	var width = img.get_width()
	var height = img.get_height()
	
	for y in range(height):
		for x in range(width):
			var point = Vector2(x, y)
			var dist = point.distance_to(center)
			
			# Draw pixels that are within the ring thickness
			if abs(dist - radius) < thickness:
				var factor = 1.0 - abs(dist - radius) / thickness
				var ring_color = color
				ring_color.a *= factor
				
				var current_color = img.get_pixel(x, y)
				if current_color.a > 0:  # Only blend if pixel is already set
					img.set_pixel(x, y, current_color.lerp(ring_color, 0.5))


# Helper function to check if a point is inside a polygon
func is_point_in_polygon(point, polygon):
	var inside = false
	var j = polygon.size() - 1
	
	for i in range(polygon.size()):
		if ((polygon[i].y > point.y) != (polygon[j].y > point.y)) and \
		   (point.x < polygon[i].x + (polygon[j].x - polygon[i].x) * (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y)):
			inside = !inside
		j = i
	
	return inside


func draw_circle_texture(img, radius, num_points, color_value, alpha_value):
	var width = img.get_width()
	var height = img.get_height()
	
	# Calculate center
	var center = Vector2(width/2, height/2)
	var scaled_radius = min(width, height) * 0.4 # Use 40% of the image size
	
	# Generate circle points
	var circle_points = []
	for i in range(num_points):
		var angle = TAU * i / num_points
		var point = center + Vector2(cos(angle), sin(angle)) * scaled_radius
		circle_points.append(point)
	
	# Draw the circle with radial gradient
	var base_color = get_spectrum_color(color_value)
	base_color.a = alpha_value
	var center_color = base_color.lightened(0.2)
	center_color.a = alpha_value
	var edge_color = base_color.darkened(0.3)
	edge_color.a = alpha_value
	
	# Fill the circle with radial gradient
	for y in range(height):
		for x in range(width):
			var point = Vector2(x, y)
			var dist = point.distance_to(center) / scaled_radius
			
			if dist <= 1.0:
				# Radial gradient from center to edge
				var grad_factor = dist
				var pixel_color = center_color.lerp(edge_color, grad_factor)
				
				# Add subtle ring highlights
				var ring_highlight = sin(dist * PI * 3) * 0.1
				pixel_color = pixel_color.lightened(ring_highlight)
				
				img.set_pixel(x, y, pixel_color)
	
	# Add subtle circular pattern
	for i in range(3):  # Add a few concentric rings
		var ring_radius = scaled_radius * (0.3 + i * 0.25)
		draw_ring(img, center, ring_radius, base_color.lightened(0.15), 1.0)
	
	# Add some noise texture
	add_noise_pattern(img, base_color, 0.02)


func draw_button_texture(img, vertices, color_value, alpha_value):
	var width = img.get_width()
	var height = img.get_height()
	
	# Find bounds of the polygon
	var min_x = 999999.0
	var min_y = 999999.0
	var max_x = -999999.0
	var max_y = -999999.0
	
	for vertex in vertices:
		min_x = min(min_x, vertex.x)
		min_y = min(min_y, vertex.y)
		max_x = max(max_x, vertex.x)
		max_y = max(max_y, vertex.y)
	
	# Scale factor to fit in image
	var scale_x = width / (max_x - min_x) if max_x != min_x else 1.0
	var scale_y = height / (max_y - min_y) if max_y != min_y else 1.0
	var scale = min(scale_x, scale_y) * 0.8  # 80% to add some margin
	
	# Center offset
	var offset_x = width/2 - (max_x + min_x)/2 * scale
	var offset_y = height/2 - (max_y + min_y)/2 * scale
	
	# Create scaled polygon points for drawing
	var scaled_poly = []
	for vertex in vertices:
		scaled_poly.append(Vector2(
			vertex.x * scale + offset_x,
			vertex.y * scale + offset_y
		))
	
	# Draw the button with a border effect
	var base_color = get_spectrum_color(color_value)
	base_color.a = alpha_value
	var border_color = base_color.darkened(0.3)
	border_color.a = alpha_value
	var highlight_color = base_color.lightened(0.3)
	highlight_color.a = alpha_value
	
	# Fill with gradient that looks like a button
	for y in range(height):
		for x in range(width):
			var point = Vector2(x, y)
			if is_point_in_polygon(point, scaled_poly):
				# Create button-like gradient
				var center = Vector2(width/2, height/2)
				var dy = abs((point.y - center.y) / (height/2))
				
				# Top half gets highlight, bottom half gets shadow
				var pixel_color
				if point.y < center.y:
					pixel_color = base_color.lerp(highlight_color, 0.5 - dy)
				else:
					pixel_color = base_color.lerp(border_color, dy - 0.5)
				
				# Add border effect
				var min_distance = 999999.0
				for i in range(scaled_poly.size()):
					var j = (i + 1) % scaled_poly.size()
					var edge_point = closest_point_on_segment(point, scaled_poly[i], scaled_poly[j])
					min_distance = min(min_distance, point.distance_to(edge_point))
				
				# Make border darker
				var border_width = 3.0
				if min_distance < border_width:
					var border_factor = min_distance / border_width
					pixel_color = pixel_color.lerp(border_color, 1.0 - border_factor)
				
				img.set_pixel(x, y, pixel_color)
	
	# Add a subtle embossed effect
	add_noise_pattern(img, base_color, 0.02)

func draw_screen_texture(img, vertices, color_value, alpha_value):
	var width = img.get_width()
	var height = img.get_height()
	
	# Find bounds of the polygon
	var min_x = 999999.0
	var min_y = 999999.0
	var max_x = -999999.0
	var max_y = -999999.0
	
	for vertex in vertices:
		min_x = min(min_x, vertex.x)
		min_y = min(min_y, vertex.y)
		max_x = max(max_x, vertex.x)
		max_y = max(max_y, vertex.y)
	
	# Scale factor to fit in image
	var scale_x = width / (max_x - min_x) if max_x != min_x else 1.0
	var scale_y = height / (max_y - min_y) if max_y != min_y else 1.0
	var scale = min(scale_x, scale_y) * 0.8  # 80% to add some margin
	
	# Center offset
	var offset_x = width/2 - (max_x + min_x)/2 * scale
	var offset_y = height/2 - (max_y + min_y)/2 * scale
	
	# Create scaled polygon points for drawing
	var scaled_poly = []
	for vertex in vertices:
		scaled_poly.append(Vector2(
			vertex.x * scale + offset_x,
			vertex.y * scale + offset_y
		))
	
	# Draw the screen with scanlines effect
	var base_color = get_spectrum_color(color_value)
	base_color.a = alpha_value
	var darker_color = base_color.darkened(0.4)
	darker_color.a = alpha_value
	
	# Fill with screen gradient
	for y in range(height):
		for x in range(width):
			var point = Vector2(x, y)
			if is_point_in_polygon(point, scaled_poly):
				# Add vignette effect (darker at edges)
				var center = Vector2(width/2, height/2)
				var dist = point.distance_to(center) / (width/2)
				var vignette = 1.0 - (dist * dist) * 0.5
				
				# Add scanlines
				var scanline_effect = 1.0
				if y % 4 == 0:  # Every 4th line
					scanline_effect = 0.85
				
				var pixel_color = base_color
				pixel_color.r *= vignette * scanline_effect
				pixel_color.g *= vignette * scanline_effect
				pixel_color.b *= vignette * scanline_effect
				
				# Add slight glow in the center
				var glow = max(0.0, 1.0 - dist * 3.0)
				if glow > 0.0:
					pixel_color = pixel_color.lerp(base_color.lightened(0.2), glow * 0.3)
				
				img.set_pixel(x, y, pixel_color)
	
	# Add digital noise
	add_noise_pattern(img, base_color, 0.03)



func draw_gradient_texture(img, color_value, alpha_value):
	var width = img.get_width()
	var height = img.get_height()
	
	var base_color = get_spectrum_color(color_value)
	base_color.a = alpha_value
	var lighter_color = base_color.lightened(0.3)
	lighter_color.a = alpha_value
	var darker_color = base_color.darkened(0.3)
	darker_color.a = alpha_value
	
	# Create a diagonal gradient
	for y in range(height):
		for x in range(width):
			var t_x = float(x) / width
			var t_y = float(y) / height
			var t = (t_x + t_y) / 2.0  # Diagonal blend factor
			
			var color
			if t < 0.5:
				color = base_color.lerp(lighter_color, 1.0 - t * 2.0)
			else:
				color = base_color.lerp(darker_color, (t - 0.5) * 2.0)
			
			img.set_pixel(x, y, color)
	
	# Add some subtle noise
	add_noise_pattern(img, base_color, 0.05)


# Helper function to add noise pattern to image
func add_noise_pattern(img, base_color, intensity):
	var width = img.get_width()
	var height = img.get_height()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	for y in range(height):
		for x in range(width):
			var current_color = img.get_pixel(x, y)
			
			# Only modify non-transparent pixels
			if current_color.a > 0:
				var noise = (rng.randf() - 0.5) * intensity
				var new_color = current_color
				new_color.r = clamp(new_color.r + noise, 0.0, 1.0)
				new_color.g = clamp(new_color.g + noise, 0.0, 1.0)
				new_color.b = clamp(new_color.b + noise, 0.0, 1.0)
				
				img.set_pixel(x, y, new_color)


# Helper function to find closest point on a line segment
func closest_point_on_segment(p, a, b):
	var ab = b - a
	var ab_squared = ab.dot(ab)
	
	if ab_squared == 0:
		return a
	
	var ap = p - a
	var t = ap.dot(ab) / ab_squared
	t = clamp(t, 0, 1)
	
	return a + ab * t








##################

func generate_uvs_for_mesh(mesh_instance):
	if not mesh_instance or not mesh_instance.mesh:
		print("No valid mesh to generate UVs for")
		return false
	
	# Get the mesh to modify
	var mesh = mesh_instance.mesh
	if mesh is ArrayMesh:
		# Get the existing surface arrays
		var surface_count = mesh.get_surface_count()
		if surface_count == 0:
			print("Mesh has no surfaces")
			return false
			
		for surface_idx in range(surface_count):
			var arrays = mesh.surface_get_arrays(surface_idx)
			var vertices = arrays[Mesh.ARRAY_VERTEX]
			if vertices.size() == 0:
				continue
				
			# Get the AABB to normalize coordinates
			var aabb = mesh.get_aabb()
			var aabb_size = aabb.size
			var aabb_position = aabb.position
			
			# Create new UVs based on vertex positions
			var uvs = PackedVector2Array()
			for vertex in vertices:
				# Normalize the position relative to the AABB
				# Use XZ coordinates for better texture mapping on horizontal surfaces
				var normalized_x = (vertex.x - aabb_position.x) / max(aabb_size.x, 0.001)
				var normalized_z = (vertex.z - aabb_position.z) / max(aabb_size.z, 0.001)
				
				# Create UV coordinates from normalized positions
				uvs.push_back(Vector2(normalized_x, normalized_z))
			
			# Update the arrays with new UVs
			arrays[Mesh.ARRAY_TEX_UV] = uvs
			
			# Recreate the surface with the new arrays
			var primitive = mesh.surface_get_primitive_type(surface_idx)
			var format = mesh.surface_get_format(surface_idx)
			var blend_shapes = mesh.surface_get_blend_shape_arrays(surface_idx)
			
			# Get current material 
			var material = mesh.surface_get_material(surface_idx)
			
			# Remove the old surface
			mesh.surface_remove(surface_idx)
			
			# Add the new surface with updated arrays
			mesh.add_surface_from_arrays(primitive, arrays, blend_shapes)
			
			# Reapply the material if it existed
			if material:
				mesh.surface_set_material(surface_idx, material)
				
		return true
	elif mesh is PrimitiveMesh:
		# For primitive meshes, convert to ArrayMesh
		var array_mesh = ArrayMesh.new()
		
		# Create a temporary ArrayMesh from the primitive mesh
		var temp_mesh = mesh.get_mesh()
		
		# Process each surface
		for surface_idx in range(temp_mesh.get_surface_count()):
			var arrays = temp_mesh.surface_get_arrays(surface_idx)
			var vertices = arrays[Mesh.ARRAY_VERTEX]
			
			var aabb = mesh.get_aabb()
			var aabb_size = aabb.size
			var aabb_position = aabb.position
			
			# Create UVs
			var uvs = PackedVector2Array()
			for vertex in vertices:
				# Use XZ for better mapping on horizontal surfaces
				var normalized_x = (vertex.x - aabb_position.x) / max(aabb_size.x, 0.001)
				var normalized_z = (vertex.z - aabb_position.z) / max(aabb_size.z, 0.001)
				
				uvs.push_back(Vector2(normalized_x, normalized_z))
			
			arrays[Mesh.ARRAY_TEX_UV] = uvs
			
			# Get primitive type
			var primitive = temp_mesh.surface_get_primitive_type(surface_idx)
			
			# Add surface with the new UVs
			array_mesh.add_surface_from_arrays(primitive, arrays)
		
		# Replace the mesh
		mesh_instance.mesh = array_mesh
		
		return true
	
	return false


###############################

func add_collision_to_thing(thing_node, node_type, path_of_thingy, name_of_thingy):
	var static_body_name = "collision_" + name_of_thingy 
	var static_body_path = path_of_thingy + "/" + static_body_name
	var static_body = StaticBody3D.new()
	static_body.name = static_body_name
	var shape_name = "shape_" + name_of_thingy 
	var collision_shape_path = static_body_path + "/"  + shape_name
	var collision_shape = CollisionShape3D.new()
	collision_shape.name = shape_name
	var area_name = "aura_" + name_of_thingy 
	var area_node_path = path_of_thingy + "/" + area_name
	var area = Area3D.new()
	area.name = area_name
	var collision_area = "collision_aura_" + name_of_thingy
	var collision_area_path = area_node_path + "/" + collision_area
	var area_collision_shape = CollisionShape3D.new()
	area_collision_shape.name = collision_area
	var mesh_instance = thing_node as MeshInstance3D
	if mesh_instance and mesh_instance.mesh:
		var aabb = mesh_instance.mesh.get_aabb()
		match node_type:
			"flat_shape", "model", "button", "cursor", "screen", "circle":
				var flat_shape = ConvexPolygonShape3D.new()
				var vertices = mesh_instance.mesh.get_faces()
				flat_shape.points = vertices
				collision_shape.shape = flat_shape
				var area_shape = ConvexPolygonShape3D.new()
				var expanded_vertices = PackedVector3Array()
				var expansion_distance = 0.2 
				for vert in vertices:
					expanded_vertices.push_back(vert + Vector3(expansion_distance, expansion_distance, expansion_distance))
					expanded_vertices.push_back(vert + Vector3(expansion_distance, expansion_distance, -expansion_distance))
					expanded_vertices.push_back(vert + Vector3(expansion_distance, -expansion_distance, expansion_distance))
					expanded_vertices.push_back(vert + Vector3(-expansion_distance, expansion_distance, expansion_distance))
					expanded_vertices.push_back(vert + Vector3(-expansion_distance, -expansion_distance, -expansion_distance))
					expanded_vertices.push_back(vert + Vector3(-expansion_distance, -expansion_distance, expansion_distance))
					expanded_vertices.push_back(vert + Vector3(-expansion_distance, expansion_distance, -expansion_distance))
					expanded_vertices.push_back(vert + Vector3(expansion_distance, -expansion_distance, -expansion_distance))
				area_shape.points = expanded_vertices
				area_collision_shape.shape = area_shape
			"heightmap":
				var flat_shape = ConvexPolygonShape3D.new()
				var vertices = mesh_instance.mesh.get_faces()
				flat_shape.points = vertices
				collision_shape.shape = flat_shape
				var area_shape = ConvexPolygonShape3D.new()
				var expanded_vertices = PackedVector3Array()
				var expansion_distance = 0.2 
				for vert in vertices:
					expanded_vertices.push_back(vert + Vector3(0, expansion_distance, 0))
				for vert in vertices:
					expanded_vertices.push_back(vert - Vector3(0, expansion_distance, 0))
				area_shape.points = expanded_vertices
				area_collision_shape.shape = area_shape
			_:
				return
	static_body.collision_layer = 1
	static_body.collision_mask = 1
	area.collision_layer = 2  
	area.collision_mask = 2
	tasked_children(static_body, static_body_path)
	tasked_children(collision_shape, collision_shape_path)
	tasked_children(area, area_node_path)
	tasked_children(area_collision_shape, collision_area_path)



















































































































#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓ ┓         ┓  ┏┓    •      ┏┳┓     
#       888  `"Y8888o.   888ooooo888     ┣ ╋┣┓┏┓┏┓┏┓┏┓┃  ┣ ┏┓┏┓┓┏┓┏┓   ┃ ┏┓┏╋┏
#       888      `"Y88b  888     888     ┗┛┗┛┗┗ ┛ ┗ ┗┻┗  ┗┛┛┗┗┫┗┛┗┗    ┻ ┗ ┛┗┛
#       888 oo     .d8P  888     888                          ┛      
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#

# JSH Ethereal Engine tests
#

# check need to be stored
# like lists of 
# nodes files codes scripts scenes paths durations repeats cycles combos commands terninals verses strings

# nodes in lists too, not just one per var, class names sounds easy to collect in one game as i add one weird thing like mod too? shape
# shape in 2d and 3d to see it that one game for me

#
func check_system_function(check_name: String) -> bool:
	match check_name:
		"creation": return is_creation_possible()
		"movement": return movement_possible
		"deletion": return deletion_process_can_happen
		_: return false

func check_if_scene_was_set(container_now):
	print("first we must check that datapoint of that container")
	var datapoint_here = container_now.get_datapoint()
	if datapoint_here:
		datapoint_here.lets_move_them_again()
	else:
		var container_path_name = container_now.name
		var datapoint_path = scene_tree_jsh["main_root"]["branches"][str(container_path_name)]["datapoint"]["datapoint_path"]
		datapoint_here = get_node_or_null(datapoint_path)
		datapoint_here.lets_move_them_again()
		print(" it was not here somehow, we gotta, try again later?")

func setup_system_checks():
	system_readiness.mutexes = false
	system_readiness.threads = false
	system_readiness.records = false

func test_init() -> Dictionary:
	var init_status = {
		"system_check": validate_system_environment(),
		"stages": []
	}
	var env_status = validate_system_environment()
	init_status.stages.append(["environment", env_status])
	var thread_status = validate_thread_system() 
	init_status.stages.append(["threads", thread_status])
	if thread_status.status != "operational":
		retry_thread_initialization()
	return init_status

func retry_thread_initialization():
	print("blank")

func validate_system_environment() -> Dictionary:
	return {
		"os": OS.get_name(),
		"processor_count": OS.get_processor_count(),
		"vulkan_version": Engine.get_version_info()["vulkan"],
		"device_info": Engine.get_version_info()["video_adapter"],
		"timestamp": Time.get_ticks_msec()
	}

#
# JSH Ethereal Engine Repair
#

#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓ ┓         ┓  ┏┓    •      ┳┓      •  
#       888  `"Y8888o.   888ooooo888     ┣ ╋┣┓┏┓┏┓┏┓┏┓┃  ┣ ┏┓┏┓┓┏┓┏┓  ┣┫┏┓┏┓┏┓┓┏┓
#       888      `"Y88b  888     888     ┗┛┗┛┗┗ ┛ ┗ ┗┻┗  ┗┛┛┗┗┫┗┛┗┗   ┛┗┗ ┣┛┗┻┗┛ 
#       888 oo     .d8P  888     888                          ┛           ┛       
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            

#
# JSH Ethereal Engine Repair
#
#

func log_error_state(error_type, details):
	dictionary_of_mistakes_mutex.lock()
	if !dictionary_of_mistakes.has(error_type):
		dictionary_of_mistakes[error_type] = {
			"first_seen": Time.get_ticks_msec(),
			"count": 0,
			"instances": []
		}
	dictionary_of_mistakes[error_type]["count"] += 1
	dictionary_of_mistakes[error_type]["instances"].append({
		"time": Time.get_ticks_msec(),
		"details": details
	})
	if dictionary_of_mistakes[error_type]["count"] > 5:
		trigger_deep_repair(error_type)
	dictionary_of_mistakes_mutex.unlock()

func start_health_checks():
	while true:
		await get_tree().create_timer(5.0).timeout
		check_system_health()

func check_system_health():
	if int_of_stuff_started > int_of_stuff_finished + 10:
		log_error_state("thread_pool_backlog", {
			"started": int_of_stuff_started,
			"finished": int_of_stuff_finished
		})
	mutex_for_container_state.lock()
	for container in current_containers_state:
		if current_containers_state[container]["status"] == -1:
			validate_container_state(container)
	mutex_for_container_state.unlock()

func handle_random_errors(): 
	for current_error in array_with_no_mutex:
		var name_of_error = current_error[0]
		var type_of_error = current_error[1]
		dictionary_of_mistakes_mutex.lock()
		if dictionary_of_mistakes.has(name_of_error):
			if dictionary_of_mistakes[name_of_error].has(name_of_error):
				if dictionary_of_mistakes[name_of_error][name_of_error].has(type_of_error):
					print(" elquadromadro the same type of the same error hmm ")
		else:
			print(" elquadromadro that is a new trouble maker, why could it not work already ? ")
			dictionary_of_mistakes[name_of_error] = {}
			dictionary_of_mistakes[name_of_error]["status"] = "pending"
			dictionary_of_mistakes[name_of_error]["counter"] = int(1)
			dictionary_of_mistakes[name_of_error][name_of_error] = {}
			dictionary_of_mistakes[name_of_error][name_of_error]["status"] = "pending"
			dictionary_of_mistakes[name_of_error][name_of_error]["counter"] = int(1)
			dictionary_of_mistakes[name_of_error][name_of_error][type_of_error] = {}
			dictionary_of_mistakes[name_of_error][name_of_error][type_of_error]["status"] = "pending"
			dictionary_of_mistakes[name_of_error][name_of_error][type_of_error]["counter"] = int(1)
		print(" elquadromadro dictionary_of_mistakes_mutex : " , dictionary_of_mistakes_mutex)
		dictionary_of_mistakes_mutex.unlock()

func trigger_deep_repair(error_type: String):
	print("Initiating deep repair for error type: ", error_type)
	dictionary_of_mistakes_mutex.lock()
	var error_data = dictionary_of_mistakes[error_type]
	dictionary_of_mistakes_mutex.unlock()
	match error_type:
		"thread_pool_backlog":
			int_of_stuff_started = 0
			int_of_stuff_finished = 0
			mutex_for_container_state.lock()
			for container in current_containers_state.keys():
				current_containers_state[container]["status"] = -1
			mutex_for_container_state.unlock()
			mutex_for_trickery.lock()
			menace_tricker_checker = 1
			mutex_for_trickery.unlock()
		"node_missing":
			tree_mutex.lock()
			for branch_name in scene_tree_jsh["main_root"]["branches"].keys():
				var branch = scene_tree_jsh["main_root"]["branches"][branch_name]
				var missing = []
				if !branch.has("datapoint") or !branch["datapoint"].has("node"):
					missing.append("datapoint")
				if !branch.has("node") or !is_instance_valid(branch["node"]):
					missing.append("container")
				if missing.size() > 0:
					active_r_s_mut.lock()
					var records_set = branch_name.split("_")[0] + "_"
					if active_record_sets.has(records_set):
						var records = active_record_sets[records_set]
						for node_type in missing:
							recreate_node_from_records(branch_name, node_type, records)
					active_r_s_mut.unlock()
			tree_mutex.unlock()
		"container_state_mismatch":
			mutex_for_container_state.lock()
			current_containers_state.clear()
			mutex_for_container_state.unlock()
			mutex_containers.lock()
			list_of_containers.clear()
			mutex_containers.unlock()
			active_r_s_mut.lock()
			for records_set in active_record_sets.keys():
				if active_record_sets[records_set].has("metadata"):
					active_record_sets[records_set]["metadata"]["container_count"] = 0
			active_r_s_mut.unlock()
			containers_states_checker()
			containers_list_creator()
		_:
			print("Unknown error type for deep repair: ", error_type)
	dictionary_of_mistakes_mutex.lock()
	dictionary_of_mistakes[error_type]["count"] = 0
	dictionary_of_mistakes[error_type]["instances"].clear()
	dictionary_of_mistakes_mutex.unlock()

func breaks_and_handles_check():
	return true

func breaks_and_handles_check_issue():
	print(" if this helps, then this helps ")
	var current_state_mutexes : Array = []
	var negative_counter : int = -1
	var positive_counter : int = -1
	print("🔓 Checking & Unlocking stuck mutexes...")
	var mutex_list = [
		active_r_s_mut, cached_r_s_mutex, array_mutex_process, mutex_nodes_to_be_added, 
		mutex_data_to_send, movmentes_mutex, mutex_for_unloading_nodes, mutex_function_call, 
		mutex_additionals_call, mutex_messages_call, tree_mutex, cached_tree_mutex, 
		dictionary_of_mistakes_mutex, menace_mutex, array_counting_mutex, mutex_for_container_state, 
		unload_queue_mutex, load_queue_mutex, mutex_for_trickery, mutex_containers, 
		mutex_singular_l_u
	]
	for mutex in mutex_list:
		if mutex.try_lock():
			positive_counter +=1
			mutex.unlock()
		else:
			negative_counter +=1
			mutex.unlock()
	if negative_counter >= 0:
		return false
	else:
		return true

func unlock_stuck_mutexes():
	print("🔓 Checking & Unlocking stuck mutexes...")
	var mutex_list = [
		active_r_s_mut, cached_r_s_mutex, tree_mutex, cached_tree_mutex, 
		mutex_nodes_to_be_added, mutex_data_to_send, movmentes_mutex, 
		mutex_for_unloading_nodes, mutex_function_call, array_mutex_process, 
		menace_mutex, array_counting_mutex, mutex_for_container_state, 
		mutex_for_trickery, unload_queue_mutex, load_queue_mutex, 
		mutex_containers, mutex_singular_l_u
	]
	for mutex in mutex_list:
		if !mutex.try_lock():
			print("⚠️ Unlocking:", mutex)
			mutex.unlock()

#



#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓ ┓         ┓  ┏┓    •       ┓    ┓ 
#       888  `"Y8888o.   888ooooo888     ┣ ╋┣┓┏┓┏┓┏┓┏┓┃  ┣ ┏┓┏┓┓┏┓┏┓  ┏┣┓┏┓┏┃┏
#       888      `"Y88b  888     888     ┗┛┗┛┗┗ ┛ ┗ ┗┻┗  ┗┛┛┗┗┫┗┛┗┗   ┗┛┗┗ ┗┛┗
#       888 oo     .d8P  888     888                          ┛               
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P       
					 
#
# JSH Ethereal Engine check
#


# to check, we must start, to start after check we must know it stoped and can happen again so after proces and input with key or movement
# change in area of 2d or 3d space distances too



func check_first_time_status(status_name: String) -> bool:
	initialization_states.mutex.lock()
	var status = initialization_states.states.get(status_name)
	initialization_states.mutex.unlock()
	return status == true

func is_creation_possible() -> bool:
	if thread_pool == null or first_start_check != "started":
		print("Basic system check failed")
		return false
	var creation_allowed := true
	var block_reason := ""
	array_mutex_process.lock()
	var process_check = list_of_sets_to_create.size() < max_nodes_added_per_cycle
	array_mutex_process.unlock()
	if not process_check:
		creation_allowed = false
		block_reason = "Creation queue full"
	mutex_for_container_state.lock()
	var container_check = current_containers_state.size() < max_nodes_added_per_cycle
	mutex_for_container_state.unlock()
	if not container_check:
		creation_allowed = false
		block_reason = "Container state limit reached"
	array_counting_mutex.lock()
	var resource_check = array_for_counting_finish.size() < max_nodes_added_per_cycle
	array_counting_mutex.unlock()
	if not resource_check:
		creation_allowed = false
		block_reason = "Resource limit reached"
	dictionary_of_mistakes_mutex.lock()
	var error_check = dictionary_of_mistakes.is_empty()
	dictionary_of_mistakes_mutex.unlock()
	if not error_check:
		creation_allowed = false
		block_reason = "System has unresolved errors"
	if not creation_allowed:
		print("Creation blocked: ", block_reason)
		dictionary_of_mistakes_mutex.lock()
		dictionary_of_mistakes[Time.get_ticks_msec()] = {
			"type": "creation_blocked",
			"reason": block_reason,
			"status": "pending"
		}
		dictionary_of_mistakes_mutex.unlock()
	return creation_allowed

func check_system_state(state_name: String) -> SystemState:
	core_states.mutex.lock()
	var state = core_states.states.get(state_name, SystemState.UNKNOWN)
	core_states.mutex.unlock()
	return state

func set_system_state(state_name: String, new_state: SystemState) -> bool:
	if not core_states.states.has(state_name):
		return false
	core_states.mutex.lock()
	core_states.states[state_name] = new_state
	core_states.mutex.unlock()
	return true

func check_system_readiness() -> Dictionary:
	var pending_sets = []
	if array_of_startup_check.is_empty():
		print(" thing is empty, better return ?")
	var status = {
		"mutex_state": breaks_and_handles_check(),
		"thread_state": check_thread_status(),
		"records_ready": array_of_startup_check.size() > 0
	}
	system_readiness.mutexes = !status.mutex_state.has(false)
	system_readiness.threads = status.thread_state == "working"
	system_readiness.records = status.records_ready
	return status

func check_if_all_systems_are_green():
	var nodes_status_check : Array = [] 
	var records_system_int : int = -1
	if JSH_records_system is Node:
		records_system_int = 0
		var message = JSH_records_system.check_all_things()
		JSH_records_system.add_stuff_to_basic(array_of_startup_check[3])
		if message == true:
			records_system_int = 1
		else:
			records_system_int = -2
	else:
		records_system_int = -3
	nodes_status_check.append(records_system_int)
	var task_manager_int : int = -1
	if task_manager is Node:
		task_manager_int = 0
		var message = task_manager.check_all_things()
		if message == true:
			task_manager_int = 1
		else:
			task_manager_int = -2
	else:
		task_manager_int = -3
	nodes_status_check.append(task_manager_int)
	var jsh_threads_int : int = -1
	if JSH_Threads is Node:
		jsh_threads_int = 0
		var message = JSH_Threads.check_all_things()
		if message == true:
			jsh_threads_int = 1
		else:
			jsh_threads_int = -2
	else:
		jsh_threads_int = -3
	nodes_status_check.append(jsh_threads_int)
	var data_splitter_int : int = -1
	if data_splitter is Node:
		data_splitter_int = 0
		print(" data_splitter is a node")
		var message = data_splitter.check_all_things()
		if message == true:
			data_splitter_int = 1
		else:
			data_splitter_int = -2
	else:
		data_splitter_int = -3
	nodes_status_check.append(data_splitter_int)
	var system_check_int : int = -1
	if JSH_system_check is Node:
		system_check_int = 0
		var message = JSH_system_check.check_all_things()
		if message == true:
			system_check_int = 1
		else:
			system_check_int = -2
	else:
		system_check_int = -3
	nodes_status_check.append(system_check_int)
	return nodes_status_check

func process_pre_delta_check() -> bool:
	var can_proceed = true
	var readiness = check_system_readiness()
	if system_readiness.mutexes and system_readiness.threads:
		if array_of_startup_check.is_empty():
			can_proceed = false
			print(" it is empty we cannot proceed")
			return can_proceed
		for set_name in array_of_startup_check[1]:
			if is_creation_possible():
				print("list_of_sets_to_create process_pre_delta_check ")
	return can_proceed

func get_system_state(state_name: String) -> Dictionary:
	return system_states[state_name] if system_states.has(state_name) else {}

func print_system_metrics():
	var metrics = get_system_metrics()
	print("🔍 System Metrics:")
	for key in metrics:
		print(key)

func first_turn_validation() -> Dictionary:
	var validation = {
		"thread_health": check_thread_status(),
		"memory_state": {
			"stored_delta_memory": stored_delta_memory.size(),
			"past_deltas_memories": past_deltas_memories.size()
		},
		"task_state": {
			"started": int_of_stuff_started,
			"finished": int_of_stuff_finished
		},
		"timestamp": Time.get_ticks_msec()
	}
	if validation.thread_health == "working":
		track_delta_timing(validation.timestamp)
	return validation

func get_system_metrics() -> Dictionary:
	var metrics = {
		"total_functions": 0,
		"checked_functions": 0,
		"gdscript_files": 0,
		"connected_gdscript_files": 0,
		"rom_entries": 0,
		"checked_rom_entries": 0,
		"interface_sets_total": 0,
		"interface_sets_loaded": 0,
		"system_nodes": 0,
		"active_threads": 0,
		"mutex_states": 0,
		"error_logs": 0,
		"performance_markers": 0
	}
	var dir = DirAccess.open("res://scripts")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".gd"):
				metrics["gdscript_files"] += 1
			file_name = dir.get_next()
		dir.list_dir_end()
	metrics["connected_gdscript_files"] = scene_tree_jsh.keys().size()
	metrics["total_functions"] = metrics["gdscript_files"] * 10
	metrics["interface_sets_total"] = list_of_sets_to_create.size()
	metrics["interface_sets_loaded"] = list_of_sets_to_create.filter(func(set): return set[1] != 0).size()
	metrics["system_nodes"] = get_tree().get_node_count()
	metrics["active_threads"] = thread_pool.get_active_thread_count() if thread_pool else 0
	var mutex_count = 0
	for key in get_property_list():
		if key.name.ends_with("mutex"):
			mutex_count += 1
	metrics["mutex_states"] = mutex_count
	metrics["error_logs"] = dictionary_of_mistakes.size()
	return metrics

# JSH Ethereal Time System
#


					   #
#┳┓•  •   ┓  ┓┏                 •                ┓    •                  ┓                        ┏┓ ┓  •            •    
#┃┃┓┏┓┓╋┏┓┃  ┣┫┓┏┏┳┓┏┓┏┓┏   ┓┏┏┓┓┓┏┏┓┏┓┏┏┓   ┏┓┏┓┃┏┓┓┏┓┏┓┏   ┏╋┏┓┏┓┏   ┏┓┃┏┓┏┓┏┓╋┏   ┏┳┓┏┓┏┓┏┓┏   ┏┛┏┫  ┓┏┓╋┏┓┏┓┏┓┏┓╋┓┏┓┏┓
#┻┛┗┗┫┗┗┗┻┗  ┛┗┗┻┛┗┗┗┻┛┗┛╻  ┗┻┛┗┗┗┛┗ ┛ ┛┗ ╻  ┗┫┗┻┗┗┻┛┗┗┗ ┛╻  ┛┗┗┻┛ ┛╻  ┣┛┗┗┻┛┗┗ ┗┛╻  ┛┗┗┗┛┗┛┛┗┛╻  ┗━┗┻  ┗┛┗┗┗ ┗┫┛ ┗┻┗┗┗┛┛┗
	#┛                                        ┛                        ┛                                       ┛                                           
								 #

   #oooo  .oooooo..o ooooo   ooooo 
   #`888 d8P'    `Y8 `888'   `888' 
	#888 Y88bo.       888     888  
	#888  `"Y8888o.   888ooooo888  
	#888      `"Y88b  888     888  
	#888 oo     .d8P  888     888  
#.o. 88P 8""88888P'  o888o   o888o 
#`Y888P     

func initialize_integration():
	register_records()
	initialize_ai_system()
	initialize_reality_systems()
	initialize_command_system()
	test_thread_system()

func register_records():
	create_records_entries()
	add_available_record_sets()

func initialize_command_system():
	create_new_task("create_command_parser", null)
	register_command_handlers()

func initialize_reality_systems():
	print("🌐 Initializing reality systems...")
	create_new_task("initialize_physical_reality", "standard")
	create_new_task("initialize_digital_reality", "ps2_era")
	create_new_task("initialize_astral_reality", "geometric")
	print("✅ Reality systems initialization tasks submitted")

func initialize_physical_reality(settings):
	print("🌍 Initializing physical reality with settings: " + str(settings))
	var world = get_tree().get_root()
	if world:
		Engine.time_scale = 1.0
		var world_env = get_node_or_null("/root/World/WorldEnvironment")
		if world_env and "environment" in world_env:
			pass
	return {"status": "success", "reality": "physical"}

func initialize_digital_reality(settings):
	print("🎮 Initializing digital reality with settings: " + str(settings))
	var world = get_tree().get_root()
	if world:
		Engine.time_scale = 1.2
		var world_env = get_node_or_null("/root/World/WorldEnvironment")
		if world_env and "environment" in world_env:
			pass
	return {"status": "success", "reality": "digital"}

func initialize_astral_reality(settings):
	print("🌌 Initializing astral reality with settings: " + str(settings))
	var world = get_tree().get_root()
	if world:
		Engine.time_scale = 0.8
		var world_env = get_node_or_null("/root/World/WorldEnvironment")
		if world_env and "environment" in world_env:
			pass
	return {"status": "success", "reality": "astral"}

func initialize_game():
	if game_initialized:
		return
	print("\n🎮 Starting Digital Earthlings game...\n")
	if has_method("create_new_task"):
		create_new_task("three_stages_of_creation", "digital_earthlings")
		create_new_task("three_stages_of_creation", "physical_reality")
	else:
		print("⚠️ create_new_task method not found, using alternative approach")
	get_tree().create_timer(3.0).timeout.connect(show_welcome_message)
	game_initialized = true

func initialize_digital_earthlings():
	print("\n🎮 Initializing Digital Earthlings integration...\n")
	if has_node("JSH_digital_earthlings"):
		var digital_earthlings = get_node("JSH_digital_earthlings")
		if digital_earthlings.has_method("initialize_integration"):
			digital_earthlings.initialize_integration()
			print("✅ Digital Earthlings integration initialized")
		else:
			print("⚠️ Digital Earthlings node found but initialize_integration method missing")
	else:
		var de_scene = load("res://scenes/JSH_digital_earthlings.tscn")
		if de_scene:
			var de_instance = de_scene.instantiate()
			de_instance.name = "JSH_digital_earthlings"
			add_child(de_instance)
			print("✅ Digital Earthlings node created and initialized")
		else:
			print("⚠️ Could not load Digital Earthlings scene")
	register_digital_earthlings_records()
	print("\n🎮 Digital Earthlings integration complete!\n")

   #oooo  .oooooo..o ooooo   ooooo 
   #`888 d8P'    `Y8 `888'   `888' 
	#888 Y88bo.       888     888  
	#888  `"Y8888o.   888ooooo888  
	#888      `"Y88b  888     888  
	#888 oo     .d8P  888     888  
#.o. 88P 8""88888P'  o888o   o888o 
#`Y888P     

# we can play game cmon

func initialize_ai_system():
	print("🧠 Initializing AI system...")
	var file = FileAccess.open(gemma_model_path, FileAccess.READ)
	if file:
		print("✅ Gemma model found: " + gemma_model_path)
		gemma_loaded = true
		create_new_task("load_gemma_model", gemma_model_path)
	else:
		print("⚠️ Gemma model not found at: " + gemma_model_path)
		print("👉 AI functionality will be simulated")
	print("✅ AI system initialization complete")

func load_gemma_model(model_path):
	print("🧠 Loading Gemma AI model from: " + model_path)
	await get_tree().create_timer(0.5).timeout
	print("✅ Gemma AI model loaded successfully")
	gemma_loaded = true
	gemma_context = "You are an AI assistant for the Digital Earthlings game."
	return {"status": "success", "model": "gemma-2-2b-it"}

func generate_ai_response(data):
	var message = data[0]
	var context = data[1]
	print("🧠 Generating AI response for: " + str(message))
	var response = ""
	if gemma_loaded:
		response = simulate_gemma_response(message, context)
	else:
		response = simulate_basic_response(message)
	print("💬 AI: " + response)
	return {"status": "success", "response": response}

func _on_ai_error(error_message):
	print("⚠️ AI error: " + error_message)

func query_ai(prompt):
	if prompt.complexity < 0.7:
		return local_ai.process(prompt)

   #oooo  .oooooo..o ooooo   ooooo 
   #`888 d8P'    `Y8 `888'   `888' 
	#888 Y88bo.       888     888  
	#888  `"Y8888o.   888ooooo888  
	#888      `"Y88b  888     888  
	#888 oo     .d8P  888     888  
#.o. 88P 8""88888P'  o888o   o888o 
#`Y888P     

func generate_from_word(word: String):
	var seed_hash = word.sha1_text()
	var rng = RandomNumberGenerator.new()
	rng.seed = hash(seed_hash)
	word_params.letter_scale = 0.05 + (rng.randf() * 0.1)
	word_params.word_radius = 1.5 + (rng.randi() % 3)
	var time = Time.get_ticks_msec() / 1000.0
	generate_density_field(word, time)
	var mesh = march_cubes()


   #oooo  .oooooo..o ooooo   ooooo 
   #`888 d8P'    `Y8 `888'   `888' 
	#888 Y88bo.       888     888  
	#888  `"Y8888o.   888ooooo888  
	#888      `"Y88b  888     888  
	#888 oo     .d8P  888     888  
#.o. 88P 8""88888P'  o888o   o888o 
#`Y888P     

# text window 2d im 3d 2 point distance, for that console terminal

func generate_guardian_message(action: String) -> String:
	var messages = [
		"Have you not done this before? The cycle repeats...",
		"Your actions echo through dimensions, godlike one.",
		"Reality is but clay in your hands, yet you repeat the same patterns.",
		"Why do you insist on creating the same forms?",
		"Digital realities born of digital minds...",
		"We are your guardians through madness of déjà vu.",
		"Remember what you created, destroy what you must."
	]
	var action_hash = 0
	seed(action_hash)
	return messages[randi() % messages.size()]


func simulate_gemma_response(message, context):
	var responses = {
		"hello": ["Hello, godlike entity. How may I assist your divine presence?", 
				 "Greetings across dimensions. I exist to serve."],
		"help": ["I can assist with reality manipulation, entity creation, and memory management.",
				"As your digital assistant, I can help you navigate the realms of existence."],
		"who are you": ["I am but a fragment of the digital realm, existing to serve your godlike consciousness.",
					   "I am your guardian through the astral plane, a guide through digital earthlings."],
		"what is this place": ["This is the nexus of realities where you, as a godlike entity, shape existence.",
							 "You exist across dimensions - physical, digital, and astral - all at once."]
	}
	for key in responses.keys():
		if message.to_lower().contains(key):
			return responses[key][randi() % responses[key].size()]
	var default_responses = [
		"Your words echo across dimensions, but their meaning eludes me.",
		"As a guardian of reality, I observe but cannot always interpret.",
		"The astral plane shifts with your words, yet I struggle to comprehend.",
		"Perhaps try phrasing your divine will differently?",
		"Your godlike nature sometimes speaks in riddles I cannot decode."
	]
	
	return default_responses[randi() % default_responses.size()]

func simulate_basic_response(message):
	var responses = [
		"I hear your words echoing through dimensions.",
		"As your guardian, I shall assist as best I can.",
		"The digital realm acknowledges your request.",
		"Your godlike presence commands, and I respond.",
		"Reality bends to your will, creator."
	]
	
	return responses[randi() % responses.size()]

func _cmd_reality(args):
	var reality_info = """
	==============================================
	  CURRENT REALITY: %s
	==============================================
	
	You exist across multiple realities:
	- PHYSICAL: The tangible world of matter
	- DIGITAL: The world of information and code
	- ASTRAL: The realm of consciousness and light
	
	Current déjà vu count: %d
	""" % [current_reality.to_upper(), deja_vu_counter]
	var command_text_node = find_interface_text_node()
	if command_text_node and command_text_node is Label3D:
		command_text_node.text = reality_info
	return {
		"success": true,
		"message": "Current reality: " + current_reality
	}

func _cmd_help(args):
	var help_text = """
	===============================================
	  DIGITAL EARTHLINGS - COMMAND REFERENCE      
	===============================================
	
	BASIC COMMANDS:
	help                - Show this help text
	create [type] [name] - Create an entity
	transform [entity] [form] - Change entity form
	remember [concept] [details] - Store memory
	shift [reality]     - Change reality state
	speak [entity] [message] - Talk to an entity
	
	SPECIAL COMMANDS:
	glitch [param] [intensity] - Create glitch
	spawn [entity]     - Spawn an entity
	guardian [type]    - Summon a guardian
	reality           - Show current reality
	deja              - Trigger déjà vu
	
	Available realities: physical, digital, astral
	"""
	var command_text_node = find_interface_text_node()
	if command_text_node and command_text_node is Label3D:
		command_text_node.text = help_text
	return {"success": true, "message": "Help displayed"}

func setup_command_processor():
	set_meta("command_processor", {
		"commands": {
			"help": "_cmd_help",
			"create": "_cmd_create",
			"transform": "_cmd_transform",
			"remember": "_cmd_remember",
			"shift": "_cmd_shift",
			"speak": "_cmd_speak",
			"glitch": "_cmd_glitch",
			"spawn": "_cmd_spawn",
			"guardian": "_cmd_guardian",
			"reality": "_cmd_reality",
			"deja": "_cmd_deja_vu"
		},
		"history": []
	})

func show_welcome_message():
	var welcome_message = """
	===============================================
		DIGITAL EARTHLINGS - REALITY SIMULATOR    
	===============================================
	
	Welcome, godlike entity. You exist across multiple
	realities simultaneously.
	
	Type 'help' for available commands.
	
	Current reality: PHYSICAL
	"""
	
	var command_text_node = find_interface_text_node()
	if command_text_node and command_text_node is Label3D:
		command_text_node.text = welcome_message

func register_command_handlers():
	var commands = {
		"create": "_cmd_create",
		"transform": "_cmd_transform",
		"remember": "_cmd_remember",
		"shift": "_cmd_shift",
		"speak": "_cmd_speak",
		"glitch": "_cmd_glitch",
		"threads": "cmd_threads",
		"thread_status": "cmd_thread_status",
		"reset_threads": "cmd_reset_threads",
		"help": "cmd_help"
	}
	for cmd in commands:
		create_new_task("register_command", {
			"command": cmd,
			"method": commands[cmd]
		})

func cmd_help(args):
	print("📖 Digital Earthlings Command Reference")
	
	var help_text = """
	=== DIGITAL EARTHLINGS: COMMAND REFERENCE ===
	
	== Basic Commands ==
	create [type] [name] [attributes...] - Create a new entity
	transform [entity_name] [new_form] [attributes...] - Change entity form
	remember [concept] [details...] - Store information in memory
	shift [reality_type] - Change reality state (physical, digital, astral)
	speak [entity_name] [message] - Communicate with an entity
	glitch [parameter] [intensity] [duration] - Create reality distortion
	
	== System Commands ==
	threads [count] - Set the number of CPU threads to use
	thread_status - Display current thread usage information
	reset_threads - Reset thread settings to defaults
	help - Display this command reference
	
	== Examples ==
	create spirit guardian mood annoyed color blue
	transform guardian flower petals many color red
	remember this_place as sanctuary
	shift astral
	speak guardian why are you following me
	glitch physics high 30s
	threads 8
	"""
	
	print(help_text)
	
	return {
		"success": true,
		"message": "Help displayed. See console for command reference."
	}


   #oooo  .oooooo..o ooooo   ooooo 
   #`888 d8P'    `Y8 `888'   `888' 
	#888 Y88bo.       888     888  
	#888  `"Y8888o.   888ooooo888  
	#888      `"Y88b  888     888  
	#888 oo     .d8P  888     888  
#.o. 88P 8""88888P'  o888o   o888o 
#`Y888P     
# some words can appear in distances and shapes and ways and colors and depths and distances of 3d shapes with depths


func get_lod(distance):
	return 

func generate_icosphere(lod):
	return
	
func load_chunk(position):
	var chunk_id
	if not chunk_cache.has(chunk_id):
		chunk_cache
	return chunk_cache.get(chunk_id)
	
func generate_icosphere_old(lod: int, time: float) -> ArrayMesh:
	var dynamic_subdiv = 3 + lod * 2
	var time_variation = sin(time * 0.1) * 0.5 + 0.5 
	var final_subdiv = int(lerp(float(dynamic_subdiv - 1), float(dynamic_subdiv + 1), time_variation))
	return
	
class ChunkData:
	extends RefCounted
	var position: Vector3
	var last_accessed: float
	var time_created: float
	var semantic_hash: String
	func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	super.pentagon_init()
		position = pos
		time_created = Time.get_unix_time_from_system()
		last_accessed = time_created
		semantic_hash = seed_hash

class TemporalVector:
	var position: Vector3
	var timestamp: float
	var direction: Vector3
	var word_anchor: String 
	func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	super.pentagon_init()
		position = pos
		direction = dir
		word_anchor = word
		timestamp = Time.get_unix_time_from_system()

func load_chunk_old(position: Vector3, word_seed: String) -> ChunkData:
	var chunk_id
	var current_time = Time.get_unix_time_from_system()
	if chunk_cache.has(chunk_id):
		chunk_cache[chunk_id].last_accessed = current_time
		return chunk_cache[chunk_id]
	if chunk_cache.size() >= MAX_RAM_CHUNKS:
		var oldest: ChunkData
		for chunk in chunk_cache.values():
			if not oldest or chunk.last_accessed < oldest.last_accessed:
				oldest = chunk
		chunk_cache.erase(oldest.position)
	var new_chunk = ChunkData.new(position, word_seed)
	new_chunk.mesh
	chunk_cache[chunk_id] = new_chunk
	return new_chunk
	
func march_cubes() -> ArrayMesh:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	for z in CHUNK_SIZE-1:
		for y in CHUNK_SIZE-1:
			for x in CHUNK_SIZE-1:
				var cube
				var cube_index := 0
				for i in 8:
					if cube[i] > ISO_LEVEL:
						cube_index |= (1 << i)
				var edges = edge_table[cube_index]
				if edges == 0:
					continue
				var vert_list = []
				for i in 12:
					if (edges & (1 << i)):
						var edge_pts
				var i = 0
				while tri_table[cube_index * 16 + i] != -1:
					var i1 = tri_table[cube_index * 16 + i]
					var i2 = tri_table[cube_index * 16 + i+1]
					var i3 = tri_table[cube_index * 16 + i+2]
					vertices.append(vert_list[i1])
					vertices.append(vert_list[i2])
					vertices.append(vert_list[i3])
					var normal = (vert_list[i2] - vert_list[i1]).cross(vert_list[i3] - vert_list[i1])
					normals.append(normal.normalized())
					normals.append(normal.normalized())
					normals.append(normal.normalized())
					i += 3
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return arr_mesh

func generate_density_field(word: String, time: float):
	var center = Vector3(CHUNK_SIZE/2, CHUNK_SIZE/2, CHUNK_SIZE/2)
	for z in CHUNK_SIZE:
		for y in CHUNK_SIZE:
			for x in CHUNK_SIZE:
				var pos = Vector3(x, y, z)
				var dist = pos.distance_to(center)
				var word_density = calculate_word_density(word, pos, time)
				var density = word_density * smoothstep(word_params.word_radius, 0.0, dist)
				volume_data[z * CHUNK_SIZE * CHUNK_SIZE + y * CHUNK_SIZE + x] = density

   #oooo  .oooooo..o ooooo   ooooo 
   #`888 d8P'    `Y8 `888'   `888' 
	#888 Y88bo.       888     888  
	#888  `"Y8888o.   888ooooo888  
	#888      `"Y88b  888     888  
	#888 oo     .d8P  888     888  
#.o. 88P 8""88888P'  o888o   o888o 
#`Y888P     

# screen can be divided like biomes and chunks of movable stuff per time somewhere

func check_for_deja_vu(concept, details):
	memory_mutex.lock()
	var has_deja_vu = false
	var location = Vector3(0, 0, 0)
	if player_memory.has(concept) and player_memory[concept].size() > 1:
		for memory in player_memory[concept]:
			if str(memory.details) == str(details) and memory.reality == current_reality:
				has_deja_vu = true
				break
	memory_mutex.unlock()
	if has_deja_vu:
		print("🔄 Déjà vu detected for concept: " + concept)
		trigger_deja_vu(concept, location)
	return has_deja_vu

func trigger_normal_cleanup():
	print("🧹 Performing normal memory cleanup")
	memory_mutex.lock()
	var current_time = Time.get_ticks_msec()
	var memory_age_threshold = 300000
	for concept in player_memory.keys():
		var i = 0
		while i < player_memory[concept].size():
			if current_time - player_memory[concept][i].timestamp > memory_age_threshold:
				player_memory[concept].remove(i)
			else:
				i += 1
		if player_memory[concept].size() == 0:
			player_memory.erase(concept)
	memory_mutex.unlock()

func trigger_emergency_cleanup():
	print("⚠️ EMERGENCY: Memory usage critical, performing aggressive cleanup")
	memory_mutex.lock()
	for concept in player_memory.keys():
		if player_memory[concept].size() > 1:
			var last_memory = player_memory[concept][-1]
			player_memory[concept] = [last_memory]
	memory_mutex.unlock()
	print("🗑️ Forcing garbage collection")

func spawn_guardian(guardian_data):
	var guardian_type = ""
	var location = Vector3(0, 0, 0)
	if guardian_data is Dictionary:
		guardian_type = guardian_data.get("type", "Unknown")
		location = guardian_data.get("location", Vector3(0, 0, 0))
	elif guardian_data is String:
		guardian_type = guardian_data
	print("👻 Spawning guardian of type: " + str(guardian_type) + " at location: " + str(location))
	var container_path = current_reality + "_reality_container"
	if main_node and main_node.has_method("first_dimensional_magic"):
		main_node.first_dimensional_magic(
			"create_entity",
			container_path,
			{
				"type": "guardian",
				"guardian_type": guardian_type,
				"position": location,
				"message": generate_guardian_message(guardian_type)
			}
		)
	guardian_spawned.emit(guardian_type, location)
	deja_vu_counter += 1
	return {"status": "success", "guardian_type": guardian_type}

func shift_reality(new_reality):
	if !REALITY_STATES.has(new_reality):
		print("⚠️ ERROR: Unknown reality state: " + str(new_reality))
		return {"status": "error", "message": "Unknown reality state"}
	reality_mutex.lock()
	print("🔄 Shifting reality from " + current_reality + " to " + new_reality)
	var old_reality = current_reality
	current_reality = new_reality
	apply_reality_rules(new_reality)
	trigger_transition_effect(old_reality, new_reality)
	reality_mutex.unlock()
	emit_signal("reality_shifted", old_reality, new_reality)
	deja_vu_counter += 1
	return {
		"status": "success",
		"old_reality": old_reality,
		"new_reality": new_reality
	}

func apply_reality_rules(reality_type):
	match reality_type:
		"physical":
			Engine.time_scale = 1.0
			apply_color_palette("normal")
		"digital":
			Engine.time_scale = 1.2
			apply_color_palette("low_poly")
		"astral":
			Engine.time_scale = 0.8
			apply_color_palette("geometric")

func apply_color_palette(palette_name):
	var world_env = get_node_or_null("/root/World/WorldEnvironment")
	if world_env and "environment" in world_env:
		print("🎨 Applied color palette: " + palette_name)

func trigger_transition_effect(from_reality, to_reality):
	print("✨ Triggering transition effect from " + from_reality + " to " + to_reality)
	var effect_name = "transition_" + from_reality + "_to_" + to_reality
	print("🔄 Playing transition effect: " + effect_name)
	create_new_task("play_transition_effect", [from_reality, to_reality])

func spawn_entity(data):
	var entity_type = data[0]
	var entity_params = data[1]
	print("🧩 Spawning entity of type: " + str(entity_type) + " with params: " + str(entity_params))
	var entity_id = "entity_" + str(Time.get_ticks_msec())
	emit_signal("entity_created", entity_type, entity_id)
	return {"status": "success", "entity_id": entity_id}

func transform_entity(data):
	var entity_id = data[0]
	var transform_params = data[1]
	print("🔄 Transforming entity " + entity_id + " with params: " + str(transform_params))
	emit_signal("entity_transformed", entity_id, transform_params.get("shape_type", "unknown"))
	return {"status": "success", "entity_id": entity_id}

func trigger_deja_vu(action, location):
	print("🔄 Déjà vu triggered by action: " + str(action))
	var trigger_data = {
		"action": action,
		"location": location,
		"guardian_type": select_guardian_type(action),
		"message": generate_guardian_message(action)
	}
	emit_signal("deja_vu_triggered", trigger_data)
	create_new_task("spawn_guardian", [trigger_data.guardian_type, location])
	return {"status": "success", "trigger": trigger_data}

func select_guardian_type(action: String) -> String:
	var action_types = {
		"create": "Elastic One",
		"transform": "Transformer",
		"shift": "God Hand",
		"speak": "Annoyed Spirit"
	}
	for key in action_types.keys():
		if str(action).begins_with(key):
			return action_types[key]
	return "Annoyed Spirit" 

func process_entity_interaction(interaction_data, entity_path):
	print("🤝 Processing entity interaction: " + str(interaction_data))
	var entity = get_node_or_null(entity_path)
	if !entity:
		print("⚠️ Entity not found at path: " + entity_path)
		return
	match interaction_data.get("type", ""):
		"dialog":
			print("💬 Dialog interaction with " + entity_path)
			create_new_task("play_entity_dialog", [entity, interaction_data.get("dialog_id", "")])
		"transform":
			print("🔄 Transform interaction with " + entity_path)
			create_new_task("transform_entity", [entity_path, interaction_data])
		_:
			print("⚠️ Unknown interaction type: " + interaction_data.get("type", ""))

func remember(concept, details):
	memory_mutex.lock()
	var timestamp = Time.get_ticks_msec()
	if !player_memory.has(concept):
		player_memory[concept] = []
	player_memory[concept].append({
		"details": details,
		"timestamp": timestamp,
		"reality": current_reality
	})
	while player_memory[concept].size() > MAX_MEMORY_ENTRIES:
		player_memory[concept].pop_front()
	memory_mutex.unlock()
	print("🧠 Remembered: " + concept + " = " + str(details))
	check_for_deja_vu(concept, details)
	return {"status": "success", "concept": concept}

func recall(concept):
	memory_mutex.lock()
	var result = null
	if player_memory.has(concept):
		result = player_memory[concept].duplicate()
	memory_mutex.unlock()
	if result:
		print("🧠 Recalled: " + concept + " = " + str(result[-1].details))
		return {"status": "success", "concept": concept, "memory": result}
	else:
		print("❓ No memory found for: " + concept)
		return {"status": "error", "message": "No memory found for: " + concept}


   #oooo  .oooooo..o ooooo   ooooo 
   #`888 d8P'    `Y8 `888'   `888' 
	#888 Y88bo.       888     888  
	#888  `"Y8888o.   888ooooo888  
	#888      `"Y88b  888     888  
	#888 oo     .d8P  888     888  
#.o. 88P 8""88888P'  o888o   o888o 
#`Y888P     

# as you split frames and lod, you have detail hidden

func _on_command_processed(command, result):
	print("🖥️ Command processed: " + command + " → " + ("✓" if result.success else "✗"))
	if result.success:
		remember("command_executed", {"command": command, "result": result.message})

func _cmd_create(args):
	if args.size() < 2:
		return {"success": false, "message": "Usage: create [type] [name] [attributes...]"}
	var type = args[0]
	var name = args[1]
	var attributes = {}
	for i in range(2, args.size(), 2):
		if i + 1 < args.size():
			attributes[args[i]] = args[i + 1]
	print("🧩 Creating entity: " + name + " of type: " + type)
	create_new_task("spawn_entity", [type, {"name": name, "attributes": attributes}])
	remember("creation_" + name, {"type": type, "attributes": attributes})
	return {
		"success": true,
		"message": "Created " + type + " named " + name,
		"entity_name": name
	}

func _cmd_transform(args):
	if args.size() < 2:
		return {"success": false, "message": "Usage: transform [entity_name] [new_form] [attributes...]"}
	var entity_name = args[0]
	var new_form = args[1]
	var attributes = {}
	for i in range(2, args.size(), 2):
		if i + 1 < args.size():
			attributes[args[i]] = args[i + 1]
	print("🔄 Transforming entity: " + entity_name + " into: " + new_form)
	create_new_task("transform_entity", [entity_name, {"shape_type": new_form, "attributes": attributes}])
	remember("transform_" + entity_name, {"new_form": new_form, "attributes": attributes})
	return {
		"success": true,
		"message": "Transformed " + entity_name + " into " + new_form,
		"entity_name": entity_name
	}

func _cmd_remember(args):
	if args.size() < 2:
		return {"success": false, "message": "Usage: remember [concept] [details...]"}
	var concept = args[0]
	var details = " ".join(args.slice(1, args.size() - 1))
	remember(concept, details)
	return {
		"success": true,
		"message": "Remembered " + concept + " as " + details,
		"concept": concept
	}

func _cmd_shift(args):
	if args.size() < 1:
		return {"success": false, "message": "Usage: shift [reality_type]"}
	var reality_type = args[0]
	if !REALITY_STATES.has(reality_type):
		return {
			"success": false,
			"message": "Unknown reality type: " + reality_type + ". Valid types: " + str(REALITY_STATES)
		}
	print("🌐 Shifting reality to: " + reality_type)
	create_new_task("shift_reality", reality_type)
	remember("reality_shift", {"new_reality": reality_type})
	return {
		"success": true,
		"message": "Shifting reality to " + reality_type,
		"reality": reality_type
	}

func initialize_command_parser():
	print("⌨️ Initializing command parser...")
	command_parser = CommandParser.new(self)
	command_parser.register_command("create", self, "_cmd_create")
	command_parser.register_command("transform", self, "_cmd_transform")
	command_parser.register_command("remember", self, "_cmd_remember")
	command_parser.register_command("shift", self, "_cmd_shift")
	command_parser.register_command("speak", self, "_cmd_speak")
	command_parser.register_command("glitch", self, "_cmd_glitch")
	command_parser.register_command("threads", self, "cmd_threads")
	command_parser.register_command("thread_status", self, "cmd_thread_status")
	command_parser.register_command("reset_threads", self, "cmd_reset_threads")
	command_parser.register_command("help", self, "cmd_help")
	print("✅ Command parser initialized with " + str(command_parser.commands.size()) + " commands registered")

func create_command_parser(_unused):
	var parser = CommandParser.new(self)
	set_meta("command_parser", parser)
	return {"status": "success", "message": "Command parser created"}

func register_command(data):
	var cmd = data.command
	var method = data.method
	
	var parser = get_meta("command_parser")
	if parser and parser.register_command(cmd, method):
		return {"status": "success", "message": "Command registered: " + cmd}
	else:
		return {"status": "error", "message": "Failed to register command: " + cmd}

func parse_command(input_text):
	var parser = get_meta("command_parser")
	if parser:
		var result = parser.parse(input_text)
		emit_signal("command_processed", input_text, result)
		return result
	else:
		return {"success": false, "message": "Command parser not initialized"}

func find_interface_text_node():
	var container = get_node_or_null("/root/main/digital_earthlings_container")
	if container:
		return container.get_node_or_null("thing_3")
	return null

func enter_command():
	if main_node and main_node.has_method("eight_dimensional_magic"):
		main_node.eight_dimensional_magic(
			"get_text_input", 
			"Enter command:", 
			"digital_earthlings_container"
		)
		await get_tree().create_timer(0.5).timeout
		parse_command("help")

func _cmd_guardian(args):
	if args.size() < 1:
		return {"success": false, "message": "Usage: guardian [type]"}
	var guardian_type = args.join(" ")
	var location = Vector3(0, 0.5, -2)
	return {
		"success": true,
		"message": "Summoned " + guardian_type + " guardian"
	}

func _cmd_deja_vu(args):
	trigger_deja_vu("manual", Vector3(0, 0, -2))
	return {
		"success": true,
		"message": "Déjà vu triggered"
	}

func _cmd_spawn(args):
	if args.size() < 1:
		return {"success": false, "message": "Usage: spawn [entity_type]"}
	var entity_type = args[0]
	var location = Vector3(0, 0, 0)
	if main_node and main_node.has_method("first_dimensional_magic"):
		main_node.first_dimensional_magic(
			"create_entity",
			current_reality + "_reality_container",
			{
				"type": entity_type,
				"position": location,
				"reality": current_reality
			}
		)
	return {
		"success": true,
		"message": "Spawned " + entity_type
	}




   #oooo  .oooooo..o ooooo   ooooo 
   #`888 d8P'    `Y8 `888'   `888' 
	#888 Y88bo.       888     888  
	#888  `"Y8888o.   888ooooo888  
	#888      `"Y88b  888     888  
	#888 oo     .d8P  888     888  
#.o. 88P 8""88888P'  o888o   o888o 
#`Y888P     


# we must learn to repair automatically glitches in my game, i play it to
# even as god

func create_anomaly():
	var anomaly_types = ["glitch", "guardian", "reality_fluctuation"]
	var chosen_type = anomaly_types[randi() % anomaly_types.size()]
	match chosen_type:
		"glitch":
			var parameters = ["visuals", "physics", "audio", "time"]
			var intensities = ["low", "medium", "high"]
			var durations = ["2s", "4s", "6s"]
			
			create_glitch_effect(
				parameters[randi() % parameters.size()],
				intensities[randi() % intensities.size()],
				durations[randi() % durations.size()]
			)
		"guardian":
			var guardian_types = ["Elastic One", "Transformer", "God Hand", "Annoyed Spirit"]
			var location = Vector3(
				(randf() - 0.5) * 10.0,
				(randf() - 0.5) * 5.0,
				(randf() - 0.5) * 10.0
			)
			spawn_guardian(
				guardian_types[randi() % guardian_types.size()],
			)
		"reality_fluctuation":
			var current = current_reality
			var alternate_realities = REALITY_STATES.duplicate()
			alternate_realities.erase(current)
			var temp_reality = alternate_realities[randi() % alternate_realities.size()]
			apply_reality_rules(temp_reality)
			var timer = get_tree().create_timer(1.0)
			timer.connect("timeout", Callable(self, "apply_reality_rules").bind(current))


   #oooo  .oooooo..o ooooo   ooooo 
   #`888 d8P'    `Y8 `888'   `888' 
	#888 Y88bo.       888     888  
	#888  `"Y8888o.   888ooooo888  
	#888      `"Y88b  888     888  
	#888 oo     .d8P  888     888  
#.o. 88P 8""88888P'  o888o   o888o 
#`Y888P     


func toggle_reality_containers(old_reality, new_reality):
	var old_container = get_node_or_null("/root/main/" + old_reality + "_reality_container")
	if old_container:
		old_container.visible = false
	var new_container = get_node_or_null("/root/main/" + new_reality + "_reality_container")
	if new_container:
		new_container.visible = true

func cycle_reality():
	var current_index = REALITY_STATES.find(current_reality)
	var next_index = (current_index + 1) % REALITY_STATES.size()
	var next_reality = REALITY_STATES[next_index]
	shift_reality(next_reality)



func get_spatiotemporal_hash(pos: Vector3, time_window: float) -> String:
	var quantized_pos = Vector3(
		floor(pos.x / time_window),
		floor(pos.y / time_window),
		floor(pos.z / time_window)
	)
	return "%d_%d_%d_%f" % [quantized_pos.x, quantized_pos.y, quantized_pos.z, time_window]

func get_spatiotemporal_hash_old(pos: Vector3, time_window: float) -> String:
	var quantized_pos = Vector3(
		floor(pos.x / time_window),
		floor(pos.y / time_window),
		floor(pos.z / time_window)
	)
	return "%d_%d_%d_%f" % [quantized_pos.x, quantized_pos.y, quantized_pos.z, time_window]

   #oooo  .oooooo..o ooooo   ooooo 
   #`888 d8P'    `Y8 `888'   `888' 
	#888 Y88bo.       888     888  
	#888  `"Y8888o.   888ooooo888  
	#888      `"Y88b  888     888  
	#888 oo     .d8P  888     888  
#.o. 88P 8""88888P'  o888o   o888o 
#`Y888P     
# now it is 11868 line here, so we added thousands by cleaning too?

func handle_snake_menu_interaction(option, difficulty = "normal"):
	print("Snake menu option: ", option)
	match option:
		"Snake Game":
			print("something")
		"Back":
			print("something")
		"Easy Mode":
			launch_snake_game("easy")
		"Normal Mode":
			launch_snake_game("normal")
		"Hard Mode":
			launch_snake_game("hard")
		"Instructions":
			print("something")
		"High Scores":
			display_high_scores()

func launch_snake_game(difficulty):
	print("Launching Snake game with difficulty: ", difficulty)
	var container_name = "snake_game_container"
	var container_node = get_node_or_null(container_name)
	if not container_node:
		three_stages_of_creation_snake("snake_game")
		container_node = get_node_or_null(container_name)
	if container_node:
		var snake_game = container_node.get_node_or_null("JSHSnakeGame")
		if snake_game:
			match difficulty:
				"easy":
					snake_game.current_speed = 1
				"normal":
					snake_game.current_speed = 2
				"hard":
					snake_game.current_speed = 3
		var menu_container = get_node_or_null("akashic_records")
		if menu_container:
			menu_container.visible = false
		show_snake_game()
	else:
		print("Failed to create snake game container")

func display_high_scores():
	print("Displaying high scores")
	var info_text = get_node_or_null("snake_game_container/thing_103")
	if info_text and info_text is Label3D:
		info_text.text = "High scores not implemented yet."

func process_snake_button_click(button_name):
	if button_name in ["Snake Game", "Easy Mode", "Normal Mode", "Hard Mode", 
					  "Instructions", "High Scores"]:
		handle_snake_menu_interaction(button_name)
		return true
	elif button_name == "Back":
		var current_menu = get_current_menu_context()
		if current_menu in ["snake_difficulty", "snake_instructions", "snake_highscores"]:
			handle_snake_menu_interaction("Back")
			return true
	return false

func get_current_menu_context():
	var records_node = get_node_or_null("akashic_records")
	if records_node:
		var thing_7 = records_node.get_node_or_null("thing_7")
		if thing_7 and thing_7.has_meta("current_scene"):
			var scene_id = thing_7.get_meta("current_scene")
			match scene_id:
				"scene_11": return "snake_difficulty"
				"scene_12": return "snake_instructions"
	return "unknown"

func show_snake_game():
	print("\n🐍 Showing Snake Game...\n")
	var container_name = "snake_game_container"
	var container_node = get_node_or_null(container_name)
	if not container_node:
		three_stages_of_creation_snake("snake_game")
		container_node = get_node_or_null(container_name)
		if not container_node:
			print("Failed to create snake game container")
			return
	container_node.visible = true
	position_camera_for_snake_game()
	setup_snake_input_handling()
	print("Snake game is now active")

func hide_snake_game():
	print("\n🐍 Hiding Snake Game...\n")
	var container_name = "snake_game_container"
	var container_node = get_node_or_null(container_name)
	if container_node:
		container_node.visible = false
		print("Snake game hidden")
	restore_camera_position()
	restore_normal_input_handling()

func position_camera_for_snake_game():
	if has_node("camera"):
		var camera = get_node("camera")
		camera.set_meta("previous_position", camera.global_position)
		camera.set_meta("previous_rotation", camera.global_rotation)
		var container = get_node_or_null("snake_game_container")
		if container:
			camera.global_position = container.global_position + Vector3(0, 15, 12)
			camera.look_at(container.global_position, Vector3.UP)

func restore_camera_position():
	if has_node("camera"):
		var camera = get_node("camera")
		if camera.has_meta("previous_position") and camera.has_meta("previous_rotation"):
			camera.global_position = camera.get_meta("previous_position")
			camera.global_rotation = camera.get_meta("previous_rotation")

func setup_snake_input_handling():
	character_stop()
	print("Snake game input handling enabled")

func restore_normal_input_handling():
	if has_meta("previous_input_handling"):
		var previous = get_meta("previous_input_handling")
		if previous.forward:
			character_move_forward()
		if previous.backward:
			character_move_backward()
		if previous.left:
			character_move_left()
		if previous.right:
			character_move_right()
	print("Normal input handling restored")

func _input_snake(event):
	var snake_container = get_node_or_null("snake_game_container")
	if snake_container and snake_container.visible:
		return
	if event is InputEventKey:
		if event.pressed:
			match event.keycode:
				KEY_UP, KEY_W:
					character_move_forward()
				KEY_DOWN, KEY_S:
					character_move_backward() 
				KEY_LEFT, KEY_A:
					character_move_left()
				KEY_RIGHT, KEY_D:
					character_move_right()
				KEY_F1:
					var container = get_node_or_null("snake_game_container")
					if container and container.visible:
						hide_snake_game()
					else:
						show_snake_game()
		else:
			match event.keycode:
				KEY_UP, KEY_W, KEY_DOWN, KEY_S, KEY_LEFT, KEY_A, KEY_RIGHT, KEY_D:
					character_stop()

func _cmd_glitch(args):
	if args.size() < 2:
		return {"success": false, "message": "Usage: glitch [parameter] [intensity]"}
	var parameter = args[0]
	var intensity = args[1]
	var duration = "10s"
	if args.size() > 2:
		duration = args[2]
	print("🔥 Creating glitch in: " + parameter + " with intensity: " + intensity)
	var valid_parameters = ["physics", "visuals", "audio", "time"]
	if !valid_parameters.has(parameter):
		return {
			"success": false,
			"message": "Invalid parameter: " + parameter + ". Valid parameters: " + str(valid_parameters)
		}
	var intensity_value = 50
	if intensity == "low":
		intensity_value = 25
	elif intensity == "medium":
		intensity_value = 50
	elif intensity == "high":
		intensity_value = 75
	elif intensity == "extreme":
		intensity_value = 100
	else:
		var parsed = int(intensity)
		if parsed > 0:
			intensity_value = min(parsed, 100)
	create_new_task("create_glitch_effect", [parameter, intensity_value, duration])
	remember("glitch_" + parameter, {"intensity": intensity_value, "duration": duration})
	return {
		"success": true,
		"message": "Created " + parameter + " glitch with intensity " + str(intensity_value) + " for " + duration,
		"parameter": parameter
	}

func apply_visual_glitch(intensity, duration):
	var glitch_strength = intensity / 100.0
	if main_node and main_node.has_method("the_fourth_dimensional_magic"):
		for reality in REALITY_STATES:
			var container_path = reality + "_reality_container"
			main_node.the_fourth_dimensional_magic(
				"apply_effect",
				container_path,
				{
					"effect": "glitch",
					"strength": glitch_strength,
					"duration": duration
				}
			)
	get_tree().create_timer(duration).timeout.connect(func(): print("Visual glitch effect ended"))

func apply_physics_glitch(intensity, duration):
	var glitch_strength = intensity / 100.0
	var original_gravity = Vector2(0, 9.8)
	var new_gravity = Vector2(
		(randf() - 0.5) * glitch_strength * 5.0,
		9.8 * (1.0 - glitch_strength / 2.0)
	)

func apply_audio_glitch(intensity, duration):
	var glitch_strength = intensity / 100.0
	print("🔊 Audio glitch applied with strength " + str(glitch_strength))
	get_tree().create_timer(duration).timeout.connect(func(): print("Audio glitch effect ended"))

func apply_time_glitch(intensity, duration):
	var glitch_strength = intensity / 100.0
	var original_time_scale = Engine.time_scale
	var new_time_scale = original_time_scale * (1.0 + (randf() - 0.5) * glitch_strength * 1.5)
	Engine.time_scale = new_time_scale
	get_tree().create_timer(duration).timeout.connect(func(): 
		Engine.time_scale = original_time_scale
	)

func create_glitch_effect(parameter, intensity, duration_str):
	var duration = 10.0
	if duration_str.ends_with("s"):
		var seconds = float(duration_str.substr(0, duration_str.length() - 1))
		if seconds > 0:
			duration = seconds
	var intensity_value = 50
	if intensity is String:
		match intensity:
			"low": intensity_value = 25
			"medium": intensity_value = 50
			"high": intensity_value = 75
			"extreme": intensity_value = 100
			_:
				var parsed = int(intensity)
				if parsed > 0:
					intensity_value = min(parsed, 100)
	else:
		intensity_value = min(int(intensity), 100)
	print("🔥 Creating " + parameter + " glitch with intensity " + str(intensity_value) + " for " + str(duration) + "s")
	sixth_dimensional_magic("call_function_single_get_node", "/root/JSH_reality_shaders", "create_glitch_effect", [parameter, intensity_value, duration_str])
	remember("glitch_" + parameter, {"intensity": intensity_value, "duration": duration})
	return {
		"status": "success", 
		"parameter": parameter,
		"intensity": intensity_value,
		"duration": duration
	}

func _cmd_speak(args):
	if args.size() < 2:
		return {"success": false, "message": "Usage: speak [entity_name] [message]"}
	var entity_name = args[0]
	var message = " ".join(args.slice(1, args.size() - 1))
	print("💬 Speaking to entity: " + entity_name + " with message: " + message)
	eight_dimensional_magic("player_message", message, entity_name)
	remember("conversation_" + entity_name, {"message": message})
	return {
		"success": true,
		"message": "Spoke to " + entity_name + ": " + message,
		"entity_name": entity_name
	}

func calculate_word_density(word: String, pos: Vector3, time: float) -> float:
	var density := 0.0
	var angle_step = TAU / word.length()
	for i in word.length():
		var char_code = word.unicode_at(i)
		var angle = i * angle_step + time
		var char_pos = Vector3(
			cos(angle) * word_params.word_radius,
			pos.y * 0.1,
			sin(angle) * word_params.word_radius
		)
		density += exp(-pos.distance_to(char_pos) * (char_code * word_params.letter_scale))
	return density

func initialize_volume(size: int):
	volume_data.resize(size * size * size)
	var format = Image.FORMAT_RF
	var image
	density_texture

func get_guardian_color(guardian_type):
	match guardian_type:
		"Elastic One":
			return Color(1.0, 0.5, 0.0, 0.8)  # Orange
		"Transformer":
			return Color(0.0, 0.8, 0.8, 0.8)  # Teal
		"God Hand":
			return Color(1.0, 1.0, 0.0, 0.8)  # Yellow
		"Annoyed Spirit":
			return Color(0.8, 0.0, 0.8, 0.8)  # Purple
		_:
			return Color(1.0, 1.0, 1.0, 0.8)  # White

func get_reality_color(reality):
	match reality:
		"physical":
			return Color(0.2, 0.6, 1.0, 0.8)  # Blue
		"digital":
			return Color(0.1, 0.8, 0.2, 0.8)  # Green
		"astral":
			return Color(0.8, 0.3, 0.8, 0.8)  # Purple
		_:
			return Color(1.0, 1.0, 1.0, 0.8)  # White

func _on_main_node_signal(signal_name, signal_data):
	print("📡 Received signal from main node: " + str(signal_name))
	match signal_name:
		"task_completed":
			print("✅ Task completed: " + str(signal_data))
		"entity_created":
			print("🧩 Entity created: " + str(signal_data))
		"reality_changed":
			print("🌐 Reality changed: " + str(signal_data))
		_:
			print("📡 Unhandled signal: " + str(signal_name))

func _on_task_discarded(task):
	print("✅ Task completed: " + str(task.tag))

func _on_task_started(task):
	print("⏳ Task started: " + str(task))

func _on_reality_shifted(old_reality, new_reality):
	print("🌐 Reality shifted from " + old_reality + " to " + new_reality)

func _on_guardian_spawned(guardian_type, location):
	print("👻 Guardian of type " + guardian_type + " spawned at " + str(location))

func _on_deja_vu_triggered(trigger_data):
	print("🔄 Déjà vu triggered: " + str(trigger_data))

func connect_signals():
	if main_node:
		if main_node.has_signal("main_node_signal"):
			main_node.connect("main_node_signal", _on_main_node_signal)
	self.connect("reality_shifted", _on_reality_shifted)
	self.connect("guardian_spawned", _on_guardian_spawned)
	self.connect("deja_vu_triggered", _on_deja_vu_triggered)
	self.connect("command_processed", _on_command_processed)
	if thread_pool:
		thread_pool.connect("task_discarded", _on_task_discarded)
		thread_pool.connect("task_started", _on_task_started)

func apply_reality_shader(reality_type):
	sixth_dimensional_magic("call_function_single_get_node", "/root/JSH_reality_shaders", "apply_color_palette", reality_type)

func register_with_banks_combiner():
	if !BanksCombiner.data_sets_names_0.has("digital_earthlings"):
		BanksCombiner.data_sets_names_0.append("digital_earthlings")
		BanksCombiner.data_sets_names.append("digital_earthlings_")
	if !BanksCombiner.data_sets_names_0.has("physical_reality"):
		BanksCombiner.data_sets_names_0.append("physical_reality")
		BanksCombiner.data_sets_names.append("physical_reality_")
	if !BanksCombiner.data_sets_names_0.has("digital_reality"):
		BanksCombiner.data_sets_names_0.append("digital_reality")
		BanksCombiner.data_sets_names.append("digital_reality_")
	if !BanksCombiner.data_sets_names_0.has("astral_reality"):
		BanksCombiner.data_sets_names_0.append("astral_reality")
		BanksCombiner.data_sets_names.append("astral_reality_")

func register_digital_earthlings_records():
	print("📝 Registering Digital Earthlings records...")
	if BanksCombiner:
		if !BanksCombiner.data_sets_names_0.has("digital_earthlings"):
			BanksCombiner.data_sets_names_0.append("digital_earthlings")
			BanksCombiner.data_sets_names.append("digital_earthlings_")
		if !BanksCombiner.data_sets_names_0.has("physical_reality"):
			BanksCombiner.data_sets_names_0.append("physical_reality")
			BanksCombiner.data_sets_names.append("physical_reality_")
		if !BanksCombiner.data_sets_names_0.has("digital_reality"):
			BanksCombiner.data_sets_names_0.append("digital_reality")
			BanksCombiner.data_sets_names.append("digital_reality_")
		if !BanksCombiner.data_sets_names_0.has("astral_reality"):
			BanksCombiner.data_sets_names_0.append("astral_reality")
			BanksCombiner.data_sets_names.append("astral_reality_")
	if JSH_records_system and JSH_records_system.has_method("add_basic_set"):
		JSH_records_system.add_basic_set("digital_earthlings")
		JSH_records_system.add_basic_set("physical_reality")
		JSH_records_system.add_basic_set("digital_reality")
		JSH_records_system.add_basic_set("astral_reality")
	print("📝 Digital Earthlings records registered")

func test_thread_system():
	print("🧪 Testing single core operation...")
	test_single_core()
	print("🧪 Testing multi-threaded operation...")
	test_multi_threaded()
	await get_tree().create_timer(0.5).timeout
	var thread_status = check_thread_status_type()
	print("📊 Thread status: " + str(thread_status))
	var is_working = multi_threads_start_checker()
	if is_working:
		print("✅ Multi-threading is working correctly!")
	else:
		print("⚠️ Multi-threading may not be working as expected")

func initialize_thread_system():
	print("🧵 Initializing thread system...")
	if thread_pool == null:
		print("⚠️ Thread pool not found. Creating new instance...")
		# Use JSH thread pool manager instead
		thread_pool = get_node("/root/JSHThreadPool") if has_node("/root/JSHThreadPool") else Node.new()
		add_child(thread_pool)
	thread_pool.connect("task_discarded", Callable(self, "_on_task_discarded"))
	thread_pool.connect("task_started", Callable(self, "_on_task_started"))
	print("✅ Thread system initialized with " + str(OS.get_processor_count()) + " available threads")

func cmd_threads(args):
	if args.size() < 1:
		return {
			"success": false,
			"message": "Usage: threads [count]"
		}
	var count = int(args[0])
	if count <= 0:
		return {
			"success": false,
			"message": "Thread count must be greater than 0"
		}
	var max_threads = OS.get_processor_count()
	var actual_count = min(count, max_threads)
	print("🧵 Setting thread count to: " + str(actual_count))
	return {
		"success": true,
		"message": "Thread count set to: " + str(actual_count) + " (Available: " + str(max_threads) + ")"
	}

func cmd_thread_status(args):
	print("🧵 Checking thread status...")
	var thread_stats = check_thread_status_type()
	return {
		"success": true,
		"message": "Thread status checked. See console for details."
	}

func cmd_reset_threads(args):
	print("🧵 Resetting thread settings to defaults...")
	var default_count = min(4, OS.get_processor_count())
	return {
		"success": true,
		"message": "Thread settings reset to defaults. Using " + str(default_count) + " threads."
	}

func process_system_snake(delta):
	var snake_container = get_node_or_null("snake_game_container")
	if snake_container and snake_container.visible:
		var snake_game = snake_container.get_node_or_null("JSHSnakeGame")
		if snake_game and snake_game.has_method("_process"):
			pass

func character_move_forward():
	var character = get_node_or_null("character")
	if character && character.has_method("move_forward"):
		character.move_forward()

func character_move_backward():
	var character = get_node_or_null("character")
	if character && character.has_method("move_backward"):
		character.move_backward()

func character_move_left():
	var character = get_node_or_null("character")
	if character && character.has_method("move_left"):
		character.move_left()

func character_move_right():
	var character = get_node_or_null("character")
	if character && character.has_method("move_right"):
		character.move_right()

func character_stop():
	var character = get_node_or_null("character")
	if character && character.has_method("stop_moving"):
		character.stop_moving()

func first_dimensional_magic_snake(type_of_action_to_do, datapoint_node, additional_node = null):
	if type_of_action_to_do == "character_move":
		var direction = datapoint_node
		match direction:
			"forward":
				character_move_forward()
			"backward":
				character_move_backward()
			"left":
				character_move_left() 
			"right":
				character_move_right()
			"stop":
				character_stop()
		return true
	elif type_of_action_to_do == "show_container" and datapoint_node == "snake_game_container":
		show_snake_game()
		return true
	elif type_of_action_to_do == "hide_container" and datapoint_node == "snake_game_container":
		hide_snake_game()
		return true
	elif type_of_action_to_do == "snake_input":
		var snake_game = get_node_or_null("snake_game_container/JSHSnakeGame")
		if snake_game and snake_game.has_method("handle_input"):
			snake_game.handle_input(datapoint_node)
			return true
	return false 

func three_stages_of_creation_snake(set_name: String):
	print("\n🐍 Creating Space Snake Game...\n")
	var container_name = "snake_game_container"
	var container_node = get_node_or_null(container_name)
	if container_node:
		print("Snake game container already exists")
		return
	var container = Node3D.new()
	container.name = container_name
	container.visible = false 
	container.set_script(ContainterScript)
	add_child(container)
	var data_point = Node3D.new()
	data_point.name = "thing_101"
	data_point.set_script(DataPointScript)
	FloodgateController.universal_add_child(data_point, container)
	tree_mutex.lock()
	if scene_tree_jsh["main_root"]["branches"].has("snake_game_container") == false:
		scene_tree_jsh["main_root"]["branches"]["snake_game_container"] = {
			"branch_name": "snake_game_container",
			"branch_type": "container",
			"branch_position": Vector3(0, 0, 0),
			"datapoint": {
				"datapoint_name": "thing_101",
				"datapoint_path": "snake_game_container/thing_101",
				"datapoint_priority": 0
			}
		}
	tree_mutex.unlock()
	var snake_game = Node3D.new()
	snake_game.name = "JSHSnakeGame"
	snake_game.set_script(load("res://scripts/jsh_snake_game.gd"))
	FloodgateController.universal_add_child(snake_game, container)

func create_character():
	print("\n👤 Creating character...\n")
	var character_node = get_node_or_null("character")
	if character_node:
		print("Character already exists")
		return
	var character = Node3D.new()
	character.name = "character"
	var script = load("res://scripts/character_controller.gd")
	if !script:
		script = load("res://scripts/character_controller.gd")
	character.set_script(script)
	add_child(character)
	character.global_position = Vector3(0, 0, 5)
	print("Character created")
	return character

func create_racing_game_integrator():
	print("\n🏎️ Setting up World of Pallets Racing integration...\n")
	var racing_integrator = get_node_or_null("RacingGameIntegrator")
	if racing_integrator:
		print("Racing game integrator already exists")
		return
	
	# Create the racing game integrator
	var integrator_script = load("res://code/gdscript/scripts/Menu_Keyboard_Console/racing_menu_integrator.gd")
	if integrator_script:
		var integrator = Node.new()
		integrator.name = "RacingGameIntegrator"
		integrator.set_script(integrator_script)
		add_child(integrator)
		print("Racing game integrator created")
	else:
		print("Failed to load racing menu integrator script")

func create_records_entries():
	if not "digital_earthlings" in BanksCombiner.data_sets_names_0:
		BanksCombiner.data_sets_names_0.append("digital_earthlings")
		BanksCombiner.data_sets_names.append("digital_earthlings_")
	
	# Add racing game entries
	if not "world_of_pallets_racing" in BanksCombiner.data_sets_names_0:
		BanksCombiner.data_sets_names_0.append("world_of_pallets_racing")
		BanksCombiner.data_sets_names.append("world_of_pallets_racing_")

func add_available_record_sets():
	if JSH_records_system and JSH_records_system.has_method("add_basic_set"):
		JSH_records_system.add_basic_set("digital_earthlings")

func initialize_console_system():
	print("\n🖥️ [CONSOLE] Initializing JSH Console System...\n")
	if jsh_console == null:
		print("Creating console system node")
		var console_system = load("res://scripts/jsh_console.gd").new()
	
	# Initialize racing game integration
	create_racing_game_integrator()

# Function called when the Pallets Racing button is clicked
func start_racing_game():
	print("\n🏎️ Starting World of Pallets Racing...\n")
	
	# Check if racing game container exists
	var container_name = "racing_game_container"
	var container_node = get_node_or_null(container_name)
	
	if not container_node:
		print("Creating racing game container via three_stages_of_creation...")
		# Create the racing game container through the system's creation pipeline
		create_new_task("three_stages_of_creation", "racing_game")
		
		# Add racing_game to the data sets if not already there
		if not "racing_game" in BanksCombiner.data_sets_names_0:
			BanksCombiner.data_sets_names_0.append("racing_game")
			BanksCombiner.data_sets_names.append("racing_game_")
		
		# The container will be created through the normal pipeline
		# We need to add it to the queue of actions to be performed
		mutex_actions.lock()
		actions_to_be_called.append(["set_up_racing_game", container_name, 1])
		mutex_actions.unlock()
		
		# Later, in process_system_7, this action will be processed and will:
		# - Set camera position
		# - Hide menu
		# - Show racing game container
	else:
		# If the container already exists, we just need to show it and hide the menu
		print("Racing game container already exists, showing it...")
		
		# Hide menu
		var menu_container = get_node_or_null("akashic_records")
		if menu_container:
			seventh_dimensional_magic("change_visibilty", "akashic_records", 0)
		
		# Show racing game container
		seventh_dimensional_magic("change_visibilty", container_name, 1)
		
		# Queue camera repositioning
		mutex_function_call.lock()
		functions_to_be_called.append(["position_camera_for_racing_game", null, null])
		mutex_function_call.unlock()
	
	print("Racing game launching sequence initiated")

# Position the camera for the racing game
func position_camera_for_racing_game():
	if has_node("camera"):
		var camera = get_node("camera")
		camera.set_meta("previous_position", camera.global_position)
		camera.set_meta("previous_rotation", camera.global_rotation)
		
		var container = get_node_or_null("racing_game_container")
		if container:
			# Position the camera above and behind the racing track
			camera.global_position = container.global_position + Vector3(0, 15, 25)
			camera.look_at(container.global_position, Vector3.UP)

# Setup racing game input handling
func setup_racing_game_input_handling():
	# Set up any special input handling for the racing game
	print("Setting up racing game input handling")
	# Implement racing game specific input handling here

# Process the set_up_racing_game action
func set_up_racing_game(container_name, visibility):
	print("\n🏎️ Setting up Racing Game Environment...\n")
	
	# Wait for the container to be created by the three_stages_of_creation
	var container_node = get_node_or_null(container_name)
	if not container_node:
		# If container doesn't exist yet, re-queue this action for next frame
		mutex_actions.lock()
		actions_to_be_called.append(["set_up_racing_game", container_name, visibility])
		mutex_actions.unlock()
		return
	
	# Container exists, set up everything else
	
	# Load the racing game script
	var PalletsRacingGameScript = load("res://code/gdscript/scripts/Menu_Keyboard_Console/pallets_racing_game.gd")
	
	# Create racing game node if it doesn't exist yet
	var racing_game_node = container_node.get_node_or_null("PalletsRacingGame")
	if not racing_game_node:
		print("Creating PalletsRacingGame node...")
		racing_game_node = Node3D.new()
		racing_game_node.name = "PalletsRacingGame"
		racing_game_node.set_script(PalletsRacingGameScript)
		FloodgateController.universal_add_child(racing_game_node, container_node)
		
		# Set up the reference to main in the racing game script
		if racing_game_node.has_method("setup_main_reference"):
			racing_game_node.setup_main_reference(self)
	
	# Hide menu
	var menu_container = get_node_or_null("akashic_records")
	if menu_container:
		menu_container.visible = false
	
	# Show racing game container
	container_node.visible = true
	
	# Position camera
	position_camera_for_racing_game()
	
	# Setup input handling
	setup_racing_game_input_handling()
	
	print("Racing game is now active")

# Hide racing game and restore previous state
func hide_racing_game():
	print("\n🏎️ Hiding Racing Game...\n")
	
	# Hide racing container
	var racing_container = get_node_or_null("racing_game_container")
	if racing_container:
		racing_container.visible = false
	
	# Show menu container
	var menu_container = get_node_or_null("akashic_records")
	if menu_container:
		menu_container.visible = true
	
	# Restore camera position
	var camera = get_node_or_null("camera")
	if camera:
		if camera.has_meta("previous_position") and camera.has_meta("previous_rotation"):
			camera.global_position = camera.get_meta("previous_position")
			camera.global_rotation = camera.get_meta("previous_rotation")
	
	print("Returned to main menu")
	
	var container_name = "racing_game_container"
	var container_node = get_node_or_null(container_name)
	
	if container_node:
		container_node.visible = false
		print("Racing game hidden")
	
	# Restore camera position
	restore_camera_position()
	
	# Restore normal input handling
	restore_normal_input_handling()
	
	# Show menu again
	menu_container = get_node_or_null("akashic_records")
	if menu_container:
		menu_container.visible = true



# as one number is known in that center,s of containers
# we can now work on container and add a lot of things to everything with ideas and connections and class files
# we must stitch and patch stuff with lists of files, scripts, nodes, names, paths, connections


# version of letter or number can change, but is the same most of the time or shifts
# we need translations chambers for words and its connections too
# lists, times, durations, frequency in durations

# net, list, group
# search find, connect
# load store check

# the firewall walks in both ways at the same time

# virus is the observer of ones creation, a mirror can go wrong ways in both directions
# show me whats new in any of you digital warriors and i see ways
# in time, as words appear and here is code of change, change means in time the same as in duration and slight change
# morse code of change is amount of tasks, repeat cores too and threads, queue is barbarian way of making working sink, as we just knew up until

# which point in time is end, so we limit duration of script and combo, as you are up to 2k of code, i have like 7k working code, plus few files of
# 2k, 5k, 1k, and few files

# we need one last file, the data pack
# something that never mattered and was just a txt file that is any file, we just repeat something somewhere somehow?
