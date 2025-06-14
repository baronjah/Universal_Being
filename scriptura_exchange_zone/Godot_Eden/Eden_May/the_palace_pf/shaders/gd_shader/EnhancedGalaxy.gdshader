//EnhancedGalaxy.gdshader
shader_type spatial;
render_mode blend_mix, cull_disabled, unshaded;

// Original galaxy parameters
uniform float u_swirl_amount : hint_range(0, 10) = 5.0;
uniform float u_arm_count : hint_range(2, 8) = 4.0;
uniform float u_arm_width : hint_range(0, 1) = 0.465;
uniform float u_star_density : hint_range(0, 1) = 0.1;
uniform float u_star_size : hint_range(1, 1024) = 512.0;
uniform vec3 u_star_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float u_circle_radius : hint_range(0, 0.5) = 0.5;
uniform float u_star_circle_radius : hint_range(0, 0.5) = 0.48;
uniform float u_fog_circle_radius : hint_range(0, 0.5) = 0.5;
uniform float u_seed : hint_range(0, 99999999) = 0.003;
uniform float u_galaxy_temperature : hint_range(0.0, 20000) = 4000;

// New parameters for enhanced visuals
uniform vec3 u_galaxy_color : source_color = vec3(0.5, 0.5, 1.0);  // Base color for fog and core
uniform float u_fog_density : hint_range(0, 1) = 0.5;
uniform float u_core_size : hint_range(0, 1) = 0.1;
uniform float u_noise_scale : hint_range(0.1, 10.0) = 2.0;

// Uniform definitions
uniform vec3 u_arm_color : source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 u_space_color : source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 u_background_color : source_color = vec3(0.0, 0.0, 0.0);
uniform float u_fog_arm_width_multiplier : hint_range(1.0, 2.0) = 1.05;

// Additional uniforms for output, probably not needed?
uniform sampler2D u_output_texture;
uniform vec2 u_output_texture_size;
uniform int u_galaxy_temp;


// SimpleNoise functions
float simple_noise_random(vec2 point) {
    return fract(sin(point.x * 100. + point.y * 654.125) * 55647.8745);
}

float value_noise(vec2 uv) {
    vec2 grid_uv = fract(uv);
    vec2 grid_id = floor(uv);
    grid_uv = grid_uv * grid_uv * (3. - 2. * grid_uv);
    float bottom_left = simple_noise_random(grid_id);
    float bottom_right = simple_noise_random(grid_id + vec2(1, 0));
    float bottom = mix(bottom_left, bottom_right, grid_uv.x);
    float top_left = simple_noise_random(grid_id + vec2(0, 1));
    float top_right = simple_noise_random(grid_id + vec2(1, 1));
    float top = mix(top_left, top_right, grid_uv.x);
    return mix(bottom, top, grid_uv.y);
}

float simple_noise(vec2 uv, float scale, int octaves) {
    octaves = clamp(octaves, 1, 6);
    float noise = value_noise(uv * scale);
    float amplitude = 1.;
    for(int i = 1; i < octaves; i++) {
        scale *= 2.;
        amplitude /= 2.;
        noise += value_noise(uv * scale) * amplitude;
    }
    return noise / 2.;
}


// New function for simplex noise (for fog effect)
vec3 mod289_vec3(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289_vec2(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }

vec3 permute(vec3 x) { return mod289_vec3(((x*34.0)+1.0)*x); }

float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,  // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod289_vec2(i); // Use the vec2 version here
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
        + i.x + vec3(0.0, i1.x, 1.0 ));

    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

// Hash function (if not already present)
float hash(vec2 p, float seed) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(5.3983, 5.4427, 6.9371) + seed);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

// Galaxy generation function
vec4 generate_galaxy4(vec2 uv, float swirl_amount, float arm_count, float arm_width, float star_density, float star_size, vec3 arm_color, vec3 space_color, vec3 star_color, float circle_radius, vec3 background_color, float your_seed_value) {
    vec2 centered_uv = (floor((uv - 0.5) * star_size) / star_size) + 0.5;
    vec2 offset_uv = centered_uv - 0.5;
    float dist = length(offset_uv);
    float angle = atan(offset_uv.y, offset_uv.x);
    
    // Swirl effect
    float swirl = swirl_amount * (1.0 - dist);
    angle += swirl;
    
    // Galaxy arms
    float arm_angle = fract(angle * arm_count / (2.0 * PI));
    
    // Star arms (sharp edges)
    float star_arm_mask = step(0.5 - arm_width/2.0, arm_angle) - step(0.5 + arm_width/2.0, arm_angle);
    
    // Fog arms (wider with gradient)
    float fog_arm_width = arm_width * u_fog_arm_width_multiplier;
    float fog_arm_mask = smoothstep(0.5 - fog_arm_width/2.0, 0.5 - arm_width/2.0, arm_angle) 
                       - smoothstep(0.5 + arm_width/2.0, 0.5 + fog_arm_width/2.0, arm_angle);
    
    // Stars
    float star_hash = hash(centered_uv, your_seed_value);
    float star_mask = step(1.0 - star_density, star_hash) * star_arm_mask;
    
    // Circular cutouts
    float star_circle_mask = step(dist, u_star_circle_radius);
    float fog_circle_mask = smoothstep(u_fog_circle_radius, u_fog_circle_radius - 0.01, dist);
    
    // Combine colors
    vec3 fog_color = mix(space_color, arm_color, fog_arm_mask * fog_circle_mask);
    vec3 galaxy_color = mix(fog_color, star_color, star_mask * star_circle_mask);
    
    float alpha = max(fog_arm_mask * fog_circle_mask, star_mask * star_circle_mask);
    
    return vec4(galaxy_color, alpha);
}

void fragment() {
    // Generate base galaxy
    vec4 galaxy = generate_galaxy4(UV, u_swirl_amount, u_arm_count, u_arm_width, u_star_density, 
                                   u_star_size, u_arm_color, u_space_color, u_star_color, 
                                   u_circle_radius, u_background_color, u_seed);
    
    // Generate noise for fog
    float noise = simple_noise(UV * u_noise_scale, 10.0, 3);
    
    // Apply noise to fog, but not to stars
    vec3 fog_color = mix(u_arm_color, u_galaxy_color, noise * u_fog_density);
    vec3 final_color = mix(fog_color, galaxy.rgb, step(0.99, max(galaxy.r, max(galaxy.g, galaxy.b))));
    
    // Ensure stars are always visible and white
    final_color = mix(final_color, u_star_color, step(0.99, max(galaxy.r, max(galaxy.g, galaxy.b))));
    
    // Calculate final alpha
    float final_alpha = galaxy.a;
    
    // Make dark areas more transparent, but keep stars fully opaque
    if (length(final_color) < 0.1 && max(galaxy.r, max(galaxy.g, galaxy.b)) < 0.99) {
        final_alpha *= length(final_color) * 10.0;
    }
    
    ALBEDO = final_color;
    ALPHA = final_alpha;
}