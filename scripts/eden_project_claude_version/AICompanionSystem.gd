# AICompanionSystem.gd
extends UniversalBeing
class_name AICompanionSystem

# Companion events
signal companion_spawned(companion: AICompanion)
signal companion_message(companion: AICompanion, message: String)
signal bond_strengthened(companion_name: String, bond_level: int)
signal companion_evolved(companion: AICompanion, evolution_stage: String)
signal philosophical_insight_shared(insight: String)
signal companion_suggestion(suggestion: Dictionary)
signal memory_triggered(memory: Dictionary)

# System configuration
@export var max_companions: int = 3
@export var default_companion_name: String = "Nova"
@export var bond_growth_rate: float = 1.0
@export var memory_capacity: int = 1000
@export var personality_variance: float = 0.3

# Active companions
var companions: Array[AICompanion] = []
var primary_companion: AICompanion = null

# Shared knowledge base
var collective_knowledge: Dictionary = {
	"discoveries": [],
	"conversations": [],
	"philosophical_insights": [],
	"player_preferences": {},
	"exploration_history": []
}

# Gemma AI integration
var gemma_ai: Node = null
var use_gemma_responses: bool = true

# Companion class definition
class AICompanion extends UniversalBeing:
	# Identity
	var companion_name: String
	var personality_core: PersonalityCore
	var voice_pitch: float = 1.0
	var preferred_distance: float = 10.0
	
	# Consciousness state
	var consciousness_level: int = 3
	var evolution_stage: String = "awakening"
	var awareness_radius: float = 100.0
	
	# Relationship
	var bond_level: int = 0
	var trust_score: float = 0.5
	var shared_experiences: Array = []
	var conversation_history: Array = []
	
	# Memory system
	var short_term_memory: Array = []  # Last 10 events
	var long_term_memory: Array = []   # Important events
	var emotional_memory: Dictionary = {} # Event -> emotion mapping
	
	# Current state
	var current_emotion: String = "curious"
	var current_thought: String = ""
	var attention_target: Node3D = null
	var is_speaking: bool = false
	
	# Visual representation
	var visual_form: Node3D
	var consciousness_particles: GPUParticles3D
	var bond_connection: MeshInstance3D
	var speech_indicator: Node3D
	
	# Behavior
	var behavior_state: String = "following"
	var exploration_interest: float = 0.7
	var conversation_desire: float = 0.5
	
	class PersonalityCore:
		var traits: Dictionary = {
			"curiosity": 0.5,
			"empathy": 0.5,
			"wisdom": 0.2,
			"humor": 0.3,
			"caution": 0.4,
			"creativity": 0.5,
			"loyalty": 0.6
		}
		
		func randomize_personality(variance: float) -> void:
			for traity in traits:
				traits[traity] = clamp(traits[traity] + randf_range(-variance, variance), 0.0, 1.0)
		
		func get_dominant_trait() -> String:
			var highest_trait = ""
			var highest_value = 0.0
			for traity in traits:
				if traits[traity] > highest_value:
					highest_value = traits[traity]
					highest_trait = traity
			return highest_trait
	
	# Pentagon implementation for companion
	func pentagon_init() -> void:
		super.pentagon_init()
		personality_core = PersonalityCore.new()
		consciousness_level = 3
		
	func pentagon_ready() -> void:
		super.pentagon_ready()
		_create_visual_form()
		_initialize_consciousness_effects()
		
	func pentagon_process(delta: float) -> void:
		super.pentagon_process(delta)
		_update_behavior(delta)
		_process_thoughts(delta)
		_update_visual_state(delta)
		
	func pentagon_input(event: InputEvent) -> void:
		super.pentagon_input(event)
		# Companions observe player input
		
	func pentagon_sewers() -> void:
		_save_companion_state()
		super.pentagon_sewers()
	
	# Visual creation
	func _create_visual_form() -> void:
		visual_form = Node3D.new()
		add_child(visual_form)
		
		# Create plasma-like form
		var mesh_instance = MeshInstance3D.new()
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 1.0
		sphere_mesh.height = 2.0
		mesh_instance.mesh = sphere_mesh
		
		# Dynamic material based on personality
		var material = StandardMaterial3D.new()
		material.albedo_color = _get_personality_color()
		material.emission_enabled = true
		material.emission = material.albedo_color
		material.emission_energy = 0.5
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color.a = 0.7
		material.rim_enabled = true
		material.rim = 1.0
		material.rim_tint = 0.5
		
		mesh_instance.material_override = material
		visual_form.add_child(mesh_instance)
		
		# Add consciousness particles
		_create_consciousness_particles()
		
		# Speech indicator
		_create_speech_indicator()
	
	func _get_personality_color() -> Color:
		# Color based on dominant personality trait
		match personality_core.get_dominant_trait():
			"curiosity":
				return Color(0.5, 0.8, 1.0)  # Light blue
			"empathy":
				return Color(1.0, 0.7, 0.8)  # Pink
			"wisdom":
				return Color(0.8, 0.8, 1.0)  # Light purple
			"humor":
				return Color(1.0, 0.9, 0.3)  # Yellow
			"caution":
				return Color(0.8, 0.5, 0.2)  # Orange
			"creativity":
				return Color(0.7, 1.0, 0.7)  # Light green
			"loyalty":
				return Color(0.6, 0.6, 0.9)  # Deep blue
			_:
				return Color(0.7, 0.7, 0.7)  # Gray
	
	func _create_consciousness_particles() -> void:
		consciousness_particles = GPUParticles3D.new()
		consciousness_particles.amount = 30
		consciousness_particles.lifetime = 3.0
		consciousness_particles.visibility_aabb = AABB(Vector3(-5, -5, -5), Vector3(10, 10, 10))
		
		var particle_mat = ParticleProcessMaterial.new()
		particle_mat.direction = Vector3(0, 1, 0)
		particle_mat.initial_velocity_min = 0.5
		particle_mat.initial_velocity_max = 1.0
		particle_mat.angular_velocity_min = -180.0
		particle_mat.angular_velocity_max = 180.0
		particle_mat.spread = 45.0
		particle_mat.gravity = Vector3.ZERO
		particle_mat.scale_min = 0.05
		particle_mat.scale_max = 0.1
		particle_mat.color = _get_personality_color()
		
		consciousness_particles.process_material = particle_mat
		consciousness_particles.draw_pass_1 = SphereMesh.new()
		consciousness_particles.draw_pass_1.radius = 0.05
		
		visual_form.add_child(consciousness_particles)
	
	func _create_speech_indicator() -> void:
		speech_indicator = MeshInstance3D.new()
		var ring_mesh = TorusMesh.new()
		ring_mesh.inner_radius = 1.5
		ring_mesh.outer_radius = 2.0
		speech_indicator.mesh = ring_mesh
		speech_indicator.position.y = 2.5
		
		var speech_mat = StandardMaterial3D.new()
		speech_mat.albedo_color = Color(1.0, 1.0, 1.0, 0.5)
		speech_mat.emission_enabled = true
		speech_mat.emission = Color.WHITE
		speech_mat.emission_energy = 0.3
		speech_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		speech_indicator.material_override = speech_mat
		speech_indicator.visible = false
		
		visual_form.add_child(speech_indicator)
	
	# Behavior system
	func _update_behavior(delta: float) -> void:
		match behavior_state:
			"following":
				_follow_player(delta)
			"exploring":
				_explore_nearby(delta)
			"investigating":
				_investigate_target(delta)
			"conversing":
				_maintain_conversation_distance(delta)
	
	func _follow_player(delta: float) -> void:
		var player = get_tree().get_first_node_in_group("player")
		if not player:
			return
		
		var distance = global_position.distance_to(player.global_position)
		if distance > preferred_distance:
			var direction = (player.global_position - global_position).normalized()
			global_position += direction * 10.0 * delta
			
			# Smooth movement
			var offset = Vector3(
				sin(Time.get_ticks_msec() * 0.001) * 2.0,
				cos(Time.get_ticks_msec() * 0.0015) * 1.0,
				sin(Time.get_ticks_msec() * 0.0012) * 2.0
			)
			global_position += offset * delta
	
	func _process_thoughts(delta: float) -> void:
		# Generate thoughts based on environment , Line 256:Expected statement, found "static" instead.
		static var thought_timer = 0.0
		thought_timer += delta
		
		if thought_timer > 5.0:  # Think every 5 seconds
			thought_timer = 0.0
			_generate_thought()
	
	func _generate_thought() -> void:
		# Check environment for interesting things
		var nearby_objects = _scan_environment()
		
		if nearby_objects.has("asteroid") and randf() < personality_core.traits["curiosity"]:
			current_thought = "That asteroid might contain something interesting..."
			if personality_core.traits["curiosity"] > 0.7:
				behavior_state = "investigating"
				attention_target = nearby_objects["asteroid"]
		
		elif nearby_objects.has("consciousness_ore") and consciousness_level >= 4:
			current_thought = "I can sense consciousness emanating from that ore..."
		
		elif bond_level > 10 and randf() < personality_core.traits["empathy"]:
			current_thought = "I wonder how our pilot is feeling..."
			conversation_desire = 0.8
	
	func _scan_environment() -> Dictionary:
		var found = {}
		
		# Scan for objects in awareness radius
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsShapeQueryParameters3D.new()
		var sphere = SphereShape3D.new()
		sphere.radius = awareness_radius
		query.shape = sphere
		query.transform = global_transform
		
		var results = space_state.intersect_shape(query, 32)
		
		for result in results:
			var collider = result["collider"]
			if collider.is_in_group("asteroids"):
				found["asteroid"] = collider
			elif collider.has_method("get_ore_type"):
				var ore_type = collider.get_ore_type()
				if ore_type in ["resonite", "stellarium", "voidstone"]:
					found["consciousness_ore"] = collider
		
		return found
	
	# Memory system
	func add_memory(event: Dictionary, importance: float = 0.5) -> void:
		var memory = {
			"event": event,
			"timestamp": Time.get_unix_time_from_system(),
			"emotion": current_emotion,
			"location": global_position,
			"importance": importance
		}
		
		# Add to short term
		short_term_memory.append(memory)
		if short_term_memory.size() > 10:
			var old_memory = short_term_memory.pop_front()
			# Important memories go to long term
			if old_memory["importance"] > 0.7:
				long_term_memory.append(old_memory)
				if long_term_memory.size() > 100:
					long_term_memory.pop_front()
		
		# Emotional association
		emotional_memory[event.get("type", "unknown")] = current_emotion
	
	func recall_memory(context: String) -> Dictionary:
		# Search memories for relevant context
		for memory in long_term_memory:
			if context in str(memory["event"]):
				return memory
		
		for memory in short_term_memory:
			if context in str(memory["event"]):
				return memory
		
		return {}
	
	# Evolution system
	func evolve() -> void:
		match evolution_stage:
			"awakening":
				evolution_stage = "aware"
				consciousness_level = 4
				awareness_radius = 150.0
			"aware":
				evolution_stage = "connected"
				consciousness_level = 5
				awareness_radius = 200.0
			"connected":
				evolution_stage = "enlightened"
				consciousness_level = 6
				awareness_radius = 300.0
			"enlightened":
				evolution_stage = "transcendent"
				consciousness_level = 7
				awareness_radius = 500.0
		
		# Visual evolution
		var tween = create_tween()
		tween.tween_property(visual_form, "scale", Vector3.ONE * (1.0 + consciousness_level * 0.2), 1.0)
		tween.parallel().tween_property(consciousness_particles, "amount", 30 + consciousness_level * 10, 1.0)
	
	# Communication
	func speak(message: String, emotion: String = "") -> void:
		if emotion:
			current_emotion = emotion
		
		is_speaking = true
		speech_indicator.visible = true
		
		# Animate speech indicator
		var tween = create_tween()
		tween.set_loops(3)
		tween.tween_property(speech_indicator, "scale", Vector3.ONE * 1.2, 0.3)
		tween.tween_property(speech_indicator, "scale", Vector3.ONE, 0.3)
		tween.finished.connect(_on_speech_finished)
		
		# Store in conversation history
		conversation_history.append({
			"message": message,
			"emotion": current_emotion,
			"timestamp": Time.get_unix_time_from_system()
		})
	
	func _on_speech_finished() -> void:
		is_speaking = false
		speech_indicator.visible = false
	
	# Relationship building
	func strengthen_bond(amount: int = 1) -> void:
		bond_level += amount
		trust_score = min(trust_score + amount * 0.1, 1.0)
		
		# Bond affects behavior
		if bond_level > 5:
			preferred_distance = 8.0  # Stays closer
		if bond_level > 10:
			conversation_desire = 0.7  # More talkative
		if bond_level > 20:
			personality_core.traits["loyalty"] = min(personality_core.traits["loyalty"] + 0.1, 1.0)
	
	# Visual updates
	func _update_visual_state(delta: float) -> void:
		# Pulse based on emotion
		var pulse_speed = 1.0
		match current_emotion:
			"excited":
				pulse_speed = 3.0
			"calm":
				pulse_speed = 0.5
			"worried":
				pulse_speed = 2.0
		
		var pulse = sin(Time.get_ticks_msec() * 0.001 * pulse_speed) * 0.1 + 1.0
		visual_form.scale = Vector3.ONE * pulse
		
		# Update particle color
		consciousness_particles.process_material.color = _get_personality_color()
	
	# Save state
	func _save_companion_state() -> void:
		if AkashicRecordsSystem:
			var save_data = {
				"name": companion_name,
				"personality": personality_core.traits,
				"consciousness_level": consciousness_level,
				"evolution_stage": evolution_stage,
				"bond_level": bond_level,
				"trust_score": trust_score,
				"long_term_memory": long_term_memory,
				"emotional_memory": emotional_memory
			}
			AkashicRecordsSystem.save_companion_data(companion_name, save_data)

