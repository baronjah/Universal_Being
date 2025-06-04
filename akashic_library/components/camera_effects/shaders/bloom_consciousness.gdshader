shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Bloom parameters
uniform float bloom_threshold : hint_range(0.0, 1.0) = 0.8;
uniform float bloom_intensity : hint_range(0.0, 3.0) = 1.0;
uniform vec3 bloom_color : source_color = vec3(0.2, 1.0, 0.2);

// Consciousness parameters
uniform float consciousness_level : hint_range(0.0, 7.0) = 3.0;
uniform float consciousness_pulse : hint_range(0.0, 1.0) = 0.0;

// Optional: Add blur parameters for smoother bloom
uniform int blur_samples : hint_range(4, 16) = 8;
uniform float blur_radius : hint_range(0.0, 2.0) = 0.5;

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 color = texture(SCREEN_TEXTURE, uv);
    
    // Calculate brightness
    float brightness = max(max(color.r, color.g), color.b);
    
    // Add consciousness pulse to bloom
    float pulse = 1.0 + (consciousness_pulse * 0.2 * sin(TIME * 2.0));
    
    // Apply bloom to bright areas
    if (brightness > bloom_threshold) {
        // Calculate bloom factor based on brightness and consciousness
        float bloom_factor = (brightness - bloom_threshold) * bloom_intensity;
        bloom_factor *= (consciousness_level / 7.0) * pulse;
        
        // Add bloom color
        color.rgb += bloom_color * bloom_factor;
        
        // Optional: Add simple blur for smoother bloom
        if (blur_samples > 0) {
            vec4 blur_color = vec4(0.0);
            float total_weight = 0.0;
            
            for (int i = 0; i < blur_samples; i++) {
                float angle = float(i) * (6.28318 / float(blur_samples));
                vec2 offset = vec2(cos(angle), sin(angle)) * blur_radius * (1.0 / SCREEN_PIXEL_SIZE);
                
                vec4 sample_color = texture(SCREEN_TEXTURE, uv + offset);
                float sample_brightness = max(max(sample_color.r, sample_color.g), sample_color.b);
                
                if (sample_brightness > bloom_threshold) {
                    float weight = 1.0 - (float(i) / float(blur_samples));
                    blur_color += sample_color * weight;
                    total_weight += weight;
                }
            }
            
            if (total_weight > 0.0) {
                blur_color /= total_weight;
                color.rgb = mix(color.rgb, blur_color.rgb, 0.5 * bloom_factor);
            }
        }
    }
    
    // Output final color
    COLOR = color;
} 