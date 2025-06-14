extends Spatial
class_name HexGridVisualizer

# ------------------------------------
# HexGridVisualizer - Hexagonal grid system for word data visualization
# Supports flat maps, infinite scrolling, and spherical transformations
# ------------------------------------

# Grid constants
const HEX_SIZE = 1.0
const HEX_HEIGHT = 0.2
const HEX_SPACING = 0.05
const GRID_FLAT_SIZE = 16
const SCROLL_SPEED = 5.0
const ROTATION_SPEED = 0.5
const ZOOM_SPEED = 2.0

# HEX GRID MATH
const SQRT3 = 1.73205080757 # sqrt(3)
const HEX_CORNER_ANGLES = [0, 60, 120, 180, 240, 300] # in degrees

# Visualization modes
enum GridMode {
    FLAT,           # Traditional flat hex grid
    SPHERE,         # Wrapped onto a sphere 
    INFINITE,       # Infinitely scrolling grid
    CYLINDER,       # Wrapped onto a cylinder
    TORUS           # Wrapped onto a torus
}

# Current grid state
var current_mode = GridMode.FLAT
var grid_cells = {}  # Dictionary of Vector3 -> HexCell
var focused_cell = null
var selected_cell = null
var grid_center = Vector3.ZERO
var grid_rotation = 0.0
var grid_scale = 1.0
var scroll_position = Vector2.ZERO

# Data references
var word_cells = {} # Dictionary mapping word_id -> cell_coordinate
var word_drive = null

# Node references
var hex_cell_scene = null
var camera = null
var cell_material = null
var highlight_material = null
var selected_material = null

# Signal declarations
signal cell_selected(cell_coord, cell_data)
signal cell_focused(cell_coord, cell_data)
signal view_changed(mode, position, rotation, scale)
signal data_updated(cell_coord, data)

# Initialize the visualizer
func _ready():
    # Create materials
    _create_materials()
    
    # Setup cell template
    _create_hex_cell_template()
    
    # Create initial grid
    generate_flat_grid(GRID_FLAT_SIZE)
    
    # Set up camera
    setup_camera()

# Process input and animation
func _process(delta):
    # Process animation based on current mode
    match current_mode:
        GridMode.SPHERE:
            _process_sphere_rotation(delta)
        GridMode.INFINITE:
            _process_infinite_scroll(delta)
        GridMode.CYLINDER, GridMode.TORUS:
            _process_cylindrical_rotation(delta)
    
    # Update grid scale animation (shared by all modes)
    _update_grid_scale(delta)

# Process user input
func _input(event):
    if event is InputEventKey:
        # Mode switching
        if event.pressed:
            if event.scancode == KEY_1:
                switch_to_mode(GridMode.FLAT)
            elif event.scancode == KEY_2:
                switch_to_mode(GridMode.SPHERE)
            elif event.scancode == KEY_3:
                switch_to_mode(GridMode.INFINITE)
            elif event.scancode == KEY_4:
                switch_to_mode(GridMode.CYLINDER)
            elif event.scancode == KEY_5:
                switch_to_mode(GridMode.TORUS)
    
    # Camera control
    elif event is InputEventMouseMotion:
        if event.button_mask & BUTTON_RIGHT:
            # Orbit camera or pan grid
            if current_mode == GridMode.FLAT or current_mode == GridMode.INFINITE:
                scroll_position -= event.relative * 0.01
                _update_infinite_grid_position()
            else:
                # Orbit camera for 3D modes
                _orbit_camera(event.relative)
    
    # Zoom control
    elif event is InputEventMouseButton:
        if event.button_index == BUTTON_WHEEL_UP:
            grid_scale = min(grid_scale + ZOOM_SPEED * 0.1, 3.0)
        elif event.button_index == BUTTON_WHEEL_DOWN:
            grid_scale = max(grid_scale - ZOOM_SPEED * 0.1, 0.5)
        
        # Cell selection
        elif event.button_index == BUTTON_LEFT and event.pressed:
            var cell_coord = _get_cell_at_mouse_position()
            if cell_coord and grid_cells.has(cell_coord):
                select_cell(cell_coord)

# Create hex cell template
func _create_hex_cell_template():
    hex_cell_scene = Spatial.new()
    hex_cell_scene.name = "HexCellTemplate"
    
    # Create hex mesh
    var hex_mesh = _create_hex_mesh()
    
    # Create mesh instance
    var mesh_instance = MeshInstance.new()
    mesh_instance.name = "HexMesh"
    mesh_instance.mesh = hex_mesh
    mesh_instance.material_override = cell_material
    hex_cell_scene.add_child(mesh_instance)
    
    # Create collision shape for interactions
    var collision = Area.new()
    collision.name = "ClickArea"
    var shape = CollisionShape.new()
    var cylinder_shape = CylinderShape.new()
    cylinder_shape.height = HEX_HEIGHT
    cylinder_shape.radius = HEX_SIZE * 0.866 # Approx radius of hex
    shape.shape = cylinder_shape
    collision.add_child(shape)
    hex_cell_scene.add_child(collision)
    
    # Create label for text
    var label = Label3D.new()
    label.name = "Label"
    label.text = ""
    label.billboard = SpatialMaterial.BILLBOARD_ENABLED
    label.pixel_size = 0.01
    label.translation.y = HEX_HEIGHT * 0.6
    hex_cell_scene.add_child(label)

