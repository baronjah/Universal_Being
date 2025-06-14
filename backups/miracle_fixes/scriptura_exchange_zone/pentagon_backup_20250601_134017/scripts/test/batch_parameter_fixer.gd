# ==================================================
# SCRIPT NAME: batch_parameter_fixer.gd
# DESCRIPTION: Batch fixes common unused parameters
# PURPOSE: Quickly fix the 160+ warnings
# CREATED: 2025-05-25 - Batch processing
# ==================================================

extends RefCounted

# Common patterns that are safe to auto-fix
static var SAFE_TO_PREFIX = {
	# Godot built-in callbacks
	"_process": ["delta"],
	"_physics_process": ["delta"],
	"_input": ["event"],
	"_unhandled_input": ["event"], 
	"_gui_input": ["event"],
	"_on_body_entered": ["body"],
	"_on_body_exited": ["body"],
	"_on_area_entered": ["area"],
	"_on_area_exited": ["area"],
	"_on_mouse_entered": [],
	"_on_mouse_exited": [],
	"_draw": [],
	"_notification": ["what"],
	
	# Common signal patterns
	"_on_.*_pressed": [],  # Button signals rarely use parameters
	"_on_.*_toggled": ["pressed"],
	"_on_.*_value_changed": ["value"],
	"_on_.*_text_changed": ["new_text"],
	"_on_.*_item_selected": ["index"],
	"_on_.*_timeout": [],
	
	# JSH Framework patterns
	"register_command": ["args"],
	"execute_command": ["context"],
	"on_thread_completed": ["result"],
}

# Track changes for reporting
static var changes_log = []

# Fix a single file
static func fix_file(file_path: String, dry_run: bool = false) -> Dictionary:
	var result = {
		"success": false,
		"changes": [],
		"error": ""
	}
	
	# Read file
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		result.error = "Cannot read file: " + file_path
		return result
		
	var lines = []
	while not file.eof_reached():
		lines.append(file.get_line())
	file.close()
	
	# Process lines
	var modified = false
	for i in range(lines.size()):
		var line = lines[i]
		var fixed_line = _process_line(line, file_path)
		if fixed_line != line:
			lines[i] = fixed_line
			modified = true
			result.changes.append({
				"line": i + 1,
				"old": line,
				"new": fixed_line
			})
	
	# Write changes
	if modified and not dry_run:
		file = FileAccess.open(file_path, FileAccess.WRITE)
		if file:
			for line in lines:
				file.store_line(line)
			file.close()
			result.success = true
		else:
			result.error = "Cannot write to file: " + file_path
	elif dry_run:
		result.success = true
		
	return result

# Process a single line
static func _process_line(line: String, file_path: String) -> String:
	# Skip if already processed (has underscore prefix)
	if line.contains("func ") and line.contains("("):
		# Extract function signature
		var func_regex = RegEx.new()
		func_regex.compile("^(\\s*)func\\s+(\\w+)\\s*\\(([^)]*)\\)(.*)")
		var match = func_regex.search(line)
		
		if match:
			var indent = match.get_string(1)
			var func_name = match.get_string(2)
			var params = match.get_string(3)
			var rest = match.get_string(4)
			
			# Check if this function pattern is in our safe list
			var fixed_params = _fix_parameters(func_name, params)
			if fixed_params != params:
				changes_log.append({
					"file": file_path,
					"function": func_name,
					"change": "Fixed parameters"
				})
				return indent + "func " + func_name + "(" + fixed_params + ")" + rest
	
	return line

