extends Node

class_name TaskTransitionAnimator

# ----- ANIMATION SETTINGS -----
@export_category("Animation Settings")
@export var enabled: bool = true
@export var default_duration: float = 0.5
@export var default_easing: int = Tween.EASE_IN_OUT
@export var default_transition_type: int = Tween.TRANS_SINE
@export var auto_start_animations: bool = true
@export var use_color_themes: bool = true
@export var particle_effects_enabled: bool = true

# ----- TRANSITION TYPES -----
enum TransitionType {
    FADE,          # Simple fade transition
    SLIDE,         # Slide from one side
    ZOOM,          # Zoom in/out
    FLIP,          # 3D flip effect
    DISSOLVE,      # Dissolve with particles
    PIXEL,         # Pixelate transition
    COLOR_WIPE,    # Color wipe effect
    GLITCH,        # Glitch effect
    BOUNCE,        # Elastic/bounce effect
    WAVE           # Wave distortion
}

# ----- STATE VARIABLES -----
var active_transitions = {}
var pending_transitions = []
var next_transition_id = 0
var ui_nodes = {}
var color_system = null
var animation_player = null
var tween = null

# ----- SIGNALS -----
signal transition_started(id, type, from_task, to_task)
signal transition_completed(id, type, task)
signal transition_cancelled(id)
signal task_focused(task_id)
signal task_blurred(task_id)

# ----- INITIALIZATION -----
func _ready():
    # Look for color system
    color_system = get_node_or_null("/root/ExtendedColorThemeSystem")
    
    if not color_system:
        color_system = get_node_or_null("/root/DimensionalColorSystem")
    
    if not color_system:
        color_system = _find_node_by_class(get_tree().root, "DimensionalColorSystem")
    
    if not color_system:
        color_system = _find_node_by_class(get_tree().root, "ColorAnimationSystem")
    
    print("Color system found: " + str(color_system != null))
    
    # Create animation player
    animation_player = AnimationPlayer.new()
    add_child(animation_player)
    
    # Create tween for animations
    tween = create_tween()
    tween.set_loops(0) # No looping
    tween.stop() # Don't start yet
    
    print("Task Transition Animator initialized")
    
    # Create default animations
    _create_default_animations()

func _find_node_by_class(node, class_name_str):
    if node.get_class() == class_name_str or (node.get_script() and node.get_script().get_path().find(class_name_str.to_lower()) >= 0):
        return node
    
    for child in node.get_children():
        var found = _find_node_by_class(child, class_name_str)
        if found:
            return found
    
    return null

func _create_default_animations():
    # Create default animations for common transitions
    var animation_library = AnimationLibrary.new()
    
    # Fade animation
    var fade_anim = Animation.new()
    var track_index = fade_anim.add_track(Animation.TYPE_VALUE)
    fade_anim.track_set_path(track_index, ".:modulate:a")
    fade_anim.track_insert_key(track_index, 0.0, 0.0)
    fade_anim.track_insert_key(track_index, 0.5, 1.0)
    animation_library.add_animation("fade_in", fade_anim)
    
    # Slide animation
    var slide_anim = Animation.new()
    track_index = slide_anim.add_track(Animation.TYPE_VALUE)
    slide_anim.track_set_path(track_index, ".:position:x")
    slide_anim.track_insert_key(track_index, 0.0, -300)
    slide_anim.track_insert_key(track_index, 0.5, 0)
    animation_library.add_animation("slide_in", slide_anim)
    
    # Zoom animation
    var zoom_anim = Animation.new()
    track_index = zoom_anim.add_track(Animation.TYPE_VALUE)
    zoom_anim.track_set_path(track_index, ".:scale")
    zoom_anim.track_insert_key(track_index, 0.0, Vector2(0.5, 0.5))
    zoom_anim.track_insert_key(track_index, 0.5, Vector2(1.0, 1.0))
    animation_library.add_animation("zoom_in", zoom_anim)
    
    # Add library to animation player
    animation_player.add_animation_library("transitions", animation_library)

# ----- PUBLIC API -----
func register_ui_node(task_id: String, node: Control) -> void:
    # Register a UI node for animations
    
    if ui_nodes.has(task_id):
        print("Replacing existing UI node for task: " + task_id)
    
    ui_nodes[task_id] = node
    
    print("Registered UI node for task: " + task_id)

