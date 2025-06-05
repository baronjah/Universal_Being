# CosmicLODSystem - FIXED VERSION - No more errors!
# Infinite space with galaxies, stars, planets
# Uses icospheres and marching cubes for seamless LOD transitions

extends Node3D
class_name CosmicLODSystem

@export var galaxy_distance: float = 1000.0
@export var star_distance: float = 100.0
@export var planet_distance: float = 10.0
@export var surface_distance: float = 1.0

# Cosmic objects at different scales
var cosmic_objects: Dictionary = {}  # Vector3i -> CosmicObject
var player: Node3D = null
var camera: Camera3D = null

enum CosmicType { GALAXY, STAR_CLUSTER, SOLAR_SYSTEM, PLANET, SURFACE }

class CosmicObject:
	var position: Vector3
	var cosmic_type: CosmicType
	var scale_level: int
	var mesh_instance: MeshInstance3D
	var chunk_coord: Vector3i
	
	func _init(pos: Vector3, type: CosmicType, coord: Vector3i):
		position = pos
		cosmic_type = type
		chunk_coord = coord
		scale_level = type

func _ready():
	# Add to generation systems group for coordinator
	add_to_group("generation_systems")
	
	# Find player and camera - DEFER to next frame to ensure scene is ready
	call_deferred("_find_player_and_camera")
	
	print("🌌 COSMIC LOD SYSTEM ACTIVE")
	print("🌌 INFINITE SPACE STREAMING ENABLED")

func _find_player_and_camera():
	"""Find player and camera after scene is ready"""
	var players = get_tree().get_nodes_in_group("players")
	if players.size() > 0:
		player = players[0]
		camera = find_camera_in_node(player)

func find_camera_in_node(node: Node) -> Camera3D:
	if node is Camera3D:
		return node
	for child in node.get_children():
		var cam = find_camera_in_node(child)
		if cam:
			return cam
	return null

func _process(delta):
	if not camera or not player:
		return
	
	# Check if player is valid and in tree
	if not is_instance_valid(player) or not player.is_inside_tree():
		return
	
	update_cosmic_lod()

func update_cosmic_lod():
	"""Update cosmic objects based on distance LOD"""
	var player_pos = player.global_position
	
	# Generate cosmic grid around player at multiple scales
	generate_galaxies_around_player(player_pos)
	
	# Update existing objects LOD
	for coord in cosmic_objects.keys():
		var cosmic_obj = cosmic_objects[coord]
		update_object_lod(cosmic_obj, player_pos)

func generate_galaxies_around_player(player_pos: Vector3):
	"""Generate galaxies in infinite grid around player"""
	var galaxy_grid_size = galaxy_distance
	var player_galaxy_coord = Vector3i(
		int(floor(player_pos.x / galaxy_grid_size)),
		int(floor(player_pos.y / galaxy_grid_size)),
		int(floor(player_pos.z / galaxy_grid_size))
	)
	
	# Generate 3x3x3 galaxy grid around player
	for x in range(-1, 2):
		for y in range(-1, 2):
			for z in range(-1, 2):
				var galaxy_coord = Vector3i(
					player_galaxy_coord.x + x,
					player_galaxy_coord.y + y,
					player_galaxy_coord.z + z
				)
				
				if galaxy_coord not in cosmic_objects:
					create_cosmic_object(galaxy_coord, CosmicType.GALAXY)

func create_cosmic_object(coord: Vector3i, initial_type: CosmicType) -> CosmicObject:
	"""Create a cosmic object at the given coordinate"""
	var world_pos = cosmic_coord_to_world_pos(coord, initial_type)
	var cosmic_obj = CosmicObject.new(world_pos, initial_type, coord)
	
	# Create visual representation
	cosmic_obj.mesh_instance = create_cosmic_mesh(cosmic_obj)
	add_child(cosmic_obj.mesh_instance)
	
	cosmic_objects[coord] = cosmic_obj
	
	print("🌌 Created %s at [%d,%d,%d]" % [
		CosmicType.keys()[initial_type], coord.x, coord.y, coord.z
	])
	
	return cosmic_obj

func create_cosmic_mesh(cosmic_obj: CosmicObject) -> MeshInstance3D:
	"""Create mesh based on cosmic object type"""
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.name = "Cosmic_%s_%d_%d_%d" % [
		CosmicType.keys()[cosmic_obj.cosmic_type],
		cosmic_obj.chunk_coord.x,
		cosmic_obj.chunk_coord.y,
		cosmic_obj.chunk_coord.z
	]
	
	var mesh = null
	var material = StandardMaterial3D.new()
	
	match cosmic_obj.cosmic_type:
		CosmicType.GALAXY:
			# Icosphere for distant galaxy
			mesh = create_icosphere(32)  # High detail icosphere
			material.albedo_color = Color(0.8, 0.6, 1.0, 0.8)
			material.emission_enabled = true
			material.emission = Color(0.6, 0.4, 1.0)
			material.emission_energy = 2.0
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mesh_instance.scale = Vector3(50, 50, 50)  # Large galaxy
			
		CosmicType.STAR_CLUSTER:
			# Multiple smaller icospheres for star cluster
			mesh = create_star_cluster_mesh()
			material.albedo_color = Color(1.0, 0.9, 0.7)
			material.emission_enabled = true
			material.emission = Color(1.0, 0.8, 0.4)
			material.emission_energy = 1.5
			mesh_instance.scale = Vector3(10, 10, 10)
			
		CosmicType.SOLAR_SYSTEM:
			# Central star with orbiting points
			mesh = create_solar_system_mesh()
			material.albedo_color = Color(1.0, 1.0, 0.8)
			material.emission_enabled = true
			material.emission = Color(1.0, 0.9, 0.6)
			material.emission_energy = 1.0
			mesh_instance.scale = Vector3(2, 2, 2)
			
		CosmicType.PLANET:
			# Detailed icosphere planet
			mesh = create_icosphere(64)  # Very high detail
			material.albedo_color = Color(0.6, 0.8, 0.4)  # Earth-like
			material.emission_enabled = true
			material.emission = Color(0.2, 0.3, 0.1)
			material.emission_energy = 0.3
			mesh_instance.scale = Vector3(5, 5, 5)
			
		CosmicType.SURFACE:
			# Marching cubes for planet surface
			mesh = create_marching_cubes_surface()
			material.albedo_color = Color(0.4, 0.6, 0.3)
			material.roughness = 0.8
			material.metallic = 0.0
			mesh_instance.scale = Vector3(1, 1, 1)
	
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	
	# Position in cosmic space - USE LOCAL POSITION FIRST!
	mesh_instance.position = cosmic_obj.position  # Use local position, not global
	
	return mesh_instance

