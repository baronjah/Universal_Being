# 🏛️ Biomechanical Walker Commands - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
# Console commands for biomechanical walker testing

var console_manager: Node
var current_walker: Node3D
var walker_visualizer: Node3D

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Wait for autoloads
	await get_tree().process_frame
	
	console_manager = get_node_or_null("/root/ConsoleManager")
	
	if console_manager:
		_register_walker_commands()
		print("Biomechanical walker commands registered")

func _register_walker_commands() -> void:
	# Try different methods to register commands
	if console_manager.has_method("register_command"):
		# Use the proper register_command method with Callables
		console_manager.register_command("spawn_biowalker", _cmd_spawn_biowalker, "Spawn biomechanical walker")
		console_manager.register_command("walker_speed", _cmd_walker_speed, "Set walker speed")
		console_manager.register_command("walker_phase", _cmd_walker_phase, "Show current gait phases")
		console_manager.register_command("walker_debug", _cmd_walker_debug, "Toggle walker debug visuals")
		console_manager.register_command("walker_params", _cmd_walker_params, "Adjust walker parameters")
		console_manager.register_command("walker_teleport", _cmd_walker_teleport, "Teleport walker to position")
		console_manager.register_command("walker_freeze", _cmd_walker_freeze, "Freeze/unfreeze walker")
		print("[BiomechanicalWalker] Commands registered via register_command!")
	elif "commands" in console_manager:
		console_manager.commands["spawn_biowalker"] = _cmd_spawn_biowalker
		console_manager.commands["walker_speed"] = _cmd_walker_speed
		console_manager.commands["walker_phase"] = _cmd_walker_phase
		console_manager.commands["walker_debug"] = _cmd_walker_debug
		console_manager.commands["walker_params"] = _cmd_walker_params
		console_manager.commands["walker_teleport"] = _cmd_walker_teleport
		console_manager.commands["walker_freeze"] = _cmd_walker_freeze
		print("[BiomechanicalWalker] Commands added to console")
	else:
		push_error("[BiomechanicalWalker] Console doesn't have commands dictionary!")

func _cmd_spawn_biowalker(args: Array) -> void:
	# Remove existing walker if any
	if current_walker:
		current_walker.queue_free()
		if walker_visualizer:
			walker_visualizer.queue_free()
	
	# Parse position
	var spawn_pos = Vector3(0, 2, 0)
	if args.size() >= 3:
		spawn_pos = Vector3(float(args[0]), float(args[1]), float(args[2]))
	
	# Create walker
	var walker_script = load("res://scripts/ragdoll/biomechanical_walker.gd")
	current_walker = Node3D.new()
	current_walker.set_script(walker_script)
	current_walker.name = "BiomechanicalWalker"
	current_walker.position = spawn_pos
	FloodgateController.universal_add_child(current_walker, get_tree().current_scene)
	
	# Create visualizer
	var visualizer_script = load("res://scripts/ragdoll/gait_phase_visualizer.gd")
	walker_visualizer = Node3D.new()
	walker_visualizer.set_script(visualizer_script)
	walker_visualizer.name = "GaitVisualizer"
	FloodgateController.universal_add_child(walker_visualizer, get_tree().current_scene)
	
	# Set walker after adding to scene
	if walker_visualizer.has_method("set_walker"):
		walker_visualizer.set_walker(current_walker)
	else:
		walker_visualizer.set("walker", current_walker)
	
	_print("[color=#00ff00]Biomechanical walker spawned at " + str(spawn_pos) + "[/color]")
	_print("[color=#ffff00]Features:[/color]")
	_print("  - Anatomically correct feet (heel, foot, toes)")
	_print("  - 8 gait phases per leg")
	_print("  - Multiple ground contact points")
	_print("  - Realistic joint constraints")
	_print("[color=#00ffff]Use 'walker_debug all on' to see visualization[/color]")

func _cmd_walker_speed(args: Array) -> void:
	if not current_walker:
		_print("[color=#ff0000]No walker spawned. Use 'spawn_biowalker' first[/color]")
		return
	
	if args.size() > 0:
		var speed = float(args[0])
		current_walker.set_walk_speed(speed)
		_print("[color=#00ff00]Walker speed set to " + str(speed) + "[/color]")
	else:
		_print("Current speed: " + str(current_walker.walk_speed))

