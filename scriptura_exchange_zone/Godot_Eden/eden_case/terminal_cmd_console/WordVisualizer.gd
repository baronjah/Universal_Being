extends Node
class_name WordVisualizer

# ------------------------------------
# WordVisualizer - Visual representation system for the World of Words
# Creates, manages, and animates 3D visualizations of words and connections
# ------------------------------------

# Visualization constants
const FONT_SIZE_BASE = 24
const WORD_COLORS = {
    "divine": Color(1.0, 0.8, 0.2),  # Gold
    "cosmic": Color(0.5, 0.0, 1.0),  # Purple
    "reality": Color(0.2, 0.8, 1.0),  # Cyan
    "creative": Color(0.2, 1.0, 0.5),  # Green
    "elemental": Color(1.0, 0.5, 0.0),  # Orange
    "temporal": Color(0.0, 0.5, 0.8),  # Blue
    "spatial": Color(0.5, 0.5, 1.0),  # Light blue
    "conscious": Color(1.0, 0.2, 0.8),  # Pink
    "technological": Color(0.6, 0.6, 0.6),  # Silver
    "natural": Color(0.2, 0.8, 0.2),  # Forest green
    "emotional": Color(1.0, 0.3, 0.3),  # Red
    "physical": Color(0.7, 0.5, 0.3),  # Brown
    "abstract": Color(0.9, 0.9, 0.9),  # White
    "scientific": Color(0.3, 0.6, 0.9),  # Sky blue
    "mystical": Color(0.8, 0.2, 1.0),  # Magenta
    "undefined": Color(0.8, 0.8, 0.8)   # Light gray
}

# Visual dimension properties
const DIMENSION_VISUALS = {
    "1D": {
        "background_color": Color(0.05, 0.05, 0.1),
        "grid_visible": false,
        "particles_enabled": false,
        "animation_speed": 0.5,
        "connection_style": "line",
        "glow_intensity": 0.2
    },
    "2D": {
        "background_color": Color(0.1, 0.1, 0.2),
        "grid_visible": true,
        "particles_enabled": true,
        "animation_speed": 0.8,
        "connection_style": "line",
        "glow_intensity": 0.5
    },
    "3D": {
        "background_color": Color(0.15, 0.15, 0.25),
        "grid_visible": true,
        "particles_enabled": true,
        "animation_speed": 1.0,
        "connection_style": "tube",
        "glow_intensity": 1.0
    },
    "4D": {
        "background_color": Color(0.2, 0.1, 0.3),
        "grid_visible": true,
        "particles_enabled": true,
        "animation_speed": 1.2,
        "connection_style": "tube_animated",
        "glow_intensity": 1.5
    },
    "5D": {
        "background_color": Color(0.25, 0.05, 0.35),
        "grid_visible": false,
        "particles_enabled": true,
        "animation_speed": 1.5,
        "connection_style": "energy",
        "glow_intensity": 2.0
    },
    "6D": {
        "background_color": Color(0.1, 0.05, 0.4),
        "grid_visible": false,
        "particles_enabled": true,
        "animation_speed": 2.0,
        "connection_style": "neural",
        "glow_intensity": 2.5
    },
    "7D": {
        "background_color": Color(0.05, 0.0, 0.2),
        "grid_visible": false,
        "particles_enabled": true,
        "animation_speed": 3.0,
        "connection_style": "quantum",
        "glow_intensity": 3.0
    }
}

# Scene references
var word_scene = null
var connection_scene = null
var particle_system = null
var environment = null

# Instance tracking
var word_instances = {}
var connection_instances = {}
var dimension_properties = {}

# Reference to spatial parent nodes
var words_parent = null
var connections_parent = null

# System state
var current_dimension = "3D"
var word_counter = 0
var highlight_active = false
var highlight_word_id = ""
var visualization_enabled = true
var floating_labels_enabled = true

# Reference to WordDrive
var word_drive = null

# Animation state
var elapsed_time = 0.0
var global_animation_speed = 1.0

# Signal declarations
signal word_visualized(word_id)
signal connection_visualized(connection_id)
signal word_clicked(word_id, word_data)
signal dimension_changed(dimension, properties)

# Node references for visualization components
var camera = null
var lighting = null
var world_environment = null
var grid = null

