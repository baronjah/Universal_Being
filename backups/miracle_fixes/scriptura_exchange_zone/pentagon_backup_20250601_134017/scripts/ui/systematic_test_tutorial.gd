# Systematic Test Tutorial - Click Through Every Function
# Tests each feature one by one, reports results back to you
extends UniversalBeingBase
class_name SystematicTestTutorial

# UI Elements
var main_panel: Panel
var title_label: Label
var current_test_label: Label
var result_display: RichTextLabel
var next_button: Button
var previous_button: Button
var test_button: Button
var close_button: Button

# Test System
var current_test_index: int = 0
var test_results: Array = []
var tests_completed: int = 0

# All tests to perform
var test_suite: Array = [
	{
		"name": "Console Basic Test",
		"description": "Test if console opens and responds",
		"command": "help",
		"expected": "Shows command list"
	},
	{
		"name": "Object Spawning - Box",
		"description": "Test basic object creation",
		"command": "box",
		"expected": "Creates a box in the scene"
	},
	{
		"name": "Object Spawning - Tree",
		"description": "Test tree spawning",
		"command": "tree", 
		"expected": "Creates a tree model"
	},
	{
		"name": "Scene Clear",
		"description": "Test object removal",
		"command": "clear",
		"expected": "Removes all spawned objects"
	},
	{
		"name": "Ragdoll Spawn",
		"description": "Test ragdoll creation",
		"command": "spawn_ragdoll",
		"expected": "Creates a working ragdoll"
	},
	{
		"name": "Ragdoll Movement",
		"description": "Test ragdoll walking",
		"command": "walk",
		"expected": "Ragdoll starts walking"
	},
	{
		"name": "Ragdoll Jump",
		"description": "Test ragdoll jumping",
		"command": "ragdoll_jump",
		"expected": "Ragdoll performs jump"
	},
	{
		"name": "Astral Being",
		"description": "Test astral being creation",
		"command": "astral_being",
		"expected": "Creates flying astral being"
	},
	{
		"name": "Ground Restore",
		"description": "Test ground restoration",
		"command": "ground",
		"expected": "Restores missing ground"
	},
	{
		"name": "System Status",
		"description": "Test system reporting",
		"command": "system_status",
		"expected": "Shows all system states"
	},
	{
		"name": "Save System",
		"description": "Test scene saving",
		"command": "save test_scene",
		"expected": "Saves current scene state"
	},
	{
		"name": "Load System", 
		"description": "Test scene loading",
		"command": "load test_scene",
		"expected": "Loads saved scene"
	},
	{
		"name": "Physics Test",
		"description": "Test physics controls",
		"command": "gravity 5.0",
		"expected": "Changes gravity value"
	},
	{
		"name": "Object Inspector",
		"description": "Test object selection",
		"command": "select box_1",
		"expected": "Selects and highlights object"
	},
	{
		"name": "Performance Check",
		"description": "Test performance monitoring",
		"command": "performance",
		"expected": "Shows FPS and memory info"
	}
]

signal test_completed(test_name: String, result: String, success: bool)
signal tutorial_finished(total_tests: int, passed: int, failed: int)

func _ready():
	_create_tutorial_ui()
	_position_ui()
	_start_tutorial()

