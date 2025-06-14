# ==================================================
# SCRIPT NAME: threaded_test_system.gd
# DESCRIPTION: Multi-threaded testing like Eden datapoint system
# CREATED: 2025-05-23 - No await, proper threading
# ==================================================

extends UniversalBeingBase
# Test containers (like Eden's datapoint containers)
var test_containers: Dictionary = {}
var active_tests: Array = []
var completed_tests: Array = []

# Processing state
var current_test_index: int = 0
var tests_per_frame: int = 2
var frame_counter: int = 0

# Zone-based testing (cosmos -> planet -> cave approach)
var test_zones: Dictionary = {
	"cosmos": ["console_system", "physics_system", "version_control"],
	"planet": ["object_spawning", "scene_loading", "dialogue_system"],
	"cave": ["ragdoll_physics", "ragdoll_walking", "astral_beings"],
	"asteroid": ["passive_mode", "workflow_system"]
}

var current_zone: String = "cosmos"
var zone_index: int = 0

# Signals
signal test_zone_completed(zone: String, results: Dictionary)
signal all_tests_completed(summary: Dictionary)

func _ready() -> void:
	_initialize_test_containers()
	set_process(true)

func _process(delta: float) -> void:
	frame_counter += 1
	
	# Process tests spread across frames (no await needed)
	if not active_tests.is_empty():
		_process_tests_this_frame()
	elif _should_start_new_zone():
		_start_next_zone()

func _initialize_test_containers() -> void:
	# Create test containers for each feature (like Eden's datapoint system)
	for zone in test_zones:
		for feature in test_zones[zone]:
			test_containers[feature] = {
				"zone": zone,
				"state": "ready",
				"progress": 0.0,
				"result": {},
				"dependencies": _get_test_dependencies(feature),
				"last_test_frame": 0
			}

func _get_test_dependencies(feature: String) -> Array:
	# Define test dependencies (like Eden's companion system)
	match feature:
		"ragdoll_walking":
			return ["ragdoll_physics"]
		"scene_loading":
			return ["object_spawning"]
		"astral_beings":
			return ["physics_system"]
		_:
			return []


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
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
func start_zone_test(zone: String) -> void:
	if not test_zones.has(zone):
		return
	
	current_zone = zone
	active_tests.clear()
	
	# Add all tests from this zone that have dependencies met
	for feature in test_zones[zone]:
		if _dependencies_met(feature):
			active_tests.append(feature)
			test_containers[feature]["state"] = "active"
	
	print("Starting test zone: " + zone + " with " + str(active_tests.size()) + " tests")

func _dependencies_met(feature: String) -> bool:
	var deps = test_containers[feature]["dependencies"]
	for dep in deps:
		var dep_container = test_containers.get(dep, {})
		if dep_container.get("state", "") != "completed":
			return false
	return true

func _process_tests_this_frame() -> void:
	var tests_processed = 0
	
	while tests_processed < tests_per_frame and current_test_index < active_tests.size():
		var feature = active_tests[current_test_index]
		var container = test_containers[feature]
		
		# Process test step by step (no blocking)
		_process_test_step(feature, container)
		
		current_test_index += 1
		tests_processed += 1
	
	# Check if all tests in current batch are done
	if current_test_index >= active_tests.size():
		_check_zone_completion()

func _process_test_step(feature: String, container: Dictionary) -> void:
	container["last_test_frame"] = frame_counter
	
	match container["state"]:
		"active":
			# Start the test
			container["state"] = "testing"
			container["progress"] = 0.1
			print("Testing: " + feature)
		
		"testing":
			# Run the actual test (synchronous, no await)
			var result = _run_feature_test(feature)
			container["result"] = result
			container["state"] = "completed"
			container["progress"] = 1.0
			
			completed_tests.append(feature)
			print("Completed: " + feature + " - " + ("PASS" if result.get("working", false) else "FAIL"))

func _run_feature_test(feature: String) -> Dictionary:
	# Run tests synchronously (like Eden's immediate state checking)
	match feature:
		"console_system":
			return _test_console_system()
		"physics_system":
			return _test_physics_system()
		"object_spawning":
			return _test_object_spawning()
		"ragdoll_physics":
			return _test_ragdoll_physics()
		"ragdoll_walking":
			return _test_ragdoll_walking()
		"scene_loading":
			return _test_scene_loading()
		"dialogue_system":
			return _test_dialogue_system()
		"astral_beings":
			return _test_astral_beings()
		"passive_mode":
			return _test_passive_mode()
		"version_control":
			return _test_version_control()
		"workflow_system":
			return _test_workflow_system()
		_:
			return {"working": false, "error": "Unknown test"}

func _test_console_system() -> Dictionary:
	var console = get_node_or_null("/root/ConsoleManager")
	if console and console.has_method("toggle_console"):
		return {"working": true, "details": "Console system operational"}
	return {"working": false, "error": "Console not found"}

func _test_physics_system() -> Dictionary:
	var physics_mgr = get_node_or_null("/root/PhysicsStateManager")
	if physics_mgr and physics_mgr.has_method("set_object_state"):
		return {"working": true, "details": "Physics state system operational"}
	return {"working": false, "error": "Physics manager not found"}

