shader_type spatial;
render_mode unshaded, blend_add, depth_prepass;

// Hologram parameters
uniform vec4 hologram_color : source_color = vec4(0.2, 0.8, 1.0, 0.7);
uniform float edge_intensity : hint_range(0.0, 2.0) = 0.8;
uniform float edge_power : hint_range(1.0, 10.0) = 2.0;
uniform float fill_amount : hint_range(0.0, 1.0) = 0.25;

// Scan line parameters
uniform float scan_line_width : hint_range(0.0, 1.0) = 0.1;
uniform float scan_line_speed : hint_range(0.0, 5.0) = 2.0;
uniform float scan_line_offset : hint_range(0.0, 1.0) = 0.0;
uniform bool horizontal_scan_lines = true;
uniform bool vertical_scan_lines = true;

// Flicker effect
uniform float flicker_intensity : hint_range(0.0, 1.0) = 0.1;
uniform float flicker_speed : hint_range(0.0, 10.0) = 3.0;
uniform float noise_scale : hint_range(0.1, 10.0) = 5.0;

// Edge glow
uniform float edge_glow : hint_range(0.0, 1.0) = 0.5;
uniform float glow_width : hint_range(0.0, 1.0) = 0.3;

// Distortion effect
uniform bool distortion_enabled = true;
uniform float distortion_amount : hint_range(0.0, 0.2) = 0.02;
uniform float distortion_speed : hint_range(0.0, 5.0) = 1.0;

// Glitch parameters
uniform bool glitch_enabled = true;
uniform float glitch_intensity : hint_range(0.0, 1.0) = 0.1;
uniform float glitch_speed : hint_range(0.0, 10.0) = 0.5;
uniform float glitch_block_size : hint_range(1.0, 50.0) = 10.0;

varying vec3 vertex_normal;
varying vec3 vertex_position;

// Hash function for noise
float hash(vec2 p) {
    float h = dot(p, vec2(127.1, 311.7));
    return fract(sin(h) * 43758.5453123);
}

// Noise function
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void vertex() {
    vertex_normal = NORMAL;
    vertex_position = VERTEX;
    
    // Apply subtle vertex distortion for a "holographic" effect
    if (distortion_enabled) {
        float time = TIME * distortion_speed;
        float vertex_offset = noise(vertex_position.xz * noise_scale + time) * 2.0 - 1.0;
        VERTEX += NORMAL * vertex_offset * distortion_amount;
    }
}

void fragment() {
    // Calculate fresnel effect for edge glow
    vec3 view_dir = normalize(-VIEW);
    float fresnel = pow(1.0 - abs(dot(normalize(vertex_normal), view_dir)), edge_power);
    
    // Apply scanning line effect
    float scan_line = 0.0;
    
    // Horizontal scan lines
    if (horizontal_scan_lines) {
        float y_scan = mod(UV.y + scan_line_offset, 1.0);
        scan_line += smoothstep(0.5 - scan_line_width * 0.5, 0.5, y_scan) * 
                     (1.0 - smoothstep(0.5, 0.5 + scan_line_width * 0.5, y_scan));
    }
    
    // Vertical scan lines
    if (vertical_scan_lines) {
        float x_scan = mod(UV.x - TIME * scan_line_speed * 0.1, 1.0);
        scan_line += smoothstep(0.5 - scan_line_width * 0.5, 0.5, x_scan) * 
                     (1.0 - smoothstep(0.5, 0.5 + scan_line_width * 0.5, x_scan));
    }
    
    // Moving scan line
    float moving_scan_line = smoothstep(scan_line_offset - scan_line_width, scan_line_offset, UV.y) * 
                             (1.0 - smoothstep(scan_line_offset, scan_line_offset + scan_line_width, UV.y));
    moving_scan_line *= 2.0;
    
    // Apply flicker effect
    float flicker = 1.0;
    if (flicker_intensity > 0.0) {
        flicker = 1.0 - flicker_intensity * noise(vec2(TIME * flicker_speed, TIME * flicker_speed * 0.5));
    }
    
    // Apply glitch effect
    float glitch = 0.0;
    if (glitch_enabled) {
        vec2 block = floor(UV * glitch_block_size);
        float noise_val = hash(block + TIME * glitch_speed);
        
        if (noise_val > 1.0 - glitch_intensity) {
            // Digital glitch artifacts
            float line_noise = hash(block + vec2(0.0, TIME * 10.0));
            glitch = smoothstep(0.5, 1.0, line_noise);
        }
    }
    
    // Calculate final hologram effect
    float edge_glow_amount = fresnel * edge_intensity * flicker;
    float fill = fill_amount * (1.0 - fresnel) * flicker;
    float scan_effect = scan_line * 0.5 + moving_scan_line;
    
    // Combine effects
    float final_alpha = min(1.0, edge_glow_amount + fill + scan_effect + glitch);
    
    // Set output color
    vec3 glow_color = hologram_color.rgb * (1.0 + edge_glow * fresnel);
    ALBEDO = glow_color;
    ALPHA = final_alpha * hologram_color.a;
    
    // Add emission for the glow effect
    EMISSION = glow_color * final_alpha;
}