extends Node
class_name MemorySplitVisualizer

# Memory Split Visualizer
# ----------------------
# Creates visual representations of memory splits across screen space
# Handles dynamic memory fragment layout and display

# Split Constants
const SPLIT_TYPES = {
    "HORIZONTAL": 0,  # Split horizontally (rows)
    "VERTICAL": 1,    # Split vertically (columns)
    "GRID": 2,        # Split into grid
    "QUAD": 3,        # Split into quadrants
    "HIERARCHICAL": 4,# Hierarchical splitting (tree-like)
    "DIMENSIONAL": 5, # Dimensional splitting (3D-like projection)
    "CUSTOM": 6      # Custom pattern splitting
}

const SPLIT_MARKERS = {
    "DEFAULT": "#",    # Standard split marker
    "SPACE": "□",      # Space/whitespace split
    "TIME": "⧗",       # Temporal split
    "DIMENSION": "◊",  # Dimensional split
    "STREAM": "↠",     # Data stream split
    "FRAGMENT": "∫",   # Fragment indicator
    "ZONE": "◍",       # Zone indicator
    "FOLD": "ᚬ",       # Fold indicator
    "COMBINE": "⨁"     # Combination indicator
}

# Level of Detail (LOD) settings
const LOD_LEVELS = {
    "MINIMAL": 0,    # Only essential data
    "LOW": 1,        # Basic data with minimal formatting
    "MEDIUM": 2,     # Standard detail level
    "HIGH": 3,       # Enhanced details and connections
    "MAXIMUM": 4     # Complete data visualization
}

# Data Structures
class SplitNode:
    var id: String
    var type: int      # SPLIT_TYPES
    var content: String
    var marker: String # SPLIT_MARKERS
    var children = []  # Array of SplitNode
    var rect = Rect2() # Screen rectangle position
    var metadata = {}
    var lod_level: int = LOD_LEVELS.MEDIUM
    var color_override = null
    var is_visible = true
    
    func _init(p_id: String, p_type: int, p_content: String = ""):
        id = p_id
        type = p_type
        content = p_content
        marker = SPLIT_MARKERS.DEFAULT
    
    func add_child(child: SplitNode):
        children.append(child)
    
    func set_rect(x: float, y: float, width: float, height: float):
        rect = Rect2(x, y, width, height)
    
    func set_metadata(key: String, value):
        metadata[key] = value
    
    func to_dict() -> Dictionary:
        var result = {
            "id": id,
            "type": type,
            "content": content,
            "marker": marker,
            "rect": {
                "x": rect.position.x,
                "y": rect.position.y,
                "width": rect.size.x,
                "height": rect.size.y
            },
            "metadata": metadata,
            "lod_level": lod_level,
            "color_override": color_override,
            "is_visible": is_visible,
            "children": []
        }
        
        for child in children:
            result.children.append(child.to_dict())
        
        return result
        
    static func from_dict(data: Dictionary) -> SplitNode:
        var node = SplitNode.new(data.id, data.type, data.content)
        node.marker = data.marker
        node.set_rect(
            data.rect.x,
            data.rect.y,
            data.rect.width,
            data.rect.height
        )
        node.metadata = data.metadata.duplicate()
        node.lod_level = data.lod_level
        node.color_override = data.color_override
        node.is_visible = data.is_visible
        
        for child_data in data.children:
            node.add_child(SplitNode.from_dict(child_data))
        
        return node

