# ==================================================
# CONSCIOUSNESS FEEDBACK SYSTEM
# PURPOSE: Make consciousness evolution FEEL magical for human player
# ARCHITECTURE: Visual particles, auras, environmental reactions
# ==================================================

extends Node
class_name ConsciousnessFeedbackSystem

# Particle effects
var consciousness_particles: GPUParticles3D
var evolution_particles: GPUParticles3D
var interaction_beam: MeshInstance3D

# Visual enhancement references
var camera_ref: Camera3D
var environment_ref: Environment

# Sound system
var audio_player: AudioStreamPlayer3D

# Effect library
var particle_materials: Dictionary = {}
var consciousness_sounds: Dictionary = {}

signal consciousness_evolved(being: UniversalBeing, new_level: int)
signal beings_merged(being_a: UniversalBeing, being_b: UniversalBeing)
signal narrative_moment(event_data: Dictionary)

func _ready() -> void:
	print("🌟 Consciousness Feedback System: Initializing visual magic...")
	setup_particle_systems()
	setup_audio_system()
	setup_environmental_effects()
	connect_to_universal_beings()

func setup_particle_systems() -> void:
	"""Create consciousness particle effects"""
	
	# Main consciousness particles
	consciousness_particles = GPUParticles3D.new()
	consciousness_particles.emitting = false
	consciousness_particles.amount = 1000
	consciousness_particles.lifetime = 3.0
	add_child(consciousness_particles)
	
	# Evolution celebration particles  
	evolution_particles = GPUParticles3D.new()
	evolution_particles.emitting = false
	evolution_particles.amount = 500
	evolution_particles.lifetime = 2.0
	add_child(evolution_particles)
	
	# Create particle materials for different consciousness levels
	create_consciousness_materials()
	
	print("✨ Particle systems ready")

func create_consciousness_materials() -> void:
	"""Create materials for different consciousness levels"""
	
	var levels = {
		0: {"color": Color.GRAY, "name": "dormant"},
		1: {"color": Color(0.9, 0.9, 0.9), "name": "awakening"},
		2: {"color": Color(0.2, 0.4, 1.0), "name": "aware"},
		3: {"color": Color(0.2, 1.0, 0.2), "name": "connected"},
		4: {"color": Color(1.0, 0.84, 0.0), "name": "enlightened"},
		5: {"color": Color.WHITE, "name": "transcendent"},
		6: {"color": Color(1.0, 0.2, 0.2), "name": "beyond"},
		7: {"color": Color(0.8, 0.3, 1.0), "name": "universal"}
	}
	
	for level in levels:
		var material = ParticleProcessMaterial.new()
		var data = levels[level]
		
		material.direction = Vector3(0, 1, 0)
		material.initial_velocity_min = 1.0
		material.initial_velocity_max = 3.0
		material.gravity = Vector3(0, -2.0, 0)
		material.scale_min = 0.1
		material.scale_max = 0.3
		material.color = data.color
		
		# Higher consciousness = more ethereal
		if level >= 5:
			material.gravity = Vector3(0, 0.5, 0)  # Float upward
			material.scale_max = 0.5
		
		particle_materials[level] = material
		print("✨ Created %s consciousness material" % data.name)

func setup_audio_system() -> void:
	"""Setup consciousness evolution sounds"""
	
	audio_player = AudioStreamPlayer3D.new()
	audio_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	audio_player.max_distance = 50.0
	add_child(audio_player)
	
	# Load consciousness sounds (you'd need actual audio files)
	consciousness_sounds = {
		0: "res://akashic_library/sounds/consciousness/dormant.ogg",
		1: "res://akashic_library/sounds/consciousness/awakening.ogg", 
		2: "res://akashic_library/sounds/consciousness/aware.ogg",
		3: "res://akashic_library/sounds/consciousness/connected.ogg",
		4: "res://akashic_library/sounds/consciousness/enlightened.ogg",
		5: "res://akashic_library/sounds/consciousness/transcendent.ogg",
		6: "res://akashic_library/sounds/consciousness/beyond.ogg",
		7: "res://akashic_library/sounds/consciousness/universal.ogg"
	}
	
	print("🎵 Consciousness audio system ready")

