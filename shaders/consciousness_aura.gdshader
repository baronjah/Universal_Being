shader_type canvas_item;

// Universal Being Consciousness Aura Shader
// Makes the invisible consciousness VISIBLE through dynamic auras
// Connected to: core/UniversalBeing.gd (consciousness_level property)
// Uses: beings/GemmaAICompanionPlasmoid.gd (AI consciousness visualization)

uniform float consciousness_level : hint_range(0.0, 5.0) = 1.0;
uniform float pulse_speed : hint_range(0.1, 5.0) = 2.0;
uniform float aura_radius : hint_range(0.1, 2.0) = 1.0;
uniform vec4 dormant_color : hint_color = vec4(0.5, 0.5, 0.5, 0.3);      // Gray
uniform vec4 awakening_color : hint_color = vec4(0.9, 0.9, 0.9, 0.4);    // White
uniform vec4 aware_color : hint_color = vec4(0.2, 0.4, 1.0, 0.5);        // Blue
uniform vec4 conscious_color : hint_color = vec4(0.2, 1.0, 0.2, 0.6);    // Green
uniform vec4 enlightened_color : hint_color = vec4(1.0, 0.84, 0.0, 0.8); // Gold
uniform vec4 transcendent_color : hint_color = vec4(1.0, 1.0, 1.0, 1.0); // Pure White

vec4 get_consciousness_color(float level) {
    if (level < 1.0) return mix(dormant_color, awakening_color, level);
    else if (level < 2.0) return mix(awakening_color, aware_color, level - 1.0);
    else if (level < 3.0) return mix(aware_color, conscious_color, level - 2.0);
    else if (level < 4.0) return mix(conscious_color, enlightened_color, level - 3.0);
    else return mix(enlightened_color, transcendent_color, min(level - 4.0, 1.0));
}

void fragment() {
    vec2 centered_uv = UV - 0.5;
    float distance = length(centered_uv) / aura_radius;
    
    // Consciousness-based pulsing with Fibonacci rhythm
    float golden_ratio = 1.618034;
    float pulse = sin(TIME * pulse_speed * golden_ratio + consciousness_level * PI) * 0.5 + 0.5;
    
    // Evolution burst effect for level 5 (transcendent)
    float burst_effect = 1.0;
    if (consciousness_level >= 5.0) {
        burst_effect = 1.0 + sin(TIME * 8.0) * 0.3;
    }
    
    // Aura intensity calculation
    float aura_intensity = (1.0 - smoothstep(0.0, 1.0, distance)) * consciousness_level * 0.2;
    aura_intensity *= pulse * burst_effect;
    
    // Get consciousness color
    vec4 aura_color = get_consciousness_color(consciousness_level);
    
    // Add sparkle effect for higher consciousness
    if (consciousness_level > 3.0) {
        float sparkle = sin(UV.x * 20.0 + TIME * 5.0) * sin(UV.y * 20.0 + TIME * 7.0);
        sparkle = smoothstep(0.7, 1.0, sparkle) * 0.5;
        aura_intensity += sparkle * (consciousness_level - 3.0) * 0.1;
    }
    
    COLOR = aura_color;
    COLOR.a *= aura_intensity;
}