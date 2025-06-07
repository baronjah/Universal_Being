# ==================================================
# UNIVERSE CONSOLE - The Creator's Interface
# PURPOSE: Visual interface for universe creation and inspection
# LOCATION: core/systems/UniverseConsole.gd
# ==================================================

extends Control
class_name UniverseConsole

## UI Components
@onready var tab_container: TabContainer = TabContainer.new()
@onready var creation_tab: Control = Control.new()
@onready var inspector_tab: Control = Control.new()
@onready var multiverse_tab: Control = Control.new()
@onready var chronicle_tab: Control = Control.new()

## Creation UI
var universe_name_input: LineEdit
var parent_selector: OptionButton
var create_button: Button
var reality_sliders: Dictionary = {}

## Inspector UI
var universe_info_label: RichTextLabel
var beings_list: ItemList
var rules_editor: GridContainer

## Multiverse UI
var universe_tree: Tree
var universe_minimap: Control

## Chronicle UI
var chronicle_display: RichTextLabel
var filter_options: HBoxContainer

## System references
var universe_manager: UniverseManager
var poetic_logger: PoeticLogger
var akashic_library: AkashicLibrary

signal universe_created(universe_name: String)
signal universe_entered(universe_name: String)
signal reality_modified(rule: String, value: Variant)

func _ready() -> void:
	_get_system_references()
	_setup_ui()
	_connect_signals()
	_refresh_displays()

func _get_system_references() -> void:
	"""Get references to required systems"""
	universe_manager = get_node("/root/UniverseManager")
	poetic_logger = get_node("/root/PoeticLogger")
	if has_node("/root/AkashicLibrary"):
		akashic_library = get_node("/root/AkashicLibrary")

func _setup_ui() -> void:
	"""Build the console interface"""
	# Console window setup
	custom_minimum_size = Vector2(800, 600)
	
	# Main container
	var panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(panel)
	# Tab container
	tab_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(tab_container)
	
	# Setup tabs
	_setup_creation_tab()
	_setup_inspector_tab()
	_setup_multiverse_tab()
	_setup_chronicle_tab()

func _setup_creation_tab() -> void:
	"""Setup universe creation interface"""
	creation_tab.name = "Create Universe"
	tab_container.add_child(creation_tab)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 10)
	creation_tab.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "Birth a New Universe"
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	# Universe name
	var name_container = HBoxContainer.new()
	vbox.add_child(name_container)
	
	var name_label = Label.new()
	name_label.text = "Universe Name:"
	name_label.custom_minimum_size.x = 150
	name_container.add_child(name_label)
	
	universe_name_input = LineEdit.new()
	universe_name_input.placeholder_text = "Enter universe name..."
	universe_name_input.custom_minimum_size.x = 300
	name_container.add_child(universe_name_input)
	
	# Parent universe selector
	var parent_container = HBoxContainer.new()
	vbox.add_child(parent_container)
	
	var parent_label = Label.new()
	parent_label.text = "Parent Universe:"
	parent_label.custom_minimum_size.x = 150
	parent_container.add_child(parent_label)
	
	parent_selector = OptionButton.new()
	parent_selector.custom_minimum_size.x = 300
	parent_container.add_child(parent_selector)
	
	# Reality rules section
	var rules_label = Label.new()
	rules_label.text = "Reality Parameters"
	rules_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(rules_label)
	
	var rules_grid = GridContainer.new()
	rules_grid.columns = 3
	vbox.add_child(rules_grid)
	
	# Add reality rule sliders
	_add_reality_slider(rules_grid, "Gravity", "physics_gravity", 0.0, 20.0, 9.8)
	_add_reality_slider(rules_grid, "Time Scale", "time_scale", 0.1, 10.0, 1.0)
	_add_reality_slider(rules_grid, "Evolution Rate", "evolution_rate", 0.0, 5.0, 1.0)
	_add_reality_slider(rules_grid, "LOD Distance", "lod_distance", 10.0, 1000.0, 100.0)
	
	# Create button
	create_button = Button.new()
	create_button.text = "Manifest Universe"
	create_button.custom_minimum_size = Vector2(200, 40)
	create_button.pressed.connect(_on_create_pressed)
	vbox.add_child(create_button)
func _setup_inspector_tab() -> void:
	"""Setup universe inspection interface"""
	inspector_tab.name = "Inspector"
	tab_container.add_child(inspector_tab)
	
	var hsplit = HSplitContainer.new()
	hsplit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	inspector_tab.add_child(hsplit)
	
	# Left panel - Universe info
	var left_panel = VBoxContainer.new()
	hsplit.add_child(left_panel)
	
	var info_label = Label.new()
	info_label.text = "Universe Information"
	info_label.add_theme_font_size_override("font_size", 18)
	left_panel.add_child(info_label)
	
	universe_info_label = RichTextLabel.new()
	universe_info_label.custom_minimum_size = Vector2(300, 200)
	universe_info_label.bbcode_enabled = true
	left_panel.add_child(universe_info_label)
	
	# Right panel - Beings list
	var right_panel = VBoxContainer.new()
	hsplit.add_child(right_panel)
	
	var beings_label = Label.new()
	beings_label.text = "Beings in Universe"
	beings_label.add_theme_font_size_override("font_size", 18)
	right_panel.add_child(beings_label)
	
	beings_list = ItemList.new()
	beings_list.custom_minimum_size = Vector2(300, 400)
	right_panel.add_child(beings_list)