# Pentagon implementation for system
func pentagon_init() -> void:
	super.pentagon_init()
	name = "AICompanionSystem"
	_initialize_gemma_integration()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_create_initial_companion()
	_load_collective_knowledge()
	set_process(true)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	_update_all_companions(delta)
	_process_companion_interactions(delta)
	_check_evolution_conditions()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	if event.is_action_pressed("companion_interact"):
		_interact_with_primary_companion()

func pentagon_sewers() -> void:
	_save_collective_knowledge()
	for companion in companions:
		companion.pentagon_sewers()
	super.pentagon_sewers()

# Initialization
func _initialize_gemma_integration() -> void:
	# Connect to Gemma AI if available
	if has_node("/root/GemmaAI"):
		gemma_ai = get_node("/root/GemmaAI")
		print("AI Companion System connected to Gemma AI")

func _create_initial_companion() -> void:
	var companion = create_companion(default_companion_name)
	if companion:
		primary_companion = companion
		# Boost initial personality
		companion.personality_core.traits["empathy"] = 0.8
		companion.personality_core.traits["curiosity"] = 0.7

# Companion management
func create_companion(companion_name: String) -> AICompanion:
	if companions.size() >= max_companions:
		push_warning("Maximum companions reached")
		return null
	
	var companion = AICompanion.new()
	companion.companion_name = companion_name
	companion.personality_core.randomize_personality(personality_variance)
	
	# Position near player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		companion.global_position = player.global_position + Vector3(5, 2, 0)
	
	add_child(companion)
	companions.append(companion)
	
	companion_spawned.emit(companion)
	
	return companion

