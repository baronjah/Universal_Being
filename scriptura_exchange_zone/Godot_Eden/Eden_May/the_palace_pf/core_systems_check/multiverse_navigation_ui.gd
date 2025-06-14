extends Control

# Multiverse Navigation UI for JSH Ethereal Engine
# This interface provides visualization and controls for navigating
# the multiverse, viewing cosmic turns, and traversing access points.

# Node references
var universe_info_panel: Panel
var access_points_container: VBoxContainer
var cosmic_turn_indicator: ProgressBar
var metanarrative_progress: ProgressBar
var universe_alignment_viz: TextureRect
var search_filter: LineEdit
var universe_name_label: Label
var universe_properties_grid: GridContainer
var travel_button: Button
var quick_travel_buttons: HBoxContainer

# System references
var multiverse_system = null
var current_universe = null
var selected_access_point = null

# Configuration
export var show_hidden_universes = false
export var auto_update_interval = 1.0
export var max_quick_travel_buttons = 5
export var animation_speed = 0.3

# Themes and styles
var universe_type_colors = {
	"physical": Color(0.2, 0.6, 1.0),
	"digital": Color(0.0, 1.0, 0.5),
	"astral": Color(1.0, 0.5, 1.0),
	"dream": Color(0.8, 0.3, 0.8),
	"temporal": Color(1.0, 0.8, 0.2),
	"conceptual": Color(0.5, 0.5, 0.5),
	"quantum": Color(0.0, 0.8, 0.8)
}

var cosmic_age_descriptions = [
	"The Age of Formation", # Age 0
	"The Age of Foundation",
	"The Age of Connection",
	"The Age of Manifestation",
	"The Age of Transcendence",
	"The Age of Harmony",
	"The Age of Unity"  # Age 6
]

# ========== Initialization ==========

func _ready():
	# Set up UI references
	universe_info_panel = $UniverseInfoPanel
	access_points_container = $AccessPointsPanel/ScrollContainer/AccessPointsList
	cosmic_turn_indicator = $CosmicProgress/TurnProgress
	metanarrative_progress = $CosmicProgress/MetanarrativeProgress
	universe_alignment_viz = $AlignmentView/AlignmentVisualization
	search_filter = $AccessPointsPanel/SearchFilter
	universe_name_label = $UniverseInfoPanel/UniverseName
	universe_properties_grid = $UniverseInfoPanel/PropertiesGrid
	travel_button = $AccessPointsPanel/TravelButton
	quick_travel_buttons = $QuickTravelBar
	
	# Connect signals
	travel_button.connect("pressed", self, "_on_travel_button_pressed")
	search_filter.connect("text_changed", self, "_on_search_filter_changed")
	
	# Set up update timer
	var update_timer = Timer.new()
	update_timer.wait_time = auto_update_interval
	update_timer.autostart = true
	update_timer.connect("timeout", self, "update_display")
	add_child(update_timer)
	
	# Initial setup
	initialize_theme()
	
	# Hide until connected to the system
	visible = false

# Connect to the multiverse system
func connect_to_multiverse_system(system):
	multiverse_system = system
	update_display()
	visible = true
	print("JSH Multiverse Navigation UI: Connected to multiverse system")

# Initialize UI theme and styling
func initialize_theme():
	# Set up theme details here
	# This would use the JSH Engine theme if available
	pass

# ========== Main Update Logic ==========

func update_display():
	if not multiverse_system:
		return
	
	current_universe = multiverse_system.get_current_universe()
	if not current_universe:
		return
	
	update_universe_info()
	update_access_points()
	update_cosmic_progress()
	update_alignment_visualization()
	update_quick_travel_buttons()

# Update universe information panel
func update_universe_info():
	universe_name_label.text = current_universe.name
	
	# Clear existing property entries
	for child in universe_properties_grid.get_children():
		child.queue_free()
	
	# Add property labels
	add_property_row("Type", current_universe.type)
	add_property_row("Stability", str(current_universe.stability) + "%")
	add_property_row("Energy Level", str(current_universe.energy_level))
	add_property_row("Core Element", current_universe.core_element)
	add_property_row("Story Phase", current_universe.story_phase)
	add_property_row("Discovered Turn", str(current_universe.discovered_turn))
	
	# Apply color based on universe type
	if universe_type_colors.has(current_universe.type.to_lower()):
		var color = universe_type_colors[current_universe.type.to_lower()]
		universe_info_panel.modulate = Color(1, 1, 1).linear_interpolate(color, 0.2)

# Add a property row to the properties grid
func add_property_row(property_name, property_value):
	var name_label = Label.new()
	name_label.text = property_name + ":"
	name_label.align = Label.ALIGN_RIGHT
	
	var value_label = Label.new()
	value_label.text = str(property_value)
	
	universe_properties_grid.add_child(name_label)
	universe_properties_grid.add_child(value_label)

