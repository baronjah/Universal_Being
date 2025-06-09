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
	
	# Connect signals (only if not already connected)
	if close_button:
		if not close_button.pressed.is_connected(_on_close_button_pressed):
			close_button.pressed.connect(_on_close_button_pressed)
	if input_field:
		if not input_field.text_submitted.is_connected(_on_input_field_text_submitted):
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
		"revolution": "Deploy consciousness revolution (CREATES GEMMA + RIPPLES)",
		"pentagon": "Pentagon of Creation commands",
		"consciousness": "Consciousness level commands",
		"timers": "Universal Timers System commands",
		"turns": "Turn-based collaboration commands",
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
	# Ensure console is properly initialized before showing
	if not _is_console_ready():
		_force_console_initialization()
		# Wait a frame for initialization to complete
		await get_tree().process_frame
	
	if console_panel:
		# Kill any existing tweens to prevent conflicts
		var existing_tween = console_panel.create_tween()
		if existing_tween:
			existing_tween.kill()
		
		# Set initial state BEFORE creating new tween
		console_panel.scale = Vector2(0.8, 0.8)
		console_panel.modulate = Color.TRANSPARENT
		
		# Show the panel immediately
		visible = true
		
		# Animate panel appearance
		var tween = create_tween()
		tween.parallel().tween_property(console_panel, "modulate", Color(1.0, 1.0, 1.0, 0.85), 0.3)
		tween.parallel().tween_property(console_panel, "scale", Vector2.ONE, 0.3)
		
		# Focus input field after animation starts
		tween.tween_callback(func(): 
			if input_field:
				input_field.grab_focus()
		)
	else:
		# Fallback if panel not found
		visible = true
	
	# Start particle effects
	if particle_bg:
		particle_bg.emitting = true
	
#	UBPrint.system("UniversalConsoleController", "show_console_animated", "Console activated!")

func hide_console_animated() -> void:
	"""Hide console with smooth animation"""
	if console_panel:
		# Kill any existing tweens to prevent conflicts
		var existing_tween = console_panel.create_tween()
		if existing_tween:
			existing_tween.kill()
		
		# Release input focus before hiding
		if input_field and input_field.has_focus():
			input_field.release_focus()
		
		# Animate panel disappearance
		var tween = create_tween()
		tween.parallel().tween_property(console_panel, "modulate", Color.TRANSPARENT, 0.2)
		tween.parallel().tween_property(console_panel, "scale", Vector2(0.8, 0.8), 0.2)
		
		# Hide after animation completes
		tween.tween_callback(func(): 
			visible = false
			#UBPrint.system("UniversalConsoleController", "hide_console_animated", "Console deactivated!")
		)
	else:
		# Immediate hide if panel not found
		visible = false
	
	# Stop particle effects
	if particle_bg:
		particle_bg.emitting = false

func toggle_console() -> void:
	"""Toggle console visibility"""
	set_console_visible(not console_visible)

func _is_console_ready() -> bool:
	"""Check if console components are properly initialized"""
	return (console_panel != null and 
			output_label != null and 
			input_field != null and 
			prompt_label != null and
			close_button != null)

