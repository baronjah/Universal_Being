extends Node
class_name FileConnectionSystem

# File connection system for Claude integration
# Connects all claude-related files with snake_case naming

# Main file connections
var file_connections = {
  # Main system files
  "main_controller": "/mnt/c/Users/Percision 15/12_turns_system/main.gd",
  "desktop_main": "/mnt/c/Users/Percision 15/Desktop/main.gd",
  
  # Claude core files
  "claude_config": "/mnt/c/Users/Percision 15/CLAUDE.md",
  "claude_akashic_bridge": "/mnt/c/Users/Percision 15/12_turns_system/claude_akashic_bridge.gd",
  "claude_akashic_demo": "/mnt/c/Users/Percision 15/12_turns_system/claude_akashic_demo.gd",
  "claude_terminal_interface": "/mnt/c/Users/Percision 15/12_turns_system/claude_terminal_interface.sh",
  "claude_ethereal_bridge": "/mnt/c/Users/Percision 15/12_turns_system/claude_ethereal_bridge.gd",
  "claude_integration_bridge": "/mnt/c/Users/Percision 15/12_turns_system/claude_integration_bridge.gd",
  "claude_wsl_config": "/mnt/c/Users/Percision 15/Desktop/wsl claude.txt",
  
  # Memory system files
  "word_memory_system": "/mnt/c/Users/Percision 15/word_memory_system.gd",
  "divine_memory_system": "/mnt/c/Users/Percision 15/12_turns_system/divine_memory_system.sh",
  "memory_investment_system": "/mnt/c/Users/Percision 15/12_turns_system/memory_investment_system.gd",
  "dimensional_memory_integration": "/mnt/c/Users/Percision 15/dimensional_memory_integration.gd",
  "dimensional_memory_splitter": "/mnt/c/Users/Percision 15/dimensional_memory_splitter.gd",
  "terminal_memory_system": "/mnt/c/Users/Percision 15/12_turns_system/terminal_memory_system.gd",
  "project_memory_system": "/mnt/c/Users/Percision 15/12_turns_system/project_memory_system.gd",
  "memory_manager": "/mnt/c/Users/Percision 15/Desktop/memory_manager.gd",
  "memory_drive_connector": "/mnt/c/Users/Percision 15/Desktop/memory_drive_connector.gd",
  
  # 3D Notepad files
  "notepad_3d_html": "/mnt/c/Users/Percision 15/12_turns_system/3d_notepad.html",
  "notepad_3d_readme": "/mnt/c/Users/Percision 15/12_turns_system/NOTEPAD3D_README.md",
  "notepad_3d_visualizer": "/mnt/c/Users/Percision 15/12_turns_system/notepad3d_visualizer.gd",
  "notepad_3d_manifesto": "/mnt/c/Users/Percision 15/12_turns_system/notepad3d_manifesto.md",
  
  # Datapoint files
  "datapoint_js": "/mnt/c/Users/Percision 15/Downloads/datapoint-js.txt",
  "terminal_datapoint_handlers": "/mnt/c/Users/Percision 15/Downloads/terminal-datapoint-handlers.txt",
  
  # Container files (custom containers for the system)
  "data_container_system": "/mnt/c/Users/Percision 15/12_turns_system/data_container_system.gd",
  
  # Archive files
  "memory_archive_system": "/mnt/c/Users/Percision 15/12_turns_system/memory_archive_system.gd",
  "past_memory_archive": "/mnt/c/Users/Percision 15/12_turns_system/past_memory_archive.gd"
}

# Logical groupings of files
var file_groups = {
  "claude_core": [
    "claude_config",
    "claude_akashic_bridge",
    "claude_akashic_demo",
    "claude_terminal_interface",
    "claude_ethereal_bridge",
    "claude_integration_bridge"
  ],
  
  "memory_systems": [
    "word_memory_system",
    "divine_memory_system",
    "memory_investment_system", 
    "dimensional_memory_integration",
    "dimensional_memory_splitter",
    "terminal_memory_system",
    "project_memory_system",
    "memory_manager",
    "memory_drive_connector",
    "memory_archive_system",
    "past_memory_archive"
  ],
  
  "notepad_3d": [
    "notepad_3d_html",
    "notepad_3d_readme",
    "notepad_3d_visualizer",
    "notepad_3d_manifesto"
  ],
  
  "datapoint_systems": [
    "datapoint_js",
    "terminal_datapoint_handlers",
    "data_container_system"
  ],
  
  "main_controllers": [
    "main_controller",
    "desktop_main"
  ]
}

