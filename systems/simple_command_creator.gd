# ==================================================
# SIMPLE COMMAND CREATOR - Universal Console Commands
# PURPOSE: Create any command on-the-fly while playing
# VISION: Type "newcmd" and instantly create commands that do anything
# ==================================================

extends Node

## 🎮 SIMPLE UNIVERSAL COMMAND CREATOR
## Creates commands while playing any scene - NO COMPLEX DEPENDENCIES

# ===== SIMPLE COMMAND SYSTEM =====
var created_commands: Dictionary = {}
var command_count: int = 0

# Interface controls (like real life potentiometers)
var interface_controls: Dictionary = {
	"sun_brightness": 1.0,
	"sun_temperature": 5000.0,
	"gravity": 9.8,
	"time_speed": 1.0,
	"consciousness_level": 3.0,
	"reality_energy": 100.0
}

signal command_created(name: String)
signal interface_changed(control: String, value: float)

# ===== INITIALIZATION =====

func _ready() -> void:
	setup_console_integration()
	print("🎮 Simple Command Creator: Ready! Type anything in console to make it a command!")

func setup_console_integration() -> void:
	"""Setup integration with any console in the scene"""
	# Connect to input to intercept console commands
	set_process_unhandled_input(true)

# ===== INPUT HANDLING =====

func _unhandled_input(event: InputEvent) -> void:
	"""Listen for console toggle to hook into command system"""
	if event.is_action_pressed("open_console") or event.is_action_pressed("ui_console_toggle"):
		call_deferred("hook_into_console")

func hook_into_console() -> void:
	"""Find and hook into any console in the scene"""
	var console = find_console_node()
	if console:
		print("🔗 Connected to console for command creation!")

func find_console_node() -> Node:
	"""Find console in scene tree"""
	var all_nodes = []
	_get_all_nodes(get_tree().root, all_nodes)
	
	for node in all_nodes:
		if node.has_method("output_line") or "console" in node.name.to_lower():
			return node
	return null

func _get_all_nodes(node: Node, array: Array) -> void:
	"""Recursively get all nodes"""
	array.append(node)
	for child in node.get_children():
		_get_all_nodes(child, array)

# ===== MAIN COMMAND CREATION FUNCTIONS =====

func create_new_command(command_input: String) -> String:
	"""Main function - create any command from user input"""
	var parts = command_input.split(" ", 1)
	if parts.size() < 1:
		return show_help()
	
	var command_name = parts[0].to_lower()
	var description = parts[1] if parts.size() > 1 else "Dynamic command"
	
	# Skip if it's a system command
	if command_name in ["help", "clear", "exit", "quit"]:
		return "Cannot override system command: " + command_name
	
	# Create the command
	created_commands[command_name] = {
		"name": command_name,
		"description": description,
		"created_time": Time.get_unix_time_from_system(),
		"usage_count": 0,
		"type": detect_command_type(description)
	}
	
	command_count += 1
	command_created.emit(command_name)
	
	# Add to console if possible
	register_with_console(command_name, description)
	
	return "✅ Command '%s' created! Now type '%s' to use it." % [command_name, command_name]

func detect_command_type(description: String) -> String:
	"""Auto-detect what kind of command this should be"""
	var lower_desc = description.to_lower()
	
	if "knowledge" in lower_desc or "notepad" in lower_desc or "docs" in lower_desc or "lod" in lower_desc:
		return "knowledge"
	elif "sun" in lower_desc or "light" in lower_desc or "bright" in lower_desc:
		return "lighting"
	elif "gravity" in lower_desc or "physics" in lower_desc:
		return "physics"
	elif "time" in lower_desc or "speed" in lower_desc:
		return "temporal"
	elif "spawn" in lower_desc or "create" in lower_desc:
		return "creation"
	elif "consciousness" in lower_desc or "mind" in lower_desc:
		return "consciousness"
	elif "interface" in lower_desc or "control" in lower_desc:
		return "interface"
	else:
		return "simple"

func register_with_console(cmd_name: String, description: String) -> void:
	"""Register command with existing console"""
	var console = find_console_node()
	if console and console.has_method("register_command"):
		var cmd_func = func(args): return execute_created_command(cmd_name, args)
		console.register_command(cmd_name, cmd_func, description)

# ===== COMMAND EXECUTION =====