# Create hex mesh
func _create_hex_mesh():
    var mesh = ArrayMesh.new()
    var st = SurfaceTool.new()
    
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    
    # Top face
    for i in range(6):
        var angle1 = deg2rad(HEX_CORNER_ANGLES[i])
        var angle2 = deg2rad(HEX_CORNER_ANGLES[(i+1) % 6])
        
        var p1 = Vector3(0, HEX_HEIGHT * 0.5, 0)
        var p2 = Vector3(HEX_SIZE * cos(angle1), HEX_HEIGHT * 0.5, HEX_SIZE * sin(angle1))
        var p3 = Vector3(HEX_SIZE * cos(angle2), HEX_HEIGHT * 0.5, HEX_SIZE * sin(angle2))
        
        st.add_normal(Vector3.UP)
        st.add_uv(Vector2(0.5, 0.5))
        st.add_vertex(p1)
        
        st.add_normal(Vector3.UP)
        st.add_uv(Vector2(0.5 + 0.5 * cos(angle1), 0.5 + 0.5 * sin(angle1)))
        st.add_vertex(p2)
        
        st.add_normal(Vector3.UP)
        st.add_uv(Vector2(0.5 + 0.5 * cos(angle2), 0.5 + 0.5 * sin(angle2)))
        st.add_vertex(p3)
    
    # Bottom face
    for i in range(6):
        var angle1 = deg2rad(HEX_CORNER_ANGLES[i])
        var angle2 = deg2rad(HEX_CORNER_ANGLES[(i+1) % 6])
        
        var p1 = Vector3(0, -HEX_HEIGHT * 0.5, 0)
        var p2 = Vector3(HEX_SIZE * cos(angle2), -HEX_HEIGHT * 0.5, HEX_SIZE * sin(angle2))
        var p3 = Vector3(HEX_SIZE * cos(angle1), -HEX_HEIGHT * 0.5, HEX_SIZE * sin(angle1))
        
        st.add_normal(Vector3.DOWN)
        st.add_uv(Vector2(0.5, 0.5))
        st.add_vertex(p1)
        
        st.add_normal(Vector3.DOWN)
        st.add_uv(Vector2(0.5 + 0.5 * cos(angle2), 0.5 + 0.5 * sin(angle2)))
        st.add_vertex(p2)
        
        st.add_normal(Vector3.DOWN)
        st.add_uv(Vector2(0.5 + 0.5 * cos(angle1), 0.5 + 0.5 * sin(angle1)))
        st.add_vertex(p3)
    }
    
    # Side faces
    for i in range(6):
        var angle1 = deg2rad(HEX_CORNER_ANGLES[i])
        var angle2 = deg2rad(HEX_CORNER_ANGLES[(i+1) % 6])
        
        var p1 = Vector3(HEX_SIZE * cos(angle1), HEX_HEIGHT * 0.5, HEX_SIZE * sin(angle1))
        var p2 = Vector3(HEX_SIZE * cos(angle2), HEX_HEIGHT * 0.5, HEX_SIZE * sin(angle2))
        var p3 = Vector3(HEX_SIZE * cos(angle2), -HEX_HEIGHT * 0.5, HEX_SIZE * sin(angle2))
        var p4 = Vector3(HEX_SIZE * cos(angle1), -HEX_HEIGHT * 0.5, HEX_SIZE * sin(angle1))
        
        # Normal points outward
        var normal = Vector3(cos((angle1 + angle2) * 0.5), 0, sin((angle1 + angle2) * 0.5)).normalized()
        
        st.add_normal(normal)
        st.add_uv(Vector2(float(i) / 6, 0))
        st.add_vertex(p1)
        
        st.add_normal(normal)
        st.add_uv(Vector2(float(i+1) / 6, 0))
        st.add_vertex(p2)
        
        st.add_normal(normal)
        st.add_uv(Vector2(float(i+1) / 6, 1))
        st.add_vertex(p3)
        
        st.add_normal(normal)
        st.add_uv(Vector2(float(i) / 6, 0))
        st.add_vertex(p1)
        
        st.add_normal(normal)
        st.add_uv(Vector2(float(i+1) / 6, 1))
        st.add_vertex(p3)
        
        st.add_normal(normal)
        st.add_uv(Vector2(float(i) / 6, 1))
        st.add_vertex(p4)
    }
    
    st.commit(mesh)
    return mesh

# Create materials for cells
func _create_materials():
    # Default cell material
    cell_material = SpatialMaterial.new()
    cell_material.albedo_color = Color(0.2, 0.3, 0.7, 0.8)
    cell_material.metallic = 0.3
    cell_material.roughness = 0.4
    cell_material.flags_transparent = true
    
    # Highlight material
    highlight_material = SpatialMaterial.new()
    highlight_material.albedo_color = Color(0.5, 0.7, 1.0, 0.9)
    highlight_material.emission_enabled = true
    highlight_material.emission = Color(0.3, 0.5, 0.8)
    highlight_material.emission_energy = 0.5
    highlight_material.flags_transparent = true
    
    # Selected material
    selected_material = SpatialMaterial.new()
    selected_material.albedo_color = Color(1.0, 0.7, 0.2, 0.9)
    selected_material.emission_enabled = true
    selected_material.emission = Color(0.8, 0.5, 0.2)
    selected_material.emission_energy = 1.0
    selected_material.flags_transparent = true

