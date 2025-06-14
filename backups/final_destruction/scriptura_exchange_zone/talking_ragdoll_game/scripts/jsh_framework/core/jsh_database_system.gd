# 🏛️ Jsh Database System - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration


#

## jsh_database_system.gd

# jsh
# database
# system
# gd

# begining 100 tells us what we had what we wanna and what we can try to have as i check too and had 

# you will add to turs are messages like queue tasks turns start stop create new task

# so lets edit some too

## JSH_database_system

# JSH_database_system jsh_database_system
# code/gdscript/scripts/Menu_Keyboard_Console/
# JSH_Core/JSH_mainframe_database/

# res://code/gdscript/scripts/Menu_Keyboard_Console/jsh_database_system.gd

#

# JSH_Core/JSH_mainframe_database/JSH_database_system

extends UniversalBeingBase
#

var bank
var Connect
var connection
var data
var pack
var Edem
var point

#

var world
var player
var head

var apple
var snake
var space
var ship

var water
var fog
var shape
var grod
var launch
var space_ship
#

var nodes
var groups
var types

var functions
var ready_gd_script
var process
var input
var cs_script_sharp
var c_basic

var triggers
var switches
var buttons
var colors
var grids

var dictionary
var keys
var memories
var initialize

var load_paste
var create_new
var setup_copy
var move_rotate_destiny
var make_add

var load_folder
var setup_record
var path_finders

var time_limits
var turn_change
var queue_create

var mutex_checker
var pipes_paths_stacks_perspective
var dictionaries_arrays_strings_numbers_symbols
var rotation_position_local_global_scale_transform_3d_2d
var shape_net_connect_points_webs_eyes_things_numbers

var spider_points_amounts
var counter_calculation
var net_segment_command
var terminal_execute_cmd
var words_sets_record_measure
var mix_measure_control_set_rules
var folder_path_thing_path_point_destination

var start_stop_middle_behins_starts_continue
var pass_break_return_path
var stop_end_symbol_ned_frame
var data_base_point_network_net_container_line

var connect_path_bridge_tunnel
var tunnel_receive_transmit_rx_tx
var start_begin_point
var stop_end_thing
var connect_move_rotate

var data_move_stop
var archive_store_cache
var start_file_creation

var load_file_ram
var create_file_new
var store_file_rom

var combo_known
var combo_new
var combo_repeat
var combo_block
var combo_change

var switch_level_button_menu_settings_float
var switch_lewer_number_direction
var duality_trinity_plus_minus_center
var split_merge_direction

var connections = {}  # Stores which nodes are connected to which

# Track function relationships
var function_dependencies = {}
var function_call_graph = {}
var shared_variables = {}

var _settings_data: Dictionary

var _mutex = Mutex.new()


# Example line storage:
var line_storage = """
[HEADER]=[version=#0|type=dictionary|lines=10]|
[DATA]=[line_0=hello world|line_1={key:value}|line_2=[1,2,3]]|
[METADATA]=[previous=version_0|changes=added_lines|timestamp=1234]|
"""

var parse_stats = {
	"files_processed": 0,
	"successful_parses": 0,
	"failed_parses": 0,
	"total_blocks": 0,
	"mutex_states": {},
	"last_processed": ""
}


# Function relationships tracking
var relationships = {
	"call_graph": {},      # Who calls whom
	"shared_vars": {},     # Which functions share variables
	"mutex_groups": {}     # Which functions share mutexes
}
# Function Categories and Metadata
# Core Lifecycle Functions
var lifecycle_functions = {
	"_init": {
		"return_type": "void",
		"category": "lifecycle",
		"mutex_dependencies": []
	},
	"_ready": {
		"return_type": "void",
		"category": "lifecycle",
		"mutex_dependencies": []
	},
	"_process": {
		"return_type": "void",
		"category": "lifecycle",
		"mutex_dependencies": ["array_mutex_process"]
	}
}

