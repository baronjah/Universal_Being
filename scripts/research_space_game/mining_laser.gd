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