# Setup camera for grid viewing
func setup_camera():
    camera = Camera.new()
    camera.name = "GridCamera"
    camera.translation = Vector3(0, 10, 15)
    camera.look_at(Vector3.ZERO, Vector3.UP)
    add_child(camera)

# Convert axial hex coordinates to 3D position
func axial_to_position(q, r):
    var x = HEX_SIZE * (1.5 * q)
    var z = HEX_SIZE * (SQRT3 * 0.5 * q + SQRT3 * r)
    return Vector3(x, 0, z)

# Generate flat hexagonal grid
func generate_flat_grid(size):
    # Clear existing grid
    clear_grid()
    
    # Generate new cells in axial coordinates
    for q in range(-size, size + 1):
        for r in range(-size, size + 1):
            # Apply hex grid constraint
            var s = -q-r
            if abs(s) <= size:
                var pos = axial_to_position(q, r)
                var cell = _create_hex_cell()
                cell.translation = pos
                
                # Store cell in grid
                var coord = Vector3(q, r, s)
                grid_cells[coord] = cell
                
                # Connect signals
                var area = cell.get_node("ClickArea")
                if area:
                    area.connect("mouse_entered", self, "_on_cell_mouse_entered", [coord])
                    area.connect("mouse_exited", self, "_on_cell_mouse_exited", [coord])
                    area.connect("input_event", self, "_on_cell_input_event", [coord])
    
    current_mode = GridMode.FLAT

# Generate spherical grid
func generate_sphere_grid(size):
    # Clear existing grid
    clear_grid()
    
    # Generate cells using spherical coordinates mapped to a hex grid
    var radius = size * HEX_SIZE * 0.5
    
    for q in range(-size, size + 1):
        for r in range(-size, size + 1):
            # Apply hex grid constraint
            var s = -q-r
            if abs(s) <= size:
                # Get flat position for initial layout
                var flat_pos = axial_to_position(q, r)
                
                # Calculate spherical position
                var pos_normalized = flat_pos.normalized()
                var sphere_pos = pos_normalized * radius
                
                # Create cell
                var cell = _create_hex_cell()
                cell.translation = sphere_pos
                
                # Orient cell normal to sphere surface
                if sphere_pos.length() > 0.01:
                    var up = sphere_pos.normalized()
                    var forward = Vector3.FORWARD
                    if abs(up.dot(forward)) > 0.99:
                        forward = Vector3.RIGHT
                    var right = up.cross(forward).normalized()
                    forward = right.cross(up).normalized()
                    
                    var basis = Basis(right, up, forward)
                    cell.transform.basis = basis
                
                # Store cell in grid
                var coord = Vector3(q, r, s)
                grid_cells[coord] = cell
                
                # Connect signals
                var area = cell.get_node("ClickArea")
                if area:
                    area.connect("mouse_entered", self, "_on_cell_mouse_entered", [coord])
                    area.connect("mouse_exited", self, "_on_cell_mouse_exited", [coord])
                    area.connect("input_event", self, "_on_cell_input_event", [coord])
    
    current_mode = GridMode.SPHERE

# Generate cylinder grid
func generate_cylinder_grid(size):
    # Clear existing grid
    clear_grid()
    
    var radius = size * HEX_SIZE * 0.6
    var height = size * HEX_SIZE * 1.2
    
    for q in range(-size, size + 1):
        for r in range(-size, size + 1):
            # Apply hex grid constraint
            var s = -q-r
            if abs(s) <= size:
                # Get flat position for initial layout
                var flat_pos = axial_to_position(q, r)
                
                # Map to cylinder coordinates
                var angle = (flat_pos.x / (size * HEX_SIZE * 2)) * 2 * PI
                var y = (flat_pos.z / (size * HEX_SIZE * 2)) * height - height/2
                
                var cylinder_pos = Vector3(
                    radius * cos(angle),
                    y,
                    radius * sin(angle)
                )
                
                # Create cell
                var cell = _create_hex_cell()
                cell.translation = cylinder_pos
                
                # Orient cell normal to cylinder surface
                var up = Vector3.UP
                var normal = Vector3(cylinder_pos.x, 0, cylinder_pos.z).normalized()
                var tangent = up.cross(normal).normalized()
                var basis = Basis(tangent, up, normal)
                
                cell.transform.basis = basis
                
                # Store cell in grid
                var coord = Vector3(q, r, s)
                grid_cells[coord] = cell
                
                # Connect signals
                var area = cell.get_node("ClickArea")
                if area:
                    area.connect("mouse_entered", self, "_on_cell_mouse_entered", [coord])
                    area.connect("mouse_exited", self, "_on_cell_mouse_exited", [coord])
                    area.connect("input_event", self, "_on_cell_input_event", [coord])
    
    current_mode = GridMode.CYLINDER

