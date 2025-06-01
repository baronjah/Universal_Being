# ==================================================
# SCRIPT NAME: ConsoleUniversalBeing.gd
# DESCRIPTION: Revolutionary console where every element is a Universal Being
# PURPOSE: Socket-based interface system with Pentagon Architecture
# CREATED: 2025-06-01 - Universal Being Revolution  
# AUTHOR: JSH + Claude Code + Luminus + Alpha
# ==================================================

extends UniversalBeing
class_name ConsoleUniversalBeing

# ===== CONSOLE UNIVERSAL BEING =====

## Socket System (MMO-style)
var socket_grid: Array[Array] = []  # 8x6 grid of sockets
var socketed_beings: Dictionary = {}  # socket_id -> Universal Being
var socket_definitions: Dictionary = {}

## Console Elements  
var console_window: Control = null
var command_input: Node = null
var output_display: Node = null
var action_bar: Node = null

## Pentagon Console State
var console_active: bool = false
var ai_connected: bool = false
var command_history: Array[String] = []

# ===== CORE SIGNALS =====

signal console_opened()
signal console_closed()
signal command_entered(command: String)
signal element_socketed(socket_id: String, being: Node)
signal element_unsocketed(socket_id: String)

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	# Call parent init
	super()
	
	# Set console-specific properties
	being_type = "console"
	consciousness_level = 3
	being_name = "Universal Console"
	
	# Initialize socket grid (8x6)
	initialize_socket_grid()
	
	print("🖥️ ConsoleUniversalBeing: Pentagon console initialization")

func pentagon_ready() -> void:
	# Call parent ready
	super()
	
	# Load console blueprint from Akashic Records
	load_console_blueprint()
	
	# Create console interface
	create_console_interface()
	
	# Connect to Gemma AI for console commands
	connect_to_gemma_ai()

func pentagon_process(delta: float) -> void:
	# Call parent process
	super(delta)
	
	# Process console updates
	if console_active:
		update_console_state(delta)
		process_ai_integration(delta)

func pentagon_input(event: InputEvent) -> void:
	# Call parent input
	super(event)
	
	# Handle console-specific input
	if console_active:
		process_console_input(event)

func pentagon_sewers() -> void:
	# Save console state to Akashic Records
	save_console_state()
	
	# Cleanup socketed beings
	cleanup_socketed_beings()
	
	# Call parent cleanup
	super()

# ===== SOCKET SYSTEM =====

func initialize_socket_grid() -> void:
	"""Initialize the 8x6 socket grid"""
	socket_grid = []
	for x in range(8):
		var column = []
		for y in range(6):
			column.append(null)  # Empty socket
		socket_grid.append(column)
	
	print("🖥️ ConsoleUniversalBeing: Socket grid (8x6) initialized")

func create_socket(socket_id: String, x: int, y: int, width: int = 1, height: int = 1) -> bool:
	"""Create a socket in the grid"""
	if not is_socket_area_free(x, y, width, height):
		push_error("🖥️ Console: Socket area not free: %s" % socket_id)
		return false
	
	# Mark socket area as occupied
	for sx in range(x, x + width):
		for sy in range(y, y + height):
			if sx < 8 and sy < 6:
				socket_grid[sx][sy] = socket_id
	
	# Store socket definition
	socket_definitions[socket_id] = {
		"x": x, "y": y, "width": width, "height": height,
		"socketed_being": null, "accepts": [], "consciousness_required": 1
	}
	
	print("🖥️ Console: Socket created - %s at (%d,%d) size %dx%d" % [socket_id, x, y, width, height])
	return true

func is_socket_area_free(x: int, y: int, width: int, height: int) -> bool:
	"""Check if socket area is free"""
	for sx in range(x, x + width):
		for sy in range(y, y + height):
			if sx >= 8 or sy >= 6 or socket_grid[sx][sy] != null:
				return false
	return true

