// black_hole_shader.gdshader - Black hole with gravitational lensing
shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque, depth_test_disabled;

// Black hole parameters
uniform float event_horizon_radius : hint_range(1.0, 100.0) = 10.0;
uniform float schwarzschild_radius : hint_range(1.0, 100.0) = 10.0;
uniform float warp_strength : hint_range(0.1, 5.0) = 1.0;
uniform float rotation_speed : hint_range(0.0, 10.0) = 1.0;

// Visual parameters
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D star_field : hint_default_white;
uniform vec3 accretion_inner_color : source_color = vec3(1.0, 0.9, 0.7);
uniform vec3 accretion_outer_color : source_color = vec3(1.0, 0.3, 0.1);
uniform float accretion_brightness : hint_range(0.1, 10.0) = 3.0;

varying vec3 world_position;
varying vec3 view_direction;
varying vec3 world_normal;
varying vec2 screen_pos;

// Gravitational lensing deflection angle
vec2 deflection_angle(vec2 impact_parameter, float mass_parameter) {
    float b = length(impact_parameter);
    if (b < 0.001) return vec2(0.0);
    
    // Einstein deflection angle: 4GM/c²b
    float deflection = 4.0 * mass_parameter / b;
    return -deflection * normalize(impact_parameter);
}

// Schwarzschild metric light bending
vec2 schwarzschild_deflection(vec2 pos, float rs) {
    float r = length(pos);
    if (r < rs) return vec2(0.0); // Inside event horizon
    
    // Simplified deflection based on Schwarzschild metric
    float deflection_magnitude = rs / (r * r) * warp_strength;
    return -normalize(pos) * deflection_magnitude;
}

// Accretion disk density and temperature
float accretion_disk_density(vec3 pos, float time) {
    float r = length(pos.xz);
    float inner_radius = event_horizon_radius * 1.5;
    float outer_radius = event_horizon_radius * 5.0;
    
    if (r < inner_radius || r > outer_radius) return 0.0;
    
    // Disk profile (thin disk approximation)
    float height = abs(pos.y);
    float scale_height = 0.1 * r;
    float vertical_profile = exp(-height * height / (scale_height * scale_height));
    
    // Radial density profile
    float normalized_r = (r - inner_radius) / (outer_radius - inner_radius);
    float radial_profile = exp(-normalized_r * 2.0) * (1.0 - exp(-(r - inner_radius) * 0.5));
    
    // Spiral structure
    float angle = atan(pos.z, pos.x);
    float spiral = sin(angle * 3.0 - time * rotation_speed - r * 0.1) * 0.3 + 0.7;
    
    // Turbulence
    float turbulence = sin(pos.x * 10.0 + time) * sin(pos.z * 10.0 - time) * 0.2 + 0.8;
    
    return radial_profile * vertical_profile * spiral * turbulence;
}

// Ray marching for accretion disk
vec3 march_accretion_disk(vec3 ray_origin, vec3 ray_dir, float max_distance) {
    const int steps = 32;
    float step_size = max_distance / float(steps);
    
    vec3 accumulated_color = vec3(0.0);
    float accumulated_density = 0.0;
    
    for (int i = 0; i < steps; i++) {
        vec3 sample_pos = ray_origin + ray_dir * (float(i) * step_size);
        
        float density = accretion_disk_density(sample_pos, TIME);
        if (density > 0.001) {
            // Temperature based on distance (inner disk is hotter)
            float r = length(sample_pos.xz);
            float temperature = 1.0 / (r / event_horizon_radius);
            temperature = clamp(temperature, 0.0, 1.0);
            
            // Doppler shift (simplified)
            vec3 disk_velocity = vec3(-sample_pos.z, 0, sample_pos.x) * rotation_speed / r;
            float doppler = 1.0 + dot(normalize(disk_velocity), ray_dir) * 0.3;
            
            // Color based on temperature
            vec3 color = mix(accretion_outer_color, accretion_inner_color, temperature);
            color *= doppler;
            
            // Accumulate with transparency
            float alpha = density * step_size * 0.5;
            accumulated_color += color * alpha * (1.0 - accumulated_density);
            accumulated_density += alpha * (1.0 - accumulated_density);
            
            if (accumulated_density > 0.95) break;
        }
    }
    
    return accumulated_color * accretion_brightness;
}

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    view_direction = normalize(CAMERA_POSITION_WORLD - world_position);
    
    // Calculate screen position for distortion
    vec4 screen_coord = PROJECTION_MATRIX * VIEW_MATRIX * MODEL_MATRIX * vec4(VERTEX, 1.0);
    screen_pos = screen_coord.xy / screen_coord.w;
}