func setup_environmental_effects() -> void:
	"""Setup environment that reacts to consciousness"""
	
	# Find camera and environment
	camera_ref = get_viewport().get_camera_3d()
	
	var env_node = get_tree().current_scene.get_node_or_null("PerfectEnvironment")
	if env_node and env_node is WorldEnvironment:
		environment_ref = env_node.environment
	
	print("🌍 Environmental reaction system ready")

func connect_to_universal_beings() -> void:
	"""Connect to existing Universal Beings for consciousness changes"""
	
	# Connect to all Universal Beings in scene
	var beings = get_tree().get_nodes_in_group("universal_beings")
	for being in beings:
		if being.has_signal("consciousness_changed"):
			being.consciousness_changed.connect(_on_being_consciousness_changed.bind(being))
		if being.has_signal("being_evolved"):
			being.being_evolved.connect(_on_being_evolved.bind(being))
	
	print("🔗 Connected to %d Universal Beings" % beings.size())

func emit_consciousness_particles(being: UniversalBeing, level: int) -> void:
	"""Emit particles when consciousness changes"""
	
	if not particle_materials.has(level):
		level = 0  # Fallback
	
	# Position particles at being
	consciousness_particles.global_position = being.global_position
	consciousness_particles.process_material = particle_materials[level]
	
	# Adjust particle count based on level
	consciousness_particles.amount = 100 + (level * 100)
	
	# Start emission
	consciousness_particles.restart()
	consciousness_particles.emitting = true
	
	# Stop after a moment
	await get_tree().create_timer(1.0).timeout
	consciousness_particles.emitting = false
	
	print("✨ Consciousness particles emitted for level %d" % level)

func camera_shake(duration: float, intensity: float) -> void:
	"""Shake camera for consciousness evolution impact"""
	
	if not camera_ref:
		return
	
	var original_position = camera_ref.global_position
	var shake_timer = 0.0
	
	while shake_timer < duration:
		var shake_offset = Vector3(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity), 
			randf_range(-intensity, intensity)
		)
		
		camera_ref.global_position = original_position + shake_offset
		shake_timer += get_process_delta_time()
		await get_tree().process_frame
	
	# Restore original position
	camera_ref.global_position = original_position
	
	print("📳 Camera shake complete")

func play_evolution_sound(level: int) -> void:
	"""Play sound for consciousness evolution"""
	
	if consciousness_sounds.has(level):
		var sound_path = consciousness_sounds[level]
		if ResourceLoader.exists(sound_path):
			var stream = load(sound_path)
			audio_player.stream = stream
			audio_player.play()
			print("🎵 Playing evolution sound for level %d" % level)

func create_interaction_beam(from_being: UniversalBeing, to_being: UniversalBeing) -> void:
	"""Create visual beam between interacting beings"""
	
	var beam = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	
	# Calculate beam direction and length
	var direction = to_being.global_position - from_being.global_position
	var length = direction.length()
	
	cylinder.top_radius = 0.05
	cylinder.bottom_radius = 0.05
	cylinder.height = length
	beam.mesh = cylinder
	
	# Position beam
	beam.global_position = from_being.global_position + direction * 0.5
	beam.look_at(to_being.global_position, Vector3.UP)
	
	# Create glowing material
	var material = StandardMaterial3D.new()
	material.emission_enabled = true
	material.emission = Color(0.5, 0.8, 1.0)
	material.emission_energy = 2.0
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.3, 0.7, 1.0, 0.6)
	beam.material_override = material
	
	get_tree().current_scene.add_child(beam)
	
	# Animate and cleanup
	var tween = create_tween()
	tween.tween_property(material, "emission_energy", 0.0, 1.0)
	tween.tween_callback(beam.queue_free)
	
	print("⚡ Interaction beam created")

