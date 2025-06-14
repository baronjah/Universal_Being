# ==================================================
# SCRIPT NAME: warning_scanner.gd  
# DESCRIPTION: Scans and reports all warnings
# PURPOSE: Identify patterns in 160+ warnings
# CREATED: 2025-05-25 - Warning analysis
# ==================================================

extends RefCounted

# Warning categories we've seen
static var WARNING_PATTERNS = {
	"UNUSED_PARAMETER": {
		"pattern": "The parameter '%s' is never used in the function",
		"count": 0,
		"files": {},
		"common_params": {}
	},
	"UNUSED_VARIABLE": {
		"pattern": "The local variable '%s' is declared but never used",
		"count": 0,
		"files": {},
		"common_vars": {}
	},
	"UNREACHABLE_CODE": {
		"pattern": "Unreachable code",
		"count": 0,
		"files": {}
	},
	"STANDALONE_EXPRESSION": {
		"pattern": "Standalone expression",
		"count": 0,
		"files": {}
	}
}

# Scan output from Godot and categorize warnings
static func parse_godot_output(output_text: String) -> Dictionary:
	var lines = output_text.split("\n")
	var results = {
		"total_warnings": 0,
		"by_type": {},
		"by_file": {},
		"most_common": []
	}
	
	for line in lines:
		if line.contains("WARNING:") or line.contains("Warning:"):
			results.total_warnings += 1
			_categorize_warning(line, results)
	
	# Analyze patterns
	_analyze_patterns(results)
	
	return results

# Categorize individual warning
static func _categorize_warning(warning_line: String, results: Dictionary) -> void:
	# Extract file path
	var file_match = RegEx.new()
	file_match.compile("res://[^:]+\\.gd")
	var file_result = file_match.search(warning_line)
	var file_path = file_result.get_string() if file_result else "unknown"
	
	# Track by file
	if not results.by_file.has(file_path):
		results.by_file[file_path] = []
	
	# Check warning type
	if warning_line.contains("is never used in the function"):
		# Extract parameter name
		var param_match = RegEx.new()
		param_match.compile("The parameter '([^']+)'")
		var param_result = param_match.search(warning_line)
		if param_result:
			var param_name = param_result.get_string(1)
			_track_unused_parameter(param_name, file_path, results)
			
	elif warning_line.contains("is declared but never used"):
		# Extract variable name
		var var_match = RegEx.new()
		var_match.compile("The local variable '([^']+)'")
		var var_result = var_match.search(warning_line)
		if var_result:
			var var_name = var_result.get_string(1)
			_track_unused_variable(var_name, file_path, results)
			
	elif warning_line.contains("Unreachable code"):
		_track_unreachable_code(file_path, results)
		
	results.by_file[file_path].append(warning_line)

# Track unused parameters
static func _track_unused_parameter(param_name: String, file_path: String, results: Dictionary) -> void:
	if not results.by_type.has("unused_parameters"):
		results.by_type["unused_parameters"] = {
			"count": 0,
			"instances": {},
			"by_name": {}
		}
	
	var tracker = results.by_type["unused_parameters"]
	tracker.count += 1
	
	# Track by parameter name
	if not tracker.by_name.has(param_name):
		tracker.by_name[param_name] = {
			"count": 0,
			"files": []
		}
	tracker.by_name[param_name].count += 1
	tracker.by_name[param_name].files.append(file_path)
	
	# Track by file
	if not tracker.instances.has(file_path):
		tracker.instances[file_path] = []
	tracker.instances[file_path].append(param_name)

# Track unused variables
static func _track_unused_variable(var_name: String, file_path: String, results: Dictionary) -> void:
	if not results.by_type.has("unused_variables"):
		results.by_type["unused_variables"] = {
			"count": 0,
			"instances": {},
			"by_name": {}
		}
	
	var tracker = results.by_type["unused_variables"]
	tracker.count += 1
	
	if not tracker.instances.has(file_path):
		tracker.instances[file_path] = []
	tracker.instances[file_path].append(var_name)

# Track unreachable code
static func _track_unreachable_code(file_path: String, results: Dictionary) -> void:
	if not results.by_type.has("unreachable_code"):
		results.by_type["unreachable_code"] = {
			"count": 0,
			"files": []
		}
	
	results.by_type["unreachable_code"].count += 1
	results.by_type["unreachable_code"].files.append(file_path)

