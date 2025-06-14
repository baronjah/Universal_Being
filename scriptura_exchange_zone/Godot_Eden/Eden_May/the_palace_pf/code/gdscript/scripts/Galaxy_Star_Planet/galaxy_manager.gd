extends "../universe_particles_physics/scale_manager.gd"
class_name GalaxyManager

# Galaxy specific properties
var galaxy_data = null
var stars = []
var active_stars = []
var star_map = {}
var galaxy_radius: float = 100.0
var lod_distances = [20.0, 50.0, 100.0, 200.0]
var star_visibility_distance = 50.0
var max_active_stars = 200

# Camera and navigation
var camera_position = Vector3.ZERO
var view_frustum = []

# Scenes and resources
@export var star_scene: PackedScene
@export var nebula_scene: PackedScene
@export var dust_scene: PackedScene

# Visual components
var galaxy_center: Node3D
var galaxy_skybox: Sprite3D
var galaxy_core: Node3D
var nebula_particles: GPUParticles3D
var dust_particles: GPUParticles3D

# Star generation parameters
var star_count = 1000
var star_density = 0.5
var arm_count = 3
var arm_width = 0.3
var spiral_factor = 0.5

# Signals
signal star_hovered(star)
signal star_selected(star)

func _ready():
    scale_level = "galaxy"
    
    # Create galaxy center
    galaxy_center = Node3D.new()
    galaxy_center.name = "GalaxyCenter"
    add_child(galaxy_center)
    
    # Create galaxy core
    galaxy_core = Node3D.new()
    galaxy_core.name = "GalaxyCore"
    galaxy_center.add_child(galaxy_core)
    
    # Set up skybox
    setup_skybox()
    
    # Create containers for stars
    var star_container = Node3D.new()
    star_container.name = "StarContainer"
    galaxy_center.add_child(star_container)
    
    # Set up particles
    setup_particles()
    
    # Deactivate initially - will be activated by universe controller
    deactivate()

# Initialize the galaxy with data from the universe
func initialize(data):
    galaxy_data = data
    
    if galaxy_data is Dictionary:
        # Initialize from data dictionary
        if galaxy_data.has("seed"):
            setup_from_seed(galaxy_data.seed)
        
        if galaxy_data.has("radius"):
            galaxy_radius = galaxy_data.radius
        
        if galaxy_data.has("arm_count"):
            arm_count = galaxy_data.arm_count
            
        if galaxy_data.has("star_count"):
            star_count = galaxy_data.star_count
            
        if galaxy_data.has("spiral_factor"):
            spiral_factor = galaxy_data.spiral_factor
            
        if galaxy_data.has("arm_width"):
            arm_width = galaxy_data.arm_width
    else:
        # Initialize from node (e.g., GalaxySprite)
        var seed_value = randi()
        if data.has_method("get_galaxy_seed"):
            seed_value = data.get_galaxy_seed()
            
        setup_from_seed(seed_value)
        
        # Try to get other parameters
        if data.has_method("get_shader_parameters"):
            var params = data.get_shader_parameters()
            if params.has("u_arm_count"):
                arm_count = int(params.u_arm_count)
            if params.has("u_arm_width"):
                arm_width = params.u_arm_width
            if params.has("u_star_density"):
                star_density = params.u_star_density
                star_count = int(1000 * star_density)
            if params.has("u_swirl_amount"):
                spiral_factor = params.u_swirl_amount
    
    # Generate galaxy content
    generate_stars()
    generate_nebulae()
    
    # Setup skybox with galaxy appearance
    update_skybox()
    
    emit_signal("scale_ready_for_activation")

# Set up galaxy from a seed value
func setup_from_seed(seed_value):
    var rng = RandomNumberGenerator.new()
    rng.seed = seed_value
    
    # Randomize galaxy parameters
    arm_count = rng.randi_range(2, 6)
    arm_width = rng.randf_range(0.2, 0.5)
    spiral_factor = rng.randf_range(0.3, 0.7)
    star_density = rng.randf_range(0.3, 1.0)
    star_count = int(1000 * star_density)
    galaxy_radius = rng.randf_range(80.0, 120.0)

# Override activate method
func activate():
    is_active = true
    set_visibility(1.0)
    set_process(true)
    set_physics_process(true)
    
    # Register resources with resource manager
    var resource_manager = ResourceManager.get_instance()
    resource_manager.set_scale("galaxy")
    
    # Show galaxy components
    update_visual_components()
    
    emit_signal("scale_activated")

