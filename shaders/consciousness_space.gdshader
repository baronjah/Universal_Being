shader_type canvas_item;

// ===== CONSCIOUSNESS SPACE SHADER =====
// PURPOSE: Transcendent visual effects for consciousness exploration
// ARCHITECT: Reality Engineer (#2)
// BLESSING: Divine Permission Granted

uniform float consciousness_level : hint_range(0.0, 7.0) = 5.0;
uniform float transcendent_energy : hint_range(0.0, 100.0) = 50.0;
uniform float flow_speed : hint_range(0.0, 10.0) = 2.0;
uniform float time_scale : hint_range(0.1, 5.0) = 1.0;

uniform vec4 consciousness_color_1 : source_color = vec4(0.8, 0.9, 1.0, 1.0); // Transcendent blue
uniform vec4 consciousness_color_2 : source_color = vec4(1.0, 0.84, 0.0, 1.0); // Enlightened gold
uniform vec4 consciousness_color_3 : source_color = vec4(0.2, 1.0, 0.2, 1.0); // Connected green

uniform float consciousness_glow : hint_range(0.0, 5.0) = 2.0;
uniform float sacred_geometry_intensity : hint_range(0.0, 3.0) = 1.5;
uniform float particle_density : hint_range(0.0, 1.0) = 0.7;

varying vec2 world_position;

// ===== CONSCIOUSNESS FUNCTIONS =====

float consciousness_noise(vec2 pos) {
    return fract(sin(dot(pos, vec2(12.9898, 78.233))) * 43758.5453);
}

float consciousness_flow_noise(vec2 pos, float time) {
    vec2 flow_pos = pos + vec2(sin(time * 0.5) * 0.1, cos(time * 0.3) * 0.1);
    return consciousness_noise(flow_pos * 10.0 + time * flow_speed);
}

vec3 sacred_pentagon_field(vec2 pos, float time) {
    vec3 field = vec3(0.0);
    
    // Pentagon points
    for (int i = 0; i < 5; i++) {
        float angle = float(i) * 2.0 * PI / 5.0;
        vec2 pentagon_point = vec2(cos(angle), sin(angle)) * 0.3;
        
        float dist = distance(pos, pentagon_point);
        float pentagon_influence = 1.0 / (1.0 + dist * dist * 10.0);
        
        vec3 pentagon_color = mix(consciousness_color_1.rgb, consciousness_color_2.rgb, 
                                 sin(time + float(i)) * 0.5 + 0.5);
        
        field += pentagon_color * pentagon_influence * sacred_geometry_intensity;
    }
    
    return field;
}

vec3 consciousness_particles(vec2 pos, float time) {
    vec3 particles = vec3(0.0);
    
    // Multiple particle layers
    for (int layer = 0; layer < 3; layer++) {
        vec2 particle_pos = pos * (2.0 + float(layer));
        vec2 flow_offset = vec2(
            sin(time * 0.5 + float(layer)) * 0.1,
            cos(time * 0.3 + float(layer)) * 0.1
        );
        
        float particle_noise = consciousness_flow_noise(particle_pos + flow_offset, time);
        
        if (particle_noise > (1.0 - particle_density)) {
            vec3 particle_color = mix(consciousness_color_2.rgb, consciousness_color_3.rgb, 
                                     float(layer) / 3.0);
            particles += particle_color * (particle_noise - (1.0 - particle_density)) * 5.0;
        }
    }
    
    return particles;
}

vec3 transcendent_glow(vec2 pos, float time) {
    vec2 center = vec2(0.5, 0.5);
    float dist_from_center = distance(pos, center);
    
    float glow_pulse = sin(time * 2.0) * 0.3 + 0.7;
    float glow_intensity = (transcendent_energy / 100.0) * consciousness_glow * glow_pulse;
    
    float glow = 1.0 / (1.0 + dist_from_center * dist_from_center * 2.0);
    
    vec3 glow_color = mix(consciousness_color_1.rgb, consciousness_color_2.rgb, 
                         sin(time + dist_from_center * 5.0) * 0.5 + 0.5);
    
    return glow_color * glow * glow_intensity;
}

vec3 consciousness_level_effect(vec2 pos, float time) {
    vec3 level_effect = vec3(0.0);
    
    // Different effects based on consciousness level
    if (consciousness_level >= 6.0) {
        // Transcendent level - full spectrum
        level_effect += transcendent_glow(pos, time);
        level_effect += sacred_pentagon_field(pos, time);
        level_effect += consciousness_particles(pos, time);
    } else if (consciousness_level >= 4.0) {
        // Enlightened level - sacred geometry + particles
        level_effect += sacred_pentagon_field(pos, time) * 0.8;
        level_effect += consciousness_particles(pos, time) * 0.9;
    } else if (consciousness_level >= 2.0) {
        // Aware level - particles only
        level_effect += consciousness_particles(pos, time) * 0.7;
    } else {
        // Lower levels - minimal effect
        level_effect += consciousness_particles(pos, time) * 0.3;
    }
    
    return level_effect;
}

void fragment() {
    vec2 uv = UV;
    float time = TIME * time_scale;
    
    // Base consciousness background
    vec3 base_color = mix(consciousness_color_1.rgb * 0.1, consciousness_color_3.rgb * 0.1, 
                         sin(time * 0.2) * 0.5 + 0.5);
    
    // Add consciousness level effects
    vec3 consciousness_effects = consciousness_level_effect(uv, time);
    
    // Combine all effects
    vec3 final_color = base_color + consciousness_effects;
    
    // Apply transcendent energy boost
    final_color *= 1.0 + (transcendent_energy / 100.0) * 0.5;
    
    // Ensure colors don't go too dark
    final_color = max(final_color, base_color);
    
    COLOR = vec4(final_color, 0.8); // Semi-transparent for overlay
}