extends Node3D

class_name LightDataVisualizer

# Light Data Visualizer - Renders light transformations in 3D space
# Connects to the Light Data Transformer and Data Sea systems to visualize transformations

signal visualization_started(light_id)
signal visualization_updated(light_id, transform_percent)
signal visualization_completed(light_id)

# Visual constants
const LINE_SPACING = 0.5
const CHAR_SPACING = 0.1
const MAX_LINE_LENGTH = 50
const MAX_DISPLAY_LINES = 22
const ANIMATION_SPEED = 1.0

# Color constants
const COLOR_12_LINES = Color(0.3, 0.6, 1.0, 0.8)  # Blue for 12 lines
const COLOR_22_LINES = Color(1.0, 0.8, 0.2, 0.8)  # Gold for 22 lines
const COLOR_TRANSITION = Color(0.8, 0.5, 1.0, 0.8) # Purple for transition
const COLOR_LIGHT_BEAM = Color(0.9, 0.9, 1.0, 0.4) # White for light beams

# Visualization nodes
var beam_meshes = []
var text_nodes = []
var light_sources = []
var particles = []

# Current visualization state
var current_visualization = null
var animation_progress = 0.0
var is_animating = false

# References to other systems
var transformer
var data_sea
var animation_player

# Initialize the visualizer
func _ready():
    # Create container nodes
    var beam_container = Node3D.new()
    beam_container.name = "BeamContainer"
    add_child(beam_container)
    
    var text_container = Node3D.new()
    text_container.name = "TextContainer"
    add_child(text_container)
    
    var light_container = Node3D.new()
    light_container.name = "LightContainer"
    add_child(light_container)
    
    var particle_container = Node3D.new()
    particle_container.name = "ParticleContainer"
    add_child(particle_container)
    
    # Create animation player
    animation_player = AnimationPlayer.new()
    add_child(animation_player)
    
    # Connect to other systems
    transformer = get_node_or_null("/root/LightDataTransformer")
    data_sea = get_node_or_null("/root/DataSeaController")
    
    # Connect signals if available
    if transformer:
        transformer.connect("transformation_complete", Callable(self, "_on_transformation_complete"))
        transformer.connect("light_intensity_changed", Callable(self, "_on_light_intensity_changed"))
    
    print("Light Data Visualizer initialized")

# Update function for animations
func _process(delta):
    if is_animating and current_visualization:
        # Update animation progress
        animation_progress += delta * ANIMATION_SPEED
        
        # Calculate transformation progress (0 to 1)
        var progress = min(1.0, animation_progress / current_visualization.duration)
        
        # Update visualization based on progress
        _update_visualization(progress)
        
        # Emit update signal
        emit_signal("visualization_updated", current_visualization.id, progress)
        
        # Check if animation complete
        if progress >= 1.0:
            is_animating = false
            emit_signal("visualization_completed", current_visualization.id)

# Visualize a transformation from the transformer
func visualize_transformation(transformation_id):
    if not transformer:
        print("ERROR: Light Data Transformer not found")
        return false
    
    # Get transformation data
    var transformations = transformer.light_data_store.transformations
    if not transformations.has(transformation_id):
        print("ERROR: Transformation not found: " + transformation_id)
        return false
    
    var transformation = transformations[transformation_id]
    
    # Set up visualization
    _setup_visualization(transformation)
    
    # Start animation
    is_animating = true
    animation_progress = 0.0
    
    # Emit started signal
    emit_signal("visualization_started", transformation_id)
    
    return true

# Visualize an active light source
func visualize_light_source(light_id):
    if not transformer:
        print("ERROR: Light Data Transformer not found")
        return false
    
    # Get light source data
    var sources = transformer.light_data_store.light_sources
    if not sources.has(light_id):
        print("ERROR: Light source not found: " + light_id)
        return false
    
    var light_source = sources[light_id]
    
    # Find associated transformation
    var transformation = null
    var transformations = transformer.light_data_store.transformations
    for id in transformations:
        if transformations[id].id == light_source.origin:
            transformation = transformations[id]
            break
    
    if not transformation:
        print("ERROR: Associated transformation not found for light: " + light_id)
        return false
    
    # Set up visualization
    _setup_visualization(transformation, true)
    
    # For light sources, show completed state
    _update_visualization(1.0)
    
    # No animation for light sources, just show the result
    is_animating = false
    
    return true

