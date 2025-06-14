shader_type spatial;
render_mode unshaded, depth_draw_opaque, diffuse_burley, specular_schlick_ggx;

// Notepad 3D Text Shader - Based on Luminus research for dynamic text rendering
uniform sampler2D text_texture : source_color;
uniform vec4 text_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 background_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);
uniform float frequency_intensity : hint_range(0.0, 5.0) = 1.0;
uniform float evolution_factor : hint_range(0.0, 1.0) = 0.0;
uniform float glow_strength : hint_range(0.0, 2.0) = 0.5;
uniform float depth_offset : hint_range(-1.0, 1.0) = 0.0;

// Word evolution animation
uniform float wave_speed : hint_range(0.0, 5.0) = 1.0;
uniform float wave_amplitude : hint_range(0.0, 0.5) = 0.1;
uniform vec2 wave_direction = vec2(1.0, 0.0);

// LOD system uniforms
uniform float lod_distance : hint_range(0.0, 100.0) = 10.0;
uniform float fade_distance : hint_range(0.0, 50.0) = 25.0;

varying vec2 text_uv;
varying float distance_to_camera;

void vertex() {
	text_uv = UV;
	
	// Calculate distance to camera for LOD
	vec4 world_pos = MODEL_MATRIX * vec4(VERTEX, 1.0);
	distance_to_camera = length(CAMERA_POSITION_WORLD - world_pos.xyz);
	
	// Word evolution animation - make text "float" based on frequency
	float wave_effect = sin(TIME * wave_speed + dot(world_pos.xz, wave_direction)) * wave_amplitude;
	wave_effect *= frequency_intensity * evolution_factor;
	
	VERTEX.y += wave_effect;
	
	// Depth offset for layering
	VERTEX.z += depth_offset;
}

// Procedural noise for text effects
float noise(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

// Text glow effect
vec3 text_glow(vec2 uv, vec4 text_sample) {
	vec3 glow = vec3(0.0);
	float glow_size = 0.01 * glow_strength;
	
	// Sample surrounding pixels for glow
	for (float x = -glow_size; x <= glow_size; x += glow_size * 0.5) {
		for (float y = -glow_size; y <= glow_size; y += glow_size * 0.5) {
			vec2 offset = vec2(x, y);
			vec4 sample_color = texture(text_texture, uv + offset);
			float distance_factor = 1.0 - length(offset) / glow_size;
			glow += sample_color.rgb * distance_factor * 0.1;
		}
	}
	
	return glow * text_color.rgb;
}

void fragment() {
	// Sample the text texture
	vec4 text_sample = texture(text_texture, text_uv);
	
	// LOD-based alpha reduction
	float lod_alpha = 1.0;
	if (distance_to_camera > lod_distance) {
		lod_alpha = 1.0 - smoothstep(lod_distance, fade_distance, distance_to_camera);
	}
	
	// Evolution effect - add noise and distortion
	vec2 evolved_uv = text_uv;
	if (evolution_factor > 0.0) {
		float noise_factor = noise(text_uv * 10.0 + TIME * 0.5) * evolution_factor * 0.1;
		evolved_uv += vec2(noise_factor, noise_factor * 0.5);
		text_sample = texture(text_texture, evolved_uv);
	}
	
	// Apply text color
	vec3 final_color = mix(background_color.rgb, text_color.rgb, text_sample.a);
	
	// Add glow effect
	if (glow_strength > 0.0) {
		vec3 glow = text_glow(evolved_uv, text_sample);
		final_color += glow;
	}
	
	// Frequency-based color enhancement
	if (frequency_intensity > 1.0) {
		float enhancement = (frequency_intensity - 1.0) * 0.5;
		final_color = mix(final_color, vec3(0.5, 0.8, 1.0), enhancement * text_sample.a);
	}
	
	// Output
	ALBEDO = final_color;
	ALPHA = text_sample.a * text_color.a * lod_alpha;
	
	// Emission for bright text
	EMISSION = final_color * 0.3 * text_sample.a;
}