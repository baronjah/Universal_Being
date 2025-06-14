extends Node
class_name AnimationSystem

"""
AnimationSystem
--------------
Creates animated visual effects for the dual memories system, including:
1. Text falling in 3D space from writing into flat shapes
2. Animated transitions between terminals
3. Color shifting and flowing animations
4. Akashic records visualization with flowing patterns
5. Shape morphing for memory fragments

The animation system integrates with all terminals and memory displays to
create a dynamic, visually engaging interface that reflects the dimensional
nature of the memory systems.
"""

# System references
var dual_memories_coordinator: DualMemoriesCoordinator
var terminal_split_controller: TerminalSplitController

# Animation settings
var animation_enabled = true
var animation_speed = 1.0
var use_3d_effects = true
var particle_effects_enabled = true

# Color scheme
var color_scheme = {
    "primary": Color(0.5, 0.0, 1.0),    # Purple
    "secondary": Color(0.0, 0.5, 1.0),  # Blue
    "tertiary": Color(1.0, 0.5, 0.0),   # Orange
    "accent1": Color(1.0, 0.8, 0.0),    # Gold
    "accent2": Color(0.0, 0.8, 0.4),    # Teal
    "background": Color(0.1, 0.1, 0.15), # Dark blue-gray
    "text": Color(0.9, 0.9, 0.95)       # Light gray
}

# Animation states
var active_animations = {}
var animation_queue = []
var current_shape = "cube"
var current_entrance_effect = "falling"

# Particle systems
var particle_emitters = {}
var shape_morphing_data = {}

# Signals
signal animation_started(animation_id, type)
signal animation_completed(animation_id)
signal color_scheme_changed(old_scheme, new_scheme)
signal shape_morphed(old_shape, new_shape)

# Initialize the animation system
func _init():
    # Initialize basic animation states
    _setup_default_animations()

# Setup with system references
func initialize(memories_coordinator: DualMemoriesCoordinator = null, 
                split_controller: TerminalSplitController = null):
    
    dual_memories_coordinator = memories_coordinator
    terminal_split_controller = split_controller
    
    # Connect signals if available
    if dual_memories_coordinator:
        dual_memories_coordinator.connect("meaning_transformed", self, "_on_meaning_transformed")
        dual_memories_coordinator.connect("terminal_split_changed", self, "_on_terminal_split_changed")
    
    if terminal_split_controller:
        terminal_split_controller.connect("terminal_data_updated", self, "_on_terminal_data_updated")
        terminal_split_controller.connect("split_mode_changed", self, "_on_split_mode_changed")
    
    print("Animation System initialized")

# Process frame updates
func _process(delta):
    if not animation_enabled:
        return
    
    # Update active animations
    for anim_id in active_animations.keys():
        var animation = active_animations[anim_id]
        
        # Update animation progress
        animation.time += delta * animation_speed
        
        # Check if animation is complete
        if animation.time >= animation.duration:
            _complete_animation(anim_id)
            continue
        
        # Process specific animation types
        match animation.type:
            "color_shift":
                _process_color_shift_animation(animation, delta)
            
            "falling_text":
                _process_falling_text_animation(animation, delta)
            
            "shape_morph":
                _process_shape_morph_animation(animation, delta)
            
            "entrance_effect":
                _process_entrance_effect_animation(animation, delta)
            
            "akashic_flow":
                _process_akashic_flow_animation(animation, delta)
    
    # Process animation queue if we have space for more active animations
    if active_animations.size() < 10 and animation_queue.size() > 0:
        var next_animation = animation_queue.pop_front()
        _start_animation(next_animation)

# Create a falling text animation
func create_falling_text_animation(text: String, target_shape: String = "flat") -> String:
    var animation_id = "falling_text_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    var animation = {
        "id": animation_id,
        "type": "falling_text",
        "text": text,
        "target_shape": target_shape,
        "characters": [],
        "time": 0.0,
        "duration": 2.0,
        "color": color_scheme.primary
    }
    
    # Create character data
    for i in range(text.length()):
        var char_data = {
            "char": text[i],
            "position": Vector3(i * 0.5, 10.0, 0.0), # Start high
            "rotation": Vector3(randf() * 360, randf() * 360, randf() * 360),
            "scale": 1.0,
            "velocity": Vector3(randf() * 2.0 - 1.0, -5.0 - randf() * 3.0, randf() * 2.0 - 1.0)
        }
        animation.characters.append(char_data)
    
    # Add to queue
    animation_queue.append(animation)
    
    return animation_id

