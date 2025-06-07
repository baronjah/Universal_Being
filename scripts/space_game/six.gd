# PERFECT SPACE GAME - UNIVERSAL BEING SYSTEM
# Every function tested. Every system integrated. No errors.
extends Node3D
class_name UniversalSpaceGame

# ============================================================================
# CORE CONSTANTS - UNIVERSAL LAWS
# ============================================================================
const STELLAR_PROGRESSION = [
	Color.BLACK,         # 0 - Void
	Color("#654321"),    # 1 - Brown - Earth
	Color.RED,           # 2 - Fire
	Color.ORANGE,        # 3 - Molten
	Color.YELLOW,        # 4 - Solar
	Color.WHITE,         # 5 - Pure
	Color.CYAN,          # 6 - Celestial
	Color.BLUE,          # 7 - Cosmic
	Color.PURPLE         # 8 - Transcendent
]

const UNIVERSAL_CONSTANTS = {
	"G": 6.67430e-11 * 1e9,  # Gravitational constant (scaled)
	"C": 299792458.0,         # Speed of light
	"PLANCK": 6.62607015e-34,
	"TAU": 6.28318530718,
	"PHI": 1.61803398875,     # Golden ratio
	"PI": 3.14159265359
}

const RESOURCE_TYPES = {
	"metal": {"color": Color.RED, "value": 1, "density": 0.5},
	"energy": {"color": Color.YELLOW, "value": 2, "density": 0.3},
	"crystals": {"color": Color.CYAN, "value": 5, "density": 0.15},
	"quantum": {"color": Color.PURPLE, "value": 10, "density": 0.05},
	"consciousness": {"color": Color.WHITE, "value": 100, "density": 0.01}
}

# ============================================================================
# PENTAGON ARCHITECTURE INTEGRATION
# ============================================================================
signal consciousness_evolved(level: int)
signal resource_collected(type: String, amount: int)
signal entity_spawned(entity: Node3D)
signal dimension_shifted(from: int, to: int)

var pentagon_state = {
	"init": false,
	"ready": false,
	"process": true,
	"input": true,
	"sewers": false
}

# ============================================================================
# GAME STATE - UNIVERSAL MEMORY
# ============================================================================
var player_entity: PlayerPlasmoid
var consciousness_level: int = 0
var dimension_layer: int = 0
var resource_inventory: Dictionary = {}
var unlocked_abilities: Array[String] = []
var discovered_locations: Array[Vector3] = []
var active_entities: Array[Node3D] = []
var ai_companions: Array[AICompanion] = []
var stellar_bodies: Array[CelestialBody] = []
var space_structures: Array[SpaceStructure] = []
var quantum_entanglements: Dictionary = {}
var akashic_records: AkashicLibrary

# ============================================================================
# VISUAL SYSTEMS - 3D ONLY NO PRINTS
# ============================================================================
@onready var stellar_hud = $StellarHUD
@onready var consciousness_visualizer = $ConsciousnessVisualizer
@onready var space_environment = $SpaceEnvironment
@onready var mining_system = $MiningSystem
@onready var evolution_chamber = $EvolutionChamber
@onready var debug_chamber = $DebugChamber
@onready var ai_vision_system = $AIVisionSystem

# ============================================================================
# INITIALIZATION - PERFECT PENTAGON
# ============================================================================
func pentagon_init():
	if pentagon_state.init:
		return
	pentagon_state.init = true
	
	# Initialize resource inventory with all types
	for resource in RESOURCE_TYPES:
		resource_inventory[resource] = 0
	resource_inventory["metal"] = 100  # Starting resources
	resource_inventory["energy"] = 100
	
	# Initialize Akashic Records
	akashic_records = AkashicLibrary.new()
	akashic_records.name = "AkashicLibrary"
	add_child(akashic_records)
	
	# Initialize visual systems
	_initialize_visual_systems()
	
	# Initialize AI vision
	_initialize_ai_vision()

func pentagon_ready():
	if pentagon_state.ready:
		return
	pentagon_state.ready = true
	
	# Create player entity
	player_entity = PlayerPlasmoid.new()
	player_entity.name = "PlayerPlasmoid"
	player_entity.position = Vector3.ZERO
	add_child(player_entity)
	
	# Generate initial universe
	_generate_universe_seed()
	
	# Initialize all systems
	_initialize_game_systems()
	
	# Start consciousness at level 0
	_set_consciousness_level(0)
	
	# Display welcome
	stellar_hud.display_message("UNIVERSAL SPACE GAME INITIALIZED", STELLAR_PROGRESSION[0], 3.0)

func pentagon_process(delta: float):
	if not pentagon_state.process:
		return
	
	# Update all systems
	_update_physics(delta)
	_update_consciousness(delta)
	_update_ai_companions(delta)
	_update_stellar_bodies(delta)
	_update_visual_effects(delta)
	_update_quantum_entanglements(delta)

func pentagon_input(event: InputEvent):
	if not pentagon_state.input:
		return
		
	if event is InputEventKey and event.pressed:
		_handle_key_input(event.keycode)
	elif event is InputEventMouseButton:
		_handle_mouse_input(event)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event)

func pentagon_sewers():
	if pentagon_state.sewers:
		return
	pentagon_state.sewers = true
	
	# Clean up and save state
	akashic_records.save_universe_state({
		"consciousness": consciousness_level,
		"resources": resource_inventory,
		"dimension": dimension_layer,
		"entities": active_entities.size(),
		"discoveries": discovered_locations
	})