class SplitLayout:
    var id: String
    var name: String
    var root_node: SplitNode
    var viewport_size = Vector2(1024, 768)
    var metadata = {}
    var created_at: int
    var updated_at: int
    
    func _init(p_id: String, p_name: String):
        id = p_id
        name = p_name
        created_at = OS.get_unix_time()
        updated_at = created_at
    
    func set_root(node: SplitNode):
        root_node = node
        updated_at = OS.get_unix_time()
    
    func update_viewport_size(width: float, height: float):
        viewport_size = Vector2(width, height)
        updated_at = OS.get_unix_time()
    
    func to_dict() -> Dictionary:
        return {
            "id": id,
            "name": name,
            "root_node": root_node.to_dict() if root_node else null,
            "viewport_size": {
                "width": viewport_size.x,
                "height": viewport_size.y
            },
            "metadata": metadata,
            "created_at": created_at,
            "updated_at": updated_at
        }
    
    static func from_dict(data: Dictionary) -> SplitLayout:
        var layout = SplitLayout.new(data.id, data.name)
        if data.root_node:
            layout.root_node = SplitNode.from_dict(data.root_node)
        layout.update_viewport_size(
            data.viewport_size.width,
            data.viewport_size.height
        )
        layout.metadata = data.metadata.duplicate()
        layout.created_at = data.created_at
        layout.updated_at = data.updated_at
        return layout

# System Variables
var _layouts = {}      # id -> SplitLayout
var _active_layout = null
var _memory_system = null
var _connection_system = null
var _target_canvas = null
var _default_font = null
var _default_font_size = 14
var _default_colors = {
    "background": Color(0.1, 0.1, 0.1),
    "foreground": Color(0.9, 0.9, 0.9),
    "split_line": Color(0.3, 0.3, 0.3),
    "marker": Color(0.7, 0.7, 0.2),
    "highlight": Color(0.2, 0.6, 0.9),
    "dimension": {
        1: Color(0.7, 0.2, 0.2),
        2: Color(0.2, 0.7, 0.2),
        3: Color(0.2, 0.2, 0.7),
        4: Color(0.7, 0.7, 0.2),
        5: Color(0.7, 0.2, 0.7),
        6: Color(0.2, 0.7, 0.7),
        7: Color(0.5, 0.3, 0.1),
        8: Color(0.1, 0.5, 0.3),
        9: Color(0.3, 0.1, 0.5),
        10: Color(0.5, 0.5, 0.1),
        11: Color(0.5, 0.1, 0.5),
        12: Color(0.1, 0.5, 0.5)
    }
}

# Signals
signal layout_created(layout_id, name)
signal layout_updated(layout_id)
signal split_node_added(layout_id, node_id)
signal split_node_updated(layout_id, node_id)
signal split_content_set(layout_id, node_id, content)

# System Initialization
func _ready():
    _default_font = Control.new().get_font("font")
    if not _default_font:
        print("Warning: Default font not available, using fallback rendering")

func initialize(memory_system = null, connection_system = null, target_canvas = null):
    _memory_system = memory_system
    _connection_system = connection_system
    _target_canvas = target_canvas
    return true

func set_target_canvas(canvas):
    _target_canvas = canvas

# Layout Management
func create_layout(name: String) -> String:
    var layout_id = "layout_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    var layout = SplitLayout.new(layout_id, name)
    
    _layouts[layout_id] = layout
    
    emit_signal("layout_created", layout_id, name)
    
    return layout_id

func get_layout(layout_id: String) -> SplitLayout:
    if _layouts.has(layout_id):
        return _layouts[layout_id]
    return null

func set_active_layout(layout_id: String) -> bool:
    if not _layouts.has(layout_id):
        return false
    
    _active_layout = _layouts[layout_id]
    return true

func get_active_layout() -> SplitLayout:
    return _active_layout

# Split Operations
func create_split_node(layout_id: String, type: int, content: String = "") -> String:
    if not _layouts.has(layout_id):
        return ""
    
    var node_id = "node_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    var node = SplitNode.new(node_id, type, content)
    
    var layout = _layouts[layout_id]
    
    # If no root node, this becomes the root
    if not layout.root_node:
        layout.set_root(node)
        
        # Set rect to full viewport
        node.set_rect(0, 0, layout.viewport_size.x, layout.viewport_size.y)
    
    emit_signal("split_node_added", layout_id, node_id)
    
    return node_id

