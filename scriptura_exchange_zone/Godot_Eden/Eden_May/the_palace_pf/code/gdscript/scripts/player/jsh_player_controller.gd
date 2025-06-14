extends CharacterBody3D
class_name JSHPlayerController

# Player Movement + Flight System for JSH Ethereal Engine
# Allows navigation through the word and shape space with multiple movement modes

# Movement modes
enum MovementMode {
    WALKING,    # Standard walking on surfaces
    FLYING,     # Free flight in any direction
    SPECTATOR,  # No collision ghost mode
    WORD_SURFING # Special mode that rides along word connections
}

# Signals
signal mode_changed(old_mode, new_mode)
signal reality_shift_requested(target_reality)
signal word_interaction(word_id, interaction_type)

# Movement parameters
@export_group("Movement Settings")
@export var walk_speed: float = 5.0
@export var run_speed: float = 10.0
@export var flight_speed: float = 15.0
@export var spectator_speed: float = 20.0
@export var word_surf_speed: float = 25.0
@export var acceleration: float = 8.0
@export var deceleration: float = 10.0
@export var jump_strength: float = 5.0
@export var gravity_force: float = 9.8

# Flight parameters
@export_group("Flight Settings")
@export var flight_acceleration: float = 4.0
@export var flight_deceleration: float = 6.0
@export var flight_rotation_speed: float = 2.0
@export var boost_multiplier: float = 2.0
@export var hover_stabilization: float = 0.5
@export var energy_consumption_rate: float = 0.1

# Camera parameters
@export_group("Camera Settings")
@export var mouse_sensitivity: float = 0.2
@export var controller_sensitivity: float = 2.0
@export var camera_smoothing: float = 0.2
@export var camera_tilt_limit: float = 89.0
@export var enable_head_bob: bool = true
@export var head_bob_amount: float = 0.1
@export var head_bob_speed: float = 10.0

# Reality shift parameters
@export_group("Reality Shift Settings")
@export var shift_transition_time: float = 1.0
@export var shift_energy_cost: float = 20.0
@export var reality_shader_transition: bool = true

# Node references
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var interaction_ray = $Head/Camera3D/InteractionRay
@onready var collision_shape = $CollisionShape3D
@onready var animation_player = $AnimationPlayer
@onready var effects_player = $EffectsPlayer
@onready var gui = $GUI
@onready var word_scanner = $WordScanner

# State variables
var current_mode: int = MovementMode.WALKING
var previous_mode: int = MovementMode.WALKING
var current_speed: float = 0.0
var movement_vector: Vector3 = Vector3.ZERO
var input_direction: Vector2 = Vector2.ZERO
var is_running: bool = false
var is_jumping: bool = false
var is_boosting: bool = false
var is_shifting_reality: bool = false
var can_double_jump: bool = true
var total_flight_time: float = 0.0
var current_reality: String = "physical"
var target_reality: String = "physical"
var reality_transition_progress: float = 0.0
var mouse_captured: bool = false
var interaction_target: String = ""
var energy: float = 100.0
var max_energy: float = 100.0
var words_collected: Array = []
var words_created: Array = []
var camera_rotation: Vector2 = Vector2.ZERO
var camera_bob_time: float = 0.0
var current_word_path: Array = []

# Energy & effects
var energy_recharge_rate: float = 0.5
var energy_recharge_delay: float = 2.0
var last_energy_use_time: float = 0.0
var particle_trail: GPUParticles3D
var reality_material: ShaderMaterial

# Interaction system
var interaction_range: float = 5.0
var nearest_word_id: String = ""
var hovered_word_id: String = ""
var selected_word_id: String = ""
var connected_words: Array = []

# Systems integration
var words_in_space = null
var reality_system = null
var word_manifestor = null
var entity_manager = null

