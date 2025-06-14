extends Control
class_name AkashicRecordsUI

# References
var akashic_records_manager = null

# UI elements
@onready var word_list: ItemList = $Panel/HSplitContainer/LeftPanel/WordList
@onready var word_details: VBoxContainer = $Panel/HSplitContainer/MiddlePanel/ScrollContainer/WordDetails
@onready var visualization_container: SubViewport = $Panel/HSplitContainer/RightPanel/SubViewportContainer/SubViewport
@onready var search_field: LineEdit = $Panel/HSplitContainer/LeftPanel/SearchContainer/SearchField
@onready var category_filter: OptionButton = $Panel/HSplitContainer/LeftPanel/SearchContainer/CategoryFilter
@onready var status_label: Label = $Panel/StatusBar/StatusLabel

# Visualization
var frequency_visualizer = null
var current_selected_word: String = ""

func _ready():
	# Find AkashicRecordsManager
	if has_node("/root/AkashicRecordsManager"):
		akashic_records_manager = get_node("/root/AkashicRecordsManager")
	else:
		print("AkashicRecordsManager not found!")
		status_label.text = "Error: AkashicRecordsManager not found!"
		return
	
	# Initialize UI
	_initialize_ui()
	
	# Connect signals
	_connect_signals()
	
	# Initialize frequency visualizer
	_initialize_visualizer()
	
	# Populate UI
	_populate_word_list()
	_populate_category_filter()
	
	status_label.text = "Akashic Records UI initialized"

func _initialize_ui():
	# Already set up in the scene file
	pass

func _connect_signals():
	# Connect UI element signals
	word_list.item_selected.connect(_on_word_selected)
	search_field.text_changed.connect(_on_search_text_changed)
	category_filter.item_selected.connect(_on_category_selected)
	
	# Connect AkashicRecordsManager signals
	if akashic_records_manager:
		akashic_records_manager.dynamic_dictionary.connect("word_added", Callable(self, "_on_word_added"))
		akashic_records_manager.dynamic_dictionary.connect("word_removed", Callable(self, "_on_word_removed"))
		akashic_records_manager.dynamic_dictionary.connect("word_updated", Callable(self, "_on_word_updated"))
		akashic_records_manager.dynamic_dictionary.connect("dictionary_loaded", Callable(self, "_on_dictionary_loaded"))

func _initialize_visualizer():
	# Load the FrequencyVisualizer script and create an instance
	var visualizer_script = load("res://code/gdscript/scripts/akashic_records/frequency_visualizer.gd")
	if visualizer_script:
		frequency_visualizer = visualizer_script.new()
		frequency_visualizer.akashic_records = akashic_records_manager
		
		# If evolution manager exists, connect it
		if akashic_records_manager.evolution_manager:
			frequency_visualizer.evolution_manager = akashic_records_manager.evolution_manager
		
		# Add to visualization container
		visualization_container.add_child(frequency_visualizer)
		
		# Connect word selection signal
		frequency_visualizer.connect("word_selected", Callable(self, "_on_visualizer_word_selected"))
		
		# Initial visualization update
		frequency_visualizer.update_visualization()
	else:
		print("FrequencyVisualizer script not found")

func _populate_word_list():
	word_list.clear()
	
	var query = search_field.text
	var category = ""
	if category_filter.selected > 0:  # Skip "All" option
		category = category_filter.get_item_text(category_filter.selected)
	
	var words = akashic_records_manager.search_words(query, category)
	
	for word_id in words:
		var word = akashic_records_manager.dynamic_dictionary.get_word(word_id)
		word_list.add_item(word_id)
		
		# Add icon based on category
		match word.category:
			"element":
				word_list.set_item_icon(word_list.get_item_count() - 1, get_icon("Node"))
			"concept":
				word_list.set_item_icon(word_list.get_item_count() - 1, get_icon("Control"))
			"entity":
				word_list.set_item_icon(word_list.get_item_count() - 1, get_icon("Spatial"))
	
	status_label.text = "Found " + str(words.size()) + " words"

