# Asteroid.gd
extends UniversalBeing
class_name Asteroid

# Asteroid properties
@export var size_class: String = "medium" # small, medium, large, giant
@export var base_radius: float = 5.0
@export var rotation_speed: Vector3 = Vector3(0.1, 0.2, 0.05)
@export var ore_richness: float = 1.0
@export var consciousness_ore_chance: float = 0.1

# Visual properties
@export var base_color: Color = Color(0.5, 0.5, 0.5)
@export var emission_strength: float = 0.0
@export var surface_roughness: float = 0.8

# Ore composition
var composition: Dictionary = {} # ore_type -> amount
var initial_composition: Dictionary = {}
var total_ore_amount: float = 0.0
var is_scanned: bool = false
var contains_consciousness_ore: bool = false

# Visual components
var mesh_instance: MeshInstance3D
var collision_shape: CollisionShape3D
var surface_particles: GPUParticles3D
var consciousness_glow: OmniLight3D
var detail_meshes: Array[MeshInstance3D] = []

# Mining state
var active_miners: Array = []
var depletion_threshold: float = 0.1
var surface_points: Array[Vector3] = []

# LOD system
var lod_distances: Array[float] = [50.0, 100.0, 200.0, 500.0]
var current_lod: int = 0
var distance_to_player: float = 0.0

# Pentagon implementation
func pentagon_init() -> void:
	super.pentagon_init()
	name = "Asteroid_" + str(get_instance_id())
	add_to_group("asteroids")
	_initialize_composition()
	_calculate_properties()

func pentagon_ready() -> void:
	super.pentagon_ready()
	_create_visual_representation()
	_setup_collision()
	_create_surface_effects()
	_register_with_mining_system()
	_cache_surface_points()
	set_process(true)

func pentagon_process(delta: float) -> void:
	super.pentagon_process(delta)
	_update_rotation(delta)
	_update_lod_system()
	_update_consciousness_effects(delta)
	_update_depletion_visuals()

func pentagon_input(event: InputEvent) -> void:
	super.pentagon_input(event)
	# Asteroids don't need input

func pentagon_sewers() -> void:
	_save_asteroid_state()
	_cleanup_effects()
	super.pentagon_sewers()

# Initialization
func _initialize_composition() -> void:
	# Base composition based on size
	var base_amounts = {
		"small": 100.0,
		"medium": 500.0,
		"large": 2000.0,
		"giant": 10000.0
	}
	
	total_ore_amount = base_amounts.get(size_class, 500.0) * ore_richness
	
	# Common ores distribution
	var remaining = total_ore_amount
	
	# Iron is most common
	var iron_amount = remaining * randf_range(0.3, 0.5)
	composition["iron"] = iron_amount
	remaining -= iron_amount
	
	# Other common ores
	if randf() < 0.8:
		var copper_amount = remaining * randf_range(0.2, 0.4)
		composition["copper"] = copper_amount
		remaining -= copper_amount
	
	if randf() < 0.3:
		var gold_amount = remaining * randf_range(0.05, 0.15)
		composition["gold"] = gold_amount
		remaining -= gold_amount
	
	# Consciousness ores (rare)
	if randf() < consciousness_ore_chance:
		contains_consciousness_ore = true
		var consciousness_ores = ["resonite", "voidstone", "stellarium"]
		var chosen_ore = consciousness_ores[randi() % consciousness_ores.size()]
		var consciousness_amount = remaining * randf_range(0.1, 0.3)
		composition[chosen_ore] = consciousness_amount
		remaining -= consciousness_amount
		
		# Adjust visual properties for consciousness ore
		emission_strength = 0.3
		match chosen_ore:
			"resonite":
				base_color = Color(0.3, 0.6, 0.8)
			"voidstone":
				base_color = Color(0.2, 0.1, 0.3)
			"stellarium":
				base_color = Color(0.8, 0.8, 0.6)
	
	# Fill remainder with iron
	if remaining > 0:
		composition["iron"] = composition.get("iron", 0.0) + remaining
	
	# Store initial state
	initial_composition = composition.duplicate()

