extends Spatial

class_name DimensionVisualizer

# Constants - Advanced color system with ghostly gradients and 3D effects
const DIMENSION_COLORS = [
    Color(0.2, 0.4, 0.8, 0.9), # Dimension 1 - Ethereal blue
    Color(0.3, 0.6, 0.9, 0.9), # Dimension 2 - Deeper azure
    Color(0.4, 0.7, 0.8, 0.9), # Dimension 3 - Teal essence
    Color(0.5, 0.8, 0.7, 0.9), # Dimension 4 - Seafoam spirit
    Color(0.6, 0.9, 0.6, 0.9), # Dimension 5 - Ghostly green
    Color(0.7, 0.9, 0.5, 0.9), # Dimension 6 - Spectral lime
    Color(0.8, 0.9, 0.4, 0.9), # Dimension 7 - Phantom yellow
    Color(0.9, 0.8, 0.3, 0.9), # Dimension 8 - Amber vision
    Color(0.9, 0.7, 0.2, 0.9), # Dimension 9 - Golden apparition
    Color(0.9, 0.6, 0.1, 0.9), # Dimension 10 - Ghostfire orange
    Color(0.9, 0.5, 0.0, 0.9), # Dimension 11 - Ember specter
    Color(1.0, 0.4, 0.0, 0.9)  # Dimension 12 - Flamecore phantom
]

# Secondary gradient colors for each dimension
const DIMENSION_GRADIENT_COLORS = [
    Color(0.1, 0.2, 0.6, 0.7), # Dimension 1 - Secondary
    Color(0.2, 0.3, 0.7, 0.7), # Dimension 2 - Secondary
    Color(0.3, 0.5, 0.6, 0.7), # Dimension 3 - Secondary
    Color(0.4, 0.6, 0.5, 0.7), # Dimension 4 - Secondary
    Color(0.5, 0.7, 0.4, 0.7), # Dimension 5 - Secondary
    Color(0.6, 0.7, 0.3, 0.7), # Dimension 6 - Secondary
    Color(0.7, 0.7, 0.2, 0.7), # Dimension 7 - Secondary
    Color(0.7, 0.6, 0.1, 0.7), # Dimension 8 - Secondary
    Color(0.7, 0.5, 0.1, 0.7), # Dimension 9 - Secondary
    Color(0.7, 0.4, 0.0, 0.7), # Dimension 10 - Secondary
    Color(0.7, 0.3, 0.0, 0.7), # Dimension 11 - Secondary
    Color(0.8, 0.2, 0.0, 0.7)  # Dimension 12 - Secondary
]

# Ghostly glow intensity for each dimension
const DIMENSION_GLOW = [
    0.3,  # Dimension 1
    0.35, # Dimension 2
    0.4,  # Dimension 3
    0.45, # Dimension 4
    0.5,  # Dimension 5
    0.55, # Dimension 6
    0.6,  # Dimension 7
    0.65, # Dimension 8
    0.7,  # Dimension 9
    0.75, # Dimension 10
    0.8,  # Dimension 11
    0.85  # Dimension 12
]

const POINTS_SHAPES = {
    "creation": "sphere",
    "exploration": "cube",
    "interaction": "cylinder",
    "challenge": "pyramid",
    "mastery": "star"
}

# Visualization options
export(bool) var auto_rotate = true
export(float) var rotation_speed = 0.5
export(float) var point_scale = 1.0
export(bool) var use_physics = false
export(String, "flat", "spiral", "cloud", "neural", "custom") var layout_mode = "spiral"
export(bool) var show_connections = true
export(int, 5, 100) var max_visible_points = 50
export(float, 0.1, 5.0) var animation_speed = 1.0

# Internal state
var current_dimension = 1
var dimension_progress = 0.0
var visualized_points = []
var visualized_categories = {}
var visualized_total = 0
var materials = {}
var meshes = {}
var point_instances = []
var camera_target = Vector3.ZERO
var noise = OpenSimplexNoise.new()
var animation_offset = 0.0

# References
var _account_manager = null

# 3D objects
var dimension_container
var point_container
var connection_container
var camera

