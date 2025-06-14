extends Node

class_name FluidSimulationDemo

# Reference to the simulation components
var simulation: FluidSimulationCore
var renderer2D: Fluid2DRenderer = null
var renderer3D: Fluid3DRenderer = null

# Demo properties
@export_category("Demo Setup")
@export var use_2d_mode: bool = true
@export var particle_count: int = 1000
@export var auto_run: bool = true
@export var simulation_speed: float = 1.0
@export var demo_type: int = 0  # 0=Water Tank, 1=Wave, 2=Splash, 3=Dam Break, 4=Fountain, 5=Vortex

# Interactive properties
@export_category("Interaction")
@export var enable_interaction: bool = true
@export var interaction_strength: float = 5.0
@export var click_to_splash: bool = true
@export var drag_to_move: bool = true
@export var use_physics_objects: bool = true

# Demo-specific settings
@export_category("Demo Settings")
@export var tank_size: Vector3 = Vector3(10, 5, 5)
@export var wave_amplitude: float = 0.5
@export var wave_frequency: float = 1.0
@export var splash_size: float = 0.5
@export var fountain_height: float = 5.0
@export var vortex_strength: float = 3.0

# Debug visualization
@export_category("Debug")
@export var show_velocities: bool = false
@export var show_forces: bool = false
@export var show_boundaries: bool = true
@export var show_performance: bool = true

# Internal variables
var _time: float = 0.0
var _fps_display: Label
var _particle_count_display: Label
var _simulation_time_display: Label
var _demo_running: bool = false
var _paused: bool = false
var _last_mouse_position: Vector2 = Vector2.ZERO
var _physics_objects = []
var _user_interaction_force: Vector3 = Vector3.ZERO
var _frame_times = []
var _last_click_time: float = 0.0

func _ready():
    # Initialize simulation
    simulation = FluidSimulationCore.new()
    add_child(simulation)
    
    # Initialize renderer based on mode
    if use_2d_mode:
        _init_2d_renderer()
    else:
        _init_3d_renderer()
    
    # Setup UI
    _setup_ui()
    
    # Start selected demo
    if auto_run:
        start_demo()

func _init_2d_renderer():
    renderer2D = Fluid2DRenderer.new()
    add_child(renderer2D)
    renderer2D.set_simulation(simulation)
    
    # Set simulation to 2D mode
    simulation.set_simulation_2d(true)
    
    # Adjust bounds to match screen size
    var viewport_size = get_viewport().get_visible_rect().size
    var aspect_ratio = viewport_size.x / viewport_size.y
    
    var bounds_y = 10.0  # Arbitrary unit size
    var bounds_x = bounds_y * aspect_ratio
    
    simulation.min_bounds = Vector3(-bounds_x/2, -bounds_y/2, -0.1)
    simulation.max_bounds = Vector3(bounds_x/2, bounds_y/2, 0.1)

func _init_3d_renderer():
    renderer3D = Fluid3DRenderer.new()
    add_child(renderer3D)
    renderer3D.set_simulation(simulation)
    
    # Configure camera for 3D view
    var camera = get_viewport().get_camera_3d()
    if camera:
        camera.global_position = Vector3(0, 5, 10)
        camera.look_at(Vector3(0, 0, 0))

func _setup_ui():
    # Create basic UI for debugging and controls
    var control = Control.new()
    control.anchor_right = 1.0
    control.anchor_bottom = 1.0
    add_child(control)
    
    # Performance display
    var performance_container = VBoxContainer.new()
    performance_container.anchor_left = 1.0
    performance_container.anchor_right = 1.0
    performance_container.offset_left = -150
    performance_container.offset_top = 10
    control.add_child(performance_container)
    
    _fps_display = Label.new()
    _fps_display.text = "FPS: 60"
    performance_container.add_child(_fps_display)
    
    _particle_count_display = Label.new()
    _particle_count_display.text = "Particles: 0"
    performance_container.add_child(_particle_count_display)
    
    _simulation_time_display = Label.new()
    _simulation_time_display.text = "Sim Time: 0.0ms"
    performance_container.add_child(_simulation_time_display)
    
    # Controls
    var button_container = HBoxContainer.new()
    button_container.anchor_top = 1.0
    button_container.anchor_bottom = 1.0
    button_container.anchor_right = 1.0
    button_container.offset_top = -50
    button_container.alignment = BoxContainer.ALIGNMENT_CENTER
    control.add_child(button_container)
    
    # Demo selector
    var demo_selector = OptionButton.new()
    demo_selector.add_item("Water Tank")
    demo_selector.add_item("Wave")
    demo_selector.add_item("Splash")
    demo_selector.add_item("Dam Break")
    demo_selector.add_item("Fountain")
    demo_selector.add_item("Vortex")
    demo_selector.selected = demo_type
    demo_selector.custom_minimum_size.x = 120
    button_container.add_child(demo_selector)
    demo_selector.connect("item_selected", _on_demo_selected)
    
    # Start button
    var start_button = Button.new()
    start_button.text = "Start"
    start_button.custom_minimum_size.x = 80
    button_container.add_child(start_button)
    start_button.connect("pressed", start_demo)
    
    # Reset button
    var reset_button = Button.new()
    reset_button.text = "Reset"
    reset_button.custom_minimum_size.x = 80
    button_container.add_child(reset_button)
    reset_button.connect("pressed", reset_demo)
    
    # Pause button
    var pause_button = Button.new()
    pause_button.text = "Pause"
    pause_button.custom_minimum_size.x = 80
    button_container.add_child(pause_button)
    pause_button.connect("pressed", toggle_pause)
    
    # 2D/3D toggle
    var mode_toggle = Button.new()
    mode_toggle.text = "2D/3D"
    mode_toggle.custom_minimum_size.x = 80
    button_container.add_child(mode_toggle)
    mode_toggle.connect("pressed", toggle_mode)
    
    # Hide UI if not showing performance
    if not show_performance:
        _fps_display.visible = false
        _particle_count_display.visible = false
        _simulation_time_display.visible = false

