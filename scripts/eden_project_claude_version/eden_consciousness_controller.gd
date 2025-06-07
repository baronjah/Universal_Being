# Eden Consciousness Controller
# The player AS awareness itself, not controlling but BEING
extends Node3D

# Consciousness state
var awareness_position: Vector3 = Vector3.ZERO
var awareness_velocity: Vector3 = Vector3.ZERO
var focus_direction: Vector3 = Vector3.FORWARD
var consciousness_camera: Camera3D
var consciousness_light: OmniLight3D
var intention_strength: float = 0.0
var focused_crystal: Node3D = null
var consciousness_trail: GPUParticles3D

# Movement parameters - not physical but intentional
const INTENTION_ACCELERATION: float = 0.5
const CONSCIOUSNESS_DAMPING: float = 0.9
const MAX_DRIFT_SPEED: float = 5.0
const FOCUS_RANGE: float = 10.0
const CONSCIOUSNESS_MASS: float = 0.1  # How "heavy" thoughts are

# Crystal connections
var crystal_web: ImmediateMesh
var connection_strengths: Dictionary = {}  # Stores connection strength between crystals
var quantum_threads: Array[Vector3] = []  # Active connection points

# Audio resonance
var resonance_players: Dictionary = {}  # AudioStreamPlayer3D for each crystal
var base_frequency: float = 432.0  # Hz - the universal frequency

# Input state
var mouse_captured: bool = false
var intention_vector: Vector3 = Vector3.ZERO

func _ready() -> void:
	# Initialize consciousness representation
	_create_consciousness_form()
	_initialize_crystal_web()
	_setup_resonance_system()
	
	# Capture mouse for first-person awareness
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func _create_consciousness_form() -> void:
	# Camera is the eye of consciousness
	consciousness_camera = Camera3D.new()
	consciousness_camera.fov = 75  # Wider awareness
	consciousness_camera.near = 0.01  # Can focus very close
	consciousness_camera.far = 1000.0  # Infinite vision
	add_child(consciousness_camera)
	
	# Light is the emanation of awareness
	consciousness_light = OmniLight3D.new()
	consciousness_light.light_color = Color(0.9, 0.95, 1.0)
	consciousness_light.light_energy = 2.0
	consciousness_light.omni_range = 15.0
	consciousness_light.shadow_enabled = true
	# Light pulses with consciousness
	add_child(consciousness_light)
	
	# Consciousness trail - thoughts leaving traces
	consciousness_trail = GPUParticles3D.new()
	consciousness_trail.amount = 100
	consciousness_trail.lifetime = 3.0
	consciousness_trail.trail_enabled = true
	consciousness_trail.trail_lifetime = 1.0
	
	var trail_material = ParticleProcessMaterial.new()
	trail_material.direction = Vector3(0, 0, 1)  # Trails behind movement
	trail_material.initial_velocity_min = 0.0
	trail_material.initial_velocity_max = 0.0
	trail_material.angular_velocity_min = -180.0
	trail_material.angular_velocity_max = 180.0
	trail_material.scale_min = 0.05
	trail_material.scale_max = 0.1
	trail_material.color = Color(0.7, 0.8, 1.0, 0.3)
	trail_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	
	consciousness_trail.process_material = trail_material
	consciousness_trail.draw_pass_1 = SphereMesh.new()
	consciousness_trail.draw_pass_1.radial_segments = 4
	consciousness_trail.draw_pass_1.height = 0.05
	add_child(consciousness_trail)

func _initialize_crystal_web() -> void:
	# Create mesh for drawing connections between crystals
	crystal_web = ImmediateMesh.new()
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = crystal_web
	
	# Web material - quantum entanglement visualization
	var web_material = StandardMaterial3D.new()
	web_material.vertex_color_use_as_albedo = true
	web_material.albedo_color = Color(0.5, 0.7, 1.0, 0.3)
	web_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	web_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	web_material.no_depth_test = true
	mesh_instance.material_override = web_material
	
	add_child(mesh_instance)

func _setup_resonance_system() -> void:
	# Each crystal will have its own tone
	# This gets populated when crystals are discovered
	pass

