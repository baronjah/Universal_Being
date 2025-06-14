extends Spatial

class_name Notepad3DVisualizer

# ----- NOTEPAD 3D VISUALIZER -----
# Handles 3D visualization of words, connections, and dimensional transitions
# Creates interactive 3D interface for the word manifestation system

# ----- VISUALIZATION SETTINGS -----
export var word_font: Font
export var word_material: Material
export var connection_material: Material
export var background_mesh: Mesh
export var default_word_mesh: Mesh
export var camera_speed: float = 10.0
export var rotation_speed: float = 1.0
export var zoom_speed: float = 0.5
export var transition_duration: float = 1.0
export var ambient_color: Color = Color(0.01, 0.01, 0.05)
export var dimension_colors = {
    "1D": Color(1.0, 0.1, 0.1),  # Red
    "2D": Color(1.0, 0.5, 0.1),  # Orange
    "3D": Color(1.0, 1.0, 0.1),  # Yellow
    "4D": Color(0.1, 1.0, 0.1),  # Green
    "5D": Color(0.1, 1.0, 1.0),  # Cyan
    "6D": Color(0.1, 0.1, 1.0),  # Blue
    "7D": Color(0.5, 0.1, 1.0),  # Purple
    "8D": Color(1.0, 0.1, 1.0),  # Magenta
    "9D": Color(1.0, 0.1, 0.5),  # Pink
    "10D": Color(0.5, 0.5, 0.5), # Gray
    "11D": Color(0.9, 0.9, 0.9), # White
    "12D": Color(0.9, 0.9, 1.0)  # Light Blue
}

# ----- COMPONENT REFERENCES -----
var main_camera: Camera
var environment: Environment
var world_environment: WorldEnvironment
var light: DirectionalLight
var word_parent: Spatial
var connection_parent: Spatial
var ui_parent: Control
var transition_effects: Spatial
var background: MeshInstance

# ----- SYSTEM STATE -----
var current_turn = 3
var current_dimension = "3D"
var current_symbol = "γ"
var word_nodes = {}
var connection_nodes = {}
var is_transitioning = false
var transition_progress = 0.0
var camera_target_position = Vector3(0, 5, 10)
var camera_target_rotation = Vector3(-0.4, 0, 0)
var camera_zoom_level = 1.0

# ----- REFERENCE TO SYSTEMS -----
var word_manifestation_system = null
var main_system = null

# ----- SIGNALS -----
signal visualization_ready
signal dimension_transition_complete(to_dimension)
signal word_selected(word_data)
signal word_deselected
signal camera_moved(position, rotation)

# ----- INITIALIZATION -----
func _ready():
    print("Notepad3D Visualizer initializing...")
    setup_scene()
    setup_environment()
    setup_ui()
    print("Notepad3D Visualizer ready")
    emit_signal("visualization_ready")

# ----- PROCESS -----
func _process(delta):
    # Handle transition animation
    if is_transitioning:
        process_transition(delta)
    
    # Update camera if not transitioning
    if not is_transitioning:
        process_camera_movement(delta)
    
    # Update word positions and rotations
    update_word_visualizations(delta)
    
    # Update connections
    update_connection_visualizations(delta)

# ----- INPUT -----
func _input(event):
    # Handle camera movement
    if event is InputEventKey:
        if event.pressed:
            match event.scancode:
                KEY_W: # Forward
                    move_camera(Vector3(0, 0, -1))
                KEY_S: # Backward
                    move_camera(Vector3(0, 0, 1))
                KEY_A: # Left
                    move_camera(Vector3(-1, 0, 0))
                KEY_D: # Right
                    move_camera(Vector3(1, 0, 0))
                KEY_Q: # Up
                    move_camera(Vector3(0, 1, 0))
                KEY_E: # Down
                    move_camera(Vector3(0, -1, 0))
                KEY_R: # Reset camera
                    reset_camera()
    
    # Handle mouse wheel for zoom
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_WHEEL_UP:
            zoom_camera(-1)
        elif event.button_index == BUTTON_WHEEL_DOWN:
            zoom_camera(1)
    
    # Handle mouse drag for rotation
    if event is InputEventMouseMotion and Input.is_mouse_button_pressed(BUTTON_RIGHT):
        rotate_camera(event.relative)