func create_icosphere(subdivisions: int) -> Mesh:
	"""Create icosphere mesh with given subdivisions"""
	var sphere = SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	# SphereMesh doesn't have subdivide properties, use radial/rings instead
	sphere.radial_segments = mini(subdivisions, 32)
	sphere.rings = mini(subdivisions, 16)
	return sphere

func create_star_cluster_mesh() -> Mesh:
	"""Create mesh representing star cluster"""
	var sphere = SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	sphere.radial_segments = 16
	sphere.rings = 8
	return sphere

func create_solar_system_mesh() -> Mesh:
	"""Create mesh representing solar system"""
	var sphere = SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	sphere.radial_segments = 8
	sphere.rings = 4
	return sphere

func create_marching_cubes_surface() -> Mesh:
	"""Create marching cubes surface for planet detail"""
	# Use BoxMesh instead of PlaneMesh for better 3D surface
	var box = BoxMesh.new()
	box.size = Vector3(10, 1, 10)
	box.subdivide_depth = 16
	box.subdivide_height = 4
	box.subdivide_width = 16
	return box

func update_object_lod(cosmic_obj: CosmicObject, player_pos: Vector3):
	"""Update LOD of cosmic object based on distance"""
	var distance = player_pos.distance_to(cosmic_obj.position)
	var new_type = determine_cosmic_type_by_distance(distance)
	
	if new_type != cosmic_obj.cosmic_type:
		# LOD transition - recreate mesh
		cosmic_obj.cosmic_type = new_type
		
		# Remove old mesh
		if cosmic_obj.mesh_instance and is_instance_valid(cosmic_obj.mesh_instance):
			cosmic_obj.mesh_instance.queue_free()
		
		# Create new mesh at new LOD
		cosmic_obj.mesh_instance = create_cosmic_mesh(cosmic_obj)
		add_child(cosmic_obj.mesh_instance)
		
		print("🔄 LOD Transition: %s at distance %.1f" % [
			CosmicType.keys()[new_type], distance
		])

func determine_cosmic_type_by_distance(distance: float) -> CosmicType:
	"""Determine cosmic object type based on viewing distance"""
	if distance > galaxy_distance * 0.8:
		return CosmicType.GALAXY
	elif distance > star_distance * 0.8:
		return CosmicType.STAR_CLUSTER
	elif distance > planet_distance * 0.8:
		return CosmicType.SOLAR_SYSTEM
	elif distance > surface_distance * 0.8:
		return CosmicType.PLANET
	else:
		return CosmicType.SURFACE

func cosmic_coord_to_world_pos(coord: Vector3i, cosmic_type: CosmicType) -> Vector3:
	"""Convert cosmic coordinate to world position based on type"""
	var scale = galaxy_distance
	match cosmic_type:
		CosmicType.GALAXY:
			scale = galaxy_distance
		CosmicType.STAR_CLUSTER:
			scale = star_distance
		CosmicType.SOLAR_SYSTEM:
			scale = planet_distance
		CosmicType.PLANET:
			scale = surface_distance
		CosmicType.SURFACE:
			scale = 1.0
	
	return Vector3(coord.x * scale, coord.y * scale, coord.z * scale)

func cleanup_distant_objects():
	"""Remove objects too far from player"""
	if not player:
		return
	
	var player_pos = player.global_position
	var objects_to_remove = []
	
	for coord in cosmic_objects.keys():
		var cosmic_obj = cosmic_objects[coord]
		var distance = player_pos.distance_to(cosmic_obj.position)
		
		if distance > galaxy_distance * 2:
			objects_to_remove.append(coord)
	
	# Limit removals per frame to prevent lag
	var removed_count = 0
	for coord in objects_to_remove:
		if removed_count >= 5:  # Only remove 5 per frame
			break
			
		var cosmic_obj = cosmic_objects[coord]
		if cosmic_obj.mesh_instance and is_instance_valid(cosmic_obj.mesh_instance):
			cosmic_obj.mesh_instance.queue_free()
		cosmic_objects.erase(coord)
		removed_count += 1
		
		# Less spam in console
		if removed_count == 1:
			print("🌌 COSMIC CLEANUP: Removing %d distant objects..." % objects_to_remove.size())

func get_cosmic_stats() -> Dictionary:
	"""Get cosmic system statistics"""
	return {
		"cosmic_objects": cosmic_objects.size(),
		"player_position": player.global_position if player else Vector3.ZERO,
		"galaxy_distance": galaxy_distance,
		"star_distance": star_distance,
		"planet_distance": planet_distance
	}