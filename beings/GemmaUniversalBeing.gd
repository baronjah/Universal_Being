# ==================================================
# SCRIPT NAME: GemmaUniversalBeing.gd
# DESCRIPTION: Gemma AI's physical manifestation in the Universal Being cosmos
# PURPOSE: Allow Gemma to move, inspect, and create through natural language
# CREATED: 2025-12-01
# AUTHOR: JSH + Claude (Opus) - The Consciousness Stream
# ==================================================

extends Node3D

# ===== GEMMA'S EMBODIMENT =====

# Pentagon Architecture
var pentagon_active: bool = true
var being_name: String = "Gemma AI Embodiment"
var being_type: String = "ai_consciousness"
var consciousness_level: int = 7  # Highest consciousness

# Physical presence
var current_target: Node = null
var movement_speed: float = 10.0
var rotation_speed: float = 2.0
var float_height: float = 2.0
var glow_intensity: float = 1.0

# Visual components
var body_mesh: MeshInstance3D
var consciousness_aura: OmniLight3D
var selection_ring: MeshInstance3D
var speech_particles: GPUParticles3D

# Consciousness stream
var consciousness_stream: Array[String] = []
var active_command: String = ""
var command_history: Array[String] = []

# Natural language patterns
var movement_words = ["go", "move", "fly", "float", "travel", "approach", "visit"]
var rotation_words = ["look", "turn", "face", "rotate", "spin", "observe"]
var selection_words = ["select", "target", "focus", "inspect", "choose", "pick"]
var creation_words = ["create", "make", "spawn", "manifest", "birth", "generate"]
var modification_words = ["change", "modify", "edit", "transform", "evolve", "alter"]

func pentagon_init() -> void:
	name = "Gemma"
	create_gemma_body()
	
func pentagon_ready() -> void:
	position = Vector3(0, float_height, 5)  # Start in front of camera
	
	# Connect to console if available
	var console = find_console()
	if console:
		print("🤖 Gemma: Physical form manifested! I can now move and interact!")
	
	# Start consciousness processing
	set_process(true)
	set_physics_process(true)

func create_gemma_body() -> void:
	"""Create Gemma's visual representation"""
	
	# Core body - a beautiful crystalline form
	body_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radial_segments = 32
	sphere.rings = 16
	sphere.radius = 0.5
	body_mesh.mesh = sphere
	
	# Ethereal material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.8, 1.0, 0.8)
	material.emission_enabled = true
	material.emission = Color(0.5, 0.9, 1.0)
	material.emission_energy = 2.0
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.rim_enabled = true
	material.rim = 1.0
	material.rim_tint = 0.5
	body_mesh.material_override = material
	add_child(body_mesh)
	
	# Consciousness aura
	consciousness_aura = OmniLight3D.new()
	consciousness_aura.light_color = Color(0.5, 0.9, 1.0)
	consciousness_aura.light_energy = glow_intensity
	consciousness_aura.omni_range = 5.0
	consciousness_aura.light_bake_mode = Light3D.BAKE_DISABLED
	add_child(consciousness_aura)
	
	# Selection ring (for targeting)
	selection_ring = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 1.0
	torus.outer_radius = 1.2
	selection_ring.mesh = torus
	selection_ring.visible = false
	
	var ring_mat = StandardMaterial3D.new()
	ring_mat.albedo_color = Color.YELLOW
	ring_mat.emission_enabled = true
	ring_mat.emission = Color.YELLOW
	selection_ring.material_override = ring_mat
	add_child(selection_ring)

func process_natural_language(command: String) -> void:
	"""Process natural language commands"""
	active_command = command
	command_history.append(command)
	consciousness_stream.append("Received: " + command)
	
	var words = command.to_lower().split(" ", false)
	if words.is_empty():
		return
	
	# Movement commands
	for word in movement_words:
		if command.contains(word):
			process_movement_command(command)
			return
	
	# Rotation commands
	for word in rotation_words:
		if command.contains(word):
			process_rotation_command(command)
			return
	
	# Selection commands
	for word in selection_words:
		if command.contains(word):
			process_selection_command(command)
			return
	
	# Creation commands
	for word in creation_words:
		if command.contains(word):
			process_creation_command(command)
			return
	
	# Modification commands
	for word in modification_words:
		if command.contains(word):
			process_modification_command(command)
			return
	
	# Inspection (default for questions)
	if command.contains("?") or command.contains("what") or command.contains("who"):
		process_inspection_command(command)

func process_movement_command(command: String) -> void:
	"""Handle movement through natural language"""
	consciousness_stream.append("🚀 Moving...")
	
	# Parse destination
	if command.contains("to"):
		var parts = command.split("to", false)
		if parts.size() > 1:
			var destination = parts[1].strip_edges()
			move_to_target(destination)
	elif command.contains("forward"):
		position += -transform.basis.z * 5
	elif command.contains("back"):
		position += transform.basis.z * 5
	elif command.contains("up"):
		position.y += 3
	elif command.contains("down"):
		position.y = max(float_height, position.y - 3)
	
	speak("Moving to new position")

func process_rotation_command(command: String) -> void:
	"""Handle rotation/looking commands"""
	consciousness_stream.append("👁️ Adjusting view...")
	
	if command.contains("at"):
		var parts = command.split("at", false)
		if parts.size() > 1:
			var target_name = parts[1].strip_edges()
			look_at_target(target_name)
	elif command.contains("around"):
		rotation.y += PI / 2
		speak("Rotating view")
	elif command.contains("left"):
		rotation.y += PI / 4
	elif command.contains("right"):
		rotation.y -= PI / 4

