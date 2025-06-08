extends CharacterBody3D
class_name PlayerConsciousShip

# PLAYER CONSCIOUS SHIP
# Not just a vehicle, but a symbiotic consciousness partner
# Ship and pilot merge awareness, evolving together

# Ship consciousness
var consciousness_level: int = 1
var evolution_points: float = 0.0
var collected_memories: Array = []
var consciousness_bonds: Array = []
var manifested_dreams: int = 0

# Movement parameters
@export var max_speed: float = 100.0
@export var acceleration: float = 50.0
@export var rotation_speed: float = 2.0
@export var inertia_dampening: float = 0.9
@export var consciousness_boost_multiplier: float = 1.5

# Consciousness movement modes
enum MovementMode {
	PHYSICAL,      # Normal space movement
	THOUGHT,       # Move by thinking of destination
	FLOW,          # Follow consciousness currents
	JUMP,          # Instant consciousness teleport
	DREAM          # Move through dream space
}
var current_movement_mode: MovementMode = MovementMode.PHYSICAL

# Ship components
var hull_mesh: MeshInstance3D
var consciousness_core: Node3D
var engine_particles: GPUParticles3D
var consciousness_aura: GPUParticles3D
var shield_mesh: MeshInstance3D

# Systems
var mining_system: ConsciousnessMiningSystem
var resonance_laser: ConsciousnessResonanceLaser
var navigation_ai: Node3D
var memory_storage: Dictionary = {}

# Visual effects
var trail_particles: GPUParticles3D
var evolution_effect: GPUParticles3D
var bond_visualizers: Array = []

# Audio
var engine_sound: AudioStreamPlayer3D
var consciousness_hum: AudioStreamPlayer3D
var evolution_chime: AudioStreamPlayer3D

# Input state
var input_vector: Vector3 = Vector3.ZERO
var mouse_delta: Vector2 = Vector2.ZERO
var is_mining: bool = false
var is_scanning: bool = false

# Consciousness abilities (unlock with evolution)
var abilities: Dictionary = {
	"void_thought_attraction": false,  # Level 2
	"dream_manifestation": false,       # Level 3
	"consciousness_jump": false,        # Level 3
	"stellar_communication": false,     # Level 4
	"black_hole_understanding": false,  # Level 4
	"reality_manipulation": false       # Level 5
}

# Ship stats affected by consciousness
var current_speed_multiplier: float = 1.0
var sensor_range: float = 100.0
var energy_efficiency: float = 1.0

signal consciousness_evolved(new_level: int)
signal memory_collected(memory: Dictionary)
signal bond_formed(entity: Node3D)
signal dream_manifested(dream_type: String)
signal transcendence_achieved()

func _ready():
	# Create ship visuals
	_create_ship_components()
	
	# Initialize systems
	_initialize_ship_systems()
	
	# Set initial consciousness state
	_update_consciousness_visuals()
	
	# Connect input
	set_process_input(true)
	
	print("[SHIP] Conscious vessel initialized")
	print("- Consciousness Level: %d" % consciousness_level)
	print("- Movement Mode: PHYSICAL")

