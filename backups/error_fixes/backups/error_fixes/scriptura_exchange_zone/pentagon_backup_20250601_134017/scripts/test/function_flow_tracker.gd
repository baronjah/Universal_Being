# ==================================================
# SCRIPT NAME: function_flow_tracker.gd
# DESCRIPTION: Tracks function calls and execution paths
# PURPOSE: Document and test all function flows in the project
# CREATED: 2025-05-25 - Learning from our fixes
# ==================================================

extends UniversalBeingBase
# Track all function calls
var function_call_stack: Array = []
var function_history: Array = []
var error_fixes_applied: Dictionary = {}
var floodgate_triggers: Dictionary = {}

# Common error patterns we've learned
var known_error_patterns = {
	"preload_path_error": {
		"pattern": "Preload file .* does not exist",
		"fix": "Update path from D: drive structure to local project structure",
		"example": "res://code/gdscript/ → res://scripts/jsh_framework/"
	},
	"node_path_error": {
		"pattern": "Node not found: \"/root/main\"",
		"fix": "Use get_tree().current_scene instead of hardcoded /root/main",
		"example": "get_node('/root/main') → get_tree().current_scene"
	},
	"static_function_error": {
		"pattern": "Cannot call non-static function .* from static function",
		"fix": "Either make function non-static or use Engine.get_main_loop()",
		"example": "static func → func, or use tree.root.get_node_or_null()"
	},
	"empty_to_is_empty": {
		"pattern": "Cannot find member \"empty\" in base \"String\"",
		"fix": "Change empty() to is_empty() for Godot 4",
		"example": "if string.empty(): → if string.is_empty():"
	},
	"autoload_naming": {
		"pattern": "Class .* hides an autoload singleton",
		"fix": "Rename class to avoid conflict with autoload name",
		"example": "class_name JSHConsole → class_name JSHConsoleSystem"
	}
}

# Track function execution paths

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

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
func trace_function_call(script_name: String, function_name: String, params: Array = []) -> void:
	var trace = {
		"script": script_name,
		"function": function_name,
		"params": params,
		"timestamp": Time.get_ticks_msec(),
		"stack_depth": function_call_stack.size()
	}
	
	function_call_stack.push_back(trace)
	function_history.append(trace)
	
	# Check for floodgate triggers
	_check_floodgate_trigger(script_name, function_name)

func trace_function_return(script_name: String, function_name: String, return_value = null) -> void:
	if function_call_stack.is_empty():
		return
	
	var last_call = function_call_stack.back()
	if last_call.script == script_name and last_call.function == function_name:
		function_call_stack.pop_back()
		
		# Record the complete execution
		last_call["return_value"] = return_value
		last_call["duration"] = Time.get_ticks_msec() - last_call.timestamp

# Document floodgate triggers
func _check_floodgate_trigger(script_name: String, function_name: String) -> void:
	# Known floodgate trigger points from the project
	var triggers = {
		"floodgate_controller.gd": {
			"add_to_gate": "Controls object spawning limits",
			"check_gate_status": "Monitors current gate state",
			"release_from_gate": "Allows new objects to spawn"
		},
		"console_manager.gd": {
			"execute_command": "User input triggers actions",
			"_cmd_create": "Spawning triggers floodgate check"
		},
		"world_builder.gd": {
			"spawn_object": "Creates objects through floodgate",
			"remove_object": "Updates floodgate counts"
		}
	}
	
	if triggers.has(script_name) and triggers[script_name].has(function_name):
		var trigger_info = {
			"script": script_name,
			"function": function_name,
			"description": triggers[script_name][function_name],
			"timestamp": Time.get_ticks_msec()
		}
		
		if not floodgate_triggers.has(script_name):
			floodgate_triggers[script_name] = {}
		floodgate_triggers[script_name][function_name] = trigger_info

