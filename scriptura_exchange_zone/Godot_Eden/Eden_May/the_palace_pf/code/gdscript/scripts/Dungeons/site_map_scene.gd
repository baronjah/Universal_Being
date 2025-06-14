extends Node2D

@export var connection_manager: WebsiteConnectionManager
@export var galaxy_visualizer: GalaxyConnectionVisualizer
@export var info_panel: PanelContainer

func _ready():
	# Initialize the system
	initialize_system()
	
	# Connect signals
	galaxy_visualizer.connect("node_selected", Callable(self, "_on_node_selected"))
	galaxy_visualizer.connect("node_hover", Callable(self, "_on_node_hover"))

func initialize_system():
	# Ensure the connection manager is ready
	if not connection_manager:
		connection_manager = WebsiteConnectionManager.new()
		add_child(connection_manager)
	
	# Set up the galaxy visualizer if not already assigned
	if not galaxy_visualizer:
		galaxy_visualizer = GalaxyConnectionVisualizer.new()
		galaxy_visualizer.connection_manager = connection_manager
		add_child(galaxy_visualizer)
	
	# Initialize with JSH Ethereal Engine as active
	connection_manager.navigate_to_component(WebsiteConnectionManager.ComponentType.JSH_ETHEREAL_ENGINE)

func _on_node_selected(component_type):
	update_info_panel(component_type)

func _on_node_hover(component_type):
	# Show tooltip or hover info
	if component_type != null:
		# Show component name in status bar
		var status_label = $StatusBar/Label
		if status_label:
			status_label.text = "Hover: " + connection_manager.components[component_type]["name"]

func update_info_panel(component_type):
	if not info_panel or component_type == null:
		return
	
	var component = connection_manager.components[component_type]
	
	# Update the info panel with component details
	var title_label = info_panel.get_node("VBoxContainer/TitleLabel")
	var description_label = info_panel.get_node("VBoxContainer/DescriptionLabel")
	var path_label = info_panel.get_node("VBoxContainer/PathLabel")
	var connections_container = info_panel.get_node("VBoxContainer/ConnectionsContainer")
	
	if title_label:
		title_label.text = component["name"]
	
	if description_label:
		description_label.text = "Entry Point: " + component["entry_point"]
	
	if path_label:
		path_label.text = "Path: " + component["path"]
	
	# Update connections list
	if connections_container:
		# Clear existing children
		for child in connections_container.get_children():
			child.queue_free()
		
		# Add heading
		var heading = Label.new()
		heading.text = "Connections:"
		heading.add_theme_font_size_override("font_size", 14)
		heading.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		connections_container.add_child(heading)
		
		# Find all connections
		var found_connections = []
		for conn in connection_manager.connections:
			if conn["from"] == component_type:
				var target = connection_manager.components[conn["to"]]["name"]
				var type_name = "Data Flow"
				match conn["type"]:

					WebsiteConnectionManager.ConnectionType.NAVIGATION:
						type_name = "Navigation"
					WebsiteConnectionManager.ConnectionType.DEPENDENCY:
						type_name = "Dependency"
					WebsiteConnectionManager.ConnectionType.API_CALL:
						type_name = "API Call"
				
				found_connections.append({
					"target": target,
					"type": type_name,
					"active": conn["active"]
				})
			elif conn["to"] == component_type:
				var source = connection_manager.components[conn["from"]]["name"]
				var type_name = "Data Flow"
				match conn["type"]:
					WebsiteConnectionManager.ConnectionType.NAVIGATION:
						type_name = "Navigation"
					WebsiteConnectionManager.ConnectionType.DEPENDENCY:
						type_name = "Dependency"
					WebsiteConnectionManager.ConnectionType.API_CALL:
						type_name = "API Call"
				
				found_connections.append({
					"source": source,
					"type": type_name,
					"active": conn["active"]
				})
		
		# Add connections to the list
		for conn_data in found_connections:
			var conn_label = Label.new()
			if "target" in conn_data:
				conn_label.text = "→ " + conn_data["target"] + " (" + conn_data["type"] + ")"
			else:
				conn_label.text = "← " + conn_data["source"] + " (" + conn_data["type"] + ")"
			
			# Set color based on connection status
			if conn_data["active"]:
				conn_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))  # Green for active
			else:
				conn_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))  # Red for inactive
			
			connections_container.add_child(conn_label)
		
		# Add navigation button
		var nav_button = Button.new()
		nav_button.text = "Open " + component["name"]
		nav_button.custom_minimum_size = Vector2(100, 30)
		nav_button.connect("pressed", Callable(self, "_on_nav_button_pressed").bind(component_type))
		connections_container.add_child(nav_button)

func _on_nav_button_pressed(component_type):
	var entry_point = connection_manager.navigate_to_component(component_type)
	
	# In a real web implementation, you'd do something like:
	# OS.shell_open(entry_point)
	
	# For now, just log it
	print("Opening: ", entry_point)
