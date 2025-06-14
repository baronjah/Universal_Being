extends Node

# JSH Multiverse Initializer
# Handles initialization and integration of the multiverse navigation system
# with the JSH Ethereal Engine architecture

# Node Paths
export(NodePath) var multiverse_evolution_system_path
export(NodePath) var akashic_records_manager_path
export(NodePath) var player_controller_path
export(NodePath) var time_progression_system_path

# UI References
var multiverse_ui = null
var system_integration = null

# Autoload references
var multiverse_evolution_system = null
var akashic_records_manager = null 
var player_controller = null
var time_progression_system = null

# Configuration
export var auto_initialize = true
export var toggle_key = KEY_F8
export var log_to_console = true

# ========== Initialization ==========

func _ready():
	if auto_initialize:
		call_deferred("initialize")

# Initialize the multiverse navigation system
func initialize():
	print("JSH Multiverse Initializer: Starting initialization")
	
	# Set up system references
	setup_system_references()
	
	# Create system integration if needed
	if not system_integration:
		system_integration = load("res://multiverse_system_integration.gd").new()
		system_integration.name = "MultiverseSystemIntegration"
		add_child(system_integration)
	
	# Initialize system integration
	var result = system_integration.initialize(
		multiverse_evolution_system,
		akashic_records_manager,
		player_controller,
		time_progression_system
	)
	
	if not result:
		printerr("JSH Multiverse Initializer: Failed to initialize system integration")
		return false
	
	# Create UI
	create_multiverse_ui()
	
	# Connect signals
	connect_signals()
	
	print("JSH Multiverse Initializer: Initialization complete")
	return true

# Set up references to required systems
func setup_system_references():
	# Try to get from exported node paths
	if multiverse_evolution_system_path:
		multiverse_evolution_system = get_node(multiverse_evolution_system_path)
	
	if akashic_records_manager_path:
		akashic_records_manager = get_node(akashic_records_manager_path)
	
	if player_controller_path:
		player_controller = get_node(player_controller_path)
	
	if time_progression_system_path:
		time_progression_system = get_node(time_progression_system_path)
	
	# Fallback to autoloads
	if not multiverse_evolution_system:
		multiverse_evolution_system = get_node_or_null("/root/MultiverseEvolutionSystem")
	
	if not akashic_records_manager:
		akashic_records_manager = get_node_or_null("/root/AkashicRecordsManager")
	
	if not player_controller:
		player_controller = get_node_or_null("/root/JSHPlayerController")
	
	if not time_progression_system:
		time_progression_system = get_node_or_null("/root/TimeProgressionSystem")
	
	# Log available systems
	log_system_status()

# Log which systems are available
func log_system_status():
	if log_to_console:
		print("JSH Multiverse Initializer: Systems detected:")
		print("- Multiverse Evolution System: " + str(multiverse_evolution_system != null))
		print("- Akashic Records Manager: " + str(akashic_records_manager != null))
		print("- Player Controller: " + str(player_controller != null))
		print("- Time Progression System: " + str(time_progression_system != null))

# Create the multiverse navigation UI
func create_multiverse_ui():
	# Instance scene if available, otherwise create programmatically
	var ui_scene = load("res://multiverse_navigation_ui.tscn")
	
	if ui_scene:
		multiverse_ui = ui_scene.instance()
	else:
		# Create UI programmatically
		multiverse_ui = load("res://multiverse_navigation_ui.gd").new()
		
		# Set up basic UI structure
		setup_basic_ui_structure(multiverse_ui)
	
	multiverse_ui.name = "MultiverseNavigationUI"
	
	# Add to canvas layer for proper UI rendering
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "MultiverseUILayer"
	canvas_layer.layer = 10  # High layer to be on top
	add_child(canvas_layer)
	canvas_layer.add_child(multiverse_ui)
	
	# Connect UI to system integration
	multiverse_ui.connect_to_multiverse_system(system_integration)
	
	# Hide by default
	multiverse_ui.visible = false
	
	print("JSH Multiverse Initializer: UI created")

