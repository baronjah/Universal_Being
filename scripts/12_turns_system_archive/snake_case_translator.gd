extends Node
class_name SnakeCaseTranslator

# Translator system that converts existing files to snake_case
# and creates connections to main, datapoint, container, archive, past, memories, 3d notepad

# Original to snake_case mappings
var claude_mappings = {
  # Core Claude components to snake_case
  "CLAUDE.md": "claude_config_main",
  "claude_akashic_bridge.gd": "claude_akashic_bridge",
  "claude_akashic_demo.gd": "claude_demo_main",
  "claude_terminal_interface.sh": "claude_terminal_interface",
  "claude_ethereal_bridge.gd": "claude_ethereal_bridge",
  "claude_integration_bridge.gd": "claude_integration_main",
  
  # Memory systems to snake_case
  "word_memory_system.gd": "word_memory_system",
  "divine_memory_system.sh": "divine_memory_system",
  "memory_investment_system.gd": "memory_investment_system",
  "dimensional_memory_integration.gd": "dimensional_memory_integration",
  "dimensional_memory_splitter.gd": "dimensional_memory_splitter",
  "terminal_memory_system.gd": "terminal_memory_system",
  "project_memory_system.gd": "project_memory_system",
  "memory_manager.gd": "memory_manager_main",
  "memory_drive_connector.gd": "memory_drive_connector",
  
  # 3D Notepad to snake_case
  "3d_notepad.html": "notepad_3d_main",
  "NOTEPAD3D_README.md": "notepad_3d_readme",
  "notepad3d_visualizer.gd": "notepad_3d_visualizer",
  "notepad3d_manifesto.md": "notepad_3d_manifesto",
  
  # Datapoint systems to snake_case
  "datapoint-js.txt": "datapoint_js_main", 
  "terminal-datapoint-handlers.txt": "terminal_datapoint_handlers",
  
  # Main controllers to snake_case
  "main.gd": "main_controller"
}

# Categorize files by your specified categories
var category_mappings = {
  "main": [
    "claude_config_main",
    "claude_demo_main",
    "claude_integration_main",
    "memory_manager_main",
    "notepad_3d_main",
    "datapoint_js_main",
    "main_controller"
  ],
  
  "datapoint": [
    "datapoint_js_main",
    "terminal_datapoint_handlers"
  ],
  
  "container": [
    "claude_ethereal_bridge",
    "claude_akashic_bridge",
    "memory_drive_connector"
  ],
  
  "archive": [
    "memory_investment_system",
    "project_memory_system"
  ],
  
  "past": [
    "divine_memory_system",
    "dimensional_memory_splitter"
  ],
  
  "memories": [
    "word_memory_system",
    "terminal_memory_system",
    "dimensional_memory_integration",
    "memory_manager_main"
  ],
  
  "3d_notepad": [
    "notepad_3d_main",
    "notepad_3d_readme",
    "notepad_3d_visualizer",
    "notepad_3d_manifesto"
  ]
}

# Reference to the file connection system
var file_connection_system

# Hash symbol connectors for file relationships
var hash_connectors = {
  "#": ["main", "datapoint"],             # Single hash for basic connections
  "##": ["container", "archive"],         # Double hash for storage connections
  "###": ["past", "memories"],            # Triple hash for memory connections
  "#_": ["3d_notepad"]                    # Hash underscore for 3D notepad connections
}

# Initialize the translator
func _ready():
  print("Snake Case Translator initialized")
  
  # Get reference to file connection system
  file_connection_system = get_node("../FileConnectionSystem")
  if file_connection_system == null:
    print("WARNING: FileConnectionSystem not found, some functionality will be limited")

# Translate a file name to snake_case
func translate_to_snake_case(file_name: String) -> String:
  # Remove file extension
  var base_name = file_name.get_basename()
  
  # Convert to lowercase
  var lower_name = base_name.to_lower()
  
  # Replace spaces and special characters with underscores
  var snake_case = lower_name.replace(" ", "_")
  snake_case = snake_case.replace("-", "_")
  snake_case = snake_case.replace(".", "_")
  
  # Ensure no double underscores
  while snake_case.find("__") >= 0:
    snake_case = snake_case.replace("__", "_")
  
  return snake_case

# Get the category of a file based on its snake_case name
func get_file_category(snake_case_name: String) -> String:
  for category in category_mappings:
    if snake_case_name in category_mappings[category]:
      return category
  return ""

# Get hash connector for a file based on its category
func get_hash_connector(snake_case_name: String) -> String:
  var category = get_file_category(snake_case_name)
  
  for hash_symbol in hash_connectors:
    if category in hash_connectors[hash_symbol]:
      return hash_symbol
  
  return "#" # Default to single hash if no match

# Create a hash-based connection string between two files
func create_connection_string(source: String, target: String) -> String:
  var source_hash = get_hash_connector(source)
  var target_hash = get_hash_connector(target)
  
  return source_hash + source + " -> " + target_hash + target

# Build a complete connection map using hash symbols
func build_hash_connection_map() -> Dictionary:
  var connection_map = {}
  
  # Create connections for each category
  for category in category_mappings:
    var files = category_mappings[category]
    
    for i in range(files.size()):
      var source = files[i]
      connection_map[source] = []
      
      # Connect to other files in same category
      for j in range(files.size()):
        if i != j:
          connection_map[source].append(files[j])
      
      # Connect to main files if not a main file itself
      if category != "main":
        for main_file in category_mappings["main"]:
          if not main_file in connection_map[source]:
            connection_map[source].append(main_file)
  
  return connection_map

# Generate a text report of all connections with hash symbols
func generate_hash_connection_report() -> String:
  var report = "# Snake Case File Connections\n\n"
  var connection_map = build_hash_connection_map()
  
  # Add section for each hash connector type
  for hash_symbol in hash_connectors:
    report += "## " + hash_symbol + " Connections\n\n"
    
    for source in connection_map:
      var source_hash = get_hash_connector(source)
      if source_hash != hash_symbol:
        continue
        
      report += "### " + source + " connects to:\n\n"
      
      for target in connection_map[source]:
        var connection = create_connection_string(source, target)
        report += "- " + connection + "\n"
      
      report += "\n"
  
  return report

# Save the connection report
func save_connection_report(path: String) -> bool:
  var report = generate_hash_connection_report()
  var file = FileAccess.open(path, FileAccess.WRITE)
  
  if file == null:
    return false
    
  file.store_string(report)
  file.close()
  return true

# Get all files in a category
func get_category_files(category: String) -> Array:
  if category in category_mappings:
    return category_mappings[category]
  return []

# Get file hash notation
func get_file_with_hash(file_name: String) -> String:
  var snake_case = file_name
  if not snake_case in claude_mappings.values():
    snake_case = translate_to_snake_case(file_name)
  
  var hash_symbol = get_hash_connector(snake_case)
  return hash_symbol + snake_case