# Initialize the visualizer
func _ready():
    print("WordVisualizer initialized")
    dimension_properties = DIMENSION_VISUALS.duplicate(true)
    
    # Setup spatial parent nodes
    words_parent = Spatial.new()
    words_parent.name = "Words"
    add_child(words_parent)
    
    connections_parent = Spatial.new()
    connections_parent.name = "Connections"
    add_child(connections_parent)
    
    # Initialize visualization environment
    _setup_environment()
    
    # Setup word and connection scenes
    _setup_resource_scenes()

# Setup the 3D environment
func _setup_environment():
    # Create camera
    camera = Camera.new()
    camera.name = "WordCamera"
    camera.translation = Vector3(0, 2, 8)
    camera.look_at(Vector3(0, 0, 0), Vector3.UP)
    camera.far = 1000
    camera.near = 0.05
    add_child(camera)
    
    # Create lighting
    lighting = DirectionalLight.new()
    lighting.name = "MainLight"
    lighting.translation = Vector3(10, 10, 10)
    lighting.look_at(Vector3.ZERO, Vector3.UP)
    lighting.light_energy = 1.2
    lighting.shadow_enabled = true
    add_child(lighting)
    
    # Create world environment
    world_environment = WorldEnvironment.new()
    var env = Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = DIMENSION_VISUALS["3D"].background_color
    env.ambient_light_color = Color(0.2, 0.2, 0.3)
    env.ambient_light_energy = 0.5
    env.fog_enabled = true
    env.fog_color = DIMENSION_VISUALS["3D"].background_color
    env.fog_depth_begin = 20
    env.fog_depth_end = 100
    env.glow_enabled = true
    env.glow_intensity = DIMENSION_VISUALS["3D"].glow_intensity
    env.glow_bloom = 0.2
    env.adjustment_enabled = true
    world_environment.environment = env
    add_child(world_environment)
    
    # Create grid
    grid = GridMap.new()
    grid.name = "VisualizationGrid"
    grid.visible = DIMENSION_VISUALS["3D"].grid_visible
    add_child(grid)
    
    # Create particle system
    particle_system = Particles.new()
    particle_system.name = "BackgroundParticles"
    particle_system.amount = 1000
    particle_system.lifetime = 10
    particle_system.one_shot = false
    particle_system.explosiveness = 0.0
    particle_system.randomness = 1.0
    particle_system.visibility_aabb = AABB(Vector3(-50, -50, -50), Vector3(100, 100, 100))
    
    # Particle material
    var particle_material = ParticlesMaterial.new()
    particle_material.emission_shape = ParticlesMaterial.EMISSION_SHAPE_BOX
    particle_material.emission_box_extents = Vector3(40, 40, 40)
    particle_material.gravity = Vector3.ZERO
    particle_material.initial_velocity = 0.2
    particle_material.damping = 0.1
    particle_material.scale = 0.05
    particle_material.scale_random = 0.05
    particle_material.color = Color(0.5, 0.5, 1.0, 0.3)
    particle_system.process_material = particle_material
    
    # Create mesh for particles
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = 0.05
    sphere_mesh.height = 0.1
    
    # Create material for particles
    var sphere_material = SpatialMaterial.new()
    sphere_material.albedo_color = Color(0.7, 0.7, 1.0, 0.3)
    sphere_material.flags_transparent = true
    sphere_material.flags_unshaded = true
    sphere_material.params_blend_mode = SpatialMaterial.BLEND_MODE_ADD
    sphere_mesh.material = sphere_material
    
    particle_system.draw_pass_1 = sphere_mesh
    particle_system.visible = DIMENSION_VISUALS["3D"].particles_enabled
    add_child(particle_system)

# Setup the resource scenes for words and connections
func _setup_resource_scenes():
    # In a real implementation, these would be loaded from scene files
    word_scene = _create_word_scene_template()
    connection_scene = _create_connection_scene_template()