# Ready function
func _ready():
    # Set up camera
    camera.current = true
    
    # Set up interaction ray
    interaction_ray.enabled = true
    interaction_ray.target_position = Vector3(0, 0, -interaction_range)
    
    # Set up particle trail
    _setup_particles()
    
    # Set up reality material
    _setup_reality_shader()
    
    # Connect signals
    if animation_player:
        animation_player.animation_finished.connect(_on_animation_finished)
    
    # Find necessary systems
    _find_systems()
    
    # Capture mouse
    _capture_mouse()
    
    # Set initial collision state
    _update_collision_for_mode()
    
    # Initialize GUI
    _update_gui()

# Find references to other systems
func _find_systems():
    # Try to find words in space system
    var words_nodes = get_tree().get_nodes_in_group("words_in_space")
    if words_nodes.size() > 0:
        words_in_space = words_nodes[0]
    
    # Try to find reality system
    if has_node("/root/main"):
        var main = get_node("/root/main")
        
        if main.has_method("get_reality_system"):
            reality_system = main.get_reality_system()
        
        if main.has_method("get_word_manifestor"):
            word_manifestor = main.get_word_manifestor()
            
        if main.has_method("get_entity_manager"):
            entity_manager = main.get_entity_manager()

# Process function for general updates
func _process(delta):
    # Process reality transition if active
    if is_shifting_reality:
        _process_reality_shift(delta)
    
    # Process energy regeneration
    _process_energy(delta)
    
    # Update hover effects for words in range
    _process_word_hover(delta)
    
    # Update GUI
    _update_gui()
    
    # Process word surfing if active
    if current_mode == MovementMode.WORD_SURFING:
        _process_word_surfing(delta)

# Physics process for movement
func _physics_process(delta):
    # Process movement based on current mode
    match current_mode:
        MovementMode.WALKING:
            _process_walking(delta)
        MovementMode.FLYING:
            _process_flying(delta)
        MovementMode.SPECTATOR:
            _process_spectator(delta)
        MovementMode.WORD_SURFING:
            # Base movement handled in _process_word_surfing()
            # But we still need to move character
            move_and_slide()
    
    # Process head bob if enabled and walking
    if enable_head_bob and current_mode == MovementMode.WALKING and is_on_floor() and movement_vector.length() > 0.1:
        _process_head_bob(delta)
    else:
        # Reset head position
        head.position.y = lerp(head.position.y, 0.0, delta * 5.0)

# Process input
func _input(event):
    # Handle mouse look
    if event is InputEventMouseMotion and mouse_captured:
        _handle_mouse_look(event)
    
    # Handle mouse interaction
    if event is InputEventMouseButton and event.pressed:
        _handle_mouse_interaction(event)
    
    # Handle keyboard shortcuts
    if event is InputEventKey and event.pressed:
        _handle_keyboard_shortcuts(event)

# Process walking movement
func _process_walking(delta):
    # Get input direction
    input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    is_running = Input.is_action_pressed("run")
    
    # Apply gravity
    if not is_on_floor():
        velocity.y -= gravity_force * delta
    
    # Handle jumping
    if Input.is_action_just_pressed("jump"):
        if is_on_floor():
            velocity.y = jump_strength
            is_jumping = true
            can_double_jump = true
            if animation_player:
                animation_player.play("jump")
        elif can_double_jump and energy >= 10.0:
            velocity.y = jump_strength * 0.8
            can_double_jump = false
            energy -= 10.0
            _consume_energy(10.0)
            if effects_player:
                effects_player.play("double_jump")
    
    # Calculate target speed
    var target_speed = walk_speed
    if is_running:
        target_speed = run_speed
    
    # Calculate movement direction relative to camera
    var movement_dir = Vector3.ZERO
    var camera_basis = camera.global_transform.basis
    
    if input_direction != Vector2.ZERO:
        movement_dir = Vector3(input_direction.x, 0, input_direction.y).normalized()
        movement_dir = camera_basis.x * movement_dir.x + camera_basis.z * movement_dir.z
        movement_dir.y = 0
        movement_dir = movement_dir.normalized()
    
    # Apply acceleration or deceleration
    if movement_dir.length() > 0:
        current_speed = lerp(current_speed, target_speed, delta * acceleration)
    else:
        current_speed = lerp(current_speed, 0.0, delta * deceleration)
    
    # Apply movement
    movement_vector = movement_dir * current_speed
    velocity.x = movement_vector.x
    velocity.z = movement_vector.z
    
    # Update animation states if available
    if animation_player and is_on_floor():
        if movement_vector.length() > 0.1:
            if is_running:
                if not animation_player.current_animation == "run":
                    animation_player.play("run")
            else:
                if not animation_player.current_animation == "walk":
                    animation_player.play("walk")
        else:
            if not animation_player.current_animation == "idle":
                animation_player.play("idle")
    
    # Apply movement
    move_and_slide()
    
    # Check if landed from jump
    if is_jumping and is_on_floor():
        is_jumping = false

