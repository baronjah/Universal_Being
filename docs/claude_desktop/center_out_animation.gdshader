shader_type canvas_item;
// Center-out animation shader from luminous data specs
// JSH #memories

uniform float speed : hint_range(0.1, 10.0) = 1.0;
uniform float wave_count : hint_range(1.0, 50.0) = 20.0;
uniform vec4 primary_color : source_color = vec4(0.0, 0.8, 1.0, 1.0);
uniform vec4 secondary_color : source_color = vec4(1.0, 0.2, 0.8, 1.0);
uniform float glow_intensity : hint_range(0.0, 2.0) = 1.0;
uniform float pulse_amplitude : hint_range(0.0, 1.0) = 0.5;
uniform bool holographic_mode = true;

void fragment() {
    // Calculate distance from center
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center);
    
    // Create animated waves radiating from center
    float wave = sin(dist * wave_count - TIME * speed);
    float pulse = sin(TIME * speed * 0.5) * pulse_amplitude + (1.0 - pulse_amplitude);
    
    // Calculate alpha with pulsing effect
    float alpha = (wave * 0.5 + 0.5) * pulse;
    
    // Mix colors based on wave position
    vec3 color = mix(primary_color.rgb, secondary_color.rgb, alpha);
    
    // Add holographic effect
    if (holographic_mode) {
        float scan_line = sin(UV.y * 100.0 + TIME * 2.0) * 0.05 + 0.95;
        color *= scan_line;
        
        // Add chromatic aberration for holographic feel
        float aberration = sin(TIME * 3.0) * 0.01;
        color.r = texture(TEXTURE, UV + vec2(aberration, 0.0)).r;
        color.b = texture(TEXTURE, UV - vec2(aberration, 0.0)).b;
    }
    
    // Apply glow
    color *= glow_intensity;
    
    // Set final color
    COLOR = vec4(color, alpha * COLOR.a);
}