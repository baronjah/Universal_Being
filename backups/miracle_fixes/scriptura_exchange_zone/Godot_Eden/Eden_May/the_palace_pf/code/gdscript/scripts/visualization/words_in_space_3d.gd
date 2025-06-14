extends Node3D
class_name WordsInSpace3D

# 3D Word Visualization System - Displays words in 3D space with Excel-like functionality
# This can be shown to Luminus as a demonstration of your word-based reality system

# Font and text settings
var default_font: Font
var default_font_size: int = 24
var word_material: StandardMaterial3D
var highlight_material: StandardMaterial3D
var selected_material: StandardMaterial3D

# Grid settings
var grid_dimensions = Vector3i(10, 10, 10)  # Like a 3D Excel grid
var cell_size = Vector3(1.0, 1.0, 1.0)
var grid_visible = true
var grid_color = Color(0.3, 0.3, 0.5, 0.2)

# Word positioning
var words_in_space = {}  # Dictionary of all words: {id: {word, position, scale, rotation, color, etc}}
var word_connections = {}  # Connections between words
var selected_word_id = null
var hover_word_id = null
var word_counter = 0

# Camera and navigation
var orbit_camera: Camera3D
var camera_target = Vector3.ZERO
var camera_distance = 10.0
var camera_speed = 5.0
var camera_rotation_speed = 1.0

# Physics interaction
var gravity_enabled = false
var physics_words = false
var word_bodies = {}  # For physics-enabled words

# Excel-like functionality
var columns = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J"]
var rows = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
var layers = ["Front", "Mid", "Back"]
var cells = {}  # Will contain cell data like Excel
var formulas = {}  # Will contain formulas like Excel

# Integration with word system
var word_manifestor = null
var entity_manager = null
var akashic_records = null

# Word properties and metadata
var word_categories = ["concept", "object", "action", "property", "relation"]
var word_colors = {
    "concept": Color(0.8, 0.2, 0.8),  # Purple for abstract concepts
    "object": Color(0.2, 0.6, 0.9),   # Blue for physical objects
    "action": Color(0.9, 0.3, 0.2),   # Red for action words
    "property": Color(0.2, 0.8, 0.3), # Green for descriptive properties
    "relation": Color(0.9, 0.8, 0.2)  # Yellow for relational words
}

# Visual effects
var pulse_effect_active = true
var rotation_effect_active = true
var glow_effect_active = true
var connection_effect_active = true

# Ready function
func _ready():
    # Set up materials
    _setup_materials()
    
    # Set up the camera
    _setup_camera()
    
    # Set up grid
    _setup_grid()
    
    # Set up interaction
    set_process_input(true)
    
    # Try to find the word manifestor and entity manager
    _find_word_systems()
    
    # Start with some sample words if in demo mode
    if OS.has_feature("editor"):
        _populate_demo_words()

# Set up materials for the words
func _setup_materials():
    # Default word material
    word_material = StandardMaterial3D.new()
    word_material.albedo_color = Color(1, 1, 1)
    word_material.emission_enabled = true
    word_material.emission = Color(0.5, 0.5, 0.8)
    word_material.emission_energy = 0.5
    
    # Highlight material for hover
    highlight_material = StandardMaterial3D.new()
    highlight_material.albedo_color = Color(1, 1, 1)
    highlight_material.emission_enabled = true
    highlight_material.emission = Color(0.8, 0.8, 0.2)
    highlight_material.emission_energy = 1.0
    
    # Selected material
    selected_material = StandardMaterial3D.new()
    selected_material.albedo_color = Color(1, 1, 1)
    selected_material.emission_enabled = true
    selected_material.emission = Color(0.2, 0.8, 0.2)
    selected_material.emission_energy = 1.5
    
    # Load default font
    default_font = load("res://fonts/default_font.tres") if ResourceLoader.exists("res://fonts/default_font.tres") else null

# Set up the orbit camera
func _setup_camera():
    # Create camera if it doesn't exist
    if not has_node("OrbitCamera"):
        orbit_camera = Camera3D.new()
        orbit_camera.name = "OrbitCamera"
        orbit_camera.current = true
        
        # Position the camera
        orbit_camera.position = Vector3(0, 0, camera_distance)
        orbit_camera.look_at(camera_target)
        
        add_child(orbit_camera)