func unregister_ui_node(task_id: String) -> void:
    # Unregister a UI node
    
    if ui_nodes.has(task_id):
        ui_nodes.erase(task_id)
        print("Unregistered UI node for task: " + task_id)
    else:
        print("No UI node found for task: " + task_id)

func transition(from_task: String, to_task: String, type: int = TransitionType.FADE, duration: float = -1) -> int:
    # Perform a transition between two tasks
    
    if not enabled:
        print("Transitions are disabled")
        return -1
    
    # Check if UI nodes exist
    if not ui_nodes.has(from_task):
        print("No UI node found for from_task: " + from_task)
        return -1
    
    if not ui_nodes.has(to_task):
        print("No UI node found for to_task: " + to_task)
        return -1
    
    # Use default duration if not specified
    var transition_duration = duration if duration > 0 else default_duration
    
    # Generate transition ID
    var transition_id = _get_next_transition_id()
    
    # Create transition data
    var transition_data = {
        "id": transition_id,
        "type": type,
        "from_task": from_task,
        "to_task": to_task,
        "from_node": ui_nodes[from_task],
        "to_node": ui_nodes[to_task],
        "duration": transition_duration,
        "progress": 0.0,
        "start_time": Time.get_ticks_msec()
    }
    
    # Add to active transitions
    active_transitions[transition_id] = transition_data
    
    # Start the transition
    _start_transition(transition_id)
    
    return transition_id

func focus_task(task_id: String, with_animation: bool = true) -> bool:
    # Focus on a specific task
    
    if not ui_nodes.has(task_id):
        print("No UI node found for task: " + task_id)
        return false
    
    print("Focusing task: " + task_id)
    
    var node = ui_nodes[task_id]
    
    if with_animation and enabled:
        # Animate the focus
        if tween.is_running():
            tween.stop()
        
        tween = create_tween()
        tween.set_ease(default_easing)
        tween.set_trans(default_transition_type)
        
        # Ensure node is visible
        node.visible = true
        node.modulate.a = 0.5
        
        # Animate
        tween.tween_property(node, "modulate:a", 1.0, default_duration / 2)
        
        # Optional: add highlight effect if color system available
        if color_system and use_color_themes:
            _apply_focus_color(task_id)
    else:
        # Just show without animation
        node.visible = true
        node.modulate.a = 1.0
    
    emit_signal("task_focused", task_id)
    
    return true

func blur_task(task_id: String, with_animation: bool = true) -> bool:
    # Blur/unfocus a specific task
    
    if not ui_nodes.has(task_id):
        print("No UI node found for task: " + task_id)
        return false
    
    print("Blurring task: " + task_id)
    
    var node = ui_nodes[task_id]
    
    if with_animation and enabled:
        # Animate the blur
        if tween.is_running():
            tween.stop()
        
        tween = create_tween()
        tween.set_ease(default_easing)
        tween.set_trans(default_transition_type)
        
        # Animate
        tween.tween_property(node, "modulate:a", 0.5, default_duration / 2)
        
        # Remove highlight if color system available
        if color_system and use_color_themes:
            _remove_focus_color(task_id)
    else:
        # Just blur without animation
        node.modulate.a = 0.5
    
    emit_signal("task_blurred", task_id)
    
    return true

func cancel_transition(transition_id: int) -> bool:
    # Cancel an active transition
    
    if not active_transitions.has(transition_id):
        print("No active transition found with ID: " + str(transition_id))
        return false
    
    var transition_data = active_transitions[transition_id]
    
    print("Cancelling transition: " + str(transition_id))
    
    # Stop the tween if it's for this transition
    if tween.is_running():
        tween.stop()
    
    # Remove from active transitions
    active_transitions.erase(transition_id)
    
    emit_signal("transition_cancelled", transition_id)
    
    return true

func cancel_all_transitions() -> void:
    # Cancel all active transitions
    
    var transition_ids = active_transitions.keys()
    
    for id in transition_ids:
        cancel_transition(id)
    
    print("Cancelled all transitions")

func set_enabled(is_enabled: bool) -> void:
    # Enable or disable transitions
    enabled = is_enabled
    
    print("Transitions " + ("enabled" if enabled else "disabled"))

