# 🏛️ Debug Test Commands - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
# Quick debug test to verify console commands are working

func _ready() -> void:
	await get_tree().process_frame
	
	var console = get_node_or_null("/root/ConsoleManager")
	if console:
		print("[DebugTest] Registering test command...")
		
		# Try direct command registration
		if console.has_method("add_command"):
			console.add_command("test", _test_command, "Test if commands work")
			print("[DebugTest] Used add_command method")
		elif console.has_method("register_command"):
			console.register_command("test", _test_command, "Test if commands work")
			print("[DebugTest] Used register_command method")
		else:
			print("[DebugTest] ERROR: No command registration method found!")
			
			# List available methods
			print("[DebugTest] Available methods in ConsoleManager:")
			for method in console.get_method_list():
				if method.name.begins_with("_cmd_") or method.name.contains("command"):
					print("  - " + method.name)
	else:
		push_error("[DebugTest] ConsoleManager not found!")

func _test_command(args: Array) -> void:
	print("[TEST] Command works! Args: " + str(args))
	if has_node("/root/ConsoleManager"):
		get_node("/root/ConsoleManager")._print_to_console("[color=#00ff00]✓ Test command executed successfully![/color]")

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