# ==================================================
# SCRIPT NAME: heightmap_world_generator.gd
# DESCRIPTION: Generates terrain with heightmaps and places vegetation
# PURPOSE: Create a living world for birds to explore
# CREATED: 2025-05-24 - Heightmap-based world generation
# ==================================================

extends UniversalBeingBase
signal terrain_generated
signal vegetation_placed

# ================================
# TERRAIN PROPERTIES
# ================================

# Terrain dimensions
var terrain_size: int = 128  # Power of 2 for efficiency
var terrain_scale: float = 0.5  # Distance between vertices
var height_scale: float = 10.0  # Maximum height

# Noise generator
var noise: FastNoiseLite
var noise_seed: int = 12345

# Terrain mesh
var terrain_mesh_instance: MeshInstance3D
var terrain_collision: StaticBody3D
var heightmap_data: Array = []

# ================================
# VEGETATION PROPERTIES
# ================================

# Object placement
var tree_density: float = 0.02  # Trees per unit area
var bush_density: float = 0.05  # Bushes per unit area
var water_pool_count: int = 5   # Number of water sources

# Fruit settings
var fruits_per_tree_min: int = 3
var fruits_per_tree_max: int = 8
var fruits_per_bush_min: int = 1
var fruits_per_bush_max: int = 3

# Placement rules
var min_tree_height: float = 2.0  # Don't place trees underwater
var max_tree_slope: float = 0.7   # Max slope for trees
var water_level: float = 1.5      # Sea level

# ================================
# INITIALIZATION
# ================================

func _ready() -> void:
	pentagon_ready()

func pentagon_ready() -> void:
	super.pentagon_ready()
	# Initialize noise
	_setup_noise()
	
	# Create containers
	_create_containers()

func _setup_noise() -> void:
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.seed = noise_seed
	noise.frequency = 0.01
	noise.fractal_octaves = 5
	noise.fractal_lacunarity = 1.9

func _create_containers() -> void:
	# Container for terrain
	var terrain_container = Node3D.new()
	terrain_container.name = "Terrain"
	add_child(terrain_container)
	
	# Container for vegetation
	var vegetation_container = Node3D.new()
	vegetation_container.name = "Vegetation"
	add_child(vegetation_container)
	
	# Container for water
	var water_container = Node3D.new()
	water_container.name = "Water"
	add_child(water_container)

# ================================
# TERRAIN GENERATION
# ================================


func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass
func generate_world() -> void:
	print("[WorldGen] Starting world generation...")
	
	# Generate heightmap
	_generate_heightmap()
	
	# Create terrain mesh
	_create_terrain_mesh()
	
	# Place vegetation
	_place_vegetation()
	
	# Create water sources
	_create_water_sources()
	
	terrain_generated.emit()
	print("[WorldGen] World generation complete!")

func _generate_heightmap() -> void:
	heightmap_data.clear()
	heightmap_data.resize(terrain_size)
	
	for x in range(terrain_size):
		heightmap_data[x] = []
		heightmap_data[x].resize(terrain_size)
		
		for z in range(terrain_size):
			# Get noise value
			var height = noise.get_noise_2d(x, z)
			
			# Apply island gradient (optional)
			var center_x = terrain_size / 2.0
			var center_z = terrain_size / 2.0
			var max_dist = terrain_size / 2.0
			
			var dist = sqrt(pow(x - center_x, 2) + pow(z - center_z, 2))
			var gradient = 1.0 - (dist / max_dist)
			gradient = clamp(gradient * 2.0 - 0.5, 0.0, 1.0)
			
			# Combine noise with gradient
			height = height * gradient
			
			# Scale to world height
			heightmap_data[x][z] = height * height_scale

