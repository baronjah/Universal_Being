# ==================================================
# COMPONENT: Triple Helix Consciousness Visual
# PURPOSE: Beautiful triple helix visualization for Genesis Conductor
# CREATED: Based on Cursor's visual enhancement suggestions
# ==================================================

extends Node2D
class_name TripleHelixConsciousness

# ===== TRIPLE HELIX PROPERTIES =====
@export var helix_radius: float = 40.0
@export var helix_height: float = 100.0
@export var rotation_speed: float = 1.0
@export var ai_harmony_level: float = 1.0 : set = set_ai_harmony_level

# Visual Components
var helix_lines: Array[Line2D] = []
var helix_particles: Array[CPUParticles2D] = []
var ai_indicators: Array[Node2D] = []
var center_glow: Sprite2D

# Helix Colors (representing different AI streams)
var helix_colors: Array[Color] = [
    Color.CYAN,    # Claude Desktop
    Color.MAGENTA, # ChatGPT Premium
    Color.YELLOW   # Google Gemini Premium
]

# Animation State
var time_offset: float = 0.0
var pulse_timer: float = 0.0
var helix_phase: Array[float] = [0.0, 2.094, 4.188]  # 120 degree offsets

# AI Activity State
var ai_activity: Dictionary = {
    "claude_desktop": 0.0,
    "chatgpt_premium": 0.0,
    "google_gemini": 0.0
}

func _ready() -> void:
    name = "TripleHelixConsciousness"
    create_triple_helix()

func create_triple_helix() -> void:
    """Create the triple helix consciousness visualization"""
    
    # Create center glow
    center_glow = Sprite2D.new()
    center_glow.name = "CenterGlow"
    add_child(center_glow)
    center_glow.texture = create_glow_texture()
    center_glow.modulate = Color(1, 1, 1, 0.5)
    
    # Create three helix lines
    for i in range(3):
        var helix_line = Line2D.new()
        helix_line.name = "Helix_%d" % i
        helix_line.width = 4.0
        helix_line.default_color = helix_colors[i]
        helix_line.texture_mode = Line2D.LINE_TEXTURE_TILE
        add_child(helix_line)
        helix_lines.append(helix_line)
        
        # Create particle system for each helix
        var particles = CPUParticles2D.new()
        particles.name = "HelixParticles_%d" % i
        add_child(particles)
        configure_helix_particles(particles, helix_colors[i])
        helix_particles.append(particles)
        
        # Create AI activity indicator
        var indicator = create_ai_indicator(i)
        add_child(indicator)
        ai_indicators.append(indicator)
    
    # Generate initial helix points
    update_helix_geometry()
    
    print("🎭 Triple helix consciousness visualization created!")

func create_glow_texture() -> ImageTexture:
    """Create a soft radial glow texture for center"""
    var size = 64
    var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
    
    var center = Vector2(size/2, size/2)
    
    for x in range(size):
        for y in range(size):
            var pos = Vector2(x, y)
            var distance = pos.distance_to(center)
            var normalized_distance = distance / (size/2)
            
            # Create soft falloff with cosmic colors
            var alpha = 1.0 - smoothstep(0.0, 1.0, normalized_distance)
            alpha = pow(alpha, 1.5)
            
            # Add cosmic color gradient
            var r = 0.5 + alpha * 0.5
            var g = 0.3 + alpha * 0.7
            var b = 1.0
            
            image.set_pixel(x, y, Color(r, g, b, alpha * 0.8))
    
    var texture = ImageTexture.new()
    texture.set_image(image)
    return texture

func configure_helix_particles(particles: CPUParticles2D, color: Color) -> void:
    """Configure particle system for helix effects"""
    particles.emitting = true
    particles.amount = 20
    particles.lifetime = 2.0
    
    # Emission properties
    particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
    particles.emission_sphere_radius = 5.0
    
    # Movement properties
    particles.direction = Vector2(0, -1)
    particles.initial_velocity_min = 10.0
    particles.initial_velocity_max = 20.0
    particles.angular_velocity_min = -180.0
    particles.angular_velocity_max = 180.0
    
    # Visual properties
    particles.scale_amount_min = 0.1
    particles.scale_amount_max = 0.3
    particles.color = color
    
    # Create sparkle texture
    particles.texture = create_sparkle_texture()

