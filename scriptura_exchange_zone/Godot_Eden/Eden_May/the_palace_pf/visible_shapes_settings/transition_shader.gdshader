shader_type spatial;

// JSH Ethereal Engine - Multiverse Transition Shader
// Creates visual effects for transitions between different reality zones and scales

uniform vec4 primary_color : source_color = vec4(0.1, 0.3, 0.8, 1.0);
uniform vec4 secondary_color : source_color = vec4(0.8, 0.2, 0.5, 1.0);
uniform float transition_progress : hint_range(0.0, 1.0) = 0.0;
uniform float ripple_speed : hint_range(0.1, 5.0) = 1.0;
uniform float ripple_density : hint_range(1.0, 50.0) = 10.0;
uniform float glow_intensity : hint_range(0.0, 5.0) = 1.0;
uniform float shimmer_speed : hint_range(0.0, 10.0) = 3.0;
uniform sampler2D noise_texture : hint_default_white;
uniform bool enable_reality_distortion = true;
uniform bool enable_dream_effect = false;

// Used for time-based animations
varying vec3 vertex_position;
varying vec3 normal_direction;
varying vec2 uv_interp;

void vertex() {
	// Store position for fragment shader
	vertex_position = VERTEX;
	
	// Pass UV coordinates to fragment shader
	uv_interp = UV;
	
	// Store normal for lighting calculations
	normal_direction = NORMAL;
	
	// Apply vertex displacement if reality distortion is enabled
	if (enable_reality_distortion) {
		// Add ripple effect based on transition progress
		float displacement = sin(ripple_density * length(VERTEX.xz) - TIME * ripple_speed) * 0.05;
		VERTEX.y += displacement * transition_progress;
		
		// Apply scale distortion
		float scale_factor = 1.0 + 0.1 * sin(TIME * 2.0) * transition_progress;
		VERTEX *= mix(1.0, scale_factor, 0.5 * transition_progress);
	}
}

void fragment() {
	// Base color interpolation between primary and secondary colors
	vec3 base_color = mix(primary_color.rgb, secondary_color.rgb, transition_progress);
	
	// Apply noise for irregular transition pattern
	vec2 noise_uv = uv_interp * 2.0 + vec2(TIME * 0.1, TIME * -0.05);
	float noise_value = texture(noise_texture, noise_uv).r;
	
	// Create ripple effect
	float dist = length(vertex_position.xz);
	float ripple = sin(dist * ripple_density - TIME * ripple_speed) * 0.5 + 0.5;
	
	// Combine base color with ripple effect
	vec3 final_color = mix(base_color, base_color * 1.5, ripple * transition_progress);
	
	// Add shimmer effect (faster at transition boundaries)
	float shimmer = sin(TIME * shimmer_speed + dist * 5.0) * 0.5 + 0.5;
	shimmer *= smoothstep(0.4, 0.6, transition_progress);
	final_color += shimmer * 0.2 * transition_progress;
	
	// Dream effect adds ethereal glow and color shifting
	if (enable_dream_effect) {
		// Subtle color shift in dreams
		float hue_shift = sin(TIME * 0.2) * 0.2;
		float sat_boost = 0.2;
		
		// Simple RGB adjustment for dreamy effect
		final_color.r += hue_shift;
		final_color.g -= hue_shift * 0.5;
		final_color.b += hue_shift * 1.5;
		
		// Add pulsing glow
		float dream_pulse = sin(TIME * 0.5) * 0.5 + 0.5;
		final_color += dream_pulse * 0.3 * vec3(0.5, 0.3, 0.9);
	}
	
	// Calculate edge glow based on view angle
	float edge_factor = 1.0 - dot(normalize(normal_direction), normalize(VIEW));
	edge_factor = pow(edge_factor, 2.0);
	
	// Apply edge glow effect
	final_color += edge_factor * glow_intensity * mix(primary_color.rgb, secondary_color.rgb, 1.0 - transition_progress);
	
	// Calculate rim lighting for a holographic effect
	float rim = pow(1.0 - dot(NORMAL, VIEW), 4.0);
	rim *= transition_progress;
	
	// Apply transparency based on transition progress
	float alpha = 1.0;
	if (transition_progress > 0.0 && transition_progress < 1.0) {
		alpha = mix(1.0, 0.8 + 0.2 * noise_value, transition_progress);
	}
	
	// Set final color and alpha
	ALBEDO = final_color;
	ALPHA = alpha;
	
	// Add emission for glow effect
	EMISSION = final_color * glow_intensity * transition_progress;
	
	// Apply metallic and roughness
	METALLIC = 0.7 * transition_progress;
	ROUGHNESS = 0.3 - 0.2 * transition_progress;
	
	// Add rim lighting as specular highlight
	SPECULAR = 0.5 + 0.5 * rim;
}