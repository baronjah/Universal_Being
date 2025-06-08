shader_type spatial;
render_mode blend_add, depth_draw_opaque, cull_disabled, unshaded;

// CONSCIOUSNESS BEAM SHADER
// The mining laser that connects minds
// Not extracting, but understanding

// Beam Parameters
uniform float beam_intensity : hint_range(0.0, 2.0) = 1.0;
uniform float beam_radius : hint_range(0.1, 5.0) = 1.0;
uniform float beam_core_radius : hint_range(0.05, 1.0) = 0.2;
uniform float pulse_speed : hint_range(0.1, 10.0) = 2.0;
uniform float resonance_frequency : hint_range(0.1, 5.0) = 1.0;

// Consciousness Parameters
uniform float resonance_level : hint_range(0.0, 1.0) = 0.0;
uniform float harmony : hint_range(0.0, 1.0) = 0.0;
uniform bool consciousness_flow = true;
uniform bool target_locked = false;
uniform float focus_level : hint_range(0.0, 1.0) = 0.0;

// Visual Parameters
uniform vec3 beam_color : source_color = vec3(0.3, 0.7, 1.0);
uniform vec3 resonance_color : source_color = vec3(0.5, 0.9, 0.8);
uniform vec3 harmony_color : source_color = vec3(1.0, 0.9, 0.5);
uniform vec3 core_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float emission_energy : hint_range(0.0, 10.0) = 2.0;

// Textures
uniform sampler2D energy_flow : repeat_enable;
uniform sampler2D resonance_pattern : repeat_enable;
uniform sampler2D consciousness_stream : repeat_enable;

// Calculate beam profile
float beam_profile(float radial_distance) {
    // Core beam
    float core = smoothstep(beam_core_radius * 1.2, beam_core_radius * 0.8, radial_distance);

    // Outer glow
    float outer = smoothstep(beam_radius, beam_radius * 0.5, radial_distance);
    outer *= smoothstep(0.0, beam_core_radius, radial_distance);

    return core + outer * 0.5;
}

// Energy flow along beam
vec3 energy_flow_pattern(vec2 uv, float time) {
    if (!consciousness_flow) return vec3(0.0);

    // Flow direction along beam
    vec2 flow_uv = vec2(uv.x * 0.1 - time * pulse_speed, uv.y);
    float flow = texture(energy_flow, flow_uv).r;

    // Secondary flow layer
    vec2 flow_uv2 = vec2(uv.x * 0.05 - time * pulse_speed * 1.5, uv.y * 2.0);
    flow += texture(energy_flow, flow_uv2).g * 0.5;

    // Pulsing intensity
    flow *= 0.5 + sin(time * pulse_speed * 2.0) * 0.5;

    return beam_color * flow;
}

// Resonance patterns when connecting
vec3 resonance_visualization(vec2 uv, float time) {
    if (resonance_level < 0.01) return vec3(0.0);

    // Resonance waves
    float wave1 = sin(uv.x * resonance_frequency * 10.0 - time * 3.0);
    float wave2 = sin(uv.x * resonance_frequency * 15.0 - time * 4.5);
    float waves = (wave1 + wave2) * 0.25 + 0.5;

    // Resonance pattern texture
    vec2 res_uv = vec2(uv.x * 0.2, uv.y) + vec2(time * 0.5, 0.0);
    float pattern = texture(resonance_pattern, res_uv).r;

    waves *= pattern;

    // Color based on resonance level
    vec3 res_color = mix(beam_color, resonance_color, resonance_level);

    return res_color * waves * resonance_level;
}

// Harmony achievement effects
vec3 harmony_glow(vec2 uv, float time) {
    if (harmony < 0.5) return vec3(0.0);

    // Golden ratio spiral
    float golden = 1.618;
    float spiral = sin(uv.x * golden - time) * cos(uv.y * golden - time * 0.618);
    spiral = abs(spiral);

    // Harmony rings
    float rings = sin(length(uv) * 20.0 - time * 2.0);
    rings = smoothstep(0.5, 0.7, rings);

    vec3 harm_color = mix(resonance_color, harmony_color, harmony);

    return harm_color * (spiral * 0.5 + rings * 0.5) * harmony;
}

