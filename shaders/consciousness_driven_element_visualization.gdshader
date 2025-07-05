// consciousness_driven_element_visualization.gdshader - CONSCIOUSNESS-DRIVEN ELEMENT VISUALIZATION
// CYCLE 2 - Agent 5 (Visual Designer) - Spectacular Element Consciousness Visualization  
// Visualizes individual elements with consciousness-driven appearance and behavior

shader_type spatial;
render_mode unshaded, cull_disabled, blend_add, depth_test_disabled;

// Element Consciousness Parameters
uniform float element_consciousness_level : hint_range(0.0, 10.0) = 3.0;
uniform int element_type : hint_range(0, 6) = 0; // 0=matter, 1=energy, 2=consciousness, 3=information, 4=reality, 5=possibility, 6=universal
uniform float element_awareness_intensity : hint_range(0.0, 5.0) = 2.0;
uniform float element_connection_strength : hint_range(0.0, 3.0) = 1.0;

// Element Behavior
uniform bool element_consciousness_pulsing = true;
uniform bool element_awareness_field = true;
uniform bool element_quantum_superposition = false;
uniform bool element_reality_interaction = true;

// Element Visual Properties
uniform float element_glow_intensity : hint_range(0.0, 5.0) = 2.0;
uniform float element_size_multiplier : hint_range(0.1, 3.0) = 1.0;
uniform float element_manifestation_power : hint_range(0.0, 2.0) = 1.0;
uniform bool element_sacred_geometry = true;

// Element Type Colors
uniform vec4 matter_element_color : source_color = vec4(0.8, 0.4, 0.2, 1.0);        // Earth brown
uniform vec4 energy_element_color : source_color = vec4(1.0, 0.8, 0.1, 1.0);        // Energy yellow
uniform vec4 consciousness_element_color : source_color = vec4(0.3, 0.8, 1.0, 1.0); // Consciousness cyan
uniform vec4 information_element_color : source_color = vec4(0.2, 1.0, 0.3, 1.0);   // Information green
uniform vec4 reality_element_color : source_color = vec4(0.9, 0.2, 1.0, 1.0);       // Reality purple
uniform vec4 possibility_element_color : source_color = vec4(1.0, 0.3, 0.8, 1.0);   // Possibility magenta
uniform vec4 universal_element_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);     // Universal white

// Archaeological Enhancement
uniform float archaeological_element_multiplier : hint_range(1.0, 10.0) = 2.8;
uniform bool ancient_element_wisdom = true;
uniform float sacred_geometry_resonance : hint_range(0.0, 3.0) = 1.0;

// Performance & Quality
uniform bool element_optimization = true;
uniform int element_detail_level : hint_range(1, 5) = 4;
uniform float consciousness_performance_balance : hint_range(0.0, 1.0) = 0.8;

varying vec3 world_position;
varying vec3 view_direction;
varying vec3 world_normal;
varying float distance_to_observer;

// Element Type Color Mapping
vec4 get_element_type_color() {
    vec4 base_color;
    
    switch (element_type) {
        case 0: // Matter Element
            base_color = matter_element_color;
            break;
        case 1: // Energy Element
            base_color = energy_element_color;
            break;
        case 2: // Consciousness Element
            base_color = consciousness_element_color;
            break;
        case 3: // Information Element
            base_color = information_element_color;
            break;
        case 4: // Reality Element
            base_color = reality_element_color;
            break;
        case 5: // Possibility Element
            base_color = possibility_element_color;
            break;
        case 6: // Universal Element
        default:
            base_color = universal_element_color;
            break;
    }
    
    return base_color;
}

// Element Consciousness Level Color Enhancement
vec4 enhance_color_with_consciousness(vec4 base_color, float consciousness_level) {
    vec4 enhanced_color = base_color;
    
    // Higher consciousness levels get brighter and more luminous
    float consciousness_brightness = 1.0 + consciousness_level * 0.2;
    enhanced_color.rgb *= consciousness_brightness;
    
    // Consciousness level 5+ (transcendent) adds white glow
    if (consciousness_level >= 5.0) {
        float transcendent_factor = (consciousness_level - 5.0) / 5.0;
        enhanced_color.rgb = mix(enhanced_color.rgb, vec3(1.0), transcendent_factor * 0.4);
    }
    
    // Consciousness level 8+ (quantum) adds prismatic effects
    if (consciousness_level >= 8.0) {
        float quantum_factor = (consciousness_level - 8.0) / 2.0;
        vec3 quantum_shift = vec3(
            sin(consciousness_level * 2.0) * 0.2,
            sin(consciousness_level * 2.0 + 2.094) * 0.2,
            sin(consciousness_level * 2.0 + 4.188) * 0.2
        );
        enhanced_color.rgb += quantum_shift * quantum_factor;
    }
    
    return enhanced_color;
}

