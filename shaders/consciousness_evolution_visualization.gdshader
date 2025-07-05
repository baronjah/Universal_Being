// consciousness_evolution_visualization.gdshader - CONSCIOUSNESS EVOLUTION EFFECTS
// CYCLE 4 - Agent 5 (Visual Designer) - Beautiful consciousness evolution visualization
// Shows Universal Being evolution, consciousness level changes, and awakening processes

shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_test_disabled;

// Evolution State Parameters
uniform float consciousness_level : hint_range(1.0, 10.0) = 5.0;
uniform float evolution_progress : hint_range(0.0, 1.0) = 0.0;
uniform float awakening_intensity : hint_range(0.0, 5.0) = 1.0;
uniform bool evolution_active : hint_range(0, 1) = false;

// Evolution Type
uniform int evolution_stage : hint_range(0, 4) = 0;  // 0=basic, 1=awakening, 2=connected, 3=enlightened, 4=transcendent
uniform float evolution_energy : hint_range(0.0, 10.0) = 3.0;
uniform float transformation_power : hint_range(0.0, 5.0) = 2.0;

// Consciousness Colors (matching Universal Being system)
uniform vec4 consciousness_1_2_color : source_color = vec4(0.5, 0.5, 0.5, 0.6);  // Gray - Dormant
uniform vec4 consciousness_3_4_color : source_color = vec4(0.2, 0.4, 1.0, 0.7);  // Blue - Aware
uniform vec4 consciousness_5_6_color : source_color = vec4(0.2, 1.0, 0.2, 0.8);  // Green - Connected
uniform vec4 consciousness_7_8_color : source_color = vec4(1.0, 0.84, 0.0, 0.9); // Gold - Enlightened
uniform vec4 consciousness_9_10_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // White - Transcendent

// Evolution Effects
uniform float consciousness_glow_intensity : hint_range(0.0, 5.0) = 2.0;
uniform float evolution_particle_density : hint_range(0.1, 3.0) = 1.5;
uniform bool show_consciousness_aura : hint_range(0, 1) = true;
uniform bool show_evolution_trails : hint_range(0, 1) = true;

// Advanced Effects
uniform float wisdom_accumulation : hint_range(0.0, 10.0) = 0.0;
uniform float reality_influence : hint_range(0.0, 5.0) = 1.0;
uniform bool show_akashic_connection : hint_range(0, 1) = false;
uniform float dimensional_presence : hint_range(1.0, 5.0) = 3.0;

// Animation
uniform float evolution_pulse_rate : hint_range(0.1, 3.0) = 1.0;
uniform float consciousness_flow_speed : hint_range(0.0, 2.0) = 0.8;
uniform bool breathing_effect : hint_range(0, 1) = true;

varying vec3 world_position;
varying vec3 view_direction;
varying vec3 world_normal;
varying float distance_to_observer;

// Get consciousness color based on level
vec4 get_consciousness_color(float level) {
    if (level <= 2.0) {
        return consciousness_1_2_color;
    } else if (level <= 4.0) {
        float blend_factor = (level - 2.0) / 2.0;
        return mix(consciousness_1_2_color, consciousness_3_4_color, blend_factor);
    } else if (level <= 6.0) {
        float blend_factor = (level - 4.0) / 2.0;
        return mix(consciousness_3_4_color, consciousness_5_6_color, blend_factor);
    } else if (level <= 8.0) {
        float blend_factor = (level - 6.0) / 2.0;
        return mix(consciousness_5_6_color, consciousness_7_8_color, blend_factor);
    } else {
        float blend_factor = (level - 8.0) / 2.0;
        return mix(consciousness_7_8_color, consciousness_9_10_color, blend_factor);
    }
}

// Consciousness field around being
float consciousness_field(vec3 pos, float time) {
    float distance = length(pos);
    
    // Field strength based on consciousness level
    float field_radius = consciousness_level * 0.5 + 1.0;
    float field_strength = consciousness_level / 10.0;
    
    // Basic field calculation
    float field = exp(-distance / field_radius) * field_strength;
    
    // Consciousness breathing effect
    if (breathing_effect) {
        float breathing = sin(time * consciousness_flow_speed * 2.0) * 0.2 + 0.8;
        field *= breathing;
    }
    
    // Evolution energy enhancement
    if (evolution_active) {
        float evolution_enhancement = sin(time * evolution_pulse_rate * 3.0) * evolution_progress + 1.0;
        field *= evolution_enhancement;
    }
    
    return field;
}

