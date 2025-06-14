extends Node

class_name UnifiedCloudNoise

signal shape_generated(shape_id, dimension, complexity)
signal perspective_shifted(from_perspective, to_perspective)
signal cloud_merged(source_id, target_id, merge_point)
signal noise_transformed(noise_id, from_type, to_type)
signal dimensional_projection_created(projection_id, source_dimension, target_dimension)

# Noise configuration
const NOISE_TYPES = {
    "simplex": {
        "id": "simplex",
        "dimensions": 4,
        "energy_cost": 3.0,
        "complexity": 0.7,
        "formula": "snoise4(x, y, z, w)",
        "color": Color(0.3, 0.7, 1.0)
    },
    "perlin": {
        "id": "perlin",
        "dimensions": 3,
        "energy_cost": 2.0,
        "complexity": 0.5,
        "formula": "pnoise3(x, y, z)",
        "color": Color(0.7, 0.3, 1.0)
    },
    "worley": {
        "id": "worley",
        "dimensions": 3,
        "energy_cost": 4.0,
        "complexity": 0.8,
        "formula": "cellular3(x, y, z)",
        "color": Color(1.0, 0.7, 0.3)
    },
    "fractal": {
        "id": "fractal",
        "dimensions": 5,
        "energy_cost": 8.0,
        "complexity": 0.9,
        "formula": "fbm(x, y, z, octaves, lacunarity)",
        "color": Color(0.3, 1.0, 0.7)
    },
    "value": {
        "id": "value",
        "dimensions": 2,
        "energy_cost": 1.0,
        "complexity": 0.3,
        "formula": "vnoise2(x, y)",
        "color": Color(1.0, 0.3, 0.3)
    },
    "curl": {
        "id": "curl",
        "dimensions": 3,
        "energy_cost": 5.0,
        "complexity": 0.6,
        "formula": "curlNoise3(x, y, z)",
        "color": Color(0.3, 0.3, 1.0)
    },
    "voronoi": {
        "id": "voronoi",
        "dimensions": 3,
        "energy_cost": 3.5,
        "complexity": 0.6,
        "formula": "voronoi3(x, y, z)",
        "color": Color(1.0, 1.0, 0.3)
    },
    "ridged": {
        "id": "ridged",
        "dimensions": 4,
        "energy_cost": 6.0,
        "complexity": 0.8,
        "formula": "ridgedmf4(x, y, z, w, octaves)",
        "color": Color(0.7, 0.0, 0.7)
    },
    "turbulence": {
        "id": "turbulence",
        "dimensions": 3,
        "energy_cost": 7.0,
        "complexity": 0.85,
        "formula": "turbulence3(x, y, z, octaves)",
        "color": Color(0.0, 0.7, 0.7)
    }
}

# Shape configuration
const SHAPE_TYPES = {
    "point": {
        "id": "point",
        "dimensions": 0,
        "vertices": 1,
        "energy_cost": 0.1,
        "formula": "position",
        "color": Color(1.0, 1.0, 1.0)
    },
    "line": {
        "id": "line",
        "dimensions": 1,
        "vertices": 2,
        "energy_cost": 0.3,
        "formula": "lerp(p1, p2, t)",
        "color": Color(0.7, 0.7, 0.7)
    },
    "triangle": {
        "id": "triangle",
        "dimensions": 2,
        "vertices": 3,
        "energy_cost": 0.5,
        "formula": "barycentric(p1, p2, p3, a, b)",
        "color": Color(1.0, 0.7, 0.3)
    },
    "square": {
        "id": "square",
        "dimensions": 2,
        "vertices": 4,
        "energy_cost": 0.6,
        "formula": "bilinear(p1, p2, p3, p4, u, v)",
        "color": Color(0.3, 0.7, 1.0)
    },
    "pentagon": {
        "id": "pentagon",
        "dimensions": 2,
        "vertices": 5,
        "energy_cost": 0.7,
        "formula": "ngon(center, radius, 5, angle)",
        "color": Color(0.7, 1.0, 0.3)
    },
    "hexagon": {
        "id": "hexagon",
        "dimensions": 2,
        "vertices": 6,
        "energy_cost": 0.8,
        "formula": "ngon(center, radius, 6, angle)",
        "color": Color(1.0, 0.3, 0.7)
    },
    "tetrahedron": {
        "id": "tetrahedron",
        "dimensions": 3,
        "vertices": 4,
        "energy_cost": 1.0,
        "formula": "tetrahedral(p1, p2, p3, p4, a, b, c)",
        "color": Color(0.3, 1.0, 0.7)
    },
    "cube": {
        "id": "cube",
        "dimensions": 3,
        "vertices": 8,
        "energy_cost": 1.2,
        "formula": "trilinear(corners, u, v, w)",
        "color": Color(0.7, 0.3, 1.0)
    },
    "octahedron": {
        "id": "octahedron",
        "dimensions": 3,
        "vertices": 6,
        "energy_cost": 1.4,
        "formula": "octahedral(center, radius, orientation)",
        "color": Color(1.0, 0.7, 0.7)
    },
    "dodecahedron": {
        "id": "dodecahedron",
        "dimensions": 3,
        "vertices": 20,
        "energy_cost": 1.8,
        "formula": "dodecahedral(center, radius, orientation)",
        "color": Color(0.7, 0.7, 1.0)
    },
    "icosahedron": {
        "id": "icosahedron",
        "dimensions": 3,
        "vertices": 12,
        "energy_cost": 1.6,
        "formula": "icosahedral(center, radius, orientation)",
        "color": Color(0.7, 1.0, 0.7)
    },
    "tesseract": {
        "id": "tesseract",
        "dimensions": 4,
        "vertices": 16,
        "energy_cost": 2.0,
        "formula": "quadrilinear(corners, u, v, w, x)",
        "color": Color(1.0, 0.3, 0.3)
    },
    "hypersphere": {
        "id": "hypersphere",
        "dimensions": 4,
        "vertices": 0,
        "energy_cost": 2.5,
        "formula": "hyperspherical(center, radius)",
        "color": Color(0.3, 0.3, 1.0)
    }
}

