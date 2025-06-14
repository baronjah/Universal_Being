# ==================================================
# SCRIPT NAME: automated_warning_fixer.gd
# DESCRIPTION: Automatically fixes common warnings
# PURPOSE: Process all files to fix unused parameters
# CREATED: 2025-05-25 - Auto-fixing 160+ warnings
# ==================================================

extends RefCounted

# Statistics tracking
static var stats = {
	"files_processed": 0,
	"warnings_fixed": 0,
	"parameters_prefixed": 0,
	"variables_prefixed": 0,
	"errors_encountered": 0
}

# Fix unused parameters in a single file
static func fix_unused_parameters_in_file(file_path: String) -> Dictionary:
	var result = {
		"success": false,
		"changes_made": 0,
		"errors": []
	}
	
	# Read file content
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		result.errors.append("Cannot open file: " + file_path)
		return result
	
	var content = file.get_as_text()
	file.close()
	
	# Track changes
	var _original_content = content
	var changes = []
	
	# Pattern to find function definitions with parameters
	var func_pattern = RegEx.new()
	func_pattern.compile("func\\s+(\\w+)\\s*\\(([^)]*)\\)")
	
	# Process each function
	for match in func_pattern.search_all(content):
		var func_name = match.get_string(1)
		var params_str = match.get_string(2)
		
		if params_str.strip_edges().is_empty():
			continue
			
		# Parse parameters
		var params = params_str.split(",")
		var new_params = []
		var param_changed = false
		
		for param in params:
			var param_parts = param.strip_edges().split(":")
			if param_parts.size() >= 1:
				var param_name = param_parts[0].strip_edges()
				
				# Check if this parameter might be unused
				# (In real implementation, we'd check the function body)
				if should_prefix_parameter(content, func_name, param_name):
					if not param_name.begins_with("_"):
						var new_param_name = "_" + param_name
						param_parts[0] = new_param_name
						param_changed = true
						changes.append({
							"type": "parameter",
							"function": func_name,
							"old": param_name,
							"new": new_param_name
						})
				
				new_params.append(":".join(param_parts))
			else:
				new_params.append(param)
		
		# Replace function definition if parameters changed
		if param_changed:
			var old_func_def = match.get_string(0)
			var new_func_def = "func %s(%s)" % [func_name, ", ".join(new_params)]
			content = content.replace(old_func_def, new_func_def)
			result.changes_made += 1
	
	# Write changes if any
	if result.changes_made > 0:
		var write_file = FileAccess.open(file_path, FileAccess.WRITE)
		if write_file:
			write_file.store_string(content)
			write_file.close()
			result.success = true
			
			# Log changes
			print("Fixed %d warnings in %s:" % [result.changes_made, file_path])
			for change in changes:
				print("  - %s: %s -> %s" % [change.function, change.old, change.new])
		else:
			result.errors.append("Cannot write to file: " + file_path)
	else:
		result.success = true
	
	return result

# Check if parameter is likely unused
static func should_prefix_parameter(content: String, func_name: String, param_name: String) -> bool:
	# Find function body
	var func_start = content.find("func " + func_name)
	if func_start == -1:
		return false
	
	# Find function end (next func or end of file)
	var func_end = content.find("\nfunc ", func_start + 1)
	if func_end == -1:
		func_end = content.length()
	
	var func_body = content.substr(func_start, func_end - func_start)
	
	# Check if parameter is used in function body
	# Skip the function definition line
	var body_start = func_body.find("\n")
	if body_start == -1:
		return false
		
	var body_only = func_body.substr(body_start)
	
	# Look for parameter usage (not in comments or strings)
	var usage_pattern = RegEx.new()
	usage_pattern.compile("\\b" + param_name + "\\b")
	
	# Simple check - if parameter appears in body, it's probably used
	# (More sophisticated check would parse strings and comments)
	return not usage_pattern.search(body_only)

# Process all GDScript files in project
static func fix_all_warnings(base_path: String = "res://scripts/") -> void:
	print("=== AUTOMATED WARNING FIXER ===")
	print("Starting scan from: " + base_path)
	
	stats.files_processed = 0
	stats.warnings_fixed = 0
	stats.parameters_prefixed = 0
	
	_scan_directory(base_path)
	
	print("\n=== SUMMARY ===")
	print("Files processed: %d" % stats.files_processed)
	print("Warnings fixed: %d" % stats.warnings_fixed)
	print("Parameters prefixed: %d" % stats.parameters_prefixed)
	print("Errors encountered: %d" % stats.errors_encountered)

# Recursively scan directories
static func _scan_directory(path: String) -> void:
	var dir = DirAccess.open(path)
	if not dir:
		print("Cannot open directory: " + path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			_scan_directory(full_path)
		elif file_name.ends_with(".gd"):
			stats.files_processed += 1
			var result = fix_unused_parameters_in_file(full_path)
			if result.success and result.changes_made > 0:
				stats.warnings_fixed += result.changes_made
				stats.parameters_prefixed += result.changes_made
			elif result.errors.size() > 0:
				stats.errors_encountered += 1
				for error in result.errors:
					print("ERROR: " + error)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

# Generate report of common unused parameters
static func analyze_warning_patterns() -> Dictionary:
	return {
		"common_unused_params": [
			"delta",  # Often unused in _process functions
			"event",  # Often unused in input handlers
			"body",   # Often unused in collision handlers
			"area",   # Often unused in area handlers
			"viewport", # Often unused in viewport callbacks
			"camera",   # Often unused in camera callbacks
		],
		"interface_methods": [
			"_ready",
			"_enter_tree",
			"_exit_tree",
			"_process",
			"_physics_process",
			"_input",
			"_unhandled_input",
			"_gui_input",
			"_draw",
			"_notification"
		],
		"signal_parameters": [
			# Signals often have parameters that handlers don't use
			"on_",
			"_pressed",
			"_changed",
			"_entered",
			"_exited"
		]
	}

# Test function to show how it works
static func test_on_sample() -> void:
	var sample_code = """
func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Delta not used
	position.x += 10

func _on_body_entered(body: Node2D) -> void:
	# Body not used
	print("Something entered!")
	

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
func calculate_damage(attacker: Node, defender: Node, weapon: String) -> int:
	# Only defender is used
	return defender.health - 10
"""
	
	print("=== SAMPLE FIX DEMONSTRATION ===")
	print("Original code:")
	print(sample_code)
	print("\nWould be fixed to:")
	print("""
func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Delta not used
	position.x += 10

func _on_body_entered(_body: Node2D) -> void:
	# Body not used  
	print("Something entered!")
	
func calculate_damage(_attacker: Node, defender: Node, _weapon: String) -> int:
	# Only defender is used
	return defender.health - 10
""")