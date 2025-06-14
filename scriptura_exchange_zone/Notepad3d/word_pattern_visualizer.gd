extends Node3D

class_name WordPatternVisualizer

signal pattern_energy_changed(pattern, energy)
signal pattern_resonance_detected(pattern1, pattern2, resonance_value)
signal word_manifestation(word, dimension, energy)

# Configuration
const MAX_PATTERN_DENSITY = 120  # Maximum number of word patterns to visualize
const ENERGY_THRESHOLD_MANIFESTATION = 75.0  # Energy threshold for word manifestation
const PATTERN_UPDATE_INTERVAL = 0.2  # Seconds between pattern updates
const RESONANCE_DETECTION_INTERVAL = 1.0  # Seconds between resonance checks
const MAX_PARTICLE_LIFETIME = 6.0  # Maximum lifetime for pattern particles
const DIMENSION_WORD_AFFINITIES = {
    1: ["base", "physical", "matter", "solid", "tangible", "real", "concrete"],
    2: ["time", "flow", "sequence", "duration", "moment", "temporal", "rhythm"],
    3: ["space", "dimension", "distance", "volume", "area", "void", "field"],
    4: ["energy", "power", "force", "vibration", "light", "heat", "charge"],
    5: ["information", "data", "knowledge", "pattern", "code", "signal", "symbol"],
    6: ["consciousness", "awareness", "mind", "perception", "thought", "sentience", "cognition"],
    7: ["connection", "link", "bridge", "relationship", "network", "web", "bond"],
    8: ["potential", "possibility", "future", "seed", "latent", "unborn", "quantum"],
    9: ["integration", "unity", "whole", "synthesis", "harmony", "convergence", "oneness"]
}

# Word pattern storage
var active_patterns = {}
var pattern_energy = {}
var pattern_position = {}
var pattern_velocity = {}
var pattern_resonances = {}
var pattern_cluster_affinity = {}
var pattern_particle_nodes = {}
var pattern_labels = {}
var pattern_last_update = {}
var pattern_dimensions = {}
var pattern_characters = {}

# Dimensional affinity colors - matches tunnel system
const DIMENSION_COLORS = {
    1: Color(1.0, 0.3, 0.3),  # Red - Base dimension
    2: Color(0.3, 1.0, 0.3),  # Green - Time dimension
    3: Color(0.3, 0.3, 1.0),  # Blue - Space dimension
    4: Color(1.0, 1.0, 0.3),  # Yellow - Energy dimension
    5: Color(1.0, 0.3, 1.0),  # Magenta - Information dimension
    6: Color(0.3, 1.0, 1.0),  # Cyan - Consciousness dimension
    7: Color(1.0, 0.6, 0.0),  # Orange - Connection dimension
    8: Color(0.6, 0.0, 1.0),  # Purple - Potential dimension
    9: Color(0.0, 0.6, 0.3)   # Teal - Integration dimension
}

# References
var tunnel_controller
var ethereal_tunnel_manager
var tunnel_visualizer

# Pattern visualization space
var pattern_container
var word_manifestation_container

# Effects and materials
var pattern_particle_material
var manifestation_material
var word_font
var audio_player

# Animation state
var energy_flow_time = 0.0
var last_resonance_check = 0.0
var last_pattern_cleanup = 0.0
var animation_accumulator = 0.0

# Integration with number system
var numeric_value_total = 0
var numeric_pattern_count = 0
var numeric_resonance_factor = 1.0

func _ready():
    # Create containers
    pattern_container = Node3D.new()
    pattern_container.name = "PatternContainer"
    add_child(pattern_container)
    
    word_manifestation_container = Node3D.new()
    word_manifestation_container.name = "WordManifestationContainer"
    add_child(word_manifestation_container)
    
    # Set up materials
    _setup_materials()
    
    # Create audio player for manifestation sounds
    audio_player = AudioStreamPlayer3D.new()
    audio_player.max_distance = 20.0
    audio_player.unit_size = 3.0
    add_child(audio_player)
    
    # Auto-detect components
    _detect_components()
    
    # Initialize seed patterns
    _initialize_seed_patterns()

func _detect_components():
    # Find tunnel controller
    if not tunnel_controller:
        var potential_controllers = get_tree().get_nodes_in_group("tunnel_controllers")
        if potential_controllers.size() > 0:
            tunnel_controller = potential_controllers[0]
            print("Found tunnel controller: " + tunnel_controller.name)
    
    # Get references from controller
    if tunnel_controller:
        ethereal_tunnel_manager = tunnel_controller.ethereal_tunnel_manager
        tunnel_visualizer = tunnel_controller.tunnel_visualizer