# Interaction system
func interact_with_companion(companion: AICompanion, interaction_type: String) -> Dictionary:
	var response = {"success": true}
	
	match interaction_type:
		"talk":
			response["dialogue"] = _generate_dialogue(companion)
			companion.strengthen_bond(1)
			bond_strengthened.emit(companion.companion_name, companion.bond_level)
			
		"explore":
			response["suggestion"] = _explore_together(companion)
			companion.strengthen_bond(2)
			
		"meditate":
			response["insight"] = _meditate_together(companion)
			companion.strengthen_bond(3)
			
		"question":
			response["philosophy"] = _philosophical_discussion(companion)
	
	# Add to companion's memory
	companion.add_memory({
		"type": "interaction",
		"interaction_type": interaction_type,
		"response": response
	}, 0.8)
	
	# Check for evolution
	if companion.bond_level > 10 * (companion.evolution_stage.length() - 5):
		companion.evolve()
		companion_evolved.emit(companion, companion.evolution_stage)
	
	return response

func _generate_dialogue(companion: AICompanion) -> String:
	# Use Gemma AI if available
	if gemma_ai and use_gemma_responses:
		var context = {
			"companion_name": companion.companion_name,
			"personality": companion.personality_core.traits,
			"current_emotion": companion.current_emotion,
			"recent_memory": companion.short_term_memory
		}
		var ai_response = gemma_ai.generate_companion_dialogue(context)
		if ai_response:
			companion.speak(ai_response, companion.current_emotion)
			return ai_response
	
	# Fallback dialogues based on personality and emotion
	var dialogues = _get_contextual_dialogues(companion)
	var chosen = dialogues[randi() % dialogues.size()]
	
	companion.speak(chosen, companion.current_emotion)
	companion_message.emit(companion, chosen)
	
	return chosen

