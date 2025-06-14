# =============================================================
# UFO MARCHING CUBES GENERATOR
# PURPOSE: Procedural 3D UFO mesh generation using marching cubes
# CREATED BY: Luminus (ChatGPT) - Mathematical SDF UFO Blueprint
# USAGE: Attach to MeshInstance3D or custom node for 3D UFO generation
# =============================================================

extends Node3D
class_name UFOMarchingCubes

@export var size := Vector3(2, 0.6, 2)
@export var resolution := 32  # Increase for higher LOD
@export var animate_lod := false
@export var lod_distance_threshold := 50.0

var mesh_instance: MeshInstance3D
var original_resolution: int

func _ready():
    original_resolution = resolution
    var mesh := _generate_ufo_mesh(size, resolution)
    mesh_instance = MeshInstance3D.new()
    mesh_instance.mesh = mesh
    add_child(mesh_instance)
    
    if animate_lod:
        set_process(true)

func _process(delta: float):
    if animate_lod and mesh_instance:
        _update_lod_based_on_distance()

func _update_lod_based_on_distance():
    """Dynamically adjust mesh resolution based on camera distance"""
    var camera = get_viewport().get_camera_3d()
    if not camera:
        return
    
    var distance = global_position.distance_to(camera.global_position)
    var new_resolution: int
    
    if distance < lod_distance_threshold * 0.5:
        new_resolution = original_resolution  # High detail
    elif distance < lod_distance_threshold:
        new_resolution = original_resolution / 2  # Medium detail
    else:
        new_resolution = original_resolution / 4  # Low detail
    
    if new_resolution != resolution:
        resolution = new_resolution
        _regenerate_mesh()

func _regenerate_mesh():
    """Regenerate UFO mesh with current resolution"""
    if mesh_instance:
        var new_mesh = _generate_ufo_mesh(size, resolution)
        mesh_instance.mesh = new_mesh

func _generate_ufo_mesh(mesh_size: Vector3, mesh_resolution: int) -> ArrayMesh:
    """Generate UFO mesh using marching cubes algorithm"""
    # Note: This is a blueprint - actual marching cubes implementation needed
    # For now, using SurfaceTool as placeholder
    
    var surface_tool = SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    # Generate vertices using SDF-based approach
    _generate_ufo_vertices(surface_tool, mesh_size, mesh_resolution)
    
    # Generate normals and create mesh
    surface_tool.generate_normals()
    surface_tool.generate_tangents()
    
    return surface_tool.commit()

func _generate_ufo_vertices(surface_tool: SurfaceTool, mesh_size: Vector3, mesh_resolution: int):
    """Generate UFO vertices using SDF sampling (simplified marching cubes)"""
    var step = 2.0 / mesh_resolution
    
    # Sample the UFO SDF and create triangles
    for x in range(mesh_resolution):
        for y in range(mesh_resolution):
            for z in range(mesh_resolution):
                var pos = Vector3(
                    (x - mesh_resolution * 0.5) * step,
                    (y - mesh_resolution * 0.5) * step,
                    (z - mesh_resolution * 0.5) * step
                )
                
                # Sample SDF at 8 corners of cube
                var sdf_value = ufo_sdf(pos, mesh_size)
                
                # Simplified: only create vertex if inside SDF
                if sdf_value < 0:
                    _add_ufo_vertex(surface_tool, pos, mesh_size)

func _add_ufo_vertex(surface_tool: SurfaceTool, pos: Vector3, mesh_size: Vector3):
    """Add a vertex with proper UV and normal"""
    # Calculate UV coordinates
    var uv = Vector2(
        (pos.x / mesh_size.x) * 0.5 + 0.5,
        (pos.z / mesh_size.z) * 0.5 + 0.5
    )
    
    # Calculate normal using SDF gradient
    var normal = _calculate_sdf_normal(pos, mesh_size)
    
    surface_tool.set_normal(normal)
    surface_tool.set_uv(uv)
    surface_tool.add_vertex(pos)

func _calculate_sdf_normal(pos: Vector3, mesh_size: Vector3) -> Vector3:
    """Calculate normal using SDF gradient"""
    var epsilon = 0.01
    var normal = Vector3(
        ufo_sdf(pos + Vector3(epsilon, 0, 0), mesh_size) - ufo_sdf(pos - Vector3(epsilon, 0, 0), mesh_size),
        ufo_sdf(pos + Vector3(0, epsilon, 0), mesh_size) - ufo_sdf(pos - Vector3(0, epsilon, 0), mesh_size),
        ufo_sdf(pos + Vector3(0, 0, epsilon), mesh_size) - ufo_sdf(pos - Vector3(0, 0, epsilon), mesh_size)
    )
    return normal.normalized()