func execute_created_command(cmd_name: String, args: Array = []) -> String:
	"""Execute a created command"""
	if not cmd_name in created_commands:
		return "❌ Command '%s' not found" % cmd_name
	
	var cmd_data = created_commands[cmd_name]
	cmd_data.usage_count += 1
	
	var result = ""
	
	# Execute based on command type
	match cmd_data.type:
		"knowledge":
			result = execute_knowledge_command(cmd_name, cmd_data.description, args)
		"lighting":
			result = execute_lighting_command(cmd_name, cmd_data.description, args)
		"physics":
			result = execute_physics_command(cmd_name, cmd_data.description, args)
		"temporal":
			result = execute_temporal_command(cmd_name, cmd_data.description, args)
		"creation":
			result = execute_creation_command(cmd_name, cmd_data.description, args)
		"consciousness":
			result = execute_consciousness_command(cmd_name, cmd_data.description, args)
		"interface":
			result = execute_interface_command(cmd_name, cmd_data.description, args)
		_:
			result = execute_simple_command(cmd_name, cmd_data.description, args)
	
	return result

# ===== SPECIALIZED COMMAND EXECUTORS =====

func execute_knowledge_command(name: String, desc: String, args: Array) -> String:
	"""Execute knowledge/documentation commands"""
	var action = args[0] if args.size() > 0 else "toggle"
	
	# Check if KnowledgeLODManager is available
	if not has_node("/root/KnowledgeLODManager"):
		return "❌ Knowledge LOD system not available"
	
	var knowledge_manager = get_node("/root/KnowledgeLODManager")
	
	match action.to_lower():
		"open", "toggle", "show":
			if not knowledge_manager.is_knowledge_active:
				knowledge_manager.open_knowledge_lod()
				return "📚 Knowledge LOD interface opened! Use 1-5 to switch spaces"
			else:
				knowledge_manager.close_knowledge_lod()
				return "📚 Knowledge LOD interface closed"
		
		"space":
			if args.size() < 2:
				return "Usage: %s space <space_name>" % name
			var space_name = args[1]
			knowledge_manager.switch_knowledge_space(space_name)
			return "🌌 Switched to knowledge space: %s" % space_name
		
		"lod":
			knowledge_manager.cycle_lod_level()
			return "📊 LOD level cycled"
		
		"search":
			var query = args[1] if args.size() > 1 else ""
			knowledge_manager.search_knowledge(query)
			return "🔍 Searching knowledge for: %s" % query
		
		"status":
			return knowledge_manager.get_console_status()
		
		"claude_desktop", "docs", "memory", "jsh":
			knowledge_manager.switch_knowledge_space(action)
			return "🌌 Switched to knowledge space: %s" % action
		
		_:
			# Default: toggle knowledge interface
			if not knowledge_manager.is_knowledge_active:
				knowledge_manager.open_knowledge_lod()
				return "📚 Knowledge LOD opened! Press N or type 'knowledge close' to close"
			else:
				return knowledge_manager.get_console_status()

func execute_lighting_command(name: String, desc: String, args: Array) -> String:
	"""Execute lighting/sun commands"""
	var value = 1.0
	if args.size() > 0 and args[0].is_valid_float():
		value = float(args[0])
	
	# Adjust sun/lighting
	if "bright" in desc.to_lower():
		interface_controls["sun_brightness"] = clamp(value, 0.0, 5.0)
		_update_lighting_in_scene()
		interface_changed.emit("sun_brightness", value)
		return "☀️ Sun brightness set to %.1f" % value
	elif "temperature" in desc.to_lower() or "color" in desc.to_lower():
		interface_controls["sun_temperature"] = clamp(value, 1000.0, 10000.0)
		_update_lighting_in_scene()
		interface_changed.emit("sun_temperature", value)
		return "🌡️ Sun temperature set to %.0fK" % value
	else:
		_update_lighting_in_scene()
		return "💡 Lighting command '%s' executed!" % name

func execute_physics_command(name: String, desc: String, args: Array) -> String:
	"""Execute physics commands"""
	var value = 9.8
	if args.size() > 0 and args[0].is_valid_float():
		value = float(args[0])
	
	if "gravity" in desc.to_lower():
		interface_controls["gravity"] = value
		# Try to set actual gravity
		if ProjectSettings.has_setting("physics/3d/default_gravity"):
			ProjectSettings.set_setting("physics/3d/default_gravity", value)
		interface_changed.emit("gravity", value)
		return "🌍 Gravity set to %.1f" % value
	else:
		return "⚡ Physics command '%s' executed!" % name

func execute_temporal_command(name: String, desc: String, args: Array) -> String:
	"""Execute time/temporal commands"""
	var value = 1.0
	if args.size() > 0 and args[0].is_valid_float():
		value = float(args[0])
	
	interface_controls["time_speed"] = clamp(value, 0.1, 10.0)
	Engine.time_scale = interface_controls["time_speed"]
	interface_changed.emit("time_speed", value)
	return "⏰ Time speed set to %.1fx" % value

