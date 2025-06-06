# ==================================================
# SCRIPT NAME: naming_validator.gd
# DESCRIPTION: Universal Being Naming Convention Validator
# PURPOSE: Automated rule checking with whitelist/blacklist system
# CREATED: 2025-01-06 - Archaeological Error Resolution
# AUTHOR: JSH + Claude Code - Universal Being Rule System
# ==================================================

@tool
extends RefCounted
#class_name NamingValidator # Commented to avoid duplicate

# ===== RULE CATEGORIES =====
enum ViolationSeverity {
	CRITICAL,    # Godot keywords/reserved words
	HIGH,        # Common shadowing issues  
	MEDIUM,      # Type name conflicts
	LOW,         # Style consistency
	INFO         # Suggestions
}

enum ValidationContext {
	VARIABLE_DECLARATION,
	FUNCTION_PARAMETER,
	CLASS_PROPERTY,
	METHOD_NAME,
	CLASS_NAME,
	SIGNAL_NAME,
	ENUM_VALUE
}

# ===== GODOT RESERVED WORDS =====
static var CRITICAL_BLACKLIST = [
	# GDScript Directives & Built-in Language Elements
	# Note: var, func, extends, etc. are REQUIRED language keywords - don't use as variable names
	"class_name",  # GDScript directive - var class_name is invalid
	"type",        # Built-in type system - var type conflicts with built-in functions
	"export",      # Old export directive
	"onready",     # Old onready directive  
	"tool",        # Script execution directive
	
	# These should never be variable names (though we use them as keywords):
	"extends",     # var extends = bad (but class MyClass extends Node = good)
	"return",      # var return = bad (but return value = good)
	"break",       # var break = bad (but break in loop = good)
	"continue",    # var continue = bad (but continue in loop = good)
]

static var HIGH_RISK_SHADOWING = [
	# Node Properties (most common shadowing issues)
	"name", "visible", "position", "rotation", "scale", "modulate",
	"texture", "material", "process", "ready", "input", "notification",
	"tree", "owner", "scene", "parent", "children"
]

static var MEDIUM_RISK_CONFLICTS = [
	# Built-in types that have their own functions/properties
	"Vector2", "Vector3", "Vector4",  # Have .length(), .normalized(), .dot(), etc.
	"Color",                          # Has .r, .g, .b, .a properties
	"Transform2D", "Transform3D",     # Have .origin, .basis, etc.
	"Resource", "Node",               # Base classes with extensive methods
	"PackedScene", "Script",          # Have load(), instantiate(), etc.
	
	# Common class names that could conflict
	"Control", "Area2D", "Area3D", "RigidBody2D", "RigidBody3D",
	"CharacterBody2D", "CharacterBody3D", "Camera2D", "Camera3D"
]

# ===== UNIVERSAL BEING REPLACEMENT MAP =====
static var NAMING_REPLACEMENTS = {
	# Core Properties
	"name": "being_name",
	"type": "being_type", 
	"position": "spatial_coordinates",
	"visible": "display_mode",
	"material": "surface_material",
	"texture": "visual_texture",
	"process": "processing_state",
	"ready": "awakening_state",
	"input": "sensing_input",
	"notification": "system_notification",
	"tree": "node_hierarchy",
	"parent": "parent_being",
	"children": "child_beings",
	"owner": "being_owner",
	"rotation": "angular_orientation",
	"scale": "scaling_factor",
	"modulate": "color_modulation",
	
	# Socket System
	"socket_name": "socket_designation",
	"socket_id": "socket_identifier",
	"socket_type": "socket_classification",
	
	# Evolution System  
	"evolution_type": "evolution_path",
	"trait": "being_trait",
	"traits": "being_traits"
}

# ===== WHITELISTED EXCEPTIONS =====
static var CONTEXT_WHITELIST = {
	# Method names are allowed to use reserved words
	ValidationContext.METHOD_NAME: [
		"get_name", "set_name", "get_position", "set_position",
		"get_type", "set_type", "get_visible", "set_visible"
	],
	
	# Class names in PascalCase are allowed
	ValidationContext.CLASS_NAME: [
		"NameValidator", "TypeChecker", "PositionManager"
	],
	
	# Signal names with reserved words are contextually OK
	ValidationContext.SIGNAL_NAME: [
		"name_changed", "position_updated", "type_evolved"
	]
}