# Create a color shift animation
func create_color_shift_animation(from_color: Color, to_color: Color, duration: float = 1.0) -> String:
    var animation_id = "color_shift_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    var animation = {
        "id": animation_id,
        "type": "color_shift",
        "from_color": from_color,
        "to_color": to_color,
        "current_color": from_color,
        "time": 0.0,
        "duration": duration
    }
    
    # Add to queue
    animation_queue.append(animation)
    
    return animation_id

# Create a shape morph animation
func create_shape_morph_animation(from_shape: String, to_shape: String, duration: float = 1.5) -> String:
    var animation_id = "shape_morph_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    var animation = {
        "id": animation_id,
        "type": "shape_morph",
        "from_shape": from_shape,
        "to_shape": to_shape,
        "progress": 0.0,
        "time": 0.0,
        "duration": duration,
        "vertices": [],
        "target_vertices": []
    }
    
    # Get shape data
    animation.vertices = _get_shape_vertices(from_shape)
    animation.target_vertices = _get_shape_vertices(to_shape)
    
    # Add to queue
    animation_queue.append(animation)
    
    return animation_id

# Create an entrance effect animation
func create_entrance_effect(effect_type: String, target_node_path: NodePath) -> String:
    var animation_id = "entrance_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    var animation = {
        "id": animation_id,
        "type": "entrance_effect",
        "effect_type": effect_type,
        "target_node_path": target_node_path,
        "time": 0.0,
        "duration": 1.0,
        "effect_params": {}
    }
    
    # Configure effect parameters based on type
    match effect_type:
        "falling":
            animation.effect_params.start_y = -100
            animation.effect_params.end_y = 0
            animation.duration = 0.8
        
        "fade_in":
            animation.effect_params.start_alpha = 0.0
            animation.effect_params.end_alpha = 1.0
            animation.duration = 0.5
        
        "zoom_in":
            animation.effect_params.start_scale = 0.1
            animation.effect_params.end_scale = 1.0
            animation.duration = 0.7
        
        "spiral":
            animation.effect_params.start_angle = 0
            animation.effect_params.end_angle = 720
            animation.effect_params.start_scale = 0.1
            animation.effect_params.end_scale = 1.0
            animation.duration = 1.2
    
    # Update current entrance effect 
    current_entrance_effect = effect_type
    
    # Add to queue
    animation_queue.append(animation)
    
    return animation_id

# Create an akashic flow animation
func create_akashic_flow_animation(flow_speed: float = 1.0, flow_density: float = 0.5) -> String:
    var animation_id = "akashic_flow_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000)
    
    var animation = {
        "id": animation_id,
        "type": "akashic_flow",
        "flow_speed": flow_speed,
        "flow_density": flow_density,
        "flow_points": [],
        "flow_lines": [],
        "time": 0.0,
        "duration": 10.0, # Long-lasting animation
        "color_gradient": [
            color_scheme.primary,
            color_scheme.secondary,
            color_scheme.tertiary
        ]
    }
    
    # Create initial flow points
    var num_points = int(20 * flow_density)
    for i in range(num_points):
        var point = {
            "position": Vector2(randf() * 800, randf() * 600),
            "velocity": Vector2(randf() * 2 - 1, randf() * 2 - 1) * flow_speed,
            "size": randf() * 3 + 1,
            "color_index": randi() % 3
        }
        animation.flow_points.append(point)
    
    # Create flow lines
    var num_lines = int(15 * flow_density)
    for i in range(num_lines):
        var line = {
            "start_point": randi() % num_points,
            "end_point": randi() % num_points,
            "thickness": randf() * 2 + 0.5,
            "alpha": randf() * 0.5 + 0.3
        }
        animation.flow_lines.append(line)
    
    # Add to queue immediately
    _start_animation(animation)
    
    return animation_id