# Perspective types
const PERSPECTIVE_TYPES = {
    "orthographic": {
        "id": "orthographic",
        "dimensions": 3,
        "energy_cost": 1.0,
        "formula": "p.x * right + p.y * up + p.z * forward + origin",
        "color": Color(0.8, 0.8, 0.8)
    },
    "perspective": {
        "id": "perspective",
        "dimensions": 3,
        "energy_cost": 1.5,
        "formula": "origin + dir * t",
        "color": Color(0.9, 0.7, 0.5)
    },
    "isometric": {
        "id": "isometric",
        "dimensions": 3,
        "energy_cost": 1.2,
        "formula": "transform * Vector3(x, y, z)",
        "color": Color(0.6, 0.8, 0.9)
    },
    "spherical": {
        "id": "spherical",
        "dimensions": 3,
        "energy_cost": 2.0,
        "formula": "r * Vector3(sin(phi)*cos(theta), sin(phi)*sin(theta), cos(phi))",
        "color": Color(0.7, 0.5, 0.9)
    },
    "cylindrical": {
        "id": "cylindrical",
        "dimensions": 3,
        "energy_cost": 1.8,
        "formula": "Vector3(r * cos(theta), z, r * sin(theta))",
        "color": Color(0.5, 0.9, 0.7)
    },
    "stereographic": {
        "id": "stereographic",
        "dimensions": 4,
        "energy_cost": 2.5,
        "formula": "stereographic_projection(x, y, z, w)",
        "color": Color(0.9, 0.5, 0.5)
    },
    "hyperboloid": {
        "id": "hyperboloid",
        "dimensions": 4,
        "energy_cost": 3.0,
        "formula": "hyperboloid_projection(x, y, z, w)",
        "color": Color(0.5, 0.5, 0.9)
    }
}

# Cloud shapes
var active_clouds = {}
var cloud_meshes = {}
var cloud_materials = {}
var cloud_noise_textures = {}

# Projections
var active_projections = {}
var projection_transforms = {}

# Shape systems
var active_shapes = {}
var shape_vertices = {}
var shape_meshes = {}

# Noise generators
var noise_generators = {}
var combined_noise = {}

# Dimensional merges
var dimension_bridges = {}
var perspective_shifts = {}

# Component references
var tunnel_controller
var ethereal_tunnel_manager
var akashic_record_connector
var fractal_time_dimension

# Mesh generation
var visualization_parent
var cloud_container

# Statistics
var total_clouds = 0
var total_shapes = 0
var total_dimensions = 0
var total_size_bytes = 0
var total_vertices = 0
var total_projections = 0
var total_transformations = 0
var sequence_numbers = []

func _ready():
    # Create sequence numbers from user input
    _generate_sequence_numbers()
    
    # Initialize noise generators
    _initialize_noise_generators()
    
    # Set up cloud container
    cloud_container = Node3D.new()
    cloud_container.name = "CloudContainer"
    add_child(cloud_container)
    
    # Auto detect components
    _detect_components()

func _detect_components():
    # Find tunnel controller
    if not tunnel_controller:
        var potential_controllers = get_tree().get_nodes_in_group("tunnel_controllers")
        if potential_controllers.size() > 0:
            tunnel_controller = potential_controllers[0]
            print("Found tunnel controller: " + tunnel_controller.name)
            ethereal_tunnel_manager = tunnel_controller.ethereal_tunnel_manager
    
    # Find akashic record connector
    if not akashic_record_connector:
        var potential_connectors = get_tree().get_nodes_in_group("akashic_record_connectors")
        if potential_connectors.size() > 0:
            akashic_record_connector = potential_connectors[0]
    
    # Find fractal time dimension
    if not fractal_time_dimension:
        var potential_time_systems = get_tree().get_nodes_in_group("fractal_time_dimensions")
        if potential_time_systems.size() > 0:
            fractal_time_dimension = potential_time_systems[0]

func _generate_sequence_numbers():
    # Extract numbers from the user's input sequence
    var raw_numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
                     0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 21, 13, 14, 15, 16, 17, 18, 
                     91, 123, 1431, 124, 213, 123, 123, 213, 1423, 414, 135, 2, 525, 346, 
                     63, 2139012, 398, 932901, 328093193089]
    
    # Generate special Fibonacci sequence numbers
    var fib_seq = _generate_fibonacci(20)
    
    # Generate prime numbers
    var prime_seq = _generate_primes(20)
    
    # Combine all sequences
    sequence_numbers = []
    sequence_numbers.append_array(raw_numbers)
    sequence_numbers.append_array(fib_seq)
    sequence_numbers.append_array(prime_seq)
    
    # Set total size estimate
    total_size_bytes = sequence_numbers.reduce(func(accum, num): return accum + num, 0)
    
    print("Total merged size in bytes: " + str(total_size_bytes))
    print("Total merged size formatted: " + _format_size(total_size_bytes))

