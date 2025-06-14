class_name SiteMapController
extends Node

# References to subsystems
var connection_manager
var pathway_system
var evolution_system
var visualizer

# UI references
@export var info_panel: Control
@export var status_label: Label
@export var log_panel: Control

# System state
var initialized = false
var current_view = "galaxy"  # galaxy, list, file, tree
var selected_component = null
var log_entries = []

func _ready():
	# Initialize all systems
	initialize_systems()
	
	# Set up UI
	setup_ui()
	
	# Connect signals
	connect_signals()

func initialize_systems():
	# Create the connection manager
	connection_manager = WebsiteConnectionManager.new()
	add_child(connection_manager)
	
	# Create the pathway system
	pathway_system = PathwaySystem.new()
	pathway_system.connection_manager = connection_manager
	add_child(pathway_system)
	
	# Create the evolution system
	evolution_system = EvolutionSystem.new()
	evolution_system.connection_manager = connection_manager
	evolution_system.pathway_system = pathway_system
	add_child(evolution_system)
	
	# Create the visualizer
	visualizer = GalaxyConnectionVisualizer.new()
	visualizer.connection_manager = connection_manager
	add_child(visualizer)
	
	initialized = true
	log_message("All systems initialized")

func setup_ui():
	# Set up view buttons
	var galaxy_btn = $ViewControls/GalaxyButton
	var list_btn = $ViewControls/ListButton
	var file_btn = $ViewControls/FileButton
	var tree_btn = $ViewControls/TreeButton
	
	if galaxy_btn:
		galaxy_btn.connect("pressed", Callable(self, "set_view").bind("galaxy"))
	if list_btn:
		list_btn.connect("pressed", Callable(self, "set_view").bind("list"))
	if file_btn:
		file_btn.connect("pressed", Callable(self, "set_view").bind("file"))
	if tree_btn:
		tree_btn.connect("pressed", Callable(self, "set_view").bind("tree"))
	
	# Initialize the info panel
	update_info_panel(null)

func connect_signals():
	# Connect component-related signals
	visualizer.connect("node_selected", Callable(self, "_on_node_selected"))
	connection_manager.connect("component_navigated", Callable(self, "_on_component_navigated"))
	connection_manager.connect("data_transferred", Callable(self, "_on_data_transferred"))
	
	# Connect pathway-related signals
	pathway_system.connect("pathway_established", Callable(self, "_on_pathway_established"))
	pathway_system.connect("pathway_traversed", Callable(self, "_on_pathway_traversed"))
	
	# Connect evolution-related signals
	evolution_system.connect("component_evolved", Callable(self, "_on_component_evolved"))
	evolution_system.connect("pathway_evolved", Callable(self, "_on_pathway_evolved"))

func set_view(view_type):
	current_view = view_type
	
	# Update UI to reflect current view
	match view_type:
		"galaxy":
			visualizer.visible = true
			$ListView.visible = false
			$FileView.visible = false
			$TreeView.visible = false
		"list":
			visualizer.visible = false
			$ListView.visible = true
			$FileView.visible = false
			$TreeView.visible = false
			update_list_view()
		"file":
			visualizer.visible = false
			$ListView.visible = false
			$FileView.visible = true
			$TreeView.visible = false
			update_file_view()
		"tree":
			visualizer.visible = false
			$ListView.visible = false
			$FileView.visible = false
			$TreeView.visible = true
			update_tree_view()
	
	log_message("View changed to: " + view_type)

func update_list_view():
	var list_container = $ListView/Container
	if not list_container:
		return
	
	# Clear existing children
	for child in list_container.get_children():
		child.queue_free()
	
	# Add each component to the list
	for component_type in connection_manager.components:
		var component = connection_manager.components[component_type]
		
		var item = HBoxContainer.new()
		
		var icon = TextureRect.new()
		# Set icon based on component type
		# icon.texture = load("res://icons/" + component["id"] + ".png")
		item.add_child(icon)
		
		var name_label = Label.new()
		name_label.text = component["name"]
		item.add_child(name_label)
		
		var path_label = Label.new()
		path_label.text = component["entry_point"]
		item.add_child(path_label)
		
		var button = Button.new()
		button.text = "Open"
		button.connect("pressed", Callable(self, "_on_component_button_pressed").bind(component_type))
		item.add_child(button)
		
		list_container.add_child(item)

func update_file_view():
	# Similar to list view but focuses on file relationships
	pass

func update_tree_view():
	# Tree view shows hierarchical relationships
	pass

