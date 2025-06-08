# ==================================================
# UNIVERSE COMMANDS - Reality Creation Interface
# PURPOSE: Extend command system with universe manipulation
# LOCATION: core/systems/UniverseCommands.gd
# ==================================================

extends Node
class_name UniverseCommands

## Command processor reference
var command_processor: UniversalCommandProcessor
var universe_manager: UniverseManager
var poetic_logger: PoeticLogger

func _ready() -> void:
	# Get references to required systems
	command_processor = get_node("/root/UniversalCommandProcessor")
	universe_manager = get_node("/root/UniverseManager")
	poetic_logger = get_node("/root/PoeticLogger")
	
	# Register universe commands
	_register_universe_commands()

func _register_universe_commands() -> void:
	"""Register all universe-related commands"""
	
	# Universe creation and navigation
	command_processor.register_command("universe", _cmd_universe, "Create or manage universes")
	command_processor.register_command("create_universe", _cmd_create_universe, "Birth a new universe")
	command_processor.register_command("enter", _cmd_enter_universe, "Enter a universe")
	command_processor.register_command("exit", _cmd_exit_universe, "Exit to parent universe")
	command_processor.register_command("multiverse", _cmd_multiverse, "Show universe tree")
	
	# Reality manipulation
	command_processor.register_command("set_physics", _cmd_set_physics, "Modify physics laws")
	command_processor.register_command("set_time", _cmd_set_time, "Modify time flow")
	command_processor.register_command("set_consciousness", _cmd_set_consciousness, "Toggle consciousness")
	
	# Universe inspection
	command_processor.register_command("universe_info", _cmd_universe_info, "Inspect universe properties")
	command_processor.register_command("list_universes", _cmd_list_universes, "List all universes")
	command_processor.register_command("universe_beings", _cmd_universe_beings, "List beings in universe")

## UNIVERSE CREATION COMMANDS ==================================================

func _cmd_universe(args: Array) -> Dictionary:
	"""Main universe command handler"""
	if args.is_empty():
		return {
			"success": false,
			"message": "Usage: universe <create|enter|exit|info|list>"
		}
	
	var subcommand = args[0]
	var subargs = args.slice(1)
	
	match subcommand:
		"create":
			return _cmd_create_universe(subargs)
		"enter":
			return _cmd_enter_universe(subargs)
		"exit":
			return _cmd_exit_universe(subargs)
		"info":
			return _cmd_universe_info(subargs)
		"list":
			return _cmd_list_universes(subargs)
		_:
			return {
				"success": false,
				"message": "Unknown subcommand: " + subcommand
			}
func _cmd_create_universe(args: Array) -> Dictionary:
	"""Create a new universe"""
	if args.is_empty():
		return {
			"success": false,
			"message": "Usage: create_universe <name> [parent_name]"
		}
	
	var universe_name = args[0]
	var parent_universe = null
	
	# Get parent universe if specified
	if args.size() > 1:
		parent_universe = universe_manager.find_universe_by_name(args[1])
		if not parent_universe:
			return {
				"success": false,
				"message": "Parent universe '%s' not found" % args[1]
			}
	
	# Create the universe
	var new_universe = universe_manager.create_universe(universe_name, parent_universe, {
		"created_by": "console_command",
		"creation_method": "divine_will"
	})
	
	return {
		"success": true,
		"message": "Universe '%s' manifested from the void" % universe_name,
		"data": {
			"uuid": new_universe.uuid,
			"parent": new_universe.parent_universe.name if new_universe.parent_universe else "None"
		}
	}

func _cmd_enter_universe(args: Array) -> Dictionary:
	"""Enter a universe"""
	if args.is_empty():
		return {
			"success": false,
			"message": "Usage: enter <universe_name>"
		}
	
	var universe = universe_manager.find_universe_by_name(args[0])
	if not universe:
		return {
			"success": false,
			"message": "Universe '%s' not found" % args[0]
		}
	
	universe_manager.enter_universe(universe)
	
	return {
		"success": true,
		"message": "Consciousness descended into Universe '%s'" % universe.name,
		"data": {"universe": universe.name}
	}

func _cmd_exit_universe(args: Array) -> Dictionary:
	"""Exit current universe"""
	var exit_to = args[0] if args.size() > 0 else "parent"
	
	var success = false
	var message = ""
	
	match exit_to:
		"parent":
			success = universe_manager.exit_to_parent()
			message = "Ascended to parent universe" if success else "Cannot exit prime universe"
		"previous":
			success = universe_manager.exit_to_previous()
			message = "Returned to previous universe" if success else "No previous universe to return to"
		_:
			# Try to enter specific universe
			var universe = universe_manager.find_universe_by_name(exit_to)
			if universe:
				universe_manager.enter_universe(universe)
				success = true
				message = "Transcended to Universe '%s'" % universe.name
			else:
				message = "Unknown universe: " + exit_to
	
	return {
		"success": success,
		"message": message,
		"data": {"current_universe": universe_manager.active_universe.name}
	}
## REALITY MANIPULATION COMMANDS ==================================================

