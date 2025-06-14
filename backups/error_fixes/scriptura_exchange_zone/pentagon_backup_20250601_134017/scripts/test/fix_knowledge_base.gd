# ==================================================
# SCRIPT NAME: fix_knowledge_base.gd
# DESCRIPTION: Documents all fixes and their reasons
# PURPOSE: Learn from past fixes to apply them automatically
# CREATED: 2025-05-25 - Building fix memory
# ==================================================

extends RefCounted

# Categorized fixes we've learned
static var PATH_FIXES = {
	"JSH_FRAMEWORK_PATHS": {
		"problem": "JSH framework expects D: drive paths",
		"symptoms": ["Preload file does not exist", "res://code/gdscript/scripts/"],
		"fix_pattern": "res://code/gdscript/scripts/ → res://scripts/jsh_framework/",
		"files_affected": [
			"jsh_scene_tree_system.gd",
			"main.gd",
			"JSH_console.gd"
		],
		"reason": "JSH framework was copied from D: drive project with different structure"
	},
	"NODE_PATHS": {
		"problem": "Hardcoded node paths don't exist",
		"symptoms": ["Node not found: /root/main", "Node not found: /root/thread_pool_autoload"],
		"fix_pattern": "get_node('/root/main') → get_tree().current_scene",
		"files_affected": [
			"jsh_scene_tree_system.gd",
			"JSH_console.gd",
			"jsh_thread_pool_manager.gd"
		],
		"reason": "Original project had different scene structure"
	}
}

static var API_CHANGES = {
	"GODOT_4_STRING_API": {
		"problem": "String.empty() removed in Godot 4",
		"symptoms": ["Cannot find member 'empty' in base 'String'"],
		"fix_pattern": ".empty() → .is_empty()",
		"files_affected": [
			"blink_animation_controller.gd"
		],
		"reason": "Godot 4 API changes"
	},
	"CONSTANT_ASSIGNMENT": {
		"problem": "Cannot assign to constants",
		"symptoms": ["Cannot assign a new value to a constant"],
		"fix_pattern": "Store in variable first, then modify",
		"files_affected": [
			"dimensional_color_system.gd"
		],
		"reason": "Constants are immutable by definition"
	}
}

static var DESIGN_ISSUES = {
	"AUTOLOAD_NAMING": {
		"problem": "Class name conflicts with autoload name",
		"symptoms": ["Class 'X' hides an autoload singleton"],
		"fix_pattern": "Rename class to avoid conflict",
		"files_affected": [
			"JSH_console.gd"
		],
		"reason": "Godot doesn't allow class names to match autoload names"
	},
	"STATIC_FUNCTION_CALLS": {
		"problem": "Static functions can't call instance methods",
		"symptoms": ["Cannot call non-static function from static function"],
		"fix_pattern": "Make function non-static or use Engine.get_main_loop()",
		"files_affected": [
			"jsh_adapter.gd"
		],
		"reason": "Static context doesn't have access to instance"
	}
}

static var WARNING_FIXES = {
	"UNUSED_PARAMETER": {
		"problem": "Parameter declared but never used",
		"symptoms": ["The parameter '", "' is never used in the function"],
		"fix_pattern": "param -> _param (prefix with underscore)",
		"files_affected": [
			"Most files with interface methods"
		],
		"reason": "Parameters required for interface compatibility but not used in implementation"
	},
	"UNUSED_VARIABLE": {
		"problem": "Variable declared but never used",
		"symptoms": ["The local variable '", "' is declared but never used"],
		"fix_pattern": "var name -> var _name or remove if not needed",
		"files_affected": [
			"Various files"
		],
		"reason": "Variable may be placeholder or leftover from refactoring"
	}
}

# Apply known fix automatically
static func apply_known_fix(error_message: String, _file_path: String) -> Dictionary:
	var result = {
		"fixed": false,
		"fix_applied": "",
		"reason": ""
	}
	
	# Check each category
	for category in [PATH_FIXES, API_CHANGES, DESIGN_ISSUES, WARNING_FIXES]:
		for fix_name in category:
			var fix = category[fix_name]
			
			# Check if error matches symptoms
			for symptom in fix.symptoms:
				if error_message.contains(symptom):
					result.fixed = true
					result.fix_applied = fix.fix_pattern
					result.reason = fix.reason
					return result
	
	return result

# Generate fix report for a file
static func get_file_fix_history(file_name: String) -> String:
	var report = "=== FIX HISTORY FOR %s ===\n\n" % file_name
	
	for category_name in ["PATH_FIXES", "API_CHANGES", "DESIGN_ISSUES", "WARNING_FIXES"]:
		var category = PATH_FIXES if category_name == "PATH_FIXES" else (API_CHANGES if category_name == "API_CHANGES" else (DESIGN_ISSUES if category_name == "DESIGN_ISSUES" else WARNING_FIXES))
		
		for fix_name in category:
			var fix = category[fix_name]
			if file_name in fix.files_affected:
				report += "FIX: %s\n" % fix_name
				report += "  Problem: %s\n" % fix.problem
				report += "  Pattern: %s\n" % fix.fix_pattern
				report += "  Reason: %s\n\n" % fix.reason
	
	return report

# Suggest preventive measures
static func get_prevention_tips() -> Array:
	return [
		"Always use get_node_or_null() instead of get_node() for safety",
		"Use relative paths for resources within the project",
		"Check Godot 4 migration guide for API changes",
		"Avoid naming classes the same as autoloads",
		"Test node paths exist before accessing them",
		"Prefix unused parameters with underscore",
		"Initialize dictionaries with default values"
	]

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