func _setup_materials():
    # Pattern particle material
    pattern_particle_material = StandardMaterial3D.new()
    pattern_particle_material.flags_transparent = true
    pattern_particle_material.flags_unshaded = true
    pattern_particle_material.emission_enabled = true
    pattern_particle_material.emission_energy = 1.5
    
    # Manifestation material with glow
    manifestation_material = StandardMaterial3D.new()
    manifestation_material.flags_transparent = true
    manifestation_material.emission_enabled = true
    manifestation_material.emission_energy = 2.0
    
    # Font for word visualization
    word_font = FontFile.new()
    # In a real implementation, you would load an actual font

func _process(delta):
    # Update patterns at fixed intervals
    animation_accumulator += delta
    energy_flow_time += delta
    
    if animation_accumulator >= PATTERN_UPDATE_INTERVAL:
        # Update pattern positions and energies
        _update_pattern_positions(animation_accumulator)
        _update_pattern_energies(animation_accumulator)
        
        animation_accumulator = 0.0
    
    # Check for resonances
    if energy_flow_time - last_resonance_check >= RESONANCE_DETECTION_INTERVAL:
        _detect_pattern_resonances()
        last_resonance_check = energy_flow_time
    
    # Check for manifestation conditions
    _check_manifestation_conditions()
    
    # Cleanup old patterns occasionally
    if energy_flow_time - last_pattern_cleanup >= 5.0:  # Every 5 seconds
        _cleanup_old_patterns()
        last_pattern_cleanup = energy_flow_time

func add_word_pattern(pattern, initial_energy = 10.0, source_dimension = 3):
    # Don't add duplicate patterns
    if active_patterns.has(pattern):
        # Just boost energy of existing pattern
        pattern_energy[pattern] += initial_energy
        _update_pattern_appearance(pattern)
        return
    
    # Limit number of active patterns
    if active_patterns.size() >= MAX_PATTERN_DENSITY:
        # Remove oldest pattern
        var oldest_pattern = ""
        var oldest_time = INF
        
        for p in active_patterns:
            if pattern_last_update[p] < oldest_time:
                oldest_time = pattern_last_update[p]
                oldest_pattern = p
        
        if oldest_pattern != "":
            remove_word_pattern(oldest_pattern)
    
    # Add new pattern
    active_patterns[pattern] = true
    pattern_energy[pattern] = initial_energy
    pattern_last_update[pattern] = energy_flow_time
    
    # Analyze pattern for dimension affinity
    var dimension = _analyze_pattern_dimension(pattern)
    pattern_dimensions[pattern] = dimension
    
    # Calculate character frequencies for resonance detection
    pattern_characters[pattern] = _analyze_pattern_characters(pattern)
    
    # Generate starting position based on dimension
    var pos = _generate_pattern_position(pattern, dimension)
    pattern_position[pattern] = pos
    
    # Generate initial velocity
    var vel = _generate_pattern_velocity(pattern)
    pattern_velocity[pattern] = vel
    
    # Create visualization for this pattern
    _create_pattern_visualization(pattern)
    
    # Assign to cluster if similar patterns exist
    _assign_pattern_to_cluster(pattern)
    
    # Extract numeric values if present
    _extract_numeric_values(pattern)
    
    return pattern

func remove_word_pattern(pattern):
    if not active_patterns.has(pattern):
        return
    
    # Remove visualization
    if pattern_particle_nodes.has(pattern):
        pattern_particle_nodes[pattern].queue_free()
        pattern_particle_nodes.erase(pattern)
    
    if pattern_labels.has(pattern):
        pattern_labels[pattern].queue_free()
        pattern_labels.erase(pattern)
    
    # Remove pattern data
    active_patterns.erase(pattern)
    pattern_energy.erase(pattern)
    pattern_position.erase(pattern)
    pattern_velocity.erase(pattern)
    pattern_last_update.erase(pattern)
    pattern_dimensions.erase(pattern)
    pattern_characters.erase(pattern)
    
    # Remove from resonances
    var resonances_to_remove = []
    for resonance_key in pattern_resonances.keys():
        var parts = resonance_key.split("_to_")
        if parts[0] == pattern or parts[1] == pattern:
            resonances_to_remove.push_back(resonance_key)
    
    for key in resonances_to_remove:
        pattern_resonances.erase(key)
    
    # Remove from cluster affinities
    pattern_cluster_affinity.erase(pattern)