# ----- TRANSITION IMPLEMENTATIONS -----
func _start_transition(transition_id: int) -> void:
    # Start a specific transition
    
    if not active_transitions.has(transition_id):
        print("No transition found with ID: " + str(transition_id))
        return
    
    var transition = active_transitions[transition_id]
    
    print("Starting transition " + str(transition_id) + " from '" + 
          transition.from_task + "' to '" + transition.to_task + "' with type: " + 
          str(transition.type))
    
    # Signal start of transition
    emit_signal("transition_started", transition_id, transition.type, 
                transition.from_task, transition.to_task)
    
    # Initialize nodes for transition
    var from_node = transition.from_node
    var to_node = transition.to_node
    
    # Make sure both nodes are in the right initial state
    from_node.visible = true
    to_node.visible = true
    
    # Choose transition implementation based on type
    match transition.type:
        TransitionType.FADE:
            _execute_fade_transition(transition)
        TransitionType.SLIDE:
            _execute_slide_transition(transition)
        TransitionType.ZOOM:
            _execute_zoom_transition(transition)
        TransitionType.FLIP:
            _execute_flip_transition(transition)
        TransitionType.DISSOLVE:
            _execute_dissolve_transition(transition)
        TransitionType.PIXEL:
            _execute_pixel_transition(transition)
        TransitionType.COLOR_WIPE:
            _execute_color_wipe_transition(transition)
        TransitionType.GLITCH:
            _execute_glitch_transition(transition)
        TransitionType.BOUNCE:
            _execute_bounce_transition(transition)
        TransitionType.WAVE:
            _execute_wave_transition(transition)
        _:
            # Default to fade
            _execute_fade_transition(transition)

func _execute_fade_transition(transition):
    # Execute a fade transition
    
    var from_node = transition.from_node
    var to_node = transition.to_node
    var duration = transition.duration
    
    # Set initial state
    from_node.modulate.a = 1.0
    to_node.modulate.a = 0.0
    
    # Create new tween for this transition
    if tween.is_running():
        tween.stop()
    
    tween = create_tween()
    tween.set_parallel(true)
    tween.set_ease(default_easing)
    tween.set_trans(default_transition_type)
    
    # Fade out from_node
    tween.tween_property(from_node, "modulate:a", 0.0, duration / 2)
    
    # Fade in to_node with slight delay
    var to_node_tween = tween.tween_property(to_node, "modulate:a", 1.0, duration / 2)
    to_node_tween.set_delay(duration / 2)
    
    # Connect to completion
    tween.tween_callback(Callable(self, "_on_transition_completed").bind(transition.id))

func _execute_slide_transition(transition):
    # Execute a slide transition
    
    var from_node = transition.from_node
    var to_node = transition.to_node
    var duration = transition.duration
    
    # Set initial state
    from_node.modulate.a = 1.0
    to_node.modulate.a = 1.0
    
    # Store original positions
    var from_pos = from_node.position
    var to_pos = to_node.position
    
    # Set to_node off-screen to the right
    to_node.position.x = to_pos.x + from_node.get_rect().size.x
    
    # Create new tween for this transition
    if tween.is_running():
        tween.stop()
    
    tween = create_tween()
    tween.set_parallel(true)
    tween.set_ease(default_easing)
    tween.set_trans(default_transition_type)
    
    # Slide out from_node to the left
    tween.tween_property(from_node, "position:x", from_pos.x - from_node.get_rect().size.x, duration)
    
    # Slide in to_node from the right
    tween.tween_property(to_node, "position:x", to_pos.x, duration)
    
    # Connect to completion
    tween.tween_callback(Callable(self, "_on_transition_completed").bind(transition.id))

