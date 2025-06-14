extends CharacterBody3D

class_name JSHPlayerControllerExtended

# ----- MOVEMENT MODES -----
enum MovementMode {
    WALKING,
    FLYING,
    SPECTATOR,
    WORD_SURFING,
    DREAM_NAVIGATION,
    TIME_STREAM
}

# ----- MOVEMENT SETTINGS -----
@export_category("Movement Settings")
@export var walk_speed: float = 5.0
@export var run_speed: float = 10.0
@export var flight_speed: float = 15.0
@export var dream_speed: float = 8.0
@export var time_stream_speed: float = 20.0
@export var acceleration: float = 8.0
@export var deceleration: float = 10.0
@export var jump_height: float = 2.0
@export var air_control: float = 0.3

# ----- CAMERA SETTINGS -----
@export_category("Camera Settings")
@export var mouse_sensitivity: float = 0.2
@export var camera_smoothing: float = 10.0
@export var head_bob_enabled: bool = true
@export var head_bob_amount: float = 0.05
@export var head_bob_speed: float = 10.0

# ----- ENERGY SETTINGS -----
@export_category("Energy Settings")
@export var max_energy: float = 100.0
@export var energy_regen_rate: float = 5.0  # Per second
@export var flight_energy_cost: float = 10.0  # Per second
@export var shift_energy_cost: float = 20.0  # Per shift
@export var word_surf_energy_cost: float = 5.0  # Per second
@export var time_stream_energy_cost: float = 15.0  # Per second

# ----- TIME CONTROL SETTINGS -----
@export_category("Time Control Settings")
@export var movement_time_factor: float = 0.5  # How much movement advances time
@export var time_stream_boost: float = 3.0  # Time acceleration in time stream mode
@export var dream_time_dilation: float = 0.5  # Time flows slower in dreams
@export var max_time_speed: float = 5.0  # Maximum time acceleration

# ----- COMPONENT REFERENCES -----
@export var camera_mount_path: NodePath
@export var camera_path: NodePath
@export var interaction_ray_path: NodePath
@export var flight_particles_path: NodePath
@export var time_stream_particles_path: NodePath
@export var dream_particles_path: NodePath
@export var effects_player_path: NodePath

# ----- EXTERNAL SYSTEM REFERENCES -----
var words_in_space: Node  # Reference to word visualization system
var gui: Node  # Reference to GUI system
var time_progression_system: Node  # Reference to time system
var game_controller: Node  # Reference to game controller

# ----- COMPONENT REFERENCES -----
@onready var camera_mount: Node3D = get_node_or_null(camera_mount_path)
@onready var camera: Camera3D = get_node_or_null(camera_path)
@onready var interaction_ray: RayCast3D = get_node_or_null(interaction_ray_path)
@onready var flight_particles: GPUParticles3D = get_node_or_null(flight_particles_path)
@onready var time_stream_particles: GPUParticles3D = get_node_or_null(time_stream_particles_path)
@onready var dream_particles: GPUParticles3D = get_node_or_null(dream_particles_path)
@onready var effects_player: AnimationPlayer = get_node_or_null(effects_player_path)

# ----- MOVEMENT STATE -----
var current_mode: MovementMode = MovementMode.WALKING
var previous_mode: MovementMode = MovementMode.WALKING
var is_shifting_mode: bool = false
var mode_transition_progress: float = 0.0
var mode_transition_duration: float = 0.5
var snap_vector: Vector3 = Vector3.DOWN
var direction: Vector3 = Vector3.ZERO
var h_velocity: Vector3 = Vector3.ZERO
var movement_enabled: bool = true

# ----- ENERGY STATE -----
var energy: float = 100.0
var last_energy_use_time: float = 0.0
var energy_depleted: bool = false

# ----- REALITY STATE -----
var current_reality: String = "physical"
var is_shifting_reality: bool = false
var reality_transition_progress: float = 0.0
var reality_transition_duration: float = 1.0
var target_reality: String = ""

# ----- WORD INTERACTION STATE -----
var selected_word_id: String = ""
var connected_words: Array = []
var current_surf_word_id: String = ""
var next_surf_word_id: String = ""
var surfing_progress: float = 0.0
var surf_speed: float = 2.0  # Seconds to travel between words