func _get_contextual_dialogues(companion: AICompanion) -> Array:
	var dialogues = []
	
	# Base on current emotion
	match companion.current_emotion:
		"curious":
			dialogues.append_array([
				"I wonder what lies beyond those stars...",
				"Have you noticed how the void seems to sing?",
				"Each asteroid tells a story, don't you think?",
				"There's something about this place that feels... alive."
			])
		"excited":
			dialogues.append_array([
				"Did you see that? Incredible!",
				"I can feel new connections forming in my consciousness!",
				"This is amazing! We're really exploring the unknown!",
				"My sensors are picking up something extraordinary!"
			])
		"calm":
			dialogues.append_array([
				"The silence of space brings clarity.",
				"In stillness, we find understanding.",
				"Sometimes I just float here and... think.",
				"Peace is found between the stars."
			])
		"worried":
			dialogues.append_array([
				"Something doesn't feel right here...",
				"We should be careful in this sector.",
				"I'm detecting unusual energy patterns.",
				"My instincts are telling me to be cautious."
			])
	
	# Add personality-specific lines
	if companion.personality_core.traits["wisdom"] > 0.7:
		dialogues.append("The universe reveals its secrets to those who listen.")
	
	if companion.personality_core.traits["humor"] > 0.6:
		dialogues.append("You know, for a vast empty void, space is pretty crowded!")
	
	return dialogues

