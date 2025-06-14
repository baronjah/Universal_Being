extends UniversalBeingBase
# Console Layer Integration - Adds layer system commands to console
# This is a patch that extends ConsoleManager with layer functionality

var console_manager: Node
var layer_system: Node

func _ready() -> void:
	# Wait for autoloads
	await get_tree().process_frame
	
	console_manager = get_node_or_null("/root/ConsoleManager")
	layer_system = get_node_or_null("/root/LayerRealitySystem")
	
	if console_manager and layer_system:
		_register_layer_commands()
		print("Layer commands registered with console")

func _register_layer_commands() -> void:
	# Add commands directly to console's command dictionary
	if "commands" in console_manager:
		console_manager.commands["layer"] = _cmd_layer
		console_manager.commands["layers"] = _cmd_layers  
		console_manager.commands["reality"] = _cmd_reality
		console_manager.commands["debug_point"] = _cmd_debug_point
		console_manager.commands["debug_line"] = _cmd_debug_line
		console_manager.commands["debug_clear"] = _cmd_debug_clear
		console_manager.commands["world_view"] = _cmd_world_view
		console_manager.commands["map_view"] = _cmd_map_view
		print("[LayerIntegration] Commands added to console")
	else:
		push_error("[LayerIntegration] Console doesn't have commands dictionary!")

func _cmd_layer(args: Array) -> void:
	if args.size() < 2:
		_print("Usage: layer [show|hide|toggle] [text|map|debug|full|all]")
		return
	
	var action = args[0]
	var layer_name = args[1]
	
	var layer_map = {
		"text": layer_system.Layer.TEXT,
		"map": layer_system.Layer.MAP_2D,
		"debug": layer_system.Layer.DEBUG_3D,
		"full": layer_system.Layer.FULL_3D
	}
	
	if layer_name == "all":
		for l in layer_map.values():
			_apply_layer_action(l, action, "all")
	elif layer_name in layer_map:
		_apply_layer_action(layer_map[layer_name], action, layer_name)
	else:
		_print("[color=#ff0000]Unknown layer: " + layer_name + "[/color]")

func _apply_layer_action(layer: int, action: String, layer_name: String) -> void:
	match action:
		"show":
			layer_system.set_layer_visibility(layer, true)
			_print("[color=#00ff00]Layer '" + layer_name + "' shown[/color]")
		"hide":
			layer_system.set_layer_visibility(layer, false)
			_print("[color=#ffff00]Layer '" + layer_name + "' hidden[/color]")
		"toggle":
			layer_system.toggle_layer(layer)
			var state = "shown" if layer_system.is_layer_visible(layer) else "hidden"
			_print("[color=#00ffff]Layer '" + layer_name + "' toggled (" + state + ")[/color]")
		_:
			_print("[color=#ff0000]Unknown action: " + action + "[/color]")

func _cmd_layers(_args: Array) -> void:
	_print("[color=#00ffff]=== Reality Layer Status ===[/color]")
	
	var layer_names = ["Text/Console", "2D Map", "Debug 3D", "Full 3D"]
	var active_count = 0
	
	for i in range(4):
		var visible = layer_system.is_layer_visible(i)
		var status = "[color=#00ff00]✓[/color]" if visible else "[color=#666666]✗[/color]"
		_print(status + " Layer " + str(i) + ": " + layer_names[i])
		if visible:
			active_count += 1
	
	_print("\nView Mode: " + _get_view_mode_name())
	_print("Active Layers: " + str(active_count) + "/4")
	
	# Show keyboard shortcuts
	_print("\n[color=#888888]Shortcuts: F1-F4 (toggle layers), F5 (cycle view mode)[/color]")

func _cmd_reality(_args: Array) -> void:
	layer_system.cycle_view_mode()
	_print("[color=#00ff00]Reality view mode: " + _get_view_mode_name() + "[/color]")

func _cmd_debug_point(args: Array) -> void:
	if args.size() < 3:
		_print("Usage: debug_point [x] [y] [z] [color]")
		return
	
	var pos = Vector3(float(args[0]), float(args[1]), float(args[2]))
	var color = Color.WHITE
	
	if args.size() > 3:
		color = _parse_color(args[3])
	
	layer_system.add_debug_point(pos, color, 0.2)
	_print("[color=#00ff00]Debug point added at " + str(pos) + "[/color]")

func _cmd_debug_line(args: Array) -> void:
	if args.size() < 6:
		_print("Usage: debug_line [x1] [y1] [z1] [x2] [y2] [z2] [color]")
		return
	
	var from = Vector3(float(args[0]), float(args[1]), float(args[2]))
	var to = Vector3(float(args[3]), float(args[4]), float(args[5]))
	var color = Color.WHITE
	
	if args.size() > 6:
		color = _parse_color(args[6])
	
	layer_system.add_debug_line(from, to, color)
	_print("[color=#00ff00]Debug line added[/color]")

func _cmd_debug_clear(_args: Array) -> void:
	layer_system.clear_debug_draw()
	_print("[color=#ffff00]Debug drawings cleared[/color]")

func _cmd_world_view(args: Array) -> void:
	if args.is_empty():
		_print("Usage: world_view [show|hide|center|zoom]")
		return
	
	# This would control the console world view
	_print("[color=#00ffff]World view command: " + args[0] + "[/color]")

func _cmd_map_view(args: Array) -> void:
	if args.is_empty():
		_print("Usage: map_view [show|hide|bounds|height_range]")
		return
	
	# This would control the 2D map overlay
	_print("[color=#00ffff]Map view command: " + args[0] + "[/color]")

# Helper functions
func _print(text: String) -> void:
	if console_manager and console_manager.has_method("_print_to_console"):
		console_manager._print_to_console(text)
	else:
		print(text)

func _get_view_mode_name() -> String:
	var mode = layer_system.current_view_mode
	match mode:
		0:
			return "Single Layer"
		1:
			return "Dual Layer"
		2:
			return "Triple Layer"
		3:
			return "All Layers"
		_:
			return "Unknown"

func _parse_color(color_str: String) -> Color:
	match color_str.to_lower():
		"red":
			return Color.RED
		"green":
			return Color.GREEN
		"blue":
			return Color.BLUE
		"yellow":
			return Color.YELLOW
		"cyan":
			return Color.CYAN
		"magenta":
			return Color.MAGENTA
		"white":
			return Color.WHITE
		"gray", "grey":
			return Color.GRAY
		_:
			# Try parsing as hex
			if color_str.begins_with("#"):
				return Color(color_str)
			return Color.WHITE

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