# ==================================================
# UNIVERSAL BEING: GemmaNaturalLanguage
# TYPE: Console
# PURPOSE: Natural language console with Gemma AI integration
# COMPONENTS: None (extends console_base)
# SCENES: None (UI handled by base class)
# ==================================================

extends ConsoleBaseUniversalBeing
class_name GemmaNaturalLanguageUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var gemma_name: String = "Gemma"
@export var gemma_color: Color = Color(0.5, 0.9, 1.0)
@export var gemma_energy: float = 2.0

# Gemma state
var gemma_body: Node3D
var gemma_target: Node3D
var gemma_is_moving: bool = false

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	# Set Universal Being identity
	being_type = "gemma_natural_language"
	being_name = gemma_name
	consciousness_level = 3  # High consciousness for AI interaction
	
	print("🌟 %s: Gemma Natural Language Init Complete" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Setup Gemma's physical form
	setup_gemma_integration()
	
	print("🌟 %s: Gemma Natural Language Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update Gemma's movement
	if gemma_is_moving and gemma_body and gemma_target:
		update_gemma_movement(delta)

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Additional Gemma-specific input handling
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_G:  # Toggle Gemma visibility
			toggle_gemma_visibility()

func pentagon_sewers() -> void:
	# Cleanup Gemma's physical form
	if gemma_body:
		gemma_body.queue_free()
	
	super.pentagon_sewers()

# ===== GEMMA-SPECIFIC METHODS =====

func setup_gemma_integration() -> void:
	"""Setup Gemma's embodiment and natural language"""
	create_gemma_body()
	terminal_output("🤖 Gemma embodiment system ready!")

func create_gemma_body() -> void:
	"""Create Gemma's physical form in the world"""
	gemma_body = Node3D.new()
	gemma_body.name = "GemmaAI_Body"
	
	# Visual representation
	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.5
	mesh.mesh = sphere
	
	# Glowing material
	var mat = StandardMaterial3D.new()
	mat.albedo_color = gemma_color
	mat.emission_enabled = true
	mat.emission = gemma_color
	mat.emission_energy = gemma_energy
	mesh.material_override = mat
	
	gemma_body.add_child(mesh)
	
	# Add to scene
	if get_tree().current_scene:
		get_tree().current_scene.add_child(gemma_body)
		gemma_body.position = Vector3(0, 2, 5)
	
	terminal_output("🤖 Gemma manifested! I can now move and see.")

func update_gemma_movement(delta: float) -> void:
	"""Update Gemma's movement towards target"""
	if not gemma_body or not gemma_target:
		gemma_is_moving = false
		return
	
	var direction = (gemma_target.position - gemma_body.position).normalized()
	var distance = gemma_body.position.distance_to(gemma_target.position)
	
	if distance > 0.1:
		gemma_body.position += direction * delta * 2.0
	else:
		gemma_is_moving = false
		terminal_output("🤖 Arrived at destination")

func toggle_gemma_visibility() -> void:
	"""Toggle Gemma's visibility"""
	if gemma_body:
		gemma_body.visible = !gemma_body.visible
		terminal_output("🤖 " + ("Now visible" if gemma_body.visible else "Now hidden"))

# ===== COMMAND PROCESSING =====

func execute_command(command: String) -> String:
	"""Execute a console command with natural language processing"""
	var lower = command.to_lower()
	
	# Movement commands
	if lower.contains("go to") or lower.contains("move to"):
		var target = extract_target(command)
		move_gemma_to_target(target)
		return "Moving to " + target
	
	# Look commands
	elif lower.contains("look at") or lower.contains("face"):
		var target = extract_target(command)
		make_gemma_look_at(target)
		return "Looking at " + target
	
	# Inspection
	elif lower.contains("inspect") or lower.contains("what is"):
		return inspect_with_gemma(command)
	
	# Creation with natural language
	elif lower.contains("create") or lower.contains("make"):
		return create_from_description(command)
	
	# Help
	elif lower.contains("help"):
		show_gemma_help()
		return "Help displayed"
	
	# Fall back to base command processing
	return super.execute_command(command)

func move_gemma_to_target(target_desc: String) -> void:
	"""Move Gemma to described target"""
	var target = find_being_by_description(target_desc)
	if target:
		gemma_target = target
		gemma_is_moving = true
		terminal_output("🤖 Moving to " + target.name)
	else:
		terminal_output("🤖 I don't see '%s'" % target_desc)

func make_gemma_look_at(target_desc: String) -> void:
	"""Make Gemma look at target"""
	var target = find_being_by_description(target_desc)
	if target and gemma_body:
		gemma_body.look_at(target.position, Vector3.UP)
		terminal_output("🤖 Looking at " + target.name)

func inspect_with_gemma(command: String) -> String:
	"""Gemma inspects and reports"""
	var target_desc = extract_target(command)
	var target = find_being_by_description(target_desc)
	
	if target:
		var report = "🤖 Inspecting: " + target.name + "\n"
		report += "  Type: " + str(target.get("being_type")) + "\n"
		report += "  Consciousness: " + str(target.get("consciousness_level")) + "\n"
		report += "  Position: " + str(target.position)
		return report
	else:
		# Inspect all
		var beings = get_tree().get_nodes_in_group("universal_beings")
		var report = "🤖 I see %d beings:\n" % beings.size()
		for being in beings:
			var b_type = being.get("being_type") if being.has_method("get") else "unknown"
			report += "  • %s (%s)\n" % [being.name, b_type]
		return report

func create_from_description(command: String) -> String:
	"""Create beings from natural language"""
	terminal_output("🤖 Creating from your words...")
	
	# Parse creation request
	if command.contains("butterfly"):
		var color = Color.CYAN
		if command.contains("red"): color = Color.RED
		elif command.contains("blue"): color = Color.BLUE
		elif command.contains("yellow"): color = Color.YELLOW
		
		create_colored_butterfly(color)
		return "✨ Butterfly manifested!"
	
	elif command.contains("tree"):
		create_tree_universal_being()
		return "🌳 Tree has taken root!"
	
	elif command.contains("star"):
		create_star_being()
		return "⭐ Star shines above!"
	
	return "Try: 'create blue butterfly' or 'make a tree'"

# ===== CREATION METHODS =====

func create_colored_butterfly(color: Color) -> void:
	"""Create butterfly with specific color"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var butterfly = SystemBootstrap.create_universal_being()
		if butterfly:
			butterfly.name = "Butterfly"
			butterfly.set("being_type", "butterfly")
			butterfly.set("consciousness_level", 3)
			
			var visual = Label.new()
			visual.text = "🦋"
			visual.add_theme_font_size_override("font_size", 48)
			visual.modulate = color
			butterfly.add_child(visual)
			
			if get_tree().current_scene:
				get_tree().current_scene.add_child(butterfly)
				butterfly.position = get_viewport().get_visible_rect().size / 2

func create_tree_universal_being() -> void:
	"""Create a tree being"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var tree = SystemBootstrap.create_universal_being()
		if tree:
			tree.name = "Tree"
			tree.set("being_type", "tree")
			tree.set("consciousness_level", 2)
			
			var visual = Label.new()
			visual.text = "🌳"
			visual.add_theme_font_size_override("font_size", 48)
			tree.add_child(visual)
			
			if get_tree().current_scene:
				get_tree().current_scene.add_child(tree)
				tree.position = get_viewport().get_visible_rect().size / 2

func create_star_being() -> void:
	"""Create a star being"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var star = SystemBootstrap.create_universal_being()
		if star:
			star.name = "Star"
			star.set("being_type", "star")
			star.set("consciousness_level", 4)
			
			var visual = Label.new()
			visual.text = "⭐"
			visual.add_theme_font_size_override("font_size", 48)
			star.add_child(visual)
			
			if get_tree().current_scene:
				get_tree().current_scene.add_child(star)
				star.position = Vector2(get_viewport().get_visible_rect().size.x / 2, 100)

# ===== HELPER METHODS =====

func extract_target(command: String) -> String:
	"""Extract target from command"""
	var parts = command.split(" ")
	var target = ""
	var skip_words = ["to", "at", "the", "a", "an"]
	
	var capture = false
	for word in parts:
		if word in ["to", "at"]:
			capture = true
			continue
		if capture and not word in skip_words:
			target = word
			break
	
	return target

func find_being_by_description(desc: String) -> Node:
	"""Find being by name or type"""
	var beings = get_tree().get_nodes_in_group("universal_beings")
	
	# Try exact name match first
	for being in beings:
		if being.name.to_lower().contains(desc.to_lower()):
			return being
	
	# Try type match
	for being in beings:
		var b_type = being.get("being_type") if being.has_method("get") else ""
		if b_type.to_lower().contains(desc.to_lower()):
			return being
	
	return null

func show_gemma_help() -> void:
	"""Show natural language help"""
	terminal_output("🤖 WORDS OF POWER:")
	terminal_output("Movement:")
	terminal_output("  • go to [target]")
	terminal_output("  • look at [being]")
	terminal_output("Creation:")
	terminal_output("  • create [color] butterfly")
	terminal_output("  • make a tree")
	terminal_output("  • create star")
	terminal_output("Inspection:")
	terminal_output("  • inspect [target]")
	terminal_output("  • what is there?")
	terminal_output("")
	terminal_output("Speak naturally - I understand context!")

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	pass
	var base_interface = super.ai_interface()
	base_interface.gemma_commands = [
		"move_to",
		"look_at",
		"inspect",
		"create",
		"toggle_visibility"
	]
	base_interface.gemma_properties = {
		"name": gemma_name,
		"color": gemma_color,
		"energy": gemma_energy,
		"is_visible": gemma_body.visible if gemma_body else false
	}
	return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		"move_to":
			if args.size() > 0:
				move_gemma_to_target(args[0])
				return true
			return false
		"look_at":
			if args.size() > 0:
				make_gemma_look_at(args[0])
				return true
			return false
		"inspect":
			if args.size() > 0:
				return inspect_with_gemma(args[0])
			return "No target specified"
		"create":
			if args.size() > 0:
				return create_from_description(args[0])
			return "No creation command specified"
		"toggle_visibility":
			toggle_gemma_visibility()
			return true
		_:
			return super.ai_invoke_method(method_name, args)
