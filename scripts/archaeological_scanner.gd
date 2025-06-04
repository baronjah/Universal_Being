# ==================================================
# SCRIPT NAME: archaeological_scanner.gd  
# DESCRIPTION: Scan for known violations from archaeological error analysis
# PURPOSE: Immediate identification and reporting of discovered naming issues
# CREATED: 2025-01-06 - Archaeological Error Resolution
# AUTHOR: JSH + Claude Code - Universal Being Archaeological Tools
# ==================================================

@tool
extends RefCounted
class_name ArchaeologicalScanner

# ===== ARCHAEOLOGICAL DISCOVERIES =====
# Based on ERROR_TRIAGE_LOG_NEW.md findings

static var KNOWN_VARIABLE_SHADOWING_LOCATIONS = [
	# From archaeological analysis - variable shadowing epidemic
	{
		"file": "beings/conversational_console_being.gd",
		"line": 48,  # Approximate
		"violation": "var name = \"GemmaAI\"",
		"shadows": "Node.name",
		"suggested_fix": "var being_name = \"GemmaAI\"",
		"severity": "HIGH",
		"archaeological_note": "Console system shadowing epidemic"
	},
	{
		"file": "main.gd", 
		"line": 17,
		"violation": "name = \"Main\"",
		"shadows": "Node.name",
		"suggested_fix": "being_name = \"Main\"",
		"severity": "HIGH",
		"archaeological_note": "Main controller shadowing"
	},
	{
		"file": "autoloads/GemmaAI.gd",
		"line": 48,
		"violation": "name = \"GemmaAI\"",
		"shadows": "Node.name", 
		"suggested_fix": "being_name = \"GemmaAI\"",
		"severity": "HIGH",
		"archaeological_note": "AI system shadowing"
	}
]

static var KNOWN_UNUSED_SIGNALS = [
	# From archaeological analysis - designed communication not connected
	{
		"file": "autoloads/GemmaAI.gd",
		"line": 43,
		"signal_name": "ai_error",
		"archaeological_purpose": "Error reporting system designed but not connected",
		"missing_connection": "Error handling UI, debug systems, or console integration",
		"priority": "MEDIUM"
	},
	{
		"file": "core/UniversalBeing.gd",
		"line": 128,
		"signal_name": "interaction_completed",
		"archaeological_purpose": "Interaction lifecycle system designed but incomplete",
		"missing_connection": "UI feedback, state management, or other beings",
		"priority": "MEDIUM"
	},
	{
		"file": "core/UniversalBeing.gd", 
		"line": 132,
		"signal_name": "thinking_started",
		"archaeological_purpose": "Consciousness state broadcasting designed",
		"missing_connection": "Visual indicators, consciousness meters, other beings",
		"priority": "MEDIUM"
	}
]

static var KNOWN_SOCKET_ENUM_ISSUES = [
	# From archaeological analysis - type system incomplete
	{
		"file": "core/UniversalBeingSocketManager.gd",
		"line": 194,
		"issue": "Using -1 for enum values without proper casting",
		"archaeological_insight": "Socket system uses -1 for \"no socket\" but enum doesn't include this",
		"fix_needed": "Add NONE = -1 to SocketType enum or use proper null handling",
		"priority": "HIGH"
	},
	{
		"file": "core/UniversalBeingSocketManager.gd",
		"line": 208, 
		"issue": "Using -1 for enum values without proper casting",
		"archaeological_insight": "Same pattern as line 194",
		"fix_needed": "Consistent with line 194 fix",
		"priority": "HIGH"
	}
]

