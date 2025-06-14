# CelestialBody.gd res://Scripts/CelestialBody.gd
@tool
extends Sprite3D

var shader_material: ShaderMaterial
var star_id: int
var star_seed: int
var star_temperature: float
var star_brightness: float
var material
var camera: Camera3D

var position_basis: Basis

func _ready():
	setup_star()
	camera = get_viewport().get_camera_3d()

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
	var information3 = 0.5 + information2#(0.5 - information2)
	var information4 = 2 + (2.0 * oscillation2)
	shader_material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
	shader_material.set_shader_parameter("offset_one", information2)
	shader_material.set_shader_parameter("offset_two", information3)
	shader_material.set_shader_parameter("offset_three", information4)
	shader_material.set_shader_parameter("time_int", time3)
	
	#camera matrix
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
	
	shader_material.set_shader_parameter("rotation_matrix", new_final_matrix)

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

func setup_star():

	var image = Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 1))
	var star_texture = ImageTexture.create_from_image(image)
	self.texture = star_texture

	var shader = load("res://Shaders/CelestialBody.gdshader")
	if shader == null:
		print("Error: Could not load CelestialBody.gdshader file")
		return

	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	material_override = shader_material

	star_id = get_instance_id()

func set_parameters(seed_star: int, temperature: float, brightness: float):

	star_seed = seed_star
	star_temperature = temperature
	star_brightness = brightness

	var star_color = temperature_to_color(temperature)

	shader_material.set_shader_parameter("star_seed", float(seed_star))
	shader_material.set_shader_parameter("temperature_star", temperature)
	shader_material.set_shader_parameter("brightness", brightness)
	shader_material.set_shader_parameter("color", star_color)

	self.scale = Vector3.ONE * brightness
	pixel_size = brightness / 100

func temperature_to_color(temperature: float) -> Color:
	print("galaxy temp in function = ", temperature)
	
	# Define color ranges for different temperature brackets
	var colors = [
		Color(1.0, 0.0, 0.0),   # Red
		Color(1.0, 0.5, 0.0),   # Orange
		Color(1.0, 1.0, 0.0),   # Yellow
		Color(1.0, 1.0, 1.0),   # White
		Color(0.5, 1.0, 1.0),   # Light Blue
		Color(0.0, 0.0, 1.0),   # Blue
		Color(0.5, 0.0, 1.0)    # Purple
	]

	# Define the temperature range
	var min_temp = 2000.0
	var max_temp = 18000.0

	# Clamp temperature between min_temp and max_temp
	var clamped_temp = clamp(temperature, min_temp, max_temp)
	
	# Normalize temperature to 0-1 range
	var normalized_temp = (clamped_temp - min_temp) / (max_temp - min_temp)
	
	# Ensure normalized_temp is exactly 0.0 or 1.0 at the extremes
	if is_equal_approx(normalized_temp, 0.0):
		normalized_temp = 0.0
	elif is_equal_approx(normalized_temp, 1.0):
		normalized_temp = 1.0
	
	# Calculate color index
	var color_index = normalized_temp * (colors.size() - 1)
	
	var index1 = int(floor(color_index))
	var index2 = int(ceil(color_index))
	index2 = min(index2, colors.size() - 1)  # Ensure we don't go out of bounds
	
	var t = fmod(color_index, 1.0)
	
	# Interpolate between the two closest colors
	var final_color = colors[index1].lerp(colors[index2], t)
	
	# Apply gamma correction
	final_color.r = pow(final_color.r, 1.0 / 2.2)
	final_color.g = pow(final_color.g, 1.0 / 2.2)
	final_color.b = pow(final_color.b, 1.0 / 2.2)
	
	#print("final color maybe lol = ", final_color)
	return final_color

func get_star_id():

	return star_id

func get_star_seed():

	return star_seed

func get_star_temperature():

	return star_temperature

func get_star_brightness():

	return star_brightness
