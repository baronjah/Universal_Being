# ==================================================
# SCRIPT NAME: floodgate_console_bridge.gd
# DESCRIPTION: Bridge between console and FloodgateController
# PURPOSE: All game operations through console commands via Floodgate
# CREATED: 2025-05-28 - Console-Floodgate integration
# ==================================================

extends UniversalBeingBase
var console_manager: Node
var floodgate: Node

func _ready() -> void:
	# Wait for autoloads
	await get_tree().process_frame
	
	console_manager = get_node_or_null("/root/ConsoleManager")
	floodgate = get_node_or_null("/root/FloodgateController")
	
	if console_manager and floodgate:
		_register_floodgate_commands()
		print("[FloodgateBridge] Console-Floodgate bridge established")
	else:
		push_error("[FloodgateBridge] Missing ConsoleManager or FloodgateController")

func _register_floodgate_commands() -> void:
	# Node creation/deletion
	console_manager.register_command("create_node", _cmd_create_node, "Create node through Floodgate")
	console_manager.register_command("delete_node", _cmd_delete_node, "Delete node through Floodgate")
	console_manager.register_command("duplicate_node", _cmd_duplicate_node, "Duplicate node through Floodgate")
	
	# Node transformations
	console_manager.register_command("move_node", _cmd_move_node, "Move node to position")
	console_manager.register_command("rotate_node", _cmd_rotate_node, "Rotate node")
	console_manager.register_command("scale_node", _cmd_scale_node, "Scale node")
	console_manager.register_command("reparent_node", _cmd_reparent_node, "Change node parent")
	
	# Property management
	console_manager.register_command("set_property", _cmd_set_property, "Set node property")
	console_manager.register_command("get_property", _cmd_get_property, "Get node property")
	console_manager.register_command("list_properties", _cmd_list_properties, "List all node properties")
	
	# Method calling
	console_manager.register_command("call_method", _cmd_call_method, "Call node method")
	console_manager.register_command("list_methods", _cmd_list_methods, "List node methods")
	
	# Signal management
	console_manager.register_command("connect_signal", _cmd_connect_signal, "Connect signal")
	console_manager.register_command("disconnect_signal", _cmd_disconnect_signal, "Disconnect signal")
	console_manager.register_command("emit_signal", _cmd_emit_signal, "Emit signal")
	console_manager.register_command("list_signals", _cmd_list_signals, "List node signals")
	
	# Asset management
	console_manager.register_command("load_asset", _cmd_load_asset, "Load asset through Floodgate")
	console_manager.register_command("unload_asset", _cmd_unload_asset, "Unload asset")
	console_manager.register_command("list_assets", _cmd_list_assets, "List loaded assets")
	
	# Scene management
	console_manager.register_command("save_scene", _cmd_save_scene, "Save current scene")
	console_manager.register_command("load_scene", _cmd_load_scene, "Load scene")
	console_manager.register_command("clear_scene", _cmd_clear_scene, "Clear all nodes from scene")
	console_manager.register_command("list_nodes", _cmd_list_nodes, "List all nodes in scene")
	
	# Floodgate status
	console_manager.register_command("floodgate_status", _cmd_floodgate_status, "Show Floodgate status")
	console_manager.register_command("floodgate_queue", _cmd_floodgate_queue, "Show operation queue")
	console_manager.register_command("floodgate_history", _cmd_floodgate_history, "Show operation history")

# ================================
# NODE OPERATIONS
# ================================

func _cmd_create_node(args: Array) -> void:
	if args.size() < 2:
		_print("Usage: create_node <class_name> <parent_path> [name] [x] [y] [z]")
		_print("Example: create_node Node3D /root/Main MyNode 0 5 0")
		return
	
	var node_class = args[0]
	var parent_path = args[1]
	var node_name = args[2] if args.size() > 2 else "NewNode"
	
	var params = {
		"class_name": node_class,
		"parent_path": parent_path,
		"name": node_name
	}
	
	# Add position if provided
	if args.size() >= 6:
		params["properties"] = {
			"position": Vector3(float(args[3]), float(args[4]), float(args[5]))
		}
	
	var op_id = floodgate.queue_operation(floodgate.OperationType.CREATE_NODE, params, 5)
	_print("[color=green]Node creation queued: " + op_id + "[/color]")

