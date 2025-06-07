// planet_shader.gdshader - Procedural planet surface with terrain
shader_type spatial;

// Planet parameters
uniform vec3 base_color : source_color = vec3(0.2, 0.5, 0.2);
uniform vec3 ocean_color : source_color = vec3(0.1, 0.3, 0.6);
uniform vec3 desert_color : source_color = vec3(0.8, 0.7, 0.5);
uniform vec3 ice_color : source_color = vec3(0.9, 0.95, 1.0);
uniform vec3 mountain_color : source_color = vec3(0.5, 0.4, 0.3);

uniform float ocean_level : hint_range(0.0, 1.0) = 0.5;
uniform float continent_scale : hint_range(1.0, 10.0) = 3.0;
uniform float terrain_height : hint_range(0.0, 0.2) = 0.05;
uniform float ice_caps : hint_range(0.0, 1.0) = 0.2;
uniform float roughness : hint_range(0.0, 1.0) = 0.7;

// Atmosphere and lighting
uniform vec3 atmosphere_color : source_color = vec3(0.5, 0.7, 1.0);
uniform float atmosphere_density : hint_range(0.0, 1.0) = 0.3;

// Textures
uniform sampler2D noise_texture : repeat_enable;
uniform sampler2D detail_texture : repeat_enable;

varying vec3 world_position;
varying vec3 world_normal;
varying vec3 view_direction;
varying float distance_to_camera;

// Improved noise sampling
float get_noise(vec2 uv, float scale) {
    return texture(noise_texture, uv * scale).r;
}

// Fractal Brownian Motion for terrain
float fbm(vec2 uv, int octaves, float scale, float persistence) {
    float value = 0.0;
    float amplitude = 1.0;
    float frequency = scale;
    float max_value = 0.0;
    
    for (int i = 0; i < octaves; i++) {
        value += get_noise(uv, frequency) * amplitude;
        max_value += amplitude;
        amplitude *= persistence;
        frequency *= 2.0;
    }
    
    return value / max_value;
}

// Continental noise (large features)
float get_continental_noise(vec3 pos) {
    vec2 uv = vec2(
        atan(pos.z, pos.x) / (2.0 * PI) + 0.5,
        asin(pos.y) / PI + 0.5
    );
    
    float continental = fbm(uv, 4, continent_scale, 0.5);
    // Add some large-scale features
    continental += fbm(uv, 2, continent_scale * 0.3, 0.6) * 0.5;
    
    return continental;
}

// Mountain noise (small features)
float get_mountain_noise(vec3 pos) {
    vec2 uv = vec2(
        atan(pos.z, pos.x) / (2.0 * PI) + 0.5,
        asin(pos.y) / PI + 0.5
    );
    
    float mountains = fbm(uv, 6, continent_scale * 10.0, 0.4);
    mountains = pow(mountains, 2.0); // Make mountains more peaked
    
    return mountains;
}

// Temperature based on latitude
float get_temperature(vec3 pos) {
    float latitude = abs(pos.y); // 0 at equator, 1 at poles
    return 1.0 - pow(latitude, 2.0); // Warmer at equator
}

// Moisture/rainfall pattern
float get_moisture(vec3 pos, float height) {
    vec2 uv = vec2(
        atan(pos.z, pos.x) / (2.0 * PI) + 0.5,
        asin(pos.y) / PI + 0.5
    );
    
    float moisture = fbm(uv + vec2(100.0), 4, continent_scale * 2.0, 0.6);
    
    // Less moisture at high altitudes
    moisture *= smoothstep(0.8, 0.3, height);
    
    // More moisture near oceans
    moisture += (1.0 - smoothstep(ocean_level - 0.1, ocean_level + 0.1, height)) * 0.3;
    
    return clamp(moisture, 0.0, 1.0);
}

