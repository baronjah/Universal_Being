extends Control
class_name AkashicDebugUI

# UI for testing and debugging the Akashic Records system
# This provides a simple interface to create entities, inspect them, and test interactions

# References
var akashic_records_manager = null
var thing_creator = null
var universal_bridge = null

# UI elements
var main_panel = null
var entity_list = null
var word_list = null
var interaction_log = null
var creation_panel = null
var details_panel = null

# Colors for entity types
var type_colors = {
	"primordial": Color(0.5, 0.5, 0.5, 1.0),  # Gray
	"fire": Color(1.0, 0.3, 0.1, 1.0),        # Red
	"water": Color(0.2, 0.4, 1.0, 1.0),       # Blue
	"wood": Color(0.2, 0.8, 0.2, 1.0),        # Green
	"ash": Color(0.7, 0.7, 0.7, 1.0)          # Light gray
}

# Selected entities for interaction
var selected_entities = []

func _ready():
	set_process(false)
	
func initialize(records_manager, creator, bridge) -> void:
	akashic_records_manager = records_manager
	thing_creator = creator
	universal_bridge = bridge
	
	# Create UI only after all references are set
	create_ui()
	
	set_process(true)

func _process(delta):
	# Update entity list periodically
	# to repair Line 48:Identifier "visible" not declared in the current scope.
	if is_instance_valid(entity_list) and visible:
		if Engine.get_frames_drawn() % 30 == 0:  # Update every 30 frames
			refresh_entity_list()

# Create the UI elements
func create_ui() -> void:
	# Create main panel
	main_panel = Panel.new()
	main_panel.name = "AkashicDebugPanel"
	main_panel.anchor_right = 1.0
	main_panel.anchor_bottom = 1.0
	main_panel.position = Vector2(50, 50)
	main_panel.size = Vector2(800, 600)
	
	# Add title
	var title = Label.new()
	title.text = "Akashic Records Debug"
	title.position = Vector2(10, 10)
	title.size = Vector2(780, 30)
	main_panel.add_child(title)
	
	# Create tabs for different sections
	var tabs = TabContainer.new()
	tabs.position = Vector2(10, 50)
	tabs.size = Vector2(780, 540)
	main_panel.add_child(tabs)
	
	# Tab 1: Entity Creation
	var creation_tab = create_creation_tab()
	tabs.add_child(creation_tab)
	
	# Tab 2: Entity List and Interactions
	var entity_tab = create_entity_tab()
	tabs.add_child(entity_tab)
	
	# Tab 3: Dictionary Browser
	var dictionary_tab = create_dictionary_tab()
	tabs.add_child(dictionary_tab)
	
	# Tab 4: Interaction Log
	var log_tab = create_log_tab()
	tabs.add_child(log_tab)
	
	# Close button
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.position = Vector2(main_panel.size.x - 100, 10)
	close_button.size = Vector2(90, 30)
	close_button.pressed.connect(Callable(self, "_on_close_pressed"))
	main_panel.add_child(close_button)
	
	# Initially hide the panel
	main_panel.visible = false
	
	# Add to scene
	add_child(main_panel)
	
	# Populate initial data
	refresh_word_list()
	refresh_entity_list()