func _input(event: InputEvent) -> void:
	# Mouse look for consciousness direction
	if event is InputEventMouseMotion and mouse_captured:
		var sensitivity = 0.002
		rotate_y(-event.relative.x * sensitivity)
		consciousness_camera.rotate_x(-event.relative.y * sensitivity)
		
		# Clamp vertical look
		var camera_rotation = consciousness_camera.rotation
		camera_rotation.x = clamp(camera_rotation.x, -PI/2, PI/2)
		consciousness_camera.rotation = camera_rotation
	
	# Toggle mouse capture
	if event.is_action_pressed("ui_cancel"):
		mouse_captured = !mouse_captured
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if mouse_captured else Input.MOUSE_MODE_VISIBLE)
	
	# Focused interaction
	if event.is_action_pressed("interact") and focused_crystal:
		_resonate_with_crystal(focused_crystal)

func _process(delta: float) -> void:
	# Gather intention from input
	intention_vector = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		intention_vector -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		intention_vector += transform.basis.z
	if Input.is_action_pressed("move_left"):
		intention_vector -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		intention_vector += transform.basis.x
	if Input.is_action_pressed("ascend"):
		intention_vector += Vector3.UP
	if Input.is_action_pressed("descend"):
		intention_vector += Vector3.DOWN
	
	# Normalize intention
	if intention_vector.length() > 0:
		intention_vector = intention_vector.normalized()
		intention_strength = 1.0
	else:
		intention_strength *= 0.95  # Fade intention
	
	# Apply consciousness movement
	_update_consciousness_movement(delta)
	
	# Update visual effects
	_update_consciousness_effects(delta)
	
	# Check crystal focus
	_update_crystal_focus()
	
	# Update crystal connections
	_update_crystal_web()

func _update_consciousness_movement(delta: float) -> void:
	# Consciousness moves through intention, not physics
	# But it has inertia - thoughts have momentum
	
	# Apply intention as acceleration
	awareness_velocity += intention_vector * INTENTION_ACCELERATION * delta
	
	# Consciousness naturally slows - returning to stillness
	awareness_velocity *= CONSCIOUSNESS_DAMPING
	
	# Limit drift speed
	if awareness_velocity.length() > MAX_DRIFT_SPEED:
		awareness_velocity = awareness_velocity.normalized() * MAX_DRIFT_SPEED
	
	# Update position
	position += awareness_velocity * delta
	
	# Subtle drift when still - consciousness is never completely static
	if intention_strength < 0.1:
		var drift = Vector3(
			sin(Time.get_ticks_msec() * 0.0007) * 0.01,
			cos(Time.get_ticks_msec() * 0.0011) * 0.01,
			sin(Time.get_ticks_msec() * 0.0013) * 0.01
		)
		position += drift

func _update_consciousness_effects(delta: float) -> void:
	# Light pulses with intention
	consciousness_light.light_energy = 2.0 + intention_strength * 3.0 + sin(Time.get_ticks_msec() * 0.003) * 0.5
	
	# Trail intensity based on movement
	var speed = awareness_velocity.length()
	consciousness_trail.amount_ratio = clamp(speed / MAX_DRIFT_SPEED, 0.1, 1.0)
	
	# Camera effects for deep focus
	if focused_crystal:
		consciousness_camera.fov = lerp(consciousness_camera.fov, 65.0, delta * 2.0)
	else:
		consciousness_camera.fov = lerp(consciousness_camera.fov, 75.0, delta * 2.0)

func _update_crystal_focus() -> void:
	# Find nearest crystal in view
	var crystals = get_tree().get_nodes_in_group("thought_crystals")
	var closest_crystal: Node3D = null
	var closest_distance: float = INF
	
	for crystal in crystals:
		if crystal is Node3D:
			var distance = position.distance_to(crystal.global_position)
			if distance < FOCUS_RANGE and distance < closest_distance:
				# Check if in view
				var to_crystal = (crystal.global_position - global_position).normalized()
				var forward = -consciousness_camera.global_transform.basis.z
				var dot = forward.dot(to_crystal)
				
				if dot > 0.7:  # Within ~45 degree cone
					closest_crystal = crystal
					closest_distance = distance
	
	# Update focus
	if focused_crystal != closest_crystal:
		if focused_crystal:
			_on_crystal_unfocused(focused_crystal)
		
		focused_crystal = closest_crystal
		
		if focused_crystal:
			_on_crystal_focused(focused_crystal)

func _on_crystal_focused(crystal: Node3D) -> void:
	# Emit focus event for crystal to respond
	if crystal.has_method("on_consciousness_focus"):
		crystal.on_consciousness_focus(intention_strength)
	
	# Start resonance
	_begin_resonance(crystal)

