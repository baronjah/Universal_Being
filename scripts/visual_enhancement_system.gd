# VisualEnhancementSystem.gd - Make the game look FANTASTIC!
extends Node3D
class_name VisualEnhancementSystem

# Visual enhancement settings
@export var enable_bloom: bool = true
@export var enable_glow: bool = true
@export var enable_volumetric_fog: bool = false  # Performance heavy
@export var enable_ssao: bool = false  # Performance heavy
@export var enable_auto_exposure: bool = true

# Color grading
@export var consciousness_color_grading: bool = true
@export_range(0.5, 2.0) var saturation_boost: float = 1.3
@export_range(0.5, 2.0) var contrast_boost: float = 1.1

# Visual presets
enum VisualPreset {
	PERFORMANCE,
	BALANCED,
	BEAUTIFUL,
	CINEMATIC
}

@export var current_preset: VisualPreset = VisualPreset.BALANCED

var environment: Environment
var camera: Camera3D

func _ready():
	print("🎨 Visual Enhancement System Initializing...")
	
	# Create or find environment
	setup_environment()
	
	# Apply visual preset
	apply_visual_preset(current_preset)
	
	# Find camera
	camera = get_viewport().get_camera_3d()
	
	print("✨ Visual enhancements active!")

func setup_environment():
	"""Set up the environment for visual enhancements"""
	# Check if environment exists
	var existing_env = get_node_or_null("/root/Main/WorldEnvironment")
	
	if existing_env and existing_env is WorldEnvironment:
		environment = existing_env.environment
		if not environment:
			environment = Environment.new()
			existing_env.environment = environment
	else:
		# Create new WorldEnvironment
		var world_env = WorldEnvironment.new()
		environment = Environment.new()
		world_env.environment = environment
		world_env.name = "EnhancedWorldEnvironment"
		get_tree().root.add_child(world_env)

func apply_visual_preset(preset: VisualPreset):
	"""Apply a visual preset for different performance/quality levels"""
	current_preset = preset
	
	match preset:
		VisualPreset.PERFORMANCE:
			apply_performance_preset()
		VisualPreset.BALANCED:
			apply_balanced_preset()
		VisualPreset.BEAUTIFUL:
			apply_beautiful_preset()
		VisualPreset.CINEMATIC:
			apply_cinematic_preset()
	
	# Always apply consciousness-based enhancements
	if consciousness_color_grading:
		apply_consciousness_grading()
	
	print("🎨 Applied %s visual preset" % VisualPreset.keys()[preset])

func apply_performance_preset():
	"""Fastest performance, still looks good"""
	if not environment:
		return
		
	# Basic ambient light
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.3, 0.35, 0.4)
	environment.ambient_light_energy = 0.8
	
	# Simple tonemap
	environment.tonemap_mode = Environment.TONE_MAPPER_REINHARD
	environment.tonemap_exposure = 1.0
	
	# Minimal glow
	environment.glow_enabled = true
	environment.glow_intensity = 0.5
	environment.glow_strength = 0.8
	environment.glow_bloom = 0.2
	environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	
	# Disable heavy effects
	environment.ssao_enabled = false
	environment.volumetric_fog_enabled = false
	environment.adjustment_enabled = true
	environment.adjustment_brightness = 1.0
	environment.adjustment_contrast = 1.1
	environment.adjustment_saturation = 1.1

func apply_balanced_preset():
	"""Good balance of quality and performance"""
	if not environment:
		return
		
	# Nice ambient light
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.25, 0.3, 0.35)
	environment.ambient_light_energy = 1.0
	
	# Better tonemap
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	environment.tonemap_exposure = 1.2
	
	# Enhanced glow for consciousness
	environment.glow_enabled = true
	environment.glow_intensity = 1.0
	environment.glow_strength = 1.2
	environment.glow_bloom = 0.5
	environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
	
	# Some fog for atmosphere
	environment.volumetric_fog_enabled = false  # Still off for performance
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.5, 0.6, 0.7)
	environment.fog_light_energy = 0.5
	environment.fog_density = 0.01
	
	# Nice adjustments
	environment.adjustment_enabled = true
	environment.adjustment_brightness = 1.1
	environment.adjustment_contrast = contrast_boost
	environment.adjustment_saturation = saturation_boost

