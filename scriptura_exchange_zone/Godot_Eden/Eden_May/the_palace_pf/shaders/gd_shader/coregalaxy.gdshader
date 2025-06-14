//coregalaxy.gdshader
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded;

uniform vec3 u_galaxy_color : source_color = vec3(0.5, 0.5, 1.0);
uniform float u_core_size : hint_range(0.0, 1.0) = 0.5;
uniform float u_star_size : hint_range(1, 2048) = 2048.0;

void vertex() {
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
    // Convert UV to centered coordinates
    vec2 centered_uv = UV * 2.0 - 1.0;
    
    // Calculate distance from center
    float dist = length(centered_uv);
    
    // Create circular gradient
    float circle = 1.0 - smoothstep(u_core_size * 0.8, u_core_size, dist);
    
    // Apply color and fade out edges
    vec3 core_color = u_galaxy_color * circle;
    
    // Adjust alpha based on distance and star size
    float alpha = circle * smoothstep(1.0, 0.0, dist / (u_star_size / 1024.0));
    
    ALBEDO = core_color;
    ALPHA = alpha;
}