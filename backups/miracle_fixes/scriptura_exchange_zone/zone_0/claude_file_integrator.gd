extends Node
class_name ClaudeFileIntegrator

# Main integration system that combines all components
# Connects Claude files in snake_case format across different categories

# References to system components
var file_connection_system
var snake_case_translator
var connection_visualizer

# Integration results
var integration_results = {
  "total_files": 0,
  "connected_files": 0,
  "categories": {},
  "hash_connections": {}
}

# Initialize the integrator
func _ready():
  print("Claude File Integrator starting...")
  
  # Initialize components
  _init_components()
  
  # Run the integration
  integrate_files()
  
  print("Claude File Integrator initialization completed")

# Initialize all required components
func _init_components():
  # Create FileConnectionSystem if needed
  if not has_node("FileConnectionSystem"):
    file_connection_system = FileConnectionSystem.new()
    file_connection_system.name = "FileConnectionSystem"
    add_child(file_connection_system)
  else:
    file_connection_system = get_node("FileConnectionSystem")
  
  # Create SnakeCaseTranslator if needed
  if not has_node("SnakeCaseTranslator"):
    snake_case_translator = SnakeCaseTranslator.new()
    snake_case_translator.name = "SnakeCaseTranslator"
    add_child(snake_case_translator)
  else:
    snake_case_translator = get_node("SnakeCaseTranslator")
  
  # Create ConnectionVisualizer if needed
  if not has_node("ConnectionVisualizer"):
    connection_visualizer = ConnectionVisualizer.new()
    connection_visualizer.name = "ConnectionVisualizer"
    add_child(connection_visualizer)
  else:
    connection_visualizer = get_node("ConnectionVisualizer")
  
  print("All components initialized")

# Main integration function
func integrate_files():
  print("Starting file integration...")
  
  # Collect integration statistics
  integration_results.total_files = file_connection_system.file_connections.size()
  
  # Process each category
  for category in snake_case_translator.category_mappings:
    var files = snake_case_translator.category_mappings[category]
    integration_results.categories[category] = files.size()
    print("Category '" + category + "' has " + str(files.size()) + " files")
  
  # Process hash connections
  var connection_map = snake_case_translator.build_hash_connection_map()
  var total_connections = 0
  
  for source in connection_map:
    var targets = connection_map[source]
    total_connections += targets.size()
    
    var hash_symbol = snake_case_translator.get_hash_connector(source)
    if not hash_symbol in integration_results.hash_connections:
      integration_results.hash_connections[hash_symbol] = 0
    
    integration_results.hash_connections[hash_symbol] += targets.size()
  
  integration_results.connected_files = total_connections
  
  print("Integration completed with " + str(total_connections) + " connections")
  
  # Generate reports
  _generate_reports()

# Generate all reports and visualizations
func _generate_reports():
  # Create report directory if needed
  var reports_dir = "/mnt/c/Users/Percision 15/12_turns_system/reports"
  var dir = DirAccess.open("/mnt/c/Users/Percision 15/12_turns_system")
  if not dir.dir_exists("reports"):
    dir.make_dir("reports")
  
  # Generate connection report
  var timestamp = Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
  var connection_report_path = reports_dir + "/connection_report_" + timestamp + ".md"
  snake_case_translator.save_connection_report(connection_report_path)
  print("Connection report saved to: " + connection_report_path)
  
  # Generate system diagram
  var system_diagram_path = reports_dir + "/system_diagram_" + timestamp + ".dot"
  file_connection_system.save_visualization(system_diagram_path)
  print("System diagram saved to: " + system_diagram_path)
  
  # Generate markdown report
  var markdown_report_path = reports_dir + "/file_system_report_" + timestamp + ".md"
  file_connection_system.save_markdown_report(markdown_report_path)
  print("Markdown report saved to: " + markdown_report_path)
  
  # Generate visualization text map
  var text_map_path = reports_dir + "/visualization_map_" + timestamp + ".md"
  connection_visualizer.save_text_map(text_map_path)
  print("Visualization map saved to: " + text_map_path)

# Get summary of integration
func get_integration_summary() -> String:
  var summary = "# Claude File Integration Summary\n\n"
  
  # Add file statistics
  summary += "## File Statistics\n\n"
  summary += "- Total files: " + str(integration_results.total_files) + "\n"
  summary += "- Connected files: " + str(integration_results.connected_files) + "\n\n"
  
  # Add category statistics
  summary += "## Category Statistics\n\n"
  for category in integration_results.categories:
    summary += "- " + category + ": " + str(integration_results.categories[category]) + " files\n"
  summary += "\n"
  
  # Add hash connection statistics
  summary += "## Hash Connection Statistics\n\n"
  for hash_symbol in integration_results.hash_connections:
    summary += "- " + hash_symbol + ": " + str(integration_results.hash_connections[hash_symbol]) + " connections\n"
  
  return summary

# Initialize the files for a specific category
func initialize_category_files(category: String) -> bool:
  if not category in snake_case_translator.category_mappings:
    print("ERROR: Category '" + category + "' not found")
    return false
  
  var files = snake_case_translator.category_mappings[category]
  print("Initializing " + str(files.size()) + " files in category '" + category + "'")
  
  for file_name in files:
    print("- " + file_name)
    
    # Check if file exists in file connection system
    var file_path = file_connection_system.get_file_path(file_name)
    if file_path.is_empty():
      print("  WARNING: File path not found for '" + file_name + "'")
    else:
      print("  Path: " + file_path)
  
  return true

# Get all files with their hash symbols
func get_files_with_hash_symbols() -> Array:
  var result = []
  
  for category in snake_case_translator.category_mappings:
    var files = snake_case_translator.category_mappings[category]
    
    for file_name in files:
      var hash_symbol = snake_case_translator.get_hash_connector(file_name)
      result.append(hash_symbol + file_name)
  
  return result

# Generate a hash-based visual map
func generate_hash_visual_map() -> String:
  var map = "```\n"
  
  # Header
  map += "# CLAUDE FILE SYSTEM CONNECTIONS #\n\n"
  
  # Build the map
  for category in snake_case_translator.category_mappings:
    var hash_symbol = ""
    
    # Find hash symbol for this category
    for hash in snake_case_translator.hash_connectors:
      if category in snake_case_translator.hash_connectors[hash]:
        hash_symbol = hash
        break
    
    map += hash_symbol + " " + category.to_upper() + " " + hash_symbol + "\n"
    
    # Add files in this category
    var files = snake_case_translator.category_mappings[category]
    for file_name in files:
      map += "  " + hash_symbol + " " + file_name + "\n"
    
    map += "\n"
  
  # Show connections
  map += "# CONNECTIONS #\n\n"
  
  var connection_map = snake_case_translator.build_hash_connection_map()
  for source in connection_map:
    var source_hash = snake_case_translator.get_hash_connector(source)
    var targets = connection_map[source]
    
    if targets.size() > 0:
      map += source_hash + " " + source + " connects to:\n"
      
      for target in targets:
        var target_hash = snake_case_translator.get_hash_connector(target)
        map += "  " + source_hash + " --> " + target_hash + " " + target + "\n"
      
      map += "\n"
  
  map += "```"
  return map