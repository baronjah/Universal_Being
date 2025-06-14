extends Control
class_name JSHEntityVisualizer

# System references
var entity_manager: JSHEntityManager = null
var spatial_manager: JSHSpatialManager = null

# Visualization settings
var mode: String = "graph"  # graph, spatial, hierarchy
var focus_entity_id: String = ""
var focus_zone_id: String = ""
var show_labels: bool = true
var show_types: bool = true
var show_properties: bool = false
var show_connections: bool = true
var zoom_level: float = 1.0
var pan_offset: Vector2 = Vector2.ZERO

# Entity node graphics
var entity_nodes: Dictionary = {}  # Maps entity ID to node
var connection_lines: Array = []
var selected_entity: String = ""

# Node colors by type
var type_colors = {
    "primordial": Color(0.8, 0.8, 0.8),
    "fire": Color(1.0, 0.4, 0.2),
    "water": Color(0.2, 0.4, 1.0),
    "earth": Color(0.6, 0.4, 0.2),
    "air": Color(0.8, 0.8, 1.0),
    "wood": Color(0.2, 0.8, 0.2),
    "metal": Color(0.7, 0.7, 0.7),
    "ash": Color(0.4, 0.4, 0.4),
    "transformed": Color(0.8, 0.4, 0.8),
    "fused": Color(0.8, 0.6, 0.2),
    "consumed": Color(0.3, 0.3, 0.3)
}

# Signals
signal entity_selected(entity_id)
signal entity_hovered(entity_id)
signal entity_details_requested(entity_id)
signal zoom_changed(zoom_level)

func _ready() -> void:
    # Get system references
    entity_manager = JSHEntityManager.get_instance()
    spatial_manager = JSHSpatialManager.get_instance()
    
    # Connect to entity manager signals
    if entity_manager:
        entity_manager.connect("entity_created", Callable(self, "_on_entity_created"))
        entity_manager.connect("entity_destroyed", Callable(self, "_on_entity_destroyed"))
        entity_manager.connect("entity_updated", Callable(self, "_on_entity_updated"))
    
    # Initialize visualization
    _initialize_visualization()

func _initialize_visualization() -> void:
    # Clear existing nodes
    entity_nodes.clear()
    connection_lines.clear()
    
    # Create nodes for existing entities
    if entity_manager:
        for id in entity_manager.entities:
            _create_entity_node(id)
    
    # Set up connections
    if show_connections:
        _update_connections()
    
    # Layout nodes
    _layout_nodes()
    
    # Force redraw
    queue_redraw()

func _create_entity_node(entity_id: String) -> void:
    var entity = entity_manager.get_entity(entity_id)
    
    if entity:
        var node_data = {
            "id": entity_id,
            "type": entity.get_type(),
            "position": Vector2(randf_range(50, 500), randf_range(50, 500)),
            "size": Vector2(30, 30),
            "color": _get_type_color(entity.get_type()),
            "label": entity_id.substr(0, 8),
            "evolution_stage": entity.evolution_stage,
            "complexity": entity.complexity,
            "properties": entity.get_properties(),
            "references": entity.get_references(),
            "tags": entity.get_tags(),
            "zones": entity.get_zones(),
            "selected": false,
            "hovered": false
        }
        
        entity_nodes[entity_id] = node_data

func _update_entity_node(entity_id: String) -> void:
    var entity = entity_manager.get_entity(entity_id)
    
    if entity and entity_nodes.has(entity_id):
        var node = entity_nodes[entity_id]
        
        # Update properties that might change
        node.type = entity.get_type()
        node.color = _get_type_color(entity.get_type())
        node.evolution_stage = entity.evolution_stage
        node.complexity = entity.complexity
        node.properties = entity.get_properties()
        node.references = entity.get_references()
        node.tags = entity.get_tags()
        node.zones = entity.get_zones()
        
        # Keep position, size, selected state