# Override deactivate method
func deactivate():
    is_active = false
    set_visibility(0.0)
    set_process(false)
    set_physics_process(false)
    
    # Unregister resources
    unregister_all_resources()
    
    emit_signal("scale_deactivated")

# Process function for galaxy scale
func update(delta):
    if not is_active:
        return
        
    # Update camera position
    update_camera_position()
    
    # Update active stars based on camera position
    update_active_stars()
    
    # Update visual effects
    update_visual_effects(delta)
    
    # Check for star selection
    if Input.is_action_just_pressed("select"):
        check_star_selection()

# Set up skybox for the galaxy
func setup_skybox():
    # Create skybox sprite
    galaxy_skybox = Sprite3D.new()
    galaxy_skybox.name = "GalaxySkybox"
    galaxy_skybox.pixel_size = 0.01
    galaxy_skybox.billboard = true
    galaxy_skybox.double_sided = false
    galaxy_skybox.no_depth_test = true
    galaxy_skybox.render_priority = -1
    
    # Create a placeholder texture initially
    var image = Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
    image.fill(Color(0, 0, 0, 1))
    var texture = ImageTexture.create_from_image(image)
    galaxy_skybox.texture = texture
    
    add_child(galaxy_skybox)

# Update skybox with galaxy appearance
func update_skybox():
    # In a real implementation, this would render the galaxy texture
    # For now, we'll just use a gradient
    var image = Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
    
    # Create a simple galaxy-like pattern
    for y in range(1024):
        for x in range(1024):
            var dx = x - 512
            var dy = y - 512
            var distance = sqrt(dx*dx + dy*dy) / 512.0
            var angle = atan2(dy, dx)
            
            # Create spiral pattern
            var spiral_offset = spiral_factor * distance * 10.0
            var arm_value = sin(angle * arm_count + spiral_offset)
            var arm_factor = pow((arm_value + 1.0) / 2.0, 1.0 / arm_width)
            
            # Brightness decreases with distance from center
            var center_brightness = max(0.0, 1.0 - distance * 1.5)
            
            # Combine factors
            var brightness = min(1.0, center_brightness + arm_factor * max(0.0, 1.0 - distance))
            brightness = pow(brightness, 1.5) * star_density  # Adjust contrast
            
            # Generate galaxy color (bluish)
            var color = Color(
                0.5 * brightness + 0.1 * center_brightness,
                0.7 * brightness + 0.1 * center_brightness,
                brightness,
                1.0
            )
            
            image.set_pixel(x, y, color)
    
    # Create texture from image
    var texture = ImageTexture.create_from_image(image)
    galaxy_skybox.texture = texture

# Set up particle systems
func setup_particles():
    # Create nebula particles
    nebula_particles = GPUParticles3D.new()
    nebula_particles.name = "NebulaParticles"
    nebula_particles.amount = 50
    nebula_particles.lifetime = 5.0
    nebula_particles.explosiveness = 0.0
    nebula_particles.randomness = 1.0
    galaxy_center.add_child(nebula_particles)
    
    # Create nebula material
    var nebula_material = ParticleProcessMaterial.new()
    nebula_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
    nebula_material.emission_sphere_radius = galaxy_radius * 0.5
    nebula_material.direction = Vector3(0, 0, 0)
    nebula_material.spread = 180.0
    nebula_material.gravity = Vector3(0, 0, 0)
    nebula_material.initial_velocity_min = 0.0
    nebula_material.initial_velocity_max = 0.2
    nebula_material.scale_min = 10.0
    nebula_material.scale_max = 30.0
    nebula_material.color = Color(0.5, 0.6, 1.0, 0.2)
    nebula_particles.process_material = nebula_material
    
    # Create dust particles
    dust_particles = GPUParticles3D.new()
    dust_particles.name = "DustParticles"
    dust_particles.amount = 100
    dust_particles.lifetime = 10.0
    dust_particles.explosiveness = 0.0
    dust_particles.randomness = 1.0
    galaxy_center.add_child(dust_particles)
    
    # Create dust material
    var dust_material = ParticleProcessMaterial.new()
    dust_material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
    dust_material.emission_sphere_radius = galaxy_radius * 0.8
    dust_material.direction = Vector3(0, 0, 0)
    dust_material.spread = 180.0
    dust_material.gravity = Vector3(0, 0, 0)
    dust_material.initial_velocity_min = 0.0
    dust_material.initial_velocity_max = 0.1
    dust_material.scale_min = 0.2
    dust_material.scale_max = 1.0
    dust_material.color = Color(1.0, 0.9, 0.7, 0.5)
    dust_particles.process_material = dust_material

