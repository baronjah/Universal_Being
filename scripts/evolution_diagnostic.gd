# ==================================================
# SCRIPT NAME: evolution_diagnostic.gd
# DESCRIPTION: Comprehensive Universal Being Project Evolution Diagnostic
# PURPOSE: Diagnose, fix, and validate the entire project foundation
# CREATED: 2025-06-04 - Evolution Validation Tool
# AUTHOR: JSH + Claude Code + The Vision
# ==================================================

extends Node
class_name EvolutionDiagnostic

# ===== DIAGNOSTIC STATE =====

var diagnostic_results: Dictionary = {}
var foundation_health: float = 0.0
var critical_issues: Array[Dictionary] = []
var evolution_recommendations: Array[String] = []
var all_file_paths: Array[String] = []
var broken_references: Array[Dictionary] = []

# ===== SIGNALS =====

signal diagnostic_complete(results: Dictionary)
signal issue_found(issue: Dictionary)
signal fix_applied(fix: String)

func _ready() -> void:
	name = "EvolutionDiagnostic"
	print("🔬 Evolution Diagnostic: Awakening...")
	print("🔬 Ready to analyze Universal Being project foundation")

# ===== MAIN DIAGNOSTIC FUNCTIONS =====

func run_complete_diagnosis() -> Dictionary:
	"""Run comprehensive project diagnosis"""
	print("🔬 ================================")
	print("🔬 UNIVERSAL BEING EVOLUTION DIAGNOSTIC")
	print("🔬 ================================")
	
	# Clear previous results
	_clear_diagnostic_state()
	
	# Run all diagnostic phases
	print("🔬 Phase 1: Scanning project structure...")
	_scan_project_structure()
	
	print("🔬 Phase 2: Validating core foundation...")
	_validate_core_foundation()
	
	print("🔬 Phase 3: Checking path references...")
	_check_all_path_references()
	
	print("🔬 Phase 4: Analyzing duplicates...")
	_analyze_duplicate_files()
	
	print("🔬 Phase 5: Evaluating evolution state...")
	_evaluate_evolution_state()
	
	print("🔬 Phase 6: Generating recommendations...")
	_generate_evolution_recommendations()
	
	# Calculate final health score
	foundation_health = _calculate_foundation_health()
	
	# Compile results
	diagnostic_results = _compile_diagnostic_results()
	
	print("🔬 ================================")
	print("🔬 DIAGNOSTIC COMPLETE")
	print("🔬 Foundation Health: %.1f%%" % foundation_health)
	print("🔬 Critical Issues: %d" % critical_issues.size())
	print("🔬 ================================")
	
	diagnostic_complete.emit(diagnostic_results)
	return diagnostic_results

func _clear_diagnostic_state() -> void:
	"""Clear all diagnostic state"""
	diagnostic_results.clear()
	critical_issues.clear()
	evolution_recommendations.clear()
	all_file_paths.clear()
	broken_references.clear()
	foundation_health = 0.0

# ===== PROJECT STRUCTURE ANALYSIS =====