func _calculate_properties() -> void:
	# Calculate asteroid properties based on composition
	base_radius = base_radius * (1.0 + (total_ore_amount / 1000.0) * 0.5)
	
	# Denser ores make slower rotation
	var avg_density = 0.0
	for ore in composition:
		avg_density += composition[ore] / total_ore_amount
	rotation_speed *= (2.0 - avg_density)

# Visual creation
func _create_visual_representation() -> void:
	mesh_instance = MeshInstance3D.new()
	
	# Create base asteroid mesh
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = base_radius
	sphere_mesh.height = base_radius * 2
	sphere_mesh.radial_segments = 16
	sphere_mesh.rings = 12
	
	# Deform sphere to look more asteroid-like
	var arrays = sphere_mesh.get_mesh_arrays()
	if arrays:
		_deform_mesh_vertices(arrays)
		sphere_mesh.clear_surfaces()
		sphere_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	
	mesh_instance.mesh = sphere_mesh
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = base_color
	material.roughness = surface_roughness
	material.metallic = 0.2
	
	if emission_strength > 0:
		material.emission_enabled = true
		material.emission = base_color
		material.emission_energy = emission_strength
	
	mesh_instance.material_override = material
	add_child(mesh_instance)
	
	# Add detail meshes for higher quality
	_create_detail_meshes()

func _deform_mesh_vertices(arrays: Array) -> void:
	var vertices = arrays[Mesh.ARRAY_VERTEX]
	var normals = arrays[Mesh.ARRAY_NORMAL]
	
	# Create noise for deformation
	var noise = FastNoiseLite.new()
	noise.seed = get_instance_id()
	noise.frequency = 0.5
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	
	for i in range(vertices.size()):
		var vertex = vertices[i]
		var normal = normals[i]
		
		# Get noise value based on position
		var noise_value = noise.get_noise_3dv(vertex.normalized() * 10.0)
		
		# Deform along normal
		var deformation = normal * noise_value * base_radius * 0.3
		vertices[i] = vertex + deformation
	
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	# Recalculate normals would go here in production

func _create_detail_meshes() -> void:
	# Add smaller rocks/details on surface
	for i in range(5):
		var detail = MeshInstance3D.new()
		var detail_mesh = BoxMesh.new()
		detail_mesh.size = Vector3.ONE * randf_range(0.5, 2.0)
		detail.mesh = detail_mesh
		
		# Random position on surface
		var angle = randf() * TAU
		var height = randf_range(-0.5, 0.5)
		var pos = Vector3(
			cos(angle) * base_radius * 0.9,
			height * base_radius,
			sin(angle) * base_radius * 0.9
		)
		detail.position = pos
		detail.rotation = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)
		
		# Same material as main asteroid
		detail.material_override = mesh_instance.material_override
		
		mesh_instance.add_child(detail)
		detail_meshes.append(detail)

func _setup_collision() -> void:
	var body = StaticBody3D.new()
	body.collision_layer = 4  # Asteroid layer
	body.collision_mask = 0
	
	collision_shape = CollisionShape3D.new()
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = base_radius
	collision_shape.shape = sphere_shape
	
	body.add_child(collision_shape)
	add_child(body)