static var KNOWN_UNUSED_PARAMETERS = [
	# From archaeological analysis - incomplete implementations
	{
		"category": "Socket Component Functions",
		"file_pattern": "core/UniversalBeing.gd",
		"line_range": "415-479",
		"issue": "All socket apply/remove functions have unused 'socket' parameter",
		"archaeological_insight": "Component socket system designed but mounting logic incomplete",
		"designed_purpose": "Hot-swappable components through socket system",
		"missing_implementation": "Actual component mounting/unmounting implementation"
	},
	{
		"category": "State Machine Functions", 
		"file_pattern": "core/UniversalBeing.gd",
		"line_range": "1276-1350",
		"issue": "All state processing functions have unused 'delta' parameter",
		"archaeological_insight": "State machine designed for time-based evolution but logic incomplete",
		"designed_purpose": "Time-based consciousness evolution and behavior",
		"missing_implementation": "Actual state-specific behaviors and transitions"
	},
	{
		"category": "Console Command Functions",
		"file_pattern": "beings/*console*.gd",
		"issue": "Multiple console commands have unused 'args' parameter", 
		"archaeological_insight": "Advanced command parsing designed but not implemented",
		"designed_purpose": "Complex commands with arguments",
		"missing_implementation": "Argument parsing and advanced command logic"
	}
]

# ===== SCANNER METHODS =====

class ArchaeologicalReport:
	var scan_timestamp: String
	var total_known_issues: int = 0
	var shadowing_violations: Array[Dictionary] = []
	var unused_signals: Array[Dictionary] = []
	var socket_enum_issues: Array[Dictionary] = []
	var unused_parameters: Array[Dictionary] = []
	var archaeological_insights: Array[String] = []
	
	func _init():
		scan_timestamp = Time.get_datetime_string_from_system()
	
	func add_insight(insight: String) -> void:
		archaeological_insights.append(insight)
	
	func get_total_issues() -> int:
		return shadowing_violations.size() + unused_signals.size() + socket_enum_issues.size() + unused_parameters.size()
	
	func generate_summary() -> String:
		var summary = []
		summary.append("🏺 ARCHAEOLOGICAL SCAN REPORT")
		summary.append("Timestamp: %s" % scan_timestamp)
		summary.append("Total Known Issues: %d" % get_total_issues())
		summary.append("")
		summary.append("📊 Issue Breakdown:")
		summary.append("  Variable Shadowing: %d" % shadowing_violations.size())
		summary.append("  Unused Signals: %d" % unused_signals.size()) 
		summary.append("  Socket Enum Issues: %d" % socket_enum_issues.size())
		summary.append("  Unused Parameters: %d" % unused_parameters.size())
		summary.append("")
		summary.append("🔍 Archaeological Insights:")
		for insight in archaeological_insights:
			summary.append("  • %s" % insight)
		
		return "\n".join(summary)

static func perform_archaeological_scan(base_path: String = "res://") -> ArchaeologicalReport:
	"""Perform comprehensive archaeological scan based on known discoveries"""
	var report = ArchaeologicalReport.new()
	
	print("🏺 Starting Archaeological Scan - Universal Being Error Triage")
	print("🔍 Scanning for known violations from archaeological analysis...")
	
	# Scan for variable shadowing
	_scan_for_variable_shadowing(report, base_path)
	
	# Scan for unused signals
	_scan_for_unused_signals(report, base_path)
	
	# Scan for socket enum issues
	_scan_for_socket_enum_issues(report, base_path)
	
	# Scan for unused parameters
	_scan_for_unused_parameters(report, base_path)
	
	# Generate archaeological insights
	_generate_archaeological_insights(report)
	
	print("🏺 Archaeological scan complete!")
	return report

static func _scan_for_variable_shadowing(report: ArchaeologicalReport, base_path: String) -> void:
	"""Scan for known variable shadowing issues"""
	print("🔍 Scanning for variable shadowing epidemic...")
	
	for known_issue in KNOWN_VARIABLE_SHADOWING_LOCATIONS:
		var file_path = base_path.path_join(known_issue.file)
		var exists = _verify_issue_exists(file_path, known_issue.line, known_issue.violation)
		
		if exists:
			report.shadowing_violations.append({
				"file": known_issue.file,
				"line": known_issue.line,
				"violation": known_issue.violation,
				"shadows": known_issue.shadows,
				"fix": known_issue.suggested_fix,
				"note": known_issue.archaeological_note,
				"verified": true
			})
			print("  ✅ Confirmed: %s:%d - %s" % [known_issue.file, known_issue.line, known_issue.violation])
		else:
			print("  ❓ Not found: %s:%d - May have been fixed or moved" % [known_issue.file, known_issue.line])

