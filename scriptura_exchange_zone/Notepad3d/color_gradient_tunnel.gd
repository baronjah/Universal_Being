extends TunnelVisualizer

class_name ColorGradientTunnelVisualizer

# Enhanced visualization with dynamic gradients and color blending
const GRADIENT_RESOLUTION = 16
const PULSE_SPEED = 1.5
const COLOR_BLEND_SPEED = 0.8
const ANIMATION_SPEEDS = [0.5, 0.8, 1.0, 1.2, 1.5]

# Color gradient system
var tunnel_gradients = {}
var transition_gradients = {}
var current_color_blend = 0.0
var color_blend_direction = 1.0

# Enhanced color dimensions with additional harmony
var extended_colors = {
    1: [Color(1.0, 0.3, 0.3), Color(0.8, 0.2, 0.2), Color(1.0, 0.4, 0.4)],  # Red variations
    2: [Color(0.3, 1.0, 0.3), Color(0.2, 0.8, 0.2), Color(0.4, 1.0, 0.4)],  # Green variations
    3: [Color(0.3, 0.3, 1.0), Color(0.2, 0.2, 0.8), Color(0.4, 0.4, 1.0)],  # Blue variations
    4: [Color(1.0, 1.0, 0.3), Color(0.8, 0.8, 0.2), Color(1.0, 1.0, 0.4)],  # Yellow variations
    5: [Color(1.0, 0.3, 1.0), Color(0.8, 0.2, 0.8), Color(1.0, 0.4, 1.0)],  # Magenta variations
    6: [Color(0.3, 1.0, 1.0), Color(0.2, 0.8, 0.8), Color(0.4, 1.0, 1.0)],  # Cyan variations
    7: [Color(1.0, 0.6, 0.0), Color(0.8, 0.5, 0.0), Color(1.0, 0.7, 0.2)],  # Orange variations
    8: [Color(0.6, 0.0, 1.0), Color(0.5, 0.0, 0.8), Color(0.7, 0.2, 1.0)],  # Purple variations
    9: [Color(0.0, 0.6, 0.3), Color(0.0, 0.5, 0.25), Color(0.2, 0.7, 0.4)]  # Teal variations
}

# Animation and effects tracking
var animation_time = 0.0
var active_animations = {}
var color_transitions = {}

# Visual style configuration
var style_config = {
    "tunnel_opacity": 0.8,
    "tunnel_glow_intensity": 1.2,
    "particle_size": 0.05,
    "particle_trail_length": 0.8,
    "tunnel_line_width": 2.0,
    "use_bloom_effect": true,
    "use_dynamic_lighting": true,
    "animation_quality": 2  # 0-4 range, higher = better quality but more performance intensive
}

func _ready():
    # Call parent _ready
    super._ready()
    
    # Initialize gradient system
    _setup_gradient_system()
    
    # Set up environment effects if possible
    _setup_environment_effects()

func _setup_gradient_system():
    # Create default gradients for each dimension
    for dimension in range(1, 10):
        var color_set = extended_colors[dimension]
        
        # Create primary gradient
        var gradient = Gradient.new()
        gradient.add_point(0.0, color_set[0])
        gradient.add_point(0.3, color_set[1])
        gradient.add_point(0.7, color_set[0])
        gradient.add_point(1.0, color_set[2])
        
        tunnel_gradients[dimension] = gradient
        
        # Create transition gradients for moving between dimensions
        for target_dim in range(1, 10):
            if dimension != target_dim:
                var transition_id = str(dimension) + "_to_" + str(target_dim)
                var trans_gradient = Gradient.new()
                
                var source_colors = extended_colors[dimension]
                var target_colors = extended_colors[target_dim]
                
                trans_gradient.add_point(0.0, source_colors[0])
                trans_gradient.add_point(0.3, source_colors[1])
                trans_gradient.add_point(0.6, target_colors[1])
                trans_gradient.add_point(1.0, target_colors[0])
                
                transition_gradients[transition_id] = trans_gradient
    
    # Set initial color blend
    current_color_blend = 0.0

func _setup_environment_effects():
    # Get the world environment if it exists
    var world_env = get_viewport().get_camera_3d().get_parent().get_node_or_null("WorldEnvironment")
    
    if world_env and style_config.use_bloom_effect:
        # Enable glow
        world_env.environment.glow_enabled = true
        world_env.environment.glow_intensity = 0.7
        world_env.environment.glow_bloom = 0.2
        world_env.environment.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
    
    # Add a global light for dynamic lighting if needed
    if style_config.use_dynamic_lighting:
        var omni_light = OmniLight3D.new()
        omni_light.name = "TunnelSystemLight"
        omni_light.light_energy = 0.5
        omni_light.omni_range = 10.0
        omni_light.light_color = Color(0.5, 0.5, 0.8)
        add_child(omni_light)