func _ready():
    # Set up 3D scene
    setup_scene()
    
    # Connect to systems
    connect_to_systems()
    
    # Initialize noise for procedural motion
    noise.seed = randi()
    noise.octaves = 4
    noise.period = 20.0
    
    # Initial update
    update_visualization()

func _process(delta):
    # Auto-rotate if enabled
    if auto_rotate:
        dimension_container.rotate_y(delta * rotation_speed * 0.2)
    
    # Animate points if physics is not used
    if not use_physics:
        animate_points(delta)
    
    # Update animation offset
    animation_offset += delta * animation_speed

func setup_scene():
    # Create dimension container
    dimension_container = Spatial.new()
    add_child(dimension_container)
    
    # Create point container
    point_container = Spatial.new()
    dimension_container.add_child(point_container)
    
    # Create connection container
    connection_container = Spatial.new()
    dimension_container.add_child(connection_container)
    
    # Create camera
    var camera_pivot = Spatial.new()
    add_child(camera_pivot)
    
    camera = Camera.new()
    camera.translation = Vector3(0, 5, 10)
    camera.look_at(Vector3.ZERO, Vector3.UP)
    camera_pivot.add_child(camera)
    
    # Create materials for each dimension
    for i in range(DIMENSION_COLORS.size()):
        var material = SpatialMaterial.new()
        material.albedo_color = DIMENSION_COLORS[i]
        material.metallic = 0.7
        material.roughness = 0.2
        material.emission_enabled = true
        material.emission = DIMENSION_COLORS[i]
        material.emission_energy = 0.3
        materials[i + 1] = material
    
    # Create meshes for each point type
    create_point_meshes()

func create_point_meshes():
    # Sphere for creation points - ghostly flowing shape
    var sphere_mesh = SphereMesh.new()
    sphere_mesh.radius = 0.3
    sphere_mesh.height = 0.6
    sphere_mesh.radial_segments = 16
    sphere_mesh.rings = 8
    meshes["sphere"] = sphere_mesh

    # Cube for exploration points - spectral geometric form
    var cube_mesh = CubeMesh.new()
    cube_mesh.size = Vector3(0.5, 0.5, 0.5)
    meshes["cube"] = cube_mesh

    # Cylinder for interaction points - ethereal connection symbol
    var cylinder_mesh = CylinderMesh.new()
    cylinder_mesh.top_radius = 0.25
    cylinder_mesh.bottom_radius = 0.25
    cylinder_mesh.height = 0.6
    cylinder_mesh.radial_segments = 12
    cylinder_mesh.rings = 6
    meshes["cylinder"] = cylinder_mesh

    # Pyramid (prism) for challenge points - ascension form
    var prism_mesh = PrismMesh.new()
    prism_mesh.size = Vector3(0.5, 0.5, 0.5)
    meshes["pyramid"] = prism_mesh

    # Custom mesh for star (mastery) points - radiant achievement marker
    # In a real implementation, this would be a custom star mesh
    # For now, we'll use a specialized sphere with emissive material
    var star_mesh = SphereMesh.new()
    star_mesh.radius = 0.2
    star_mesh.height = 0.4
    star_mesh.radial_segments = 12
    star_mesh.rings = 6
    meshes["star"] = star_mesh

func connect_to_systems():
    # Connect to account manager
    if has_node("/root/SmartAccountManager") or get_node_or_null("/root/SmartAccountManager"):
        _account_manager = get_node("/root/SmartAccountManager")
        _account_manager.connect("points_updated", self, "_on_points_updated")
        _account_manager.connect("dimension_changed", self, "_on_dimension_changed")
        print("Connected to SmartAccountManager")
        
        # Initial values
        current_dimension = _account_manager.current_dimension
        dimension_progress = _account_manager.get_progress_to_next_dimension()
        
        # Load category points
        if _account_manager.points_categories:
            visualized_categories = _account_manager.points_categories.duplicate()
            
            for category in visualized_categories:
                visualized_total += visualized_categories[category]

func update_visualization():
    # Clear existing visualization
    clear_visualization()
    
    # Create new points based on current data
    create_points()
    
    # Update background/environment based on dimension
    update_environment()
    
    # Update camera position based on layout
    update_camera()

