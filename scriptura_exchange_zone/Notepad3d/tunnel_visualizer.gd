extends Node3D

class_name TunnelVisualizer

# Configuration
const DEFAULT_TUNNEL_WIDTH = 0.2
const DEFAULT_ANCHOR_SIZE = 0.5
const DEFAULT_GLOW_INTENSITY = 0.8
const MAX_LOD_DISTANCE = 100.0
const COLOR_DIMENSIONS = {
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
var ethereal_tunnel_manager
var active_tunnels = {}
var anchor_nodes = {}
var tunnel_meshes = {}
var word_particles = {}

# Visual elements
var tunnel_material
var anchor_material
var word_particle_material
var stability_shader

signal tunnel_selected(tunnel_id)
signal anchor_selected(anchor_id)

func _ready():
    _setup_materials()
    _connect_signals()
    
    # Auto-detect tunnel manager if in the scene tree
    if not ethereal_tunnel_manager:
        # Try to find it automatically in the scene tree
        var potential_managers = get_tree().get_nodes_in_group("tunnel_managers")
        if potential_managers.size() > 0:
            ethereal_tunnel_manager = potential_managers[0]
            print("Automatically found tunnel manager: " + ethereal_tunnel_manager.name)

func set_tunnel_manager(manager):
    ethereal_tunnel_manager = manager
    _connect_signals()
    refresh_visualization()

func _setup_materials():
    # Base tunnel material with glow
    tunnel_material = StandardMaterial3D.new()
    tunnel_material.emission_enabled = true
    tunnel_material.emission_energy = 1.0
    tunnel_material.flags_transparent = true
    
    # Anchor material
    anchor_material = StandardMaterial3D.new()
    anchor_material.albedo_color = Color(1.0, 1.0, 1.0)
    anchor_material.metallic = 0.8
    anchor_material.roughness = 0.2
    
    # Word particle material
    word_particle_material = StandardMaterial3D.new()
    word_particle_material.flags_transparent = true
    word_particle_material.emission_enabled = true
    word_particle_material.emission_energy = 1.5
    
    # Stability shader for tunnels
    stability_shader = ShaderMaterial.new()
    # Would define shader here, using visual turbulence to represent stability

func _connect_signals():
    if not ethereal_tunnel_manager:
        return
        
    if not ethereal_tunnel_manager.is_connected("tunnel_established", self, "_on_tunnel_established"):
        ethereal_tunnel_manager.connect("tunnel_established", self, "_on_tunnel_established")
    
    if not ethereal_tunnel_manager.is_connected("tunnel_collapsed", self, "_on_tunnel_collapsed"):
        ethereal_tunnel_manager.connect("tunnel_collapsed", self, "_on_tunnel_collapsed")
    
    if not ethereal_tunnel_manager.is_connected("anchor_created", self, "_on_anchor_created"):
        ethereal_tunnel_manager.connect("anchor_created", self, "_on_anchor_created")
    
    if not ethereal_tunnel_manager.is_connected("anchor_removed", self, "_on_anchor_removed"):
        ethereal_tunnel_manager.connect("anchor_removed", self, "_on_anchor_removed")
    
    if not ethereal_tunnel_manager.is_connected("stability_changed", self, "_on_stability_changed"):
        ethereal_tunnel_manager.connect("stability_changed", self, "_on_stability_changed")

func refresh_visualization():
    # Clear existing visualization
    for node in get_children():
        remove_child(node)
        node.queue_free()
    
    active_tunnels.clear()
    anchor_nodes.clear()
    tunnel_meshes.clear()
    
    if not ethereal_tunnel_manager:
        print("No tunnel manager assigned!")
        return
    
    # Create anchors
    for anchor_id in ethereal_tunnel_manager.get_anchors():
        _create_anchor_visualization(anchor_id)
    
    # Create tunnels
    for tunnel_id in ethereal_tunnel_manager.get_tunnels():
        _create_tunnel_visualization(tunnel_id)

func _create_anchor_visualization(anchor_id):
    var anchor_data = ethereal_tunnel_manager.get_anchor_data(anchor_id)
    if not anchor_data:
        return
    
    var anchor_node = CSGSphere3D.new()
    anchor_node.radius = DEFAULT_ANCHOR_SIZE
    anchor_node.material = anchor_material.duplicate()
    
    # Position based on dimensional coordinates
    anchor_node.position = Vector3(
        anchor_data.coordinates.x,
        anchor_data.coordinates.y,
        anchor_data.coordinates.z
    )
    
    # Add label
    var label = Label3D.new()
    label.text = anchor_id
    label.pixel_size = 0.01
    label.position.y = DEFAULT_ANCHOR_SIZE + 0.2
    anchor_node.add_child(label)
    
    # Make interactive
    anchor_node.input_ray_pickable = true
    
    # Add to scene
    add_child(anchor_node)
    anchor_nodes[anchor_id] = anchor_node

func _create_tunnel_visualization(tunnel_id):
    var tunnel_data = ethereal_tunnel_manager.get_tunnel_data(tunnel_id)
    if not tunnel_data:
        return
    
    var source_anchor = ethereal_tunnel_manager.get_anchor_data(tunnel_data.source)
    var target_anchor = ethereal_tunnel_manager.get_anchor_data(tunnel_data.target)
    
    if not source_anchor or not target_anchor:
        return
    
    # Create tunnel path
    var curve = Curve3D.new()
    
    # Start point
    var start_pos = Vector3(
        source_anchor.coordinates.x,
        source_anchor.coordinates.y,
        source_anchor.coordinates.z
    )
    curve.add_point(start_pos)
    
    # Add waypoints if available
    if tunnel_data.has("waypoints") and tunnel_data.waypoints.size() > 0:
        for waypoint in tunnel_data.waypoints:
            curve.add_point(Vector3(waypoint.x, waypoint.y, waypoint.z))
    else:
        # Simple curve with one control point
        var mid_pos = (start_pos + Vector3(
            target_anchor.coordinates.x,
            target_anchor.coordinates.y,
            target_anchor.coordinates.z
        )) / 2.0
        
        # Add some height based on dimension
        mid_pos.y += tunnel_data.dimension * 0.5
        
        curve.add_point(mid_pos)
    
    # End point
    var end_pos = Vector3(
        target_anchor.coordinates.x,
        target_anchor.coordinates.y,
        target_anchor.coordinates.z
    )
    curve.add_point(end_pos)
    
    # Create path
    var path = Path3D.new()
    path.curve = curve
    
    # Create mesh instance
    var tunnel_mesh = CSGPolygon3D.new()
    tunnel_mesh.polygon = _create_tunnel_profile(tunnel_data.dimension, tunnel_data.stability)
    tunnel_mesh.mode = CSGPolygon3D.MODE_PATH
    tunnel_mesh.path_node = NodePath(".")
    
    # Set material with color based on dimension
    var tunnel_mat = tunnel_material.duplicate()
    var dim_color = COLOR_DIMENSIONS.get(tunnel_data.dimension, Color(1, 1, 1))
    tunnel_mat.albedo_color = dim_color
    tunnel_mat.emission = dim_color
    
    # Adjust emission based on stability
    tunnel_mat.emission_energy = DEFAULT_GLOW_INTENSITY * (0.5 + tunnel_data.stability * 0.5)
    
    # Apply material
    tunnel_mesh.material = tunnel_mat
    
    # Add stability effect
    if tunnel_data.stability < 0.7:
        # Apply distortion shader for unstable tunnels
        var stability_mat = stability_shader.duplicate()
        stability_mat.set_shader_parameter("stability", tunnel_data.stability)
        stability_mat.set_shader_parameter("base_color", dim_color)
        tunnel_mesh.material_override = stability_mat
    
    # Make interactive
    tunnel_mesh.input_ray_pickable = true
    
    # Add to scene
    path.add_child(tunnel_mesh)
    add_child(path)
    
    # Create flow particles for active tunnels
    if tunnel_data.active:
        _create_flow_particles(path, tunnel_data)
    
    # Store references
    active_tunnels[tunnel_id] = {
        "path": path,
        "mesh": tunnel_mesh,
        "data": tunnel_data
    }

func _create_tunnel_profile(dimension, stability):
    var segment_count = 8 + dimension
    var radius = DEFAULT_TUNNEL_WIDTH * (0.5 + dimension * 0.1)
    
    # Adjust radius based on stability
    radius *= (0.8 + stability * 0.4)
    
    var points = []
    for i in range(segment_count):
        var angle = 2 * PI * i / segment_count
        
        # Add some variance based on stability
        var variance = 0.0
        if stability < 1.0:
            variance = (1.0 - stability) * 0.2 * randf()
            
        var point_radius = radius * (1.0 + variance)
        points.append(Vector2(cos(angle) * point_radius, sin(angle) * point_radius))
    
    return points

func _create_flow_particles(path, tunnel_data):
    var particles = GPUParticles3D.new()
    particles.amount = 50 + (tunnel_data.dimension * 10)
    particles.lifetime = 2.0
    particles.speed_scale = 1.0 / tunnel_data.dimension  # Slower in higher dimensions
    
    # Set up particle material
    var particle_material = ParticleProcessMaterial.new()
    particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_PATH
    particle_material.emission_shape_scale = Vector3(1, 1, 1)
    particle_material.path_node = NodePath("..")
    
    # Color based on dimension
    var dim_color = COLOR_DIMENSIONS.get(tunnel_data.dimension, Color(1, 1, 1))
    particle_material.color = dim_color
    particle_material.color_ramp = _create_color_gradient(dim_color)
    
    particles.process_material = particle_material
    
    # Add to path
    path.add_child(particles)
    return particles

func _create_color_gradient(base_color):
    var gradient = Gradient.new()
    
    # Start transparent
    var start_color = base_color
    start_color.a = 0.0
    gradient.add_point(0.0, start_color)
    
    # Middle bright
    var mid_color = base_color
    mid_color.a = 0.8
    gradient.add_point(0.3, mid_color)
    
    # End transparent
    var end_color = base_color
    end_color.a = 0.0
    gradient.add_point(1.0, end_color)
    
    var gradient_texture = GradientTexture.new()
    gradient_texture.gradient = gradient
    return gradient_texture

func _on_tunnel_established(tunnel_id):
    _create_tunnel_visualization(tunnel_id)

func _on_tunnel_collapsed(tunnel_id):
    if active_tunnels.has(tunnel_id):
        var tunnel = active_tunnels[tunnel_id]
        
        # Create collapse effect
        _create_collapse_effect(tunnel.path.curve)
        
        # Remove tunnel
        tunnel.path.queue_free()
        active_tunnels.erase(tunnel_id)

func _create_collapse_effect(curve):
    var collapse_particles = GPUParticles3D.new()
    collapse_particles.emitting = true
    collapse_particles.one_shot = true
    collapse_particles.explosiveness = 0.8
    collapse_particles.amount = 100
    
    # Set up material
    var particle_material = ParticleProcessMaterial.new()
    particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_PATH
    particle_material.emission_shape_scale = Vector3(1, 1, 1)
    particle_material.path = curve
    
    # Apply material
    collapse_particles.process_material = particle_material
    
    # Add to scene temporarily
    add_child(collapse_particles)
    
    # Remove after effect completes
    var timer = Timer.new()
    timer.wait_time = 2.0
    timer.one_shot = true
    timer.connect("timeout", self, "_remove_collapse_effect", [collapse_particles, timer])
    add_child(timer)
    timer.start()

func _remove_collapse_effect(particles, timer):
    particles.queue_free()
    timer.queue_free()

func _on_anchor_created(anchor_id):
    _create_anchor_visualization(anchor_id)

func _on_anchor_removed(anchor_id):
    if anchor_nodes.has(anchor_id):
        anchor_nodes[anchor_id].queue_free()
        anchor_nodes.erase(anchor_id)

func _on_stability_changed(tunnel_id, new_stability):
    if active_tunnels.has(tunnel_id):
        var tunnel = active_tunnels[tunnel_id]
        
        # Update material
        if tunnel.mesh.material_override:
            tunnel.mesh.material_override.set_shader_parameter("stability", new_stability)
        
        # Update tunnel data
        tunnel.data.stability = new_stability
        
        # If stability is critical, show warning effect
        if new_stability < 0.3:
            _create_warning_effect(tunnel.path)

func _create_warning_effect(path):
    var warning_light = OmniLight3D.new()
    warning_light.light_color = Color(1.0, 0.0, 0.0)
    warning_light.light_energy = 2.0
    
    # Create blinking animation
    var animation_player = AnimationPlayer.new()
    var animation = Animation.new()
    
    # Create animation track for blinking
    var track_index = animation.add_track(Animation.TYPE_VALUE)
    animation.track_set_path(track_index, ".:light_energy")
    
    # Add keyframes
    animation.track_insert_key(track_index, 0.0, 2.0)
    animation.track_insert_key(track_index, 0.25, 0.1)
    animation.track_insert_key(track_index, 0.5, 2.0)
    animation.track_insert_key(track_index, 0.75, 0.1)
    animation.track_insert_key(track_index, 1.0, 2.0)
    
    # Set loop
    animation.loop_mode = Animation.LOOP
    
    # Add to player
    animation_player.add_animation("blink_warning", animation)
    warning_light.add_child(animation_player)
    
    # Add to path
    path.add_child(warning_light)
    
    # Play animation
    animation_player.play("blink_warning")

func _process(delta):
    # Update word particles if any
    for tunnel_id in active_tunnels:
        var tunnel = active_tunnels[tunnel_id]
        
        # If there are words being transferred through this tunnel
        if ethereal_tunnel_manager.is_transferring_words(tunnel_id):
            # Create or update word particles for this tunnel
            if not word_particles.has(tunnel_id):
                word_particles[tunnel_id] = _create_word_particles(tunnel.path)

func _create_word_particles(path):
    var particles = GPUParticles3D.new()
    particles.amount = 20
    particles.lifetime = 3.0
    
    # Set up material
    var particle_material = ParticleProcessMaterial.new()
    particle_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_PATH
    particle_material.emission_shape_scale = Vector3(1, 1, 1)
    particle_material.path_node = NodePath("..")
    
    # Word particles are distinctly white with glow
    particle_material.color = Color(1.0, 1.0, 1.0, 0.8)
    
    # Apply material
    particles.process_material = particle_material
    
    # Add to path
    path.add_child(particles)
    return particles

func _input(event):
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        # Handle clicking on tunnels or anchors
        var camera = get_viewport().get_camera_3d()
        var from = camera.project_ray_origin(event.position)
        var to = from + camera.project_ray_normal(event.position) * 1000
        
        var space_state = get_world_3d().direct_space_state
        var result = space_state.intersect_ray(from, to)
        
        if result:
            # Check if we hit a tunnel
            for tunnel_id in active_tunnels:
                if result.collider == active_tunnels[tunnel_id].mesh:
                    emit_signal("tunnel_selected", tunnel_id)
                    return
            
            # Check if we hit an anchor
            for anchor_id in anchor_nodes:
                if result.collider == anchor_nodes[anchor_id]:
                    emit_signal("anchor_selected", anchor_id)
                    return

func zoom_to_tunnel(tunnel_id):
    if not active_tunnels.has(tunnel_id):
        return
        
    var tunnel = active_tunnels[tunnel_id]
    var curve = tunnel.path.curve
    
    # Calculate center point of tunnel
    var center = Vector3()
    var point_count = curve.get_point_count()
    
    for i in range(point_count):
        center += curve.get_point_position(i)
    
    center /= point_count
    
    # Tell camera controller to focus here (would need to implement in camera controller)
    get_parent().get_node("CameraController").focus_on(center)

func get_tunnel_color(dimension):
    return COLOR_DIMENSIONS.get(dimension, Color(1, 1, 1))

func set_lod_level(level):
    # Change level of detail based on distance or performance settings
    # Level 0 = highest quality, Level 3 = lowest quality
    for tunnel_id in active_tunnels:
        var tunnel = active_tunnels[tunnel_id]
        
        match level:
            0: # Highest quality
                # Full particles, full resolution tunnel
                _update_tunnel_profile(tunnel.mesh, tunnel.data.dimension, tunnel.data.stability, 8 + tunnel.data.dimension)
            1: # Medium quality
                # Fewer particles, slightly reduced tunnel resolution
                _update_tunnel_profile(tunnel.mesh, tunnel.data.dimension, tunnel.data.stability, 6 + tunnel.data.dimension)
            2: # Low quality
                # Minimal particles, low tunnel resolution
                _update_tunnel_profile(tunnel.mesh, tunnel.data.dimension, tunnel.data.stability, 4)
            3: # Lowest quality
                # No particles, very low tunnel resolution
                _update_tunnel_profile(tunnel.mesh, tunnel.data.dimension, tunnel.data.stability, 3)

func _update_tunnel_profile(tunnel_mesh, dimension, stability, segment_count):
    tunnel_mesh.polygon = _create_tunnel_profile_with_segments(dimension, stability, segment_count)

func _create_tunnel_profile_with_segments(dimension, stability, segment_count):
    var radius = DEFAULT_TUNNEL_WIDTH * (0.5 + dimension * 0.1)
    radius *= (0.8 + stability * 0.4)
    
    var points = []
    for i in range(segment_count):
        var angle = 2 * PI * i / segment_count
        var variance = 0.0
        if stability < 1.0:
            variance = (1.0 - stability) * 0.2 * randf()
        var point_radius = radius * (1.0 + variance)
        points.append(Vector2(cos(angle) * point_radius, sin(angle) * point_radius))
    
    return points