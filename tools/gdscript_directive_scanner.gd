# ==================================================
# SCRIPT NAME: gdscript_directive_scanner.gd
# DESCRIPTION: Scan for variables that conflict with GDScript directives and built-in types
# PURPOSE: Find var class_name, var type, etc. - actual GDScript conflicts
# CREATED: 2025-01-06 - GDScript Directive Conflict Resolution
# AUTHOR: JSH + Claude Code - Universal Being GDScript Safety
# ==================================================

@tool
extends RefCounted
class_name GDScriptDirectiveScanner

# ===== GDSCRIPT DIRECTIVE CONFLICTS =====
# These CANNOT be used as variable names because they are GDScript directives/built-ins

static var GDSCRIPT_DIRECTIVES = [
	"class_name",  # GDScript class directive - var class_name = INVALID
	"tool",        # Script execution directive - var tool = INVALID  
	"extends",     # Inheritance directive - var extends = INVALID
	"export",      # Old export system - var export = INVALID
	"onready"      # Old onready system - var onready = INVALID
]

static var BUILTIN_TYPES_WITH_FUNCTIONS = [
	# These have built-in methods that would be shadowed
	"type",        # Built-in type checking - var type shadows type() function
	"Vector2",     # Has .length(), .normalized(), .dot(), etc.
	"Vector3",     # Has .length(), .normalized(), .cross(), etc.
	"Vector4",     # Has .length(), .normalized(), etc.
	"Color",       # Has .r, .g, .b, .a properties
	"Transform2D", # Has .origin, .basis, etc.
	"Transform3D", # Has .origin, .basis, etc.
	"Rect2",       # Has .position, .size, .area(), etc.
	"Resource",    # Base class with many methods
	"Node",        # Base class with extensive API
	"PackedScene", # Has instantiate(), load(), etc.
	"Script"       # Has new(), get_script_method_list(), etc.
]

static var BUILTIN_FUNCTIONS_TO_AVOID = [
	# Global functions that shouldn't be variable names
	"print",       # var print = bad (shadows print() function)
	"push_error",  # var push_error = bad
	"push_warning", # var push_warning = bad
	"len",         # var len = bad (shadows len() function)
	"range",       # var range = bad (shadows range() function)
	"abs",         # var abs = bad (shadows abs() function)
	"sin", "cos", "tan", "sqrt", # Math functions
	"load",        # var load = bad (shadows load() function)
	"preload"      # var preload = bad (shadows preload() function)
]

# ===== SYMBOL CONFLICTS =====
static var SPECIAL_SYMBOLS = [
	"#",           # Comment marker - cannot be in variable names anyway
	"@",           # Annotation prefix - cannot be in variable names
	"$",           # Node path - cannot be in variable names  
	"%"            # Unique name - cannot be in variable names
]

# ===== CONFLICT DETECTION =====

class DirectiveConflict:
	var file_path: String
	var line_number: int
	var column: int
	var variable_name: String
	var conflict_type: String
	var issue_description: String
	var suggested_fix: String
	var severity: String
	
	func _init(file: String, line: int, col: int, var_name: String, conflict: String):
		file_path = file
		line_number = line
		column = col
		variable_name = var_name
		conflict_type = conflict
		severity = _get_severity()
		issue_description = _get_description()
		suggested_fix = _get_suggestion()
	
	func _get_severity() -> String:
		if conflict_type in ["GDSCRIPT_DIRECTIVE", "BUILTIN_TYPE_FUNCTION"]:
			return "CRITICAL"
		elif conflict_type == "BUILTIN_FUNCTION":
			return "HIGH"
		else:
			return "MEDIUM"
	
	func _get_description() -> String:
		match conflict_type:
			"GDSCRIPT_DIRECTIVE":
				return "Variable '%s' conflicts with GDScript directive" % variable_name
			"BUILTIN_TYPE_FUNCTION":
				return "Variable '%s' shadows built-in type with methods" % variable_name
			"BUILTIN_FUNCTION":
				return "Variable '%s' shadows global function" % variable_name
			_:
				return "Variable '%s' has potential conflict" % variable_name
	
	func _get_suggestion() -> String:
		# Use Universal Being architectural terms for replacements
		match variable_name:
			"class_name":
				return "being_class_designation"
			"type":
				return "being_essence_type"
			"tool":
				return "being_tool_mode"
			"extends":
				return "being_inheritance_path"
			"Vector2", "Vector3", "Vector4":
				return "spatial_coordinates" 
			"Color":
				return "visual_color"
			"Transform2D", "Transform3D":
				return "spatial_transform"
			"print":
				return "debug_output"
			"load":
				return "resource_loader"
			_:
				return "universal_%s" % variable_name.to_lower()

