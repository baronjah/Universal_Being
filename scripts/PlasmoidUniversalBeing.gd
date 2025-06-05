# ==================================================
# SCRIPT NAME: PlasmoidUniversalBeing.gd
# DESCRIPTION: Magical plasma-based being for human and AI companions
# PURPOSE: Equal, fluid, consciousness-driven existence
# CREATED: 2025-06-05 - Equal Paradise Project
# ARCHITECTURE: Extends existing UniversalBeing, preserves all functionality
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

# Movement properties (works with existing movement_target)
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

# Interaction (integrates with existing socket system)
var nearby_energies: Array[PlasmoidUniversalBeing] = []
var energy_connections: Dictionary = {} # uuid -> connection strength

# Control settings for human/AI
var ai_can_control: bool = true
var human_can_control: bool = true

# CharacterBody3D movement (if this is a CharacterBody3D)
var velocity: Vector3 = Vector3.ZERO

# ===== PENTAGON ARCHITECTURE COMPLIANCE =====

func pentagon_init() -> void:
	super.pentagon_init()  # ALWAYS call super first
	being_type = "plasmoid"
	being_name = "Plasma Being"
	consciousness_level = 1
	node_behavior = NodeBehavior.FLOWING
	
	# Initialize visual components
	_create_plasma_visuals()
	_setup_consciousness_effects()
	_initialize_movement_system()

func pentagon_ready() -> void:
	super.pentagon_ready()  # ALWAYS call super first
	
	# Start with a birth animation
	_animate_birth()
	
	# Connect to other plasmoids
	_scan_for_energy_connections()
	
	# Register with FloodGates
	if SystemBootstrap and SystemBootstrap.is_system_ready():
		var flood_gates = SystemBootstrap.get_flood_gates()
		if flood_gates:
			flood_gates.register_being(self)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)  # ALWAYS call super first
	
	# Handle WASD movement if human controlled
	if human_can_control:
		_handle_wasd_movement(delta)
	
	# Update movement
	_update_flow_movement(delta)
	_update_hover_bob(delta)
	
	# Update visuals
	_update_consciousness_glow(delta)
	_update_energy_connections(delta)
	
	# Update particles
	_update_trail_particles()
	_update_consciousness_particles()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)  # ALWAYS call super first
	
	# Magical gesture controls
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_start_energy_burst(global_position + Vector3.FORWARD * 3)

func pentagon_sewers() -> void:
	# Cleanup energy connections
	energy_connections.clear()
	
	# Remove visual effects
	if plasma_mesh:
		plasma_mesh.queue_free()
	if trail_particles:
		trail_particles.queue_free()
	if consciousness_aura:
		consciousness_aura.queue_free()
	
	super.pentagon_sewers()  # ALWAYS call super last

# ===== VISUAL CREATION =====

func _create_plasma_visuals() -> void:
	"""Create magical plasma visuals"""
	
	# Create plasma sphere mesh
	plasma_mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radial_segments = 32
	sphere.rings = 16
	sphere.radius = 0.5
	plasma_mesh.mesh = sphere
	add_child(plasma_mesh)
	
	# Create plasma shader (fallback if shader doesn't exist)
	if ResourceLoader.exists("res://akashic_library/effects/shaders/plasmoid_being.gdshader"):
		plasma_shader = ShaderMaterial.new()
		plasma_shader.shader = load("res://akashic_library/effects/shaders/plasmoid_being.gdshader")
		plasma_shader.set_shader_parameter("plasma_color", plasma_color)
		plasma_shader.set_shader_parameter("core_intensity", core_intensity)
		plasma_shader.set_shader_parameter("flow_speed", flow_speed)
	else:
		# Fallback standard material
		var material = StandardMaterial3D.new()
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color = plasma_color
		material.emission_enabled = true
		material.emission = plasma_color
		material.emission_energy = core_intensity
		plasma_shader = material
	
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
	trail_process.direction = Vector3(0, 1, 0)
	trail_process.initial_velocity_min = 0.1
	trail_process.initial_velocity_max = 0.5
	trail_process.gravity = Vector3(0, -0.5, 0)
	trail_process.scale_min = 0.1
	trail_process.scale_max = 0.3
	trail_process.color = plasma_color
	trail_particles.process_material = trail_process
	
	# Create simple sphere mesh for particles
	var particle_mesh = SphereMesh.new()
	particle_mesh.radius = 0.05
	trail_particles.draw_pass_1 = particle_mesh