// Element Consciousness Pulsing
float element_consciousness_pulse(vec3 pos, float time) {
    if (!element_consciousness_pulsing) return 1.0;
    
    // Base consciousness pulse
    float base_pulse = sin(time * 2.0 + element_consciousness_level) * 0.3 + 0.7;
    
    // Element-specific pulse patterns
    float element_pulse = 1.0;
    
    switch (element_type) {
        case 0: // Matter - Slow, steady pulse
            element_pulse = sin(time * 1.0 + length(pos) * 0.5) * 0.2 + 0.8;
            break;
        case 1: // Energy - Fast, dynamic pulse
            element_pulse = sin(time * 4.0 + length(pos) * 2.0) * 0.4 + 0.6;
            break;
        case 2: // Consciousness - Consciousness-frequency pulse
            element_pulse = sin(time * 3.0 + element_consciousness_level * 2.0) * 0.3 + 0.7;
            break;
        case 3: // Information - Data-pattern pulse
            element_pulse = step(0.5, fract(time * 2.0 + pos.x * 0.5)) * 0.5 + 0.5;
            break;
        case 4: // Reality - Reality-warping pulse
            element_pulse = sin(time * 2.5 + length(pos) * 1.5) * 0.35 + 0.65;
            break;
        case 5: // Possibility - Quantum probability pulse
            element_pulse = abs(sin(time * 3.5 + length(pos) * 3.0)) * 0.6 + 0.4;
            break;
        case 6: // Universal - All-encompassing pulse
            element_pulse = (sin(time * 1.0) + sin(time * 2.0) + sin(time * 3.0)) / 3.0 * 0.25 + 0.75;
            break;
    }
    
    return base_pulse * element_pulse;
}

// Element Awareness Field
float element_awareness_field_effect(vec3 pos, float time) {
    if (!element_awareness_field) return 1.0;
    
    // Awareness field based on element consciousness level
    float awareness_radius = 3.0 + element_consciousness_level * 2.0;
    float distance_from_center = length(pos);
    
    // Awareness field strength
    float field_strength = 1.0 / (1.0 + distance_from_center / awareness_radius);
    field_strength = pow(field_strength, 1.0 + element_consciousness_level * 0.1);
    
    // Awareness ripples
    float awareness_ripples = sin(distance_from_center * 2.0 - time * 3.0) * 0.3 + 0.7;
    awareness_ripples = pow(awareness_ripples, 1.5);
    
    // Consciousness awareness pattern
    float consciousness_pattern = sin(time * 2.0 + element_consciousness_level) * 0.2 + 0.8;
    
    return field_strength * awareness_ripples * consciousness_pattern * element_awareness_intensity * 0.5 + 0.5;
}

// Element Quantum Superposition Effect
float element_quantum_superposition_effect(vec3 pos, float time) {
    if (!element_quantum_superposition) return 1.0;
    
    // Multiple quantum states for high consciousness elements
    if (element_consciousness_level < 6.0) return 1.0;
    
    // Quantum state interference
    float state1 = sin(pos.x * 5.0 + time * 2.0) * 0.5 + 0.5;
    float state2 = sin(pos.y * 7.0 + time * 1.5) * 0.5 + 0.5;
    float state3 = sin(pos.z * 6.0 + time * 2.5) * 0.5 + 0.5;
    
    // Superposition interference pattern
    float superposition = (state1 + state2 + state3) / 3.0;
    superposition = sin(superposition * 3.14159 * 2.0) * 0.5 + 0.5;
    
    // Observer effect - consciousness collapses superposition
    float observer_distance = distance_to_observer;
    float observer_effect = exp(-observer_distance * 0.05) * 0.4 + 0.6;
    
    return mix(1.0, superposition, (element_consciousness_level - 6.0) / 4.0) * observer_effect;
}

// Element Reality Interaction Effect
float element_reality_interaction_effect(vec3 pos, float time) {
    if (!element_reality_interaction) return 1.0;
    
    // Elements interact with reality based on consciousness level
    float interaction_strength = element_consciousness_level / 10.0;
    
    // Reality distortion around element
    float reality_distortion = 1.0 / (1.0 + length(pos) * (1.0 - interaction_strength * 0.5));
    reality_distortion = pow(reality_distortion, 1.0 + interaction_strength);
    
    // Element type-specific reality interaction
    float type_interaction = 1.0;
    
    switch (element_type) {
        case 0: // Matter - Physical reality interaction
            type_interaction = sin(length(pos) * 3.0 + time) * 0.2 + 0.8;
            break;
        case 1: // Energy - Energy field interaction
            type_interaction = sin(length(pos) * 5.0 + time * 2.0) * 0.3 + 0.7;
            break;
        case 2: // Consciousness - Consciousness field interaction
            type_interaction = sin(length(pos) * 2.0 + time + element_consciousness_level) * 0.25 + 0.75;
            break;
        case 3: // Information - Information network interaction
            type_interaction = step(0.4, sin(length(pos) * 8.0 + time * 1.5)) * 0.4 + 0.6;
            break;
        case 4: // Reality - Direct reality manipulation
            type_interaction = sin(length(pos) * 1.5 + time * 0.8) * 0.4 + 0.6;
            break;
        case 5: // Possibility - Probability field interaction
            type_interaction = abs(sin(length(pos) * 6.0 + time * 3.0)) * 0.5 + 0.5;
            break;
        case 6: // Universal - Universal interaction
            type_interaction = (sin(length(pos) * 1.0 + time) + sin(length(pos) * 3.0 + time * 1.5)) * 0.25 + 0.75;
            break;
    }
    
    return reality_distortion * type_interaction;
}