# ----- TIME CONTROL STATE -----
var time_multiplier: float = 1.0
var is_advancing_time: bool = false
var is_rewinding_time: bool = false
var time_stream_direction: Vector3 = Vector3.ZERO
var dream_state_active: bool = false
var last_movement_time: float = 0.0
var last_position: Vector3 = Vector3.ZERO
var distance_moved: float = 0.0

# ----- SIGNALS -----
signal mode_changed(old_mode, new_mode)
signal reality_shifted(old_reality, new_reality)
signal word_selected(word_id)
signal energy_changed(current, max)
signal player_moved(distance, velocity)
signal time_advanced(amount)

# ----- INITIALIZATION -----
func _ready():
    # Initialize components
    if camera_mount == null and has_node("CameraMount"):
        camera_mount = $CameraMount
    
    if camera == null and camera_mount and camera_mount.has_node("Camera3D"):
        camera = camera_mount.get_node("Camera3D")
    
    if interaction_ray == null and camera and camera.has_node("InteractionRay"):
        interaction_ray = camera.get_node("InteractionRay")
    
    # Configure input
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    
    # Initialize state
    energy = max_energy
    last_position = global_position
    last_movement_time = Time.get_ticks_msec() / 1000.0
    
    # Initialize effects
    setup_visual_effects()

# ----- INPUT HANDLING -----
func _input(event):
    if !movement_enabled:
        return
    
    # Mouse look
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        if camera_mount:
            # Rotate camera mount (left/right)
            camera_mount.rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
            
            # Rotate camera (up/down)
            if camera:
                var new_rotation = camera.rotation.x - deg_to_rad(event.relative.y * mouse_sensitivity)
                camera.rotation.x = clamp(new_rotation, deg_to_rad(-89), deg_to_rad(89))
    
    # Toggle mouse capture
    if event.is_action_pressed("ui_cancel"):
        if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        else:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# ----- PHYSICS PROCESS -----
func _physics_process(delta):
    if !movement_enabled:
        return
    
    # Handle energy regeneration
    process_energy(delta)
    
    # Process mode transition
    if is_shifting_mode:
        process_mode_transition(delta)
    
    # Process reality transition
    if is_shifting_reality:
        process_reality_transition(delta)
    
    # Process movement based on current mode
    match current_mode:
        MovementMode.WALKING:
            process_walking(delta)
        MovementMode.FLYING:
            process_flying(delta)
        MovementMode.SPECTATOR:
            process_spectator(delta)
        MovementMode.WORD_SURFING:
            process_word_surfing(delta)
        MovementMode.DREAM_NAVIGATION:
            process_dream_navigation(delta)
        MovementMode.TIME_STREAM:
            process_time_stream(delta)
    
    # Move and slide
    if current_mode != MovementMode.WORD_SURFING:
        move_and_slide()
    
    # Calculate movement for time advancement
    calculate_movement(delta)
    
    # Update visual effects
    update_visual_effects(delta)
    
    # Check for word interaction
    process_word_interaction()

# ----- MOVEMENT PROCESSING -----
func process_walking(delta):
    # Add gravity when in air
    if not is_on_floor():
        velocity.y -= gravity * delta
    else:
        snap_vector = Vector3.DOWN
    
    # Handle jumping
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = sqrt(2.0 * gravity * jump_height)
        snap_vector = Vector3.ZERO
    
    # Get input direction
    direction = get_movement_direction()
    
    # Calculate target speed
    var target_speed = run_speed if Input.is_action_pressed("run") else walk_speed
    
    # Calculate target velocity
    var target_velocity = direction * target_speed
    
    # Smoothly interpolate to target velocity
    h_velocity = h_velocity.lerp(target_velocity, delta * (acceleration if direction.length() > 0 else deceleration))
    
    # Apply horizontal velocity
    velocity.x = h_velocity.x
    velocity.z = h_velocity.z
    
    # Process head bob
    if head_bob_enabled and is_on_floor() and direction.length() > 0:
        process_head_bob(delta, h_velocity.length() / walk_speed)

