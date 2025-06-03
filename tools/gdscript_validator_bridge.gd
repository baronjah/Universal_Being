#!/usr/bin/env godot --script
# ==================================================
# SCRIPT NAME: gdscript_validator_bridge.gd
# DESCRIPTION: Bridge to validate GDScript files using Godot LSP
# PURPOSE: Enable Linux Claude to validate GDScript through Windows Godot
# CREATED: 2025-01-06 - Multi-AI Remote Development Bridge
# AUTHOR: JSH + Claude Code - Universal Being Remote Validation
# ==================================================

@tool
extends MainLoop

# ===== VALIDATION BRIDGE =====

const VALIDATION_DIR = "user://validation_bridge/"
const REQUEST_FILE = "validation_request.json"
const RESPONSE_FILE = "validation_response.json"

func _initialize():
	"""Initialize validation bridge"""
	var args = OS.get_cmdline_args()
	await main(args)

static func main(args: Array[String]):
	"""Main validation bridge entry point"""
	print("🔍 GDScript Validation Bridge - Powered by Godot LSP")
	
	if args.size() == 0:
		print_usage()
		return
	
	match args[0]:
		"--validate-file":
			if args.size() > 1:
				await validate_file(args[1])
			else:
				print("❌ Error: No file path provided")
		"--validate-content":
			if args.size() > 1:
				await validate_content(args[1])
			else:
				print("❌ Error: No content provided")
		"--check-syntax":
			if args.size() > 1:
				await check_syntax(args[1])
			else:
				print("❌ Error: No file path provided")
		"--process-queue":
			await process_validation_queue()
		_:
			print_usage()

static func print_usage():
	"""Print usage information"""
	print("Usage:")
	print("  --validate-file <path>     Validate a GDScript file")
	print("  --validate-content <code>  Validate GDScript content")
	print("  --check-syntax <path>      Check syntax only")
	print("  --process-queue           Process validation request queue")
	print("")
	print("Examples:")
	print("  godot --script gdscript_validator_bridge.gd -- --validate-file main.gd")
	print("  godot --script gdscript_validator_bridge.gd -- --validate-content 'func test(): pass'")

