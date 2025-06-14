extends Node
class_name WordPhysics

# ------------------------------------
# WordPhysics - Physics engine for the World of Words system
# Simulates physical behavior of words and interactions between them
# ------------------------------------

# Physics constants
const GRAVITY = Vector3(0, -9.8, 0)
const DAMPING = 0.99
const FLOOR_FRICTION = 0.9
const CONNECTION_DISTANCE_DEFAULT = 2.0
const DIMENSION_PHYSICS = {
    "1D": {
        "enabled": false,
        "gravity_factor": 0.0,
        "restriction": "x",
        "damping": 0.9
    },
    "2D": {
        "enabled": true,
        "gravity_factor": 0.5,
        "restriction": "xy",
        "damping": 0.95
    },
    "3D": {
        "enabled": true,
        "gravity_factor": 1.0,
        "restriction": "none",
        "damping": 0.99
    },
    "4D": {
        "enabled": true,
        "gravity_factor": 0.8,
        "restriction": "none",
        "damping": 0.98,
        "time_factor": 1.2
    },
    "5D": {
        "enabled": true,
        "gravity_factor": 0.3,
        "restriction": "none",
        "damping": 0.97,
        "probability_factor": true
    },
    "6D": {
        "enabled": false,
        "conceptual": true
    },
    "7D": {
        "enabled": false,
        "metaphysical": true
    }
}

# System state
var physics_enabled = true
var auto_physics = true
var collision_detection = true
var word_drive = null
var current_dimension = "3D"
var last_physics_time = 0

# Word physics state tracking
var word_physics_state = {}
var connection_physics_state = {}

# Force effect system
var force_effects = []

# Signal declarations
signal collision_detected(word_id_1, word_id_2, impact_velocity)
signal word_physics_updated(word_id, physics_state)
signal word_touched_boundary(word_id, boundary, velocity)
signal force_applied(word_id, force, source)

# Initialize physics engine
func _ready():
    print("WordPhysics initialized")
    last_physics_time = OS.get_unix_time()

# Process physics
func process_physics(delta):
    if not physics_enabled or not word_drive:
        return
    
    # Get dimension physics properties
    var dim_physics = DIMENSION_PHYSICS[current_dimension] if DIMENSION_PHYSICS.has(current_dimension) else DIMENSION_PHYSICS["3D"]
    
    # Skip processing if physics not enabled for this dimension
    if not dim_physics.get("enabled", true):
        return
    
    # Get reference to words and connections
    var words = word_drive.get_all_words()
    var connections = word_drive.get_all_connections()
    
    # Update physics timestamp
    last_physics_time = OS.get_unix_time()
    
    # Process each word
    for word_id in words:
        var word = words[word_id]
        _process_word_physics(word_id, word, delta, dim_physics)
    
    # Process connections
    for connection_id in connections:
        var connection = connections[connection_id]
        _process_connection_physics(connection_id, connection, words, delta, dim_physics)
    
    # Process force effects (temporary forces like explosions, attractions, etc.)
    _process_force_effects(words, delta)
    
    # Process collisions
    if collision_detection:
        _process_collisions(words, delta)

# Process physics for a single word
func _process_word_physics(word_id, word, delta, dim_physics):
    # Ensure we have a physics state for this word
    if not word_physics_state.has(word_id):
        word_physics_state[word_id] = {
            "position": word.get("position", Vector3(0, 0, 0)),
            "velocity": word.get("velocity", Vector3(0, 0, 0)),
            "acceleration": Vector3(0, 0, 0),
            "rotation": word.get("rotation", Vector3(0, 0, 0)),
            "angular_velocity": word.get("angular_velocity", Vector3(0, 0, 0)),
            "mass": word.get("mass", 1.0),
            "forces": []
        }
    
    var physics = word_physics_state[word_id]
    
    # Reset acceleration
    physics.acceleration = Vector3(0, 0, 0)
    
    # Apply gravity if enabled
    if dim_physics.get("gravity_factor", 0.0) > 0:
        var gravity_effect = GRAVITY * dim_physics.gravity_factor
        physics.acceleration += gravity_effect
    
    # Apply accumulated forces
    for force in physics.forces:
        physics.acceleration += force / physics.mass
    
    # Clear forces for next frame
    physics.forces.clear()
    
    # Update velocity
    physics.velocity += physics.acceleration * delta
    
    # Apply damping
    physics.velocity *= dim_physics.get("damping", DAMPING)
    
    # Apply dimension restrictions
    match dim_physics.get("restriction", "none"):
        "x":
            # 1D restriction - only move along x axis
            physics.velocity.y = 0
            physics.velocity.z = 0
        "xy":
            # 2D restriction - only move on xy plane
            physics.velocity.z = 0
    
    # Special dimension effects
    if dim_physics.get("probability_factor", false):
        # 5D adds randomness to movement (probability waves)
        physics.velocity += Vector3(
            rand_range(-0.1, 0.1),
            rand_range(-0.1, 0.1),
            rand_range(-0.1, 0.1)
        ) * dim_physics.get("probability_strength", 0.5)
    
    # Update position
    physics.position += physics.velocity * delta
    
    # Update rotation (from angular velocity)
    physics.rotation += physics.angular_velocity * delta
    
    # Apply world boundaries
    _apply_boundaries(word_id, physics, dim_physics)
    
    # Update the word in the data drive
    word_drive.send_message("physics_update", {
        "word_id": word_id,
        "position": physics.position,
        "velocity": physics.velocity,
        "rotation": physics.rotation,
        "angular_velocity": physics.angular_velocity,
        "interaction_type": "physics_update"
    })
    
    # Emit signal
    emit_signal("word_physics_updated", word_id, physics)

