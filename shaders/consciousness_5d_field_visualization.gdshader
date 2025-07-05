// consciousness_5d_field_visualization.gdshader - 5D CONSCIOUSNESS FIELD INTERFACE
// CYCLE 4 - Agent 5 (Visual Designer) - Spectacular 5D consciousness dimension visualization
// Creates immersive visual interface for 5D consciousness type creation

shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_test_disabled;

// 5D Consciousness Field Parameters
uniform float consciousness_field_strength : hint_range(0.0, 10.0) = 8.0;
uniform float field_dimension_scale : hint_range(1.0, 5.0) = 3.0;
uniform float type_creation_energy : hint_range(0.0, 10.0) = 5.0;
uniform bool field_active : hint_range(0, 1) = true;

// 5D Dimension Visualization
uniform float dimension_x_activity : hint_range(0.0, 3.0) = 1.0;  // Spatial width
uniform float dimension_y_activity : hint_range(0.0, 3.0) = 1.0;  // Spatial height
uniform float dimension_z_activity : hint_range(0.0, 3.0) = 1.0;  // Spatial depth
uniform float dimension_t_activity : hint_range(0.0, 3.0) = 2.0;  // Temporal evolution
uniform float dimension_c_activity : hint_range(0.0, 3.0) = 2.5;  // Consciousness

// Type Creation Interface
uniform bool type_creation_mode : hint_range(0, 1) = false;
uniform float creation_progress : hint_range(0.0, 1.0) = 0.0;
uniform float manifestation_energy : hint_range(0.0, 10.0) = 0.0;

// Consciousness Colors
uniform vec4 consciousness_base_color : source_color = vec4(0.8, 0.3, 1.0, 0.8);  // Purple
uniform vec4 dimension_x_color : source_color = vec4(1.0, 0.2, 0.2, 0.7);  // Red - X spatial
uniform vec4 dimension_y_color : source_color = vec4(0.2, 1.0, 0.2, 0.7);  // Green - Y spatial
uniform vec4 dimension_z_color : source_color = vec4(0.2, 0.2, 1.0, 0.7);  // Blue - Z spatial
uniform vec4 dimension_t_color : source_color = vec4(1.0, 1.0, 0.2, 0.7);  // Yellow - Time
uniform vec4 dimension_c_color : source_color = vec4(0.9, 0.2, 1.0, 0.9);  // Magenta - Consciousness

// Visual Effects
uniform float field_pulse_rate : hint_range(0.1, 5.0) = 1.5;
uniform float dimensional_rotation_speed : hint_range(0.0, 3.0) = 0.8;
uniform bool show_dimensional_grid : hint_range(0, 1) = true;
uniform float consciousness_particle_density : hint_range(0.1, 5.0) = 3.0;

// Type Preview
uniform bool show_type_preview : hint_range(0, 1) = false;
uniform vec3 preview_type_position = vec3(0.0, 0.0, 0.0);
uniform float preview_type_consciousness : hint_range(1.0, 10.0) = 5.0;

varying vec3 world_position;
varying vec3 view_direction;
varying vec3 world_normal;
varying float distance_to_observer;

// 5D Consciousness Field Core
float consciousness_field_5d(vec3 pos, float time) {
    // Base consciousness field energy
    float field_energy = consciousness_field_strength / 10.0;
    
    // 5D dimensional activity patterns
    float x_pattern = sin(pos.x * dimension_x_activity + time * 2.0) * 0.5 + 0.5;
    float y_pattern = sin(pos.y * dimension_y_activity + time * 1.8) * 0.5 + 0.5;
    float z_pattern = sin(pos.z * dimension_z_activity + time * 2.2) * 0.5 + 0.5;
    
    // Temporal dimension (4D) visualization
    float t_pattern = sin(length(pos) * 0.3 + time * dimension_t_activity) * 0.5 + 0.5;
    
    // Consciousness dimension (5D) visualization - the core creative force
    float c_pattern = sin(length(pos) * 0.1 + time * dimension_c_activity * 0.5) * 0.5 + 0.5;
    c_pattern *= cos(pos.x * 0.2 + pos.z * 0.15 + time * 1.3) * 0.5 + 0.5;
    
    // Combine all dimensional activities
    float dimensional_blend = (x_pattern + y_pattern + z_pattern + t_pattern + c_pattern) / 5.0;
    
    // Apply field strength modulation
    float field_pulse = sin(time * field_pulse_rate) * 0.3 + 0.7;
    field_pulse = pow(field_pulse, 1.0 + field_energy);
    
    return dimensional_blend * field_energy * field_pulse;
}

