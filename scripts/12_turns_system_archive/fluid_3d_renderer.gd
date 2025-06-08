extends Node3D

class_name Fluid3DRenderer

# Reference to fluid simulation
var simulation: FluidSimulationCore = null

# Rendering properties
@export_category("Rendering Methods")
@export var render_method: int = 0  # 0=Particles, 1=Metaballs, 2=Mesh Surface
@export var surface_detail: float = 1.0  # Detail level for mesh surface (0.1-2.0)
@export var particle_size: float = 0.1
@export var use_instancing: bool = true
@export var max_particles_to_render: int = 10000
@export var use_imposters: bool = false  # Use billboards instead of spheres
@export_color var base_color: Color = Color(0.0, 0.5, 1.0, 0.8) 

# Fluid mesh properties
@export_category("Fluid Surface Properties")
@export_range(0.1, 2.0) var metaball_threshold: float = 0.5
@export_range(0.1, 2.0) var surface_smoothing: float = 1.0
@export var update_interval: float = 0.1  # Surface update frequency in seconds
@export var use_adaptive_resolution: bool = true  # Adjust resolution based on particle count

# Visual effects
@export_category("Visual Effects")
@export var enable_refraction: bool = true
@export var refraction_strength: float = 0.1
@export var enable_reflection: bool = true
@export var reflection_strength: float = 0.3
@export var enable_foam: bool = true
@export var foam_threshold: float = 0.7
@export_color var foam_color: Color = Color(1.0, 1.0, 1.0, 0.9)
@export var enable_caustics: bool = true
@export var enable_depth_fade: bool = true
@export var depth_fade_distance: float = 2.0
@export var add_ripples: bool = true
@export var ripple_speed: float = 1.0
@export var ripple_height: float = 0.03

# Performance options
@export_category("Performance")
@export_range(8, 100) var surface_resolution: int = 32  # Grid resolution for marching cubes
@export var lod_distance: float = 20.0  # Distance for level of detail changes
@export var occlusion_culling: bool = true  # Cull particles not visible to camera
@export var use_shader_lod: bool = true  # Use LOD in shaders based on distance
@export var frustum_culling: bool = true  # Cull particles outside camera frustum

# Internal variables
var _time: float = 0.0
var _surface_update_timer: float = 0.0
var _particle_mesh_instance: MeshInstance3D = null
var _surface_mesh_instance: MeshInstance3D = null
var _last_camera_position: Vector3 = Vector3.ZERO
var _fluid_material: Material = null
var _foam_material: Material = null
var _particle_material: Material = null
var _impostor_material: Material = null
var _multimesh: MultiMesh = null
var _needs_rebuild: bool = true

# Surface generation variables
var _last_bounds: AABB = AABB()
var _volume_texture: RenderTexture3D = null
var _marching_cubes_data: Array = []
var _surface_mesh_arrays: Array = []

func _ready():
    # Initialize materials
    _init_materials()
    
    # Initialize meshes based on render method
    _init_meshes()
    
    # Initialize camera tracking
    _last_camera_position = _get_camera_position()
    
    # Create initial volume texture for metaball approach
    if render_method == 1:  # Metaballs
        _create_volume_texture()

func _init_materials():
    # Load materials or create default ones
    _fluid_material = _create_fluid_material()
    _foam_material = _create_foam_material()
    _particle_material = _create_particle_material() 
    _impostor_material = _create_impostor_material()

func _init_meshes():
    # Create different mesh objects depending on render method
    match render_method:
        0:  # Particles
            _setup_particle_rendering()
        1:  # Metaballs
            _setup_metaball_rendering()
        2:  # Mesh Surface
            _setup_surface_rendering()

func _process(delta):
    _time += delta
    _surface_update_timer += delta
    
    # Check if camera moved significantly
    var camera_pos = _get_camera_position()
    var camera_moved = camera_pos.distance_to(_last_camera_position) > 0.5
    if camera_moved:
        _last_camera_position = camera_pos
    
    # Update shader parameters that change every frame
    _update_shader_parameters(delta)
    
    # Check if surface needs updating
    if render_method != 0:  # Not particle-only
        if _needs_rebuild or _surface_update_timer >= update_interval:
            _surface_update_timer = 0.0
            _rebuild_fluid_surface()
            _needs_rebuild = false

func _physics_process(delta):
    # Update particles for instanced rendering
    if render_method == 0 and use_instancing and simulation != null:
        _update_particle_instances()