# Create a new light visualization
func create_light_visualization(position, color, intensity):
    # Create light node
    var light = OmniLight3D.new()
    light.light_color = color
    light.light_energy = 1.0 + (intensity * 0.5)
    light.omni_range = 5.0 + (intensity * 2.0)
    light.shadow_enabled = true
    light.position = position
    
    # Add to container
    get_node("LightContainer").add_child(light)
    light_sources.append(light)
    
    # Add particle system for light rays
    _create_light_particle_system(position, color, intensity)
    
    return light

# Set up visualization for a transformation
func _setup_visualization(transformation, is_static=false):
    # Clear any existing visualization
    _clear_visualization()
    
    # Get original and transformed data
    var original_text = transformation.result.split("\n")
    var original_count = transformation.original_lines
    var target_count = transformation.result_lines
    
    # Create visualization info
    current_visualization = {
        "id": transformation.id,
        "original_lines": original_text.slice(0, original_count),
        "transformed_lines": original_text,
        "mode": transformation.mode,
        "light_patterns": transformation.light_patterns,
        "intensity": transformation.intensity,
        "position": Vector3(0, 0, 0),
        "duration": 2.0 + (original_count * 0.1),
        "static": is_static
    }
    
    # Create text nodes for lines
    for i in range(MAX_DISPLAY_LINES):
        var text_3d = Label3D.new()
        text_3d.text = ""
        text_3d.font_size = 24
        text_3d.pixel_size = 0.01
        text_3d.modulate = Color(1, 1, 1, 0)  # Start transparent
        text_3d.position = Vector3(0, -i * LINE_SPACING, 0)
        text_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        
        get_node("TextContainer").add_child(text_3d)
        text_nodes.append(text_3d)
    
    # Create light beam meshes
    for i in range(3):  # Create 3 beams
        var beam = _create_light_beam()
        beam.visible = false
        get_node("BeamContainer").add_child(beam)
        beam_meshes.append(beam)
    
    # Create central light source
    var light_color = _get_color_for_mode(transformation.mode)
    var light_intensity = transformation.intensity
    var central_light = create_light_visualization(Vector3(0, 0, -2), light_color, light_intensity)
    
    # Set up beam positions
    _position_light_beams()

# Update the visualization based on animation progress
func _update_visualization(progress):
    if not current_visualization:
        return
    
    # Linear interpolation between 12 and 22 lines
    var orig_lines = current_visualization.original_lines
    var transformed_lines = current_visualization.transformed_lines
    
    # Calculate how many lines to show
    var start_count = orig_lines.size()
    var end_count = transformed_lines.size()
    var line_count = int(lerp(start_count, end_count, progress))
    
    # Update text nodes
    for i in range(MAX_DISPLAY_LINES):
        var text_node = text_nodes[i]
        
        if i < line_count:
            # Show line with fade-in effect
            var line_progress = clamp((progress * transformed_lines.size() - i) * 2, 0, 1)
            
            # Get appropriate text
            var line_text = ""
            if i < transformed_lines.size():
                line_text = transformed_lines[i]
                
                # Truncate if too long
                if line_text.length() > MAX_LINE_LENGTH:
                    line_text = line_text.substr(0, MAX_LINE_LENGTH) + "..."
            
            text_node.text = line_text
            text_node.modulate = Color(1, 1, 1, line_progress)
            
            # Highlight lines with light patterns
            if current_visualization.has("light_patterns") and _line_has_light_pattern(i):
                text_node.modulate = _get_highlight_color(i, line_progress)
        else:
            # Hide line
            text_node.modulate = Color(1, 1, 1, 0)
    
    # Update light beams
    for i in range(beam_meshes.size()):
        var beam = beam_meshes[i]
        beam.visible = progress > 0.2
        
        # Pulse the beams
        var alpha = 0.3 + (0.7 * (sin(progress * 10 + i) * 0.5 + 0.5))
        var beam_material = beam.get_active_material(0)
        beam_material.albedo_color.a = alpha
    
    # Update light sources
    for light in light_sources:
        # Pulse light intensity
        light.light_energy = 1.0 + (current_visualization.intensity * 0.5) + (sin(progress * 5) * 0.3)
    
    # Update particles
    for particle in particles:
        # Adjust emission based on progress
        particle.emitting = progress > 0.3
        if particle.emitting:
            particle.amount = int(30 * progress)

