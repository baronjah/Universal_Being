class_name MarchingCubesTerrain
extends Node3D

# Marching cubes settings
@export var grid_size: Vector3i = Vector3i(32, 16, 32)
@export var cube_size: float = 1.0
@export var iso_level: float = 0.5
@export var smooth_normals: bool = true

# Noise settings for terrain generation
@export var noise: FastNoiseLite
@export var noise_scale: float = 0.1
@export var noise_amplitude: float = 1.0

# Mesh resource
var mesh_instance: MeshInstance3D
var st: SurfaceTool

# Lookup tables for the marching cubes algorithm
var edge_table: Array
var tri_table: Array

func _ready():
	initialize_tables()
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	generate_terrain()

func initialize_tables():
	# Initialize the edge table and triangle table for marching cubes
	# (These tables are quite long, so I'm omitting them for brevity)
	# In a real implementation, you would include the standard marching cubes tables
	edge_table = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15] # Simplified for example
	tri_table = [[0, 1, 2], [0, 2, 3]] # Simplified for example

func generate_terrain():
	st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# Generate density field
	var density_field = generate_density_field()
	
	# Apply marching cubes algorithm
	for x in range(grid_size.x - 1):
		for y in range(grid_size.y - 1):
			for z in range(grid_size.z - 1):
				var cube_pos = Vector3(x, y, z)
				process_cube(cube_pos, density_field)
	
	# Finalize the mesh
	if smooth_normals:
		st.generate_normals()
	st.generate_tangents()
	mesh_instance.mesh = st.commit()
	
	# Create a physical body with collision shape
	create_collision_shape()

func generate_density_field() -> Array:
	var field = []
	
	# Initialize 3D array for the field
	for x in range(grid_size.x):
		field.append([])
		for y in range(grid_size.y):
			field[x].append([])
			for z in range(grid_size.z):
				var pos = Vector3(x, y, z) * noise_scale
				var density = noise.get_noise_3d(pos.x, pos.y, pos.z) * noise_amplitude
				
				# Apply height falloff for cave-like structures
				density += (grid_size.y - y) * 0.05
				
				field[x][y].append(density)
	
	return field

func process_cube(pos: Vector3, field: Array):
	var cube_corners = []
	var cube_densities = []
	
	# Get the 8 corners of the cube
	for i in range(8):
		var offset = Vector3(
			i & 1,
			(i & 2) >> 1,
			(i & 4) >> 2
		)
		var corner_pos = pos + offset
		var corner_density #= field[int(corner_pos.x)][int(corner_pos.y)][int(corner_pos.z)]
		
		cube_corners.append(corner_pos * cube_size)
		cube_densities.append(corner_density)
	
	# Calculate cube index for lookup tables
	var cube_index = 0
	for i in range(8):
		if cube_densities[i] < iso_level:
			cube_index |= 1 << i
	
	# Skip empty cubes
	if edge_table[cube_index] == 0:
		return
	
	# Find vertex positions on each edge
	var edge_vertices = []
	for i in range(12):
		if (edge_table[cube_index] & (1 << i)) != 0:
			var v1 = i % 8
			var v2 = (i + 1) % 8
			
			# Interpolate vertex position
			var t = (iso_level - cube_densities[v1]) / (cube_densities[v2] - cube_densities[v1])
			edge_vertices.append(cube_corners[v1].lerp(cube_corners[v2], t))
		else:
			edge_vertices.append(null)
	
	# Create triangles
	var tri_index = 0
	while tri_table[cube_index][tri_index] != -1:
		var v1 = edge_vertices[tri_table[cube_index][tri_index]]
		var v2 = edge_vertices[tri_table[cube_index][tri_index + 1]]
		var v3 = edge_vertices[tri_table[cube_index][tri_index + 2]]
		
		st.add_vertex(v1)
		st.add_vertex(v2)
		st.add_vertex(v3)
		
		tri_index += 3

func create_collision_shape():
	var collision_shape = CollisionShape3D.new()
	var mesh_shape = ConcavePolygonShape3D.new()
	mesh_shape.set_faces(mesh_instance.mesh.get_faces())
	collision_shape.shape = mesh_shape
	
	var static_body = StaticBody3D.new()
	static_body.add_child(collision_shape)
	add_child(static_body)