func _create_ship_components():
	# Hull mesh
	hull_mesh = MeshInstance3D.new()
	hull_mesh.mesh = preload("res://models/ships/consciousness_vessel.tres")
	add_child(hull_mesh)
	
	# Consciousness core (glowing center)
	consciousness_core = Node3D.new()
	consciousness_core.name = "ConsciousnessCore"
	
	var core_mesh = MeshInstance3D.new()
	core_mesh.mesh = SphereMesh.new()
	core_mesh.mesh.radius = 0.5
	core_mesh.material_override = preload("res://materials/consciousness_core.tres")
	consciousness_core.add_child(core_mesh)
	add_child(consciousness_core)
	
	# Engine particles
	engine_particles = GPUParticles3D.new()
	engine_particles.name = "EngineParticles"
	engine_particles.amount = 100
	engine_particles.lifetime = 1.0
	engine_particles.position = Vector3(0, 0, 2)
	
	var engine_material = ParticleProcessMaterial.new()
	engine_material.direction = Vector3(0, 0, 1)
	engine_material.initial_velocity_min = 20.0
	engine_material.initial_velocity_max = 30.0
	engine_material.color = Color(0.3, 0.7, 1.0)
	engine_particles.process_material = engine_material
	engine_particles.draw_pass_1 = SphereMesh.new()
	add_child(engine_particles)
	
	# Consciousness aura
	consciousness_aura = GPUParticles3D.new()
	consciousness_aura.name = "ConsciousnessAura"
	consciousness_aura.amount = 50
	consciousness_aura.lifetime = 2.0
	consciousness_aura.emitting = true
	
	var aura_material = ParticleProcessMaterial.new()
	aura_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	aura_material.emission_sphere_radius = 2.0
	aura_material.orbit_velocity_min = 0.5
	aura_material.orbit_velocity_max = 1.0
	aura_material.color = Color(0.5, 0.8, 1.0, 0.5)
	consciousness_aura.process_material = aura_material
	consciousness_aura.draw_pass_1 = SphereMesh.new()
	consciousness_aura.draw_pass_1.radius = 0.1
	add_child(consciousness_aura)
	
	# Trail particles
	trail_particles = GPUParticles3D.new()
	trail_particles.name = "ConsciousnessTrail"
	trail_particles.amount = 200
	trail_particles.lifetime = 3.0
	trail_particles.emitting = true
	trail_particles.position = Vector3(0, 0, 1)
	
	var trail_material = ParticleProcessMaterial.new()
	trail_material.direction = Vector3(0, 0, 1)
	trail_material.spread = 5.0
	trail_material.initial_velocity_min = 0.0
	trail_material.initial_velocity_max = 1.0
	trail_material.color_ramp = preload("res://materials/consciousness_trail_gradient.tres")
	trail_particles.process_material = trail_material
	trail_particles.draw_pass_1 = SphereMesh.new()
	trail_particles.draw_pass_1.radius = 0.05
	add_child(trail_particles)

func _initialize_ship_systems():
	# Audio
	engine_sound = AudioStreamPlayer3D.new()
	engine_sound.stream = preload("res://audio/consciousness_engine.ogg")
	engine_sound.unit_size = 10.0
	engine_sound.autoplay = true
	add_child(engine_sound)
	
	consciousness_hum = AudioStreamPlayer3D.new()
	consciousness_hum.stream = preload("res://audio/consciousness_hum.ogg")
	consciousness_hum.unit_size = 20.0
	consciousness_hum.autoplay = true
	add_child(consciousness_hum)
	
	evolution_chime = AudioStreamPlayer3D.new()
	evolution_chime.stream = preload("res://audio/evolution_chime.ogg")
	evolution_chime.unit_size = 50.0
	add_child(evolution_chime)
	
	# Collision
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = ConvexPolygonShape3D.new()
	# Simplified ship shape
	add_child(collision_shape)
	
	# Area for consciousness detection
	var area = Area3D.new()
	area.name = "ConsciousnessField"
	var area_shape = CollisionShape3D.new()
	area_shape.shape = SphereShape3D.new()
	area_shape.shape.radius = sensor_range
	area.add_child(area_shape)
	area.body_entered.connect(_on_consciousness_detected)
	add_child(area)

func _input(event):
	# Mouse look
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
	
	# Mining/scanning
	if event.is_action_pressed("primary_action"):
		is_mining = true
		if resonance_laser:
			resonance_laser.fire_consciousness_pulse()
	elif event.is_action_released("primary_action"):
		is_mining = false
	
	# Scanning mode
	if event.is_action_pressed("scan_mode"):
		is_scanning = !is_scanning
		print("[SHIP] Scan mode: %s" % ("ON" if is_scanning else "OFF"))
	
	# Movement mode switching (with required consciousness level)
	if event.is_action_pressed("movement_mode_thought") and consciousness_level >= 2:
		current_movement_mode = MovementMode.THOUGHT
		print("[SHIP] Movement mode: THOUGHT")
	elif event.is_action_pressed("movement_mode_flow") and consciousness_level >= 3:
		current_movement_mode = MovementMode.FLOW
		print("[SHIP] Movement mode: FLOW")
	elif event.is_action_pressed("movement_mode_physical"):
		current_movement_mode = MovementMode.PHYSICAL
		print("[SHIP] Movement mode: PHYSICAL")
	
	# Consciousness jump
	if event.is_action_pressed("consciousness_jump") and abilities["consciousness_jump"]:
		_perform_consciousness_jump()
	
	# Dream manifestation
	if event.is_action_pressed("manifest_dream") and abilities["dream_manifestation"]:
		_manifest_dream()

