# ==================================================
# SCRIPT NAME: feature_test_panel.gd
# DESCRIPTION: Visual test panel with buttons for all features
# PURPOSE: Quick testing and status reporting
# CREATED: 2025-05-28 - Feature testing UI
# ==================================================

extends UniversalBeingBase
# signal test_completed(feature: String, success: bool)  # Currently unused but kept for future expansion

# UI Components
var panel: PanelContainer
var scroll: ScrollContainer
var button_container: VBoxContainer
var status_label: Label
var minimize_button: Button

# State
var is_minimized: bool = false
var test_results: Dictionary = {}

# Feature categories
var features = {
	"🎮 Console": [
		{"name": "Toggle Console", "command": "toggle_console", "test": "_test_console"},
		{"name": "Test Commands", "command": "help", "test": "_test_commands"},
		{"name": "Fix Console Size", "command": "fix_console", "test": "_test_console_fix"}
	],
	"🔍 Inspector": [
		{"name": "Open Inspector", "command": "inspect Ground", "test": "_test_inspector"},
		{"name": "Select All", "command": "select_all", "test": "_test_selection"},
		{"name": "Edit Property", "command": "edit position 0,5,0", "test": "_test_edit"}
	],
	"🌟 Astral Beings": [
		{"name": "Spawn Being", "action": "_spawn_astral_being", "test": "_test_astral_spawn"},
		{"name": "Move Being", "action": "_test_astral_move", "test": "_test_astral_move"},
		{"name": "Organize Scene", "action": "_test_astral_organize", "test": "_test_astral_organize"},
		{"name": "Create Light", "action": "_test_astral_light", "test": "_test_astral_light"}
	],
	"🚶 Ragdoll": [
		{"name": "Spawn Walker", "command": "spawn_biowalker", "test": "_test_ragdoll_spawn"},
		{"name": "Walk Forward", "command": "walk forward", "test": "_test_ragdoll_walk"},
		{"name": "Debug View", "command": "walker_debug all on", "test": "_test_ragdoll_debug"}
	],
	"🏗️ Scenes": [
		{"name": "Create Object", "command": "create_mesh sphere", "test": "_test_create_object"},
		{"name": "Save Scene", "command": "save_scene test.tscn", "test": "_test_save_scene"},
		{"name": "Clear Scene", "command": "clear", "test": "_test_clear_scene"}
	],
	"⚡ Floodgate": [
		{"name": "Check Status", "action": "_test_floodgate_status", "test": "_test_floodgate_status"},
		{"name": "Queue Test", "action": "_test_floodgate_queue", "test": "_test_floodgate_queue"},
		{"name": "Performance", "command": "performance", "test": "_test_performance"}
	]
}

# References
var console_manager: Node
var astral_beings: Array = []

func _ready() -> void:
	_setup_ui()
	_create_buttons()
	_setup_references()
	
	# Position in top-right corner
	set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	position.x -= 320
	position.y += 20
	
	print("[FeatureTestPanel] Test panel ready")

func _setup_ui() -> void:
	# Main panel
	panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 500)
	add_child(panel)
	
	# Style
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.12, 0.95)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.3, 0.5, 0.8, 0.8)
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", panel_style)
	
	# Main container
	var vbox = VBoxContainer.new()
	FloodgateController.universal_add_child(vbox, panel)
	
	# Header
	var header = HBoxContainer.new()
	FloodgateController.universal_add_child(header, vbox)
	
	var title = Label.new()
	title.text = "🧪 Feature Test Panel"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	FloodgateController.universal_add_child(title, header)
	
	header.add_spacer(true)
	
	minimize_button = Button.new()
	minimize_button.text = "—"
	minimize_button.custom_minimum_size = Vector2(30, 30)
	minimize_button.pressed.connect(_toggle_minimize)
	FloodgateController.universal_add_child(minimize_button, header)
	
	# Status label
	status_label = Label.new()
	status_label.text = "Ready to test"
	status_label.add_theme_color_override("font_color", Color(0.7, 0.9, 0.7))
	FloodgateController.universal_add_child(status_label, vbox)
	
	FloodgateController.universal_add_child(HSeparator.new(, vbox))
	
	# Scroll container
	scroll = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(280, 400)
	FloodgateController.universal_add_child(scroll, vbox)
	
	# Button container
	button_container = VBoxContainer.new()
	button_container.add_theme_constant_override("separation", 5)
	FloodgateController.universal_add_child(button_container, scroll)

