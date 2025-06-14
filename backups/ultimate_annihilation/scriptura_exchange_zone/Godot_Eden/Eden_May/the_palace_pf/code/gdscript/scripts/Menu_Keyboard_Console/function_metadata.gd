# function_metadata.gd
extends Node

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

# Function relationships tracking
var relationships = {
	"call_graph": {},      # Who calls whom
	"shared_vars": {},     # Which functions share variables
	"mutex_groups": {}     # Which functions share mutexes
}



const SCENE_TREE_BLUEPRINT = {
	"main_root": {
		"name": [],
		"type": [],
		"jsh_type": [],
		"branches": {},
		"status": "pending",  # pending/processing/complete, now i have pending, active, disabled
		"metadata": {
			"creation_time": 0,
			"priority": 0
		}
	}
}

const BRANCH_BLUEPRINT = {
	"name": [],
	"type": [],
	"jsh_type": [],
	"children": {},
	"parent": [],
	"status": "pending",
	"metadata": {
		"position": Vector3.ZERO,
		"rotation": Vector3.ZERO,
		"creation_order": 0
	}
}


# the two point o, jsh tree
const JSH_TREE = {
	"name": "",  # Root node name
	"type": "",  # Node type
	"status": "pending",
	"node": null,  # Node reference
	"nodes": {},  # All nodes by path
	"metadata": {
		"creation_time": 0,
		"position": Vector3.ZERO,
		"rotation": Vector3.ZERO,
		"collisions": [],  # Track collision related nodes
		"groups": [],
		"parent_path": "",
		"full_path": "",
		"creation_order": 0
	}
}


func get_function_metadata(script_path: String, function_name: String) -> Dictionary:
	if FUNCTIONS.has(script_path) and FUNCTIONS[script_path].has(function_name):
		return FUNCTIONS[script_path][function_name]
	return FUNCTION_TEMPLATE.duplicate()

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
