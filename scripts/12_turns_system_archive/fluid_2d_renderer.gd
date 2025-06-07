extends Node2D

class_name Fluid2DRenderer

# Reference to fluid simulation
var simulation: FluidSimulationCore = null

# Rendering properties
@export_category("Rendering Properties")
@export var particle_size: float = 20.0
@export var smoothing: bool = true
@export var use_metaballs: bool = true
@export var metaball_threshold: float = 0.5
@export var metaball_falloff: float = 0.8
@export var use_shader: bool = true
@export_color var gradient_top_color: Color = Color(0.0, 0.6, 1.0, 0.8)
@export_color var gradient_bottom_color: Color = Color(0.0, 0.4, 0.8, 0.9)

# Custom rendering options
@export_category("Visual Effects")
@export var add_ripples: bool = true
@export var ripple_frequency: float = 3.0
@export var ripple_amplitude: float = 0.2
@export var add_caustics: bool = true
@export var add_foam: bool = true
@export var foam_threshold: float = 0.7
@export_color var foam_color: Color = Color(1.0, 1.0, 1.0, 0.7)
@export_color var outline_color: Color = Color(0.0, 0.3, 0.6, 0.4)
@export var outline_width: float = 2.0

# Optimization
@export_category("Optimization")
@export var render_quality: float = 1.0 # 0.0-1.0 multiplier
@export var max_particles_to_render: int = 2000
@export var cull_offscreen_particles: bool = true
@export var use_instancing: bool = true

# Internal variables
var particle_shader: Shader = null
var metaball_shader: Shader = null
var render_texture: RenderTexture2D = null
var _time: float = 0.0
var _fluid_surface_mesh: Array = [] # Vertices for fluid surface
var _particle_draw_list: Array = [] # Optimized list for drawing
var _metaball_resolution: Vector2 = Vector2(512, 512)

# Caching
var _cached_viewport_size: Vector2 = Vector2.ZERO
var _cached_particles: Array = []
var _needs_surface_rebuild: bool = true

func _ready():
    # Initialize shaders
    if use_shader:
        _init_shaders()
    
    # Initialize render texture
    if use_metaballs:
        _init_render_texture()
    
    # Set initial viewport size cache
    _cached_viewport_size = get_viewport_rect().size

func _init_shaders():
    # Load fluid particle shader
    particle_shader = load("res://shaders/fluid_particle.gdshader")
    if particle_shader == null:
        # Create default shader if not found
        particle_shader = Shader.new()
        particle_shader.code = _get_default_particle_shader_code()
    
    # Load metaball shader
    metaball_shader = load("res://shaders/fluid_metaball.gdshader")
    if metaball_shader == null:
        # Create default shader if not found
        metaball_shader = Shader.new()
        metaball_shader.code = _get_default_metaball_shader_code()

func _init_render_texture():
    # Create render texture for metaballs
    var size_x = int(get_viewport_rect().size.x * render_quality)
    var size_y = int(get_viewport_rect().size.y * render_quality)
    _metaball_resolution = Vector2(size_x, size_y)
    
    render_texture = RenderTexture2D.new()
    render_texture.size = _metaball_resolution
    render_texture.format = RenderTextureFormat.RGBA8

func _process(delta):
    _time += delta
    
    # Check if viewport size changed
    var new_viewport_size = get_viewport_rect().size
    if new_viewport_size != _cached_viewport_size:
        _cached_viewport_size = new_viewport_size
        
        # Resize render texture if needed
        if use_metaballs and render_texture:
            var size_x = int(new_viewport_size.x * render_quality)
            var size_y = int(new_viewport_size.y * render_quality)
            _metaball_resolution = Vector2(size_x, size_y)
            render_texture.size = _metaball_resolution
    
    # Mark for surface rebuild every frame
    _needs_surface_rebuild = true
    
    # Update cached particles from simulation
    if simulation != null:
        _cached_particles = simulation.get_particles_for_rendering()
        
        # Sort particles by depth (for correct alpha blending)
        if smoothing:
            _cached_particles.sort_custom(_sort_particles_by_depth)
        
        # Prepare optimized draw list if using instances
        if use_instancing:
            _prepare_particle_draw_list()
    
    # Request redraw
    queue_redraw()

