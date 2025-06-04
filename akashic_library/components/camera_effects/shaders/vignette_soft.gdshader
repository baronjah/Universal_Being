shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Vignette parameters
uniform float intensity : hint_range(0.0, 1.0) = 0.2;
uniform float softness : hint_range(0.0, 1.0) = 0.8;
uniform vec4 vignette_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// Optional: Add consciousness influence
uniform float consciousness_level : hint_range(0.0, 7.0) = 1.0;
uniform float consciousness_pulse : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    // Get base color from screen texture
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    // Calculate distance from center (0.0 to 1.0)
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(SCREEN_UV, center);
    
    // Create smooth vignette mask
    float vignette = smoothstep(0.8, 0.2 * softness, dist * (1.0 + intensity));
    
    // Add subtle consciousness pulse effect
    float pulse = 1.0 + (consciousness_pulse * 0.1 * sin(TIME * 2.0));
    vignette = mix(vignette, 1.0, consciousness_pulse * 0.2);
    
    // Apply vignette
    color.rgb = mix(color.rgb, vignette_color.rgb, (1.0 - vignette) * intensity * pulse);
    
    // Output final color
    COLOR = color;
} 