# ==================================================
# UNIVERSAL BEING: ConsoleButterflyTreeFix
# TYPE: Console Enhancement
# PURPOSE: Adds butterfly and tree creation to console
# COMPONENTS: None (extends UniversalBeing
# SCENES: None (UI handled by base class)
# ==================================================

extends ConsoleBaseUniversalBeing
class_name ConsoleButterflyTreeFixUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var butterfly_colors: Dictionary = {
	"blue": Color.CYAN,
	"red": Color.RED,
	"yellow": Color.YELLOW,
	"purple": Color.PURPLE,
	"green": Color.GREEN
}

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	# Set Universal Being identity
	being_type = "console_butterfly_tree_fix"
	being_name = "Console Butterfly Tree Fix"
	consciousness_level = 2
	
	print("🌟 %s: Console Butterfly Tree Fix Init Complete" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	print("🌟 %s: Console Butterfly Tree Fix Ready Complete" % being_name)

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
	"""Execute a console command with butterfly and tree support"""
	var lower_command = command.to_lower()
	
	# Handle creation commands
	if lower_command.contains("create") or lower_command.contains("make"):
		if lower_command.contains("butterfly"):
			return create_butterfly_universal_being()
		elif lower_command.contains("tree"):
			return create_tree_universal_being()
	
	# Fall back to base command processing
	return super.execute_command(command)

func create_butterfly_universal_being() -> String:
	"""Create a butterfly being"""
	if not SystemBootstrap or not SystemBootstrap.is_system_ready():
		return "❌ System not ready for creation"
	
	# Create basic butterfly using Universal Being
	var butterfly = SystemBootstrap.create_universal_being()
	if not butterfly:
		return "❌ Failed to create butterfly"
	
	# Configure butterfly
	butterfly.name = "Butterfly Being"
	butterfly.set("being_name", "Blue Butterfly")
	butterfly.set("being_type", "butterfly")
	butterfly.set("consciousness_level", 3)
	
	# Add visual representation
	var label = Label.new()
	label.text = "🦋"
	label.add_theme_font_size_override("font_size", 48)
	label.modulate = butterfly_colors["blue"]
	butterfly.add_child(label)
	
	# Add to scene
	if get_tree().current_scene:
		get_tree().current_scene.add_child(butterfly)
		butterfly.position = get_viewport().get_visible_rect().size / 2
		
		# Make it move
		var tween = butterfly.create_tween()
		tween.set_loops()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(butterfly, "position", 
			butterfly.position + Vector2(100, -50), 2.0)
		tween.tween_property(butterfly, "position",
			butterfly.position + Vector2(-100, 50), 2.0)
	
	# Register with systems
	if SystemBootstrap:
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("register_being"):
			flood_gates.register_being(butterfly)
	
	# Notify Gemma
	if GemmaAI:
		GemmaAI.ai_message.emit("🦋 A beautiful butterfly has emerged into being!")
	
	return "✅ Beautiful blue butterfly created!\n🦋 It flutters with consciousness level 3"

func create_tree_universal_being() -> String:
	"""Create a tree being"""
	if not SystemBootstrap or not SystemBootstrap.is_system_ready():
		return "❌ System not ready for creation"
	
	# Try to load TreeUniversalBeing
	var TreeClass = load("res://beings/TreeUniversalBeing.gd")
	if not TreeClass:
		return create_basic_tree()
	
	# Create proper tree
	var tree = TreeClass.new()
	if get_tree().current_scene:
		get_tree().current_scene.add_child(tree)
		tree.position = Vector2(get_viewport().get_visible_rect().size.x / 2, 
			get_viewport().get_visible_rect().size.y - 100)
	
	# Register with systems
	if SystemBootstrap:
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates and flood_gates.has_method("register_being"):
			flood_gates.register_being(tree)
	
	# Notify Gemma
	if GemmaAI:
		GemmaAI.ai_message.emit("🌳 A sacred tree has taken root in our world!")
	
	return "✅ Sacred Tree planted!\n🌳 Watch it grow with consciousness level 2"

func create_basic_tree() -> String:
	"""Create a basic tree as fallback"""
	var tree = SystemBootstrap.create_universal_being()
	if not tree:
		return "❌ Failed to create basic tree"
	
	tree.name = "Tree Being"
	tree.set("being_type", "tree")
	tree.set("consciousness_level", 2)
	
	# Simple tree visual
	var trunk = ColorRect.new()
	trunk.color = Color(0.4, 0.3, 0.2)
	trunk.size = Vector2(20, 80)
	trunk.position = Vector2(-10, -80)
	tree.add_child(trunk)
	
	var leaves = Label.new()
	leaves.text = "🌳"
	leaves.add_theme_font_size_override("font_size", 64)
	leaves.position = Vector2(-32, -120)
	tree.add_child(leaves)
	
	if get_tree().current_scene:
		get_tree().current_scene.add_child(tree)
		tree.position = Vector2(get_viewport().get_visible_rect().size.x / 2, 
			get_viewport().get_visible_rect().size.y - 50)
	
	return "✅ Basic tree created!"

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	var base_interface = super.ai_interface()
	base_interface.ai_commands = ["create_butterfly", "create_tree"]
	base_interface.ai_properties = {
		"butterfly_colors": butterfly_colors.keys()
	}
	return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		"create_butterfly":
			return create_butterfly_universal_being()
		"create_tree":
			return create_tree_universal_being()
		_:
			return super.ai_invoke_method(method_name, args)