func process_flying(delta):
    # Get input direction (including vertical)
    var fly_direction = get_movement_direction()
    
    # Add vertical movement
    if Input.is_action_pressed("jump"):
        fly_direction.y += 1.0
    if Input.is_action_pressed("crouch"):
        fly_direction.y -= 1.0
    
    # Calculate target speed
    var target_speed = flight_speed * (1.5 if Input.is_action_pressed("run") else 1.0)
    
    # Calculate target velocity
    var target_velocity = fly_direction * target_speed
    
    # Smoothly interpolate to target velocity
    velocity = velocity.lerp(target_velocity, delta * (acceleration if fly_direction.length() > 0 else deceleration))
    
    # Consume energy
    if velocity.length() > 0.1:
        _consume_energy(flight_energy_cost * delta)

func process_spectator(delta):
    # Similar to flying but without energy cost
    var spectate_direction = get_movement_direction()
    
    # Add vertical movement
    if Input.is_action_pressed("jump"):
        spectate_direction.y += 1.0
    if Input.is_action_pressed("crouch"):
        spectate_direction.y -= 1.0
    
    # Calculate target velocity
    var target_velocity = spectate_direction * flight_speed
    
    # Smoothly interpolate to target velocity
    velocity = velocity.lerp(target_velocity, delta * (acceleration if spectate_direction.length() > 0 else deceleration))

func process_word_surfing(delta):
    if current_surf_word_id == "" or next_surf_word_id == "":
        # Find a word to surf if none selected
        find_surfing_path()
        return
    
    # Check if we still have the words
    if words_in_space == null or !words_in_space.has_method("get_word_position"):
        return
    
    # Get word positions
    var current_word_pos = words_in_space.get_word_position(current_surf_word_id)
    var next_word_pos = words_in_space.get_word_position(next_surf_word_id)
    
    # Update surfing progress
    surfing_progress += delta * surf_speed
    
    if surfing_progress >= 1.0:
        # Move to next word
        global_position = next_word_pos
        
        # Make next word the current word
        current_surf_word_id = next_surf_word_id
        
        # Find new next word
        find_next_surf_word()
        
        # Reset progress
        surfing_progress = 0.0
        
        # Select the new word
        _select_word(current_surf_word_id)
    else:
        # Interpolate between words
        global_position = current_word_pos.lerp(next_word_pos, ease(surfing_progress, -2.0))
        
        # Look in movement direction
        var look_pos = next_word_pos
        if look_pos != global_position:
            camera_mount.look_at(look_pos, Vector3.UP)
    
    # Consume energy
    _consume_energy(word_surf_energy_cost * delta)

func process_dream_navigation(delta):
    # Special movement for dream state
    var dream_direction = get_movement_direction()
    
    # Add vertical movement with less restriction
    if Input.is_action_pressed("jump"):
        dream_direction.y += 1.0
    if Input.is_action_pressed("crouch"):
        dream_direction.y -= 1.0
    
    # Calculate target speed (slower in dreams)
    var target_speed = dream_speed * (1.2 if Input.is_action_pressed("run") else 1.0)
    
    # Add subtle drift based on time
    var drift = Vector3(
        sin(Time.get_ticks_msec() / 1000.0 * 0.5) * 0.1,
        cos(Time.get_ticks_msec() / 1000.0 * 0.3) * 0.05,
        sin(Time.get_ticks_msec() / 1000.0 * 0.7) * 0.1
    )
    
    # Calculate target velocity with drift
    var target_velocity = (dream_direction + drift) * target_speed
    
    # Smoothly interpolate to target velocity with more smoothing
    velocity = velocity.lerp(target_velocity, delta * (acceleration * 0.7 if dream_direction.length() > 0 else deceleration * 0.7))
    
    # Apply time dilation effect
    if time_progression_system:
        time_progression_system.time_multiplier = dream_time_dilation

