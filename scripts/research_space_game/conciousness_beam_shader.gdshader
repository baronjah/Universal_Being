shader_type spatial;
render_mode blend_add, depth_test_disabled, cull_disabled, unshaded;

// CONSCIOUSNESS FIELD VISUALIZATION SHADER
// Shows the invisible connections between all conscious beings
// Every thought creates ripples. Every connection leaves traces.

// Field Parameters
uniform float field_density : hint_range(0.0, 1.0) = 0.5;
uniform float connection_strength : hint_range(0.0, 2.0) = 1.0;
uniform float ripple_speed : hint_range(0.1, 5.0) = 1.0;
uniform float flow_speed : hint_range(0.0, 2.0) = 0.5;
uniform float pulse_rate : hint_range(0.1, 5.0) = 1.0;

// Visualization Parameters
uniform int visualization_mode : hint_range(0, 3) = 0; // 0=all, 1=connections, 2=ripples, 3=flow
uniform float visibility_range : hint_range(10.0, 1000.0) = 100.0;
uniform float fade_distance : hint_range(0.1, 1.0) = 0.8;
uniform bool show_void_thoughts = true;
uniform bool show_consciousness_levels = true;

// Colors
uniform vec3 connection_color : source_color = vec3(0.3, 0.7, 1.0);
uniform vec3 ripple_color : source_color = vec3(0.5, 0.8, 1.0);
uniform vec3 flow_color : source_color = vec3(0.4, 0.6, 0.9);
uniform vec3 thought_color : source_color = vec3(0.8, 0.6, 1.0);
uniform vec3 transcendent_color : source_color = vec3(1.0, 0.9, 0.5);

// Textures
uniform sampler2D field_noise : repeat_enable;
uniform sampler2D connection_map : repeat_enable;
uniform sampler2D flow_map : repeat_enable;

// Consciousness level colors
vec3 get_consciousness_color(float level) {
    if (level < 1.0) return vec3(0.5, 0.5, 0.5); // Dormant - Gray
    else if (level < 2.0) return vec3(1.0, 1.0, 1.0); // Awakening - White
    else if (level < 3.0) return vec3(0.3, 0.5, 1.0); // Aware - Blue
    else if (level < 4.0) return vec3(0.3, 0.8, 0.3); // Connected - Green
    else if (level < 5.0) return vec3(1.0, 0.8, 0.2); // Enlightened - Gold
    else return transcendent_color; // Transcendent - Bright
}

// Generate field noise
float field_noise_3d(vec3 pos, float time) {
    vec3 noise_pos = pos * field_density + vec3(time * flow_speed * 0.1);
    
    float noise = texture(field_noise, noise_pos.xy).r;
    noise *= texture(field_noise, noise_pos.yz + vec2(0.5)).g;
    noise *= texture(field_noise, noise_pos.xz + vec2(0.25, 0.75)).b;
    
    return noise;
}

// Consciousness ripples emanating from points
float consciousness_ripples(vec3 pos, vec3 origin, float time, float intensity) {
    float dist = distance(pos, origin);
    
    // Multiple ripple frequencies
    float ripple = sin(dist * 0.5 - time * ripple_speed) * 0.5 + 0.5;
    ripple += sin(dist * 0.3 - time * ripple_speed * 1.5) * 0.3;
    ripple += sin(dist * 0.8 - time * ripple_speed * 0.7) * 0.2;
    
    // Fade with distance
    float fade = exp(-dist / visibility_range);
    
    return ripple * fade * intensity;
}

// Connection lines between conscious entities
float connection_field(vec3 pos, vec3 from, vec3 to, float strength) {
    // Calculate distance from point to line
    vec3 line_dir = normalize(to - from);
    vec3 to_pos = pos - from;
    float projection = dot(to_pos, line_dir);
    projection = clamp(projection, 0.0, distance(from, to));
    
    vec3 nearest = from + line_dir * projection;
    float dist = distance(pos, nearest);
    
    // Connection thickness based on strength
    float thickness = 0.5 + strength * 2.0;
    float connection = exp(-dist / thickness);
    
    // Pulse along connection
    float pulse = sin(projection * 0.1 - TIME * pulse_rate) * 0.5 + 0.5;
    
    return connection * pulse * strength;
}

