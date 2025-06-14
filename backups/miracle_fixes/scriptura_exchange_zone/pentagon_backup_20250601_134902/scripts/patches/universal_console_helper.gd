# 🏛️ Universal Console Helper - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
# Universal Entity Console Integration Helper
# This ensures commands are properly registered

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	name = "UniversalConsoleHelper"
	
	# Wait for both systems to be ready
	await get_tree().create_timer(2.5).timeout
	
	_ensure_universal_commands()

func _ensure_universal_commands():
	var console = get_node_or_null("/root/ConsoleManager")
	var universal = get_node_or_null("/root/UniversalEntity")
	
	if not console:
		print("[UniversalConsoleHelper] ConsoleManager not found")
		return
		
	if not universal:
		print("[UniversalConsoleHelper] UniversalEntity not found") 
		return
	
	# Check if commands are already registered
	if "commands" in console and "universal" in console.commands:
		print("[UniversalConsoleHelper] Commands already registered!")
		return
	
	# Force registration
	print("[UniversalConsoleHelper] Forcing command registration...")
	
	if "commands" in console:
		# Create wrapper functions
		console.commands["universal"] = func(args): 
			if universal.has_method("_cmd_universal_status"):
				universal._cmd_universal_status(args)
				
		console.commands["perfect"] = func(args):
			if universal.has_method("_cmd_make_perfect"):
				universal._cmd_make_perfect(args)
				
		console.commands["health"] = func(args):
			if universal.has_method("_cmd_health_check"):
				universal._cmd_health_check(args)
				
		console.commands["evolve"] = func(args):
			if universal.has_method("_cmd_evolve"):
				universal._cmd_evolve(args)
				
		console.commands["satisfy"] = func(args):
			if universal.has_method("_cmd_check_satisfaction"):
				universal._cmd_check_satisfaction(args)
				
		console.commands["variables"] = func(args):
			if universal.has_method("_cmd_list_variables"):
				universal._cmd_list_variables(args)
				
		console.commands["lists"] = func(args):
			if universal.has_method("_cmd_show_lists"):
				universal._cmd_show_lists(args)
				
		console.commands["optimize"] = func(args):
			if universal.has_method("_cmd_optimize_now"):
				universal._cmd_optimize_now(args)
		
		print("[UniversalConsoleHelper] ✅ All commands registered!")
		print("[UniversalConsoleHelper] You can now use: universal, perfect, health, etc.")
		
		# Print to console if possible
		if console.has_method("_print_to_console"):
			console._print_to_console("[color=#00ff00]Universal Entity commands ready![/color]")
			console._print_to_console("Type 'universal' to begin!")


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