# System Management Functions
var system_functions = {
	"check_system_state": {
		"return_type": "SystemState",
		"mutex_dependencies": ["core_states.mutex"],
		"category": "system"
	},
	"check_system_health": {
		"return_type": "Dictionary",
		"mutex_dependencies": ["dictionary_of_mistakes_mutex"],
		"category": "system"
	},
	"check_thread_status": {
		"return_type": "int",
		"mutex_dependencies": [],
		"category": "system"
	}
}

# Creation and Processing Functions
var creation_functions = {
	"three_stages_of_creation": {
		"return_type": "Dictionary",
		"mutex_dependencies": ["array_mutex_process"],
		"category": "creation"
	},
	"whip_out_set_by_its_name": {
		"return_type": "CreationStatus",
		"mutex_dependencies": ["array_mutex_process"],
		"category": "creation"
	}
}

# Memory Management Functions
var memory_functions = {
	"check_memory_state": {
		"return_type": "Dictionary",
		"mutex_dependencies": [],
		"category": "memory"
	},
	"get_data_structure_size": {
		"return_type": "int",
		"mutex_dependencies": [],
		"category": "memory"
	}
}

# Node Creation Functions
var node_functions = {
	"create_container": {
		"return_type": "Node",
		"mutex_dependencies": ["mutex_containers"],
		"category": "node_creation"
	},
	"create_datapoint": {
		"return_type": "Node",
		"mutex_dependencies": ["mutex_nodes_to_be_added"],
		"category": "node_creation"
	}
}

# Error Handling Functions
var error_functions = {
	"record_mistake": {
		"return_type": "void",
		"mutex_dependencies": ["dictionary_of_mistakes_mutex"],
		"category": "error"
	},
	"handle_random_errors": {
		"return_type": "Dictionary",
		"mutex_dependencies": ["dictionary_of_mistakes_mutex"],
		"category": "error"
	}
}

# Time Management Functions
var time_functions = {
	"calculate_time": {
		"return_type": "Dictionary",
		"mutex_dependencies": [],
		"category": "time"
	},
	"before_time_blimp": {
		"return_type": "void",
		"mutex_dependencies": [],
		"category": "time"
	}
}

# File Operations Functions
var file_functions = {
	"check_folder": {
		"return_type": "bool",
		"mutex_dependencies": [],
		"category": "file"
	},
	"file_creation": {
		"return_type": "bool",
		"mutex_dependencies": [],
		"category": "file"
	}
}
####

signal parsing_completed(stats: Dictionary)
signal error_detected(error: Dictionary)

const MAX_LINES_PER_BLOCK = 10
const MAX_WORDS_PER_LINE = 10

## additional add
# Basic character types

const CHAR_TYPES = {
	"UPPERCASE": 1,
	"LOWERCASE": 2,
	"NUMBER": 3,
	"SPECIAL": 4,
	"WHITESPACE": 5
}
##
const SPLIT_RULES = {
	"LEVEL_0": ["[", "]"],    # Main blocks
	"LEVEL_1": ["="],         # Section separators
	"LEVEL_2": ["|"],         # Data separators
	"LEVEL_3": [",", "."]     # Content separators
}
const STORAGE_RULES = {
	"MAX_LINE_LENGTH": 80,
	"MAX_FUNCTION_SIZE": 1000,
	"REQUIRED_TAGS": ["name", "version", "status"],
	"ALLOWED_SYMBOLS": ["[", "]", "=", "|", "#"]
}
const JSH_FILE_FORMAT = {
	"line_separator": "|",
	"block_start": "[",
	"block_end": "]",
	"dict_marker": "=",
	"version_marker": "#"
}
# Core function metadata blueprint
const FUNCTION_TEMPLATE = {
	"inputs": [],
	"return_type": "void",
	"category": "",
	"globals_used": [],
	"mutexes_used": [],
	"dependencies": [],
	"file_path": ""
}
# Standardized categories
const CATEGORIES = {
	"LIFECYCLE": "lifecycle",    # _init, _ready, _process
	"SYSTEM": "system",         # System checks and management
	"CREATION": "creation",     # Object/node creation
	"MEMORY": "memory",         # Memory management
	"ERROR": "error",          # Error handling
	"FILE": "file",            # File operations
	"TIME": "time"             # Time management
}
const MAIN_FUNCTIONS = {
	"_init": {
		"input_types": [],
		"return_type": "void",
		"required_mutexes": []
	},
	"_ready": {
		"input_types": [],
		"return_type": "void",
		"required_mutexes": []
	},
	"check_system_state": {
		"input_types": ["String"],
		"return_type": "SystemState",
		"required_mutexes": ["core_states.mutex"]
	}
}
# System check functions
const SYSTEM_CHECK_FUNCTIONS = {
	"verify_system": {
		"input_types": ["String"],
		"return_type": "Dictionary",
		"required_mutexes": ["system_health.mutex"]
	}
}
# Thread pool functions
const THREAD_POOL_FUNCTIONS = {
	"submit_task": {
		"input_types": ["String", "Variant"],
		"return_type": "bool",
		"required_mutexes": ["__tasks_lock"]
	}
}

