#[compute]
#version 450
layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

// Input uniforms
layout(set = 0, binding = 0) uniform Params {
    float u_seed;
    float u_arm_count;
    float u_arm_width;
    float u_star_density;
    float u_star_size;  // Resolution
    float u_star_circle_radius;
    float u_swirl_amount;
};

// Output buffer
layout(set = 0, binding = 1, std430) buffer StarBuffer {
    vec4 star_data[];
};

// Hash function
float hash(vec2 p, float seed) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(5.3983, 5.4427, 6.9371) + seed);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

void main() {
    uvec2 id = gl_GlobalInvocationID.xy;
    vec2 uv = vec2(id) / u_star_size;
    
    // Calculate distance and angle from center
    vec2 centered_uv = uv - 0.5;
    float dist = length(centered_uv);
    float angle = atan(centered_uv.y, centered_uv.x);

    // Apply swirl effect
    float swirl = u_swirl_amount * (1.0 - dist);
    angle += swirl;

    // Calculate arm angle
    float arm_angle = fract((angle / (2.0 * 3.14159265359)) * u_arm_count);
    
    // Create arm mask
    float arm_mask = step(0.5 - u_arm_width / 2.0, arm_angle) - step(0.5 + u_arm_width / 2.0, arm_angle);

    float star_hash = hash(uv, u_seed);
    float star_mask = step(1.0 - u_star_density, star_hash);

    // Apply circular mask
    float circle_mask = step(dist, u_star_circle_radius);

    // Final mask combines arm, star, and circle masks
    float final_mask = arm_mask * star_mask * circle_mask;

    if (final_mask > 0.5) {
        // This is a star within the circle and on an arm
        uint index = gl_GlobalInvocationID.y * gl_NumWorkGroups.x * gl_WorkGroupSize.x + gl_GlobalInvocationID.x;
        // Invert the y-coordinate here before sending
        star_data[index] = vec4(uv.x, 1.0 - uv.y, star_hash, 1.0);
    }
}