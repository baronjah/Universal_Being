# CelestialPlanetSprite.gd

extends Sprite3D

var shader_material: ShaderMaterial
var planet_id: int
var planet_seed: int
#var star_temperature: float
#var star_brightness: float
var material
var camera: Camera3D
var rotation_speed: float = 1.0  # Adjust as needed
var position_basis: Basis
var star_basis: Basis
var tilt_angle: float = 0.0
var star_vector: Vector3
var planet_data
var planet_type
var radius
var orbit_radius
var mass
var orbit_speed
var moons
var habitable
var water
var basic_resources
var rare_resources
var spin_speed
var planet_data_records

func _ready():
	setup_planet()
	camera = get_viewport().get_camera_3d()
	#rotation_degrees.x = tilt_angle


func _process(delta):
	
	var time = (Time.get_ticks_msec() / 1000.0) * 0.98
	var time2 = (Time.get_ticks_msec() / 10000.0) * 0.96
	var time3 = Time.get_ticks_msec()
	var timer_reset = int(time)
	var timer_reset2 = int(time2)
	var timer_new = time - timer_reset
	var timer_new2 = time2 - timer_reset2
	var information =  0.5 * timer_new
	var oscillation = abs(1 - (timer_new * 2))
	var oscillation2 = abs(1 - (timer_new2 * 2))
	var information2 = 0.5 * oscillation
	var information3 = 0.5 + information2
	var information4 = 2 + (2.0 * oscillation2)
	shader_material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
	shader_material.set_shader_parameter("offset_one", information2)
	shader_material.set_shader_parameter("offset_two", information3)
	shader_material.set_shader_parameter("offset_three", information4)
	shader_material.set_shader_parameter("time_int", time3)
	
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

	var planet_rotation = global_transform.basis
	var planet_rotation_x = planet_rotation.x
	var planet_rotation_y = planet_rotation.y
	var planet_rotation_z = planet_rotation.z
	var rotation_planet = Basis(-planet_rotation_x, -planet_rotation_y, planet_rotation_z)
	
	var combined_basis = rotation_planet * position_basis

	#var spin_speed: float = 2.0
	self.rotate_y(spin_speed * delta) #
	
	shader_material.set_shader_parameter("rotation_matrix", combined_basis) # one for our camera combined_basis
	shader_material.set_shader_parameter("position_matrix", position_basis) # one for light direction position_basis
	#var position_basis2 = Basis(-position_basis.x, -position_basis.y, -position_basis.z)
	#shader_material.set_shader_parameter("position_matrix2", position_basis2) # one for light direction position_basis
	#var light_direction = calculate_light_direction()
	#var light_direction_x = light_direction.x
	#var light_direction_y = light_direction.y
	#var light_direction_z = light_direction.z
	#print(star_vector)
	enhanced_look_at_star(self, star_vector) # star_basis

	
	#var light_direction_matrix = Basis(light_direction, light_direction.cross(Vector3.UP).normalized(), light_direction.cross(Vector3.RIGHT).normalized())
	var star_basis_x = star_basis.x
	var star_basis_y = star_basis.y
	var star_basis_z = star_basis.z
	var rotation_star = Basis(-star_basis_x, -star_basis_y, -star_basis_z)
	
	#camera_matrix = camera orientation, so sprite looks good
	#position_basis = what enhanced look at spits out
	#rotation_planet = planet own rotation
	#star_basis = what lok at does when we put target as 0,0,0
	#new_final_matrix = camera + position /2
	#var combined_basis = rotation_planet * new_final_matrix
	#var planet_rot = rotation_planet * position_basis
	#var basis_2_x = (star_basis.x + rotation_planet.x) / 2
	#var basis_2_y = (star_basis.y + rotation_planet.y) / 2
	#var basis_2_z = (star_basis.z + rotation_planet.z) / 2
	#var new_final_matrix2 = Basis(basis_2_x, basis_2_y, basis_2_z)

	#var new_ld = star_basis * planet_rot
	#var newest_ld = new_final_matrix * new_ld
	shader_material.set_shader_parameter("direction_matrix", star_basis)
	#shader_material.set_shader_parameter("direction_matrix2", rotation_star)
	#shader_material.set_shader_parameter("planet_position", global_transform.origin)
	
#func calculate_light_direction():
#	var star_position = Vector3.ZERO
#	var planet_position = global_transform.origin
#	var light_direction = (star_position - planet_position).normalized()
#	
	# Try switching the components around
#	return Vector3(light_direction.z, light_direction.y, -light_direction.x)
	
# Enhanced look-at function that adjusts the basis of the node considering all three axes
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

func setup_planet():

	var image = Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 1))
	var star_texture = ImageTexture.create_from_image(image)
	self.texture = star_texture

	var shader = load("res://Shaders/CelestialPlanet.gdshader")
	if shader == null:
		print("Error: Could not load CelestialBody.gdshader file")
		return

	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	material_override = shader_material

	planet_id = get_instance_id()

func set_parameters(seed_planet: int, planet_type: int, radius: float, orbit_radius: float, planet_tilt: float, planet_rotation: float, planet_data_system: Dictionary):
	#print("celestal planet sprite data, seed_planet = ", seed_planet," planet_type = ", planet_type," radius = ", radius, " orbit_radius = ",orbit_radius)
	#noise_scale, shininess, planet_type
	planet_data_records = planet_data_system
	planet_seed = seed_planet
	tilt_angle = planet_tilt
	rotation_degrees.x = tilt_angle
	spin_speed = planet_rotation
	var delta_Alpha = GlobalState.elapsed_time_seconds
	print("delta_Alpha = ", delta_Alpha)
	self.rotate_y(spin_speed * delta_Alpha)
	shader_material.set_shader_parameter("planet_seed", float(planet_seed))
	shader_material.set_shader_parameter("noise_scale", radius * 8)
	#shader_material.set_shader_parameter("shininess", how far it is from sun either divided or multipled by something, we need to check)
	shader_material.set_shader_parameter("planet_type", planet_type)

	#self.scale = Vector3.ONE * (radius / )
	pixel_size = radius / 1000

func temperature_to_color(temperature: float) -> Color:

	if temperature < 3500:
		return Color(1.0, 0.5, 0.0, 1.0)  # Red
	elif temperature < 5000:
		return Color(1.0, 0.8, 0.0, 1.0)  # Orange
	elif temperature < 6000:
		return Color(1.0, 1.0, 1.0, 1.0)  # White
	elif temperature < 10000:
		return Color(0.8, 0.8, 1.0, 1.0)  # Light Blue
	else:
		return Color(0.6, 0.6, 1.0, 1.0)  # Blue

func get_planet_id():

	return planet_id

func get_planet_seed():

	return planet_seed

func get_planet_type():

	return planet_type

func get_planet_data():

	return planet_data
	
func get_planet_data_records():
	return planet_data_records
