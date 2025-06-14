# 🏛️ Delayed Command Injector - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
# Delayed command injection - waits for console to be fully ready

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Wait a full second to ensure everything is loaded
	await get_tree().create_timer(1.0).timeout
	
	print("\n🔧 [DelayedInjector] Attempting to inject commands...")
	
	var console = get_node_or_null("/root/ConsoleManager")
	if not console:
		push_error("[DelayedInjector] Console not found!")
		return
	
	print("[DelayedInjector] Console found, checking commands...")
	
	# Try different methods to access commands
	var commands_dict = null
	
	# Method 1: Direct property access
	if "commands" in console:
		commands_dict = console.commands
		print("[DelayedInjector] ✅ Found commands via property check")
	# Method 2: get() method
	elif console.get("commands") != null:
		commands_dict = console.get("commands")
		print("[DelayedInjector] ✅ Found commands via get()")
	# Method 3: Try to access directly
	else:
		commands_dict = console.get("commands")
		if commands_dict:
			print("[DelayedInjector] ✅ Found commands via fallback")
		else:
			print("[DelayedInjector] ❌ All access methods failed")
	
	if commands_dict == null:
		push_error("[DelayedInjector] Could not access commands dictionary!")
		return
	
	if not commands_dict is Dictionary:
		push_error("[DelayedInjector] Commands is not a Dictionary! Type: " + str(typeof(commands_dict)))
		return
	
	print("[DelayedInjector] Adding custom commands to dictionary with " + str(commands_dict.size()) + " existing commands...")
	
	# Add our custom commands
	commands_dict["spawn_biowalker"] = func(_args):
		console._print_to_console("[color=#00ff00]Creating biomechanical walker...[/color]")
		var walker_script = load("res://scripts/ragdoll/biomechanical_walker.gd")
		if walker_script:
			var walker = Node3D.new()
			walker.set_script(walker_script)
			walker.name = "BiomechanicalWalker"
			walker.position = Vector3(0, 2, 0)
			get_tree().FloodgateController.universal_add_child(walker, current_scene)
			console._print_to_console("[color=#00ff00]✅ Biomechanical walker spawned![/color]")
			console._print_to_console("[color=#ffff00]Note: This is a complex physics object with:")
			console._print_to_console("  - Anatomically correct feet (heel, midfoot, toes)")
			console._print_to_console("  - 8-phase gait cycle")
			console._print_to_console("  - Multiple ground contact points[/color]")
		else:
			console._print_to_console("[color=#ff0000]❌ Failed to load walker script![/color]")
	
	commands_dict["test_layers"] = func(_args):
		console._print_to_console("[color=#00ffff]=== Layer System Test ===[/color]")
		var layer_sys = get_node_or_null("/root/LayerRealitySystem")
		if layer_sys:
			console._print_to_console("[color=#00ff00]✅ Layer system found![/color]")
			console._print_to_console("Press F1-F4 to toggle layers")
			console._print_to_console("Press F5 to cycle view modes")
		else:
			console._print_to_console("[color=#ff0000]❌ Layer system not in autoloads![/color]")
	
	commands_dict["layer"] = func(args):
		if args.size() < 2:
			console._print_to_console("Usage: layer [show|hide|toggle] [text|map|debug|full]")
			return
		
		var layer_sys = get_node_or_null("/root/LayerRealitySystem")
		if not layer_sys:
			console._print_to_console("[color=#ff0000]Layer system not available[/color]")
			return
		
		var action = args[0]
		var layer_name = args[1]
		
		var layer_map = {
			"text": 0,
			"map": 1,
			"debug": 2,
			"full": 3
		}
		
		if layer_name in layer_map:
			var layer_id = layer_map[layer_name]
			match action:
				"show":
					layer_sys.set_layer_visibility(layer_id, true)
					console._print_to_console("[color=#00ff00]Layer " + layer_name + " shown[/color]")
				"hide":
					layer_sys.set_layer_visibility(layer_id, false)
					console._print_to_console("[color=#ffff00]Layer " + layer_name + " hidden[/color]")
				"toggle":
					layer_sys.toggle_layer(layer_id)
					console._print_to_console("[color=#00ffff]Layer " + layer_name + " toggled[/color]")
		else:
			console._print_to_console("[color=#ff0000]Unknown layer: " + layer_name + "[/color]")
	
	print("[DelayedInjector] ✅ Commands injected successfully!")
	print("[DelayedInjector] New total commands: " + str(commands_dict.size()))
	
	# Verify our commands were added
	if "spawn_biowalker" in commands_dict:
		print("[DelayedInjector] ✅ Verified: spawn_biowalker added")
	if "test_layers" in commands_dict:
		print("[DelayedInjector] ✅ Verified: test_layers added")
	if "layer" in commands_dict:
		print("[DelayedInjector] ✅ Verified: layer added")

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