# ==================================================
# SCRIPT NAME: run_path_audit.gd
# DESCRIPTION: Execute comprehensive path audit
# PURPOSE: Diagnose the evolving project's connection state
# CREATED: 2025-06-04 - Evolution Diagnosis
# AUTHOR: JSH + Claude Code
# ==================================================

extends Node

func _ready() -> void:
	print("🌟 UNIVERSAL BEING PROJECT EVOLUTION DIAGNOSIS")
	print("🌟 Analyzing the living, growing codebase...")
	
	# Create path audit system
	var PathAuditClass = load("res://tools/path_audit_system.gd")
	if not PathAuditClass:
		print("❌ Cannot load PathAuditSystem - creating simple audit")
		simple_audit()
		return
	
	var audit_system = PathAuditClass.new()
	add_child(audit_system)
	
	# Run comprehensive audit
	var report = audit_system.audit_all_paths()
	
	# Print evolution diagnosis
	print_evolution_diagnosis(report)
	
	# Save detailed report
	save_evolution_report(report)

func simple_audit() -> void:
	"""Simple audit without the full system"""
	print("🔍 Running simple path audit...")
	
	var broken_count = 0
	var total_count = 0
	
	# Check key files exist
	var key_files = [
		"res://core/UniversalBeing.gd",
		"res://core/FloodGates.gd", 
		"res://systems/storage/AkashicRecordsSystem.gd",
		"res://systems/AkashicLibrary.gd",
		"res://core/UniversalBeingInterface.gd"
	]
	
	for file_path in key_files:
		total_count += 1
		if not ResourceLoader.exists(file_path):
			print("❌ Missing: %s" % file_path)
			broken_count += 1
		else:
			print("✅ Found: %s" % file_path)
	
	print("🔍 Simple audit complete: %d/%d files found" % [total_count - broken_count, total_count])

func print_evolution_diagnosis(report: Dictionary) -> void:
	"""Print diagnosis of project evolution state"""
	print("")
	print("🌟 ==========================================")
	print("🌟 UNIVERSAL BEING PROJECT EVOLUTION STATE")
	print("🌟 ==========================================")
	
	var summary = report.get("summary", {})
	
	print("📊 PROJECT SCALE:")
	print("  Total Files: %d" % summary.get("total_files_scanned", 0))
	print("  Path References: %d" % summary.get("total_paths_found", 0))
	print("")
	
	print("🔧 EVOLUTION NEEDS:")
	print("  Broken Connections: %d" % summary.get("broken_paths", 0))
	print("  Missing Components: %d" % summary.get("missing_files", 0))
	print("  Path Mismatches: %d" % summary.get("path_mismatches", 0))
	print("")
	
	var health_percentage = calculate_project_health(summary)
	print("💝 PROJECT HEALTH: %.1f%%" % health_percentage)
	
	if health_percentage >= 90:
		print("🌟 Status: THRIVING - Project evolution is strong!")
	elif health_percentage >= 75:
		print("🌱 Status: GROWING - Minor evolution needs")
	elif health_percentage >= 50:
		print("🔧 Status: EVOLVING - Significant improvements needed")
	else:
		print("🚨 Status: REQUIRES ATTENTION - Critical evolution needs")
	
	print("")
	print("🎯 EVOLUTION PRIORITIES:")
	var recommendations = report.get("recommendations", [])
	for i in range(min(5, recommendations.size())):
		print("  %d. %s" % [i+1, recommendations[i]])

func calculate_project_health(summary: Dictionary) -> float:
	"""Calculate project health percentage"""
	var total_refs = summary.get("total_paths_found", 1)  # Avoid division by zero
	var broken = summary.get("broken_paths", 0)
	var missing = summary.get("missing_files", 0)
	var mismatches = summary.get("path_mismatches", 0)
	
	var issues = broken + missing + (mismatches * 0.5)  # Mismatches are less critical
	var health = max(0, 100 - (issues / float(total_refs) * 100))
	
	return health

func save_evolution_report(report: Dictionary) -> void:
	"""Save detailed evolution report"""
	var file = FileAccess.open("res://PROJECT_EVOLUTION_REPORT.md", FileAccess.WRITE)
	if not file:
		print("❌ Cannot save evolution report")
		return
	
	file.store_string("# Universal Being Project Evolution Report\n\n")
	file.store_string("Generated: %s\n\n" % Time.get_datetime_string_from_system())
	
	var summary = report.get("summary", {})
	file.store_string("## Evolution State\n\n")
	file.store_string("- **Total Files**: %d\n" % summary.get("total_files_scanned", 0))
	file.store_string("- **Path References**: %d\n" % summary.get("total_paths_found", 0))
	file.store_string("- **Broken Connections**: %d\n" % summary.get("broken_paths", 0))
	file.store_string("- **Missing Components**: %d\n" % summary.get("missing_files", 0))
	file.store_string("- **Health Score**: %.1f%%\n\n" % calculate_project_health(summary))
	
	# Broken paths details
	var broken_paths = report.get("broken_paths", [])
	if broken_paths.size() > 0:
		file.store_string("## Broken Connections\n\n")
		for broken in broken_paths:
			file.store_string("- `%s` references missing `%s`\n" % [broken.source_file, broken.broken_path])
		file.store_string("\n")
	
	# Evolution recommendations
	var recommendations = report.get("recommendations", [])
	if recommendations.size() > 0:
		file.store_string("## Evolution Priorities\n\n")
		for i in range(recommendations.size()):
			file.store_string("%d. %s\n" % [i+1, recommendations[i]])
	
	file.close()
	print("📝 Evolution report saved: res://PROJECT_EVOLUTION_REPORT.md")

func _input(event: InputEvent) -> void:
	"""Handle input for manual audit trigger"""
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F12:
			print("🔍 F12 pressed - Re-running evolution diagnosis...")
			get_tree().reload_current_scene()