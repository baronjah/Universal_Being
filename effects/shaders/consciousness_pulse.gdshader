shader_type spatial;
render_mode unshaded, cull_disabled;

// Universal Being consciousness visualization shader
// Creates a pulsing glow effect that intensifies with consciousness level

uniform float consciousness_level : hint_range(0.0, 5.0) = 1.0;
uniform vec4 consciousness_color : source_color = vec4(0.2, 0.8, 1.0, 1.0);
uniform float pulse_speed : hint_range(0.1, 5.0) = 1.0;
uniform float pulse_intensity : hint_range(0.0, 2.0) = 0.5;

varying vec3 vertex_world_pos;
varying vec3 vertex_normal;

void vertex() {
    vertex_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vertex_normal = NORMAL;
}

void fragment() {
    // Calculate base pulse based on consciousness level
    float base_pulse = sin(TIME * pulse_speed) * 0.5 + 0.5;
    float consciousness_pulse = base_pulse * consciousness_level * pulse_intensity;
    
    // Create radial glow effect
    vec3 view_dir = normalize(vertex_world_pos - CAMERA_MATRIX[3].xyz);
    float fresnel = pow(1.0 - abs(dot(vertex_normal, view_dir)), 2.0);
    
    // Combine effects
    vec4 final_color = consciousness_color;
    final_color.a *= (fresnel + consciousness_pulse) * consciousness_level;
    
    // Apply to albedo and emission
    ALBEDO = final_color.rgb;
    EMISSION = final_color.rgb * consciousness_pulse;
    ALPHA = final_color.a;
} 