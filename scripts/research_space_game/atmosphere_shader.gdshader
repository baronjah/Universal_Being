// atmosphere_shader.gdshader - Atmospheric scattering effect
shader_type spatial;
render_mode unshaded, cull_front, depth_test_disabled, blend_add;

// Atmosphere parameters
uniform vec3 atmosphere_color : source_color = vec3(0.5, 0.7, 1.0);
uniform float planet_radius : hint_range(1.0, 1000.0) = 10.0;
uniform float atmosphere_radius : hint_range(1.0, 1000.0) = 12.0;
uniform float density_falloff : hint_range(1.0, 10.0) = 5.0;
uniform float intensity : hint_range(0.1, 5.0) = 1.0;
uniform float sun_intensity : hint_range(0.1, 5.0) = 2.0;

// Scattering coefficients
uniform vec3 rayleigh_coefficient = vec3(5.8e-3, 13.5e-3, 33.1e-3);
uniform float mie_coefficient = 2.0e-3;
uniform float rayleigh_scale_height = 8.0;
uniform float mie_scale_height = 1.2;
uniform float mie_g = 0.76; // Mie phase function asymmetry

varying vec3 world_position;
varying vec3 world_normal;
varying vec3 view_direction;
varying vec3 sun_direction;

// Rayleigh phase function
float rayleigh_phase(float cos_theta) {
    return 3.0 / (16.0 * PI) * (1.0 + cos_theta * cos_theta);
}

// Mie phase function (Henyey-Greenstein)
float mie_phase(float cos_theta, float g) {
    float g2 = g * g;
    float denom = 1.0 + g2 - 2.0 * g * cos_theta;
    return (1.0 - g2) / (4.0 * PI * pow(denom, 1.5));
}

// Calculate optical depth (integral of density along ray)
vec2 optical_depth(vec3 ray_origin, vec3 ray_dir, float ray_length, int steps) {
    vec3 step_size = ray_dir * (ray_length / float(steps));
    vec3 current_pos = ray_origin + step_size * 0.5;
    
    vec2 total_depth = vec2(0.0);
    
    for (int i = 0; i < steps; i++) {
        float height = length(current_pos) - planet_radius;
        float normalized_height = height / (atmosphere_radius - planet_radius);
        
        // Density based on height
        float rayleigh_density = exp(-height / rayleigh_scale_height);
        float mie_density = exp(-height / mie_scale_height);
        
        total_depth.x += rayleigh_density * length(step_size);
        total_depth.y += mie_density * length(step_size);
        
        current_pos += step_size;
    }
    
    return total_depth;
}

// Ray-sphere intersection
vec2 ray_sphere_intersect(vec3 ray_origin, vec3 ray_dir, float radius) {
    float a = dot(ray_dir, ray_dir);
    float b = 2.0 * dot(ray_origin, ray_dir);
    float c = dot(ray_origin, ray_origin) - radius * radius;
    float discriminant = b * b - 4.0 * a * c;
    
    if (discriminant < 0.0) {
        return vec2(-1.0);
    }
    
    float sqrt_disc = sqrt(discriminant);
    return vec2((-b - sqrt_disc) / (2.0 * a), (-b + sqrt_disc) / (2.0 * a));
}

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    view_direction = normalize(CAMERA_POSITION_WORLD - world_position);
    
    // Assume sun direction (can be made uniform)
    sun_direction = normalize(vec3(1.0, 0.5, 0.3));
}

void fragment() {
    vec3 ray_origin = CAMERA_POSITION_WORLD;
    vec3 ray_dir = -view_direction;
    
    // Find atmosphere intersection
    vec2 atmosphere_intersect = ray_sphere_intersect(ray_origin, ray_dir, atmosphere_radius);
    
    if (atmosphere_intersect.x < 0.0) {
        discard;
    }
    
    // Check planet intersection
    vec2 planet_intersect = ray_sphere_intersect(ray_origin, ray_dir, planet_radius);
    
    float ray_start = max(0.0, atmosphere_intersect.x);
    float ray_end = atmosphere_intersect.y;
    
    if (planet_intersect.x > 0.0) {
        ray_end = min(ray_end, planet_intersect.x);
    }
    
    float ray_length = ray_end - ray_start;
    
    // Number of sample steps
    const int num_steps = 16;
    const int num_steps_light = 8;
    
    vec3 step_size = ray_dir * (ray_length / float(num_steps));
    vec3 current_pos = ray_origin + ray_dir * ray_start + step_size * 0.5;
    
    vec3 total_rayleigh = vec3(0.0);
    vec3 total_mie = vec3(0.0);
    vec2 total_optical_depth = vec2(0.0);
    
    // March through atmosphere
    for (int i = 0; i < num_steps; i++) {
        float height = length(current_pos) - planet_radius;
        float normalized_height = height / (atmosphere_radius - planet_radius);
        
        // Skip if above atmosphere
        if (normalized_height > 1.0) {
            current_pos += step_size;
            continue;
        }
        
        // Calculate density at current position
        float rayleigh_density = exp(-height / rayleigh_scale_height);
        float mie_density = exp(-height / mie_scale_height);
        
        // Optical depth to current position
        vec2 step_optical_depth = vec2(
            rayleigh_density * length(step_size),
            mie_density * length(step_size)
        );
        
        // Calculate optical depth to sun
        float sun_ray_length = ray_sphere_intersect(current_pos, sun_direction, atmosphere_radius).y;
        vec2 sun_optical_depth = optical_depth(current_pos, sun_direction, sun_ray_length, num_steps_light);
        
        // Total optical depth
        vec2 total_depth = total_optical_depth + sun_optical_depth;
        
        // Calculate scattering
        vec3 rayleigh_scatter = rayleigh_coefficient * rayleigh_density;
        float mie_scatter = mie_coefficient * mie_density;
        
        // Extinction
        vec3 extinction = exp(-(rayleigh_coefficient * total_depth.x + mie_coefficient * total_depth.y));
        
        // Accumulate scattering
        total_rayleigh += rayleigh_scatter * extinction * length(step_size);
        total_mie += vec3(mie_scatter) * extinction * length(step_size);
        
        total_optical_depth += step_optical_depth;
        current_pos += step_size;
    }
    
    // Phase functions
    float cos_theta = dot(ray_dir, sun_direction);
    float rayleigh_phase_val = rayleigh_phase(cos_theta);
    float mie_phase_val = mie_phase(cos_theta, mie_g);
    
    // Final scattering
    vec3 rayleigh = total_rayleigh * rayleigh_phase_val * sun_intensity;
    vec3 mie = total_mie * mie_phase_val * sun_intensity;
    
    // Combine and apply color
    vec3 scattering = (rayleigh + mie) * atmosphere_color * intensity;
    
    // Fade based on view angle (limb brightening)
    float limb = 1.0 - dot(normalize(world_position), view_direction);
    limb = pow(limb, density_falloff);
    
    // Height-based fade
    float height_fade = 1.0 - smoothstep(planet_radius, atmosphere_radius, length(world_position));
    
    // Final color
    vec3 final_color = scattering * limb * height_fade;
    
    ALBEDO = final_color;
    ALPHA = length(final_color) * 0.5;
}