func add_child_split(layout_id: String, parent_node_id: String, type: int, content: String = "") -> String:
    if not _layouts.has(layout_id):
        return ""
    
    var layout = _layouts[layout_id]
    var parent_node = find_node_by_id(layout.root_node, parent_node_id)
    
    if not parent_node:
        return ""
    
    var node_id = "node_" + str(OS.get_unix_time()) + "_" + str(randi() % 1000).pad_zeros(3)
    var node = SplitNode.new(node_id, type, content)
    
    # Calculate initial rect based on parent and split type
    calculate_child_rect(parent_node, node, parent_node.children.size())
    
    parent_node.add_child(node)
    
    emit_signal("split_node_added", layout_id, node_id)
    
    return node_id

func find_node_by_id(root: SplitNode, node_id: String) -> SplitNode:
    if not root:
        return null
    
    if root.id == node_id:
        return root
    
    for child in root.children:
        var result = find_node_by_id(child, node_id)
        if result:
            return result
    
    return null

func calculate_child_rect(parent: SplitNode, child: SplitNode, index: int):
    var parent_rect = parent.rect
    
    match parent.type:
        SPLIT_TYPES.HORIZONTAL:
            var child_count = parent.children.size() + 1
            var height = parent_rect.size.y / child_count
            
            # Update existing children
            for i in range(parent.children.size()):
                var existing_child = parent.children[i]
                existing_child.set_rect(
                    parent_rect.position.x,
                    parent_rect.position.y + i * height,
                    parent_rect.size.x,
                    height
                )
            
            # Set new child rect
            child.set_rect(
                parent_rect.position.x,
                parent_rect.position.y + index * height,
                parent_rect.size.x,
                height
            )
            
        SPLIT_TYPES.VERTICAL:
            var child_count = parent.children.size() + 1
            var width = parent_rect.size.x / child_count
            
            # Update existing children
            for i in range(parent.children.size()):
                var existing_child = parent.children[i]
                existing_child.set_rect(
                    parent_rect.position.x + i * width,
                    parent_rect.position.y,
                    width,
                    parent_rect.size.y
                )
            
            # Set new child rect
            child.set_rect(
                parent_rect.position.x + index * width,
                parent_rect.position.y,
                width,
                parent_rect.size.y
            )
            
        SPLIT_TYPES.GRID:
            var total_children = parent.children.size() + 1
            var rows = ceil(sqrt(total_children))
            var cols = ceil(total_children / float(rows))
            
            var cell_width = parent_rect.size.x / cols
            var cell_height = parent_rect.size.y / rows
            
            # Update all children's positions
            for i in range(total_children):
                var row = floor(i / cols)
                var col = i % cols
                
                var node
                if i < parent.children.size():
                    node = parent.children[i]
                else:
                    node = child
                
                node.set_rect(
                    parent_rect.position.x + col * cell_width,
                    parent_rect.position.y + row * cell_height,
                    cell_width,
                    cell_height
                )
                
        SPLIT_TYPES.QUAD:
            # Only supports exactly 4 children
            var quad_index = min(index, 3)
            var row = floor(quad_index / 2)
            var col = quad_index % 2
            
            var half_width = parent_rect.size.x / 2
            var half_height = parent_rect.size.y / 2
            
            child.set_rect(
                parent_rect.position.x + col * half_width,
                parent_rect.position.y + row * half_height,
                half_width,
                half_height
            )
            
        SPLIT_TYPES.HIERARCHICAL:
            # Start with full area, each level divides available space
            var depth = parent.children.size()
            var margin_factor = 0.1 + (0.05 * depth)  # Increasing margin with depth
            
            var margin_x = parent_rect.size.x * margin_factor
            var margin_y = parent_rect.size.y * margin_factor
            
            child.set_rect(
                parent_rect.position.x + margin_x,
                parent_rect.position.y + margin_y,
                parent_rect.size.x - (2 * margin_x),
                parent_rect.size.y - (2 * margin_y)
            )
            
        SPLIT_TYPES.DIMENSIONAL:
            # 3D-like projection where each node appears to be on a different plane
            var offset = 20 * (parent.children.size() + 1)
            
            child.set_rect(
                parent_rect.position.x + offset,
                parent_rect.position.y + offset,
                parent_rect.size.x - (2 * offset),
                parent_rect.size.y - (2 * offset)
            )
            
        _:  # CUSTOM or default
            # For custom, let's just divide horizontally by default
            var height = parent_rect.size.y / (parent.children.size() + 1)
            child.set_rect(
                parent_rect.position.x,
                parent_rect.position.y + index * height,
                parent_rect.size.x,
                height
            )