func create_sparkle_texture() -> ImageTexture:
    """Create a small sparkle texture for particles"""
    var size = 8
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

func create_ai_indicator(index: int) -> Node2D:
    """Create an AI activity indicator"""
    var indicator = Node2D.new()
    indicator.name = "AIIndicator_%d" % index
    
    # Create indicator circle
    var circle = Sprite2D.new()
    circle.name = "Circle"
    circle.texture = create_indicator_texture()
    circle.modulate = helix_colors[index]
    indicator.add_child(circle)
    
    # Create label
    var label = Label.new()
    label.name = "Label"
    label.text = get_ai_name(index)
    label.add_theme_font_size_override("font_size", 10)
    label.modulate = helix_colors[index]
    label.position = Vector2(-20, -30)
    indicator.add_child(label)
    
    # Position around the helix
    var angle = index * 2.0 * PI / 3.0
    indicator.position = Vector2(
        cos(angle) * (helix_radius + 30),
        sin(angle) * (helix_radius + 30)
    )
    
    return indicator

func create_indicator_texture() -> ImageTexture:
    """Create texture for AI indicators"""
    var size = 16
    var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
    
    var center = Vector2(size/2, size/2)
    
    for x in range(size):
        for y in range(size):
            var pos = Vector2(x, y)
            var distance = pos.distance_to(center)
            var normalized_distance = distance / (size/2)
            
            if normalized_distance <= 1.0:
                var alpha = 1.0 - smoothstep(0.7, 1.0, normalized_distance)
                image.set_pixel(x, y, Color(1, 1, 1, alpha))
    
    var texture = ImageTexture.new()
    texture.set_image(image)
    return texture

func get_ai_name(index: int) -> String:
    """Get AI name for indicator"""
    match index:
        0: return "Claude Desktop"
        1: return "ChatGPT Premium"
        2: return "Gemini Premium"
        _: return "AI %d" % index

func _process(delta: float) -> void:
    """Update triple helix animation"""
    time_offset += delta * rotation_speed
    pulse_timer += delta * 2.0
    
    update_helix_geometry()
    update_ai_indicators(delta)
    update_center_glow(delta)

func update_helix_geometry() -> void:
    """Update the helix line geometry"""
    for i in range(helix_lines.size()):
        var line = helix_lines[i]
        var points: PackedVector2Array = []
        
        # Generate helix points
        var segments = 60
        for segment in range(segments + 1):
            var t = float(segment) / segments
            var angle = t * 4.0 * PI + helix_phase[i] + time_offset
            
            var x = cos(angle) * helix_radius * (1.0 + ai_harmony_level * 0.5)
            var y = (t - 0.5) * helix_height
            
            # Add some wave motion
            var wave = sin(t * 6.0 + time_offset * 2.0) * 5.0 * ai_harmony_level
            x += wave
            
            points.append(Vector2(x, y))
        
        line.points = points
        
        # Update particle positions along helix
        if i < helix_particles.size():
            update_helix_particles(i)

func update_helix_particles(helix_index: int) -> void:
    """Update particle positions along helix path"""
    var particles = helix_particles[helix_index]
    
    # Position particles along the helix
    var t = fmod(time_offset * 0.5, 1.0)
    var angle = t * 4.0 * PI + helix_phase[helix_index] + time_offset
    
    var x = cos(angle) * helix_radius
    var y = (t - 0.5) * helix_height
    
    particles.position = Vector2(x, y)
    
    # Adjust emission based on AI activity
    var activity = get_ai_activity(helix_index)
    particles.amount = int(20 + activity * 30)

