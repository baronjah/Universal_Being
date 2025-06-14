extends Spatial
class_name Notepad3DAdvanced

# Notepad3D Advanced - Dimensional Memory Visualization System
# Integrates with the # memory organization system and Ultra Advanced Mode
# Creates an immersive 3D interface for manipulating memories across dimensions

# Memory System Integration
var memory_rehab_system = null # Reference to MemoryRehabSystem
var memory_ultra_advanced = null # Reference to MemoryUltraAdvanced
var current_device = 0 # Active device (0-3)
var current_dimension = 1 # Active dimension (1-12)

# Visualization Settings
export var memory_node_mesh: Mesh
export var memory_font: Font
export var memory_material: Material
export var connection_material: Material
export var environment_mesh: Mesh

# Color Mapping
const DIMENSION_COLORS = {
    1: Color(1.0, 0.1, 0.1),  # Red - Reality
    2: Color(1.0, 0.5, 0.1),  # Orange - Linear
    3: Color(1.0, 1.0, 0.1),  # Yellow - Spatial
    4: Color(0.1, 1.0, 0.1),  # Green - Temporal
    5: Color(0.1, 1.0, 1.0),  # Cyan - Consciousness
    6: Color(0.1, 0.1, 1.0),  # Blue - Connection
    7: Color(0.5, 0.1, 1.0),  # Purple - Creation
    8: Color(1.0, 0.1, 1.0),  # Magenta - Network
    9: Color(1.0, 0.1, 0.5),  # Pink - Harmony
    10: Color(0.7, 0.7, 0.7), # Silver - Unity
    11: Color(0.9, 0.9, 0.9), # White - Transcendence
    12: Color(0.9, 0.9, 1.0)  # Light Blue - Meta
}

const TAG_COLORS = {
    "##": Color(1.0, 1.0, 1.0),  # Core - White
    "#-": Color(0.7, 0.7, 0.7),  # Fragment - Gray
    "#>": Color(0.0, 0.7, 1.0),  # Link - Blue
    "#^": Color(1.0, 0.5, 0.0),  # Evolution - Orange
    "#*": Color(1.0, 1.0, 0.0),  # Insight - Yellow
    "#t": Color(0.0, 1.0, 0.0),  # Time - Green
    "#s": Color(0.5, 0.0, 1.0),  # Space - Purple
    "#e": Color(1.0, 0.0, 0.5),  # Emotion - Pink
    "#?": Color(1.0, 0.7, 0.0),  # Question - Gold
    "#!": Color(1.0, 0.0, 0.0),  # Answer - Red
    "#m": Color(0.0, 1.0, 1.0),  # Meta - Cyan
    "#x": Color(0.5, 0.0, 0.0)   # Conflict - Dark Red
}

# Component References
var camera: Camera
var environment: Environment
var world_environment: WorldEnvironment
var main_light: DirectionalLight
var memory_parent: Spatial
var connection_parent: Spatial
var ui_layer: CanvasLayer
var dimension_label: Label
var device_label: Label
var status_label: Label
var command_input: LineEdit

# Scene State
var memory_nodes = {} # id -> Spatial
var connection_nodes = {}
var device_containers = [] # Array of 4 containers for each device
var is_transitioning = false
var transition_progress = 0.0
var animation_time = 0.0
var selected_memory_id = null

# Physics Simulation
var physics_enabled = true
var gravity_strength = 0.1
var attraction_strength = 0.5
var repulsion_strength = 1.0
var connection_strength = 2.0
var max_velocity = 5.0
var damping = 0.95

# Memory Node Data
class MemoryNodeData:
    var id: String
    var content: String
    var device: int
    var dimension: int
    var tags = []
    var position: Vector3
    var velocity: Vector3
    var connections = []
    var size: float
    var color: Color
    var highlight: bool
    var creation_time: float
    
    func _init(p_id, p_content, p_device, p_dimension, p_tags = []):
        id = p_id
        content = p_content
        device = p_device
        dimension = p_dimension
        tags = p_tags
        position = Vector3(
            rand_range(-5, 5),
            rand_range(-5, 5),
            rand_range(-5, 5)
        )
        velocity = Vector3.ZERO
        size = 1.0
        color = DIMENSION_COLORS[dimension]
        highlight = false
        creation_time = OS.get_ticks_msec() / 1000.0
        
        # Adjust color based on tags
        if tags.size() > 0:
            var tag = tags[0]
            if TAG_COLORS.has(tag):
                color = color.linear_interpolate(TAG_COLORS[tag], 0.7)

# Signals
signal memory_selected(memory_id, memory_data)
signal command_executed(command, result)
signal dimension_changed(device, dimension)
signal memory_created(memory_id)
signal memory_connected(source_id, target_id)

