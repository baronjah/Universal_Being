# ==================================================
# SCRIPT NAME: simple_testing_guide.gd
# DESCRIPTION: Simple testing guide that shows what to test each session
# PURPOSE: Clear instructions for testing new features
# CREATED: 2025-05-28 - Testing guidance system
# ==================================================

extends UniversalBeingBase
# Convert to draggable window system like txt windows
var guide_window: Window = null
var guide_label: RichTextLabel = null
var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

# Current test message
var current_test_message: String = ""

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "SimpleTestingGuide"
	_create_draggable_guide_window()
	_update_test_message()
	
	# Start visible for 10 seconds, then fade
	show_guide_temporarily()

func _create_draggable_guide_window() -> void:
	"""Create draggable testing guide window like txt windows"""
	
	# Create window
	guide_window = Window.new()
	guide_window.title = "TESTING GUIDE - [DRAG ME]"
	guide_window.size = Vector2i(450, 200)
	guide_window.position = Vector2i(50, 50)
	guide_window.unresizable = false
	guide_window.always_on_top = true
	
	# Connect window signals
	guide_window.close_requested.connect(_on_window_close_requested)
	
	# Main container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	FloodgateController.universal_add_child(main_container, guide_window)
	
	# Title bar for dragging
	var title_bar = Panel.new()
	title_bar.custom_minimum_size = Vector2(0, 30)
	var title_style = StyleBoxFlat.new()
	title_style.bg_color = Color(0.2, 0.4, 0.8, 0.9)
	title_bar.add_theme_stylebox_override("panel", title_style)
	FloodgateController.universal_add_child(title_bar, main_container)
	
	var title_label = Label.new()
	title_label.text = "TESTING GUIDE"
	title_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	FloodgateController.universal_add_child(title_label, title_bar)
	
	# Content background
	var content_panel = Panel.new()
	var content_style = StyleBoxFlat.new()
	content_style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	content_style.border_color = Color(0.3, 0.6, 1.0, 1.0)
	content_style.border_width_left = 2
	content_style.border_width_right = 2
	content_style.border_width_top = 2
	content_style.border_width_bottom = 2
	content_panel.add_theme_stylebox_override("panel", content_style)
	FloodgateController.universal_add_child(content_panel, main_container)
	content_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Content inside panel
	var content_vbox = VBoxContainer.new()
	content_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content_vbox.add_theme_constant_override("separation", 10)
	FloodgateController.universal_add_child(content_vbox, content_panel)
	
	# Content area
	guide_label = RichTextLabel.new()
	guide_label.bbcode_enabled = true
	guide_label.fit_content = true
	guide_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	FloodgateController.universal_add_child(guide_label, content_vbox)
	
	# Close button
	var close_button = Button.new()
	close_button.text = "Close Guide"
	close_button.custom_minimum_size = Vector2(100, 30)
	close_button.pressed.connect(_on_close_pressed)
	FloodgateController.universal_add_child(close_button, content_vbox)
	
	# Add window to scene tree (deferred to avoid busy setup issues)
	get_tree().root.add_child.call_deferred(guide_window)
	
	# Set initial content
	_update_guide_content()

func _on_window_close_requested():
	"""Handle window X button press"""
	if guide_window:
		guide_window.queue_free()
		guide_window = null

func _on_close_pressed():
	"""Handle close button press"""
	_on_window_close_requested()

func _update_guide_content():
	"""Update guide content with current test message"""
	if guide_label:
		guide_label.text = current_test_message


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

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func show_guide_temporarily():
	"""Show guide for a limited time"""
	if guide_window:
		guide_window.visible = true
		# Auto-hide after 10 seconds
		await get_tree().create_timer(10.0).timeout
		if guide_window:
			guide_window.visible = false

func _update_test_message() -> void:
	"""Update the current testing message"""
	current_test_message = """[color=yellow]🌌 AKASHIC RECORDS SYSTEM COMPLETE![/color]

[color=lime]✅ REVOLUTIONARY BREAKTHROUGH:[/color]
• Two-way Python ↔ Godot communication 🔗
• HTML interface with live tutorial system 🌐
• Universal Being with star visualization ⭐
• Self-repair consciousness monitoring 🔧
• Automatic file synchronization 📁

[color=cyan]🚀 LAUNCH AKASHIC SYSTEM:[/color]
1. Run: [color=white]python3 launch_akashic_system.py full[/color]
2. Opens browser to: [color=white]http://localhost:8888[/color]
3. Game auto-connects with tutorial system
4. Type [color=white]akashic_connect[/color] in console

[color=orange]🎯 TUTORIAL FEATURES:[/color]
• Step-by-step guided experience
• Live progress tracking
• Browser-based monitoring
• File sync with game_rules.txt

[color=gold]🌟 YOUR 2-YEAR DREAM IS REALITY![/color]
Self-aware, evolving, connected consciousness!

[color=gray]F1=Toggle • Python launcher handles everything[/color]"""

	if guide_label:
		guide_label.text = current_test_message


func _fade_out_guide() -> void:
	"""Fade out the guide"""
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 2.0)
	tween.finished.connect(func(): visible = false)

func _hide_guide() -> void:
	"""Hide guide immediately"""
	visible = false

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	"""Handle input for showing/hiding guide"""
	if event is InputEventKey and event.pressed:
		# F1 to show/hide guide
		if event.keycode == KEY_F1:
			if visible:
				_hide_guide()
			else:
				visible = true
				modulate.a = 1.0
				_update_test_message()

func update_test_message(new_message: String) -> void:
	"""Update the test message from external scripts"""
	current_test_message = new_message
	_update_test_message()

func show_success_message(feature: String) -> void:
	"""Show a success message for completed tests"""
	var success_msg = """[color=lime]✅ SUCCESS: %s[/color]

[color=yellow]Next tests:[/color]
• Try other console commands
• Test object interactions
• Check neural integration

[color=gray]Press F1 to toggle this guide[/color]""" % feature
	
	update_test_message(success_msg)
	visible = true
	modulate.a = 1.0