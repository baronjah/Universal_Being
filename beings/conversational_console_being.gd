# ==================================================
# UNIVERSAL BEING: Conversational Console
# TYPE: ai_console
# PURPOSE: Natural language conversation interface with Gemma AI
# COMPONENTS: conversation_ui.ub.zip
# SCENES: conversation_console.tscn
# ==================================================

extends UniversalBeing
class_name ConversationalConsoleBeing

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
	
	# Create windowed console interface
	_create_console_window()
	
	# Add Universe Genesis component for advanced universe creation
	add_component("res://components/universe_genesis/UniverseGenesisComponent.gd")
	
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
	"""Create the conversational console window"""
	# Create main window
	console_window = Window.new()
	console_window.title = window_title
	console_window.size = window_size
	console_window.position = window_position
	console_window.wrap_controls = true
	console_window.unresizable = false
	
	# Add to scene tree
	get_tree().root.add_child(console_window)
	
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
	"""Send message to AI"""
	if message.strip_edges().is_empty():
		return
	
	# Add user message
	add_message("user", message)
	
	# Clear input
	input_field.text = ""
	input_field.grab_focus()
	
	# Send to Gemma AI
	_send_to_gemma(message)

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
	if gemma_ai.has_method("generate_response"):
		var response = await gemma_ai.generate_response(full_prompt)
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
		var being_name = _extract_being_name(message)
		_inspect_being_naturally(being_name)
	
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

func _inspect_being_naturally(being_name: String) -> void:
	"""Inspect being through natural language"""
	if being_name.is_empty():
		add_message("system", "🔍 Please specify which being to inspect")
		return
	
	# Find being by name
	var flood_gates = SystemBootstrap.get_flood_gates() if SystemBootstrap else null
	if not flood_gates:
		add_message("system", "❌ FloodGates system not available")
		return
	
	var all_beings = flood_gates.get_all_beings()
	for being in all_beings:
		if being.being_name.to_lower().contains(being_name.to_lower()):
			_display_being_inspection(being)
			# Switch to inspector tab
			if channel_tabs:
				channel_tabs.current_tab = 2  # Inspector tab (0=conversation, 1=universe, 2=inspector)
			return
	
	add_message("system", "🔍 Being '%s' not found" % being_name)

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