func update_info_panel(component_type):
	if not info_panel:
		return
	
	if component_type == null:
		info_panel.visible = false
		return
	
	info_panel.visible = true
	var component = connection_manager.components[component_type]
	
	# Update the info panel with component details
	var title_label = info_panel.get_node("VBoxContainer/TitleLabel")
	if title_label:
		title_label.text = component["name"]
	
	var path_label = info_panel.get_node("VBoxContainer/PathLabel")
	if path_label:
		path_label.text = "File: " + component["entry_point"]
	
	var api_label = info_panel.get_node("VBoxContainer/APILabel")
	if api_label:
		api_label.text = "API Endpoints: " + str(component["api_endpoints"].size())
	
	var handlers_label = info_panel.get_node("VBoxContainer/HandlersLabel")
	if handlers_label:
		handlers_label.text = "Data Handlers: " + str(component["data_handlers"].size())
	
	# Show evolution stage if it exists
	if "evolution_stage" in component:
		var stage_label = info_panel.get_node("VBoxContainer/StageLabel")
		if stage_label:
			var stage_name = ""
			match component["evolution_stage"]:
				EvolutionSystem.EvolutionStage.INITIALIZATION:
					stage_name = "Initialization"
				EvolutionSystem.EvolutionStage.EXPANSION:
					stage_name = "Expansion"
				EvolutionSystem.EvolutionStage.OPTIMIZATION:
					stage_name = "Optimization"
				EvolutionSystem.EvolutionStage.MUTATION:
					stage_name = "Mutation"
			
			stage_label.text = "Evolution Stage: " + stage_name
	
	# Add button to navigate to component
	var nav_button = info_panel.get_node("VBoxContainer/NavButton")
	if nav_button:
		nav_button.text = "Open " + component["name"]
		# Disconnect existing connections to avoid multiple calls
		if nav_button.is_connected("pressed", Callable(self, "_on_nav_button_pressed")):
			nav_button.disconnect("pressed", Callable(self, "_on_nav_button_pressed"))
		
		nav_button.connect("pressed", Callable(self, "_on_nav_button_pressed").bind(component_type))

func _on_node_selected(component_type):
	selected_component = component_type
	update_info_panel(component_type)

func _on_component_navigated(from_component, to_component):
	log_message("Navigated from " + (connection_manager.components[from_component]["name"] if from_component != null else "none") + 
				" to " + connection_manager.components[to_component]["name"])
	
	# If pathway system exists, record this navigation
	if pathway_system and from_component != null:
		pathway_system.traverse_pathway(
			connection_manager.components[from_component]["id"],
			connection_manager.components[to_component]["id"]
		)

func _on_data_transferred(from_component, to_component, data):
	log_message("Data transferred from " + connection_manager.components[from_component]["name"] + 
				" to " + connection_manager.components[to_component]["name"])

func _on_pathway_established(from_id, to_id, path_type):
	# Get component names from IDs
	var from_name = "Unknown"
	var to_name = "Unknown"
	
	for component_type in connection_manager.components:
		if connection_manager.components[component_type]["id"] == from_id:
			from_name = connection_manager.components[component_type]["name"]
		if connection_manager.components[component_type]["id"] == to_id:
			to_name = connection_manager.components[component_type]["name"]
	
	var type_name = ""
	match path_type:
		PathwaySystem.PathwayType.DATA_PATH:
			type_name = "Data"
		PathwaySystem.PathwayType.NAVIGATION_PATH:
			type_name = "Navigation"
		PathwaySystem.PathwayType.COMPONENT_PATH:
			type_name = "Component"
		PathwaySystem.PathwayType.FILE_PATH:
			type_name = "File"
	
	log_message("Established " + type_name + " pathway from " + from_name + " to " + to_name)

func _on_pathway_traversed(path_id, data):
	log_message("Pathway traversed: " + path_id)

func _on_component_evolved(component_id, stage, changes):
	var component_name = "Unknown"
	
	for component_type in connection_manager.components:
		if connection_manager.components[component_type]["id"] == component_id:
			component_name = connection_manager.components[component_type]["name"]
			break
	
	var stage_name = ""
	match stage:
		EvolutionSystem.EvolutionStage.INITIALIZATION:
			stage_name = "Initialization"
		EvolutionSystem.EvolutionStage.EXPANSION:
			stage_name = "Expansion"
		EvolutionSystem.EvolutionStage.OPTIMIZATION:
			stage_name = "Optimization"
		EvolutionSystem.EvolutionStage.MUTATION:
			stage_name = "Mutation"
	
	log_message("Component evolved: " + component_name + " (Stage: " + stage_name + ")")
	
	# Update visualizer to show changes
	visualizer.queue_redraw()
	
	# Update info panel if this component is selected
	for component_type in connection_manager.components:
		if connection_manager.components[component_type]["id"] == component_id and component_type == selected_component:
			update_info_panel(component_type)
			break

func _on_pathway_evolved(pathway_id, changes):
	log_message("Pathway evolved: " + pathway_id)

func _on_nav_button_pressed(component_type):
	connection_manager.navigate_to_component(component_type)

func _on_component_button_pressed(component_type):
	connection_manager.navigate_to_component(component_type)

func log_message(message):
	print(message)
	
	# Add to log entries
	log_entries.append({
		"timestamp": Time.get_datetime_string_from_system(),
		"message": message
	})
	
	# Update log panel if it exists
	if log_panel:
		var log_text = log_panel.get_node("LogText")
		if log_text:
			var log_content = ""
			
			# Show last 10 log entries
			var start_idx = max(0, log_entries.size() - 10)
			for i in range(start_idx, log_entries.size()):
				var entry = log_entries[i]
				log_content += "[" + entry["timestamp"] + "] " + entry["message"] + "\n"
			
			log_text.text = log_content
	
	# Update status label if it exists
	if status_label:
		status_label.text = message
