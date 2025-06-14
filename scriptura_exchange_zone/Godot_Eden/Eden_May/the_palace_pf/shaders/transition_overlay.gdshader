shader_type canvas_item;

uniform float blur_amount : hint_range(0.0, 5.0) = 0.0;
uniform float distortion : hint_range(0.0, 1.0) = 0.0;
uniform float scale_shift : hint_range(0.0, 1.0) = 0.0;
uniform vec2 screen_center = vec2(0.5, 0.5);

void fragment() {
    // Calculate distance from center
    vec2 center_offset = UV - screen_center;
    float dist_from_center = length(center_offset);
    
    // Apply scale distortion effect (zoom in/out)
    float scale_factor = 1.0 + scale_shift * 0.2 * sin(TIME * 2.0 + dist_from_center * 5.0);
    vec2 scaled_uv = screen_center + center_offset * scale_factor;
    
    // Apply radial distortion
    float distortion_strength = distortion * dist_from_center * 2.0;
    vec2 distorted_uv = mix(UV, scaled_uv, distortion_strength);
    
    // Sample with blur
    vec4 color = textureLod(SCREEN_TEXTURE, distorted_uv, blur_amount * 4.0);
    
    // Add cosmic dust effect
    if (distortion > 0.2) {
        // Random dust particles
        float noise = fract(sin(dot(UV, vec2(12.9898, 78.233) * TIME)) * 43758.5453);
        float dust = step(0.995 - distortion * 0.1, noise) * distortion;
        color.rgb += dust * vec3(0.7, 0.8, 1.0);
        
        // Subtle color shift for cosmic effect
        float shift = sin(TIME * 2.0 + UV.x * 10.0) * 0.02 * distortion;
        color.r += shift;
        color.b -= shift;
    }
    
    // Apply vignette effect during transition
    float vignette = 1.0 - smoothstep(0.5, 1.5, dist_from_center * (1.0 + distortion));
    color.rgb *= mix(1.0, vignette, distortion * 0.5);
    
    COLOR = color;
}