# ===== LEGACY CODE EXCEPTIONS =====
static var LEGACY_WHITELIST = [
	# Format: {"file": "path", "line": number, "pattern": "var name", "reason": "explanation"}
	{
		"file": "main.gd",
		"line": 17,
		"pattern": "var name = \"Main\"",
		"reason": "Legacy main controller - scheduled for refactoring",
		"deadline": "2025-02-01"
	},
	{
		"file": "socket_manager.gd", 
		"line": 45,
		"pattern": "var type = VISUAL",
		"reason": "Socket type enum - needs socket_classification refactor",
		"deadline": "2025-01-15"
	}
]

# ===== VALIDATION RESULT CLASSES =====
class ValidationResult:
	var is_valid: bool = true
	var violations: Array[Violation] = []
	var suggestions: Array[String] = []
	var warning_count: int = 0
	var error_count: int = 0
	
	func add_violation(violation: Violation) -> void:
		violations.append(violation)
		is_valid = false
		
		match violation.severity:
			ViolationSeverity.CRITICAL, ViolationSeverity.HIGH:
				error_count += 1
			ViolationSeverity.MEDIUM, ViolationSeverity.LOW:
				warning_count += 1
	
	func get_summary() -> String:
		if is_valid:
			return "✅ All naming conventions followed"
		else:
			return "❌ Found %d errors, %d warnings" % [error_count, warning_count]

class Violation:
	var severity: ViolationSeverity
	var file_path: String
	var line_number: int
	var column: int
	var problematic_name: String
	var context: ValidationContext
	var message: String
	var suggested_fix: String
	var rule_violated: String
	
	func _init(sev: ViolationSeverity, file: String, line: int, col: int, name: String, ctx: ValidationContext):
		severity = sev
		file_path = file
		line_number = line
		column = col
		problematic_name = name
		context = ctx
		rule_violated = _get_rule_name()
		message = _generate_message()
		suggested_fix = _generate_suggestion()
	
	func _get_rule_name() -> String:
		match severity:
			ViolationSeverity.CRITICAL:
				return "GODOT_KEYWORD_CONFLICT"
			ViolationSeverity.HIGH:
				return "NODE_PROPERTY_SHADOWING"
			ViolationSeverity.MEDIUM:
				return "TYPE_NAME_CONFLICT"
			ViolationSeverity.LOW:
				return "STYLE_CONVENTION"
			_:
				return "NAMING_SUGGESTION"
	
	func _generate_message() -> String:
		var base_msg = ""
		match severity:
			ViolationSeverity.CRITICAL:
				base_msg = "🚫 CRITICAL: '%s' is a Godot keyword and cannot be used" % problematic_name
			ViolationSeverity.HIGH:
				base_msg = "⚠️ HIGH: Variable '%s' shadows Node property" % problematic_name
			ViolationSeverity.MEDIUM:
				base_msg = "⚡ MEDIUM: '%s' conflicts with Godot type name" % problematic_name
			ViolationSeverity.LOW:
				base_msg = "💡 LOW: '%s' doesn't follow Universal Being conventions" % problematic_name
			_:
				base_msg = "ℹ️ INFO: Consider renaming '%s'" % problematic_name
		
		return "%s in %s:%d" % [base_msg, file_path.get_file(), line_number]
	
	func _generate_suggestion() -> String:
		if NamingValidator.NAMING_REPLACEMENTS.has(problematic_name):
			return "Replace with: %s" % NamingValidator.NAMING_REPLACEMENTS[problematic_name]
		else:
			return "Consider: %s" % NamingValidator.suggest_alternative(problematic_name)

class FileValidationReport:
	var file_path: String
	var total_lines: int
	var violations: Array[Violation] = []
	var is_clean: bool = true
	var scan_timestamp: String
	
	func _init(path: String):
		file_path = path
		scan_timestamp = Time.get_datetime_string_from_system()
	
	func add_violation(violation: Violation) -> void:
		violations.append(violation)
		is_clean = false
	
	func get_summary() -> String:
		if is_clean:
			return "✅ %s: Clean" % file_path.get_file()
		else:
			var critical = violations.filter(func(v): return v.severity == ViolationSeverity.CRITICAL).size()
			var high = violations.filter(func(v): return v.severity == ViolationSeverity.HIGH).size()
			var medium = violations.filter(func(v): return v.severity == ViolationSeverity.MEDIUM).size()
			var low = violations.filter(func(v): return v.severity == ViolationSeverity.LOW).size()
			
			return "❌ %s: %dC %dH %dM %dL" % [file_path.get_file(), critical, high, medium, low]

