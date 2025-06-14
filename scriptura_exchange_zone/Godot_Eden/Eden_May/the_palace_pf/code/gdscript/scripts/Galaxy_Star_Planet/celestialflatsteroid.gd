# CelestialFlatsteroid.gd
@tool
extends Sprite3D

var shader_material: ShaderMaterial
var asteroid_id: int
var star_seed: int
var asteroid_seed: int
var material
var asteroid_mass
var asteroid_radius
var asteroid_data: Dictionary

# the ready function, runs once and is done
func _ready():
	setup_asteroid()

func setup_asteroid():
	var image = Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 1))
	var asteroid_texture = ImageTexture.create_from_image(image)
	self.texture = asteroid_texture

	var shader = load("res://Shaders/CelestialFlatsteroid.gdshader")
	if shader == null:
		print("Error: Could not load CelestialFlatsteroid.gdshader file")
		return

	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	material_override = shader_material
	asteroid_id = get_instance_id()

func set_parameters(seed_asteroid: int, radius_asteroid: float, mass_asteroid: float, data: Dictionary):
	print("we tried in flatsteroid!")
	print(seed_asteroid, radius_asteroid, mass_asteroid, data)
	asteroid_seed = seed_asteroid
	asteroid_radius = radius_asteroid
	asteroid_data = data
#	shader_material.set_shader_parameter("asteroid_seed", float(seed_asteroid))
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