# Create a template for the word scene
func _create_word_scene_template():
    # This would typically be a preloaded scene, but we're creating it programmatically
    # for this example
    var scene = Spatial.new()
    scene.name = "WordTemplate"
    
    # Add 3D text mesh
    var text = Label3D.new()
    text.name = "WordText"
    text.text = "Word"
    text.font_size = FONT_SIZE_BASE
    text.modulate = Color(1.0, 1.0, 1.0)
    text.billboard = SpatialMaterial.BILLBOARD_ENABLED
    scene.add_child(text)
    
    # Add collision shape for interaction
    var collision = Area.new()
    collision.name = "ClickArea"
    var shape = CollisionShape.new()
    var box = BoxShape.new()
    box.extents = Vector3(1, 0.5, 0.1)
    shape.shape = box
    collision.add_child(shape)
    scene.add_child(collision)
    
    # Add particle emitter for effects
    var particles = Particles.new()
    particles.name = "WordParticles"
    particles.amount = 20
    particles.lifetime = 1.0
    particles.local_coords = true
    particles.emitting = false
    
    var particle_material = ParticlesMaterial.new()
    particle_material.emission_shape = ParticlesMaterial.EMISSION_SHAPE_SPHERE
    particle_material.emission_sphere_radius = 0.5
    particle_material.gravity = Vector3(0, 0.5, 0)
    particle_material.initial_velocity = 0.5
    particle_material.scale = 0.05
    particle_material.color = Color(1.0, 1.0, 1.0)
    particles.process_material = particle_material
    
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = 0.05
    sphere_mesh.height = 0.1
    var sphere_material = SpatialMaterial.new()
    sphere_material.albedo_color = Color(1.0, 1.0, 1.0, 0.5)
    sphere_material.flags_transparent = true
    sphere_material.flags_unshaded = true
    sphere_mesh.material = sphere_material
    
    particles.draw_pass_1 = sphere_mesh
    scene.add_child(particles)
    
    return scene

# Create a template for connection scene
func _create_connection_scene_template():
    # This would typically be a preloaded scene, but we're creating it programmatically
    var scene = Spatial.new()
    scene.name = "ConnectionTemplate"
    
    # Add line mesh
    var immediate_geo = ImmediateGeometry.new()
    immediate_geo.name = "ConnectionLine"
    
    var line_material = SpatialMaterial.new()
    line_material.flags_unshaded = true
    line_material.flags_transparent = true
    line_material.params_blend_mode = SpatialMaterial.BLEND_MODE_ADD
    line_material.albedo_color = Color(1.0, 1.0, 1.0, 0.7)
    immediate_geo.material_override = line_material
    
    scene.add_child(immediate_geo)
    
    return scene

# Process function for animation updates
func _process(delta):
    if not visualization_enabled:
        return
    
    elapsed_time += delta * global_animation_speed
    
    # Update word animations
    for word_id in word_instances:
        _update_word_animation(word_id, delta)
    
    # Update connection animations
    for connection_id in connection_instances:
        _update_connection_animation(connection_id, delta)
    
    # Update camera rotation for immersive effect
    if camera:
        var camera_orbit_speed = 0.05 * global_animation_speed * DIMENSION_VISUALS[current_dimension].animation_speed
        camera.translation = camera.translation.rotated(Vector3.UP, camera_orbit_speed * delta)
        camera.look_at(Vector3.ZERO, Vector3.UP)

# Update animation for a specific word
func _update_word_animation(word_id, delta):
    if not word_instances.has(word_id):
        return
    
    var word_node = word_instances[word_id]
    var word_data = word_drive.get_word(word_id) if word_drive else null
    
    if not word_data:
        return
    
    # Apply hover animation
    var hover_height = sin(elapsed_time * 0.5 + word_id.hash() % 10) * 0.1
    
    # Apply power-based scaling
    var power_scale = 1.0 + (word_data.power / 100.0) * 0.5
    
    # Apply evolution stage effects if applicable
    var evolution_stage = word_data.get("evolution_stage", 1)
    var evolution_effect = pow(evolution_stage, 0.5) * 0.2
    
    # Combine all effects
    var base_scale = Vector3(power_scale, power_scale, power_scale)
    var animation_scale = base_scale * (1.0 + sin(elapsed_time + word_id.hash()) * 0.05)
    
    # Apply to node
    word_node.translation.y += hover_height
    word_node.scale = animation_scale
    
    # Update particles based on power
    var particles = word_node.get_node("WordParticles")
    if particles:
        particles.emitting = word_data.power > 50 or evolution_stage > 1
        if evolution_stage > 1:
            var process_material = particles.process_material
            process_material.initial_velocity = 0.5 + (evolution_stage * 0.2)
            
            var sphere_mesh = particles.draw_pass_1
            var sphere_material = sphere_mesh.material
            sphere_material.albedo_color = _get_color_for_word(word_data.text, word_data.get("categories", ["undefined"]))
            sphere_material.albedo_color.a = 0.3 + (evolution_stage * 0.1)