# Process flying movement
func _process_flying(delta):
    # Get input direction
    input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    is_boosting = Input.is_action_pressed("run")
    
    # Track flight time for energy consumption
    total_flight_time += delta
    
    # Calculate target speed
    var target_speed = flight_speed
    if is_boosting and energy > 0:
        target_speed *= boost_multiplier
        _consume_energy(energy_consumption_rate * 2.0 * delta)
    else:
        _consume_energy(energy_consumption_rate * delta)
    
    # Calculate movement direction relative to camera
    var movement_dir = Vector3.ZERO
    var camera_transform = camera.global_transform
    
    if input_direction != Vector2.ZERO:
        movement_dir += camera_transform.basis.z * -input_direction.y
        movement_dir += camera_transform.basis.x * input_direction.x
    
    # Handle vertical movement
    if Input.is_action_pressed("jump"):
        movement_dir += Vector3.UP
    if Input.is_action_pressed("crouch"):
        movement_dir += Vector3.DOWN
    
    movement_dir = movement_dir.normalized()
    
    # Apply acceleration or deceleration
    if movement_dir.length() > 0:
        current_speed = lerp(current_speed, target_speed, delta * flight_acceleration)
    else:
        current_speed = lerp(current_speed, 0.0, delta * flight_deceleration)
    
    # Apply movement
    movement_vector = movement_dir * current_speed
    
    # Apply slight hover stabilization when not moving
    if movement_dir.length() < 0.1:
        velocity = velocity.lerp(Vector3.ZERO, delta * hover_stabilization)
    
    # Set velocity
    velocity = movement_vector
    
    # Update particle trail
    if particle_trail:
        particle_trail.emitting = current_speed > 1.0
        var emission_intensity = clamp(current_speed / flight_speed * boost_multiplier, 0.0, 2.0)
        particle_trail.amount_scale = emission_intensity
    
    # Apply movement
    move_and_slide()
    
    # Check if we need to switch back to walking due to energy depletion
    if energy <= 0 and current_mode == MovementMode.FLYING:
        set_movement_mode(MovementMode.WALKING)
        if effects_player:
            effects_player.play("energy_depleted")

# Process spectator movement (no collision, ghost mode)
func _process_spectator(delta):
    # Get input direction
    input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    is_boosting = Input.is_action_pressed("run")
    
    # Calculate target speed
    var target_speed = spectator_speed
    if is_boosting:
        target_speed *= boost_multiplier
    
    # Calculate movement direction relative to camera
    var movement_dir = Vector3.ZERO
    var camera_transform = camera.global_transform
    
    if input_direction != Vector2.ZERO:
        movement_dir += camera_transform.basis.z * -input_direction.y
        movement_dir += camera_transform.basis.x * input_direction.x
    
    # Handle vertical movement
    if Input.is_action_pressed("jump"):
        movement_dir += Vector3.UP
    if Input.is_action_pressed("crouch"):
        movement_dir += Vector3.DOWN
    
    movement_dir = movement_dir.normalized()
    
    # Apply acceleration or deceleration
    if movement_dir.length() > 0:
        current_speed = lerp(current_speed, target_speed, delta * flight_acceleration)
    else:
        current_speed = lerp(current_speed, 0.0, delta * flight_deceleration)
    
    # Apply movement directly to global transform
    global_position += movement_dir * current_speed * delta
    
    # Update particle trail
    if particle_trail:
        particle_trail.emitting = current_speed > 1.0
        particle_trail.amount_scale = current_speed / spectator_speed

