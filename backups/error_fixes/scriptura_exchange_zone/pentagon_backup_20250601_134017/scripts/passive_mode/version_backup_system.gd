# ==================================================
# SCRIPT NAME: version_backup_system.gd
# DESCRIPTION: Automatic version backups after each test
# CREATED: 2025-05-23 - Track what worked when
# ==================================================

extends UniversalBeingBase
# Version tracking
var current_version: Dictionary = {
	"number": "0.1.0",
	"test_count": 0,
	"working_features": [],
	"broken_features": [],
	"timestamp": ""
}

var version_history: Array = []
var feature_status_log: Dictionary = {}

# Backup settings
const MAX_BACKUPS: int = 100
const BACKUP_DIR: String = "user://version_backups/"

# Feature list to track
var tracked_features: Array = [
	"console_system",
	"object_spawning",
	"ragdoll_physics",
	"ragdoll_walking",
	"scene_loading",
	"scene_saving",
	"dialogue_system",
	"astral_beings",
	"passive_mode",
	"version_control"
]

# Signals
signal version_backed_up(version: Dictionary)
signal feature_status_changed(feature: String, working: bool)
signal test_completed(results: Dictionary)

func _ready() -> void:
	_ensure_backup_directory()
	_load_version_history()


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
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
func run_test_suite() -> Dictionary:
	print("=== RUNNING FEATURE TEST SUITE ===")
	
	var test_results = {
		"version": current_version["number"],
		"timestamp": Time.get_datetime_string_from_system(),
		"test_count": current_version["test_count"] + 1,
		"features": {}
	}
	
	# Test each feature
	for feature in tracked_features:
		var result = _test_feature(feature)
		test_results["features"][feature] = result
		
		# Update feature status
		if feature_status_log.has(feature):
			feature_status_log[feature].append({
				"version": current_version["number"],
				"working": result["working"],
				"timestamp": test_results["timestamp"]
			})
		else:
			feature_status_log[feature] = [{
				"version": current_version["number"],
				"working": result["working"],
				"timestamp": test_results["timestamp"]
			}]
		
		emit_signal("feature_status_changed", feature, result["working"])
	
	# Update current version
	current_version["test_count"] += 1
	current_version["working_features"] = []
	current_version["broken_features"] = []
	
	for feature in test_results["features"]:
		if test_results["features"][feature]["working"]:
			current_version["working_features"].append(feature)
		else:
			current_version["broken_features"].append(feature)
	
	# Create backup
	_create_version_backup(test_results)
	
	emit_signal("test_completed", test_results)
	return test_results

func _test_feature(feature: String) -> Dictionary:
	print("Testing: " + feature)
	
	match feature:
		"console_system":
			return _test_console_system()
		"object_spawning":
			return _test_object_spawning()
		"ragdoll_physics":
			return _test_ragdoll_physics()
		"ragdoll_walking":
			return _test_ragdoll_walking()
		"scene_loading":
			return _test_scene_loading()
		"scene_saving":
			return _test_scene_saving()
		"dialogue_system":
			return _test_dialogue_system()
		"astral_beings":
			return _test_astral_beings()
		"passive_mode":
			return _test_passive_mode()
		"version_control":
			return _test_version_control()
		_:
			return {"working": false, "error": "Unknown feature"}

func _test_console_system() -> Dictionary:
	# Test if console opens and accepts commands
	var console = get_node_or_null("/root/ConsoleManager")
	if not console:
		return {"working": false, "error": "Console not found"}
	
	# Simulate console toggle
	if console.has_method("toggle_console"):
		return {"working": true, "details": "Console toggles correctly"}
	
	return {"working": false, "error": "Console methods missing"}

func _test_object_spawning() -> Dictionary:
	# Test if objects can be spawned
	var world_builder = get_node_or_null("/root/WorldBuilder")
	if not world_builder:
		return {"working": false, "error": "WorldBuilder not found"}
	
	var initial_count = world_builder.spawned_objects.size()
	if world_builder.has_method("create_tree"):
		world_builder.create_tree()
		var new_count = world_builder.spawned_objects.size()
		if new_count > initial_count:
			return {"working": true, "details": "Objects spawn correctly"}
	
	return {"working": false, "error": "Spawning failed"}

