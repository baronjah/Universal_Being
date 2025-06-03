#!/usr/bin/env -S godot --script
extends Node2D

# Visual Integration Test for Universal Being System
# Tests the ButtonUniversalBeing with button_template.tscn

var button_being: ButtonUniversalBeing
var current_level: int = 0
var timer: float = 0.0
var cycle_time: float = 2.0  # Time per consciousness level

# Use ChatGPT's consciousness colors
const CONSCIOUSNESS_COLORS = {
	0: Color(0.5, 0.5, 0.5),      # Gray - Dormant
	1: Color(0.9, 0.9, 0.9),      # Pale - Awakening
	2: Color(0.2, 0.4, 1.0),      # Blue - Aware
	3: Color(0.2, 1.0, 0.2),      # Green - Connected
	4: Color(1.0, 0.84, 0.0),     # Gold - Enlightened
	5: Color(1.0, 1.0, 1.0),      # Glowing White - Transcendent
	6: Color(1.0, 1.0, 1.0)       # Beyond (same as Transcendent)
}

func _ready():
	print("\n🎨 VISUAL INTEGRATION TEST")
	print("=".repeat(60))
	print("Testing ButtonUniversalBeing with button_template.tscn")
	print("Cycling through consciousness levels 0-6...")
	print("=".repeat(60) + "\n")
	
	# Create the button being
	button_being = preload("res://beings/button_universal_being.gd").new()
	var viewport_size = get_viewport_rect().size
	button_being.position = Vector3(viewport_size.x / 2, viewport_size.y / 2, 0)
	add_child(button_being)
	
	# Load the visual scene
	button_being.load_scene("res://scenes/ui/button_template.tscn")
	
	# Wait a frame for scene to load
	await get_tree().process_frame
	
	# Setup initial visual
	update_consciousness_display()
	
	# Add UI instructions
	create_ui_overlay()

func _process(delta: float):
	timer += delta
	
	# Cycle through consciousness levels
	if timer >= cycle_time:
		timer = 0.0
		current_level = (current_level + 1) % 7
		button_being.consciousness_level = current_level
		update_consciousness_display()

func update_consciousness_display():
	print("🌟 Consciousness Level: %d - %s" % [current_level, ConsciousnessVisualizer.get_consciousness_name(current_level)])
	
	# Update the being's visual using the centralized system
	button_being.update_consciousness_visual()
	
	# Verify scene is loaded
	var scene_root = button_being.get_scene_node("")
	if not scene_root:
		print("   ❌ Scene not loaded!")
		return
	
	print("   ✅ Visual updated with ConsciousnessVisualizer")

# Removed redundant update functions - now using ConsciousnessVisualizer

func _on_button_hover(button: Button, level: int):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.3)

func _on_button_unhover(button: Button):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(button, "scale", Vector2.ONE, 0.3)

func create_ui_overlay():
	# Create info panel
	var panel = PanelContainer.new()
	panel.position = Vector2(10, 10)
	panel.size = Vector2(400, 150)
	add_child(panel)
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "Visual Integration Test"
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	var info = Label.new()
	info.text = "Cycling through consciousness levels...\nPress ESC to exit"
	vbox.add_child(info)
	
	# Legend
	var legend_title = Label.new()
	legend_title.text = "\nConsciousness Levels:"
	vbox.add_child(legend_title)
	
	for i in range(7):
		var level_label = Label.new()
		level_label.text = "  Level %d" % i
		level_label.modulate = CONSCIOUSNESS_COLORS[i]
		vbox.add_child(level_label)

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		print("\n✅ Visual Integration Test Complete!")
		get_tree().quit()
	
	# Manual level control
	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_0 and event.keycode <= KEY_6:
			var level = event.keycode - KEY_0
			current_level = level
			button_being.consciousness_level = level
			timer = 0.0
			update_consciousness_display()
			print("⌨️  Manually set to level %d" % level)
