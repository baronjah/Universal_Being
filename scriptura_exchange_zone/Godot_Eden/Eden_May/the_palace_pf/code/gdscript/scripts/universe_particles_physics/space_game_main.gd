extends Node3D

# Space Game Main Controller
# This script sets up the space game and handles global inputs and events

# References to scale managers
var universe_controller

# UI references
var ui_canvas
var loading_screen
var debug_text
var tooltip

# Scene references
@export var universe_scene: PackedScene
@export var galaxy_scene: PackedScene 
@export var star_system_scene: PackedScene
@export var planet_scene: PackedScene
@export var element_scene: PackedScene

# Debug mode
@export var debug_mode: bool = true
@export var start_scale: String = "universe"  # universe, galaxy, star_system, planet, element

# Signals
signal game_loaded
signal scale_changed(from_scale, to_scale)
signal debug_info_updated(info)

func _ready():
    # Setup UI
    setup_ui()
    
    # Create the universe controller
    universe_controller = preload("res://code/gdscript/scripts/universe_particles_physics/universe_controller.gd").new()
    universe_controller.name = "UniverseController"
    add_child(universe_controller)
    
    # Connect signals
    universe_controller.connect("scale_changed", Callable(self, "_on_scale_changed"))
    universe_controller.connect("transition_started", Callable(self, "_on_transition_started"))
    universe_controller.connect("transition_completed", Callable(self, "_on_transition_completed"))
    
    # Set scene references
    universe_controller.universe_scene = universe_scene
    universe_controller.galaxy_scene = galaxy_scene
    universe_controller.star_system_scene = star_system_scene
    universe_controller.planet_scene = planet_scene
    universe_controller.element_scene = element_scene
    
    # Start at the selected scale
    start_at_scale(start_scale)
    
    # Setup debug info timer
    if debug_mode:
        var timer = Timer.new()
        timer.wait_time = 1.0
        timer.autostart = true
        timer.one_shot = false
        timer.connect("timeout", Callable(self, "_update_debug_info"))
        add_child(timer)
    
    emit_signal("game_loaded")

func _process(delta):
    # Handle global inputs
    if Input.is_action_just_pressed("toggle_debug"):
        toggle_debug()
    
    # Update tooltip for hoverable objects
    update_tooltip()

func _input(event):
    # Handle global input events
    if event.is_action_pressed("ui_cancel"):
        # Show pause menu
        show_pause_menu()
    
    if event.is_action_pressed("screenshot"):
        # Take a screenshot
        take_screenshot()

# Setup UI elements
func setup_ui():
    ui_canvas = CanvasLayer.new()
    ui_canvas.layer = 10
    add_child(ui_canvas)
    
    # Loading screen
    loading_screen = ColorRect.new()
    loading_screen.color = Color(0, 0, 0, 1)
    loading_screen.anchors_preset = Control.PRESET_FULL_RECT
    loading_screen.visible = false
    ui_canvas.add_child(loading_screen)
    
    var loading_label = Label.new()
    loading_label.text = "Loading..."
    loading_label.name = "LoadingLabel"
    loading_label.anchors_preset = Control.PRESET_CENTER
    loading_screen.add_child(loading_label)
    
    # Debug text
    if debug_mode:
        debug_text = Label.new()
        debug_text.text = "Debug Info"
        debug_text.name = "DebugText"
        debug_text.anchors_preset = Control.PRESET_TOP_LEFT
        debug_text.position = Vector2(10, 10)
        ui_canvas.add_child(debug_text)
    
    # Tooltip
    tooltip = Label.new()
    tooltip.name = "Tooltip"
    tooltip.anchors_preset = Control.PRESET_BOTTOM_CENTER
    tooltip.position = Vector2(0, -50)
    tooltip.visible = false
    ui_canvas.add_child(tooltip)

# Start the game at a specific scale
func start_at_scale(scale_name: String):
    var scale_level = get_scale_level_from_name(scale_name)
    
    if scale_level != -1:
        universe_controller.current_scale = scale_level
        universe_controller.activate_target_scale()
    else:
        push_error("Invalid scale name: " + scale_name)

# Get scale level enum from string
func get_scale_level_from_name(scale_name: String):
    match scale_name:
        "universe":
            return universe_controller.ScaleLevel.UNIVERSE
        "galaxy":
            return universe_controller.ScaleLevel.GALAXY
        "star_system":
            return universe_controller.ScaleLevel.STAR_SYSTEM
        "planet":
            return universe_controller.ScaleLevel.PLANET
        "element":
            return universe_controller.ScaleLevel.ELEMENT
    return -1

