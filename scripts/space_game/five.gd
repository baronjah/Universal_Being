# mining_system.gd - Complete mining and resource management
extends Node

# Resource types that connect to your space game
enum ResourceType {
	METAL,
	CRYSTAL,
	ENERGY,
	QUANTUM,
	DARK_MATTER,
	CONSCIOUSNESS_FRAGMENTS
}

# Asteroid/Resource node that works with your existing scenes
class_name SpaceResource
extends StaticBody3D

@export var resource_type: ResourceType = ResourceType.METAL
@export var resource_amount: float = 100.0
@export var mining_difficulty: float = 1.0
@export var respawn_time: float = 300.0  # 5 minutes

var is_depleted: bool = false
var visual_mesh: MeshInstance3D
var glow_effect: OmniLight3D
var original_scale: Vector3

signal resource_depleted
signal resource_mined(amount: float, type: ResourceType)

func _ready():
	add_to_group("resources")
	_setup_visuals()
	_setup_collision()

func _setup_visuals():
	visual_mesh = MeshInstance3D.new()
	add_child(visual_mesh)
	
	# Different meshes for different resources
	match resource_type:
		ResourceType.METAL:
			var mesh = BoxMesh.new()
			mesh.size = Vector3(5, 5, 5)
			visual_mesh.mesh = mesh
			_apply_metal_material()
		ResourceType.CRYSTAL:
			var mesh = CylinderMesh.new()
			mesh.height = 8
			mesh.radial_segments = 6
			visual_mesh.mesh = mesh
			_apply_crystal_material()
		ResourceType.ENERGY:
			var mesh = SphereMesh.new()
			mesh.radius = 3
			mesh.radial_segments = 32
			visual_mesh.mesh = mesh
			_apply_energy_material()
		ResourceType.QUANTUM:
			var mesh = TorusMesh.new()
			mesh.inner_radius = 2
			mesh.outer_radius = 4
			visual_mesh.mesh = mesh
			_apply_quantum_material()
	
	original_scale = scale
	
	# Add glow for valuable resources
	if resource_type >= ResourceType.QUANTUM:
		glow_effect = OmniLight3D.new()
		glow_effect.light_energy = 2.0
		glow_effect.omni_range = 20.0
		add_child(glow_effect)

func _apply_metal_material():
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.6, 0.6, 0.7)
	mat.metallic = 0.8
	mat.roughness = 0.3
	visual_mesh.material_override = mat

func _apply_crystal_material():
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.3, 0.7, 1.0)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.8
	mat.emission_enabled = true
	mat.emission = Color(0.3, 0.7, 1.0)
	mat.emission_energy = 0.5
	mat.rim_enabled = true
	mat.rim = 1.0
	mat.rim_tint = 0.5
	visual_mesh.material_override = mat

func _apply_energy_material():
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 1.0, 0.3)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.9, 0.0)
	mat.emission_energy = 2.0
	visual_mesh.material_override = mat

func _apply_quantum_material():
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.3, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.8, 0.3, 1.0)
	mat.emission_energy = 3.0
	# Animated effect
	mat.rim_enabled = true
	mat.rim = 1.0
	visual_mesh.material_override = mat

func _setup_collision():
	var shape = CollisionShape3D.new()
	var collision_shape = BoxShape3D.new()
	collision_shape.size = Vector3(5, 5, 5)
	shape.shape = collision_shape
	add_child(shape)

func mine(mining_power: float) -> Dictionary:
	if is_depleted:
		return {}
	
	# Calculate mined amount
	var efficiency = mining_power / mining_difficulty
	var mined = min(resource_amount, 10.0 * efficiency)
	resource_amount -= mined
	
	# Visual feedback
	_mining_effect()
	
	# Scale down as resources deplete
	var remaining_ratio = resource_amount / 100.0
	scale = original_scale * (0.3 + 0.7 * remaining_ratio)
	
	# Check if depleted
	if resource_amount <= 0:
		is_depleted = true
		resource_depleted.emit()
		_start_respawn_timer()
	
	# Return mined resources
	var result = {}
	result[resource_type] = mined
	resource_mined.emit(mined, resource_type)
	
	return result

func _mining_effect():
	# Create mining particles
	var particles = CPUParticles3D.new()
	particles.amount = 30
	particles.lifetime = 1.0
	particles.direction = Vector3.UP
	particles.spread = 45.0
	particles.initial_velocity_min = 5.0
	particles.initial_velocity_max = 15.0
	
	# Color based on resource
	match resource_type:
		ResourceType.METAL:
			particles.color = Color(0.7, 0.7, 0.7)
		ResourceType.CRYSTAL:
			particles.color = Color(0.3, 0.7, 1.0)
		ResourceType.ENERGY:
			particles.color = Color(1.0, 1.0, 0.0)
		ResourceType.QUANTUM:
			particles.color = Color(0.8, 0.3, 1.0)
	
	add_child(particles)
	particles.emitting = true
	particles.one_shot = true
	
	# Clean up
	await particles.finished
	particles.queue_free()

func _start_respawn_timer():
	visible = false
	set_collision_layer_value(1, false)
	
	await get_tree().create_timer(respawn_time).timeout
	
	_respawn()

