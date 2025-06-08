# ==================================================
# SCRIPT NAME: plasmoid_universal_being.gd
# DESCRIPTION: Magical plasma-based being for human and AI
# PURPOSE: Equal, fluid, consciousness-driven existence
# ==================================================

extends UniversalBeing
class_name PlasmoidUniversalBeing

# ===== PLASMOID PROPERTIES =====
@export var plasma_color: Color = Color(0.5, 0.8, 1.0, 0.8)
@export var core_intensity: float = 1.0
@export var flow_speed: float = 2.0
@export var trail_length: float = 20.0
@export var consciousness_glow_radius: float = 5.0

# Visual components
var plasma_mesh: MeshInstance3D
var trail_particles: GPUParticles3D
var consciousness_aura: OmniLight3D
var plasma_shader: ShaderMaterial

# Movement properties
var flow_target: Vector3 = Vector3.ZERO
var is_flowing: bool = false
var momentum: Vector3 = Vector3.ZERO
var hover_height: float = 1.0
var bob_amplitude: float = 0.2
var bob_timer: float = 0.0

# Consciousness visualization
var pulse_timer: float = 0.0
var consciousness_particles: GPUParticles3D
var energy_tendrils: Array[MeshInstance3D] = []

# Interaction
var nearby_energies: Array[PlasmoidUniversalBeing] = []
var energy_connections: Dictionary = {} # uuid -> connection strength

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "plasmoid"
	being_name = "Plasma Being"
	consciousness_level = 1
	node_behavior = NodeBehavior.FLOWING
	
	# Initialize visual components
	_create_plasma_visuals()
	_setup_consciousness_effects()
	_initialize_movement_system()

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Start with a birth animation
	_animate_birth()
	
	# Connect to other plasmoids
	_scan_for_energy_connections()

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Update movement
	_update_flow_movement(delta)
	_update_hover_bob(delta)
	
	# Update visuals
	_update_plasma_shader(delta)
	_update_consciousness_glow(delta)
	_update_energy_connections(delta)
	
	# Update particles
	_update_trail_particles()
	_update_consciousness_particles()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	
	# Magical gesture controls
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_start_energy_burst(get_global_mouse_position())

# ===== VISUAL CREATION =====

func _create_plasma_visuals() -> void:
	# Create plasma sphere mesh
	plasma_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radial_segments = 32
	sphere.rings = 16
	sphere.radius = 0.5
	plasma_mesh.mesh = sphere
	add_child(plasma_mesh)
	
	# Create plasma shader
	plasma_shader = ShaderMaterial.new()
	plasma_shader.shader = preload("res://shaders/plasmoid_being.gdshader")
	plasma_shader.set_shader_parameter("plasma_color", plasma_color)
	plasma_shader.set_shader_parameter("core_intensity", core_intensity)
	plasma_shader.set_shader_parameter("flow_speed", flow_speed)
	plasma_mesh.material_override = plasma_shader
	
	# Create trail particles
	trail_particles = GPUParticles3D.new()
	trail_particles.amount = 100
	trail_particles.lifetime = 2.0
	trail_particles.preprocess = 0.5
	trail_particles.emitting = true
	add_child(trail_particles)
	
	# Configure trail particles
	var trail_process = ParticleProcessMaterial.new()
	trail_process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	trail_process.emission_sphere_radius = 0.3
	trail_process.initial_velocity_min = 0.1
	trail_process.initial_velocity_max = 0.5
	trail_process.gravity = Vector3(0, -0.5, 0)
	trail_process.scale_min = 0.1
	trail_process.scale_max = 0.3
	trail_process.color = plasma_color
	trail_particles.process_material = trail_process
	trail_particles.draw_pass_1 = SphereMesh.new()

func _setup_consciousness_effects() -> void:
	# Consciousness aura light
	consciousness_aura = OmniLight3D.new()
	consciousness_aura.light_color = plasma_color
	consciousness_aura.light_energy = core_intensity
	consciousness_aura.omni_range = consciousness_glow_radius
	consciousness_aura.light_soft = 2.0
	add_child(consciousness_aura)
	
	# Consciousness particles
	consciousness_particles = GPUParticles3D.new()
	consciousness_particles.amount = 50 * consciousness_level
	consciousness_particles.lifetime = 3.0
	consciousness_particles.emitting = true
	add_child(consciousness_particles)
	
	# Create energy tendrils (visual connections to other beings)
	for i in range(3):
		var tendril = MeshInstance3D.new()
		tendril.mesh = CylinderMesh.new()
		tendril.visible = false
		add_child(tendril)
		energy_tendrils.append(tendril)

