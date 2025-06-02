shader_type spatial;
render_mode unshaded, cull_disabled, blend_add;

// Universal Being component visualization shader
// Creates a marching cubes style glow effect for component data visualization

uniform vec4 component_color : source_color = vec4(0.4, 0.8, 1.0, 1.0);
uniform float noise_scale : hint_range(0.1, 10.0) = 2.0;
uniform float glow_intensity : hint_range(0.0, 5.0) = 1.0;
uniform float time_scale : hint_range(0.1, 5.0) = 1.0;
uniform float component_density : hint_range(0.0, 1.0) = 0.5;

varying vec3 vertex_world_pos;
varying vec3 vertex_normal;

// Simple noise function for marching cubes effect
float noise(vec3 p) {
    vec3 i = floor(p);
    vec3 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    
    float n = i.x + i.y * 157.0 + 113.0 * i.z;
    return mix(
        mix(
            mix(sin(n + 0.0), sin(n + 1.0), f.x),
            mix(sin(n + 157.0), sin(n + 158.0), f.x),
            f.y
        ),
        mix(
            mix(sin(n + 113.0), sin(n + 114.0), f.x),
            mix(sin(n + 270.0), sin(n + 271.0), f.x),
            f.y
        ),
        f.z
    ) * 0.5 + 0.5;
}

void vertex() {
    vertex_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vertex_normal = NORMAL;
}

void fragment() {
    // Create animated noise field
    vec3 noise_pos = vertex_world_pos * noise_scale + vec3(TIME * time_scale);
    float noise_val = noise(noise_pos);
    
    // Create marching cubes style effect
    float density = smoothstep(component_density - 0.1, component_density + 0.1, noise_val);
    
    // Add fresnel effect for edge glow
    vec3 view_dir = normalize(vertex_world_pos - CAMERA_MATRIX[3].xyz);
    float fresnel = pow(1.0 - abs(dot(vertex_normal, view_dir)), 3.0);
    
    // Combine effects
    vec4 final_color = component_color;
    final_color.a *= density * (fresnel + glow_intensity);
    
    // Apply to albedo and emission
    ALBEDO = final_color.rgb;
    EMISSION = final_color.rgb * density * glow_intensity;
    ALPHA = final_color.a;
} 