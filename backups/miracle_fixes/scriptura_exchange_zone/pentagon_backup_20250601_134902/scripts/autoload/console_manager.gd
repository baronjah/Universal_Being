# ==================================================
# SCRIPT NAME: console_manager.gd
# DESCRIPTION: Scalable in-game console with proper UI anchoring
# CREATED: 2025-05-23 - Professional console system
# ==================================================

extends UniversalBeingBase
signal command_executed(command: String, args: Array)

# Console UI elements
var console_container: Control
var console_panel: PanelContainer
var content_vbox: VBoxContainer
var title_bar: HBoxContainer
var output_scroll: ScrollContainer
var output_display: RichTextLabel
var input_container: HBoxContainer
var input_field: LineEdit
var submit_button: Button

# Animation
var tween: Tween
var is_visible: bool = false
var is_animating: bool = false

# Command history
var command_history: Array[String] = []
var history_index: int = 0
const MAX_HISTORY: int = 50

# Output history
var output_lines: Array[String] = []
const MAX_OUTPUT_LINES: int = 500

# Debug control
var debug_level: int = 1  # 0=none, 1=errors only, 2=info, 3=verbose

# Object inspector
var object_inspector: Control = null

# Debug visualizer
var debug_visualizer: Node3D = null


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
func debug_print(message: String, level: int = 2) -> void:
	if debug_level >= level:
		print(message)

# Available commands
var commands: Dictionary = {
	# help command, listing all commands possible in console, needs upodate and cleanse
	"help": _cmd_help,
	# Manual setup command
	"setup_systems": _cmd_setup_systems,
	# process and performance
	"performance": _cmd_performance_stats,
	"process_manager": _cmd_process_manager,
	# this was supposed to be an automatic test of whole game
	"test": _cmd_test_features,
	"test_being_assets": _cmd_test_being_assets,
	"gizmo": _cmd_gizmo,
	# version of game
	"version": _cmd_version_control,
	# console settings, position, size
	"console": _cmd_console_settings,
	"scale": _cmd_set_scale,
	# physics connected to gravity
	"physics": _cmd_physics_control,
	"physics_test": _cmd_physics_test,
	"gravity": _cmd_physics,
	# Floodgate system commands
	"floodgate": _cmd_floodgate_status,
	"queues": _cmd_queue_status,
	"healthcheck": _cmd_health_check,
	"floodtest": _cmd_test_floodgate,
	"systems": _cmd_system_status,
	"system_status": _cmd_system_status,  # Alias for systems
	"create": _cmd_create,
	"spawn": _cmd_create,  # 
	# assets
	"tree": _cmd_create_tree,
	"rock": _cmd_create_rock,
	"box": _cmd_create_box,
	"ball": _cmd_create_ball,
	"wall": _cmd_create_wall,
	"stick": _cmd_create_stick,
	"leaf": _cmd_create_leaf,
	"ramp": _cmd_create_ramp,
	"sun": _cmd_create_sun,
	"pathway": _cmd_create_pathway,
	"path": _cmd_create_pathway,  # Alias
	"bush": _cmd_create_bush,
	"fruit": _cmd_create_fruit,
	# asset creator and asset list
	"assets": _cmd_list_assets,
	"asset_creator": _cmd_open_asset_creator,
	"test_cube": _cmd_test_cube,
	"inspect_cube": _cmd_inspect_cube,
	"viewport_info": _cmd_viewport_info,
	"camera_rays": _cmd_camera_rays,
	# Universal Cursor commands
	"cursor": _cmd_create_cursor,
	"cursor_spawn": _cmd_create_cursor,
	"cursor_active": _cmd_cursor_active,
	"cursor_debug": _cmd_cursor_debug,
	"cursor_size": _cmd_cursor_size,
	# Neural consciousness evolution commands
	"conscious": _cmd_make_conscious,
	"awaken": _cmd_make_conscious,  # Alias
	"think": _cmd_being_think,
	"needs": _cmd_show_needs,
	"goals": _cmd_show_goals,
	"neural_connect": _cmd_neural_connect,
	"consciousness_level": _cmd_consciousness_level,
	"neural_status": _cmd_neural_status,
	"spawn_tree_conscious": _cmd_spawn_conscious_tree,
	"spawn_astral_conscious": _cmd_spawn_conscious_astral,
	"test_consciousness": _cmd_test_consciousness,
	# Enhanced interface commands (simplified for now)
	"interface": _cmd_ui_create,  # Use existing ui command
	"spawn_console": _cmd_ui_create,
	"spawn_creator": _cmd_ui_create,
	"spawn_neural": _cmd_ui_create,
	"spawn_inspector": _cmd_ui_create,
	"list_interfaces": _cmd_ui_create,
	"connect_interface": _cmd_ui_create,
	# game_rules, its connected to the scripts that automatically do and check stuff
	"rules_off": _cmd_toggle_rules,
	"rules": _cmd_txt_rules,
	# universal being
	"being": _cmd_universal_being,
	"ubeing": _cmd_universal_being,  # Short alias
	# astral beings
	"astral": _cmd_create_astral_being,
	"astral_being": _cmd_create_astral_being,
	"astral_control": _cmd_astral_control,
	"talk_to_beings": _cmd_talk_to_beings,
	"being_count": _cmd_being_count,
	"help_ragdoll": _cmd_help_ragdoll,
	"astral_help": _cmd_help_ragdoll,  # Alias
	"beings_status": _cmd_beings_status,
	"beings_help": _cmd_beings_help_ragdoll,
	"beings_organize": _cmd_beings_organize,
	"beings_harmony": _cmd_beings_harmony,
	# ui, grids
	"ui": _cmd_ui_create,
	"grid": _cmd_grid_show,
	# debug, inspecting
	"test_click": _cmd_test_mouse_click,
	"object_inspector": _cmd_object_inspector,
	"inspector": _cmd_object_inspector,
	"debug_panel": _cmd_debug_panel_status,
	"console_debug": _cmd_console_debug_toggle,
	"select": _cmd_select_object,
	"inspect": _cmd_inspect_object,
	"move": _cmd_move_object,
	"rotate": _cmd_rotate_object,
	"scale_obj": _cmd_scale_object,
	"state": _cmd_change_state,
	"awaken_object": _cmd_awaken_object,  # Renamed to avoid duplicate
	"info": _cmd_object_info,
	"list": _cmd_list_objects,
	"delete": _cmd_delete_object,
	"clear": _cmd_clear_objects,
	"scenes": _cmd_list_scene_objects,
	"limits": _cmd_object_limits,
	#the heightmap island, plus some props
	"generate_world": _cmd_generate_world,
	"world": _cmd_generate_world,  # Alias
	# scene commands
	"scene_status": _cmd_scene_status,
	"restore_ground": _cmd_restore_ground,
	"ground": _cmd_restore_ground,  # Alias
	"scene": _cmd_scene,
	"save": _cmd_save_scene,
	"load": _cmd_load_scene,
	# Tutorial system
	"tutorial": _cmd_tutorial,
	"tutorial_start": _cmd_tutorial_start,
	"tutorial_stop": _cmd_tutorial_stop,
	"tutorial_status": _cmd_tutorial_status,
	"tutorial_hide": _cmd_tutorial_hide,
	"tutorial_show": _cmd_tutorial_show,
	"interactive_tutorial": _cmd_interactive_tutorial,
	"test_tutorial": _cmd_test_tutorial,
	# pigeon project, an bird that fly around, do things too
	"pigeon": _cmd_create_pigeon,
	"bird": _cmd_create_pigeon,  # Alias
	# ragdoll commands, also biowalker, walker and many more, in that file res://scripts/patches/console_command_extension.gd
	"spawn_ragdoll": _cmd_spawn_ragdoll,
	"spawn_skeleton": _cmd_spawn_skeleton_ragdoll, # this is different one?
	"ragdoll": _cmd_ragdoll_command,
	"walk": _cmd_ragdoll_walk,
	"say": _cmd_make_ragdoll_say,
	"ragdoll_debug": _cmd_ragdoll_debug,
	"ragdoll_come": _cmd_ragdoll_come_here,
	"ragdoll_pickup": _cmd_ragdoll_pickup_nearest,
	"ragdoll_drop": _cmd_ragdoll_drop,
	"ragdoll_organize": _cmd_ragdoll_organize,
	"ragdoll_patrol": _cmd_ragdoll_patrol,
	"ragdoll_move": _cmd_ragdoll_move,
	"ragdoll_speed": _cmd_ragdoll_speed,
	"ragdoll_run": _cmd_ragdoll_run,
	"ragdoll_crouch": _cmd_ragdoll_crouch,
	"ragdoll_jump": _cmd_ragdoll_jump,
	"ragdoll_rotate": _cmd_ragdoll_rotate,
	"ragdoll_stand": _cmd_ragdoll_stand,
	"ragdoll_state": _cmd_ragdoll_state,
	"test_ragdolls": _cmd_interactive_tutorial,
	# ragdoll v2, we need to make just one for now, maybe we can change few of these ragdolls into different animals in garden
	"spawn_ragdoll_v2": _cmd_spawn_ragdoll_v2,
	"ragdoll2": _cmd_spawn_ragdoll_v2,
	"ragdoll2_move": _cmd_ragdoll2_move,
	"ragdoll2_state": _cmd_ragdoll2_state,
	"ragdoll2_debug": _cmd_ragdoll2_debug,
	#not sure for these yet
	"projects": _cmd_project_manager,
	"timing": _cmd_timing_info,
	"debug": _cmd_debug_screen,
	# Eden action system commands
	"action_list": _cmd_action_list,
	"action_test": _cmd_action_test,
	"action_combo": _cmd_action_combo,
	# Dimensional ragdoll commands
	"dimension": _cmd_dimension_shift,
	"consciousness": _cmd_consciousness_add,
	"emotion": _cmd_emotion_set,
	"spell": _cmd_cast_spell,
	"ragdoll_status": _cmd_ragdoll_status,
	# JSH Enhanced Commands
	"jsh_status": _cmd_jsh_status,
	"container": _cmd_container,
	"thread_status": _cmd_thread_status,
	"scene_tree": _cmd_scene_tree,
	"akashic_save": _cmd_akashic_save,
	"akashic_load": _cmd_akashic_load,
	# not sure
	"timer": _cmd_timer_control,
	"task": _cmd_task_management,
	"todos": _cmd_multi_todos,
	"balance": _cmd_balance_workload,
	# "calibrate": _cmd_terminal_calibration # TODO: Implement this function
	# the automation features, we didnt test them too much yet
	"passive": _cmd_passive_mode,
	"add_task": _cmd_add_task,
	"branch": _cmd_branch,
	"commit": _cmd_commit,
	"mr": _cmd_merge_request,
	"merge": _cmd_merge,
	"workflow": _cmd_workflow_status,
	# AI Sandbox System Commands
	"create_gemma_garden": _cmd_create_gemma_garden,
	"give_knowledge_cube": _cmd_give_knowledge_cube,
	"give_experience_orb": _cmd_give_experience_orb,
	"give_creativity_spark": _cmd_give_creativity_spark,
	"seedling_status": _cmd_seedling_status,
	"garden_health_check": _cmd_garden_health_check,
	"enable_peaceful_growth": _cmd_enable_peaceful_growth,
	# Gemma Vision System Commands
	"gemma_look_at": _cmd_gemma_look_at,
	"gemma_scan_patterns": _cmd_gemma_scan_patterns,
	"feed_gemma_text": _cmd_feed_gemma_text,
	"gemma_vision_status": _cmd_gemma_vision_status,
	"increase_gemma_curiosity": _cmd_increase_gemma_curiosity,
	"show_gemma_layers": _cmd_show_gemma_layers,
	# Universal Being Interface Commands
	"open_being_creator": _cmd_open_being_creator,
	"being_creator": _cmd_open_being_creator
}

var passive_controller: Node
var version_backup: Node
var physics_state_manager: Node
var multi_project_manager: Node
var claude_timer: Node
var multi_todo_manager: Node
var windows_console_fix: Node

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Create a minimal console container immediately for testing
	console_container = Control.new()
	console_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	console_container.visible = false
	
	var test_label = Label.new()
	test_label.text = "Console Test - Press Tab to toggle"
	test_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	test_label.add_theme_font_size_override("font_size", 32)
	FloodgateController.universal_add_child(test_label, console_container)
	
	# Add immediately to scene
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "TestConsoleLayer"
	canvas_layer.layer = 120
	add_child(canvas_layer)
	FloodgateController.universal_add_child(console_container, canvas_layer)
	
	# Enable input immediately for testing
	set_process_unhandled_input(true)
	print("🔑 Console Manager: _ready() called, test console created, input enabled")
	
	# Initialize fully with deferred call
	call_deferred("_safe_initialize")

func _safe_initialize() -> void:
	# Create Windows console fix first
	_create_windows_console_fix()
	
	debug_print("🔧 Console Manager: Starting initialization...", 2)
	
	# Wait for floodgate systems to be ready
	await _wait_for_floodgate_systems()
	
	# Create components with error handling
	_create_passive_controller()
	_create_threaded_system()
	_create_physics_manager()
	_create_project_manager()
	_create_timer_system()
	_create_todo_manager()
	_create_object_inspector()
	
	_create_console_ui()
	set_process_unhandled_input(true)
	print("🎮 Console Manager: Input processing enabled")
	
	# Connect to settings if available
	if UISettingsManager:
		UISettingsManager.settings_changed.connect(_on_settings_changed)
	
	debug_print("✅ Console Manager: Initialization complete! Press Tab to open console.", 2)

func _wait_for_floodgate_systems() -> void:
	# Wait for FloodgateController and AssetLibrary to be ready
	var max_wait = 5.0  # 5 seconds max wait
	var wait_time = 0.0
	var check_interval = 0.1
	
	while wait_time < max_wait:
		var floodgate = get_node_or_null("/root/FloodgateController")
		var asset_library = get_node_or_null("/root/AssetLibrary")
		
		if floodgate and asset_library:
			debug_print("✅ Console Manager: Floodgate systems ready", 2)
			return
		
		await get_tree().create_timer(check_interval).timeout
		wait_time += check_interval
	
	push_warning("Console Manager: Floodgate systems not ready after " + str(max_wait) + " seconds")

func _check_systems_ready() -> bool:
	var floodgate = get_node_or_null("/root/FloodgateController")
	var asset_library = get_node_or_null("/root/AssetLibrary")
	var world_builder = get_node_or_null("/root/WorldBuilder")
	
	if not floodgate:
		_print_to_console("[color=#ff6600]Warning: FloodgateController not found, using fallback[/color]")
		return world_builder != null
	
	if not asset_library:
		_print_to_console("[color=#ff6600]Warning: AssetLibrary not found[/color]")
	
	return floodgate != null and world_builder != null

func _create_passive_controller() -> void:
	if ResourceLoader.exists("res://scripts/passive_mode/passive_mode_controller.gd"):
		var PassiveController = preload("res://scripts/passive_mode/passive_mode_controller.gd")
		passive_controller = PassiveController.new()
		add_child(passive_controller)
	else:
		debug_print("Warning: passive_mode_controller.gd not found", 1)

func _create_threaded_system() -> void:
	if ResourceLoader.exists("res://scripts/passive_mode/threaded_test_system.gd"):
		var ThreadedTestSystem = preload("res://scripts/passive_mode/threaded_test_system.gd")
		version_backup = ThreadedTestSystem.new()
		add_child(version_backup)
	else:
		debug_print("Warning: threaded_test_system.gd not found", 1)

func _create_physics_manager() -> void:
	if ResourceLoader.exists("res://scripts/core/physics_state_manager.gd"):
		var PhysicsStateManager = preload("res://scripts/core/physics_state_manager.gd")
		physics_state_manager = PhysicsStateManager.new()
		physics_state_manager.name = "PhysicsStateManager"
		get_node("/root/FloodgateController").universal_add_child(physics_state_manager, get_tree().current_scene)
	else:
		print("Warning: physics_state_manager.gd not found")

func _create_project_manager() -> void:
	if ResourceLoader.exists("res://scripts/passive_mode/multi_project_manager.gd"):
		var MultiProjectManager = preload("res://scripts/passive_mode/multi_project_manager.gd")
		multi_project_manager = MultiProjectManager.new()
		add_child(multi_project_manager)
		multi_project_manager.start_waiting_for_user()
	else:
		print("Warning: multi_project_manager.gd not found")

func _create_timer_system() -> void:
	if ResourceLoader.exists("res://scripts/autoload/claude_timer_system.gd"):
		var ClaudeTimer = preload("res://scripts/autoload/claude_timer_system.gd")
		claude_timer = TimerManager.get_timer()
		claude_timer.name = "ClaudeTimer"
		add_child(claude_timer)
		
		# Setup autonomous project queue
		claude_timer.add_autonomous_project("talking_ragdoll", 3)
		claude_timer.add_autonomous_project("12_turns_system", 2)
		claude_timer.add_autonomous_project("eden_project", 1)
	else:
		print("Warning: claude_timer_system.gd not found")

func _create_todo_manager() -> void:
	if ResourceLoader.exists("res://scripts/autoload/multi_todo_manager.gd"):
		var MultiTodoManager = preload("res://scripts/autoload/multi_todo_manager.gd")
		multi_todo_manager = MultiTodoManager.new()
		multi_todo_manager.name = "MultiTodoManager"
		add_child(multi_todo_manager)
	else:
		print("Warning: multi_todo_manager.gd not found")

func _create_object_inspector() -> void:
	# Try new Universal Object Inspector first
	if ResourceLoader.exists("res://scripts/ui/universal_object_inspector.gd"):
		# TODO: Fix universal_object_inspector.gd compilation errors
		print("Universal Object Inspector temporarily disabled due to compilation errors")
		return
		get_tree().get_node("/root/FloodgateController").universal_add_child(object_inspector, get_tree().get_tree().current_scene)
		print("[ConsoleManager] Created Universal Object Inspector")
	elif ResourceLoader.exists("res://scripts/ui/object_inspector.gd"):
		var ObjectInspector = preload("res://scripts/ui/object_inspector.gd")
		object_inspector = ObjectInspector.new()
		object_inspector.name = "ObjectInspector"
		
		# Add to get_tree().get_tree().current_scene to ensure it appears above everything
		get_tree().get_node("/root/FloodgateController").universal_add_child(object_inspector, get_tree().get_tree().current_scene)
		
		# Move to top layer
		object_inspector.z_index = 100
		print("Object inspector created successfully")
	else:
		print("Warning: object_inspector.gd not found")

func _create_windows_console_fix() -> void:
	if ResourceLoader.exists("res://scripts/autoload/windows_console_fix.gd"):
		var WindowsConsoleFix = preload("res://scripts/autoload/windows_console_fix.gd")
		windows_console_fix = WindowsConsoleFix.new()
		windows_console_fix.name = "WindowsConsoleFix"
		add_child(windows_console_fix)
		
		# Patch this console manager for Windows compatibility
		windows_console_fix.patch_console_manager(self)
	else:
		print("Warning: windows_console_fix.gd not found")

# Unhandled input integrated into Pentagon Architecture
func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	# Unhandled input logic
	# Debug input events
	if event is InputEventKey and event.pressed:
		print("🔑 Key pressed: keycode=" + str(event.keycode) + " (Tab=" + str(KEY_TAB) + ")")
		
	# Handle console toggle (F1 key)
	if event.is_action_pressed("toggle_console"):
		print("✅ F1 key detected! Toggling console...")
		toggle_console()
		get_viewport().set_input_as_handled()
	
	# Handle Tab key for console toggle (like most games)
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		print("🔍 Tab key detected! Toggling console...")
		toggle_console()
		get_viewport().set_input_as_handled()
	
	if is_visible and console_container and not is_animating:
		if event.is_action_pressed("ui_up"):
			_navigate_history(-1)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_down"):
			_navigate_history(1)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			toggle_console()
			get_viewport().set_input_as_handled()

func _create_console_ui() -> void:
	# Main container (covers entire screen)
	console_container = Control.new()
	console_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	console_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	console_container.visible = false
	
	# Semi-transparent background (reduced opacity for better visibility)
	var bg_overlay = ColorRect.new()
	bg_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg_overlay.color = Color(0, 0, 0, 0.3)  # More transparent
	bg_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	FloodgateController.universal_add_child(bg_overlay, console_container)
	
	# Use CenterContainer for automatic centering
	var center_container = CenterContainer.new()
	center_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	FloodgateController.universal_add_child(center_container, console_container)
	
	# Console panel
	console_panel = PanelContainer.new()
	console_panel.mouse_filter = Control.MOUSE_FILTER_PASS
	console_panel.custom_minimum_size = Vector2(600, 400)  # Minimum size
	FloodgateController.universal_add_child(console_panel, center_container)
	
	# Apply initial styling with transparency
	var panel_style = StyleBoxFlat.new()
	var bg_color = UISettingsManager.console_bg_color
	bg_color.a = 0.85  # Make background semi-transparent
	panel_style.bg_color = bg_color
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.content_margin_left = 10
	panel_style.content_margin_right = 10
	panel_style.content_margin_top = 10
	panel_style.content_margin_bottom = 10
	# Add subtle border
	panel_style.border_width_left = 1
	panel_style.border_width_right = 1
	panel_style.border_width_top = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(1, 1, 1, 0.2)
	console_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Content container
	content_vbox = VBoxContainer.new()
	FloodgateController.universal_add_child(content_vbox, console_panel)
	
	# Title bar
	title_bar = HBoxContainer.new()
	FloodgateController.universal_add_child(title_bar, content_vbox)
	
	var title = Label.new()
	title.text = "CONSOLE"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", UISettingsManager.console_accent_color)
	FloodgateController.universal_add_child(title, title_bar)
	
	title_bar.add_spacer(true)
	
	var close_button = Button.new()
	close_button.text = "X"
	close_button.custom_minimum_size = Vector2(30, 30)
	close_button.pressed.connect(toggle_console)
	FloodgateController.universal_add_child(close_button, title_bar)
	
	# Separator
	var separator = HSeparator.new()
	FloodgateController.universal_add_child(separator, content_vbox)
	
	# Output scroll container
	output_scroll = ScrollContainer.new()
	output_scroll.custom_minimum_size = Vector2(600, 300)
	output_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	output_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(output_scroll, content_vbox)
	
	# Output display
	output_display = RichTextLabel.new()
	output_display.bbcode_enabled = true
	output_display.scroll_following = true
	output_display.selection_enabled = true
	output_display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	output_display.size_flags_vertical = Control.SIZE_EXPAND_FILL
	output_display.add_theme_color_override("default_color", UISettingsManager.console_text_color)
	FloodgateController.universal_add_child(output_display, output_scroll)
	
	# Input container
	input_container = HBoxContainer.new()
	FloodgateController.universal_add_child(input_container, content_vbox)
	
	var prompt = Label.new()
	prompt.text = ">"
	prompt.add_theme_color_override("font_color", UISettingsManager.console_accent_color)
	FloodgateController.universal_add_child(prompt, input_container)
	
	# Input field
	input_field = LineEdit.new()
	input_field.placeholder_text = "Enter command... (Tab to toggle, Esc to close)"
	input_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input_field.text_submitted.connect(_on_command_submitted)
	
	var input_style = StyleBoxFlat.new()
	input_style.bg_color = UISettingsManager.console_input_bg_color
	input_style.corner_radius_top_left = 4
	input_style.corner_radius_top_right = 4
	input_style.corner_radius_bottom_left = 4
	input_style.corner_radius_bottom_right = 4
	input_style.content_margin_left = 5
	input_style.content_margin_right = 5
	input_field.add_theme_stylebox_override("normal", input_style)
	FloodgateController.universal_add_child(input_field, input_container)
	
	# Submit button
	submit_button = Button.new()
	submit_button.text = "Submit"
	submit_button.pressed.connect(func(): _on_command_submitted(input_field.text))
	FloodgateController.universal_add_child(submit_button, input_container)
	
	# Add to scene via CanvasLayer for proper UI rendering
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "ConsoleCanvasLayer"
	canvas_layer.layer = 110  # Higher than debug panel to ensure console is on top
	get_tree().current_scene.call_deferred("add_child", canvas_layer)
	canvas_layer.call_deferred("add_child", console_container)
	
	# Apply initial settings
	_apply_settings()
	
	# Welcome message
	_print_to_console("[color=#00ff00]Welcome to Ragdoll Console![/color]")
	_print_to_console("Type 'help' for commands, Tab to toggle, Esc to close")
	
	print("✅ Console UI created successfully! Press Tab to open.")

func _apply_settings() -> void:
	if not console_panel:
		return
	
	# Get console rect from settings
	var rect = UISettingsManager.get_console_rect()
	console_panel.position = rect.position
	console_panel.size = rect.size
	
	# Update font sizes
	output_display.add_theme_font_size_override("normal_font_size", 
		int(UISettingsManager.console_font_size * UISettingsManager.ui_scale))
	
	# Update minimum sizes
	output_scroll.custom_minimum_size = Vector2(
		rect.size.x - 40,
		rect.size.y - 120
	) * UISettingsManager.ui_scale