# Set up the 3D grid
func _setup_grid():
    # Remove any existing grid
    if has_node("3DGrid"):
        get_node("3DGrid").queue_free()
    
    # Create grid mesh
    var grid_node = Node3D.new()
    grid_node.name = "3DGrid"
    add_child(grid_node)
    
    var grid_material = StandardMaterial3D.new()
    grid_material.albedo_color = grid_color
    grid_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    
    # Create X-Y planes for each Z level
    for z in range(grid_dimensions.z + 1):
        var grid_mesh = _create_grid_plane(grid_dimensions.x, grid_dimensions.y, cell_size.x, cell_size.y)
        var grid_instance = MeshInstance3D.new()
        grid_instance.mesh = grid_mesh
        grid_instance.material_override = grid_material
        grid_instance.position = Vector3(grid_dimensions.x * cell_size.x / 2, grid_dimensions.y * cell_size.y / 2, z * cell_size.z)
        grid_node.add_child(grid_instance)
    
    # Create coordinate labels
    _create_grid_labels()
    
    # Set grid visibility
    grid_node.visible = grid_visible

# Create a grid plane mesh
func _create_grid_plane(width, height, cell_width, cell_height):
    var surface_tool = SurfaceTool.new()
    surface_tool.begin(Mesh.PRIMITIVE_LINES)
    
    # Horizontal lines
    for y in range(height + 1):
        surface_tool.add_vertex(Vector3(0, y * cell_height, 0))
        surface_tool.add_vertex(Vector3(width * cell_width, y * cell_height, 0))
    
    # Vertical lines
    for x in range(width + 1):
        surface_tool.add_vertex(Vector3(x * cell_width, 0, 0))
        surface_tool.add_vertex(Vector3(x * cell_width, height * cell_height, 0))
    
    surface_tool.index()
    return surface_tool.commit()

# Create labels for the 3D grid
func _create_grid_labels():
    var labels_node = Node3D.new()
    labels_node.name = "GridLabels"
    get_node("3DGrid").add_child(labels_node)
    
    # Create column labels (A, B, C...)
    for x in range(grid_dimensions.x):
        _create_text_label(columns[x], Vector3((x + 0.5) * cell_size.x, -0.5 * cell_size.y, 0), 0.5, Color(0.8, 0.8, 1.0))
    
    # Create row labels (1, 2, 3...)
    for y in range(grid_dimensions.y):
        _create_text_label(str(rows[y]), Vector3(-0.5 * cell_size.x, (y + 0.5) * cell_size.y, 0), 0.5, Color(0.8, 0.8, 1.0))
    
    # Create layer labels (Front, Mid, Back...)
    for z in range(grid_dimensions.z):
        _create_text_label(layers[z] if z < layers.size() else str(z), 
                         Vector3(-0.5 * cell_size.x, -0.5 * cell_size.y, (z + 0.5) * cell_size.z), 
                         0.5, 
                         Color(0.8, 0.8, 1.0))

# Create a 3D text label
func _create_text_label(text, position, scale_factor=1.0, color=Color(1,1,1)):
    var label_mesh = TextMesh.new()
    label_mesh.text = text
    label_mesh.font_size = int(default_font_size * scale_factor)
    
    if default_font:
        label_mesh.font = default_font
    
    var label_instance = MeshInstance3D.new()
    label_instance.mesh = label_mesh
    
    var label_material = StandardMaterial3D.new()
    label_material.albedo_color = color
    label_material.emission_enabled = true
    label_material.emission = color
    label_material.emission_energy = 0.5
    label_instance.material_override = label_material
    
    label_instance.position = position
    
    get_node("3DGrid/GridLabels").add_child(label_instance)
    return label_instance

# Find word-related systems in the scene
func _find_word_systems():
    # Look for word manifestor
    if has_node("/root/main"):
        var main = get_node("/root/main")
        if main.has_method("get_word_manifestor"):
            word_manifestor = main.get_word_manifestor()
        
        if main.has_method("get_entity_manager"):
            entity_manager = main.get_entity_manager()
            
        if main.has_method("get_records_system"):
            akashic_records = main.get_records_system()