func _scan_project_structure() -> void:
	"""Scan entire project structure"""
	print("🔍 Scanning project structure...")
	
	# Find all .gd files
	_find_all_gdscript_files("res://")
	
	# Find all .tscn files
	_find_all_scene_files("res://")
	
	print("🔍 Found %d total files to analyze" % all_file_paths.size())

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
			all_file_paths.append(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

func _find_all_scene_files(path: String) -> void:
	"""Recursively find all .tscn files"""
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = path + "/" + file_name if path != "res://" else "res://" + file_name
		
		if dir.current_is_dir() and not file_name.begins_with("."):
			_find_all_scene_files(full_path)
		elif file_name.ends_with(".tscn"):
			all_file_paths.append(full_path)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

# ===== CORE FOUNDATION VALIDATION =====

func _validate_core_foundation() -> void:
	"""Validate core Universal Being foundation"""
	print("🏛️ Validating core foundation...")
	
	# Check critical core files
	var core_files = {
		"res://core/UniversalBeing.gd": "Universal Being base class",
		"res://core/FloodGates.gd": "Scene tree guardian",
		"res://core/AkashicRecords.gd": "ZIP database system",
		"res://autoloads/SystemBootstrap.gd": "System bootstrap",
		"res://autoloads/GemmaAI.gd": "AI companion",
		"res://main.gd": "Main entry point",
		"res://project.godot": "Project configuration"
	}
	
	for file_path in core_files:
		var description = core_files[file_path]
		if ResourceLoader.exists(file_path):
			print("✅ %s: %s" % [description, file_path])
		else:
			var issue = {
				"type": "missing_core_file",
				"file": file_path,
				"description": description,
				"severity": "critical"
			}
			critical_issues.append(issue)
			issue_found.emit(issue)
			print("❌ MISSING: %s (%s)" % [description, file_path])
	
	# Check for Pentagon Architecture compliance
	_check_pentagon_compliance()
	
	# Check for duplicate core files
	_check_core_duplicates()

func _check_pentagon_compliance() -> void:
	"""Check Pentagon Architecture compliance"""
	print("🔺 Checking Pentagon Architecture compliance...")
	
	var pentagon_methods = [
		"pentagon_init", "pentagon_ready", "pentagon_process", 
		"pentagon_input", "pentagon_sewers"
	]
	
	# Check core UniversalBeing.gd
	if ResourceLoader.exists("res://core/UniversalBeing.gd"):
		var file = FileAccess.open("res://core/UniversalBeing.gd", FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			
			for method in pentagon_methods:
				if not content.contains("func " + method):
					var issue = {
						"type": "missing_pentagon_method",
						"file": "res://core/UniversalBeing.gd",
						"method": method,
						"severity": "high"
					}
					critical_issues.append(issue)
					print("⚠️ Missing Pentagon method: %s" % method)

func _check_core_duplicates() -> void:
	"""Check for duplicate core files"""
	print("🔍 Checking for duplicate core files...")
	
	var duplicate_patterns = [
		["SystemBootstrap.gd", "SystemBootstrap_Enhanced.gd", "SystemBootstrap_Fixed.gd"],
		["CursorUniversalBeing.gd", "CursorUniversalBeing_Enhanced.gd", "CursorUniversalBeing_Fixed.gd", "CursorUniversalBeing_Final.gd"],
		["logic_connector.gd", "logic_connector_singleton.gd"],
		["ConsoleTextLayer.gd"]  # Check if exists in multiple places
	]
	
	for pattern in duplicate_patterns:
		var found_files = []
		for file_variant in pattern:
			for file_path in all_file_paths:
				if file_path.get_file() == file_variant:
					found_files.append(file_path)
		
		if found_files.size() > 1:
			var issue = {
				"type": "duplicate_files",
				"files": found_files,
				"severity": "medium"
			}
			critical_issues.append(issue)
			print("⚠️ Duplicate files found: %s" % str(found_files))

# ===== PATH REFERENCE VALIDATION =====

func _check_all_path_references() -> void:
	"""Check all path references in all files"""
	print("🔗 Checking path references...")
	
	var total_refs = 0
	var broken_refs = 0
	
	for file_path in all_file_paths:
		if file_path.ends_with(".gd"):
			var refs = _extract_path_references(file_path)
			total_refs += refs.size()
			
			for ref in refs:
				if not _validate_path_reference(ref):
					broken_refs += 1
					broken_references.append({
						"source_file": file_path,
						"broken_path": ref,
						"type": _get_reference_type(ref)
					})
	
	print("🔗 Path references: %d total, %d broken" % [total_refs, broken_refs])
	
	if broken_refs > 0:
		var issue = {
			"type": "broken_path_references",
			"count": broken_refs,
			"total": total_refs,
			"severity": "high"
		}
		critical_issues.append(issue)

func _extract_path_references(file_path: String) -> Array[String]:
	"""Extract all res:// path references from a file"""
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

func _validate_path_reference(path: String) -> bool:
	"""Validate that a path reference exists"""
	return ResourceLoader.exists(path) or FileAccess.file_exists(path) or DirAccess.dir_exists_absolute(path)

func _get_reference_type(path: String) -> String:
	"""Get the type of path reference"""
	if path.contains("/core/"):
		return "core"
	elif path.contains("/systems/"):
		return "systems"
	elif path.contains("/components/"):
		return "components"
	elif path.contains("/autoloads/"):
		return "autoloads"
	elif path.contains("/scenes/"):
		return "scenes"
	else:
		return "other"

# ===== DUPLICATE FILE ANALYSIS =====

func _analyze_duplicate_files() -> void:
	"""Analyze duplicate and similar files"""
	print("🔄 Analyzing duplicate files...")
	
	var file_groups = {}
	
	# Group files by base name
	for file_path in all_file_paths:
		var base_name = file_path.get_file().get_basename()
		
		# Look for variations
		var variations = [
			"_enhanced", "_fixed", "_improved", "_final", "_v2", "_new"
		]
		
		var clean_name = base_name
		for variation in variations:
			clean_name = clean_name.replace(variation, "")
		
		if not file_groups.has(clean_name):
			file_groups[clean_name] = []
		
		file_groups[clean_name].append(file_path)
	
	# Report groups with multiple files
	for group_name in file_groups:
		var files = file_groups[group_name]
		if files.size() > 1:
			print("🔄 Multiple versions of '%s': %s" % [group_name, str(files)])

# ===== EVOLUTION STATE EVALUATION =====

func _evaluate_evolution_state() -> void:
	"""Evaluate the evolution state of the project"""
	print("🌱 Evaluating evolution state...")
	
	# Check implementation completeness vs The First Impact vision
	var expected_systems = [
		"core/UniversalBeing.gd",
		"core/FloodGates.gd", 
		"core/AkashicRecords.gd",
		"core/UniversalBeingInterface.gd",  # NEW addition
		"systems/LogicConnectorSystem.gd",  # Should exist
		"autoloads/GemmaAI.gd"
	]
	
	var implemented_count = 0
	for system in expected_systems:
		if ResourceLoader.exists("res://" + system):
			implemented_count += 1
		else:
			print("🌱 Missing expected system: %s" % system)
	
	var completion_percentage = (implemented_count / float(expected_systems.size())) * 100
	print("🌱 Evolution completion: %.1f%% (%d/%d systems)" % [completion_percentage, implemented_count, expected_systems.size()])

# ===== RECOMMENDATION GENERATION =====

func _generate_evolution_recommendations() -> void:
	"""Generate recommendations for evolution"""
	print("💡 Generating evolution recommendations...")
	
	evolution_recommendations.clear()
	
	# Priority 1: Critical Issues
	if critical_issues.size() > 0:
		evolution_recommendations.append("🚨 Fix %d critical issues immediately" % critical_issues.size())
	
	# Priority 2: Broken References
	if broken_references.size() > 0:
		evolution_recommendations.append("🔗 Fix %d broken path references" % broken_references.size())
	
	# Priority 3: Consolidation
	evolution_recommendations.append("🔄 Consolidate SystemBootstrap trilogy into single enhanced version")
	evolution_recommendations.append("🎯 Merge Cursor variations, keep Final version as primary")
	evolution_recommendations.append("🔌 Enhance Logic Connector system for universal action access")
	
	# Priority 4: Missing Systems
	evolution_recommendations.append("🎨 Complete interface system with creation tools")
	evolution_recommendations.append("🤖 Build Gemma AI collaboration interfaces")
	evolution_recommendations.append("📖 Implement 4D timeline story system")
	
	# Priority 5: Evolution Features
	evolution_recommendations.append("🌌 Build complete Akashic Action Registry")
	evolution_recommendations.append("🔮 Implement Universal Being evolution/multiplication")
	evolution_recommendations.append("📦 Create 3D chunk system as living database")

# ===== HEALTH CALCULATION =====

func _calculate_foundation_health() -> float:
	"""Calculate overall foundation health percentage"""
	var health_factors = {
		"core_files_present": 30.0,
		"no_critical_issues": 25.0,
		"path_references_valid": 20.0,
		"minimal_duplicates": 15.0,
		"evolution_progress": 10.0
	}
	
	var total_health = 0.0
	
	# Core files present
	var core_files = ["res://core/UniversalBeing.gd", "res://core/FloodGates.gd", "res://core/AkashicRecords.gd"]
	var core_present = 0
	for file in core_files:
		if ResourceLoader.exists(file):
			core_present += 1
	total_health += (core_present / float(core_files.size())) * health_factors.core_files_present
	
	# No critical issues
	var critical_count = 0
	for issue in critical_issues:
		if issue.severity == "critical":
			critical_count += 1
	var critical_health = max(0, 1 - (critical_count / 5.0))  # 5+ critical = 0 health
	total_health += critical_health * health_factors.no_critical_issues
	
	# Path references valid
	var total_refs = 0
	var broken_refs = broken_references.size()
	for file_path in all_file_paths:
		if file_path.ends_with(".gd"):
			total_refs += _extract_path_references(file_path).size()
	var path_health = 1.0 if total_refs == 0 else max(0, 1 - (broken_refs / float(total_refs)))
	total_health += path_health * health_factors.path_references_valid
	
	# Minimal duplicates (simplified)
	var duplicate_count = 0
	for issue in critical_issues:
		if issue.type == "duplicate_files":
			duplicate_count += 1
	var duplicate_health = max(0, 1 - (duplicate_count / 3.0))
	total_health += duplicate_health * health_factors.minimal_duplicates
	
	# Evolution progress (simplified - based on file count)
	var evolution_health = min(1.0, all_file_paths.size() / 100.0)  # 100+ files = full health
	total_health += evolution_health * health_factors.evolution_progress
	
	return total_health

# ===== RESULTS COMPILATION =====

func _compile_diagnostic_results() -> Dictionary:
	"""Compile all diagnostic results"""
	return {
		"foundation_health": foundation_health,
		"total_files": all_file_paths.size(),
		"critical_issues": critical_issues,
		"broken_references": broken_references,
		"evolution_recommendations": evolution_recommendations,
		"timestamp": Time.get_datetime_string_from_system()
	}

# ===== AUTOMATED FIXES =====

func apply_automated_fixes() -> void:
	"""Apply automated fixes for common issues"""
	print("🔧 Applying automated fixes...")
	
	var fixes_applied = 0
	
	# Fix 1: Create missing directories
	var required_dirs = [
		"res://tools/",
		"res://debug/",
		"res://tests/"
	]
	
	for dir_path in required_dirs:
		if not DirAccess.dir_exists_absolute(dir_path):
			DirAccess.open("res://").make_dir_recursive(dir_path.replace("res://", ""))
			fix_applied.emit("Created missing directory: " + dir_path)
			fixes_applied += 1
	
	print("🔧 Applied %d automated fixes" % fixes_applied)

# ===== PUBLIC API =====

func save_diagnostic_report() -> void:
	"""Save diagnostic report to file"""
	var file = FileAccess.open("res://EVOLUTION_DIAGNOSTIC_REPORT.md", FileAccess.WRITE)
	if not file:
		print("❌ Cannot save diagnostic report")
		return
	
	file.store_string("# Universal Being Evolution Diagnostic Report\n\n")
	file.store_string("Generated: %s\n\n" % Time.get_datetime_string_from_system())
	file.store_string("## Foundation Health: %.1f%%\n\n" % foundation_health)
	
	# Critical Issues
	if critical_issues.size() > 0:
		file.store_string("## Critical Issues (%d)\n\n" % critical_issues.size())
		for issue in critical_issues:
			file.store_string("- **%s**: %s\n" % [issue.type, str(issue)])
		file.store_string("\n")
	
	# Broken References
	if broken_references.size() > 0:
		file.store_string("## Broken References (%d)\n\n" % broken_references.size())
		for ref in broken_references.slice(0, 10):  # Limit to first 10
			file.store_string("- `%s` → `%s`\n" % [ref.source_file, ref.broken_path])
		if broken_references.size() > 10:
			file.store_string("- ... and %d more\n" % (broken_references.size() - 10))
		file.store_string("\n")
	
	# Recommendations
	file.store_string("## Evolution Recommendations\n\n")
	for i in range(evolution_recommendations.size()):
		file.store_string("%d. %s\n" % [i+1, evolution_recommendations[i]])
	
	file.close()
	print("📝 Diagnostic report saved: res://EVOLUTION_DIAGNOSTIC_REPORT.md")

func print_summary() -> void:
	"""Print diagnostic summary"""
	print("")
	print("🔬 ================================")
	print("🔬 EVOLUTION DIAGNOSTIC SUMMARY")
	print("🔬 ================================")
	print("🔬 Foundation Health: %.1f%%" % foundation_health)
	print("🔬 Total Files Analyzed: %d" % all_file_paths.size())
	print("🔬 Critical Issues: %d" % critical_issues.size())
	print("🔬 Broken References: %d" % broken_references.size())
	print("🔬 ================================")
	
	if foundation_health >= 90:
		print("🌟 STATUS: EXCELLENT - Foundation is very strong!")
	elif foundation_health >= 75:
		print("✅ STATUS: GOOD - Minor issues to address")
	elif foundation_health >= 50:
		print("⚠️ STATUS: NEEDS WORK - Significant issues found")
	else:
		print("🚨 STATUS: CRITICAL - Foundation needs major repairs")
	
	print("🔬 ================================")
	
	# Show top recommendations
	if evolution_recommendations.size() > 0:
		print("🎯 TOP PRIORITIES:")
		for i in range(min(3, evolution_recommendations.size())):
			print("  %d. %s" % [i+1, evolution_recommendations[i]])
	
	print("🔬 ================================")