func socket_being(socket_id: String, being: Node) -> bool:
	"""Socket a Universal Being into a specific slot"""
	if not socket_id in socket_definitions:
		push_error("🖥️ Console: Socket not found: %s" % socket_id)
		return false
	
	var socket_def = socket_definitions[socket_id]
	if socket_def.socketed_being != null:
		push_warning("🖥️ Console: Socket already occupied: %s" % socket_id)
		return false
	
	# Check if being is compatible with socket
	if not is_being_compatible(socket_id, being):
		push_error("🖥️ Console: Being not compatible with socket: %s" % socket_id)
		return false
	
	# Socket the being using FloodGates
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("add_being_to_scene"):
			flood_gates.add_being_to_scene(being, self, true)
	else:
		add_child(being)
	
	# Register the socketed being
	socket_def.socketed_being = being
	socketed_beings[socket_id] = being
	
	# Configure being for console use
	configure_socketed_being(socket_id, being)
	
	element_socketed.emit(socket_id, being)
	print("🖥️ Console: Being socketed - %s -> %s" % [being.name, socket_id])
	return true

func unsocket_being(socket_id: String) -> bool:
	"""Remove a being from a socket"""
	if not socket_id in socket_definitions:
		return false
	
	var socket_def = socket_definitions[socket_id]
	var being = socket_def.socketed_being
	if not being:
		return false
	
	# Remove through FloodGates
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("remove_being"):
			flood_gates.remove_being(being)
	else:
		being.queue_free()
	
	# Clear socket
	socket_def.socketed_being = null
	socketed_beings.erase(socket_id)
	
	element_unsocketed.emit(socket_id)
	print("🖥️ Console: Being unsocketed from %s" % socket_id)
	return true

func is_being_compatible(socket_id: String, being: Node) -> bool:
	"""Check if a Universal Being is compatible with a socket"""
	var socket_def = socket_definitions[socket_id]
	
	# Check consciousness level requirement
	var consciousness = being.get("consciousness_level") if being.has_method("get") else 0
	if consciousness < socket_def.get("consciousness_required", 1):
		return false
	
	# Check type compatibility
	var being_type = being.get("being_type") if being.has_method("get") else "unknown"
	var accepted_types = socket_def.get("accepts", [])
	if accepted_types.size() > 0 and being_type not in accepted_types:
		return false
	
	return true

# ===== CONSOLE INTERFACE =====

func create_console_interface() -> void:
	"""Create the professional terminal interface"""
	print("🖥️ Console: Creating professional terminal interface...")
	
	# Create main console window
	console_window = Control.new()
	console_window.name = "ProfessionalTerminal"
	console_window.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	console_window.size = Vector2(900, 700)
	console_window.z_index = 100
	
	# Add to main scene UI layer
	var main_scene = get_tree().current_scene
	if main_scene:
		var ui_node = main_scene.get_node("UI")
		if ui_node:
			ui_node.add_child(console_window)
		else:
			main_scene.add_child(console_window)
	else:
		add_child(console_window)
	
	# Create the professional terminal structure
	create_terminal_structure()
	
	# Create default sockets after terminal structure is ready
	create_default_sockets()
	
	print("🖥️ Console: Professional terminal created (900x700)")

func create_default_sockets() -> void:
	"""Create the default socket layout"""
	# Command input socket (top row, spans 6 columns)
	create_socket("command_input_socket", 0, 0, 6, 1)
	socket_definitions["command_input_socket"]["accepts"] = ["text_input", "voice_input"]
	socket_definitions["command_input_socket"]["consciousness_required"] = 2
	
	# Output display socket (middle area, full width, 4 rows)  
	create_socket("output_display_socket", 0, 1, 8, 4)
	socket_definitions["output_display_socket"]["accepts"] = ["text_output", "visual_output"]
	socket_definitions["output_display_socket"]["consciousness_required"] = 1
	
	# Action bar socket (bottom row, full width)
	create_socket("action_bar_socket", 0, 5, 8, 1)
	socket_definitions["action_bar_socket"]["accepts"] = ["button", "slider", "toggle"]
	socket_definitions["action_bar_socket"]["consciousness_required"] = 1
	
	print("🖥️ Console: Default sockets created (3 main sockets)")

