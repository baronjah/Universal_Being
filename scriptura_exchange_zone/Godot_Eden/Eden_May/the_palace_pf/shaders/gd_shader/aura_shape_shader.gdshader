
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 aura_color : source_color = vec4(0.3, 0.6, 1.0, 0.5);
uniform float pulse_speed = 2.0;
uniform float noise_scale = 0.5;

void fragment() {
//	vec3 world_pos = (CAMERA_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float time = TIME * pulse_speed;

	// Noise-based aura
//	float noise = fract(sin(dot(world_pos.xy, vec2(12.9898,78.233))) * 43758.5453);
//	float dist = length(world_pos - CAMERA_POSITION_VIEW);
//	float falloff = smoothstep(10.0, 0.0, dist);

	// Pulsing effect
	float pulse = (sin(time) + 1.0) * 0.5;

	ALBEDO = aura_color.rgb;
//	ALPHA = aura_color.a * falloff * mix(0.8, 1.2, noise) * pulse;
	EMISSION = aura_color.rgb * 2.0;
}