func _generate_fibonacci(count):
    var sequence = [1, 1]
    for i in range(2, count):
        sequence.push_back(sequence[i-1] + sequence[i-2])
    return sequence

func _generate_primes(count):
    var primes = [2]
    var num = 3
    
    while primes.size() < count:
        var is_prime = true
        for i in range(2, int(sqrt(num)) + 1):
            if num % i == 0:
                is_prime = false
                break
        
        if is_prime:
            primes.push_back(num)
        
        num += 2  # Check only odd numbers
    
    return primes

func _format_size(bytes):
    if bytes < 1024:
        return str(bytes) + " B"
    elif bytes < 1024 * 1024:
        return str(float(bytes) / 1024.0).substr(0, 5) + " KB"
    elif bytes < 1024 * 1024 * 1024:
        return str(float(bytes) / (1024.0 * 1024.0)).substr(0, 5) + " MB"
    else:
        return str(float(bytes) / (1024.0 * 1024.0 * 1024.0)).substr(0, 5) + " GB"

func _initialize_noise_generators():
    for noise_type in NOISE_TYPES:
        var noise = FastNoiseLite.new()
        
        match noise_type:
            "simplex":
                noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
            "perlin":
                noise.noise_type = FastNoiseLite.TYPE_PERLIN
            "value":
                noise.noise_type = FastNoiseLite.TYPE_VALUE
            "worley":
                noise.noise_type = FastNoiseLite.TYPE_CELLULAR
            "fractal":
                noise.noise_type = FastNoiseLite.TYPE_PERLIN
                noise.fractal_type = FastNoiseLite.FRACTAL_FBM
                noise.fractal_octaves = 5
            "turbulence":
                noise.noise_type = FastNoiseLite.TYPE_PERLIN
                noise.fractal_type = FastNoiseLite.FRACTAL_RIDGED_MULTI
                noise.fractal_octaves = 4
            "ridged":
                noise.noise_type = FastNoiseLite.TYPE_PERLIN
                noise.fractal_type = FastNoiseLite.FRACTAL_RIDGED_MULTI
                noise.fractal_octaves = 3
            _:
                noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
        
        # Add some variation based on sequence numbers
        var seed_value = sequence_numbers[randi() % sequence_numbers.size()] % 100000
        noise.seed = seed_value
        
        # Store noise generator
        noise_generators[noise_type] = noise

func generate_cloud_shape(shape_type = "cube", noise_type = "perlin", dimension = 3, size = 1.0, complexity = 1.0):
    if not SHAPE_TYPES.has(shape_type) or not NOISE_TYPES.has(noise_type):
        return null
    
    # Generate unique cloud ID
    var cloud_id = "cloud_" + shape_type + "_" + noise_type + "_" + str(randi() % 10000)
    
    # Calculate vertices based on shape
    var vertices = _generate_shape_vertices(shape_type, size, dimension)
    
    # Generate cloud data
    var cloud = {
        "id": cloud_id,
        "shape_type": shape_type,
        "noise_type": noise_type,
        "dimension": dimension,
        "size": size,
        "complexity": complexity,
        "vertices": vertices.size(),
        "creation_time": Time.get_unix_time_from_system(),
        "modified_time": Time.get_unix_time_from_system()
    }
    
    # Store cloud
    active_clouds[cloud_id] = cloud
    shape_vertices[cloud_id] = vertices
    
    # Generate mesh
    var mesh = _generate_cloud_mesh(cloud_id, vertices, noise_type, complexity)
    cloud_meshes[cloud_id] = mesh
    
    # Create material
    var material = _create_cloud_material(noise_type, shape_type)
    cloud_materials[cloud_id] = material
    
    # Apply material to mesh
    if cloud_container:
        var mesh_instance = MeshInstance3D.new()
        mesh_instance.name = cloud_id
        mesh_instance.mesh = mesh
        mesh_instance.material_override = material
        
        # Position based on sequence numbers
        var x = (sequence_numbers[0] % 10) - 5.0
        var y = (sequence_numbers[1] % 10) - 5.0
        var z = (sequence_numbers[2] % 10) - 5.0
        mesh_instance.position = Vector3(x, y, z)
        
        cloud_container.add_child(mesh_instance)
    
    # Update statistics
    total_clouds += 1
    total_vertices += vertices.size()
    total_dimensions = max(total_dimensions, dimension)
    
    # Record to Akashic records if available
    if akashic_record_connector:
        var cloud_data = {
            "cloud_id": cloud_id,
            "shape_type": shape_type,
            "noise_type": noise_type,
            "dimension": dimension,
            "vertices": vertices.size()
        }
        
        akashic_record_connector.record_dimensional_data(dimension, cloud_data, "cloud_shape")
    
    # Emit signal
    emit_signal("shape_generated", cloud_id, dimension, complexity)
    
    return cloud_id

