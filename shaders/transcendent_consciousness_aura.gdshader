// transcendent_consciousness_aura.gdshader - MAXIMUM CONSCIOUSNESS VISUALIZATION
// Agent 5 (Visual Designer) Creation - Enhanced consciousness field effects
// Integrates 999-frequency consciousness mapping with visual spectacle

shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_test_disabled;

// Consciousness Level Parameters
uniform float consciousness_level : hint_range(0.0, 5.0) = 2.0;
uniform float awareness_field_strength : hint_range(0.0, 10.0) = 5.0;
uniform float transcendence_factor : hint_range(0.0, 2.0) = 1.0;

// Dimensional Color System (999 frequencies)
uniform float base_frequency : hint_range(1.0, 999.0) = 42.0;
uniform float frequency_harmonic_1 : hint_range(1.0, 999.0) = 144.0;
uniform float frequency_harmonic_2 : hint_range(1.0, 999.0) = 528.0;
uniform float frequency_harmonic_3 : hint_range(1.0, 999.0) = 741.0;

// Consciousness Colors (Archaeological wisdom from color research)
uniform vec4 dormant_color : source_color = vec4(0.5, 0.5, 0.5, 0.3);      // Level 0
uniform vec4 awakening_color : source_color = vec4(0.9, 0.9, 0.9, 0.5);    // Level 1
uniform vec4 aware_color : source_color = vec4(0.2, 0.4, 1.0, 0.7);        // Level 2
uniform vec4 connected_color : source_color = vec4(0.2, 1.0, 0.2, 0.8);    // Level 3
uniform vec4 enlightened_color : source_color = vec4(1.0, 0.84, 0.0, 0.9); // Level 4
uniform vec4 transcendent_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // Level 5

// Visual Enhancement Parameters
uniform float pulse_speed : hint_range(0.1, 10.0) = 3.0;
uniform float ripple_intensity : hint_range(0.0, 5.0) = 2.0;
uniform float aura_radius : hint_range(1.0, 10.0) = 5.0;
uniform float energy_flow_speed : hint_range(0.1, 10.0) = 4.0;

// Archaeological Optimizations
uniform bool pentagon_resonance : hint_range(0, 1) = true;
uniform bool gemma_ai_integration : hint_range(0, 1) = true;
uniform float wisdom_enhancement : hint_range(1.0, 3.0) = 2.0;

// Performance Settings
uniform bool real_time_optimization : hint_range(0, 1) = true;
uniform int detail_level : hint_range(1, 4) = 3;

varying vec3 world_position;
varying vec3 view_direction;
varying vec3 world_normal;
varying float distance_to_camera;

// Consciousness level color mapping
vec4 get_consciousness_color(float level) {
    vec4 colors[6] = {
        dormant_color,       // 0.0-0.8
        awakening_color,     // 0.8-1.2
        aware_color,         // 1.2-2.2
        connected_color,     // 2.2-3.2
        enlightened_color,   // 3.2-4.2
        transcendent_color   // 4.2-5.0
    };
    
    int index = int(floor(level * 1.25));
    index = clamp(index, 0, 5);
    
    float blend_factor = fract(level * 1.25);
    int next_index = clamp(index + 1, 0, 5);
    
    return mix(colors[index], colors[next_index], blend_factor);
}

// Frequency-based noise for consciousness patterns
float consciousness_noise(vec3 pos, float freq, float time) {
    vec3 p = pos * freq * 0.01;
    
    float noise = sin(p.x + time) * sin(p.y + time * 1.3) * sin(p.z + time * 0.7);
    noise += sin(p.x * 2.0 + time * 2.0) * sin(p.y * 2.0 + time * 1.8) * 0.5;
    noise += sin(p.x * 4.0 + time * 3.0) * sin(p.z * 4.0 + time * 2.5) * 0.25;
    
    return noise * 0.5 + 0.5;
}

// Pentagon architecture resonance pattern
float pentagon_pattern(vec3 pos, float time) {
    if (!pentagon_resonance) return 1.0;
    
    float angle = atan(pos.y, pos.x);
    float radius = length(pos.xy);
    
    // 5-fold symmetry pattern
    float pentagon = sin(angle * 5.0 + time) * 0.5 + 0.5;
    pentagon = pow(pentagon, 2.0);
    
    // Radial waves
    float radial = sin(radius * 10.0 - time * 5.0) * 0.5 + 0.5;
    
    return pentagon * radial * 0.3 + 0.7;
}