# ===== MAIN VALIDATION METHODS =====

static func validate_variable_name(var_name: String, context: ValidationContext, file_path: String = "", line_num: int = 0) -> ValidationResult:
	"""Validate a single variable name against all rules"""
	var result = ValidationResult.new()
	
	# Check if whitelisted for this context
	if _is_whitelisted(var_name, context, file_path, line_num):
		return result
	
	# Critical: Godot keywords
	if var_name in CRITICAL_BLACKLIST:
		var violation = Violation.new(ViolationSeverity.CRITICAL, file_path, line_num, 0, var_name, context)
		result.add_violation(violation)
		return result
	
	# High: Node property shadowing
	if var_name in HIGH_RISK_SHADOWING:
		var violation = Violation.new(ViolationSeverity.HIGH, file_path, line_num, 0, var_name, context)
		result.add_violation(violation)
	
	# Medium: Type name conflicts  
	if var_name in MEDIUM_RISK_CONFLICTS:
		var violation = Violation.new(ViolationSeverity.MEDIUM, file_path, line_num, 0, var_name, context)
		result.add_violation(violation)
	
	# Low: Universal Being conventions
	if not _follows_universal_being_conventions(var_name):
		var violation = Violation.new(ViolationSeverity.LOW, file_path, line_num, 0, var_name, context)
		result.add_violation(violation)
	
	return result

static func scan_file_for_violations(file_path: String) -> FileValidationReport:
	"""Scan entire file for naming violations"""
	var report = FileValidationReport.new(file_path)
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Cannot open file: %s" % file_path)
		return report
	
	var line_number = 0
	while not file.eof_reached():
		line_number += 1
		var line = file.get_line()
		var violations = _scan_line_for_violations(line, line_number, file_path)
		
		for violation in violations:
			report.add_violation(violation)
	
	file.close()
	report.total_lines = line_number
	return report

static func scan_project_for_violations(base_path: String = "res://") -> Dictionary:
	"""Scan entire project for violations"""
	var project_report = {
		"scan_timestamp": Time.get_datetime_string_from_system(),
		"base_path": base_path,
		"files_scanned": 0,
		"total_violations": 0,
		"file_reports": {},
		"summary": {}
	}
	
	var file_paths = _get_all_gdscript_files(base_path)
	
	for file_path in file_paths:
		var report = scan_file_for_violations(file_path)
		project_report.file_reports[file_path] = report
		project_report.files_scanned += 1
		project_report.total_violations += report.violations.size()
	
	project_report.summary = _generate_project_summary(project_report)
	return project_report

static func suggest_alternative(forbidden_name: String) -> String:
	"""Suggest Universal Being alternative for forbidden name"""
	
	# Direct replacement available
	if NAMING_REPLACEMENTS.has(forbidden_name):
		return NAMING_REPLACEMENTS[forbidden_name]
	
	# Generate Universal Being style alternatives
	var alternatives = []
	
	# Add Universal Being prefixes
	alternatives.append("being_%s" % forbidden_name)
	alternatives.append("universal_%s" % forbidden_name) 
	alternatives.append("cosmic_%s" % forbidden_name)
	alternatives.append("dimensional_%s" % forbidden_name)
	
	# Consciousness-related terms
	if "level" in forbidden_name or "state" in forbidden_name:
		alternatives.append("consciousness_%s" % forbidden_name)
		alternatives.append("awareness_%s" % forbidden_name)
	
	# Socket-related terms
	if "socket" in forbidden_name:
		alternatives.append("socket_designation")
		alternatives.append("socket_interface")
		alternatives.append("mounting_point")
	
	# Visual/rendering terms
	if forbidden_name in ["color", "material", "texture", "visible"]:
		alternatives.append("visual_%s" % forbidden_name)
		alternatives.append("rendering_%s" % forbidden_name)
		alternatives.append("appearance_%s" % forbidden_name)
	
	return alternatives[0] if alternatives.size() > 0 else "universal_%s" % forbidden_name

