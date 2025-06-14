# CelestialAsteroid.gd
@tool
extends Sprite3D

var shader_material: ShaderMaterial
var asteroid_id: int
var star_seed: int
var asteroid_seed: int
var material
var camera: Camera3D
var rotation_speed: float = 1.0  # Adjust as needed
var position_basis: Basis
var position_basis2: Basis
var star_basis: Basis
var star_vector: Vector3
var asteroid_mass
var asteroid_radius
var asteroid_data: Dictionary

# the ready function, runs once and is done
func _ready():
	setup_asteroid()
	camera = get_viewport().get_camera_3d()

# the process function that runs each and every frame
func _process(delta):
	var time = (Time.get_ticks_msec() / 1000.0)
	shader_material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
	var camera_x = -camera.global_transform.basis.x
	var camera_y = camera.global_transform.basis.y
	var camera_z = -camera.global_transform.basis.z
	var camera_matrix  = Basis(camera_x, camera_y, camera_z).orthonormalized()
	var camera_pos = camera.global_transform.origin
	enhanced_look_at(self, camera_pos)
	var basis_1_x = (camera_matrix.x + position_basis.x) / 2
	var basis_1_y = (camera_matrix.y + position_basis.y) / 2
	var basis_1_z = (camera_matrix.z + position_basis.z) / 2
	var new_final_matrix = Basis(basis_1_x, basis_1_y, basis_1_z)
	var moon_rotation = global_transform.basis
	var moon_rotation_x = moon_rotation.x
	var moon_rotation_y = moon_rotation.y
	var moon_rotation_z = moon_rotation.z
	var rotation_moon = Basis(-moon_rotation_x, -moon_rotation_y, moon_rotation_z)
	var combined_basis = rotation_moon * new_final_matrix
	shader_material.set_shader_parameter("rotation_matrix", combined_basis) # one for our camera combined_basis
	shader_material.set_shader_parameter("position_matrix", position_basis) # one for light direction position_basis
	enhanced_look_at_star(self, star_vector) # star_basis
	var star_basis_x = star_basis.x
	var star_basis_y = star_basis.y
	var star_basis_z = star_basis.z
	var rotation_star = Basis(-star_basis_x, -star_basis_y, -star_basis_z)
	shader_material.set_shader_parameter("direction_matrix", star_basis)
	pixel_size = 0.001

func enhanced_look_at(node: Node3D, target: Vector3) -> void:
	var origin: Vector3 = node.global_transform.origin
	var forward: Vector3 = (target - origin).normalized()
	# Just return if at the same position
	if origin == target:
		return
	# Calculate right and up vectors based on the camera's basis
	var camera_cam_x = camera.global_transform.basis.x
	var camera_cam_y = camera.global_transform.basis.y
	var right: Vector3 = -camera_cam_x
	var up: Vector3 = -camera_cam_y
	# If the forward vector is too close to the up vector, adjust the up vector to avoid gimbal lock
	if abs(forward.dot(up)) > 0.999:
		up = Vector3.UP if abs(forward.dot(Vector3.UP)) < 0.999 else Vector3.RIGHT
	# Recalculate right and up vectors
	right = up.cross(forward).normalized()
	up = forward.cross(right).normalized()
	# Create a new basis with the calculated vectors
	var new_basis = Basis(right, -up, -forward)
	position_basis = new_basis

# check the rotation basis in direction of the star!
func enhanced_look_at_star(node: Node3D, target: Vector3) -> void:
	var origin: Vector3 = node.global_transform.origin
	var forward: Vector3 = (target - origin).normalized()
	# Just return if at the same position
	if origin == target:
		return
	# Calculate right and up vectors based on the camera's basis
	var camera_cam_x = camera.global_transform.basis.x
	var camera_cam_y = camera.global_transform.basis.y
	var right: Vector3 = -camera_cam_x
	var up: Vector3 = -camera_cam_y
	# If the forward vector is too close to the up vector, adjust the up vector to avoid gimbal lock
	if abs(forward.dot(up)) > 0.999:
		up = Vector3.UP if abs(forward.dot(Vector3.UP)) < 0.999 else Vector3.RIGHT
	# Recalculate right and up vectors
	right = up.cross(forward).normalized()
	up = forward.cross(right).normalized()
	# Create a new basis with the calculated vectors
	var new_basis = Basis(right, -up, -forward)
	star_basis = new_basis

func setup_asteroid():
	var image = Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 1))
	var asteroid_texture = ImageTexture.create_from_image(image)
	self.texture = asteroid_texture

	var shader = load("res://Shaders/CelestialAsteroid.gdshader")
	if shader == null:
		print("Error: Could not load CelestialAsteroid.gdshader file")
		return

	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	material_override = shader_material
	asteroid_id = get_instance_id()

func set_parameters(seed_asteroid: int, radius_asteroid: float, mass_asteroid: float, data: Dictionary):
	asteroid_seed = seed_asteroid
	asteroid_radius = radius_asteroid
	asteroid_data = data
	shader_material.set_shader_parameter("asteroid_seed", float(seed_asteroid))
	pixel_size = asteroid_radius / 100

func get_scene_node(path: String) -> Node: 
	return get_tree().get_root().get_node(path)

func get_asteroid_id():
	return asteroid_id

func get_asteroid_seed():
	return asteroid_seed

func get_asteroid_mass():
	return asteroid_mass

func get_asteroid_radius():
	return asteroid_radius

func get_asteroid_data():
	return asteroid_data
