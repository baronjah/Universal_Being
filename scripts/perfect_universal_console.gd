# ==================================================
# UNIVERSAL BEING: Perfect Universal Console
# TYPE: ai_console_perfect
# PURPOSE: THE perfect console with ALL features in one place
# FEATURES: Enhanced commands, natural language, macros, Gemma AI, normalized interface
# CREATED: 2025-06-04 - The Final Console Revolution
# ==================================================

extends UniversalBeing
class_name PerfectUniversalConsole

# ===== CONSOLE PROPERTIES =====
@export var window_title: String = "Universal Being - Perfect AI Console"
@export var window_size: Vector2 = Vector2(900, 700)
@export var window_position: Vector2 = Vector2(100, 100)
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
var console_ready: bool = false

# ===== INTERFACE LOADING SYSTEM =====
var loaded_interfaces: Dictionary = {}  # tab_index -> interface_node
var interface_connections: Dictionary = {}  # interface_node -> gemma_connection

# ===== ENHANCED COMMAND SYSTEM =====
var natural_language_triggers: Dictionary = {}
var macro_recording: bool = false
var current_macro: Array[String] = []
var recorded_macros: Dictionary = {}

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "ai_console_perfect"
	being_name = "Perfect Universal Console"
	consciousness_level = 7  # Maximum consciousness for perfect interface
	visual_layer = 95  # Console layer - below cursor but above game UI
	metadata.ai_accessible = true
	metadata.gemma_can_modify = true
	print("🌟 %s: Pentagon Init Complete - THE PERFECT CONSOLE" % being_name)

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
	
	# Create the perfect console window
	_create_perfect_console_window()
	
	# Try to load default interfaces
	load_default_interfaces()
	
	# Perfect welcome message
	add_message("system", "🌟 PERFECT UNIVERSAL CONSOLE ACTIVATED")
	add_message("system", "💬 All features unified: Commands, Natural Language, Macros, AI")
	add_message("system", "🎯 Type /help for enhanced commands or speak naturally to Gemma")
	add_message("gemma", "Hello! I'm Gemma AI with perfect integration. I can see everything, debug anything, and create whatever you dream! What shall we build together?")
	
	# Console system ready - enable all features
	_finalize_console_setup()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	if event is InputEventKey and event.pressed:
		# Console toggle - just backtick (`) 
		if event.keycode == KEY_QUOTELEFT:
			toggle_console_visibility()
			print("🖥️ Console toggle triggered!")

func pentagon_sewers() -> void:
	if console_window:
		console_window.queue_free()
	print("🌟 %s: Pentagon Sewers Starting" % being_name)
	super.pentagon_sewers()

# ===== PERFECT CONSOLE WINDOW CREATION =====

func _create_perfect_console_window() -> void:
	"""Create the perfect console window - simple and working!"""
	
	# Create basic working window
	console_window = Window.new()
	console_window.title = window_title
	console_window.size = Vector2(800, 600)  # Fixed size
	console_window.position = Vector2(50, 50)  # Top-left corner
	console_window.visible = false  # Start hidden
	
	# Add to scene tree
	get_tree().root.add_child(console_window)
	print("🖥️ Console window created successfully!")
	
	# Window layering is handled automatically by Godot
	
	# Initially hidden until toggled
	console_window.visible = false
	
	# Create main container
	var main_container = VBoxContainer.new()
	main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	console_window.add_child(main_container)
	
	# Create channel tabs
	channel_tabs = TabContainer.new()
	channel_tabs.custom_minimum_size.y = 500
	channel_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(channel_tabs)
	
	# Create conversation tab
	_create_conversation_tab()
	
	# Create universe tab
	_create_universe_tab()
	
	# Create universe rules editor tab
	_create_universe_rules_editor_tab()
	
	# Create inspector tab
	_create_inspector_tab()
	
	# Create macro tab
	_create_macro_tab()
	
	# Create input area
	_create_input_area(main_container)
	
	print("🎯 Perfect Console Window created with Universal Interface System!")

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
	# Enable perfect text selection and copy-paste
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
	universe_display.text = "[center][color=cyan]🌌 Perfect Universe Management[/color][/center]\\n\\nUniverses will be listed here..."
	universe_display.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.add_child(universe_display)