static func generate_refactoring_plan(violations: Array[Violation]) -> Dictionary:
	"""Generate automated refactoring plan"""
	var plan = {
		"timestamp": Time.get_datetime_string_from_system(),
		"total_violations": violations.size(),
		"refactoring_actions": [],
		"estimated_files_affected": 0,
		"priority_order": []
	}
	
	# Group violations by file and severity
	var files_affected = {}
	var critical_violations = []
	var high_violations = []
	
	for violation in violations:
		if not files_affected.has(violation.file_path):
			files_affected[violation.file_path] = []
		files_affected[violation.file_path].append(violation)
		
		# Prioritize by severity
		match violation.severity:
			ViolationSeverity.CRITICAL:
				critical_violations.append(violation)
			ViolationSeverity.HIGH:
				high_violations.append(violation)
	
	plan.estimated_files_affected = files_affected.size()
	
	# Generate refactoring actions
	for file_path in files_affected:
		var file_violations = files_affected[file_path]
		var action = {
			"file_path": file_path,
			"violations": file_violations.size(),
			"replacements": {},
			"manual_review_needed": false
		}
		
		for violation in file_violations:
			if NAMING_REPLACEMENTS.has(violation.problematic_name):
				action.replacements[violation.problematic_name] = NAMING_REPLACEMENTS[violation.problematic_name]
			else:
				action.manual_review_needed = true
		
		plan.refactoring_actions.append(action)
	
	# Set priority order
	plan.priority_order = ["CRITICAL", "HIGH", "MEDIUM", "LOW"]
	
	return plan

# ===== HELPER METHODS =====

static func _is_whitelisted(var_name: String, context: ValidationContext, file_path: String, line_num: int) -> bool:
	"""Check if name is whitelisted for this context"""
	
	# Context-specific whitelist
	if CONTEXT_WHITELIST.has(context):
		if var_name in CONTEXT_WHITELIST[context]:
			return true
	
	# Legacy code whitelist
	for legacy_item in LEGACY_WHITELIST:
		if file_path.ends_with(legacy_item.file) and line_num == legacy_item.line:
			if var_name in legacy_item.pattern:
				# For now, always allow legacy whitelist items
				# TODO: Implement proper deadline checking
				print("⏰ Legacy whitelist active for %s:%d - %s" % [file_path, line_num, legacy_item.reason])
				return true
	
	return false

static func _follows_universal_being_conventions(var_name: String) -> bool:
	"""Check if name follows Universal Being conventions"""
	
	# Preferred prefixes
	var ub_prefixes = ["being_", "universal_", "cosmic_", "dimensional_", "consciousness_", 
					   "socket_", "pentagon_", "akashic_", "spatial_", "visual_", "evolution_"]
	
	for prefix in ub_prefixes:
		if var_name.begins_with(prefix):
			return true
	
	# Allow camelCase and snake_case
	var is_snake_case = var_name.is_valid_identifier() and "_" in var_name
	var is_camel_case = var_name.is_valid_identifier() and var_name[0].to_lower() == var_name[0]
	
	return is_snake_case or is_camel_case

static func _scan_line_for_violations(line: String, line_number: int, file_path: String) -> Array[Violation]:
	"""Scan single line for naming violations"""
	var violations: Array[Violation] = []
	
	# Regex patterns for different declaration types
	var patterns = {
		"var_declaration": r"var\s+(\w+)",
		"export_var": r"@export\s+var\s+(\w+)", 
		"function_param": r"func\s+\w+\([^)]*(\w+):\s*\w+",
		"class_declaration": r"class_name\s+(\w+)",
		"signal_declaration": r"signal\s+(\w+)"
	}
	
	for pattern_type in patterns:
		var regex = RegEx.new()
		regex.compile(patterns[pattern_type])
		var results = regex.search_all(line)
		
		for result in results:
			var var_name = result.get_string(1)
			var context = _pattern_type_to_context(pattern_type)
			var validation_result = validate_variable_name(var_name, context, file_path, line_number)
			
			for violation in validation_result.violations:
				violations.append(violation)
	
	return violations

