// CelestialBody.gdshader

shader_type spatial;
render_mode unshaded;

uniform float star_seed : hint_range(1, 10000);
uniform vec4 color1 : source_color = vec4(1.0, 1.0, 1.0, 1.0);  // White
uniform vec4 color2 : source_color = vec4(0.0, 0.0, 0.0, 1.0);  // Black
uniform vec3 color3 : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 color4 : source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 color5 : source_color = vec3(1.0, 0.5, 0.0);
uniform float noise_scale = 99.0;
uniform float rotation_speed = 0.1;
uniform vec3 player_position;
uniform float time; // Added time variable
uniform vec4 blob_color : source_color = vec4(1.0, 0.5, 0.0, 1.0); // Orange for blobs
uniform float blob_size = 0.5;
varying vec3 vertex_position;
varying vec3 view_direction;
uniform mat3 rotation_matrix;
uniform float offset_one;
uniform float offset_two;
uniform float offset_three;
uniform vec4 flares_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 void_color : source_color = vec4(0.0, 0.0, 0.0, 0.0);

uniform float flare_intensity = 1.0;
uniform float flare_scale = 1.0;

uniform float time_speed : hint_range(0.0, 1.0) = 0.05;
//uniform float time;
uniform float storm_width : hint_range(0.0, 0.5) = 0.3;
uniform float storm_dither_width : hint_range(0.0, 0.5) = 0.07;
//uniform float flare_scale = 1.0;
uniform float flare_seed: hint_range(1, 10);
uniform float circle_amount : hint_range(2.0, 30.0) = 5.0;
uniform float circle_scale : hint_range(0.0, 1.0) = 1.0;

uniform float flare_size = 50.0;
uniform int OCTAVES : hint_range(0, 20, 1) = 4;

uniform float blob_detail_scale = 2.0;
uniform float blob_detail_intensity = 0.3;
uniform float blob_detail_speed = 0.1;
uniform float time_int;

//uniform vec4 flares_color : source_color = vec4(1.0, 0.7, 0.3, 1.0); // Bright orange-yellow

uniform float temperature_star = 2100;
#include "res://ShaderInc/FastNoiseLite.gdshaderinc"

vec3 temperature_to_base_color(float temperature) {
    vec4 colors[7] = vec4[7](
        vec4(1.0, 0.0, 0.0, 1.0), // Red
        vec4(1.0, 0.5, 0.0, 1.0), // Orange
        vec4(1.0, 1.0, 0.0, 1.0), // Yellow
        vec4(1.0, 1.0, 1.0, 1.0), // White
        vec4(0.5, 1.0, 1.0, 1.0), // Light Blue
        vec4(0.0, 0.0, 1.0, 1.0), // Blue
        vec4(0.5, 0.0, 1.0, 1.0)  // Purple
    );

    // Clamp temperature between 2000K and 18000K
    float clamped_temp = clamp(temperature_star, 2000.0, 18000.0);

    // Normalize temperature to 0-1 range
    float normalized_temp = (clamped_temp - 2000.0) / 16000.0;

    float colorIndex = normalized_temp * float(colors.length() - 1);
    int index1 = int(floor(colorIndex));
    int index2 = int(ceil(colorIndex));
    index2 = min(index2, colors.length() - 1); // Ensure we don't go out of bounds

    float t = fract(colorIndex);

    vec4 finalColor = mix(colors[index1], colors[index2], t);

    // Apply gamma correction
    finalColor.rgb = pow(finalColor.rgb, vec3(1.0 / 2.2));
    return finalColor.rgb;
}

float animate_blobs2(float blob_noise) {
    float edge0 = offset_one - 0.3;
    float edge1 = offset_one + 0.1;
    float smooth_factor = smoothstep(edge1, edge0, blob_noise);
    return (blob_noise < offset_one) ? smooth_factor * 3.6 : 0.0;
}