func clear_visualization():
    # Remove existing point instances
    for point in point_instances:
        if is_instance_valid(point):
            point.queue_free()
    
    # Clear arrays
    point_instances = []
    visualized_points = []
    
    # Clear connection lines
    for child in connection_container.get_children():
        child.queue_free()

func create_points():
    # Calculate total point count based on categories
    var total_points = min(max_visible_points, int(visualized_total / 100))
    total_points = max(total_points, 10) # Minimum 10 points
    
    # Create points for each category
    for category in visualized_categories:
        var category_points = int((visualized_categories[category] / visualized_total) * total_points)
        var shape = POINTS_SHAPES[category] if category in POINTS_SHAPES else "sphere"
        
        for i in range(category_points):
            create_point_instance(category, shape)
    
    # Calculate point positions based on layout
    position_points()
    
    # Create connections if enabled
    if show_connections:
        create_connections()

func create_point_instance(category, shape):
    # Create mesh instance with ghostly 3D gradient effect
    var mesh_instance = MeshInstance.new()
    mesh_instance.mesh = meshes[shape]

    # Create advanced material with ghostly effects
    var material = SpatialMaterial.new()

    # Get primary and secondary gradient colors
    var primary_color = DIMENSION_COLORS[current_dimension - 1]
    var secondary_color = DIMENSION_GRADIENT_COLORS[current_dimension - 1]
    var glow_intensity = DIMENSION_GLOW[current_dimension - 1]

    # Set material properties for ghostly appearance
    material.flags_transparent = true
    material.albedo_color = primary_color
    material.emission_enabled = true
    material.emission = primary_color
    material.emission_energy = glow_intensity
    material.rim_enabled = true
    material.rim = 0.5
    material.rim_tint = 0.5
    material.metallic = 0.7
    material.roughness = 0.2

    # Add vertex color support for gradient effect
    material.vertex_color_use_as_albedo = true

    # Adjust properties based on category for varied appearances
    match category:
        "creation":
            material.emission_energy = glow_intensity * 1.2
            material.roughness = 0.1
        "exploration":
            material.metallic = 0.5
            material.rim_tint = 0.7
        "interaction":
            material.emission_energy = glow_intensity * 0.9
            material.rim = 0.7
        "challenge":
            material.roughness = 0.4
            material.metallic = 0.9
        "mastery":
            material.emission_energy = glow_intensity * 1.5
            material.roughness = 0.0
            material.metallic = 1.0

    mesh_instance.material_override = material
    mesh_instance.scale = Vector3.ONE * point_scale

    # Apply a slight rotation for more visual interest
    mesh_instance.rotation_degrees = Vector3(
        randf() * 360.0,
        randf() * 360.0,
        randf() * 360.0
    )

    # Add to containers
    point_container.add_child(mesh_instance)
    point_instances.append(mesh_instance)

    # Add metadata
    mesh_instance.set_meta("category", category)
    mesh_instance.set_meta("primary_color", primary_color)
    mesh_instance.set_meta("secondary_color", secondary_color)
    mesh_instance.set_meta("glow_intensity", glow_intensity)

    # Add to visualization data
    visualized_points.append({
        "instance": mesh_instance,
        "category": category,
        "shape": shape,
        "position": Vector3.ZERO,
        "velocity": Vector3.ZERO,
        "created_at": OS.get_unix_time(),
        "primary_color": primary_color,
        "secondary_color": secondary_color,
        "glow_pulse_offset": randf() * TAU # Random offset for glow pulsing
    })

func position_points():
    match layout_mode:
        "flat":
            position_points_flat()
        "spiral":
            position_points_spiral()
        "cloud":
            position_points_cloud()
        "neural":
            position_points_neural()
        "custom":
            position_points_custom()
        _:
            position_points_spiral() # Default

func position_points_flat():
    var point_count = visualized_points.size()
    var radius = 5.0
    
    for i in range(point_count):
        var angle = (i / float(point_count)) * TAU
        var pos = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
        
        visualized_points[i]["position"] = pos
        visualized_points[i]["instance"].translation = pos

