shader_type spatial;
render_mode unshaded;

uniform float time : hint_range(0.0, 1.0);
uniform float temperature_star = 18000;

void fragment() {
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
    ALBEDO = finalColor.rgb;
}
