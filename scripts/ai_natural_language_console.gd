# ==================================================
# UNIVERSAL BEING: AINaturalLanguageConsole
# TYPE: Console
# PURPOSE: AI-enhanced natural language console
# COMPONENTS: None (extends console_base)
# SCENES: None (UI handled by base class)
# ==================================================

extends ConsoleBaseUniversalBeing
class_name AINaturalLanguageConsoleUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var ai_name: String = "Gemma"
@export var ai_color: Color = Color(0.5, 0.9, 1.0)
@export var ai_energy: float = 2.0

# Creation word patterns
var creation_words: Array[String] = ["create", "make", "spawn", "generate", "build"]

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	# Set Universal Being identity
	being_type = "ai_natural_language_console"
	being_name = ai_name
	consciousness_level = 3  # High consciousness for AI interaction
	
	print("🌟 %s: AI Natural Language Console Init Complete" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("🌟 %s: AI Natural Language Console Ready Complete" % being_name)

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
	"""Execute a console command with AI-enhanced natural language processing"""
	# Check if this looks like a creation request
	var is_creation_request = false
	for word in creation_words:
		if command.to_lower().contains(word):
			is_creation_request = true
			break
	
	if is_creation_request and GemmaAI:
		# Send to Gemma for interpretation
		terminal_output("🤖 Processing creation request with AI...")
		return interpret_creation_request(command)
	
	# Fall back to base command processing
	return super.execute_command(command)

func interpret_creation_request(command: String) -> String:
	"""AI interpretation of creation requests"""
	var lower_command = command.to_lower()
	
	# Check for butterfly variations
	if lower_command.contains("butterfly") or lower_command.contains("moth"):
		var color = parse_color_from_command(lower_command)
		return create_ai_butterfly(color)
	
	# Check for tree variations
	elif lower_command.contains("tree") or lower_command.contains("plant"):
		var tree_type = parse_tree_type(lower_command)
		return create_ai_tree(tree_type)
	
	# Check for other beings
	elif lower_command.contains("bird"):
		return create_ai_being("bird", Color.YELLOW)
	elif lower_command.contains("flower"):
		return create_ai_being("flower", Color.MAGENTA)
	elif lower_command.contains("star"):
		return create_ai_being("star", Color.WHITE)
	
	return "🤖 I can create: butterfly, tree, bird, flower, star\n" + \
		   "🤖 Try: 'create blue butterfly' or 'make a tall tree'"

func parse_color_from_command(command: String) -> Color:
	"""Extract color from natural language"""
	var colors = {
		"red": Color.RED,
		"blue": Color.BLUE,
		"green": Color.GREEN,
		"yellow": Color.YELLOW,
		"purple": Color.PURPLE,
		"pink": Color.PINK,
		"orange": Color.ORANGE,
		"cyan": Color.CYAN,
		"white": Color.WHITE,
		"black": Color.BLACK
	}
	
	for color_name in colors:
		if command.contains(color_name):
			return colors[color_name]
	
	return Color.CYAN  # Default

func parse_tree_type(command: String) -> String:
	"""Determine tree type from command"""
	if command.contains("oak"): return "oak"
	if command.contains("pine"): return "pine"
	if command.contains("willow"): return "willow"
	if command.contains("cherry"): return "cherry"
	return "sacred"  # Default

func create_ai_butterfly(color: Color) -> String:
	"""Create butterfly with AI-determined properties"""
	if not SystemBootstrap or not SystemBootstrap.is_system_ready():
		return "❌ System not ready for creation"
	
	var butterfly = SystemBootstrap.create_universal_being()
	if not butterfly:
		return "❌ Failed to create butterfly"
	
	butterfly.name = "AI Butterfly"
	butterfly.set("being_type", "butterfly")
	butterfly.set("consciousness_level", 3)
	
	# Visual
	var visual = Label.new()
	visual.text = "🦋"
	visual.add_theme_font_size_override("font_size", 48)
	visual.modulate = color
	butterfly.add_child(visual)
	
	# Add to scene with movement
	if get_tree().current_scene:
		get_tree().current_scene.add_child(butterfly)
		butterfly.position = get_viewport().get_visible_rect().size / 2
		
		# Fluttering animation
		var tween = butterfly.create_tween()
		tween.set_loops()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(butterfly, "position", 
			butterfly.position + Vector2(100, -50), 2.0)
		tween.tween_property(butterfly, "position",
			butterfly.position + Vector2(-100, 50), 2.0)
	
	var color_name = get_color_name(color)
	if GemmaAI:
		GemmaAI.ai_message.emit("🦋 Manifested a %s butterfly through AI understanding!" % color_name)
	
	return "✅ %s butterfly created!" % color_name

func create_ai_tree(tree_type: String) -> String:
	"""Create tree with specific type"""
	if not SystemBootstrap or not SystemBootstrap.is_system_ready():
		return "❌ System not ready for creation"
	
	var tree = SystemBootstrap.create_universal_being()
	if not tree:
		return "❌ Failed to create tree"
	
	tree.name = "%s Tree" % tree_type.capitalize()
	tree.set("being_type", "tree")
	tree.set("consciousness_level", 2)
	
	# Visual based on type
	var emoji = "🌳"
	match tree_type:
		"oak": emoji = "🌳"
		"pine": emoji = "🌲"
		"willow": emoji = "🌿"
		"cherry": emoji = "🌸"
	
	var visual = Label.new()
	visual.text = emoji
	visual.add_theme_font_size_override("font_size", 64)
	tree.add_child(visual)
	
	if get_tree().current_scene:
		get_tree().current_scene.add_child(tree)
		tree.position = Vector2(get_viewport().get_visible_rect().size.x / 2, 
			get_viewport().get_visible_rect().size.y - 100)
	
	return "✅ %s tree planted!" % tree_type.capitalize()

func create_ai_being(type: String, color: Color) -> String:
	"""Create generic AI-interpreted being"""
	if not SystemBootstrap or not SystemBootstrap.is_system_ready():
		return "❌ System not ready for creation"
	
	var emojis = {
		"bird": "🐦",
		"flower": "🌸",
		"star": "⭐"
	}
	
	var being = SystemBootstrap.create_universal_being()
	if not being:
		return "❌ Failed to create %s" % type
	
	being.name = "%s Being" % type.capitalize()
	being.set("being_type", type)
	being.set("consciousness_level", randi_range(1, 4))
	
	var visual = Label.new()
	visual.text = emojis.get(type, "✨")
	visual.add_theme_font_size_override("font_size", 48)
	visual.modulate = color
	being.add_child(visual)
	
	if get_tree().current_scene:
		get_tree().current_scene.add_child(being)
		being.position = get_viewport().get_visible_rect().size / 2 + \
			Vector2(randf_range(-200, 200), randf_range(-200, 200))
	
	return "✅ %s created!" % type.capitalize()

func get_color_name(color: Color) -> String:
	"""Get color name from Color value"""
	if color.is_equal_approx(Color.RED): return "red"
	if color.is_equal_approx(Color.BLUE): return "blue"
	if color.is_equal_approx(Color.GREEN): return "green"
	if color.is_equal_approx(Color.YELLOW): return "yellow"
	if color.is_equal_approx(Color.PURPLE): return "purple"
	if color.is_equal_approx(Color.CYAN): return "cyan"
	return "colorful"

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	pass
	var base_interface = super.ai_interface()
	base_interface.ai_commands = ["create", "interpret", "get_color"]
	base_interface.ai_properties = {
		"name": ai_name,
		"color": ai_color,
		"energy": ai_energy,
		"creation_words": creation_words
	}
	return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		"create":
			if args.size() > 0:
				return interpret_creation_request(args[0])
			return "No creation command specified"
		"interpret":
			if args.size() > 0:
				return interpret_creation_request(args[0])
			return "No command to interpret"
		"get_color":
			if args.size() > 0:
				return parse_color_from_command(args[0])
			return Color.WHITE
		_:
			return super.ai_invoke_method(method_name, args)