func _cmd_delete_node(args: Array) -> void:
	if args.size() < 1:
		_print("Usage: delete_node <node_path>")
		_print("Example: delete_node /root/Main/MyNode")
		return
	
	var node_path = args[0]
	var params = {"node_path": node_path}
	
	var op_id = floodgate.queue_operation(floodgate.OperationType.DELETE_NODE, params, 5)
	_print("[color=yellow]Node deletion queued: " + op_id + "[/color]")

func _cmd_duplicate_node(args: Array) -> void:
	if args.size() < 1:
		_print("Usage: duplicate_node <node_path> [new_name] [x_offset] [y_offset] [z_offset]")
		return
	
	var node_path = args[0]
	var node = get_node_or_null(node_path)
	if not node:
		_print("[color=red]Node not found: " + node_path + "[/color]")
		return
	
	var new_name = args[1] if args.size() > 1 else node.name + "_copy"
	var offset = Vector3.ZERO
	if args.size() >= 5:
		offset = Vector3(float(args[2]), float(args[3]), float(args[4]))
	
	# Create duplicate through Floodgate
	var params = {
		"class_name": node.get_class(),
		"parent_path": node.get_parent().get_path(),
		"name": new_name
	}
	
	if node.has_method("get_position"):
		params["properties"] = {"position": node.position + offset}
	
	var op_id = floodgate.queue_operation(floodgate.OperationType.CREATE_NODE, params, 5)
	_print("[color=green]Node duplication queued: " + op_id + "[/color]")

# ================================
# TRANSFORMATION OPERATIONS
# ================================

func _cmd_move_node(args: Array) -> void:
	if args.size() < 4:
		_print("Usage: move_node <node_path> <x> <y> <z>")
		return
	
	var node_path = args[0]
	var position = Vector3(float(args[1]), float(args[2]), float(args[3]))
	
	var params = {
		"node_path": node_path,
		"position": position
	}
	
	var op_id = floodgate.queue_operation(floodgate.OperationType.MOVE_NODE, params, 3)
	_print("[color=cyan]Node movement queued: " + op_id + "[/color]")

func _cmd_rotate_node(args: Array) -> void:
	if args.size() < 4:
		_print("Usage: rotate_node <node_path> <x> <y> <z> (degrees)")
		return
	
	var node_path = args[0]
	var rotation = Vector3(deg_to_rad(float(args[1])), deg_to_rad(float(args[2])), deg_to_rad(float(args[3])))
	
	var params = {
		"node_path": node_path,
		"rotation": rotation
	}
	
	var op_id = floodgate.queue_operation(floodgate.OperationType.ROTATE_NODE, params, 3)
	_print("[color=cyan]Node rotation queued: " + op_id + "[/color]")

func _cmd_scale_node(args: Array) -> void:
	if args.size() < 2:
		_print("Usage: scale_node <node_path> <scale> OR scale_node <node_path> <x> <y> <z>")
		return
	
	var node_path = args[0]
	var scale_vec = Vector3.ONE
	
	if args.size() == 2:
		var uniform_scale = float(args[1])
		scale_vec = Vector3(uniform_scale, uniform_scale, uniform_scale)
	elif args.size() >= 4:
		scale_vec = Vector3(float(args[1]), float(args[2]), float(args[3]))
	
	var params = {
		"node_path": node_path,
		"scale": scale_vec
	}
	
	var op_id = floodgate.queue_operation(floodgate.OperationType.SCALE_NODE, params, 3)
	_print("[color=cyan]Node scaling queued: " + op_id + "[/color]")

func _cmd_reparent_node(args: Array) -> void:
	if args.size() < 2:
		_print("Usage: reparent_node <node_path> <new_parent_path>")
		return
	
	var node_path = args[0]
	var new_parent_path = args[1]
	
	var params = {
		"node_path": node_path,
		"new_parent_path": new_parent_path
	}
	
	var op_id = floodgate.queue_operation(floodgate.OperationType.REPARENT_NODE, params, 4)
	_print("[color=cyan]Node reparenting queued: " + op_id + "[/color]")

# ================================
# PROPERTY OPERATIONS
# ================================

