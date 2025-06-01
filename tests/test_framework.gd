extends Node
class_name UniversalBeingTestFramework

# Test Results
var tests_run: int = 0
var tests_passed: int = 0
var tests_failed: int = 0
var current_test: String = ""
var test_results: Array = []

# Test a UniversalBeing
static func test_being(being_class: Script) -> Dictionary:
	var framework = UniversalBeingTestFramework.new()
	var being = being_class.new()
	
	framework.run_test_suite(being)
	
	var results = {
		"class": being_class.resource_path,
		"total": framework.tests_run,
		"passed": framework.tests_passed,
		"failed": framework.tests_failed,
		"details": framework.test_results
	}
	
	being.queue_free()
	framework.queue_free()
	
	return results

func run_test_suite(being: UniversalBeing):
	print("\n🧪 Testing Universal Being: %s" % being.get_class())
	print("=" * 50)
	
	# Core Tests
	test_pentagon_lifecycle(being)
	test_component_system(being)
	test_evolution_system(being)
	test_ai_interface(being)
	test_scene_control(being)
	test_consciousness_system(being)
	
	# Print results
	print("\n📊 Test Results:")
	print("   Total: %d" % tests_run)
	print("   ✅ Passed: %d" % tests_passed)
	print("   ❌ Failed: %d" % tests_failed)
	print("   Success Rate: %.1f%%" % (float(tests_passed) / float(tests_run) * 100.0))

# Test Pentagon Lifecycle
func test_pentagon_lifecycle(being: UniversalBeing):
	start_test("Pentagon Lifecycle")
	
	# Test init
	assert_not_empty(being.being_uuid, "UUID should be generated")
	assert_true(being.has_method("pentagon_init"), "Should have pentagon_init")
	
	# Test ready
	assert_true(being.has_method("pentagon_ready"), "Should have pentagon_ready")
	
	# Test process
	assert_true(being.has_method("pentagon_process"), "Should have pentagon_process")
	being.pentagon_process(0.016)
	
	# Test input
	assert_true(being.has_method("pentagon_input"), "Should have pentagon_input")
	var test_event = InputEventKey.new()
	being.pentagon_input(test_event)
	
	# Test sewers
	assert_true(being.has_method("pentagon_sewers"), "Should have pentagon_sewers")

# Test Component System
func test_component_system(being: UniversalBeing):
	start_test("Component System")
	
	assert_true(being.has_method("add_component"), "Should have add_component")
	assert_true(being.has_method("remove_component"), "Should have remove_component")
	assert_equals(being.component_data.size(), 0, "Should start with no components")
	
	# Test adding a fake component
	being.component_data["test_component"] = {"test": true}
	assert_equals(being.component_data.size(), 1, "Should have one component")
	
	being.remove_component("test_component")
	assert_equals(being.component_data.size(), 0, "Component should be removed")

# Test Evolution System
func test_evolution_system(being: UniversalBeing):
	start_test("Evolution System")
	
	assert_not_null(being.evolution_state, "Should have evolution state")
	assert_true(being.evolution_state.has("can_become"), "Should have can_become")
	assert_true(being.evolution_state.has("has_been"), "Should have has_been")
	
	# Test evolution methods
	assert_true(being.has_method("can_evolve_to"), "Should have can_evolve_to")
	assert_true(being.has_method("evolve_to"), "Should have evolve_to")
	
	# Test evolution check
	if being.evolution_state.can_become.size() > 0:
		var target = being.evolution_state.can_become[0]
		assert_true(being.can_evolve_to(target), "Should be able to evolve to allowed target")

# Test AI Interface
func test_ai_interface(being: UniversalBeing):
	start_test("AI Interface")
	
	var ai_data = being.ai_interface()
	assert_not_null(ai_data, "AI interface should return data")
	assert_true(ai_data.has("base_commands"), "Should have base commands")
	assert_true(ai_data.has("consciousness_level"), "Should have consciousness level")
	assert_true(ai_data.has("being_type"), "Should have being type")
	
	# Test AI methods
	assert_true(being.has_method("ai_modify_property"), "Should have ai_modify_property")
	assert_true(being.has_method("ai_invoke_method"), "Should have ai_invoke_method")

# Test Scene Control
func test_scene_control(being: UniversalBeing):
	start_test("Scene Control")
	
	assert_true(being.has_method("load_scene"), "Should have load_scene")
	assert_true(being.has_method("get_scene_node"), "Should have get_scene_node")
	assert_true(being.has_method("set_scene_property"), "Should have set_scene_property")
	assert_true(being.has_method("call_scene_method"), "Should have call_scene_method")

# Test Consciousness System
func test_consciousness_system(being: UniversalBeing):
	start_test("Consciousness System")
	
	assert_greater_equal(being.consciousness_level, 0, "Consciousness should be >= 0")
	assert_not_null(being.consciousness_aura_color, "Should have aura color")
	assert_true(being.has_method("update_consciousness_visual"), "Should have update method")
	
	# Test consciousness update
	var old_color = being.consciousness_aura_color
	being.consciousness_level = 5
	being.update_consciousness_visual()
	# Color should change with consciousness
	assert_not_equals(being.consciousness_aura_color, old_color, "Aura should change with consciousness")

# Helper Functions
func start_test(test_name: String):
	current_test = test_name
	print("\n🔍 %s" % test_name)

func assert_true(condition: bool, message: String):
	tests_run += 1
	if condition:
		tests_passed += 1
		print("   ✅ %s" % message)
		test_results.append({"test": current_test, "assertion": message, "passed": true})
	else:
		tests_failed += 1
		print("   ❌ %s" % message)
		test_results.append({"test": current_test, "assertion": message, "passed": false})

func assert_false(condition: bool, message: String):
	assert_true(!condition, message)

func assert_equals(actual, expected, message: String):
	assert_true(actual == expected, "%s (got: %s, expected: %s)" % [message, actual, expected])

func assert_not_equals(actual, expected, message: String):
	assert_true(actual != expected, "%s (values should not be equal)" % message)

func assert_not_null(value, message: String):
	assert_true(value != null, "%s (should not be null)" % message)

func assert_not_empty(value: String, message: String):
	assert_true(value != "", "%s (should not be empty)" % message)

func assert_greater_equal(actual, expected, message: String):
	assert_true(actual >= expected, "%s (got: %s, expected >= %s)" % [message, actual, expected])