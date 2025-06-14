extends Node
class_name JSHFogSystem
# fog.gd
# res://scenes/fog.gd
# JSH_World/fog
# res://scenes/fog.gd
# res://code/gdscript/scripts/Thing_Place_Space/fog.gd
####################
#
# JSH Fog System
#
#      oooo  .oooooo..o ooooo   ooooo 
#      `888 d8P'    `Y8 `888'   `888' 
#       888 Y88bo.       888     888     ┏┓      ┏┓         
#       888  `"Y8888o.   888ooooo888     ┣┫┏┓┏┓  ┗┓┓┏┏╋┏┓┏┳┓
#       888      `"Y88b  888     888     ┛┗┗ ┛┗  ┗┛┗┫┛┗┗ ┛┗┗
#       888 oo     .d8P  888     888             ┛       
#   .o. 88P 8""88888P'  o888o   o888o 
#   `Y888P                            
#
# JSH Fog System
#
####################

signal fog_changed(fog_params)
signal volumetric_fog_updated(voxel_data)

# Fog types
enum FogType {
	UNIFORM,           # Uniform fog throughout the scene
	LAYERED,           # Layered fog with height gradients
	VOLUMETRIC,        # Full volumetric fog with 3D textures
	ATMOSPHERIC,       # Atmospheric scattering simulation
	GRADIENT,          # Custom gradient-based fog
	NOISE_BASED        # Noise-generated fog patterns
}

# Fog parameters
var current_fog_type: int = FogType.UNIFORM
var fog_enabled: bool = true
var fog_color: Color = Color(0.5, 0.5, 0.5, 0.5)
var fog_density: float = 0.1
var fog_start: float = 10.0
var fog_end: float = 100.0
var fog_height: float = 10.0
var fog_curve: Curve
var fog_noise_texture: NoiseTexture3D
var fog_texture: Texture3D
var fog_voxel_data: Array
var fog_environment: Environment
var fog_update_interval: float = 0.5
var time_since_update: float = 0.0

# Gradient parameters
var gradient_colors: Array[Color] = [
	Color(0.0, 0.0, 0.0, 0.0),  # Transparent at bottom
	Color(0.5, 0.5, 0.5, 0.5),  # Semi-transparent in middle
	Color(1.0, 1.0, 1.0, 1.0)   # Opaque at top
]

var gradient_positions: Array[float] = [0.0, 0.5, 1.0]
var custom_gradient: Gradient

# Shadow interaction
var shadow_density_multiplier: float = 1.2
var light_diffusion: float = 0.8

# Shader materials
var fog_shader_material: ShaderMaterial
var fog_shader_params: Dictionary = {}

func _init_add():
	# Initialize fog curve and gradient
	fog_curve = Curve.new()
	fog_curve.add_point(Vector2(0, 0))
	fog_curve.add_point(Vector2(0.5, 0.5))
	fog_curve.add_point(Vector2(1, 1))
	
	custom_gradient = Gradient.new()
	_update_gradient()
	
	# Create noise texture for volumetric fog
	create_fog_noise_texture()

func _ready_add():
	# Initialize shader material
	initialize_fog_shader()

func _process_add(delta):
	if fog_enabled and current_fog_type == FogType.VOLUMETRIC:
		time_since_update += delta
		if time_since_update >= fog_update_interval:
			update_volumetric_fog()
			time_since_update = 0.0

# Setup methods
func initialize_fog_shader():
	fog_shader_material = ShaderMaterial.new()
	var shader_code = """
	shader_type spatial;
	
	uniform vec4 fog_color : source_color = vec4(0.5, 0.5, 0.5, 0.5);
	uniform float fog_density = 0.1;
	uniform float fog_start = 10.0;
	uniform float fog_end = 100.0;
	uniform float fog_height = 10.0;
	uniform sampler3D fog_texture;
	uniform float time;
	uniform int fog_type;
	
	void fragment() {
		float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
		vec3 world_pos = CAMERA_MATRIX * vec4(VERTEX, 1.0);
		float fog_factor = 0.0;
		
		if (fog_type == 0) { // UNIFORM
			float dist = length(VERTEX);
			fog_factor = smoothstep(fog_start, fog_end, dist) * fog_density;
		}
		else if (fog_type == 1) { // LAYERED
			float height_factor = smoothstep(0.0, fog_height, world_pos.y);
			float dist = length(VERTEX);
			fog_factor = (1.0 - height_factor) * smoothstep(fog_start, fog_end, dist) * fog_density;
		}
		else if (fog_type == 2) { // VOLUMETRIC
			vec3 tex_coord = (world_pos / 100.0) + vec3(time * 0.01, time * 0.02, time * 0.005);
			vec4 noise_value = texture(fog_texture, tex_coord);
			float dist = length(VERTEX);
			fog_factor = noise_value.r * smoothstep(fog_start, fog_end, dist) * fog_density;
		}
		
		ALBEDO = mix(ALBEDO, fog_color.rgb, fog_factor * fog_color.a);
	}
	"""
	
	fog_shader_material.shader = Shader.new()
	fog_shader_material.shader.code = shader_code
	
	# Set initial shader parameters
	fog_shader_material.set_shader_parameter("fog_color", fog_color)
	fog_shader_material.set_shader_parameter("fog_density", fog_density)
	fog_shader_material.set_shader_parameter("fog_start", fog_start)
	fog_shader_material.set_shader_parameter("fog_end", fog_end)
	fog_shader_material.set_shader_parameter("fog_height", fog_height)
	fog_shader_material.set_shader_parameter("time", 0.0)
	fog_shader_material.set_shader_parameter("fog_type", current_fog_type)