func split_node(layout_id: String, node_id: String, split_type: int, split_count: int = 2) -> Array:
    if not _layouts.has(layout_id):
        return []
    
    var layout = _layouts[layout_id]
    var node = find_node_by_id(layout.root_node, node_id)
    
    if not node:
        return []
    
    var created_nodes = []
    
    # Create child nodes
    for i in range(split_count):
        var content = "Split " + str(i+1) + " of " + node_id
        var child_id = add_child_split(layout_id, node_id, split_type, content)
        
        if not child_id.empty():
            created_nodes.append(child_id)
    
    # Set node type to the split type
    node.type = split_type
    
    emit_signal("layout_updated", layout_id)
    
    return created_nodes

func set_node_content(layout_id: String, node_id: String, content: String) -> bool:
    if not _layouts.has(layout_id):
        return false
    
    var layout = _layouts[layout_id]
    var node = find_node_by_id(layout.root_node, node_id)
    
    if not node:
        return false
    
    node.content = content
    
    emit_signal("split_content_set", layout_id, node_id, content)
    
    return true

func set_node_marker(layout_id: String, node_id: String, marker: String) -> bool:
    if not _layouts.has(layout_id):
        return false
    
    if not SPLIT_MARKERS.values().has(marker):
        return false
    
    var layout = _layouts[layout_id]
    var node = find_node_by_id(layout.root_node, node_id)
    
    if not node:
        return false
    
    node.marker = marker
    
    emit_signal("split_node_updated", layout_id, node_id)
    
    return true

func set_node_lod(layout_id: String, node_id: String, lod_level: int) -> bool:
    if not _layouts.has(layout_id):
        return false
    
    if lod_level < LOD_LEVELS.MINIMAL or lod_level > LOD_LEVELS.MAXIMUM:
        return false
    
    var layout = _layouts[layout_id]
    var node = find_node_by_id(layout.root_node, node_id)
    
    if not node:
        return false
    
    node.lod_level = lod_level
    
    emit_signal("split_node_updated", layout_id, node_id)
    
    return true

# Layout Creation Helpers
func create_horizontal_split_layout(name: String, count: int) -> String:
    var layout_id = create_layout(name)
    var root_id = create_split_node(layout_id, SPLIT_TYPES.HORIZONTAL)
    
    var layout = _layouts[layout_id]
    var root_node = layout.root_node
    
    # Add child splits
    for i in range(count):
        var content = "Horizontal Split " + str(i+1)
        add_child_split(layout_id, root_id, SPLIT_TYPES.HORIZONTAL, content)
    
    return layout_id

func create_vertical_split_layout(name: String, count: int) -> String:
    var layout_id = create_layout(name)
    var root_id = create_split_node(layout_id, SPLIT_TYPES.VERTICAL)
    
    var layout = _layouts[layout_id]
    var root_node = layout.root_node
    
    # Add child splits
    for i in range(count):
        var content = "Vertical Split " + str(i+1)
        add_child_split(layout_id, root_id, SPLIT_TYPES.VERTICAL, content)
    
    return layout_id

func create_grid_layout(name: String, rows: int, cols: int) -> String:
    var layout_id = create_layout(name)
    var root_id = create_split_node(layout_id, SPLIT_TYPES.GRID)
    
    var layout = _layouts[layout_id]
    var root_node = layout.root_node
    
    # Add all cells
    for r in range(rows):
        for c in range(cols):
            var content = "Grid Cell " + str(r+1) + "," + str(c+1)
            add_child_split(layout_id, root_id, SPLIT_TYPES.GRID, content)
    
    return layout_id

func create_quad_layout(name: String) -> String:
    var layout_id = create_layout(name)
    var root_id = create_split_node(layout_id, SPLIT_TYPES.QUAD)
    
    var layout = _layouts[layout_id]
    var root_node = layout.root_node
    
    # Add four quadrants
    var quadrant_names = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"]
    
    for i in range(4):
        var content = "Quadrant " + quadrant_names[i]
        add_child_split(layout_id, root_id, SPLIT_TYPES.QUAD, content)
    
    return layout_id