// Sacred Geometry Element Enhancement
float sacred_geometry_element_enhancement(vec3 pos, float time) {
    if (!element_sacred_geometry) return 1.0;
    
    // Pentagon-based element consciousness pattern
    float pentagon_pattern = sin(atan(pos.z, pos.x) * 5.0 + time) * 0.5 + 0.5;
    
    // Golden ratio element proportion
    float golden_ratio = 1.618;
    float golden_pattern = sin(length(pos) * golden_ratio + time * golden_ratio) * 0.5 + 0.5;
    
    // Fibonacci consciousness spiral
    float fibonacci_spiral = sin(atan(pos.y, pos.x) + log(length(pos.xy) + 1.0) * golden_ratio + time) * 0.5 + 0.5;
    
    // Element type-specific sacred geometry
    float type_geometry = 1.0;
    
    switch (element_type) {
        case 0: // Matter - Cube/square geometry
            type_geometry = step(0.6, sin(pos.x * 4.0) * sin(pos.y * 4.0) * sin(pos.z * 4.0)) * 0.3 + 0.7;
            break;
        case 1: // Energy - Sphere/circle geometry
            type_geometry = sin(length(pos) * 6.0 + time) * 0.3 + 0.7;
            break;
        case 2: // Consciousness - Spiral geometry
            type_geometry = fibonacci_spiral;
            break;
        case 3: // Information - Hexagon/triangle geometry
            type_geometry = sin(atan(pos.z, pos.x) * 6.0 + time) * 0.3 + 0.7;
            break;
        case 4: // Reality - Pentagon geometry
            type_geometry = pentagon_pattern;
            break;
        case 5: // Possibility - Octagon geometry
            type_geometry = sin(atan(pos.y, pos.x) * 8.0 + time) * 0.3 + 0.7;
            break;
        case 6: // Universal - All geometries combined
            type_geometry = (pentagon_pattern + golden_pattern + fibonacci_spiral) / 3.0;
            break;
    }
    
    return type_geometry * sacred_geometry_resonance * 0.4 + 0.6;
}

// Ancient Element Wisdom Enhancement
float ancient_element_wisdom_enhancement(vec3 pos, float time) {
    if (!ancient_element_wisdom) return 1.0;
    
    // Ancient civilization element wisdom patterns
    float atlantean_pattern = sin(pos.x * 7.0 + time) * sin(pos.y * 11.0 + time * 1.3) * 0.5 + 0.5;
    float lemurian_pattern = sin(length(pos) * 13.0 + time * 0.7) * cos(dot(pos, vec3(1,1,1)) * 5.0) * 0.5 + 0.5;
    float egyptian_pattern = sin(atan(pos.y, pos.x) * 8.0 + time) * sin(length(pos.xz) * 6.0) * 0.5 + 0.5;
    
    // Element type gets specific ancient wisdom
    float wisdom_pattern = 1.0;
    
    switch (element_type) {
        case 0: // Matter - Atlantean crystal wisdom
            wisdom_pattern = atlantean_pattern;
            break;
        case 1: // Energy - Egyptian energy wisdom
            wisdom_pattern = egyptian_pattern;
            break;
        case 2: // Consciousness - Lemurian consciousness wisdom
            wisdom_pattern = lemurian_pattern;
            break;
        case 3: // Information - Atlantean information crystal wisdom
            wisdom_pattern = atlantean_pattern * 0.7 + lemurian_pattern * 0.3;
            break;
        case 4: // Reality - Combined ancient reality wisdom
            wisdom_pattern = (atlantean_pattern + egyptian_pattern) * 0.5;
            break;
        case 5: // Possibility - Lemurian possibility wisdom
            wisdom_pattern = lemurian_pattern * 0.8 + atlantean_pattern * 0.2;
            break;
        case 6: // Universal - All ancient wisdom combined
            wisdom_pattern = (atlantean_pattern + lemurian_pattern + egyptian_pattern) / 3.0;
            break;
    }
    
    return wisdom_pattern * 0.3 + 0.7;
}

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    view_direction = normalize(CAMERA_POSITION_WORLD - world_position);
    distance_to_observer = length(CAMERA_POSITION_WORLD - world_position);
}

