# ==================================================
# SCRIPT NAME: path_audit_system.gd
# DESCRIPTION: Comprehensive path audit for Universal Being project
# PURPOSE: Find all path references and validate folder structure
# CREATED: 2025-06-04 - Database Connection Audit
# AUTHOR: JSH + Claude Code
# ==================================================

extends Node
class_name PathAuditSystem

# ===== AUDIT RESULTS =====

var found_paths: Dictionary = {}  # file -> array of paths
var broken_paths: Array[Dictionary] = []
var missing_files: Array[String] = []
var folder_structure: Dictionary = {}
var path_mismatches: Array[Dictionary] = []

# ===== AUDIT CATEGORIES =====

var core_paths: Array[String] = []
var system_paths: Array[String] = []
var component_paths: Array[String] = []
var asset_paths: Array[String] = []
var scene_paths: Array[String] = []
var ui_paths: Array[String] = []

# ===== PATH PATTERNS =====

var path_patterns = {
	"core": RegEx.new(),
	"systems": RegEx.new(),
	"components": RegEx.new(),
	"beings": RegEx.new(),
	"assets": RegEx.new(),
	"scenes": RegEx.new(),
	"ui": RegEx.new()
}

func _ready() -> void:
	name = "PathAuditSystem"
	_compile_path_patterns()
	print("🔍 Path Audit System: Ready to analyze Universal Being database connections")

func _compile_path_patterns() -> void:
	"""Compile regex patterns for different path types"""
	path_patterns.core.compile("res://core/.*\\.gd")
	path_patterns.systems.compile("res://systems/.*\\.gd")
	path_patterns.components.compile("res://components/.*\\.(gd|ub\\.zip)")
	path_patterns.beings.compile("res://beings/.*\\.gd")
	path_patterns.assets.compile("res://assets/.*")
	path_patterns.scenes.compile("res://scenes/.*\\.tscn")
	path_patterns.ui.compile("res://ui/.*\\.gd")

# ===== MAIN AUDIT FUNCTIONS =====

func audit_all_paths() -> Dictionary:
	"""Conduct comprehensive path audit"""
	print("🔍 Starting comprehensive path audit...")
	
	# Clear previous results
	_clear_audit_results()
	
	# Scan all files
	_scan_project_structure()
	_extract_all_path_references()
	_validate_all_paths()
	_analyze_folder_structure()
	_identify_path_mismatches()
	
	# Generate report
	var report = _generate_audit_report()
	
	print("🔍 Path audit complete!")
	return report

func _clear_audit_results() -> void:
	"""Clear previous audit results"""
	found_paths.clear()
	broken_paths.clear()
	missing_files.clear()
	folder_structure.clear()
	path_mismatches.clear()
	
	core_paths.clear()
	system_paths.clear()
	component_paths.clear()
	asset_paths.clear()
	scene_paths.clear()
	ui_paths.clear()

func _scan_project_structure() -> void:
	"""Scan the entire project structure"""
	print("🔍 Scanning project structure...")
	folder_structure = _scan_directory("res://")

func _scan_directory(path: String) -> Dictionary:
	"""Recursively scan directory structure"""
	var result = {
		"path": path,
		"files": [],
		"folders": {},
		"file_count": 0,
		"folder_count": 0
	}
	
	var dir = DirAccess.open(path)
	if not dir:
		return result
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name if path != "res://" else "res://" + file_name
		
		if dir.current_is_dir():
			result.folders[file_name] = _scan_directory(full_path)
			result.folder_count += 1
		else:
			result.files.append(file_name)
			result.file_count += 1
		
		file_name = dir.get_next()
	
	dir.list_dir_end()
	return result

func _extract_all_path_references() -> void:
	"""Extract all path references from all files"""
	print("🔍 Extracting path references...")
	_extract_paths_from_gdscript_files()
	_extract_paths_from_scene_files()
	_extract_paths_from_project_file()

func _extract_paths_from_gdscript_files() -> void:
	"""Extract paths from all .gd files"""
	var gd_files = _find_all_files_with_extension(".gd")
	
	for file_path in gd_files:
		var paths = _extract_paths_from_file(file_path)
		if paths.size() > 0:
			found_paths[file_path] = paths

func _extract_paths_from_scene_files() -> void:
	"""Extract paths from .tscn files"""
	var scene_files = _find_all_files_with_extension(".tscn")
	
	for file_path in scene_files:
		var paths = _extract_paths_from_file(file_path)
		if paths.size() > 0:
			found_paths[file_path] = paths

