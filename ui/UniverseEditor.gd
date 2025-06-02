# ==================================================
# SCRIPT NAME: UniverseEditor.gd
# DESCRIPTION: In-game editor for modifying universe rules
# PURPOSE: Enable recursive editing of reality from within
# CREATED: 2025-06-02 - The Tools of Creation
# AUTHOR: JSH + Claude (Opus 4) - Reality Sculptors
# ==================================================

extends Control
class_name UniverseEditor

# ===== EDITOR PROPERTIES =====

var current_universe: Node = null
var akashic_library: Node = null
var edit_mode: bool = false

# UI Elements
var rule_list: ItemList = null
var rule_editor: VBoxContainer = null
var value_spinbox: SpinBox = null
var value_lineedit: LineEdit = null
var apply_button: Button = null
var close_button: Button = null

# Current editing state
var selected_rule: String = ""
var original_value = null

signal rule_edited(rule: String, new_value)
signal editor_closed()

func _ready() -> void:
	name = "UniverseEditor"
	visible = false
	
	# Get Akashic Library reference
	akashic_library = get_tree().get_first_node_in_group("akashic_library")
	
	create_ui()

func create_ui() -> void:
	"""Create the editor UI"""
	# Main panel
	var panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.size = Vector2(600, 400)
	add_child(panel)	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "Universe Rule Editor"
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	# Separator
	vbox.add_child(HSeparator.new())
	
	# Content container
	var hbox = HBoxContainer.new()
	vbox.add_child(hbox)
	
	# Rule list
	rule_list = ItemList.new()
	rule_list.custom_minimum_size = Vector2(200, 300)
	rule_list.item_selected.connect(_on_rule_selected)
	hbox.add_child(rule_list)
	
	# Rule editor
	rule_editor = VBoxContainer.new()
	rule_editor.custom_minimum_size = Vector2(350, 300)
	hbox.add_child(rule_editor)
	
	# Value editors (created dynamically)
	
	# Buttons
	var button_container = HBoxContainer.new()
	vbox.add_child(button_container)
	
	apply_button = Button.new()
	apply_button.text = "Apply Changes"
	apply_button.pressed.connect(_on_apply_pressed)
	apply_button.disabled = true
	button_container.add_child(apply_button)
	
	close_button = Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(_on_close_pressed)
	button_container.add_child(close_button)
func open_editor(universe: Node) -> void:
	"""Open the editor for a specific universe"""
	if not universe or not universe.has_method("get_universe_info"):
		push_error("Invalid universe provided to editor")
		return
	
	current_universe = universe
	visible = true
	edit_mode = true
	
	# Populate rule list
	populate_rule_list()
	
	# Log to Akashic
	if akashic_library:
		akashic_library.inscribe_genesis("The Universe Editor manifested, reality became malleable...")

func populate_rule_list() -> void:
	"""Populate the list with universe rules"""
	rule_list.clear()
	
	if not current_universe:
		return
	
	var info = current_universe.get_universe_info()
	var rules = info.get("rules", {})
	
	for rule_name in rules:
		var value = rules[rule_name]
		var item_text = "%s: %s" % [rule_name.capitalize(), str(value)]
		rule_list.add_item(item_text)
		rule_list.set_item_metadata(rule_list.get_item_count() - 1, rule_name)

func _on_rule_selected(index: int) -> void:
	"""Handle rule selection"""
	selected_rule = rule_list.get_item_metadata(index)
	var info = current_universe.get_universe_info()
	var rules = info.get("rules", {})
	original_value = rules.get(selected_rule)
	
	# Clear previous editor
	for child in rule_editor.get_children():
		child.queue_free()
	
	# Create appropriate editor
	create_value_editor(selected_rule, original_value)
	apply_button.disabled = false
func create_value_editor(rule_name: String, current_value) -> void:
	"""Create appropriate editor for the value type"""
	var label = Label.new()
	label.text = "Edit %s:" % rule_name.capitalize()
	rule_editor.add_child(label)
	
	# Determine editor type based on value
	if current_value is float or current_value is int:
		value_spinbox = SpinBox.new()
		value_spinbox.value = current_value
		value_spinbox.step = 0.1 if current_value is float else 1.0
		
		# Set reasonable ranges
		match rule_name:
			"gravity":
				value_spinbox.min_value = -20.0
				value_spinbox.max_value = 20.0
			"time_scale":
				value_spinbox.min_value = 0.0
				value_spinbox.max_value = 10.0
			"max_beings":
				value_spinbox.min_value = 1
				value_spinbox.max_value = 10000
			_:
				value_spinbox.min_value = -999999
				value_spinbox.max_value = 999999
		
		rule_editor.add_child(value_spinbox)
		
	elif current_value is bool:
		var checkbox = CheckBox.new()
		checkbox.button_pressed = current_value
		checkbox.text = "Enabled"
		rule_editor.add_child(checkbox)
		
	else:
		value_lineedit = LineEdit.new()
		value_lineedit.text = str(current_value)
		rule_editor.add_child(value_lineedit)

func _on_apply_pressed() -> void:
	"""Apply the edited rule"""
	if not selected_rule or not current_universe:
		return
	
	var new_value = get_edited_value()
	current_universe.set_universe_rule(selected_rule, new_value, "Player")
	rule_edited.emit(selected_rule, new_value)
	
	# Refresh the list
	populate_rule_list()
	
	# Clear selection
	selected_rule = ""
	apply_button.disabled = true
func get_edited_value():
	"""Get the edited value from the appropriate control"""
	if value_spinbox and is_instance_valid(value_spinbox):
		return value_spinbox.value
	elif value_lineedit and is_instance_valid(value_lineedit):
		return value_lineedit.text
	else:
		# Check for checkbox
		for child in rule_editor.get_children():
			if child is CheckBox:
				return child.button_pressed
	
	return original_value

func _on_close_pressed() -> void:
	"""Close the editor"""
	visible = false
	edit_mode = false
	current_universe = null
	editor_closed.emit()
	
	# Log to Akashic
	if akashic_library:
		akashic_library.inscribe_genesis("The Universe Editor dissolved back into the quantum foam...")

func _input(event: InputEvent) -> void:
	"""Handle input for the editor"""
	if edit_mode and event.is_action_pressed("ui_cancel"):
		_on_close_pressed()