// Evolution particle effects
float evolution_particles(vec3 pos, float time) {
    if (!evolution_active) return 0.0;
    
    // Particle positions based on evolution progress
    float particle_scale = evolution_particle_density * (1.0 + evolution_progress);
    
    // Spiral particle pattern during evolution
    float spiral_angle = atan(pos.z, pos.x) + time * 2.0;
    float spiral_radius = length(pos.xz);
    float spiral_height = pos.y;
    
    // Evolution spiral
    float spiral_pattern = sin(spiral_angle * 3.0 + spiral_radius * 2.0 + spiral_height + time * 4.0);
    spiral_pattern = step(0.7, spiral_pattern) * evolution_progress;
    
    // Random particles for transformation energy
    float random_particles = step(0.85, sin(pos.x * particle_scale + time) * cos(pos.y * particle_scale + time * 1.3) * sin(pos.z * particle_scale + time * 0.7));
    random_particles *= evolution_energy / 10.0;
    
    // Consciousness awakening bursts
    float awakening_bursts = 0.0;
    if (awakening_intensity > 0.0) {
        awakening_bursts = step(0.9, sin(length(pos) * 5.0 - time * 6.0)) * awakening_intensity * 0.2;
    }
    
    return spiral_pattern + random_particles + awakening_bursts;
}

// Consciousness aura visualization
float consciousness_aura(vec3 pos, float time) {
    if (!show_consciousness_aura) return 1.0;
    
    float distance = length(pos);
    
    // Multi-layer aura based on consciousness level
    float aura_radius_1 = consciousness_level * 0.3;
    float aura_radius_2 = consciousness_level * 0.6;
    float aura_radius_3 = consciousness_level * 1.0;
    
    // Aura layers
    float aura_1 = exp(-distance / aura_radius_1) * 0.5;
    float aura_2 = exp(-distance / aura_radius_2) * 0.3;
    float aura_3 = exp(-distance / aura_radius_3) * 0.2;
    
    // Aura pulsing
    float aura_pulse = sin(time * consciousness_flow_speed) * 0.3 + 0.7;
    aura_pulse = pow(aura_pulse, 1.0 + consciousness_level * 0.1);
    
    float total_aura = (aura_1 + aura_2 + aura_3) * aura_pulse;
    
    // Consciousness glow enhancement
    total_aura *= consciousness_glow_intensity / 5.0;
    
    return total_aura;
}

// Evolution trails during transformation
float evolution_trails(vec3 pos, float time) {
    if (!show_evolution_trails || !evolution_active) return 1.0;
    
    // Trail patterns during evolution
    float trail_length = evolution_progress * 3.0;
    
    // Multiple trail directions
    vec3 trail_dir_1 = normalize(vec3(1.0, 0.5, 0.0));
    vec3 trail_dir_2 = normalize(vec3(-0.5, 1.0, 0.5));
    vec3 trail_dir_3 = normalize(vec3(0.0, -0.5, 1.0));
    
    // Trail calculations
    float trail_1 = max(0.0, 1.0 - abs(dot(pos, trail_dir_1) - time * 2.0) / trail_length);
    float trail_2 = max(0.0, 1.0 - abs(dot(pos, trail_dir_2) - time * 1.8 + PI) / trail_length);
    float trail_3 = max(0.0, 1.0 - abs(dot(pos, trail_dir_3) - time * 2.2 + PI * 0.5) / trail_length);
    
    // Trail intensity based on transformation power
    float trail_intensity = transformation_power / 5.0;
    
    return 1.0 + (trail_1 + trail_2 + trail_3) * trail_intensity * evolution_progress;
}