func execute_creation_command(name: String, desc: String, args: Array) -> String:
	"""Execute creation/spawn commands"""
	var what_to_create = args[0] if args.size() > 0 else name
	var creation_name = args[1] if args.size() > 1 else (what_to_create + "_" + str(randi() % 1000))
	
	# Try to create a Universal Being
	var being = _create_universal_being(creation_name, what_to_create)
	if being:
		return "✨ Created %s: '%s'" % [what_to_create, creation_name]
	else:
		return "📦 Creation command '%s' executed! (Conceptual creation)" % name

func execute_consciousness_command(name: String, desc: String, args: Array) -> String:
	"""Execute consciousness commands"""
	var level = 3.0
	if args.size() > 0 and args[0].is_valid_float():
		level = clamp(float(args[0]), 0.0, 5.0)
	
	interface_controls["consciousness_level"] = level
	_affect_consciousness_in_scene(level)
	interface_changed.emit("consciousness_level", level)
	return "🧠 Consciousness level set to %.1f" % level

func execute_interface_command(name: String, desc: String, args: Array) -> String:
	"""Execute interface control commands"""
	if args.size() >= 2:
		var control_name = args[0]
		var control_value = float(args[1]) if args[1].is_valid_float() else 1.0
		
		if control_name in interface_controls:
			interface_controls[control_name] = control_value
			interface_changed.emit(control_name, control_value)
			return "🎛️ Interface control '%s' set to %.1f" % [control_name, control_value]
	
	return "🎛️ Interface command '%s' executed!" % name

func execute_simple_command(name: String, desc: String, args: Array) -> String:
	"""Execute simple text commands"""
	var arg_text = " (with: %s)" % ", ".join(args) if args.size() > 0 else ""
	return "🎮 %s: %s%s" % [name.capitalize(), desc, arg_text]

# ===== INTERFACE CONTROL SYSTEMS =====

func _update_lighting_in_scene() -> void:
	"""Update lighting in the current scene"""
	var lights = []
	_find_lights_in_scene(get_tree().root, lights)
	
	for light in lights:
		if light is DirectionalLight3D:  # Sun
			light.light_energy = interface_controls["sun_brightness"]
			# Approximate temperature to color
			var temp = interface_controls["sun_temperature"]
			if temp < 3000:
				light.light_color = Color(1.0, 0.5, 0.2)  # Warm/red
			elif temp < 5000:
				light.light_color = Color(1.0, 0.8, 0.6)  # Warm white
			elif temp < 7000:
				light.light_color = Color(1.0, 1.0, 1.0)  # Pure white
			else:
				light.light_color = Color(0.7, 0.8, 1.0)  # Cool blue

func _find_lights_in_scene(node: Node, lights: Array) -> void:
	"""Find all lights in scene"""
	if node is Light3D:
		lights.append(node)
	for child in node.get_children():
		_find_lights_in_scene(child, lights)

func _affect_consciousness_in_scene(level: float) -> void:
	"""Affect consciousness of all beings in scene"""
	var beings = get_tree().get_nodes_in_group("universal_beings")
	for being in beings:
		if being.has_property("consciousness_level"):
			being.consciousness_level = min(being.consciousness_level + (level - 3.0), 5.0)

func _create_universal_being(being_name: String, being_type: String) -> Node:
	"""Create a Universal Being if possible"""
	var being_script = load("res://core/UniversalBeing.gd")
	if being_script:
		var being = being_script.new()
		being.being_name = being_name
		being.being_type = being_type
		being.consciousness_level = 1
		
		var current_scene = get_tree().current_scene
		if current_scene:
			current_scene.add_child(being)
			return being
	return null

# ===== USER INTERFACE FUNCTIONS =====

func show_help() -> String:
	var help_text = "🎮 SIMPLE COMMAND CREATOR - Create any command instantly!\n\n"
	help_text += "📚 Knowledge LOD Commands:\n"
	help_text += "• knowledge / notepad / docs - Toggle knowledge interface\n"
	help_text += "• klod status - Show knowledge system status\n"
	help_text += "• kspace <space> - Switch knowledge space\n"
	help_text += "• kspace claude_desktop - Claude documentation\n"
	help_text += "• kspace claude_memory - Memory/memories docs\n"
	help_text += "• kspace jsh - JSH documentation\n\n"
	help_text += "Interface Controls (like real life potentiometers):\n"
	help_text += "• sun_brightness: %.1f (0.0-5.0)\n" % interface_controls["sun_brightness"]
	help_text += "• sun_temperature: %.0fK (1000-10000)\n" % interface_controls["sun_temperature"]
	help_text += "• gravity: %.1f\n" % interface_controls["gravity"]
	help_text += "• time_speed: %.1fx\n" % interface_controls["time_speed"]
	help_text += "• consciousness_level: %.1f (0-5)\n" % interface_controls["consciousness_level"]
	help_text += "• reality_energy: %.1f\n\n" % interface_controls["reality_energy"]
	help_text += "Examples:\n"
	help_text += "  brighten_sun makes sun brighter\n"
	help_text += "  slow_time slows down time\n"
	help_text += "  spawn_tree creates a tree being\n"
	help_text += "  boost_consciousness increases awareness\n"
	help_text += "  knowledge open knowledge interface\n"
	help_text += "  kspace claude_desktop\n\n"
	help_text += "Total commands created: %d" % command_count
	
	return help_text

