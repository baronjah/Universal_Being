// CelestialAsteroid.gdshader

shader_type spatial;
render_mode unshaded;

uniform float asteroid_seed : hint_range(1, 10000) = 1;
uniform vec4 color1 : source_color = vec4(1.0, 1.0, 1.0, 1.0);  // White
uniform vec4 color2 : source_color = vec4(0.0, 0.0, 0.0, 1.0);  // Void
uniform vec4 color3 : source_color = vec4(0.0, 0.0, 0.0, 0.0); // nothing
uniform float noise_scale = 88.8;

uniform float time;            // Added time variable
uniform mat3 rotation_matrix;  // our position
uniform mat3 rotation_matrix2; // our position reversed

// rotation position matrixes
uniform mat3 direction_matrix; // light point
uniform mat3 position_matrix;  // our position
uniform mat3 position_matrix2; // our position in reverse?
uniform vec3 planet_position;
uniform vec3 player_position;

// the rotations of despair
uniform mat3 new_final_matrix_up;
uniform mat3 new_final_matrix_down;
uniform mat3 new_final_matrix_left;
uniform mat3 new_final_matrix_right;

//star light and darkness stuff
uniform vec3 light_color = vec3(1.0, 1.0, 1.0); // Slightly yellow sunlight
uniform float ambient_strength = 0.005;
uniform float diffuse_strength = 0.9;
uniform float specular_strength = 1.0;
uniform float shininess = 4.0;

uniform int asteroid_type : hint_range(0 , 6) = 2; // 0 - earth like planet, 1 - Rocky Planet , 2 - Ice Planet, 3 - Fire Planet, 4 - Exo Planet, kinda like earth planets, but its purple and green, purple lands and green water, 5 - Gas Giants

// moon leftovers, we probably wont use them?
uniform float crater_size : hint_range(0.01, 0.5) = 0.3;
uniform float crater_depth : hint_range(0.0, 1.0) = 0.8;
uniform float crater_rim_width : hint_range(0.01, 0.5) = 0.1;
uniform float crater_edge_smoothness : hint_range(0.001, 0.1) = 0.04;
uniform int crater_count : hint_range(1, 50) = 20;
uniform float crater_rim_brightness : hint_range(0.0, 1.0) = 0.5;

uniform float asteroid_frequency;
uniform float amplitude;
uniform int octaves;
uniform float asteroid_lacunarity;
uniform float asteroid_gain;

#include "res://ShaderInc/FastNoiseLite.gdshaderinc"

float rand(vec3 co) {
    return fract(sin(dot(co, vec3(12.9898, 78.233, 45.5432))) * 43758.5453 + asteroid_seed);
}

// Generate 3D noise-based asteroid shape
float generate_asteroid(vec3 pos) {
    float noise_value = 0.0;
    vec3 p = pos * asteroid_frequency;
    float amplitude_total = 0.0;

    // Octave loop for noise generation
    for (int i = 0; i < octaves; i++) {
		//okay so here we cannot really do it this way? but we can generate that noise here also? we can do it here
		//or we can do it in fragment, because there isnt really something like FastNoiseLite_GetNoise?
		//i mean maybe there is but with different words? i know that we can use "fnlGetNoise3D" word
		//and we are already doing that in fragment :) so maybe either we generate that noise with fnl = fast noise lite
		//or what? we do that in fragment or we will need to add settings stuff here for noise, it is your choise
        //noise_value += FastNoiseLite_GetNoise(asteroid_seed, p) * amplitude;
        p *= asteroid_lacunarity;
        amplitude_total += amplitude;
        //amplitude *= asteroid_gain; // assignment to uniform? what does it mean? is something not right?
    }

    noise_value /= amplitude_total;

    // Easing function to control the shape
    float center_distance = length(pos);
    float eased_noise = smoothstep(0.0, 1.0, noise_value * center_distance);
    return eased_noise;
}



