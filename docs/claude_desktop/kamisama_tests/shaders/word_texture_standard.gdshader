shader_type canvas_item;

// Word texture generator - Standard shader
// Converts words into textures based on their frequency characteristics

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
uniform float dimensionality = 3.0;  // How dimensional the texture appears

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

// Fractal Brownian Motion
float fbm(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    // Add different octaves of noise
    for (int i = 0; i < 6; i++) {
        value += amplitude * noise(st * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    
    return value;
}

// Word specific pattern generator
float word_pattern(vec2 uv, float time) {
    // Use word hash to create a unique pattern
    float hash_factor = float(word_hash % 100) / 100.0;
    
    // Calculate frequencies for pattern
    float base_freq = primary_frequency / 10.0;
    
    // Create word-specific offset
    vec2 offset = vec2(
        cos(time * 0.5 + hash_factor * 6.28),
        sin(time * 0.3 + hash_factor * 6.28)
    ) * frequency_variance;
    
    // Scale based on character count
    float scale_factor = float(char_count) / 10.0 + 0.5;
    
    // Main pattern component
    vec2 st = uv * noise_scale * scale_factor + offset;
    float pattern = fbm(st * (1.0 + base_freq));
    
    // Add some variation based on dimensionality
    if (dimensionality > 3.0) {
        // Add another layer of fbm for higher dimensions
        float second_layer = fbm(st * 2.0 + vec2(pattern, pattern));
        pattern = mix(pattern, second_layer, (dimensionality - 3.0) / 2.0);
    }
    
    // Add time-based evolution
    pattern += 0.1 * sin(uv.x * 10.0 * base_freq + time);
    pattern += 0.1 * cos(uv.y * 8.0 * base_freq + time * 0.7);
    
    // Add small noise detail
    pattern += 0.05 * random(uv + vec2(time * 0.1, time * 0.2));
    
    return pattern;
}

// Main shader function
void fragment() {
    // Get UV coordinates
    vec2 uv = UV;
    
    // Generate the main pattern
    float pattern = word_pattern(uv, time);
    
    // Create the final color
    vec4 base_color = mix(primary_color, secondary_color, pattern);
    
    // Add some variation based on UV coordinates for more interest
    float edge_factor = (1.0 - abs(uv.x - 0.5) * 2.0) * (1.0 - abs(uv.y - 0.5) * 2.0);
    edge_factor = pow(edge_factor, 0.3); // Soften the edges
    
    // Mix with a gradient based on feeling intensity
    vec4 feeling_color = vec4(
        primary_color.r * (1.0 - feeling_intensity) + secondary_color.r * feeling_intensity,
        primary_color.g * (1.0 - feeling_intensity) + secondary_color.g * feeling_intensity,
        primary_color.b * (1.0 - feeling_intensity) + secondary_color.b * feeling_intensity,
        1.0
    );
    
    // Final color mix
    vec4 final_color = mix(base_color, feeling_color, pattern * feeling_intensity);
    final_color.a = edge_factor * 0.8 + 0.2; // Add some transparency at edges
    
    // Output the final color
    COLOR = final_color;
}