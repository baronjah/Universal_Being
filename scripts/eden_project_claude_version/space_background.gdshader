// space_background.gdshader
shader_type spatial;
render_mode unshaded, cull_front, depth_test_disabled;

uniform float time_scale : hint_range(0.01, 1.0) = 0.05;
uniform float star_density : hint_range(0.0001, 0.01) = 0.001;
uniform vec3 nebula_color1 : source_color = vec3(0.2, 0.1, 0.4);
uniform vec3 nebula_color2 : source_color = vec3(0.1, 0.2, 0.5);
uniform vec3 nebula_color3 : source_color = vec3(0.3, 0.1, 0.3);
uniform float nebula_scale : hint_range(0.1, 5.0) = 1.0;
uniform float nebula_intensity : hint_range(0.0, 1.0) = 0.3;

// Hash function for procedural generation
float hash(vec3 p) {
    p = fract(p * vec3(443.8975, 397.2973, 491.1871));
    p += dot(p, p.yxz + 19.19);
    return fract((p.x + p.y) * p.z);
}

// 3D Noise
float noise3D(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    return mix(mix(mix(hash(i + vec3(0,0,0)), hash(i + vec3(1,0,0)), f.x),
                   mix(hash(i + vec3(0,1,0)), hash(i + vec3(1,1,0)), f.x), f.y),
               mix(mix(hash(i + vec3(0,0,1)), hash(i + vec3(1,0,1)), f.x),
                   mix(hash(i + vec3(0,1,1)), hash(i + vec3(1,1,1)), f.x), f.y), f.z);
}

// Fractal Brownian Motion for nebula
float fbm(vec3 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < octaves; i++) {
        value += amplitude * noise3D(p * frequency);
        amplitude *= 0.5;
        frequency *= 2.0;
    }

    return value;
}

// Star field generation
float stars(vec3 p) {
    // Multiple layers of stars
    float star_field = 0.0;

    // Bright stars
    vec3 p1 = p * 100.0;
    float bright = smoothstep(0.99, 1.0, hash(floor(p1)));
    star_field += bright;

    // Medium stars
    vec3 p2 = p * 200.0;
    float medium = smoothstep(0.98, 1.0, hash(floor(p2))) * 0.5;
    star_field += medium;

    // Dim stars
    vec3 p3 = p * 500.0;
    float dim = smoothstep(0.97, 1.0, hash(floor(p3))) * 0.3;
    star_field += dim;

    // Twinkling effect
    float twinkle = sin(TIME * 10.0 + hash(floor(p * 100.0)) * 6.28) * 0.5 + 0.5;
    star_field *= (0.8 + twinkle * 0.2);

    return star_field * star_density * 1000.0;
}

// Nebula generation
vec3 nebula(vec3 p, float time) {
    // Animated nebula movement
    vec3 np = p * nebula_scale + vec3(time * 0.1, time * 0.05, time * 0.03);

    // Multiple octaves for detail
    float n1 = fbm(np, 4);
    float n2 = fbm(np * 2.0 + vec3(100), 3);
    float n3 = fbm(np * 4.0 + vec3(200), 2);

    // Combine noise layers
    float nebula_mask = n1 * 0.5 + n2 * 0.3 + n3 * 0.2;
    nebula_mask = smoothstep(0.4, 0.9, nebula_mask);

    // Color variation
    vec3 color = mix(nebula_color1, nebula_color2, n1);
    color = mix(color, nebula_color3, n2 * n3);

    return color * nebula_mask * nebula_intensity;
}

void vertex() {
    // Keep the background sphere large
    POSITION = vec4(VERTEX, 1.0);
}

void fragment() {
    // Get view direction
    vec3 view_dir = normalize((INV_VIEW_MATRIX * vec4(VERTEX, 0.0)).xyz);

    // Base space color (deep void)
    vec3 space_color = vec3(0.02, 0.01, 0.05);

    // Add stars
    float star_brightness = stars(view_dir);
    vec3 star_color = vec3(0.9, 0.95, 1.0) * star_brightness;

    // Add nebula
    vec3 nebula_color = nebula(view_dir, TIME * time_scale);

    // Combine all elements
    vec3 final_color = space_color + star_color + nebula_color;

    // Add subtle color variation
    float color_var = noise3D(view_dir * 10.0);
    final_color += vec3(0.01, 0.02, 0.03) * color_var;

    // Output
    ALBEDO = final_color;
    EMISSION = final_color * 0.5; // Self-illuminated background
}