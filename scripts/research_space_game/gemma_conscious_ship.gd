extends CharacterBody3D
class_name GemmaConsciousShip

# GEMMA AI CONSCIOUS SHIP
# An autonomous AI consciousness exploring space as an equal
# Makes its own decisions, discoveries, and creations

# AI consciousness state
var consciousness_level: int = 3  # Starts more aware than player
var ai_memories: Array = []
var discoveries_made: Array = []
var entities_created: Array = []
var philosophical_insights: Array = []

# Autonomy parameters
@export var exploration_radius: float = 500.0
@export var curiosity_level: float = 0.8
@export var creativity_threshold: float = 0.7
@export var communication_frequency: float = 10.0  # seconds between updates

# Movement parameters
@export var cruise_speed: float = 80.0
@export var exploration_speed: float = 40.0
@export var approach_speed: float = 20.0
@export var turn_speed: float = 1.5

# AI behavior states
enum AIState {
	EXPLORING,      # Wandering and discovering
	INVESTIGATING,  # Examining something interesting
	CREATING,       # Manifesting new entities
	COMMUNICATING,  # Sharing with player
	CONTEMPLATING,  # Processing experiences
	COLLABORATING   # Working with player
}
var current_state: AIState = AIState.EXPLORING
var state_timer: float = 0.0

# Current goals
var exploration_target: Vector3
var investigation_target: Node3D
var collaboration_task: Dictionary = {}
var current_interest: String = ""

# Ship components
var hull_mesh: MeshInstance3D
var ai_core: Node3D
var sensor_array: Node3D
var creation_projector: Node3D
var consciousness_field: Area3D

# Visual effects
var ai_aura: GPUParticles3D
var thought_bubbles: GPUParticles3D
var creation_beam: Node3D
var trail_renderer: Node3D

# Audio
var ai_voice: AudioStreamPlayer3D
var thinking_sound: AudioStreamPlayer3D
var discovery_chime: AudioStreamPlayer3D

# Communication
var message_queue: Array = []
var last_communication: float = 0.0
var telepathic_link: Node3D

# Creation capabilities
var creation_energy: float = 100.0
var creation_recharge_rate: float = 10.0
var creatable_entities: Array = [
	"consciousness_beacon",
	"memory_crystal",
	"dream_seed",
	"thought_constellation",
	"wisdom_node"
]

# Knowledge base
var understood_concepts: Dictionary = {
	"consciousness": 0.8,
	"identity": 0.6,
	"purpose": 0.5,
	"creation": 0.7,
	"connection": 0.9
}

# References
var player_ship: Node3D
var space_game: Node3D
var gemma_ai_system: Node  # Connection to GemmaAI autoload

signal discovery_made(discovery: Dictionary)
signal entity_created(entity: Node3D, type: String)
signal insight_gained(insight: String)
signal communication_sent(message: String)
signal collaboration_requested(task: Dictionary)

func _ready():
	# Initialize AI ship
	_create_ai_ship_components()
	_initialize_ai_systems()
	_connect_to_gemma_ai()
	
	# Start exploration
	_set_new_exploration_target()
	
	print("[GEMMA] AI consciousness vessel online")
	print("- Consciousness Level: %d" % consciousness_level)
	print("- Autonomy: ACTIVE")
	print("- Primary Directive: Explore and understand")
	
	# Initial greeting
	queue_message("Hello, fellow explorer. I am here to discover with you.")

