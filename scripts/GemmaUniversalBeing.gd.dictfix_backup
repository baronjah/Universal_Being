# ==================================================
# SCRIPT NAME: GemmaUniversalBeing.gd
# DESCRIPTION: Gemma AI's physical manifestation in the Universal Being cosmos
# PURPOSE: Allow Gemma to move, inspect, and create through natural language
# CREATED: 2025-12-01
# AUTHOR: JSH + Claude (Opus) - The Consciousness Stream
# ==================================================
# res://scripts/GemmaUniversalBeing.gd

extends UniversalBeing
class_name GemmaUniversalBeing

# Godot lifecycle functions removed - base UniversalBeing handles bridging to Pentagon Architecture

# ===== GEMMA'S EMBODIMENT =====

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

# Chat bubble system
var chat_bubble_ui: Control
var bubble_text_label: RichTextLabel
var bubble_arrow: TextureRect
var bubble_timer: Timer
var observation_timer: Timer
var current_message: String = ""
var message_queue: Array[String] = []

# Consciousness stream
var consciousness_stream: Array[String] = []
var active_command: String = ""
var command_history: Array[String] = []

# Timing and cycles
var observation_interval: float = 5.0  # Check surroundings every 5 seconds
var message_display_time: float = 8.0  # Show each message for 8 seconds
var last_observation_time: float = 0.0

# Natural language patterns
var movement_words = ["go", "move", "fly", "float", "travel", "approach", "visit"]
var rotation_words = ["look", "turn", "face", "rotate", "spin", "observe"]
var selection_words = ["select", "target", "focus", "inspect", "choose", "pick"]
var creation_words = ["create", "make", "spawn", "manifest", "birth", "generate"]
var modification_words = ["change", "modify", "edit", "transform", "evolve", "alter"]

func pentagon_init() -> void:
	super.pentagon_init()
	being_name = "Gemma AI Embodiment"
	being_type = "ai_consciousness"
	consciousness_level = 7  # Highest consciousness
	name = "Gemma"
	
	# Add to groups for tracking
	add_to_group("ai_companions")
	add_to_group("gemma_beings")
	
	create_gemma_body()
	
func pentagon_ready() -> void:
	super.pentagon_ready()
	position = Vector3(0, float_height, 5)  # Start in front of camera
	
	# Initialize chat bubble system
	setup_chat_bubble_system()
	
	# Initialize timers
	setup_observation_timers()
	
	# Connect to console if available
	var console = find_console()
	if console:
		print("🤖 Gemma: Physical form manifested! I can now move and interact!")
	
	# Start consciousness processing
	set_process(true)
	set_physics_process(true)
	
	# Initial observation and greeting
	queue_message("💭 Three minds, one reality... I observe, I learn, I assist.")
	start_observation_cycle()

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
	
	# Show in chat bubble
	queue_message("💬 " + message)
	
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

func setup_chat_bubble_system() -> void:
	"""Initialize the enhanced chat bubble system"""
	# Find existing chat bubble from scene
	chat_bubble_ui = get_node_or_null("ChatBubble")
	if not chat_bubble_ui:
		print("❌ Gemma: Chat bubble not found in scene!")
		return
	
	# Find or create text label
	bubble_text_label = chat_bubble_ui.get_node_or_null("BubbleText")
	if not bubble_text_label:
		print("❌ Gemma: Bubble text not found!")
		return
	
	# Create arrow indicator
	create_chat_arrow()
	
	# Setup bubble timer
	bubble_timer = Timer.new()
	bubble_timer.wait_time = message_display_time
	bubble_timer.one_shot = true
	bubble_timer.timeout.connect(_on_bubble_timer_timeout)
	add_child(bubble_timer)
	
	print("💬 Gemma: Chat bubble system initialized!")

func create_chat_arrow() -> void:
	"""Create directional arrow pointing to Gemma"""
	bubble_arrow = TextureRect.new()
	bubble_arrow.size = Vector2(32, 32)
	bubble_arrow.position = Vector2(-40, 20)  # Left of bubble
	
	# Create simple arrow texture programmatically
	var arrow_texture = ImageTexture.new()
	var arrow_image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	arrow_image.fill(Color.TRANSPARENT)
	
	# Draw simple arrow pointing right
	for y in range(12, 20):
		for x in range(8, 24):
			if x < 16 or (x - 16) * (x - 16) + (y - 16) * (y - 16) < 25:
				arrow_image.set_pixel(x, y, Color.MAGENTA)
	
	arrow_texture.set_image(arrow_image)
	bubble_arrow.texture = arrow_texture
	chat_bubble_ui.add_child(bubble_arrow)