# Populate with some demo words
func _populate_demo_words():
    # Add some sample words at different positions
    add_word("reality", Vector3(1, 5, 1), "concept")
    add_word("creation", Vector3(3, 5, 2), "concept")
    add_word("fire", Vector3(5, 3, 1), "object")
    add_word("water", Vector3(5, 3, 3), "object")
    add_word("earth", Vector3(2, 3, 4), "object")
    add_word("air", Vector3(8, 3, 2), "object")
    add_word("run", Vector3(3, 1, 3), "action")
    add_word("jump", Vector3(5, 1, 3), "action")
    add_word("blue", Vector3(7, 5, 5), "property")
    add_word("heavy", Vector3(7, 3, 5), "property")
    
    # Add some connections
    connect_words("reality", "creation")
    connect_words("fire", "water")
    connect_words("earth", "air")
    connect_words("run", "jump")
    
    # Add to cells in the 3D grid
    set_cell_word("A1", "Front", "reality")
    set_cell_word("C2", "Mid", "creation")
    set_cell_word("E3", "Front", "fire")
    set_cell_word("E3", "Back", "water")
    set_cell_word("B3", "Back", "earth")
    
    # Add a formula to a cell
    set_cell_formula("D4", "Mid", "=CONNECT(A1,C2)")  # Connect reality and creation

# Add a word to 3D space
func add_word(word_text, position, category="concept", size=1.0, color=null):
    word_counter += 1
    var word_id = word_text + "_" + str(word_counter)
    
    # Determine word color
    var word_color = color
    if word_color == null and word_categories.has(category):
        word_color = word_colors[category]
    if word_color == null:
        word_color = Color(1, 1, 1)
    
    # Create 3D text mesh
    var text_mesh = TextMesh.new()
    text_mesh.text = word_text
    text_mesh.font_size = int(default_font_size * size)
    
    if default_font:
        text_mesh.font = default_font
    
    # Create mesh instance
    var word_instance = MeshInstance3D.new()
    word_instance.name = word_id
    word_instance.mesh = text_mesh
    
    # Create custom material for this word
    var word_mat = word_material.duplicate()
    word_mat.albedo_color = word_color
    word_mat.emission = word_color
    word_instance.material_override = word_mat
    
    # Set word position
    word_instance.position = position
    
    # Add to scene
    add_child(word_instance)
    
    # Store word data
    words_in_space[word_id] = {
        "text": word_text,
        "position": position,
        "category": category,
        "size": size,
        "color": word_color,
        "node": word_instance,
        "connections": []
    }
    
    # Set up collision for interaction
    var collision_shape = CollisionShape3D.new()
    var box_shape = BoxShape3D.new()
    box_shape.size = Vector3(word_text.length() * size * 0.5, size, 0.1) # Approximate text dimensions
    collision_shape.shape = box_shape
    
    var area = Area3D.new()
    area.collision_layer = 1
    area.collision_mask = 1
    area.input_ray_pickable = true
    area.name = "WordInteractionArea"
    area.set_meta("word_id", word_id)
    
    area.add_child(collision_shape)
    word_instance.add_child(area)
    
    # Connect area signals
    area.connect("mouse_entered", Callable(self, "_on_Word_mouse_entered").bind(word_id))
    area.connect("mouse_exited", Callable(self, "_on_Word_mouse_exited").bind(word_id))
    area.connect("input_event", Callable(self, "_on_Word_input_event").bind(word_id))
    
    if physics_words:
        _add_physics_to_word(word_id)
    
    # If integrated with word manifestor, try to get word properties
    _get_word_properties(word_id, word_text)
    
    return word_id