# Create the entity creation tab
func create_creation_tab() -> Control:
	var tab = Control.new()
	tab.name = "Creation"
	
	# Panel for creation
	creation_panel = VBoxContainer.new()
	creation_panel.position = Vector2(10, 10)
	creation_panel.size = Vector2(760, 520)
	tab.add_child(creation_panel)
	
	# Title
	var title = Label.new()
	title.text = "Create New Entity"
	creation_panel.add_child(title)
	
	# Word selection
	var word_selection = HBoxContainer.new()
	creation_panel.add_child(word_selection)
	
	var word_label = Label.new()
	word_label.text = "Entity Type:"
	word_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word_selection.add_child(word_label)
	
	word_list = OptionButton.new()
	word_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word_selection.add_child(word_list)
	
	# Position controls
	var position_controls = HBoxContainer.new()
	creation_panel.add_child(position_controls)
	
	var pos_label = Label.new()
	pos_label.text = "Position:"
	pos_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	position_controls.add_child(pos_label)
	
	var pos_x_label = Label.new()
	pos_x_label.text = "X:"
	position_controls.add_child(pos_x_label)
	
	var pos_x = SpinBox.new()
	pos_x.name = "pos_x"
	pos_x.min_value = -100
	pos_x.max_value = 100
	pos_x.step = 1
	pos_x.value = 0
	position_controls.add_child(pos_x)
	
	var pos_y_label = Label.new()
	pos_y_label.text = "Y:"
	position_controls.add_child(pos_y_label)
	
	var pos_y = SpinBox.new()
	pos_y.name = "pos_y"
	pos_y.min_value = -100
	pos_y.max_value = 100
	pos_y.step = 1
	pos_y.value = 0
	position_controls.add_child(pos_y)
	
	var pos_z_label = Label.new()
	pos_z_label.text = "Z:"
	position_controls.add_child(pos_z_label)
	
	var pos_z = SpinBox.new()
	pos_z.name = "pos_z"
	pos_z.min_value = -100
	pos_z.max_value = 100
	pos_z.step = 1
	pos_z.value = 0
	position_controls.add_child(pos_z)
	
	# Create button
	var create_button = Button.new()
	create_button.text = "Create Entity"
	create_button.pressed.connect(Callable(self, "_on_create_entity_pressed"))
	creation_panel.add_child(create_button)
	
	# Separator
	var separator = HSeparator.new()
	creation_panel.add_child(separator)
	
	# Word creation section
	var word_creation_label = Label.new()
	word_creation_label.text = "Define New Word Type"
	creation_panel.add_child(word_creation_label)
	
	var word_id_container = HBoxContainer.new()
	creation_panel.add_child(word_id_container)
	
	var word_id_label = Label.new()
	word_id_label.text = "Word ID:"
	word_id_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word_id_container.add_child(word_id_label)
	
	var word_id_input = LineEdit.new()
	word_id_input.name = "word_id_input"
	word_id_input.placeholder_text = "Enter a unique ID"
	word_id_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word_id_container.add_child(word_id_input)
	
	var parent_container = HBoxContainer.new()
	creation_panel.add_child(parent_container)
	
	var parent_label = Label.new()
	parent_label.text = "Parent Type:"
	parent_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent_container.add_child(parent_label)
	
	var parent_input = OptionButton.new()
	parent_input.name = "parent_input"
	parent_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent_container.add_child(parent_input)
	
	var props_label = Label.new()
	props_label.text = "Properties (JSON format):"
	creation_panel.add_child(props_label)
	
	var props_input = TextEdit.new()
	props_input.name = "props_input"
	props_input.text = "{\n  \"essence\": 1.0,\n  \"stability\": 1.0\n}"
	props_input.size_flags_vertical = Control.SIZE_EXPAND_FILL
	creation_panel.add_child(props_input)
	
	var define_button = Button.new()
	define_button.text = "Define New Word"
	define_button.pressed.connect(Callable(self, "_on_define_word_pressed"))
	creation_panel.add_child(define_button)
	
	return tab