# Initialization
func _ready():
    print("# Notepad3D Advanced initializing...")
    setup_scene()
    setup_ui()
    setup_device_containers()
    print("# Notepad3D Advanced ready #")

# Process
func _process(delta):
    # Update animation time
    animation_time += delta
    
    # Handle transition animation
    if is_transitioning:
        process_transition(delta)
    
    # Update memory physics and visuals
    if physics_enabled:
        update_memory_physics(delta)
    
    # Update memory visuals
    update_memory_visuals(delta)
    
    # Animate environment
    animate_environment(delta)

# Setup Functions
func setup_scene():
    # Create scene structure
    memory_parent = Spatial.new()
    memory_parent.name = "Memories"
    add_child(memory_parent)
    
    connection_parent = Spatial.new()
    connection_parent.name = "Connections"
    connection_parent.z_index = -1  # Ensure connections render behind memories
    add_child(connection_parent)
    
    # Setup camera
    camera = Camera.new()
    camera.name = "MainCamera"
    camera.translation = Vector3(0, 0, 15)
    camera.fov = 70
    camera.far = 1000
    add_child(camera)
    
    # Setup lighting
    main_light = DirectionalLight.new()
    main_light.name = "MainLight"
    main_light.translation = Vector3(10, 10, 10)
    main_light.look_at(Vector3.ZERO, Vector3.UP)
    main_light.shadow_enabled = true
    add_child(main_light)
    
    # Setup environment
    environment = Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.05, 0.05, 0.1)
    environment.ambient_light_color = Color(0.2, 0.2, 0.3)
    environment.ambient_light_energy = 0.3
    environment.fog_enabled = true
    environment.fog_color = Color(0.05, 0.05, 0.1)
    environment.fog_depth_begin = 20
    environment.fog_depth_end = 100
    environment.fog_depth_curve = 2
    environment.glow_enabled = true
    environment.glow_intensity = 0.2
    environment.glow_bloom = 0.3
    
    world_environment = WorldEnvironment.new()
    world_environment.environment = environment
    add_child(world_environment)
    
    # Create skybox/environment sphere
    var env_sphere = MeshInstance.new()
    env_sphere.name = "EnvironmentSphere"
    
    if environment_mesh:
        env_sphere.mesh = environment_mesh
    else:
        var sphere = SphereMesh.new()
        sphere.radius = 500
        sphere.height = 1000
        env_sphere.mesh = sphere
    
    var env_material = SpatialMaterial.new()
    env_material.flags_unshaded = true
    env_material.flags_do_not_receive_shadows = true
    env_material.flags_disable_ambient_light = true
    env_material.flags_no_depth_test = true
    env_material.params_cull_mode = SpatialMaterial.CULL_FRONT  # Render inside
    env_material.albedo_color = Color(0.05, 0.05, 0.1)
    env_sphere.material_override = env_material
    add_child(env_sphere)

func setup_ui():
    # Create UI layer
    ui_layer = CanvasLayer.new()
    ui_layer.name = "UI"
    add_child(ui_layer)
    
    # Create dimension label
    dimension_label = Label.new()
    dimension_label.name = "DimensionLabel"
    dimension_label.text = "# DIMENSION " + str(current_dimension) + " #"
    dimension_label.rect_position = Vector2(20, 20)
    dimension_label.add_color_override("font_color", DIMENSION_COLORS[current_dimension])
    ui_layer.add_child(dimension_label)
    
    # Create device label
    device_label = Label.new()
    device_label.name = "DeviceLabel"
    device_label.text = "# DEVICE " + str(current_device) + " #"
    device_label.rect_position = Vector2(20, 50)
    device_label.add_color_override("font_color", Color(1, 1, 1))
    ui_layer.add_child(device_label)
    
    # Create status label
    status_label = Label.new()
    status_label.name = "StatusLabel"
    status_label.text = "# READY #"
    status_label.align = Label.ALIGN_RIGHT
    status_label.rect_position = Vector2(get_viewport().size.x - 200, 20)
    status_label.rect_size = Vector2(180, 50)
    status_label.add_color_override("font_color", Color(0.5, 1, 0.5))
    ui_layer.add_child(status_label)
    
    # Create command input
    command_input = LineEdit.new()
    command_input.name = "CommandInput"
    command_input.placeholder_text = "# Enter memory command..."
    command_input.rect_position = Vector2(20, get_viewport().size.y - 50)
    command_input.rect_size = Vector2(get_viewport().size.x - 40, 30)
    command_input.connect("text_entered", self, "_on_command_entered")
    ui_layer.add_child(command_input)
    
    # Help text
    var help_label = Label.new()
    help_label.name = "HelpLabel"
    help_label.text = "# Press Tab for commands | WASD = Navigate | Right-click = Rotate | Scroll = Zoom #"
    help_label.align = Label.ALIGN_CENTER
    help_label.rect_position = Vector2(0, get_viewport().size.y - 80)
    help_label.rect_size = Vector2(get_viewport().size.x, 30)
    help_label.add_color_override("font_color", Color(0.7, 0.7, 0.7))
    ui_layer.add_child(help_label)

