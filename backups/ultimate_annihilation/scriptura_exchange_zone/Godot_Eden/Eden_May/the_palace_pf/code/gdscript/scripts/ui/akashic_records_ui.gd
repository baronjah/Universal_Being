extends Control
class_name AkashicRecordsUI

# References
var akashic_records_manager = null
var thing_creator = null
var universal_bridge = null

# UI elements
@onready var word_list = $WordList
@onready var word_details = $WordDetails
@onready var search_box = $SearchBox
@onready var create_button = $CreateButton
@onready var interact_button = $InteractButton

func _ready():
	# Connect UI signals
	if create_button:
		create_button.pressed.connect(Callable(self, "_on_create_button_pressed"))
	
	if interact_button:
		interact_button.pressed.connect(Callable(self, "_on_interact_button_pressed"))
	
	if search_box:
		search_box.text_changed.connect(Callable(self, "_on_search_text_changed"))
	
	if word_list:
		word_list.item_selected.connect(Callable(self, "_on_word_selected"))

# Set the akashic records manager reference
func set_akashic_records_manager(manager) -> void:
	akashic_records_manager = manager
	
	# Connect signals
	if akashic_records_manager:
		if akashic_records_manager.has_signal("word_created"):
			akashic_records_manager.connect("word_created", Callable(self, "_on_word_created"))
		
		if akashic_records_manager.has_signal("word_updated"):
			akashic_records_manager.connect("word_updated", Callable(self, "_on_word_updated"))
	
	# Refresh the word list
	refresh_word_list()

# Set the thing creator reference
func set_thing_creator(creator) -> void:
	thing_creator = creator

# Set the universal bridge reference
func set_universal_bridge(bridge) -> void:
	universal_bridge = bridge

# Refresh the word list
func refresh_word_list() -> void:
	if not word_list or not akashic_records_manager:
		return
	
	# Clear the list
	word_list.clear()
	
	# Get dictionary stats
	var stats = akashic_records_manager.get_dictionary_stats()
	var words = stats.get("words", [])
	
	# Add words to the list
	for word_id in words:
		var word_data = akashic_records_manager.get_word(word_id)
		var display_name = word_data.get("display_name", word_id.capitalize())
		var category = word_data.get("category", "unknown")
		
		# Add item with metadata
		var index = word_list.add_item(display_name + " (" + category + ")")
		word_list.set_item_metadata(index, word_id)

# Show details for a word
func show_word_details(word_id: String) -> void:
	if not word_details or not akashic_records_manager:
		return
	
	# Get word data
	var word_data = akashic_records_manager.get_word(word_id)
	
	# Format details text
	var details = "ID: " + word_id + "\n"
	details += "Category: " + word_data.get("category", "unknown") + "\n"
	
	if word_data.has("parent"):
		details += "Parent: " + word_data.get("parent") + "\n"
	
	if word_data.has("properties"):
		details += "\nProperties:\n"
		var properties = word_data.get("properties")
		for key in properties.keys():
			details += "  " + key + ": " + str(properties[key]) + "\n"
	
	if word_data.has("states"):
		details += "\nStates:\n"
		var states = word_data.get("states")
		if states.has("current"):
			details += "  Current: " + states.get("current") + "\n"
		
		if states.has("possible"):
			details += "  Possible: " + str(states.get("possible")) + "\n"
	
	# Set details text
	word_details.text = details

# Create a new word
func create_word_dialog() -> void:
	# This would normally instantiate a dialog for creating words
	# For now, we'll use a simplified version with hardcoded values
	var word_id = "custom_" + str(randi())
	var category = "custom"
	var properties = {
		"essence": 0.5,
		"stability": 0.5,
		"resonance": 0.5,
		"complexity": 0.5
	}
	
	if akashic_records_manager:
		var success = akashic_records_manager.create_word(word_id, category, properties)
		if success:
			print("Created new word: " + word_id)
			refresh_word_list()
		else:
			print("Failed to create word: " + word_id)

# Signal handlers
func _on_create_button_pressed() -> void:
	create_word_dialog()

func _on_interact_button_pressed() -> void:
	# Get selected words (would be implemented with actual UI)
	var selected_items = word_list.get_selected_items()
	if selected_items.size() < 1:
		print("Select a word to interact with.")
		return
	
	var word_id = word_list.get_item_metadata(selected_items[0])
	
	# For now, we'll just interact with fire if available
	var other_word_id = "fire"
	
	if akashic_records_manager:
		var result = akashic_records_manager.process_word_interaction(word_id, other_word_id)
		print("Interaction result: ", result)
		
		# Create a thing from the result if applicable
		if result.has("result") and universal_bridge:
			var result_word = result.get("result")
			if not result_word.is_empty():
				var position = Vector3(0, 0, 0)  # Default position
				universal_bridge.create_thing_from_word(result_word, position)

func _on_search_text_changed(new_text: String) -> void:
	# Implement filtering
	pass

func _on_word_selected(index: int) -> void:
	var word_id = word_list.get_item_metadata(index)
	show_word_details(word_id)

func _on_word_created(word_id: String) -> void:
	refresh_word_list()

func _on_word_updated(word_id: String) -> void:
	refresh_word_list()
	
	# If this is the currently selected word, update details
	var selected_items = word_list.get_selected_items()
	if selected_items.size() > 0:
		var selected_word_id = word_list.get_item_metadata(selected_items[0])
		if selected_word_id == word_id:
			show_word_details(word_id)