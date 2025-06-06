shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque, depth_test_disabled, diffuse_lambert, specular_disabled;

// ===== CONSCIOUSNESS RIPPLE SHADER =====
// PURPOSE: Visualize consciousness propagation as beautiful expanding rings
// REVOLUTIONARY: Makes invisible consciousness visible and interactive

uniform float radius : hint_range(0.0, 50.0) = 1.0;
uniform float thickness : hint_range(0.01, 2.0) = 0.1;
uniform vec4 ripple_color : source_color = vec4(0.0, 1.0, 1.0, 0.8);
uniform float intensity : hint_range(0.0, 3.0) = 1.0;
uniform float time : hint_range(0.0, 1000.0) = 0.0;
uniform float wave_frequency : hint_range(1.0, 20.0) = 10.0;
uniform float wave_amplitude : hint_range(0.0, 0.5) = 0.1;

varying vec3 world_pos;
varying vec3 world_normal;
varying vec2 ripple_uv;

void vertex() {
	// Scale vertex by radius to create expanding ripple
	VERTEX = VERTEX * radius;
	
	// Add consciousness wave distortion - living energy effect
	float wave = sin(VERTEX.x * wave_frequency + time * 5.0) * wave_amplitude;
	wave += cos(VERTEX.z * wave_frequency * 0.7 + time * 3.0) * wave_amplitude * 0.5;
	VERTEX.y += wave * intensity;
	
	// Calculate world position for effects
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	
	// Store UV for ripple calculations
	ripple_uv = UV;
}

void fragment() {
	// Distance from center (0.5, 0.5 is center of plane)
	float dist = length(ripple_uv - vec2(0.5));
	
	// Create ripple ring with smooth edges
	float ring_inner = smoothstep(0.5 - thickness, 0.5 - thickness * 0.5, dist);
	float ring_outer = smoothstep(0.5 + thickness * 0.5, 0.5 + thickness, dist);
	float ring = ring_inner * ring_outer;
	
	// Add consciousness pulse - heartbeat of awareness
	float pulse = sin(time * 8.0 + dist * 20.0) * 0.3 + 0.7;
	ring *= pulse;
	
	// Add energy sparks - random consciousness bursts
	float spark_x = sin(ripple_uv.x * 50.0 + time * 15.0) * 0.5 + 0.5;
	float spark_y = cos(ripple_uv.y * 50.0 + time * 12.0) * 0.5 + 0.5;
	float sparks = smoothstep(0.8, 1.0, spark_x * spark_y) * 0.3;
	
	// Combine ring and sparks
	float final_alpha = (ring + sparks) * intensity * ripple_color.a;
	
	// Add fresnel glow for 3D depth
	vec3 view_dir = normalize(CAMERA_POSITION_WORLD - world_pos);
	float fresnel = pow(1.0 - abs(dot(world_normal, view_dir)), 2.0);
	
	// Final color composition
	ALBEDO = ripple_color.rgb;
	ALPHA = final_alpha;
	
	// Consciousness emission - self-illuminating awareness
	EMISSION = ripple_color.rgb * (final_alpha + fresnel * 0.5) * intensity;
	
	// Add rim lighting for consciousness glow
	EMISSION += ripple_color.rgb * fresnel * 0.3 * intensity;
}