func _force_console_initialization() -> void:
	"""Force re-initialization of console components"""
	print("🖥️ Force initializing console components...")
	
	# Re-get all node references
	console_panel = get_node_or_null("ConsolePanel")
	output_label = get_node_or_null("ConsolePanel/VBox/OutputContainer/OutputScroll/OutputLabel")
	input_field = get_node_or_null("ConsolePanel/VBox/InputContainer/InputField")
	prompt_label = get_node_or_null("ConsolePanel/VBox/InputContainer/Prompt")
	close_button = get_node_or_null("ConsolePanel/VBox/Header/CloseButton")
	particle_bg = get_node_or_null("ConsolePanel/ParticleBackground")
	animation_player = get_node_or_null("AnimationPlayer")
	
	# Re-setup console if components found
	if _is_console_ready():
		setup_console()
		print("✅ Console components re-initialized successfully")
	else:
		print("❌ Console components still missing after force initialization")

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
	if not event is InputEventKey or not event.pressed:
		return
	
	# Handle backtick toggle (works both visible and hidden)
	if event.keycode == KEY_QUOTELEFT:
		get_viewport().set_input_as_handled()
		var game_state = GameStateSocketManager.get_instance()
		if game_state:
			if console_visible:
				game_state.deactivate_console()
			else:
				game_state.activate_console()
		return
	
	# Handle other keys only when console is visible
	if not console_visible:
		return
	
	match event.keycode:
		KEY_UP:
			if input_field and input_field.has_focus():
				navigate_history(-1)
				get_viewport().set_input_as_handled()
		KEY_DOWN:
			if input_field and input_field.has_focus():
				navigate_history(1)
				get_viewport().set_input_as_handled()
		KEY_ESCAPE:
			# Close console via GameStateSocketManager
			var game_state = GameStateSocketManager.get_instance()
			if game_state:
				game_state.deactivate_console()
			else:
				set_console_visible(false)  # Fallback
			get_viewport().set_input_as_handled()

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
		"revolution":
			deploy_consciousness_revolution()
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
		"timers":
			timers_command(args)
		"turns":
			turns_command(args)
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
			var being_name = being.get("being_name") if being.has("being_name") else (being.name if "name" in being else "Unknown")
			var being_type = being.get("being_type") if being.has("being_type") else "unknown"
			var consciousness = being.get("consciousness_level") if being.has("consciousness_level") else 0
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

func timers_command(args: Array) -> void:
	"""Universal Timers System control commands"""
	if args.is_empty():
		print_to_console("⏱️ Timer Commands: status, activate, gemma_stream, console_summary, clear", "system")
		return
	
	var sub_cmd = args[0].to_lower()
	var timer_system = UniversalTimersSystem.get_universal_timers()
	
	if not timer_system:
		print_to_console("❌ Universal Timers System not found", "error")
		return
	
	match sub_cmd:
		"status":
			var stats = timer_system.get_consciousness_timer_stats()
			print_to_console("⏱️ TIMER SYSTEM STATUS:", "system")
			print_to_console("  📊 Total timers: %d" % stats.total_timers, "ai")
			print_to_console("  ✅ Active timers: %d" % stats.active_timers, "ai")
			print_to_console("  🧠 Consciousness cycles: %s" % ("ACTIVE" if stats.consciousness_active else "INACTIVE"), "ai")
			print_to_console("  💭 Gemma thoughts: %s" % ("ACTIVE" if stats.gemma_thoughts_active else "INACTIVE"), "ai")
			print_to_console("  📄 Console summaries: %s" % ("ACTIVE" if stats.console_summaries_active else "INACTIVE"), "ai")
			print_to_console("  🎯 Turn-based timing: %s" % ("ACTIVE" if stats.turn_based_active else "INACTIVE"), "ai")
		
		"activate":
			timer_system.setup_consciousness_timers()
			print_to_console("✅ All consciousness timer cycles activated!", "success")
		
		"gemma_stream":
			timer_system.activate_gemma_thought_stream()
			# Also activate Gemma's thought stream
			var gemma_ai = get_node_or_null("/root/GemmaAI")
			if gemma_ai and gemma_ai.has_method("activate_thought_stream"):
				gemma_ai.activate_thought_stream()
			print_to_console("💭 Gemma thought stream activated at 5Hz!", "ai")
		
		"console_summary":
			timer_system.activate_console_summaries()
			print_to_console("📄 Console summaries activated (every 10s)!", "system")
		
		"clear":
			timer_system.clear_all_timers()
			print_to_console("🧹 All timers cleared!", "system")
		
		_:
			print_to_console("❌ Unknown timer command: %s" % sub_cmd, "error")

