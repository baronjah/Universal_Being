extends Node3D
class_name UniverseController

# Scale levels
enum ScaleLevel {
    UNIVERSE,    # View of multiple galaxies
    GALAXY,      # View inside a galaxy with stars
    STAR_SYSTEM, # View of planets orbiting a star
    PLANET,      # View of a planet's surface
    ELEMENT      # View of individual elements
}

# Current state
var current_scale: ScaleLevel = ScaleLevel.UNIVERSE
var target_scale: ScaleLevel = ScaleLevel.UNIVERSE
var transition_progress: float = 0.0
var is_transitioning: bool = false

# Scale managers
var universe_manager: Node
var galaxy_manager: Node
var star_system_manager: Node
var planet_manager: Node
var element_manager: Node

# Transition properties
var transition_speed: float = 1.0
var transition_target: Node = null
var transition_camera: Camera3D
var original_camera_position: Vector3
var target_camera_position: Vector3

# Resources
@export var universe_scene: PackedScene
@export var galaxy_scene: PackedScene
@export var star_system_scene: PackedScene
@export var planet_scene: PackedScene
@export var element_scene: PackedScene

# UI elements
var transition_overlay: ColorRect
var loading_indicator: Control

# Signals
signal scale_changed(from_scale, to_scale)
signal transition_started(target_scale)
signal transition_completed(new_scale)

func _ready():
    # Initialize transition overlay
    setup_transition_overlay()
    
    # Setup initial scale (Universe)
    setup_universe_scale()
    
    # Initialize camera
    transition_camera = get_viewport().get_camera_3d()
    if not transition_camera:
        transition_camera = Camera3D.new()
        add_child(transition_camera)
    
    # Setup resource management
    ResourceManager.initialize_universe_resources()

func _process(delta):
    if is_transitioning:
        process_transition(delta)
    else:
        # Normal update for current scale
        update_current_scale(delta)

# Setup the transition overlay for visual effects during transitions
func setup_transition_overlay():
    transition_overlay = ColorRect.new()
    transition_overlay.color = Color(0, 0, 0, 0)  # Start transparent
    transition_overlay.anchors_preset = Control.PRESET_FULL_RECT
    
    var overlay_material = ShaderMaterial.new()
    var shader = load("res://shaders/transition_overlay.gdshader")
    if shader:
        overlay_material.shader = shader
        transition_overlay.material = overlay_material
    
    var canvas_layer = CanvasLayer.new()
    canvas_layer.layer = 10  # High layer to be on top
    add_child(canvas_layer)
    canvas_layer.add_child(transition_overlay)
    transition_overlay.visible = false

# Initialize the universe scale
func setup_universe_scale():
    if universe_scene:
        universe_manager = universe_scene.instantiate()
        add_child(universe_manager)
    else:
        universe_manager = Node3D.new()
        universe_manager.name = "UniverseManager"
        add_child(universe_manager)
    
    current_scale = ScaleLevel.UNIVERSE
    
    # Initialize with placeholder galaxies if needed
    if universe_manager.get_child_count() == 0 and universe_manager.has_method("generate_galaxy_field"):
        universe_manager.generate_galaxy_field()

# Begin transition to a new scale
func transition_to_scale(target_scale_level: ScaleLevel, focus_object = null):
    if is_transitioning:
        return  # Already in transition
    
    if target_scale_level == current_scale:
        return  # Already at this scale
    
    # Initialize transition
    target_scale = target_scale_level
    is_transitioning = true
    transition_progress = 0.0
    
    # Store original camera position
    original_camera_position = transition_camera.global_position
    
    # Determine target position
    if focus_object:
        transition_target = focus_object
        var direction = transition_camera.global_position.direction_to(focus_object.global_position)
        var target_distance = get_scale_distance(target_scale_level)
        target_camera_position = focus_object.global_position - direction * target_distance
    else:
        # Default target if no focus object
        match target_scale_level:
            ScaleLevel.UNIVERSE:
                # Move back to universe view
                if universe_manager:
                    target_camera_position = Vector3(0, 100, 0)
            ScaleLevel.GALAXY:
                # Find nearest galaxy
                target_camera_position = find_nearest_galaxy_position()
            ScaleLevel.STAR_SYSTEM:
                # Find default star system
                target_camera_position = find_default_star_position()
            ScaleLevel.PLANET:
                # Find default planet
                target_camera_position = find_default_planet_position()
            ScaleLevel.ELEMENT:
                # Default element position
                target_camera_position = Vector3(0, 0, 5)
    
    # Load necessary resources for target scale
    load_scale_resources(target_scale_level)
    
    # Show transition overlay
    transition_overlay.visible = true
    
    # Emit signal
    emit_signal("transition_started", target_scale_level)

