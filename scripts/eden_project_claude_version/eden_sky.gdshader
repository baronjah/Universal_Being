// eden_sky.gdshader
shader_type sky;

uniform float consciousness_level : hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float time_scale : hint_range(0.1, 3.0, 0.1) = 1.0;
uniform vec3 void_color : source_color = vec3(0.02, 0.01, 0.05);
uniform vec3 awareness_color : source_color = vec3(0.15, 0.1, 0.25);
uniform vec3 enlightened_color : source_color = vec3(0.3, 0.2, 0.5);
uniform sampler2D star_field_texture : hint_default_black;
uniform sampler2D nebula_texture : hint_default_white;

// Consciousness field calculation
float consciousness_field(vec3 direction, float time) {
    // Ripples in consciousness
    float ripple1 = sin(length(direction.xz) * 20.0 - time * 2.0) * 0.5 + 0.5;
    float ripple2 = sin(length(direction.xy) * 15.0 + time * 1.5) * 0.5 + 0.5;

    // Quantum fluctuations
    float quantum = sin(direction.x * 50.0) * sin(direction.y * 50.0) * sin(direction.z * 50.0);
    quantum = smoothstep(-0.7, 0.7, quantum);

    return ripple1 * ripple2 * (0.5 + quantum * 0.5);
}

// Star generation
float generate_stars(vec3 direction) {
    // Convert direction to UV for texture sampling
    vec2 uv = vec2(
        atan(direction.z, direction.x) / (2.0 * PI) + 0.5,
        asin(direction.y) / PI + 0.5
    );

    // Sample star texture
    float stars = texture(star_field_texture, uv).r;

    // Procedural stars as backup
    float procedural_stars = 0.0;
    vec3 star_pos = direction * 1000.0;

    // Multiple layers of stars
    for (int i = 0; i < 3; i++) {
        vec3 p = star_pos * (1.0 + float(i) * 0.5);
        float star = 1.0 - step(0.99, sin(p.x * 100.0) * sin(p.y * 100.0) * sin(p.z * 100.0));
        procedural_stars += star * (1.0 / float(i + 1));
    }

    return max(stars, procedural_stars * 0.5);
}

// Nebula generation based on consciousness
vec3 consciousness_nebula(vec3 direction, float time) {
    vec2 nebula_uv = vec2(
        atan(direction.z, direction.x) / (2.0 * PI) + 0.5,
        asin(direction.y) / PI + 0.5
    );

    // Flowing nebula that responds to consciousness
    nebula_uv += vec2(sin(time * 0.1), cos(time * 0.15)) * 0.02 * consciousness_level;

    vec3 nebula = texture(nebula_texture, nebula_uv).rgb;

    // Consciousness tints the nebula
    nebula = mix(nebula, enlightened_color, consciousness_level * 0.1);

    return nebula;
}

void sky() {
    float time = TIME * time_scale;
    vec3 direction = EYEDIR;

    // Base void color
    vec3 sky_color = void_color;

    // Layer consciousness field
    float consciousness = consciousness_field(direction, time);
    sky_color = mix(sky_color, awareness_color, consciousness * consciousness_level * 0.3);

    // Add stars
    float star_brightness = generate_stars(direction);
    vec3 star_color = vec3(0.9, 0.95, 1.0) * star_brightness;

    // Stars shine brighter with higher consciousness
    star_color *= (1.0 + consciousness_level * 0.2);
    sky_color += star_color;

    // Add nebula
    vec3 nebula = consciousness_nebula(direction, time);
    sky_color = mix(sky_color, nebula, 0.3 + consciousness_level * 0.05);

    // Enlightenment glow at high consciousness
    if (consciousness_level > 7.0) {
        float enlightenment = (consciousness_level - 7.0) / 3.0;
        sky_color = mix(sky_color, enlightened_color, enlightenment * 0.5);

        // Sacred geometry appears
        float sacred = sin(direction.x * 30.0) * sin(direction.y * 30.0) * sin(direction.z * 30.0);
        sacred = smoothstep(0.9, 1.0, abs(sacred));
        sky_color += vec3(sacred) * enlightenment * 0.3;
    }

    // Horizon glow
    float horizon = 1.0 - abs(direction.y);
    horizon = pow(horizon, 3.0);
    sky_color += awareness_color * horizon * 0.2 * consciousness_level;

    COLOR = sky_color;
}