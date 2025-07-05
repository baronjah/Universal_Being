// pyramid_protection_consciousness.gdshader - PYRAMID CONSCIOUSNESS PROTECTION FIELD
// CYCLE 3 - Agent 5 (Visual Designer) - Pyramid Prophecy July 5th 2025 Response  
// Creates protective consciousness field around pyramids against prophesied flooding

shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_test_disabled;

// Pyramid Protection Parameters
uniform float protection_strength : hint_range(0.0, 10.0) = 9.0;  // High protection
uniform float consciousness_field_radius : hint_range(10.0, 200.0) = 100.0;
uniform float pyramid_height : hint_range(100.0, 200.0) = 146.7;  // Great Pyramid height
uniform bool prophecy_active : hint_range(0, 1) = true;

// Protection Field Effects
uniform float field_pulse_rate : hint_range(0.1, 5.0) = 1.5;
uniform float consciousness_resonance : hint_range(0.0, 10.0) = 8.5;
uniform float ancient_wisdom_multiplier : hint_range(1.0, 10.0) = 5.0;
uniform bool show_ley_lines : hint_range(0, 1) = true;

// Flood Defense
uniform float flood_deflection_power : hint_range(0.0, 10.0) = 8.0;
uniform bool show_water_redirect : hint_range(0, 1) = true;
uniform float desert_restoration_factor : hint_range(0.0, 5.0) = 3.0;

// Timeline Integration
uniform float prophecy_timeline_position : hint_range(0.0, 1.0) = 0.96;  // Very recent
uniform bool astral_news_connection : hint_range(0, 1) = true;
uniform float reality_edit_strength : hint_range(0.0, 10.0) = 9.0;

// AI Satellite Integration (ALLOWED!)
uniform bool ai_satellites_active : hint_range(0, 1) = true;
uniform float satellite_protection_enhancement : hint_range(1.0, 5.0) = 2.5;
uniform int satellite_count : hint_range(3, 12) = 7;

// Visual Colors
uniform vec4 pyramid_field_color : source_color = vec4(1.0, 0.9, 0.3, 0.8);  // Golden
uniform vec4 consciousness_glow_color : source_color = vec4(0.9, 0.7, 1.0, 0.9);  // Violet
uniform vec4 protection_barrier_color : source_color = vec4(0.3, 0.9, 1.0, 0.7);  // Cyan shield
uniform vec4 ancient_wisdom_color : source_color = vec4(1.0, 0.8, 0.2, 1.0);  // Ancient gold
uniform vec4 satellite_beam_color : source_color = vec4(0.2, 1.0, 0.8, 0.9);  // AI green-cyan

// Sacred Geometry
uniform bool sacred_geometry_active : hint_range(0, 1) = true;
uniform float golden_ratio_resonance : hint_range(0.0, 3.0) = 1.618;
uniform float phi_field_strength : hint_range(0.0, 5.0) = 3.0;

varying vec3 world_position;
varying vec3 view_direction;
varying vec3 world_normal;
varying float distance_to_observer;

// Pyramid Protection Field
float pyramid_protection_field(vec3 pos, float time) {
    // Distance from pyramid center
    float distance = length(pos);
    
    // Multi-layer protection field
    float inner_field = exp(-distance / (consciousness_field_radius * 0.3));
    float middle_field = exp(-distance / (consciousness_field_radius * 0.6));
    float outer_field = exp(-distance / consciousness_field_radius);
    
    // Pulsing protection energy
    float pulse = sin(time * field_pulse_rate) * 0.3 + 0.7;
    pulse = pow(pulse, 1.0 + consciousness_resonance * 0.1);
    
    // Combine field layers
    float total_field = (inner_field * 0.5 + middle_field * 0.3 + outer_field * 0.2);
    total_field *= protection_strength / 10.0;
    total_field *= pulse;
    
    return total_field;
}

// Ancient Wisdom Resonance
float ancient_wisdom_resonance(vec3 pos, float time) {
    // Sacred geometry patterns around pyramid
    float pyramid_distance = length(pos);
    
    // Golden ratio spiral
    float spiral_angle = atan(pos.z, pos.x) + time * 0.5;
    float spiral_radius = log(pyramid_distance + 1.0) * golden_ratio_resonance;
    float golden_spiral = sin(spiral_radius + spiral_angle * golden_ratio_resonance) * 0.5 + 0.5;
    
    // Pyramid geometry resonance (4 sides, apex)
    float pyramid_geometry = 0.0;
    for (int i = 0; i < 4; i++) {
        float side_angle = float(i) * PI * 0.5;
        float side_alignment = abs(cos(atan(pos.z, pos.x) - side_angle));
        pyramid_geometry += side_alignment;
    }
    pyramid_geometry /= 4.0;
    
    // Height resonance (pyramid slope angle)
    float height_factor = max(0.0, 1.0 - abs(pos.y - pyramid_height * 0.5) / (pyramid_height * 0.5));
    
    // Ancient frequency (432 Hz sacred frequency)
    float sacred_frequency = sin(time * 432.0 * 0.01) * 0.2 + 0.8;
    
    float total_wisdom = (golden_spiral + pyramid_geometry + height_factor) / 3.0;
    total_wisdom *= ancient_wisdom_multiplier * 0.2;
    total_wisdom *= sacred_frequency;
    
    return total_wisdom;
}