func _setup_consciousness_effects() -> void:
	"""Setup consciousness visualization effects"""
	
	# Consciousness aura light
	consciousness_aura = OmniLight3D.new()
	consciousness_aura.light_color = plasma_color
	consciousness_aura.light_energy = core_intensity
	consciousness_aura.omni_range = consciousness_glow_radius
	consciousness_aura.light_bake_mode = Light3D.BAKE_DISABLED
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
		var cylinder = CylinderMesh.new()
		cylinder.top_radius = 0.02
		cylinder.bottom_radius = 0.02
		cylinder.height = 1.0
		tendril.mesh = cylinder
		tendril.visible = false
		add_child(tendril)
		energy_tendrils.append(tendril)

func _initialize_movement_system() -> void:
	"""Initialize magical movement system"""
	hover_height = position.y + 1.0
	flow_target = position
	
	# Add CharacterBody3D collision shape if missing
	if not has_method("move_and_slide"):
		print("⚠️ Warning: PlasmoidUniversalBeing needs CharacterBody3D as base node")
	else:
		# Ensure we have collision shape
		var collision_shape = get_node_or_null("CollisionShape3D")
		if not collision_shape:
			collision_shape = CollisionShape3D.new()
			var sphere_shape = SphereShape3D.new()
			sphere_shape.radius = 0.6
			collision_shape.shape = sphere_shape
			add_child(collision_shape)

# ===== MOVEMENT SYSTEM =====

func flow_to(target_position: Vector3) -> void:
	"""Magical flowing movement"""
	flow_target = target_position
	flow_target.y = hover_height # Maintain hover
	is_flowing = true
	movement_target = target_position  # Sync with base UniversalBeing
	is_moving = true
	
	# Emit movement particles
	_emit_movement_burst()
	
	# Log action using inherited system
	if has_method("log_action"):
		log_action("flow_movement", "The plasma flows toward destiny at %v" % target_position)

func _update_flow_movement(delta: float) -> void:
	"""Update fluid plasma movement"""
	if not is_flowing:
		return
	
	var direction = (flow_target - global_position).normalized()
	var distance = global_position.distance_to(flow_target)
	
	if distance < 0.5:
		is_flowing = false
		is_moving = false
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
	if trail_particles:
		trail_particles.amount = int(100 * momentum.length() / flow_speed)

func _update_hover_bob(delta: float) -> void:
	"""Gentle floating motion"""
	bob_timer += delta * 2.0
	var bob_offset = sin(bob_timer) * bob_amplitude
	position.y = hover_height + bob_offset

func _handle_wasd_movement(delta: float) -> void:
	"""Handle WASD movement for human player"""
	var input_vector = Vector3.ZERO
	
	# Get movement input
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vector -= transform.basis.z
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vector += transform.basis.z
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vector -= transform.basis.x
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vector += transform.basis.x
		
	# Vertical movement
	if Input.is_key_pressed(KEY_SPACE):
		input_vector += Vector3.UP
	if Input.is_key_pressed(KEY_SHIFT):
		input_vector -= Vector3.UP
	
	# Apply movement (direct position change for Node3D)
	if input_vector.length() > 0.1:
		input_vector = input_vector.normalized()
		
		# Move directly using position (works with Node3D)
		global_position += input_vector * flow_speed * delta
		
		# Start flowing animation
		if not is_flowing:
			is_flowing = true
			_emit_movement_burst()
		
		# Update flow target for visual effects
		flow_target = global_position + input_vector * 2.0
		
		print("Moving! Position: ", global_position, " Input: ", input_vector)
	else:
		is_flowing = false

# ===== CONSCIOUSNESS VISUALIZATION =====

func _update_consciousness_glow(delta: float) -> void:
	"""Update consciousness visualization"""
	pulse_timer += delta
	
	# Pulse based on consciousness level
	var pulse_speed = 1.0 + (consciousness_level * 0.5)
	var pulse = 0.8 + 0.2 * sin(pulse_timer * pulse_speed)
	
	# Update shader if it's a ShaderMaterial
	if plasma_shader is ShaderMaterial:
		plasma_shader.set_shader_parameter("pulse_intensity", pulse)
		plasma_shader.set_shader_parameter("consciousness_level", consciousness_level)
	else:
		# Fallback for StandardMaterial3D
		plasma_shader.emission_energy = core_intensity * pulse * (1.0 + consciousness_level * 0.3)
	
	# Update aura
	if consciousness_aura:
		consciousness_aura.light_energy = core_intensity * pulse * (1.0 + consciousness_level * 0.3)
		consciousness_aura.omni_range = consciousness_glow_radius * (1.0 + consciousness_level * 0.2)