# ----- SETUP FUNCTIONS -----
func setup_scene():
    # Create node structure
    word_parent = Spatial.new()
    word_parent.name = "Words"
    add_child(word_parent)
    
    connection_parent = Spatial.new()
    connection_parent.name = "Connections"
    add_child(connection_parent)
    
    ui_parent = Control.new()
    ui_parent.name = "UI"
    ui_parent.anchor_right = 1.0
    ui_parent.anchor_bottom = 1.0
    add_child(ui_parent)
    
    transition_effects = Spatial.new()
    transition_effects.name = "TransitionEffects"
    add_child(transition_effects)
    
    # Setup camera
    main_camera = Camera.new()
    main_camera.name = "MainCamera"
    main_camera.translation = Vector3(0, 5, 10)
    main_camera.rotation_degrees = Vector3(-30, 0, 0)
    main_camera.fov = 70
    main_camera.far = 1000
    add_child(main_camera)
    
    # Setup light
    light = DirectionalLight.new()
    light.name = "MainLight"
    light.translation = Vector3(0, 10, 0)
    light.rotation_degrees = Vector3(-45, 0, 0)
    light.shadow_enabled = true
    add_child(light)
    
    # Setup background
    background = MeshInstance.new()
    background.name = "Background"
    if background_mesh:
        background.mesh = background_mesh
    else:
        # Create default skybox mesh
        var sphere = SphereMesh.new()
        sphere.radius = 500
        sphere.height = 1000
        sphere.is_hemisphere = false
        background.mesh = sphere
    
    var background_material = SpatialMaterial.new()
    background_material.flags_unshaded = true
    background_material.flags_do_not_receive_shadows = true
    background_material.flags_disable_ambient_light = true
    background_material.flags_no_depth_test = true
    background_material.render_priority = -100  # Render first
    background_material.albedo_color = Color(0.01, 0.01, 0.05)
    background.material_override = background_material
    add_child(background)

func setup_environment():
    # Create environment for visual effects
    environment = Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = ambient_color
    environment.ambient_light_color = ambient_color
    environment.ambient_light_energy = 0.2
    environment.fog_enabled = true
    environment.fog_color = ambient_color
    environment.fog_depth_begin = 20
    environment.fog_depth_end = 100
    environment.fog_depth_curve = 2
    environment.dof_blur_far_enabled = true
    environment.dof_blur_far_distance = 40
    environment.dof_blur_far_amount = 0.1
    environment.glow_enabled = true
    environment.glow_intensity = 0.1
    environment.glow_bloom = 0.1
    
    # Apply environment
    world_environment = WorldEnvironment.new()
    world_environment.environment = environment
    add_child(world_environment)
    
    # Set initial dimension appearance
    set_dimension_appearance(current_dimension)

func setup_ui():
    # Add dimension indicator
    var dimension_label = Label.new()
    dimension_label.name = "DimensionLabel"
    dimension_label.text = current_dimension + " - " + current_symbol
    dimension_label.align = Label.ALIGN_CENTER
    dimension_label.valign = Label.VALIGN_TOP
    dimension_label.rect_position = Vector2(10, 10)
    dimension_label.rect_size = Vector2(200, 50)
    dimension_label.add_color_override("font_color", dimension_colors[current_dimension])
    ui_parent.add_child(dimension_label)
    
    # Add help text
    var help_label = Label.new()
    help_label.name = "HelpLabel"
    help_label.text = "WASD = Move | Mouse Wheel = Zoom | Right Mouse = Rotate | R = Reset View"
    help_label.align = Label.ALIGN_CENTER
    help_label.valign = Label.VALIGN_BOTTOM
    help_label.rect_position = Vector2(10, get_viewport().size.y - 40)
    help_label.rect_size = Vector2(get_viewport().size.x - 20, 30)
    help_label.add_color_override("font_color", Color(0.8, 0.8, 0.8, 0.8))
    ui_parent.add_child(help_label)