# Process word surfing (riding along word connections)
func _process_word_surfing(delta):
    # Only active when we have a path to follow
    if current_word_path.size() < 2:
        return
    
    # Get current target and next point
    var current_target = current_word_path[0]
    var next_point = current_word_path[1]
    
    # Calculate direction to current target
    var dir_to_target = (current_target - global_position).normalized()
    
    # Apply movement
    var target_speed = word_surf_speed
    current_speed = lerp(current_speed, target_speed, delta * acceleration)
    movement_vector = dir_to_target * current_speed
    velocity = movement_vector
    
    # Check distance to target
    var distance_to_target = global_position.distance_to(current_target)
    if distance_to_target < 1.0:
        # Move to next point in path
        current_word_path.remove_at(0)
        
        # Check if we reached the end
        if current_word_path.size() < 2:
            set_movement_mode(MovementMode.FLYING)
            if effects_player:
                effects_player.play("word_surf_end")
        else:
            # Continue surfing
            if effects_player:
                effects_player.play("word_surf_node")

# Process energy regeneration and consumption
func _process_energy(delta):
    var current_time = Time.get_ticks_msec() / 1000.0
    
    # Regenerate energy if not used recently
    if (current_time - last_energy_use_time) > energy_recharge_delay:
        energy = min(energy + energy_recharge_rate * delta, max_energy)

# Process reality shift transition
func _process_reality_shift(delta):
    if not is_shifting_reality:
        return
    
    reality_transition_progress += delta / shift_transition_time
    
    if reality_transition_progress >= 1.0:
        _complete_reality_shift()
    else:
        # Update shader parameters for transition effect
        if reality_material:
            reality_material.set_shader_parameter("transition_progress", reality_transition_progress)
            reality_material.set_shader_parameter("to_reality", target_reality)

# Process head bobbing for walking
func _process_head_bob(delta):
    if current_mode != MovementMode.WALKING:
        return
    
    if movement_vector.length() > 0.1 and is_on_floor():
        camera_bob_time += delta * head_bob_speed * (current_speed / walk_speed)
        var bob_offset = sin(camera_bob_time) * head_bob_amount
        head.position.y = bob_offset

# Process word hover effects
func _process_word_hover(delta):
    # Check interaction ray for word targeting
    if interaction_ray.is_colliding():
        var collider = interaction_ray.get_collider()
        
        if collider and collider.has_meta("word_id"):
            var word_id = collider.get_meta("word_id")
            
            # Update hovered word
            if hovered_word_id != word_id:
                if hovered_word_id != "" and words_in_space:
                    # Remove hover from previous word
                    words_in_space._on_Word_mouse_exited(hovered_word_id)
                
                hovered_word_id = word_id
                
                if words_in_space:
                    # Add hover to new word
                    words_in_space._on_Word_mouse_entered(hovered_word_id)
                
                # Update GUI with word info
                _update_word_info(word_id)
        else:
            # Nothing hit, clear hover
            if hovered_word_id != "" and words_in_space:
                words_in_space._on_Word_mouse_exited(hovered_word_id)
                hovered_word_id = ""
    else:
        # Nothing hit, clear hover
        if hovered_word_id != "" and words_in_space:
            words_in_space._on_Word_mouse_exited(hovered_word_id)
            hovered_word_id = ""

# Handle mouse look
func _handle_mouse_look(event):
    # Apply mouse movement to camera rotation with sensitivity
    var mouse_motion = event.relative * (mouse_sensitivity * 0.01)
    
    # Rotate camera horizontally
    rotate_y(-mouse_motion.x)
    
    # Rotate camera vertically (with limits)
    var current_tilt = camera.rotation.x
    var new_tilt = current_tilt - mouse_motion.y
    new_tilt = clamp(new_tilt, deg_to_rad(-camera_tilt_limit), deg_to_rad(camera_tilt_limit))
    camera.rotation.x = new_tilt