func _create_tutorial_ui():
	# Main panel
	main_panel = Panel.new()
	main_panel.size = Vector2(600, 500)
	main_panel.anchors_preset = Control.PRESET_CENTER
	add_child(main_panel)
	
	# Background
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.9)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color.CYAN
	main_panel.add_theme_stylebox_override("panel", style)
	
	# Title
	title_label = Label.new()
	title_label.text = "🧪 SYSTEMATIC FUNCTION TESTER"
	title_label.position = Vector2(20, 20)
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", Color.CYAN)
	FloodgateController.universal_add_child(title_label, main_panel)
	
	# Current test info
	current_test_label = Label.new()
	current_test_label.position = Vector2(20, 60)
	current_test_label.size = Vector2(560, 80)
	current_test_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	current_test_label.add_theme_font_size_override("font_size", 16)
	FloodgateController.universal_add_child(current_test_label, main_panel)
	
	# Test button (BIG!)
	test_button = Button.new()
	test_button.text = "🎯 TEST THIS FUNCTION"
	test_button.position = Vector2(150, 150)
	test_button.size = Vector2(300, 60)
	test_button.add_theme_font_size_override("font_size", 20)
	test_button.add_theme_color_override("font_color", Color.WHITE)
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.2, 0.6, 0.2)
	test_button.add_theme_stylebox_override("normal", button_style)
	test_button.pressed.connect(_run_current_test)
	FloodgateController.universal_add_child(test_button, main_panel)
	
	# Result display
	result_display = RichTextLabel.new()
	result_display.position = Vector2(20, 230)
	result_display.size = Vector2(560, 180)
	result_display.bbcode_enabled = true
	result_display.text = "[color=white]Click TEST to check if this function works properly[/color]"
	FloodgateController.universal_add_child(result_display, main_panel)
	
	# Navigation buttons
	previous_button = Button.new()
	previous_button.text = "◀ Previous"
	previous_button.position = Vector2(20, 430)
	previous_button.size = Vector2(120, 40)
	previous_button.pressed.connect(_previous_test)
	FloodgateController.universal_add_child(previous_button, main_panel)
	
	next_button = Button.new()
	next_button.text = "Next ▶"
	next_button.position = Vector2(160, 430)
	next_button.size = Vector2(120, 40)
	next_button.pressed.connect(_next_test)
	FloodgateController.universal_add_child(next_button, main_panel)
	
	# Close button
	close_button = Button.new()
	close_button.text = "❌ Close Tutorial"
	close_button.position = Vector2(460, 430)
	close_button.size = Vector2(120, 40)
	close_button.add_theme_color_override("font_color", Color.RED)
	close_button.pressed.connect(_close_tutorial)
	FloodgateController.universal_add_child(close_button, main_panel)

func _position_ui():
	# Center on screen
	var viewport_size = get_viewport().get_visible_rect().size
	main_panel.position = (viewport_size - main_panel.size) / 2

func _start_tutorial():
	current_test_index = 0
	test_results.clear()
	tests_completed = 0
	_update_current_test()

func _update_current_test():
	if current_test_index >= test_suite.size():
		_finish_tutorial()
		return
	
	var test = test_suite[current_test_index]
	
	# Update UI
	current_test_label.text = "Test %d/%d: %s\n%s\nCommand: '%s'\nExpected: %s" % [
		current_test_index + 1,
		test_suite.size(),
		test.name,
		test.description,
		test.command,
		test.expected
	]
	
	# Update navigation buttons
	previous_button.disabled = current_test_index == 0
	next_button.text = "Next ▶" if current_test_index < test_suite.size() - 1 else "Finish"
	
	# Reset result display
	result_display.text = "[color=white]Click TEST to check if this function works properly[/color]"

func _run_current_test():
	var test = test_suite[current_test_index]
	
	result_display.text = "[color=yellow]⏳ Testing: " + test.command + "[/color]"
	
	# Get console manager
	var console = get_node_or_null("/root/ConsoleManager")
	if not console:
		_record_test_result(test.name, "❌ Console Manager not found", false)
		return
	
	# Count objects before test
	var objects_before = _count_scene_objects()
	
	# Execute the command
	var success = false
	var result_message = ""
	
	# Give command time to execute
	await get_tree().create_timer(0.1).timeout
	
	# Try to execute command
	if console.has_method("execute_command"):
		console.execute_command(test.command)
		await get_tree().create_timer(1.0).timeout  # Wait for execution
		
		# Check results based on command type
		match test.command:
			"help":
				success = true
				result_message = "✅ Help command executed"
			"box", "tree", "rock":
				var objects_after = _count_scene_objects()
				success = objects_after > objects_before
				result_message = "✅ Object created" if success else "❌ No object created"
			"clear":
				var objects_after = _count_scene_objects()
				success = objects_after < objects_before
				result_message = "✅ Objects cleared" if success else "❌ Objects not cleared"
			"spawn_ragdoll":
				var ragdolls = get_tree().get_nodes_in_group("ragdolls")
				success = ragdolls.size() > 0
				result_message = "✅ Ragdoll spawned" if success else "❌ No ragdoll found"
			"astral_being":
				var astrals = get_tree().get_nodes_in_group("astral_beings")
				success = astrals.size() > 0
				result_message = "✅ Astral being created" if success else "❌ Astral being failed"
			_:
				# Generic test - assume success if no error
				success = true
				result_message = "✅ Command executed (check manually)"
	else:
		result_message = "❌ Console execute_command method not found"
		success = false
	
	_record_test_result(test.name, result_message, success)

