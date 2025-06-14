extends Control
class_name ThingCreatorUI

# References
var akashic_records_manager = null
var thing_creator = null

# UI elements
@onready var word_list = $Panel/HSplitContainer/LeftPanel/WordList
@onready var properties_container = $Panel/HSplitContainer/RightPanel/ScrollContainer/VBoxContainer/PropertiesContainer
@onready var custom_props_container = $Panel/HSplitContainer/RightPanel/ScrollContainer/VBoxContainer/CustomPropsContainer
@onready var preview_viewport = $Panel/HSplitContainer/RightPanel/PreviewContainer/SubViewportContainer/SubViewport
@onready var preview_camera = $Panel/HSplitContainer/RightPanel/PreviewContainer/SubViewportContainer/SubViewport/Camera3D
@onready var position_x = $Panel/HSplitContainer/RightPanel/ScrollContainer/VBoxContainer/PositionContainer/XBox/XValue
@onready var position_y = $Panel/HSplitContainer/RightPanel/ScrollContainer/VBoxContainer/PositionContainer/YBox/YValue
@onready var position_z = $Panel/HSplitContainer/RightPanel/ScrollContainer/VBoxContainer/PositionContainer/ZBox/ZValue
@onready var search_field = $Panel/HSplitContainer/LeftPanel/SearchBox/SearchField
@onready var category_filter = $Panel/HSplitContainer/LeftPanel/SearchBox/CategoryFilter
@onready var status_label = $Panel/StatusBar/StatusLabel

# Preview instance
var preview_instance = null
var selected_word_id = ""
var temp_custom_props = {}

# Signals
signal thing_created(thing_id, word_id, position)

func _ready():
	# Find AkashicRecordsManager
	if has_node("/root/AkashicRecordsManager"):
		akashic_records_manager = get_node("/root/AkashicRecordsManager")
	else:
		push_error("AkashicRecordsManager not found!")
		status_label.text = "Error: AkashicRecordsManager not found!"
		return
	
	# Create ThingCreator if not already available
	if has_node("/root/ThingCreator"):
		thing_creator = get_node("/root/ThingCreator")
	else:
		var ThingCreatorClass = load("res://code/gdscript/scripts/akashic_records/thing_creator.gd")
		if ThingCreatorClass:
			thing_creator = ThingCreatorClass.new()
			thing_creator.name = "ThingCreator"
			get_tree().root.add_child(thing_creator)
		else:
			push_error("ThingCreator class not found!")
			status_label.text = "Error: ThingCreator class not found!"
			return
	
	# Connect signals
	word_list.item_selected.connect(_on_word_selected)
	search_field.text_changed.connect(_on_search_text_changed)
	category_filter.item_selected.connect(_on_category_selected)
	thing_creator.thing_created.connect(_on_thing_created)
	
	# Connect to Thing Creator signals
	thing_creator.thing_created.connect(_on_thing_created)
	
	# Set up preview environment
	_setup_preview_environment()
	
	# Populate UI
	_populate_category_filter()
	_populate_word_list()
	
	status_label.text = "Thing Creator UI initialized"

# Set up the 3D preview environment
func _setup_preview_environment():
	# Add a simple environment
	var environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.1, 0.1, 0.12)
	environment.ambient_light_color = Color(0.2, 0.2, 0.2)
	environment.ambient_light_energy = 1.0
	
	# Add environment to preview viewport
	preview_viewport.world_3d.environment = environment
	
	# Set up basic lighting
	var directional_light = DirectionalLight3D.new()
	directional_light.transform.basis = Basis.looking_at(Vector3(0.5, -0.7, 0.5).normalized())
	directional_light.light_color = Color(1.0, 0.98, 0.9)
	directional_light.light_energy = 1.2
	directional_light.shadow_enabled = true
	preview_viewport.add_child(directional_light)
	
	# Position camera
	preview_camera.global_position = Vector3(0, 0, 3)
	preview_camera.look_at(Vector3.ZERO)