# Update animation for a specific connection
func _update_connection_animation(connection_id, delta):
    if not connection_instances.has(connection_id):
        return
    
    var connection_node = connection_instances[connection_id]
    var connection_data = word_drive.get_connection(connection_id) if word_drive else null
    
    if not connection_data:
        return
    
    # Get references to the connected words
    var from_id = connection_data.from_id
    var to_id = connection_data.to_id
    
    if not word_instances.has(from_id) or not word_instances.has(to_id):
        return
    
    var from_node = word_instances[from_id]
    var to_node = word_instances[to_id]
    
    # Update the connection geometry
    var line = connection_node.get_node("ConnectionLine")
    if not line:
        return
    
    var from_pos = from_node.global_transform.origin
    var to_pos = to_node.global_transform.origin
    
    # Get the line material
    var line_material = line.material_override
    
    # Update based on connection style
    match DIMENSION_VISUALS[current_dimension].connection_style:
        "line":
            # Simple line
            line.clear()
            line.begin(Mesh.PRIMITIVE_LINE_STRIP)
            line.add_vertex(from_pos)
            line.add_vertex(to_pos)
            line.end()
            
        "tube":
            # Tube with thickness
            _draw_tube_connection(line, from_pos, to_pos, connection_data)
            
        "tube_animated":
            # Animated tube with pulses
            _draw_animated_tube_connection(line, from_pos, to_pos, connection_data)
            
        "energy":
            # Energy beam with particles
            _draw_energy_connection(line, from_pos, to_pos, connection_data)
            
        "neural":
            # Neural network style with multiple paths
            _draw_neural_connection(line, from_pos, to_pos, connection_data)
            
        "quantum":
            # Quantum entanglement style with probability paths
            _draw_quantum_connection(line, from_pos, to_pos, connection_data)
            
        _:
            # Default fallback
            line.clear()
            line.begin(Mesh.PRIMITIVE_LINE_STRIP)
            line.add_vertex(from_pos)
            line.add_vertex(to_pos)
            line.end()
    
    # Update color based on connection strength
    var strength = connection_data.get("strength", 1.0)
    var color_base = connection_data.get("color", Color(1.0, 1.0, 1.0))
    
    if line_material:
        line_material.albedo_color = color_base
        line_material.albedo_color.a = min(0.3 + (strength * 0.3), 0.9)
        line_material.emission = color_base
        line_material.emission_energy = 0.5 + (strength * 0.5)

# Draw tube-style connection
func _draw_tube_connection(line, from_pos, to_pos, connection_data):
    var segments = 8
    var radius = 0.05 * connection_data.get("strength", 1.0)
    
    line.clear()
    line.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
    
    var direction = (to_pos - from_pos).normalized()
    var up = Vector3.UP
    if direction.dot(up) > 0.9:
        up = Vector3.RIGHT
    
    var right = direction.cross(up).normalized()
    up = right.cross(direction).normalized()
    
    for i in range(segments + 1):
        var angle = i * 2.0 * PI / segments
        var x = cos(angle)
        var y = sin(angle)
        
        var offset = (right * x + up * y) * radius
        line.add_vertex(from_pos + offset)
        line.add_vertex(to_pos + offset)
    
    line.end()

# Draw animated tube connection
func _draw_animated_tube_connection(line, from_pos, to_pos, connection_data):
    var segments = 12
    var radius = 0.05 * connection_data.get("strength", 1.0)
    var length = from_pos.distance_to(to_pos)
    var pulse_speed = 2.0
    var pulse_width = 0.3
    var connection_id_hash = connection_data.id.hash()
    
    line.clear()
    line.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
    
    var direction = (to_pos - from_pos).normalized()
    var up = Vector3.UP
    if direction.dot(up) > 0.9:
        up = Vector3.RIGHT
    
    var right = direction.cross(up).normalized()
    up = right.cross(direction).normalized()
    
    for i in range(segments + 1):
        var angle = i * 2.0 * PI / segments
        var x = cos(angle)
        var y = sin(angle)
        
        # Pulse effect along the tube
        var pulse_pos = fmod(elapsed_time * pulse_speed + float(connection_id_hash % 100) / 100.0, 1.0)
        var pulse_factor = 1.0 + sin(fmod(pulse_pos, 1.0) * PI * 2) * 0.3
        
        var offset = (right * x + up * y) * radius * pulse_factor
        line.add_vertex(from_pos + offset)
        line.add_vertex(to_pos + offset)
    
    line.end()