# Connect two words with a visible line
func connect_words(word1_id, word2_id, connection_type="default", connection_strength=1.0):
    # Ensure both words exist
    if not words_in_space.has(word1_id) or not words_in_space.has(word2_id):
        return false
    
    # Create unique connection ID
    var connection_id = word1_id + "_to_" + word2_id
    
    # Don't create duplicate connections
    if word_connections.has(connection_id):
        return true
    
    # Get word positions
    var pos1 = words_in_space[word1_id].position
    var pos2 = words_in_space[word2_id].position
    
    # Create line mesh
    var line_mesh = ImmediateMesh.new()
    
    # Create material for connection line
    var line_material = StandardMaterial3D.new()
    line_material.albedo_color = Color(0.5, 0.5, 0.9, 0.7)
    line_material.emission_enabled = true
    line_material.emission = Color(0.5, 0.5, 0.9)
    line_material.emission_energy = 0.5 * connection_strength
    
    # Adjust material based on connection type
    match connection_type:
        "strong":
            line_material.albedo_color = Color(0.9, 0.5, 0.5, 0.8)
            line_material.emission = Color(0.9, 0.5, 0.5)
            line_material.emission_energy = 0.8 * connection_strength
        "semantic":
            line_material.albedo_color = Color(0.5, 0.9, 0.5, 0.8)
            line_material.emission = Color(0.5, 0.9, 0.5)
            line_material.emission_energy = 0.7 * connection_strength
    
    # Create connection line
    line_mesh.clear_surfaces()
    line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
    line_mesh.surface_add_vertex(pos1)
    line_mesh.surface_add_vertex(pos2)
    line_mesh.surface_end()
    
    # Create mesh instance for the line
    var line_instance = MeshInstance3D.new()
    line_instance.name = connection_id
    line_instance.mesh = line_mesh
    line_instance.material_override = line_material
    
    # Add to scene
    add_child(line_instance)
    
    # Store connection data
    word_connections[connection_id] = {
        "word1": word1_id,
        "word2": word2_id,
        "type": connection_type,
        "strength": connection_strength,
        "node": line_instance
    }
    
    # Update words connection list
    words_in_space[word1_id].connections.append(connection_id)
    words_in_space[word2_id].connections.append(connection_id)
    
    return true

# Get Excel-like cell position from row and column
func get_cell_position(column, row, layer):
    var x = columns.find(column)
    var y = rows.find(row)
    var z = layers.find(layer)
    
    if x == -1 or y == -1 or z == -1:
        return null
    
    return Vector3(x * cell_size.x, y * cell_size.y, z * cell_size.z)

# Set a word in a specific cell
func set_cell_word(column, layer, word_id):
    # Parse column to get letter and number
    var col_letter = column.substr(0, 1)
    var row_number = int(column.substr(1))
    
    # Get cell position
    var cell_pos = get_cell_position(col_letter, row_number, layer)
    if cell_pos == null:
        return false
    
    # Create cell identifier
    var cell_id = col_letter + str(row_number) + "_" + layer
    
    # Store cell data
    cells[cell_id] = {
        "word_id": word_id,
        "position": cell_pos,
        "column": col_letter,
        "row": row_number,
        "layer": layer
    }
    
    # If word exists, move it to this cell
    if words_in_space.has(word_id):
        # Add offset to center in cell
        var centered_pos = cell_pos + Vector3(cell_size.x/2, cell_size.y/2, 0)
        move_word(word_id, centered_pos)
    
    return true

# Set a formula in a specific cell
func set_cell_formula(column, layer, formula):
    # Parse column to get letter and number
    var col_letter = column.substr(0, 1)
    var row_number = int(column.substr(1))
    
    # Get cell position
    var cell_pos = get_cell_position(col_letter, row_number, layer)
    if cell_pos == null:
        return false
    
    # Create cell identifier
    var cell_id = col_letter + str(row_number) + "_" + layer
    
    # Parse formula
    var formula_type = ""
    var formula_args = []
    
    if formula.begins_with("="):
        var formula_parts = formula.substr(1).split("(")
        if formula_parts.size() >= 1:
            formula_type = formula_parts[0]
            
            if formula_parts.size() >= 2:
                var args_part = formula_parts[1].trim_suffix(")")
                formula_args = args_part.split(",")
    
    # Store formula data
    formulas[cell_id] = {
        "formula": formula,
        "type": formula_type,
        "args": formula_args,
        "position": cell_pos,
        "column": col_letter,
        "row": row_number,
        "layer": layer
    }
    
    # Execute formula
    execute_formula(cell_id)
    
    return true