func setup_device_containers():
    # Create a container for each device
    for i in range(4):
        var container = Spatial.new()
        container.name = "Device_" + str(i)
        memory_parent.add_child(container)
        device_containers.append(container)
        
        # Only show the current device container
        container.visible = (i == current_device)

# Memory Visualization Functions
func create_memory_visualization(memory_data):
    # Validate memory exists and is not already visualized
    if memory_nodes.has(memory_data.id):
        return null
    
    # Create the memory node
    var node = Spatial.new()
    node.name = "Memory_" + memory_data.id
    node.translation = memory_data.position
    
    # Get the correct device container
    var device_container = device_containers[memory_data.device]
    device_container.add_child(node)
    
    # Create visual representation
    var visual = create_memory_mesh(memory_data)
    node.add_child(visual)
    
    # Create label
    var label = create_memory_label(memory_data)
    node.add_child(label)
    
    # Add collision for interaction
    var area = Area.new()
    var collision = CollisionShape.new()
    var shape = SphereShape.new()
    shape.radius = memory_data.size * 0.5
    collision.shape = shape
    area.add_child(collision)
    area.connect("input_event", self, "_on_memory_input_event", [memory_data.id])
    node.add_child(area)
    
    # Add glow effect if memory has tags
    if memory_data.tags.size() > 0:
        var light = OmniLight.new()
        light.name = "Glow"
        light.light_color = memory_data.color
        light.light_energy = 0.5
        light.omni_range = memory_data.size * 2
        node.add_child(light)
    
    # Store reference to node
    memory_nodes[memory_data.id] = node
    
    return node

func create_memory_mesh(memory_data):
    # Create the visual mesh for the memory
    var mesh_instance = MeshInstance.new()
    mesh_instance.name = "MemoryMesh"
    
    # Use provided mesh or create default
    if memory_node_mesh:
        mesh_instance.mesh = memory_node_mesh
    else:
        var sphere = SphereMesh.new()
        sphere.radius = memory_data.size * 0.5
        sphere.height = memory_data.size
        sphere.radial_segments = 16
        sphere.rings = 8
        mesh_instance.mesh = sphere
    
    # Create material
    var material
    if memory_material:
        material = memory_material.duplicate()
    else:
        material = SpatialMaterial.new()
        material.flags_unshaded = false
        material.metallic = 0.7
        material.roughness = 0.2
        material.emission_enabled = true
        material.emission = memory_data.color.darkened(0.7)
        material.emission_energy = 0.5
    
    # Apply color and properties
    material.albedo_color = memory_data.color
    
    # Special effects for different tags
    if memory_data.tags.size() > 0:
        var tag = memory_data.tags[0]
        
        match tag:
            "##":  # Core - Stronger emission
                material.emission_energy = 1.0
                material.metallic = 0.9
            "#-":  # Fragment - More transparent
                material.flags_transparent = true
                material.albedo_color.a = 0.7
            "#>":  # Link - Emissive pulses
                material.emission_energy = 0.7 + sin(animation_time * 2) * 0.3
            "#^":  # Evolution - Growing/shrinking
                mesh_instance.scale = Vector3.ONE * (1 + sin(animation_time) * 0.1)
            "#*":  # Insight - Bright flashes
                material.emission_energy = 0.5 + pow(sin(animation_time * 3) * 0.5 + 0.5, 2)
            "#m":  # Meta - Rotating effect
                mesh_instance.rotation_degrees.y = animation_time * 30
    
    # Set material
    mesh_instance.material_override = material
    
    return mesh_instance