# ----- WORD VISUALIZATION -----
func create_word_visualization(word_data):
    # Skip if already exists
    if word_nodes.has(word_data.id):
        return word_nodes[word_data.id]
    
    # Create parent for this word
    var word_node = Spatial.new()
    word_node.name = "Word_" + word_data.id
    word_node.translation = word_data.position
    word_node.rotation = word_data.rotation
    word_parent.add_child(word_node)
    
    # Create 3D text mesh
    var text_mesh
    
    if word_font != null:
        # Create text mesh with font
        text_mesh = create_text_mesh(word_data.text, word_font)
    else:
        # Use default mesh with label
        text_mesh = MeshInstance.new()
        text_mesh.mesh = default_word_mesh if default_word_mesh else BoxMesh.new()
        
        # Add label
        var viewport = Viewport.new()
        viewport.size = Vector2(256, 128)
        viewport.transparent_bg = true
        viewport.render_target_v_flip = true
        
        var label = Label.new()
        label.text = word_data.text
        label.align = Label.ALIGN_CENTER
        label.valign = Label.VALIGN_CENTER
        label.rect_size = viewport.size
        label.add_color_override("font_color", Color(1, 1, 1, 1))
        
        viewport.add_child(label)
        word_node.add_child(viewport)
        
        # Create sprite using viewport texture
        var sprite_material = SpatialMaterial.new()
        sprite_material.flags_unshaded = true
        sprite_material.flags_transparent = true
        sprite_material.albedo_texture = viewport.get_texture()
        
        var sprite = MeshInstance.new()
        sprite.mesh = QuadMesh.new()
        sprite.mesh.size = Vector2(2, 1)
        sprite.material_override = sprite_material
        sprite.translation = Vector3(0, 1, 0)
        word_node.add_child(sprite)
    
    # Scale mesh based on word power
    text_mesh.scale = word_data.size
    word_node.add_child(text_mesh)
    
    # Create material for the word
    var word_mat
    if word_material != null:
        # Use provided material as base
        word_mat = word_material.duplicate()
    else:
        # Create default material
        word_mat = SpatialMaterial.new()
        word_mat.flags_unshaded = false
        word_mat.metallic = 0.8
        word_mat.roughness = 0.2
        word_mat.emission_enabled = true
        word_mat.emission = word_data.color.darkened(0.8)
        word_mat.emission_energy = 0.5 + (word_data.power / 100.0)
    
    # Apply color based on word data
    word_mat.albedo_color = word_data.color
    text_mesh.material_override = word_mat
    
    # Add glow effect for powerful words
    if word_data.power > 50:
        var glow = OmniLight.new()
        glow.light_color = word_data.color
        glow.light_energy = 0.5 + (word_data.power / 200.0)
        glow.light_specular = 1.0
        glow.omni_range = 3.0 + (word_data.power / 50.0)
        word_node.add_child(glow)
    
    # Store reference to node
    word_nodes[word_data.id] = word_node
    
    # Add collision for interaction
    var collision = CollisionShape.new()
    var shape = BoxShape.new()
    shape.extents = Vector3(1, 1, 1) * word_data.size.length()
    collision.shape = shape
    
    var area = Area.new()
    area.add_child(collision)
    area.connect("input_event", self, "_on_word_input_event", [word_data.id])
    word_node.add_child(area)
    
    return word_node

