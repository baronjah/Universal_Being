shader_type spatial;
render_mode unshaded, cull_disabled, blend_add;

// Universal Being AI connection visualization shader
// Creates a flowing energy beam effect for AI interactions between beings

uniform vec4 beam_color : source_color = vec4(0.8, 0.2, 1.0, 1.0);
uniform float beam_speed : hint_range(0.1, 10.0) = 2.0;
uniform float beam_width : hint_range(0.0, 1.0) = 0.2;
uniform float beam_intensity : hint_range(0.0, 5.0) = 1.0;
uniform float connection_strength : hint_range(0.0, 1.0) = 0.5;

varying vec3 vertex_world_pos;
varying vec2 uv_coords;

// Flow noise function for beam effect
float flow_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    // Animate flow
    float time = TIME * beam_speed;
    float flow = sin(i.x * 0.1 + i.y * 0.2 + time) * 0.5 + 0.5;
    
    // Create flowing pattern
    float n = sin(i.x * 12.9898 + i.y * 78.233) * 43758.5453;
    float noise = fract(n);
    
    return mix(noise, flow, 0.5);
}

void vertex() {
    vertex_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    uv_coords = UV;
}

void fragment() {
    // Create flowing beam effect
    vec2 flow_uv = uv_coords * 10.0 + vec2(TIME * beam_speed, 0.0);
    float flow = flow_noise(flow_uv);
    
    // Create beam shape
    float beam_shape = smoothstep(beam_width, 0.0, abs(uv_coords.y - 0.5) * 2.0);
    
    // Add connection strength variation
    float strength_var = sin(TIME * 2.0 + flow * 10.0) * 0.1 + 0.9;
    float final_strength = connection_strength * strength_var;
    
    // Combine effects
    vec4 final_color = beam_color;
    final_color.a *= flow * beam_shape * final_strength * beam_intensity;
    
    // Apply to albedo and emission
    ALBEDO = final_color.rgb;
    EMISSION = final_color.rgb * flow * beam_shape * beam_intensity;
    ALPHA = final_color.a;
    
    // Add some sparkle effect
    float sparkle = pow(flow * beam_shape, 3.0) * beam_intensity;
    EMISSION += vec3(1.0) * sparkle;
} 