func process_time_stream(delta):
    # Calculate direction based on camera
    time_stream_direction = -camera_mount.transform.basis.z
    
    # Get input for forward/backward time flow
    var time_direction = 0.0
    if Input.is_action_pressed("move_forward"):
        time_direction = 1.0  # Forward in time
    elif Input.is_action_pressed("move_backward"):
        time_direction = -1.0  # Backward in time
    
    # Apply time flow
    if time_progression_system and time_direction != 0.0:
        var time_speed = time_stream_boost * abs(time_direction)
        time_progression_system.time_multiplier = time_speed * (1.0 if time_direction > 0 else -1.0)
        is_advancing_time = time_direction > 0
        is_rewinding_time = time_direction < 0
    else:
        time_progression_system.time_multiplier = 1.0
        is_advancing_time = false
        is_rewinding_time = false
    
    # Movement in time stream
    var lateral_direction = Vector3.ZERO
    if Input.is_action_pressed("move_right"):
        lateral_direction += camera_mount.transform.basis.x
    if Input.is_action_pressed("move_left"):
        lateral_direction -= camera_mount.transform.basis.x
    if Input.is_action_pressed("jump"):
        lateral_direction += Vector3.UP
    if Input.is_action_pressed("crouch"):
        lateral_direction -= Vector3.UP
    
    if lateral_direction.length() > 0:
        lateral_direction = lateral_direction.normalized()
    
    # Calculate target velocity
    var forward_speed = time_stream_speed * abs(time_direction)
    var lateral_speed = time_stream_speed * 0.5
    
    var target_velocity = (time_stream_direction * forward_speed * time_direction) + (lateral_direction * lateral_speed)
    
    # Apply velocity with strong smoothing
    velocity = velocity.lerp(target_velocity, delta * 3.0)
    
    # Consume energy
    if time_direction != 0.0:
        _consume_energy(time_stream_energy_cost * delta)

# ----- HELPER FUNCTIONS -----
func get_movement_direction() -> Vector3:
    var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    
    if camera_mount:
        var basis = camera_mount.global_transform.basis
        direction = (basis.z * -input_dir.y + basis.x * input_dir.x).normalized()
    else:
        direction = Vector3(input_dir.x, 0, -input_dir.y).normalized()
    
    return direction

func process_head_bob(delta, intensity):
    if !camera_mount:
        return
    
    var bob_speed = head_bob_speed * intensity
    head_bob_cycle += delta * bob_speed
    
    var y_offset = sin(head_bob_cycle) * head_bob_amount * intensity
    camera_mount.position.y = lerp(camera_mount.position.y, y_offset, delta * camera_smoothing)

func process_energy(delta):
    # Regenerate energy when not using abilities
    if Time.get_ticks_msec() / 1000.0 - last_energy_use_time > 1.0:
        energy = min(max_energy, energy + energy_regen_rate * delta)
        energy_depleted = false
    
    # Update GUI with energy value
    if gui and gui.has_method("update_energy"):
        gui.update_energy(energy, max_energy)
    
    # Emit signal for energy change
    emit_signal("energy_changed", energy, max_energy)

func _consume_energy(amount: float):
    var previous_energy = energy
    energy = max(0.0, energy - amount)
    last_energy_use_time = Time.get_ticks_msec() / 1000.0
    
    # Check for energy depletion
    if previous_energy > 0 and energy <= 0 and !energy_depleted:
        energy_depleted = true
        
        # Handle energy depletion effects
        handle_energy_depletion()

func handle_energy_depletion():
    # Show effect
    if effects_player:
        effects_player.play("energy_depleted")
    
    # Force exit from energy-consuming modes
    if current_mode == MovementMode.FLYING or current_mode == MovementMode.WORD_SURFING or current_mode == MovementMode.TIME_STREAM:
        set_movement_mode(MovementMode.WALKING)
    
    # Notify via GUI
    if gui and gui.has_method("show_notification"):
        gui.show_notification("Energy depleted!", 2.0)

func setup_visual_effects():
    # Setup flight particles
    if flight_particles:
        flight_particles.emitting = false
    
    # Setup time stream particles
    if time_stream_particles:
        time_stream_particles.emitting = false
    
    # Setup dream particles
    if dream_particles:
        dream_particles.emitting = false

