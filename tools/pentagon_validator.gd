# ==================================================
# SCRIPT NAME: pentagon_validator.gd
# DESCRIPTION: Pentagon Architecture Compliance Validator
# PURPOSE: Validate that all Universal Beings follow the sacred 5-point lifecycle
# CREATED: 2025-06-04 - Pentagon Compliance Engine
# AUTHOR: JSH + Claude Code + Pentagon Architecture Council
# ==================================================

extends Node
class_name PentagonValidator

# ===============================================
# PENTAGON VALIDATION SYSTEM
# ===============================================

# Pentagon methods that MUST be implemented
const PENTAGON_METHODS = [
	"pentagon_init",
	"pentagon_ready", 
	"pentagon_process",
	"pentagon_input",
	"pentagon_sewers"
]

# Required super() call patterns
const SUPER_CALL_PATTERNS = {
	"pentagon_init": "super.pentagon_init()",
	"pentagon_ready": "super.pentagon_ready()",
	"pentagon_process": "super.pentagon_process(delta)",
	"pentagon_input": "super.pentagon_input(event)",
	"pentagon_sewers": "super.pentagon_sewers()"
}

# Validation results
var validation_results: Dictionary = {}
var total_beings_scanned: int = 0
var compliant_beings: int = 0
var non_compliant_beings: Array[Dictionary] = []

signal validation_complete(results: Dictionary)
signal being_validated(being_path: String, compliant: bool)

# ===============================================
# INITIALIZATION
# ===============================================

func _ready() -> void:
	name = "PentagonValidator"
	print("🔺 Pentagon Validator: Sacred geometry compliance system ready")

# ===============================================
# VALIDATION METHODS
# ===============================================

func validate_all_beings() -> Dictionary:
	"""Validate Pentagon compliance across entire project"""
	print("🔺 Starting comprehensive Pentagon Architecture validation...")
	
	_reset_validation_state()
	
	# Find all Universal Being scripts
	var being_scripts = _find_all_universal_being_scripts()
	print("🔺 Found %d Universal Being scripts to validate" % being_scripts.size())
	
	# Validate each script
	for script_path in being_scripts:
		var compliance_result = _validate_being_script(script_path)
		_process_validation_result(script_path, compliance_result)
	
	# Generate final report
	var final_results = _generate_validation_report()
	validation_complete.emit(final_results)
	
	return final_results

func validate_single_being(script_path: String) -> Dictionary:
	"""Validate Pentagon compliance for a single Universal Being"""
	print("🔺 Validating Pentagon compliance: %s" % script_path)
	
	return _validate_being_script(script_path)

# ===============================================
# SCRIPT DISCOVERY
# ===============================================

func _find_all_universal_being_scripts() -> Array[String]:
	"""Find all scripts that extend Universal Being"""
	var universal_being_scripts = []
	
	# Search in key directories
	var search_directories = [
		"res://beings/",
		"res://core/", 
		"res://components/",
		"res://systems/",
		"res://ui/",
		"res://examples/"
	]
	
	for directory in search_directories:
		_scan_directory_for_beings(directory, universal_being_scripts)
	
	return universal_being_scripts