# Populate the word list
func _populate_word_list():
	word_list.clear()
	
	var query = search_field.text
	var category = ""
	if category_filter.selected > 0:  # Skip "All" option
		category = category_filter.get_item_text(category_filter.selected)
	
	var words = akashic_records_manager.search_words(query, category)
	
	for word_id in words:
		var word = akashic_records_manager.dynamic_dictionary.get_word(word_id)
		if not word:
			continue
			
		word_list.add_item(word_id)
		
		# Set icon based on category
		var icon_index = word_list.get_item_count() - 1
		match word.category:
			"element":
				# Set element icon
				pass
			"entity":
				# Set entity icon
				pass
			"concept":
				# Set concept icon
				pass
	
	status_label.text = "Found " + str(words.size()) + " words"

# Populate the category filter dropdown
func _populate_category_filter():
	category_filter.clear()
	
	# Add "All" option
	category_filter.add_item("All")
	
	# Get all unique categories
	var categories = {}
	for word_id in akashic_records_manager.dynamic_dictionary.words:
		var word = akashic_records_manager.dynamic_dictionary.get_word(word_id)
		if word:
			categories[word.category] = true
	
	# Add to dropdown
	for category in categories:
		category_filter.add_item(category)

# Update the properties display for the selected word
func _update_properties_display(word_id: String):
	# Clear current properties
	for child in properties_container.get_children():
		properties_container.remove_child(child)
		child.queue_free()
	
	# Clear custom properties
	for child in custom_props_container.get_children():
		custom_props_container.remove_child(child)
		child.queue_free()
	
	if word_id.is_empty():
		return
	
	var dictionary = akashic_records_manager.dynamic_dictionary
	var word = dictionary.get_word(word_id)
	if not word:
		return
	
	# Display properties
	var props_label = Label.new()
	props_label.text = "Word Properties:"
	props_label.add_theme_font_size_override("font_size", 14)
	properties_container.add_child(props_label)
	
	# Add properties as read-only displays
	for prop_name in word.properties:
		var prop_value = word.properties[prop_name]
		
		var prop_container = HBoxContainer.new()
		properties_container.add_child(prop_container)
		
		var name_label = Label.new()
		name_label.text = prop_name + ":"
		name_label.custom_minimum_size.x = 120
		prop_container.add_child(name_label)
		
		var value_label = Label.new()
		value_label.text = str(prop_value)
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		prop_container.add_child(value_label)
	
	# Add custom properties section
	var custom_label = Label.new()
	custom_label.text = "Custom Instance Properties:"
	custom_label.add_theme_font_size_override("font_size", 14)
	custom_props_container.add_child(custom_label)
	
	# Reset custom properties for this word
	temp_custom_props = {}
	
	# Add button to add custom properties
	var add_prop_button = Button.new()
	add_prop_button.text = "Add Custom Property"
	add_prop_button.pressed.connect(_on_add_custom_property)
	custom_props_container.add_child(add_prop_button)
	
	# Create preview
	_create_preview(word_id)

# Create a 3D preview of the selected word
func _create_preview(word_id: String):
	# Clear current preview
	if preview_instance:
		preview_instance.queue_free()
		preview_instance = null
	
	if word_id.is_empty():
		return
	
	var dictionary = akashic_records_manager.dynamic_dictionary
	var word = dictionary.get_word(word_id)
	if not word:
		return
	
	# Create new preview instance using ThingCreator's visualization code
	var position = Vector3.ZERO
	preview_instance = thing_creator._create_visual_representation(word, position)
	
	if preview_instance:
		preview_viewport.add_child(preview_instance)
		
		# Set preview instance at origin
		preview_instance.global_position = Vector3.ZERO
		
		# Start rotation animation
		var tween = create_tween().set_loops()
		tween.tween_property(preview_instance, "rotation:y", 2*PI, 5.0).from(0.0)

# Create a thing in the world
func create_thing():
	if selected_word_id.is_empty() or not thing_creator:
		status_label.text = "No word selected or Thing Creator not available"
		return
	
	# Get position from UI
	var position = Vector3(
		position_x.value,
		position_y.value,
		position_z.value
	)
	
	# Create the thing
	var thing_id = thing_creator.create_thing(selected_word_id, position, temp_custom_props)
	
	if not thing_id.is_empty():
		status_label.text = "Created thing: " + thing_id
		emit_signal("thing_created", thing_id, selected_word_id, position)
	else:
		status_label.text = "Failed to create thing from word: " + selected_word_id

