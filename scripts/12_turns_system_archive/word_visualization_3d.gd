extends Node3D

# Word Visualization in 3D Space
# Creates visual representations of words and their relationships

@onready var investment_system = $"../../MemoryInvestmentSystem"
@onready var direction_tracker = $"../../WordDirectionTracker"

# Visual properties
const WORD_COLORS = {
    "Knowledge": Color(0.2, 0.6, 1.0),
    "Insight": Color(0.8, 0.4, 1.0),
    "Creation": Color(0.2, 0.8, 0.4),
    "Connection": Color(1.0, 0.6, 0.2),
    "Memory": Color(0.6, 0.8, 1.0),
    "Dream": Color(0.5, 0.3, 0.8),
    "Ethereal": Color(0.9, 0.9, 1.0)
}

# Cached objects
var word_nodes = {}
var connection_lines = []

# Shader for ghostly appearance
var ghost_material = null
var line_material = null

func _ready():
    # Set up materials
    _create_materials()
    
    # Update timer
    var timer = Timer.new()
    timer.wait_time = 0.5
    timer.autostart = true
    timer.timeout.connect(_update_visualization)
    add_child(timer)
    
    # Initial update
    _update_visualization()

func _create_materials():
    # Create ghostly material
    ghost_material = StandardMaterial3D.new()
    ghost_material.flags_transparent = true
    ghost_material.albedo_color = Color(1, 1, 1, 0.7)
    ghost_material.emission_enabled = true
    ghost_material.emission = Color(0.5, 0.7, 0.9)
    ghost_material.emission_energy = 0.5
    
    # Create line material
    line_material = StandardMaterial3D.new()
    line_material.flags_transparent = true
    line_material.albedo_color = Color(0.7, 0.8, 1.0, 0.3)
    line_material.emission_enabled = true
    line_material.emission = Color(0.7, 0.8, 1.0)
    line_material.emission_energy = 0.3

func _update_visualization():
    # Get current investments and word relationships
    var investments = investment_system.get_investments()
    
    # Clear old connections
    for line in connection_lines:
        if is_instance_valid(line):
            line.queue_free()
    connection_lines.clear()
    
    # Update or create word nodes
    var words_to_keep = []
    
    for investment in investments:
        var word = investment.word
        words_to_keep.append(word)
        
        if not word_nodes.has(word):
            # Create new word node
            _create_word_node(word, investment.category)
        else:
            # Update existing node
            var node = word_nodes[word]
            if is_instance_valid(node):
                # Update size based on value
                var scale_factor = 0.5 + (investment.current_value / 10.0)
                scale_factor = clamp(scale_factor, 0.5, 2.0)
                node.scale = Vector3.ONE * scale_factor
                
                # Update color based on ROI
                var roi = investment.current_value / investment.initial_value
                var base_color = WORD_COLORS.get(investment.category, Color(0.8, 0.8, 0.8))
                var intensity = 0.5 + clamp(roi - 1.0, 0.0, 1.0)
                
                if is_instance_valid(node.get_node("MeshInstance3D")) and is_instance_valid(node.get_node("MeshInstance3D").get_surface_override_material(0)):
                    var material = node.get_node("MeshInstance3D").get_surface_override_material(0)
                    material.albedo_color = base_color
                    material.albedo_color.a = 0.7
                    material.emission = base_color
                    material.emission_energy = intensity
    
    # Remove nodes for words that are no longer invested
    var words_to_remove = []
    for word in word_nodes:
        if not word in words_to_keep:
            words_to_remove.append(word)
    
    for word in words_to_remove:
        if is_instance_valid(word_nodes[word]):
            word_nodes[word].queue_free()
        word_nodes.erase(word)
    
    # Create connections between related words
    for word in word_nodes:
        var related = direction_tracker.get_related_words(word)
        for related_word in related:
            if word_nodes.has(related_word):
                _create_connection(word, related_word)
    
    # Rotate the scene slightly for dynamic effect
    rotation.y += 0.001
    rotation.z += 0.0005