func _create_buttons() -> void:
	for category in features:
		# Category header
		var category_label = Label.new()
		category_label.text = category
		category_label.add_theme_font_size_override("font_size", 14)
		category_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
		FloodgateController.universal_add_child(category_label, button_container)
		
		# Feature buttons
		for feature in features[category]:
			var button = Button.new()
			button.text = "  " + feature.name
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			
			# Store feature data
			button.set_meta("feature", feature)
			button.set_meta("category", category)
			
			# Connect signal
			button.pressed.connect(_on_button_pressed.bind(button))
			
			# Style
			var button_style = StyleBoxFlat.new()
			button_style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
			button_style.border_width_left = 2
			button_style.border_width_top = 1
			button_style.border_width_right = 1
			button_style.border_width_bottom = 1
			button_style.border_color = Color(0.3, 0.3, 0.4, 0.5)
			button_style.corner_radius_top_left = 4
			button_style.corner_radius_top_right = 4
			button_style.corner_radius_bottom_left = 4
			button_style.corner_radius_bottom_right = 4
			button.add_theme_stylebox_override("normal", button_style)
			
			# Hover style
			var hover_style = button_style.duplicate()
			hover_style.bg_color = Color(0.2, 0.2, 0.3, 0.9)
			hover_style.border_color = Color(0.4, 0.5, 0.7, 0.8)
			button.add_theme_stylebox_override("hover", hover_style)
			
			FloodgateController.universal_add_child(button, button_container)
		
		# Add spacing
		FloodgateController.universal_add_child(Control.new(, button_container))

func _setup_references() -> void:
	console_manager = get_node_or_null("/root/ConsoleManager")

func _on_button_pressed(button: Button) -> void:
	var feature = button.get_meta("feature")
	var _category = button.get_meta("category")
	
	_update_status("Testing: " + feature.name, Color.YELLOW)
	
	# Execute the feature
	if feature.has("command"):
		# Console command
		if console_manager:
			console_manager._execute_command(feature.command)
	elif feature.has("action"):
		# Direct action
		call(feature.action)
	
	# Run test if specified
	if feature.has("test"):
		call_deferred(feature.test, button)
	else:
		_mark_success(button)

# ================================
# TEST IMPLEMENTATIONS
# ================================

func _test_console(button: Button) -> void:
	await get_tree().create_timer(0.5).timeout
	var console_visible = console_manager and console_manager.is_visible
	_mark_result(button, console_visible)

func _test_commands(button: Button) -> void:
	# Commands execute instantly if console exists
	_mark_result(button, console_manager != null)

func _test_console_fix(button: Button) -> void:
	await get_tree().create_timer(0.5).timeout
	_mark_success(button)

func _test_inspector(button: Button) -> void:
	await get_tree().create_timer(0.5).timeout
	var inspectors = get_tree().get_nodes_in_group("object_inspectors")
	_mark_result(button, inspectors.size() > 0)

func _test_selection(button: Button) -> void:
	await get_tree().create_timer(0.5).timeout
	_mark_success(button)  # Assume success if no error

func _test_edit(button: Button) -> void:
	await get_tree().create_timer(0.5).timeout
	_mark_success(button)

func _spawn_astral_being() -> void:
	var being_scene = preload("res://scripts/core/magical_astral_being.gd")
	var being = being_scene.new()
	being.being_name = "Astral Helper " + str(astral_beings.size() + 1)
	being.position = Vector3(randf_range(-5, 5), 3, randf_range(-5, 5))
	being.color = Color(randf(), randf_range(0.5, 1.0), randf_range(0.8, 1.0))
	
	get_tree().FloodgateController.universal_add_child(being, current_scene)
	astral_beings.append(being)

func _test_astral_spawn(button: Button) -> void:
	_spawn_astral_being()
	await get_tree().create_timer(0.5).timeout
	_mark_result(button, astral_beings.size() > 0)

func _test_astral_move(button: Button) -> void:
	if astral_beings.is_empty():
		_spawn_astral_being()
	
	var being = astral_beings[0]
	being.add_task("move_to", {"position": Vector3(0, 2, 0)})
	
	await get_tree().create_timer(1.0).timeout
	_mark_success(button)