func _cmd_set_property(args: Array) -> void:
	if args.size() < 3:
		_print("Usage: set_property <node_path> <property_name> <value>")
		_print("Example: set_property /root/Main/Player position Vector3(0,5,0)")
		return
	
	var node_path = args[0]
	var property_name = args[1]
	var value_str = args[2]
	
	# Try to parse the value
	var value = _parse_value(value_str)
	
	var params = {
		"node_path": node_path,
		"property_name": property_name,
		"value": value
	}
	
	var op_id = floodgate.queue_operation(floodgate.OperationType.MODIFY_PROPERTY, params, 2)
	_print("[color=magenta]Property modification queued: " + op_id + "[/color]")

func _cmd_get_property(args: Array) -> void:
	if args.size() < 2:
		_print("Usage: get_property <node_path> <property_name>")
		return
	
	var node_path = args[0]
	var property_name = args[1]
	var node = get_node_or_null(node_path)
	
	if not node:
		_print("[color=red]Node not found: " + node_path + "[/color]")
		return
	
	if node.has_method("get"):
		var value = node.get(property_name)
		_print("[color=cyan]" + property_name + ": " + str(value) + "[/color]")
	else:
		_print("[color=red]Cannot get property from node[/color]")

func _cmd_list_properties(args: Array) -> void:
	if args.size() < 1:
		_print("Usage: list_properties <node_path>")
		return
	
	var node_path = args[0]
	var node = get_node_or_null(node_path)
	
	if not node:
		_print("[color=red]Node not found: " + node_path + "[/color]")
		return
	
	_print("[color=cyan]=== Properties for " + node_path + " ===[/color]")
	var property_list = node.get_property_list()
	for prop in property_list:
		if prop.has("name"):
			var value = node.get(prop.name)
			_print("  " + prop.name + ": " + str(value))

# ================================
# METHOD OPERATIONS
# ================================

func _cmd_call_method(args: Array) -> void:
	if args.size() < 2:
		_print("Usage: call_method <node_path> <method_name> [arg1] [arg2] ...")
		return
	
	var node_path = args[0]
	var method_name = args[1]
	var method_args = []
	
	# Parse arguments
	for i in range(2, args.size()):
		method_args.append(_parse_value(args[i]))
	
	var params = {
		"node_path": node_path,
		"method_name": method_name,
		"arguments": method_args
	}
	
	var op_id = floodgate.queue_operation(floodgate.OperationType.CALL_METHOD, params, 2)
	_print("[color=magenta]Method call queued: " + op_id + "[/color]")

func _cmd_list_methods(args: Array) -> void:
	if args.size() < 1:
		_print("Usage: list_methods <node_path>")
		return
	
	var node_path = args[0]
	var node = get_node_or_null(node_path)
	
	if not node:
		_print("[color=red]Node not found: " + node_path + "[/color]")
		return
	
	_print("[color=cyan]=== Methods for " + node_path + " ===[/color]")
	var method_list = node.get_method_list()
	for method in method_list:
		if method.has("name"):
			_print("  " + method.name + "()")

# ================================
# SIGNAL OPERATIONS
# ================================

func _cmd_connect_signal(args: Array) -> void:
	if args.size() < 4:
		_print("Usage: connect_signal <source_path> <signal_name> <target_path> <method_name>")
		return
	
	var source_path = args[0]
	var signal_name = args[1]
	var target_path = args[2]
	var method_name = args[3]
	
	var params = {
		"source_path": source_path,
		"signal_name": signal_name,
		"target_path": target_path,
		"method_name": method_name
	}
	
	var op_id = floodgate.queue_operation(floodgate.OperationType.CONNECT_SIGNAL, params, 2)
	_print("[color=green]Signal connection queued: " + op_id + "[/color]")

func _cmd_disconnect_signal(args: Array) -> void:
	if args.size() < 4:
		_print("Usage: disconnect_signal <source_path> <signal_name> <target_path> <method_name>")
		return
	
	var source_path = args[0]
	var signal_name = args[1]
	var target_path = args[2]
	var method_name = args[3]
	
	var params = {
		"source_path": source_path,
		"signal_name": signal_name,
		"target_path": target_path,
		"method_name": method_name
	}
	
	var op_id = floodgate.queue_operation(floodgate.OperationType.DISCONNECT_SIGNAL, params, 2)
	_print("[color=yellow]Signal disconnection queued: " + op_id + "[/color]")

