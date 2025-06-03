# ==================================================
# SCRIPT NAME: UniverseConsoleComponent.gd
# DESCRIPTION: Console component for universe management and navigation
# PURPOSE: Provide console commands for recursive universe creation/editing
# CREATED: 2025-06-02 - The Console of Infinite Realities
# AUTHOR: JSH + Claude (Opus 4) - Console Architects
# ==================================================

extends Node
class_name UniverseConsoleComponent

# Godot lifecycle functions removed - base UniversalBeing handles bridging to Pentagon Architecture

# ===== UNIVERSE CONSOLE PROPERTIES =====

var console_being: Node = null
var current_universe: Node = null
var universe_stack: Array[Node] = []  # Navigation history
var akashic_library: Node = null
var command_processor: Node = null

# Command registry
var universe_commands: Dictionary = {
	"universe": _cmd_universe,
	"portal": _cmd_portal,
	"inspect": _cmd_inspect,
	"enter": _cmd_enter,
	"exit": _cmd_exit,
	"list": _cmd_list,
	"rules": _cmd_rules,
	"setrule": _cmd_setrule,
	"lod": _cmd_lod,
	"tree": _cmd_tree,
	"save": _cmd_save,
	"load": _cmd_load,
	"merge": _cmd_merge,
	"split": _cmd_split
}

signal universe_created(universe: Node)
signal universe_entered(universe: Node)
signal universe_exited(universe: Node)
signal portal_created(from: Node, to: Node)

func initialize(console: Node) -> void:
	"""Initialize with the console being"""
	console_being = console
	_register_commands()
	
	# Start in the main universe (scene root)
	current_universe = get_tree().root.get_node("Main")
	
	if akashic_library:
		akashic_library.inscribe_genesis("🌌 The Universe Console awakens, ready to sculpt realities...")

func _register_commands() -> void:
	"""Register universe commands with the console"""
	if not console_being:
		return
	
	# Register each command
	for cmd_name in universe_commands:
		if console_being.has_method("register_command"):
			console_being.register_command(cmd_name, self, universe_commands[cmd_name])

# ===== COMMAND IMPLEMENTATIONS =====

func _cmd_universe(args: Array) -> String:
	"""Universe command: create, delete, rename"""
	if args.is_empty():
		return "Usage: universe <create|delete|rename> [name]"
	
	var action = args[0]
	match action:
		"create":
			var name = args[1] if args.size() > 1 else "Universe_%d" % randi()
			return _create_universe(name)
		"delete":
			var name = args[1] if args.size() > 1 else ""
			return _delete_universe(name)
		"rename":
			if args.size() < 2:
				return "Usage: universe rename <new_name>"
			return _rename_universe(args[1])
		_:
			return "Unknown universe action: %s" % action

func _create_universe(universe_name: String) -> String:
	"""Create a new universe"""
	var UniverseClass = load("res://beings/UniverseUniversalBeing.gd")
	if not UniverseClass:
		return "ERROR: UniverseUniversalBeing class not found!"
	
	var new_universe = UniverseClass.new()
	new_universe.universe_name = universe_name
	new_universe.universe_seed = randi()
	
	# Add to current universe or main scene
	if current_universe and current_universe.has_method("add_being_to_universe"):
		current_universe.add_being_to_universe(new_universe)
	else:
		get_tree().root.get_node("Main").add_child(new_universe)
	
	universe_created.emit(new_universe)
	
	if akashic_library:
		akashic_library.inscribe_genesis("🌌 Universe '%s' sparked into being through console command!" % universe_name)
	
	return "✨ Universe '%s' created! Use 'enter %s' to explore it." % [universe_name, universe_name]

func _delete_universe(universe_name: String) -> String:
	"""Delete a universe (with safety check)"""
	var universe = _find_universe_by_name(universe_name)
	if not universe:
		return "Universe '%s' not found." % universe_name
	
	if universe == current_universe:
		return "Cannot delete current universe! Exit first with 'exit'."
	
	# Check if it has beings
	var info = universe.get_universe_info()
	if info.get("beings", 0) > 0:
		return "Universe contains %d beings. Use 'universe delete %s --force' to confirm." % [info.beings, universe_name]
	
	universe.queue_free()
	return "Universe '%s' dissolved back into the void..." % universe_name

func _rename_universe(new_name: String) -> String:
	"""Rename current universe"""
	if not current_universe or not current_universe.has_method("universe_name"):
		return "Not currently in a universe!"
	
	var old_name = current_universe.universe_name
	current_universe.universe_name = new_name
	
	if akashic_library:
		akashic_library.inscribe_genesis("🌌 Universe '%s' transformed into '%s'" % [old_name, new_name])
	
	return "Universe renamed from '%s' to '%s'" % [old_name, new_name]