#from Luminus
### Metadata for all functions categorized by their respective script files
const MAIN_GD = {
	"_init": {"input_types": [], "return_type": "void", "required_mutexes": []},
	"_ready": {"input_types": [], "return_type": "void", "required_mutexes": []},
	"check_system_state": {"input_types": ["String"], "return_type": "SystemState", "required_mutexes": ["core_states.mutex"]},
	"process_turn_0": {"input_types": ["float"], "return_type": "Dictionary", "required_mutexes": ["array_mutex_process"]}
}

const THREAD_POOL_GD = {
	"submit_task": {"input_types": ["String", "Variant"], "return_type": "bool", "required_mutexes": ["__tasks_lock"]},
	"update_thread_state": {"input_types": ["String", "String", "Variant"], "return_type": "void", "required_mutexes": ["__thread_state_mutex"]},
	"get_thread_stats": {"input_types": [], "return_type": "Dictionary", "required_mutexes": ["__thread_state_mutex"]}
}

const SYSTEM_CHECK_GD = {
	"verify_system": {"input_types": ["String"], "return_type": "Dictionary", "required_mutexes": ["system_health.mutex"]},
	"check_system_health": {"input_types": [], "return_type": "Dictionary", "required_mutexes": ["dictionary_of_mistakes_mutex"]},
	"check_memory_state": {"input_types": [], "return_type": "Dictionary", "required_mutexes": []}
}

const FILE_MANAGEMENT_GD = {
	"create_file": {"input_types": ["Array", "int", "String"], "return_type": "void", "required_mutexes": []},
	"check_settings_file": {"input_types": [], "return_type": "bool", "required_mutexes": []},
	"file_creation": {"input_types": ["Array", "String", "String"], "return_type": "bool", "required_mutexes": []}
}

const JSH_QUEUE_GD = {
	"three_stages_of_creation": {"input_types": ["String"], "return_type": "void", "required_mutexes": ["array_mutex_process"]},
	"check_currently_being_created_sets": {"input_types": [], "return_type": "void", "required_mutexes": ["mutex_for_container_state"]},
	"process_stages": {"input_types": [], "return_type": "void", "required_mutexes": ["array_mutex_process"]}
}