# Generate torus grid
func generate_torus_grid(size):
    # Clear existing grid
    clear_grid()
    
    var major_radius = size * HEX_SIZE * 1.0  # Outer radius of torus
    var minor_radius = size * HEX_SIZE * 0.3  # Inner radius of torus
    
    for q in range(-size, size + 1):
        for r in range(-size, size + 1):
            # Apply hex grid constraint
            var s = -q-r
            if abs(s) <= size:
                # Get flat position
                var flat_pos = axial_to_position(q, r)
                
                # Map to toroidal coordinates
                var u = (flat_pos.x / (size * HEX_SIZE * 2)) * 2 * PI  # around the torus
                var v = (flat_pos.z / (size * HEX_SIZE * 2)) * 2 * PI  # around the tube
                
                var torus_pos = Vector3(
                    (major_radius + minor_radius * cos(v)) * cos(u),
                    minor_radius * sin(v),
                    (major_radius + minor_radius * cos(v)) * sin(u)
                )
                
                # Create cell
                var cell = _create_hex_cell()
                cell.translation = torus_pos
                
                # Orient cell normal to torus surface
                var center_dir = Vector3(cos(u), 0, sin(u))
                var normal = torus_pos - (center_dir * major_radius)
                normal = normal.normalized()
                
                var tangent1 = Vector3(-sin(u), 0, cos(u))
                var tangent2 = normal.cross(tangent1).normalized()
                
                var basis = Basis(tangent1, tangent2, normal)
                cell.transform.basis = basis
                
                # Store cell in grid
                var coord = Vector3(q, r, s)
                grid_cells[coord] = cell
                
                # Connect signals
                var area = cell.get_node("ClickArea")
                if area:
                    area.connect("mouse_entered", self, "_on_cell_mouse_entered", [coord])
                    area.connect("mouse_exited", self, "_on_cell_mouse_exited", [coord])
                    area.connect("input_event", self, "_on_cell_input_event", [coord])
    
    current_mode = GridMode.TORUS

# Generate infinite grid (creates cells around view area and moves them as needed)
func generate_infinite_grid():
    # Clear existing grid
    clear_grid()
    
    # Generate visible region initially
    var visible_size = 8
    _populate_visible_region(Vector2.ZERO, visible_size)
    
    current_mode = GridMode.INFINITE
    scroll_position = Vector2.ZERO

# Create a single hex cell instance
func _create_hex_cell():
    var cell = hex_cell_scene.duplicate()
    cell.name = "HexCell"
    add_child(cell)
    return cell

# Populate visible region for infinite grid
func _populate_visible_region(center_pos, size):
    var center_q = int(center_pos.x / (HEX_SIZE * 1.5))
    var center_r = int(center_pos.y / (HEX_SIZE * SQRT3))
    
    for q in range(center_q - size, center_q + size + 1):
        for r in range(center_r - size, center_r + size + 1):
            var s = -q-r
            
            var coord = Vector3(q, r, s)
            if not grid_cells.has(coord):
                var pos = axial_to_position(q, r)
                var cell = _create_hex_cell()
                cell.translation = pos
                
                # Store cell in grid
                grid_cells[coord] = cell
                
                # Connect signals
                var area = cell.get_node("ClickArea")
                if area:
                    area.connect("mouse_entered", self, "_on_cell_mouse_entered", [coord])
                    area.connect("mouse_exited", self, "_on_cell_mouse_exited", [coord])
                    area.connect("input_event", self, "_on_cell_input_event", [coord])

# Update grid with word data
func update_grid_with_words(words):
    # Clear existing word data
    word_cells.clear()
    
    # Get cells in coordinate order for consistent assignment
    var cell_coords = grid_cells.keys()
    cell_coords.sort()
    
    var word_idx = 0
    var word_ids = words.keys()
    
    # Assign words to cells
    for coord in cell_coords:
        if word_idx >= word_ids.size():
            break
            
        var word_id = word_ids[word_idx]
        var word_data = words[word_id]
        
        # Assign word to cell
        set_cell_data(coord, word_data)
        
        # Track word to cell mapping
        word_cells[word_id] = coord
        
        word_idx += 1

# Set data for a specific cell
func set_cell_data(coord, data):
    if not grid_cells.has(coord):
        return
        
    var cell = grid_cells[coord]
    
    # Update label
    var label = cell.get_node("Label")
    if label and data.has("text"):
        label.text = data.text
        
        # Set color based on data properties
        if data.has("color"):
            label.modulate = data.color
        elif data.has("power"):
            # Generate color based on power
            var power = float(data.power) / 100.0
            label.modulate = Color(
                min(0.5 + power * 0.5, 1.0),
                min(0.5 + (1.0 - power) * 0.5, 1.0),
                min(0.7 + abs(power - 0.5), 1.0)
            )
        
        # Set size based on power
        if data.has("power"):
            var scale_factor = 0.8 + (data.power / 100.0) * 0.7
            label.pixel_size = 0.01 * scale_factor
    
    # Store data in cell (for reference)
    cell.set_meta("data", data)
    
    # Notify of update
    emit_signal("data_updated", coord, data)

# Clear entire grid
func clear_grid():
    # Remove all cells
    for coord in grid_cells:
        var cell = grid_cells[coord]
        if is_instance_valid(cell):
            cell.queue_free()
    
    grid_cells.clear()
    word_cells.clear()