# Execute a formula
func execute_formula(cell_id):
    if not formulas.has(cell_id):
        return false
    
    var formula = formulas[cell_id]
    
    match formula.type:
        "CONNECT":
            if formula.args.size() >= 2:
                # Get cell IDs for the args
                var cell1_id = formula.args[0]
                var cell2_id = formula.args[1]
                
                # Get words in those cells
                var word1_id = null
                var word2_id = null
                
                if cells.has(cell1_id) and cells[cell1_id].has("word_id"):
                    word1_id = cells[cell1_id].word_id
                
                if cells.has(cell2_id) and cells[cell2_id].has("word_id"):
                    word2_id = cells[cell2_id].word_id
                
                # Connect the words if they exist
                if word1_id and word2_id:
                    connect_words(word1_id, word2_id)
        
        "COMBINE":
            if formula.args.size() >= 2:
                # Get cell IDs for the args
                var cell1_id = formula.args[0]
                var cell2_id = formula.args[1]
                
                # Get words in those cells
                var word1_text = ""
                var word2_text = ""
                
                if cells.has(cell1_id) and cells[cell1_id].has("word_id"):
                    var word1_id = cells[cell1_id].word_id
                    if words_in_space.has(word1_id):
                        word1_text = words_in_space[word1_id].text
                
                if cells.has(cell2_id) and cells[cell2_id].has("word_id"):
                    var word2_id = cells[cell2_id].word_id
                    if words_in_space.has(word2_id):
                        word2_text = words_in_space[word2_id].text
                
                # Create a new combined word
                if word1_text != "" and word2_text != "":
                    var combined_text = word1_text + "_" + word2_text
                    var new_word_id = add_word(combined_text, formula.position)
                    set_cell_word(formula.column + str(formula.row), formula.layer, new_word_id)
    
    return true

# Move a word to a new position
func move_word(word_id, new_position):
    if not words_in_space.has(word_id):
        return false
    
    # Update position in data
    words_in_space[word_id].position = new_position
    
    # Update node position
    words_in_space[word_id].node.position = new_position
    
    # Update connections
    for connection_id in words_in_space[word_id].connections:
        update_connection(connection_id)
    
    return true

# Update a connection line between words
func update_connection(connection_id):
    if not word_connections.has(connection_id):
        return false
    
    var connection = word_connections[connection_id]
    
    # Ensure both words exist
    if not words_in_space.has(connection.word1) or not words_in_space.has(connection.word2):
        return false
    
    # Get updated positions
    var pos1 = words_in_space[connection.word1].position
    var pos2 = words_in_space[connection.word2].position
    
    # Update line mesh
    var line_mesh = ImmediateMesh.new()
    line_mesh.clear_surfaces()
    line_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
    line_mesh.surface_add_vertex(pos1)
    line_mesh.surface_add_vertex(pos2)
    line_mesh.surface_end()
    
    # Update instance
    connection.node.mesh = line_mesh
    
    return true

# Handle mouse entering a word
func _on_Word_mouse_entered(word_id):
    hover_word_id = word_id
    
    # Highlight the word
    if words_in_space.has(word_id):
        var word_node = words_in_space[word_id].node
        if word_id != selected_word_id:  # Don't change if already selected
            word_node.material_override = highlight_material

# Handle mouse exiting a word
func _on_Word_mouse_exited(word_id):
    if hover_word_id == word_id:
        hover_word_id = null
    
    # Remove highlight if not selected
    if words_in_space.has(word_id) and word_id != selected_word_id:
        var word_node = words_in_space[word_id].node
        var original_color = words_in_space[word_id].color
        
        # Restore original material
        var word_mat = word_material.duplicate()
        word_mat.albedo_color = original_color
        word_mat.emission = original_color
        word_node.material_override = word_mat

# Handle input events on words
func _on_Word_input_event(camera, event, position, normal, shape_idx, word_id):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            _on_Word_clicked(word_id)

# Handle word click
func _on_Word_clicked(word_id):
    # Deselect previous word
    if selected_word_id != null and words_in_space.has(selected_word_id):
        var prev_word_node = words_in_space[selected_word_id].node
        var prev_color = words_in_space[selected_word_id].color
        
        # Restore original material
        var word_mat = word_material.duplicate()
        word_mat.albedo_color = prev_color
        word_mat.emission = prev_color
        prev_word_node.material_override = word_mat
    
    # Select new word
    selected_word_id = word_id
    
    # Apply selection material
    if words_in_space.has(word_id):
        var word_node = words_in_space[word_id].node
        word_node.material_override = selected_material
        
        # Show word details
        _show_word_details(word_id)