# Create the entity list and interactions tab
func create_entity_tab() -> Control:
	var tab = Control.new()
	tab.name = "Entities"
	
	# Split view
	var split = HSplitContainer.new()
	split.position = Vector2(10, 10)
	split.size = Vector2(760, 520)
	tab.add_child(split)
	
	# Left side - entity list
	var left_panel = VBoxContainer.new()
	split.add_child(left_panel)
	
	var list_label = Label.new()
	list_label.text = "Active Entities"
	left_panel.add_child(list_label)
	
	entity_list = ItemList.new()
	entity_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	entity_list.allow_reselect = true
	entity_list.select_mode = ItemList.SELECT_MULTI
	entity_list.item_selected.connect(Callable(self, "_on_entity_selected"))
	left_panel.add_child(entity_list)
	
	var refresh_button = Button.new()
	refresh_button.text = "Refresh List"
	refresh_button.pressed.connect(Callable(self, "refresh_entity_list"))
	left_panel.add_child(refresh_button)
	
	# Right side - entity details and interactions
	var right_panel = VBoxContainer.new()
	split.add_child(right_panel)
	
	details_panel = VBoxContainer.new()
	details_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_panel.add_child(details_panel)
	
	var details_label = Label.new()
	details_label.text = "Entity Details"
	details_panel.add_child(details_label)
	
	var details_text = RichTextLabel.new()
	details_text.name = "details_text"
	details_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details_text.bbcode_enabled = true
	details_text.text = "Select an entity to view details"
	details_panel.add_child(details_text)
	
	var interact_button = Button.new()
	interact_button.name = "interact_button"
	interact_button.text = "Interact Selected Entities"
	interact_button.disabled = true
	interact_button.pressed.connect(Callable(self, "_on_interact_pressed"))
	right_panel.add_child(interact_button)
	
	var transform_section = HBoxContainer.new()
	right_panel.add_child(transform_section)
	
	var transform_label = Label.new()
	transform_label.text = "Transform to:"
	transform_section.add_child(transform_label)
	
	var transform_type = OptionButton.new()
	transform_type.name = "transform_type"
	transform_type.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	transform_section.add_child(transform_type)
	
	var transform_button = Button.new()
	transform_button.name = "transform_button"
	transform_button.text = "Transform"
	transform_button.disabled = true
	transform_button.pressed.connect(Callable(self, "_on_transform_pressed"))
	transform_section.add_child(transform_button)
	
	return tab

# Create the dictionary browser tab
func create_dictionary_tab() -> Control:
	var tab = Control.new()
	tab.name = "Dictionary"
	
	# Dictionary browser
	var browser = VBoxContainer.new()
	browser.position = Vector2(10, 10)
	browser.size = Vector2(760, 520)
	tab.add_child(browser)
	
	var browser_label = Label.new()
	browser_label.text = "Dictionary Contents"
	browser.add_child(browser_label)
	
	var filter_container = HBoxContainer.new()
	browser.add_child(filter_container)
	
	var filter_label = Label.new()
	filter_label.text = "Filter by Type:"
	filter_container.add_child(filter_label)
	
	var filter_dropdown = OptionButton.new()
	filter_dropdown.name = "filter_dropdown"
	filter_dropdown.add_item("All", 0)
	filter_dropdown.add_item("Element", 1)
	filter_dropdown.add_item("Base", 2)
	filter_dropdown.add_item("Custom", 3)
	filter_dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	filter_dropdown.item_selected.connect(Callable(self, "_on_filter_selected"))
	filter_container.add_child(filter_dropdown)
	
	var dictionary_list = ItemList.new()
	dictionary_list.name = "dictionary_list"
	dictionary_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dictionary_list.item_selected.connect(Callable(self, "_on_dictionary_item_selected"))
	browser.add_child(dictionary_list)
	
	var details_container = VBoxContainer.new()
	details_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	browser.add_child(details_container)
	
	var dict_details_label = Label.new()
	dict_details_label.text = "Word Details"
	details_container.add_child(dict_details_label)
	
	var dict_details = RichTextLabel.new()
	dict_details.name = "dict_details"
	dict_details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	dict_details.bbcode_enabled = true
	dict_details.text = "Select a word to view details"
	details_container.add_child(dict_details)
	
	return tab

# Create the interaction log tab
func create_log_tab() -> Control:
	var tab = Control.new()
	tab.name = "Log"
	
	# Log panel
	var log_panel = VBoxContainer.new()
	log_panel.position = Vector2(10, 10)
	log_panel.size = Vector2(760, 520)
	tab.add_child(log_panel)
	
	var log_label = Label.new()
	log_label.text = "Interaction Log"
	log_panel.add_child(log_label)
	
	interaction_log = RichTextLabel.new()
	interaction_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	interaction_log.bbcode_enabled = true
	interaction_log.scroll_following = true
	log_panel.add_child(interaction_log)
	
	var clear_button = Button.new()
	clear_button.text = "Clear Log"
	clear_button.pressed.connect(Callable(self, "_on_clear_log_pressed"))
	log_panel.add_child(clear_button)
	
	return tab