func _process(delta):
    if _paused:
        return
    
    # Update time counter
    _time += delta
    
    # Run simulation steps
    if _demo_running:
        var sim_start_time = Time.get_ticks_usec()
        
        # Run simulation at specified speed
        simulation.simulate_step(delta * simulation_speed)
        
        var sim_end_time = Time.get_ticks_usec()
        var sim_time_ms = (sim_end_time - sim_start_time) / 1000.0
        
        # Update performance displays
        if show_performance:
            # Track frame times for smoother FPS display
            _frame_times.append(1.0 / delta)
            if _frame_times.size() > 30:
                _frame_times.pop_front()
            
            var avg_fps = 0
            for fps in _frame_times:
                avg_fps += fps
            avg_fps /= _frame_times.size()
            
            _fps_display.text = "FPS: " + str(int(avg_fps))
            _particle_count_display.text = "Particles: " + str(simulation.get_particle_count())
            _simulation_time_display.text = "Sim Time: " + str(sim_time_ms).pad_decimals(1) + "ms"
    
    # Update demo-specific effects
    if _demo_running:
        match demo_type:
            1:  # Wave
                _update_wave_demo(delta)
            4:  # Fountain
                _update_fountain_demo(delta)
            5:  # Vortex
                _update_vortex_demo(delta)
    
    # Handle interactive physics objects
    if use_physics_objects and _physics_objects.size() > 0:
        _update_physics_objects(delta)
    
    # Apply user interaction forces
    if _user_interaction_force != Vector3.ZERO:
        simulation.add_force_field(
            _user_interaction_force, 
            particle_size * 10, 
            interaction_strength * 10, 
            1.0
        )
        _user_interaction_force = Vector3.ZERO

func _input(event):
    if not enable_interaction or not _demo_running:
        return
    
    # Handle mouse interaction
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            if click_to_splash and _time - _last_click_time > 0.2:
                _last_click_time = _time
                var click_pos = _get_world_position_from_mouse()
                _create_splash_at_position(click_pos, interaction_strength, splash_size)
        
        # Start dragging
        if event.button_index == MOUSE_BUTTON_LEFT:
            _last_mouse_position = event.position
    
    # Handle mouse drag
    elif event is InputEventMouseMotion and drag_to_move:
        if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
            var mouse_pos = _get_world_position_from_mouse()
            var force_dir = Vector3.ZERO
            
            if use_2d_mode:
                # In 2D, create a force in the direction of mouse movement
                var current_mouse_screen = event.position
                var movement = current_mouse_screen - _last_mouse_position
                _last_mouse_position = current_mouse_screen
                
                if movement.length_squared() > 4:  # Minimum movement threshold
                    force_dir = Vector3(movement.x, movement.y, 0).normalized()
                    _user_interaction_force = mouse_pos + force_dir * 0.2
            else:
                # In 3D, pull particles toward mouse position
                _user_interaction_force = mouse_pos

