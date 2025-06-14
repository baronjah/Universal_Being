# 🏛️ Console Command Extension - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

extends UniversalBeingBase
# Console Command Extension - Adds new commands via monkey patching

var console: Node
var original_process_input

func _ready() -> void:
	# Get console manager
	console = get_node_or_null("/root/ConsoleManager")
	if not console:
		push_error("[CommandExtension] ConsoleManager not found!")
		return
	
	# Wait for console to be fully ready
	await get_tree().process_frame
	await get_tree().process_frame
	
	print("[CommandExtension] Extending console commands...")
	
	# Hook into the input processing
	if console.has_signal("text_submitted"):
		# Connect to existing signal if available
		var connections = console.get_signal_connection_list("text_submitted")
		for conn in connections:
			if conn.callable.get_object() == console:
				# Found the console's own handler
				original_process_input = conn.callable
				console.disconnect("text_submitted", conn.callable)
				console.connect("text_submitted", _on_extended_input_submitted)
				print("[CommandExtension] Hooked into text input processing")
				break
	
	# Alternative: Find the input field directly
	_find_and_hook_input_field(console)

func _find_and_hook_input_field(node: Node) -> void:
	# Recursively search for LineEdit
	if node is LineEdit:
		print("[CommandExtension] Found LineEdit!")
		if not node.text_submitted.is_connected(_on_extended_input_submitted):
			node.text_submitted.connect(_on_extended_input_submitted)
		return
	
	for child in node.get_children():
		_find_and_hook_input_field(child)

func _on_extended_input_submitted(text: String) -> void:
	print("[CommandExtension] Intercepted command: " + text)
	
	# Parse command
	var parts = text.strip_edges().split(" ")
	if parts.is_empty():
		return
	
	var command = parts[0].to_lower()
	var args = parts.slice(1)
	
	# Check for our custom commands
	var handled = false
	match command:
		"spawn_biowalker":
			_cmd_spawn_biowalker(args)
			handled = true
		"walker_debug":
			_cmd_walker_debug(args)
			handled = true
		"layers":
			_cmd_layers(args)
			handled = true
		"layer":
			_cmd_layer(args)
			handled = true
		"test":
			_print("[color=#00ff00]Extension test successful![/color]")
			handled = true
	
	if handled:
		# Clear the input field
		_clear_input_field()
	else:
		# Pass to original handler
		if console.has_method("_on_input_submitted"):
			console._on_input_submitted(text)
		else:
			_print("[color=#ff0000]Unknown command: " + command + "[/color]")
			_print("Type 'help' for available commands")

func _clear_input_field() -> void:
	# Find and clear the input field
	_clear_input_recursive(console)

func _clear_input_recursive(node: Node) -> void:
	if node is LineEdit:
		node.text = ""
		return
	
	for child in node.get_children():
		_clear_input_recursive(child)

# Command implementations
func _cmd_spawn_biowalker(args: Array) -> void:
	_print("[color=#00ff00]Creating biomechanical walker...[/color]")
	
	var spawn_pos = Vector3(0, 2, 0)
	if args.size() >= 3:
		spawn_pos = Vector3(float(args[0]), float(args[1]), float(args[2]))
	
	# Load the actual biomechanical walker
	var walker_script = load("res://scripts/ragdoll/biomechanical_walker.gd")
	if walker_script:
		var walker = Node3D.new()
		walker.set_script(walker_script)
		walker.name = "BiomechanicalWalker"
		walker.position = spawn_pos
		get_tree().FloodgateController.universal_add_child(walker, current_scene)
		
		# Add visualizer
		var viz_script = load("res://scripts/ragdoll/gait_phase_visualizer.gd")
		if viz_script:
			var visualizer = Node3D.new()
			visualizer.set_script(viz_script)
			visualizer.name = "GaitVisualizer"
			visualizer.set("walker", walker)
			get_tree().FloodgateController.universal_add_child(visualizer, current_scene)
		
		_print("[color=#00ff00]Biomechanical walker spawned at " + str(spawn_pos) + "[/color]")
		_print("[color=#ffff00]Use 'walker_debug all on' to see visualization[/color]")
		_print("[color=#00ffff]Press F3 to toggle debug layer[/color]")
	else:
		_print("[color=#ff0000]Failed to load walker script![/color]")

func _cmd_walker_debug(args: Array) -> void:
	_print("[color=#ffff00]Walker debug: " + str(args) + "[/color]")
	# TODO: Implement debug controls

func _cmd_layers(_args: Array) -> void:
	_print("[color=#00ffff]=== Layer System Status ===[/color]")
	
	var layer_system = get_node_or_null("/root/LayerRealitySystem")
	if layer_system:
		_print("[color=#00ff00]Layer Reality System: ACTIVE[/color]")
		_print("F1: Console (this)")
		_print("F2: 2D Map Layer")
		_print("F3: Debug 3D Layer")
		_print("F4: Full 3D Layer")
		_print("F5: Cycle view modes")
	else:
		_print("[color=#ff0000]Layer Reality System: NOT LOADED[/color]")

func _cmd_layer(args: Array) -> void:
	if args.size() < 2:
		_print("Usage: layer [show|hide|toggle] [text|map|debug|full]")
		return
	
	var layer_system = get_node_or_null("/root/LayerRealitySystem")
	if not layer_system:
		_print("[color=#ff0000]Layer system not available[/color]")
		return
	
	# TODO: Implement layer control
	_print("[color=#00ffff]Layer " + args[0] + " " + args[1] + "[/color]")

func _print(text: String) -> void:
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