func visualize_word_pattern(pattern, energy = 10.0, dimension = 3):
    # Add or update the pattern
    if not active_patterns.has(pattern):
        add_word_pattern(pattern, energy, dimension)
    else:
        # Update existing pattern
        pattern_energy[pattern] += energy
        pattern_last_update[pattern] = energy_flow_time
        
        # Update dimension if stronger affinity is detected
        var new_dimension = _analyze_pattern_dimension(pattern)
        if abs(pattern_dimensions[pattern] - new_dimension) >= 2:
            pattern_dimensions[pattern] = new_dimension
        
        # Update visualization
        _update_pattern_appearance(pattern)

func transfer_energy_between_patterns(source_pattern, target_pattern, amount):
    if not active_patterns.has(source_pattern) or not active_patterns.has(target_pattern):
        return false
    
    if pattern_energy[source_pattern] < amount:
        amount = pattern_energy[source_pattern]  # Cap at available energy
    
    if amount <= 0:
        return false
    
    # Transfer energy
    pattern_energy[source_pattern] -= amount
    pattern_energy[target_pattern] += amount
    
    # Update last interaction time
    pattern_last_update[source_pattern] = energy_flow_time
    pattern_last_update[target_pattern] = energy_flow_time
    
    # Update visualizations
    _update_pattern_appearance(source_pattern)
    _update_pattern_appearance(target_pattern)
    
    # Create energy transfer effect
    _create_energy_transfer_effect(source_pattern, target_pattern, amount)
    
    # Emit signal
    emit_signal("pattern_energy_changed", target_pattern, pattern_energy[target_pattern])
    
    return true

func _create_pattern_visualization(pattern):
    # Create particle system for pattern
    var particles = GPUParticles3D.new()
    particles.amount = 20 + pattern.length() * 2  # Scale with pattern length
    particles.lifetime = 2.0
    particles.explosiveness = 0.0
    particles.randomness = 0.2
    particles.local_coords = false
    
    # Create particle material
    var dimension = pattern_dimensions[pattern]
    var base_color = DIMENSION_COLORS.get(dimension, Color(1, 1, 1))
    
    var mat = pattern_particle_material.duplicate()
    mat.albedo_color = base_color
    mat.emission = base_color
    particles.draw_pass_1 = SphereMesh.new()
    particles.draw_pass_1.radius = 0.05
    particles.draw_pass_1.material = mat
    
    # Position
    var pos = pattern_position[pattern]
    particles.position = pos
    
    # Add to scene
    pattern_container.add_child(particles)
    pattern_particle_nodes[pattern] = particles
    
    # Add label
    var label = Label3D.new()
    label.text = pattern
    label.font = word_font
    label.pixel_size = 0.01 * (0.5 + pattern_energy[pattern] / 50.0)  # Scale with energy
    label.text_alpha = 0.8
    label.position = pos + Vector3(0, 0.2, 0)
    label.billboard = true
    label.fixed_size = true
    label.modulate = base_color
    
    pattern_container.add_child(label)
    pattern_labels[pattern] = label

func _update_pattern_appearance(pattern):
    if not active_patterns.has(pattern):
        return
    
    if not pattern_particle_nodes.has(pattern) or not pattern_labels.has(pattern):
        _create_pattern_visualization(pattern)
        return
    
    # Update particles based on energy
    var particles = pattern_particle_nodes[pattern]
    var energy = pattern_energy[pattern]
    
    # Scale particles with energy
    particles.amount = 20 + floor(energy / 5)
    
    # Update emission intensity
    var mat = particles.draw_pass_1.material
    mat.emission_energy = 0.5 + (energy / 30.0)
    
    # Update label
    var label = pattern_labels[pattern]
    label.text_alpha = min(0.8, 0.4 + (energy / 100.0))
    label.pixel_size = 0.01 * (0.5 + energy / 50.0)
    
    # Update position
    var pos = pattern_position[pattern]
    label.position = pos + Vector3(0, 0.2, 0)
    
    # Pulse effect based on energy
    var pulse = sin(energy_flow_time * 2.0 + hash(pattern) % 10) * 0.2 + 0.8
    mat.albedo_color.a = pulse