# Rendering Functions
func render_layout(layout_id: String = "") -> bool:
    if not _target_canvas:
        print("Error: No target canvas set for rendering")
        return false
    
    if layout_id.empty() and _active_layout:
        layout_id = _active_layout.id
    
    if not _layouts.has(layout_id):
        print("Error: Layout not found: " + layout_id)
        return false
    
    var layout = _layouts[layout_id]
    
    # Clear canvas
    _target_canvas.clear()
    
    # Render layout tree
    if layout.root_node:
        render_node(layout.root_node)
    
    return true

func render_node(node: SplitNode, depth: int = 0):
    if not node or not node.is_visible:
        return
    
    var rect = node.rect
    
    # Draw background
    _target_canvas.draw_rect(rect, _default_colors.background, true)
    
    # Draw border
    _target_canvas.draw_rect(rect, _default_colors.split_line, false)
    
    # Get content color
    var content_color = _default_colors.foreground
    if node.color_override:
        content_color = node.color_override
    elif node.metadata.has("dimension") and _default_colors.dimension.has(node.metadata.dimension):
        content_color = _default_colors.dimension[node.metadata.dimension]
    
    # Draw content with appropriate level of detail
    var display_content = node.content
    
    # If associated with memory system, try to get real memory content
    if node.metadata.has("memory_id") and _memory_system:
        var memory = _memory_system.get_memory(node.metadata.memory_id)
        if memory:
            if node.lod_level == LOD_LEVELS.MINIMAL:
                # Just show ID
                display_content = memory.id.split("_")[0]
            elif node.lod_level == LOD_LEVELS.LOW:
                # Show truncated content
                display_content = memory.content.substr(0, 20) + (memory.content.length() > 20 ? "..." : "")
            elif node.lod_level == LOD_LEVELS.MEDIUM:
                # Show content with line breaks
                display_content = memory.content.replace("\n", " ")
                if display_content.length() > 50:
                    display_content = display_content.substr(0, 50) + "..."
            else:
                # Show full content for high/maximum LOD
                display_content = memory.content
    
    # Draw marker if present
    if node.marker != SPLIT_MARKERS.DEFAULT:
        var marker_rect = Rect2(
            rect.position.x + 5,
            rect.position.y + 5,
            20,
            20
        )
        
        _target_canvas.draw_string(
            _default_font,
            Vector2(marker_rect.position.x, marker_rect.position.y + 15),
            node.marker,
            _default_colors.marker
        )
    
    # Draw text content
    var text_padding = 10
    var text_x = rect.position.x + text_padding
    var text_y = rect.position.y + text_padding + _default_font_size
    
    # If node has marker, adjust text position
    if node.marker != SPLIT_MARKERS.DEFAULT:
        text_x += 25
    
    # Draw text with wrapping
    var max_width = rect.size.x - (2 * text_padding)
    draw_wrapped_text(
        display_content,
        Vector2(text_x, text_y),
        content_color,
        max_width
    )
    
    # Recursively render children
    for child in node.children:
        render_node(child, depth + 1)

func draw_wrapped_text(text: String, position: Vector2, color: Color, max_width: float):
    if not _target_canvas or not _default_font:
        return
    
    var lines = []
    var current_line = ""
    var words = text.split(" ")
    
    for word in words:
        var test_line = current_line + " " + word if current_line else word
        var line_width = _default_font.get_string_size(test_line).x
        
        if line_width <= max_width:
            current_line = test_line
        else:
            lines.append(current_line)
            current_line = word
    
    if current_line:
        lines.append(current_line)
    
    # Draw each line
    for i in range(lines.size()):
        var line_y = position.y + i * (_default_font_size + 5)
        _target_canvas.draw_string(
            _default_font,
            Vector2(position.x, line_y),
            lines[i],
            color
        )

