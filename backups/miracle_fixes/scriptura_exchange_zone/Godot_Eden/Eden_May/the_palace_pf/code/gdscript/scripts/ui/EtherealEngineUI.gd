extends Node
class_name EtherealEngineUI

# References
var thing_creator = null
var main_controller = null
var camera = null
var behavior_system = null

# UI components
var ui_root = null
var console_panel = null
var creation_panel = null
var info_panel = null
var pattern_panel = null
var behavior_panel = null

# UI state
var ui_visible = false
var current_panel = null
var console_history = []
var console_index = -1

# Command history
var command_history = []
var history_index = -1

func _ready():
	# Wait a moment for the scene to fully initialize
	await get_tree().create_timer(0.5).timeout
	
	print("EtherealEngineUI initializing...")
	
	# Find required components
	find_required_components()
	
	# Create UI
	create_ui()
	
	# Set up input handling
	set_process_input(true)
	
	print("EtherealEngineUI initialization complete")
	print("Press 'Tab' to toggle the interface")

func _input(event):
	# Toggle UI with Tab key
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		toggle_ui()
	
	# Process console input if visible
	if ui_visible and current_panel == console_panel:
		# Command history navigation
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_UP:
				# Navigate history backward
				if history_index < command_history.size() - 1:
					history_index += 1
					set_console_input(command_history[command_history.size() - 1 - history_index])
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_DOWN:
				# Navigate history forward
				if history_index > 0:
					history_index -= 1
					set_console_input(command_history[command_history.size() - 1 - history_index])
				elif history_index == 0:
					history_index = -1
					set_console_input("")
				get_viewport().set_input_as_handled()

func find_required_components():
	# Find the main controller
	if has_node("/root/main"):
		main_controller = get_node("/root/main")

	# Find the camera
	if main_controller and main_controller.has_node("Player_Head/cameramove/TrackballCamera"):
		camera = main_controller.get_node("Player_Head/cameramove/TrackballCamera")

	# Find or create ThingCreator
	if has_node("/root/CoreThingCreator"):
		thing_creator = get_node("/root/CoreThingCreator")
	else:
		# Try to load the script
		var thing_creator_script = load("res://code/gdscript/scripts/core/CoreThingCreator.gd")
		if thing_creator_script:
			var ThingCreatorClass = thing_creator_script
			thing_creator = ThingCreatorClass.get_instance()
			thing_creator.name = "CoreThingCreator"
			get_tree().root.add_child(thing_creator)
			print("Created CoreThingCreator instance")
		else:
			push_error("CoreThingCreator script not found!")

	# Find or create behavior system
	if has_node("/root/EntityBehaviorSystem"):
		behavior_system = get_node("/root/EntityBehaviorSystem")
	else:
		# Try to load the script
		var behavior_script = load("res://code/gdscript/scripts/core/EntityBehaviorSystem.gd")
		if behavior_script:
			behavior_system = behavior_script.get_instance()
			behavior_system.name = "EntityBehaviorSystem"
			get_tree().root.add_child(behavior_system)
			print("Created EntityBehaviorSystem instance")
		else:
			push_error("EntityBehaviorSystem script not found!")

# Core UI setup