func create_fog_noise_texture():
	# Create 3D noise texture for volumetric fog
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()
	noise.frequency = 0.01
	
	fog_noise_texture = NoiseTexture3D.new()
	fog_noise_texture.seamless = true
	fog_noise_texture.noise = noise
	fog_noise_texture.width = 64
	fog_noise_texture.height = 64
	fog_noise_texture.depth = 64
	
	fog_texture = fog_noise_texture

# Fog type management
func set_fog_type(type: int):
	current_fog_type = type
	
	if fog_shader_material:
		fog_shader_material.set_shader_parameter("fog_type", current_fog_type)
	
	match current_fog_type:
		FogType.UNIFORM:
			configure_uniform_fog()
		FogType.LAYERED:
			configure_layered_fog()
		FogType.VOLUMETRIC:
			configure_volumetric_fog()
		FogType.ATMOSPHERIC:
			configure_atmospheric_fog()
		FogType.GRADIENT:
			configure_gradient_fog()
		FogType.NOISE_BASED:
			configure_noise_based_fog()
	
	emit_signal("fog_changed", get_fog_params())

# Fog type configuration methods
func configure_uniform_fog():
	# Uniform fog parameters
	fog_density = 0.1
	fog_start = 10.0
	fog_end = 100.0
	fog_color = Color(0.5, 0.5, 0.5, 0.5)
	
	if fog_shader_material:
		fog_shader_material.set_shader_parameter("fog_density", fog_density)
		fog_shader_material.set_shader_parameter("fog_start", fog_start)
		fog_shader_material.set_shader_parameter("fog_end", fog_end)
		fog_shader_material.set_shader_parameter("fog_color", fog_color)

func configure_layered_fog():
	# Layered fog parameters
	fog_density = 0.15
	fog_start = 5.0
	fog_end = 80.0
	fog_height = 20.0
	fog_color = Color(0.6, 0.6, 0.6, 0.6)
	
	if fog_shader_material:
		fog_shader_material.set_shader_parameter("fog_density", fog_density)
		fog_shader_material.set_shader_parameter("fog_start", fog_start)
		fog_shader_material.set_shader_parameter("fog_end", fog_end)
		fog_shader_material.set_shader_parameter("fog_height", fog_height)
		fog_shader_material.set_shader_parameter("fog_color", fog_color)

func configure_volumetric_fog():
	# Volumetric fog parameters
	fog_density = 0.2
	fog_start = 0.0
	fog_end = 60.0
	fog_color = Color(0.7, 0.7, 0.7, 0.7)
	
	# Update or regenerate the noise texture
	create_fog_noise_texture()
	
	if fog_shader_material:
		fog_shader_material.set_shader_parameter("fog_density", fog_density)
		fog_shader_material.set_shader_parameter("fog_start", fog_start)
		fog_shader_material.set_shader_parameter("fog_end", fog_end)
		fog_shader_material.set_shader_parameter("fog_color", fog_color)
		fog_shader_material.set_shader_parameter("fog_texture", fog_texture)

func configure_atmospheric_fog():
	# TODO: Implement atmospheric scattering
	pass

func configure_gradient_fog():
	# Update gradient
	_update_gradient()
	
	# TODO: Implement gradient-based fog
	pass

func configure_noise_based_fog():
	# TODO: Implement noise-based fog
	pass

# Gradient management
func _update_gradient():
	custom_gradient.colors.clear()
	custom_gradient.offsets.clear()
	
	for i in range(gradient_colors.size()):
		custom_gradient.add_point(gradient_positions[i], gradient_colors[i])

func set_gradient_colors(colors: Array[Color], positions: Array[float]):
	if colors.size() != positions.size():
		push_error("Gradient colors and positions must have the same length")
		return
	
	gradient_colors = colors
	gradient_positions = positions
	_update_gradient()
	
	if current_fog_type == FogType.GRADIENT:
		emit_signal("fog_changed", get_fog_params())

# Volumetric fog updates
func update_volumetric_fog():
	if current_fog_type != FogType.VOLUMETRIC:
		return
	
	# Update time parameter for animation
	if fog_shader_material:
		fog_shader_material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
	
	emit_signal("volumetric_fog_updated", fog_voxel_data)

# Parameters and state management
func get_fog_params() -> Dictionary:
	return {
		"type": current_fog_type,
		"enabled": fog_enabled,
		"color": fog_color,
		"density": fog_density,
		"start": fog_start,
		"end": fog_end,
		"height": fog_height,
		"gradient": custom_gradient if current_fog_type == FogType.GRADIENT else null,
	}