func create_memory_label(memory_data):
    # Create a billboard label for the memory
    
    # Create a viewport for rendering text
    var viewport = Viewport.new()
    viewport.name = "LabelViewport"
    viewport.size = Vector2(256, 128)
    viewport.transparent_bg = true
    viewport.render_target_v_flip = true
    
    # Create the label
    var label = Label.new()
    label.name = "MemoryText"
    label.text = format_memory_text(memory_data.content, memory_data.tags)
    label.align = Label.ALIGN_CENTER
    label.valign = Label.VALIGN_CENTER
    label.rect_size = viewport.size
    label.add_color_override("font_color", memory_data.color.lightened(0.5))
    
    viewport.add_child(label)
    
    # Create a sprite to display the viewport texture
    var sprite_material = SpatialMaterial.new()
    sprite_material.flags_unshaded = true
    sprite_material.flags_transparent = true
    sprite_material.params_billboard_mode = SpatialMaterial.BILLBOARD_ENABLED
    sprite_material.albedo_texture = viewport.get_texture()
    
    var sprite = MeshInstance.new()
    sprite.name = "LabelSprite"
    sprite.mesh = QuadMesh.new()
    sprite.mesh.size = Vector2(2, 1) * memory_data.size
    sprite.material_override = sprite_material
    sprite.translation = Vector3(0, memory_data.size * 0.7, 0)
    
    # Create the complete label system
    var label_parent = Spatial.new()
    label_parent.name = "Label"
    label_parent.add_child(viewport)
    label_parent.add_child(sprite)
    
    return label_parent

func format_memory_text(content, tags):
    # Format the memory text with tags
    var formatted = content
    
    # Trim to reasonable length for display
    if formatted.length() > 30:
        formatted = formatted.substr(0, 27) + "..."
    
    # Add the primary tag if exists
    if tags.size() > 0:
        formatted = tags[0] + " " + formatted
    
    return formatted

func create_connection_visualization(source_id, target_id):
    # Create a visual connection between two memories
    var connection_id = source_id + "_" + target_id
    
    # Skip if already exists
    if connection_nodes.has(connection_id):
        return connection_nodes[connection_id]
    
    # Verify both memories exist
    if not memory_nodes.has(source_id) or not memory_nodes.has(target_id):
        return null
    
    # Create connection
    var connection = ImmediateGeometry.new()
    connection.name = "Connection_" + connection_id
    connection_parent.add_child(connection)
    
    # Create material
    var material
    if connection_material:
        material = connection_material.duplicate()
    else:
        material = SpatialMaterial.new()
        material.flags_unshaded = true
        material.vertex_color_use_as_albedo = true
        material.flags_transparent = true
        material.flags_no_depth_test = false
        
    # Get memory data
    var source_node = memory_nodes[source_id]
    var target_node = memory_nodes[target_id]
    var source_color = source_node.get_node("MemoryMesh").material_override.albedo_color
    var target_color = target_node.get_node("MemoryMesh").material_override.albedo_color
    
    # Set properties
    connection.material_override = material
    
    # Draw line
    update_connection(connection, source_node.translation, target_node.translation, source_color, target_color)
    
    # Store reference
    connection_nodes[connection_id] = connection
    
    # Set metadata
    connection.set_meta("source_id", source_id)
    connection.set_meta("target_id", target_id)
    
    return connection

func update_connection(connection, start_pos, end_pos, start_color, end_color):
    # Update the visual appearance of a connection
    connection.clear()
    connection.begin(Mesh.PRIMITIVE_LINE_STRIP)
    
    # Draw line with gradient color
    for i in range(10):
        var t = i / 9.0
        var pos = start_pos.linear_interpolate(end_pos, t)
        var color = start_color.linear_interpolate(end_color, t)
        color.a = 0.7  # Make line slightly transparent
        
        # Add some waviness to the line
        var wave_offset = Vector3(
            sin(animation_time * 2 + t * 10) * 0.05,
            cos(animation_time * 1.5 + t * 8) * 0.05,
            sin(animation_time + t * 12) * 0.05
        )
        
        connection.set_color(color)
        connection.add_vertex(pos + wave_offset)
    
    connection.end()