func apply_beautiful_preset():
	"""High quality visuals"""
	if not environment:
		return
		
	# Rich ambient light
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_color = Color(0.3, 0.35, 0.45)
	environment.ambient_light_energy = 1.2
	environment.ambient_light_sky_contribution = 1.0
	
	# Cinematic tonemap
	environment.tonemap_mode = Environment.TONE_MAPPER_ACES
	environment.tonemap_exposure = 1.3
	environment.tonemap_white = 6.0
	
	# Beautiful glow
	environment.glow_enabled = true
	environment.glow_intensity = 1.5
	environment.glow_strength = 1.5
	environment.glow_bloom = 0.8
	environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
	environment.glow_hdr_threshold = 1.0
	environment.glow_hdr_scale = 2.0
	
	# Light SSAO
	environment.ssao_enabled = true
	environment.ssao_radius = 1.0
	environment.ssao_intensity = 0.5
	
	# Atmospheric fog
	environment.volumetric_fog_enabled = enable_volumetric_fog
	environment.volumetric_fog_density = 0.01
	environment.volumetric_fog_albedo = Color(0.5, 0.6, 0.7)
	environment.volumetric_fog_emission = Color(0.0, 0.0, 0.0)
	
	# Rich adjustments
	environment.adjustment_enabled = true
	environment.adjustment_brightness = 1.15
	environment.adjustment_contrast = contrast_boost * 1.1
	environment.adjustment_saturation = saturation_boost * 1.1

func apply_cinematic_preset():
	"""Ultra quality for screenshots/videos"""
	apply_beautiful_preset()  # Start with beautiful
	
	if not environment:
		return
	
	# Even more cinematic
	environment.tonemap_exposure = 1.5
	environment.glow_intensity = 2.0
	environment.ssao_intensity = 1.0
	
	# Full volumetric fog
	environment.volumetric_fog_enabled = true
	environment.volumetric_fog_density = 0.02
	
	# Film-like adjustments
	environment.adjustment_contrast = 1.3
	environment.adjustment_saturation = 1.4

func apply_consciousness_grading():
	"""Apply color grading based on consciousness levels in scene"""
	if not environment:
		return
	
	# Find average consciousness level
	var beings = get_tree().get_nodes_in_group("universal_beings")
	if beings.is_empty():
		return
	
	var total_consciousness = 0.0
	var consciousness_count = 0
	
	for being in beings:
		if "consciousness_level" in being:
			total_consciousness += being.consciousness_level
			consciousness_count += 1
	
	if consciousness_count == 0:
		return
	
	var avg_consciousness = total_consciousness / consciousness_count
	
	# Apply color grading based on consciousness
	var color_shift = Color.WHITE
	
	match int(avg_consciousness):
		0: # Dormant - gray
			color_shift = Color(0.9, 0.9, 0.9)
		1: # Awakening - white
			color_shift = Color(1.0, 1.0, 1.0)
		2: # Aware - cyan
			color_shift = Color(0.9, 1.0, 1.0)
		3: # Connected - green
			color_shift = Color(0.9, 1.0, 0.9)
		4: # Enlightened - yellow
			color_shift = Color(1.0, 1.0, 0.9)
		5: # Transcendent - magenta
			color_shift = Color(1.0, 0.9, 1.0)
		_: # Beyond
			color_shift = Color(1.0, 0.95, 1.0)
	
	# Subtle color grading
	if environment.adjustment_enabled:
		var current_color = Color(
			environment.adjustment_brightness,
			environment.adjustment_brightness,
			environment.adjustment_brightness
		)
		var target_color = current_color * color_shift
		
		# Smooth transition
		environment.adjustment_brightness = lerp(
			environment.adjustment_brightness,
			(target_color.r + target_color.g + target_color.b) / 3.0,
			0.1
		)

func create_sky():
	"""Create a beautiful procedural sky"""
	if not environment:
		return
	
	var sky = ProceduralSkyMaterial.new()
	sky.sky_top_color = Color(0.1, 0.2, 0.4)  # Deep blue
	sky.sky_horizon_color = Color(0.3, 0.4, 0.5)  # Lighter blue
	sky.ground_bottom_color = Color(0.05, 0.1, 0.15)  # Dark ground
	sky.ground_horizon_color = Color(0.2, 0.25, 0.3)  # Horizon
	sky.sun_angle_max = 30.0
	sky.sun_curve = 2.0
	
	var sky_instance = Sky.new()
	sky_instance.sky_material = sky
	
	environment.sky = sky_instance
	environment.background_mode = Environment.BG_SKY
	environment.background_energy_multiplier = 0.5

func toggle_visual_preset():
	"""Cycle through visual presets"""
	var next_preset = (current_preset + 1) % VisualPreset.size()
	apply_visual_preset(next_preset)

# Console commands
func _input(event):
	# F9 to cycle visual presets
	if event.is_action_pressed("ui_f9"):
		toggle_visual_preset()
	
	# F10 to toggle glow
	if event.is_action_pressed("ui_f10"):
		if environment:
			environment.glow_enabled = !environment.glow_enabled
			print("🌟 Glow: %s" % ("ON" if environment.glow_enabled else "OFF"))