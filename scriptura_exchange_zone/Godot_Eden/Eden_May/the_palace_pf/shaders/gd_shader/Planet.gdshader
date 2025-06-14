//Planet.gdshader , "res://Shaders/Planet.gdshader"
shader_type spatial;
render_mode unshaded;

uniform vec4 color : source_color;
uniform float radius : hint_range(0.5, 20);
uniform float type : hint_range(0, 3);

void fragment() {
    vec2 centered_uv = (UV - 0.5) * 2.0;
    float dist = length(centered_uv);

    // Basic circle shape
    float circle = 1.0 - step(1.0, dist);

    // Add some variation based on planet type
    float variation = sin(centered_uv.x * 10.0) * sin(centered_uv.y * 10.0) * 0.5 + 0.5;
    variation = mix(1.0, variation, type / 3.0);  // More variation for higher type values

    vec3 final_color = color.rgb * variation;

    ALBEDO = final_color;
    ALPHA = circle;
}

void vertex() {
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}