func _draw():
    if simulation == null or _cached_particles.size() == 0:
        return
    
    # Determine rendering method
    if use_metaballs:
        _draw_fluid_metaballs()
    elif smoothing:
        _draw_smooth_particles()
    else:
        _draw_simple_particles()

func _draw_simple_particles():
    # Draw simple circles for each particle
    var particles_to_render = _get_renderable_particles()
    
    for p in particles_to_render:
        var pos = Vector2(p.position.x, p.position.y)
        
        if cull_offscreen_particles and not _is_on_screen(pos, particle_size):
            continue
        
        var color = _get_particle_color(p)
        
        # Draw circle
        draw_circle(pos, particle_size * 0.5, color)
        
        # Draw outline if needed
        if outline_width > 0:
            draw_arc(pos, particle_size * 0.5, 0, TAU, 32, outline_color, outline_width)

func _draw_smooth_particles():
    # Draw particles with antialiasing and smooth gradients
    var particles_to_render = _get_renderable_particles()
    
    for p in particles_to_render:
        var pos = Vector2(p.position.x, p.position.y)
        
        if cull_offscreen_particles and not _is_on_screen(pos, particle_size):
            continue
        
        var color = _get_particle_color(p)
        
        # Draw circle with gradient
        var rect = Rect2(pos - Vector2(particle_size, particle_size) * 0.5, 
                        Vector2(particle_size, particle_size))
        
        # Draw main colored circle with gradient
        var center_color = color
        var edge_color = Color(color.r, color.g, color.b, 0.0)
        
        _draw_radial_gradient_circle(pos, particle_size * 0.5, center_color, edge_color)
        
        # Add foam on surface particles if enabled
        if add_foam and p.is_surface and randf() < foam_threshold:
            var foam_size = particle_size * 0.3
            var foam_offset = Vector2(randf_range(-0.2, 0.2), randf_range(-0.2, 0.0)) * particle_size
            _draw_radial_gradient_circle(pos + foam_offset, foam_size, foam_color, 
                                        Color(foam_color.r, foam_color.g, foam_color.b, 0.0))

func _draw_fluid_metaballs():
    # Regenerate surface mesh if needed
    if _needs_surface_rebuild:
        _rebuild_fluid_surface()
        _needs_surface_rebuild = false
    
    # Draw the metaball surface
    if _fluid_surface_mesh.size() >= 3:  # At least one triangle
        var colors = _get_metaball_colors()
        draw_polygon(_fluid_surface_mesh, colors)
        
        # Draw outline if needed
        if outline_width > 0:
            var outline_points = _get_surface_outline(_fluid_surface_mesh)
            for i in range(outline_points.size() - 1):
                draw_line(outline_points[i], outline_points[i+1], outline_color, outline_width)
            # Connect last to first
            if outline_points.size() > 2:
                draw_line(outline_points[-1], outline_points[0], outline_color, outline_width)
    
    # Debug: draw particles as small circles if needed
    if false:  # Change to true for debugging
        var particles_to_render = _get_renderable_particles()
        for p in particles_to_render:
            var pos = Vector2(p.position.x, p.position.y)
            if cull_offscreen_particles and not _is_on_screen(pos, 4):
                continue
            var debug_color = Color(1, 1, 1, 0.3)
            draw_circle(pos, 2, debug_color)

