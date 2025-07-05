// flood_disaster_visualization.gdshader - FLOOD DISASTER TIMELINE VISUALIZATION
// CYCLE 3 - Agent 5 (Visual Designer) - Texas Flood July 4th 2025 Response
// Creates dynamic flood visualization for disaster events on Earth timeline

shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_test_disabled;

// Flood Parameters
uniform float flood_intensity : hint_range(0.0, 10.0) = 7.5;  // Texas flood intensity
uniform float flood_radius : hint_range(1.0, 100.0) = 25.0;
uniform float flood_height : hint_range(0.1, 10.0) = 3.0;
uniform float time_since_flood : hint_range(0.0, 365.0) = 1.0;  // Days since flood

// Water Flow Effects
uniform float water_flow_speed : hint_range(0.1, 5.0) = 2.0;
uniform float wave_amplitude : hint_range(0.0, 2.0) = 1.0;
uniform float turbulence_strength : hint_range(0.0, 3.0) = 2.0;
uniform bool show_flood_spread : hint_range(0, 1) = true;

// Timeline Integration
uniform float timeline_position : hint_range(0.0, 1.0) = 0.95;  // Recent event
uniform bool show_prophecy_connection : hint_range(0, 1) = true;
uniform float consciousness_impact : hint_range(0.0, 10.0) = 6.0;

// Visual Colors
uniform vec4 flood_water_color : source_color = vec4(0.2, 0.4, 0.8, 0.8);
uniform vec4 turbulent_water_color : source_color = vec4(0.4, 0.6, 1.0, 0.9);
uniform vec4 disaster_glow_color : source_color = vec4(1.0, 0.3, 0.2, 1.0);
uniform vec4 consciousness_connection_color : source_color = vec4(0.8, 0.2, 1.0, 1.0);

// Texas-Specific
uniform bool texas_flood_mode : hint_range(0, 1) = true;
uniform float texas_geography_factor : hint_range(0.5, 2.0) = 1.5;

// Performance
uniform bool high_quality_waves : hint_range(0, 1) = true;
uniform int wave_detail_level : hint_range(1, 5) = 4;

varying vec3 world_position;
varying vec3 view_direction;
varying vec3 world_normal;
varying float distance_to_observer;

// Flood Water Simulation
float flood_water_height(vec3 pos, float time) {
    // Base flood level
    float base_height = flood_height * (flood_intensity / 10.0);
    
    // Distance from flood center (Texas flood epicenter)
    float distance_from_center = length(pos.xz);
    float flood_spread = flood_radius * (1.0 + time_since_flood * 0.1);
    
    // Flood attenuation with distance
    float flood_coverage = 1.0 / (1.0 + distance_from_center / flood_spread);
    flood_coverage = pow(flood_coverage, 1.5);
    
    // Wave motion
    float wave1 = sin(pos.x * 0.5 + time * water_flow_speed) * wave_amplitude;
    float wave2 = cos(pos.z * 0.7 + time * water_flow_speed * 0.8) * wave_amplitude;
    float wave3 = sin(length(pos.xz) * 0.3 - time * water_flow_speed) * wave_amplitude * 0.5;
    
    float total_waves = (wave1 + wave2 + wave3) * flood_coverage;
    
    return (base_height + total_waves) * flood_coverage;
}

// Water Turbulence (for disaster intensity)
float water_turbulence(vec3 pos, float time) {
    // Higher intensity = more turbulent water
    float turbulence_factor = flood_intensity / 10.0;
    
    // Multiple turbulence layers
    float turb1 = sin(pos.x * 2.0 + time * 3.0) * sin(pos.z * 1.5 + time * 2.5);
    float turb2 = cos(pos.x * 3.5 + time * 4.0) * cos(pos.z * 2.8 + time * 3.2);
    float turb3 = sin(length(pos.xz) * 4.0 + time * 5.0) * 0.5;
    
    float total_turbulence = (turb1 + turb2 + turb3) * turbulence_strength;
    total_turbulence *= turbulence_factor;
    
    return total_turbulence * 0.5 + 0.5;
}

// Flood Spread Visualization
float flood_spread_pattern(vec3 pos, float time) {
    if (!show_flood_spread) return 1.0;
    
    // Simulate flood spreading over time
    float spread_time = time_since_flood * 24.0;  // Hours since flood
    float spread_radius = 5.0 + spread_time * 2.0;  // Expanding flood zone
    
    float distance = length(pos.xz);
    
    // Flood front (edge of spreading water)
    float flood_front = abs(distance - spread_radius);
    float front_thickness = 2.0;
    float front_intensity = 1.0 / (1.0 + flood_front / front_thickness);
    
    // Pulsing flood front
    float pulse = sin(time * 4.0 + distance * 0.5) * 0.3 + 0.7;
    
    return front_intensity * pulse;
}

// Texas Geography Integration
float texas_geography_modification(vec3 pos, float time) {
    if (!texas_flood_mode) return 1.0;
    
    // Simulate Texas terrain effects on flooding
    // Rivers, plains, urban drainage
    float river_pattern = sin(pos.x * 0.1) * cos(pos.z * 0.15);  // River channels
    float urban_drainage = step(0.3, sin(pos.x * 0.8) * sin(pos.z * 0.6));  // City grid
    float plains_factor = 1.0 - abs(sin(pos.x * 0.05)) * 0.3;  // Texas plains
    
    float geography_effect = (river_pattern + urban_drainage + plains_factor) / 3.0;
    geography_effect *= texas_geography_factor;
    
    return geography_effect * 0.5 + 0.5;
}

