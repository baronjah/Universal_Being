float hash(vec2 p, float seed) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(5.3983, 5.4427, 6.9371) + seed);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

vec4 generate_galaxy4(vec2 uv, float swirl_amount, float arm_count, float arm_width, float star_density, float star_size, vec3 arm_color, vec3 space_color, vec3 star_color, float circle_radius, vec3 background_color, float your_seed_value) {
    vec2 centered_uv = (floor((uv - 0.5) * star_size) / star_size) + 0.5;
	vec2 offset_uv = centered_uv - 0.5;
    float dist = length(offset_uv);
    float angle = atan(offset_uv.y, offset_uv.x);
    
    // Swirl effect
    float swirl = swirl_amount * (1.0 - dist);
    angle += swirl;
    
    // Galaxy arms
    float arm_angle = fract(angle * arm_count / (2.0 * 3.14159265359));
    float arm_mask = step(arm_width, arm_angle);
    
    // Stars
    vec2 star_uv = floor(uv * star_size) / star_size;
    float star_hash = hash(centered_uv, your_seed_value);
    float star_mask = step(1.0 - star_density, star_hash) * arm_mask;
    
    // Circular cutout
    float circle_mask = step(dist, circle_radius);
    
    // Combine colors
    vec3 galaxy_color = mix(space_color, arm_color, arm_mask);
    
    // Apply star color only within the circular cutout
    galaxy_color = mix(galaxy_color, star_color, star_mask * circle_mask);
    
    vec3 final_color = mix(background_color, galaxy_color, circle_mask);
    
    return vec4(final_color, 1.0);
}