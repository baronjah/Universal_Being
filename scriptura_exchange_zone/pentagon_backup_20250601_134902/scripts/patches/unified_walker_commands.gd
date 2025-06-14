# ==================================================
# SCRIPT NAME: unified_walker_commands.gd
# DESCRIPTION: Console commands for the unified biomechanical walker
# PURPOSE: Replace all old ragdoll commands with clean, working system
# CREATED: 2025-05-26 - Project cleanup and consolidation  
# ==================================================

extends UniversalBeingBase
var console_manager: Node = null
var current_walker: UnifiedBiomechanicalWalker = null
var walker_visualizer: Node3D = null

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	await get_tree().process_frame
	
	console_manager = get_node_or_null("/root/ConsoleManager")
	
	if console_manager:
		_register_walker_commands()
		print("[UnifiedWalkerCommands] Commands registered successfully")
	else:
		print("[UnifiedWalkerCommands] Warning: ConsoleManager not found")

func _register_walker_commands() -> void:
	# Try different registration methods
	if console_manager.has_method("register_command"):
		# All spawn variations point to same function
		console_manager.register_command("spawn_walker", _cmd_spawn_walker, "Spawn unified biomechanical walker")
		console_manager.register_command("spawn_biowalker", _cmd_spawn_walker, "Spawn unified biomechanical walker")
		console_manager.register_command("biowalker", _cmd_spawn_walker, "Spawn unified biomechanical walker")
		# Walker control commands
		console_manager.register_command("walker_speed", _cmd_walker_speed, "Set walker speed") 
		console_manager.register_command("walker_teleport", _cmd_walker_teleport, "Teleport walker to position")
		console_manager.register_command("walker_info", _cmd_walker_info, "Show walker information")
		console_manager.register_command("walker_destroy", _cmd_walker_destroy, "Destroy current walker")
		console_manager.register_command("walker_debug", _cmd_walker_debug, "Toggle walker debug visualization")
		print("[UnifiedWalkerCommands] Registered via register_command")
	elif "commands" in console_manager:
		# All spawn variations
		console_manager.commands["spawn_walker"] = _cmd_spawn_walker
		console_manager.commands["spawn_biowalker"] = _cmd_spawn_walker
		console_manager.commands["biowalker"] = _cmd_spawn_walker
		# Walker control commands
		console_manager.commands["walker_speed"] = _cmd_walker_speed
		console_manager.commands["walker_teleport"] = _cmd_walker_teleport
		console_manager.commands["walker_info"] = _cmd_walker_info
		console_manager.commands["walker_destroy"] = _cmd_walker_destroy
		console_manager.commands["walker_debug"] = _cmd_walker_debug
		print("[UnifiedWalkerCommands] Registered via commands dictionary")
	else:
		push_error("[UnifiedWalkerCommands] No compatible command registration method found")

func _cmd_spawn_walker(args: Array) -> void:
	# Remove existing walker
	if current_walker:
		current_walker.queue_free()
		current_walker = null
	
	# Parse spawn position
	var spawn_pos = Vector3(0, 3, 0)  # Start higher to prevent ground clipping
	if args.size() >= 3:
		spawn_pos = Vector3(float(args[0]), float(args[1]), float(args[2]))
	
	# Create new unified walker
	current_walker = UnifiedBiomechanicalWalker.new()
	current_walker.name = "UnifiedWalker"
	current_walker.position = spawn_pos
	get_tree().FloodgateController.universal_add_child(current_walker, get_tree().current_scene)
	
	# Connect signals for feedback
	current_walker.step_completed.connect(_on_step_completed)
	current_walker.phase_changed.connect(_on_phase_changed)
	
	_print("[color=#00ff00]✅ Unified biomechanical walker spawned![/color]")
	_print("Position: " + str(spawn_pos))
	_print("[color=#ffff00]Features:[/color]")
	_print("  • Three-element feet (heel, midfoot, toes)")
	_print("  • Proper joint constraints")
	_print("  • 4-phase gait cycle per leg")
	_print("  • Stable physics system")
	_print("[color=#00ffff]Commands: walker_speed, walker_teleport, walker_info[/color]")