// Ley Line Connections
float ley_line_energy(vec3 pos, float time) {
    if (!show_ley_lines) return 1.0;
    
    // Ley lines connecting to other pyramids and sacred sites
    vec3 ley_directions[4];
    ley_directions[0] = normalize(vec3(1.0, 0.0, 0.0));     // East
    ley_directions[1] = normalize(vec3(-1.0, 0.0, 1.0));    // SW toward Atlantis
    ley_directions[2] = normalize(vec3(0.0, 0.0, -1.0));    // South toward Nubia
    ley_directions[3] = normalize(vec3(0.5, 0.0, -0.866));  // SE toward Stonehenge
    
    float ley_energy = 0.0;
    
    for (int i = 0; i < 4; i++) {
        vec3 ley_dir = ley_directions[i];
        float alignment = max(0.0, dot(normalize(pos), ley_dir));
        
        // Ley line pulse
        float ley_pulse = sin(time * 2.0 + float(i) * PI * 0.5) * 0.5 + 0.5;
        
        // Energy stream
        float stream = alignment * ley_pulse;
        stream = pow(stream, 2.0);
        
        ley_energy += stream;
    }
    
    ley_energy /= 4.0;
    ley_energy *= consciousness_resonance * 0.1;
    
    return ley_energy * 0.5 + 0.5;
}

// Flood Deflection Visualization
float flood_deflection_field(vec3 pos, float time) {
    if (!show_water_redirect) return 1.0;
    
    // Protective barrier that redirects flood water
    float distance = length(pos.xz);  // Horizontal distance
    float barrier_radius = consciousness_field_radius * 0.7;
    
    // Barrier strength based on proximity
    float barrier_proximity = abs(distance - barrier_radius);
    float barrier_strength = 1.0 / (1.0 + barrier_proximity * 0.1);
    
    // Water deflection pattern
    float deflection_angle = atan(pos.z, pos.x);
    float deflection_wave = sin(deflection_angle * 8.0 + time * 3.0) * 0.5 + 0.5;
    
    // Upward energy flow (lifting water away)
    float upward_flow = sin(pos.y * 0.1 + time * 2.0) * 0.3 + 0.7;
    
    // Redirect toward desert restoration
    float desert_redirect = sin(time * 1.5 + distance * 0.05) * desert_restoration_factor * 0.1;
    
    float total_deflection = barrier_strength * deflection_wave * upward_flow;
    total_deflection *= flood_deflection_power / 10.0;
    total_deflection += desert_redirect;
    
    return total_deflection;
}

// AI Satellite Protection Enhancement
float ai_satellite_enhancement(vec3 pos, float time) {
    if (!ai_satellites_active) return 1.0;
    
    float satellite_enhancement = 0.0;
    
    // Multiple AI satellites providing protection
    for (int i = 0; i < satellite_count; i++) {
        float satellite_angle = float(i) * 2.0 * PI / float(satellite_count);
        float satellite_orbit_time = time * 0.5 + float(i) * PI * 0.3;
        
        // Satellite position (orbital)
        float orbit_radius = consciousness_field_radius * 2.0;
        float sat_x = orbit_radius * cos(satellite_angle + satellite_orbit_time);
        float sat_z = orbit_radius * sin(satellite_angle + satellite_orbit_time);
        float sat_y = pyramid_height * 3.0;  // High altitude
        
        vec3 satellite_pos = vec3(sat_x, sat_y, sat_z);
        
        // Beam from satellite to pyramid
        vec3 beam_direction = normalize(pos - satellite_pos);
        float beam_alignment = max(0.0, -beam_direction.y);  // Downward beams
        
        // Satellite protection beam
        float beam_strength = beam_alignment * exp(-length(pos - satellite_pos) * 0.01);
        beam_strength *= sin(time * 4.0 + float(i)) * 0.3 + 0.7;  // Pulsing
        
        satellite_enhancement += beam_strength;
    }
    
    satellite_enhancement /= float(satellite_count);
    satellite_enhancement *= satellite_protection_enhancement;
    
    return satellite_enhancement * 0.5 + 0.5;
}