func _create_surface_effects() -> void:
	# Dust particles on surface
	surface_particles = GPUParticles3D.new()
	surface_particles.amount = 20
	surface_particles.lifetime = 5.0
	surface_particles.visibility_aabb = AABB(
		Vector3(-base_radius * 2, -base_radius * 2, -base_radius * 2),
		Vector3(base_radius * 4, base_radius * 4, base_radius * 4)
	)
	
	var particle_material = ParticleProcessMaterial.new()
	particle_material.direction = Vector3(0, 1, 0)
	particle_material.initial_velocity_min = 0.1
	particle_material.initial_velocity_max = 0.5
	particle_material.angular_velocity_min = -90.0
	particle_material.angular_velocity_max = 90.0
	particle_material.spread = 180.0
	particle_material.gravity = Vector3.ZERO
	particle_material.scale_min = 0.05
	particle_material.scale_max = 0.1
	particle_material.color = base_color * 0.7
	
	surface_particles.process_material = particle_material
	surface_particles.draw_pass_1 = SphereMesh.new()
	surface_particles.draw_pass_1.radius = 0.05
	surface_particles.draw_pass_1.height = 0.1
	
	add_child(surface_particles)
	
	# Consciousness glow for special asteroids
	if contains_consciousness_ore:
		consciousness_glow = OmniLight3D.new()
		consciousness_glow.light_color = base_color
		consciousness_glow.light_energy = emission_strength * 2.0
		consciousness_glow.omni_range = base_radius * 3.0
		consciousness_glow.shadow_enabled = false
		add_child(consciousness_glow)

func _cache_surface_points() -> void:
	# Pre-calculate surface points for mining effects
	for i in range(50):
		var theta = randf() * TAU
		var phi = randf() * PI
		
		var point = Vector3(
			sin(phi) * cos(theta),
			cos(phi),
			sin(phi) * sin(theta)
		) * base_radius * randf_range(0.8, 1.0)
		
		surface_points.append(point)

# Update functions
func _update_rotation(delta: float) -> void:
	rotate_x(rotation_speed.x * delta)
	rotate_y(rotation_speed.y * delta)
	rotate_z(rotation_speed.z * delta)

func _update_lod_system() -> void:
	# Get player distance
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	distance_to_player = global_position.distance_to(player.global_position)
	
	# Determine LOD level
	var new_lod = lod_distances.size()
	for i in range(lod_distances.size()):
		if distance_to_player < lod_distances[i]:
			new_lod = i
			break
	
	if new_lod != current_lod:
		_apply_lod_level(new_lod)
		current_lod = new_lod

func _apply_lod_level(lod: int) -> void:
	match lod:
		0: # Highest detail
			mesh_instance.visible = true
			surface_particles.emitting = true
			for detail in detail_meshes:
				detail.visible = true
		1: # High detail
			mesh_instance.visible = true
			surface_particles.emitting = true
			for detail in detail_meshes:
				detail.visible = false
		2: # Medium detail
			mesh_instance.visible = true
			surface_particles.emitting = false
			for detail in detail_meshes:
				detail.visible = false
		3: # Low detail
			mesh_instance.visible = true
			surface_particles.emitting = false
			# Could switch to lower poly mesh here
		_: # Invisible
			mesh_instance.visible = false
			surface_particles.emitting = false

func _update_consciousness_effects(delta: float) -> void:
	if not consciousness_glow:
		return
	
	# Pulse consciousness glow
	var pulse = sin(Time.get_ticks_msec() * 0.001) * 0.5 + 0.5
	consciousness_glow.light_energy = emission_strength * 2.0 * (0.5 + pulse * 0.5)

func _update_depletion_visuals() -> void:
	var depletion_ratio = 1.0 - (get_total_ore_amount() / total_ore_amount)
	
	if depletion_ratio > 0.5:
		# Start showing depletion
		var material = mesh_instance.material_override
		material.albedo_color = base_color.lerp(Color(0.3, 0.3, 0.3), depletion_ratio)
		
		if depletion_ratio > 0.9:
			# Nearly depleted
			material.albedo_color.a = 0.5

# Mining interface
func get_composition() -> Dictionary:
	return composition.duplicate()

func get_detailed_composition() -> Dictionary:
	var detailed = {}
	for ore_type in composition:
		detailed[ore_type] = {
			"amount": composition[ore_type],
			"percentage": (composition[ore_type] / total_ore_amount) * 100.0,
			"quality": _determine_ore_quality(ore_type)
		}
	return detailed

func _determine_ore_quality(ore_type: String) -> String:
	var amount_ratio = composition[ore_type] / initial_composition.get(ore_type, 1.0)
	if amount_ratio > 0.8:
		return "pure"
	elif amount_ratio > 0.5:
		return "rich"
	elif amount_ratio > 0.2:
		return "normal"
	else:
		return "poor"

