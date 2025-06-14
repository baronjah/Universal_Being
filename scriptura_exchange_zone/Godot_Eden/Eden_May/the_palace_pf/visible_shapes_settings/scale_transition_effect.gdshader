shader_type spatial;

// Scale transition parameters
uniform float transition_progress : hint_range(0.0, 1.0) = 0.0;
uniform vec3 from_scale_color : source_color = vec3(0.2, 0.6, 0.9); // Blue - human scale
uniform vec3 to_scale_color : source_color = vec3(0.9, 0.5, 0.9);   // Pink - quantum scale
uniform int transition_type = 0; // 0 = up scale (bigger), 1 = down scale (smaller)
uniform float time_dilation : hint_range(0.1, 5.0) = 1.0;
uniform float distortion_strength : hint_range(0.0, 1.0) = 0.3;
uniform sampler2D noise_texture;

// Spatial distortion parameters
uniform float wave_speed = 3.0;
uniform float wave_amplitude = 0.3;
uniform float fractal_noise_scale = 3.0;
uniform float fractal_noise_strength = 0.2;

void vertex() {
    // Only apply distortion during transition
    if (transition_progress > 0.0 && transition_progress < 1.0) {
        // Create transition bell curve (stronger in the middle of transition)
        float peak_factor = sin(transition_progress * 3.14159) * distortion_strength;
        
        // Different distortion based on scale direction
        if (transition_type == 0) { // Upscaling (zooming out)
            // Expansion effect (vertices move outward)
            vec3 normal_direction = normalize(VERTEX);
            VERTEX += normal_direction * peak_factor * 0.5;
            
            // Add wave distortion
            float wave = sin(TIME * wave_speed + VERTEX.x * 2.0 + VERTEX.y * 3.0 + VERTEX.z * 1.5) * wave_amplitude;
            VERTEX *= 1.0 + wave * peak_factor * 0.1;
            
        } else { // Downscaling (zooming in)
            // Contraction with fractal noise
            vec3 noise_sample = vec3(
                sin(VERTEX.x * fractal_noise_scale + TIME),
                sin(VERTEX.y * fractal_noise_scale + TIME * 0.7),
                sin(VERTEX.z * fractal_noise_scale + TIME * 1.3)
            );
            
            // Detailed vertex displacement
            VERTEX += noise_sample * peak_factor * fractal_noise_strength;
            
            // Subtle pulsing
            float pulse = sin(TIME * wave_speed * 2.0) * 0.5 + 0.5;
            VERTEX *= 1.0 + pulse * peak_factor * 0.05;
        }
    }
}

void fragment() {
    // Base color from scale colors
    vec3 color = mix(from_scale_color, to_scale_color, transition_progress);
    
    // Apply time dilation visual effect (edge glow during transition)
    if (transition_progress > 0.0 && transition_progress < 1.0) {
        // Create edge detection effect
        float fresnel = pow(1.0 - dot(NORMAL, VIEW), 3.0);
        
        // Add ripple effect
        float ripple_time = TIME * time_dilation;
        float ripple = sin((fresnel * 10.0 - ripple_time * 2.0) * 3.14159) * 0.5 + 0.5;
        
        // Apply to color
        float transition_intensity = sin(transition_progress * 3.14159);
        color += ripple * transition_intensity * 0.5;
        
        // Scale-specific effects
        if (transition_type == 0) { // Upscaling (to larger scale)
            // Add atmospheric scattering-like effect
            color = mix(color, vec3(0.6, 0.8, 1.0), fresnel * transition_intensity * 0.3);
        } else { // Downscaling (to smaller scale)
            // Add quantum fluctuation-like effect
            float quantum_flicker = fract(sin(dot(FRAGCOORD.xy, vec2(12.9898, 78.233)) * ripple_time) * 43758.5453);
            color = mix(color, color * (0.8 + quantum_flicker * 0.4), transition_intensity * 0.4);
        }
    }
    
    // Apply the final color
    ALBEDO = color;
    
    // Adjust other material properties during transition
    float transition_factor = sin(transition_progress * 3.14159);
    
    // Increase emission during transition
    EMISSION = color * transition_factor * 0.8;
    
    // Adjust metallic and roughness based on scale
    if (transition_type == 0) { // Upscaling (larger scale - more atmospheric)
        METALLIC = mix(0.1, 0.0, transition_progress);
        ROUGHNESS = mix(0.7, 0.9, transition_progress);
        SPECULAR = mix(0.5, 0.2, transition_progress);
    } else { // Downscaling (smaller scale - more reflective/quantum)
        METALLIC = mix(0.1, 0.4, transition_progress);
        ROUGHNESS = mix(0.7, 0.3, transition_progress);
        SPECULAR = mix(0.5, 0.8, transition_progress);
    }
}