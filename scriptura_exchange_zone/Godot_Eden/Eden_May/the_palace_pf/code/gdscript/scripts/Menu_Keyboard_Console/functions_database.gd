# functions_database.gd
extends Node

class_name FunctionChainManager

var registered_commands = {}
var command_chains = {}
var priority_queue = []
var execution_history = []

func register_command(command_name: String, target_node: Node, function_name: String):
	registered_commands[command_name] = {
		"target": target_node,
		"function": function_name,
		"last_execution": 0,
		"execution_count": 0
	}

func create_chain(chain_name: String, commands: Array):
	command_chains[chain_name] = {
		"commands": commands,
		"status": "ready",
		"last_execution": 0
	}

func execute_chain(chain_name: String, args = null):
	if not command_chains.has(chain_name):
		return {"success": false, "message": "Chain not found"}
	
	var chain = command_chains[chain_name]
	var results = []
	
	for cmd in chain.commands:
		if not registered_commands.has(cmd):
			results.append({"command": cmd, "success": false, "message": "Command not found"})
			continue
			
		var command_data = registered_commands[cmd]
		var target = command_data.target
		var function = command_data.function
		
		var result
		if args != null:
			result = target.call(function, args)
		else:
			result = target.call(function)
			
		results.append({
			"command": cmd,
			"success": true,
			"result": result
		})
		
		command_data.last_execution = Time.get_ticks_msec()
		command_data.execution_count += 1
	
	chain.last_execution = Time.get_ticks_msec()
	execution_history.append({
		"chain": chain_name,
		"time": Time.get_ticks_msec(),
		"results": results
	})
	
	return {"success": true, "results": results}


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


# Track function relationships
var function_dependencies = {}
var function_call_graph = {}
var shared_variables = {}



## new stuff starts here
# Function structure analysis
class FunctionAnalysis:
	var name: String
	var char_composition: Dictionary = {}  # Stores character type counts
	var parameter_count: int = 0
	var return_type: String = ""
	var body_length: int = 0
	
	func _init(func_name: String):
		name = func_name
		analyze_name()
	
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
