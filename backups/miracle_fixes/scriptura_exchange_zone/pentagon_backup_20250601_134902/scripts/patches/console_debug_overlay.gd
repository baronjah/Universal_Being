# 🏛️ Console Debug Overlay - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: console_debug_overlay.gd
# DESCRIPTION: Debug overlay to show console status
# PURPOSE: Help debug console visibility issues
# CREATED: 2025-05-26
# ==================================================

extends CanvasLayer

var debug_label: Label
var console_manager: Node

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	layer = 999  # Top layer
	
	# Create debug label
	debug_label = Label.new()
	debug_label.text = "Console Debug: Starting..."
	debug_label.position = Vector2(10, 10)
	debug_label.add_theme_font_size_override("font_size", 16)
	debug_label.add_theme_color_override("font_color", Color.YELLOW)
	add_child(debug_label)
	
	# Always start visible when created
	visible = true
	
	# Wait for console manager
	await get_tree().process_frame
	console_manager = get_node_or_null("/root/ConsoleManager")
	
	if console_manager:
		debug_label.text = "Console Manager: Found ✅"
	else:
		debug_label.text = "Console Manager: NOT FOUND ❌"

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	if not console_manager:
		return
		
	var status = []
	status.append("Console Manager: ✅")
	
	if "console_container" in console_manager:
		var container = console_manager.console_container
		if container:
			status.append("Container: ✅ (Visible: " + str(container.visible) + ")")
			status.append("Alpha: " + str(container.modulate.a))
			status.append("Parent: " + str(container.get_parent()))
		else:
			status.append("Container: ❌ NULL")
	else:
		status.append("Container: ❌ Property not found")
	
	if "is_visible" in console_manager:
		status.append("is_visible: " + str(console_manager.is_visible))
	
	if "is_animating" in console_manager:
		status.append("is_animating: " + str(console_manager.is_animating))
	
	debug_label.text = "\n".join(status)

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	if event is InputEventKey and event.pressed and event.keycode == KEY_F12:
		# F12 removes the overlay (same as console_debug command)
		queue_free()

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass