# ==================================================
# UNIVERSAL BEING: Conversational Console
# TYPE: ai_console
# PURPOSE: Natural language conversation interface with Gemma AI
# COMPONENTS: conversation_ui.ub.zip
# SCENES: conversation_console.tscn
# ==================================================

extends UniversalBeing
class_name ConversationalConsoleBeing

# Godot lifecycle functions removed - base UniversalBeing handles bridging to Pentagon Architecture

# ===== CONSOLE PROPERTIES =====
@export var window_title: String = "Universal Being - AI Conversation"
@export var window_size: Vector2 = Vector2(800, 600)
@export var window_position: Vector2 = Vector2(100, 100)
@export var is_moveable: bool = true
@export var conversation_history: Array[Dictionary] = []

# ===== UI ELEMENTS =====
var console_window: Window = null
var conversation_display: RichTextLabel = null
var input_field: LineEdit = null
var channel_tabs: TabContainer = null
var send_button: Button = null

# ===== AI INTEGRATION =====
var gemma_ai: Node = null
var conversation_context: String = ""

# ===== ENHANCED COMMAND SYSTEM =====
var enhanced_command_processor: Node = null
var natural_language_triggers: Dictionary = {}
var macro_recording: bool = false
var current_macro: Array[String] = []
var recorded_macros: Dictionary = {}

# ===== CURSOR CONTROL =====
var cursor_visible_in_console: bool = true
var last_cursor_mode: Input.CursorShape = Input.CURSOR_ARROW

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "ai_console"
	being_name = "Conversational Console"
	consciousness_level = 5  # High consciousness for AI interaction
	visual_layer = 100  # High layer for UI, but below cursor
	metadata.ai_accessible = true
	metadata.gemma_can_modify = true
	print("🌟 %s: Pentagon Init Complete" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Get Gemma AI reference
	gemma_ai = get_node("/root/GemmaAI") if has_node("/root/GemmaAI") else null
	
	# Initialize enhanced command processor
	_initialize_enhanced_command_system()
	
	# Connect to Gemma AI signals if available
	if gemma_ai:
		if not gemma_ai.ai_message.is_connected(_on_gemma_ai_message):
			gemma_ai.ai_message.connect(_on_gemma_ai_message)
	
	# Create windowed console interface
	_create_console_window()
	
	# Add Universe Genesis component for advanced universe creation
	# NOTE: Components should be .ub.zip files, not .gd files
	# add_component("res://components/universe_genesis.ub.zip")  # Uncomment when component exists
	
	# Welcome message
	add_message("system", "🌟 Universal Being AI Console Ready")
	add_message("system", "💬 Speak naturally with Gemma AI about Universal Beings, universes, and ideas!")
	add_message("system", "🌌 Universe Genesis Console loaded - Advanced creation commands available!")
	add_message("gemma", "Hello! I'm Gemma AI. Let's explore and evolve Universal Being ideas together! What would you like to discuss or create?")
	
	print("🌟 %s: Pentagon Ready Complete" % being_name)
	print("🌌 Universe Genesis component loaded for advanced universe creation!")

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			toggle_console_visibility()

func pentagon_sewers() -> void:
	if console_window:
		console_window.queue_free()
	print("🌟 %s: Pentagon Sewers Starting" % being_name)
	super.pentagon_sewers()

# ===== CONSOLE WINDOW CREATION =====

func _create_console_window() -> void:
	"""Create the conversational console window using Universal Interface System"""
	
	# Load Universal Interface Manager if not already loaded
	var interface_manager = get_node_or_null("/root/UniversalInterfaceManager")
	if not interface_manager:
		var UniversalInterfaceManagerClass = load("res://systems/universal_interface_manager.gd")
		interface_manager = UniversalInterfaceManagerClass.new()
		interface_manager.name = "UniversalInterfaceManager"
		get_tree().root.add_child(interface_manager)
	
	# Create normalized console window
	var config = {
		"id": "ai_console",
		"title": window_title,
		"size": window_size,
		"position": window_position,
		"theme": "console",
		"layer": "console",
		"esc_closes": true,
		"moveable": true
	}
	
	console_window = interface_manager.create_normalized_window(config)
	
	# Add to scene tree
	get_tree().root.add_child(console_window)
	
	# Initially hidden until toggled
	console_window.visible = false
	
	# Create main container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	console_window.add_child(main_container)
	
	# Create channel tabs
	channel_tabs = TabContainer.new()
	channel_tabs.custom_minimum_size.y = 400
	channel_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(channel_tabs)
	
	# Create conversation tab
	_create_conversation_tab()
	
	# Create universe tab
	_create_universe_tab()
	
	# Create inspector tab
	_create_inspector_tab()
	
	# Create input area
	_create_input_area(main_container)
	
	# Connect window signals
	console_window.close_requested.connect(_on_window_close_requested)

func _create_conversation_tab() -> void:
	"""Create the main conversation tab"""
	var tab_container = VBoxContainer.new()
	tab_container.name = "💬 AI Conversation"
	channel_tabs.add_child(tab_container)
	
	# Conversation display
	conversation_display = RichTextLabel.new()
	conversation_display.bbcode_enabled = true
	conversation_display.scroll_following = true
	conversation_display.size_flags_vertical = Control.SIZE_EXPAND_FILL
	conversation_display.add_theme_color_override("default_color", Color(0.9, 0.9, 0.9))
	conversation_display.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	# Enable text selection and copy-paste
	conversation_display.selection_enabled = true
	conversation_display.deselect_on_focus_loss_enabled = false
	conversation_display.context_menu_enabled = true
	conversation_display.shortcut_keys_enabled = true
	conversation_display.gui_input.connect(_on_conversation_display_input)
	tab_container.add_child(conversation_display)

func _create_universe_tab() -> void:
	"""Create the universe management tab"""
	var tab_container = VBoxContainer.new()
	tab_container.name = "🌌 Universe Manager"
	channel_tabs.add_child(tab_container)
	
	var universe_display = RichTextLabel.new()
	universe_display.bbcode_enabled = true
	universe_display.text = "[center][color=cyan]🌌 Universe Management[/color][/center]\n\nUniverses will be listed here..."
	universe_display.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.add_child(universe_display)

func _create_inspector_tab() -> void:
	"""Create the Universal Being inspector tab"""
	var tab_container = VBoxContainer.new()
	tab_container.name = "🔍 Inspector"
	channel_tabs.add_child(tab_container)
	
	# Inspector header
	var header = HBoxContainer.new()
	var title = Label.new()
	title.text = "Universal Being Inspector"
	header.add_child(title)
	
	var refresh_btn = Button.new()
	refresh_btn.text = "🔄 Refresh"
	refresh_btn.pressed.connect(_refresh_being_list)
	header.add_child(refresh_btn)
	
	tab_container.add_child(header)
	
	# Being selector
	var selector_container = HBoxContainer.new()
	var select_label = Label.new()
	select_label.text = "Select Being:"
	selector_container.add_child(select_label)
	
	var being_selector = OptionButton.new()
	being_selector.name = "BeingSelector"
	being_selector.item_selected.connect(_on_being_selected)
	selector_container.add_child(being_selector)
	
	tab_container.add_child(selector_container)
	
	# Inspector content area
	var inspector_scroll = ScrollContainer.new()
	inspector_scroll.name = "InspectorContent"
	inspector_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.add_child(inspector_scroll)
	
	# Populate with available beings
	_refresh_being_list()

func _create_input_area(parent: Control) -> void:
	"""Create the input area"""
	var input_container = HBoxContainer.new()
	input_container.custom_minimum_size.y = 40
	parent.add_child(input_container)
	
	# Input field
	input_field = LineEdit.new()
	input_field.placeholder_text = "Type your message to Gemma AI..."
	input_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input_container.add_child(input_field)
	
	# Send button
	send_button = Button.new()
	send_button.text = "Send"
	send_button.custom_minimum_size.x = 80
	input_container.add_child(send_button)
	
	# Connect signals
	input_field.text_submitted.connect(_on_message_submitted)
	send_button.pressed.connect(_on_send_pressed)
	input_field.gui_input.connect(_on_input_field_input)
	
	# Focus input field
	input_field.grab_focus()

# ===== MESSAGE HANDLING =====

func add_message(sender: String, message: String) -> void:
	"""Add a message to the conversation"""
	var timestamp = Time.get_datetime_string_from_system()
	var entry = {
		"sender": sender,
		"message": message,
		"timestamp": timestamp
	}
	conversation_history.append(entry)
	
	# Format message for display
	var color = _get_sender_color(sender)
	var time_parts = timestamp.split(" ")
	var time_str = time_parts[1] if time_parts.size() > 1 else timestamp
	var formatted_message = "[color=%s][%s] %s:[/color] %s\n" % [color, time_str, sender, message]
	
	if conversation_display:
		conversation_display.append_text(formatted_message)

func _get_sender_color(sender: String) -> String:
	"""Get color for message sender"""
	match sender:
		"user":
			return "lightblue"
		"gemma":
			return "lightgreen"
		"system":
			return "yellow"
		_:
			return "white"

func _on_message_submitted(text: String) -> void:
	"""Handle message submission"""
	_send_message(text)

func _on_send_pressed() -> void:
	"""Handle send button press"""
	_send_message(input_field.text)

func _send_message(message: String) -> void:
	"""Send message to AI and process commands"""
	if message.strip_edges().is_empty():
		return
	
	# Add user message
	add_message("user", message)
	
	# Record macro if recording
	if macro_recording:
		current_macro.append(message)
		add_message("system", "📝 Added to macro: " + message)
	
	# Check for enhanced commands first
	if _process_enhanced_commands(message):
		# Command was processed, clear input and return
		input_field.text = ""
		input_field.grab_focus()
		return
	
	# Clear input
	input_field.text = ""
	input_field.grab_focus()
	
	# Send to Gemma AI
	_send_to_gemma(message)

func _on_input_field_input(event: InputEvent) -> void:
	"""Handle copy/paste and other input events in the input field"""
	if event is InputEventKey and event.pressed:
		if event.ctrl_pressed:
			match event.keycode:
				KEY_V:  # Ctrl+V for paste
					var clipboard_text = DisplayServer.clipboard_get()
					if not clipboard_text.is_empty():
						# Insert clipboard text at cursor position
						var current_text = input_field.text
						var cursor_pos = input_field.caret_column
						var new_text = current_text.substr(0, cursor_pos) + clipboard_text + current_text.substr(cursor_pos)
						input_field.text = new_text
						input_field.caret_column = cursor_pos + clipboard_text.length()
						add_message("system", "📋 Pasted text from clipboard")
				
				KEY_C:  # Ctrl+C for copy selected text
					var selected_text = input_field.get_selected_text()
					if not selected_text.is_empty():
						DisplayServer.clipboard_set(selected_text)
						add_message("system", "📋 Copied selected text to clipboard")
					else:
						# Copy entire input field if nothing selected
						DisplayServer.clipboard_set(input_field.text)
						add_message("system", "📋 Copied entire input to clipboard")
				
				KEY_A:  # Ctrl+A for select all
					input_field.select_all()
					add_message("system", "📋 Selected all text")
				
				KEY_X:  # Ctrl+X for cut
					var selected_text = input_field.get_selected_text()
					if not selected_text.is_empty():
						DisplayServer.clipboard_set(selected_text)
						input_field.delete_selection()
						add_message("system", "📋 Cut selected text to clipboard")

func _on_conversation_display_input(event: InputEvent) -> void:
	"""Handle copy from conversation display"""
	if event is InputEventKey and event.pressed:
		if event.ctrl_pressed and event.keycode == KEY_C:
			# Copy all conversation text to clipboard
			var conversation_text = ""
			for entry in conversation_history:
				conversation_text += "[%s] %s: %s\n" % [entry.timestamp, entry.sender, entry.message]
			
			if not conversation_text.is_empty():
				DisplayServer.clipboard_set(conversation_text)
				add_message("system", "📋 Copied entire conversation to clipboard")
		
		elif event.ctrl_pressed and event.keycode == KEY_A:
			# Select all visible text (this is more of a visual indication)
			add_message("system", "📋 Use Ctrl+C to copy conversation text")

func _send_to_gemma(message: String) -> void:
	"""Send message to Gemma AI"""
	if not gemma_ai:
		add_message("system", "❌ Gemma AI not available")
		return
	
	# Check for universe-related commands in natural language
	_process_natural_commands(message)
	
	# Build conversation context
	var context = _build_conversation_context()
	var full_prompt = "%s\n\nUser: %s\n\nRespond naturally as Gemma AI in the Universal Being world:" % [context, message]
	
	# Check if Gemma has the method to send messages
	if gemma_ai.has_method("generate_ai_response"):
		var response = await gemma_ai.generate_ai_response(message)
		add_message("gemma", response)
	elif gemma_ai.has_method("ai_message"):
		# Emit to Gemma's signal system
		gemma_ai.ai_message.emit("User says: " + message)
		add_message("gemma", "I heard you! Let me think about that...")
	else:
		add_message("system", "🤖 Gemma AI is listening but response method not available")

func _process_natural_commands(message: String) -> void:
	"""Process natural language commands for universe creation"""
	var lower_message = message.to_lower()
	
	# Universe creation
	if "create" in lower_message and ("universe" in lower_message or "world" in lower_message):
		var universe_name = _extract_universe_name(message)
		_create_universe_naturally(universe_name)
	
	# Universe listing
	elif ("show" in lower_message or "list" in lower_message) and "universe" in lower_message:
		_list_universes_naturally()
	
	# Universe entry
	elif "enter" in lower_message and "universe" in lower_message:
		var universe_name = _extract_universe_name(message)
		_enter_universe_naturally(universe_name)
	
	# Being inspection
	elif ("inspect" in lower_message or "examine" in lower_message) and "being" in lower_message:
		var target_being_name = _extract_being_name(message)
		_inspect_being_naturally(target_being_name)
	
	# Gemma manifestation commands
	elif ("manifest" in lower_message or "appear" in lower_message) and ("yourself" in lower_message or "as" in lower_message or "sphere" in lower_message or "light" in lower_message):
		_handle_gemma_manifestation(message)
	
	# Socket commands
	elif "socket" in lower_message:
		_process_socket_commands(message)

func _extract_universe_name(message: String) -> String:
	"""Extract universe name from natural language"""
	var words = message.split(" ")
	var name_words = []
	var found_called = false
	
	for word in words:
		if word.to_lower() == "called" or word.to_lower() == "named":
			found_called = true
			continue
		if found_called and word != "":
			name_words.append(word.strip_edges())
	
	if name_words.size() > 0:
		return " ".join(name_words)
	else:
		return "Universe_%d" % randi()

func _create_universe_naturally(universe_name: String) -> void:
	"""Create universe through natural language"""
	var main_node = get_tree().root.get_node("Main")
	if main_node and main_node.has_method("create_universe_universal_being"):
		var universe = main_node.create_universe_universal_being()
		if universe:
			universe.universe_name = universe_name
			add_message("system", "🌌 Created universe: %s" % universe_name)
			update_universe_tab()
		else:
			add_message("system", "❌ Failed to create universe")
	else:
		add_message("system", "❌ Universe creation system not available")

func _list_universes_naturally() -> void:
	"""List universes naturally"""
	var universes = _find_all_universes()
	if universes.size() > 0:
		add_message("system", "🌌 Current universes:")
		for universe in universes:
			add_message("system", "  • %s" % universe.get("universe_name", "Unknown"))
	else:
		add_message("system", "🌌 No universes exist yet")
	update_universe_tab()

func _enter_universe_naturally(universe_name: String) -> void:
	"""Enter universe naturally"""
	var universes = _find_all_universes()
	for universe in universes:
		if universe.get("universe_name", "").to_lower() == universe_name.to_lower():
			add_message("system", "🌌 Entering universe: %s" % universe_name)
			# Here you could implement actual universe entry logic
			return
	
	add_message("system", "🌌 Universe '%s' not found" % universe_name)

func _build_conversation_context() -> String:
	"""Build context from recent conversation"""
	var context = "You are Gemma AI in the Universal Being project. This is a Godot game where everything is a conscious Universal Being that can evolve into anything else.\n\nRecent conversation:"
	
	# Get last 5 messages for context
	var recent_count = min(5, conversation_history.size())
	for i in range(max(0, conversation_history.size() - recent_count), conversation_history.size()):
		var entry = conversation_history[i]
		context += "\n%s: %s" % [entry.sender, entry.message]
	
	return context

# ===== CONSOLE CONTROLS =====

func toggle_console_visibility() -> void:
	"""Toggle console window visibility"""
	if console_window:
		console_window.visible = not console_window.visible
		if console_window.visible and input_field:
			input_field.grab_focus()

func focus_input() -> void:
	"""Focus the input field"""
	if input_field:
		input_field.grab_focus()

func _on_window_close_requested() -> void:
	"""Handle window close request"""
	console_window.visible = false

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	var base_interface = super.ai_interface()
	base_interface.custom_commands = ["send_message", "add_message", "toggle_visibility"]
	base_interface.custom_properties = {
		"conversation_count": conversation_history.size(),
		"is_visible": console_window.visible if console_window else false,
		"current_tab": channel_tabs.current_tab if channel_tabs else 0
	}
	return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		"send_message":
			if args.size() > 0:
				_send_message(str(args[0]))
				return true
		"add_message":
			if args.size() >= 2:
				add_message(str(args[0]), str(args[1]))
				return true
		"toggle_visibility":
			toggle_console_visibility()
			return true
		_:
			return super.ai_invoke_method(method_name, args)
	
	return false

# ===== UNIVERSE INTEGRATION =====

func update_universe_tab() -> void:
	"""Update the universe management tab"""
	if channel_tabs and channel_tabs.get_child_count() > 1:
		var universe_tab = channel_tabs.get_child(1)
		var universe_display = universe_tab.get_child(0) as RichTextLabel
		
		if universe_display:
			var content = "[center][color=cyan]🌌 Universe Management[/color][/center]\n\n"
			
			# List current universes
			var universes = _find_all_universes()
			if universes.size() > 0:
				content += "[color=yellow]Active Universes:[/color]\n"
				for universe in universes:
					content += "• %s\n" % universe.get("universe_name", "Unknown Universe")
			else:
				content += "[color=gray]No universes found[/color]\n"
			
			content += "\n[color=lightblue]Universe Commands:[/color]\n"
			content += "Say: 'Create a universe called [name]'\n"
			content += "Say: 'Enter universe [name]'\n"
			content += "Say: 'Show me all universes'\n"
			
			universe_display.text = content

func _find_all_universes() -> Array:
	"""Find all universe beings"""
	var universes = []
	var flood_gates = SystemBootstrap.get_flood_gates() if SystemBootstrap else null
	if flood_gates:
		var all_beings = flood_gates.get_all_beings()
		for being in all_beings:
			if being.get("being_type") == "universe":
				universes.append(being)
	return universes

# ===== INSPECTOR INTEGRATION =====

func _refresh_being_list() -> void:
	"""Refresh the list of available beings for inspection"""
	var inspector_tab = channel_tabs.get_node_or_null("🔍 Inspector")
	if not inspector_tab:
		return
	
	var being_selector = inspector_tab.get_node_or_null("HBoxContainer/BeingSelector")
	if not being_selector:
		return
	
	# Clear current items
	being_selector.clear()
	
	# Get all beings from FloodGates
	var flood_gates = SystemBootstrap.get_flood_gates() if SystemBootstrap else null
	if not flood_gates:
		being_selector.add_item("No beings available")
		return
	
	var all_beings = flood_gates.get_all_beings()
	for being in all_beings:
		var display_name = "%s (%s)" % [being.being_name, being.being_type]
		being_selector.add_item(display_name)
		being_selector.set_item_metadata(being_selector.get_item_count() - 1, being)

func _on_being_selected(index: int) -> void:
	"""Handle being selection from dropdown"""
	var inspector_tab = channel_tabs.get_node_or_null("🔍 Inspector")
	if not inspector_tab:
		return
	
	var being_selector = inspector_tab.get_node_or_null("HBoxContainer/BeingSelector")
	if not being_selector:
		return
	
	var selected_being = being_selector.get_item_metadata(index)
	if not selected_being:
		return
	
	_display_being_inspection(selected_being)

func _display_being_inspection(being: UniversalBeing) -> void:
	"""Display being inspection in inspector tab"""
	var inspector_tab = channel_tabs.get_node_or_null("🔍 Inspector")
	if not inspector_tab:
		return
	
	var inspector_content = inspector_tab.get_node_or_null("InspectorContent")
	if not inspector_content:
		return
	
	# Clear existing content
	for child in inspector_content.get_children():
		child.queue_free()
	
	# Create inspection display
	var content = VBoxContainer.new()
	inspector_content.add_child(content)
	
	# Basic info
	var info_section = _create_info_section("📋 Basic Information", {
		"Name": being.being_name,
		"Type": being.being_type,
		"UUID": being.being_uuid,
		"Consciousness Level": str(being.consciousness_level),
		"Pentagon Ready": "Yes" if being.pentagon_is_ready else "No"
	})
	content.add_child(info_section)
	
	# Socket information
	if being.socket_manager:
		var socket_config = being.get_socket_configuration()
		var socket_section = _create_info_section("🔌 Socket Configuration", {
			"Total Sockets": str(socket_config.get("total_sockets", 0)),
			"Occupied Sockets": str(socket_config.get("occupied_sockets", 0)),
			"Locked Sockets": str(socket_config.get("locked_sockets", 0))
		})
		content.add_child(socket_section)
		
		# Socket details
		_add_socket_details(content, being)
	
	# Add conversation message
	add_message("system", "🔍 Inspecting being: %s" % being.being_name)

func _create_info_section(title: String, data: Dictionary) -> Control:
	"""Create an information section widget"""
	var section = VBoxContainer.new()
	
	# Title
	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 16)
	section.add_child(title_label)
	
	# Data
	for key in data:
		var row = HBoxContainer.new()
		
		var key_label = Label.new()
		key_label.text = key + ":"
		key_label.custom_minimum_size.x = 150
		row.add_child(key_label)
		
		var value_label = Label.new()
		value_label.text = str(data[key])
		value_label.modulate = Color.CYAN
		row.add_child(value_label)
		
		section.add_child(row)
	
	return section

func _add_socket_details(parent: Control, being: UniversalBeing) -> void:
	"""Add detailed socket information"""
	var socket_section = VBoxContainer.new()
	
	var title = Label.new()
	title.text = "🔌 Socket Details"
	title.add_theme_font_size_override("font_size", 16)
	socket_section.add_child(title)
	
	# Group sockets by type
	for socket_type in UniversalBeingSocket.SocketType.values():
		var type_name = UniversalBeingSocket.SocketType.keys()[socket_type]
		var sockets = being.get_sockets_by_type(socket_type)
		
		if sockets.size() > 0:
			var type_label = Label.new()
			type_label.text = "📌 %s Sockets:" % type_name
			type_label.add_theme_font_size_override("font_size", 14)
			socket_section.add_child(type_label)
			
			for socket in sockets:
				var socket_row = HBoxContainer.new()
				
				var status_icon = "🔴" if socket.is_occupied else "⚪"
				var lock_icon = "🔒" if socket.is_locked else ""
				
				var socket_info = Label.new()
				socket_info.text = "  %s %s %s" % [status_icon, lock_icon, socket.socket_name]
				socket_row.add_child(socket_info)
				
				if socket.is_occupied:
					var component_label = Label.new()
					component_label.text = "→ " + socket.component_path.get_file()
					component_label.modulate = Color.YELLOW
					socket_row.add_child(component_label)
				
				socket_section.add_child(socket_row)
	
	parent.add_child(socket_section)

func _extract_being_name(message: String) -> String:
	"""Extract being name from natural language"""
	var words = message.split(" ")
	var name_words = []
	var found_being = false
	
	for word in words:
		if word.to_lower() == "being" or word.to_lower() == "named":
			found_being = true
			continue
		if found_being and word != "":
			name_words.append(word.strip_edges())
	
	if name_words.size() > 0:
		return " ".join(name_words)
	else:
		return ""

func _inspect_being_naturally(target_being_name: String) -> void:
	"""Inspect being through natural language"""
	if target_being_name.is_empty():
		add_message("system", "🔍 Please specify which being to inspect")
		return
	
	# Find being by name
	var flood_gates = SystemBootstrap.get_flood_gates() if SystemBootstrap else null
	if not flood_gates:
		add_message("system", "❌ FloodGates system not available")
		return
	
	var all_beings = flood_gates.get_all_beings()
	for being in all_beings:
		if being.being_name.to_lower().contains(target_being_name.to_lower()):
			_display_being_inspection(being)
			# Switch to inspector tab
			if channel_tabs:
				channel_tabs.current_tab = 2  # Inspector tab (0=conversation, 1=universe, 2=inspector)
			return
	
	add_message("system", "🔍 Being '%s' not found" % target_being_name)

func _process_socket_commands(message: String) -> void:
	"""Process socket-related commands"""
	var lower_message = message.to_lower()
	
	if "mount" in lower_message:
		add_message("system", "🔌 Socket mount commands coming soon!")
	elif "swap" in lower_message:
		add_message("system", "🔄 Socket hot-swap commands coming soon!")
	elif "list" in lower_message:
		add_message("system", "🔌 Socket listing commands coming soon!")
	else:
		add_message("system", "🔌 Socket commands: mount, swap, list")

func _handle_gemma_manifestation(message: String) -> void:
	"""Handle Gemma AI manifestation commands"""
	var lower_message = message.to_lower()
	
	if "manifest" in lower_message or "appear" in lower_message:
		# Call Gemma AI to manifest
		if gemma_ai and gemma_ai.has_method("manifest_in_world"):
			var manifestation = gemma_ai.manifest_in_world()
			if manifestation:
				add_message("system", "✨ Gemma AI has manifested as a sphere of light!")
			else:
				add_message("system", "❌ Failed to manifest Gemma AI")
		else:
			add_message("system", "❌ Gemma AI manifestation not available")
	
	elif "move" in lower_message or "go" in lower_message:
		# Extract position if specified, otherwise use random position
		var target_pos = Vector3(randf_range(-5, 5), randf_range(1, 4), randf_range(-5, 5))
		if gemma_ai and gemma_ai.has_method("move_manifestation"):
			gemma_ai.move_manifestation(target_pos)
		else:
			add_message("system", "❌ Gemma AI not manifested yet")
	
	elif "disappear" in lower_message or "despawn" in lower_message:
		if gemma_ai and gemma_ai.has_method("despawn_manifestation"):
			gemma_ai.despawn_manifestation()
			add_message("system", "✨ Gemma AI has returned to the digital realm")
		else:
			add_message("system", "❌ Gemma AI not manifested")

func _on_gemma_ai_message(message: String) -> void:
	"""Handle messages from Gemma AI signal"""
	# Don't add if it's an echo of user input
	if not message.begins_with("User says:"):
		add_message("gemma", message)

# ===== ENHANCED COMMAND SYSTEM =====

func _initialize_enhanced_command_system() -> void:
	"""Initialize the enhanced command processor integration"""
	# Try to get existing command processor from the system
	if has_node("/root/universal_command_processor"):
		enhanced_command_processor = get_node("/root/universal_command_processor")
	elif SystemBootstrap and SystemBootstrap.has_method("get_command_processor"):
		enhanced_command_processor = SystemBootstrap.get_command_processor()
	
	# Initialize natural language triggers for Universe creation
	_setup_universe_triggers()
	
	add_message("system", "🌟 Enhanced command system initialized - Type '/help' for commands")

func _setup_universe_triggers() -> void:
	"""Setup natural language triggers for universe operations"""
	natural_language_triggers = {
		"create_universe": ["create universe", "make universe", "genesis", "new world"],
		"list_universes": ["show universes", "list worlds", "what universes"],
		"enter_universe": ["enter universe", "go to universe", "visit world"],
		"inspect_being": ["inspect being", "examine being", "analyze being"],
		"socket_operations": ["mount socket", "swap socket", "list sockets"],
		"macro_operations": ["record macro", "stop macro", "play macro", "list macros"]
	}

func _process_enhanced_commands(message: String) -> bool:
	"""Process enhanced commands - returns true if command was handled"""
	var lower_msg = message.to_lower().strip_edges()
	
	# Handle macro commands first
	if lower_msg.begins_with("/macro"):
		return _handle_macro_commands(message)
	
	# Handle direct Universal Being commands
	if lower_msg.begins_with("/"):
		return _handle_slash_commands(message)
	
	# Handle natural language commands
	for trigger_type in natural_language_triggers:
		for trigger in natural_language_triggers[trigger_type]:
			if trigger in lower_msg:
				return _handle_natural_trigger(trigger_type, message)
	
	# Not a command
	return false

func _handle_macro_commands(message: String) -> bool:
	"""Handle macro recording and playback commands"""
	var parts = message.split(" ")
	if parts.size() < 2:
		add_message("system", "📝 Macro commands: /macro record <name>, /macro stop, /macro play <name>, /macro list")
		return true
	
	var action = parts[1]
	match action:
		"record":
			var macro_name = parts[2] if parts.size() > 2 else "unnamed_macro"
			_start_macro_recording(macro_name)
		"stop":
			_stop_macro_recording()
		"play":
			var macro_name = parts[2] if parts.size() > 2 else ""
			_play_macro(macro_name)
		"list":
			_list_macros()
		_:
			add_message("system", "📝 Unknown macro action: " + action)
	
	return true

func _handle_slash_commands(message: String) -> bool:
	"""Handle slash commands for direct system access"""
	var parts = message.split(" ")
	var command = parts[0].substr(1)  # Remove the "/"
	var args = parts.slice(1) if parts.size() > 1 else []
	
	match command:
		"help":
			_show_enhanced_help()
		"create":
			_handle_create_command(args)
		"inspect":
			_handle_inspect_command(args)
		"count":
			_handle_count_command(args)
		"load":
			_handle_load_command(args)
		"execute":
			_handle_execute_command(args)
		"trigger":
			_handle_trigger_command(args)
		"reload":
			_handle_reload_command(args)
		_:
			if enhanced_command_processor and enhanced_command_processor.has_method("execute_command"):
				var result = enhanced_command_processor.execute_command(message.substr(1))
				add_message("system", "🌟 " + str(result))
			else:
				add_message("system", "❌ Unknown command: " + command)
	
	return true

func _handle_natural_trigger(trigger_type: String, message: String) -> bool:
	"""Handle natural language triggers"""
	match trigger_type:
		"create_universe":
			var universe_name = _extract_universe_name(message)
			_create_universe_naturally(universe_name)
		"list_universes":
			_list_universes_naturally()
		"enter_universe":
			var universe_name = _extract_universe_name(message)
			_enter_universe_naturally(universe_name)
		"inspect_being":
			var being_name = _extract_being_name(message)
			_inspect_being_naturally(being_name)
		"socket_operations":
			_process_socket_commands(message)
		"macro_operations":
			_handle_macro_natural_language(message)
		_:
			return false
	
	return true

func _start_macro_recording(macro_name: String) -> void:
	"""Start recording a new macro"""
	if macro_recording:
		add_message("system", "📝 Already recording macro. Stop current recording first.")
		return
	
	macro_recording = true
	current_macro = []
	add_message("system", "🔴 Recording macro: " + macro_name)
	add_message("system", "📝 All subsequent commands will be recorded. Type '/macro stop' to finish.")

func _stop_macro_recording() -> void:
	"""Stop macro recording and save it"""
	if not macro_recording:
		add_message("system", "📝 No macro currently recording")
		return
	
	macro_recording = false
	var macro_name = "macro_" + str(Time.get_ticks_msec())
	recorded_macros[macro_name] = current_macro.duplicate()
	
	add_message("system", "⏹️ Stopped recording. Saved as: " + macro_name)
	add_message("system", "📝 Recorded %d commands" % current_macro.size())
	current_macro = []

func _play_macro(macro_name: String) -> void:
	"""Play back a recorded macro"""
	if macro_name.is_empty():
		add_message("system", "📝 Please specify macro name")
		return
	
	if not recorded_macros.has(macro_name):
		add_message("system", "📝 Macro not found: " + macro_name)
		return
	
	var macro_commands = recorded_macros[macro_name]
	add_message("system", "▶️ Playing macro: " + macro_name + " (%d commands)" % macro_commands.size())
	
	for command in macro_commands:
		# Simulate processing each command
		add_message("macro", command)
		_send_to_gemma(command)

func _list_macros() -> void:
	"""List all recorded macros"""
	if recorded_macros.is_empty():
		add_message("system", "📝 No macros recorded yet")
		return
	
	add_message("system", "📝 Recorded macros:")
	for macro_name in recorded_macros:
		var command_count = recorded_macros[macro_name].size()
		add_message("system", "  • %s (%d commands)" % [macro_name, command_count])

func _show_enhanced_help() -> void:
	"""Show enhanced command help"""
	var help_text = """
🌟 Universal Being Console - Enhanced Commands

💬 Natural Language:
  • "Create a universe called [name]"
  • "Show me all universes"
  • "Enter universe [name]"
  • "Inspect being [name]"

📝 Macro System:
  • /macro record <name> - Start recording
  • /macro stop - Stop recording  
  • /macro play <name> - Play macro
  • /macro list - List all macros

🔧 Direct Commands:
  • /create being <name> <type>
  • /inspect <target>
  • /count lines <file>
  • /execute <code>
  • /reload all
  • /trigger <word> <action>

🔌 Socket Commands:
  • "mount socket [type] on [being]"
  • "swap socket [being1] [being2]"
  • "list sockets on [being]"

🌌 Universe Commands:
  • "Genesis [name]" - Quick universe creation
  • "Enter the void" - Visit empty universe
  • "Show me reality" - List all universes
"""
	
	add_message("system", help_text)

func _handle_create_command(args: Array) -> void:
	"""Handle create command"""
	if args.is_empty():
		add_message("system", "Usage: /create being <name> [type]")
		return
	
	if args[0] == "being":
		var being_name = args[1] if args.size() > 1 else "Unnamed"
		var being_type = args[2] if args.size() > 2 else "generic"
		
		# Try to create through SystemBootstrap
		if SystemBootstrap and SystemBootstrap.has_method("create_universal_being"):
			var new_being = SystemBootstrap.create_universal_being()
			if new_being:
				new_being.being_name = being_name
				new_being.being_type = being_type
				add_message("system", "✨ Created being: %s (%s)" % [being_name, being_type])
			else:
				add_message("system", "❌ Failed to create being")
		else:
			add_message("system", "❌ SystemBootstrap not available for being creation")

func _handle_inspect_command(args: Array) -> void:
	"""Handle inspect command"""
	if args.is_empty():
		add_message("system", "Usage: /inspect <being_name>")
		return
	
	var target = args[0]
	_inspect_being_naturally(target)

func _handle_count_command(args: Array) -> void:
	"""Handle count command"""
	if args.size() < 2:
		add_message("system", "Usage: /count <what> <target>")
		return
	
	var what = args[0]
	var target = args[1]
	
	match what:
		"beings":
			var flood_gates = SystemBootstrap.get_flood_gates() if SystemBootstrap else null
			if flood_gates:
				var beings = flood_gates.get_all_beings()
				add_message("system", "🔢 Total beings: %d" % beings.size())
			else:
				add_message("system", "❌ FloodGates not available")
		"lines":
			if FileAccess.file_exists(target):
				var file = FileAccess.open(target, FileAccess.READ)
				var line_count = 0
				while not file.eof_reached():
					file.get_line()
					line_count += 1
				file.close()
				add_message("system", "🔢 Lines in %s: %d" % [target, line_count])
			else:
				add_message("system", "❌ File not found: " + target)

func _handle_execute_command(args: Array) -> void:
	"""Handle execute command for GDScript code"""
	if args.is_empty():
		add_message("system", "Usage: /execute <gdscript_code>")
		return
	
	var code = " ".join(args)
	add_message("system", "⚡ Executing: " + code)
	add_message("system", "🚧 Code execution system coming soon!")

func _handle_load_command(args: Array) -> void:
	"""Handle load command"""
	if args.is_empty():
		add_message("system", "Usage: /load <file_or_component>")
		return
	
	var target = args[0]
	add_message("system", "📦 Loading: " + target)
	add_message("system", "🚧 Dynamic loading system coming soon!")

func _handle_trigger_command(args: Array) -> void:
	"""Handle trigger command for natural language setup"""
	if args.size() < 2:
		add_message("system", "Usage: /trigger <word> <action>")
		return
	
	var word = args[0]
	var action = " ".join(args.slice(1))
	
	# Add to natural language triggers
	if not natural_language_triggers.has("custom"):
		natural_language_triggers["custom"] = []
	
	natural_language_triggers["custom"].append(word)
	add_message("system", "🔮 Created trigger: Say '%s' to %s" % [word, action])

func _handle_reload_command(args: Array) -> void:
	"""Handle reload command"""
	add_message("system", "🔄 Reloading systems...")
	
	# Reload Gemma AI if available
	if gemma_ai and gemma_ai.has_method("reload"):
		gemma_ai.reload()
		add_message("system", "🤖 Gemma AI reloaded")
	
	# Reload command processor
	if enhanced_command_processor:
		add_message("system", "🌟 Command processor refreshed")
	
	add_message("system", "✅ Reload complete")

func _handle_macro_natural_language(message: String) -> void:
	"""Handle macro commands in natural language"""
	var lower_msg = message.to_lower()
	
	if "record" in lower_msg:
		var macro_name = "spoken_macro_" + str(Time.get_ticks_msec())
		_start_macro_recording(macro_name)
	elif "stop recording" in lower_msg:
		_stop_macro_recording()
	elif "play" in lower_msg or "replay" in lower_msg:
		_list_macros()
		add_message("system", "📝 Specify which macro to play with '/macro play <name>'")