func _cmd_walker_speed(args: Array) -> void:
	if not current_walker:
		_print("[color=#ff0000]No walker spawned! Use 'spawn_walker' first.[/color]")
		return
	
	if args.is_empty():
		_print("Current walk speed: " + str(current_walker.walk_speed))
		return
	
	var new_speed = float(args[0])
	current_walker.set_walk_speed(new_speed)
	_print("[color=#00ff00]Walk speed set to: " + str(new_speed) + "[/color]")

func _cmd_walker_teleport(args: Array) -> void:
	if not current_walker:
		_print("[color=#ff0000]No walker spawned! Use 'spawn_walker' first.[/color]")
		return
	
	if args.size() < 3:
		_print("[color=#ff0000]Usage: walker_teleport <x> <y> <z>[/color]")
		return
	
	var new_pos = Vector3(float(args[0]), float(args[1]), float(args[2]))
	current_walker.teleport_to(new_pos)
	_print("[color=#00ff00]Walker teleported to: " + str(new_pos) + "[/color]")

func _cmd_walker_info(_args: Array) -> void:
	if not current_walker:
		_print("[color=#ff0000]No walker spawned! Use 'spawn_walker' first.[/color]")
		return
	
	var info = current_walker.get_debug_info()
	_print("[color=#00ffff]=== Walker Debug Info ===[/color]")
	_print("Position: " + str(info.position))
	_print("Velocity: " + str(info.velocity))
	_print("Walk Speed: " + str(info.walk_speed))
	_print("Left Leg Phase: " + str(info.left_phase))
	_print("Right Leg Phase: " + str(info.right_phase))
	_print("Cycle Time: " + str(info.cycle_time))

func _cmd_walker_destroy(_args: Array) -> void:
	if not current_walker:
		_print("[color=#ff0000]No walker to destroy.[/color]")
		return
	
	current_walker.queue_free()
	current_walker = null
	_print("[color=#ffff00]Walker destroyed.[/color]")

func _cmd_walker_debug(args: Array) -> void:
	if not current_walker:
		_print("[color=#ff0000]No walker spawned! Use 'spawn_walker' first.[/color]")
		return
	
	if args.is_empty():
		_print("[color=#ffff00]Usage: walker_debug <on|off|info>[/color]")
		return
	
	match args[0].to_lower():
		"on", "enable":
			_print("[color=#00ff00]Walker debug visualization enabled[/color]")
			_print("• Yellow = Head")
			_print("• Blue = Torso (pelvis/spine)")
			_print("• Green = Legs (thigh/shin)")
			_print("• Red = Feet (heel/midfoot/toes)")
		"off", "disable":
			_print("[color=#ffff00]Debug visualization is always on (color coding)[/color]")
		"info":
			var _info = current_walker.get_debug_info()
			_print("[color=#00ffff]=== Walker Debug Visualization ===[/color]")
			_print("Body parts are color-coded:")
			_print("  🟡 Head: " + ("✅" if current_walker.head else "❌"))
			_print("  🔵 Torso: " + ("✅" if current_walker.pelvis else "❌"))
			_print("  🟢 Legs: " + ("✅" if current_walker.left_leg else "❌"))
			_print("  🔴 Feet: 3 elements per foot")
		_:
			_print("[color=#ff0000]Unknown debug option. Use: on|off|info[/color]")

func _on_step_completed(foot: String) -> void:
	if console_manager and console_manager.debug_level >= 3:
		_print("[DEBUG] Step completed: " + foot)

func _on_phase_changed(leg: String, phase: String) -> void:
	if console_manager and console_manager.debug_level >= 3:
		_print("[DEBUG] " + leg + " leg: " + phase)

func _print(message: String) -> void:
	if console_manager and console_manager.has_method("_print_to_console"):
		console_manager._print_to_console(message)
	else:
		print(message)

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