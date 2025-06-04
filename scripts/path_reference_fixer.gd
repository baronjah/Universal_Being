# ==================================================
# SCRIPT NAME: path_reference_fixer.gd
# DESCRIPTION: Fix broken path references throughout the project
# PURPOSE: Update all res:// paths to correct locations based on diagnostic findings
# CREATED: 2025-06-04 - Foundation Repair Tool
# AUTHOR: JSH + Claude Code
# ==================================================

extends Node
class_name PathReferenceFixer

# Path mappings to fix broken references
var path_mappings = {
	# SystemBootstrap trilogy fixes
	"res://systems/FloodGates.gd": "res://core/FloodGates.gd",
	"res://systems/AkashicRecords.gd": "res://core/AkashicRecords.gd",
	"res://core/universal_being.gd": "res://core/UniversalBeing.gd",
	"res://scripts/core/UniversalBeing.gd": "res://core/UniversalBeing.gd",
	"res://core/flood_gates.gd": "res://core/FloodGates.gd",
	"res://core/akashic_records.gd": "res://core/AkashicRecords.gd",
	
	# Logic Connector fixes
	"res://debug/logic_connector.gd": "res://systems/debug/logic_connector_singleton.gd",
	
	# Console fixes
	"res://beings/ConsoleUniversalBeing.gd": "res://ui/ConsoleTextLayer.gd",
	
	# Asset validation fixes
	"res://assets/validation/last_validation_report.md": "res://assets/validation/validation_report.md",
	
	# Enhanced file mappings
	"res://autoloads/SystemBootstrap_Enhanced.gd": "res://autoloads/SystemBootstrap.gd",
	"res://autoloads/SystemBootstrap_Fixed.gd": "res://autoloads/SystemBootstrap.gd",
	"res://core/CursorUniversalBeing_Enhanced.gd": "res://core/CursorUniversalBeing.gd",
	"res://core/CursorUniversalBeing_Fixed.gd": "res://core/CursorUniversalBeing.gd",
	"res://core/CursorUniversalBeing_Final.gd": "res://core/CursorUniversalBeing.gd"
}

# Files to scan for path references
var files_to_fix: Array[String] = []
var fixes_applied: Array[Dictionary] = []

signal fix_complete(fixes_count: int)
signal fix_progress(current: int, total: int)

func _ready() -> void:
	name = "PathReferenceFixer"
	print("🔧 Path Reference Fixer: Ready to repair broken paths")

func scan_and_fix_all() -> void:
	"""Scan entire project and fix all broken path references"""
	print("🔧 Starting comprehensive path reference fix...")
	
	# Find all .gd files that might have path references
	_find_all_gdscript_files("res://")
	
	print("🔧 Found %d files to scan for path references" % files_to_fix.size())
	
	# Fix references in each file
	var total_fixes = 0
	for i in range(files_to_fix.size()):
		var file_path = files_to_fix[i]
		var file_fixes = fix_path_references_in_file(file_path)
		total_fixes += file_fixes
		
		fix_progress.emit(i + 1, files_to_fix.size())
		
		# Don't overwhelm the system
		if i % 10 == 0:
			await get_tree().process_frame
	
	print("🔧 Path fixing complete! Applied %d fixes across %d files" % [total_fixes, files_to_fix.size()])
	fix_complete.emit(total_fixes)

func fix_path_references_in_file(file_path: String) -> int:
	"""Fix path references in a single file"""
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return 0
	
	var content = file.get_as_text()
	file.close()
	
	var original_content = content
	var fixes_in_file = 0
	
	# Apply all path mappings
	for old_path in path_mappings:
		var new_path = path_mappings[old_path]
		
		# Only fix if the target exists or the old path is definitely wrong
		if ResourceLoader.exists(new_path) or not ResourceLoader.exists(old_path):
			var old_count = content.count(old_path)
			content = content.replace(old_path, new_path)
			var new_count = content.count(old_path)
			
			if old_count > new_count:
				var fixed_count = old_count - new_count
				fixes_in_file += fixed_count
				fixes_applied.append({
					"file": file_path,
					"old_path": old_path,
					"new_path": new_path,
					"count": fixed_count
				})
				print("🔧 Fixed %d references: %s → %s in %s" % [fixed_count, old_path, new_path, file_path.get_file()])
	
	# Write back if changes were made
	if content != original_content:
		var write_file = FileAccess.open(file_path, FileAccess.WRITE)
		if write_file:
			write_file.store_string(content)
			write_file.close()
	
	return fixes_in_file

func _find_all_gdscript_files(path: String) -> void:
	"""Recursively find all .gd files"""
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name if path != "res://" else "res://" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			_find_all_gdscript_files(full_path)
		elif file_name.ends_with(".gd"):
			files_to_fix.append(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

func validate_critical_paths() -> Dictionary:
	"""Validate critical paths that should exist"""
	var critical_paths = [
		"res://core/UniversalBeing.gd",
		"res://core/FloodGates.gd", 
		"res://core/AkashicRecords.gd",
		"res://autoloads/SystemBootstrap.gd",
		"res://autoloads/GemmaAI.gd",
		"res://core/CursorUniversalBeing.gd",
		"res://main.gd",
		"res://project.godot"
	]
	
	var results = {
		"total": critical_paths.size(),
		"existing": 0,
		"missing": []
	}
	
	for path in critical_paths:
		if ResourceLoader.exists(path) or FileAccess.file_exists(path):
			results.existing += 1
			print("✅ Critical path exists: %s" % path)
		else:
			results.missing.append(path)
			print("❌ Critical path missing: %s" % path)
	
	var health_percentage = (results.existing / float(results.total)) * 100
	print("🔧 Critical path health: %.1f%% (%d/%d)" % [health_percentage, results.existing, results.total])
	
	return results

func generate_fix_report() -> String:
	"""Generate a detailed report of all fixes applied"""
	var report = "# Path Reference Fix Report\n\n"
	report += "Generated: %s\n\n" % Time.get_datetime_string_from_system()
	report += "## Summary\n\n"
	report += "- Total fixes applied: %d\n" % fixes_applied.size()
	report += "- Files modified: %d\n\n" % files_to_fix.size()
	
	if fixes_applied.size() > 0:
		report += "## Fixes Applied\n\n"
		for fix in fixes_applied:
			report += "- **%s**: %s → %s (%d occurrences)\n" % [
				fix.file.get_file(), 
				fix.old_path, 
				fix.new_path, 
				fix.count
			]
	
	return report

func save_fix_report() -> void:
	"""Save the fix report to file"""
	var report = generate_fix_report()
	var file = FileAccess.open("res://PATH_REFERENCE_FIX_REPORT.md", FileAccess.WRITE)
	if file:
		file.store_string(report)
		file.close()
		print("📝 Fix report saved: res://PATH_REFERENCE_FIX_REPORT.md")