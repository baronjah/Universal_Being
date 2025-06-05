shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec3 plasma_color : source_color = vec3(0.5, 0.8, 1.0);
uniform float core_intensity : hint_range(0.0, 5.0) = 1.0;
uniform float flow_speed : hint_range(0.0, 10.0) = 2.0;
uniform float pulse_intensity : hint_range(0.0, 1.0) = 1.0;
uniform int consciousness_level : hint_range(0, 7) = 1;
uniform vec3 flash_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float flash_intensity : hint_range(0.0, 1.0) = 0.0;

varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = (MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz;
    
    // Consciousness-based vertex displacement
    float displacement = sin(TIME * flow_speed + VERTEX.y * 3.0) * 0.05;
    displacement *= float(consciousness_level) * 0.1;
    VERTEX += NORMAL * displacement * pulse_intensity;
}

void fragment() {
    // Energy flow pattern
    float energy_flow = sin(world_pos.y * 10.0 - TIME * flow_speed) * 0.5 + 0.5;
    energy_flow *= sin(world_pos.x * 8.0 + TIME * flow_speed * 0.7) * 0.5 + 0.5;
    
    // Consciousness glow
    float consciousness_glow = float(consciousness_level) / 7.0;
    
    // Core to edge gradient
    vec3 view_dir = normalize(CAMERA_POSITION_WORLD - world_pos);
    float fresnel = pow(1.0 - dot(world_normal, view_dir), 2.0);
    
    // Plasma effect
    vec3 plasma = plasma_color * core_intensity;
    plasma *= (1.0 + energy_flow * 0.5);
    plasma *= (1.0 + consciousness_glow * 2.0);
    
    // Add fresnel glow
    plasma += plasma_color * fresnel * 2.0 * pulse_intensity;
    
    // Flash effect for consciousness changes
    plasma = mix(plasma, flash_color * 5.0, flash_intensity);
    
    ALBEDO = plasma;
    EMISSION = plasma * (0.5 + consciousness_glow);
    ALPHA = 0.8 + fresnel * 0.2;
    METALLIC = 0.0;
    ROUGHNESS = 0.2;
    SPECULAR = 0.8;
}