# Update the list of available access points
func update_access_points():
	# Clear existing access points
	for child in access_points_container.get_children():
		child.queue_free()
	
	# Get access points from the system
	var access_points = multiverse_system.get_available_access_points()
	var filter_text = search_filter.text.to_lower()
	
	# Add filtered access points
	for ap in access_points:
		if filter_text and not (filter_text in ap.target_universe.name.to_lower() or filter_text in ap.description.to_lower()):
			continue
			
		if not show_hidden_universes and ap.hidden:
			continue
			
		var ap_button = Button.new()
		ap_button.text = ap.target_universe.name
		ap_button.hint_tooltip = ap.description
		
		# Add connection stability indicator
		var stability_indicator = TextureProgress.new()
		stability_indicator.value = ap.stability
		stability_indicator.rect_min_size = Vector2(50, 10)
		
		var hbox = HBoxContainer.new()
		hbox.add_child(ap_button)
		hbox.add_child(stability_indicator)
		
		# Connect button signal
		ap_button.connect("pressed", self, "_on_access_point_selected", [ap])
		
		access_points_container.add_child(hbox)

# Update cosmic turn and metanarrative progress
func update_cosmic_progress():
	var cosmic_data = multiverse_system.get_cosmic_state()
	
	# Update turn progress
	cosmic_turn_indicator.value = cosmic_data.turn_progress
	cosmic_turn_indicator.hint_tooltip = "Turn " + str(cosmic_data.current_turn) + " of " + str(cosmic_data.total_turns)
	
	# Update age display
	var age_label = $CosmicProgress/AgeLabel
	age_label.text = "Cosmic Age: " + str(cosmic_data.current_age) + " - " + cosmic_age_descriptions[cosmic_data.current_age]
	
	# Update metanarrative progress
	metanarrative_progress.value = cosmic_data.metanarrative_progress
	metanarrative_progress.hint_tooltip = "Metanarrative Progress: " + str(int(cosmic_data.metanarrative_progress)) + "%"

# Update universe alignment visualization
func update_alignment_visualization():
	# This would generate or update a texture showing universe alignment
	# For now, we'll use a placeholder
	# In a full implementation, this would be a custom shader or generated texture
	var alignment_data = multiverse_system.get_universe_alignment()
	
	# Example visualization update:
	# universe_alignment_viz.material.set_shader_param("alignment_data", alignment_data)

# Update quick travel buttons
func update_quick_travel_buttons():
	# Clear existing buttons
	for child in quick_travel_buttons.get_children():
		child.queue_free()
	
	# Get frequently used or important universes
	var key_universes = multiverse_system.get_key_universes()
	var count = 0
	
	for universe in key_universes:
		if count >= max_quick_travel_buttons:
			break
			
		var quick_button = Button.new()
		quick_button.text = universe.name
		quick_button.connect("pressed", self, "_on_quick_travel_pressed", [universe])
		
		# Apply styling
		if universe == current_universe:
			quick_button.disabled = true
		
		quick_travel_buttons.add_child(quick_button)
		count += 1

# ========== Signal Handlers ==========

func _on_access_point_selected(access_point):
	selected_access_point = access_point
	travel_button.disabled = false
	
	# Update travel button text
	travel_button.text = "Travel to " + access_point.target_universe.name

func _on_travel_button_pressed():
	if selected_access_point:
		var result = multiverse_system.travel_to_universe(selected_access_point.target_universe.id)
		if result:
			# Travel animation
			play_travel_animation()
			
			# Update display after travel
			yield(get_tree().create_timer(animation_speed * 2), "timeout")
			update_display()
		else:
			# Show travel error
			show_travel_error("Cannot travel to this universe at this time.")

func _on_quick_travel_pressed(universe):
	var result = multiverse_system.travel_to_universe(universe.id)
	if result:
		play_travel_animation()
		
		# Update display after travel
		yield(get_tree().create_timer(animation_speed * 2), "timeout")
		update_display()
	else:
		show_travel_error("Quick travel failed. Access point may be unstable.")

func _on_search_filter_changed(_new_text):
	update_access_points()

# ========== Utility Functions ==========

func play_travel_animation():
	# Create animation for universe travel
	var anim = $TravelAnimation
	if not anim:
		anim = AnimationPlayer.new()
		anim.name = "TravelAnimation"
		add_child(anim)
		
		# Create travel animation
		var animation = Animation.new()
		var track_idx = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track_idx, ":modulate")
		animation.track_insert_key(track_idx, 0.0, Color(1, 1, 1, 1))
		animation.track_insert_key(track_idx, animation_speed, Color(1, 1, 1, 0))
		animation.track_insert_key(track_idx, animation_speed * 2, Color(1, 1, 1, 1))
		
		anim.add_animation("travel", animation)
	
	anim.play("travel")

func show_travel_error(message):
	var error_label = $ErrorMessage
	if not error_label:
		error_label = Label.new()
		error_label.name = "ErrorMessage"
		error_label.align = Label.ALIGN_CENTER
		error_label.modulate = Color(1, 0.3, 0.3)
		add_child(error_label)
	
	error_label.text = message
	error_label.visible = true
	
	# Hide after delay
	yield(get_tree().create_timer(2.0), "timeout")
	error_label.visible = false

# ========== Public API ==========

func toggle_visibility():
	visible = !visible
	
	if visible:
		update_display()

func focus_universe(universe_id):
	# Find universe in access points and focus/highlight it
	var access_points = multiverse_system.get_available_access_points()
	
	for ap in access_points:
		if ap.target_universe.id == universe_id:
			_on_access_point_selected(ap)
			return true
	
	return false

func show_multiverse_map():
	# This would open a more detailed visualization of the multiverse
	# Placeholder for now
	print("JSH Multiverse Navigation: Detailed map not yet implemented")