# Draw energy beam connection
func _draw_energy_connection(line, from_pos, to_pos, connection_data):
    var strength = connection_data.get("strength", 1.0)
    var width = 0.1 * strength
    var segments = 20
    var noise_amplitude = 0.1 + (strength * 0.1)
    var connection_id_hash = connection_data.id.hash()
    
    line.clear()
    line.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
    
    var direction = (to_pos - from_pos).normalized()
    var length = from_pos.distance_to(to_pos)
    var up = Vector3.UP
    if abs(direction.dot(up)) > 0.9:
        up = Vector3.RIGHT
    
    var right = direction.cross(up).normalized()
    
    for i in range(segments + 1):
        var t = float(i) / segments
        var pos = from_pos.linear_interpolate(to_pos, t)
        
        # Add noise for energy effect
        var noise_x = sin(t * 20.0 + elapsed_time * 5.0 + connection_id_hash) * noise_amplitude
        var noise_y = cos(t * 15.0 + elapsed_time * 4.0 + connection_id_hash) * noise_amplitude
        pos += right * noise_x + up * noise_y
        
        # Vary width for energy pulses
        var pulse = 1.0 + sin((t * 10.0 + elapsed_time * 3.0) * PI) * 0.5
        var current_width = width * pulse
        
        line.add_vertex(pos + (right * current_width))
        line.add_vertex(pos - (right * current_width))
    
    line.end()

# Draw neural-style connection
func _draw_neural_connection(line, from_pos, to_pos, connection_data):
    var strength = connection_data.get("strength", 1.0)
    var width = 0.04 * strength
    var segments = 16
    var paths = 3
    var connection_id_hash = connection_data.id.hash()
    
    line.clear()
    
    for p in range(paths):
        line.begin(Mesh.PRIMITIVE_LINE_STRIP)
        
        var path_offset = p * 0.2 - ((paths - 1) * 0.2 / 2)
        var path_speed = 0.5 + (p * 0.2)
        
        for i in range(segments + 1):
            var t = float(i) / segments
            var mid_point = from_pos.linear_interpolate(to_pos, 0.5)
            
            # Create curved path
            var mid_offset = Vector3(
                sin(path_offset + connection_id_hash) * 0.5,
                cos(path_offset + connection_id_hash) * 0.5,
                sin(path_offset * 2 + connection_id_hash) * 0.5
            )
            
            mid_point += mid_offset
            
            var pos
            if t < 0.5:
                pos = from_pos.linear_interpolate(mid_point, t * 2)
            else:
                pos = mid_point.linear_interpolate(to_pos, (t - 0.5) * 2)
            
            # Add time-based pulse
            var pulse_offset = sin(elapsed_time * path_speed + connection_id_hash + p) * 0.1
            pos += Vector3(
                sin(t * 10 + elapsed_time + p) * pulse_offset,
                cos(t * 12 + elapsed_time + p) * pulse_offset,
                sin(t * 8 + elapsed_time + p) * pulse_offset
            )
            
            line.add_vertex(pos)
        
        line.end()
    
    # Add neural nodes along connection
    for n in range(3):
        var t = 0.25 + (n * 0.25)
        var node_pos = from_pos.linear_interpolate(to_pos, t)
        
        line.begin(Mesh.PRIMITIVE_LINE_LOOP)
        
        var node_size = 0.05 + (strength * 0.02)
        var node_segments = 8
        
        for i in range(node_segments):
            var angle = i * 2.0 * PI / node_segments
            var x = cos(angle + elapsed_time) * node_size
            var y = sin(angle + elapsed_time) * node_size
            var z = cos(angle * 2 + elapsed_time) * node_size * 0.5
            
            line.add_vertex(node_pos + Vector3(x, y, z))
        
        line.end()

# Draw quantum-style connection
func _draw_quantum_connection(line, from_pos, to_pos, connection_data):
    var strength = connection_data.get("strength", 1.0)
    var paths = 7
    var segments = 24
    var path_width = 0.02
    var connection_id_hash = connection_data.id.hash()
    
    line.clear()
    
    for p in range(paths):
        var probability = 1.0 - (p / (paths - 1))
        if probability < 0.2:
            continue
        
        var path_color = line.material_override.albedo_color
        path_color.a *= probability
        
        line.begin(Mesh.PRIMITIVE_LINE_STRIP)
        
        var amplitude = 0.5 * probability
        var frequency = 2.0 + (p * 2.0)
        
        for i in range(segments + 1):
            var t = float(i) / segments
            var base_pos = from_pos.linear_interpolate(to_pos, t)
            
            var wave_x = sin(t * frequency * PI + elapsed_time + p + connection_id_hash) * amplitude
            var wave_y = cos(t * frequency * PI + elapsed_time * 0.7 + p + connection_id_hash) * amplitude
            var wave_z = sin(t * frequency * 0.5 * PI + elapsed_time * 1.3 + p + connection_id_hash) * amplitude * 0.5
            
            var pos = base_pos + Vector3(wave_x, wave_y, wave_z) * probability
            
            line.add_vertex(pos)
        
        line.end()
        
        // Draw quantum particles along the path
        line.begin(Mesh.PRIMITIVE_POINTS)
        
        var particles = 5
        for i in range(particles):
            var t = fmod(elapsed_time * (0.2 + (i * 0.1)) + (p * 0.1) + (connection_id_hash % 10) * 0.1, 1.0)
            var base_pos = from_pos.linear_interpolate(to_pos, t)
            
            var wave_x = sin(t * frequency * PI + elapsed_time + p) * amplitude
            var wave_y = cos(t * frequency * PI + elapsed_time * 0.7 + p) * amplitude
            var wave_z = sin(t * frequency * 0.5 * PI + elapsed_time * 1.3 + p) * amplitude * 0.5
            
            var pos = base_pos + Vector3(wave_x, wave_y, wave_z) * probability
            
            line.add_vertex(pos)
        
        line.end()
    }

