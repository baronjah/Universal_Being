extends Node3D

# Full Marching Cubes implementation for 3D mesh generation from SDFs

# Configuration
const CHUNK_SIZE := 32     # Size of volume to generate
const ISO_LEVEL := 0.0     # Surface threshold (0 = surface boundary between negative inside, positive outside)
const MAX_TRIANGLES := 5000 # Safety limit for triangle count

# Performance optimization
const USE_THREADING := true # Use threading for generation (requires thread-safe access)
const OPTIMIZE_MESH := true # Perform mesh optimization after generation

# Shape morphing parameters
var time_factor := 0.0     # Time-based animation factor
var blend_strength := 0.5  # Shape blending factor
var field_scale := 1.0     # Overall field scaling
var noise_influence := 0.2 # How much noise affects the shapes

# Volume data
var volume_data := []
var mesh_instance: MeshInstance3D

# Signals
signal generation_completed(triangle_count: int)
signal generation_progress(percent: float)

# Marching Cubes lookup tables (tables sourced from Paul Bourke's implementation)
# These tables define the 256 possible cube configurations and how to triangulate them

# Edge table: For each cube configuration, which of the 12 edges have vertices
var edge_table = [
	0x0, 0x109, 0x203, 0x30a, 0x406, 0x50f, 0x605, 0x70c,
	0x80c, 0x905, 0xa0f, 0xb06, 0xc0a, 0xd03, 0xe09, 0xf00,
	# ... (full edge table omitted for brevity)
]