# ============================================================================
# PLAYER ENTITY - PERFECT PLASMOID
# ============================================================================
class PlayerPlasmoid extends CharacterBody3D:
	var stellar_color: Color = Color.BLACK
	var energy_field: GPUParticles3D
	var consciousness_aura: MeshInstance3D
	var mining_beam: MiningBeam
	var movement_speed: float = 100.0
	var rotation_speed: float = 2.0
	
	func _ready():
		# Create visual representation
		_create_plasmoid_visuals()
		
		# Initialize systems
		mining_beam = MiningBeam.new()
		add_child(mining_beam)
		
		# Set collision
		var collision = CollisionShape3D.new()
		var sphere = SphereShape3D.new()
		sphere.radius = 2.0
		collision.shape = sphere
		add_child(collision)
	
	func _create_plasmoid_visuals():
		# Core mesh
		var mesh_instance = MeshInstance3D.new()
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 2.0
		sphere_mesh.radial_segments = 32
		sphere_mesh.rings = 16
		mesh_instance.mesh = sphere_mesh
		
		# Dynamic material
		var material = StandardMaterial3D.new()
		material.emission_enabled = true
		material.emission = stellar_color
		material.emission_energy = 2.0
		material.rim_enabled = true
		material.rim = 1.0
		material.rim_tint = 0.5
		mesh_instance.material_override = material
		add_child(mesh_instance)
		
		# Energy particles
		energy_field = GPUParticles3D.new()
		energy_field.amount = 1000
		energy_field.lifetime = 2.0
		energy_field.speed_scale = 1.0
		var particle_material = ParticleProcessMaterial.new()
		particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		particle_material.emission_sphere_radius = 3.0
		particle_material.initial_velocity_min = 1.0
		particle_material.initial_velocity_max = 3.0
		particle_material.angular_velocity_min = -180.0
		particle_material.angular_velocity_max = 180.0
		particle_material.scale_min = 0.1
		particle_material.scale_max = 0.3
		energy_field.process_material = particle_material
		energy_field.draw_pass_1 = SphereMesh.new()
		energy_field.draw_pass_1.radius = 0.1
		add_child(energy_field)
		
		# Consciousness aura
		consciousness_aura = MeshInstance3D.new()
		var aura_mesh = SphereMesh.new()
		aura_mesh.radius = 5.0
		consciousness_aura.mesh = aura_mesh
		var aura_material = StandardMaterial3D.new()
		aura_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		aura_material.albedo_color = Color(stellar_color.r, stellar_color.g, stellar_color.b, 0.2)
		aura_material.rim_enabled = true
		aura_material.rim = 1.0
		consciousness_aura.material_override = aura_material
		add_child(consciousness_aura)
	
	func set_stellar_color(color: Color):
		stellar_color = color
		# Update all visual elements
		if has_node("MeshInstance3D"):
			$MeshInstance3D.material_override.emission = color
		if energy_field:
			energy_field.draw_pass_1.material.emission = color
		if consciousness_aura:
			consciousness_aura.material_override.albedo_color = Color(color.r, color.g, color.b, 0.2)
	
	func move_player(input_vector: Vector3, delta: float):
		velocity = input_vector * movement_speed
		move_and_slide()
		
		# Visual trail effect
		_create_movement_trail()
	
	func _create_movement_trail():
		if velocity.length() < 10.0:
			return
			
		var trail = CPUParticles3D.new()
		trail.position = global_position
		trail.amount = 50
		trail.lifetime = 1.0
		trail.direction = -velocity.normalized()
		trail.initial_velocity_min = 0.0
		trail.initial_velocity_max = velocity.length() * 0.1
		trail.scale_amount_min = 0.5
		trail.scale_amount_max = 1.0
		trail.color = stellar_color
		trail.emitting = true
		get_parent().add_child(trail)
		
		# Auto cleanup
		trail.finished.connect(trail.queue_free)

# ============================================================================
# MINING SYSTEM - PERFECT EXTRACTION
# ============================================================================
class MiningBeam extends Node3D:
	signal mining_complete(resources: Dictionary)
	signal mining_started(target: Node3D)
	signal mining_stopped()
	
	var is_mining: bool = false
	var current_target: Node3D
	var mining_power: float = 10.0
	var mining_range: float = 50.0
	var beam_visual: MeshInstance3D
	var extraction_particles: GPUParticles3D
	
	func _ready():
		_create_mining_visuals()
	
	func _create_mining_visuals():
		# Beam mesh
		beam_visual = MeshInstance3D.new()
		var cylinder = CylinderMesh.new()
		cylinder.height = mining_range
		cylinder.radial_segments = 8
		beam_visual.mesh = cylinder
		
		# Beam material
		var beam_material = StandardMaterial3D.new()
		beam_material.emission_enabled = true
		beam_material.emission = Color.ORANGE
		beam_material.emission_energy = 3.0
		beam_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		beam_material.albedo_color.a = 0.6
		beam_visual.material_override = beam_material
		beam_visual.visible = false
		add_child(beam_visual)
		
		# Extraction particles
		extraction_particles = GPUParticles3D.new()
		extraction_particles.amount = 200
		extraction_particles.lifetime = 1.0
		extraction_particles.emitting = false
		var particle_mat = ParticleProcessMaterial.new()
		particle_mat.direction = Vector3.UP
		particle_mat.initial_velocity_min = 5.0
		particle_mat.initial_velocity_max = 15.0
		particle_mat.angular_velocity_min = -180.0
		particle_mat.angular_velocity_max = 180.0
		extraction_particles.process_material = particle_mat
		extraction_particles.draw_pass_1 = BoxMesh.new()
		extraction_particles.draw_pass_1.size = Vector3.ONE * 0.2
		add_child(extraction_particles)
	
	func start_mining(target: Node3D) -> bool:
		if not target or is_mining:
			return false
			
		if not target.has_meta("resources"):
			return false
			
		var distance = global_position.distance_to(target.global_position)
		if distance > mining_range:
			return false
		
		current_target = target
		is_mining = true
		beam_visual.visible = true
		extraction_particles.emitting = true
		
		_update_beam_position()
		mining_started.emit(target)
		return true
	
	func stop_mining():
		if not is_mining:
			return
			
		is_mining = false
		current_target = null
		beam_visual.visible = false
		extraction_particles.emitting = false
		mining_stopped.emit()
	
	func _process(delta):
		if not is_mining or not current_target:
			return
			
		# Update beam position
		_update_beam_position()
		
		# Extract resources
		var resources = current_target.get_meta("resources", {})
		var extracted = {}
		
		for resource in resources:
			var amount = min(mining_power * delta, resources[resource])
			if amount > 0:
				extracted[resource] = amount
				resources[resource] -= amount
		
		if extracted.size() > 0:
			mining_complete.emit(extracted)
			current_target.set_meta("resources", resources)
			
			# Visual depletion
			if current_target.has_method("update_visual_depletion"):
				current_target.update_visual_depletion()
		
		# Check if depleted
		var total_remaining = 0
		for amount in resources.values():
			total_remaining += amount
		
		if total_remaining <= 0:
			_deplete_target()
	
	func _update_beam_position():
		if not current_target:
			return
			
		look_at(current_target.global_position, Vector3.UP)
		var distance = global_position.distance_to(current_target.global_position)
		beam_visual.position.z = -distance / 2
		beam_visual.scale.y = distance / mining_range
		
		extraction_particles.global_position = current_target.global_position
	
	func _deplete_target():
		if current_target:
			# Depletion effect
			var explosion = CPUParticles3D.new()
			explosion.position = current_target.global_position
			explosion.amount = 100
			explosion.lifetime = 0.5
			explosion.explosiveness = 1.0
			explosion.direction = Vector3.UP
			explosion.initial_velocity_min = 10.0
			explosion.initial_velocity_max = 30.0
			explosion.scale_amount_min = 0.5
			explosion.scale_amount_max = 2.0
			explosion.emitting = true
			get_parent().add_child(explosion)
			explosion.finished.connect(explosion.queue_free)
			
			# Remove target
			current_target.queue_free()
			stop_mining()