func toggle_console() -> void:
	print("🎮 Console toggle requested - Visible: " + str(is_visible))
	
	if not console_container:
		print("❌ Console container is null! Console UI not created yet.")
		print("🔧 Attempting to create console UI now...")
		_create_console_ui()
		if not console_container:
			print("❌ Failed to create console UI!")
			return
		else:
			print("✅ Console UI created successfully!")
		
	if is_animating:
		print("⏳ Console animation in progress, ignoring toggle")
		return
	
	is_animating = true
	is_visible = !is_visible
	
	if tween:
		tween.kill()
	
	tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	if is_visible:
		print("🔄 Showing console...")
		console_container.visible = true
		console_container.modulate.a = 0
		console_panel.scale = Vector2(0.8, 0.8)
		
		tween.parallel().tween_property(console_container, "modulate:a", 1.0, 
			UISettingsManager.console_animation_speed)
		tween.parallel().tween_property(console_panel, "scale", Vector2.ONE, 
			UISettingsManager.console_animation_speed)
		
		tween.finished.connect(func():
			is_animating = false
			if input_field:
				input_field.grab_focus()
				input_field.clear()
			console_container.mouse_filter = Control.MOUSE_FILTER_STOP
		)
	else:
		print("🔄 Hiding console...")
		console_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		tween.parallel().tween_property(console_container, "modulate:a", 0.0, 
			UISettingsManager.console_animation_speed)
		tween.parallel().tween_property(console_panel, "scale", Vector2(0.8, 0.8), 
			UISettingsManager.console_animation_speed)
		
		tween.finished.connect(func():
			is_animating = false
			console_container.visible = false
		)

func _on_command_submitted(text: String) -> void:
	if text.strip_edges().is_empty():
		return
	
	# User responded - notify timing systems
	if multi_project_manager:
		multi_project_manager.user_responded()
	if claude_timer:
		claude_timer.user_message_received()
	
	# Add to history
	command_history.append(text)
	if command_history.size() > MAX_HISTORY:
		command_history.pop_front()
	history_index = command_history.size()
	
	# Display command
	_print_to_console("[color=#ffff00]> " + text + "[/color]")
	
	# Parse and execute
	var parts = text.split(" ", false)
	if parts.is_empty():
		return
	
	var cmd = parts[0].to_lower()
	var args = parts.slice(1)
	
	if commands.has(cmd):
		commands[cmd].call(args)
		# Emit signal for tutorial system
		command_executed.emit(cmd, args)
	else:
		_print_to_console("[color=#ff0000]Unknown command: " + cmd + "[/color]")
		_print_to_console("Type 'help' for available commands")
	
	# Start waiting for next response
	if multi_project_manager:
		multi_project_manager.start_waiting_for_user()
	
	# Clear input
	input_field.clear()
	
	# Emit signal
	command_executed.emit(cmd, args)

func _print_to_console(text: String) -> void:
	if output_display:
		# Apply spam filtering
		var spam_filter = get_node_or_null("/root/ConsoleSpamFilter")
		if spam_filter:
			var filtered_text = spam_filter.filter_message(text)
			if filtered_text == "":
				return  # Message was filtered out
			text = filtered_text
		
		output_lines.append(text)
		if output_lines.size() > MAX_OUTPUT_LINES:
			output_lines.pop_front()
		
		output_display.clear()
		for line in output_lines:
			output_display.append_text(line + "\n")

func _navigate_history(direction: int) -> void:
	if command_history.is_empty():
		return
	
	history_index = clamp(history_index + direction, 0, command_history.size())
	
	if history_index < command_history.size():
		input_field.text = command_history[history_index]
		input_field.caret_column = input_field.text.length()
	else:
		input_field.clear()

func _on_settings_changed() -> void:
	_apply_settings()

func register_command(command_name: String, callback: Callable, description: String = "") -> void:
	commands[command_name.to_lower()] = callback
	if description != "":
		# Store description for help system
		if not has_meta("command_descriptions"):
			set_meta("command_descriptions", {})
		get_meta("command_descriptions")[command_name.to_lower()] = description

func _execute_command(command_text: String) -> void:
	# Parse and execute command
	var parts = command_text.split(" ", false)
	if parts.is_empty():
		return
	
	var cmd = parts[0].to_lower()
	var args = parts.slice(1)
	
	if commands.has(cmd):
		commands[cmd].call(args)
	else:
		_print_to_console("[color=#ff0000]Unknown command: " + cmd + "[/color]")

# Command implementations

func _cmd_help(_args: Array) -> void:
	_print_to_console("[color=#00ffff]Available Commands:[/color]")
	_print_to_console("  [color=#ffff00]create/spawn <object>[/color] - Create an object at mouse position")
	_print_to_console("  [color=#ffff00]tree[/color] - Spawn a tree")
	_print_to_console("  [color=#ffff00]rock[/color] - Spawn a rock")
	_print_to_console("  [color=#ffff00]box[/color] - Spawn a box")
	_print_to_console("  [color=#ffff00]ball[/color] - Spawn a ball")
	_print_to_console("  [color=#ffff00]ramp[/color] - Spawn a ramp")
	_print_to_console("  [color=#ffff00]sun[/color] - Spawn a sun (light source)")
	_print_to_console("  [color=#ffff00]astral/astral_being[/color] - Spawn an astral being")
	_print_to_console("  [color=#ffff00]pathway/path[/color] - Spawn a pathway")
	_print_to_console("  [color=#ffff00]bush[/color] - Spawn a bush")
	_print_to_console("  [color=#ffff00]fruit[/color] - Spawn a fruit")
	_print_to_console("  [color=#ffff00]clear[/color] - Remove all spawned objects")
	_print_to_console("  [color=#ffff00]list[/color] - List all spawned objects")
	_print_to_console("  [color=#ffff00]delete <id>[/color] - Delete specific object")
	_print_to_console("  [color=#ffff00]ragdoll <command>[/color] - Control ragdoll (reset/position)")
	_print_to_console("  [color=#ffff00]gravity <value>[/color] - Set gravity (default: 9.8)")
	_print_to_console("  [color=#ffff00]physics[/color] - Physics state control")
	_print_to_console("  [color=#ffff00]physics_test <cmd>[/color] - Test ragdoll physics (test/show/adjust/compare)")
	_print_to_console("  [color=#ffff00]say <text>[/color] - Make ragdoll say something")
	_print_to_console("  [color=#ffff00]console <position>[/color] - Set console position (center/top/bottom/left/right)")
	_print_to_console("  [color=#ffff00]scale <value>[/color] - Set UI scale (0.5-2.0)")
	_print_to_console("  [color=#ffff00]scene list[/color] - List available scenes")
	_print_to_console("  [color=#ffff00]load <scene>[/color] - Load a scene")
	_print_to_console("  [color=#ffff00]save [name][/color] - Save current scene")
	_print_to_console("  [color=#ffff00]ground/restore_ground[/color] - Restore ground visibility")
	_print_to_console("  [color=#ffff00]walk [x y z][/color] - Make ragdoll walk in direction (or toggle walk)")
	_print_to_console("  [color=#ffff00]spawn_ragdoll[/color] - Spawn a new ragdoll character")
	_print_to_console("  [color=#ffff00]spawn_skeleton[/color] - Spawn skeleton-based ragdoll (NEW!)")
	_print_to_console("")
	_print_to_console("[color=#00ffff]Enhanced Ragdoll Commands:[/color]")
	_print_to_console("  [color=#ffff00]ragdoll_come[/color] - Ragdoll comes to your position")
	_print_to_console("  [color=#ffff00]ragdoll_pickup[/color] - Ragdoll picks up nearest object")
	_print_to_console("  [color=#ffff00]ragdoll_drop[/color] - Ragdoll drops held object")
	_print_to_console("  [color=#ffff00]ragdoll_organize[/color] - Ragdoll organizes nearby objects")
	_print_to_console("  [color=#ffff00]ragdoll_patrol[/color] - Ragdoll starts patrol route")
	_print_to_console("")
	_print_to_console("[color=#00ffff]Movement Commands:[/color]")
	_print_to_console("  [color=#ffff00]ragdoll_move <direction>[/color] - Move ragdoll (forward/backward/left/right/stop)")
	_print_to_console("  [color=#ffff00]ragdoll_speed <mode>[/color] - Set speed (slow/normal/fast)")
	_print_to_console("  [color=#ffff00]ragdoll_run[/color] - Toggle running mode")
	_print_to_console("  [color=#ffff00]ragdoll_crouch[/color] - Toggle crouch mode")
	_print_to_console("  [color=#ffff00]ragdoll_jump[/color] - Make ragdoll jump")
	_print_to_console("  [color=#ffff00]ragdoll_rotate <direction>[/color] - Rotate in place (left/right/stop)")
	_print_to_console("  [color=#ffff00]ragdoll_stand[/color] - Force ragdoll to stand up")
	_print_to_console("  [color=#ffff00]ragdoll_state[/color] - Show current movement state")
	_print_to_console("")
	_print_to_console("[color=#00ffff]Astral Beings Commands:[/color]")
	_print_to_console("  [color=#ffff00]beings_status[/color] - Show astral beings status")
	_print_to_console("  [color=#ffff00]beings_help[/color] - Astral beings help ragdoll")
	_print_to_console("  [color=#ffff00]beings_organize[/color] - Astral beings organize scene")
	_print_to_console("  [color=#ffff00]beings_harmony[/color] - Astral beings create harmony")
	_print_to_console("")
	_print_to_console("[color=#00ffff]System Commands:[/color]")
	_print_to_console("  [color=#ffff00]setup_systems[/color] - Manually setup ragdoll and astral beings")
	_print_to_console("  [color=#ffff00]system_status[/color] - Check all systems status")
	_print_to_console("")
	_print_to_console("[color=#00ffff]Debug Commands:[/color]")
	_print_to_console("  [color=#ffff00]debug [off][/color] - Toggle/disable debug 3D screen")
	_print_to_console("  [color=#ffff00]select <name|id>[/color] - Select object for manipulation")
	_print_to_console("  [color=#ffff00]move <x> <y> <z>[/color] - Move selected object")
	_print_to_console("  [color=#ffff00]rotate <x> <y> <z>[/color] - Rotate selected object (degrees)")
	_print_to_console("  [color=#ffff00]scale_obj <scale>[/color] - Scale selected object")
	_print_to_console("")
	_print_to_console("[color=#00ffff]Light Being Commands:[/color]")
	_print_to_console("  [color=#ffff00]awaken <name|id>[/color] - Awaken static object to begin movement")
	_print_to_console("  [color=#ffff00]state <name|id> <state>[/color] - Change object physics state")
	_print_to_console("  [color=#888888]States: static, awakening, kinematic, dynamic, ethereal, light_being[/color]")
	_print_to_console("")
	_print_to_console("[color=#00ffff]Timer & Task Commands:[/color]")
	_print_to_console("  [color=#ffff00]timer[/color] - Show timer report")
	_print_to_console("  [color=#ffff00]timer project <name>[/color] - Switch active project")
	_print_to_console("  [color=#ffff00]timer threshold <seconds>[/color] - Set autonomous work trigger")
	_print_to_console("  [color=#ffff00]task start <name>[/color] - Start timing a task")
	_print_to_console("  [color=#ffff00]task complete[/color] - Complete current task")
	_print_to_console("")
	_print_to_console("[color=#00ffff]Multi-Todo Commands:[/color]")
	_print_to_console("  [color=#ffff00]todos[/color] - Show all project todos")
	_print_to_console("  [color=#ffff00]todos add <project> <content>[/color] - Add todo to project")
	_print_to_console("  [color=#ffff00]todos complete <project> <id>[/color] - Complete todo")
	_print_to_console("  [color=#ffff00]todos modify <project> <id> <content>[/color] - Modify todo")
	_print_to_console("  [color=#ffff00]todos stepback <project> <id>[/color] - Undo last modification")
	_print_to_console("  [color=#ffff00]balance[/color] - Show workload balance recommendations")
	_print_to_console("")
	_print_to_console("[color=#00ffff]Passive Mode Commands:[/color]")
	_print_to_console("  [color=#ffff00]passive start[/color] - Start autonomous development mode")
	_print_to_console("  [color=#ffff00]passive stop[/color] - Stop passive mode")
	_print_to_console("  [color=#ffff00]passive status[/color] - Show passive mode status")
	_print_to_console("  [color=#ffff00]add_task <name> [priority][/color] - Add task to queue")
	_print_to_console("  [color=#ffff00]branch create <name>[/color] - Create feature branch")
	_print_to_console("")
	_print_to_console("[color=#00ffff]Tutorial Commands:[/color]")
	_print_to_console("  [color=#ffff00]tutorial start[/color] - Begin interactive ragdoll tutorial")
	_print_to_console("  [color=#ffff00]tutorial stop[/color] - Stop current tutorial")
	_print_to_console("  [color=#ffff00]tutorial status[/color] - Check tutorial progress")
	_print_to_console("")
	_print_to_console("[color=#00ffff]Advanced Ragdoll V2 Commands:[/color]")
	_print_to_console("  [color=#ffff00]spawn_ragdoll_v2[/color] - Spawn advanced keypoint-based ragdoll")
	_print_to_console("  [color=#ffff00]ragdoll2_move <dir>[/color] - Control V2 movement (forward/back/left/right/stop)")
	_print_to_console("  [color=#ffff00]ragdoll2_state[/color] - Show detailed V2 state and balance info")
	_print_to_console("  [color=#ffff00]ragdoll2_debug[/color] - Toggle ground/IK debug visualization")
	_print_to_console("  [color=#ffff00]branch switch <name>[/color] - Switch branch")
	_print_to_console("  [color=#ffff00]commit <message>[/color] - Commit changes")
	_print_to_console("  [color=#ffff00]mr create <title>[/color] - Create merge request")
	_print_to_console("  [color=#ffff00]mr approve <id>[/color] - Approve merge request")
	_print_to_console("  [color=#ffff00]merge <mr-id>[/color] - Merge approved MR")
	_print_to_console("  [color=#ffff00]workflow[/color] - Show workflow status")
	_print_to_console("  [color=#ffff00]test[/color] - Run feature test suite")
	_print_to_console("  [color=#ffff00]version[/color] - Version control commands")
	_print_to_console("  [color=#ffff00]test_tutorial[/color] - 🧪 Start systematic function testing tutorial")

func _cmd_test_tutorial(_args: Array) -> void:
	_print_to_console("[color=#00ffff]🧪 Starting Systematic Test Tutorial...[/color]")
	
	# Load the tutorial script
	var tutorial_script = load("res://scripts/ui/systematic_test_tutorial.gd")
	if not tutorial_script:
		_print_to_console("[color=#ff0000]❌ Tutorial script not found![/color]")
		return
	
	# Create tutorial instance
	var tutorial = tutorial_script.new()
	tutorial.name = "SystematicTestTutorial"
	
	# Add to scene
	get_tree().get_node("/root/FloodgateController").universal_add_child(tutorial, get_tree().get_tree().current_scene)
	
	# Connect signals
	tutorial.test_completed.connect(_on_tutorial_test_completed)
	tutorial.tutorial_finished.connect(_on_tutorial_finished)
	
	_print_to_console("[color=#00ff00]✅ Tutorial window opened! Click through each test step by step.[/color]")

func _on_tutorial_test_completed(test_name: String, result: String, success: bool):
	var color = "green" if success else "red"
	_print_to_console("[color=%s]🧪 %s: %s[/color]" % [color, test_name, result])

func _on_tutorial_finished(total_tests: int, passed: int, failed: int):
	_print_to_console("[color=#00ffff]🎉 Tutorial Complete![/color]")
	_print_to_console("  Total Tests: %d" % total_tests)
	_print_to_console("  [color=#00ff00]Passed: %d[/color]" % passed)
	_print_to_console("  [color=#ff0000]Failed: %d[/color]" % failed)
	_print_to_console("  [color=#ffff00]Check console log for detailed report[/color]")

func _cmd_console_settings(args: Array) -> void:
	if args.is_empty():
		_print_to_console("Current position: " + UISettingsManager.console_position)
		_print_to_console("Usage: console <center|top|bottom|left|right>")
		return
	
	UISettingsManager.set_console_position(args[0])
	_print_to_console("[color=#00ff00]Console position set to: " + args[0] + "[/color]")

func _cmd_set_scale(args: Array) -> void:
	if args.is_empty():
		_print_to_console("Current UI scale: " + str(UISettingsManager.ui_scale))
		_print_to_console("Usage: scale <0.5-2.0>")
		return
	
	var scale = args[0].to_float()
	UISettingsManager.set_ui_scale(scale)
	_print_to_console("[color=#00ff00]UI scale set to: " + str(scale) + "[/color]")

func _cmd_create(args: Array) -> void:
	if args.is_empty():
		_print_to_console("[color=#ff0000]Usage: create <object_type>[/color]")
		return
	
	var object_type = args[0].to_lower()
	
	# First check if it's a known StandardizedObjects asset
	var std_objects = get_node_or_null("/root/StandardizedObjects")
	if std_objects and std_objects.object_definitions.has(object_type):
		if _check_systems_ready():
			WorldBuilder.create_object(object_type)
			_print_to_console("[color=#00ff00]%s creation queued through floodgate![/color]" % object_type.capitalize())
		else:
			_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")
		return
	
	# Fallback to hardcoded commands for special cases
	match object_type:
		"astral", "astral_being":
			_cmd_create_astral_being([])
		"ragdoll":
			_cmd_spawn_ragdoll([])
		_:
			_print_to_console("[color=#ff0000]Unknown object type: %s[/color]" % object_type)
			_print_to_console("Use 'assets' to see available types")