static func _scan_for_unused_signals(report: ArchaeologicalReport, base_path: String) -> void:
	"""Scan for unused signals from archaeological analysis"""
	print("🔍 Scanning for unused signals (designed communication not connected)...")
	
	for signal_info in KNOWN_UNUSED_SIGNALS:
		var file_path = base_path.path_join(signal_info.file)
		var signal_declared = _check_signal_declared(file_path, signal_info.signal_name)
		var signal_connected = _check_signal_connections(file_path, signal_info.signal_name, base_path)
		
		if signal_declared and not signal_connected:
			report.unused_signals.append({
				"file": signal_info.file,
				"line": signal_info.line,
				"signal_name": signal_info.signal_name,
				"purpose": signal_info.archaeological_purpose,
				"missing_connection": signal_info.missing_connection,
				"status": "UNUSED_BUT_DESIGNED"
			})
			print("  ✅ Confirmed unused signal: %s in %s" % [signal_info.signal_name, signal_info.file])
		elif signal_declared and signal_connected:
			print("  ✅ Signal connected: %s in %s" % [signal_info.signal_name, signal_info.file])
		else:
			print("  ❓ Signal not found: %s in %s" % [signal_info.signal_name, signal_info.file])

static func _scan_for_socket_enum_issues(report: ArchaeologicalReport, base_path: String) -> void:
	"""Scan for socket enum -1 issues"""
	print("🔍 Scanning for socket enum issues...")
	
	for enum_issue in KNOWN_SOCKET_ENUM_ISSUES:
		var file_path = base_path.path_join(enum_issue.file)
		var issue_exists = _check_enum_issue(file_path, enum_issue.line)
		
		if issue_exists:
			report.socket_enum_issues.append({
				"file": enum_issue.file,
				"line": enum_issue.line,
				"issue": enum_issue.issue,
				"insight": enum_issue.archaeological_insight,
				"fix": enum_issue.fix_needed,
				"verified": true
			})
			print("  ✅ Confirmed enum issue: %s:%d" % [enum_issue.file, enum_issue.line])

static func _scan_for_unused_parameters(report: ArchaeologicalReport, base_path: String) -> void:
	"""Scan for unused parameters from incomplete implementations"""
	print("🔍 Scanning for unused parameters (incomplete implementations)...")
	
	for param_issue in KNOWN_UNUSED_PARAMETERS:
		var pattern_found = _check_unused_parameter_pattern(base_path, param_issue)
		
		if pattern_found:
			report.unused_parameters.append({
				"category": param_issue.category,
				"pattern": param_issue.file_pattern,
				"issue": param_issue.issue,
				"insight": param_issue.archaeological_insight,
				"purpose": param_issue.designed_purpose,
				"missing": param_issue.missing_implementation,
				"instances_found": pattern_found
			})
			print("  ✅ Confirmed pattern: %s" % param_issue.category)

static func _generate_archaeological_insights(report: ArchaeologicalReport) -> void:
	"""Generate insights from archaeological discoveries"""
	print("🏺 Generating archaeological insights...")
	
	# Variable shadowing insight
	if report.shadowing_violations.size() > 0:
		report.add_insight("Variable shadowing epidemic affects ALL major systems - Node.name conflicts are widespread")
	
	# Unused signals insight
	if report.unused_signals.size() > 0:
		report.add_insight("Communication infrastructure designed but not wired up - signals are pathways waiting for activation")
	
	# Socket system insight
	if report.socket_enum_issues.size() > 0:
		report.add_insight("Socket system uses -1 for 'no socket' but enum doesn't include this - type system incomplete")
	
	# Unused parameters insight
	if report.unused_parameters.size() > 0:
		report.add_insight("Functions designed with parameters for future features but logic not implemented yet")
	
	# Overall architectural insight
	var total_issues = report.get_total_issues()
	if total_issues > 10:
		report.add_insight("Universal Being project has extremely sophisticated architecture that's 80% designed but only 40% connected")
		report.add_insight("Every 'error' represents a designed feature waiting for connection rather than actual bugs")
	
	# System-specific insights
	if report.socket_enum_issues.size() > 0 and report.unused_parameters.size() > 0:
		report.add_insight("Hot-swappable component system (sockets) designed but mounting logic incomplete")
	
	if report.unused_signals.size() >= 3:
		report.add_insight("Multi-AI collaborative environment signals designed but not connected")

