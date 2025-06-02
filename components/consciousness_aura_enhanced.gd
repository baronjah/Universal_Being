# ==================================================
# COMPONENT: Enhanced Consciousness Aura Visual System
# PURPOSE: Beautiful particle-based consciousness visualization
# CREATED: Based on Cursor's visual enhancement suggestions
# ==================================================

extends Node2D
class_name ConsciousnessAuraEnhanced

# ===== CONSCIOUSNESS AURA PROPERTIES =====
@export var consciousness_level: int = 0 : set = set_consciousness_level
@export var aura_radius: float = 50.0
@export var particle_count: int = 100
@export var pulse_speed: float = 2.0

# Visual Components
var particles: GPUParticles2D
var glow_circle: Sprite2D
var consciousness_colors: Array[Color] = [
    Color.GRAY,        # 0: Dormant
    Color.WHITE,       # 1: Awakening  
    Color.CYAN,        # 2: Aware
    Color.GREEN,       # 3: Active
    Color.YELLOW,      # 4: Enlightened
    Color.MAGENTA,     # 5: Transcendent
    Color.RED          # 6+: Cosmic
]

# Animation State
var pulse_timer: float = 0.0
var swirl_rotation: float = 0.0

func _ready() -> void:
    name = "ConsciousnessAura"
    create_enhanced_aura()

func create_enhanced_aura() -> void:
    """Create beautiful particle-based consciousness aura"""
    
    # Create glow background
    glow_circle = Sprite2D.new()
    glow_circle.name = "GlowCircle"
    add_child(glow_circle)
    
    # Create glow texture procedurally
    var glow_texture = create_glow_texture()
    glow_circle.texture = glow_texture
    glow_circle.modulate = Color(1, 1, 1, 0.3)
    
    # Create particle system
    particles = GPUParticles2D.new()
    particles.name = "ConsciousnessParticles"
    add_child(particles)
    
    # Configure particle material
    var material = ParticleProcessMaterial.new()
    configure_particle_material(material)
    particles.process_material = material
    
    # Set particle properties
    particles.emitting = true
    particles.amount = particle_count
    particles.lifetime = 3.0
    particles.texture = create_particle_texture()
    
    print("🧠 Enhanced consciousness aura created with particles!")

func create_glow_texture() -> ImageTexture:
    """Create a soft radial glow texture"""
    var size = 128
    var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
    
    var center = Vector2(size/2, size/2)
    
    for x in range(size):
        for y in range(size):
            var pos = Vector2(x, y)
            var distance = pos.distance_to(center)
            var normalized_distance = distance / (size/2)
            
            # Create soft falloff
            var alpha = 1.0 - smoothstep(0.0, 1.0, normalized_distance)
            alpha = pow(alpha, 2.0)  # More falloff
            
            image.set_pixel(x, y, Color(1, 1, 1, alpha))
    
    var texture = ImageTexture.new()
    texture.set_image(image)
    return texture

func create_particle_texture() -> ImageTexture:
    """Create a small particle texture"""
    var size = 16
    var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
    
    var center = Vector2(size/2, size/2)
    
    for x in range(size):
        for y in range(size):
            var pos = Vector2(x, y)
            var distance = pos.distance_to(center)
            var normalized_distance = distance / (size/2)
            
            var alpha = 1.0 - smoothstep(0.0, 1.0, normalized_distance)
            image.set_pixel(x, y, Color(1, 1, 1, alpha))
    
    var texture = ImageTexture.new()
    texture.set_image(image)
    return texture

func configure_particle_material(material: ParticleProcessMaterial) -> void:
    """Configure particle system for consciousness visualization"""
    
    # Emission
    material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
    material.emission_sphere_radius = aura_radius
    
    # Direction and spread
    material.direction = Vector3(0, -1, 0)
    material.initial_velocity_min = 20.0
    material.initial_velocity_max = 40.0
    material.angular_velocity_min = -180.0
    material.angular_velocity_max = 180.0
    
    # Gravity and damping
    material.gravity = Vector3(0, -10.0, 0)
    material.linear_accel_min = -5.0
    material.linear_accel_max = 5.0
    
    # Scale animation
    material.scale_min = 0.1
    material.scale_max = 0.3
    # Note: scale_curve would need a CurveTexture, not a Curve
    # material.scale_curve = create_scale_curve_texture()
    
    # Color animation
    material.color = get_consciousness_color()
    # Note: color_ramp would need a GradientTexture1D, not a Gradient
    # material.color_ramp = create_color_ramp_texture()