func _create_word_node(word, category):
    # Create node
    var node = Node3D.new()
    node.name = "Word_" + word
    add_child(node)
    
    # Position based on word's directional properties
    var position = direction_tracker.get_word_position(word)
    node.position = position * 2.0  # Scale for better visibility
    
    # Create mesh
    var mesh_instance = MeshInstance3D.new()
    node.add_child(mesh_instance)
    
    # Choose mesh based on category
    var mesh = null
    match category:
        "Knowledge": mesh = SphereMesh.new()
        "Insight": mesh = PrismMesh.new()
        "Creation": mesh = BoxMesh.new()
        "Connection": mesh = CylinderMesh.new()
        "Memory": mesh = CapsuleMesh.new()
        "Dream": mesh = TorusMesh.new()
        "Ethereal": 
            mesh = SphereMesh.new()
            mesh.radius = 0.3
            mesh.height = 0.6
        _: mesh = SphereMesh.new()
    
    mesh_instance.mesh = mesh
    
    # Create material clone
    var material = ghost_material.duplicate()
    material.albedo_color = WORD_COLORS.get(category, Color(0.8, 0.8, 0.8))
    
    mesh_instance.set_surface_override_material(0, material)
    
    # Add label
    var label_3d = Label3D.new()
    label_3d.text = word
    label_3d.font_size = 12
    label_3d.pixel_size = 0.01
    label_3d.no_depth_test = true
    label_3d.position.y = 0.5
    node.add_child(label_3d)
    
    # Store node reference
    word_nodes[word] = node

func _create_connection(word1, word2):
    # Skip if either node is invalid
    if not is_instance_valid(word_nodes[word1]) or not is_instance_valid(word_nodes[word2]):
        return
    
    # Get positions
    var pos1 = word_nodes[word1].position
    var pos2 = word_nodes[word2].position
    
    # Create immediate geometry
    var immediate = ImmediateMesh.new()
    var line_node = MeshInstance3D.new()
    line_node.mesh = immediate
    
    # Draw line
    immediate.clear_surfaces()
    immediate.surface_begin(Mesh.PRIMITIVE_LINES)
    immediate.surface_add_vertex(pos1)
    immediate.surface_add_vertex(pos2)
    immediate.surface_end()
    
    # Set material
    line_node.material_override = line_material.duplicate()
    
    # Add to scene
    add_child(line_node)
    connection_lines.append(line_node)

func _process(delta):
    # Slightly update positions for flowing effect
    var time = Time.get_ticks_msec() / 1000.0
    
    for word in word_nodes:
        var node = word_nodes[word]
        if is_instance_valid(node):
            # Get base position
            var base_pos = direction_tracker.get_word_position(word) * 2.0
            
            # Add subtle movement
            node.position = base_pos + Vector3(
                sin(time + hash(word) % 10) * 0.1,
                cos(time * 0.7 + hash(word) % 10) * 0.1,
                sin(time * 0.5 + hash(word) % 10) * 0.1
            )
            
            # Subtle rotation
            node.rotation.y += delta * 0.2
            
            # Pulse effect based on value
            var investment = investment_system.get_investment(word)
            if investment:
                var pulse = (sin(time * 2.0 + hash(word) % 10) + 1.0) * 0.1
                var scale_base = 0.5 + (investment.current_value / 10.0)
                scale_base = clamp(scale_base, 0.5, 2.0)
                node.scale = Vector3.ONE * (scale_base + pulse)
    
    # Update connection lines
    _update_connections()

func _update_connections():
    for i in range(connection_lines.size()):
        var line = connection_lines[i]
        if is_instance_valid(line) and line.mesh is ImmediateMesh:
            var immediate = line.mesh as ImmediateMesh
            
            # Get connected nodes from line vertices
            var vertices = []
            for j in range(immediate.get_surface_count()):
                # Cannot directly get vertex positions from ImmediateMesh
                # This is a simplification; in practice you'd need to track which words each line connects
                pass
            
            # As a fallback, just clear and rebuild all lines next update
            # This is less efficient but ensures lines follow moving nodes
            pass