func create_ui():
	# Create the UI root
	ui_root = Control.new()
	ui_root.name = "EtherealEngineUI"
	ui_root.anchor_right = 1.0
	ui_root.anchor_bottom = 1.0
	ui_root.visible = false  # Start hidden
	
	# Create a semi-transparent background
	var background = ColorRect.new()
	background.name = "Background"
	background.anchor_right = 1.0
	background.anchor_bottom = 1.0
	background.color = Color(0.1, 0.1, 0.1, 0.8)
	ui_root.add_child(background)
	
	# Create a main container
	var main_container = VBoxContainer.new()
	main_container.name = "MainContainer"
	main_container.anchor_right = 1.0
	main_container.anchor_bottom = 1.0
	main_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.custom_minimum_size = Vector2(800, 600)
	ui_root.add_child(main_container)
	
	# Create a title bar
	var title_bar = HBoxContainer.new()
	title_bar.name = "TitleBar"
	main_container.add_child(title_bar)
	
	var title = Label.new()
	title.text = "JSH Ethereal Engine"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 20)
	title_bar.add_child(title)
	
	# Create tab buttons
	var tab_container = HBoxContainer.new()
	tab_container.name = "TabContainer"
	main_container.add_child(tab_container)
	
	# Create console tab
	var console_button = Button.new()
	console_button.text = "Command Console"
	console_button.pressed.connect(_on_console_tab_pressed)
	tab_container.add_child(console_button)
	
	# Create creation tab
	var creation_button = Button.new()
	creation_button.text = "Entity Creation"
	creation_button.pressed.connect(_on_creation_tab_pressed)
	tab_container.add_child(creation_button)
	
	# Create pattern tab
	var pattern_button = Button.new()
	pattern_button.text = "Pattern Generator"
	pattern_button.pressed.connect(_on_pattern_tab_pressed)
	tab_container.add_child(pattern_button)
	
	# Create info tab
	var info_button = Button.new()
	info_button.text = "Information"
	info_button.pressed.connect(_on_info_tab_pressed)
	tab_container.add_child(info_button)

	# Create behavior tab
	var behavior_button = Button.new()
	behavior_button.text = "Behaviors"
	behavior_button.pressed.connect(_on_behavior_tab_pressed)
	tab_container.add_child(behavior_button)

	# Create close button
	var close_button = Button.new()
	close_button.text = "Close (Tab)"
	close_button.pressed.connect(toggle_ui)
	tab_container.add_child(close_button)
	
	# Create panel container
	var panel_container = Control.new()
	panel_container.name = "PanelContainer"
	panel_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(panel_container)
	
	# Create console panel
	console_panel = create_console_panel()
	panel_container.add_child(console_panel)
	
	# Create entity creation panel
	creation_panel = create_creation_panel()
	panel_container.add_child(creation_panel)
	
	# Create pattern panel
	pattern_panel = create_pattern_panel()
	panel_container.add_child(pattern_panel)
	
	# Create info panel
	info_panel = create_info_panel()
	panel_container.add_child(info_panel)

	# Create behavior panel
	behavior_panel = create_behavior_panel()
	panel_container.add_child(behavior_panel)

	# Set initial panel
	current_panel = console_panel
	hide_all_panels()
	console_panel.visible = true
	
	# Add UI to the scene
	get_tree().root.add_child(ui_root)

func toggle_ui():
	ui_visible = !ui_visible
	ui_root.visible = ui_visible
	
	if ui_visible and current_panel == console_panel:
		# Focus the input field
		var input_field = console_panel.get_node("VBoxContainer/InputContainer/ConsoleInput")
		input_field.grab_focus()

func hide_all_panels():
	console_panel.visible = false
	creation_panel.visible = false
	pattern_panel.visible = false
	info_panel.visible = false
	behavior_panel.visible = false

# Panel creation functions

func create_console_panel():
	var panel = Control.new()
	panel.name = "ConsolePanel"
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	
	var layout = VBoxContainer.new()
	layout.name = "VBoxContainer"
	layout.anchor_right = 1.0
	layout.anchor_bottom = 1.0
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(layout)
	
	# Output area
	var scroll = ScrollContainer.new()
	scroll.name = "OutputScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)
	
	var output = RichTextLabel.new()
	output.name = "ConsoleOutput"
	output.bbcode_enabled = true
	output.text = "JSH Ethereal Engine Console\n"
	output.text += "-------------------------\n"
	output.text += "Type 'help' for a list of commands.\n\n"
	output.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	output.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	scroll.add_child(output)
	
	# Input area
	var input_container = HBoxContainer.new()
	input_container.name = "InputContainer"
	layout.add_child(input_container)
	
	var prompt = Label.new()
	prompt.text = "> "
	input_container.add_child(prompt)
	
	var input_field = LineEdit.new()
	input_field.name = "ConsoleInput"
	input_field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	input_field.placeholder_text = "Enter command..."
	input_field.text_submitted.connect(_on_console_input_submitted)
	input_container.add_child(input_field)
	
	var submit_button = Button.new()
	submit_button.text = "Send"
	submit_button.pressed.connect(func(): _on_console_input_submitted(input_field.text))
	input_container.add_child(submit_button)
	
	return panel