vec4 get_first_asteroid_color(int type_of_asteroid){
    vec4 first_asteroid_color;
    if (type_of_asteroid == 0) first_asteroid_color = vec4(0.0, 0.0, 0.5, 1.0); // Earth-like (water_deep_blue)
    else if (type_of_asteroid == 1) first_asteroid_color = vec4(0.5, 0.0, 0.0, 1.0); // Rocky Red (Dark Red)
    else if (type_of_asteroid == 2) first_asteroid_color = vec4(0.565, 0.561, 0.686, 1.0); // Ice (Deep Ice Blue)
    else if (type_of_asteroid == 3) first_asteroid_color = vec4(0.545, 0.0, 0.0, 1.0); // Fire (Deep Lava Red)
    else if (type_of_asteroid == 4) first_asteroid_color = vec4(0.08, 0.39, 0.26, 1.0); // Exo (Dark Green)
    else if (type_of_asteroid == 5) first_asteroid_color = vec4(0.2, 0.2, 0.2, 1.0); // Rocky Grey (Dark Gray)
	else if (type_of_asteroid == 6) first_asteroid_color = vec4(0.6, 0.3, 0.0, 1.0); // Gas Giant (Deep Orange)
    return first_asteroid_color;
}

vec4 get_second_asteroid_color(int type_of_asteroid){
    vec4 second_asteroid_color;
    if (type_of_asteroid == 0) second_asteroid_color = vec4(0.0, 0.5, 1.0, 1.0); // Earth-like (water_aqua_blue)
    else if (type_of_asteroid == 1) second_asteroid_color = vec4(1.0, 0.0, 0.0, 1.0); // Rocky Red (Red)
    else if (type_of_asteroid == 2) second_asteroid_color = vec4(0.878, 0.969, 1.0, 1.0); // Ice (Pale Blue)
    else if (type_of_asteroid == 3) second_asteroid_color = vec4(1.0, 0.27, 0.0, 1.0); // Fire (Lava Orange)
    else if (type_of_asteroid == 4) second_asteroid_color = vec4(0.47, 0.88, 0.64, 1.0); // Exo (Light Green)
    else if (type_of_asteroid == 5) second_asteroid_color = vec4(0.5, 0.5, 0.5, 1.0); // Rocky Grey (Gray)
	else if (type_of_asteroid == 6) second_asteroid_color = vec4(0.8, 0.6, 0.2, 1.0); // Gas Giant (Light Orange)
    return second_asteroid_color;
}

// Simple hash function for random number generation
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

// Random 1D function returning a float between 0 and 1
float random_1d(float x, float seed) {
    return hash(x + seed);
}

vec4 get_surface_color(float noise, vec4 color_1, vec4 color_2, float surface_d) {
	float easeInCirc = 1.0 - sqrt(1.0 - pow(surface_d, 2.0));
	float easin = surface_d * surface_d * surface_d * surface_d;
	float new_noise = noise - (surface_d * 0.3);
    float mix_factor = smoothstep(-1.0, 1.0, new_noise);
    return mix(color_1, color_2, mix_factor);
}

vec4 get_surface_color_2(float noise, float noise2, vec4 color_1, vec4 color_2, float surface_d) {
	float easeInCirc = 1.0 - sqrt(1.0 - pow(surface_d, 2.0));
	float easin = surface_d * surface_d * surface_d * surface_d;
	float new_noise = (((noise * 1.2) + (noise2 * 1.8)) * 0.8) - easeInCirc * 1.1;
    float mix_factor = smoothstep(-1.0, 1.0, new_noise);
    return mix(color_1, color_2, mix_factor);
}