func _rebuild_fluid_surface():
    """Generate a mesh surface for the fluid using metaballs technique"""
    _fluid_surface_mesh.clear()
    
    if _cached_particles.size() == 0:
        return
    
    # Use marching squares algorithm (2D equivalent of marching cubes)
    var grid_resolution = 40  # Adjust for quality vs performance
    var bounds = _get_particles_bounds()
    
    # Add padding to bounds
    bounds.position -= Vector2(particle_size, particle_size)
    bounds.size += Vector2(particle_size, particle_size) * 2
    
    var cell_size = Vector2(bounds.size.x / grid_resolution, 
                           bounds.size.y / grid_resolution)
    
    # Generate implicit field values (metaball field)
    var field = {}
    for x in range(grid_resolution + 1):
        for y in range(grid_resolution + 1):
            var pos = bounds.position + Vector2(x * cell_size.x, y * cell_size.y)
            var value = 0.0
            
            # Sum contribution from each particle
            for p in _cached_particles:
                var particle_pos = Vector2(p.position.x, p.position.y)
                var dist = pos.distance_to(particle_pos)
                if dist < particle_size * 2:
                    value += pow(1.0 - dist / (particle_size * 2), metaball_falloff)
            
            # Store grid value
            field[Vector2i(x, y)] = value
    
    # Generate polygons using marching squares
    _fluid_surface_mesh = _marching_squares(field, grid_resolution, 
                                         bounds, metaball_threshold)

func _marching_squares(field, resolution, bounds, threshold):
    """Implement marching squares algorithm for metaball rendering"""
    var vertices = []
    var visited_edges = {}
    
    # Process each cell in the grid
    for x in range(resolution):
        for y in range(resolution):
            # Get the values at the 4 corners of this cell
            var cell_type = 0
            var corners = [
                Vector2i(x, y),
                Vector2i(x + 1, y),
                Vector2i(x + 1, y + 1),
                Vector2i(x, y + 1)
            ]
            
            var corner_values = []
            for i in range(4):
                var value = field[corners[i]]
                corner_values.append(value)
                if value >= threshold:
                    cell_type |= (1 << i)
            
            # Skip empty or full cells
            if cell_type == 0 or cell_type == 15:
                continue
            
            # Calculate the positions where the metaball surface intersects the cell edges
            var positions = []
            
            # Look up interpolation positions for this cell type
            match cell_type:
                1: # 0001 - Bottom-left corner
                    positions.append(_interpolate_position(corners[0], corners[3], corner_values[0], corner_values[3], threshold, bounds))
                    positions.append(_interpolate_position(corners[0], corners[1], corner_values[0], corner_values[1], threshold, bounds))
                2: # 0010 - Bottom-right corner
                    positions.append(_interpolate_position(corners[1], corners[0], corner_values[1], corner_values[0], threshold, bounds))
                    positions.append(_interpolate_position(corners[1], corners[2], corner_values[1], corner_values[2], threshold, bounds))
                3: # 0011 - Bottom edge
                    positions.append(_interpolate_position(corners[1], corners[2], corner_values[1], corner_values[2], threshold, bounds))
                    positions.append(_interpolate_position(corners[0], corners[3], corner_values[0], corner_values[3], threshold, bounds))
                4: # 0100 - Top-right corner
                    positions.append(_interpolate_position(corners[2], corners[1], corner_values[2], corner_values[1], threshold, bounds))
                    positions.append(_interpolate_position(corners[2], corners[3], corner_values[2], corner_values[3], threshold, bounds))
                5: # 0101 - Diagonal case 1
                    positions.append(_interpolate_position(corners[0], corners[1], corner_values[0], corner_values[1], threshold, bounds))
                    positions.append(_interpolate_position(corners[0], corners[3], corner_values[0], corner_values[3], threshold, bounds))
                    positions.append(_interpolate_position(corners[2], corners[1], corner_values[2], corner_values[1], threshold, bounds))
                    positions.append(_interpolate_position(corners[2], corners[3], corner_values[2], corner_values[3], threshold, bounds))
                6: # 0110 - Right edge
                    positions.append(_interpolate_position(corners[1], corners[0], corner_values[1], corner_values[0], threshold, bounds))
                    positions.append(_interpolate_position(corners[2], corners[3], corner_values[2], corner_values[3], threshold, bounds))
                7: # 0111 - All except top-left
                    positions.append(_interpolate_position(corners[0], corners[3], corner_values[0], corner_values[3], threshold, bounds))
                    positions.append(_interpolate_position(corners[0], corners[1], corner_values[0], corner_values[1], threshold, bounds))
                8: # 1000 - Top-left corner
                    positions.append(_interpolate_position(corners[3], corners[0], corner_values[3], corner_values[0], threshold, bounds))
                    positions.append(_interpolate_position(corners[3], corners[2], corner_values[3], corner_values[2], threshold, bounds))
                9: # 1001 - Left edge
                    positions.append(_interpolate_position(corners[0], corners[1], corner_values[0], corner_values[1], threshold, bounds))
                    positions.append(_interpolate_position(corners[3], corners[2], corner_values[3], corner_values[2], threshold, bounds))
                10: # 1010 - Diagonal case 2
                    positions.append(_interpolate_position(corners[1], corners[0], corner_values[1], corner_values[0], threshold, bounds))
                    positions.append(_interpolate_position(corners[1], corners[2], corner_values[1], corner_values[2], threshold, bounds))
                    positions.append(_interpolate_position(corners[3], corners[0], corner_values[3], corner_values[0], threshold, bounds))
                    positions.append(_interpolate_position(corners[3], corners[2], corner_values[3], corner_values[2], threshold, bounds))
                11: # 1011 - All except top-right
                    positions.append(_interpolate_position(corners[1], corners[2], corner_values[1], corner_values[2], threshold, bounds))
                    positions.append(_interpolate_position(corners[3], corners[2], corner_values[3], corner_values[2], threshold, bounds))
                12: # 1100 - Top edge
                    positions.append(_interpolate_position(corners[3], corners[0], corner_values[3], corner_values[0], threshold, bounds))
                    positions.append(_interpolate_position(corners[2], corners[1], corner_values[2], corner_values[1], threshold, bounds))
                13: # 1101 - All except bottom-right
                    positions.append(_interpolate_position(corners[0], corners[1], corner_values[0], corner_values[1], threshold, bounds))
                    positions.append(_interpolate_position(corners[2], corners[1], corner_values[2], corner_values[1], threshold, bounds))
                14: # 1110 - All except bottom-left
                    positions.append(_interpolate_position(corners[1], corners[0], corner_values[1], corner_values[0], threshold, bounds))
                    positions.append(_interpolate_position(corners[3], corners[0], corner_values[3], corner_values[0], threshold, bounds))
                _: # Other cases (shouldn't happen)
                    pass
            
            # Add calculated vertices to the mesh
            for i in range(0, positions.size(), 2):
                if i+1 < positions.size():  # Ensure we have a pair
                    var pos1 = positions[i]
                    var pos2 = positions[i+1]
                    
                    # Create an edge key to track unique edges
                    var edge_key = str(pos1) + str(pos2)
                    if not visited_edges.has(edge_key):
                        visited_edges[edge_key] = true
                        
                        # Add vertices in correct winding order for proper polygon rendering
                        vertices.append(pos1)
                        vertices.append(pos2)
    
    # Convert to proper polygon by forming a convex hull or organizing vertices
    return _organize_polygon_vertices(vertices)