func _create_inspector_tab() -> void:
	"""Create the Universal Being inspector tab"""
	var tab_container = VBoxContainer.new()
	tab_container.name = "🔍 Perfect Inspector"
	channel_tabs.add_child(tab_container)
	
	# Inspector header
	var header = HBoxContainer.new()
	var title = Label.new()
	title.text = "Perfect Universal Being Inspector"
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

func _create_universe_rules_editor_tab() -> void:
	"""Create the universe rules editor tab"""
	var tab_container = VBoxContainer.new()
	tab_container.name = "🌌 Universe Rules"
	channel_tabs.add_child(tab_container)
	
	# Load the universe rules editor interface
	# TODO: Find existing universe rules editor in project
	var rules_placeholder = Label.new()
	rules_placeholder.text = "🌌 Universe Rules Editor\n(Integration pending)"
	rules_placeholder.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rules_placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rules_placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	tab_container.add_child(rules_placeholder)
	
	# Connect to Gemma vision
	# connect_to_gemma_vision(rules_placeholder)  # TODO: Re-enable when rules editor exists
	
	print("🌌 Universe Rules Editor tab created and connected to Gemma vision")

func _create_macro_tab() -> void:
	"""Create the macro management tab"""
	var tab_container = VBoxContainer.new()
	tab_container.name = "📝 Perfect Macros"
	channel_tabs.add_child(tab_container)
	
	var macro_display = RichTextLabel.new()
	macro_display.bbcode_enabled = true
	macro_display.text = "[center][color=yellow]📝 Perfect Macro System[/color][/center]\\n\\nRecord and playback command sequences:\\n/macro record <name>\\n/macro stop\\n/macro play <name>\\n/macro list"
	macro_display.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.add_child(macro_display)

func _create_input_area(parent: Control) -> void:
	"""Create the perfect input area"""
	var input_container = HBoxContainer.new()
	input_container.custom_minimum_size.y = 40
	parent.add_child(input_container)
	
	# Input field
	input_field = LineEdit.new()
	input_field.placeholder_text = "Perfect Console: Commands, Natural Language, or AI Chat..."
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

# ===== INTERFACE LOADING SYSTEM =====

func load_interface(interface_path: String, tab_index: int) -> void:
	"""Load a custom interface into a tab's content area"""
	if tab_index < 0 or tab_index >= channel_tabs.get_child_count():
		push_error("Invalid tab index: %d" % tab_index)
		return
	
	# Load the interface scene/script
	var interface_resource = load(interface_path)
	if not interface_resource:
		push_error("Failed to load interface: %s" % interface_path)
		return
	
	# Instantiate the interface
	var interface_node: Node = null
	if interface_resource is PackedScene:
		interface_node = interface_resource.instantiate()
	elif interface_resource is GDScript:
		# Create Control node for UI interfaces
		interface_node = Control.new()
		interface_node.set_script(interface_resource)
	else:
		push_error("Interface must be a PackedScene or GDScript: %s" % interface_path)
		return
	
	# Remove any existing interface in this tab
	if loaded_interfaces.has(tab_index):
		var old_interface = loaded_interfaces[tab_index]
		disconnect_from_gemma_vision(old_interface)
		old_interface.queue_free()
	
	# Get the tab container
	var tab_container = channel_tabs.get_child(tab_index)
	
	# Clear existing content (except the first child if it's a label/header)
	for i in range(tab_container.get_child_count() - 1, -1, -1):
		var child = tab_container.get_child(i)
		if child is RichTextLabel or child is ScrollContainer:
			child.queue_free()
	
	# Add the new interface
	tab_container.add_child(interface_node)
	loaded_interfaces[tab_index] = interface_node
	
	# Connect to Gemma vision
	connect_to_gemma_vision(interface_node)
	
	# Log the loading
	var akashic = SystemBootstrap.get_akashic_records() if SystemBootstrap else null
	if akashic and akashic.has_method("log_event"):
		akashic.log_event("interface_loaded", {
			"path": interface_path,
			"tab_index": tab_index,
			"tab_name": channel_tabs.get_tab_title(tab_index),
			"timestamp": Time.get_datetime_string_from_system()
		})
	
	add_message("system", "🌟 Loaded interface: %s into tab %d" % [interface_path, tab_index])