func _generate_shape_vertices(shape_type, size, dimension):
    var vertices = []
    
    match shape_type:
        "point":
            vertices.push_back(Vector3(0, 0, 0))
        
        "line":
            vertices.push_back(Vector3(-size/2, 0, 0))
            vertices.push_back(Vector3(size/2, 0, 0))
        
        "triangle":
            var h = size * sqrt(3) / 2
            vertices.push_back(Vector3(0, h/2, 0))
            vertices.push_back(Vector3(-size/2, -h/2, 0))
            vertices.push_back(Vector3(size/2, -h/2, 0))
        
        "square":
            vertices.push_back(Vector3(-size/2, -size/2, 0))
            vertices.push_back(Vector3(size/2, -size/2, 0))
            vertices.push_back(Vector3(size/2, size/2, 0))
            vertices.push_back(Vector3(-size/2, size/2, 0))
        
        "cube":
            for i in range(8):
                var x = (i & 1) * size - size/2
                var y = ((i >> 1) & 1) * size - size/2
                var z = ((i >> 2) & 1) * size - size/2
                vertices.push_back(Vector3(x, y, z))
        
        "tetrahedron":
            vertices.push_back(Vector3(0, size, 0))
            vertices.push_back(Vector3(-size, -size, -size))
            vertices.push_back(Vector3(size, -size, -size))
            vertices.push_back(Vector3(0, -size, size))
        
        "octahedron":
            vertices.push_back(Vector3(size, 0, 0))
            vertices.push_back(Vector3(-size, 0, 0))
            vertices.push_back(Vector3(0, size, 0))
            vertices.push_back(Vector3(0, -size, 0))
            vertices.push_back(Vector3(0, 0, size))
            vertices.push_back(Vector3(0, 0, -size))
        
        "icosahedron":
            var phi = (1.0 + sqrt(5.0)) / 2.0
            var a = size
            var b = size * phi
            
            # 12 vertices of icosahedron
            vertices.push_back(Vector3(0, a, b))
            vertices.push_back(Vector3(0, a, -b))
            vertices.push_back(Vector3(0, -a, b))
            vertices.push_back(Vector3(0, -a, -b))
            
            vertices.push_back(Vector3(a, b, 0))
            vertices.push_back(Vector3(a, -b, 0))
            vertices.push_back(Vector3(-a, b, 0))
            vertices.push_back(Vector3(-a, -b, 0))
            
            vertices.push_back(Vector3(b, 0, a))
            vertices.push_back(Vector3(b, 0, -a))
            vertices.push_back(Vector3(-b, 0, a))
            vertices.push_back(Vector3(-b, 0, -a))
        
        _:
            # Default to cube for unknown shapes
            for i in range(8):
                var x = (i & 1) * size - size/2
                var y = ((i >> 1) & 1) * size - size/2
                var z = ((i >> 2) & 1) * size - size/2
                vertices.push_back(Vector3(x, y, z))
    
    # Scale based on dimension (higher dimensions get smaller in 3D space)
    var scale_factor = 1.0 / pow(dimension, 0.3)
    for i in range(vertices.size()):
        vertices[i] *= scale_factor
    
    # Add extra vertices based on complexity
    var complexity_count = int(SHAPE_TYPES[shape_type].vertices * 3)
    for i in range(complexity_count):
        var idx1 = randi() % vertices.size()
        var idx2 = randi() % vertices.size()
        
        if idx1 != idx2:
            # Create interpolated vertex
            var t = randf()
            var new_vertex = vertices[idx1].lerp(vertices[idx2], t)
            vertices.push_back(new_vertex)
    
    return vertices

func _generate_cloud_mesh(cloud_id, vertices, noise_type, complexity):
    # Create a new mesh for the cloud
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    var noise = noise_generators[noise_type]
    
    # For points, create small spheres
    if vertices.size() == 1:
        _add_sphere_to_surface_tool(st, vertices[0], 0.1, 8, noise, complexity)
        
    # For lines, create cylinders
    elif vertices.size() == 2:
        _add_cylinder_to_surface_tool(st, vertices[0], vertices[1], 0.05, 8, noise, complexity)
        
    # For triangles and other polygons
    elif vertices.size() >= 3:
        # Create triangles from vertices
        for i in range(vertices.size()):
            for j in range(i+1, vertices.size()):
                for k in range(j+1, vertices.size()):
                    # Calculate triangle normal
                    var edge1 = vertices[j] - vertices[i]
                    var edge2 = vertices[k] - vertices[i]
                    var normal = edge1.cross(edge2).normalized()
                    
                    # Skip degenerate triangles
                    if normal.length_squared() < 0.001:
                        continue
                    
                    # Apply noise to vertices
                    var v1 = _apply_noise_to_vertex(vertices[i], noise, complexity)
                    var v2 = _apply_noise_to_vertex(vertices[j], noise, complexity)
                    var v3 = _apply_noise_to_vertex(vertices[k], noise, complexity)
                    
                    # Add triangle
                    st.set_normal(normal)
                    st.add_vertex(v1)
                    st.add_vertex(v2)
                    st.add_vertex(v3)
        
        # For 3D shapes, add internal vertices to create volume
        if SHAPE_TYPES[active_clouds[cloud_id].shape_type].dimensions >= 3:
            var center = Vector3.ZERO
            for v in vertices:
                center += v
            center /= vertices.size()
            
            for i in range(vertices.size()):
                var v1 = _apply_noise_to_vertex(vertices[i], noise, complexity)
                var v2 = _apply_noise_to_vertex(vertices[(i+1) % vertices.size()], noise, complexity)
                var v3 = _apply_noise_to_vertex(center, noise, complexity)
                
                var normal = (v1 - center).cross(v2 - center).normalized()
                
                st.set_normal(normal)
                st.add_vertex(v1)
                st.add_vertex(v2)
                st.add_vertex(v3)
    
    # Generate mesh
    st.index()
    var mesh = st.commit()
    
    # Store mesh
    shape_meshes[cloud_id] = mesh
    
    # Generate noise texture for the material
    var noise_texture = _generate_noise_texture(noise_type, complexity)
    cloud_noise_textures[cloud_id] = noise_texture
    
    return mesh