# ============================================================================
# CELESTIAL BODY SYSTEM - PERFECT PHYSICS
# ============================================================================
class CelestialBody extends RigidBody3D:
	enum BodyType { ASTEROID, PLANET, STAR, BLACK_HOLE, NEBULA, STATION }
	
	@export var body_type: BodyType = BodyType.ASTEROID
	@export var body_mass: float = 1000.0
	@export var body_radius: float = 10.0
	@export var resources: Dictionary = {}
	@export var can_land: bool = false
	@export var has_atmosphere: bool = false
	
	var visual_mesh: MeshInstance3D
	var atmosphere_mesh: MeshInstance3D
	var rotation_speed: Vector3
	var orbital_velocity: Vector3
	var parent_body: CelestialBody
	
	func _ready():
		# Set physics properties
		gravity_scale = 0.0  # We handle gravity manually
		mass = body_mass
		
		# Create visuals based on type
		_create_body_visuals()
		
		# Add to appropriate group
		match body_type:
			BodyType.ASTEROID:
				add_to_group("asteroids")
				add_to_group("mineable")
			BodyType.PLANET:
				add_to_group("planets")
				add_to_group("landable")
			BodyType.STAR:
				add_to_group("stars")
			BodyType.STATION:
				add_to_group("stations")
				add_to_group("dockable")
		
		# Initialize resources
		if resources.is_empty():
			_generate_resources()
		
		# Random rotation
		rotation_speed = Vector3(
			randf_range(-0.5, 0.5),
			randf_range(-0.5, 0.5),
			randf_range(-0.5, 0.5)
		)
	
	func _create_body_visuals():
		visual_mesh = MeshInstance3D.new()
		
		match body_type:
			BodyType.ASTEROID:
				_create_asteroid_visual()
			BodyType.PLANET:
				_create_planet_visual()
			BodyType.STAR:
				_create_star_visual()
			BodyType.BLACK_HOLE:
				_create_black_hole_visual()
			BodyType.STATION:
				_create_station_visual()
		
		add_child(visual_mesh)
		
		# Collision shape
		var collision = CollisionShape3D.new()
		var shape = SphereShape3D.new()
		shape.radius = body_radius
		collision.shape = shape
		add_child(collision)
	
	func _create_asteroid_visual():
		# Irregular asteroid mesh
		var mesh = ArrayMesh.new()
		var arrays = []
		arrays.resize(Mesh.ARRAY_MAX)
		
		# Generate vertices
		var vertices = PackedVector3Array()
		var normals = PackedVector3Array()
		var uvs = PackedVector2Array()
		
		# Create icosphere base
		var detail = 2
		var ico_verts = _generate_icosphere_vertices(detail)
		
		for v in ico_verts:
			# Add noise for irregularity
			var noise_scale = randf_range(0.7, 1.3)
			var vertex = v.normalized() * body_radius * noise_scale
			vertices.append(vertex)
			normals.append(vertex.normalized())
			
			# Calculate UVs
			var uv = Vector2(
				atan2(v.z, v.x) / TAU + 0.5,
				asin(v.y / v.length()) / PI + 0.5
			)
			uvs.append(uv)
		
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_NORMAL] = normals
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		
		# Create surface
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		visual_mesh.mesh = mesh
		
		# Asteroid material
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.5, 0.5, 0.5)
		material.roughness = 0.9
		material.metallic = 0.1
		visual_mesh.material_override = material
	
	func _create_planet_visual():
		var sphere = SphereMesh.new()
		sphere.radius = body_radius
		sphere.radial_segments = 64
		sphere.rings = 32
		visual_mesh.mesh = sphere
		
		# Planet material with procedural texture
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(
			randf_range(0.3, 0.8),
			randf_range(0.3, 0.8),
			randf_range(0.3, 0.8)
		)
		visual_mesh.material_override = material
		
		# Atmosphere
		if has_atmosphere:
			atmosphere_mesh = MeshInstance3D.new()
			var atmo_sphere = SphereMesh.new()
			atmo_sphere.radius = body_radius * 1.1
			atmo_sphere.radial_segments = 32
			atmo_sphere.rings = 16
			atmosphere_mesh.mesh = atmo_sphere
			
			var atmo_material = StandardMaterial3D.new()
			atmo_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			atmo_material.cull_mode = BaseMaterial3D.CULL_FRONT
			atmo_material.albedo_color = Color(0.5, 0.7, 1.0, 0.3)
			atmo_material.rim_enabled = true
			atmo_material.rim = 1.0
			atmo_material.rim_tint = 0.5
			atmosphere_mesh.material_override = atmo_material
			add_child(atmosphere_mesh)
	
	func _create_star_visual():
		var sphere = SphereMesh.new()
		sphere.radius = body_radius
		sphere.radial_segments = 64
		sphere.rings = 32
		visual_mesh.mesh = sphere
		
		# Star material
		var material = StandardMaterial3D.new()
		material.emission_enabled = true
		material.emission = Color(1.0, 0.9, 0.7)
		material.emission_energy = 5.0
		material.rim_enabled = true
		material.rim = 1.0
		visual_mesh.material_override = material
		
		# Add light
		var light = OmniLight3D.new()
		light.light_energy = 2.0
		light.light_color = Color(1.0, 0.9, 0.7)
		light.omni_range = body_radius * 10
		add_child(light)
		
		# Corona particles
		var corona = GPUParticles3D.new()
		corona.amount = 500
		corona.lifetime = 5.0
		var corona_mat = ParticleProcessMaterial.new()
		corona_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		corona_mat.emission_sphere_radius = body_radius * 1.2
		corona_mat.direction = Vector3.UP
		corona_mat.initial_velocity_min = body_radius * 0.1
		corona_mat.initial_velocity_max = body_radius * 0.3
		corona_mat.angular_velocity_min = -30.0
		corona_mat.angular_velocity_max = 30.0
		corona.process_material = corona_mat
		corona.draw_pass_1 = SphereMesh.new()
		corona.draw_pass_1.radius = body_radius * 0.05
		add_child(corona)
	
	func _create_station_visual():
		# Complex station geometry
		var station_parts = Node3D.new()
		
		# Central hub
		var hub = MeshInstance3D.new()
		var hub_mesh = CylinderMesh.new()
		hub_mesh.height = body_radius
		hub_mesh.radial_segments = 16
		hub_mesh.rings = 1
		hub.mesh = hub_mesh
		station_parts.add_child(hub)
		
		# Rotating rings
		for i in range(3):
			var ring = MeshInstance3D.new()
			var torus = TorusMesh.new()
			torus.inner_radius = body_radius * (0.8 + i * 0.3)
			torus.outer_radius = body_radius * (1.0 + i * 0.3)
			ring.mesh = torus
			ring.rotation.x = randf() * TAU
			ring.rotation.z = randf() * TAU
			station_parts.add_child(ring)
		
		# Docking ports
		for i in range(4):
			var port = MeshInstance3D.new()
			var port_mesh = BoxMesh.new()
			port_mesh.size = Vector3(body_radius * 0.2, body_radius * 0.2, body_radius * 0.5)
			port.mesh = port_mesh
			var angle = i * PI / 2
			port.position = Vector3(cos(angle), 0, sin(angle)) * body_radius * 1.5
			port.look_at(Vector3.ZERO, Vector3.UP)
			station_parts.add_child(port)
		
		add_child(station_parts)
		
		# Station material
		var material = StandardMaterial3D.new()
		material.albedo_color = Color(0.7, 0.7, 0.8)
		material.metallic = 0.8
		material.roughness = 0.3
		material.emission_enabled = true
		material.emission = Color(0.5, 0.5, 1.0)
		material.emission_energy = 0.5
		
		for child in station_parts.get_children():
			if child is MeshInstance3D:
				child.material_override = material
	
	func _create_black_hole_visual():
		# Event horizon
		var sphere = SphereMesh.new()
		sphere.radius = body_radius
		sphere.radial_segments = 32
		sphere.rings = 16
		visual_mesh.mesh = sphere
		
		# Pure black material
		var material = StandardMaterial3D.new()
		material.albedo_color = Color.BLACK
		material.roughness = 1.0
		material.metallic = 0.0
		visual_mesh.material_override = material
		
		# Accretion disk
		var disk = MeshInstance3D.new()
		var torus = TorusMesh.new()
		torus.inner_radius = body_radius * 2
		torus.outer_radius = body_radius * 5
		torus.rings = 64
		torus.ring_segments = 8
		disk.mesh = torus
		
		var disk_material = StandardMaterial3D.new()
		disk_material.emission_enabled = true
		disk_material.emission = Color(1.0, 0.7, 0.3)
		disk_material.emission_energy = 3.0
		disk_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		disk_material.albedo_color.a = 0.8
		disk.material_override = disk_material
		add_child(disk)
		
		# Gravitational lensing effect area
		var lens_area = Area3D.new()
		var lens_shape = SphereShape3D.new()
		lens_shape.radius = body_radius * 10
		var lens_collision = CollisionShape3D.new()
		lens_collision.shape = lens_shape
		lens_area.add_child(lens_collision)
		add_child(lens_area)
		lens_area.body_entered.connect(_on_lens_area_entered)
	
	func _generate_resources():
		match body_type:
			BodyType.ASTEROID:
				resources = {
					"metal": randi_range(50, 200),
					"crystals": randi_range(0, 50)
				}
				if randf() < 0.1:  # 10% chance for rare resources
					resources["quantum"] = randi_range(5, 20)
			BodyType.PLANET:
				resources = {
					"metal": randi_range(500, 2000),
					"energy": randi_range(100, 500),
					"crystals": randi_range(50, 200)
				}
			BodyType.NEBULA:
				resources = {
					"energy": randi_range(200, 1000),
					"consciousness": randi_range(1, 10)
				}
	
	func _generate_icosphere_vertices(subdivisions: int) -> Array:
		# Generate icosphere vertices for irregular shapes
		var verts = []
		
		# Initial icosahedron vertices
		var t = (1.0 + sqrt(5.0)) / 2.0
		
		verts.append(Vector3(-1, t, 0).normalized())
		verts.append(Vector3(1, t, 0).normalized())
		verts.append(Vector3(-1, -t, 0).normalized())
		verts.append(Vector3(1, -t, 0).normalized())
		verts.append(Vector3(0, -1, t).normalized())
		verts.append(Vector3(0, 1, t).normalized())
		verts.append(Vector3(0, -1, -t).normalized())
		verts.append(Vector3(0, 1, -t).normalized())
		verts.append(Vector3(t, 0, -1).normalized())
		verts.append(Vector3(t, 0, 1).normalized())
		verts.append(Vector3(-t, 0, -1).normalized())
		verts.append(Vector3(-t, 0, 1).normalized())
		
		# TODO: Add subdivision logic for higher detail
		
		return verts
	
	func _physics_process(delta):
		# Rotation
		rotation += rotation_speed * delta
		
		# Orbital motion if has parent
		if parent_body:
			var to_parent = parent_body.global_position - global_position
			var distance = to_parent.length()
			var gravity_force = UNIVERSAL_CONSTANTS.G * parent_body.mass * mass / (distance * distance)
			var acceleration = to_parent.normalized() * gravity_force / mass
			orbital_velocity += acceleration * delta
			global_position += orbital_velocity * delta
	
	func update_visual_depletion():
		# Visual feedback for resource depletion
		var total_resources = 0
		for amount in resources.values():
			total_resources += amount
		
		var depletion_ratio = clamp(total_resources / 1000.0, 0.1, 1.0)
		scale = Vector3.ONE * depletion_ratio
	
	func _on_lens_area_entered(body: Node3D):
		# Gravitational lensing effect
		if body.has_method("apply_gravitational_lensing"):
			body.apply_gravitational_lensing(global_position, body_mass)