func _interpolate_position(p1, p2, val1, val2, threshold, bounds):
    """Linearly interpolate between grid points to find exact threshold position"""
    # Avoid division by zero
    if abs(val2 - val1) < 0.0001:
        return Vector2.ZERO
    
    # Calculate interpolation factor
    var t = (threshold - val1) / (val2 - val1)
    
    # Clamp interpolation to 0-1 range
    t = clamp(t, 0.0, 1.0)
    
    # Calculate cell size
    var cell_size = Vector2(bounds.size.x / 40.0, bounds.size.y / 40.0)
    
    # Calculate interpolated position
    var pos = Vector2(
        bounds.position.x + (p1.x * (1.0 - t) + p2.x * t) * cell_size.x,
        bounds.position.y + (p1.y * (1.0 - t) + p2.y * t) * cell_size.y
    )
    
    return pos

func _organize_polygon_vertices(vertices):
    """Organize vertices into a proper polygon"""
    if vertices.size() <= 2:
        return []
    
    # Find center point of all vertices
    var center = Vector2.ZERO
    for v in vertices:
        center += v
    center /= vertices.size()
    
    # Sort vertices by angle around center point
    var sorted_vertices = vertices.duplicate()
    sorted_vertices.sort_custom(func(a, b): 
        return atan2(a.y - center.y, a.x - center.x) < atan2(b.y - center.y, b.x - center.x)
    )
    
    return sorted_vertices