# Switch visualization mode
func switch_to_mode(mode):
    if mode == current_mode:
        return
    
    match mode:
        GridMode.FLAT:
            generate_flat_grid(GRID_FLAT_SIZE)
        GridMode.SPHERE:
            generate_sphere_grid(GRID_FLAT_SIZE)
        GridMode.CYLINDER:
            generate_cylinder_grid(GRID_FLAT_SIZE)
        GridMode.TORUS:
            generate_torus_grid(GRID_FLAT_SIZE)
        GridMode.INFINITE:
            generate_infinite_grid()
    
    # Reset camera
    _reset_camera_for_mode(mode)
    
    # Emit view changed signal
    emit_signal("view_changed", mode, grid_center, grid_rotation, grid_scale)
    
    # If we have word data, update grid
    if word_drive:
        var words = word_drive.get_all_words()
        update_grid_with_words(words)

# Reset camera for current mode
func _reset_camera_for_mode(mode):
    match mode:
        GridMode.FLAT, GridMode.INFINITE:
            camera.translation = Vector3(0, 15, 15)
            camera.rotation = Vector3(-PI/4, 0, 0)
        GridMode.SPHERE:
            camera.translation = Vector3(0, 0, GRID_FLAT_SIZE * HEX_SIZE * 2)
            camera.look_at(Vector3.ZERO, Vector3.UP)
        GridMode.CYLINDER:
            camera.translation = Vector3(0, 0, GRID_FLAT_SIZE * HEX_SIZE * 2)
            camera.look_at(Vector3.ZERO, Vector3.UP)
        GridMode.TORUS:
            camera.translation = Vector3(0, GRID_FLAT_SIZE * HEX_SIZE * 0.5, GRID_FLAT_SIZE * HEX_SIZE * 3)
            camera.look_at(Vector3.ZERO, Vector3.UP)

# Update sphere rotation animation
func _process_sphere_rotation(delta):
    var rotation_matrix = Basis(Vector3.UP, delta * ROTATION_SPEED * 0.2)
    
    # Rotate all cells around center
    for coord in grid_cells:
        var cell = grid_cells[coord]
        var pos = cell.translation
        
        # Rotate position
        pos = rotation_matrix.xform(pos)
        
        # Apply to cell
        cell.translation = pos
        
        # Orient cell normal to sphere surface
        if pos.length() > 0.01:
            var up = pos.normalized()
            var forward = Vector3.FORWARD
            if abs(up.dot(forward)) > 0.99:
                forward = Vector3.RIGHT
            var right = up.cross(forward).normalized()
            forward = right.cross(up).normalized()
            
            var basis = Basis(right, up, forward)
            cell.transform.basis = basis

# Process infinite grid scrolling
func _process_infinite_scroll(delta):
    var visible_size = 8
    var visible_range = HEX_SIZE * SQRT3 * visible_size
    
    # Check if we need to create new cells or recycle existing ones
    var center_q = int(scroll_position.x / (HEX_SIZE * 1.5))
    var center_r = int(scroll_position.y / (HEX_SIZE * SQRT3))
    
    # Populate new cells as needed
    _populate_visible_region(scroll_position, visible_size)
    
    # Remove cells that are too far from view
    var cells_to_remove = []
    for coord in grid_cells:
        var q = coord.x
        var r = coord.y
        
        var dist_q = abs(q - center_q)
        var dist_r = abs(r - center_r)
        
        if dist_q > visible_size * 2 or dist_r > visible_size * 2:
            cells_to_remove.append(coord)
    
    # Remove far cells
    for coord in cells_to_remove:
        var cell = grid_cells[coord]
        if is_instance_valid(cell):
            cell.queue_free()
        grid_cells.erase(coord)
    
    # Update the displayed grid position
    _update_infinite_grid_position()

# Update grid position for infinite scrolling
func _update_infinite_grid_position():
    for coord in grid_cells:
        var q = coord.x
        var r = coord.y
        
        var base_pos = axial_to_position(q, r)
        var offset_pos = Vector3(
            base_pos.x - scroll_position.x,
            base_pos.y,
            base_pos.z - scroll_position.y
        )
        
        grid_cells[coord].translation = offset_pos

# Process cylindrical grid rotation
func _process_cylindrical_rotation(delta):
    if current_mode == GridMode.CYLINDER:
        var rotation_matrix = Basis(Vector3.UP, delta * ROTATION_SPEED * 0.2)
        
        # Rotate all cells around center Y axis
        for coord in grid_cells:
            var cell = grid_cells[coord]
            var pos = cell.translation
            
            # Rotate position around Y axis
            var rotated_pos = Vector3(
                rotation_matrix.xform(Vector3(pos.x, 0, pos.z)).x,
                pos.y,
                rotation_matrix.xform(Vector3(pos.x, 0, pos.z)).z
            )
            
            # Apply to cell
            cell.translation = rotated_pos
            
            # Update orientation
            var normal = Vector3(rotated_pos.x, 0, rotated_pos.z).normalized()
            var up = Vector3.UP
            var tangent = up.cross(normal).normalized()
            var basis = Basis(tangent, up, normal)
            
            cell.transform.basis = basis
    
    elif current_mode == GridMode.TORUS:
        var rotation_matrix = Basis(Vector3.UP, delta * ROTATION_SPEED * 0.1)
        var rotation_matrix2 = Basis(Vector3.RIGHT, delta * ROTATION_SPEED * 0.05)
        
        # Rotate all cells around center
        for coord in grid_cells:
            var cell = grid_cells[coord]
            var pos = cell.translation
            
            # Apply double rotation for torus
            pos = rotation_matrix.xform(pos)
            pos = rotation_matrix2.xform(pos)
            
            # Apply to cell
            cell.translation = pos
            
            # Complex torus orientation update
            var major_radius = GRID_FLAT_SIZE * HEX_SIZE * 1.0
            var center_proj = Vector3(pos.x, 0, pos.z)
            var center_dir = center_proj.normalized()
            
            if center_proj.length() > 0.1:
                var normal = (pos - center_dir * major_radius).normalized()
                var tangent1 = Vector3(-center_dir.z, 0, center_dir.x)
                var tangent2 = normal.cross(tangent1).normalized()
                
                var basis = Basis(tangent1, tangent2, normal)
                cell.transform.basis = basis

