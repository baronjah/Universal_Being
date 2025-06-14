extends Control
class_name ActionVisualizer

# Signals
signal action_completed(action_type, success)
signal visualization_finished(event_type)

# Visual configuration
export var base_color = Color(0.2, 0.5, 0.8, 0.8)
export var highlight_color = Color(0.9, 0.6, 0.2, 0.9)
export var success_color = Color(0.2, 0.8, 0.4, 0.8)
export var failure_color = Color(0.8, 0.2, 0.2, 0.8)
export var font_size = 24
export var animation_speed = 1.0
export var particle_count = 30
export var glow_intensity = 0.7
export var sound_volume = 0.7

# Rendering references
var particle_material = null
var font = null
var audio_player = null
var animation_player = null
var tween = null

# Active visualizations
var active_events = {}
var active_actions = {}
var current_guidance_label = null
var active_particles = []

# Ready for player input
var waiting_for_input = false
var current_action_type = ""
var input_success_window = 0.0
var input_start_time = 0.0

func _ready():
    # Initialize rendering components
    _initialize_rendering()
    
    # Set up input handling
    set_process_input(true)
    
    # Create animation player for sequenced animations
    animation_player = AnimationPlayer.new()
    add_child(animation_player)
    
    # Create tween for smooth transitions
    tween = Tween.new()
    add_child(tween)
    
    # Create audio player for sound effects
    audio_player = AudioStreamPlayer.new()
    add_child(audio_player)

func _initialize_rendering():
    # Initialize particle material
    particle_material = ParticlesMaterial.new()
    particle_material.emission_shape = ParticlesMaterial.EMISSION_SHAPE_SPHERE
    particle_material.emission_sphere_radius = 10.0
    particle_material.spread = 180.0
    particle_material.gravity = Vector3(0, 0, 0)
    particle_material.initial_velocity = 50.0
    particle_material.color = base_color
    
    # Initialize font
    font = DynamicFont.new()
    font.font_data = load("res://fonts/main_font.tres")
    font.size = font_size

func _process(delta):
    # Update active particle systems
    for particles in active_particles:
        if particles.emitting:
            # Apply any runtime effects like color shifts
            var material = particles.process_material
            if material:
                material.color = material.color.linear_interpolate(highlight_color, delta * 0.5)
    
    # Update action timers if waiting for input
    if waiting_for_input:
        var elapsed = OS.get_ticks_msec() - input_start_time
        var remaining = input_success_window * 1000 - elapsed
        
        if remaining <= 0:
            # Time expired, action failed
            _complete_action(current_action_type, false)
            waiting_for_input = false

func _input(event):
    if not waiting_for_input:
        return
    
    # Check for action input (spacebar or left mouse button)
    if (event is InputEventKey and event.scancode == KEY_SPACE and event.pressed) or \
       (event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed):
        
        # Calculate success based on timing
        var elapsed = OS.get_ticks_msec() - input_start_time
        var remaining = input_success_window * 1000 - elapsed
        
        # Success is more likely if action is performed in the middle of the window
        var optimal_time = input_success_window * 500  # middle of window
        var time_diff = abs(elapsed - optimal_time)
        var success_probability = 1.0 - (time_diff / (input_success_window * 500))
        success_probability = clamp(success_probability, 0.3, 0.95)  # 30-95% success chance
        
        var success = randf() < success_probability
        
        # Complete the action
        _complete_action(current_action_type, success)
        waiting_for_input = false
        
        # Consume the input
        get_tree().set_input_as_handled()