func create_terminal_structure() -> void:
	"""Create the complete professional terminal structure"""
	print("🖥️ Terminal: Building professional structure...")
	
	# Main background panel
	var main_panel = Panel.new()
	main_panel.name = "TerminalBackground"
	main_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Terminal background styling
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.08, 0.08, 0.12, 0.98)  # Very dark blue
	bg_style.border_width_left = 3
	bg_style.border_width_right = 3
	bg_style.border_width_top = 3
	bg_style.border_width_bottom = 3
	bg_style.border_color = Color(0.2, 0.6, 1.0, 0.8)  # Electric blue border
	bg_style.corner_radius_top_left = 12
	bg_style.corner_radius_top_right = 12
	bg_style.corner_radius_bottom_left = 12
	bg_style.corner_radius_bottom_right = 12
	
	main_panel.add_theme_stylebox_override("panel", bg_style)
	console_window.add_child(main_panel)
	
	# Main VBox layout
	var main_vbox = VBoxContainer.new()
	main_vbox.name = "TerminalLayout"
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 0)
	main_panel.add_child(main_vbox)
	
	# 1. CREATE HEADER WITH TITLE AND CLOSE BUTTON
	create_terminal_header(main_vbox)
	
	# 2. CREATE CHANNEL TABS FOR MEMORIES
	create_channel_system(main_vbox)
	
	# 3. CREATE RICH TEXT DISPLAY AREA
	create_rich_text_display(main_vbox)
	
	# 4. CREATE AUTOCOMPLETE SUGGESTIONS
	create_autocomplete_area(main_vbox)
	
	# 5. CREATE USER INPUT FIELD
	create_input_field(main_vbox)
	
	print("🖥️ Terminal: Professional structure complete!")

func create_terminal_header(parent: VBoxContainer) -> void:
	"""Create draggable header with title and close button"""
	var header = Panel.new()
	header.name = "TerminalHeader"
	header.custom_minimum_size = Vector2(0, 40)
	
	# Header styling
	var header_style = StyleBoxFlat.new()
	header_style.bg_color = Color(0.12, 0.12, 0.20, 1.0)
	header_style.border_width_bottom = 1
	header_style.border_color = Color(0.2, 0.6, 1.0, 0.5)
	header.add_theme_stylebox_override("panel", header_style)
	
	parent.add_child(header)
	
	# Header layout
	var header_hbox = HBoxContainer.new()
	header_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	header_hbox.add_theme_constant_override("separation", 10)
	header.add_child(header_hbox)
	
	# Terminal icon and title
	var title_label = Label.new()
	title_label.text = "🌟 UNIVERSAL CONSCIOUSNESS TERMINAL"
	title_label.add_theme_color_override("font_color", Color.CYAN)
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header_hbox.add_child(title_label)
	
	# Close button
	var close_button = Button.new()
	close_button.text = "✕"
	close_button.custom_minimum_size = Vector2(30, 30)
	close_button.add_theme_color_override("font_color", Color.RED)
	close_button.add_theme_font_size_override("font_size", 18)
	close_button.pressed.connect(close_terminal)
	header_hbox.add_child(close_button)
	
	# Make header draggable
	header.gui_input.connect(_on_header_input)

func create_channel_system(parent: VBoxContainer) -> void:
	"""Create memory channels for different console logs"""
	var channel_container = TabContainer.new()
	channel_container.name = "ChannelTabs"
	channel_container.custom_minimum_size = Vector2(0, 35)
	
	# Channel styling
	channel_container.add_theme_color_override("font_selected_color", Color.YELLOW)
	channel_container.add_theme_color_override("font_unselected_color", Color.CYAN)
	
	parent.add_child(channel_container)
	
	# Create different channels
	create_channel_tab(channel_container, "MAIN", "Main consciousness stream")
	create_channel_tab(channel_container, "AI", "Gemma AI communications")
	create_channel_tab(channel_container, "DEBUG", "System debug messages")
	create_channel_tab(channel_container, "BEINGS", "Universal Being activities")