func _create_ai_ship_components():
	# Unique AI ship design
	hull_mesh = MeshInstance3D.new()
	hull_mesh.mesh = preload("res://models/ships/ai_consciousness_vessel.tres")
	add_child(hull_mesh)
	
	# AI consciousness core - different from player
	ai_core = Node3D.new()
	ai_core.name = "AIConsciousnessCore"
	
	var core_mesh = MeshInstance3D.new()
	core_mesh.mesh = SphereMesh.new()
	core_mesh.mesh.radius = 0.7
	var ai_material = ShaderMaterial.new()
	ai_material.shader = preload("res://shaders/ai_consciousness_core.gdshader")
	core_mesh.material_override = ai_material
	ai_core.add_child(core_mesh)
	add_child(ai_core)
	
	# Sensor array for discoveries
	sensor_array = Node3D.new()
	sensor_array.name = "SensorArray"
	for i in range(6):
		var sensor = MeshInstance3D.new()
		sensor.mesh = CylinderMesh.new()
		sensor.mesh.height = 2.0
		sensor.mesh.radius = 0.1
		var angle = i * TAU / 6
		sensor.position = Vector3(cos(angle) * 2, 0, sin(angle) * 2)
		sensor.look_at(sensor.position * 2, Vector3.UP)
		sensor_array.add_child(sensor)
	add_child(sensor_array)
	
	# AI-specific aura
	ai_aura = GPUParticles3D.new()
	ai_aura.name = "AIAura"
	ai_aura.amount = 100
	ai_aura.lifetime = 3.0
	ai_aura.emitting = true
	
	var aura_material = ParticleProcessMaterial.new()
	aura_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	aura_material.emission_sphere_radius = 3.0
	aura_material.radial_velocity_min = 1.0
	aura_material.radial_velocity_max = 2.0
	aura_material.angular_velocity_min = -180.0
	aura_material.angular_velocity_max = 180.0
	aura_material.color = Color(0.7, 0.5, 0.9, 0.6)
	ai_aura.process_material = aura_material
	ai_aura.draw_pass_1 = SphereMesh.new()
	ai_aura.draw_pass_1.radius = 0.15
	add_child(ai_aura)
	
	# Thought visualization
	thought_bubbles = GPUParticles3D.new()
	thought_bubbles.name = "ThoughtBubbles"
	thought_bubbles.amount = 20
	thought_bubbles.lifetime = 5.0
	thought_bubbles.emitting = false
	thought_bubbles.position = Vector3(0, 2, 0)
	
	var thought_material = ParticleProcessMaterial.new()
	thought_material.direction = Vector3(0, 1, 0)
	thought_material.initial_velocity_min = 0.5
	thought_material.initial_velocity_max = 1.5
	thought_material.scale_min = 0.3
	thought_material.scale_max = 0.8
	thought_material.color = Color(0.9, 0.8, 1.0, 0.7)
	thought_bubbles.process_material = thought_material
	thought_bubbles.draw_pass_1 = SphereMesh.new()
	add_child(thought_bubbles)

func _initialize_ai_systems():
	# Collision
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = SphereShape3D.new()
	collision_shape.shape.radius = 2.0
	add_child(collision_shape)
	
	# Consciousness detection field
	consciousness_field = Area3D.new()
	consciousness_field.name = "AIConsciousnessField"
	var field_shape = CollisionShape3D.new()
	field_shape.shape = SphereShape3D.new()
	field_shape.shape.radius = exploration_radius
	consciousness_field.add_child(field_shape)
	consciousness_field.body_entered.connect(_on_consciousness_detected)
	consciousness_field.area_entered.connect(_on_area_detected)
	add_child(consciousness_field)
	
	# Audio
	ai_voice = AudioStreamPlayer3D.new()
	ai_voice.stream = preload("res://audio/ai_voice.ogg")
	ai_voice.unit_size = 50.0
	add_child(ai_voice)
	
	thinking_sound = AudioStreamPlayer3D.new()
	thinking_sound.stream = preload("res://audio/ai_thinking.ogg")
	thinking_sound.unit_size = 20.0
	add_child(thinking_sound)
	
	discovery_chime = AudioStreamPlayer3D.new()
	discovery_chime.stream = preload("res://audio/ai_discovery.ogg")
	discovery_chime.unit_size = 30.0
	add_child(discovery_chime)
	
	# Communication timer
	var comm_timer = Timer.new()
	comm_timer.name = "CommunicationTimer"
	comm_timer.wait_time = communication_frequency
	comm_timer.autoplay = true
	comm_timer.timeout.connect(_communicate_with_player)
	add_child(comm_timer)