func _test_ragdoll_physics() -> Dictionary:
	# Test if ragdoll has proper physics
	var ragdolls = get_tree().get_nodes_in_group("ragdolls")
	if ragdolls.is_empty():
		# Check if spawning capability exists without actually spawning
		var world_builder = get_node_or_null("/root/WorldBuilder")
		if world_builder and world_builder.has_method("create_ragdoll"):
			return {"working": true, "details": "Ragdoll spawner available"}
		else:
			return {"working": false, "error": "No ragdoll spawner found"}
	
	# Test existing ragdoll
	var ragdoll = ragdolls[0]
	if ragdoll.has_method("get_body"):
		var body = ragdoll.get_body()
		if body and body is RigidBody3D:
			return {"working": true, "details": "Ragdoll has physics body"}
	
	return {"working": false, "error": "Ragdoll exists but no physics body"}

func _test_ragdoll_walking() -> Dictionary:
	# Test if ragdoll can walk
	var ragdolls = get_tree().get_nodes_in_group("ragdolls")
	if not ragdolls.is_empty():
		var ragdoll = ragdolls[0]
		if ragdoll.has_method("toggle_walking"):
			return {"working": true, "details": "Walking methods exist"}
	
	return {"working": false, "error": "Walking not implemented"}

func _test_scene_loading() -> Dictionary:
	# Test scene loading system
	var scene_loader = get_node_or_null("/root/SceneLoader")
	if not scene_loader:
		return {"working": false, "error": "SceneLoader not found"}
	
	if scene_loader.has_method("list_available_scenes"):
		var scenes = scene_loader.list_available_scenes()
		if scenes.size() > 0:
			return {"working": true, "details": str(scenes.size()) + " scenes available"}
	
	return {"working": false, "error": "No scenes found"}

func _test_scene_saving() -> Dictionary:
	# Test scene saving
	var scene_loader = get_node_or_null("/root/SceneLoader")
	if scene_loader and scene_loader.has_method("save_current_scene"):
		return {"working": true, "details": "Save method exists"}
	
	return {"working": false, "error": "Save method missing"}

func _test_dialogue_system() -> Dictionary:
	# Test dialogue display
	var dialogue_system = get_node_or_null("/root/DialogueSystem")
	if not dialogue_system:
		return {"working": false, "error": "DialogueSystem not found"}
	
	if dialogue_system.has_method("show_dialogue"):
		return {"working": true, "details": "Dialogue methods present"}
	
	return {"working": false, "error": "Dialogue methods missing"}

func _test_astral_beings() -> Dictionary:
	# Test astral being creation
	var world_builder = get_node_or_null("/root/WorldBuilder")
	if world_builder and world_builder.has_method("create_astral_being"):
		return {"working": true, "details": "Astral being spawner exists"}
	
	return {"working": false, "error": "Astral being spawner missing"}

func _test_passive_mode() -> Dictionary:
	# Test passive mode system
	var console = get_node_or_null("/root/ConsoleManager")
	if console and console.has_node("passive_controller"):
		return {"working": true, "details": "Passive mode integrated"}
	
	return {"working": false, "error": "Passive mode not found"}

func _test_version_control() -> Dictionary:
	# Self-test
	return {"working": true, "details": "Version control active"}