# Process the ongoing transition
func process_transition(delta):
    transition_progress += delta * transition_speed
    
    if transition_progress >= 1.0:
        complete_transition()
        return
    
    # Apply visual effects based on progress
    var curve = ease(transition_progress, 0.5)  # Smooth easing
    
    # Update camera
    if transition_camera:
        transition_camera.global_position = original_camera_position.lerp(target_camera_position, curve)
        
        # Add camera effects (e.g., FOV change, DoF)
        var original_fov = 75
        var target_fov = get_scale_fov(target_scale)
        transition_camera.fov = lerp(original_fov, target_fov, curve)
    
    # Update overlay
    var blur_amount = sin(transition_progress * PI) * 0.5
    var distortion = sin(transition_progress * PI) * 0.3
    var alpha = sin(transition_progress * PI) * 0.5
    
    # Apply shader effects
    if transition_overlay.material and transition_overlay.material is ShaderMaterial:
        transition_overlay.material.set_shader_parameter("blur_amount", blur_amount)
        transition_overlay.material.set_shader_parameter("distortion", distortion)
    
    transition_overlay.color.a = alpha

# Complete the transition to the new scale
func complete_transition():
    is_transitioning = false
    
    # Deactivate previous scale
    deactivate_current_scale()
    
    # Activate new scale
    activate_target_scale()
    
    # Hide transition overlay
    transition_overlay.visible = false
    
    # Update current scale
    current_scale = target_scale
    
    # Emit signal
    emit_signal("transition_completed", current_scale)

# Deactivate the current scale before transitioning
func deactivate_current_scale():
    match current_scale:
        ScaleLevel.UNIVERSE:
            if universe_manager && universe_manager.has_method("deactivate"):
                universe_manager.deactivate()
        ScaleLevel.GALAXY:
            if galaxy_manager && galaxy_manager.has_method("deactivate"):
                galaxy_manager.deactivate()
        ScaleLevel.STAR_SYSTEM:
            if star_system_manager && star_system_manager.has_method("deactivate"):
                star_system_manager.deactivate()
        ScaleLevel.PLANET:
            if planet_manager && planet_manager.has_method("deactivate"):
                planet_manager.deactivate()
        ScaleLevel.ELEMENT:
            if element_manager && element_manager.has_method("deactivate"):
                element_manager.deactivate()

# Activate the target scale after transitioning
func activate_target_scale():
    match target_scale:
        ScaleLevel.UNIVERSE:
            if universe_manager && universe_manager.has_method("activate"):
                universe_manager.activate()
        ScaleLevel.GALAXY:
            if not galaxy_manager:
                load_galaxy_manager()
            if galaxy_manager && galaxy_manager.has_method("activate"):
                galaxy_manager.activate()
        ScaleLevel.STAR_SYSTEM:
            if not star_system_manager:
                load_star_system_manager()
            if star_system_manager && star_system_manager.has_method("activate"):
                star_system_manager.activate()
        ScaleLevel.PLANET:
            if not planet_manager:
                load_planet_manager()
            if planet_manager && planet_manager.has_method("activate"):
                planet_manager.activate()
        ScaleLevel.ELEMENT:
            if not element_manager:
                load_element_manager()
            if element_manager && element_manager.has_method("activate"):
                element_manager.activate()

