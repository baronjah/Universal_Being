shader_type spatial;

// Reality transition parameters
uniform float transition_progress : hint_range(0.0, 1.0) = 0.0;
uniform vec3 from_color : source_color = vec3(0.1, 0.1, 0.2);
uniform vec3 to_color : source_color = vec3(0.1, 0.2, 0.1);
uniform float edge_width : hint_range(0.0, 0.5) = 0.1;
uniform float ripple_speed = 5.0;
uniform float ripple_intensity = 0.3;
uniform float glow_intensity = 1.0;

// Distortion and effect parameters
uniform sampler2D noise_texture;
uniform float distortion_amount : hint_range(0.0, 1.0) = 0.2;
uniform float wave_speed = 2.0;

void vertex() {
	// Apply vertex displacement during transition
	if (transition_progress > 0.0 && transition_progress < 1.0) {
		float wave = sin(TIME * wave_speed + VERTEX.x + VERTEX.y + VERTEX.z) * ripple_intensity;
		float transition_factor = sin(transition_progress * 3.14159);
		
		// Apply subtle vertex displacement during transition
		VERTEX += NORMAL * wave * transition_factor * 0.1;
	}
}

void fragment() {
	// Base color blending between realities
	vec3 base_color = mix(from_color, to_color, transition_progress);
	
	// Create a ripple effect during transition
	float ripple = 0.0;
	if (transition_progress > 0.0 && transition_progress < 1.0) {
		float transition_factor = sin(transition_progress * 3.14159);
		vec2 uv = UV;
		
		// Distortion based on transition progress
		float dist = length(uv - vec2(0.5, 0.5)) * 2.0;
		ripple = sin((dist - TIME * ripple_speed) * 10.0) * ripple_intensity;
		ripple *= transition_factor;
		
		// Edge effect for transition boundary
		float edge_effect = smoothstep(transition_progress - edge_width, transition_progress, dist);
		edge_effect *= smoothstep(dist, transition_progress + edge_width, transition_progress + edge_width * 2.0);
		edge_effect *= transition_factor;
		
		// Apply edge glow
		base_color += edge_effect * glow_intensity * to_color;
	}
	
	// Apply the ripple effect to the final color
	vec3 final_color = base_color + vec3(ripple);
	
	// Set the final material properties
	ALBEDO = final_color;
	METALLIC = 0.1;
	ROUGHNESS = 0.7;
	
	// Add emission for glowing effect
	EMISSION = final_color * glow_intensity * transition_progress;
	
	// Transition effect on transparency
	float alpha_transition = 1.0;
	if (transition_progress > 0.0 && transition_progress < 1.0) {
		float transition_factor = sin(transition_progress * 3.14159);
		alpha_transition = mix(1.0, 0.8, transition_factor);
	}
	ALPHA = alpha_transition;
}