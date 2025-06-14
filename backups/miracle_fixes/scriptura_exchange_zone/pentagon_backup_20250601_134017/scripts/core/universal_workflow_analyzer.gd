# Universal Workflow Analyzer - Maps ALL Possibilities
# Traces every path, every function, every connection
# Helps combine duplicate files into perfect unified versions
extends UniversalBeingBase
class_name UniversalWorkflowAnalyzer

# Complete workflow mapping
var all_scripts: Dictionary = {}  # script_path -> script_data
var all_functions: Dictionary = {}  # function_name -> [script_paths]
var all_variables: Dictionary = {}  # var_name -> [script_paths]
var execution_flows: Dictionary = {}  # entry_point -> possible_paths
var duplicate_functionality: Dictionary = {}  # purpose -> [script_paths]

# Analysis results
var workflow_graph: Dictionary = {}
var combination_candidates: Array = []
var optimization_suggestions: Array = []

signal analysis_complete()
signal duplicate_found(purpose: String, files: Array)
signal combination_suggested(files: Array, reason: String)

func _ready():
	print("🔍 [WorkflowAnalyzer] Starting complete project analysis...")
	await analyze_entire_project()

# Analyze the entire project structure

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
func analyze_entire_project():
	# Step 1: Scan all GDScript files
	await _scan_all_scripts()
	
	# Step 2: Map all execution flows
	_map_execution_flows()
	
	# Step 3: Find duplicate functionality
	_find_duplicates()
	
	# Step 4: Generate combination suggestions
	_suggest_combinations()
	
	# Step 5: Create workflow visualization
	_generate_workflow_graph()
	
	emit_signal("analysis_complete")
	
	# Generate report
	var report = generate_complete_report()
	print(report)

# Scan all scripts in the project
func _scan_all_scripts():
	var dir = DirAccess.open("res://scripts")
	if not dir:
		return
		
	_scan_directory_recursive(dir, "res://scripts")

func _scan_directory_recursive(dir: DirAccess, path: String):
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			var subdir = DirAccess.open(full_path)
			if subdir:
				_scan_directory_recursive(subdir, full_path)
		elif file_name.ends_with(".gd"):
			_analyze_script(full_path)
		
		file_name = dir.get_next()

# Analyze individual script
func _analyze_script(script_path: String):
	var script_data = {
		"path": script_path,
		"purpose": _determine_purpose(script_path),
		"functions": [],
		"variables": [],
		"signals": [],
		"dependencies": [],
		"calls_to": [],
		"called_by": []
	}
	
	# Parse script content
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return
		
	var content = file.get_as_text()
	file.close()
	
	# Extract functions
	var func_regex = RegEx.new()
	func_regex.compile("func\\s+(\\w+)\\s*\\(")
	for match in func_regex.search_all(content):
		var func_name = match.get_string(1)
		script_data.functions.append(func_name)
		
		# Track function locations
		if not func_name in all_functions:
			all_functions[func_name] = []
		all_functions[func_name].append(script_path)
	
	# Extract variables
	var var_regex = RegEx.new()
	var_regex.compile("(?:var|@export|@onready)\\s+(?:var\\s+)?(\\w+)")
	for match in var_regex.search_all(content):
		var var_name = match.get_string(1)
		script_data.variables.append(var_name)
		
		# Track variable locations
		if not var_name in all_variables:
			all_variables[var_name] = []
		all_variables[var_name].append(script_path)
	
	# Extract signals
	var signal_regex = RegEx.new()
	signal_regex.compile("signal\\s+(\\w+)")
	for match in signal_regex.search_all(content):
		script_data.signals.append(match.get_string(1))
	
	# Extract dependencies (load/preload)
	var dep_regex = RegEx.new()
	dep_regex.compile("(?:load|preload)\\s*\\(\\s*[\"'](res://[^\"']+)[\"']")
	for match in dep_regex.search_all(content):
		script_data.dependencies.append(match.get_string(1))
	
	# Store analyzed data
	all_scripts[script_path] = script_data

# Determine script purpose from path and name
func _determine_purpose(script_path: String) -> String:
	var file_name = script_path.get_file().get_basename()
	var folder = script_path.get_base_dir().get_file()
	
	# Categorize by name patterns
	if "universal" in file_name:
		return "universal_entity_system"
	elif "floodgate" in file_name:
		return "flow_control"
	elif "console" in file_name:
		return "console_interface"
	elif "ragdoll" in file_name:
		return "physics_entity"
	elif "manager" in file_name:
		return "system_management"
	elif "controller" in file_name:
		return "flow_control"
	elif "helper" in file_name:
		return "utility"
	elif "test" in file_name:
		return "testing"
	elif "debug" in file_name:
		return "debugging"
	elif "ui" in folder or "interface" in file_name:
		return "user_interface"
	else:
		return "general"

