shader_type canvas_item;

// Word texture generator - Dimensional shader
// Creates textures with dimensional qualities based on word frequency characteristics

// Word parameters
uniform int word_hash;      // Unique hash based on the word
uniform int char_count;     // Number of characters in the word
uniform float primary_frequency;   // Primary frequency of the word
uniform float frequency_variance;  // Variance in frequencies

// Appearance parameters
uniform float time;         // For animation
uniform float noise_scale;  // Scale of the noise
uniform float word_influence = 0.8;  // How much the word influences the pattern
uniform vec4 primary_color : source_color = vec4(0.3, 0.5, 0.8, 1.0);
uniform vec4 secondary_color : source_color = vec4(0.8, 0.3, 0.5, 1.0);

// Dimensionality
uniform float dimensionality = 3.0;  // Value from 1.0 to 5.0
uniform float depth_scale = 0.5;     // How pronounced the depth appears
uniform float dimension_shift = 0.0;  // For animated dimension shifts

// Feeling parameters
uniform float feeling_intensity = 0.5;  // Influence of emotional content

// Helper functions
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Value noise function
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    
    // Four corners
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    
    // Smooth interpolation
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal Brownian Motion with dimensional variation
float fbm(vec2 st, float dim) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    // Number of octaves based on dimensionality
    int octaves = int(2.0 + dim * 0.8);
    
    // Add different octaves of noise
    for (int i = 0; i < 8; i++) {
        if (i < octaves) {
            value += amplitude * noise(st * frequency);
            
            // Dimensional scaling affects how frequencies interact
            frequency *= 1.8 + (dim - 3.0) * 0.1;
            amplitude *= 0.5 - (dim - 3.0) * 0.02;
        }
    }
    
    return value;
}

// Dimensional layering function
float dimensional_layer(vec2 uv, float depth, float time, float dim) {
    // Offset based on dimensionality and depth
    vec2 offset = vec2(
        cos(time * 0.3 + depth * 3.0) * (dim - 2.0) * 0.01,
        sin(time * 0.2 + depth * 2.0) * (dim - 2.0) * 0.01
    );
    
    // Scale adjustment based on dimensionality
    float scale_adj = 1.0 + (dim - 3.0) * 0.2;
    
    // Layer pattern
    vec2 st = (uv + offset * depth) * scale_adj;
    float pattern = fbm(st * (1.0 + depth * 0.2), dim);
    
    // For higher dimensions, add non-Euclidean-like distortions
    if (dim > 4.0) {
        float distortion = noise(st * 2.0 + vec2(time * 0.1, 0.0)) * (dim - 4.0) * 0.5;
        pattern = mix(pattern, 1.0 - pattern, distortion);
        
        // Add dimensional fracturing
        float fracture = step(0.7, noise(st * 3.0 + vec2(0.0, time * 0.1)));
        pattern = mix(pattern, fracture, (dim - 4.0) * 0.3);
    }
    
    return pattern;
}

// Main dimensional pattern generator
float dimensional_pattern(vec2 uv, float time) {
    // Use word hash to create a unique dimensional pattern
    float hash_factor = float(word_hash % 100) / 100.0;
    
    // Calculate effective dimensionality
    float effect_dim = dimensionality + dimension_shift * sin(time * 0.2);
    
    // Base dimensional pattern
    float pattern = 0.0;
    
    // Number of layers based on dimensionality (more layers for higher dimensions)
    int layers = int(3.0 + effect_dim * 0.5);
    
    // Layer blending factor also controlled by dimensionality
    float layer_blend = 0.6 + (effect_dim - 3.0) * 0.1;
    
    // Generate dimensional layers
    for (int i = 0; i < 8; i++) {
        if (i < layers) {
            float depth = float(i) / float(layers);
            float layer = dimensional_layer(uv, depth, time, effect_dim);
            
            // First layer or blend with previous
            if (i == 0) {
                pattern = layer;
            } else {
                pattern = mix(pattern, layer, layer_blend / float(i));
            }
        }
    }
    
    // Add frequency-based dimensional rifts
    float freq_factor = primary_frequency / 20.0;
    float rift = sin(uv.x * 10.0 * freq_factor + uv.y * 8.0 * freq_factor + time * 0.3);
    rift = smoothstep(0.4, 0.6, rift) * 0.2 * (effect_dim - 2.5) / 2.5;
    
    pattern = mix(pattern, 1.0 - pattern, rift);
    
    // Add dimensional boundaries that shift with dimensionality
    if (effect_dim > 3.5) {
        float boundary = step(0.6, fbm(uv * 3.0 + vec2(time * 0.05), effect_dim));
        pattern = mix(pattern, boundary, (effect_dim - 3.5) * 0.3);
    }
    
    return pattern;
}