func _get_surface_outline(polygon):
    """Extract the outline edges from the polygon"""
    var edges = {}
    var outline = []
    
    # Track edge frequencies
    for i in range(polygon.size()):
        var p1 = polygon[i]
        var p2 = polygon[(i + 1) % polygon.size()]
        
        var edge_key = str(p1) + "__" + str(p2)
        var rev_edge_key = str(p2) + "__" + str(p1)
        
        if edges.has(edge_key):
            edges[edge_key] += 1
        else:
            edges[edge_key] = 1
        
        if edges.has(rev_edge_key):
            edges[rev_edge_key] += 1
        else:
            edges[rev_edge_key] = 1
    
    # Find edges that appear only once (outline edges)
    for i in range(polygon.size()):
        var p1 = polygon[i]
        var p2 = polygon[(i + 1) % polygon.size()]
        
        var edge_key = str(p1) + "__" + str(p2)
        
        if edges[edge_key] == 1:
            outline.append(p1)
    
    return outline

func _draw_radial_gradient_circle(center, radius, inner_color, outer_color):
    """Draw a circle with a radial gradient from center to edge"""
    # Create a gradient texture
    var gradient = Gradient.new()
    gradient.add_point(0.0, inner_color)
    gradient.add_point(1.0, outer_color)
    
    var gradient_texture = GradientTexture2D.new()
    gradient_texture.gradient = gradient
    gradient_texture.fill = GradientTexture2D.FILL_RADIAL
    gradient_texture.width = int(radius * 2)
    gradient_texture.height = int(radius * 2)
    
    # Draw textured circle
    var rect = Rect2(center - Vector2(radius, radius), Vector2(radius * 2, radius * 2))
    draw_texture_rect(gradient_texture, rect, false)

func _get_particle_color(particle):
    """Get color for a particle, with vertical gradient"""
    if particle.has("color"):
        return particle.color
    
    # Calculate vertical position for gradient
    var t = (particle.position.y - min_bounds().y) / (max_bounds().y - min_bounds().y)
    t = clamp(t, 0.0, 1.0)
    
    # Lerp between top and bottom colors
    var color = gradient_top_color.lerp(gradient_bottom_color, t)
    
    # Modify alpha for surface particles
    if particle.has("is_surface") and particle.is_surface:
        color.a *= 1.2  # Make surface particles slightly more opaque
    
    return color

func _get_metaball_colors():
    """Get colors for the metaball polygon"""
    var colors = []
    
    # Create a gradient from top to bottom of the fluid surface
    for vertex in _fluid_surface_mesh:
        var t = (vertex.y - min_bounds().y) / (max_bounds().y - min_bounds().y)
        t = clamp(t, 0.0, 1.0)
        
        var color = gradient_top_color.lerp(gradient_bottom_color, t)
        
        # Add some ripple effects based on time and position
        if add_ripples:
            var ripple = sin((vertex.x * 0.1 + _time * 2.0) * ripple_frequency) * 
                        sin((vertex.y * 0.1 + _time) * ripple_frequency) * 
                        ripple_amplitude
            
            # Adjust color brightness based on ripple
            color = color.lightened(ripple * 0.2)
        
        # Add to colors array
        colors.append(color)
    
    return colors

func _get_default_particle_shader_code():
    """Return default particle shader code if no shader is available"""
    return """
    shader_type canvas_item;
    
    uniform vec4 inner_color : source_color = vec4(0.0, 0.6, 1.0, 0.7);
    uniform vec4 outer_color : source_color = vec4(0.0, 0.4, 0.8, 0.0);
    uniform float inner_radius = 0.4;
    
    void fragment() {
        float dist = distance(UV, vec2(0.5));
        
        // Circular shape with soft edges
        float alpha = smoothstep(0.5, inner_radius, dist);
        
        // Interpolate between inner and outer color
        vec4 color = mix(outer_color, inner_color, alpha);
        
        COLOR = color;
    }
    """