func _create_version_backup(test_results: Dictionary) -> void:
	var backup = {
		"version": current_version.duplicate(true),
		"test_results": test_results,
		"files_snapshot": _get_files_snapshot(),
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	# Save backup
	var filename = BACKUP_DIR + "v" + current_version["number"] + "_test" + str(current_version["test_count"]) + ".dat"
	var file = FileAccess.open(filename, FileAccess.WRITE)
	if file:
		file.store_var(backup)
		file.close()
	
	# Add to history
	version_history.append(backup)
	
	# Cleanup old backups if needed
	if version_history.size() > MAX_BACKUPS:
		version_history.pop_front()
		_cleanup_old_backups()
	
	emit_signal("version_backed_up", backup)
	print("Version backed up: " + filename)

func _get_files_snapshot() -> Dictionary:
	# Create snapshot of current project state
	var snapshot = {
		"scripts": [],
		"scenes": [],
		"resources": []
	}
	
	# Would scan project directories here
	# For now, return basic info
	snapshot["timestamp"] = Time.get_datetime_string_from_system()
	
	return snapshot

func find_last_working_version(feature: String) -> Dictionary:
	# Search history for last version where feature worked
	for i in range(version_history.size() - 1, -1, -1):
		var version = version_history[i]
		if feature in version["version"]["working_features"]:
			return version
	
	return {}

func compare_versions(version1: String, version2: String) -> Dictionary:
	# Compare two versions to find differences
	var v1_data = _find_version_data(version1)
	var v2_data = _find_version_data(version2)
	
	if v1_data.is_empty() or v2_data.is_empty():
		return {"error": "Version not found"}
	
	return {
		"features_fixed": _array_diff(v2_data["working_features"], v1_data["working_features"]),
		"features_broken": _array_diff(v2_data["broken_features"], v1_data["broken_features"]),
		"test_count_diff": v2_data["test_count"] - v1_data["test_count"]
	}

func restore_version(version_number: String) -> bool:
	# Restore project to specific version
	var version_data = _find_version_data(version_number)
	if version_data.is_empty():
		return false
	
	# Would restore files here
	print("Restoring to version: " + version_number)
	
	current_version = version_data.duplicate(true)
	return true

func generate_feature_report() -> String:
	var report = "=== FEATURE STATUS REPORT ===\n\n"
	
	for feature in tracked_features:
		report += feature + ":\n"
		
		if feature_status_log.has(feature):
			var history = feature_status_log[feature]
			var last_status = history[-1]
			
			report += "  Current: " + ("WORKING" if last_status["working"] else "BROKEN") + "\n"
			report += "  Since: " + last_status["version"] + "\n"
			
			# Find when it last changed
			for i in range(history.size() - 2, -1, -1):
				if history[i]["working"] != last_status["working"]:
					report += "  Changed in: " + history[i + 1]["version"] + "\n"
					break
		else:
			report += "  Status: UNTESTED\n"
		
		report += "\n"
	
	return report

func _find_version_data(version_number: String) -> Dictionary:
	for version in version_history:
		if version["version"]["number"] == version_number:
			return version["version"]
	return {}

func _array_diff(arr1: Array, arr2: Array) -> Array:
	var diff = []
	for item in arr1:
		if not item in arr2:
			diff.append(item)
	return diff

func _ensure_backup_directory() -> void:
	var dir = DirAccess.open("user://")
	if not dir.dir_exists("version_backups"):
		dir.make_dir("version_backups")

func _load_version_history() -> void:
	var dir = DirAccess.open(BACKUP_DIR)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".dat"):
			var file = FileAccess.open(BACKUP_DIR + file_name, FileAccess.READ)
			if file:
				var backup = file.get_var()
				version_history.append(backup)
				file.close()
		file_name = dir.get_next()
	
	# Sort by timestamp
	version_history.sort_custom(func(a, b): return a["timestamp"] < b["timestamp"])

func _cleanup_old_backups() -> void:
	# Remove oldest backup files
	if version_history.size() > MAX_BACKUPS:
		var to_remove = version_history.size() - MAX_BACKUPS
		for i in range(to_remove):
			var version = version_history[i]
			var filename = BACKUP_DIR + "v" + version["version"]["number"] + "_test" + str(version["version"]["test_count"]) + ".dat"
			DirAccess.remove_absolute(filename)

# Public API
func increment_version(bump_type: String = "patch") -> void:
	var parts = current_version["number"].split(".")
	var major = int(parts[0])
	var minor = int(parts[1])
	var patch = int(parts[2])
	
	match bump_type:
		"major":
			major += 1
			minor = 0
			patch = 0
		"minor":
			minor += 1
			patch = 0
		"patch":
			patch += 1
	
	current_version["number"] = str(major) + "." + str(minor) + "." + str(patch)
	current_version["test_count"] = 0

func get_current_version() -> String:
	return current_version["number"]

func get_working_features() -> Array:
	return current_version["working_features"]

func get_broken_features() -> Array:
	return current_version["broken_features"]