func _update_pattern_positions(delta):
    # Move patterns based on velocity and apply forces
    for pattern in active_patterns.keys():
        if not pattern_position.has(pattern) or not pattern_velocity.has(pattern):
            continue
        
        var pos = pattern_position[pattern]
        var vel = pattern_velocity[pattern]
        
        # Apply velocity with some damping
        pos += vel * delta * 0.5
        
        # Apply bounding box to keep patterns within view
        var bound = 10.0
        if pos.x < -bound: pos.x = -bound; vel.x *= -0.5
        if pos.x > bound: pos.x = bound; vel.x *= -0.5
        if pos.y < -bound: pos.y = -bound; vel.y *= -0.5
        if pos.y > bound: pos.y = bound; vel.y *= -0.5
        if pos.z < -bound: pos.z = -bound; vel.z *= -0.5
        if pos.z > bound: pos.z = bound; vel.z *= -0.5
        
        // Apply attraction to dimension center
        var dimension = pattern_dimensions[pattern]
        var dim_center = _get_dimension_center(dimension)
        var dir_to_center = (dim_center - pos).normalized()
        
        // Attraction force based on dimension affinity
        vel += dir_to_center * delta * 0.2
        
        // Apply some random motion
        var random_force = Vector3(
            (randf() * 2.0 - 1.0),
            (randf() * 2.0 - 1.0),
            (randf() * 2.0 - 1.0)
        ) * delta * 0.1
        
        vel += random_force
        
        // Apply clustering with related patterns
        for other_pattern in active_patterns.keys():
            if pattern == other_pattern:
                continue
            
            var cluster_key = pattern + "_to_" + other_pattern
            var reverse_key = other_pattern + "_to_" + pattern
            
            if pattern_resonances.has(cluster_key) or pattern_resonances.has(reverse_key):
                var other_pos = pattern_position[other_pattern]
                var dir = (other_pos - pos).normalized()
                var dist = pos.distance_to(other_pos)
                
                // Only attract if not too close
                if dist > 1.0:
                    var resonance = pattern_resonances.get(cluster_key, pattern_resonances.get(reverse_key, 0.0))
                    vel += dir * delta * resonance * 0.5
            }
        
        // Apply velocity damping
        vel *= (1.0 - delta * 0.1)
        
        // Update position and velocity
        pattern_position[pattern] = pos
        pattern_velocity[pattern] = vel
        
        // Update visual position
        if pattern_particle_nodes.has(pattern):
            pattern_particle_nodes[pattern].position = pos
        
        if pattern_labels.has(pattern):
            pattern_labels[pattern].position = pos + Vector3(0, 0.2, 0)

func _update_pattern_energies(delta):
    // Spontaneous energy changes
    for pattern in active_patterns.keys():
        if not pattern_energy.has(pattern):
            continue
        
        var energy = pattern_energy[pattern]
        
        // Energy decay over time
        energy *= (1.0 - delta * 0.05)
        
        // Energy gain based on dimension and current system turn
        if tunnel_controller:
            var turn_info = tunnel_controller.get_current_turn_info()
            
            // Different turns affect different dimension patterns
            var dimension = pattern_dimensions[pattern]
            var energy_boost = 0.0
            
            match turn_info.turn:
                0: // Origin - boosts base dimension
                    if dimension == 1:
                        energy_boost = 0.5
                
                4: // Reflection - boosts information dimension
                    if dimension == 5:
                        energy_boost = 0.8
                
                7: // Insight - boosts consciousness dimension
                    if dimension == 6:
                        energy_boost = 1.0
                
                10: // Manifestation - boosts all dimensions
                    energy_boost = 0.3
            
            energy += energy_boost * delta
        }
        
        // Min energy floor
        if energy < 0.1:
            energy = 0.0
        
        // Update energy
        pattern_energy[pattern] = energy
        
        // Remove patterns with no energy
        if energy <= 0.0:
            remove_word_pattern(pattern)
            continue
        
        // Update visual appearance based on new energy
        _update_pattern_appearance(pattern)

func _detect_pattern_resonances():
    // Check for resonances between patterns
    var new_resonances = {}
    
    for pattern1 in active_patterns.keys():
        for pattern2 in active_patterns.keys():
            if pattern1 == pattern2:
                continue
            
            // Create a consistent key for this pair
            var resonance_key = pattern1 + "_to_" + pattern2
            
            // Skip if we've already calculated this pair
            if pattern_resonances.has(resonance_key):
                new_resonances[resonance_key] = pattern_resonances[resonance_key]
                continue
            
            // Calculate resonance value
            var resonance = _calculate_pattern_resonance(pattern1, pattern2)
            
            // Store if significant
            if resonance > 0.2:
                new_resonances[resonance_key] = resonance
                
                // Emit signal for new significant resonances
                if resonance > 0.5:
                    emit_signal("pattern_resonance_detected", pattern1, pattern2, resonance)
                
                // Create visual effect for strong resonances
                if resonance > 0.7:
                    _create_resonance_effect(pattern1, pattern2, resonance)
            }
        }
    }
    
    // Update resonances
    pattern_resonances = new_resonances

