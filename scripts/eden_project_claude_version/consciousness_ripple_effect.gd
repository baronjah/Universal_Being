# Consciousness Ripple Effect
# When consciousness interacts deeply, reality itself ripples
extends Node3D

# Ripple parameters
@export var ripple_radius: float = 10.0
@export var ripple_speed: float = 5.0
@export var ripple_lifetime: float = 3.0
@export var ripple_color: Color = Color(0.7, 0.8, 1.0, 1.0)
@export var affect_crystals: bool = true
@export var affect_reality: bool = true

# Ripple state
var ripple_time: float = 0.0
var origin_point: Vector3 = Vector3.ZERO
var ripple_strength: float = 1.0
var affected_nodes: Array[Node3D] = []

# Visual components
var ripple_mesh: MeshInstance3D
var ripple_particles: GPUParticles3D
var distortion_field: Area3D

# Audio component for the ripple sound
var ripple_audio: AudioStreamPlayer3D

func _ready() -> void:
	origin_point = global_position
	_create_ripple_visualization()
	_create_particle_burst()
	_create_distortion_field()
	_create_ripple_audio()
	_begin_ripple()

func _create_ripple_visualization() -> void:
	# Create expanding ring mesh
	ripple_mesh = MeshInstance3D.new()
	
	# Use a torus for the ring
	var torus = TorusMesh.new()
	torus.inner_radius = 0.8
	torus.outer_radius = 1.0
	torus.rings = 32
	torus.ring_segments = 16
	ripple_mesh.mesh = torus
	
	# Ripple material with transparency
	var material = StandardMaterial3D.new()
	material.albedo_color = ripple_color
	material.emission_enabled = true
	material.emission = ripple_color
	material.emission_energy = 2.0
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.alpha_scissor_threshold = 0.1
	material.no_depth_test = true
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	# Add fresnel for ethereal look
	material.rim_enabled = true
	material.rim = 1.0
	material.rim_tint = 0.5
	
	ripple_mesh.material_override = material
	ripple_mesh.scale = Vector3.ZERO
	add_child(ripple_mesh)

func _create_particle_burst() -> void:
	# Particles that scatter from ripple origin
	ripple_particles = GPUParticles3D.new()
	ripple_particles.amount = 100
	ripple_particles.lifetime = ripple_lifetime
	ripple_particles.one_shot = true
	ripple_particles.emitting = false
	
	var particle_mat = ParticleProcessMaterial.new()
	particle_mat.direction = Vector3(0, 1, 0)
	particle_mat.initial_velocity_min = 2.0
	particle_mat.initial_velocity_max = 8.0
	particle_mat.angular_velocity_min = -720.0
	particle_mat.angular_velocity_max = 720.0
	particle_mat.spread = 180.0  # Full sphere
	particle_mat.flatness = 0.0
	particle_mat.gravity = Vector3.ZERO  # No gravity in consciousness space
	
	# Size over lifetime
	var scale_curve = Curve.new()
	scale_curve.add_point(Vector2(0.0, 0.0))
	scale_curve.add_point(Vector2(0.1, 1.0))
	scale_curve.add_point(Vector2(0.9, 0.8))
	scale_curve.add_point(Vector2(1.0, 0.0))
	particle_mat.scale_curve = scale_curve
	
	# Alpha fade
	var alpha_curve = Curve.new()
	alpha_curve.add_point(Vector2(0.0, 1.0))
	alpha_curve.add_point(Vector2(0.5, 0.8))
	alpha_curve.add_point(Vector2(1.0, 0.0))
	particle_mat.alpha_curve = alpha_curve
	
	particle_mat.color = ripple_color
	
	ripple_particles.process_material = particle_mat
	
	# Small sphere particles
	var sphere = SphereMesh.new()
	sphere.radial_segments = 4
	sphere.height = 0.1
	sphere.radius = 0.05
	ripple_particles.draw_pass_1 = sphere
	
	add_child(ripple_particles)

func _create_distortion_field() -> void:
	# Area that affects nearby objects
	distortion_field = Area3D.new()
	var collision = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 0.1  # Starts small
	collision.shape = sphere_shape
	distortion_field.add_child(collision)
	
	# Monitor for entering nodes
	distortion_field.body_entered.connect(_on_body_entered_field)
	distortion_field.area_entered.connect(_on_area_entered_field)
	
	add_child(distortion_field)

func _create_ripple_audio() -> void:
	ripple_audio = AudioStreamPlayer3D.new()
	ripple_audio.unit_size = 20.0
	ripple_audio.max_distance = 50.0
	ripple_audio.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
	
	# Create resonance sound
	var audio_stream = AudioStreamGenerator.new()
	audio_stream.mix_rate = 44100
	audio_stream.buffer_length = 0.5
	
	ripple_audio.stream = audio_stream
	ripple_audio.volume_db = 0.0
	ripple_audio.pitch_scale = 1.0 + randf_range(-0.1, 0.1)  # Slight variation
	
	add_child(ripple_audio)