func create_scale_curve() -> Curve:
    """Create scale animation curve for particles"""
    var curve = Curve.new()
    curve.add_point(Vector2(0.0, 0.0))  # Start small
    curve.add_point(Vector2(0.3, 1.0))  # Grow quickly
    curve.add_point(Vector2(0.7, 1.0))  # Stay large
    curve.add_point(Vector2(1.0, 0.0))  # Fade out
    return curve

func create_color_ramp() -> Gradient:
    """Create color animation for particles"""
    var gradient = Gradient.new()
    var base_color = get_consciousness_color()
    
    # In Godot 4, use set_offset and set_color
    gradient.set_offset(0, 0.0)
    gradient.set_color(0, Color(base_color.r, base_color.g, base_color.b, 0.0))
    gradient.add_point(0.2, base_color)
    gradient.add_point(0.8, base_color)
    gradient.add_point(1.0, Color(base_color.r, base_color.g, base_color.b, 0.0))
    
    return gradient

func get_consciousness_color() -> Color:
    """Get color based on consciousness level"""
    if consciousness_level < consciousness_colors.size():
        return consciousness_colors[consciousness_level]
    else:
        return consciousness_colors[-1]  # Red for super consciousness

func set_consciousness_level(new_level: int) -> void:
    """Update consciousness level and visuals"""
    consciousness_level = new_level
    update_aura_visuals()

func update_aura_visuals() -> void:
    """Update visual effects based on consciousness level"""
    if not particles or not glow_circle:
        return
    
    var color = get_consciousness_color()
    
    # Update glow circle
    glow_circle.modulate = Color(color.r, color.g, color.b, 0.3 + consciousness_level * 0.1)
    glow_circle.scale = Vector2.ONE * (1.0 + consciousness_level * 0.2)
    
    # Update particle material
    if particles.process_material is ParticleProcessMaterial:
        var material = particles.process_material as ParticleProcessMaterial
        material.color = color
        material.color_ramp = create_color_ramp()
        
        # More particles for higher consciousness
        particles.amount = particle_count + consciousness_level * 20
        
        # Faster movement for higher consciousness
        material.initial_velocity_min = 20.0 + consciousness_level * 10.0
        material.initial_velocity_max = 40.0 + consciousness_level * 15.0

func _process(delta: float) -> void:
    """Animate consciousness effects"""
    pulse_timer += delta * pulse_speed
    swirl_rotation += delta * 30.0  # degrees per second
    
    update_pulse_animation(delta)
    update_swirl_animation(delta)

func update_pulse_animation(delta: float) -> void:
    """Create pulsing effect based on consciousness level"""
    if not glow_circle:
        return
    
    var pulse_intensity = sin(pulse_timer) * 0.3 + 0.7
    var base_scale = 1.0 + consciousness_level * 0.2
    glow_circle.scale = Vector2.ONE * base_scale * pulse_intensity
    
    # Pulse the particle emission
    if particles:
        var emission_scale = pulse_intensity
        particles.amount = int((particle_count + consciousness_level * 20) * emission_scale)

func update_swirl_animation(delta: float) -> void:
    """Create swirling motion for higher consciousness levels"""
    if consciousness_level < 3 or not particles:
        return
    
    # Add swirling motion to particles for enlightened consciousness
    rotation_degrees = swirl_rotation * (consciousness_level - 2) * 0.1

func trigger_consciousness_burst() -> void:
    """Create burst effect when consciousness increases"""
    if not particles:
        return
    
    # Temporary burst of particles
    var burst_tween = create_tween()
    burst_tween.tween_method(
        func(value: float): particles.amount = int(particle_count * value),
        1.0,
        3.0,
        0.5
    )
    burst_tween.tween_method(
        func(value: float): particles.amount = int(particle_count * value),
        3.0,
        1.0,
        1.0
    )
    
    print("🌟 Consciousness burst triggered!")

# ===== INTEGRATION METHODS =====

func set_aura_radius(radius: float) -> void:
    """Set the radius of the consciousness aura"""
    aura_radius = radius
    if particles and particles.process_material is ParticleProcessMaterial:
        var material = particles.process_material as ParticleProcessMaterial
        material.emission_ring_radius = radius
        material.emission_ring_inner_radius = radius * 0.8

func set_particle_count(count: int) -> void:
    """Set number of particles"""
    particle_count = count
    if particles:
        particles.amount = count

func set_pulse_speed(speed: float) -> void:
    """Set pulse animation speed"""
    pulse_speed = speed

func get_aura_info() -> Dictionary:
    """Get information about the aura state"""
    return {
        "consciousness_level": consciousness_level,
        "aura_radius": aura_radius,
        "particle_count": particles.amount if particles else 0,
        "color": get_consciousness_color(),
        "pulse_timer": pulse_timer
    }