func create_creation_panel():
	var panel = Control.new()
	panel.name = "CreationPanel"
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	
	var layout = VBoxContainer.new()
	layout.anchor_right = 1.0
	layout.anchor_bottom = 1.0
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(layout)
	
	# Title
	var title = Label.new()
	title.text = "Entity Creation"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	layout.add_child(title)
	
	# Word input
	var word_container = HBoxContainer.new()
	layout.add_child(word_container)
	
	var word_label = Label.new()
	word_label.text = "Word: "
	word_container.add_child(word_label)
	
	var word_input = LineEdit.new()
	word_input.name = "WordInput"
	word_input.placeholder_text = "Enter a word..."
	word_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word_container.add_child(word_input)
	
	# Position controls
	var pos_container = HBoxContainer.new()
	layout.add_child(pos_container)
	
	var pos_label = Label.new()
	pos_label.text = "Position: "
	pos_container.add_child(pos_label)
	
	var pos_x = SpinBox.new()
	pos_x.name = "PosX"
	pos_x.min_value = -100
	pos_x.max_value = 100
	pos_x.step = 0.5
	pos_x.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pos_container.add_child(pos_x)
	
	var pos_y = SpinBox.new()
	pos_y.name = "PosY"
	pos_y.min_value = -100
	pos_y.max_value = 100
	pos_y.step = 0.5
	pos_y.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pos_container.add_child(pos_y)
	
	var pos_z = SpinBox.new()
	pos_z.name = "PosZ"
	pos_z.min_value = -100
	pos_z.max_value = 100
	pos_z.step = 0.5
	pos_z.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pos_container.add_child(pos_z)
	
	# Use camera position button
	var camera_button = Button.new()
	camera_button.text = "Use Camera Position"
	camera_button.pressed.connect(_on_use_camera_position_pressed)
	layout.add_child(camera_button)
	
	# Evolution stage
	var evo_container = HBoxContainer.new()
	layout.add_child(evo_container)
	
	var evo_label = Label.new()
	evo_label.text = "Evolution Stage: "
	evo_container.add_child(evo_label)
	
	var evo_slider = HSlider.new()
	evo_slider.name = "EvoSlider"
	evo_slider.min_value = 0
	evo_slider.max_value = 5
	evo_slider.step = 1
	evo_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	evo_container.add_child(evo_slider)
	
	var evo_value = Label.new()
	evo_value.name = "EvoValue"
	evo_value.text = "0"
	evo_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	evo_container.add_child(evo_value)
	
	# Connect slider value change
	evo_slider.value_changed.connect(func(value): evo_value.text = str(int(value)))
	
	# Create button
	var create_button = Button.new()
	create_button.text = "Create Entity"
	create_button.pressed.connect(_on_create_entity_button_pressed)
	layout.add_child(create_button)
	
	# Spacer
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(spacer)
	
	# Entity list
	var list_title = Label.new()
	list_title.text = "Active Entities"
	list_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(list_title)
	
	var entity_list = ItemList.new()
	entity_list.name = "EntityList"
	entity_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	entity_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(entity_list)
	
	# Control buttons
	var button_container = HBoxContainer.new()
	layout.add_child(button_container)
	
	var refresh_button = Button.new()
	refresh_button.text = "Refresh List"
	refresh_button.pressed.connect(_on_refresh_entity_list_pressed)
	button_container.add_child(refresh_button)
	
	var remove_button = Button.new()
	remove_button.text = "Remove Selected"
	remove_button.pressed.connect(_on_remove_entity_pressed)
	button_container.add_child(remove_button)
	
	var evolve_button = Button.new()
	evolve_button.text = "Evolve Selected"
	evolve_button.pressed.connect(_on_evolve_entity_pressed)
	button_container.add_child(evolve_button)
	
	return panel