func _scan_directory_for_beings(directory_path: String, beings_list: Array[String]) -> void:
	"""Recursively scan directory for Universal Being scripts"""
	var dir = DirAccess.open(directory_path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var file_path = directory_path + "/" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			# Recursively scan subdirectories
			_scan_directory_for_beings(file_path, beings_list)
		elif file_name.ends_with(".gd"):
			# Check if this script extends Universal Being
			if _script_extends_universal_being(file_path):
				beings_list.append(file_path)
		
		file_name = dir.get_next()

func _script_extends_universal_being(script_path: String) -> bool:
	"""Check if script extends UniversalBeing"""
	if not FileAccess.file_exists(script_path):
		return false
	
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return false
	
	var content = file.get_as_text()
	file.close()
	
	# Check for extends UniversalBeing
	var extends_patterns = [
		"extends UniversalBeing",
		"extends \"res://core/UniversalBeing.gd\"",
		"class_name.*extends UniversalBeing"
	]
	
	for pattern in extends_patterns:
		if content.contains(pattern):
			return true
	
	return false

# ===============================================
# COMPLIANCE VALIDATION
# ===============================================

func _validate_being_script(script_path: String) -> Dictionary:
	"""Validate Pentagon compliance for a specific script"""
	var validation_result = {
		"script_path": script_path,
		"pentagon_compliant": false,
		"methods_found": [],
		"methods_missing": [],
		"super_calls_correct": [],
		"super_calls_missing": [],
		"compliance_score": 0.0,
		"issues": [],
		"recommendations": []
	}
	
	if not FileAccess.file_exists(script_path):
		validation_result.issues.append("Script file not found")
		return validation_result
	
	var file = FileAccess.open(script_path, FileAccess.READ)
	if not file:
		validation_result.issues.append("Cannot read script file")
		return validation_result
	
	var content = file.get_as_text()
	file.close()
	
	# Check for Pentagon methods
	_validate_pentagon_methods(content, validation_result)
	
	# Check for proper super() calls
	_validate_super_calls(content, validation_result)
	
	# Calculate compliance score
	_calculate_compliance_score(validation_result)
	
	# Generate recommendations
	_generate_recommendations(validation_result)
	
	return validation_result

func _validate_pentagon_methods(content: String, result: Dictionary) -> void:
	"""Check if all Pentagon methods are implemented"""
	for method in PENTAGON_METHODS:
		var method_pattern = "func %s(" % method
		if content.contains(method_pattern):
			result.methods_found.append(method)
		else:
			result.methods_missing.append(method)
			result.issues.append("Missing Pentagon method: %s()" % method)

func _validate_super_calls(content: String, result: Dictionary) -> void:
	"""Check if proper super() calls are made in Pentagon methods"""
	for method in result.methods_found:
		var super_pattern = SUPER_CALL_PATTERNS.get(method, "")
		if super_pattern.is_empty():
			continue
		
		# Extract method body
		var method_body = _extract_method_body(content, method)
		if method_body.contains(super_pattern):
			result.super_calls_correct.append(method)
		else:
			result.super_calls_missing.append(method)
			result.issues.append("Missing super() call in %s(): Expected '%s'" % [method, super_pattern])

func _extract_method_body(content: String, method_name: String) -> String:
	"""Extract the body of a specific method"""
	var method_start = content.find("func %s(" % method_name)
	if method_start == -1:
		return ""
	
	# Find the opening brace or colon
	var brace_pos = content.find(":", method_start)
	if brace_pos == -1:
		return ""
	
	# Find the next function or end of file
	var next_func = content.find("\nfunc ", brace_pos)
	var method_end = next_func if next_func != -1 else content.length()
	
	return content.substr(brace_pos, method_end - brace_pos)

func _calculate_compliance_score(result: Dictionary) -> void:
	"""Calculate compliance score based on validation results"""
	var total_checks = PENTAGON_METHODS.size() * 2  # Methods + super calls
	var passed_checks = result.methods_found.size() + result.super_calls_correct.size()
	
	result.compliance_score = float(passed_checks) / total_checks
	result.pentagon_compliant = result.compliance_score >= 1.0

func _generate_recommendations(result: Dictionary) -> void:
	"""Generate actionable recommendations for compliance"""
	if result.methods_missing.size() > 0:
		result.recommendations.append("Implement missing Pentagon methods: %s" % ", ".join(result.methods_missing))
	
	if result.super_calls_missing.size() > 0:
		result.recommendations.append("Add required super() calls in: %s" % ", ".join(result.super_calls_missing))
	
	if result.pentagon_compliant:
		result.recommendations.append("✅ Perfect Pentagon compliance achieved!")
	elif result.compliance_score >= 0.8:
		result.recommendations.append("⚠️ Minor Pentagon compliance issues - close to perfect")
	else:
		result.recommendations.append("🚨 Major Pentagon compliance issues - requires attention")

# ===============================================
# VALIDATION PROCESSING
# ===============================================

func _reset_validation_state() -> void:
	"""Reset validation state for new run"""
	validation_results.clear()
	total_beings_scanned = 0
	compliant_beings = 0
	non_compliant_beings.clear()

func _process_validation_result(script_path: String, compliance_result: Dictionary) -> void:
	"""Process validation result for a being"""
	total_beings_scanned += 1
	validation_results[script_path] = compliance_result
	
	if compliance_result.pentagon_compliant:
		compliant_beings += 1
		print("  ✅ %s (%.1f%% compliant)" % [script_path, compliance_result.compliance_score * 100])
	else:
		non_compliant_beings.append(compliance_result)
		print("  ❌ %s (%.1f%% compliant)" % [script_path, compliance_result.compliance_score * 100])
		
		# Show issues
		for issue in compliance_result.issues:
			print("     - %s" % issue)
	
	being_validated.emit(script_path, compliance_result.pentagon_compliant)

func _generate_validation_report() -> Dictionary:
	"""Generate comprehensive validation report"""
	var compliance_percentage = (float(compliant_beings) / total_beings_scanned) * 100.0 if total_beings_scanned > 0 else 0.0
	
	var report = {
		"timestamp": Time.get_datetime_string_from_system(),
		"total_beings_scanned": total_beings_scanned,
		"compliant_beings": compliant_beings,
		"non_compliant_beings": non_compliant_beings.size(),
		"compliance_percentage": compliance_percentage,
		"validation_results": validation_results,
		"non_compliant_details": non_compliant_beings,
		"status": _get_compliance_status(compliance_percentage),
		"summary": _generate_summary_text(compliance_percentage)
	}
	
	print("\n🔺 === PENTAGON VALIDATION REPORT ===")
	print("🔺 Beings Scanned: %d" % total_beings_scanned)
	print("🔺 Compliant: %d" % compliant_beings)
	print("🔺 Non-Compliant: %d" % non_compliant_beings.size())
	print("🔺 Compliance: %.1f%%" % compliance_percentage)
	print("🔺 Status: %s" % report.status)
	print("🔺 ===================================")
	
	return report

func _get_compliance_status(percentage: float) -> String:
	"""Get compliance status based on percentage"""
	if percentage >= 95.0:
		return "EXCELLENT"
	elif percentage >= 85.0:
		return "GOOD"
	elif percentage >= 70.0:
		return "FAIR"
	else:
		return "NEEDS WORK"

func _generate_summary_text(percentage: float) -> String:
	"""Generate summary text for compliance report"""
	if percentage >= 95.0:
		return "Pentagon Architecture compliance is excellent! Almost all beings follow the sacred 5-point lifecycle."
	elif percentage >= 85.0:
		return "Pentagon Architecture compliance is good. Most beings follow the sacred lifecycle with minor issues."
	elif percentage >= 70.0:
		return "Pentagon Architecture compliance is fair. Several beings need Pentagon method implementations."
	else:
		return "Pentagon Architecture compliance needs significant work. Many beings are missing required methods."

# ===============================================
# FIX GENERATION
# ===============================================

func generate_compliance_fixes() -> Array[Dictionary]:
	"""Generate automated fixes for Pentagon compliance issues"""
	var fixes = []
	
	for being_result in non_compliant_beings:
		var fix = _generate_being_fix(being_result)
		if not fix.is_empty():
			fixes.append(fix)
	
	return fixes

func _generate_being_fix(being_result: Dictionary) -> Dictionary:
	"""Generate fix for a specific non-compliant being"""
	if being_result.pentagon_compliant:
		return {}
	
	var fix = {
		"script_path": being_result.script_path,
		"fix_type": "pentagon_compliance",
		"missing_methods": being_result.methods_missing,
		"missing_super_calls": being_result.super_calls_missing,
		"fix_code": _generate_fix_code(being_result)
	}
	
	return fix

func _generate_fix_code(being_result: Dictionary) -> String:
	"""Generate GDScript code to fix Pentagon compliance"""
	var fix_code = ""
	
	# Generate missing methods
	for method in being_result.methods_missing:
		fix_code += _generate_method_template(method) + "\n\n"
	
	return fix_code

func _generate_method_template(method_name: String) -> String:
	"""Generate template for a Pentagon method"""
	var templates = {
		"pentagon_init": """func pentagon_init() -> void:
	super.pentagon_init()  # ALWAYS call super first
	# Initialize being-specific properties here""",
		
		"pentagon_ready": """func pentagon_ready() -> void:
	super.pentagon_ready()  # ALWAYS call super first
	# Setup being connections and references here""",
		
		"pentagon_process": """func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)  # ALWAYS call super first
	# Being-specific frame processing here""",
		
		"pentagon_input": """func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)  # ALWAYS call super first
	# Handle being-specific input here""",
		
		"pentagon_sewers": """func pentagon_sewers() -> void:
	# Being-specific cleanup here
	super.pentagon_sewers()  # ALWAYS call super last"""
	}
	
	return templates.get(method_name, "# Method template not found")

# ===============================================
# PUBLIC API
# ===============================================

func get_compliance_summary() -> Dictionary:
	"""Get summary of current compliance state"""
	return {
		"total_beings": total_beings_scanned,
		"compliant_beings": compliant_beings,
		"compliance_percentage": (float(compliant_beings) / total_beings_scanned) * 100.0 if total_beings_scanned > 0 else 0.0,
		"non_compliant_count": non_compliant_beings.size()
	}

func export_validation_report(file_path: String) -> bool:
	"""Export validation report to file"""
	var report = _generate_validation_report()
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	if not file:
		print("❌ Cannot create report file: %s" % file_path)
		return false
	
	file.store_string(JSON.stringify(report, "\t"))
	file.close()
	
	print("✅ Validation report exported to: %s" % file_path)
	return true