func _cmd_walker_phase(_args: Array) -> void:
	if not current_walker:
		_print("[color=#ff0000]No walker spawned[/color]")
		return
	
	_print("[color=#00ffff]=== Current Gait Phases ===[/color]")
	_print("Left leg:  " + current_walker.get_current_phase("left"))
	_print("Right leg: " + current_walker.get_current_phase("right"))
	_print("")
	_print("Left foot on ground:  " + str(current_walker.is_foot_on_ground("left")))
	_print("Right foot on ground: " + str(current_walker.is_foot_on_ground("right")))

func _cmd_walker_debug(args: Array) -> void:
	if not walker_visualizer:
		_print("[color=#ff0000]No walker visualizer active[/color]")
		return
	
	if args.is_empty():
		_print("Usage: walker_debug [labels|contacts|forces|timeline|all] [on|off]")
		return
	
	var result = walker_visualizer.handle_console_command("gait_debug", args)
	_print(result)

func _cmd_walker_params(args: Array) -> void:
	if not current_walker:
		_print("[color=#ff0000]No walker spawned[/color]")
		return
	
	if args.size() < 2:
		_print("Usage: walker_params [param] [value]")
		_print("Params: step_length, step_height, stance_time, swing_time")
		_print("Current values:")
		_print("  step_length: " + str(current_walker.step_length))
		_print("  step_height: " + str(current_walker.step_height))
		_print("  stance_time: " + str(current_walker.stance_duration))
		_print("  swing_time: " + str(current_walker.swing_duration))
		return
	
	var param = args[0]
	var value = float(args[1])
	
	match param:
		"step_length":
			current_walker.step_length = value
			_print("Step length set to " + str(value))
		"step_height":
			current_walker.step_height = value
			_print("Step height set to " + str(value))
		"stance_time":
			current_walker.stance_duration = value
			_print("Stance duration set to " + str(value))
		"swing_time":
			current_walker.swing_duration = value
			_print("Swing duration set to " + str(value))
		_:
			_print("[color=#ff0000]Unknown parameter: " + param + "[/color]")

func _cmd_walker_teleport(args: Array) -> void:
	if not current_walker:
		_print("[color=#ff0000]No walker spawned[/color]")
		return
	
	if args.size() < 3:
		_print("Usage: walker_teleport [x] [y] [z]")
		return
	
	var new_pos = Vector3(float(args[0]), float(args[1]), float(args[2]))
	
	# Teleport all parts
	var offset = new_pos - current_walker.pelvis.global_position
	current_walker.pelvis.global_position += offset
	current_walker.spine.global_position += offset
	
	for leg in [current_walker.left_leg, current_walker.right_leg]:
		leg.hip.global_position += offset
		leg.thigh.global_position += offset
		leg.shin.global_position += offset
		leg.heel.global_position += offset
		leg.foot.global_position += offset
		leg.toes.global_position += offset
	
	_print("[color=#00ff00]Walker teleported to " + str(new_pos) + "[/color]")

func _cmd_walker_freeze(args: Array) -> void:
	if not current_walker:
		_print("[color=#ff0000]No walker spawned[/color]")
		return
	
	var freeze = true
	if args.size() > 0:
		freeze = args[0] != "false" and args[0] != "off"
	
	# Freeze/unfreeze all bodies
	var bodies = [
		current_walker.pelvis, current_walker.spine,
		current_walker.left_leg.hip, current_walker.left_leg.thigh,
		current_walker.left_leg.shin, current_walker.left_leg.heel,
		current_walker.left_leg.foot, current_walker.left_leg.toes,
		current_walker.right_leg.hip, current_walker.right_leg.thigh,
		current_walker.right_leg.shin, current_walker.right_leg.heel,
		current_walker.right_leg.foot, current_walker.right_leg.toes
	]
	
	for body in bodies:
		body.freeze = freeze
	
	_print("[color=#00ff00]Walker " + ("frozen" if freeze else "unfrozen") + "[/color]")

func _print(text: String) -> void:
	if console_manager and console_manager.has_method("_print_to_console"):
		console_manager._print_to_console(text)
	else:
		print(text)

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