# Layout Handling Functions
func save_layout(layout_id: String) -> bool:
    if not _layouts.has(layout_id):
        return false
    
    var layout = _layouts[layout_id]
    var dir = Directory.new()
    var layouts_dir = "user://layouts"
    
    # Create directory if it doesn't exist
    if not dir.dir_exists(layouts_dir):
        dir.make_dir_recursive(layouts_dir)
    
    # Save as JSON
    var file = File.new()
    var file_path = layouts_dir.plus_file(layout.id + ".json")
    var err = file.open(file_path, File.WRITE)
    
    if err != OK:
        push_error("Failed to open layout file for writing: " + str(err))
        return false
    
    file.store_string(JSON.print(layout.to_dict(), "  "))
    file.close()
    
    return true

func load_layout(file_path: String) -> String:
    var file = File.new()
    var err = file.open(file_path, File.READ)
    
    if err != OK:
        push_error("Failed to open layout file for reading: " + str(err))
        return ""
    
    var content = file.get_as_text()
    file.close()
    
    var parse_result = JSON.parse(content)
    if parse_result.error != OK:
        push_error("Failed to parse layout JSON: " + str(parse_result.error))
        return ""
    
    var layout_data = parse_result.result
    var layout = SplitLayout.from_dict(layout_data)
    
    # Store layout
    _layouts[layout.id] = layout
    
    emit_signal("layout_created", layout.id, layout.name)
    
    return layout.id

# Memory Integration
func create_memory_layout_from_dimension(dimension: int, layout_type: int = SPLIT_TYPES.GRID) -> String:
    if not _memory_system:
        return ""
    
    var layout_name = "Dimension " + str(dimension) + " Memories"
    var layout_id = create_layout(layout_name)
    var root_id = create_split_node(layout_id, layout_type)
    
    var memories = _memory_system.get_memories_by_dimension(dimension)
    
    # Determine layout based on number of memories
    if layout_type == SPLIT_TYPES.GRID:
        # Split into grid
        var count = memories.size()
        var rows = ceil(sqrt(count))
        var cols = ceil(count / float(rows))
        
        var layout = _layouts[layout_id]
        layout.root_node.type = SPLIT_TYPES.GRID
        
        for i in range(memories.size()):
            var memory = memories[i]
            var child_id = add_child_split(layout_id, root_id, SPLIT_TYPES.GRID, memory.content)
            
            if not child_id.empty():
                var child_node = find_node_by_id(layout.root_node, child_id)
                child_node.metadata["memory_id"] = memory.id
                child_node.metadata["dimension"] = dimension
                
                # Set marker based on tags if available
                if memory.tags.size() > 0:
                    if memory.tags.has(_memory_system.MEMORY_TAGS.CORE):
                        child_node.marker = SPLIT_MARKERS.DEFAULT
                    elif memory.tags.has(_memory_system.MEMORY_TAGS.FRAGMENT):
                        child_node.marker = SPLIT_MARKERS.FRAGMENT
                    elif memory.tags.has(_memory_system.MEMORY_TAGS.TIME):
                        child_node.marker = SPLIT_MARKERS.TIME
                    elif memory.tags.has(_memory_system.MEMORY_TAGS.SPACE):
                        child_node.marker = SPLIT_MARKERS.SPACE
    else:
        # Handle other layout types
        for i in range(memories.size()):
            var memory = memories[i]
            var child_id = add_child_split(layout_id, root_id, layout_type, memory.content)
            
            if not child_id.empty():
                var layout = _layouts[layout_id]
                var child_node = find_node_by_id(layout.root_node, child_id)
                child_node.metadata["memory_id"] = memory.id
                child_node.metadata["dimension"] = dimension
    
    emit_signal("layout_updated", layout_id)
    
    return layout_id