# Physics Simulation
func update_memory_physics(delta):
    # Skip if no memory rehab system
    if not memory_rehab_system and not memory_ultra_advanced:
        return
    
    # Get all memory nodes in current device
    var current_memories = []
    for id in memory_nodes:
        var node = memory_nodes[id]
        if node.get_parent() == device_containers[current_device]:
            current_memories.append(id)
    
    # Calculate forces for each memory
    for i in range(current_memories.size()):
        var id_a = current_memories[i]
        var node_a = memory_nodes[id_a]
        var pos_a = node_a.translation
        var vel_a = Vector3.ZERO
        
        if node_a.has_meta("velocity"):
            vel_a = node_a.get_meta("velocity")
        
        # Apply central gravity
        var to_center = -pos_a.normalized()
        vel_a += to_center * gravity_strength * delta
        
        # Apply repulsion and attraction between memories
        for j in range(current_memories.size()):
            if i == j:
                continue
                
            var id_b = current_memories[j]
            var node_b = memory_nodes[id_b]
            var pos_b = node_b.translation
            
            # Calculate direction and distance
            var dir = (pos_b - pos_a).normalized()
            var dist = pos_a.distance_to(pos_b)
            
            # Skip if too far
            if dist > 20:
                continue
            
            # Apply repulsion (inverse square)
            var repulsion = -dir * repulsion_strength / max(dist * dist, 0.1)
            vel_a += repulsion * delta
            
            # Check if connected
            var connection_id_a = id_a + "_" + id_b
            var connection_id_b = id_b + "_" + id_a
            
            if connection_nodes.has(connection_id_a) or connection_nodes.has(connection_id_b):
                # Apply attraction for connected nodes
                var ideal_dist = 2.0
                var connection_force = dir * connection_strength * (dist - ideal_dist) * delta
                vel_a += connection_force
        
        # Apply drag/damping
        vel_a *= damping
        
        # Limit maximum velocity
        if vel_a.length() > max_velocity:
            vel_a = vel_a.normalized() * max_velocity
        
        # Update position
        node_a.translation += vel_a * delta
        
        # Store velocity
        node_a.set_meta("velocity", vel_a)

# Visual Updates
func update_memory_visuals(delta):
    # Skip if no memory rehab system
    if not memory_rehab_system and not memory_ultra_advanced:
        return
    
    # Update connections
    for connection_id in connection_nodes:
        var connection = connection_nodes[connection_id]
        var source_id = connection.get_meta("source_id")
        var target_id = connection.get_meta("target_id")
        
        # Skip if either memory no longer exists
        if not memory_nodes.has(source_id) or not memory_nodes.has(target_id):
            connection.queue_free()
            connection_nodes.erase(connection_id)
            continue
        
        # Update connection appearance
        var source_node = memory_nodes[source_id]
        var target_node = memory_nodes[target_id]
        var source_mesh = source_node.get_node("MemoryMesh")
        var target_mesh = target_node.get_node("MemoryMesh")
        
        update_connection(
            connection, 
            source_node.translation, 
            target_node.translation,
            source_mesh.material_override.albedo_color,
            target_mesh.material_override.albedo_color
        )
    
    # Highlight selected memory
    if selected_memory_id and memory_nodes.has(selected_memory_id):
        var node = memory_nodes[selected_memory_id]
        var mesh = node.get_node("MemoryMesh")
        var material = mesh.material_override
        
        # Create pulsing highlight effect
        var pulse = (sin(animation_time * 4) * 0.5 + 0.5) * 0.5 + 0.5
        material.emission_energy = pulse * 2
        
        # Create spotlight on selected memory
        var spotlight = null
        for child in node.get_children():
            if child is SpotLight and child.name == "SelectionLight":
                spotlight = child
                break
        
        if not spotlight:
            spotlight = SpotLight.new()
            spotlight.name = "SelectionLight"
            spotlight.light_color = Color(1, 1, 1)
            spotlight.light_energy = 1.0
            spotlight.spot_range = 10
            spotlight.spot_angle = 30
            spotlight.translation = Vector3(0, 5, 0)
            spotlight.rotation = Vector3(-PI/2, 0, 0)
            node.add_child(spotlight)

func animate_environment(delta):
    # Create ambient animations in the environment
    
    # Slowly rotate the environment light
    if main_light:
        main_light.rotation_degrees.y += delta * 5
    
    # Subtle color shifts in the environment
    if environment:
        var base_color = DIMENSION_COLORS[current_dimension].darkened(0.95)
        var time_factor = (sin(animation_time * 0.2) * 0.5 + 0.5) * 0.1
        environment.background_color = base_color.lightened(time_factor)
        environment.fog_color = base_color.lightened(time_factor * 0.5)
    
    # Update dimension label color
    if dimension_label:
        var dimension_color = DIMENSION_COLORS[current_dimension]
        var pulse = sin(animation_time * 2) * 0.1 + 0.9
        dimension_label.add_color_override("font_color", dimension_color * pulse)

# System Integration
func connect_memory_rehab_system(system):
    memory_rehab_system = system
    print("# Connected to Memory Rehab System #")
    
    # Initial load of memories
    load_memories_from_rehab_system()
    
    return true

func connect_memory_ultra_advanced(system):
    memory_ultra_advanced = system
    print("# Connected to Memory Ultra Advanced System #")
    
    # Initial load of memories
    load_memories_from_ultra_system()
    
    return true

