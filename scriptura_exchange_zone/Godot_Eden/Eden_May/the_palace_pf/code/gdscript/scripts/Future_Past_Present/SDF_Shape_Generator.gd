extends Node3D

# SDF Shape Generator
# This script implements a signed distance field (SDF) based shape generator with marching cubes

const CHUNK_SIZE = 32  # Size of the volume to generate
const ISO_LEVEL = 0.5  # Surface threshold

# Marching cubes tables would go here in a full implementation
# They define how to triangulate each cube configuration

# Shape parameters
var shape_params = {
	"blend_factor": 0.5,     # How much shapes blend (0-1)
	"smooth_factor": 0.2,    # Smoothing amount
	"noise_scale": 0.5,      # Scale of noise applied to shapes
	"time_scale": 0.2,       # Animation speed for time-based effects
	"seed": 12345            # Random seed for reproducibility
}

# Volume data
var volume_data = []
var mesh_instance = null

func _ready():
	initialize_volume(CHUNK_SIZE)
	mesh_instance = MeshInstance3D.new()
	add_child(mesh_instance)
	
	# Generate initial shape
	generate_shape()
	
	# Set up material
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.3, 0.7, 0.9, 0.8)
	material.metallic = 0.7
	material.roughness = 0.2
	material.emission_enabled = true
	material.emission = Color(0.2, 0.4, 0.8)
	material.emission_energy = 0.5
	
	mesh_instance.material_override = material

func _process(delta):
	# Update shape over time for animations
	shape_params.time_offset = (shape_params.time_offset if "time_offset" in shape_params else 0.0) + delta * shape_params.time_scale
	generate_shape()

func initialize_volume(size):
	# Create a 3D array to hold our density values
	volume_data.resize(size * size * size)
	volume_data.fill(0.0)
	print("Volume initialized with size: %d x %d x %d" % [size, size, size])

func generate_shape():
	# Generate the SDF field
	var center = Vector3(CHUNK_SIZE/2, CHUNK_SIZE/2, CHUNK_SIZE/2)
	var time_offset = shape_params.time_offset if "time_offset" in shape_params else 0.0
	
	for z in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			for x in range(CHUNK_SIZE):
				var pos = Vector3(x, y, z)
				var density = calculate_density(pos, center, time_offset)
				volume_data[x + y * CHUNK_SIZE + z * CHUNK_SIZE * CHUNK_SIZE] = density
	
	# Apply marching cubes to generate the mesh
	var mesh = apply_marching_cubes()
	mesh_instance.mesh = mesh

func calculate_density(pos, center, time_offset):
	# Sample point position relative to center
	var p = pos - center
	
	# Basic sphere SDF
	var sphere1 = p.length() - 10.0
	
	# Second sphere with time-based animation
	var p2 = p
	p2.x += sin(time_offset * 2.0) * 5.0
	p2.y += cos(time_offset * 1.5) * 3.0
	var sphere2 = p2.length() - 8.0
	
	# Torus SDF
	var p3 = p
	p3.y += sin(time_offset) * 2.0
	var q = Vector2(Vector2(p3.x, p3.z).length() - 12.0, p3.y)
	var torus = q.length() - 3.0
	
	# Noise distortion
	var noise_val = noise_3d(p.x * shape_params.noise_scale, 
							 p.y * shape_params.noise_scale,
							 p.z * shape_params.noise_scale)
	
	# Blend shapes using smooth min function
	var blended = smooth_min(sphere1, sphere2, shape_params.blend_factor)
	blended = smooth_min(blended, torus, shape_params.blend_factor)
	
	# Apply noise
	blended += noise_val * 2.0
	
	# Return final density (negative inside, positive outside)
	return blended

func smooth_min(a, b, k):
	# Smooth minimum function for blending SDFs
	var h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0)
	return lerp(b, a, h) - k * h * (1.0 - h)

func noise_3d(x, y, z):
	# Simple noise function for 3D coordinates
	var p = Vector3(x, y, z)
	p = Vector3(
		fract(sin(p.dot(Vector3(127.1, 311.7, 74.7))) * 43758.5453),
		fract(sin(p.dot(Vector3(269.5, 183.3, 246.1))) * 43758.5453),
		fract(sin(p.dot(Vector3(113.5, 271.9, 124.6))) * 43758.5453)
	)
	return -1.0 + 2.0 * p.length()

func fract(data):
	print(" fract function data it : ", data)

func apply_marching_cubes():
	# Simplified marching cubes implementation
	var vertices = PackedVector3Array()
	var normals = PackedVector3Array()
	
	# Traverse volume
	for z in range(CHUNK_SIZE-1):
		for y in range(CHUNK_SIZE-1):
			for x in range(CHUNK_SIZE-1):
				# Sample density values at cube corners
				var cube = [
					get_density(x, y, z),
					get_density(x+1, y, z),
					get_density(x+1, y, z+1),
					get_density(x, y, z+1),
					get_density(x, y+1, z),
					get_density(x+1, y+1, z),
					get_density(x+1, y+1, z+1),
					get_density(x, y+1, z+1)
				]
				
				# Determine which vertices are inside/outside the surface
				var cube_index = 0
				for i in range(8):
					if cube[i] < ISO_LEVEL:
						cube_index |= (1 << i)
				
				# Skip empty cubes
				if cube_index == 0 or cube_index == 255:
					continue
				
				# Generate triangles - simplified version
				# In a real implementation, we would use edge tables and interpolation
				# based on the actual density values
				
				# For this simplified version, let's just create a vertex at the center
				# of any cube that intersects the surface
				var center = Vector3(x + 0.5, y + 0.5, z + 0.5)
				
				# Add some variation to make it look less blocky
				var offset = Vector3(
					randf_range(-0.2, 0.2),
					randf_range(-0.2, 0.2),
					randf_range(-0.2, 0.2)
				)
				
				center += offset
				
				# Calculate approximate normal
				var normal = Vector3(
					get_density(x+1, y, z) - get_density(x-1, y, z),
					get_density(x, y+1, z) - get_density(x, y-1, z),
					get_density(x, y, z+1) - get_density(x, y, z-1)
				).normalized()
				
				# Create triangles - very simplified version
				if randf() > 0.5:  # Skip some to reduce density
					vertices.append(center)
					normals.append(normal)
	
	# Create mesh from vertices
	var arr_mesh = ArrayMesh.new()
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	
	if vertices.size() > 0:
		arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, arrays)
		print("Generated mesh with %d points" % vertices.size())
	else:
		print("No vertices generated")
	
	return arr_mesh

func get_density(x, y, z):
	# Get density value from the volume, with bounds checking
	if x < 0 or y < 0 or z < 0 or x >= CHUNK_SIZE or y >= CHUNK_SIZE or z >= CHUNK_SIZE:
		return 1.0  # Outside is positive
	
	return volume_data[x + y * CHUNK_SIZE + z * CHUNK_SIZE * CHUNK_SIZE]

# Shape parameter manipulation functions
func set_blend_factor(value):
	shape_params.blend_factor = clamp(value, 0.0, 1.0)
	
func set_noise_scale(value):
	shape_params.noise_scale = clamp(value, 0.0, 2.0)
	
func set_time_scale(value):
	shape_params.time_scale = clamp(value, 0.0, 1.0)
	
func set_seed(value):
	shape_params.seed = value
	seed(value)
