shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

// Word influence parameters
uniform vec4 word_color : source_color = vec4(0.5, 0.8, 1.0, 0.8);
uniform float word_influence : hint_range(0.0, 1.0) = 0.5;
uniform sampler2D word_texture : filter_linear_mipmap;
uniform float evolution_phase : hint_range(0.0, 6.28) = 0.0;
uniform float time_scale : hint_range(0.1, 5.0) = 1.0;

// Shape parameters
uniform float shape_morph_factor : hint_range(0.0, 1.0) = 0.0;
uniform vec3 shape_target_pos = vec3(0.0, 0.0, 0.0);
uniform int connection_count : hint_range(0, 64) = 0;
uniform vec3 connection_points[64];
uniform float connection_strengths[64];

// Evolution parameters
uniform float evolution_stage : hint_range(0.0, 1.0) = 0.0;
uniform float growth_rate : hint_range(0.0, 5.0) = 1.0;

// Global time value from Godot
varying vec3 vertex_pos;
varying vec3 normal_interp;
varying vec2 uv_interp;

void vertex() {
    // Store original vertex information
    vertex_pos = VERTEX;
    normal_interp = NORMAL;
    uv_interp = UV;

    // Basic vertex animation based on time and evolution
    float time = TIME * time_scale;

    // Calculate influence from word parameters
    float word_time_factor = sin(time * 0.5 + evolution_phase) * 0.5 + 0.5;
    float word_factor = word_influence * word_time_factor * evolution_stage;

    // Apply evolution stage transformations
    if (evolution_stage > 0.0) {
        // Morph shape according to evolution stage
        float morph = shape_morph_factor * evolution_stage;

        // Calculate connection influence
        vec3 connection_influence = vec3(0.0);
        for (int i = 0; i < connection_count && i < 64; i++) {
            float dist = distance(VERTEX, connection_points[i]);
            float influence = connection_strengths[i] / (1.0 + dist * dist);

            // Direction vector towards connection point
            vec3 dir = normalize(connection_points[i] - VERTEX);
            connection_influence += dir * influence * evolution_stage;
        }

        // Apply various influences to vertex
        VERTEX += NORMAL * sin(time * 2.0 + VERTEX.y * 4.0) * 0.02 * word_factor;
        VERTEX += connection_influence * 0.05;

        // Move vertex toward target shape
        vec3 target_dir = normalize(shape_target_pos - VERTEX);
        VERTEX = mix(VERTEX, VERTEX + target_dir * 0.1, morph * sin(time + VERTEX.x + VERTEX.z));
    }
}

void fragment() {
    // Calculate pulsing effect
    float time = TIME * time_scale;
    float pulse = sin(time * 2.0 + evolution_phase) * 0.5 + 0.5;

    // Word texture influence
    vec4 word_tex = texture(word_texture, uv_interp);
    float word_mask = word_tex.r * word_influence;

    // Evolution effect on color
    float evolution_effect = evolution_stage * (sin(time + uv_interp.x * 10.0) * 0.5 + 0.5);

    // Combine colors based on evolution stage
    vec3 early_color = mix(word_color.rgb, vec3(1.0, 1.0, 1.0), pulse * 0.3);
    vec3 evolved_color = mix(word_color.rgb, vec3(0.2, 0.8, 1.0), evolution_effect);

    vec3 final_color = mix(early_color, evolved_color, evolution_stage);

    // Create light patterns on surface
    float pattern = sin(uv_interp.x * 20.0 + time) * sin(uv_interp.y * 20.0 + time) * 0.5 + 0.5;

    // Apply word texture influence
    final_color = mix(final_color, word_tex.rgb * final_color * 1.5, word_mask * evolution_stage);

    // Add glow at higher evolution stages
    float glow = evolution_stage * evolution_stage * pulse;

    // Final color with pattern and evolution effects
    ALBEDO = final_color;
    METALLIC = mix(0.1, 0.8, evolution_stage);
    ROUGHNESS = mix(0.9, 0.1, evolution_stage);
    SPECULAR = mix(0.1, 0.8, evolution_stage * pattern);
    EMISSION = final_color * glow * 2.0;
    ALPHA = word_color.a * max(evolution_stage, 0.5);
}