// Height map function for normal calculation
float height(vec2 uv, float time) {
    return dimensional_pattern(uv, time) * depth_scale;
}

// Normal map calculation from height field
vec3 calculate_normal(vec2 uv, float time) {
    float eps = 0.01;
    float h = height(uv, time);
    float h_x = height(uv + vec2(eps, 0.0), time);
    float h_y = height(uv + vec2(0.0, eps), time);
    
    // Compute normal from height differences
    vec3 normal = normalize(vec3(
        (h - h_x) / eps,
        (h - h_y) / eps,
        0.3  // Z component controls normal intensity
    ));
    
    return normal * 0.5 + 0.5;  // Convert to 0-1 range
}

// Main shader function
void fragment() {
    // Get UV coordinates
    vec2 uv = UV;
    
    // Generate the dimensional pattern
    float pattern = dimensional_pattern(uv, time);
    
    // Generate normal for lighting
    vec3 normal = calculate_normal(uv, time);
    
    // Simple directional light
    vec3 light_dir = normalize(vec3(0.5, 0.5, 1.0));
    float light = dot(normal * 2.0 - 1.0, light_dir) * 0.5 + 0.5;
    
    // Apply dimensional coloring
    vec4 dim_color = mix(primary_color, secondary_color, pattern);
    
    // Apply lighting with dimensional variation
    float light_intensity = 0.6 + 0.4 * light;
    vec4 lit_color = dim_color * light_intensity;
    
    // Add dimensional highlights
    float highlight = pow(light, 8.0) * 0.8;
    lit_color = mix(lit_color, vec4(1.0, 1.0, 1.0, 1.0), highlight);
    
    // Add dimensional shadows
    float shadow = (1.0 - light) * 0.6;
    lit_color = mix(lit_color, vec4(0.0, 0.0, 0.0, 1.0), shadow * pattern);
    
    // Add depth-based atmospheric effect for higher dimensions
    if (dimensionality > 3.0) {
        float atmosphere = 1.0 - pattern;
        atmosphere = pow(atmosphere, 2.0) * (dimensionality - 3.0) * 0.2;
        vec4 atmosphere_color = vec4(
            primary_color.b,
            primary_color.r,
            primary_color.g,
            1.0
        );
        lit_color = mix(lit_color, atmosphere_color, atmosphere);
    }
    
    // Edge effects based on dimensionality
    float edge_factor = (1.0 - abs(uv.x - 0.5) * 2.0) * (1.0 - abs(uv.y - 0.5) * 2.0);
    edge_factor = pow(edge_factor, 0.3);
    
    // Adjust alpha for dimensional boundaries
    float alpha = edge_factor;
    if (dimensionality > 4.0) {
        // For higher dimensions, add transparent rifts
        alpha = mix(alpha, alpha * pattern, (dimensionality - 4.0) * 0.5);
    }
    
    // Final color with alpha
    vec4 final_color = lit_color;
    final_color.a = alpha;
    
    // Output the final color
    COLOR = final_color;
}