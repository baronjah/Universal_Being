float pseudo_random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 generate_galaxy(vec2 uv, float swirl_amount, float arm_count, float center_size, float star_density, float star_spacing, float radial_line_count) {
    // Center the UV coordinates
    vec2 centered_uv = uv - 0.5;
    float dist = length(centered_uv);
    float angle = atan(centered_uv.y, centered_uv.x);
    
    // Swirl effect
    float swirl = swirl_amount * (1.0 - dist);
    angle += swirl;
    
    // Galaxy arms
    float arm = fract(angle * arm_count / (6.28318530718)); // 2.0 * PI
    
    // Center and overall shape
    float shape = smoothstep(center_size, 1.0, dist);
    shape *= smoothstep(0.8, 0.2, dist); // Fade out edges
    
    // Combine for basic galaxy structure
    float galaxy = arm * shape;
    
    // Add stars using pseudo-random noise
    float noise = pseudo_random(uv * star_spacing);
    float star = step(1.0 - star_density, noise);
    
    // Add radial lines
    float lines = 0.0;
    if (radial_line_count > 0.0) {
        float normalized_angle = (angle + 3.14159265359) / (6.28318530718);
        lines = step(fract(normalized_angle * radial_line_count), 0.02);
    }
    
    // Combine everything
    float final_galaxy = max(galaxy, star);
    final_galaxy = max(final_galaxy, lines);
    
    // Add some color variation
    vec3 color = vec3(final_galaxy);
    color.r += pseudo_random(uv * 1.1) * 0.1;
    color.g += pseudo_random(uv * 1.2) * 0.1;
    color.b += pseudo_random(uv * 1.3) * 0.1;
    
    return vec4(color, 1.0);
}