func _process(delta):
    # Update base class
    super._process(delta)
    
    # Update animation time
    animation_time += delta
    
    # Update color blending
    current_color_blend += color_blend_direction * COLOR_BLEND_SPEED * delta
    if current_color_blend >= 1.0:
        current_color_blend = 1.0
        color_blend_direction = -1.0
    elif current_color_blend <= 0.0:
        current_color_blend = 0.0
        color_blend_direction = 1.0
    
    # Update tunnel gradients
    _update_tunnel_gradients(delta)
    
    # Update active animations
    _update_animations(delta)
    
    # Update color transitions
    _update_color_transitions(delta)

func _update_tunnel_gradients(delta):
    # Update materials for tunnels based on current gradients
    for tunnel_id in active_tunnels:
        var tunnel = active_tunnels[tunnel_id]
        var tunnel_data = tunnel.data
        
        if not tunnel.mesh:
            continue
        
        # Get current dimension's gradient
        var gradient = tunnel_gradients[tunnel_data.dimension]
        
        # Check for active color transition
        if color_transitions.has(tunnel_id):
            var transition = color_transitions[tunnel_id]
            var transition_gradient = transition_gradients.get(
                str(transition.source_dim) + "_to_" + str(transition.target_dim),
                gradient
            )
            
            # Update transition progress
            transition.progress += delta / transition.duration
            
            if transition.progress >= 1.0:
                # Transition complete
                color_transitions.erase(tunnel_id)
                
                # Update material using final gradient
                _apply_gradient_to_tunnel(tunnel.mesh, gradient, tunnel_data.stability)
            else:
                # Use transition gradient with current progress
                _apply_gradient_to_tunnel(tunnel.mesh, transition_gradient, tunnel_data.stability, transition.progress)
        else:
            # Regular update using dimension's gradient
            _apply_gradient_to_tunnel(tunnel.mesh, gradient, tunnel_data.stability)

func _apply_gradient_to_tunnel(tunnel_mesh, gradient, stability, offset = null):
    # Get base material
    var material = tunnel_mesh.material
    
    if not material:
        return
    
    # Calculate gradient offset if not specified
    if offset == null:
        offset = fmod(animation_time * PULSE_SPEED, 1.0)
    
    # Adjust color based on gradient and current animation time
    var gradient_pos = fmod(offset, 1.0)  
    var main_color = gradient.sample(gradient_pos)
    
    # Apply stability factor to opacity
    var opacity = style_config.tunnel_opacity * (0.4 + stability * 0.6)
    main_color.a = opacity
    
    # Apply to material
    material.albedo_color = main_color
    material.emission = main_color
    material.emission_energy = style_config.tunnel_glow_intensity * (0.5 + stability * 0.5)

func _update_animations(delta):
    # Process active animations
    var completed_animations = []
    
    for anim_id in active_animations:
        var animation = active_animations[anim_id]
        
        # Update progress
        animation.time += delta
        
        if animation.time >= animation.duration:
            # Animation complete
            completed_animations.push_back(anim_id)
            
            # Apply completion callback if any
            if animation.has("on_complete"):
                animation.on_complete.call_func()
        else:
            # Apply animation frame
            var progress = animation.time / animation.duration
            
            match animation.type:
                "pulse":
                    _apply_pulse_animation(animation.target, progress)
                "ripple":
                    _apply_ripple_animation(animation.target, progress)
                "color_flash":
                    _apply_color_flash_animation(animation.target, progress, animation.color)
    
    # Clean up completed animations
    for anim_id in completed_animations:
        active_animations.erase(anim_id)

func _update_color_transitions(delta):
    # Nothing additional needed here, transitions are handled in _update_tunnel_gradients
    pass

func _create_tunnel_visualization(tunnel_id):
    # Call parent method to create base tunnel
    super._create_tunnel_visualization(tunnel_id)
    
    var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
    if not tunnel_data:
        return
    
    # Apply initial gradient
    var tunnel = active_tunnels[tunnel_id]
    if tunnel and tunnel.mesh:
        var gradient = tunnel_gradients[tunnel_data.dimension]
        _apply_gradient_to_tunnel(tunnel.mesh, gradient, tunnel_data.stability)
    
    # Create establishment animation
    _add_tunnel_establish_animation(tunnel_id)

func _add_tunnel_establish_animation(tunnel_id):
    var anim_id = "establish_" + tunnel_id
    
    active_animations[anim_id] = {
        "type": "ripple",
        "target": tunnel_id,
        "time": 0.0,
        "duration": 1.5,
        "on_complete": func():
            # When establishment animation completes, add a pulse animation
            _add_tunnel_pulse_animation(tunnel_id)
    }