func create_text_mesh(text, font):
    # Create 3D text mesh using the provided font
    # This is a simplified version - actual implementation would depend on your engine version
    # and available text mesh generation capabilities
    
    # Placeholder - create a simple mesh with the text as name
    var text_mesh = MeshInstance.new()
    text_mesh.name = text
    text_mesh.mesh = default_word_mesh if default_word_mesh else BoxMesh.new()
    
    return text_mesh

func update_word_visualization(word_id, word_data):
    # Skip if doesn't exist
    if not word_nodes.has(word_id):
        return false
    
    var word_node = word_nodes[word_id]
    
    # Update position and rotation with smoothing
    word_node.translation = word_node.translation.linear_interpolate(word_data.position, 0.1)
    
    # Handle rotation (convert Vector3 rotation to quaternion for smoother interpolation)
    var current_quat = Quat(word_node.rotation)
    var target_quat = Quat(word_data.rotation)
    var interpolated_quat = current_quat.slerp(target_quat, 0.1)
    word_node.rotation = interpolated_quat.get_euler()
    
    # Update material based on evolution stage
    if word_data.evolution_stage > 1:
        var mesh_instance = word_node.get_child(0)  # Assuming first child is the mesh
        if mesh_instance is MeshInstance and mesh_instance.material_override:
            var material = mesh_instance.material_override
            
            # Enhance emission based on evolution stage
            if material is SpatialMaterial:
                material.emission_energy = 0.5 + (word_data.power / 100.0) * (word_data.evolution_stage / 3.0)
                
                # Special appearance for transcended words (stage 5)
                if word_data.evolution_stage >= 5:
                    material.emission = Color(1, 1, 1).linear_interpolate(word_data.color, 0.3)
                    
                    # Update or add glow effect
                    var glow = null
                    for child in word_node.get_children():
                        if child is OmniLight:
                            glow = child
                            break
                    
                    if glow:
                        glow.light_energy = 1.0 + (word_data.power / 100.0)
                        glow.omni_range = 5.0 + (word_data.power / 40.0)
                        glow.light_color = Color(1, 1, 1).linear_interpolate(word_data.color, 0.5)
    
    return true

func delete_word_visualization(word_id):
    # Skip if doesn't exist
    if not word_nodes.has(word_id):
        return false
    
    # Get node reference
    var word_node = word_nodes[word_id]
    
    # Remove node
    word_node.queue_free()
    word_nodes.erase(word_id)
    
    return true

# ----- CONNECTION VISUALIZATION -----
func create_connection_visualization(connection_data):
    # Skip if already exists
    if connection_nodes.has(connection_data.id):
        return connection_nodes[connection_data.id]
    
    # Verify both words exist
    if not word_nodes.has(connection_data.word1_id) or not word_nodes.has(connection_data.word2_id):
        return null
    
    # Create connection visual
    var connection_node = Spatial.new()
    connection_node.name = "Connection_" + connection_data.id
    connection_parent.add_child(connection_node)
    
    # Create line mesh
    var line = create_connection_line(
        word_nodes[connection_data.word1_id].translation,
        word_nodes[connection_data.word2_id].translation,
        connection_data.color,
        0.05 + (connection_data.strength * 0.05)
    )
    connection_node.add_child(line)
    
    # Store reference
    connection_nodes[connection_data.id] = connection_node
    
    # Add additional metadata
    connection_node.set_meta("word1_id", connection_data.word1_id)
    connection_node.set_meta("word2_id", connection_data.word2_id)
    connection_node.set_meta("strength", connection_data.strength)
    
    return connection_node

func create_connection_line(start_pos, end_pos, color, thickness):
    # Create a line mesh between two points
    var line = ImmediateGeometry.new()
    line.name = "Line"
    
    # Create material
    var line_material
    if connection_material != null:
        line_material = connection_material.duplicate()
    else:
        line_material = SpatialMaterial.new()
        line_material.flags_unshaded = true
        line_material.flags_use_point_size = true
        line_material.vertex_color_use_as_albedo = true
        line_material.emission_enabled = true
        line_material.emission = color
        line_material.emission_energy = 1.0
    
    line_material.albedo_color = color
    line.material_override = line_material
    
    # Draw line
    line.begin(Mesh.PRIMITIVE_LINE_STRIP)
    line.set_color(color)
    line.add_vertex(start_pos)
    line.add_vertex(end_pos)
    line.end()
    
    return line

