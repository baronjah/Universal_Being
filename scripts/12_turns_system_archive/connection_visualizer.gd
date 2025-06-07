extends Node2D
class_name ConnectionVisualizer

# Visual representation of file connections using your preferred format
# Displays connections between different file categories with hash symbols and colors

# Reference to snake_case translator
var translator

# Color coding for different file categories
var category_colors = {
  "main": Color(0.2, 0.6, 0.8),       # Blue
  "datapoint": Color(0.8, 0.6, 0.2),  # Orange
  "container": Color(0.8, 0.3, 0.7),  # Purple
  "archive": Color(0.3, 0.7, 0.4),    # Green
  "past": Color(0.7, 0.2, 0.3),       # Red
  "memories": Color(0.8, 0.8, 0.2),   # Yellow
  "3d_notepad": Color(0.4, 0.8, 0.8)  # Cyan
}

# Node positions for different categories
var category_positions = {
  "main": Vector2(400, 100),
  "datapoint": Vector2(200, 200),
  "container": Vector2(600, 200),
  "archive": Vector2(300, 300),
  "past": Vector2(500, 300),
  "memories": Vector2(300, 400),
  "3d_notepad": Vector2(500, 400)
}

# Node size for each category
var category_node_sizes = {
  "main": 40,
  "datapoint": 30,
  "container": 35,
  "archive": 30,
  "past": 30,
  "memories": 35,
  "3d_notepad": 35
}

# File nodes by category
var file_nodes = {}

# Connection lines
var connection_lines = []

# Hash symbols for display
var hash_symbols = {
  "#": "•",
  "##": "••",
  "###": "•••",
  "#_": "•_"
}

# Initialize the visualizer
func _ready():
  print("Connection Visualizer initialized")
  
  # Get reference to snake_case translator
  translator = get_node("../SnakeCaseTranslator")
  if translator == null:
    print("WARNING: SnakeCaseTranslator not found, visualization will be limited")
    return
  
  # Create nodes for each file
  _create_file_nodes()
  
  # Create connection lines
  _create_connection_lines()

# Draw the visualization
func _draw():
  # Draw connection lines first (background)
  for connection in connection_lines:
    draw_line(connection.start_pos, connection.end_pos, connection.color, 2.0)
    
    # Draw hash symbol in the middle of the line
    var mid_point = connection.start_pos.linear_interpolate(connection.end_pos, 0.5)
    var hash_symbol = hash_symbols.get(connection.hash_symbol, "•")
    var symbol_offset = Vector2(-5, -5) # Offset to center the text
    draw_string(get_font("font"), mid_point + symbol_offset, hash_symbol, Color.WHITE)
  
  # Draw file nodes (foreground)
  for category in file_nodes:
    var color = category_colors[category]
    
    for node in file_nodes[category]:
      # Draw node circle
      draw_circle(node.position, node.size, color)
      
      # Draw node label
      var label_offset = Vector2(-node.name.length() * 3, node.size + 10)
      draw_string(get_font("font"), node.position + label_offset, node.name, Color.WHITE)

# Create nodes for each file
func _create_file_nodes():
  for category in translator.category_mappings:
    var files = translator.category_mappings[category]
    var base_position = category_positions[category]
    var node_size = category_node_sizes[category]
    
    file_nodes[category] = []
    
    # Calculate spacing based on number of files
    var spacing = 80.0
    var total_width = (files.size() - 1) * spacing
    var start_x = base_position.x - (total_width / 2)
    
    for i in range(files.size()):
      var file_node = {
        "name": files[i],
        "position": Vector2(start_x + (i * spacing), base_position.y),
        "size": node_size,
        "category": category
      }
      
      file_nodes[category].append(file_node)

# Create connection lines between nodes
func _create_connection_lines():
  var connection_map = translator.build_hash_connection_map()
  
  # Create connections for each source file
  for source in connection_map:
    var source_category = translator.get_file_category(source)
    var source_node = _find_node_by_name(source)
    
    if source_node == null:
      continue
      
    # Create connections to target files
    for target in connection_map[source]:
      var target_category = translator.get_file_category(target)
      var target_node = _find_node_by_name(target)
      
      if target_node == null:
        continue
      
      # Create hash connection
      var hash_symbol = translator.get_hash_connector(source)
      
      # Create connection line
      var connection = {
        "start_pos": source_node.position,
        "end_pos": target_node.position,
        "color": category_colors[source_category].linear_interpolate(category_colors[target_category], 0.5),
        "source": source,
        "target": target,
        "hash_symbol": hash_symbol
      }
      
      connection_lines.append(connection)

# Find a node by its name
func _find_node_by_name(name: String) -> Dictionary:
  for category in file_nodes:
    for node in file_nodes[category]:
      if node.name == name:
        return node
  
  return {}

# Save visualization as image
func save_visualization(path: String) -> bool:
  # Request redraw to ensure everything is updated
  queue_redraw()
  
  # Wait for redraw to complete
  await get_tree().process_frame
  
  # Capture the visualization as an image
  var viewport = get_viewport()
  var image = viewport.get_texture().get_data()
  
  # Save the image
  return image.save_png(path)

# Generate a textual map of the visualization
func generate_text_map() -> String:
  var text_map = "# Connection Visualization Map\n\n"
  
  # Add categories
  for category in file_nodes:
    text_map += "## " + category + " Files\n\n"
    
    for node in file_nodes[category]:
      text_map += "- " + node.name + "\n"
    
    text_map += "\n"
  
  # Add connections
  text_map += "## Connections\n\n"
  
  for connection in connection_lines:
    var hash_symbol = hash_symbols.get(connection.hash_symbol, "•")
    text_map += "- " + connection.source + " " + hash_symbol + " " + connection.target + "\n"
  
  return text_map

# Save text map
func save_text_map(path: String) -> bool:
  var text_map = generate_text_map()
  var file = FileAccess.open(path, FileAccess.WRITE)
  
  if file == null:
    return false
    
  file.store_string(text_map)
  file.close()
  return true