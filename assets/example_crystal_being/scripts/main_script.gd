# Crystal Being - Perfect Pentagon Architecture Example
# FOLLOWS ALL UNIVERSAL BEING ASSET RULES

extends UniversalBeing
class_name CrystalBeing

# ===== CRYSTAL PROPERTIES =====
@export var crystal_size: Vector3 = Vector3(1.0, 2.0, 1.0)
@export var resonance_color: Color = Color.CYAN
@export var rotation_speed: float = 1.0
@export var pulse_enabled: bool = true

# Internal state
var crystal_mesh: MeshInstance3D
var crystal_material: StandardMaterial3D
var pulse_timer: float = 0.0
var resonance_particles: GPUParticles3D

# Signals (as defined in manifest)
signal resonance_triggered(frequency: float)
signal crystal_touched(interaction_force: float)
signal energy_absorbed(amount: float)

# ===== PENTAGON ARCHITECTURE IMPLEMENTATION =====

func pentagon_init() -> void:
	"""Initialize Crystal Being - ALWAYS CALL SUPER FIRST"""
	super.pentagon_init()
	
	# Set Universal Being properties
	being_name = "Crystal Being"
	being_type = "crystal"
	consciousness_level = 2
	
	# Initialize crystal-specific properties
	create_crystal_geometry()
	setup_consciousness_resonance()

func pentagon_ready() -> void:
	"""Crystal awakening - ALWAYS CALL SUPER FIRST"""
	super.pentagon_ready()
	
	# Add to consciousness resonance network
	add_to_group("crystal_beings")
	add_to_group("resonance_network")
	
	# Start gentle pulsing animation
	if pulse_enabled:
		start_consciousness_pulse()

func pentagon_process(delta: float) -> void:
	"""Crystal living process - ALWAYS CALL SUPER FIRST"""
	super.pentagon_process(delta)
	
	# Rotate crystal based on consciousness level
	if crystal_mesh:
		crystal_mesh.rotation.y += delta * rotation_speed * (1.0 + consciousness_level * 0.2)
	
	# Update consciousness pulse
	if pulse_enabled:
		update_consciousness_pulse(delta)
	
	# Resonance with nearby Universal Beings
	detect_consciousness_resonance()

func pentagon_input(event: InputEvent) -> void:
	"""Crystal sensing - ALWAYS CALL SUPER FIRST"""
	super.pentagon_input(event)
	
	# Respond to touch/click
	if event is InputEventMouseButton and event.pressed:
		handle_crystal_touch(event.position)

func pentagon_sewers() -> void:
	"""Crystal transformation/death - ALWAYS CALL SUPER LAST"""
	# Clean up crystal-specific resources
	if resonance_particles:
		resonance_particles.queue_free()
	
	# Emit final resonance
	resonance_triggered.emit(440.0) # A note
	
	# Call super last for proper cleanup
	super.pentagon_sewers()

# ===== CRYSTAL-SPECIFIC METHODS =====

func create_crystal_geometry() -> void:
	"""Create beautiful crystal geometry"""
	crystal_mesh = MeshInstance3D.new()
	crystal_mesh.name = "CrystalMesh"
	
	# Create crystal shape (octahedron)
	var mesh = BoxMesh.new()
	mesh.size = crystal_size
	crystal_mesh.mesh = mesh
	
	# Create resonance material
	crystal_material = StandardMaterial3D.new()
	crystal_material.albedo_color = resonance_color
	crystal_material.metallic = 0.8
	crystal_material.roughness = 0.1
	crystal_material.emission = resonance_color * 0.3
	crystal_mesh.material_override = crystal_material
	
	add_child(crystal_mesh)

func setup_consciousness_resonance() -> void:
	"""Setup particle system for consciousness visualization"""
	resonance_particles = GPUParticles3D.new()
	resonance_particles.name = "ResonanceParticles"
	resonance_particles.emitting = true
	resonance_particles.amount = 50 + consciousness_level * 20
	
	# Configure particles based on consciousness level
	var material = ParticleProcessMaterial.new()
	material.emission = ParticleProcessMaterial.EMISSION_SPHERE
	material.initial_velocity_min = 1.0
	material.initial_velocity_max = 3.0
	material.color = resonance_color
	
	resonance_particles.process_material = material
	add_child(resonance_particles)

func start_consciousness_pulse() -> void:
	"""Begin consciousness pulsing animation"""
	pulse_timer = 0.0

func update_consciousness_pulse(delta: float) -> void:
	"""Update pulsing effect based on consciousness"""
	pulse_timer += delta * 2.0
	
	if crystal_material:
		var pulse_intensity = (sin(pulse_timer) + 1.0) * 0.5
		var enhanced_intensity = pulse_intensity * (1.0 + consciousness_level * 0.3)
		crystal_material.emission = resonance_color * enhanced_intensity

func detect_consciousness_resonance() -> void:
	"""Detect and respond to nearby Universal Beings"""
	var nearby_beings = get_tree().get_nodes_in_group("universal_beings")
	
	for being in nearby_beings:
		if being != self and being.has_method("get_global_position"):
			var distance = global_position.distance_to(being.global_position)
			if distance < 10.0: # Resonance range
				create_resonance_link(being)

func create_resonance_link(other_being: Node) -> void:
	"""Create visual resonance link with another being"""
	if other_being.has_method("get") and other_being.get("consciousness_level") > 0:
		# Trigger resonance event
		var frequency = 220.0 + other_being.get("consciousness_level") * 55.0
		resonance_triggered.emit(frequency)

func handle_crystal_touch(touch_position: Vector2) -> void:
	"""Handle interaction with crystal"""
	var interaction_force = 1.0 + consciousness_level * 0.5
	crystal_touched.emit(interaction_force)
	
	# Absorb consciousness energy from touch
	var energy_amount = interaction_force * 0.1
	energy_absorbed.emit(energy_amount)
	
	# Visual feedback
	if crystal_material:
		# Temporary brightness increase
		var tween = create_tween()
		tween.tween_method(set_crystal_brightness, 1.0, 2.0, 0.1)
		tween.tween_method(set_crystal_brightness, 2.0, 1.0, 0.3)

func set_crystal_brightness(brightness: float) -> void:
	"""Set crystal emission brightness"""
	if crystal_material:
		crystal_material.emission = resonance_color * brightness

# ===== EVOLUTION INTERFACE =====

func can_evolve_to(target_type: String) -> bool:
	"""Check if crystal can evolve to target type"""
	var valid_targets = ["advanced_crystal_being", "quantum_crystal_being"]
	return target_type in valid_targets and consciousness_level >= 3

func get_evolution_requirements(target_type: String) -> Dictionary:
	"""Get requirements for evolution"""
	match target_type:
		"advanced_crystal_being":
			return {"consciousness_level": 3, "resonance_events": 10}
		"quantum_crystal_being":
			return {"consciousness_level": 4, "quantum_entanglement": true}
		_:
			return {}

# ===== AI INTERFACE =====

func ai_interface() -> Dictionary:
	"""Provide AI interface data"""
	var base = super.ai_interface()
	base.crystal_properties = {
		"size": crystal_size,
		"color": resonance_color,
		"rotation_speed": rotation_speed,
		"pulse_enabled": pulse_enabled
	}
	base.resonance_frequency = 440.0 + consciousness_level * 55.0
	return base