func _begin_ripple() -> void:
	# Start the ripple effect
	ripple_particles.emitting = true
	ripple_audio.play()
	
	# Generate the ripple tone
	_generate_ripple_sound()
	
	# Find all crystals in scene to potentially affect
	var all_crystals = get_tree().get_nodes_in_group("thought_crystals")
	for crystal in all_crystals:
		if crystal is Node3D:
			var distance = global_position.distance_to(crystal.global_position)
			if distance < ripple_radius * 2:  # Potential to be affected
				affected_nodes.append(crystal)

func _generate_ripple_sound() -> void:
	# This would generate actual audio data
	# For now, using the audio player as a spatial marker
	# In full implementation, would fill the AudioStreamGenerator buffer
	pass

func _process(delta: float) -> void:
	ripple_time += delta
	
	if ripple_time > ripple_lifetime:
		queue_free()
		return
	
	# Expand ripple
	var current_radius = ripple_time * ripple_speed
	
	# Update ring mesh
	ripple_mesh.scale = Vector3.ONE * current_radius
	
	# Fade out over lifetime
	var fade = 1.0 - (ripple_time / ripple_lifetime)
	fade = ease(fade, 0.3)  # Ease out curve
	
	var material = ripple_mesh.material_override
	material.albedo_color.a = fade * 0.5
	material.emission_energy = fade * 3.0
	
	# Update distortion field
	var collision_shape = distortion_field.get_child(0) as CollisionShape3D
	var sphere = collision_shape.shape as SphereShape3D
	sphere.radius = current_radius
	
	# Affect nearby crystals
	if affect_crystals:
		_affect_crystals(current_radius, fade)
	
	# Reality distortion
	if affect_reality:
		_distort_reality(current_radius, fade)
	
	# Audio fade
	ripple_audio.volume_db = linear_to_db(fade)

func _affect_crystals(radius: float, strength: float) -> void:
	for crystal in affected_nodes:
		if not is_instance_valid(crystal):
			continue
			
		var distance = global_position.distance_to(crystal.global_position)
		
		# Check if ripple has reached this crystal
		if distance < radius and distance > radius - ripple_speed * get_process_delta_time() * 2:
			# Just touched by ripple
			if crystal.has_method("on_consciousness_ripple"):
				crystal.on_consciousness_ripple(strength, global_position)
			
			# Visual pulse
			_pulse_crystal(crystal, strength)
			
			# Add slight displacement
			var direction = (crystal.global_position - global_position).normalized()
			var force = direction * strength * 0.5
			
			if crystal.has_method("apply_consciousness_force"):
				crystal.apply_consciousness_force(force)

func _pulse_crystal(crystal: Node3D, strength: float) -> void:
	# Create a quick scale pulse
	var original_scale = crystal.scale
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(crystal, "scale", original_scale * (1.0 + strength * 0.3), 0.2)
	tween.tween_property(crystal, "scale", original_scale, 0.8)

func _distort_reality(radius: float, strength: float) -> void:
	# This would affect the world geometry/shaders
	# For now, we'll emit a signal that the world can listen to
	var distortion_data = {
		"origin": global_position,
		"radius": radius,
		"strength": strength,
		"time": ripple_time
	}
	
	# The world generator or environment would listen for this
	get_tree().call_group("reality_listeners", "on_consciousness_distortion", distortion_data)

func _on_body_entered_field(body: Node3D) -> void:
	# Physical objects entering the ripple field
	if body.has_method("on_consciousness_field_entered"):
		body.on_consciousness_field_entered(ripple_strength)

func _on_area_entered_field(area: Area3D) -> void:
	# Other areas (like other consciousness fields)
	if area.has_method("on_consciousness_overlap"):
		area.on_consciousness_overlap(self)

# Called to modify ripple parameters before it starts
func set_ripple_parameters(params: Dictionary) -> void:
	ripple_radius = params.get("radius", ripple_radius)
	ripple_speed = params.get("speed", ripple_speed)
	ripple_lifetime = params.get("lifetime", ripple_lifetime)
	ripple_color = params.get("color", ripple_color)
	ripple_strength = params.get("strength", ripple_strength)

# For saving the ripple state if needed
func get_ripple_state() -> Dictionary:
	return {
		"origin": origin_point,
		"time": ripple_time,
		"radius": ripple_time * ripple_speed,
		"strength": ripple_strength * (1.0 - ripple_time / ripple_lifetime)
	}

# Notes:
# - Ripple expands at consciousness speed, not physical speed
# - Affects both crystals and reality itself
# - Can overlap with other ripples for interference patterns
# - Visual: expanding ring + particles + reality distortion
# - Audio: resonant tone that fades with distance
# - Ready for integration with world generation system
# - Crystals can respond uniquely to ripples
# - Save state allows persistence of ripple effects