func _setup_particle_rendering():
    # Remove any existing instances
    if _particle_mesh_instance != null:
        _particle_mesh_instance.queue_free()
    
    if use_instancing:
        # Create multimesh for instanced rendering
        _multimesh = MultiMesh.new()
        _multimesh.transform_format = MultiMesh.TRANSFORM_3D
        _multimesh.color_format = MultiMesh.COLOR_FLOAT
        _multimesh.instance_count = 0  # Will be updated dynamically
        
        # Create base sphere mesh
        var sphere = SphereMesh.new()
        sphere.radius = particle_size / 2.0
        sphere.height = particle_size
        sphere.radial_segments = 8
        sphere.rings = 4
        _multimesh.mesh = sphere
        
        # Create mesh instance with multimesh
        _particle_mesh_instance = MeshInstance3D.new()
        _particle_mesh_instance.multimesh = _multimesh
        _particle_mesh_instance.material_override = _particle_material
        add_child(_particle_mesh_instance)
    else:
        # Just create a placeholder - individual spheres will be created later
        _particle_mesh_instance = MeshInstance3D.new()
        add_child(_particle_mesh_instance)

func _setup_metaball_rendering():
    # Create shader-based metaball rendering setup
    _surface_mesh_instance = MeshInstance3D.new()
    add_child(_surface_mesh_instance)
    
    # Initially use a simple plane mesh
    var plane_mesh = PlaneMesh.new()
    plane_mesh.size = Vector2(2, 2)
    _surface_mesh_instance.mesh = plane_mesh
    
    # Assign material
    _surface_mesh_instance.material_override = _fluid_material

func _setup_surface_rendering():
    # Create mesh surface rendering setup
    _surface_mesh_instance = MeshInstance3D.new()
    add_child(_surface_mesh_instance)
    
    # Create empty initial mesh
    var array_mesh = ArrayMesh.new()
    _surface_mesh_instance.mesh = array_mesh
    
    # Assign material
    _surface_mesh_instance.material_override = _fluid_material

func _update_shader_parameters(delta):
    # Update time-dependent parameters in all materials
    if _fluid_material:
        _fluid_material.set_shader_parameter("time", _time)
        
        if add_ripples:
            var wave_params = Vector4(
                ripple_speed, 
                ripple_height,
                1.0 + sin(_time * 0.5) * 0.2,  # Wave frequency modulation
                1.0 + cos(_time * 0.3) * 0.1   # Wave scale modulation
            )
            _fluid_material.set_shader_parameter("wave_params", wave_params)
            
    if _foam_material:
        _foam_material.set_shader_parameter("time", _time)
        
    if _particle_material:
        _particle_material.set_shader_parameter("time", _time)
    
    if _impostor_material:
        _impostor_material.set_shader_parameter("time", _time)
        
        # Update camera position for billboarding
        var camera = get_viewport().get_camera_3d()
        if camera:
            _impostor_material.set_shader_parameter("camera_position", camera.global_position)

func _update_particle_instances():
    if simulation == null or _multimesh == null:
        return
    
    var particles = simulation.get_particles_for_rendering()
    var render_count = min(particles.size(), max_particles_to_render)
    
    # Resize multimesh if needed
    if _multimesh.instance_count != render_count:
        _multimesh.instance_count = render_count
    
    # Skip if no particles
    if render_count == 0:
        return
    
    # Update transforms and colors for each particle
    for i in range(render_count):
        var p = particles[i]
        
        # Create transform
        var pos = p.position
        var scale = Vector3.ONE * (particle_size / 2.0)
        
        # Apply velocity-based stretching for fast particles
        if p.has("velocity"):
            var speed = p.velocity.length()
            if speed > 1.0:
                var stretch_dir = p.velocity.normalized()
                var stretch_factor = min(1.0 + speed * 0.1, 2.0)
                scale += stretch_dir * stretch_factor * 0.1
        
        var transform = Transform3D().scaled(scale)
        transform.origin = pos
        
        # Set instance transform
        _multimesh.set_instance_transform(i, transform)
        
        # Set instance color
        var color = base_color
        if p.has("color"):
            color = p.color
            
        # Adjust color for surface particles
        if p.has("is_surface") and p.is_surface and enable_foam:
            color = color.lerp(foam_color, foam_threshold)
            
        _multimesh.set_instance_color(i, color)

func _rebuild_fluid_surface():
    if simulation == null:
        return
    
    var particles = simulation.get_particles_for_rendering()
    if particles.size() == 0:
        # No particles to render, clear surface
        if render_method == 2 and _surface_mesh_instance:
            var empty_mesh = ArrayMesh.new()
            _surface_mesh_instance.mesh = empty_mesh
        return
    
    # Get fluid bounds
    var bounds = _calculate_fluid_bounds(particles)
    _last_bounds = bounds
    
    match render_method:
        1:  # Metaballs
            _update_volume_texture(particles, bounds)
        2:  # Mesh Surface
            _create_mesh_surface(particles, bounds)