# ===== SDF FUNCTIONS (SIGNED DISTANCE FIELDS) =====

func ufo_sdf(pos: Vector3, mesh_size: Vector3) -> float:
    """Custom SDF for UFO: dome + body = union of two SDFs"""
    var dome = sphere_sdf(pos - Vector3(0, 0.15 * mesh_size.y, 0), mesh_size.x * 0.45)
    var body = ellipsoid_sdf(pos, mesh_size * Vector3(1, 0.4, 1))
    return min(dome, body)  # Union operation

func sphere_sdf(p: Vector3, r: float) -> float:
    """Sphere signed distance field"""
    return p.length() - r

func ellipsoid_sdf(p: Vector3, radii: Vector3) -> float:
    """Ellipsoid signed distance field"""
    var normalized = Vector3(p.x / radii.x, p.y / radii.y, p.z / radii.z)
    return normalized.length() - 1.0

func box_sdf(p: Vector3, b: Vector3) -> float:
    """Box signed distance field"""
    var q = Vector3(abs(p.x) - b.x, abs(p.y) - b.y, abs(p.z) - b.z)
    return Vector3(max(q.x, 0), max(q.y, 0), max(q.z, 0)).length() + min(max(q.x, max(q.y, q.z)), 0.0)

func torus_sdf(p: Vector3, t: Vector2) -> float:
    """Torus signed distance field"""
    var q = Vector2(Vector2(p.x, p.z).length() - t.x, p.y)
    return q.length() - t.y

# ===== SDF OPERATIONS =====

func sdf_union(d1: float, d2: float) -> float:
    """Union of two SDFs"""
    return min(d1, d2)

func sdf_subtraction(d1: float, d2: float) -> float:
    """Subtract d2 from d1"""
    return max(-d2, d1)

func sdf_intersection(d1: float, d2: float) -> float:
    """Intersection of two SDFs"""
    return max(d1, d2)

func sdf_smooth_union(d1: float, d2: float, k: float) -> float:
    """Smooth union of two SDFs"""
    var h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0)
    return lerp(d2, d1, h) - k * h * (1.0 - h)

# ===== ADVANCED UFO VARIANTS =====

func alien_mothership_sdf(pos: Vector3, mesh_size: Vector3) -> float:
    """More complex UFO with multiple sections"""
    var main_body = ellipsoid_sdf(pos, mesh_size)
    var top_dome = sphere_sdf(pos - Vector3(0, mesh_size.y * 0.3, 0), mesh_size.x * 0.6)
    var bottom_ring = torus_sdf(pos + Vector3(0, mesh_size.y * 0.2, 0), Vector2(mesh_size.x * 0.8, 0.1))
    
    var ufo_base = sdf_union(main_body, top_dome)
    return sdf_union(ufo_base, bottom_ring)

func crystalline_ufo_sdf(pos: Vector3, mesh_size: Vector3) -> float:
    """Crystalline/geometric UFO design"""
    var core = sphere_sdf(pos, mesh_size.x * 0.4)
    var outer_shell = sphere_sdf(pos, mesh_size.x * 0.8)
    var crystal_cut = box_sdf(pos, mesh_size * 0.6)
    
    var hollow_sphere = sdf_subtraction(core, outer_shell)
    return sdf_intersection(hollow_sphere, crystal_cut)

# ===== TEXTURE3D GENERATION HELPERS =====

func generate_noise_texture3d(size: int) -> ImageTexture3D:
    """Generate 3D noise texture for alien materials"""
    var images: Array[Image] = []
    
    for z in range(size):
        var image = Image.create(size, size, false, Image.FORMAT_RGB8)
        
        for x in range(size):
            for y in range(size):
                var noise_val = _fractal_noise(Vector3(x, y, z) / float(size))
                var color = Color(noise_val, noise_val * 0.8, noise_val * 1.2)
                image.set_pixel(x, y, color)
        
        images.append(image)
    
    var texture3d = ImageTexture3D.new()
    texture3d.create_from_images(images)
    return texture3d

func _fractal_noise(pos: Vector3) -> float:
    """Simple fractal noise for texture generation"""
    var value = 0.0
    var amplitude = 1.0
    var frequency = 1.0
    
    for i in range(4):
        value += amplitude * (sin(pos.x * frequency) * cos(pos.y * frequency) * sin(pos.z * frequency))
        amplitude *= 0.5
        frequency *= 2.0
    
    return (value + 1.0) * 0.5  # Normalize to 0-1

# ===== USAGE EXAMPLE =====
# var ufo_generator = UFOMarchingCubes.new()
# ufo_generator.size = Vector3(3, 1, 3)  # Larger UFO
# ufo_generator.resolution = 64         # Higher detail
# ufo_generator.animate_lod = true      # Enable LOD
# add_child(ufo_generator)