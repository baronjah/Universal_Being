//AsteroidsPositions.glsl
#[compute]
#version 450
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

// Input uniforms
layout(set = 0, binding = 0) uniform Params {
    float u_seed;
    float u_asteroids_density;
    float u_asteroids_size;  // Resolution
    float u_asteroids_circle_radius;
};

// Output buffer
layout(set = 0, binding = 1, std430) buffer AsteroidsBuffer {
    vec4 asteroid_data[];
};

// Hash function
float hash(vec2 p, float seed) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(5.3983, 5.4427, 6.9371) + seed);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

void main() {
    uvec2 id = gl_GlobalInvocationID.xy;
    vec2 uv = vec2(id) / u_asteroids_size;
    
    // Calculate distance and angle from center
    vec2 centered_uv = uv - 0.5;
    float dist = length(centered_uv);

    float asteroids_hash = hash(uv, u_seed);
    float asteroids_mask = step(1.0 - u_asteroids_density, asteroids_hash);

    // Apply circular mask
    float circle_mask = step(dist, 0.5);
    float circle_mask2 = step(dist, 0.4);

    // Final mask combines arm, star, and circle masks
    float final_mask = asteroids_mask * (circle_mask - circle_mask2);

    if (final_mask > 0.5) {
        // Them Asteroids damn
        uint index = gl_GlobalInvocationID.y * gl_NumWorkGroups.x * gl_WorkGroupSize.x + gl_GlobalInvocationID.x;
        // Invert the y-coordinate here before sending
        asteroid_data[index] = vec4(uv.x, 1.0 - uv.y, asteroids_hash, 1.0);
    }
}