func _create_terrain_mesh() -> void:
	# Create mesh instance
	terrain_mesh_instance = MeshInstance3D.new()
	terrain_mesh_instance.name = "TerrainMesh"
	get_node("Terrain").add_child(terrain_mesh_instance)
	
	# Generate mesh
	var array_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	
	# Generate vertices, normals, uvs
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var uvs = PackedVector2Array()
	var colors = PackedColorArray()
	
	# Create vertices
	for x in range(terrain_size):
		for z in range(terrain_size):
			var pos = Vector3(
				(x - terrain_size/2) * terrain_scale,
				heightmap_data[x][z],
				(z - terrain_size/2) * terrain_scale
			)
			vertices.append(pos)
			uvs.append(Vector2(float(x) / terrain_size, float(z) / terrain_size))
			
			# Color based on height
			var height_normalized = (pos.y + height_scale) / (2.0 * height_scale)
			var color = Color()
			
			if pos.y < water_level:
				color = Color(0.2, 0.3, 0.6)  # Underwater
			elif pos.y < water_level + 1.0:
				color = Color(0.9, 0.8, 0.6)  # Beach
			elif pos.y < height_scale * 0.6:
				color = Color(0.3, 0.6, 0.3)  # Grass
			else:
				color = Color(0.5, 0.4, 0.3)  # Mountain
				
			colors.append(color)
	
	# Calculate normals
	for i in range(vertices.size()):
		normals.append(Vector3.UP)  # Placeholder
	
	# Create indices for triangles
	var indices = PackedInt32Array()
	for x in range(terrain_size - 1):
		for z in range(terrain_size - 1):
			var idx = x * terrain_size + z
			
			# First triangle
			indices.append(idx)
			indices.append(idx + terrain_size)
			indices.append(idx + terrain_size + 1)
			
			# Second triangle
			indices.append(idx)
			indices.append(idx + terrain_size + 1)
			indices.append(idx + 1)
	
	# Assign arrays
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	
	# Create mesh
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	terrain_mesh_instance.mesh = array_mesh
	
	# Create material
	var material = MaterialLibrary.get_material("default")
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.9
	terrain_mesh_instance.material_override = material
	
	# Add collision
	_create_terrain_collision()

func _create_terrain_collision() -> void:
	terrain_collision = StaticBody3D.new()
	terrain_collision.name = "TerrainCollision"
	FloodgateController.universal_add_child(terrain_collision, terrain_mesh_instance)
	
	# Use trimesh collision
	terrain_mesh_instance.create_trimesh_collision()

# ================================
# VEGETATION PLACEMENT
# ================================

func _place_vegetation() -> void:
	var vegetation_container = get_node("Vegetation")
	var world_builder = get_node("/root/WorldBuilder")
	
	if not world_builder:
		print("[WorldGen] WorldBuilder not found!")
		return
	
	# Place trees
	var tree_count = int(terrain_size * terrain_size * terrain_scale * terrain_scale * tree_density)
	for i in range(tree_count):
		_place_tree(vegetation_container)
	
	# Place bushes
	var bush_count = int(terrain_size * terrain_size * terrain_scale * terrain_scale * bush_density)
	for i in range(bush_count):
		_place_bush(vegetation_container)
		
	vegetation_placed.emit()

func _place_tree(container: Node3D) -> void:
	var max_attempts = 10
	
	for attempt in range(max_attempts):
		# Random position
		var x = randi() % terrain_size
		var z = randi() % terrain_size
		var height = heightmap_data[x][z]
		
		# Check placement rules
		if height < min_tree_height or height < water_level + 0.5:
			continue
			
		# Check slope
		if not _check_slope_at(x, z, max_tree_slope):
			continue
		
		# Create tree
		var tree_pos = Vector3(
			(x - terrain_size/2) * terrain_scale,
			height,
			(z - terrain_size/2) * terrain_scale
		)
		
		var tree = _create_tree_with_fruits(tree_pos)
		FloodgateController.universal_add_child(tree, container)
		
		# Register with WorldBuilder for tracking
		var world_builder = get_node_or_null("/root/WorldBuilder")
		if world_builder:
			world_builder.register_world_object(tree)
		
		break