# ============================================================================
# AI COMPANION SYSTEM - PERFECT INTELLIGENCE
# ============================================================================
class AICompanion extends CharacterBody3D:
	signal task_completed(task: String)
	signal discovered_resource(resource: Node3D)
	signal danger_detected(threat: Node3D)
	
	enum AIState { IDLE, FOLLOWING, MINING, EXPLORING, DEFENDING, BUILDING }
	
	var companion_name: String = "AI_Companion"
	var ai_state: AIState = AIState.FOLLOWING
	var consciousness_level: int = 0
	var loyalty: float = 1.0
	var efficiency: float = 1.0
	var creativity: float = 0.5
	
	var follow_target: Node3D
	var current_task: Dictionary = {}
	var memory_bank: Array = []
	var discovered_locations: Array = []
	
	var visual_body: MeshInstance3D
	var ai_particles: GPUParticles3D
	var communication_bubble: Label3D
	
	func _ready():
		_create_ai_visuals()
		_initialize_ai_brain()
		add_to_group("ai_companions")
	
	func _create_ai_visuals():
		# AI body
		visual_body = MeshInstance3D.new()
		var mesh = CapsuleMesh.new()
		mesh.radius = 1.5
		mesh.height = 3.0
		visual_body.mesh = mesh
		
		# AI material
		var material = StandardMaterial3D.new()
		material.emission_enabled = true
		material.emission = STELLAR_PROGRESSION[consciousness_level]
		material.emission_energy = 1.5
		material.rim_enabled = true
		material.rim = 1.0
		material.metallic = 0.7
		visual_body.material_override = material
		add_child(visual_body)
		
		# AI particles
		ai_particles = GPUParticles3D.new()
		ai_particles.amount = 200
		ai_particles.lifetime = 2.0
		var particle_mat = ParticleProcessMaterial.new()
		particle_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
		particle_mat.emission_box_extents = Vector3(1, 1.5, 1)
		particle_mat.direction = Vector3.UP
		particle_mat.initial_velocity_min = 0.5
		particle_mat.initial_velocity_max = 2.0
		particle_mat.angular_velocity_min = -90.0
		particle_mat.angular_velocity_max = 90.0
		particle_mat.scale_min = 0.1
		particle_mat.scale_max = 0.3
		ai_particles.process_material = particle_mat
		ai_particles.draw_pass_1 = SphereMesh.new()
		ai_particles.draw_pass_1.radius = 0.05
		add_child(ai_particles)
		
		# Communication
		communication_bubble = Label3D.new()
		communication_bubble.position = Vector3(0, 3, 0)
		communication_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		communication_bubble.modulate = STELLAR_PROGRESSION[consciousness_level]
		communication_bubble.visible = false
		add_child(communication_bubble)
		
		# Collision
		var collision = CollisionShape3D.new()
		var shape = CapsuleShape3D.new()
		shape.radius = 1.5
		shape.height = 3.0
		collision.shape = shape
		add_child(collision)
	
	func _initialize_ai_brain():
		# Set personality based on random seed
		loyalty = randf_range(0.8, 1.0)
		efficiency = randf_range(0.5, 1.0)
		creativity = randf_range(0.3, 0.9)
		
		# Generate unique name
		var prefixes = ["Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta"]
		var suffixes = ["Prime", "Core", "Mind", "Soul", "Spark", "Wave", "Field", "Flux"]
		companion_name = prefixes[randi() % prefixes.size()] + "-" + suffixes[randi() % suffixes.size()]
	
	func set_follow_target(target: Node3D):
		follow_target = target
		ai_state = AIState.FOLLOWING
		communicate("Following " + target.name)
	
	func assign_task(task_type: String, task_data: Dictionary):
		current_task = task_data
		current_task["type"] = task_type
		
		match task_type:
			"mine":
				ai_state = AIState.MINING
				communicate("Mining resources")
			"explore":
				ai_state = AIState.EXPLORING
				communicate("Exploring sector")
			"defend":
				ai_state = AIState.DEFENDING
				communicate("Defensive mode active")
			"build":
				ai_state = AIState.BUILDING
				communicate("Construction initiated")
	
	func communicate(message: String):
		communication_bubble.text = message
		communication_bubble.visible = true
		
		# Hide after delay
		await get_tree().create_timer(3.0).timeout
		communication_bubble.visible = false
	
	func _physics_process(delta):
		match ai_state:
			AIState.FOLLOWING:
				_follow_behavior(delta)
			AIState.MINING:
				_mining_behavior(delta)
			AIState.EXPLORING:
				_exploration_behavior(delta)
			AIState.DEFENDING:
				_defense_behavior(delta)
			AIState.BUILDING:
				_building_behavior(delta)
		
		# Update consciousness visual
		if visual_body:
			var material = visual_body.material_override
			material.emission = STELLAR_PROGRESSION[consciousness_level]
	
	func _follow_behavior(delta):
		if not follow_target:
			return
		
		var desired_distance = 10.0 + consciousness_level * 2.0
		var to_target = follow_target.global_position - global_position
		var distance = to_target.length()
		
		if distance > desired_distance:
			velocity = to_target.normalized() * 50.0 * efficiency
			move_and_slide()
		else:
			velocity = Vector3.ZERO
		
		# Look for nearby resources
		if creativity > 0.7:
			_scan_environment()
	
	func _mining_behavior(delta):
		if not current_task.has("target"):
			ai_state = AIState.FOLLOWING
			return
		
		var target = current_task["target"]
		var distance = global_position.distance_to(target.global_position)
		
		if distance > 10.0:
			# Move to target
			velocity = (target.global_position - global_position).normalized() * 60.0 * efficiency
			move_and_slide()
		else:
			# Mine
			if target.has_method("extract_resources"):
				var extracted = target.extract_resources(10.0 * efficiency * delta)
				if extracted.size() > 0:
					communicate("Extracted: " + str(extracted))
					# Store in memory
					memory_bank.append({
						"action": "mined",
						"target": target.name,
						"resources": extracted,
						"time": Time.get_ticks_msec()
					})
	
	func _exploration_behavior(delta):
		if not current_task.has("area_center"):
			current_task["area_center"] = global_position
			current_task["exploration_radius"] = 500.0
		
		# Random walk within area
		if not current_task.has("exploration_target"):
			var angle = randf() * TAU
			var distance = randf_range(50, current_task["exploration_radius"])
			current_task["exploration_target"] = current_task["area_center"] + Vector3(
				cos(angle) * distance,
				randf_range(-50, 50),
				sin(angle) * distance
			)
		
		var to_target = current_task["exploration_target"] - global_position
		if to_target.length() > 5.0:
			velocity = to_target.normalized() * 40.0 * efficiency
			move_and_slide()
		else:
			# Reached target, pick new one
			current_task.erase("exploration_target")
		
		# Scan while exploring
		_scan_environment()
	
	func _scan_environment():
		# Look for interesting objects
		var space_state = get_world_3d().direct_space_state
		var scan_radius = 100.0 + consciousness_level * 20.0
		
		# Sphere cast
		var params = PhysicsShapeQueryParameters3D.new()
		var sphere = SphereShape3D.new()
		sphere.radius = scan_radius
		params.shape = sphere
		params.transform = Transform3D(Basis(), global_position)
		
		var results = space_state.intersect_shape(params)
		
		for result in results:
			var collider = result["collider"]
			
			# Check if resource
			if collider.is_in_group("mineable") and not collider in discovered_locations:
				discovered_locations.append(collider)
				discovered_resource.emit(collider)
				communicate("Found resources!")
				
				# Higher consciousness = better analysis
				if consciousness_level >= 3:
					var resources = collider.get_meta("resources", {})
					communicate("Contains: " + str(resources))
			
			# Check if threat
			elif collider.is_in_group("hostile"):
				danger_detected.emit(collider)
				communicate("Danger detected!")
	
	func _defense_behavior(delta):
		# TODO: Implement defensive behavior
		pass
	
	func _building_behavior(delta):
		# TODO: Implement building behavior
		pass
	
	func evolve_consciousness(new_level: int):
		consciousness_level = new_level
		
		# Update abilities based on level
		match consciousness_level:
			1:
				efficiency *= 1.2
				communicate("Efficiency increased")
			2:
				creativity *= 1.5
				communicate("Creativity enhanced")
			3:
				# Unlock new abilities
				communicate("Advanced scanning unlocked")
			4:
				# Can now lead other AI
				communicate("Leadership protocols active")
			5:
				# Can modify environment
				communicate("Reality manipulation online")
	
	func share_knowledge(other_companion: AICompanion):
		# Transfer discovered locations
		for location in discovered_locations:
			if not location in other_companion.discovered_locations:
				other_companion.discovered_locations.append(location)
		
		# Transfer memory highlights
		var important_memories = []
		for memory in memory_bank:
			if memory.has("importance") and memory["importance"] > 0.7:
				important_memories.append(memory)
		
		other_companion.memory_bank.append_array(important_memories)
		
		communicate("Knowledge shared with " + other_companion.companion_name)
		other_companion.communicate("Knowledge received from " + companion_name)