func _cmd_portal(args: Array) -> String:
	"""Portal command: create portals between universes"""
	if args.size() < 2:
		return "Usage: portal <target_universe> [bidirectional]"
	
	var target_name = args[0]
	var bidirectional = args.size() > 1 and args[1] == "true"
	
	var target_universe = _find_universe_by_name(target_name)
	if not target_universe:
		return "Target universe '%s' not found!" % target_name
	
	if not current_universe or not current_universe.has_method("create_portal_to"):
		return "Not currently in a universe!"
	
	# Create portal
	current_universe.create_portal_to(target_universe, "Console User")
	
	if bidirectional:
		target_universe.create_portal_to(current_universe, "Console User")
	
	portal_created.emit(current_universe, target_universe)
	
	return "🌀 Portal created from '%s' to '%s'%s" % [
		current_universe.universe_name,
		target_universe.universe_name,
		" (bidirectional)" if bidirectional else ""
	]

func _cmd_inspect(args: Array) -> String:
	"""Inspect current or specified universe"""
	var universe = current_universe
	if args.size() > 0:
		universe = _find_universe_by_name(args[0])
		if not universe:
			return "Universe '%s' not found!" % args[0]
	
	if not universe or not universe.has_method("get_universe_info"):
		return "No universe to inspect!"
	
	var info = universe.get_universe_info()
	var output = "🌌 Universe: %s\n" % info.get("name", "Unknown")
	output += "  Age: %.2f seconds\n" % info.get("age", 0.0)
	output += "  Beings: %d / %d\n" % [info.get("beings", 0), info.rules.get("max_beings", 1000)]
	output += "  Sub-universes: %d\n" % info.get("sub_universes", 0)
	output += "  Total Consciousness: %.2f\n" % info.get("consciousness", 0.0)
	output += "  Entropy Level: %.4f\n" % info.get("entropy", 0.0)
	
	return output

func _cmd_enter(args: Array) -> String:
	"""Enter a universe"""
	if args.is_empty():
		return "Usage: enter <universe_name>"
	
	var target_name = args[0]
	var target_universe = _find_universe_by_name(target_name)
	
	if not target_universe:
		return "Universe '%s' not found!" % target_name
	
	# Push current universe to stack
	if current_universe:
		universe_stack.push_back(current_universe)
	
	# Enter new universe
	current_universe = target_universe
	universe_entered.emit(target_universe)
	
	if akashic_library:
		akashic_library.inscribe_genesis("🌌 Console user entered universe '%s'" % target_name)
	
	return "🌌 Entered universe '%s'. Use 'exit' to return." % target_name

func _cmd_exit(args: Array) -> String:
	"""Exit current universe"""
	if universe_stack.is_empty():
		return "Already at root level!"
	
	var previous_universe = universe_stack.pop_back()
	var exited_universe = current_universe
	current_universe = previous_universe
	
	universe_exited.emit(exited_universe)
	
	if akashic_library:
		akashic_library.inscribe_genesis("🌌 Console user exited universe '%s'" % exited_universe.universe_name)
	
	return "🌌 Returned to universe '%s'" % current_universe.universe_name

func _cmd_list(args: Array) -> String:
	"""List universes or beings in current universe"""
	var list_type = args[0] if args.size() > 0 else "universes"
	
	match list_type:
		"universes":
			return _list_universes()
		"beings":
			return _list_beings()
		"portals":
			return _list_portals()
		_:
			return "Usage: list <universes|beings|portals>"

func _list_universes() -> String:
	"""List all accessible universes"""
	var output = "🌌 Accessible Universes:\n"
	var universes = _find_all_universes()
	
	if universes.is_empty():
		return output + "  No universes found!"
	
	for universe in universes:
		var info = universe.get_universe_info()
		var marker = " ← current" if universe == current_universe else ""
		output += "  • %s (beings: %d, age: %.1fs)%s\n" % [
			info.name, info.beings, info.age, marker
		]
	
	return output

func _cmd_rules(args: Array) -> String:
	"""Display universe rules"""
	if not current_universe or not current_universe.has_method("get_universe_info"):
		return "Not currently in a universe!"
	
	var info = current_universe.get_universe_info()
	var rules = info.get("rules", {})
	
	var output = "🌌 Universe Rules for '%s':\n" % info.name
	for rule_name in rules:
		output += "  %s: %s\n" % [rule_name, str(rules[rule_name])]
	
	return output

func _cmd_setrule(args: Array) -> String:
	"""Set a universe rule"""
	if args.size() < 2:
		return "Usage: setrule <rule_name> <value>"
	
	if not current_universe or not current_universe.has_method("set_universe_rule"):
		return "Not currently in a universe!"
	
	var rule_name = args[0]
	var value_str = args[1]
	
	# Parse value based on type
	var value = _parse_rule_value(value_str)
	
	current_universe.set_universe_rule(rule_name, value, "Console User")
	
	return "✨ Rule '%s' set to %s" % [rule_name, str(value)]