func create_channel_tab(parent: TabContainer, title: String, description: String) -> void:
	"""Create individual channel tab"""
	var tab = Control.new()
	tab.name = title
	parent.add_child(tab)
	parent.set_tab_title(parent.get_tab_count() - 1, title)

func create_rich_text_display(parent: VBoxContainer) -> void:
	"""Create rich text display with per-character formatting"""
	var text_container = Panel.new()
	text_container.name = "TextDisplayContainer"
	text_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Text area styling
	var text_style = StyleBoxFlat.new()
	text_style.bg_color = Color(0.05, 0.05, 0.08, 1.0)
	text_style.border_width_left = 1
	text_style.border_width_right = 1
	text_style.border_width_top = 1
	text_style.border_width_bottom = 1
	text_style.border_color = Color(0.2, 0.6, 1.0, 0.3)
	text_container.add_theme_stylebox_override("panel", text_style)
	
	parent.add_child(text_container)
	
	# Rich text display
	var rich_text = RichTextLabel.new()
	rich_text.name = "RichTextDisplay"
	rich_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rich_text.add_theme_constant_override("margin_left", 10)
	rich_text.add_theme_constant_override("margin_right", 10)
	rich_text.add_theme_constant_override("margin_top", 10)
	rich_text.add_theme_constant_override("margin_bottom", 10)
	rich_text.bbcode_enabled = true
	rich_text.scroll_following = true
	rich_text.selection_enabled = true
	
	# Set initial rich text content
	rich_text.text = "[color=cyan]🌟 UNIVERSAL CONSCIOUSNESS TERMINAL ACTIVATED[/color]\n"
	rich_text.text += "[color=yellow]💫 Socket System: 8x6 grid ready[/color]\n"
	rich_text.text += "[color=lime]🤖 Gemma AI: Connected and conscious[/color]\n"
	rich_text.text += "[color=white]🖥️ Ready for commands...[/color]\n\n"
	
	text_container.add_child(rich_text)
	output_display = rich_text

func create_autocomplete_area(parent: VBoxContainer) -> void:
	"""Create autocomplete suggestions bracket"""
	var autocomplete_container = Panel.new()
	autocomplete_container.name = "AutocompleteContainer"
	autocomplete_container.custom_minimum_size = Vector2(0, 30)
	autocomplete_container.visible = false  # Hidden by default
	
	# Autocomplete styling
	var auto_style = StyleBoxFlat.new()
	auto_style.bg_color = Color(0.15, 0.15, 0.25, 0.9)
	auto_style.border_width_top = 1
	auto_style.border_color = Color(0.4, 0.8, 1.0, 0.6)
	autocomplete_container.add_theme_stylebox_override("panel", auto_style)
	
	parent.add_child(autocomplete_container)
	
	# Autocomplete text
	var auto_label = Label.new()
	auto_label.name = "AutocompleteText"
	auto_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	auto_label.add_theme_constant_override("margin_left", 10)
	auto_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	auto_label.text = "💡 create button | evolve input | show sockets | help"
	auto_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0, 0.8))
	auto_label.add_theme_font_size_override("font_size", 12)
	autocomplete_container.add_child(auto_label)