func create_pattern_panel():
	var panel = Control.new()
	panel.name = "PatternPanel"
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	
	var layout = VBoxContainer.new()
	layout.anchor_right = 1.0
	layout.anchor_bottom = 1.0
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(layout)
	
	# Title
	var title = Label.new()
	title.text = "Pattern Generator"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	layout.add_child(title)
	
	# Description
	var description = Label.new()
	description.text = "Create patterns of entities in different arrangements."
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(description)
	
	# Word input
	var word_container = HBoxContainer.new()
	layout.add_child(word_container)
	
	var word_label = Label.new()
	word_label.text = "Word: "
	word_container.add_child(word_label)
	
	var word_input = LineEdit.new()
	word_input.name = "PatternWordInput"
	word_input.placeholder_text = "Enter a word..."
	word_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word_container.add_child(word_input)
	
	# Pattern type
	var type_container = HBoxContainer.new()
	layout.add_child(type_container)
	
	var type_label = Label.new()
	type_label.text = "Pattern Type: "
	type_container.add_child(type_label)
	
	var type_option = OptionButton.new()
	type_option.name = "PatternType"
	type_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_option.add_item("Circle", 0)
	type_option.add_item("Grid", 1)
	type_option.add_item("Random", 2)
	type_option.add_item("Sphere", 3)
	type_container.add_child(type_option)
	
	# Count and radius
	var params_container = HBoxContainer.new()
	layout.add_child(params_container)
	
	var count_label = Label.new()
	count_label.text = "Count: "
	params_container.add_child(count_label)
	
	var count_spinner = SpinBox.new()
	count_spinner.name = "PatternCount"
	count_spinner.min_value = 1
	count_spinner.max_value = 50
	count_spinner.value = 5
	count_spinner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	params_container.add_child(count_spinner)
	
	var radius_label = Label.new()
	radius_label.text = "Radius: "
	params_container.add_child(radius_label)
	
	var radius_spinner = SpinBox.new()
	radius_spinner.name = "PatternRadius"
	radius_spinner.min_value = 1
	radius_spinner.max_value = 50
	radius_spinner.value = 5
	radius_spinner.step = 0.5
	radius_spinner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	params_container.add_child(radius_spinner)
	
	# Position controls
	var pos_container = HBoxContainer.new()
	layout.add_child(pos_container)
	
	var pos_label = Label.new()
	pos_label.text = "Center Position: "
	pos_container.add_child(pos_label)
	
	var pos_x = SpinBox.new()
	pos_x.name = "PatternPosX"
	pos_x.min_value = -100
	pos_x.max_value = 100
	pos_x.step = 0.5
	pos_x.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pos_container.add_child(pos_x)
	
	var pos_y = SpinBox.new()
	pos_y.name = "PatternPosY"
	pos_y.min_value = -100
	pos_y.max_value = 100
	pos_y.step = 0.5
	pos_y.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pos_container.add_child(pos_y)
	
	var pos_z = SpinBox.new()
	pos_z.name = "PatternPosZ"
	pos_z.min_value = -100
	pos_z.max_value = 100
	pos_z.step = 0.5
	pos_z.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pos_container.add_child(pos_z)
	
	# Use camera position button
	var camera_button = Button.new()
	camera_button.text = "Use Camera Position"
	camera_button.pressed.connect(_on_use_pattern_camera_position_pressed)
	layout.add_child(camera_button)
	
	# Create button
	var create_button = Button.new()
	create_button.text = "Generate Pattern"
	create_button.pressed.connect(_on_generate_pattern_pressed)
	layout.add_child(create_button)
	
	# Spacer
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(spacer)
	
	# Pattern list
	var list_title = Label.new()
	list_title.text = "Generated Patterns"
	list_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(list_title)
	
	var pattern_list = ItemList.new()
	pattern_list.name = "PatternList"
	pattern_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	pattern_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(pattern_list)
	
	return panel

func create_info_panel():
	var panel = Control.new()
	panel.name = "InfoPanel"
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	
	var layout = VBoxContainer.new()
	layout.anchor_right = 1.0
	layout.anchor_bottom = 1.0
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(layout)
	
	# Title
	var title = Label.new()
	title.text = "JSH Ethereal Engine Information"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	layout.add_child(title)
	
	# Scrollable content
	var scroll = ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)
	
	var content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(content)
	
	# Add info sections
	var sections = [
		{
			"title": "Universal Entity System",
			"text": "The Universal Entity system is the foundation of the JSH Ethereal Engine. Entities can be manifested from words, transform between different forms, evolve through stages, and interact with each other."
		},
		{
			"title": "Word Manifestation",
			"text": "Words can be manifested into physical entities in the world. Each word has properties that determine its behavior, appearance, and interactions with other entities."
		},
		{
			"title": "Entity Evolution",
			"text": "Entities can evolve through multiple stages, becoming more complex and powerful. Each evolution stage unlocks new abilities and visual enhancements."
		},
		{
			"title": "Pattern Generation",
			"text": "Create patterns of entities in various arrangements such as circles, grids, random distributions, and spheres. Patterns allow for creating complex structures quickly."
		},
		{
			"title": "Commands",
			"text": "The console supports various commands for controlling the system:\n\n- create [word] [x] [y] [z]: Create an entity from a word at the specified position\n- remove [entity_id]: Remove an entity\n- evolve [entity_id]: Evolve an entity to the next stage\n- transform [entity_id] [form]: Transform an entity to a new form\n- connect [entity_id1] [entity_id2]: Connect two entities\n- pattern [word] [type] [count] [radius]: Create a pattern of entities\n- list: List all entities\n- help: Show available commands"
		},
		{
			"title": "Navigation",
			"text": "- Use the mouse to rotate the camera (hold left button and drag)\n- Use WASD keys to move the camera\n- Press Tab to toggle the interface\n- Use the tabs at the top to switch between console, creation, pattern, and information panels"
		},
		{
			"title": "Credits",
			"text": "JSH Ethereal Engine\nDeveloped based on the JSH architecture documentation"
		}
	]
	
	for section in sections:
		var section_title = Label.new()
		section_title.text = section["title"]
		section_title.add_theme_font_size_override("font_size", 16)
		content.add_child(section_title)
		
		var section_text = RichTextLabel.new()
		section_text.text = section["text"]
		section_text.fit_content = true
		section_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		section_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		content.add_child(section_text)
		
		# Add spacing
		var spacer = Control.new()
		spacer.custom_minimum_size.y = 10
		content.add_child(spacer)
	
	return panel

# Button event handlers