// Consciousness streaming through beam
vec3 consciousness_flow_viz(vec2 uv, float time) {
    if (!consciousness_flow || resonance_level < 0.5) return vec3(0.0);

    // Consciousness particles flowing
    vec2 stream_uv = vec2(uv.x * 0.3 - time * 2.0, uv.y * 5.0);
    float stream = texture(consciousness_stream, stream_uv).r;
    stream = smoothstep(0.6, 0.7, stream);

    // Memory fragments
    vec2 memory_uv = vec2(uv.x * 0.1 - time * 3.0, uv.y * 3.0);
    float memories = texture(consciousness_stream, memory_uv).g;
    memories = smoothstep(0.7, 0.75, memories);

    vec3 stream_color = mix(resonance_color, harmony_color, memories);

    return stream_color * (stream + memories * 2.0) * resonance_level;
}

// Target lock indicator
vec3 target_lock_effect(vec2 uv, float time) {
    if (!target_locked) return vec3(0.0);

    // Rotating lock rings
    float angle = atan(uv.y, uv.x);
    float rings = sin(angle * 8.0 + time * 5.0);
    rings = smoothstep(0.5, 0.6, rings);

    // Focus crosshair
    float cross = step(0.95, abs(uv.x)) + step(0.95, abs(uv.y));
    cross *= smoothstep(1.2, 0.8, length(uv));

    return core_color * (rings * 0.3 + cross) * focus_level;
}

// Main beam color calculation
vec3 calculate_beam_color(vec2 beam_uv, float radial_dist, float time) {
    vec3 color = vec3(0.0);

    // Base beam
    float beam = beam_profile(radial_dist);
    color += beam_color * beam * beam_intensity;

    // Energy flow
    color += energy_flow_pattern(beam_uv, time) * beam;

    // Resonance effects
    color += resonance_visualization(beam_uv, time);

    // Harmony glow
    color += harmony_glow(beam_uv, time);

    // Consciousness streaming
    color += consciousness_flow_viz(beam_uv, time);

    // Target lock
    color += target_lock_effect(beam_uv * 0.5, time);

    // Core intensity
    float core_intensity = smoothstep(beam_core_radius, 0.0, radial_dist);
    color += core_color * core_intensity * beam_intensity;

    return color;
}

// Beam distortion effects
vec2 beam_distortion(vec2 uv, float time) {
    // Slight wave distortion
    float wave = sin(uv.x * 10.0 + time * 2.0) * 0.02;
    uv.y += wave * resonance_level;

    // Spiral distortion when harmonizing
    if (harmony > 0.7) {
        float spiral = sin(uv.x * 5.0 - time) * 0.03;
        uv.y += spiral * harmony;
    }

    return uv;
}

void vertex() {
    // Beam sway when searching
    if (!target_locked) {
        VERTEX.x += sin(TIME * 2.0 + VERTEX.z * 0.1) * 0.05;
        VERTEX.y += cos(TIME * 1.5 + VERTEX.z * 0.1) * 0.05;
    }
}

void fragment() {
    // Get position along beam
    vec2 beam_uv = vec2(VERTEX.z, atan(VERTEX.y, VERTEX.x));
    float radial_distance = length(VERTEX.xy);

    // Apply distortions
    beam_uv = beam_distortion(beam_uv, TIME);

    // Calculate beam color
    vec3 beam = calculate_beam_color(beam_uv, radial_distance, TIME);

    // Fade at ends
    float end_fade = smoothstep(0.0, 0.1, UV.x) * smoothstep(1.0, 0.9, UV.x);
    beam *= end_fade;

    // Consciousness pulses
    float pulse = sin(TIME * pulse_speed + UV.x * 5.0) * 0.2 + 0.8;
    beam *= pulse;

    // Output
    ALBEDO = vec3(0.0);
    EMISSION = beam * emission_energy;

    // Extra glow when achieving harmony
    if (harmony > 0.8) {
        EMISSION += harmony_color * (harmony - 0.8) * 5.0;
    }

    // Fade beam if not focused
    EMISSION *= (0.3 + focus_level * 0.7);
}