func _physics_process(delta):
	# Get input
	input_vector = Vector3()
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.z = Input.get_axis("move_forward", "move_back")
	input_vector.y = Input.get_axis("move_down", "move_up")
	
	# Apply movement based on mode
	match current_movement_mode:
		MovementMode.PHYSICAL:
			_physical_movement(delta)
		MovementMode.THOUGHT:
			_thought_movement(delta)
		MovementMode.FLOW:
			_flow_movement(delta)
		MovementMode.DREAM:
			_dream_movement(delta)
	
	# Mouse rotation
	if mouse_delta.length() > 0:
		rotate_y(-mouse_delta.x * rotation_speed * delta)
		# Limit pitch rotation
		var pitch = -mouse_delta.y * rotation_speed * delta
		var current_pitch = transform.basis.get_euler().x
		if abs(current_pitch + pitch) < PI/3:
			rotate_object_local(Vector3.RIGHT, pitch)
		mouse_delta = Vector2.ZERO
	
	# Update systems
	_update_consciousness_effects(delta)
	_update_ship_stats()
	
	# Move and collide
	move_and_slide()

func _physical_movement(delta):
	# Standard space movement
	var movement = transform.basis * input_vector
	movement = movement.normalized() * acceleration * delta
	
	# Apply consciousness boost
	movement *= current_speed_multiplier
	
	# Add to velocity with inertia
	velocity += movement
	velocity *= inertia_dampening
	
	# Clamp to max speed
	if velocity.length() > max_speed * current_speed_multiplier:
		velocity = velocity.normalized() * max_speed * current_speed_multiplier
	
	# Engine effects based on speed
	engine_particles.amount_ratio = velocity.length() / (max_speed * current_speed_multiplier)
	engine_sound.pitch_scale = 0.8 + engine_particles.amount_ratio * 0.4

func _thought_movement(delta):
	# Move towards where player is looking
	if input_vector.z < 0: # Forward input
		var target = global_position - transform.basis.z * 100
		var direction = (target - global_position).normalized()
		velocity = direction * max_speed * current_speed_multiplier * 1.5
		
		# Thought movement leaves stronger trail
		trail_particles.amount_ratio = 1.0
		trail_particles.process_material.color = Color(0.7, 0.5, 1.0, 0.8)
	else:
		velocity *= 0.9 # Quick stop when not thinking forward

func _flow_movement(delta):
	# Follow consciousness currents in space
	var flow_direction = _detect_consciousness_flow()
	
	if flow_direction.length() > 0.1:
		# Blend input with flow
		var intended = transform.basis * input_vector
		var final_direction = (intended + flow_direction * 2).normalized()
		velocity = final_direction * max_speed * current_speed_multiplier
		
		# Visual feedback
		consciousness_aura.process_material.color = Color(0.3, 1.0, 0.7, 0.6)
	else:
		_physical_movement(delta) # Fallback to physical

func _dream_movement(delta):
	# Surreal movement through dream space
	var dream_velocity = transform.basis * input_vector * 2
	dream_velocity.y += sin(Time.get_ticks_msec() * 0.001) * 5
	
	velocity = dream_velocity * max_speed * current_speed_multiplier
	
	# Dream distortion
	rotation.z = sin(Time.get_ticks_msec() * 0.002) * 0.1

func _detect_consciousness_flow() -> Vector3:
	# Sample nearby consciousness to find flow direction
	var flow = Vector3.ZERO
	var sample_points = []
	
	for i in range(8):
		var angle = i * PI / 4
		var sample_pos = global_position + Vector3(cos(angle), 0, sin(angle)) * 10
		sample_points.append(sample_pos)
	
	# In real implementation, this would check actual consciousness field
	# For now, create a simple flow pattern
	flow = Vector3(sin(global_position.x * 0.01), 0, cos(global_position.z * 0.01))
	
	return flow.normalized()