# Map all execution flows
func _map_execution_flows():
	# Common entry points
	var entry_points = [
		"_ready", "_process", "_physics_process", "_input",
		"console_command", "spawn_entity", "load_scene"
	]
	
	for entry in entry_points:
		if entry in all_functions:
			execution_flows[entry] = _trace_execution_path(entry)

# Trace execution path from entry point
func _trace_execution_path(func_name: String, visited: Array = []) -> Array:
	if func_name in visited:
		return []  # Avoid infinite recursion
		
	visited.append(func_name)
	var paths = []
	
	# Find all scripts containing this function
	if func_name in all_functions:
		for script_path in all_functions[func_name]:
			var script_data = all_scripts.get(script_path, {})
			
			# Add all functions this script might call
			for other_func in script_data.get("functions", []):
				if other_func != func_name:
					paths.append(other_func)
					# Recursively trace
					paths.append_array(_trace_execution_path(other_func, visited.duplicate()))
	
	return paths

# Find duplicate functionality
func _find_duplicates():
	# Group scripts by purpose
	var purpose_groups = {}
	
	for script_path in all_scripts:
		var purpose = all_scripts[script_path].purpose
		if not purpose in purpose_groups:
			purpose_groups[purpose] = []
		purpose_groups[purpose].append(script_path)
	
	# Find groups with multiple scripts
	for purpose in purpose_groups:
		if purpose_groups[purpose].size() > 1:
			duplicate_functionality[purpose] = purpose_groups[purpose]
			emit_signal("duplicate_found", purpose, purpose_groups[purpose])

# Suggest combinations
func _suggest_combinations():
	# Universal entity files
	if all_functions.has("become"):
		var universal_files = []
		for script_path in all_scripts:
			if "universal" in script_path and not "test" in script_path:
				universal_files.append(script_path)
		
		if universal_files.size() > 1:
			var suggestion = {
				"files": universal_files,
				"reason": "Multiple universal entity implementations",
				"main_file": "universal_being_unified.gd",
				"combine_strategy": "merge_features"
			}
			combination_candidates.append(suggestion)
			emit_signal("combination_suggested", universal_files, suggestion.reason)
	
	# Floodgate files
	if all_functions.has("queue_operation"):
		var floodgate_files = []
		for script_path in all_scripts:
			if "floodgate" in script_path:
				floodgate_files.append(script_path)
		
		if floodgate_files.size() > 1:
			var suggestion = {
				"files": floodgate_files,
				"reason": "Multiple floodgate implementations",
				"main_file": "floodgate_unified_controller.gd",
				"combine_strategy": "unified_queue"
			}
			combination_candidates.append(suggestion)
			emit_signal("combination_suggested", floodgate_files, suggestion.reason)
	
	# Manager files
	var manager_files = []
	for script_path in all_scripts:
		if "manager" in script_path and not "test" in script_path:
			manager_files.append(script_path)
	
	if manager_files.size() > 3:
		var suggestion = {
			"files": manager_files,
			"reason": "Too many separate managers",
			"main_file": "universal_system_manager.gd",
			"combine_strategy": "hierarchical_management"
		}
		combination_candidates.append(suggestion)
		emit_signal("combination_suggested", manager_files, suggestion.reason)

# Generate workflow graph
func _generate_workflow_graph():
	workflow_graph = {
		"entry_points": {},
		"core_systems": {},
		"connections": [],
		"data_flow": []
	}
	
	# Map entry points
	workflow_graph.entry_points = {
		"user_input": ["ConsoleManager._input", "BryceGrid._gui_input"],
		"system_start": ["_ready functions in autoloads"],
		"frame_update": ["_process", "_physics_process"],
		"console_commands": ["ConsoleManager.execute_command"]
	}
	
	# Map core systems
	workflow_graph.core_systems = {
		"universal_entity": {
			"files": _get_files_with_substring("universal"),
			"main_functions": ["become", "evolve", "connect_to_being"],
			"purpose": "Core entity that can be anything"
		},
		"floodgate": {
			"files": _get_files_with_substring("floodgate"),
			"main_functions": ["queue_operation", "process_queue"],
			"purpose": "Control flow and operation queuing"
		},
		"console": {
			"files": _get_files_with_substring("console"),
			"main_functions": ["execute_command", "register_command"],
			"purpose": "User interaction interface"
		}
	}
	
	# Map connections between systems
	workflow_graph.connections = [
		{"from": "console", "to": "floodgate", "via": "execute_command"},
		{"from": "floodgate", "to": "universal_entity", "via": "create_node"},
		{"from": "universal_entity", "to": "console", "via": "status_update"}
	]