func _check_manifestation_conditions():
    var patterns_to_manifest = []
    
    // Check each pattern for manifestation conditions
    for pattern in active_patterns.keys():
        var energy = pattern_energy[pattern]
        
        // Basic energy threshold
        if energy >= ENERGY_THRESHOLD_MANIFESTATION:
            patterns_to_manifest.push_back(pattern)
            continue
        
        // Check for resonance-based manifestation
        var max_resonance = 0.0
        var resonant_energy = 0.0
        
        for resonance_key in pattern_resonances.keys():
            var parts = resonance_key.split("_to_")
            if parts[0] == pattern or parts[1] == pattern:
                var resonance = pattern_resonances[resonance_key]
                
                if resonance > max_resonance:
                    max_resonance = resonance
                
                // The other pattern in the resonance
                var other_pattern = parts[0] if parts[1] == pattern else parts[1]
                
                if pattern_energy.has(other_pattern):
                    resonant_energy += pattern_energy[other_pattern] * resonance
            }
        }
        
        // Combined energy manifestation check
        if energy + resonant_energy >= ENERGY_THRESHOLD_MANIFESTATION:
            patterns_to_manifest.push_back(pattern)
        }
    }
    
    // Process manifestations
    for pattern in patterns_to_manifest:
        _manifest_word_pattern(pattern)

func _manifest_word_pattern(pattern):
    if not active_patterns.has(pattern):
        return
    
    var dimension = pattern_dimensions[pattern]
    var energy = pattern_energy[pattern]
    
    // Perform manifestation
    print("Manifesting word pattern: " + pattern + " (Dimension: " + str(dimension) + 
          ", Energy: " + str(energy) + ")")
    
    // Create manifestation effect
    _create_manifestation_effect(pattern, dimension, energy)
    
    // Emit signal
    emit_signal("word_manifestation", pattern, dimension, energy)
    
    // Remove the manifested pattern
    remove_word_pattern(pattern)
    
    // Affect nearby patterns
    var manifestation_pos = pattern_position[pattern]
    var effect_radius = 2.0 + (energy / 20.0)
    
    for other_pattern in active_patterns.keys():
        if other_pattern == pattern:
            continue
        
        var other_pos = pattern_position[other_pattern]
        var dist = manifestation_pos.distance_to(other_pos)
        
        if dist <= effect_radius:
            // Energy boost to nearby patterns
            var boost = energy * 0.2 * (1.0 - dist / effect_radius)
            pattern_energy[other_pattern] += boost
            
            // Update visuals
            _update_pattern_appearance(other_pattern)
        }
    }
    
    // Affect tunnels if connected to tunnel system
    if tunnel_controller and tunnel_visualizer:
        // Find tunnels in the same dimension
        var tunnels = ethereal_tunnel_manager.get_tunnels()
        
        for tunnel_id in tunnels:
            var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
            
            // Match dimension
            if tunnel_data.dimension == dimension:
                // Energy boost to tunnel
                var stability_boost = (energy / 100.0) * 0.1
                var new_stability = min(1.0, tunnel_data.stability + stability_boost)
                
                ethereal_tunnel_manager.set_tunnel_stability(tunnel_id, new_stability)
                
                // Visual effect
                if tunnel_visualizer.has_method("add_color_flash"):
                    var flash_color = DIMENSION_COLORS.get(dimension, Color(1, 1, 1))
                    tunnel_visualizer.add_color_flash(tunnel_id, flash_color)
            }
        }
    }

