//CelestialAsteroidBelt.gdshader
shader_type spatial;
render_mode blend_mix, cull_disabled, unshaded;
uniform float asteroids_density : hint_range(0, 1) = 0.1;
uniform float asteroids_size : hint_range(1, 1024) = 512.0;
uniform vec3 asteroids_color : source_color = vec3(0.3, 0.3, 0.3);
uniform float asteroids_radius : hint_range(0, 0.5) = 0.5;
uniform float u_seed : hint_range(0, 99999999) = 0.003;

// Hash function
float hash(vec2 p, float seed) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(5.3983, 5.4427, 6.9371) + seed);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

// Galaxy generation function
vec4 generate_asteroid_belt(vec2 uv, float asteroids_density_, float circle_radius, float your_seed_value, float asteroids_size_, vec3 star_color) {
    vec2 centered_uv = (floor((uv - 0.5) * asteroids_size_) / asteroids_size_) + 0.5;
    vec2 offset_uv = centered_uv - 0.5;
    float dist = length(offset_uv);
    // Stars
    float asteroids_hash = hash(centered_uv, your_seed_value);
    float asteroids_mask = step(1.0 - asteroids_density_, asteroids_hash);

    // Circular cutouts
    float asteroids_circle_mask = step(dist, 0.5);
	float asteroids_circle_mask2 = step(dist, 0.4);

    // Combine colors
	vec3 asteroid = vec3(0.0);
    vec3 asteroid_color = mix(asteroid, star_color, asteroids_mask * (asteroids_circle_mask - asteroids_circle_mask2));

    float alpha = (asteroids_mask * (asteroids_circle_mask - asteroids_circle_mask2));

    return vec4(asteroid_color, alpha);
}

void fragment() {
    // Generate base galaxy
    vec4 asteroid_belt = generate_asteroid_belt(UV, asteroids_density, asteroids_radius, u_seed, asteroids_size, asteroids_color);

    ALBEDO = asteroid_belt.rgb;
    ALPHA = asteroid_belt.a;
}