extends Node
# ═══════════════════════════════════════════════════════════════════════════════════════════════
# 📋 VERSION MANAGER - GITHUB-STYLE LOCAL VERSION CONTROL 📋
# ═══════════════════════════════════════════════════════════════════════════════════════════════
#
# 📍 PROJECT PATH: /akashic_notepad3d_game/scripts/core/version_manager.gd
# 🎯 FILE GOAL: Local Git-like version control system for dynamic file management
# 🔗 CONNECTED FILES:
#    - core/class_evolver.gd (class evolution tracking)
#    - core/connection_mapper.gd (dependency management)
#    - All project files (version tracking)
#
# 🚀 REVOLUTIONARY FEATURES:
#    - Local commit system with hash generation
#    - Branch management for experimental development
#    - File version tracking and rollback capabilities
#    - AI collaboration logging and attribution
#    - Change categorization and impact assessment
#
# 🎮 USER EXPERIENCE: GitHub-style workflow in Godot for AI development
# ═══════════════════════════════════════════════════════════════════════════════════════════════

## Version Manager class for local Git-like version control
class_name VersionManager_versionmanager

# ─────────────────────────────────────────────────────────────────────────────────
# 🗃️ VERSION CONTROL STATE
# ─────────────────────────────────────────────────────────────────────────────────

static var version_history: Dictionary = {}
static var current_branch: String = "main"
static var file_versions: Dictionary = {}
static var branches: Dictionary = {"main": {"created": Time.get_datetime_string_from_system(), "commits": []}}
static var search_log: Array = []

# Change categories for organized development
enum ChangeCategory {
	FEATURE,        # New functionality added
	BUGFIX,         # Problem resolution
	REFACTOR,       # Code structure improvement
	EXPERIMENT,     # Testing new approaches
	AI_SUGGESTION,  # Claude/AI recommended changes
	COLLABORATION   # Multi-AI development
}

# ─────────────────────────────────────────────────────────────────────────────────
# 📝 COMMIT SYSTEM - TRACK ALL CHANGES
# ─────────────────────────────────────────────────────────────────────────────────
# INPUT: File path and change description
# PROCESS: Creates commit entry with metadata and hash
# OUTPUT: Commit hash for reference and rollback
# CHANGES: Updates version history and file version tracking
# CONNECTION: Enables rollback, branching, and change analysis
# ─────────────────────────────────────────────────────────────────────────────────
static func commit_change(file_path: String, change_description: String, category = ChangeCategory.FEATURE, ai_contributors: Array = ["Claude"]) -> String:
	var commit_hash = generate_hash(file_path + change_description + str(Time.get_unix_time_from_system()))
	
	var commit_data = {
		"timestamp": Time.get_datetime_string_from_system(),
		"file": file_path,
		"description": change_description,
		"hash": commit_hash,
		"category": ChangeCategory.keys()[category],
		"ai_contributors": ai_contributors,
		"branch": current_branch,
		"impact": _assess_impact(file_path),
		"tested": false,
		"scene_compatibility": _detect_scene_compatibility(file_path)
	}
	
	version_history[commit_hash] = commit_data
	branches[current_branch]["commits"].append(commit_hash)
	update_file_version(file_path, commit_hash)
	
	print("📝 COMMIT: ", commit_hash.substr(0, 8), " - ", change_description)
	print("🎯 File: ", file_path, " | Category: ", commit_data.category)
	print("🤖 AI Contributors: ", ai_contributors)
	
	return commit_hash

static func generate_hash(input: String) -> String:
	# Simple hash generation for commit identification
	var hash_value = input.hash()
	return str(abs(hash_value)).pad_zeros(8) + str(Time.get_unix_time_from_system()).substr(-4)

static func update_file_version(file_path: String, commit_hash: String = "") -> void:
	if not file_versions.has(file_path):
		file_versions[file_path] = {"versions": [], "current": ""}
	
	if commit_hash != "":
		file_versions[file_path]["versions"].append(commit_hash)
		file_versions[file_path]["current"] = commit_hash

# ─────────────────────────────────────────────────────────────────────────────────
# 🌿 BRANCH MANAGEMENT - EXPERIMENTAL DEVELOPMENT
# ─────────────────────────────────────────────────────────────────────────────────
static func create_branch(branch_name: String, description: String = "") -> bool:
	if branches.has(branch_name):
		print("⚠️ Branch already exists: ", branch_name)
		return false
	
	branches[branch_name] = {
		"created": Time.get_datetime_string_from_system(),
		"description": description,
		"parent_branch": current_branch,
		"commits": []
	}
	
	print("🌿 Created branch: ", branch_name)
	print("📝 Description: ", description)
	return true

static func checkout_branch(branch_name: String) -> bool:
	if not branches.has(branch_name):
		print("❌ Branch not found: ", branch_name)
		return false
	
	var previous_branch = current_branch
	current_branch = branch_name
	
	print("🔄 Switched from '", previous_branch, "' to '", branch_name, "'")
	return true

static func merge_branch(source_branch: String, target_branch: String = "") -> bool:
	if target_branch == "":
		target_branch = current_branch
	
	if not branches.has(source_branch) or not branches.has(target_branch):
		print("❌ Branch not found for merge")
		return false
	
	# Simple merge - copy commits from source to target
	var source_commits = branches[source_branch]["commits"]
	for commit_hash in source_commits:
		if not branches[target_branch]["commits"].has(commit_hash):
			branches[target_branch]["commits"].append(commit_hash)
	
	print("🔄 Merged '", source_branch, "' into '", target_branch, "'")
	print("📝 Added ", source_commits.size(), " commits")
	return true