func _remove_entity_node(entity_id: String) -> void:
    if entity_nodes.has(entity_id):
        entity_nodes.erase(entity_id)
        
        # Remove any connections to this entity
        _update_connections()

func _update_connections() -> void:
    connection_lines.clear()
    
    # Create connections based on references
    for id in entity_nodes:
        var node = entity_nodes[id]
        var entity = entity_manager.get_entity(id)
        
        if entity:
            var references = entity.get_references()
            
            for ref_type in references:
                for target_id in references[ref_type]:
                    if entity_nodes.has(target_id):
                        connection_lines.append({
                            "source": id,
                            "target": target_id,
                            "type": ref_type,
                            "color": Color(0.5, 0.5, 0.5, 0.7)
                        })
    
    # Special connection colors
    for i in range(connection_lines.size()):
        var line = connection_lines[i]
        
        match line.type:
            "parent":
                line.color = Color(0.2, 0.7, 0.2, 0.7)
            "child":
                line.color = Color(0.7, 0.2, 0.2, 0.7)
            "fused_into":
                line.color = Color(0.8, 0.6, 0.2, 0.7)
            "split_into":
                line.color = Color(0.2, 0.6, 0.8, 0.7)
            "created":
                line.color = Color(0.8, 0.2, 0.8, 0.7)

func _layout_nodes() -> void:
    match mode:
        "graph":
            _layout_graph()
        "spatial":
            _layout_spatial()
        "hierarchy":
            _layout_hierarchy()

func _layout_graph() -> void:
    # Force-directed graph layout
    var iterations = 100
    var k = 200.0  # Optimal distance
    var gravity = 0.01
    var damping = 0.9
    
    # Initialize forces and velocities
    var forces = {}
    var velocities = {}
    
    for id in entity_nodes:
        forces[id] = Vector2.ZERO
        velocities[id] = Vector2.ZERO
    
    for _iter in range(iterations):
        # Reset forces
        for id in entity_nodes:
            forces[id] = Vector2.ZERO
        
        # Repulsive forces (entities repel each other)
        for id1 in entity_nodes:
            var pos1 = entity_nodes[id1].position
            
            for id2 in entity_nodes:
                if id1 == id2:
                    continue
                
                var pos2 = entity_nodes[id2].position
                var delta = pos1 - pos2
                var distance = max(delta.length(), 0.1)
                var force = delta.normalized() * (k * k) / distance
                
                forces[id1] += force
                forces[id2] -= force
        
        # Attractive forces (connected entities attract)
        for connection in connection_lines:
            var id1 = connection.source
            var id2 = connection.target
            
            var pos1 = entity_nodes[id1].position
            var pos2 = entity_nodes[id2].position
            var delta = pos1 - pos2
            var distance = max(delta.length(), 0.1)
            var force = delta.normalized() * (distance * distance) / k
            
            forces[id1] -= force
            forces[id2] += force
        
        # Gravity toward center
        var center = Vector2(size.x / 2, size.y / 2)
        for id in entity_nodes:
            var pos = entity_nodes[id].position
            var delta = center - pos
            forces[id] += delta * gravity
        
        # Update positions
        for id in entity_nodes:
            velocities[id] = (velocities[id] + forces[id]) * damping
            entity_nodes[id].position += velocities[id]
            
            # Ensure nodes stay within bounds
            var pos = entity_nodes[id].position
            pos.x = clamp(pos.x, 50, size.x - 50)
            pos.y = clamp(pos.y, 50, size.y - 50)
            entity_nodes[id].position = pos

func _layout_spatial() -> void:
    # Use actual spatial positions for layout
    for id in entity_nodes:
        var spatial_pos = spatial_manager.get_entity_position(id)
        
        # Convert 3D position to 2D for display
        var pos_2d = Vector2(
            (spatial_pos.x * 0.5 + 0.5) * size.x,
            (spatial_pos.z * 0.5 + 0.5) * size.y
        )
        
        entity_nodes[id].position = pos_2d