func _cmd_emit_signal(args: Array) -> void:
	if args.size() < 2:
		_print("Usage: emit_signal <node_path> <signal_name> [arg1] [arg2] ...")
		return
	
	var node_path = args[0]
	var signal_name = args[1]
	var signal_args = []
	
	for i in range(2, args.size()):
		signal_args.append(_parse_value(args[i]))
	
	var params = {
		"node_path": node_path,
		"signal_name": signal_name,
		"arguments": signal_args
	}
	
	var op_id = floodgate.queue_operation(floodgate.OperationType.EMIT_SIGNAL, params, 1)
	_print("[color=magenta]Signal emission queued: " + op_id + "[/color]")

func _cmd_list_signals(args: Array) -> void:
	if args.size() < 1:
		_print("Usage: list_signals <node_path>")
		return
	
	var node_path = args[0]
	var node = get_node_or_null(node_path)
	
	if not node:
		_print("[color=red]Node not found: " + node_path + "[/color]")
		return
	
	_print("[color=cyan]=== Signals for " + node_path + " ===[/color]")
	var signal_list = node.get_signal_list()
	for signal_info in signal_list:
		if signal_info.has("name"):
			_print("  " + signal_info.name)

# ================================
# ASSET OPERATIONS
# ================================

func _cmd_load_asset(args: Array) -> void:
	if args.size() < 2:
		_print("Usage: load_asset <asset_type> <asset_path>")
		_print("Types: SCENE, MESH, TEXTURE, AUDIO, SCRIPT, SHADER, MATERIAL")
		return
	
	var asset_type = args[0].to_upper()
	var asset_path = args[1]
	
	var params = {
		"asset_type": asset_type,
		"asset_path": asset_path
	}
	
	var op_id = floodgate.queue_operation(floodgate.OperationType.LOAD_ASSET, params, 3)
	_print("[color=blue]Asset loading queued: " + op_id + "[/color]")

func _cmd_unload_asset(args: Array) -> void:
	if args.size() < 1:
		_print("Usage: unload_asset <asset_path>")
		return
	
	var asset_path = args[0]
	var params = {"asset_path": asset_path}
	
	var op_id = floodgate.queue_operation(floodgate.OperationType.UNLOAD_ASSET, params, 1)
	_print("[color=yellow]Asset unloading queued: " + op_id + "[/color]")

func _cmd_list_assets(_args: Array) -> void:
	_print("[color=cyan]=== Loaded Assets ===[/color]")
	if floodgate.loaded_assets.is_empty():
		_print("No assets loaded")
		return
	
	for asset_path in floodgate.loaded_assets:
		_print("  " + asset_path)

# ================================
# SCENE OPERATIONS
# ================================

func _cmd_save_scene(args: Array) -> void:
	if args.size() < 1:
		_print("Usage: save_scene <file_path>")
		return
	
	var file_path = args[0]
	var scene = get_tree().current_scene
	
	if scene:
		var packed_scene = PackedScene.new()
		packed_scene.pack(scene)
		var result = ResourceSaver.save(packed_scene, file_path)
		
		if result == OK:
			_print("[color=green]Scene saved to: " + file_path + "[/color]")
		else:
			_print("[color=red]Failed to save scene[/color]")
	else:
		_print("[color=red]No current scene to save[/color]")

func _cmd_load_scene(args: Array) -> void:
	if args.size() < 1:
		_print("Usage: load_scene <file_path>")
		return
	
	var file_path = args[0]
	var scene = load(file_path)
	
	if scene:
		get_tree().change_scene_to_packed(scene)
		_print("[color=green]Scene loaded: " + file_path + "[/color]")
	else:
		_print("[color=red]Failed to load scene: " + file_path + "[/color]")

func _cmd_clear_scene(_args: Array) -> void:
	var scene = get_tree().current_scene
	if scene:
		# Queue deletion of all children
		for child in scene.get_children():
			var params = {"node_path": child.get_path()}
			floodgate.queue_operation(floodgate.OperationType.DELETE_NODE, params, 1)
		
		_print("[color=yellow]Scene clearing queued[/color]")
	else:
		_print("[color=red]No current scene[/color]")

func _cmd_list_nodes(args: Array) -> void:
	var root_path = "/root"
	if args.size() > 0:
		root_path = args[0]
	
	var root_node = get_node_or_null(root_path)
	if not root_node:
		_print("[color=red]Node not found: " + root_path + "[/color]")
		return
	
	_print("[color=cyan]=== Node Tree from " + root_path + " ===[/color]")
	_print_node_tree(root_node, 0)