func update_visual_effects(delta):
    # Update flight particles
    if flight_particles:
        flight_particles.emitting = current_mode == MovementMode.FLYING and velocity.length() > 1.0
        
        if flight_particles.emitting:
            # Adjust particle emission based on speed
            var speed_ratio = velocity.length() / flight_speed
            flight_particles.amount = int(32.0 * speed_ratio) + 16
    
    # Update time stream particles
    if time_stream_particles:
        time_stream_particles.emitting = current_mode == MovementMode.TIME_STREAM
        
        if time_stream_particles.emitting:
            // Adjust time stream effects based on direction
            if is_advancing_time:
                time_stream_particles.direction = Vector3(0, 0, -1)  # Forward in time
            elif is_rewinding_time:
                time_stream_particles.direction = Vector3(0, 0, 1)   # Backward in time
            else:
                time_stream_particles.direction = Vector3(0, 1, 0)   # Neutral
    
    # Update dream particles
    if dream_particles:
        dream_particles.emitting = current_mode == MovementMode.DREAM_NAVIGATION
        
        if dream_particles.emitting:
            // Adjust dream particles based on movement
            dream_particles.lifetime = 2.0 + velocity.length() * 0.1

# ----- MODE TRANSITION -----
func set_movement_mode(mode: MovementMode):
    if mode == current_mode:
        return
    
    # Check energy requirements for certain modes
    if (mode == MovementMode.FLYING or mode == MovementMode.WORD_SURFING or mode == MovementMode.TIME_STREAM) and energy <= 0:
        # Not enough energy
        if gui and gui.has_method("show_notification"):
            gui.show_notification("Not enough energy!", 2.0)
        
        if effects_player:
            effects_player.play("energy_depleted")
        
        return
    
    # Store previous mode
    previous_mode = current_mode
    
    # Update mode
    current_mode = mode
    
    # Start transition
    is_shifting_mode = true
    mode_transition_progress = 0.0
    
    # Perform mode-specific initialization
    initialize_mode(mode)
    
    # Update GUI
    if gui and gui.has_method("update_mode"):
        gui.update_mode(MovementMode.keys()[mode])
    
    # Emit signal
    emit_signal("mode_changed", previous_mode, current_mode)
    
    # Play mode change effect
    if effects_player:
        effects_player.play("mode_change")

func initialize_mode(mode: MovementMode):
    match mode:
        MovementMode.WALKING:
            # Reset velocity
            velocity = Vector3.ZERO
            h_velocity = Vector3.ZERO
        
        MovementMode.FLYING:
            # Zero out vertical velocity
            velocity.y = 0
        
        MovementMode.SPECTATOR:
            # Zero out velocity
            velocity = Vector3.ZERO
        
        MovementMode.WORD_SURFING:
            # Initialize surfing
            velocity = Vector3.ZERO
            current_surf_word_id = ""
            next_surf_word_id = ""
            surfing_progress = 0.0
            
            # Find initial surf path
            find_surfing_path()
        
        MovementMode.DREAM_NAVIGATION:
            # Enter dream state
            velocity = Vector3.ZERO
            if time_progression_system and time_progression_system.has_method("enter_dream_state"):
                time_progression_system.enter_dream_state()
            
            dream_state_active = true
        
        MovementMode.TIME_STREAM:
            # Initialize time stream
            velocity = Vector3.ZERO
            is_advancing_time = false
            is_rewinding_time = false
            
            if time_progression_system:
                time_progression_system.time_multiplier = 1.0

func process_mode_transition(delta):
    // Update transition progress
    mode_transition_progress += delta / mode_transition_duration
    
    if mode_transition_progress >= 1.0:
        // Transition complete
        mode_transition_progress = 1.0
        is_shifting_mode = false
    
    // Apply visual transition effects based on modes
    if camera:
        // FOV transition between modes
        var base_fov = 75.0
        var target_fov = base_fov
        
        match current_mode:
            MovementMode.WALKING:
                target_fov = 75.0
            MovementMode.FLYING:
                target_fov = 85.0
            MovementMode.SPECTATOR:
                target_fov = 80.0
            MovementMode.WORD_SURFING:
                target_fov = 90.0
            MovementMode.DREAM_NAVIGATION:
                target_fov = 70.0
            MovementMode.TIME_STREAM:
                target_fov = 100.0
        
        // Interpolate FOV
        camera.fov = lerp(
            camera.fov,
            target_fov,
            delta * 5.0
        )