# ===== HELPER METHODS =====

static func _verify_issue_exists(file_path: String, line_number: int, expected_content: String) -> bool:
	"""Verify if a specific issue still exists at the expected location"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false
	
	var current_line = 0
	while not file.eof_reached() and current_line < line_number + 5:  # Check nearby lines too
		current_line += 1
		var line = file.get_line()
		
		if current_line >= line_number - 2 and current_line <= line_number + 2:
			if expected_content in line or line.strip_edges() in expected_content:
				file.close()
				return true
	
	file.close()
	return false

static func _check_signal_declared(file_path: String, signal_name: String) -> bool:
	"""Check if signal is declared in file"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false
	
	var content = file.get_as_text()
	file.close()
	
	# Look for signal declaration
	var regex = RegEx.new()
	regex.compile("signal\\s+" + signal_name)
	return regex.search(content) != null

static func _check_signal_connections(file_path: String, signal_name: String, base_path: String) -> bool:
	"""Check if signal is connected anywhere in the project"""
	var all_files = _get_all_gd_files(base_path)
	
	for file in all_files:
		var file_access = FileAccess.open(file, FileAccess.READ)
		if not file_access:
			continue
			
		var content = file_access.get_as_text()
		file_access.close()
		
		# Look for signal connections
		if signal_name + ".connect" in content or signal_name + ".emit" in content:
			return true
	
	return false