func _execute_zoom_transition(transition):
    # Execute a zoom transition
    
    var from_node = transition.from_node
    var to_node = transition.to_node
    var duration = transition.duration
    
    # Set initial state
    from_node.modulate.a = 1.0
    to_node.modulate.a = 0.0
    
    # Store original scales
    var from_scale = from_node.scale
    var to_scale = to_node.scale
    
    # Set to_node initial scale
    to_node.scale = Vector2(0.5, 0.5)
    
    # Create new tween for this transition
    if tween.is_running():
        tween.stop()
    
    tween = create_tween()
    tween.set_parallel(true)
    tween.set_ease(default_easing)
    tween.set_trans(default_transition_type)
    
    # Zoom out and fade out from_node
    tween.tween_property(from_node, "scale", Vector2(1.5, 1.5), duration / 2)
    tween.tween_property(from_node, "modulate:a", 0.0, duration / 2)
    
    # Zoom in and fade in to_node with delay
    var to_scale_tween = tween.tween_property(to_node, "scale", to_scale, duration / 2)
    to_scale_tween.set_delay(duration / 2)
    
    var to_fade_tween = tween.tween_property(to_node, "modulate:a", 1.0, duration / 2)
    to_fade_tween.set_delay(duration / 2)
    
    # Connect to completion
    tween.tween_callback(Callable(self, "_on_transition_completed").bind(transition.id))

func _execute_flip_transition(transition):
    # Execute a 3D flip transition
    # Note: This is simplified since Godot 2D doesn't directly support 3D transforms
    
    var from_node = transition.from_node
    var to_node = transition.to_node
    var duration = transition.duration
    
    # Set initial state
    from_node.modulate.a = 1.0
    to_node.modulate.a = 0.0
    
    # Original scales
    var from_scale = from_node.scale
    var to_scale = to_node.scale
    
    # Create new tween for this transition
    if tween.is_running():
        tween.stop()
    
    tween = create_tween()
    tween.set_parallel(false)  # Sequential for flip effect
    tween.set_ease(default_easing)
    tween.set_trans(default_transition_type)
    
    # First half of flip - scale from_node horizontally to 0
    tween.tween_property(from_node, "scale:x", 0.0, duration / 2)
    
    # At the midpoint, swap visibility
    tween.tween_callback(func():
        from_node.modulate.a = 0.0
        to_node.modulate.a = 1.0
        to_node.scale.x = 0.0
    )
    
    # Second half of flip - scale to_node horizontally from 0 to normal
    tween.tween_property(to_node, "scale:x", to_scale.x, duration / 2)
    
    # Connect to completion
    tween.tween_callback(Callable(self, "_on_transition_completed").bind(transition.id))

func _execute_dissolve_transition(transition):
    # Execute a dissolve transition with particles
    
    var from_node = transition.from_node
    var to_node = transition.to_node
    var duration = transition.duration
    
    # Set initial state
    from_node.modulate.a = 1.0
    to_node.modulate.a = 0.0
    
    # Create dissolve effect with shader if available
    # For this example, we'll just do a crossfade with a shader transition
    
    # Create new tween for this transition
    if tween.is_running():
        tween.stop()
    
    tween = create_tween()
    tween.set_parallel(true)
    tween.set_ease(default_easing)
    tween.set_trans(default_transition_type)
    
    # Fade out from_node
    tween.tween_property(from_node, "modulate:a", 0.0, duration)
    
    # Fade in to_node
    tween.tween_property(to_node, "modulate:a", 1.0, duration)
    
    # Connect to completion
    tween.tween_callback(Callable(self, "_on_transition_completed").bind(transition.id))
    
    # If particle effects are enabled, add some particles
    if particle_effects_enabled:
        # In a real implementation, would create particle effects
        # For this mock-up, we'll just print a message
        print("Particle dissolve effect would be shown here")

func _execute_pixel_transition(transition):
    # Execute a pixelate transition
    # Note: This would typically require a shader
    
    var from_node = transition.from_node
    var to_node = transition.to_node
    var duration = transition.duration
    
    # Set initial state
    from_node.modulate.a = 1.0
    to_node.modulate.a = 0.0
    
    # Create new tween for this transition
    if tween.is_running():
        tween.stop()
    
    tween = create_tween()
    tween.set_parallel(true)
    tween.set_ease(default_easing)
    tween.set_trans(default_transition_type)
    
    # Fade transitions
    tween.tween_property(from_node, "modulate:a", 0.0, duration)
    tween.tween_property(to_node, "modulate:a", 1.0, duration)
    
    # Connect to completion
    tween.tween_callback(Callable(self, "_on_transition_completed").bind(transition.id))
    
    print("Pixelate effect would be shown here (requires shader)")

