shader_type spatial;
//render_mode unshaded, cull_disabled, depth_draw_never, depth_test_disabled;
render_mode unshaded, cull_disabled, depth_draw_never;

uniform float cloud_seed : hint_range(1, 10000);
uniform vec3 tip_of_dome;
uniform vec3 over_player_head;
uniform mat3 basis_in_direction_of_player;
uniform mat3 basis_of_camera;
uniform vec3 world_pos;
uniform vec3 player_position;
uniform float time;
uniform float noise_scale : hint_range(1, 10000);

#include "res://ShaderInc/FastNoiseLite.gdshaderinc"


void fragment() {
    vec2 uv = UV * 2.0 - 1.0;
    float d = length(uv);

    // Create a 3D position from the 2D UV, centered on the player
    vec3 p = vec3(uv, sqrt(max(0.0, 1.0 - d * d)));
    p = basis_of_camera * p;
    p += player_position;

    // Calculate distance from dome center
    float dist_from_center = length(p - tip_of_dome);

    // Setup FastNoiseLite
    fnl_state noise_state = fnlCreateState(int(cloud_seed));
    noise_state.noise_type = FNL_NOISE_OPENSIMPLEX2;
    noise_state.frequency = 0.01;
    noise_state.fractal_type = FNL_FRACTAL_FBM;
	noise_state.lacunarity = 4.f;
	noise_state.gain = .3f;
    noise_state.octaves = 4;

    // Generate cloud noise
    float n = fnlGetNoise3D(noise_state,
        p.x * 99.0,
        p.y * 99.0,
        p.z * 99.0
    );

//	float n = fnlGetNoise3D(noise_state, p.x * noise_scale, p.y * noise_scale, p.z * noise_scale);

    // Adjust noise based on distance from dome center
    float cloud_factor = smoothstep(0.8, 1.0, dist_from_center / length(over_player_head - tip_of_dome));
    n = mix(n, 0.0, cloud_factor);

    // Create cloud color and density
    vec3 cloud_color = mix(vec3(0.8, 0.8, 0.8), vec3(1.0, 1.0, 1.0), n);
    float cloud_density = smoothstep(0.4, 0.6, n);

    // Create sky gradient
    float sky_gradient = dot(normalize(p - tip_of_dome), vec3(0.0, 1.0, 0.0)) * 0.5 + 0.5;
    vec3 sky_color = mix(vec3(0.5, 0.7, 1.0), vec3(0.0, 0.0, 1.0), sky_gradient);

    // Combine sky and clouds
    vec3 final_color = mix(sky_color, cloud_color, cloud_density);

    ALBEDO = final_color.rgb; // Red color for visibility
    ALPHA = smoothstep(1.0, 0.99, d) * (1.0 - cloud_factor);
}