func get_icon(name: String) -> Texture2D:
	# This function would return an icon based on name
	# In a real implementation, you'd have icons for different categories
	return null

func _populate_category_filter():
	category_filter.clear()
	
	# Add "All" option
	category_filter.add_item("All")
	
	# Get all unique categories
	var categories = {}
	for word_id in akashic_records_manager.dynamic_dictionary.words:
		var word = akashic_records_manager.dynamic_dictionary.get_word(word_id)
		categories[word.category] = true
	
	# Add to dropdown
	for category in categories:
		category_filter.add_item(category)

func _update_word_details(word_id: String):
	# Clear details panel
	for child in word_details.get_children():
		word_details.remove_child(child)
		child.queue_free()
	
	if word_id.is_empty() or not akashic_records_manager.dynamic_dictionary.words.has(word_id):
		return
	
	var word = akashic_records_manager.dynamic_dictionary.get_word(word_id)
	
	# Add general info
	var id_label = Label.new()
	id_label.text = "ID: " + word.id
	word_details.add_child(id_label)
	
	var category_label = Label.new()
	category_label.text = "Category: " + word.category
	word_details.add_child(category_label)
	
	var parent_label = Label.new()
	parent_label.text = "Parent: " + word.parent_id
	word_details.add_child(parent_label)
	
	# Add usage info
	var usage_label = Label.new()
	usage_label.text = "Usage Count: " + str(word.usage_count)
	word_details.add_child(usage_label)
	
	# Add properties section
	var props_label = Label.new()
	props_label.text = "Properties:"
	word_details.add_child(props_label)
	
	for prop in word.properties:
		var prop_label = Label.new()
		prop_label.text = "  " + prop + ": " + str(word.properties[prop])
		word_details.add_child(prop_label)
	
	# Add states section
	var states_label = Label.new()
	states_label.text = "States:"
	word_details.add_child(states_label)
	
	for state in word.states:
		var state_label = Label.new()
		var is_current = state == word.current_state
		state_label.text = "  " + state + (" (current)" if is_current else "")
		word_details.add_child(state_label)
	
	# Add interactions section
	var interactions_label = Label.new()
	interactions_label.text = "Interactions:"
	word_details.add_child(interactions_label)
	
	for target_id in word.interactions:
		var interaction = word.interactions[target_id]
		var interaction_label = Label.new()
		interaction_label.text = "  " + target_id + " -> " + interaction.get("result", "")
		word_details.add_child(interaction_label)
		
		if not interaction.get("conditions", {}).is_empty():
			var conditions_label = Label.new()
			conditions_label.text = "    Conditions: " + str(interaction.get("conditions", {}))
			word_details.add_child(conditions_label)
	
	# Add children section
	var children_label = Label.new()
	children_label.text = "Children:"
	word_details.add_child(children_label)
	
	for child_id in word.children:
		var child_label = Label.new()
		child_label.text = "  " + child_id
		word_details.add_child(child_label)
	
	# Add variants section
	var variants_label = Label.new()
	variants_label.text = "Variants:"
	word_details.add_child(variants_label)
	
	for variant in word.variants:
		var variant_label = Label.new()
		variant_label.text = "  " + variant.id
		word_details.add_child(variant_label)
	
	# Add action buttons
	var buttons_container = HBoxContainer.new()
	word_details.add_child(buttons_container)
	
	var edit_button = Button.new()
	edit_button.text = "Edit Word"
	edit_button.pressed.connect(_on_edit_word_button_pressed.bind(word_id))
	buttons_container.add_child(edit_button)
	
	var add_interaction_button = Button.new()
	add_interaction_button.text = "Add Interaction"
	add_interaction_button.pressed.connect(_on_add_interaction_button_pressed.bind(word_id))
	buttons_container.add_child(add_interaction_button)
	
	current_selected_word = word_id
	
	# Update visualization selection
	if frequency_visualizer:
		frequency_visualizer.select_word(word_id)

# Signal handlers
func _on_word_selected(index: int):
	var word_id = word_list.get_item_text(index)
	_update_word_details(word_id)

func _on_search_text_changed(new_text: String):
	_populate_word_list()

