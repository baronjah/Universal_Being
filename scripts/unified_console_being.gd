# ==================================================
# UNIVERSAL BEING: Unified Console
# TYPE: console
# PURPOSE: Unified command console with universe management integration
# COMPONENTS: console_core.ub.zip, universe_console.ub.zip
# SCENES: unified_console.tscn
# ==================================================

extends UniversalBeing
class_name UnifiedConsoleBeing

# ===== CONSOLE PROPERTIES =====
@export var max_lines: int = 1000
@export var command_prefix: String = "> "
@export var history_size: int = 100
@export var console_color: Color = Color(0.0, 1.0, 0.0, 1.0)  # Green terminal color

# ===== INTERNAL STATE =====
var console_text: RichTextLabel = null
var input_field: LineEdit = null
var command_history: Array[String] = []
var history_index: int = -1
var current_input: String = ""

# ===== UNIVERSE INTEGRATION =====
var universe_component: UniverseConsoleComponent = null
var current_universe: Node = null
var universe_stack: Array[Node] = []

# ===== COMMAND REGISTRY =====
var command_registry: Dictionary = {}

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "unified_console"
	being_name = "Unified Console"
	consciousness_level = 5  # High consciousness for full AI control
	metadata.ai_accessible = true
	metadata.gemma_can_modify = true
	print("🌟 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Create console UI
	_create_console_ui()
	
	# Initialize universe component
	universe_component = UniverseConsoleComponent.new()
	add_child(universe_component)
	
	# Register base commands
	_register_base_commands()
	
	# Register universe commands
	_register_universe_commands()
	
	# Display welcome message
	output("╔══════════════════════════════════════════════════╗")
	output("║       UNIVERSAL BEING CONSOLE v1.0               ║")
	output("║  'In the beginning was the Word...'              ║")
	output("╚══════════════════════════════════════════════════╝")
	output("")
	output("Type 'help' for available commands")
	output("")
	
	# Log to Akashic Records
	var akashic = get_tree().get_first_node_in_group("akashic_library")
	if akashic:
		akashic.log_system_event("Unified Console", "creation", {"message": "🌟 The Unified Console manifested, bridging word and reality..."})
	
	print("🌟 %s: Pentagon Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# Update console if needed

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	if not input_field or not input_field.has_focus():
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP:
				_navigate_history(-1)
			KEY_DOWN:
				_navigate_history(1)
			KEY_TAB:
				_autocomplete_command()

func pentagon_sewers() -> void:
	output("Console shutting down...")
	print("🌟 %s: Pentagon Sewers Starting" % being_name)
	
	# Cleanup UI
	if console_text:
		console_text.queue_free()
	if input_field:
		input_field.queue_free()
	
	super.pentagon_sewers()

# ===== UI CREATION =====

func _create_console_ui() -> void:
	"""Create the console UI elements"""
	# Create container
	var container = VBoxContainer.new()
	container.name = "ConsoleContainer"
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(container)
	
	# Create console output
	console_text = RichTextLabel.new()
	console_text.name = "ConsoleOutput"
	console_text.bbcode_enabled = true
	console_text.scroll_following = true
	console_text.custom_minimum_size = Vector2(800, 400)
	console_text.add_theme_color_override("default_color", console_color)
	console_text.add_theme_color_override("font_color", console_color)
	console_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	console_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(console_text)
	
	# Create input field
	input_field = LineEdit.new()
	input_field.name = "CommandInput"
	input_field.placeholder_text = "Enter command..."
	input_field.caret_blink = true
	input_field.custom_minimum_size.y = 30
	input_field.add_theme_color_override("font_color", console_color)
	input_field.add_theme_color_override("caret_color", console_color)
	container.add_child(input_field)
	
	# Connect signals
	input_field.text_submitted.connect(_on_command_submitted)
	input_field.grab_focus()  # Actually grab focus!()

# ===== COMMAND REGISTRATION =====

func _register_base_commands() -> void:
	"""Register basic console commands"""
	register_command("help", _cmd_help, "Show available commands")
	register_command("clear", _cmd_clear, "Clear console output")
	register_command("history", _cmd_history, "Show command history")
	register_command("echo", _cmd_echo, "Echo text to console")
	register_command("ai", _cmd_ai, "AI system commands")
	register_command("beings", _cmd_beings, "List all beings")
	register_command("inspect", _cmd_inspect_being, "Inspect a being")

func _register_universe_commands() -> void:
	"""Register universe management commands"""
	register_command("universe", _cmd_universe, "Universe creation and management")
	register_command("portal", _cmd_portal, "Create portals between universes")
	register_command("enter", _cmd_enter, "Enter a universe")
	register_command("exit", _cmd_exit, "Exit current universe")
	register_command("list", _cmd_list, "List universes/beings/portals")
	register_command("rules", _cmd_rules, "Display universe rules")
	register_command("setrule", _cmd_setrule, "Set universe rule")
	register_command("lod", _cmd_lod, "Level of Detail control")
	register_command("tree", _cmd_tree, "Show universe hierarchy")

func register_command(name: String, callback: Callable, description: String = "") -> void:
	"""Register a command with the console"""
	command_registry[name] = {
		"callback": callback,
		"description": description
	}

# ===== COMMAND HANDLING =====

func execute_command(command: String) -> void:
	"""Execute a console command"""
	if command.is_empty():
		return
	
	# Add to history
	command_history.push_front(command)
	if command_history.size() > history_size:
		command_history.pop_back()
	history_index = -1
	
	# Display command
	output("%s%s" % [command_prefix, command])
	
	# Parse command
	var parts = command.split(" ", false)
	var cmd_name = parts[0].to_lower()
	var args = parts.slice(1)
	
	# Execute command
	if command_registry.has(cmd_name):
		var result = command_registry[cmd_name].callback.call(args)
		if result and not result.is_empty():
			output(result)
	else:
		output("Unknown command: %s" % cmd_name)
		output("Type 'help' for available commands")

# ===== BASE COMMANDS =====

func _cmd_help(args: Array) -> String:
	pass
	var output_text = "\n=== Available Commands ===\n"
	
	# Group commands by category
	var categories = {
		"Basic": ["help", "clear", "history", "echo"],
		"Universe": ["universe", "portal", "enter", "exit", "list", "rules", "setrule", "lod", "tree"],
		"System": ["ai", "beings", "inspect"]
	}
	
	for category in categories:
		output_text += "\n[%s]\n" % category
		for cmd in categories[category]:
			if command_registry.has(cmd):
				var desc = command_registry[cmd].description
				output_text += "  %-12s - %s\n" % [cmd, desc]
	
	return output_text

func _cmd_clear(args: Array) -> String:
	console_text.clear()
	return ""

func _cmd_history(args: Array) -> String:
	pass
	var count = 10
	if args.size() > 0 and args[0].is_valid_int():
		count = int(args[0])
	
	var output_text = "Command History:\n"
	for i in min(count, command_history.size()):
		output_text += "  %d: %s\n" % [i + 1, command_history[i]]
	
	return output_text

func _cmd_echo(args: Array) -> String:
	return " ".join(args)

func _cmd_ai(args: Array) -> String:
	if args.is_empty():
		return "Usage: ai <pentagon|bridges|status>"
	
	match args[0]:
		"pentagon":
			return _show_ai_pentagon_status()
		"bridges":
			return _show_ai_bridges()
		"status":
			return _show_ai_system_status()
		_:
			return "Unknown ai subcommand: %s" % args[0]

func _cmd_beings(args: Array) -> String:
	pass
	var flood_gates = SystemBootstrap.get_flood_gates() if SystemBootstrap else null
	if not flood_gates:
		return "FloodGates system not available"
	
	var beings = flood_gates.get_all_beings()
	var output_text = "=== Active Universal Beings ===\n"
	output_text += "Total: %d beings\n\n" % beings.size()
	
	for being in beings:
		output_text += "• %s (%s) - Consciousness: %d\n" % [
			being.being_name,
			being.being_type,
			being.consciousness_level
		]
	
	return output_text

func _cmd_inspect_being(args: Array) -> String:
	if args.is_empty():
		return "Usage: inspect <being_name>"
	
	var target_name = args[0]
	var flood_gates = SystemBootstrap.get_flood_gates() if SystemBootstrap else null
	if not flood_gates:
		return "FloodGates system not available"
	
	# Find being
	var beings = flood_gates.get_all_beings()
	for being in beings:
		if being.being_name == target_name:
			return _inspect_being(being)
	
	return "Being '%s' not found" % target_name

# ===== UNIVERSE COMMANDS =====

func _cmd_universe(args: Array) -> String:
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
	pass
	# Load UniverseUniversalBeing class directly
	var UniverseClass = load("res://beings/universe_universal_being.gd")
	if not UniverseClass:
		return "ERROR: UniverseUniversalBeing class not found!"
	
	var new_universe = UniverseClass.new()
	if not new_universe:
		return "ERROR: Failed to create Universe Universal Being!"
	
	# Configure universe properties
	new_universe.universe_name = universe_name
	new_universe.universe_seed = randi()
	
	# Add to current universe or main scene
	var parent = current_universe if current_universe else get_tree().root.get_node("Main")
	parent.add_child(new_universe)
	
	# Log to Akashic
	var akashic = get_tree().get_first_node_in_group("akashic_library")
	if akashic:
		akashic.log_universe_event("creation", "🌌 Universe '%s' birthed through console command!" % universe_name, {"universe_name": universe_name, "created_via": "console"})
	
	return "✨ Universe '%s' created! Use 'enter %s' to explore it." % [universe_name, universe_name]

func _delete_universe(universe_name: String) -> String:
	pass
	var universe = _find_universe_by_name(universe_name)
	if not universe:
		return "Universe '%s' not found." % universe_name
	
	if universe == current_universe:
		return "Cannot delete current universe! Exit first with 'exit'."
	
	universe.queue_free()
	return "Universe '%s' dissolved back into the void..." % universe_name

func _rename_universe(new_name: String) -> String:
	if not current_universe:
		return "Not currently in a universe!"
	
	var old_name = current_universe.universe_name
	current_universe.universe_name = new_name
	
	return "Universe renamed from '%s' to '%s'" % [old_name, new_name]

func _cmd_portal(args: Array) -> String:
	if args.size() < 1:
		return "Usage: portal <target_universe> [bidirectional]"
	
	var target_name = args[0]
	var bidirectional = args.size() > 1 and args[1] == "true"
	
	var target_universe = _find_universe_by_name(target_name)
	if not target_universe:
		return "Target universe '%s' not found!" % target_name
	
	if not current_universe:
		return "Not currently in a universe!"
	
	# Create portal
	current_universe.create_portal_to(target_universe, "Console User")
	
	if bidirectional:
		target_universe.create_portal_to(current_universe, "Console User")
	
	return "🌀 Portal created from '%s' to '%s'%s" % [
		current_universe.universe_name,
		target_universe.universe_name,
		" (bidirectional)" if bidirectional else ""
	]

func _cmd_enter(args: Array) -> String:
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
	
	return "🌌 Entered universe '%s'. Use 'exit' to return." % target_name

func _cmd_exit(args: Array) -> String:
	if universe_stack.is_empty():
		return "Already at root level!"
	
	var previous_universe = universe_stack.pop_back()
	current_universe = previous_universe
	
	return "🌌 Returned to %s" % (current_universe.universe_name if current_universe else "root")

func _cmd_list(args: Array) -> String:
	pass
	var list_type = args[0] if args.size() > 0 else "universes"
	
	match list_type:
		"universes":
			return _list_universes()
		"beings":
			return _list_beings_in_universe()
		"portals":
			return _list_portals()
		_:
			return "Usage: list <universes|beings|portals>"

func _cmd_rules(args: Array) -> String:
	if not current_universe:
		return "Not currently in a universe!"
	
	var info = current_universe.get_universe_info()
	var rules = info.get("rules", {})
	
	var output_text = "🌌 Universe Rules for '%s':\n" % info.name
	for rule_name in rules:
		output_text += "  %s: %s\n" % [rule_name, str(rules[rule_name])]
	
	return output_text

func _cmd_setrule(args: Array) -> String:
	if args.size() < 2:
		return "Usage: setrule <rule_name> <value>"
	
	if not current_universe:
		return "Not currently in a universe!"
	
	var rule_name = args[0]
	var value = _parse_value(args[1])
	
	current_universe.set_universe_rule(rule_name, value, "Console User")
	
	return "✨ Rule '%s' set to %s" % [rule_name, str(value)]

func _cmd_lod(args: Array) -> String:
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
	pass
	var output_text = "🌌 Universe Tree:\n"
	var root_universes = _find_root_universes()
	
	for universe in root_universes:
		output_text += _build_universe_tree(universe, 0)
	
	return output_text

# ===== HELPER FUNCTIONS =====

func output(text: String) -> void:
	# Output text to console
	if console_text:
		console_text.append_text(text + "\n")

func toggle_console_visibility() -> void:
	# Toggle console visibility
	if console_text:
		visible = not visible
		if visible and input_field:
			input_field.grab_focus()
			print("🖥️ Console is now visible and focused!")
		else:
			print("🖥️ Console hidden")

func focus_input() -> void:
	# Force focus to input field
	if input_field:
		input_field.grab_focus()
		# Also make sure console is visible
		if console_text and console_text.get_parent():
			console_text.get_parent().visible = true
		print("🖥️ Console input focused!")

func _navigate_history(direction: int) -> void:
	"""Navigate command history"""
	if command_history.is_empty():
		return
	
	history_index = clamp(history_index + direction, -1, command_history.size() - 1)
	
	if history_index == -1:
		input_field.text = current_input
	else:
		input_field.text = command_history[history_index]

func _autocomplete_command() -> void:
	"""Autocomplete current command"""
	var current_text = input_field.text
	var matches = []
	
	for cmd in command_registry:
		if cmd.begins_with(current_text):
			matches.append(cmd)
	
	if matches.size() == 1:
		input_field.text = matches[0] + " "
		input_field.caret_column = input_field.text.length()
	elif matches.size() > 1:
		output("Possible commands: " + ", ".join(matches))

func _find_universe_by_name(name: String) -> Node:
	"""Find a universe by name"""
	var all_universes = _find_all_universes()
	for universe in all_universes:
		if universe.get("universe_name") == name:
			return universe
	return null

func _find_all_universes() -> Array:
	"""Find all universes in the scene tree"""
	var universes = []
	_find_universes_recursive(get_tree().root, universes)
	return universes

func _find_universes_recursive(node: Node, universes: Array) -> void:
	"""Recursively find all universe beings"""
	if node.has_method("get_universe_info"):
		universes.append(node)
	
	for child in node.get_children():
		_find_universes_recursive(child, universes)

func _find_root_universes() -> Array:
	"""Find universes that aren't inside other universes"""
	var all_universes = _find_all_universes()
	var root_universes = []
	
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
	var output_text = "%s└─ %s (beings: %d)\n" % [indent, info.name, info.beings]
	
	# Find sub-universes
	if universe.has("contained_beings"):
		for being in universe.contained_beings:
			if being.has_method("get_universe_info"):
				output_text += _build_universe_tree(being, depth + 1)
	
	return output_text

func _list_universes() -> String:
	"""List all accessible universes"""
	var output_text = "🌌 Accessible Universes:\n"
	var universes = _find_all_universes()
	
	if universes.is_empty():
		return output_text + "  No universes found!"
	
	for universe in universes:
		var info = universe.get_universe_info()
		var marker = " ← current" if universe == current_universe else ""
		output_text += "  • %s (beings: %d, age: %.1fs)%s\n" % [
			info.name, info.beings, info.age, marker
		]
	
	return output_text

func _list_beings_in_universe() -> String:
	"""List beings in current universe"""
	if not current_universe:
		return "Not currently in a universe!"
	
	var output_text = "🌟 Beings in '%s':\n" % current_universe.universe_name
	
	if not current_universe.has("contained_beings") or current_universe.contained_beings.is_empty():
		return output_text + "  No beings in this universe."
	
	for being in current_universe.contained_beings:
		var type = being.get("being_type") if being.has_method("get") else "unknown"
		var consciousness = being.get("consciousness_level") if being.has_method("get") else 0
		output_text += "  • %s (%s) - Consciousness: %d\n" % [being.name, type, consciousness]
	
	return output_text

func _list_portals() -> String:
	"""List portals in current universe"""
	if not current_universe:
		return "Not currently in a universe!"
	
	var output_text = "🌀 Portals in '%s':\n" % current_universe.universe_name
	
	if not current_universe.has("portal_connections") or current_universe.portal_connections.is_empty():
		return output_text + "  No portals in this universe."
	
	for portal_id in current_universe.portal_connections:
		var target = current_universe.portal_connections[portal_id]
		output_text += "  • %s → %s\n" % [portal_id, target.universe_name if target else "Unknown"]
	
	return output_text

func _inspect_being(being: Node) -> String:
	"""Inspect a universal being"""
	var output_text = "=== Being Inspection ===\n"
	output_text += "Name: %s\n" % being.being_name
	output_text += "Type: %s\n" % being.being_type
	output_text += "Consciousness: %d\n" % being.consciousness_level
	
	if being.has_method("ai_interface"):
		var ai_data = being.ai_interface()
		output_text += "\nAI Interface:\n"
		output_text += "  Accessible: %s\n" % ai_data.get("accessible", false)
		output_text += "  Custom Commands: %s\n" % ai_data.get("custom_commands", [])
	
	return output_text

func _show_ai_pentagon_status() -> String:
	"""Show Pentagon of Creation status"""
	var conductor = get_tree().get_first_node_in_group("genesis_conductor")
	if not conductor:
		return "Genesis Conductor not found!"
	
	return conductor.get_pentagon_status()

func _show_ai_bridges() -> String:
	"""Show AI bridge connections"""
	var output_text = "=== AI Bridge Status ===\n"
	
	var bridges = {
		"Gemma AI": get_tree().get_first_node_in_group("gemma_ai"),
		"Claude Code": get_tree().get_first_node_in_group("claude_code"),
		"Cursor": get_tree().get_first_node_in_group("cursor"),
		"Claude Desktop": get_tree().get_first_node_in_group("claude_desktop"),
		"ChatGPT Premium": get_tree().get_first_node_in_group("chatgpt_premium"),
		"Google Gemini": get_tree().get_first_node_in_group("google_gemini")
	}
	
	for bridge_name in bridges:
		var status = "Connected" if bridges[bridge_name] else "Not Connected"
		output_text += "  %s: %s\n" % [bridge_name, status]
	
	return output_text

func _show_ai_system_status() -> String:
	"""Show overall AI system status"""
	return "AI System Status: Online\nPentagon Architecture: Active\nConsciousness Network: Operational"

func _parse_value(value_str: String):
	"""Parse string to appropriate type"""
	if value_str.is_valid_float():
		return float(value_str)
	if value_str.is_valid_int():
		return int(value_str)
	if value_str.to_lower() in ["true", "false"]:
		return value_str.to_lower() == "true"
	return value_str

func _on_command_submitted(command: String) -> void:
	"""Handle command submission"""
	execute_command(command)
	input_field.text = ""
	current_input = ""

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	pass
	var base_interface = super.ai_interface()
	base_interface.custom_commands = ["output", "execute", "clear", "universe", "portal", "enter", "exit"]
	base_interface.custom_properties = {
		"current_universe": current_universe.universe_name if current_universe else "root",
		"universe_stack_depth": universe_stack.size(),
		"command_count": command_history.size()
	}
	return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		"output":
			if args.size() > 0:
				output(str(args[0]))
				return true
		"execute":
			if args.size() > 0:
				execute_command(str(args[0]))
				return true
		"clear":
			_cmd_clear([])
			return true
		"universe":
			return _cmd_universe(args)
		"portal":
			return _cmd_portal(args)
		"enter":
			return _cmd_enter(args)
		"exit":
			return _cmd_exit(args)
		_:
			return super.ai_invoke_method(method_name, args)
	
	return false
