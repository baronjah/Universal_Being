shader_type spatial;
render_mode unshaded, cull_back, depth_prepass;

// Anime-style parameters
uniform float outline_width : hint_range(0.0, 10.0) = 2.0;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform int cel_shading_levels : hint_range(1, 10) = 3;
uniform sampler2D main_texture : hint_default_white;
uniform vec4 base_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform bool use_billboard = true;
uniform bool use_soft_shadows = true;
uniform bool use_hatching = false;
uniform sampler2D hatching_texture : hint_default_white;

// Visual effects
uniform float pulse_amount : hint_range(0.0, 1.0) = 0.0;
uniform float pulse_speed : hint_range(0.0, 10.0) = 3.0;
uniform bool use_rim_light = true;
uniform float rim_power : hint_range(0.0, 10.0) = 3.0;
uniform vec4 rim_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Animation parameters
uniform float animation_time_offset = 0.0;
uniform bool use_wave_effect = false;
uniform float wave_amplitude : hint_range(0.0, 1.0) = 0.1;
uniform float wave_frequency : hint_range(0.0, 10.0) = 3.0;
uniform float wave_speed : hint_range(0.0, 10.0) = 2.0;

varying vec3 vertex_normal;
varying vec3 vertex_position;

void vertex() {
    // Store values for fragment shader
    vertex_normal = NORMAL;
    vertex_position = VERTEX;
    
    // Apply wave animation if enabled
    if (use_wave_effect) {
        float wave = sin((VERTEX.y * wave_frequency + TIME * wave_speed + animation_time_offset)) * wave_amplitude;
        VERTEX.x += wave * VERTEX.y * 0.2;
        VERTEX.z += cos(VERTEX.y * wave_frequency * 0.5 + TIME * wave_speed * 0.7 + animation_time_offset) * wave_amplitude * 0.3;
    }
    
    // Apply pulse animation
    if (pulse_amount > 0.0) {
        float pulse = sin(TIME * pulse_speed + animation_time_offset) * 0.5 + 0.5;
        VERTEX *= 1.0 + (pulse * pulse_amount * 0.1);
    }
    
    // Ensure normals are correctly transformed
    NORMAL = normalize(NORMAL);
}

void fragment() {
    // Calculate diffuse lighting with cel shading
    float NdotL = dot(normalize(vertex_normal), normalize(vec3(1.0, 3.0, -2.0)));
    NdotL = NdotL * 0.5 + 0.5; // Remap to [0,1]
    
    // Apply cel-shading
    float cel_shading = floor(NdotL * float(cel_shading_levels)) / float(cel_shading_levels);
    
    // Calculate if this is an outline
    float is_outline = 0.0;
    if (outline_width > 0.0) {
        // Simple edge detection
        vec3 normal = normalize(vertex_normal);
        float NdotV = abs(dot(normal, normalize(VIEW)));
        is_outline = (1.0 - smoothstep(0.0, outline_width * 0.05, NdotV)) * outline_color.a;
    }
    
    // Get base color from texture or uniform
    vec4 color = texture(main_texture, UV) * base_color;
    
    // Add rim lighting effect
    if (use_rim_light) {
        float rim = 1.0 - dot(normalize(vertex_normal), normalize(-VIEW));
        rim = smoothstep(0.0, 1.0, rim);
        rim = pow(rim, rim_power);
        color.rgb = mix(color.rgb, rim_color.rgb, rim * rim_color.a);
    }
    
    // Apply hatching for shadow areas if enabled
    if (use_hatching) {
        // Use a hatching texture in shadow areas
        float hatch_blend = 1.0 - cel_shading;
        vec3 hatch_color = texture(hatching_texture, UV * 5.0).rgb;
        color.rgb = mix(color.rgb, hatch_color, hatch_blend * 0.5);
    }
    
    // Mix between outline and cel-shaded color
    ALBEDO = mix(color.rgb * cel_shading, outline_color.rgb, is_outline);
    ALPHA = mix(color.a, outline_color.a, is_outline);
    
    // Add a soft shadow if enabled
    if (use_soft_shadows) {
        float shadow = smoothstep(0.4, 0.5, cel_shading);
        ALBEDO *= mix(0.7, 1.0, shadow);
    }
    
    // Add emission for the rim light
    if (use_rim_light) {
        float rim = 1.0 - dot(normalize(vertex_normal), normalize(-VIEW));
        rim = smoothstep(0.5, 1.0, rim);
        rim = pow(rim, rim_power);
        EMISSION = rim_color.rgb * rim * rim_color.a;
    }
}