func _on_category_selected(index: int):
	_populate_word_list()

func _on_visualizer_word_selected(word):
	if word:
		# Find item in list and select it
		for i in range(word_list.get_item_count()):
			if word_list.get_item_text(i) == word.id:
				word_list.select(i)
				_update_word_details(word.id)
				break
	else:
		# Deselect
		word_list.deselect_all()
		_update_word_details("")

func _on_word_added(word_id: String):
	_populate_word_list()
	_populate_category_filter()
	
	if frequency_visualizer:
		frequency_visualizer.update_visualization()

func _on_word_removed(word_id: String):
	_populate_word_list()
	
	if current_selected_word == word_id:
		current_selected_word = ""
		_update_word_details("")
	
	if frequency_visualizer:
		frequency_visualizer.update_visualization()

func _on_word_updated(word_id: String):
	# Update word details if this is the currently selected word
	if current_selected_word == word_id:
		_update_word_details(word_id)
	
	if frequency_visualizer:
		frequency_visualizer.update_visualization()

func _on_dictionary_loaded():
	_populate_word_list()
	_populate_category_filter()
	
	if frequency_visualizer:
		frequency_visualizer.update_visualization()

# UI Action handlers
func _on_add_word_button_pressed():
	# Show dialog to add new word
	var dialog = ConfirmationDialog.new()
	dialog.title = "Add New Word"
	dialog.size = Vector2(400, 200)
	
	var vbox = VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.position = Vector2(10, 10)
	vbox.size = dialog.size - Vector2(20, 50)
	dialog.add_child(vbox)
	
	var id_hbox = HBoxContainer.new()
	vbox.add_child(id_hbox)
	
	var id_label = Label.new()
	id_label.text = "ID:"
	id_hbox.add_child(id_label)
	
	var id_edit = LineEdit.new()
	id_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	id_hbox.add_child(id_edit)
	
	var category_hbox = HBoxContainer.new()
	vbox.add_child(category_hbox)
	
	var category_label = Label.new()
	category_label.text = "Category:"
	category_hbox.add_child(category_label)
	
	var category_edit = LineEdit.new()
	category_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	category_edit.text = "element"
	category_hbox.add_child(category_edit)
	
	var parent_hbox = HBoxContainer.new()
	vbox.add_child(parent_hbox)
	
	var parent_label = Label.new()
	parent_label.text = "Parent:"
	parent_hbox.add_child(parent_label)
	
	var parent_edit = LineEdit.new()
	parent_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent_hbox.add_child(parent_edit)
	
	add_child(dialog)
	
	dialog.confirmed.connect(func():
		var id = id_edit.text.strip_edges()
		var category = category_edit.text.strip_edges()
		var parent = parent_edit.text.strip_edges()
		
		if id.is_empty() or category.is_empty():
			return
		
		# Create word
		var success = akashic_records_manager.create_word(id, category, {}, parent)
		
		if success:
			status_label.text = "Word added: " + id
		else:
			status_label.text = "Failed to add word: " + id
		
		dialog.queue_free()
	)
	
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	
	dialog.popup_centered()