static func _pattern_type_to_context(pattern_type: String) -> ValidationContext:
	"""Convert pattern type to validation context"""
	match pattern_type:
		"var_declaration", "export_var":
			return ValidationContext.VARIABLE_DECLARATION
		"function_param":
			return ValidationContext.FUNCTION_PARAMETER
		"class_declaration":
			return ValidationContext.CLASS_NAME
		"signal_declaration":
			return ValidationContext.SIGNAL_NAME
		_:
			return ValidationContext.VARIABLE_DECLARATION

static func _get_all_gdscript_files(base_path: String) -> Array[String]:
	"""Get all .gd files in project"""
	var files: Array[String] = []
	_scan_directory_recursive(base_path, files)
	return files

static func _scan_directory_recursive(path: String, files: Array[String]) -> void:
	"""Recursively scan directory for .gd files"""
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			_scan_directory_recursive(full_path, files)
		elif file_name.ends_with(".gd"):
			files.append(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

static func _generate_project_summary(project_report: Dictionary) -> Dictionary:
	"""Generate summary statistics"""
	var summary = {
		"total_critical": 0,
		"total_high": 0, 
		"total_medium": 0,
		"total_low": 0,
		"cleanest_files": [],
		"most_violations": [],
		"compliance_percentage": 0.0
	}
	
	var clean_files = 0
	var violation_counts = {}
	
	for file_path in project_report.file_reports:
		var report = project_report.file_reports[file_path]
		
		if report.is_clean:
			clean_files += 1
			summary.cleanest_files.append(file_path)
		else:
			violation_counts[file_path] = report.violations.size()
			
			for violation in report.violations:
				match violation.severity:
					ViolationSeverity.CRITICAL:
						summary.total_critical += 1
					ViolationSeverity.HIGH:
						summary.total_high += 1
					ViolationSeverity.MEDIUM:
						summary.total_medium += 1
					ViolationSeverity.LOW:
						summary.total_low += 1
	
	# Calculate compliance percentage
	if project_report.files_scanned > 0:
		summary.compliance_percentage = (clean_files / float(project_report.files_scanned)) * 100.0
	
	# Get files with most violations
	var sorted_violations = violation_counts.keys()
	sorted_violations.sort_custom(func(a, b): return violation_counts[a] > violation_counts[b])
	summary.most_violations = sorted_violations.slice(0, 5)  # Top 5
	
	return summary

# Date comparison function removed - legacy whitelist always active for now

# ===== COMMAND LINE INTERFACE =====

static func run_validation_cli(args: Array[String]) -> void:
	"""Command line interface for validation"""
	if args.size() == 0:
		print("Universal Being Naming Validator")
		print("Usage:")
		print("  --scan-file <path>     Scan single file")
		print("  --scan-project [path]  Scan entire project")
		print("  --suggest <name>       Get naming suggestion")
		print("  --check <name>         Check single name")
		return
	
	match args[0]:
		"--scan-file":
			if args.size() > 1:
				var report = scan_file_for_violations(args[1])
				print(report.get_summary())
				for violation in report.violations:
					print("  %s" % violation.message)
					print("    → %s" % violation.suggested_fix)
		
		"--scan-project":
			var base_path = args[1] if args.size() > 1 else "res://"
			var project_report = scan_project_for_violations(base_path)
			print("🔍 Universal Being Project Scan Results")
			print("Files scanned: %d" % project_report.files_scanned)
			print("Total violations: %d" % project_report.total_violations)
			print("Compliance: %.1f%%" % project_report.summary.compliance_percentage)
			print("\nSeverity breakdown:")
			print("  Critical: %d" % project_report.summary.total_critical)
			print("  High: %d" % project_report.summary.total_high)
			print("  Medium: %d" % project_report.summary.total_medium)
			print("  Low: %d" % project_report.summary.total_low)
		
		"--suggest":
			if args.size() > 1:
				var suggestion = suggest_alternative(args[1])
				print("Suggestion for '%s': %s" % [args[1], suggestion])
		
		"--check":
			if args.size() > 1:
				var result = validate_variable_name(args[1], ValidationContext.VARIABLE_DECLARATION)
				print(result.get_summary())
				for violation in result.violations:
					print("  %s" % violation.message)