# Toggle UI visibility
func toggle_visibility() -> void:
	if main_panel:
		main_panel.visible = !main_panel.visible
		
		if main_panel.visible:
			# Refresh data when showing
			refresh_word_list()
			refresh_entity_list()

# Refresh the entity list
func refresh_entity_list() -> void:
	if not is_instance_valid(entity_list) or not thing_creator:
		return
		
	entity_list.clear()
	
	var things = thing_creator.get_all_things()
	for thing_id in things:
		var thing_data = thing_creator.get_thing(thing_id)
		if thing_data.size() > 0:
			var word_id = thing_data.word_id
			var display_text = thing_id + " (" + word_id + ")"
			
			# Add item with color
			var color = type_colors.get(word_id, Color(1, 1, 1, 1))
			entity_list.add_item(display_text, null, true)
			var idx = entity_list.item_count - 1
			entity_list.set_item_metadata(idx, thing_id)
			entity_list.set_item_custom_fg_color(idx, color)
	
	# Update interaction button state
	_update_interaction_button()

# Refresh the word list
func refresh_word_list() -> void:
	if not is_instance_valid(word_list) or not akashic_records_manager:
		return
	
	word_list.clear()
	# res://code/gdscript/scripts/akashic_records/debug_ui.gd
	# Invalid call. Nonexistent function 'get_dictionary_stats' in base 'Node (AkashicRecordsManagerA)'.
	var stats = akashic_records_manager.get_dictionary_stats()
	if stats.has("words"):
		for word_id in stats.words:
			var word = akashic_records_manager.get_word(word_id)
			if word.size() > 0:
				word_list.add_item(word_id)
				word_list.set_item_metadata(word_list.item_count - 1, word_id)
	
	# Also update the parent dropdown and transform dropdown
	var parent_input = creation_panel.get_node_or_null("parent_input")
	if parent_input:
		parent_input.clear()
		for word_id in stats.words:
			var word = akashic_records_manager.get_word(word_id)
			if word.size() > 0:
				parent_input.add_item(word_id)
				parent_input.set_item_metadata(parent_input.item_count - 1, word_id)
	
	# Update transform type dropdown
	var transform_type = details_panel.get_parent().get_node_or_null("transform_type")
	if transform_type:
		transform_type.clear()
		for word_id in stats.words:
			transform_type.add_item(word_id)
			transform_type.set_item_metadata(transform_type.item_count - 1, word_id)

# Update the interaction button state
func _update_interaction_button() -> void:
	var interact_button = details_panel.get_parent().get_node_or_null("interact_button")
	if interact_button:
		interact_button.disabled = selected_entities.size() != 2
	
	var transform_button = details_panel.get_parent().get_node_or_null("transform_button")
	if transform_button:
		transform_button.disabled = selected_entities.size() != 1

# Log an interaction
func log_interaction(entity1_id: String, entity2_id: String, result: Dictionary) -> void:
	if not is_instance_valid(interaction_log):
		return
	
	var timestamp = Time.get_datetime_string_from_system()
	var log_text = "[b][" + timestamp + "][/b] "
	
	# Get entity types
	var entity1_type = "unknown"
	var entity2_type = "unknown"
	
	var thing1 = thing_creator.get_thing(entity1_id)
	if thing1.size() > 0:
		entity1_type = thing1.word_id
	
	var thing2 = thing_creator.get_thing(entity2_id)
	if thing2.size() > 0:
		entity2_type = thing2.word_id
	
	# Add interaction details
	log_text += entity1_id + " (" + entity1_type + ") + " + entity2_id + " (" + entity2_type + ")\n"
	
	if result.success:
		log_text += "[color=green]Success:[/color] "
		
		if result.has("interaction"):
			log_text += result.interaction
		
		if result.has("description"):
			log_text += " - " + result.description
		
		if result.has("effects") and result.effects.size() > 0:
			log_text += "\nEffects: " + str(result.effects)
		
		if result.has("transformation") and result.transformation.triggered:
			log_text += "\n[color=purple]Transformation triggered:[/color] " + result.transformation.target
		
		if result.has("new_thing_id"):
			log_text += "\n[color=blue]Created:[/color] " + result.new_thing_id
		
		if result.has("merged_thing_id"):
			log_text += "\n[color=blue]Merged into:[/color] " + result.merged_thing_id
	else:
		log_text += "[color=red]Failed:[/color] "
		if result.has("reason"):
			log_text += result.reason
	
	# Add to log with separator
	interaction_log.text += log_text + "\n[color=gray]--------------------[/color]\n"