func _extract_paths_from_project_file() -> void:
	"""Extract paths from project.godot"""
	var paths = _extract_paths_from_file("res://project.godot")
	if paths.size() > 0:
		found_paths["res://project.godot"] = paths

func _find_all_files_with_extension(extension: String) -> Array[String]:
	"""Find all files with specific extension"""
	var files: Array[String] = []
	_find_files_recursive("res://", extension, files)
	return files

func _find_files_recursive(path: String, extension: String, files: Array[String]) -> void:
	"""Recursively find files with extension"""
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name if path != "res://" else "res://" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			_find_files_recursive(full_path, extension, files)
		elif file_name.ends_with(extension):
			files.append(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

func _extract_paths_from_file(file_path: String) -> Array[String]:
	"""Extract all res:// paths from a file"""
	var paths: Array[String] = []
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return paths
	
	var content = file.get_as_text()
	file.close()
	
	# Find all res:// paths
	var regex = RegEx.new()
	regex.compile("\"res://[^\"]*\"")
	
	var results = regex.search_all(content)
	for result in results:
		var path = result.get_string().strip_edges().trim_prefix("\"").trim_suffix("\"")
		if path not in paths:
			paths.append(path)
	
	return paths

func _validate_all_paths() -> void:
	"""Validate all found paths exist"""
	print("🔍 Validating path references...")
	
	for source_file in found_paths:
		var paths = found_paths[source_file]
		for path in paths:
			if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
				broken_paths.append({
					"source_file": source_file,
					"broken_path": path,
					"type": _get_path_type(path)
				})

func _get_path_type(path: String) -> String:
	"""Determine the type of path"""
	if path.contains("/core/"):
		return "core"
	elif path.contains("/systems/"):
		return "systems"
	elif path.contains("/components/"):
		return "components"
	elif path.contains("/beings/"):
		return "beings"
	elif path.contains("/assets/"):
		return "assets"
	elif path.contains("/scenes/"):
		return "scenes"
	elif path.contains("/ui/"):
		return "ui"
	elif path.contains("/autoloads/"):
		return "autoloads"
	else:
		return "other"

func _analyze_folder_structure() -> void:
	"""Analyze folder structure for logical consistency"""
	print("🔍 Analyzing folder structure...")
	
	# Check for expected core folders
	var expected_folders = [
		"core", "systems", "components", "beings", 
		"assets", "scenes", "ui", "autoloads"
	]
	
	for folder in expected_folders:
		if not DirAccess.dir_exists_absolute("res://" + folder):
			missing_files.append("Missing folder: " + folder)

func _identify_path_mismatches() -> void:
	"""Identify potential path mismatches and naming inconsistencies"""
	print("🔍 Identifying path mismatches...")
	
	# Look for potential naming inconsistencies
	for source_file in found_paths:
		var paths = found_paths[source_file]
		for path in paths:
			_check_naming_consistency(source_file, path)

func _check_naming_consistency(source_file: String, referenced_path: String) -> void:
	"""Check if path follows naming conventions"""
	var file_name = referenced_path.get_file()
	
	# Check for snake_case in file names
	if file_name.contains(" ") or file_name != file_name.to_lower():
		if not file_name.ends_with(".tscn") and not file_name.ends_with(".png"):
			path_mismatches.append({
				"source": source_file,
				"path": referenced_path,
				"issue": "Non-snake_case filename",
				"suggestion": file_name.to_snake_case()
			})
	
	# Check for potential duplicates (similar names)
	_check_for_similar_paths(source_file, referenced_path)

func _check_for_similar_paths(source_file: String, path: String) -> void:
	"""Check for similar paths that might be duplicates"""
	var base_name = path.get_file().get_basename()
	
	# Look for files with similar names but different suffixes
	var variations = [
		base_name + "_enhanced.gd",
		base_name + "_fixed.gd", 
		base_name + "_improved.gd",
		base_name + "_final.gd"
	]
	
	for variation in variations:
		var full_variation_path = path.get_base_dir() + "/" + variation
		if ResourceLoader.exists(full_variation_path) and full_variation_path != path:
			path_mismatches.append({
				"source": source_file,
				"path": path,
				"issue": "Potential duplicate file",
				"duplicate": full_variation_path
			})

# ===== REPORT GENERATION =====

func _generate_audit_report() -> Dictionary:
	"""Generate comprehensive audit report"""
	var report = {
		"summary": {
			"total_files_scanned": _count_total_files(),
			"total_paths_found": _count_total_paths(),
			"broken_paths": broken_paths.size(),
			"missing_files": missing_files.size(),
			"path_mismatches": path_mismatches.size()
		},
		"broken_paths": broken_paths,
		"missing_files": missing_files,
		"path_mismatches": path_mismatches,
		"folder_structure": folder_structure,
		"recommendations": _generate_recommendations()
	}
	
	return report

func _count_total_files() -> int:
	"""Count total files scanned"""
	return found_paths.size()

func _count_total_paths() -> int:
	"""Count total paths found"""
	var total = 0
	for file in found_paths:
		total += found_paths[file].size()
	return total

func _generate_recommendations() -> Array[String]:
	"""Generate recommendations for fixing issues"""
	var recommendations: Array[String] = []
	
	if broken_paths.size() > 0:
		recommendations.append("Fix %d broken path references" % broken_paths.size())
	
	if path_mismatches.size() > 0:
		recommendations.append("Review %d potential file duplicates/naming issues" % path_mismatches.size())
	
	if missing_files.size() > 0:
		recommendations.append("Create %d missing folders/files" % missing_files.size())
	
	recommendations.append("Standardize all file names to snake_case")
	recommendations.append("Consolidate duplicate files (SystemBootstrap trilogy, Cursor variations)")
	recommendations.append("Organize components into logical subfolders")
	
	return recommendations

# ===== PUBLIC API =====

func audit_specific_folder(folder_path: String) -> Dictionary:
	"""Audit a specific folder"""
	print("🔍 Auditing folder: %s" % folder_path)
	
	var folder_paths: Dictionary = {}
	var folder_files = _find_all_files_with_extension(".gd")
	
	for file_path in folder_files:
		if file_path.begins_with(folder_path):
			var paths = _extract_paths_from_file(file_path)
			if paths.size() > 0:
				folder_paths[file_path] = paths
	
	return folder_paths

func check_path_exists(path: String) -> bool:
	"""Check if a specific path exists"""
	return ResourceLoader.exists(path) or FileAccess.file_exists(path)

func suggest_path_fix(broken_path: String) -> String:
	"""Suggest a fix for a broken path"""
	var base_name = broken_path.get_file()
	var dir_path = broken_path.get_base_dir()
	
	# Try common variations
	var suggestions = [
		dir_path + "/" + base_name.to_lower(),
		dir_path + "/" + base_name.to_snake_case(),
		"res://core/" + base_name,
		"res://systems/" + base_name,
		"res://components/" + base_name
	]
	
	for suggestion in suggestions:
		if check_path_exists(suggestion):
			return suggestion
	
	return "No automatic fix found"

func print_audit_summary() -> void:
	"""Print a summary of the audit results"""
	print("🔍 PATH AUDIT SUMMARY:")
	print("  Files scanned: %d" % _count_total_files())
	print("  Paths found: %d" % _count_total_paths())
	print("  Broken paths: %d" % broken_paths.size())
	print("  Missing files: %d" % missing_files.size())
	print("  Path mismatches: %d" % path_mismatches.size())
	
	if broken_paths.size() > 0:
		print("📋 BROKEN PATHS:")
		for i in range(min(5, broken_paths.size())):
			var broken = broken_paths[i]
			print("  - %s references missing: %s" % [broken.source_file, broken.broken_path])
	
	if path_mismatches.size() > 0:
		print("📋 PATH MISMATCHES:")
		for i in range(min(5, path_mismatches.size())):
			var mismatch = path_mismatches[i]
			print("  - %s: %s" % [mismatch.issue, mismatch.path])

# ===== AUTOMATED FIXES =====

func fix_common_path_issues() -> int:
	"""Automatically fix common path issues"""
	print("🔧 Attempting automated path fixes...")
	var fixes_applied = 0
	
	# This would require careful file modification
	# For now, just report what could be fixed
	for broken in broken_paths:
		var suggestion = suggest_path_fix(broken.broken_path)
		if suggestion != "No automatic fix found":
			print("🔧 Could fix: %s -> %s" % [broken.broken_path, suggestion])
			fixes_applied += 1
	
	return fixes_applied