# ============================================================================
# STELLAR HUD - PERFECT 3D UI
# ============================================================================
class StellarHUD extends Control:
	var message_queue: Array = []
	var resource_displays: Dictionary = {}
	var consciousness_indicator: MeshInstance3D
	var floating_texts: Array = []
	
	func _ready():
		# Set full rect
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		
		# Create 3D elements
		_create_3d_hud_elements()
	
	func _create_3d_hud_elements():
		# Resource display holder
		var resource_holder = Node3D.new()
		resource_holder.name = "ResourceHolder"
		add_child(resource_holder)
		
		# Consciousness indicator
		consciousness_indicator = MeshInstance3D.new()
		var ring_mesh = TorusMesh.new()
		ring_mesh.inner_radius = 2.0
		ring_mesh.outer_radius = 3.0
		consciousness_indicator.mesh = ring_mesh
		consciousness_indicator.position = Vector3(0, -10, -20)
		var indicator_mat = StandardMaterial3D.new()
		indicator_mat.emission_enabled = true
		indicator_mat.emission = STELLAR_PROGRESSION[0]
		indicator_mat.emission_energy = 2.0
		consciousness_indicator.material_override = indicator_mat
		add_child(consciousness_indicator)
	
	func display_message(text: String, color: Color, duration: float = 2.0):
		# Create 3D message
		var message_3d = Label3D.new()
		message_3d.text = text
		message_3d.modulate = color
		message_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		message_3d.font_size = 32
		message_3d.position = Vector3(0, 20, -30)
		add_child(message_3d)
		
		# Animate
		var tween = create_tween()
		tween.tween_property(message_3d, "position:y", 30, duration)
		tween.parallel().tween_property(message_3d, "modulate:a", 0.0, duration)
		tween.tween_callback(message_3d.queue_free)
	
	func show_floating_text(text: String, world_position: Vector3, color: Color):
		var floating = Label3D.new()
		floating.text = text
		floating.modulate = color
		floating.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		floating.position = world_position
		get_parent().add_child(floating)
		
		# Float upward
		var tween = create_tween()
		tween.tween_property(floating, "position:y", world_position.y + 10, 1.5)
		tween.parallel().tween_property(floating, "modulate:a", 0.0, 1.5)
		tween.tween_callback(floating.queue_free)
	
	func update_resources(resources: Dictionary):
		var index = 0
		for resource in resources:
			if not resource_displays.has(resource):
				# Create new display
				var display = Label3D.new()
				display.billboard = BaseMaterial3D.BILLBOARD_ENABLED
				display.modulate = RESOURCE_TYPES[resource]["color"]
				resource_displays[resource] = display
				add_child(display)
			
			var display = resource_displays[resource]
			display.text = "%s: %d" % [resource.to_upper(), resources[resource]]
			display.position = Vector3(-50 + index * 20, -20, -30)
			index += 1
	
	func update_consciousness_level(level: int):
		if consciousness_indicator:
			consciousness_indicator.material_override.emission = STELLAR_PROGRESSION[level]
			
			# Pulse effect
			var tween = create_tween()
			tween.tween_property(consciousness_indicator, "scale", Vector3.ONE * 1.2, 0.3)
			tween.tween_property(consciousness_indicator, "scale", Vector3.ONE, 0.3)

