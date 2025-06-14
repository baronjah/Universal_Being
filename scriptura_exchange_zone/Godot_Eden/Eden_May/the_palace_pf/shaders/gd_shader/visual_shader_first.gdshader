shader_type spatial;
render_mode unshaded, cull_disabled;

// Visualization parameters
uniform vec4 surface_color : source_color = vec4(0.3, 0.7, 1.0, 1.0);
uniform vec4 interior_color : source_color = vec4(0.1, 0.4, 0.8, 1.0);
uniform vec4 exterior_color : source_color = vec4(0.8, 0.1, 0.3, 1.0);
uniform float surface_thickness = 0.05;
uniform float time_scale = 1.0;
uniform float iso_level = 0.0;
uniform float max_steps = 100.0;
uniform float max_distance = 100.0;
uniform float epsilon = 0.001;
uniform int shape_type = 0; // 0: Sphere, 1: Torus, 2: Box, 3: Blend, 4: Morph

// Hash function for noise generation
float hash(float n) {
    return fract(sin(n) * 43758.5453);
}

// 3D noise function
float noise_3d(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);

    float n = p.x + p.y * 57.0 + p.z * 113.0;
    return mix(
        mix(
            mix(hash(n), hash(n + 1.0), f.x),
            mix(hash(n + 57.0), hash(n + 58.0), f.x),
            f.y),
        mix(
            mix(hash(n + 113.0), hash(n + 114.0), f.x),
            mix(hash(n + 170.0), hash(n + 171.0), f.x),
            f.y),
        f.z);
}

// Sphere SDF
float sdf_sphere(vec3 p, float radius) {
    return length(p) - radius;
}

// Box SDF
float sdf_box(vec3 p, vec3 b) {
    vec3 d = abs(p) - b;
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

// Torus SDF
float sdf_torus(vec3 p, float radius_major, float radius_minor) {
    vec2 q = vec2(length(p.xz) - radius_major, p.y);
    return length(q) - radius_minor;
}

// Smooth min for blending
float smooth_min(float a, float b, float k) {
    float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
    return mix(b, a, h) - k * h * (1.0 - h);
}

// Calculate SDF based on shape type
float calculate_sdf(vec3 p) {
    // Apply time animation
    float t = TIME * time_scale;
    vec3 anim_p = p;
    anim_p.x += sin(t * 0.7) * 0.3;
    anim_p.y += cos(t * 0.5) * 0.2;

    // Add noise distortion
    float noise = noise_3d(p * 3.0 + vec3(t * 0.1)) * 0.1;
    anim_p += noise;

    float result = 0.0;

    if (shape_type == 0) { // Sphere
        result = sdf_sphere(anim_p, 0.8);
    }
    else if (shape_type == 1) { // Torus
        result = sdf_torus(anim_p, 0.7, 0.3);
    }
    else if (shape_type == 2) { // Box
        result = sdf_box(anim_p, vec3(0.6));
    }
    else if (shape_type == 3) { // Blended shapes
        float sphere1 = sdf_sphere(anim_p, 0.8);
        float sphere2 = sdf_sphere(anim_p - vec3(0.5, 0.2, 0.3), 0.5);
        result = smooth_min(sphere1, sphere2, 0.3);
    }
    else if (shape_type == 4) { // Morphing shapes
        float shape1 = sdf_sphere(anim_p, 0.8);
        float shape2 = sdf_torus(anim_p, 0.7, 0.3);
        float morph = (sin(t) + 1.0) * 0.5; // 0 to 1
        result = mix(shape1, shape2, morph);
    }

    return result;
}

// Ray marching for SDF visualization
vec4 ray_march(vec3 ro, vec3 rd) {
    float total_distance = 0.0;
    float min_distance = max_distance;

    for (float steps = 0.0; steps < max_steps; steps++) {
        vec3 p = ro + rd * total_distance;
        float distance = calculate_sdf(p);

        min_distance = min(min_distance, distance);
        total_distance += distance;

        if (distance < epsilon) {
            // Hit the surface
            return vec4(1.0, total_distance, steps / max_steps, 0.0);
        }

        if (total_distance > max_distance) {
            // Missed the object
            break;
        }
    }

    // Missed, but can still visualize the distance field
    return vec4(0.0, total_distance, min_distance, min_distance);
}

// Calculate normal at surface point
vec3 calculate_normal(vec3 p) {
    const float h = 0.0001;
    return normalize(vec3(
        calculate_sdf(p + vec3(h, 0.0, 0.0)) - calculate_sdf(p - vec3(h, 0.0, 0.0)),
        calculate_sdf(p + vec3(0.0, h, 0.0)) - calculate_sdf(p - vec3(0.0, h, 0.0)),
        calculate_sdf(p + vec3(0.0, 0.0, h)) - calculate_sdf(p - vec3(0.0, 0.0, h))
    ));
}

void vertex() {
    // Billboard the quad to always face the camera
    MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
    // Get direction from the center of screen to the current fragment
    vec2 uv = (2.0 * UV - 1.0);
    vec3 ro = vec3(0.0, 0.0, 2.0); // Ray origin (camera position)
    vec3 rd = normalize(vec3(uv, -1.0)); // Ray direction

    // Ray march to find the surface
    vec4 result = ray_march(ro, rd);

    if (result.x > 0.0) {
        // Surface hit
        vec3 hit_point = ro + rd * result.y;
        vec3 normal = calculate_normal(hit_point);

        // Simple lighting
        vec3 light_dir = normalize(vec3(1.0, 1.0, -0.5));
        float diffuse = max(0.0, dot(normal, light_dir));
        float ambient = 0.2;
        float lighting = ambient + diffuse;

        ALBEDO = surface_color.rgb * lighting;
        ALPHA = 1.0;
    } else {
        // Visualize distance field
        float closest_distance = result.z;
        float distance_field = result.w;

        // Highlight the isosurface
        if (abs(distance_field) < surface_thickness) {
            ALBEDO = surface_color.rgb;
            ALPHA = 1.0;
        } else if (distance_field < 0.0) {
            // Inside the shape
            ALBEDO = interior_color.rgb;
            ALPHA = 0.6;
        } else {
            // Outside the shape
            ALBEDO = exterior_color.rgb;
            ALPHA = 0.3 * (1.0 - min(distance_field, 1.0));
        }
    }
}