func _calculate_fluid_bounds(particles):
    var min_pos = Vector3(INF, INF, INF)
    var max_pos = Vector3(-INF, -INF, -INF)
    
    for p in particles:
        min_pos.x = min(min_pos.x, p.position.x)
        min_pos.y = min(min_pos.y, p.position.y)
        min_pos.z = min(min_pos.z, p.position.z)
        
        max_pos.x = max(max_pos.x, p.position.x)
        max_pos.y = max(max_pos.y, p.position.y)
        max_pos.z = max(max_pos.z, p.position.z)
    
    # Add padding
    var padding = Vector3.ONE * particle_size * 2.0
    min_pos -= padding
    max_pos += padding
    
    return AABB(min_pos, max_pos - min_pos)

func _create_volume_texture():
    # Create 3D texture for metaball field
    var resolution = Vector3i(32, 32, 32)
    if use_adaptive_resolution:
        # Adjust resolution based on particle count
        var count = simulation.get_particle_count() if simulation else 100
        var factor = clamp(sqrt(count) / 20.0, 0.5, 2.0)
        resolution = Vector3i(32, 32, 32) * factor
        
    # Ensure resolution is between 16 and 64 in each dimension
    resolution.x = clamp(resolution.x, 16, 64)
    resolution.y = clamp(resolution.y, 16, 64)
    resolution.z = clamp(resolution.z, 16, 64)
    
    _volume_texture = RenderTexture3D.new()
    _volume_texture.size = resolution
    _volume_texture.format = RenderTextureFormat.R8

func _update_volume_texture(particles, bounds):
    if _volume_texture == null:
        _create_volume_texture()
    
    # Calculate field values
    var resolution = _volume_texture.size
    var field_data = PackedFloat32Array()
    field_data.resize(resolution.x * resolution.y * resolution.z)
    
    for x in range(resolution.x):
        for y in range(resolution.y):
            for z in range(resolution.z):
                var pos = Vector3(
                    lerp(bounds.position.x, bounds.end.x, float(x) / resolution.x),
                    lerp(bounds.position.y, bounds.end.y, float(y) / resolution.y),
                    lerp(bounds.position.z, bounds.end.z, float(z) / resolution.z)
                )
                
                var density = 0.0
                for p in particles:
                    var dist = pos.distance_to(p.position)
                    if dist < particle_size * 2.0:
                        density += pow(1.0 - dist / (particle_size * 2.0), 2.0)
                
                var idx = x + y * resolution.x + z * resolution.x * resolution.y
                field_data[idx] = density
    
    # Update volume texture data
    var image_3d = Image3D.new()
    image_3d.create_from_data(resolution.x, resolution.y, resolution.z, 
                            Image.FORMAT_R8, field_data)
    
    _volume_texture.data = image_3d
    
    # Update material
    if _fluid_material:
        _fluid_material.set_shader_parameter("volume_texture", _volume_texture)
        _fluid_material.set_shader_parameter("bounds_min", bounds.position)
        _fluid_material.set_shader_parameter("bounds_size", bounds.size)
        _fluid_material.set_shader_parameter("threshold", metaball_threshold)

func _create_mesh_surface(particles, bounds):
    # Create surface mesh using marching cubes
    
    # Determine resolution based on detail level and bounds size
    var base_resolution = int(surface_resolution * surface_detail)
    var x_res = int(base_resolution * (bounds.size.x / max(bounds.size.x, bounds.size.y, bounds.size.z)))
    var y_res = int(base_resolution * (bounds.size.y / max(bounds.size.x, bounds.size.y, bounds.size.z)))
    var z_res = int(base_resolution * (bounds.size.z / max(bounds.size.x, bounds.size.y, bounds.size.z)))
    
    # Ensure minimum resolution
    x_res = max(x_res, 8)
    y_res = max(y_res, 8)
    z_res = max(z_res, 8)
    
    # Calculate cell size
    var cell_size = Vector3(
        bounds.size.x / x_res,
        bounds.size.y / y_res,
        bounds.size.z / z_res
    )
    
    # Generate scalar field
    var field = {}
    for x in range(x_res + 1):
        for y in range(y_res + 1):
            for z in range(z_res + 1):
                var pos = bounds.position + Vector3(
                    x * cell_size.x,
                    y * cell_size.y, 
                    z * cell_size.z
                )
                
                var density = 0.0
                for p in particles:
                    var dist = pos.distance_to(p.position)
                    if dist < particle_size * 2.0:
                        density += pow(1.0 - dist / (particle_size * 2.0), 2.0)
                
                field[Vector3i(x, y, z)] = density
    
    # Generate mesh using marching cubes
    var vertices = []
    var normals = []
    var indices = []
    
    # Apply marching cubes algorithm
    _marching_cubes(field, x_res, y_res, z_res, bounds, 
                   cell_size, metaball_threshold, 
                   vertices, normals, indices)
    
    # Skip if no vertices
    if vertices.size() == 0:
        return
    
    # Create mesh arrays
    var arrays = []
    arrays.resize(Mesh.ARRAY_MAX)
    arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(vertices)
    arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array(normals)
    arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(indices)
    
    # Create UV coordinates based on position
    var uvs = []
    for v in vertices:
        var uv = Vector2(
            (v.x - bounds.position.x) / bounds.size.x,
            (v.z - bounds.position.z) / bounds.size.z
        )
        uvs.append(uv)
    arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array(uvs)
    
    # Create colors (can be used for effects)
    var colors = []
    for v in vertices:
        var t = (v.y - bounds.position.y) / bounds.size.y
        var color = base_color
        
        # Adjust color based on height
        color.r += t * 0.1
        color.g += t * 0.2
        color.b += (1.0 - t) * 0.1
        
        colors.append(color)
    arrays[Mesh.ARRAY_COLOR] = PackedColorArray(colors)
    
    # Create or update mesh
    var array_mesh = ArrayMesh.new()
    array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
    
    # Smooth normals for better appearance
    if surface_smoothing > 0.0:
        # Would call _smooth_normals here if implemented
        pass
    
    # Assign to mesh instance
    _surface_mesh_instance.mesh = array_mesh