# Handle mouse interaction
func _handle_mouse_interaction(event):
    match event.button_index:
        MOUSE_BUTTON_LEFT:
            # Left click - select word or create word
            if hovered_word_id != "":
                _select_word(hovered_word_id)
            else:
                # Create word at position if we have a manifestor
                _create_word_at_position(interaction_ray.get_collision_point())
        
        MOUSE_BUTTON_RIGHT:
            # Right click - connect words or start word surfing
            if selected_word_id != "" and hovered_word_id != "" and selected_word_id != hovered_word_id:
                _connect_words(selected_word_id, hovered_word_id)
            elif selected_word_id != "" and words_in_space:
                # Start word surfing from selected word
                _start_word_surfing(selected_word_id)
        
        MOUSE_BUTTON_MIDDLE:
            # Middle click - change movement mode
            _toggle_movement_mode()

# Handle keyboard shortcuts
func _handle_keyboard_shortcuts(event):
    match event.keycode:
        KEY_F:
            # F key - toggle flight mode
            if current_mode == MovementMode.WALKING:
                set_movement_mode(MovementMode.FLYING)
            else:
                set_movement_mode(MovementMode.WALKING)
        
        KEY_G:
            # G key - toggle ghost/spectator mode
            if current_mode == MovementMode.SPECTATOR:
                set_movement_mode(previous_mode)
            else:
                set_movement_mode(MovementMode.SPECTATOR)
        
        KEY_R:
            # R key - cycle reality
            _cycle_reality()
        
        KEY_C:
            # C key - create word at camera position
            _create_word_at_position(camera.global_position + camera.global_transform.basis.z * -2.0)
        
        KEY_TAB:
            # Tab key - toggle mouse capture
            _toggle_mouse_capture()
        
        KEY_E:
            # E key - interact with hovered word
            if hovered_word_id != "":
                _interact_with_word(hovered_word_id)

# Set movement mode
func set_movement_mode(mode: int):
    if mode == current_mode:
        return
    
    # Store previous mode
    previous_mode = current_mode
    
    # Set new mode
    current_mode = mode
    
    # Update collision based on mode
    _update_collision_for_mode()
    
    # Play transition effects
    match current_mode:
        MovementMode.WALKING:
            if effects_player:
                effects_player.play("to_walking")
        
        MovementMode.FLYING:
            if effects_player:
                effects_player.play("to_flying")
        
        MovementMode.SPECTATOR:
            if effects_player:
                effects_player.play("to_spectator")
        
        MovementMode.WORD_SURFING:
            if effects_player:
                effects_player.play("to_word_surfing")
    
    # Reset movement variables
    current_speed = 0.0
    movement_vector = Vector3.ZERO
    
    # Emit signal
    emit_signal("mode_changed", previous_mode, current_mode)

# Toggle movement mode
func _toggle_movement_mode():
    match current_mode:
        MovementMode.WALKING:
            set_movement_mode(MovementMode.FLYING)
        MovementMode.FLYING:
            set_movement_mode(MovementMode.SPECTATOR)
        MovementMode.SPECTATOR:
            set_movement_mode(MovementMode.WALKING)
        MovementMode.WORD_SURFING:
            set_movement_mode(MovementMode.FLYING)

# Update collision based on movement mode
func _update_collision_for_mode():
    match current_mode:
        MovementMode.WALKING:
            # Enable collision for walking
            if collision_shape:
                collision_shape.disabled = false
            
            # Enable gravity
            set_up_direction(Vector3.UP)
            set_floor_stop_on_slope_enabled(true)
            set_floor_max_angle(deg_to_rad(45.0))
        
        MovementMode.FLYING:
            # Enable collision for flying
            if collision_shape:
                collision_shape.disabled = false
            
            # Disable gravity effects
            set_up_direction(Vector3.UP)
            set_floor_stop_on_slope_enabled(false)
        
        MovementMode.SPECTATOR:
            # Disable collision for spectator
            if collision_shape:
                collision_shape.disabled = true
        
        MovementMode.WORD_SURFING:
            # Enable collision but adjust for surfing
            if collision_shape:
                collision_shape.disabled = false
            
            # Disable gravity effects
            set_up_direction(Vector3.UP)
            set_floor_stop_on_slope_enabled(false)