# Connection links between files - directional links showing which files reference others
var file_connections_map = {
  "claude_integration_bridge": ["claude_akashic_bridge", "claude_ethereal_bridge", "claude_terminal_interface"],
  "claude_akashic_bridge": ["word_memory_system", "memory_investment_system"],
  "claude_ethereal_bridge": ["dimensional_memory_integration", "project_memory_system"],
  "memory_manager": ["memory_drive_connector", "word_memory_system", "dimensional_memory_splitter"],
  "notepad_3d_visualizer": ["memory_manager", "datapoint_js"],
  "main_controller": ["claude_integration_bridge", "memory_manager", "notepad_3d_visualizer"]
}

# Initialize the system
func _ready():
  print("File Connection System initialized")
  print("Found " + str(file_connections.size()) + " files in the system")
  
  # Check which files actually exist
  _verify_file_existence()

# Verify that the files exist
func _verify_file_existence():
  var existing_files = 0
  var missing_files = []
  
  for key in file_connections:
    var file_path = file_connections[key]
    var file = FileAccess.open(file_path, FileAccess.READ)
    
    if file != null:
      existing_files += 1
      file.close()
    else:
      missing_files.append(key)
  
  print("Found " + str(existing_files) + " existing files")
  if missing_files.size() > 0:
    print("Missing " + str(missing_files.size()) + " files: " + str(missing_files))

# Get a file path by its snake_case key
func get_file_path(key: String) -> String:
  if key in file_connections:
    return file_connections[key]
  return ""

# Get all files in a group
func get_group_files(group: String) -> Array:
  if group in file_groups:
    var result = []
    for key in file_groups[group]:
      result.append(file_connections[key])
    return result
  return []

# Get files that connect to a specific file
func get_connections_to(key: String) -> Array:
  var result = []
  for source in file_connections_map:
    if key in file_connections_map[source]:
      result.append(source)
  return result

# Check if a file is connected to another
func is_connected_to(source: String, target: String) -> bool:
  if source in file_connections_map:
    return target in file_connections_map[source]
  return false

# Load content from a file
func load_file_content(key: String) -> String:
  var file_path = get_file_path(key)
  if file_path.is_empty():
    return ""
    
  var file = FileAccess.open(file_path, FileAccess.READ)
  if file == null:
    return ""
    
  var content = file.get_as_text()
  file.close()
  return content

# Create a visual representation of the file connections
func create_connection_visualization() -> String:
  var result = "digraph FileConnections {\n"
  
  # Add nodes by group
  for group in file_groups:
    result += "  subgraph cluster_" + group + " {\n"
    result += "    label=\"" + group + "\";\n"
    
    for key in file_groups[group]:
      result += "    \"" + key + "\";\n"
    
    result += "  }\n\n"
  
  # Add connections
  for source in file_connections_map:
    for target in file_connections_map[source]:
      result += "  \"" + source + "\" -> \"" + target + "\";\n"
  
  result += "}\n"
  return result

# Generate a markdown report of the file system
func generate_markdown_report() -> String:
  var report = "# Claude File Connection System\n\n"
  
  # Overview
  report += "## Overview\n\n"
  report += "Total files: " + str(file_connections.size()) + "\n"
  report += "File groups: " + str(file_groups.size()) + "\n\n"
  
  # Groups
  report += "## File Groups\n\n"
  for group in file_groups:
    report += "### " + group + "\n\n"
    for key in file_groups[group]:
      var file_path = file_connections[key]
      report += "- **" + key + "**: `" + file_path + "`\n"
    report += "\n"
  
  # Connections
  report += "## File Connections\n\n"
  for source in file_connections_map:
    report += "### " + source + " connects to:\n\n"
    for target in file_connections_map[source]:
      report += "- " + target + "\n"
    report += "\n"
  
  return report

# Save the markdown report
func save_markdown_report(path: String) -> bool:
  var report = generate_markdown_report()
  var file = FileAccess.open(path, FileAccess.WRITE)
  
  if file == null:
    return false
    
  file.store_string(report)
  file.close()
  return true

# Save the visualization dot file
func save_visualization(path: String) -> bool:
  var visualization = create_connection_visualization()
  var file = FileAccess.open(path, FileAccess.WRITE)
  
  if file == null:
    return false
    
  file.store_string(visualization)
  file.close()
  return true