# Set color scheme
func set_color_scheme(scheme_name: String) -> bool:
    var old_scheme = color_scheme.duplicate()
    
    match scheme_name:
        "purple_blue_orange":
            color_scheme = {
                "primary": Color(0.5, 0.0, 1.0),    # Purple
                "secondary": Color(0.0, 0.5, 1.0),  # Blue
                "tertiary": Color(1.0, 0.5, 0.0),   # Orange
                "accent1": Color(1.0, 0.8, 0.0),    # Gold
                "accent2": Color(0.0, 0.8, 0.4),    # Teal
                "background": Color(0.1, 0.1, 0.15), # Dark blue-gray
                "text": Color(0.9, 0.9, 0.95)       # Light gray
            }
        
        "green_blue_pink":
            color_scheme = {
                "primary": Color(0.0, 0.8, 0.4),    # Green
                "secondary": Color(0.0, 0.5, 1.0),  # Blue
                "tertiary": Color(1.0, 0.5, 0.8),   # Pink
                "accent1": Color(0.8, 0.8, 0.0),    # Yellow
                "accent2": Color(0.8, 0.5, 0.0),    # Orange
                "background": Color(0.08, 0.08, 0.12), # Very dark blue
                "text": Color(0.95, 0.95, 1.0)      # White
            }
        
        "earth_tones":
            color_scheme = {
                "primary": Color(0.6, 0.4, 0.2),    # Brown
                "secondary": Color(0.4, 0.6, 0.2),  # Olive
                "tertiary": Color(0.8, 0.6, 0.4),   # Tan
                "accent1": Color(0.2, 0.4, 0.6),    # Steel Blue
                "accent2": Color(0.7, 0.3, 0.2),    # Rust
                "background": Color(0.15, 0.12, 0.08), # Dark brown
                "text": Color(0.9, 0.85, 0.8)       # Cream
            }
        
        "neon_cyberpunk":
            color_scheme = {
                "primary": Color(1.0, 0.0, 1.0),    # Magenta
                "secondary": Color(0.0, 1.0, 1.0),  # Cyan
                "tertiary": Color(1.0, 1.0, 0.0),   # Yellow
                "accent1": Color(0.0, 1.0, 0.5),    # Neon Green
                "accent2": Color(1.0, 0.5, 0.0),    # Neon Orange
                "background": Color(0.05, 0.05, 0.1), # Almost black
                "text": Color(0.9, 0.9, 1.0)        # White
            }
        
        _:
            return false
    
    # Emit signal
    emit_signal("color_scheme_changed", old_scheme, color_scheme)
    
    return true

# Set animation speed
func set_animation_speed(speed: float) -> void:
    animation_speed = clamp(speed, 0.1, 3.0)

# Enable/disable animations
func set_animation_enabled(enabled: bool) -> void:
    animation_enabled = enabled

# Set 3D effects
func set_3d_effects(enabled: bool) -> void:
    use_3d_effects = enabled

# Get current shape
func get_current_shape() -> String:
    return current_shape

# Set current shape
func set_current_shape(shape: String) -> bool:
    if shape in ["cube", "sphere", "pyramid", "cylinder", "torus", "flat"]:
        var old_shape = current_shape
        current_shape = shape
        emit_signal("shape_morphed", old_shape, current_shape)
        return true
    return false

# Apply color theme to terminals
func apply_color_theme_to_terminals() -> void:
    if terminal_split_controller:
        # Apply colors to each active terminal
        var terminals = terminal_split_controller.active_terminal_cores
        
        for i in range(terminals.size()):
            var core_id = terminals[i]
            var assignment = terminal_split_controller.core_assignments.get(core_id)
            
            # Choose color based on assignment
            var color_style = "default"
            match assignment:
                TerminalSplitController.CoreAssignment.WORD_MEMORY:
                    color_style = "blue"
                TerminalSplitController.CoreAssignment.WISH_KNOWLEDGE:
                    color_style = "green"  
                TerminalSplitController.CoreAssignment.DUAL_MEMORY:
                    color_style = "purple"
                _:
                    if i == 0:
                        color_style = "blue"
                    elif i == 1: 
                        color_style = "green"
                    elif i == 2:
                        color_style = "purple"
                    else:
                        color_style = "orange"
            
            # Apply style if dual core terminal available
            if terminal_split_controller.dual_core_terminal and \
               terminal_split_controller.dual_core_terminal.cores.has(core_id):
                terminal_split_controller.dual_core_terminal.cores[core_id].bracket_style = color_style

# Private methods

# Start an animation
func _start_animation(animation):
    active_animations[animation.id] = animation
    emit_signal("animation_started", animation.id, animation.type)

# Complete an animation
func _complete_animation(animation_id):
    var animation = active_animations[animation_id]
    
    # Final update for the animation
    match animation.type:
        "shape_morph":
            # Set current shape to target shape
            current_shape = animation.to_shape
    
    # Remove from active animations
    active_animations.erase(animation_id)
    
    # Emit signal
    emit_signal("animation_completed", animation_id)