func _marching_cubes(field, x_res, y_res, z_res, bounds, cell_size, 
                    threshold, vertices, normals, indices):
    """Implementation of Marching Cubes algorithm for isosurface extraction"""
    # Marching cubes lookup tables
    var edge_table = _get_marching_cubes_edge_table()
    var tri_table = _get_marching_cubes_tri_table()
    
    # Process each cell
    for x in range(x_res):
        for y in range(y_res):
            for z in range(z_res):
                # Get the values at the 8 corners of the cube
                var cube_values = []
                var positions = []
                
                for i in range(8):
                    var corner = Vector3i(
                        x + (i & 1),
                        y + ((i & 2) >> 1),
                        z + ((i & 4) >> 2)
                    )
                    
                    var pos = bounds.position + Vector3(
                        corner.x * cell_size.x,
                        corner.y * cell_size.y,
                        corner.z * cell_size.z
                    )
                    
                    positions.append(pos)
                    
                    if field.has(corner):
                        cube_values.append(field[corner])
                    else:
                        cube_values.append(0.0)
                
                # Calculate cube index
                var cube_index = 0
                for i in range(8):
                    if cube_values[i] > threshold:
                        cube_index |= (1 << i)
                
                # Skip empty cubes
                if cube_index == 0 or cube_index == 255:
                    continue
                
                # Get edge flags
                var edge_flags = edge_table[cube_index]
                
                # Skip if no edges
                if edge_flags == 0:
                    continue
                
                # Calculate intersection vertices
                var edge_vertices = {}
                
                if edge_flags & 1:    # Edge 0
                    edge_vertices[0] = _interpolate_vertex(positions[0], positions[1], 
                                                         cube_values[0], cube_values[1], threshold)
                
                if edge_flags & 2:    # Edge 1
                    edge_vertices[1] = _interpolate_vertex(positions[1], positions[2], 
                                                         cube_values[1], cube_values[2], threshold)
                
                if edge_flags & 4:    # Edge 2
                    edge_vertices[2] = _interpolate_vertex(positions[2], positions[3], 
                                                         cube_values[2], cube_values[3], threshold)
                
                if edge_flags & 8:    # Edge 3
                    edge_vertices[3] = _interpolate_vertex(positions[3], positions[0], 
                                                         cube_values[3], cube_values[0], threshold)
                
                if edge_flags & 16:   # Edge 4
                    edge_vertices[4] = _interpolate_vertex(positions[4], positions[5], 
                                                         cube_values[4], cube_values[5], threshold)
                
                if edge_flags & 32:   # Edge 5
                    edge_vertices[5] = _interpolate_vertex(positions[5], positions[6], 
                                                         cube_values[5], cube_values[6], threshold)
                
                if edge_flags & 64:   # Edge 6
                    edge_vertices[6] = _interpolate_vertex(positions[6], positions[7], 
                                                         cube_values[6], cube_values[7], threshold)
                
                if edge_flags & 128:  # Edge 7
                    edge_vertices[7] = _interpolate_vertex(positions[7], positions[4], 
                                                         cube_values[7], cube_values[4], threshold)
                
                if edge_flags & 256:  # Edge 8
                    edge_vertices[8] = _interpolate_vertex(positions[0], positions[4], 
                                                         cube_values[0], cube_values[4], threshold)
                
                if edge_flags & 512:  # Edge 9
                    edge_vertices[9] = _interpolate_vertex(positions[1], positions[5], 
                                                         cube_values[1], cube_values[5], threshold)
                
                if edge_flags & 1024: # Edge 10
                    edge_vertices[10] = _interpolate_vertex(positions[2], positions[6], 
                                                         cube_values[2], cube_values[6], threshold)
                
                if edge_flags & 2048: # Edge 11
                    edge_vertices[11] = _interpolate_vertex(positions[3], positions[7], 
                                                         cube_values[3], cube_values[7], threshold)
                
                # Create triangles based on tri_table
                var i = 0
                while i < 16 and tri_table[cube_index][i] != -1:
                    var a = edge_vertices[tri_table[cube_index][i]]
                    var b = edge_vertices[tri_table[cube_index][i+1]]
                    var c = edge_vertices[tri_table[cube_index][i+2]]
                    
                    # Calculate normal
                    var normal = (b - a).cross(c - a).normalized()
                    
                    # Add vertices and normals
                    vertices.append(a)
                    vertices.append(b)
                    vertices.append(c)
                    
                    normals.append(normal)
                    normals.append(normal)
                    normals.append(normal)
                    
                    # Add indices
                    var base_idx = indices.size()
                    indices.append(base_idx)
                    indices.append(base_idx + 1)
                    indices.append(base_idx + 2)
                    
                    i += 3