func _layout_hierarchy() -> void:
    # Layout entities in a hierarchical tree
    var levels = {}
    var max_level = 0
    
    # Group entities by evolution stage
    for id in entity_nodes:
        var level = entity_nodes[id].evolution_stage
        max_level = max(max_level, level)
        
        if not levels.has(level):
            levels[level] = []
        
        levels[level].append(id)
    
    # Position entities by level
    var level_height = size.y / (max_level + 2)
    
    for level in levels:
        var entities = levels[level]
        var level_width = size.x / (entities.size() + 1)
        
        for i in range(entities.size()):
            var id = entities[i]
            var pos = Vector2(
                (i + 1) * level_width,
                (level + 1) * level_height
            )
            
            entity_nodes[id].position = pos

func _get_type_color(entity_type: String) -> Color:
    # Return color for entity type, or default
    if type_colors.has(entity_type):
        return type_colors[entity_type]
    
    # Check for derived types
    for base_type in type_colors:
        if entity_type.begins_with(base_type):
            return type_colors[base_type]
    
    # Default color
    return Color(0.5, 0.5, 0.5)

func set_mode(new_mode: String) -> void:
    if mode != new_mode:
        mode = new_mode
        _layout_nodes()
        queue_redraw()

func set_focus_entity(entity_id: String) -> void:
    focus_entity_id = entity_id
    
    if entity_nodes.has(entity_id):
        selected_entity = entity_id
        
        # Center view on entity
        var node_pos = entity_nodes[entity_id].position
        pan_offset = Vector2(size.x / 2, size.y / 2) - node_pos
        
        queue_redraw()

func set_focus_zone(zone_id: String) -> void:
    focus_zone_id = zone_id
    
    # Filter entities in this zone
    var entities_in_zone = []
    
    for id in entity_nodes:
        var entity = entity_manager.get_entity(id)
        if entity and zone_id in entity.get_zones():
            entities_in_zone.append(id)
    
    # Highlight entities in this zone
    for id in entity_nodes:
        entity_nodes[id].selected = id in entities_in_zone
    
    queue_redraw()