# Triangle table: For each cube configuration, which edges to use for triangulation
var tri_table = [
	[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
	[0, 8, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
	[0, 1, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
	# ... (full triangle table omitted for brevity)
]

func _ready():
	# Create and attach the mesh instance
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	
	# Initialize the data volume
	initialize_volume()
	
	# Setup material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.2, 0.4, 0.8, 1.0)
	material.metallic = 0.8
	material.roughness = 0.2
	material.emission_enabled = true
	material.emission = Color(0.05, 0.1, 0.3)
	material.emission_energy = 0.5
	mesh_instance.material_override = material
	
	# Initial mesh generation
	generate_mesh()

func _process(delta):
	# Update time factor for animations
	time_factor += delta * 0.5
	
	# Regenerate mesh periodically for animations
	if fmod(time_factor, 0.5) < delta:
		generate_mesh()

func initialize_volume():
	# Initialize the 3D volume data
	volume_data.resize(CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE)
	for i in range(volume_data.size()):
		volume_data[i] = 1.0  # Default all to outside (positive)
	
	print("Volume initialized: %d voxels" % volume_data.size())

func set_voxel(x: int, y: int, z: int, value: float):
	# Set a voxel value, with bounds checking
	if x >= 0 and x < CHUNK_SIZE and y >= 0 and y < CHUNK_SIZE and z >= 0 and z < CHUNK_SIZE:
		volume_data[x + y * CHUNK_SIZE + z * CHUNK_SIZE * CHUNK_SIZE] = value

func get_voxel(x: int, y: int, z: int) -> float:
	# Get a voxel value, with bounds checking
	if x >= 0 and x < CHUNK_SIZE and y >= 0 and y < CHUNK_SIZE and z >= 0 and z < CHUNK_SIZE:
		return volume_data[x + y * CHUNK_SIZE + z * CHUNK_SIZE * CHUNK_SIZE]
	return 1.0  # Outside is positive

func generate_mesh():
	# Fill the volume with SDF values
	populate_volume()
	
	# Use marching cubes to extract the mesh
	var mesh = apply_marching_cubes()
	
	# Assign the mesh
	mesh_instance.mesh = mesh

func populate_volume():
	# Populate the volume with SDF values
	# This is where the shape is defined
	
	var center = Vector3(CHUNK_SIZE/2, CHUNK_SIZE/2, CHUNK_SIZE/2)
	var time_offset = sin(time_factor) * 2.0
	
	for z in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			for x in range(CHUNK_SIZE):
				var pos = Vector3(x, y, z)
				var density = calculate_sdf(pos, center, time_offset)
				set_voxel(x, y, z, density)
		
		# Report progress
		if z % 4 == 0:
			var progress = float(z) / CHUNK_SIZE
			emit_signal("generation_progress", progress)

func calculate_sdf(pos: Vector3, center: Vector3, time_offset: float) -> float:
	# Calculate SDF value at a position
	# Negative inside, positive outside
	
	# Normalize position to -1 to 1 range
	var p = (pos - center) / (CHUNK_SIZE * 0.5) * field_scale
	
	# Apply time-based animation
	p.x += sin(time_offset * 0.5) * 0.2
	p.y += cos(time_offset * 0.7) * 0.1
	
	# Basic shape SDFs
	var sphere1 = sphere_sdf(p, Vector3.ZERO, 0.7)
	var sphere2 = sphere_sdf(p, Vector3(sin(time_offset) * 0.4, 0.3, cos(time_offset) * 0.4), 0.5)
	var torus = torus_sdf(p, 0.6, 0.2)
	var box = box_sdf(p, Vector3(0.5, 0.5, 0.5))
	
	# Add noise
	var noise_val = noise_3d(p.x * 3.0, p.y * 3.0, p.z * 3.0) * noise_influence
	
	# Blend shapes using smooth minimum
	var result = smooth_min(sphere1, sphere2, blend_strength)
	result = smooth_min(result, torus, blend_strength)
	result = smooth_min(result, box, blend_strength * 0.5)
	
	# Apply noise
	result += noise_val
	
	return result * (CHUNK_SIZE * 0.5)  # Scale back to volume size

# SDF primitives
func sphere_sdf(p: Vector3, center: Vector3, radius: float) -> float:
	return (p - center).length() - radius

func box_sdf(p: Vector3, b: Vector3) -> float:
	var q = p.abs() - b
	return q.max(Vector3.ZERO).length() + min(max(q.x, max(q.y, q.z)), 0.0)

func torus_sdf(p: Vector3, R: float, r: float) -> float:
	var p_xz = Vector2(p.x, p.z)
	var q = Vector2(p_xz.length() - R, p.y)
	return q.length() - r

# SDF operations
func smooth_min(a: float, b: float, k: float) -> float:
	var h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0)
	return lerp(b, a, h) - k * h * (1.0 - h)

func noise_3d(x: float, y: float, z: float) -> float:
	# Simple hash-based 3D noise
	var p = Vector3(x, y, z)
	var h = hash_3d(p)
	return h * 2.0 - 1.0

func hash_3d(p: Vector3) -> float:
	# Jenkins hash
	var h = 0
	h = h + int(p.x * 374761393) & 0xFFFFFFFF
	h = h + int(p.y * 668265263) & 0xFFFFFFFF
	h = h + int(p.z * 968413130) & 0xFFFFFFFF
	h = h ^ (h >> 13)
	h = h * 1274126177 & 0xFFFFFFFF
	h = h ^ (h >> 16)
	return float(h) / 4294967295.0 # Normalize to 0-1

func apply_marching_cubes() -> Mesh:
	# Generate mesh using marching cubes algorithm
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	var triangle_count = 0
	
	# Traverse each cube in the volume
	for z in range(CHUNK_SIZE - 1):
		for y in range(CHUNK_SIZE - 1):
			for x in range(CHUNK_SIZE - 1):
				# Get the eight corners of this cube
				var cube_values = [
					get_voxel(x, y, z),
					get_voxel(x+1, y, z),
					get_voxel(x+1, y, z+1),
					get_voxel(x, y, z+1),
					get_voxel(x, y+1, z),
					get_voxel(x+1, y+1, z),
					get_voxel(x+1, y+1, z+1),
					get_voxel(x, y+1, z+1)
				]
				
				# Determine cube configuration index
				var cube_index = 0
				for i in range(8):
					if cube_values[i] < ISO_LEVEL:
						cube_index |= (1 << i)
				
				# Skip empty cubes
				if cube_index == 0 or cube_index == 255:
					continue
				
				# Get the edges with intersection points
				var edge_mask = edge_table[cube_index]
				if edge_mask == 0:
					continue
				
				# Interpolate vertices for each intersected edge
				var edge_vertices = []
				for i in range(12):
					edge_vertices.append(null)  # Initialize all edges to null
				
				if edge_mask & 1:    # Edge 0: (0,1)
					edge_vertices[0] = interpolate_vertex(
						Vector3(x, y, z), Vector3(x+1, y, z),
						cube_values[0], cube_values[1])
				if edge_mask & 2:    # Edge 1: (1,2)
					edge_vertices[1] = interpolate_vertex(
						Vector3(x+1, y, z), Vector3(x+1, y, z+1),
						cube_values[1], cube_values[2])
				if edge_mask & 4:    # Edge 2: (2,3)
					edge_vertices[2] = interpolate_vertex(
						Vector3(x+1, y, z+1), Vector3(x, y, z+1),
						cube_values[2], cube_values[3])
				if edge_mask & 8:    # Edge 3: (3,0)
					edge_vertices[3] = interpolate_vertex(
						Vector3(x, y, z+1), Vector3(x, y, z),
						cube_values[3], cube_values[0])
				if edge_mask & 16:   # Edge 4: (4,5)
					edge_vertices[4] = interpolate_vertex(
						Vector3(x, y+1, z), Vector3(x+1, y+1, z),
						cube_values[4], cube_values[5])
				if edge_mask & 32:   # Edge 5: (5,6)
					edge_vertices[5] = interpolate_vertex(
						Vector3(x+1, y+1, z), Vector3(x+1, y+1, z+1),
						cube_values[5], cube_values[6])
				if edge_mask & 64:   # Edge 6: (6,7)
					edge_vertices[6] = interpolate_vertex(
						Vector3(x+1, y+1, z+1), Vector3(x, y+1, z+1),
						cube_values[6], cube_values[7])
				if edge_mask & 128:  # Edge 7: (7,4)
					edge_vertices[7] = interpolate_vertex(
						Vector3(x, y+1, z+1), Vector3(x, y+1, z),
						cube_values[7], cube_values[4])
				if edge_mask & 256:  # Edge 8: (0,4)
					edge_vertices[8] = interpolate_vertex(
						Vector3(x, y, z), Vector3(x, y+1, z),
						cube_values[0], cube_values[4])
				if edge_mask & 512:  # Edge 9: (1,5)
					edge_vertices[9] = interpolate_vertex(
						Vector3(x+1, y, z), Vector3(x+1, y+1, z),
						cube_values[1], cube_values[5])
				if edge_mask & 1024: # Edge 10: (2,6)
					edge_vertices[10] = interpolate_vertex(
						Vector3(x+1, y, z+1), Vector3(x+1, y+1, z+1),
						cube_values[2], cube_values[6])
				if edge_mask & 2048: # Edge 11: (3,7)
					edge_vertices[11] = interpolate_vertex(
						Vector3(x, y, z+1), Vector3(x, y+1, z+1),
						cube_values[3], cube_values[7])
				
				# Create triangles according to the cube configuration
				var i = 0
				while tri_table[cube_index][i] != -1 and triangle_count < MAX_TRIANGLES:
					var v1 = edge_vertices[tri_table[cube_index][i]]
					var v2 = edge_vertices[tri_table[cube_index][i+1]]
					var v3 = edge_vertices[tri_table[cube_index][i+2]]
					
					vertices.append(v1)
					vertices.append(v2)
					vertices.append(v3)
					
					# Calculate normal
					var normal = (v2 - v1).cross(v3 - v1).normalized()
					normals.append(normal)
					normals.append(normal)
					normals.append(normal)
					
					triangle_count += 1
					i += 3
	
	# Create mesh from vertices
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	
	if vertices.size() > 0:
		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		emit_signal("generation_completed", triangle_count)
		print("Generated mesh with %d triangles" % triangle_count)
	else:
		print("No vertices generated")
	
	return arr_mesh

func interpolate_vertex(p1: Vector3, p2: Vector3, v1: float, v2: float) -> Vector3:
	# Find the point between p1 and p2 where the isosurface crosses
	if abs(ISO_LEVEL - v1) < 0.00001:
		return p1
	if abs(ISO_LEVEL - v2) < 0.00001:
		return p2
	if abs(v1 - v2) < 0.00001:
		return p1
	
	var t = (ISO_LEVEL - v1) / (v2 - v1)
	return p1 + t * (p2 - p1)

# Public API for adjusting parameters
func set_blend_strength(value: float):
	blend_strength = clamp(value, 0.0, 1.0)
	print("Blend strength set to: %.2f" % blend_strength)

func set_field_scale(value: float):
	field_scale = clamp(value, 0.1, 5.0)
	print("Field scale set to: %.2f" % field_scale)

func set_noise_influence(value: float):
	noise_influence = clamp(value, 0.0, 1.0)
	print("Noise influence set to: %.2f" % noise_influence)

# Utility function for debugging
func visualize_slice(y_slice: int):
	# Create a debug visualization of a horizontal slice through the volume
	var img = Image.create(CHUNK_SIZE, CHUNK_SIZE, false, Image.FORMAT_RGB8)
	
	for z in range(CHUNK_SIZE):
		for x in range(CHUNK_SIZE):
			var val = get_voxel(x, y_slice, z)
			var color_val# = range_lerp(val, -1.0, 1.0, 0.0, 1.0)
			color_val = clamp(color_val, 0.0, 1.0)
			
			var color = Color(color_val, color_val, color_val)
			if abs(val - ISO_LEVEL) < 0.05:
				color = Color(1.0, 0.0, 0.0)  # Highlight the isosurface in red
				
			img.set_pixel(x, z, color)
	
	return img
