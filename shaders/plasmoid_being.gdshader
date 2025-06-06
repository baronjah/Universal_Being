shader_type canvas_item;

uniform vec4 plasma_color : source_color = vec4(0.5, 0.8, 1.0, 0.8);
uniform float core_intensity : hint_range(0.0, 2.0) = 1.0;
uniform float flow_speed : hint_range(0.0, 5.0) = 2.0;
uniform float pulse_intensity : hint_range(0.0, 2.0) = 1.0;
uniform int consciousness_level : hint_range(0, 7) = 1;
uniform float alpha : hint_range(0.0, 1.0) = 1.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float flash_intensity : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec2 center = vec2(0.5, 0.5);
	float distance = length(UV - center);
	
	// Create plasma effect
	float plasma = sin(TIME * flow_speed + distance * 10.0) * 0.5 + 0.5;
	plasma *= pulse_intensity;
	
	// Core glow
	float glow = 1.0 - smoothstep(0.0, 0.5, distance);
	glow *= core_intensity;
	
	// Consciousness enhancement
	float consciousness_factor = float(consciousness_level) / 7.0;
	glow *= (1.0 + consciousness_factor);
	
	// Final color calculation
	vec4 final_color = plasma_color * (plasma + glow);
	
	// Apply flash effect
	final_color = mix(final_color, flash_color, flash_intensity);
	
	// Apply alpha
	final_color.a *= alpha;
	
	COLOR = final_color;
}