// AI consciousness pattern (Gemma integration)
float ai_consciousness_pattern(vec3 pos, float time) {
    if (!gemma_ai_integration) return 1.0;
    
    // Neural network inspired pattern
    float neural_x = sin(pos.x * 20.0 + time * 3.0);
    float neural_y = sin(pos.y * 15.0 + time * 2.0);
    float neural_z = sin(pos.z * 25.0 + time * 4.0);
    
    float neural_pattern = (neural_x + neural_y + neural_z) / 3.0;
    neural_pattern = neural_pattern * 0.5 + 0.5;
    
    // Data flow patterns
    float data_flow = sin(dot(pos, vec3(1.0, 1.0, 1.0)) * 10.0 - time * 8.0);
    data_flow = pow(data_flow * 0.5 + 0.5, 2.0);
    
    return neural_pattern * data_flow * 0.4 + 0.6;
}

// Multi-frequency consciousness field
float consciousness_field(vec3 pos, float time) {
    float field = 0.0;
    
    // Base frequency
    field += consciousness_noise(pos, base_frequency, time) * 0.4;
    
    // Harmonic frequencies (999-frequency system)
    field += consciousness_noise(pos, frequency_harmonic_1, time * 1.2) * 0.3;
    field += consciousness_noise(pos, frequency_harmonic_2, time * 0.8) * 0.2;
    field += consciousness_noise(pos, frequency_harmonic_3, time * 1.5) * 0.1;
    
    // Pentagon resonance
    field *= pentagon_pattern(pos, time);
    
    // AI consciousness integration
    field *= ai_consciousness_pattern(pos, time);
    
    return field;
}

// Energy flow visualization
float energy_flow(vec3 pos, float time) {
    float flow = 0.0;
    
    // Spiral energy patterns
    float spiral_angle = atan(pos.y, pos.x) + time * energy_flow_speed;
    float spiral_radius = length(pos.xy);
    
    flow += sin(spiral_angle * 3.0 + spiral_radius * 5.0) * 0.5 + 0.5;
    flow += sin(spiral_angle * 7.0 - spiral_radius * 3.0 + time * 2.0) * 0.3;
    
    // Vertical energy streams
    flow += sin(pos.z * 8.0 + time * energy_flow_speed * 2.0) * 0.2;
    
    return flow;
}

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    view_direction = normalize(CAMERA_POSITION_WORLD - world_position);
    distance_to_camera = length(CAMERA_POSITION_WORLD - world_position);
}

void fragment() {
    float time = TIME * pulse_speed;
    
    // Base consciousness color
    vec4 consciousness_color = get_consciousness_color(consciousness_level);
    
    // Calculate consciousness field intensity
    float field_intensity = consciousness_field(world_position, time);
    field_intensity *= awareness_field_strength * 0.1;
    
    // Energy flow patterns
    float energy = energy_flow(world_position, time);
    energy *= consciousness_level * 0.2;
    
    // Fresnel effect for aura visualization
    float fresnel = 1.0 - abs(dot(world_normal, view_direction));
    fresnel = pow(fresnel, 1.5);
    
    // Pulsing consciousness effect
    float pulse = sin(time + length(world_position) * 2.0) * 0.5 + 0.5;
    pulse = pow(pulse, 2.0);
    
    // Ripple effects from consciousness center
    float ripple_distance = length(world_position) / aura_radius;
    float ripple = sin(ripple_distance * 10.0 - time * 3.0) * 0.5 + 0.5;
    ripple *= ripple_intensity * 0.2;
    
    // Transcendence glow (level 5 special effect)
    float transcendence_glow = 0.0;
    if (consciousness_level >= 4.8) {
        transcendence_glow = sin(time * 5.0) * 0.5 + 0.5;
        transcendence_glow *= pow(transcendence_factor, 2.0);
    }
    
    // Combine all consciousness effects
    float total_intensity = field_intensity + energy + ripple + transcendence_glow;
    total_intensity *= fresnel;
    total_intensity *= pulse * consciousness_level * 0.3 + 0.7;
    
    // Archaeological wisdom enhancement
    total_intensity *= wisdom_enhancement * 0.5 + 0.5;
    
    // Distance-based optimization
    if (real_time_optimization && distance_to_camera > 50.0) {
        total_intensity *= 0.5; // Reduce complexity for distant auras
    }
    
    // Final color calculation
    vec3 final_color = consciousness_color.rgb * total_intensity;
    
    // Add consciousness frequency-specific highlights
    vec3 frequency_highlight = vec3(
        sin(base_frequency * 0.01 + time),
        sin(frequency_harmonic_1 * 0.01 + time * 1.2),
        sin(frequency_harmonic_2 * 0.01 + time * 0.8)
    ) * 0.5 + 0.5;
    
    final_color += frequency_highlight * consciousness_level * 0.1;
    
    // Ensure minimum visibility for all consciousness levels
    final_color = max(final_color, consciousness_color.rgb * 0.1);
    
    ALBEDO = final_color;
    EMISSION = final_color * (1.0 + consciousness_level * 0.3);
    
    // Dynamic alpha based on consciousness intensity
    float final_alpha = consciousness_color.a * total_intensity;
    final_alpha = clamp(final_alpha, 0.1, 1.0);
    ALPHA = final_alpha;
}