# ================================
# FLOODGATE STATUS
# ================================

func _cmd_floodgate_status(_args: Array) -> void:
	_print("[color=cyan]=== Floodgate Controller Status ===[/color]")
	_print("Operation queue size: " + str(floodgate.operation_queue.size()))
	_print("Max queue size: " + str(floodgate.MAX_QUEUE_SIZE))
	_print("Processing operation: " + str(floodgate.processing_operation))
	_print("Registered nodes: " + str(floodgate.registered_nodes.size()))
	_print("Loaded assets: " + str(floodgate.loaded_assets.size()))
	_print("Failed operations: " + str(floodgate.failed_operations.size()))

func _cmd_floodgate_queue(_args: Array) -> void:
	_print("[color=cyan]=== Operation Queue ===[/color]")
	if floodgate.operation_queue.is_empty():
		_print("Queue is empty")
		return
	
	for i in range(min(10, floodgate.operation_queue.size())):
		var op = floodgate.operation_queue[i]
		_print("  [" + str(i) + "] " + op.id + " - Type: " + _get_operation_name(op.type) + " Priority: " + str(op.priority))

func _cmd_floodgate_history(_args: Array) -> void:
	_print("[color=cyan]=== Recent Operation History ===[/color]")
	if floodgate.operation_history.is_empty():
		_print("No operations in history")
		return
	
	var recent_count = min(10, floodgate.operation_history.size())
	for i in range(recent_count):
		var op = floodgate.operation_history[-(i+1)]  # Get from end
		var status_color = "green" if op.status == "completed" else "red"
		_print("  [color=" + status_color + "]" + op.id + " - " + _get_operation_name(op.type) + " - " + op.status + "[/color]")

# ================================
# HELPER FUNCTIONS
# ================================

func _parse_value(value_str: String):
	# Try to parse common types
	if value_str.is_valid_int():
		return int(value_str)
	elif value_str.is_valid_float():
		return float(value_str)
	elif value_str.to_lower() in ["true", "false"]:
		return value_str.to_lower() == "true"
	elif value_str.begins_with("Vector3(") and value_str.ends_with(")"):
		# Parse Vector3
		var coords = value_str.substr(8, value_str.length() - 9).split(",")
		if coords.size() == 3:
			return Vector3(float(coords[0]), float(coords[1]), float(coords[2]))
	elif value_str.begins_with("Vector2(") and value_str.ends_with(")"):
		# Parse Vector2
		var coords = value_str.substr(8, value_str.length() - 9).split(",")
		if coords.size() == 2:
			return Vector2(float(coords[0]), float(coords[1]))
	
	# Return as string if no parsing worked
	return value_str

func _get_operation_name(op_type) -> String:
	match op_type:
		floodgate.OperationType.CREATE_NODE: return "CREATE_NODE"
		floodgate.OperationType.DELETE_NODE: return "DELETE_NODE"
		floodgate.OperationType.MOVE_NODE: return "MOVE_NODE"
		floodgate.OperationType.ROTATE_NODE: return "ROTATE_NODE"
		floodgate.OperationType.SCALE_NODE: return "SCALE_NODE"
		floodgate.OperationType.REPARENT_NODE: return "REPARENT_NODE"
		floodgate.OperationType.LOAD_ASSET: return "LOAD_ASSET"
		floodgate.OperationType.UNLOAD_ASSET: return "UNLOAD_ASSET"
		floodgate.OperationType.MODIFY_PROPERTY: return "MODIFY_PROPERTY"
		floodgate.OperationType.CALL_METHOD: return "CALL_METHOD"
		floodgate.OperationType.EMIT_SIGNAL: return "EMIT_SIGNAL"
		floodgate.OperationType.CONNECT_SIGNAL: return "CONNECT_SIGNAL"
		floodgate.OperationType.DISCONNECT_SIGNAL: return "DISCONNECT_SIGNAL"
		_: return "UNKNOWN"

func _print_node_tree(node: Node, depth: int) -> void:
	var indent = "  ".repeat(depth)
	var node_info = node.name + " (" + node.get_class() + ")"
	_print(indent + "├─ " + node_info)
	
	for child in node.get_children():
		_print_node_tree(child, depth + 1)

func _print(text: String) -> void:
	if console_manager:
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