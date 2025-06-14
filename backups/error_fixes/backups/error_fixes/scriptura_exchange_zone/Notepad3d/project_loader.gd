extends Node

class_name ProjectLoader

# Project Loader System
# Provides a simple interface to load and connect multiple projects

# Dependencies (assumed to be in the same directory)
const CONNECTOR_SCRIPT = "unified_project_connector.gd"
const ANALYZER_SCRIPT = "token_analyzer.gd"
const LINKER_SCRIPT = "project_linker.gd"
const VISUALIZER_SCRIPT = "project_connection_visualizer.gd"

# Components
var connector = null
var analyzer = null
var linker = null
var visualizer = null

# Project settings
var projects = {
	"12_turns_system": "/mnt/c/Users/Percision 15/12_turns_system",
	"LuminusOS": "/mnt/c/Users/Percision 15/LuminusOS",
	"Eden_OS": "/mnt/c/Users/Percision 15/Eden_OS",
	"Godot_Eden": "/mnt/c/Users/Percision 15/Godot_Eden"
}

# Initialization status
var is_initialized = false

# Signals
signal initialization_complete()
signal project_connected(project_name)
signal connection_created(source_id, target_id, connection_type)

func _ready():
	initialize()

# Initialize the system
func initialize():
	print("Initializing Project Loader...")
	
	# Load scripts
	var connector_script = load_script(CONNECTOR_SCRIPT)
	var analyzer_script = load_script(ANALYZER_SCRIPT)
	var linker_script = load_script(LINKER_SCRIPT)
	var visualizer_script = load_script(VISUALIZER_SCRIPT)
	
	if not connector_script or not analyzer_script or not linker_script or not visualizer_script:
		push_error("Failed to load required scripts")
		return false
	
	# Create instances
	connector = connector_script.new()
	analyzer = analyzer_script.new()
	linker = linker_script.new(connector, analyzer)
	visualizer = visualizer_script.new()
	visualizer.connect_to_connector(connector)
	
	# Connect signals
	connector.connect("component_registered", self, "_on_component_registered")
	connector.connect("connection_established", self, "_on_connection_established")
	
	is_initialized = true
	emit_signal("initialization_complete")
	
	print("Project Loader initialized successfully")
	return true

# Connect all projects
func connect_all_projects(auto_link = true):
	if not is_initialized:
		push_error("System not initialized")
		return false
	
	print("Connecting all projects...")
	
	# Connector will scan and register components from all projects
	
	# Automatically link projects if requested
	if auto_link:
		linker.link_projects()
	
	print("All projects connected")
	return true

# Create a specific connection between components
func create_connection(source_component, target_component, connection_type):
	if not is_initialized:
		push_error("System not initialized")
		return false
	
	return connector.connect_components(source_component, target_component, connection_type)

# Get a summary of all connections
func get_connection_summary():
	if not is_initialized:
		push_error("System not initialized")
		return null
	
	var topology = connector.get_connection_topology()
	
	var summary = {
		"projects": {},
		"connections": {
			"total": 0,
			"by_type": {},
			"cross_project": 0
		}
	}
	
	# Project stats
	for project_name in topology.projects:
		var project_info = topology.projects[project_name]
		summary.projects[project_name] = {
			"components": project_info.component_count,
			"connections": project_info.connection_count
		}
	
	# Connection stats
	for connection_id in topology.connections:
		var connection = topology.connections[connection_id]
		summary.connections.total += 1
		
		# Count by type
		var connection_type = connection.type
		if not summary.connections.by_type.has(connection_type):
			summary.connections.by_type[connection_type] = 0
		summary.connections.by_type[connection_type] += 1
		
		# Check if cross-project
		var source_project = null
		var target_project = null
		
		for component_id in topology.components:
			if component_id == connection.source:
				source_project = topology.components[component_id].project
			elif component_id == connection.target:
				target_project = topology.components[component_id].project
		
		if source_project != null and target_project != null and source_project != target_project:
			summary.connections.cross_project += 1
	
	return summary

# Export visualization to HTML
func export_visualization(output_path = "/mnt/c/Users/Percision 15/project_connections.html"):
	if not is_initialized:
		push_error("System not initialized")
		return null
	
	return visualizer.export_html_visualization(output_path)

# Get components matching criteria
func find_components(criteria, value, project_filter = null):
	if not is_initialized:
		push_error("System not initialized")
		return []
	
	return connector.find_components(criteria, value, project_filter)

# Transfer data between components
func transfer_data(source_id, target_id, data, channel = "default"):
	if not is_initialized:
		push_error("System not initialized")
		return null
	
	return connector.transfer_data(source_id, target_id, data, channel)

# Helper functions

func load_script(script_name):
	var script_path = OS.get_executable_path().get_base_dir() + "/" + script_name
	
	if not File.new().file_exists(script_path):
		push_error("Script file not found: " + script_path)
		return null
	
	var script = load(script_path)
	if script == null:
		push_error("Failed to load script: " + script_path)
		return null
	
	return script

# Signal handlers

func _on_component_registered(component_id, source_project):
	emit_signal("project_connected", source_project)

func _on_connection_established(source_id, target_id, connection_type):
	emit_signal("connection_created", source_id, target_id, connection_type)

# Simple usage example
func example_usage():
	# Initialize
	if not is_initialized:
		initialize()
	
	# Connect all projects
	connect_all_projects(true)
	
	# Get a summary
	var summary = get_connection_summary()
	print("Connected " + str(summary.connections.total) + " components across " + 
		  str(summary.projects.size()) + " projects")
	
	# Export visualization
	export_visualization()
	
	return summary