# Clear current visualization
func _clear_visualization():
    # Clear text nodes
    for text_node in text_nodes:
        text_node.queue_free()
    text_nodes.clear()
    
    # Clear beam meshes
    for beam in beam_meshes:
        beam.queue_free()
    beam_meshes.clear()
    
    # Clear light sources
    for light in light_sources:
        light.queue_free()
    light_sources.clear()
    
    # Clear particles
    for particle in particles:
        particle.queue_free()
    particles.clear()
    
    # Reset current visualization
    current_visualization = null
    is_animating = false
    animation_progress = 0.0

# Create a light beam mesh
func _create_light_beam():
    # Create mesh instance
    var mesh_instance = MeshInstance3D.new()
    
    # Create beam mesh (simple cylinder)
    var cylinder = CylinderMesh.new()
    cylinder.top_radius = 0.1
    cylinder.bottom_radius = 0.5
    cylinder.height = 10.0
    mesh_instance.mesh = cylinder
    
    # Create material
    var material = StandardMaterial3D.new()
    material.albedo_color = COLOR_LIGHT_BEAM
    material.emission_enabled = true
    material.emission = COLOR_LIGHT_BEAM
    material.emission_energy_multiplier = 2.0
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    
    # Apply material
    mesh_instance.set_surface_override_material(0, material)
    
    return mesh_instance

# Create particle system for light
func _create_light_particle_system(position, color, intensity):
    # Create particles
    var particles_instance = CPUParticles3D.new()
    particles_instance.position = position
    particles_instance.amount = 30 * (intensity + 1)
    particles_instance.lifetime = 2.0
    particles_instance.mesh = SphereMesh.new()
    particles_instance.mesh.radius = 0.05
    particles_instance.mesh.height = 0.1
    
    # Set up emission
    particles_instance.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
    particles_instance.emission_sphere_radius = 0.2
    
    # Set up motion
    particles_instance.gravity = Vector3(0, 0, 0)
    particles_instance.initial_velocity_min = 0.5
    particles_instance.initial_velocity_max = 1.5
    particles_instance.scale_amount_min = 0.05
    particles_instance.scale_amount_max = 0.2
    
    # Set up color
    particles_instance.color = color
    particles_instance.color_ramp = Gradient.new()
    
    # Get container and add
    get_node("ParticleContainer").add_child(particles_instance)
    particles.append(particles_instance)
    
    return particles_instance

# Position light beams for visualization
func _position_light_beams():
    if beam_meshes.size() < 3:
        return
    
    # Top beam - pointing down
    beam_meshes[0].position = Vector3(0, 5, -3)
    beam_meshes[0].rotation_degrees = Vector3(180, 0, 0)
    
    # Left beam - pointing right and down
    beam_meshes[1].position = Vector3(-5, 3, -3)
    beam_meshes[1].rotation_degrees = Vector3(160, 70, 0)
    
    # Right beam - pointing left and down
    beam_meshes[2].position = Vector3(5, 3, -3)
    beam_meshes[2].rotation_degrees = Vector3(160, -70, 0)

# Check if a line has a light pattern in it
func _line_has_light_pattern(line_index):
    if not current_visualization or not current_visualization.has("light_patterns"):
        return false
    
    for pattern in current_visualization.light_patterns:
        # Check light clusters
        if pattern.type == "light_cluster":
            if line_index >= pattern.start_line and line_index <= pattern.end_line:
                return true
        
        # Check symmetry points
        elif pattern.type == "symmetry":
            var center = pattern.center_line
            var size = pattern.size
            
            if line_index >= center - size and line_index <= center + size:
                return true
    
    return false