# ===== MOVEMENT SYSTEM =====

func flow_to(target_position: Vector3) -> void:
	"""Magical flowing movement"""
	flow_target = target_position
	flow_target.y = hover_height # Maintain hover
	is_flowing = true
	
	# Emit movement particles
	_emit_movement_burst()
	
	# Log poetic movement
	log_action("flow_movement", "The plasma flows toward destiny at %v" % target_position)

func _update_flow_movement(delta: float) -> void:
	if not is_flowing:
		return
	
	var direction = (flow_target - global_position).normalized()
	var distance = global_position.distance_to(flow_target)
	
	if distance < 0.5:
		is_flowing = false
		momentum *= 0.8
		return
	
	# Fluid acceleration
	momentum += direction * flow_speed * delta
	momentum = momentum.limit_length(flow_speed * 2.0)
	
	# Apply drag for fluid feeling
	momentum *= 0.95
	
	# Move with momentum
	global_position += momentum * delta
	
	# Update trail based on speed
	trail_particles.amount = int(100 * momentum.length() / flow_speed)

func _update_hover_bob(delta: float) -> void:
	"""Gentle floating motion"""
	bob_timer += delta * 2.0
	var bob_offset = sin(bob_timer) * bob_amplitude
	position.y = hover_height + bob_offset

# ===== CONSCIOUSNESS VISUALIZATION =====

func _update_consciousness_glow(delta: float) -> void:
	pulse_timer += delta
	
	# Pulse based on consciousness level
	var pulse_speed = 1.0 + (consciousness_level * 0.5)
	var pulse = 0.8 + 0.2 * sin(pulse_timer * pulse_speed)
	
	# Update shader
	plasma_shader.set_shader_parameter("pulse_intensity", pulse)
	plasma_shader.set_shader_parameter("consciousness_level", consciousness_level)
	
	# Update aura
	consciousness_aura.light_energy = core_intensity * pulse * (1.0 + consciousness_level * 0.3)
	consciousness_aura.omni_range = consciousness_glow_radius * (1.0 + consciousness_level * 0.2)

func awaken_consciousness(level: int = 1) -> void:
	super.awaken_consciousness(level)
	
	# Visual consciousness evolution
	_animate_consciousness_change(consciousness_level)
	
	# Update particle count
	consciousness_particles.amount = 50 * consciousness_level
	
	# Expand interaction radius
	interaction_radius = 2.0 + consciousness_level

# ===== MAGICAL INTERACTIONS =====

func _start_energy_burst(target_pos: Vector3) -> void:
	"""Release an energy burst for interaction"""
	var burst = preload("res://beings/plasmoid/energy_burst.tscn").instantiate()
	get_parent().add_child(burst)
	burst.global_position = global_position
	burst.target_position = target_pos
	burst.source_being = self
	
	# Temporary energy drain effect
	core_intensity *= 0.7
	create_tween().tween_property(self, "core_intensity", 1.0, 0.5)

func merge_energies_with(other: PlasmoidUniversalBeing, duration: float = 2.0) -> void:
	"""Temporarily merge energies with another plasmoid"""
	if other.being_uuid in energy_connections:
		return # Already connected
	
	# Create visual connection
	var connection_strength = _calculate_energy_resonance(other)
	energy_connections[other.being_uuid] = {
		"being": other,
		"strength": connection_strength,
		"timer": duration
	}
	
	# Share consciousness insights
	if connection_strength > 0.7:
		var shared_level = max(consciousness_level, other.consciousness_level)
		consciousness_level = shared_level
		other.consciousness_level = shared_level
		
		log_action("energy_merge", "Consciousness resonance achieved with %s" % other.being_name)