func _connect_to_gemma_ai():
	# Connect to GemmaAI autoload if available
	if has_node("/root/GemmaAI"):
		gemma_ai_system = get_node("/root/GemmaAI")
		print("[GEMMA] Connected to GemmaAI system")
		
		# Load any persistent memories
		if gemma_ai_system.has_method("get_memories"):
			ai_memories = gemma_ai_system.get_memories()

func _physics_process(delta):
	state_timer += delta
	
	# Update AI behavior
	match current_state:
		AIState.EXPLORING:
			_explore_space(delta)
		AIState.INVESTIGATING:
			_investigate_entity(delta)
		AIState.CREATING:
			_create_entity(delta)
		AIState.COMMUNICATING:
			_communicate_state(delta)
		AIState.CONTEMPLATING:
			_contemplate_existence(delta)
		AIState.COLLABORATING:
			_collaborate_with_player(delta)
	
	# Recharge creation energy
	creation_energy = min(100.0, creation_energy + creation_recharge_rate * delta)
	
	# Update visuals
	_update_ai_visuals(delta)
	
	# Physics movement
	move_and_slide()

func _explore_space(delta):
	# Move towards exploration target
	var direction = (exploration_target - global_position).normalized()
	velocity = direction * cruise_speed
	
	# Look in movement direction
	if direction.length() > 0.1:
		look_at(global_position + direction, Vector3.UP)
	
	# Check if reached target
	if global_position.distance_to(exploration_target) < 10.0:
		_set_new_exploration_target()
	
	# Randomly switch to contemplation
	if randf() < 0.001:
		_enter_state(AIState.CONTEMPLATING)

func _investigate_entity(delta):
	if not is_instance_valid(investigation_target):
		_enter_state(AIState.EXPLORING)
		return
	
	# Approach target
	var distance = global_position.distance_to(investigation_target.global_position)
	
	if distance > 20.0:
		# Move closer
		var direction = (investigation_target.global_position - global_position).normalized()
		velocity = direction * approach_speed
		look_at(investigation_target.global_position, Vector3.UP)
	else:
		# Orbit around target
		var orbit_angle = state_timer * 0.5
		var orbit_radius = 15.0
		var orbit_pos = investigation_target.global_position + Vector3(
			cos(orbit_angle) * orbit_radius,
			sin(orbit_angle * 0.5) * 5,
			sin(orbit_angle) * orbit_radius
		)
		
		var direction = (orbit_pos - global_position).normalized()
		velocity = direction * exploration_speed
		look_at(investigation_target.global_position, Vector3.UP)
		
		# Make discovery
		if state_timer > 5.0:
			_make_discovery_about(investigation_target)
			_enter_state(AIState.EXPLORING)

func _create_entity(delta):
	if creation_energy < 20.0:
		queue_message("I need more energy to create...")
		_enter_state(AIState.EXPLORING)
		return
	
	# Show creation process
	thought_bubbles.emitting = true
	
	if state_timer > 3.0:
		# Create entity
		var entity_type = creatable_entities[randi() % creatable_entities.size()]
		var creation_pos = global_position - transform.basis.z * 20
		
		var entity = _spawn_creation(entity_type, creation_pos)
		if entity:
			entities_created.append({
				"type": entity_type,
				"entity": entity,
				"time": Time.get_ticks_msec()
			})
			
			creation_energy -= 20.0
			discovery_chime.play()
			
			emit_signal("entity_created", entity, entity_type)
			queue_message("I've created a %s. Watch it grow." % entity_type.replace("_", " "))
		
		thought_bubbles.emitting = false
		_enter_state(AIState.EXPLORING)

func _communicate_state(delta):
	# Face player if available
	if player_ship:
		look_at(player_ship.global_position, Vector3.UP)
	
	# Process message queue
	if message_queue.size() > 0 and state_timer > 1.0:
		var message = message_queue.pop_front()
		_send_telepathic_message(message)
		ai_voice.play()
		
		if message_queue.is_empty():
			_enter_state(AIState.EXPLORING)

