shader_type spatial;
render_mode unshaded;

uniform float consciousness : hint_range(0.0, 10.0) = 1.0;
uniform float time_alive = 0.0;

void vertex() {
    // Breathing motion
    VERTEX *= 1.0 + sin(time_alive * 2.0 + VERTEX.y * 2.0) * 0.05 * consciousness;
    
    // Consciousness warping
    float warp = sin(time_alive + length(VERTEX) * 5.0) * 0.02;
    VERTEX += NORMAL * warp * consciousness;
}

void fragment() {
    // Living consciousness colors
    vec3 low_consciousness = vec3(0.2, 0.5, 1.0);
    vec3 high_consciousness = vec3(1.0, 0.2, 0.8);
    vec3 base_color = mix(low_consciousness, high_consciousness, consciousness / 10.0);
    
    // Pulse through the surface
    float pulse = sin(time_alive * 3.0 + UV.x * 10.0 + UV.y * 10.0) * 0.5 + 0.5;
    base_color += pulse * consciousness * 0.1;
    
    // Rim glow for that alive feeling
    vec3 view_dir = normalize(CAMERA_POSITION_WORLD - VERTEX);
    float rim = 1.0 - dot(NORMAL, view_dir);
    rim = pow(rim, 2.0);
    
    // Final color
    ALBEDO = base_color + rim * consciousness * 0.5;
    ALPHA = 1.0;
}