func _place_bush(container: Node3D) -> void:
	var max_attempts = 10
	
	for attempt in range(max_attempts):
		# Random position
		var x = randi() % terrain_size
		var z = randi() % terrain_size
		var height = heightmap_data[x][z]
		
		# Bushes can grow in more places
		if height < water_level:
			continue
		
		# Create bush
		var bush_pos = Vector3(
			(x - terrain_size/2) * terrain_scale,
			height,
			(z - terrain_size/2) * terrain_scale
		)
		
		var bush = _create_bush_with_fruits(bush_pos)
		FloodgateController.universal_add_child(bush, container)
		
		# Register with WorldBuilder for tracking
		var world_builder = get_node_or_null("/root/WorldBuilder")
		if world_builder:
			world_builder.register_world_object(bush)
		
		break

func _create_tree_with_fruits(pos: Vector3) -> Node3D:
	var tree_root = Node3D.new()
	tree_root.position = pos
	tree_root.name = "Tree"
	
	# Create trunk
	var trunk = MeshInstance3D.new()
	var trunk_mesh = CylinderMesh.new()
	trunk_mesh.height = 4.0
	trunk_mesh.top_radius = 0.2
	trunk_mesh.bottom_radius = 0.4
	trunk.mesh = trunk_mesh
	trunk.position.y = 2.0
	
	var trunk_mat = MaterialLibrary.get_material("default")
	trunk_mat.albedo_color = Color(0.4, 0.2, 0.1)
	trunk.material_override = trunk_mat
	FloodgateController.universal_add_child(trunk, tree_root)
	
	# Create canopy
	var canopy = MeshInstance3D.new()
	var canopy_mesh = SphereMesh.new()
	canopy_mesh.radius = 2.0
	canopy_mesh.height = 3.0
	canopy.mesh = canopy_mesh
	canopy.position.y = 5.0
	
	var canopy_mat = MaterialLibrary.get_material("default")
	canopy_mat.albedo_color = Color(0.2, 0.6, 0.2)
	canopy.material_override = canopy_mat
	FloodgateController.universal_add_child(canopy, tree_root)
	
	# Add fruits in canopy (torus pattern)
	var fruit_count = randi_range(fruits_per_tree_min, fruits_per_tree_max)
	for i in range(fruit_count):
		var angle = (TAU / fruit_count) * i + randf() * 0.5
		var radius = randf_range(1.0, 1.8)
		var height = randf_range(4.0, 6.0)
		
		var fruit = _create_fruit()
		fruit.position = Vector3(
			cos(angle) * radius,
			height,
			sin(angle) * radius
		)
		FloodgateController.universal_add_child(fruit, tree_root)
	
	tree_root.add_to_group("trees")
	return tree_root

func _create_bush_with_fruits(pos: Vector3) -> Node3D:
	var bush_root = Node3D.new()
	bush_root.position = pos
	bush_root.name = "Bush"
	
	# Create bush body
	var bush = MeshInstance3D.new()
	var bush_mesh = SphereMesh.new()
	bush_mesh.radius = 1.0
	bush_mesh.height = 0.8
	bush.mesh = bush_mesh
	bush.position.y = 0.5
	
	var bush_mat = MaterialLibrary.get_material("default")
	bush_mat.albedo_color = Color(0.1, 0.5, 0.1)
	bush.material_override = bush_mat
	FloodgateController.universal_add_child(bush, bush_root)
	
	# Add fruits on sides
	var fruit_count = randi_range(fruits_per_bush_min, fruits_per_bush_max)
	for i in range(fruit_count):
		var angle = randf() * TAU
		var fruit = _create_fruit()
		fruit.position = Vector3(
			cos(angle) * 0.8,
			randf_range(0.3, 0.7),
			sin(angle) * 0.8
		)
		FloodgateController.universal_add_child(fruit, bush_root)
	
	bush_root.add_to_group("bushes")
	return bush_root

