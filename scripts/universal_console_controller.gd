# ==================================================
# SCRIPT: Universal Console Controller
# PURPOSE: Animated console with AI-powered command system
# CREATED: Based on Cursor's enhancement suggestions
# ==================================================

extends Control
class_name UniversalConsoleController

# ===== CONSOLE PROPERTIES =====
@export var console_visible: bool = false : set = set_console_visible
@export var auto_scroll: bool = true
@export var max_output_lines: int = 1000

# UI Components
@onready var console_panel: Panel = $ConsolePanel
@onready var output_label: RichTextLabel = $ConsolePanel/VBox/OutputContainer/OutputScroll/OutputLabel
@onready var input_field: LineEdit = $ConsolePanel/VBox/InputContainer/InputField
@onready var prompt_label: Label = $ConsolePanel/VBox/InputContainer/Prompt
@onready var close_button: Button = $ConsolePanel/VBox/Header/CloseButton
@onready var particle_bg: CPUParticles2D = $ConsolePanel/ParticleBackground
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Console State
var command_history: Array[String] = []
var history_index: int = -1
var output_lines: Array[String] = []
var console_commands: Dictionary = {}

# Animation State
var prompt_pulse_timer: float = 0.0
var is_processing_command: bool = false

func _ready() -> void:
	name = "UniversalConsole"
	setup_console()
	register_console_commands()
	
	# Connect signals
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	if input_field:
		input_field.text_submitted.connect(_on_input_field_text_submitted)
	
	# Start with console hidden
	set_console_visible(false)
	
	print("🖥️ Universal Console Controller initialized!")

func setup_console() -> void:
	"""Setup console visual properties"""
	if console_panel:
		console_panel.modulate = Color.TRANSPARENT
		# Make console semi-transparent so cursor is visible underneath
		console_panel.self_modulate = Color(1.0, 1.0, 1.0, 0.85)  # 85% opacity
	
	# Setup particle background
	if particle_bg:
		particle_bg.emitting = true
		animate_particles()
	
	# Setup input field
	if input_field:
		input_field.placeholder_text = "Enter command... (help for commands)"

func register_console_commands() -> void:
	"""Register available console commands"""
	console_commands = {
		"help": "Show available commands",
		"clear": "Clear console output", 
		"status": "Show system status",
		"beings": "List all Universal Beings",
		"create": "Create a new Universal Being",
		"ai": "Send message to AI systems",
		"pentagon": "Pentagon of Creation commands",
		"consciousness": "Consciousness level commands",
		"genesis": "Biblical genesis pattern commands",
		"cosmic": "Cosmic insight commands",
		"harmony": "AI harmony control",
		"exit": "Close console"
	}

func set_console_visible(visible: bool) -> void:
	"""Toggle console visibility with animation"""
	console_visible = visible
	
	if visible:
		show_console_animated()
	else:
		hide_console_animated()

func show_console_animated() -> void:
	"""Show console with smooth animation"""
	visible = true
	
	if console_panel:
		# Animate panel appearance
		var tween = create_tween()
		tween.parallel().tween_property(console_panel, "modulate", Color(1.0, 1.0, 1.0, 0.85), 0.3)
		tween.parallel().tween_property(console_panel, "scale", Vector2.ONE, 0.3)
		console_panel.scale = Vector2(0.8, 0.8)
	
	# Focus input field
	if input_field:
		input_field.grab_focus()
	
	# Start particle effects
	if particle_bg:
		particle_bg.emitting = true
	
	print_to_console("🖥️ Universal Console activated!", "system")

func hide_console_animated() -> void:
	"""Hide console with smooth animation"""
	if console_panel:
		var tween = create_tween()
		tween.parallel().tween_property(console_panel, "modulate", Color.TRANSPARENT, 0.2)
		tween.parallel().tween_property(console_panel, "scale", Vector2(0.8, 0.8), 0.2)
		tween.tween_callback(func(): visible = false)
	
	# Stop particle effects
	if particle_bg:
		particle_bg.emitting = false