// Consciousness Impact Visualization  
float consciousness_impact_effect(vec3 pos, float time) {
    // Flood disaster affects consciousness in expanding rings
    float consciousness_radius = consciousness_impact * 10.0;
    float distance = length(pos);
    
    // Consciousness impact waves
    float impact_wave1 = sin(distance * 0.1 - time * 1.0) * 0.5 + 0.5;
    float impact_wave2 = cos(distance * 0.05 - time * 0.7) * 0.5 + 0.5;
    
    // Consciousness field strength
    float field_strength = 1.0 / (1.0 + distance / consciousness_radius);
    field_strength = pow(field_strength, 1.5);
    
    return (impact_wave1 + impact_wave2) * 0.5 * field_strength;
}

// Prophecy Connection Visualization
float prophecy_connection_effect(vec3 pos, float time) {
    if (!show_prophecy_connection) return 1.0;
    
    // Visual connection from Texas flood to pyramid prophecy
    // Creates energy streams/ley lines between events
    
    // Direction toward pyramids (approximate)
    vec3 pyramid_direction = normalize(vec3(1.0, 0.0, 1.0));  // NE toward Egypt
    float alignment = dot(normalize(pos), pyramid_direction);
    
    // Energy stream visualization
    float stream_intensity = max(0.0, alignment);
    stream_intensity = pow(stream_intensity, 3.0);
    
    // Pulsing connection
    float pulse = sin(time * 2.0 + length(pos) * 0.1) * 0.4 + 0.6;
    
    // Timeline synchronicity
    float sync_factor = sin(time * 3.0 + timeline_position * 10.0) * 0.3 + 0.7;
    
    return stream_intensity * pulse * sync_factor;
}

// Disaster Glow Effect
float disaster_glow_intensity(vec3 pos, float time) {
    // Intense glow at disaster center, fading outward
    float distance = length(pos.xz);
    float glow_radius = flood_radius * 0.5;
    
    // Core disaster glow
    float core_glow = exp(-distance / glow_radius);
    
    // Pulsing disaster energy
    float pulse = sin(time * 3.0) * 0.4 + 0.6;
    pulse = pow(pulse, 1.0 + flood_intensity * 0.1);
    
    // Intensity based on flood severity
    float intensity_factor = flood_intensity / 10.0;
    
    return core_glow * pulse * intensity_factor;
}

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    view_direction = normalize(CAMERA_POSITION_WORLD - world_position);
    distance_to_observer = length(CAMERA_POSITION_WORLD - world_position);
}

void fragment() {
    float time = TIME;
    
    // Calculate flood effects
    float water_height = flood_water_height(world_position, time);
    float turbulence = water_turbulence(world_position, time);
    float spread_pattern = flood_spread_pattern(world_position, time);
    float geography_mod = texas_geography_modification(world_position, time);
    float consciousness_impact = consciousness_impact_effect(world_position, time);
    float prophecy_connection = prophecy_connection_effect(world_position, time);
    float disaster_glow = disaster_glow_intensity(world_position, time);
    
    // Base flood water color
    vec4 water_color = mix(flood_water_color, turbulent_water_color, turbulence);
    
    // Apply geography modifications
    water_color.rgb *= geography_mod;
    
    // Add consciousness impact coloring
    water_color.rgb = mix(water_color.rgb, consciousness_connection_color.rgb, 
                         consciousness_impact * 0.3);
    
    // Add prophecy connection effect
    if (show_prophecy_connection) {
        water_color.rgb = mix(water_color.rgb, consciousness_connection_color.rgb, 
                             prophecy_connection * 0.4);
    }
    
    // Disaster glow overlay
    vec3 glow_contribution = disaster_glow_color.rgb * disaster_glow;
    water_color.rgb += glow_contribution * 0.5;
    
    // Water surface effects
    float surface_foam = step(0.7, turbulence) * 0.3;
    water_color.rgb += vec3(surface_foam);
    
    // Flood spread highlighting
    water_color.rgb += vec3(0.2, 0.4, 0.6) * spread_pattern * 0.3;
    
    // Timeline position effects (recent events are brighter)
    float timeline_brightness = 0.5 + timeline_position * 0.5;
    water_color.rgb *= timeline_brightness;
    
    // Intensity-based brightness
    float intensity_brightness = 0.3 + (flood_intensity / 10.0) * 0.7;
    water_color.rgb *= intensity_brightness;
    
    // Fresnel effect for water surface
    float fresnel = 1.0 - abs(dot(world_normal, view_direction));
    fresnel = pow(fresnel, 2.0);
    water_color.rgb += vec3(0.1, 0.2, 0.3) * fresnel;
    
    // Final color output
    ALBEDO = water_color.rgb;
    EMISSION = water_color.rgb * (1.0 + disaster_glow * 2.0 + consciousness_impact);
    
    // Dynamic alpha based on effects
    float final_alpha = water_color.a;
    final_alpha *= (0.4 + turbulence * 0.3 + spread_pattern * 0.3);
    
    // Fade with distance for performance
    float distance_fade = 1.0 / (1.0 + distance_to_observer * 0.01);
    final_alpha *= distance_fade;
    
    ALPHA = clamp(final_alpha, 0.1, 1.0);
}