func _draw() -> void:
    # Apply zoom and pan
    var transform = Transform2D().translated(pan_offset).scaled(Vector2(zoom_level, zoom_level))
    
    # Draw connections
    if show_connections:
        for connection in connection_lines:
            var source_id = connection.source
            var target_id = connection.target
            
            if entity_nodes.has(source_id) and entity_nodes.has(target_id):
                var source_pos = transform * entity_nodes[source_id].position
                var target_pos = transform * entity_nodes[target_id].position
                
                # Draw line
                draw_line(source_pos, target_pos, connection.color, 2.0)
                
                # Draw arrow
                var direction = (target_pos - source_pos).normalized()
                var arrow_point = target_pos - direction * 15
                var perpendicular = Vector2(-direction.y, direction.x) * 5
                
                draw_triangle(arrow_point, arrow_point + perpendicular - direction * 10, arrow_point - perpendicular - direction * 10, connection.color)
    
    # Draw entity nodes
    for id in entity_nodes:
        var node = entity_nodes[id]
        var pos = transform * node.position
        var radius = node.size.x / 2 * zoom_level
        
        # Adjust node size based on complexity
        radius = radius * (1.0 + node.complexity * 0.05)
        
        # Draw node
        var color = node.color
        var border_color = Color.BLACK
        var border_width = 2.0
        
        if node.selected or id == selected_entity:
            border_color = Color.WHITE
            border_width = 3.0
        
        if node.hovered:
            border_color = Color.YELLOW
            border_width = 3.0
        
        draw_circle(pos, radius, color)
        draw_arc(pos, radius, 0, TAU, 32, border_color, border_width)
        
        # Draw evolution stage indicator
        if node.evolution_stage > 0:
            for i in range(node.evolution_stage):
                var angle = TAU * (i / 4.0)
                var indicator_pos = pos + Vector2(cos(angle), sin(angle)) * (radius * 0.7)
                draw_circle(indicator_pos, 3.0, Color.WHITE)
        
        # Draw label
        if show_labels:
            var font_size = 14
            var label = node.label
            
            if show_types:
                label += " (" + node.type + ")"
            
            var label_pos = pos + Vector2(0, radius + 15)
            draw_string(ThemeDB.fallback_font, label_pos, label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
        
        # Draw properties
        if show_properties and (node.selected or id == selected_entity):
            var property_text = ""
            for key in node.properties:
                property_text += key + ": " + str(node.properties[key]) + "\n"
            
            var prop_pos = pos + Vector2(0, radius + 30)
            draw_string(ThemeDB.fallback_font, prop_pos, property_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12)

func draw_triangle(p1: Vector2, p2: Vector2, p3: Vector2, color: Color) -> void:
    var points = PackedVector2Array([p1, p2, p3])
    draw_polygon(points, PackedColorArray([color]))

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.pressed:
            match event.button_index:
                MOUSE_BUTTON_LEFT:
                    # Check for node selection
                    var mouse_pos = get_local_mouse_position()
                    var transformed_pos = mouse_pos - pan_offset
                    transformed_pos /= zoom_level
                    
                    var closest_node = ""
                    var closest_distance = 1000000.0
                    
                    for id in entity_nodes:
                        var node = entity_nodes[id]
                        var distance = node.position.distance_to(transformed_pos)
                        
                        if distance < node.size.x / 2 * (1.0 + node.complexity * 0.05) and distance < closest_distance:
                            closest_node = id
                            closest_distance = distance
                    
                    if not closest_node.is_empty():
                        selected_entity = closest_node
                        emit_signal("entity_selected", closest_node)
                        queue_redraw()
                
                MOUSE_BUTTON_RIGHT:
                    # Show entity details
                    if not selected_entity.is_empty():
                        emit_signal("entity_details_requested", selected_entity)
                
                MOUSE_BUTTON_WHEEL_UP:
                    # Zoom in
                    zoom_level = min(zoom_level * 1.1, 5.0)
                    emit_signal("zoom_changed", zoom_level)
                    queue_redraw()
                
                MOUSE_BUTTON_WHEEL_DOWN:
                    # Zoom out
                    zoom_level = max(zoom_level / 1.1, 0.1)
                    emit_signal("zoom_changed", zoom_level)
                    queue_redraw()
        
    elif event is InputEventMouseMotion:
        # Pan the view
        if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
            pan_offset += event.relative
            queue_redraw()
        
        # Update node hover
        var mouse_pos = get_local_mouse_position()
        var transformed_pos = mouse_pos - pan_offset
        transformed_pos /= zoom_level
        
        var hovered_node = ""
        
        for id in entity_nodes:
            var node = entity_nodes[id]
            var distance = node.position.distance_to(transformed_pos)
            
            if distance < node.size.x / 2 * (1.0 + node.complexity * 0.05):
                hovered_node = id
                break
        
        # Update hover state
        var hover_changed = false
        
        for id in entity_nodes:
            var was_hovered = entity_nodes[id].hovered
            var is_hovered = id == hovered_node
            
            if was_hovered != is_hovered:
                entity_nodes[id].hovered = is_hovered
                hover_changed = true
        
        if hover_changed:
            queue_redraw()
            
            if not hovered_node.is_empty():
                emit_signal("entity_hovered", hovered_node)

func _on_entity_created(entity: JSHUniversalEntity) -> void:
    _create_entity_node(entity.get_id())
    _update_connections()
    queue_redraw()

func _on_entity_destroyed(entity_id: String) -> void:
    _remove_entity_node(entity_id)
    queue_redraw()

func _on_entity_updated(entity: JSHUniversalEntity) -> void:
    _update_entity_node(entity.get_id())
    _update_connections()
    queue_redraw()