# Public API: visualize a new word
func visualize_word(word_data):
    if not visualization_enabled or not word_data.has("id"):
        return
    
    var word_id = word_data.id
    
    # Check if already visualized
    if word_instances.has(word_id):
        update_word_visual(word_id, word_data)
        return
    
    # Create a new instance from the template
    var word_instance = word_scene.duplicate()
    word_instance.name = "Word_" + word_id
    
    # Set initial position
    if word_data.has("position"):
        word_instance.translation = word_data.position
    else:
        word_instance.translation = Vector3(
            rand_range(-5, 5),
            rand_range(-5, 5),
            rand_range(-5, 5)
        )
    
    # Set initial rotation
    if word_data.has("rotation"):
        word_instance.rotation = word_data.rotation
    
    # Set text
    var text_node = word_instance.get_node("WordText")
    if text_node:
        text_node.text = word_data.text
        
        # Calculate font size based on power
        var power = word_data.get("power", DEFAULT_WORD_POWER)
        text_node.font_size = FONT_SIZE_BASE * (0.8 + (power / 100.0) * 0.7)
        
        # Set color based on categories
        text_node.modulate = _get_color_for_word(word_data.text, word_data.get("categories", ["undefined"]))
    
    # Setup interaction
    var area = word_instance.get_node("ClickArea")
    if area:
        # Connect signals
        area.connect("input_event", self, "_on_word_input_event", [word_id])
        area.connect("mouse_entered", self, "_on_word_mouse_entered", [word_id])
        area.connect("mouse_exited", self, "_on_word_mouse_exited", [word_id])
    
    # Add to scene
    words_parent.add_child(word_instance)
    word_instances[word_id] = word_instance
    
    # Setup particles
    var particles = word_instance.get_node("WordParticles")
    if particles:
        particles.emitting = word_data.get("power", 0) > 50
        
        # Set particle color based on word
        var particle_material = particles.process_material
        if particle_material:
            particle_material.color = _get_color_for_word(word_data.text, word_data.get("categories", ["undefined"]))
    
    # Emit signal
    emit_signal("word_visualized", word_id)

# Public API: visualize a connection
func visualize_connection(connection_data):
    if not visualization_enabled or not connection_data.has("id"):
        return
    
    var connection_id = connection_data.id
    
    # Check if already visualized
    if connection_instances.has(connection_id):
        update_connection_visual(connection_id, connection_data)
        return
    
    # Check if both words exist
    if not word_instances.has(connection_data.from_id) or not word_instances.has(connection_data.to_id):
        return
    
    # Create a new instance from the template
    var connection_instance = connection_scene.duplicate()
    connection_instance.name = "Connection_" + connection_id
    
    # Set material color based on connection data
    var line = connection_instance.get_node("ConnectionLine")
    if line and line.material_override:
        if connection_data.has("color"):
            line.material_override.albedo_color = connection_data.color
        else:
            # Generate color based on connected words
            var from_word_data = word_drive.get_word(connection_data.from_id) if word_drive else null
            var to_word_data = word_drive.get_word(connection_data.to_id) if word_drive else null
            
            if from_word_data and to_word_data:
                var from_color = _get_color_for_word(from_word_data.text, from_word_data.get("categories", ["undefined"]))
                var to_color = _get_color_for_word(to_word_data.text, to_word_data.get("categories", ["undefined"]))
                line.material_override.albedo_color = from_color.linear_interpolate(to_color, 0.5)
                line.material_override.albedo_color.a = 0.7
            else:
                line.material_override.albedo_color = Color(1.0, 1.0, 1.0, 0.7)
        
        // Set emission glow based on strength
        line.material_override.emission = line.material_override.albedo_color
        line.material_override.emission_energy = 0.5 + (connection_data.get("strength", 1.0) * 0.5)
    
    # Add to scene
    connections_parent.add_child(connection_instance)
    connection_instances[connection_id] = connection_instance
    
    # Initial update to position the connection
    _update_connection_animation(connection_id, 0)
    
    # Emit signal
    emit_signal("connection_visualized", connection_id)

