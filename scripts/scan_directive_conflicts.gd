# ==================================================
# SCRIPT NAME: scan_directive_conflicts.gd
# DESCRIPTION: Run GDScript directive conflict scan on Universal Being project
# PURPOSE: Find actual var class_name, var type, etc. conflicts
# CREATED: 2025-01-06 - GDScript Directive Scan Execution
# AUTHOR: JSH + Claude Code - Universal Being Conflict Detection
# ==================================================

@tool
extends SceneTree

func _init():
	pass
	# Load the scanner
	var scanner_script = load("res://tools/gdscript_directive_scanner.gd")
	if not scanner_script:
		print("❌ Could not load gdscript_directive_scanner.gd")
		quit()
		return
	
	print("🚫 Running GDScript Directive Conflict Scan on Universal Being project...")
	print("Looking for variables that conflict with GDScript directives and built-in types")
	print("")
	
	# Run the scan
	var report = scanner_script.scan_project_for_directive_conflicts("res://")
	
	# Display results
	print(report.get_summary())
	print("")
	
	# Show detailed conflicts if found
	if report.total_conflicts > 0:
		print("📋 DETAILED CONFLICT REPORT:")
		print("")
		
		for conflict in report.conflicts:
			print("🚫 %s - %s:%d" % [conflict.severity, conflict.file_path.get_file(), conflict.line_number])
			print("   Issue: %s" % conflict.issue_description)
			print("   Fix: %s → %s" % [conflict.variable_name, conflict.suggested_fix])
			print("")
		
		# Generate fix script
		print("🔧 Generating automatic fix script...")
		var fix_script = scanner_script.generate_fix_script(report.conflicts)
		
		var script_file = FileAccess.open("res://fix_directive_conflicts.sh", FileAccess.WRITE)
		if script_file:
			script_file.store_string(fix_script)
			script_file.close()
			print("✅ Fix script saved to: res://fix_directive_conflicts.sh")
			print("   Run: chmod +x fix_directive_conflicts.sh && ./fix_directive_conflicts.sh")
		
		# Save detailed report
		var report_file = FileAccess.open("res://gdscript_directive_conflicts_report.txt", FileAccess.WRITE)
		if report_file:
			var detailed_report = []
			detailed_report.append(report.get_summary())
			detailed_report.append("")
			detailed_report.append("DETAILED CONFLICTS:")
			detailed_report.append("")
			
			for conflict in report.conflicts:
				detailed_report.append("File: %s:%d" % [conflict.file_path, conflict.line_number])
				detailed_report.append("Variable: %s" % conflict.variable_name)
				detailed_report.append("Conflict Type: %s" % conflict.conflict_type)
				detailed_report.append("Issue: %s" % conflict.issue_description)
				detailed_report.append("Suggested Fix: %s" % conflict.suggested_fix)
				detailed_report.append("Severity: %s" % conflict.severity)
				detailed_report.append("")
			
			report_file.store_string("\n".join(detailed_report))
			report_file.close()
			print("📄 Detailed report saved to: res://gdscript_directive_conflicts_report.txt")
	else:
		print("✅ No GDScript directive conflicts found!")
		print("   The Universal Being project follows proper GDScript naming conventions.")
	
	print("")
	print("🏛️ Universal Being Project - GDScript Directive Scan Complete")
	
	quit()