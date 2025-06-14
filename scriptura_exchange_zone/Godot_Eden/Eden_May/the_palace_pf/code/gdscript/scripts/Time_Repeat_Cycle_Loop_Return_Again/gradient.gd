extends Node
class_name JSHGradientSystem
# gradient.gd
# res://code/gdscript/scripts/Time_Repeat_Cycle_Loop_Return_Again/gradient.gd
# JSH_Patch/gradient
####################
#
# JSH Gradient System
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓    ┓•               ┏┓         
#       888  `"Y8888o.   888ooooo888     ┃┏┓┏┓┏┫┏┓┏┓╋┏┓┏┓╋      ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┗┛┗┗┻┗┻┗┫┗┻┗┛┗┗┻┗      ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888              ┛                  ┛       
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# JSH Gradient System
#
####################
#

signal gradient_updated(gradient_id)
signal gradient_created(gradient_id)
signal gradient_removed(gradient_id)

# Gradient types
enum GradientType {
	LINEAR,
	RADIAL,
	CONICAL,
	BILINEAR,
	DIAMOND,
	SPIRAL,
	CUSTOM
}

# Gradient space types
enum GradientSpace {
	LOCAL,       # Local to object
	WORLD,       # World space
	SCREEN,      # Screen space
	UV,          # UV space (for materials)
	DEPTH,       # Depth-based
	TIME         # Time-based (for animations)
}

# Color models
enum ColorModel {
	RGB,
	HSV,
	LAB
}

# Gradient storage
var gradients: Dictionary = {}
var default_resolution: int = 256
var active_gradient_id: String = ""

# Shader cache
var shader_cache: Dictionary = {}

# Default noise for randomization
var noise_generator: FastNoiseLite

func _init_add():
	# Initialize noise generator
	noise_generator = FastNoiseLite.new()
	noise_generator.seed = randi()
	
	# Create a default gradient
	var default_gradient = create_gradient("default", GradientType.LINEAR)
	active_gradient_id = "default"

func _ready_add():
	pass

# Gradient Creation Methods
func create_gradient(id: String, type: int = GradientType.LINEAR) -> String:
	# Generate unique ID if not specified or already exists
	if id.is_empty() or gradients.has(id):
		id = "gradient_" + str(Time.get_ticks_msec()) + "_" + str(randi() % 1000)
	
	# Create basic gradient
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0, 0, 0, 1))
	gradient.add_point(1.0, Color(1, 1, 1, 1))
	
	# Store in dictionary with metadata
	gradients[id] = {
		"gradient": gradient,
		"type": type,
		"space": GradientSpace.LOCAL,
		"color_model": ColorModel.RGB,
		"resolution": default_resolution,
		"texture": null,
		"shader": null,
		"params": {
			"center": Vector2(0.5, 0.5),
			"angle": 0.0,
			"scale": Vector2(1.0, 1.0),
			"offset": Vector2(0.0, 0.0),
			"repeat": false,
			"mirror": false
		}
	}
	
	emit_signal("gradient_created", id)
	return id

func remove_gradient(id: String) -> bool:
	if not gradients.has(id):
		return false
	
	# Clean up resources
	if gradients[id].texture != null:
		gradients[id].texture.queue_free()
	
	gradients.erase(id)
	emit_signal("gradient_removed", id)
	
	# If we removed the active gradient, set a new one
	if active_gradient_id == id and not gradients.is_empty():
		active_gradient_id = gradients.keys()[0]
	
	return true

func set_active_gradient(id: String) -> bool:
	if not gradients.has(id):
		return false
	
	active_gradient_id = id
	return true

# Gradient Modification Methods
func set_gradient_colors(id: String, colors: Array[Color], positions: Array[float]) -> bool:
	if not gradients.has(id) or colors.size() != positions.size():
		return false
	
	var grad_data = gradients[id]
	var gradient: Gradient = grad_data.gradient
	
	# Clear existing points
	for i in range(gradient.get_point_count()):
		gradient.remove_point(0)
	
	# Add new points
	for i in range(colors.size()):
		gradient.add_point(positions[i], colors[i])
	
	_update_gradient_resources(id)
	emit_signal("gradient_updated", id)
	return true

func set_gradient_type(id: String, type: int) -> bool:
	if not gradients.has(id):
		return false
	
	gradients[id].type = type
	_update_gradient_resources(id)
	emit_signal("gradient_updated", id)
	return true

func set_gradient_space(id: String, space: int) -> bool:
	if not gradients.has(id):
		return false
	
	gradients[id].space = space
	_update_gradient_resources(id)
	emit_signal("gradient_updated", id)
	return true

func set_gradient_color_model(id: String, color_model: int) -> bool:
	if not gradients.has(id):
		return false
	
	gradients[id].color_model = color_model
	_update_gradient_resources(id)
	emit_signal("gradient_updated", id)
	return true

func set_gradient_params(id: String, params: Dictionary) -> bool:
	if not gradients.has(id):
		return false
	
	# Update only specified parameters
	for key in params:
		if gradients[id].params.has(key):
			gradients[id].params[key] = params[key]
	
	_update_gradient_resources(id)
	emit_signal("gradient_updated", id)
	return true

func set_gradient_resolution(id: String, resolution: int) -> bool:
	if not gradients.has(id) or resolution <= 0:
		return false
	
	gradients[id].resolution = resolution
	_update_gradient_resources(id)
	emit_signal("gradient_updated", id)
	return true

# Gradient Sampling and Access Methods
func sample_gradient(id: String, position: float) -> Color:
	if not gradients.has(id):
		return Color(1, 0, 1, 1)  # Magenta for errors
	
	var gradient: Gradient = gradients[id].gradient
	return gradient.sample(position)

func sample_gradient_texture(id: String, position: Vector2) -> Color:
	if not gradients.has(id) or gradients[id].texture == null:
		return Color(1, 0, 1, 1)  # Magenta for errors
	
	var texture: GradientTexture2D = gradients[id].texture
	
	# Ensure position is in 0-1 range
	position.x = fmod(position.x, 1.0) if position.x >= 0 else 1.0 + fmod(position.x, 1.0)
	position.y = fmod(position.y, 1.0) if position.y >= 0 else 1.0 + fmod(position.y, 1.0)
	
	# Sample texture
	return texture.get_image().get_pixel(
		int(position.x * texture.width),
		int(position.y * texture.height)
	)

func get_gradient(id: String = "") -> Gradient:
	if id.is_empty():
		id = active_gradient_id
	
	if not gradients.has(id):
		return null
	
	return gradients[id].gradient

func get_gradient_texture(id: String = "") -> Texture2D:
	if id.is_empty():
		id = active_gradient_id
	
	if not gradients.has(id):
		return null
	
	if gradients[id].texture == null:
		_generate_gradient_texture(id)
	
	return gradients[id].texture

func get_gradient_shader(id: String = "") -> Shader:
	if id.is_empty():
		id = active_gradient_id
	
	if not gradients.has(id):
		return null
	
	if gradients[id].shader == null:
		_generate_gradient_shader(id)
	
	return gradients[id].shader

# Gradient Generation Methods
func generate_random_gradient(id: String = "", num_points: int = 5, color_theme: String = "random"):
	# Create new gradient if id not provided
	print(" generate random gradient id ", id)
	#if id.is_empty() or not gradients.has(id):

func _generate_gradient_texture(id):
	print(" something id ", id)
	
	
func _generate_gradient_shader(id):
	print(" something id ", id)

func _update_gradient_resources(id):
	print(" something id ", id)