# Get highlight color for lines with light patterns
func _get_highlight_color(line_index, alpha):
    var base_color = Color(1.0, 0.9, 0.6, alpha)  # Light yellow base
    
    if not current_visualization or not current_visualization.has("light_patterns"):
        return base_color
    
    for pattern in current_visualization.light_patterns:
        if pattern.type == "light_cluster":
            if line_index >= pattern.start_line and line_index <= pattern.end_line:
                # Intensity-based coloring
                var intensity = pattern.intensity / 10.0  # Normalize to 0-1 range
                return Color(1.0, 0.7 + (0.3 * intensity), 0.4 + (0.6 * intensity), alpha)
        
        elif pattern.type == "symmetry":
            var center = pattern.center_line
            var size = pattern.size
            
            if line_index >= center - size and line_index <= center + size:
                # Distance from center determines color
                var distance = abs(line_index - center)
                var normalized_distance = float(distance) / max(1, size)
                
                # Center is more gold, edges more blue
                var r = lerp(1.0, 0.3, normalized_distance)
                var g = lerp(0.9, 0.6, normalized_distance)
                var b = lerp(0.3, 1.0, normalized_distance)
                
                return Color(r, g, b, alpha)
    
    return base_color

# Get color based on transformation mode
func _get_color_for_mode(mode):
    match mode:
        "expand":
            return Color(0.2, 0.6, 1.0)  # Blue
        "condense":
            return Color(1.0, 0.8, 0.2)  # Gold
        "illuminate":
            return Color(1.0, 1.0, 0.8)  # Soft white
        "refract":
            return Color(0.8, 0.2, 1.0)  # Purple
        "reflect":
            return Color(0.2, 1.0, 0.8)  # Teal
        _:
            return Color(0.9, 0.9, 0.9)  # Default light gray

# SIGNAL HANDLERS
# --------------

# Handle transformation completion
func _on_transformation_complete(data_id, original_lines, transformed_lines):
    # Automatically visualize if not currently visualizing
    if not is_animating and not current_visualization:
        visualize_transformation(data_id)

# Handle light intensity changes
func _on_light_intensity_changed(intensity_level, source_file):
    # Update light intensity for active visualizations
    if current_visualization:
        current_visualization.intensity = intensity_level
        
        # Update light sources
        for light in light_sources:
            light.light_energy = 1.0 + (intensity_level * 0.5)
            light.omni_range = 5.0 + (intensity_level * 2.0)

# PUBLIC API METHODS
# -----------------

# Get current visualization status
func get_visualization_status():
    if not current_visualization:
        return "No active visualization"
    
    var status = "Visualizing: " + current_visualization.id + "\n"
    status += "Mode: " + current_visualization.mode + "\n"
    status += "Progress: " + str(int(animation_progress / current_visualization.duration * 100)) + "%\n"
    status += "Lines: " + str(current_visualization.original_lines.size()) + " → " + str(current_visualization.transformed_lines.size())
    
    return status

# Stop current visualization
func stop_visualization():
    if is_animating:
        is_animating = false
        return "Visualization stopped"
    else:
        return "No animation in progress"

# Create a floating text visualization
func create_floating_text(text, position, color=Color(1,1,1), size=24, duration=3.0):
    var text_node = Label3D.new()
    text_node.text = text
    text_node.font_size = size
    text_node.pixel_size = 0.01
    text_node.modulate = color
    text_node.position = position
    text_node.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    
    get_node("TextContainer").add_child(text_node)
    
    # Create animation to fade out
    var tween = create_tween()
    tween.tween_property(text_node, "modulate:a", 0.0, duration)
    tween.tween_callback(Callable(text_node, "queue_free"))
    
    return text_node

# Process a command for visualization
func process_command(command):
    var parts = command.split(" ")
    
    if parts.size() < 1:
        return "Available commands: visualize, status, stop, floating"
    
    match parts[0]:
        "visualize":
            if parts.size() < 2:
                return "Usage: visualize <transformation_id>"
            
            var success = visualize_transformation(parts[1])
            if success:
                return "Visualization started for: " + parts[1]
            else:
                return "Failed to visualize: " + parts[1]
            
        "status":
            return get_visualization_status()
            
        "stop":
            return stop_visualization()
            
        "floating":
            if parts.size() < 3:
                return "Usage: floating <text> <duration>"
            
            var text = parts[1]
            var duration = 3.0
            if parts.size() >= 3:
                duration = float(parts[2])
            
            create_floating_text(text, Vector3(0, 0, -3), Color(1,1,1), 24, duration)
            return "Created floating text: " + text
            
        _:
            return "Unknown command: " + parts[0]