func _create_manifestation_effect(pattern, dimension, energy):
    // Create a visual effect for word manifestation
    var effect_node = Node3D.new()
    effect_node.name = "Manifestation_" + pattern
    
    // Position at pattern location
    var pos = pattern_position[pattern]
    effect_node.position = pos
    
    // Create word text
    var word_text = Label3D.new()
    word_text.text = pattern
    word_text.font = word_font
    word_text.pixel_size = 0.02 + (energy / 200.0)
    word_text.billboard = true
    word_text.modulate = DIMENSION_COLORS.get(dimension, Color(1, 1, 1))
    effect_node.add_child(word_text)
    
    // Create particle effect
    var particles = GPUParticles3D.new()
    particles.amount = 100 + energy
    particles.lifetime = 3.0
    particles.explosiveness = 0.8
    particles.one_shot = true
    
    // Configure particle material
    var mat = manifestation_material.duplicate()
    mat.albedo_color = DIMENSION_COLORS.get(dimension, Color(1, 1, 1))
    mat.emission = mat.albedo_color
    particles.draw_pass_1 = SphereMesh.new()
    particles.draw_pass_1.radius = 0.05
    particles.draw_pass_1.material = mat
    
    effect_node.add_child(particles)
    
    // Create expanding sphere
    var sphere = CSGSphere3D.new()
    sphere.radius = 0.1
    sphere.material = mat.duplicate()
    effect_node.add_child(sphere)
    
    // Add light
    var light = OmniLight3D.new()
    light.light_color = DIMENSION_COLORS.get(dimension, Color(1, 1, 1))
    light.light_energy = 2.0 + (energy / 50.0)
    effect_node.add_child(light)
    
    // Add to scene
    word_manifestation_container.add_child(effect_node)
    
    // Create animation for the effect
    var tween = create_tween()
    tween.set_parallel(true)
    
    // Expand sphere
    tween.tween_property(sphere, "radius", 3.0 + (energy / 20.0), 2.0)
    tween.tween_property(sphere.material, "albedo_color:a", 0.0, 2.0)
    
    // Fade out light
    tween.tween_property(light, "light_energy", 0.0, 3.0)
    
    // Float word upward
    tween.tween_property(word_text, "position:y", 3.0, 3.0)
    
    // Remove after animation completes
    await tween.finished
    effect_node.queue_free()
    
    // Play audio
    if audio_player:
        // Would load an actual sound in a real implementation
        // audio_player.stream = manifestation_sound
        audio_player.position = pos
        audio_player.play()

func _create_energy_transfer_effect(source_pattern, target_pattern, amount):
    // Create a visual energy transfer effect between patterns
    var source_pos = pattern_position[source_pattern]
    var target_pos = pattern_position[target_pattern]
    
    // Create a line between the patterns
    var energy_beam = CSGCylinder3D.new()
    energy_beam.radius = 0.03 + (amount / 100.0)
    
    // Calculate position and height
    var mid_point = (source_pos + target_pos) / 2.0
    var distance = source_pos.distance_to(target_pos)
    energy_beam.height = distance
    
    // Orient the cylinder
    energy_beam.look_at_from_position(mid_point, target_pos, Vector3.UP)
    energy_beam.rotate_x(PI/2)  // Adjust orientation
    
    // Set material
    var source_dim = pattern_dimensions[source_pattern]
    var target_dim = pattern_dimensions[target_pattern]
    
    var source_color = DIMENSION_COLORS.get(source_dim, Color(1, 1, 1))
    var target_color = DIMENSION_COLORS.get(target_dim, Color(1, 1, 1))
    
    var mat = StandardMaterial3D.new()
    mat.flags_transparent = true
    mat.emission_enabled = true
    
    // Gradient between source and target colors
    mat.albedo_color = source_color.lerp(target_color, 0.5)
    mat.emission = mat.albedo_color
    mat.emission_energy = 1.0 + (amount / 50.0)
    
    energy_beam.material = mat
    
    // Add to scene
    pattern_container.add_child(energy_beam)
    
    // Animate and remove
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(mat, "albedo_color:a", 0.0, 0.5)
    tween.tween_property(mat, "emission_energy", 0.0, 0.5)
    
    await tween.finished
    energy_beam.queue_free()

func _create_resonance_effect(pattern1, pattern2, resonance):
    var pos1 = pattern_position[pattern1]
    var pos2 = pattern_position[pattern2]
    
    // Create resonance line
    var resonance_line = CSGCylinder3D.new()
    resonance_line.radius = 0.02 * resonance
    
    // Calculate position and height
    var mid_point = (pos1 + pos2) / 2.0
    var distance = pos1.distance_to(pos2)
    resonance_line.height = distance
    
    // Orient the cylinder
    resonance_line.look_at_from_position(mid_point, pos2, Vector3.UP)
    resonance_line.rotate_x(PI/2)  // Adjust orientation
    
    // Set material
    var dim1 = pattern_dimensions[pattern1]
    var dim2 = pattern_dimensions[pattern2]
    
    var color1 = DIMENSION_COLORS.get(dim1, Color(1, 1, 1))
    var color2 = DIMENSION_COLORS.get(dim2, Color(1, 1, 1))
    
    var mat = StandardMaterial3D.new()
    mat.flags_transparent = true
    mat.emission_enabled = true
    
    // Gradient between colors
    mat.albedo_color = color1.lerp(color2, 0.5)
    mat.albedo_color.a = resonance * 0.5
    mat.emission = mat.albedo_color
    mat.emission_energy = 0.5 + resonance
    
    resonance_line.material = mat
    
    // Add to scene
    pattern_container.add_child(resonance_line)
    
    // Pulsate effect
    var tween = create_tween()
    tween.set_loops(3)
    tween.set_parallel(true)
    
    tween.tween_property(mat, "albedo_color:a", resonance, 0.5)
    tween.tween_property(mat, "emission_energy", 0.5 + (resonance * 2.0), 0.5)
    
    tween.chain().tween_property(mat, "albedo_color:a", resonance * 0.3, 0.5)
    tween.tween_property(mat, "emission_energy", 0.5 + resonance, 0.5)
    
    await tween.finished
    resonance_line.queue_free()