func toggle_console() -> void:
	"""Toggle console visibility"""
	set_console_visible(not console_visible)

func _process(delta: float) -> void:
	"""Update console animations"""
	if not console_visible:
		return
	
	update_prompt_animation(delta)
	update_particle_animation(delta)

func update_prompt_animation(delta: float) -> void:
	"""Animate the prompt with pulsing effect"""
	if not prompt_label:
		return
	
	prompt_pulse_timer += delta * 3.0
	var pulse_intensity = sin(prompt_pulse_timer) * 0.3 + 0.7
	prompt_label.modulate = Color(0, 1, 1, pulse_intensity)

func update_particle_animation(delta: float) -> void:
	"""Update particle background effects"""
	if not particle_bg:
		return
	
	# Adjust particle intensity based on activity
	var base_amount = 50
	var activity_multiplier = 1.0
	if is_processing_command:
		activity_multiplier = 2.0
	
	particle_bg.amount = int(base_amount * activity_multiplier)

func animate_particles() -> void:
	"""Setup particle animation"""
	if not particle_bg:
		return
	
	# Create animated particle effects
	var tween = create_tween()
	tween.set_loops()
	tween.tween_method(
		func(value: float): 
			if particle_bg:
				particle_bg.color = Color(0, 1, 1, 0.2 + value * 0.2),
		0.0,
		1.0,
		2.0
	)
	tween.tween_method(
		func(value: float):
			if particle_bg:
				particle_bg.color = Color(0, 1, 1, 0.4 - value * 0.2),
		1.0,
		0.0,
		2.0
	)

# ===== INPUT HANDLING =====

func _on_input_field_text_submitted(text: String) -> void:
	"""Handle command input"""
	if text.strip_edges().is_empty():
		return
	
	var command = text.strip_edges()
	
	# Add to history
	command_history.append(command)
	history_index = command_history.size()
	
	# Show command in output
	print_to_console("🎮> " + command, "user")
	
	# Process command
	process_command(command)
	
	# Clear input
	input_field.text = ""

func _input(event: InputEvent) -> void:
	"""Handle console-specific input"""
	if not console_visible or not input_field or not input_field.has_focus():
		return
	
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP:
				navigate_history(-1)
			KEY_DOWN:
				navigate_history(1)
			KEY_ESCAPE:
				set_console_visible(false)

func navigate_history(direction: int) -> void:
	"""Navigate command history"""
	if command_history.is_empty():
		return
	
	history_index = clamp(history_index + direction, -1, command_history.size() - 1)
	
	if history_index >= 0:
		input_field.text = command_history[history_index]
		input_field.caret_column = input_field.text.length()
	else:
		input_field.text = ""

# ===== COMMAND PROCESSING =====

func process_command(command: String) -> void:
	"""Process console command"""
	is_processing_command = true
	
	var parts = command.split(" ", false)
	if parts.is_empty():
		return
	
	var cmd = parts[0].to_lower()
	var args = parts.slice(1)
	
	match cmd:
		"help":
			show_help()
		"clear":
			clear_console()
		"status":
			show_system_status()
		"beings":
			list_universal_beings()
		"create":
			create_universal_being_command(args)
		"ai":
			send_ai_message(args)
		"pentagon":
			pentagon_command(args)
		"consciousness":
			consciousness_command(args)
		"genesis":
			genesis_command(args)
		"cosmic":
			cosmic_command(args)
		"harmony":
			harmony_command(args)
		"exit":
			set_console_visible(false)
		_:
			print_to_console("❌ Unknown command: " + cmd + " (type 'help' for commands)", "error")
	
	is_processing_command = false

func show_help() -> void:
	"""Show available commands"""
	print_to_console("🖥️ Universal Console Commands:", "system")
	for cmd in console_commands.keys():
		print_to_console("  %s - %s" % [cmd, console_commands[cmd]], "ai")