void fragment() {
    // Get current screen UV
    vec2 screen_uv = SCREEN_UV;
    
    // Distance from black hole center in screen space
    vec2 center_screen = screen_pos;
    vec2 offset = screen_uv - vec2(0.5);
    float screen_dist = length(offset);
    
    // Calculate 3D distance to black hole
    float distance_3d = length(world_position - CAMERA_POSITION_WORLD);
    vec3 to_black_hole = normalize(world_position - CAMERA_POSITION_WORLD);
    
    // Check if we're looking at the event horizon
    float impact_parameter = length(cross(to_black_hole, -view_direction)) * distance_3d;
    
    if (impact_parameter < event_horizon_radius) {
        // Inside event horizon - complete black
        ALBEDO = vec3(0.0);
        ALPHA = 1.0;
        return;
    }
    
    // Gravitational lensing distortion
    vec2 deflection = schwarzschild_deflection(offset * distance_3d, schwarzschild_radius);
    vec2 distorted_uv = screen_uv + deflection / distance_3d;
    
    // Multiple deflection passes for stronger effect near event horizon
    float bend_strength = schwarzschild_radius / (impact_parameter + schwarzschild_radius);
    for (int i = 0; i < 3; i++) {
        vec2 additional_deflection = schwarzschild_deflection(
            (distorted_uv - vec2(0.5)) * distance_3d, 
            schwarzschild_radius * bend_strength
        );
        distorted_uv += additional_deflection / distance_3d * 0.5;
    }
    
    // Photon sphere (light orbit) effect
    float photon_radius = schwarzschild_radius * 1.5;
    if (impact_parameter < photon_radius && impact_parameter > event_horizon_radius) {
        // Light bending around black hole can show what's behind it
        float orbit_amount = 1.0 - (impact_parameter - event_horizon_radius) / 
                            (photon_radius - event_horizon_radius);
        orbit_amount = pow(orbit_amount, 2.0);
        
        // Wrap UV coordinates for extreme bending
        distorted_uv = mix(distorted_uv, 1.0 - distorted_uv, orbit_amount * 0.5);
    }
    
    // Sample background through distortion
    vec3 background = texture(screen_texture, distorted_uv).rgb;
    
    // Add distorted star field for distant stars
    vec2 star_uv = distorted_uv * 3.0;
    vec3 stars = texture(star_field, star_uv).rgb;
    background = max(background, stars * 0.5);
    
    // Gravitational redshift
    float redshift_factor = 1.0 - schwarzschild_radius / (impact_parameter + schwarzschild_radius);
    background *= vec3(1.0, redshift_factor, redshift_factor * redshift_factor);
    
    // Accretion disk
    vec3 disk_color = march_accretion_disk(
        CAMERA_POSITION_WORLD,
        -view_direction,
        distance_3d * 2.0
    );
    
    // Einstein ring effect
    float ring_width = 0.1;
    float ring_radius = schwarzschild_radius * 1.5 / distance_3d;
    float ring_dist = abs(screen_dist - ring_radius);
    float ring_intensity = exp(-ring_dist * ring_dist / (ring_width * ring_width)) * bend_strength;
    vec3 einstein_ring = vec3(0.5, 0.7, 1.0) * ring_intensity * 2.0;
    
    // Combine all effects
    vec3 final_color = background + disk_color + einstein_ring;
    
    // Fade to black near event horizon
    float horizon_fade = smoothstep(0.0, 0.1, 
        (impact_parameter - event_horizon_radius) / event_horizon_radius);
    final_color *= horizon_fade;
    
    ALBEDO = final_color;
    ALPHA = 1.0;
}