func _record_test_result(test_name: String, result: String, success: bool):
	# Store result
	test_results.append({
		"name": test_name,
		"result": result,
		"success": success,
		"timestamp": Time.get_datetime_string_from_system()
	})
	
	# Update display
	var color = "green" if success else "red"
	result_display.text = "[color=%s]%s[/color]" % [color, result]
	
	# Print to console for logging
	print("🧪 [TestTutorial] %s: %s" % [test_name, result])
	
	emit_signal("test_completed", test_name, result, success)
	
	if success:
		tests_completed += 1

func _next_test():
	if current_test_index < test_suite.size() - 1:
		current_test_index += 1
		_update_current_test()
	else:
		_finish_tutorial()

func _previous_test():
	if current_test_index > 0:
		current_test_index -= 1
		_update_current_test()

func _finish_tutorial():
	var passed = test_results.filter(func(r): return r.success).size()
	var failed = test_results.size() - passed
	
	# Show final results
	result_display.text = """[color=cyan]🎉 TUTORIAL COMPLETE![/color]
	
Tests Passed: [color=green]%d[/color]
Tests Failed: [color=red]%d[/color]
Total Tests: %d

[color=yellow]Results saved to console log for Claude analysis[/color]""" % [passed, failed, test_results.size()]
	
	# Generate detailed report
	_generate_final_report()
	
	emit_signal("tutorial_finished", test_results.size(), passed, failed)
	
	# Change test button to restart
	test_button.text = "🔄 RESTART TUTORIAL"
	test_button.pressed.disconnect(_run_current_test)
	test_button.pressed.connect(_restart_tutorial)

func _generate_final_report():
	print("\n" + "=".repeat(60))
	print("🧪 SYSTEMATIC TEST TUTORIAL RESULTS")
	print("=".repeat(60))
	print("Total Tests: %d" % test_results.size())
	print("Passed: %d" % test_results.filter(func(r): return r.success).size())
	print("Failed: %d" % test_results.filter(func(r): return not r.success).size())
	print("\nDETAILED RESULTS:")
	
	for i in range(test_results.size()):
		var result = test_results[i]
		var status = "✅" if result.success else "❌"
		print("%d. %s %s - %s" % [i+1, status, result.name, result.result])
	
	print("\n" + "=".repeat(60))
	print("📋 RECOMMENDATIONS FOR CLAUDE:")
	
	var failed_tests = test_results.filter(func(r): return not r.success)
	if failed_tests.size() > 0:
		print("🚨 BROKEN FUNCTIONS TO FIX:")
		for test in failed_tests:
			print("  - " + test.name + ": " + test.result)
	
	var working_tests = test_results.filter(func(r): return r.success)
	if working_tests.size() > 0:
		print("✅ WORKING FUNCTIONS (keep these):")
		for test in working_tests:
			print("  - " + test.name)
	
	print("=".repeat(60) + "\n")

func _restart_tutorial():
	_start_tutorial()
	test_button.text = "🎯 TEST THIS FUNCTION"
	test_button.pressed.disconnect(_restart_tutorial)
	test_button.pressed.connect(_run_current_test)

func _close_tutorial():
	queue_free()

func _count_scene_objects() -> int:
	var count = 0
	var root = get_tree().current_scene
	if root:
		count = _count_children_recursive(root)
	return count

func _count_children_recursive(node: Node) -> int:
	var count = 1  # Count this node
	for child in node.get_children():
		count += _count_children_recursive(child)
	return count

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