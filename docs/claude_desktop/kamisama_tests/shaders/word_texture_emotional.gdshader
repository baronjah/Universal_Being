shader_type canvas_item;

// Word texture generator - Emotional shader
// Creates textures with emotional resonance based on word characteristics

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
uniform float feeling_intensity = 0.5;  // Intensity of emotional content
uniform float feeling_chaos = 0.3;      // Chaotic nature of emotions
uniform bool feeling_mode = false;      // Special feeling-focused mode
uniform float feeling_wavelength = 4.0; // Wavelength of emotional oscillations

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

// Emotional pattern generator
float emotional_pattern(vec2 uv, float time) {
    // Use word hash and feeling intensity to create emotional patterns
    float hash_factor = float(word_hash % 100) / 100.0;
    
    // Calculate frequencies based on emotional parameters
    float emotion_freq = primary_frequency / 10.0 * (1.0 + feeling_intensity);
    
    // Create emotional offset with more dramatic movement
    vec2 offset = vec2(
        cos(time * 0.5 * feeling_intensity + hash_factor * 6.28),
        sin(time * 0.7 * feeling_intensity + hash_factor * 6.28)
    ) * frequency_variance * (1.0 + feeling_chaos);
    
    // Scale based on emotional intensity
    float scale_factor = float(char_count) / 10.0 + feeling_intensity;
    
    // Main emotional pattern
    vec2 st = uv * noise_scale * scale_factor + offset;
    float pattern = fbm(st * (1.0 + emotion_freq));
    
    // Add pulsing effect for emotional resonance
    float pulse = sin(time * feeling_intensity + pattern * 3.14159);
    pattern = mix(pattern, pattern * (0.8 + 0.2 * pulse), feeling_intensity);
    
    // Add swirls for emotional complexity
    float swirl_factor = feeling_chaos * 0.5;
    vec2 swirl_uv = uv + vec2(
        sin(uv.y * feeling_wavelength + time) * swirl_factor,
        cos(uv.x * feeling_wavelength + time * 0.8) * swirl_factor
    );
    
    float swirl_pattern = fbm(swirl_uv * scale_factor);
    pattern = mix(pattern, swirl_pattern, feeling_chaos);
    
    // Add time-based emotional waves
    pattern += 0.15 * sin(uv.x * 8.0 * emotion_freq + time * feeling_intensity);
    pattern += 0.15 * cos(uv.y * 6.0 * emotion_freq + time * 0.8 * feeling_intensity);
    
    // Special feeling mode adds more dramatic movement
    if (feeling_mode) {
        float dramatic_pulse = pow(abs(sin(time * 0.5)), 3.0) * feeling_intensity;
        pattern = mix(pattern, pattern * dramatic_pulse + 0.5, 0.3);
        
        // Add emotional highlights
        float highlight = pow(pattern, 2.0) * feeling_intensity;
        pattern = mix(pattern, highlight, feeling_intensity * 0.5);
    }
    
    return pattern;
}

// Main shader function
void fragment() {
    // Get UV coordinates
    vec2 uv = UV;
    
    // Generate the emotional pattern
    float pattern = emotional_pattern(uv, time);
    
    // Create emotional color gradient
    vec4 emotion_color = mix(primary_color, secondary_color, pattern);
    
    // Add color pulsing based on feeling intensity
    float pulse_factor = sin(time * feeling_intensity * 2.0) * 0.5 + 0.5;
    vec4 pulse_color = mix(emotion_color, vec4(1.0, 1.0, 1.0, 1.0), pulse_factor * feeling_intensity * 0.3);
    
    // Create glow effect for strong emotions
    float glow = pow(pattern, 2.0) * feeling_intensity;
    vec4 glow_color = mix(pulse_color, vec4(1.0, 1.0, 1.0, 1.0), glow * 0.5);
    
    // Edge effects for emotional boundary
    float edge_factor = (1.0 - abs(uv.x - 0.5) * 2.0) * (1.0 - abs(uv.y - 0.5) * 2.0);
    edge_factor = pow(edge_factor, 0.3) * (0.8 + 0.2 * sin(time * feeling_intensity));
    
    // Final color with emotional resonance
    vec4 final_color = mix(glow_color, primary_color, (1.0 - feeling_intensity) * 0.3);
    
    // Add slight transparency variation for emotional depth
    final_color.a = edge_factor * (0.7 + 0.3 * pattern);
    
    // Output the final color
    COLOR = final_color;
}