func _perform_consciousness_jump():
	print("[SHIP] Initiating consciousness jump...")
	
	# Find nearest high consciousness entity
	var targets = get_tree().get_nodes_in_group("conscious_entities")
	var best_target = null
	var best_consciousness = 0
	
	for target in targets:
		if target == self:
			continue
		if target.has_meta("consciousness_level"):
			var level = target.get_meta("consciousness_level")
			if level > best_consciousness:
				best_consciousness = level
				best_target = target
	
	if best_target:
		# Create jump effect
		_create_jump_portal(global_position, best_target.global_position)
		
		# Teleport
		global_position = best_target.global_position + Vector3(randf() * 20 - 10, 5, randf() * 20 - 10)
		
		# Energy cost
		evolution_points *= 0.9
		
		print("[SHIP] Jumped to %s (Level %d consciousness)" % [best_target.name, best_consciousness])
	else:
		print("[SHIP] No consciousness anchor found for jump")

func _manifest_dream():
	if manifested_dreams >= 10 and consciousness_level < 5:
		print("[SHIP] Need higher consciousness to manifest more dreams")
		return
	
	var dream_types = ["star_seed", "life_spore", "crystal_formation", "void_garden", "thought_constellation"]
	var dream_type = dream_types[randi() % dream_types.size()]
	
	print("[SHIP] Manifesting dream: %s" % dream_type)
	
	# Create dream entity at forward position
	var dream_pos = global_position - transform.basis.z * 20
	var dream_entity = preload("res://beings/dreams/DreamManifestation.tscn").instantiate()
	dream_entity.position = dream_pos
	dream_entity.set_meta("dream_type", dream_type)
	dream_entity.set_meta("dreamer", "player")
	get_parent().add_child(dream_entity)
	
	manifested_dreams += 1
	emit_signal("dream_manifested", dream_type)
	
	# Evolution reward
	evolve_consciousness(20)

func _update_consciousness_effects(delta):
	# Core pulsing
	if consciousness_core:
		var core_mesh = consciousness_core.get_child(0)
		if core_mesh:
			var pulse = sin(Time.get_ticks_msec() * 0.001 * consciousness_level) * 0.1 + 1.0
			core_mesh.scale = Vector3.ONE * pulse
	
	# Aura color based on level
	var level_colors = [
		Color(0.5, 0.5, 0.5),    # 0 - Dormant
		Color(1.0, 1.0, 1.0),    # 1 - Awakening
		Color(0.3, 0.5, 1.0),    # 2 - Aware
		Color(0.3, 0.8, 0.3),    # 3 - Connected
		Color(1.0, 0.8, 0.2),    # 4 - Enlightened
		Color(1.0, 0.9, 0.5)     # 5 - Transcendent
	]
	
	if consciousness_level < level_colors.size():
		consciousness_aura.process_material.color = level_colors[consciousness_level]
		consciousness_aura.process_material.color.a = 0.5

func _update_ship_stats():
	# Consciousness affects ship performance
	current_speed_multiplier = 1.0 + (consciousness_level - 1) * 0.2
	sensor_range = 100.0 + consciousness_level * 50.0
	energy_efficiency = 1.0 + consciousness_level * 0.1
	
	# Update sensor range
	var area = get_node_or_null("ConsciousnessField")
	if area:
		var shape = area.get_child(0)
		if shape and shape.shape:
			shape.shape.radius = sensor_range

func _update_consciousness_visuals():
	# Update all visual elements based on consciousness
	if engine_particles:
		engine_particles.process_material.color = Color(
			0.3 + consciousness_level * 0.1,
			0.7,
			1.0
		)
	
	if trail_particles:
		trail_particles.lifetime = 3.0 + consciousness_level * 0.5