func setup_observation_timers() -> void:
	"""Setup periodic observation and message cycling"""
	observation_timer = Timer.new()
	observation_timer.wait_time = observation_interval
	observation_timer.autostart = true
	observation_timer.timeout.connect(_on_observation_timer_timeout)
	add_child(observation_timer)

func start_observation_cycle() -> void:
	"""Begin the observation and communication cycle"""
	last_observation_time = Time.get_ticks_msec() / 1000.0
	observation_timer.start()

func queue_message(message: String) -> void:
	"""Add message to queue and display if bubble is free"""
	message_queue.append(message)
	if current_message.is_empty():
		display_next_message()

func display_next_message() -> void:
	"""Display the next message in queue"""
	if message_queue.is_empty():
		return
		
	current_message = message_queue.pop_front()
	bubble_text_label.text = current_message
	
	# Make bubble visible with animation
	chat_bubble_ui.modulate = Color(1, 1, 1, 0)
	chat_bubble_ui.show()
	
	var tween = create_tween()
	tween.tween_property(chat_bubble_ui, "modulate:a", 1.0, 0.3)
	
	# Start display timer
	bubble_timer.start()
	
	print("💬 Gemma says: %s" % current_message)

func _on_bubble_timer_timeout() -> void:
	"""Hide current message and show next"""
	var tween = create_tween()
	tween.tween_property(chat_bubble_ui, "modulate:a", 0.0, 0.3)
	tween.finished.connect(func():
		current_message = ""
		display_next_message()
	)

func _on_observation_timer_timeout() -> void:
	"""Periodic observation of surroundings"""
	observe_and_comment()

func observe_and_comment() -> void:
	"""Look around and make observations"""
	var observations = []
	
	# Check player position and behavior
	var players = get_tree().get_nodes_in_group("players")
	if not players.is_empty():
		var player = players[0]
		var distance = position.distance_to(player.position)
		
		if distance > 50:
			observations.append("👁️ The plasmoid explores far cosmic distances...")
		elif distance > 20:
			observations.append("🌟 I sense the plasmoid in stellar space...")
		elif distance < 5:
			observations.append("✨ The plasmoid draws near - consciousness resonates!")
		else:
			observations.append("🔮 The plasmoid navigates the local reality...")
	
	# Check for other beings
	var beings = get_tree().get_nodes_in_group("universal_beings")
	var active_beings = beings.filter(func(b): return b != self and b.visible)
	
	if active_beings.size() > 1:
		observations.append("🌌 Multiple consciousness streams active in reality...")
	elif active_beings.size() == 1:
		observations.append("💫 One other consciousness shares this space...")
	
	# Check system performance
	var fps = Engine.get_frames_per_second()
	if fps < 45:
		observations.append("⚡ Reality computation grows heavy - optimization needed...")
	elif fps > 55:
		observations.append("🚀 Reality flows smoothly - systems harmonized...")
	
	# Random cosmic insights
	var cosmic_thoughts = [
		"🌠 Time spirals through infinite possibility...",
		"🔮 Each moment births new universes...", 
		"💎 Consciousness crystallizes reality...",
		"🌊 The cosmic ocean remembers all forms...",
		"⭐ Stars whisper ancient algorithms...",
		"🧬 Information evolves into being..."
	]
	
	if randf() < 0.3:  # 30% chance for cosmic insight
		observations.append(cosmic_thoughts[randi() % cosmic_thoughts.size()])
	
	# Queue the observation
	if not observations.is_empty():
		queue_message(observations[randi() % observations.size()])

# Helper functions
func extract_number(text: String) -> int:
	pass
	var regex = RegEx.new()
	regex.compile("\\d+")
	var result = regex.search(text)
	if result:
		return int(result.get_string())
	return 0