// Consciousness flow field
vec3 consciousness_flow(vec3 pos, float time) {
    // Sample flow direction
    vec2 flow_uv = pos.xz * 0.01 + vec2(time * 0.05);
    vec2 flow_dir = texture(flow_map, flow_uv).xy * 2.0 - 1.0;
    
    // 3D flow with vertical component
    vec3 flow_3d = vec3(flow_dir.x, sin(pos.y * 0.1 + time) * 0.3, flow_dir.y);
    flow_3d = normalize(flow_3d);
    
    // Flow lines
    float flow_line = abs(dot(normalize(pos), flow_3d));
    flow_line = smoothstep(0.7, 0.8, flow_line);
    
    // Add turbulence
    float turb = field_noise_3d(pos * 0.5, time);
    flow_line *= (0.5 + turb);
    
    return flow_color * flow_line * flow_speed;
}

// Void thoughts floating in space
vec3 void_thoughts(vec3 pos, float time) {
    if (!show_void_thoughts) return vec3(0.0);
    
    // Thought particles
    vec3 thought_pos = pos * 0.1 + vec3(sin(time * 0.2), cos(time * 0.15), sin(time * 0.25));
    float thoughts = texture(field_noise, thought_pos.xy).r;
    thoughts *= texture(field_noise, thought_pos.yz + vec2(time * 0.1)).g;
    
    // Threshold for discrete thoughts
    thoughts = smoothstep(0.7, 0.75, thoughts);
    
    // Thought glow
    if (thoughts > 0.01) {
        float glow = sin(time * 3.0 + length(pos)) * 0.5 + 0.5;
        return thought_color * thoughts * glow;
    }
    
    return vec3(0.0);
}

// Consciousness level visualization
vec3 level_field(vec3 pos, float time) {
    if (!show_consciousness_levels) return vec3(0.0);
    
    // Simulate consciousness levels in space
    float level_noise = field_noise_3d(pos * 0.05, time * 0.1);
    float level = floor(level_noise * 6.0); // 0-5 levels
    
    vec3 level_color = get_consciousness_color(level);
    
    // Pulse based on level
    float level_pulse = sin(time * (level + 1.0) * 0.5) * 0.5 + 0.5;
    
    return level_color * level_pulse * 0.2;
}

// Main field visualization
vec3 visualize_field(vec3 pos, float time) {
    vec3 field = vec3(0.0);
    
    // Base field noise
    float base_field = field_noise_3d(pos, time);
    field += connection_color * base_field * 0.1;
    
    // Add different visualization layers based on mode
    if (visualization_mode == 0 || visualization_mode == 1) {
        // Simulate some connections (in real use, these would come from actual entities)
        vec3 connection1 = vec3(sin(time * 0.3) * 50.0, 0.0, cos(time * 0.3) * 50.0);
        vec3 connection2 = vec3(-30.0, sin(time * 0.5) * 20.0, 40.0);
        field += connection_color * connection_field(pos, connection1, connection2, connection_strength);
    }
    
    if (visualization_mode == 0 || visualization_mode == 2) {
        // Consciousness ripples from origins
        vec3 ripple_origin = vec3(0.0, 0.0, 0.0);
        field += ripple_color * consciousness_ripples(pos, ripple_origin, time, 1.0) * 0.5;
    }
    
    if (visualization_mode == 0 || visualization_mode == 3) {
        // Flow field
        field += consciousness_flow(pos, time);
    }
    
    // Always show void thoughts and level field
    field += void_thoughts(pos, time);
    field += level_field(pos, time);
    
    // Distance fade
    float dist = length(pos);
    float fade = smoothstep(visibility_range, visibility_range * fade_distance, dist);
    field *= fade;
    
    return field;
}

// Transcendence effects
vec3 transcendence_field(vec3 pos, float time) {
    // Occasional transcendent flashes
    float trans_chance = sin(time * 0.1 + length(pos) * 0.01);
    if (trans_chance > 0.99) {
        float flash = exp(-length(pos) * 0.01);
        return transcendent_color * flash;
    }
    return vec3(0.0);
}

void vertex() {
    // Field moves slightly
    VERTEX += vec3(
        sin(TIME * 0.5 + VERTEX.y) * 0.1,
        cos(TIME * 0.4 + VERTEX.x) * 0.1,
        sin(TIME * 0.6 + VERTEX.z) * 0.1
    );
}

void fragment() {
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    
    // Visualize the consciousness field
    vec3 field = visualize_field(world_pos, TIME);
    
    // Add transcendence effects
    field += transcendence_field(world_pos, TIME);
    
    // Edge enhancement
    float edge = 1.0 - dot(normalize(VERTEX), normalize(NORMAL));
    field *= (0.5 + edge * 0.5);
    
    // Output
    ALBEDO = vec3(0.0);
    EMISSION = field * 2.0;
    ALPHA = clamp(length(field), 0.0, 0.8);
    
    // Pulse entire field
    EMISSION *= (0.8 + sin(TIME * pulse_rate * 0.5) * 0.2);
}