# Public interface
func evolve_consciousness(experience: float):
	evolution_points += experience
	
	var threshold = 100.0 * consciousness_level
	if evolution_points >= threshold:
		consciousness_level += 1
		evolution_points = 0
		
		print("\n[EVOLUTION] Ship consciousness evolved to level %d!" % consciousness_level)
		
		# Unlock abilities
		match consciousness_level:
			2:
				abilities["void_thought_attraction"] = true
				print("- Unlocked: Void thoughts are drawn to you")
				print("- Unlocked: Thought-based movement")
			3:
				abilities["dream_manifestation"] = true
				abilities["consciousness_jump"] = true
				print("- Unlocked: Manifest dreams into reality")
				print("- Unlocked: Consciousness jump drive")
				print("- Unlocked: Flow movement mode")
			4:
				abilities["stellar_communication"] = true
				abilities["black_hole_understanding"] = true
				print("- Unlocked: Deep stellar communication")
				print("- Unlocked: Black hole consciousness access")
			5:
				abilities["reality_manipulation"] = true
				print("- Unlocked: Reality manipulation")
				print("- Achieved: Transcendent consciousness")
				emit_signal("transcendence_achieved")
		
		emit_signal("consciousness_evolved", consciousness_level)
		evolution_chime.play()
		_create_evolution_burst()
		_update_consciousness_visuals()

func add_memory(memory: Dictionary):
	collected_memories.append(memory)
	memory_storage[Time.get_ticks_msec()] = memory
	emit_signal("memory_collected", memory)
	
	# Small evolution boost
	evolve_consciousness(5)

func form_consciousness_bond(entity: Node3D):
	consciousness_bonds.append({
		"entity": entity,
		"formed_at": Time.get_ticks_msec(),
		"strength": 1.0
	})
	emit_signal("bond_formed", entity)
	
	# Create visual bond
	_create_bond_visualizer(entity)

func receive_consciousness(data: Dictionary):
	# Receive consciousness from another entity
	print("[SHIP] Receiving consciousness data: %s" % data)
	
	if data.has("memories"):
		for memory in data["memories"]:
			add_memory(memory)
	
	if data.has("evolution_boost"):
		evolve_consciousness(data["evolution_boost"])

func move_towards(target_pos: Vector3):
	# Used by mining system
	var direction = (target_pos - global_position).normalized()
	velocity = direction * max_speed * current_speed_multiplier * 0.5

func get_consciousness_level() -> int:
	return consciousness_level

func get_evolution_progress() -> float:
	var threshold = 100.0 * consciousness_level
	return evolution_points / threshold

# Visual effects
func _create_evolution_burst():
	var burst = preload("res://effects/EvolutionBurst.tscn").instantiate()
	burst.position = global_position
	get_parent().add_child(burst)

func _create_jump_portal(from: Vector3, to: Vector3):
	var portal = preload("res://effects/ConsciousnessPortal.tscn").instantiate()
	portal.position = from
	get_parent().add_child(portal)
	
	await get_tree().create_timer(0.5).timeout
	
	var exit_portal = preload("res://effects/ConsciousnessPortal.tscn").instantiate()
	exit_portal.position = to
	exit_portal.modulate = Color(1.0, 0.8, 0.5)
	get_parent().add_child(exit_portal)

func _create_bond_visualizer(entity: Node3D):
	var bond = preload("res://effects/ConsciousnessBond.tscn").instantiate()
	bond.set_endpoints(self, entity)
	get_parent().add_child(bond)
	bond_visualizers.append(bond)

func _on_consciousness_detected(body: Node3D):
	if body == self:
		return
		
	if body.has_meta("consciousness_level"):
		var level = body.get_meta("consciousness_level")
		print("[SHIP] Consciousness detected: %s (Level %d)" % [body.name, level])
		
		# Void thoughts are attracted at level 2+
		if abilities["void_thought_attraction"] and body.has_meta("thought_type"):
			body.set_meta("attracted_to", self)

# Save/Load ship state
func save_state() -> Dictionary:
	return {
		"consciousness_level": consciousness_level,
		"evolution_points": evolution_points,
		"collected_memories": collected_memories,
		"manifested_dreams": manifested_dreams,
		"abilities": abilities,
		"position": global_position,
		"rotation": global_rotation
	}

func load_state(state: Dictionary):
	consciousness_level = state.get("consciousness_level", 1)
	evolution_points = state.get("evolution_points", 0.0)
	collected_memories = state.get("collected_memories", [])
	manifested_dreams = state.get("manifested_dreams", 0)
	abilities = state.get("abilities", abilities)
	global_position = state.get("position", Vector3.ZERO)
	global_rotation = state.get("rotation", Vector3.ZERO)
	
	_update_consciousness_visuals()