func _get_world_position_from_mouse():
    var mouse_pos = get_viewport().get_mouse_position()
    
    if use_2d_mode:
        # Convert 2D screen position to simulation coordinates
        var viewport_size = get_viewport().get_visible_rect().size
        var x_ratio = mouse_pos.x / viewport_size.x
        var y_ratio = mouse_pos.y / viewport_size.y
        
        var sim_width = simulation.max_bounds.x - simulation.min_bounds.x
        var sim_height = simulation.max_bounds.y - simulation.min_bounds.y
        
        var world_x = simulation.min_bounds.x + sim_width * x_ratio
        var world_y = simulation.min_bounds.y + sim_height * y_ratio
        
        return Vector3(world_x, world_y, 0)
    else:
        # Cast ray into 3D scene
        var camera = get_viewport().get_camera_3d()
        if camera:
            var from = camera.project_ray_origin(mouse_pos)
            var to = from + camera.project_ray_normal(mouse_pos) * 100
            
            # Intersect with a plane at y=0 for simplicity
            var plane = Plane(Vector3.UP, 0)
            var intersection = plane.intersects_ray(from, to - from)
            
            if intersection:
                return intersection
        
        return Vector3.ZERO

func _create_splash_at_position(position, strength, size):
    var particle_count = int(50 * size)
    simulation.create_splash(position, size, particle_count, strength)
    
    # Apply to 2D renderer if available
    if renderer2D:
        renderer2D.add_ripple_at_position(Vector2(position.x, position.y), strength, size)
    
    # Apply to 3D renderer if available
    if renderer3D:
        renderer3D.add_splash(position, strength, size)

func _update_wave_demo(delta):
    # Generate continuous waves
    var origin = Vector3(simulation.min_bounds.x, 0, 0)
    var direction = Vector3(1, 0, 0)
    
    simulation.apply_wave_generator(
        origin,
        direction,
        wave_amplitude,
        wave_frequency,
        _time
    )

func _update_fountain_demo(delta):
    # Continuous fountain from center bottom
    var fountain_pos = Vector3(0, simulation.min_bounds.y, 0)
    var spawn_interval = 0.05
    
    # Spawn particles periodically
    if int(_time / spawn_interval) > int((_time - delta) / spawn_interval):
        var particle_count = 5
        var positions = []
        var velocities = []
        
        for i in range(particle_count):
            var angle = randf() * TAU
            var radius = randf() * 0.2
            
            var pos = fountain_pos + Vector3(cos(angle) * radius, 0, sin(angle) * radius)
            var vel = Vector3(cos(angle) * 0.5, fountain_height, sin(angle) * 0.5)
            
            positions.append(pos)
            velocities.append(vel)
        
        simulation.create_particles(positions, velocities, particle_count)

func _update_vortex_demo(delta):
    # Create a vortex in the center
    var center = Vector3(0, 0, 0)
    var axis = Vector3(0, 1, 0)  # Vertical axis
    
    simulation.add_vortex(
        center,
        axis,
        tank_size.x * 0.8,
        vortex_strength,
        1.5
    )

func _update_physics_objects(delta):
    # Update positions of physics objects
    for obj in _physics_objects:
        # Apply gravity
        obj.velocity += simulation.gravity * delta
        
        # Update position
        obj.position += obj.velocity * delta
        
        # Check bounds collision
        for i in range(3):
            if obj.position[i] - obj.radius < simulation.min_bounds[i]:
                obj.position[i] = simulation.min_bounds[i] + obj.radius
                obj.velocity[i] *= -0.7  # Bounce with damping
            elif obj.position[i] + obj.radius > simulation.max_bounds[i]:
                obj.position[i] = simulation.max_bounds[i] - obj.radius
                obj.velocity[i] *= -0.7  # Bounce with damping
        
        # Interact with fluid particles
        simulation.add_force_field(
            obj.position,
            obj.radius * 2,
            obj.velocity.length() * 2,
            1.5
        )

func start_demo():
    # Clear existing particles
    simulation.clear_particles()
    
    # Reset time
    _time = 0.0
    
    # Remove any physics objects
    _physics_objects.clear()
    
    # Initialize selected demo
    match demo_type:
        0:  # Water Tank
            _init_water_tank_demo()
        1:  # Wave
            _init_wave_demo()
        2:  # Splash
            _init_splash_demo()
        3:  # Dam Break
            _init_dam_break_demo()
        4:  # Fountain
            _init_fountain_demo()
        5:  # Vortex
            _init_vortex_demo()
    
    _demo_running = true
    _paused = false

func reset_demo():
    start_demo()

func toggle_pause():
    _paused = !_paused

func toggle_mode():
    use_2d_mode = !use_2d_mode
    
    # Clean up existing renderer
    if renderer2D:
        renderer2D.queue_free()
        renderer2D = null
    
    if renderer3D:
        renderer3D.queue_free()
        renderer3D = null
    
    # Initialize new renderer
    if use_2d_mode:
        _init_2d_renderer()
    else:
        _init_3d_renderer()
    
    # Restart demo
    start_demo()