# Update grid scale effect
func _update_grid_scale(delta):
    # Apply current scale to all cells
    for coord in grid_cells:
        var cell = grid_cells[coord]
        
        if current_mode == GridMode.FLAT or current_mode == GridMode.INFINITE:
            cell.scale = Vector3(grid_scale, grid_scale, grid_scale)
        else:
            # For 3D shapes, scale is applied differently to preserve the shape
            var mesh = cell.get_node("HexMesh")
            if mesh:
                mesh.scale = Vector3(1, grid_scale, 1)

# Orbit camera based on mouse input
func _orbit_camera(relative_motion):
    if not camera:
        return
        
    var sensitivity = 0.005
    var orbit_center = Vector3.ZERO
    
    # Get current camera position relative to center
    var cam_pos = camera.global_transform.origin - orbit_center
    
    # Create rotation matrices
    var horizontal_rotation = Basis(Vector3.UP, -relative_motion.x * sensitivity)
    var vertical_axis = camera.global_transform.basis.x
    var vertical_rotation = Basis(vertical_axis, -relative_motion.y * sensitivity)
    
    # Apply rotations
    cam_pos = horizontal_rotation.xform(cam_pos)
    cam_pos = vertical_rotation.xform(cam_pos)
    
    # Update camera position
    camera.global_transform.origin = cam_pos + orbit_center
    
    # Make camera look at center
    camera.look_at(orbit_center, Vector3.UP)

# Get cell at mouse position using raycasting
func _get_cell_at_mouse_position():
    var mouse_pos = get_viewport().get_mouse_position()
    var ray_from = camera.project_ray_origin(mouse_pos)
    var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * 1000
    
    var space_state = get_world().direct_space_state
    var intersection = space_state.intersect_ray(ray_from, ray_to)
    
    if intersection and intersection.collider:
        var parent = intersection.collider.get_parent()
        
        # Find which cell this belongs to
        for coord in grid_cells:
            if grid_cells[coord] == parent:
                return coord
    
    return null

# Select a specific cell
func select_cell(coord):
    if not grid_cells.has(coord):
        return
    
    # Deselect previous cell
    if selected_cell and grid_cells.has(selected_cell):
        var prev_cell = grid_cells[selected_cell]
        var prev_mesh = prev_cell.get_node("HexMesh")
        if prev_mesh:
            prev_mesh.material_override = highlight_material if selected_cell == focused_cell else cell_material
    
    # Select new cell
    selected_cell = coord
    var cell = grid_cells[coord]
    var mesh = cell.get_node("HexMesh")
    if mesh:
        mesh.material_override = selected_material
    
    # Get cell data
    var data = cell.has_meta("data") ? cell.get_meta("data") : null
    
    # Emit selection signal
    emit_signal("cell_selected", coord, data)

# Handle mouse entering a cell
func _on_cell_mouse_entered(coord):
    if not grid_cells.has(coord):
        return
    
    focused_cell = coord
    
    # Don't change material if it's the selected cell
    if selected_cell == coord:
        return
    
    var cell = grid_cells[coord]
    var mesh = cell.get_node("HexMesh")
    if mesh:
        mesh.material_override = highlight_material
    
    # Get cell data
    var data = cell.has_meta("data") ? cell.get_meta("data") : null
    
    # Emit focus signal
    emit_signal("cell_focused", coord, data)

# Handle mouse exiting a cell
func _on_cell_mouse_exited(coord):
    if not grid_cells.has(coord):
        return
    
    if focused_cell == coord:
        focused_cell = null
    
    # Don't change material if it's the selected cell
    if selected_cell == coord:
        return
    
    var cell = grid_cells[coord]
    var mesh = cell.get_node("HexMesh")
    if mesh:
        mesh.material_override = cell_material

# Handle input events on cells
func _on_cell_input_event(camera, event, click_pos, normal, shape_idx, coord):
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT and event.pressed:
            select_cell(coord)

# Get cell for a specific word ID
func get_cell_for_word(word_id):
    if word_cells.has(word_id):
        return word_cells[word_id]
    return null

# Get word data for a cell
func get_word_in_cell(coord):
    if not grid_cells.has(coord):
        return null
    
    var cell = grid_cells[coord]
    return cell.has_meta("data") ? cell.get_meta("data") : null

# Connect to WordDrive
func connect_to_word_drive(drive):
    word_drive = drive
    
    if word_drive:
        # Initialize with current words
        var words = word_drive.get_all_words()
        update_grid_with_words(words)
        
        # Connect to messages for updates
        word_drive.connect("word_message_sent", self, "_on_word_message")

