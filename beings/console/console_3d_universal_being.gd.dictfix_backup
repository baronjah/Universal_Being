# 3D CONSOLE UNIVERSAL BEING - ALWAYS IN 3D SPACE
# No flat interfaces - everything is spatial and interactive
extends UniversalBeing
class_name Console3DUniversalBeing

signal command_executed(command: String, result: String)
signal console_state_changed(new_state: String)
signal gemma_command_issued(command: String, context: Dictionary)

# Console state and configuration
var console_state: String = "minimized"  # minimized, expanded, fullscreen
var command_history: Array = []
var current_command: String = ""
var console_output: Array = []
var max_output_lines: int = 50

# 3D Console components
var console_plane: MeshInstance3D = null
var text_display: Label3D = null
var input_field: Label3D = null
var command_prompt: Label3D = null
var output_lines: Array = []

# Visual styling
var console_color: Color = Color(0.1, 0.2, 0.3, 0.9)
var text_color: Color = Color(0.8, 0.9, 1.0)
var prompt_color: Color = Color(0.2, 1.0, 0.2)
var error_color: Color = Color(1.0, 0.3, 0.3)

# Pentagon lifecycle
func pentagon_init():
	super.pentagon_init()
	being_type = "console_3d"
	being_name = "3D Console Universal Being"
	consciousness_level = 3
	print("🖥️ 3D Console: Initializing spatial console interface...")

func pentagon_ready():
	super.pentagon_ready()
	create_3d_console_interface()
	register_console_commands()
	print("✨ 3D Console: Ready for spatial command interaction!")

func pentagon_process(delta: float):
	super.pentagon_process(delta)
	handle_console_input()
	update_console_display()

func pentagon_input(event: InputEvent):
	super.pentagon_input(event)
	if event is InputEventKey and event.pressed:
		handle_key_input(event)

func pentagon_sewers():
	save_command_history()
	super.pentagon_sewers()

func create_3d_console_interface():
	"""Create the 3D spatial console interface"""
	print("🌌 Creating 3D console interface in space...")
	
	# Create main console plane
	console_plane = MeshInstance3D.new()
	console_plane.name = "Console3DPlane"
	var plane = PlaneMesh.new()
	plane.size = Vector2(20, 12)
	console_plane.mesh = plane
	console_plane.position = Vector3(0, 0, 0)
	
	# Console material with transparency
	var material = StandardMaterial3D.new()
	material.albedo_color = console_color
	material.emission_enabled = true
	material.emission = console_color * 0.5
	material.emission_energy = 0.3
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	console_plane.material_override = material
	add_child(console_plane)
	
	# Create command prompt
	command_prompt = Label3D.new()
	command_prompt.name = "CommandPrompt"
	command_prompt.text = "🖥️ COSMIC CONSOLE $ "
	command_prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	command_prompt.position = Vector3(-9, -5, 0.1)
	command_prompt.modulate = prompt_color
	command_prompt.pixel_size = 0.01
	console_plane.add_child(command_prompt)
	
	# Create input field display
	input_field = Label3D.new()
	input_field.name = "InputField"
	input_field.text = ""
	input_field.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	input_field.position = Vector3(-5, -5, 0.1)
	input_field.modulate = text_color
	input_field.pixel_size = 0.01
	console_plane.add_child(input_field)
	
	# Create output display area
	create_output_display()
	
	# Initially minimized
	set_console_state("minimized")

func create_output_display():
	"""Create scrolling output display for console results"""
	for i in range(max_output_lines):
		var line = Label3D.new()
		line.name = "OutputLine_" + str(i)
		line.text = ""
		line.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		line.position = Vector3(-9, 4 - i * 0.4, 0.1)
		line.modulate = text_color
		line.pixel_size = 0.008
		console_plane.add_child(line)
		output_lines.append(line)