func _on_edit_word_button_pressed(word_id: String):
	if not akashic_records_manager.dynamic_dictionary.words.has(word_id):
		return
	
	var word = akashic_records_manager.dynamic_dictionary.get_word(word_id)
	
	# Show dialog to edit properties
	var dialog = ConfirmationDialog.new()
	dialog.title = "Edit Word: " + word_id
	dialog.size = Vector2(400, 500)
	
	var vbox = VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.position = Vector2(10, 10)
	vbox.size = dialog.size - Vector2(20, 50)
	dialog.add_child(vbox)
	
	# Property editor
	var props_label = Label.new()
	props_label.text = "Properties:"
	vbox.add_child(props_label)
	
	var props_scroll = ScrollContainer.new()
	props_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(props_scroll)
	
	var props_vbox = VBoxContainer.new()
	props_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	props_scroll.add_child(props_vbox)
	
	var property_editors = {}
	
	for prop in word.properties:
		var prop_hbox = HBoxContainer.new()
		props_vbox.add_child(prop_hbox)
		
		var prop_label = Label.new()
		prop_label.text = prop + ":"
		prop_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		prop_hbox.add_child(prop_label)
		
		var prop_edit
		if word.properties[prop] is float:
			prop_edit = SpinBox.new()
			prop_edit.min_value = 0.0
			prop_edit.max_value = 1.0
			prop_edit.step = 0.01
			prop_edit.value = word.properties[prop]
		else:
			prop_edit = LineEdit.new()
			prop_edit.text = str(word.properties[prop])
		
		prop_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		prop_hbox.add_child(prop_edit)
		property_editors[prop] = prop_edit
	
	# Add property button
	var add_prop_button = Button.new()
	add_prop_button.text = "Add Property"
	vbox.add_child(add_prop_button)
	
	# State editor
	var states_label = Label.new()
	states_label.text = "States:"
	vbox.add_child(states_label)
	
	var states_scroll = ScrollContainer.new()
	states_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(states_scroll)
	
	var states_vbox = VBoxContainer.new()
	states_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	states_scroll.add_child(states_vbox)
	
	var state_editors = {}
	
	for state in word.states:
		var state_hbox = HBoxContainer.new()
		states_vbox.add_child(state_hbox)
		
		var state_label = Label.new()
		state_label.text = state
		state_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		state_hbox.add_child(state_label)
		
		var default_check = CheckBox.new()
		default_check.text = "Default"
		default_check.button_pressed = (state == word.current_state)
		state_hbox.add_child(default_check)
		state_editors[state] = default_check
	
	# Add state button
	var add_state_button = Button.new()
	add_state_button.text = "Add State"
	vbox.add_child(add_state_button)
	
	add_child(dialog)
	
	dialog.confirmed.connect(func():
		# Update properties
		for prop in property_editors:
			var editor = property_editors[prop]
			
			if editor is SpinBox:
				word.properties[prop] = editor.value
			else:
				var value = editor.text
				
				# Try to convert to number if possible
				if value.is_valid_float():
					word.properties[prop] = float(value)
				elif value == "true":
					word.properties[prop] = true
				elif value == "false":
					word.properties[prop] = false
				else:
					word.properties[prop] = value
		
		# Update states
		var new_current_state = word.current_state
		
		for state in state_editors:
			var is_default = state_editors[state].button_pressed
			
			if is_default:
				new_current_state = state
		
		if new_current_state != word.current_state:
			word.change_state(new_current_state)
		
		# Update word
		akashic_records_manager.dynamic_dictionary.update_word(word)
		
		status_label.text = "Word updated: " + word.id
		dialog.queue_free()
	)
	
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	
	dialog.popup_centered()

func _on_add_interaction_button_pressed(word_id: String):
	if not akashic_records_manager.dynamic_dictionary.words.has(word_id):
		return
	
	# Show dialog to add interaction
	var dialog = ConfirmationDialog.new()
	dialog.title = "Add Interaction to " + word_id
	dialog.size = Vector2(400, 200)
	
	var vbox = VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.position = Vector2(10, 10)
	vbox.size = dialog.size - Vector2(20, 50)
	dialog.add_child(vbox)
	
	var target_hbox = HBoxContainer.new()
	vbox.add_child(target_hbox)
	
	var target_label = Label.new()
	target_label.text = "Target Word:"
	target_hbox.add_child(target_label)
	
	var target_edit = LineEdit.new()
	target_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	target_hbox.add_child(target_edit)
	
	var result_hbox = HBoxContainer.new()
	vbox.add_child(result_hbox)
	
	var result_label = Label.new()
	result_label.text = "Result Word:"
	result_hbox.add_child(result_label)
	
	var result_edit = LineEdit.new()
	result_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_hbox.add_child(result_edit)
	
	var condition_hbox = HBoxContainer.new()
	vbox.add_child(condition_hbox)
	
	var condition_label = Label.new()
	condition_label.text = "Condition:"
	condition_hbox.add_child(condition_label)
	
	var condition_edit = LineEdit.new()
	condition_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	condition_edit.placeholder_text = "e.g. heat > 0.5"
	condition_hbox.add_child(condition_edit)
	
	add_child(dialog)
	
	dialog.confirmed.connect(func():
		var target = target_edit.text.strip_edges()
		var result = result_edit.text.strip_edges()
		var condition = condition_edit.text.strip_edges()
		
		if target.is_empty() or result.is_empty():
			return
		
		# Parse condition
		var conditions = {}
		if not condition.is_empty():
			var parts = condition.split(" ", false)
			if parts.size() >= 3:
				var prop = parts[0].strip_edges()
				var op = parts[1].strip_edges()
				var val = parts[2].strip_edges()
				
				if val.is_valid_float():
					val = float(val)
				elif val == "true":
					val = true
				elif val == "false":
					val = false
				
				conditions[prop] = op + " " + str(val)
		
		# Add interaction
		var success = akashic_records_manager.add_word_interaction(word_id, target, result, conditions)
		
		if success:
			status_label.text = "Interaction added to " + word_id
			_update_word_details(word_id)
		else:
			status_label.text = "Failed to add interaction to " + word_id
		
		dialog.queue_free()
	)
	
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	
	dialog.popup_centered()