const HIDDEN_VEIL_GD = {
	"the_fourth_dimensional_magic": {"input_types": ["String", "Node", "Variant"], "return_type": "void", "required_mutexes": ["movmentes_mutex"]},
	"fifth_dimensional_magic": {"input_types": ["String", "String"], "return_type": "void", "required_mutexes": ["mutex_for_unloading_nodes"]},
	"sixth_dimensional_magic": {"input_types": ["String", "String", "String", "Variant"], "return_type": "void", "required_mutexes": ["mutex_function_call"]}
}
# Function metadata organized by file
const FUNCTIONS = {
	"main.gd": {
		"_init": {
			"inputs": [],
			"return_type": "void",
			"category": CATEGORIES.LIFECYCLE,
			"globals_used": [],
			"mutexes_used": [],
			"dependencies": []
		},
		"prepare_akashic_records": {
			"inputs": [],
			"return_type": "void",
			"category": CATEGORIES.SYSTEM,
			"globals_used": [
				"first_start_check",
				"array_of_startup_check"
			],
			"mutexes_used": [
				"breaks_and_handles_check",
				"check_thread_status"
			],
			"dependencies": [
				"BanksCombiner.dataSetLimits",
				"timer_system"
			]
		}
	},
	
	"system_check.gd": {
		"verify_system": {
			"inputs": ["String"],
			"return_type": "Dictionary",
			"category": CATEGORIES.SYSTEM,
			"globals_used": [],
			"mutexes_used": ["system_health.mutex"],
			"dependencies": []
		}
	},
	
	"thread_pool.gd": {
		"submit_task": {
			"inputs": ["String", "Variant"],
			"return_type": "bool",
			"category": CATEGORIES.SYSTEM,
			"globals_used": [],
			"mutexes_used": ["__tasks_lock"],
			"dependencies": []
		}
	}
}
const FUNCTION_METADATA = {
	"prepare_akashic_records": {
		"inputs": [],
		"return_type": "void",
		"globals_used": [
			"first_start_check",
			"array_of_startup_check"
		],
		"mutexes_used": [
			"breaks_and_handles_check",
			"check_thread_status"
		],
		"dependencies": [
			"BanksCombiner.dataSetLimits",
			"timer_system"
		]
	},
	
	"is_creation_possible": {
		"inputs": [],
		"return_type": "bool",
		"globals_used": [
			"thread_pool",
			"first_start_check",
			"max_nodes_added_per_cycle"
		],
		"mutexes_used": [
			"array_mutex_process",
			"mutex_for_container_state",
			"array_counting_mutex",
			"dictionary_of_mistakes_mutex"
		],
		"dependencies": []
	},
	
	"process_pending_sets": {
		"inputs": [],
		"return_type": "void", 
		"globals_used": [
			"array_of_startup_check",
			"list_of_sets_to_create"
		],
		"mutexes_used": [],
		"dependencies": [
			"three_stages_of_creation"
		]
	}
}



## new stuff starts here
# Function structure analysis

class FunctionAnalysis:
	var name: String
	var char_composition: Dictionary = {}  # Stores character type counts
	var parameter_count: int = 0
	var return_type: String = ""
	var body_length: int = 0
	
	func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	super.pentagon_init()
		name = func_name
		analyze_name()
	

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
	func analyze_name():
		char_composition.clear()
		for c in name:
			var char_type = get_char_type(c)
			if !char_composition.has(char_type):
				char_composition[char_type] = 0
			char_composition[char_type] += 1
	
	func get_char_type(c: String) -> int:
		var code = c.unicode_at(0)
		if code >= 65 and code <= 90:  # A-Z
			return CHAR_TYPES.UPPERCASE
		elif code >= 97 and code <= 122:  # a-z
			return CHAR_TYPES.LOWERCASE
		elif code >= 48 and code <= 57:  # 0-9
			return CHAR_TYPES.NUMBER
		elif code == 32 or code == 9:  # space or tab
			return CHAR_TYPES.WHITESPACE
		else:
			return CHAR_TYPES.SPECIAL

