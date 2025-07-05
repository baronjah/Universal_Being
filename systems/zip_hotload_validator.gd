extends Node
class_name ZipHotloadValidator

## 🧪 CYCLE 3 - AGENT 3 (Validator) - ZIP HOT-LOADING SYSTEM VALIDATOR
## Tests and validates the ZipHotloadExtension functionality

signal validation_completed(success: bool, results: Dictionary)

var hotload_extension: ZipHotloadExtension
var test_results: Dictionary = {}
var tests_completed: int = 0
var total_tests: int = 5

func _ready() -> void:
	name = "ZipHotloadValidator"
	print("🧪 ZIP HOT-LOADING VALIDATOR: STARTING TESTS!")
	
	# Create and configure the hot-loading extension
	hotload_extension = ZipHotloadExtension.new()
	add_child(hotload_extension)
	
	# Connect to signals for validation
	hotload_extension.zip_hotload_detected.connect(_on_zip_hotload_detected)
	hotload_extension.gdscript_hotload_executed.connect(_on_gdscript_hotload_executed)
	hotload_extension.txt_reality_updated.connect(_on_txt_reality_updated)
	
	# Start validation tests
	call_deferred("start_validation_tests")

func start_validation_tests() -> void:
	"""Start comprehensive validation of hot-loading system"""
	print("🚀 STARTING HOT-LOADING VALIDATION TESTS...")
	
	# Test 1: Basic system initialization
	test_system_initialization()
	
	# Test 2: ZIP file detection and watching
	test_zip_watching()
	
	# Test 3: TXT to 3D reality generation
	test_txt_reality_generation()
	
	# Test 4: GDScript hot-loading
	test_gdscript_hotloading()
	
	# Test 5: JSON configuration loading
	test_json_configuration()

func test_system_initialization() -> void:
	"""Test 1: Validate system initialization"""
	print("🔧 TEST 1: System Initialization")
	
	var success = true
	var details = []
	
	# Check if hotload extension is properly initialized
	if hotload_extension:
		details.append("✅ ZipHotloadExtension created successfully")
	else:
		success = false
		details.append("❌ ZipHotloadExtension creation failed")
	
	# Check if file watcher is active
	if hotload_extension.file_watcher_timer and hotload_extension.file_watcher_timer.is_stopped() == false:
		details.append("✅ File watcher timer active")
	else:
		success = false
		details.append("❌ File watcher timer not active")
	
	# Check if directories are being watched
	if hotload_extension.watched_directories.size() > 0:
		details.append("✅ Watch directories configured: %d" % hotload_extension.watched_directories.size())
	else:
		success = false
		details.append("❌ No watch directories configured")
	
	record_test_result("system_initialization", success, details)

func test_zip_watching() -> void:
	"""Test 2: Validate ZIP file watching"""
	print("📂 TEST 2: ZIP File Watching")
	
	var success = true
	var details = []
	
	# Add test ZIP to watch list
	var test_zip_path = "res://zip_worlds/test_world.zip"
	if FileAccess.file_exists(test_zip_path):
		hotload_extension.add_zip_watch(test_zip_path)
		details.append("✅ Test ZIP added to watch list: %s" % test_zip_path)
		
		# Check if it's in the watched files
		if test_zip_path in hotload_extension.watched_zip_files:
			details.append("✅ ZIP file properly tracked in watch list")
		else:
			success = false
			details.append("❌ ZIP file not found in watch list")
	else:
		success = false
		details.append("❌ Test ZIP file not found: %s" % test_zip_path)
	
	record_test_result("zip_watching", success, details)

func test_txt_reality_generation() -> void:
	"""Test 3: Validate TXT to 3D reality generation"""
	print("📝 TEST 3: TXT to 3D Reality Generation")
	
	var success = true
	var details = []
	
	# Test TXT content processing
	var test_txt_content = """CREATE: cube red glowing
CREATE: sphere blue floating
CONSCIOUSNESS: 4.0
This is a test reality."""
	
	var reality_data = hotload_extension.process_txt_to_reality(test_txt_content, "test.txt")
	
	# Validate reality data structure
	if reality_data.has("objects") and reality_data.objects.size() > 0:
		details.append("✅ Objects parsed from TXT: %d" % reality_data.objects.size())
	else:
		success = false
		details.append("❌ No objects parsed from TXT")
	
	if reality_data.has("consciousness_level") and reality_data.consciousness_level == 4.0:
		details.append("✅ Consciousness level parsed correctly: %f" % reality_data.consciousness_level)
	else:
		success = false
		details.append("❌ Consciousness level parsing failed")
	
	# Test reality manifestation
	var initial_children = get_tree().current_scene.get_child_count()
	hotload_extension.manifest_txt_reality(reality_data, "test.txt")
	var final_children = get_tree().current_scene.get_child_count()
	
	if final_children > initial_children:
		details.append("✅ Reality manifested into scene (new nodes added)")
	else:
		success = false
		details.append("❌ No new nodes added to scene")
	
	record_test_result("txt_reality_generation", success, details)