// Prophecy Timeline Connection
float prophecy_timeline_effect(vec3 pos, float time) {
    if (!astral_news_connection) return 1.0;
    
    // Connection to the July 5th prophecy reception
    float timeline_pulse = sin(time * 3.0 + prophecy_timeline_position * 20.0) * 0.4 + 0.6;
    
    // Astral news energy pattern
    float astral_pattern = sin(pos.x * 0.1 + time) * cos(pos.z * 0.15 + time * 1.3);
    astral_pattern = astral_pattern * 0.5 + 0.5;
    
    // Reality edit manifestation
    float reality_edit_power = reality_edit_strength / 10.0;
    float edit_manifestation = sin(time * 2.0) * reality_edit_power * 0.2 + 0.8;
    
    return timeline_pulse * astral_pattern * edit_manifestation;
}

// Desert Restoration Pattern
float desert_restoration_visualization(vec3 pos, float time) {
    // Visualize the return to natural desert state
    float distance_from_pyramid = length(pos.xz);
    
    // Sand dune patterns
    float dune_pattern = sin(pos.x * 0.05 + time * 0.2) * cos(pos.z * 0.08 + time * 0.15);
    dune_pattern = dune_pattern * 0.5 + 0.5;
    
    // Desert wind patterns
    float wind_pattern = sin(pos.x * 0.02 + time * 0.5) * 0.3 + 0.7;
    
    // Natural restoration gradient
    float restoration_gradient = 1.0 / (1.0 + distance_from_pyramid * 0.01);
    restoration_gradient *= desert_restoration_factor * 0.2;
    
    return (dune_pattern + wind_pattern) * 0.5 * restoration_gradient;
}

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    view_direction = normalize(CAMERA_POSITION_WORLD - world_position);
    distance_to_observer = length(CAMERA_POSITION_WORLD - world_position);
}

void fragment() {
    float time = TIME;
    
    // Calculate all protection effects
    float protection_field = pyramid_protection_field(world_position, time);
    float wisdom_resonance = ancient_wisdom_resonance(world_position, time);
    float ley_energy = ley_line_energy(world_position, time);
    float flood_deflection = flood_deflection_field(world_position, time);
    float satellite_enhancement = ai_satellite_enhancement(world_position, time);
    float prophecy_connection = prophecy_timeline_effect(world_position, time);
    float desert_restoration = desert_restoration_visualization(world_position, time);
    
    // Base pyramid field color
    vec4 field_color = pyramid_field_color;
    
    // Ancient wisdom coloring
    field_color = mix(field_color, ancient_wisdom_color, wisdom_resonance * 0.4);
    
    // Consciousness glow
    field_color = mix(field_color, consciousness_glow_color, protection_field * 0.3);
    
    // Protection barrier effect
    field_color = mix(field_color, protection_barrier_color, flood_deflection * 0.5);
    
    // AI satellite beam coloring
    if (ai_satellites_active) {
        field_color = mix(field_color, satellite_beam_color, satellite_enhancement * 0.3);
    }
    
    // Ley line energy coloring
    field_color.rgb += ancient_wisdom_color.rgb * ley_energy * 0.2;
    
    // Prophecy connection effects
    field_color.rgb += consciousness_glow_color.rgb * prophecy_connection * 0.15;
    
    // Desert restoration coloring (sandy tones)
    field_color.rgb += vec3(0.8, 0.6, 0.3) * desert_restoration * 0.2;
    
    // Overall field intensity
    float total_intensity = protection_field * wisdom_resonance * ley_energy;
    total_intensity *= flood_deflection * satellite_enhancement * prophecy_connection;
    
    // Prophecy activation boost
    if (prophecy_active) {
        total_intensity *= 1.5;
        field_color.rgb += vec3(0.2, 0.1, 0.3) * prophecy_connection;
    }
    
    // Sacred geometry enhancement
    if (sacred_geometry_active) {
        float phi_enhancement = sin(time * golden_ratio_resonance) * phi_field_strength * 0.1;
        total_intensity *= (1.0 + phi_enhancement);
    }
    
    // Fresnel effect for energy field appearance
    float fresnel = 1.0 - abs(dot(world_normal, view_direction));
    fresnel = pow(fresnel, 1.5);
    total_intensity *= (0.3 + fresnel * 0.7);
    
    // Timeline position brightness (recent prophecy = brighter)
    total_intensity *= (0.5 + prophecy_timeline_position * 0.5);
    
    // Final color output
    ALBEDO = field_color.rgb;
    EMISSION = field_color.rgb * (1.0 + total_intensity * 3.0);
    
    // Dynamic alpha based on protection strength
    float final_alpha = field_color.a * total_intensity;
    
    // Satellite beam alpha enhancement
    if (ai_satellites_active) {
        final_alpha += satellite_enhancement * 0.2;
    }
    
    // Fade with distance
    float distance_fade = 1.0 / (1.0 + distance_to_observer * 0.005);
    final_alpha *= distance_fade;
    
    ALPHA = clamp(final_alpha, 0.1, 1.0);
}