# Process word messages for updates
func _on_word_message(msg_type, payload, source):
    if not word_drive:
        return
    
    match msg_type:
        "word_create":
            # New word created
            if payload.has("id"):
                var word_id = payload.id
                
                # Find available cell
                for coord in grid_cells:
                    if not get_word_in_cell(coord):
                        # Empty cell found
                        set_cell_data(coord, payload)
                        word_cells[word_id] = coord
                        break
        
        "word_update":
            # Word updated
            if payload.has("id") and word_cells.has(payload.id):
                var coord = word_cells[payload.id]
                set_cell_data(coord, payload)
        
        "word_delete":
            # Word deleted
            if payload.has("id") and word_cells.has(payload.id):
                var coord = word_cells[payload.id]
                
                # Clear cell data
                var cell = grid_cells[coord]
                var label = cell.get_node("Label")
                if label:
                    label.text = ""
                
                cell.set_meta("data", null)
                word_cells.erase(payload.id)

# Transform flat grid to sphere with animation
func transform_flat_to_sphere(duration = 1.0):
    if current_mode != GridMode.FLAT:
        return
    
    var tween = Tween.new()
    add_child(tween)
    
    var radius = GRID_FLAT_SIZE * HEX_SIZE * 0.5
    
    # For each cell, store initial position and calculate target position
    var cells_data = {}
    for coord in grid_cells:
        var cell = grid_cells[coord]
        var initial_pos = cell.translation
        
        # Calculate target spherical position
        var pos_normalized = initial_pos.normalized()
        var target_pos = pos_normalized * radius
        
        cells_data[coord] = {
            "cell": cell,
            "initial_pos": initial_pos,
            "target_pos": target_pos
        }
    }
    
    # Setup camera tween
    var cam_initial_pos = camera.translation
    var cam_target_pos = Vector3(0, 0, GRID_FLAT_SIZE * HEX_SIZE * 2)
    
    tween.interpolate_property(camera, "translation", cam_initial_pos, cam_target_pos, 
        duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    
    # Start all tweens for cell positions
    for coord in cells_data:
        var data = cells_data[coord]
        tween.interpolate_method(self, "_update_cell_transform", 
            {"cell": data.cell, "start_pos": data.initial_pos, "end_pos": data.target_pos, "progress": 0.0},
            {"cell": data.cell, "start_pos": data.initial_pos, "end_pos": data.target_pos, "progress": 1.0},
            duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    }
    
    tween.start()
    
    # When complete, switch to sphere mode
    yield(tween, "tween_all_completed")
    current_mode = GridMode.SPHERE
    emit_signal("view_changed", current_mode, grid_center, grid_rotation, grid_scale)
    tween.queue_free()

# Update cell position during transition
func _update_cell_transform(data):
    var cell = data.cell
    var start_pos = data.start_pos
    var end_pos = data.end_pos
    var progress = data.progress
    
    # Interpolate position
    var new_pos = start_pos.linear_interpolate(end_pos, progress)
    cell.translation = new_pos
    
    # Gradually update orientation to sphere normal
    if progress > 0.5 and new_pos.length() > 0.01:
        var up = new_pos.normalized()
        var forward = Vector3.FORWARD
        if abs(up.dot(forward)) > 0.99:
            forward = Vector3.RIGHT
        var right = up.cross(forward).normalized()
        forward = right.cross(up).normalized()
        
        var target_basis = Basis(right, up, forward)
        var current_basis = cell.transform.basis
        
        # Spherical interpolation factor increases as progress approaches 1
        var orient_factor = (progress - 0.5) * 2.0
        
        # Use quaternions for smoother rotation
        var current_quat = Quat(current_basis)
        var target_quat = Quat(target_basis)
        var interpolated_quat = current_quat.slerp(target_quat, orient_factor)
        
        cell.transform.basis = Basis(interpolated_quat)
    }

