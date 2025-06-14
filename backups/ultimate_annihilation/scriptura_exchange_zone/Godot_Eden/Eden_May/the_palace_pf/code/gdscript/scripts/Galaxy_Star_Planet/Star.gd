#Star.gd in Star scene, here we are generating a sprite for stars in GalaxyCloseUp scene, they apeear where just white dots were on a single sprite with some help of compute shader

@tool
extends Sprite3D

var shader_material: ShaderMaterial
var pending_parameters: Dictionary = {}
var star_id: int
var shader_parameters: Dictionary = {}
var star_texture: ImageTexture
var star_seed: int
var star_temperature
var star_brightness

func _ready():
	#print("Star _ready function called")
	add_to_group("stars")
	setup_star()

func setup_star():
	# Create a placeholder texture
	var image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 1))  # White color
	star_texture = ImageTexture.create_from_image(image)

	# Assign the texture to the Sprite3D
	self.texture = star_texture

	# Load the shader directly
	var shader = load("res://Shaders/Star.gdshader")
	if shader == null:
		print("Error: Could not load Star.gdshader file")
		return

	# Create a new ShaderMaterial with the loaded shader
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader

	# Assign the material to the Sprite3D
	material_override = shader_material
	#print("Created new ShaderMaterial and assigned shader")

	# Apply any pending parameters
	if not pending_parameters.is_empty():
		apply_parameters(pending_parameters)

	star_id = get_instance_id()
	#print("Star ID: ", star_id)

func set_parameters(seed_star: int, temperature: float, size: float):
	#print("set parameters for star, we are here now, so work now!")
	#print("seed_star: ", seed_star, ", temperature: ", temperature, ", size: ", size)
	star_seed = seed_star
	
	if shader_material == null:
		#print("Error: shader_material is null. Running setup_star()")
		setup_star()
	
	if shader_material == null:
		print("Error: shader_material is still null after setup_star()")
		return
	
	#print("so we are here again, after the shader thingy and setupstar? so lets se now")
	var star_color = temperature_to_color(temperature)
	#print("temperature = ",temperature, "so we got some star_color, with function from temperature to color = ",star_color)
	#print("we also have size = " , size)
	#print(temperature)
	star_temperature = temperature
	star_brightness = size
	shader_parameters = {
		"color": star_color,
		"brightness": size
	}

	for param in shader_parameters:
		shader_material.set_shader_parameter(param, shader_parameters[param])
	
	# Adjust the scale based on the size parameter
	self.scale = Vector3.ONE * size
	pixel_size = size / 100

func apply_parameters(params: Dictionary):
	for key in params:
		shader_material.set_shader_parameter(key, params[key])
	#print("Shader parameters applied")

func get_star_id():
	return star_id

func get_shader_parameters():
	return shader_parameters

func get_star_texture():
	return star_texture

func get_star_seed():
	return star_seed
	
func get_star_temperature():
	return star_temperature

func get_star_brightness():
	return star_brightness

func temperature_to_color(temperature: float) -> Color:
	#print("galaxy temp in function = ", temperature)
	
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

func remap(value, old_min, old_max, new_min, new_max):
	return (value - old_min) / (old_max - old_min) * (new_max - new_min) + new_min
