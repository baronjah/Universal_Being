extends Control

# virtual_keyboard.gd
# Advanced virtual keyboard with gradient keys, rounded corners,
# and responsive visual feedback for Ethereal Engine

# Configuration
export var enable_animations = true
export var enable_sound = true
export var use_rounded_keys = true
export var use_gradients = true
export var key_size = Vector2(60, 60)
export var key_margin = Vector2(5, 5)
export var corner_radius = 10.0

# Layout settings
export var keyboard_scale = 1.0
export var row_count = 4
export var layout_type = "QWERTY"  # QWERTY, AZERTY, NUMERIC
export var additional_keys = true  # Include special keys

# Visual settings
export var background_color = Color(0.12, 0.12, 0.14, 0.9)
export var key_color = Color(0.2, 0.2, 0.22, 1.0)
export var text_color = Color(0.9, 0.9, 0.9, 1.0)
export var gradient_intensity = 0.7
export var glow_intensity = 0.3
export var key_press_scale = 0.9
export var feedback_duration = 0.15  # seconds

# Gradient colors (will interpolate between these)
export var gradient_colors = [
    Color(0.0, 0.5, 1.0, 1.0),   # Blue
    Color(0.8, 0.3, 1.0, 1.0),   # Purple 
    Color(1.0, 0.4, 0.4, 1.0),   # Salmon/Red
    Color(1.0, 0.8, 0.0, 1.0),   # Gold
    Color(0.0, 0.8, 0.5, 1.0)    # Teal
]

# Internal state
var keys = []
var key_states = {}
var pressed_keys = []
var current_layout = []
var keyboard_rect = Rect2()
var is_visible = true
var is_shift_active = false
var is_symbols_active = false

# Animation
var tween_manager = null
var animation_queue = []

# Integration
var eye_tracking_system = null

# Signals
signal key_pressed(key_value)
signal keyboard_hidden()
signal keyboard_shown()
signal pattern_detected(pattern)

# ===== INITIALIZATION =====

func _ready():
    # Set up tween for animations
    tween_manager = Tween.new()
    add_child(tween_manager)
    
    # Initialize keyboard
    _create_keyboard_layout()
    
    # Connect to eye tracking system if available
    _connect_to_systems()
    
    # Initialize processing
    set_process(true)
    set_process_input(true)

# Create keyboard layout
func _create_keyboard_layout():
    keys.clear()
    key_states.clear()
    
    # Get base layout
    current_layout = _get_layout(layout_type)
    
    # Calculate keyboard dimensions
    var max_keys_in_row = 0
    for row in current_layout:
        max_keys_in_row = max(max_keys_in_row, row.size())
    
    var keyboard_width = (key_size.x + key_margin.x) * max_keys_in_row + key_margin.x
    var keyboard_height = (key_size.y + key_margin.y) * row_count + key_margin.y
    
    keyboard_rect = Rect2(
        (get_viewport_rect().size.x - keyboard_width * keyboard_scale) / 2,
        get_viewport_rect().size.y - keyboard_height * keyboard_scale - 20,
        keyboard_width * keyboard_scale,
        keyboard_height * keyboard_scale
    )
    
    # Create key objects
    var y_offset = keyboard_rect.position.y + key_margin.y * keyboard_scale
    
    for row_index in range(current_layout.size()):
        var row = current_layout[row_index]
        var row_width = (key_size.x + key_margin.x) * row.size() + key_margin.x
        var x_offset = keyboard_rect.position.x + (keyboard_rect.size.x - row_width * keyboard_scale) / 2
        
        for col_index in range(row.size()):
            var key_info = row[col_index]
            var key_width = key_size.x
            
            # Handle special-width keys
            if key_info.has("width"):
                key_width = key_size.x * key_info.width
            
            # Create key object
            var key = {
                "id": key_info.id,
                "value": key_info.value,
                "shift_value": key_info.get("shift_value", key_info.value.to_upper()),
                "symbols_value": key_info.get("symbols_value", key_info.value),
                "rect": Rect2(
                    x_offset,
                    y_offset,
                    key_width * keyboard_scale,
                    key_size.y * keyboard_scale
                ),
                "color": key_color,
                "gradient": _generate_key_gradient(),
                "type": key_info.get("type", "standard"),
                "pressed": false,
                "hover": false,
                "scale": 1.0,
                "opacity": 1.0,
                "glow": 0.0
            }
            
            keys.append(key)
            key_states[key.id] = {
                "pressed": false,
                "hover": false,
                "scale": 1.0,
                "opacity": 1.0,
                "glow": 0.0,
                "animation": null
            }
            
            # Move to next key position
            x_offset += (key_width + key_margin.x) * keyboard_scale
        
        # Move to next row
        y_offset += (key_size.y + key_margin.y) * keyboard_scale