func set_fog_params(params: Dictionary):
	if params.has("type"):
		current_fog_type = params.type
	
	if params.has("enabled"):
		fog_enabled = params.enabled
	
	if params.has("color"):
		fog_color = params.color
		if fog_shader_material:
			fog_shader_material.set_shader_parameter("fog_color", fog_color)
	
	if params.has("density"):
		fog_density = params.density
		if fog_shader_material:
			fog_shader_material.set_shader_parameter("fog_density", fog_density)
	
	if params.has("start"):
		fog_start = params.start
		if fog_shader_material:
			fog_shader_material.set_shader_parameter("fog_start", fog_start)
	
	if params.has("end"):
		fog_end = params.end
		if fog_shader_material:
			fog_shader_material.set_shader_parameter("fog_end", fog_end)
	
	if params.has("height"):
		fog_height = params.height
		if fog_shader_material:
			fog_shader_material.set_shader_parameter("fog_height", fog_height)
	
	emit_signal("fog_changed", get_fog_params())

# Utility methods
func set_environment(env: Environment):
	fog_environment = env
	
	# Set up environment fog parameters
	if fog_environment:
		# Configure environment fog settings based on current_fog_type
		match current_fog_type:
			FogType.UNIFORM:
				fog_environment.volumetric_fog_enabled = false
				fog_environment.fog_enabled = true
				fog_environment.fog_color = fog_color
				fog_environment.fog_density = fog_density
			FogType.LAYERED, FogType.GRADIENT:
				fog_environment.volumetric_fog_enabled = false
				fog_environment.fog_enabled = true
				fog_environment.fog_height_enabled = true
				fog_environment.fog_height_min = 0.0
				fog_environment.fog_height_max = fog_height
				fog_environment.fog_color = fog_color
				fog_environment.fog_density = fog_density
			FogType.VOLUMETRIC, FogType.ATMOSPHERIC, FogType.NOISE_BASED:
				fog_environment.fog_enabled = false
				fog_environment.volumetric_fog_enabled = true
				fog_environment.volumetric_fog_density = fog_density
				fog_environment.volumetric_fog_albedo = fog_color

# Apply the fog to a specific object
func apply_fog_to_object(object: Node3D):
	if not fog_enabled or not fog_shader_material:
		return
	
	# Find MeshInstance3D children and apply fog material
	var mesh_instances = []
	_find_mesh_instances(object, mesh_instances)
	
	for mesh_instance in mesh_instances:
		if mesh_instance is MeshInstance3D:
			# You might want to store original materials to restore them later
			mesh_instance.material_overlay = fog_shader_material

# Helper to find all MeshInstance3D nodes
func _find_mesh_instances(node: Node, result: Array):
	if node is MeshInstance3D:
		result.append(node)
	
	for child in node.get_children():
		_find_mesh_instances(child, result)

# Console command handlers (to be used with your console system)
func handle_console_command(args: Array) -> String:
	if args.size() == 0:
		return "Usage: fog <command> [params]"
	
	var command = args[0]
	match command:
		"enable":
			fog_enabled = true
			return "Fog system enabled"
		"disable":
			fog_enabled = false
			return "Fog system disabled"
		"type":
			if args.size() < 2:
				return "Usage: fog type <type_name>"
			
			var type_name = args[1].to_lower()
			var type_mapping = {
				"uniform": FogType.UNIFORM,
				"layered": FogType.LAYERED,
				"volumetric": FogType.VOLUMETRIC,
				"atmospheric": FogType.ATMOSPHERIC,
				"gradient": FogType.GRADIENT,
				"noise": FogType.NOISE_BASED
			}
			
			if type_mapping.has(type_name):
				set_fog_type(type_mapping[type_name])
				return "Fog type set to " + type_name
			else:
				return "Unknown fog type: " + type_name
		"density":
			if args.size() < 2:
				return "Usage: fog density <value>"
			
			var density = float(args[1])
			set_fog_params({"density": density})
			return "Fog density set to " + str(density)
		"color":
			if args.size() < 4:
				return "Usage: fog color <r> <g> <b> [a]"
			
			var r = float(args[1])
			var g = float(args[2])
			var b = float(args[3])
			var a = 1.0
			if args.size() >= 5:
				a = float(args[4])
			
			set_fog_params({"color": Color(r, g, b, a)})
			return "Fog color set to RGBA(" + str(r) + "," + str(g) + "," + str(b) + "," + str(a) + ")"
		"info":
			var params = get_fog_params()
			var type_names = ["UNIFORM", "LAYERED", "VOLUMETRIC", "ATMOSPHERIC", "GRADIENT", "NOISE_BASED"]
			var info = "Fog System Info:\n"
			info += "- Type: " + type_names[params.type] + "\n"
			info += "- Enabled: " + str(params.enabled) + "\n"
			info += "- Color: " + str(params.color) + "\n"
			info += "- Density: " + str(params.density) + "\n"
			info += "- Range: " + str(params.start) + " to " + str(params.end) + "\n"
			info += "- Height: " + str(params.height)
			return info
		_:
			return "Unknown fog command: " + command
