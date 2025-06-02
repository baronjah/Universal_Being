shader_type canvas_item;

// Effect parameters
uniform float focus_distance : hint_range(0.1, 100.0) = 10.0;
uniform float blur_amount : hint_range(0.0, 1.0) = 0.3;
uniform int blur_samples : hint_range(4, 16) = 8;
uniform float bokeh_shape : hint_range(3.0, 8.0) = 6.0; // Hexagonal by default

// Consciousness integration
uniform float consciousness_level : hint_range(0.0, 7.0) = 2.0;
uniform float effect_intensity : hint_range(0.0, 1.0) = 1.0;

// Screen texture
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;

// Helper function to get depth
float get_depth(vec2 uv) {
    return texture(depth_texture, uv).r;
}

// Convert depth to world units (approximate)
float linearize_depth(float depth) {
    float near = 0.1;
    float far = 1000.0;
    float z = depth * 2.0 - 1.0;
    return (2.0 * near * far) / (far + near - z * (far - near));
}

// Bokeh blur implementation
vec4 bokeh_blur(vec2 uv, float blur_radius) {
    vec4 color = vec4(0.0);
    float total_weight = 0.0;
    
    // Create hexagonal sampling pattern
    float golden_angle = 2.39996323; // Golden angle in radians
    
    for (int i = 0; i < blur_samples; i++) {
        float angle = float(i) * golden_angle;
        float radius = sqrt(float(i) / float(blur_samples)) * blur_radius;
        
        vec2 offset = vec2(cos(angle), sin(angle)) * radius;
        vec2 sample_uv = uv + offset;
        
        // Vignette the samples to create bokeh shape
        float vignette = 1.0 - smoothstep(0.0, 1.0, length(offset) / blur_radius);
        
        color += texture(screen_texture, sample_uv) * vignette;
        total_weight += vignette;
    }
    
    return color / total_weight;
}

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Get the depth at current pixel
    float depth = get_depth(uv);
    float linear_depth = linearize_depth(depth);
    
    // Calculate blur based on distance from focus point
    float depth_difference = abs(linear_depth - focus_distance);
    float blur_factor = smoothstep(0.0, 20.0, depth_difference) * blur_amount * effect_intensity;
    
    // Apply consciousness modulation
    blur_factor *= (consciousness_level - 1.0) / 6.0; // Start from level 2
    
    // Sample the scene
    vec4 sharp_color = texture(screen_texture, uv);
    vec4 blurred_color = bokeh_blur(uv, blur_factor * 0.02); // Convert to UV space
    
    // Mix based on blur factor
    vec4 final_color = mix(sharp_color, blurred_color, clamp(blur_factor, 0.0, 1.0));
    
    // Add subtle consciousness glow to in-focus areas
    if (consciousness_level >= 2.0) {
        float focus_glow = 1.0 - blur_factor;
        final_color.rgb += final_color.rgb * focus_glow * 0.1 * (consciousness_level / 7.0);
    }
    
    COLOR = final_color;
}