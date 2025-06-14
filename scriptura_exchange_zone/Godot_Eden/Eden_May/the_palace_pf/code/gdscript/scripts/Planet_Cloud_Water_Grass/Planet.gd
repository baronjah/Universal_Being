# Planet Scene, Planet.gd with a shader, "res://Scenes/Planet.tscn", "res://Shaders/Planet.gdshader"

extends Sprite3D

var shader_material: ShaderMaterial
var pending_parameters: Dictionary = {}
var planet_id: int
var shader_parameters: Dictionary = {}
var planet_texture: ImageTexture
var planet_seed: int
var planet_type: int
var planet_radius: float
var planet_mass: float

func _ready():
	add_to_group("planets")
	setup_planet()

func setup_planet():
	# Create a placeholder texture
	var image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 1))  # White color
	planet_texture = ImageTexture.create_from_image(image)
	
	# Assign the texture to the Sprite3D
	self.texture = planet_texture
	
	# Load the shader directly
	var shader = load("res://Shaders/CelestialPlanet")
	if shader == null:
		print("Error: Could not load Planet.gdshader file")
		return
	
	# Create a new ShaderMaterial with the loaded shader
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	
	# Assign the material to the Sprite3D
	material_override = shader_material
	
	# Apply any pending parameters
	if not pending_parameters.is_empty():
		apply_parameters(pending_parameters)
	
	planet_id = get_instance_id()

func set_planet_data(data: Dictionary):
	planet_seed = data.seed
	planet_type = data.type
	planet_radius = data.radius
	planet_mass = data.mass
	
	if shader_material == null:
		setup_planet()
	
	if shader_material == null:
		print("Error: shader_material is still null after setup_planet()")
		return
	
	var planet_color = type_to_color(planet_type)
	
	shader_parameters = {
		"color": planet_color,
		"radius": planet_radius,
		"type": float(planet_type)  # Convert to float for shader uniform
	}
	
	for param in shader_parameters:
		shader_material.set_shader_parameter(param, shader_parameters[param])
	
	# Adjust the scale based on the radius
	self.scale = Vector3.ONE * (planet_radius * 0.1)  # Adjust scaling factor as needed

func apply_parameters(params: Dictionary):
	for key in params:
		shader_material.set_shader_parameter(key, params[key])

func get_planet_id():
	return planet_id

func get_shader_parameters():
	return shader_parameters

func get_planet_texture():
	return planet_texture

func get_planet_seed():
	return planet_seed

func type_to_color(type: int) -> Color:
	match type:
		0: return Color(0.6, 0.4, 0.2, 1.0)  # Rocky (Brown)
		1: return Color(0.8, 0.6, 0.2, 1.0)  # Gas Giant (Orange)
		2: return Color(0.6, 0.8, 1.0, 1.0)  # Ice Giant (Light Blue)
		3: return Color(0.2, 0.6, 0.3, 1.0)  # Super-Earth (Green)
	return Color(1, 1, 1, 1)  # Default white
