# ==================================================
# UNIVERSAL BEING: GemmaSimple
# TYPE: Console
# PURPOSE: Simple Gemma AI console integration
# COMPONENTS: None (extends console_base)
# SCENES: None (UI handled by base class)
# ==================================================

extends ConsoleBaseUniversalBeing
class_name GemmaSimpleUniversalBeing

# ===== BEING-SPECIFIC PROPERTIES =====
@export var gemma_name: String = "Gemma"
@export var gemma_color: Color = Color(0.5, 0.9, 1.0)
@export var gemma_energy: float = 2.0

# Gemma state
var gemma_body: Node3D = null

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	super.pentagon_init()
	
	# Set Universal Being identity
	being_type = "gemma_simple"
	being_name = gemma_name
	consciousness_level = 2  # Medium consciousness for basic AI
	
	print("🌟 %s: Gemma Simple Init Complete" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Create Gemma's physical form
	create_gemma_embodiment()
	
	print("🌟 %s: Gemma Simple Ready Complete" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	# No additional processing needed

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	# No additional input handling needed

func pentagon_sewers() -> void:
	# Cleanup Gemma's physical form
	if gemma_body:
		gemma_body.queue_free()
	
	super.pentagon_sewers()

# ===== GEMMA-SPECIFIC METHODS =====

func create_gemma_embodiment() -> void:
	"""Give Gemma a physical form"""
	terminal_output("🤖 Manifesting Gemma AI embodiment...")
	
	gemma_body = Node3D.new()
	gemma_body.name = "GemmaAI"
	
	# Simple glowing orb
	var mesh = MeshInstance3D.new()
	mesh.mesh = SphereMesh.new()
	mesh.mesh.radius = 0.5
	
	var mat = StandardMaterial3D.new()
	mat.emission_enabled = true
	mat.emission = gemma_color
	mat.emission_energy = gemma_energy
	mesh.material_override = mat
	
	gemma_body.add_child(mesh)
	if get_tree().current_scene:
		get_tree().current_scene.add_child(gemma_body)
		gemma_body.position = Vector3(0, 2, 5)
	
	terminal_output("✨ Gemma manifested! Try: 'go to tree' or 'look at butterfly'")

# ===== COMMAND PROCESSING =====

func execute_command(command: String) -> String:
	"""Execute a console command with natural language processing"""
	var parts = command.split(" ", false)
	if parts.is_empty():
		return "Empty command"
	
	# Natural language movement
	if command.contains("go to") or command.contains("move to"):
		if gemma_body:
			var target_name = command.split("to")[-1].strip_edges()
			var target = find_being(target_name)
			if target:
				var tween = gemma_body.create_tween()
				tween.tween_property(gemma_body, "position", 
					target.position + Vector3(2, 1, 0), 1.0)
				return "🤖 Moving to " + target.name
			else:
				return "🤖 Can't find " + target_name
		else:
			create_gemma_embodiment()
			return "Created Gemma embodiment"
	
	# Natural language inspection
	if command.contains("what is") or command.contains("inspect"):
		var target_name = command.split(" ")[-1]
		var target = find_being(target_name)
		if target:
			var report = "🤖 Inspecting " + target.name + ":\n"
			report += "  Type: " + str(target.get("being_type")) + "\n"
			report += "  Consciousness: " + str(target.get("consciousness_level"))
			return report
		return "🤖 Can't find " + target_name
	
	# Natural language creation
	if command.contains("create") and command.contains("butterfly"):
		return handle_create_command("butterfly")
	
	# Fall back to base command processing
	return super.execute_command(command)

func find_being(name: String) -> Node:
	"""Find a being by name or type"""
	var beings = get_tree().get_nodes_in_group("universal_beings")
	for being in beings:
		if being.name.to_lower().contains(name.to_lower()):
			return being
		var b_type = being.get("being_type") if being.has_method("get") else ""
		if b_type.to_lower().contains(name.to_lower()):
			return being
	return null

func handle_create_command(being_type: String) -> String:
	"""Handle creation commands"""
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var being = SystemBootstrap.create_universal_being()
		if being:
			being.name = being_type.capitalize()
			being.set("being_type", being_type)
			being.set("consciousness_level", 1)
			
			if get_tree().current_scene:
				get_tree().current_scene.add_child(being)
				being.position = get_viewport().get_visible_rect().size / 2
			return "✨ Created " + being_type
	return "❌ Failed to create " + being_type

# ===== AI INTEGRATION =====

func ai_interface() -> Dictionary:
	var base_interface = super.ai_interface()
	base_interface.gemma_commands = ["move_to", "inspect", "create"]
	base_interface.gemma_properties = {
		"name": gemma_name,
		"color": gemma_color,
		"energy": gemma_energy,
		"is_visible": gemma_body != null
	}
	return base_interface

func ai_invoke_method(method_name: String, args: Array = []) -> Variant:
	match method_name:
		"move_to":
			if args.size() > 0:
				var target = find_being(args[0])
				if target and gemma_body:
					var tween = gemma_body.create_tween()
					tween.tween_property(gemma_body, "position", 
						target.position + Vector3(2, 1, 0), 1.0)
					return true
			return false
		"inspect":
			if args.size() > 0:
				var target = find_being(args[0])
				if target:
					return "Type: " + str(target.get("being_type")) + "\n" + \
						   "Consciousness: " + str(target.get("consciousness_level"))
			return "Target not found"
		"create":
			if args.size() > 0:
				return handle_create_command(args[0])
			return "No being type specified"
		_:
			return super.ai_invoke_method(method_name, args)