func _execute_color_wipe_transition(transition):
    # Execute a color wipe transition
    # Note: This would typically require a shader
    
    var from_node = transition.from_node
    var to_node = transition.to_node
    var duration = transition.duration
    
    # Set initial state
    from_node.modulate.a = 1.0
    to_node.modulate.a = 0.0
    
    # Get a color for the wipe
    var wipe_color = Color(0.1, 0.4, 0.9, 1.0)  # Default blue
    
    if color_system and use_color_themes:
        if color_system.has_method("get_color"):
            wipe_color = color_system.get_color("primary")
    
    # Create new tween for this transition
    if tween.is_running():
        tween.stop()
    
    tween = create_tween()
    tween.set_parallel(false)  # Sequential for wipe effect
    tween.set_ease(default_easing)
    tween.set_trans(default_transition_type)
    
    # Fade out from_node
    tween.tween_property(from_node, "modulate:a", 0.0, duration / 2)
    
    # Color flash - would use shader in real implementation
    tween.tween_callback(func():
        to_node.modulate = wipe_color
        to_node.modulate.a = 1.0
    )
    
    # Color fade to normal
    tween.tween_property(to_node, "modulate", Color(1, 1, 1, 1), duration / 2)
    
    # Connect to completion
    tween.tween_callback(Callable(self, "_on_transition_completed").bind(transition.id))
    
    print("Color wipe effect would be shown here (requires shader)")

func _execute_glitch_transition(transition):
    # Execute a glitch transition
    # Note: This would typically require a shader and/or custom drawing
    
    var from_node = transition.from_node
    var to_node = transition.to_node
    var duration = transition.duration
    
    # Set initial state
    from_node.modulate.a = 1.0
    to_node.modulate.a = 0.0
    
    # Create new tween for this transition
    if tween.is_running():
        tween.stop()
    
    tween = create_tween()
    tween.set_parallel(true)
    tween.set_ease(default_easing)
    tween.set_trans(default_transition_type)
    
    # Fade transitions
    tween.tween_property(from_node, "modulate:a", 0.0, duration)
    tween.tween_property(to_node, "modulate:a", 1.0, duration)
    
    # Connect to completion
    tween.tween_callback(Callable(self, "_on_transition_completed").bind(transition.id))
    
    print("Glitch effect would be shown here (requires shader)")

func _execute_bounce_transition(transition):
    # Execute a bounce transition
    
    var from_node = transition.from_node
    var to_node = transition.to_node
    var duration = transition.duration
    
    # Set initial state
    from_node.modulate.a = 1.0
    to_node.modulate.a = 0.0
    
    # Store original scales
    var from_scale = from_node.scale
    var to_scale = to_node.scale
    
    # Set to_node initial scale
    to_node.scale = Vector2(0.3, 0.3)
    
    # Create new tween for this transition
    if tween.is_running():
        tween.stop()
    
    tween = create_tween()
    tween.set_parallel(true)
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_BOUNCE)
    
    # Shrink and fade out from_node
    tween.tween_property(from_node, "scale", Vector2(0.3, 0.3), duration / 2)
    tween.tween_property(from_node, "modulate:a", 0.0, duration / 2)
    
    # Grow and fade in to_node with delay
    var to_scale_tween = tween.tween_property(to_node, "scale", to_scale, duration / 2)
    to_scale_tween.set_delay(duration / 2)
    
    var to_fade_tween = tween.tween_property(to_node, "modulate:a", 1.0, duration / 2)
    to_fade_tween.set_delay(duration / 2)
    
    # Connect to completion
    tween.tween_callback(Callable(self, "_on_transition_completed").bind(transition.id))

func _execute_wave_transition(transition):
    # Execute a wave transition
    # Note: This would typically require a shader
    
    var from_node = transition.from_node
    var to_node = transition.to_node
    var duration = transition.duration
    
    # Set initial state
    from_node.modulate.a = 1.0
    to_node.modulate.a = 0.0
    
    # Create new tween for this transition
    if tween.is_running():
        tween.stop()
    
    tween = create_tween()
    tween.set_parallel(true)
    tween.set_ease(default_easing)
    tween.set_trans(default_transition_type)
    
    # Fade transitions
    tween.tween_property(from_node, "modulate:a", 0.0, duration)
    tween.tween_property(to_node, "modulate:a", 1.0, duration)
    
    # Connect to completion
    tween.tween_callback(Callable(self, "_on_transition_completed").bind(transition.id))
    
    print("Wave distortion effect would be shown here (requires shader)")