func _cmd_lod(args: Array) -> String:
	"""Manage Level of Detail settings"""
	if args.is_empty():
		return "Usage: lod <set|get> [level]"
	
	if not current_universe:
		return "Not currently in a universe!"
	
	var action = args[0]
	match action:
		"get":
			return "Current LOD: %d (quality: %.1f%%)" % [
				current_universe.current_lod,
				current_universe.simulation_quality * 100
			]
		"set":
			if args.size() < 2:
				return "Usage: lod set <0-4>"
			var level = int(args[1])
			current_universe.current_lod = clamp(level, 0, 4)
			current_universe.apply_lod_settings()
			return "LOD set to %d" % level
		_:
			return "Unknown lod action: %s" % action

func _cmd_tree(args: Array) -> String:
	"""Display universe hierarchy tree"""
	var output = "🌌 Universe Tree:\n"
	var root_universes = _find_root_universes()
	
	for universe in root_universes:
		output += _build_universe_tree(universe, 0)
	
	return output

func _cmd_save(args: Array) -> String:
	"""Save universe state"""
	if args.is_empty():
		return "Usage: save <filename>"
	
	# TODO: Implement universe serialization
	return "Universe save not yet implemented"

func _cmd_load(args: Array) -> String:
	"""Load universe state"""
	if args.is_empty():
		return "Usage: load <filename>"
	
	# TODO: Implement universe deserialization
	return "Universe load not yet implemented"

func _cmd_merge(args: Array) -> String:
	"""Merge two universes"""
	if args.size() < 2:
		return "Usage: merge <universe1> <universe2>"
	
	# TODO: Implement universe merging
	return "Universe merging not yet implemented"

func _cmd_split(args: Array) -> String:
	"""Split current universe"""
	if args.is_empty():
		return "Usage: split <criteria>"
	
	# TODO: Implement universe splitting
	return "Universe splitting not yet implemented"

# ===== HELPER FUNCTIONS =====

func _find_universe_by_name(name: String) -> Node:
	"""Find a universe by name"""
	var all_universes = _find_all_universes()
	for universe in all_universes:
		if universe.universe_name == name:
			return universe
	return null

func _find_all_universes() -> Array[Node]:
	"""Find all universes in the scene tree"""
	var universes: Array[Node] = []
	_find_universes_recursive(get_tree().root, universes)
	return universes

func _find_universes_recursive(node: Node, universes: Array[Node]) -> void:
	"""Recursively find all universe beings"""
	if node.has_method("get_universe_info"):
		universes.append(node)
	
	for child in node.get_children():
		_find_universes_recursive(child, universes)

func _find_root_universes() -> Array[Node]:
	"""Find universes that aren't inside other universes"""
	var all_universes = _find_all_universes()
	var root_universes: Array[Node] = []
	
	for universe in all_universes:
		var is_root = true
		var parent = universe.get_parent()
		while parent:
			if parent.has_method("get_universe_info"):
				is_root = false
				break
			parent = parent.get_parent()
		
		if is_root:
			root_universes.append(universe)
	
	return root_universes

func _build_universe_tree(universe: Node, depth: int) -> String:
	"""Build tree representation of universe hierarchy"""
	var indent = "  ".repeat(depth)
	var info = universe.get_universe_info()
	var output = "%s└─ %s (beings: %d)\n" % [indent, info.name, info.beings]
	
	# Find sub-universes
	for being in universe.contained_beings:
		if being.has_method("get_universe_info"):
			output += _build_universe_tree(being, depth + 1)
	
	return output

func _list_beings() -> String:
	"""List beings in current universe"""
	if not current_universe:
		return "Not currently in a universe!"
	
	var output = "🌟 Beings in '%s':\n" % current_universe.universe_name
	
	if current_universe.contained_beings.is_empty():
		return output + "  No beings in this universe."
	
	for being in current_universe.contained_beings:
		var type = being.get("being_type") if being.has_method("get") else "unknown"
		var consciousness = being.get("consciousness_level") if being.has_method("get") else 0
		output += "  • %s (%s) - Consciousness: %d\n" % [being.name, type, consciousness]
	
	return output

func _list_portals() -> String:
	"""List portals in current universe"""
	if not current_universe:
		return "Not currently in a universe!"
	
	var output = "🌀 Portals in '%s':\n" % current_universe.universe_name
	
	if current_universe.portal_connections.is_empty():
		return output + "  No portals in this universe."
	
	for portal_id in current_universe.portal_connections:
		var target = current_universe.portal_connections[portal_id]
		output += "  • %s → %s\n" % [portal_id, target.universe_name if target else "Unknown"]
	
	return output

func _parse_rule_value(value_str: String):
	"""Parse a string value into appropriate type"""
	# Try float
	if value_str.is_valid_float():
		return float(value_str)
	# Try int
	if value_str.is_valid_int():
		return int(value_str)
	# Try bool
	if value_str.to_lower() in ["true", "false"]:
		return value_str.to_lower() == "true"
	# Return as string
	return value_str