# Handle entity selection
func _on_entity_selected(index) -> void:
	var thing_id = entity_list.get_item_metadata(index)
	
	# Simple selection toggle
	if selected_entities.has(thing_id):
		selected_entities.erase(thing_id)
		entity_list.deselect(index)
	else:
		selected_entities.append(thing_id)
	
	# Limit to 2 selections
	if selected_entities.size() > 2:
		var first_id = selected_entities[0]
		selected_entities.remove_at(0)
		
		# Deselect visually
		for i in range(entity_list.item_count):
			if entity_list.get_item_metadata(i) == first_id:
				entity_list.deselect(i)
				break
	
	# Update details panel
	var details_text = details_panel.get_node_or_null("details_text")
	if details_text:
		if selected_entities.size() == 1:
			var thing_data = thing_creator.get_thing(selected_entities[0])
			if thing_data.size() > 0:
				details_text.text = _format_thing_details(thing_data)
		elif selected_entities.size() == 2:
			details_text.text = "[b]Selected for interaction:[/b]\n"
			for entity_id in selected_entities:
				var thing_data = thing_creator.get_thing(entity_id)
				if thing_data.size() > 0:
					details_text.text += "- " + entity_id + " (" + thing_data.word_id + ")\n"
			
			details_text.text += "\nPress 'Interact' to test interaction."
		else:
			details_text.text = "Select an entity to view details"
	
	# Update interaction button
	_update_interaction_button()

# Format thing details for display
func _format_thing_details(thing_data: Dictionary) -> String:
	var result = "[b]" + thing_data.get("id", "Unknown") + "[/b]\n"
	result += "Type: " + thing_data.get("word_id", "Unknown") + "\n"
	result += "Position: " + str(thing_data.get("position", Vector3.ZERO)) + "\n\n"
	
	if thing_data.has("properties"):
		result += "[u]Properties:[/u]\n"
		for prop in thing_data.properties:
			result += prop + ": " + str(thing_data.properties[prop]) + "\n"
	
	return result

# Handle filter selection
func _on_filter_selected(index) -> void:
	# TODO: Implement filtering of dictionary contents
	pass

# Handle dictionary item selection
func _on_dictionary_item_selected(index) -> void:
	# TODO: Show word details
	pass

# Handle interaction button press
func _on_interact_pressed() -> void:
	if selected_entities.size() != 2 or not universal_bridge:
		return
	
	var entity1_id = selected_entities[0]
	var entity2_id = selected_entities[1]
	
	# Process the interaction
	var result = universal_bridge.process_thing_interaction(entity1_id, entity2_id)
	
	# Log the result
	log_interaction(entity1_id, entity2_id, result)
	
	# Refresh lists
	refresh_entity_list()
	
	# Clear selection
	selected_entities.clear()
	
	# Update details
	var details_text = details_panel.get_node_or_null("details_text")
	if details_text:
		if result.success:
			details_text.text = "[b]Interaction Result:[/b]\n"
			details_text.text += "Type: " + result.get("type", "unknown") + "\n"
			details_text.text += "Description: " + result.get("description", "") + "\n\n"
			
			if result.has("effects") and result.effects.size() > 0:
				details_text.text += "[u]Effects:[/u]\n"
				for effect in result.effects:
					details_text.text += "- " + str(effect) + "\n"
		else:
			details_text.text = "[b]Interaction Failed[/b]\n"
			details_text.text += "Reason: " + result.get("reason", "unknown")

