extends Node

# Material references
var physical_material: Material
var digital_material: Material
var astral_material: Material
var transition_material: ShaderMaterial

# Shader references
var transition_shader: Shader

# Colors for different realities
const PHYSICAL_COLOR = Color(0.1, 0.1, 0.2)  # Dark blue-ish
const DIGITAL_COLOR = Color(0.1, 0.3, 0.1)   # Matrix green
const ASTRAL_COLOR = Color(0.3, 0.1, 0.3)    # Purple-ish

# Environment settings for different realities
var physical_environment: Environment
var digital_environment: Environment
var astral_environment: Environment

# Called when the node enters the scene tree
func _ready():
	# Load the transition shader
	transition_shader = load("res://reality_transition_shader.gdshader")
	
	# Create base materials for each reality
	_create_physical_material()
	_create_digital_material()
	_create_astral_material()
	_create_transition_material()
	
	# Create environment settings
	_create_environments()

# Create physical reality material
func _create_physical_material():
	physical_material = StandardMaterial3D.new()
	physical_material.albedo_color = PHYSICAL_COLOR
	physical_material.roughness = 0.7
	physical_material.metallic = 0.1
	physical_material.emission_enabled = true
	physical_material.emission = PHYSICAL_COLOR * 0.5
	physical_material.emission_energy_multiplier = 0.3

# Create digital reality material
func _create_digital_material():
	digital_material = StandardMaterial3D.new()
	digital_material.albedo_color = DIGITAL_COLOR
	digital_material.roughness = 0.4
	digital_material.metallic = 0.3
	digital_material.emission_enabled = true
	digital_material.emission = DIGITAL_COLOR * 0.7
	digital_material.emission_energy_multiplier = 0.5
	
	# Add a grid pattern using triplanar mapping
	if ResourceLoader.exists("res://grid_pattern.png"):
		var texture = load("res://grid_pattern.png")
		digital_material.albedo_texture = texture
		digital_material.uv1_triplanar = true

# Create astral reality material
func _create_astral_material():
	astral_material = StandardMaterial3D.new()
	astral_material.albedo_color = ASTRAL_COLOR
	astral_material.roughness = 0.2
	astral_material.metallic = 0.6
	astral_material.emission_enabled = true
	astral_material.emission = ASTRAL_COLOR
	astral_material.emission_energy_multiplier = 0.8

# Create transition material with shader
func _create_transition_material():
	transition_material = ShaderMaterial.new()
	transition_material.shader = transition_shader
	
	# Set default transition parameters
	transition_material.set_shader_parameter("transition_progress", 0.0)
	transition_material.set_shader_parameter("from_color", PHYSICAL_COLOR)
	transition_material.set_shader_parameter("to_color", DIGITAL_COLOR)
	transition_material.set_shader_parameter("edge_width", 0.1)
	transition_material.set_shader_parameter("ripple_speed", 5.0)
	transition_material.set_shader_parameter("ripple_intensity", 0.3)
	transition_material.set_shader_parameter("glow_intensity", 1.0)
	transition_material.set_shader_parameter("distortion_amount", 0.2)
	transition_material.set_shader_parameter("wave_speed", 2.0)

# Create environment settings for each reality
func _create_environments():
	# Physical reality - neutral blue-ish
	physical_environment = Environment.new()
	physical_environment.background_mode = Environment.BG_COLOR
	physical_environment.background_color = Color(0.05, 0.05, 0.1)
	physical_environment.ambient_light_color = Color(0.3, 0.3, 0.4)
	physical_environment.fog_enabled = true
	physical_environment.fog_density = 0.01
	physical_environment.fog_light_color = Color(0.1, 0.1, 0.2)
	physical_environment.glow_enabled = true
	physical_environment.glow_intensity = 0.3
	
	# Digital reality - matrix green
	digital_environment = Environment.new()
	digital_environment.background_mode = Environment.BG_COLOR
	digital_environment.background_color = Color(0.02, 0.1, 0.02)
	digital_environment.ambient_light_color = Color(0.2, 0.4, 0.2)
	digital_environment.fog_enabled = true
	digital_environment.fog_density = 0.02
	digital_environment.fog_light_color = Color(0.05, 0.15, 0.05)
	digital_environment.glow_enabled = true
	digital_environment.glow_intensity = 0.5
	
	# Astral reality - ethereal purple
	astral_environment = Environment.new()
	astral_environment.background_mode = Environment.BG_COLOR
	astral_environment.background_color = Color(0.1, 0.05, 0.15)
	astral_environment.ambient_light_color = Color(0.4, 0.2, 0.5)
	astral_environment.fog_enabled = true
	astral_environment.fog_density = 0.015
	astral_environment.fog_light_color = Color(0.2, 0.1, 0.3)
	astral_environment.glow_enabled = true
	astral_environment.glow_intensity = 0.7
	astral_environment.glow_bloom = 0.2

# Get material for a specific reality
func get_reality_material(reality_name: String) -> Material:
	match reality_name.to_upper():
		"PHYSICAL":
			return physical_material
		"DIGITAL":
			return digital_material
		"ASTRAL":
			return astral_material
		_:
			return physical_material

# Get environment for a specific reality
func get_reality_environment(reality_name: String) -> Environment:
	match reality_name.to_upper():
		"PHYSICAL":
			return physical_environment
		"DIGITAL":
			return digital_environment
		"ASTRAL":
			return astral_environment
		_:
			return physical_environment

# Configure transition between realities
func configure_transition(from_reality: String, to_reality: String, progress: float):
	var from_color = PHYSICAL_COLOR
	var to_color = DIGITAL_COLOR
	
	# Set source color
	match from_reality.to_upper():
		"PHYSICAL":
			from_color = PHYSICAL_COLOR
		"DIGITAL":
			from_color = DIGITAL_COLOR
		"ASTRAL":
			from_color = ASTRAL_COLOR
	
	# Set target color
	match to_reality.to_upper():
		"PHYSICAL":
			to_color = PHYSICAL_COLOR
		"DIGITAL":
			to_color = DIGITAL_COLOR
		"ASTRAL":
			to_color = ASTRAL_COLOR
	
	# Update transition material parameters
	transition_material.set_shader_parameter("from_color", from_color)
	transition_material.set_shader_parameter("to_color", to_color)
	transition_material.set_shader_parameter("transition_progress", progress)
	
	return transition_material