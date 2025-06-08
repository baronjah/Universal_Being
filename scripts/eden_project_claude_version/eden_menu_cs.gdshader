// Eden Menu Background Shader
// Visualizing the quantum foam of possibility
shader_type canvas_item;

uniform float consciousness_level : hint_range(0.0, 3.0) = 1.0;
uniform float time_scale : hint_range(0.1, 2.0) = 1.0;
uniform vec2 genesis_point = vec2(0.5, 0.5);
uniform sampler2D noise_texture;

// The breathing of creation
float breathing(float time) {
    return sin(time * 2.0) * 0.5 + 0.5;
}

// Fractal consciousness patterns
float consciousness_field(vec2 uv, float time) {
    vec2 pos = uv - genesis_point;
    float dist = length(pos);
    
    // Ripples of thought
    float ripple = sin(dist * 20.0 - time * 3.0) * 0.5 + 0.5;
    ripple *= exp(-dist * 2.0);
    
    // Quantum fluctuations
    float quantum = texture(noise_texture, uv + vec2(time * 0.05)).r;
    quantum = mix(quantum, 1.0 - quantum, breathing(time));
    
    // Consciousness waves
    float wave = sin(uv.x * 10.0 + time) * sin(uv.y * 10.0 + time * 1.3);
    wave = wave * 0.5 + 0.5;
    
    return mix(ripple, wave, quantum) * consciousness_level;
}

// The void between thoughts
vec3 void_color(vec2 uv, float field) {
    vec3 deep_void = vec3(0.02, 0.01, 0.05);
    vec3 conscious_glow = vec3(0.3, 0.1, 0.5);
    vec3 transcendent = vec3(0.8, 0.6, 1.0);
    
    // Layer the consciousness levels
    vec3 color = mix(deep_void, conscious_glow, field);
    
    // At higher consciousness, reality shifts
    if (consciousness_level > 1.5) {
        color = mix(color, transcendent, (consciousness_level - 1.5) * 0.5);
    }
    
    // Breathing light
    float breath = breathing(TIME * time_scale);
    color += vec3(0.1, 0.05, 0.15) * breath * field;
    
    return color;
}

void fragment() {
    vec2 uv = UV;
    float time = TIME * time_scale;
    
    // Generate consciousness field
    float field = consciousness_field(uv, time);
    
    // Apply void coloring
    vec3 final_color = void_color(uv, field);
    
    // Edge of reality distortion
    float edge_dist = min(
        min(uv.x, 1.0 - uv.x),
        min(uv.y, 1.0 - uv.y)
    );
    
    // Fade at boundaries of perception
    float edge_fade = smoothstep(0.0, 0.1, edge_dist);
    final_color *= edge_fade;
    
    // Alpha based on consciousness
    float alpha = mix(0.95, 0.7, consciousness_level / 3.0);
    
    COLOR = vec4(final_color, alpha);
}

// Notes for shader integration:
// - Apply to a ColorRect behind the menu
// - consciousness_level should sync with menu state
// - genesis_point can follow mouse for interactivity
// - noise_texture should be a seamless noise image
// - Adjust time_scale for different menu states
// - Consider adding uniform for color themes per state