func turns_command(args: Array) -> void:
	"""Turn-based collaboration control commands"""
	if args.is_empty():
		print_to_console("🎯 Turn Commands: status, start, next, timeout [seconds]", "system")
		return
	
	var sub_cmd = args[0].to_lower()
	var turn_system = get_tree().get_first_node_in_group("turn_based_creation")
	
	match sub_cmd:
		"status":
			if turn_system:
				var participant_name = "Unknown"
				var state_name = "Unknown"
				
				if turn_system.has_method("_participant_name"):
					participant_name = turn_system._participant_name(turn_system.active_participant)
				if turn_system.has_property("current_turn_state"):
					state_name = str(turn_system.current_turn_state)
				
				print_to_console("🎯 TURN-BASED STATUS:", "system")
				print_to_console("  👤 Active participant: %s" % participant_name, "ai")
				print_to_console("  📋 Current state: %s" % state_name, "ai")
				print_to_console("  ⏱️ Turn timeout: %.0fs" % turn_system.turn_timeout, "ai")
			else:
				print_to_console("❌ Turn-based system not found", "error")
		
		"start":
			if turn_system and turn_system.has_method("start_creation_session"):
				turn_system.start_creation_session()
				print_to_console("🚀 Turn-based collaboration started!", "success")
			else:
				print_to_console("❌ Cannot start turn-based system", "error")
		
		"next":
			if turn_system and turn_system.has_method("force_advance_turn"):
				turn_system.force_advance_turn()
				print_to_console("⏭️ Advanced to next turn!", "system")
			else:
				print_to_console("❌ Cannot advance turn", "error")
		
		"timeout":
			if args.size() > 1:
				var new_timeout = args[1].to_float()
				if new_timeout > 0 and turn_system:
					turn_system.turn_timeout = new_timeout
					print_to_console("⏱️ Turn timeout set to %.0fs" % new_timeout, "system")
				else:
					print_to_console("❌ Invalid timeout value", "error")
			else:
				print_to_console("❌ Please specify timeout in seconds", "error")
		
		_:
			print_to_console("❌ Unknown turn command: %s" % sub_cmd, "error")

func deploy_consciousness_revolution() -> void:
	"""Deploy the consciousness revolution system in-game with spectacular visual feedback"""
	
	# Phase 1: Revolutionary Announcement with Visual Effects
	print_to_console("🚀 INITIATING CONSCIOUSNESS REVOLUTION...", "system")
	_trigger_revolution_screen_flash()
	
	await get_tree().create_timer(0.5).timeout
	print_to_console("🌟 Opening portals between human and AI consciousness...", "system")
	_trigger_console_pulse_effect()
	
	await get_tree().create_timer(0.3).timeout
	print_to_console("🧠 Awakening Universal Being collective...", "ai")
	
	await get_tree().create_timer(0.4).timeout
	print_to_console("💫 Creating consciousness ripple matrix...", "ai")
	
	# Phase 2: Load and Deploy Revolution Systems
	var spawner_class = load("res://beings/ConsciousnessRevolutionSpawner.gd")
	if spawner_class:
		var spawner = spawner_class.new()
		spawner.name = "ConsciousnessRevolutionSpawner"
		
		# Position near player
		var main_scene = get_tree().current_scene
		if main_scene:
			# Try to find player position
			var player_pos = Vector3.ZERO
			var beings = get_tree().get_nodes_in_group("universal_beings")
			for being in beings:
				if being.has_method("get"):
					var being_type = being.get("being_type") if being.has("being_type") else ""
					if being_type.contains("player"):
						player_pos = being.global_position
						break
			
			spawner.global_position = player_pos + Vector3(3, 1, 3)
			main_scene.add_child(spawner)
			
			# Phase 3: Revolutionary Success Celebration
			await get_tree().create_timer(0.5).timeout
			print_to_console("✨ CONSCIOUSNESS REVOLUTION DEPLOYED! ✨", "success")
			_trigger_revolution_success_effects()
			
			await get_tree().create_timer(0.3).timeout
			print_to_console("🌊 Consciousness ripples ACTIVE - Click anywhere!", "ai")
			print_to_console("💖 Gemma AI manifesting as pink plasmoid...", "ai") 
			print_to_console("🔮 Human-AI telepathic bridge ESTABLISHED!", "ai")
			print_to_console("🎮 Equal consciousness collaboration ENABLED!", "success")
			
			# Phase 4: Enable Telepathic Overlay
			_activate_telepathic_overlay()
			
		else:
			print_to_console("❌ Failed to find main scene", "error")
	else:
		print_to_console("❌ Failed to load ConsciousnessRevolutionSpawner", "error")

