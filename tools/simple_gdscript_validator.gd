#!/usr/bin/env godot --script
# Simple GDScript validator using Godot's built-in parser
extends SceneTree

func _initialize():
	"""Test GDScript validation"""
	print("🔍 Simple GDScript Validator")
	
	# Test the file we want to validate
	var test_file = "/tmp/test_validation.gd"
	
	# Create test content
	var content = """extends Node

func _ready():
	print("Hello World")
	var name = "test"  # This should trigger a warning
"""
	
	# Write test file
	var file = FileAccess.open(test_file, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()
		print("✅ Created test file: %s" % test_file)
	else:
		print("❌ Failed to create test file")
		quit()
		return
	
	# Test validation
	var result = validate_gdscript_file(test_file)
	print("📊 Validation Results:")
	print("  Valid: %s" % result.is_valid)
	print("  Errors: %d" % result.errors.size())
	print("  Warnings: %d" % result.warnings.size())
	
	for error in result.errors:
		print("  ❌ Error Line %d: %s" % [error.line, error.message])
	
	for warning in result.warnings:
		print("  ⚠️ Warning Line %d: %s" % [warning.line, warning.message])
	
	# Test with actual Universal Being files
	print("\n🌟 Testing Universal Being Files:")
	test_universal_being_files()
	
	quit()

func validate_gdscript_file(file_path: String) -> Dictionary:
	"""Validate a GDScript file using Godot's parser"""
	var result = {
		"file_path": file_path,
		"is_valid": true,
		"errors": [],
		"warnings": []
	}
	
	# Check if file exists
	if not FileAccess.file_exists(file_path):
		result.errors.append({
			"message": "File not found: %s" % file_path,
			"line": 0
		})
		result.is_valid = false
		return result
	
	# Read file content
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		result.errors.append({
			"message": "Cannot read file: %s" % file_path,
			"line": 0
		})
		result.is_valid = false
		return result
	
	var content = file.get_as_text()
	file.close()
	
	# Try to parse using GDScript
	var script = GDScript.new()
	script.source_code = content
	
	# Parse the script
	var parse_result = script.reload()
	
	if parse_result != OK:
		result.is_valid = false
		result.errors.append({
			"message": "GDScript parse error",
			"line": 1
		})
	
	# Check for common naming issues
	check_naming_conventions(content, result)
	
	return result

func check_naming_conventions(content: String, result: Dictionary) -> void:
	"""Check for Universal Being naming conventions"""
	var lines = content.split("\n")
	
	for i in range(lines.size()):
		var line = lines[i]
		var line_number = i + 1
		
		# Check for variable declarations that shadow Node properties
		if line.strip_edges().begins_with("var "):
			var regex = RegEx.new()
			regex.compile(r"var\s+(\w+)")
			var match = regex.search(line)
			if match:
				var var_name = match.get_string(1)
				if var_name in ["name", "position", "visible", "type", "process", "ready"]:
					result.warnings.append({
						"message": "Variable '%s' shadows Node property - consider using 'being_%s'" % [var_name, var_name],
						"line": line_number
					})

func test_universal_being_files() -> void:
	"""Test some actual Universal Being files"""
	var test_files = [
		"main.gd",
		"core/UniversalBeing.gd",
		"core/CursorUniversalBeing.gd"
	]
	
	for file_path in test_files:
		if FileAccess.file_exists(file_path):
			print("  🔍 Testing: %s" % file_path)
			var result = validate_gdscript_file(file_path)
			print("    Valid: %s, Errors: %d, Warnings: %d" % [result.is_valid, result.errors.size(), result.warnings.size()])
			
			# Show first few issues
			for i in range(min(3, result.errors.size())):
				var error = result.errors[i]
				print("      ❌ Line %d: %s" % [error.line, error.message])
			
			for i in range(min(3, result.warnings.size())):
				var warning = result.warnings[i]
				print("      ⚠️ Line %d: %s" % [warning.line, warning.message])
		else:
			print("  ⚠️ File not found: %s" % file_path)