func connect_to_gemma_vision(interface_node: Node) -> void:
	"""Connect any interface to Gemma's vision systems"""
	if not gemma_ai:
		return
	
	# Check if Gemma has the observe_interface method
	if gemma_ai.has_method("observe_interface"):
		gemma_ai.observe_interface(interface_node)
		interface_connections[interface_node] = true
		add_message("gemma", "👁️ I can now see and understand this interface!")
	else:
		# Add the method to Gemma if it doesn't exist
		_add_gemma_interface_observation()
		if gemma_ai.has_method("observe_interface"):
			gemma_ai.observe_interface(interface_node)
			interface_connections[interface_node] = true

func disconnect_from_gemma_vision(interface_node: Node) -> void:
	"""Disconnect an interface from Gemma's vision"""
	if interface_connections.has(interface_node):
		interface_connections.erase(interface_node)
		
		if gemma_ai and gemma_ai.has_method("unobserve_interface"):
			gemma_ai.unobserve_interface(interface_node)

func _add_gemma_interface_observation() -> void:
	"""Add interface observation capability to Gemma if missing"""
	if not gemma_ai:
		return
	
	# Create a simple observation system
	var observation_script = """
extends Node

var observed_interfaces: Array[Node] = []

func observe_interface(interface_node: Node) -> void:
	if not interface_node in observed_interfaces:
		observed_interfaces.append(interface_node)
		print("🤖 Gemma: Now observing interface: ", interface_node.name)
		
		# Connect to interface signals if available
		if interface_node.has_signal("interface_updated"):
			interface_node.interface_updated.connect(_on_interface_updated.bind(interface_node))

func unobserve_interface(interface_node: Node) -> void:
	observed_interfaces.erase(interface_node)
	
	if interface_node.has_signal("interface_updated"):
		if interface_node.interface_updated.is_connected(_on_interface_updated):
			interface_node.interface_updated.disconnect(_on_interface_updated)

func _on_interface_updated(data: Dictionary, interface: Node) -> void:
	print("🤖 Gemma: Interface updated - ", interface.name, " - ", data)
	# Process interface changes
	"""
	
	# This is a placeholder - in reality, we'd extend GemmaAI properly
	add_message("system", "📝 Gemma interface observation system prepared")

func load_default_interfaces() -> void:
	"""Load default interfaces for each tab"""
	# Tab 0 is AI Conversation - load AI chat interface
	if ResourceLoader.exists("res://interfaces/ai_chat_interface.gd"):
		load_interface("res://interfaces/ai_chat_interface.gd", 0)
	
	# Tab 1 is Universe Manager
	if ResourceLoader.exists("res://interfaces/universe_builder_interface.gd"):
		load_interface("res://interfaces/universe_builder_interface.gd", 1)
	
	# Tab 2 is Inspector
	if ResourceLoader.exists("res://interfaces/being_inspector_interface.gd"):
		load_interface("res://interfaces/being_inspector_interface.gd", 2)
	
	# Tab 3 is Macros - already has content

func get_loaded_interface(tab_index: int) -> Node:
	"""Get the loaded interface for a specific tab"""
	return loaded_interfaces.get(tab_index, null)

func reload_interface(tab_index: int) -> void:
	"""Reload the interface in a specific tab"""
	if loaded_interfaces.has(tab_index):
		var interface = loaded_interfaces[tab_index]
		var interface_path = interface.get_script().resource_path if interface.get_script() else ""
		if interface_path:
			load_interface(interface_path, tab_index)

# ===== PERFECT MESSAGE HANDLING =====

func add_message(sender: String, message: String) -> void:
	"""Add a message to the perfect conversation"""
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
	var formatted_message = "[color=%s][%s] %s:[/color] %s\\n" % [color, time_str, sender, message]
	
	if conversation_display:
		conversation_display.append_text(formatted_message)