# Public API: update word visual
func update_word_visual(word_id, updated_data):
    if not visualization_enabled or not word_instances.has(word_id):
        return
    
    var word_instance = word_instances[word_id]
    
    # Update position if provided
    if updated_data.has("position"):
        word_instance.translation = updated_data.position
    
    # Update rotation if provided
    if updated_data.has("rotation"):
        word_instance.rotation = updated_data.rotation
    
    # Update text if provided
    if updated_data.has("text"):
        var text_node = word_instance.get_node("WordText")
        if text_node:
            text_node.text = updated_data.text
    
    # Update power affects size
    if updated_data.has("power"):
        var text_node = word_instance.get_node("WordText")
        if text_node:
            text_node.font_size = FONT_SIZE_BASE * (0.8 + (updated_data.power / 100.0) * 0.7)
    
    # Update categories affects color
    if updated_data.has("categories"):
        var text_node = word_instance.get_node("WordText")
        if text_node:
            text_node.modulate = _get_color_for_word(
                updated_data.get("text", word_instance.get_node("WordText").text), 
                updated_data.categories
            )
    
    # Update particles
    if updated_data.has("power") or updated_data.has("evolution_stage"):
        var particles = word_instance.get_node("WordParticles")
        if particles:
            particles.emitting = updated_data.get("power", 0) > 50 or updated_data.get("evolution_stage", 1) > 1
            
            if particles.emitting:
                var process_material = particles.process_material
                if process_material and updated_data.has("categories"):
                    process_material.color = _get_color_for_word(
                        updated_data.get("text", word_instance.get_node("WordText").text), 
                        updated_data.categories
                    )

# Public API: update connection visual
func update_connection_visual(connection_id, updated_data):
    if not visualization_enabled or not connection_instances.has(connection_id):
        return
    
    var connection_instance = connection_instances[connection_id]
    
    # Update material properties
    var line = connection_instance.get_node("ConnectionLine")
    if line and line.material_override:
        # Update color if provided
        if updated_data.has("color"):
            line.material_override.albedo_color = updated_data.color
            line.material_override.emission = updated_data.color
        
        # Update opacity/strength if provided
        if updated_data.has("strength"):
            line.material_override.albedo_color.a = 0.3 + (updated_data.strength * 0.4)
            line.material_override.emission_energy = 0.5 + (updated_data.strength * 0.5)

# Public API: update word physics
func update_word_physics(word_id, physics_data):
    if not visualization_enabled or not word_instances.has(word_id):
        return
    
    var word_instance = word_instances[word_id]
    
    # Update position if provided
    if physics_data.has("position"):
        word_instance.translation = physics_data.position
    
    # Update rotation if provided
    if physics_data.has("rotation"):
        word_instance.rotation = physics_data.rotation

# Public API: remove word visual
func remove_word_visual(word_id):
    if not word_instances.has(word_id):
        return
    
    var word_instance = word_instances[word_id]
    
    # Play removal animation
    var tween = Tween.new()
    add_child(tween)
    tween.interpolate_property(word_instance, "scale", word_instance.scale, Vector3.ZERO, 0.5, Tween.TRANS_BACK, Tween.EASE_IN)
    tween.start()
    
    # Wait for animation to complete
    yield(tween, "tween_completed")
    
    # Remove instance
    word_instance.queue_free()
    word_instances.erase(word_id)
    tween.queue_free()

# Public API: remove connection visual
func remove_connection_visual(connection_id):
    if not connection_instances.has(connection_id):
        return
    
    var connection_instance = connection_instances[connection_id]
    
    # Play removal animation
    var line = connection_instance.get_node("ConnectionLine")
    if line and line.material_override:
        var tween = Tween.new()
        add_child(tween)
        tween.interpolate_property(line.material_override, "albedo_color:a", line.material_override.albedo_color.a, 0.0, 0.5, Tween.TRANS_SINE, Tween.EASE_IN)
        tween.start()
        
        # Wait for animation to complete
        yield(tween, "tween_completed")
        
        # Remove instance
        connection_instance.queue_free()
        connection_instances.erase(connection_id)
        tween.queue_free()