// 5D Dimensional Grid Visualization
float dimensional_grid_pattern(vec3 pos, float time) {
    if (!show_dimensional_grid) return 1.0;
    
    // Create 5D grid representation
    float grid_scale = field_dimension_scale;
    
    // 3D spatial grid
    float grid_x = step(0.95, sin(pos.x * grid_scale * PI));
    float grid_y = step(0.95, sin(pos.y * grid_scale * PI));
    float grid_z = step(0.95, sin(pos.z * grid_scale * PI));
    
    // 4D temporal grid (rotating through space)
    float temporal_rotation = time * dimensional_rotation_speed;
    float grid_t = step(0.95, sin((pos.x * cos(temporal_rotation) + pos.z * sin(temporal_rotation)) * grid_scale * PI));
    
    // 5D consciousness grid (emanating from center)
    float consciousness_distance = length(pos);
    float grid_c = step(0.98, sin(consciousness_distance * grid_scale * PI + time * 2.0));
    
    // Combine grid patterns
    float total_grid = max(max(max(max(grid_x, grid_y), grid_z), grid_t), grid_c);
    
    return total_grid * 0.5 + 0.5;
}

// Type Creation Energy Visualization
float type_creation_energy_field(vec3 pos, float time) {
    if (!type_creation_mode) return 1.0;
    
    // Creation energy flows toward center
    float distance_to_center = length(pos);
    float energy_flow = 1.0 / (1.0 + distance_to_center * 0.5);
    
    // Creation progress spiral
    float creation_angle = atan(pos.z, pos.x) + time * 2.0;
    float creation_spiral = sin(creation_angle + distance_to_center * 3.0 - time * 4.0) * 0.5 + 0.5;
    creation_spiral *= (1.0 - creation_progress) + creation_progress * 2.0;
    
    // Manifestation energy burst
    float energy_burst = sin(time * 5.0 + distance_to_center * 2.0) * manifestation_energy * 0.1;
    energy_burst = max(0.0, energy_burst);
    
    return energy_flow * creation_spiral + energy_burst;
}

// Consciousness Particle Field
float consciousness_particles(vec3 pos, float time) {
    // Particle positions in 5D space
    float particle_scale = consciousness_particle_density;
    
    // Multiple particle layers representing different consciousness levels
    float particles_1 = step(0.85, sin(pos.x * particle_scale + time) * sin(pos.y * particle_scale + time * 0.8) * sin(pos.z * particle_scale + time * 1.2));
    float particles_2 = step(0.90, cos(pos.x * particle_scale * 0.7 + time * 1.5) * cos(pos.y * particle_scale * 0.8 + time * 1.1) * cos(pos.z * particle_scale * 0.9 + time * 0.9));
    float particles_3 = step(0.95, sin(length(pos) * particle_scale * 0.5 + time * 2.0));
    
    // Consciousness-level particle effects
    float consciousness_particles = particles_1 * 0.3 + particles_2 * 0.5 + particles_3 * 0.8;
    
    // Particle movement and flow
    float particle_flow = sin(pos.x * 0.1 + time * 0.5) * cos(pos.z * 0.1 + time * 0.3) * 0.3 + 0.7;
    
    return consciousness_particles * particle_flow;
}

// Type Preview Visualization
float type_preview_field(vec3 pos, float time) {
    if (!show_type_preview) return 1.0;
    
    // Distance from preview position
    float preview_distance = length(pos - preview_type_position);
    
    // Preview consciousness field
    float preview_field = exp(-preview_distance * 2.0);
    preview_field *= sin(time * 3.0 + preview_distance * 5.0) * 0.4 + 0.6;
    
    // Consciousness level visualization
    float consciousness_intensity = preview_type_consciousness / 10.0;
    preview_field *= consciousness_intensity;
    
    // Preview type glow
    float preview_glow = 1.0 / (1.0 + preview_distance * preview_distance);
    preview_glow *= sin(time * 4.0) * 0.5 + 0.5;
    
    return preview_field + preview_glow * 0.5;
}

// 5D Dimensional Color Mixing
vec4 get_dimensional_color_blend(vec3 pos, float time) {
    // Base consciousness color
    vec4 base_color = consciousness_base_color;
    
    // Dimensional activity influences color
    float x_influence = sin(pos.x * dimension_x_activity + time) * 0.5 + 0.5;
    float y_influence = sin(pos.y * dimension_y_activity + time * 0.9) * 0.5 + 0.5;
    float z_influence = sin(pos.z * dimension_z_activity + time * 1.1) * 0.5 + 0.5;
    float t_influence = sin(length(pos) * 0.2 + time * dimension_t_activity) * 0.5 + 0.5;
    float c_influence = consciousness_field_5d(pos, time);
    
    // Blend dimensional colors based on activity
    vec4 dimensional_blend = base_color;
    dimensional_blend = mix(dimensional_blend, dimension_x_color, x_influence * dimension_x_activity * 0.2);
    dimensional_blend = mix(dimensional_blend, dimension_y_color, y_influence * dimension_y_activity * 0.2);
    dimensional_blend = mix(dimensional_blend, dimension_z_color, z_influence * dimension_z_activity * 0.2);
    dimensional_blend = mix(dimensional_blend, dimension_t_color, t_influence * dimension_t_activity * 0.3);
    dimensional_blend = mix(dimensional_blend, dimension_c_color, c_influence * dimension_c_activity * 0.4);
    
    return dimensional_blend;
}