func load_memories_from_rehab_system():
    # Skip if no system
    if not memory_rehab_system:
        return
    
    # Get memories from current dimension
    var dimension_memories = memory_rehab_system.get_memories_by_dimension(current_dimension)
    
    # Create visualization for each memory
    for memory in dimension_memories:
        # Convert to our format
        var memory_data = MemoryNodeData.new(
            memory.id,
            memory.content,
            0,  # Default to device 0 for rehab system
            memory.dimension,
            memory.tags
        )
        
        # Create visualization
        create_memory_visualization(memory_data)
    
    # Create connections
    for memory in dimension_memories:
        for connection in memory.connections:
            create_connection_visualization(memory.id, connection)
    
    print("# Loaded " + str(dimension_memories.size()) + " memories from rehab system #")

func load_memories_from_ultra_system():
    # Skip if no system
    if not memory_ultra_advanced:
        return
    
    # Clear existing memories first
    clear_visualizations()
    
    # Get memories for current device and dimension
    var device_memories = []
    
    if memory_ultra_advanced.memory_matrix.size() > current_device:
        var device_matrix = memory_ultra_advanced.memory_matrix[current_device]
        
        if device_matrix.has(current_dimension):
            device_memories = device_matrix[current_dimension]
    
    # Create visualization for each memory
    for memory in device_memories:
        # Convert to our format
        var memory_data = MemoryNodeData.new(
            memory.id,
            memory.word,
            memory.device_number,
            memory.dimension,
            []  # No tags in ultra system
        )
        
        # Adjust size based on power level
        memory_data.size = 1.0 + (memory.power_level / 10.0)
        
        # Create visualization
        create_memory_visualization(memory_data)
    
    # Create connections
    for memory in device_memories:
        for connection in memory.connections:
            # Find memory with this word
            for other_memory in device_memories:
                if other_memory.word == connection:
                    create_connection_visualization(memory.id, other_memory.id)
                    break
    
    print("# Loaded " + str(device_memories.size()) + " memories from device " + 
        str(current_device) + ", dimension " + str(current_dimension) + " #")

func clear_visualizations():
    # Remove all memory and connection visualizations
    for id in memory_nodes:
        memory_nodes[id].queue_free()
    
    for id in connection_nodes:
        connection_nodes[id].queue_free()
    
    memory_nodes.clear()
    connection_nodes.clear()

# Dimension & Device Control
func change_dimension(new_dimension):
    # Skip if same dimension
    if new_dimension == current_dimension:
        return
    
    # Validate dimension
    if new_dimension < 1 or new_dimension > 12:
        print("# Invalid dimension: " + str(new_dimension) + " #")
        return false
    
    # Check if this device has access to this dimension
    if memory_ultra_advanced:
        var valid_dimensions = memory_ultra_advanced.DEVICE_DIMENSIONS[current_device]
        if not valid_dimensions.has(new_dimension):
            print("# Device " + str(current_device) + " cannot access dimension " + 
                str(new_dimension) + " #")
            return false
    
    print("# Changing to dimension " + str(new_dimension) + " #")
    
    # Start transition
    is_transitioning = true
    transition_progress = 0.0
    
    var old_dimension = current_dimension
    current_dimension = new_dimension
    
    # Update UI
    dimension_label.text = "# DIMENSION " + str(current_dimension) + " #"
    dimension_label.add_color_override("font_color", DIMENSION_COLORS[current_dimension])
    
    # Update environment color
    var target_color = DIMENSION_COLORS[current_dimension].darkened(0.95)
    environment.background_color = target_color
    environment.fog_color = target_color
    
    # Load memories for new dimension
    if memory_rehab_system:
        load_memories_from_rehab_system()
    elif memory_ultra_advanced:
        load_memories_from_ultra_system()
    
    emit_signal("dimension_changed", current_device, current_dimension)
    
    return true

func change_device(new_device):
    # Skip if same device
    if new_device == current_device:
        return
    
    # Validate device
    if new_device < 0 or new_device > 3:
        print("# Invalid device: " + str(new_device) + " #")
        return false
    
    print("# Changing to device " + str(new_device) + " #")
    
    # Hide old device container, show new one
    device_containers[current_device].visible = false
    device_containers[new_device].visible = true
    
    var old_device = current_device
    current_device = new_device
    
    # Update UI
    device_label.text = "# DEVICE " + str(current_device) + " #"
    
    # If using ultra advanced system, change to a valid dimension
    if memory_ultra_advanced:
        var valid_dimensions = memory_ultra_advanced.DEVICE_DIMENSIONS[current_device]
        
        if not valid_dimensions.has(current_dimension):
            # Change to first valid dimension for this device
            change_dimension(valid_dimensions[0])
        else:
            # Reload memories for current dimension
            load_memories_from_ultra_system()
    
    emit_signal("dimension_changed", current_device, current_dimension)
    
    return true