func _on_console_tab_pressed():
	hide_all_panels()
	console_panel.visible = true
	current_panel = console_panel
	
	# Focus input field
	var input_field = console_panel.get_node("VBoxContainer/InputContainer/ConsoleInput")
	input_field.grab_focus()

func _on_creation_tab_pressed():
	hide_all_panels()
	creation_panel.visible = true
	current_panel = creation_panel
	
	# Refresh entity list
	_on_refresh_entity_list_pressed()

func _on_pattern_tab_pressed():
	hide_all_panels()
	pattern_panel.visible = true
	current_panel = pattern_panel

func _on_info_tab_pressed():
	hide_all_panels()
	info_panel.visible = true
	current_panel = info_panel

# Console functionality

func _on_console_input_submitted(text):
	if text.strip_edges().is_empty():
		return
	
	# Add to history
	command_history.append(text)
	history_index = -1
	
	# Echo command
	add_console_text("> " + text, Color(1, 1, 1))
	
	# Process command
	process_console_command(text)
	
	# Clear input field
	set_console_input("")

func process_console_command(text):
	var command_parts = text.strip_edges().split(" ", false)
	if command_parts.size() == 0:
		return
	
	var command = command_parts[0].to_lower()
	
	match command:
		"help":
			show_help()
		
		"create":
			if command_parts.size() >= 5:
				var word = command_parts[1]
				var x = float(command_parts[2])
				var y = float(command_parts[3])
				var z = float(command_parts[4])
				var evolution = 0
				if command_parts.size() >= 6:
					evolution = int(command_parts[5])
				
				if thing_creator:
					var entity_id = thing_creator.create_entity(word, Vector3(x, y, z), evolution)
					if not entity_id.is_empty():
						add_console_text("Created entity " + entity_id + " at position (" + str(x) + ", " + str(y) + ", " + str(z) + ")", Color(0.2, 0.8, 0.2))
					else:
						add_console_text("Failed to create entity", Color(0.8, 0.2, 0.2))
				else:
					add_console_text("ThingCreator not available", Color(0.8, 0.2, 0.2))
			else:
				add_console_text("Usage: create [word] [x] [y] [z] [evolution_stage]", Color(0.8, 0.8, 0.2))
		
		"remove":
			if command_parts.size() >= 2:
				var entity_id = command_parts[1]
				
				if thing_creator and thing_creator.has_method("remove_entity"):
					var success = thing_creator.remove_entity(entity_id)
					if success:
						add_console_text("Removed entity " + entity_id, Color(0.2, 0.8, 0.2))
					else:
						add_console_text("Failed to remove entity " + entity_id, Color(0.8, 0.2, 0.2))
				else:
					add_console_text("ThingCreator not available", Color(0.8, 0.2, 0.2))
			else:
				add_console_text("Usage: remove [entity_id]", Color(0.8, 0.8, 0.2))
		
		"evolve":
			if command_parts.size() >= 2:
				var entity_id = command_parts[1]
				
				if thing_creator and thing_creator.has_method("evolve_entity"):
					var success = thing_creator.evolve_entity(entity_id)
					if success:
						add_console_text("Evolved entity " + entity_id, Color(0.2, 0.8, 0.2))
					else:
						add_console_text("Failed to evolve entity " + entity_id, Color(0.8, 0.2, 0.2))
				else:
					add_console_text("ThingCreator not available", Color(0.8, 0.2, 0.2))
			else:
				add_console_text("Usage: evolve [entity_id]", Color(0.8, 0.8, 0.2))
		
		"transform":
			if command_parts.size() >= 3:
				var entity_id = command_parts[1]
				var new_form = command_parts[2]
				
				if thing_creator and thing_creator.has_method("transform_entity"):
					var success = thing_creator.transform_entity(entity_id, new_form)
					if success:
						add_console_text("Transformed entity " + entity_id + " to " + new_form, Color(0.2, 0.8, 0.2))
					else:
						add_console_text("Failed to transform entity " + entity_id, Color(0.8, 0.2, 0.2))
				else:
					add_console_text("ThingCreator not available", Color(0.8, 0.2, 0.2))
			else:
				add_console_text("Usage: transform [entity_id] [new_form]", Color(0.8, 0.8, 0.2))
		
		"connect":
			if command_parts.size() >= 3:
				var entity1_id = command_parts[1]
				var entity2_id = command_parts[2]
				var connection_type = "default"
				if command_parts.size() >= 4:
					connection_type = command_parts[3]
				
				if thing_creator and thing_creator.has_method("connect_entities"):
					var success = thing_creator.connect_entities(entity1_id, entity2_id, connection_type)
					if success:
						add_console_text("Connected entities " + entity1_id + " and " + entity2_id, Color(0.2, 0.8, 0.2))
					else:
						add_console_text("Failed to connect entities", Color(0.8, 0.2, 0.2))
				else:
					add_console_text("ThingCreator not available", Color(0.8, 0.2, 0.2))
			else:
				add_console_text("Usage: connect [entity1_id] [entity2_id] [connection_type]", Color(0.8, 0.8, 0.2))
		
		"pattern":
			if command_parts.size() >= 5:
				var word = command_parts[1]
				var pattern_type = command_parts[2]
				var count = int(command_parts[3])
				var radius = float(command_parts[4])
				
				var position = Vector3.ZERO
				if command_parts.size() >= 8:
					position = Vector3(float(command_parts[5]), float(command_parts[6]), float(command_parts[7]))
				
				if thing_creator and thing_creator.has_method("create_pattern"):
					var pattern_id = thing_creator.create_pattern(word, pattern_type, position, count, radius)
					if not pattern_id.is_empty():
						add_console_text("Created pattern " + pattern_id, Color(0.2, 0.8, 0.2))
					else:
						add_console_text("Failed to create pattern", Color(0.8, 0.2, 0.2))
				else:
					add_console_text("ThingCreator not available", Color(0.8, 0.2, 0.2))
			else:
				add_console_text("Usage: pattern [word] [type] [count] [radius] [x] [y] [z]", Color(0.8, 0.8, 0.2))
				add_console_text("Pattern types: circle, grid, random, sphere", Color(0.8, 0.8, 0.2))
		
		"list":
			if thing_creator and thing_creator.has_method("get_all_entities"):
				var entities = thing_creator.get_all_entities()
				if entities.size() > 0:
					add_console_text("Active entities:", Color(0.2, 0.8, 0.8))
					for entity_id in entities:
						add_console_text("- " + entity_id, Color(0.8, 0.8, 0.8))
				else:
					add_console_text("No active entities", Color(0.8, 0.8, 0.2))
			else:
				add_console_text("ThingCreator not available", Color(0.8, 0.2, 0.2))
		
		_:
			add_console_text("Unknown command: " + command, Color(0.8, 0.2, 0.2))
			add_console_text("Type 'help' for a list of commands", Color(0.8, 0.8, 0.2))

