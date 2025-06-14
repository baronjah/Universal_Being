extends Node

# Example usage of the Unified Project Connector System
# This file demonstrates how to use the system to connect different project components

# Load required scripts
const ProjectLoader = preload("project_loader.gd")
const UnifiedProjectConnector = preload("unified_project_connector.gd")
const TokenAnalyzer = preload("token_analyzer.gd")
const ProjectLinker = preload("project_linker.gd")
const ProjectConnectionVisualizer = preload("project_connection_visualizer.gd")

# Instances
var loader = null
var connector = null
var analyzer = null
var linker = null
var visualizer = null

func _ready():
	# Simple usage with the loader
	simple_example()
	
	# Advanced usage with direct component access
	advanced_example()

# Simple usage example with ProjectLoader
func simple_example():
	print("\n=== SIMPLE EXAMPLE ===\n")
	
	# Create the loader
	loader = ProjectLoader.new()
	
	# Connect all projects with automatic linking
	loader.connect_all_projects(true)
	
	# Export visualization
	loader.export_visualization()
	
	# Get a summary
	var summary = loader.get_connection_summary()
	print("Connected " + str(summary.connections.total) + " components across " + 
		  str(summary.projects.size()) + " projects")
	
	# Find specific components
	var color_systems = loader.find_components(
		UnifiedProjectConnector.MatchCriteria.NAME_PATTERN,
		"*color*system*"
	)
	
	print("Found " + str(color_systems.size()) + " color systems")
	
	# Transfer data between color systems if found
	if color_systems.size() >= 2:
		var source_id = color_systems[0]
		var target_id = color_systems[1]
		
		var color_data = {
			"primary_color": Color(0.2, 0.7, 1.0),
			"secondary_color": Color(1.0, 0.4, 0.2)
		}
		
		loader.transfer_data(source_id, target_id, color_data)
		print("Transferred color data from " + source_id + " to " + target_id)
	
	print("\nSimple example complete\n")

# Advanced usage example with direct component access
func advanced_example():
	print("\n=== ADVANCED EXAMPLE ===\n")
	
	# Create components manually
	connector = UnifiedProjectConnector.new()
	analyzer = TokenAnalyzer.new()
	linker = ProjectLinker.new(connector, analyzer)
	visualizer = ProjectConnectionVisualizer.new()
	
	# Register some components manually
	var dimensional_color_system_12 = connector.register_component(
		"12_turns_system",
		"dimensional_color_system.gd", 
		"script",
		{"domain": "visualization"}
	)
	
	var dimensional_color_system_eden = connector.register_component(
		"Eden_OS",
		"dimensional_color_system.gd", 
		"script",
		{"domain": "visualization"}
	)
	
	var multi_core_system = connector.register_component(
		"LuminusOS",
		"scripts/multi_core_system.gd", 
		"script",
		{"domain": "processing"}
	)
	
	var universal_connector = connector.register_component(
		"12_turns_system",
		"universal_connector.gd", 
		"script",
		{"domain": "connection"}
	)
	
	# Create connections manually
	connector.connect_components(
		dimensional_color_system_12,
		dimensional_color_system_eden,
		connector.ConnectionType.VARIABLE_MIRROR,
		{
			"variables": ["color_values", "color_properties"],
			"bidirectional": true
		}
	)
	
	connector.connect_components(
		universal_connector,
		multi_core_system,
		connector.ConnectionType.SYSTEM_LINK,
		{
			"interaction_mode": "proxy"
		}
	)
	
	# Scan for more components
	var terminal_components = connector.find_components(
		connector.MatchCriteria.NAME_PATTERN,
		"*terminal*"
	)
	
	print("Found " + str(terminal_components.size()) + " terminal components")
	
	# Find name-based connection candidates
	var candidates = connector.get_name_based_connection_candidates()
	print("Found " + str(candidates.size()) + " name-based connection candidates")
	
	# Connect the visualizer
	visualizer.connect_to_connector(connector)
	
	# Export visualizations
	visualizer.export_html_visualization("/mnt/c/Users/Percision 15/advanced_connections.html")
	
	print("\nAdvanced example complete\n")

# Example of connecting similar components across all projects
func connect_similar_components():
	# Create the connector if not already created
	if connector == null:
		connector = UnifiedProjectConnector.new()
	
	# Scan projects
	connector._scan_projects()
	
	# Find components by domain
	var memory_components = connector.find_components(
		connector.MatchCriteria.SEMANTIC_DOMAIN,
		"memory"
	)
	
	var visualization_components = connector.find_components(
		connector.MatchCriteria.SEMANTIC_DOMAIN,
		"visualization"
	)
	
	var processing_components = connector.find_components(
		connector.MatchCriteria.SEMANTIC_DOMAIN,
		"processing"
	)
	
	# Connect within domains
	print("Connecting memory components...")
	_connect_components_in_group(memory_components, connector.ConnectionType.VARIABLE_MIRROR)
	
	print("Connecting visualization components...")
	_connect_components_in_group(visualization_components, connector.ConnectionType.VARIABLE_MIRROR)
	
	print("Connecting processing components...")
	_connect_components_in_group(processing_components, connector.ConnectionType.SYSTEM_LINK)
	
	print("Connected components by domain")

# Helper to connect components within a group
func _connect_components_in_group(component_ids, connection_type):
	for i in range(component_ids.size()):
		for j in range(i+1, component_ids.size()):
			var source_id = component_ids[i]
			var target_id = component_ids[j]
			
			# Only connect if from different projects
			var source_project = source_id.split("::")[0]
			var target_project = target_id.split("::")[0]
			
			if source_project != target_project:
				connector.connect_components(source_id, target_id, connection_type)
				print("Connected " + source_id + " to " + target_id)

# Example of tokenizing and comparing files
func tokenize_example():
	# Create analyzer if not already created
	if analyzer == null:
		analyzer = TokenAnalyzer.new()
	
	# Tokenize a file with different strategies
	var file_path = "/mnt/c/Users/Percision 15/12_turns_system/dimensional_color_system.gd"
	
	# Code tokens
	var code_tokens = analyzer.tokenize_file(file_path, analyzer.TokenStrategy.CODE_TOKENS)
	print("Found " + str(code_tokens.size()) + " code tokens")
	
	# Function names
	var function_tokens = analyzer.tokenize_file(file_path, analyzer.TokenStrategy.FUNCTION_NAMES)
	print("Found " + str(function_tokens.size()) + " function tokens")
	
	# Variable names
	var variable_tokens = analyzer.tokenize_file(file_path, analyzer.TokenStrategy.VARIABLE_NAMES)
	print("Found " + str(variable_tokens.size()) + " variable tokens")
	
	# Analyze token frequencies
	var file = File.new()
	if file.open(file_path, File.READ) == OK:
		var content = file.get_as_text()
		file.close()
		
		var frequencies = analyzer.analyze_token_frequencies(content)
		
		# Print top 10 most frequent tokens
		var sorted_tokens = []
		for token in frequencies:
			sorted_tokens.append({"token": token, "frequency": frequencies[token]})
		
		sorted_tokens.sort_custom(self, "_sort_by_frequency")
		
		print("Top 10 most frequent tokens:")
		for i in range(min(10, sorted_tokens.size())):
			print(sorted_tokens[i].token + ": " + str(sorted_tokens[i].frequency))
	
	print("Tokenization example complete")

# Sort helper for token frequencies
func _sort_by_frequency(a, b):
	return a.frequency > b.frequency