func _respawn():
	resource_amount = 100.0
	is_depleted = false
	visible = true
	set_collision_layer_value(1, true)
	scale = original_scale
	
	# Respawn effect
	var tween = create_tween()
	scale = Vector3.ZERO
	tween.tween_property(self, "scale", original_scale, 1.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

# Mining Tool System that attaches to player ship
class_name MiningLaser
extends Node3D

@export var mining_range: float = 50.0
@export var mining_power: float = 10.0
@export var energy_cost: float = 1.0
@export var laser_color: Color = Color(1.0, 0.5, 0.0)

var is_mining: bool = false
var current_target: SpaceResource
var laser_beam: MeshInstance3D
var laser_particles: GPUParticles3D

signal mining_started(target: SpaceResource)
signal mining_stopped
signal resources_collected(resources: Dictionary)

func _ready():
	_setup_laser_visual()

func _setup_laser_visual():
	# Laser beam mesh
	laser_beam = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.height = mining_range
	cylinder.radial_segments = 8
	cylinder.rings = 1
	laser_beam.mesh = cylinder
	
	# Laser material
	var mat = StandardMaterial3D.new()
	mat.albedo_color = laser_color
	mat.emission_enabled = true
	mat.emission = laser_color
	mat.emission_energy = 2.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.7
	laser_beam.material_override = mat
	
	add_child(laser_beam)
	laser_beam.visible = false
	
	# Mining particles at target
	laser_particles = GPUParticles3D.new()
	laser_particles.amount = 100
	laser_particles.lifetime = 0.5
	laser_particles.visibility_aabb = AABB(Vector3(-10, -10, -10), Vector3(20, 20, 20))
	add_child(laser_particles)
	laser_particles.emitting = false

func start_mining(target: SpaceResource):
	if not target or is_mining:
		return
		
	var distance = global_position.distance_to(target.global_position)
	if distance > mining_range:
		return
	
	current_target = target
	is_mining = true
	laser_beam.visible = true
	laser_particles.emitting = true
	
	# Position laser
	_update_laser_position()
	
	mining_started.emit(target)

func stop_mining():
	is_mining = false
	current_target = null
	laser_beam.visible = false
	laser_particles.emitting = false
	mining_stopped.emit()

func _process(delta):
	if not is_mining or not current_target:
		return
	
	# Check if still in range
	var distance = global_position.distance_to(current_target.global_position)
	if distance > mining_range:
		stop_mining()
		return
	
	# Update laser position
	_update_laser_position()
	
	# Mine the target
	var mined_resources = current_target.mine(mining_power * delta)
	if mined_resources.size() > 0:
		resources_collected.emit(mined_resources)
	
	# Check if depleted
	if current_target.is_depleted:
		stop_mining()

func _update_laser_position():
	if not current_target:
		return
		
	# Point laser at target
	look_at(current_target.global_position, Vector3.UP)
	
	# Scale beam to reach target
	var distance = global_position.distance_to(current_target.global_position)
	laser_beam.scale.y = distance / mining_range
	laser_beam.position.z = -distance / 2
	
	# Position particles at target
	laser_particles.global_position = current_target.global_position

func get_nearest_resource(max_range: float) -> SpaceResource:
	var nearest: SpaceResource = null
	var min_distance = max_range
	
	for node in get_tree().get_nodes_in_group("resources"):
		if node is SpaceResource and not node.is_depleted:
			var distance = global_position.distance_to(node.global_position)
			if distance < min_distance:
				min_distance = distance
				nearest = node
	
	return nearest

# Resource spawner for your space scenes
class_name ResourceField
extends Node3D

@export var field_radius: float = 1000.0
@export var resource_count: int = 50
@export var resource_distribution: Dictionary = {
	ResourceType.METAL: 0.5,
	ResourceType.CRYSTAL: 0.3,
	ResourceType.ENERGY: 0.15,
	ResourceType.QUANTUM: 0.05
}

func _ready():
	generate_resource_field()

func generate_resource_field():
	var resource_scene = preload("res://scenes/space_resource.tscn")
	
	for i in range(resource_count):
		# Random position in sphere
		var pos = Vector3(
			randf_range(-1, 1),
			randf_range(-1, 1),
			randf_range(-1, 1)
		).normalized()
		pos *= randf() * field_radius
		
		# Determine resource type
		var type = _weighted_random_resource()
		
		# Create resource
		var resource = SpaceResource.new()
		resource.position = pos
		resource.resource_type = type
		resource.resource_amount = randf_range(50, 150)
		
		# Rarer resources are harder to mine
		match type:
			ResourceType.QUANTUM:
				resource.mining_difficulty = 3.0
			ResourceType.ENERGY:
				resource.mining_difficulty = 2.0
			ResourceType.CRYSTAL:
				resource.mining_difficulty = 1.5
			_:
				resource.mining_difficulty = 1.0
		
		add_child(resource)

func _weighted_random_resource() -> ResourceType:
	var rand = randf()
	var cumulative = 0.0
	
	for type in resource_distribution:
		cumulative += resource_distribution[type]
		if rand <= cumulative:
			return type
	
	return ResourceType.METAL  # Fallbackand 
