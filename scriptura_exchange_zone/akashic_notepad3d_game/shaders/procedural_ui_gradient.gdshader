shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque, depth_test_disabled, diffuse_burley, specular_schlick_ggx;

// Based on Luminus research: Procedural rounded rectangles with gradients for 3D UI
uniform vec4 color_top : source_color = vec4(0.2, 0.4, 0.8, 0.9);
uniform vec4 color_bottom : source_color = vec4(0.1, 0.2, 0.6, 0.9);
uniform float corner_radius : hint_range(0.0, 0.5) = 0.1;
uniform float border_width : hint_range(0.0, 0.1) = 0.02;
uniform vec4 border_color : source_color = vec4(0.4, 0.6, 1.0, 1.0);
uniform float glow_intensity : hint_range(0.0, 2.0) = 0.3;
uniform float hover_blend : hint_range(0.0, 1.0) = 0.0;
uniform vec4 hover_color : source_color = vec4(0.8, 0.9, 1.0, 1.0);
uniform float time_offset : hint_range(0.0, 10.0) = 0.0;

varying vec2 world_uv;

void vertex() {
	world_uv = UV;
}

// Signed Distance Field for rounded rectangle
float sdf_rounded_rect(vec2 uv, vec2 size, float radius) {
	uv = abs(uv) - size + radius;
	return length(max(uv, 0.0)) + min(max(uv.x, uv.y), 0.0) - radius;
}

// Smooth step function for anti-aliasing
float smooth_edge(float edge) {
	return smoothstep(0.0, fwidth(edge), -edge);
}

void fragment() {
	vec2 uv = world_uv;
	vec2 centered_uv = uv - 0.5; // Center the UV coordinates
	
	// Define the rectangle size (slightly smaller than full UV space)
	vec2 rect_size = vec2(0.4, 0.4);
	
	// Calculate distance to rounded rectangle
	float dist = sdf_rounded_rect(centered_uv, rect_size, corner_radius);
	
	// Main shape mask with smooth edges
	float shape_mask = smooth_edge(dist);
	
	// Border mask
	float border_mask = smooth_edge(dist) - smooth_edge(dist - border_width);
	
	// Gradient calculation
	float gradient_factor = 1.0 - uv.y; // Top to bottom gradient
	vec4 gradient_color = mix(color_bottom, color_top, gradient_factor);
	
	// Add subtle animation based on time
	float pulse = sin(TIME * 2.0 + time_offset) * 0.1 + 1.0;
	gradient_color.rgb *= pulse;
	
	// Hover effect blending
	vec4 final_color = mix(gradient_color, hover_color, hover_blend);
	
	// Apply border
	final_color = mix(final_color, border_color, border_mask);
	
	// Add glow effect
	float glow_dist = max(0.0, -dist * 20.0);
	vec3 glow = final_color.rgb * glow_intensity * exp(-glow_dist);
	final_color.rgb += glow;
	
	// Final output
	ALBEDO = final_color.rgb;
	ALPHA = final_color.a * shape_mask;
	
	// Add emission for unshaded bright appearance
	EMISSION = final_color.rgb * 0.2;
}