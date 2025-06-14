shader_type spatial;
// Holographic 3D interface shader with sacred geometry patterns
// JSH #memories

render_mode unshaded, cull_disabled, depth_draw_opaque, depth_test_disabled;

uniform float time_scale : hint_range(0.1, 5.0) = 1.0;
uniform vec4 hologram_color : source_color = vec4(0.0, 1.0, 0.8, 1.0);
uniform float scan_speed : hint_range(0.1, 10.0) = 2.0;
uniform float distortion_amount : hint_range(0.0, 0.1) = 0.02;
uniform float geometry_complexity : hint_range(3.0, 12.0) = 6.0;
uniform bool sacred_geometry_mode = true;

// Sacred geometry pattern generator
float sacred_pattern(vec2 uv, float sides) {
    float angle = atan(uv.y, uv.x);
    float radius = length(uv);
    float pattern = sin(sides * angle) * cos(radius * 10.0);
    return pattern;
}

void vertex() {
    // Add subtle vertex animation for holographic wobble
    vec3 offset = vec3(
        sin(TIME * time_scale + VERTEX.y * 2.0) * distortion_amount,
        cos(TIME * time_scale * 1.3 + VERTEX.x * 2.0) * distortion_amount,
        sin(TIME * time_scale * 0.7 + VERTEX.z * 2.0) * distortion_amount
    );
    VERTEX += offset;
}

void fragment() {
    vec2 centered_uv = UV - vec2(0.5);
    
    // Create holographic scan lines
    float scan = sin(UV.y * 100.0 - TIME * scan_speed) * 0.1 + 0.9;
    
    // Add sacred geometry patterns
    float pattern = 1.0;
    if (sacred_geometry_mode) {
        pattern = sacred_pattern(centered_uv, geometry_complexity);
        pattern = pattern * 0.5 + 0.5;
    }
    
    // Create holographic flicker
    float flicker = sin(TIME * 20.0) * 0.05 + 0.95;
    
    // Distance-based fade
    float dist = length(centered_uv);
    float fade = 1.0 - smoothstep(0.3, 0.5, dist);
    
    // Combine effects
    vec3 color = hologram_color.rgb * scan * pattern * flicker;
    float alpha = hologram_color.a * fade * pattern;
    
    // Add edge glow
    float edge = 1.0 - abs(dot(NORMAL, VIEW));
    color += hologram_color.rgb * pow(edge, 2.0) * 0.5;
    
    ALBEDO = color;
    ALPHA = alpha;
    EMISSION = color * 2.0;
}