// Wisdom accumulation visualization
float wisdom_visualization(vec3 pos, float time) {
    if (wisdom_accumulation <= 0.0) return 1.0;
    
    // Wisdom appears as crystalline patterns
    float wisdom_pattern = sin(pos.x * 2.0 + time * 0.3) * cos(pos.y * 1.5 + time * 0.5) * sin(pos.z * 1.8 + time * 0.2);
    wisdom_pattern = wisdom_pattern * 0.5 + 0.5;
    
    // Wisdom accumulation effect
    float wisdom_strength = wisdom_accumulation / 10.0;
    wisdom_pattern = pow(wisdom_pattern, 2.0 - wisdom_strength);
    
    // Crystalline structure
    float crystal_structure = step(0.8, wisdom_pattern) * wisdom_strength;
    
    return 1.0 + crystal_structure * 0.5;
}

// Reality influence field
float reality_influence_field(vec3 pos, float time) {
    if (reality_influence <= 0.0) return 1.0;
    
    // Reality distortion around high-consciousness beings
    float distance = length(pos);
    float influence_radius = reality_influence * 2.0;
    
    // Reality ripples
    float ripple_1 = sin(distance * 3.0 - time * 2.0) * exp(-distance / influence_radius);
    float ripple_2 = cos(distance * 2.5 - time * 1.5) * exp(-distance / (influence_radius * 0.8));
    
    // Reality influence strength
    float influence_strength = reality_influence / 5.0;
    float total_influence = (ripple_1 + ripple_2) * influence_strength;
    
    return 1.0 + total_influence * 0.3;
}

// Akashic Records connection visualization
float akashic_connection(vec3 pos, float time) {
    if (!show_akashic_connection) return 1.0;
    
    // Connection streams to Akashic Records
    float akashic_distance = length(pos - vec3(0.0, 5.0, 0.0));  // Connection point above
    
    // Data streams
    float stream_1 = sin(akashic_distance * 4.0 - time * 3.0) * exp(-akashic_distance * 0.2);
    float stream_2 = cos(akashic_distance * 3.5 - time * 2.5) * exp(-akashic_distance * 0.15);
    
    // Information flow
    float info_flow = sin(time * 4.0 + pos.x * 0.5) * cos(time * 3.0 + pos.z * 0.3);
    info_flow = info_flow * 0.5 + 0.5;
    
    float total_connection = (stream_1 + stream_2) * info_flow * consciousness_level * 0.1;
    
    return 1.0 + max(0.0, total_connection) * 0.4;
}

// Dimensional presence effect
float dimensional_presence_effect(vec3 pos, float time) {
    if (dimensional_presence <= 1.0) return 1.0;
    
    // Higher consciousness exists in multiple dimensions
    float dimension_factor = (dimensional_presence - 1.0) / 4.0;
    
    // Multi-dimensional flickering
    float dimension_flicker = sin(time * 8.0) * sin(time * 6.3) * sin(time * 4.7) * dimension_factor;
    dimension_flicker = dimension_flicker * 0.2 + 1.0;
    
    // Dimensional overlap patterns
    float overlap_pattern = sin(pos.x * 0.3 + time) * cos(pos.y * 0.4 + time * 1.2) * sin(pos.z * 0.5 + time * 0.8);
    overlap_pattern = overlap_pattern * dimension_factor * 0.3 + 1.0;
    
    return dimension_flicker * overlap_pattern;
}

// Evolution stage specific effects
float evolution_stage_effects(vec3 pos, float time) {
    float stage_effect = 1.0;
    
    switch(evolution_stage) {
        case 0: // Basic being
            stage_effect = 1.0;
            break;
        case 1: // Awakening
            stage_effect = 1.0 + sin(time * 4.0) * 0.2;
            break;
        case 2: // Connected
            float connection_pulse = sin(length(pos) * 2.0 - time * 3.0) * 0.3 + 1.0;
            stage_effect = connection_pulse;
            break;
        case 3: // Enlightened
            float enlightened_glow = exp(-length(pos) * 0.5) * (sin(time * 2.0) * 0.4 + 1.2);
            stage_effect = enlightened_glow;
            break;
        case 4: // Transcendent
            float transcendent_radiance = 1.0 + sin(time * 1.5) * sin(time * 2.3) * sin(time * 3.1) * 0.6;
            transcendent_radiance *= exp(-length(pos) * 0.3);
            stage_effect = transcendent_radiance;
            break;
    }
    
    return stage_effect;
}

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    view_direction = normalize(CAMERA_POSITION_WORLD - world_position);
    distance_to_observer = length(CAMERA_POSITION_WORLD - world_position);
}