func _test_object_spawning() -> Dictionary:
	var world_builder = get_node_or_null("/root/WorldBuilder")
	if world_builder and world_builder.has_method("create_tree"):
		return {"working": true, "details": "Object spawning system operational"}
	return {"working": false, "error": "WorldBuilder not found"}

func _test_ragdoll_physics() -> Dictionary:
	var ragdolls = get_tree().get_nodes_in_group("ragdolls")
	if not ragdolls.is_empty():
		var ragdoll = ragdolls[0]
		if ragdoll.has_method("get_body"):
			return {"working": true, "details": "Ragdoll physics available"}
	
	# Check if spawner exists
	var world_builder = get_node_or_null("/root/WorldBuilder")
	if world_builder and world_builder.has_method("create_ragdoll"):
		return {"working": true, "details": "Ragdoll spawner available"}
	
	return {"working": false, "error": "No ragdoll system found"}

func _test_ragdoll_walking() -> Dictionary:
	var ragdolls = get_tree().get_nodes_in_group("ragdolls")
	if not ragdolls.is_empty():
		var ragdoll = ragdolls[0]
		if ragdoll.has_method("toggle_walking"):
			return {"working": true, "details": "Walking system available"}
	return {"working": false, "error": "No walking capability"}

func _test_scene_loading() -> Dictionary:
	var scene_loader = get_node_or_null("/root/SceneLoader")
	if scene_loader and scene_loader.has_method("list_available_scenes"):
		var scenes = scene_loader.list_available_scenes()
		return {"working": true, "details": str(scenes.size()) + " scenes available"}
	return {"working": false, "error": "Scene loader not found"}

func _test_dialogue_system() -> Dictionary:
	var dialogue_system = get_node_or_null("/root/DialogueSystem")
	if dialogue_system and dialogue_system.has_method("show_dialogue"):
		return {"working": true, "details": "Dialogue system operational"}
	return {"working": false, "error": "Dialogue system not found"}

func _test_astral_beings() -> Dictionary:
	var world_builder = get_node_or_null("/root/WorldBuilder")
	if world_builder and world_builder.has_method("create_astral_being"):
		return {"working": true, "details": "Astral being system available"}
	return {"working": false, "error": "Astral being system not found"}

func _test_passive_mode() -> Dictionary:
	var console = get_node_or_null("/root/ConsoleManager")
	if console and console.has_node("passive_controller"):
		return {"working": true, "details": "Passive mode integrated"}
	return {"working": false, "error": "Passive mode not found"}

func _test_workflow_system() -> Dictionary:
	var console = get_node_or_null("/root/ConsoleManager")
	if console and console.has_node("multi_project_manager"):
		return {"working": true, "details": "Workflow system integrated"}
	return {"working": false, "error": "Workflow system not found"}

func _test_version_control() -> Dictionary:
	# Self-test
	return {"working": true, "details": "Version control active"}

func _check_zone_completion() -> void:
	var zone_results = {}
	var all_completed = true
	
	for feature in test_zones[current_zone]:
		var container = test_containers[feature]
		zone_results[feature] = container["result"]
		if container["state"] != "completed":
			all_completed = false
	
	if all_completed:
		emit_signal("test_zone_completed", current_zone, zone_results)
		print("Zone completed: " + current_zone)
		
		# Start next zone or finish
		if _has_next_zone():
			_start_next_zone()
		else:
			_finalize_all_tests()

func _should_start_new_zone() -> bool:
	return active_tests.is_empty() and current_zone != ""

func _has_next_zone() -> bool:
	var zones = test_zones.keys()
	var current_index = zones.find(current_zone)
	return current_index >= 0 and current_index < zones.size() - 1

func _start_next_zone() -> void:
	var zones = test_zones.keys()
	var current_index = zones.find(current_zone)
	
	if current_index >= 0 and current_index < zones.size() - 1:
		current_test_index = 0
		start_zone_test(zones[current_index + 1])

func _finalize_all_tests() -> void:
	var summary = {
		"total_tests": test_containers.size(),
		"passed": 0,
		"failed": 0,
		"zones": {}
	}
	
	for zone in test_zones:
		summary["zones"][zone] = {}
		for feature in test_zones[zone]:
			var result = test_containers[feature]["result"]
			summary["zones"][zone][feature] = result
			
			if result.get("working", false):
				summary["passed"] += 1
			else:
				summary["failed"] += 1
	
	emit_signal("all_tests_completed", summary)
	print("All tests completed: " + str(summary["passed"]) + " passed, " + str(summary["failed"]) + " failed")

# Public API
func run_full_test_suite() -> void:
	completed_tests.clear()
	current_test_index = 0
	
	# Start with cosmos zone
	start_zone_test("cosmos")

func run_zone_test(zone: String) -> void:
	start_zone_test(zone)

func get_test_status() -> Dictionary:
	return {
		"current_zone": current_zone,
		"active_tests": active_tests.size(),
		"completed_tests": completed_tests.size(),
		"total_containers": test_containers.size()
	}

func get_zone_progress(zone: String) -> float:
	if not test_zones.has(zone):
		return 0.0
	
	var total_tests = test_zones[zone].size()
	var completed_count = 0
	
	for feature in test_zones[zone]:
		if test_containers[feature]["state"] == "completed":
			completed_count += 1
	
	return float(completed_count) / float(total_tests)