# ==================================================
# SCRIPT NAME: grid_list_console_bridge.gd
# DESCRIPTION: Bridges grid UI, list UI, and console commands
# PURPOSE: Unified interface where visual = textual
# CREATED: 2025-05-25 - Everything is a command
# ==================================================

extends UniversalBeingBase
# Interface registry - maps visual elements to commands
var interface_registry: Dictionary = {
	"grids": {},      # Grid position -> command
	"lists": {},      # List index -> command  
	"pages": {},      # Page number -> item set
	"shortcuts": {}   # Key combo -> command
}

# Command patterns
var command_patterns: Dictionary = {
	"spawn": "create %s at %s",
	"select": "select %s",
	"move": "move %s to %s",
	"delete": "delete %s",
	"modify": "set %s.%s = %s",
	"execute": "run %s with %s"
}

# Visual to command mapping
var visual_actions: Dictionary = {
	"click": "select",
	"double_click": "execute",
	"drag": "move",
	"right_click": "context",
	"hover": "preview"
}

signal command_generated(command: String, source: String)
signal visual_action_performed(action: String, target: Variant)

## Register grid cell to command
# INPUT: Grid position, command string
# PROCESS: Maps grid location to executable command
# OUTPUT: None
# CHANGES: interface_registry
# CONNECTION: UI setup

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	# Pentagon setup - override in child classes
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
func register_grid_cell(x: int, y: int, page: int, command: String) -> void:
	var key = "%d_%d_%d" % [page, x, y]
	interface_registry.grids[key] = {
		"command": command,
		"position": Vector2i(x, y),
		"page": page,
		"type": "grid_cell"
	}

## Register list item to command
# INPUT: List index, command string
# PROCESS: Maps list position to command
# OUTPUT: None
# CHANGES: interface_registry
# CONNECTION: List population
func register_list_item(index: int, page: int, command: String) -> void:
	var key = "%d_%d" % [page, index]
	interface_registry.lists[key] = {
		"command": command,
		"index": index,
		"page": page,
		"type": "list_item"
	}

## Convert visual action to command
# INPUT: Action type, target info
# PROCESS: Translates UI interaction to console command
# OUTPUT: Command string
# CHANGES: None
# CONNECTION: Input handling
func visual_to_command(action: String, target: Dictionary) -> String:
	var base_action = visual_actions.get(action, "select")
	var command = ""
	
	match target.type:
		"grid_cell":
			command = "%s grid:%d,%d" % [base_action, target.position.x, target.position.y]
		"list_item":
			command = "%s list:%d" % [base_action, target.index]
		"entity":
			command = "%s %s" % [base_action, target.id]
		_:
			command = "%s %s" % [base_action, str(target)]
	
	emit_signal("command_generated", command, action)
	return command

## Execute unified command
# INPUT: Command string
# PROCESS: Executes regardless of source (UI/console)
# OUTPUT: Result dictionary
# CHANGES: Game state
# CONNECTION: All input methods
func execute_unified_command(command: String, source: String = "console") -> Dictionary:
	var result = {
		"success": false,
		"message": "",
		"data": null
	}
	
	# Parse command
	var parts = command.split(" ")
	if parts.is_empty():
		result.message = "Empty command"
		return result
	
	var action = parts[0]
	var args = parts.slice(1)
	
	# Route to appropriate handler
	match action:
		"select":
			result = _handle_select(args)
		"create", "spawn":
			result = _handle_create(args)
		"move":
			result = _handle_move(args)
		"delete":
			result = _handle_delete(args)
		"page":
			result = _handle_page_change(args)
		"mode":
			result = _handle_mode_change(args)
		_:
			# Forward to game console
			if has_node("/root/ConsoleManager"):
				get_node("/root/ConsoleManager").execute_command(command)
				result.success = true
				result.message = "Forwarded to game console"
	
	# Log command history
	_log_command(command, source, result)
	
	return result

## Smart command completion
# INPUT: Partial command
# PROCESS: Suggests completions based on context
# OUTPUT: Array of suggestions
# CHANGES: None
# CONNECTION: Console autocomplete
func get_command_suggestions(partial: String) -> Array:
	var suggestions = []
	
	# Split partial command
	var parts = partial.split(" ")
	
	if parts.size() == 1:
		# Suggest actions
		for action in ["select", "create", "move", "delete", "page", "list", "grid"]:
			if action.begins_with(parts[0]):
				suggestions.append(action)
	else:
		# Context-aware suggestions
		var action = parts[0]
		match action:
			"create", "spawn":
				suggestions = _get_entity_types()
			"page":
				suggestions = _get_page_numbers()
			"select":
				suggestions = _get_selectable_items()
	
	return suggestions