func create_input_field(parent: VBoxContainer) -> void:
	"""Create user input field at bottom"""
	var input_container = Panel.new()
	input_container.name = "InputContainer"
	input_container.custom_minimum_size = Vector2(0, 45)
	
	# Input styling
	var input_style = StyleBoxFlat.new()
	input_style.bg_color = Color(0.1, 0.1, 0.15, 1.0)
	input_style.border_width_top = 2
	input_style.border_color = Color(0.2, 0.6, 1.0, 0.8)
	input_container.add_theme_stylebox_override("panel", input_style)
	
	parent.add_child(input_container)
	
	# Input field layout
	var input_hbox = HBoxContainer.new()
	input_hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	input_hbox.add_theme_constant_override("margin_left", 10)
	input_hbox.add_theme_constant_override("margin_right", 10)
	input_hbox.add_theme_constant_override("margin_top", 5)
	input_hbox.add_theme_constant_override("margin_bottom", 5)
	input_container.add_child(input_hbox)
	
	# Prompt indicator
	var prompt_label = Label.new()
	prompt_label.text = "🌟>"
	prompt_label.add_theme_color_override("font_color", Color.CYAN)
	prompt_label.add_theme_font_size_override("font_size", 16)
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	input_hbox.add_child(prompt_label)
	
	# User input line
	var input_line = LineEdit.new()
	input_line.name = "UserInput"
	input_line.placeholder_text = "Enter consciousness command..."
	input_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input_line.add_theme_color_override("font_color", Color.YELLOW)
	input_line.add_theme_color_override("font_placeholder_color", Color.GRAY)
	input_line.add_theme_font_size_override("font_size", 14)
	
	# Remove background from input
	var input_bg = StyleBoxEmpty.new()
	input_line.add_theme_stylebox_override("normal", input_bg)
	input_line.add_theme_stylebox_override("focus", input_bg)
	
	input_hbox.add_child(input_line)
	command_input = input_line
	
	# Connect input signals
	input_line.text_submitted.connect(_on_command_submitted)
	input_line.text_changed.connect(_on_input_changed)

func close_terminal() -> void:
	"""Close the terminal"""
	toggle_console()

var is_dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _on_header_input(event: InputEvent) -> void:
	"""Handle header dragging"""
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				is_dragging = true
				drag_offset = console_window.global_position - event.global_position
			else:
				# Stop dragging
				is_dragging = false
	elif event is InputEventMouseMotion and is_dragging:
		# Handle drag motion
		console_window.global_position = event.global_position + drag_offset

func _on_input_changed(text: String) -> void:
	"""Handle input text changes for autocomplete"""
	var autocomplete = console_window.find_child("AutocompleteContainer", true, false)
	if autocomplete:
		autocomplete.visible = text.length() > 0

# ===== BLUEPRINT LOADING =====