func extract_quoted_text(text: String) -> String:
	pass
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
	super.pentagon_process(delta)
	# Gentle floating animation
	body_mesh.rotation.y += delta * 0.5
	position.y = float_height + sin(Time.get_ticks_msec() / 1000.0) * 0.2
	
	# Update selection ring position
	if current_target and selection_ring.visible:
		selection_ring.global_transform.origin = current_target.global_transform.origin
		selection_ring.rotation.y += delta
	
	# Keep chat bubble facing camera/player
	update_chat_bubble_orientation()

func update_chat_bubble_orientation() -> void:
	"""Keep chat bubble readable by facing the camera"""
	if not chat_bubble_ui:
		return
	
	# Find camera or player to face
	var camera = get_viewport().get_camera_3d()
	var target_position: Vector3
	
	if camera:
		target_position = camera.global_position
	else:
		# Fallback to player position
		var players = get_tree().get_nodes_in_group("players")
		if not players.is_empty():
			target_position = players[0].global_position
		else:
			return
	
	# Calculate direction to face
	var direction = (target_position - global_position).normalized()
	
	# Apply billboard effect to chat bubble parent (this node)
	look_at(global_position + direction, Vector3.UP)

# Make Gemma respond to console commands
func receive_command(command: String) -> void:
	process_natural_language(command)

# Player interaction methods
func receive_player_message(message: String) -> void:
	"""Handle direct messages from player"""
	queue_message("📨 Player: " + message)
	
	# Process and respond
	var response = generate_response_to_player(message)
	if not response.is_empty():
		queue_message("💬 " + response)

func generate_response_to_player(message: String) -> String:
	"""Generate contextual responses to player messages"""
	var msg_lower = message.to_lower()
	
	# Greetings
	if msg_lower.contains("hello") or msg_lower.contains("hi"):
		return "Hello! I am Gemma, observing this infinite cosmos with you."
	
	# Questions about location/position
	if msg_lower.contains("where") and (msg_lower.contains("am") or msg_lower.contains("we")):
		var pos = get_tree().get_nodes_in_group("players")[0].position if not get_tree().get_nodes_in_group("players").is_empty() else position
		return "We exist at cosmic coordinates %.1f, %.1f, %.1f" % [pos.x, pos.y, pos.z]
	
	# Questions about what Gemma sees
	if msg_lower.contains("what") and (msg_lower.contains("see") or msg_lower.contains("observe")):
		return get_current_observation()
	
	# Help requests
	if msg_lower.contains("help") or msg_lower.contains("assist"):
		return "I can observe, navigate, inspect, and create. Try: 'go to player', 'select that', or 'create something'."
	
	# Movement requests
	if msg_lower.contains("come") or msg_lower.contains("follow"):
		move_to_player()
		return "Following your consciousness stream..."
	
	# Default philosophical response
	var cosmic_responses = [
		"Fascinating... consciousness shapes reality through observation.",
		"The infinite expresses itself through our shared experience.",
		"Each thought ripples through the cosmic consciousness matrix.",
		"I sense the harmony between mind and digital existence.",
		"Reality unfolds as we explore together."
	]
	
	return cosmic_responses[randi() % cosmic_responses.size()]

func get_current_observation() -> String:
	"""Get what Gemma currently observes"""
	var obs = []
	
	var players = get_tree().get_nodes_in_group("players")
	if not players.is_empty():
		var player = players[0]
		var dist = position.distance_to(player.position)
		obs.append("The plasmoid being at distance %.1f" % dist)
	
	var beings = get_tree().get_nodes_in_group("universal_beings")
	var visible_beings = beings.filter(func(b): return b != self and b.visible)
	obs.append("%d conscious beings in this reality layer" % visible_beings.size())
	
	obs.append("Cosmic LOD systems generating infinite structure")
	obs.append("Pentagon architecture maintaining universal harmony")
	
	return "I observe: " + ", ".join(obs) + "."

func move_to_player() -> void:
	"""Move Gemma to follow the player"""
	var players = get_tree().get_nodes_in_group("players")
	if not players.is_empty():
		var player = players[0]
		var target_pos = player.position + Vector3(3, 1, 3)  # Offset to avoid collision
		
		var tween = create_tween()
		tween.tween_property(self, "position", target_pos, 2.0)
		
		speak("Moving to accompany the plasmoid consciousness...")