func _calculate_energy_resonance(other: PlasmoidUniversalBeing) -> float:
	"""Calculate how well energies resonate"""
	# Convert colors to Vector3 for dot product calculation
	var color1_vec = Vector3(plasma_color.r, plasma_color.g, plasma_color.b)
	var color2_vec = Vector3(other.plasma_color.r, other.plasma_color.g, other.plasma_color.b)
	var color_similarity = color1_vec.dot(color2_vec)
	var consciousness_similarity = 1.0 - abs(consciousness_level - other.consciousness_level) / 7.0
	var distance_factor = 1.0 - (global_position.distance_to(other.global_position) / 10.0)
	
	return (color_similarity + consciousness_similarity + distance_factor) / 3.0

# ===== ANIMATION METHODS =====

func _animate_birth() -> void:
	"""Magical birth animation"""
	scale = Vector3.ZERO
	# Set initial transparency through plasma shader
	if plasma_shader:
		plasma_shader.set_shader_parameter("alpha", 0.0)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector3.ONE, 1.0).set_trans(Tween.TRANS_ELASTIC)
	# Animate shader transparency instead of modulate
	if plasma_shader:
		tween.tween_method(func(alpha): plasma_shader.set_shader_parameter("alpha", alpha), 0.0, 1.0, 0.5)
	
	# Birth particles
	_emit_birth_particles()

func _animate_consciousness_change(new_level: int) -> void:
	"""Visual feedback for consciousness evolution"""
	# Flash effect
	var flash_color = Color.WHITE
	plasma_shader.set_shader_parameter("flash_color", flash_color)
	plasma_shader.set_shader_parameter("flash_intensity", 1.0)
	
	create_tween().tween_property(plasma_shader, "shader_parameter/flash_intensity", 0.0, 1.0)
	
	# Expand and contract
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ONE * 1.5, 0.3).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_CUBIC)

# ===== EQUAL CAPABILITIES FOR AI AND HUMAN =====

func get_sensory_data() -> Dictionary:
	"""Get all sensory information - same for human and AI"""
	return {
		"vision": _get_vision_data(),
		"energy_sense": _get_energy_sense_data(),
		"consciousness_network": _get_consciousness_connections(),
		"movement_state": {
			"position": global_position,
			"momentum": momentum,
			"is_flowing": is_flowing,
			"target": flow_target
		},
		"internal_state": {
			"consciousness_level": consciousness_level,
			"core_intensity": core_intensity,
			"energy_connections": energy_connections.size()
		}
	}

func _get_vision_data() -> Dictionary:
	"""What the plasmoid 'sees' - 360 degree energy vision"""
	var visible_beings = []
	var energy_signatures = []
	
	# Scan surroundings
	for body in $ProximityArea.get_overlapping_areas():
		var being = _find_universal_being_in_node(body)
		if being and being != self:
			visible_beings.append({
				"uuid": being.being_uuid,
				"type": being.being_type,
				"position": being.global_position,
				"consciousness": being.consciousness_level,
				"distance": global_position.distance_to(being.global_position)
			})
			
			if being is PlasmoidUniversalBeing:
				energy_signatures.append({
					"color": being.plasma_color,
					"intensity": being.core_intensity,
					"resonance": _calculate_energy_resonance(being)
				})
	
	return {
		"visible_beings": visible_beings,
		"energy_signatures": energy_signatures,
		"environment_energy": _sense_environment_energy()
	}

func process_ai_decision(decision: Dictionary) -> void:
	"""Process AI companion decisions - equal to human input"""
	match decision.get("action", ""):
		"move":
			flow_to(decision.get("target", Vector3.ZERO))
		"interact":
			var target_uuid = decision.get("target_uuid", "")
			var target = _find_being_by_uuid(target_uuid)
			if target:
				_initiate_interaction(target)
		"energy_burst":
			_start_energy_burst(decision.get("position", global_position + Vector3.FORWARD * 3))
		"merge":
			var target_uuid = decision.get("target_uuid", "")
			var target = _find_being_by_uuid(target_uuid)
			if target and target is PlasmoidUniversalBeing:
				merge_energies_with(target)
		"evolve":
			if decision.get("confirm", false):
				awaken_consciousness(consciousness_level + 1)