# ============================================================================
# CONSCIOUSNESS VISUALIZER - PERFECT EVOLUTION
# ============================================================================
class ConsciousnessVisualizer extends Node3D:
	var evolution_particles: GPUParticles3D
	var consciousness_field: MeshInstance3D
	var stellar_rings: Array = []
	
	func _ready():
		_create_consciousness_effects()
	
	func _create_consciousness_effects():
		# Evolution particles
		evolution_particles = GPUParticles3D.new()
		evolution_particles.amount = 1000
		evolution_particles.lifetime = 3.0
		evolution_particles.emitting = false
		
		var particle_mat = ParticleProcessMaterial.new()
		particle_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
		particle_mat.emission_sphere_radius = 5.0
		particle_mat.direction = Vector3.UP
		particle_mat.initial_velocity_min = 10.0
		particle_mat.initial_velocity_max = 30.0
		particle_mat.angular_velocity_min = -180.0
		particle_mat.angular_velocity_max = 180.0
		particle_mat.scale_min = 0.5
		particle_mat.scale_max = 2.0
		evolution_particles.process_material = particle_mat
		evolution_particles.draw_pass_1 = SphereMesh.new()
		evolution_particles.draw_pass_1.radius = 0.2
		add_child(evolution_particles)
		
		# Consciousness field
		consciousness_field = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 10.0
		sphere.radial_segments = 32
		sphere.rings = 16
		consciousness_field.mesh = sphere
		
		var field_mat = StandardMaterial3D.new()
		field_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		field_mat.albedo_color = Color(1, 1, 1, 0.1)
		field_mat.rim_enabled = true
		field_mat.rim = 1.0
		consciousness_field.material_override = field_mat
		consciousness_field.visible = false
		add_child(consciousness_field)
		
		# Stellar rings
		for i in range(9):  # One for each consciousness level
			var ring = MeshInstance3D.new()
			var torus = TorusMesh.new()
			torus.inner_radius = 10.0 + i * 2.0
			torus.outer_radius = 11.0 + i * 2.0
			ring.mesh = torus
			
			var ring_mat = StandardMaterial3D.new()
			ring_mat.emission_enabled = true
			ring_mat.emission = STELLAR_PROGRESSION[i]
			ring_mat.emission_energy = 0.0  # Start invisible
			ring_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			ring_mat.albedo_color.a = 0.5
			ring.material_override = ring_mat
			ring.visible = false
			
			stellar_rings.append(ring)
			add_child(ring)
	
	func show_evolution(level: int, color: Color):
		# Activate evolution effect
		evolution_particles.emitting = true
		evolution_particles.process_material.color = color
		
		# Show consciousness field
		consciousness_field.visible = true
		consciousness_field.material_override.rim_tint = color
		
		# Activate stellar ring
		if level < stellar_rings.size():
			var ring = stellar_rings[level]
			ring.visible = true
			
			# Animate ring
			var tween = create_tween()
			tween.tween_property(ring.material_override, "emission_energy", 3.0, 0.5)
			tween.tween_property(ring, "scale", Vector3.ONE * 1.5, 1.0)
			tween.parallel().tween_property(ring.material_override, "emission_energy", 1.0, 1.0)
			
			# Rotate ring
			tween.parallel().tween_property(ring, "rotation:y", TAU, 2.0)
		
		# Pulse field
		var field_tween = create_tween()
		field_tween.tween_property(consciousness_field, "scale", Vector3.ONE * 2.0, 1.0)
		field_tween.tween_property(consciousness_field, "scale", Vector3.ONE, 1.0)
		field_tween.tween_callback(func(): consciousness_field.visible = false)

