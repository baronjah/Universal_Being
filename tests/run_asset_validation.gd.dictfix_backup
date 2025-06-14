# Asset Validation Runner
# Run this script to validate all Universal Being assets

extends RefCounted

static func _run_validation():
	"""Main validation entry point"""
	print("🎨 Universal Being Asset Validation System")
	print("==========================================")
	
	# Validate all asset directories
	var asset_directories = [
		"res://assets/beings",
		"res://assets/components", 
		"res://assets/scenes",
		"res://assets/materials"
	]
	
	var all_reports: Array[UniversalBeingAssetChecker.ValidationReport] = []
	
	for directory in asset_directories:
		print("\n📁 Checking directory: %s" % directory)
		var reports = UniversalBeingAssetChecker.validate_all_assets_in_directory(directory)
		all_reports.append_array(reports)
		
		# Print directory summary
		if reports.size() > 0:
			_print_directory_summary(directory, reports)
		else:
			print("  No .ub.zip assets found")
	
	# Print overall summary
	print("\n" + "=".repeat(50))
	UniversalBeingAssetChecker.print_validation_summary(all_reports)
	
	# Generate detailed report if there are issues
	_generate_detailed_report(all_reports)

static func _print_directory_summary(directory: String, reports: Array[UniversalBeingAssetChecker.ValidationReport]) -> void:
	"""Print summary for a specific directory"""
	var valid = 0
	var issues = 0
	
	for report in reports:
		if report.result == UniversalBeingAssetChecker.ValidationResult.VALID:
			valid += 1
		else:
			issues += 1
	
	print("  📊 Assets: %d total, %d valid, %d with issues" % [reports.size(), valid, issues])

static func _generate_detailed_report(reports: Array[UniversalBeingAssetChecker.ValidationReport]) -> void:
	"""Generate detailed report file for assets with issues"""
	var has_issues = false
	var report_content = "# Universal Being Asset Validation Report\n"
	report_content += "Generated: %s\n\n" % Time.get_datetime_string_from_system()
	
	for report in reports:
		if report.result != UniversalBeingAssetChecker.ValidationResult.VALID:
			has_issues = true
			report_content += "## Asset: %s\n" % report.asset_path
			report_content += "Status: %s\n" % _result_to_string(report.result)
			report_content += "Pentagon Compliance: %s\n" % ("✅" if report.pentagon_compliance else "❌")
			report_content += "Consciousness Valid: %s\n\n" % ("✅" if report.consciousness_valid else "❌")
			
			if report.issues.size() > 0:
				report_content += "### Issues:\n"
				for issue in report.issues:
					var level_icon = _get_level_icon(issue.level)
					report_content += "- %s %s" % [level_icon, issue.message]
					if issue.file != "":
						report_content += " (%s)" % issue.file
					report_content += "\n"
				report_content += "\n"
	
	if has_issues:
		var file = FileAccess.open("res://assets/validation/last_validation_report.md", FileAccess.WRITE)
		if file:
			file.store_string(report_content)
			file.close()
			print("📝 Detailed report saved to: res://assets/validation/last_validation_report.md")

static func _result_to_string(result: UniversalBeingAssetChecker.ValidationResult) -> String:
	match result:
		UniversalBeingAssetChecker.ValidationResult.VALID: return "VALID"
		UniversalBeingAssetChecker.ValidationResult.WARNING: return "WARNING"
		UniversalBeingAssetChecker.ValidationResult.ERROR: return "ERROR" 
		UniversalBeingAssetChecker.ValidationResult.CRITICAL: return "CRITICAL"
		_: return "UNKNOWN"

static func _get_level_icon(level: UniversalBeingAssetChecker.ValidationResult) -> String:
	match level:
		UniversalBeingAssetChecker.ValidationResult.VALID: return "✅"
		UniversalBeingAssetChecker.ValidationResult.WARNING: return "⚠️"
		UniversalBeingAssetChecker.ValidationResult.ERROR: return "❌"
		UniversalBeingAssetChecker.ValidationResult.CRITICAL: return "🚨"
		_: return "❓"

# Auto-run when script is executed
static func _init():
	_run_validation()