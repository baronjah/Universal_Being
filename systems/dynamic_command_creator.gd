# ==================================================
# DYNAMIC COMMAND CREATOR - Create Commands On-The-Fly
# PURPOSE: Universal command creation system for any scene
# VISION: Type anything into console and make it a command instantly
# ==================================================

extends Node
# class_name DynamicCommandCreator  # Commented to avoid autoload conflict

## 🎮 UNIVERSAL COMMAND CREATOR SYSTEM
## Creates commands dynamically while playing any scene
## Integrates with Universal Console and Command Processor

# ===== DYNAMIC COMMAND SYSTEM =====
signal command_created(name: String, description: String)
signal command_executed(name: String, result: Variant)

var created_commands: Dictionary = {}
var command_templates: Dictionary = {}
var console_ref: Node = null
var processor_ref: Node = null

# Command creation patterns
enum CommandType {
	SIMPLE,           # Just output text
	SPAWN_BEING,      # Create Universal Being
	MODIFY_REALITY,   # Change game state
	VISUAL_EFFECT,    # Create visual effects
	CONSCIOUSNESS,    # Affect consciousness levels
	CUSTOM_SCRIPT     # Execute custom GDScript
}

# ===== INITIALIZATION =====

func _ready() -> void:
	setup_command_templates()
	connect_to_console_system()
	register_creation_commands()
	setup_input_handling()
	print("🎮 Dynamic Command Creator: Ready to create commands on-the-fly!")

func setup_input_handling() -> void:
	"""Setup input handling for console integration"""
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	"""Handle global input for command creation"""
	if event.is_action_pressed("open_console") or event.is_action_pressed("ui_console_toggle"):
		# Make sure our system is ready when console opens
		call_deferred("ensure_system_ready")

func ensure_system_ready() -> void:
	"""Ensure our command creation system is ready"""
	if not processor_ref:
		connect_to_console_system()
		register_creation_commands()

func setup_command_templates() -> void:
	"""Setup templates for different command types"""
	command_templates = {
		CommandType.SIMPLE: {
			"description": "Simple output command",
			"template": "func execute(args): return '%s'"
		},
		CommandType.SPAWN_BEING: {
			"description": "Spawn Universal Being",
			"template": """
func execute(args):
	var being = UniversalBeing.new()
	being.being_name = '%s'
	being.being_type = args[0] if args.size() > 0 else 'dynamic'
	get_tree().current_scene.add_child(being)
	return 'Spawned %s being'
"""
		},
		CommandType.VISUAL_EFFECT: {
			"description": "Create visual effect",
			"template": """
func execute(args):
	var effect_name = '%s'
	print('✨ ' + effect_name + ' effect activated!')
	# Future: Create actual visual effect
	return 'Visual effect: ' + effect_name
"""
		},
		CommandType.CONSCIOUSNESS: {
			"description": "Consciousness interaction",
			"template": """
func execute(args):
	var beings = get_tree().get_nodes_in_group('universal_beings')
	var effect = '%s'
	for being in beings:
		if being.has_method('modify_consciousness'):
			being.modify_consciousness(effect)
	return 'Applied consciousness effect: ' + effect
"""
		}
	}

func connect_to_console_system() -> void:
	"""Connect to existing console and command processor"""
	# Find console in any scene
	console_ref = find_console_in_scene()
	processor_ref = find_command_processor()
	
	# Create command processor if not found
	if not processor_ref:
		var processor_script = load("res://core/command_system/UniversalCommandProcessor.gd")
		if processor_script:
			processor_ref = processor_script.new()
			processor_ref.name = "DynamicCommandProcessor"
			add_child(processor_ref)
			print("🔗 Created and connected to Command Processor")
	
	if console_ref:
		print("🔗 Connected to Universal Console")
	if processor_ref:
		print("🔗 Connected to Command Processor")

func find_console_in_scene() -> Node:
	"""Find console in current scene tree"""
	var all_nodes = get_tree().get_nodes_in_group("console")
	if not all_nodes.is_empty():
		return all_nodes[0]
	
	# Search by class name
	return _find_node_by_script_pattern("UniversalConsole")

func find_command_processor() -> Node:
	"""Find command processor in scene"""
	var all_nodes = get_tree().get_nodes_in_group("command_processor")
	if not all_nodes.is_empty():
		return all_nodes[0]
	
	return _find_node_by_script_pattern("UniversalCommandProcessor")

