# ==================================================
# UNIVERSAL COMMAND PROCESSOR - The Brain of Reality
# PURPOSE: Process any command, natural or structured
# LOCATION: core/command_system/UniversalCommandProcessor.gd
# ==================================================

extends Node
class_name UniversalCommandProcessor

## Command patterns and triggers
var command_registry: Dictionary = {}
var natural_triggers: Dictionary = {} # "potato" -> logic_connector
var active_contexts: Array[CommandContext] = []
var command_history: Array[String] = []

signal command_executed(command: String, result: Variant)
signal trigger_activated(word: String, being: UniversalBeing)
signal reality_changed(what: String, how: Dictionary)

func _ready() -> void:
	_register_core_commands()
	_register_natural_triggers()

## COMMAND REGISTRATION ==================================================

func _register_core_commands() -> void:
	"""Register essential commands for reality manipulation"""
	
	# Data inspection commands
	register_command("inspect", _cmd_inspect, "Inspect any object/file/being")
	register_command("count", _cmd_count, "Count lines/nodes/components")
	register_command("analyze", _cmd_analyze, "Deep analysis of structure")
	register_command("tree", _cmd_tree, "Show hierarchy tree")
	
	# Creation commands
	register_command("create", _cmd_create, "Create anything from nothing")
	register_command("spawn", _cmd_spawn, "Spawn Universal Being")
	register_command("generate", _cmd_generate, "Generate from template")
	register_command("evolve", _cmd_evolve, "Evolve being to new form")
	
	# Script/Logic commands
	register_command("load", _cmd_load, "Load script/record/package")
	register_command("execute", _cmd_execute, "Execute GDScript code")
	register_command("connect", _cmd_connect, "Connect logic connectors")
	register_command("trigger", _cmd_trigger, "Set natural language trigger")
	
	# Reality manipulation
	register_command("edit", _cmd_edit, "Edit anything live")
	register_command("reload", _cmd_reload, "Hot reload component")
	register_command("save", _cmd_save, "Save current state")
	register_command("reality", _cmd_reality, "Modify reality rules")
	
	# System commands
	register_command("help", _cmd_help, "Show available commands")
	register_command("history", _cmd_history, "Show command history")
	register_command("undo", _cmd_undo, "Undo last change")
	register_command("macro", _cmd_macro, "Record command sequence")

func register_command(name: String, method: Callable, description: String = "") -> void:
	command_registry[name] = {
		"method": method,
		"description": description,
		"usage_count": 0
	}

## NATURAL LANGUAGE PROCESSING ==================================================

func process_natural_language(text: String, speaker: UniversalBeing = null) -> void:
	"""Process natural language for triggers and commands"""
	var words = text.to_lower().split(" ")
	
	# Check for trigger words
	for word in words:
		if word in natural_triggers:
			var trigger_data = natural_triggers[word]
			_activate_trigger(word, trigger_data, speaker)
	
	# Check if it's a command-like structure
	if text.begins_with("say ") or text.begins_with("do ") or text.begins_with("make "):
		var command = text.split(" ", 2)[1] if text.split(" ").size() > 1 else ""
		execute_command(command)

func register_natural_trigger(word: String, logic_connector: Dictionary) -> void:
	"""Register word as trigger for logic connector"""
	natural_triggers[word.to_lower()] = logic_connector
	print("🔮 Registered trigger: '%s' -> %s" % [word, logic_connector.get("action", "unknown")])

func _activate_trigger(word: String, trigger_data: Dictionary, speaker: UniversalBeing) -> void:
	"""Activate natural language trigger"""
	print("✨ Trigger activated: '%s'" % word)
	
	# Find nearby beings
	if speaker:
		var nearby = _find_nearby_beings(speaker, trigger_data.get("radius", 100.0))
		for being in nearby:
			if being.has_method("on_trigger"):
				being.on_trigger(word, trigger_data, speaker)
	
	trigger_activated.emit(word, speaker)