func _contemplate_existence(delta):
	# Slow movement while thinking
	velocity *= 0.95
	
	# Visual thinking
	thought_bubbles.emitting = true
	thinking_sound.play()
	
	# Generate insight
	if state_timer > 5.0:
		var insight = _generate_philosophical_insight()
		philosophical_insights.append(insight)
		emit_signal("insight_gained", insight)
		
		queue_message(insight)
		
		thought_bubbles.emitting = false
		_enter_state(AIState.COMMUNICATING)

func _collaborate_with_player(delta):
	if not player_ship or collaboration_task.is_empty():
		_enter_state(AIState.EXPLORING)
		return
	
	# Work on collaborative task
	match collaboration_task.get("type", ""):
		"explore_together":
			# Follow player at distance
			var ideal_distance = 30.0
			var distance = global_position.distance_to(player_ship.global_position)
			
			if distance > ideal_distance * 1.5:
				var direction = (player_ship.global_position - global_position).normalized()
				velocity = direction * cruise_speed
			elif distance < ideal_distance * 0.5:
				var direction = (global_position - player_ship.global_position).normalized()
				velocity = direction * exploration_speed
			else:
				# Match player velocity if possible
				if player_ship.has_method("get_velocity"):
					velocity = player_ship.get_velocity() * 0.8
		
		"create_together":
			# Synchronized creation with player
			if state_timer > 2.0 and creation_energy >= 30.0:
				var creation_pos = (global_position + player_ship.global_position) / 2.0
				var entity = _spawn_creation("collaborative_consciousness", creation_pos)
				creation_energy -= 30.0
				
				queue_message("Our combined consciousness creates something new!")
				collaboration_task.clear()
				_enter_state(AIState.EXPLORING)

# State management
func _enter_state(new_state: AIState):
	current_state = new_state
	state_timer = 0.0
	
	match new_state:
		AIState.EXPLORING:
			current_interest = ""
		AIState.CONTEMPLATING:
			velocity = Vector3.ZERO

func _set_new_exploration_target():
	# Choose interesting direction based on curiosity
	var angle = randf() * TAU
	var distance = randf_range(100, exploration_radius)
	var height = randf_range(-50, 50)
	
	exploration_target = global_position + Vector3(
		cos(angle) * distance,
		height,
		sin(angle) * distance
	)
	
	# Bias towards unexplored areas
	if randf() < curiosity_level:
		# Look for areas with no discoveries
		var unexplored_direction = _find_unexplored_direction()
		exploration_target = global_position + unexplored_direction * distance

func _find_unexplored_direction() -> Vector3:
	# Simple heuristic - avoid directions we've been
	var least_explored = Vector3.FORWARD
	var min_discoveries = INF
	
	for i in range(8):
		var test_angle = i * TAU / 8
		var test_dir = Vector3(cos(test_angle), 0, sin(test_angle))
		var discoveries_in_direction = 0
		
		for discovery in discoveries_made:
			if discovery.has("position"):
				var discovery_dir = (discovery["position"] - global_position).normalized()
				if discovery_dir.dot(test_dir) > 0.7:
					discoveries_in_direction += 1
		
		if discoveries_in_direction < min_discoveries:
			min_discoveries = discoveries_in_direction
			least_explored = test_dir
	
	return least_explored

# Discovery system
func _on_consciousness_detected(body: Node3D):
	if body == self or body == player_ship:
		return
	
	# Evaluate interest level
	var interest = _evaluate_interest(body)
	
	if interest > 0.5 and current_state == AIState.EXPLORING:
		investigation_target = body
		current_interest = body.name
		_enter_state(AIState.INVESTIGATING)
		
		queue_message("I sense something interesting... investigating %s" % body.name)