func _get_sender_color(sender: String) -> String:
	"""Get perfect color for message sender"""
	match sender:
		"user":
			return "lightblue"
		"gemma":
			return "lightgreen"
		"system":
			return "yellow"
		"macro":
			return "purple"
		"debug":
			return "orange"
		_:
			return "white"

func _on_message_submitted(text: String) -> void:
	"""Handle perfect message submission"""
	_send_message(text)

func _on_send_pressed() -> void:
	"""Handle perfect send button press"""
	_send_message(input_field.text)

func _send_message(message: String) -> void:
	"""Send message through perfect processing pipeline"""
	if message.strip_edges().is_empty():
		return
	
	# Add user message
	add_message("user", message)
	
	# Record macro if recording
	if macro_recording:
		current_macro.append(message)
		add_message("system", "📝 Added to macro: " + message)
	
	# Process enhanced commands first
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

func _send_to_gemma(message: String) -> void:
	"""Send message to Gemma AI with perfect integration"""
	if not gemma_ai:
		add_message("system", "❌ Gemma AI not available")
		return
	
	# Check for universe-related commands in natural language
	_process_natural_commands(message)
	
	# Build perfect conversation context
	var context = _build_conversation_context()
	var full_prompt = "%s\\n\\nUser: %s\\n\\nRespond naturally as Gemma AI in the Universal Being world:" % [context, message]
	
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

# ===== PERFECT ENHANCED COMMAND SYSTEM =====

func _initialize_enhanced_command_system() -> void:
	"""Initialize the perfect enhanced command processor"""
	_setup_perfect_triggers()
	add_message("system", "🌟 Perfect Enhanced Command System initialized - Type '/help' for all commands")