class DirectiveScanReport:
	var scan_timestamp: String
	var files_scanned: int = 0
	var total_conflicts: int = 0
	var conflicts: Array[DirectiveConflict] = []
	var conflicts_by_type: Dictionary = {}
	
	func _init():
		scan_timestamp = Time.get_datetime_string_from_system()
		conflicts_by_type = {
			"GDSCRIPT_DIRECTIVE": 0,
			"BUILTIN_TYPE_FUNCTION": 0, 
			"BUILTIN_FUNCTION": 0
		}
	
	func add_conflict(conflict: DirectiveConflict) -> void:
		conflicts.append(conflict)
		total_conflicts += 1
		conflicts_by_type[conflict.conflict_type] += 1
	
	func get_summary() -> String:
		var summary = []
		summary.append("🚫 GDScript Directive Conflict Scan Report")
		summary.append("Timestamp: %s" % scan_timestamp)
		summary.append("Files scanned: %d" % files_scanned)
		summary.append("Total conflicts: %d" % total_conflicts)
		summary.append("")
		summary.append("Conflict breakdown:")
		summary.append("  GDScript Directives: %d" % conflicts_by_type.GDSCRIPT_DIRECTIVE)
		summary.append("  Built-in Type Functions: %d" % conflicts_by_type.BUILTIN_TYPE_FUNCTION)
		summary.append("  Built-in Functions: %d" % conflicts_by_type.BUILTIN_FUNCTION)
		summary.append("")
		
		if total_conflicts > 0:
			summary.append("🔧 Critical fixes needed:")
			for conflict in conflicts:
				if conflict.severity == "CRITICAL":
					summary.append("  %s:%d - %s → %s" % [
						conflict.file_path.get_file(),
						conflict.line_number,
						conflict.variable_name,
						conflict.suggested_fix
					])
		
		return "\n".join(summary)

# ===== MAIN SCANNING METHODS =====

static func scan_project_for_directive_conflicts(base_path: String = "res://") -> DirectiveScanReport:
	"""Scan entire project for GDScript directive conflicts"""
	print("🚫 Scanning for GDScript directive conflicts...")
	print("Looking for: var class_name, var type, etc.")
	
	var report = DirectiveScanReport.new()
	var all_files = _get_all_gd_files(base_path)
	
	for file_path in all_files:
		var file_conflicts = _scan_file_for_directive_conflicts(file_path)
		report.files_scanned += 1
		
		for conflict in file_conflicts:
			report.add_conflict(conflict)
	
	print("🚫 Directive conflict scan complete!")
	return report

static func _scan_file_for_directive_conflicts(file_path: String) -> Array[DirectiveConflict]:
	"""Scan single file for directive conflicts"""
	var conflicts: Array[DirectiveConflict] = []
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return conflicts
	
	var content = file.get_as_text()
	file.close()
	
	var lines = content.split("\n")
	
	for i in range(lines.size()):
		var line = lines[i]
		var line_number = i + 1
		
		# Check for variable declarations that conflict with directives
		var line_conflicts = _check_line_for_conflicts(line, line_number, file_path)
		conflicts.append_array(line_conflicts)
	
	return conflicts

static func _check_line_for_conflicts(line: String, line_number: int, file_path: String) -> Array[DirectiveConflict]:
	"""Check single line for directive conflicts"""
	var conflicts: Array[DirectiveConflict] = []
	
	# Skip comments
	if line.strip_edges().begins_with("#"):
		return conflicts
	
	# Pattern for variable declarations: var variable_name
	var var_regex = RegEx.new()
	var_regex.compile("var\\s+(\\w+)")
	var var_matches = var_regex.search_all(line)
	
	for match in var_matches:
		var var_name = match.get_string(1)
		var conflict_type = _get_conflict_type(var_name)
		
		if conflict_type != "":
			var conflict = DirectiveConflict.new(
				file_path, line_number, match.get_start(), var_name, conflict_type
			)
			conflicts.append(conflict)
	
	# Also check @export var declarations
	var export_regex = RegEx.new()
	export_regex.compile("@export\\s+var\\s+(\\w+)")
	var export_matches = export_regex.search_all(line)
	
	for match in export_matches:
		var var_name = match.get_string(1)
		var conflict_type = _get_conflict_type(var_name)
		
		if conflict_type != "":
			var conflict = DirectiveConflict.new(
				file_path, line_number, match.get_start(), var_name, conflict_type
			)
			conflicts.append(conflict)
	
	return conflicts

static func _get_conflict_type(var_name: String) -> String:
	"""Determine what type of conflict this variable name has"""
	
	if var_name in GDSCRIPT_DIRECTIVES:
		return "GDSCRIPT_DIRECTIVE"
	elif var_name in BUILTIN_TYPES_WITH_FUNCTIONS:
		return "BUILTIN_TYPE_FUNCTION"
	elif var_name in BUILTIN_FUNCTIONS_TO_AVOID:
		return "BUILTIN_FUNCTION"
	else:
		return ""