func _add_tunnel_pulse_animation(tunnel_id):
    var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
    if not tunnel_data:
        return
    
    # Pulse animation speed depends on dimension and stability
    var pulse_duration = 2.0 + (tunnel_data.dimension - 1) * 0.5
    pulse_duration /= (0.5 + tunnel_data.stability * 0.5)
    
    var anim_id = "pulse_" + tunnel_id
    
    active_animations[anim_id] = {
        "type": "pulse",
        "target": tunnel_id,
        "time": 0.0,
        "duration": pulse_duration,
        "on_complete": func():
            # Repeat pulse with slight variation
            var variation = (randf() - 0.5) * 0.4  # -0.2 to +0.2
            _add_tunnel_pulse_animation(tunnel_id)
    }

func _apply_pulse_animation(tunnel_id, progress):
    if not active_tunnels.has(tunnel_id):
        return
    
    var tunnel = active_tunnels[tunnel_id]
    if not tunnel or not tunnel.mesh:
        return
    
    var tunnel_data = tunnel.data
    var material = tunnel.mesh.material
    
    if not material:
        return
    
    # Calculate pulse effect (sine wave)
    var pulse_factor = (sin(progress * PI * 2) + 1) * 0.5  # 0 to 1
    
    # Get base color from dimension
    var base_color = COLOR_DIMENSIONS.get(tunnel_data.dimension, Color(1, 1, 1))
    
    # Apply pulse to emission energy
    var energy_base = style_config.tunnel_glow_intensity * (0.5 + tunnel_data.stability * 0.5)
    var energy_pulse = energy_base * (0.8 + pulse_factor * 0.4)
    
    material.emission_energy = energy_pulse
    
    # Apply subtle size pulsing to particles if they exist
    if tunnel.has("particles") and tunnel.particles:
        var base_size = style_config.particle_size
        var pulse_size = base_size * (0.9 + pulse_factor * 0.2)
        
        var particle_material = tunnel.particles.process_material
        if particle_material:
            particle_material.scale_min = pulse_size * 0.8
            particle_material.scale_max = pulse_size * 1.2

func _apply_ripple_animation(tunnel_id, progress):
    if not active_tunnels.has(tunnel_id):
        return
    
    var tunnel = active_tunnels[tunnel_id]
    if not tunnel or not tunnel.path:
        return
    
    # Ripple along the tunnel path
    var curve = tunnel.path.curve
    var point_count = curve.get_point_count()
    
    # We need to create a temporary mesh for the ripple effect
    if not tunnel.has("ripple_mesh"):
        var ripple = CSGSphere3D.new()
        ripple.radius = 0.1
        ripple.operation = CSGShape3D.OPERATION_UNION
        
        var ripple_material = StandardMaterial3D.new()
        ripple_material.emission_enabled = true
        ripple_material.flags_transparent = true
        
        ripple.material = ripple_material
        tunnel.path.add_child(ripple)
        tunnel.ripple_mesh = ripple
    
    # Move ripple along the path
    var pos = progress
    var point_pos = curve.sample_baked(pos * curve.get_baked_length())
    
    tunnel.ripple_mesh.position = point_pos
    
    # Scale and color based on progress
    var scale_factor = sin(progress * PI) * 0.3 + 0.1
    tunnel.ripple_mesh.scale = Vector3(scale_factor, scale_factor, scale_factor)
    
    var ripple_material = tunnel.ripple_mesh.material
    var base_color = COLOR_DIMENSIONS.get(tunnel.data.dimension, Color(1, 1, 1))
    base_color.a = (1.0 - progress) * 0.8
    
    ripple_material.albedo_color = base_color
    ripple_material.emission = base_color
    ripple_material.emission_energy = 2.0

func _apply_color_flash_animation(tunnel_id, progress, flash_color):
    if not active_tunnels.has(tunnel_id):
        return
    
    var tunnel = active_tunnels[tunnel_id]
    if not tunnel or not tunnel.mesh:
        return
    
    var material = tunnel.mesh.material
    
    if not material:
        return
    
    # Calculate flash intensity (peak in the middle)
    var flash_intensity = 0.0
    if progress < 0.5:
        flash_intensity = progress * 2.0  # 0 to 1
    else:
        flash_intensity = (1.0 - progress) * 2.0  # 1 to 0
    
    # Blend between base color and flash color
    var base_color = COLOR_DIMENSIONS.get(tunnel.data.dimension, Color(1, 1, 1))
    var blend_color = base_color.lerp(flash_color, flash_intensity)
    
    material.emission = blend_color
    material.emission_energy = 1.0 + flash_intensity * 2.0