# Generate stars for the galaxy
func generate_stars():
    # Clear existing stars
    for star in stars:
        if is_instance_valid(star):
            star.queue_free()
    stars.clear()
    active_stars.clear()
    
    # Create RNG with galaxy seed
    var rng = RandomNumberGenerator.new()
    if galaxy_data and galaxy_data is Dictionary and galaxy_data.has("seed"):
        rng.seed = galaxy_data.seed
    else:
        rng.seed = randi()
    
    # Generate stars with spiral galaxy pattern
    for i in range(star_count):
        # Generate star in spiral pattern
        var distance = rng.randf_range(0.1, 1.0)
        distance = pow(distance, 0.5)  # More stars toward center
        distance *= galaxy_radius
        
        var angle = rng.randf() * TAU
        var arm = floor(angle / TAU * arm_count)
        var arm_angle = arm * TAU / arm_count
        
        # Add spiral winding
        arm_angle += spiral_factor * distance / galaxy_radius * 2.0
        
        # Add random variation
        angle = arm_angle + rng.randf_range(-arm_width, arm_width) * (1.0 - distance / galaxy_radius * 0.5)
        
        # Calculate position
        var x = cos(angle) * distance
        var y = (rng.randf() - 0.5) * distance * 0.2
        var z = sin(angle) * distance
        
        # Create star
        create_star(Vector3(x, y, z), rng)

# Create an individual star
func create_star(position, rng):
    var star
    
    if star_scene:
        star = star_scene.instantiate()
    else:
        # Create a simple star representation
        star = Node3D.new()
        var mesh_instance = MeshInstance3D.new()
        mesh_instance.mesh = SphereMesh.new()
        mesh_instance.mesh.radius = 0.5
        mesh_instance.mesh.height = 1.0
        star.add_child(mesh_instance)
        
        # Add light
        var light = OmniLight3D.new()
        light.light_energy = 1.0
        light.omni_range = 5.0
        star.add_child(light)
    
    star.name = "Star_" + str(stars.size())
    star.position = position
    
    # Set random star properties
    var star_size = rng.randf_range(0.5, 2.5)
    var temperature = rng.randf_range(3000, 12000)  # Kelvin
    var star_color = get_star_color(temperature)
    
    # Apply properties
    star.scale = Vector3.ONE * star_size
    
    # Store star data
    var star_data = {
        "position": position,
        "size": star_size,
        "temperature": temperature,
        "color": star_color,
        "visible": false,
        "active": false,
    }
    
    # Store in star map
    star_map[star.get_instance_id()] = star_data
    
    # Add to stars array
    stars.append(star)
    
    # Add to star container, but don't make active yet
    var star_container = galaxy_center.get_node("StarContainer")
    star_container.add_child(star)
    star.visible = false
    
    # Add to stars group for easier access
    star.add_to_group("stars")
    
    return star

# Generate nebulae for the galaxy
func generate_nebulae():
    # This would generate nebulae objects in the galaxy
    # For now, we'll just use particles
    pass

# Update camera position
func update_camera_position():
    var viewport = get_viewport()
    if viewport:
        var camera = viewport.get_camera_3d()
        if camera:
            camera_position = camera.global_position
            view_frustum = camera.get_frustum()