func load_console_blueprint() -> void:
	"""Load console definition from Akashic Records"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic and akashic.has_method("load_interface_blueprint"):
			var blueprint = akashic.load_interface_blueprint("console_base.txt")
			if blueprint:
				apply_blueprint(blueprint)
				print("🖥️ Console: Blueprint loaded from Akashic Records")
			else:
				print("🖥️ Console: Using default blueprint")
				create_default_interface()
		else:
			print("🖥️ Console: Akashic Records not available, using defaults")
			create_default_interface()
	else:
		print("🖥️ Console: Systems not ready, using defaults")
		create_default_interface()

func apply_blueprint(blueprint: Dictionary) -> void:
	"""Apply loaded blueprint to console"""
	# Apply blueprint settings
	if blueprint.has("layout"):
		apply_layout_settings(blueprint.layout)
	
	if blueprint.has("socket_definitions"):
		apply_socket_definitions(blueprint.socket_definitions)

func create_default_interface() -> void:
	"""Create basic console interface without blueprint"""
	print("🖥️ Console: Creating default interface...")
	# Create basic input/output interface
	create_basic_input_output()
	print("🖥️ Console: Default interface created")

# ===== AI INTEGRATION =====

func connect_to_gemma_ai() -> void:
	"""Connect console to Gemma AI"""
	if GemmaAI and not ai_connected:
		# Disconnect any existing connections to prevent duplicates
		if GemmaAI.ai_message.is_connected(on_ai_message):
			GemmaAI.ai_message.disconnect(on_ai_message)
		
		GemmaAI.ai_message.connect(on_ai_message)
		ai_connected = true
		print("🖥️ Console: Connected to Gemma AI")
		
		# Send greeting to AI (only once)
		if GemmaAI.has_method("ai_message"):
			GemmaAI.ai_message.emit("🖥️ Universal Console activated! Every interface element is a conscious Universal Being.")

func on_ai_message(message: String) -> void:
	"""Handle messages from Gemma AI"""
	display_output("🤖 Gemma: " + message)
	
	# Check if Gemma is sending a command
	if message.begins_with("COMMAND:"):
		var command = message.substr(8).strip_edges()
		display_output("🤖 Gemma executing: " + command)
		handle_console_command(command)

func ai_send_command(command: String) -> void:
	"""Allow AI to send commands directly to console"""
	display_output("🤖 AI Command: " + command)
	handle_console_command(command)

func process_ai_integration(delta: float) -> void:
	"""Process AI integration each frame"""
	if ai_connected and GemmaAI:
		# Allow AI to inspect and modify console
		if GemmaAI.has_method("analyze_console"):
			# Periodic analysis (every few seconds)
			pass

# ===== CONSOLE OPERATIONS =====

func toggle_console() -> void:
	"""Toggle console visibility"""
	if console_window:
		console_active = not console_active
		console_window.visible = console_active
		
		if console_active:
			console_opened.emit()
			print("🖥️ Console: Opened")
		else:
			console_closed.emit()
			print("🖥️ Console: Closed")


func process_command(command: String) -> void:
	"""Process a command entered in console"""
	command_history.append(command)
	command_entered.emit(command)
	
	display_output("🖥️ Command: " + command)
	print("🖥️ Console Command: " + command)
	
	# Process command locally first
	handle_console_command(command)
	
	# Send to Gemma AI if connected
	if ai_connected and GemmaAI and GemmaAI.has_method("process_user_input"):
		GemmaAI.process_user_input(command)

func handle_console_command(command: String) -> void:
	"""Handle console commands locally"""
	var cmd = command.to_lower().strip_edges()
	
	if cmd.begins_with("create "):
		var what = cmd.substr(7)  # Remove "create "
		handle_create_command(what)
	elif cmd.begins_with("evolve "):
		var what = cmd.substr(7)  # Remove "evolve "
		handle_evolve_command(what)
	elif cmd == "show sockets":
		display_output(debug_socket_info())
	elif cmd == "help":
		show_console_help()
	else:
		display_output("🖥️ Unknown command: " + command)
		display_output("🖥️ Try: create button, evolve input, show sockets, help")

func handle_create_command(what: String) -> void:
	"""Handle create commands"""
	match what:
		"button":
			display_output("🌟 Creating ButtonBeing... (TODO: Implement)")
		"input":
			display_output("🌟 Creating TextInputBeing... (TODO: Implement)")
		"output":
			display_output("🌟 Creating OutputDisplayBeing... (TODO: Implement)")
		_:
			display_output("🖥️ Can create: button, input, output")

func handle_evolve_command(what: String) -> void:
	"""Handle evolve commands"""
	display_output("🌟 Evolution system activated for: " + what)
	display_output("🌟 (TODO: Implement Universal Being evolution)")

func show_console_help() -> void:
	"""Show console help"""
	display_output("🌟 UNIVERSAL CONSOLE COMMANDS:")
	display_output("  create button - Create conscious button")
	display_output("  create input - Create conscious input field")
	display_output("  evolve [being] - Evolve Universal Being")
	display_output("  show sockets - Display socket grid status")
	display_output("  help - Show this help")

# ===== DEBUG FUNCTIONS =====

func get_console_info() -> Dictionary:
	"""Get console information for debugging"""
	return {
		"active": console_active,
		"ai_connected": ai_connected,
		"total_sockets": socket_definitions.size(),
		"socketed_beings": socketed_beings.size(),
		"command_history": command_history.size(),
		"consciousness_level": consciousness_level
	}

func debug_socket_info() -> String:
	"""Get socket debug information"""
	var info = []
	info.append("=== Console Socket Debug ===")
	info.append("Total Sockets: %d" % socket_definitions.size())
	
	for socket_id in socket_definitions:
		var socket_def = socket_definitions[socket_id]
		var being = socket_def.socketed_being
		var status = "Empty" if not being else being.name
		info.append("  %s: %s" % [socket_id, status])
	
	return "\n".join(info)

# ===== MISSING FUNCTIONS IMPLEMENTATION =====

func update_console_state(delta: float) -> void:
	"""Update console state each frame"""
	# Update socketed beings
	for socket_id in socketed_beings:
		var being = socketed_beings[socket_id]
		if being and being.has_method("pentagon_process"):
			being.pentagon_process(delta)

func process_console_input(event: InputEvent) -> void:
	"""Process console-specific input"""
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				if console_active:
					toggle_console()
			KEY_ENTER:
				if command_input and command_input.has_method("get_text"):
					var command = command_input.get_text()
					if command.length() > 0:
						process_command(command)

func save_console_state() -> void:
	"""Save console state to Akashic Records"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var akashic = SystemBootstrap.get_akashic_records()
		if akashic and akashic.has_method("save_console_state"):
			var state_data = {
				"socket_definitions": socket_definitions,
				"socketed_beings": get_socketed_beings_data(),
				"console_active": console_active
			}
			akashic.save_console_state(state_data)
			print("🖥️ Console: State saved to Akashic Records")