class FunctionDatabase:
	var functions: Dictionary = {}
	
	func add_function(func_text: String):
		var lines = func_text.split("\n")
		var func_declaration = lines[0]
		
		# Basic function signature parsing
		var func_name = extract_function_name(func_declaration)
		if func_name.is_empty():
			return
			
		var analysis = FunctionAnalysis.new(func_name)
		analysis.body_length = lines.size() - 1  # Exclude declaration line
		analysis.parameter_count = count_parameters(func_declaration)
		analysis.return_type = extract_return_type(func_declaration)
		
		functions[func_name] = analysis

	func extract_function_name(declaration: String) -> String:
		var func_start = declaration.find("func ") + 5
		var params_start = declaration.find("(")
		if func_start == -1 or params_start == -1:
			return ""
		return declaration.substr(func_start, params_start - func_start).strip_edges()

	func count_parameters(declaration: String) -> int:
		var params_start = declaration.find("(") + 1
		var params_end = declaration.find(")")
		if params_start == -1 or params_end == -1:
			return 0
		var params = declaration.substr(params_start, params_end - params_start).strip_edges()
		if params.is_empty():
			return 0
		return params.split(",").size()

	func extract_return_type(declaration: String) -> String:
		var arrow_pos = declaration.find("->")
		if arrow_pos == -1:
			return "void"
		var end_pos = declaration.find(":", arrow_pos)
		if end_pos == -1:
			end_pos = declaration.length()
		return declaration.substr(arrow_pos + 2, end_pos - (arrow_pos + 2)).strip_edges()

	func get_function_analysis(func_name: String) -> FunctionAnalysis:
		return functions.get(func_name)

	func print_analysis(func_name: String) -> String:
		var analysis = get_function_analysis(func_name)
		if not analysis:
			return "Function not found: " + func_name
			
		var report = "Function Analysis for: " + func_name + "\n"
		report += "Character Composition:\n"
		for char_type in analysis.char_composition:
			var type_name = get_type_name(char_type)
			report += "  %s: %d\n" % [type_name, analysis.char_composition[char_type]]
		report += "Parameters: %d\n" % analysis.parameter_count
		report += "Return Type: %s\n" % analysis.return_type
		report += "Body Length: %d lines\n" % analysis.body_length
		return report

	func get_type_name(type_code: int) -> String:
		for type_name in CHAR_TYPES:
			if CHAR_TYPES[type_name] == type_code:
				return type_name
		return "UNKNOWN"
		
		
##





## godot functions

############################

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Load settings on startup
	if SettingsBank:
		_settings_data = SettingsBank.check_all_settings_data()
		initialize_parser()





###############################
##
## no input, just return

func check_all_things():
	print(" JSH file parser check connection")
	return true

func initialize_parser() -> void:
	if _settings_data.is_empty():
		push_error("Settings data not available")
		return
		
	# Initialize mutex states tracking
	parse_stats.mutex_states = {
		"file_access": true,
		"parsing": true,
		"stats": true
	}
# Stats collection for system check integration

func collect_system_stats() -> Dictionary:
	return {
		"parser_status": {
			"active": parse_stats.files_processed > 0,
			"success_rate": float(parse_stats.successful_parses) / max(parse_stats.files_processed, 1),
			"mutex_states": parse_stats.mutex_states
		},
		"format_stats": {
			"total_blocks": parse_stats.total_blocks,
			"recent_file": parse_stats.last_processed
		}
	}
##########################

func get_parse_stats() -> Dictionary:
	_mutex.lock()
	var stats = parse_stats.duplicate()
	_mutex.unlock()
	return stats

##
##
##
##
############# functions with inputs
##
##
##
func register_node(node, identifier):
	if identifier not in connections:
		connections[identifier] = {"inputs": [], "outputs": []}

func connect_nodes(sender_id, receiver_id):
	# Ensure both nodes are registered
	if sender_id in connections and receiver_id in connections:
		connections[sender_id]["outputs"].append(receiver_id)
		connections[receiver_id]["inputs"].append(sender_id)

func send_signal(sender_id, action):
	if sender_id in connections:
		for receiver_id in connections[sender_id]["outputs"]:
			if receiver_id in connections:
				# Assuming each node has a method to receive actions
				connections[receiver_id].receive_action(action)

## functions with possible return
##
##
##
##

func get_function_metadata(script_path: String, function_name: String) -> Dictionary:
	if FUNCTIONS.has(script_path) and FUNCTIONS[script_path].has(function_name):
		return FUNCTIONS[script_path][function_name]
	return FUNCTION_TEMPLATE.duplicate()#

func get_category_functions(category: String) -> Array:
	var functions = []
	for script in FUNCTIONS:
		for func_name in FUNCTIONS[script]:
			if FUNCTIONS[script][func_name].category == category:
				functions.append({
					"script": script,
					"function": func_name,
					"metadata": FUNCTIONS[script][func_name]
				})
	return functions

func get_mutex_dependencies(script_path: String, function_name: String) -> Array:
	var metadata = get_function_metadata(script_path, function_name)
	return metadata.mutexes_used

func get_global_variables(script_path: String, function_name: String) -> Array:
	var metadata = get_function_metadata(script_path, function_name)
	return metadata.globals_used