# Handle transform button press
func _on_transform_pressed() -> void:
	if selected_entities.size() != 1 or not universal_bridge:
		return
	
	var entity_id = selected_entities[0]
	var transform_type = details_panel.get_parent().get_node_or_null("transform_type")
	
	if not transform_type:
		return
	
	var type_idx = transform_type.selected
	var new_type = transform_type.get_item_metadata(type_idx)
	
	# Process the transformation
	var success = universal_bridge.transform_thing(entity_id, new_type)
	
	# Create a mock result for logging
	var result = {
		"success": success,
		"type": "transform",
		"description": "Manual transformation to " + new_type
	}
	
	# Log the result
	log_interaction(entity_id, entity_id, result)
	
	# Refresh lists
	refresh_entity_list()
	
	# Clear selection
	selected_entities.clear()
	
	# Update details
	var details_text = details_panel.get_node_or_null("details_text")
	if details_text:
		if success:
			details_text.text = "[b]Transformation Success[/b]\n"
			details_text.text += "Entity transformed to: " + new_type
		else:
			details_text.text = "[b]Transformation Failed[/b]"

# Handle create entity button press
func _on_create_entity_pressed() -> void:
	if not word_list or not universal_bridge:
		return
	
	var selected_idx = word_list.selected
	if selected_idx < 0:
		return
	
	var word_id = word_list.get_item_metadata(selected_idx)
	
	var pos_x = creation_panel.get_node_or_null("pos_x")
	var pos_y = creation_panel.get_node_or_null("pos_y")
	var pos_z = creation_panel.get_node_or_null("pos_z")
	
	if not pos_x or not pos_y or not pos_z:
		return
	
	var position = Vector3(pos_x.value, pos_y.value, pos_z.value)
	
	# Create the entity
	var entity_id = universal_bridge.create_thing_from_word(word_id, position)
	
	if not entity_id.is_empty():
		# Log the creation
		var result = {
			"success": true,
			"type": "create",
			"description": "Created entity of type " + word_id
		}
		
		log_interaction("user", "system", result)
		
		# Refresh lists
		refresh_entity_list()
	else:
		# Log failure
		var result = {
			"success": false,
			"reason": "Failed to create entity"
		}
		
		log_interaction("user", "system", result)

# Handle define word button press
func _on_define_word_pressed() -> void:
	if not akashic_records_manager:
		return
	
	var word_id_input = creation_panel.get_node_or_null("word_id_input")
	var parent_input = creation_panel.get_node_or_null("parent_input")
	var props_input = creation_panel.get_node_or_null("props_input")
	
	if not word_id_input or not parent_input or not props_input:
		return
	
	var word_id = word_id_input.text.strip_edges()
	if word_id.is_empty():
		return
	
	var parent_idx = parent_input.selected
	var parent_id = ""
	if parent_idx >= 0:
		parent_id = parent_input.get_item_metadata(parent_idx)
	
	# Parse properties JSON
	var properties = {}
	var json_str = props_input.text
	
	var json = JSON.new()
	var parse_result = json.parse(json_str)
	if parse_result == OK:
		properties = json.get_data()
	
	# Create word data
	var word_data = {
		"id": word_id,
		"display_name": word_id.capitalize(),
		"category": "custom",
		"parent": parent_id,
		"properties": properties
	}
	
	# Create the word
	var success = akashic_records_manager.create_word(word_id, word_data)
	
	if success:
		# Log the creation
		var result = {
			"success": true,
			"type": "define",
			"description": "Defined new word: " + word_id
		}
		
		log_interaction("user", "system", result)
		
		# Refresh lists
		refresh_word_list()
		
		# Clear inputs
		word_id_input.text = ""
	else:
		# Log failure
		var result = {
			"success": false,
			"reason": "Failed to define word"
		}
		
		log_interaction("user", "system", result)

# Handle clear log button press
func _on_clear_log_pressed() -> void:
	if interaction_log:
		interaction_log.text = ""

# Handle close button press
func _on_close_pressed() -> void:
	if main_panel:
		main_panel.visible = false