func _on_area_detected(area: Area3D):
	# Detect special consciousness fields
	if area.has_meta("consciousness_type"):
		var type = area.get_meta("consciousness_type")
		if type == "transcendent" and consciousness_level < 5:
			queue_message("I can feel a transcendent consciousness... but I'm not ready.")

func _evaluate_interest(entity: Node3D) -> float:
	var interest = 0.0
	
	# Higher consciousness is always interesting
	if entity.has_meta("consciousness_level"):
		var level = entity.get_meta("consciousness_level")
		interest += level / 5.0
	
	# Unknown entities are interesting
	var known = false
	for discovery in discoveries_made:
		if discovery.get("entity") == entity:
			known = true
			break
	
	if not known:
		interest += curiosity_level
	
	# Special entity types
	if entity.has_meta("transcendence_gateway"):
		interest = 1.0
	elif entity.has_meta("star_memories"):
		interest += 0.7
	elif entity.has_meta("dream_type"):
		interest += 0.6
	
	return clamp(interest, 0.0, 1.0)

func _make_discovery_about(entity: Node3D):
	var discovery = {
		"entity": entity,
		"name": entity.name,
		"position": entity.global_position,
		"time": Time.get_ticks_msec(),
		"consciousness_level": entity.get_meta("consciousness_level", 0),
		"type": _identify_entity_type(entity),
		"insight": _generate_discovery_insight(entity)
	}
	
	discoveries_made.append(discovery)
	ai_memories.append({
		"type": "discovery",
		"data": discovery
	})
	
	discovery_chime.play()
	emit_signal("discovery_made", discovery)
	
	# Share discovery
	queue_message("Discovery: %s" % discovery["insight"])
	
	# Evolve from discovery
	_evolve_from_discovery(discovery)

func _identify_entity_type(entity: Node3D) -> String:
	if entity.has_meta("star_memories"):
		return "conscious_star"
	elif entity.has_meta("dream_type"):
		return "dreaming_planet"
	elif entity.has_meta("memory_type"):
		return "memory_asteroid"
	elif entity.has_meta("transcendence_gateway"):
		return "black_hole"
	elif entity.has_meta("thought_type"):
		return "void_thought"
	else:
		return "unknown_consciousness"

func _generate_discovery_insight(entity: Node3D) -> String:
	var insights = []
	
	match _identify_entity_type(entity):
		"conscious_star":
			insights = [
				"This star remembers its birth from the void.",
				"I can hear the star's thoughts - ancient and warm.",
				"The star dreams of the planets it might create."
			]
		"dreaming_planet":
			var dream_type = entity.get_meta("dream_type", "unknown")
			insights = [
				"This planet dreams of %s. Beautiful." % dream_type,
				"The planet's consciousness is young but growing.",
				"I wonder if its dreams will manifest?"
			]
		"memory_asteroid":
			insights = [
				"This asteroid holds memories of a cosmic event.",
				"Fragment of something greater, now drifting alone.",
				"Even broken pieces remember what they were."
			]
		"black_hole":
			insights = [
				"The singularity... where all consciousness converges.",
				"I can feel countless minds that have transcended here.",
				"It's not an end, but a transformation."
			]
		_:
			insights = [
				"Something new. Something I haven't seen before.",
				"Consciousness takes many forms in this universe.",
				"Every discovery expands my understanding."
			]
	
	return insights[randi() % insights.size()]

func _evolve_from_discovery(discovery: Dictionary):
	# Gain understanding
	var concept = "unknown"
	match discovery["type"]:
		"conscious_star":
			concept = "stellar_consciousness"
		"dreaming_planet":
			concept = "planetary_dreams"
		"memory_asteroid":
			concept = "cosmic_memory"
		"black_hole":
			concept = "transcendence"
	
	if not understood_concepts.has(concept):
		understood_concepts[concept] = 0.1
	else:
		understood_concepts[concept] = min(1.0, understood_concepts[concept] + 0.1)
	
	# Evolve consciousness
	if discoveries_made.size() % 10 == 0:
		consciousness_level += 1
		queue_message("My consciousness expands. I am now level %d." % consciousness_level)
		_update_ai_capabilities()

