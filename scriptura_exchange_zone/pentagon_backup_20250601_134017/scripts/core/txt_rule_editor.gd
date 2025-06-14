# 🏛️ Txt Rule Editor - Ragdoll physics and behavior system
# Author: JSH (Migrated by Pentagon Engine)
# Created: May 31, 2025, 23:28 CEST
# Purpose: Ragdoll physics and behavior system
# Connection: Part of Pentagon Architecture migration

# ==================================================
# SCRIPT NAME: txt_rule_editor.gd
# DESCRIPTION: In-game editor for TXT rule files
# PURPOSE: Edit game rules live through UI
# ==================================================

extends UniversalBeingBase
class_name TxtRuleEditor

# UI elements
var file_list: ItemList
var text_editor: TextEdit
var save_button: Button
var refresh_button: Button
var current_file: String = ""

# Paths
const RULES_PATH = "res://user/lists/"
const DEFINITIONS_PATH = "res://assets/definitions/"

# Current loaded files
var loaded_files: Dictionary = {}

func _ready() -> void:
	_create_ui()
	_load_file_list()

func _create_ui() -> void:
	"""Create the editor interface"""
	set_custom_minimum_size(Vector2(800, 600))
	
	# Main container
	var hbox = HSplitContainer.new()
	add_child(hbox)
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Left panel - file list
	var left_panel = VBoxContainer.new()
	FloodgateController.universal_add_child(left_panel, hbox)
	left_panel.custom_minimum_size.x = 200
	
	var label = Label.new()
	label.text = "TXT Rule Files"
	FloodgateController.universal_add_child(label, left_panel)
	
	file_list = ItemList.new()
	file_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	file_list.item_selected.connect(_on_file_selected)
	FloodgateController.universal_add_child(file_list, left_panel)
	
	refresh_button = Button.new()
	refresh_button.text = "Refresh Files"
	refresh_button.pressed.connect(_load_file_list)
	FloodgateController.universal_add_child(refresh_button, left_panel)
	
	# Right panel - text editor
	var right_panel = VBoxContainer.new()
	FloodgateController.universal_add_child(right_panel, hbox)
	
	var header = HBoxContainer.new()
	FloodgateController.universal_add_child(header, right_panel)
	
	var file_label = Label.new()
	file_label.text = "Editing: None"
	file_label.name = "FileLabel"
	FloodgateController.universal_add_child(file_label, header)
	
	header.add_spacer(false)
	
	save_button = Button.new()
	save_button.text = "Save"
	save_button.pressed.connect(_save_current_file)
	save_button.disabled = true
	FloodgateController.universal_add_child(save_button, header)
	
	text_editor = TextEdit.new()
	text_editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	text_editor.text_changed.connect(_on_text_changed)
	text_editor.syntax_highlighter = CodeHighlighter.new()
	
	# Configure syntax highlighting
	var highlighter = text_editor.syntax_highlighter as CodeHighlighter
	highlighter.add_keyword_color("if", Color.CYAN)
	highlighter.add_keyword_color("then", Color.CYAN)
	highlighter.add_keyword_color("else", Color.CYAN)
	highlighter.add_keyword_color("when", Color.CYAN)
	highlighter.add_keyword_color("->", Color.YELLOW)
	highlighter.add_color_region("#", "", Color.GRAY, true)  # Comments
	highlighter.add_color_region("[", "]", Color.GREEN)      # Sections
	
	FloodgateController.universal_add_child(text_editor, right_panel)

func _load_file_list() -> void:
	"""Load all TXT files from rules and definitions"""
	file_list.clear()
	loaded_files.clear()
	
	# Load user rules
	_scan_directory(RULES_PATH, "Rules")
	
	# Load asset definitions
	_scan_directory(DEFINITIONS_PATH + "objects/", "Objects")
	_scan_directory(DEFINITIONS_PATH + "interfaces/", "Interfaces")
	_scan_directory(DEFINITIONS_PATH + "creatures/", "Creatures")

func _scan_directory(path: String, category: String) -> void:
	"""Scan directory for TXT files"""
	var dir = DirAccess.open(path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".txt"):
			var display_name = category + "/" + file_name
			file_list.add_item(display_name)
			loaded_files[display_name] = path + file_name
		file_name = dir.get_next()

func _on_file_selected(index: int) -> void:
	"""Load selected file into editor"""
	var display_name = file_list.get_item_text(index)
	var file_path = loaded_files.get(display_name, "")
	
	if file_path.is_empty():
		return
	
	current_file = file_path
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		text_editor.text = file.get_as_text()
		file.close()
		
		var label = get_node("FileLabel") as Label
		if label:
			label.text = "Editing: " + display_name
		
		save_button.disabled = false

func _on_text_changed() -> void:
	"""Mark file as modified"""
	if save_button:
		save_button.modulate = Color.YELLOW  # Visual indication of unsaved changes

func _save_current_file() -> void:
	"""Save the current file"""
	if current_file.is_empty():
		return
	
	var file = FileAccess.open(current_file, FileAccess.WRITE)
	if file:
		file.store_string(text_editor.text)
		file.close()
		
		save_button.modulate = Color.WHITE
		
		# Notify systems of rule change
		_notify_rule_change(current_file)
		
		print("[TxtRuleEditor] Saved: " + current_file)

func _notify_rule_change(file_path: String) -> void:
	"""Notify game systems that rules have changed"""
	# If it's a game rule file
	if file_path.contains("/lists/"):
		var lists_viewer = get_node_or_null("/root/ListsViewerSystem")
		if lists_viewer and lists_viewer.has_method("reload_file"):
			var file_name = file_path.get_file()
			lists_viewer.reload_file(file_name)
	
	# If it's an asset definition
	elif file_path.contains("/definitions/"):
		var asset_library = get_node_or_null("/root/AssetLibrary")
		if asset_library and asset_library.has_method("reload_definitions"):
			asset_library.reload_definitions()

# Console command integration
static func create_editor() -> TxtRuleEditor:
	"""Create and return editor instance"""
	var editor = TxtRuleEditor.new()
	editor.name = "TxtRuleEditor"
	return editor

func _init() -> void:
	pentagon_init()

func pentagon_init() -> void:
	# Pentagon initialization - override in child classes
	pass

func _process(delta: float) -> void:
	pentagon_process(delta)

func pentagon_process(delta: float) -> void:
	# Pentagon logic processing - override in child classes
	pass

func _input(event: InputEvent) -> void:
	pentagon_input(event)

func pentagon_input(event: InputEvent) -> void:
	# Pentagon input handling - override in child classes
	pass

func sewers() -> void:
	pentagon_sewers()

func pentagon_sewers() -> void:
	# Pentagon cleanup/output - override in child classes
	pass