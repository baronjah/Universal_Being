# 🏛️ Interactive Tutorial System - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
## Interactive Tutorial System
## Press buttons instead of typing commands, automatic testing and logging

signal test_completed(test_name: String, success: bool, details: Dictionary)
signal tutorial_finished(results: Dictionary)

@onready var console_manager = $"/root/ConsoleManager"
@onready var scene_manager = $"/root/UnifiedSceneManager"

var test_results: Dictionary = {}
var current_test: String = ""
var initial_state: Dictionary = {}

## Tutorial flow states
enum TutorialState {
	NOT_STARTED,
	BASIC_SPAWN,
	MOVEMENT_TEST,
	INTERACTION_TEST,
	CLEANUP_TEST,
	COMPLETED
}

var tutorial_state: TutorialState = TutorialState.NOT_STARTED

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	visible = false
	_create_ui()
	_save_initial_state()

func _save_initial_state() -> void:
	"""Save the initial scene state for restoration"""
	initial_state = {
		"ragdoll_count": get_tree().get_nodes_in_group("ragdolls").size(),
		"camera_position": get_viewport().get_camera_3d().global_position if get_viewport().get_camera_3d() else Vector3.ZERO,
		"ground_visible": scene_manager.original_ground.visible if scene_manager.original_ground else true
	}

func _create_ui() -> void:
	"""Create the button-based UI"""
	var vbox = VBoxContainer.new()
	add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "🎮 Interactive Ragdoll Tutorial"
	title.add_theme_font_size_override("font_size", 24)
	FloodgateController.universal_add_child(title, vbox)
	
	FloodgateController.universal_add_child(HSeparator.new(, vbox))
	
	# Current test label
	var test_label = Label.new()
	test_label.name = "TestLabel"
	test_label.text = "Press 'Start Tutorial' to begin"
	FloodgateController.universal_add_child(test_label, vbox)
	
	# Button container
	var button_container = VBoxContainer.new()
	button_container.name = "ButtonContainer"
	FloodgateController.universal_add_child(button_container, vbox)
	
	# Start button
	var start_btn = Button.new()
	start_btn.text = "🚀 Start Tutorial"
	start_btn.pressed.connect(_start_tutorial)
	FloodgateController.universal_add_child(start_btn, button_container)
	
	FloodgateController.universal_add_child(HSeparator.new(, vbox))
	
	# Results display
	var results_label = RichTextLabel.new()
	results_label.name = "ResultsLabel"
	results_label.custom_minimum_size = Vector2(400, 200)
	results_label.bbcode_enabled = true
	FloodgateController.universal_add_child(results_label, vbox)
	
	# Close button
	var close_btn = Button.new()
	close_btn.text = "❌ Close Tutorial"
	close_btn.pressed.connect(_close_tutorial)
	FloodgateController.universal_add_child(close_btn, vbox)
	
	# Position in corner
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 0.0
	anchor_bottom = 0.0
	position = Vector2(20, 100)

func _start_tutorial() -> void:
	"""Begin the interactive tutorial"""
	print("🎯 Starting Interactive Tutorial")
	test_results.clear()
	tutorial_state = TutorialState.BASIC_SPAWN
	_update_test_ui()

func _update_test_ui() -> void:
	"""Update UI based on current tutorial state"""
	var test_label = $VBoxContainer/TestLabel
	var button_container = $VBoxContainer/ButtonContainer
	
	# Clear existing test buttons
	for child in button_container.get_children():
		if child.text.begins_with("🚀"):  # Keep start button
			continue
		child.queue_free()
	
	match tutorial_state:
		TutorialState.BASIC_SPAWN:
			test_label.text = "Test 1: Basic Ragdoll Spawning"
			_add_test_buttons([
				{"text": "✅ Spawn at Origin", "command": "spawn"},
				{"text": "📍 Spawn at Camera", "command": "spawn_at_camera"},
				{"text": "🔢 Spawn at 5,0,5", "command": "spawn 5 0 5"},
				{"text": "🗑️ Clear All", "command": "clear"}
			])
			
		TutorialState.MOVEMENT_TEST:
			test_label.text = "Test 2: Ragdoll Movement"
			_add_test_buttons([
				{"text": "🚶 Spawn Walker", "command": "walker"},
				{"text": "⚡ Set Speed Fast", "command": "walker_speed 3.0"},
				{"text": "🐌 Set Speed Slow", "command": "walker_speed 0.5"},
				{"text": "💪 Set Force High", "command": "walker_force 150"},
				{"text": "🪶 Set Force Low", "command": "walker_force 50"}
			])
			
		TutorialState.INTERACTION_TEST:
			test_label.text = "Test 3: Ragdoll Interaction"
			_add_test_buttons([
				{"text": "📋 List Ragdolls", "command": "list_ragdolls"},
				{"text": "🎯 Select First", "command": "select_ragdoll 0"},
				{"text": "👁️ Show Inspector", "command": "object_inspector show"},
				{"text": "🔍 Debug Physics", "command": "debug_physics"},
				{"text": "📊 Performance Stats", "command": "performance_stats"}
			])
			
		TutorialState.CLEANUP_TEST:
			test_label.text = "Test 4: Scene Management"
			_add_test_buttons([
				{"text": "🗑️ Clear Ragdolls", "command": "clear"},
				{"text": "🌍 Show Ground", "command": "restore_ground"},
				{"text": "🎮 Setup Systems", "command": "setup_systems"},
				{"text": "🔄 Reset Scene", "command": "_reset_scene", "special": true}
			])
			
		TutorialState.COMPLETED:
			test_label.text = "Tutorial Complete! Check results below."
			_show_final_results()
	
	# Add next button if not completed
	if tutorial_state != TutorialState.COMPLETED:
		var next_btn = Button.new()
		next_btn.text = "➡️ Next Test"
		next_btn.pressed.connect(_next_test)
		FloodgateController.universal_add_child(next_btn, button_container)