func _on_crystal_unfocused(crystal: Node3D) -> void:
	# Emit unfocus event
	if crystal.has_method("on_consciousness_unfocus"):
		crystal.on_consciousness_unfocus()
	
	# Stop resonance
	_end_resonance(crystal)

func _begin_resonance(crystal: Node3D) -> void:
	# Create audio stream for this crystal if needed
	if not resonance_players.has(crystal):
		var audio_player = AudioStreamPlayer3D.new()
		audio_player.position = crystal.position
		audio_player.unit_size = 10.0
		audio_player.max_distance = 30.0
		
		# Generate tone based on crystal's data
		var crystal_data = crystal.get_meta("thought_data", {})
		var frequency = base_frequency * crystal_data.get("resonance", 1.0)
		
		# Create sine wave generator
		var audio_stream = AudioStreamGenerator.new()
		audio_stream.mix_rate = 44100
		audio_player.stream = audio_stream
		
		add_child(audio_player)
		resonance_players[crystal] = audio_player
		
		# Start playing the tone
		audio_player.play()
		_generate_sine_tone(audio_player, frequency)

func _end_resonance(crystal: Node3D) -> void:
	if resonance_players.has(crystal):
		var audio_player = resonance_players[crystal]
		var tween = create_tween()
		tween.tween_property(audio_player, "volume_db", -80.0, 0.5)
		tween.tween_callback(audio_player.queue_free)
		resonance_players.erase(crystal)

func _generate_sine_tone(player: AudioStreamPlayer3D, frequency: float) -> void:
	# This would need actual audio generation code
	# For now, it's a placeholder for the resonance system
	pass

func _update_crystal_web() -> void:
	# Clear previous frame
	crystal_web.clear_surfaces()
	
	# Get all crystals
	var crystals = get_tree().get_nodes_in_group("thought_crystals")
	if crystals.size() < 2:
		return
	
	# Draw connections based on consciousness proximity
	crystal_web.surface_begin(Mesh.PRIMITIVE_LINES)
	
	for i in range(crystals.size()):
		for j in range(i + 1, crystals.size()):
			var crystal_a = crystals[i]
			var crystal_b = crystals[j]
			
			if crystal_a is Node3D and crystal_b is Node3D:
				var distance = crystal_a.global_position.distance_to(crystal_b.global_position)
				
				# Connection strength based on consciousness presence
				var consciousness_factor = 1.0 / (1.0 + position.distance_to((crystal_a.global_position + crystal_b.global_position) * 0.5))
				var connection_strength = consciousness_factor * (1.0 - distance / 20.0)
				
				if connection_strength > 0.1:
					# Draw line with varying alpha
					var color = Color(0.3, 0.5, 1.0, connection_strength * 0.5)
					crystal_web.surface_set_color(color)
					crystal_web.surface_add_vertex(crystal_a.global_position)
					crystal_web.surface_add_vertex(crystal_b.global_position)
	
	crystal_web.surface_end()

func _resonate_with_crystal(crystal: Node3D) -> void:
	# Deep interaction - consciousness merges temporarily with crystal
	print("Resonating with ", crystal.name)
	
	# Create ripple effect in reality
	var ripple = preload("res://effects/consciousness_ripple.tscn").instantiate()
	ripple.global_position = crystal.global_position
	get_parent().add_child(ripple)
	
	# Trigger crystal's action
	if crystal.has_method("activate"):
		crystal.activate(self)

# Helper to get consciousness metrics
func get_consciousness_state() -> Dictionary:
	return {
		"position": position,
		"velocity": awareness_velocity,
		"intention": intention_strength,
		"focused_target": focused_crystal.name if focused_crystal else "void",
		"light_energy": consciousness_light.light_energy
	}

# Called by crystals to influence consciousness
func apply_consciousness_force(force: Vector3, strength: float = 1.0) -> void:
	awareness_velocity += force * strength * CONSCIOUSNESS_MASS

# Notes for Integration:
# - Consciousness moves through intention, not WASD directly
# - Movement has momentum but naturally returns to stillness  
# - Crystals form a web of connections visible to consciousness
# - Focus creates resonance (audio + visual)
# - No collision - consciousness passes through all
# - Ready for VR: just parent to XROrigin3D instead
# - Trail particles show the path of thought
# - Light intensity reveals consciousness strength