func get_function_dependencies(script_path: String, function_name: String) -> Array:
	var metadata = get_function_metadata(script_path, function_name)
	return metadata.dependencies

func generate_report(script_path: String = "", category: String = "") -> String:
	var report = "JSH Function Report\n"
	report += "================\n\n"
	if !script_path.is_empty():
		report += "Script: " + script_path + "\n\n"
		if FUNCTIONS.has(script_path):
			for func_name in FUNCTIONS[script_path]:
				report += _generate_function_report(script_path, func_name)
	elif !category.is_empty():
		report += "Category: " + category + "\n\n"
		var funcs = get_category_functions(category)
		for f in funcs:
			report += _generate_function_report(f.script, f.function)
	return report

func _generate_function_report(script_path: String, function_name: String) -> String:
	var metadata = get_function_metadata(script_path, function_name)
	var report = "Function: " + function_name + "\n"
	report += "-" +  str((function_name.length() + 10)) + "\n" 
	report += "Category: " + metadata.category + "\n"
	report += "Return Type: " + metadata.return_type + "\n"
	if !metadata.inputs.is_empty():
		report += "Inputs: " + str(metadata.inputs) + "\n"
	if !metadata.globals_used.is_empty():
		report += "\nGlobals:\n"
		for g in metadata.globals_used:
			report += "- " + g + "\n"
	if !metadata.mutexes_used.is_empty():
		report += "\nMutexes:\n"
		for m in metadata.mutexes_used:
			report += "- " + m + "\n"
	if !metadata.dependencies.is_empty():
		report += "\nDependencies:\n"
		for d in metadata.dependencies:
			report += "- " + d + "\n"
	report += "\n"
	return report

func analyze_function_requirements(function_name: String) -> Dictionary:
	if !FUNCTION_METADATA.has(function_name):
		return {}
	var metadata = FUNCTION_METADATA[function_name]
	var requirements = {
		"missing_globals": [],
		"missing_mutexes": [],
		"missing_dependencies": []
	}
	# Check globals
	for global_var in metadata.globals_used:
		if !(global_var in get_parent()):
			requirements.missing_globals.append(global_var)
	# Check mutexes 
	for mutex in metadata.mutexes_used:
		if !(mutex in get_parent()):
			requirements.missing_mutexes.append(mutex)
	# Check dependencies
	for dep in metadata.dependencies:
		var node_path = NodePath(dep.split(".")[0])
		if !has_node(node_path):
			requirements.missing_dependencies.append(dep)
	return requirements

func check_function_compatibility(function_name: String) -> Dictionary:
	var metadata = FUNCTION_METADATA.get(function_name, {})
	if metadata.is_empty():
		return {"compatible": false, "reason": "No metadata found"}
	var result = {
		"compatible": true,
		"issues": [],
		"shared_vars": [],
		"mutex_conflicts": []
	}
	# Check for shared variable conflicts
	for var_name in metadata.globals_used:
		for other_func in FUNCTION_METADATA:
			if other_func != function_name:
				if var_name in FUNCTION_METADATA[other_func].globals_used:
					result.shared_vars.append({
						"variable": var_name,
						"shared_with": other_func
					})
	# Check for mutex conflicts
	for mutex in metadata.mutexes_used:
		for other_func in FUNCTION_METADATA:
			if other_func != function_name:
				if mutex in FUNCTION_METADATA[other_func].mutexes_used:
					result.mutex_conflicts.append({
						"mutex": mutex,
						"conflicts_with": other_func
					})
	# Check dependency chain
	var dep_chain = get_dependency_chain(function_name)
	if dep_chain.has_circular_dependency:
		result.compatible = false
		result.issues.append("Circular dependency detected")
	return result

func get_dependency_chain(function_name: String, chain: Array = []) -> Dictionary:
	var result = {
		"chain": chain.duplicate(),
		"has_circular_dependency": false
	}
	if function_name in chain:
		result.has_circular_dependency = true
		return result
	result.chain.append(function_name)
	if !FUNCTION_METADATA.has(function_name):
		return result
	for dep in FUNCTION_METADATA[function_name].dependencies:
		var dep_func = dep.split(".")[-1]
		if FUNCTION_METADATA.has(dep_func):
			var dep_result = get_dependency_chain(dep_func, result.chain)
			if dep_result.has_circular_dependency:
				result.has_circular_dependency = true
				break
	return result