# Show details for a selected word
func _show_word_details(word_id):
    if not words_in_space.has(word_id):
        return
    
    var word_data = words_in_space[word_id]
    
    # Print word details to the console
    print("Word: " + word_data.text)
    print("Category: " + word_data.category)
    print("Position: " + str(word_data.position))
    print("Size: " + str(word_data.size))
    print("Connections: " + str(word_data.connections.size()))
    
    # If there's a UI panel for showing details, update it here
    # This would typically be implemented in a separate script

# Add physics to a word
func _add_physics_to_word(word_id):
    if not words_in_space.has(word_id):
        return
    
    var word_node = words_in_space[word_id].node
    
    # Create rigid body for physics
    var rigid_body = RigidBody3D.new()
    rigid_body.name = "WordPhysics"
    
    # Create collision shape
    var collision_shape = CollisionShape3D.new()
    var box_shape = BoxShape3D.new()
    var word_text = words_in_space[word_id].text
    box_shape.size = Vector3(word_text.length() * 0.5, 1, 0.1)  # Approximate text dimensions
    collision_shape.shape = box_shape
    
    rigid_body.add_child(collision_shape)
    
    # Remove existing word node and add it to rigid body
    var parent = word_node.get_parent()
    parent.remove_child(word_node)
    rigid_body.add_child(word_node)
    word_node.position = Vector3.ZERO  # Reset position relative to parent
    
    # Add rigid body to scene
    parent.add_child(rigid_body)
    rigid_body.global_position = words_in_space[word_id].position
    
    # Store reference to rigid body
    word_bodies[word_id] = rigid_body

# Get word properties from the word manifestor system
func _get_word_properties(word_id, word_text):
    if word_manifestor and word_manifestor.has_method("analyze_word"):
        var properties = word_manifestor.analyze_word(word_text)
        
        # Update word category based on analysis
        if properties.has("element_affinity"):
            var element = properties.element_affinity
            words_in_space[word_id].element = element
            
            # Update color based on element
            var element_colors = {
                "fire": Color(0.9, 0.3, 0.2),
                "water": Color(0.2, 0.4, 0.9),
                "earth": Color(0.6, 0.4, 0.2),
                "air": Color(0.8, 0.8, 1.0),
                "metal": Color(0.7, 0.7, 0.7),
                "wood": Color(0.3, 0.7, 0.3)
            }
            
            if element_colors.has(element):
                words_in_space[word_id].color = element_colors[element]
                
                # Update material
                var word_node = words_in_space[word_id].node
                var word_mat = word_material.duplicate()
                word_mat.albedo_color = element_colors[element]
                word_mat.emission = element_colors[element]
                word_node.material_override = word_mat

# Process input for camera control
func _input(event):
    # Camera rotation with right mouse button
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_RIGHT:
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
    
    # Camera movement with mouse while right button is held
    if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
        _rotate_camera(event.relative)

# Process function for continuous updates
func _process(delta):
    # Update visual effects
    if pulse_effect_active:
        _update_pulse_effects(delta)
    
    if rotation_effect_active:
        _update_rotation_effects(delta)
    
    if connection_effect_active:
        _update_connection_effects(delta)

# Update pulse effects for words
func _update_pulse_effects(delta):
    var time = Time.get_ticks_msec() / 1000.0
    
    for word_id in words_in_space:
        # Skip selected or hovered words
        if word_id == selected_word_id or word_id == hover_word_id:
            continue
        
        var word_data = words_in_space[word_id]
        var word_node = word_data.node
        
        # Create a subtle pulsing effect
        var pulse_scale = 1.0 + sin(time * 2.0 + float(word_id.hash()) * 0.1) * 0.05
        word_node.scale = Vector3(pulse_scale, pulse_scale, pulse_scale)

# Update rotation effects for words
func _update_rotation_effects(delta):
    var time = Time.get_ticks_msec() / 1000.0
    
    for word_id in words_in_space:
        # Skip selected word
        if word_id == selected_word_id:
            continue
        
        var word_data = words_in_space[word_id]
        var word_node = word_data.node
        
        # Create a subtle rotation effect
        var rotation_speed = 0.2 + float(word_id.hash() % 10) * 0.02
        var rotation_angle = sin(time * rotation_speed) * 0.05
        word_node.rotation.y = rotation_angle
        word_node.rotation.x = rotation_angle * 0.5

