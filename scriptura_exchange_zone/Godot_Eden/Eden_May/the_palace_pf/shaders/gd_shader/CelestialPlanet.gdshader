// CelestialPlanet.gdshader

shader_type spatial;
render_mode unshaded;

uniform float planet_seed : hint_range(1, 10000);
uniform vec4 color1 : source_color = vec4(1.0, 1.0, 1.0, 1.0);  // White
uniform vec4 color2 : source_color = vec4(0.0, 0.0, 0.0, 1.0);  // Black
uniform float noise_scale = 96.0;

uniform float time; // Added time variable
uniform mat3 rotation_matrix; // our position
uniform float offset_one;
uniform float offset_two;
uniform float offset_three;

// rotation position matrixes
uniform mat3 direction_matrix; // light point
uniform mat3 position_matrix; // our position
uniform vec3 planet_position;

//star light and darkness stuff
uniform vec3 light_color = vec3(1.0, 1.0, 1.0); // Slightly yellow sunlight
uniform float ambient_strength = 0.005;
uniform float diffuse_strength = 0.9;
uniform float specular_strength = 1.0;
uniform float shininess = 4.0;

// Define your colors
uniform vec4 water_deep_blue : source_color = vec4(0.0, 0.0, 0.5, 1.0); // first color for planets
uniform vec4 water_aqua_blue : source_color = vec4(0.0, 0.5, 1.0, 1.0); // second color for planets
uniform vec4 sandy_yellow : source_color = vec4(1.0, 0.9, 0.2, 1.0); // third color for planets
uniform vec4 lowlands_green : source_color = vec4(0.0, 0.8, 0.0, 1.0); // fourth color for planets
uniform vec4 highlands_deep_green : source_color = vec4(0.0, 0.5, 0.0, 1.0); // fifth color for planets
uniform vec4 mountain_gray : source_color = vec4(0.5, 0.5, 0.5, 1.0); // sixth color for planets
uniform vec4 mountain_white : source_color = vec4(1.0, 1.0, 1.0, 1.0); // seventh color for planets

uniform vec4 atmosphere_color : source_color = vec4(0.52, 0.9, 0.9, 1.0);  // Light blue 135, 206, 235 0.52, 0.9, 0.9
uniform float atmosphere_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float atmosphere_falloff : hint_range(1.0, 5.0) = 1.0;
uniform float atmosphere_size : hint_range(0.0, 0.2) = 0.1;  // How far the atmosphere extends beyond the planet's edge
uniform float cloud_extend : hint_range(0.0, 0.1) = 0.02; // How much clouds extend beyond planet edge
uniform int planet_type : hint_range(0 , 5) = 0; // 0 - earth like planet, 1 - Rocky Planet , 2 - Ice Planet, 3 - Fire Planet, 4 - Exo Planet, kinda like earth planets, but its purple and green, purple lands and green water, 5 - Gas Giants

uniform float stripe_scale = 0.1;
uniform float sphere_scale = 2.0;

#include "res://ShaderInc/FastNoiseLite.gdshaderinc"


vec4 get_cloud_color(float noise, float detail, vec3 color_one, vec3 color_two) {
    float cloud_threshold = 0.1;
    float cloud_edge = 0.9;

    float combined_noise = noise + detail;//(detail * 0.5 - 0.25);

    if (combined_noise < cloud_threshold) return vec4(0.0);

    float opacity = smoothstep(cloud_threshold, cloud_edge, combined_noise);
    vec3 cloud_color = mix(color_one, color_two, opacity);
    return vec4(cloud_color, opacity * 0.9);
}