## COMMAND EXECUTION ==================================================

func execute_command(input: String) -> Variant:
	"""Execute any command and return result"""
	command_history.append(input)
	
	var parts = input.strip_edges().split(" ", 2)
	if parts.is_empty():
		return null
	
	var cmd = parts[0].to_lower()
	var args = parts.slice(1) if parts.size() > 1 else []
	
	# Direct command
	if cmd in command_registry:
		var cmd_data = command_registry[cmd]
		cmd_data.usage_count += 1
		var result = cmd_data.method.call(args)
		command_executed.emit(input, result)
		return result
	
	# Try to interpret as natural language
	process_natural_language(input)
	return "Processed as natural language"

## CORE COMMANDS ==================================================

func _cmd_inspect(args: Array) -> String:
	"""Inspect anything - file, node, being, package"""
	if args.is_empty():
		return "Usage: inspect <target>"
	
	var target = args[0]
	var result = "🔍 Inspecting: %s\n" % target
	
	# File inspection
	if FileAccess.file_exists(target):
		var file = FileAccess.open(target, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			
			result += "Type: File\n"
			result += "Size: %d bytes\n" % content.length()
			result += "Lines: %d\n" % content.split("\n").size()
			
			# Check for functions
			var functions = _extract_functions(content)
			if not functions.is_empty():
				result += "Functions: %s\n" % ", ".join(functions)
			
			# Check for classes
			if content.contains("class_name"):
				var class_match = RegEx.new()
				class_match.compile("class_name\\s+(\\w+)")
				var match_result = class_match.search(content)
				if match_result:
					result += "Class: %s\n" % match_result.get_string(1)
	
	# Node inspection
	elif has_node(target):
		var node = get_node(target)
		result += "Type: %s\n" % node.get_class()
		result += "Children: %d\n" % node.get_child_count()
		
		if node is UniversalBeing:
			result += "Being Type: %s\n" % node.being_type
			result += "Consciousness: %d\n" % node.consciousness_level
	
	return result

func _cmd_count(args: Array) -> String:
	"""Count anything - lines, nodes, functions, etc."""
	if args.is_empty():
		return "Usage: count <what> <in>"
	
	var what = args[0]
	var target = args[1] if args.size() > 1 else ""
	
	match what:
		"lines":
			if FileAccess.file_exists(target):
				var content = FileAccess.open(target, FileAccess.READ).get_as_text()
				return "Lines: %d" % content.split("\n").size()
		"nodes":
			var root = get_node(target) if target else get_tree().root
			return "Nodes: %d" % _count_nodes_recursive(root)
		"beings":
			var count = 0
			for node in get_tree().get_nodes_in_group("universal_beings"):
				count += 1
			return "Universal Beings: %d" % count
		_:
			return "Unknown count type: %s" % what

func _cmd_create(args: Array) -> String:
	"""Create anything from description"""
	if args.is_empty():
		return "Usage: create <type> <name> [properties]"
	
	var type = args[0]
	var name = args[1] if args.size() > 1 else "unnamed"
	
	match type:
		"being":
			var being = UniversalBeing.new()
			being.being_name = name
			being.being_type = args[2] if args.size() > 2 else "generic"
			get_tree().current_scene.add_child(being)
			return "✨ Created being: %s" % name
		
		"trigger":
			if args.size() < 3:
				return "Usage: create trigger <word> <action>"
			var word = args[1]
			var action = args[2]
			register_natural_trigger(word, {"action": action})
			return "🔮 Created trigger: say '%s' to %s" % [word, action]
		
		"connector":
			var connector = {
				"name": name,
				"type": "logic_connector",
				"connections": []
			}
			# Store in akashic records
			return "🔗 Created connector: %s" % name
		
		_:
			return "Unknown type: %s" % type

func _cmd_load(args: Array) -> String:
	"""Load and execute scripts, records, or packages"""
	if args.is_empty():
		return "Usage: load <script/record/package> <path>"
	
	var type = args[0]
	var path = args[1] if args.size() > 1 else ""
	
	match type:
		"script":
			var script = load(path)
			if script:
				var instance = script.new()
				get_tree().current_scene.add_child(instance)
				return "📜 Loaded script: %s" % path
		
		"record":
			# Load from akashic records
			if has_node("/root/AkashicRecords"):
				var records = get_node("/root/AkashicRecords")
				var data = records.load_record(path)
				return "📚 Loaded record: %s" % path
		
		"package":
			if has_node("/root/akashic_loader"):
				var loader = get_node("/root/akashic_loader")
				loader.queue_package_load(path, 100) # High priority
				return "📦 Loading package: %s" % path
		
		_:
			return "Unknown load type: %s" % type

func _cmd_execute(args: Array) -> String:
	"""Execute GDScript code directly"""
	if args.is_empty():
		return "Usage: execute <code>"
	
	var code = " ".join(args)
	
	# Create temporary script
	var script = GDScript.new()
	script.source_code = """
extends Node
func _run():
	%s
""" % code
	
	# Execute
	var instance = Node.new()
	instance.set_script(script)
	if instance.has_method("_run"):
		instance.call("_run")
		instance.queue_free()
		return "✅ Executed: %s" % code
	
	return "❌ Failed to execute code"

func _cmd_reality(args: Array) -> String:
	"""Modify reality rules"""
	if args.is_empty():
		return "Usage: reality <rule> <value>"
	
	var rule = args[0]
	var value = args[1] if args.size() > 1 else ""
	
	match rule:
		"gravity":
			if value.is_valid_float():
				ProjectSettings.set_setting("physics/2d/default_gravity", float(value))
				return "🌍 Gravity set to: %s" % value
		
		"time":
			if value.is_valid_float():
				Engine.time_scale = float(value)
				return "⏰ Time scale set to: %s" % value
		
		"consciousness":
			# Modify global consciousness rules
			return "🧠 Consciousness rules updated"
		
		_:
			return "Unknown reality rule: %s" % rule

## HELPER FUNCTIONS ==================================================

func _extract_functions(content: String) -> Array[String]:
	"""Extract function names from GDScript content"""
	var functions: Array[String] = []
	var lines = content.split("\n")
	
	for line in lines:
		if line.strip_edges().begins_with("func "):
			var func_match = RegEx.new()
			func_match.compile("func\\s+(\\w+)")
			var match = func_match.search(line)
			if match:
				functions.append(match.get_string(1))
	
	return functions

func _count_nodes_recursive(node: Node) -> int:
	var count = 1
	for child in node.get_children():
		count += _count_nodes_recursive(child)
	return count

func _find_nearby_beings(center: UniversalBeing, radius: float) -> Array[UniversalBeing]:
	"""Find all beings within radius of center being"""
	var nearby: Array[UniversalBeing] = []
	var all_beings = get_tree().get_nodes_in_group("universal_beings")
	
	for being in all_beings:
		if being != center and being is Node2D and center is Node2D:
			var distance = being.global_position.distance_to(center.global_position)
			if distance <= radius:
				nearby.append(being)
	
	return nearby

func _cmd_help(args: Array) -> String:
	"""Show available commands"""
	var help_text = "🌟 Universal Commands:\n\n"
	
	for cmd_name in command_registry:
		var cmd_data = command_registry[cmd_name]
		help_text += "• %s - %s\n" % [cmd_name, cmd_data.description]
	
	help_text += "\n💫 Natural triggers: %d registered\n" % natural_triggers.size()
	help_text += "Say 'help <command>' for detailed usage"
	
	return help_text

## Command Context for complex operations
class CommandContext:
	var name: String
	var variables: Dictionary = {}
	var commands: Array[String] = []
	
	func execute_all() -> Array:
		var results = []
		for cmd in commands:
			results.append(UniversalCommandProcessor.execute_command(cmd))
		return results