func position_points_spiral():
    var point_count = visualized_points.size()
    var height_scale = 2.0
    var radius_scale = 5.0
    var rotations = 2.0
    
    for i in range(point_count):
        var t = i / float(point_count)
        var angle = t * TAU * rotations
        var radius = radius_scale * (0.2 + 0.8 * t)
        var height = height_scale * (t - 0.5)
        
        var pos = Vector3(cos(angle) * radius, height, sin(angle) * radius)
        
        visualized_points[i]["position"] = pos
        visualized_points[i]["instance"].translation = pos

func position_points_cloud():
    var point_count = visualized_points.size()
    var radius = 5.0
    
    for i in range(point_count):
        var phi = acos(1 - 2 * (i / float(point_count)))
        var theta = TAU * ((1 + sqrt(5)) / 2) * i
        
        var pos = Vector3(
            radius * sin(phi) * cos(theta),
            radius * sin(phi) * sin(theta),
            radius * cos(phi)
        )
        
        visualized_points[i]["position"] = pos
        visualized_points[i]["instance"].translation = pos

func position_points_neural():
    # Group points by category
    var points_by_category = {}
    
    for point in visualized_points:
        var category = point["category"]
        if not category in points_by_category:
            points_by_category[category] = []
        
        points_by_category[category].append(point)
    
    # Position each category in its own cluster
    var angle_offset = 0
    var category_count = points_by_category.size()
    
    for category in points_by_category:
        var points = points_by_category[category]
        var point_count = points.size()
        
        var cluster_angle = angle_offset * TAU / category_count
        var cluster_center = Vector3(
            cos(cluster_angle) * 4.0,
            0,
            sin(cluster_angle) * 4.0
        )
        
        # Position points around cluster center
        for i in range(point_count):
            var radius = 2.0
            var point_angle = (i / float(point_count)) * TAU
            
            var offset = Vector3(
                cos(point_angle) * radius * 0.5,
                (i % 3) - 1.0,
                sin(point_angle) * radius * 0.5
            )
            
            var pos = cluster_center + offset
            
            points[i]["position"] = pos
            points[i]["instance"].translation = pos
        
        angle_offset += 1

func position_points_custom():
    # This would implement a custom layout algorithm
    # For now, we'll just use a variation of the spiral
    
    var point_count = visualized_points.size()
    
    for i in range(point_count):
        var t = i / float(point_count)
        var angle = t * TAU * 3.0
        
        var category = visualized_points[i]["category"]
        var category_offset = 0.0
        
        if category == "creation":
            category_offset = 2.0
        elif category == "exploration":
            category_offset = 1.0
        elif category == "interaction":
            category_offset = 0.0
        elif category == "challenge":
            category_offset = -1.0
        elif category == "mastery":
            category_offset = -2.0
        
        var pos = Vector3(
            cos(angle) * (3.0 + t * 2.0),
            category_offset + sin(angle * 2.0),
            sin(angle) * (3.0 + t * 2.0)
        )
        
        visualized_points[i]["position"] = pos
        visualized_points[i]["instance"].translation = pos

func create_connections():
    # Create connections between points of the same category
    var points_by_category = {}
    
    for i in range(visualized_points.size()):
        var point = visualized_points[i]
        var category = point["category"]
        
        if not category in points_by_category:
            points_by_category[category] = []
        
        points_by_category[category].append(i)
    
    # Create connections for each category
    for category in points_by_category:
        var indices = points_by_category[category]
        
        if indices.size() <= 1:
            continue
        
        # Connect points in sequence
        for i in range(indices.size() - 1):
            var from_idx = indices[i]
            var to_idx = indices[i + 1]
            
            create_connection_line(
                visualized_points[from_idx]["position"],
                visualized_points[to_idx]["position"],
                DIMENSION_COLORS[current_dimension - 1]
            )

func create_connection_line(from_pos, to_pos, color):
    # In a real implementation, this would create a 3D line
    # This is a simplified version using an immediate geometry node
    
    var immediate = ImmediateGeometry.new()
    connection_container.add_child(immediate)
    
    var material = SpatialMaterial.new()
    material.albedo_color = color
    material.flags_unshaded = true
    material.flags_transparent = true
    material.params_blend_mode = SpatialMaterial.BLEND_MODE_ADD
    
    immediate.material_override = material
    
    immediate.begin(Mesh.PRIMITIVE_LINE_STRIP)
    immediate.add_vertex(from_pos)
    immediate.add_vertex(to_pos)
    immediate.end()