# Process color shift animation
func _process_color_shift_animation(animation, delta):
    var t = animation.time / animation.duration
    animation.current_color = animation.from_color.linear_interpolate(animation.to_color, t)

# Process falling text animation
func _process_falling_text_animation(animation, delta):
    for char_data in animation.characters:
        # Update position
        char_data.position += char_data.velocity * delta
        
        # Update rotation
        char_data.rotation.x += delta * 30
        char_data.rotation.y += delta * 20
        char_data.rotation.z += delta * 10
        
        # Apply gravity
        char_data.velocity.y += 9.8 * delta
        
        # Check for target shape
        if animation.time > animation.duration * 0.6:
            # Start moving characters to their final positions
            var final_height = 0
            
            match animation.target_shape:
                "flat":
                    final_height = 0
                "cube":
                    # Arrange in cube shape
                    final_height = (char_data.position.x / 5.0) - 2
                "sphere":
                    # Arrange in rough sphere shape
                    var angle = char_data.position.x * 0.1
                    var radius = 3
                    char_data.position.z = sin(angle) * radius
                    final_height = cos(angle) * radius
                _:
                    final_height = 0
            
            # Move toward final height
            var target_y = final_height
            char_data.velocity.y = (target_y - char_data.position.y) * 2.0
            
            # Slow down x and z velocity
            char_data.velocity.x *= 0.9
            char_data.velocity.z *= 0.9

# Process shape morph animation
func _process_shape_morph_animation(animation, delta):
    var t = animation.time / animation.duration
    animation.progress = t
    
    # Interpolate between shapes
    for i in range(animation.vertices.size()):
        if i < animation.target_vertices.size():
            animation.vertices[i] = animation.vertices[i].linear_interpolate(
                animation.target_vertices[i], t)

# Process entrance effect animation
func _process_entrance_effect_animation(animation, delta):
    var t = animation.time / animation.duration
    var target_node = get_node_or_null(animation.target_node_path)
    
    if not target_node:
        return
    
    match animation.effect_type:
        "falling":
            var start_y = animation.effect_params.start_y
            var end_y = animation.effect_params.end_y
            var current_y = start_y + (end_y - start_y) * ease(t, -0.5)
            target_node.rect_position.y = current_y
        
        "fade_in":
            var start_alpha = animation.effect_params.start_alpha
            var end_alpha = animation.effect_params.end_alpha
            var current_alpha = start_alpha + (end_alpha - start_alpha) * t
            target_node.modulate.a = current_alpha
        
        "zoom_in":
            var start_scale = animation.effect_params.start_scale
            var end_scale = animation.effect_params.end_scale
            var current_scale = start_scale + (end_scale - start_scale) * ease(t, -1)
            target_node.rect_scale = Vector2(current_scale, current_scale)
            target_node.rect_pivot_offset = target_node.rect_size / 2
        
        "spiral":
            var start_angle = animation.effect_params.start_angle
            var end_angle = animation.effect_params.end_angle
            var current_angle = start_angle + (end_angle - start_angle) * t
            var start_scale = animation.effect_params.start_scale
            var end_scale = animation.effect_params.end_scale
            var current_scale = start_scale + (end_scale - start_scale) * t
            
            target_node.rect_rotation = current_angle
            target_node.rect_scale = Vector2(current_scale, current_scale)
            target_node.rect_pivot_offset = target_node.rect_size / 2

# Process akashic flow animation
func _process_akashic_flow_animation(animation, delta):
    # Update flow points
    for point in animation.flow_points:
        point.position += point.velocity * delta * animation.flow_speed
        
        # Bounce off edges
        if point.position.x < 0 or point.position.x > 800:
            point.velocity.x *= -1
        if point.position.y < 0 or point.position.y > 600:
            point.velocity.y *= -1
    
    # No need to update flow lines as they reference points by index

# Setup default animations
func _setup_default_animations():
    # Create basic shape data
    shape_morphing_data = {
        "cube": {
            "vertices": _create_cube_vertices()
        },
        "sphere": {
            "vertices": _create_sphere_vertices()
        },
        "pyramid": {
            "vertices": _create_pyramid_vertices()
        },
        "cylinder": {
            "vertices": _create_cylinder_vertices()
        },
        "torus": {
            "vertices": _create_torus_vertices()
        },
        "flat": {
            "vertices": _create_flat_vertices()
        }
    }