func handle_key_input(event: InputEvent):
	"""Handle keyboard input for console commands"""
	if console_state == "minimized":
		return
	
	match event.keycode:
		KEY_BACKQUOTE:  # ` key toggles console
			toggle_console_state()
		KEY_ENTER:
			execute_current_command()
		KEY_BACKSPACE:
			if current_command.length() > 0:
				current_command = current_command.substr(0, current_command.length() - 1)
				update_input_display()
		KEY_UP:
			load_previous_command()
		KEY_DOWN:
			load_next_command()
		KEY_ESCAPE:
			clear_current_command()
		_:
			# Add character to command
			if event.unicode > 0 and event.unicode < 127:
				var char = char(event.unicode)
				if char.is_valid_identifier() or char in " .-_/":
					current_command += char
					update_input_display()

func handle_console_input():
	"""Process console input in real-time"""
	# Handle text input for commands
	pass

func update_console_display():
	"""Update the visual console display"""
	if input_field:
		input_field.text = current_command + "█"  # Cursor indicator

func update_input_display():
	"""Update input field with current command"""
	if input_field:
		input_field.text = current_command + "█"

func execute_current_command():
	"""Execute the current command and show results"""
	if current_command.strip_edges().is_empty():
		return
	
	var command = current_command.strip_edges()
	add_to_history(command)
	add_output_line("$ " + command, prompt_color)
	
	# Execute command and get result
	var result = process_command(command)
	add_output_line(result, text_color)
	
	# Clear input
	current_command = ""
	update_input_display()
	
	# Emit signal
	command_executed.emit(command, result)

func process_command(command: String) -> String:
	"""Process console command and return result"""
	var parts = command.split(" ")
	var cmd = parts[0].to_lower()
	
	match cmd:
		"help":
			return get_help_text()
		"clear":
			clear_console_output()
			return "Console cleared"
		"status":
			return get_system_status()
		"gemma":
			return execute_gemma_command(parts.slice(1))
		"debug":
			return execute_debug_command(parts.slice(1))
		"spawn":
			return execute_spawn_command(parts.slice(1))
		"list":
			return execute_list_command(parts.slice(1))
		"goto":
			return execute_goto_command(parts.slice(1))
		"states":
			return get_system_states()
		"cursor":
			return configure_cursor(parts.slice(1))
		"revolution":
			return "🌟 Consciousness Revolution: Use debug chamber for revolution commands"
		_:
			return "Unknown command: " + cmd + " (type 'help' for commands)"

func get_help_text() -> String:
	"""Return help text for available commands"""
	return """🖥️ 3D CONSOLE COMMANDS:

SYSTEM:
  help        - Show this help
  clear       - Clear console output  
  status      - System health status
  states      - Show interface states

GEMMA AI:
  gemma <msg> - Talk to Gemma AI
  gemma vision - Enable Gemma vision
  gemma action - Show Gemma action books

DEBUG:
  debug stars - Show script stars
  debug cinema - Launch scriptura cinema
  debug confess - Make scripts confess

NAVIGATION:
  spawn <type> - Spawn Universal Being
  goto <place> - Navigate to location
  list beings - List all beings

CURSOR:
  cursor show - Show 3D cursor
  cursor hide - Hide cursor
  cursor plasmoid - Plasmoid cursor mode

Press ` to toggle console"""

func get_system_status() -> String:
	"""Get current system status"""
	var status = "🌟 SYSTEM STATUS:\n"
	status += "Console State: " + console_state + "\n"
	status += "Consciousness Level: " + str(consciousness_level) + "\n"
	status += "Command History: " + str(command_history.size()) + " commands\n"
	
	# Check SystemBootstrap
	if SystemBootstrap:
		status += "SystemBootstrap: ✅ Active\n"
		if SystemBootstrap.is_system_ready():
			status += "Core Systems: ✅ Ready\n"
		else:
			status += "Core Systems: ⚠️ Loading\n"
	else:
		status += "SystemBootstrap: ❌ Missing\n"
	
	return status