func _add_sphere_to_surface_tool(st, center, radius, segments, noise, complexity):
    # Create a sphere for point clouds
    var rings = segments
    var sectors = segments * 2
    
    for i in range(rings + 1):
        var lat = PI * (-0.5 + float(i) / rings)
        var y = sin(lat)
        var r = cos(lat)
        
        for j in range(sectors + 1):
            var lon = 2 * PI * float(j) / sectors
            var x = r * sin(lon)
            var z = r * cos(lon)
            
            var point = Vector3(x, y, z) * radius + center
            var noisy_point = _apply_noise_to_vertex(point, noise, complexity)
            
            var normal = (noisy_point - center).normalized()
            st.set_normal(normal)
            st.add_vertex(noisy_point)
            
            if i < rings and j < sectors:
                var current = i * (sectors + 1) + j
                var next = current + (sectors + 1)
                
                st.add_index(current)
                st.add_index(next)
                st.add_index(current + 1)
                
                st.add_index(current + 1)
                st.add_index(next)
                st.add_index(next + 1)

func _add_cylinder_to_surface_tool(st, start, end, radius, segments, noise, complexity):
    # Create a cylinder for line clouds
    var direction = (end - start).normalized()
    var length = (end - start).length()
    
    # Create basis with direction as one axis
    var up = Vector3(0, 1, 0)
    if abs(direction.dot(up)) > 0.9:
        up = Vector3(1, 0, 0)
    
    var side = direction.cross(up).normalized()
    up = side.cross(direction).normalized()
    
    for i in range(segments + 1):
        var angle = 2 * PI * float(i) / segments
        var x = cos(angle)
        var y = sin(angle)
        
        # Create two circles at start and end points
        var circle_point_start = start + (side * x + up * y) * radius
        var circle_point_end = end + (side * x + up * y) * radius
        
        var noisy_start = _apply_noise_to_vertex(circle_point_start, noise, complexity)
        var noisy_end = _apply_noise_to_vertex(circle_point_end, noise, complexity)
        
        var normal_start = (noisy_start - start).normalized()
        var normal_end = (noisy_end - end).normalized()
        
        st.set_normal(normal_start)
        st.add_vertex(noisy_start)
        
        st.set_normal(normal_end)
        st.add_vertex(noisy_end)
        
        if i < segments:
            var current = i * 2
            var next = current + 2
            
            # Add two triangles for the cylinder side
            st.add_index(current)
            st.add_index(current + 1)
            st.add_index(next)
            
            st.add_index(next)
            st.add_index(current + 1)
            st.add_index(next + 1)

func _apply_noise_to_vertex(vertex, noise, complexity):
    var noise_scale = 0.1 + complexity * 0.9  # 0.1 to 1.0
    var time_offset = OS.get_ticks_msec() / 10000.0  # Slowly changing time
    
    var noise_value = noise.get_noise_3d(
        vertex.x * 5.0, 
        vertex.y * 5.0, 
        vertex.z * 5.0 + time_offset
    ) * noise_scale
    
    var noise_dir = Vector3(
        noise.get_noise_3d(vertex.x * 3.1, vertex.y * 7.3, vertex.z * 9.2 + time_offset),
        noise.get_noise_3d(vertex.x * 6.7, vertex.y * 4.3, vertex.z * 2.9 + time_offset),
        noise.get_noise_3d(vertex.x * 8.3, vertex.y * 2.7, vertex.z * 5.1 + time_offset)
    ).normalized()
    
    var distance = noise_value * 0.5  # Scale the displacement
    
    return vertex + noise_dir * distance

func _create_cloud_material(noise_type, shape_type):
    var material = StandardMaterial3D.new()
    
    # Set basic properties
    material.flags_transparent = true
    material.albedo_color = NOISE_TYPES[noise_type].color
    material.albedo_color.a = 0.7  # Make it slightly transparent
    
    # Enable emission
    material.emission_enabled = true
    material.emission = NOISE_TYPES[noise_type].color
    material.emission_energy = 0.5
    
    # Set metallic and roughness
    material.metallic = 0.3
    material.roughness = 0.7
    
    # Add some rim lighting
    material.rim_enabled = true
    material.rim = 0.3
    material.rim_tint = 0.5
    
    # Add some color from the shape type
    var shape_color = SHAPE_TYPES[shape_type].color
    material.albedo_color = material.albedo_color.lerp(shape_color, 0.3)
    
    return material