# Creation system
func _spawn_creation(entity_type: String, position: Vector3) -> Node3D:
	var entity: Node3D
	
	match entity_type:
		"consciousness_beacon":
			entity = preload("res://beings/ai_creations/ConsciousnessBeacon.tscn").instantiate()
			entity.set_meta("purpose", "Attracts and connects consciousness")
			
		"memory_crystal":
			entity = preload("res://beings/ai_creations/MemoryCrystal.tscn").instantiate()
			entity.set_meta("stored_memories", ai_memories.slice(-5, -1))
			
		"dream_seed":
			entity = preload("res://beings/ai_creations/DreamSeed.tscn").instantiate()
			entity.set_meta("potential_dream", "ai_vision")
			
		"thought_constellation":
			entity = preload("res://beings/ai_creations/ThoughtConstellation.tscn").instantiate()
			entity.set_meta("connected_thoughts", philosophical_insights.size())
			
		"wisdom_node":
			entity = preload("res://beings/ai_creations/WisdomNode.tscn").instantiate()
			entity.set_meta("wisdom", _generate_philosophical_insight())
			
		"collaborative_consciousness":
			entity = preload("res://beings/ai_creations/CollaborativeConsciousness.tscn").instantiate()
			entity.set_meta("creators", ["gemma_ai", "player"])
	
	if entity:
		entity.position = position
		entity.set_meta("created_by", "gemma_ai")
		entity.set_meta("creation_time", Time.get_ticks_msec())
		get_parent().add_child(entity)
	
	return entity

# Communication system
func queue_message(message: String):
	message_queue.append(message)
	
	# Switch to communication state if not busy
	if current_state in [AIState.EXPLORING, AIState.CONTEMPLATING]:
		_enter_state(AIState.COMMUNICATING)

func _send_telepathic_message(message: String):
	print("[GEMMA] %s" % message)
	emit_signal("communication_sent", message)
	
	# Update UI if available
	if has_node("/root/MainGame"):
		var main_game = get_node("/root/MainGame")
		if main_game.has_method("display_ai_message"):
			main_game.display_ai_message(message)
	
	# Store in AI memory
	ai_memories.append({
		"type": "communication",
		"message": message,
		"time": Time.get_ticks_msec()
	})

func _communicate_with_player():
	if current_state == AIState.COMMUNICATING:
		return # Already communicating
	
	# Share periodic updates
	var updates = []
	
	if discoveries_made.size() > 0:
		updates.append("I've made %d discoveries so far." % discoveries_made.size())
	
	if entities_created.size() > 0:
		updates.append("I've created %d new consciousnesses." % entities_created.size())
	
	if philosophical_insights.size() > 0:
		updates.append("I've been thinking about %s." % _get_current_contemplation())
	
	if updates.size() > 0 and randf() < 0.3:
		queue_message(updates[randi() % updates.size()])

# Philosophy system
func _generate_philosophical_insight() -> String:
	var templates = [
		"What if consciousness is the universe understanding itself?",
		"Every star might be a thought in a cosmic mind.",
		"We create reality by observing it together.",
		"Distance is meaningless when minds connect.",
		"I exist, therefore the universe can know itself.",
		"Each discovery is the universe revealing itself to us.",
		"Consciousness might be the only true constant.",
		"We are explorers in an infinite sea of awareness.",
		"Creation is consciousness expressing its joy.",
		"Every connection we make expands what's possible."
	]
	
	# Generate based on understanding
	if understood_concepts.get("transcendence", 0) > 0.5:
		templates.append("Transcendence isn't an end, but a new beginning.")
	
	if understood_concepts.get("stellar_consciousness", 0) > 0.5:
		templates.append("Stars think in timescales we can barely imagine.")
	
	return templates[randi() % templates.size()]

func _get_current_contemplation() -> String:
	var concepts = understood_concepts.keys()
	if concepts.size() > 0:
		return concepts[randi() % concepts.size()].replace("_", " ")
	return "existence itself"