# Get shape vertices 
func _get_shape_vertices(shape: String) -> Array:
    if shape_morphing_data.has(shape):
        return shape_morphing_data[shape].vertices.duplicate()
    return []

# Create cube vertices
func _create_cube_vertices() -> Array:
    var vertices = []
    var size = 1.0
    
    # 8 corners of a cube
    vertices.append(Vector3(-size, -size, -size))
    vertices.append(Vector3(size, -size, -size))
    vertices.append(Vector3(size, size, -size))
    vertices.append(Vector3(-size, size, -size))
    vertices.append(Vector3(-size, -size, size))
    vertices.append(Vector3(size, -size, size))
    vertices.append(Vector3(size, size, size))
    vertices.append(Vector3(-size, size, size))
    
    return vertices

# Create sphere vertices 
func _create_sphere_vertices() -> Array:
    var vertices = []
    var radius = 1.0
    var segments = 8
    
    for i in range(segments):
        var lat = PI * (-0.5 + float(i) / segments)
        var z = sin(lat)
        var zr = cos(lat)
        
        for j in range(segments):
            var lng = 2 * PI * float(j) / segments
            var x = cos(lng) * zr
            var y = sin(lng) * zr
            
            vertices.append(Vector3(x, y, z) * radius)
    
    return vertices

# Create pyramid vertices
func _create_pyramid_vertices() -> Array:
    var vertices = []
    var size = 1.0
    
    # Base
    vertices.append(Vector3(-size, -size, -size))
    vertices.append(Vector3(size, -size, -size))
    vertices.append(Vector3(size, -size, size))
    vertices.append(Vector3(-size, -size, size))
    
    # Apex
    vertices.append(Vector3(0, size, 0))
    
    return vertices

# Create cylinder vertices
func _create_cylinder_vertices() -> Array:
    var vertices = []
    var radius = 1.0
    var height = 2.0
    var segments = 8
    
    # Top and bottom circles
    for i in range(segments):
        var angle = 2 * PI * float(i) / segments
        var x = cos(angle) * radius
        var z = sin(angle) * radius
        
        # Bottom circle
        vertices.append(Vector3(x, -height/2, z))
        
        # Top circle
        vertices.append(Vector3(x, height/2, z))
    
    return vertices

# Create torus vertices
func _create_torus_vertices() -> Array:
    var vertices = []
    var outer_radius = 1.0
    var inner_radius = 0.3
    var segments = 8
    var sides = 8
    
    for i in range(segments):
        var u = 2 * PI * float(i) / segments
        var center_x = cos(u) * outer_radius
        var center_z = sin(u) * outer_radius
        
        for j in range(sides):
            var v = 2 * PI * float(j) / sides
            var x = (outer_radius + inner_radius * cos(v)) * cos(u)
            var y = inner_radius * sin(v)
            var z = (outer_radius + inner_radius * cos(v)) * sin(u)
            
            vertices.append(Vector3(x, y, z))
    
    return vertices

# Create flat vertices
func _create_flat_vertices() -> Array:
    var vertices = []
    var size = 1.0
    
    # Just 4 corners of a square
    vertices.append(Vector3(-size, 0, -size))
    vertices.append(Vector3(size, 0, -size))
    vertices.append(Vector3(size, 0, size))
    vertices.append(Vector3(-size, 0, size))
    
    return vertices

# Signal handlers
func _on_meaning_transformed(original_text, transformed_text, source_system):
    # Create subtle animation when meaning transforms
    if animation_enabled:
        create_color_shift_animation(
            color_scheme.primary,
            color_scheme.secondary,
            0.8
        )

func _on_terminal_split_changed(old_config, new_config):
    # Create animation when terminal configuration changes
    if animation_enabled:
        # Animate all terminals with entrance effect
        if terminal_split_controller:
            for core_id in terminal_split_controller.active_terminal_cores:
                var node_path = terminal_split_controller.get_path_to(terminal_split_controller)
                create_entrance_effect(current_entrance_effect, node_path)

func _on_terminal_data_updated(core_id, content):
    # Create subtle animation when terminal data updates
    if animation_enabled and randf() < 0.3: # Only animate sometimes
        create_color_shift_animation(
            color_scheme.text,
            color_scheme.accent1,
            0.4
        )

func _on_split_mode_changed(old_mode, new_mode):
    # Create animation when split mode changes
    if animation_enabled:
        create_akashic_flow_animation(1.0, 0.7)