func _setup_multiverse_tab() -> void:
	"""Setup multiverse visualization"""
	multiverse_tab.name = "Multiverse"
	tab_container.add_child(multiverse_tab)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	multiverse_tab.add_child(vbox)
	
	# Universe tree
	universe_tree = Tree.new()
	universe_tree.custom_minimum_size = Vector2(400, 500)
	universe_tree.item_selected.connect(_on_universe_selected)
	vbox.add_child(universe_tree)
	
	# Action buttons
	var button_container = HBoxContainer.new()
	vbox.add_child(button_container)
	
	var enter_button = Button.new()
	enter_button.text = "Enter Universe"
	enter_button.pressed.connect(_on_enter_universe)
	button_container.add_child(enter_button)
	
	var exit_button = Button.new()
	exit_button.text = "Exit to Parent"
	exit_button.pressed.connect(_on_exit_universe)
	button_container.add_child(exit_button)

func _setup_chronicle_tab() -> void:
	"""Setup chronicle viewer"""
	chronicle_tab.name = "Chronicle"
	tab_container.add_child(chronicle_tab)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	chronicle_tab.add_child(vbox)
	
	# Filter options
	filter_options = HBoxContainer.new()
	vbox.add_child(filter_options)
	
	var filter_label = Label.new()
	filter_label.text = "Filter:"
	filter_options.add_child(filter_label)
	
	var filter_types = ["All", "Creation", "Evolution", "Connection", "Reality Change"]
	for filter_type in filter_types:
		var button = Button.new()
		button.text = filter_type
		button.toggle_mode = true
		button.pressed.connect(_on_filter_changed.bind(filter_type.to_lower()))
		filter_options.add_child(button)
	
	# Chronicle display
	chronicle_display = RichTextLabel.new()
	chronicle_display.bbcode_enabled = true
	chronicle_display.custom_minimum_size = Vector2(600, 400)
	vbox.add_child(chronicle_display)
## HELPER FUNCTIONS ==================================================

func _add_reality_slider(parent: GridContainer, label_text: String, rule_key: String, 
		min_val: float, max_val: float, default: float) -> void:
	"""Add a reality rule slider"""
	var label = Label.new()
	label.text = label_text + ":"
	parent.add_child(label)
	
	var slider = HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = default
	slider.custom_minimum_size.x = 200
	parent.add_child(slider)
	
	var value_label = Label.new()
	value_label.text = str(default)
	value_label.custom_minimum_size.x = 50
	parent.add_child(value_label)
	
	slider.value_changed.connect(func(value): value_label.text = "%.2f" % value)
	reality_sliders[rule_key] = slider

func _connect_signals() -> void:
	"""Connect to system signals"""
	universe_manager.universe_created.connect(_on_universe_created)
	universe_manager.universe_entered.connect(_on_universe_entered)
	
	if poetic_logger:
		poetic_logger.verse_written.connect(_on_verse_written)

func _refresh_displays() -> void:
	"""Refresh all UI displays"""
	_refresh_parent_selector()
	_refresh_universe_info()
	_refresh_universe_tree()
	_refresh_chronicle()

func _refresh_parent_selector() -> void:
	"""Update parent universe dropdown"""
	parent_selector.clear()
	parent_selector.add_item("Current Universe", 0)
	
	var universes = universe_manager.get_all_universes()
	for i in range(universes.size()):
		parent_selector.add_item(universes[i].name, i + 1)
		parent_selector.set_item_metadata(i + 1, universes[i])

func _refresh_universe_info() -> void:
	"""Update universe inspector"""
	var universe = universe_manager.active_universe
	var info = universe_manager.get_universe_info(universe)
	
	var info_text = "[b]%s[/b]\n" % info.name
	info_text += "[color=gray]UUID: %s[/color]\n\n" % info.uuid.substr(0, 12)
	info_text += "Parent: %s\n" % info.parent
	info_text += "Children: %d\n" % info.children
	info_text += "Beings: %d\n" % info.beings
	info_text += "Age: %.1f seconds\n\n" % info.age
	
	info_text += "[b]Reality Rules:[/b]\n"
	for rule in info.rules:
		info_text += "• %s: %s\n" % [rule.capitalize(), info.rules[rule]]
	
	universe_info_label.text = info_text
	
	# Update beings list
	beings_list.clear()
	for being in universe.beings:
		var item_text = being.name
		if being.has_method("get_being_type"):
			item_text += " [%s]" % being.get_being_type()
		beings_list.add_item(item_text)

