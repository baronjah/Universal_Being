// Star.gdshader
shader_type spatial;
render_mode unshaded, blend_add;

uniform vec4 color : source_color = vec4(1.0);
uniform float brightness : hint_range(0, 2) = 2.0;

void fragment() {
    vec2 centered_uv = (UV - 0.5) * 2.0;
    float dist = length(centered_uv);
    float alpha = smoothstep(1.0, 0.0, dist);
    ALBEDO = color.rgb * brightness;
    ALPHA = alpha * color.a;
}

void vertex() {
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}