# Set up basic UI structure when creating programmatically
func setup_basic_ui_structure(ui):
	# Create basic UI structure if needed
	# This creates a minimal structure if the scene file doesn't exist
	
	# Universe Info Panel
	var universe_info_panel = Panel.new()
	universe_info_panel.name = "UniverseInfoPanel"
	universe_info_panel.anchor_right = 0.3
	universe_info_panel.anchor_bottom = 0.5
	ui.add_child(universe_info_panel)
	
	var universe_name = Label.new()
	universe_name.name = "UniverseName"
	universe_name.text = "Universe Name"
	universe_name.align = Label.ALIGN_CENTER
	universe_info_panel.add_child(universe_name)
	
	var properties_grid = GridContainer.new()
	properties_grid.name = "PropertiesGrid"
	properties_grid.columns = 2
	properties_grid.anchor_top = 0.1
	properties_grid.anchor_right = 1.0
	properties_grid.anchor_bottom = 1.0
	universe_info_panel.add_child(properties_grid)
	
	# Access Points Panel
	var access_points_panel = Panel.new()
	access_points_panel.name = "AccessPointsPanel"
	access_points_panel.anchor_left = 0.31
	access_points_panel.anchor_right = 0.7
	access_points_panel.anchor_bottom = 0.8
	ui.add_child(access_points_panel)
	
	var search_filter = LineEdit.new()
	search_filter.name = "SearchFilter"
	search_filter.placeholder_text = "Search access points..."
	search_filter.anchor_right = 1.0
	access_points_panel.add_child(search_filter)
	
	var scroll = ScrollContainer.new()
	scroll.name = "ScrollContainer"
	scroll.anchor_top = 0.07
	scroll.anchor_right = 1.0
	scroll.anchor_bottom = 0.9
	access_points_panel.add_child(scroll)
	
	var access_points_list = VBoxContainer.new()
	access_points_list.name = "AccessPointsList"
	access_points_list.anchor_right = 1.0
	access_points_list.anchor_bottom = 1.0
	scroll.add_child(access_points_list)
	
	var travel_button = Button.new()
	travel_button.name = "TravelButton"
	travel_button.text = "Travel to Selected Universe"
	travel_button.disabled = true
	travel_button.anchor_top = 0.92
	travel_button.anchor_right = 1.0
	travel_button.anchor_bottom = 1.0
	access_points_panel.add_child(travel_button)
	
	# Cosmic Progress
	var cosmic_progress = Control.new()
	cosmic_progress.name = "CosmicProgress"
	cosmic_progress.anchor_left = 0.71
	cosmic_progress.anchor_right = 1.0
	cosmic_progress.anchor_bottom = 0.3
	ui.add_child(cosmic_progress)
	
	var age_label = Label.new()
	age_label.name = "AgeLabel"
	age_label.text = "Cosmic Age: 0 - The Age of Formation"
	cosmic_progress.add_child(age_label)
	
	var turn_progress = ProgressBar.new()
	turn_progress.name = "TurnProgress"
	turn_progress.value = 50
	turn_progress.anchor_top = 0.2
	turn_progress.anchor_right = 1.0
	cosmic_progress.add_child(turn_progress)
	
	var metanarrative_progress = ProgressBar.new()
	metanarrative_progress.name = "MetanarrativeProgress"
	metanarrative_progress.value = 25
	metanarrative_progress.anchor_top = 0.4
	metanarrative_progress.anchor_right = 1.0
	cosmic_progress.add_child(metanarrative_progress)
	
	# Alignment View
	var alignment_view = Control.new()
	alignment_view.name = "AlignmentView"
	alignment_view.anchor_left = 0.71
	alignment_view.anchor_top = 0.31
	alignment_view.anchor_right = 1.0
	alignment_view.anchor_bottom = 0.8
	ui.add_child(alignment_view)
	
	var alignment_viz = TextureRect.new()
	alignment_viz.name = "AlignmentVisualization"
	alignment_viz.anchor_right = 1.0
	alignment_viz.anchor_bottom = 1.0
	alignment_viz.expand = true
	alignment_view.add_child(alignment_viz)
	
	# Quick Travel Bar
	var quick_travel_bar = HBoxContainer.new()
	quick_travel_bar.name = "QuickTravelBar"
	quick_travel_bar.anchor_top = 0.81
	quick_travel_bar.anchor_right = 1.0
	quick_travel_bar.anchor_bottom = 0.9
	quick_travel_bar.alignment = BoxContainer.ALIGN_CENTER
	ui.add_child(quick_travel_bar)

