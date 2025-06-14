extends Node
class_name ThingCreatorStandaloneUI

# This script creates a standalone menu for the Thing Creator
# Use this if your scene doesn't have a suitable menu system

var thing_creator = null
var akashic_records_manager = null
var ui_visible = false
var current_ui_instance = null

# UI elements
var ui_container = null
var menu_panel = null
var view_area = null

func _ready():
	# Wait a moment for the scene to fully initialize
	await get_tree().create_timer(0.5).timeout
	
	print("==== Thing Creator Standalone Starting ====")
	
	# Find required components
	find_akashic_records()
	
	# Set up Thing Creator
	setup_thing_creator()
	
	# Create UI
	create_ui()
	
	print("==== Thing Creator Standalone Complete ====")
	print("Press 'T' to toggle the Thing Creator menu")

func _input(event):
	# Toggle UI with T key
	if event is InputEventKey and event.pressed and event.keycode == KEY_T:
		toggle_ui()

func find_akashic_records():
	print("Searching for AkashicRecordsManager...")
	
	if has_node("/root/AkashicRecordsManager"):
		akashic_records_manager = get_node("/root/AkashicRecordsManager")
		print("Found AkashicRecordsManager")
		return
	
	# Try to find by searching all nodes
	akashic_records_manager = find_node_by_class("AkashicRecordsManager")
	if akashic_records_manager:
		print("Found AkashicRecordsManager by search")
		return
	
	print("Could not find AkashicRecordsManager node")
	print("Make sure Akashic Records is initialized")

func setup_thing_creator():
	print("Setting up Thing Creator...")
	
	# Check if already exists
	if has_node("/root/ThingCreator"):
		thing_creator = get_node("/root/ThingCreator")
		print("ThingCreator already exists")
		return
	
	# Create new instance
	var ThingCreatorClass = load("res://code/gdscript/scripts/akashic_records/thing_creator.gd")
	if ThingCreatorClass:
		thing_creator = ThingCreatorClass.new()
		thing_creator.name = "ThingCreator"
		get_tree().root.add_child(thing_creator)
		print("Created new ThingCreator instance")
	else:
		print("Failed to load ThingCreator class")

func create_ui():
	print("Creating standalone UI...")
	
	# Create the main UI container
	ui_container = Control.new()
	ui_container.name = "ThingCreatorUI"
	ui_container.anchor_right = 1.0
	ui_container.anchor_bottom = 1.0
	ui_container.visible = false  # Start hidden
	
	# Create a semi-transparent background panel
	var bg_panel = Panel.new()
	bg_panel.name = "Background"
	bg_panel.anchor_right = 1.0
	bg_panel.anchor_bottom = 1.0
	
	# Set up a style with semi-transparency
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	bg_panel.add_theme_stylebox_override("panel", style)
	
	ui_container.add_child(bg_panel)
	
	# Create a horizontal split layout
	var h_split = HSplitContainer.new()
	h_split.name = "Layout"
	h_split.anchor_right = 1.0
	h_split.anchor_bottom = 1.0
	h_split.split_offset = 200  # Width of the menu panel
	
	bg_panel.add_child(h_split)
	
	# Create the menu panel
	menu_panel = VBoxContainer.new()
	menu_panel.name = "MenuPanel"
	
	h_split.add_child(menu_panel)
	
	# Add title
	var title = Label.new()
	title.text = "Thing Creator"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	menu_panel.add_child(title)
	
	# Add menu buttons
	create_menu_buttons()
	
	# Create view area for content
	view_area = Control.new()
	view_area.name = "ViewArea"
	
	h_split.add_child(view_area)
	
	# Add to the scene
	get_tree().root.add_child(ui_container)
	
	print("Standalone UI created - press 'T' to toggle")

