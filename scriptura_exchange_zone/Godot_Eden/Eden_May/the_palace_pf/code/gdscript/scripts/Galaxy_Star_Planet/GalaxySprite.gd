# GalaxySprite.gd in scene GalaxySprite, here we are generating with help of a shader a Galaxy, with fog and arms
@tool
extends Sprite3D

var shader_material: ShaderMaterial
var pending_parameters: Dictionary = {}
var galaxy_id: int
var shader_parameters: Dictionary = {}
var galaxy_texture: ImageTexture
var galaxy_seed: int
var resolution: float

func _ready():
#	print("GalaxySprite _ready function called")
	
	# Create a placeholder texture
	var image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 1))  # White color
	var texture_galaxy = ImageTexture.create_from_image(image)
	
	# Assign the texture to the Sprite3D
	self.texture = texture_galaxy
	
	# Load the shader directly
	var shader = load("res://Shaders/EnhancedGalaxy.gdshader")
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
	galaxy_id = get_instance_id()
	#print(galaxy_id)
	#add_to_group("galaxies")

func set_parameters(seed_galaxy: int, arm_count: int, arm_width: float, circle_size: float, star_density: float, resolution: float, fog_density: float, fog_arm_width_multiplier: float, galaxy_fog_color: Color, galaxy_temp: int, galaxy_fog_temperature: float, galaxy_fog_swirl: float):
	#print("seed_galaxy",seed_galaxy, "arm_count",arm_count, "arm_width",arm_width, "circle_size",circle_size, "star_density",star_density, "resolution", resolution, "fog_density", fog_density, "fog_arm_width_multiplier", fog_arm_width_multiplier, "galaxy_fog_color", galaxy_fog_color)
	galaxy_seed = seed_galaxy
	self.resolution = resolution
	#print("are we there?")
	shader_parameters = {
		"u_seed": float(seed_galaxy) / 1000000.0,
		"u_arm_count": float(arm_count),
		"u_arm_width": arm_width,
		"u_star_circle_radius": circle_size * 0.95,  # Slightly smaller for stars
		"u_fog_circle_radius": circle_size,
		"u_star_density": star_density,
		"u_star_size": resolution,
		"u_swirl_amount": galaxy_fog_swirl,
		"u_arm_color": Color(0.0, 0.0, 0.0),  # Purple color for arms
		"u_space_color": Color(0.0, 0.0, 0.0),
		"u_star_color": Color(1, 1, 1),
		"u_background_color": Color(0, 0, 0),
		"u_galaxy_color": galaxy_fog_color,  # Lighter purple for fog
		"u_fog_density": float(fog_density),
		"u_noise_scale": 5.0,
		"u_fog_arm_width_multiplier": float(fog_arm_width_multiplier),  # Make fog arms 20% wider than star arms
		"u_galaxy_temp": galaxy_temp,
		"u_galaxy_temperature": galaxy_fog_temperature
	}
	
	#print("this is galaxy temp generated lets see if it is this lol = ", galaxy_temp)
	#print("do we send that shish = ", galaxy_fog_temperature)
	#print(" is this that whole color thingu = ", galaxy_fog_color)
	if shader_material:
		for param in shader_parameters:
			shader_material.set_shader_parameter(param, shader_parameters[param])
	# Create and store the galaxy texture
	var image = Image.create(int(resolution), int(resolution), false, Image.FORMAT_RGBA8)
	galaxy_texture = ImageTexture.create_from_image(image)
	texture = galaxy_texture

func _apply_parameters(params: Dictionary):
	for key in params:
		shader_material.set_shader_parameter(key, params[key])
#	print("Shader parameters applied")

func get_galaxy_id():
	return galaxy_id
	
func get_shader_parameters():
	return shader_parameters
	
func get_galaxy_texture():
	return galaxy_texture
	
func get_galaxy_seed():
	return galaxy_seed

func get_resolution():
	return resolution