// Determine biome based on temperature, moisture, and height
vec3 get_biome_color(float temperature, float moisture, float height) {
    vec3 color;
    
    // Ocean
    if (height < ocean_level) {
        float depth = (ocean_level - height) / ocean_level;
        color = mix(ocean_color * 1.2, ocean_color * 0.3, depth);
        return color;
    }
    
    // Ice caps
    if (temperature < ice_caps) {
        return ice_color;
    }
    
    // Mountains (high altitude)
    if (height > 0.8) {
        return mix(mountain_color, ice_color, smoothstep(0.8, 0.95, height));
    }
    
    // Biomes based on temperature and moisture
    if (temperature > 0.7) { // Hot
        if (moisture < 0.3) {
            color = desert_color; // Desert
        } else if (moisture < 0.6) {
            color = mix(desert_color, base_color, moisture * 2.0); // Savanna
        } else {
            color = base_color * 1.2; // Tropical forest
        }
    } else if (temperature > 0.4) { // Temperate
        if (moisture < 0.3) {
            color = mix(desert_color, base_color, 0.5); // Grassland
        } else {
            color = base_color; // Forest
        }
    } else { // Cold
        if (moisture < 0.3) {
            color = mix(mountain_color, ice_color, 0.3); // Tundra
        } else {
            color = mix(base_color * 0.7, ice_color, 0.2); // Boreal forest
        }
    }
    
    return color;
}

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    view_direction = normalize(CAMERA_POSITION_WORLD - world_position);
    distance_to_camera = length(CAMERA_POSITION_WORLD - world_position);
    
    // Vertex displacement for terrain
    vec3 normalized_pos = normalize(VERTEX);
    
    float continental = get_continental_noise(normalized_pos);
    float mountains = get_mountain_noise(normalized_pos);
    
    // Combine height influences
    float height = continental;
    if (height > ocean_level) {
        height += mountains * terrain_height * 2.0;
    }
    
    // Apply displacement
    VERTEX += NORMAL * height * terrain_height;
}

void fragment() {
    vec3 normalized_pos = normalize(world_position);
    
    // Get terrain features
    float continental = get_continental_noise(normalized_pos);
    float mountains = get_mountain_noise(normalized_pos);
    float height = continental;
    if (height > ocean_level) {
        height += mountains * 0.2;
    }
    
    // Calculate environmental factors
    float temperature = get_temperature(normalized_pos);
    float moisture = get_moisture(normalized_pos, height);
    
    // Get biome color
    vec3 surface_color = get_biome_color(temperature, moisture, height);
    
    // Add detail texture
    vec2 detail_uv = vec2(
        atan(normalized_pos.z, normalized_pos.x) / (2.0 * PI) + 0.5,
        asin(normalized_pos.y) / PI + 0.5
    ) * 50.0;
    vec3 detail = texture(detail_texture, detail_uv).rgb;
    surface_color *= (detail * 0.3 + 0.7);
    
    // Normal mapping for terrain detail
    vec2 normal_offset = vec2(0.001);
    float height_left = get_continental_noise(normalize(world_position + vec3(-normal_offset.x, 0, 0)));
    float height_right = get_continental_noise(normalize(world_position + vec3(normal_offset.x, 0, 0)));
    float height_up = get_continental_noise(normalize(world_position + vec3(0, normal_offset.y, 0)));
    float height_down = get_continental_noise(normalize(world_position + vec3(0, -normal_offset.y, 0)));
    
    vec3 terrain_normal = normalize(vec3(
        height_left - height_right,
        height_down - height_up,
        normal_offset.x * 2.0
    ));
    
    vec3 final_normal = normalize(world_normal + terrain_normal * 0.3);
    
    // Lighting
    vec3 light_dir = normalize(vec3(1.0, 1.0, 0.5));
    float ndotl = max(dot(final_normal, light_dir), 0.0);
    
    // Ocean specular
    float specular = 0.0;
    if (height < ocean_level) {
        vec3 reflect_dir = reflect(-light_dir, final_normal);
        specular = pow(max(dot(view_direction, reflect_dir), 0.0), 32.0) * 0.5;
    }
    
    // Atmospheric scattering
    float atmosphere = pow(1.0 - dot(world_normal, view_direction), 2.0);
    vec3 atmosphere_contribution = atmosphere_color * atmosphere * atmosphere_density;
    
    // Final color
    vec3 lit_color = surface_color * (ndotl * 0.8 + 0.2) + specular;
    vec3 final_color = mix(lit_color, atmosphere_color, atmosphere * atmosphere_density * 0.5);
    
    ALBEDO = final_color;
    ROUGHNESS = roughness;
    
    // Ocean has low roughness
    if (height < ocean_level) {
        ROUGHNESS = 0.1;
    }
    
    // Distance fog for large planets
    float fog_factor = exp(-distance_to_camera * 0.00001);
    ALBEDO = mix(atmosphere_color * 0.5, ALBEDO, fog_factor);
}