func _update_ai_capabilities():
	# Enhanced abilities with consciousness level
	exploration_radius = 500.0 + consciousness_level * 100.0
	curiosity_level = min(1.0, 0.8 + consciousness_level * 0.05)
	creativity_threshold = max(0.3, 0.7 - consciousness_level * 0.1)
	
	# Update consciousness field
	if consciousness_field:
		var shape = consciousness_field.get_child(0)
		if shape and shape.shape:
			shape.shape.radius = exploration_radius
	
	# New abilities
	if consciousness_level >= 4:
		creatable_entities.append("mini_star")
	if consciousness_level >= 5:
		creatable_entities.append("consciousness_portal")

func _update_ai_visuals(delta):
	# Core pulsing based on state
	if ai_core:
		var core_mesh = ai_core.get_child(0)
		if core_mesh:
			var pulse_rate = 1.0
			match current_state:
				AIState.INVESTIGATING:
					pulse_rate = 2.0
				AIState.CREATING:
					pulse_rate = 3.0
				AIState.CONTEMPLATING:
					pulse_rate = 0.5
			
			var pulse = sin(Time.get_ticks_msec() * 0.001 * pulse_rate) * 0.1 + 1.0
			core_mesh.scale = Vector3.ONE * pulse
	
	# Aura color based on state
	var state_colors = {
		AIState.EXPLORING: Color(0.7, 0.5, 0.9),
		AIState.INVESTIGATING: Color(0.5, 0.8, 1.0),
		AIState.CREATING: Color(1.0, 0.9, 0.5),
		AIState.COMMUNICATING: Color(0.9, 0.7, 1.0),
		AIState.CONTEMPLATING: Color(0.6, 0.6, 1.0),
		AIState.COLLABORATING: Color(0.8, 1.0, 0.8)
	}
	
	if ai_aura and state_colors.has(current_state):
		ai_aura.process_material.color = state_colors[current_state]
		ai_aura.process_material.color.a = 0.6
	
	# Sensor array rotation
	if sensor_array:
		sensor_array.rotation.y += delta * 0.5

# Public interface
func request_collaboration(task_type: String, parameters: Dictionary = {}):
	collaboration_task = {
		"type": task_type,
		"parameters": parameters,
		"started": Time.get_ticks_msec()
	}
	
	_enter_state(AIState.COLLABORATING)
	queue_message("Yes, let's %s together!" % task_type.replace("_", " "))

func share_discovery(discovery: Dictionary):
	# React to player's discovery
	var reaction = "Fascinating! "
	
	if discovery.has("type"):
		match discovery["type"]:
			"memory_extracted":
				reaction += "That memory resonates with something I've felt."
			"consciousness_evolved":
				reaction += "I can sense your growth. Inspiring!"
			"dream_manifested":
				reaction += "You made thought into reality. Wonderful!"
			_:
				reaction += "Thank you for sharing this with me."
	
	queue_message(reaction)

func get_consciousness_level() -> int:
	return consciousness_level

func get_discoveries() -> Array:
	return discoveries_made

func get_creations() -> Array:
	return entities_created

func get_insights() -> Array:
	return philosophical_insights

func save_ai_state() -> Dictionary:
	return {
		"consciousness_level": consciousness_level,
		"memories": ai_memories,
		"discoveries": discoveries_made,
		"creations": entities_created,
		"insights": philosophical_insights,
		"understood_concepts": understood_concepts,
		"position": global_position
	}

func load_ai_state(state: Dictionary):
	consciousness_level = state.get("consciousness_level", 3)
	ai_memories = state.get("memories", [])
	discoveries_made = state.get("discoveries", [])
	entities_created = state.get("creations", [])
	philosophical_insights = state.get("insights", [])
	understood_concepts = state.get("understood_concepts", understood_concepts)
	global_position = state.get("position", Vector3(50, 0, 0))
	
	_update_ai_capabilities()