# Update connection effects
func _update_connection_effects(delta):
    var time = Time.get_ticks_msec() / 1000.0
    
    for connection_id in word_connections:
        var connection = word_connections[connection_id]
        var line_node = connection.node
        
        # Get line material
        var material = line_node.material_override
        if material is StandardMaterial3D:
            # Pulse the emission energy
            var base_energy = 0.5 * connection.strength
            var pulse = sin(time * 2.0 + float(connection_id.hash()) * 0.1) * 0.2
            material.emission_energy = base_energy + pulse

# Rotate the camera based on mouse movement
func _rotate_camera(relative_movement):
    if orbit_camera:
        # Convert to radians
        var rotation_x = -relative_movement.y * camera_rotation_speed * 0.01
        var rotation_y = -relative_movement.x * camera_rotation_speed * 0.01
        
        # Rotate camera around target
        var camera_pos = orbit_camera.position
        var target_pos = camera_target
        
        # Create a basis for rotation
        var basis = Basis()
        basis = basis.rotated(Vector3.UP, rotation_y)
        basis = basis.rotated(Vector3.RIGHT, rotation_x)
        
        # Calculate new position
        var offset = camera_pos - target_pos
        offset = basis * offset
        
        # Apply new position
        orbit_camera.position = target_pos + offset
        orbit_camera.look_at(target_pos)

# Main function to display the 3D word visualization
func show_words_in_space():
    # Make sure this node is visible
    visible = true
    
    # Reset camera if needed
    if orbit_camera:
        orbit_camera.position = Vector3(grid_dimensions.x * cell_size.x / 2, 
                                      grid_dimensions.y * cell_size.y / 2, 
                                      camera_distance)
        orbit_camera.look_at(Vector3(grid_dimensions.x * cell_size.x / 2, 
                                   grid_dimensions.y * cell_size.y / 2, 
                                   0))
    
    # This would hide other UI elements if needed
    # And possibly set up a specific camera mode

# Create a visualization from entity manager data
func visualize_entities():
    if entity_manager == null:
        return
    
    # Get all entities
    var entities = entity_manager.get_all_entities()
    
    # Clear existing words
    _clear_all_words()
    
    # Create words for each entity
    for entity_id in entities:
        var entity = entity_manager.get_entity(entity_id)
        
        # Extract entity information
        var entity_type = entity.get_type()
        var entity_pos = entity.global_position
        
        # Scale position to fit grid
        var grid_pos = Vector3(
            entity_pos.x % grid_dimensions.x, 
            entity_pos.y % grid_dimensions.y,
            entity_pos.z % grid_dimensions.z
        )
        
        # Add word for this entity
        add_word(entity_type, grid_pos)

# Clear all words from the visualization
func _clear_all_words():
    # Remove all word nodes
    for word_id in words_in_space:
        if is_instance_valid(words_in_space[word_id].node):
            words_in_space[word_id].node.queue_free()
    
    # Remove all connection nodes
    for connection_id in word_connections:
        if is_instance_valid(word_connections[connection_id].node):
            word_connections[connection_id].node.queue_free()
    
    # Clear data
    words_in_space.clear()
    word_connections.clear()
    word_counter = 0
    selected_word_id = null
    hover_word_id = null

# Export visualization as a separate scene
func export_visualization(path="user://words_visualization.tscn"):
    # Create a new packed scene
    var packed_scene = PackedScene.new()
    
    # Pack the current state
    packed_scene.pack(self)
    
    # Save to file
    return ResourceSaver.save(packed_scene, path)

# Import visualization from a file
func import_visualization(path="user://words_visualization.tscn"):
    if ResourceLoader.exists(path):
        var scene = ResourceLoader.load(path)
        if scene is PackedScene:
            # Clear current state
            _clear_all_words()
            
            # Instance the scene
            var imported_viz = scene.instantiate()
            
            # Copy data from imported visualization
            if imported_viz is WordsInSpace3D:
                # Copy words
                for word_id in imported_viz.words_in_space:
                    var word_data = imported_viz.words_in_space[word_id]
                    add_word(word_data.text, word_data.position, word_data.category, 
                             word_data.size, word_data.color)
                
                # Copy connections
                for connection_id in imported_viz.word_connections:
                    var connection = imported_viz.word_connections[connection_id]
                    connect_words(connection.word1, connection.word2, 
                                 connection.type, connection.strength)
                
                return true
    
    return false