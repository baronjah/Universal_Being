extends UniversalBeingBase
class_name GameLauncher

# GAME LAUNCHER - System Status Monitor and Error Reporter
# Provides comprehensive startup diagnostics and system health monitoring

var startup_complete = false
var error_log = []
var system_status = {}

signal systems_ready()
signal startup_error(error_message)

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("🚀 [GameLauncher] Starting system diagnostics...")
	_run_startup_diagnostics()

func _run_startup_diagnostics():
	print("\n=== SYSTEM STARTUP DIAGNOSTICS ===")
	
	# Check core autoloads
	_check_autoload_systems()
	
	# Check floodgate integration
	_check_floodgate_systems()
	
	# Check scene structure
	_check_scene_structure()
	
	# Check asset availability
	_check_critical_assets()
	
	# Final status report
	_generate_status_report()

func _check_autoload_systems():
	print("\n📋 Checking Autoload Systems:")
	
	var autoloads = [
		"FloodgateController",
		"AssetLibrary", 
		"UISettingsManager",
		"ConsoleManager",
		"WorldBuilder",
		"DialogueSystem",
		"SceneLoader"
	]
	
	for autoload_name in autoloads:
		var node = get_node_or_null("/root/" + autoload_name)
		if node:
			system_status[autoload_name] = "✅ READY"
			print("  ✅ " + autoload_name + ": READY")
		else:
			system_status[autoload_name] = "❌ MISSING"
			print("  ❌ " + autoload_name + ": MISSING")
			error_log.append("Missing autoload: " + autoload_name)

func _check_floodgate_systems():
	print("\n🌊 Checking Floodgate Systems:")
	
	var floodgate = get_node_or_null("/root/FloodgateController")
	var asset_library = get_node_or_null("/root/AssetLibrary")
	
	if floodgate:
		print("  ✅ FloodgateController: Online")
		
		# Check if floodgate is processing
		await get_tree().create_timer(0.1).timeout
		
		# Get queue status
		var queue_info = {
			"actions": floodgate.actions_to_be_called.size(),
			"nodes": floodgate.nodes_to_be_added.size(),
			"movements": floodgate.things_to_be_moved.size(),
			"functions": floodgate.functions_to_be_called.size()
		}
		
		print("  📊 Queue Status: " + str(queue_info))
		system_status["floodgate_queues"] = queue_info
	else:
		print("  ❌ FloodgateController: Offline")
		error_log.append("FloodgateController not found")
	
	if asset_library:
		print("  ✅ AssetLibrary: Online")
		var catalog_summary = asset_library.get_catalog_summary()
		print("  📚 Asset Catalog: " + str(catalog_summary))
		system_status["asset_catalog"] = catalog_summary
	else:
		print("  ❌ AssetLibrary: Offline")
		error_log.append("AssetLibrary not found")

func _check_scene_structure():
	print("\n🎬 Checking Scene Structure:")
	
	# Check main scene components
	var main_node = get_tree().current_scene
	if main_node:
		print("  ✅ Main Scene: " + main_node.name)
		system_status["main_scene"] = main_node.name
		
		# Check for camera
		var camera = get_viewport().get_camera_3d()
		if camera:
			print("  ✅ Camera3D: Found at " + str(camera.global_position))
			system_status["camera"] = "Available"
		else:
			print("  ⚠️ Camera3D: Not found")
			error_log.append("No Camera3D found")
		
		# Check for ground
		var ground = get_tree().get_first_node_in_group("ground")
		if not ground:
			ground = main_node.get_node_or_null("Ground")
		
		if ground:
			print("  ✅ Ground: Found")
			system_status["ground"] = "Available"
		else:
			print("  ⚠️ Ground: Not found")
			error_log.append("No ground plane found")
	else:
		print("  ❌ Main Scene: Not found")
		error_log.append("Main scene not loaded")

