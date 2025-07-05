// cosmic_particle_spectacular.gdshader - MAXIMUM SPECTACLE PARTICLE EFFECTS
// Agent 5 (Visual Designer) Creation - Enhanced cosmic particle visualization
// Perfect for nebulae, star fields, and consciousness particle streams

shader_type particles;

// Cosmic Particle Types
uniform int particle_type : hint_range(0, 4) = 0; // 0=Stardust, 1=Nebula, 2=Consciousness, 3=Energy, 4=Quantum
uniform float cosmic_scale : hint_range(0.1, 1000.0) = 100.0;
uniform float time_scale : hint_range(0.1, 10.0) = 1.0;

// Visual Enhancement Parameters  
uniform float brightness_multiplier : hint_range(0.1, 10.0) = 3.0;
uniform float size_variation : hint_range(0.1, 5.0) = 2.0;
uniform vec3 base_color : source_color = vec3(1.0, 1.0, 1.0);
uniform vec3 energy_color : source_color = vec3(0.3, 0.8, 1.0);

// Consciousness Integration
uniform float consciousness_influence : hint_range(0.0, 2.0) = 1.0;
uniform float consciousness_frequency : hint_range(1.0, 999.0) = 42.0;
uniform bool consciousness_mode : hint_range(0, 1) = false;

// Archaeological Optimizations (Discovered patterns)
uniform bool sacred_geometry : hint_range(0, 1) = true;
uniform bool golden_ratio_movement : hint_range(0, 1) = true;
uniform float wisdom_multiplier : hint_range(1.0, 3.0) = 1.8;

// Performance Optimization
uniform bool gpu_optimization : hint_range(0, 1) = true;
uniform int max_particles : hint_range(1000, 100000) = 50000;

// Hash function for pseudo-random generation
float hash(float p) {
    p = fract(p * 0.1031);
    p *= p + 33.33;
    p *= p + p;
    return fract(p);
}

vec3 hash3(float p) {
    vec3 p3 = fract(vec3(p) * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yxz + 33.33);
    return fract((p3.xxy + p3.yxx) * p3.zyx);
}

// Consciousness wave function
float consciousness_wave(float time, float frequency) {
    if (!consciousness_mode) return 1.0;
    
    float wave = sin(frequency * 0.1 * time);
    wave += sin(frequency * 0.05 * time) * 0.5;
    wave += sin(frequency * 0.02 * time) * 0.25;
    
    return 0.7 + 0.3 * wave * consciousness_influence;
}

// Sacred geometry influence on particle movement
vec3 sacred_geometry_influence(vec3 pos, float time) {
    if (!sacred_geometry) return vec3(0.0);
    
    float golden_ratio = 1.618033988749;
    
    // Pentagon architecture influence (5-fold symmetry)
    float pentagon_angle = atan(pos.y, pos.x) * 5.0;
    vec3 pentagon_force = vec3(
        cos(pentagon_angle + time),
        sin(pentagon_angle + time),
        sin(pentagon_angle * golden_ratio + time * 0.5)
    ) * 0.1;
    
    // Golden ratio spiral
    if (golden_ratio_movement) {
        float spiral_radius = length(pos.xy);
        float spiral_angle = atan(pos.y, pos.x) + time * 0.5;
        
        pentagon_force += vec3(
            cos(spiral_angle * golden_ratio) * 0.05,
            sin(spiral_angle * golden_ratio) * 0.05,
            sin(spiral_radius * golden_ratio + time) * 0.03
        );
    }
    
    return pentagon_force * wisdom_multiplier;
}