void fragment() {
    float time = TIME;
    
    // Calculate all consciousness evolution effects
    float consciousness_field_effect = consciousness_field(world_position, time);
    float evolution_particle_effect = evolution_particles(world_position, time);
    float consciousness_aura_effect = consciousness_aura(world_position, time);
    float evolution_trail_effect = evolution_trails(world_position, time);
    float wisdom_effect = wisdom_visualization(world_position, time);
    float reality_influence_effect = reality_influence_field(world_position, time);
    float akashic_effect = akashic_connection(world_position, time);
    float dimensional_effect = dimensional_presence_effect(world_position, time);
    float stage_effect = evolution_stage_effects(world_position, time);
    
    // Get base consciousness color
    vec4 consciousness_color = get_consciousness_color(consciousness_level);
    
    // Base field visualization
    vec4 field_color = consciousness_color;
    
    // Apply consciousness field
    field_color.rgb *= (0.5 + consciousness_field_effect * 1.5);
    
    // Add evolution particles
    field_color.rgb += vec3(1.0, 0.8, 0.2) * evolution_particle_effect;
    
    // Apply consciousness aura
    field_color.rgb *= (0.7 + consciousness_aura_effect * 0.6);
    
    // Evolution trail effects
    field_color.rgb *= evolution_trail_effect;
    
    // Wisdom crystalline effects
    if (wisdom_accumulation > 0.0) {
        field_color.rgb = mix(field_color.rgb, vec3(0.9, 0.9, 1.0), wisdom_effect * wisdom_accumulation * 0.05);
    }
    
    // Reality influence distortion
    field_color.rgb *= reality_influence_effect;
    
    // Akashic connection glow
    if (show_akashic_connection) {
        field_color.rgb = mix(field_color.rgb, vec3(0.8, 1.0, 0.9), akashic_effect * 0.3);
    }
    
    // Dimensional presence effects
    field_color.rgb *= dimensional_effect;
    
    // Evolution stage specific coloring
    field_color.rgb *= stage_effect;
    
    // Calculate total consciousness intensity
    float total_intensity = consciousness_field_effect * consciousness_aura_effect;
    total_intensity *= evolution_trail_effect * wisdom_effect * reality_influence_effect;
    total_intensity *= dimensional_effect * stage_effect;
    
    // Evolution boost
    if (evolution_active) {
        total_intensity *= (1.0 + evolution_progress * 2.0 + evolution_energy * 0.1);
        field_color.rgb += vec3(0.3, 0.2, 0.1) * evolution_progress;
    }
    
    // Consciousness level intensity scaling
    total_intensity *= (0.3 + consciousness_level * 0.07);
    
    // Glow intensity application
    total_intensity *= consciousness_glow_intensity / 5.0;
    
    // Fresnel effect for consciousness field
    float fresnel = 1.0 - abs(dot(world_normal, view_direction));
    fresnel = pow(fresnel, 1.5);
    total_intensity *= (0.4 + fresnel * 0.6);
    
    // Special effects for high consciousness levels
    if (consciousness_level >= 9.0) {
        // Transcendent white glow with particles
        field_color.rgb = mix(field_color.rgb, vec3(1.0, 1.0, 1.0), 0.3);
        total_intensity *= 1.5;
        
        // Transcendent particle effects
        float transcendent_particles = step(0.95, sin(world_position.x * 8.0 + time * 2.0) * sin(world_position.y * 7.0 + time * 1.8) * sin(world_position.z * 9.0 + time * 2.2));
        field_color.rgb += vec3(1.0, 1.0, 1.0) * transcendent_particles * 0.5;
    }
    
    // Final color output
    ALBEDO = field_color.rgb;
    EMISSION = field_color.rgb * (1.0 + total_intensity * 2.5);
    
    // Dynamic alpha based on consciousness and effects
    float final_alpha = field_color.a * total_intensity;
    
    // Evolution particle alpha boost
    final_alpha += evolution_particle_effect * 0.3;
    
    // Distance fade
    float distance_fade = 1.0 / (1.0 + distance_to_observer * 0.008);
    final_alpha *= distance_fade;
    
    ALPHA = clamp(final_alpha, 0.02, 1.0);
}