func create_connected_memories_layout(memory_id: String, connection_type: String = "") -> String:
    if not _memory_system or not _connection_system:
        return ""
    
    var memory = _memory_system.get_memory(memory_id)
    if not memory:
        return ""
    
    var layout_name = "Connections for " + memory_id
    var layout_id = create_layout(layout_name)
    
    # Create root node for central memory
    var root_id = create_split_node(layout_id, SPLIT_TYPES.HIERARCHICAL, memory.content)
    
    var layout = _layouts[layout_id]
    var root_node = layout.root_node
    root_node.metadata["memory_id"] = memory_id
    root_node.metadata["dimension"] = memory.dimension
    
    // Get connected memories
    var connected_memories = _connection_system.get_connected_memories(memory_id, connection_type)
    
    // Create nodes for connected memories
    for connected_id in connected_memories:
        var connected_memory = _memory_system.get_memory(connected_id)
        if connected_memory:
            var child_id = add_child_split(
                layout_id,
                root_id,
                SPLIT_TYPES.HIERARCHICAL,
                connected_memory.content
            )
            
            if not child_id.empty():
                var child_node = find_node_by_id(layout.root_node, child_id)
                child_node.metadata["memory_id"] = connected_id
                child_node.metadata["dimension"] = connected_memory.dimension
                
                // Set connection type marker
                var connections = _connection_system.get_connections_for_memory(memory_id)
                for conn in connections:
                    if (conn.source_id == memory_id and conn.target_id == connected_id) or \
                       (conn.target_id == memory_id and conn.source_id == connected_id):
                        // Choose marker based on connection type
                        if conn.type == _connection_system.CONNECTION_TYPES.SEQUENTIAL:
                            child_node.marker = SPLIT_MARKERS.STREAM
                        elif conn.type == _connection_system.CONNECTION_TYPES.SPLITS:
                            child_node.marker = SPLIT_MARKERS.FRAGMENT
                        elif conn.type == _connection_system.CONNECTION_TYPES.CYCLES:
                            child_node.marker = SPLIT_MARKERS.TIME
                        elif conn.type == _connection_system.CONNECTION_TYPES.MERGES:
                            child_node.marker = SPLIT_MARKERS.COMBINE
                        break
    
    emit_signal("layout_updated", layout_id)
    
    return layout_id

# Utility Functions
func nodes_to_text(layout_id: String) -> String:
    if not _layouts.has(layout_id):
        return ""
    
    var layout = _layouts[layout_id]
    var text = "# LAYOUT: " + layout.name + " #\n\n"
    
    if layout.root_node:
        text += _node_to_text(layout.root_node, 0)
    
    return text

func _node_to_text(node: SplitNode, depth: int) -> String:
    var indent = "  ".repeat(depth)
    var text = indent
    
    # Add marker if present
    if node.marker != SPLIT_MARKERS.DEFAULT:
        text += node.marker + " "
    
    # Add shortened content
    var content = node.content
    if content.length() > 50:
        content = content.substr(0, 47) + "..."
    content = content.replace("\n", " ")
    
    text += content + "\n"
    
    # Add children
    for child in node.children:
        text += _node_to_text(child, depth + 1)
    
    return text

func get_node_at_position(layout_id: String, position: Vector2) -> SplitNode:
    if not _layouts.has(layout_id):
        return null
    
    var layout = _layouts[layout_id]
    if not layout.root_node:
        return null
    
    return _find_node_at_position(layout.root_node, position)

func _find_node_at_position(node: SplitNode, position: Vector2) -> SplitNode:
    if not node.is_visible:
        return null
    
    # Check if position is within this node's rect
    if not node.rect.has_point(position):
        return null
    
    # Check children first (from back to front)
    for i in range(node.children.size() - 1, -1, -1):
        var child = node.children[i]
        var child_result = _find_node_at_position(child, position)
        if child_result:
            return child_result
    
    # If not in any children, return this node
    return node

# Example usage:
# var split_visualizer = MemorySplitVisualizer.new()
# add_child(split_visualizer)
# split_visualizer.initialize(memory_system, connection_system)
# 
# # Create a layout
# var layout_id = split_visualizer.create_grid_layout("Memory Grid", 2, 2)
# split_visualizer.set_active_layout(layout_id)
# 
# # Set a canvas item for rendering
# var canvas = $CanvasLayer/Panel
# split_visualizer.set_target_canvas(canvas)
# 
# # Render the layout
# split_visualizer.render_layout()