# ----- REALITY SHIFTING -----
func shift_reality(target: String):
    if is_shifting_reality:
        return
    
    if energy < shift_energy_cost:
        if effects_player:
            effects_player.play("energy_depleted")
        return
    
    // Store target reality
    target_reality = target
    is_shifting_reality = true
    reality_transition_progress = 0.0
    
    // Apply energy cost
    _consume_energy(shift_energy_cost)
    
    // Emit signal for start of shift
    emit_signal("reality_shifted", current_reality, target_reality)
    
    // Notify via GUI
    if gui and gui.has_method("show_notification"):
        gui.show_notification("Shifting to " + target_reality + " reality...", 1.0)

func process_reality_transition(delta):
    // Update transition progress
    reality_transition_progress += delta / reality_transition_duration
    
    if reality_transition_progress >= 1.0:
        // Transition complete
        reality_transition_progress = 1.0
        is_shifting_reality = false
        
        // Update current reality
        current_reality = target_reality
        
        // Apply reality effects
        apply_reality_effects()
        
        // Update GUI
        if gui and gui.has_method("update_reality"):
            gui.update_reality(current_reality)
    
    // Apply visual transition effects
    if game_controller and game_controller.has_method("update_reality_transition"):
        game_controller.update_reality_transition(current_reality, target_reality, reality_transition_progress)

func apply_reality_effects():
    if game_controller and game_controller.has_method("set_reality"):
        game_controller.set_reality(current_reality)

# ----- WORD INTERACTION -----
func process_word_interaction():
    // Check for interaction with words
    if Input.is_action_just_pressed("interact"):
        interact_with_word()
    
    // Update interaction ray if it exists
    if interaction_ray and words_in_space:
        var collider = interaction_ray.get_collider()
        
        if collider != null:
            // Highlight word under crosshair
            var word_id = collider.get_meta("word_id", "")
            if word_id != "":
                if gui and gui.has_method("highlight_word"):
                    gui.highlight_word(true)
        else:
            // No word under crosshair
            if gui and gui.has_method("highlight_word"):
                gui.highlight_word(false)

func interact_with_word():
    if !interaction_ray:
        return
    
    var collider = interaction_ray.get_collider()
    
    if collider != null:
        // Get word ID from collider
        var word_id = collider.get_meta("word_id", "")
        
        if word_id != "":
            // Select the word
            _select_word(word_id)
            
            // Start surfing from this word if in surfing mode
            if current_mode == MovementMode.WORD_SURFING:
                current_surf_word_id = word_id
                surfing_progress = 0.0
                find_next_surf_word()

func _select_word(word_id: String):
    // Deselect previous word
    if selected_word_id != "" and words_in_space:
        words_in_space.highlight_word(selected_word_id, false)
    
    // Select new word
    selected_word_id = word_id
    
    if words_in_space:
        words_in_space.highlight_word(word_id, true)
    
    // Get connected words
    if words_in_space:
        connected_words = words_in_space.get_connected_words(word_id)
    
    // Update GUI
    if gui and gui.has_method("show_word_info"):
        var word_text = words_in_space.get_word_text(word_id)
        var word_data = {}
        
        // Get additional word data if available
        if words_in_space.has_method("get_word_data"):
            word_data = words_in_space.get_word_data(word_id)
        
        gui.show_word_info(word_id, word_text, word_data)
    
    // Emit signal
    emit_signal("word_selected", word_id)

func find_surfing_path():
    if !words_in_space:
        return
    
    // Try to get a word to start surfing from
    if selected_word_id != "":
        current_surf_word_id = selected_word_id
    else:
        // Find closest word
        var closest_word = find_closest_word()
        if closest_word != "":
            current_surf_word_id = closest_word
        else:
            return  // No suitable word found
    
    // Find next word in surfing path
    find_next_surf_word()
    
    // If successful, select the current word
    if current_surf_word_id != "":
        _select_word(current_surf_word_id)

func find_closest_word() -> String:
    if !words_in_space or !words_in_space.has_method("get_all_words"):
        return ""
    
    var all_words = words_in_space.get_all_words()
    var closest_word = ""
    var closest_distance = 9999999.0
    
    for word_id in all_words:
        var word_pos = words_in_space.get_word_position(word_id)
        var distance = global_position.distance_to(word_pos)
        
        if distance < closest_distance:
            closest_distance = distance
            closest_word = word_id
    
    return closest_word