# Update the current active scale
func update_current_scale(delta):
    match current_scale:
        ScaleLevel.UNIVERSE:
            if universe_manager && universe_manager.has_method("update"):
                universe_manager.update(delta)
            
            # Check for galaxy selection to trigger transition
            if Input.is_action_just_pressed("select") and transition_camera:
                var selected_galaxy = find_galaxy_under_cursor()
                if selected_galaxy:
                    transition_to_scale(ScaleLevel.GALAXY, selected_galaxy)
        
        ScaleLevel.GALAXY:
            if galaxy_manager && galaxy_manager.has_method("update"):
                galaxy_manager.update(delta)
            
            # Check for star selection
            if Input.is_action_just_pressed("select") and transition_camera:
                var selected_star = find_star_under_cursor()
                if selected_star:
                    transition_to_scale(ScaleLevel.STAR_SYSTEM, selected_star)
                    
            # Check for return to universe
            if Input.is_action_just_pressed("ui_cancel"):
                transition_to_scale(ScaleLevel.UNIVERSE)
        
        ScaleLevel.STAR_SYSTEM:
            if star_system_manager && star_system_manager.has_method("update"):
                star_system_manager.update(delta)
            
            # Check for planet selection
            if Input.is_action_just_pressed("select") and transition_camera:
                var selected_planet = find_planet_under_cursor()
                if selected_planet:
                    transition_to_scale(ScaleLevel.PLANET, selected_planet)
                    
            # Check for return to galaxy
            if Input.is_action_just_pressed("ui_cancel"):
                transition_to_scale(ScaleLevel.GALAXY)
        
        ScaleLevel.PLANET:
            if planet_manager && planet_manager.has_method("update"):
                planet_manager.update(delta)
                
            # Check for element transition
            if Input.is_action_just_pressed("enter_elements"):
                transition_to_scale(ScaleLevel.ELEMENT)
                
            # Check for return to star system
            if Input.is_action_just_pressed("ui_cancel"):
                transition_to_scale(ScaleLevel.STAR_SYSTEM)
                
        ScaleLevel.ELEMENT:
            if element_manager && element_manager.has_method("update"):
                element_manager.update(delta)
                
            # Check for return to planet
            if Input.is_action_just_pressed("ui_cancel"):
                transition_to_scale(ScaleLevel.PLANET)

# Load necessary resources for the target scale
func load_scale_resources(scale_level: ScaleLevel):
    match scale_level:
        ScaleLevel.GALAXY:
            load_galaxy_manager()
        ScaleLevel.STAR_SYSTEM:
            load_star_system_manager()
        ScaleLevel.PLANET:
            load_planet_manager()
        ScaleLevel.ELEMENT:
            load_element_manager()

# Helper functions to load managers for different scales

func load_galaxy_manager():
    if galaxy_manager:
        return
        
    if galaxy_scene:
        galaxy_manager = galaxy_scene.instantiate()
    else:
        # Create a default manager if no scene is provided
        galaxy_manager = Node3D.new()
        galaxy_manager.name = "GalaxyManager"
    
    add_child(galaxy_manager)
    
    # Initialize with data from currently selected galaxy
    if galaxy_manager.has_method("initialize") and transition_target:
        galaxy_manager.initialize(transition_target)

func load_star_system_manager():
    if star_system_manager:
        return
        
    if star_system_scene:
        star_system_manager = star_system_scene.instantiate()
    else:
        star_system_manager = Node3D.new()
        star_system_manager.name = "StarSystemManager"
    
    add_child(star_system_manager)
    
    # Initialize with data from currently selected star
    if star_system_manager.has_method("initialize") and transition_target:
        star_system_manager.initialize(transition_target)

func load_planet_manager():
    if planet_manager:
        return
        
    if planet_scene:
        planet_manager = planet_scene.instantiate()
    else:
        planet_manager = Node3D.new()
        planet_manager.name = "PlanetManager"
    
    add_child(planet_manager)
    
    # Initialize with data from currently selected planet
    if planet_manager.has_method("initialize") and transition_target:
        planet_manager.initialize(transition_target)