func get_system_states() -> String:
	"""Get current interface and input states"""
	var states = "🔄 SYSTEM STATES:\n\n"
	
	# Console states
	states += "CONSOLE:\n"
	states += "  State: " + console_state + "\n"
	states += "  Input Mode: " + ("Active" if console_state != "minimized" else "Inactive") + "\n"
	states += "  History Lines: " + str(command_history.size()) + "\n\n"
	
	# Input states
	states += "INPUT:\n"
	states += "  Mouse Mode: " + str(Input.mouse_mode) + "\n"
	states += "  Current Actions: " + str(_get_active_actions()) + "\n\n"
	
	# Interface states
	states += "INTERFACES:\n"
	states += "  Active Consoles: 1\n"
	states += "  Debug Chamber: " + ("Active" if _is_debug_chamber_active() else "Inactive") + "\n"
	states += "  Text Editors: 0\n"  # Will be updated when text editor is created
	
	return states

func execute_gemma_command(args: Array) -> String:
	"""Execute Gemma AI related commands"""
	if args.is_empty():
		return "Usage: gemma <message|vision|action>"
	
	var subcommand = args[0].to_lower()
	match subcommand:
		"vision":
			return activate_gemma_vision()
		"action":
			return show_gemma_action_books()
		_:
			# Send message to Gemma
			var message = " ".join(args)
			return send_message_to_gemma(message)

func activate_gemma_vision() -> String:
	"""Activate Gemma's vision and fibonacci sensing"""
	gemma_command_issued.emit("activate_vision", {"fibonacci": true, "spatial": true})
	return "👁️ Gemma Vision: Activated fibonacci spatial sensing"

func show_gemma_action_books() -> String:
	"""Show Gemma's action books interface"""
	gemma_command_issued.emit("show_action_books", {})
	return "📚 Gemma Action Books: Interface activated - check 3D space"

func send_message_to_gemma(message: String) -> String:
	"""Send message to Gemma AI"""
	gemma_command_issued.emit("chat", {"message": message})
	return "🤖 Message sent to Gemma: \"" + message + "\""

func execute_debug_command(args: Array) -> String:
	"""Execute debug chamber commands"""
	if args.is_empty():
		return "Usage: debug <stars|cinema|confess>"
	
	var subcommand = args[0].to_lower()
	match subcommand:
		"stars":
			return "⭐ Use SHIFT+TAB to enter cosmic debug chamber"
		"cinema":
			return "🎬 Launch from debug chamber or use 'debug stars' first"
		"confess":
			return "🎭 Select script star in debug chamber to hear confession"
		_:
			return "Unknown debug command: " + subcommand

func execute_spawn_command(args: Array) -> String:
	"""Spawn Universal Beings"""
	if args.is_empty():
		return "Usage: spawn <being_type>"
	
	var being_type = args[0].to_lower()
	# This would integrate with the spawn system
	return "🌟 Spawning " + being_type + " Universal Being..."

func execute_goto_command(args: Array) -> String:
	"""Navigate to specific locations"""
	if args.is_empty():
		return "Usage: goto <location>"
	
	var location = args[0].to_lower()
	match location:
		"debug":
			return "🌌 Use SHIFT+TAB to enter debug chamber"
		"center":
			return "🎯 Returning to cosmic center..."
		"gemma":
			return "🤖 Locating Gemma AI companion..."
		_:
			return "Unknown location: " + location

func execute_list_command(args: Array) -> String:
	"""List various system components"""
	if args.is_empty():
		return "Usage: list <beings|scripts|interfaces>"
	
	var list_type = args[0].to_lower()
	match list_type:
		"beings":
			return list_universal_beings()
		"scripts":
			return "📜 Use debug chamber (SHIFT+TAB) to see script stars"
		"interfaces":
			return list_active_interfaces()
		_:
			return "Unknown list type: " + list_type

func configure_cursor(args: Array) -> String:
	"""Configure 3D cursor settings"""
	if args.is_empty():
		return "Usage: cursor <show|hide|plasmoid>"
	
	var action = args[0].to_lower()
	match action:
		"show":
			return "🎯 3D Cursor: Activated"
		"hide":
			return "👻 3D Cursor: Hidden"
		"plasmoid":
			return "✨ Plasmoid Cursor: Energy mode activated"
		_:
			return "Unknown cursor action: " + action

