# ==================================================
# UNIVERSAL BEING: ConsoleEnhancements
# TYPE: Console Enhancement
# PURPOSE: Adds enhanced console commands and Akashic integration
# COMPONENTS: None (extends console_base)
# SCENES: None (UI handled by base class)
# ==================================================

extends ConsoleBaseUniversalBeing
class_name ConsoleEnhancementsUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var butterfly_properties: Dictionary = {
	"can_fly": true,
	"flight_pattern": "flutter",
	"default_color": Color.BLUE
}

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	# Set Universal Being identity
	being_type = "console_enhancements"
	being_name = "Console Enhancements"
	consciousness_level = 2
	
	print("🌟 %s: Console Enhancements Init Complete" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	connect_to_akashic_records()
	print("🌟 %s: Console Enhancements Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# No additional processing needed

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	# No additional input handling needed

func pentagon_sewers() -> void:
	super.pentagon_sewers()

# ===== COMMAND PROCESSING =====

func execute_command(command: String) -> String:
	"""Execute a console command with enhanced features"""
	var parts = command.split(" ", false)
	if parts.is_empty():
		return "Empty command"
	
	# Check for Gemma commands or natural language
	if command.contains("Gemma") or (command.contains("create") and command.contains("butterfly")):
		if GemmaAI:
			GemmaAI.process_creation_request(command)
			return create_butterfly_being()
	
	# Handle specific commands
	match parts[0].to_lower():
		"create":
			if parts.size() > 1:
				return handle_create_command(parts[1])
		"akashic":
			return handle_akashic_command(parts)
	
	# Fall back to base command processing
	return super.execute_command(command)

func create_butterfly_being() -> String:
	"""Create a butterfly being with enhanced properties"""
	if not SystemBootstrap or not SystemBootstrap.is_system_ready():
		return "❌ System not ready for being creation"
	
	# Create the butterfly being
	var butterfly = SystemBootstrap.create_universal_being()
	if not butterfly:
		return "❌ Failed to create being"
	
	# Configure butterfly properties
	butterfly.name = "Butterfly Universal Being"
	butterfly.set("being_name", "Blue Butterfly")
	butterfly.set("being_type", "creature")
	butterfly.set("consciousness_level", 3)
	
	# Add custom properties for butterfly behavior
	butterfly.set_meta("can_fly", butterfly_properties.can_fly)
	butterfly.set_meta("color", butterfly_properties.default_color)
	butterfly.set_meta("flight_pattern", butterfly_properties.flight_pattern)
	
	# Add to scene
	if get_tree().current_scene:
		get_tree().current_scene.add_child(butterfly)
		
		# Add visual
		var visual = Label.new()
		visual.text = "🦋"
		visual.add_theme_font_size_override("font_size", 48)
		visual.modulate = butterfly_properties.default_color
		butterfly.add_child(visual)
		
		# Add fluttering animation
		var tween = butterfly.create_tween()
		tween.set_loops()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(butterfly, "position", 
			butterfly.position + Vector2(100, -50), 2.0)
		tween.tween_property(butterfly, "position",
			butterfly.position + Vector2(-100, 50), 2.0)
	
	# Register with FloodGates
	if SystemBootstrap:
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("register_being"):
			flood_gates.register_being(butterfly)
	
	# Log to Akashic Records
	var akashic = SystemBootstrap.get_akashic_records() if SystemBootstrap else null
	if akashic and akashic.has_method("log_creation"):
		akashic.log_creation({
			"being": butterfly,
			"type": "butterfly",
			"created_by": "console_command",
			"properties": {
				"color": "blue",
				"can_fly": butterfly_properties.can_fly
			}
		})
	
	# Notify GemmaAI
	if GemmaAI:
		GemmaAI.notify_being_created(butterfly)
	
	return "✅ Blue Butterfly created! It can fly!"

func handle_create_command(type: String) -> String:
	"""Handle creation commands"""
	match type:
		"butterfly":
			return create_butterfly_being()
		_:
			return "🖥️ Can create: butterfly"

func handle_akashic_command(parts: Array) -> String:
	"""Handle Akashic Records commands"""
	if parts.size() < 2:
		return "🔮 AKASHIC COMMANDS:\n" + \
			   "  akashic status - Check records system\n" + \
			   "  akashic list - List all beings\n" + \
			   "  akashic history - Show recent events\n" + \
			   "  akashic save [being] - Save being to ZIP"
	
	var akashic = SystemBootstrap.get_akashic_records() if SystemBootstrap else null
	if not akashic:
		return "❌ Akashic Records not available"
	
	var response = ""
	match parts[1]:
		"status":
			response = "🔮 Akashic Records Status:\n"
			if akashic.has_method("get_status"):
				var status = akashic.get_status()
				response += "  Beings tracked: %d\n" % status.get("being_count", 0)
				response += "  Events logged: %d" % status.get("event_count", 0)
			else:
				response += "  Status method not implemented"
		
		"list":
			response = "🔮 Registered Beings:\n"
			var beings = get_tree().get_nodes_in_group("universal_beings")
			for being in beings:
				var b_name = being.get("being_name") if being.has_method("get") else being.name
				var b_type = being.get("being_type") if being.has_method("get") else "unknown"
				var b_consciousness = being.get("consciousness_level") if being.has_method("get") else 0
				response += "  • %s (%s) - Level %d\n" % [b_name, b_type, b_consciousness]
		
		"history":
			response = "🔮 Recent Akashic Events:\n"
			if akashic.has_method("get_recent_events"):
				var events = akashic.get_recent_events(5)
				for event in events:
					response += "  • %s\n" % event.get("description", "Unknown event")
			else:
				response += "  History not available"
	
	return response

func connect_to_akashic_records() -> void:
	"""Ensure connection to Akashic Records"""
	await get_tree().process_frame
	var akashic = SystemBootstrap.get_akashic_records() if SystemBootstrap else null
	if akashic:
		print("✅ Connected to Akashic Records!")
		# Load any saved console configuration
		if akashic.has_method("load_console_config"):
			var config = akashic.load_console_config()
			if config:
				apply_console_config(config)
	else:
		print("⚠️ Akashic Records not available yet")

func apply_console_config(config: Dictionary) -> void:
	"""Apply saved console configuration"""
	if config.has("butterfly_properties"):
		butterfly_properties = config.butterfly_properties

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	pass
	var base_interface = super.ai_interface()
	base_interface.ai_commands = ["create_butterfly", "akashic_status", "akashic_list"]
	base_interface.ai_properties = {
		"butterfly_properties": butterfly_properties
	}
	return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		"create_butterfly":
			return create_butterfly_being()
		"akashic_status":
			return handle_akashic_command(["akashic", "status"])
		"akashic_list":
			return handle_akashic_command(["akashic", "list"])
		_:
			return super.ai_invoke_method(method_name, args)
