// LuminousPlanet.gdshader
shader_type spatial;
render_mode unshaded, blend_mix;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float brightness : hint_range(0, 2) = 1.0;
uniform float glow_intensity : hint_range(0, 1) = 0.5;
uniform float noise_scale : hint_range(0, 10) = 2.0;
uniform float time_scale : hint_range(0, 1) = 0.1;
uniform float animation_speed : hint_range(0, 2) = 1.0;
uniform float pulse_frequency : hint_range(0, 10) = 2.0;
uniform float pulse_amplitude : hint_range(0, 0.5) = 0.1;
uniform bool use_custom_texture = false;
uniform sampler2D custom_texture : source_color;

// Simple noise function
float noise(vec3 p) {
    float n = sin(p.x * 1.0) * 0.5 + 0.5;
    n += sin(p.y * 2.3) * 0.5 + 0.5;
    n += sin(p.z * 3.7) * 0.5 + 0.5;
    n += sin(p.x * 4.1 + p.y * 5.3 + p.z * 6.7) * 0.5 + 0.5;
    return n / 4.0;
}

float fbm(vec3 p) {
    float f = 0.0;
    f += 0.5 * noise(p); p *= 2.01;
    f += 0.25 * noise(p); p *= 2.03;
    f += 0.125 * noise(p);
    return f;
}

void fragment() {
    // Base planet color
    vec3 base_color = color.rgb;
    
    // UV coordinates for sphere
    vec2 centered_uv = UV * 2.0 - 1.0;
    float dist = length(centered_uv);
    
    // Calculate angle for rotation animation
    float time = TIME * animation_speed;
    float angle_x = time * time_scale;
    float angle_y = time * time_scale * 0.7;
    
    // Rotate UVs
    vec2 rotated_uv = vec2(
        centered_uv.x * cos(angle_x) - centered_uv.y * sin(angle_x),
        centered_uv.x * sin(angle_x) + centered_uv.y * cos(angle_y)
    );
    
    // Create noise-based patterns
    vec3 noise_pos = vec3(rotated_uv * noise_scale, time * 0.1);
    float noise_value = fbm(noise_pos);
    
    // Pulse effect
    float pulse = sin(time * pulse_frequency) * pulse_amplitude + 1.0;
    
    // Apply edge glow effect
    float edge_glow = smoothstep(0.8, 1.0, dist) * glow_intensity;
    
    // Combine all effects
    vec3 final_color;
    
    if (use_custom_texture) {
        // Use provided texture
        vec4 tex_color = texture(custom_texture, UV);
        final_color = mix(tex_color.rgb, base_color, 0.3);
    } else {
        // Use procedural pattern
        vec3 pattern_color = mix(base_color, vec3(noise_value), 0.3);
        final_color = pattern_color;
    }
    
    // Apply pulse and glow
    final_color = mix(final_color, color.rgb * 1.5, edge_glow);
    final_color *= pulse * brightness;
    
    // Set alpha based on distance from center
    float alpha = smoothstep(1.0, 0.9, dist);
    
    // Output
    ALBEDO = final_color;
    ALPHA = alpha;
    
    // Add slight rim lighting effect
    float fresnel = pow(1.0 - dot(NORMAL, VIEW), 3.0);
    EMISSION = final_color * fresnel * glow_intensity;
}