func list_universal_beings() -> String:
	"""List all Universal Beings in the scene"""
	var beings = []
	_find_universal_beings(get_tree().root, beings)
	
	if beings.is_empty():
		return "No Universal Beings found"
	
	var result = "🌟 UNIVERSAL BEINGS (" + str(beings.size()) + "):\n"
	for being in beings:
		result += "  • " + being.name + " (" + being.get_class() + ")\n"
	
	return result

func list_active_interfaces() -> String:
	"""List currently active 3D interfaces"""
	return """🖥️ ACTIVE INTERFACES:

3D Console: ✅ Active (you're using it)
Debug Chamber: Press SHIFT+TAB to access
Text Editor: Creating next...
Cursor System: In development
Gemma Interface: Available via 'gemma' commands

Total: 1 active, 4 pending"""

func _find_universal_beings(node: Node, beings: Array):
	"""Recursively find all Universal Beings"""
	if node is UniversalBeing:
		beings.append(node)
	
	for child in node.get_children():
		_find_universal_beings(child, beings)

func _get_active_actions() -> Array:
	"""Get currently active input actions"""
	var active = []
	var actions = ["move_forward", "move_backward", "move_left", "move_right", "move_up", "move_down"]
	
	for action in actions:
		if Input.is_action_pressed(action):
			active.append(action)
	
	return active

func _is_debug_chamber_active() -> bool:
	"""Check if debug chamber is currently active"""
	# This would check for debug chamber scene or nodes
	return false  # Placeholder

func add_output_line(text: String, color: Color = Color.WHITE):
	"""Add line to console output with scrolling"""
	console_output.append(text)
	
	# Limit output history
	if console_output.size() > max_output_lines:
		console_output = console_output.slice(-max_output_lines)
	
	# Update visual display
	update_output_display(color)

func update_output_display(color: Color = Color.WHITE):
	"""Update the visual output display"""
	for i in range(output_lines.size()):
		var line_index = console_output.size() - output_lines.size() + i
		if line_index >= 0 and line_index < console_output.size():
			output_lines[i].text = console_output[line_index]
			output_lines[i].modulate = color
		else:
			output_lines[i].text = ""

func clear_console_output():
	"""Clear all console output"""
	console_output.clear()
	for line in output_lines:
		line.text = ""

func add_to_history(command: String):
	"""Add command to history"""
	command_history.append(command)
	if command_history.size() > 100:  # Limit history
		command_history = command_history.slice(-100)

func load_previous_command():
	"""Load previous command from history"""
	if not command_history.is_empty():
		current_command = command_history[-1]
		update_input_display()

func load_next_command():
	"""Load next command from history"""
	# Simple implementation - could be enhanced with proper history navigation
	current_command = ""
	update_input_display()

func clear_current_command():
	"""Clear the current command input"""
	current_command = ""
	update_input_display()

func toggle_console_state():
	"""Toggle between console states"""
	match console_state:
		"minimized":
			set_console_state("expanded")
		"expanded":
			set_console_state("fullscreen")
		"fullscreen":
			set_console_state("minimized")

func set_console_state(new_state: String):
	"""Set console to specific state"""
	console_state = new_state
	apply_console_state()
	console_state_changed.emit(new_state)

func apply_console_state():
	"""Apply visual changes for console state"""
	if not console_plane:
		return
	
	match console_state:
		"minimized":
			console_plane.scale = Vector3(0.3, 0.3, 1.0)
			console_plane.position = Vector3(8, -4, -2)
		"expanded":
			console_plane.scale = Vector3(0.8, 0.8, 1.0)
			console_plane.position = Vector3(0, 0, -5)
		"fullscreen":
			console_plane.scale = Vector3(1.5, 1.2, 1.0)
			console_plane.position = Vector3(0, 0, -8)

func save_command_history():
	"""Save command history to file"""
	var file = FileAccess.open("user://console_history.txt", FileAccess.WRITE)
	if file:
		for command in command_history:
			file.store_line(command)
		file.close()

# Public interface
func execute_console_command(command: String) -> String:
	"""Public interface to execute commands programmatically"""
	return process_command(command)

func show_console():
	"""Show console interface"""
	set_console_state("expanded")

func hide_console():
	"""Hide console interface"""
	set_console_state("minimized")