func _add_test_buttons(tests: Array) -> void:
	"""Add test buttons to the UI"""
	var button_container = $VBoxContainer/ButtonContainer
	
	for test in tests:
		var btn = Button.new()
		btn.text = test.text
		
		if test.get("special", false):
			btn.pressed.connect(_reset_scene)
		else:
			btn.pressed.connect(_run_test.bind(test.text, test.command))
		
		FloodgateController.universal_add_child(btn, button_container)
		
		# Add YES/NO buttons for each test
		var result_container = HBoxContainer.new()
		FloodgateController.universal_add_child(result_container, button_container)
		
		var yes_btn = Button.new()
		yes_btn.text = "✅ Worked"
		yes_btn.modulate = Color.GREEN
		yes_btn.pressed.connect(_record_result.bind(test.text, true))
		FloodgateController.universal_add_child(yes_btn, result_container)
		
		var no_btn = Button.new()
		no_btn.text = "❌ Failed"
		no_btn.modulate = Color.RED
		no_btn.pressed.connect(_record_result.bind(test.text, false))
		FloodgateController.universal_add_child(no_btn, result_container)
		
		FloodgateController.universal_add_child(Label.new(, result_container))  # Spacer

func _run_test(test_name: String, command: String) -> void:
	"""Execute a test command"""
	current_test = test_name
	print("🧪 Running test: ", test_name)
	
	# Execute through console
	console_manager._execute_command(command)
	
	# Log the action
	_update_results("Executed: " + command)

func _record_result(test_name: String, success: bool) -> void:
	"""Record test result"""
	test_results[test_name] = {
		"success": success,
		"state": tutorial_state,
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	var result_text = "[color=%s]%s: %s[/color]" % [
		"green" if success else "red",
		test_name,
		"PASSED" if success else "FAILED"
	]
	_update_results(result_text)
	
	emit_signal("test_completed", test_name, success, test_results[test_name])

func _next_test() -> void:
	"""Move to next test phase"""
	match tutorial_state:
		TutorialState.BASIC_SPAWN:
			tutorial_state = TutorialState.MOVEMENT_TEST
		TutorialState.MOVEMENT_TEST:
			tutorial_state = TutorialState.INTERACTION_TEST
		TutorialState.INTERACTION_TEST:
			tutorial_state = TutorialState.CLEANUP_TEST
		TutorialState.CLEANUP_TEST:
			tutorial_state = TutorialState.COMPLETED
	
	_update_test_ui()

func _reset_scene() -> void:
	"""Reset scene to initial state"""
	print("🔄 Resetting scene to initial state")
	
	# Clear all ragdolls
	console_manager._execute_command("clear")
	
	# Restore ground
	if scene_manager.original_ground:
		scene_manager.original_ground.visible = initial_state.get("ground_visible", true)
	
	# Reset camera if possible
	var camera = get_viewport().get_camera_3d()
	if camera and initial_state.has("camera_position"):
		camera.global_position = initial_state.camera_position
	
	_update_results("[color=yellow]Scene reset to initial state[/color]")

func _update_results(text: String) -> void:
	"""Update the results display"""
	var results_label = $VBoxContainer/ResultsLabel
	results_label.append_text(text + "\n")

func _show_final_results() -> void:
	"""Display final test results and save to file"""
	var results_label = $VBoxContainer/ResultsLabel
	results_label.clear()
	results_label.append_text("[b]Tutorial Results:[/b]\n\n")
	
	var passed = 0
	var failed = 0
	
	for test_name in test_results:
		var result = test_results[test_name]
		if result.success:
			passed += 1
			results_label.append_text("[color=green]✅ %s[/color]\n" % test_name)
		else:
			failed += 1
			results_label.append_text("[color=red]❌ %s[/color]\n" % test_name)
	
	results_label.append_text("\n[b]Summary:[/b]\n")
	results_label.append_text("Passed: %d\n" % passed)
	results_label.append_text("Failed: %d\n" % failed)
	results_label.append_text("Success Rate: %.1f%%\n" % (float(passed) / float(passed + failed) * 100.0))
	
	# Save results to file
	_save_results_to_file()
	
	emit_signal("tutorial_finished", test_results)

func _save_results_to_file() -> void:
	"""Save test results to a file for analysis"""
	var file = FileAccess.open("user://tutorial_results_%s.json" % Time.get_datetime_string_from_system(), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(test_results, "\t"))
		file.close()
		_update_results("\n[color=yellow]Results saved to file[/color]")

func _close_tutorial() -> void:
	"""Close the tutorial UI"""
	visible = false


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
func show_tutorial() -> void:
	"""Show the tutorial UI"""
	visible = true
	tutorial_state = TutorialState.NOT_STARTED
	_save_initial_state()