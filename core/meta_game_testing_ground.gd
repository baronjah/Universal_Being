# ==================================================
# UNIVERSAL BEING: Meta Game Testing Ground
# TYPE: system
# PURPOSE: Provides a sandbox environment for testing Universal Beings
# COMPONENTS: []
# SCENES: ["res://scenes/meta_game/testing_ground.tscn"]
# ==================================================

extends UniversalBeing
class_name MetaGameTestingGroundUniversalBeing

# ===== TESTING GROUND STATE =====

var active_tests: Dictionary = {}  # test_id -> TestData
var test_history: Array[TestData] = []
var max_history_size: int = 100
var current_scene: Node = null

# ===== TEST DATA STRUCTURE =====

class TestData:
	var test_id: String
	var being_type: String
	var test_parameters: Dictionary
	var start_time: int
	var end_time: int
	var status: String  # "running", "completed", "failed"
	var results: Dictionary
	var created_by: String
	
	func _init(p_test_id: String, p_being_type: String, p_parameters: Dictionary = {}, p_created_by: String = "system") -> void:
		test_id = p_test_id
		being_type = p_being_type
		test_parameters = p_parameters
		start_time = Time.get_unix_time_from_system()
		end_time = 0
		status = "running"
		results = {}
		created_by = p_created_by
	
	func complete(p_results: Dictionary = {}) -> void:
		end_time = Time.get_unix_time_from_system()
		status = "completed"
		results = p_results
	
	func fail(p_error: String) -> void:
		end_time = Time.get_unix_time_from_system()
		status = "failed"
		results = {"error": p_error}
	
	func to_dict() -> Dictionary:
		return {
			"test_id": test_id,
			"being_type": being_type,
			"test_parameters": test_parameters,
			"start_time": start_time,
			"end_time": end_time,
			"status": status,
			"results": results,
			"created_by": created_by,
			"duration": end_time - start_time if end_time > 0 else 0
		}
	
	static func from_dict(data: Dictionary) -> TestData:
		var test = TestData.new(
			data.get("test_id", ""),
			data.get("being_type", ""),
			data.get("test_parameters", {}),
			data.get("created_by", "system")
		)
		test.end_time = data.get("end_time", 0)
		test.status = data.get("status", "running")
		test.results = data.get("results", {})
		return test

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	being_type = "meta_game_testing_ground"
	being_name = "Meta Game Testing Ground"
	consciousness_level = 3  # High consciousness for AI testing
	
	print("🧪 Meta Game Testing Ground: Pentagon Init Complete")

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Register with FloodGate as system being
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("register_system_being"):
			flood_gates.register_system_being(self)
	
	# Load testing ground scene
	load_testing_ground()
	
	print("🧪 Meta Game Testing Ground: Pentagon Ready Complete")

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Process active tests
	process_active_tests()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Handle test-related input
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			cancel_all_tests()

func pentagon_sewers() -> void:
	# Save test history
	save_test_history()
	
	# Cleanup active tests
	cancel_all_tests()
	
	# Unload scene
	if current_scene:
		current_scene.queue_free()
		current_scene = null
	
	super.pentagon_sewers()

# ===== TESTING GROUND METHODS =====

func load_testing_ground() -> bool:
	"""Load the testing ground scene"""
	if current_scene:
		push_error("Testing ground scene already loaded")
		return false
	
	var scene = load("res://scenes/meta_game/testing_ground.tscn")
	if not scene:
		push_error("Failed to load testing ground scene")
		return false
	
	current_scene = scene.instantiate()
	add_child(current_scene)
	print("🧪 Testing ground scene loaded")
	return true

func start_test(being_type: String, parameters: Dictionary = {}, created_by: String = "system") -> String:
	"""Start a new test for a Universal Being type"""
	var test_id = generate_test_id()
	var test = TestData.new(test_id, being_type, parameters, created_by)
	
	# Create test instance
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("create_being"):
			var being = flood_gates.create_being(being_type, parameters)
			if being:
				test.results["being_uuid"] = being.being_uuid
				active_tests[test_id] = test
				print("🧪 Started test %s for %s" % [test_id, being_type])
				return test_id
	
	test.fail("Failed to create test instance")
	add_to_history(test)
	push_error("Failed to start test for %s" % being_type)
	return ""