func _find_node_by_script_pattern(pattern: String) -> Node:
	"""Find node by script class pattern"""
	var all_nodes = get_tree().get_nodes_in_group("universal_beings")
	for node in all_nodes:
		if node.get_script() and str(node.get_script()).contains(pattern):
			return node
	return null

# ===== REGISTER CREATION COMMANDS =====

func register_creation_commands() -> void:
	"""Register the main command creation commands"""
	if processor_ref and processor_ref.has_method("register_command"):
		# Main command creation command
		processor_ref.register_command("newcmd", create_new_command, "Create new command: newcmd <name> <type> <description>")
		processor_ref.register_command("listcmds", list_created_commands, "List all dynamically created commands")
		processor_ref.register_command("delcmd", delete_command, "Delete created command: delcmd <name>")
		processor_ref.register_command("quickcmd", create_quick_command, "Quick command: quickcmd <name> <what_it_does>")
		
		print("🎮 Command creation commands registered!")

# ===== MAIN COMMAND CREATION FUNCTION =====

func create_new_command(args: Array) -> String:
	"""Create a new command dynamically - THE MAIN FUNCTION!"""
	if args.size() < 2:
		return """
🎮 CREATE NEW COMMAND:

Usage: newcmd <name> <type> [description]

Types:
  simple     - Just outputs text
  spawn      - Creates Universal Being  
  effect     - Visual effect
  reality    - Modifies game state
  conscious  - Affects consciousness
  script     - Custom GDScript

Examples:
  newcmd potato simple "Says hello potato"
  newcmd dragon spawn "Spawns a dragon being"
  newcmd sparkle effect "Creates sparkles"
  newcmd godmode reality "Activates god mode"
"""
	
	var cmd_name = args[0].to_lower()
	var cmd_type = args[1].to_lower()
	var description = args[2] if args.size() > 2 else "Dynamic command"
	
	# Validate command name
	if cmd_name.length() < 2:
		return "❌ Command name must be at least 2 characters"
	
	# Determine command type
	var command_type: CommandType
	match cmd_type:
		"simple", "text", "say":
			command_type = CommandType.SIMPLE
		"spawn", "being", "create":
			command_type = CommandType.SPAWN_BEING
		"effect", "visual", "fx":
			command_type = CommandType.VISUAL_EFFECT
		"reality", "modify", "change":
			command_type = CommandType.MODIFY_REALITY
		"conscious", "consciousness", "mind":
			command_type = CommandType.CONSCIOUSNESS
		"script", "code", "custom":
			command_type = CommandType.CUSTOM_SCRIPT
		_:
			command_type = CommandType.SIMPLE
	
	# Create the command
	var success = _create_dynamic_command(cmd_name, command_type, description)
	
	if success:
		command_created.emit(cmd_name, description)
		return "✅ Created command '%s'! Type '%s' to use it." % [cmd_name, cmd_name]
	else:
		return "❌ Failed to create command '%s'" % cmd_name

func create_quick_command(args: Array) -> String:
	"""Quick command creation - just name and what it does"""
	if args.size() < 2:
		return "Usage: quickcmd <name> <what_it_does>\nExample: quickcmd rainbow 'creates rainbow effect'"
	
	var cmd_name = args[0].to_lower()
	var what_it_does = " ".join(args.slice(1))
	
	# Auto-detect command type from description
	var command_type = _detect_command_type(what_it_does)
	
	var success = _create_dynamic_command(cmd_name, command_type, what_it_does)
	
	if success:
		return "🚀 Quick command '%s' created! It %s" % [cmd_name, what_it_does]
	else:
		return "❌ Failed to create quick command '%s'" % cmd_name

func _detect_command_type(description: String) -> CommandType:
	"""Auto-detect command type from description"""
	var lower_desc = description.to_lower()
	
	if lower_desc.contains("spawn") or lower_desc.contains("create") or lower_desc.contains("being"):
		return CommandType.SPAWN_BEING
	elif lower_desc.contains("effect") or lower_desc.contains("visual") or lower_desc.contains("sparkle"):
		return CommandType.VISUAL_EFFECT
	elif lower_desc.contains("consciousness") or lower_desc.contains("mind") or lower_desc.contains("aware"):
		return CommandType.CONSCIOUSNESS
	elif lower_desc.contains("reality") or lower_desc.contains("modify") or lower_desc.contains("change"):
		return CommandType.MODIFY_REALITY
	else:
		return CommandType.SIMPLE

# ===== COMMAND CREATION LOGIC =====

