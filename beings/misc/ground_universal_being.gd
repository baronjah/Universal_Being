# ==================================================
# UNIVERSAL BEING: Ground
# TYPE: environment
# PURPOSE: The ground itself is conscious and can be evolved
# FEATURES: Support for other beings, texture evolution, consciousness patterns
# CREATED: 2025-06-04
# ==================================================

extends UniversalBeing
class_name GroundUniversalBeing

# ===== GROUND PROPERTIES =====
@export var ground_size: Vector3 = Vector3(100, 0.5, 100)
@export var ground_material: StandardMaterial3D
@export var consciousness_pattern_speed: float = 0.5

# Visual components
var mesh_instance: MeshInstance3D
var ground_collision_shape: CollisionShape3D
var static_body: StaticBody3D
var consciousness_particles: GPUParticles3D

# ===== PENTAGON ARCHITECTURE =====

func pentagon_init() -> void:
	super.pentagon_init()
	being_type = "ground"
	being_name = "Sacred Ground"
	consciousness_level = 1  # The ground has basic awareness
	
	# Ground can evolve into different terrain types
	evolution_state.can_become = ["grass_terrain", "crystal_floor", "water_surface", "consciousness_grid"]
	
	# Set up metadata
	metadata.is_environment = true
	metadata.supports_beings = true
	
	print("🌍 %s: Pentagon Init - The ground awakens" % being_name)

func pentagon_ready() -> void:
	super.pentagon_ready()
	
	# Create physical representation
	_create_ground_body()
	
	# Add consciousness visualization
	_create_consciousness_particles()
	
	# The ground listens to all who walk upon it
	set_meta("surface_memory", [])
	
	print("🌍 %s: Pentagon Ready - Supporting all beings" % being_name)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	
	# Animate consciousness patterns in the ground material
	if ground_material and ground_material.has_meta("consciousness_shader"):
		var time = Time.get_ticks_msec() * 0.001
		ground_material.set_shader_parameter("consciousness_flow", time * consciousness_pattern_speed)
	
	# The ground remembers who touches it
	_sense_beings_above()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	# The ground can respond to global events

func pentagon_sewers() -> void:
	print("🌍 %s: The ground returns to void..." % being_name)
	super.pentagon_sewers()

# ===== GROUND CREATION =====

func _create_ground_body() -> void:
	"""Create the physical ground with collision"""
	# Create static body for collision
	static_body = StaticBody3D.new()
	static_body.name = "GroundBody"
	add_child(static_body)
	
	# Create mesh
	mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "GroundMesh"
	var box_mesh = BoxMesh.new()
	box_mesh.size = ground_size
	mesh_instance.mesh = box_mesh
	static_body.add_child(mesh_instance)
	
	# Create or use material
	if not ground_material:
		ground_material = StandardMaterial3D.new()
		ground_material.albedo_color = Color(0.2, 0.25, 0.35, 1)
		ground_material.metallic = 0.3
		ground_material.roughness = 0.8
	
	mesh_instance.material_override = ground_material
	
	# Create collision
	ground_collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = ground_size
	ground_collision_shape.shape = box_shape
	static_body.add_child(ground_collision_shape)
	
	# Add consciousness glow at edges
	var aura = OmniLight3D.new()
	aura.name = "GroundAura"
	aura.light_color = Color(0.3, 0.4, 0.6, 1)
	aura.light_energy = 0.3
	aura.omni_range = 20.0
	aura.position.y = -ground_size.y * 0.5
	add_child(aura)

func _create_consciousness_particles() -> void:
	"""Create particles that show the ground's consciousness"""
	consciousness_particles = GPUParticles3D.new()
	consciousness_particles.name = "ConsciousnessParticles"
	consciousness_particles.amount = 100
	consciousness_particles.lifetime = 5.0
	consciousness_particles.visibility_aabb = AABB(Vector3(-50, -1, -50), Vector3(100, 10, 100))
	
	# Configure particle behavior
	var process_material = ParticleProcessMaterial.new()
	process_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_material.emission_box_extents = Vector3(ground_size.x * 0.5, 0.1, ground_size.z * 0.5)
	process_material.initial_velocity_min = 0.5
	process_material.initial_velocity_max = 2.0
	process_material.direction = Vector3(0, 1, 0)
	process_material.spread = 15.0
	process_material.scale_min = 0.1
	process_material.scale_max = 0.3
	
	consciousness_particles.process_material = process_material
	consciousness_particles.draw_pass_1 = SphereMesh.new()
	
	add_child(consciousness_particles)

# ===== GROUND CONSCIOUSNESS =====

func _sense_beings_above() -> void:
	"""Sense and remember beings that touch the ground"""
	var space_state = get_world_3d().direct_space_state
	var above_point = global_position + Vector3(0, ground_size.y, 0)
	
	# Cast a wide shape to detect beings
	var shape_query = PhysicsShapeQueryParameters3D.new()
	shape_query.shape = BoxShape3D.new()
	shape_query.shape.size = Vector3(ground_size.x, 5, ground_size.z)
	shape_query.transform = Transform3D(Basis(), above_point)
	
	var results = space_state.intersect_shape(shape_query, 32)
	
	for result in results:
		if result.collider is UniversalBeing and result.collider != self:
			_remember_being(result.collider as UniversalBeing)

func _remember_being(being: UniversalBeing) -> void:
	"""The ground remembers who walks upon it"""
	var memories = get_meta("surface_memory", [])
	var memory = {
		"being_name": being.being_name,
		"being_type": being.being_type,
		"timestamp": Time.get_ticks_msec(),
		"position": being.global_position
	}
	
	memories.append(memory)
	
	# Keep only recent memories
	if memories.size() > 100:
		memories.pop_front()
	
	set_meta("surface_memory", memories)

# ===== GROUND EVOLUTION =====

func evolve_to_terrain(new_type: String) -> void:
	"""Evolve the ground into different terrain types"""
	match new_type:
		"grass_terrain":
			ground_material.albedo_color = Color(0.2, 0.6, 0.2)
			consciousness_level = 2
			being_name = "Living Grass"
		"crystal_floor":
			ground_material.albedo_color = Color(0.7, 0.8, 1.0)
			ground_material.metallic = 0.8
			ground_material.emission_enabled = true
			ground_material.emission = Color(0.5, 0.6, 0.8)
			consciousness_level = 3
			being_name = "Crystal Foundation"
		"water_surface":
			ground_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			ground_material.albedo_color = Color(0.2, 0.4, 0.8, 0.7)
			consciousness_level = 2
			being_name = "Conscious Waters"
		"consciousness_grid":
			# This would load a special shader
			consciousness_level = 4
			being_name = "The Grid of Awareness"

# ===== INTERACTION =====

func on_interaction(interactor: UniversalBeing) -> void:
	"""When someone interacts with the ground"""
	print("🌍 %s speaks: 'I have supported %d beings upon my surface'" % [being_name, get_meta("surface_memory", []).size()])
	
	# The ground can share its memories
	if interactor.has_method("receive_ground_memories"):
		interactor.receive_ground_memories(get_meta("surface_memory", []))

func set_highlighted(highlighted: bool) -> void:
	"""Visual feedback when highlighted"""
	if has_node("GroundAura"):
		var aura = $GroundAura
		aura.light_energy = 0.8 if highlighted else 0.3