func get_function_usage(var_name: String) -> Array:
	var using_functions = []
	for func_name in FUNCTION_METADATA:
		var metadata = FUNCTION_METADATA[func_name]
		if var_name in metadata.globals_used:
			using_functions.append(func_name)
	return using_functions

func generate_function_report(function_name: String) -> String:
	if !FUNCTION_METADATA.has(function_name):
		return "No metadata found for function: " + function_name
	var metadata = FUNCTION_METADATA[function_name]
	var report = "Function Analysis: " + function_name + "\n"
	report += "=" + str((function_name.length() + 18)) + "\n\n"
	report += "Inputs: " + ("None" if metadata.inputs.is_empty() else str(metadata.inputs)) + "\n"
	report += "Returns: " + metadata.return_type + "\n\n"
	report += "Global Variables Used:\n"
	for var_name in metadata.globals_used:
		report += "- " + var_name + "\n"
	report += "\nMutexes Required:\n"
	for mutex in metadata.mutexes_used:
		report += "- " + mutex + "\n"
	report += "\nDependencies:\n"
	for dep in metadata.dependencies:
		report += "- " + dep + "\n"
	var compatibility = check_function_compatibility(function_name)
	report += "\nCompatibility Check:\n"
	report += "- Compatible: " + str(compatibility.compatible) + "\n"
	if !compatibility.issues.is_empty():
		report += "- Issues Found:\n"
		for issue in compatibility.issues:
			report += "  * " + issue + "\n"
	return report

func process_directory(path: String = "") -> Dictionary:
	if path.is_empty() and _settings_data.has("directory_path"):
		path = _settings_data.directory_path
	var result = {
		"processed_files": [],
		"failed_files": [],
		"stats": parse_stats.duplicate()
	}
	_mutex.lock()
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.get_extension() == "txt":
				var full_path = path.path_join(file_name)
				if process_file(full_path):
					result.processed_files.append(file_name)
				else:
					result.failed_files.append(file_name)
			file_name = dir.get_next()
			
		dir.list_dir_end()
	_mutex.unlock()
	emit_signal("parsing_completed", result)
	return result

func process_file(file_path: String) -> bool:
	_mutex.lock()
	var success = false
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var parsed = parse_jsh_file(content)
			if !parsed.is_empty():
				update_parse_stats(true, file_path)
				success = true
			else:
				update_parse_stats(false, file_path)
	_mutex.unlock()
	return success

func update_parse_stats(success: bool, file_path: String) -> void:
	parse_stats.files_processed += 1
	if success:
		parse_stats.successful_parses += 1
	else:
		parse_stats.failed_parses += 1
	parse_stats.last_processed = file_path
# Enhanced JSH file parsing

func parse_jsh_file(content: String) -> Dictionary:
	var blocks = {}
	var current_block = ""
	var lines = content.split(JSH_FILE_FORMAT.line_separator)
	for line in lines:
		if line.is_empty():
			continue
		if line.begins_with(JSH_FILE_FORMAT.block_start):
			var parts = line.split(JSH_FILE_FORMAT.dict_marker)
			if parts.size() >= 2:
				current_block = parts[0].trim_prefix(JSH_FILE_FORMAT.block_start).trim_suffix(JSH_FILE_FORMAT.block_end)
				blocks[current_block] = {
					"content": [],
					"metadata": parse_block_metadata(parts[1])
				}
		elif current_block != "":
			if blocks.has(current_block):
				blocks[current_block].content.append(line)
	parse_stats.total_blocks = blocks.size()
	return blocks

func parse_block_metadata(metadata_str: String) -> Dictionary:
	var metadata = {}
	var parts = metadata_str.split(JSH_FILE_FORMAT.line_separator)
	for part in parts:
		var kv = part.split("=")
		if kv.size() == 2:
			metadata[kv[0].strip_edges()] = kv[1].strip_edges()
	return metadata