func clear_console() -> void:
	"""Clear console output"""
	output_lines.clear()
	if output_label:
		output_label.text = ""
	print_to_console("🖥️ Console cleared", "system")

func show_system_status() -> void:
	"""Show Universal Being system status"""
	print_to_console("🌟 Universal Being Engine Status:", "system")
	
	# Get main scene
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("get_status_info"):
		var status = main_scene.get_status_info()
		print_to_console("  Systems Ready: %s" % status.get("systems_ready", false), "ai")
		print_to_console("  Beings Count: %d" % status.get("demo_beings_count", 0), "ai")
		print_to_console("  Bootstrap Ready: %s" % status.get("bootstrap_ready", false), "ai")
		print_to_console("  AI Ready: %s" % status.get("ai_ready", false), "ai")
	
	# Check for Pentagon of Creation
	var pentagon_status = get_pentagon_status()
	print_to_console("  Pentagon of Creation: %s" % pentagon_status, "ai")

func list_universal_beings() -> void:
	"""List all Universal Beings in the scene"""
	print_to_console("🎭 Universal Beings:", "system")
	
	var main_scene = get_tree().current_scene
	var beings = find_all_universal_beings(main_scene)
	
	if beings.is_empty():
		print_to_console("  No Universal Beings found", "ai")
	else:
		for being in beings:
			var being_name = being.get("being_name") if being.has_method("get") else being.name
			var being_type = being.get("being_type") if being.has_method("get") else "unknown"
			var consciousness = being.get("consciousness_level") if being.has_method("get") else 0
			print_to_console("  • %s (%s) - Consciousness: %d" % [being_name, being_type, consciousness], "ai")

func create_universal_being_command(args: Array) -> void:
	"""Create a new Universal Being"""
	var being_type = "test"
	if args.size() > 0:
		being_type = args[0]
	
	print_to_console("🌟 Creating Universal Being of type: %s" % being_type, "system")
	
	# Try to create through main scene
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("create_test_being"):
		main_scene.create_test_being()
		print_to_console("✅ Universal Being created successfully!", "ai")
	else:
		print_to_console("❌ Cannot create Universal Being - main scene not available", "error")

func send_ai_message(args: Array) -> void:
	"""Send message to AI systems"""
	if args.is_empty():
		print_to_console("❌ Usage: ai <message>", "error")
		return
	
	var message = " ".join(args)
	print_to_console("🤖 Sending to AI: %s" % message, "system")
	
	# Send to Gemma AI if available
	if GemmaAI and GemmaAI.has_method("process_user_input"):
		print_to_console("🤖 Gemma AI is listening...", "ai")
		# Process the input and wait for response
		GemmaAI.process_user_input(message)
		
		# Connect to ai_message signal to receive response
		if not GemmaAI.ai_message.is_connected(_on_ai_response):
			GemmaAI.ai_message.connect(_on_ai_response)
		
		print_to_console("✅ Message sent to Gemma AI", "ai")
	elif GemmaAI:
		print_to_console("❌ Gemma AI process_user_input method not available", "error")
	else:
		print_to_console("❌ Gemma AI not available", "error")

func pentagon_command(args: Array) -> void:
	"""Pentagon of Creation commands"""
	if args.is_empty():
		print_to_console("🎭 Pentagon Commands: status, activate, harmony, symphony", "system")
		return
	
	var sub_cmd = args[0].to_lower()
	match sub_cmd:
		"status":
			var status = get_pentagon_status()
			print_to_console("🎭 Pentagon Status: %s" % status, "ai")
		"activate":
			print_to_console("🎭 Activating Pentagon of Creation...", "system")
			activate_pentagon()
		_:
			print_to_console("❌ Unknown pentagon command: %s" % sub_cmd, "error")