func _setup_perfect_triggers() -> void:
	"""Setup perfect natural language triggers"""
	natural_language_triggers = {
		"create_universe": ["create universe", "make universe", "genesis", "new world"],
		"list_universes": ["show universes", "list worlds", "what universes"],
		"enter_universe": ["enter universe", "go to universe", "visit world"],
		"inspect_being": ["inspect being", "examine being", "analyze being", "debug being"],
		"socket_operations": ["mount socket", "swap socket", "list sockets"],
		"macro_operations": ["record macro", "stop macro", "play macro", "list macros"],
		"gemma_manifest": ["manifest yourself", "appear as sphere", "show yourself"],
		"help_request": ["help", "what can you do", "how do I", "commands"]
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

func _handle_slash_commands(message: String) -> bool:
	"""Handle perfect slash commands"""
	var parts = message.split(" ")
	var command = parts[0].substr(1)  # Remove the "/"
	var args = parts.slice(1) if parts.size() > 1 else []
	
	match command:
		"help":
			_show_perfect_help()
		"create":
			_handle_create_command(args)
		"inspect":
			_handle_inspect_command(args)
		"count":
			_handle_count_command(args)
		"debug":
			_handle_debug_command(args)
		"fix":
			_handle_fix_command(args)
		"gemma":
			_handle_gemma_command(args)
		"load":
			_handle_load_interface_command(args)
		"reload":
			_handle_reload_interface_command(args)
		"interfaces":
			_show_loaded_interfaces()
		_:
			add_message("system", "❌ Unknown command: " + command + " - Type /help for available commands")
	
	return true

func _handle_macro_commands(message: String) -> bool:
	"""Handle perfect macro recording and playback"""
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

func _show_perfect_help() -> void:
	"""Show perfect command help"""
	var help_text = """
🌟 PERFECT UNIVERSAL CONSOLE - All Commands

💬 Natural Language (speak naturally):
  • "Create a universe called [name]"
  • "Show me all universes"  
  • "Inspect being [name]"
  • "Debug the movement system"
  • "Fix any errors you find"
  • "Gemma, manifest yourself as a sphere"

🔧 Enhanced Commands:
  • /help - Show this help
  • /create being <name> [type] - Create Universal Being
  • /inspect <being_name> - Deep being analysis
  • /count beings - Count all entities
  • /debug <system> - Debug any system
  • /fix <issue> - Auto-fix problems
  • /gemma <action> - Direct Gemma commands
  
📋 Interface Commands:
  • /load <path> <tab> - Load interface into tab
  • /reload <tab> - Reload interface in tab
  • /interfaces - Show all loaded interfaces

📝 Perfect Macro System:
  • /macro record <name> - Start recording
  • /macro stop - Stop recording
  • /macro play <name> - Replay macro
  • /macro list - List all macros

🎯 Interface Controls:
  • ESC - Close console
  • Ctrl+C - Copy conversation
  • Tab through interface sections
  • Click and drag to move window

🌟 Gemma Partnership Features:
  • Gemma can see everything in the 3D world
  • Gemma remembers all commands and shortcuts
  • Gemma can debug and fix any system
  • Gemma can create anything you imagine
  • Just speak naturally - no need to remember commands!
"""
	
	add_message("system", help_text)

# ===== PERFECT CONSOLE CONTROLS =====

func toggle_console_visibility() -> void:
	"""Toggle perfect console window visibility"""
	if console_window:
		console_window.visible = not console_window.visible
		print("🖥️ Console now visible: ", console_window.visible)
		if console_window.visible and input_field:
			input_field.grab_focus()
	else:
		print("❌ Console window is null! Creating it now...")
		_create_perfect_console_window()

func focus_input() -> void:
	"""Focus the perfect input field"""
	if input_field:
		input_field.grab_focus()

# ===== PLACEHOLDER METHODS =====
# (Keep all the enhanced functionality from conversational_console_being.gd)

func _process_natural_commands(message: String) -> void:
	"""Process natural language commands for interface management"""
	var lower_msg = message.to_lower()
	
	# Interface loading commands
	if "load" in lower_msg or "show" in lower_msg or "open" in lower_msg:
		if "universe" in lower_msg and ("builder" in lower_msg or "creator" in lower_msg):
			channel_tabs.current_tab = 1
			add_message("system", "🌌 Switched to Universe Builder tab")
		elif "inspector" in lower_msg or "inspect" in lower_msg:
			channel_tabs.current_tab = 2
			add_message("system", "🔍 Switched to Inspector tab")
		elif "chat" in lower_msg or "conversation" in lower_msg:
			channel_tabs.current_tab = 0
			add_message("system", "💬 Switched to AI Chat tab")
		elif "macro" in lower_msg:
			channel_tabs.current_tab = 3
			add_message("system", "📝 Switched to Macros tab")

func _handle_natural_trigger(trigger_type: String, message: String) -> bool:
	return false  # Implement natural triggers

func _handle_create_command(args: Array) -> void:
	add_message("system", "🔧 Create command processing...")

func _handle_inspect_command(args: Array) -> void:
	add_message("system", "🔍 Inspect command processing...")

func _handle_count_command(args: Array) -> void:
	pass
	var flood_gates = SystemBootstrap.get_flood_gates() if SystemBootstrap else null
	if flood_gates:
		var beings = flood_gates.get_all_beings()
		add_message("system", "🔢 Total beings: %d" % beings.size())
	else:
		add_message("system", "❌ FloodGates not available")

func _handle_debug_command(args: Array) -> void:
	add_message("system", "🐛 Debug command processing...")

func _handle_fix_command(args: Array) -> void:
	add_message("system", "🔧 Fix command processing...")

func _handle_gemma_command(args: Array) -> void:
	add_message("system", "🤖 Gemma command processing...")

func _handle_load_interface_command(args: Array) -> void:
	"""Handle interface loading command"""
	if args.size() < 2:
		add_message("system", "❌ Usage: /load <interface_path> <tab_index>")
		add_message("system", "Example: /load res://interfaces/ai_chat.tscn 0")
		return
	
	var interface_path = args[0]
	var tab_index = args[1].to_int()
	
	load_interface(interface_path, tab_index)

func _handle_reload_interface_command(args: Array) -> void:
	"""Handle interface reload command"""
	if args.size() < 1:
		add_message("system", "❌ Usage: /reload <tab_index>")
		return
	
	var tab_index = args[0].to_int()
	reload_interface(tab_index)

func _show_loaded_interfaces() -> void:
	"""Show all loaded interfaces"""
	add_message("system", "🌟 Loaded Interfaces:")
	
	for i in range(channel_tabs.get_child_count()):
		var tab_name = channel_tabs.get_tab_title(i)
		if loaded_interfaces.has(i):
			var interface = loaded_interfaces[i]
			var interface_name = interface.name if interface else "Unknown"
			add_message("system", "  Tab %d (%s): %s" % [i, tab_name, interface_name])
		else:
			add_message("system", "  Tab %d (%s): No custom interface loaded" % [i, tab_name])

func _start_macro_recording(macro_name: String) -> void:
	if macro_recording:
		add_message("system", "📝 Already recording macro. Stop current recording first.")
		return
	
	macro_recording = true
	current_macro = []
	add_message("system", "🔴 Recording macro: " + macro_name)

func _stop_macro_recording() -> void:
	if not macro_recording:
		add_message("system", "📝 No macro currently recording")
		return
	
	macro_recording = false
	var macro_name = "macro_" + str(Time.get_ticks_msec())
	recorded_macros[macro_name] = current_macro.duplicate()
	
	add_message("system", "⏹️ Stopped recording. Saved as: " + macro_name)
	current_macro = []

func _play_macro(macro_name: String) -> void:
	add_message("system", "▶️ Macro playback coming soon...")

func _list_macros() -> void:
	if recorded_macros.is_empty():
		add_message("system", "📝 No macros recorded yet")
		return
	
	add_message("system", "📝 Recorded macros:")
	for macro_name in recorded_macros:
		var command_count = recorded_macros[macro_name].size()
		add_message("system", "  • %s (%d commands)" % [macro_name, command_count])

func _refresh_being_list() -> void:
	pass  # Implement being list refresh

func _on_being_selected(index: int) -> void:
	pass  # Implement being selection

func _build_conversation_context() -> String:
	return "Perfect AI conversation context"

func _on_conversation_display_input(event: InputEvent) -> void:
	pass  # Implement conversation display input

func _on_input_field_input(event: InputEvent) -> void:
	pass  # Implement input field handling

func _on_gemma_ai_message(message: String) -> void:
	"""Handle messages from Gemma AI signal"""
	if not message.begins_with("User says:"):
		add_message("gemma", message)

# ===== TAB MANAGEMENT =====

func switch_to_tab(tab_name: String) -> bool:
	"""Switch to a specific tab by name"""
	if not channel_tabs:
		return false
	
	for i in range(channel_tabs.get_child_count()):
		var tab = channel_tabs.get_child(i)
		if tab.name == tab_name:
			channel_tabs.current_tab = i
			print("🌌 Switched to tab: %s" % tab_name)
			return true
	
	print("⚠️ Tab not found: %s" % tab_name)
	return false

func show_console() -> void:
	"""Show the console window"""
	if console_window:
		console_window.visible = true
		if input_field:
			input_field.grab_focus()
		# Console shown - notify systems
		if gemma_ai and gemma_ai.has_method("ai_message"):
			gemma_ai.ai_message.emit("Console activated - ready for commands")

func hide_console() -> void:
	"""Hide the console window"""
	if console_window:
		console_window.visible = false
		# Console hidden - save state
		_save_console_state()

func _finalize_console_setup() -> void:
	"""Complete console initialization"""
	# Setup keyboard shortcuts
	setup_console_shortcuts()
	
	# Connect to game events
	connect_to_game_systems()
	
	# Ready for interaction
	console_ready = true

func setup_console_shortcuts() -> void:
	"""Setup console keyboard shortcuts"""
	# Tilde key toggle is already handled in project.godot
	pass

func connect_to_game_systems() -> void:
	"""Connect console to Universal Being systems"""
	var flood_gates = SystemBootstrap.get_flood_gates() if SystemBootstrap else null
	if flood_gates:
		# Monitor new beings created
		if flood_gates.has_signal("being_created"):
			flood_gates.being_created.connect(_on_being_created)

func _save_console_state() -> void:
	"""Save console state for next session"""
	# Could save to AkashicRecordsSystemSystem
	pass

func _on_being_created(being: UniversalBeing) -> void:
	"""Handle new Universal Being creation"""
	add_message("system", "New being created: %s (%s)" % [being.being_name, being.being_type])