func _get_default_metaball_shader_code():
    """Return default metaball shader code if no shader is available"""
    return """
    shader_type canvas_item;
    
    uniform vec4 top_color : source_color = vec4(0.0, 0.6, 1.0, 0.8);
    uniform vec4 bottom_color : source_color = vec4(0.0, 0.4, 0.8, 0.9);
    uniform float wave_speed = 2.0;
    uniform float wave_frequency = 20.0;
    uniform float wave_amplitude = 0.05;
    uniform float time_offset = 0.0;
    
    void fragment() {
        // Vertical gradient
        float t = UV.y;
        vec4 base_color = mix(top_color, bottom_color, t);
        
        // Add wave effect
        float wave = sin((UV.x * wave_frequency) + time_offset * wave_speed) * 
                    sin((UV.y * wave_frequency * 0.5) + time_offset * wave_speed * 0.7) * 
                    wave_amplitude;
        
        // Apply wave effect
        base_color = base_color * (1.0 + wave);
        
        // Add highlights at top
        if (UV.y < 0.15) {
            base_color = base_color * (1.0 + (0.15 - UV.y) * 2.0);
        }
        
        COLOR = base_color;
    }
    """

func _get_renderable_particles():
    """Get particles that should be rendered, respecting max count"""
    var render_count = min(_cached_particles.size(), max_particles_to_render)
    return _cached_particles.slice(0, render_count - 1)

func _prepare_particle_draw_list():
    """Prepare an optimized list for particle drawing using instancing"""
    _particle_draw_list.clear()
    
    var particles_to_render = _get_renderable_particles()
    for p in particles_to_render:
        var pos = Vector2(p.position.x, p.position.y)
        
        if cull_offscreen_particles and not _is_on_screen(pos, particle_size):
            continue
        
        _particle_draw_list.append({
            "position": pos,
            "color": _get_particle_color(p),
            "size": particle_size,
            "is_surface": p.get("is_surface", false)
        })

func _get_particles_bounds():
    """Get bounds rectangle containing all particles"""
    if _cached_particles.size() == 0:
        return Rect2(0, 0, 1, 1)
    
    var min_p = Vector2(INF, INF)
    var max_p = Vector2(-INF, -INF)
    
    for p in _cached_particles:
        var pos = Vector2(p.position.x, p.position.y)
        min_p.x = min(min_p.x, pos.x)
        min_p.y = min(min_p.y, pos.y)
        max_p.x = max(max_p.x, pos.x)
        max_p.y = max(max_p.y, pos.y)
    
    return Rect2(min_p, max_p - min_p)

func _is_on_screen(position, size):
    """Check if a particle is visible on screen"""
    var screen_rect = get_viewport_rect()
    var extended_rect = screen_rect.grow(size)
    return extended_rect.has_point(position)

func _sort_particles_by_depth(a, b):
    """Sort particles by depth (y position) for correct drawing order"""
    return a.position.y > b.position.y

func min_bounds():
    """Get minimum bounds from simulation if available"""
    if simulation != null:
        return Vector2(simulation.min_bounds.x, simulation.min_bounds.y)
    return Vector2(-10, -10)

func max_bounds():
    """Get maximum bounds from simulation if available"""
    if simulation != null:
        return Vector2(simulation.max_bounds.x, simulation.max_bounds.y)
    return Vector2(10, 10)

func set_simulation(sim):
    """Set the fluid simulation to render"""
    simulation = sim

func add_ripple_at_position(position, strength=1.0, size=1.0):
    """Add a ripple effect at a specific position (for interaction)"""
    if simulation == null:
        return
    
    # Find particles near the position
    for p in simulation.particles:
        var particle_pos = Vector2(p.position.x, p.position.y)
        var dist = particle_pos.distance_to(position)
        
        if dist < particle_size * 4 * size:
            # Apply force based on distance
            var force_dir = (p.position - Vector3(position.x, position.y, 0)).normalized()
            var force_strength = strength * (1.0 - dist / (particle_size * 4 * size))
            p.force += force_dir * force_strength * 10.0
            
            # Increase velocity slightly for more dynamic effect
            p.velocity += force_dir * force_strength * 2.0