extends Node
class_name CoreThingCreatorStandalone

# This script creates a standalone menu for the Thing Creator
# Use this if your scene doesn't have a suitable menu system

var thing_creator: Node = null
var akashic_records_manager: Node = null
var ui_visible: bool = false
var current_ui_instance: Node = null

# UI elements
var ui_container: Control = null
var menu_panel: VBoxContainer = null
var view_area: Control = null

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	print("==== Thing Creator Standalone Starting ====")
	find_akashic_records()
	setup_thing_creator()
	create_ui()
	print("==== Thing Creator Standalone Complete ====")
	print("Press 'T' to toggle the Thing Creator menu")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_T:
		toggle_ui()

func find_akashic_records() -> void:
	print("Searching for AkashicRecordsManager...")

	if has_node("/root/AkashicRecordsManager"):
		akashic_records_manager = get_node("/root/AkashicRecordsManager")
		print("Found AkashicRecordsManager")
		return

	if has_node("/root/CoreAkashicRecordsManager"):
		akashic_records_manager = get_node("/root/CoreAkashicRecordsManager")
		print("Found CoreAkashicRecordsManager")
		return

	akashic_records_manager = find_node_by_class("CoreAkashicRecordsManager")
	if akashic_records_manager:
		print("Found CoreAkashicRecordsManager by search")
	else:
		print("Could not find CoreAkashicRecordsManager node")
		print("Attempting to create CoreAkashicRecordsManager instance")
		var AkashicRecordsClass = load("res://code/gdscript/scripts/core/core_akashic_records_manager.gd")
		if AkashicRecordsClass:
			akashic_records_manager = AkashicRecordsClass.new()
			if akashic_records_manager:
				akashic_records_manager.name = "CoreAkashicRecordsManager"
				get_tree().root.add_child(akashic_records_manager)
				akashic_records_manager.initialize()
				print("Created and initialized CoreAkashicRecordsManager")
			else:
				print("Could not create CoreAkashicRecordsManager")

func setup_thing_creator() -> void:
	print("Setting up Thing Creator...")

	if has_node("/root/ThingCreator"):
		thing_creator = get_node("/root/ThingCreator")
		print("ThingCreator already exists")
		return

	if has_node("/root/CoreThingCreator"):
		thing_creator = get_node("/root/CoreThingCreator")
		print("CoreThingCreator already exists")
		return

	thing_creator = find_node_by_class("CoreThingCreator")
	if thing_creator:
		print("Found CoreThingCreator by search")
		return

	# Updated to use the new path and class name
	var ThingCreatorClass = load("res://code/gdscript/scripts/core/core_thing_creator.gd")
	if ThingCreatorClass:
		thing_creator = ThingCreatorClass.new()
		thing_creator.name = "CoreThingCreator"
		get_tree().root.add_child(thing_creator)
		print("Created new CoreThingCreator instance")
	else:
		print("Failed to load CoreThingCreator class")

func create_ui() -> void:
	print("Creating standalone UI...")

	ui_container = Control.new()
	ui_container.name = "ThingCreatorUI"
	ui_container.anchor_right = 1.0
	ui_container.anchor_bottom = 1.0
	ui_container.visible = false

	var bg_panel = Panel.new()
	bg_panel.name = "Background"
	bg_panel.anchor_right = 1.0
	bg_panel.anchor_bottom = 1.0

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	bg_panel.add_theme_stylebox_override("panel", style)
	ui_container.add_child(bg_panel)

	var h_split = HSplitContainer.new()
	h_split.name = "Layout"
	h_split.anchor_right = 1.0
	h_split.anchor_bottom = 1.0
	h_split.split_offset = 200
	bg_panel.add_child(h_split)

	menu_panel = VBoxContainer.new()
	menu_panel.name = "MenuPanel"
	h_split.add_child(menu_panel)

	var title = Label.new()
	title.text = "Thing Creator"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 18)
	menu_panel.add_child(title)

	create_menu_buttons()

	view_area = Control.new()
	view_area.name = "ViewArea"
	h_split.add_child(view_area)

	get_tree().root.add_child(ui_container)
	print("Standalone UI created - press 'T' to toggle")