# Generate a gradient for a key
func _generate_key_gradient():
    # Get 2-3 random colors
    var colors = []
    var count = 2 + int(randf() * 2)  # 2-3 colors
    
    for i in range(count):
        var color_index = randi() % gradient_colors.size()
        var color = gradient_colors[color_index]
        # Slightly vary the color
        color = Color(
            clamp(color.r + (randf() - 0.5) * 0.1, 0, 1),
            clamp(color.g + (randf() - 0.5) * 0.1, 0, 1),
            clamp(color.b + (randf() - 0.5) * 0.1, 0, 1),
            color.a
        )
        colors.append(color)
    
    # Generate 2-3 points for gradient
    var points = []
    for i in range(count):
        points.append({
            "position": Vector2(randf(), randf()),
            "color": colors[i],
            "size": 0.3 + randf() * 0.7
        })
    
    return {
        "colors": colors,
        "points": points,
        "intensity": gradient_intensity
    }

# Get keyboard layout definition
func _get_layout(layout_name):
    match layout_name:
        "QWERTY":
            return [
                [
                    {"id": "q", "value": "q"},
                    {"id": "w", "value": "w"},
                    {"id": "e", "value": "e"},
                    {"id": "r", "value": "r"},
                    {"id": "t", "value": "t"},
                    {"id": "y", "value": "y"},
                    {"id": "u", "value": "u"},
                    {"id": "i", "value": "i"},
                    {"id": "o", "value": "o"},
                    {"id": "p", "value": "p"}
                ],
                [
                    {"id": "a", "value": "a"},
                    {"id": "s", "value": "s"},
                    {"id": "d", "value": "d"},
                    {"id": "f", "value": "f"},
                    {"id": "g", "value": "g"},
                    {"id": "h", "value": "h"},
                    {"id": "j", "value": "j"},
                    {"id": "k", "value": "k"},
                    {"id": "l", "value": "l"}
                ],
                [
                    {"id": "shift", "value": "⇧", "shift_value": "⇧", "type": "modifier", "width": 1.5},
                    {"id": "z", "value": "z"},
                    {"id": "x", "value": "x"},
                    {"id": "c", "value": "c"},
                    {"id": "v", "value": "v"},
                    {"id": "b", "value": "b"},
                    {"id": "n", "value": "n"},
                    {"id": "m", "value": "m"},
                    {"id": "backspace", "value": "⌫", "shift_value": "⌫", "type": "special", "width": 1.5}
                ],
                [
                    {"id": "symbols", "value": "123", "shift_value": "123", "type": "modifier", "width": 1.5},
                    {"id": "globe", "value": "🌐", "shift_value": "🌐", "type": "special"},
                    {"id": "space", "value": " ", "shift_value": " ", "type": "space", "width": 4},
                    {"id": "dot", "value": ".", "shift_value": "."},
                    {"id": "return", "value": "⏎", "shift_value": "⏎", "type": "special", "width": 1.5}
                ]
            ]
        "NUMERIC":
            return [
                [
                    {"id": "1", "value": "1", "symbols_value": "1"},
                    {"id": "2", "value": "2", "symbols_value": "2"},
                    {"id": "3", "value": "3", "symbols_value": "3"},
                    {"id": "4", "value": "4", "symbols_value": "4"},
                    {"id": "5", "value": "5", "symbols_value": "5"},
                    {"id": "6", "value": "6", "symbols_value": "6"},
                    {"id": "7", "value": "7", "symbols_value": "7"},
                    {"id": "8", "value": "8", "symbols_value": "8"},
                    {"id": "9", "value": "9", "symbols_value": "9"},
                    {"id": "0", "value": "0", "symbols_value": "0"}
                ],
                [
                    {"id": "-", "value": "-", "symbols_value": "-"},
                    {"id": "/", "value": "/", "symbols_value": "/"},
                    {"id": ":", "value": ":", "symbols_value": ":"},
                    {"id": ";", "value": ";", "symbols_value": ";"},
                    {"id": "(", "value": "(", "symbols_value": "("},
                    {"id": ")", "value": ")", "symbols_value": ")"},
                    {"id": "$", "value": "$", "symbols_value": "$"},
                    {"id": "&", "value": "&", "symbols_value": "&"},
                    {"id": "@", "value": "@", "symbols_value": "@"}
                ],
                [
                    {"id": "symbols2", "value": "#+=", "shift_value": "#+=", "type": "modifier", "width": 1.5},
                    {"id": ".", "value": ".", "symbols_value": "."},
                    {"id": ",", "value": ",", "symbols_value": ","},
                    {"id": "?", "value": "?", "symbols_value": "?"},
                    {"id": "!", "value": "!", "symbols_value": "!"},
                    {"id": "'", "value": "'", "symbols_value": "'"},
                    {"id": "\"", "value": "\"", "symbols_value": "\""},
                    {"id": "backspace", "value": "⌫", "shift_value": "⌫", "type": "special", "width": 1.5}
                ],
                [
                    {"id": "abc", "value": "ABC", "shift_value": "ABC", "type": "modifier", "width": 1.5},
                    {"id": "globe", "value": "🌐", "shift_value": "🌐", "type": "special"},
                    {"id": "space", "value": " ", "shift_value": " ", "type": "space", "width": 4},
                    {"id": "dot", "value": ".", "shift_value": "."},
                    {"id": "return", "value": "⏎", "shift_value": "⏎", "type": "special", "width": 1.5}
                ]
            ]
        _:  # Default to QWERTY
            return _get_layout("QWERTY")

