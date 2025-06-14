shader_type sky;

uniform sampler2D panorama_texture;
uniform float depth_factor : hint_range(0.9, 1.1) = 1.0;
uniform float brightness : hint_range(0.0, 1.0) = 0.3;

void sky() {
    vec3 dir = normalize(EYEDIR);

    // Calculate the angle from the vertical axis
    float theta = acos(dir.y);

    // Calculate the angle around the vertical axis
    float phi = atan(dir.x, dir.z);

    // Modify theta based on the depth factor
    // This will affect the vertical stretch, more pronounced near the equator
    theta = mix(theta, PI * 0.5, (depth_factor - 1.0) * sin(theta));

    // Convert back to Cartesian coordinates
    vec3 modified_dir = vec3(
        sin(theta) * sin(phi),
        cos(theta),
        sin(theta) * cos(phi)
    );

    // Convert direction to panorama UV coordinates
    vec2 sky_uv = vec2(phi / (2.0 * PI) + 0.5, theta / PI);

    // Sample the panorama texture
    vec3 color = texture(panorama_texture, sky_uv).rgb;
    color *= brightness;
    COLOR = color;
}