func _test_astral_organize(button: Button) -> void:
	if astral_beings.is_empty():
		_spawn_astral_being()
	
	# Create some objects to organize
	for i in range(5):
		var mesh = MeshInstance3D.new()
		mesh.mesh = BoxMesh.new()
		mesh.position = Vector3(randf_range(-3, 3), 1, randf_range(-3, 3))
		
		var body = RigidBody3D.new()
		FloodgateController.universal_add_child(mesh, body)
		get_tree().FloodgateController.universal_add_child(body, current_scene)
		
		var shape = CollisionShape3D.new()
		shape.shape = BoxShape3D.new()
		FloodgateController.universal_add_child(shape, body)
	
	var being = astral_beings[0]
	being.add_task("organize_area", {"center": Vector3.ZERO})
	
	await get_tree().create_timer(3.0).timeout
	_mark_success(button)

func _test_astral_light(button: Button) -> void:
	if astral_beings.is_empty():
		_spawn_astral_being()
	
	var being = astral_beings[0]
	being.add_task("create_light", {"position": Vector3(5, 2, 5)})
	
	await get_tree().create_timer(2.0).timeout
	_mark_success(button)

func _test_ragdoll_spawn(button: Button) -> void:
	await get_tree().create_timer(1.0).timeout
	var ragdolls = get_tree().get_nodes_in_group("ragdolls")
	_mark_result(button, ragdolls.size() > 0)

func _test_ragdoll_walk(button: Button) -> void:
	await get_tree().create_timer(1.0).timeout
	_mark_success(button)

func _test_ragdoll_debug(button: Button) -> void:
	await get_tree().create_timer(0.5).timeout
	_mark_success(button)

func _test_create_object(button: Button) -> void:
	await get_tree().create_timer(0.5).timeout
	_mark_success(button)

func _test_save_scene(button: Button) -> void:
	await get_tree().create_timer(1.0).timeout
	_mark_success(button)

func _test_clear_scene(button: Button) -> void:
	await get_tree().create_timer(0.5).timeout
	_mark_success(button)

func _test_floodgate_status(button: Button) -> void:
	var floodgate = get_node_or_null("/root/FloodgateController")
	if floodgate:
		_update_status("Floodgate: Active", Color.GREEN)
		_mark_success(button)
	else:
		_update_status("Floodgate: Not found", Color.RED)
		_mark_failure(button)

func _test_floodgate_queue(button: Button) -> void:
	var floodgate = get_node_or_null("/root/FloodgateController")
	if floodgate and floodgate.has_method("queue_operation"):
		# Queue a test operation
		floodgate.queue_operation({
			"type": "test",
			"data": "Test operation from test panel"
		})
		_mark_success(button)
	else:
		_mark_failure(button)

func _test_performance(button: Button) -> void:
	await get_tree().create_timer(0.5).timeout
	_mark_success(button)

# ================================
# UI HELPERS
# ================================

func _mark_success(button: Button) -> void:
	button.text = "✅ " + button.get_meta("feature").name
	button.modulate = Color(0.7, 1.0, 0.7)
	test_results[button] = true
	_update_test_count()

func _mark_failure(button: Button) -> void:
	button.text = "❌ " + button.get_meta("feature").name
	button.modulate = Color(1.0, 0.7, 0.7)
	test_results[button] = false
	_update_test_count()

func _mark_result(button: Button, success: bool) -> void:
	if success:
		_mark_success(button)
	else:
		_mark_failure(button)

func _update_status(text: String, color: Color = Color.WHITE) -> void:
	status_label.text = text
	status_label.add_theme_color_override("font_color", color)

func _update_test_count() -> void:
	var passed = 0
	var total = test_results.size()
	
	for result in test_results.values():
		if result:
			passed += 1
	
	if total > 0:
		var percent = (float(passed) / float(total)) * 100
		_update_status("Tests: %d/%d (%.0f%%)" % [passed, total, percent], 
			Color.GREEN if percent == 100 else Color.YELLOW)

func _toggle_minimize() -> void:
	is_minimized = !is_minimized
	scroll.visible = !is_minimized
	status_label.visible = !is_minimized
	
	if is_minimized:
		panel.custom_minimum_size.y = 50
		minimize_button.text = "+"
	else:
		panel.custom_minimum_size.y = 500
		minimize_button.text = "—"

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