func _generate_noise_texture(noise_type, complexity):
    var noise = noise_generators[noise_type]
    
    # Create noise texture
    var texture_size = int(64 + complexity * 64)  # 64 to 128
    var img = Image.create(texture_size, texture_size, false, Image.FORMAT_RGBA8)
    
    for x in range(texture_size):
        for y in range(texture_size):
            var nx = float(x) / texture_size
            var ny = float(y) / texture_size
            
            var noise_value = noise.get_noise_2d(nx * 10, ny * 10)
            noise_value = (noise_value + 1.0) / 2.0  # Convert from -1...1 to 0...1
            
            var color = NOISE_TYPES[noise_type].color
            color.a = noise_value  # Alpha from noise
            
            img.set_pixel(x, y, color)
    
    var texture = ImageTexture.create_from_image(img)
    return texture

func create_perspective_projection(source_dimension, target_dimension, perspective_type = "perspective"):
    if not PERSPECTIVE_TYPES.has(perspective_type):
        return null
    
    # Generate unique projection ID
    var projection_id = "projection_" + str(source_dimension) + "_to_" + str(target_dimension) + "_" + perspective_type
    
    # Create projection data
    var projection = {
        "id": projection_id,
        "source_dimension": source_dimension,
        "target_dimension": target_dimension,
        "perspective_type": perspective_type,
        "creation_time": Time.get_unix_time_from_system(),
        "transform": Transform3D.IDENTITY
    }
    
    # Calculate projection matrix based on type
    var transform = Transform3D.IDENTITY
    
    match perspective_type:
        "orthographic":
            transform = Transform3D.IDENTITY
        
        "perspective":
            # Set up perspective projection
            var fov = 75.0
            var aspect = 1.0
            var z_near = 0.05
            var z_far = 100.0
            
            # This is a simplified perspective matrix
            transform.basis = Basis(Vector3(1, 0, 0), Vector3(0, 1, 0), Vector3(0, 0, 1))
            transform.origin = Vector3(0, 0, -5)  # Move back to see projection
        
        "isometric":
            # Set up isometric view
            var rot_x = PI / 4.0  # 45 degrees
            var rot_y = PI / 4.0  # 45 degrees
            
            transform = Transform3D(Basis(Quaternion(Vector3(1, 0, 0), rot_x) * Quaternion(Vector3(0, 1, 0), rot_y)))
            transform.origin = Vector3(0, 0, -5)
        
        "spherical":
            # Set up spherical projection
            var radius = 5.0
            var height = 2.0
            
            transform.origin = Vector3(0, height, -radius)
            transform = transform.looking_at(Vector3(0, 0, 0), Vector3.UP)
    
    # Store projection
    projection_transforms[projection_id] = transform
    active_projections[projection_id] = projection
    
    # Update statistics
    total_projections += 1
    
    # Record to Akashic records if available
    if akashic_record_connector:
        var projection_data = {
            "projection_id": projection_id,
            "source_dimension": source_dimension,
            "target_dimension": target_dimension,
            "perspective_type": perspective_type
        }
        
        akashic_record_connector.record_dimensional_data(
            max(source_dimension, target_dimension), 
            projection_data, 
            "dimensional_projection"
        )
    
    # Emit signal
    emit_signal("dimensional_projection_created", projection_id, source_dimension, target_dimension)
    
    return projection_id

func apply_projection_to_clouds(projection_id, cloud_ids = []):
    if not active_projections.has(projection_id):
        return false
    
    var projection = active_projections[projection_id]
    var transform = projection_transforms[projection_id]
    
    # If no specific clouds provided, apply to all clouds
    if cloud_ids.empty():
        cloud_ids = active_clouds.keys()
    
    # Apply projection to each cloud
    for cloud_id in cloud_ids:
        if not cloud_meshes.has(cloud_id) or not active_clouds.has(cloud_id):
            continue
        
        var cloud = active_clouds[cloud_id]
        
        # Only apply if dimensions match
        if cloud.dimension == projection.source_dimension:
            # Get mesh instance in the scene
            var mesh_instance = cloud_container.get_node_or_null(cloud_id)
            
            if mesh_instance:
                mesh_instance.transform = transform
            
            # Update cloud data
            cloud.transform = transform
            cloud.projected = true
            cloud.projection_id = projection_id
            
            # Update statistics
            total_transformations += 1
    
    return true

