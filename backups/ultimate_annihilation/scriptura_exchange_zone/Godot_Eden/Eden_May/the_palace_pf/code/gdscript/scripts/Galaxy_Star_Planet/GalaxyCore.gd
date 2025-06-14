#GalaxyCore.gd in scene GalaxyCore, here we are generating a core for galaxy, right now it is the same color as galaxy fog, size was done in some way in Galaxies scene if i remember correctly
@tool
extends Sprite3D

var shader_material: ShaderMaterial
var pending_parameters: Dictionary = {}

func _ready():
	#print("GalaxyCore _ready function called")
	
	# Create a placeholder texture
	var image = Image.create(512, 512, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1, 1))  # White color
	var texture_core = ImageTexture.create_from_image(image)
	
	# Assign the texture to the Sprite3D
	self.texture = texture_core
	
	# Load the shader directly
	var shader = load("res://Shaders/coregalaxy.gdshader")
	if shader == null:
		print("Error: Could not load GalaxyCore.gdshader file")
		return
	
	# Create a new ShaderMaterial with the loaded shader
	shader_material = ShaderMaterial.new()
	shader_material.shader = shader
	
	# Assign the material to the Sprite3D
	material_override = shader_material
	#print("Created new ShaderMaterial and assigned shader for GalaxyCore")
	
	# Apply any pending parameters
	if not pending_parameters.is_empty():
		apply_parameters(pending_parameters)

func set_parameters(galaxy_fog_color: Color, resolution: float):
	var core_size = 1  # Adjust the 0.2 factor as needed
	var params = {
		"u_galaxy_color": galaxy_fog_color,
		"u_core_size": core_size,
		"u_star_size": resolution
	}
	
	if shader_material:
		apply_parameters(params)
	else:
		pending_parameters = params

func apply_parameters(params: Dictionary):
	for key in params:
		shader_material.set_shader_parameter(key, params[key])
#	print("GalaxyCore shader parameters applied")