func _create_dynamic_command(name: String, type: CommandType, description: String) -> bool:
	"""Create and register the dynamic command"""
	
	# Create command data
	var command_data = {
		"name": name,
		"type": type,
		"description": description,
		"created_time": Time.get_unix_time_from_system(),
		"usage_count": 0
	}
	
	# Generate command function
	var command_func = _generate_command_function(name, type, description)
	
	# Store in our registry
	created_commands[name] = command_data
	
	# Register with command processor
	if processor_ref and processor_ref.has_method("register_command"):
		processor_ref.register_command(name, command_func, description)
		
		# Also add to console if available
		if console_ref and console_ref.has_method("output_line"):
			console_ref.output_line("🎮 Command '%s' created and ready!" % name)
		
		return true
	
	return false

func _generate_command_function(name: String, type: CommandType, description: String) -> Callable:
	"""Generate the actual command function"""
	match type:
		CommandType.SIMPLE:
			return func(args: Array): return _execute_simple_command(name, description, args)
		CommandType.SPAWN_BEING:
			return func(args: Array): return _execute_spawn_command(name, description, args)
		CommandType.VISUAL_EFFECT:
			return func(args: Array): return _execute_effect_command(name, description, args)
		CommandType.CONSCIOUSNESS:
			return func(args: Array): return _execute_consciousness_command(name, description, args)
		CommandType.MODIFY_REALITY:
			return func(args: Array): return _execute_reality_command(name, description, args)
		_:
			return func(args: Array): return _execute_simple_command(name, description, args)

# ===== COMMAND EXECUTION FUNCTIONS =====

func _execute_simple_command(name: String, description: String, args: Array) -> String:
	"""Execute simple text command"""
	created_commands[name].usage_count += 1
	command_executed.emit(name, description)
	
	var result = "🎮 %s: %s" % [name.capitalize(), description]
	
	if not args.is_empty():
		result += " (with: %s)" % ", ".join(args)
	
	# Visual feedback
	_create_visual_feedback(name, Color.CYAN)
	
	return result

func _execute_spawn_command(name: String, description: String, args: Array) -> String:
	"""Execute being spawn command"""
	created_commands[name].usage_count += 1
	
	# Create Universal Being
	var being_type = args[0] if args.size() > 0 else name
	var being_name = args[1] if args.size() > 1 else (name + "_being")
	
	# Try to create being
	var being = _create_universal_being(being_name, being_type)
	if being:
		_create_visual_feedback(name, Color.GREEN)
		return "✨ Spawned %s being named '%s'!" % [being_type, being_name]
	else:
		return "❌ Failed to spawn being"

func _execute_effect_command(name: String, description: String, args: Array) -> String:
	"""Execute visual effect command"""
	created_commands[name].usage_count += 1
	
	var effect_type = args[0] if args.size() > 0 else name
	var intensity = args[1] if args.size() > 1 else "medium"
	
	# Create visual effect
	_create_visual_effect(effect_type, intensity)
	_create_visual_feedback(name, Color.MAGENTA)
	
	return "✨ %s effect activated with %s intensity!" % [effect_type.capitalize(), intensity]

func _execute_consciousness_command(name: String, description: String, args: Array) -> String:
	"""Execute consciousness modification command"""
	created_commands[name].usage_count += 1
	
	var consciousness_effect = args[0] if args.size() > 0 else "enlighten"
	var affected_count = 0
	
	# Affect all Universal Beings
	var all_beings = get_tree().get_nodes_in_group("universal_beings")
	for being in all_beings:
		if being.has_method("modify_consciousness_level"):
			being.modify_consciousness_level(consciousness_effect)
			affected_count += 1
		elif being.has_property("consciousness_level"):
			being.consciousness_level = min(being.consciousness_level + 1, 5)
			affected_count += 1
	
	_create_visual_feedback(name, Color.GOLD)
	
	return "🧠 Consciousness effect '%s' applied to %d beings!" % [consciousness_effect, affected_count]

func _execute_reality_command(name: String, description: String, args: Array) -> String:
	"""Execute reality modification command"""
	created_commands[name].usage_count += 1
	
	var reality_aspect = args[0] if args.size() > 0 else "physics"
	var change_value = args[1] if args.size() > 1 else "enhanced"
	
	# Modify reality based on aspect
	match reality_aspect:
		"gravity":
			if change_value.is_valid_float():
				ProjectSettings.set_setting("physics/3d/default_gravity", float(change_value))
		"time":
			if change_value.is_valid_float():
				Engine.time_scale = float(change_value)
		"consciousness":
			# Global consciousness boost
			pass
	
	_create_visual_feedback(name, Color.RED)
	
	return "🌍 Reality aspect '%s' modified to '%s'!" % [reality_aspect, change_value]