func update_connection_visualization(connection_id, connection_data):
    # Skip if doesn't exist
    if not connection_nodes.has(connection_id):
        return false
    
    # Verify both words exist
    if not word_nodes.has(connection_data.word1_id) or not word_nodes.has(connection_data.word2_id):
        return false
    
    var connection_node = connection_nodes[connection_id]
    
    # Update line positions
    var line = connection_node.get_node("Line")
    if line is ImmediateGeometry:
        var start_pos = word_nodes[connection_data.word1_id].translation
        var end_pos = word_nodes[connection_data.word2_id].translation
        
        line.clear()
        line.begin(Mesh.PRIMITIVE_LINE_STRIP)
        line.set_color(connection_data.color)
        line.add_vertex(start_pos)
        line.add_vertex(end_pos)
        line.end()
    
    return true

func delete_connection_visualization(connection_id):
    # Skip if doesn't exist
    if not connection_nodes.has(connection_id):
        return false
    
    # Get node reference
    var connection_node = connection_nodes[connection_id]
    
    # Remove node
    connection_node.queue_free()
    connection_nodes.erase(connection_id)
    
    return true

# ----- DIMENSION TRANSITIONS -----
func transition_to_dimension(dimension, symbol, turn):
    if is_transitioning or dimension == current_dimension:
        return false
    
    print("Transitioning to dimension: %s (Turn %d: %s)" % [dimension, turn, symbol])
    
    is_transitioning = true
    transition_progress = 0.0
    
    # Store previous values
    var prev_dimension = current_dimension
    var prev_symbol = current_symbol
    
    # Update current values
    current_dimension = dimension
    current_symbol = symbol
    current_turn = turn
    
    # Update UI
    var dimension_label = ui_parent.get_node("DimensionLabel")
    if dimension_label:
        dimension_label.text = dimension + " - " + symbol
        dimension_label.add_color_override("font_color", dimension_colors[dimension])
    
    # Prepare environment transition
    set_dimension_appearance(dimension)
    
    # Special camera positioning based on dimension
    setup_camera_for_dimension(dimension)
    
    return true

func process_transition(delta):
    if not is_transitioning:
        return
    
    # Update transition progress
    transition_progress += delta / transition_duration
    
    if transition_progress >= 1.0:
        # Transition complete
        is_transitioning = false
        transition_progress = 0.0
        emit_signal("dimension_transition_complete", current_dimension)
    else:
        # Apply transition effects
        apply_transition_effects(transition_progress)