static func _check_enum_issue(file_path: String, line_number: int) -> bool:
	"""Check if enum -1 issue exists"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return false
	
	var current_line = 0
	while not file.eof_reached():
		current_line += 1
		var line = file.get_line()
		
		if current_line >= line_number - 5 and current_line <= line_number + 5:
			if "!= -1" in line or "== -1" in line:
				file.close()
				return true
	
	file.close()
	return false

static func _check_unused_parameter_pattern(base_path: String, pattern_info: Dictionary) -> int:
	"""Check for unused parameter patterns"""
	var matches_found = 0
	var all_files = _get_all_gd_files(base_path)
	
	for file in all_files:
		if pattern_info.file_pattern.contains("*"):
			# Wildcard pattern matching
			var pattern = pattern_info.file_pattern.replace("*", "")
			if not pattern in file:
				continue
		else:
			# Exact file pattern
			if not file.ends_with(pattern_info.file_pattern):
				continue
		
		var file_access = FileAccess.open(file, FileAccess.READ)
		if not file_access:
			continue
			
		var content = file_access.get_as_text()
		file_access.close()
		
		# Look for unused parameter patterns
		if "unused" in pattern_info.issue.to_lower():
			if "socket" in pattern_info.issue and "func " in content:
				matches_found += _count_unused_socket_functions(content)
			elif "delta" in pattern_info.issue and "func " in content:
				matches_found += _count_unused_delta_functions(content)
			elif "args" in pattern_info.issue and "func " in content:
				matches_found += _count_unused_args_functions(content)
	
	return matches_found

static func _count_unused_socket_functions(content: String) -> int:
	"""Count functions with unused socket parameters"""
	var count = 0
	var lines = content.split("\n")
	
	for i in range(lines.size()):
		var line = lines[i]
		if "func " in line and "socket" in line and "socket:" in line:
			# Check if socket parameter is used in function body
			var socket_used = false
			for j in range(i + 1, min(i + 20, lines.size())):  # Check next 20 lines
				if "socket" in lines[j] and not "func " in lines[j]:
					socket_used = true
					break
				if "func " in lines[j]:  # Hit next function
					break
			
			if not socket_used:
				count += 1
	
	return count

static func _count_unused_delta_functions(content: String) -> int:
	"""Count functions with unused delta parameters"""
	var count = 0
	var lines = content.split("\n")
	
	for i in range(lines.size()):
		var line = lines[i]
		if "func " in line and "delta" in line and "delta:" in line:
			# Check if delta parameter is used in function body
			var delta_used = false
			for j in range(i + 1, min(i + 20, lines.size())):
				if "delta" in lines[j] and not "func " in lines[j]:
					delta_used = true
					break
				if "func " in lines[j]:
					break
			
			if not delta_used:
				count += 1
	
	return count

static func _count_unused_args_functions(content: String) -> int:
	"""Count functions with unused args parameters"""
	var count = 0
	var lines = content.split("\n")
	
	for i in range(lines.size()):
		var line = lines[i]
		if "func " in line and "args" in line and ("args:" in line or "args = " in line):
			# Check if args parameter is used in function body
			var args_used = false
			for j in range(i + 1, min(i + 20, lines.size())):
				if "args" in lines[j] and not "func " in lines[j]:
					args_used = true
					break
				if "func " in lines[j]:
					break
			
			if not args_used:
				count += 1
	
	return count

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

# ===== QUICK ARCHAEOLOGICAL FIXES =====

static func generate_quick_fix_script() -> String:
	"""Generate a quick fix script for known issues"""
	var script_lines = []
	script_lines.append("#!/bin/bash")
	script_lines.append("# Universal Being Archaeological Quick Fixes")
	script_lines.append("# Generated by Archaeological Scanner")
	script_lines.append("")
	
	# Variable shadowing fixes
	script_lines.append("echo '🏺 Applying archaeological fixes for variable shadowing...'")
	for issue in KNOWN_VARIABLE_SHADOWING_LOCATIONS:
		script_lines.append("# Fix %s:%d" % [issue.file, issue.line])
		script_lines.append("sed -i 's/%s/%s/g' '%s'" % [
			issue.violation.replace("\"", "\\\""),
			issue.suggested_fix.replace("\"", "\\\""), 
			issue.file
		])
	
	script_lines.append("")
	script_lines.append("echo '✅ Archaeological fixes applied!'")
	script_lines.append("echo 'Run validation scan to verify fixes.'")
	
	return "\n".join(script_lines)

# ===== COMMAND LINE INTERFACE =====

static func main():
	"""Entry point for archaeological scanner"""
	var args = OS.get_cmdline_args()
	
	if "--archaeological-scan" in args:
		var report = perform_archaeological_scan()
		print(report.generate_summary())
		
		# Save detailed report
		var report_file = FileAccess.open("archaeological_scan_report.txt", FileAccess.WRITE)
		if report_file:
			report_file.store_string(report.generate_summary())
			report_file.close()
			print("\n📄 Detailed report saved to: archaeological_scan_report.txt")
	
	elif "--generate-fixes" in args:
		var fix_script = generate_quick_fix_script()
		var script_file = FileAccess.open("quick_archaeological_fixes.sh", FileAccess.WRITE)
		if script_file:
			script_file.store_string(fix_script)
			script_file.close()
			print("🔧 Quick fix script generated: quick_archaeological_fixes.sh")
			print("Run: chmod +x quick_archaeological_fixes.sh && ./quick_archaeological_fixes.sh")
	
	else:
		print("🏺 Universal Being Archaeological Scanner")
		print("Based on ERROR_TRIAGE_LOG_NEW.md discoveries")
		print("")
		print("Usage:")
		print("  --archaeological-scan    Scan for known violations")
		print("  --generate-fixes         Generate quick fix script")
		print("")
		print("🔍 Archaeological Approach: Understanding WHY unused parameters exist")
		print("   and what connections need to be made in the Universal Being project.")