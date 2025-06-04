shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Chromatic aberration parameters
uniform float aberration_amount : hint_range(0.0, 0.01) = 0.003;
uniform vec2 aberration_center = vec2(0.5, 0.5);
uniform float radial_factor : hint_range(0.0, 2.0) = 1.0;

// Consciousness parameters
uniform float consciousness_level : hint_range(0.0, 7.0) = 4.0;
uniform float consciousness_pulse : hint_range(0.0, 1.0) = 0.0;

// Movement influence
uniform vec2 camera_velocity = vec2(0.0, 0.0);
uniform float movement_multiplier : hint_range(0.0, 5.0) = 2.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Calculate direction and distance from center
    vec2 direction = uv - aberration_center;
    float distance = length(direction);
    
    // Normalize direction for radial effect
    vec2 normalized_direction = direction / (distance + 0.0001); // Avoid division by zero
    
    // Calculate base aberration amount
    float base_aberration = aberration_amount * distance * radial_factor;
    
    // Add consciousness influence
    float consciousness_factor = (consciousness_level - 3.0) / 4.0;
    float aberration = base_aberration * consciousness_factor;
    
    // Add movement influence
    float movement = length(camera_velocity) * movement_multiplier;
    aberration += movement * aberration_amount * 0.5;
    
    // Add consciousness pulse
    float pulse = 1.0 + (consciousness_pulse * 0.3 * sin(TIME * 3.0));
    aberration *= pulse;
    
    // Sample RGB channels with offset
    vec3 color;
    color.r = texture(SCREEN_TEXTURE, uv - normalized_direction * aberration * 1.0).r;
    color.g = texture(SCREEN_TEXTURE, uv).g;
    color.b = texture(SCREEN_TEXTURE, uv + normalized_direction * aberration * 1.0).b;
    
    // Optional: Add subtle color shift based on consciousness
    if (consciousness_level > 4.5) {
        float shift = sin(TIME * 2.0) * 0.1 * consciousness_pulse;
        color.r = texture(SCREEN_TEXTURE, uv - normalized_direction * (aberration + shift)).r;
        color.b = texture(SCREEN_TEXTURE, uv + normalized_direction * (aberration + shift)).b;
    }
    
    // Output final color
    COLOR = vec4(color, 1.0);
} 