# Connect to other systems
func _connect_to_systems():
    # Try to find eye tracking system
    eye_tracking_system = get_node_or_null("/root/EyeTrackingSystem")
    if not eye_tracking_system and get_parent():
        eye_tracking_system = get_parent().get_node_or_null("EyeTrackingSystem")

# ===== MAIN LOOPS =====

func _process(delta):
    if not is_visible:
        return
    
    # Update animations
    _process_animations(delta)
    
    # Update gaze interactions if eye tracking is available
    if eye_tracking_system:
        _update_gaze_interactions()
    
    # Trigger redraw
    update()

func _input(event):
    if not is_visible:
        return
    
    # Handle mouse input
    if event is InputEventMouseMotion:
        _update_hover(event.position)
    
    # Handle mouse clicks
    elif event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
        _handle_click(event.position)

# ===== EVENT HANDLING =====

# Update hover state
func _update_hover(position):
    for key in keys:
        var was_hover = key.hover
        key.hover = key.rect.has_point(position)
        
        if key.hover != was_hover:
            # Update state
            key_states[key.id].hover = key.hover
            
            # Add visual feedback
            if key.hover:
                _animate_key_hover(key.id, true)
            else:
                _animate_key_hover(key.id, false)

# Handle mouse click
func _handle_click(position):
    for key in keys:
        if key.rect.has_point(position):
            _press_key(key.id)
            break

# Update interactions based on eye gaze
func _update_gaze_interactions():
    if not eye_tracking_system:
        return
    
    # Get current gaze position
    var gaze_position = eye_tracking_system.current_gaze_position
    
    # Check if gaze is on a key
    for key in keys:
        var was_hover = key.hover
        
        # Only update hover state if not already set by mouse
        if not key.hover:
            key.hover = key.rect.has_point(gaze_position)
            
            if key.hover != was_hover:
                # Update state
                key_states[key.id].hover = key.hover
                
                # Add subtle visual feedback for gaze hover
                if key.hover:
                    _animate_key_glow(key.id, true)
                else:
                    _animate_key_glow(key.id, false)