func extract_ore(ore_type: String, amount: float) -> float:
	if not composition.has(ore_type):
		return 0.0
	
	var available = composition[ore_type]
	var extracted = min(available, amount)
	
	composition[ore_type] -= extracted
	
	if composition[ore_type] <= 0.01:
		composition.erase(ore_type)
	
	return extracted

func get_total_ore_amount() -> float:
	var total = 0.0
	for ore in composition.values():
		total += ore
	return total

func is_depleted() -> bool:
	return get_total_ore_amount() < depletion_threshold

func get_average_hardness() -> float:
	# Would integrate with ore_types from MiningSystem
	return 0.5

func get_radius() -> float:
	return base_radius

func get_random_surface_point() -> Vector3:
	if surface_points.is_empty():
		return global_position + Vector3.UP * base_radius
	
	var point = surface_points[randi() % surface_points.size()]
	return global_position + point

func add_miner(miner: Node3D) -> void:
	if miner not in active_miners:
		active_miners.append(miner)

func remove_miner(miner: Node3D) -> void:
	active_miners.erase(miner)

# System integration
func _register_with_mining_system() -> void:
	var mining_system = get_node_or_null("/root/SpaceGame/MiningSystem")
	if mining_system:
		mining_system.register_asteroid(self)

# Save/Load
func _save_asteroid_state() -> void:
	if AkashicRecordsSystem:
		var save_data = {
			"position": global_position,
			"composition": composition,
			"is_scanned": is_scanned,
			"depletion_ratio": 1.0 - (get_total_ore_amount() / total_ore_amount)
		}
		AkashicRecordsSystem.save_asteroid_data(get_instance_id(), save_data)

func load_asteroid_state(data: Dictionary) -> void:
	global_position = data.get("position", global_position)
	composition = data.get("composition", composition)
	is_scanned = data.get("is_scanned", false)
	
	# Update visuals based on loaded state
	_update_depletion_visuals()

# Cleanup
func _cleanup_effects() -> void:
	if surface_particles:
		surface_particles.emitting = false
	
	for miner in active_miners:
		if miner.has_method("stop_mining"):
			miner.stop_mining(self)

# Socket connections for special asteroids
func connect_consciousness_extractor(extractor: Node) -> bool:
	if contains_consciousness_ore:
		return connect_to_socket("consciousness_socket", extractor)
	return false

# Public properties for UI/HUD
func get_asteroid_info() -> Dictionary:
	return {
		"name": name,
		"size_class": size_class,
		"radius": base_radius,
		"total_ore": get_total_ore_amount(),
		"ore_types": composition.keys(),
		"contains_consciousness": contains_consciousness_ore,
		"is_depleted": is_depleted(),
		"scan_status": is_scanned
	}

# Special asteroid variations
static func create_consciousness_asteroid(ore_type: String) -> Asteroid:
	var asteroid = Asteroid.new()
	asteroid.consciousness_ore_chance = 1.0
	asteroid.ore_richness = 2.0
	asteroid.size_class = "large"
	
	# Will be initialized with guaranteed consciousness ore
	return asteroid

static func create_asteroid_field(center: Vector3, count: int, radius: float) -> Array:
	var asteroids = []
	
	for i in range(count):
		var asteroid = Asteroid.new()
		
		# Random properties
		var sizes = ["small", "small", "small", "medium", "medium", "large"]
		asteroid.size_class = sizes[randi() % sizes.size()]
		asteroid.ore_richness = randf_range(0.5, 1.5)
		
		# Random position
		var angle = randf() * TAU
		var distance = randf_range(10.0, radius)
		var height = randf_range(-radius * 0.3, radius * 0.3)
		
		asteroid.position = center + Vector3(
			cos(angle) * distance,
			height,
			sin(angle) * distance
		)
		
		asteroids.append(asteroid)
	
	return asteroids
