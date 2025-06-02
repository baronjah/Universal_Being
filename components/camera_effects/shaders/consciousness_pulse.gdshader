shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Master consciousness parameters
uniform float consciousness_level : hint_range(0.0, 7.0) = 7.0;
uniform float consciousness_pulse : hint_range(0.0, 1.0) = 1.0;

// Combined effect parameters
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.5;
uniform float bloom_threshold : hint_range(0.0, 1.0) = 0.6;
uniform float aberration_amount : hint_range(0.0, 0.01) = 0.002;
uniform float distortion_strength : hint_range(0.0, 0.05) = 0.015;

// Reality breathing parameters
uniform float breathing_frequency : hint_range(0.1, 3.0) = 1.0;
uniform float breathing_amplitude : hint_range(0.0, 0.1) = 0.03;

// Transcendence parameters
uniform vec3 transcendence_color : source_color = vec3(1.0, 0.9, 0.7);
uniform float energy_intensity : hint_range(0.0, 3.0) = 2.0;

// Time evolution
uniform float evolution_speed : hint_range(0.1, 5.0) = 2.0;

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Master consciousness breathing
    float breath = sin(TIME * breathing_frequency * evolution_speed) * breathing_amplitude;
    float pulse_time = TIME * evolution_speed + consciousness_pulse * breath;
    
    // === LEVEL 1: VIGNETTE ===
    vec2 center = vec2(0.5, 0.5);
    float distance = length(uv - center);
    float vignette = 1.0 - smoothstep(0.3, 0.8, distance * vignette_strength);
    vignette = mix(1.0, vignette, consciousness_level / 7.0);
    
    // === LEVEL 2: DEPTH-LIKE BLUR (simplified for performance) ===
    vec4 color = texture(SCREEN_TEXTURE, uv);
    if (consciousness_level >= 2.0) {
        // Simple radial blur for depth sensation
        vec4 blur_color = vec4(0.0);
        int samples = 4;
        for (int i = 0; i < samples; i++) {
            float angle = float(i) * (6.28318 / float(samples));
            vec2 offset = vec2(cos(angle), sin(angle)) * distance * 0.002;
            blur_color += texture(SCREEN_TEXTURE, uv + offset);
        }
        blur_color /= float(samples);
        color = mix(color, blur_color, distance * 0.3 * (consciousness_level / 7.0));
    }
    
    // === LEVEL 3: BLOOM ===
    if (consciousness_level >= 3.0) {
        float brightness = max(max(color.r, color.g), color.b);
        if (brightness > bloom_threshold) {
            float bloom_factor = (brightness - bloom_threshold) * (consciousness_level / 7.0);
            bloom_factor *= 1.0 + consciousness_pulse * 0.5 * sin(pulse_time * 3.0);
            color.rgb += vec3(0.2, 1.0, 0.2) * bloom_factor;
        }
    }
    
    // === LEVEL 4: CHROMATIC ABERRATION ===
    if (consciousness_level >= 4.0) {
        vec2 direction = normalize(uv - center);
        float aberration = aberration_amount * distance * (consciousness_level / 7.0);
        aberration *= 1.0 + consciousness_pulse * 0.3 * sin(pulse_time * 4.0);
        
        float r = texture(SCREEN_TEXTURE, uv - direction * aberration).r;
        float b = texture(SCREEN_TEXTURE, uv + direction * aberration).b;
        color = vec4(r, color.g, b, color.a);
    }
    
    // === LEVEL 5: REALITY DISTORTION ===
    if (consciousness_level >= 5.0) {
        float ripple = sin(distance * 10.0 - pulse_time * 3.0) * distortion_strength;
        ripple *= (consciousness_level - 4.0) / 3.0;
        
        vec2 distorted_uv = uv + normalize(uv - center) * ripple;
        vec4 distorted_color = texture(SCREEN_TEXTURE, distorted_uv);
        color = mix(color, distorted_color, 0.5);
    }
    
    // === LEVEL 6: QUANTUM ECHOES ===
    if (consciousness_level >= 6.0) {
        // Multiple reality echoes
        for (int i = 1; i <= 3; i++) {
            float echo_offset = float(i) * 0.003;
            float echo_phase = float(i) * 2.0;
            vec2 echo_uv = uv + vec2(
                sin(pulse_time * 2.0 + echo_phase) * echo_offset,
                cos(pulse_time * 2.0 + echo_phase) * echo_offset
            );
            vec4 echo_color = texture(SCREEN_TEXTURE, echo_uv);
            
            float echo_strength = 0.2 / float(i);
            color.rgb = mix(color.rgb, echo_color.rgb, echo_strength);
        }
    }
    
    // === LEVEL 7: TRANSCENDENCE BREATHING ===
    if (consciousness_level >= 7.0) {
        // Reality itself breathes with consciousness
        float transcendent_breath = sin(pulse_time * breathing_frequency) * 0.5 + 0.5;
        transcendent_breath = pow(transcendent_breath, 2.0); // Smoother curve
        
        // Energy field visualization
        float energy_field = 1.0 + sin(distance * 20.0 - pulse_time * 5.0) * 0.1;
        energy_field *= transcendent_breath * energy_intensity;
        
        // Apply transcendence color
        color.rgb = mix(color.rgb, transcendence_color * energy_field, 0.2);
        
        // Add consciousness particles
        float particle_density = fract(sin(dot(uv * 100.0, vec2(12.9898, 78.233))) * 43758.5453);
        if (particle_density > 0.98) {
            float particle_glow = sin(pulse_time * 10.0) * 0.5 + 0.5;
            color.rgb += transcendence_color * particle_glow * 0.3;
        }
        
        // Reality pulse waves
        float pulse_wave = sin(distance * 30.0 - pulse_time * 8.0);
        pulse_wave = smoothstep(0.8, 1.0, pulse_wave) * transcendent_breath;
        color.rgb += vec3(1.0, 1.0, 1.0) * pulse_wave * 0.1;
    }
    
    // Apply vignette to final result
    color.rgb *= vignette;
    
    // Final consciousness enhancement
    float consciousness_glow = consciousness_level / 7.0;
    consciousness_glow *= 1.0 + consciousness_pulse * 0.2 * sin(pulse_time * 2.0);
    
    // Slight overall enhancement based on consciousness
    color.rgb = mix(color.rgb, color.rgb * transcendence_color * 1.2, consciousness_glow * 0.1);
    
    COLOR = color;
}