func process_transition(delta):
    # Process dimension/device transition animation
    transition_progress += delta * 2
    
    if transition_progress >= 1.0:
        is_transitioning = false
        transition_progress = 0.0
    else:
        # Apply transition effects
        var effect = sin(transition_progress * PI)
        
        # Flash effect
        if environment:
            var base_color = DIMENSION_COLORS[current_dimension].darkened(0.95)
            environment.background_color = base_color.lightened(effect * 0.3)
            environment.glow_intensity = 0.2 + effect * 0.3
        
        # Camera shake
        if camera:
            var shake = Vector3(
                sin(transition_progress * 20) * effect * 0.1,
                cos(transition_progress * 25) * effect * 0.1,
                sin(transition_progress * 15) * effect * 0.1
            )
            camera.translation += shake

# Memory Management
func create_memory(content, tags = []):
    # Create a new memory in the current dimension
    
    if memory_rehab_system:
        var memory_id = memory_rehab_system.create_memory(content, current_dimension, tags)
        
        if memory_id:
            print("# Created memory: " + memory_id + " #")
            
            # Reload the memories
            load_memories_from_rehab_system()
            
            # Select the new memory
            select_memory(memory_id)
            
            emit_signal("memory_created", memory_id)
            
            return memory_id
    elif memory_ultra_advanced:
        # Create a word in the ultra advanced system
        var success = memory_ultra_advanced.add_memory_word(content, current_device, current_dimension)
        
        if success:
            print("# Created memory word: " + content + " #")
            
            # Reload the memories
            load_memories_from_ultra_system()
            
            emit_signal("memory_created", success.id)
            
            return success.id
    
    return null

func connect_memories(source_id, target_id):
    # Connect two memories
    
    if memory_rehab_system:
        var success = memory_rehab_system.connect_memories(source_id, target_id)
        
        if success:
            print("# Connected memories: " + source_id + " <-> " + target_id + " #")
            
            # Create visual connection
            create_connection_visualization(source_id, target_id)
            
            emit_signal("memory_connected", source_id, target_id)
            
            return true
    elif memory_ultra_advanced and memory_nodes.has(source_id) and memory_nodes.has(target_id):
        // Find the memory word objects
        var source_word = null
        var target_word = null
        
        for id in memory_nodes:
            if id == source_id:
                source_word = memory_nodes[id].name.replace("Memory_", "")
            if id == target_id:
                target_word = memory_nodes[id].name.replace("Memory_", "")
                
            if source_word and target_word:
                break
        
        var success = memory_ultra_advanced.connect_memory_words(source_word, target_word)
        
        if success:
            print("# Connected memory words: " + source_word + " <-> " + target_word + " #")
            
            // Create visual connection
            create_connection_visualization(source_id, target_id)
            
            emit_signal("memory_connected", source_id, target_id)
            
            return true
    
    return false

func select_memory(memory_id):
    // Deselect previous memory
    if selected_memory_id and memory_nodes.has(selected_memory_id):
        var node = memory_nodes[selected_memory_id]
        
        // Remove selection spotlight
        for child in node.get_children():
            if child is SpotLight and child.name == "SelectionLight":
                child.queue_free()
                break
        
        // Reset material
        var mesh = node.get_node("MemoryMesh")
        if mesh and mesh.material_override:
            mesh.material_override.emission_energy = 0.5
    
    // Update selected memory
    selected_memory_id = memory_id
    
    // Get memory data
    var memory_data = null
    
    if memory_rehab_system and selected_memory_id:
        memory_data = memory_rehab_system.get_memory(selected_memory_id)
    elif memory_ultra_advanced and selected_memory_id:
        // We don't have direct access to memory data in ultra mode,
        // so we'll just emit the signal with the ID
        pass
    
    // Emit signal with memory data
    emit_signal("memory_selected", selected_memory_id, memory_data)
    
    // Update status label
    if selected_memory_id:
        status_label.text = "# SELECTED: " + selected_memory_id + " #"
    else:
        status_label.text = "# READY #"
    
    return true