# Update which stars are active based on camera position
func update_active_stars():
    # Update active stars based on distance and visibility
    var star_container = galaxy_center.get_node("StarContainer")
    
    # Step 1: Deactivate stars that are too far
    for i in range(active_stars.size() - 1, -1, -1):
        var star = active_stars[i]
        if not is_instance_valid(star):
            active_stars.remove_at(i)
            continue
            
        var star_data = star_map.get(star.get_instance_id())
        if not star_data:
            active_stars.remove_at(i)
            continue
            
        var distance = star.global_position.distance_to(camera_position)
        if distance > star_visibility_distance:
            # Deactivate this star
            unregister_object_with_resource_manager(star, "visible")
            star.visible = false
            star_data.visible = false
            star_data.active = false
            active_stars.remove_at(i)
    
    # Step 2: Find new stars to activate
    var stars_to_activate = []
    
    for star in stars:
        if not is_instance_valid(star):
            continue
            
        if active_stars.has(star):
            continue
            
        var star_data = star_map.get(star.get_instance_id())
        if not star_data:
            continue
            
        var distance = star.global_position.distance_to(camera_position)
        if distance <= star_visibility_distance:
            stars_to_activate.append(star)
    
    # Sort by distance (activate closest first)
    stars_to_activate.sort_custom(Callable(self, "sort_by_distance_to_camera"))
    
    # Activate up to max_active_stars
    var slots_available = max_active_stars - active_stars.size()
    var to_activate = min(slots_available, stars_to_activate.size())
    
    for i in range(to_activate):
        var star = stars_to_activate[i]
        if register_object_with_resource_manager(star, "visible"):
            var star_data = star_map[star.get_instance_id()]
            star.visible = true
            star_data.visible = true
            star_data.active = true
            active_stars.append(star)
            
            # Also register star light with resource manager
            var light = star.get_node_or_null("OmniLight3D")
            if light:
                # Priority based on star size/brightness
                var priority = int(star_data.size * 5)
                register_object_with_resource_manager(light, "light", priority)

# Custom sort function for stars by distance to camera
func sort_by_distance_to_camera(a, b):
    var a_data = star_map.get(a.get_instance_id())
    var b_data = star_map.get(b.get_instance_id())
    
    if not a_data or not b_data:
        return false
        
    var a_dist = a.global_position.distance_to(camera_position)
    var b_dist = b.global_position.distance_to(camera_position)
    
    return a_dist < b_dist

# Update visual effects (particles, etc.)
func update_visual_effects(delta):
    # Update particle system positions and settings
    if nebula_particles:
        nebula_particles.emitting = is_active
        
    if dust_particles:
        dust_particles.emitting = is_active
        
    # Update galaxy rotation
    if galaxy_center:
        galaxy_center.rotate_y(delta * 0.01)  # Slow rotation

# Check for star selection via raycast
func check_star_selection():
    var camera = get_viewport().get_camera_3d()
    if not camera:
        return
        
    var from = camera.project_ray_origin(get_viewport().get_mouse_position())
    var to = from + camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000
    
    var space_state = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.new()
    query.from = from
    query.to = to
    query.collision_mask = 2  # Assuming stars are on layer 2
    
    var result = space_state.intersect_ray(query)
    if result and result.collider:
        if result.collider.is_in_group("stars"):
            # Star selected
            emit_signal("star_selected", result.collider)

# Override update_visual_components
func update_visual_components():
    # Update visibility of all components based on transition state
    if galaxy_skybox:
        galaxy_skybox.modulate.a = visibility
        
    if nebula_particles:
        # Adjust particle opacity
        var material = nebula_particles.process_material
        var original_color = material.color
        material.color = Color(original_color.r, original_color.g, original_color.b, original_color.a * visibility)
        
    if dust_particles:
        # Adjust particle opacity
        var material = dust_particles.process_material
        var original_color = material.color
        material.color = Color(original_color.r, original_color.g, original_color.b, original_color.a * visibility)
    
    # Update active stars
    for star in active_stars:
        if is_instance_valid(star):
            # Fade in/out stars
            star.modulate.a = visibility
            
            # Also adjust star lights
            var light = star.get_node_or_null("OmniLight3D")
            if light:
                light.light_energy = visibility * star_map[star.get_instance_id()].size

# Get color based on star temperature
func get_star_color(temperature):
    # Approximate star color based on temperature
    var t = clamp(temperature, 3000, 12000) / 12000.0
    
    if t < 0.5:  # Cooler stars (red to yellow)
        return Color(1.0, t * 2.0, 0.0)
    else:  # Hotter stars (yellow to blue-white)
        return Color(1.0, 1.0, (t - 0.5) * 2.0)

# Unregister all resources when deactivating
func unregister_all_resources():
    # Unregister all active stars
    for star in active_stars:
        if is_instance_valid(star):
            unregister_object_with_resource_manager(star, "visible")
            
            # Also unregister star light
            var light = star.get_node_or_null("OmniLight3D")
            if light:
                unregister_object_with_resource_manager(light, "light")
    
    active_stars.clear()
    
    # Unregister particles
    if nebula_particles:
        unregister_object_with_resource_manager(nebula_particles, "particles")
        
    if dust_particles:
        unregister_object_with_resource_manager(dust_particles, "particles")