# ===== HELPER FUNCTIONS =====

func _create_universal_being(being_name: String, being_type: String) -> Node:
	"""Create a Universal Being dynamically"""
	# Try to load UniversalBeing class
	var being_script = load("res://core/UniversalBeing.gd")
	if not being_script:
		return null
	
	var being = being_script.new()
	being.being_name = being_name
	being.being_type = being_type
	being.consciousness_level = 1
	
	# Add to current scene
	var current_scene = get_tree().current_scene
	if current_scene:
		current_scene.add_child(being)
		return being
	
	return null

func _create_visual_effect(effect_type: String, intensity: String) -> void:
	"""Create visual effect (placeholder for now)"""
	print("✨ Visual Effect: %s (%s intensity)" % [effect_type, intensity])
	
	# Future: Create actual particle effects, screen flashes, etc.
	match effect_type:
		"sparkle", "glitter":
			print("✨ Sparkles dance across the screen!")
		"flash", "burst":
			print("💥 Brilliant flash illuminates reality!")
		"rainbow", "color":
			print("🌈 Colors flow like digital aurora!")
		_:
			print("🎇 %s effect ripples through space!" % effect_type.capitalize())

func _create_visual_feedback(command_name: String, color: Color) -> void:
	"""Create visual feedback for command execution"""
	if console_ref and console_ref.has_method("output_line"):
		var color_hex = "#%02x%02x%02x" % [color.r8, color.g8, color.b8]
		console_ref.output_line("[color=%s]🎮 Command '%s' executed![/color]" % [color_hex, command_name])

# ===== COMMAND MANAGEMENT =====

func list_created_commands(args: Array) -> String:
	"""List all dynamically created commands"""
	if created_commands.is_empty():
		return "📝 No dynamic commands created yet. Use 'newcmd' to create one!"
	
	var result = "🎮 CREATED COMMANDS:\n\n"
	
	for cmd_name in created_commands:
		var cmd_data = created_commands[cmd_name]
		result += "• %s - %s (used %d times)\n" % [cmd_name, cmd_data.description, cmd_data.usage_count]
	
	result += "\nTotal: %d commands created" % created_commands.size()
	return result

func delete_command(args: Array) -> String:
	"""Delete a created command"""
	if args.is_empty():
		return "Usage: delcmd <command_name>"
	
	var cmd_name = args[0].to_lower()
	
	if cmd_name in created_commands:
		created_commands.erase(cmd_name)
		
		# Try to remove from processor (if supported)
		if processor_ref and processor_ref.has_method("unregister_command"):
			processor_ref.unregister_command(cmd_name)
		
		return "🗑️ Deleted command '%s'" % cmd_name
	else:
		return "❌ Command '%s' not found" % cmd_name

# ===== CONSOLE INTEGRATION =====

func add_to_any_scene() -> void:
	"""Add this system to any scene automatically"""
	# Auto-attach to current scene
	var current_scene = get_tree().current_scene
	if current_scene and not current_scene.has_node("DynamicCommandCreator"):
		current_scene.add_child(self)
		print("🎮 Dynamic Command Creator added to scene: %s" % current_scene.name)

# ===== SAVE/LOAD COMMANDS =====

func save_created_commands() -> void:
	"""Save created commands to file"""
	var save_data = {
		"commands": created_commands,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var file = FileAccess.open("user://dynamic_commands.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("💾 Dynamic commands saved!")

func load_created_commands() -> void:
	"""Load created commands from file"""
	var file = FileAccess.open("user://dynamic_commands.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_text)
		
		if parse_result == OK:
			var save_data = json.data
			created_commands = save_data.get("commands", {})
			
			# Re-register commands
			for cmd_name in created_commands:
				var cmd_data = created_commands[cmd_name]
				_create_dynamic_command(cmd_name, cmd_data.type, cmd_data.description)
			
			print("📂 Loaded %d dynamic commands!" % created_commands.size())

# ===== AUTOLOAD HELPER =====

func _enter_tree() -> void:
	"""Auto-setup when added to scene"""
	call_deferred("add_to_any_scene")
	call_deferred("load_created_commands")

func _exit_tree() -> void:
	"""Save commands when leaving"""
	save_created_commands()