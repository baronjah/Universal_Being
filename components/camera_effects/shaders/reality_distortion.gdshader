shader_type canvas_item;

// Reality distortion parameters
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02;
uniform float wave_frequency : hint_range(1.0, 10.0) = 3.0;
uniform float wave_amplitude : hint_range(0.0, 0.05) = 0.01;

// Consciousness parameters
uniform float consciousness_level : hint_range(0.0, 7.0) = 5.0;
uniform float consciousness_pulse : hint_range(0.0, 1.0) = 0.0;

// Space-time parameters
uniform float time_distortion : hint_range(0.0, 2.0) = 1.0;
uniform vec2 distortion_center = vec2(0.5, 0.5);

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Calculate consciousness influence
    float consciousness_factor = (consciousness_level - 4.0) / 3.0;
    
    // Create pulsing time effect
    float pulse_time = TIME * time_distortion + consciousness_pulse * sin(TIME * 2.0);
    
    // Calculate distance and direction from center
    vec2 direction = uv - distortion_center;
    float distance = length(direction);
    
    // Create ripple effect
    float ripple = sin(distance * wave_frequency - pulse_time * 3.0) * wave_amplitude;
    ripple *= consciousness_factor;
    
    // Create swirl distortion
    float angle = atan(direction.y, direction.x);
    float swirl = sin(pulse_time + angle * 4.0) * distortion_strength;
    swirl *= consciousness_factor * distance;
    
    // Apply rotational matrix for swirl
    float cos_swirl = cos(swirl);
    float sin_swirl = sin(swirl);
    mat2 rotation = mat2(vec2(cos_swirl, -sin_swirl), vec2(sin_swirl, cos_swirl));
    
    // Combine distortions
    vec2 distorted_direction = rotation * direction;
    vec2 ripple_offset = normalize(direction) * ripple;
    
    // Final UV calculation
    vec2 distorted_uv = distortion_center + distorted_direction + ripple_offset;
    
    // Add consciousness pulse distortion
    if (consciousness_level >= 5.5) {
        float pulse_strength = consciousness_pulse * 0.03;
        float pulse_wave = sin(pulse_time * 5.0) * pulse_strength;
        distorted_uv += vec2(pulse_wave, pulse_wave * 0.5);
    }
    
    // Sample the distorted texture
    vec4 color = texture(SCREEN_TEXTURE, distorted_uv);
    
    // Add reality fracture lines for higher consciousness
    if (consciousness_level >= 6.0) {
        float fracture = step(0.98, sin(uv.x * 50.0 + pulse_time)) * 0.1;
        fracture += step(0.98, sin(uv.y * 50.0 + pulse_time * 1.3)) * 0.1;
        color.rgb += vec3(1.0, 0.8, 1.0) * fracture * consciousness_factor;
    }
    
    // Add subtle color shift to represent reality bending
    float reality_shift = sin(pulse_time * 0.5) * 0.1 * consciousness_factor;
    color.rgb = mix(color.rgb, color.bgr, reality_shift);
    
    COLOR = color;
}