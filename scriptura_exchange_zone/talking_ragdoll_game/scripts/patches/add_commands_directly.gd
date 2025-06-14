# 🏛️ Add Commands Directly - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
# Direct command injection for console - temporary fix

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Wait a frame to ensure console is ready
	await get_tree().process_frame
	await get_tree().process_frame  # Extra frame for safety
	
	var console = get_node_or_null("/root/ConsoleManager")
	if not console:
		push_error("[AddCommands] ConsoleManager not found!")
		return
	
	print("[AddCommands] Attempting to add commands to console...")
	
	# Check if commands dictionary exists
	if not "commands" in console:
		push_error("[AddCommands] Console doesn't have commands dictionary!")
		return
	
	# Add biomechanical walker commands
	console.commands["spawn_biowalker"] = Callable(self, "_cmd_spawn_biowalker")
	console.commands["walker_debug"] = Callable(self, "_cmd_walker_debug")
	console.commands["layers"] = Callable(self, "_cmd_layers")
	console.commands["layer"] = Callable(self, "_cmd_layer")
	
	print("[AddCommands] Commands added successfully!")
	print("[AddCommands] Total commands: " + str(console.commands.size()))

# Biomechanical walker spawn command
func _cmd_spawn_biowalker(args: Array) -> void:
	_print("[color=#00ff00]Creating biomechanical walker...[/color]")
	
	var spawn_pos = Vector3(0, 2, 0)
	if args.size() >= 3:
		spawn_pos = Vector3(float(args[0]), float(args[1]), float(args[2]))
	
	# Create simple test node for now
	var test_walker = Node3D.new()
	test_walker.name = "TestBioWalker"
	
	# Add a visible mesh
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = BoxMesh.new()
	mesh_instance.mesh.size = Vector3(1, 2, 0.5)
	FloodgateController.universal_add_child(mesh_instance, test_walker)
	
	test_walker.position = spawn_pos
	get_tree().FloodgateController.universal_add_child(test_walker, current_scene)
	
	_print("[color=#00ff00]Test walker created at " + str(spawn_pos) + "[/color]")
	_print("[color=#ffff00]Note: This is a simplified version for testing[/color]")

func _cmd_walker_debug(args: Array) -> void:
	_print("[color=#ffff00]Walker debug command received[/color]")
	_print("Args: " + str(args))

func _cmd_layers(_args: Array) -> void:
	_print("[color=#00ffff]=== Layer System Status ===[/color]")
	
	var layer_system = get_node_or_null("/root/LayerRealitySystem")
	if layer_system:
		_print("[color=#00ff00]Layer Reality System: ACTIVE[/color]")
		_print("Press F1-F4 to toggle layers")
		_print("Press F5 to cycle view modes")
	else:
		_print("[color=#ff0000]Layer Reality System: NOT FOUND[/color]")
		_print("Check if LayerRealitySystem is in autoloads")

func _cmd_layer(args: Array) -> void:
	if args.size() < 2:
		_print("Usage: layer [show|hide|toggle] [text|map|debug|full]")
		return
	
	_print("[color=#00ffff]Layer command: " + args[0] + " " + args[1] + "[/color]")

func _print(text: String) -> void:
	var console = get_node("/root/ConsoleManager")
	if console and console.has_method("_print_to_console"):
		console._print_to_console(text)

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