float animate_blobs(float blob_noise) {
    float edge0 = offset_two - 1.0;
    float edge1 = offset_two + 0.5;
    float smooth_factor = smoothstep(edge0, edge1, blob_noise);
    return (blob_noise > offset_two) ? smooth_factor * 3.9 : 0.0;
}



float getDistanceFromCenter(vec3 point) {
	return length(point);
}


float mapFlareNoise(float noise, float distance) {
    if (distance < 0.7) {
        return 0.0; // No flare in core
    } else if (distance < 0.85) {
        // Map noise for inner flare
        return smoothstep(0.7, 0.85, distance) * noise;
    } else {
        // Map noise for outer flare
        return smoothstep(0.85, 1.0, distance) * noise;
    }
}


vec4 get_cloud_color(float noise, float detail, vec3 color_1, vec3 color_2) {
    float cloud_threshold = 0.2;
    float cloud_edge = 0.8;

    float combined_noise = noise + ((detail * 0.5 - 0.25) + offset_one );

    if (combined_noise < cloud_threshold) return vec4(0.0);

    float opacity = smoothstep(cloud_threshold, cloud_edge, combined_noise);
    vec3 cloud_color = mix(color_1, color_2, opacity);
    return vec4(cloud_color, opacity * 0.7);
}

void vertex() {
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
    // Create a 3D position from the 2D UV
    vec2 uv = UV * 2.0 - 1.0;
    float d = length(uv);

	    // Adjust scales for each layer
    float core_scale = 0.93; // Adjust this to change core size
    float blob_scale = 0.98; // Slightly larger than core
    //float flare_scale = 1.0; // Full size for flares

	    // Calculate separate distances for each layer
    float core_d = d / core_scale;
    float blob_d = d / blob_scale;
    float flare_d = d;
    vec3 p = vec3(uv, sqrt(max(0.0, 1.0 - d * d)));

    // Apply rotation
    p = rotation_matrix * p;

    // Setup FastNoiseLite
    fnl_state noise_state = fnlCreateState(int(star_seed));
    noise_state.noise_type = FNL_NOISE_OPENSIMPLEX2;
    noise_state.frequency = 0.01;
    noise_state.fractal_type = FNL_FRACTAL_FBM;
	noise_state.lacunarity = 4.f;
	noise_state.gain = .3f;
    noise_state.octaves = 4;

	fnl_state base_noise_state = fnlCreateState(int(star_seed));
	base_noise_state.noise_type = FNL_NOISE_OPENSIMPLEX2;
	base_noise_state.frequency = 0.01;
	base_noise_state.fractal_type = FNL_FRACTAL_FBM;
	base_noise_state.lacunarity = 4.f;
	base_noise_state.gain = .3f;
    base_noise_state.octaves = 4;

	fnl_state blob_noise_state = fnlCreateState(int(star_seed + 3.69));
	blob_noise_state.noise_type = FNL_NOISE_OPENSIMPLEX2;
	blob_noise_state.frequency = 0.02;
	blob_noise_state.fractal_type = FNL_NOISE_VALUE; //FNL_NOISE_VALUE;
	blob_noise_state.lacunarity = 3.f;
	blob_noise_state.gain = .3f;
    blob_noise_state.octaves = 3;

	fnl_state flares_noise_state = fnlCreateState(int(star_seed + 5.67));
	flares_noise_state.noise_type = FNL_NOISE_OPENSIMPLEX2;
	flares_noise_state.frequency = 0.03;
	flares_noise_state.fractal_type = FNL_NOISE_CELLULAR;
	flares_noise_state.lacunarity = 3.f;
	flares_noise_state.gain = .3f;
    flares_noise_state.octaves = 2;

    // Generate noise for base star appearance
    float n = fnlGetNoise3D(noise_state, p.x * noise_scale, p.y * noise_scale, p.z * noise_scale + (time * 2.2));
    //vec4 star_color = temperature_to_base_color(temperature_star);
    vec3 main_color = temperature_to_base_color(temperature_star);
    vec3 second_color = main_color * 0.3; // Slightly darker
    vec3 blobs_color = main_color * 1.3; // Slightly brighter

	vec3 flaren_colo = main_color * 1.36;
	vec4 flar_color = vec4(flaren_colo.x, flaren_colo.y, flaren_colo.z, 1.0);
	vec4 flarenern_coloroo = vec4((flares_color.x + flaren_colo.x ) * 0.5, (flares_color.y + flaren_colo.y ) * 0.5, (flares_color.z + flaren_colo.z ) * 0.5, flares_color.w);


    // Mix colors based on noise for base star
    vec4 base_color = vec4(mix(second_color, main_color, n * 0.5 + 0.5), 1.0);

    // Generate noise for blobs
    float blob_noise = fnlGetNoise3D(blob_noise_state, p.x * noise_scale * 1.5, p.y * noise_scale * 1.5, p.z * noise_scale * 1.5 + (time * 9.3));

	float blob_noise2 = fnlGetNoise3D(blob_noise_state, p.x * noise_scale * 1.5, p.y * noise_scale * 1.5, p.z * noise_scale * 1.5 + (time * 3.6));


	float distance = getDistanceFromCenter(p);
	vec3 point = p ;//* noise_scale * offset_three;
	float flares_noise = fnlGetNoise3D(flares_noise_state, point.x * noise_scale, point.y  * noise_scale, point.z  * noise_scale + (time * 3.3));
	float flares_noise2 = fnlGetNoise3D(flares_noise_state, point.x * noise_scale, point.y  * noise_scale, point.z  * noise_scale + (time * 6.3));

	float flareEffect = mapFlareNoise(flares_noise, distance);

	vec4 final_color = vec4(0.0, 0.0, 0.0, 0.0); // Fully transparent
	vec4 flare_layer = vec4(0.0);
	vec4 blob_layer = vec4(0.0);
	vec4 core_layer = vec4(0.0);
	vec4 flares_layer = vec4(0.0);


	// Core layer
	if (core_d <= 1.0) {
	    core_layer = base_color;
	    core_layer.a = smoothstep(1.0, 0.99, core_d);
	}
	final_color = mix(final_color, core_layer, core_layer.a);
	// Blob layer
	if (blob_d <= 1.0) {

		vec3 color_1 = main_color.rgb;
		vec3 color_2 = blobs_color.rgb;
		vec4 blobin_color = get_cloud_color(blob_noise, blob_noise2, color_1, color_2);

		//float blobs_opacity = smoothstep(blob_noise, blob_noise2, -0.2);
		blob_layer = mix(final_color, blobin_color * 3.2, blob_noise * blobin_color.a);
		blob_layer.a = smoothstep(1.0, 0.9, blob_d);
	}
	final_color = mix(final_color, blob_layer, blob_layer.a);
// Flare layer
	if (flare_d <= 1.0) {
		//flares_noise  flareEffect
		vec3 color_3 = main_color.rgb;
		vec3 color_4 = flaren_colo.rgb;
		vec4 flarin_color = get_cloud_color(flares_noise, flares_noise, color_3, color_4);
    //flares_layer = vec4(flar_color.rgb, flareEffect);
	//blob_layer = mix(final_color, blobin_color, blob_noise * blobin_color.a);
		flares_layer = mix(final_color, flarin_color, flares_noise * flarin_color.a);
		flare_layer = mix(final_color, flares_layer , flares_layer.a);
	//flare_layer = mix(final_color, flares_layer, flares_layer);
		flare_layer.a = smoothstep(1.0, 0.9, flare_d);
	}

	final_color = mix(final_color, flare_layer, flare_layer.a);

	// Apply final mask
	float mask = smoothstep(1.0, 0.99, d);
	ALBEDO = final_color.rgb;
	ALPHA = final_color.a * mask;
}