shader_type canvas_item;

// Plasmoid Consciousness Shader
// Creates a dynamic, flowing consciousness visualization for the player plasmoid

uniform float consciousness_level : hint_range(0.0, 7.0) = 5.0;
uniform float glow_intensity : hint_range(0.0, 5.0) = 1.5;
uniform float time : hint_range(0.0, 100.0) = 0.0;
uniform float flow_speed : hint_range(0.1, 3.0) = 1.0;
uniform vec3 primary_color : source_color = vec3(0.2, 0.8, 1.0);
uniform vec3 secondary_color : source_color = vec3(1.0, 0.4, 0.8);

varying vec3 world_position;
varying vec3 world_normal;

vec3 get_consciousness_color(float level) {
    // Consciousness level color mapping
    vec3 colors[8];
    colors[0] = vec3(0.5, 0.5, 0.5);      // Gray - Dormant
    colors[1] = vec3(0.9, 0.9, 0.9);      // Pale - Awakening  
    colors[2] = vec3(0.2, 0.4, 1.0);      // Blue - Aware
    colors[3] = vec3(0.2, 1.0, 0.2);      // Green - Connected
    colors[4] = vec3(1.0, 0.84, 0.0);     // Gold - Enlightened
    colors[5] = vec3(1.0, 1.0, 1.0);      // White - Transcendent
    colors[6] = vec3(0.8, 0.9, 1.0);      // Cosmic Blue - Beyond
    colors[7] = vec3(1.0, 0.8, 1.0);      // Cosmic Purple - Infinite
    
    int base_level = int(floor(level));
    float fraction = level - float(base_level);
    
    if (base_level >= 7) return colors[7];
    if (base_level < 0) return colors[0];
    
    return mix(colors[base_level], colors[base_level + 1], fraction);
}

float noise(vec3 p) {
    // Simple 3D noise function
    p = fract(p * 0.3183);
    p += dot(p, p.yxz + 19.19);
    return fract((p.x + p.y) * p.z);
}

float fbm(vec3 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(p * frequency);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    
    return value;
}

void vertex() {
    world_position = VERTEX;
    world_normal = NORMAL;
}

void fragment() {
    vec3 pos = world_position;
    float t = time * flow_speed;
    
    // Create flowing consciousness patterns
    vec3 flow_pos = pos + vec3(sin(t * 0.5), cos(t * 0.3), sin(t * 0.7)) * 0.1;
    float consciousness_flow = fbm(flow_pos * 2.0 + t * 0.1);
    
    // Add pulsing energy
    float pulse = sin(t * 2.0) * 0.5 + 0.5;
    float energy_pulse = sin(t * 4.0 + pos.x + pos.y + pos.z) * 0.3 + 0.7;
    
    // Create consciousness-based color
    vec3 base_color = get_consciousness_color(consciousness_level);
    
    // Mix in flowing patterns
    vec3 flow_color = mix(primary_color, secondary_color, consciousness_flow);
    vec3 final_color = mix(base_color, flow_color, 0.3);
    
    // Add consciousness level intensity
    float consciousness_intensity = consciousness_level / 7.0;
    final_color *= consciousness_intensity * energy_pulse;
    
    // Add glow effect
    float glow = glow_intensity * pulse * consciousness_intensity;
    final_color += base_color * glow * 0.5;
    
    // Edge glow for plasmoid boundary
    float edge_factor = 1.0 - abs(dot(normalize(world_normal), normalize(vec3(0, 0, 1))));
    final_color += base_color * edge_factor * glow_intensity * 0.3;
    
    COLOR = vec4(final_color, 0.8 + consciousness_intensity * 0.2);
}