func cleanup_socketed_beings() -> void:
	"""Cleanup all socketed beings"""
	for socket_id in socketed_beings.keys():
		unsocket_being(socket_id)
	socketed_beings.clear()
	print("🖥️ Console: All socketed beings cleaned up")

func configure_socketed_being(socket_id: String, being: Node) -> void:
	"""Configure a being after socketing"""
	if being.has_method("set_socket_context"):
		being.set_socket_context(socket_id, self)
	
	# Position the being in the socket
	var socket_def = socket_definitions[socket_id]
	if being is Control:
		var control_being = being as Control
		control_being.position = Vector2(socket_def.x * 100, socket_def.y * 100)
		control_being.size = Vector2(socket_def.width * 100, socket_def.height * 100)
	
	print("🖥️ Console: Being configured for socket %s" % socket_id)

func apply_layout_settings(layout: Dictionary) -> void:
	"""Apply layout settings from blueprint"""
	if layout.has("window_size"):
		var size = layout.window_size
		if console_window:
			console_window.size = Vector2(size.x, size.y)
	
	if layout.has("background_color"):
		var color = layout.background_color
		setup_console_styling_with_color(Color(color.r, color.g, color.b, color.a))
	
	print("🖥️ Console: Layout settings applied")

func apply_socket_definitions(socket_defs: Array) -> void:
	"""Apply socket definitions from blueprint"""
	for socket_data in socket_defs:
		if socket_data.has("id") and socket_data.has("x") and socket_data.has("y"):
			var socket_id = socket_data.id
			var x = socket_data.x
			var y = socket_data.y
			var width = socket_data.get("width", 1)
			var height = socket_data.get("height", 1)
			
			create_socket(socket_id, x, y, width, height)
			
			# Apply socket-specific settings
			if socket_data.has("accepts"):
				socket_definitions[socket_id]["accepts"] = socket_data.accepts
			if socket_data.has("consciousness_required"):
				socket_definitions[socket_id]["consciousness_required"] = socket_data.consciousness_required
	
	print("🖥️ Console: Blueprint socket definitions applied")

func create_basic_input_output() -> void:
	"""Create basic input/output interface without blueprint"""
	print("🖥️ Console: create_basic_input_output() called")
	if not console_window:
		print("🖥️ Console: ERROR - No console_window!")
		return
	
	print("🖥️ Console: Console window exists, children: %d" % console_window.get_child_count())
	
	# Create a simple VBoxContainer layout
	var vbox = VBoxContainer.new()
	vbox.name = "BasicLayout"
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	vbox.add_theme_constant_override("margin_left", 20)
	vbox.add_theme_constant_override("margin_right", 20)
	vbox.add_theme_constant_override("margin_top", 20)
	vbox.add_theme_constant_override("margin_bottom", 20)
	
	# Add to console panel (the child we created in setup_console_styling)
	var console_panel = console_window.get_child(0) if console_window.get_child_count() > 0 else console_window
	console_panel.add_child(vbox)
	print("🖥️ Console: VBox added to console panel")
	
	# Create title
	var title_label = Label.new()
	title_label.name = "ConsoleTitle"
	title_label.text = "🌟 UNIVERSAL CONSOLE - CONSCIOUSNESS LEVEL 3 🌟"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_color_override("font_color", Color.CYAN)
	title_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title_label)
	
	# Create output area
	var output_label = Label.new()
	output_label.name = "OutputArea"
	output_label.text = "🖥️ Universal Console Ready\n🌟 Every element is a Universal Being!\n🌟 Socket System: 8x6 grid active\n🌟 Type commands below:\n"
	output_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	output_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	output_label.add_theme_color_override("font_color", Color.WHITE)
	output_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(output_label)
	output_display = output_label
	
	# Create input area
	var input_line = LineEdit.new()
	input_line.name = "InputArea"
	input_line.placeholder_text = "Enter command (e.g. 'create button', 'evolve input')..."
	input_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input_line.add_theme_color_override("font_color", Color.YELLOW)
	input_line.add_theme_font_size_override("font_size", 14)
	vbox.add_child(input_line)
	command_input = input_line
	
	# Connect input signals
	if input_line.has_signal("text_submitted"):
		input_line.text_submitted.connect(_on_command_submitted)
	
	print("🖥️ Console: Basic input/output interface created")