func test_gdscript_hotloading() -> void:
	"""Test 4: Validate GDScript hot-loading"""
	print("🔥 TEST 4: GDScript Hot-loading")
	
	var success = true
	var details = []
	
	# Test script compilation
	var test_script_content = """extends Node
class_name TestHotloadScript

func _ready():
	print("Hot-loaded script initialized!")
	name = "HotLoadedTestScript"

func test_function():
	return "Hot-loading works!"
"""
	
	var script = GDScript.new()
	script.source_code = test_script_content
	
	if script.reload() == OK:
		details.append("✅ GDScript compilation successful")
		
		# Test instantiation
		if script.can_instantiate():
			var instance = script.new()
			details.append("✅ Script instance created successfully")
			
			# Test adding to scene
			if instance is Node:
				get_tree().current_scene.add_child(instance)
				details.append("✅ Script instance added to scene")
				
				# Test method calling
				if instance.has_method("test_function"):
					var result = instance.test_function()
					if result == "Hot-loading works!":
						details.append("✅ Script method execution successful")
					else:
						success = false
						details.append("❌ Script method returned unexpected result")
				else:
					success = false
					details.append("❌ Script method not found")
			else:
				success = false
				details.append("❌ Script instance is not a Node")
		else:
			success = false
			details.append("❌ Script cannot be instantiated")
	else:
		success = false
		details.append("❌ GDScript compilation failed")
	
	record_test_result("gdscript_hotloading", success, details)

func test_json_configuration() -> void:
	"""Test 5: Validate JSON configuration loading"""
	print("📋 TEST 5: JSON Configuration Loading")
	
	var success = true
	var details = []
	
	# Test JSON parsing
	var test_json_content = """{
	"zip_settings": {
		"watch_interval": 1.0,
		"auto_reload": true
	},
	"consciousness_settings": {
		"consciousness_multiplier": 2.5
	}
}"""
	
	var json = JSON.new()
	if json.parse(test_json_content) == OK:
		details.append("✅ JSON parsing successful")
		
		var data = json.data
		if data.has("zip_settings") and data.has("consciousness_settings"):
			details.append("✅ JSON structure validation passed")
			
			# Test configuration application
			var original_interval = hotload_extension.watch_interval
			hotload_extension.apply_zip_settings(data.zip_settings)
			
			if hotload_extension.watch_interval == 1.0:
				details.append("✅ ZIP settings applied successfully")
			else:
				success = false
				details.append("❌ ZIP settings application failed")
				
			# Restore original interval
			hotload_extension.watch_interval = original_interval
		else:
			success = false
			details.append("❌ JSON structure validation failed")
	else:
		success = false
		details.append("❌ JSON parsing failed")
	
	record_test_result("json_configuration", success, details)

func record_test_result(test_name: String, success: bool, details: Array) -> void:
	"""Record test result and check if all tests completed"""
	test_results[test_name] = {
		"success": success,
		"details": details
	}
	
	tests_completed += 1
	
	# Print test result
	var status = "✅ PASSED" if success else "❌ FAILED"
	print("🧪 TEST %s: %s" % [test_name.to_upper(), status])
	for detail in details:
		print("   %s" % detail)
	
	# Check if all tests completed
	if tests_completed >= total_tests:
		complete_validation()

func complete_validation() -> void:
	"""Complete validation and emit results"""
	print("\n🏁 HOT-LOADING VALIDATION COMPLETE!")
	
	var passed_tests = 0
	var failed_tests = 0
	
	for test_name in test_results.keys():
		if test_results[test_name].success:
			passed_tests += 1
		else:
			failed_tests += 1
	
	var overall_success = failed_tests == 0
	
	print("📊 VALIDATION RESULTS:")
	print("   ✅ Passed: %d/%d" % [passed_tests, total_tests])
	print("   ❌ Failed: %d/%d" % [failed_tests, total_tests])
	print("   🎯 Overall: %s" % ("SUCCESS" if overall_success else "NEEDS FIXES"))
	
	var results = {
		"overall_success": overall_success,
		"passed_tests": passed_tests,
		"failed_tests": failed_tests,
		"total_tests": total_tests,
		"detailed_results": test_results
	}
	
	validation_completed.emit(overall_success, results)

# Signal handlers
func _on_zip_hotload_detected(zip_path: String, changed_files: Array) -> void:
	"""Handle ZIP hot-load detection"""
	print("🔥 ZIP HOT-LOAD DETECTED: %s (%d files)" % [zip_path, changed_files.size()])

func _on_gdscript_hotload_executed(script_path: String, success: bool) -> void:
	"""Handle GDScript hot-load execution"""
	var status = "✅ SUCCESS" if success else "❌ FAILED"
	print("🔥 GDSCRIPT HOT-LOAD %s: %s" % [status, script_path])

func _on_txt_reality_updated(txt_file: String, new_reality: Dictionary) -> void:
	"""Handle TXT reality update"""
	print("📝 TXT REALITY UPDATED: %s (%d objects)" % [txt_file, new_reality.get("objects", []).size()])

# Public API
func force_validation() -> void:
	"""Force start validation tests"""
	tests_completed = 0
	test_results.clear()
	start_validation_tests()

func get_validation_results() -> Dictionary:
	"""Get current validation results"""
	return test_results