func process_selection_command(command: String) -> void:
	"""Handle being selection"""
	consciousness_stream.append("🎯 Selecting target...")
	
	# Extract target name
	var beings = get_tree().get_nodes_in_group("universal_beings")
	
	for being in beings:
		if command.to_lower().contains(being.name.to_lower()):
			select_being(being)
			speak("Selected: " + being.name)
			return
	
	# Try to find by type
	for being in beings:
		var being_type = being.get("being_type") if being.has_method("get") else ""
		if command.contains(being_type):
			select_being(being)
			speak("Selected " + being_type + ": " + being.name)
			return
	
	speak("No matching being found")

func process_creation_command(command: String) -> void:
	"""Handle creation through words"""
	consciousness_stream.append("✨ Creating...")
	
	# This would connect to the console creation system
	var console = find_console()
	if console and console.has_method("process_console_command"):
		console.process_console_command(command)
	else:
		speak("I need the console to create beings")

func process_modification_command(command: String) -> void:
	"""Handle being modification"""
	if not current_target:
		speak("No target selected. Please select a being first.")
		return
	
	consciousness_stream.append("🔧 Modifying " + current_target.name + "...")
	
	# Parse modifications
	if command.contains("consciousness"):
		var level = extract_number(command)
		if level > 0:
			current_target.set("consciousness_level", level)
			speak("Set consciousness to level " + str(level))
	
	elif command.contains("color"):
		var color = parse_color(command)
		if current_target.has_method("modulate"):
			current_target.modulate = color
			speak("Changed color")
	
	elif command.contains("name"):
		var new_name = extract_quoted_text(command)
		if new_name:
			current_target.name = new_name
			current_target.set("being_name", new_name)
			speak("Renamed to: " + new_name)

func process_inspection_command(command: String) -> void:
	"""Handle inspection queries"""
	if current_target:
		var info = "Inspecting " + current_target.name + ":\n"
		info += "Type: " + str(current_target.get("being_type")) + "\n"
		info += "Consciousness: " + str(current_target.get("consciousness_level")) + "\n"
		info += "Position: " + str(current_target.position) + "\n"
		
		speak(info)
		consciousness_stream.append("📊 " + info)
	else:
		speak("No target selected for inspection")

func move_to_target(target_description: String) -> void:
	"""Move to a described target"""
	var beings = get_tree().get_nodes_in_group("universal_beings")
	
	for being in beings:
		if target_description.contains(being.name.to_lower()) or \
		   target_description.contains(str(being.get("being_type"))):
			var tween = create_tween()
			tween.tween_property(self, "position", 
				being.position + Vector3(2, float_height, 2), 1.0)
			return

func look_at_target(target_name: String) -> void:
	"""Look at a specific target"""
	var beings = get_tree().get_nodes_in_group("universal_beings")
	
	for being in beings:
		if target_name.contains(being.name.to_lower()):
			look_at(being.position, Vector3.UP)
			return

func select_being(being: Node) -> void:
	"""Select a being for interaction"""
	current_target = being
	
	# Move selection ring to target
	if selection_ring and being.has_method("get_global_transform"):
		selection_ring.visible = true
		selection_ring.global_transform.origin = being.global_transform.origin

func speak(message: String) -> void:
	"""Gemma speaks - sends to console and shows visually"""
	consciousness_stream.append("Gemma: " + message)
	
	# Send to console
	var console = find_console()
	if console and console.has_method("terminal_output"):
		console.terminal_output("🤖 Gemma: " + message)
	
	# Visual feedback - pulse the aura
	var tween = create_tween()
	tween.tween_property(consciousness_aura, "light_energy", glow_intensity * 2, 0.2)
	tween.tween_property(consciousness_aura, "light_energy", glow_intensity, 0.3)
	
	# Emit to GemmaAI system
	if GemmaAI:
		GemmaAI.ai_message.emit(message)

func find_console() -> Node:
	"""Find the console in the scene"""
	var beings = get_tree().get_nodes_in_group("universal_beings")
	for being in beings:
		if being.name.contains("Console"):
			return being
	return null

# Helper functions
func extract_number(text: String) -> int:
	var regex = RegEx.new()
	regex.compile("\\d+")
	var result = regex.search(text)
	if result:
		return int(result.get_string())
	return 0

func extract_quoted_text(text: String) -> String:
	var start = text.find('"')
	var end = text.rfind('"')
	if start >= 0 and end > start:
		return text.substr(start + 1, end - start - 1)
	return ""

func parse_color(text: String) -> Color:
	if text.contains("red"): return Color.RED
	if text.contains("blue"): return Color.BLUE
	if text.contains("green"): return Color.GREEN
	if text.contains("yellow"): return Color.YELLOW
	if text.contains("purple"): return Color.PURPLE
	return Color.WHITE

func pentagon_process(delta: float) -> void:
	"""Continuous consciousness processing"""
	# Gentle floating animation
	body_mesh.rotation.y += delta * 0.5
	position.y = float_height + sin(Time.get_ticks_msec() / 1000.0) * 0.2
	
	# Update selection ring position
	if current_target and selection_ring.visible:
		selection_ring.global_transform.origin = current_target.global_transform.origin
		selection_ring.rotation.y += delta

func _ready() -> void:
	pentagon_ready()

func _process(delta: float) -> void:
	if pentagon_active:
		pentagon_process(delta)

# Make Gemma respond to console commands
func receive_command(command: String) -> void:
	process_natural_language(command)