# Transform sphere to flat grid with animation
func transform_sphere_to_flat(duration = 1.0):
    if current_mode != GridMode.SPHERE:
        return
    
    var tween = Tween.new()
    add_child(tween)
    
    # For each cell, store current position and calculate target position
    var cells_data = {}
    for coord in grid_cells:
        var cell = grid_cells[coord]
        var initial_pos = cell.translation
        
        // Calculate target flat position
        var q = coord.x
        var r = coord.y
        var target_pos = axial_to_position(q, r)
        
        cells_data[coord] = {
            "cell": cell,
            "initial_pos": initial_pos,
            "target_pos": target_pos,
            "initial_basis": cell.transform.basis,
            "target_basis": Basis() // Identity basis for flat orientation
        }
    }
    
    // Setup camera tween
    var cam_initial_pos = camera.translation
    var cam_target_pos = Vector3(0, 15, 15)
    var cam_initial_rot = camera.rotation
    var cam_target_rot = Vector3(-PI/4, 0, 0)
    
    tween.interpolate_property(camera, "translation", cam_initial_pos, cam_target_pos, 
        duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    tween.interpolate_property(camera, "rotation", cam_initial_rot, cam_target_rot, 
        duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    
    // Start all tweens for cell positions and orientations
    for coord in cells_data:
        var data = cells_data[coord]
        tween.interpolate_method(self, "_update_cell_flat_transform", 
            {"cell": data.cell, "start_pos": data.initial_pos, "end_pos": data.target_pos, 
             "start_basis": data.initial_basis, "end_basis": data.target_basis, "progress": 0.0},
            {"cell": data.cell, "start_pos": data.initial_pos, "end_pos": data.target_pos, 
             "start_basis": data.initial_basis, "end_basis": data.target_basis, "progress": 1.0},
            duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    }
    
    tween.start()
    
    // When complete, switch to flat mode
    yield(tween, "tween_all_completed")
    current_mode = GridMode.FLAT
    emit_signal("view_changed", current_mode, grid_center, grid_rotation, grid_scale)
    tween.queue_free()

# Update cell transform during flat conversion
func _update_cell_flat_transform(data):
    var cell = data.cell
    var start_pos = data.start_pos
    var end_pos = data.end_pos
    var start_basis = data.start_basis
    var end_basis = data.end_basis
    var progress = data.progress
    
    // Interpolate position
    var new_pos = start_pos.linear_interpolate(end_pos, progress)
    cell.translation = new_pos
    
    // Interpolate orientation using quaternions
    var start_quat = Quat(start_basis)
    var end_quat = Quat(end_basis)
    var interpolated_quat = start_quat.slerp(end_quat, progress)
    
    cell.transform.basis = Basis(interpolated_quat)

# Roll the grid like a ball (visualization effect)
func roll_grid(direction, duration = 1.0):
    if current_mode != GridMode.FLAT:
        return
    
    var tween = Tween.new()
    add_child(tween)
    
    // Calculate rotation axis perpendicular to direction
    var axis = Vector3(-direction.y, 0, direction.x).normalized()
    var angle = PI/2 // 90 degree rotation
    
    // Track how far each cell should move
    var grid_size = GRID_FLAT_SIZE * HEX_SIZE * 2
    var cells_data = {}
    
    for coord in grid_cells:
        var cell = grid_cells[coord]
        var initial_pos = cell.translation
        
        // Calculate position after rolling
        var rotation_transform = Transform()
        rotation_transform.basis = Basis(axis, angle)
        var rotated_pos = rotation_transform.xform(initial_pos)
        
        // Determine if this cell will be hidden (rotated to back side)
        var dot_product = initial_pos.normalized().dot(direction)
        var will_be_hidden = dot_product > 0
        
        cells_data[coord] = {
            "cell": cell,
            "initial_pos": initial_pos,
            "target_pos": rotated_pos,
            "will_be_hidden": will_be_hidden
        }
    }
    
    // Setup global rotation tween
    var rotation_data = {
        "progress": 0.0,
        "axis": axis,
        "angle": angle,
        "cells": cells_data
    }
    
    tween.interpolate_method(self, "_update_roll_transform", 
        rotation_data,
        {"progress": 1.0, "axis": axis, "angle": angle, "cells": cells_data},
        duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
    
    tween.start()
    
    // When complete, reorganize the grid
    yield(tween, "tween_all_completed")
    _finalize_grid_roll(direction)
    tween.queue_free()

# Update cell transforms during roll animation
func _update_roll_transform(data):
    var progress = data.progress
    var axis = data.axis
    var angle = data.angle * progress
    var cells = data.cells
    
    // Apply rotation to all cells
    for coord in cells:
        var cell_data = cells[coord]
        var cell = cell_data.cell
        var initial_pos = cell_data.initial_pos
        
        // Create rotation transform
        var rotation_transform = Transform()
        rotation_transform.basis = Basis(axis, angle)
        var rotated_pos = rotation_transform.xform(initial_pos)
        
        // Apply position
        cell.translation = rotated_pos
        
        // Update visibility (fade out cells rotating to back)
        if cell_data.will_be_hidden:
            var opacity = 1.0 - progress
            var mesh = cell.get_node("HexMesh")
            if mesh and mesh.material_override:
                var material = mesh.material_override
                var color = material.albedo_color
                color.a = opacity
                material.albedo_color = color
        }
    }

# Finalize grid after rolling animation
func _finalize_grid_roll(direction):
    // This would reorganize the grid after rolling
    // For a real implementation, you'd recalculate cell positions based on the new state
    // and possibly load/create new cells for the side that's now visible
    
    // For now, we'll just reset to flat mode as placeholder
    switch_to_mode(GridMode.FLAT)

# Main API: Update with search results
func update_with_search_results(search_results):
    // Get list of cells in order
    var cell_coords = grid_cells.keys()
    cell_coords.sort()
    
    // Clear existing assignments
    for coord in cell_coords:
        var cell = grid_cells[coord]
        var label = cell.get_node("Label")
        if label:
            label.text = ""
        
        cell.set_meta("data", null)
    }
    
    word_cells.clear()
    
    // Assign search results to cells
    var result_idx = 0
    for coord in cell_coords:
        if result_idx >= search_results.size():
            break
            
        var result = search_results[result_idx]
        set_cell_data(coord, result)
        
        if result.has("id"):
            word_cells[result.id] = coord
        }
        
        result_idx += 1
    }

# Convert grid to specific mode with transition
func transform_to_mode(target_mode, duration = 1.0):
    if current_mode == target_mode:
        return
        
    match [current_mode, target_mode]:
        [GridMode.FLAT, GridMode.SPHERE]:
            transform_flat_to_sphere(duration)
        [GridMode.SPHERE, GridMode.FLAT]:
            transform_sphere_to_flat(duration)
        _:
            // For other transitions, just switch directly
            switch_to_mode(target_mode)
}