func list_commands() -> String:
	"""List all created commands"""
	if created_commands.is_empty():
		return "📝 No commands created yet. Just type anything to create one!"
	
	var result = "🎮 CREATED COMMANDS:\n\n"
	for cmd_name in created_commands:
		var cmd = created_commands[cmd_name]
		result += "• %s (%s) - %s [used %d times]\n" % [cmd_name, cmd.type, cmd.description, cmd.usage_count]
	
	return result

func get_interface_status() -> String:
	"""Get current interface control status"""
	var result = "🎛️ INTERFACE CONTROLS:\n\n"
	for control in interface_controls:
		result += "• %s: %.1f\n" % [control, interface_controls[control]]
	return result

# ===== UNIVERSAL CONSOLE INTEGRATION =====

func process_console_input(input: String) -> String:
	"""Process input from any console"""
	var trimmed = input.strip_edges()
	var parts = trimmed.split(" ")
	var cmd = parts[0].to_lower()
	
	# Handle special knowledge commands first
	match cmd:
		"knowledge", "notepad", "docs", "kl":
			return execute_knowledge_command("knowledge", "knowledge interface", parts.slice(1))
		"klod":
			return execute_knowledge_command("klod", "knowledge lod system", parts.slice(1))
		"kspace":
			if parts.size() > 1:
				return execute_knowledge_command("kspace", "knowledge space", ["space", parts[1]])
			else:
				return "Usage: kspace <claude_desktop|claude_home_mds|claude_memory|jsh|root_docs>"
	
	# Handle regular special commands
	if trimmed == "help" or trimmed == "?":
		return show_help()
	elif trimmed == "listcmds" or trimmed == "commands":
		return list_commands()
	elif trimmed == "interface" or trimmed == "controls":
		return get_interface_status()
	elif trimmed.begins_with("newcmd "):
		var cmd_part = trimmed.substr(7)  # Remove "newcmd "
		return create_new_command(cmd_part)
	elif trimmed in created_commands:
		var args = parts.slice(1) if parts.size() > 1 else []
		return execute_created_command(cmd, args)
	else:
		# If it's not a known command, try to execute as command with args first
		if parts.size() > 1 and parts[0] in created_commands:
			return execute_created_command(parts[0], parts.slice(1))
		else:
			# Otherwise create it!
			return create_new_command(trimmed)

# ===== AUTO-INTEGRATION =====

func _enter_tree() -> void:
	"""Auto-setup when added to scene"""
	call_deferred("integrate_with_scene")

func integrate_with_scene() -> void:
	"""Integrate with current scene automatically"""
	# Try to find and connect to console
	var console = find_console_node()
	if console:
		print("🔗 Integrated with console in scene!")
	
	# Add interface controls to scene if needed
	_setup_interface_controls()

func _setup_interface_controls() -> void:
	"""Setup interface controls in the scene"""
	# This could create actual UI elements for the potentiometers
	print("🎛️ Interface controls ready - use commands to adjust reality!")

# ===== SAVE/LOAD =====

func save_commands() -> void:
	"""Save created commands"""
	var file = FileAccess.open("user://simple_commands.json", FileAccess.WRITE)
	if file:
		var save_data = {
			"commands": created_commands,
			"interface_controls": interface_controls,
			"timestamp": Time.get_unix_time_from_system()
		}
		file.store_string(JSON.stringify(save_data))
		file.close()

func load_commands() -> void:
	"""Load saved commands"""
	var file = FileAccess.open("user://simple_commands.json", FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		if json.parse(json_text) == OK:
			var data = json.data
			created_commands = data.get("commands", {})
			var saved_controls = data.get("interface_controls", {})
			
			# Merge saved controls with defaults
			for control in saved_controls:
				if control in interface_controls:
					interface_controls[control] = saved_controls[control]
			
			command_count = created_commands.size()
			print("📂 Loaded %d saved commands!" % command_count)

func _exit_tree() -> void:
	"""Save on exit"""
	save_commands()