func create_menu_buttons() -> void:
	var create_button = Button.new()
	create_button.text = "Create Thing"
	create_button.pressed.connect(_on_create_thing_button_pressed)
	menu_panel.add_child(create_button)

	var manage_button = Button.new()
	manage_button.text = "Manage Things"
	manage_button.pressed.connect(_on_manage_things_button_pressed)
	menu_panel.add_child(manage_button)

	var dictionary_button = Button.new()
	dictionary_button.text = "Dictionary"
	dictionary_button.pressed.connect(_on_dictionary_button_pressed)
	menu_panel.add_child(dictionary_button)

	var help_button = Button.new()
	help_button.text = "Help"
	help_button.pressed.connect(_on_help_button_pressed)
	menu_panel.add_child(help_button)

	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	menu_panel.add_child(spacer)

	var close_button = Button.new()
	close_button.text = "Close Menu (T)"
	close_button.pressed.connect(_on_close_button_pressed)
	menu_panel.add_child(close_button)

func toggle_ui() -> void:
	ui_visible = !ui_visible
	ui_container.visible = ui_visible

func _close_current_ui() -> void:
	if current_ui_instance and is_instance_valid(current_ui_instance):
		current_ui_instance.queue_free()
		current_ui_instance = null

func open_thing_creator_ui() -> void:
	_close_current_ui()
	var scene = load("res://code/gdscript/scenes/thing_creator_ui.tscn")
	if scene:
		current_ui_instance = scene.instantiate()
		view_area.add_child(current_ui_instance)
		print("Core Thing Creator UI opened")
	else:
		print("Error: Core Thing Creator UI scene not found")

func show_message(message: String) -> void:
	print(message)

# --- Button callbacks ---
func _on_create_thing_button_pressed() -> void:
	open_thing_creator_ui()

func _on_manage_things_button_pressed() -> void:
	_close_current_ui()

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

	if thing_creator:
		var things = thing_creator.get_all_things()
		for thing_id in things:
			var word_id = thing_creator.get_thing_word(thing_id)
			var position = thing_creator.get_thing_position(thing_id)
			list.add_item("%s (%s) at %s" % [thing_id, word_id, str(position)])

	var buttons = HBoxContainer.new()
	manager.add_child(buttons)

	var refresh_button = Button.new()
	refresh_button.text = "Refresh"
	refresh_button.pressed.connect(func(): _on_manage_things_button_pressed())
	buttons.add_child(refresh_button)

	var remove_button = Button.new()
	remove_button.text = "Remove Selected"
	buttons.add_child(remove_button)

	current_ui_instance = manager
	view_area.add_child(current_ui_instance)

	print("Thing Manager opened")

func _on_dictionary_button_pressed() -> void:
	_close_current_ui()

	var scene = load("res://code/gdscript/scenes/akashic_records_ui.tscn")
	if scene:
		current_ui_instance = scene.instantiate()
		view_area.add_child(current_ui_instance)
		print("Dictionary UI opened")
	else:
		print("Error: Akashic Records UI scene not found")

func _on_help_button_pressed() -> void:
	_close_current_ui()

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

	var sections = [
		{"title": "Getting Started", "content": "The Thing Creator allows you to create physical objects in the game world based on dictionary entries. Start by selecting a word from the dictionary and setting a position."},
		{"title": "Create Thing", "content": "Opens the Thing Creator UI where you can select dictionary entries and create objects at specific positions in the game world."},
		{"title": "Manage Things", "content": "Shows a list of all created things and allows you to remove them."},
		{"title": "Dictionary", "content": "Opens the Akashic Records dictionary where you can view and edit dictionary entries."},
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

		var spacer = Control.new()
		spacer.custom_minimum_size.y = 10
		content.add_child(spacer)

	current_ui_instance = help
	view_area.add_child(current_ui_instance)

	print("Help opened")

func _on_close_button_pressed() -> void:
	toggle_ui()

# --- Recursive finder ---
func find_node_by_class(class_name_to_find: String, node: Node = null) -> Node:
	if node == null:
		node = get_tree().root

	if node.get_class() == class_name_to_find:
		return node

	for child in node.get_children():
		var found = find_node_by_class(class_name_to_find, child)
		if found:
			return found

	return null