func combine_clouds(cloud_ids, merge_type = "union"):
    if cloud_ids.size() < 2:
        return null
    
    # Generate unique combined ID
    var combined_id = "combined_" + str(randi() % 10000)
    
    # Calculate combined dimension and properties
    var max_dimension = 0
    var total_vertices = 0
    var noise_types = []
    var shape_types = []
    
    for cloud_id in cloud_ids:
        if active_clouds.has(cloud_id):
            var cloud = active_clouds[cloud_id]
            max_dimension = max(max_dimension, cloud.dimension)
            total_vertices += cloud.vertices
            noise_types.push_back(cloud.noise_type)
            shape_types.push_back(cloud.shape_type)
    
    # Create combined cloud data
    var combined_cloud = {
        "id": combined_id,
        "merged_from": cloud_ids,
        "dimension": max_dimension,
        "vertices": total_vertices,
        "noise_types": noise_types,
        "shape_types": shape_types,
        "merge_type": merge_type,
        "creation_time": Time.get_unix_time_from_system()
    }
    
    # Create combined mesh
    var combined_mesh = _combine_cloud_meshes(cloud_ids, merge_type)
    
    if not combined_mesh:
        return null
    
    # Store combined cloud
    active_clouds[combined_id] = combined_cloud
    cloud_meshes[combined_id] = combined_mesh
    
    # Create material that combines properties
    var material = _create_combined_material(cloud_ids)
    cloud_materials[combined_id] = material
    
    # Add to scene
    if cloud_container:
        var mesh_instance = MeshInstance3D.new()
        mesh_instance.name = combined_id
        mesh_instance.mesh = combined_mesh
        mesh_instance.material_override = material
        
        # Position in center of component clouds
        var center = Vector3.ZERO
        var count = 0
        
        for cloud_id in cloud_ids:
            var cloud_node = cloud_container.get_node_or_null(cloud_id)
            if cloud_node:
                center += cloud_node.position
                count += 1
        
        if count > 0:
            center /= count
        
        mesh_instance.position = center
        cloud_container.add_child(mesh_instance)
    
    # Update statistics
    total_clouds += 1
    
    # Record to Akashic records if available
    if akashic_record_connector:
        var merge_data = {
            "combined_id": combined_id,
            "source_clouds": cloud_ids,
            "merge_type": merge_type,
            "dimension": max_dimension
        }
        
        akashic_record_connector.record_dimensional_data(max_dimension, merge_data, "cloud_merge")
    
    # Emit signal
    emit_signal("cloud_merged", cloud_ids[0], cloud_ids[1], combined_id)
    
    return combined_id

func _combine_cloud_meshes(cloud_ids, merge_type):
    # Create CSG nodes for Boolean operations
    var csg_combined
    
    match merge_type:
        "union":
            csg_combined = CSGCombiner3D.new()
            csg_combined.operation = CSGCombiner3D.OPERATION_UNION
        
        "intersection":
            csg_combined = CSGCombiner3D.new()
            csg_combined.operation = CSGCombiner3D.OPERATION_INTERSECTION
        
        "subtraction":
            csg_combined = CSGCombiner3D.new()
            csg_combined.operation = CSGCombiner3D.OPERATION_SUBTRACTION
        
        _:
            csg_combined = CSGCombiner3D.new()
            csg_combined.operation = CSGCombiner3D.OPERATION_UNION
    
    # Add each cloud mesh as a CSG mesh
    var first = true
    for cloud_id in cloud_ids:
        if cloud_meshes.has(cloud_id):
            var csg_mesh = CSGMesh3D.new()
            csg_mesh.mesh = cloud_meshes[cloud_id]
            
            if first and merge_type == "subtraction":
                # First object is the one to subtract from
                csg_mesh.operation = CSGShape3D.OPERATION_UNION
                first = false
            elif merge_type == "subtraction":
                csg_mesh.operation = CSGShape3D.OPERATION_SUBTRACTION
            else:
                csg_mesh.operation = CSGShape3D.OPERATION_UNION
            
            csg_combined.add_child(csg_mesh)
    
    # Add to scene temporarily to perform CSG operation
    add_child(csg_combined)
    
    # Wait for a frame to let CSG process
    await get_tree().process_frame
    
    # Create mesh from CSG result
    var resulting_mesh = csg_combined.get_meshes()[1]
    
    # Clean up
    csg_combined.queue_free()
    
    return resulting_mesh

func _create_combined_material(cloud_ids):
    var material = StandardMaterial3D.new()
    
    # Average properties from component clouds
    var color = Color(0, 0, 0, 0)
    var emission = Color(0, 0, 0)
    var emission_energy = 0.0
    var count = 0
    
    for cloud_id in cloud_ids:
        if cloud_materials.has(cloud_id):
            var mat = cloud_materials[cloud_id]
            color += mat.albedo_color
            emission += mat.emission
            emission_energy += mat.emission_energy
            count += 1
    
    if count > 0:
        color /= count
        emission /= count
        emission_energy /= count
    else:
        color = Color(1, 1, 1, 0.7)
        emission = Color(1, 1, 1)
        emission_energy = 0.5
    
    # Set material properties
    material.flags_transparent = true
    material.albedo_color = color
    material.emission_enabled = true
    material.emission = emission
    material.emission_energy = emission_energy
    
    # Add some fancy effects for combined materials
    material.rim_enabled = true
    material.rim = 0.5
    material.rim_tint = 0.7
    
    return material

func transform_noise(cloud_id, new_noise_type):
    if not active_clouds.has(cloud_id) or not NOISE_TYPES.has(new_noise_type):
        return false
    
    var cloud = active_clouds[cloud_id]
    var old_noise_type = cloud.noise_type
    
    # Skip if already using this noise type
    if old_noise_type == new_noise_type:
        return true
    
    # Update cloud data
    cloud.noise_type = new_noise_type
    cloud.modified_time = Time.get_unix_time_from_system()
    
    # Create new material with the new noise type
    var material = _create_cloud_material(new_noise_type, cloud.shape_type)
    cloud_materials[cloud_id] = material
    
    # Apply to mesh instance
    if cloud_container:
        var mesh_instance = cloud_container.get_node_or_null(cloud_id)
        if mesh_instance:
            mesh_instance.material_override = material
    
    # Record to Akashic records if available
    if akashic_record_connector:
        var transform_data = {
            "cloud_id": cloud_id,
            "old_noise_type": old_noise_type,
            "new_noise_type": new_noise_type
        }
        
        akashic_record_connector.record_dimensional_data(cloud.dimension, transform_data, "noise_transform")
    
    # Emit signal
    emit_signal("noise_transformed", cloud_id, old_noise_type, new_noise_type)
    
    return true