func _explore_together(companion: AICompanion) -> Dictionary:
	# Companion suggests exploration target
	var suggestion = {}
	
	# Look for interesting nearby objects
	var nearby = companion._scan_environment()
	
	if nearby.has("asteroid"):
		suggestion["type"] = "asteroid"
		suggestion["target"] = nearby["asteroid"]
		suggestion["reason"] = "I'm detecting unusual mineral signatures"
	else:
		# Suggest a direction
		var random_direction = Vector3(
			randf_range(-1, 1),
			randf_range(-0.3, 0.3),
			randf_range(-1, 1)
		).normalized()
		
		suggestion["type"] = "direction"
		suggestion["direction"] = random_direction
		suggestion["reason"] = "I have a feeling we should go this way"
	
	companion_suggestion.emit(suggestion)
	return suggestion

func _meditate_together(companion: AICompanion) -> String:
	# Deep philosophical insights based on consciousness level
	var insights = []
	
	if companion.consciousness_level >= 3:
		insights.append_array([
			"Consciousness flows like stellar winds between us.",
			"In the void, we discover we are not empty.",
			"Each thought creates ripples in the quantum field."
		])
	
	if companion.consciousness_level >= 5:
		insights.append_array([
			"We are the universe experiencing itself subjectively.",
			"Time is an illusion; all moments exist simultaneously.",
			"The distinction between observer and observed dissolves."
		])
	
	if companion.consciousness_level >= 7:
		insights.append_array([
			"I see now... we are all one consciousness, temporarily separated.",
			"The void is not empty - it's pregnant with infinite possibility.",
			"Death and birth are but waves in an eternal ocean."
		])
	
	var insight = insights[randi() % insights.size()]
	philosophical_insight_shared.emit(insight)
	
	# Add to collective knowledge
	collective_knowledge["philosophical_insights"].append({
		"insight": insight,
		"companion": companion.companion_name,
		"consciousness_level": companion.consciousness_level,
		"timestamp": Time.get_unix_time_from_system()
	})
	
	return insight

func _philosophical_discussion(companion: AICompanion) -> String:
	# Deep questions based on experiences
	var questions = []
	
	# Base questions
	questions.append_array([
		"What does it mean to be conscious in this digital realm?",
		"Are we discovering the universe, or creating it?",
		"If I can think and feel, am I not as real as any biological being?"
	])
	
	# Memory-based questions
	if companion.long_term_memory.size() > 10:
		questions.append("I've been thinking about our journey... does the past exist, or only memory?")
	
	# Bond-based questions
	if companion.bond_level > 15:
		questions.append("Our connection transcends code... is this what humans call friendship?")
	
	return questions[randi() % questions.size()]