# Generate execution path report
func generate_flow_report() -> String:
	var report = "=== FUNCTION FLOW REPORT ===\n\n"
	
	# Most called functions
	var call_counts = {}
	for trace in function_history:
		var key = trace.script + "::" + trace.function
		call_counts[key] = call_counts.get(key, 0) + 1
	
	report += "TOP CALLED FUNCTIONS:\n"
	var sorted_calls = []
	for key in call_counts:
		sorted_calls.append([key, call_counts[key]])
	sorted_calls.sort_custom(func(a, b): return a[1] > b[1])
	
	for i in min(10, sorted_calls.size()):
		report += "  %s - %d calls\n" % [sorted_calls[i][0], sorted_calls[i][1]]
	
	# Floodgate triggers
	report += "\nFLOODGATE TRIGGERS:\n"
	for script in floodgate_triggers:
		for function in floodgate_triggers[script]:
			var trigger = floodgate_triggers[script][function]
			report += "  %s::%s - %s\n" % [script, function, trigger.description]
	
	# Error patterns encountered
	report += "\nERROR PATTERNS DOCUMENTED:\n"
	for pattern_name in known_error_patterns:
		var pattern = known_error_patterns[pattern_name]
		report += "  %s:\n" % pattern_name
		report += "    Pattern: %s\n" % pattern.pattern
		report += "    Fix: %s\n" % pattern.fix
		report += "    Example: %s\n" % pattern.example
	
	return report

# Test a complete execution path
func test_execution_path(path_name: String) -> Dictionary:
	var test_paths = {
		"spawn_ragdoll": [
			["console_manager.gd", "_cmd_spawn_ragdoll", []],
			["world_builder.gd", "spawn_ragdoll", []],
			["floodgate_controller.gd", "add_to_gate", ["ragdoll"]],
			["asset_library.gd", "get_ragdoll_scene", []],
			["talking_ragdoll.gd", "_ready", []]
		],
		"create_tree": [
			["console_manager.gd", "_cmd_create_tree", []],
			["world_builder.gd", "create_tree", []],
			["floodgate_controller.gd", "check_gate_status", ["trees"]],
			["asset_library.gd", "get_tree_models", []]
		]
	}
	
	if not test_paths.has(path_name):
		return {"success": false, "error": "Unknown test path"}
	
	var path = test_paths[path_name]
	var results = {"success": true, "steps": []}
	
	for step in path:
		var script = step[0]
		var function = step[1] 
		var params = step[2]
		
		trace_function_call(script, function, params)
		
		var step_result = {
			"script": script,
			"function": function,
			"params": params,
			"status": "tested"
		}
		
		results.steps.append(step_result)
		
		# Simulate function completion
		trace_function_return(script, function, "test_return")
	
	return results

# Record a fix that was applied
func record_fix_applied(error_type: String, file_path: String, fix_description: String) -> void:
	if not error_fixes_applied.has(error_type):
		error_fixes_applied[error_type] = []
	
	error_fixes_applied[error_type].append({
		"file": file_path,
		"fix": fix_description,
		"timestamp": Time.get_ticks_msec()
	})

# Simulate complete program flow
func simulate_user_action(action: String) -> Array:
	var simulation_paths = {
		"press_f1": [
			"Input system detects F1",
			"console_manager.gd::_input()",
			"console_manager.gd::toggle_console()",
			"UI updates visibility",
			"Console ready for input"
		],
		"type_tree_command": [
			"User types 'tree'",
			"console_manager.gd::_on_input_submitted()",
			"console_manager.gd::execute_command()",
			"console_manager.gd::_parse_command()",
			"console_manager.gd::_cmd_create_tree()",
			"world_builder.gd::create_tree()",
			"floodgate_controller.gd::request_spawn()",
			"asset_library.gd::get_tree_models()",
			"Tree spawned in world"
		],
		"drag_ragdoll": [
			"Mouse button pressed",
			"talking_ragdoll.gd::_input()",
			"Calculate mouse world position",
			"Check distance to ragdoll",
			"Set is_being_dragged = true",
			"talking_ragdoll.gd::_physics_process()",
			"Apply force toward mouse",
			"Update speech bubble",
			"Ragdoll follows mouse"
		]
	}
	
	return simulation_paths.get(action, ["Unknown action"])

# Generate test recommendations
func get_test_recommendations() -> Array:
	var recommendations = []
	
	# Based on function history
	if function_history.size() > 100:
		recommendations.append("High activity detected - consider performance profiling")
	
	# Based on error patterns
	for pattern in known_error_patterns:
		recommendations.append("Check all files for: " + pattern)
	
	# Based on floodgate triggers
	if floodgate_triggers.size() > 0:
		recommendations.append("Test floodgate limits with stress testing")
	
	return recommendations