func load_element_manager():
    if element_manager:
        return
        
    if element_scene:
        element_manager = element_scene.instantiate()
    else:
        element_manager = load("res://code/gdscript/scripts/elements_shapes_projection/element_manager.gd").new()
        element_manager.name = "ElementManager"
    
    add_child(element_manager)
    
    # Initialize with data from current planet
    if element_manager.has_method("initialize") and planet_manager:
        var planet_data = planet_manager.get_planet_data()
        element_manager.initialize(planet_data)

# Helper functions to find objects at different scales

func find_galaxy_under_cursor():
    var from = transition_camera.project_ray_origin(get_viewport().get_mouse_position())
    var to = from + transition_camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000
    
    var space_state = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.new()
    query.from = from
    query.to = to
    query.collision_mask = 1
    
    var result = space_state.intersect_ray(query)
    if result and result.collider:
        if result.collider.is_in_group("galaxies"):
            return result.collider
    
    return null

func find_star_under_cursor():
    var from = transition_camera.project_ray_origin(get_viewport().get_mouse_position())
    var to = from + transition_camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000
    
    var space_state = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.new()
    query.from = from
    query.to = to
    query.collision_mask = 2  # Assuming stars are on layer 2
    
    var result = space_state.intersect_ray(query)
    if result and result.collider:
        if result.collider.is_in_group("stars"):
            return result.collider
    
    return null

func find_planet_under_cursor():
    var from = transition_camera.project_ray_origin(get_viewport().get_mouse_position())
    var to = from + transition_camera.project_ray_normal(get_viewport().get_mouse_position()) * 1000
    
    var space_state = get_world_3d().direct_space_state
    var query = PhysicsRayQueryParameters3D.new()
    query.from = from
    query.to = to
    query.collision_mask = 4  # Assuming planets are on layer 3
    
    var result = space_state.intersect_ray(query)
    if result and result.collider:
        if result.collider.is_in_group("planets"):
            return result.collider
    
    return null

# Helper functions to get scale-specific parameters

func get_scale_distance(scale_level: ScaleLevel) -> float:
    match scale_level:
        ScaleLevel.UNIVERSE:
            return 500.0
        ScaleLevel.GALAXY:
            return 100.0
        ScaleLevel.STAR_SYSTEM:
            return 30.0
        ScaleLevel.PLANET:
            return 10.0
        ScaleLevel.ELEMENT:
            return 3.0
    return 10.0

func get_scale_fov(scale_level: ScaleLevel) -> float:
    match scale_level:
        ScaleLevel.UNIVERSE:
            return 70.0
        ScaleLevel.GALAXY:
            return 65.0
        ScaleLevel.STAR_SYSTEM:
            return 60.0
        ScaleLevel.PLANET:
            return 55.0
        ScaleLevel.ELEMENT:
            return 45.0
    return 70.0

func find_nearest_galaxy_position() -> Vector3:
    # Default to a position above the universe
    var position = Vector3(0, 100, 0)
    
    # Look for galaxies to find a good position
    var galaxies = get_tree().get_nodes_in_group("galaxies")
    if galaxies.size() > 0:
        var nearest_galaxy = galaxies[0]
        position = nearest_galaxy.global_position + Vector3(0, 0, 50)
    
    return position

func find_default_star_position() -> Vector3:
    var position = Vector3(0, 0, 50)
    
    # Look for stars
    var stars = get_tree().get_nodes_in_group("stars")
    if stars.size() > 0:
        var default_star = stars[0]
        position = default_star.global_position + Vector3(0, 10, 20)
    
    return position

func find_default_planet_position() -> Vector3:
    var position = Vector3(0, 0, 20)
    
    # Look for planets
    var planets = get_tree().get_nodes_in_group("planets")
    if planets.size() > 0:
        var default_planet = planets[0]
        position = default_planet.global_position + Vector3(0, 5, 10)
    
    return position