# Consume energy for an action
func _consume_energy(amount: float):
    energy = max(0.0, energy - amount)
    last_energy_use_time = Time.get_ticks_msec() / 1000.0

# Shift reality
func shift_reality(target: String):
    if is_shifting_reality:
        return
    
    if energy < shift_energy_cost:
        if effects_player:
            effects_player.play("energy_depleted")
        return
    
    # Check if target reality is valid
    if reality_system and not reality_system.is_valid_reality(target):
        return
    
    # Store target reality
    target_reality = target
    is_shifting_reality = true
    reality_transition_progress = 0.0
    
    # Apply energy cost
    _consume_energy(shift_energy_cost)
    
    # Play effects
    if effects_player:
        effects_player.play("reality_shift_start")
    
    # Emit signal
    emit_signal("reality_shift_requested", target)

# Complete reality shift
func _complete_reality_shift():
    is_shifting_reality = false
    current_reality = target_reality
    
    # Notify reality system
    if reality_system:
        reality_system.set_current_reality(current_reality)
    
    # Reset transition parameters
    reality_transition_progress = 0.0
    
    # Play completion effect
    if effects_player:
        effects_player.play("reality_shift_complete")

# Cycle through realities
func _cycle_reality():
    if is_shifting_reality:
        return
    
    var realities = ["physical", "digital", "astral"]
    var current_index = realities.find(current_reality)
    var next_index = (current_index + 1) % realities.size()
    
    shift_reality(realities[next_index])

# Select a word
func _select_word(word_id: String):
    # Deselect previous word
    if selected_word_id != "" and words_in_space:
        words_in_space._on_Word_clicked(selected_word_id)  # This toggles selection
    
    # Select new word
    selected_word_id = word_id
    
    if words_in_space:
        words_in_space._on_Word_clicked(word_id)
    
    # Get connected words
    if words_in_space:
        connected_words = words_in_space.get_connected_words(word_id)
    
    # Play selection effect
    if effects_player:
        effects_player.play("word_select")
    
    # Emit interaction signal
    emit_signal("word_interaction", word_id, "select")

# Connect two words
func _connect_words(word1_id: String, word2_id: String):
    if words_in_space:
        words_in_space.connect_words(word1_id, word2_id)
        
        # Play connection effect
        if effects_player:
            effects_player.play("word_connect")
        
        # Emit interaction signal
        emit_signal("word_interaction", word1_id, "connect")
        emit_signal("word_interaction", word2_id, "connect")

# Start word surfing from a word
func _start_word_surfing(start_word_id: String):
    if not words_in_space:
        return
    
    # Get connected words
    var connections = words_in_space.get_connected_words(start_word_id)
    
    if connections.size() > 0:
        # Create a path of word positions
        current_word_path = []
        
        # Add starting word position
        var start_pos = words_in_space.get_word_position(start_word_id)
        current_word_path.append(start_pos)
        
        # Add positions of connected words
        for word_id in connections:
            var pos = words_in_space.get_word_position(word_id)
            current_word_path.append(pos)
        
        # Start word surfing mode
        set_movement_mode(MovementMode.WORD_SURFING)
        
        # Play effect
        if effects_player:
            effects_player.play("word_surf_start")

# Create word at position
func _create_word_at_position(position: Vector3):
    if not word_manifestor:
        return
    
    # Open word creation prompt
    # This would typically connect to a UI prompt
    # For now, just create a random test word
    var test_words = ["reality", "creation", "thought", "energy", "light", "quantum", "code", "system", "framework", "language"]
    var random_word = test_words[randi() % test_words.size()]
    
    # Create word through manifestor
    if word_manifestor.has_method("manifest_word"):
        var entity_id = word_manifestor.manifest_word(random_word, position)
        if entity_id:
            words_created.append(random_word)
            
            # Play creation effect
            if effects_player:
                effects_player.play("word_create")