func _refresh_universe_tree() -> void:
	"""Update multiverse tree view"""
	universe_tree.clear()
	var root = universe_tree.create_item()
	root.set_text(0, "Multiverse")
	
	var tree_data = universe_manager.get_universe_tree()
	for universe_name in tree_data:
		_add_universe_to_tree(root, universe_name, tree_data[universe_name])

func _add_universe_to_tree(parent: TreeItem, name: String, data: Dictionary) -> void:
	"""Recursively add universe to tree"""
	var item = universe_tree.create_item(parent)
	item.set_text(0, "%s (%d beings)" % [name, data.beings])
	item.set_metadata(0, data.uuid)
	
	# Highlight active universe
	if universe_manager.active_universe and data.uuid == universe_manager.active_universe.uuid:
		item.set_custom_bg_color(0, Color(0.2, 0.3, 0.5))
	
	# Add children
	for child_name in data.children:
		_add_universe_to_tree(item, child_name, data.children[child_name])

func _refresh_chronicle() -> void:
	"""Update chronicle display"""
	if not akashic_library:
		chronicle_display.text = "[i]Akashic Library not available[/i]"
		return
	
	var verses = poetic_logger.get_chronicle_verses()
	var chronicle_text = "[b]Chronicle of Creation[/b]\n\n"
	
	for verse in verses:
		chronicle_text += verse + "\n\n"
	
	chronicle_display.text = chronicle_text
## EVENT HANDLERS ==================================================

func _on_create_pressed() -> void:
	"""Handle universe creation"""
	var universe_name = universe_name_input.text.strip_edges()
	if universe_name == "":
		return
	
	# Get parent universe
	var parent_universe = null
	var selected_idx = parent_selector.selected
	if selected_idx > 0:
		parent_universe = parent_selector.get_item_metadata(selected_idx)
	
	# Gather reality rules
	var custom_rules = {}
	for rule_key in reality_sliders:
		custom_rules[rule_key] = reality_sliders[rule_key].value
	
	# Create universe
	var new_universe = universe_manager.create_universe(universe_name, parent_universe, {
		"created_via": "universe_console",
		"custom_rules": custom_rules
	})
	
	# Apply custom rules
	for rule in custom_rules:
		universe_manager.set_universe_rule(new_universe, rule, custom_rules[rule])
	
	# Clear input
	universe_name_input.text = ""
	
	# Emit signal
	universe_created.emit(universe_name)
	
	# Refresh displays
	_refresh_displays()

func _on_universe_selected() -> void:
	"""Handle universe selection in tree"""
	var selected = universe_tree.get_selected()
	if selected:
		var uuid = selected.get_metadata(0)
		var universe = universe_manager.get_universe_by_uuid(uuid)
		if universe:
			# Update info display for selected universe
			var info = universe_manager.get_universe_info(universe)
			# Could show preview of selected universe

func _on_enter_universe() -> void:
	"""Enter selected universe"""
	var selected = universe_tree.get_selected()
	if selected:
		var uuid = selected.get_metadata(0)
		var universe = universe_manager.get_universe_by_uuid(uuid)
		if universe:
			universe_manager.enter_universe(universe)
			universe_entered.emit(universe.name)
			_refresh_displays()

func _on_exit_universe() -> void:
	"""Exit to parent universe"""
	if universe_manager.exit_to_parent():
		_refresh_displays()

func _on_filter_changed(filter_type: String) -> void:
	"""Handle chronicle filter change"""
	# Update chronicle display based on filter
	if filter_type == "all":
		_refresh_chronicle()
	else:
		var filtered_verses = poetic_logger.get_chronicle_verses(filter_type)
		var chronicle_text = "[b]Chronicle of Creation - %s[/b]\n\n" % filter_type.capitalize()
		
		for verse in filtered_verses:
			chronicle_text += verse + "\n\n"
		
		chronicle_display.text = chronicle_text

func _on_universe_created(universe: UniverseManager.Universe) -> void:
	"""Handle universe creation event"""
	_refresh_displays()

func _on_universe_entered(universe: UniverseManager.Universe) -> void:
	"""Handle universe entry event"""
	_refresh_displays()

func _on_verse_written(verse: String, context: Dictionary) -> void:
	"""Handle new chronicle entry"""
	# Append to chronicle display if on chronicle tab
	if tab_container.current_tab == 3: # Chronicle tab
		chronicle_display.append_text(verse + "\n\n")

## PUBLIC INTERFACE ==================================================

func show_console() -> void:
	"""Show the universe console"""
	visible = true
	_refresh_displays()

func hide_console() -> void:
	"""Hide the universe console"""
	visible = false

func toggle_console() -> void:
	"""Toggle console visibility"""
	visible = not visible
	if visible:
		_refresh_displays()