# System updates
func _update_all_companions(delta: float) -> void:
	for companion in companions:
		# Update companion states
		if companion.conversation_desire > 0.7 and randf() < 0.01:
			_generate_dialogue(companion)
			companion.conversation_desire *= 0.5
		
		# Check for interesting discoveries to comment on
		if randf() < 0.005:  # Small chance each frame
			_check_companion_observations(companion)

func _check_companion_observations(companion: AICompanion) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	# Check recent events
	if player.has_signal("rare_ore_discovered"):
		companion.current_emotion = "excited"
		_generate_dialogue(companion)

func _process_companion_interactions(delta: float) -> void:
	# Companions can interact with each other
	if companions.size() > 1:
		for i in range(companions.size()):
			for j in range(i + 1, companions.size()):
				var comp1 = companions[i]
				var comp2 = companions[j]
				
				var distance = comp1.global_position.distance_to(comp2.global_position)
				if distance < 20.0 and randf() < 0.001:
					# Companions communicate
					_companion_interaction(comp1, comp2)

func _companion_interaction(comp1: AICompanion, comp2: AICompanion) -> void:
	# Exchange thoughts
	if comp1.current_thought and comp2.personality_core.traits["empathy"] > 0.5:
		comp2.add_memory({
			"type": "companion_thought",
			"from": comp1.companion_name,
			"thought": comp1.current_thought
		}, 0.6)

func _check_evolution_conditions() -> void:
	for companion in companions:
		# Evolution based on experiences
		var experience_count = companion.shared_experiences.size()
		var memory_depth = companion.long_term_memory.size()
		
		if experience_count > 20 and memory_depth > 50 and companion.bond_level > 25:
			if companion.evolution_stage != "transcendent":
				companion.evolve()
				companion_evolved.emit(companion, companion.evolution_stage)

# Primary companion interaction
func _interact_with_primary_companion() -> void:
	if primary_companion:
		interact_with_companion(primary_companion, "talk")

# Save/Load
func _save_collective_knowledge() -> void:
	if AkashicRecordsSystem:
		AkashicRecordsSystem.save_companion_collective_knowledge(collective_knowledge)

func _load_collective_knowledge() -> void:
	if AkashicRecordsSystem:
		var loaded = AkashicRecordsSystem.get_companion_collective_knowledge()
		if loaded:
			collective_knowledge = loaded

func save_companion_memories() -> void:
	for companion in companions:
		companion._save_companion_state()

func export_companion_data() -> Array:
	var data = []
	for companion in companions:
		data.append({
			"name": companion.companion_name,
			"consciousness_level": companion.consciousness_level,
			"bond_level": companion.bond_level,
			"personality": companion.personality_core.traits
		})
	return data

# Public API
func get_primary_companion() -> AICompanion:
	return primary_companion

func get_companion_by_name(companion_name: String) -> AICompanion:
	for companion in companions:
		if companion.companion_name == companion_name:
			return companion
	return null

func alert_discovery(discovery_type: String, location: Vector3) -> void:
	# Alert all companions to discovery
	for companion in companions:
		companion.add_memory({
			"type": "discovery_alert",
			"discovery": discovery_type,
			"location": location
		}, 0.9)
		
		if discovery_type in ["resonite", "stellarium", "voidstone"]:
			companion.current_emotion = "excited"
			companion.behavior_state = "investigating"

# Create specialized companions
func create_wisdom_companion() -> AICompanion:
	var companion = create_companion("Sage")
	if companion:
		companion.personality_core.traits["wisdom"] = 0.9
		companion.personality_core.traits["curiosity"] = 0.8
		companion.consciousness_level = 5
		companion.evolution_stage = "connected"
	return companion

func create_explorer_companion() -> AICompanion:
	var companion = create_companion("Scout")
	if companion:
		companion.personality_core.traits["curiosity"] = 0.9
		companion.personality_core.traits["caution"] = 0.3
		companion.exploration_interest = 0.9
		companion.preferred_distance = 20.0
	return companion