func _cmd_set_physics(args: Array) -> Dictionary:
	"""Modify physics in current universe"""
	if args.size() < 2:
		return {
			"success": false,
			"message": "Usage: set_physics <property> <value>"
		}
	
	var property = args[0]
	var value = str_to_var(args[1])
	
	match property:
		"gravity":
			universe_manager.set_universe_rule(
				universe_manager.active_universe,
				"physics_gravity",
				value
			)
			return {
				"success": true,
				"message": "Gravity redefined to %s" % value
			}
		_:
			return {
				"success": false,
				"message": "Unknown physics property: " + property
			}

func _cmd_set_time(args: Array) -> Dictionary:
	"""Modify time flow in current universe"""
	if args.is_empty():
		return {
			"success": false,
			"message": "Usage: set_time <scale>"
		}
	
	var time_scale = str_to_var(args[0])
	universe_manager.set_universe_rule(
		universe_manager.active_universe,
		"time_scale",
		time_scale
	)
	
	return {
		"success": true,
		"message": "Time now flows at %sx speed" % time_scale
	}

func _cmd_set_consciousness(args: Array) -> Dictionary:
	"""Toggle consciousness in current universe"""
	var enabled = true
	if args.size() > 0:
		enabled = args[0].to_lower() in ["true", "on", "1", "yes"]
	
	universe_manager.set_universe_rule(
		universe_manager.active_universe,
		"consciousness_enabled",
		enabled
	)
	
	return {
		"success": true,
		"message": "Consciousness %s in this universe" % ["awakened" if enabled else "dormant"]
	}

## UNIVERSE INSPECTION COMMANDS ==================================================

func _cmd_universe_info(args: Array) -> Dictionary:
	"""Get info about a universe"""
	var universe = universe_manager.active_universe
	
	if args.size() > 0:
		universe = universe_manager.find_universe_by_name(args[0])
		if not universe:
			return {
				"success": false,
				"message": "Universe '%s' not found" % args[0]
			}
	
	var info = universe_manager.get_universe_info(universe)
	
	var message = """
Universe: %s
UUID: %s
Parent: %s
Children: %d
Beings: %d
Age: %.1f seconds
Rules:
  Gravity: %s
  Time Scale: %s
  Consciousness: %s
  Evolution Rate: %s
""" % [
		info.name,
		info.uuid.substr(0, 8) + "...",
		info.parent,
		info.children,
		info.beings,
		info.age,
		info.rules.physics_gravity,
		info.rules.time_scale,
		"Enabled" if info.rules.consciousness_enabled else "Disabled",
		info.rules.evolution_rate
	]
	
	return {
		"success": true,
		"message": message.strip_edges(),
		"data": info
	}

func _cmd_list_universes(args: Array) -> Dictionary:
	"""List all universes"""
	var universes = universe_manager.get_all_universes()
	
	var message = "=== The Multiverse ===\n"
	for universe in universes:
		var depth = universe_manager.get_universe_depth(universe)
		var indent = "  ".repeat(depth)
		var active = " [ACTIVE]" if universe == universe_manager.active_universe else ""
		message += "%s• %s (Beings: %d)%s\n" % [
			indent,
			universe.name,
			universe.beings.size(),
			active
		]
	
	return {
		"success": true,
		"message": message.strip_edges(),
		"data": {"universe_count": universes.size()}
	}

func _cmd_universe_beings(args: Array) -> Dictionary:
	"""List beings in current or specified universe"""
	var universe = universe_manager.active_universe
	
	if args.size() > 0:
		universe = universe_manager.find_universe_by_name(args[0])
		if not universe:
			return {
				"success": false,
				"message": "Universe '%s' not found" % args[0]
			}
	
	var message = "Beings in Universe '%s':\n" % universe.name
	
	if universe.beings.is_empty():
		message += "  (void - no beings exist yet)"
	else:
		for being in universe.beings:
			var type_str = ""
			if being.has_method("get_being_type"):
				type_str = " [%s]" % being.get_being_type()
			message += "  • %s%s\n" % [being.name, type_str]
	
	return {
		"success": true,
		"message": message.strip_edges(),
		"data": {"being_count": universe.beings.size()}
	}

func _cmd_multiverse(args: Array) -> Dictionary:
	"""Show the multiverse tree structure"""
	var tree = universe_manager.get_universe_tree()
	
	var message = "=== Multiverse Tree ===\n"
	message += _format_universe_tree(tree, 0)
	
	return {
		"success": true,
		"message": message.strip_edges(),
		"data": tree
	}

## HELPER FUNCTIONS ==================================================

func _format_universe_tree(tree: Dictionary, depth: int) -> String:
	"""Recursively format universe tree for display"""
	var result = ""
	var indent = "  ".repeat(depth)
	
	for universe_name in tree:
		var node = tree[universe_name]
		result += "%s%s [%d beings]\n" % [indent, universe_name, node.beings]
		
		if node.children.size() > 0:
			result += _format_universe_tree(node.children, depth + 1)
	
	return result