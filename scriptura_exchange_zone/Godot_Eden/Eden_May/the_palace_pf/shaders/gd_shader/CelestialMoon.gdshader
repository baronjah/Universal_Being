// CelestialMoon.gdshader

shader_type spatial;
render_mode unshaded;

uniform float moon_seed : hint_range(1, 10000) = 322222221;
uniform vec4 color1 : source_color = vec4(1.0, 1.0, 1.0, 1.0);  // White
uniform vec4 color2 : source_color = vec4(0.0, 0.0, 0.0, 1.0);  // Void
uniform vec4 color3 : source_color = vec4(0.0, 0.0, 0.0, 0.0); // nothing
uniform float noise_scale = 88.8;

uniform float time; // Added time variable
uniform mat3 rotation_matrix; // our position

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

uniform int moon_type : hint_range(0 , 6) = 2; // 0 - earth like planet, 1 - Rocky Planet , 2 - Ice Planet, 3 - Fire Planet, 4 - Exo Planet, kinda like earth planets, but its purple and green, purple lands and green water, 5 - Gas Giants

uniform float crater_size : hint_range(0.01, 0.5) = 0.3;
uniform float crater_depth : hint_range(0.0, 1.0) = 0.8;
uniform float crater_rim_width : hint_range(0.01, 0.5) = 0.1;
uniform float crater_edge_smoothness : hint_range(0.001, 0.1) = 0.04;
uniform int crater_count : hint_range(1, 50) = 20;
uniform float crater_rim_brightness : hint_range(0.0, 1.0) = 0.5;

float rand(vec3 co) {
	float smaller_seed = moon_seed / 2137.0;
	//smaller_seed = clamp(smaller_seed, 0.0, 111.9);
    return fract(sin(dot(co, vec3(12.9898, 78.233, 45.5432))) * (43758.5453 + smaller_seed));
}

vec4 crater(vec3 p, vec3 center, float radius) {
    float d = distance(p, center);
    // Black inner crater
    float inner_crater = smoothstep(radius, 0.0, d);
    // White outer rim
    float outer_rim = smoothstep(radius, radius * 0.8, d);
	float whole_zone = smoothstep(radius, 0.0, d);
    // Transparency for the impact area (black part)
    float impact_transparency = smoothstep(radius * 0.1, radius, d * 0.55);
    float rim_transparency2 = smoothstep(radius * 0.7, radius * 0.8, d);
    // Transparency for the outer rim (white part)
    float rim_transparency = smoothstep(radius * 0.8, radius, d);

    // Combine colors
    vec3 crater_impact_color = vec3(0.0);
	float alpha_impact = (1.0 - impact_transparency);

	vec3 crater_rim_color = vec3(1.0);
	float alpha_rim = (0.0 - (rim_transparency - rim_transparency2));
    // Combine this shit
	vec4 new_impact = vec4(crater_impact_color, (alpha_impact * 1.06)) ;
	vec4 new_rim = vec4(crater_rim_color, (alpha_rim * 0.7));
	//and the final warrior has spoken
	vec4 final_crater = vec4(0.0, 0.0, 0.0, 0.0);
	vec4 first_impact = mix(final_crater, new_impact, new_impact.a);
	vec4 whole_creation = mix(first_impact, new_rim, new_rim.a);

	whole_creation *= crater_depth;
    return whole_creation;//vec4(crater_color, alpha);
}

vec4 generate_craters(vec3 p) {
    vec4 result = vec4(0.0);
    for (int i = 0; i < crater_count; i++) {
        vec3 crater_center = normalize(vec3(
            rand(vec3(float(i), 0.0, 1.0)) * 2.0 - 1.0,
            rand(vec3(float(i), 1.0, 2.0)) * 2.0 - 1.0,
            rand(vec3(float(i), 2.0, 3.0)) * 2.0 - 1.0
        ));
        float crater_radius = (rand(vec3(float(i), 3.0, 4.0)) * 0.5 + 0.5) * crater_size;
        vec4 crater_effect = crater(p, crater_center, crater_radius);

        // Blend craters
        result = mix(result, crater_effect, crater_effect.a * (1.0 - result.a));
    }
    return result;
}

#include "res://ShaderInc/FastNoiseLite.gdshaderinc"