func _interpolate_vertex(v1, v2, val1, val2, threshold):
    """Linear interpolation between vertices based on field values"""
    if abs(threshold - val1) < 0.00001:
        return v1
    if abs(threshold - val2) < 0.00001:
        return v2
    if abs(val1 - val2) < 0.00001:
        return v1
    
    var t = (threshold - val1) / (val2 - val1)
    return v1 + (v2 - v1) * t

func _create_fluid_material():
    """Create default fluid material with shader"""
    var material = ShaderMaterial.new()
    var shader = Shader.new()
    
    # Load shader code based on render method
    match render_method:
        0:  # Particles
            shader.code = _get_particle_shader_code()
        1:  # Metaballs
            shader.code = _get_metaball_shader_code()
        2:  # Mesh Surface
            shader.code = _get_surface_shader_code()
    
    material.shader = shader
    
    # Set common parameters
    material.set_shader_parameter("base_color", base_color)
    material.set_shader_parameter("refraction_strength", refraction_strength)
    material.set_shader_parameter("reflection_strength", reflection_strength)
    material.set_shader_parameter("depth_fade_distance", depth_fade_distance)
    
    return material

func _create_foam_material():
    """Create foam material with shader"""
    var material = ShaderMaterial.new()
    var shader = Shader.new()
    shader.code = _get_foam_shader_code()
    material.shader = shader
    
    # Set parameters
    material.set_shader_parameter("foam_color", foam_color)
    
    return material

func _create_particle_material():
    """Create default particle material"""
    var material = StandardMaterial3D.new()
    material.albedo_color = base_color
    material.metallic = 0.1
    material.roughness = 0.2
    material.clearcoat_enabled = true
    material.clearcoat = 0.5
    material.clearcoat_roughness = 0.1
    material.refraction_enabled = enable_refraction
    material.refraction_scale = refraction_strength
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    
    return material

func _create_impostor_material():
    """Create billboarded impostor material for particles"""
    var material = ShaderMaterial.new()
    var shader = Shader.new()
    shader.code = _get_impostor_shader_code()
    material.shader = shader
    
    # Set parameters
    material.set_shader_parameter("particle_color", base_color)
    
    return material

func _get_camera_position():
    """Get current camera position"""
    var camera = get_viewport().get_camera_3d()
    if camera:
        return camera.global_position
    return Vector3.ZERO

func _get_particle_shader_code():
    """Get shader code for particle rendering"""
    return """
shader_type spatial;
render_mode blend_mix, depth_prepass, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.0, 0.5, 1.0, 0.8);
uniform float time;
uniform float refraction_strength : hint_range(0.0, 1.0) = 0.1;
uniform float roughness : hint_range(0.0, 1.0) = 0.2;
uniform float metallic : hint_range(0.0, 1.0) = 0.1;

void vertex() {
    // Add slight wobble to particles
    VERTEX.y += sin(VERTEX.x * 4.0 + time * 2.0) * 0.01;
}

void fragment() {
    ALBEDO = base_color.rgb;
    ALPHA = base_color.a;
    METALLIC = metallic;
    ROUGHNESS = roughness;
    SPECULAR = 0.5;
    
    // Add refraction
    REFRACTION = refraction_strength;
    
    // Fresnel effect for edge highlights
    float fresnel = pow(1.0 - dot(NORMAL, VIEW), 5.0);
    EMISSION = base_color.rgb * fresnel * 0.2;
}
"""

