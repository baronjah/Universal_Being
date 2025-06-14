# AsteroidField.gd in AsteroidField scene
@tool
extends Node3D

var asteroid_density: float = 0.01
var asteroid_radius: float = 0.5
var asteroid_size: float = 512.0

var asteroid_2d_scene = preload("res://Scenes/celestialflatsteroid.tscn")
var asteroid_3d_scene = preload("res://Scenes/CelestialAsteroid.tscn")
var rd: RenderingDevice
var shader: RID
var pipeline: RID
var uniform_set: RID
var buffer: RID
var asteroid_data : Dictionary

var rng = RandomNumberGenerator.new()

var transition_distance: float = 36.9
var asteroids: Array = []

class AsteroidData:
	extends Node
	var position: Vector3
	var scale: Vector3
	var seed_asteroid: int
	var radius_asteroid: float
	var mass_asteroid: float
	var current_child: Sprite3D = null
	var is_3d: bool = false

	func _init(pos: Vector3, scl: Vector3, seed_a: int, radius_a: float, mass_a: float):
		position = pos
		scale = scl
		seed_asteroid = seed_a
		radius_asteroid = radius_a
		mass_asteroid = mass_a

func _ready():
	setup_compute_shader()
	#print("we in ready lol")
	generate_asteroids()
	
func _process(delta):
	update_asteroid_transitions()
	#print("papaja")

func setup_compute_shader():
	print("compute shader setup")
	rd = RenderingServer.create_local_rendering_device()
	
	var shader_file = load("res://ComputeShaders/AsteroidsPositions.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	
	pipeline = rd.compute_pipeline_create(shader)
	var uniform_data = PackedFloat32Array([
		rng.randf_range(0, 9999),  # Random seed
		asteroid_density,
		asteroid_size,
		asteroid_radius
	])
	print(uniform_data)
	var uniform_bytes = uniform_data.to_byte_array()
	var uniform_buffer = rd.uniform_buffer_create(uniform_bytes.size(), uniform_bytes)
	
	var resolution = int(asteroid_size)
	buffer = rd.storage_buffer_create(resolution * resolution * 16)  # 16 bytes per vec4
	
	var uniform_1 = RDUniform.new()
	uniform_1.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
	uniform_1.binding = 0
	uniform_1.add_id(uniform_buffer)
	
	var uniform_2 = RDUniform.new()
	uniform_2.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform_2.binding = 1
	uniform_2.add_id(buffer)
	
	uniform_set = rd.uniform_set_create([uniform_1, uniform_2], shader, 0)

func generate_asteroids():
	var resolution = int(asteroid_size)

	var compute_list = rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, resolution / 16, resolution / 16, 1)
	rd.compute_list_end()
	rd.submit()
	rd.sync()
	var output_bytes = rd.buffer_get_data(buffer)
	var output = output_bytes.to_float32_array()
	for i in range(0, output.size(), 4):
		if output[i + 3] > 0.01:  # Check alpha value
			var pos = Vector3((output[i] * (resolution * 2.0)) - resolution, 0, (output[i + 1] * (resolution * 2.0)) - resolution)
			pos.y = generate_torus(pos)
			var scale = Vector3.ONE * (output[i + 2] * 0.01 + 0.005)
			var current_asteroid = generate_asteroid_data()
			
			var asteroid_data = AsteroidData.new(pos, scale, current_asteroid.seed_asteroid, current_asteroid.radius_asteroid, current_asteroid.mass_asteroid)
			add_child(asteroid_data)
			asteroids.append(asteroid_data)
			ensure_2d_asteroid(asteroid_data)

func generate_torus(pos: Vector3) -> float:
	# Extract X and Z coordinates
	var first_number = pos.x
	var second_number = pos.z
	var two_numbers = Vector2(first_number, second_number)
	
	var maximum_zone = asteroid_size
	var minimum_zone = asteroid_size * 0.8
	var offset_value = asteroid_size * 0.1
	
	# Calculate the distance from the center
	var distance = two_numbers.length()
	
	# Calculate normalized distance in range [0, 1]
	var normalized_distance = (distance - minimum_zone) / (maximum_zone - minimum_zone)
	normalized_distance = clamp(normalized_distance, 0.0, 1.0)
	
	# Apply easing function (quadratic easing)
	var torus_value = pow(sin(normalized_distance * PI), 2.0)
	torus_value = 1 - pow(1 - torus_value, 4)
	
	# Optionally: Scale by some factor or apply additional functions to control density
	torus_value = torus_value * offset_value
	var random_offset = rng.randf_range(-torus_value, torus_value)
	torus_value = random_offset
	return torus_value
		
func generate_asteroid_data():
	# Generate the random parameters
	var seed_asteroid = rng.randi_range(1, 9999)
	var radius_asteroid = rng.randf_range(1.0, 0.1)
	var mass_asteroid = rng.randf_range(36.9, 963.3)

	# Create the dictionary with the parameters
	var asteroid_data = {
		"seed_asteroid": seed_asteroid,
		"radius_asteroid": radius_asteroid,
		"mass_asteroid": mass_asteroid
	}
	return asteroid_data

func update_asteroid_transitions():
	var camera = get_viewport().get_camera_3d()
	if camera:
		for asteroid_data in asteroids:
			var distance = camera.global_transform.origin.distance_to(asteroid_data.position)
			if distance < transition_distance and not asteroid_data.is_3d:
				ensure_3d_asteroid(asteroid_data)
			elif distance >= transition_distance and asteroid_data.is_3d:
				ensure_2d_asteroid(asteroid_data)

func ensure_3d_asteroid(asteroid_data: AsteroidData):
	if asteroid_data.current_child:
		asteroid_data.current_child.queue_free()
	
	var asteroid_3d = asteroid_3d_scene.instantiate()
	asteroid_3d.position = asteroid_data.position
	asteroid_3d.scale = asteroid_data.scale
	asteroid_3d.set_parameters(asteroid_data.seed_asteroid, asteroid_data.radius_asteroid, asteroid_data.mass_asteroid, {})
	asteroid_data.add_child(asteroid_3d)
	asteroid_data.current_child = asteroid_3d
	asteroid_data.is_3d = true

func ensure_2d_asteroid(asteroid_data: AsteroidData):
	if asteroid_data.current_child:
		asteroid_data.current_child.queue_free()
	
	var asteroid_2d = asteroid_2d_scene.instantiate()
	asteroid_2d.position = asteroid_data.position
	asteroid_2d.scale = asteroid_data.scale
	asteroid_2d.set_parameters(asteroid_data.seed_asteroid, asteroid_data.radius_asteroid, asteroid_data.mass_asteroid, {})
	asteroid_data.add_child(asteroid_2d)
	asteroid_data.current_child = asteroid_2d
	asteroid_data.is_3d = false