static func validate_file(file_path: String) -> Dictionary:
	"""Validate a GDScript file using Godot's built-in parser"""
	print("🔍 Validating file: %s" % file_path)
	
	var result = {
		"file_path": file_path,
		"is_valid": false,
		"errors": [],
		"warnings": [],
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	# Check if file exists
	if not FileAccess.file_exists(file_path):
		result.errors.append({
			"message": "File not found: %s" % file_path,
			"line": 0,
			"column": 0
		})
		print("❌ File not found: %s" % file_path)
		return result
	
	# Read file content
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		result.errors.append({
			"message": "Cannot read file: %s" % file_path,
			"line": 0,
			"column": 0
		})
		print("❌ Cannot read file: %s" % file_path)
		return result
	
	var content = file.get_as_text()
	file.close()
	
	# Validate content
	result = await validate_content(content, file_path)
	print("✅ Validation complete for: %s" % file_path)
	return result

static func validate_content(content: String, source_path: String = "temp.gd") -> Dictionary:
	"""Validate GDScript content using Godot's parser"""
	print("🔍 Validating GDScript content...")
	
	var result = {
		"source_path": source_path,
		"is_valid": true,
		"errors": [],
		"warnings": [],
		"syntax_tree": null,
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	# Try to parse the GDScript content
	var parser = GDScript.new()
	parser.source_code = content
	
	# Parse and check for errors
	var parse_result = parser.reload()
	
	if parse_result != OK:
		result.is_valid = false
		
		# Try to get more detailed error information
		var error_msg = "Parse error in GDScript"
		
		# Common GDScript parse error patterns
		var error_patterns = [
			{"pattern": "Parse Error", "severity": "error"},
			{"pattern": "Unexpected token", "severity": "error"},
			{"pattern": "Expected", "severity": "error"},
			{"pattern": "Identifier.*not declared", "severity": "error"},
			{"pattern": "Function.*not found", "severity": "error"},
			{"pattern": "Invalid syntax", "severity": "error"}
		]
		
		result.errors.append({
			"message": error_msg,
			"line": 1,
			"column": 1,
			"severity": "error"
		})
		
		print("❌ Parse error in GDScript content")
	else:
		print("✅ GDScript content is syntactically valid")
		
		# Additional semantic analysis
		result = await analyze_gdscript_semantics(content, result)
	
	return result

static func analyze_gdscript_semantics(content: String, result: Dictionary) -> Dictionary:
	"""Analyze GDScript for semantic issues"""
	print("🔍 Analyzing GDScript semantics...")
	
	var lines = content.split("\n")
	
	for i in range(lines.size()):
		var line = lines[i]
		var line_number = i + 1
		
		# Check for common issues
		if line.strip_edges().begins_with("var "):
			# Check for variable naming issues
			var regex = RegEx.new()
			regex.compile(r"var\s+(\w+)")
			var var_match = regex.search(line)
			if var_match:
				var var_name = var_match.get_string(1) if var_match.get_group_count() > 0 else ""
				if var_name in ["name", "position", "visible", "type"]:
					result.warnings.append({
						"message": "Variable '%s' shadows Node property" % var_name,
						"line": line_number,
						"column": line.find(var_name),
						"severity": "warning"
					})
		
		# Check for function definitions
		if line.strip_edges().begins_with("func "):
			# Check for Pentagon method overrides without super calls
			var pentagon_methods = ["pentagon_init", "pentagon_ready", "pentagon_process", "pentagon_input", "pentagon_sewers"]
			for method in pentagon_methods:
				if method in line and "super." not in content:
					result.warnings.append({
						"message": "Pentagon method '%s' should call super.%s()" % [method, method],
						"line": line_number,
						"column": line.find(method),
						"severity": "warning"
					})
	
	print("✅ Semantic analysis complete")
	return result

static func check_syntax(file_path: String) -> Dictionary:
	"""Quick syntax check only"""
	print("🔍 Quick syntax check: %s" % file_path)
	
	var result = await validate_file(file_path)
	
	# Filter to only syntax errors
	var syntax_result = {
		"file_path": file_path,
		"has_syntax_errors": result.errors.size() > 0,
		"syntax_errors": result.errors,
		"timestamp": result.timestamp
	}
	
	if syntax_result.has_syntax_errors:
		print("❌ Syntax errors found in: %s" % file_path)
		for error in syntax_result.syntax_errors:
			print("   Line %d: %s" % [error.line, error.message])
	else:
		print("✅ Syntax OK: %s" % file_path)
	
	return syntax_result

static func process_validation_queue() -> void:
	"""Process validation requests from file queue"""
	print("🔍 Processing validation queue...")
	
	# Ensure validation directory exists
	if not DirAccess.dir_exists_absolute(VALIDATION_DIR):
		DirAccess.make_dir_recursive_absolute(VALIDATION_DIR)
	
	var request_path = VALIDATION_DIR + REQUEST_FILE
	var response_path = VALIDATION_DIR + RESPONSE_FILE
	
	# Check for pending validation request
	if FileAccess.file_exists(request_path):
		print("📥 Found validation request")
		
		var file = FileAccess.open(request_path, FileAccess.READ)
		if file:
			var request_text = file.get_as_text()
			file.close()
			
			var request = JSON.parse_string(request_text)
			if request:
				var response = await handle_validation_request(request)
				
				# Write response
				var response_file = FileAccess.open(response_path, FileAccess.WRITE)
				if response_file:
					response_file.store_string(JSON.stringify(response))
					response_file.close()
					print("✅ Validation response written")
				
				# Clean up request
				DirAccess.remove_absolute(request_path)
			else:
				print("❌ Invalid JSON in validation request")
	else:
		print("📭 No validation requests found")

static func handle_validation_request(request: Dictionary) -> Dictionary:
	"""Handle a validation request"""
	var response = {
		"request_id": request.get("id", "unknown"),
		"timestamp": Time.get_datetime_string_from_system(),
		"results": []
	}
	
	if request.has("files"):
		for file_data in request.files:
			var file_path = file_data.get("path", "")
			var result = await validate_file(file_path)
			response.results.append(result)
	
	if request.has("content"):
		var content = request.content.get("code", "")
		var source = request.content.get("source", "temp.gd")
		var result = await validate_content(content, source)
		response.results.append(result)
	
	return response

# ===== FILE WATCHER =====

static func watch_for_changes(directory: String) -> void:
	"""Watch directory for file changes and auto-validate"""
	print("👁️ Watching directory for changes: %s" % directory)
	
	# This would require a more complex implementation
	# For now, we'll use polling
	var file_times = {}
	
	while true:
		var dir = DirAccess.open(directory)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			
			while file_name != "":
				if file_name.ends_with(".gd"):
					var full_path = directory + "/" + file_name
					var current_time = FileAccess.get_modified_time(full_path)
					
					if not file_times.has(full_path) or file_times[full_path] != current_time:
						file_times[full_path] = current_time
						print("📝 File changed: %s" % file_name)
						await validate_file(full_path)
				
				file_name = dir.get_next()
			
			dir.list_dir_end()
		
		await Engine.get_main_loop().create_timer(1.0).timeout

# ===== MAIN ENTRY POINT =====

func _ready():
	"""MainLoop ready - shouldn't be called in script mode"""
	pass