func _cleanup_old_patterns():
    var patterns_to_remove = []
    
    // Find old patterns with low energy
    for pattern in active_patterns.keys():
        var time_since_update = energy_flow_time - pattern_last_update[pattern]
        var energy = pattern_energy[pattern]
        
        // Patterns that haven't been updated in a while and have low energy
        if time_since_update > 10.0 and energy < 5.0:
            patterns_to_remove.push_back(pattern)
        }
    }
    
    // Remove old patterns
    for pattern in patterns_to_remove:
        remove_word_pattern(pattern)

func _analyze_pattern_dimension(pattern):
    // Determine which dimension this pattern belongs to based on semantics
    var best_dimension = 3  // Default to space dimension
    var best_score = 0
    
    // Simple keyword matching
    for dimension in DIMENSION_WORD_AFFINITIES:
        var affinity_words = DIMENSION_WORD_AFFINITIES[dimension]
        var score = 0
        
        for word in affinity_words:
            if pattern.find(word) >= 0:
                score += 2
            
            // Partial matches
            for segment in pattern.split(" "):
                if segment.length() >= 3 and word.find(segment) >= 0:
                    score += 1
            }
        }
        
        if score > best_score:
            best_score = score
            best_dimension = dimension
        }
    }
    
    // If no clear match, use character analysis as fallback
    if best_score == 0:
        // Use character frequencies to guess dimension
        var chars = _analyze_pattern_characters(pattern)
        
        // Rough heuristics based on character composition
        var numbers = chars.get("numbers", 0)
        var spaces = chars.get("spaces", 0)
        var symbols = chars.get("symbols", 0)
        var vowels = chars.get("vowels", 0)
        var consonants = chars.get("consonants", 0)
        
        if numbers > pattern.length() * 0.3:
            best_dimension = 1  // Base/physical for numeric heavy
        elif symbols > pattern.length() * 0.2:
            best_dimension = 5  // Information for symbol heavy
        elif vowels > consonants * 2:
            best_dimension = 7  // Connection for vowel heavy
        elif consonants > vowels * 2:
            best_dimension = 8  // Potential for consonant heavy
        }
    }
    
    return best_dimension

func _analyze_pattern_characters(pattern):
    var chars = {
        "vowels": 0,
        "consonants": 0,
        "numbers": 0,
        "spaces": 0,
        "symbols": 0
    }
    
    var vowels = "aeiou"
    var consonants = "bcdfghjklmnpqrstvwxyz"
    var numbers = "0123456789"
    
    for i in range(pattern.length()):
        var c = pattern[i].to_lower()
        
        if vowels.find(c) >= 0:
            chars.vowels += 1
        elif consonants.find(c) >= 0:
            chars.consonants += 1
        elif numbers.find(c) >= 0:
            chars.numbers += 1
        elif c == " ":
            chars.spaces += 1
        else:
            chars.symbols += 1
        }
    }
    
    return chars

func _calculate_pattern_resonance(pattern1, pattern2):
    // Calculate how strongly two patterns resonate with each other
    
    // Check dimensions first
    var dim1 = pattern_dimensions[pattern1]
    var dim2 = pattern_dimensions[pattern2]
    
    // Dimensional resonance factor - closer dimensions resonate more
    var dim_factor = 1.0 - (abs(dim1 - dim2) / 9.0)
    
    // Character comparison
    var chars1 = pattern_characters[pattern1]
    var chars2 = pattern_characters[pattern2]
    
    var char_similarity = 0.0
    var total_chars = 0
    
    for char_type in chars1.keys():
        var diff = abs(chars1[char_type] - chars2[char_type])
        var max_val = max(chars1[char_type], chars2[char_type])
        
        if max_val > 0:
            char_similarity += 1.0 - (diff / float(max_val))
            total_chars += 1
        }
    }
    
    if total_chars > 0:
        char_similarity /= total_chars
    }
    
    // Word overlap
    var words1 = pattern1.split(" ")
    var words2 = pattern2.split(" ")
    
    var word_overlap = 0
    
    for word in words1:
        if word.length() >= 3 and words2.has(word):
            word_overlap += 1
        }
    }
    
    var word_factor = 0.0
    if words1.size() > 0 and words2.size() > 0:
        word_factor = float(word_overlap) / min(words1.size(), words2.size())
    }
    
    // Length similarity
    var length_ratio = min(pattern1.length(), pattern2.length()) / max(pattern1.length(), pattern2.length())
    
    // Combined resonance value
    var resonance = (
        dim_factor * 0.4 +
        char_similarity * 0.3 +
        word_factor * 0.2 +
        length_ratio * 0.1
    ) * numeric_resonance_factor
    
    return resonance