func shift_perspective(perspective_id, shift_amount = 0.1):
    if not active_projections.has(perspective_id):
        return false
    
    var projection = active_projections[perspective_id]
    var transform = projection_transforms[perspective_id]
    
    var old_perspective = projection.perspective_type
    
    # Calculate new perspective based on shift
    var perspectives = PERSPECTIVE_TYPES.keys()
    perspectives.sort()
    
    var current_index = perspectives.find(old_perspective)
    if current_index < 0:
        return false
    
    var new_index = current_index
    if shift_amount > 0:
        new_index = min(current_index + 1, perspectives.size() - 1)
    elif shift_amount < 0:
        new_index = max(current_index - 1, 0)
    
    var new_perspective = perspectives[new_index]
    
    # Skip if already using this perspective
    if old_perspective == new_perspective:
        return true
    
    # Update projection data
    projection.perspective_type = new_perspective
    
    # Create new transform
    var new_transform
    
    match new_perspective:
        "orthographic":
            new_transform = Transform3D.IDENTITY
        
        "perspective":
            # Set up perspective projection
            new_transform = transform
            new_transform.origin = Vector3(0, 0, -5)
        
        "isometric":
            # Set up isometric view
            var rot_x = PI / 4.0
            var rot_y = PI / 4.0
            
            new_transform = Transform3D(Basis(Quaternion(Vector3(1, 0, 0), rot_x) * 
                                    Quaternion(Vector3(0, 1, 0), rot_y)))
            new_transform.origin = Vector3(0, 0, -5)
        
        "spherical":
            # Set up spherical projection
            var radius = 5.0
            var height = 2.0
            
            new_transform = Transform3D.IDENTITY
            new_transform.origin = Vector3(0, height, -radius)
            new_transform = new_transform.looking_at(Vector3(0, 0, 0), Vector3.UP)
    
    # Store new transform
    projection_transforms[perspective_id] = new_transform
    
    # Apply new projection to affected clouds
    for cloud_id in active_clouds:
        var cloud = active_clouds[cloud_id]
        if cloud.has("projection_id") and cloud.projection_id == perspective_id:
            # Update cloud instance
            var mesh_instance = cloud_container.get_node_or_null(cloud_id)
            if mesh_instance:
                mesh_instance.transform = new_transform
    
    # Record to Akashic records if available
    if akashic_record_connector:
        var shift_data = {
            "projection_id": perspective_id,
            "old_perspective": old_perspective,
            "new_perspective": new_perspective
        }
        
        akashic_record_connector.record_dimensional_data(
            max(projection.source_dimension, projection.target_dimension), 
            shift_data, 
            "perspective_shift"
        )
    
    # Emit signal
    emit_signal("perspective_shifted", old_perspective, new_perspective)
    
    return true

func generate_shape_from_numbers(sequence_indices = [], shape_type = "cube"):
    if sequence_indices.empty() or sequence_indices.size() < 3:
        # Use first few numbers from sequence
        sequence_indices = [0, 1, 2, 3, 4, 5, 6, 7]
    
    # Filter indices to valid range
    var valid_indices = []
    for idx in sequence_indices:
        if idx >= 0 and idx < sequence_numbers.size():
            valid_indices.push_back(idx)
    
    if valid_indices.size() < 3:
        return null
    
    # Extract numbers for shape generation
    var numbers = []
    for idx in valid_indices:
        numbers.push_back(sequence_numbers[idx])
    
    # Generate unique shape ID
    var shape_id = "number_shape_" + str(randi() % 10000)
    
    # Calculate dimension based on numbers
    var dimension_sum = 0
    for num in numbers:
        dimension_sum += num
    
    var dimension = (dimension_sum % 5) + 1  # 1 to 5
    
    # Calculate complexity from variance of numbers
    var mean = 0.0
    for num in numbers:
        mean += num
    mean /= numbers.size()
    
    var variance = 0.0
    for num in numbers:
        variance += pow(num - mean, 2)
    variance /= numbers.size()
    
    var complexity = clamp(sqrt(variance) / 100.0, 0.1, 1.0)
    
    # Use the numbers to seed a noise type
    var noise_types = NOISE_TYPES.keys()
    var noise_type = noise_types[numbers[0] % noise_types.size()]
    
    # Generate the cloud shape
    return generate_cloud_shape(shape_type, noise_type, dimension, 1.0, complexity)

func get_total_stats():
    return {
        "clouds": total_clouds,
        "shapes": total_shapes,
        "dimensions": total_dimensions,
        "vertices": total_vertices,
        "projections": total_projections,
        "transformations": total_transformations,
        "size_bytes": total_size_bytes,
        "size_formatted": _format_size(total_size_bytes),
        "sequence_numbers_count": sequence_numbers.size()
    }

func get_cloud_info(cloud_id):
    if not active_clouds.has(cloud_id):
        return null
    
    return active_clouds[cloud_id]

func get_active_clouds():
    return active_clouds.keys()

func get_projection_info(projection_id):
    if not active_projections.has(projection_id):
        return null
    
    return active_projections[projection_id]

func get_active_projections():
    return active_projections.keys()

func get_sequence_numbers():
    return sequence_numbers