# Fix parameters based on function name
static func _fix_parameters(func_name: String, params_str: String) -> String:
	if params_str.strip_edges().is_empty():
		return params_str
		
	# Check if function matches our patterns
	var safe_params = []
	
	# Direct match
	if SAFE_TO_PREFIX.has(func_name):
		safe_params = SAFE_TO_PREFIX[func_name]
	else:
		# Pattern match (e.g., _on_*_pressed)
		for pattern in SAFE_TO_PREFIX:
			if pattern.contains("*"):
				var regex_pattern = pattern.replace("*", "\\w+")
				var regex = RegEx.new()
				regex.compile("^" + regex_pattern + "$")
				if regex.search(func_name):
					safe_params = SAFE_TO_PREFIX[pattern]
					break
	
	# If no pattern matched, return unchanged
	if safe_params == null:
		return params_str
	
	# Parse and fix parameters
	var params = params_str.split(",")
	var fixed_params = []
	
	for i in range(params.size()):
		var param = params[i].strip_edges()
		if param.is_empty():
			continue
			
		# Extract parameter name
		var param_parts = param.split(":")
		if param_parts.size() > 0:
			var param_name = param_parts[0].strip_edges()
			
			# Check if this parameter should be prefixed
			var should_prefix = false
			
			# If safe_params is empty, prefix all parameters
			if safe_params.is_empty() and i == 0:
				should_prefix = true
			# Otherwise check if parameter name is in safe list
			elif param_name in safe_params:
				should_prefix = true
			
			if should_prefix and not param_name.begins_with("_"):
				param_parts[0] = "_" + param_name
				param = ":".join(param_parts)
		
		fixed_params.append(param)
	
	return ", ".join(fixed_params)

# Batch process multiple files
static func batch_fix(file_paths: Array, dry_run: bool = false) -> void:
	print("=== BATCH PARAMETER FIXER ===")
	print("Processing %d files..." % file_paths.size())
	print("Dry run: %s" % ("Yes" if dry_run else "No"))
	print("")
	
	var success_count = 0
	var change_count = 0
	
	for file_path in file_paths:
		var result = fix_file(file_path, dry_run)
		if result.success:
			success_count += 1
			if result.changes.size() > 0:
				change_count += result.changes.size()
				print("Fixed %s:" % file_path)
				for change in result.changes:
					print("  Line %d: %s" % [change.line, change.new.strip_edges()])
		elif result.error:
			print("ERROR in %s: %s" % [file_path, result.error])
	
	print("\n=== SUMMARY ===")
	print("Files processed: %d" % file_paths.size())
	print("Files fixed: %d" % success_count)
	print("Total changes: %d" % change_count)

# Find all files that need fixing
static func find_files_to_fix(base_path: String = "res://scripts/") -> Array:
	var files = []
	_scan_for_files(base_path, files)
	return files

static func _scan_for_files(path: String, files: Array) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		return
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			_scan_for_files(full_path, files)
		elif file_name.ends_with(".gd"):
			files.append(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

# Quick fix for the most common patterns
static func quick_fix_common() -> void:
	print("=== QUICK FIX COMMON PATTERNS ===")
	
	# Target the most common unused parameters
	var priority_patterns = [
		"_process",
		"_physics_process", 
		"_input",
		"_gui_input",
		"_on_body_entered",
		"_on_body_exited",
		"_on_area_entered",
		"_on_area_exited"
	]
	
	print("Targeting functions: %s" % ", ".join(priority_patterns))
	
	var all_files = find_files_to_fix()
	print("Found %d .gd files to check" % all_files.size())
	
	# First do a dry run
	print("\nDRY RUN - Checking what would be changed...")
	batch_fix(all_files, true)
	
	print("\nPress Enter to apply fixes, or Ctrl+C to cancel...")
	# In real usage, you'd uncomment this to apply:
	# batch_fix(all_files, false)

# Test on sample code
static func test() -> void:
	print("=== TEST MODE ===")
	var test_cases = [
		["func _process(delta: float) -> void:", "func _process(_delta: float) -> void:"],
		["func _on_button_pressed():", "func _on_button_pressed():"],
		["func _on_body_entered(body: Node2D):", "func _on_body_entered(_body: Node2D):"],
		["func custom_function(param1: int, param2: String):", "func custom_function(param1: int, param2: String):"]
	]
	
	for test_case in test_cases:
		var input = test_case[0]
		var expected = test_case[1]
		var result = _process_line(input, "test.gd")
		var passed = result == expected
		print("%s: %s -> %s" % ["PASS" if passed else "FAIL", input, result])
		if not passed:
			print("  Expected: %s" % expected)

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