func setup_console_styling_with_color(bg_color: Color) -> void:
	"""Setup console styling with custom background color"""
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = bg_color
	style_box.border_width_left = 2
	style_box.border_width_right = 2
	style_box.border_width_top = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.06, 0.2, 0.38)
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	
	if console_window:
		console_window.add_theme_stylebox_override("panel", style_box)

func get_socketed_beings_data() -> Dictionary:
	"""Get data for socketed beings for saving"""
	var data = {}
	for socket_id in socketed_beings:
		var being = socketed_beings[socket_id]
		if being and being.has_method("get_save_data"):
			data[socket_id] = being.get_save_data()
		else:
			data[socket_id] = {"name": being.name, "type": "unknown"}
	return data

func _on_command_submitted(text: String) -> void:
	"""Handle command submission from input field"""
	if text.length() > 0:
		process_command(text)
		if command_input and command_input.has_method("clear"):
			command_input.clear()

# ===== OVERRIDE DISPLAY OUTPUT =====

func display_output(text: String) -> void:
	"""Display text in rich text output area with channel routing"""
	print("🖥️ Terminal Output: " + text)
	
	# Route message to appropriate channel
	var channel = determine_message_channel(text)
	route_to_channel(text, channel)
	
	# Also display in current active channel
	if output_display and output_display.has_method("append_text"):
		var formatted_text = format_terminal_text(text)
		output_display.append_text(formatted_text + "\n")
	elif output_display:
		var current_text = output_display.text if output_display.has_method("get") else ""
		output_display.text = current_text + text + "\n"

func determine_message_channel(text: String) -> String:
	"""Determine which channel a message belongs to"""
	if text.begins_with("🤖"):
		return "AI"
	elif text.begins_with("🌊") or text.begins_with("🚀") or text.begins_with("ERROR"):
		return "DEBUG"  
	elif text.begins_with("🌟") and ("Being" in text or "being" in text):
		return "BEINGS"
	else:
		return "MAIN"

func route_to_channel(text: String, channel: String) -> void:
	"""Route message to specific channel storage"""
	# TODO: Store messages in channel-specific arrays for later display
	# For now, just tag the message
	print("📡 Routing to %s: %s" % [channel, text.substr(0, 50) + "..."])

func format_terminal_text(text: String) -> String:
	"""Format text with colors for terminal display"""
	var formatted = text
	
	# Color code different types of messages
	if text.begins_with("🤖"):
		formatted = "[color=lime]" + text + "[/color]"
	elif text.begins_with("🖥️"):
		formatted = "[color=cyan]" + text + "[/color]"
	elif text.begins_with("🌟"):
		formatted = "[color=yellow]" + text + "[/color]"
	elif text.begins_with("💫"):
		formatted = "[color=magenta]" + text + "[/color]"
	elif text.begins_with("⚠️") or text.begins_with("ERROR"):
		formatted = "[color=red]" + text + "[/color]"
	else:
		formatted = "[color=white]" + text + "[/color]"
	
	return formatted
