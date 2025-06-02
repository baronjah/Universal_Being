shader_type canvas_item;

// Quantum vision parameters
uniform int reality_layers : hint_range(2, 8) = 4;
uniform float layer_offset : hint_range(0.001, 0.02) = 0.005;
uniform float quantum_frequency : hint_range(1.0, 10.0) = 4.0;

// Consciousness parameters
uniform float consciousness_level : hint_range(0.0, 7.0) = 6.0;
uniform float consciousness_pulse : hint_range(0.0, 1.0) = 0.0;

// Multiple reality parameters
uniform float reality_mix : hint_range(0.0, 1.0) = 0.7;
uniform float probability_wave : hint_range(0.0, 5.0) = 2.0;

// Colors for different reality layers
uniform vec3 reality_color_1 : source_color = vec3(1.0, 0.2, 0.2);
uniform vec3 reality_color_2 : source_color = vec3(0.2, 1.0, 0.2);
uniform vec3 reality_color_3 : source_color = vec3(0.2, 0.2, 1.0);
uniform vec3 reality_color_4 : source_color = vec3(1.0, 1.0, 0.2);

void fragment() {
    vec2 uv = SCREEN_UV;
    
    // Calculate consciousness influence
    float consciousness_factor = (consciousness_level - 5.0) / 2.0;
    
    // Quantum time fluctuation
    float quantum_time = TIME * probability_wave + consciousness_pulse * sin(TIME * 3.0);
    
    // Sample base reality
    vec4 base_color = texture(SCREEN_TEXTURE, uv);
    vec4 final_color = base_color;
    
    // Create multiple reality layers
    vec3[] layer_colors = {reality_color_1, reality_color_2, reality_color_3, reality_color_4};
    
    for (int i = 0; i < reality_layers && i < 4; i++) {
        // Calculate quantum offset for this layer
        float layer_phase = float(i) * 1.57; // 90 degrees per layer
        float wave_x = sin(quantum_time * quantum_frequency + layer_phase) * layer_offset;
        float wave_y = cos(quantum_time * quantum_frequency * 1.3 + layer_phase) * layer_offset;
        
        vec2 quantum_uv = uv + vec2(wave_x, wave_y) * consciousness_factor;
        
        // Sample this reality layer
        vec4 layer_color = texture(SCREEN_TEXTURE, quantum_uv);
        
        // Apply quantum interference pattern
        float interference = sin(uv.x * 100.0 + quantum_time + layer_phase) * 
                           sin(uv.y * 100.0 + quantum_time * 1.2 + layer_phase);
        interference = (interference + 1.0) * 0.5; // Normalize to 0-1
        
        // Calculate probability of this reality
        float probability = 0.5 + 0.3 * sin(quantum_time * 2.0 + float(i));
        probability *= consciousness_factor * interference;
        
        // Tint layer with its quantum color
        layer_color.rgb = mix(layer_color.rgb, layer_color.rgb * layer_colors[i], 0.3);
        
        // Mix with quantum superposition
        final_color.rgb = mix(final_color.rgb, layer_color.rgb, probability * reality_mix);
    }
    
    // Add quantum uncertainty visualization
    if (consciousness_level >= 6.5) {
        // Heisenberg uncertainty principle visualization
        float uncertainty_x = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
        float uncertainty_y = fract(sin(dot(uv + vec2(1.0), vec2(12.9898, 78.233))) * 43758.5453);
        
        vec2 uncertainty = vec2(uncertainty_x, uncertainty_y) * 0.001 * consciousness_factor;
        vec4 uncertain_color = texture(SCREEN_TEXTURE, uv + uncertainty);
        
        final_color.rgb = mix(final_color.rgb, uncertain_color.rgb, 0.1);
    }
    
    // Add quantum tunneling effect - particles appear/disappear randomly
    float tunneling = step(0.995, fract(sin(dot(uv * 1000.0, vec2(12.9898, 78.233))) * 43758.5453));
    tunneling *= consciousness_factor;
    final_color.rgb += vec3(1.0, 0.5, 1.0) * tunneling * 0.2;
    
    // Add wave-particle duality visualization
    float wave_particle = sin(length(uv - vec2(0.5)) * 50.0 - quantum_time * 5.0);
    wave_particle = smoothstep(-0.1, 0.1, wave_particle) * consciousness_factor * 0.1;
    final_color.rgb += vec3(0.5, 0.8, 1.0) * wave_particle;
    
    COLOR = final_color;
}