func consciousness_command(args: Array) -> void:
	"""Consciousness level commands"""
	print_to_console("🧠 Consciousness commands not yet implemented", "system")

func genesis_command(args: Array) -> void:
	"""Biblical genesis pattern commands"""
	print_to_console("📜 Genesis pattern commands not yet implemented", "system")

func cosmic_command(args: Array) -> void:
	"""Cosmic insight commands"""
	print_to_console("🔮 Cosmic insight commands not yet implemented", "system")

func harmony_command(args: Array) -> void:
	"""AI harmony control commands"""
	print_to_console("🎵 AI harmony commands not yet implemented", "system")

# ===== OUTPUT METHODS =====

func print_to_console(text: String, msg_type: String = "system") -> void:
	"""Print message to console with color coding"""
	var color = get_message_color(msg_type)
	var formatted_text = "[color=#%s]%s[/color]" % [color.to_html(), text]
	
	output_lines.append(formatted_text)
	
	# Limit output lines
	while output_lines.size() > max_output_lines:
		output_lines.pop_front()
	
	# Update output label
	if output_label:
		output_label.text = "\n".join(output_lines)
		
		# Auto-scroll to bottom
		if auto_scroll:
			call_deferred("scroll_to_bottom")

func get_message_color(msg_type: String) -> Color:
	"""Get color for message type"""
	match msg_type:
		"system": return Color(0.4, 0.8, 1.0)  # Light blue
		"ai": return Color(0.0, 1.0, 1.0)      # Cyan
		"user": return Color(1.0, 1.0, 1.0)    # White
		"error": return Color(1.0, 0.3, 0.3)   # Red
		"success": return Color(0.3, 1.0, 0.3) # Green
		_: return Color.WHITE

func scroll_to_bottom() -> void:
	"""Scroll output to bottom"""
	if output_label and output_label.get_parent() is ScrollContainer:
		var scroll_container = output_label.get_parent() as ScrollContainer
		scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

# ===== UTILITY METHODS =====

func find_all_universal_beings(node: Node) -> Array[Node]:
	"""Find all Universal Beings in the scene tree"""
	var beings: Array[Node] = []
	_collect_beings_recursive(node, beings)
	return beings

func _collect_beings_recursive(node: Node, result: Array[Node]) -> void:
	"""Recursively collect Universal Beings"""
	if node.has_method("get") and node.get("being_type") != "":
		result.append(node)
	
	for child in node.get_children():
		_collect_beings_recursive(child, result)

func get_pentagon_status() -> String:
	"""Get Pentagon of Creation status"""
	var main_scene = get_tree().current_scene
	var beings = find_all_universal_beings(main_scene)
	
	var ai_bridges = 0
	var genesis_conductor = null
	
	for being in beings:
		if being.has_method("get"):
			var being_type = being.get("being_type")
			if being_type in ["mcp_bridge", "ai_bridge_chatgpt", "ai_bridge_gemini"]:
				ai_bridges += 1
			elif being_type == "consciousness_conductor":
				genesis_conductor = being
	
	if genesis_conductor:
		return "%d/6 AI bridges, Genesis Conductor active" % (ai_bridges + 3)  # +3 for Gemma, Claude Code, Cursor
	else:
		return "%d/6 AI bridges, no Genesis Conductor" % (ai_bridges + 3)

func activate_pentagon() -> void:
	"""Activate Pentagon of Creation"""
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("toggle_pentagon_ai_mode"):
		main_scene.toggle_pentagon_ai_mode()
		print_to_console("✅ Pentagon of Creation activation initiated!", "success")
	else:
		print_to_console("❌ Cannot activate Pentagon - main scene not available", "error")

# ===== SIGNAL HANDLERS =====

func _on_ai_response(response: String) -> void:
	"""Handle AI response"""
	print_to_console(response, "ai")

func _on_close_button_pressed() -> void:
	"""Handle close button press"""
	set_console_visible(false)