# Function for checking file format validity

func validate_file_format(content: String) -> Dictionary:
	var validation = {
		"valid": true,
		"errors": []
	}
	if !content.begins_with("[# JSH Ethereal Engine]"):
		validation.valid = false
		validation.errors.append("Missing JSH header")
	for rule in STORAGE_RULES.REQUIRED_TAGS:
		if !content.contains("[" + rule):
			validation.valid = false
			validation.errors.append("Missing required tag: " + rule)
	return validation

func analyze_file_content(content: String) -> Dictionary:
	var analysis = {
		"total_chars": content.length(),
		"char_counts": {},
		"symbol_counts": {},
		"word_counts": {},
		"splits": []
	}
	for c in content:
		if !analysis.char_counts.has(c):
			analysis.char_counts[c] = 0
		analysis.char_counts[c] += 1
	var splits = content.split("[")
	for split in splits:
		if split.contains("]"):
			analysis.splits.append(split.split("]")[0])
	return analysis

func split_by_rules(content: String, level: String) -> Array:
	var splits = []
	if SPLIT_RULES.has(level):
		for symbol in SPLIT_RULES[level]:
			splits.append_array(content.split(symbol))
	return splits
func parse_function_data(function_content: String) -> Dictionary:
	return {
		"name": get_function_name(function_content),
		"inputs": get_function_inputs(function_content),
		"content": get_function_body(function_content),
		"analysis": analyze_file_content(function_content)
	}
# Function parsing helpers

func get_function_name(function_content: String) -> String:
	var lines = function_content.split("\n")
	for line in lines:
		if line.begins_with("func "):
			# Remove 'func ' and everything after '('
			var name = line.substr(5).split("(")[0].strip_edges()
			return name
	return ""

func get_function_inputs(function_content: String) -> Array:
	var inputs = []
	var lines = function_content.split("\n")
	for line in lines:
		if line.begins_with("func "):
			# Get everything between ( and )
			var params = line.split("(")[1].split(")")[0]
			if params.strip_edges() != "":
				for param in params.split(","):
					var param_parts = param.strip_edges().split(":")
					inputs.append({
						"name": param_parts[0].strip_edges(),
						"type": param_parts[1].strip_edges() if param_parts.size() > 1 else "Variant"
					})
			break
	return inputs

func get_function_body(function_content: String) -> String:
	var lines = function_content.split("\n")
	var body = []
	var in_body = false
	
	for line in lines:
		if line.begins_with("func "):
			in_body = true
			continue
		if in_body:
			body.append(line)
	
	return "\n".join(body)
# Line processing

func process_with_limits(content: String) -> Dictionary:
	var processed = {
		"lines": [],
		"word_count": 0,
		"line_count": 0
	}
	
	var lines = content.split("\n")
	for line in lines:
		if processed.line_count >= MAX_LINES_PER_BLOCK:
			break
			
		var words = line.split(" ")
		if words.size() <= MAX_WORDS_PER_LINE:
			processed.lines.append(line)
			processed.word_count += words.size()
			processed.line_count += 1
			
	return processed
# Version tracking

func generate_ender_version(content: String) -> String:
	var lines = content.split("\n")
	var ender = []
	for line in lines:
		var stripped = line.strip_edges()
		if stripped != "":
			ender.append(stripped)
	return "\n".join(ender)

func compare_versions(old_content: String, new_content: String) -> Dictionary:
	var diff = {
		"added_lines": [],
		"removed_lines": [],
		"modified_lines": []
	}
	
	var old_blocks = parse_jsh_file(old_content)
	var new_blocks = parse_jsh_file(new_content)
	
	# Compare blocks
	for block in old_blocks:
		if new_blocks.has(block):
			# Compare lines within block
			var old_lines = old_blocks[block]
			var new_lines = new_blocks[block]
			for i in range(old_lines.size()):
				if old_lines[i] != new_lines[i]:
					diff.modified_lines.append([block, i, old_lines[i], new_lines[i]])
	
	return diff