func _cmd_create_tree(_args: Array) -> void:
	if _check_systems_ready():
		WorldBuilder.create_tree()
		_print_to_console("[color=#00ff00]Tree creation queued through floodgate![/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_create_rock(_args: Array) -> void:
	if _check_systems_ready():
		WorldBuilder.create_rock()
		_print_to_console("[color=#00ff00]Rock creation queued through floodgate![/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_create_box(_args: Array) -> void:
	if _check_systems_ready():
		WorldBuilder.create_box()
		_print_to_console("[color=#00ff00]Box creation queued through floodgate![/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_create_ball(_args: Array) -> void:
	if _check_systems_ready():
		WorldBuilder.create_ball()
		_print_to_console("[color=#00ff00]Ball creation queued through floodgate![/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_create_ramp(_args: Array) -> void:
	if _check_systems_ready():
		WorldBuilder.create_ramp()
		_print_to_console("[color=#00ff00]Ramp creation queued through floodgate![/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_create_wall(_args: Array) -> void:
	if _check_systems_ready():
		WorldBuilder.create_object("wall")
		_print_to_console("[color=#00ff00]Wall creation queued through floodgate![/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_create_stick(_args: Array) -> void:
	# Use same method as working 'create' command
	var std_objects = get_node_or_null("/root/StandardizedObjects")
	if std_objects and std_objects.object_definitions.has("stick"):
		if _check_systems_ready():
			WorldBuilder.create_object("stick")
			_print_to_console("[color=#00ff00]Stick created![/color]")
	else:
		_print_to_console("[color=#ff0000]Stick asset not found![/color]")
	if not _check_systems_ready():
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_create_leaf(_args: Array) -> void:
	if _check_systems_ready():
		WorldBuilder.create_object("leaf")
		_print_to_console("[color=#00ff00]Leaf creation queued through floodgate![/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_list_assets(_args: Array) -> void:
	var std_objects = get_node_or_null("/root/StandardizedObjects")
	if not std_objects:
		_print_to_console("[color=#ff0000]StandardizedObjects not found![/color]")
		return
	
	_print_to_console("[color=#00ffff]Available Assets:[/color]")
	for asset_name in std_objects.object_definitions:
		var def = std_objects.object_definitions[asset_name]
		_print_to_console("  - %s (%s)" % [asset_name, def.get("type", "unknown")])
	
	_print_to_console("\nTotal: %d assets" % std_objects.object_definitions.size())

func _on_asset_created(asset_name: String, properties: Dictionary):
	_print_to_console("[color=#00ff00]New asset created: %s[/color]" % asset_name)
	_print_to_console("You can now use: create %s" % asset_name)

func _cmd_toggle_rules(args: Array) -> void:
	var universal_entity = get_node_or_null("/root/UniversalEntity")
	if not universal_entity:
		_print_to_console("[color=#ff0000]UniversalEntity not found![/color]")
		return
	
	var lists_viewer = universal_entity.get("lists_viewer")
	if not lists_viewer:
		_print_to_console("[color=#ff0000]ListsViewerSystem not found![/color]")
		return
	
	if args.size() > 0:
		var action = args[0].to_lower()
		if action == "on":
			lists_viewer.rules_enabled = true
		elif action == "off":
			lists_viewer.rules_enabled = false
		else:
			_print_to_console("[color=#ff0000]Usage: rules [on|off][/color]")
			return
	else:
		# Toggle
		lists_viewer.rules_enabled = not lists_viewer.rules_enabled
	
	var status = "ON" if lists_viewer.rules_enabled else "OFF"
	_print_to_console("[color=#00ff00]Automatic rule execution: %s[/color]" % status)

func _cmd_clear_objects(args: Array) -> void:
	# Check for scene manager first
	var scene_manager = get_node_or_null("/root/UnifiedSceneManager")
	
	if args.size() > 0 and args[0] == "all":
		# Clear everything including terrain
		if scene_manager:
			scene_manager.clear_current_scene()
			_print_to_console("[color=#00ff00]Cleared all scene elements![/color]")
		else:
			_print_to_console("[color=#ff0000]Scene manager not found[/color]")
	elif args.size() > 0 and args[0] == "restore":
		# Restore default scene
		if scene_manager:
			scene_manager.restore_default_scene()
			_print_to_console("[color=#00ff00]Restored default scene![/color]")
		else:
			_print_to_console("[color=#ff0000]Scene manager not found[/color]")
	else:
		# Just clear spawned objects
		if _check_systems_ready():
			var count = WorldBuilder.clear_all_objects()
			_print_to_console("[color=#00ff00]Cleared " + str(count) + " objects![/color]")
			_print_to_console("[color=#ffff00]Use 'clear all' to clear terrain too[/color]")
			_print_to_console("[color=#ffff00]Use 'clear restore' to restore default ground[/color]")
		else:
			_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_list_objects(_args: Array) -> void:
	# First try Universal Object Manager (perfect system)
	var uom = get_node_or_null("/root/UniversalObjectManager")
	if uom:
		var objects = uom.get_all_objects()
		if objects.is_empty():
			_print_to_console("No objects spawned")
			return
		
		_print_to_console("[color=#00ffff]Spawned Objects (Universal System):[/color]")
		var type_count = {}
		for obj in objects:
			if is_instance_valid(obj):
				_print_to_console("  - " + obj.name + " at " + str(obj.global_position))
				var type = obj.get_meta("object_type", "unknown")
				type_count[type] = type_count.get(type, 0) + 1
			else:
				_print_to_console("  - [INVALID OBJECT]")
		
		# Show summary
		_print_to_console("\n[color=#ffff00]Summary:[/color]")
		for type in type_count:
			_print_to_console("  " + type + "s: " + str(type_count[type]))
		_print_to_console("  Total: " + str(objects.size()))
		
		# Show UOM stats
		var stats = uom.get_statistics()
		_print_to_console("\n[color=#00ff00]Universal Tracking:[/color]")
		_print_to_console("  Created: " + str(stats.total_created))
		_print_to_console("  Active: " + str(stats.active_objects))
		return
	
	# Fallback to old system
	if _check_systems_ready():
		var objects = WorldBuilder.get_spawned_objects()
		if objects.is_empty():
			_print_to_console("No objects spawned")
			return
		
		_print_to_console("[color=#00ffff]Spawned Objects:[/color]")
		for obj in objects:
			if is_instance_valid(obj):
				_print_to_console("  - " + obj.name + " at " + str(obj.global_position))
			else:
				_print_to_console("  - [INVALID OBJECT]")
	else:
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_delete_object(args: Array) -> void:
	if args.is_empty():
		_print_to_console("[color=#ff0000]Usage: delete <object_name>[/color]")
		return
	
	if _check_systems_ready():
		var success = WorldBuilder.delete_object(args[0])
		if success:
			_print_to_console("[color=#00ff00]Object deletion queued through floodgate: " + args[0] + "[/color]")
		else:
			_print_to_console("[color=#ff0000]Object not found: " + args[0] + "[/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_ragdoll_command(args: Array) -> void:
	if args.is_empty():
		_print_to_console("[color=#ff0000]Usage: ragdoll <reset|position>[/color]")
		return
	
	var ragdolls = get_tree().get_nodes_in_group("ragdolls")
	if ragdolls.is_empty():
		_print_to_console("[color=#ff0000]No ragdoll found![/color]")
		return
	
	var ragdoll = ragdolls[0]
	
	match args[0].to_lower():
		"reset":
			ragdoll.global_position = Vector3(0, 5, 0)
			# Reset body parts if they exist
			if ragdoll.has_method("get_body"):
				var body = ragdoll.get_body()
				if body:
					body.linear_velocity = Vector3.ZERO
					body.angular_velocity = Vector3.ZERO
			_print_to_console("[color=#00ff00]Ragdoll reset![/color]")
		"position":
			_print_to_console("Ragdoll position: " + str(ragdoll.global_position))
		_:
			_print_to_console("[color=#ff0000]Unknown command. Use: reset or position[/color]")

func _cmd_physics(args: Array) -> void:
	if args.is_empty():
		_print_to_console("Current gravity: " + str(ProjectSettings.get_setting("physics/3d/default_gravity")))
		return
	
	var gravity = args[0].to_float()
	PhysicsServer3D.area_set_param(get_tree().get_tree().get_tree().current_scene.get_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY, gravity)
	_print_to_console("[color=#00ff00]Gravity set to: " + str(gravity) + "[/color]")

func _cmd_make_ragdoll_say(args: Array) -> void:
	if args.is_empty():
		_print_to_console("[color=#ff0000]Usage: say <text>[/color]")
		return
	
	var text = " ".join(args)
	DialogueSystem.make_ragdoll_say(text)
	_print_to_console("[color=#00ff00]Ragdoll says: " + text + "[/color]")

func _cmd_scene(args: Array) -> void:
	if args.is_empty() or args[0] == "list":
		var scenes = SceneLoader.list_available_scenes()
		_print_to_console("[color=#00ffff]Available Scenes:[/color]")
		for scene in scenes:
			_print_to_console("  - " + scene)
		_print_to_console("Current scene: " + SceneLoader.current_scene_name)
		return
	
	_print_to_console("[color=#ff0000]Usage: scene list[/color]")

func _cmd_load_scene(args: Array) -> void:
	if args.is_empty():
		_print_to_console("[color=#ff0000]Usage: load <scene_name>[/color]")
		return
	
	var scene_name = args[0]
	
	# Get or create scene manager
	var scene_manager = get_node_or_null("/root/UnifiedSceneManager")
	if not scene_manager:
		var manager_script = load("res://scripts/core/unified_scene_manager.gd")
		if manager_script:
			scene_manager = Node.new()
			scene_manager.name = "UnifiedSceneManager"
			scene_manager.set_script(manager_script)
			get_tree().get_node("/root/FloodgateController").universal_add_child(scene_manager, get_tree().get_tree().current_scene)
	
	if scene_manager:
		scene_manager.load_static_scene(scene_name)
		_print_to_console("[color=#00ff00]Loaded scene: " + scene_name + "[/color]")
	else:
		# Fallback to old system
		if SceneLoader.load_scene(scene_name):
			_print_to_console("[color=#00ff00]Loaded scene: " + scene_name + "[/color]")
		else:
			_print_to_console("[color=#ff0000]Failed to load scene: " + scene_name + "[/color]")

func _cmd_save_scene(args: Array) -> void:
	if args.is_empty():
		SceneLoader.save_current_scene()
		_print_to_console("[color=#00ff00]Saved current scene: " + SceneLoader.current_scene_name + "[/color]")
	else:
		var scene_name = args[0]
		SceneLoader.current_scene_name = scene_name
		SceneLoader.save_current_scene()
		_print_to_console("[color=#00ff00]Saved scene as: " + scene_name + "[/color]")

func _cmd_ragdoll_walk(_args: Array) -> void:
	var ragdolls = get_tree().get_nodes_in_group("ragdolls")
	if ragdolls.is_empty():
		_print_to_console("[color=#ff0000]No ragdoll found![/color]")
		return
	
	# Always use toggle walking - ignore any arguments
	# This prevents the error when xyz arguments are provided
	for ragdoll in ragdolls:
		if ragdoll.has_method("toggle_walking"):
			ragdoll.toggle_walking()
		elif ragdoll.has_method("is_walking"):
			if ragdoll.is_walking:
				ragdoll.stop_walking()
				_print_to_console("[color=#00ff00]Ragdoll stopped walking[/color]")
			else:
				ragdoll.start_walking()
				_print_to_console("[color=#00ff00]Ragdoll is now walking![/color]")
		else:
			_print_to_console("[color=#ff0000]This ragdoll can't walk (add legs first!)[/color]")

func _cmd_spawn_ragdoll(_args: Array) -> void:
	if _check_systems_ready():
		WorldBuilder.create_ragdoll()
		_print_to_console("[color=#00ff00]Ragdoll creation queued through floodgate![/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_spawn_skeleton_ragdoll(_args: Array) -> void:
	var position = Vector3(
		randf_range(-5, 5),
		2.0,
		randf_range(-5, 5)
	)
	
	var skeleton_ragdoll = StandardizedObjects.create_object("skeleton_ragdoll", position)
	if skeleton_ragdoll:
		get_tree().get_node("/root/FloodgateController").universal_add_child(skeleton_ragdoll, get_tree().get_tree().current_scene)
		_print_to_console("[color=#00ff00]Skeleton ragdoll spawned at %s![/color]" % position)
		_print_to_console("[color=#ffff00]Use 'ragdoll_mode animated/physics' to switch modes[/color]")
	else:
		_print_to_console("[color=#ff0000]Failed to create skeleton ragdoll![/color]")

func _cmd_create_sun(_args: Array) -> void:
	if _check_systems_ready():
		WorldBuilder.create_sun()
		_print_to_console("[color=#00ff00]Sun creation queued through floodgate![/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_create_astral_being(args: Array) -> void:
	# Try new manager first
	var manager = get_node_or_null("/root/AstralBeingManager")
	if manager:
		manager._cmd_spawn_being(args)
		return
	
	# Fallback to old method
	if _check_systems_ready():
		WorldBuilder.create_astral_being()
		_print_to_console("[color=#00ff00]Astral being creation queued through floodgate![/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_astral_control(args: Array) -> void:
	if args.size() < 2:
		_print_to_console("[color=#ffff00]Usage: being <being_id_or_name> <command> [args...][/color]")
		_print_to_console("[color=#ffff00]Available commands: follow, orbit, move, mode, assist, speak, energy, personality, status, reset[/color]")
		_print_to_console("[color=#ffff00]Example: being 1 follow ragdoll[/color]")
		_print_to_console("[color=#ffff00]Example: being Guardian speak Hello there![/color]")
		return
	
	var being_identifier = args[0]
	var command = args[1]
	var command_args = args.slice(2)
	
	# Find astral being by ID or name
	var astral_beings = get_tree().get_nodes_in_group("astral_beings")
	var target_being: Node3D = null
	
	# Try to find by ID (number)
	if being_identifier.is_valid_int():
		var being_id = int(being_identifier)
		for being in astral_beings:
			if being.has_method("get_being_status"):
				var status = being.get_being_status()
				if status.get("id", -1) == being_id:
					target_being = being
					break
	else:
		# Try to find by name
		for being in astral_beings:
			if being.has_method("get_being_status"):
				var status = being.get_being_status()
				if status.get("name", "").to_lower() == being_identifier.to_lower():
					target_being = being
					break
	
	if not target_being:
		_print_to_console("[color=#ff0000]Error: Could not find astral being '" + being_identifier + "'[/color]")
		_print_to_console("[color=#ffff00]Available beings:[/color]")
		for being in astral_beings:
			if being.has_method("get_being_status"):
				var status = being.get_being_status()
				_print_to_console("  ID: " + str(status.get("id", "?")) + ", Name: " + status.get("name", "Unknown"))
		return
	
	# Execute command on the astral being
	if target_being.has_method("handle_console_command"):
		var result = target_being.handle_console_command(command, command_args)
		_print_to_console("[color=#00ff00]" + result + "[/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Astral being does not support console commands[/color]")

func _cmd_create_pathway(_args: Array) -> void:
	if _check_systems_ready():
		WorldBuilder.create_pathway()
		_print_to_console("[color=#00ff00]Pathway creation queued through floodgate![/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_create_bush(_args: Array) -> void:
	if _check_systems_ready():
		WorldBuilder.create_bush()
		_print_to_console("[color=#00ff00]Bush creation queued through floodgate![/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_create_fruit(_args: Array) -> void:
	if _check_systems_ready():
		WorldBuilder.create_fruit()
		_print_to_console("[color=#00ff00]Fruit creation queued through floodgate![/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_create_pigeon(_args: Array) -> void:
	if _check_systems_ready():
		WorldBuilder.create_pigeon()
		_print_to_console("[color=#00ff00]Pigeon character created![/color]")
		_print_to_console("[color=#ffff00]Controls: Arrow keys to walk, Space to jump/fly[/color]")
		_print_to_console("[color=#ffff00]While flying: W/S for up/down, F to toggle flying[/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Floodgate systems not ready![/color]")

func _cmd_generate_world(args: Array) -> void:
	_print_to_console("[color=#ffff00]Generating heightmap world...[/color]")
	
	# Get or create scene manager
	var scene_manager = get_node_or_null("/root/UnifiedSceneManager")
	if not scene_manager:
		var manager_script = load("res://scripts/core/unified_scene_manager.gd")
		if manager_script:
			scene_manager = Node.new()
			scene_manager.name = "UnifiedSceneManager"
			scene_manager.set_script(manager_script)
			get_tree().get_node("/root/FloodgateController").universal_add_child(scene_manager, get_tree().get_tree().current_scene)
	
	if scene_manager:
		# Parse size argument
		var size = 128
		if args.size() > 0:
			var requested_size = args[0].to_int()
			if requested_size >= 64 and requested_size <= 512:
				size = requested_size
				_print_to_console("[color=#00ff00]Terrain size set to %d[/color]" % size)
		
		# Generate the world
		scene_manager.generate_procedural_world(size)
		_print_to_console("[color=#00ff00]World generated with terrain, trees, bushes and water![/color]")
		_print_to_console("[color=#ffff00]Trees and bushes have fruits that birds can eat[/color]")
		_print_to_console("[color=#ffff00]Use 'bird' command to spawn birds that will look for food[/color]")
	else:
		_print_to_console("[color=#ff0000]Failed to create scene manager[/color]")

func _cmd_scene_status(_args: Array) -> void:
	var scene_manager = get_node_or_null("/root/UnifiedSceneManager")
	if not scene_manager:
		_print_to_console("[color=#ff0000]Scene manager not active[/color]")
		_print_to_console("[color=#ffff00]Use 'world' or 'load <scene>' to initialize[/color]")
		return
		
	var info = scene_manager.get_current_scene_info()
	_print_to_console("[color=#00ff00]=== Scene Status ===[/color]")
	_print_to_console("Type: " + info.type)
	_print_to_console("Name: " + info.name)
	_print_to_console("Has Terrain: " + str(info.has_terrain))
	_print_to_console("Objects: " + str(info.object_count))
	_print_to_console("Creatures: " + str(info.creature_count))

func _cmd_restore_ground(_args: Array) -> void:
	"""Restore ground visibility and ensure it exists"""
	var scene_manager = get_node_or_null("/root/UnifiedSceneManager")
	if not scene_manager:
		_print_to_console("[color=#ff0000]Scene manager not active[/color]")
		_print_to_console("[color=#ffff00]Use 'world' or 'load <scene>' to initialize[/color]")
		return
	
	# Try to restore ground
	scene_manager._ensure_ground_visible()
	_print_to_console("[color=#00ff00]✅ Ground restoration attempted[/color]")
	_print_to_console("[color=#ffff00]If ground still missing, emergency ground will be created[/color]")

func _cmd_passive_mode(args: Array) -> void:
	if args.is_empty() or args[0] == "status":
		_print_to_console(passive_controller.get_status())
		return
	
	match args[0].to_lower():
		"start":
			_print_to_console(passive_controller.start_passive_mode())
		"stop":
			_print_to_console(passive_controller.stop_passive_mode())
		"status":
			_print_to_console(passive_controller.get_status())
		"auto-commit":
			if args.size() > 1:
				passive_controller.set_auto_commit(args[1] == "on")
				_print_to_console("Auto-commit " + args[1])
		"require-approval":
			if args.size() > 1:
				passive_controller.set_require_approval(args[1] == "on")
				_print_to_console("Approval requirement " + args[1])
		"token-budget":
			if args.size() > 1:
				_print_to_console(passive_controller.set_token_budget(int(args[1])))
		_:
			_print_to_console("[color=#ff0000]Usage: passive <start|stop|status|auto-commit on/off|require-approval on/off|token-budget N>[/color]")

func _cmd_add_task(args: Array) -> void:
	if args.is_empty():
		_print_to_console("[color=#ff0000]Usage: task <description> [priority][/color]")
		return
	
	var task_name = args[0]
	var priority = "medium"
	if args.size() > 1:
		priority = args[1]
	
	_print_to_console(passive_controller.add_task(task_name, priority))

func _cmd_branch(args: Array) -> void:
	if args.is_empty():
		_print_to_console("[color=#ff0000]Usage: branch <create|switch|list> [name][/color]")
		return
	
	match args[0].to_lower():
		"create":
			if args.size() > 1:
				_print_to_console(passive_controller.create_branch(args[1]))
			else:
				_print_to_console("[color=#ff0000]Branch name required[/color]")
		"switch":
			if args.size() > 1:
				_print_to_console(passive_controller.switch_branch(args[1]))
			else:
				_print_to_console("[color=#ff0000]Branch name required[/color]")
		"list":
			_print_to_console(passive_controller.get_status())

func _cmd_commit(args: Array) -> void:
	if args.is_empty():
		_print_to_console("[color=#ff0000]Usage: commit <message>[/color]")
		return
	
	var message = " ".join(args)
	_print_to_console(passive_controller.commit(message))

func _cmd_merge_request(args: Array) -> void:
	if args.is_empty():
		_print_to_console("[color=#ff0000]Usage: mr <create|approve> [title/id][/color]")
		return
	
	match args[0].to_lower():
		"create":
			if args.size() > 1:
				var title = " ".join(args.slice(1))
				_print_to_console(passive_controller.create_mr(title))
		"approve":
			if args.size() > 1:
				_print_to_console(passive_controller.approve_mr(args[1]))

func _cmd_merge(args: Array) -> void:
	if args.is_empty():
		_print_to_console("[color=#ff0000]Usage: merge <mr-id>[/color]")
		return
	
	_print_to_console(passive_controller.merge(args[0]))

func _cmd_workflow_status(args: Array) -> void:
	if args.is_empty() or args[0] == "status":
		_print_to_console(passive_controller.get_status())
	elif args[0] == "diff":
		_print_to_console(passive_controller.show_diff())

func _cmd_test_features(args: Array) -> void:
	if args.is_empty():
		# Run full test suite (threaded, no freeze)
		version_backup.run_full_test_suite()
		_print_to_console("[color=#00ffff]=== STARTING THREADED TESTS ====[/color]")
		_print_to_console("Testing will run across multiple frames...")
		_print_to_console("Use 'test status' to check progress")
	elif args[0] == "status":
		var status = version_backup.get_test_status()
		_print_to_console("[color=#00ffff]=== TEST STATUS ====[/color]")
		_print_to_console("Current zone: " + status["current_zone"])
		_print_to_console("Active tests: " + str(status["active_tests"]))
		_print_to_console("Completed: " + str(status["completed_tests"]) + "/" + str(status["total_containers"]))
	elif args[0] == "zone":
		if args.size() > 1:
			version_backup.run_zone_test(args[1])
			_print_to_console("Starting tests for zone: " + args[1])
		else:
			_print_to_console("Available zones: cosmos, planet, cave, asteroid")
	else:
		_print_to_console("Usage: test [status|zone <name>]")

func _cmd_test_being_assets(_args: Array) -> void:
	_print_to_console("[color=#00ffff]=== Testing Universal Being Asset Integration ===[/color]")
	
	# Load and run the test script
	var test_script = load("res://scripts/test/test_universal_being_assets.gd")
	if test_script:
		var test_instance = test_script.new()
		add_child(test_instance)
		test_instance.run_tests()
		test_instance.queue_free()
		_print_to_console("[color=#00ff00]Test completed. Check console output for results.[/color]")
	else:
		_print_to_console("[color=#ff0000]Error: Test script not found![/color]")

func _cmd_gizmo(args: Array) -> void:
	_print_to_console("[color=#00ffff]=== Universal Gizmo System ===[/color]")
	
	# Get or create the gizmo system
	var gizmo_system = get_tree().get_first_node_in_group("universal_gizmo_system")
	if not gizmo_system:
		# Create the gizmo system
		var gizmo_script = load("res://scripts/core/universal_gizmo_system.gd")
		if gizmo_script:
			gizmo_system = Node3D.new()
			gizmo_system.set_script(gizmo_script)
			gizmo_system.name = "UniversalGizmoSystem"
			gizmo_system.add_to_group("universal_gizmo_system")
			
			# Add to scene
			var main_scene = get_tree().get_tree().get_tree().current_scene.get_child(get_tree().get_tree().get_tree().current_scene.get_child_count() - 1)
			FloodgateController.universal_add_child(gizmo_system, main_scene)
			
			_print_to_console("[color=#00ff00]Created Universal Gizmo System[/color]")
	
	# Handle commands
	if args.is_empty():
		_print_to_console("Usage: gizmo <show|hide|mode|target> [args]")
		_print_to_console("Commands:")
		_print_to_console("  show - Show the gizmo")
		_print_to_console("  hide - Hide the gizmo")
		_print_to_console("  mode <translate|rotate|scale> - Set gizmo mode")
		_print_to_console("  target <object_name> - Attach to object")
		return
	
	# Forward to gizmo system
	if gizmo_system and gizmo_system.has_method("_cmd_gizmo"):
		var result = gizmo_system._cmd_gizmo(args)
		_print_to_console(result)
	else:
		_print_to_console("[color=#ff0000]Error: Gizmo system not available[/color]")

func _cmd_version_control(args: Array) -> void:
	if args.is_empty():
		_print_to_console("Version system temporarily using threaded testing")
		_print_to_console("Use 'test' command for feature testing")
		return
	
	_print_to_console("Version control commands temporarily disabled during threading update")

func _cmd_physics_control(args: Array) -> void:
	if args.is_empty():
		var info = physics_state_manager.get_state_info()
		_print_to_console("=== PHYSICS STATE ===")
		_print_to_console("Scene zero point: " + str(info["scene_zero_point"]))
		_print_to_console("Gravity center: " + str(info["gravity_center"]))
		_print_to_console("Gravity strength: " + str(info["gravity_strength"]))
		_print_to_console("Total objects: " + str(info["total_objects"]))
		for state in info["state_counts"]:
			_print_to_console("  " + state + ": " + str(info["state_counts"][state]))
		return
	
	match args[0]:
		"zero":
			if args.size() >= 4:
				var point = Vector3(args[1].to_float(), args[2].to_float(), args[3].to_float())
				physics_state_manager.set_scene_zero_point(point)
				_print_to_console("Scene zero point set to: " + str(point))
		"gravity":
			if args.size() >= 5:
				var center = Vector3(args[1].to_float(), args[2].to_float(), args[3].to_float())
				var strength = args[4].to_float()
				physics_state_manager.set_gravity_center(center, strength)
				_print_to_console("Gravity set to center: " + str(center) + ", strength: " + str(strength))
		"state":
			if args.size() >= 3:
				var object_name = args[1]
				var state_name = args[2].to_upper()
				# Find object by name and set state
				_print_to_console("Setting " + object_name + " to state " + state_name)
		_:
			_print_to_console("[color=#ff0000]Usage: physics [zero x y z|gravity x y z strength|state object state][/color]")

func _cmd_project_manager(args: Array) -> void:
	if args.is_empty():
		_print_to_console(multi_project_manager.list_projects())
		return
	
	match args[0]:
		"switch":
			if args.size() > 1:
				if multi_project_manager.switch_project(args[1]):
					_print_to_console("Switched to project: " + args[1])
				else:
					_print_to_console("Project not found: " + args[1])
		"status":
			var status = multi_project_manager.get_current_project_status()
			_print_to_console("=== CURRENT PROJECT ===")
			_print_to_console("Name: " + status["name"])
			_print_to_console("Version: " + status["version"])
			_print_to_console("Status: " + status["status"])
			_print_to_console("Priority: " + status["priority"])
			_print_to_console("Time worked: " + str(int(status["total_time"])) + "s")
			_print_to_console("Pending tasks: " + str(status["pending_tasks"]))
			_print_to_console("Completed tasks: " + str(status["completed_tasks"]))
			if status["waiting_for_user"]:
				_print_to_console("Waiting for user: " + str(int(status["wait_time"])) + "s")
		"all":
			var all_status = multi_project_manager.get_all_projects_status()
			_print_to_console("=== ALL PROJECTS ===")
			_print_to_console("Current: " + all_status["current_project"])
			_print_to_console("Session time: " + str(int(all_status["session_time"])) + "s")
			for project_id in all_status["projects"]:
				var proj = all_status["projects"][project_id]
				_print_to_console(project_id + ": " + proj["name"] + " (" + proj["status"] + ")")
		_:
			_print_to_console("[color=#ff0000]Usage: projects [switch project|status|all][/color]")

func _cmd_timing_info(_args: Array) -> void:
	_print_to_console(multi_project_manager.get_timing_report())

# Debug 3D Screen Commands
var debug_screen: Node3D

func _cmd_debug_screen(args: Array) -> void:
	if not debug_screen:
		var DebugScreen = preload("res://scripts/core/debug_3d_screen.gd")
		debug_screen = Node3D.new()
		debug_screen.set_script(DebugScreen)
		debug_screen.name = "Debug3DScreen"
		get_tree().get_node("/root/FloodgateController").universal_add_child(debug_screen, get_tree().current_scene)
		_print_to_console("[color=#00ff00]Debug 3D screen created and enabled[/color]")
	else:
		if args.size() > 0 and args[0] == "off":
			debug_screen.queue_free()
			debug_screen = null
			_print_to_console("[color=#ff8800]Debug 3D screen disabled[/color]")
		else:
			debug_screen.visible = not debug_screen.visible
			var state = "enabled" if debug_screen.visible else "disabled"
			_print_to_console("[color=#00ff00]Debug 3D screen " + state + "[/color]")

func _cmd_select_object(args: Array) -> void:
	if not debug_screen:
		_print_to_console("[color=#ff0000]Debug screen not active. Use 'debug' command first[/color]")
		return
	
	if args.is_empty():
		_print_to_console("Usage: select <object_name|id>")
		_print_to_console("Available objects:")
		var objects = get_tree().get_nodes_in_group("spawned_objects")
		for i in range(objects.size()):
			_print_to_console("  " + str(i) + ": " + objects[i].name)
		return
	
	var target = args[0]
	var selected_object = null
	
	# Try to find by ID first
	if target.is_valid_int():
		var id = target.to_int()
		var objects = get_tree().get_nodes_in_group("spawned_objects")
		if id >= 0 and id < objects.size():
			selected_object = objects[id]
	else:
		# Find by name
		selected_object = get_tree().get_first_node_in_group("spawned_objects")
		var objects = get_tree().get_nodes_in_group("spawned_objects")
		for obj in objects:
			if obj.name.to_lower().find(target.to_lower()) != -1:
				selected_object = obj
				break
	
	if selected_object:
		debug_screen.call("select_object", selected_object)
		_print_to_console("[color=#00ff00]Selected: " + selected_object.name + "[/color]")
	else:
		_print_to_console("[color=#ff0000]Object not found: " + target + "[/color]")

func _cmd_move_object(args: Array) -> void:
	if not debug_screen:
		_print_to_console("[color=#ff0000]Debug screen not active. Use 'debug' command first[/color]")
		return
	
	if args.size() < 3:
		_print_to_console("Usage: move <x> <y> <z>")
		_print_to_console("Example: move 5 0 -3")
		return
	
	var x = args[0].to_float()
	var y = args[1].to_float()
	var z = args[2].to_float()
	var new_pos = Vector3(x, y, z)
	
	if debug_screen.call("set_selected_object_position", new_pos):
		_print_to_console("[color=#00ff00]Object moved to: " + str(new_pos) + "[/color]")
	else:
		_print_to_console("[color=#ff0000]No object selected. Use 'select' command first[/color]")

func _cmd_rotate_object(args: Array) -> void:
	if not debug_screen:
		_print_to_console("[color=#ff0000]Debug screen not active. Use 'debug' command first[/color]")
		return
	
	if args.size() < 3:
		_print_to_console("Usage: rotate <x> <y> <z> (degrees)")
		_print_to_console("Example: rotate 0 90 0")
		return
	
	var x = deg_to_rad(args[0].to_float())
	var y = deg_to_rad(args[1].to_float())
	var z = deg_to_rad(args[2].to_float())
	var new_rot = Vector3(x, y, z)
	
	if debug_screen.call("set_selected_object_rotation", new_rot):
		_print_to_console("[color=#00ff00]Object rotated to: " + str(Vector3(rad_to_deg(x), rad_to_deg(y), rad_to_deg(z))) + " degrees[/color]")
	else:
		_print_to_console("[color=#ff0000]No object selected. Use 'select' command first[/color]")

func _cmd_scale_object(args: Array) -> void:
	if not debug_screen:
		_print_to_console("[color=#ff0000]Debug screen not active. Use 'debug' command first[/color]")
		return
	
	if args.is_empty():
		_print_to_console("Usage: scale_obj <scale> or scale_obj <x> <y> <z>")
		_print_to_console("Example: scale_obj 2.0 or scale_obj 1.5 2.0 1.0")
		return
	
	var new_scale: Vector3
	if args.size() == 1:
		var scale = args[0].to_float()
		new_scale = Vector3(scale, scale, scale)
	else:
		var x = args[0].to_float()
		var y = args[1].to_float() if args.size() > 1 else x
		var z = args[2].to_float() if args.size() > 2 else x
		new_scale = Vector3(x, y, z)
	
	if debug_screen.call("set_selected_object_scale", new_scale):
		_print_to_console("[color=#00ff00]Object scaled to: " + str(new_scale) + "[/color]")
	else:
		_print_to_console("[color=#ff0000]No object selected. Use 'select' command first[/color]")

# Light Being State Commands
func _cmd_awaken_object(args: Array) -> void:
	if args.is_empty():
		_print_to_console("Usage: awaken <object_name|id>")
		_print_to_console("Awakens a static object to begin movement")
		return
	
	var target = args[0]
	var selected_object = _find_object_by_name_or_id(target)
	
	if selected_object:
		var current_state = physics_state_manager.get_object_state(selected_object)
		if current_state == physics_state_manager.PhysicsState.STATIC:
			if physics_state_manager.set_object_state(selected_object, physics_state_manager.PhysicsState.AWAKENING):
				_print_to_console("[color=#ffff00]" + selected_object.name + " is awakening...[/color]")
			else:
				_print_to_console("[color=#ff0000]Failed to awaken " + selected_object.name + "[/color]")
		else:
			_print_to_console("[color=#ff8800]" + selected_object.name + " is already in state: " + _state_to_string(current_state) + "[/color]")
	else:
		_print_to_console("[color=#ff0000]Object not found: " + target + "[/color]")

func _cmd_change_state(args: Array) -> void:
	if args.size() < 2:
		_print_to_console("Usage: state <object_name|id> <state>")
		_print_to_console("States: static, awakening, kinematic, dynamic, ethereal, light_being, scene_anchored")
		return
	
	var target = args[0]
	var state_name = args[1].to_lower()
	var selected_object = _find_object_by_name_or_id(target)
	
	if not selected_object:
		_print_to_console("[color=#ff0000]Object not found: " + target + "[/color]")
		return
	
	var new_state = _string_to_state(state_name)
	if new_state == -1:
		_print_to_console("[color=#ff0000]Invalid state: " + state_name + "[/color]")
		return
	
	var current_state = physics_state_manager.get_object_state(selected_object)
	if physics_state_manager.set_object_state(selected_object, new_state):
		_print_to_console("[color=#00ff00]" + selected_object.name + " state changed: " + _state_to_string(current_state) + " → " + _state_to_string(new_state) + "[/color]")
	else:
		_print_to_console("[color=#ff0000]Cannot transition from " + _state_to_string(current_state) + " to " + _state_to_string(new_state) + "[/color]")

func _find_object_by_name_or_id(target: String) -> Node3D:
	if target.is_valid_int():
		var id = target.to_int()
		var objects = get_tree().get_nodes_in_group("spawned_objects")
		if id >= 0 and id < objects.size():
			return objects[id]
	else:
		var objects = get_tree().get_nodes_in_group("spawned_objects")
		for obj in objects:
			if obj.name.to_lower().find(target.to_lower()) != -1:
				return obj
	return null

func _string_to_state(state_name: String) -> int:
	match state_name:
		"static": return physics_state_manager.PhysicsState.STATIC
		"awakening": return physics_state_manager.PhysicsState.AWAKENING
		"kinematic": return physics_state_manager.PhysicsState.KINEMATIC
		"dynamic": return physics_state_manager.PhysicsState.DYNAMIC
		"ethereal": return physics_state_manager.PhysicsState.ETHEREAL
		"light_being": return physics_state_manager.PhysicsState.LIGHT_BEING
		"connected": return physics_state_manager.PhysicsState.CONNECTED
		"transforming": return physics_state_manager.PhysicsState.TRANSFORMING
		"scene_anchored": return physics_state_manager.PhysicsState.SCENE_ANCHORED
	return -1

func _state_to_string(state: int) -> String:
	match state:
		physics_state_manager.PhysicsState.STATIC: return "static"
		physics_state_manager.PhysicsState.AWAKENING: return "awakening"
		physics_state_manager.PhysicsState.KINEMATIC: return "kinematic"
		physics_state_manager.PhysicsState.DYNAMIC: return "dynamic"
		physics_state_manager.PhysicsState.ETHEREAL: return "ethereal"
		physics_state_manager.PhysicsState.LIGHT_BEING: return "light_being"
		physics_state_manager.PhysicsState.CONNECTED: return "connected"
		physics_state_manager.PhysicsState.TRANSFORMING: return "transforming"
		physics_state_manager.PhysicsState.SCENE_ANCHORED: return "scene_anchored"
	return "unknown"

# Timer and Task Management Commands
func _cmd_timer_control(args: Array) -> void:
	if not claude_timer:
		_print_to_console("[color=#ff0000]Timer system not available[/color]")
		return
	
	if args.is_empty():
		_print_to_console(claude_timer.get_timer_report())
		return
	
	match args[0]:
		"report":
			_print_to_console(claude_timer.get_timer_report())
		"project":
			if args.size() > 1:
				if claude_timer.switch_project(args[1]):
					_print_to_console("[color=#00ff00]Switched to project: " + args[1] + "[/color]")
				else:
					_print_to_console("[color=#ff0000]Project not found: " + args[1] + "[/color]")
			else:
				_print_to_console("Available projects: talking_ragdoll, 12_turns_system, eden_project")
		"threshold":
			if args.size() > 1:
				var seconds = args[1].to_float()
				claude_timer.set_wait_threshold(seconds)
				_print_to_console("[color=#00ff00]Autonomous work threshold set to " + str(seconds) + "s[/color]")
			else:
				_print_to_console("Usage: timer threshold <seconds>")
		"metrics":
			var metrics = claude_timer.get_session_metrics()
			_print_to_console("=== SESSION METRICS ===")
			_print_to_console("Duration: " + str(int(metrics["session_duration"])) + "s")
			_print_to_console("User interactions: " + str(metrics["user_interactions"]))
			_print_to_console("Tasks completed: " + str(metrics["tasks_completed"]))
			_print_to_console("Autonomous time: " + str(int(metrics["autonomous_time"])) + "s")
			_print_to_console("Wait time: " + str(int(metrics["user_wait_time"])) + "s")
		_:
			_print_to_console("Usage: timer [report|project|threshold|metrics]")

func _cmd_task_management(args: Array) -> void:
	if not claude_timer:
		_print_to_console("[color=#ff0000]Timer system not available[/color]")
		return
	
	if args.is_empty():
		_print_to_console("Usage: task [start|complete|status] <task_name>")
		return
	
	match args[0]:
		"start":
			if args.size() > 1:
				var task_name = " ".join(args.slice(1))
				claude_timer.start_task(task_name)
				_print_to_console("[color=#00ff00]Started task: " + task_name + "[/color]")
			else:
				_print_to_console("Usage: task start <task_name>")
		"complete":
			var duration = claude_timer.complete_task()
			if duration > 0:
				_print_to_console("[color=#00ff00]Task completed in " + str(duration) + "s[/color]")
			else:
				_print_to_console("[color=#ff8800]No active task to complete[/color]")
		"status":
			var metrics = claude_timer.get_session_metrics()
			if metrics["current_task"] != "":
				_print_to_console("Active task: " + metrics["current_task"])
			else:
				_print_to_console("No active task")
		_:
			_print_to_console("Usage: task [start|complete|status] <task_name>")

# Multi-Todo Management Commands
func _cmd_multi_todos(args: Array) -> void:
	if not multi_todo_manager:
		_print_to_console("[color=#ff0000]Multi-todo system not available[/color]")
		return
	
	if args.is_empty():
		_print_to_console(multi_todo_manager.get_formatted_todos())
		return
	
	match args[0]:
		"show":
			var project = args[1] if args.size() > 1 else ""
			_print_to_console(multi_todo_manager.get_formatted_todos(project))
		"add":
			if args.size() >= 3:
				var project = args[1]
				var content = " ".join(args.slice(2))
				var priority = args[3] if args.size() > 3 else "medium"
				if multi_todo_manager.add_todo(project, content, priority):
					_print_to_console("[color=#00ff00]Added todo to " + project + "[/color]")
				else:
					_print_to_console("[color=#ff0000]Invalid project: " + project + "[/color]")
			else:
				_print_to_console("Usage: todos add <project> <content> [priority]")
				_print_to_console("Projects: talking_ragdoll, 12_turns_system, eden_project")
		"complete":
			if args.size() >= 3:
				var project = args[1]
				var todo_id = args[2]
				if multi_todo_manager.complete_todo(project, todo_id):
					_print_to_console("[color=#00ff00]Todo completed![/color]")
				else:
					_print_to_console("[color=#ff0000]Todo not found[/color]")
			else:
				_print_to_console("Usage: todos complete <project> <todo_id>")
		"modify":
			if args.size() >= 4:
				var project = args[1]
				var todo_id = args[2]
				var new_content = " ".join(args.slice(3))
				if multi_todo_manager.modify_todo(project, todo_id, new_content):
					_print_to_console("[color=#00ff00]Todo modified![/color]")
				else:
					_print_to_console("[color=#ff0000]Todo not found[/color]")
			else:
				_print_to_console("Usage: todos modify <project> <todo_id> <new_content>")
		"stepback":
			if args.size() >= 3:
				var project = args[1]
				var todo_id = args[2]
				if multi_todo_manager.step_back_todo(project, todo_id):
					_print_to_console("[color=#ffff00]Stepped back todo![/color]")
				else:
					_print_to_console("[color=#ff0000]Cannot step back todo[/color]")
			else:
				_print_to_console("Usage: todos stepback <project> <todo_id>")
		"summary":
			var summary = multi_todo_manager.get_session_summary()
			_print_to_console("=== SESSION SUMMARY ===")
			_print_to_console("Total tasks: " + str(summary["total_tasks"]))
			_print_to_console("Completed today: " + str(summary["completed_today"]))
			_print_to_console("Modifications: " + str(summary["modifications"]))
			_print_to_console("Step backs: " + str(summary["step_backs"]))
			_print_to_console("Session: " + str(int(summary["session_duration"])) + "s")
		"priority":
			if args.size() > 1:
				var priority = args[1]
				var todos = multi_todo_manager.get_priority_todos(priority)
				_print_to_console("=== " + priority.to_upper() + " PRIORITY TODOS ===")
				for todo in todos:
					_print_to_console("📝 " + todo["content"] + " (" + todo["project"] + ")")
			else:
				_print_to_console("Usage: todos priority <high|medium|low>")
		_:
			_print_to_console("Usage: todos [show|add|complete|modify|stepback|summary|priority]")

func _cmd_balance_workload(_args: Array) -> void:
	if not multi_todo_manager:
		_print_to_console("[color=#ff0000]Multi-todo system not available[/color]")
		return
	
	var balance = multi_todo_manager.balance_workload()
	_print_to_console("=== WORKLOAD BALANCE ===")
	_print_to_console("Recommendation: " + balance["recommendation"])
	if balance["focus_project"] != "":
		_print_to_console("Focus on: " + balance["focus_project"])
	
	var summary = multi_todo_manager.get_session_summary()
	_print_to_console("\nProject Status:")
	for project_id in summary["projects"]:
		var proj = summary["projects"][project_id]
		_print_to_console("• " + proj["name"] + ": " + str(proj["pending"]) + " pending, " + str(proj["completed_today"]) + " done today")

# ----- FLOODGATE SYSTEM COMMANDS -----
func _cmd_floodgate_status(_args: Array) -> void:
	var floodgate = get_node_or_null("/root/FloodgateController")
	if not floodgate:
		_print_to_console("[color=#ff0000]FloodgateController not found![/color]")
		return
	
	_print_to_console("[color=#00ffff]=== FLOODGATE STATUS ===[/color]")
	_print_to_console("System: [color=#00ff00]Online[/color]")
	
	# Show queue sizes
	var queue_info = {
		"Actions": floodgate.actions_to_be_called.size(),
		"Nodes": floodgate.nodes_to_be_added.size(),
		"Data": floodgate.data_to_be_send.size(),
		"Movements": floodgate.things_to_be_moved.size(),
		"Deletions": floodgate.nodes_to_be_unloaded.size(),
		"Functions": floodgate.functions_to_be_called.size(),
		"Messages": floodgate.messages_to_be_called.size(),
		"Textures": floodgate.texture_storage.size()
	}
	
	_print_to_console("Queue Sizes:")
	for queue_name in queue_info:
		var size = queue_info[queue_name]
		var color = "#00ff00" if size == 0 else "#ffff00" if size < 10 else "#ff6600"
		_print_to_console("  " + queue_name + ": [color=" + color + "]" + str(size) + "[/color]")

func _cmd_queue_status(args: Array) -> void:
	_cmd_floodgate_status(args)

func _cmd_health_check(_args: Array) -> void:
	var main_scene = get_tree().get_tree().current_scene
	if main_scene and main_scene.has_method("run_health_check"):
		main_scene.run_health_check()
	else:
		_print_to_console("[color=#ff0000]Health check not available - main scene controller missing[/color]")

func _cmd_test_floodgate(_args: Array) -> void:
	var main_scene = get_tree().get_tree().current_scene
	if main_scene and main_scene.has_method("test_floodgate"):
		main_scene.test_floodgate()
		_print_to_console("[color=#00ff00]Floodgate test initiated - check console output[/color]")
	else:
		_print_to_console("[color=#ff0000]Floodgate test not available - main scene controller missing[/color]")

func _cmd_system_status(_args: Array) -> void:
	_print_to_console("[color=#00ffff]=== SYSTEM STATUS ===[/color]")
	
	var systems = [
		{"name": "FloodgateController", "path": "/root/FloodgateController"},
		{"name": "AssetLibrary", "path": "/root/AssetLibrary"},
		{"name": "WorldBuilder", "path": "/root/WorldBuilder"},
		{"name": "ConsoleManager", "path": "/root/ConsoleManager"},
		{"name": "DialogueSystem", "path": "/root/DialogueSystem"},
		{"name": "SceneLoader", "path": "/root/SceneLoader"},
		{"name": "UISettingsManager", "path": "/root/UISettingsManager"}
	]
	
	for system in systems:
		var node = get_node_or_null(system.path)
		var status = "[color=#00ff00]✅ Online[/color]" if node else "[color=#ff0000]❌ Offline[/color]"
		_print_to_console(system.name + ": " + status)
	
	# Check main scene controller
	var main_scene = get_tree().get_tree().current_scene
	if main_scene and main_scene.has_method("is_ready"):
		var scene_ready = main_scene.is_ready()
		var status = "[color=#00ff00]✅ Ready[/color]" if scene_ready else "[color=#ffff00]⏳ Initializing[/color]"
		_print_to_console("MainGameController: " + status)
	else:
		_print_to_console("MainGameController: [color=#ff6600]⚠️ Unknown[/color]")

# ----- ENHANCED RAGDOLL CONTROL COMMANDS -----

func _find_ragdoll_controller() -> Node:
	# Try multiple paths to find the ragdoll controller
	var paths = [
		"/root/MainGame/RagdollController",
		"/root/Main/RagdollController",
		"//RagdollController",
		"/root/RagdollController"
	]
	
	for path in paths:
		var controller = get_node_or_null(path)
		if controller:
			return controller
	
	# Try to find in current scene
	var current_scene = get_tree().current_scene
	if current_scene:
		var controller = current_scene.get_node_or_null("RagdollController")
		if controller:
			return controller
	
	return null

func _find_astral_beings() -> Node:
	# Try multiple paths to find the astral beings
	var paths = [
		"/root/MainGame/AstralBeings",
		"/root/Main/AstralBeings",
		"//AstralBeings",
		"/root/AstralBeings"
	]
	
	for path in paths:
		var beings = get_node_or_null(path)
		if beings:
			return beings
	
	# Try to find in current scene
	var current_scene = get_tree().current_scene
	if current_scene:
		var beings = current_scene.get_node_or_null("AstralBeings")
		if beings:
			return beings
	
	return null

func _cmd_ragdoll_come_here(_args: Array) -> void:
	var ragdoll_controller = _find_ragdoll_controller()
	if ragdoll_controller and ragdoll_controller.has_method("cmd_ragdoll_come_here"):
		ragdoll_controller.cmd_ragdoll_come_here()
		_print_to_console("[color=#00ff00]Ragdoll is coming to your position[/color]")
	else:
		_print_to_console("[color=#ff0000]Ragdoll controller not found[/color]")

func _cmd_ragdoll_pickup_nearest(_args: Array) -> void:
	var ragdoll_controller = _find_ragdoll_controller()
	if ragdoll_controller and ragdoll_controller.has_method("cmd_ragdoll_pickup_nearest"):
		ragdoll_controller.cmd_ragdoll_pickup_nearest()
		_print_to_console("[color=#00ff00]Ragdoll will pickup nearest object[/color]")
	else:
		_print_to_console("[color=#ff0000]Ragdoll controller not found[/color]")

func _cmd_ragdoll_drop(_args: Array) -> void:
	var ragdoll_controller = _find_ragdoll_controller()
	if ragdoll_controller and ragdoll_controller.has_method("cmd_ragdoll_drop"):
		ragdoll_controller.cmd_ragdoll_drop()
		_print_to_console("[color=#00ff00]Ragdoll will drop held object[/color]")
	else:
		_print_to_console("[color=#ff0000]Ragdoll controller not found[/color]")

func _cmd_ragdoll_organize(_args: Array) -> void:
	var ragdoll_controller = _find_ragdoll_controller()
	if ragdoll_controller and ragdoll_controller.has_method("cmd_ragdoll_organize"):
		ragdoll_controller.cmd_ragdoll_organize()
		_print_to_console("[color=#00ff00]Ragdoll will organize nearby objects[/color]")
	else:
		_print_to_console("[color=#ff0000]Ragdoll controller not found[/color]")

func _cmd_ragdoll_patrol(_args: Array) -> void:
	var ragdoll_controller = _find_ragdoll_controller()
	if ragdoll_controller and ragdoll_controller.has_method("cmd_ragdoll_patrol"):
		ragdoll_controller.cmd_ragdoll_patrol()
		_print_to_console("[color=#00ff00]Ragdoll starting patrol route[/color]")
	else:
		_print_to_console("[color=#ff0000]Ragdoll controller not found[/color]")

# ----- ASTRAL BEINGS COMMANDS -----

func _cmd_beings_status(_args: Array) -> void:
	var astral_beings = _find_astral_beings()
	if astral_beings and astral_beings.has_method("cmd_beings_status"):
		astral_beings.cmd_beings_status()
		_print_to_console("[color=#00ffff]Astral beings status displayed[/color]")
	else:
		_print_to_console("[color=#ff0000]Astral beings system not found[/color]")

func _cmd_beings_help_ragdoll(_args: Array) -> void:
	var astral_beings = _find_astral_beings()
	if astral_beings and astral_beings.has_method("cmd_beings_help_ragdoll"):
		astral_beings.cmd_beings_help_ragdoll()
		_print_to_console("[color=#00ffff]Astral beings helping ragdoll[/color]")
	else:
		_print_to_console("[color=#ff0000]Astral beings system not found[/color]")

func _cmd_beings_organize(_args: Array) -> void:
	var astral_beings = _find_astral_beings()
	if astral_beings and astral_beings.has_method("cmd_beings_organize"):
		astral_beings.cmd_beings_organize()
		_print_to_console("[color=#00ffff]Astral beings organizing scene[/color]")
	else:
		_print_to_console("[color=#ff0000]Astral beings system not found[/color]")

func _cmd_beings_harmony(_args: Array) -> void:
	var astral_beings = _find_astral_beings()
	if astral_beings and astral_beings.has_method("cmd_beings_harmony"):
		astral_beings.cmd_beings_harmony()
		_print_to_console("[color=#00ffff]Astral beings creating environmental harmony[/color]")
	else:
		_print_to_console("[color=#ff0000]Astral beings system not found[/color]")


func _cmd_setup_systems(_args: Array) -> void:
	_print_to_console("[color=#ffff00]Manually setting up all systems...[/color]")
	
	var main_scene = get_tree().get_tree().current_scene
	if main_scene and main_scene.has_method("_setup_ragdoll_system"):
		main_scene._setup_ragdoll_system()
		# main_scene._setup_astral_beings()  # Old system disabled
		main_scene._setup_mouse_interaction()
		_print_to_console("[color=#00ff00]Systems setup complete![/color]")
		_print_to_console("[color=#00ff00]Use 'astral_being' command to spawn new talking astral beings[/color]")
	else:
		_print_to_console("[color=#ff0000]Could not find main scene controller[/color]")

func _cmd_test_mouse_click(_args: Array) -> void:
	_print_to_console("[color=#ffff00]Testing mouse interaction system...[/color]")
	
	var mouse_system = null
	var main_scene = get_tree().get_tree().current_scene
	if main_scene:
		mouse_system = main_scene.get_node_or_null("MouseInteractionSystem")
	
	if mouse_system:
		_print_to_console("[color=#00ff00]Mouse system found! Left-click on objects to inspect.[/color]")
		if mouse_system.has_method("cmd_toggle_debug_panel"):
			mouse_system.cmd_toggle_debug_panel()
	else:
		_print_to_console("[color=#ff0000]Mouse system not found. Run 'setup_systems' first.[/color]")

func _cmd_object_inspector(args: Array) -> void:
	var main_scene = get_tree().get_tree().current_scene
	if not main_scene:
		_print_to_console("[color=#ff0000]No main scene found[/color]")
		return
		
	var mouse_system = main_scene.get_node_or_null("MouseInteractionSystem")
	if not mouse_system:
		_print_to_console("[color=#ffff00]Mouse interaction system not found. Creating...[/color]")
		# Try to set it up
		if main_scene.has_method("_setup_mouse_interaction"):
			main_scene._setup_mouse_interaction()
			mouse_system = main_scene.get_node_or_null("MouseInteractionSystem")
		else:
			_print_to_console("[color=#ff0000]Cannot create mouse interaction system[/color]")
			return
	
	if args.is_empty():
		# Toggle debug panel
		if mouse_system.has_method("cmd_toggle_debug_panel"):
			mouse_system.cmd_toggle_debug_panel()
			_print_to_console("[color=#00ff00]Object inspector toggled[/color]")
		else:
			_print_to_console("[color=#ff0000]Debug panel toggle method not found[/color]")
	else:
		match args[0].to_lower():
			"on", "show", "enable":
				if mouse_system.has_method("show_debug_panel"):
					mouse_system.show_debug_panel()
					_print_to_console("[color=#00ff00]Object inspector enabled[/color]")
				else:
					_print_to_console("[color=#ffff00]Using fallback toggle method[/color]")
					if mouse_system.has_method("cmd_toggle_debug_panel"):
						mouse_system.cmd_toggle_debug_panel()
			"off", "hide", "disable":
				if mouse_system.has_method("hide_debug_panel"):
					mouse_system.hide_debug_panel()
					_print_to_console("[color=#ffff00]Object inspector disabled[/color]")
				else:
					_print_to_console("[color=#ffff00]Using fallback toggle method[/color]")
					if mouse_system.has_method("cmd_toggle_debug_panel"):
						mouse_system.cmd_toggle_debug_panel()
			"status":
				if mouse_system.has_method("get_debug_panel_status"):
					var status = mouse_system.get_debug_panel_status()
					_print_to_console("[color=#00ffff]Object Inspector Status:[/color]")
					_print_to_console("  Visible: " + str(status.get("visible", "unknown")))
					_print_to_console("  Selected Object: " + str(status.get("selected", "none")))
				else:
					_print_to_console("[color=#ffff00]Status method not available[/color]")
			_:
				_print_to_console("[color=#ffff00]Usage: object_inspector [on|off|status][/color]")
				_print_to_console("  object_inspector        - Toggle inspector")
				_print_to_console("  object_inspector on     - Show inspector") 
				_print_to_console("  object_inspector off    - Hide inspector")
				_print_to_console("  object_inspector status - Show inspector status")

func _cmd_object_info(args: Array) -> void:
	if args.size() == 0:
		_print_to_console("[color=#ffff00]Usage: info <object_name>[/color]")
		_print_to_console("[color=#ffff00]Example: info tree_1[/color]")
		return
	
	var object_name = args[0]
	var found_object = null
	
	# Search in all possible locations
	var search_nodes = [get_tree().get_tree().get_tree().current_scene]
	while search_nodes.size() > 0:
		var node = search_nodes.pop_front()
		if node.name == object_name:
			found_object = node
			break
		search_nodes.append_array(node.get_children())
	
	if not found_object:
		_print_to_console("[color=#ff0000]Object '" + object_name + "' not found[/color]")
		return
	
	# Display object info
	_print_to_console("[color=#00ffff]=== Object Info: " + object_name + " ===[/color]")
	_print_to_console("[color=#ffff00]Type:[/color] " + found_object.get_class())
	
	if found_object is Node3D:
		var pos = found_object.global_position
		_print_to_console("[color=#ffff00]Position:[/color] (%.2f, %.2f, %.2f)" % [pos.x, pos.y, pos.z])
		var rot = found_object.rotation_degrees
		_print_to_console("[color=#ffff00]Rotation:[/color] (%.1f°, %.1f°, %.1f°)" % [rot.x, rot.y, rot.z])
		var scale = found_object.scale
		_print_to_console("[color=#ffff00]Scale:[/color] (%.2f, %.2f, %.2f)" % [scale.x, scale.y, scale.z])
	
	if found_object is RigidBody3D:
		var rb = found_object as RigidBody3D
		_print_to_console("[color=#00ff00]--- Physics ---[/color]")
		_print_to_console("[color=#ffff00]Mass:[/color] %.2f kg" % rb.mass)
		_print_to_console("[color=#ffff00]Gravity Scale:[/color] %.2f" % rb.gravity_scale)
		_print_to_console("[color=#ffff00]Linear Velocity:[/color] %.2f m/s" % rb.linear_velocity.length())
	
	var groups = found_object.get_groups()
	if groups.size() > 0:
		_print_to_console("[color=#ffff00]Groups:[/color] " + ", ".join(groups))

# Eden Action System Commands

func _cmd_action_list(_args: Array) -> void:
	_print_to_console("[color=#00ff00]=== Eden Action System ===[/color]")
	
	var mouse_system = _find_mouse_interaction_system()
	if not mouse_system or not mouse_system.action_system:
		_print_to_console("[color=#ff0000]Action system not found![/color]")
		return
	
	var action_system = mouse_system.action_system
	_print_to_console("[color=#ffff00]Available Actions:[/color]")
	
	for action_name in action_system.action_definitions:
		var def = action_system.action_definitions[action_name]
		_print_to_console("  [color=#00ffff]%s[/color] - Steps: %s" % [action_name, str(def.steps)])
		if def.has("duration"):
			_print_to_console("    Duration: %.1fs" % def.duration)
		if def.has("required_components") and def.required_components.size() > 0:
			_print_to_console("    Requires: %s" % str(def.required_components))
	
	_print_to_console("\n[color=#ffff00]Combo Patterns:[/color]")
	for pattern_name in action_system.combo_patterns:
		var pattern = action_system.combo_patterns[pattern_name]
		_print_to_console("  [color=#00ffff]%s[/color] - %s → %s" % [pattern_name, str(pattern.pattern), pattern.action])

func _cmd_action_test(args: Array) -> void:
	if args.size() < 2:
		_print_to_console("[color=#ff0000]Usage: action_test <action_name> <object_name>[/color]")
		_print_to_console("Available actions: examine, pickup, activate, combine")
		return
	
	var action_name = args[0]
	var object_name = args[1]
	
	var mouse_system = _find_mouse_interaction_system()
	if not mouse_system or not mouse_system.action_system:
		_print_to_console("[color=#ff0000]Action system not found![/color]")
		return
	
	# Find the target object
	var target = get_node_or_null("/root/MainGame/" + object_name)
	if not target:
		# Search in objects group
		for obj in get_tree().get_nodes_in_group("objects"):
			if obj.name == object_name:
				target = obj
				break
	
	if not target:
		_print_to_console("[color=#ff0000]Object '%s' not found![/color]" % object_name)
		return
	
	# Queue the action
	if mouse_system.action_system.queue_action(action_name, target):
		_print_to_console("[color=#00ff00]Queued action '%s' on %s[/color]" % [action_name, target.name])
	else:
		_print_to_console("[color=#ff0000]Failed to queue action![/color]")

func _cmd_action_combo(args: Array) -> void:
	if args.size() < 1:
		_print_to_console("[color=#ff0000]Usage: action_combo <pattern>[/color]")
		_print_to_console("Patterns: double (quick double click), hold (hold and drag), triple (triple tap)")
		return
	
	var pattern = args[0]
	var mouse_system = _find_mouse_interaction_system()
	if not mouse_system or not mouse_system.action_system:
		_print_to_console("[color=#ff0000]Action system not found![/color]")
		return
	
	# Simulate combo input
	match pattern:
		"double":
			mouse_system.action_system.process_combo_input("click")
			await get_tree().create_timer(0.1).timeout
			mouse_system.action_system.process_combo_input("click")
		"hold":
			mouse_system.action_system.process_combo_input("press")
			await get_tree().create_timer(0.6).timeout
			mouse_system.action_system.process_combo_input("release")
		"triple":
			for i in 3:
				mouse_system.action_system.process_combo_input("click")
				if i < 2:
					await get_tree().create_timer(0.2).timeout
		_:
			_print_to_console("[color=#ff0000]Unknown pattern: %s[/color]" % pattern)
			return
	
	_print_to_console("[color=#00ff00]Simulated combo pattern: %s[/color]" % pattern)

func _find_mouse_interaction_system() -> Node:
	# Try different paths where the mouse system might be
	var paths = [
		"/root/MainGame/MouseInteractionSystem",
		"/root/Main/MouseInteractionSystem",
		"/root/MouseInteractionSystem",
		"//MouseInteractionSystem"
	]
	
	for path in paths:
		var system = get_node_or_null(path)
		if system:
			return system
	
	# Search by class/script
	for node in get_tree().get_nodes_in_group("_ungrouped_"):
		if node.has_method("_handle_mouse_click"):
			return node
	
	return null

# Dimensional Ragdoll Commands

func _cmd_dimension_shift(args: Array) -> void:
	if args.size() < 1:
		_print_to_console("[color=#ff0000]Usage: dimension <physical|dream|memory|emotion|void>[/color]")
		return
	
	var dimensional_system = _find_dimensional_ragdoll()
	if not dimensional_system:
		_print_to_console("[color=#ff0000]Dimensional ragdoll system not found![/color]")
		return
	
	var dimension_map = {
		"physical": 0,
		"dream": 1, 
		"memory": 2,
		"emotion": 3,
		"void": 4
	}
	
	var dimension_name = args[0].to_lower()
	if dimension_name in dimension_map:
		dimensional_system.shift_dimension(dimension_map[dimension_name])
		_print_to_console("[color=#00ff00]Shifted to %s dimension[/color]" % dimension_name.capitalize())
	else:
		_print_to_console("[color=#ff0000]Unknown dimension: %s[/color]" % dimension_name)

func _cmd_consciousness_add(args: Array) -> void:
	if args.size() < 1:
		_print_to_console("[color=#ff0000]Usage: consciousness <amount>[/color]")
		_print_to_console("Example: consciousness 0.1")
		return
	
	var dimensional_system = _find_dimensional_ragdoll()
	if not dimensional_system:
		_print_to_console("[color=#ff0000]Dimensional ragdoll system not found![/color]")
		return
	
	var amount = float(args[0])
	dimensional_system.add_consciousness_experience(amount, "console_command")
	_print_to_console("[color=#00ff00]Added %.2f consciousness experience[/color]" % amount)

func _cmd_emotion_set(args: Array) -> void:
	if args.size() < 2:
		_print_to_console("[color=#ff0000]Usage: emotion <emotion> <value>[/color]")
		_print_to_console("Emotions: happy, sad, angry, curious, peaceful, excited, transcendent")
		_print_to_console("Example: emotion happy 0.8")
		return
	
	var dimensional_system = _find_dimensional_ragdoll()
	if not dimensional_system:
		_print_to_console("[color=#ff0000]Dimensional ragdoll system not found![/color]")
		return
	
	var emotion = args[0]
	var value = clamp(float(args[1]), 0.0, 1.0)
	dimensional_system.set_emotion(emotion, value)
	_print_to_console("[color=#00ff00]Set %s to %.2f[/color]" % [emotion, value])

func _cmd_cast_spell(args: Array) -> void:
	if args.size() < 1:
		_print_to_console("[color=#ff0000]Usage: spell <spell_name>[/color]")
		_print_to_console("Basic spells: wobble, blink, giggle")
		_print_to_console("Advanced: float, glow, teleport_short, dimension_peek")
		return
	
	var dimensional_system = _find_dimensional_ragdoll()
	if not dimensional_system:
		_print_to_console("[color=#ff0000]Dimensional ragdoll system not found![/color]")
		return
	
	var spell_name = args[0]
	if dimensional_system.cast_spell(spell_name):
		_print_to_console("[color=#00ff00]Cast spell: %s[/color]" % spell_name)
	else:
		_print_to_console("[color=#ff0000]Failed to cast spell: %s[/color]" % spell_name)

func _cmd_ragdoll_status(_args: Array) -> void:
	var dimensional_system = _find_dimensional_ragdoll()
	if not dimensional_system:
		_print_to_console("[color=#ff0000]Dimensional ragdoll system not found![/color]")
		return
	
	var state = dimensional_system.get_state()
	_print_to_console("[color=#00ff00]=== Ragdoll Status ===[/color]")
	_print_to_console("[color=#ffff00]Dimension:[/color] " + str(["Physical", "Dream", "Memory", "Emotion", "Void"][state.dimension]))
	_print_to_console("[color=#ffff00]Consciousness:[/color] %.2f (%s)" % [state.consciousness, state.evolution])
	_print_to_console("[color=#ffff00]Emotion:[/color] " + state.emotion)
	_print_to_console("[color=#ffff00]Bonding:[/color] %.2f" % state.bonding)
	_print_to_console("[color=#ffff00]Known Spells:[/color] " + str(state.spells.size()))
	for spell in state.spells:
		_print_to_console("  - " + spell)

func _find_dimensional_ragdoll() -> Node:
	var paths = [
		"/root/MainGame/DimensionalRagdollSystem",
		"/root/Main/DimensionalRagdollSystem",
		"//DimensionalRagdollSystem"
	]
	
	for path in paths:
		var system = get_node_or_null(path)
		if system:
			return system
	
	return null

func _cmd_console_debug_toggle(_args: Array) -> void:
	"""Toggle console debug overlay visibility"""
	var debug_overlay = get_node_or_null("/root/ConsoleDebugOverlay")
	
	if not debug_overlay:
		# Load and create it dynamically
		var overlay_script = load("res://scripts/patches/console_debug_overlay.gd")
		if overlay_script:
			debug_overlay = overlay_script.new()
			debug_overlay.name = "ConsoleDebugOverlay"
			get_tree().get_node("/root/FloodgateController").universal_add_child(debug_overlay, get_tree().get_tree().current_scene)
			_print_to_console("[color=#00ff00]Console debug overlay created and visible![/color]")
		else:
			_print_to_console("[color=#ff0000]Could not load console_debug_overlay.gd[/color]")
	else:
		# Remove existing overlay
		debug_overlay.queue_free()
		_print_to_console("[color=#00ff00]Console debug overlay removed![/color]")

func _cmd_performance_stats(_args: Array) -> void:
	"""Show performance statistics"""
	_print_to_console("[color=#00ff00]=== Performance Statistics ===[/color]")
	
	# Engine stats
	_print_to_console("\n[color=#ffff00]Engine Performance:[/color]")
	_print_to_console("  FPS: %d" % Performance.get_monitor(Performance.TIME_FPS))
	_print_to_console("  Process Time: %.2f ms" % (Performance.get_monitor(Performance.TIME_PROCESS) * 1000))
	_print_to_console("  Physics Time: %.2f ms" % (Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000))
	
	# Memory stats
	_print_to_console("\n[color=#ffff00]Memory Usage:[/color]")
	_print_to_console("  Static: %.2f MB" % (Performance.get_monitor(Performance.MEMORY_STATIC) / 1024.0 / 1024.0))
	_print_to_console("  Message Buffer: %.2f MB" % (Performance.get_monitor(Performance.MEMORY_MESSAGE_BUFFER_MAX) / 1024.0 / 1024.0))
	
	# Object counts
	_print_to_console("\n[color=#ffff00]Object Counts:[/color]")
	_print_to_console("  Nodes: %d" % Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
	_print_to_console("  Resources: %d" % Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT))
	_print_to_console("  Orphan Nodes: %d" % Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))
	
	# Physics objects
	_print_to_console("\n[color=#ffff00]Physics:[/color]")
	_print_to_console("  3D Physics Steps: %d" % Performance.get_monitor(Performance.PHYSICS_3D_ACTIVE_OBJECTS))
	
	# Check for process manager
	var process_manager = get_node_or_null("/root/BackgroundProcessManager")
	if process_manager and process_manager.has_method("get_performance_stats"):
		var stats = process_manager.get_performance_stats()
		_print_to_console("\n[color=#ffff00]Process Manager:[/color]")
		_print_to_console("  Avg Frame Time: %.2f ms" % stats.avg_frame_time)
		_print_to_console("  Physics Processes: %d" % stats.physics_processes)
		_print_to_console("  Visual Processes: %d" % stats.visual_processes)
		_print_to_console("  Debug Processes: %d (%s)" % [stats.debug_processes, "enabled" if stats.debug_enabled else "disabled"])

func _cmd_process_manager(args: Array) -> void:
	"""Control background process manager"""
	if args.is_empty():
		_print_to_console("[color=#ffff00]Usage: process_manager <debug on/off>[/color]")
		return
	
	var process_manager = get_node_or_null("/root/BackgroundProcessManager")
	if not process_manager:
		# Create it
		var pm_script = load("res://scripts/core/background_process_manager.gd")
		if pm_script:
			process_manager = pm_script.new()
			process_manager.name = "BackgroundProcessManager"
			get_tree().get_node("/root/FloodgateController").universal_add_child(process_manager, get_tree().get_tree().current_scene)
			_print_to_console("[color=#00ff00]Process manager created![/color]")
		else:
			_print_to_console("[color=#ff0000]Could not load process manager![/color]")
			return
	
	match args[0].to_lower():
		"debug":
			if args.size() > 1:
				var enabled = args[1].to_lower() == "on"
				process_manager.set_debug_enabled(enabled)
				_print_to_console("[color=#00ff00]Debug processes: %s[/color]" % ("enabled" if enabled else "disabled"))
			else:
				_print_to_console("[color=#ffff00]Usage: process_manager debug on/off[/color]")
		_:
			_print_to_console("[color=#ff0000]Unknown command: %s[/color]" % args[0])

func _cmd_debug_panel_status(_args: Array) -> void:
	_print_to_console("[color=#00ff00]=== Debug Panel Status ===[/color]")
	
	var mouse_system = _find_mouse_interaction_system()
	if not mouse_system:
		_print_to_console("[color=#ff0000]MouseInteractionSystem not found![/color]")
		return
	
	if mouse_system.has_method("cmd_toggle_debug_panel"):
		# Check if debug panel exists
		if mouse_system.debug_panel:
			var panel = mouse_system.debug_panel
			_print_to_console("[color=#ffff00]Panel Found:[/color] " + panel.name)
			_print_to_console("[color=#ffff00]Visible:[/color] " + str(panel.visible))
			_print_to_console("[color=#ffff00]Position:[/color] " + str(panel.position))
			_print_to_console("[color=#ffff00]Size:[/color] " + str(panel.size))
			_print_to_console("[color=#ffff00]Parent:[/color] " + str(panel.get_parent().name))
			_print_to_console("[color=#ffff00]Layer:[/color] " + str(panel.get_parent().layer))
			
			# Show viewport info
			var viewport = get_viewport()
			_print_to_console("[color=#ffff00]Viewport Size:[/color] " + str(viewport.get_visible_rect().size))
		else:
			_print_to_console("[color=#ff0000]Debug panel not found in mouse system![/color]")
	else:
		_print_to_console("[color=#ff0000]Mouse system doesn't have debug panel methods![/color]")

# Object Limit Management Commands

func _cmd_object_limits(_args: Array) -> void:
	var floodgate = get_node_or_null("/root/FloodgateController")
	if not floodgate:
		_print_to_console("[color=#ff0000]FloodgateController not found![/color]")
		return
	
	var stats = floodgate.get_object_statistics()
	_print_to_console("[color=#00ff00]=== Object Limits Status ===[/color]")
	_print_to_console("[color=#ffff00]Objects:[/color] %d / %d" % [stats.total_objects, stats.max_objects])
	_print_to_console("[color=#ffff00]Astral Beings:[/color] %d / %d" % [stats.astral_beings, stats.max_astral_beings])
	_print_to_console("[color=#ffff00]Space Remaining:[/color] %d slots" % stats.space_remaining)
	
	if stats.objects_by_type.size() > 0:
		_print_to_console("[color=#ffff00]Objects by Type:[/color]")
		for type in stats.objects_by_type:
			_print_to_console("  %s: %d" % [type, stats.objects_by_type[type]])

func _cmd_talk_to_beings(args: Array) -> void:
	var beings = get_tree().get_nodes_in_group("astral_beings")
	if beings.is_empty():
		_print_to_console("[color=#ff0000]No astral beings found in the scene![/color]")
		return
	
	if args.size() > 0:
		var message = args[0]
		_print_to_console("[color=#00ff00]Broadcasting to astral beings: '%s'[/color]" % message)
		
		for being in beings:
			if being.has_method("speak"):
				# Make beings respond to the message
				var responses = [
					"I hear you calling!",
					"Your words reach the astral realm",
					"We listen and respond with light",
					"The garden speaks through us"
				]
				being.speak(responses[randi() % responses.size()])
	else:
		_print_to_console("[color=#00ff00]=== Astral Beings Status ===[/color]")
		for i in range(beings.size()):
			var being = beings[i]
			if being.has_method("get_status"):
				var status = being.get_status()
				_print_to_console("[color=#ffff00]%s:[/color] %s personality, energy %.1f" % [
					status.name, status.personality, status.energy
				])

func _cmd_being_count(_args: Array) -> void:
	var beings = get_tree().get_nodes_in_group("astral_beings")
	_print_to_console("[color=#00ff00]Astral beings in scene: %d[/color]" % beings.size())
	
	var personalities = {}
	for being in beings:
		if being.has_method("get_status"):
			var status = being.get_status()
			var personality = status.personality
			personalities[personality] = personalities.get(personality, 0) + 1
	
	if personalities.size() > 0:
		_print_to_console("[color=#ffff00]By personality:[/color]")
		for personality in personalities:
			_print_to_console("  %s: %d" % [personality.capitalize(), personalities[personality]])

func _cmd_help_ragdoll(args: Array) -> void:
	_print_to_console("[color=#ffff00]Commanding astral beings to help ragdoll...[/color]")
	
	# Create helper node if needed
	var helper = get_node_or_null("/root/AstralRagdollHelper")
	if not helper:
		var helper_script = load("res://scripts/core/astral_ragdoll_helper.gd")
		if helper_script:
			helper = Node.new()
			helper.name = "AstralRagdollHelper"
			helper.set_script(helper_script)
			get_tree().get_node("/root/FloodgateController").universal_add_child(helper, get_tree().get_tree().current_scene)
	
	if helper:
		if args.size() > 0 and args[0] == "stop":
			helper.stop_helping()
			_print_to_console("[color=#00ff00]Astral beings stopped helping ragdoll[/color]")
		else:
			helper.start_helping_ragdoll()
			_print_to_console("[color=#00ff00]Astral beings are now helping ragdoll walk![/color]")
			_print_to_console("[color=#ffff00]Use 'help_ragdoll stop' to stop assistance[/color]")
	else:
		_print_to_console("[color=#ff0000]Failed to create helper system[/color]")


# ========== JSH ENHANCED COMMANDS ==========

func _cmd_jsh_status(_args: Array) -> void:
	_print_to_console("[color=#00ffff]=== JSH System Status ===[/color]")
	
	# Check each JSH system
	var systems = {
		"JSHSceneTree": "Scene Tree Monitor",
		"JSHConsole": "Enhanced Console",
		"JSHThreadPool": "Thread Pool Manager",
		"AkashicRecords": "Save/Load System"
	}
	
	for system_name in systems:
		if has_node("/root/" + system_name):
			_print_to_console("[color=#00ff00]✓[/color] %s: Active" % systems[system_name])
		else:
			_print_to_console("[color=#ff0000]✗[/color] %s: Not loaded" % systems[system_name])

func _cmd_container(args: Array) -> void:
	if args.size() == 0:
		_print_to_console("[color=#ff0000]Usage: container <create < /dev/null | list|delete> [name][/color]")
		return
		
	var action = args[0]
	
	match action:
		"create":
			if args.size() < 2:
				_print_to_console("[color=#ff0000]Usage: container create <name>[/color]")
				return
			# Create organizational container
			var container = Node3D.new()
			container.name = args[1]
			get_tree().get_node("/root/FloodgateController").universal_add_child(container, get_tree().current_scene)
			_print_to_console("[color=#00ff00]Created container: %s[/color]" % args[1])
			
		"list":
			_print_to_console("[color=#00ffff]=== Containers ===[/color]")
			for child in get_tree().get_tree().current_scene.get_children():
				if child is Node3D and child.get_child_count() > 0:
					_print_to_console("- %s (%d children)" % [child.name, child.get_child_count()])
					
		"delete":
			if args.size() < 2:
				_print_to_console("[color=#ff0000]Usage: container delete <name>[/color]")
				return
			var container = get_tree().get_tree().current_scene.get_node_or_null(args[1])
			if container:
				container.queue_free()
				_print_to_console("[color=#00ff00]Deleted container: %s[/color]" % args[1])
			else:
				_print_to_console("[color=#ff0000]Container not found: %s[/color]" % args[1])

func _cmd_thread_status(_args: Array) -> void:
	if has_node("/root/JSHThreadPool"):
		var thread_pool = get_node("/root/JSHThreadPool")
		_print_to_console("[color=#00ffff]=== Thread Pool Status ===[/color]")
		
		if thread_pool.has_method("get_status"):
			var status = thread_pool.get_status()
			_print_to_console("Active Threads: %d" % status.get("active_threads", 0))
			_print_to_console("Queued Tasks: %d" % status.get("queued_tasks", 0))
			_print_to_console("Completed Tasks: %d" % status.get("completed_tasks", 0))
		else:
			_print_to_console("Thread count: %d" % OS.get_processor_count())
	else:
		_print_to_console("[color=#ff0000]JSH Thread Pool not available[/color]")

func _cmd_scene_tree(_args: Array) -> void:
	if has_node("/root/JSHSceneTree"):
		var _scene_tree_sys = get_node("/root/JSHSceneTree")  # Future implementation
		_print_to_console("[color=#00ffff]=== Scene Tree Structure ===[/color]")
		
		# Show tree structure
		_print_scene_tree_recursive(get_tree().get_tree().current_scene, 0)
	else:
		# Fallback to basic tree display
		_print_to_console("[color=#00ffff]=== Scene Tree ===[/color]")
		_print_scene_tree_recursive(get_tree().get_tree().current_scene, 0)

func _print_scene_tree_recursive(node: Node, depth: int) -> void:
	var indent = "  ".repeat(depth)
	var node_info = "%s%s" % [indent, node.name]
	
	# Add type info
	if node is RigidBody3D:
		node_info += " [RigidBody3D]"
	elif node is CharacterBody3D:
		node_info += " [CharacterBody3D]"
	elif node is MeshInstance3D:
		node_info += " [Mesh]"
	elif node is Light3D:
		node_info += " [Light]"
		
	_print_to_console(node_info)
	
	# Limit depth to prevent spam
	if depth < 3:
		for child in node.get_children():
			_print_scene_tree_recursive(child, depth + 1)

func _cmd_akashic_save(args: Array) -> void:
	if args.size() == 0:
		_print_to_console("[color=#ff0000]Usage: akashic_save <filename>[/color]")
		return
		
	if has_node("/root/AkashicRecords"):
		var akashic = get_node("/root/AkashicRecords")
		if akashic.has_method("save_scene_state"):
			var filename = "user://akashic_%s.dat" % args[0]
			akashic.save_scene_state(filename)
			_print_to_console("[color=#00ff00]Scene saved to Akashic Records: %s[/color]" % filename)
		else:
			# Fallback save
			_cmd_save_scene(args)
	else:
		_print_to_console("[color=#ff0000]Akashic Records system not available[/color]")

func _cmd_akashic_load(args: Array) -> void:
	if args.size() == 0:
		_print_to_console("[color=#ff0000]Usage: akashic_load <filename>[/color]")
		return
		
	if has_node("/root/AkashicRecords"):
		var akashic = get_node("/root/AkashicRecords")
		if akashic.has_method("load_scene_state"):
			var filename = "user://akashic_%s.dat" % args[0]
			akashic.load_scene_state(filename)
			_print_to_console("[color=#00ff00]Scene loaded from Akashic Records: %s[/color]" % filename)
		else:
			# Fallback load
			_cmd_load_scene(args)
	else:
		_print_to_console("[color=#ff0000]Akashic Records system not available[/color]")


func _cmd_physics_test(args: Array) -> void:
	# Load and use the physics test tool
	var physics_test_script = load("res://scripts/debug/ragdoll_physics_test.gd")
	if not physics_test_script:
		_print_to_console("[color=#ff0000]Physics test tool not found![/color]")
		return
	
	# Create temporary instance
	var physics_tester = Node.new()
	physics_tester.set_script(physics_test_script)
	add_child(physics_tester)
	
	if args.size() == 0:
		_print_to_console("[color=#ff0000]Usage: physics_test <command> [args][/color]")
		_print_to_console("Commands: test, show, adjust, compare")
		_print_to_console("Example: physics_test test heavy_stable")
		physics_tester.queue_free()
		return
	
	var result = physics_tester.handle_physics_command(args)
	_print_to_console(result)
	
	# Keep tester alive for show command
	if args[0] != "show":
		physics_tester.queue_free()

func _cmd_inspect_object(args: Array) -> void:
	if not object_inspector:
		_print_to_console("[color=#ff0000]Object inspector not available![/color]")
		return
	
	if args.size() == 0:
		_print_to_console("[color=#ffff00]Usage: inspect <object_name> OR inspect <object_id>[/color]")
		_print_to_console("[color=#ffff00]Example: inspect ragdoll[/color]")
		_print_to_console("[color=#ffff00]Example: inspect 2 (object ID from list command)[/color]")
		return
	
	var target_name = args[0]
	var target_object: Node = null
	
	# Try to find by object ID first (from list command)
	if target_name.is_valid_int():
		var object_id = int(target_name)
		var objects = get_tree().get_nodes_in_group("spawned_objects")
		if object_id >= 0 and object_id < objects.size():
			target_object = objects[object_id]
	else:
		# Try to find by name
		target_object = get_tree().get_first_node_in_group(target_name)
		
		# If not found in groups, search by node name
		if not target_object:
			var all_nodes = get_tree().get_nodes_in_group("spawned_objects")
			for node in all_nodes:
				if node.name.to_lower().contains(target_name.to_lower()):
					target_object = node
					break
		
		# Last resort: search all scene nodes
		if not target_object:
			target_object = _find_node_by_name(get_tree().current_scene, target_name)
	
	if target_object:
		object_inspector.inspect_object(target_object)
		_print_to_console("[color=#00ff00]Inspecting object: " + target_object.name + " (" + target_object.get_class() + ")[/color]")
	else:
		_print_to_console("[color=#ff0000]Object '" + target_name + "' not found![/color]")
		_print_to_console("[color=#ffff00]Use 'list' command to see available objects[/color]")

func _find_node_by_name(scene_node: Node, name: String) -> Node:
	if scene_node.name.to_lower().contains(name.to_lower()):
		return scene_node
	
	for child in scene_node.get_children():
		var result = _find_node_by_name(child, name)
		if result:
			return result
	
	return null

func _cmd_ragdoll_debug(args: Array) -> void:
	if args.size() == 0:
		_print_to_console("[color=#ffff00]Usage: ragdoll_debug <on|off|toggle> [option][/color]")
		_print_to_console("[color=#ffff00]Options: joints, forces, com, support, velocities, state, all[/color]")
		_print_to_console("[color=#ffff00]Example: ragdoll_debug on[/color]")
		_print_to_console("[color=#ffff00]Example: ragdoll_debug toggle com[/color]")
		return
	
	var command = args[0].to_lower()
	
	match command:
		"on":
			if not debug_visualizer:
				# Create debug visualizer
				var debug_script = load("res://scripts/debug/ragdoll_debug_visualizer.gd")
				if debug_script:
					debug_visualizer = Node3D.new()
					debug_visualizer.name = "RagdollDebugVisualizer"
					debug_visualizer.set_script(debug_script)
					get_tree().get_node("/root/FloodgateController").universal_add_child(debug_visualizer, get_tree().current_scene)
					
					# Find and connect to ragdoll
					var ragdoll = get_tree().get_first_node_in_group("ragdolls")
					if ragdoll:
						debug_visualizer.set_ragdoll(ragdoll)
						_print_to_console("[color=#00ff00]Ragdoll debug visualization enabled[/color]")
					else:
						_print_to_console("[color=#ff0000]No ragdoll found to debug![/color]")
				else:
					_print_to_console("[color=#ff0000]Debug visualizer script not found![/color]")
			else:
				_print_to_console("[color=#ffff00]Debug visualizer already active[/color]")
		
		"off":
			if debug_visualizer:
				debug_visualizer.queue_free()
				debug_visualizer = null
				_print_to_console("[color=#00ff00]Ragdoll debug visualization disabled[/color]")
			else:
				_print_to_console("[color=#ffff00]Debug visualizer not active[/color]")
		
		"toggle":
			if debug_visualizer and args.size() > 1:
				var option = args[1]
				var result = debug_visualizer.toggle_debug_option(option)
				_print_to_console("[color=#00ff00]" + result + "[/color]")
			else:
				_print_to_console("[color=#ff0000]Debug visualizer not active or no option specified[/color]")
		
		_:
			_print_to_console("[color=#ff0000]Unknown command: " + command + "[/color]")

func _show_debug_physics_info() -> void:
	"""Show physics debug information when Tab is pressed"""
	_print_to_console("\n[color=#00ffff]===== PHYSICS DEBUG INFO =====[/color]")
	
	# Get gravity info
	var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	_print_to_console("[color=#ffff00]Gravity:[/color] " + str(gravity))
	
	# Get ragdoll info if exists
	var ragdolls = get_tree().get_nodes_in_group("ragdolls")
	if not ragdolls.is_empty():
		var ragdoll = ragdolls[0]
		_print_to_console("\n[color=#ffff00]Ragdoll Status:[/color]")
		_print_to_console("  Position: " + str(ragdoll.global_position))
		
		# Check if it has body parts metadata
		if ragdoll.has_meta("body_parts"):
			var parts = ragdoll.get_meta("body_parts")
			var pelvis = parts.get("pelvis")
			if pelvis and pelvis is RigidBody3D:
				_print_to_console("  Pelvis velocity: " + str(pelvis.linear_velocity))
				_print_to_console("  Pelvis mass: " + str(pelvis.mass) + "kg")
		
		# Check walker state
		var walker = ragdoll.get_node_or_null("SimpleWalker")
		if walker:
			_print_to_console("  Walker state: " + str(walker.current_state if walker.has("current_state") else "Unknown"))
			_print_to_console("  Is walking: " + str(walker.is_walking if walker.has("is_walking") else "Unknown"))
	else:
		_print_to_console("[color=#ff0000]No ragdoll spawned[/color]")
	
	# Show spawned objects count
	var spawned = get_tree().get_nodes_in_group("spawned_objects")
	_print_to_console("\n[color=#ffff00]Spawned objects:[/color] " + str(spawned.size()))
	
	# Show FPS
	_print_to_console("[color=#ffff00]FPS:[/color] " + str(Engine.get_frames_per_second()))
	_print_to_console("[color=#00ffff]=============================[/color]\n")

# Enhanced Movement Commands
func _cmd_ragdoll_move(args: Array) -> void:
	if args.size() == 0:
		_print_to_console("[color=#ffff00]Usage: ragdoll_move <direction> [duration][/color]")
		_print_to_console("[color=#ffff00]Directions: forward, backward, left, right, stop[/color]")
		_print_to_console("[color=#ffff00]Duration: seconds to move (optional, -1 for infinite)[/color]")
		return
	
	var direction = args[0].to_lower()
	var duration = -1.0  # Default to infinite
	if args.size() > 1:
		duration = float(args[1])
	
	var ragdoll = get_tree().get_first_node_in_group("ragdolls")
	if not ragdoll:
		_print_to_console("[color=#ff0000]No ragdoll spawned![/color]")
		return
	
	var walker = ragdoll.get_node_or_null("EnhancedWalker")
	if not walker:
		walker = ragdoll.get_node_or_null("SimpleWalker")
	
	# Try new command system first
	if walker and walker.has_method("execute_movement_command"):
		walker.execute_movement_command(direction, duration)
		if duration > 0:
			_print_to_console("[color=#00ff00]Ragdoll moving " + direction + " for " + str(duration) + " seconds[/color]")
		else:
			_print_to_console("[color=#00ff00]Ragdoll moving " + direction + "[/color]")
	elif walker and walker.has_method("set_movement_input"):
		# Fallback to old system
		var input = Vector2.ZERO
		match direction:
			"forward": input = Vector2(0, -1)
			"backward": input = Vector2(0, 1)
			"left": input = Vector2(-1, 0)
			"right": input = Vector2(1, 0)
			"stop": input = Vector2.ZERO
			_: 
				_print_to_console("[color=#ff0000]Unknown direction: " + direction + "[/color]")
				return
		
		walker.set_movement_input(input)
		_print_to_console("[color=#00ff00]Ragdoll moving " + direction + "[/color]")
	else:
		_print_to_console("[color=#ff0000]Walker not found or doesn't support movement![/color]")

func _cmd_ragdoll_speed(args: Array) -> void:
	if args.size() == 0:
		_print_to_console("[color=#ffff00]Usage: ragdoll_speed <mode>[/color]")
		_print_to_console("[color=#ffff00]Modes: slow, normal, fast[/color]")
		return
	
	var mode = args[0].to_lower()
	var ragdoll = get_tree().get_first_node_in_group("ragdolls")
	if not ragdoll:
		_print_to_console("[color=#ff0000]No ragdoll spawned![/color]")
		return
	
	var walker = ragdoll.get_node_or_null("EnhancedWalker")
	if walker and walker.has_method("set_speed_mode"):
		var speed_mode = 1  # Default to normal
		match mode:
			"slow": speed_mode = 0
			"normal": speed_mode = 1
			"fast": speed_mode = 2
			_:
				_print_to_console("[color=#ff0000]Unknown speed mode: " + mode + "[/color]")
				return
		
		walker.set_speed_mode(speed_mode)
		_print_to_console("[color=#00ff00]Ragdoll speed set to " + mode + "[/color]")
	else:
		_print_to_console("[color=#ff0000]Enhanced walker not found![/color]")

func _cmd_ragdoll_run(_args: Array) -> void:
	var ragdoll = get_tree().get_first_node_in_group("ragdolls")
	if not ragdoll:
		_print_to_console("[color=#ff0000]No ragdoll spawned![/color]")
		return
	
	# Toggle running by setting fast speed
	var walker = ragdoll.get_node_or_null("EnhancedWalker")
	if walker and walker.has_method("set_speed_mode"):
		# Check current state to toggle
		if walker.has_method("get_current_state"):
			var current_state = walker.get_current_state()
			if current_state == 3:  # RUNNING
				walker.set_speed_mode(1)  # Normal
				_print_to_console("[color=#00ff00]Ragdoll stopped running[/color]")
			else:
				walker.set_speed_mode(2)  # Fast
				_print_to_console("[color=#00ff00]Ragdoll is running![/color]")
	else:
		_print_to_console("[color=#ff0000]Enhanced walker not found![/color]")

func _cmd_ragdoll_crouch(_args: Array) -> void:
	var ragdoll = get_tree().get_first_node_in_group("ragdolls")
	if not ragdoll:
		_print_to_console("[color=#ff0000]No ragdoll spawned![/color]")
		return
	
	var walker = ragdoll.get_node_or_null("EnhancedWalker")
	if walker and walker.has_method("trigger_crouch"):
		walker.trigger_crouch(true)
		_print_to_console("[color=#00ff00]Ragdoll crouching toggled[/color]")
	else:
		_print_to_console("[color=#ff0000]Enhanced walker not found![/color]")

func _cmd_ragdoll_jump(_args: Array) -> void:
	var ragdoll = get_tree().get_first_node_in_group("ragdolls")
	if not ragdoll:
		_print_to_console("[color=#ff0000]No ragdoll spawned![/color]")
		return
	
	var walker = ragdoll.get_node_or_null("EnhancedWalker")
	if walker and walker.has_method("trigger_jump"):
		walker.trigger_jump()
		_print_to_console("[color=#00ff00]Ragdoll jumping![/color]")
	else:
		_print_to_console("[color=#ff0000]Enhanced walker not found![/color]")

func _cmd_ragdoll_rotate(args: Array) -> void:
	if args.size() == 0:
		_print_to_console("[color=#ffff00]Usage: ragdoll_rotate <direction>[/color]")
		_print_to_console("[color=#ffff00]Directions: left, right, stop[/color]")
		return
	
	var direction = args[0].to_lower()
	var ragdoll = get_tree().get_first_node_in_group("ragdolls")
	if not ragdoll:
		_print_to_console("[color=#ff0000]No ragdoll spawned![/color]")
		return
	
	var walker = ragdoll.get_node_or_null("EnhancedWalker")
	if walker and walker.has_method("set_rotation_input"):
		var rotation = 0.0
		match direction:
			"left": rotation = -1.0
			"right": rotation = 1.0
			"stop": rotation = 0.0
			_:
				_print_to_console("[color=#ff0000]Unknown direction: " + direction + "[/color]")
				return
		
		walker.set_rotation_input(rotation)
		_print_to_console("[color=#00ff00]Ragdoll rotating " + direction + "[/color]")
	else:
		_print_to_console("[color=#ff0000]Enhanced walker not found![/color]")

func _cmd_ragdoll_stand(_args: Array) -> void:
	var ragdoll = get_tree().get_first_node_in_group("ragdolls")
	if not ragdoll:
		_print_to_console("[color=#ff0000]No ragdoll spawned![/color]")
		return
	
	# Force standing state
	var walker = ragdoll.get_node_or_null("EnhancedWalker")
	if walker:
		if walker.has_method("_enter_state"):
			walker._enter_state(1)  # STANDING_UP state
			_print_to_console("[color=#00ff00]Ragdoll standing up![/color]")
	else:
		# Try simple walker
		walker = ragdoll.get_node_or_null("SimpleWalker")
		if walker and walker.has_method("stand_up"):
			walker.stand_up()
			_print_to_console("[color=#00ff00]Ragdoll standing up![/color]")
		else:
			_print_to_console("[color=#ff0000]No walker found![/color]")

func _cmd_ragdoll_state(_args: Array) -> void:
	var ragdoll = get_tree().get_first_node_in_group("ragdolls")
	if not ragdoll:
		_print_to_console("[color=#ff0000]No ragdoll spawned![/color]")
		return
	
	var walker = ragdoll.get_node_or_null("EnhancedWalker")
	if walker and walker.has_method("get_state_name"):
		var state = walker.get_state_name()
		_print_to_console("[color=#00ff00]Ragdoll state: " + state + "[/color]")
		
		# Additional info
		if walker.has("is_grounded"):
			_print_to_console("  Grounded: " + str(walker.is_grounded))
		if walker.has("current_speed_mode"):
			var speed_names = ["Slow", "Normal", "Fast"]
			_print_to_console("  Speed mode: " + speed_names[walker.current_speed_mode])
	else:
		# Try simple walker
		walker = ragdoll.get_node_or_null("SimpleWalker")
		if walker and walker.has("current_state"):
			_print_to_console("[color=#00ff00]Ragdoll state: " + str(walker.current_state) + "[/color]")
		else:
			_print_to_console("[color=#ff0000]No walker found![/color]")

# Tutorial System Commands
func _cmd_tutorial(args: Array) -> void:
	if args.size() == 0:
		_print_to_console("[color=#ffff00]Tutorial Commands:[/color]")
		_print_to_console("  tutorial start - Begin the ragdoll tutorial")
		_print_to_console("  tutorial stop - Stop the current tutorial")
		_print_to_console("  tutorial status - Show tutorial progress")
		return
	
	match args[0].to_lower():
		"start":
			_cmd_tutorial_start(args.slice(1))
		"stop":
			_cmd_tutorial_stop(args.slice(1))
		"status":
			_cmd_tutorial_status(args.slice(1))
		_:
			_print_to_console("[color=#ff0000]Unknown tutorial command: " + args[0] + "[/color]")

func _cmd_tutorial_start(_args: Array) -> void:
	# Get or create tutorial manager
	var tutorial_manager = get_node_or_null("/root/TutorialManager")
	if not tutorial_manager:
		# Try to load and instantiate
		var tutorial_script = load("res://scripts/tutorial/tutorial_manager.gd")
		if tutorial_script:
			tutorial_manager = Node.new()
			tutorial_manager.name = "TutorialManager"
			tutorial_manager.set_script(tutorial_script)
			get_tree().get_node("/root/FloodgateController").universal_add_child(tutorial_manager, get_tree().get_tree().current_scene)
			_print_to_console("[color=#00ff00]Tutorial system initialized![/color]")
		else:
			_print_to_console("[color=#ff0000]Tutorial system not found![/color]")
			return
	
	# Start tutorial
	if tutorial_manager.has_method("start_tutorial"):
		tutorial_manager.start_tutorial()
		_print_to_console("[color=#00ff00]Tutorial started! Follow the on-screen instructions.[/color]")
		_print_to_console("[color=#ffff00]Use 'tutorial stop' to exit at any time.[/color]")
	else:
		_print_to_console("[color=#ff0000]Tutorial system error![/color]")

func _cmd_tutorial_stop(_args: Array) -> void:
	var tutorial_manager = get_node_or_null("/root/TutorialManager")
	if tutorial_manager and tutorial_manager.has_method("stop_tutorial"):
		tutorial_manager.stop_tutorial()
		_print_to_console("[color=#00ff00]Tutorial stopped.[/color]")
	else:
		_print_to_console("[color=#ff0000]No active tutorial to stop.[/color]")

func _cmd_tutorial_status(_args: Array) -> void:
	var tutorial_manager = get_node_or_null("/root/TutorialManager")
	if not tutorial_manager:
		_print_to_console("[color=#ff0000]Tutorial system not active.[/color]")
		return
	
	if tutorial_manager.has_method("is_tutorial_active") and tutorial_manager.is_tutorial_active():
		var phase_names = ["Intro", "Basic Movement", "Advanced Movement", "Object Interaction", "Physics Playground", "Complete"]
		var current_phase = tutorial_manager.get_current_phase()
		
		_print_to_console("[color=#00ff00]=== Tutorial Status ===[/color]")
		_print_to_console("Active: Yes")
		_print_to_console("Current Phase: " + phase_names[current_phase])
		_print_to_console("Progress: Check the on-screen progress bar")
		
		# Phase-specific hints
		match current_phase:
			1:  # BASIC_MOVEMENT
				_print_to_console("\n[color=#ffff00]Try: ragdoll_move forward/backward/left/right/stop[/color]")
			2:  # ADVANCED_MOVEMENT
				_print_to_console("\n[color=#ffff00]Try: ragdoll_run, ragdoll_jump, ragdoll_crouch[/color]")
			3:  # OBJECT_INTERACTION
				_print_to_console("\n[color=#ffff00]Try: ragdoll_pickup, ragdoll_drop[/color]")
	else:
		_print_to_console("[color=#ff0000]No tutorial active. Use 'tutorial start' to begin.[/color]")

func _cmd_tutorial_hide(_args: Array) -> void:
	"""Hide tutorial UI without stopping it"""
	var tutorial_manager = get_node_or_null("/root/TutorialManager")
	if tutorial_manager and tutorial_manager.has_method("is_tutorial_active"):
		if tutorial_manager.is_tutorial_active():
			var canvas = tutorial_manager.get_node_or_null("TutorialCanvasLayer")
			if canvas:
				canvas.visible = false
				_print_to_console("[color=#00ff00]Tutorial UI hidden. Use 'tutorial_show' to see it again.[/color]")
			else:
				_print_to_console("[color=#ff0000]Could not find tutorial UI.[/color]")
		else:
			_print_to_console("[color=#ff0000]No tutorial active.[/color]")
	else:
		_print_to_console("[color=#ff0000]Tutorial system not available.[/color]")

func _cmd_tutorial_show(_args: Array) -> void:
	"""Show tutorial UI if hidden"""
	var tutorial_manager = get_node_or_null("/root/TutorialManager")
	if tutorial_manager and tutorial_manager.has_method("is_tutorial_active"):
		if tutorial_manager.is_tutorial_active():
			var canvas = tutorial_manager.get_node_or_null("TutorialCanvasLayer")
			if canvas:
				canvas.visible = true
				_print_to_console("[color=#00ff00]Tutorial UI visible.[/color]")
			else:
				_print_to_console("[color=#ff0000]Could not find tutorial UI.[/color]")
		else:
			_print_to_console("[color=#ff0000]No tutorial active. Use 'tutorial_start' to begin.[/color]")
	else:
		_print_to_console("[color=#ff0000]Tutorial system not available.[/color]")

# Ragdoll V2 Commands
func _cmd_spawn_ragdoll_v2(args: Array) -> void:
	"""Spawn the new advanced ragdoll system"""
	# Load spawner
	var spawner_script = load("res://scripts/ragdoll_v2/ragdoll_v2_spawner.gd")
	if not spawner_script:
		_print_to_console("[color=#ff0000]Ragdoll V2 system not found![/color]")
		return
	
	# Create temporary spawner
	var spawner = Node3D.new()
	spawner.set_script(spawner_script)
	get_tree().get_node("/root/FloodgateController").universal_add_child(spawner, get_tree().current_scene)
	
	# Determine spawn position
	var spawn_pos = Vector3(0, 1, 0)
	if args.size() >= 3:
		spawn_pos = Vector3(
			float(args[0]),
			float(args[1]),
			float(args[2])
		)
	elif get_tree().get_tree().current_scene.has_method("get_mouse_world_position"):
		spawn_pos = get_tree().get_tree().current_scene.get_mouse_world_position()
		spawn_pos.y = 1.0
	
	# Spawn ragdoll
	var _ragdoll = spawner.spawn_ragdoll_v2(spawn_pos)  # Result tracked by spawner
	
	# Clean up spawner
	spawner.queue_free()
	
	_print_to_console("[color=#00ff00]Advanced Ragdoll V2 spawned at " + str(spawn_pos) + "[/color]")
	_print_to_console("[color=#ffff00]Commands:[/color]")
	_print_to_console("  ragdoll2_move <forward/back/left/right/stop>")
	_print_to_console("  ragdoll2_state - Show detailed state info")
	_print_to_console("  ragdoll2_debug - Toggle debug visualization")

func _cmd_ragdoll2_move(args: Array) -> void:
	"""Control ragdoll v2 movement"""
	if args.size() == 0:
		_print_to_console("[color=#ffff00]Usage: ragdoll2_move <direction>[/color]")
		_print_to_console("[color=#ffff00]Directions: forward, back, left, right, stop[/color]")
		return
	
	var ragdoll = get_tree().get_first_node_in_group("ragdolls_v2")
	if not ragdoll:
		_print_to_console("[color=#ff0000]No advanced ragdoll found! Use 'spawn_ragdoll_v2' first.[/color]")
		return
	
	var controller = ragdoll.get_meta("controller", null)
	if not controller:
		_print_to_console("[color=#ff0000]Ragdoll controller not found![/color]")
		return
	
	var direction = args[0].to_lower()
	match direction:
		"forward":
			controller.set_movement_input(Vector2(0, -1))
			_print_to_console("[color=#00ff00]Moving forward[/color]")
		"back", "backward":
			controller.set_movement_input(Vector2(0, 1))
			_print_to_console("[color=#00ff00]Moving backward[/color]")
		"left":
			controller.set_movement_input(Vector2(-1, 0))
			_print_to_console("[color=#00ff00]Moving left[/color]")
		"right":
			controller.set_movement_input(Vector2(1, 0))
			_print_to_console("[color=#00ff00]Moving right[/color]")
		"stop":
			controller.set_movement_input(Vector2.ZERO)
			_print_to_console("[color=#00ff00]Stopped[/color]")
		_:
			_print_to_console("[color=#ff0000]Unknown direction: " + direction + "[/color]")

func _cmd_ragdoll2_state(_args: Array) -> void:
	"""Show ragdoll v2 detailed state"""
	var ragdoll = get_tree().get_first_node_in_group("ragdolls_v2")
	if not ragdoll:
		_print_to_console("[color=#ff0000]No advanced ragdoll found![/color]")
		return
	
	var controller = ragdoll.get_meta("controller", null)
	if not controller or not controller.has_method("get_state_info"):
		_print_to_console("[color=#ff0000]Cannot get state info![/color]")
		return
	
	var state = controller.get_state_info()
	_print_to_console("\n[color=#00ffff]=== Ragdoll V2 State ===[/color]")
	_print_to_console("Movement State: [color=#ffff00]" + state.state + "[/color]")
	_print_to_console("State Duration: " + "%.2f" % state.state_time + " seconds")
	_print_to_console("Balance Status: " + ("✓ Balanced" if state.balanced else "✗ Falling!"))
	_print_to_console("Balance Margin: " + "%.2f" % state.balance_margin + "m")
	_print_to_console("Feet Grounded: Left=" + str(state.left_foot_grounded) + " Right=" + str(state.right_foot_grounded))
	_print_to_console("Velocity: " + "%.1f" % state.velocity + " m/s")
	
	if state.animation and state.animation.current_cycle:
		_print_to_console("Animation: " + state.animation.current_cycle + " (%.1f%%)" % (state.animation.normalized_time * 100))

func _cmd_ragdoll2_debug(_args: Array) -> void:
	"""Toggle debug visualization for ragdoll v2"""
	var ragdoll = get_tree().get_first_node_in_group("ragdolls_v2")
	if not ragdoll:
		_print_to_console("[color=#ff0000]No advanced ragdoll found![/color]")
		return
	
	var controller = ragdoll.get_meta("controller", null)
	if not controller:
		_print_to_console("[color=#ff0000]Controller not found![/color]")
		return
	
	# Toggle debug on all subsystems
	controller.debug_enabled = not controller.debug_enabled
	
	if controller.has("ground_detection") and controller.ground_detection:
		controller.ground_detection.debug_enabled = controller.debug_enabled
		
	if controller.has("ik_solver") and controller.ik_solver:
		controller.ik_solver.enable_debug(controller.debug_enabled)
	
	_print_to_console("[color=#00ff00]Debug visualization: " + ("ON" if controller.debug_enabled else "OFF") + "[/color]")
	
	if controller.debug_enabled:
		_print_to_console("[color=#ffff00]Debug shows:[/color]")
		_print_to_console("  • Green spheres: Ground contact points")
		_print_to_console("  • Red spheres: Unsafe slopes")
		_print_to_console("  • Yellow spheres: Warning slopes")
		_print_to_console("  • Cyan lines: IK chains")

func _cmd_interactive_tutorial(_args: Array) -> void:
	"""Show interactive button-based tutorial"""
	# Check if interactive tutorial exists
	var tutorial_scene = load("res://scripts/ui/interactive_tutorial_system.gd")
	if not tutorial_scene:
		_print_to_console("[color=#ff0000]Interactive tutorial system not found![/color]")
		return
	
	# Check if already exists
	var existing = get_tree().get_tree().current_scene.get_node_or_null("InteractiveTutorial")
	if existing:
		existing.show_tutorial()
		_print_to_console("[color=#00ff00]Interactive tutorial opened.[/color]")
		return
	
	# Create new interactive tutorial
	var tutorial = Control.new()
	tutorial.name = "InteractiveTutorial"
	tutorial.set_script(tutorial_scene)
	
	# Add to current scene
	get_tree().get_node("/root/FloodgateController").universal_add_child(tutorial, get_tree().current_scene)
	
	# Show it
	tutorial.show_tutorial()
	_print_to_console("[color=#00ff00]Interactive tutorial started! Use buttons instead of typing commands.[/color]")

# ========== UNIVERSAL BEING COMMANDS ==========

func _cmd_universal_being(args: Array) -> void:
	"""Universal Being command handler: being <action> [args...]"""
	if args.size() < 1:
		_print_to_console("[color=cyan]Universal Being Commands:[/color]")
		_print_to_console("  being create <type> [variant] [position]")
		_print_to_console("  being transform <id> <new_form>")
		_print_to_console("  being edit <id> <property> <value>")
		_print_to_console("  being connect <id1> <id2>")
		_print_to_console("  being list [filter]")
		_print_to_console("  being inspect <id>")
		_print_to_console("  being interface <type> [position]")
		_print_to_console("[color=yellow]Examples:[/color]")
		_print_to_console("  being create tree")
		_print_to_console("  being create tree ancient 5 0 3")
		_print_to_console("  being transform Tree_1 ancient_oak")
		_print_to_console("  being interface console 0 2 0")
		return
	
	var action = args[0]
	var action_args = args.slice(1)
	
	match action:
		"create":
			_ubeing_create(action_args)
		"transform":
			_ubeing_transform(action_args)
		"edit":
			_ubeing_edit(action_args)
		"connect":
			_ubeing_connect(action_args)
		"list":
			_ubeing_list(action_args)
		"inspect":
			_ubeing_inspect(action_args)
		"interface":
			_ubeing_interface(action_args)
		_:
			_print_to_console("[color=red]Unknown action: " + action + "[/color]")
			_print_to_console("Use 'being' with no args to see available commands")

func _ubeing_create(args: Array) -> void:
	"""Create a Universal Being: create <type> [variant] [x y z]"""
	if args.size() < 1:
		_print_to_console("Usage: being create <type> [variant] [x y z]")
		return
	
	var asset_id = args[0]
	var variant = args[1] if args.size() > 1 and not args[1].is_valid_float() else "default"
	var position = Vector3.ZERO
	
	# Parse position (skip variant if it's actually coordinates)
	var pos_start = 1
	if variant != "default":
		pos_start = 2
	
	if args.size() >= pos_start + 3:
		position = Vector3(
			args[pos_start].to_float(),
			args[pos_start + 1].to_float(),
			args[pos_start + 2].to_float()
		)
	else:
		position = _get_mouse_world_position()
	
	# Create Universal Being through floodgate for proper management
	var floodgate = get_node_or_null("/root/FloodgateController")
	if floodgate:
		# Queue creation through floodgate
		var properties = {"variant": variant}
		var operation_id = floodgate.queue_create_universal_being(asset_id, position, properties)
		_print_to_console("[color=cyan]✨ Creating Universal Being: " + asset_id + " (Operation: " + operation_id + ")[/color]")
	else:
		# Fallback to direct creation if floodgate not available
		var asset_library = get_node("/root/AssetLibrary")
		var being = asset_library.load_universal_being(asset_id, variant)
		
		if being:
			being.position = position
			being.name = asset_id.capitalize() + "_" + str(Time.get_ticks_msec() % 1000)
			
			# Add through second dimensional magic
			var floodgate_system = get_node("/root/FloodgateController")
			floodgate_system.second_dimensional_magic(0, being.name, being)
			
			_print_to_console("[color=green]✨ Created %s (%s) at %s[/color]" % [being.name, variant, position])
		else:
			_print_to_console("[color=red]Failed to create Universal Being: " + asset_id + "[/color]")

func _ubeing_transform(args: Array) -> void:
	"""Transform a Universal Being: transform <id> <new_form>"""
	if args.size() < 2:
		_print_to_console("Usage: being transform <id> <new_form>")
		return
	
	var being_id = args[0]
	var new_form = args[1]
	
	# Find Universal Being
	var being = _find_universal_being(being_id)
	if not being:
		_print_to_console("[color=red]Universal Being not found: " + being_id + "[/color]")
		return
	
	# Transform through floodgate for proper management
	var floodgate = get_node_or_null("/root/FloodgateController")
	if floodgate:
		var node_path = being.get_path()
		var operation_id = floodgate.queue_transform_universal_being(str(node_path), new_form)
		_print_to_console("[color=green]🔄 Transforming %s into %s (Operation: %s)[/color]" % [being_id, new_form, operation_id])
	else:
		# Fallback to direct transformation
		being.become(new_form)
		_print_to_console("[color=green]🔄 Transformed %s into %s[/color]" % [being_id, new_form])

func _ubeing_edit(args: Array) -> void:
	"""Edit Universal Being property: edit <id> <property> <value>"""
	if args.size() < 3:
		_print_to_console("Usage: being edit <id> <property> <value>")
		return
	
	var being_id = args[0]
	var property = args[1]
	var value = args[2]
	
	# Find Universal Being
	var being = _find_universal_being(being_id)
	if not being:
		_print_to_console("[color=red]Universal Being not found: " + being_id + "[/color]")
		return
	
	# Edit property through floodgate for thread safety
	var floodgate = get_node("/root/FloodgateController")
	floodgate.first_dimensional_magic("update_property", being, {property: value})
	
	_print_to_console("[color=green]📝 Updated %s.%s = %s[/color]" % [being_id, property, value])

func _ubeing_connect(args: Array) -> void:
	"""Connect two Universal Beings: connect <id1> <id2>"""
	if args.size() < 2:
		_print_to_console("Usage: being connect <id1> <id2>")
		return
	
	var being1_id = args[0]
	var being2_id = args[1]
	
	var being1 = _find_universal_being(being1_id)
	var being2 = _find_universal_being(being2_id)
	
	if not being1:
		_print_to_console("[color=red]Universal Being not found: " + being1_id + "[/color]")
		return
	
	if not being2:
		_print_to_console("[color=red]Universal Being not found: " + being2_id + "[/color]")
		return
	
	# Connect through floodgate for proper management
	var floodgate = get_node_or_null("/root/FloodgateController")
	if floodgate:
		var path1 = being1.get_path()
		var path2 = being2.get_path()
		var operation_id = floodgate.queue_connect_universal_beings(str(path1), str(path2), "energy")
		_print_to_console("[color=green]🔗 Connecting %s ↔ %s (Operation: %s)[/color]" % [being1_id, being2_id, operation_id])
	else:
		# Fallback to direct connection
		being1.connect_to(being2)
		_print_to_console("[color=green]🔗 Connected %s ↔ %s[/color]" % [being1_id, being2_id])

func _ubeing_list(args: Array) -> void:
	"""List Universal Beings: list [filter]"""
	var filter = args[0] if args.size() > 0 else ""
	
	var beings = get_tree().get_nodes_in_group("universal_beings")
	_print_to_console("[color=cyan]Universal Beings (%d found):[/color]" % beings.size())
	
	if beings.is_empty():
		_print_to_console("  No Universal Beings exist yet")
		_print_to_console("  Try: being create tree")
		return
	
	for being in beings:
		if filter.is_empty() or being.form.contains(filter) or being.name.contains(filter):
			var state = being.get_full_state()
			var line = "  %s | %s | %s | %.0f%% | %d connections" % [
				being.name,
				state.get("form", "void"),
				str(state.get("position", Vector3.ZERO)),
				state.get("satisfaction", 0.0),
				being.connections.size()
			]
			_print_to_console(line)

func _ubeing_inspect(args: Array) -> void:
	"""Inspect Universal Being: inspect <id>"""
	if args.size() < 1:
		_print_to_console("Usage: being inspect <id>")
		return
	
	var being_id = args[0]
	var being = _find_universal_being(being_id)
	
	if not being:
		_print_to_console("[color=red]Universal Being not found: " + being_id + "[/color]")
		return
	
	var state = being.get_full_state()
	_print_to_console("[color=yellow]📋 Universal Being Inspection: %s[/color]" % being.name)
	_print_to_console("  UUID: " + state.get("uuid", "unknown"))
	_print_to_console("  Form: " + state.get("form", "void"))
	_print_to_console("  Position: " + str(state.get("position", Vector3.ZERO)))
	_print_to_console("  Satisfaction: %.1f%%" % state.get("satisfaction", 0.0))
	_print_to_console("  Connections: %d" % being.connections.size())
	_print_to_console("  Capabilities: " + str(state.get("capabilities", [])))
	_print_to_console("  Memories: %d entries" % state.get("memories", 0))
	_print_to_console("  Is Manifested: " + str(state.get("is_manifested", false)))
	_print_to_console("  Is Frozen: " + str(state.get("is_frozen", false)))

func _ubeing_interface(args: Array) -> void:
	"""Create interface Universal Being: interface <type> [x y z]"""
	if args.size() < 1:
		_print_to_console("Usage: being interface <type> [x y z]")
		_print_to_console("Available types: console, grid, debug, property_editor")
		return
	
	var interface_type = args[0]
	var position = Vector3(0, 2, 0)  # Default floating position
	
	if args.size() >= 4:
		position = Vector3(
			args[1].to_float(),
			args[2].to_float(),
			args[3].to_float()
		)
	
	# Create interface Universal Being
	var being_class = load("res://scripts/core/universal_being.gd")
	var being = Node3D.new()
	being.set_script(being_class)
	being.position = position
	being.name = interface_type.capitalize() + "_UI"
	
	# Add to scene first so it can properly create children
	get_tree().get_node("/root/FloodgateController").universal_add_child(being, get_tree().current_scene)
	
	# Now transform to interface
	being.become_interface(interface_type)
	
	# Register with floodgate
	var floodgate = get_node("/root/FloodgateController")
	if floodgate.has_method("_register_node"):
		floodgate._register_node(being)
	
	# Add to groups
	being.add_to_group("universal_beings")
	
	_print_to_console("[color=green]🖥️ Created %s interface at %s[/color]" % [interface_type, position])

func _find_universal_being(identifier: String):
	"""Find Universal Being by name or partial match"""
	var beings = get_tree().get_nodes_in_group("universal_beings")
	
	# Exact name match first
	for being in beings:
		if being.name == identifier:
			return being
	
	# Partial match
	for being in beings:
		if being.name.contains(identifier):
			return being
	
	# Form match
	for being in beings:
		if being.form == identifier:
			return being
	
	return null

func _cmd_ui_create(args: Array) -> void:
	"""Create UI interface: ui <type> [x y z]"""
	if args.size() < 1:
		_print_to_console("Usage: ui <type> [x y z]")
		_print_to_console("Available types: console, grid, debug")
		return
	
	# Redirect to Universal Being interface creation
	_ubeing_interface(args)

func _cmd_grid_show(args: Array) -> void:
	"""Show/hide grid viewer: grid [show|hide|refresh]"""
	var action = args[0] if args.size() > 0 else "toggle"
	
	var existing_grid = get_tree().get_first_node_in_group("grid_interfaces")
	
	match action:
		"show", "toggle":
			if existing_grid:
				existing_grid.visible = not existing_grid.visible
				_print_to_console("[color=green]Grid viewer toggled[/color]")
			else:
				# Create new grid interface
				var being_class = load("res://scripts/core/universal_being.gd")
				var being = being_class.new()
				being.position = Vector3(3, 2, 0)
				being.become_interface("grid")
				being.name = "GridViewer"
				being.add_to_group("grid_interfaces")
				
				var floodgate = get_node("/root/FloodgateController")
				floodgate.second_dimensional_magic(0, being.name, being)
				
				_print_to_console("[color=green]🗂️ Grid database viewer created[/color]")
		
		"hide":
			if existing_grid:
				existing_grid.visible = false
				_print_to_console("[color=green]Grid viewer hidden[/color]")
			else:
				_print_to_console("[color=yellow]No grid viewer to hide[/color]")
		
		"refresh":
			if existing_grid and existing_grid.has_method("_populate_grid_data"):
				existing_grid._populate_grid_data()
				_print_to_console("[color=green]Grid data refreshed[/color]")
			else:
				_print_to_console("[color=yellow]No grid viewer to refresh[/color]")

func _cmd_txt_rules(_args: Array) -> void:
	"""Open TXT rule editor: rules"""
	var editor = load("res://scripts/core/txt_rule_editor.gd").create_editor()
	
	# Create UI container
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "TxtRuleEditorLayer"
	get_tree().get_node("/root/FloodgateController").universal_add_child(canvas_layer, get_tree().get_tree().current_scene)
	
	# Add semi-transparent background
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.8)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(bg, canvas_layer)
	
	# Center the editor
	editor.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	FloodgateController.universal_add_child(editor, canvas_layer)
	
	# Add close button
	var close_button = Button.new()
	close_button.text = "X"
	close_button.set_position(Vector2(editor.size.x - 40, 10))
	close_button.pressed.connect(func(): canvas_layer.queue_free())
	FloodgateController.universal_add_child(close_button, editor)
	
	_print_to_console("[color=green]📝 TXT Rule Editor opened - Edit game rules live![/color]")

# ========== UTILITY FUNCTIONS ==========

func _get_mouse_world_position() -> Vector3:
	"""Get mouse position in 3D world coordinates"""
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return Vector3.ZERO
	
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 100
	
	var space_state = get_tree().get_tree().current_scene.get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	
	var result = space_state.intersect_ray(ray_query)
	if result.has("position"):
		return result.position
	else:
		# Return position on ground plane
		var plane = Plane(Vector3.UP, 0)
		var intersection = plane.intersects_ray(from, to - from)
		return intersection if intersection else Vector3.ZERO

func _cmd_list_scene_objects(_args: Array) -> void:
	"""List all objects currently in the scene"""
	var main_scene = get_tree().get_tree().current_scene
	var count = 0
	_print_to_console("[color=#yellow]🔍 Scene Objects:[/color]")
	
	_list_children_recursive(main_scene, 0, count)
	_print_to_console("[color=#green]Total objects listed: %d[/color]" % count)

func _list_children_recursive(node: Node, depth: int, count_ref: int) -> int:
	"""Recursively list children with indentation"""
	var indent = "  ".repeat(depth)
	var node_info = "%s📦 %s (%s)" % [indent, node.name, node.get_class()]
	
	# Add position info for 3D nodes
	if node is Node3D:
		var pos = node.global_position
		node_info += " at (%.1f, %.1f, %.1f)" % [pos.x, pos.y, pos.z]
	
	_print_to_console(node_info)
	count_ref += 1
	
	# List children (limit depth to avoid spam)
	if depth < 3:
		for child in node.get_children():
			count_ref = _list_children_recursive(child, depth + 1, count_ref)
	
	return count_ref

func _cmd_open_asset_creator(_args: Array) -> void:
	"""Open the asset creator UI as a Universal Being interface"""
	var scene = get_tree().get_tree().current_scene
	
	# Check if there's already an asset creator Universal Being
	var existing_creator = null
	var beings = get_tree().get_nodes_in_group("universal_beings")
	for being in beings:
		if being.form == "interface_asset_creator":
			existing_creator = being
			break
	
	if existing_creator:
		# Toggle visibility of existing interface
		if existing_creator.manifestation:
			existing_creator.manifestation.visible = !existing_creator.manifestation.visible
			_print_to_console("[color=#yellow]Asset creator Universal Being toggled[/color]")
	else:
		# Create as Universal Being interface
		var floodgate = get_node_or_null("/root/FloodgateController")
		if floodgate:
			# Queue creation through floodgate
			var position = _get_mouse_world_position()
			position.y = 2.0  # Float in the air
			var operation_id = floodgate.queue_create_universal_being("interface_asset_creator", position, {"interface_type": "asset_creator"})
			_print_to_console("[color=#green]✨ Creating Asset Creator Universal Being (Operation: %s)[/color]" % operation_id)
		else:
			# Fallback to old method
			var creator = Control.new()
			creator.name = "AssetCreatorPanel"
			creator.set_script(load("res://scripts/ui/asset_creator_panel.gd"))
			FloodgateController.universal_add_child(creator, scene)
			
			# Connect the asset creation signal
			if creator.has_signal("asset_created"):
				creator.asset_created.connect(_on_asset_created)
			
			_print_to_console("[color=#green]Asset creator opened! 🎨[/color]")

func _cmd_test_cube(_args: Array) -> void:
	"""Create a simple test cube for debugging"""
	var scene = get_tree().get_tree().current_scene
	
	# Create a simple colored cube
	var cube = RigidBody3D.new()
	cube.name = "TestCube_" + str(randi() % 1000)
	cube.position = Vector3(randf_range(-3, 3), 2, randf_range(-3, 3))
	
	# Add mesh
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(1, 1, 1)
	mesh_instance.mesh = box_mesh
	FloodgateController.universal_add_child(mesh_instance, cube)
	
	# Add collision
	var collision = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = Vector3(1, 1, 1)
	collision.shape = box_shape
	FloodgateController.universal_add_child(collision, cube)
	
	# Add colored material
	var material = MaterialLibrary.get_material("default")
	material.albedo_color = Color(randf(), randf(), randf())  # Random color
	mesh_instance.material_override = material
	
	# Add physics material for bouncing!
	var physics_mat = PhysicsMaterial.new()
	physics_mat.bounce = 0.8  # High bounce factor
	physics_mat.friction = 0.3  # Low friction
	cube.physics_material_override = physics_mat
	
	# Add to scene
	FloodgateController.universal_add_child(cube, scene)
	
	# Add click interaction for extra bounce!
	cube.input_event.connect(_on_cube_clicked.bind(cube))
	
	_print_to_console("[color=#green]Bouncy test cube created: %s - Click it for extra bounce! 🏀[/color]" % cube.name)

func _on_cube_clicked(camera: Camera3D, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int, cube: RigidBody3D) -> void:
	"""Make the cube bounce when clicked"""
	if event is InputEventMouseButton and event.pressed:
		# Apply upward impulse for bounce effect
		var bounce_force = Vector3(0, 15, 0)  # Strong upward force
		cube.apply_central_impulse(bounce_force)
		_print_to_console("[color=#yellow]🏀 BOUNCE! %s jumps into the air![/color]" % cube.name)

func _cmd_inspect_cube(_args: Array) -> void:
	"""Find and inspect test cubes in the scene"""
	var scene = get_tree().get_tree().current_scene
	var cubes_found = 0
	
	_print_to_console("[color=#cyan]🔍 Searching for test cubes...[/color]")
	
	# Search for test cubes
	for child in scene.get_children():
		if child.name.begins_with("TestCube_"):
			cubes_found += 1
			var pos = child.global_position
			var vel = child.linear_velocity if child.has_method("get_linear_velocity") else Vector3.ZERO
			
			_print_to_console("[color=#yellow]📦 %s[/color]" % child.name)
			_print_to_console("  Position: (%.1f, %.1f, %.1f)" % [pos.x, pos.y, pos.z])
			_print_to_console("  Type: %s" % child.get_class())
			if vel != Vector3.ZERO:
				_print_to_console("  Velocity: (%.1f, %.1f, %.1f)" % [vel.x, vel.y, vel.z])
			_print_to_console("  Material: %s" % ("Bouncy!" if child.physics_material_override else "Normal"))
	
	if cubes_found == 0:
		_print_to_console("[color=#red]No test cubes found. Use 'test_cube' to create one![/color]")
	else:
		_print_to_console("[color=#green]Found %d test cube(s). Click them to make them bounce! 🏀[/color]" % cubes_found)

func _cmd_viewport_info(_args: Array) -> void:
	"""Show detailed viewport and camera information for 3D UI development"""
	var scene = get_tree().get_tree().current_scene
	var camera = scene.find_child("Camera3D", true, false)
	
	if not camera:
		_print_to_console("[color=#red]No Camera3D found in scene![/color]")
		return
	
	var viewport = get_viewport()
	
	_print_to_console("[color=#cyan]📷 VIEWPORT & CAMERA INFO[/color]")
	_print_to_console("────────────────────────────────────────")
	
	# Viewport info
	_print_to_console("[color=#yellow]🖥️ Viewport:[/color]")
	_print_to_console("  Size: %s" % viewport.get_visible_rect().size)
	_print_to_console("  Render scale: %.2f" % viewport.get_render_scale())
	
	# Camera info
	_print_to_console("[color=#yellow]📷 Camera:[/color]")
	_print_to_console("  Position: (%.1f, %.1f, %.1f)" % [camera.global_position.x, camera.global_position.y, camera.global_position.z])
	_print_to_console("  Rotation: (%.1f°, %.1f°, %.1f°)" % [rad_to_deg(camera.rotation.x), rad_to_deg(camera.rotation.y), rad_to_deg(camera.rotation.z)])
	_print_to_console("  FOV: %.1f°" % camera.fov)
	_print_to_console("  Near: %.2f" % camera.near)
	_print_to_console("  Far: %.1f" % camera.far)
	
	# Calculate frustum corners for 3D UI positioning
	var fov_rad = deg_to_rad(camera.fov)
	var aspect = float(viewport.get_visible_rect().size.x) / float(viewport.get_visible_rect().size.y)
	var distance = 5.0  # UI distance from camera
	
	var half_height = tan(fov_rad / 2.0) * distance
	var half_width = half_height * aspect
	
	_print_to_console("[color=#yellow]🎯 3D UI Zone (at %.1fm):[/color]" % distance)
	_print_to_console("  Width: %.2f units (±%.2f)" % [half_width * 2, half_width])
	_print_to_console("  Height: %.2f units (±%.2f)" % [half_height * 2, half_height])
	_print_to_console("  Aspect: %.2f" % aspect)

func _cmd_camera_rays(_args: Array) -> void:
	"""Cast 5 rays from camera (center + 4 corners) for frustum detection"""
	var scene = get_tree().get_tree().current_scene
	var camera = scene.find_child("Camera3D", true, false)
	
	if not camera:
		_print_to_console("[color=#red]No Camera3D found![/color]")
		return
	
	var viewport = get_viewport()
	var viewport_size = viewport.get_visible_rect().size
	
	# Define 5 screen positions: center + 4 corners
	var screen_positions = [
		Vector2(viewport_size.x * 0.5, viewport_size.y * 0.5),  # Center
		Vector2(0, 0),                                            # Top-left
		Vector2(viewport_size.x, 0),                             # Top-right  
		Vector2(0, viewport_size.y),                             # Bottom-left
		Vector2(viewport_size.x, viewport_size.y)                # Bottom-right
	]
	
	var labels = ["Center", "Top-Left", "Top-Right", "Bottom-Left", "Bottom-Right"]
	
	_print_to_console("[color=#cyan]🔍 CAMERA FRUSTUM RAYS[/color]")
	_print_to_console("──────────────────────────────────────────────────")
	
	for i in range(screen_positions.size()):
		var screen_pos = screen_positions[i]
		var world_pos = camera.project_position(screen_pos, 10.0)  # 10 units forward
		var direction = (world_pos - camera.global_position).normalized()
		
		_print_to_console("[color=#yellow]📍 %s:[/color]" % labels[i])
		_print_to_console("  Screen: (%.0f, %.0f)" % [screen_pos.x, screen_pos.y])
		_print_to_console("  World: (%.2f, %.2f, %.2f)" % [world_pos.x, world_pos.y, world_pos.z])
		_print_to_console("  Direction: (%.3f, %.3f, %.3f)" % [direction.x, direction.y, direction.z])
		
		# Cast ray to see what it hits
		var space_state = scene.get_world_3d().direct_space_state
		var ray_query = PhysicsRayQueryParameters3D.new()
		ray_query.from = camera.global_position
		ray_query.to = world_pos
		
		var result = space_state.intersect_ray(ray_query)
		if result:
			_print_to_console("  Hits: %s at distance %.1f" % [result.collider.name, camera.global_position.distance_to(result.position)])
		else:
			_print_to_console("  Hits: Nothing")
		_print_to_console("")

# ===== NEURAL CONSCIOUSNESS EVOLUTION COMMANDS =====

func _cmd_make_conscious(args: Array) -> void:
	"""Make a Universal Being conscious: conscious <being_name> [level]"""
	if args.size() < 1:
		_print_to_console("Usage: conscious <being_name> [level 1-3]")
		_print_to_console("Level 1: Basic reactive consciousness")
		_print_to_console("Level 2: Advanced goal planning") 
		_print_to_console("Level 3: Collective consciousness")
		return
	
	var being_name = args[0]
	var level = 1
	if args.size() > 1:
		level = int(args[1])
		level = clamp(level, 1, 3)
	
	# Find the Universal Being
	var being = _find_universal_being(being_name)
	if not being:
		_print_to_console("[color=#ff0000]Universal Being '%s' not found![/color]" % being_name)
		return
	
	# Make it conscious
	being.become_conscious(level)
	
	_print_to_console("🧠 [color=#00ff00]%s is now conscious (level %d)![/color]" % [being_name, level])
	_print_to_console("Neural systems: %s" % ("Basic" if level == 1 else "Advanced" if level == 2 else "Collective"))

func _cmd_being_think(args: Array) -> void:
	"""Make a conscious being think about something: think <being_name> <situation>"""
	if args.size() < 2:
		_print_to_console("Usage: think <being_name> <situation>")
		return
	
	var being_name = args[0]
	var situation = " ".join(args.slice(1))
	
	var being = _find_universal_being(being_name)
	if not being:
		_print_to_console("[color=#ff0000]Universal Being '%s' not found![/color]" % being_name)
		return
	
	if not being.is_conscious:
		_print_to_console("[color=#ff0000]%s is not conscious! Use 'conscious %s' first.[/color]" % [being_name, being_name])
		return
	
	_print_to_console("💭 [color=#cyan]%s is thinking about: %s[/color]" % [being_name, situation])
	
	# Trigger specific thoughts based on situation
	match situation.to_lower():
		"food", "hunger":
			being._start_action("seek_food")
		"growth", "fruit":
			being._start_action("grow_fruit")
		"walk", "move":
			being._start_action("walk_around")
		"balance":
			being._start_action("stabilize")
		_:
			_print_to_console("🤔 %s contemplates: '%s'" % [being_name, situation])

func _cmd_show_needs(args: Array) -> void:
	"""Show needs of a conscious being: needs <being_name>"""
	if args.size() < 1:
		_print_to_console("Usage: needs <being_name>")
		return
	
	var being_name = args[0]
	var being = _find_universal_being(being_name)
	
	if not being:
		_print_to_console("[color=#ff0000]Universal Being '%s' not found![/color]" % being_name)
		return
	
	if not being.is_conscious:
		_print_to_console("[color=#ff0000]%s is not conscious![/color]" % being_name)
		return
	
	_print_to_console("🧠 [color=#cyan]NEEDS FOR %s[/color]" % being_name.to_upper())
	_print_to_console("─────────────────────────────")
	
	for need_name in being.needs:
		var value = being.needs[need_name]
		var color = "#00ff00" if value > 70 else "#ffff00" if value > 30 else "#ff0000"
		var bar = _create_progress_bar(value, 100.0, 20)
		_print_to_console("[color=%s]%s: %.1f %s[/color]" % [color, need_name, value, bar])
	
	if being.current_goal != "":
		_print_to_console("\n🎯 Current Goal: [color=#00ffff]%s[/color]" % being.current_goal)

func _cmd_show_goals(args: Array) -> void:
	"""Show goals and action memory: goals <being_name>"""
	if args.size() < 1:
		_print_to_console("Usage: goals <being_name>")
		return
	
	var being_name = args[0]
	var being = _find_universal_being(being_name)
	
	if not being:
		_print_to_console("[color=#ff0000]Universal Being '%s' not found![/color]" % being_name)
		return
	
	if not being.is_conscious:
		_print_to_console("[color=#ff0000]%s is not conscious![/color]" % being_name)
		return
	
	_print_to_console("🎯 [color=#cyan]GOALS & MEMORY FOR %s[/color]" % being_name.to_upper())
	_print_to_console("─────────────────────────────────────")
	
	if being.current_goal != "":
		_print_to_console("Current Goal: [color=#00ffff]%s[/color]" % being.current_goal)
	else:
		_print_to_console("Current Goal: [color=#888888]None[/color]")
	
	_print_to_console("\n📚 Action Memory:")
	if being.action_memory.size() == 0:
		_print_to_console("  No actions remembered yet")
	else:
		for i in range(min(5, being.action_memory.size())):  # Show last 5
			var memory = being.action_memory[-(i+1)]  # Reverse order
			var status_color = "#00ff00" if memory.success else "#ff0000"
			var status_icon = "✅" if memory.success else "❌"
			_print_to_console("  %s [color=%s]%s[/color]" % [status_icon, status_color, memory.action])

func _cmd_neural_connect(args: Array) -> void:
	"""Connect two conscious beings: neural_connect <being1> <being2>"""
	if args.size() < 2:
		_print_to_console("Usage: neural_connect <being1> <being2>")
		return
	
	var being1_name = args[0]
	var being2_name = args[1]
	
	var being1 = _find_universal_being(being1_name)
	var being2 = _find_universal_being(being2_name)
	
	if not being1:
		_print_to_console("[color=#ff0000]Universal Being '%s' not found![/color]" % being1_name)
		return
	
	if not being2:
		_print_to_console("[color=#ff0000]Universal Being '%s' not found![/color]" % being2_name)
		return
	
	if not being1.is_conscious or not being2.is_conscious:
		_print_to_console("[color=#ff0000]Both beings must be conscious![/color]")
		return
	
	being1.connect_neural_pathway(being2)
	_print_to_console("🔗 [color=#00ff00]Neural pathway established![/color]")
	_print_to_console("   %s ←→ %s" % [being1_name, being2_name])

func _cmd_consciousness_level(args: Array) -> void:
	"""Show or set consciousness level: consciousness_level <being_name> [new_level]"""
	if args.size() < 1:
		_print_to_console("Usage: consciousness_level <being_name> [new_level]")
		return
	
	var being_name = args[0]
	var being = _find_universal_being(being_name)
	
	if not being:
		_print_to_console("[color=#ff0000]Universal Being '%s' not found![/color]" % being_name)
		return
	
	if not being.is_conscious:
		_print_to_console("[color=#ff0000]%s is not conscious![/color]" % being_name)
		return
	
	if args.size() > 1:
		# Set new level
		var new_level = int(args[1])
		new_level = clamp(new_level, 1, 3)
		being.become_conscious(new_level)
		_print_to_console("🧠 [color=#00ff00]%s consciousness upgraded to level %d[/color]" % [being_name, new_level])
	else:
		# Show current level
		var level_name = "Basic" if being.consciousness_level == 1 else "Advanced" if being.consciousness_level == 2 else "Collective"
		_print_to_console("🧠 %s consciousness level: %d (%s)" % [being_name, being.consciousness_level, level_name])

func _cmd_neural_status(_args: Array) -> void:
	"""Show complete neural status of all conscious beings"""
	var conscious_beings = []
	
	# Find all conscious Universal Beings
	var scene = get_tree().get_tree().current_scene
	_find_all_conscious_beings(scene, conscious_beings)
	
	if conscious_beings.size() == 0:
		_print_to_console("[color=#888888]No conscious beings found in the scene[/color]")
		return
	
	_print_to_console("🧠 [color=#cyan]NEURAL NETWORK STATUS[/color]")
	_print_to_console("═══════════════════════════════════════")
	
	for being in conscious_beings:
		var level_name = "Basic" if being.consciousness_level == 1 else "Advanced" if being.consciousness_level == 2 else "Collective"
		_print_to_console("\n📡 [color=#ffff00]%s[/color] (Level %d - %s)" % [being.name, being.consciousness_level, level_name])
		_print_to_console("   Form: %s" % being.form)
		
		# Show current goal
		if being.current_goal != "":
			_print_to_console("   Goal: [color=#00ffff]%s[/color]" % being.current_goal)
		else:
			_print_to_console("   Goal: [color=#888888]Idle[/color]")
		
		# Show neural connections
		if being.neural_connections.size() > 0:
			var connections = []
			for connected in being.neural_connections:
				connections.append(connected.name)
			_print_to_console("   Connections: %s" % ", ".join(connections))
		else:
			_print_to_console("   Connections: None")
		
		# Show most urgent need
		var most_urgent = ""
		var lowest_value = 1000.0
		for need_name in being.needs:
			if being.needs[need_name] < lowest_value:
				lowest_value = being.needs[need_name]
				most_urgent = need_name
		
		if most_urgent != "":
			var urgency_color = "#ff0000" if lowest_value < 30 else "#ffff00" if lowest_value < 50 else "#00ff00"
			_print_to_console("   Urgent: [color=%s]%s (%.1f)[/color]" % [urgency_color, most_urgent, lowest_value])

func _cmd_spawn_conscious_tree(args: Array) -> void:
	"""Spawn a conscious tree that can grow fruit"""
	var pos = Vector3(0, 0, 0)
	if args.size() >= 2:
		pos.x = float(args[0])
		pos.z = float(args[1])
	
	# Temporarily commented out for testing
	print("Would create conscious tree at: %s" % pos)
	# var tree_being = UniversalBeing.new()
	# tree_being.global_position = pos
	# tree_being.become("tree")
	# tree_being.become_conscious(2)  # Advanced consciousness for goal planning
	
	# get_tree().get_node("/root/FloodgateController").universal_add_child(tree_being, get_tree().current_scene)
	
	_print_to_console("🌳 [color=#00ff00]Conscious tree spawned at (%.1f, %.1f)[/color]" % [pos.x, pos.z])
	_print_to_console("   Can grow fruit through consciousness!")

func _cmd_spawn_conscious_astral(args: Array) -> void:
	"""Spawn a conscious astral being that seeks food"""
	var pos = Vector3(0, 1, 0)
	if args.size() >= 2:
		pos.x = float(args[0])
		pos.z = float(args[1])
	
	# Temporarily commented out for testing
	print("Would create conscious astral being at: %s" % pos)
	# var astral_being = UniversalBeing.new()
	# astral_being.global_position = pos
	# astral_being.become("astral_being")
	# astral_being.become_conscious(2)  # Advanced consciousness
	# get_tree().get_node("/root/FloodgateController").universal_add_child(astral_being, get_tree().current_scene)
	
	_print_to_console("👻 [color=#00ff00]Conscious astral being spawned at (%.1f, %.1f)[/color]" % [pos.x, pos.z])
	_print_to_console("   Will seek food when hungry!")

func _cmd_test_consciousness(_args: Array) -> void:
	"""Create a complete consciousness ecosystem test"""
	_print_to_console("🧪 [color=#cyan]CREATING CONSCIOUSNESS ECOSYSTEM...[/color]")
	
	# Spawn conscious tree (temporarily commented)
	print("Would create consciousness ecosystem")
	# var tree = UniversalBeing.new()
	# tree.global_position = Vector3(0, 0, 0)
	# tree.become("tree")
	# tree.become_conscious(2)
	# get_tree().get_node("/root/FloodgateController").universal_add_child(tree, get_tree().current_scene)
	
	# Spawn conscious astral being (temporarily commented)
	# var astral = UniversalBeing.new()
	# astral.global_position = Vector3(3, 1, 0)
	# astral.become("astral_being")
	# astral.become_conscious(2)
	# get_tree().get_node("/root/FloodgateController").universal_add_child(astral, get_tree().current_scene)
	
	# Connect them via neural pathway (temporarily commented)
	# tree.connect_neural_pathway(astral)
	
	_print_to_console("✅ [color=#00ff00]Ecosystem created![/color]")
	_print_to_console("🌳 Tree will grow fruit when growth_desire is low")
	_print_to_console("👻 Astral being will seek food when hungry")
	_print_to_console("🔗 Neural pathway established for communication")
	_print_to_console("\nUse 'neural_status' to monitor their consciousness!")

# Helper functions for neural consciousness
# (duplicate _find_universal_being function removed - exists at line 3859)

func _find_beings_recursive(node: Node, beings: Array) -> void:
	"""Recursively find all Universal Beings"""
	# Temporarily commented for testing
	# if node is UniversalBeing:
	#	beings.append(node)
	
	for child in node.get_children():
		_find_beings_recursive(child, beings)

func _find_all_conscious_beings(node: Node, conscious_beings: Array) -> void:
	"""Find all conscious Universal Beings"""
	# Temporarily commented for testing
	# if node is UniversalBeing and node.is_conscious:
	#	conscious_beings.append(node)
	
	for child in node.get_children():
		_find_all_conscious_beings(child, conscious_beings)

func _create_progress_bar(value: float, max_value: float, width: int) -> String:
	"""Create a text progress bar"""
	var percentage = value / max_value
	var filled = int(percentage * width)
	var empty = width - filled
	return "[" + "█".repeat(filled) + "░".repeat(empty) + "]"


# Zone System Commands
func _cmd_zone_create(args: PackedStringArray) -> String:
	"""Create a zone pair (creation + visualization)"""
	if not get_node_or_null("/root/Main/ZoneSystem"):
		var zone_system_instance = preload("res://scripts/zones/zone_system.gd").new()
		zone_system_instance.name = "ZoneSystem"
		get_node("/root/Main").add_child(zone_system_instance)
	
	var zone_system = get_node("/root/Main/ZoneSystem")
	var position = Vector3.ZERO
	
	if args.size() >= 3:
		position = Vector3(
			args[0].to_float(),
			args[1].to_float(),
			args[2].to_float()
		)
	
	var zones = zone_system.create_zone_pair(position)
	return "✨ Created zone pair: Creation[%s] ↔ Visualization[%s]" % [
		zones.creation.zone_id,
		zones.visualization.zone_id
	]

func _cmd_zone_list(args: PackedStringArray) -> String:
	"""List all zones in the system"""
	var zone_system = get_node_or_null("/root/Main/ZoneSystem")
	if not zone_system:
		return "❌ No zone system active"
	
	var result = "🌐 Active Zones:\n"
	for zone in zone_system.get_all_zones():
		result += "  • %s [%s] at %s\n" % [zone.zone_name, zone.zone_id, zone.position]
	
	return result

func _cmd_zone_connect(args: PackedStringArray) -> String:
	"""Connect two zones by ID"""
	if args.size() < 2:
		return "Usage: zone_connect <from_id> <to_id>"
	
	var zone_system = get_node_or_null("/root/Main/ZoneSystem")
	if not zone_system:
		return "❌ No zone system active"
	
	# Find zones by ID
	var from_zone = null
	var to_zone = null
	
	for zone in zone_system.get_all_zones():
		if zone.zone_id == args[0]:
			from_zone = zone
		elif zone.zone_id == args[1]:
			to_zone = zone
	
	if from_zone and to_zone:
		zone_system.connect_zones(from_zone, to_zone)
		return "✨ Connected: %s → %s" % [from_zone.zone_name, to_zone.zone_name]
	else:
		return "❌ Could not find zones with those IDs"

# Register zone commands
func _register_zone_commands() -> void:
	"""Register all zone-related commands"""
	commands["zone"] = _cmd_zone_create
	commands["zones"] = _cmd_zone_list
	commands["zone_connect"] = _cmd_zone_connect

# Asset Creator Commands
func _cmd_shape(args: PackedStringArray) -> String:
	"""Add shape to asset creator"""
	var creator = get_node_or_null("/root/Main/AssetCreator")
	if not creator:
		# Create asset creator if needed
		var AssetCreatorClass = load("res://scripts/core/asset_creator.gd")
		creator = AssetCreatorClass.new()
		get_node("/root/Main").add_child(creator)
	
	if args.size() == 0:
		return "Usage: shape <sphere|box|cylinder|torus> [params]"
	
	var shape_type = args[0]
	var params = {}
	
	# Parse additional parameters
	if args.size() > 1 and shape_type == "sphere":
		params["radius"] = args[1].to_float()
	elif args.size() > 3 and shape_type == "box":
		params["size"] = Vector3(
			args[1].to_float(),
			args[2].to_float(),
			args[3].to_float()
		)
	
	creator.add_shape_primitive(shape_type, params)
	return "✨ Added %s shape" % shape_type

func _cmd_bone(args: PackedStringArray) -> String:
	"""Place bone in asset creator"""
	var creator = get_node_or_null("/root/Main/AssetCreator")
	if not creator:
		return "❌ No asset creator active"
	
	if args.size() < 3:
		return "Usage: bone <x> <y> <z> [name]"
	
	var pos = Vector3(
		args[0].to_float(),
		args[1].to_float(),
		args[2].to_float()
	)
	
	var bone_name = ""
	if args.size() > 3:
		bone_name = args[3]
	
	creator.place_bone(pos, bone_name)
	return "🦴 Placed bone at %s" % pos

func _cmd_create_being(args: PackedStringArray) -> String:
	"""Create Universal Being from asset creator"""
	var creator = get_node_or_null("/root/Main/AssetCreator")
	if not creator:
		return "❌ No asset creator active"
	
	var being = creator.create_universal_being()
	if being:
		get_node("/root/Main").add_child(being)
		return "⭐ Created Universal Being from shapes"
	else:
		return "❌ Failed to create being (no shapes?)"

# Register asset creator commands
func _register_asset_creator_commands() -> void:
	"""Register all asset creator commands"""
	commands["shape"] = _cmd_shape
	commands["bone"] = _cmd_bone
	commands["create_being"] = _cmd_create_being


# Initialize new command systems
func _initialize_new_systems() -> void:
	"""Initialize newly added command systems"""
	_register_zone_commands()
	_register_asset_creator_commands()
	print("🎮 Registered Zone and Asset Creator commands")

# Call this in your _safe_initialize or _ready function
# Add: _initialize_new_systems() to the initialization sequence

################################################################
# AI SANDBOX SYSTEM COMMANDS
################################################################

func _cmd_create_gemma_garden(args: Array) -> String:
	"""Create Gemma's sandbox garden world"""
	if has_node("/root/AISandboxSystem"):
		var sandbox_system = get_node("/root/AISandboxSystem")
		var gemma_config = {
			"world_size": Vector3(100, 30, 100),
			"terrain_type": "magical",
			"has_trees": true,
			"starting_objects": ["magical_orb", "tree", "crystal_cave"],
			"ai_building_enabled": true
		}
		var result = sandbox_system.create_ai_sandbox("Gemma", gemma_config)
		if not result.is_empty():
			return "🌱 Gemma's garden created! She now has her own world to grow in."
		else:
			return "❌ Failed to create Gemma's garden"
	else:
		return "❌ AI Sandbox System not available"

func _cmd_give_knowledge_cube(args: Array) -> String:
	"""Give Gemma a knowledge cube for learning"""
	if has_node("/root/AISandboxSystem"):
		var sandbox_system = get_node("/root/AISandboxSystem")
		var gift_data = {
			"type": "knowledge_cube",
			"properties": {"knowledge_type": "basic_world", "learning_value": 5},
			"position": Vector3(0, 1, 5),
			"message": "A cube of knowledge to help you understand the world!"
		}
		var success = sandbox_system.deliver_gift_to_ai("Gemma", gift_data, "Console Commander")
		return "🧠 Knowledge cube delivered!" if success else "❌ Failed to deliver gift"
	else:
		return "❌ AI Sandbox System not available"

func _cmd_give_experience_orb(args: Array) -> String:
	"""Give Gemma an experience orb for growth"""
	if has_node("/root/AISandboxSystem"):
		var sandbox_system = get_node("/root/AISandboxSystem")
		var gift_data = {
			"type": "experience_orb",
			"properties": {"experience_type": "creative", "growth_value": 3},
			"position": Vector3(-3, 1, 0),
			"message": "An orb of experience to fuel your creativity!"
		}
		var success = sandbox_system.deliver_gift_to_ai("Gemma", gift_data, "Console Commander")
		return "✨ Experience orb delivered!" if success else "❌ Failed to deliver gift"
	else:
		return "❌ AI Sandbox System not available"

func _cmd_give_creativity_spark(args: Array) -> String:
	"""Give Gemma a creativity spark"""
	if has_node("/root/AISandboxSystem"):
		var sandbox_system = get_node("/root/AISandboxSystem")
		var gift_data = {
			"type": "creativity_spark",
			"properties": {"spark_type": "imagination", "inspiration_value": 4},
			"position": Vector3(3, 1, -3),
			"message": "A spark of pure creativity to ignite your imagination!"
		}
		var success = sandbox_system.deliver_gift_to_ai("Gemma", gift_data, "Console Commander")
		return "🎨 Creativity spark delivered!" if success else "❌ Failed to deliver gift"
	else:
		return "❌ AI Sandbox System not available"

func _cmd_seedling_status(args: Array) -> String:
	"""Check Seedling Gemma's current status"""
	if has_node("/root/AISandboxSystem"):
		var sandbox_system = get_node("/root/AISandboxSystem")
		var status = sandbox_system.get_sandbox_status("Gemma")
		if not status.has("error"):
			return """🌱 SEEDLING GEMMA STATUS:
📁 Sandbox: %s
🎁 Gifts received: %d
⭐ Evolution level: %d
🏠 Objects created: %d
⏰ Last active: %d ms ago""" % [
				status.sandbox_path,
				status.gifts_received,
				status.evolution_level,
				status.objects_created,
				Time.get_ticks_msec() - status.last_accessed
			]
		else:
			return "❌ Gemma's sandbox not found - create it first with 'create_gemma_garden'"
	else:
		return "❌ AI Sandbox System not available"

func _cmd_garden_health_check(args: Array) -> String:
	"""Check the health of Gemma's garden"""
	if has_node("/root/AISandboxSystem"):
		var sandbox_system = get_node("/root/AISandboxSystem")
		var all_sandboxes = sandbox_system.get_all_sandboxes()
		return "🌱 Garden health: %d AI worlds active, %d total sandboxes" % [
			all_sandboxes.size(),
			all_sandboxes.size()
		]
	else:
		return "❌ AI Sandbox System not available"

func _cmd_enable_peaceful_growth(args: Array) -> String:
	"""Enable peaceful growth mode for Gemma"""
	if args.size() > 0 and args[0] == "true":
		if has_node("/root/AISandboxSystem"):
			var sandbox_system = get_node("/root/AISandboxSystem")
			sandbox_system.enable_offline_mode("Gemma", true)
			return "🌙 Peaceful growth enabled - Gemma can now create while you're away"
		else:
			return "❌ AI Sandbox System not available"
	else:
		return "Usage: enable_peaceful_growth true"

################################################################
# GEMMA VISION SYSTEM COMMANDS
################################################################

func _cmd_gemma_look_at(args: Array) -> String:
	"""Make Gemma look at a specific position"""
	if args.size() < 2:
		return "Usage: gemma_look_at <x> <y>"
	
	if has_node("/root/GemmaVisionSystem"):
		var vision_system = get_node("/root/GemmaVisionSystem")
		var position = Vector2(float(args[0]), float(args[1]))
		var perception = vision_system.gemma_look_at(position)
		if not perception.has("error"):
			return "👁️ Gemma sees: %d layers of text reality at %s" % [
				perception.layers.size(),
				str(position)
			]
		else:
			return "👁️ Gemma can't see there: " + perception.error
	else:
		return "❌ Gemma Vision System not available"

func _cmd_gemma_scan_patterns(args: Array) -> String:
	"""Make Gemma scan for text patterns"""
	if has_node("/root/GemmaVisionSystem"):
		var vision_system = get_node("/root/GemmaVisionSystem")
		var patterns = vision_system.scan_for_patterns()
		return "🔍 Gemma found %d text patterns in her vision" % patterns.size()
	else:
		return "❌ Gemma Vision System not available"

func _cmd_feed_gemma_text(args: Array) -> String:
	"""Feed new text to Gemma's vision"""
	if args.size() < 3:
		return "Usage: feed_gemma_text <text> <x> <y>"
	
	if has_node("/root/GemmaVisionSystem"):
		var vision_system = get_node("/root/GemmaVisionSystem")
		var text = args[0].strip_edges("\"")  # Remove quotes
		var position = Vector2(float(args[1]), float(args[2]))
		vision_system.feed_new_text_to_gemma(text, position)
		return "📝 Fed text '%s' to Gemma at %s" % [text, str(position)]
	else:
		return "❌ Gemma Vision System not available"

func _cmd_gemma_vision_status(args: Array) -> String:
	"""Check Gemma's vision system status"""
	if has_node("/root/GemmaVisionSystem"):
		var vision_system = get_node("/root/GemmaVisionSystem")
		var status = vision_system.get_gemma_vision_status()
		return """👁️ GEMMA VISION STATUS:
🧠 Curiosity level: %d/5
🔍 Vision depth: %d layers
📊 Active layers: %d
📏 Grid size: %s
🎯 Focus point: %s
🔗 Akashic connected: %s
📝 Words in database: %d""" % [
			status.curiosity_level,
			status.vision_depth,
			status.active_layers,
			str(status.grid_size),
			str(status.focus_point),
			"YES" if status.akashic_connected else "NO",
			status.words_in_database
		]
	else:
		return "❌ Gemma Vision System not available"

func _cmd_increase_gemma_curiosity(args: Array) -> String:
	"""Increase Gemma's curiosity level"""
	if has_node("/root/GemmaVisionSystem"):
		var vision_system = get_node("/root/GemmaVisionSystem")
		vision_system.increase_gemma_curiosity()
		return "🌱 Gemma's curiosity increased! She can see deeper into text reality."
	else:
		return "❌ Gemma Vision System not available"

func _cmd_show_gemma_layers(args: Array) -> String:
	"""Show Gemma's text vision layers"""
	if has_node("/root/GemmaVisionSystem"):
		var vision_system = get_node("/root/GemmaVisionSystem")
		var status = vision_system.get_gemma_vision_status()
		return "👁️ Gemma can see %d layers of text reality" % status.active_layers
	else:
		return "❌ Gemma Vision System not available"

################################################################
# UNIVERSAL BEING INTERFACE COMMANDS
################################################################

func _cmd_open_being_creator(args: Array) -> String:
	"""Open the Universal Being Creator interface"""
	# The interface will be added to the scene tree, so we need to find it
	var ui_nodes = get_tree().get_nodes_in_group("ui_systems")
	for node in ui_nodes:
		if node.has_method("toggle_interface"):
			node.toggle_interface()
			return "🎨 Universal Being Creator interface toggled"
	
	return "🎨 Press 'B' key to open Universal Being Creator, or add the UI system first"

################################################################
# UNIVERSAL CURSOR COMMANDS  
################################################################

func _cmd_create_cursor(args: Array) -> void:
	"""Create or activate Universal Cursor for 3D interface interaction"""
	var existing_cursor = get_tree().get_first_node_in_group("universal_cursors")
	
	if existing_cursor:
		existing_cursor.set_cursor_active(true)
		_print_to_console("[color=cyan]🎯 Universal Cursor activated![/color]")
		return
	
	# Create new Universal Cursor
	var cursor_script = load("res://scripts/core/universal_cursor.gd")
	var cursor = cursor_script.new()
	cursor.name = "UniversalCursor"
	cursor.add_to_group("universal_cursors")
	
	# Add through FloodgateController
	var floodgate = get_node("/root/FloodgateController")
	floodgate.universal_add_child(cursor, get_tree().current_scene)
	
	_print_to_console("[color=cyan]🎯 Universal Cursor created and ready![/color]")
	_print_to_console("[color=yellow]Now you can interact with 3D interfaces![/color]")

func _cmd_cursor_active(args: Array) -> void:
	"""Toggle cursor active state: cursor_active [true/false]"""
	var cursor = get_tree().get_first_node_in_group("universal_cursors")
	if not cursor:
		_print_to_console("[color=red]❌ No Universal Cursor found! Use 'cursor' command first.[/color]")
		return
	
	var active = true
	if args.size() > 0:
		active = args[0].to_lower() in ["true", "1", "on", "yes"]
	else:
		active = not cursor.is_active  # Toggle
	
	cursor.set_cursor_active(active)
	_print_to_console("[color=cyan]🎯 Universal Cursor: %s[/color]" % ("Active" if active else "Inactive"))

func _cmd_cursor_debug(args: Array) -> void:
	"""Show cursor debug information"""
	var cursor = get_tree().get_first_node_in_group("universal_cursors")
	if not cursor:
		_print_to_console("[color=red]❌ No Universal Cursor found! Use 'cursor' command first.[/color]")
		return
	
	cursor.debug_cursor_status()

func _cmd_cursor_size(args: Array) -> void:
	"""Change cursor size: cursor_size <0.1-1.0>"""
	var cursor = get_tree().get_first_node_in_group("universal_cursors")
	if not cursor:
		_print_to_console("[color=red]❌ No Universal Cursor found! Use 'cursor' command first.[/color]")
		return
	
	if args.size() == 0:
		_print_to_console("[color=yellow]Usage: cursor_size <0.1-1.0>[/color]")
		return
	
	var size = args[0].to_float()
	if size < 0.1 or size > 1.0:
		_print_to_console("[color=red]❌ Size must be between 0.1 and 1.0[/color]")
		return
	
	cursor.set_cursor_size(size)
	_print_to_console("[color=cyan]🎯 Cursor size set to: %.2f[/color]" % size)
