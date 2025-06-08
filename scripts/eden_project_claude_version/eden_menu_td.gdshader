// Eden 3D Consciousness Field Shader
// For spatial materials on menu crystals and environment
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Consciousness parameters
uniform float consciousness_level : hint_range(0.0, 5.0, 0.1) = 1.0;
uniform float resonance : hint_range(0.0, 2.0, 0.1) = 1.0;
uniform float time_scale : hint_range(0.1, 3.0, 0.1) = 1.0;
uniform vec3 genesis_point = vec3(0.0, 0.0, 0.0);
uniform vec3 base_color : source_color = vec3(0.3, 0.2, 0.8);
uniform vec3 consciousness_color : source_color = vec3(0.8, 0.6, 1.0);
uniform sampler2D quantum_noise : hint_default_white;
uniform float dissolution_amount : hint_range(0.0, 1.0, 0.01) = 0.0;

// Vertex displacement for living geometry
void vertex() {
    // Get world position for consciousness field calculation
    vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    // Distance from genesis point affects everything
    float genesis_distance = length(world_pos - genesis_point);
    
    // Consciousness waves rippling through space
    float wave = sin(genesis_distance * 10.0 - TIME * time_scale * 3.0);
    wave *= exp(-genesis_distance * 0.3); // Falloff
    
    // Quantum fluctuations
    vec2 noise_uv = world_pos.xz * 0.1 + TIME * 0.05;
    float quantum = texture(quantum_noise, noise_uv).r;
    
    // Vertex breathing with consciousness
    float breath = sin(TIME * time_scale * 2.0 + genesis_distance) * 0.5 + 0.5;
    float displacement = wave * quantum * breath * consciousness_level * 0.1;
    
    // Apply displacement along normal
    VERTEX += NORMAL * displacement * resonance;
    
    // Dissolution effect - vertices scatter when transitioning
    if (dissolution_amount > 0.0) {
        vec3 scatter_dir = normalize(world_pos - genesis_point + vec3(quantum, wave, breath));
        VERTEX += scatter_dir * dissolution_amount * dissolution_amount * 3.0;
    }
}

// Fragment processing for consciousness visualization
void fragment() {
    // Base quantum field texture
    vec2 quantum_uv = UV + TIME * time_scale * 0.02;
    float quantum_field = texture(quantum_noise, quantum_uv).r;
    quantum_field = mix(quantum_field, 1.0 - quantum_field, sin(TIME * time_scale));
    
    // Distance-based consciousness gradient
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    float consciousness_distance = length(world_pos - genesis_point);
    float consciousness_gradient = 1.0 - smoothstep(0.0, 10.0, consciousness_distance);
    
    // Thought pattern generation
    float thought_pattern = sin(UV.x * 20.0 + TIME * time_scale) * sin(UV.y * 20.0 - TIME * time_scale * 0.7);
    thought_pattern = smoothstep(-0.5, 0.5, thought_pattern);
    
    // Combine colors based on consciousness state
    vec3 color = mix(base_color, consciousness_color, consciousness_gradient * consciousness_level * 0.5);
    color = mix(color, vec3(1.0), thought_pattern * resonance * 0.3);
    
    // Edge detection for crystalline structure
    float edge = 1.0 - dot(NORMAL, VIEW);
    edge = pow(edge, 1.5);
    
    // Emission based on consciousness and edge
    vec3 emission = consciousness_color * edge * consciousness_level;
    emission += base_color * quantum_field * resonance * 0.5;
    
    // Dissolution fade
    float alpha = 1.0 - dissolution_amount;
    alpha *= mix(0.7, 1.0, edge); // Edges more visible
    
    // Output
    ALBEDO = color;
    EMISSION = emission * (1.0 + sin(TIME * time_scale * 3.0) * 0.2);
    METALLIC = 0.8 - quantum_field * 0.3;
    ROUGHNESS = 0.2 + thought_pattern * 0.3;
    SPECULAR = 0.5 + consciousness_gradient * 0.3;
    ALPHA = alpha;
    
    // Subsurface scattering for organic feel
    SSS_STRENGTH = consciousness_level * 0.3;
}

// ========================================
// Eden Void Environment Shader
// For the background/skybox
// ========================================
shader_type sky;

uniform float void_consciousness : hint_range(0.0, 1.0, 0.01) = 0.3;
uniform float time_flow : hint_range(0.1, 2.0, 0.1) = 1.0;
uniform vec3 void_base : source_color = vec3(0.02, 0.01, 0.05);
uniform vec3 void_highlight : source_color = vec3(0.15, 0.1, 0.25);
uniform sampler2D star_field : hint_default_black;

void sky() {
    // Normalized direction
    vec3 dir = EYEDIR;
    
    // Quantum foam base pattern
    float foam = sin(dir.x * 50.0 + TIME * time_flow) * sin(dir.y * 50.0 - TIME * time_flow * 0.7) * sin(dir.z * 50.0 + TIME * time_flow * 1.3);
    foam = smoothstep(-0.7, 0.7, foam);
    
    // Consciousness waves across the void
    float wave_1 = sin(length(dir.xz) * 20.0 - TIME * time_flow * 2.0) * 0.5 + 0.5;
    float wave_2 = sin(length(dir.xy) * 15.0 + TIME * time_flow * 1.5) * 0.5 + 0.5;
    float consciousness_wave = wave_1 * wave_2;
    
    // Star field with consciousness modulation
    vec2 star_uv = dir.xz * 0.5 + 0.5;
    float stars = texture(star_field, star_uv + TIME * time_flow * 0.01).r;
    stars *= consciousness_wave;
    
    // Combine void colors
    vec3 color = mix(void_base, void_highlight, foam * void_consciousness);
    color += stars * vec3(0.8, 0.7, 1.0) * void_consciousness;
    
    // Horizon glow where consciousness is strongest
    float horizon = 1.0 - abs(dir.y);
    horizon = pow(horizon, 3.0);
    color += void_highlight * horizon * void_consciousness * 2.0;
    
    COLOR = color;
}

// Notes for shader integration:
// - Apply consciousness field shader to menu crystals
// - Use dissolution_amount for transitions between states
// - genesis_point should track player focus/cursor
// - Sync consciousness_level with game state
// - resonance varies per menu option for unique feel
// - Void environment shader creates living background
// - Both shaders work together to create unified experience