# ----- EVENT HANDLERS -----
func _on_transition_completed(transition_id: int):
    # Called when a transition completes
    
    if not active_transitions.has(transition_id):
        return
    
    var transition = active_transitions[transition_id]
    
    print("Transition " + str(transition_id) + " completed")
    
    # Clean up transition
    var from_node = transition.from_node
    var to_node = transition.to_node
    var from_task = transition.from_task
    var to_task = transition.to_task
    var type = transition.type
    
    # Remove from active transitions
    active_transitions.erase(transition_id)
    
    # Ensure final state
    from_node.modulate.a = 0.0
    to_node.modulate.a = 1.0
    
    # If the transition has special end states (like position/scale), reset them
    match type:
        TransitionType.SLIDE:
            # Reset positions to original
            from_node.position.x = 0
            to_node.position.x = 0
        TransitionType.ZOOM:
        TransitionType.FLIP:
        TransitionType.BOUNCE:
            # Reset scales
            from_node.scale = Vector2(1, 1)
            to_node.scale = Vector2(1, 1)
    
    # Hide from_node
    from_node.visible = false
    
    # Emit signal
    emit_signal("transition_completed", transition_id, type, to_task)
    
    # Apply focus color if color system available
    if color_system and use_color_themes:
        _apply_focus_color(to_task)

# ----- COLOR THEME INTEGRATION -----
func _apply_focus_color(task_id: String):
    # Apply a focus color to a task
    if not color_system:
        return
    
    if not ui_nodes.has(task_id):
        return
    
    var node = ui_nodes[task_id]
    
    # Different color systems may have different APIs
    if color_system.has_method("get_color"):
        var highlight_color = color_system.get_color("highlight")
        
        # Apply highlight
        if node.has_method("set_highlight_color"):
            node.set_highlight_color(highlight_color)
        else:
            # Basic fallback - just add a colored outline
            if node.has_method("set_outline_color"):
                node.set_outline_color(highlight_color)
    elif color_system.has_method("start_pulse_animation"):
        # For color animation system
        if node.has_node("Background"):
            var bg = node.get_node("Background")
            color_system.start_pulse_animation(task_id, bg.color, Color(0.4, 0.6, 1.0))

func _remove_focus_color(task_id: String):
    # Remove focus color from a task
    if not color_system:
        return
    
    if not ui_nodes.has(task_id):
        return
    
    var node = ui_nodes[task_id]
    
    # Different color systems may have different APIs
    if color_system.has_method("get_color"):
        var normal_color = color_system.get_color("border")
        
        # Remove highlight
        if node.has_method("set_highlight_color"):
            node.set_highlight_color(normal_color)
        else:
            # Basic fallback - remove colored outline
            if node.has_method("set_outline_color"):
                node.set_outline_color(normal_color)
    elif color_system.has_method("stop_animation"):
        # For color animation system
        color_system.stop_animation(task_id)

# ----- UTILITY METHODS -----
func _get_next_transition_id() -> int:
    next_transition_id += 1
    return next_transition_id

func get_transition_type_name(type: int) -> String:
    # Get the name of a transition type
    
    match type:
        TransitionType.FADE:
            return "Fade"
        TransitionType.SLIDE:
            return "Slide"
        TransitionType.ZOOM:
            return "Zoom"
        TransitionType.FLIP:
            return "Flip"
        TransitionType.DISSOLVE:
            return "Dissolve"
        TransitionType.PIXEL:
            return "Pixel"
        TransitionType.COLOR_WIPE:
            return "Color Wipe"
        TransitionType.GLITCH:
            return "Glitch"
        TransitionType.BOUNCE:
            return "Bounce"
        TransitionType.WAVE:
            return "Wave"
        _:
            return "Unknown"

func get_available_transitions() -> Array:
    # Get list of available transition types
    return [
        TransitionType.FADE,
        TransitionType.SLIDE,
        TransitionType.ZOOM,
        TransitionType.FLIP,
        TransitionType.DISSOLVE,
        TransitionType.PIXEL,
        TransitionType.COLOR_WIPE,
        TransitionType.GLITCH,
        TransitionType.BOUNCE,
        TransitionType.WAVE
    ]