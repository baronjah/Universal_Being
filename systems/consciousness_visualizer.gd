extends Node
class_name ConsciousnessVisualizer

# ChatGPT's consciousness color progression
const CONSCIOUSNESS_COLORS = {
	0: Color(0.5, 0.5, 0.5),      # Gray - Dormant
	1: Color(0.9, 0.9, 0.9),      # Pale - Awakening
	2: Color(0.2, 0.4, 1.0),      # Blue - Aware
	3: Color(0.2, 1.0, 0.2),      # Green - Connected
	4: Color(1.0, 0.84, 0.0),     # Gold - Enlightened
	5: Color(1.0, 1.0, 1.0)       # Glowing White - Transcendent
}

const CONSCIOUSNESS_NAMES = {
	0: "Dormant",
	1: "Awakening",
	2: "Aware",
	3: "Connected",
	4: "Enlightened",
	5: "Transcendent"
}

# Visual effect parameters per consciousness level
const VISUAL_EFFECTS = {
	0: {
		"particle_amount": 0,
		"particle_speed": 0.0,
		"emission_radius": 0.0,
		"glow_strength": 0.0,
		"pulse_speed": 0.0
	},
	1: {
		"particle_amount": 8,
		"particle_speed": 0.5,
		"emission_radius": 20.0,
		"glow_strength": 0.1,
		"pulse_speed": 1.0
	},
	2: {
		"particle_amount": 16,
		"particle_speed": 1.0,
		"emission_radius": 30.0,
		"glow_strength": 0.3,
		"pulse_speed": 1.5
	},
	3: {
		"particle_amount": 24,
		"particle_speed": 1.5,
		"emission_radius": 40.0,
		"glow_strength": 0.5,
		"pulse_speed": 2.0
	},
	4: {
		"particle_amount": 32,
		"particle_speed": 2.0,
		"emission_radius": 50.0,
		"glow_strength": 0.7,
		"pulse_speed": 2.5
	},
	5: {
		"particle_amount": 48,
		"particle_speed": 3.0,
		"emission_radius": 60.0,
		"glow_strength": 1.0,
		"pulse_speed": 3.0
	}
}

# Apply consciousness visual to a being's scene
static func apply_consciousness_visual(being: UniversalBeing, scene_root: Node) -> void:
	var level = clampi(being.consciousness_level, 0, 5)
	var color = CONSCIOUSNESS_COLORS[level]
	var effects = VISUAL_EFFECTS[level]
	
	# Update AuraParticles
	var aura = scene_root.get_node_or_null("AuraParticles")
	if aura and aura is CPUParticles2D:
		apply_particle_effects(aura, level, color, effects)
	
	# Update ConsciousnessLabel
	var label = scene_root.get_node_or_null("ConsciousnessLabel")
	if label and label is Label:
		apply_label_effects(label, level, color)
	
	# Update button/main visual element
	if scene_root is Control:
		apply_control_effects(scene_root, level, color, effects)
	
	# Apply glowing effect for level 5
	if level == 5:
		apply_transcendent_glow(scene_root, color)

static func apply_particle_effects(particles: CPUParticles2D, level: int, color: Color, effects: Dictionary) -> void:
	particles.emitting = level > 0
	particles.amount = effects.particle_amount
	particles.lifetime = 2.0
	particles.speed_scale = effects.particle_speed
	
	# Color settings
	particles.color = color
	particles.color.a = 0.6 if level < 5 else 0.8
	
	# Emission shape
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = effects.emission_radius
	
	# Movement
	particles.initial_velocity_min = 10.0 * effects.particle_speed
	particles.initial_velocity_max = 20.0 * effects.particle_speed
	
	# Rotation
	particles.angular_velocity_min = -180.0 if level > 2 else 0.0
	particles.angular_velocity_max = 180.0 if level > 2 else 0.0
	
	# Scale
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.0 + (level * 0.2)
	
	# Advanced effects for higher levels
	if level >= 3:
		particles.orbit_velocity_min = 0.1
		particles.orbit_velocity_max = 0.3
		
	if level >= 4:
		particles.damping_min = 5.0
		particles.damping_max = 10.0
		
	if level == 5:
		particles.hue_variation_min = -0.1
		particles.hue_variation_max = 0.1

static func apply_label_effects(label: Label, level: int, color: Color) -> void:
	label.text = "Level %d: %s" % [level, CONSCIOUSNESS_NAMES[level]]
	label.modulate = color
	
	# Add shadow/glow for higher levels
	if level >= 3:
		label.add_theme_color_override("font_shadow_color", color)
		label.add_theme_constant_override("shadow_offset_x", 2)
		label.add_theme_constant_override("shadow_offset_y", 2)
		
	if level >= 4:
		label.add_theme_constant_override("shadow_outline_size", 4)

static func apply_control_effects(control: Control, level: int, color: Color, effects: Dictionary) -> void:
	# Base modulation
	control.modulate = color
	control.modulate.a = 1.0 if level < 5 else 0.95
	
	# Add metadata for dynamic effects
	control.set_meta("consciousness_level", level)
	control.set_meta("pulse_speed", effects.pulse_speed)
	control.set_meta("glow_strength", effects.glow_strength)

static func apply_transcendent_glow(node: Node, color: Color) -> void:
	# For level 5, add special glowing effect
	if node is CanvasItem:
		node.material = create_glow_material(color)

static func create_glow_material(color: Color) -> ShaderMaterial:
	var shader = Shader.new()
	shader.code = """
shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float glow_power : hint_range(0.0, 3.0) = 1.0;
uniform float time_scale : hint_range(0.0, 10.0) = 3.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float pulse = sin(TIME * time_scale) * 0.5 + 0.5;
    vec4 glow = glow_color * pulse * glow_power;
    COLOR = tex + glow * tex.a;
}
"""
	
	var material = ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("glow_color", color)
	material.set_shader_parameter("glow_power", 1.0)
	material.set_shader_parameter("time_scale", 3.0)
	
	return material

# Get consciousness color
static func get_consciousness_color(level: int) -> Color:
	return CONSCIOUSNESS_COLORS.get(clampi(level, 0, 5), Color.WHITE)

# Get consciousness name
static func get_consciousness_name(level: int) -> String:
	return CONSCIOUSNESS_NAMES.get(clampi(level, 0, 5), "Unknown")

# Interpolate between consciousness levels for smooth transitions
static func interpolate_consciousness_color(from_level: int, to_level: int, weight: float) -> Color:
	var from_color = get_consciousness_color(from_level)
	var to_color = get_consciousness_color(to_level)
	return from_color.lerp(to_color, weight)

# Create a consciousness transition effect
static func create_transition_particles(position: Vector2, from_level: int, to_level: int) -> CPUParticles2D:
	var particles = CPUParticles2D.new()
	particles.position = position
	particles.emitting = true
	particles.amount = 50
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = 20.0
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 100.0
	particles.angular_velocity_min = -360.0
	particles.angular_velocity_max = 360.0
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 1.5
	
	# Gradient from old to new color
	var gradient = Gradient.new()
	gradient.add_point(0.0, get_consciousness_color(from_level))
	gradient.add_point(1.0, get_consciousness_color(to_level))
	
	# TODO: Apply gradient to particles when Godot supports it
	particles.color = get_consciousness_color(to_level)
	
	return particles