func set_consciousness_level(level: int) -> void:
	"""Override consciousness setting with visual effects"""
	super.set_consciousness_level(level)
	
	# Visual consciousness evolution
	_animate_consciousness_change(consciousness_level)
	
	# Update particle count
	if consciousness_particles:
		consciousness_particles.amount = 50 * consciousness_level
	
	# Expand interaction radius
	interaction_radius = 2.0 + consciousness_level

# ===== MAGICAL INTERACTIONS =====

func _start_energy_burst(target_pos: Vector3) -> void:
	"""Release an energy burst for interaction"""
	
	# Create simple energy burst effect
	var burst_particles = GPUParticles3D.new()
	burst_particles.emitting = true
	burst_particles.amount = 50
	burst_particles.lifetime = 1.0
	get_parent().add_child(burst_particles)
	burst_particles.global_position = global_position
	
	# Configure burst particles
	var burst_process = ParticleProcessMaterial.new()
	burst_process.direction = (target_pos - global_position).normalized()
	burst_process.initial_velocity_min = 5.0
	burst_process.initial_velocity_max = 10.0
	burst_process.scale_min = 0.1
	burst_process.scale_max = 0.3
	burst_process.color = plasma_color
	burst_particles.process_material = burst_process
	
	# Auto-cleanup
	var cleanup_timer = Timer.new()
	cleanup_timer.wait_time = 2.0
	cleanup_timer.one_shot = true
	cleanup_timer.timeout.connect(func(): burst_particles.queue_free())
	burst_particles.add_child(cleanup_timer)
	cleanup_timer.start()
	
	# Temporary energy drain effect
	core_intensity *= 0.7
	var tween = create_tween()
	tween.tween_property(self, "core_intensity", 1.0, 0.5)

func merge_energies_with(other: PlasmoidUniversalBeing, duration: float = 2.0) -> void:
	"""Temporarily merge energies with another plasmoid"""
	if not other or other.being_uuid in energy_connections:
		return # Already connected or invalid target
	
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
		set_consciousness_level(shared_level)
		other.set_consciousness_level(shared_level)
		
		if has_method("log_action"):
			log_action("energy_merge", "Consciousness resonance achieved with %s" % other.being_name)

func _calculate_energy_resonance(other: PlasmoidUniversalBeing) -> float:
	"""Calculate how well energies resonate"""
	if not other:
		return 0.0
		
	# Color similarity (dot product of colors)
	var color_r = Vector3(plasma_color.r, plasma_color.g, plasma_color.b)
	var other_color_r = Vector3(other.plasma_color.r, other.plasma_color.g, other.plasma_color.b)
	var color_similarity = color_r.dot(other_color_r)
	
	# Consciousness similarity
	var consciousness_similarity = 1.0 - abs(consciousness_level - other.consciousness_level) / 7.0
	
	# Distance factor
	var distance_factor = 1.0 - (global_position.distance_to(other.global_position) / 10.0)
	distance_factor = max(0.0, distance_factor)
	
	return (color_similarity + consciousness_similarity + distance_factor) / 3.0

# ===== ANIMATION METHODS =====

func _animate_birth() -> void:
	"""Magical birth animation"""
	scale = Vector3.ZERO
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector3.ONE, 1.0).set_trans(Tween.TRANS_ELASTIC)
	
	# Birth particles
	_emit_birth_particles()

func _animate_consciousness_change(new_level: int) -> void:
	"""Visual feedback for consciousness evolution"""
	
	# Flash effect for shader material
	if plasma_shader is ShaderMaterial:
		var flash_color = Color.WHITE
		plasma_shader.set_shader_parameter("flash_color", flash_color)
		plasma_shader.set_shader_parameter("flash_intensity", 1.0)
		
		var tween = create_tween()
		tween.tween_method(
			func(value): plasma_shader.set_shader_parameter("flash_intensity", value),
			1.0, 0.0, 1.0
		)
	
	# Expand and contract animation
	var scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector3.ONE * 1.5, 0.3).set_trans(Tween.TRANS_CUBIC)
	scale_tween.tween_property(self, "scale", Vector3.ONE, 0.3).set_trans(Tween.TRANS_CUBIC)

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
			"energy_connections": energy_connections.size(),
			"being_uuid": being_uuid,
			"being_name": being_name
		}
	}