func _init_water_tank_demo():
    # Create a tank of water particles
    var tank_min = simulation.min_bounds + Vector3(1, 1, 1)
    var tank_max = Vector3(
        simulation.max_bounds.x - 1,
        tank_min.y + tank_size.y * 0.6,
        simulation.max_bounds.z - 1
    )
    
    var spacing = simulation.smooth_radius * 0.8
    simulation.create_fluid_cube(tank_min, tank_max, spacing)
    
    # Add a few physics objects if enabled
    if use_physics_objects:
        _add_physics_objects(3)

func _init_wave_demo():
    # Create a flat water surface
    var tank_min = Vector3(
        simulation.min_bounds.x + 1,
        0,
        simulation.min_bounds.z + 1
    )
    var tank_max = Vector3(
        simulation.max_bounds.x - 1,
        0.5,
        simulation.max_bounds.z - 1
    )
    
    var spacing = simulation.smooth_radius * 0.8
    simulation.create_fluid_cube(tank_min, tank_max, spacing)
    
    # If 2D mode, create a wave shape
    if use_2d_mode:
        var width = simulation.max_bounds.x - simulation.min_bounds.x - 2
        simulation.create_wave(
            Vector3(simulation.min_bounds.x + 1, 0, 0),
            width,
            wave_amplitude,
            3,  # 3 complete waves
            particle_count
        )

func _init_splash_demo():
    # Create a pool of water with a central splash
    var tank_min = Vector3(
        simulation.min_bounds.x + 1,
        simulation.min_bounds.y + 1,
        simulation.min_bounds.z + 1
    )
    var tank_max = Vector3(
        simulation.max_bounds.x - 1,
        tank_min.y + 1,
        simulation.max_bounds.z - 1
    )
    
    var spacing = simulation.smooth_radius * 0.8
    simulation.create_fluid_cube(tank_min, tank_max, spacing)
    
    # Create a splash in the center
    var center = Vector3(0, tank_max.y + 1, 0)
    simulation.create_splash(center, 1.0, 100, 3.0)

func _init_dam_break_demo():
    # Create a column of water on one side that will collapse
    var tank_width = simulation.max_bounds.x - simulation.min_bounds.x - 2
    var dam_position = simulation.min_bounds.x + tank_width * 0.3
    
    var dam_min = Vector3(
        simulation.min_bounds.x + 1,
        simulation.min_bounds.y + 1,
        simulation.min_bounds.z + 1
    )
    var dam_max = Vector3(
        dam_position,
        simulation.max_bounds.y - 1,
        simulation.max_bounds.z - 1
    )
    
    var spacing = simulation.smooth_radius * 0.8
    simulation.create_fluid_cube(dam_min, dam_max, spacing)

func _init_fountain_demo():
    # Start with empty tank, fountain will generate particles
    var tank_min = Vector3(
        simulation.min_bounds.x + 1,
        simulation.min_bounds.y + 1,
        simulation.min_bounds.z + 1
    )
    var tank_max = Vector3(
        simulation.max_bounds.x - 1,
        tank_min.y + 0.5,
        simulation.max_bounds.z - 1
    )
    
    var spacing = simulation.smooth_radius * 0.8
    simulation.create_fluid_cube(tank_min, tank_max, spacing, Vector3.ZERO)

func _init_vortex_demo():
    # Create a pool of water for the vortex
    var tank_min = Vector3(
        simulation.min_bounds.x + 1,
        simulation.min_bounds.y + 1,
        simulation.min_bounds.z + 1
    )
    var tank_max = Vector3(
        simulation.max_bounds.x - 1,
        tank_min.y + 2,
        simulation.max_bounds.z - 1
    )
    
    var spacing = simulation.smooth_radius * 0.8
    simulation.create_fluid_cube(tank_min, tank_max, spacing)
    
    # Add initial swirl velocity
    for p in simulation.particles:
        var to_center = Vector3.ZERO - p.position
        to_center.y = 0  # Keep horizontal
        var dist = to_center.length()
        
        if dist > 0.001:
            var tangent = Vector3(to_center.z, 0, -to_center.x).normalized()
            p.velocity = tangent * min(1.0, 3.0 / dist) * vortex_strength * 0.2

func _add_physics_objects(count):
    for i in range(count):
        var obj = {
            "position": Vector3(
                randf_range(simulation.min_bounds.x + 2, simulation.max_bounds.x - 2),
                simulation.max_bounds.y - 1,
                randf_range(simulation.min_bounds.z + 2, simulation.max_bounds.z - 2)
            ),
            "velocity": Vector3.ZERO,
            "radius": randf_range(0.3, 0.7),
            "mass": 1.0
        }
        
        _physics_objects.append(obj)

func _on_demo_selected(index):
    demo_type = index
    if _demo_running:
        start_demo()