# Interact with a word
func _interact_with_word(word_id: String):
    if not words_in_space:
        return
    
    # Get word data
    var word_data = words_in_space.get_word_data(word_id)
    
    if word_data:
        # "Collect" the word if not already collected
        if not words_collected.has(word_data.text):
            words_collected.append(word_data.text)
            
            # Play collection effect
            if effects_player:
                effects_player.play("word_collect")
            
            # Emit interaction signal
            emit_signal("word_interaction", word_id, "collect")

# Update GUI
func _update_gui():
    if not gui:
        return
    
    # Update mode text
    var mode_text = ""
    match current_mode:
        MovementMode.WALKING:
            mode_text = "WALKING"
        MovementMode.FLYING:
            mode_text = "FLYING"
        MovementMode.SPECTATOR:
            mode_text = "SPECTATOR"
        MovementMode.WORD_SURFING:
            mode_text = "WORD SURFING"
    
    # Update reality text
    var reality_text = current_reality.capitalize()
    if is_shifting_reality:
        reality_text += " → " + target_reality.capitalize() + " (" + str(int(reality_transition_progress * 100)) + "%)"
    
    # Update energy bar
    var energy_percentage = energy / max_energy
    
    # Update word info
    if gui.has_method("update_player_info"):
        gui.update_player_info({
            "mode": mode_text,
            "reality": reality_text,
            "energy": energy_percentage,
            "position": global_position,
            "speed": current_speed,
            "words_collected": words_collected.size(),
            "words_created": words_created.size(),
            "selected_word": selected_word_id,
            "hovered_word": hovered_word_id
        })

# Update word info in GUI
func _update_word_info(word_id: String):
    if not gui or not words_in_space:
        return
    
    var word_data = words_in_space.get_word_data(word_id)
    
    if word_data and gui.has_method("update_word_info"):
        gui.update_word_info(word_data)

# Toggle mouse capture
func _toggle_mouse_capture():
    mouse_captured = !mouse_captured
    _capture_mouse()

# Capture mouse
func _capture_mouse():
    if mouse_captured:
        Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    else:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Animation finished callback
func _on_animation_finished(anim_name: String):
    # Handle animation transitions
    pass

# Set up particle trail
func _setup_particles():
    # Create particle system for movement trail
    particle_trail = GPUParticles3D.new()
    particle_trail.name = "MovementTrail"
    particle_trail.emitting = false
    
    # Set up particle material
    var material = ParticleProcessMaterial.new()
    material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
    material.emission_sphere_radius = 0.2
    material.gravity = Vector3.ZERO
    material.initial_velocity_min = 0.2
    material.initial_velocity_max = 0.5
    material.scale_min = 0.05
    material.scale_max = 0.2
    material.color = Color(0.2, 0.7, 1.0, 0.7)
    material.color_ramp = Gradient.new()
    material.lifetime_randomness = 0.2
    
    particle_trail.process_material = material
    
    # Add mesh to particles
    var mesh = SphereMesh.new()
    mesh.radius = 0.1
    mesh.height = 0.2
    particle_trail.draw_pass_1 = mesh
    
    # Add to scene
    add_child(particle_trail)
    particle_trail.position = Vector3(0, 0, 0.5)

# Set up reality shader
func _setup_reality_shader():
    # Create shader material for reality transition effects
    reality_material = ShaderMaterial.new()
    
    # Add to environment
    if camera:
        var environment = camera.environment
        if not environment:
            environment = Environment.new()
            camera.environment = environment
        
        # Add post-processing shader when available
        # This would be implemented separately

# Helper methods that words_in_space would need to implement
func get_word_data(word_id: String) -> Dictionary:
    if words_in_space and words_in_space.has_method("get_word_data"):
        return words_in_space.get_word_data(word_id)
    return {}

func get_word_position(word_id: String) -> Vector3:
    if words_in_space and words_in_space.has_method("get_word_position"):
        return words_in_space.get_word_position(word_id)
    return Vector3.ZERO

func get_connected_words(word_id: String) -> Array:
    if words_in_space and words_in_space.has_method("get_connected_words"):
        return words_in_space.get_connected_words(word_id)
    return []