func _check_critical_assets():
	print("\n📦 Checking Critical Assets:")
	
	var critical_scripts = [
		"res://scripts/core/standardized_objects.gd",
		"res://scripts/core/floodgate_controller.gd",
		"res://scripts/core/asset_library.gd"
	]
	
	for script_path in critical_scripts:
		if ResourceLoader.exists(script_path):
			print("  ✅ " + script_path.get_file() + ": Found")
		else:
			print("  ❌ " + script_path.get_file() + ": Missing")
			error_log.append("Missing script: " + script_path)
	
	# Check if StandardizedObjects is working
	var test_object = StandardizedObjects.create_object("box", Vector3.ZERO)
	if test_object:
		print("  ✅ StandardizedObjects: Working")
		test_object.queue_free()  # Clean up test object
		system_status["standardized_objects"] = "Working"
	else:
		print("  ❌ StandardizedObjects: Failed")
		error_log.append("StandardizedObjects.create_object() failed")

func _generate_status_report():
	print("\n📊 STARTUP STATUS REPORT:")
	print("==================================================") # Fixed string multiplication
	
	var total_systems = system_status.size()
	var working_systems = 0
	
	for system_name in system_status:
		var status = system_status[system_name]
		if status is String:
			if status.contains("✅") or status == "Available" or status == "Working":
				working_systems += 1
		elif status is Dictionary and not status.is_empty():
			working_systems += 1
	
	print("🎯 Systems Status: " + str(working_systems) + "/" + str(total_systems) + " operational")
	
	if error_log.is_empty():
		print("✅ No critical errors detected")
		startup_complete = true
		emit_signal("systems_ready")
		print("🚀 All systems ready! Game launch successful!")
	else:
		print("⚠️  " + str(error_log.size()) + " issues detected:")
		for error in error_log:
			print("  • " + error)
		
		if error_log.size() <= 2:
			print("🟡 Minor issues detected, game should still function")
			startup_complete = true
			emit_signal("systems_ready")
		else:
			print("🔴 Critical issues detected, game may not function properly")
			emit_signal("startup_error", "Critical startup errors detected")
	
	print("==================================================") # Fixed string multiplication
	print("🎮 Game Ready! Press Tab to open console.")
	
	# Save diagnostic report
	_save_diagnostic_report()

func _save_diagnostic_report():
	var report = {
		"timestamp": Time.get_datetime_string_from_system(),
		"startup_complete": startup_complete,
		"system_status": system_status,
		"errors": error_log,
		"godot_version": Engine.get_version_info()
	}
	
	var file = FileAccess.open("user://startup_diagnostic.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(report, "\t"))
		file.close()
		print("📄 Diagnostic report saved to user://startup_diagnostic.json")

# Public API for checking system health

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
func get_system_status() -> Dictionary:
	return system_status.duplicate()

func get_error_log() -> Array:
	return error_log.duplicate()

func is_startup_complete() -> bool:
	return startup_complete

func run_health_check():
	print("\n🏥 HEALTH CHECK INITIATED")
	_run_startup_diagnostics()

# Test floodgate system
func test_floodgate_system():
	if not startup_complete:
		print("❌ Cannot test floodgate - startup not complete")
		return
	
	print("\n🧪 TESTING FLOODGATE SYSTEM")
	
	var floodgate = get_node_or_null("/root/FloodgateController")
	if not floodgate:
		print("❌ FloodgateController not available")
		return
	
	print("🔬 Queueing test operations...")
	
	# Test first dimensional magic (actions)
	var test_node = Node3D.new()
	test_node.name = "test_node_launcher"
	get_tree().FloodgateController.universal_add_child(test_node, get_tree().current_scene)
	
	floodgate.first_dimensional_magic("update_position", test_node, Vector3(1, 2, 3))
	
	# Test second dimensional magic (node creation) 
	var test_child = Node3D.new()
	test_child.name = "test_child_launcher"
	floodgate.second_dimensional_magic(0, "test_child_launcher", test_child)
	
	# Test cleanup
	await get_tree().create_timer(1.0).timeout
	
	if is_instance_valid(test_node):
		test_node.queue_free()
	
	print("✅ Floodgate test completed - check console for operation logs")

# Quick console command
func quick_test():
	print("\n⚡ QUICK SYSTEM TEST")
	print("FloodgateController: " + ("✅" if get_node_or_null("/root/FloodgateController") else "❌"))
	print("AssetLibrary: " + ("✅" if get_node_or_null("/root/AssetLibrary") else "❌"))
	print("WorldBuilder: " + ("✅" if get_node_or_null("/root/WorldBuilder") else "❌"))
	print("ConsoleManager: " + ("✅" if get_node_or_null("/root/ConsoleManager") else "❌"))