func set_dimension_appearance(dimension):
    # Update environment based on dimension
    if not dimension_colors.has(dimension):
        return
    
    var color = dimension_colors[dimension]
    
    # Gradually update these in the transition effect
    environment.background_color = color.darkened(0.95)
    environment.ambient_light_color = color.darkened(0.8)
    environment.fog_color = color.darkened(0.9)
    
    # Update light color
    light.light_color = color.lightened(0.5)
    
    # Special dimension-specific settings
    match dimension:
        "1D":
            # Simple line world
            environment.fog_depth_begin = 10
            environment.fog_depth_end = 30
            light.light_energy = 0.5
        "2D":
            # Flat world
            environment.fog_depth_begin = 15
            environment.fog_depth_end = 40
            light.light_energy = 0.7
        "3D":
            # Standard 3D space
            environment.fog_depth_begin = 20
            environment.fog_depth_end = 60
            light.light_energy = 1.0
        "4D":
            # Time dimension - more dynamic
            environment.fog_depth_begin = 25
            environment.fog_depth_end = 70
            light.light_energy = 1.2
            # Add time dilation effect
        "5D":
            # Consciousness - mental space
            environment.fog_depth_begin = 30
            environment.fog_depth_end = 80
            light.light_energy = 1.3
            environment.dof_blur_far_amount = 0.2
        "6D":
            # Connection dimension
            environment.fog_depth_begin = 30
            environment.fog_depth_end = 100
            light.light_energy = 1.0
        "7D":
            # Creation dimension
            environment.fog_depth_begin = 40
            environment.fog_depth_end = 120
            light.light_energy = 1.5
        "8D":
            # Network dimension
            environment.fog_depth_begin = 50
            environment.fog_depth_end = 150
            light.light_energy = 1.2
        "9D":
            # Harmony dimension
            environment.fog_depth_begin = 70
            environment.fog_depth_end = 200
            light.light_energy = 1.0
        "10D":
            # Unity dimension
            environment.fog_depth_begin = 100
            environment.fog_depth_end = 300
            light.light_energy = 1.8
            environment.dof_blur_far_amount = 0.05
        "11D":
            # Transcendence dimension
            environment.fog_depth_begin = 200
            environment.fog_depth_end = 500
            light.light_energy = 2.0
            environment.dof_blur_far_amount = 0.0
        "12D":
            # Beyond dimension
            environment.fog_depth_begin = 500
            environment.fog_depth_end = 1000
            light.light_energy = 2.5
            environment.dof_blur_far_amount = 0.0

func setup_camera_for_dimension(dimension):
    # Set appropriate camera position for each dimension
    match dimension:
        "1D":
            camera_target_position = Vector3(0, 1, 5)
            camera_target_rotation = Vector3(0, 0, 0)
            camera_zoom_level = 1.0
        "2D":
            camera_target_position = Vector3(0, 5, 0.1)
            camera_target_rotation = Vector3(-PI/2, 0, 0)
            camera_zoom_level = 2.0
        "3D":
            camera_target_position = Vector3(0, 5, 10)
            camera_target_rotation = Vector3(-PI/6, 0, 0)
            camera_zoom_level = 1.0
        _:
            # Default for other dimensions
            camera_target_position = Vector3(0, 5, 10)
            camera_target_rotation = Vector3(-PI/6, 0, 0)
            camera_zoom_level = 1.0

func apply_transition_effects(progress):
    # Apply various transition effects based on progress (0.0 to 1.0)
    
    # Smoothly move camera
    if main_camera:
        var initial_pos = main_camera.translation
        var initial_rot = main_camera.rotation
        main_camera.translation = initial_pos.linear_interpolate(camera_target_position, progress * 0.1)
        
        # Smoothly rotate (using quaternions for better interpolation)
        var current_quat = Quat(initial_rot)
        var target_quat = Quat(camera_target_rotation)
        var interpolated_quat = current_quat.slerp(target_quat, progress * 0.1)
        main_camera.rotation = interpolated_quat.get_euler()
    
    # Add transition visual effects
    var effect_intensity = sin(progress * PI) # Peak at middle of transition
    
    # Color shift
    var target_color = dimension_colors[current_dimension].darkened(0.95)
    environment.background_color = environment.background_color.linear_interpolate(target_color, progress * 0.1)
    
    # Glow effect
    environment.glow_intensity = 0.1 + effect_intensity * 0.5
    environment.glow_bloom = 0.1 + effect_intensity * 0.3
    
    # Camera effects
    if main_camera:
        main_camera.fov = 70 + (effect_intensity * 10)

# ----- CAMERA FUNCTIONS -----
func move_camera(direction):
    if is_transitioning:
        return
    
    var speed = camera_speed * camera_zoom_level
    var camera_basis = main_camera.global_transform.basis
    
    # Move relative to camera orientation
    var movement = camera_basis.x * direction.x + camera_basis.y * direction.y + camera_basis.z * direction.z
    movement = movement.normalized() * speed
    
    camera_target_position += movement
    main_camera.translation += movement
    
    emit_signal("camera_moved", main_camera.translation, main_camera.rotation)

