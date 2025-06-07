// accretion_disk_shader.gdshader - Hot swirling matter around black holes
shader_type spatial;
render_mode unshaded, cull_disabled, blend_add;

// Disk parameters
uniform float inner_radius : hint_range(1.0, 100.0) = 20.0;
uniform float outer_radius : hint_range(10.0, 200.0) = 50.0;
uniform float rotation_speed : hint_range(0.1, 10.0) = 1.0;
uniform float turbulence_scale : hint_range(0.1, 5.0) = 1.0;

// Visual parameters
uniform vec3 hot_color : source_color = vec3(1.0, 0.9, 0.7);
uniform vec3 cool_color : source_color = vec3(1.0, 0.3, 0.1);
uniform float brightness : hint_range(0.1, 10.0) = 3.0;
uniform float opacity : hint_range(0.1, 1.0) = 0.8;

// Doppler effect
uniform float doppler_strength : hint_range(0.0, 1.0) = 0.3;

uniform sampler2D noise_texture : repeat_enable;

varying vec3 world_position;
varying vec3 view_direction;
varying float radial_distance;
varying float angular_position;

// Keplerian velocity profile
float orbital_velocity(float r) {
    // v ∝ 1/√r for Keplerian disk
    return 1.0 / sqrt(r / inner_radius);
}

// Disk density profile
float disk_density(float r) {
    if (r < inner_radius || r > outer_radius) return 0.0;
    
    // Standard thin disk profile
    float normalized_r = (r - inner_radius) / (outer_radius - inner_radius);
    
    // Density peaks at inner edge and falls off
    float density = exp(-normalized_r * 3.0);
    
    // Sharp cutoff at inner edge (inside ISCO)
    density *= smoothstep(0.0, 0.1, normalized_r);
    
    return density;
}

// Temperature profile (hotter near black hole)
float disk_temperature(float r) {
    // T ∝ r^(-3/4) for standard thin disk
    return pow(inner_radius / r, 0.75);
}

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    view_direction = normalize(CAMERA_POSITION_WORLD - world_position);
    
    // Cylindrical coordinates
    radial_distance = length(vec2(VERTEX.x, VERTEX.z));
    angular_position = atan(VERTEX.z, VERTEX.x);
}

void fragment() {
    // Current position in disk coordinates
    vec2 disk_pos = vec2(world_position.x, world_position.z);
    float r = length(disk_pos);
    float theta = atan(disk_pos.y, disk_pos.x);
    
    // Check if we're in the disk
    float density = disk_density(r);
    if (density < 0.001) {
        discard;
    }
    
    // Disk rotation
    float orbital_period = 2.0 * PI * sqrt(r * r * r / (inner_radius * inner_radius * inner_radius));
    float phase = theta - TIME * rotation_speed / orbital_period;
    
    // Spiral structure
    float spiral = sin(phase * 3.0 - r * 0.1) * 0.3 + 0.7;
    
    // Turbulence
    vec2 turb_uv = vec2(phase / (2.0 * PI), r / outer_radius);
    float turbulence = texture(noise_texture, turb_uv * turbulence_scale).r;
    turbulence = turbulence * 0.4 + 0.6;
    
    // Hot spots (magnetic reconnection events)
    float hot_spots = texture(noise_texture, turb_uv * 5.0 + vec2(TIME * 0.1)).r;
    hot_spots = pow(hot_spots, 3.0) * 2.0;
    
    // Temperature determines color
    float temperature = disk_temperature(r);
    temperature *= turbulence;
    temperature += hot_spots * 0.3;
    temperature = clamp(temperature, 0.0, 1.0);
    
    vec3 emission_color = mix(cool_color, hot_color, temperature);
    
    // Doppler shift
    vec3 velocity_direction = vec3(-sin(theta), 0.0, cos(theta));
    float velocity_magnitude = orbital_velocity(r);
    vec3 disk_velocity = velocity_direction * velocity_magnitude;
    
    // Relativistic beaming (simplified)
    float doppler_factor = 1.0 + dot(normalize(disk_velocity), view_direction) * doppler_strength;
    doppler_factor = clamp(doppler_factor, 0.5, 1.5);
    
    // Apply Doppler shift to color and brightness
    emission_color = mix(emission_color, hot_color, (doppler_factor - 1.0) * 2.0);
    float brightness_mod = pow(doppler_factor, 3.0); // Relativistic beaming
    
    // Disk thickness gives vertical structure
    float vertical_pos = abs(world_position.y);
    float scale_height = 0.05 * r; // Thin disk approximation
    float vertical_profile = exp(-vertical_pos * vertical_pos / (scale_height * scale_height));
    
    // Combine all effects
    float final_density = density * spiral * turbulence * vertical_profile;
    vec3 final_color = emission_color * brightness * brightness_mod * final_density;
    
    // Edge fade for smooth appearance
    float edge_fade = smoothstep(outer_radius - 5.0, outer_radius, r);
    final_color *= (1.0 - edge_fade);
    
    ALBEDO = final_color;
    EMISSION = final_color;
    ALPHA = min(final_density * opacity, 1.0);
}