func start_color_transition(tunnel_id, target_dimension, duration = 1.0):
    if not active_tunnels.has(tunnel_id):
        return false
    
    var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
    if not tunnel_data:
        return false
    
    // Add to transitions
    color_transitions[tunnel_id] = {
        "source_dim": tunnel_data.dimension,
        "target_dim": target_dimension,
        "progress": 0.0,
        "duration": duration
    }
    
    return true

func add_color_flash(tunnel_id, color = null, duration = 0.5):
    if not active_tunnels.has(tunnel_id):
        return false
    
    // Use provided color or generate one
    var flash_color = color
    if not flash_color:
        flash_color = Color(1.0, 1.0, 1.0)
    
    var anim_id = "flash_" + tunnel_id + "_" + str(OS.get_ticks_msec())
    
    active_animations[anim_id] = {
        "type": "color_flash",
        "target": tunnel_id,
        "time": 0.0,
        "duration": duration,
        "color": flash_color
    }
    
    return true

func set_animation_quality(quality_level):
    # Quality level 0-4, 4 being highest
    quality_level = clamp(quality_level, 0, 4)
    style_config.animation_quality = quality_level
    
    // Adjust visual parameters based on quality
    match quality_level:
        0:  // Lowest quality
            style_config.tunnel_opacity = 0.7
            style_config.tunnel_glow_intensity = 0.8
            style_config.particle_size = 0.1
            style_config.particle_trail_length = 0.3
            style_config.use_bloom_effect = false
            style_config.use_dynamic_lighting = false
        1:  // Low quality
            style_config.tunnel_opacity = 0.75
            style_config.tunnel_glow_intensity = 1.0
            style_config.particle_size = 0.08
            style_config.particle_trail_length = 0.5
            style_config.use_bloom_effect = false
            style_config.use_dynamic_lighting = false
        2:  // Medium quality (default)
            style_config.tunnel_opacity = 0.8
            style_config.tunnel_glow_intensity = 1.2
            style_config.particle_size = 0.05
            style_config.particle_trail_length = 0.7
            style_config.use_bloom_effect = true
            style_config.use_dynamic_lighting = false
        3:  // High quality
            style_config.tunnel_opacity = 0.85
            style_config.tunnel_glow_intensity = 1.5
            style_config.particle_size = 0.04
            style_config.particle_trail_length = 0.9
            style_config.use_bloom_effect = true
            style_config.use_dynamic_lighting = true
        4:  // Ultra quality
            style_config.tunnel_opacity = 0.9
            style_config.tunnel_glow_intensity = 1.8
            style_config.particle_size = 0.03
            style_config.particle_trail_length = 1.2
            style_config.use_bloom_effect = true
            style_config.use_dynamic_lighting = true
    
    // Apply changes to existing tunnels
    _apply_quality_settings()

func _apply_quality_settings():
    // Apply settings to environment
    _setup_environment_effects()
    
    // Apply to all tunnels
    for tunnel_id in active_tunnels:
        var tunnel = active_tunnels[tunnel_id]
        
        if tunnel.mesh and tunnel.mesh.material:
            var material = tunnel.mesh.material
            material.flags_transparent = true
            material.emission_enabled = true
            material.emission_energy = style_config.tunnel_glow_intensity
            
            // Adjust based on stability
            var opacity = style_config.tunnel_opacity * (0.4 + tunnel.data.stability * 0.6)
            var current_color = material.albedo_color
            current_color.a = opacity
            material.albedo_color = current_color
        
        // Adjust particles
        if tunnel.has("particles") and tunnel.particles:
            var particle_material = tunnel.particles.process_material
            if particle_material:
                particle_material.scale_min = style_config.particle_size * 0.8
                particle_material.scale_max = style_config.particle_size * 1.2

func _on_stability_changed(tunnel_id, new_stability):
    // Call parent implementation
    super._on_stability_changed(tunnel_id, new_stability)
    
    // Add visual effect for stability change
    if new_stability < 0.5:
        // Unstable tunnel gets a red flash
        add_color_flash(tunnel_id, Color(1.0, 0.3, 0.3, 0.7))
    elif new_stability > 0.8:
        // Very stable tunnel gets a green flash
        add_color_flash(tunnel_id, Color(0.3, 1.0, 0.3, 0.7))

func get_gradient_for_dimension(dimension):
    return tunnel_gradients.get(dimension, tunnel_gradients[3])  // Default to dimension 3 if not found

func create_custom_gradient(colors, positions = null):
    var gradient = Gradient.new()
    
    if positions and positions.size() == colors.size():
        for i in range(colors.size()):
            gradient.add_point(positions[i], colors[i])
    else:
        // Distribute evenly if no positions provided
        for i in range(colors.size()):
            var pos = float(i) / (colors.size() - 1) if colors.size() > 1 else 0.0
            gradient.add_point(pos, colors[i])
    
    return gradient