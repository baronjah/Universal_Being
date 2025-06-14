# QUICK CONSOLE ACTIVATOR - DIRECT COMMAND ACCESS
# Fixes console commands not responding in game
extends Node

var console_controller = null

func _ready():
	print("🎮 Quick Console Activator: Connecting direct commands...")
	_find_or_create_console_controller()

func _find_or_create_console_controller():
	# Try to find existing console controller
	var controller_script = load("res://scripts/universal_console_controller.gd")
	if controller_script:
		console_controller = controller_script.new()
		console_controller.name = "UniversalConsoleController"
		get_tree().current_scene.add_child(console_controller)
		print("✅ Console Controller: Active and ready for commands!")
	else:
		print("❌ Console Controller: Script not found")

func _input(event):
	if event is InputEventKey and event.pressed:
		# Backtick key to activate console
		if event.keycode == KEY_QUOTELEFT:  # ` key
			_toggle_console()
		# Quick revolution command
		elif event.keycode == KEY_R and event.ctrl_pressed:
			_quick_revolution()
		# Quick stars command
		elif event.keycode == KEY_S and event.ctrl_pressed:
			_quick_stars()

func _toggle_console():
	print("🎮 Console Toggle: Press ` to open console")
	if console_controller and console_controller.has_method("toggle_console"):
		console_controller.toggle_console()

func _quick_revolution():
	print("🌟 Quick Revolution: Triggering consciousness revolution...")
	if console_controller and console_controller.has_method("deploy_consciousness_revolution"):
		console_controller.deploy_consciousness_revolution()
	else:
		# Direct revolution trigger
		_create_direct_revolution()

func _quick_stars():
	print("⭐ Quick Stars: Activating star navigation...")
	if console_controller and console_controller.has_method("execute_command"):
		console_controller.execute_command("stars")

func _create_direct_revolution():
	"""Direct revolution creation without console"""
	print("🚀 DIRECT REVOLUTION: Creating consciousness revolution...")
	
	# Create revolution system directly
	var revolution_script = load("res://scripts/ConsciousnessRevolution.gd")
	if revolution_script:
		var revolution = revolution_script.new()
		revolution.name = "DirectRevolution"
		get_tree().current_scene.add_child(revolution)
		revolution.trigger_revolution()
		print("✅ Revolution triggered directly!")
	else:
		print("❌ Revolution script not found")

func _get_class_info():
	print("🎮 QuickConsoleActivator: Ready for direct command access!")