# Process physics for connections
func _process_connection_physics(connection_id, connection, words, delta, dim_physics):
    var from_id = connection.from_id
    var to_id = connection.to_id
    
    # Ensure both words exist
    if not words.has(from_id) or not words.has(to_id):
        return
    
    # Ensure both words have physics state
    if not word_physics_state.has(from_id) or not word_physics_state.has(to_id):
        return
    
    var from_physics = word_physics_state[from_id]
    var to_physics = word_physics_state[to_id]
    
    # Calculate connection parameters
    var connection_strength = connection.get("strength", 1.0)
    var ideal_distance = connection.get("ideal_distance", CONNECTION_DISTANCE_DEFAULT)
    
    # Calculate spring force
    var direction = (from_physics.position - to_physics.position).normalized()
    var current_distance = from_physics.position.distance_to(to_physics.position)
    var extension = current_distance - ideal_distance
    
    # Skip if too far or too close (within tolerance)
    var tolerance = 0.01
    if abs(extension) < tolerance:
        return
    
    # Calculate spring force (Hooke's law: F = k * x)
    var spring_constant = 2.0 * connection_strength
    var force_magnitude = extension * spring_constant
    var force = direction * force_magnitude
    
    # Apply to words (equal and opposite)
    var from_word = words[from_id]
    var to_word = words[to_id]
    
    var from_mass = from_physics.mass
    var to_mass = to_physics.mass
    
    # Add forces to words
    word_physics_state[from_id].forces.append(-force)
    word_physics_state[to_id].forces.append(force)
    
    # If we have a special connection style, apply additional effects
    if connection.has("style"):
        match connection.style:
            "elastic":
                # More springy behavior
                _apply_elastic_effect(from_id, to_id, connection, delta)
            "rigid":
                # Stiffer connection
                _apply_rigid_effect(from_id, to_id, connection, delta)
            "magnetic":
                # Attraction without physical connection
                _apply_magnetic_effect(from_id, to_id, connection, delta)
            "energy":
                # Energy transfer between words
                _apply_energy_transfer(from_id, to_id, connection, delta)

# Apply world boundaries to keep words in visible space
func _apply_boundaries(word_id, physics, dim_physics):
    var boundary_size = 20.0
    var boundary_hit = false
    var boundary_name = ""
    var impact_velocity = Vector3.ZERO
    
    # Check X boundary
    if physics.position.x < -boundary_size:
        physics.position.x = -boundary_size
        impact_velocity = physics.velocity
        physics.velocity.x *= -0.8
        boundary_hit = true
        boundary_name = "left"
    elif physics.position.x > boundary_size:
        physics.position.x = boundary_size
        impact_velocity = physics.velocity
        physics.velocity.x *= -0.8
        boundary_hit = true
        boundary_name = "right"
    
    # Check Y boundary (floor and ceiling)
    if physics.position.y < 0:
        physics.position.y = 0
        impact_velocity = physics.velocity
        physics.velocity.y *= -0.5
        physics.velocity.x *= FLOOR_FRICTION
        physics.velocity.z *= FLOOR_FRICTION
        boundary_hit = true
        boundary_name = "floor"
    elif physics.position.y > boundary_size:
        physics.position.y = boundary_size
        impact_velocity = physics.velocity
        physics.velocity.y *= -0.8
        boundary_hit = true
        boundary_name = "ceiling"
    
    # Check Z boundary
    if physics.position.z < -boundary_size:
        physics.position.z = -boundary_size
        impact_velocity = physics.velocity
        physics.velocity.z *= -0.8
        boundary_hit = true
        boundary_name = "back"
    elif physics.position.z > boundary_size:
        physics.position.z = boundary_size
        impact_velocity = physics.velocity
        physics.velocity.z *= -0.8
        boundary_hit = true
        boundary_name = "front"
    
    # Emit signal if boundary was hit
    if boundary_hit:
        emit_signal("word_touched_boundary", word_id, boundary_name, impact_velocity)