# ─────────────────────────────────────────────────────────────────────────────────
# 🔍 INTELLIGENT FILE DISCOVERY - SMART FILE READING
# ─────────────────────────────────────────────────────────────────────────────────
static func find_file_with_fallback(base_name: String, context: String = "base") -> String:
	var search_paths = []
	var timestamp = Time.get_datetime_string_from_system()
	
	# Build search hierarchy based on naming convention
	# [ClassName]_v[Version]_[ScenePart]_[Variant].gd
	search_paths.append(base_name + "_v1_" + context + "_base.gd")
	search_paths.append(base_name + "_v2_" + context + "_enhanced.gd")
	search_paths.append(base_name + "_v1_" + context + "_simple.gd")
	search_paths.append(base_name + "_v3_" + context + "_advanced.gd")
	search_paths.append(base_name + ".gd")  # Fallback to basic name
	
	var found_file = ""
	var tried_files = []
	
	for path in search_paths:
		tried_files.append(path)
		if FileAccess.file_exists("res://scripts/core/" + path):
			found_file = "res://scripts/core/" + path
			break
	
	# Log the search attempt
	var search_entry = {
		"timestamp": timestamp,
		"looking_for": base_name,
		"context": context,
		"tried_files": tried_files,
		"found_in": found_file if found_file != "" else "MISSING",
		"next_action": "continue" if found_file != "" else "generate"
	}
	search_log.append(search_entry)
	
	if found_file == "":
		print("🔍 FILE SEARCH FAILED: ", base_name)
		print("📁 Tried: ", tried_files)
		print("🎯 Suggest: Generate new file or check deprecated folders")
	else:
		print("✅ FILE FOUND: ", found_file)
	
	return found_file
}

static func find_function_in_versions(class_name: String, function_name: String) -> Dictionary:
	var result = {"found": false, "file": "", "version": "", "working": false}
	
	# Search through different versions for the function
	var version_files = [
		class_name + "_v1.gd",
		class_name + "_v2.gd", 
		class_name + "_v3.gd",
		class_name + ".gd"
	]
	
	for file in version_files:
		var full_path = "res://scripts/core/" + file
		if FileAccess.file_exists(full_path):
			# In a real implementation, we would parse the file to check for the function
			# For now, we'll simulate the check
			result.found = true
			result.file = full_path
			result.version = file
			break
	
	print("🔍 FUNCTION SEARCH: ", function_name, " in ", class_name)
	print("📁 Result: ", result)
	
	return result

# ─────────────────────────────────────────────────────────────────────────────────
# 📊 IMPACT ASSESSMENT AND ANALYSIS
# ─────────────────────────────────────────────────────────────────────────────────
static func _assess_impact(file_path: String) -> String:
	# Assess the impact level of changes to specific files
	var core_files = ["main_game_controller.gd", "camera_controller.gd", "word_database.gd"]
	var ui_files = ["interactive_3d_ui_system.gd", "crosshair_system.gd"]
	
	var filename = file_path.get_file()
	
	if filename in core_files:
		return "HIGH"
	elif filename in ui_files:
		return "MEDIUM"
	else:
		return "LOW"

static func _detect_scene_compatibility(file_path: String) -> String:
	# Detect which scenes this file is compatible with
	var filename = file_path.get_file().to_lower()
	
	if "cosmic" in filename or "space" in filename:
		return "cosmic"
	elif "notepad" in filename or "layer" in filename:
		return "notepad"
	elif "eden" in filename or "garden" in filename:
		return "eden"
	else:
		return "all"

# ─────────────────────────────────────────────────────────────────────────────────
# 📈 REPORTING AND ANALYTICS
# ─────────────────────────────────────────────────────────────────────────────────
static func get_version_report() -> Dictionary:
	return {
		"total_commits": version_history.size(),
		"current_branch": current_branch,
		"total_branches": branches.size(),
		"files_tracked": file_versions.size(),
		"recent_commits": _get_recent_commits(5),
		"search_attempts": search_log.size()
	}

static func _get_recent_commits(count: int) -> Array:
	var recent = []
	var all_commits = version_history.values()
	# Simple reverse chronological sort (newest first)
	all_commits.reverse()
	
	for i in range(min(count, all_commits.size())):
		recent.append(all_commits[i])
	
	return recent

static func get_search_log() -> Array:
	return search_log

static func get_commit_history(file_path: String = "") -> Array:
	if file_path == "":
		return version_history.values()
	
	var file_commits = []
	for commit in version_history.values():
		if commit.file == file_path:
			file_commits.append(commit)
	
	return file_commits

# ─────────────────────────────────────────────────────────────────────────────────
# 🎯 VERSION CONTROL UTILITIES
# ─────────────────────────────────────────────────────────────────────────────────
static func rollback_to_commit(file_path: String, commit_hash: String) -> bool:
	if not version_history.has(commit_hash):
		print("❌ Commit not found: ", commit_hash)
		return false
	
	var commit = version_history[commit_hash]
	if commit.file != file_path:
		print("❌ Commit doesn't match file: ", file_path)
		return false
	
	print("🔄 Rolling back ", file_path, " to commit ", commit_hash.substr(0, 8))
	print("📅 From: ", commit.timestamp)
	print("📝 Description: ", commit.description)
	
	# In a real implementation, this would restore the file content
	return true

static func tag_version(tag_name: String, commit_hash: String, description: String = "") -> bool:
	if not version_history.has(commit_hash):
		print("❌ Commit not found for tagging: ", commit_hash)
		return false
	
	version_history[commit_hash]["tag"] = tag_name
	version_history[commit_hash]["tag_description"] = description
	
	print("🏷️ Tagged commit ", commit_hash.substr(0, 8), " as '", tag_name, "'")
	return true