vec4 get_first_moon_color(int type_of_moon){
    vec4 first_moon_color;
    if (type_of_moon == 0) first_moon_color = vec4(0.0, 0.0, 0.5, 1.0); // Earth-like (water_deep_blue)
    else if (type_of_moon == 1) first_moon_color = vec4(0.5, 0.0, 0.0, 1.0); // Rocky Red (Dark Red)
    else if (type_of_moon == 2) first_moon_color = vec4(0.565, 0.561, 0.686, 1.0); // Ice (Deep Ice Blue)
    else if (type_of_moon == 3) first_moon_color = vec4(0.545, 0.0, 0.0, 1.0); // Fire (Deep Lava Red)
    else if (type_of_moon == 4) first_moon_color = vec4(0.08, 0.39, 0.26, 1.0); // Exo (Dark Green)
    else if (type_of_moon == 5) first_moon_color = vec4(0.2, 0.2, 0.2, 1.0); // Rocky Grey (Dark Gray)
	else if (type_of_moon == 6) first_moon_color = vec4(0.6, 0.3, 0.0, 1.0); // Gas Giant (Deep Orange)
    return first_moon_color;
}

vec4 get_second_moon_color(int type_of_moon){
    vec4 second_moon_color;
    if (type_of_moon == 0) second_moon_color = vec4(0.0, 0.5, 1.0, 1.0); // Earth-like (water_aqua_blue)
    else if (type_of_moon == 1) second_moon_color = vec4(1.0, 0.0, 0.0, 1.0); // Rocky Red (Red)
    else if (type_of_moon == 2) second_moon_color = vec4(0.878, 0.969, 1.0, 1.0); // Ice (Pale Blue)
    else if (type_of_moon == 3) second_moon_color = vec4(1.0, 0.27, 0.0, 1.0); // Fire (Lava Orange)
    else if (type_of_moon == 4) second_moon_color = vec4(0.47, 0.88, 0.64, 1.0); // Exo (Light Green)
    else if (type_of_moon == 5) second_moon_color = vec4(0.5, 0.5, 0.5, 1.0); // Rocky Grey (Gray)
	else if (type_of_moon == 6) second_moon_color = vec4(0.8, 0.6, 0.2, 1.0); // Gas Giant (Light Orange)
    return second_moon_color;
}

// Simple hash function for random number generation
float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

// Random 1D function returning a float between 0 and 1
float random_1d(float x, float seed) {
    return hash(x + seed);
}

vec4 get_surface_color(float noise, vec4 color_1, vec4 color_2) {
    float mix_factor = smoothstep(-1.0, 1.0, noise);
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

	// Apply rotation
	p = rotation_matrix * p;

	// Setup FastNoiseLite for moon surface
	fnl_state moon_noise = fnlCreateState(int(moon_seed));
	moon_noise.noise_type = FNL_NOISE_OPENSIMPLEX2;
	moon_noise.frequency = 0.01;
	moon_noise.fractal_type = FNL_FRACTAL_FBM;
	moon_noise.lacunarity = 4.f;
	moon_noise.gain = .3f;
	moon_noise.octaves = 4;
	float x = moon_seed / 2137.0;/// SCREEN_PIXEL_SIZE;
	float random_value = random_1d(x, moon_seed);
	vec4 final_color = vec4(0.0, 0.0, 0.0, 0.0);
    // Generate noise for base star appearance
    float moon_surface = fnlGetNoise3D(moon_noise, p.x * noise_scale, p.y * noise_scale, p.z * noise_scale);
	vec4 color_one = get_first_moon_color(moon_type);
	vec4 color_two = get_second_moon_color(moon_type);

	float clamped_value = clamp(random_value, 0.4, 1.0);

	vec3 new_color_ein = vec3(color_one.rgb * clamped_value);
	vec3 new_color_zwei = vec3(color_two.rgb * clamped_value);

	vec4 color_uno = vec4(new_color_ein, color_one.a);
	vec4 color_dos = vec4(new_color_zwei, color_two.a);

	vec4 base_color = get_surface_color(moon_surface, color_uno, color_dos);
	vec4 surface_layer = vec4(0.0);
	// Core layer
	if (surface_d <= 1.0) {
		surface_layer = mix(final_color, base_color, base_color.a);
	    surface_layer.a = smoothstep(1.0, 0.99, surface_d);
	}

	// Combine layers
	final_color = mix(final_color, surface_layer, surface_layer.a);

    vec4 crater_effect = generate_craters(p);

	// Overlay the craters on top of the final color
	final_color.rgb = mix(final_color.rgb, crater_effect.rgb, crater_effect.a);
	final_color.a = max(final_color.a, crater_effect.a);

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
    final_color.rgb *= lighting;

	// Apply final mask
	float mask = smoothstep(1.0, 0.99, d);
	ALBEDO = final_color.rgb;
	ALPHA = final_color.a * mask;
}