func show_help():
	var help_text = """Available commands:
- create [word] [x] [y] [z] [evolution_stage]: Create an entity from a word
- remove [entity_id]: Remove an entity
- evolve [entity_id]: Evolve an entity to the next stage
- transform [entity_id] [form]: Transform an entity to a new form
- connect [entity1_id] [entity2_id] [connection_type]: Connect two entities
- pattern [word] [type] [count] [radius] [x] [y] [z]: Create a pattern of entities
- list: List all entities
- help: Show this help text

Forms:
seed, flame, droplet, crystal, wisp, flow, void_spark, spark, pattern, orb, sprout, light_mote, shadow_essence

Pattern types:
circle, grid, random, sphere"""
	
	add_console_text(help_text, Color(0.8, 0.8, 0.2))

func add_console_text(text, color = Color.WHITE):
	var output = console_panel.get_node("VBoxContainer/OutputScroll/ConsoleOutput")
	output.push_color(color)
	output.add_text(text + "\n")
	output.pop()
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	output.scroll_to_line(output.get_line_count() - 1)

func set_console_input(text):
	var input_field = console_panel.get_node("VBoxContainer/InputContainer/ConsoleInput")
	input_field.text = text
	input_field.caret_column = text.length()

# Creation panel handlers

func _on_create_entity_button_pressed():
	var word = creation_panel.get_node("WordInput").text
	if word.strip_edges().is_empty():
		return
	
	var pos_x = creation_panel.get_node("PosX").value
	var pos_y = creation_panel.get_node("PosY").value
	var pos_z = creation_panel.get_node("PosZ").value
	var evolution = int(creation_panel.get_node("EvoSlider").value)
	
	if thing_creator:
		var entity_id = thing_creator.create_entity(word, Vector3(pos_x, pos_y, pos_z), evolution)
		if not entity_id.is_empty():
			add_console_text("Created entity " + entity_id + " at position (" + str(pos_x) + ", " + str(pos_y) + ", " + str(pos_z) + ")", Color(0.2, 0.8,.2))
			_on_refresh_entity_list_pressed()
		else:
			add_console_text("Failed to create entity", Color(0.8, 0.2, 0.2))

func _on_use_camera_position_pressed():
	if camera:
		var cam_pos = camera.global_position
		creation_panel.get_node("PosX").value = cam_pos.x
		creation_panel.get_node("PosY").value = cam_pos.y
		creation_panel.get_node("PosZ").value = cam_pos.z