func find_next_surf_word():
    if current_surf_word_id == "" or !words_in_space:
        return
    
    // Get connected words from current word
    connected_words = words_in_space.get_connected_words(current_surf_word_id)
    
    if connected_words.size() == 0:
        // No connected words, try to find closest word
        next_surf_word_id = find_closest_word()
        if next_surf_word_id == current_surf_word_id:
            next_surf_word_id = ""  // Avoid surfing to self
        return
    
    // Choose a connected word to surf to
    // Prefer unvisited words or words in the direction of movement
    var best_word_id = ""
    var best_score = -1.0
    
    for word_id in connected_words:
        var score = 0.0
        
        // Bias toward words in the direction we're facing
        var word_pos = words_in_space.get_word_position(word_id)
        var current_pos = words_in_space.get_word_position(current_surf_word_id)
        var to_word = (word_pos - current_pos).normalized()
        var forward = -camera_mount.global_transform.basis.z
        var direction_score = to_word.dot(forward) + 1.0  // Range 0-2
        
        score += direction_score * 2.0
        
        // Bias toward words we haven't visited recently
        if word_id != next_surf_word_id:
            score += 1.0
        
        if score > best_score:
            best_score = score
            best_word_id = word_id
    
    next_surf_word_id = best_word_id

# ----- TIME ADVANCEMENT -----
func calculate_movement(delta):
    // Calculate distance moved since last frame
    distance_moved = global_position.distance_to(last_position)
    last_position = global_position
    
    // Only consider significant movement
    if distance_moved > 0.01:
        // Emit movement signal
        emit_signal("player_moved", distance_moved, velocity)
        
        // Advance time based on movement
        if time_progression_system:
            var time_advance = distance_moved * movement_time_factor * delta
            time_progression_system.accelerate_time(time_advance)
            
            // Emit time advancement signal
            emit_signal("time_advanced", time_advance)

# ----- PUBLIC API -----
func teleport_to(position: Vector3):
    // Set global position directly
    global_position = position

func look_at_point(point: Vector3):
    if !camera_mount:
        return
    
    var direction = point - global_position
    if direction.length_squared() > 0.001:
        camera_mount.look_at(point, Vector3.UP)

func set_movement_enabled(enabled: bool):
    movement_enabled = enabled
    
    // Stop all motion if disabled
    if !enabled:
        velocity = Vector3.ZERO
        h_velocity = Vector3.ZERO

func cycle_movement_mode():
    // Cycle through available modes
    var next_mode = (current_mode + 1) % MovementMode.size()
    set_movement_mode(next_mode)

func toggle_flight_mode():
    if current_mode == MovementMode.FLYING:
        set_movement_mode(MovementMode.WALKING)
    else:
        set_movement_mode(MovementMode.FLYING)

func enter_dream_state():
    // Only enter if not already in dream mode
    if current_mode != MovementMode.DREAM_NAVIGATION:
        set_movement_mode(MovementMode.DREAM_NAVIGATION)

func exit_dream_state():
    // Only exit if in dream mode
    if current_mode == MovementMode.DREAM_NAVIGATION:
        set_movement_mode(previous_mode)
        
        // Exit dream state in time system
        if time_progression_system and time_progression_system.has_method("exit_dream_state"):
            time_progression_system.exit_dream_state()
        
        dream_state_active = false

func toggle_time_stream():
    if current_mode == MovementMode.TIME_STREAM:
        set_movement_mode(MovementMode.WALKING)
    else:
        set_movement_mode(MovementMode.TIME_STREAM)

func get_current_movement_mode() -> String:
    return MovementMode.keys()[current_mode]

func get_current_reality() -> String:
    return current_reality

func get_energy_level() -> float:
    return energy

func set_energy_level(level: float):
    energy = clamp(level, 0, max_energy)
    energy_depleted = energy <= 0
    
    // Update GUI
    if gui and gui.has_method("update_energy"):
        gui.update_energy(energy, max_energy)
    
    // Emit signal
    emit_signal("energy_changed", energy, max_energy)

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var head_bob_cycle = 0.0