func _generate_pattern_position(pattern, dimension):
    // Generate a position for a new pattern based on its dimension
    var base_pos = _get_dimension_center(dimension)
    
    // Add some random offset
    var offset = Vector3(
        randf_range(-3.0, 3.0),
        randf_range(-3.0, 3.0),
        randf_range(-3.0, 3.0)
    )
    
    return base_pos + offset

func _get_dimension_center(dimension):
    // Return the center position for a given dimension
    var angle = (dimension - 1) * (2 * PI / 9)
    var radius = 5.0
    
    var x = cos(angle) * radius
    var z = sin(angle) * radius
    
    return Vector3(x, 0, z)

func _generate_pattern_velocity(pattern):
    // Generate initial velocity for a pattern
    return Vector3(
        randf_range(-0.5, 0.5),
        randf_range(-0.3, 0.3),
        randf_range(-0.5, 0.5)
    )

func _assign_pattern_to_cluster(pattern):
    // Find the best cluster for this pattern based on resonance
    var best_resonance = 0.0
    var best_pattern = ""
    
    for other_pattern in active_patterns.keys():
        if other_pattern == pattern:
            continue
        
        var resonance = _calculate_pattern_resonance(pattern, other_pattern)
        
        if resonance > best_resonance:
            best_resonance = resonance
            best_pattern = other_pattern
        }
    }
    
    // If good resonance found, store it
    if best_resonance > 0.5 and best_pattern != "":
        var resonance_key = pattern + "_to_" + best_pattern
        pattern_resonances[resonance_key] = best_resonance
        
        // Attract the patterns together
        var dir = (pattern_position[best_pattern] - pattern_position[pattern]).normalized()
        pattern_velocity[pattern] += dir * 0.5
    }

func _extract_numeric_values(pattern):
    // Extract numbers from the pattern for the numeric token system
    var number_pattern = RegEx.new()
    number_pattern.compile("\\d+")
    
    var matches = number_pattern.search_all(pattern)
    
    for match_obj in matches:
        var num = int(match_obj.get_string())
        numeric_value_total += num
        numeric_pattern_count += 1
    }
    
    // Update resonance factor based on numeric patterns
    if numeric_pattern_count > 0:
        numeric_resonance_factor = 1.0 + (numeric_value_total / (numeric_pattern_count * 100.0))
        numeric_resonance_factor = clamp(numeric_resonance_factor, 1.0, 3.0)
    }

func _initialize_seed_patterns():
    // Add some initial patterns to get started
    add_word_pattern("space", 15.0, 3)
    add_word_pattern("time", 15.0, 2)
    add_word_pattern("energy", 15.0, 4)
    add_word_pattern("pattern", 10.0, 5)
    add_word_pattern("connection", 10.0, 7)

func get_pattern_energy(pattern):
    return pattern_energy.get(pattern, 0.0)

func get_active_patterns():
    return active_patterns.keys()

func get_patterns_in_dimension(dimension):
    var result = []
    
    for pattern in active_patterns.keys():
        if pattern_dimensions[pattern] == dimension:
            result.push_back(pattern)
        }
    }
    
    return result

func get_highest_energy_patterns(count = 5):
    var patterns = active_patterns.keys()
    patterns.sort_custom(self, "_sort_by_energy")
    
    return patterns.slice(0, min(count, patterns.size()) - 1)

func _sort_by_energy(a, b):
    return pattern_energy[a] > pattern_energy[b]

func clear_all_patterns():
    var patterns_to_remove = active_patterns.keys()
    
    for pattern in patterns_to_remove:
        remove_word_pattern(pattern)
    
    // Reset numeric values
    numeric_value_total = 0
    numeric_pattern_count = 0
    numeric_resonance_factor = 1.0
    
    // Reset timers
    energy_flow_time = 0.0
    last_resonance_check = 0.0
    last_pattern_cleanup = 0.0
    animation_accumulator = 0.0