float pseudo_random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 generate_galaxy3(vec2 uv, float swirl_amount, float arm_count, float center_size, float star_density, float star_spacing, float radial_line_count, 
                     vec3 galaxy_color, vec3 space_color, vec3 inner_star_color, vec3 outer_star_color, float color_band_sharpness, float inner_star_radius, float radial_line_width, vec3 radial_line_color) {
    // Center the UV coordinates
    vec2 centered_uv = uv - 0.5;
    float dist = length(centered_uv);
    float angle = atan(centered_uv.y, centered_uv.x);
    
    // Swirl effect
    float swirl = swirl_amount * (1.0 - dist);
    angle += swirl;
    
    // Galaxy arms
    float arm = fract(angle * arm_count / (6.28318530718)); // 2.0 * PI
    
    // Color bands
    float color_band = step(0.5, fract(arm * 2.0 + 0.25));
    color_band = mix(arm, color_band, color_band_sharpness);
    
    // Center and overall shape
    float shape = smoothstep(center_size, 1.0, dist);
    shape *= smoothstep(0.8, 0.2, dist); // Fade out edges
    
    // Combine for basic galaxy structure
    float galaxy_mask = arm * shape;
    
    // Add stars using pseudo-random noise
    float noise = pseudo_random(uv * star_spacing);
    float inner_star = step(1.0 - star_density, noise) * step(dist, inner_star_radius);
    float outer_star = step(1.0 - star_density * 0.5, noise) * step(inner_star_radius, dist);
    
    // Add radial lines
    float lines = 0.0;
    if (radial_line_count > 0.0) {
        float normalized_angle = (angle + 3.14159265359) / (6.28318530718);
        lines = step(fract(normalized_angle * radial_line_count), radial_line_width);
    }
    
    // Combine colors
    vec3 galaxy_arm_color = mix(galaxy_color, galaxy_color * 1.5, color_band);
    vec3 final_color = mix(space_color, galaxy_arm_color, galaxy_mask);
    final_color = mix(final_color, inner_star_color, inner_star * (1.0 - galaxy_mask));
    final_color = mix(final_color, outer_star_color, outer_star);
    final_color = mix(final_color, radial_line_color, lines); // Add lines with custom color
    
    return vec4(final_color, 1.0);
}