func _create_fruit() -> RigidBody3D:
	var fruit = RigidBody3D.new()
	fruit.name = "Fruit"
	
	# Visual
	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.1
	mesh.mesh = sphere
	
	var mat = MaterialLibrary.get_material("default")
	mat.albedo_color = Color(0.9, 0.2, 0.2)
	mat.emission_enabled = true
	mat.emission = Color(0.9, 0.2, 0.2)
	mat.emission_energy = 0.3
	mesh.material_override = mat
	FloodgateController.universal_add_child(mesh, fruit)
	
	# Collision
	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.1
	collision.shape = shape
	FloodgateController.universal_add_child(collision, fruit)
	
	# Properties
	fruit.mass = 0.1
	fruit.freeze = true  # Start frozen on tree
	fruit.add_to_group("fruit")
	fruit.add_to_group("food")
	
	return fruit

# ================================
# WATER SOURCES
# ================================

func _create_water_sources() -> void:
	var water_container = get_node("Water")
	
	for i in range(water_pool_count):
		# Find low spots
		var lowest_height = INF
		var lowest_x = 0
		var lowest_z = 0
		
		# Random search area
		var search_x = randi() % (terrain_size - 20) + 10
		var search_z = randi() % (terrain_size - 20) + 10
		
		for x in range(search_x - 10, search_x + 10):
			for z in range(search_z - 10, search_z + 10):
				if x >= 0 and x < terrain_size and z >= 0 and z < terrain_size:
					if heightmap_data[x][z] < lowest_height:
						lowest_height = heightmap_data[x][z]
						lowest_x = x
						lowest_z = z
		
		# Create water pool
		if lowest_height < water_level + 2.0:
			var water_pos = Vector3(
				(lowest_x - terrain_size/2) * terrain_scale,
				lowest_height + 0.1,
				(lowest_z - terrain_size/2) * terrain_scale
			)
			
			var water = _create_water_pool(water_pos)
			FloodgateController.universal_add_child(water, water_container)

func _create_water_pool(pos: Vector3) -> Area3D:
	var water = Area3D.new()
	water.position = pos
	water.name = "WaterPool"
	
	# Visual
	var mesh = MeshInstance3D.new()
	var plane = PlaneMesh.new()
	plane.size = Vector2(4, 4)
	mesh.mesh = plane
	mesh.rotate_x(-PI/2)
	
	var mat = MaterialLibrary.get_material("default")
	mat.albedo_color = Color(0.2, 0.5, 0.8, 0.8)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.roughness = 0.1
	mat.metallic = 0.3
	mesh.material_override = mat
	FloodgateController.universal_add_child(mesh, water)
	
	# Collision
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = Vector3(4, 0.5, 4)
	collision.shape = shape
	collision.position.y = -0.25
	FloodgateController.universal_add_child(collision, water)
	
	water.add_to_group("water")
	return water

# ================================
# UTILITY FUNCTIONS
# ================================

func _check_slope_at(x: int, z: int, max_slope: float) -> bool:
	if x <= 0 or x >= terrain_size - 1 or z <= 0 or z >= terrain_size - 1:
		return false
		
	var h_center = heightmap_data[x][z]
	var h_left = heightmap_data[x-1][z]
	var h_right = heightmap_data[x+1][z]
	var h_front = heightmap_data[x][z-1]
	var h_back = heightmap_data[x][z+1]
	
	var slope_x = abs(h_right - h_left) / (2.0 * terrain_scale)
	var slope_z = abs(h_back - h_front) / (2.0 * terrain_scale)
	
	return max(slope_x, slope_z) < max_slope

func get_height_at_position(world_pos: Vector3) -> float:
	# Convert world position to heightmap coordinates
	var x = int((world_pos.x / terrain_scale) + terrain_size/2)
	var z = int((world_pos.z / terrain_scale) + terrain_size/2)
	
	if x >= 0 and x < terrain_size and z >= 0 and z < terrain_size:
		return heightmap_data[x][z]
	
	return 0.0