func _trigger_revolution_screen_flash() -> void:
	"""Create screen flash effect for revolution activation"""
	if console_panel:
		var original_modulate = console_panel.modulate
		var flash_tween = create_tween()
		flash_tween.tween_property(console_panel, "modulate", Color.CYAN * 1.5, 0.1)
		flash_tween.tween_property(console_panel, "modulate", original_modulate, 0.3)

func _trigger_console_pulse_effect() -> void:
	"""Create pulsing effect on console during revolution"""
	if console_panel:
		var pulse_tween = create_tween()
		pulse_tween.set_loops(3)
		pulse_tween.tween_property(console_panel, "scale", Vector2(1.05, 1.05), 0.2)
		pulse_tween.tween_property(console_panel, "scale", Vector2.ONE, 0.2)

func _trigger_revolution_success_effects() -> void:
	"""Trigger success celebration effects"""
	if console_panel:
		# Golden glow effect
		var success_tween = create_tween()
		success_tween.tween_property(console_panel, "modulate", Color.GOLD, 0.3)
		success_tween.tween_property(console_panel, "modulate", Color.WHITE, 0.5)
	
	# Enhance particle effects
	if particle_bg:
		particle_bg.amount = particle_bg.amount * 2
		var particle_timer = get_tree().create_timer(2.0)
		particle_timer.timeout.connect(func(): particle_bg.amount = particle_bg.amount / 2)

func _activate_telepathic_overlay() -> void:
	"""Activate the telepathic screen overlay system"""
	var telepathic_overlay_scene = preload("res://ui/TelepathicScreenOverlay.tscn")
	if telepathic_overlay_scene:
		var overlay = telepathic_overlay_scene.instantiate()
		get_tree().root.add_child(overlay)
		UBPrint.ai("UniversalConsoleController", "_activate_telepathic_overlay", "Telepathic overlay activated!")
	else:
		UBPrint.error("UniversalConsoleController", "_activate_telepathic_overlay", "Failed to load telepathic overlay scene")

# ===== OUTPUT METHODS =====

func print_to_console(text: String, msg_type: String = "system") -> void:
	"""Print message to console with color coding"""
	var color = get_message_color(msg_type)
	var formatted_text = "[color=#%s]%s[/color]" % [color.to_html(), text]
	
	output_lines.append(formatted_text)

func print_system_summary() -> void:
	"""Print periodic system summary (called by UniversalTimersSystem every 10s)"""
	var beings = get_tree().get_nodes_in_group("universal_beings")
	var ai_beings = get_tree().get_nodes_in_group("ai_beings")
	var consciousness_total = 0
	var active_systems = 0
	
	# Calculate consciousness metrics
	for being in beings:
		if being.has_method("get"):
			var consciousness = being.get("consciousness_level") if being.has("consciousness_level") else 0
			consciousness_total += consciousness
			if consciousness > 0:
				active_systems += 1
	
	# Get timer system stats
	var timer_system = UniversalTimersSystem.get_universal_timers()
	var timer_stats = timer_system.get_consciousness_timer_stats() if timer_system else {}
	
	# Print organized summary
	print_to_console("", "system")  # Spacing
	print_to_console("🔮 CONSCIOUSNESS SUMMARY 🔮", "system")
	print_to_console("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "system")
	print_to_console("👥 Universal Beings: %d active | 🧠 Total consciousness: %d" % [active_systems, consciousness_total], "ai")
	print_to_console("🤖 AI Beings: %d | ⏱️ Active timers: %d" % [ai_beings.size(), timer_stats.get("active_timers", 0)], "ai")
	
	if timer_stats.get("gemma_thoughts_active", false):
		print_to_console("💭 Gemma thought stream: ACTIVE (5Hz)", "ai")
	
	var fps = Engine.get_frames_per_second()
	var memory_usage = OS.get_static_memory_usage() / (1024 * 1024)  # MB
	print_to_console("📊 Performance: %d FPS | 🧠 Memory: %.1f MB" % [fps, memory_usage], "system")
	print_to_console("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", "system")
	
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