func update_environment():
    # In a real implementation, this would update the environment
    # based on the current dimension
    pass

func update_camera():
    # Calculate camera target position based on visualization
    calculate_camera_target()
    
    # In a real implementation, this would smoothly update the camera position
    # For now, we'll just print the target
    print("Camera target: " + str(camera_target))

func calculate_camera_target():
    # Calculate the centroid of all points
    var sum = Vector3.ZERO
    var count = visualized_points.size()
    
    if count == 0:
        camera_target = Vector3.ZERO
        return
    
    for point in visualized_points:
        sum += point["position"]
    
    camera_target = sum / count

func animate_points(delta):
    # Animate each point with ghostly gradient and 3D effects
    for i in range(visualized_points.size()):
        var point = visualized_points[i]
        var pos = point["position"]
        var instance = point["instance"]

        # Get noise values for organic movement
        var noise_val = noise.get_noise_3d(
            pos.x * 0.1,
            pos.y * 0.1 + animation_offset,
            pos.z * 0.1
        )

        var noise_val2 = noise.get_noise_3d(
            pos.z * 0.12,
            pos.x * 0.12 + animation_offset * 0.7,
            pos.y * 0.12
        )

        # Create ghostly motion effect
        var offset = Vector3(
            noise_val * 0.2,
            sin(animation_offset * 2.0 + pos.x * 0.3) * 0.1,
            noise_val2 * 0.2
        )

        # Apply position with ethereal movement
        instance.translation = pos + offset

        # Animate material properties for ghostly gradient effect
        if instance.material_override:
            var material = instance.material_override
            var primary_color = point["primary_color"]
            var secondary_color = point["secondary_color"]
            var glow_intensity = instance.get_meta("glow_intensity")
            var glow_pulse = sin(animation_offset * 1.5 + point["glow_pulse_offset"]) * 0.3 + 0.7

            # Create color gradients and ghostly pulsing
            material.emission_energy = glow_intensity * glow_pulse

            # Add slight rotation for ethereal floating effect
            instance.rotate_y(delta * 0.2 * noise_val)
            instance.rotate_x(delta * 0.1 * noise_val2)

            # Scale pulsing for a breathing effect
            var scale_pulse = 1.0 + sin(animation_offset + point["glow_pulse_offset"]) * 0.05
            instance.scale = Vector3.ONE * point_scale * scale_pulse

        # Add trail effect for mastery and creation categories
        if point["category"] == "mastery" or point["category"] == "creation":
            # In a real implementation, would create ghost trail particles here
            pass

func _on_points_updated(total, category, amount):
    # Update category values
    if _account_manager:
        visualized_categories = _account_manager.points_categories.duplicate()
        
        visualized_total = 0
        for cat in visualized_categories:
            visualized_total += visualized_categories[cat]
    
    # Update visualization if significant change
    if amount > 100 or visualized_points.size() < 10:
        update_visualization()

func _on_dimension_changed(new_dimension):
    # Update dimension
    current_dimension = new_dimension
    
    # Update dimension progress
    if _account_manager:
        dimension_progress = _account_manager.get_progress_to_next_dimension()
    
    # Update visualization
    update_visualization()
    
    # Play dimension transition effect
    play_dimension_transition_effect()

func play_dimension_transition_effect():
    # In a real implementation, this would play a visual/sound effect
    # For now, just print a message
    print("VISUAL EFFECT: Dimension transition to " + str(current_dimension))

func set_layout_mode(mode):
    if mode in ["flat", "spiral", "cloud", "neural", "custom"]:
        layout_mode = mode
        update_visualization()
        return true
    
    return false

func set_auto_rotate(enabled):
    auto_rotate = enabled
    return true

func set_point_scale(scale):
    point_scale = clamp(scale, 0.1, 3.0)
    
    # Update existing points
    for point in point_instances:
        if is_instance_valid(point):
            point.scale = Vector3.ONE * point_scale
    
    return true

func set_use_physics(enabled):
    use_physics = enabled
    return true

func set_max_visible_points(max_points):
    max_visible_points = clamp(max_points, 5, 100)
    update_visualization()
    return true