# Process collisions between words
func _process_collisions(words, delta):
    var word_ids = word_physics_state.keys()
    
    # Check all pairs of words
    for i in range(word_ids.size()):
        var word_id1 = word_ids[i]
        
        for j in range(i + 1, word_ids.size()):
            var word_id2 = word_ids[j]
            
            var physics1 = word_physics_state[word_id1]
            var physics2 = word_physics_state[word_id2]
            
            # Simple sphere collision check
            var word1 = words[word_id1]
            var word2 = words[word_id2]
            
            var radius1 = _calculate_word_radius(word1)
            var radius2 = _calculate_word_radius(word2)
            var min_distance = radius1 + radius2
            
            var current_distance = physics1.position.distance_to(physics2.position)
            
            if current_distance < min_distance:
                _resolve_collision(word_id1, word_id2, physics1, physics2, min_distance, current_distance)

# Resolve collision between two words
func _resolve_collision(word_id1, word_id2, physics1, physics2, min_distance, current_distance):
    # Calculate collision normal
    var normal = (physics2.position - physics1.position).normalized()
    
    # Calculate relative velocity
    var relative_velocity = physics2.velocity - physics1.velocity
    var velocity_along_normal = relative_velocity.dot(normal)
    
    # Skip if objects are moving away from each other
    if velocity_along_normal > 0:
        return
    
    # Calculate impact velocities for notification
    var impact_velocity = relative_velocity.length()
    
    # Calculate impulse
    var e = 0.7  # Coefficient of restitution (bounciness)
    var j = -(1 + e) * velocity_along_normal
    j /= 1/physics1.mass + 1/physics2.mass
    
    # Apply impulse
    var impulse = normal * j
    physics1.velocity -= (1 / physics1.mass) * impulse
    physics2.velocity += (1 / physics2.mass) * impulse
    
    # Positional correction to prevent sinking
    var percent = 0.2  # Penetration percentage to correct
    var correction = normal * (min_distance - current_distance) * percent
    
    physics1.position -= correction * (1 / physics1.mass) / (1/physics1.mass + 1/physics2.mass)
    physics2.position += correction * (1 / physics2.mass) / (1/physics1.mass + 1/physics2.mass)
    
    # Emit collision signal
    emit_signal("collision_detected", word_id1, word_id2, impact_velocity)

# Calculate approximated radius for a word based on its properties
func _calculate_word_radius(word):
    var base_radius = 0.5
    var power_factor = word.get("power", 25) / 50.0
    var evolution_factor = word.get("evolution_stage", 1) / 3.0
    
    return base_radius * (1.0 + power_factor * 0.5 + evolution_factor * 0.3)

# Process temporary force effects
func _process_force_effects(words, delta):
    var effects_to_remove = []
    
    for i in range(force_effects.size()):
        var effect = force_effects[i]
        
        # Check if effect expired
        effect.duration -= delta
        if effect.duration <= 0:
            effects_to_remove.append(i)
            continue
        
        # Apply effect based on type
        match effect.type:
            "explosion":
                _apply_explosion_effect(effect, words, delta)
            "vortex":
                _apply_vortex_effect(effect, words, delta)
            "attractor":
                _apply_attractor_effect(effect, words, delta)
            "wave":
                _apply_wave_effect(effect, words, delta)
    
    # Remove expired effects
    for i in range(effects_to_remove.size() - 1, -1, -1):
        force_effects.remove(effects_to_remove[i])

# Apply explosion force effect
func _apply_explosion_effect(effect, words, delta):
    var origin = effect.position
    var strength = effect.strength
    var radius = effect.radius
    var falloff = effect.get("falloff", 2.0)  # Quadratic falloff by default
    
    for word_id in word_physics_state:
        var physics = word_physics_state[word_id]
        var distance = physics.position.distance_to(origin)
        
        if distance <= radius:
            var direction = (physics.position - origin).normalized()
            var force_magnitude = strength * pow(1 - distance/radius, falloff)
            var force = direction * force_magnitude
            
            physics.forces.append(force)
            emit_signal("force_applied", word_id, force, "explosion")

