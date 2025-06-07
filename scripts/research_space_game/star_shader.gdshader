// star_shader.gdshader - Realistic star surface with turbulence and corona
shader_type spatial;
render_mode unshaded, cull_disabled;

// Star parameters
uniform float temperature : hint_range(2000.0, 20000.0) = 5778.0; // Kelvin
uniform float luminosity : hint_range(0.1, 10.0) = 1.0;
uniform float turbulence_scale : hint_range(1.0, 50.0) = 10.0;
uniform float time_scale : hint_range(0.1, 5.0) = 1.0;
uniform float corona_size : hint_range(1.0, 3.0) = 1.5;
uniform float flare_intensity : hint_range(0.0, 2.0) = 0.5;

// Noise texture for surface detail
uniform sampler2D noise_texture : repeat_enable;

varying vec3 world_position;
varying vec3 view_direction;
varying vec3 world_normal;

// Temperature to RGB conversion (blackbody radiation approximation)
vec3 temperature_to_color(float temp) {
    vec3 color;

    // CIE 1964 10 degree CMFs (simplified)
    if (temp < 1000.0) {
        color = vec3(1.0, 0.0, 0.0);
    } else if (temp < 3500.0) {
        float t = (temp - 1000.0) / 2500.0;
        color = mix(vec3(1.0, 0.0, 0.0), vec3(1.0, 0.6, 0.3), t);
    } else if (temp < 5000.0) {
        float t = (temp - 3500.0) / 1500.0;
        color = mix(vec3(1.0, 0.6, 0.3), vec3(1.0, 0.8, 0.6), t);
    } else if (temp < 6500.0) {
        float t = (temp - 5000.0) / 1500.0;
        color = mix(vec3(1.0, 0.8, 0.6), vec3(1.0, 0.95, 0.85), t);
    } else if (temp < 10000.0) {
        float t = (temp - 6500.0) / 3500.0;
        color = mix(vec3(1.0, 0.95, 0.85), vec3(0.85, 0.9, 1.0), t);
    } else {
        float t = min((temp - 10000.0) / 10000.0, 1.0);
        color = mix(vec3(0.85, 0.9, 1.0), vec3(0.7, 0.8, 1.0), t);
    }

    return color;
}

// 3D noise function for turbulence
float noise3D(vec3 p) {
    return texture(noise_texture, p.xy * 0.1).r *
           texture(noise_texture, p.yz * 0.1).r *
           texture(noise_texture, p.xz * 0.1).r;
}

// Fractal noise for detailed turbulence
float fractal_noise(vec3 p, float scale) {
    float value = 0.0;
    float amplitude = 1.0;
    float frequency = scale;

    for (int i = 0; i < 4; i++) {
        value += noise3D(p * frequency) * amplitude;
        frequency *= 2.0;
        amplitude *= 0.5;
    }

    return value;
}

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    view_direction = normalize(CAMERA_POSITION_WORLD - world_position);
}

void fragment() {
    float time = TIME * time_scale;

    // Base color from temperature
    vec3 star_color = temperature_to_color(temperature);

    // Surface turbulence (convection cells)
    vec3 turb_pos = world_position * turbulence_scale + vec3(time * 0.1);
    float turbulence = fractal_noise(turb_pos, 0.1);
    turbulence = turbulence * 0.3 + 0.7; // Range: 0.7 to 1.0

    // Granulation pattern (smaller convection cells)
    vec3 gran_pos = world_position * turbulence_scale * 5.0 + vec3(time * 0.5);
    float granulation = noise3D(gran_pos);
    granulation = pow(granulation, 2.0) * 0.2 + 0.8;

    // Solar flares (bright spots)
    float flare = sin(world_position.x * 50.0 + time * 5.0) *
                  sin(world_position.y * 50.0 - time * 3.0) *
                  sin(world_position.z * 50.0 + time * 4.0);
    flare = smoothstep(0.7, 0.9, flare) * flare_intensity;

    // Limb darkening (edges appear darker)
    float ndotv = dot(world_normal, view_direction);
    float limb_darkening = pow(max(ndotv, 0.0), 0.5);
    limb_darkening = limb_darkening * 0.5 + 0.5;

    // Corona effect (atmospheric glow)
    float rim = 1.0 - ndotv;
    rim = pow(rim, 2.0);
    vec3 corona = star_color * rim * corona_size;

    // Combine all effects
    vec3 surface_color = star_color * turbulence * granulation * limb_darkening;
    surface_color += star_color * flare * 2.0; // Bright flares

    // Final color with corona
    vec3 final_color = surface_color * luminosity + corona;

    // Add slight color variation based on position
    vec3 color_variation = vec3(
        noise3D(world_position * 2.0),
        noise3D(world_position * 2.0 + vec3(100.0)),
        noise3D(world_position * 2.0 + vec3(200.0))
    );
    final_color *= (color_variation * 0.1 + 0.9);

    ALBEDO = final_color;
    EMISSION = final_color * 2.0;

    // Add subtle alpha fade at edges for corona
    ALPHA = 1.0;
    if (rim > 0.8) {
        ALPHA = 1.0 - smoothstep(0.8, 1.0, rim);
    }
}