static func generate_fix_script(conflicts: Array[DirectiveConflict]) -> String:
	"""Generate script to automatically fix directive conflicts"""
	var script_lines = []
	script_lines.append("#!/bin/bash")
	script_lines.append("# GDScript Directive Conflict Fixes")
	script_lines.append("# Auto-generated by GDScriptDirectiveScanner")
	script_lines.append("")
	script_lines.append("echo '🚫 Fixing GDScript directive conflicts...'")
	script_lines.append("")
	
	# Group conflicts by file
	var files_to_fix = {}
	for conflict in conflicts:
		if not files_to_fix.has(conflict.file_path):
			files_to_fix[conflict.file_path] = []
		files_to_fix[conflict.file_path].append(conflict)
	
	for file_path in files_to_fix:
		script_lines.append("# Fixing %s" % file_path)
		var file_conflicts = files_to_fix[file_path]
		
		for conflict in file_conflicts:
			if conflict.severity == "CRITICAL":
				script_lines.append("sed -i 's/var %s/var %s/g' '%s'" % [
					conflict.variable_name,
					conflict.suggested_fix,
					conflict.file_path
				])
				script_lines.append("echo '  ✅ Fixed: %s → %s'" % [
					conflict.variable_name,
					conflict.suggested_fix
				])
		
		script_lines.append("")
	
	script_lines.append("echo '✅ GDScript directive conflict fixes applied!'")
	script_lines.append("echo 'Please test the project to ensure everything works correctly.'")
	
	return "\n".join(script_lines)

static func check_specific_variable(var_name: String) -> Dictionary:
	"""Check if a specific variable name has conflicts"""
	var result = {
		"variable_name": var_name,
		"has_conflict": false,
		"conflict_type": "",
		"issue": "",
		"suggestion": ""
	}
	
	var conflict_type = _get_conflict_type(var_name)
	if conflict_type != "":
		result.has_conflict = true
		result.conflict_type = conflict_type
		
		match conflict_type:
			"GDSCRIPT_DIRECTIVE":
				result.issue = "'%s' is a GDScript directive and cannot be used as variable name" % var_name
			"BUILTIN_TYPE_FUNCTION":
				result.issue = "'%s' is a built-in type with methods that would be shadowed" % var_name
			"BUILTIN_FUNCTION":
				result.issue = "'%s' is a global function that would be shadowed" % var_name
		
		# Generate Universal Being style suggestion
		var temp_conflict = DirectiveConflict.new("", 0, 0, var_name, conflict_type)
		result.suggestion = temp_conflict.suggested_fix
	
	return result

# ===== HELPER METHODS =====

static func _get_all_gd_files(base_path: String) -> Array[String]:
	"""Get all .gd files recursively"""
	var files: Array[String] = []
	_scan_directory_for_gd_files(base_path, files)
	return files

static func _scan_directory_for_gd_files(path: String, files: Array[String]) -> void:
	"""Recursively scan directory for .gd files"""
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path.path_join(file_name)
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			_scan_directory_for_gd_files(full_path, files)
		elif file_name.ends_with(".gd"):
			files.append(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

# ===== COMMAND LINE INTERFACE =====

static func main():
	"""Entry point for directive scanner"""
	var args = OS.get_cmdline_args()
	
	if "--scan-directives" in args:
		var report = scan_project_for_directive_conflicts()
		print(report.get_summary())
		
		# Save report to file
		var report_file = FileAccess.open("gdscript_directive_conflicts.txt", FileAccess.WRITE)
		if report_file:
			report_file.store_string(report.get_summary())
			report_file.close()
			print("\n📄 Report saved to: gdscript_directive_conflicts.txt")
	
	elif "--check-var" in args:
		if args.size() > args.find("--check-var") + 1:
			var var_name = args[args.find("--check-var") + 1]
			var result = check_specific_variable(var_name)
			
			print("Checking variable: '%s'" % var_name)
			if result.has_conflict:
				print("❌ CONFLICT: %s" % result.issue)
				print("💡 Suggestion: %s" % result.suggestion)
			else:
				print("✅ No conflicts found")
	
	elif "--generate-fixes" in args:
		var report = scan_project_for_directive_conflicts()
		var fix_script = generate_fix_script(report.conflicts)
		
		var script_file = FileAccess.open("fix_directive_conflicts.sh", FileAccess.WRITE)
		if script_file:
			script_file.store_string(fix_script)
			script_file.close()
			print("🔧 Fix script generated: fix_directive_conflicts.sh")
			print("Run: chmod +x fix_directive_conflicts.sh && ./fix_directive_conflicts.sh")
	
	else:
		print("🚫 GDScript Directive Conflict Scanner")
		print("Finds variables that conflict with GDScript directives and built-in types")
		print("")
		print("Usage:")
		print("  --scan-directives     Scan project for conflicts")
		print("  --check-var <name>    Check specific variable name")
		print("  --generate-fixes      Generate automatic fix script")
		print("")
		print("Examples of conflicts:")
		print("  var class_name = 'Bad'    # ❌ Conflicts with GDScript directive")  
		print("  var type = 'String'       # ❌ Shadows built-in type() function")
		print("  var Vector2 = Vector2()   # ❌ Shadows Vector2 type with methods")
		print("  var print = 'something'   # ❌ Shadows print() function")