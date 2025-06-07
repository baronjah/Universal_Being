extends Node
# Example usage of the Claude file integration system

func _ready():
  print("Starting Claude file integration example...")
  
  # Create the integrator
  var integrator = ClaudeFileIntegrator.new()
  add_child(integrator)
  
  # Wait for initialization to complete
  await get_tree().process_frame
  
  # Get summary of integration
  var summary = integrator.get_integration_summary()
  print("\nIntegration Summary:\n" + summary)
  
  # Get files with hash symbols
  var files_with_hash = integrator.get_files_with_hash_symbols()
  print("\nFiles with hash symbols:")
  for file in files_with_hash:
    print("- " + file)
  
  # Generate hash visual map
  var hash_map = integrator.generate_hash_visual_map()
  print("\nHash Visual Map:\n" + hash_map)
  
  # Example: Initialize files for a specific category
  var category = "main"
  print("\nInitializing files for category '" + category + "':")
  integrator.initialize_category_files(category)
  
  # Example: Get connections for a specific file
  var file_name = "claude_integration_main"
  var connections = integrator.snake_case_translator.get_connections_to(file_name)
  print("\nConnections to '" + file_name + "':")
  for connection in connections:
    print("- " + connection)
  
  print("\nExample completed!")

# Run the example
func run_example():
  _ready()