void vertex() {
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
	// Create a 3D position from the 2D UV
	vec2 uv = UV * 2.0 - 1.0;
	float d = length(uv);

	// Adjust scales for each layer
	float surface_scale = 1.0; // Adjust this to change core size
	// Calculate separate distances for each layer
	float surface_d = d / surface_scale;
    vec3 p = vec3(uv, sqrt(max(0.0, 1.0 - d * d)));
	//the basises of despair shall prosper!
    vec3 p2 = vec3(uv, sqrt(max(0.0, 1.0 - d * d)));
	vec3 p3 = vec3(uv, sqrt(max(0.0, 1.0 - d * d)));
	vec3 p4 = vec3(uv, sqrt(max(0.0, 1.0 - d * d)));
	vec3 p5 = vec3(uv, sqrt(max(0.0, 1.0 - d * d)));
	//here we were using just a circle for generation of planets and moons and stars, but now the asteroid, can take any form and shape!
	//and so we need to invent new way, of making the "d" hmm, i think we shall make the noise with easing
	//by that i mean, the further ne noise is from center, the lower is value! and if noise is under certain value
	//we dont use it and we dont put it on canvas

	// Apply rotation
	p = rotation_matrix * p;
	// dawn forgot about right?
	p2 = new_final_matrix_right * p2;
	p3 = new_final_matrix_up * p3;
	p4 = new_final_matrix_down * p4;
	p5 = new_final_matrix_left * p5;

	// Setup FastNoiseLite for moon surface
	fnl_state asteroid_noise = fnlCreateState(int(asteroid_seed));
	asteroid_noise.noise_type = FNL_NOISE_OPENSIMPLEX2S;
	asteroid_noise.frequency = 0.015;
	asteroid_noise.fractal_type = FNL_NOISE_VALUE;
	asteroid_noise.lacunarity = 4.f;
	asteroid_noise.gain = .3f;
	asteroid_noise.octaves = 4;

	// Setup FastNoiseLite for moon surface
	fnl_state asteroid_noise_new_type = fnlCreateState(int(asteroid_seed));
	asteroid_noise_new_type.noise_type = FNL_NOISE_OPENSIMPLEX2S;
	asteroid_noise_new_type.frequency = 0.015;
	asteroid_noise_new_type.fractal_type = FNL_NOISE_CELLULAR;
	asteroid_noise_new_type.lacunarity = 4.f;
	asteroid_noise_new_type.gain = .3f;
	asteroid_noise_new_type.octaves = 4;


	float x = asteroid_seed / 2137.0;/// SCREEN_PIXEL_SIZE;
	float random_value = random_1d(x, asteroid_seed);
	vec4 final_color = vec4(0.0, 0.0, 0.0, 0.0);
	vec4 final_color2 = vec4(0.0, 0.0, 0.0, 0.0);
	vec4 final_color3 = vec4(0.0, 0.0, 0.0, 0.0);
	vec4 final_color4 = vec4(0.0, 0.0, 0.0, 0.0);
	vec4 final_color5 = vec4(0.0, 0.0, 0.0, 0.0);
	vec4 final_color6 = vec4(0.0, 0.0, 0.0, 0.0);

	//float new_scale = noise_scale * 0.369;
	//float position_x = new_scale * player_position.x;
	//float position_y = new_scale * player_position.y;
	//float position_z = new_scale * player_position.z;

	//float position_x_reversed = -position_x;
	//float position_y_reversed = -position_y;
	//float position_z_reversed = -position_z;
    // Generate noise for base star appearance
	//the first type of noise, from center, from where camera is looking
    float asteroid_surface = fnlGetNoise3D(asteroid_noise, p.x * noise_scale, p.y * noise_scale, p.z * noise_scale);
	//the second type of noise, from not so center, as we check some point in front or behind camera
	float asteroid_surface2 = fnlGetNoise3D(asteroid_noise, p.x * noise_scale, p.y * noise_scale, p.z * noise_scale);
	float asteroid_surface3 = fnlGetNoise3D(asteroid_noise_new_type, p.x * noise_scale, p.y * noise_scale, p.z * noise_scale);
	//the third type of noise, from center, and from behind? i like it raw :)
	//float asteroid_surface3 = fnlGetNoise3D(asteroid_noise, p3.x * noise_scale, p3.y * noise_scale, p3.z * noise_scale);
	//the fourth type of the noise! just like the second! we set our sight from different place than center! we go back, center, forth, from two places? from four? maybe just three?! who knows work already!
	//float asteroid_surface4 = fnlGetNoise3D(asteroid_noise, p4.x * noise_scale, p4.y * noise_scale, p4.z * noise_scale);
	//well i didnt like them so i changed them to that or whatever, we will see :(
	//float asteroid_surface5 = fnlGetNoise3D(asteroid_noise, p5.x * noise_scale, p5.y * noise_scale, p5.z * noise_scale);

	vec4 color_one = get_first_asteroid_color(asteroid_type);
	vec4 color_two = get_second_asteroid_color(asteroid_type);
	float clamped_value = clamp(random_value, 0.4, 1.0);
	vec3 new_color_ein = vec3(color_one.rgb * clamped_value);
	vec3 new_color_zwei = vec3(color_two.rgb * clamped_value);
	vec4 color_uno = vec4(new_color_ein, color_one.a);
	vec4 color_dos = vec4(new_color_zwei, color_two.a);

	//asteroid_surface - noise center, front
	vec4 base_color = get_surface_color(asteroid_surface, color_uno, color_dos, surface_d);
	//asteroid_surface2 - noise, center, back
	vec4 base_color2 = get_surface_color_2(asteroid_surface2, asteroid_surface3, color_uno, color_dos, surface_d);
	//asteroid_surface_a - noise not center, front
	vec4 base_color3 = get_surface_color(asteroid_surface3, color_uno, color_dos, surface_d);
	//asteroid_surface2_a - noise, not center, back
	//vec4 base_color4 = get_surface_color(asteroid_surface4, color_uno, color_dos, surface_d);
	//okay so we still are working on it global
	//vec4 base_color5 = get_surface_color(asteroid_surface5, color_uno, color_dos, surface_d);

	vec4 surface_layer = vec4(0.0);
	vec4 surface_layer2 = vec4(0.0);
	vec4 surface_layer3 = vec4(0.0);
	//vec4 surface_layer4 = vec4(0.0);
	//not even god knows for what we need these two, where are the blues clues!
	//vec4 surface_layer5 = vec4(0.0);
	//vec4 surface_layer6 = vec4(0.0);
	//maybe you shall be the preetiest?
	vec4 surface_asteroid = vec4(0.0);
	// Core layer
	float dunno;
	//so previously, if we were in the area of circle, we draw that celeastial bodies
	//now we will need to think of differernt stuff? like if some float value is over certain point
	//we will be drawing these asteroids
	if (surface_d <= 1.0) {
		float easeInCirc = 1.0 - sqrt(1.0 - pow(surface_d, 2.0));
		//float new_d = surface_d * surface_d * surface_d * surface_d;
		//float new_d2 = 1.0 - (1.0 - surface_d) * (1.0 - surface_d);
		// two layers, from centers, one in front of us, one from behind!
		//base_color - noise center, front
		surface_layer = mix(final_color, base_color - easeInCirc, 1.0);
		//base_color2 - noise, center, back
		surface_layer2 = mix(final_color2, base_color2 - easeInCirc, 1.0);
		// another two layers, but this time around! not from center, but slighty in directionf of camera :)
		//base_color3 - noise not center, front
		surface_layer3 = mix(final_color3, base_color3 - easeInCirc, 1.0);
		//base_color4 - noise, not center, back
		//surface_layer4 = mix(final_color4, base_color4 - easeInCirc, 1.0);
		//so maybe it is time to add a little bit of shade and make you a little bit different from your predescessor? but we wont be using your parameters for anything beside what we see bool
		//surface_layer5 = mix(final_color5, base_color5 - easeInCirc, 1.0);

		//for what we need ya huh not too shaded baby, just pure and raw pristine skin, with nothing gyara ugly would put on mrrr
		surface_asteroid = mix(final_color, base_color, 1.0);
		//the threshold of darkness, where we set the fine line of alternative universe, the mirror universe!
		float darkness_threshold = 0.0;
		//the mistakes of human kind, where they forgot, that three thingies, are just together from perspective of higher dimensional beings, as humans still dont understand that naming 9 the same things with different way, wont change, what they are lol
		// the darkest times first agenda, where we first were, we set out to create the first layer of flat three dimensions!
		float darkest_times1_1 = surface_layer.r;//base_color.r - (surface_d * 0.5);
		float darkest_times1_2 = surface_layer.g;//base_color.g - (surface_d * 0.5);
		float darkest_times1_3 = surface_layer.b;//base_color.b - (surface_d * 0.5);
		// so we continued, we went to mirror dimension! to create even further!
		float darkest_times2_1 = surface_layer2.r;
		float darkest_times2_2 = surface_layer2.g;
		float darkest_times2_3 = surface_layer2.b;
		//but we didnt stop there, we slighy altered these realities, and went on and on to create and change and shape even further until creater, the master, so me, seen what i wanted to see, them stupid rocks in space, on flat texture lol
		float darkest_times3_1 = surface_layer3.r;
		float darkest_times3_2 = surface_layer3.g;
		float darkest_times3_3 = surface_layer3.b;
		// and so we went even further! we went backward, then we mirrored the image, like an cursed broken mirror, we seen the spacetime in past, future, from the present in any direction, from present to past, from present to future, to shape and mold it, until we like it
		//float darkest_times4_1 = surface_layer4.r;
		//float darkest_times4_2 = surface_layer4.g;
		//float darkest_times4_3 = surface_layer4.b;
		//and what we do here? just as we set out on another adventure to create, then we splitted what we seen, took the parts which we wanted, and modled it into one! just one floating variable, what once were colors, now is just a single floating point which shall me looked like a grayscale? maybe
		//float darkest_times5_1 = surface_layer5.r;
		//float darkest_times5_2 = surface_layer5.g;
		//float darkest_times5_3 = surface_layer5.b;
		//who knows maybe this is how we can create better version of that whole thingy? the new gray scale? or maybe better grey scale? like that bitch, as better is e, than a, as a is kinda gay! and we like them asses and pussies lol! and boobies too!
		float new_age = (darkest_times1_1 + darkest_times1_2 + darkest_times1_3);
		float new_age2 = (darkest_times2_1 + darkest_times2_2 + darkest_times2_3);
		float new_age3 = (darkest_times3_1 + darkest_times3_2 + darkest_times3_3);
		//float new_age4 = (darkest_times4_1 + darkest_times4_2 + darkest_times4_3);
		//float new_age5 = (darkest_times5_1 + darkest_times5_2 + darkest_times5_3);
		//here we also can connect them all into one, didnt kinda work, which is grave mistake on part of humankind, because it should have been working, as i seen it, hmm, maybe thats why humans die?
		float newest_age = (new_age + new_age2);
		newest_age = clamp(newest_age, 0.0, 1.0);
		surface_layer.a = 0.0;
		surface_layer2.a = 0.0;
		//surface_layer3.a = 0.0;
		//surface_layer4.a = 0.0;
		//surface_layer5.a = 0.0;
		dunno = 0.0;

		if (new_age > darkness_threshold) {
			surface_layer.a = 1.0;
    }
		if (new_age > darkness_threshold) {
			surface_layer2.a = 1.0;
    }
		if (new_age3 > darkness_threshold) {
			surface_layer3.a = 1.0;
	}
	//	if (new_age4 > darkness_threshold){
	//		surface_layer4.a = 1.0;
	//	}
	//	if (new_age5 > darkness_threshold){
	//		surface_layer5.a = 1.0;
	//}
		if (newest_age > darkness_threshold){
			dunno = 1.0;
		}

	}

	//surface_layer - front
	//surface_layer2 - back
	//surface_layer3 - front slighty off
	//surface_layer4 - back slighty off
	//surface_layer5 - front slighty off darker
	//surface_layer6 - back slighty off darker
	//
	//so now we shall combine it all! we got them four Alphas! their transparency shall form the mold for whatever we will cook with four textures!
	//so we shall start what is first layer as texture, the first one, is the darkest back? then darkest front? then on top just front? so three textures?
	//and how about alphas? do we just add 4 .a together, clamp them and call it a day? maybe that stupid dunno, can be clamped and we have the same? i hope lol

	// the Combined ALpha! the one made from our whole adventure! or maybe many adventures? kinda all are the same, i just conquer the world at the end and have fun until im bored lol
	float new_alpha = surface_layer.a + surface_layer2.a;
	new_alpha = clamp(new_alpha, 0.0, 1.0);

	vec4 new_color = vec4(0.0);
	// surface_layer6, then surface_later5 and then surface_layeer1
	vec4 new_surface = mix(new_color, surface_layer, surface_layer.a);
	//new_surface = mix(new_surface, surface_layer5, surface_layer5.a);
	//new_surface = mix(new_surface, surface_layer4, new_alpha);
	//new_surface = mix(new_surface, surface_layer3, new_alpha);
	final_color = mix(new_surface, surface_layer2, surface_layer.a);



	//lightning and darkness
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
    //final_color.rgb *= lighting;

	// Apply final mask
	float mask = smoothstep(1.0, 0.99, d);
	ALBEDO = final_color.rgb;
	ALPHA = final_color.a;
}