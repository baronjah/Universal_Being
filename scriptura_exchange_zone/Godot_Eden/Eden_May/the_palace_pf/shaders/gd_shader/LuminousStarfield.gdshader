// LuminousStarfield.gdshader
shader_type spatial;
render_mode unshaded, blend_add;

uniform vec4 base_color : source_color = vec4(0.0, 0.05, 0.1, 1.0);
uniform vec4 star_color : source_color = vec4(0.9, 0.9, 1.0, 1.0);
uniform float star_density : hint_range(0, 2) = 1.0;
uniform float star_brightness : hint_range(0, 5) = 1.5;
uniform float flicker_speed : hint_range(0, 5) = 1.0;
uniform float flicker_intensity : hint_range(0, 1) = 0.2;
uniform float rotation_speed : hint_range(0, 1) = 0.02;
uniform float parallax_depth : hint_range(0, 2) = 0.5;

// Hash function for pseudo-random stars
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// Star shape function
float star(vec2 uv, float flare) {
    float d = length(uv);
    float m = 0.05 / d;
    
    // Create star shape
    float rays = max(0.0, 1.0 - abs(uv.x * uv.y * 100.0));
    m += rays * flare;
    m *= smoothstep(1.0, 0.2, d);
    
    return m;
}

void fragment() {
    // Calculate time-based rotation
    float time = TIME * flicker_speed;
    float rotation = TIME * rotation_speed;
    
    // Apply rotation to UVs
    vec2 centered_uv = UV * 2.0 - 1.0;
    float aspect = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
    centered_uv.x *= aspect;
    
    vec2 rotated_uv = vec2(
        centered_uv.x * cos(rotation) - centered_uv.y * sin(rotation),
        centered_uv.x * sin(rotation) + centered_uv.y * cos(rotation)
    );
    
    // Initialize color
    vec3 col = base_color.rgb;
    
    // Create 3 layers of stars with different depths for parallax effect
    for (int layer = 0; layer < 3; layer++) {
        float depth = 1.0 - float(layer) * 0.3 * parallax_depth;
        vec2 uv = rotated_uv * (1.0 + float(layer) * parallax_depth * 0.5);
        
        // Create grid for star positions
        vec2 grid = fract(uv * 5.0 * depth) - 0.5;
        vec2 id = floor(uv * 5.0 * depth);
        
        // Generate stars based on hash
        for (int y = -1; y <= 1; y++) {
            for (int x = -1; x <= 1; x++) {
                vec2 offset = vec2(float(x), float(y));
                float random = hash(id + offset);
                
                // Only create stars with probability based on density
                if (random > (1.0 - star_density * 0.3)) {
                    // Position star within cell with some randomness
                    vec2 star_pos = offset + vec2(
                        sin(random * 13.37 + time) * 0.1,
                        cos(random * 42.42 + time * 0.8) * 0.1
                    );
                    
                    // Calculate distance to star
                    vec2 star_uv = grid - star_pos;
                    
                    // Star flicker
                    float flicker = sin(time * random * 5.0) * flicker_intensity + (1.0 - flicker_intensity);
                    
                    // Star brightness based on random value
                    float brightness = star_brightness * random * depth * flicker;
                    
                    // Generate star
                    float s = star(star_uv, random * 0.5);
                    col += star_color.rgb * s * brightness;
                }
            }
        }
    }
    
    // Add subtle nebula effect
    vec2 nebula_uv = rotated_uv * 0.3;
    float nebula = (
        sin(nebula_uv.x * 3.0 + time * 0.1) * 
        sin(nebula_uv.y * 2.5 + time * 0.08)
    ) * 0.05;
    
    col += star_color.rgb * nebula * star_color.a;
    
    // Output
    ALBEDO = col;
    ALPHA = smoothstep(0.0, 0.2, length(col));
}