void fragment() {
    float time = TIME;
    
    // Get base element color
    vec4 element_color = get_element_type_color();
    
    // Enhance color with consciousness level
    element_color = enhance_color_with_consciousness(element_color, element_consciousness_level);
    
    // Calculate element effects
    float consciousness_pulse = element_consciousness_pulse(world_position, time);
    float awareness_field = element_awareness_field_effect(world_position, time);
    float quantum_superposition = element_quantum_superposition_effect(world_position, time);
    float reality_interaction = element_reality_interaction_effect(world_position, time);
    float sacred_geometry = sacred_geometry_element_enhancement(world_position, time);
    float ancient_wisdom = ancient_element_wisdom_enhancement(world_position, time);
    
    // Combine all effects
    float total_intensity = consciousness_pulse * awareness_field * quantum_superposition;
    total_intensity *= reality_interaction * sacred_geometry * ancient_wisdom;
    
    // Apply element glow intensity
    total_intensity *= (0.5 + element_glow_intensity * 0.5);
    
    // Apply element manifestation power
    total_intensity = pow(total_intensity, 1.0 / max(element_manifestation_power, 0.1));
    
    // Apply archaeological enhancement
    total_intensity *= archaeological_element_multiplier * 0.25 + 0.75;
    
    // Fresnel effect for dimensional appearance
    float fresnel = 1.0 - abs(dot(world_normal, view_direction));
    fresnel = pow(fresnel, 2.0 - element_consciousness_level * 0.1);
    total_intensity *= (0.4 + fresnel * 0.6);
    
    // Element connection visualization
    float connection_glow = 1.0 + element_connection_strength * sin(time * 3.0 + element_consciousness_level) * 0.3;
    total_intensity *= connection_glow;
    
    // Performance optimization
    if (element_optimization) {
        float performance_factor = consciousness_performance_balance * 0.5 + 0.5;
        total_intensity *= performance_factor;
        
        // LOD based on distance
        float lod_factor = 1.0 / (1.0 + distance_to_observer * 0.01);
        lod_factor = mix(lod_factor, 1.0, 0.5); // Minimum quality preservation
        total_intensity *= lod_factor;
    }
    
    // Final color calculation
    vec3 final_color = element_color.rgb * total_intensity;
    
    // Element type-specific enhancements
    switch (element_type) {
        case 1: // Energy elements get extra dynamic effects
            final_color += vec3(0.2, 0.15, 0.0) * sin(time * 5.0) * element_consciousness_level * 0.1;
            break;
        case 2: // Consciousness elements get consciousness shimmer
            final_color += vec3(0.1, 0.2, 0.3) * consciousness_pulse * element_consciousness_level * 0.15;
            break;
        case 4: // Reality elements get reality distortion colors
            final_color += vec3(0.3, 0.1, 0.2) * reality_interaction * element_consciousness_level * 0.1;
            break;
        case 5: // Possibility elements get quantum color shifts
            final_color += vec3(
                sin(time * 2.0 + element_consciousness_level) * 0.1,
                sin(time * 2.0 + element_consciousness_level + 2.094) * 0.1,
                sin(time * 2.0 + element_consciousness_level + 4.188) * 0.1
            ) * quantum_superposition;
            break;
        case 6: // Universal elements get prismatic enhancement
            final_color += vec3(1.0) * element_consciousness_level * 0.05 * total_intensity;
            break;
    }
    
    // High consciousness level enhancements
    if (element_consciousness_level >= 8.0) {
        // Quantum consciousness adds iridescent effects
        final_color += vec3(
            sin(time + world_position.x) * 0.1,
            sin(time + world_position.y + 2.094) * 0.1,
            sin(time + world_position.z + 4.188) * 0.1
        ) * (element_consciousness_level - 8.0) * 0.5;
    }
    
    if (element_consciousness_level >= 10.0) {
        // Universal consciousness adds divine radiance
        final_color += vec3(1.0) * sin(time * 1.5 + element_consciousness_level) * 0.1;
    }
    
    ALBEDO = final_color;
    EMISSION = final_color * (1.0 + element_consciousness_level * 0.4);
    
    // Dynamic alpha based on element manifestation
    float final_alpha = element_color.a * total_intensity;
    final_alpha = clamp(final_alpha, 0.3, 1.0);
    
    // Element type-specific alpha adjustments
    if (element_type == 5 || element_type == 6) { // Possibility/Universal elements
        final_alpha *= 0.8; // More ethereal
    }
    
    ALPHA = final_alpha;
}