func create_menu_buttons():
	# Create the "Create Thing" button
	var create_button = Button.new()
	create_button.text = "Create Thing"
	create_button.pressed.connect(_on_create_thing_button_pressed)
	menu_panel.add_child(create_button)
	
	# Create the "Manage Things" button
	var manage_button = Button.new()
	manage_button.text = "Manage Things"
	manage_button.pressed.connect(_on_manage_things_button_pressed)
	menu_panel.add_child(manage_button)
	
	# Create the "Dictionary" button
	var dictionary_button = Button.new()
	dictionary_button.text = "Dictionary"
	dictionary_button.pressed.connect(_on_dictionary_button_pressed)
	menu_panel.add_child(dictionary_button)
	
	# Create the "Spawn Snake" button
	var snake_button = Button.new()
	snake_button.text = "Spawn Snake"
	snake_button.pressed.connect(_on_spawn_snake_button_pressed)
	menu_panel.add_child(snake_button)
	
	# Create the "Help" button
	var help_button = Button.new()
	help_button.text = "Help"
	help_button.pressed.connect(_on_help_button_pressed)
	menu_panel.add_child(help_button)
	
	# Add close button at the bottom
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	menu_panel.add_child(spacer)
	
	var close_button = Button.new()
	close_button.text = "Close Menu (T)"
	close_button.pressed.connect(_on_close_button_pressed)
	menu_panel.add_child(close_button)

func toggle_ui():
	ui_visible = !ui_visible
	ui_container.visible = ui_visible

func _close_current_ui():
	if current_ui_instance and is_instance_valid(current_ui_instance):
		current_ui_instance.queue_free()
		current_ui_instance = null

func open_thing_creator_ui():
	# Close existing UI if open
	_close_current_ui()
	
	# Load the Thing Creator UI scene
	var thing_creator_ui_scene = load("res://code/gdscript/scenes/thing_creator_ui.tscn")
	if not thing_creator_ui_scene:
		print("Error: Thing Creator UI scene not found")
		return
	
	# Instance the UI
	current_ui_instance = thing_creator_ui_scene.instantiate()
	
	# Add to view area
	view_area.add_child(current_ui_instance)
	
	print("Thing Creator UI opened")

func show_message(message):
	print(message)

# Button handlers
func _on_create_thing_button_pressed():
	open_thing_creator_ui()

func _on_manage_things_button_pressed():
	# Close existing UI if open
	_close_current_ui()
	
	# Create a simple thing manager UI
	var manager = VBoxContainer.new()
	manager.name = "ThingManager"
	
	var title = Label.new()
	title.text = "Thing Manager"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	manager.add_child(title)
	
	var list = ItemList.new()
	list.name = "ThingsList"
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	manager.add_child(list)
	
	# Populate list if thing creator exists
	if thing_creator:
		var things = thing_creator.get_all_things()
		for thing_id in things:
			var word_id = thing_creator.get_thing_word(thing_id)
			var position = thing_creator.get_thing_position(thing_id)
			list.add_item(thing_id + " (" + word_id + ") at " + str(position))
	
	var button_container = HBoxContainer.new()
	manager.add_child(button_container)
	
	var refresh_button = Button.new()
	refresh_button.text = "Refresh"
	refresh_button.pressed.connect(func(): _on_manage_things_button_pressed())
	button_container.add_child(refresh_button)
	
	var remove_button = Button.new()
	remove_button.text = "Remove Selected"
	button_container.add_child(remove_button)
	
	# Set current UI
	current_ui_instance = manager
	view_area.add_child(current_ui_instance)
	
	print("Thing Manager opened")

func _on_dictionary_button_pressed():
	# Close existing UI if open
	_close_current_ui()
	
	# Try to load the Akashic Records UI
	var akashic_records_ui_scene = load("res://code/gdscript/scenes/akashic_records_ui.tscn")
	if akashic_records_ui_scene:
		current_ui_instance = akashic_records_ui_scene.instantiate()
		view_area.add_child(current_ui_instance)
		print("Dictionary UI opened")
	else:
		print("Error: Akashic Records UI scene not found")