func _get_metaball_shader_code():
    """Get shader code for metaball volume rendering"""
    return """
shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler3D volume_texture;
uniform vec3 bounds_min;
uniform vec3 bounds_size;
uniform float threshold = 0.5;
uniform vec4 base_color : source_color = vec4(0.0, 0.5, 1.0, 0.8);
uniform float time;
uniform float refraction_strength : hint_range(0.0, 1.0) = 0.1;
uniform float reflection_strength : hint_range(0.0, 1.0) = 0.3;
uniform float depth_fade_distance = 2.0;
uniform vec4 wave_params = vec4(1.0, 0.03, 1.0, 1.0); // speed, height, freq mod, scale mod

// Ray marching parameters
const int MAX_STEPS = 128;
const float STEP_SIZE = 0.05;
const float EPSILON = 0.001;

float sample_volume(vec3 pos) {
    // Convert to normalized coordinates in the volume texture
    vec3 norm_pos = (pos - bounds_min) / bounds_size;
    
    // Check if outside bounds
    if (any(lessThan(norm_pos, vec3(0.0))) || any(greaterThan(norm_pos, vec3(1.0)))) {
        return 0.0;
    }
    
    return texture(volume_texture, norm_pos).r;
}

vec3 estimate_normal(vec3 pos) {
    vec2 e = vec2(EPSILON, 0.0);
    return normalize(vec3(
        sample_volume(pos + e.xyy) - sample_volume(pos - e.xyy),
        sample_volume(pos + e.yxy) - sample_volume(pos - e.yxy),
        sample_volume(pos + e.yyx) - sample_volume(pos - e.yyx)
    ));
}

void fragment() {
    // Ray marching setup
    vec3 ray_origin = CAMERA_POSITION;
    vec3 ray_dir = normalize(VERTEX - CAMERA_POSITION);
    
    // Intersect with bounding box
    vec3 inv_ray_dir = 1.0 / ray_dir;
    vec3 t1 = (bounds_min - ray_origin) * inv_ray_dir;
    vec3 t2 = (bounds_min + bounds_size - ray_origin) * inv_ray_dir;
    vec3 tmin = min(t1, t2);
    vec3 tmax = max(t1, t2);
    
    float t_near = max(max(tmin.x, tmin.y), tmin.z);
    float t_far = min(min(tmax.x, tmax.y), tmax.z);
    
    // Skip if ray doesn't intersect box
    if (t_near > t_far || t_far < 0.0) {
        discard;
    }
    
    // Clamp to near plane
    t_near = max(t_near, 0.0);
    
    // Ray march through volume
    float t = t_near;
    bool hit = false;
    vec3 hit_pos = vec3(0.0);
    
    for (int i = 0; i < MAX_STEPS; i++) {
        if (t > t_far) break;
        
        vec3 pos = ray_origin + ray_dir * t;
        float value = sample_volume(pos);
        
        if (value > threshold) {
            hit = true;
            hit_pos = pos;
            break;
        }
        
        t += STEP_SIZE;
    }
    
    if (!hit) {
        discard;
    }
    
    // Calculate surface properties
    vec3 normal = estimate_normal(hit_pos);
    
    // Add wave displacement
    float wave_speed = wave_params.x;
    float wave_height = wave_params.y;
    float wave_freq_mod = wave_params.z;
    float wave_scale_mod = wave_params.w;
    
    float wave = sin((hit_pos.x + hit_pos.z) * 2.0 * wave_freq_mod + time * wave_speed) * 
                 sin((hit_pos.z - hit_pos.x) * 3.0 * wave_scale_mod + time * wave_speed * 0.7) * 
                 wave_height;
    
    // Adjust normal for waves
    normal.y += wave * 5.0;
    normal = normalize(normal);
    
    // Basic lighting
    ALBEDO = base_color.rgb;
    ALPHA = base_color.a;
    METALLIC = 0.1;
    ROUGHNESS = 0.2;
    SPECULAR = 0.5;
    
    // Add fresnel effect for edge highlights
    float fresnel = pow(1.0 - dot(normal, VIEW), 5.0);
    EMISSION = base_color.rgb * fresnel * 0.3;
    
    // Refraction based on depth
    float depth = length(hit_pos - CAMERA_POSITION);
    float depth_fade = 1.0 - exp(-depth / depth_fade_distance);
    
    REFRACTION = refraction_strength * (1.0 - depth_fade);
    
    // Adjust alpha based on depth
    ALPHA *= mix(0.7, 1.0, depth_fade);
    
    // Set correct depth
    DEPTH = length(hit_pos - CAMERA_POSITION);
}
"""