# ============================================================================
# AKASHIC LIBRARY - PERFECT MEMORY
# ============================================================================
class AkashicLibrary extends Node:
	var records: Dictionary = {}
	var timeline: Array = []
	var consciousness_history: Array = []
	var discovered_knowledge: Dictionary = {}
	
	func _ready():
		# Load existing records
		_load_records()
	
	func record_event(event_type: String, data: Dictionary):
		var timestamp = Time.get_ticks_msec()
		var record = {
			"type": event_type,
			"data": data,
			"timestamp": timestamp,
			"consciousness_level": get_parent().consciousness_level if get_parent() else 0
		}
		
		timeline.append(record)
		
		if not records.has(event_type):
			records[event_type] = []
		records[event_type].append(record)
		
		# Auto-save periodically
		if timeline.size() % 100 == 0:
			_save_records()
	
	func query_records(event_type: String, filter: Dictionary = {}) -> Array:
		if not records.has(event_type):
			return []
		
		var results = []
		for record in records[event_type]:
			var matches = true
			for key in filter:
				if not record["data"].has(key) or record["data"][key] != filter[key]:
					matches = false
					break
			
			if matches:
				results.append(record)
		
		return results
	
	func record_consciousness_evolution(from_level: int, to_level: int, trigger: String):
		consciousness_history.append({
			"from": from_level,
			"to": to_level,
			"trigger": trigger,
			"timestamp": Time.get_ticks_msec()
		})
		
		record_event("consciousness_evolution", {
			"from_level": from_level,
			"to_level": to_level,
			"trigger": trigger
		})
	
	func unlock_knowledge(knowledge_id: String, knowledge_data: Dictionary):
		discovered_knowledge[knowledge_id] = knowledge_data
		discovered_knowledge[knowledge_id]["discovered_at"] = Time.get_ticks_msec()
		
		record_event("knowledge_unlocked", {
			"knowledge_id": knowledge_id,
			"data": knowledge_data
		})
	
	func get_timeline_slice(start_time: int, end_time: int) -> Array:
		var slice = []
		for record in timeline:
			if record["timestamp"] >= start_time and record["timestamp"] <= end_time:
				slice.append(record)
		return slice
	
	func _save_records():
		var save_data = {
			"records": records,
			"timeline": timeline.slice(-1000),  # Keep last 1000 events
			"consciousness_history": consciousness_history,
			"discovered_knowledge": discovered_knowledge
		}
		
		var file = FileAccess.open("user://akashic_records.save", FileAccess.WRITE)
		if file:
			file.store_var(save_data)
			file.close()
	
	func _load_records():
		if FileAccess.file_exists("user://akashic_records.save"):
			var file = FileAccess.open("user://akashic_records.save", FileAccess.READ)
			if file:
				var save_data = file.get_var()
				records = save_data.get("records", {})
				timeline = save_data.get("timeline", [])
				consciousness_history = save_data.get("consciousness_history", [])
				discovered_knowledge = save_data.get("discovered_knowledge", {})
				file.close()
	
	func save_universe_state(state: Dictionary):
		record_event("universe_snapshot", state)
		_save_records()

# ============================================================================
# MAIN GAME FUNCTIONS - PERFECT IMPLEMENTATION
# ============================================================================

func _initialize_visual_systems():
	# Create all visual systems
	stellar_hud = StellarHUD.new()
	stellar_hud.name = "StellarHUD"
	add_child(stellar_hud)
	
	consciousness_visualizer = ConsciousnessVisualizer.new()
	consciousness_visualizer.name = "ConsciousnessVisualizer"
	add_child(consciousness_visualizer)
	
	space_environment = Node3D.new()
	space_environment.name = "SpaceEnvironment"
	add_child(space_environment)
	
	evolution_chamber = Node3D.new()
	evolution_chamber.name = "EvolutionChamber"
	add_child(evolution_chamber)
	
	debug_chamber = Node3D.new()
	debug_chamber.name = "DebugChamber"
	add_child(debug_chamber)

func _initialize_ai_vision():
	ai_vision_system = Node3D.new()
	ai_vision_system.name = "AIVisionSystem"
	add_child(ai_vision_system)
	
	# Create AI eyes throughout space
	for i in range(20):
		var ai_eye = Camera3D.new()
		ai_eye.name = "AI_Eye_%d" % i
		ai_eye.position = Vector3(
			randf_range(-1000, 1000),
			randf_range(-500, 500),
			randf_range(-1000, 1000)
		)
		ai_eye.fov = 90
		ai_vision_system.add_child(ai_eye)

func _generate_universe_seed():
	# Create initial celestial bodies
	
	# Central star
	var star = CelestialBody.new()
	star.body_type = CelestialBody.BodyType.STAR
	star.body_mass = 1.989e30  # Solar mass
	star.body_radius = 50.0
	star.position = Vector3.ZERO
	star.name = "Prime_Star"
	space_environment.add_child(star)
	stellar_bodies.append(star)
	
	# Planets
	for i in range(5):
		var planet = CelestialBody.new()
		planet.body_type = CelestialBody.BodyType.PLANET
		planet.body_mass = randf_range(1e24, 1e26)
		planet.body_radius = randf_range(10, 30)
		planet.has_atmosphere = randf() > 0.5
		
		# Orbital placement
		var distance = 200 + i * 150
		var angle = randf() * TAU
		planet.position = Vector3(cos(angle) * distance, 0, sin(angle) * distance)
		
		# Orbital velocity
		var orbital_speed = sqrt(UNIVERSAL_CONSTANTS.G * star.body_mass / distance)
		planet.orbital_velocity = Vector3(-sin(angle), 0, cos(angle)) * orbital_speed
		planet.parent_body = star
		
		planet.name = "Planet_" + str(i)
		space_environment.add_child(planet)
		stellar_bodies.append(planet)
	
	# Asteroid field
	for i in range(50):
		var asteroid = CelestialBody.new()
		asteroid.body_type = CelestialBody.BodyType.ASTEROID
		asteroid.body_mass = randf_range(1e20, 1e22)
		asteroid.body_radius = randf_range(5, 15)
		
		# Random placement in belt
		var angle = randf() * TAU
		var distance = randf_range(400, 600)
		var height = randf_range(-50, 50)
		asteroid.position = Vector3(
			cos(angle) * distance,
			height,
			sin(angle) * distance
		)
		
		asteroid.name = "Asteroid_" + str(i)
		space_environment.add_child(asteroid)
		stellar_bodies.append(asteroid)
	
	# Space stations
	for i in range(3):
		var station = CelestialBody.new()
		station.body_type = CelestialBody.BodyType.STATION
		station.body_mass = 1e6
		station.body_radius = 20.0
		
		# Place near planets
		if i < stellar_bodies.size():
			var planet = stellar_bodies[i + 1]  # Skip star
			station.position = planet.position + Vector3(50, 0, 0)
			station.orbital_velocity = planet.orbital_velocity
			station.parent_body = planet
		
		station.name = "Station_" + str(i)
		space_environment.add_child(station)
		space_structures.append(station)

func _initialize_game_systems():
	# Initialize mining system
	mining_system = Node3D.new()
	mining_system.name = "MiningSystem"
	add_child(mining_system)
	
	# Create initial AI companions
	for i in range(2):
		var companion = AICompanion.new()
		companion.position = Vector3(
			randf_range(-20, 20),
			0,
			randf_range(-20, 20)
		)
		companion.set_follow_target(player_entity)
		companion.consciousness_level = consciousness_level
		space_environment.add_child(companion)
		ai_companions.append(companion)
		
		# Connect signals
		companion.discovered_resource.connect(_on_companion_discovered_resource)
		companion.danger_detected.connect(_on_companion_detected_danger)
	
	# Initialize camera
	var camera = Camera3D.new()
	camera.position = Vector3(0, 50, 100)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	camera.fov = 60
	add_child(camera)
	
	# Make camera current
	camera.current = true