# Helper to get files containing substring
func _get_files_with_substring(substring: String) -> Array:
	var files = []
	for script_path in all_scripts:
		if substring in script_path:
			files.append(script_path)
	return files

# Generate complete analysis report
func generate_complete_report() -> String:
	var report = "\n🌟 UNIVERSAL WORKFLOW ANALYSIS REPORT 🌟\n"
	report += "=".repeat(50) + "\n\n"
	
	# Summary
	report += "PROJECT SUMMARY:\n"
	report += "  Total Scripts: " + str(all_scripts.size()) + "\n"
	report += "  Total Functions: " + str(all_functions.size()) + "\n"
	report += "  Total Variables: " + str(all_variables.size()) + "\n"
	report += "  Duplicate Groups: " + str(duplicate_functionality.size()) + "\n\n"
	
	# Duplicate functionality
	report += "DUPLICATE FUNCTIONALITY FOUND:\n"
	for purpose in duplicate_functionality:
		report += "\n  " + purpose.to_upper() + ":\n"
		for file_path in duplicate_functionality[purpose]:
			var script_data = all_scripts.get(file_path, {})
			report += "    - " + file_path.get_file() + "\n"
			report += "      Functions: " + str(script_data.get("functions", [])) + "\n"
	
	# Combination suggestions
	report += "\nSUGGESTED COMBINATIONS:\n"
	for suggestion in combination_candidates:
		report += "\n  Main File: " + str(suggestion.get("main_file", "")) + "\n"
		report += "  Reason: " + str(suggestion.get("reason", "")) + "\n"
		report += "  Files to combine:\n"
		for file_path in suggestion.get("files", []):
			report += "    - " + str(file_path) + "\n"
		report += "  Strategy: " + str(suggestion.get("combine_strategy", "")) + "\n"
	
	# Execution flows
	report += "\nMAIN EXECUTION FLOWS:\n"
	for entry_point in execution_flows:
		report += "  " + entry_point + " → "
		var paths = execution_flows[entry_point]
		if paths.size() > 0:
			report += str(paths.slice(0, min(5, paths.size())))
			if paths.size() > 5:
				report += " ... (" + str(paths.size() - 5) + " more)"
		report += "\n"
	
	# Functions appearing in multiple files
	report += "\nFUNCTIONS IN MULTIPLE FILES:\n"
	for func_name in all_functions:
		if all_functions[func_name].size() > 1:
			report += "  " + func_name + ":\n"
			for script_path in all_functions[func_name]:
				report += "    - " + script_path + "\n"
	
	return report

# Generate combination script
func generate_combination_script(suggestion: Dictionary) -> String:
	var script = "# UNIFIED " + str(suggestion.get("main_file", "")).to_upper() + "\n"
	script += "# Combined from: " + str(suggestion.get("files", [])) + "\n"
	script += "# Reason: " + str(suggestion.get("reason", "")) + "\n\n"
	
	script += "extends Node\n\n"
	
	# Collect all unique functions
	var all_funcs = {}
	var all_vars = {}
	var all_sigs = []
	
	for file_path in suggestion.get("files", []):
		var script_data = all_scripts.get(file_path, {})
		
		# Collect functions
		for func_name in script_data.get("functions", []):
			if not func_name in all_funcs:
				all_funcs[func_name] = file_path
		
		# Collect variables
		for var_name in script_data.get("variables", []):
			if not var_name in all_vars:
				all_vars[var_name] = file_path
		
		# Collect signals
		all_sigs.append_array(script_data.get("signals", []))
	
	# Generate unified script structure
	script += "# Signals\n"
	for sig in all_sigs:
		script += "signal " + sig + "\n"
	
	script += "\n# Variables\n"
	for var_name in all_vars:
		script += "var " + var_name + "  # From: " + all_vars[var_name] + "\n"
	
	script += "\n# Functions\n"
	for func_name in all_funcs:
		script += "func " + func_name + "():\n"
		script += "\t# Implementation from: " + all_funcs[func_name] + "\n"
		script += "\tpass\n\n"
	
	return script