# Connect signals for system integration
func connect_signals():
	# Connect input events for toggling UI
	set_process_input(true)
	
	# Connect to system integration signals
	system_integration.connect("universe_changed", self, "_on_universe_changed")
	system_integration.connect("access_point_discovered", self, "_on_access_point_discovered")
	system_integration.connect("cosmic_turn_advanced", self, "_on_cosmic_turn_advanced")
	
	# Connect to player controller signals if available
	if player_controller:
		player_controller.connect("movement_mode_changed", self, "_on_movement_mode_changed")
	
	print("JSH Multiverse Initializer: Signals connected")

# ========== Input Handling ==========

func _input(event):
	if event is InputEventKey and event.pressed and event.scancode == toggle_key:
		toggle_multiverse_ui()

# Toggle UI visibility
func toggle_multiverse_ui():
	if multiverse_ui:
		multiverse_ui.toggle_visibility()

# ========== Signal Handlers ==========

func _on_universe_changed(old_universe_id, new_universe_id):
	if log_to_console:
		print("JSH Multiverse: Traveled from " + old_universe_id + " to " + new_universe_id)
		
	# Update player controller if available
	if player_controller:
		player_controller.set_current_universe(new_universe_id)
	
	# Record in akashic records if available
	if akashic_records_manager:
		akashic_records_manager.record_event("universe_travel", {
			"from": old_universe_id,
			"to": new_universe_id,
			"timestamp": OS.get_unix_time()
		})

func _on_access_point_discovered(access_point):
	if log_to_console:
		print("JSH Multiverse: Discovered new access point to " + access_point.target_universe.name)
	
	# Record in akashic records if available
	if akashic_records_manager:
		akashic_records_manager.record_event("access_point_discovered", {
			"target_universe": access_point.target_universe.name,
			"stability": access_point.stability,
			"timestamp": OS.get_unix_time()
		})

func _on_cosmic_turn_advanced(turn_data):
	if log_to_console:
		print("JSH Multiverse: Advanced to Cosmic Turn " + str(turn_data.turn) + 
			  " in Age " + str(turn_data.age))
	
	# Notify time progression system if available
	if time_progression_system:
		time_progression_system.set_cosmic_turn(turn_data.turn)
	
	# Record in akashic records if available
	if akashic_records_manager:
		akashic_records_manager.record_event("cosmic_turn_advanced", {
			"turn": turn_data.turn,
			"age": turn_data.age,
			"timestamp": OS.get_unix_time()
		})

func _on_movement_mode_changed(old_mode, new_mode):
	# Certain movement modes might affect universe travel
	if new_mode == "dream_navigation" or new_mode == "time_stream":
		# These modes might make hidden universes more accessible
		if multiverse_ui:
			multiverse_ui.show_hidden_universes = true
	else:
		if multiverse_ui:
			multiverse_ui.show_hidden_universes = false
	
	if log_to_console:
		print("JSH Multiverse: Player movement mode changed: " + old_mode + " -> " + new_mode)

# ========== Public API ==========

# Focus on a specific universe in the UI
func focus_universe(universe_id):
	if multiverse_ui:
		return multiverse_ui.focus_universe(universe_id)
	return false

# Force cosmic turn advancement
func advance_cosmic_turn():
	if system_integration:
		return system_integration.advance_cosmic_turn()
	return false

# Reset the entire multiverse system
func reset_multiverse():
	if system_integration:
		return system_integration.reset_system()
	return false

# Travel to a universe programmatically
func travel_to_universe(universe_id):
	if system_integration:
		return system_integration.travel_to_universe(universe_id)
	return false

# Show the multiverse map
func show_multiverse_map():
	if multiverse_ui:
		multiverse_ui.show_multiverse_map()
		return true
	return false