func _on_refresh_entity_list_pressed():
	var entity_list = creation_panel.get_node("EntityList")
	entity_list.clear()
	
	if thing_creator and thing_creator.has_method("get_all_entities"):
		var entities = thing_creator.get_all_entities()
		for entity_id in entities:
			entity_list.add_item(entity_id)

func _on_remove_entity_pressed():
	var entity_list = creation_panel.get_node("EntityList")
	var selected = entity_list.get_selected_items()
	
	if selected.size() > 0:
		var selected_idx = selected[0]
		var entity_id = entity_list.get_item_text(selected_idx)
		
		if thing_creator and thing_creator.has_method("remove_entity"):
			var success = thing_creator.remove_entity(entity_id)
			if success:
				add_console_text("Removed entity " + entity_id, Color(0.2, 0.8, 0.2))
				_on_refresh_entity_list_pressed()
			else:
				add_console_text("Failed to remove entity " + entity_id, Color(0.8, 0.2, 0.2))

func _on_evolve_entity_pressed():
	var entity_list = creation_panel.get_node("EntityList")
	var selected = entity_list.get_selected_items()
	
	if selected.size() > 0:
		var selected_idx = selected[0]
		var entity_id = entity_list.get_item_text(selected_idx)
		
		if thing_creator and thing_creator.has_method("evolve_entity"):
			var success = thing_creator.evolve_entity(entity_id)
			if success:
				add_console_text("Evolved entity " + entity_id, Color(0.2, 0.8, 0.2))
			else:
				add_console_text("Failed to evolve entity " + entity_id, Color(0.8, 0.2, 0.2))

# Pattern panel handlers

func _on_use_pattern_camera_position_pressed():
	if camera:
		var cam_pos = camera.global_position
		pattern_panel.get_node("PatternPosX").value = cam_pos.x
		pattern_panel.get_node("PatternPosY").value = cam_pos.y
		pattern_panel.get_node("PatternPosZ").value = cam_pos.z

func _on_generate_pattern_pressed():
	var word = pattern_panel.get_node("PatternWordInput").text
	if word.strip_edges().is_empty():
		return

	var type_option = pattern_panel.get_node("PatternType")
	var pattern_type = "circle"
	match type_option.selected:
		0: pattern_type = "circle"
		1: pattern_type = "grid"
		2: pattern_type = "random"
		3: pattern_type = "sphere"

	var count = int(pattern_panel.get_node("PatternCount").value)
	var radius = float(pattern_panel.get_node("PatternRadius").value)

	var pos_x = pattern_panel.get_node("PatternPosX").value
	var pos_y = pattern_panel.get_node("PatternPosY").value
	var pos_z = pattern_panel.get_node("PatternPosZ").value

	if thing_creator and thing_creator.has_method("create_pattern"):
		var pattern_id = thing_creator.create_pattern(word, pattern_type, Vector3(pos_x, pos_y, pos_z), count, radius)
		if not pattern_id.is_empty():
			add_console_text("Created pattern " + pattern_id, Color(0.2, 0.8, 0.2))

			# Update pattern list
			var pattern_list = pattern_panel.get_node("PatternList")
			pattern_list.add_item(pattern_id + " (" + pattern_type + ", " + word + " x" + str(count) + ")")
		else:
			add_console_text("Failed to create pattern", Color(0.8, 0.2, 0.2))

# Behavior Panel Methods