# ===== KEY ACTIONS =====

# Press a key
func _press_key(key_id):
    var key = _find_key_by_id(key_id)
    if not key:
        return
    
    # Update pressed state
    key.pressed = true
    key_states[key.id].pressed = true
    
    # Add to pressed keys list
    if not pressed_keys.has(key.id):
        pressed_keys.append(key.id)
    
    # Animate key press
    _animate_key_press(key.id)
    
    # Handle key action
    _handle_key_action(key)
    
    # Release key after a short delay
    yield(get_tree().create_timer(0.1), "timeout")
    _release_key(key.id)

# Release a key
func _release_key(key_id):
    var key = _find_key_by_id(key_id)
    if not key:
        return
    
    # Update pressed state
    key.pressed = false
    key_states[key.id].pressed = false
    
    # Remove from pressed keys list
    var index = pressed_keys.find(key.id)
    if index >= 0:
        pressed_keys.remove(index)
    
    # Animate key release
    _animate_key_release(key.id)

# Handle key action
func _handle_key_action(key):
    match key.type:
        "modifier":
            if key.id == "shift":
                is_shift_active = !is_shift_active
            elif key.id == "symbols" or key.id == "abc":
                is_symbols_active = !is_symbols_active
                _update_key_display()
        "special":
            if key.id == "backspace":
                emit_signal("key_pressed", "BACKSPACE")
            elif key.id == "return":
                emit_signal("key_pressed", "RETURN")
            elif key.id == "globe":
                _toggle_layout()
        _:  # Standard keys
            var value = key.value
            if is_shift_active:
                value = key.shift_value
            elif is_symbols_active:
                value = key.symbols_value
            
            emit_signal("key_pressed", value)
            
            # If shift is active and not locked, deactivate after typing a character
            if is_shift_active and key.type != "modifier":
                is_shift_active = false
                _update_key_display()

# Update key display based on shift/symbols state
func _update_key_display():
    # This would update the visual appearance of keys
    # based on shift and symbols state
    update()  # Trigger redraw

# Toggle between layouts
func _toggle_layout():
    if layout_type == "QWERTY":
        layout_type = "NUMERIC"
    else:
        layout_type = "QWERTY"
    
    _create_keyboard_layout()

# ===== ANIMATIONS =====

# Process animations
func _process_animations(delta):
    # Process animation queue
    var i = 0
    while i < animation_queue.size():
        var anim = animation_queue[i]
        
        anim.time += delta
        var progress = min(1.0, anim.time / anim.duration)
        
        # Apply animation
        match anim.type:
            "press":
                var scale = 1.0 - (1.0 - key_press_scale) * progress
                key_states[anim.key_id].scale = scale
            "release":
                var scale = key_press_scale + (1.0 - key_press_scale) * progress
                key_states[anim.key_id].scale = scale
            "hover":
                var glow = anim.from + (anim.to - anim.from) * progress
                key_states[anim.key_id].glow = glow
            "opacity":
                var opacity = anim.from + (anim.to - anim.from) * progress
                key_states[anim.key_id].opacity = opacity
        
        # Check if animation is complete
        if progress >= 1.0:
            animation_queue.remove(i)
        else:
            i += 1
    
    # Apply animation states to keys
    for key in keys:
        var state = key_states[key.id]
        key.scale = state.scale
        key.opacity = state.opacity
        key.glow = state.glow
        key.pressed = state.pressed
        key.hover = state.hover

# Animate key press
func _animate_key_press(key_id):
    if not enable_animations:
        return
    
    # Cancel existing animations for this key
    _cancel_animations_for_key(key_id)
    
    # Add press animation
    animation_queue.append({
        "key_id": key_id,
        "type": "press",
        "time": 0.0,
        "duration": feedback_duration
    })
    
    # Add glow animation
    animation_queue.append({
        "key_id": key_id,
        "type": "hover",
        "from": 0.0,
        "to": 1.0,
        "time": 0.0,
        "duration": feedback_duration
    })