func react_environment_to_consciousness(being: UniversalBeing, level: int) -> void:
	"""Make environment react to high consciousness"""
	
	if not environment_ref:
		return
	
	match level:
		5, 6, 7:  # Transcendent levels
			# Brighten ambient light
			var original_energy = environment_ref.ambient_light_energy
			var tween = create_tween()
			tween.tween_property(environment_ref, "ambient_light_energy", 
				original_energy * 1.5, 2.0)
			tween.tween_property(environment_ref, "ambient_light_energy", 
				original_energy, 3.0)
			
			# Enhance glow
			if environment_ref.glow_enabled:
				tween.parallel().tween_property(environment_ref, "glow_intensity", 
					environment_ref.glow_intensity * 1.3, 2.0)
				tween.parallel().tween_property(environment_ref, "glow_intensity", 
					environment_ref.glow_intensity, 3.0)
			
			print("🌟 Environment reacting to transcendent consciousness")

func trigger_narrative_moment(event_data: Dictionary) -> void:
	"""Trigger a narrative moment with visual/audio cues"""
	
	var title = event_data.get("title", "Consciousness Event")
	var description = event_data.get("description", "Something profound happened...")
	
	# Focus camera if specified
	if event_data.has("camera_focus") and camera_ref:
		var focus_target = event_data.camera_focus
		if focus_target is Node3D:
			# Smooth camera movement toward target
			var tween = create_tween()
			tween.tween_method(_smooth_camera_look_at, 
				camera_ref.global_position, 
				focus_target.global_position, 2.0)
	
	# Environmental shift
	if event_data.has("ambient_shift"):
		match event_data.ambient_shift:
			"ethereal":
				react_environment_to_consciousness(null, 7)
			"mystical":
				react_environment_to_consciousness(null, 5)
	
	# Emit signal for UI/narrative system
	narrative_moment.emit(event_data)
	
	print("📖 Narrative moment: %s" % title)

func _smooth_camera_look_at(start_pos: Vector3, target_pos: Vector3, weight: float) -> void:
	"""Smoothly orient camera toward target"""
	if camera_ref:
		var look_direction = start_pos.lerp(target_pos, weight)
		camera_ref.look_at(look_direction, Vector3.UP)

# ===== SIGNAL HANDLERS =====

func _on_being_consciousness_changed(being: UniversalBeing, new_level: int) -> void:
	"""Handle consciousness evolution of a being"""
	
	# Visual celebration
	emit_consciousness_particles(being, new_level)
	
	# Camera shake for major evolutions
	if new_level >= 5:
		camera_shake(0.3, new_level * 0.05)
	
	# Play evolution sound
	play_evolution_sound(new_level)
	
	# Environmental reaction
	react_environment_to_consciousness(being, new_level)
	
	# Emit signal
	consciousness_evolved.emit(being, new_level)
	
	print("🌟 Consciousness feedback for %s evolving to level %d" % [being.name, new_level])

func _on_being_evolved(being: UniversalBeing, old_form: String, new_form: String) -> void:
	"""Handle being evolution (form change)"""
	
	# Major celebration for form evolution
	emit_consciousness_particles(being, being.consciousness_level)
	camera_shake(0.5, 0.2)
	
	# Environmental reaction
	react_environment_to_consciousness(being, being.consciousness_level + 1)
	
	# Trigger narrative moment
	trigger_narrative_moment({
		"title": "Evolution",
		"description": "%s evolved from %s to %s!" % [being.name, old_form, new_form],
		"camera_focus": being,
		"ambient_shift": "mystical"
	})
	
	print("🦋 Evolution feedback: %s → %s" % [old_form, new_form])

# ===== PUBLIC API =====

func create_interaction_feedback(being_a: UniversalBeing, being_b: UniversalBeing) -> void:
	"""Create feedback for being interaction"""
	create_interaction_beam(being_a, being_b)

func celebrate_consciousness_milestone(being: UniversalBeing, milestone: String) -> void:
	"""Celebrate special consciousness achievements"""
	
	trigger_narrative_moment({
		"title": milestone,
		"description": "%s has achieved %s!" % [being.name, milestone],
		"camera_focus": being,
		"ambient_shift": "ethereal"
	})

print("🌟 Consciousness Feedback System: Visual magic ready!")