# Signal handlers
func _on_scale_changed(from_scale, to_scale):
    emit_signal("scale_changed", from_scale, to_scale)
    
    # Update UI for new scale
    update_ui_for_scale(to_scale)

func _on_transition_started(target_scale):
    # Show loading screen
    loading_screen.visible = true

func _on_transition_completed(new_scale):
    # Hide loading screen
    loading_screen.visible = false

# Update UI for specific scale
func update_ui_for_scale(scale):
    # Update UI elements based on current scale
    match scale:
        universe_controller.ScaleLevel.UNIVERSE:
            if tooltip:
                tooltip.text = "Click on a galaxy to zoom in"
        universe_controller.ScaleLevel.GALAXY:
            if tooltip:
                tooltip.text = "Click on a star to zoom in"
        universe_controller.ScaleLevel.STAR_SYSTEM:
            if tooltip:
                tooltip.text = "Click on a planet to zoom in"
        universe_controller.ScaleLevel.PLANET:
            if tooltip:
                tooltip.text = "Press E to enter element view"
        universe_controller.ScaleLevel.ELEMENT:
            if tooltip:
                tooltip.text = "Escape to return to planet view"

# Update tooltip when hovering over objects
func update_tooltip():
    var camera = get_viewport().get_camera_3d()
    if not camera:
        return
        
    var space_state = get_world_3d().direct_space_state
    var mouse_pos = get_viewport().get_mouse_position()
    var from = camera.project_ray_origin(mouse_pos)
    var to = from + camera.project_ray_normal(mouse_pos) * 1000
    
    var query = PhysicsRayQueryParameters3D.new()
    query.from = from
    query.to = to
    
    var result = space_state.intersect_ray(query)
    
    if result and result.collider:
        if result.collider.has_method("get_tooltip_text"):
            tooltip.text = result.collider.get_tooltip_text()
            tooltip.visible = true
            return
        
        # Default tooltips based on groups
        if result.collider.is_in_group("galaxies"):
            tooltip.text = "Galaxy"
            tooltip.visible = true
            return
            
        if result.collider.is_in_group("stars"):
            tooltip.text = "Star"
            tooltip.visible = true
            return
            
        if result.collider.is_in_group("planets"):
            tooltip.text = "Planet"
            tooltip.visible = true
            return
            
        if result.collider.is_in_group("elements"):
            tooltip.text = "Element"
            tooltip.visible = true
            return
    
    # No object under cursor
    tooltip.visible = false

# Toggle debug display
func toggle_debug():
    if debug_text:
        debug_text.visible = !debug_text.visible

# Update debug information
func _update_debug_info():
    if not debug_mode or not debug_text or not debug_text.visible:
        return
    
    var resource_manager = ResourceManager.get_instance()
    var stats = resource_manager.get_resource_stats()
    
    var debug_info = "FPS: %d | Scale: %s\n" % [Engine.get_frames_per_second(), get_scale_name(universe_controller.current_scale)]
    debug_info += "Lights: %d/%d | Particles: %d/%d\n" % [
        stats.lights.active, stats.lights.max,
        stats.particles.active, stats.particles.max
    ]
    debug_info += "Physics: %d/%d | Visible: %d/%d\n" % [
        stats.physics.active, stats.physics.max,
        stats.visible.active, stats.visible.max
    ]
    
    debug_text.text = debug_info
    emit_signal("debug_info_updated", debug_info)

# Get scale name from enum
func get_scale_name(scale_level):
    match scale_level:
        universe_controller.ScaleLevel.UNIVERSE:
            return "Universe"
        universe_controller.ScaleLevel.GALAXY:
            return "Galaxy"
        universe_controller.ScaleLevel.STAR_SYSTEM:
            return "Star System"
        universe_controller.ScaleLevel.PLANET:
            return "Planet"
        universe_controller.ScaleLevel.ELEMENT:
            return "Element"
    return "Unknown"

# Show pause menu
func show_pause_menu():
    # Implementation depends on your UI system
    pass

# Take a screenshot
func take_screenshot():
    var datetime = Time.get_datetime_dict_from_system()
    var filename = "user://screenshot_%04d%02d%02d_%02d%02d%02d.png" % [
        datetime.year, datetime.month, datetime.day, 
        datetime.hour, datetime.minute, datetime.second
    ]
    
    var image = get_viewport().get_texture().get_image()
    image.save_png(filename)
    
    print("Screenshot saved to: ", filename)