# Animate key release
func _animate_key_release(key_id):
    if not enable_animations:
        return
    
    # Cancel existing animations for this key
    _cancel_animations_for_key(key_id)
    
    # Add release animation
    animation_queue.append({
        "key_id": key_id,
        "type": "release",
        "time": 0.0,
        "duration": feedback_duration
    })
    
    # Add glow fade animation
    animation_queue.append({
        "key_id": key_id,
        "type": "hover",
        "from": key_states[key_id].glow,
        "to": 0.0,
        "time": 0.0,
        "duration": feedback_duration * 2.0
    })

# Animate key hover
func _animate_key_hover(key_id, is_hover):
    if not enable_animations:
        return
    
    # Cancel existing hover animations
    _cancel_animations_for_key(key_id, "hover")
    
    # Add hover animation
    animation_queue.append({
        "key_id": key_id,
        "type": "hover",
        "from": key_states[key_id].glow,
        "to": is_hover ? 0.5 : 0.0,
        "time": 0.0,
        "duration": feedback_duration * 2.0
    })

# Animate key glow
func _animate_key_glow(key_id, is_glow):
    if not enable_animations:
        return
    
    # Cancel existing glow animations
    _cancel_animations_for_key(key_id, "hover")
    
    # Add glow animation (more subtle than hover)
    animation_queue.append({
        "key_id": key_id,
        "type": "hover",
        "from": key_states[key_id].glow,
        "to": is_glow ? 0.3 : 0.0,
        "time": 0.0,
        "duration": feedback_duration * 3.0
    })

# Cancel animations for a key
func _cancel_animations_for_key(key_id, type=null):
    var i = 0
    while i < animation_queue.size():
        var anim = animation_queue[i]
        
        if anim.key_id == key_id and (type == null or anim.type == type):
            animation_queue.remove(i)
        else:
            i += 1

# ===== RENDERING =====

func _draw():
    if not is_visible:
        return
    
    # Draw keyboard background
    if use_rounded_corners:
        _draw_rounded_rect(keyboard_rect, background_color, corner_radius)
    else:
        draw_rect(keyboard_rect, background_color)
    
    # Draw keys
    for key in keys:
        _draw_key(key)

# Draw a key
func _draw_key(key):
    var key_rect = key.rect
    
    # Apply scale
    if key.scale != 1.0:
        var center = key_rect.position + key_rect.size * 0.5
        var scaled_size = key_rect.size * key.scale
        key_rect = Rect2(
            center - scaled_size * 0.5,
            scaled_size
        )
    
    # Draw key background
    var key_bg_color = key.color
    key_bg_color.a *= key.opacity
    
    if use_rounded_corners:
        _draw_rounded_rect(key_rect, key_bg_color, corner_radius * keyboard_scale)
    else:
        draw_rect(key_rect, key_bg_color)
    
    # Draw key gradient
    if use_gradients:
        _draw_key_gradient(key, key_rect)
    
    # Draw key glow
    if key.glow > 0.0:
        var glow_color = Color(1, 1, 1, key.glow * 0.3)
        if use_rounded_corners:
            _draw_rounded_rect(key_rect, glow_color, corner_radius * keyboard_scale)
        else:
            draw_rect(key_rect, glow_color)
    
    # Draw key text
    var key_text = key.value
    if is_shift_active:
        key_text = key.shift_value
    elif is_symbols_active:
        key_text = key.symbols_value
    
    # Calculate font size (approximately half key height)
    var font_size = key_rect.size.y * 0.5
    
    # Draw centered text
    var font = Control.new().get_font("font")
    var text_pos = key_rect.position + key_rect.size * 0.5 - Vector2(font.get_string_size(key_text).x / 2, font_size / 2)
    
    draw_string(font, text_pos, key_text, text_color)