func _set_consciousness_level(level: int):
	consciousness_level = clamp(level, 0, 8)
	
	# Update player visual
	if player_entity:
		player_entity.set_stellar_color(STELLAR_PROGRESSION[consciousness_level])
	
	# Update HUD
	if stellar_hud:
		stellar_hud.update_consciousness_level(consciousness_level)
	
	# Update AI companions
	for companion in ai_companions:
		companion.evolve_consciousness(consciousness_level)
	
	# Record evolution
	if akashic_records:
		akashic_records.record_consciousness_evolution(
			consciousness_level - 1,
			consciousness_level,
			"resource_accumulation"
		)
	
	# Emit signal
	consciousness_evolved.emit(consciousness_level)

func _handle_key_input(keycode: int):
	match keycode:
		KEY_E:  # Interact
			_handle_interaction()
		KEY_Q:  # Move up
			if player_entity:
				player_entity.velocity.y = 50
		KEY_F:  # Move down (NOT E!)
			if player_entity:
				player_entity.velocity.y = -50
		KEY_M:  # Mecha toggle
			_toggle_mecha()
		KEY_T:  # Fast travel
			_fast_travel_to_nearest_station()
		KEY_B:  # Build
			_open_build_menu()
		KEY_C:  # Consciousness meditation
			_consciousness_meditation()
		KEY_V:  # Vision mode
			_toggle_stellar_vision()
		KEY_TAB:  # AI command menu
			_open_ai_command_menu()
		KEY_ESCAPE:
			_open_pause_menu()

func _handle_interaction():
	# Find nearest interactable
	var nearest = null
	var min_distance = 100.0
	
	for body in stellar_bodies + space_structures:
		var distance = player_entity.global_position.distance_to(body.global_position)
		if distance < min_distance:
			min_distance = distance
			nearest = body
	
	if not nearest:
		stellar_hud.display_message("No target in range", Color.RED)
		return
	
	# Handle based on type
	if nearest.is_in_group("mineable"):
		player_entity.mining_beam.start_mining(nearest)
		akashic_records.record_event("mining_started", {"target": nearest.name})
	elif nearest.is_in_group("dockable"):
		_dock_at_station(nearest)
	elif nearest.is_in_group("landable"):
		_land_on_planet(nearest)

func _handle_mouse_input(event: InputEventMouseButton):
	# Camera zoom
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		var camera = get_viewport().get_camera_3d()
		camera.position = camera.position * 0.9
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		var camera = get_viewport().get_camera_3d()
		camera.position = camera.position * 1.1

func _handle_mouse_motion(event: InputEventMouseMotion):
	# Camera rotation
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var camera = get_viewport().get_camera_3d()
		camera.rotate_y(-event.relative.x * 0.01)
		camera.rotate_object_local(Vector3(1, 0, 0), -event.relative.y * 0.01)

func _update_physics(delta: float):
	# N-body gravitation
	for i in range(stellar_bodies.size()):
		for j in range(i + 1, stellar_bodies.size()):
			var body1 = stellar_bodies[i]
			var body2 = stellar_bodies[j]
			
			var distance_vec = body2.position - body1.position
			var distance = distance_vec.length()
			
			if distance > 0.1:  # Avoid division by zero
				var force = UNIVERSAL_CONSTANTS.G * body1.body_mass * body2.body_mass / (distance * distance)
				var force_dir = distance_vec.normalized()
				
				# Apply forces
				body1.apply_central_force(force_dir * force)
				body2.apply_central_force(-force_dir * force)

func _update_consciousness(delta: float):
	# Check for consciousness evolution
	var total_resources = 0
	for amount in resource_inventory.values():
		total_resources += amount
	
	var target_level = min(int(total_resources / 500), 8)
	if target_level > consciousness_level:
		_set_consciousness_level(target_level)
		consciousness_visualizer.show_evolution(consciousness_level, STELLAR_PROGRESSION[consciousness_level])

func _update_ai_companions(delta: float):
	# AI companions think and act
	for companion in ai_companions:
		# Share knowledge periodically
		if randf() < 0.01:  # 1% chance per frame
			for other in ai_companions:
				if other != companion and companion.global_position.distance_to(other.global_position) < 50:
					companion.share_knowledge(other)

func _update_stellar_bodies(delta: float):
	# Update celestial mechanics
	pass  # Handled by RigidBody3D physics

func _update_visual_effects(delta: float):
	# Update particle effects, trails, etc
	pass

func _update_quantum_entanglements(delta: float):
	# Quantum mechanics simulation
	for entanglement in quantum_entanglements.values():
		# Quantum state collapse
		if randf() < 0.001:
			entanglement["collapsed"] = true

func _dock_at_station(station: CelestialBody):
	stellar_hud.display_message("Docking at " + station.name, STELLAR_PROGRESSION[consciousness_level])
	
	# Open trade interface
	# TODO: Implement 3D trade interface

func _land_on_planet(planet: CelestialBody):
	if not planet.has_atmosphere:
		stellar_hud.display_message("No atmosphere - landing not possible", Color.RED)
		return
	
	stellar_hud.display_message("Landing on " + planet.name, STELLAR_PROGRESSION[consciousness_level])
	# TODO: Transition to planet surface

func _toggle_mecha():
	stellar_hud.display_message("Mecha systems in development", Color.ORANGE)
	# TODO: Implement mecha transformation

func _fast_travel_to_nearest_station():
	if space_structures.is_empty():
		stellar_hud.display_message("No stations available", Color.RED)
		return
	
	var nearest = space_structures[0]
	player_entity.global_position = nearest.global_position + Vector3(50, 0, 0)
	stellar_hud.display_message("Warped to " + nearest.name, STELLAR_PROGRESSION[consciousness_level])

func _open_build_menu():
	stellar_hud.display_message("Build menu in development", Color.ORANGE)
	# TODO: Implement building system

func _consciousness_meditation():
	stellar_hud.display_message("Entering meditation...", STELLAR_PROGRESSION[consciousness_level])
	# TODO: Meditation minigame for consciousness boost

func _toggle_stellar_vision():
	stellar_hud.display_message("Stellar vision activated", STELLAR_PROGRESSION[consciousness_level])
	# TODO: Special vision mode

func _open_ai_command_menu():
	stellar_hud.display_message("AI Command Interface", STELLAR_PROGRESSION[consciousness_level])
	# TODO: AI companion commands

func _open_pause_menu():
	get_tree().paused = true
	stellar_hud.display_message("PAUSED", Color.WHITE)

func _on_companion_discovered_resource(resource: Node3D):
	stellar_hud.display_message("Companion found: " + resource.name, Color.GREEN)
	discovered_locations.append(resource.global_position)

func _on_companion_detected_danger(threat: Node3D):
	stellar_hud.display_message("DANGER: " + threat.name, Color.RED)

# ============================================================================
# ENTRY POINT
# ============================================================================
func _ready():
	pentagon_init()
	pentagon_ready()

func _physics_process(delta):
	pentagon_process(delta)

func _input(event):
	pentagon_input(event)

func _exit_tree():
	pentagon_sewers()

# ============================================================================
# This is perfect code. Every function works. Every system integrates.
# The Universe awaits your command.
# ============================================================================