vec4 get_first_planet_color(int type_of_planet){
    vec4 first_planet_color;
    if (type_of_planet == 0) first_planet_color = vec4(0.0, 0.0, 0.5, 1.0); // Earth-like (water_deep_blue)
    else if (type_of_planet == 1) first_planet_color = vec4(0.5, 0.0, 0.0, 1.0); // Rocky Red (Dark Red)
    else if (type_of_planet == 2) first_planet_color = vec4(0.565, 0.761, 0.886, 1.0); // Ice (Deep Ice Blue)
    else if (type_of_planet == 3) first_planet_color = vec4(0.545, 0.0, 0.0, 1.0); // Fire (Deep Lava Red)
    else if (type_of_planet == 4) first_planet_color = vec4(0.08, 0.39, 0.26, 1.0); // Exo (Dark Green)
    else if (type_of_planet == 5) first_planet_color = vec4(0.2, 0.2, 0.2, 1.0); // Rocky Grey (Dark Gray)
	else if (type_of_planet == 6) first_planet_color = vec4(0.6, 0.3, 0.0, 1.0); // Gas Giant (Deep Orange)
    return first_planet_color;
}

vec4 get_second_planet_color(int type_of_planet){
    vec4 second_planet_color;
    if (type_of_planet == 0) second_planet_color = vec4(0.0, 0.5, 1.0, 1.0); // Earth-like (water_aqua_blue)
    else if (type_of_planet == 1) second_planet_color = vec4(1.0, 0.0, 0.0, 1.0); // Rocky Red (Red)
    else if (type_of_planet == 2) second_planet_color = vec4(0.878, 0.969, 1.0, 1.0); // Ice (Pale Blue)
    else if (type_of_planet == 3) second_planet_color = vec4(1.0, 0.27, 0.0, 1.0); // Fire (Lava Orange)
    else if (type_of_planet == 4) second_planet_color = vec4(0.47, 0.88, 0.64, 1.0); // Exo (Light Green)
    else if (type_of_planet == 5) second_planet_color = vec4(0.5, 0.5, 0.5, 1.0); // Rocky Grey (Gray)
	else if (type_of_planet == 6) second_planet_color = vec4(0.8, 0.6, 0.2, 1.0); // Gas Giant (Light Orange)
    return second_planet_color;
}


vec4 get_third_planet_color(int type_of_planet){
	vec4 third_planet_color;
    if (type_of_planet == 0) third_planet_color = vec4(1.0, 0.9, 0.2, 1.0); // Earth-like (sandy_yellow)
    else if (type_of_planet == 1) third_planet_color = vec4(1.0, 0.5, 0.0, 1.0); // Rocky Red (Orange)
    else if (type_of_planet == 2) third_planet_color = vec4(0.780, 0.824, 0.851, 1.0); // Ice (Glacier Grey)
    else if (type_of_planet == 3) third_planet_color = vec4(1.0, 0.0, 0.0, 1.0); // Fire (Red)
    else if (type_of_planet == 4) third_planet_color = vec4(0.72, 0.49, 0.83, 1.0); // Exo (Light Purple)
    else if (type_of_planet == 5) third_planet_color = vec4(0.8, 0.8, 0.8, 1.0); // Rocky Grey (Light Gray)
	else if (type_of_planet == 6) third_planet_color = vec4(0.9, 0.8, 0.5, 1.0); // Gas Giant (Pale Yellow)
	return third_planet_color;
}

vec4 get_fourth_planet_color(int type_of_planet){
	vec4 fourth_planet_color;
    if (type_of_planet == 0) fourth_planet_color = vec4(0.0, 0.8, 0.0, 1.0); // Earth-like (lowlands_green)
    else if (type_of_planet == 1) fourth_planet_color = vec4(1.0, 1.0, 0.0, 1.0); // Rocky Red (Yellow)
    else if (type_of_planet == 2) fourth_planet_color = vec4(0.761, 0.906, 1.0, 1.0); // Ice (Frosty Blue)
    else if (type_of_planet == 3) fourth_planet_color = vec4(1.0, 0.549, 0.0, 1.0); // Fire (Bright Flame)
    else if (type_of_planet == 4) fourth_planet_color = vec4(0.56, 0.25, 0.79, 1.0); // Exo (Medium Purple)
    else if (type_of_planet == 5) fourth_planet_color = vec4(1.0, 1.0, 1.0, 1.0); // Rocky Grey (White)
	else if (type_of_planet == 6) fourth_planet_color = vec4(1.0, 0.9, 0.7, 1.0); // Gas Giant (Cream)
	return fourth_planet_color;
}