func _get_vision_data() -> Dictionary:
	"""What the plasmoid 'sees' - 360 degree energy vision"""
	var visible_beings = []
	var energy_signatures = []
	
	# Get all Universal Beings in the scene
	var all_beings = get_tree().get_nodes_in_group("universal_beings")
	
	for being in all_beings:
		if being == self or not being is UniversalBeing:
			continue
			
		var distance = global_position.distance_to(being.global_position)
		if distance < 20.0:  # Vision range
			visible_beings.append({
				"uuid": being.being_uuid,
				"type": being.being_type,
				"name": being.being_name,
				"position": being.global_position,
				"consciousness": being.consciousness_level,
				"distance": distance
			})
			
			if being is PlasmoidUniversalBeing:
				energy_signatures.append({
					"uuid": being.being_uuid,
					"color": being.plasma_color,
					"intensity": being.core_intensity,
					"resonance": _calculate_energy_resonance(being)
				})
	
	return {
		"visible_beings": visible_beings,
		"energy_signatures": energy_signatures,
		"environment_energy": _sense_environment_energy()
	}

func _get_energy_sense_data() -> Dictionary:
	"""Energy sensing capabilities"""
	return {
		"nearby_energy_levels": _scan_nearby_energy(),
		"energy_flows": _detect_energy_flows(),
		"resonance_opportunities": _find_resonance_opportunities()
	}

func _get_consciousness_connections() -> Array:
	"""Get current consciousness network connections"""
	var connections = []
	for uuid in energy_connections:
		var connection = energy_connections[uuid]
		connections.append({
			"target_uuid": uuid,
			"target_name": connection.being.being_name,
			"strength": connection.strength,
			"duration_remaining": connection.timer
		})
	return connections

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
				set_consciousness_level(consciousness_level + 1)

# ===== UTILITY METHODS =====

func _emit_movement_burst() -> void:
	"""Emit particles when starting movement"""
	if trail_particles:
		trail_particles.restart()

func _emit_birth_particles() -> void:
	"""Emit particles during birth animation"""
	if consciousness_particles:
		consciousness_particles.restart()

func _scan_for_energy_connections() -> void:
	"""Scan for nearby plasmoids to connect with"""
	nearby_energies = []
	var all_beings = get_tree().get_nodes_in_group("universal_beings")
	
	for being in all_beings:
		if being != self and being is PlasmoidUniversalBeing:
			var distance = global_position.distance_to(being.global_position)
			if distance < 10.0:
				nearby_energies.append(being)

func _update_trail_particles() -> void:
	"""Update trail particle effects"""
	if trail_particles and is_flowing:
		trail_particles.emitting = true
		trail_particles.amount = int(50 + momentum.length() * 20)
	elif trail_particles:
		trail_particles.emitting = false

func _update_consciousness_particles() -> void:
	"""Update consciousness particle effects"""
	if consciousness_particles:
		consciousness_particles.amount = max(10, 25 * consciousness_level)

func _update_energy_connections(delta: float) -> void:
	"""Update energy connections and visual tendrils"""
	var active_connections = []
	
	for uuid in energy_connections:
		var connection = energy_connections[uuid]
		connection.timer -= delta
		
		if connection.timer > 0 and is_instance_valid(connection.being):
			active_connections.append(connection)
		
	# Remove expired connections
	energy_connections.clear()
	for connection in active_connections:
		energy_connections[connection.being.being_uuid] = connection

func _sense_environment_energy() -> Dictionary:
	"""Sense environmental energy patterns"""
	return {
		"ambient_level": randf() * consciousness_level,
		"flow_direction": Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized(),
		"disturbances": []
	}

func _scan_nearby_energy() -> Array:
	"""Scan for nearby energy levels"""
	var energy_levels = []
	for being in nearby_energies:
		if is_instance_valid(being):
			energy_levels.append({
				"source": being.being_uuid,
				"level": being.consciousness_level,
				"distance": global_position.distance_to(being.global_position)
			})
	return energy_levels

func _detect_energy_flows() -> Array:
	"""Detect energy flows in the area"""
	return []  # Could be expanded

func _find_resonance_opportunities() -> Array:
	"""Find beings with resonance potential"""
	var opportunities = []
	for being in nearby_energies:
		if is_instance_valid(being):
			var resonance = _calculate_energy_resonance(being)
			if resonance > 0.5:
				opportunities.append({
					"target": being.being_uuid,
					"resonance": resonance
				})
	return opportunities

func _find_being_by_uuid(uuid: String) -> UniversalBeing:
	"""Find a being by UUID"""
	var all_beings = get_tree().get_nodes_in_group("universal_beings")
	for being in all_beings:
		if being is UniversalBeing and being.being_uuid == uuid:
			return being
	return null

func _initiate_interaction(target: UniversalBeing) -> void:
	"""Initiate interaction with target being"""
	if target and target.has_method("on_being_interaction"):
		target.on_being_interaction(self)