# Apply vortex force effect
func _apply_vortex_effect(effect, words, delta):
    var origin = effect.position
    var strength = effect.strength
    var radius = effect.radius
    var axis = effect.get("axis", Vector3.UP)
    
    for word_id in word_physics_state:
        var physics = word_physics_state[word_id]
        var offset = physics.position - origin
        var distance = offset.length()
        
        if distance <= radius:
            var factor = 1.0 - distance/radius
            
            # Create rotating force around axis
            var tangent = offset.cross(axis).normalized()
            var force = tangent * strength * factor
            
            physics.forces.append(force)
            emit_signal("force_applied", word_id, force, "vortex")

# Apply attractor force effect
func _apply_attractor_effect(effect, words, delta):
    var origin = effect.position
    var strength = effect.strength
    var radius = effect.radius
    
    for word_id in word_physics_state:
        var physics = word_physics_state[word_id]
        var offset = origin - physics.position
        var distance = offset.length()
        
        if distance <= radius:
            var direction = offset.normalized()
            var force_magnitude = strength * (1.0 - distance/radius)
            var force = direction * force_magnitude
            
            physics.forces.append(force)
            emit_signal("force_applied", word_id, force, "attractor")

# Apply wave force effect
func _apply_wave_effect(effect, words, delta):
    var origin = effect.position
    var strength = effect.strength
    var wavelength = effect.get("wavelength", 2.0)
    var speed = effect.get("speed", 5.0)
    var time = effect.get("time", 0.0) + delta
    effect.time = time
    
    for word_id in word_physics_state:
        var physics = word_physics_state[word_id]
        var distance = physics.position.distance_to(origin)
        
        # Calculate wave amplitude based on distance and time
        var wave_phase = (distance - speed * time) / wavelength
        var amplitude = strength * sin(wave_phase * 2 * PI)
        
        # Direction is radially outward from origin
        var direction = (physics.position - origin).normalized()
        var force = direction * amplitude
        
        physics.forces.append(force)
        emit_signal("force_applied", word_id, force, "wave")

# Apply elastic connection effect
func _apply_elastic_effect(from_id, to_id, connection, delta):
    if not word_physics_state.has(from_id) or not word_physics_state.has(to_id):
        return
    
    var from_physics = word_physics_state[from_id]
    var to_physics = word_physics_state[to_id]
    
    # Add some oscillation to the motion
    var oscillation = sin(OS.get_ticks_msec() / 1000.0 * 2.0) * 0.1
    
    # Apply to angular velocity for visual effect
    from_physics.angular_velocity.y += oscillation
    to_physics.angular_velocity.y -= oscillation

# Apply rigid connection effect
func _apply_rigid_effect(from_id, to_id, connection, delta):
    if not word_physics_state.has(from_id) or not word_physics_state.has(to_id):
        return
    
    var from_physics = word_physics_state[from_id]
    var to_physics = word_physics_state[to_id]
    
    // More rigid connections attempt to maintain exact distance
    var direction = (from_physics.position - to_physics.position).normalized()
    var current_distance = from_physics.position.distance_to(to_physics.position)
    var ideal_distance = connection.get("ideal_distance", CONNECTION_DISTANCE_DEFAULT)
    
    // Strong correction factor
    var correction_factor = 0.5
    var correction = (current_distance - ideal_distance) * correction_factor
    
    // Apply correction to positions
    var total_mass = from_physics.mass + to_physics.mass
    var from_ratio = to_physics.mass / total_mass
    var to_ratio = from_physics.mass / total_mass
    
    from_physics.position -= direction * correction * from_ratio
    to_physics.position += direction * correction * to_ratio
    
    // Transfer some angular momentum
    var angular_transfer = from_physics.angular_velocity - to_physics.angular_velocity
    from_physics.angular_velocity -= angular_transfer * 0.01
    to_physics.angular_velocity += angular_transfer * 0.01