void start() {
    float particle_id = float(INDEX);
    vec3 random_vals = hash3(particle_id);
    
    // Particle type-specific initialization
    if (particle_type == 0) { // Stardust
        VELOCITY = (random_vals - 0.5) * 10.0 * cosmic_scale * 0.01;
        CUSTOM.x = random_vals.x * 2.0 + 0.5; // Brightness
        CUSTOM.y = random_vals.y * size_variation + 0.5; // Size
        
    } else if (particle_type == 1) { // Nebula gas
        VELOCITY = (random_vals - 0.5) * 2.0 * cosmic_scale * 0.01;
        CUSTOM.x = random_vals.x * 1.5 + 0.3; // Brightness
        CUSTOM.y = random_vals.y * size_variation * 2.0 + 1.0; // Larger size
        
    } else if (particle_type == 2) { // Consciousness particles
        float consciousness_speed = consciousness_influence * 5.0;
        VELOCITY = (random_vals - 0.5) * consciousness_speed * cosmic_scale * 0.01;
        CUSTOM.x = random_vals.x * consciousness_influence + 0.5;
        CUSTOM.y = random_vals.y * size_variation + 0.3;
        
    } else if (particle_type == 3) { // Energy streams
        VELOCITY = (random_vals - 0.5) * 15.0 * cosmic_scale * 0.01;
        CUSTOM.x = random_vals.x * 3.0 + 1.0; // High brightness
        CUSTOM.y = random_vals.y * size_variation * 0.5 + 0.2; // Smaller size
        
    } else if (particle_type == 4) { // Quantum particles
        VELOCITY = (random_vals - 0.5) * 8.0 * cosmic_scale * 0.01;
        CUSTOM.x = random_vals.x * 4.0 + 0.5; // Variable brightness
        CUSTOM.y = random_vals.y * size_variation * 0.3 + 0.1; // Very small
    }
    
    // Initial position in cosmic space
    TRANSFORM[3].xyz = (random_vals - 0.5) * cosmic_scale;
    
    // Store particle type in CUSTOM.z
    CUSTOM.z = float(particle_type);
    
    // Archaeological wisdom enhancement
    CUSTOM.x *= wisdom_multiplier * 0.5 + 0.5;
}

void process() {
    float time = TIME * time_scale;
    float particle_id = float(INDEX);
    float stored_particle_type = CUSTOM.z;
    
    // Base physics
    vec3 position = TRANSFORM[3].xyz;
    vec3 velocity = VELOCITY;
    
    // Consciousness wave influence
    float consciousness_effect = consciousness_wave(time, consciousness_frequency);
    velocity *= consciousness_effect;
    
    // Sacred geometry influence
    vec3 sacred_force = sacred_geometry_influence(position, time);
    velocity += sacred_force;
    
    // Particle type-specific behavior
    if (int(stored_particle_type) == 0) { // Stardust
        // Gentle stellar wind influence
        velocity += vec3(sin(time * 0.5), cos(time * 0.3), sin(time * 0.8)) * 0.5;
        
    } else if (int(stored_particle_type) == 1) { // Nebula gas
        // Turbulent gas dynamics
        float turbulence = sin(position.x * 0.1 + time) * cos(position.y * 0.1 + time);
        velocity += vec3(turbulence, turbulence * 0.5, turbulence * 0.3) * 2.0;
        
    } else if (int(stored_particle_type) == 2) { // Consciousness particles
        // Consciousness field attraction/repulsion
        float consciousness_field = sin(length(position) * 0.05 + time * consciousness_frequency * 0.01);
        velocity += normalize(position) * consciousness_field * consciousness_influence;
        
    } else if (int(stored_particle_type) == 3) { // Energy streams
        // Directed energy flow
        vec3 energy_direction = normalize(vec3(1.0, 0.5, 0.2));
        velocity += energy_direction * 5.0;
        velocity += vec3(sin(time * 3.0), cos(time * 2.0), sin(time * 4.0)) * 1.0;
        
    } else if (int(stored_particle_type) == 4) { // Quantum particles
        // Quantum uncertainty principle simulation
        float uncertainty = hash(particle_id + time * 10.0);
        velocity += (hash3(particle_id + time) - 0.5) * uncertainty * 10.0;
    }
    
    // Apply velocity
    VELOCITY = velocity;
    
    // Update position
    TRANSFORM[3].xyz += VELOCITY * DELTA;
    
    // Boundary wrapping for infinite effect
    vec3 boundary = vec3(cosmic_scale * 0.5);
    if (abs(TRANSFORM[3].x) > boundary.x) TRANSFORM[3].x *= -0.9;
    if (abs(TRANSFORM[3].y) > boundary.y) TRANSFORM[3].y *= -0.9;
    if (abs(TRANSFORM[3].z) > boundary.z) TRANSFORM[3].z *= -0.9;
    
    // Dynamic brightness based on consciousness
    if (consciousness_mode) {
        CUSTOM.x *= consciousness_effect;
    }
    
    // Archaeological enhancement to brightness
    CUSTOM.x *= wisdom_multiplier * 0.3 + 0.7;
    
    // Performance optimization
    if (gpu_optimization && INDEX > max_particles) {
        CUSTOM.x = 0.0; // Hide excess particles
    }
}