func _on_test_interaction_button_pressed():
	# Show dialog to test interaction
	var dialog = ConfirmationDialog.new()
	dialog.title = "Test Interaction"
	dialog.size = Vector2(400, 200)
	
	var vbox = VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.position = Vector2(10, 10)
	vbox.size = dialog.size - Vector2(20, 50)
	dialog.add_child(vbox)
	
	var word1_hbox = HBoxContainer.new()
	vbox.add_child(word1_hbox)
	
	var word1_label = Label.new()
	word1_label.text = "Word 1:"
	word1_hbox.add_child(word1_label)
	
	var word1_edit = LineEdit.new()
	word1_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if not current_selected_word.is_empty():
		word1_edit.text = current_selected_word
	word1_hbox.add_child(word1_edit)
	
	var word2_hbox = HBoxContainer.new()
	vbox.add_child(word2_hbox)
	
	var word2_label = Label.new()
	word2_label.text = "Word 2:"
	word2_hbox.add_child(word2_label)
	
	var word2_edit = LineEdit.new()
	word2_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word2_hbox.add_child(word2_edit)
	
	var context_hbox = HBoxContainer.new()
	vbox.add_child(context_hbox)
	
	var context_label = Label.new()
	context_label.text = "Context:"
	context_hbox.add_child(context_label)
	
	var context_edit = LineEdit.new()
	context_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	context_edit.placeholder_text = "e.g. heat=0.8,moisture=0.2"
	context_hbox.add_child(context_edit)
	
	add_child(dialog)
	
	dialog.confirmed.connect(func():
		var word1_id = word1_edit.text.strip_edges()
		var word2_id = word2_edit.text.strip_edges()
		var context_str = context_edit.text.strip_edges()
		
		if word1_id.is_empty() or word2_id.is_empty():
			return
		
		# Parse context
		var context = {}
		if not context_str.is_empty():
			var parts = context_str.split(",")
			for part in parts:
				var kv = part.split("=")
				if kv.size() == 2:
					var key = kv[0].strip_edges()
					var val = kv[1].strip_edges()
					
					if val.is_valid_float():
						val = float(val)
					elif val == "true":
						val = true
					elif val == "false":
						val = false
					
					context[key] = val
		
		# Test interaction
		var result = akashic_records_manager.process_word_interaction(word1_id, word2_id, context)
		
		# Show result
		var result_dialog = AcceptDialog.new()
		result_dialog.title = "Interaction Result"
		result_dialog.dialog_text = str(result)
		result_dialog.size = Vector2(400, 300)
		add_child(result_dialog)
		
		result_dialog.confirmed.connect(func():
			result_dialog.queue_free()
		)
		
		result_dialog.popup_centered()
		
		dialog.queue_free()
	)
	
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	
	dialog.popup_centered()

func _on_save_button_pressed():
	if akashic_records_manager.save_all():
		status_label.text = "Akashic Records saved"
	else:
		status_label.text = "Failed to save Akashic Records"