func _get_surface_shader_code():
    """Get shader code for mesh surface rendering"""
    return """
shader_type spatial;
render_mode blend_mix, depth_draw_always, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 base_color : source_color = vec4(0.0, 0.5, 1.0, 0.8);
uniform float time;
uniform float refraction_strength : hint_range(0.0, 1.0) = 0.1;
uniform float reflection_strength : hint_range(0.0, 1.0) = 0.3;
uniform float depth_fade_distance = 2.0;
uniform vec4 wave_params = vec4(1.0, 0.03, 1.0, 1.0); // speed, height, freq mod, scale mod
uniform sampler2D surface_normal_map : hint_normal;
uniform sampler2D foam_texture : hint_default_white;
uniform bool enable_caustics = true;
uniform bool enable_foam = true;
uniform float foam_threshold = 0.7;
uniform vec4 foam_color : source_color = vec4(1.0, 1.0, 1.0, 0.9);

void vertex() {
    // Add wave displacement
    float wave_speed = wave_params.x;
    float wave_height = wave_params.y;
    float wave_freq_mod = wave_params.z;
    float wave_scale_mod = wave_params.w;
    
    float wave = sin((VERTEX.x + VERTEX.z) * 2.0 * wave_freq_mod + time * wave_speed) * 
                 sin((VERTEX.z - VERTEX.x) * 3.0 * wave_scale_mod + time * wave_speed * 0.7) * 
                 wave_height;
    
    // Apply wave displacement to vertex
    VERTEX.y += wave;
    
    // Adjust normal for waves
    NORMAL.y += wave * 5.0;
    NORMAL = normalize(NORMAL);
}

void fragment() {
    // Basic color
    ALBEDO = base_color.rgb;
    ALPHA = base_color.a;
    METALLIC = 0.1;
    ROUGHNESS = 0.2;
    SPECULAR = 0.5;
    
    // Use vertex color if available
    if (COLOR.a > 0.0) {
        ALBEDO = COLOR.rgb;
        ALPHA = COLOR.a;
    }
    
    // Normal mapping for ripples
    vec3 normal_map = texture(surface_normal_map, UV * 3.0 + vec2(time * 0.05, time * 0.03)).rgb * 2.0 - 1.0;
    normal_map = mix(vec3(0.0, 1.0, 0.0), normal_map, 0.3);
    NORMAL_MAP = normal_map;
    NORMAL_MAP_DEPTH = 0.2;
    
    // Add fresnel effect for edge highlights
    float fresnel = pow(1.0 - dot(NORMAL, VIEW), 5.0);
    EMISSION = base_color.rgb * fresnel * 0.3;
    
    // Refraction based on depth
    float depth = texture(DEPTH_TEXTURE, SCREEN_UV).r;
    vec4 world_pos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth, 1.0);
    world_pos.xyz /= world_pos.w;
    
    float depth_diff = length(world_pos.xyz - VERTEX);
    float depth_fade = 1.0 - exp(-depth_diff / depth_fade_distance);
    
    REFRACTION = refraction_strength * (1.0 - depth_fade);
    
    // Add foam
    if (enable_foam) {
        float foam_noise = texture(foam_texture, UV * 5.0 + vec2(time * 0.1, 0.0)).r;
        float foam_pattern = texture(foam_texture, UV * 3.0 - vec2(time * 0.2, 0.0)).r;
        float foam = foam_noise * foam_pattern;
        
        // Apply foam at edges and shallow areas
        float foam_mask = fresnel * 0.7 + (1.0 - depth_fade) * 0.5;
        
        if (foam_mask > foam_threshold && foam > 0.4) {
            ALBEDO = mix(ALBEDO, foam_color.rgb, foam_mask);
            ROUGHNESS = mix(ROUGHNESS, 0.7, foam_mask);
            SPECULAR = mix(SPECULAR, 0.1, foam_mask);
        }
    }
    
    // Add caustics
    if (enable_caustics && depth_fade < 0.5) {
        float caustic1 = texture(foam_texture, UV * 4.0 + vec2(time * 0.05, time * 0.03)).r;
        float caustic2 = texture(foam_texture, UV * 3.0 - vec2(time * 0.07, time * 0.02)).r;
        float caustic = pow(caustic1 * caustic2, 2.0) * (1.0 - depth_fade);
        
        EMISSION += vec3(0.2, 0.4, 0.8) * caustic * 0.5;
    }
}
"""

func _get_foam_shader_code():
    """Get shader code for foam rendering"""
    return """
shader_type spatial;
render_mode blend_add, depth_draw_never, cull_back, unshaded;

uniform vec4 foam_color : source_color = vec4(1.0, 1.0, 1.0, 0.9);
uniform float time;
uniform sampler2D foam_texture : hint_default_white;

void vertex() {
    // Push foam slightly above surface
    VERTEX.y += 0.005;
}

void fragment() {
    float foam_noise = texture(foam_texture, UV * 5.0 + vec2(time * 0.1, 0.0)).r;
    float foam_pattern = texture(foam_texture, UV * 3.0 - vec2(time * 0.2, 0.0)).r;
    float foam = foam_noise * foam_pattern * COLOR.a;
    
    ALBEDO = foam_color.rgb;
    ALPHA = foam * foam_color.a;
    EMISSION = foam_color.rgb * 0.5;
}
"""