# Analyze patterns and find most common issues
static func _analyze_patterns(results: Dictionary) -> void:
	# Find most common unused parameters
	if results.by_type.has("unused_parameters"):
		var params = results.by_type["unused_parameters"].by_name
		var param_list = []
		
		for param_name in params:
			param_list.append({
				"name": param_name,
				"count": params[param_name].count
			})
		
		param_list.sort_custom(func(a, b): return a.count > b.count)
		
		results.most_common = param_list.slice(0, 10)

# Generate fix script for common patterns
static func generate_fix_script(results: Dictionary) -> String:
	var script = "# Auto-generated fix script\n\n"
	
	# Most common unused parameters
	if results.by_type.has("unused_parameters"):
		script += "# Most common unused parameters:\n"
		for param_data in results.most_common:
			script += "# %s (appears %d times)\n" % [param_data.name, param_data.count]
		
		script += "\n# Files with most warnings:\n"
		var file_counts = {}
		for file_path in results.by_type["unused_parameters"].instances:
			file_counts[file_path] = results.by_type["unused_parameters"].instances[file_path].size()
		
		# Sort by count
		var sorted_files = file_counts.keys()
		sorted_files.sort_custom(func(a, b): return file_counts[a] > file_counts[b])
		
		for file_path in sorted_files.slice(0, 10):
			script += "# %s: %d warnings\n" % [file_path, file_counts[file_path]]
	
	return script

# Generate summary report
static func generate_report(results: Dictionary) -> String:
	var report = "=== WARNING ANALYSIS REPORT ===\n\n"
	
	report += "Total warnings: %d\n\n" % results.total_warnings
	
	# By type breakdown
	report += "By Type:\n"
	for warning_type in results.by_type:
		var count = results.by_type[warning_type].count
		report += "  %s: %d\n" % [warning_type.replace("_", " ").capitalize(), count]
	
	report += "\nMost Common Unused Parameters:\n"
	for i in range(min(10, results.most_common.size())):
		var param = results.most_common[i]
		report += "  %d. %s (%d occurrences)\n" % [i+1, param.name, param.count]
	
	# Files with most warnings
	report += "\nFiles with Most Warnings:\n"
	var file_warning_counts = {}
	for file_path in results.by_file:
		file_warning_counts[file_path] = results.by_file[file_path].size()
	
	var sorted_files = file_warning_counts.keys()
	sorted_files.sort_custom(func(a, b): return file_warning_counts[a] > file_warning_counts[b])
	
	for i in range(min(10, sorted_files.size())):
		var file_path = sorted_files[i]
		report += "  %s: %d warnings\n" % [file_path, file_warning_counts[file_path]]
	
	return report

# Quick fix suggestions based on parameter name
static func suggest_fix(param_name: String) -> String:
	var common_fixes = {
		"delta": "Common in _process/_physics_process, safe to prefix with _",
		"event": "Common in input handlers, prefix with _ if not using event data",
		"body": "Common in collision callbacks, prefix with _ if not checking what collided",
		"area": "Common in area detection, prefix with _ if not using area info",
		"viewport": "Common in viewport callbacks, usually safe to prefix with _",
		"control": "Common in GUI callbacks, prefix with _ if not using control reference"
	}
	
	if common_fixes.has(param_name):
		return common_fixes[param_name]
	else:
		return "Consider if parameter is needed for interface compatibility"

# Test the scanner
static func test_scan() -> void:
	var sample_output = """
res://scripts/core/talking_ragdoll.gd:45 - Warning: The parameter 'delta' is never used in the function '_process'.
res://scripts/core/talking_ragdoll.gd:120 - Warning: The parameter 'body' is never used in the function '_on_body_entered'.
res://scripts/ui/console.gd:88 - Warning: The parameter 'event' is never used in the function '_gui_input'.
res://scripts/ui/console.gd:95 - Warning: The local variable 'temp' is declared but never used.
res://scripts/core/game_manager.gd:200 - Warning: Unreachable code after return statement.
"""
	
	var results = parse_godot_output(sample_output)
	print(generate_report(results))

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