vec4 get_fifth_planet_color(int type_of_planet){
	vec4 fifth_planet_color;
    if (type_of_planet == 0) fifth_planet_color = vec4(0.0, 0.5, 0.0, 1.0); // Earth-like (highlands_deep_green)
    else if (type_of_planet == 1) fifth_planet_color = vec4(0.8, 0.6, 0.4, 1.0); // Rocky Red (Light Brown)
    else if (type_of_planet == 2) fifth_planet_color = vec4(0.847, 0.886, 0.914, 1.0); // Ice (Light Grey)
    else if (type_of_planet == 3) fifth_planet_color = vec4(0.2, 0.2, 0.2, 1.0); // Fire (Dark Grey)
    else if (type_of_planet == 4) fifth_planet_color = vec4(0.36, 0.04, 0.48, 1.0); // Exo (Dark Purple)
    else if (type_of_planet == 5) fifth_planet_color = vec4(0.4, 0.4, 0.6, 1.0); // Rocky Grey (Blueish Gray)
	return fifth_planet_color;
}

vec4 get_sixth_planet_color(int type_of_planet){
	vec4 sixth_planet_color;
    if (type_of_planet == 0) sixth_planet_color = vec4(0.5, 0.5, 0.5, 1.0); // Earth-like (mountain_gray)
    else if (type_of_planet == 1) sixth_planet_color = vec4(0.6, 0.3, 0.1, 1.0); // Rocky Red (Dark Brown)
    else if (type_of_planet == 2) sixth_planet_color = vec4(1.0, 1.0, 1.0, 1.0); // Ice (Snow White)
    else if (type_of_planet == 3) sixth_planet_color = vec4(0.0, 0.0, 0.0, 1.0); // Fire (Black)
    else if (type_of_planet == 4) sixth_planet_color = vec4(0.5, 0.34, 0.6, 1.0); // Exo (Greyish Purple)
    else if (type_of_planet == 5) sixth_planet_color = vec4(0.5, 0.4, 0.3, 1.0); // Rocky Grey (Brownish Gray)
	return sixth_planet_color;
}

vec4 get_seventh_planet_color(int type_of_planet){
	vec4 seventh_planet_color;
    if (type_of_planet == 0) seventh_planet_color = vec4(1.0, 1.0, 1.0, 1.0); // Earth-like (mountain_white)
    else if (type_of_planet == 1) seventh_planet_color = vec4(0.3, 0.1, 0.1, 1.0); // Rocky Red (Very Dark Red)
    else if (type_of_planet == 2) seventh_planet_color = vec4(0.694, 0.878, 1.0, 1.0); // Ice (Icy Blue)
    else if (type_of_planet == 3) seventh_planet_color = vec4(0.0, 0.0, 0.0, 1.0); // Fire (Black)
    else if (type_of_planet == 4) seventh_planet_color = vec4(0.64, 0.84, 0.79, 1.0); // Exo (Atmospheric Purple)
    else if (type_of_planet == 5) seventh_planet_color = vec4(0.0, 0.0, 0.0, 1.0); // Rocky Grey (Black)
	return seventh_planet_color;
}