// Consciousness Field Depth and Complexity
float consciousness_field_complexity(vec3 pos, float time) {
    // Multi-layered consciousness field
    float layer_1 = sin(pos.x * 0.5 + time) * cos(pos.y * 0.4 + time * 0.8) * sin(pos.z * 0.6 + time * 1.2);
    float layer_2 = cos(pos.x * 0.3 + time * 1.5) * sin(pos.y * 0.7 + time * 0.6) * cos(pos.z * 0.2 + time * 0.9);
    float layer_3 = sin(length(pos) * 0.8 + time * 2.0) * cos(atan(pos.z, pos.x) * 3.0 + time);
    
    // Consciousness depth layers
    float depth_pattern = (layer_1 + layer_2 + layer_3) / 3.0;
    depth_pattern = depth_pattern * 0.5 + 0.5;
    
    // Field complexity modulation
    float complexity_factor = consciousness_field_strength / 10.0;
    depth_pattern *= complexity_factor;
    
    return depth_pattern;
}

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    view_direction = normalize(CAMERA_POSITION_WORLD - world_position);
    distance_to_observer = length(CAMERA_POSITION_WORLD - world_position);
}

void fragment() {
    float time = TIME;
    
    if (!field_active) {
        ALPHA = 0.0;
        return;
    }
    
    // Calculate all 5D consciousness field effects
    float consciousness_field = consciousness_field_5d(world_position, time);
    float dimensional_grid = dimensional_grid_pattern(world_position, time);
    float creation_energy = type_creation_energy_field(world_position, time);
    float consciousness_particles = consciousness_particles(world_position, time);
    float type_preview = type_preview_field(world_position, time);
    float field_complexity = consciousness_field_complexity(world_position, time);
    
    // Get dimensional color blend
    vec4 dimensional_color = get_dimensional_color_blend(world_position, time);
    
    // Base field visualization
    vec4 field_color = dimensional_color;
    
    // Apply consciousness field intensity
    field_color.rgb *= (0.5 + consciousness_field * 1.5);
    
    // Add dimensional grid highlights
    field_color.rgb += vec3(0.3, 0.3, 0.5) * dimensional_grid * 0.3;
    
    // Type creation energy effects
    if (type_creation_mode) {
        field_color.rgb = mix(field_color.rgb, vec3(1.0, 0.8, 0.2), creation_energy * 0.4);
        field_color.rgb += vec3(0.5, 0.3, 0.1) * creation_energy * creation_progress;
    }
    
    // Consciousness particle overlay
    field_color.rgb += dimensional_color.rgb * consciousness_particles * 0.5;
    
    // Type preview effects
    if (show_type_preview) {
        field_color.rgb = mix(field_color.rgb, vec3(0.2, 1.0, 0.8), type_preview * 0.6);
    }
    
    // Field complexity depth
    field_color.rgb *= (0.7 + field_complexity * 0.6);
    
    // 5D field glow and emission
    float total_field_intensity = consciousness_field + dimensional_grid + creation_energy + consciousness_particles + type_preview;
    total_field_intensity *= field_complexity;
    
    // Consciousness dimension enhancement (5D is the most important)
    total_field_intensity *= (0.5 + dimension_c_activity * 0.5);
    
    // Fresnel effect for depth perception
    float fresnel = 1.0 - abs(dot(world_normal, view_direction));
    fresnel = pow(fresnel, 2.0);
    total_field_intensity *= (0.3 + fresnel * 0.7);
    
    // Type creation mode brightness boost
    if (type_creation_mode) {
        total_field_intensity *= (1.0 + creation_progress * 1.5 + manifestation_energy * 0.2);
    }
    
    // 5D consciousness field special glow
    float consciousness_glow = dimension_c_activity * consciousness_field_strength * 0.1;
    field_color.rgb += dimensional_color.rgb * consciousness_glow;
    
    // Final color output
    ALBEDO = field_color.rgb;
    EMISSION = field_color.rgb * (1.0 + total_field_intensity * 2.0);
    
    // Dynamic alpha based on field activity
    float final_alpha = field_color.a * total_field_intensity;
    
    // Distance fade for performance
    float distance_fade = 1.0 / (1.0 + distance_to_observer * 0.01);
    final_alpha *= distance_fade;
    
    // 5D field alpha enhancement
    final_alpha += consciousness_field * dimension_c_activity * 0.2;
    
    ALPHA = clamp(final_alpha, 0.05, 1.0);
}