func display_visual_event(event_type, visual_data):
    # Create container for this visual event
    var container = Control.new()
    container.rect_min_size = Vector2(200, 200)
    container.rect_position = Vector2(
        visual_data.position.x * rect_size.x - 100,
        visual_data.position.y * rect_size.y - 100
    )
    add_child(container)
    
    # Create particles for the event
    var particles = Particles2D.new()
    particles.amount = particle_count
    particles.lifetime = visual_data.duration
    particles.explosiveness = 0.2
    particles.process_material = particle_material.duplicate()
    
    # Customize particles based on event type
    match event_type:
        "pattern_emergence":
            particles.process_material.color = Color(0.2, 0.5, 0.9, 0.8)
            particles.process_material.initial_velocity = 30.0
            particles.amount = particle_count * 1.5
        "memory_integration":
            particles.process_material.color = Color(0.9, 0.8, 0.2, 0.8)
            particles.process_material.initial_velocity = 20.0
        "dimensional_shift":
            particles.process_material.color = Color(0.8, 0.2, 0.8, 0.8)
            particles.process_material.initial_velocity = 50.0
            particles.amount = particle_count * 2
        "neural_evolution":
            particles.process_material.color = Color(0.2, 0.8, 0.5, 0.8)
            particles.process_material.initial_velocity = 25.0
        "time_acceleration":
            particles.process_material.color = Color(0.7, 0.7, 0.9, 0.8)
            particles.process_material.initial_velocity = 60.0
        "reality_anchor":
            particles.process_material.color = Color(0.9, 0.4, 0.1, 0.9)
            particles.process_material.initial_velocity = 15.0
        "word_manifestation":
            particles.process_material.color = Color(0.1, 0.8, 0.8, 0.8)
            particles.process_material.initial_velocity = 35.0
        "player_action":
            particles.process_material.color = Color(0.3, 0.9, 0.3, 0.9) if visual_data.success else Color(0.9, 0.3, 0.3, 0.9)
            particles.process_material.initial_velocity = 40.0
    
    # Add particles to container
    container.add_child(particles)
    active_particles.append(particles)
    
    # Add label with event name
    var label = Label.new()
    label.text = _get_display_text_for_event(event_type, visual_data)
    label.align = Label.ALIGN_CENTER
    label.valign = Label.VALIGN_CENTER
    label.rect_min_size = Vector2(200, 50)
    label.rect_position = Vector2(0, 80)
    label.add_color_override("font_color", particles.process_material.color)
    container.add_child(label)
    
    # Add glow effect
    var glow = Light2D.new()
    glow.texture = _create_radial_texture(64, particles.process_material.color)
    glow.energy = glow_intensity
    glow.scale = Vector2(4, 4)
    container.add_child(glow)
    
    # Start particles
    particles.emitting = true
    
    # Play sound if available
    if visual_data.has("sound"):
        _play_sound(visual_data.sound)
    
    # Store event
    active_events[event_type + str(OS.get_ticks_msec())] = {
        "container": container,
        "particles": particles,
        "label": label,
        "glow": glow,
        "duration": visual_data.duration,
        "start_time": OS.get_ticks_msec()
    }
    
    # Set up timer to clean up
    var timer = Timer.new()
    timer.wait_time = visual_data.duration
    timer.one_shot = true
    timer.connect("timeout", self, "_cleanup_visual_event", [event_type, container])
    add_child(timer)
    timer.start()
    
    # Animate entrance
    tween.interpolate_property(container, "modulate", 
        Color(1, 1, 1, 0), Color(1, 1, 1, 1), 
        0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
    tween.start()

func display_action_opportunity(action_type, time_window, prompt_text):
    # Create action UI container
    var container = Control.new()
    container.rect_min_size = Vector2(300, 150)
    container.rect_position = Vector2(
        rect_size.x / 2 - 150,
        rect_size.y / 2 - 75
    )
    add_child(container)
    
    # Create action prompt label
    var label = Label.new()
    label.text = prompt_text
    label.align = Label.ALIGN_CENTER
    label.valign = Label.VALIGN_CENTER
    label.rect_min_size = Vector2(300, 50)
    label.rect_position = Vector2(0, 0)
    label.add_color_override("font_color", highlight_color)
    container.add_child(label)
    
    # Create timer indicator
    var progress = ProgressBar.new()
    progress.rect_min_size = Vector2(300, 20)
    progress.rect_position = Vector2(0, 60)
    progress.max_value = time_window
    progress.value = time_window
    container.add_child(progress)
    
    # Create action hint
    var hint = Label.new()
    hint.text = "Press SPACE or CLICK to act!"
    hint.align = Label.ALIGN_CENTER
    hint.valign = Label.VALIGN_CENTER
    hint.rect_min_size = Vector2(300, 30)
    hint.rect_position = Vector2(0, 90)
    hint.add_color_override("font_color", Color(0.9, 0.9, 0.9, 0.8))
    container.add_child(hint)
    
    # Store action
    active_actions[action_type] = {
        "container": container,
        "label": label,
        "progress": progress,
        "hint": hint,
        "time_window": time_window,
        "start_time": OS.get_ticks_msec()
    }
    
    # Set input variables
    waiting_for_input = true
    current_action_type = action_type
    input_success_window = time_window
    input_start_time = OS.get_ticks_msec()
    
    # Animate timer countdown
    tween.interpolate_property(progress, "value", 
        time_window, 0, 
        time_window, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
    
    # Animate entrance
    tween.interpolate_property(container, "modulate", 
        Color(1, 1, 1, 0), Color(1, 1, 1, 1), 
        0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
    tween.start()
    
    # Play sound
    _play_sound("action_opportunity")
    
    # Set up timer to auto-fail if no input
    var timer = Timer.new()
    timer.wait_time = time_window
    timer.one_shot = true
    timer.connect("timeout", self, "_auto_fail_action", [action_type])
    add_child(timer)
    timer.start()

func display_ai_guidance(guidance_text, importance):
    # Remove any existing guidance
    if current_guidance_label != null:
        current_guidance_label.queue_free()
    
    # Create new guidance label
    current_guidance_label = Label.new()
    current_guidance_label.text = guidance_text
    current_guidance_label.align = Label.ALIGN_CENTER
    current_guidance_label.valign = Label.VALIGN_CENTER
    current_guidance_label.rect_min_size = Vector2(600, 80)
    current_guidance_label.rect_position = Vector2(
        rect_size.x / 2 - 300,
        rect_size.y - 100
    )
    
    # Set color based on importance
    var color = base_color.linear_interpolate(highlight_color, importance)
    current_guidance_label.add_color_override("font_color", color)
    
    add_child(current_guidance_label)
    
    # Animate entrance
    tween.interpolate_property(current_guidance_label, "modulate", 
        Color(1, 1, 1, 0), Color(1, 1, 1, 1), 
        0.5, Tween.TRANS_SINE, Tween.EASE_OUT)
    tween.start()
    
    # Play sound
    _play_sound("guidance")
    
    # Schedule auto-removal after a while
    var timer = Timer.new()
    timer.wait_time = 10.0 + importance * 10  # 10-20 seconds based on importance
    timer.one_shot = true
    timer.connect("timeout", self, "_fade_out_guidance")
    add_child(timer)
    timer.start()

func _fade_out_guidance():
    if current_guidance_label == null:
        return
    
    # Animate exit
    tween.interpolate_property(current_guidance_label, "modulate", 
        Color(1, 1, 1, 1), Color(1, 1, 1, 0), 
        1.0, Tween.TRANS_SINE, Tween.EASE_IN)
    tween.start()
    
    # Schedule removal
    yield(tween, "tween_completed")
    if current_guidance_label != null:
        current_guidance_label.queue_free()
        current_guidance_label = null

func _complete_action(action_type, success):
    if not active_actions.has(action_type):
        return
    
    var action = active_actions[action_type]
    
    # Stop any active tweens for this action
    tween.remove_all()
    
    # Visual feedback for success/failure
    var color = success_color if success else failure_color
    action.label.add_color_override("font_color", color)
    
    # Update text
    action.label.text = _get_action_result_text(action_type, success)
    
    # Play sound
    _play_sound("action_" + ("success" if success else "failure"))
    
    # Create result particles
    var particles = Particles2D.new()
    particles.position = Vector2(150, 30)  # Center of label
    particles.amount = particle_count * (2 if success else 1)
    particles.lifetime = 1.0
    particles.explosiveness = 0.6
    particles.process_material = particle_material.duplicate()
    particles.process_material.color = color
    particles.process_material.initial_velocity = 50.0 if success else 30.0
    particles.one_shot = true
    particles.emitting = true
    action.container.add_child(particles)
    active_particles.append(particles)
    
    # Emit signal
    emit_signal("action_completed", action_type, success)
    
    # Fade out
    tween.interpolate_property(action.container, "modulate", 
        Color(1, 1, 1, 1), Color(1, 1, 1, 0), 
        1.0, Tween.TRANS_SINE, Tween.EASE_IN)
    tween.start()
    
    # Schedule cleanup
    var timer = Timer.new()
    timer.wait_time = 1.0
    timer.one_shot = true
    timer.connect("timeout", self, "_cleanup_action", [action_type])
    add_child(timer)
    timer.start()

func _auto_fail_action(action_type):
    # Only fail if still waiting for input
    if waiting_for_input and current_action_type == action_type:
        _complete_action(action_type, false)
        waiting_for_input = false

func _cleanup_visual_event(event_type, container):
    # Animate exit
    tween.interpolate_property(container, "modulate", 
        Color(1, 1, 1, 1), Color(1, 1, 1, 0), 
        0.5, Tween.TRANS_SINE, Tween.EASE_IN)
    tween.start()
    
    # Schedule removal
    yield(tween, "tween_completed")
    if is_instance_valid(container) and container.get_parent() == self:
        container.queue_free()
    
    # Remove from active events
    for key in active_events.keys():
        if active_events[key].container == container:
            active_events.erase(key)
            break
    
    # Signal completion
    emit_signal("visualization_finished", event_type)

func _cleanup_action(action_type):
    if !active_actions.has(action_type):
        return
    
    var container = active_actions[action_type].container
    if is_instance_valid(container) and container.get_parent() == self:
        container.queue_free()
    
    active_actions.erase(action_type)

func _get_display_text_for_event(event_type, data):
    match event_type:
        "pattern_emergence":
            return "Pattern Emerging"
        "memory_integration":
            return "Memory Integration"
        "dimensional_shift":
            return "Dimension Shift"
        "neural_evolution":
            return "Neural Evolution"
        "time_acceleration":
            return "Time Acceleration"
        "reality_anchor":
            return "Reality Anchor"
        "word_manifestation":
            return "Word Manifesting"
        "player_action":
            if data.success:
                return data.reward
            else:
                return "Failed"
        _:
            return event_type.capitalize()

func _get_action_result_text(action_type, success):
    if success:
        match action_type:
            "connect_patterns":
                return "Patterns Connected!"
            "stabilize_dimension":
                return "Dimension Stabilized!"
            "capture_memory":
                return "Memory Captured!"
            "accelerate_evolution":
                return "Evolution Accelerated!"
            "word_power":
                return "Word Empowered!"
            _:
                return "Success!"
    else:
        match action_type:
            "connect_patterns":
                return "Patterns Scattered"
            "stabilize_dimension":
                return "Dimension Unstable"
            "capture_memory":
                return "Memory Faded"
            "accelerate_evolution":
                return "Evolution Stalled"
            "word_power":
                return "Word Weakened"
            _:
                return "Failed"

func _play_sound(sound_name):
    # In a real implementation, you would load and play actual sound files
    # For now, we'll just print the sound being played
    print("Playing sound: ", sound_name)

func _create_radial_texture(size, color):
    # Create a radial gradient texture for glow effects
    var image = Image.new()
    image.create(size, size, false, Image.FORMAT_RGBA8)
    
    image.lock()
    
    var center_x = size / 2
    var center_y = size / 2
    var max_dist = size / 2
    
    for x in range(size):
        for y in range(size):
            var dist = sqrt(pow(x - center_x, 2) + pow(y - center_y, 2))
            var alpha = 1.0 - min(dist / max_dist, 1.0)
            alpha = pow(alpha, 2)  # Square for smoother falloff
            
            var pixel_color = Color(color.r, color.g, color.b, color.a * alpha)
            image.set_pixel(x, y, pixel_color)
    
    image.unlock()
    
    var texture = ImageTexture.new()
    texture.create_from_image(image)
    
    return texture

func clear_all_visualizations():
    # Clear all active events
    for key in active_events.keys():
        var container = active_events[key].container
        if is_instance_valid(container):
            container.queue_free()
    
    active_events.clear()
    
    # Clear all active actions
    for key in active_actions.keys():
        var container = active_actions[key].container
        if is_instance_valid(container):
            container.queue_free()
    
    active_actions.clear()
    
    # Clear guidance
    if current_guidance_label != null:
        current_guidance_label.queue_free()
        current_guidance_label = null
    
    # Reset input state
    waiting_for_input = false
    current_action_type = ""
    
    # Clear particles
    active_particles.clear()
    
    # Stop all animations
    tween.remove_all()
    animation_player.stop()
    
    # Stop all timers
    for child in get_children():
        if child is Timer:
            child.stop()

func get_active_event_count():
    return active_events.size()

func get_active_action_count():
    return active_actions.size()