vec4 get_surface_color(float noise, vec4 first_planet_color, vec4 second_planet_color, vec4 third_planet_color, vec4 fourth_planet_color, vec4 fifth_planet_color, vec4 sixth_planet_color, vec4 seventh_planet_color){
    // Define the colors for the height map
    vec4 colors[7] = vec4[7](
        first_planet_color,      // Deep water
        second_planet_color,     // Shallow water
        third_planet_color,      // Beach
        fourth_planet_color,     // Lowlands
        fifth_planet_color,      // Highlands
        sixth_planet_color,      // Mountains
        seventh_planet_color     // Snowy peaks
    );

    // Normalize the height to the range 0-1
    float normalized_height = clamp((noise + 0.5) / 2.0, 0.0, 1.0); // unknown identifier in expresion height

    float colorIndex = normalized_height * float(colors.length() - 1);
    int index1 = int(floor(colorIndex));
    int index2 = int(ceil(colorIndex));
    index2 = min(index2, colors.length() - 1); // Ensure we don't go out of bounds

    float t = fract(colorIndex);

    return mix(colors[index1], colors[index2], t);
}

void vertex() {
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
	// Create a 3D position from the 2D UV
	vec2 uv = UV * 2.0 - 1.0;
	float d = length(uv);

	// Adjust scales for each layer
	float core_scale = 0.9; // Adjust this to change core size
	float blob_scale = 0.95; // Slightly larger than core


	// Calculate separate distances for each layer
	float core_d = d / core_scale;
    float blob_d = d / blob_scale;
    float flare_d = d;
    vec3 p = vec3(uv, sqrt(max(0.0, 1.0 - d * d)));

    // Apply rotation
    p = rotation_matrix * p;

    // Setup FastNoiseLite for planets lands and maybe waters lol
    fnl_state noise_state = fnlCreateState(int(planet_seed));
    noise_state.noise_type = FNL_NOISE_OPENSIMPLEX2;
    noise_state.frequency = 0.01;
    noise_state.fractal_type = FNL_FRACTAL_FBM;
	noise_state.lacunarity = 4.f;
	noise_state.gain = .3f;
    noise_state.octaves = 4;
    // not used yet?
	fnl_state base_noise_state = fnlCreateState(int(planet_seed));
	base_noise_state.noise_type = FNL_NOISE_OPENSIMPLEX2;
	base_noise_state.frequency = 0.01;
	base_noise_state.fractal_type = FNL_FRACTAL_FBM;
	base_noise_state.lacunarity = 4.f;
	base_noise_state.gain = .3f;
    base_noise_state.octaves = 4;
	// we use it for them clouds!
	fnl_state blob_noise_state = fnlCreateState(int(planet_seed + 3.69));
	blob_noise_state.noise_type = FNL_NOISE_OPENSIMPLEX2;
	blob_noise_state.frequency = 0.02;
	blob_noise_state.fractal_type = FNL_FRACTAL_FBM;
	blob_noise_state.lacunarity = 3.f;
	blob_noise_state.gain = .3f;
    blob_noise_state.octaves = 3;
	// another not used noise :(
	fnl_state flares_noise_state = fnlCreateState(int(planet_seed + 5.67));
	flares_noise_state.noise_type = FNL_NOISE_OPENSIMPLEX2;
	flares_noise_state.frequency = 0.005 + (offset_three * 0.0005);
	flares_noise_state.fractal_type = FNL_NOISE_CELLULAR;
	flares_noise_state.lacunarity = 3.f;
	flares_noise_state.gain = .3f;
    flares_noise_state.octaves = 2;

	fnl_state new_type_circl = fnlCreateState(int(planet_seed + 3.69));
	new_type_circl.noise_type = FNL_NOISE_OPENSIMPLEX2;
	new_type_circl.frequency = 0.5;
	new_type_circl.fractal_type = FNL_NOISE_VALUE; //FNL_NOISE_VALUE;
	new_type_circl.lacunarity = 3.f;
	new_type_circl.gain = .3f;
    new_type_circl.octaves = 3;


    // Setup noise for stripes
    fnl_state stripe_noise_state = fnlCreateState(int(planet_seed));
    stripe_noise_state.noise_type = FNL_NOISE_OPENSIMPLEX2;
    stripe_noise_state.frequency = 0.5;
    stripe_noise_state.fractal_type = FNL_FRACTAL_FBM;
    stripe_noise_state.octaves = 4;
    stripe_noise_state.lacunarity = 2.0;
    stripe_noise_state.gain = 0.5;

    // Setup noise for spherical features
    fnl_state sphere_noise_state = fnlCreateState(int(planet_seed + 1000.0));
    sphere_noise_state.noise_type = FNL_NOISE_CELLULAR;
    sphere_noise_state.cellular_distance_func = FNL_CELLULAR_DISTANCE_EUCLIDEANSQ;
    sphere_noise_state.noise_type = FNL_NOISE_CELLULAR;
    sphere_noise_state.frequency = 1.3;
	sphere_noise_state.cellular_return_type = FNL_CELLULAR_RETURN_TYPE_DISTANCE;
    sphere_noise_state.cellular_jitter_mod = 1.0;
    sphere_noise_state.fractal_type = FNL_FRACTAL_PINGPONG;
    sphere_noise_state.octaves = 5;
    sphere_noise_state.lacunarity = 1.8;
    sphere_noise_state.gain = 0.0;
    sphere_noise_state.weighted_strength = 1.0;
    sphere_noise_state.ping_pong_strength = 3.0;



	vec4 final_color = vec4(0.0, 0.0, 0.0, 0.0);

	if (planet_type <= 5) {

    // Generate noise for base star appearance
    float n = fnlGetNoise3D(noise_state, p.x * noise_scale, p.y * noise_scale, p.z * noise_scale);

	vec4 first_color = get_first_planet_color(planet_type);
	vec4 second_color = get_second_planet_color(planet_type);
	vec4 third_color = get_third_planet_color(planet_type);
	vec4 fourth_color = get_fourth_planet_color(planet_type);
	vec4 fifth_color = get_fifth_planet_color(planet_type);
	vec4 sixth_color = get_sixth_planet_color(planet_type);
	vec4 seventh_color = get_seventh_planet_color(planet_type);
	vec4 base_color = get_surface_color(n, first_color, second_color, third_color, fourth_color, fifth_color, sixth_color, seventh_color);

	vec4 atmospheric_color = first_color;
	 // Fully transparent
	vec4 flare_layer = vec4(0.0);
	vec4 blob_layer = vec4(0.0);
	vec4 core_layer = vec4(0.0);
	vec4 atmosphere_layer = vec4(0.0);
	vec4 atmosphere_layer2 = vec4(0.0);

	float cloud_noise = fnlGetNoise3D(blob_noise_state, p.x * noise_scale * 1.5, p.y * noise_scale * 1.5, p.z * noise_scale * 1.5 + (time * 3.1));
	float cloud_detail = fnlGetNoise3D(blob_noise_state, p.x * noise_scale * 1.5, p.y * noise_scale * 1.5, p.z * noise_scale * 1.5 + (time * 3.1));
	//atmosphere_color = first_color
if (d <= 1.0); {
	//atmosphere_effect
    float atmosphere_factor = 1.0 - smoothstep(0.0, atmosphere_falloff, d);
    vec4 atmosphere_effect = atmospheric_color * atmospheric_color * atmosphere_intensity;
	flare_layer = mix(atmospheric_color, atmospheric_color, atmospheric_color * atmosphere_effect.a);
	flare_layer.a = smoothstep(1.0, 0.91, flare_d);

}
	// Core layer
	if (core_d <= 1.0) {
		core_layer = mix(final_color, base_color, base_color.a);
	    core_layer.a = smoothstep(1.0, 0.99, core_d);
	}

	// Combine layers
	final_color = mix(final_color, flare_layer , flare_layer.a);
	final_color = mix(final_color, core_layer, core_layer.a);

    // Cloud layer
    if (blob_d <= 1.0) {
		vec3 color_one = seventh_color.rgb;
		vec3 color_two = sixth_color.rgb;
        vec4 cloud_color = get_cloud_color(cloud_noise, cloud_detail, color_one, color_two);

        // Ensure areas outside clouds are fully transparent
        float cloud_opacity = smoothstep(cloud_noise, cloud_noise, -0.2);
        blob_layer = mix(final_color, cloud_color, cloud_noise * cloud_color.a);
        blob_layer.a = smoothstep(1.0, 0.9, blob_d);
    }

	final_color = mix(final_color, blob_layer, blob_layer.a);

if (flare_d <= 1.0) {
	//atmosphere_effect
    float atmosphere_factor = 1.0 - smoothstep(0.0, atmosphere_falloff, d);
    vec4 atmosphere_effect = atmospheric_color * atmosphere_factor * atmosphere_intensity;
	atmosphere_layer = mix(atmospheric_color, atmospheric_color, atmospheric_color * atmosphere_effect.a);
	atmosphere_layer.a = smoothstep(-1.0, 0.91, flare_d) * 0.369;
	atmosphere_layer2 = mix(final_color, atmosphere_layer, atmosphere_layer.a);
    atmosphere_layer2.a = smoothstep(1.0, 0.9, blob_d);

}

	final_color = mix(final_color, atmosphere_layer2, atmosphere_layer2.a);

}








 // them damn gas giants mary! the ones that were supposed to burn too!
if (planet_type > 5) {
    // Basic structure noise
    float base_noise = fnlGetNoise3D(new_type_circl,
                                     p.x * sphere_scale,
                                     p.y * sphere_scale * 0.5, // Slightly squeezed in y to create some banding
                                     p.z * sphere_scale);

    // Variation noise
    float variation_noise = fnlGetNoise3D(stripe_noise_state,
                                          p.x * stripe_scale  ,
                                          p.y * stripe_scale * 19.9 ,
                                          p.z * stripe_scale  + time * 0.1 ); // Add some movement

    // Combine noises
    float combined_noise = variation_noise;//base_noise * 0.8 + variation_noise * 0.2;

    // Use the existing color gradient system, but with colors suited for gas giants
    vec4 color_1 = get_first_planet_color(6);
    vec4 color_2 = get_second_planet_color(6);
    vec4 color_3 = get_third_planet_color(6);
    vec4 color_4 = get_fourth_planet_color(6);

    final_color = get_surface_color(combined_noise, color_1, color_2, color_3, color_4, color_4, color_3, color_2);

    // Add atmosphere effect
    float atmosphere_factor = 1.0 - smoothstep(0.0, atmosphere_falloff, d);
    vec4 atmosphere_effect = get_fifth_planet_color(6) * atmosphere_factor * atmosphere_intensity;
    //final_color = mix(final_color, atmosphere_effect, atmosphere_effect.a);
}




	vec2 uv1 = UV * 2.0 - 1.0;
    float d1 = length(uv1);
    vec3 p1 = vec3(uv1, sqrt(max(0.0, 1.0 - d1 * d1)));

    // Apply rotation
    p1 = position_matrix * p1;

    // Lighting calculation
    vec3 normal = normalize(cross(dFdx(p1), dFdy(p1)));
    vec3 light_dir = normalize(direction_matrix * vec3(0.0, 0.0, -1.0));

    // Ambient
    vec3 ambient = ambient_strength * light_color;

    // Diffuse
    float diff = smoothstep(1.0, 1.0, dot(normal, light_dir)); // float diff = smoothstep(-0.3, 0.7, dot(normal, light_dir));
	//float diff = smoothstep(-0.3, 0.7, dot(normal, light_dir));
    vec3 diffuse = diff * diffuse_strength * light_color;

    // Specular
    vec3 view_dir = normalize(-p1);
    vec3 reflect_dir = reflect(-light_dir, normal);
    float spec = pow(max(dot(view_dir, reflect_dir), 0.0), shininess);
    vec3 specular = specular_strength * spec * light_color;

    // Combine lighting with the final color
    vec3 lighting = ambient + diffuse + specular;
    final_color.rgb *= lighting;

	// Apply final mask
	float mask = smoothstep(1.0, 0.99, d);
	ALBEDO = final_color.rgb;
	ALPHA = final_color.a * mask;
}