# Handle adding a custom property
func _on_add_custom_property():
	var dialog = ConfirmationDialog.new()
	dialog.title = "Add Custom Property"
	dialog.size = Vector2(400, 150)
	
	var vbox = VBoxContainer.new()
	vbox.anchor_right = 1.0
	vbox.anchor_bottom = 1.0
	vbox.position = Vector2(10, 10)
	vbox.size = dialog.size - Vector2(20, 50)
	dialog.add_child(vbox)
	
	var name_hbox = HBoxContainer.new()
	vbox.add_child(name_hbox)
	
	var name_label = Label.new()
	name_label.text = "Property Name:"
	name_hbox.add_child(name_label)
	
	var name_edit = LineEdit.new()
	name_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_hbox.add_child(name_edit)
	
	var value_hbox = HBoxContainer.new()
	vbox.add_child(value_hbox)
	
	var value_label = Label.new()
	value_label.text = "Property Value:"
	value_hbox.add_child(value_label)
	
	var value_edit = LineEdit.new()
	value_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_hbox.add_child(value_edit)
	
	add_child(dialog)
	
	dialog.confirmed.connect(func():
		var prop_name = name_edit.text.strip_edges()
		var prop_value = value_edit.text.strip_edges()
		
		if prop_name.is_empty():
			return
		
		# Try to convert value to appropriate type
		if prop_value.is_valid_float():
			prop_value = float(prop_value)
		elif prop_value == "true":
			prop_value = true
		elif prop_value == "false":
			prop_value = false
		
		# Add to temp custom properties
		temp_custom_props[prop_name] = prop_value
		
		# Update display
		_update_custom_props_display()
		
		dialog.queue_free()
	)
	
	dialog.canceled.connect(func():
		dialog.queue_free()
	)
	
	dialog.popup_centered()

# Update the display of custom properties
func _update_custom_props_display():
	# Clear existing custom property displays (keep the label and button)
	var children_to_keep = []
	for i in range(custom_props_container.get_child_count()):
		if i < 2:  # Keep the first two children (label and button)
			children_to_keep.append(custom_props_container.get_child(i))
		else:
			var child = custom_props_container.get_child(i)
			custom_props_container.remove_child(child)
			child.queue_free()
	
	# Clear container and re-add keepers
	for child in custom_props_container.get_children():
		custom_props_container.remove_child(child)
	
	for child in children_to_keep:
		custom_props_container.add_child(child)
	
	# Add custom properties
	for prop_name in temp_custom_props:
		var prop_value = temp_custom_props[prop_name]
		
		var prop_container = HBoxContainer.new()
		custom_props_container.add_child(prop_container)
		
		var name_label = Label.new()
		name_label.text = prop_name + ":"
		name_label.custom_minimum_size.x = 120
		prop_container.add_child(name_label)
		
		var value_label = Label.new()
		value_label.text = str(prop_value)
		value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		prop_container.add_child(value_label)
		
		var remove_button = Button.new()
		remove_button.text = "X"
		remove_button.pressed.connect(_on_remove_custom_property.bind(prop_name))
		prop_container.add_child(remove_button)
	
	# Move the "Add" button to the end
	var add_button = custom_props_container.get_child(1)
	custom_props_container.move_child(add_button, custom_props_container.get_child_count() - 1)

# Handle removing a custom property
func _on_remove_custom_property(prop_name: String):
	temp_custom_props.erase(prop_name)
	_update_custom_props_display()

# Signal handlers
func _on_word_selected(index: int):
	var word_id = word_list.get_item_text(index)
	selected_word_id = word_id
	_update_properties_display(word_id)

func _on_search_text_changed(new_text: String):
	_populate_word_list()

func _on_category_selected(index: int):
	_populate_word_list()

func _on_thing_created(thing_id: String, word_id: String, position: Vector3):
	# Clear temporary custom properties
	temp_custom_props = {}
	_update_custom_props_display()
	
	# Update status
	status_label.text = "Thing created: " + thing_id + " (from word: " + word_id + ")"

func _on_create_button_pressed():
	create_thing()

func _on_close_button_pressed():
	# Hide UI
	if get_parent() and get_parent().has_method("hide"):
		get_parent().hide()
	elif visible:
		visible = false