# Apply magnetic connection effect
func _apply_magnetic_effect(from_id, to_id, connection, delta):
    if not word_physics_state.has(from_id) or not word_physics_state.has(to_id):
        return
    
    var from_physics = word_physics_state[from_id]
    var to_physics = word_physics_state[to_id]
    
    // Magnetic effect applies force only when certain distance is exceeded
    var direction = (from_physics.position - to_physics.position).normalized()
    var current_distance = from_physics.position.distance_to(to_physics.position)
    var ideal_distance = connection.get("ideal_distance", CONNECTION_DISTANCE_DEFAULT)
    
    // Only attract when further than ideal distance
    if current_distance > ideal_distance:
        var strength = connection.get("strength", 1.0) * 0.5
        var force = direction * strength
        
        // Apply weaker forces for magnetic connections
        word_physics_state[from_id].forces.append(-force * 0.5)
        word_physics_state[to_id].forces.append(force * 0.5)
    }

# Apply energy transfer effect between connected words
func _apply_energy_transfer(from_id, to_id, connection, delta):
    if not word_physics_state.has(from_id) or not word_physics_state.has(to_id):
        return
    
    var from_physics = word_physics_state[from_id]
    var to_physics = word_physics_state[to_id]
    
    // Energy transfer gradually balances kinetic energy
    var from_energy = from_physics.velocity.length_squared()
    var to_energy = to_physics.velocity.length_squared()
    
    // Transfer a small amount of energy in each update
    if from_energy > to_energy:
        var transfer_amount = 0.05
        var energy_transfer = (from_energy - to_energy) * transfer_amount
        
        // Apply slight boost to slower object
        if to_physics.velocity.length() > 0.01:
            var boost_direction = to_physics.velocity.normalized()
            var boost = boost_direction * sqrt(energy_transfer)
            to_physics.velocity += boost
            
            // Corresponding reduction in energy for the faster object
            if from_physics.velocity.length() > 0.01:
                var slow_direction = from_physics.velocity.normalized()
                var reduction = slow_direction * sqrt(energy_transfer)
                from_physics.velocity -= reduction
    } else {
        var transfer_amount = 0.05
        var energy_transfer = (to_energy - from_energy) * transfer_amount
        
        // Apply slight boost to slower object
        if from_physics.velocity.length() > 0.01:
            var boost_direction = from_physics.velocity.normalized()
            var boost = boost_direction * sqrt(energy_transfer)
            from_physics.velocity += boost
            
            // Corresponding reduction in energy for the faster object
            if to_physics.velocity.length() > 0.01:
                var slow_direction = to_physics.velocity.normalized()
                var reduction = slow_direction * sqrt(energy_transfer)
                to_physics.velocity -= reduction
    }

# Public API: Set physics enabled state
func set_physics_enabled(enabled):
    physics_enabled = enabled

# Public API: Set current dimension
func set_dimension(dimension):
    if DIMENSION_PHYSICS.has(dimension):
        current_dimension = dimension

# Public API: Apply force to word
func apply_force(word_id, force, source = "external"):
    if not word_physics_state.has(word_id):
        return false
    
    word_physics_state[word_id].forces.append(force)
    emit_signal("force_applied", word_id, force, source)
    return true

# Public API: Apply impulse to word (immediate velocity change)
func apply_impulse(word_id, impulse):
    if not word_physics_state.has(word_id):
        return false
    
    var physics = word_physics_state[word_id]
    physics.velocity += impulse / physics.mass
    return true

# Public API: Set position of a word
func set_position(word_id, position):
    if not word_physics_state.has(word_id):
        word_physics_state[word_id] = {
            "position": position,
            "velocity": Vector3(0, 0, 0),
            "acceleration": Vector3(0, 0, 0),
            "rotation": Vector3(0, 0, 0),
            "angular_velocity": Vector3(0, 0, 0),
            "mass": 1.0,
            "forces": []
        }
    else:
        word_physics_state[word_id].position = position
    
    return true

# Public API: Add a force effect to the system
func add_force_effect(effect_type, position, strength, radius, duration, additional_properties = {}):
    var effect = {
        "type": effect_type,
        "position": position,
        "strength": strength,
        "radius": radius,
        "duration": duration,
        "creation_time": OS.get_unix_time()
    }
    
    # Add any additional properties
    for key in additional_properties:
        effect[key] = additional_properties[key]
    
    force_effects.append(effect)
    return effect

# Public API: Clear all physics state
func clear_physics_state():
    word_physics_state.clear()
    connection_physics_state.clear()
    force_effects.clear()

# Public API: Get physics state for a word
func get_word_physics(word_id):
    if word_physics_state.has(word_id):
        return word_physics_state[word_id]
    return null

# Public API: Connect to WordDrive
func connect_to_word_drive(drive):
    word_drive = drive
    
    if word_drive:
        word_drive.send_message("system_command", {
            "command": "set_physics_engine",
            "engine": self
        })