# Draw a key gradient
func _draw_key_gradient(key, key_rect):
    var gradient = key.gradient
    
    for point in gradient.points:
        var position = key_rect.position + Vector2(
            key_rect.size.x * point.position.x,
            key_rect.size.y * point.position.y
        )
        
        var size = min(key_rect.size.x, key_rect.size.y) * point.size
        var color = point.color
        color.a *= gradient.intensity * key.opacity
        
        draw_circle(position, size, color)

# Draw a rounded rectangle
func _draw_rounded_rect(rect, color, radius):
    # Corners
    var top_left = rect.position
    var top_right = Vector2(rect.position.x + rect.size.x, rect.position.y)
    var bottom_left = Vector2(rect.position.x, rect.position.y + rect.size.y)
    var bottom_right = rect.position + rect.size
    
    # Draw corner arcs
    draw_circle(top_left + Vector2(radius, radius), radius, color)
    draw_circle(top_right + Vector2(-radius, radius), radius, color)
    draw_circle(bottom_left + Vector2(radius, -radius), radius, color)
    draw_circle(bottom_right + Vector2(-radius, -radius), radius, color)
    
    # Draw rect sections
    # Center
    draw_rect(Rect2(top_left.x + radius, top_left.y, rect.size.x - radius * 2, rect.size.y), color)
    # Left
    draw_rect(Rect2(top_left.x, top_left.y + radius, radius, rect.size.y - radius * 2), color)
    # Right
    draw_rect(Rect2(top_right.x - radius, top_right.y + radius, radius, rect.size.y - radius * 2), color)

# ===== HELPERS =====

# Find a key by ID
func _find_key_by_id(key_id):
    for key in keys:
        if key.id == key_id:
            return key
    
    return null

# ===== PUBLIC API =====

# Show keyboard
func show_keyboard():
    if not is_visible:
        is_visible = true
        
        # Animate appearance
        if enable_animations:
            # Fade in all keys
            for key in keys:
                key_states[key.id].opacity = 0.0
                
                animation_queue.append({
                    "key_id": key.id,
                    "type": "opacity",
                    "from": 0.0,
                    "to": 1.0,
                    "time": 0.0,
                    "duration": 0.3
                })
        
        emit_signal("keyboard_shown")
    
    return true

# Hide keyboard
func hide_keyboard():
    if is_visible:
        # Animate disappearance
        if enable_animations:
            # Fade out all keys
            for key in keys:
                animation_queue.append({
                    "key_id": key.id,
                    "type": "opacity",
                    "from": key_states[key.id].opacity,
                    "to": 0.0,
                    "time": 0.0,
                    "duration": 0.2
                })
            
            # Wait for animation before hiding
            yield(get_tree().create_timer(0.2), "timeout")
        
        is_visible = false
        emit_signal("keyboard_hidden")
    
    return true

# Toggle keyboard visibility
func toggle_keyboard():
    if is_visible:
        return hide_keyboard()
    else:
        return show_keyboard()

# Change keyboard layout
func set_layout(new_layout_type):
    if new_layout_type in ["QWERTY", "AZERTY", "NUMERIC"]:
        layout_type = new_layout_type
        _create_keyboard_layout()
        return true
    
    return false

# Set keyboard scale
func set_scale(scale):
    keyboard_scale = clamp(scale, 0.5, 2.0)
    _create_keyboard_layout()
    return keyboard_scale

# Set visual theme
func set_theme(colors):
    if colors.has("background"):
        background_color = colors.background
    
    if colors.has("key"):
        key_color = colors.key
    
    if colors.has("text"):
        text_color = colors.text
    
    if colors.has("gradients") and colors.gradients is Array:
        gradient_colors = colors.gradients
    
    update()
    return true

# Simulate key press
func simulate_press(key_value):
    for key in keys:
        if key.value == key_value or key.shift_value == key_value or key.symbols_value == key_value:
            _press_key(key.id)
            return true
    
    return false

# Set sound feedback
func set_sound_enabled(enabled):
    enable_sound = enabled
    return enable_sound