// Command Processing
func process_command(command):
    // Skip empty commands
    command = command.strip_edges()
    if command.empty():
        return null
    
    print("# Processing command: " + command + " #")
    
    // Add # prefix if not present
    if not command.begins_with("#"):
        command = "# " + command
    
    // Parse command and arguments
    var parts = command.split(" ", false)
    var cmd = parts[0].to_lower()
    
    // Get arguments
    var args = []
    if parts.size() > 1:
        args = parts.slice(1, parts.size() - 1)
    
    // Process command
    var result = null
    
    match cmd:
        "#", "##":
            // Create new memory with core tag
            if args.size() > 0:
                var content = PoolStringArray(args).join(" ")
                result = create_memory(content, ["##"])
                
        "#-":
            // Create new memory with fragment tag
            if args.size() > 0:
                var content = PoolStringArray(args).join(" ")
                result = create_memory(content, ["#-"])
                
        "#>":
            // Connect selected memory to another
            if selected_memory_id and args.size() > 0:
                var target_id = args[0]
                result = connect_memories(selected_memory_id, target_id)
                
        "#dimension", "#dim":
            // Change dimension
            if args.size() > 0 and args[0].is_valid_integer():
                var dim = int(args[0])
                result = change_dimension(dim)
                
        "#device", "#dev":
            // Change device
            if args.size() > 0 and args[0].is_valid_integer():
                var dev = int(args[0])
                result = change_device(dev)
                
        "#select":
            // Select memory by ID
            if args.size() > 0:
                result = select_memory(args[0])
                
        "#clear":
            // Clear all visualizations
            clear_visualizations()
            result = true
            
        "#refresh":
            // Reload memories
            if memory_rehab_system:
                load_memories_from_rehab_system()
            elif memory_ultra_advanced:
                load_memories_from_ultra_system()
            result = true
            
        "#physics":
            // Toggle physics simulation
            physics_enabled = !physics_enabled
            result = physics_enabled
            
        "#help":
            // Show help
            result = {
                "commands": [
                    "# <text> - Create core memory",
                    "#- <text> - Create fragment memory",
                    "#> <id> - Connect selected memory to another",
                    "#dimension <num> - Change dimension",
                    "#device <num> - Change device",
                    "#select <id> - Select memory by ID",
                    "#clear - Clear visualizations",
                    "#refresh - Reload memories",
                    "#physics - Toggle physics simulation",
                    "#help - Show this help"
                ]
            }
            
        _:
            // Default: create memory with content
            result = create_memory(command)
    
    // Update command input
    command_input.text = ""
    
    // Emit signal
    emit_signal("command_executed", command, result)
    
    return result

// Input Handling
func _input(event):
    // Handle keyboard navigation
    if event is InputEventKey and event.pressed:
        match event.scancode:
            KEY_W:  // Forward
                if event.control:
                    change_device((current_device + 1) % 4)
                else:
                    camera.translation.z -= 1
            KEY_S:  // Backward
                if event.control:
                    change_device((current_device - 1 + 4) % 4)
                else:
                    camera.translation.z += 1
            KEY_A:  // Left
                if event.control:
                    change_dimension(max(1, current_dimension - 1))
                else:
                    camera.translation.x -= 1
            KEY_D:  // Right
                if event.control:
                    change_dimension(min(12, current_dimension + 1))
                else:
                    camera.translation.x += 1
            KEY_Q:  // Up
                camera.translation.y += 1
            KEY_E:  // Down
                camera.translation.y -= 1
            KEY_R:  // Reset camera
                camera.translation = Vector3(0, 0, 15)
                camera.rotation = Vector3(0, 0, 0)
            KEY_TAB:  // Focus command input
                command_input.grab_focus()
            KEY_ESCAPE:  // Deselect
                select_memory(null)
    
    // Handle mouse wheel for zoom
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_WHEEL_UP:
            camera.translation.z -= 1
        elif event.button_index == BUTTON_WHEEL_DOWN:
            camera.translation.z += 1
    
    // Handle mouse rotation
    if event is InputEventMouseMotion and Input.is_mouse_button_pressed(BUTTON_RIGHT):
        var sensitivity = 0.005
        camera.rotation.y -= event.relative.x * sensitivity
        camera.rotation.x -= event.relative.y * sensitivity
        camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _on_command_entered(text):
    process_command(text)

func _on_memory_input_event(camera, event, click_position, click_normal, shape_idx, memory_id):
    if event is InputEventMouseButton and event.pressed:
        if event.button_index == BUTTON_LEFT:
            select_memory(memory_id)
        elif event.button_index == BUTTON_RIGHT and selected_memory_id and selected_memory_id != memory_id:
            // Connect selected memory to clicked memory
            connect_memories(selected_memory_id, memory_id)

// Example usage:
// var notepad = Notepad3DAdvanced.new()
// add_child(notepad)
// 
// // Connect to MemoryRehabSystem
// var rehab_system = MemoryRehabSystem.new()
// add_child(rehab_system)
// notepad.connect_memory_rehab_system(rehab_system)
// 
// // OR connect to MemoryUltraAdvanced
// var ultra_system = MemoryUltraAdvanced.new()
// add_child(ultra_system)
// notepad.connect_memory_ultra_advanced(ultra_system)