func cancel_test(test_id: String) -> bool:
	"""Cancel a specific test"""
	if not active_tests.has(test_id):
		push_error("Test %s not found" % test_id)
		return false
	
	var test = active_tests[test_id]
	test.fail("Test cancelled")
	add_to_history(test)
	active_tests.erase(test_id)
	
	# Cleanup test instance
	if test.results.has("being_uuid"):
		if SystemBootstrap and SystemBootstrap.is_system_ready():
			var flood_gates = SystemBootstrap.get_flood_gates()
			if flood_gates and flood_gates.has_method("destroy_being"):
				flood_gates.destroy_being(test.results["being_uuid"])
	
	print("🧪 Cancelled test: %s" % test_id)
	return true

func cancel_all_tests() -> void:
	"""Cancel all active tests"""
	for test_id in active_tests.keys():
		cancel_test(test_id)

func process_active_tests() -> void:
	"""Process all active tests"""
	for test_id in active_tests.keys():
		var test = active_tests[test_id]
		
		# Check if test being is still valid
		if test.results.has("being_uuid"):
			if SystemBootstrap and SystemBootstrap.is_system_ready():
				var flood_gates = SystemBootstrap.get_flood_gates()
				if flood_gates and flood_gates.has_method("get_being"):
					var being = flood_gates.get_being(test.results["being_uuid"])
					if not being:
						test.fail("Test being was destroyed")
						add_to_history(test)
						active_tests.erase(test_id)
						continue
		
		# Update test results
		update_test_results(test)

func update_test_results(test: TestData) -> void:
	"""Update results for a test"""
	if not test.results.has("being_uuid"):
		return
	
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("get_being"):
			var being = flood_gates.get_being(test.results["being_uuid"])
			if being:
				# Collect being state
				test.results["state"] = {
					"position": being.position if being.has_method("get_position") else Vector3.ZERO,
					"rotation": being.rotation if being.has_method("get_rotation") else Vector3.ZERO,
					"scale": being.scale if being.has_method("get_scale") else Vector3.ONE,
					"consciousness": being.consciousness_level if being.has_method("get_consciousness") else 0,
					"components": being.component_data if being.has_method("get_components") else {}
				}

func add_to_history(test: TestData) -> void:
	"""Add a test to history"""
	test_history.append(test)
	if test_history.size() > max_history_size:
		test_history.pop_front()

func generate_test_id() -> String:
	"""Generate a unique test ID"""
	return "test_%d" % Time.get_unix_time_from_system()

# ===== TEST QUERY METHODS =====

func get_test_info(test_id: String) -> Dictionary:
	"""Get information about a test"""
	if active_tests.has(test_id):
		return active_tests[test_id].to_dict()
	
	# Check history
	for test in test_history:
		if test.test_id == test_id:
			return test.to_dict()
	
	return {}

func list_active_tests() -> Array[Dictionary]:
	"""List all active tests"""
	var test_list: Array[Dictionary] = []
	for test in active_tests.values():
		test_list.append(test.to_dict())
	return test_list

func get_test_history() -> Array[Dictionary]:
	"""Get test execution history"""
	var history: Array[Dictionary] = []
	for test in test_history:
		history.append(test.to_dict())
	return history

# ===== PERSISTENCE =====

func save_test_history() -> void:
	"""Save test history to Akashic Records"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic and akashic.has_method("save_data"):
			var history_data = []
			for test in test_history:
				history_data.append(test.to_dict())
			akashic.save_data("test_history", history_data)

func load_test_history() -> void:
	"""Load test history from Akashic Records"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic and akashic.has_method("load_data"):
			var history_data = akashic.load_data("test_history", [])
			for test_data in history_data:
				test_history.append(TestData.from_dict(test_data))

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	var base_interface = super.ai_interface()
	
	base_interface["test_info"] = {
		"active_tests": active_tests.size(),
		"history_size": test_history.size(),
		"scene_loaded": current_scene != null
	}
	
	base_interface["capabilities"] = [
		"test_creation",
		"test_monitoring",
		"test_control",
		"history_tracking"
	]
	
	return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		"start_test":
			if args.size() >= 1:
				return start_test(args[0], args[1] if args.size() > 1 else {}, args[2] if args.size() > 2 else "ai")
			return ""
		"cancel_test":
			if args.size() > 0:
				return cancel_test(args[0])
			return false
		"cancel_all":
			cancel_all_tests()
			return true
		"list_active":
			return list_active_tests()
		"get_history":
			return get_test_history()
		"get_test_info":
			if args.size() > 0:
				return get_test_info(args[0])
			return {}
		_:
			return super.ai_invoke_method(method_name, args) 