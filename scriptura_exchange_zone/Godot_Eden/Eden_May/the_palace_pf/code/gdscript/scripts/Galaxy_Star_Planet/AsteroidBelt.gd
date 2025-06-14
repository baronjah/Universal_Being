# GalaxySprite.gd in scene GalaxySprite, here we are generating with help of a shader a Galaxy, with fog and arms
#@tool
extends Sprite3D

var shader_material: ShaderMaterial
var pending_parameters: Dictionary = {}
var asteroid_belt_id: int
var shader_parameters: Dictionary = {}
var asteroid_belt_texture: ImageTexture
var asteroid_belt_seed: int
var resolution: float

func _ready():
	# Create a placeholder texture
	var image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 1))  # White color
	var texture_galaxy = ImageTexture.create_from_image(image)
	
	# Assign the texture to the Sprite3D
	self.texture = texture_galaxy
	
	# Load the shader directly
	var shader = load("res://Shaders/CelestialAsteroidBelt.gdshader")
	if shader == null:
		print("Error: Could not load .gdshader file")
		return
	
	# Create a new ShaderMaterial with the loaded shader
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	
	# Assign the material to the Sprite3D
	material_override = shader_material
#	print("Created new ShaderMaterial and assigned shader")

	# Apply any pending parameters
	if not pending_parameters.is_empty():
		_apply_parameters(pending_parameters)
	asteroid_belt_id = get_instance_id()
	#print(galaxy_id)
	#add_to_group("galaxies")

func set_parameters(seed_asteroid_belt: int, asteroid_zone_width: float, asteroid_belt_density: float, asteroid_zone_size: float, asteroid_circle_radius: float, asteroid_belt_noise_scale: float):
	asteroid_belt_seed = seed_asteroid_belt
	self.resolution = resolution
	#print("are we there?")
	shader_parameters = {
		"asteroid_belt_seed": float(asteroid_belt_seed) / 1000000.0,
		"asteroid_circle_radius": float(asteroid_circle_radius),
		"asteroid_zone_width": asteroid_zone_width,
		"asteroid_density": asteroid_belt_density,  # Slightly smaller for stars
		"asteroid_zone_size": asteroid_zone_size,
		"asteroid_belt_noise_scale": asteroid_belt_noise_scale
	}

	if shader_material:
		for param in shader_parameters:
			shader_material.set_shader_parameter(param, shader_parameters[param])
	# Create and store the galaxy texture
	var image = Image.create(int(resolution), int(resolution), false, Image.FORMAT_RGBA8)
	asteroid_belt_texture = ImageTexture.create_from_image(image)
	texture = asteroid_belt_texture

func _apply_parameters(params: Dictionary):
	for key in params:
		shader_material.set_shader_parameter(key, params[key])

func get_asteroid_belt_id():
	return asteroid_belt_id

func get_shader_parameters():
	return shader_parameters
	
func get_asteroid_belt_texture():
	return asteroid_belt_texture
	
func get_asteroid_belt_seed():
	return asteroid_belt_seed

func get_resolution():
	return resolution