## Page-based item access
# INPUT: Page number, item index
# PROCESS: Calculates global index from page+local
# OUTPUT: Global item reference
# CHANGES: None
# CONNECTION: Pagination system
func get_item_from_page(page: int, index: int) -> Dictionary:
	var global_index = page * 999 + index
	
	return {
		"global_index": global_index,
		"page": page,
		"local_index": index,
		"command": "select item_%d" % global_index
	}

## Grid to list conversion
# INPUT: Grid coordinates
# PROCESS: Converts 2D grid to 1D list index
# OUTPUT: List index
# CHANGES: None
# CONNECTION: Display mode switching
func grid_to_list_index(x: int, y: int, columns: int) -> int:
	return y * columns + x

## List to grid conversion
# INPUT: List index, column count
# PROCESS: Converts 1D index to 2D coordinates
# OUTPUT: Grid position
# CHANGES: None
# CONNECTION: Display mode switching
func list_to_grid_pos(index: int, columns: int) -> Vector2i:
	return Vector2i(
		index % columns,
		index / columns
	)

## Command handlers
func _handle_select(args: Array) -> Dictionary:
	if args.is_empty():
		return {"success": false, "message": "No target specified"}
	
	var target = args[0]
	
	# Handle different target formats
	if target.begins_with("grid:"):
		var coords = target.substr(5).split(",")
		if coords.size() == 2:
			var x = int(coords[0])
			var y = int(coords[1])
			return {"success": true, "data": {"type": "grid", "x": x, "y": y}}
		else:
			return {"success": false, "message": "Invalid grid coordinates"}
	
	elif target.begins_with("list:"):
		var index = int(target.substr(5))
		return {"success": true, "data": {"type": "list", "index": index}}
	
	else:
		# Direct entity selection
		return {"success": true, "data": {"type": "entity", "id": target}}

func _handle_create(args: Array) -> Dictionary:
	if args.size() < 1:
		return {"success": false, "message": "Specify what to create"}
	
	var entity_type = args[0]
	var position = "cursor"
	
	if args.size() > 2 and args[1] == "at":
		position = args[2]
	
	# Generate creation command
	var command = command_patterns.spawn % [entity_type, position]
	
	return {
		"success": true,
		"message": "Creating %s" % entity_type,
		"data": {"command": command}
	}

func _handle_page_change(args: Array) -> Dictionary:
	if args.is_empty():
		return {"success": false, "message": "Specify page number"}
	
	var page_num = int(args[0])
	
	return {
		"success": true,
		"message": "Switching to page %d" % page_num,
		"data": {"page": page_num}
	}

## Helper functions
func _get_entity_types() -> Array:
	return ["ragdoll", "tree", "rock", "box", "sphere", "light", "particle"]

func _get_page_numbers() -> Array:
	var pages = []
	for i in range(10):  # Show first 10 pages
		pages.append(str(i))
	return pages

func _get_selectable_items() -> Array:
	var items = []
	# Get from current context
	var tree = get_tree()
	if tree:
		for node in tree.get_nodes_in_group("selectable"):
			items.append(node.name)
	return items

func _log_command(command: String, source: String, result: Dictionary) -> void:
	# Command history for undo/redo
	var history_entry = {
		"command": command,
		"source": source,
		"timestamp": Time.get_ticks_msec(),
		"result": result
	}
	
	# Store in appropriate system
	if has_node("/root/MultiLayerRecordSystem"):
		get_node("/root/MultiLayerRecordSystem").store_with_metadata(
			"cmd_%d" % Time.get_ticks_msec(),
			history_entry,
			"active"
		)
func _handle_move(args: Array) -> Dictionary:
	if args.size() < 3:
		return {"success": false, "message": "Usage: move <source> to <destination>"}
	
	var source = args[0]
	var destination = args[2] if args[1] == "to" else args[1]
	
	return {
		"success": true,
		"message": "Moving %s to %s" % [source, destination],
		"data": {"source": source, "destination": destination}
	}

func _handle_delete(args: Array) -> Dictionary:
	if args.is_empty():
		return {"success": false, "message": "Specify what to delete"}
	
	var target = args[0]
	
	return {
		"success": true,
		"message": "Deleting %s" % target,
		"data": {"target": target}
	}

func _handle_mode_change(args: Array) -> Dictionary:
	if args.is_empty():
		return {"success": false, "message": "Specify display mode"}
	
	var mode = args[0]
	
	return {
		"success": true,
		"message": "Changing to %s mode" % mode,
		"data": {"mode": mode}
	}