func _get_impostor_shader_code():
    """Get shader code for particle impostors (billboards)"""
    return """
shader_type spatial;
render_mode blend_mix, depth_prepass, cull_disabled;

uniform vec4 particle_color : source_color = vec4(0.0, 0.5, 1.0, 0.8);
uniform float time;
uniform vec3 camera_position;

void vertex() {
    // Billboard the quad to face camera
    vec3 up = vec3(0.0, 1.0, 0.0);
    vec3 forward = normalize(camera_position - VERTEX);
    vec3 right = normalize(cross(up, forward));
    up = cross(forward, right);
    
    vec3 pos = VERTEX;
    vec3 offset = VERTEX - MODEL_MATRIX[3].xyz;
    
    // Apply billboard transform
    VERTEX = MODEL_MATRIX[3].xyz;
    VERTEX += right * offset.x;
    VERTEX += up * offset.y;
    VERTEX += forward * offset.z * 0.1; // Flatten slightly
    
    // Add subtle animation
    VERTEX.y += sin(time * 2.0 + pos.x + pos.z) * 0.01;
}

void fragment() {
    // Calculate distance from fragment to center of quad
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(UV, center) * 2.0;
    
    // Create soft circular shape
    float circle = 1.0 - smoothstep(0.8, 1.0, dist);
    
    // Add internal detail
    float detail = sin(dist * 3.1415) * 0.5 + 0.5;
    
    // Apply highlight in center
    float highlight = 1.0 - smoothstep(0.0, 0.3, dist);
    
    ALBEDO = particle_color.rgb;
    ALPHA = circle * particle_color.a;
    METALLIC = 0.1;
    ROUGHNESS = mix(0.2, 0.4, detail);
    SPECULAR = 0.5;
    
    // Add subtle emission for highlighting
    EMISSION = particle_color.rgb * highlight * 0.2;
}
"""

func _get_marching_cubes_edge_table():
    """Return edge table for marching cubes algorithm"""
    # This would typically contain a 256-entry array of integers
    # representing edge intersections for each cube configuration
    # For brevity, returning a placeholder
    var edge_table = []
    edge_table.resize(256)
    
    # Fill with actual values (first 16 entries shown as example)
    edge_table[0] = 0x0
    edge_table[1] = 0x109
    edge_table[2] = 0x203
    edge_table[3] = 0x30a
    edge_table[4] = 0x406
    edge_table[5] = 0x50f
    edge_table[6] = 0x605
    edge_table[7] = 0x70c
    edge_table[8] = 0x80c
    edge_table[9] = 0x905
    edge_table[10] = 0xa0f
    edge_table[11] = 0xb06
    edge_table[12] = 0xc0a
    edge_table[13] = 0xd03
    edge_table[14] = 0xe09
    edge_table[15] = 0xf00
    
    # Note: Complete table would have all 256 entries
    # For a complete implementation, load from a file or define the full array
    
    return edge_table

func _get_marching_cubes_tri_table():
    """Return triangle table for marching cubes algorithm"""
    # This would typically contain a 256-entry array of arrays
    # Each sub-array contains indices of up to 15 edges forming triangles
    # For brevity, returning a placeholder
    var tri_table = []
    tri_table.resize(256)
    
    # Fill with actual values (first entry shown as example)
    tri_table[0] = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]
    tri_table[1] = [0, 8, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]
    
    # Note: Complete table would have all 256 entries
    # For a complete implementation, load from a file or define the full array
    
    return tri_table

func set_simulation(sim):
    """Set the fluid simulation to render"""
    simulation = sim
    _needs_rebuild = true

func set_render_method(method):
    """Change the rendering method"""
    if method != render_method:
        render_method = method
        
        # Clean up existing instances
        if _particle_mesh_instance:
            _particle_mesh_instance.queue_free()
            _particle_mesh_instance = null
        
        if _surface_mesh_instance:
            _surface_mesh_instance.queue_free()
            _surface_mesh_instance = null
        
        # Initialize with new method
        _init_materials()
        _init_meshes()
        _needs_rebuild = true

func add_splash(position, force=5.0, size=1.0):
    """Create a splash effect at a specific position (for interaction)"""
    if simulation == null:
        return
        
    # Add particles for splash
    simulation.create_splash(position, size, int(20 * size), force)
    
    # Force surface rebuild
    _needs_rebuild = true