func rotate_camera(relative_motion):
    if is_transitioning:
        return
    
    var rotation_delta = Vector3(
        -relative_motion.y * rotation_speed * 0.01,
        -relative_motion.x * rotation_speed * 0.01,
        0
    )
    
    camera_target_rotation += rotation_delta
    
    # Limit vertical rotation
    camera_target_rotation.x = clamp(camera_target_rotation.x, -PI/2, PI/2)
    
    main_camera.rotation += rotation_delta
    main_camera.rotation.x = clamp(main_camera.rotation.x, -PI/2, PI/2)
    
    emit_signal("camera_moved", main_camera.translation, main_camera.rotation)

func zoom_camera(direction):
    if is_transitioning:
        return
    
    # Adjust zoom level
    camera_zoom_level += direction * zoom_speed * 0.1
    camera_zoom_level = clamp(camera_zoom_level, 0.5, 3.0)
    
    # Move camera forward/backward based on zoom
    var forward = -main_camera.global_transform.basis.z.normalized() * direction * zoom_speed * 2
    main_camera.translation += forward
    camera_target_position += forward
    
    emit_signal("camera_moved", main_camera.translation, main_camera.rotation)

func reset_camera():
    setup_camera_for_dimension(current_dimension)
    main_camera.translation = camera_target_position
    main_camera.rotation = camera_target_rotation
    
    emit_signal("camera_moved", main_camera.translation, main_camera.rotation)

# ----- UPDATE FUNCTIONS -----
func update_word_visualizations(delta):
    # Skip if no manifestation system
    if not word_manifestation_system:
        return
    
    var manifested_words = word_manifestation_system.get_word_list()
    
    # Update existing words
    for word_id in manifested_words:
        var word_data = manifested_words[word_id]
        
        # Create if not exists
        if not word_nodes.has(word_id):
            create_word_visualization(word_data)
        else:
            # Update existing
            update_word_visualization(word_id, word_data)
    
    # Check for deleted words
    var words_to_delete = []
    for word_id in word_nodes:
        if not manifested_words.has(word_id):
            words_to_delete.append(word_id)
    
    # Delete words that no longer exist
    for word_id in words_to_delete:
        delete_word_visualization(word_id)

func update_connection_visualizations(delta):
    # Skip if no manifestation system
    if not word_manifestation_system:
        return
    
    var connections = word_manifestation_system.get_connection_list()
    
    # Update existing connections
    for connection in connections:
        var connection_id = connection.id
        
        # Create if not exists
        if not connection_nodes.has(connection_id):
            create_connection_visualization(connection)
        else:
            # Update existing
            update_connection_visualization(connection_id, connection)
    
    # Check for deleted connections
    var connections_to_delete = []
    for connection_id in connection_nodes:
        var found = false
        for connection in connections:
            if connection.id == connection_id:
                found = true
                break
        
        if not found:
            connections_to_delete.append(connection_id)
    
    # Delete connections that no longer exist
    for connection_id in connections_to_delete:
        delete_connection_visualization(connection_id)

# ----- EVENT HANDLERS -----
func _on_word_input_event(camera, event, click_position, click_normal, shape_idx, word_id):
    # Handle word interactions
    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
        # Get word data
        if word_manifestation_system and word_manifestation_system.get_word_list().has(word_id):
            var word_data = word_manifestation_system.get_word_list()[word_id]
            emit_signal("word_selected", word_data)
        else:
            emit_signal("word_deselected")

# ----- PUBLIC API -----
func set_word_manifestation_system(system):
    word_manifestation_system = system
    print("Word manifestation system connected to visualizer")

func set_main_system(system):
    main_system = system
    print("Main system connected to visualizer")

func get_current_dimension():
    return {
        "dimension": current_dimension,
        "symbol": current_symbol,
        "turn": current_turn
    }