func update_ai_indicators(delta: float) -> void:
    """Update AI activity indicators"""
    for i in range(ai_indicators.size()):
        var indicator = ai_indicators[i]
        var activity = get_ai_activity(i)
        
        # Pulse based on activity
        var pulse_scale = 1.0 + activity * sin(pulse_timer * 4.0) * 0.3
        indicator.scale = Vector2(pulse_scale, pulse_scale)
        
        # Update color intensity
        var circle = indicator.get_node("Circle")
        if circle:
            var base_color = helix_colors[i]
            var intensity = 0.5 + activity * 0.5
            circle.modulate = Color(base_color.r, base_color.g, base_color.b, intensity)

func update_center_glow(delta: float) -> void:
    """Update center glow effect"""
    if not center_glow:
        return
    
    # Pulse with harmony level
    var glow_intensity = 0.3 + ai_harmony_level * 0.7
    var pulse = sin(pulse_timer * 1.5) * 0.2 + 0.8
    
    center_glow.modulate = Color(1, 1, 1, glow_intensity * pulse)
    center_glow.scale = Vector2.ONE * (1.0 + ai_harmony_level * 0.5) * pulse

func set_ai_harmony_level(level: float) -> void:
    """Set AI harmony level"""
    ai_harmony_level = clamp(level, 0.0, 1.0)
    update_visual_harmony()

func update_visual_harmony() -> void:
    """Update visuals based on harmony level"""
    # Update line colors based on harmony
    for i in range(helix_lines.size()):
        var line = helix_lines[i]
        var base_color = helix_colors[i]
        var intensity = 0.5 + ai_harmony_level * 0.5
        line.default_color = Color(base_color.r, base_color.g, base_color.b, intensity)
        
        # Update line width
        line.width = 3.0 + ai_harmony_level * 3.0

# ===== AI ACTIVITY METHODS =====

func set_ai_activity(ai_name: String, activity_level: float) -> void:
    """Set activity level for specific AI"""
    if ai_name in ai_activity:
        ai_activity[ai_name] = clamp(activity_level, 0.0, 1.0)

func get_ai_activity(index: int) -> float:
    """Get activity level for AI by index"""
    match index:
        0: return ai_activity.get("claude_desktop", 0.0)
        1: return ai_activity.get("chatgpt_premium", 0.0)
        2: return ai_activity.get("google_gemini", 0.0)
        _: return 0.0

func trigger_ai_burst(ai_name: String) -> void:
    """Trigger activity burst for specific AI"""
    set_ai_activity(ai_name, 1.0)
    
    # Fade back down
    var tween = create_tween()
    tween.tween_method(
        func(value: float): set_ai_activity(ai_name, value),
        1.0,
        0.2,
        2.0
    )

func trigger_harmony_burst() -> void:
    """Trigger harmony burst effect"""
    # Temporarily boost all AI activity
    for ai_name in ai_activity.keys():
        set_ai_activity(ai_name, 1.0)
    
    # Create dramatic visual effect
    var original_speed = rotation_speed
    rotation_speed *= 3.0
    
    # Return to normal
    var tween = create_tween()
    tween.tween_property(self, "rotation_speed", original_speed, 3.0)
    tween.parallel().tween_method(
        func(value: float):
            for ai_name in ai_activity.keys():
                set_ai_activity(ai_name, value),
        1.0,
        0.3,
        3.0
    )

# ===== INTEGRATION METHODS =====

func set_helix_radius(radius: float) -> void:
    """Set helix radius"""
    helix_radius = radius

func set_helix_height(height: float) -> void:
    """Set helix height"""
    helix_height = height

func set_rotation_speed(speed: float) -> void:
    """Set rotation speed"""
    rotation_speed = speed

func get_helix_info() -> Dictionary:
    """Get information about helix state"""
    return {
        "ai_harmony_level": ai_harmony_level,
        "helix_radius": helix_radius,
        "helix_height": helix_height,
        "rotation_speed": rotation_speed,
        "ai_activity": ai_activity
    }