func create_behavior_panel():
	var panel = Control.new()
	panel.name = "BehaviorPanel"
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0

	var layout = VBoxContainer.new()
	layout.anchor_right = 1.0
	layout.anchor_bottom = 1.0
	layout.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(layout)

	# Title
	var title = Label.new()
	title.text = "Entity Behaviors"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	layout.add_child(title)

	# Description
	var description = Label.new()
	description.text = "Control how entities interact with the environment and each other."
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(description)

	# Behavior enable/disable
	var toggle_container = HBoxContainer.new()
	layout.add_child(toggle_container)

	var toggle_label = Label.new()
	toggle_label.text = "Enable Behaviors: "
	toggle_container.add_child(toggle_label)

	var toggle_button = CheckButton.new()
	toggle_button.name = "BehaviorToggle"
	toggle_button.pressed = true
	toggle_button.pressed.connect(_on_behavior_toggle_pressed)
	toggle_container.add_child(toggle_button)

	# Update interval
	var interval_container = HBoxContainer.new()
	layout.add_child(interval_container)

	var interval_label = Label.new()
	interval_label.text = "Update Interval (seconds): "
	interval_container.add_child(interval_label)

	var interval_slider = HSlider.new()
	interval_slider.name = "IntervalSlider"
	interval_slider.min_value = 0.1
	interval_slider.max_value = 1.0
	interval_slider.step = 0.1
	interval_slider.value = 0.5
	interval_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	interval_slider.value_changed.connect(_on_interval_changed)
	interval_container.add_child(interval_slider)

	var interval_value = Label.new()
	interval_value.name = "IntervalValue"
	interval_value.text = "0.5"
	interval_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	interval_container.add_child(interval_value)

	# Entity behavior presets section
	var presets_title = Label.new()
	presets_title.text = "Behavior Presets"
	presets_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	presets_title.add_theme_font_size_override("font_size", 16)
	layout.add_child(presets_title)

	var presets_container = HBoxContainer.new()
	layout.add_child(presets_container)

	var preset_names = ["Calm", "Lively", "Chaotic", "Reactive"]
	for preset in preset_names:
		var preset_button = Button.new()
		preset_button.text = preset
		preset_button.pressed.connect(func(): _on_preset_pressed(preset))
		presets_container.add_child(preset_button)

	# Interactive entities list
	var list_title = Label.new()
	list_title.text = "Interactive Entities"
	list_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	list_title.add_theme_font_size_override("font_size", 16)
	layout.add_child(list_title)

	var entity_list = ItemList.new()
	entity_list.name = "InteractiveEntityList"
	entity_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	layout.add_child(entity_list)

	# Button container
	var button_container = HBoxContainer.new()
	layout.add_child(button_container)

	var refresh_button = Button.new()
	refresh_button.text = "Refresh List"
	refresh_button.pressed.connect(_on_refresh_behaviors_pressed)
	button_container.add_child(refresh_button)

	var reinitialize_button = Button.new()
	reinitialize_button.text = "Reinitialize All"
	reinitialize_button.pressed.connect(_on_reinitialize_behaviors_pressed)
	button_container.add_child(reinitialize_button)

	return panel

func _on_behavior_tab_pressed():
	hide_all_panels()
	behavior_panel.visible = true
	current_panel = behavior_panel

	# Refresh the entity list
	_on_refresh_behaviors_pressed()

func _on_behavior_toggle_pressed():
	if behavior_system:
		var toggle = behavior_panel.get_node("BehaviorToggle")
		behavior_system.behavior_active = toggle.pressed
		add_console_text("Entity behaviors " + ("enabled" if toggle.pressed else "disabled"),
						Color(0.2, 0.8, 0.2))

func _on_interval_changed(value):
	if behavior_system:
		behavior_system.update_interval = value
		behavior_panel.get_node("IntervalValue").text = str(value)

func _on_preset_pressed(preset_name):
	if not behavior_system:
		return

	match preset_name:
		"Calm":
			behavior_system.update_interval = 0.8
			behavior_panel.get_node("IntervalSlider").value = 0.8
			behavior_panel.get_node("IntervalValue").text = "0.8"
			# Apply calm behavior settings

		"Lively":
			behavior_system.update_interval = 0.4
			behavior_panel.get_node("IntervalSlider").value = 0.4
			behavior_panel.get_node("IntervalValue").text = "0.4"
			# Apply lively behavior settings

		"Chaotic":
			behavior_system.update_interval = 0.2
			behavior_panel.get_node("IntervalSlider").value = 0.2
			behavior_panel.get_node("IntervalValue").text = "0.2"
			# Apply chaotic behavior settings

		"Reactive":
			behavior_system.update_interval = 0.3
			behavior_panel.get_node("IntervalSlider").value = 0.3
			behavior_panel.get_node("IntervalValue").text = "0.3"
			# Apply reactive behavior settings

	add_console_text("Applied '" + preset_name + "' behavior preset", Color(0.2, 0.8, 0.2))

func _on_refresh_behaviors_pressed():
	if not behavior_system:
		return

	var entity_list = behavior_panel.get_node("InteractiveEntityList")
	entity_list.clear()

	# Get all interactive entities
	var entities = behavior_system.interactive_entities
	for entity_id in entities:
		var data = entities[entity_id]
		var entity = data.entity

		if is_instance_valid(entity):
			entity_list.add_item(entity_id + " (" + data.behavior_key + ")")

func _on_reinitialize_behaviors_pressed():
	if not behavior_system or not thing_creator:
		return

	behavior_system.interactive_entities.clear()

	# Re-register all existing entities
	var entities = thing_creator.get_all_entities()
	for entity_id in entities:
		var entity = thing_creator.get_entity(entity_id)
		if entity:
			behavior_system._on_entity_created(entity_id, entity.source_word, entity.global_position)

	add_console_text("Reinitialized behaviors for all entities", Color(0.2, 0.8, 0.2))
	_on_refresh_behaviors_pressed()