# Public API: update dimension
func update_dimension(dimension, properties = null):
    if not DIMENSION_VISUALS.has(dimension):
        return
    
    current_dimension = dimension
    
    # Apply dimension visual properties
    var dimension_visual = DIMENSION_VISUALS[dimension]
    
    # Update environment
    if world_environment and world_environment.environment:
        var env = world_environment.environment
        env.background_color = dimension_visual.background_color
        env.fog_color = dimension_visual.background_color
        env.glow_intensity = dimension_visual.glow_intensity
    
    # Update grid
    if grid:
        grid.visible = dimension_visual.grid_visible
    
    // Update particles
    if particle_system:
        particle_system.visible = dimension_visual.particles_enabled
    
    // Update animation speed
    global_animation_speed = dimension_visual.animation_speed
    
    // Update all connections to use the new style
    for connection_id in connection_instances:
        _update_connection_animation(connection_id, 0)
    
    // Emit signal
    emit_signal("dimension_changed", dimension, properties if properties != null else dimension_visual)

# Public API: highlight a word
func highlight_word(word_id):
    if not word_instances.has(word_id):
        return
    
    // Remove existing highlight
    clear_highlight()
    
    var word_instance = word_instances[word_id]
    
    // Add glow effect
    var particles = word_instance.get_node("WordParticles")
    if particles:
        particles.emitting = true
        particles.amount = 50
        
        var process_material = particles.process_material
        if process_material:
            process_material.initial_velocity = 1.0
            process_material.color = Color(1.0, 1.0, 1.0, 0.8)
    
    // Scale up the word
    word_instance.scale *= 1.5
    
    // Mark as highlighted
    highlight_active = true
    highlight_word_id = word_id

# Public API: clear highlight
func clear_highlight():
    if not highlight_active:
        return
    
    if word_instances.has(highlight_word_id):
        var word_instance = word_instances[highlight_word_id]
        
        // Reset particle effect
        var particles = word_instance.get_node("WordParticles")
        if particles:
            particles.emitting = false
            particles.amount = 20
        
        // Reset scale
        word_instance.scale = Vector3(1, 1, 1)
    
    highlight_active = false
    highlight_word_id = ""

# Public API: connect to WordDrive
func connect_to_word_drive(drive):
    word_drive = drive
    
    // Register with the drive
    if word_drive:
        word_drive.register_visualizer(self)

# Public API: enable/disable visualization
func set_visualization_enabled(enabled):
    visualization_enabled = enabled
    
    if not enabled:
        // Hide all words and connections
        for word_id in word_instances:
            word_instances[word_id].visible = false
        
        for connection_id in connection_instances:
            connection_instances[connection_id].visible = false
    else:
        // Show all words and connections
        for word_id in word_instances:
            word_instances[word_id].visible = true
        
        for connection_id in connection_instances:
            connection_instances[connection_id].visible = true

# Get color for a word based on its text and categories
func _get_color_for_word(word_text, categories):
    // Check for categories
    if categories and categories.size() > 0:
        var primary_category = categories[0]
        if WORD_COLORS.has(primary_category):
            return WORD_COLORS[primary_category]
    
    // Fallback: check for color keywords in text
    word_text = word_text.to_lower()
    for color_key in WORD_COLORS.keys():
        if word_text.find(color_key) >= 0:
            return WORD_COLORS[color_key]
    
    // Default color
    return WORD_COLORS.undefined

# Handle word input events
func _on_word_input_event(camera, event, click_pos, normal, shape_idx, word_id):
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        // Get word data
        var word_data = word_drive.get_word(word_id) if word_drive else null
        
        // Highlight the word
        highlight_word(word_id)
        
        // Emit signal
        emit_signal("word_clicked", word_id, word_data)

# Handle mouse entered word
func _on_word_mouse_entered(word_id):
    if not word_instances.has(word_id):
        return
    
    var word_instance = word_instances[word_id]
    
    // Subtle highlight
    word_instance.scale *= 1.2

# Handle mouse exited word
func _on_word_mouse_exited(word_id):
    if not word_instances.has(word_id) or highlight_word_id == word_id:
        return
    
    var word_instance = word_instances[word_id]
    
    // Remove subtle highlight
    word_instance.scale = Vector3(1, 1, 1)