func _on_spawn_snake_button_pressed():
	# Close existing UI if open
	_close_current_ui()
	
	# Create snake spawner UI
	var snake_panel = VBoxContainer.new()
	snake_panel.name = "SnakePanel"
	
	var title = Label.new()
	title.text = "Space Snake Spawner"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 16)
	snake_panel.add_child(title)
	
	var description = Label.new()
	description.text = "Spawn a cosmic space snake that travels through the void. The snake will interact with elements in your world."
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.custom_minimum_size.y = 80
	snake_panel.add_child(description)
	
	var spawn_button = Button.new()
	spawn_button.text = "Spawn Snake"
	spawn_button.pressed.connect(func():
		# Try to find or load snake spawner
		var snake_spawner = null
		if has_node("/root/SnakeSpawner"):
			snake_spawner = get_node("/root/SnakeSpawner")
		else:
			# Try to create a new spawner
			var spawner_script = load("res://code/gdscript/scripts/Snake_Space_Movement/snake_spawner.gd")
			if spawner_script:
				snake_spawner = spawner_script.new()
				snake_spawner.name = "SnakeSpawner"
				get_tree().root.add_child(snake_spawner)
		
		if snake_spawner and snake_spawner.has_method("spawn_snake_at_player"):
			snake_spawner.spawn_snake_at_player()
			var info_label = Label.new()
			info_label.text = "Snake spawned! Look around you in the 3D space."
			snake_panel.add_child(info_label)
		else:
			var error_label = Label.new()
			error_label.text = "Error: Could not spawn snake. Snake spawner not found."
			snake_panel.add_child(error_label)
	)
	
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	button_container.add_child(spawn_button)
	snake_panel.add_child(button_container)
	
	# Set as current UI
	current_ui_instance = snake_panel
	view_area.add_child(current_ui_instance)
	
	print("Snake spawner UI opened")

func _on_help_button_pressed():
	# Close existing UI if open
	_close_current_ui()
	
	# Create a help UI
	var help = VBoxContainer.new()
	help.name = "HelpPanel"
	
	var title = Label.new()
	title.text = "Thing Creator Help"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	help.add_child(title)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	help.add_child(scroll)
	
	var content = VBoxContainer.new()
	scroll.add_child(content)
	
	# Add help text
	var sections = [
		{"title": "Getting Started", "content": "The Thing Creator allows you to create physical objects in the game world based on dictionary entries. Start by selecting a word from the dictionary and setting a position."},
		{"title": "Create Thing", "content": "Opens the Thing Creator UI where you can select dictionary entries and create objects at specific positions in the game world."},
		{"title": "Manage Things", "content": "Shows a list of all created things and allows you to remove them."},
		{"title": "Dictionary", "content": "Opens the Akashic Records dictionary where you can view and edit dictionary entries."},
		{"title": "Spawn Snake", "content": "Creates a cosmic space snake that travels through the void. The snake interacts with elements in your world and can be used for testing interactions between entities."},
		{"title": "Keyboard Shortcuts", "content": "Press 'T' to toggle this menu at any time."}
	]
	
	for section in sections:
		var section_title = Label.new()
		section_title.text = section["title"]
		section_title.add_theme_font_size_override("font_size", 16)
		content.add_child(section_title)
		
		var section_content = Label.new()
		section_content.text = section["content"]
		section_content.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_child(section_content)
		
		# Add spacing
		var spacer = Control.new()
		spacer.custom_minimum_size.y = 10
		content.add_child(spacer)
	
	# Set current UI
	current_ui_instance = help
	view_area.add_child(current_ui_instance)
	
	print("Help opened")

func _on_close_button_pressed():
	toggle_ui()

# Recursive function to find a node by class
func find_node_by_class(class_name_to_find, node = null):
	if node == null:
		node = get_tree().root
	
	if node.get_class() == class_name_to_find:
		return node
	
	for child in node.get_children():
		var found = find_node_by_class(class_name_to_find, child)
		if found:
			return found
	
	return null
